#
# DeploySqlAw2016.ps1
#
# Parameters

# Variables
$targetDirectory = "C:\SQL2016Demo"
$adventrueWorks2016DownloadLocation = "https://sql2016demoaddeploy.blob.core.windows.net/adventureworks2016/AdventureWorks2016CTP3.zip"

# Create Folder Structure
if(!(Test-Path -Path $targetDirectory)){
	New-Item -ItemType Directory -Force -Path $targetDirectory
	}
if(!(Test-Path -Path $targetDirectory\adventureWorks2016CTP3)){
	New-Item -ItemType Directory -Force -Path $targetDirectory\adventureWorks2016CTP3
	}
# Download the SQL Server 2016 CTP 3.3 AdventureWorks database files.  
Set-Location $targetDirectory
Invoke-WebRequest -Uri $adventrueWorks2016DownloadLocation -OutFile $targetDirectory\AdventureWorks2016CTP3.zip

# Create a function to expand zip files
function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item)
}
}

# Expand the downloaded files
Expand-ZIPFile -file $targetDirectory\AdventureWorks2016CTP3.zip -destination $targetDirectory\adventureWorks2016CTP3
Expand-ZIPFile -file $targetDirectory\adventureWorks2016CTP3\SQLServer2016CTP3Samples.zip -destination $targetDirectory\adventureWorks2016CTP3

# Copy backup files to Default SQL Backup Folder
Copy-Item -Path $targetDirectory\AdventureWorks2016CTP3\*.bak -Destination "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup"

# Restore SQL Backups for AdventureWorks and AdventrueWorksDW
Import-Module SQLPS -DisableNameChecking
cd \sql\localhost\

Invoke-Sqlcmd -Query "USE [master]
RESTORE DATABASE [AdventureWorks2016CTP3] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorks2016CTP3.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2016CTP3_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks2016CTP3_Data.mdf',  MOVE N'AdventureWorks2016CTP3_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks2016CTP3_Log.ldf',  MOVE N'AdventureWorks2016CTP3_mod' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks2016CTP3_mod',  NOUNLOAD,  REPLACE,  STATS = 5

GO" -ServerInstance LOCALHOST -QueryTimeout 0

Invoke-Sqlcmd -Query "USE [master]
	RESTORE DATABASE [AdventureworksDW2016CTP3] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorksDW2016CTP3.bak' WITH  FILE = 1,  MOVE N'AdventureWorksDW2014_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2016CTP3_Data.mdf',  MOVE N'AdventureWorksDW2014_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2016CTP3_Log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

	GO" -ServerInstance LOCALHOST -QueryTimeout 0
