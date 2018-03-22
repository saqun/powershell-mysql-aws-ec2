This script shows how to :
- create Powershell GUI with WPF
- access to database thru MySQL
- create AWS EC2 instances

You will need to create a config file name "ec2_inst_dup.cfg" where you run the script.
This file has to define the variables as follow:

# AWS EC2
HDW_SecurityGroupID = YOUR-SECURITY-GROUP-ID         
HDW_AccessKey       = YOUR-AWS-ACCESS-KEY
HDW_SecretKey       = YOUR-AWS-SECRET-KEY
HDW_KeyName         = YOUR-AWS-KEYNAME

# Email
HHDW_EmailFrom      = hardwireinfo@hardwire.co.nz
PSEmailServer       = YOUR-MAIL-SERVER

#Database-ware
MySQLHost          = MySQL-Host
MySQLAdminUserName = root
MySQLAdminPassword = 
MySQLDatabase      = MySQL-DB
MySQLTable         = MySQL-DB-TABLE
