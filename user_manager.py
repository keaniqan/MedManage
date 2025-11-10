import mysql.connector
from mysql.connector import Error
import hashlib
import csv
import json
import random
from faker import Faker

# =========================
# UserInserter Class
# =========================
class UserInserter:
    def __init__(self, host='localhost', port=3307, database='MedManageDB', user='root', password=''):
        """Initialize database connection"""
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password
        self.connection = None

    def connect(self):
        """Create database connection"""
        try:
            self.connection = mysql.connector.connect(
                host=self.host,
                port=self.port,
                database=self.database,
                user=self.user,
                password=self.password
            )
            if self.connection.is_connected():
                print(f"Successfully connected to {self.database} on port {self.port}")
                return True
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            return False

    def hash_password(self, password):
        """Hash password using SHA256"""
        return hashlib.sha256(password.encode()).hexdigest()

    # -------------------------
    # Single and Bulk Inserts
    # -------------------------
    def insert_single_user(self, username, email, user_type, first_name, last_name,
                          phone, password, identification, gender, institute_id=None):
        """Insert a single user into the database"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            password_hash = self.hash_password(password)
            query = """
            INSERT INTO users (Username, Email, UserType, FirstName, LastName,
                               Phone, PasswordHash, Identification, Gender, InstituteID)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            values = (username, email, user_type, first_name, last_name,
                      phone, password_hash, identification, gender, institute_id)
            cursor.execute(query, values)
            self.connection.commit()
            cursor.close()
            return cursor.lastrowid
        except Error as e:
            print(f"✗ Error inserting user '{username}': {e}")
            return False

    def insert_bulk_users(self, users_list):
        """Insert multiple users from a list of dictionaries"""
        success_count = 0
        fail_count = 0
        for user in users_list:
            result = self.insert_single_user(
                username=user.get('username'),
                email=user.get('email'),
                user_type=user.get('user_type', 'patient'),
                first_name=user.get('first_name'),
                last_name=user.get('last_name'),
                phone=user.get('phone'),
                password=user.get('password', 'default123'),
                identification=user.get('identification'),
                gender=user.get('gender'),
                institute_id=user.get('institute_id')
            )
            if result:
                success_count += 1
            else:
                fail_count += 1
        print(f"\n=== Bulk Insert Summary ===")
        print(f"Successful: {success_count}")
        print(f"Failed: {fail_count}")
        print(f"Total: {len(users_list)}")

    # -------------------------
    # CSV / JSON Inserts
    # -------------------------
    def insert_from_csv(self, csv_file_path):
        """Insert users from a CSV file"""
        users_list = []
        try:
            with open(csv_file_path, 'r', encoding='utf-8') as file:
                csv_reader = csv.DictReader(file)
                for row in csv_reader:
                    users_list.append(row)
            print(f"Loaded {len(users_list)} users from CSV")
            self.insert_bulk_users(users_list)
        except FileNotFoundError:
            print(f"Error: File '{csv_file_path}' not found")
        except Exception as e:
            print(f"Error reading CSV: {e}")

    def insert_from_json(self, json_file_path):
        """Insert users from a JSON file"""
        try:
            with open(json_file_path, 'r', encoding='utf-8') as file:
                users_list = json.load(file)
            print(f"Loaded {len(users_list)} users from JSON")
            self.insert_bulk_users(users_list)
        except FileNotFoundError:
            print(f"Error: File '{json_file_path}' not found")
        except Exception as e:
            print(f"Error reading JSON: {e}")

    # -------------------------
    # User Statistics
    # -------------------------
    def count_users(self, user_type=None):
        """Count total users or users by type"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return 0
        try:
            cursor = self.connection.cursor()
            if user_type:
                query = "SELECT COUNT(*) FROM users WHERE UserType = %s"
                cursor.execute(query, (user_type,))
            else:
                query = "SELECT COUNT(*) FROM users"
                cursor.execute(query)
            count = cursor.fetchone()[0]
            cursor.close()
            return count
        except Error as e:
            print(f"Error counting users: {e}")
            return 0

    def get_user_statistics(self):
        """Get detailed user statistics"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return None
        try:
            cursor = self.connection.cursor()
            query = "SELECT UserType, COUNT(*) as count FROM users GROUP BY UserType"
            cursor.execute(query)
            results = cursor.fetchall()
            stats = {'total': self.count_users(), 'by_type': {}}
            for user_type, count in results:
                stats['by_type'][user_type] = count
            cursor.close()
            return stats
        except Error as e:
            print(f"Error getting statistics: {e}")
            return None

    def print_statistics(self):
        """Print user statistics in a readable format"""
        stats = self.get_user_statistics()
        if stats:
            print("\n=== Database User Statistics ===")
            print(f"Total Users: {stats['total']}")
            print("\nBy User Type:")
            for user_type, count in stats['by_type'].items():
                print(f"  {user_type.capitalize()}: {count}")
            print("=" * 32)

    # -------------------------
    # Deletion / Limiting Users
    # -------------------------
    def delete_user_by_id(self, user_id):
        """Delete a user by UserID"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            query = "DELETE FROM users WHERE UserID = %s"
            cursor.execute(query, (user_id,))
            self.connection.commit()
            success = cursor.rowcount > 0
            cursor.close()
            if success:
                print(f"✓ User with ID {user_id} deleted successfully")
            else:
                print(f"✗ No user found with ID {user_id}")
            return success
        except Error as e:
            print(f"✗ Error deleting user: {e}")
            return False

    def delete_users_by_type(self, user_type):
        """Delete all users of a specific type"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            query = "DELETE FROM users WHERE UserType = %s"
            cursor.execute(query, (user_type,))
            self.connection.commit()
            deleted_count = cursor.rowcount
            print(f"✓ Deleted {deleted_count} {user_type}(s)")
            cursor.close()
            return deleted_count
        except Error as e:
            print(f"✗ Error deleting users: {e}")
            return False

    def clear_all_users(self, confirm=False):
        """Clear all users from database (use with caution!)"""
        if not confirm:
            print("⚠️  WARNING: This will delete ALL users! Call with confirm=True")
            return False
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            query = "DELETE FROM users"
            cursor.execute(query)
            self.connection.commit()
            deleted_count = cursor.rowcount
            print(f"✓ Deleted all {deleted_count} users")
            cursor.close()
            return deleted_count
        except Error as e:
            print(f"✗ Error clearing users: {e}")
            return False

    def limit_users_by_type(self, user_type, max_count):
        """Keep only the specified number of users of a type (keeps oldest)"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            current_count = self.count_users(user_type)
            if current_count <= max_count:
                print(f"Current {user_type} count ({current_count}) is within limit ({max_count})")
                return True
            query = """
            DELETE FROM users 
            WHERE UserType = %s 
            AND UserID NOT IN (
                SELECT UserID FROM (
                    SELECT UserID FROM users 
                    WHERE UserType = %s 
                    ORDER BY UserID ASC 
                    LIMIT %s
                ) AS keep_users
            )
            """
            cursor.execute(query, (user_type, user_type, max_count))
            self.connection.commit()
            deleted_count = cursor.rowcount
            print(f"✓ Reduced {user_type} count from {current_count} to {max_count} (Deleted {deleted_count} users)")
            cursor.close()
            return True
        except Error as e:
            print(f"✗ Error limiting users: {e}")
            return False

    # -------------------------
    # Close Connection
    # -------------------------
    def close(self):
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("Database connection closed")

# =========================
# Bulk User Generation
# =========================
fake = Faker()

def generate_users(count, user_type, institute_id=101):
    """Generate a list of fake users"""
    users = []
    for _ in range(count):
        first_name = fake.first_name()
        last_name = fake.last_name()
        username = f"{first_name.lower()}_{last_name.lower()}{random.randint(1,9999)}"
        email = f"{username}@example.com"
        phone = f"+60{random.choice(['11','12','13','16','17','18','19'])}{random.randint(1000000,9999999)}"
        identification = f"IC{random.randint(100000,999999)}"
        gender = random.choice(['M','F'])
        password = "password123"
        users.append({
            'username': username,
            'email': email,
            'user_type': user_type,
            'first_name': first_name,
            'last_name': last_name,
            'phone': phone,
            'password': password,
            'identification': identification,
            'gender': gender,
            'institute_id': institute_id
        })
    return users


# Main Part

if __name__ == "__main__":
    inserter = UserInserter(
        host='localhost',
        port=3307,
        database='MedManageDB',
        user='root',
        password='root'  
    )

    if inserter.connect():
        print("\n--- Generating Users ---")
        # Generate users
        patients = generate_users(1000, 'patient', institute_id=101)
        doctors = generate_users(100, 'doctor', institute_id=101)
        admins = generate_users(5, 'admin', institute_id=101)
        superadmin = [{
            'username': 'superadmin',
            'email': 'superadmin@example.com',
            'user_type': 'super admin',
            'first_name': 'Super',
            'last_name': 'Admin',
            'phone': '0123456789',
            'password': 'admin',
            'identification': 'IC000000',
            'gender': 'M',
            'institute_id': 101
        }]
        all_users = patients + doctors + admins + superadmin
        print(f"Total users to insert: {len(all_users)}")

        # Bulk insert
        inserter.insert_bulk_users(all_users)

        # Print statistics
        inserter.print_statistics()

        # Close connection
        inserter.close()
