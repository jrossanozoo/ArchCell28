USE [ZL]
GO

/****** Object:  Trigger [mailAvisoReqDyC]    Script Date: 01/15/2013 11:11:47 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[ZL].[mailAvisoReqDyC]'))
DROP TRIGGER [ZL].[mailAvisoReqDyC]
GO

USE [ZL]
GO

/****** Object:  Trigger [ZL].[mailAvisoReqDyC]    Script Date: 01/15/2013 11:11:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Daniel Correa
-- Create date: 14/01/2013
-- Description:	Trigger que dispara un mail cuando se de
--              alta un requerimiento para DyC
-- =============================================
CREATE TRIGGER [ZL].[mailAvisoReqDyC] 
   ON  [ZL].[DYCREQ] 
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE @Estilo AS VARCHAR(MAX)
	,@Cuerpo AS VARCHAR(MAX)
	,@Asunto AS VARCHAR(MAX)
	,@nromail AS INT
	
	DECLARE	@Numero   AS VARCHAR(10)
		,@Titulo      AS VARCHAR(250)
		,@Solicitante AS VARCHAR(30)
		,@Cliente     AS VARCHAR(50)
		,@Prioridad   AS VARCHAR(10)
		,@Producto    AS VARCHAR(50)
		,@Categoria   AS VARCHAR(20)
		,@Correo      AS VARCHAR(150);
		
	select 
		@Numero = CAST(INSERTED.CODIN AS VARCHAR(10))
		,@Titulo = RTRIM(ISNULL(INSERTED.ASUNTO, ''))
		,@Solicitante = RTRIM(INSERTED.SOLIC)
		,@Cliente = RTRIM(ZL.Clientes.Cmpnombre)
		,@Prioridad = CASE ISNULL(INSERTED.PRIORIDAD, '')
			WHEN 1 THEN 'Alta'
			WHEN 2 THEN 'Media'
			WHEN 3 THEN 'Baja'
			ELSE 'Baja'
		END
		,@Producto = RTRIM(ZL.Prodzl.Descr)
		,@Categoria = RTRIM(ISNULL(ZL.DYCCATREQ.CDESC, ''))
	from 
		INSERTED
		LEFT JOIN ZL.Clientes ON ZL.Clientes.Cmpcodigo = INSERTED.CCLIENTE
		LEFT JOIN ZL.Prodzl ON ZL.Prodzl.Ccod = INSERTED.CPCOD
		LEFT JOIN ZL.DYCCATREQ ON ZL.DYCCATREQ.CCOD = INSERTED.CATEGORIA 
	
		SET @Estilo = (SELECT TOP 1 Htmlcod FROM [ZL].[FACTURACION].[EstiloMail] WHERE id = 1);

		SET @Asunto = 'Avisos ZL - Nuevo Requerimiento para DyC - Prioridad: ' + @Prioridad;
		SET @Cuerpo =           '<p class="style1">';
		SET @Cuerpo = @Cuerpo + '	Solicitante: '+@Solicitante+'<br />';
		SET @Cuerpo = @Cuerpo + '	Solicitud N&deg;: '+@Numero+'<br />';
		SET @Cuerpo = @Cuerpo + '	T&iacute;tulo: '+@Titulo+'<br />';
		SET @Cuerpo = @Cuerpo + '	Categor&iacute;a: '+@Categoria+'<br />';
		SET @Cuerpo = @Cuerpo + '	Cliente: '+@Cliente+'<br />';
		SET @Cuerpo = @Cuerpo + '	Producto: '+@Producto+'<br />';
		SET @Cuerpo = @Cuerpo + '</p>';
		SET @Cuerpo = @Cuerpo + '<p class="style1">';
		SET @Cuerpo = @Cuerpo + '	&nbsp;';
		SET @Cuerpo = @Cuerpo + '</p>';
		
		SET @Correo = 'cel@zoologic.com.ar';
		SET @Correo = 'hcorrea@zoologic.com.ar';
		SET @Cuerpo = @Estilo + @Cuerpo;
		
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'mesadeayuda'
		,@recipients = @Correo
		,@copy_recipients = '' 
		,@blind_copy_recipients = ''
		,@body = @Cuerpo  
		,@subject = @Asunto 
		,@body_format = 'HTML' 
		,@mailitem_id = @nromail OUTPUT ;
		
END




GO


