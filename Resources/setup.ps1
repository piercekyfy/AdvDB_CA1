$user = Read-Host 'Enter username:'
$pass = Read-Host 'Enter password:'

$url = "http://${user}:${pass}@127.0.0.1:5984/"

Write-Output "Performing First Time Configuration..."

curl.exe '-X', 'PUT', "$url/_users"
curl.exe '-X', 'PUT', "$url/_replicator"

$db_name = 'phones'
$dataset_file = 'dataset_phones.json'

Write-Output "Deleting Existing..."
curl.exe '-X', 'DELETE', "$url/$db_name"
Write-Output "Creating New..."
curl.exe '-X', 'PUT', "$url/$db_name"

Write-Output "Uploading Dataset..."
curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'POST', "$url/$db_name/_bulk_docs", '-d', "@$dataset_file" | Out-Null

Write-Output "`n----------------------------- DB Setup Complete! -----------------------------`n"
Write-Output "------------------------- http://127.0.0.1:5984/_utils ------------------------`n"