param(
    [string]$RequestBody
)

try {
    # Get the connection string from environment variables
    $connectionString = $env:AzureWebJobsStorage

    # Create a storage account context
    $storageAccount = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse($connectionString)
    $tableClient = $storageAccount.CreateCloudTableClient()
    $table = $tableClient.GetTableReference("LogTable")
    $table.CreateIfNotExists()

    # Parse the request body and create a log entry object
    $logEntry = [PSCustomObject]@{
        PartitionKey = "LogEntry"
        RowKey = [Guid]::NewGuid().ToString()
        datetime = [DateTime]::UtcNow.ToString("o")
        severity = ($RequestBody | ConvertFrom-Json).severity
        message = ($RequestBody | ConvertFrom-Json).message
    }

    # Insert the log entry into the table
    $insertOperation = [Microsoft.Azure.Cosmos.Table.TableOperation]::Insert($logEntry)
    $table.Execute($insertOperation)

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