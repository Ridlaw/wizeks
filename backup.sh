#! /bin/bash

##########################################################################################
#Mongodump Backups
##########################################################################################

# Make sure to:
# 1) Name this file `backup.sh` and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region)
# 4) Fill in DB host + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run chmod +x backup.sh
# 7) Test it out via ./backup.sh
# 8) Set up a daily backup at midnight via `crontab -e`:
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log

# HOST="localhost"

MONGODUMP_PATH="/usr/bin/mongodump"

MONGO_DATABASE="test"

MONGO_USER="ridwizUser"

MONGO_PASS="123Mongo"

S3_BUCKET_NAME="wizmongo12345"

S3_BUCKET_PATH="mongobackup"

TIME=`/bin/date --date='+5 hour 30 minutes' '+%d-%m-%Y-%I-%M-%S-%p'`

# Create backup

# $MONGODUMP_PATH -d $MONGO_DATABASE -h $HOST   #when no authentication set 

# $MONGODUMP_PATH -u $MONGO_USER -p $MONGO_PASS -d $MONGO_DATABASE --authenticationDatabase=admin     #use admin credentials

$MONGODUMP_PATH -u $MONGO_USER -p $MONGO_PASS -d $MONGO_DATABASE


mv dump mongodb-backup

tar cf mongodb-backup.tar mongodb-backup

# Upload to S3

aws s3 cp mongodb-backup.tar s3://$S3_BUCKET_NAME/$S3_BUCKET_PATH/mongodb-backup-$TIME.tar

#Delete local files

rm -rf mongodb-*

# All done
echo "Backup available at https://s3.amazonaws.com/$S3_BUCKET_NAME/$S3_BUCKET_PATH/mongodb-backup-$TIME"

##########################################################################################