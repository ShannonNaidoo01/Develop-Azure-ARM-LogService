try {
    # Get the connection string from environment variables
    $connectionString = $env:AzureWebJobsStorage

    # Create a storage account context
    $storageAccount = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse($connectionString)
    $tableClient = $storageAccount.CreateCloudTableClient()
    $table = $tableClient.GetTableReference("LogTable")

    # Create the table query
    $query = New-Object Microsoft.Azure.Cosmos.Table.TableQuery
    $query.FilterString = "PartitionKey eq 'LogEntry'"
    $logEntries = $table.ExecuteQuery($query)

    # Sort the log entries by datetime in descending order and select the first 100 entries
    $sortedLogEntries = $logEntries | Sort-Object -Property { [DateTime]::Parse($_.datetime) } -Descending | Select-Object -First 100

    # Return the sorted log entries as JSON
    return @{
        statusCode = 200
        body = ($sortedLogEntries | ConvertTo-Json -Depth 10)
    }
}
catch {
    Write-Error $_.Exception.Message
    return @{
        statusCode = 500
        body = "Error retrieving log entries."
    }
}