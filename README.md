# Elasticache Backup Script

This script automates the backup of Elasticache snapshots to an S3 bucket. It retrieves the latest automatic snapshot of each available Replication Group and Cluster in the specified AWS regions, and copies it to the S3 bucket.

## Getting Started

### Prerequisites

- AWS CLI installed
- AWS credentials with permission to access Elasticache and S3

### Installing

1. Clone or download this repository
2. Navigate to the directory containing the script
3. Make the script executable with the command: `chmod +x redis.sh`

### Usage

1. Open the script with a text editor
2. Replace the values of `S3_BUCKET_NAME` and `REGION` with your desired values
3. Run the script with the command: `./redis.sh`

### Output

- A log file is created at `/var/log/redis-backup/redis-backup.log`, which contains information about the backup process and any errors that occur.
- An error file is created at `/var/log/redis-backup/redis-backup.err`, which contains any error messages generated during the backup process.

## Authors

* **Allyson Medeiros** - *Initial work* - [Allyson](https://github.com/allyson2106)


