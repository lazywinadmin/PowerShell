function Update-O365UserUPNSuffix
{
<#
    .SYNOPSIS
        Function to correct the UPN of a user in Office365 (O365) and Active Directory (AD)

    .DESCRIPTION
        Function to correct the UPN of a user in Office365 (O365) and Active Directory (AD).
        Once modified you might want to force the sync between AD and O365 to make sure the object
        are correctly synced.

        This function is used to correct user accounts mismatch or most likely used
        in environment where User conversion from Contractor to Permanent requires
        a change of UPN. Example: test.user@ContosoConsultant.com to test.user@Contoso.com

        For the Office 365 UPN, This script will be first changed to the
        <Tenant>.onmicrosoft.com UPN, then change to the new UPN specified by the user.
        This is needed to avoid some issues I encountered in the past.

    .PARAMETER UserAlias
        Specifies the User Alias, typically what is in front of the '@' of the current
        UPN. Example Bob.Marley

    .PARAMETER CurrentUPNSuffix
        Specifies the current UPN Suffix. Default is 'ContosoConsultant.com'

    .PARAMETER NewUPNSuffix
        Specifies the new UPN suffix to apply. Default is 'Contoso.com'

    .PARAMETER TenantUPNSuffix
        Specifies the Tenant UPN Suffix. Default is 'contoso.onmicrosoft.com'

    .PARAMETER DomainController
        Specifies the Domain Controller on which the Active Directory modification will
        occur.

    .PARAMETER Credential
        Specifies the credential to use for ActiveDirectory changes

    .EXAMPLE
        Update-O365UserUPNSuffix `
        -Verbose `
        -Credential $cred `
        -UserAlias 'perm.test' `
        -CurrentUPNSuffix 'ContosoConsultant.com' `
        -NewUPNSuffix 'Contoso.com' `
        -TenantUPNSuffix 'Contoso.onmicrosoft.com' `
        -DomainController 'DC01.Contoso.com'

    .NOTES
        Francois-Xavier Cat
        www.lazywinadmin.com
        @lazywinadm
        github.com/lazywinadmin
#>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$UserAlias,

        [Parameter(Mandatory = $true)]
        [String]$CurrentUPNSuffix,

        [Parameter(Mandatory = $true)]
        [String]$NewUPNSuffix,

        [Parameter(Mandatory = $true)]
        [String]$TenantUPNSuffix,

        [Parameter(Mandatory = $true)]
        [String]$DomainController,

        [System.Management.Automation.Credential()]
        [Alias('RunAs')]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        TRY
        {
            $CurrentUPN = $("$UserAlias@$CurrentUPNSuffix")
            $TemporaryUPN = $("$UserAlias@$TenantUPNSuffix")
            $NewUPN = $("$UserAlias@$NewUPNSuffix")

            # Exchange Online - Validate we find the user
            Write-Verbose -Message "[BEGIN] Current Information"
            if (Get-MsolDomain)
            {
                $MSOLUserBefore = Get-MsolUser -UserPrincipalName $CurrentUPN -ErrorAction Stop
            }
            else
            {
                Write-Error "[BEGIN] Does not seem connected to Office365"
                break
            }

            # Active Directory - Validate we find the user
            $ADUserBefore = (Get-ADuser -LDAPFilter "(UserPrincipalName=$CurrentUPN)" -Server $DomainController -ErrorAction Stop)

            if (-not ($ADUserBefore))
            { Write-Error -Message "[BEGIN] Can't find this user in AD" }

            [pscustomobject]@{
                State = 'BEFORE'
                UserAlias = $UserAlias
                SID = $ADUserBefore.SID
                UPN_in_AD = $ADUserBefore.UserPrincipalName
                UPN_in_O365 = $MSOLUserBefore.UserPrincipalName
            }
        }
        CATCH
        {
            $Error[0].Exception.Message
        }
    }
    PROCESS
    {
        TRY
        {
            Write-Verbose -Message "[PROCESS] Processing changes"
            $Splatting = @{ }

            if ($PSBoundParameters['Credential']) { $Splatting.credential = $Credential }

            # Set the current MSOL user to the default OnMicrosoft.com UPN Suffix
            Set-MsolUserPrincipalName -UserPrincipalName $CurrentUPN -NewUserPrincipalName $TemporaryUPN -ErrorAction Stop | Out-Null
            # Set the user to the new UPN Suffix
            Set-MsolUserPrincipalName -UserPrincipalName $TemporaryUPN -NewUserPrincipalName $NewUPN -ErrorAction Stop | Out-Null

            # Set UPN on the Active Directory User
            Get-ADUser  @splatting -LDAPFilter "(UserPrincipalName=$CurrentUPN)" -Server $DomainController |
            Set-ADUser @splatting -UserPrincipalName $NewUPN -server $DomainController -ErrorAction Stop


            # Post Change
            Start-Sleep -Seconds 5
            $MSOLUserAfter = Get-MsolUser -UserPrincipalName $NewUPN
            $ADUserAfter = Get-ADUser @splatting -LDAPFilter "(UserPrincipalName=$NewUPN)" -Server $DomainController
            [pscustomobject]@{
                State = 'AFTER'
                UserAlias = $UserAlias
                SID = $ADUserAfter.SID
                UPN_in_AD = $ADUserAfter.UserPrincipalName
                UPN_in_O365 = $MSOLUserAfter.UserPrincipalName
            }
        }
        CATCH
        {
            $Error[0].Exception.Message
        }
    }
    END
    {
        Write-Warning -Message "[END] You might want to initiate the DirSync between AD and O365 or wait for next sync"
    }
}
