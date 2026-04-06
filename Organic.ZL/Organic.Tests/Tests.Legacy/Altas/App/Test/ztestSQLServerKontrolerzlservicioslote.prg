**********************************************************************
Define Class ztestSQLServerKontrolerZLSERVICIOSLOTE as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestSQLServerKontrolerZLSERVICIOSLOTE of ztestSQLServerKontrolerZLSERVICIOSLOTE.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		local loentidad as Object 
		
		loEntidad = _screen.zoo.instanciarentidad( "CLASIFICACIONV2" )
		try
			loEntidad.Codigo = "99"
		catch
			loEntidad.nuevo()
			loEntidad.Codigo = "99"
			loEntidad.Nombre = "clas99"
			loEntidad.grabar()
		endtry
		loEntidad.release()
		
		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()
		CrearFuncionAdmEstadoRS()
		CrearFuncion_FuncObtenerTipoUsuarioZLAD()
		CrearFuncion_func_NormalizarNombre()
		ActualizarCampoEspantera()

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerHabilitarYdeshabilitarColumnasTIyGrupoCom
		local loForm as Object, loControl as Object, loGrilla as Object, loControlCom as Object, loModulo as Object, ;
			lcCodigo1 as String, lcCodigo2 as String, loError as Exception, lcNombreMock as String
	
private gomensajes as Object
_screen.mocks.agregarmock( "Mensajes" )
_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "'*OBJETO'" )

		loError = null
		CrearEntZL_zlservicioslote_Test()
		=CrearItemZlserviciosloteSubitems_Test()
		*!*	 DRAGON 2028
		lcNombreMock = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()
		set procedure to ( lcNombreMock ) additive
		try
			_screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', forceext( lcNombreMock, '' ) )

			this.agregarmocks( "ZLCLIENTES,Zlrazonsociales,CONTRATOV2,LEGAJOOPS,PRODUCTOZL,direcciones," + ;
				"ZLAMBITOSSERIE,ZLSERIESTI,TIPOARTICULOITEMSERVICIO" )

			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Codigo_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'Zlseriesad', 'Cargar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'Zlseriesad', 'Eliminar', .T. )

			_screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenerclasificaciones', "99" )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenerclasificacionesparafiltrosql', "99" )

			loForm = goformularios.procesar( "ZLSERVICIOSLOTE" )
			loForm.oKontroler.oEntidad.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )

			loModulo = _screen.zoo.instanciarentidad( "zlismodulo" )
			with loModulo
				.Nuevo()
				lcCodigo1 = .ccod
				.Descrip = 'Prueba'
				.TipoModulo_pk = '2'
				.Grabar()

				.Nuevo()
				lcCodigo2 = .ccod
				.Descrip = 'Prueba'
				.TipoModulo_pk = '1'
				.Grabar()

				.Release()
			endwith

			loSeries = createobject( "serietest" )
			with loSeries
				try
					.nroserie = '407111'
					.eliminar()
				catch to loError
				finally
					.cNumeroSerieTest = '407111'
					.Nuevo()
					.Clave = '10-10-10'
					.Nombre = 'Prueba 2'
					.Direcc_pk = '01'
					.Ambito_pk = '01'
					.ProductoZoologic_pk = '01'
					.Grabar()
					.Release()
				endtry
			endwith

			loSeries = createobject( "serietest" )
			with loSeries
				try
					.nroserie = '505000'
					.eliminar()
				catch to loError
				finally
					.cNumeroSerieTest = '505000'
					.Nuevo()
					.Clave = '10-10-10'
					.Nombre = 'Prueba 2'
					.Direcc_pk = '01'
					.Ambito_pk = '01'
					.ProductoZoologic_pk = '01'
					.Grabar()
					.Release()
				endtry
			endwith

			loArticulos = _screen.zoo.instanciarentidad( "zlisarticulos" )
			with loArticulos
				try
					.Codigo = '00-PP'
					.Eliminar()
				catch to loError
				finally
					.Nuevo()
					.Codigo = '00-PP'
					.Descrip = 'Prueba'
					.TipoArticulo_pk = 'TI'
					.Desactivado = .F.
					.ProductoZoologic_pk = '01'
					.DetalleClasificaciones.oItem.Clasificacion_pk = '99'
					.DetalleClasificaciones.oItem.detalleClasificacion = 'clasif 99'
					.DetalleClasificaciones.Actualizar()
					.DetalleModulos.oItem.CodigoModulo_pk = lcCodigo1
					.DetalleModulos.Actualizar()
					.Grabar()
					.Release()
				endtry
			endwith

			loArticulos = _screen.zoo.instanciarentidad( "zlisarticulos" )
			with loArticulos
				try
					.Codigo = '03-AB'
					.Eliminar()
				catch to loError
				finally
					.Nuevo()
					.Codigo = '03-AB'
					.Descrip = 'Prueba'
					.TipoArticulo_pk = 'AB'
					.Desactivado = .F.
					.ProductoZoologic_pk = '01'
					.DetalleClasificaciones.oItem.Clasificacion_pk = '99'
					.DetalleClasificaciones.oItem.detalleClasificacion = 'clasif 99'
					.DetalleClasificaciones.Actualizar()
					.Grabar()
					.Release()
				endtry
			endwith

			loArticulos = _screen.zoo.instanciarentidad( "zlisarticulos" )
			with loArticulos
				try
					.Codigo = '00-TI'
					.Eliminar()
				catch to loError
				finally
					.Nuevo()
					.Codigo = '00-TI'
					.Descrip = 'Prueba'
					.TipoArticulo_pk = 'TI'
					.Desactivado = .F.
					.ProductoZoologic_pk = '01'
					.DetalleClasificaciones.oItem.Clasificacion_pk = '99'
					.DetalleClasificaciones.oItem.detalleClasificacion = 'clasif 99'
					.DetalleClasificaciones.Actualizar()
					.DetalleModulos.oItem.CodigoModulo_pk = lcCodigo2
					.DetalleModulos.Actualizar()
					.Grabar()
					.Release()
				endtry
			endwith

			local loClasificacionesDelCliente as zoocoleccion OF zoocoleccion.prg
			loClasificacionesDelCliente = _screen.zoo.crearobjeto( "zoocoleccion" )
			loClasificacionesDelCliente.Agregar( "99" ) 
				
			with loForm
				.oKontroler.ejecutar('Nuevo')
				.oEntidad.RazonSocial_pk = "01234"		
				.oEntidad.Cliente_pk = "MAXI"
				loGrilla = .oKontroler.obtenerControl("SUBITEMS")
				logrilla.nFilaActiva = 1

				.oEntidad.Subitems.oItem.SetearClasificacionesDelCliente( loClasificacionesDelCliente )
				.oEntidad.Subitems.oItem.Serie_pk = "407111"
				.oEntidad.Subitems.oItem.Articulo_pk = "00-PP"
				loControl = .oKontroler.obtenerControl( "SUBITEMS_SERIETI_CAMPO_7_1" )
				this.asserttrue( "La Condicion de Foco no esta seteado correctamente ( 1 )", !loForm.oKontroler.CondiciondeFoco( "SUBITEMS" , 1 , 6 ) )
				loControlCom = .oKontroler.obtenerControl( "SUBITEMS_grupoCom_CAMPO_9_1" )
				this.asserttrue( "La Condicion de Foco no esta seteado correctamente ( 2 )", loForm.oKontroler.CondiciondeFoco( "SUBITEMS" , 1 , 8 ) )			
				
				_screen.mocks.agregarseteometodo( "zlisarticulos", "TieneModuloTI", .T. )	
				_screen.mocks.agregarseteometodo( "zlisarticulos", "TieneModuloComunicador", .F. )		
				.oEntidad.Subitems.oItem.Articulo_pk = "00-TI"
				this.asserttrue( "La Condicion de Foco no esta seteado correctamente ( 3 )", loForm.oKontroler.CondiciondeFoco( "SUBITEMS" , 1 , 6 ) )
				this.asserttrue( "La Condicion de Foco no esta seteado correctamente ( 4 )", !loForm.oKontroler.CondiciondeFoco( "SUBITEMS" , 1 , 8 ) )			
				.oEntidad.Subitems.Actualizar()
				logrilla.nFilaActiva = 2
				.oEntidad.Subitems.oItem.Serie_pk = "505000"
				_screen.mocks.agregarseteometodo( "zlisarticulos", "TieneModuloTI", .F. )

				.oEntidad.Subitems.oItem.Articulo_pk = "03-AB"	
				loControl = .oKontroler.obtenerControl( "SUBITEMS_SERIETI_CAMPO_7_2" )
				this.asserttrue( "La Condicion de Foco no esta seteado correctamente ( 5 )", !loForm.oKontroler.CondiciondeFoco( "SUBITEMS" , 2 , 6 ) )
				loControlCom = .oKontroler.obtenerControl( "SUBITEMS_grupoCom_CAMPO_9_2" )
				this.asserttrue( "La Condicion de Foco no esta seteado correctamente ( 6 )", !loForm.oKontroler.CondiciondeFoco( "SUBITEMS" , 2 , 8 ) )
				.oKontroler.ejecutar('Cancelar')
				.oKontroler.ejecutar('Salir')
			endwith 
			loForm = null
			logrilla.release()
		catch to loError
			throw loError
		finally
			BorrarEntZL_zlservicioslote_Test()
			=BorrarItemZlserviciosloteSubitems_Test()
goMensajes = _Screen.zoo.app.oMensajes
		endtry
	endfunc 


	
	*---------------------------------
	Function TearDown
		local loentidad as Object 
		
		loEntidad = _screen.zoo.instanciarentidad( "CLASIFICACIONV2" )
		try
			loEntidad.Codigo = "99"
		catch
			loEntidad.eliminar()
		endtry
		loEntidad.release()

	EndFunc

EndDefine


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


*---------------------------------
define class serietest as ent_zlseries of ent_zlseries.prg

	cNumeroSerieTest = ''

	function ObtenerNumeroString()
		return this.cNumeroSerieTest
	endfunc

enddefine

*--------------------------------------------------------------------------------------------------
function CrearItemZlserviciosloteSubitems_Test
	local lcArchivo as String, lcContenido as String 
	
	lcArchivo = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido noshow
		*--------------------------------------------------------------------------------------------------
		define class Mock_ItemZlserviciosloteSubitems_Test as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg

			function init() as Void
				dodefault()
				this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_aux' , 'ztestSQLServerKontrolerZLSERVICIOSLOTE.prg' )
			endfunc 
		
			function ValidaArticuloCentralizador
				return .t.
			endfunc
		enddefine
	endtext

	strtofile( lcContenido, lcArchivo, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarItemZlserviciosloteSubitems_Test
	local lcArchivo as String 
	lcArchivo = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()
	delete file ( lcArchivo )
endfunc

*--------------------------------------------------------------------------------------------------
function CrearEntZL_zlservicioslote_Test
	local lcArchivo as String, lcContenido as String 
	
	lcArchivo = ObtenerNombreDeArchivoIentZL_ZLservicioslote_Test()

	text to lcContenido noshow
		define class EntZL_zlservicioslote as Ent_zlservicioslote of Ent_zlservicioslote.prg
			function NoEsRazonSocialDePantera() as Void
				return .t.
			endfunc 
		enddefine
	endtext

	strtofile( lcContenido, lcArchivo, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarEntZL_zlservicioslote_Test
	local lcArchivo as String 
	lcArchivo = ObtenerNombreDeArchivoIentZL_ZLservicioslote_Test()
	delete file ( lcArchivo )
endfunc 

*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test.prg'
	return lcArchivo
endfunc

*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoIentZL_ZLservicioslote_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.CRUTAINICIAL ) + 'GENERADOS\entZL_ZLservicioslote.prg'
	return lcArchivo
endfunc

****************************************************
Function CrearFuncionAdmEstadoRS
	Local lcAlter
	TEXT to lcAlter noshow

		CREATE function [ZL].[AdmEstadoRS] ( ) returns table as return

			select zl.ASESTRZAD.nrz
	                             ,zl.ASESTRZAD.cestado
	                             ,ZL.Funciones.Alltrim(zl.Estado.Nombre) as [Estado RS Descripción]
	                             ,zl.Estado.Codfz as [Código Foto Zoo Logic]
	                             ,zl.Estado.Inclfac as [Facturable]
	                             ,case when IsNull(Ltrim(rtrim(zl.Estado.fRAENT)),'')='' then 0 else 1 end as [Dar Código]
	                             ,zl.Estado.Observmda as [Obtener Servicio MDA]
	                             ,zl.ASESTRZAD.fecha
	          from zl.ASESTRZAD   WITH (NOLOCK)
	                  inner join 
	                             /*se cruza con los últimos comprobantes de asignación de estado*/
	                             (     select nrz as RS, max(numero) as ultimoComprobante   
	                                   from zl.ASESTRZAD   WITH (NOLOCK)
	                                   group by nrz
	                             ) as RsUltimoEstado
	                             on zl.ASESTRZAD.numero = RsUltimoEstado.ultimoComprobante 
	                          left join zl.Estado   WITH (NOLOCK) on zl.ASESTRZAD.cestado =  zl.Estado.codigo

	ENDTEXT

	try 
		goServicios.daTOS.ejecutarsql(lcAlter)
	catch
	endtry 

Endfunc

*----------------------------------------------------------------
define class ValidacionesEstadoRazonSocial_Aux as custom 
	*-----------------------------------------------------------------------------------------
	function Validar( txVal ) as Boolean
		return .t.
	endfunc 
enddefine 

*-----------------------------------
define class ValidacionDeArticulos_aux  as custom

	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPorSerie( trazonsocial, tserie, tarticulo ) as Boolean
		return .t.
	endfunc	
	
enddefine

*-----------------------------------------------------------------------------------------
Function CrearFuncion_FuncObtenerTipoUsuarioZLAD
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncObtenerTipoUsuarioZLAD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[FuncObtenerTipoUsuarioZLAD]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE function [ZL].[FuncObtenerTipoUsuarioZLAD]
		( 
			@UsuarioZL Varchar(100) 
		)
		returns Varchar(7)
		as
		begin
			declare @ret Varchar(4);
			
					select @ret = L.Tipousu 
						from  ZL.DUsrZLAD D
						JOIN ZL.Legops L on upper(D.codusu) = L.ccod
						where upper(D.USUAD) = upper( @UsuarioZL )
			
			return ISNULL(@ret, '' )
		end
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

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
function ActualizarCampoEspantera() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		update zl.Razonsocial set EsPantera = 0	where Cmpcod = '01234'
	endtext
	
	goServicios.Datos.EjecutarSql( lcSQL )
endfunc 
