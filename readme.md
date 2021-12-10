# Instructions

## Before you begin

in root/providers.tf
- set profile name to yours
- test with aws sts-get-caller-identity (in terminal)
- set region

create root/terraform.tfvars file 
- (has to be created newly because sensitive data is stored and shouldn't be uploaded to Github)
- add: <br/>
access_ip = "your_id_adress/32 or 0.0.0.0/0" <br/>

dbname     = "name" <br/>
dbuser     = "username" <br/>
dbpassword = "password" <br/>

docdb_master_username = "foo" <br/>
docdb_master_password = "mustbeeightchars" <br/>

create SSH Keys<br/>
- (if you change location (./webserver) also change public_key_path in root/main.tf) <br/>
- run in terminal: <br/>
ssh-keygen -t rsa  <br/>
refactor
-> prompt: ./webserver <br/>
-> prompt: enter <br/>
-> prompt: enter <br/>


Route 53: 
- if you have a domain name, you may change the hostes zone name to yours, but changes will take time 
- recommended for testing purposes not to use Route 53

# Terminal run: (inside root folder!)
- terraform init 
- terrafrom validate 
- terraform plan 
- terraform apply --auto-approve

### Define Variables 

...to be added



# Needs to be fixed 

- decide which version to use (for no breaks) (because yellow notifications show up, not set)
- Don't know why some security groups need an index because they are a tuple (in Hauptmodulen sollte das aber nicht mehr vorkommen)
- different SSH Keys for Webserver & Backendserver
- dependencies klären, wenn SG sich ändern mmuss LB/ASG sich auch automatisch ändern und erneueren

## Other informationen 

-
-




# Using Git (locally)

(git init)  <br/>
git add .   <br/>
git commit -m "Give describing message of changes" <br/>

git branch "new_branch" <br/>
git checkout "branch" <br/>
git merge "branch" <br/>
git push -u origin "branch" <br/>

# Pushing Code to Github

git remote add origin https://github.com/health-cloud-solutions/Terraform2.git <br>
git push -u origin master   


## Downloading Code in Terraform Folder
git clone https://github.com/health-cloud-solutions/Terraform2.git   

