#!/bin/bash
# Note this script does modify your default EMR Roles to allow them to be managed by SSM and to connect using session manager 
aws emr create-default-roles

# Updates the built-in role (instance profile) to allow systems manager to manage EMR
# No SSH needed, now you can use systems manager
aws iam attach-role-policy --role-name EMR_EC2_DefaultRole --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# Enables SSM session manager
aws iam attach-role-policy --role-name EMR_EC2_DefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM

#create a bucket for logs, bootstrap, and output
echo Specify an S3 bucket for the logs,bootstrap, and output:
read bucketname

aws s3 mb s3://$bucketname

#specify your s3 logs URI
logs_uri=s3n://$bucketname/logs/

#Create bootstrap script that installs custom libraries on all EMR nodes. Needs at least 12GB EBS volume per node
echo "#!/bin/bash" > nltk_bootstrap.sh
echo "sudo yum install -y python-devel" >> nltk_bootstrap.sh
echo "sudo yum install -y python-pip" >> nltk_bootstrap.sh
echo "sudo pip install numpy nltk" >> nltk_bootstrap.sh
echo "sudo /usr/bin/python3 -m nltk.downloader -d /usr/share/nltk_data all " >> nltk_bootstrap.sh

aws s3 cp nltk_bootstrap.sh s3://$bucketname/bootstrap/nltk-bootstrap.sh

# if you want to use your own EMR role you can swap this one out
customprofile=EMR_EC2_DefaultRole

# Uses Latest Amazon Linux 2 as Base for AMI
ami=`aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[0].[Value]' --output text`

# Picks a subnet for EMR - Note, not all subnets support all instance types
snid=`aws ec2 describe-subnets --filters Name=default-for-az,Values=true --output=text --query 'Subnets[0].SubnetId'`

aws emr create-cluster \
 --name "Notebook Cluster" \
 --release-label emr-6.3.0 \
 --applications Name=Spark Name=Livy Name=JupyterEnterpriseGateway  \
 --instance-type m5.xlarge \
 --instance-count 3 \
 --custom-ami-id=$ami \
 --service-role EMR_DefaultRole \
 --bootstrap-actions '[{"Path":"s3://'$bucketname'/bootstrap/nltk-bootstrap.sh","Name":"Custom action"}]' \
 --ebs-root-volume-size 15  \
 --log-uri $logs_uri \
 --ec2-attributes '{"SubnetId":"'$snid'","InstanceProfile":"'$customprofile'"}'