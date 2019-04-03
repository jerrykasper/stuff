Param (
    [string]$Computername = $env:computername
)

Begin {

    [String]$date = Get-Date -Format "dd-MM-yyyy"
    [int]$Days = 6000
    $Result = @()
    New-Item -Path c:\temp -Force -ItemType Directory
    $OutputFileName = "c:\temp\" + $Computer + " " + $date + ".txt"
    
}

Process {
    "Gathering Event Logs, this can take awhile..."

    Foreach ($computer in $computername) {
        $ELogs = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-$Days) -ComputerName $Computer
    
        If ($ELogs) {
            "Processing..."
            ForEach ($Log in $ELogs) {
            
                If ($Log.InstanceId -eq 7001) {
                    $ET = "Logon"
                }
                ElseIf ($Log.InstanceId -eq 7002) {
                    $ET = "Logoff"
                }
                $Result += New-Object PSObject -Property @{
                    Time     = $Log.TimeWritten
                    User     = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
                    Computer = $log.MachineName
                    ET       = $ET
                    Error    = $null
                }
            }
        
        }
        Else {
            $Result += New-Object PSObject -Property @{
                Time     = $null
                User     = $null
                Computer = $computer
                ET       = $null
                Error    = "Problem with $Computer."
            }
            "If you see a 'Network Path not found' error, try starting the Remote Registry service on $computer."
            "Or there are no logon/logoff events (XP requires auditing be turned on)"
        }
    }
}
end {
    $Result | Select-Object Time, $ET, User | Sort-Object Time -Descending | Export-Csv $OutputFileName
    "Done."
}