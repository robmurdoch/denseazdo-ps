class OrgConnection {
    [string]$Uri

    [System.Collections.Hashtable]$Headers

    [ValidateSet('DefaultCredential', 'PersonalAccessToken', 'Credential')]
    [string]$AuthenticationMethod

    [ValidateSet('api-version=7.0', 'api-version=6.0', 'api-version=5.0', 'api-version=4.1')]
    [string]$ApiVersion

    [string[]]$ApiVersions = @('api-version=7.0', 'api-version=6.0', 'api-version=5.0', 'api-version=4.1')
    
    OrgConnection(
        [string]$Uri,
        [System.Collections.Hashtable]$Headers,
        [string]$AuthenticationMethod
    ) {
        $this.Uri = $Uri
        $this.Headers = $Headers
        $this.AuthenticationMethod = $AuthenticationMethod
    }
    
    OrgConnection(
        [string]$Uri,
        [string]$AuthenticationMethod
    ) {
        $this.Uri = $Uri
        $this.Headers = @{}
        $this.AuthenticationMethod = $AuthenticationMethod
    }
    
    OrgConnection(
        [string]$Uri
    ) {
        $this.Uri = $Uri
        $this.Headers = @{}
        $this.AuthenticationMethod = 'DefaultCredential'
    }
    
    OrgConnection(
    ) {
        $this.Uri = 'undefined'
        $this.Headers = @{}
        $this.AuthenticationMethod = 'DefaultCredential'
    }

    [double] getApiVersionNumber() {
        $versionPart = $this.ApiVersion.Substring($this.ApiVersion.IndexOf('=') + 1)
        return [double]$versionPart
    }
}