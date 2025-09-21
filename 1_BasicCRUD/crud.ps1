# Simple function that returns the value corresponding to '$key' in $json
function Get-Value {
    param ( [string]$json, [string]$key )
    
    (($json.Trim('{}') -split ',' | Where-Object { $_ -like "`"$key`"*" }) -split ':')[1].Trim('"')     
}

$user = Read-Host 'Enter username:'
$pass = Read-Host 'Enter password:'

$url = "http://${user}:${pass}@127.0.0.1:5984/"

$db_name = 'phones'

# GET
Write-Output "`n`t`GET all rows in the database:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/_all_docs" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."

$brand_id = 'MyBrandId'
$post_json_file = 'post.json'

# POST
Write-Output "`n`t`POST a new brand with devices:`n"
$post_result = curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'POST', "$url/phones/", '-d', "@$post_json_file"
Write-Output "$post_result"

$post_result_id = Get-Value $post_result 'id'
$post_result_rev = Get-Value $post_result 'rev'

Write-Output "`n`tGET the newly created brand:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/$post_result_id"

$put_json_file = 'put.json'

# PUT
Write-Output "`n`tPUT an update of the newly created brand:`n"
$put_result = curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'PUT', "$url/phones/$post_result_id`?rev=$post_result_rev", '-d', "@$put_json_file"
Write-Output "$put_result"

Write-Output "`n`tGET the newly updated brand:`n"
curl.exe '-s', '-X', 'GET', "$url/phones/$post_result_id"

$put_result_rev = Get-Value $put_result 'rev'

# DELETE

Write-Output "`n`tDELETE MyBrand document:`n"
curl.exe '-s', '-X', 'DELETE', "$url/phones/$post_result_id`?rev=$put_result_rev"