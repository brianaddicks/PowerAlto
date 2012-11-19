PaSH
====

Welcome to the PaSH wiki!  PaSH (Palo Alto Shell) is a powershell module for access Palo Alto Next-Gen Firewalls through their built-in XML API.

So far, this module adds 6 new cmdlets as follows:

**Get-PaConnectionString**: Connects to the firewall with a PSCredential, generates an apikey and returns a url string to begin making connections.

**Get-PaCustom**: Builds a valid api query from a connection string, type, action, and xpath.

**Get-PaRules**: Returns all Security Rules to a PSObject

**Get-PaSystemInfo**: Returns various system information including sofware/update versions

**Set-PaRule**: Edits or creates a security rule.

**Invoke-PaCommit**: Commits current candidate configuration.

To install PaSH, simply download [paloalto.psm1](https://github.com/brianaddicks/PaSH/blob/master/PaloAlto.psm1).  Place it inside a it's own directory (named paloalto) inside your Powershell Module path.  You can get your PSModule path from: $env:PSModulePath