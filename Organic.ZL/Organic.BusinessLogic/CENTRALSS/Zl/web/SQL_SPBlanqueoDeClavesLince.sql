USE [ZL]
GO



ALTER PROCEDURE [ZL].[stp_EnvioDeClavesDeProductos]
	@Serie VARCHAR(7) = '', 
	@Version VARCHAR(10) = ''

AS 
	
BEGIN
	SET NOCOUNT ON;

	create 	table #Tabla ( ID INT Identity(1,1),
							RazonSocial VARCHAR(100),
							CodigoRZ  VARCHAR(50),
							CodigoCliente VARCHAR(50),
							Cliente VARCHAR(100),
							CodigoContacto VARCHAR(10),
							Contacto varchar(50),
							mail varchar(100),
							TipoAccion numeric(3)
						 ); 
	
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
		,@Log AS VARCHAR(100)
		,@TipoAccion Numeric(3)
		,@CodigoDeError as VARCHAR(120)
		,@Contador INT 
		,@Regs INT ;
	
	
	set @CodigoDeError = '';
	
	-------- /* estilos html */
	SET @Estilo = (SELECT top 1 Htmlcod FROM [ZL].[MAILS].[EstiloMail] WHERE id = 1)
	
	
	if exists ( select top 1 zl.vMails.eMail
					FROM
						ZL.SERIES 
						  inner join ( select distinct  Nroserie , crass from zl.itemserv ) I on I.Nroserie = zl.Series.Nroserie   
						  INNER JOIN ZL.RAZONSOCIAL ON ZL.RAZONSOCIAL.CMPCOD = i.Crass 
						  INNER JOIN ZL.CLIENTES ON ZL.CLIENTES.CMPCODIGO = ZL.RAZONSOCIAL.CLIENTE 
						  inner join zl.zl.vMails on vMails.Cliente = ZL.RAZONSOCIAL.CLIENTE and vmails.TipoAccion = 6				  
						  INNER JOIN ZL.CONTACT ON ZL.CONTACT.Codigo = vMails.Contacto 
									AND ZL.CONTACT.DESACTI = 0 --CONTACTO ACTIVO
						  inner JOIN ZL.TITULOS ON ZL.TITULOS.CCOD = ZL.CONTACT.TITULO
							   
								
					WHERE
						ZL.Series.Nroserie = @Serie	) 
	
	begin
		
		set @CodigoDeError = 'OK' ;

		-- 15 ID PARA MAIL DE BLANQUEO DE CLAVE PARA LINCE
 		SELECT TOP 1 @Asunto = [asuntoMail], @Log = [asuntoMail], @Cuerpo = [bodyMail]  FROM [ZL].[MAILS].[FormatoMail] WHERE id = 15
		
		insert into #Tabla 
		
		SELECT
			ZL.RAZONSOCIAL.DESCRIP  as NombreRSocial
			, ZL.RAZONSOCIAL.CMPCOD as CodigoRSocial
			, ZL.CLIENTES.CMPCODIGO as CodigoCliente
			, ZL.CLIENTES.CMPNOMBRE as NombreCliente
			, zl.vMails.Contacto    as Contacto
			, LTRIM(RTRIM(ZL.TITULOS.DESCR)) + ' ' + LTRIM(RTRIM(ZL.CONTACT.PNOM))+ ' ' +LTRIM(RTRIM(ZL.CONTACT.[SNOM]))+ ' ' +LTRIM(RTRIM(ZL.CONTACT.APELL)) as Destinatario
			, zl.vMails.eMail
			, vmails.TipoAccion
		FROM
			ZL.SERIES 
			  inner join ( select distinct  Nroserie , crass from zl.itemserv ) I on I.Nroserie = zl.Series.Nroserie   
			  INNER JOIN ZL.RAZONSOCIAL ON ZL.RAZONSOCIAL.CMPCOD = i.Crass 
			  INNER JOIN ZL.CLIENTES ON ZL.CLIENTES.CMPCODIGO = ZL.RAZONSOCIAL.CLIENTE 
			  inner join zl.zl.vMails on vMails.Cliente = ZL.RAZONSOCIAL.CLIENTE and vmails.TipoAccion = 6				  
			  INNER JOIN ZL.CONTACT ON ZL.CONTACT.Codigo = vMails.Contacto 
						AND ZL.CONTACT.DESACTI = 0 --CONTACTO ACTIVO
			  inner JOIN ZL.TITULOS ON ZL.TITULOS.CCOD = ZL.CONTACT.TITULO
				   
					
		WHERE
			ZL.Series.Nroserie = @Serie;

			
	end ;
	
	else 
	begin
		set @CodigoDeError = 'ADVERTENCIA: No hay Mail de tipo ADMINISTRADOR.';
		
		-- 20 ID PARA MAIL DE BLANQUEO DE CLAVE PARA LINCE
		SELECT TOP 1 @Asunto = [asuntoMail], @Log = [asuntoMail], @Cuerpo = [bodyMail]  FROM [ZL].[MAILS].[FormatoMail] WHERE id = 19

		insert into #Tabla 
		
		SELECT
			ZL.RAZONSOCIAL.DESCRIP  as NombreRSocial
			, ZL.RAZONSOCIAL.CMPCOD as CodigoRSocial
			, ZL.CLIENTES.CMPCODIGO as CodigoCliente
			, ZL.CLIENTES.CMPNOMBRE as NombreCliente
			, zl.vMails.Contacto    as Contacto
			, LTRIM(RTRIM(ZL.TITULOS.DESCR)) + ' ' + LTRIM(RTRIM(ZL.CONTACT.PNOM))+ ' ' +LTRIM(RTRIM(ZL.CONTACT.[SNOM]))+ ' ' +LTRIM(RTRIM(ZL.CONTACT.APELL)) as Destinatario
			, zl.vMails.eMail
			, vmails.TipoAccion
		FROM
			ZL.SERIES 
			  inner join ( select distinct  Nroserie , crass from zl.itemserv ) I on I.Nroserie = zl.Series.Nroserie   
			  INNER JOIN ZL.RAZONSOCIAL ON ZL.RAZONSOCIAL.CMPCOD = i.Crass 
			  INNER JOIN ZL.CLIENTES ON ZL.CLIENTES.CMPCODIGO = ZL.RAZONSOCIAL.CLIENTE 
			  inner join zl.zl.vMails on vMails.Cliente = ZL.RAZONSOCIAL.CLIENTE and vmails.TipoAccion = 1				  
			  INNER JOIN ZL.CONTACT ON ZL.CONTACT.Codigo = vMails.Contacto 
						AND ZL.CONTACT.DESACTI = 0 --CONTACTO ACTIVO
			  inner JOIN ZL.TITULOS ON ZL.TITULOS.CCOD = ZL.CONTACT.TITULO
				   
					
		WHERE
			ZL.Series.Nroserie = @Serie;	
	end;	
	
	-----------------------------------
	
	SET @Regs = ( SELECT COUNT(*) FROM #Tabla )
	SET @Contador = 1  ;
	
	WHILE ( @Contador <= @Regs )
	BEGIN
		
		select  
				@TipoAccion = t.TipoAccion , 
				@mail = t.mail,
				@RazonSocial = t.RazonSocial  ,
				@CodigoRZ = t.CodigoRZ, 
				@CodigoCliente = t.CodigoCliente, 
				@Cliente = t.Cliente, 
				@CodigoContacto = t.CodigoContacto, 
				@Contacto = t.Contacto
			from #Tabla t 
			WHERE t.ID = @Contador ;
		
		
		SET @Retorno = @Serie+CHAR(64+DAY(GETDATE()))+CHAR(64+MONTH(GETDATE()));
		SET @BodyTmp = replace( @cuerpo,  '[[Contacto]]',      LTRIM(RTRIM(@Contacto)) );
		SET @BodyTmp = replace( @BodyTmp, '[[Retorno]]',       @Retorno );
		SET @BodyTmp = replace( @BodyTmp, '[[Cliente]]',       @Cliente );
		SET @BodyTmp = replace( @BodyTmp, '[[CodigoCliente]]', @codigoCliente );
		SET @BodyTmp = replace( @BodyTmp, '[[Razonsocial]]',   @RazonSocial );
		SET @BodyTmp = replace( @BodyTmp, '[[CodigoRZ]]',      @CodigoRZ );
		SET @BodyTmp = replace( @BodyTmp, '[[Serie]]',         @Serie );
		SET @BodyTmp = @Estilo + @BodyTmp;



		begin try


-- Borrar esto antes de pasarlo a PRODUCCION--		 
-- Set @mail = 'gmalusardi@zoologic.com.ar' ---- 
-- Borrar esto antes de pasarlo a PRODUCCION--		
			
			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Mesa de Ayuda'
				,@recipients = @mail
				,@copy_recipients = '' 
				,@blind_copy_recipients = ''
				,@body = @BodyTmp  
				,@subject = @Asunto 
				,@body_format = 'HTML' 
				,@mailitem_id = @nromail OUTPUT;	
						
--declare @forzarerror numeric(5,2) = 1/0

		end try 
		
		BEGIN CATCH
			set @CodigoDeError = 'ERROR al enviar mail.';
			insert into [ZL].[dbo].[LogAvisos]
				 ( Tabla
				  ,RegPor
				  ,NroComprob  )
			 values 
				( 'ERRORBLANQUEOCLAVELINCE'
				 , convert(nvarchar(10), getdate(), 103) + ' ' + convert(nvarchar(5), getdate(), 108) + ' Serie: ' + @Serie 
				 ,@nromail )
		END CATCH
		
		SET @Log = upper( REPLACE( @Asunto, 'Zoo Logic - Solicitud de ', '' ) );
		
		-- LOG envioClavesProductos
		insert into [ZL].[dbo].[logEnvioClavesProductos] (
			[accion]
			,[serie]
			,[destino]
			,[fecha]
			,TipoAccion
			,mailitem_id
			,CodigoDeError 
		) values (
			@Log
			, @Serie
			, @mail
			, GETDATE()
			, @TipoAccion
			, @nromail
			, @CodigoDeError 
		);
				
		SET @Contador = @Contador + 1
 
	END

	RAISERROR(@CodigoDeError ,16,1) ;  
	
END


GO


