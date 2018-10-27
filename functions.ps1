#-[Start Functions ]------------------------------------------------------
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value ((Get-Date -format yyyy-MM-dd_HH-mm-ss) + ": " + $logstring)
   Write-Host ((Get-Date -format yyyy-MM-dd_HH-mm-ss) + ": " + $logstring);
}
function IsNullOrEmpty($str) {if ($str) {"String is not empty"} else {"String is null or empty"}}

function exec-query( $sql,$parameters=@{},$conn,$timeout=60,[switch]$help){
    if ($help){
        $msg = @"
Execute a sql statement.  Parameters are allowed.
Input parameters should be a dictionary of parameter names and values.
Return value will usually be a list of datarows.
"@
    Write-Host $msg
    return
 }
     try {
     $cmd=new-object system.Data.SqlClient.SqlCommand($sql,$conn)
     $cmd.CommandTimeout=$timeout
     foreach($p in $parameters.Keys){
        [Void] $cmd.Parameters.AddWithValue("@$p",$parameters[$p])
     }
     $ds=New-Object system.Data.DataSet
     $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
     $da.fill($ds) | Out-Null
     }
     catch {
        $_.Exception|format-list -force
        $ds = $null
    }
	return $ds
}

function exec-scalar($sql, $conn, $timeout=60) {

    try {
        $sqlCommand = New-Object system.Data.sqlclient.SqlCommand($sql,$conn)
        $value = $sqlCommand.ExecuteScalar()
        $sqlCommand.Dispose()
    }
    catch {
        $_.Exception|format-list -force
        $value = $null
    }
    return $value
}

function exec-nonquery($sql, $conn, $timeout=60) {

    try {
    $sqlCommand = New-Object system.Data.sqlclient.SqlCommand($sql,$conn)
    $sqlCommand.ExecuteNonQuery()
    $sqlCommand.Dispose()
    }
    catch {
        $_.Exception|format-list -force
        $value = $false
    }
    return $true
}

#-[End Functions ]--------------------------------------------------------

#-[Log Examples ]---------------------------------------------------------
if (!(Test-Path -path "$CL\logs")) {
    New-Item "$CL\logs" -type directory
}
$filedate = (Get-Date -format yyyyMMdd)
$Logfile = "$CL\logs\Mylogfile_" + $filedate + ".log"

# Then
LogWrite("My Log Message.");


#-[DB Examples ]---------------------------------------------------------
$Conn = New-Object System.Data.SqlClient.SqlConnection
$Conn.ConnectionString = "Data Source=<<SERVER>>;Database=<<DATEBASE>>;Trusted_Connection=True;Connection Timeout=60;"
#$ErrorActionPreference = "SilentlyContinue"
$Conn.open()
$querySQL = "SELECT * FROM DBAssignments"

$servers = exec-query -sql $querySQL -conn $Conn

if($servers.Tables[0].rows.count -gt 0) {
    foreach ($server in $servers.Tables[0]) {
		$col1 = $server.col1
		$col2 = $server.col2
	}
	
}	

$Conn.Close()