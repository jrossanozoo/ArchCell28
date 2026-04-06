/*
-- Enable CLR Integration
sp_configure 'clr enable', 1
GO
RECONFIGURE
GO

USE [ZL_DM]
GO

-- Set TRUSTWORTHY database's option ON
ALTER DATABASE ZL_DM SET TRUSTWORTHY ON
GO

ALTER AUTHORIZATION ON DATABASE::[ZL_DM] TO sa
GO
*/

-- Add assembly
-- remember to set the path to SqlMSMQ.dll correctly

CREATE ASSEMBLY ZLMSQ
AUTHORIZATION dbo
FROM 'C:\ZZZ\ZooLogicSA.ZL.SqlMessageQueue.dll'
WITH PERMISSION_SET = UNSAFE
GO

-- Create procedures
CREATE PROCEDURE [ZL].EnviarSentenciaAColaDeMensaje
@queue  nvarchar(200),
@msg    nvarchar(MAX)
AS EXTERNAL NAME ZLMSQ.[ZooLogicSA.ZL.SqlMessageQueue.SqlMessageQueue].Send
GO

CREATE PROCEDURE [ZL].LeerSentenciaDeColaDeMensaje
@queue  nvarchar(200),
@msg    nvarchar(MAX) OUTPUT
AS EXTERNAL NAME ZLMSQ.[ZooLogicSA.ZL.SqlMessageQueue.SqlMessageQueue].Peek
GO

CREATE PROCEDURE [ZL].EjecutarSentenciaDeColaDeMensaje
@queue  nvarchar(200),
@msg    nvarchar(MAX) OUTPUT
AS EXTERNAL NAME ZLMSQ.[ZooLogicSA.ZL.SqlMessageQueue.SqlMessageQueue].Receive
GO


/*
-- Uncomment this to test ZLMSQ
Declare @lcString nvarchar(1024)
Set @lcString = 'MENSAJE NUEVO AL IVR'
EXEC [ZL].[EnviarSentenciaAColaDeMensaje] 'server03\PublicQueue', @lcString
GO


DECLARE @text nvarchar(1024)
EXEC [ZL].[LeerSentenciaDeColaDeMensaje] 'server03\PublicQueue', @msg = @text OUTPUT
Select @text
GO


DECLARE @text nvarchar(1024)
EXEC [ZL].[LeerSentenciaDeColaDeMensaje] 'server03\PublicQueue', @msg = @text OUTPUT
Select @text
GO

DECLARE @text nvarchar(1024)
EXEC [ZL].[LeerSentenciaDeColaDeMensaje] 'zlcopsiis01\PublicQueue', @msg = @text OUTPUT
Select @text
GO




DECLARE @text nvarchar(1024), @lcSQL nvarchar(1024)
EXEC [ZL].[EjecutarSentenciaDeColaDeMensaje] 'server03\PublicQueue', @msg = @text OUTPUT
Select @text
Set @lcSQL = @text
exec ( @lcSql )
go 




/*
-- Run this after rebuilding assembly 
ALTER ASSEMBLY ZLMSQ
FROM 'C:\ZZZ\ZooLogicSA.ZL.SqlMessageQueue.dll'
WITH PERMISSION_SET = UNSAFE
*/


/*
-- Remove procedures and SqlMSMQ from database

drop procedure [ZL].EjecutarSentenciaDeColaDeMensaje
go
drop procedure [ZL].LeerSentenciaDeColaDeMensaje
go
drop Procedure [ZL].EnviarSentenciaAColaDeMensaje
go
DROP ASSEMBLY ZLMSQ
GO
*/



Select *
from zl.regcoddesact


USE msdb 
go 
EXEC sp_start_job @job_name = 'PublicQueueReader'
