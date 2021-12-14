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
    