**********************************************************************
Define Class zTestBuscador As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestBuscador Of zTestBuscador.prg
	#Endif

	*---------------------------------
	Function zTestEjecutar
		local loLanzadorDeConsulta as Object, loObjMock as Object
		
		loObjMock = newobject( "ObjetoMock" )
		_screen.mocks.agregarmock( "ConfiguracionDeConsulta" )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURACIONDECONSULTA', 'Obtenerconfiguracion', loObjMock, '[1]' )
		_screen.mocks.agregarmock( "ManagerEjecucion" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Ejecutaraplicacion', .T., "[" + addbs( _SCREEN.ZOO.CRUTAINICIAL )+ "bin\zoologicsa.buscador.lanzador.exe],[*COMODIN],.T.,.T." )

		goServicios.Ejecucion = null

		loLanzadorDeConsulta = _screen.zoo.Crearobjeto( "LanzadorDeConsulta" ) 
		loLanzadorDeConsulta.Procesar( "1" )
	
		_screen.mocks.verificarejecuciondemocksunaclase( "ManagerEjecucion" )
	
		loLanzadorDeConsulta = null
	Endfunc


	*-----------------------------------------------------------------------------------------
	function zTestNativaAtributosParaNativa() as Void
		local loObjetoConfiguracion as Object 

		loObjetoConfiguracion = _screen.zoo.crearobjeto( "ConfiguracionDeConsulta" )

		goParametros.Dibujante.FormatoParaFecha = 2

		loResultado = loObjetoConfiguracion.Obtenerconfiguracion( "2" )

		loObjetoConfiguracion = null

		This.assertequals( "Atributo sucursal para nativa.", addbs( _screen.zoo.app.ObtenerRutaSucursal( _screen.zoo.app.ObtenerSucursalActiva() ) ) + "DBF", loResultado.Sucursal )

		loResultado = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificarConfiguracion
		local loObjetoConfiguracion as Object 

		loObjetoConfiguracion = _screen.zoo.crearobjeto( "ConfiguracionDeConsulta" )

		goParametros.Dibujante.FormatoParaFecha = 2

		loResultado = loObjetoConfiguracion.Obtenerconfiguracion( "2" )

		loObjetoConfiguracion = null

		This.asserttrue( "Atributo Nativa.", loResultado.EsNativa = goServicios.Datos.EsNativa() )		
		This.asserttrue( "Atributo FormatoFechaLarga.", loResultado.FormatoFechaLarga )

		This.assertequals( "Atributo Permite codigo en minusculas.", goParametros.Nucleo.PermiteCodigosEnMinusculas, loResultado.CodigoEnMinusculas )
		This.assertequals( "Atributo CaracterImpresionCodigoDeBarra .", alltrim( goRegistry.Dibujante.CaracterSeparadorDeAtributosDeCombinacionParaImpresionDeCodigoDeBarras ), loResultado.CaracterImpresionCodigoDeBarra  )
		This.assertequals( "Atributo NombreGenerados.", "ZooLogicSA.Buscador." + proper( _screen.zoo.app.ObtenerNombreProyecto() ) + ".Generados", loResultado.NombreGenerados )
		This.assertequals( "Atributo RutaAssembly.", addbs( addbs( _screen.Zoo.cRutaInicial ) + "Bin" ), loResultado.RutaAssembly )

		This.assertequals( "Atributo InformacionAplicacion.", "O", vartype( loResultado.InformacionAplicacion ) )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestBaseDeDatosConAgrupamiento
		local loConfiguracionDeConsulta as Object, loConfiguracion as Object, ;
			loError as zooexception OF zooexception.prg
		
		lcCodigo = right( sys( 2015 ), 8 )
		goParametros.Nucleo.AgrupamientoParaConsultaDeStock = lcCodigo

		loEntidadAgrupamiento = _screen.zoo.instanciarentidad( "Agrupamiento" )
		
		with loEntidadAgrupamiento as ent_Agrupamiento of ent_Agrupamiento.prg
			.Nuevo()
			.Codigo = lcCodigo
			.Descripcion = "DESCRIP"
			.BaseDeDatosDetalle.LimpiarItem()
			.BaseDeDatosDetalle.oItem.BaseDeDatos_pk = "PAISES"
			.BaseDeDatosDetalle.oItem.Incluye = .t.
			.BaseDeDatosDetalle.Actualizar()
			.Grabar()
			.Release()
		endwith
		
		loConfiguracionDeConsulta = newobject( "AuxConfiguracionDeConsulta" )
		loConfiguracionDeConsulta.lUsaAgrupamiento = .t.

		loConfiguracion = loConfiguracionDeConsulta.ObtenerConfiguracion( "2" )
		
		This.assertequals( "La cantidad de base de datos no es la correcta.", 1, loConfiguracion.BasesDeDatos.Count )
		
		loConfiguracionDeConsulta = null
		loConfiguracion = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestBaseDeDatosSinAgrupamiento
		local loConfiguracionDeConsultaFactory as Object, loConfiguracionDeConsulta as Object, loConfiguracion as Object, ;
			loError as zooexception OF zooexception.prg

		goParametros.Nucleo.AgrupamientoParaConsultaDeStock = ""

		loConfiguracionDeConsultaFactory = _screen.zoo.crearobjeto( "ConfiguracionDeConsultaFactory" )
		loConfiguracionDeConsulta = loConfiguracionDeConsultaFactory.ObtenerObjetoConfiguracion()

		loConfiguracion = loConfiguracionDeConsulta.ObtenerConfiguracion( "2" )

		This.assertequals( "La cantidad de base de datos no es la correcta.", 1, loConfiguracion.BasesDeDatos.Count )

		loConfiguracionDeConsultaFactory = null
		loConfiguracionDeConsulta = null
		loConfiguracion = null

	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestSetearAtributoExcepcionPorAgrupamientoInexistente
		local loObjetoConfiguracion as Object 

		loObjetoConfiguracion = newobject( "AuxConfiguracionDeConsulta" )
		loObjetoConfiguracion.lUsaAgrupamiento = .t.

		_Screen.mocks.Agregarmock( "Mensajes" )
		goServicios.Mensajes = _screen.zoo.crearobjeto( "Mensajes" )
		
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Advertir', '*THROW', "[No es posible mostrar el stock mediante el agrupamiento " +  "TEST000" + ". Los datos mostrados serán de la base de datos activa.]" )

		_screen.mocks.agregarmock( "Agrupamiento" )
		_screen.mocks.AgregarSeteoMetodo( 'agrupamiento', 'Obtenerbasesdedatos', '*THROW', "[TEST000]" )

		goParametros.Nucleo.AgrupamientoParaConsultaDeStock = "TEST000"

		Try
			loResultado = loObjetoConfiguracion.ObtenerConfiguracion( "2" )
			This.asserttrue( "Debería haber tirado excepción.", .F. )
		catch to loError
			This.assertequals( "No se mostró el mensaje esperado.", "Error Generador por Mock Advertir([No es posible mostrar el stock mediante el agrupamiento TEST000. Los datos mostrados serán de la base de datos activa.])", loError.uservalue.message )

		endtry

		loObjetoConfiguracion = null
		goServicios.mensajes = goMensajes
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSetearAtributoExcepcionPorAgrupamientoInexistenteListadosNoStock
		local loObjetoConfiguracion as Object 

		loObjetoConfiguracion = _screen.zoo.crearobjeto( "ConfiguracionDeConsulta" )
		_Screen.mocks.Agregarmock( "Mensajes" )
		goServicios.Mensajes = _screen.zoo.crearobjeto( "Mensajes" )
		
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Advertir', '*THROW', "[No es posible mostrar el stock mediante el agrupamiento " +  "TEST000" + ". Los datos mostrados serán de la base de datos activa.]" )

		_screen.mocks.agregarmock( "Agrupamiento" )
		_screen.mocks.AgregarSeteoMetodo( 'agrupamiento', 'Obtenerbasesdedatos', '*THROW', "[TEST000]" )
		_screen.mocks.AgregarSeteoMetodo( 'agrupamiento', 'Obtenerbasesdedatos', '""', "[*COMODIN]" )

		goParametros.Nucleo.AgrupamientoParaConsultaDeStock = "TEST000"

		Try
			loResultado = loObjetoConfiguracion.ObtenerConfiguracion( "5" )
		catch to loError
			This.asserttrue( "No debería haber mostrador el mensaje. ", .F. )

		endtry

		loObjetoConfiguracion = null
		goServicios.mensajes = goMensajes
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
define class ObjetoMock as custom

idBuscador = ""
	*-----------------------------------------------------------------------------------------
	function GrabarSerializado( tcArchivo as String ) as Void
		return ""
	endfunc 

enddefine

**********************************************************************
define class LanzadorDeConsultaTest as LanzadorDeConsulta of LanzadorDeConsulta.prg 
	lEsNativa = .f.
	cSucursal = ""
	cStringConnection = ""
	lCodigosEnMinusculas = .f.
	
	*-----------------------------------------------------------------------------------------
	protected function LanzarBuscadorNet( toArgumentosLanzadorDeConsulta ) && tlEsNativa as Boolean, tcSucursal as String, tcStringConnection as String, tcIdBuscador as String, tlFormatoFechaLarga as Boolean ) as Void
		this.lEsNativa = toArgumentosLanzadorDeConsulta.EsNativa
		this.cSucursal = toArgumentosLanzadorDeConsulta.Sucursal
		this.cStringConnection = toArgumentosLanzadorDeConsulta.StringConnection
		this.lCodigosEnMinusculas = goParametros.Nucleo.PermiteCodigosEnMinusculas

	endfunc 
enddefine



*------------------------------------------------------------------------------------------------
define class AuxConfiguracionDeConsulta as ConfiguracionDeConsulta of ConfiguracionDeConsulta.prg

	lUsaAgrupamiento = .f.	

	*-----------------------------------------------------------------------------------------
	protected function CorrespondeUsarAgrupamiento(  tcIdFormulario as String ) as Void
		return this.lUsaAgrupamiento
	endfunc 

enddefine

