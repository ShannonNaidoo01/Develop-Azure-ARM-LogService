try {
    $storageAccount = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse("<connection-string>")
    $tableClient = $storageAccount.CreateCloudTableClient()
    $table = $tableClient.GetTableReference("LogTable")

    $query = New-Object Microsoft.Azure.Cosmos.Table.TableQuery
    $query.FilterString = "PartitionKey eq 'LogEntry'"
    $logEntries = $table.ExecuteQuery($query)

    $sortedLogEntries = $logEntries | Sort-Object -Property datetime -Descending | Select-Object -First 100

    return @{
        statusCode = 200
        body = ($sortedLogEntries | ConvertTo-Json)
    }
}
catch {
    Write-Error $_.Exception.Message
    return @{
        statusCode = 500
        body = "Error retrieving log entries."
    }
}
