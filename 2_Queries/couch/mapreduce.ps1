# // POPULATE ENV VARIABLES \\
$env_file = if (Test-Path './.env') {'./.env'} elseif (Test-Path '../.env') {'../.env'} elseif (Test-Path '../../.env') {'../../.env'} else {throw '.env not found.'}
Get-Content $env_file | ForEach-Object {
    if([string]::IsNullOrWhiteSpace($_) -or $_.StartsWith('#')) { return }
    
    $parts = $_ -split '=', 2

    if(-not $parts.Length -eq 2) { return }

    $name = $parts[0].Trim()
    $value = $parts[1].Trim()

    Set-Item "env:$name" $value
}
# // --------------------- \\


$url = "http://${ENV:COUCHDB_USER}:${ENV:COUCHDB_PASS}@127.0.0.1:5984/"

$db_name = 'phones'

$brands_views_file = "$PSScriptRoot/brands_views.json"

Write-Output "`n`t`Create brands views:`n"
curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'PUT', "$url/$db_name/_design/brands", '-d', "@$brands_views_file"

# Find one particular document
Write-Output "`n`t`Find Galaxy A60 document:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/models?key=%22Galaxy%20A60%22" # Powershell is weird about escaping "" so I manually url encode it to %22 here

# Find range of documents (using a view that returns lower-case brand names only)
Write-Output "`n`t`Find devices of brands from 'A' to 'C' in alphabetical order:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/all_lower?startkey=%22a%22&endkey=%22d%22" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."

# _sum
Write-Output "`n`t`Summation:`n"

Write-Output "`t`Sum total device specification count:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/sum_specification_count" | Select-Object -first 10 | Write-Output

Write-Output "`t`Sum total device specification count per brand:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/sum_specification_count?group=true" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."

# _count
Write-Output "`n`t`Counting:`n"

Write-Output "`t`Count of devices:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/count_devices" | Select-Object -first 10 | Write-Output

Write-Output "`t`Count of devices per brand:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/count_devices?group=true" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."

# _stats

Write-Output "`n`t`Statistics of android devices in all brands:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_design/brands/_view/android_devices?reduce=true" | Select-Object -first 10 | Write-Output