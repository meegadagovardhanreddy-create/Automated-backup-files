A. Project Overview

This project is a Linux shell script that creates backups of a directory.
The script:

Creates a compressed .tar.gz backup file
Names the backup using date and time
Generates a checksum file to verify data integrity
Automatically deletes old backups when the limit is reached
Supports dry run mode (to test without making changes)
Logs all actions for review
Why is this Useful?
It prevents data loss and also prevents the storage from being filled with old backups.

B. How to Use It
1. Installation
Clone the repository:

git clone https://github.com/A4671satya/Build-the-Automated-Backup-System.git
cd Build-the-Automated-Backup-System
Make script executable:

bash
Copy code
chmod +x backup.sh
2. Basic Usage
bash
Copy code
./backup.sh <source_directory>
Example:

bash
Copy code
./backup.sh ~/Documents
3. Dry Run Mode (No backups created, only logs)
bash
Copy code
./backup.sh --dry-run ~/Documents
4. Backup Rotation Limit
Set inside script (example: keep last 5 backups):

bash
Copy code
MAX_BACKUPS=5



C. How It Works

Backup Process
Create timestamp → backup-YYYY-MM-DD-HHMM.tar.gz

Create compressed archive of source folder

Generate checksum using:

bash
Copy code
sha256sum backupfile.tar.gz > backupfile.tar.gz.sha256
Verify checksum

Log success or error

Rotation Algorithm
Count how many backups exist

If count > MAX_BACKUPS
→ Remove oldest backup

Backup Folder Structure (Example)
bash
Copy code
~/backups/
  backup-2025-11-03-1120.tar.gz
  backup-2025-11-03-1120.tar.gz.sha256
  backup-2025-11-04-1130.tar.gz
  backup.log




D. Design Decisions
Decision	Reason
Bash script	Works on all Linux systems
tar + gzip compression	Saves space, fast
sha256 checksum	Detects corruption
Rotation system	Prevents disk storage overflow
Logging	Easier debugging and auditing

Challenges & Solutions
Challenge	Solution
Backups becoming too large	Used compression
Too many backups stored	Added rotation limit
Need to confirm backup integrity	Added checksum verify
Users running script accidentally	Added dry run mode




# E. Testing and Examples
1. Create Test Folder
bash
Copy code
mkdir -p ~/test_backup/src
echo "hello world" > ~/test_backup/src/file1.txt
echo "sample data" > ~/test_backup/src/file2.txt
2. Dry Run Test
bash
Copy code
./backup.sh --dry-run ~/test_backup/src
Expected Output:

lua
Copy code
DRY RUN: Would create backup backup-2025-11-03-1120.tar.gz
DRY RUN: Would create checksum backup-2025-11-03-1120.tar.gz.sha256
3. Real Backup
bash
Copy code
./backup.sh ~/test_backup/src
Check backup:

bash
Copy code
ls -lh ~/backups
4. Create Multiple Backups (simulate days)
Run multiple times:

bash
Copy code
./backup.sh ~/test_backup/src
./backup.sh ~/test_backup/src
./backup.sh ~/test_backup/src
If MAX_BACKUPS=3, you will see:

sql
Copy code
Old backup deleted: backup-2025-11-01-1040.tar.gz
5. Error Handling Example
Try backing up non-existing folder:

bash
Copy code
./backup.sh /no/such/folder
Expected:

makefile
Copy code
ERROR: Source directory does not exist
6. Verify Backup Integrity
bash
Copy code
sha256sum -c backup-*.sha256
7. Restore Backup (if needed)
bash
Copy code
tar -xzf backup-YYYY-MM-DD-HHMM.tar.gz -C /restore/location




F. Known Limitations
Limitation	Possible Improvement
Only local backups supported	Add upload to AWS S3 / Google Drive
No automatic scheduling	Use cron job
No email notification	Add status alert system
No GUI	Could build web dashboard

Summary
Feature	Status
Backup creation	
Checksum verification	
Backup rotation	
Logging system	
Dry run mode	
Error handling	

Developed by: Puppala Satya
College: KIET, JNTUK

yaml
Copy code

---

If you want, I can now also:

 Create a **PowerPoint (PPT)**  
 Create a **Demo Script** for your viva  
 Create **GitHub commit messages** and final structure  
