**********************************************************************
DEFINE CLASS zTestNocturnosMdaIncMda as FxuTestCase OF FxuTestCase.prg
	#IF .f.
	LOCAL THIS AS zTestNocturnosMdaIncMda OF zTestNocturnosMdaIncMda.PRG
	#ENDIF

	cClasificacionPorDefecto = ''
	cArchivoMock1 = ""
	CodDireccion = ""

	*-----------------------------------------------------------------------------------------
	function Setup
		this.CodDireccion = CrearDirecciones()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
		CrearFuncionesSQL()
		CrearFuncion_func_NormalizarNombre()
		
	endfunc 
	
	*---------------------------------
	Function TearDown
		goservicios.paraMETROS.zl.altas.vaLORSUGERIDOPARACLASIFICACIONDECLIENTES = this.cClasificacionPorDefecto
	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerMdaincmda
		local lomdaincmda as Object, loTalonario as Object, loSerie as Object, loClientes as Object, lcCliente as String;
			  lozlRazonSociales as Object, lcClasificacionPorDefecto as String, loClasificacionv2 as Object, loArticulo  as Object,;
			  loProductoZL as Object, loZlServiciosLote as Object, lcProductoZL as String, loMDATipoInteraccion as Object ,;
			  loTipoArticuloItemServicio as Object, loPais as Object, loProvincia as Object
			  
		private gomensajes as Object
		_screen.mocks.agregarmock( "Mensajes" )
		_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
		goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )

		this.agregarmocks( "TipificacionV2, SubTipificacionV2, LegajoOPS, ContratoV2, Direcciones, ListaDePrecios, Valor, EstadoV2, ActualizarZoo, Contactos, ZLAmbitosSerie" )
		_screen.mocks.AgregarSeteoMetodo( 'Relaserierzad_sqlserver', 'Obtenerdatosentidad', .T., "[Codigo],[nroserie = '507000'],[],[distinct]" )
		_screen.mocks.AgregarSeteoMetodo( 'Relaserierzad_sqlserver', 'Obtenerdatosentidad', .T., "[Codigo],[nroserie = ''],[],[distinct]" )
		_screen.mocks.AgregarSeteoMetodo( 'relaserierz', 'Codigo_despuesdeasignar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Inicializar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Finalizar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Migrarclientes', .T., "[*COMODIN],[cliente test]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Migrarrazonsocial', .T., "[*COMODIN],[rz test],[*COMODIN],88.88" )
		_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Migrarrazonsocial', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Contactos', 'Codigo_despuesdeasignar', .T. )
		
		=CrearFuncIyDAsignacionDeProyectoVigente()
		=CrearItemZlserviciosloteSubitems_Test( this )	

		*!*	 DRAGON 2028
		set procedure to (this.cArchivoMock1) additive


		=crearCodigoSugeridoCOMPORTAMIENTOCODIGOSUGERIDOENTIDAD()
		
		_screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', forceext( this.cArchivoMock1, '' ) )

		
		_screen.zoo.app.oTecnovoz = null
		_screen.zoo.app.oTecnovoz = newobject( 'Test_TecnoVoz' )


		loTIPOARTICULOITEMSERVICIO = _screen.zoo.instanciarentidad( "TIPOARTICULOITEMSERVICIO" )
		with loTIPOARTICULOITEMSERVICIO
			try
				.ccod = "01"
				.eliminar()
			catch
			finally
				.nuevo()			
				.ccod = "01"
				.descrip = "tipodeart"
				.grabar()
			endtry
			.release()
		endwith
 				
		loMDATIPOINTERACCION = _screen.zoo.instanciarentidad( "MDATIPOINTERACCION" )
		with loMDATIPOINTERACCION
			try
				.ccod = "LLAMADA"
				.eliminar()
			catch
			finally
				.nuevo()
				.ccod = "LLAMADA"
				.Descrip = "Se comunico con el cliente telefonicamente"                                 
				.grabar()
			endtry
			.release()
		endwith
		
		loProductoZL = _screen.zoo.instanciarentidad( "productozl" )
		with loProductoZL
			.nuevo()
			lcProductoZL = .ccod
			.descrip = 'Producto ZL'
			.grabar()
		endwith
 
		loClasificacionv2 = _screen.zoo.instanciarentidad("Clasificacionv2")
		with loClasificacionv2
			Try
				loClasificacionv2.codigo = '99' 
			Catch To loError
				loClasificacionv2.nuevo()
				loClasificacionv2.codigo = '99'
				loClasificacionv2.nombre = 'Clasificacion 99'
				loClasificacionv2.GRABAR()
			endtry 
		endwith
		loClasificacionv2.release()

		this.cClasificacionPorDefecto = goservicios.paraMETROS.zl.altas.vaLORSUGERIDOPARACLASIFICACIONDECLIENTES
		goservicios.paraMETROS.zl.altas.vaLORSUGERIDOPARACLASIFICACIONDECLIENTES = "99" 

		loClasificacionv2 = _screen.zoo.instanciarentidad( "Clasificacionv2" )
		with loClasificacionv2
			try
				.Codigo = '37'
				.Eliminar()
			catch
			finally
				.Nuevo()
				.Codigo = '37'
				.Nombre = 'Clasificacion 37'
				.Grabar()
			endtry 
		endwith
		loClasificacionv2.release()

		loClientes = _Screen.zoo.instanciarentidad( "zlClientes" )
		
		with loClientes 
			.nuevo()
			.Nombre = "cliente test"
			.MensajeMDA = "Mensaje MDA cliente"
			.direcc_pk = this.CodDireccion
			.grabar()
			lcCliente = loClientes.codigo 
		endwith

		loPais = _screen.zoo.instanciarentidad( "NACIONALIDAD" )
		with loPais
			try
				.Ccod = "00"
				.Eliminar()
			catch
			finally
				.Nuevo()
				.Ccod = "00"
				.Descrip = "00"
				.Grabar()
			endtry
		endwith	

		loProvincia = _screen.zoo.instanciarentidad( "PROVINCIA" )
		with loProvincia
			try
				.Codigo = "00"
				.Eliminar()
			catch
			finally
				.Nuevo()
				.Codigo = "00"
				.Descripcion = "00"
				.Pais_pk = "00"
				.Grabar()
			endtry
		endwith	

		loPais.Release()
		loProvincia.Release()

		lozlRazonSociales = _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "zTestNocturnosMdaIncMda.prg" ) 		
		
		with lozlRazonSociales
			.nuevo()
			.descripcion = 'rz test'
			.listadeprecios_pk = '99999'
			.cliente_pk = lcCliente
			.SituacionFiscal_pk = 1
			.cuit = '11111111113'
			.FormaDePago_pk = 'EFE'
			.direcc_pk = this.CodDireccion
			.reGIMENCOMISION = 32
			.VersionSistema = 88.88
			.Direccion = "Direccion de prueba"
			.Provincia_pk = "00"
			.grabar()
		endwith 
		loTalonario = _Screen.zoo.instanciarentidad( "talonario" )
		with loTalonario
			try
				.codigo = 'MDAINCMDA'                                        
				.eliminar()
			catch
			finally
				.Nuevo()
				.codigo = "MDAINCMDA"
				.ENTIDAD = "MDAINCMDA"
				.ReservarNumero = .t.
				.grabar()	
			endtry
		endwith

		Try
			loTalonario.codigo = "ALTASIS" 
		Catch To loError
			loTalonario.nuevo()
			loTalonario.codigo = "ALTASIS" 
			loTalonario.ENTIDAD = "ZLSERVICIOSLOTE"
			loTalonario.GRABAR()
		endtry 
		loTalonario.release()

		loSerie = createobject( "serieTest" )
		with loSerie
			try
				.nroserie = '407008'
				.eliminar()
			catch
			finally	
				.cNumeroSugeridoTest = '407008'
				.nuevo()
				.ambito_pk = "0001"
				.PRODUCTOZOOLOGIC_pk = lcProductoZL
				.nombre = "serie test"
				.direcc_pk = '00001'
				.MensajeMDA = "MensajeMDA test"

				.grabar()
			endtry 
		endwith

		loArticulo = _screen.zoo.instanciarentidad( "zlIsarticulos" ) 
		with loArticulo
			try
				.codigo = '00-AA'
				.eliminar()
			catch
			finally 
				.nuevo()
				.codigo = '00-AA'
				.descrip = 'art 00-AA'
				.tipoArticulo_pk = '01'
				.productozoologic_pk = lcProductoZL
				.detalleclasificaciones.oitem.clasificacion_pk = '99'
				.detalleclasificaciones.oitem.detalleclasificacion = '99'
				.detalleclasificaciones.actualizar()
				.grabar()
			endtry 
		endwith

		loZlServiciosLote = _screen.zoo.instanciarentidad( "zlServiciosLote" )
		loZlServiciosLote.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )

		loMdaincmda = createobject( "Ent_TestMDAINCMDA" )
		with loMdaincmda
			try
				.ultimno()
				.eliminar()
			catch
			finally
				.Nuevo()
				.NroSerie_pk = "407008"			
				.TipoIncidente_pk = 1
				.SubTipoIncidente_pk = 1
				.Consulta = "Consulta MDA"
				.lHabilitarCliente_PK = .t.
				.Razonsocial = lozlRazonSociales.codigo
				.Cliente_Pk = lcCliente
				* Transacciones con el cliente
				.detalletransacciones.oitem.tipocontacto_pk = "LLAMADA"
				.detalletransacciones.Actualizar()
				.Grabar()		
				.ultimo()
			endtry			
			
			this.assertequals( "El serie grabado no es el correcto", "407008", alltrim( .nroserie_pk ) )
			this.assertequals( "La clave generada no es la correcta", "77-41-56", alltrim( .ClaveSerie ) )
			this.assertequals( "El cliente asignado al incidente no es el correcto", lcCliente, alltrim( .cliente_pk ) )
			this.assertequals( "La Consulta MDA no es la esperada", "Consulta MDA", alltrim( .Consulta ) )
			this.assertequals( "El subtipo de incidente no es el esperado", 1, .SubTipoIncidente_pk )
			.detalletransacciones.CargarItem( 1 )
			this.assertequals( "La transaccion del cliente no es la esperada", "LLAMADA", alltrim( .detalletransacciones.oitem.tipocontacto_pk ) )

		endwith	

		try
			loSerie.release()
		catch
		endtry

		try
			loClientes.ultimo()
			loClientes.eliminar()
		catch
		finally
			loClientes.release()
		endtry

		try
			loMdaincmda.ultimo()
			loMdaincmda.eliminar()
		catch
		finally
			loMdaincmda.release()
		endtry
		
		try
			lozlRazonSociales.ultimo()
			lozlRazonSociales.eliminar()
		catch
		finally
			lozlRazonSociales.release()
		endtry
		
		try
			loZlServiciosLote.ultimo()
			loZlServiciosLote.eliminar()
		catch
		finally
			loZlServiciosLote.release()
		endtry
		
		try
			loProductoZL.ccod = lcProductoZL
			loProductoZL.eliminar()
		catch
		finally
			loProductoZL.release()
		endtry

		loArticulo.release()

		_screen.zoo.app.oTecnovoz = Null
		
		goMensajes = _Screen.zoo.app.oMensajes
	endfunc 
	
ENDDEFINE



*-----------------------------------------------------------------------------------------
function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase as Object ) as Void

	local lcContenido as String 
	
	toFxuTestCase.cArchivoMock1 = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido textmerge noshow
	*--------------------------------------------------------------------------------------------------
	define class <<justfname( forceext( toFxuTestCase.cArchivoMock1, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg

		function ValidaArticuloCentralizador
			return .t.
		endfunc

	enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMock1, 0)

endfunc 

*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test() as string
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc 

*-----------------------------------------------------------------------------------------
define class serieTest as ent_zlseries of ent_zlseries.prg
	cNumeroSugeridoTest = ''
	
	function ObtenerNumeroString() as String
		return this.cNumeroSugeridoTest 
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

*-----------------------------------------------------------------------------------------
function CrearFuncIyDAsignacionDeProyectoVigente
	Local lcAlter
**			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncIyDAsignacionDeProyectoVigente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))		
	text to lcAlter noshow 
		DROP FUNCTION [ZL].[FuncIyDAsignacionDeProyectoVigente]		
	endtext
	
	try	
		goServicios.daTOS.ejecutarsql(lcAlter)
	catch
	endtry 		

	
	TEXT to lcAlter noshow
		CREATE FUNCTION [ZL].[FuncIyDAsignacionDeProyectoVigente] 
		(     
		@Entidad as varchar(60)
		,@Numero as integer
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
	      select a.PROY as Proyecto
	      from AsigProy a
	      where a.NUM = (
             select 
                   max( NUM ) as Numero from zl.AsigProy 
                               where  @Numero = case @Entidad 
                                     when 'MINUTADEREUNION' then Minuta
                                     when 'IYDPRESUPUESTOS' then Presup
                                     when 'MDAINCMDA' then incid
                                     when 'PNCEREQUERIMIENTOS' then pnceReq
                                     when 'REQUERIMIENTOS_ID' then IyDReq
                                     when 'SGCACCIONESSGC' then SGCAc
                                     when 'DOCFUNCIONAL' then Docu 
                                     else 0 end
	                          ) 
		)
	ENDTEXT
	
	goServicios.daTOS.ejecutarsql(lcAlter)

Endfunc

*------------------------------------------------------------------------------
define class ZLRazonSociales_Aux as Ent_ZLRazonSociales of Ent_ZLRazonSociales.prg

	*-----------------------------------------------------------------------------------------
	function ValidarPermisoAsignacionTipoRazonSocial()
		return .t.
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Validar_Regimencomision( txVal as variant ) as Boolean
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarEsquemaActivo( txVal ) as boolean
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar( ) as boolean
		return .t.
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDatosAFIP() as Void
		this.Direccion = "Direccion de prueba"
		this.Localidad = ""
		this.Provincia_pk = "00"
		this.CodigoPostal = ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		return .t.
	endfunc 	

enddefine


*----------------------------------------------------------------
define class ValidacionesEstadoRazonSocial_Aux as custom 

	*-----------------------------------------------------------------------------------------
	function Validar( txVal ) as Boolean
		return .t.
	endfunc 
enddefine 


*-------------------------------------------------------------------
define class Test_TecnoVoz as custom

	*-----------------------------------------------------------------------------------------
	function ObtenerMotivoAperturaAutomaticaDeIncidente() as String
		return 'Saraza'
	endfunc 

	*-----------------------------------------------------------------------------------------
	function OBTENERVALORSUGERIDOREFERENCIA() as String
		return 'Saraza'
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRazonSocialDeTecnovoz() as String 
		return 'Saraza'
	endfunc		

enddefine


*-----------------------------------------------------------------------------------------
define class Ent_TestMDAINCMDA as Ent_MDAINCMDA of Ent_MDAINCMDA.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosRazonSocial( ) as Void
	** bla
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTipoIncidenteXProducto()
		return  .T. 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarSubTipoIncidente()
		return  .T. 
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function validarClientePorProducto() 
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function validarProductoPorTipo() 
		return .t.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
		(	
			
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			select 
					E.Ccod as Esquema ,
					CLIENTE  as Cliente ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
					e.dueno as Duenio
				from ZL.esqcom E
				left join (select Cliente, CREGIMEN from zl.ASESCOMCLI 
								where NUMERO in ( select max(numero)
									from zl.ASESCOMCLI
									group by   CLIENTE
												)      
							) as ASESCOMCLI on e.ccod = ASESCOMCLI.CREGIMEN 
				join ZL.Legops l on l.ccod = e.dueno 
				
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

*-----------------------------------------------------------------------------------------
function CrearFuncionesSQL() as Void
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerUsuarioZLPorUsuarioAD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerUsuarioZLPorUsuarioAD]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerUsuarioZLPorUsuarioAD]
		( @Usuario as Varchar(100) )
			RETURNS TABLE
			AS
			RETURN
			(
				select 
					CODUSU as UsuarioZL
				from ZL.DUSRZLAD DU
				where DU.USUAD = @Usuario
					)
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
function crearCodigoSugeridoCOMPORTAMIENTOCODIGOSUGERIDOENTIDAD() as Void
	Local lcTexto
	TEXT to lcTexto noshow
		if not exists( select * from Organizacion.COMCODSU where entidad= 'MDAINCMDA')
			insert into ORGANIZACION.COMCODSU ( "Horaexpo","Horaimpo","Haltafw","Fectrans","Fecimpo","Fmodifw","Hmodifw","Saltafw","Vmodifw","Zadsfw","Valtafw","Umodifw","Smodifw","Ualtafw","Fecexpo","Faltafw","Bdmodifw","Esttrans","Bdaltafw","Desentidad","Entidad","Anchodispo","Sugerir","Idglobal","Anchosuger","Prefijobd","Prefijo","Vistaprev","Busqextend","Obs","Salta" ) values ( '', '', '17:45:50', '19000101', '19000101', '20251030', '17:45:50', '104500', '01.0001.00000', '', '01.0001.00000', '', '104500', '', '19000101', '20251030', 'ZL', '', 'ZL', 'Incidentes', 'MDAINCMDA', 8.00, 0, 0, 0, 0, '', '', 0, '', 0 )
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )	
	
endfunc 