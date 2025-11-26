try:
    import mysql.connector
    from mysql.connector import Error
except ModuleNotFoundError as e:
    raise SystemExit(
        "mysql.connector not found. Fix with:\n"
        "pip uninstall -y mysql mysql-connector\n"
        "pip install -U mysql-connector-python"
    )
import json
import hashlib
import random
from turtle import title
from faker import Faker

def _print_mysql_connector_info():
    try:
        import mysql
        ver = getattr(getattr(mysql, "connector", None), "__version__", None)
        if ver:
            print(f"mysql-connector-python version: {ver}")
        else:
            # Shadowing package present
            print(
                "Detected conflicting 'mysql' package without connector. Run:\n"
                "pip uninstall -y mysql mysql-connector && pip install -U mysql-connector-python"
            )
    except Exception:
        pass

_print_mysql_connector_info()

# =========================
# UserInserter Class
# =========================
class UserInserter:
    def __init__(self, host='localhost', port=3307, database='medmanagedb', user='root', password='root'):
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
            print("If this is an import error, reinstall:\n"
                  "pip uninstall -y mysql mysql-connector && pip install -U mysql-connector-python")
            return False

    def hash_password(self, password):
        """Hash password using SHA256"""
        return hashlib.sha256(password.encode()).hexdigest()

    # -------------------------
    # Single User Insert
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
            user_id = cursor.lastrowid
            cursor.close()
            print(f"✓ Created User: {first_name} {last_name} ({user_type})")
            return user_id
        except Error as e:
            print(f"✗ Error inserting user '{username}': {e}")
            return False

    # -------------------------
    # Insert Patient Details
    # -------------------------
    def insert_patient_details(self, user_id, abo_blood_type, rh_blood_type, emergency_contact, dob):
        """Insert patient details"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            query = """
            INSERT INTO patientdetails (UserID, ABOBloodType, RhBloodType, EmergencyContact, DOB)
            VALUES (%s, %s, %s, %s, %s)
            """
            values = (user_id, abo_blood_type, rh_blood_type, emergency_contact, dob)
            cursor.execute(query, values)
            self.connection.commit()
            patient_details_id = cursor.lastrowid
            cursor.close()
            return patient_details_id
        except Error as e:
            print(f"✗ Error inserting patient details: {e}")
            return False

    # -------------------------
    # Insert Doctor Using Stored Procedure
    # -------------------------
    def insert_doctor_with_procedure(self, username, email, first_name, last_name,
                                     phone, password, identification, gender, institute_id,
                                     specialist, medical_licence_number, years_of_experience,
                                     medical_school, certificates, languages_spoken):
        """Insert a doctor using the AddDoctor stored procedure"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            
            # Convert languages_spoken list to JSON string if it's a list
            if isinstance(languages_spoken, list):
                languages_json = json.dumps(languages_spoken)
            else:
                languages_json = languages_spoken
            
            # Call the stored procedure
            cursor.callproc('AddDoctor', [
                username,
                email,
                first_name,
                last_name,
                phone,
                password,  # Plain password - procedure will hash it
                identification,
                gender,
                institute_id,
                specialist,
                medical_licence_number,
                years_of_experience,
                medical_school,
                certificates,
                languages_json
            ])
            
            self.connection.commit()
            
            # Get the UserID that was created
            cursor.execute("SELECT UserID FROM users WHERE Username = %s", (username,))
            result = cursor.fetchone()
            user_id = result[0] if result else None
            
            # Get the DoctorDetailsID
            if user_id:
                cursor.execute("SELECT DoctorDetailsID FROM doctordetails WHERE UserID = %s", (user_id,))
                result = cursor.fetchone()
                doctor_details_id = result[0] if result else None
            else:
                doctor_details_id = None
            
            cursor.close()
            
            print(f"✓ Created Doctor via Stored Procedure: {first_name} {last_name} ({specialist})")
            return doctor_details_id
            
        except Error as e:
            print(f"✗ Error calling AddDoctor procedure for '{username}': {e}")
            return False

    # -------------------------
    # Insert Doctor Details (Keep for backward compatibility)
    # -------------------------
    def insert_doctor_details(self, user_id, specialist, medical_licence_number, 
                             years_of_experience, medical_school, certificates, languages_spoken):
        """Insert doctor details (legacy method - kept for compatibility)"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            query = """
            INSERT INTO doctordetails (UserID, Specialist, MedicalLicenceNumber, YearsOfExperience,
                                       MedicalSchool, Certificates, LanguagesSpoken)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            values = (user_id, specialist, medical_licence_number, years_of_experience,
                     medical_school, certificates, json.dumps(languages_spoken))
            cursor.execute(query, values)
            self.connection.commit()
            doctor_details_id = cursor.lastrowid
            cursor.close()
            return doctor_details_id
        except Error as e:
            print(f"✗ Error inserting doctor details: {e}")
            return False

    # -------------------------
    # Link Doctor to Patient
    # -------------------------
    def link_doctor_patient(self, patient_details_id, doctor_details_id, is_primary=False):
        """Link a doctor to a patient"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            query = """
            INSERT INTO doctor_patient (PatientDetailsID, DoctorDetailsID, IsPrimaryDoctor)
            VALUES (%s, %s, %s)
            """
            values = (patient_details_id, doctor_details_id, is_primary)
            cursor.execute(query, values)
            self.connection.commit()
            cursor.close()
            return True
        except Error as e:
            print(f"✗ Error linking doctor to patient: {e}")
            return False

    # -------------------------
    # Initialize Institutes
    # -------------------------
    def initialize_institutes(self):
        """Insert 5 hardcoded institutes into the database"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        
        institutes = [
            ('Sarawak General Hospital', 'Jalan Hospital', None, 'Kuching', 'SWK', 'MY', '93586'),
            ('Normah Medical Specialist Centre', 'Jalan Tun Abdul Rahman Yakub', None, 'Kuching', 'SWK', 'MY', '93350'),
            ('Timberland Medical Centre', 'Jalan Rock', 'Taman Rock', 'Kuching', 'SWK', 'MY', '93200'),
            ('Borneo Medical Centre', 'Jalan Tun Jugah', None, 'Kuching', 'SWK', 'MY', '93350'),
            ('KPJ Healthcare Kuching', 'Lot 1230 & 1231 Section 66 KTLD', 'Jalan Tun Ahmad Zaidi Adruce', 'Kuching', 'SWK', 'MY', '93200')
        ]
        
        try:
            cursor = self.connection.cursor()
            
            # Check if institutes already exist
            cursor.execute("SELECT COUNT(*) FROM institute")
            count = cursor.fetchone()[0]
            
            if count >= 5:
                print("✓ Institutes already exist in database")
                cursor.close()
                return True
            
            # Clear existing institutes and insert new ones
            cursor.execute("DELETE FROM institute")
            
            query = """
            INSERT INTO institute (Name, AddressLine1, AddressLine2, City, StateProvinceCode, Country, PostalCode)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            
            for institute in institutes:
                cursor.execute(query, institute)
            
            self.connection.commit()
            cursor.close()
            print(f"✓ Successfully inserted {len(institutes)} institutes")
            return True
            
        except Error as e:
            print(f"✗ Error initializing institutes: {e}")
            return False

    # -------------------------
    # Bulk Insert with Relations (UPDATED TO USE STORED PROCEDURE)
    # -------------------------
    def insert_doctors_with_patients(self, num_doctors, patients_per_doctor=10):
        """Insert doctors using stored procedure and assign patients to them"""
        fake = Faker()
        
        print(f"\n--- Generating {num_doctors} Doctors with {patients_per_doctor} Patients Each ---")
        
        titles = ['Dr.', 'Prof. Dr.', 'Assoc. Prof. Dr.']
        medical_schools = [
            'University of Malaya', 'National University of Singapore',
            'Monash University', 'University of Melbourne',
            'King\'s College London', 'Johns Hopkins University'
        ]
        certificates = [
            'MBBS, MRCP', 'MBBS, FRCS', 'MD, FACP',
            'MBBS, MMed', 'MD, PhD', 'MBBS, FRCPE'
        ]
        languages = [
            ["English", "Malay"],
            ["English", "Mandarin"],
            ["English", "Tamil"],
            ["English", "Malay", "Mandarin"]
        ]
        
        # Get list of institute IDs
        cursor = self.connection.cursor()
        cursor.execute("SELECT InstituteID FROM institute")
        institute_ids = [row[0] for row in cursor.fetchall()]
        cursor.close()
        
        if not institute_ids:
            print("✗ No institutes found in database!")
            return
        
        success_doctors = 0
        success_patients = 0
        
        for i in range(num_doctors):
            # Distribute doctors across institutes
            institute_id = institute_ids[i % len(institute_ids)]
            
            # Generate doctor data
            first_name = fake.first_name()
            last_name = fake.last_name()
            username = f"dr_{first_name.lower()}_{last_name.lower()}{random.randint(1,999)}"
            email = f"{username}@hospital.com"
            phone = f"+60{random.choice(['11','12','13'])}{random.randint(1000000,9999999)}"
            identification = f"IC{random.randint(700000,999999)}"
            gender = random.choice(['M','F'])
            
            specialist = random.choice(['Cardiologist', 'Dermatologist', 'Neurologist', 
                                       'Pediatrician', 'General Practitioner', 'Orthopedic Surgeon'])
            medical_licence = f"MMC{random.randint(10000,99999)}"
            years_exp = random.randint(5, 30)
            school = random.choice(medical_schools)
            cert = random.choice(certificates)
            langs = random.choice(languages)
            
            # Use stored procedure to create doctor
            doctor_details_id = self.insert_doctor_with_procedure(
                username=username,
                email=email,
                first_name=first_name,
                last_name=last_name,
                phone=phone,
                password='doctor123',
                identification=identification,
                gender=gender,
                institute_id=institute_id,
                specialist=specialist,
                medical_licence_number=medical_licence,
                years_of_experience=years_exp,
                medical_school=school,
                certificates=cert,
                languages_spoken=langs
            )
            
            if doctor_details_id:
                success_doctors += 1
                
                # Create patients for this doctor
                for j in range(patients_per_doctor):
                    patient_first = fake.first_name()
                    patient_last = fake.last_name()
                    patient_username = f"{patient_first.lower()}_{patient_last.lower()}{random.randint(1,9999)}"
                    patient_email = f"{patient_username}@example.com"
                    patient_phone = f"+60{random.choice(['16','17','18','19'])}{random.randint(1000000,9999999)}"
                    patient_id = f"IC{random.randint(100000,699999)}"
                    patient_gender = random.choice(['M','F'])
                    
                    patient_user_id = self.insert_single_user(
                        username=patient_username,
                        email=patient_email,
                        user_type='patient',
                        first_name=patient_first,
                        last_name=patient_last,
                        phone=patient_phone,
                        password='patient123',
                        identification=patient_id,
                        gender=patient_gender,
                        institute_id=institute_id
                    )
                    
                    if not patient_user_id:
                        continue
                    
                    # Create patient details
                    blood_abo = random.choice(['A', 'B', 'AB', 'O'])
                    blood_rh = random.choice(['+', '-'])
                    emergency = f"+60{random.choice(['11','12','13','16','17'])}{random.randint(1000000,9999999)}"
                    dob = fake.date_of_birth(minimum_age=18, maximum_age=85)
                    
                    patient_details_id = self.insert_patient_details(
                        user_id=patient_user_id,
                        abo_blood_type=blood_abo,
                        rh_blood_type=blood_rh,
                        emergency_contact=emergency,
                        dob=dob
                    )
                    
                    if patient_details_id:
                        # Link patient to doctor (first patient is primary)
                        is_primary = (j == 0)
                        self.link_doctor_patient(patient_details_id, doctor_details_id, is_primary)
                        success_patients += 1
                        print(f"    → Assigned Patient: {patient_first} {patient_last} {'(Primary)' if is_primary else ''}")
        
        print(f"\n=== Generation Summary ===")
        print(f"Doctors Created: {success_doctors}/{num_doctors}")
        print(f"Patients Created: {success_patients}/{num_doctors * patients_per_doctor}")
        print(f"Total Users: {success_doctors + success_patients}")
        print(f"Institutes Used: {len(institute_ids)}")

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
            
            # Additional stats
            if self.connection and self.connection.is_connected():
                cursor = self.connection.cursor()
                cursor.execute("SELECT COUNT(*) FROM patientdetails")
                patient_details = cursor.fetchone()[0]
                cursor.execute("SELECT COUNT(*) FROM doctordetails")
                doctor_details = cursor.fetchone()[0]
                cursor.execute("SELECT COUNT(*) FROM doctor_patient")
                relationships = cursor.fetchone()[0]
                cursor.close()
                
                print(f"\nPatient Details Records: {patient_details}")
                print(f"Doctor Details Records: {doctor_details}")
                print(f"Doctor-Patient Relationships: {relationships}")
            print("=" * 32)

    # -------------------------
    # Deletion Functions
    # -------------------------
    def clear_all_data(self, confirm=False):
        """Clear all data from database (use with caution!)"""
        if not confirm:
            print("⚠️  WARNING: This will delete ALL data! Call with confirm=True")
            return False
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            # Disable foreign key checks temporarily
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
            
            # Delete in order to respect foreign key constraints
            cursor.execute("DELETE FROM reminder")
            cursor.execute("DELETE FROM compliance")
            cursor.execute("DELETE FROM prescriptiondetail")
            cursor.execute("DELETE FROM prescription")
            cursor.execute("DELETE FROM appointment")
            cursor.execute("DELETE FROM symptom")
            cursor.execute("DELETE FROM disease_patientdetails")
            cursor.execute("DELETE FROM doctor_patient")
            cursor.execute("DELETE FROM doctordetails")
            cursor.execute("DELETE FROM patientdetails")
            cursor.execute("DELETE FROM users")
            cursor.execute("DELETE FROM medicine")
            cursor.execute("DELETE FROM disease")
            cursor.execute("DELETE FROM institute")
            
            # Re-enable foreign key checks
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
            
            self.connection.commit()
            cursor.close()
            print("✓ All data cleared successfully")
            return True
        except Error as e:
            print(f"✗ Error clearing data: {e}")
            return False

    # -------------------------
    # Close Connection
    # -------------------------
    def close(self):
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("Database connection closed")


# =========================
# Main Execution
# =========================
if __name__ == "__main__":
    # IMPORTANT: First create the tables by running cos10082_database.sql in MySQL Workbench
    inserter = UserInserter(
        host='localhost',
        port=3307,  
        database='medmanagedb',
        user='root',
        password='root'
    )

    if inserter.connect():
        # Initialize 5 hardcoded institutes
        inserter.initialize_institutes()
        
        # Generate doctors with patients (now using stored procedure)
        num_doctors = 20  
        patients_per_doctor = 10
        
        inserter.insert_doctors_with_patients(
            num_doctors=num_doctors,
            patients_per_doctor=patients_per_doctor
        )
        
        # Print statistics
        inserter.print_statistics()
        
        # Close connection
        inserter.close()