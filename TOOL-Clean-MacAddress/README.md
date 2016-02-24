[CleanMacaddress01]: https://github.com/lazywinadmin/PowerShell/blob/master/TOOL-Clean-MacAddress/Clean-MacAddress01.png
# Clean-MacAddress
This function is used to clean up a Mac Address string.

I'm using this for some report and for SCCM Automation to keep everything clean :-)
## Loading the function

```PowerShell
# Load the function in your PS
. .\Clean-MacAddress.ps1
```

![alt text][CleanMacAddress01]

## Clean a Mac Address

```PowerShell
# Clean a Mac Address
Clean-MacAddress -MacAddress '00:11:22:33:44:55'
001122334455

# Clean a Mac Address and convert to UpperCase
Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Uppercase
001122DDEEFF

# Clean a Mac Address and convert to LowerCase
Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase
001122ddeeff

# Clean a Mac Address and convert to LowerCase and add a dash separator
Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase -Separator '-'
00-11-22-dd-ee-ff

# Clean a Mac Address and convert to LowerCase and add a dot separator
Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase -Separator '.'
00.11.22.dd.ee.ff

# Clean a Mac Address and convert to LowerCase and add a colon separator
Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase -Separator :
00:11:22:dd:ee:ff

```
