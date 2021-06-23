# Get-PowerShellDiskUsage (psdu)
![Screenshot 2021-06-23 133458](https://user-images.githubusercontent.com/57404682/123090251-3a7d4280-d428-11eb-8c43-2298853b7e6b.png)


## SYNOPSIS
This cmdlet is intended for on-premises servers and in cloud-based service. 

Use the Get-PowerShellDiskUsage cmdlet to view items and folders and their respective size and attributes.

---
## SYNTAX
```
Get-PowerShellDiskUsage 
 [-Path]
 [-SizeUnit]
```

---
## DESCRIPTION
Currently the Get-PowerShellDiskUsage cmlet provides a simular output which you would expect from "ncdu" (NCurses Disk Usage) on a linux machine.

You can run this module with and without the appropiate permissions for the folder you try to view. If Get-PowerShellDiskUsage cannot read the file or folder a warning will be displayed.

---
## HOW TO USE
To use psdu please "dot source" (load) the Get-PowerShellDiskUsage.ps1 file. To do this change to the folder containing the Get-PowerShellDiskUsage.ps1 file and put a dot before the file path. 

### DOT SOURCE (LOADING) EXAMPLE
```
cd ~/Downloads/Get-PowerShellDiskUsage/
. Get-PowerShellDiskUsage.ps1
psdu 
```

- On Line 1 you see the change to the folder containing the script.
- On Line 2 you actually dot sorce (load the script into the Power Shell runtime) the script.
- On Line 3 you now have now have all the functions of the script in your powershell runtime and can use them as shown before.


### More Information
Please visit [Microsofts Power Shell Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-7.1#script-scope-and-dot-sourcing) for more Information.

---
## CHANGELOG

### Version 2.0.0 (2021-06-23)
- massivly simplified script
- removed unnecessary files & functions
- improved code 

### Version 1.0.0 (2020-11-01)
- Initial Release

---
## EXAMPLES

### Example 1
```powershell
Get-PowerShellDiskUsage /
```

This example returns a summary list of all the files and folders in the root folder of your computer using the alias.

### Example 2
```powershell
Get-PowerShellDiskUsage -SizeUnit MB
```

This example returns a list of all the files and folders in the current folder and formats them to MB.

---
## PARAMETERS

### -Path
This parameter can be used to specify a path other than the current location of your shell.

### -SizeUnit
This parameter formats the output according to the input. 

You can specify: Bytes, KB, MB, GB, TB and PB.

---
## INPUTS

###  
Currently the module accepts text input and no pipe input.

---
## OUTPUTS

###  
The Output of this module is text only. It cannot be used to pipe to other cmdlets.

---
## ALIASES

* psdu
* Get-HumanFriendlyFileList
* psHFO
* gfl
* ncdu

---
## NOTES


---
## RELATED LINKS
https://github.com/FrankieDevOp/psdu