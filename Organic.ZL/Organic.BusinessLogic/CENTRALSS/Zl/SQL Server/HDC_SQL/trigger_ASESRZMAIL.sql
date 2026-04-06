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
	,@ACCMAIL AS INT
	,@ALTA AS INT;
	
	
	SELECT 
		@USUARIO = EMAIL 
		,@CLAVE = ZL.CONTACTOS.Apellido
		,@ACCMAIL = ACCMAIL
		,@ALTA = ACCION
	FROM 
		INSERTED
		LEFT JOIN ZL.CONTACTOS on ZL.CONTACTOS.Mail = INSERTED.EMAIL 

	IF @ACCMAIL = 8 and @ALTA = 1
		BEGIN

			SET @Estilo = (SELECT TOP 1 Htmlcod FROM [ZL].[FACTURACION].[EstiloMail] WHERE id = 1)

			SELECT TOP 1 @Asunto = [asuntoMail], @Cuerpo = [bodyMail] FROM [ZL].[FACTURACION].[FormatoMail] WHERE id = 18
			
			SET @BodyTmp = replace( @Cuerpo, '[[USUARIO]]', LTRIM(RTRIM(@USUARIO)) );
			SET @BodyTmp = replace( @BodyTmp, '[[CLAVE]]',  lower(REPLACE ( @CLAVE,' ','')));
			SET @BodyTmp = @Estilo + @BodyTmp;

			set @USUARIO = @USUARIO + ';cel@zoologic.com.ar'

			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'DyC'
			,@recipients = @USUARIO 
			,@copy_recipients = '' 
			,@blind_copy_recipients = ''
			,@body = @BodyTmp  
			,@subject = @Asunto 
			,@body_format = 'HTML' 
			,@mailitem_id = @nromail OUTPUT ;
		END
END

GO
