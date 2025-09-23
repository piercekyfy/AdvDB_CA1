$mongosh = '../mongosh/bin/mongosh.exe'

$setup_file = 'setup_mongodb.js'

Invoke-Expression "$mongosh -f $setup_file"