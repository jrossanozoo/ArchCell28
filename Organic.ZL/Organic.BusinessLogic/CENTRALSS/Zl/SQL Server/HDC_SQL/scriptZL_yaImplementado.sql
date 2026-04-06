----------------------------------------------------------------------------------
-- F. 1317
----------------------------------------------------------------------------------
-- Insertar Acciones
declare @NumAsig int
set @NumAsig = ( select max(numero) from zl.ASESRZMAIL )

insert into ZL.ASESRZMAIL 
	( Numero, email, AccMail, DesAccMail, Notas, tipo, accion,FechA, hhssReg, FAltaFW, HAltaFW, UAltaFW, SAltaFW, BDAltaFW )
Select	
	@NumAsig + ROW_NUMBER() over ( ORDER BY email ) numero ,
	M.EMAIL,
	8 as AccMail,
	'Acceso al Campus Virtual'  ,
	'Generado por migración' as Notas ,
	1 as Tipo_Cliente,
	1 as Accion_Tipo_Alta,
	 getdate() FechA,
	 '',
	 getdate() FAltaFW,
	 '',
	 'ATENCIONALCLIENTE' as UAltaFW ,
	 '' as SAltaFW ,
	 'ZL' as BDAltaFW
from zl.DYCUSUCAMP U 
inner join ZL.MAILS M on U.Contacto = M.CONTACTO
where U.Activo = 1

	
-- Actualizar Talonario
   update zl.numeraciones set Numero = (select max(numero) from zl.ASESRZMAIL) where Entidad = 'ASIGACCRAZMAIL'


-- Eliminar Tabla
EXEC sp_rename 'zl.DYCUSUCAMP', 'Borrar_DYCUSUCAMP'


-------------------------------------------------------------------------------
-- F. 1040
-------------------------------------------------------------------------------

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
'Zoo Logic - Confirmación de inscripción al Campus Virtual', 
'
    <p class="style1">
      Estimado Cliente, por medio del presente mensaje le confirmamos la creaci&oacute;n de su nuevo 
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
      <img src="http://www.zoologic.com.ar/firmas/capacitacion.jpg" border="0" />
    </p>
    <p class="style1">
    </p>
');



-------------------------------------------------------------------------------
-- F. 502
-------------------------------------------------------------------------------
insert into [ZL].[FACTURACION].[FormatoMail]
([id], [Descrip], [asuntoMail], [bodyMail])
values
(
15,
'Restauración clave Lince',
'Zoo Logic - Solicitud de restauración clave Lince', 
'      <p class="encabezado">
        [[Contacto]]
        <br />
        [[Cliente]] ([[CodigoCliente]])
        <br />
        [[Razonsocial]] ([[CodigoRZ]])
      </p>
      <p class="style1">
        Estimado Cliente,
      </p>
      <p class="style1">
        Nos ponemos en contacto con Usted para comunicarle que hemos recibido 
        una solicitud de restauraci&oacute;n de clave para el serie Nº <b>[[Serie]]</b> 
        a trav&eacute;s de la p&aacute;gina web de Zoo Logic. Para proceder a la 
        restauraci&oacute;n, debe:
      </p>
      <ol>
        <li>Abrir Lince Indumentaria registrado con el n&uacute;mero de serie indicado.</li>
        <li>Seleccionar una sucursal.</li>
        <li>Acceder al men&uacute; &quot;Herramientas&quot;, &quot;V  Cambiar Clave&quot;.</li> 
        <li>En el espacio &quot;Ingrese clave anterior:&quot;, introducir la siguiente clave: <b>[[Retorno]]</b>.</li> 
        <li>Luego siga las indicaciones en pantalla.</li>
      </ol>
      <p class="style1">
        En caso de no haber solicitado Ud. esta restauraci&oacute;n, simplemente 
        ignore este mensaje. 
      </p>
      <p class="style1">
        Si necesita asistencia adicional, comun&iacute;quese con nosotros telef&oacute;nicamente 
        al (011) 4896-3111 o v&iacute;a e-mail a <a href="mailto:mesadeayuda@zoologic.com.ar">mesadeayuda@zoologic.com.ar</a>.
      </p>
      <p class="style1">
        Atentamente, el equipo de Mesa de Ayuda
      </p>
      <p class="style1">
        <img src="http://www.zoologic.com.ar/firmas/mesadeayuda.jpg" border="0" />
      </p>
      <p class="style1">
      </p>')
      

insert into [ZL].[FACTURACION].[FormatoMail]
([id], [Descrip], [asuntoMail], [bodyMail])
values
(
16,
'Restauración de clave de Administrador',
'Zoo Logic - Solicitud de restauración de clave de Administrador', 
'      <p class="encabezado">
        [[Contacto]]
        <br />
        [[Cliente]] ([[CodigoCliente]])
        <br />
        [[Razonsocial]] ([[CodigoRZ]])
      </p>
      <p class="style1">
        Estimado Cliente,
      </p>
      <p class="style1">
        <b>[[Serie]]</b> 
        <br />
        <b>[[Retorno]]</b>.
      </p>
      <p class="style1">
        En caso de no haber solicitado Ud. esta restauraci&oacute;n, simplemente 
        ignore este mensaje. 
      </p>
      <p class="style1">
        Si necesita asistencia adicional, comun&iacute;quese con nosotros telef&oacute;nicamente 
        al (011) 4896-3111 o v&iacute;a e-mail a <a href="mailto:mesadeayuda@zoologic.com.ar">mesadeayuda@zoologic.com.ar</a>.
      </p>
      <p class="style1">
        Atentamente, el equipo de Mesa de Ayuda
      </p>
      <p class="style1">
        <img src="http://www.zoologic.com.ar/firmas/mesadeayuda.jpg" border="0" />
      </p>
      <p class="style1">
      </p>')
      
insert into [ZL].[FACTURACION].[FormatoMail]
([id], [Descrip], [asuntoMail], [bodyMail])
values
(
17,
'Desativación temporal de Seguridad',
'Zoo Logic - Solicitud de desativación temporal de Seguridad', 
'      <p class="encabezado">
        [[Contacto]]
        <br />
        [[Cliente]] ([[CodigoCliente]])
        <br />
        [[Razonsocial]] ([[CodigoRZ]])
      </p>
      <p class="style1">
        Estimado Cliente,
      </p>
      <p class="style1">
        <b>[[Serie]]</b> 
        <br />
        <b>[[Retorno]]</b>.
      </p>
      <p class="style1">
        En caso de no haber solicitado Ud. esta restauraci&oacute;n, simplemente 
        ignore este mensaje. 
      </p>
      <p class="style1">
        Si necesita asistencia adicional, comun&iacute;quese con nosotros telef&oacute;nicamente 
        al (011) 4896-3111 o v&iacute;a e-mail a <a href="mailto:mesadeayuda@zoologic.com.ar">mesadeayuda@zoologic.com.ar</a>.
      </p>
      <p class="style1">
        Atentamente, el equipo de Mesa de Ayuda
      </p>
      <p class="style1">
        <img src="http://www.zoologic.com.ar/firmas/mesadeayuda.jpg
        " border="0" />
      </p>
      <p class="style1">
      </p>')      
      

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[logEnvioClavesProductos]') AND type in (N'U'))
DROP TABLE [dbo].[logEnvioClavesProductos]
GO

CREATE TABLE [dbo].[logEnvioClavesProductos](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[accion] [varchar](100) NULL,
	[serie] [varchar](50) NULL,
	[destino] [varchar](100) NULL,
	[fecha] [datetime] NOT NULL
) ON [PRIMARY]

GO

-- =============================================
-- Author:		Daniel Correa
-- Create date: 06/12/2012
-- Description:	Funcionalidad 40226181
-- Modificado:  28/12/2012
-- =============================================
Create PROCEDURE [ZL].[stp_EnvioDeClavesDeProductos]
	@Serie VARCHAR(7) = '', 
	@Version VARCHAR(10) = '',
	@TipoOperacion INT = 0
AS 
	
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@RazonSocial AS VARCHAR(100)
		,@Cliente AS VARCHAR(100)
		,@CodigoContacto AS VARCHAR(10)
		,@Contacto AS VARCHAR(50)
		,@mail AS VARCHAR(100)
		,@profile_name AS VARCHAR(100)
		,@recipients AS VARCHAR(100)
		,@blind_copy_recipients AS VARCHAR(50)
		,@body AS VARCHAR(5000) 
		,@Asunto AS VARCHAR(150) 
		,@body_format AS VARCHAR(50) 
		,@mailitem_id AS INT
		,@Estilo AS VARCHAR(MAX)
		,@Cuerpo AS VARCHAR(MAX)
		,@BodyTmp AS VARCHAR(MAX)
		,@Encabezado AS VARCHAR(500)
		,@Retorno AS VARCHAR(MAX)
		,@nromail AS INT
		,@CodigoRZ AS VARCHAR(50)
		,@CodigoCliente AS VARCHAR(50)
		,@Log AS VARCHAR(100);
	
	-------- /* estilos html */
	SET @Estilo = (SELECT TOP 1 Htmlcod FROM [ZL].[FACTURACION].[EstiloMail] WHERE id = 1)
	
	IF @TipoOperacion = 1
		BEGIN
			-- 16 ID PARA MAIL DE RESTAURACION DE CLAVE DE ADMINISTRADOR
 			SELECT TOP 1 @Asunto = [asuntoMail], @Log = [asuntoMail], @Cuerpo = [bodyMail] FROM [ZL].[FACTURACION].[FormatoMail] WHERE id = 16
		END
	IF @TipoOperacion = 2
		BEGIN
			-- 17 ID PARA MAIL DE CLAVE TEMPORAL DE ADMINISTRADOR
 			SELECT TOP 1 @Asunto = [asuntoMail], @Log = [asuntoMail], @Cuerpo = [bodyMail] FROM [ZL].[FACTURACION].[FormatoMail] WHERE id = 17
		END
	IF @TipoOperacion = 3
		BEGIN
			-- 15 ID PARA MAIL DE BLANQUEO DE CLAVE PARA LINCE
 			SELECT TOP 1 @Asunto = [asuntoMail], @Log = [asuntoMail], @Cuerpo = [bodyMail] FROM [ZL].[FACTURACION].[FormatoMail] WHERE id = 15
		END

	DECLARE Resultado CURSOR FOR
	SELECT
		ZL.Razonsocial.Descrip
		,ZL.Razonsocial.Cmpcod 
		,ZL.Clientes.Cmpcodigo
		,ZL.Clientes.Cmpnombre 
		,zl.contact.[Codigo]
		,LTRIM(RTRIM(zl.Titulos.[Descr])) + ' ' + LTRIM(RTRIM(zl.contact.[Pnom]))+ ' ' +LTRIM(RTRIM(zl.contact.[Snom]))+ ' ' +LTRIM(RTRIM(zl.contact.[Apell]))
		,ZL.MAILS.EMAIL
	from 
		ZL.Series 
		LEFT JOIN ZL.Razonsocial ON ZL.Razonsocial.Cdir = ZL.Series.Cdir 
		LEFT JOIN ZL.Clientes ON ZL.Clientes.Cmpcodigo = ZL.Razonsocial.Cliente 
		LEFT JOIN ZL.MAILS ON ZL.MAILS.CLIENTE = ZL.Clientes.Cmpcodigo
		INNER JOIN ZL.[ASESRZMAIL] ON ZL.[ASESRZMAIL].EMAIL = ZL.MAILS.EMAIL 
			AND ZL.ASESRZMAIL.ACCMAIL = 6 --Notificaciones de Seguridad
			AND ZL.ASESRZMAIL.ACCION  = 1 --Alta
		LEFT JOIN ZL.Contact ON ZL.Contact.Codigo = ZL.MAILS.CONTACTO 
			AND ZL.Contact.Desacti = 0 --Contacto activo
		LEFT JOIN ZL.Titulos ON ZL.Titulos.Ccod = ZL.Contact.Titulo
	WHERE
		ZL.Series.Nroserie = @Serie;
	OPEN Resultado;
	FETCH NEXT FROM Resultado INTO @RazonSocial, @CodigoRZ, @CodigoCliente, @Cliente, @CodigoContacto, @Contacto, @mail;
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @TipoOperacion = 1 --Producto Organic -- Restauración de clave de Administrador
			BEGIN
				SET @Retorno = '';
				SET @BodyTmp = replace( @cuerpo,  '[[Contacto]]',      LTRIM(RTRIM(@Contacto)) );
				SET @BodyTmp = replace( @BodyTmp, '[[Retorno]]',       @Retorno );
				SET @BodyTmp = replace( @BodyTmp, '[[Cliente]]',       @Cliente );
				SET @BodyTmp = replace( @BodyTmp, '[[CodigoCliente]]', @codigoCliente );
				SET @BodyTmp = replace( @BodyTmp, '[[Razonsocial]]',   @RazonSocial );
				SET @BodyTmp = replace( @BodyTmp, '[[CodigoRZ]]',      @CodigoRZ );
				Sç ET @BodyTmp = replace( @BodyTmp, '[[Serie]]',         @Serie );
				SET @BodyTmp = @Estilo + @BodyTmp;

				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'mesadeayuda'
					,@recipients = @mail
					,@copy_recipients = '' 
					,@blind_copy_recipients = ''
					,@body = @BodyTmp  
					,@subject = @Asunto 
					,@body_format = 'HTML' 
					,@mailitem_id = @nromail OUTPUT ;
			END;
			
		IF @TipoOperacion = 2 --Producto Organic -- Desativación temporal de Seguridad
			BEGIN
				SET @Retorno = '';
				SET @BodyTmp = replace( @cuerpo,  '[[Contacto]]',      LTRIM(RTRIM(@Contacto)) );
				SET @BodyTmp = replace( @BodyTmp, '[[Retorno]]',       @Retorno );
				SET @BodyTmp = replace( @BodyTmp, '[[Cliente]]',       @Cliente );
				SET @BodyTmp = replace( @BodyTmp, '[[CodigoCliente]]', @codigoCliente );
				SET @BodyTmp = replace( @BodyTmp, '[[Razonsocial]]',   @RazonSocial );
				SET @BodyTmp = replace( @BodyTmp, '[[CodigoRZ]]',      @CodigoRZ );
				SET @BodyTmp = replace( @BodyTmp, '[[Serie]]',         @Serie );
				SET @BodyTmp = @Estilo + @BodyTmp;

				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'mesadeayuda'
					,@recipients = @mail
					--,@recipients = 'hcorrea@zoologic.com.ar' 
					,@copy_recipients = '' 
					,@blind_copy_recipients = ''
					,@body = @BodyTmp  
					,@subject = @Asunto 
					,@body_format = 'HTML' 
					,@mailitem_id = @nromail OUTPUT ;
			END;
			
		IF @TipoOperacion = 3 --Blanqueo de clave Lince
			BEGIN
				SET @Retorno = @Serie+CHAR(64+DAY(GETDATE()))+CHAR(64+MONTH(GETDATE()));
				SET @BodyTmp = replace( @cuerpo,  '[[Contacto]]',      LTRIM(RTRIM(@Contacto)) );
				SET @BodyTmp = replace( @BodyTmp, '[[Retorno]]',       @Retorno );
				SET @BodyTmp = replace( @BodyTmp, '[[Cliente]]',       @Cliente );
				SET @BodyTmp = replace( @BodyTmp, '[[CodigoCliente]]', @codigoCliente );
				SET @BodyTmp = replace( @BodyTmp, '[[Razonsocial]]',   @RazonSocial );
				SET @BodyTmp = replace( @BodyTmp, '[[CodigoRZ]]',      @CodigoRZ );
				SET @BodyTmp = replace( @BodyTmp, '[[Serie]]',         @Serie );
				SET @BodyTmp = @Estilo + @BodyTmp;

				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'mesadeayuda'
					,@recipients = @mail
					,@copy_recipients = '' 
					,@blind_copy_recipients = ''
					,@body = @BodyTmp  
					,@subject = @Asunto 
					,@body_format = 'HTML' 
					,@mailitem_id = @nromail OUTPUT ;
				
				--SELECT @nromail;
				
			END;

		SET @Log = REPLACE( @Asunto, 'Zoo Logic - Solicitud de ', '' );
		SET @Log = UPPER(@Log);
		-- LOG envioClavesProductos
		insert into [ZL].[dbo].[logEnvioClavesProductos] (
			[accion]
			,[serie]
			,[destino]
			,[fecha]
		) values (
			@Log
			, @Serie
			, @mail
			, GETDATE()
		);
		
		
		FETCH NEXT FROM Resultado INTO @RazonSocial, @CodigoRZ, @CodigoCliente, @Cliente, @CodigoContacto, @Contacto, @mail;
	END
	CLOSE Resultado;
	DEALLOCATE Resultado;
END
