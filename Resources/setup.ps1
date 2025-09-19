set-executionpolicy remotesigned

$db_name = 'phones'
$dataset_file = 'dataset_phones.json'

$user = Read-Host 'Enter username:'
$pass = Read-Host 'Enter password:'

$url = "http://${user}:${pass}@127.0.0.1:5984/"

echo "Deleting Existing..."
curl.exe '-X', 'DELETE', "$url/$db_name"
echo "Creating New..."
curl.exe '-X', 'PUT', "$url/$db_name"

echo "Uploading Dataset..."
curl.exe '-H', 'Content-Type: application/json', '-X', 'POST', "$url/$db_name/_bulk_docs", '-d', "@$dataset_file" | Out-Null

echo "`n----------------------------- DB Setup Complete! -----------------------------`n"
echo "------------------------- http://127.0.0.1:5984/_utils ------------------------`n"