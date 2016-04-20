# Get-O365CalendarEvent

## Usage
``` powershell
Get-O365CalendarEvent `
    -EmailAddress info@lazywinadmin.com `
    -Credential (Get-Credential) `
    -StartDateTime ((Get-Date).adddays(-5)) `
    -EndDateTime (Get-Date) `
    -PageResult 2|Select-Object -Property Subject, StartTimeZone, Start, End
```

![Alt text](https://raw.githubusercontent.com/lazywinadmin/PowerShell/master/O365-Get-O365CalendarEvent/images/Get-O365CalendarEvent.png?raw=true "Get-O365CalendarEvent Example")
