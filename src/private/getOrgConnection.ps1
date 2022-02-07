
function getOrgConnection {
    [CmdletBinding()]
    [OutputType([OrgConnection])]
    param(
        [string]$Uri,
        [string]$PersonalAccessToken,
        [System.Management.Automation.PSCredential]$Credential
    )

    if ($PSBoundParameters.ContainsKey("PersonalAccessToken")) {

        $encodedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken"))
        return [OrgConnection]::New($Uri, @{Authorization = "Basic $encodedToken" }, 'PersonalAccessToken')

    }
    elseif ($PSBoundParameters.ContainsKey("Credential")) {

        $encodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credential.UserName, $Credential.Password)))
        return [OrgConnection]::New($Uri, @{Authorization = "Basic $encodedCredential" }, 'Credential')
    }
    else {

        return [OrgConnection]::New($Uri, 'DefaultCredential')

    }
}