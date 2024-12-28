param(
    [string]$RequestBody
)

try {
    $storageAccount = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse("YourConnectionString")
    $tableClient = $storageAccount.CreateCloudTableClient()
    $table = $tableClient.GetTableReference("LogTable")
    $table.CreateIfNotExists()

    $logEntry = [PSCustomObject]@{
        PartitionKey = "LogEntry"
        RowKey = [Guid]::NewGuid().ToString()
        datetime = [DateTime]::UtcNow.ToString("o")
        severity = ($RequestBody | ConvertFrom-Json).severity
        message = ($RequestBody | ConvertFrom-Json).message
    }

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
