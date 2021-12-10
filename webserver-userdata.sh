#!/bin/bash -ex
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Hello World from my AWSome Webserver hosted on EC2 from” > /var/www/html/index.html