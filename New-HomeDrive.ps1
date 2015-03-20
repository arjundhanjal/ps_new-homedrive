<#
  New-HomeDrive, v1
  Developed by Arjun Dhanjal
#>

PARAM(
  $Alias
)

$AccountName=$Alias

# Importing ActiveDirectory PS module

    Import-Module ActiveDirectory

# Assign the drive letter and home drive for a user in Active Directory

    $HomeDrive='U:'
    $UserRoot='\\RAMPDC01.ramp.dhanjalserver.arjundhanjal.com\USERDATA$\'
    $HomeDirectory=$UserRoot+$AccountName

# Add home drive information to Active Directory profile

    # Set-ADUser $Alias -HomeDrive $HomeDrive -HomeDirectory $HomeDirectory

# Create the folder on the root of the common USERDATA share

    New-Item -Path $HomeDirectory -Type Directory -Force
    $Domain='RAMP'
    $IdentityReference=$Domain+'\'+$AccountName

# Set paramaters for access rule

    $FileSystemAccessRights=[System.Security.AccessCOntrol.FileSystemRights]"FullControl"
    $InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags=[System.Security.AccessControl.PropagationFlags]"None"
    $AccessControl=[System.Security.AccessControl.AccessControlType]"Allow"

# Build access rule from parameters

    $AccessRule=New-Object System.Security.AccessControl.FileSystemAccessRule -argumentlist ($IdentityReference,$FileSystemAccessRights,$InheritanceFlags,$PropagationFlags,$AccessControl)

# Get current access rule from Home Folder for user

    $HomeFolderACL=Get-ACL $HomeDirectory
    $HomeFolderACL.AddAccessRule($AccessRule)
    Set-ACL -Path $HomeDirectory -AclObject $HomeFolderACL

# Add user to MAP-UserDrive group. This will invoke a GPO to map the user's home directory to U:\ upon login.

    $ADGroup = "MAP-UserDrive"
    Add-ADGroupMember -Identity $ADGroup -Member $AccountName
