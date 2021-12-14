---
title: Windows PSSession MOTD
date: 2021-12-13 09:30:00
categories: [Windows, Server administration]
tags: [pinned,windows,winrm,pssession,pssessionconfiguration,motd,banner]     # TAG names should always be lowercase
---

Setting up a completely new windows environment comes with some one time configurations. One of those is legal notice texts and banners. Aside from the usual legalnotice text registry key, which only sets a legal message for Remote Desktop Connections. There is also a way to configure MOTD banners when connecting over Winrm to a windows host in powershell (Enter-PSSession).

Here's an example of what it might look like:
![image](/assets/motd/motd_example.png)

## Set up

To have a nice banner as shown in the screenshot above. We need the following:

1. Environment variables, useful info to show upon startup
2. Ensure the presence of the banner startup script
3. Set the remote session configuration

For the sake of being generic let's say we decide on a __motd_path__ filepath, which can be interpreted as: 'C:\whereveryouwant\motd\'. In the environment for which I configured this we are using Puppet as a configuration manager. But I suppose this could be translated to any other configuration manager.

&nbsp;

## 1. Environment variables

Aside from a nice logo that is shown, we would like to see some useful information concerning the machine you are connecting to. This could be the machine name, ip address, current disk space used, full FQDN, status of certain services. The needs may differ here, change at will.

In my case I use a configuration manager to ensure the presence of a PowerShell Datafile (.psd1) in the motd_path, parsed with some environment variables. Using the .psd1 format allows us to import the file in PowerShell as nice hashtable. Since I'm using puppet at this time, I am putting this file as a ruby template in a module (applied on the machine). Which will parse the variables in between the '<%= %>' with machine variables and facts. The psd1 file looks something like:

```powershell
@{
    someInfo1      = '<%= @someInfo1 %>';
    someInfo2      = '<%= @someInfo2 %>';
    someInfo3      = '<%= @someInfo3 %>';
    someInfo4      = '<%= @someInfo4 %>';
    someInfo5      = '<%= @someInfo5 %>';
    Datacenter     = '<%= @env_dc %>';
    someInfo6      = '<%= @someInfo6 %>';
    'AD Domain'    = '<%= @ad_domain %>';
    Domain         = '<%= @domain %>';
    OS             = '<%= @windows_product_name %>';
    Hostname       = '<%= @hostname %>';
    'Server Type'  = '<%= @operatingsystemtype %>';
    someInfo9      = '<%= @environment %>';
}
```

The .psd1 will be imported in to a variable used throughout the nexts script to put the info in the right place. I can imagine that this can be reworked to contain perhaps performance metrics or anything really.

&nbsp;

## 2. Startupscsript

Now for the second file we need to have in the motd_path. This is the actual script that will run at startup to display the banner. A couple of things to note:

- __Save the file as UTF8 With BOM__. If this is not done, the characters for the borders will be all messed up because of incompatible file encoding.

- When importing the psd1 file, I'm again parsing a Ruby variable in puppet to ensure to have the correct path. This could be replaced with some declaration on where the script is located (something like "$ScriptPath = Split-Path $MyInvocation.MyCommand.Path")

- In the beginning of the script (the switch statement) I'm deciding whether or not to show the logo because of screen size constraints. I thought it'd be nice to have scaling responsive message. And if the console size is ridiculously small, i'm resorting to a simple echo of the legalnotice text.

```powershell
## ATTENTION ::  This file needs to be saved with encoding UTF8 With BOM !!! otherwise special characters will not be loaded properly
## Dependency :: In the specified MOTD Path there needs to be a MOTDVars.psd1 file which contains a hashtable of environment variables!

#region setVariables
# Assign static variables based on banner size
switch ($Host.UI.RawUI.WindowSize.Width) {
    {$_ -ge 97}{
        $drawBox     = $true
        $windowsLogo = $true
        $top_banner  = @"
                                    ╭──────────────────────────╮
    ╒═══════════════════════════════╡       ⚠  Warning ⚠      ╞═══════════════════════════════╕
    │                               ╰──────────────────────────╯                               │
    │                                                                                          │
    │                      Access is restricted to authorised users ONLY.                      │
    │                      All connections and transactions are monitored.                     │
    │               By continuing past this point, you consent to this monitoring.             │
    │                                                                                          │
"@
            $div = @"
    ├──────────────────────────────────────────────────────────────────────────────────────────┤
"@
            $spacer = '    │  '
            $width  = $div.length
            $foot = '    └' + '─' * ($width - 6) + '┘'
            $limit = 34
            }
        {$_ -ge 54 -AND $_ -lt 97} {
            $drawBox     = $true
            $top_banner = @"
            ╭──────────────────────────────╮
    ╒═══════╡        ⚠   Warning ⚠        ╞═══════╕
    │       ╰──────────────────────────────╯       │
    │                                              │
    │    Access is restricted to authorised        │
    │    users ONLY. All transactions and          │
    │    connections are monitored.                │
    │    By continuing past this point, you        │
    │    consent to this monitoring.               │
    │                                              │
"@
            $div = @"
    ├──────────────────────────────────────────────┤
"@
            $width  = $div.length
            $spacer = '    │    '
            $foot = '    └' + '─' * ($width - 6) + '┘'
            $limit = 29
        }
        {$_ -lt 54} {
            Write-Host "!! Warning !!"
            Write-Host "Access is restricted to authorised users ONLY. All connections and transactions are monitored. By continuing past this point, you consent to this monitoring."
        }
    }
#import device info
    ## Import MOTDVars.psD1    
    $import = Import-PowerShellDataFile  '<%= @motd_path %>\motdVars.psd1'; $motdVars =  @{}; $import.Keys | % { if ($import.$_.length -gt $limit ) { $motdVars += @{ $_ = 'error::var_too_long' } }else { $motdVars += @{ $_ = $import.$_ } } }
    $Date = Get-Date
    $env_color = switch ($motdVars.someInfo9) {
        'dev'         { "DarkGreen" }
        'staging'     { "DarkBlue" }
        'production'  { "Red" }
        Default       { "Yellow" }
    }
    $body = @{
        1  = @{ WindowsLogo = @{ 1 = @{ "                        " = 'Black' }; 2 = @{ "                  " = 'Black'; }; }                                                  ; Info = @{ ''           = 'Yellow'   ; }  ; };
        2  = @{ WindowsLogo = @{ 1 = @{ "         ,.=:^!^!t3Z3z.," = 'Red' }  ; 2 = @{ "                  " = 'Blue'; }; }                                                   ; Info = @{ $Date        = $env_color; } ; };
        3  = @{ WindowsLogo = @{ 1 = @{ "        :tt:::tt333EE3 " = 'Red' }   ; 2 = @{ "                   " = 'Black'; }; }                                                 ; Info = @{ ''           = 'Black'  ; }  ; };
        4  = @{ WindowsLogo = @{ 1 = @{ "        Et:::ztt33EEE " = 'Red' }    ; 2 = @{ " @Ee.,      ..,     " = 'Green'; }; }                                                ; Info = @{ 'Hostname'   = 'Yellow'   ; }  ; };
        5  = @{ WindowsLogo = @{ 1 = @{ "       ;tt:::tt333EE7" = 'Red' }     ; 2 = @{ " ;EEEEEEttttt33#     " = 'Green'; }; }                                               ; Info = @{ 'OS'         = 'Yellow'   ; }  ; };
        6  = @{ WindowsLogo = @{ 1 = @{ "      :Et:::zt333EEQ." = 'Red' }     ; 2 = @{ " SEEEEEttttt33QL     " = 'Green'; }; }                                               ; Info = @{ 'Server Type'= 'Yellow'   ; }  ; };
        7  = @{ WindowsLogo = @{ 1 = @{ "      it::::tt333EEF" = 'Red' }      ; 2 = @{ " @EEEEEEttttt33F      " = 'Green'; }; }                                              ; Info = @{ ''           = 'Black'  ; }  ; };
        8  = @{ WindowsLogo = @{ 1 = @{ "     ;3=*^``````'*4EEV" = 'Red' }    ; 2 = @{ " :EEEEEEttttt33@.      " = 'Green'; }; }                                             ; Info = @{ 'someInfo1'  = 'Yellow'   ; }  ; };
        9  = @{ WindowsLogo = @{ 1 = @{ "     ,.=::::it=., " = 'Cyan' }       ; 2 = @{ "``" = 'Red'; }; 3 = @{" @EEEEEEtttz33QF       " = 'Green'; }; }                      ; Info = @{ 'someInfo2'  = 'Yellow'   ; }  ; };
        10 = @{ WindowsLogo = @{ 1 = @{ "    ;::::::::zt33) " = 'Cyan' }      ; 2 = @{ "  '4EEEtttji3P*        " = 'Green'; }; }                                             ; Info = @{ 'someInfo3'  = 'Yellow'   ; }  ; };
        11 = @{ WindowsLogo = @{ 1 = @{ "   :t::::::::tt33." = 'Cyan' }       ; 2 = @{ ":Z3z.. " = 'Yellow'; " ````" = 'Green' }; 3 = @{" ,..g.        " = 'Yellow'; }; }    ; Info = @{ 'someInfo4'  = 'Yellow'   ; }  ; };
        12 = @{ WindowsLogo = @{ 1 = @{ "   i::::::::zt33F" = 'Cyan' }        ; 2 = @{ " AEEEtttt::::ztF         " = 'Yellow'; }; }                                          ; Info = @{ ''           = 'Black'  ; }  ; };
        13 = @{ WindowsLogo = @{ 1 = @{ "  ;:::::::::t33V" = 'Cyan' }         ; 2 = @{ " ;EEEttttt::::t3          " = 'Yellow'; }; }                                         ; Info = @{ 'someInfo5'  = 'Yellow'   ; }  ; };
        14 = @{ WindowsLogo = @{ 1 = @{ "  E::::::::zt33L" = 'Cyan' }         ; 2 = @{ " @EEEtttt::::z3F          " = 'Yellow'; }; }                                         ; Info = @{ 'Datacenter' = 'Yellow'   ; }  ; };
        15 = @{ WindowsLogo = @{ 1 = @{ " {3=*^``````'*4E3)" = 'Cyan' }       ; 2 = @{ " ;EEEtttt:::::tZ``          " = 'Yellow'; }; }                                       ; Info = @{ 'someInfo6'  = 'Yellow'   ; }  ; };
        16 = @{ WindowsLogo = @{ 1 = @{ "             ``" = 'Cyan' }          ; 2 = @{ " :EEEEtttt::::z7            " = 'Yellow'; }; }                                       ; Info = @{ 'AD Domain'  = 'Yellow'   ; }  ; };
        17 = @{ WindowsLogo = @{ 1 = @{ "                 'VEzjt:;;z>*``            " = 'Yellow'; }; }                                                                       ; Info = @{ 'someInfo9'  = 'Yellow'   ; }  ; };
        18 = @{ WindowsLogo = @{ 1 = @{ "                      ````                  " = 'Yellow'; }; }                                                                      ; Info = @{ ''           = 'Black'  ; }  ; };
    }
#endregion setvariables
# Write Actual Banner
if($drawBox){
    write-host $top_banner -ForegroundColor $env_color
    write-host $div -ForegroundColor $env_color
    ## write body
    for ($i = 1; $i -le $body.Count; $i++) {
        $lineLength = 0
        Write-Host $spacer -NoNewline -ForegroundColor $env_color
        if($windowsLogo){
            for ($x = 1; $x -le $body.$i.WindowsLogo.Keys.Count; $x++) {
                $body.$i.WindowsLogo.$x.Keys | % { 
                    Write-host $_ -NoNewline -ForegroundColor $body.$i.WindowsLogo.$x.$_ 
                    $lineLength += $_.length
                }
            }
        }
        $body.$i.Info.Keys | % {
            $info_key = "$($_)$(if($motdVars.$_){': '})"
            $info_var  = "$($motdVars.$_)"
            Write-host $info_key -NoNewline -ForegroundColor $body.$i.Info.$_
            Write-host $info_var -NoNewline -ForegroundColor Gray
            $lineLength += ($info_key.length + $info_var.length)
        }
        Write-Host "$(' '*($width - $spacer.length - $lineLength -1) + '│')"  -ForegroundColor $env_color
    }
    Write-Host ("$foot") -ForegroundColor $env_color
}
```

__Note:__ I have to disclaim that I found the windows logo on [GitHub](https://github.com/joeyaiello/ps-motd), credit where credit is due. I decided to rewrite it abit to have the logo in a hashtable together with the session info. And to build the banner with the nested loops. My thought was that it's shorter, nicer and more readable. However using nested loops like that my come with some performance impact. Maybe it's a bit harder on the cpu when the script runs. I found when testing that it was not that bad of a delay compared to using the millions of write-host statements. Depends on the case and what you prefer.

&nbsp;

## 3. Set-PSSessionConfiguration

Now that we have all the necessary files in place, we need to configure the machine to run the motd.ps1 script on startup of a Remote Session. We need to point the PSSessionConfiguration for the microsoft.powershell profile to the startupscript, or create a new profile. Again depends on the use case.

```powershell
#decide if config needs to be set
if((Get-PSSessionConfiguration | where name -like 'microsoft.powershell').startupscript -eq '$($motd_path)\\motd.ps1'){
    # Set the config
    Set-PSSessionConfiguration -Name 'microsoft.powershell' -startupscript '${motd_path}\\motd.ps1' -NoServiceRestart
}else{
    exit 0
}
```

I prefer to put the NoServiceRestart when setting the configuration because when testing in my environment I found that setting the startupscript in this case did not require the pssesion (winrm) service to restart. __Warning: if you do not specify the argument NoServiceRestart, the winrm service will restart and all current remote session will be disconnected...__

Once all this is configured, once you do an Enter-PSSession to a machine this is configured on. You should see a nice banner.

## Sources

- Special credit goes to the github user [joeyaiello, whose project](https://github.com/joeyaiello/ps-motd) inspired me, specifically for the windows logo.

- Microsoft Doc: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-pssessionconfiguration?view=powershell-7.2
