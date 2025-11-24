# Dense-AzureDevOps-Ps

PowerShell module for managing Azure DevOps Server/Services

## Installation

### Future Installation
Download from PowerShell Gallery
* TODO: Publish to the powershell gallery and provide instructions

### Preview Installation
1. Clone the rep
2. Set current path to clone location 
3. Run .\Build-Module.ps1
4. See [Usage](#Usage)

## Usage
    # Establish a connection  
    $orgConnection = Connect-AzureDevOps -OrgUri 'https://mydomain/mycollection' -PersonalAccessToken $personalAccessToken  

    # Get a Team Project
    $project = Get-Project -OrgConnection $orgConnection -id 'Agile Git'

    # Explore the CmdLets
    Get-Help Get-ClassificationNode

## Development Environment

1. Create .\tests\integration\secrets.ps1 with two variables: Url to your organization, personalaccesstoken to authenticate (GitIgnore prevents it from being checked in) 
2. Run Unit Tests: e.g. Invoke-Pester .\tests\unit\getOrgConnection.tests.ps1
3. Run Integration tests: e.g. Invoke-Pester .\tests\integration\Core.tests.ps1 -Output Detailed
4. Contribute

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

### Working toward a Preview release with this core functionality
Managing TFS in a highly regulated environment demands reporting entitlements, ensuring separation-of-duties, etc. This requires a specifically designed security that can't be allowed to drift.

* Export Area and Iteration Security for checking if Teams are appropriately permissioned
* Export TFVC Security for checking if rougue people are able to change code
* Export Build Definitions and Builds to report agent usage, capabilities, and demands
* Export Release Definitions and Releases to report approval configuration and approvers, approval comments
* Export Collection and Project Level Groups/Teams to ensure no inappropriate access has been provisioned

## Credits

Inspired by the desire to learn powershell, Donovan Brown's VSTeam project, and the need to manage a TFS Instance in a highly-regulated large enterprise

## License

TODO: Write license