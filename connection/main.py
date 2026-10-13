import mysql.connector
from mysql.connector import Error

# ---- your student number (the connection details come from it) ----
STUDENT_NUMBER = ""

# Port = "2" + last four digits of the student number 
PORT = int("2" + STUDENT_NUMBER[-4:])


DB_CONFIG = {
    "host": "172.21.12.21",
    "port": PORT,
    "user": STUDENT_NUMBER,
    "password": "!St" + STUDENT_NUMBER,
    "database": "university_accommodation",
    "ssl_disabled": False,          # the server requires SSL
    "ssl_verify_cert": False,       # self-signed certificate, so do not verify
    "ssl_verify_identity": False,
    "connection_timeout": 10,
}


def connect():
    """Create and return a database connection."""
    return mysql.connector.connect(**DB_CONFIG)


def run_query(conn, sql, params=None):
    """Run a SELECT query and print the results as a table."""
    cursor = conn.cursor()
    cursor.execute(sql, params)
    rows = cursor.fetchall()
    headers = [col[0] for col in cursor.description]
    cursor.close()

    if not rows:
        print("No results found.")
        return

    # work out column widths so the output lines up
    widths = [len(h) for h in headers]
    for row in rows:
        for i, value in enumerate(row):
            widths[i] = max(widths[i], len(str(value)))

    print(" | ".join(h.ljust(widths[i]) for i, h in enumerate(headers)))
    print("-+-".join("-" * w for w in widths))
    for row in rows:
        print(" | ".join(str(v).ljust(widths[i]) for i, v in enumerate(row)))


# ------------------- QUERIES -------------------

def residence_capacity(conn):
    sql = """
        SELECT r.ResidenceName,
               COUNT(rm.RoomID) AS NumberOfRooms,
               SUM(rm.Capacity) AS TotalBeds
        FROM residence r
        INNER JOIN room rm ON r.ResidenceID = rm.ResidenceID
        GROUP BY r.ResidenceName
    """
    run_query(conn, sql)


def unpaid_fees(conn):
    sql = """
        SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
               COUNT(py.PaymentID) AS UnpaidPayments,
               SUM(py.Amount)      AS AmountOwed
        FROM student s
        INNER JOIN payment py ON s.StudentID = py.StudentID
        WHERE py.Status IN ('Pending', 'Overdue')
        GROUP BY s.StudentID, s.FirstName, s.LastName
    """
    run_query(conn, sql)


def students_without_room(conn):
    sql = """
        SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
               s.Programme
        FROM student s
        LEFT JOIN allocation al ON s.StudentID = al.StudentID
        WHERE al.AllocationID IS NULL
    """
    run_query(conn, sql)


def maintenance_summary(conn):
    sql = """
        SELECT r.ResidenceName, mr.Priority,
               COUNT(mr.RequestID) AS Requests
        FROM maintenance_request mr
        INNER JOIN room rm ON mr.RoomID = rm.RoomID
        INNER JOIN residence r ON rm.ResidenceID = r.ResidenceID
        GROUP BY r.ResidenceName, mr.Priority
    """
    run_query(conn, sql)


def search_student(conn):
    name = input("Enter part of a student's first or last name: ")
    sql = """
        SELECT StudentID, FirstName, LastName, Email, Programme
        FROM student
        WHERE FirstName LIKE %s OR LastName LIKE %s
    """
    pattern = "%" + name + "%"
    run_query(conn, sql, (pattern, pattern))


def add_maintenance_request(conn):
    """INSERT example: a student reports a maintenance problem."""
    try:
        room_id = int(input("Room ID: "))
        student_id = int(input("Student ID: "))
    except ValueError:
        print("Room ID and Student ID must be numbers.")
        return
    description = input("Description of the problem: ")
    priority = input("Priority (Low/Medium/High): ").capitalize()

    if priority not in ("Low", "Medium", "High"):
        print("Priority must be Low, Medium or High.")
        return

    sql = """
        INSERT INTO maintenance_request
            (RoomID, StudentID, RequestDate, Description, Priority, Status)
        VALUES (%s, %s, CURDATE(), %s, %s, 'Open')
    """
    cursor = conn.cursor()
    cursor.execute(sql, (room_id, student_id, description, priority))
    conn.commit()
    print("Maintenance request added (ID", cursor.lastrowid, ")")
    cursor.close()


# ------------------- NEW QUERIES -------------------

def students_per_programme(conn):
    """How many students are enrolled in each programme."""
    sql = """
        SELECT Programme,
               COUNT(StudentID) AS NumberOfStudents
        FROM student
        GROUP BY Programme
        ORDER BY NumberOfStudents DESC
    """
    run_query(conn, sql)


def payment_status_summary(conn):
    """Number and total value of payments for each payment status."""
    sql = """
        SELECT Status,
               COUNT(PaymentID) AS NumberOfPayments,
               SUM(Amount)      AS TotalAmount
        FROM payment
        GROUP BY Status
        ORDER BY TotalAmount DESC
    """
    run_query(conn, sql)


def residence_occupancy(conn):
    """Beds taken vs total beds per residence, as a percentage.

    Assumes allocation has a RoomID column linking it to room.
    """
    sql = """
        SELECT r.ResidenceName,
               cap.TotalBeds,
               COALESCE(occ.Occupied, 0) AS BedsOccupied,
               ROUND(100 * COALESCE(occ.Occupied, 0) / cap.TotalBeds, 1)
                   AS PercentFull
        FROM residence r
        INNER JOIN (
            SELECT ResidenceID, SUM(Capacity) AS TotalBeds
            FROM room
            GROUP BY ResidenceID
        ) cap ON r.ResidenceID = cap.ResidenceID
        LEFT JOIN (
            SELECT rm.ResidenceID, COUNT(al.AllocationID) AS Occupied
            FROM room rm
            INNER JOIN allocation al ON al.RoomID = rm.RoomID
            GROUP BY rm.ResidenceID
        ) occ ON r.ResidenceID = occ.ResidenceID
        ORDER BY PercentFull DESC
    """
    run_query(conn, sql)


def open_maintenance_requests(conn):
    """All open requests with who reported them and where, highest priority first."""
    sql = """
        SELECT mr.RequestID,
               r.ResidenceName,
               mr.RoomID,
               CONCAT(s.FirstName, ' ', s.LastName) AS ReportedBy,
               mr.Priority,
               mr.RequestDate,
               mr.Description
        FROM maintenance_request mr
        INNER JOIN student s   ON mr.StudentID = s.StudentID
        INNER JOIN room rm     ON mr.RoomID = rm.RoomID
        INNER JOIN residence r ON rm.ResidenceID = r.ResidenceID
        WHERE mr.Status = 'Open'
        ORDER BY FIELD(mr.Priority, 'High', 'Medium', 'Low'), mr.RequestDate
    """
    run_query(conn, sql)


def repeat_reporters(conn):
    """Students who have submitted more than one maintenance request."""
    sql = """
        SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
               COUNT(mr.RequestID) AS RequestsSubmitted
        FROM student s
        INNER JOIN maintenance_request mr ON s.StudentID = mr.StudentID
        GROUP BY s.StudentID, s.FirstName, s.LastName
        HAVING COUNT(mr.RequestID) > 1
        ORDER BY RequestsSubmitted DESC
    """
    run_query(conn, sql)


def recent_maintenance_requests(conn):
    """Maintenance requests from the last N days (the user chooses N)."""
    try:
        days = int(input("Show requests from the last how many days? "))
    except ValueError:
        print("Please enter a whole number.")
        return
    sql = """
        SELECT mr.RequestID, mr.RequestDate, mr.Priority, mr.Status,
               mr.Description
        FROM maintenance_request mr
        WHERE mr.RequestDate >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
        ORDER BY mr.RequestDate DESC
    """
    run_query(conn, sql, (days,))


# ------------------- MAIN MENU -------------------

def main():
    try:
        conn = connect()
        print("Connected to the database.")
    except Error as e:
        print("Could not connect:", e)
        return

    menu = {
        "1": ("Residence capacity", residence_capacity),
        "2": ("Students with unpaid fees", unpaid_fees),
        "3": ("Students without a room", students_without_room),
        "4": ("Maintenance requests by residence and priority", maintenance_summary),
        "5": ("Search for a student", search_student),
        "6": ("Add a maintenance request", add_maintenance_request),
        "7": ("Number of students per programme", students_per_programme),
        "8": ("Payment summary by status", payment_status_summary),
        "9": ("Residence occupancy (% full)", residence_occupancy),
        "10": ("Open maintenance requests (highest priority first)", open_maintenance_requests),
        "11": ("Students with repeat maintenance requests", repeat_reporters),
        "12": ("Recent maintenance requests (last N days)", recent_maintenance_requests),
    }

    while True:
        print("\n=== University Accommodation System ===")
        for key, (label, _) in menu.items():
            print(key + ". " + label)
        print("0. Exit")

        choice = input("Choose an option: ")
        if choice == "0":
            break
        if choice in menu:
            print()
            try:
                menu[choice][1](conn)
            except Error as e:
                print("Database error:", e)
        else:
            print("Invalid option, try again.")

    conn.close()
    print("Connection closed. Goodbye!")


if __name__ == "__main__":
    main()
