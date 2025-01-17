#!/bin/bash
#------------------------------------------------------------------------------
# written by: lawrence mcdaniel
#             https://lawrencemcdaniel.com
#             https://blog.lawrencemcdaniel.com
#
# date:       sep-2022
#
# usage:      backup Open edX MySQL databases.
#             This is designed to run as a cron job but it also will run from the command line.
#             - dump mysql databases
#             - combine into a single tarball
#             - store in "backups" folder in user directory
#             - upload to an AWS S3 bucket
#             - manage local backup retention policy
#             - generate a log report and store in the home folder
#
# reference:  https://github.com/edx/edx-documentation/blob/master/en_us/install_operations/source/platform_releases/ginkgo.rst
#------------------------------------------------------------------------------

# ensure that cron can find our aws cli configuration
PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/ubuntu/scripts:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
AWS_CONFIG_FILE=/home/ubuntu/.aws/config
AWS_REGION=us-east-1

# do not change these
BASE_BACKUPS_DIRECTORY="/home/ubuntu/backups/"
BACKUPS_DIRECTORY="${BASE_BACKUPS_DIRECTORY}/mysql/"
WORKING_DIRECTORY="/home/ubuntu/backup-tmp/"
OUTPUT_FILE_MASTER="/home/ubuntu/openedx-backup-mysql.out"

# AWS S3 Bucket for remote storage
S3_BUCKET="prod-usa-prod-backup"
NUMBER_OF_BACKUPS_TO_RETAIN="30"      # Note: this only regards local storage (ie on the ubuntu server).
                                      # All backups are retained in the S3 bucket forever.
                                      # BE AWARE: AWS S3 monthly costs will grow unbounded.
                                      # You need to monitor the size of the S3 bucket and prune
                                      # old backups as you deem appropriate.
NOW="$(date +%Y%m%dT%H%M%S)"
OUTPUT_FILE="${OUTPUT_FILE_MASTER}-${NOW}.out"

if [ ! -f ${OUTPUT_FILE} ]; then
    touch ${OUTPUT_FILE}
    chmod 644 ${OUTPUT_FILE}
    chown ubuntu ${OUTPUT_FILE}
    chgrp ubuntu ${OUTPUT_FILE}
    echo "created output file ${OUTPUT_FILE}"
fi

echo "-------------------------------------------------------------------------------" >> $OUTPUT_FILE
echo "${NOW}" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE


#------------------------------------------------------------------------------
# retrieve the mysql root credentials from k8s secrets. Sets the following environment variables:
#
#    MYSQL_HOST=mysql.service.devdatalabs.com
#    MYSQL_PORT=3306
#    MYSQL_ROOT_PASSWORD=******
#    MYSQL_ROOT_USERNAME=root
#
#------------------------------------------------------------------------------
$(ksecret.sh mysql-root prod-usa-service)

#Check to see if a working folder exists. if not, create it.
if [ ! -d ${WORKING_DIRECTORY} ]; then
    mkdir ${WORKING_DIRECTORY}
    echo "created backup working folder ${WORKING_DIRECTORY}" >> $OUTPUT_FILE
fi

#Check to see if anything is currently in the working folder. if so, delete it all.
if [ -f "$WORKING_DIRECTORY/*" ]; then
  sudo rm -r "$WORKING_DIRECTORY/*"
fi

#Check to see if a base backups/ folder exists. if not, create it.
if [ ! -d ${BASE_BACKUPS_DIRECTORY} ]; then
    mkdir ${BASE_BACKUPS_DIRECTORY}
    echo "created backups folder ${BASE_BACKUPS_DIRECTORY}" >> $OUTPUT_FILE
fi

#Check to see if a backups/ folder exists. if not, create it.
if [ ! -d ${BACKUPS_DIRECTORY} ]; then
    mkdir ${BACKUPS_DIRECTORY}
    echo "created backups folder ${BACKUPS_DIRECTORY}" >> $OUTPUT_FILE
fi


cd ${WORKING_DIRECTORY}

# Begin Backup MySQL databases
#------------------------------------------------------------------------------------------------------------------------
echo "Backing up MySQL databases" >> $OUTPUT_FILE
echo "Reading MySQL database names..." >> $OUTPUT_FILE
mysql -h ${MYSQL_HOST} -u ${MYSQL_ROOT_USERNAME} -p"$MYSQL_ROOT_PASSWORD" -ANe "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('innodb', 'tmp', 'mysql','sys','information_schema','performance_schema')" > /tmp/db.txt
DBS="--databases $(cat /tmp/db.txt)"
SQL_FILE="mysql-data-${NOW}.sql"
echo "Dumping MySQL structures..." >> $OUTPUT_FILE
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h ${MYSQL_HOST} -u ${MYSQL_ROOT_USERNAME} -p"$MYSQL_ROOT_PASSWORD" --add-drop-database ${DBS} > ${SQL_FILE}
echo "Done backing up MySQL" >> $OUTPUT_FILE

#Tarball our mysql backup file
echo "Compressing MySQL backup into a single tarball archive" >> $OUTPUT_FILE
tar -czf ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz ${SQL_FILE}

# ensure that ubuntu owns these files, regardless of who runs this script
sudo chown ubuntu ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz
sudo chgrp ubuntu ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz
echo "Created tarball of backup data openedx-mysql-${NOW}.tgz" >> $OUTPUT_FILE
# End Backup MySQL databases
#------------------------------------------------------------------------------------------------------------------------

#Prune the Backups/ folder by eliminating all but the 30 most recent tarball files
echo "Pruning the local backup folder archive" >> $OUTPUT_FILE
if [ -d ${BACKUPS_DIRECTORY} ]; then
  cd ${BACKUPS_DIRECTORY}
  ls -1tr | head -n -${NUMBER_OF_BACKUPS_TO_RETAIN} | xargs -d '\n' rm -f --
fi

#Remove the working folder
echo "Cleaning up" >> $OUTPUT_FILE
sudo rm -r ${WORKING_DIRECTORY}

echo "Sync backup to AWS S3 backup folder" >> $OUTPUT_FILE
aws s3 sync ${BASE_BACKUPS_DIRECTORY} s3://${S3_BUCKET}/backups
echo "Done!" >> $OUTPUT_FILE
echo "-------------------------------------------------------------------------------" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

cat $OUTPUT_FILE
cat $OUTPUT_FILE >> $OUTPUT_FILE_MASTER
rm $OUTPUT_FILE
