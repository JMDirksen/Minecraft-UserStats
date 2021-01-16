$statsDir = "..\MinecraftServer\world\stats"
$dbFile = "UserStats.json"

function Main {
    # Load db
    $db = Get-Content $dbFile | ConvertFrom-Json -AsHashtable
    if ($null -eq $db) { $db = @{} }

    # Get statistics
    $statsFiles = Get-ChildItem $statsDir -Filter *.json
    $current = ($statsFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-10) }).Count
    $totalLastHour = ($statsFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) }).Count
    $totalLastDay = ($statsFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }).Count
    $totalLastWeek = ($statsFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }).Count
    $totalLastMonth = ($statsFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMonths(-1) }).Count
    $totalLastYear = ($statsFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddYears(-1) }).Count
    $total = $statsFiles.Count

    # Add record
    $key = Get-DateKey
    $db[$key] = $current

    # Store db
    $db | ConvertTo-Json -Compress | Out-File -FilePath $dbFile

    # Calculate statistics
    $todayKey = $key.Substring(0, 6)
    $today = $db.GetEnumerator() | Where-Object { $_.Key.StartsWith($todayKey) } | Measure-Object Value -Average -Maximum

    $monthKey = $key.Substring(0, 4)
    $month = $db.GetEnumerator() | Where-Object { $_.Key.StartsWith($monthKey) } | Measure-Object Value -Average -Maximum

    $yearKey = $key.Substring(0, 2)
    $year = $db.GetEnumerator() | Where-Object { $_.Key.StartsWith($yearKey) } | Measure-Object Value -Average -Maximum
    $lastYearKey = (Get-DateKey (Get-Date).AddYears(-1)).Substring(0, 2)
    $lastYear = $db.GetEnumerator() | Where-Object { $_.Key.StartsWith($lastYearKey) } | Measure-Object Value -Average -Maximum

    # Output statistics
    $output = "# Updated" + [environment]::NewLine
    $output += (Get-Date).ToString() + [environment]::NewLine
    $output += "" + [environment]::NewLine
    $output += "# Total players" + [environment]::NewLine
    $output += "Current    " + $current + [environment]::NewLine
    $output += "Last hour  " + $totalLastHour + [environment]::NewLine
    $output += "Last day   " + $totalLastDay + [environment]::NewLine
    $output += "Last week  " + $totalLastWeek + [environment]::NewLine
    $output += "Last month " + $totalLastMonth + [environment]::NewLine
    $output += "Last year  " + $totalLastYear + [environment]::NewLine
    $output += "Total      " + $total + [environment]::NewLine
    $output += "" + [environment]::NewLine
    $output += "# Maximum players online" + [environment]::NewLine
    $output += "Today      " + [math]::Round($today.Maximum, 2) + " (" + [math]::Round(($today.Maximum - $month.Maximum) / $month.Maximum * 100) + "%)" + [environment]::NewLine
    $output += "This month " + [math]::Round($month.Maximum, 2) + " (" + [math]::Round(($month.Maximum - $year.Maximum) / $year.Maximum * 100) + "%)" + [environment]::NewLine
    $output += "This year  " + [math]::Round($year.Maximum , 2) + " (" + [math]::Round(($year.Maximum - $lastYear.Maximum) / $lastYear.Maximum * 100) + "%)" + [environment]::NewLine
    $output += "" + [environment]::NewLine
    $output += "# Average players online" + [environment]::NewLine
    $output += "Today      " + [math]::Round($today.Average, 2) + " (" + [math]::Round(($today.Average - $month.Average) / $month.Average * 100) + "%)" + [environment]::NewLine
    $output += "This month " + [math]::Round($month.Average, 2) + " (" + [math]::Round(($month.Average - $year.Average) / $year.Average * 100) + "%)" + [environment]::NewLine
    $output += "This year  " + [math]::Round($year.Average , 2) + " (" + [math]::Round(($year.Average - $lastYear.Average) / $lastYear.Average * 100) + "%)" + [environment]::NewLine

    $output | Out-File UserStats.txt
    [environment]::NewLine + $output
}

function Get-DateKey([datetime]$Date = (Get-Date)) {
    $key = (Get-Date -Date $Date -Format "yyMMddHHmm").ToString()
    $key.Substring(0, $key.Length - 1) + "0"
}

Main
