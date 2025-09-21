$user = Read-Host 'Enter username:'
$pass = Read-Host 'Enter password:'

$url = "http://${user}:${pass}@127.0.0.1:5984/"

$db_name = 'phones'

$brands_views_file = 'brands_views.json'

Write-Output "`n`t`Create brands views:`n"
curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'PUT', "$url/phones/_design/brands", '-d', "@$brands_views_file"

# Find one particular document
Write-Output "`n`t`Find 'Microsoft' document:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_design/brands/_view/all?key=%22Microsoft%22" # Powershell is weird about escaping "" so I manually url encode it to %22 here

# Find range of documents (using a view that returns lower-case brand names only)
Write-Output "`n`t`Find brands from 'A' to 'C' in alphabetical order:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_design/brands/_view/all_lower?startkey=%22a%22&endkey=%22d%22"

# _sum
Write-Output "`n`t`Summation:`n"

Write-Output "`t`Total sum of devices:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_design/brands/_view/by_devices" 

Write-Output "`t`Sum of devices per brand:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_design/brands/_view/by_devices?group=true" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."

# _count
Write-Output "`n`t`Counting:`n"

Write-Output "`t`Count of android devices:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_design/brands/_view/android_devices" 

Write-Output "`t`Count of android devices per brand:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_design/brands/_view/android_devices?group=true" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."