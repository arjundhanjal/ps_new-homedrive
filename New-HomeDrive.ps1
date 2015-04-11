<#
  New-HomeDrive.ps1
  Copyright (C) 2015  Arjun Dhanjal

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  Contact information available at ArjunDhanjal.com
#>

PARAM(
  [Parameter(Mandatory=$true)]
    [string]$AccountName
)

# Importing ActiveDirectory PS module

    Import-Module ActiveDirectory

# Assigning the drive letter and home drive for a user in Active Directory

    $HomeDrive='U:'
    $UserRoot='\\RAMPDC01.ramp.dhanjalserver.arjundhanjal.com\USERDATA$\'
    $HomeDirectory=$UserRoot+$AccountName

# Adding home drive information to Active Directory profile

    # Set-ADUser $AccountName -HomeDrive $HomeDrive -HomeDirectory $HomeDirectory

# Creating the folder on the root of the common USERDATA share

    New-Item -Path $HomeDirectory -Type Directory -Force
    $Domain='RAMP'
    $IdentityReference=$Domain+'\'+$AccountName

# Setting paramaters for access rule

    $FileSystemAccessRights=[System.Security.AccessControl.FileSystemRights]"FullControl"
    $InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags=[System.Security.AccessControl.PropagationFlags]"None"
    $AccessControl=[System.Security.AccessControl.AccessControlType]"Allow"

# Building access rule from parameters

    $AccessRule=New-Object System.Security.AccessControl.FileSystemAccessRule -argumentlist ($IdentityReference,$FileSystemAccessRights,$InheritanceFlags,$PropagationFlags,$AccessControl)

# Getting current access rule from home folder for user

    $HomeFolderACL=Get-ACL $HomeDirectory
    $HomeFolderACL.AddAccessRule($AccessRule)
    Set-ACL -Path $HomeDirectory -AclObject $HomeFolderACL

# Adding user to MAP-UserDrive group. This will invoke a GPO to map the user's home directory to U:\ upon login.

    $ADGroup = "MAP-UserDrive"
    Add-ADGroupMember -Identity $ADGroup -Member $AccountName
