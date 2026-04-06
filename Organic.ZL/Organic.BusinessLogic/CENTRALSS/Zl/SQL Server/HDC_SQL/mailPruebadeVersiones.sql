USE [ZL]
GO

/****** Object:  Trigger [mailUsuarioCampusVirtual]    Script Date: 01/03/2013 09:34:58 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[ZL].[mailUsuarioCampusVirtual]'))
DROP TRIGGER [ZL].[mailUsuarioCampusVirtual]
GO

USE [ZL]
GO

/****** Object:  Trigger [ZL].[mailUsuarioCampusVirtual]    Script Date: 01/03/2013 09:34:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Correa
-- Create date: 03/01/2013
-- Description:	Trigger que dispara un mail para insert cuando se asigna
--              Usuario de campus virtual como acción de mail
-- =============================================
CREATE TRIGGER [ZL].[mailUsuarioCampusVirtual] 
   ON  [ZL].[ASESRZMAIL] 
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE @USUARIO AS VARCHAR(150)
	,@CLAVE AS VARCHAR(150)
	,@Estilo AS VARCHAR(MAX)
	,@BodyTmp AS VARCHAR(MAX)
	,@Cuerpo AS VARCHAR(MAX)
	,@Asunto AS VARCHAR(MAX)
	,@nromail AS INT
	,@ACCMAIL AS INT;
	
	SELECT 
		@USUARIO = EMAIL 
		,@CLAVE = ZL.CONTACTOS.Apellido
		,@ACCMAIL = ACCMAIL
	FROM 
		INSERTED
		LEFT JOIN ZL.CONTACTOS on ZL.CONTACTOS.Mail = INSERTED.EMAIL 

	IF @ACCMAIL = 8
		BEGIN

			SET @Estilo = (SELECT TOP 1 Htmlcod FROM [ZL].[FACTURACION].[EstiloMail] WHERE id = 1)

			SELECT TOP 1 @Asunto = [asuntoMail], @Cuerpo = [bodyMail] FROM [ZL].[FACTURACION].[FormatoMail] WHERE id = 18
			
			SET @BodyTmp = replace( @Cuerpo, '[[USUARIO]]', LTRIM(RTRIM(@USUARIO)) );
			SET @BodyTmp = replace( @BodyTmp, '[[CLAVE]]', @CLAVE );
			SET @BodyTmp = @Estilo + @BodyTmp;
				
			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'mesadeayuda'
			,@recipients = @USUARIO 
			,@copy_recipients = 'hcorrea@zoologic.com.ar' 
			,@blind_copy_recipients = ''
			,@body = @BodyTmp  
			,@subject = @Asunto 
			,@body_format = 'HTML' 
			,@mailitem_id = @nromail OUTPUT ;
		END
END

GO


