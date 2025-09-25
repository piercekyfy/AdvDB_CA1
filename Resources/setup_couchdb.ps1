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

Write-Output "Performing First Time Configuration..."

curl.exe '-X', 'PUT', "$url/_users"
curl.exe '-X', 'PUT', "$url/_replicator"

$db_name = 'phones'
$dataset_file = "$PSScriptRoot/processed_dataset_phones.json"

Write-Output "Deleting Existing..."
curl.exe '-X', 'DELETE', "$url/$db_name"
Write-Output "Creating New..."
curl.exe '-X', 'PUT', "$url/$db_name"

Write-Output "Uploading Dataset..."
curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'POST', "$url/$db_name/_bulk_docs", '-d', "@$dataset_file" | Out-Null

Write-Output "`n----------------------------- DB Setup Complete! -----------------------------`n"
Write-Output "------------------------- http://127.0.0.1:5984/_utils ------------------------`n"