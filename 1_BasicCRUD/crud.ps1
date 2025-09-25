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

# Simple function that returns the value corresponding to '$key' in $json
function Get-Value {
    param ( [string]$json, [string]$key )
    
    (($json.Trim('{}') -split ',' | Where-Object { $_ -like "`"$key`"*" }) -split ':')[1].Trim('"')     
}

$url = "http://${ENV:COUCHDB_USER}:${ENV:COUCHDB_PASS}@127.0.0.1:5984/"

$db_name = 'phones'

# GET
Write-Output "`n`t`GET all rows in the database:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/_all_docs" | Select-Object -first 10 | Write-Output
Write-Output "`t`t..."

$post_json_file = "$PSScriptRoot/post.json"

# POST
Write-Output "`n`t`POST a new devices:`n"
$post_result = curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'POST', "$url/$db_name/", '-d', "@$post_json_file"
Write-Output "$post_result"

$post_result_id = Get-Value $post_result 'id'
$post_result_rev = Get-Value $post_result 'rev'

Write-Output "`n`tGET the newly created device:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/$post_result_id"

$put_json_file = "$PSScriptRoot/put.json"

# PUT
Write-Output "`n`tPUT an update of the newly created device:`n"
$put_result = curl.exe '-s', '-H', 'Content-Type: application/json', '-X', 'PUT', "$url/$db_name/$post_result_id`?rev=$post_result_rev", '-d', "@$put_json_file"
Write-Output "$put_result"

Write-Output "`n`tGET the newly updated device:`n"
curl.exe '-s', '-X', 'GET', "$url/$db_name/$post_result_id"

$put_result_rev = Get-Value $put_result 'rev'

# DELETE

Write-Output "`n`tDELETE device document:`n"
curl.exe '-s', '-X', 'DELETE', "$url/$db_name/$post_result_id`?rev=$put_result_rev"