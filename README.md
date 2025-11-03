Automatic Backup System.

Project Overreview.

These project is "Automated Backup System ("smart backup automation tool") these is written in the bash.

1) It automatically creates compressed backups, verifies their integrity, and deletes old backups to save space.

Features.

1) Create timestamped backups like Day , Date, Month, Year.

2) Verify backups using SHA256 checksums
 
3) Automatically delete old backups (rotation policy) 

4) Keep backups configurable via `backup.config`
 
5) Logging of all activities in `backup.log`
 
6) Dry-run mode to simulate without changing anything
 
7) Prevents multiple runs with a lock file
 
8) Can be automated with `cron`


ConfigFile.(backup.confing).

These file is like a setting file for these project.

It tells about our scrpit like what we need to give the commands for our backup files.
If we need to delete anything like backup files we need to change the script in the config file.
Or if we need to timestamp,date, time,month,year these things are setteled in the config file.
In these config file we can put how many backup files we need or how many we nedd to delete we can write a a script here.

#like

# ===== Backup System Configuration =====

# Destination folder where all backups will be stored
BACKUP_DESTINATION=/home/dmin/backup-system/backups

# Folders or files you want to skip during backup
EXCLUDE_PATTERNS=".git,node_modules,.cache"

# How many backups you want to keep
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3

# Optional: (for future feature) Email notifications
NOTIFY_EMAIL=dmin@example.com

# ===== End of Configuration =====

#How It Works.

Takes a folder path as input

Creates a .tar.gz archive with the current date and time

Generates a .sha256 checksum file

Verifies backup integrity

Automatically deletes old backups based on configured retention rules

Logs all actions in backup.log

#Backup Rotation (Automatic Cleanup).

The last 7 daily backups

The last 4 weekly backups

The last 3 monthly backups

#Author.

Name: Govardhanreddy Meegada
Date: November 2025
Project Type: Linux Bash Scripting / Automation.
