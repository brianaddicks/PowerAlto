poweralto
====

Welcome to the **poweralto** wiki!  **Poweralto** is a PowerShell module that provides tools for discovering, configuring, and troubleshooting **Palo Alto Next-Gen Firewalls** through their XML API.

So far, this module adds 16 new cmdlets as follows:
So far, this module adds 16 new cmdlets as follows:

* **[Find-PaAddressObject](http://brianaddicks.github.com/poweralto/Find-PaAddressObject.html)**: Search Address Objects and Address Groups for a given IP, FQDN, or string.* **[Find-PaUnusedObjects](http://brianaddicks.github.com/poweralto/Find-PaUnusedObjects.html)**: Find unused Address Objects and Address Groups.* **[Get-PaConnectionString](http://brianaddicks.github.com/poweralto/Get-PaConnectionString.html)**: Connects to a Palo Alto firewall and returns an connection string with API key. adds value to global:PaConnectionArray for other functions to access* **[Get-PaNatRule](http://brianaddicks.github.com/poweralto/Get-PaNatRule.html)**: Returns NAT Ruleset from Palo Alto firewall.* **[Get-PaObjectUsage](http://brianaddicks.github.com/poweralto/Get-PaObjectUsage.html)**: Returns Security, Nat, Address and Address Group usge of specific search string.* **[Get-PaSecurityRule](http://brianaddicks.github.com/poweralto/Get-PaSecurityRule.html)**: Returns Security Ruleset from Palo Alto firewall.* **[Get-PaSystemInfo](http://brianaddicks.github.com/poweralto/Get-PaSystemInfo.html)**: Returns general information about the desired PA.* **[Invoke-PaCommit](http://brianaddicks.github.com/poweralto/Invoke-PaCommit.html)**: Commits candidate config to Palo Alto firewall* **[Restart-PaSystem](http://brianaddicks.github.com/poweralto/Restart-PaSystem.html)**: Restarts PA and watches initial autocommit job for completion.* **[Restore-PaPreviousVersion](http://brianaddicks.github.com/poweralto/Restore-PaPreviousVersion.html)**: Reverts to previous configuration version* **[Send-PaApiQuery](http://brianaddicks.github.com/poweralto/Send-PaApiQuery.html)**: Query Palo Alto for custom data.* **[Set-PaSecurityRule](http://brianaddicks.github.com/poweralto/Set-PaSecurityRule.html)**: Edits settings on a Palo Alto Security Rule* **[Set-PaUpdateSchedule](http://brianaddicks.github.com/poweralto/Set-PaUpdateSchedule.html)**: Defines schedule for content updates.* **[Update-PaContent](http://brianaddicks.github.com/poweralto/Update-PaContent.html)**: Updates Pa Content files.* **[Update-PaSoftware](http://brianaddicks.github.com/poweralto/Update-PaSoftware.html)**: Updates PanOS software to desired version.* **[Watch-PaJob](http://brianaddicks.github.com/poweralto/Watch-PaJob.html)**: Watch a given Jobs progress.To install poweralto, download [poweralto.psm1](https://github.com/brianaddicks/poweralto/blob/master/poweralto.psm1).

Place it inside a it's own directory (named poweralto) inside your Powershell Module path.  You can get your PSModule path from $env:PSModulePath. For example:
* Current User scope: `C:\Users\user\Documents\WindowsPowerShell\Modules\poweralto\poweralto.psm1`
* Local Machine scope: `C:\Windows\system32\WindowsPowerShell\v1.0\Modules\poweralto\poweralto.psm1`

After the file is in place, you can then import it into your PowerShell session:
`Import-Module poweralto`

