param(
    [string]$RequestBody
)

try {
    Write-Output "Starting function execution"

    # Get the connection string from environment variables
    $connectionString = $env:COSMOS_DB_CONNECTION_STRING
    Write-Output "Connection string retrieved: $connectionString"

    # Create a Cosmos DB account context
    $storageAccount = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse($connectionString)
    $tableClient = $storageAccount.CreateCloudTableClient()
    $table = $tableClient.GetTableReference("LogTable")
    $table.CreateIfNotExists()
    Write-Output "Table reference obtained and table created if not exists"

    # Parse the request body and create a log entry object
    $logEntry = [PSCustomObject]@{
        PartitionKey = "LogEntry"
        RowKey = [Guid]::NewGuid().ToString()
        datetime = [DateTime]::UtcNow.ToString("o")
        severity = ($RequestBody | ConvertFrom-Json).severity
        message = ($RequestBody | ConvertFrom-Json).message
    }
    Write-Output "Log entry created: $($logEntry | ConvertTo-Json)"

    # Insert the log entry into the table
    $insertOperation = [Microsoft.Azure.Cosmos.Table.TableOperation]::Insert($logEntry)
    $table.Execute($insertOperation)
    Write-Output "Log entry inserted"

    return @{
        statusCode = 201
        body = "Log entry created."
    }
}
catch {
    Write-Error $_.Exception.Message
    return @{
        statusCode = 500
        body = "Error creating log entry."
    }
}