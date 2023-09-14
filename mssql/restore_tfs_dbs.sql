USE [master]

-- Restore ReportServer
RESTORE DATABASE [ReportServer]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\ReportServer.bak'
WITH FILE = 1,
MOVE N'ReportServer' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ReportServer.mdf',
MOVE N'ReportServer_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ReportServer_log.ldf',
NOUNLOAD, STATS = 5
GO

-- Restore ReportServerTempDB
RESTORE DATABASE [ReportServerTempDB]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\ReportServerTempDB.bak'
WITH FILE = 1,
MOVE N'ReportServerTempDB' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ReportServerTempDB.mdf',
MOVE N'ReportServerTempDB_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ReportServerTempDB_log.ldf',
NOUNLOAD, STATS = 5
GO

-- Restore Tfs_Configuration
RESTORE DATABASE [Tfs_Configuration]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Tfs_Configuration.bak'
WITH FILE = 1,
MOVE N'Tfs_Configuration' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Tfs_Configuration.mdf',
MOVE N'Tfs_Configuration_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Tfs_Configuration_log.ldf',
NOUNLOAD, STATS = 5
GO

-- Restore Tfs_DefaultCollection
RESTORE DATABASE [Tfs_DefaultCollection]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Tfs_DefaultCollection.bak'
WITH FILE = 1,
MOVE N'Tfs_DefaultCollection' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Tfs_DefaultCollection.mdf',
MOVE N'Tfs_DefaultCollection_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Tfs_DefaultCollection_log.ldf',
NOUNLOAD, STATS = 5
GO

-- Restore Tfs_Warehouse
RESTORE DATABASE [Tfs_Warehouse]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Tfs_Warehouse.bak'
WITH FILE = 1,
MOVE N'Tfs_Warehouse' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Tfs_Warehouse.mdf',
MOVE N'Tfs_Warehouse_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Tfs_Warehouse_log.ldf',
NOUNLOAD, STATS = 5
GO
