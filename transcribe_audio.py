#!/usr/bin/env python3
"""
Audio transcription script using speech recognition.
Usage: python transcribe_audio.py <audio_file_path> <appointment_id>
"""

import sys
import os
import speech_recognition as sr
from pathlib import Path
import mysql.connector
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


def get_db_connection():
    """
    Establish and return a database connection.
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', ''),
            database=os.getenv('DB_NAME', 'medmanagedb')
        )
        return connection
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        sys.exit(1)


def update_appointment_details(appointment_id, transcription):
    """
    Update the appointment Details column with the transcription.
    
    Args:
        appointment_id: The appointment ID to update
        transcription: The transcribed text
    """
    connection = None
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        
        # Update the appointment Details
        query = "UPDATE Appointment SET Details = %s WHERE AppointmentID = %s"
        cursor.execute(query, (transcription, appointment_id))
        connection.commit()
        
        if cursor.rowcount > 0:
            print(f"\nSuccessfully updated Appointment ID {appointment_id} with transcription.")
        else:
            print(f"\nWarning: No appointment found with ID {appointment_id}.")
        
        cursor.close()
    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        sys.exit(1)
    finally:
        if connection and connection.is_connected():
            connection.close()


def transcribe_audio(audio_file_path):
    """
    Transcribe an audio file and return the transcription.
    
    Args:
        audio_file_path: Path to the audio file
    
    Returns:
        str: The transcribed text
    
    Raises:
        SystemExit: If transcription fails
    """
    # Check if file exists
    file_path = Path(audio_file_path)
    if not file_path.exists():
        print(f"Error: File '{audio_file_path}' not found.")
        sys.exit(1)
    
    # Check file extension
    supported_formats = ['.wav', '.flac', '.aiff', '.aif']
    if file_path.suffix.lower() not in supported_formats:
        print(f"Warning: File format '{file_path.suffix}' may not be supported.")
        print(f"Supported formats: {', '.join(supported_formats)}")
    
    # Initialize recognizer
    recognizer = sr.Recognizer()
    
    print(f"Transcribing: {audio_file_path}")
    print("Please wait...\n")
    
    try:
        # Load audio file
        with sr.AudioFile(audio_file_path) as source:
            # Adjust for ambient noise
            recognizer.adjust_for_ambient_noise(source, duration=0.5)
            
            # Record the audio data
            audio_data = recognizer.record(source)
        
        # Perform transcription using Google Speech Recognition
        print("Transcription:")
        print("-" * 50)
        text = recognizer.recognize_google(audio_data)
        print(text)
        print("-" * 50)
        
        return text
        
    except sr.UnknownValueError:
        print("Error: Could not understand the audio.")
        sys.exit(1)
    except sr.RequestError as e:
        print(f"Error: Could not request results from speech recognition service; {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


def main():
    """Main entry point for the script."""
    # Check arguments
    if len(sys.argv) != 3:
        print("Usage: python transcribe_audio.py <audio_file_path> <appointment_id>")
        print("\nExample:")
        print("  python transcribe_audio.py recording.wav 123")
        sys.exit(1)
    
    audio_file_path = sys.argv[1]
    appointment_id = sys.argv[2]
    
    # Validate appointment ID is a number
    try:
        appointment_id = int(appointment_id)
    except ValueError:
        print(f"Error: Appointment ID must be a valid integer, got '{sys.argv[2]}'")
        sys.exit(1)
    
    # Transcribe the audio file
    try:
        transcription = transcribe_audio(audio_file_path)
    except Exception as e:
        print(f"Transcription failed: {e}")
        sys.exit(1)
    
    # Update the database with the transcription
    update_appointment_details(appointment_id, transcription)


if __name__ == "__main__":
    main()
