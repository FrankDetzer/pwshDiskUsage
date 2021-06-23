# Author:       FrankieDevOp
# Date:         2021-06-23
# Link:         https://github.com/FrankieDevOp/psdu
# Version:      2.0.0
# Changelog:    see readme.md

function Get-PowerShellDiskUsage {
    [Alias('psdu','ncdu','Get-HumanFriendlyFileList','psHFO','gfl')]
    param (
        [string]$Path = (Get-Location).Path,
        [validateset('Auto', 'Bytes', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$Unit = 'Auto'
    )

    begin {
        [uint64]$TotalItemLength = 0
        $AllFilesReadable = $true
        $Output = New-Object System.Collections.Generic.List[System.Object]
        $Readable = $true
        $Counter = 1

        if ($Path.Length -eq 1 -and $Path -ne '/') {
            $Path = $Path + ':'
        }

        $List = Get-ChildItem -Path $Path -Recurse:$false
        $Disk = Get-PSDrive $List[0].PSDrive
        $DiskTotalSpaceInBytes = $Disk.Used + $Disk.Free

        foreach ($Item in $List) {
            $PercentComplete = $Counter / $List.Count * 100
            Write-Progress -Activity 'Indexing in Progress' -Status ([string]$Counter + '/' + [string]$List.Count + ' (' + '{0:n2} %)' -f ($PercentComplete) + ' items indexed') -PercentComplete $PercentComplete

            if ($Item.PSIsContainer) {
                try {
                    $Length = (Get-ChildItem -Path $Item.FullName -Recurse:$true -File -ErrorAction Stop | Measure-Object Length -Sum).Sum 
                }
                catch {
                    $Readable = $false
                    $AllFilesReadable = $false
                    $Length = 0
                }
            }
            else {
                $Length = $Item.Length
            }

            if ($null -eq $Length) {
                $Length = 0
            }


            $Output.Add([PSCustomObject][ordered]@{
                'Name'           = $Item.Name
                'SizeVisualised' = $null
                'Mode'           = $Item.Mode
                'Length'         = $Length
                'SizeInPercent'  = $null
                'Readable'       = $Readable
                'IsContainer'    = $Item.PSIsContainer
            })

            $TotalItemLength += $Length
            $Counter++
        }

        $Meta = (
            [pscustomobject]@{
                Path           = $List[0].Parent
                TotalItemCount = $Output.Count
                TotalItemSize  = $TotalItemLength
                FolderCount    = ($Output | Where-Object { $_.IsContainer -eq $true }).Count
                ItemCount      = ($Output | Where-Object { $_.IsContainer -eq $false }).Count
                UsageInPercent = '{0:n2} %' -f ([math]::round($TotalItemLength / $DiskTotalSpaceInBytes * 100, 2)) 
            }
        )    
    }

    process {
        $Output = $Output | Sort-Object IsContainer, Length -Descending 
        $Output | ForEach-Object {
            $SizeInPercent = $_.Length / $TotalItemLength * 100
            [int]$SimplePercent = $SizeInPercent / 10

            $_.SizeVisualised = '[' + ('#' * $SimplePercent) + (' ' * (10 - $SimplePercent)) + ']'
            $_.SizeInPercent = '{0:n2} %' -f ([math]::round($SizeInPercent, 2)) 
            $_.Length = Format-BytesToHumanReadable -Length $_.Length -SizeUnit $Unit

                if ($_.IsContainer) {
                    $_.Name = $_.Name + '/'
                }
        }
    }

    end {
        $Disk | Format-Table -AutoSize -Property @{Name = 'Disk'; Expression = { $_.Name } }, @{Name = 'Used'; Expression = { Format-BytesToHumanReadable -Length $_.Used -SizeUnit $Unit }; Align = 'right' }, @{Name = 'Free'; Expression = { Format-BytesToHumanReadable -Length $_.Free -SizeUnit $Unit }; Align = 'right' }, @{Name = 'Total'; Expression = { Format-BytesToHumanReadable -Length $DiskTotalSpaceInBytes -SizeUnit $Unit }; Align = 'right' }
        $Meta | Format-Table -AutoSize -Property Path, TotalItemCount, @{Name = 'TotalItemSize'; Expression = { Format-BytesToHumanReadable -Length $_.TotalItemSize -SizeUnit $Unit }; Align = 'right' }, @{Name = 'UsageInPercent'; Expression = { $_.UsageInPercent }; Align = 'right' }, FolderCount, ItemCount


        if ($AllFilesReadable) {
            $Output | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Length'; Expression = { $_.Length }; Align = 'right' }
        }
        else {
            Write-Warning 'Results unaccurate. Unable to read all items. Restart Power Shell with elevated privileges to receive accurate results.'
            $Output | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Length'; Expression = { $_.Length }; Align = 'right' }, Readable
        }
    }   
}

function Format-BytesToHumanReadable {
    param (
        [uint64]$Length,
        [validateset('Auto', 'Bytes', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$Unit = 'Auto'
    )

    process {
        if ($Unit -eq 'Auto') {
            if ($Length -lt 1) {
                $Output = $null
            }
            elseif ($Length -lt 1KB) {
                $Output = '{0:n0}     B' -f $Length
            }
            elseif ($Length -lt 1MB) {
                $Output = '{0:n2} KB' -f ($Length / 1KB)
            }
            elseif ($Length -lt 1GB) {
                $Output = '{0:n2} MB' -f ($Length / 1MB)
            }
            elseif ($Length -lt 1TB) {
                $Output = '{0:n2} GB' -f ($Length / 1GB)
            }
            elseif ($Length -lt 1PB) {
                $Output = '{0:n2} TB' -f ($Length / 1TB)
            }
            else {
                $Output = '{0:n2} PB' -f ($Length / 1PB)
            }
        }
        else {
            switch ($Unit) {
                'Bytes' {
                    $Output = '{0:n0}     B' -f $Length
                }
                'KB' {
                    $Output = '{0:n2} KB' -f ($Length / 1KB)
                }
                'MB' {
                    $Output = '{0:n2} MB' -f ($Length / 1MB)
                }
                'GB' {
                    $Output = '{0:n2} GB' -f ($Length / 1GB)
                }
                'TB' {
                    $Output = '{0:n2} TB' -f ($Length / 1TB)
                }
                'PB' {
                    $Output = '{0:n2} PB' -f ($Length / 1PB)
                }
            }
        }
    }
    end {
        return ($Output)
    }
}