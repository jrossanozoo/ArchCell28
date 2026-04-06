USE [ZL]
GO


update [ZL].[FACTURACION].[EstiloMail] set Htmlcod =
'      <style type="text/css">
        .Encabezado {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 9pt;
        }
        .style1 {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 9pt;
        }
        .ZooLogic {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 9pt;
          color: #009933;
          font-weight: bold;
        }
        table.tabla {
          font-family: verdana, Arial;
          font-size:8pt;
          border-width: 1px 1px 1px 1px;
          border-spacing: 0px;
          border-style: solid solid solid solid;
          border-color: rgb(0, 153, 51) rgb(0, 153, 51) rgb(0, 153, 51) rgb(0, 153, 51);
          border-collapse: collapse;
          background-color: transparent;
        }
        table.tabla th {
          border:1px solid white;
          background-color:#009933;
          color:#FFFFFF;
          padding:3px
        }
        .par {
			background-color: #FFFFFF;
        }
        .impar {
			background-color: #CCCCCC;
        }
        table.tabla td {
          border-width: 1px 1px 1px 1px;
          padding: 3px;
          border-style: solid solid solid solid;
          border-color: #009933;
          background-color: transparent;
        }
        .concepto {
          background-color: #009933;
          color: #FFFFFF;
          font-weight: bold;
          background-color: #009933;
          color: #FFFFFF;
        }
        .nrofactura {
          font-family: verdana, Arial;
          font-size:11pt;
        }
      </style>
' WHERE id = 1;

DELETE FROM [ZL].[FACTURACION].[FormatoMail] WHERE [ZL].[FACTURACION].[FormatoMail].id = 18;

insert into [ZL].[FACTURACION].[FormatoMail]
([id], [Descrip], [asuntoMail], [bodyMail])
values
(
18,
'Confirmación de inscripción',
'Zoo Logic - Confirmación de inscripción', 
'
    <p class="style1">
      Estimado Cliente,
    </p>
    <p class="style1">
      por medio del presente mensaje le confirmamos la creaci&oacute;n de su nuevo 
      usuario para acceder al Campus Virtual de capacitaci&oacute;n de Zoo Logic:
    </p>
    <p class="style1">
      Usuario: [[USUARIO]]<br />
      Contrase&ntilde;a: [[CLAVE]]
    </p>
    <p class="style1">
      La contrase&ntilde;a podr&aacute; ser modificada luego de realizar el primer 
      ingreso al campus.
    </p>
    <p class="style1">
      Le recordamos que la direcci&oacute;n para acceder al Campus Virtual es 
      <a href="http://campus.zoologic.com.ar">http://campus.zoologic.com.ar</a><br>
      Descargue el manual de introducci&oacute;n al Campus haciendo click 
      <a href="http://campus.zoologic.com.ar/introcampus.pdf">aqu&iacute;</a>.
    </p>
    <p class="style1">
      Atentamente, el equipo de Documentaci&oacute;n y Capacitaci&oacute;n
    </p>
    <p class="style1">
      <img src="http://pbx01/Web%20Zoologic/aspcodes/capacitacion.jpg" border="0" />
    </p>
    <p class="style1">
    </p>
');

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
			@profile_name = 'ZL Avisos'
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


