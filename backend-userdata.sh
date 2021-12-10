#!/bin/bash -ex
yum update -y
sudo yum install -y amazon-efs-utils
sudo apt-get -y install nfs-common

# Mount EFS
sudo mount -t efs fs-068b51f13491d1df2 efs/
sudo mkdir efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-068b51f13491d1df2.efs.eu-west-2.amazonaws.com:/ efs
# findmnt (to see mounting points)
# to unmount "sudo umount efs"

# DocumentDB
wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
# Can't connect to document DB, since it wont find mongodb command and am unable to install mongo
