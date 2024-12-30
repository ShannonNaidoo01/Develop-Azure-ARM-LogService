param(
    [Microsoft.AspNetCore.Http.HttpRequest] $req
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

    # Create the table query
    $query = New-Object Microsoft.Azure.Cosmos.Table.TableQuery
    $query.FilterString = "PartitionKey eq 'LogEntry'"
    $logEntries = $table.ExecuteQuery($query)
    Write-Output "Log entries retrieved: $($logEntries.Count)"

    # Sort the log entries by datetime in descending order and select the first 100 entries
    $sortedLogEntries = $logEntries | Sort-Object -Property { [DateTime]::Parse($_.datetime) } -Descending | Select-Object -First 100
    Write-Output "Log entries sorted and selected"

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