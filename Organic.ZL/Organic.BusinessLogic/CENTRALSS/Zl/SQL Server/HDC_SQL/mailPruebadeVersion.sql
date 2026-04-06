/******************************************************************************
                           PARA EJECUTAR ESTE STP: 
                      
                      EXEC ZL.stp_mailpruebadeversion 2
                    
                    SIENDO 2 EL NUMERO DE PRUEBA DE VERSION
******************************************************************************/
USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[stp_mailPruebadeVersion]    Script Date: 01/22/2013 11:03:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[stp_mailPruebadeVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[stp_mailPruebadeVersion]
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[stp_mailPruebadeVersion]    Script Date: 01/22/2013 11:03:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Héctor Daniel Correa
-- Create date: 21/01/2013
-- Description:	STP para el envío de mails de la entidad Prueba de Versión
-- =============================================
CREATE PROCEDURE [ZL].[stp_mailPruebadeVersion]
	@NumPruebaVersion INT = 0 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@recipients AS VARCHAR(100)
		,@blind_copy_recipients AS VARCHAR(50)
		,@body AS VARCHAR(5000) 
		,@Asunto AS VARCHAR(150) 
		,@body_format AS VARCHAR(50) 
		,@mailitem_id AS INT
		,@Estilo AS VARCHAR(MAX)
		,@Cuerpo AS VARCHAR(MAX)
		,@BodyTmp AS VARCHAR(MAX)
		,@PRODUCTO AS VARCHAR(50) 
		,@FUNCIONALIDAD AS VARCHAR(50) 
		,@ESTADO AS VARCHAR(50) 
		,@HISTORIA AS VARCHAR(150) 
		,@TITULO AS VARCHAR(250) 
		,@USUARIO AS VARCHAR(50) 
		,@PROPIETARIO AS VARCHAR(50) 
		,@CORREO AS VARCHAR(50) 
		,@nromail AS INT
		,@ULTIMOUSUARIO AS VARCHAR(50)
		,@TOTALREGISTROS AS INT
		,@CONTADOR AS INT
		,@RUTAEXE AS VARCHAR(500)
		,@LINKREPORTE AS VARCHAR(500)
		,@FILA AS INT
		,@PAR AS INT
		,@EQUIPO AS VARCHAR(40)
		,@FECHAACEPTACION AS VARCHAR(8);
	
	-------- /* estilos html */
	SET @Estilo = (SELECT TOP 1 Htmlcod FROM [ZL].[FACTURACION].[EstiloMail] WHERE id = 1);
	SELECT TOP 1 @Asunto = '', @Cuerpo = '' FROM [ZL].[FACTURACION].[FormatoMail] WHERE id = 17; --?????????????
	SET @Asunto = 'Avisos ZL - Prueba de Versión';
	
	DECLARE DESTINOS CURSOR FOR 
		SELECT 
			RTRIM(ZL.DETHISTPRU.PROPIET) AS [USUARIO]
			,LOWER(LTRIM(RTRIM(ZL.DETHISTPRU.PROPIET)))+'@zoologic.com.ar' AS [CORREO]
			,LOWER(LTRIM(RTRIM(ZL.PRUVER.RUTEXE))) AS [RUTAEXE]
		FROM 
			ZL.PRUVER
			LEFT JOIN ZL.DETHISTPRU ON ZL.DETHISTPRU.CODINT = ZL.PRUVER.NUM
		WHERE 
			ZL.PRUVER.NUM = @NumPruebaVersion
		GROUP BY
			ZL.DETHISTPRU.PROPIET
			,ZL.PRUVER.RUTEXE
		ORDER BY
			ZL.DETHISTPRU.PROPIET;

	OPEN DESTINOS;
	FETCH NEXT FROM DESTINOS INTO @USUARIO, @CORREO, @RUTAEXE;
	WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE GRILLA CURSOR FOR
			SELECT 
				RTRIM(ZL.Prodzl.Descr) AS [PRODUCTO]
				,CASE ZL.DETHISTPRU.BUG
					WHEN 0 THEN 'http://reportes/_layouts/ReportServer/RSViewerPage.aspx?rv:RelativeReportUrl=/Reportes/IyD/Gestion/Funcionalidad.rdl&rp:Funcionalidad='+CONVERT(VARCHAR, ZL.DETHISTPRU.CODIGO)
					ELSE 'http://reportes/_layouts/ReportServer/RSViewerPage.aspx?rv:RelativeReportUrl=/Reportes/IyD/Gestion/Bug.rdl&rp:Bug='+CONVERT(VARCHAR, ZL.DETHISTPRU.BUG)
				END AS [LINKREPORTE]
				,CASE ZL.DETHISTPRU.BUG
					WHEN 0 THEN ZL.DETHISTPRU.CODIGO
					ELSE ZL.DETHISTPRU.BUG
				END AS [FUNCIONALIDAD]
				,RTRIM(ZL.ESTPRUVER.DESCR) AS [ESTADO]
				,CONVERT(VARCHAR, ZL.DETHISTPRU.HISTID) + ' ' + RTRIM(ZL.DETHISTPRU.HISDES) AS [HISTORIA]
				,RTRIM(LTRIM(ZL.DETHISTPRU.NOMBRE)) AS [TITULO]
				,RTRIM(ZL.DETHISTPRU.PROPIET) AS [PROPIETARIO]
				,CONVERT(VARCHAR(8), ZL.DETHISTPRU.FECHAAC, 3) AS [FECHAACEPTACION]
				,RTRIM(ZL.DETHISTPRU.PROYD) AS [EQUIPO]
			FROM 
				ZL.PRUVER
				LEFT JOIN ZL.DETHISTPRU ON ZL.DETHISTPRU.CODINT = ZL.PRUVER.NUM
				LEFT JOIN ZL.RPRUVER ON ZL.RPRUVER.NUMPRV = ZL.PRUVER.NUM 
				LEFT JOIN ZL.Prodzl ON ZL.Prodzl.Ccod = ZL.PRUVER.PROD
				LEFT JOIN ZL.ESTPRUVER ON ZL.ESTPRUVER.COD = ZL.DETHISTPRU.ESTADOPRUE 
			WHERE 
				ZL.PRUVER.NUM = @NumPruebaVersion
			ORDER BY
				ZL.DETHISTPRU.PROPIET
				,ZL.DETHISTPRU.CODIGO;
			OPEN GRILLA;
			FETCH NEXT FROM GRILLA INTO @PRODUCTO, @LINKREPORTE, @FUNCIONALIDAD ,@ESTADO ,@HISTORIA ,@TITULO ,@PROPIETARIO, @FECHAACEPTACION, @EQUIPO;
			SET @Cuerpo = '<body>';
			SET @Cuerpo = @Cuerpo + '    <p class="style1">';
			SET @Cuerpo = @Cuerpo + '      Instalar o Actualizar EXCLUSIVAMENTE desde este <a href="' + @RUTAEXE + '">link</a>';
			SET @Cuerpo = @Cuerpo + '    </p>';
			SET @Cuerpo = @Cuerpo + '    <p class="style1">';
			SET @Cuerpo = @Cuerpo + '      Responder ítem por ítem exclusivamente con un OK, Mal o No aplica.'
			SET @Cuerpo = @Cuerpo + '    </p>';
			SET @Cuerpo = @Cuerpo + '    <p class="style1">';
			SET @Cuerpo = @Cuerpo + '      Prueba de Versi&oacute;n N&deg;: ' + CAST(@NumPruebaVersion AS VARCHAR(10));
			SET @Cuerpo = @Cuerpo + '    </p>';
			SET @Cuerpo = @Cuerpo + '    <table class="tabla">';
			SET @Cuerpo = @Cuerpo + '         <tr>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Producto';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Func/Bug';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Estado';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Historia';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Nombre/T&iacute;tulo';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Aceptaci&oacute;n';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Propietario';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '           <th>';
			SET @Cuerpo = @Cuerpo + '             Equipo';
			SET @Cuerpo = @Cuerpo + '           </th>';
			SET @Cuerpo = @Cuerpo + '         </tr>';
			SET @FILA = 1;
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @PAR = @FILA % 2;
					IF @PAR = 0
						BEGIN
							SET @Cuerpo = @Cuerpo + '         <tr class="impar">';
						END
					ELSE
						BEGIN 
							SET @Cuerpo = @Cuerpo + '         <tr class="par">';
						END
					SET @FILA = @FILA + 1;
					SET @Cuerpo = @Cuerpo + '           <td>';
					SET @Cuerpo = @Cuerpo + '             '+ @PRODUCTO;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td style="text-align: center;">';
					SET @Cuerpo = @Cuerpo + '			  <a href="' + @LINKREPORTE + '">' + @FUNCIONALIDAD + '</a>';
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td>';
					SET @Cuerpo = @Cuerpo + '             '+ @ESTADO;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td>';
					SET @Cuerpo = @Cuerpo + '             '+ @HISTORIA;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td>';
					SET @Cuerpo = @Cuerpo + '             '+ @TITULO;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td style="text-align: center;">';
					SET @Cuerpo = @Cuerpo + '             '+ @FECHAACEPTACION;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td>';
					SET @Cuerpo = @Cuerpo + '             '+ @PROPIETARIO;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '           <td>';
					SET @Cuerpo = @Cuerpo + '             '+ @EQUIPO;
					SET @Cuerpo = @Cuerpo + '           </td>';
					SET @Cuerpo = @Cuerpo + '         </tr>';
					FETCH NEXT FROM GRILLA INTO @PRODUCTO, @LINKREPORTE, @FUNCIONALIDAD ,@ESTADO ,@HISTORIA ,@TITULO ,@PROPIETARIO, @FECHAACEPTACION, @EQUIPO;
				END
			SET @Cuerpo = @Cuerpo + '       </table>';
			SET @Cuerpo = @Cuerpo + '</body>';
			SET @BodyTmp = @Estilo + @Cuerpo;

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'ZL Avisos'
				,@recipients = 'hcorrea@zoologic.com.ar'
				--,@recipients = @CORREO  
				--;flicciardi@zoologic.com.ar
				,@copy_recipients = '' 
				,@blind_copy_recipients = ''
				,@body = @BodyTmp  
				,@subject = @Asunto 
				,@body_format = 'HTML' 
				,@mailitem_id = @nromail OUTPUT;
			--SELECT @BodyTmp;
			CLOSE GRILLA;
			DEALLOCATE GRILLA;

			FETCH NEXT FROM DESTINOS INTO @USUARIO ,@CORREO, @RUTAEXE;
		END	
	CLOSE DESTINOS;
	DEALLOCATE DESTINOS;

END
GO


