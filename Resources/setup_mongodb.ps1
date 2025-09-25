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

$setup_file = "$PSScriptRoot/setup_mongodb.js"

Invoke-Expression "$Env:MONGOSH_PATH -f $setup_file"