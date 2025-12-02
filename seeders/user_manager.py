try:
    import mysql.connector
    from mysql.connector import Error
except ModuleNotFoundError as e:
    raise SystemExit(
        "mysql.connector not found. Fix with:\n"
        "pip uninstall -y mysql mysql-connector\n"
        "pip install -U mysql-connector-python"
    )
import os
import json
import hashlib
import random
from turtle import title
from faker import Faker
from dotenv import load_dotenv
from datetime import datetime, timedelta

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
        
        # If user is a patient, use AddPatient stored procedure
        if user_type == 'patient':
            print(f"⚠ Warning: insert_single_user called for patient. Use insert_patient_with_procedure instead.")
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
    # Insert Patient Using Stored Procedure
    # -------------------------
    def insert_patient_with_procedure(self, username, email, first_name, last_name,
                                     phone, password, identification, gender, institute_id,
                                     abo_blood_type, rh_blood_type, emergency_contact, dob):
        """Insert a patient using the AddPatient stored procedure"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            
            # Call the stored procedure
            cursor.callproc('AddPatient', [
                username,
                email,
                first_name,
                last_name,
                phone,
                password,  # Plain password - procedure will hash it
                identification,
                gender,
                institute_id,
                abo_blood_type,
                rh_blood_type,
                emergency_contact,
                dob
            ])
            
            # Fetch the result
            for result in cursor.stored_results():
                row = result.fetchone()
                user_id = row[0] if row else None
            
            self.connection.commit()
            
            # Get the PatientDetailsID
            if user_id:
                cursor.execute("SELECT PatientDetailsID FROM patientdetails WHERE UserID = %s", (user_id,))
                result = cursor.fetchone()
                patient_details_id = result[0] if result else None
            else:
                patient_details_id = None
            
            cursor.close()
            
            #print(f"✓ Created Patient via Stored Procedure: {first_name} {last_name}")
            return user_id, patient_details_id
            
        except Error as e:
            print(f"✗ Error calling AddPatient procedure for '{username}': {e}")
            return False, False

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
            
            #print(f"✓ Created Doctor via Stored Procedure: {first_name} {last_name} ({specialist})")
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
    # Bulk Insert with Relations (OPTIMIZED)
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
        
        # Disable autocommit for better performance
        self.connection.autocommit = False
        
        try:
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
                    
                    # Batch create patients and links
                    patient_batch = []
                    for j in range(patients_per_doctor):
                        patient_first = fake.first_name()
                        patient_last = fake.last_name()
                        patient_username = f"{patient_first.lower()}_{patient_last.lower()}{random.randint(1,9999)}"
                        patient_email = f"{patient_username}@example.com"
                        patient_phone = f"+60{random.choice(['16','17','18','19'])}{random.randint(1000000,9999999)}"
                        patient_id = f"IC{random.randint(100000,699999)}"
                        patient_gender = random.choice(['M','F'])
                        
                        blood_abo = random.choice(['A', 'B', 'AB', 'O'])
                        blood_rh = random.choice(['+', '-'])
                        emergency = f"+60{random.choice(['11','12','13','16','17'])}{random.randint(1000000,9999999)}"
                        dob = fake.date_of_birth(minimum_age=18, maximum_age=85)
                        
                        patient_batch.append({
                            'username': patient_username,
                            'email': patient_email,
                            'first_name': patient_first,
                            'last_name': patient_last,
                            'phone': patient_phone,
                            'identification': patient_id,
                            'gender': patient_gender,
                            'institute_id': institute_id,
                            'abo_blood_type': blood_abo,
                            'rh_blood_type': blood_rh,
                            'emergency_contact': emergency,
                            'dob': dob
                        })
                    
                    # Process patient batch
                    for patient_data in patient_batch:
                        patient_user_id, patient_details_id = self.insert_patient_with_procedure(**patient_data, password='patient123')
                        
                        if patient_user_id and patient_details_id:
                            self.link_doctor_patient(patient_details_id, doctor_details_id, True)
                            success_patients += 1
                    
                    # Commit every 5 doctors (batch commit)
                    if (i + 1) % 5 == 0:
                        self.connection.commit()
                        print(f"Progress: {i + 1}/{num_doctors} doctors processed")
            
            # Final commit
            self.connection.commit()
            
        finally:
            # Re-enable autocommit
            self.connection.autocommit = True
        
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
    # Insert Medicine
    # -------------------------
    def insert_medicine(self, name, brand, description):
        """Insert a medicine using the AddMedicine stored procedure"""
        if not self.connection or not self.connection.is_connected():
            print("No database connection")
            return False
        try:
            cursor = self.connection.cursor()
            
            # Call the stored procedure
            cursor.callproc('AddMedicine', [name, brand, description])
            
            # Fetch the result (LAST_INSERT_ID)
            for result in cursor.stored_results():
                row = result.fetchone()
                medicine_id = row[0] if row else None
            
            self.connection.commit()
            cursor.close()
            return medicine_id
        except Error as e:
            print(f"✗ Error inserting medicine '{name}': {e}")
            return False

    def initialize_medicines(self):
        """Insert common medicines into the database"""
        if not self.connection or not self.connection.is_connected():
            return False
        
        cursor = self.connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM medicine")
        count = cursor.fetchone()[0]
        cursor.close()
        
        if count > 0:
            print("✓ Medicines already exist in database")
            return True
        
        medicines = [
            ('Paracetamol', 'Panadol', 'Pain reliever and fever reducer'),
            ('Ibuprofen', 'Advil', 'Anti-inflammatory and pain reliever'),
            ('Amoxicillin', 'Amoxil', 'Antibiotic for bacterial infections'),
            ('Metformin', 'Glucophage', 'Diabetes medication'),
            ('Lisinopril', 'Prinivil', 'Blood pressure medication'),
            ('Amlodipine', 'Norvasc', 'Calcium channel blocker for hypertension'),
            ('Simvastatin', 'Zocor', 'Cholesterol-lowering medication'),
            ('Omeprazole', 'Prilosec', 'Proton pump inhibitor for acid reflux'),
            ('Levothyroxine', 'Synthroid', 'Thyroid hormone replacement'),
            ('Albuterol', 'Ventolin', 'Bronchodilator for asthma'),
            ('Aspirin', 'Bayer', 'Blood thinner and pain reliever'),
            ('Atorvastatin', 'Lipitor', 'Statin for cholesterol management'),
            ('Losartan', 'Cozaar', 'Angiotensin receptor blocker'),
            ('Cetirizine', 'Zyrtec', 'Antihistamine for allergies'),
            ('Ranitidine', 'Zantac', 'H2 blocker for heartburn')
        ]
        
        for med in medicines:
            self.insert_medicine(*med)
        
        print(f"✓ Successfully inserted {len(medicines)} medicines")
        return True

    # -------------------------
    # Insert Disease
    # -------------------------
    def insert_disease(self, name, description):
        """Insert a disease into the database"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            query = "INSERT INTO disease (Name, Description) VALUES (%s, %s)"
            cursor.execute(query, (name, description))
            self.connection.commit()
            disease_id = cursor.lastrowid
            cursor.close()
            return disease_id
        except Error as e:
            print(f"✗ Error inserting disease '{name}': {e}")
            return False

    def initialize_diseases(self):
        """Insert common diseases into the database"""
        if not self.connection or not self.connection.is_connected():
            return False
        
        cursor = self.connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM disease")
        count = cursor.fetchone()[0]
        cursor.close()
        
        if count > 0:
            print("✓ Diseases already exist in database")
            return True
        
        diseases = [
            ('Hypertension', 'High blood pressure condition'),
            ('Type 2 Diabetes', 'Metabolic disorder affecting blood sugar'),
            ('Asthma', 'Chronic respiratory condition'),
            ('Coronary Artery Disease', 'Heart disease due to plaque buildup'),
            ('Hyperlipidemia', 'High cholesterol levels'),
            ('GERD', 'Gastroesophageal reflux disease'),
            ('Hypothyroidism', 'Underactive thyroid gland'),
            ('Osteoarthritis', 'Degenerative joint disease'),
            ('Depression', 'Mental health disorder'),
            ('Anxiety Disorder', 'Excessive worry and fear')
        ]
        
        for disease in diseases:
            self.insert_disease(*disease)
        
        print(f"✓ Successfully inserted {len(diseases)} diseases")
        return True

    # -------------------------
    # Insert Side Effect
    # -------------------------
    def insert_side_effect(self, name, description):
        """Insert a side effect into the database"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            query = "INSERT INTO sideeffect (Name, Description) VALUES (%s, %s)"
            cursor.execute(query, (name, description))
            self.connection.commit()
            side_effect_id = cursor.lastrowid
            cursor.close()
            return side_effect_id
        except Error as e:
            print(f"✗ Error inserting side effect '{name}': {e}")
            return False

    def initialize_side_effects(self):
        """Insert common side effects"""
        if not self.connection or not self.connection.is_connected():
            return False
        
        cursor = self.connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM sideeffect")
        count = cursor.fetchone()[0]
        cursor.close()
        
        if count > 0:
            print("✓ Side effects already exist in database")
            return True
        
        side_effects = [
            ('Nausea', 'Feeling of sickness with urge to vomit'),
            ('Dizziness', 'Feeling of lightheadedness or unsteadiness'),
            ('Headache', 'Pain in the head region'),
            ('Drowsiness', 'Feeling of sleepiness'),
            ('Dry mouth', 'Reduced saliva production'),
            ('Constipation', 'Difficulty in bowel movements'),
            ('Diarrhea', 'Loose or watery stools'),
            ('Fatigue', 'Extreme tiredness'),
            ('Insomnia', 'Difficulty sleeping'),
            ('Rash', 'Skin irritation or eruption')
        ]
        
        for effect in side_effects:
            self.insert_side_effect(*effect)
        
        print(f"✓ Successfully inserted {len(side_effects)} side effects")
        return True

    # -------------------------
    # Insert Symptom
    # -------------------------
    def insert_symptom(self, name, description):
        """Insert a symptom into the database"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            query = "INSERT INTO symptom (Name, Description) VALUES (%s, %s)"
            cursor.execute(query, (name, description))
            self.connection.commit()
            symptom_id = cursor.lastrowid
            cursor.close()
            return symptom_id
        except Error as e:
            print(f"✗ Error inserting symptom '{name}': {e}")
            return False

    def initialize_symptoms(self):
        """Insert common symptoms"""
        if not self.connection or not self.connection.is_connected():
            return False
        
        cursor = self.connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM symptom")
        count = cursor.fetchone()[0]
        cursor.close()
        
        if count > 0:
            print("✓ Symptoms already exist in database")
            return True
        
        symptoms = [
            ('Fever', 'Elevated body temperature'),
            ('Cough', 'Sudden expulsion of air from lungs'),
            ('Chest Pain', 'Discomfort in chest area'),
            ('Shortness of Breath', 'Difficulty breathing'),
            ('Fatigue', 'Extreme tiredness'),
            ('Joint Pain', 'Pain in joints'),
            ('Abdominal Pain', 'Pain in stomach area'),
            ('Headache', 'Pain in head'),
            ('Dizziness', 'Feeling unsteady'),
            ('Nausea', 'Feeling sick')
        ]
        
        for symptom in symptoms:
            self.insert_symptom(*symptom)
        
        print(f"✓ Successfully inserted {len(symptoms)} symptoms")
        return True

    # -------------------------
    # Link Disease to Patient (OPTIMIZED)
    # -------------------------
    def link_disease_to_patient(self, patient_details_id, disease_id, onset_days_ago=30):
        """Link a disease to a patient"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            onset = datetime.now() - timedelta(days=onset_days_ago)
            query = """
            INSERT IGNORE INTO disease_patientdetails (DiseaseID, PatientDetailsID, Onset)
            VALUES (%s, %s, %s)
            """
            cursor.execute(query, (disease_id, patient_details_id, onset))
            cursor.close()
            return True
        except Error as e:
            print(f"✗ Error linking disease to patient: {e}")
            return False

    # -------------------------
    # Link Symptom to Patient (OPTIMIZED)
    # -------------------------
    def link_symptom_to_patient(self, patient_details_id, symptom_id, onset_days_ago=7):
        """Link a symptom to a patient"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            onset = datetime.now() - timedelta(days=onset_days_ago)
            query = """
            INSERT IGNORE INTO symptom_patientdetails (SymptomID, PatientDetailsID, Onset)
            VALUES (%s, %s, %s)
            """
            cursor.execute(query, (symptom_id, patient_details_id, onset))
            cursor.close()
            return True
        except Error as e:
            print(f"✗ Error linking symptom to patient: {e}")
            return False

    # -------------------------
    # Create Prescription
    # -------------------------
    def create_prescription(self, patient_user_id, doctor_user_id, medicine_id, total_dose, remark):
        """Create a prescription"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            
            # Generate random date between 2015-2025
            start_date = datetime(2015, 1, 1)
            end_date = datetime(2025, 12, 31)
            time_between = end_date - start_date
            days_between = time_between.days
            random_days = random.randrange(days_between)
            prescribed_on = start_date + timedelta(days=random_days)
            
            query = """
            INSERT INTO prescription (PatientUserID, DoctorUserID, MedicineID, TotalDose, Remark, PrescribedOn)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query, (patient_user_id, doctor_user_id, medicine_id, total_dose, remark, prescribed_on))
            self.connection.commit()
            prescription_id = cursor.lastrowid
            cursor.close()
            return prescription_id, prescribed_on  # Return both ID and date
        except Error as e:
            print(f"✗ Error creating prescription: {e}")
            return False, None

    # -------------------------
    # Create Prescription Detail
    # -------------------------
    def create_prescription_detail(self, prescription_id, dose, interval_minutes, remark, days_duration=7, prescribed_on=None):
        """Create prescription detail (trigger will automatically create reminder)"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            
            # Use prescribed_on if provided, otherwise use current date
            if prescribed_on:
                start_on = prescribed_on
            else:
                start_on = datetime.now()
            
            end_on = start_on + timedelta(days=days_duration)
            
            query = """
            INSERT INTO prescriptiondetail 
            (PrescriptionID, IsTakeOnEffect, StartOn, EndOn, Dose, IntervalMinutes, Remark)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query, (prescription_id, 0, start_on, end_on, dose, interval_minutes, remark))
            self.connection.commit()
            detail_id = cursor.lastrowid
            cursor.close()
            return detail_id
        except Error as e:
            print(f"✗ Error creating prescription detail: {e}")
            return False

    # -------------------------
    # Create Appointment
    # -------------------------
    def create_appointment(self, patient_user_id, doctor_user_id, days_ahead=7, details="Regular checkup"):
        """Create an appointment"""
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            appointment_time = datetime.now() + timedelta(days=days_ahead)
            query = """
            INSERT INTO appointment 
            (PatientUserID, DoctorUserID, AppointmentOn, Details, IsDoctorAccept, IsPatientAccept)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            is_accepted = random.choice([0, 1])
            cursor.execute(query, (patient_user_id, doctor_user_id, appointment_time, 
                                 details, is_accepted, is_accepted))
            self.connection.commit()
            appointment_id = cursor.lastrowid
            cursor.close()
            return appointment_id
        except Error as e:
            print(f"✗ Error creating appointment: {e}")
            return False

    # -------------------------
    # Create Reminder for Prescription (DEPRECATED - Now handled by trigger)
    # -------------------------
    def create_reminder_for_prescription(self, prescription_detail_id, interval_minutes):
        """Create reminder for prescription detail
        NOTE: This is now deprecated as reminders are created automatically by trigger
        Kept for backward compatibility only
        """
        if not self.connection or not self.connection.is_connected():
            return False
        try:
            cursor = self.connection.cursor()
            start_on = datetime.now()
            end_on = start_on + timedelta(days=7)
            query = """
            INSERT INTO reminder 
            (StartOn, EndOn, IntervalMinutes, PrescriptionDetailID)
            VALUES (%s, %s, %s, %s)
            """
            cursor.execute(query, (start_on, end_on, interval_minutes, prescription_detail_id))
            self.connection.commit()
            reminder_id = cursor.lastrowid
            cursor.close()
            return reminder_id
        except Error as e:
            print(f"✗ Error creating reminder: {e}")
            return False

    def close(self):
        """Close database connection"""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("Database connection closed")

    # -------------------------
    # Populate All Data (OPTIMIZED)
    # -------------------------
    def populate_all_data(self, num_doctors=10, patients_per_doctor=20):
        """Populate all tables with related data"""
        fake = Faker()
        
        print("\n" + "="*60)
        print("STARTING COMPLETE DATABASE POPULATION")
        print("="*60)
        
        # Initialize base data
        print("\n[1/8] Initializing institutes...")
        self.initialize_institutes()
        
        print("\n[2/8] Initializing medicines...")
        self.initialize_medicines()
        
        print("\n[3/8] Initializing diseases...")
        self.initialize_diseases()
        
        print("\n[4/8] Initializing side effects...")
        self.initialize_side_effects()
        
        print("\n[5/8] Initializing symptoms...")
        self.initialize_symptoms()
        
        # Get IDs for reference
        cursor = self.connection.cursor()
        cursor.execute("SELECT MedicineId FROM medicine")
        medicine_ids = [row[0] for row in cursor.fetchall()]
        
        cursor.execute("SELECT DiseaseID FROM disease")
        disease_ids = [row[0] for row in cursor.fetchall()]
        
        cursor.execute("SELECT SymptomID FROM symptom")
        symptom_ids = [row[0] for row in cursor.fetchall()]
        cursor.close()
        
        print(f"\n[6/8] Creating {num_doctors} doctors with {patients_per_doctor} patients each...")
        self.insert_doctors_with_patients(num_doctors, patients_per_doctor)
        
        # Get all patients and doctors in one query
        cursor = self.connection.cursor()
        cursor.execute("""
            SELECT pd.PatientDetailsID, pd.UserID, dd.UserID as DoctorUserID
            FROM patientdetails pd
            JOIN doctor_patient dp ON pd.PatientDetailsID = dp.PatientDetailsID
            JOIN doctordetails dd ON dp.DoctorDetailsID = dd.DoctorDetailsID
            WHERE dp.IsPrimaryDoctor = 1
        """)
        patients_with_doctors = cursor.fetchall()
        cursor.close()
        
        print(f"\n[7/8] Adding diseases, symptoms, prescriptions to {len(patients_with_doctors)} patients...")
        
        # Disable autocommit for bulk operations
        self.connection.autocommit = False
        
        prescription_count = 0
        appointment_count = 0
        disease_count = 0
        symptom_count = 0
        
        try:
            cursor = self.connection.cursor()
            
            # Prepare bulk insert statements
            disease_links = []
            symptom_links = []
            
            for idx, (patient_details_id, patient_user_id, doctor_user_id) in enumerate(patients_with_doctors):
                # Collect disease links
                num_diseases = random.randint(1, 3)
                for disease_id in random.sample(disease_ids, min(num_diseases, len(disease_ids))):
                    onset = datetime.now() - timedelta(days=random.randint(30, 365))
                    disease_links.append((disease_id, patient_details_id, onset))
                
                # Collect symptom links
                num_symptoms = random.randint(1, 5)
                for symptom_id in random.sample(symptom_ids, min(num_symptoms, len(symptom_ids))):
                    onset = datetime.now() - timedelta(days=random.randint(1, 30))
                    symptom_links.append((symptom_id, patient_details_id, onset))
                
                # Create prescriptions
                num_prescriptions = random.randint(1, 3)
                for _ in range(num_prescriptions):
                    medicine_id = random.choice(medicine_ids)
                    total_dose = f"{random.randint(7, 30)} tablets"
                    remark = random.choice(["Take after meals", "Take before bedtime", "Take with water", "Complete full course"])
                    
                    prescription_result = self.create_prescription(patient_user_id, doctor_user_id, medicine_id, total_dose, remark)
                    
                    # Handle both old (single value) and new (tuple) return formats
                    if isinstance(prescription_result, tuple):
                        prescription_id, prescribed_on = prescription_result
                    else:
                        prescription_id = prescription_result
                        prescribed_on = None
                    
                    if prescription_id:
                        dose = f"{random.choice(['1', '2'])} tablet(s)"
                        interval = random.choice([480, 720, 1440])
                        detail_id = self.create_prescription_detail(
                            prescription_id, dose, interval, "As prescribed", 
                            days_duration=random.randint(7, 30),
                            prescribed_on=prescribed_on  # Pass the prescription date
                        )
                        
                        if detail_id:
                            # Reminder is now created automatically by trigger
                            # self.create_reminder_for_prescription(detail_id, interval)
                            prescription_count += 1
                
                # Create appointments
                num_appointments = random.randint(0, 2)
                for _ in range(num_appointments):
                    details = random.choice(["Regular checkup", "Follow-up consultation", "Lab results review", "Medication review"])
                    if self.create_appointment(patient_user_id, doctor_user_id, days_ahead=random.randint(1, 60), details=details):
                        appointment_count += 1
                
                # Commit every 50 patients
                if (idx + 1) % 50 == 0:
                    # Bulk insert disease links
                    if disease_links:
                        cursor.executemany("""
                            INSERT IGNORE INTO disease_patientdetails (DiseaseID, PatientDetailsID, Onset)
                            VALUES (%s, %s, %s)
                        """, disease_links)
                        disease_count += len(disease_links)
                        disease_links = []
                    
                    # Bulk insert symptom links
                    if symptom_links:
                        cursor.executemany("""
                            INSERT IGNORE INTO symptom_patientdetails (SymptomID, PatientDetailsID, Onset)
                            VALUES (%s, %s, %s)
                        """, symptom_links)
                        symptom_count += len(symptom_links)
                        symptom_links = []
                    
                    self.connection.commit()
                    print(f"Progress: {idx + 1}/{len(patients_with_doctors)} patients processed")
            
            # Final bulk inserts
            if disease_links:
                cursor.executemany("""
                    INSERT IGNORE INTO disease_patientdetails (DiseaseID, PatientDetailsID, Onset)
                    VALUES (%s, %s, %s)
                """, disease_links)
                disease_count += len(disease_links)
            
            if symptom_links:
                cursor.executemany("""
                    INSERT IGNORE INTO symptom_patientdetails (SymptomID, PatientDetailsID, Onset)
                    VALUES (%s, %s, %s)
                """, symptom_links)
                symptom_count += len(symptom_links)
            
            self.connection.commit()
            cursor.close()
            
        finally:
            # Re-enable autocommit
            self.connection.autocommit = True
        
        print(f"✓ Linked {disease_count} diseases to patients")
        print(f"✓ Linked {symptom_count} symptoms to patients")
        print(f"✓ Created {prescription_count} prescriptions")
        print(f"✓ Created {appointment_count} appointments")
        
        print("\n[8/8] Generating final statistics...")
        self.print_statistics()
        
        print("\n" + "="*60)
        print("DATABASE POPULATION COMPLETE!")
        print("="*60)

# =========================
# Main Execution
# =========================
if __name__ == "__main__":
    # IMPORTANT: First create the tables by running cos10082_database.sql in MySQL Workbench
    load_dotenv()  # Load environment variables from .env file if present
    inserter = UserInserter(
        host= os.getenv('hostname', 'localhost'),
        port= os.getenv('port', 3307),
        database= os.getenv('database', 'medmanagedb'),
        user= os.getenv('user', 'root'),
        password= os.getenv('password', 'root')
    )

    if inserter.connect():
        # Populate all tables with comprehensive data
        inserter.populate_all_data(
            num_doctors=10,
            patients_per_doctor=20
        )
        
        # Close connection
        inserter.close()