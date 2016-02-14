Import-Module ServerManager
write-host "__________________________________________________________________________ "
write-host "################## ddd ####################################################\"
write-host "                   ddd                                       rapidadpwd  ##\"
write-host "                   ddd                                                   ##\"
write-host "   r rrrrr       d ddd                                                   ##\"
write-host "  rrrr  rrr    ddd ddd                              prccdc toolkit 2016  ##\"
write-host "  rrr   rrr   ddd  ddd                                  bofh@pencol.edu  ##\"
write-host "  rrr         dddd ddd                                                   ##\"
write-host "  rrr          ddddddd                                                   ##\"
write-host "  rrr "
write-host ""

$has_ad_ps = (Get-WindowsFeature RSAT-AD-Powershell).Installed

if ($1 -eq "--unsafe-changes") {
        $unsafe_changes = "True"
    }
    else {
        $unsafe_changes = "False"
    }

If ("$has_ad_ps" -eq "False") {
        write-warning "AD Powershell modules not present"
        write-warning "I will install them"
        write-host ""
        Add-WindowsFeature RSAT-AD-Powershell
    }
    else {
        write-host "AD Powershell modules is already installed, good!"
        write-host ""
    }

function change_pass ($u, $p) {
    $new_password = (ConvertTo-SecureString -String $p -AsPlainText -Force)
    Set-ADAccountPassword -Identity $u -Reset -NewPassword $new_password
    write-host "[!!] Changed password for user:     $u / $p   "
    write-host "Timestamp: $(Get-Date) "
    write-host ""
}


function get_password () {
    cls
    write-host "Querying the AD Password Policy for $((Get-ADDomain).forest) ..."
    write-host ""
    $complex_policy = (Get-ADDefaultDomainPasswordPolicy).ComplexityEnabled
    $length_policy = (Get-ADDefaultDomainPasswordPolicy).MinPasswordLength
        if ($complex_policy -eq "True") { write-warning "Password Complexity is:  REQUIRED,   \# One each of --> A-Z, a-z, 0-9, and special [!#%] \#" }
        if ($length_policy -ne "0") { write-warning "Minimum Password Length: $length_policy chars" }
    write-host ""
    $the_password = Read-Host "Enter a new password for all Active Directory accounts  "
    write-host ""
    $confirm_password = Read-Host "Please confirm the password  "
    write-host ""
    if ( "$the_password" -ne "$confirm_password" ) {
        write-warning " Sorry these passwords do not match "
        sleep 4
        get_password
        }
    else {
        write-warning " I will now change all of the passwds to: $the_password "
        write-host ""
    }
    return $the_password
}

Import-Module ActiveDirectory
sleep 3

$userlist_array = ((Get-ADUser -filter *).Name)
$bulk_password = get_password

ForEach ($AD_user in $userlist_array) {
    If ("$AD_user" -ne "krbtgt") {
        ## write-host using $AD_user and $bulk_password
        change_pass $AD_user $bulk_password
    }
    else {
        If ($unsafe_changes -ne "True") {
        write-Warning "[..] Not changing the password for the Kerberos service account: $((Get-ADDomain).forest)\$AD_user"
        write-Warning "Change it manually, or invoke this script with the '--unsafe-changes' option set"
        write-host ""
        }
          else {
            change_pass $AD_user $bulk_password
          }
    }
}

$bulk_password ="OverWriteWithNonsense"
Remove-Variable -Name bulk_password
write-host "[!!!] Finished "