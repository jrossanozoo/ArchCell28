USE [ZL]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AudiModPro]') AND type in (N'U'))
	DROP TABLE [ZL].[AudiModPro]

create table [ZL].[AudiModPro] ( 
	fecha datetime, 
	usuario sysname not null, 
	procFunc sysname not null, 
	comando varchar( max ), 
	hostname sysname, 
	tipo_evento varchar( 255 ) )
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE name = N'auditoriaZLschemma' AND parent_class=0)
	DROP TRIGGER [auditoriaZLschemma] ON DATABASE
go

create trigger 
auditoriaZLschemma on database for CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION
as 
declare @eventData xml
set @eventData = eventdata()

INSERT [ZL].[AudiModPro] ( fecha, usuario, procFunc, comando, hostname, tipo_evento )
  SELECT 
	GETDATE() AS fecha,
	suser_sname() AS usuario,
    @eventData.value( 'data(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME' ) 
		as proceso,
    @eventData.value( 'data(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'VARCHAR(MAX)' ) 
		as comando,
	host_name() as hostname,
    @eventData.value( 'data(/EVENT_INSTANCE/EventType)[1]', 'varchar(255)' ) 
		as evento

--declare @body1 varchar(100)
--set @body1 = 'Server : ' + @@servername+ ' te envía su primer mail de prueba, puto'
--EXEC msdb.dbo.sp_send_dbmail @recipients='jbarrionuevo@zoologic.com.ar',
--    @subject = 'SQL Server te la hace sentir',
--    @body = @body1,
--    @body_format = 'HTML',
--	@profile_name ='Perfil' ;

go