*-----------------------------------------------------------------------------------------
define class zTestGestorDeExcepcionesSQLServer as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestGestorDeExcepcionesSQLServer of zTestGestorDeExcepcionesSQLServer.prg
	#endif

	*---------------------------------
	function Setup
	endfunc

	*---------------------------------
	function TearDown
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function zTestU_ObtenerCollationMandatoriaSegunZooLogicMaster
		private goServicios
		private goLibrerias
		goServicios = _screen.Zoo.CrearObjeto( "ServiciosAplicacion" )
		goLibrerias = newobject( "MockLibrerias" )
		InicializarMockDeServicios( goServicios, goLibrerias )
		local loGestor as Object
		loGestor = newobject( "GestorDeExcepcionesSQLServer_Accesor" )
		goServicios.Librerias.cBaseDeDatosExistente = "NUCLEO_ZOOLOGICMASTER"
		this.AssertEquals( "La collation no es la esperada.", "SQL_Latin1_General_CP1_CI_AI", loGestor.ObtenerCollationMandatoria_Accesor() )
		FinalizarMockDeServicios( goServicios, goLibrerias )
		loGestor = null
		goLibrerias = null
		goServicios = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function zTestU_ObtenerCollationMandatoriaSegunADNImplant
		private goServicios
		private goLibrerias
		goServicios = _screen.Zoo.CrearObjeto( "ServiciosAplicacion" )
		goLibrerias = newobject( "MockLibrerias" )
		InicializarMockDeServicios( goServicios, goLibrerias )
		local loGestor as Object
		loGestor = newobject( "GestorDeExcepcionesSQLServer_Accesor" )
		goServicios.Librerias.cBaseDeDatosExistente = "NUCLEO_ADNIMPLANT"
		this.AssertEquals( "La collation no es la esperada.", "SQL_Latin1_General_CP1_CI_AI", loGestor.ObtenerCollationMandatoria_Accesor() )
		FinalizarMockDeServicios( goServicios, goLibrerias )
		loGestor = null
		goLibrerias = null
		goServicios = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function zTestU_ObtenerCollationMandatoriaPorDefault
		private goServicios
		private goLibrerias
		goServicios = _screen.Zoo.CrearObjeto( "ServiciosAplicacion" )
		goLibrerias = newobject( "MockLibrerias" )
		InicializarMockDeServicios( goServicios, goLibrerias )
		local loGestor as Object
		loGestor = newobject( "GestorDeExcepcionesSQLServer_Accesor" )
		goServicios.Librerias.cBaseDeDatosExistente = ""
		this.AssertEquals( "La collation no es la esperada.", "SQL_Latin1_General_CP1_CI_AI", loGestor.ObtenerCollationMandatoria_Accesor() )
		FinalizarMockDeServicios( goServicios, goLibrerias )
		loGestor = null
		goLibrerias = null
		goServicios = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function zTestU_ObtenerCollationsUtilizadasEnUnaBD
		local loGestor as Object, loCollations as Object, lcTabla as String
		loGestor = newobject( "GestorDeExcepcionesSQLServer_Accesor" )
		lcTabla = sys( 2015 )
		goServicios.Datos.EjecutarSentencias( "CREATE TABLE [ZooLogic].["+ lcTabla + "]( [Texto] [varchar] ( 100 ) COLLATE French_CI_AS NULL,) ON [PRIMARY]", "", "", "", set( "Datasession" ) )
		loCollations = loGestor.ObtenerCollationsUtilizadasEnUnaBD_Accesor( goServicios.Datos.ObtenerNombreBD( "PAISES" ) )
		this.AssertEquals( "La collation 1 no es la esperada.", "French_CI_AS", loCollations.Item[ 1 ] )
		this.AssertEquals( "La collation 2 no es la esperada.", "SQL_Latin1_General_CP1_CI_AI", loCollations.Item[ 2 ] )
		goServicios.Datos.EjecutarSentencias( "DROP TABLE [ZooLogic].[" + lcTabla + "]", "", "", "", set( "Datasession" ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function zTestU_LevantarExcepcion
		local loGestor as Object, loError as Object, lcTabla as String
		local array taError[ 1 ]
		loGestor = newobject( "GestorDeExcepcionesSQLServer_Accesor" )
		restore from ( addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\ErrorDeCollationEnBD.mem" ) additive
		try
			lcTabla = sys( 2015 )
			goServicios.Datos.EjecutarSentencias( "CREATE TABLE [ZooLogic].["+ lcTabla + "]( [Texto] [varchar] ( 100 ) COLLATE French_CI_AS NULL,) ON [PRIMARY]", "", "", "", set( "Datasession" ) )
			loGestor.LevantarExcepcion( "query sql", @taError )
		catch to loError
			this.AssertEquals( "La cantidad de mensajes información es incorrecta.", 4, loError.UserValue.oInformacion.Count )
			this.AssertEquals( "El mensaje de la información 1 no es el esperado.", chr( 13 ) + chr( 10 ) + "Instrucción SQL no realizada: query sql", loError.UserValue.oInformacion.Item[ 1 ].cMensaje )
			this.AssertEquals( "El mensaje de la información 2 no es el esperado.", "Algunos objetos de la base de datos " + _Screen.Zoo.App.cNombreBaseDeDatosSQL + " poseen la Collation French_CI_AS la cual es incorrecta.", loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
			this.AssertEquals( "El mensaje de la información 3 no es el esperado.", "Collation requerida: SQL_Latin1_General_CP1_CI_AI", loError.UserValue.oInformacion.Item[ 3 ].cMensaje )
			this.AssertEquals( "El mensaje de la información 4 no es el esperado.", "No es posible realizar esta operación. Algunas bases de datos están utilizando una Collation distinta a la requerida por la aplicación. Por favor comuniquese con la Mesa de Ayuda de Zoo Logic para recibir asistencia.", loError.UserValue.oInformacion.Item[ 4 ].cMensaje )
		finally
			goServicios.Datos.EjecutarSentencias( "DROP TABLE [ZooLogic].[" + lcTabla + "]", "", "", "", set( "Datasession" ) )
		endtry
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class GestorDeExcepcionesSQLServer_Accesor as GestorDeExcepcionesSQLServer of GestorDeExcepcionesSQLServer.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerCollationMandatoria_Accesor() as string
		return this.ObtenerCollationMandatoria()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCollationsUtilizadasEnUnaBD_Accesor( tcDB as String ) as Collection
		return this.ObtenerCollationsUtilizadasEnUnaBD( tcDB )
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
function InicializarMockDeServicios( toServicios as Object, toLibrerias as Object ) as Void
		toServicios.Datos = goDatos
		toServicios.Registry = goRegistry
		toServicios.Controles = _screen.zoo.CrearObjeto( "ServicioControles" )
		toLibrerias = newobject( "MockLibrerias" )
		toServicios.Librerias = toLibrerias
		toServicios.Parametros = goParametros
endfunc

*-----------------------------------------------------------------------------------------
function FinalizarMockDeServicios( toServicios as Object, toLibrerias as Object ) as Void
		toServicios.Datos = null
		toServicios.Registry = null
		toServicios.Controles = null
		toServicios.Librerias = null
		toServicios.Parametros = null
endfunc


*-----------------------------------------------------------------------------------------
define class MockLibrerias as Librerias of Librerias.prg
	
	cBaseDeDatosExistente = ""

	*-----------------------------------------------------------------------------------------
	function ExisteBaseDeDatos( tcRutaBaseDeDatos as String ) as Void	
		return this.cBaseDeDatosExistente == tcRutaBaseDeDatos
	endfunc

enddefine