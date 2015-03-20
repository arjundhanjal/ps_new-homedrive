# New-HomeDrive.ps1

This script is designed to create a new user folder on a common users share in a domain environment, set the appropriate access permissions, and then add the user to an Active Directory security group to ensure the folder is mapped to a network share through GPO.

This script is written to integrate with Active Directory, and thus will only work on domain networks. For this script to work properly, the user executing it must a) have access to read and query Active Directory, and b) have access to add and remove users from Active Directory security groups.

## The process

1. Importing the ActiveDirectory module

   First, the script imports PowerShell's **ActiveDirectory** module. For this to execute properly, the ActiveDirectory module must be [installed](https://technet.microsoft.com/en-us/magazine/gg413289.aspx) on the client computer.

2. Creating the user's folder on the common user share

   The script will first create a folder with username provided in `$UserRoot`.

3. Assigning permissions

   The script then assigns the proper permissions to the folder. It makes `$AccountName` the folder owner and sets permissions to deny unauthorized users access to the folder.

4. Mapping the drive

   Finally, the script will add `$AccountName` to `$ADGroup`, which allows for the potential to map the user's home drive to a network share upon login. This drive mapping functionality is not included in the script, though. For this part to work, the system administrator must first create a Group Policy Object (GPO) which maps `\\$HomeDirectory` to `%username%` for members of `$ADGroup`. 
