**********************************************************************
Define Class zTestNocturnosZlRectificacionDeBajas as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestNocturnosZlRectificacionDeBajas of zTestNocturnosZlRectificacionDeBajas.prg
	#ENDIF

	cArchivoMockZlserviciosloteSubitems = ""
	cArchivoMockZlServiciosLoteBaja = ""	
	CodDireccion = ""
	
	*-----------------------------------------------------------------------------------------
	function ZTESTSQLServerZLRECTIFICACIONDEBAJAS
		local loLote as Object, loerror as Exception, loBajaDeServicios as Object, ;
			lnNroItemServicio1 as Integer, ldFechaDeVigencia as date, lnNumeroDeBaja as Integer, loArticulo as Object , loserie as Object ;
			loTipoMotivo as Object, loMotivo  as Object, loClasificacion as Object 

		private gomensajes as Object
		_screen.mocks.agregarmock( "Mensajes" )
		_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
		goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
		
		loError = null

		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()
		=CrearItemZlserviciosloteSubitems_Test( this )
		=CrearZlServiciosLoteBaja_Test( this )
		=CrearFuncion_func_NormalizarNombre()
		=Crear_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD()

		*!*	 DRAGON 2028
		set procedure to ( this.cArchivoMockZlserviciosloteSubitems ) additive
		set procedure to ( this.cArchivoMockZlServiciosLoteBaja ) additive
		
		this.CodDireccion = CrearDirecciones()

		try
			_screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', forceext( this.cArchivoMockZlserviciosloteSubitems, '' ) )
			_screen.Mocks.AgregarMock( 'ZlServiciosLoteBaja', forceext( this.cArchivoMockZlServiciosLoteBaja, '' ) )

			**************************** MOCKS ****************************
			this.agregarmocks( "Zlrazonsociales,LEGAJOOPS,CONTRATOV2,TIPOARTICULOITEMSERVICIO,PRODUCTOZL, ActualizarzOO, ZlAmbitosSerie, Direcciones, Contactos" )
			_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Levantarexcepciontexto', .T., "[El dato buscado 12345 de la entidad ZLRAZONSOCIALES no existe.],9001" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Codigo_despuesdeasignar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarclientes', .T., "[*COMODIN],[*COMODIN]" ) 

			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Enlazar', .T., "[Cliente.EventoObtenerLogueo],[inyectarLogueo]" ) && ztestzlrectificaciondebajas.ztestzlrectificaciondebajas 20/09/11 16:43:08
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Enlazar', .T., "[Cliente.EventoObtenerInformacion],[inyectarInformacion]" ) && ztestzlrectificaciondebajas.ztestzlrectificaciondebajas 20/09/11 16:43:08
			_screen.mocks.AgregarSeteoMetodo( 'contactos', 'Codigo_despuesdeasignar', .T. ) && ztestnocturnoszlrectificaciondebajas.ztestzlrectificaciondebajas 05/10/12 10:31:53

			
			toEntidad = newobject( "objEntidad" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Cliente_access', toEntidad )
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Cliente_pk_despuesdeasignar', .T. ) && ztestnocturnoszlrectificaciondebajas.ztestzlrectificaciondebajas 17/10/12 11:31:42

			**************************** TALONARIOS ****************************
			=CargarTalonarios()
			
			**************************** clasificacion ****************************
			loClasificacion = _screen.zoo.instanciarentidad( "clasificacionv2" )
			with loClasificacion
				try
					.Codigo = "01"
					.Modificar()
				catch
					.nuevo()
					.Codigo = "01"
				finally
					.Nombre = "Clasificacion 01"
					.grabar()
					.release()
				endtry
			endwith
			loClasificacion = null

			local loClasificacionv2 as Object
			loClasificacionv2 = _screen.zoo.instanciarentidad( "Clasificacionv2" )
			with loClasificacionv2
				try
					.Codigo = '37'
					.Modificar()
				catch
					.Nuevo()
					.Codigo = '37'
				finally
					.Nombre = 'Clasificacion 37'
					.Grabar()
				endtry 
			endwith
			loClasificacionv2.release()

			**************************** zlisarticulos ****************************
			loarticulo = _screen.zoo.instanciarentidad( "zlisarticulos" )
			with loarticulo
				try
					.Codigo = "00-AB"
					.Modificar()
				catch
					.nuevo()
					.Codigo = "00-AB"
				finally
					.descrip = "art test"
					.tipoarticulo_pk = '2'
					.PRODUCTOZOOLOGIC_pk = '9999'
					.desactivado = .f.
					.DetalleClasificaciones.limpiar()
					.DetalleClasificaciones.oitem.clasificacion_pk = "01"
					.DetalleClasificaciones.oitem.detalleclasificacion = 'fruta'
					.DetalleClasificaciones.actualizar()
					.grabar()
					.release()
				endtry
			endwith
			loarticulo = null

			**************************** SERIE ****************************
			loSerie = createobject( "serieTest" )
			with loSerie
				try
					.nroserie = '407000'
					.Modificar()
				catch
					.cNumeroSugeridoTest = '407000'
					.nuevo()
				finally     
					.ambito_pk = "0001"
					.productozoologic_pk = '9999'
					.nombre = "serie test"
					.direcc_pk = '00001'
					.grabar()
					.release()
				endtry 
			endwith
			loSerie = null 

			************************TIPO MOTIVO BAJA ****************************
			loTipoMotivo = _Screen.zoo.instanciarentidad( "TIPOMOTIVOBAJA" )
			local lCodTipoMotivoBaja as number 
			with loTipoMotivo
				try
 					.nuevo()
					lCodTipoMotivoBaja = .Codigo
					.Descripcion = 'Ponele'
					.grabar()
					.release()
				endtry 
			endwith

			**************************** MOTIVO BAJA ****************************
			loMotivo = _Screen.zoo.instanciarentidad( "COMMOTIVOBAJA" )
			local lCodMotivoBaja as string 
			with loMotivo
				try
					.nuevo()
					lCodMotivoBaja = .cCod 
					.Descrip = 'No le gusta el sistema'
					.Tipo_pk = lCodTipoMotivoBaja 
					.grabar()
				catch	
				endtry 
			endwith
			
			local loEntidad as entidad OF entidad.prg
			******************************** ALTA DE CLASIFICACION ************************
			loEntidad = _Screen.zoo.instanciarentidad( "CLASIFICACIONV2" )
			with loEntidad
				try
					.Codigo = "01"
					.Modificar()
				catch
					.Nuevo()
					.Codigo = "01"		
				finally
					.Nombre = "Grandes Clientes"
					.Grabar()
				endtry
				.Release()
			endwith
			
			******************************** ALTA DE CLIENTE ************************
			local lcCodigoCli as string
			loEntidad = _Screen.zoo.instanciarentidad( "ZLClientes" )
			with loEntidad
				try
					.Nuevo()
					lcCodigoCli = .Codigo
					.direcc_pk = this.CodDireccion
					.Nombre = 'CLitest' + sys(2015)
					.Grabar()
					.Release()
				catch to loError
					this.asserttrue( 'no Deberia haber dado error al dar de alta el cliente.', .f. )
				endtry
			endwith
				
			**************************** ZLSERVICIOSLOTE ****************************
			loLote = _screen.zoo.Crearobjeto( "ZLSERVICIOSLOTE_AUX", "zTestNocturnosZlRectificacionDeBajas.prg" )
			loLote.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )
			
			with loLote 
				.nuevo()
				
				.razonSocial.Cliente_pk = lcCodigoCli
				.RazonSocial_pk = '12345' 
				.cliente_pk = lcCodigoCli
				.Contacto_Pk= '01'			
				with .subitems.oitem
					.serie_pk = '407000'
					.PRODUCTOZOOLOGIC_PK = '9999'
					.PRODUCTOZOOLOGICDetalle = 'DETALLE'
					.Articulo_pk = '00-AB'
					.FechaAltaVigencia = date() - 48	
				endwith
				.subitems.Actualizar()
				
				try
					.grabar()
					.release()
				catch to loerror 
					this.asserttrue('Deberia haber grabado el alta',.F.) 
				finally
				endtry
			endwith
			loLote.Release()
			loLote = null

			**************************** ZLITEMSSERVICIOS ****************************
			loEntItemSer = _Screen.zoo.instanciarentidad( "ZLITEMSSERVICIOS" )
			loEntItemSer.ultimo()
			lnNroItemServicio1 = loEntItemSer.codigo
			loEntItemSer.Release()
			loEntItemSer = null

			**************************** ZLSERVICIOSLOTEBAJA ****************************
			loBajaDeServicios = _Screen.zoo.instanciarentidad( "ZLSERVICIOSLOTEBAJA" )  

			with loBajaDeServicios 
				.nuevo()
				.regpor_pk = 'ADMIN'
				.razonSocial.Cliente_pk = lcCodigoCli                   
				.RazonSocial_pk = '12345' 
				.Contacto_pk = '1234567'
				.cliente_pk = lcCodigoCli
				.NumeroFormWebBaja = 32594134
				.MotivoBaja_pk = lCodMotivoBaja    
				with .SubItems.oitem
					.nroitemserv_pk = lnNroItemServicio1
					.FechaBajaVigencia = date() + 48
				endwith
				.SubItems.Actualizar()
			  
				try
					.grabar()
					lnNumeroDeBaja = .Numero &&alltrim( STR( int ( .Numero - 1 ) ) ) 
					.release()
				catch to loerror
					this.asserttrue('Deberia haber grabado la baja',.F.) 
				endtry
			endwith 

			loBajaDeServicios.Release()
			loBajaDeServicios = null
			
			**************************** ZLITEMSSERVICIOS ****************************
			loEntItemSer = _Screen.zoo.instanciarentidad( "ZLITEMSSERVICIOS" )
			loEntItemSer.Codigo = lnNroItemServicio1
			this.assertEquals( 'No se actulizo la fecha de baja de vigencia en el item de servicio',date()+48 ,loEntItemSer.FechaBajaVigencia )
			loEntItemSer.Release()
			loEntItemSer = null

			**************************** ZLRECTIFICACIONDEBAJASIS ****************************
			local loRectificacion as ent_ZLRECTIFICACIONDEBAJASIS of ent_ZLRECTIFICACIONDEBAJASIS.prg
			loRectificacion = _Screen.zoo.instanciarentidad( "ZLRECTIFICACIONDEBAJASIS" )  

			with loRectificacion
				.nuevo()
				
				.RazonSocial.Cliente_pk = lcCodigoCli     
				.fkNumeroBaja_Pk = lnNumeroDeBaja
				
				
				&&&& &&&& Cabecera &&&& &&&&
				this.assertEquals( 'No se actulizo la razon social', alltrim( .RazonSocial_pk ), '12345'  )
				this.assertEquals( 'No se actulizo el contacto', alltrim( .Contacto_pk), '1234567'  )
				this.assertEquals( 'No se actulizo el cliente', alltrim( .cliente_pk ), lcCodigoCli)
				this.assertEquals( 'No se actulizo el Numero de formulario web', .NumeroFormWebBaja, 32594134 )
					
				&&&& &&&& Detalle &&&& &&&&
				local lnItemActivo1 as Integer, lnItemActivo2 as Integer
				lnItemActivo1 = 0
				if loRectificacion.SubItems.Count > 0
					for i = 1 to loRectificacion.SubItems.Count
						loItem = loRectificacion.SubItems.item[i]
						with loItem
							this.assertEquals( 'No se actulizo el Nro de item de servicio', lnNroItemServicio1, .NroItemServ_pk )
							this.assertEquals( 'No se actulizo el serie', "407000", alltrim( .Serie_pk ) )
							this.assertEquals( 'No se actulizo el serie detalle', "serie test", lower(alltrim( .SerieDetalle ) ) )
							this.assertEquals( 'No se actulizo el articulo detalle', "art test", lower(alltrim( .ArticuloDetalle ) ) )
							this.assertEquals( 'No se actulizo el serie ti', "", alltrim( .SerieTi_pk ) )
							this.assertEquals( 'No se actulizo la razon social', "", alltrim( .RazonSocial ) )
							this.assertEquals( 'No se actulizo la razon social',  ( date() + 48 ), .FechaBajaVigencia )
							
							lnItemActivo1 = i

						endwith
					endfor
					loItem = null
				else
					this.asserttrue( "No se cargaron los items en la grilla.", .f. )
				endif
				if lnItemActivo1 > 0 
					loRectificacion.SubItems.item[lnItemActivo1].FechaBajaVigencia = date() + 58
					try 
						.grabar()
					catch to loerror 
						this.asserttrue('Deberia haber grabado la rectificacion de baja.', .f. ) 
					finally
						.release()
					endtry
				endif
			endwith 

			loRectificacion.Release()
			loRectificacion = null		

			**************************** ZLITEMSSERVICIOS ****************************
			loEntItemSer = _Screen.zoo.instanciarentidad( "ZLITEMSSERVICIOS" )
		
			loEntItemSer.Codigo = lnNroItemServicio1
			lcLogueo = "No se actulizo la fecha de baja de vigencia en el item de servicio 1 luego"
			lcLogueo = lcLogueo + "de Grabar" + chr( 13 )+ chr( 10 ) + " El comprobante de rectificacion de baja."
			this.assertEquals( lcLogueo,date() + 58 ,loEntItemSer.FechaBajaVigencia )

			loEntItemSer.Release()
			loEntItemSer = null
			
			
			with loMotivo
				try
					.cCod = '01'
					.eliminar()
				catch
				finally     
					.release()
				endtry 
			endwith
			loMotivo = null
		catch to loError
			throw loError
		finally
			=BorrarItemZlserviciosloteSubitems_Test( this )
			=BorrarZlServiciosLoteBaja_Test( this )
			goMensajes = _Screen.zoo.app.oMensajes
		endtry
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerArticulosNoVisiblesDeCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeCliente]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeCliente]
		(@Cliente varchar(5), @Art varchar(13))
		RETURNS TABLE
		AS
		RETURN
		(
			select cli.Cmpcodigo as Cliente, art.Ccod as Articulo, dana.Cmpclasif as Clasificacion
			from ZL.Isarticu art
				inner join ZL.DCLAARTNO dana on dana.Codcla = art.Ccod
				inner join ZL.DETCLASCLIE dc on dc.Fkclasifi = dana.Cmpclasif
				inner join ZL.Clientes cli on cli.Cmpcodigo = dc.Fkcliente
			where cli.Cmpcodigo = @Cliente and art.Ccod = @Art
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc



*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
function CargarTalonarios() as Void
	loTalonario = _screen.zoo.instanciarentidad("talonario")
	local loError as Exception, loEx as Exception
	Try
		loTalonario.codigo = "ITEMSERCOD"
	Catch To loError
		loTalonario.nuevo()
		loTalonario.codigo = "ITEMSERCOD" 
		loTalonario.ENTIDAD = "ZLITEMSSERVICIOS"
		loTalonario.GRABAR()
	endtry 
	
	
	Try
		loTalonario.codigo = "ALTASIS"
	Catch To loError
		loTalonario.nuevo()
		loTalonario.codigo = "ALTASIS" 
		loTalonario.ENTIDAD = "ZLSERVICIOSLOTE"
		loTalonario.GRABAR()
	endtry 

	Try
		loTalonario.codigo = "BAJASIS" 
	Catch To loError
		loTalonario.nuevo()
		loTalonario.codigo = "BAJASIS" 
		loTalonario.ENTIDAD = "ZLSERVICIOSLOTEBAJA"
		loTalonario.GRABAR()
	endtry 
	
	Try
		loTalonario.codigo = "RECBAJIS" 
	Catch To loError
		loTalonario.nuevo()
		loTalonario.codigo = "RECBAJIS" 
		loTalonario.ENTIDAD = "ZLRECTIFICACIONDEBAJASIS"
		loTalonario.GRABAR()
	endtry 	
	
	loTalonario.Release()
	loTalonario = null
endfunc 


*--------------------------------------------------------------------------------
define class serieTest as ent_zlseries of ent_zlseries.prg
      cNumeroSugeridoTest = ''
      function ObtenerNumeroString() as String
            return this.cNumeroSugeridoTest 
      endfunc
enddefine

*--------------------------------------------------------------------------------------------------
function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMockZlserviciosloteSubitems = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido textmerge noshow
	
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlserviciosloteSubitems, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg
			function ValidaArticuloCentralizador
				return .t.
			endfunc

			*-----------------------------------------------------------------------------------------
			function Init() as Void
				dodefault()
				this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_Aux' )			
			endfunc 

		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMockZlserviciosloteSubitems, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMockZlserviciosloteSubitems
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc


*--------------------------------------------------------------------------------------------------
function CrearZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMockZlServiciosLoteBaja = ObtenerNombreDeArchivoZlServiciosLoteBaja_Test()

	text to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlServiciosLoteBaja, '' ) )>> as Ent_ZlServiciosLoteBaja of Ent_ZlServiciosLoteBaja.prg
			function TieneModuloeHost( tcArticulo as String ) as Boolean
				return .t.
			endfunc

			function EjecutaSPDesactivaGrupoComunicacionesxSerie( tcSerie as String, tcFechaBaja as String ) as Void
			endfunc

			protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
				nodefault
			endfunc				
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMockZlServiciosLoteBaja, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMockZlServiciosLoteBaja
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoZlServiciosLoteBaja_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ZlServiciosLoteBaja_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc


*-----------------------------------------------------------------------------------------
define class objEntidad as Custom

	Codigo = ''
	*-----------------------------------------------------------------------------------------
	function SoportaBusquedaExtendida() as Void
		return .f.
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
function CrearDirecciones
	local loent as Object, loerror as Object, lcCodRetorno as String, loent1 as Object , loent2 as Object, loent3 as Object

	lcCodRetorno = ''
	
	loent = _Screen.zoo.instanciarentidad( 'PROVINCIA' )

	with loent
		try 
			.codigo = '01'
			.Eliminar()
		catch to loError	
		endtry 
			
		try 
			.NUEVO()
			.codigo = '01'
			.Descripcion = 'BA'
			.grabar()
		catch to loError	
		finally 
			.Release()
		endtry 	
	endwith 
	
	loent = null
	loent1 = _Screen.zoo.instanciarentidad( 'TIPODIRECCIONES' )	

	with loent1
	
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = '01'
			.Descrip = 'Tipo 1'
			.grabar()
		catch to loError
		finally 
			.Release()
		endtry 			
	endwith 	
	loent1 = null
	loent2 = _Screen.zoo.instanciarentidad( 'NACIONALIDAD' )

	with loent2
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = 'AR'
			.Descrip = 'Aryentain'
			.grabar()
		catch to loError
		finally 
			.Release()
		endtry 				
	endwith 	

	loent2 = null
	loent3 = _Screen.zoo.instanciarentidad( 'DIRECCIONESALTAS' )
	
	with loent3	
		try 
			.nuevo()
			.Calle = 'LA CALLE'
			.Provincia_PK ='01'
			.TIPO_PK = '01'
			.Pais_pk = 'AR'
			.Grabar()
		catch to loError
		finally
			.Ultimo()
			lcCodRetorno = .Codigo
			.Release()
		endtry 	
			
	endwith 

	loent3 = null

	return lcCodRetorno
	
endfunc 


*----------------------------------------------------------------
define class ValidacionesEstadoRazonSocial_Aux as custom 

	*-----------------------------------------------------------------------------------------
	function Validar( txVal ) as Boolean
		return .t.
	endfunc 
enddefine 


********************************************************************************************
define class ValidacionDeArticulos_Aux as Custom

	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPorSerie( tRazonSocial as String, tSerie as String, tArticulo as String ) as Boolean
		return .t.
	endfunc 

enddefine

*----------------------------------------------------------------
define class ZLSERVICIOSLOTE_AUX as ent_ZLSERVICIOSLOTE of ent_ZLSERVICIOSLOTE.PRG

	*-----------------------------------------------------------------------------------------
	function CrearCuentaComunicaciones() as Void
		nodefault
	endfunc
	protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
		nodefault
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function NoEsRazonSocialDePantera() as Boolean
		return .T.
	endfunc
		
enddefine

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSql( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[func_NormalizarNombre]
				(@Texto varchar(max))
			RETURNS VARCHAR(MAX) AS
			BEGIN

				declare @Text varchar(max) = ltrim(rtrim((case when @Texto is null then '' else lower(replace(@Texto, '.', '')) end)))
				while charindex('  ', @Text) > 0
					begin
						set @Text = replace(@Text, '  ', ' ')
					end
				declare @LastTextIndex int = (select charindex(' ', reverse(@Text))), @LastText varchar(max) = ''
				declare @New varchar(max) = ''
				declare @Index int = 1, @Len int = len(@Text)

				while (@Index <= @Len)
					begin
						if (substring(@Text, @Index, 1) like '[^a-z]' and @Index + 1 <= @Len)
							begin
								select @New = @New + upper(substring(@Text, @Index, 2)), @Index = @Index + 2
							end
						else
							begin
								select @New = @New + substring(@Text, @Index, 1), @Index = @Index + 1
							end
					end

				set @New = (upper(left(@New, 1)) + right(@New, abs(@Len - 1)))
				set @LastText = right(lower(@New), abs(@Len - (@Len - @LastTextIndex + 1)))
				set @New =
					case
						when @LastText = 'sa' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.'
						when @LastText = 'srl' then left(@New, @Len - @LastTextIndex + 1) + 'S.R.L.'
						when @LastText = 'sas' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.S.'
						else @New
					end

				return ltrim(rtrim(@New))

			END
		endtext
		
		goServicios.Datos.EjecutarSql( lcSQL )

endfunc


*-----------------------------------------------------------------------------------------
function  Crear_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD
	Local  lcSQL as String 
	text to lcSQL noshow
		CREATE PROCEDURE [ZL].[sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD]
				@RazonSocial varchar(5), @Serie varchar(7), @Origen varchar(100), @NroComprobante numeric(12)
			AS begin
				select 0 where 1=2
			end
	endtext 
	try 
		goServicios.Datos.EjecutarSql( lcSQL )
	catch 
	endtry 

endfunc