#include registry.h
**********************************************************************
Define Class zTestAplicacionBase As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestAplicacionBase Of zTestAplicacionBase.prg
	#Endif

	oPropiedades = null	
	oApp = Null
	cRutaInicial = ""
	cSetMultilock = ""
	cOldRutasTablasSeguridad = ""
	cOldRutaRegistrosOrganizacion = ""	
	cRutaTemporal = ""
	lEsBuildAutomatico = .F.
	lDesarrollo = .F.
	oInfo = null
	cDeleted = ""
	
	cSerie = ""
	*lVerificarYEjecutarAadnImplant = .f.
	OldTiempoDeEsperaParaCerrarAplicacion = 0
	lMockearParametros = .F.
	
	*---------------------------------
	Function Setup
		local loArchivos as object, lcArchivo as string
		goformularios.setent(200)
		_screen.AddProperty( "lPasoPorProcesarAdnImplant", .f. )
		_screen.AddProperty( "lPasoPorReindexar", .f. )
		*this.lVerificarYEjecutarAadnImplant = goparametros.Nucleo.AdministradorBD.VerificarYEjecutarAdnImplant

		this.cSerie = goFormularios.leer( 1 )

		this.oPropiedades = _Screen.zoo.crearobjeto( "zooCustom" )
		This.oInfo = _screen.zoo.crearobjeto( "ZooInformacion" )
	
		This.oApp = NewObject( "AplicacionNucleo_mock" )
		This.oApp.SetearInformacion( This.oInfo )
		this.oApp.NombreProducto = _screen.zoo.app.NombreProducto
		this.oApp.TipoDeBase = _screen.zoo.app.TipoDeBase
		this.oApp.lSeccion9 = _Screen.Zoo.App.lSeccion9
		this.oApp.cSerie = _screen.zoo.app.cSerie
				
		This.cRutaInicial = _Screen.zoo.cRutaInicial
		
		loArchivos = newobject( "manejoarchivos","C:\zoo\Dlls\Generales\manejoarchivos.prg" )

		lcArchivo = addbs( _screen.Zoo.cRutaInicial ) + "Adn\dbc\Indice.DBF"
		loArchivos.setearatributos( "N", lcArchivo )
		
		lcArchivo = addbs( _screen.Zoo.cRutaInicial ) + "Adn\dbc\Indice.CDX"
		loArchivos.setearatributos( "N", lcArchivo )

		lcArchivo = addbs( _screen.Zoo.cRutaInicial ) + "Adn\dbc\Tablas.DBF"
		loArchivos.setearatributos( "N", lcArchivo )

		lcArchivo = addbs( _screen.Zoo.cRutaInicial ) + "Adn\dbc\Tablas.CDX"
		loArchivos.setearatributos( "N", lcArchivo )

		lcArchivo = addbs( _screen.Zoo.cRutaInicial ) + "Adn\dbc\Tablas.FPT"
		loArchivos.setearatributos( "N", lcArchivo )
		
		This.cOldRutaRegistrosOrganizacion = goRegistry.Nucleo.RutaRegistrosOrganizacion

		this.cRutaTemporal = _screen.zoo.obtenerrutatemporal()
		
		this.cSetMultilock = set("Multilocks")
		
		this.lEsBuildAutomatico = _screen.zoo.esbuildautomatico 
		this.lDesarrollo = _screen.zoo.ldesarrollo 

		_Screen.mocks.agregarmock( "ConfigurarAgenteDeAccionesOrganic" )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAGENTEDEACCIONESORGANIC', 'Configuraragenteporactualizacion', .T. )
		
		GuardarEntorno( this )	
		loArchivos = null
		This.OldTiempoDeEsperaParaCerrarAplicacion = goRegistry.Nucleo.TiempoDeEsperaParaCerrarAplicacion
		this.cDeleted = set( "Deleted" )
		goParametros.Nucleo.Actualizaciones.BuscarActualizacionesAlIniciar = .f.
		set deleted on
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function TearDown
		local lnSessionLocal as Integer, lcExclusive as String, lcMultilock as String, ;
			loManejoDeArchivos as Object, lcDirectorio as String, lcDeleted as String

		_Screen.zoo.cRutaInicial = This.cRutaInicial
		removeproperty( _Screen, "lPasoPorProcesarAdnImplant" )
		removeproperty( _screen, "lPasoPorReindexar" )
		
		_screen.mocks.vaciar()
		RestablecerEntorno( this )
		
		this.oPropiedades.oPoolConexiones = null
		
		this.oPropiedades.destroy()

		goDatos.EjecutarSentencias( "delete from emp where alltrim( upper( empcod )) <> 'PAISES' and  alltrim( upper( empcod )) <> 'COUNTRYS'", "Emp", Addbs( _Screen.zoo.cRutaInicial ))		
		
		if file( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.dbf.txt" )
			delete file ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.dbf" )
			rename ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.dbf.txt" )	to ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.dbf" )
		endif

		if file( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.cdx.txt" )
			delete file ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.cdx" )
			rename ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.cdx.txt" )	to ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\indice.cdx" )
		endif
		
		if file( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.dbf.txt" )
			delete file ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.dbf" )
			rename ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.dbf.txt" )	to ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.dbf" )
		endif
		
		if file( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.cdx.txt" )
			delete file ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.cdx" )
			rename ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.cdx.txt" )	to ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.cdx" )
		endif

		if file( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.fpt.txt" )
			delete file ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.fpt" )
			rename ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.fpt.txt" )	to ( addbs( _screen.zoo.cRutaInicial ) + "adn\dbc\tablas.fpt" )
		endif

		loManejoDeArchivos = Newobject( "manejoarchivos","C:\zoo\Dlls\Generales\manejoarchivos.prg" )
		lcDirectorio = Addbs( _Screen.zoo.cRutaInicial ) + "sucursal\CopyaBD"
		loManejoDeArchivos.BorrarCarpeta ( lcDirectorio )
		loManejoDeArchivos.BorrarCarpeta ( lcDirectorio + '1' )

		this.EjecutarSentencias( "Select * from emp", "Emp", _screen.zoo.cRutaInicial, "EmpAux", set("Datasession"))
		this.assertequals( "Error en la cantidad de registros de EMP al terminar el test. Verifique", 2, reccount( "EmpAux" ) )

		use in select( "EmpAux" )

		if vartype( this.oApp ) = "O"
			This.oApp.Release()	
		endif	
		
		goRegistry.Nucleo.RutaRegistrosOrganizacion = This.cOldRutaRegistrosOrganizacion
		
		lcMultilock = this.cSetMultilock
		set Multilocks &lcMultilock
		_screen.zoo.app.lEstoyUsandoTimers = .F.

		_screen.zoo.esbuildautomatico = this.lEsBuildAutomatico 
		_screen.zoo.ldesarrollo = this.lDesarrollo

		goFormularios.SetearS( this.cSerie )
		loManejoDeArchivos = null

		goservicios.asignarservicios()
		*goparametros.Nucleo.AdministradorBD.VerificarYEjecutarAdnImplant = this.lVerificarYEjecutarAadnImplant
		goRegistry.Nucleo.TiempoDeEsperaParaCerrarAplicacion = This.OldTiempoDeEsperaParaCerrarAplicacion

		if file( _screen.zoo.crutainicial + "chkrz.txt" )
			delete file _screen.zoo.crutainicial + "chkrz.txt"
		endif 			
		
		lcDeleted = this.cDeleted		
		set deleted &lcDeleted	
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestAperturaAutomatidaDeEntidades
		local loEntidad as Object, loFormularios as Object, lcUsuLogueado as String   
		lcUsuLogueado = goServicios.seGURIDAD.cUltimoUsuarioLogueado 
		loFormularios = goServicios.Formularios
		goServicios.seGURIDAD.cUltimoUsuarioLogueado = 'ADMIN'
		loEntidad = _screen.zoo.instanciarentidad('APERTURAAUTOMATICAENTIDADES') 
		try
			loEntidad.Usuario = "ADMIN"
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.nuevo()
		
		with loEntidad.AccionesDetalle
			.oItem.Entidad = "APERTURAAUTOMATICAENTIDADES"
			.Actualizar()
			.LimpiarItem()
			.oItem.Entidad = "CUBA"
			.Actualizar()
			.LimpiarItem()	
			.oItem.Entidad = "ARGENTINA"
			.Actualizar()
			.LimpiarItem()					
		endwith		
		loEntidad.grabar()
		loEntidad.release()		

		goServicios.Formularios = _screen.zoo.crearobjeto( 'goFormulariosAuxMock', 'zTestAplicacionBase.prg' ) 
 
		_Screen.Zoo.App.AperturaAutomaticaDeEntidades()
		this.assertequals( "La cantidad de Formularios instanciados debe ser tres.", 3 , goServicios.Formularios.oColeccionFormularios.count )
		this.assertequals( "Usurio incorrecto", 'ADMIN' , goServicios.seGURIDAD.cUltimoUsuarioLogueado )

		goServicios.seGURIDAD.cUltimoUsuarioLogueado = lcUsuLogueado 
		goServicios.Formularios = loFormularios 
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ztestInicializarBaseDeDatos
		local loAplicacionBase as Object, lcSucursal as string, lcSql as String, lcPath as String

		_screen.mocks.agregarmock( "ChequeoParametrosNucleo" )
		_screen.mocks.AgregarSeteoMetodo( 'CHEQUEOPARAMETROSNUCLEO', 'Chequear', .T. )
		this.assertequals( "La Sucursal Activa es incorrecta", _Screen.Zoo.app.cSucursalActiva , 'Paises')

		lcSucursal = 'PETER'
		lcPath = Addbs( _Screen.zoo.cRutaInicial ) + "Sucursal"
		lcSql = "Insert Into emp ( empCod,  ePath, eUnid, color_bd ) Values ( '" + lcSucursal + "', '" + lcPath + "', 'C', 65535)"

		goDatos.EjecutarSentencias( lcSql, "emp.dbf", _Screen.Zoo.cRutaInicial, "", _Screen.Zoo.DatasessionId )

		_Screen.Zoo.App.lSinSucursalActiva = .t.					
		_Screen.Zoo.App.cSucursalActiva = lcSucursal
		_Screen.Zoo.App.InicializarBaseDeDatos()
		this.assertequals( "La Sucursal Activa es incorrecta 1", lcSucursal , _Screen.Zoo.app.cSucursalActiva )

		_Screen.Zoo.App.InicializarBaseDeDatos()
	
		this.assertequals( "La Sucursal Activa es incorrecta 2", lcSucursal , _Screen.Zoo.app.cSucursalActiva )
	endfunc
			
	*-----------------------------------------------------------------------------------------
	function zTestValidarExistenciaDeFuentes
		Local loAplicacion As Object, llRetorno As Boolean
		
		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "'El sistema no tiene instalada la fuente Tahoma ni la fuente DIN Mittelschrift Std. Es posible que no pueda visualizar correctamente las pantallas.'" )		
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "'El sistema no tiene instalada la fuente DIN Mittelschrift Std. Es posible que no pueda visualizar correctamente las pantallas.'" )		
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "'El sistema no tiene instalada la fuente Tahoma. Es posible que no pueda visualizar correctamente las pantallas.'" )		
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )
	
		loAplicacion = This.oAPP

		This.asserttrue( "No existe el metodo ValidarExistenciaDeFuentes", pemstatus( loAplicacion, 'ValidarExistenciaDeFuentes' ,5) )

		llRetorno = loAplicacion.ValidarExistenciaDeFuentes()
		
		if !llRetorno
			This.assertTrue( loAplicacion.oInformacion( 1 ).cMensaje , llRetorno )
		EndIf	
			
		loAplicacion = Null
		goMensajes = _screen.zoo.app.oMensajes
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestInstanciar
		local loapp as aplicacionbase of aplicacionbase.prg, lcTituloParaLaVentanaDelMonitor as String

		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase
		
		This.assertnotnull( "No se Instacio la Aplicacion", loApp )

		with loApp
			This.assertequals( "El nombre del proyecto esta mal cargado" , "Nucleo", This.oApp.Nombre  )
			This.assertequals( "El nombre de la sucursal esta mal cargado" , "", .cSucursalActiva )

			This.asserttrue( "La propiedad oFormPrincipal no existe" , Pemstatus( loApp, 'oFormPrincipal', 5 ) )
			This.asserttrue( "La propiedad lSinSucursalActiva no existe" , Pemstatus( loApp, 'lSinSucursalActiva', 5 ) )
			This.asserttrue( "La propiedad lSinSucursalActiva no esta inicializada en .F." , !.lSinSucursalActiva )
			This.asserttrue( "La propiedad TipoDeBase no existe" , Pemstatus( loApp, 'TipoDeBase', 5 ) )
			This.asserttrue( "La propiedad cProducto no existe" , Pemstatus( loApp, 'cProducto', 5 ) )
			This.Assertequals( "La propiedad cProducto está mal seteada" , "00" , alltrim( loApp.cProducto ) )
			This.assertTrue( "La propiedad 'lUtilizaPrefijoDB' no existe", pemstatus( loApp, 'lUtilizaPrefijoDB', 5 ) )

			This.asserttrue( "La propiedad cRutaTablasSeguridad no existe" , Pemstatus( loApp, 'cRutaTablasSeguridad', 5 ) )
			This.asserttrue( "la propiedad nColorBD no existe", Pemstatus( loApp, 'nColorBD', 5))

			This.asserttrue( "La propiedad oMonitor no existe" , Pemstatus( loApp, 'oMonitor', 5 ) )
			This.asserttrue( "La propiedad oExportaciones no existe" , Pemstatus( loApp, 'oExportaciones', 5 ) )
			This.assertTrue( "La propiedad 'cRutaTablasOrganizacion' no existe", pemstatus( loApp, 'cRutaTablasOrganizacion', 5 ) )
			This.assertTrue( "La propiedad 'cRutaTablasPuesto' no existe", pemstatus( loApp, 'cRutaTablasPuesto', 5 ) )		
			This.Assertequals( "No se llenó correctamente la propiedad 'cRutaTablasOrganizacion'", _screen.zoo.cRutaInicial, loApp.cRutaTablasOrganizacion )
			This.Assertequals( "No se llenó correctamente la propiedad 'cRutaTablasPuesto'", _screen.zoo.cRutaInicial, loApp.cRutaTablasPuesto )			
			This.assertTrue( "No se inicializo correctamente la propiedad 'lUtilizaPrefijoDB' Debe estar siempre en .t.", loApp.lUtilizaPrefijoDB )
			
			This.Assertequals( "No se cargo correctamente la propiedad 'cSchemaDefault'", ;
				'ZooLogic', loApp.cSchemaDefault )

			.release()
		endwith
	Endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ztestBajarServiciosYSalirSiFallo_Mensaje
		local loapp as aplicacionbase of aplicacionbase.prg, lcTexto as string, ;
			loError as Exception 

		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )

		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', "*THROW", "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', "*THROW", "'ERROR'" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Advertir', .T., "'*OBJETO',0" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., "[Optimizando ingreso al sistema...]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., ".T." )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., "[Espere por favor...]" )

		loApp = this.oApp
		
		with loApp 
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
			.Iniciar()
		endwith
				
		with loApp
			try
				.BajarServiciosYSalirSiFallo( "ERROR", .f. )
				this.Asserttrue( "debe dar error (1)", .f. )
			catch to loError
				this.assertequals( "El mensaje es incorrecto (1)", "Error Generador por Mock Enviar('*OBJETO')", loError.uservalue.message )
			endtry

			try
				.BajarServiciosYSalirSiFallo( "ERROR", .t. )
				this.Asserttrue( "debe dar error (2)", .f. )
			catch to loError
				this.assertequals( "El mensaje es incorrecto (2)", "Error Generador por Mock Enviarsinespera([ERROR])", loError.uservalue.message )
			endtry
		endwith
		
		loapp.release()
		goServicios.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestIniciarServicio
		local loAp as aplicacionbase of aplicacionbase.prg, lcOrig as string, loError as Exception , lcSerie  as string, ;
			loCol as zoocoleccion OF zoocoleccion.prg, loBindeo as Object

		*** Estas variables privadas son para que el mock TestManagerFormulariosNucleo devuelva entradas o Obs
		private pnObtDesEncEnt, pcObs, pcCodigoBloq
		*** Estas variables privadas son para que el mock TestLibreriasNucleo devuelva fecha y hora
		private pdFecha, pcHora
		
		pdFecha = ctod( "17/01/2008" )
		pcHora = "10:00"

		_screen.mocks.agregarmock( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "111111", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "Compumundo", "4" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "hipermegar", "5" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ed        ", "6" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "          ", "7" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "la organiz", "8" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ación mas ", "9" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "torpe del ", "10" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "mundo     ", "11" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obs', "FRUTA" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "FRUTA", "3" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Sre', .T., "-1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obtdesencent', 10 )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esd', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Traeralfrente', .T., "'*OBJETO'" )
		_screen.mocks.agregarmock( "Librerias", "TestLibreriasNucleo", "TestLibreriasNucleo.prg" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Estainstalado', .T., "[" + getenv("COMPUTERNAME") + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[" + upper( alltrim( substr( sys( 0 ), at( "#" , sys( 0 ) ) + 2 ) ) ) + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[*COMODIN]")
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Armarnombreperfilsegunentorno', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Cnombreperfil_access', .T. )
				
		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )
				
		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', "*THROWUSUARIO", "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Advertir', .T., "'*OBJETO',0" )

		loCol = _screen.zoo.crearobjeto( "zooColeccion" )

		_screen.mocks.agregarmock( "Modulos" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Obtenermodulos', loCol )

		loAp = newobject( "AplicacionBase2" )
		loAp.NombreProducto = _screen.zoo.app.NombreProducto
		loAp.TipoDeBase = _screen.zoo.app.TipoDeBase
				
		with loAp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
		endwith
		
		loAp.oMonitor = newobject( "custom" )

		loAp.Iniciar()
		
		lcServicio = "oMonitor"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )
		This.AssertEquals( lcServicio + ". No debe estanciar el nuevo monitor, debe dejar el objeto anterior", "Custom", loAp.&lcServicio..Class )

		loAp.oMonitor = "PEPE"
		loAp.Iniciar()
		
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )
		This.AssertEquals( lcServicio + ". Debe estanciar el nuevo monitor", "Managermonitor", loAp.&lcServicio..Class )

		loAp.release()
		goServicios.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestIniciar
		local loAp as aplicacionbase of aplicacionbase.prg, lcOrig as string, loError as Exception , lcSerie  as string, ;
			loCol as zoocoleccion OF zoocoleccion.prg, loBindeo as Object, lcLeer3 as String

		*** Estas variables privadas son para que el mock TestManagerFormulariosNucleo devuelva entradas o Obs
		private pnObtDesEncEnt, pcObs, pcCodigoBloq
		*** Estas variables privadas son para que el mock TestLibreriasNucleo devuelva fecha y hora
		private pdFecha, pcHora
        lcLeer3 = goFormularios.Leer(3)
		pdFecha = ctod( "17/01/2008" )
		pcHora = "10:00"

		_screen.mocks.agregarmock( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "111111", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "Compumundo", "4" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "hipermegar", "5" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ed        ", "6" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "          ", "7" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "la organiz", "8" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ación mas ", "9" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "torpe del ", "10" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "mundo     ", "11" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obs', "FRUTA" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "FRUTA", "3" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Sre', .T., "-1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obtdesencent', 10 )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esd', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Traeralfrente', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Estainstalado', .T., "[" + getenv("COMPUTERNAME") + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[" + upper( alltrim( substr( sys( 0 ), at( "#" , sys( 0 ) ) + 2 ) ) ) + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[*COMODIN]")
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Armarnombreperfilsegunentorno', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Cnombreperfil_access', .T. )
						
		_screen.mocks.agregarmock( "Librerias", "TestLibreriasNucleo", "TestLibreriasNucleo.prg" )

		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )
				
		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', "*THROWUSUARIO", "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Advertir', .T., "'*OBJETO',0" )

		loCol = _screen.zoo.crearobjeto( "zooColeccion" )

		_screen.mocks.agregarmock( "Modulos" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Obtenermodulos', loCol )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Verificarmodulosaas', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Verificarmodulosaas', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Verificarmodulosaas', .T. ) 

		goServicios.Librerias.Release()
		goServicios.Librerias = _screen.zoo.crearobjeto( "Librerias" )
		goLibrerias = goServicios.Librerias

		loAp = newobject( "AplicacionBase2" )
		loAp.NombreProducto = _screen.zoo.app.NombreProducto
		loAp.TipoDeBase = _screen.zoo.app.TipoDeBase
				
		loBindeo = newobject( "ObjetoBindeo" )

		bindevent( loAp, "Sacaratributossololectura", loBindeo, "Sacaratributossololectura" )
		bindevent( loAp, "IniciarServicio", loBindeo, "IniciarEstilos" )

		with loAp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
		endwith

		loBindeo.lPasoPorSacaratributossololectura = .f.
		loBindeo.lPasoPorIniciarEstilos = .f.
		
		loAp.Iniciar()
		
		this.asserttrue( "Deberia correr el metodo IniciarServiciosSinDependencia", 0 < loAp.nOrdenIniciarServiciosSinDependencia )
		this.asserttrue( "Deberia correr el metodo IniciarServiciosConDependencia", 0 < loAp.nOrdenIniciarServiciosConDependencia )
		this.asserttrue( "Deberia correr el metodo SetearAplicacion", 0 < loAp.nOrdenSetearAplicacion )
		this.asserttrue( "Deberia correr el metodo IniciarServiciosSinDependencia antes del metodo SetearAplicacion", loAp.nOrdenSetearAplicacion < loAp.nOrdenIniciarServiciosSinDependencia )
		this.asserttrue( "Deberia correr el metodo IniciarServiciosConDependencia antes del metodo SetearAplicacion", loAp.nOrdenSetearAplicacion < loAp.nOrdenIniciarServiciosConDependencia )
		
		this.asserttrue( "No pasó por el metodo Sacaratributossololectura al iniciar", loBindeo.lPasoPorSacaratributossololectura )
		this.asserttrue( "No pasó por el metodo IniciarEstilos al iniciar", loBindeo.lPasoPorIniciarEstilos )
		
		lcServicio = "oDatos"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oFormularios"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oMonitor"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oLibrerias"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oMensajes"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oServicioControles"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "goControles"  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , goControles )

		lcServicio = "oParametros"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oRegistry"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )
		
		lcServicio = "oModulos"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oEstilos"
		This.AssertTrue( lcServicio + ". No Existe la variable publica", type( "g" + lcServicio  ) = "O")
		This.AssertEquals( lcServicio + ". La referencia es erronea", loAp.&lcServicio , evaluate( "g" + lcServicio ) )

		lcServicio = "oTimerBase"
		This.AssertTrue( "Falta el objeto oTimerBase en la app", pemstatus( loAp, "oTimerBase", 5 ) )

	*****************
		_screen.mocks.agregarmock( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "111111", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obs', "FRUTA" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "FRUTA", "3" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Sre', .T., "-1" )

		loAp.release()
		
		loAp = newobject( "AplicacionBase2" )
		loAp.NombreProducto = _screen.zoo.app.NombreProducto
		loAp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		with loAp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
		endwith

		try
			loAp.Iniciar()
		catch to loError
			this.AssertTrue( "No debe dar error al iniciar (1)" + chr( 13 ) + loError.UserValue.message, .f. )
		endtry

		_screen.mocks.agregarmock( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "*THROW", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Sre', .T., "-1" )
		
		loAp.release()
		loAp = newobject( "AplicacionBase2" )
		loAp.NombreProducto = _screen.zoo.app.NombreProducto
		loAp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		with loAp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
		endwith

		try
			loAp.Iniciar()
			this.Asserttrue( "debe dar error (1)", .f. )
		catch to loError
			this.AssertEquals( "El mensaje de error no es el correcto", "Error Generador por Mock Leer(1)", loError.UserValue.message )
		endtry
		

		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .t., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Mostrarscx', "*THROW", "'FrmPedirClave',.T.,'*OBJETO'" )
		
		_screen.mocks.agregarmock( "Librerias", "TestLibreriasNucleo", "TestLibreriasNucleo.prg" )
		
		try
			loAp.Iniciar()
		catch to loError
			this.AssertEquals( "El mensaje de error no es el correcto (1)", ;
					"Error Generador por Mock Mostrarscx([FrmPedirClave],.T.,'*OBJETO')", loError.UserValue.message )
		endtry
		goServicios.Librerias.Release()
		goServicios.Librerias = _screen.zoo.crearobjeto( "Librerias" )
		loAp.oLibrerias = goServicios.Librerias
		this.AssertTrue( "No debe salir", !loAp.oLibrerias.lSalir )
		
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Mostrarscx', .f., "'FrmPedirClave',.T.,'*OBJETO'" )

		try
			loAp.Iniciar()
		catch to loError
			this.AssertEquals( "El mensaje de error no es el correcto (2)", ;
					"Error Generador por Mock Mostrarscx('FrmPedirClave',.T.,'*OBJETO')", loError.UserValue.message )
		endtry
		this.AssertTrue( "Debe salir", loAp.oLibrerias.lSalir )

		* test por .t.
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'SetearDO', "*THROW", "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Mostrarscx', .t., "'FrmPedirClave',.T.,'*OBJETO'" )

		try
			loAp.Iniciar()
		catch to loError
			this.AssertEquals( "El mensaje de error no es el correcto (3)", ;
					"Error Generador por Mock Seteardo('*OBJETO')", loError.UserValue.message )
		endtry

	*****************
		_screen.mocks.quitarmockpornombre( "MANAGERFORMULARIOS" )
		_screen.mocks.agregarmock( "ManagerFormularios", "TestManagerformulariosNucleo", "TestManagerformulariosNucleo.prg" )

		_screen.mocks.agregarmock( "Librerias", "TestLibreriasNucleo", "TestLibreriasNucleo.prg" )

		loAp.release()
		loAp = this.oApp
		with loAp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""

			this.assertequals( "El atributo serie no esta vacio", "", _screen.zoo.app.cSerie )

		endwith

		pnObtDesEncEnt = -100
		pcObs = ""
		pcCodigoBloq = ""

		try
			loAp.Iniciar()
		catch to loError
			this.AssertTrue( "No debe dar error al iniciar (2)" + chr( 13 ) + ;
				loError.UserValue.message, .f. )
		endtry
		goServicios.Librerias.Release()
		goServicios.Librerias = _screen.zoo.crearobjeto( "Librerias" )
		loAp.oLibrerias = goServicios.Librerias
		this.assertequals( "El atributo serie es incorrecto", "106046", _screen.zoo.app.cSerie )
		
		goFormularios.SetearS( "123456" )
		pnObtDesEncEnt = -100
		loAp.oLibrerias.lSalir = .f.

		loAp.Iniciar()
		
		this.AssertTrue( "NO Debe salir por error en SRE", !loAp.oLibrerias.lSalir )		

       
		pcObs = "OTRACOSA"
		pnObtDesEncEnt = 100
		goFormularios.SetearS( "FRUTA" )

		loAp.oLibrerias.lSalir = .f.

		loAp.Iniciar()
		this.AssertTrue( "NO Debe salir por error en HW", !loAp.oLibrerias.lSalir )		

        goFormularios.Escribir(3, lcLeer3)
		loAp.release()
        
		_screen.mocks.quitarmockpornombre( "Librerias" )
		goServicios.Librerias.Release()
		_Screen.Zoo.App.oLibrerias = goServicios.Librerias
		goServicios.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ztestEsquemaSeguridad
		local lcDirectorio as String, loApp as aplicacionBase of AplicacionBase.prg

		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		
		with loApp
			.Nombre = "Nucleo1"
			.cProyecto = "NUCLEO2"
		endwith
		
		lcDirectorio = addbs( addbs( _screen.zoo.cRutaInicial ) + sys( 2015 ) )

		goRegistry.Nucleo.RutaRegistrosOrganizacion = lcDirectorio

		loApp.SeteoEsquemaSeguridad()

		This.assertequals( "No se seteo la propiedad Rutas de Organizacion correctamente." , ;
			alltrim( lcDirectorio ), loApp.cRutaParametrosOrganizacion )

		loApp.release()
	Endfunc 


	*-----------------------------------------------------------------------------------------
	Function zTestColorBaseDeDatos
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		lcPath = Addbs( _Screen.zoo.cRutaInicial )

		goServicios.Datos.EjecutarSentencias( "insert into emp ( empCod, ePath, eUnid, color_bd ) values ( 'BASE2', '" + lcPath + "', 'C', 65535 )", "Emp.dbf", lcPath )

		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase
				
		with loApp
			.cSucursalActiva = "Base2"
		endwith
		
		This.asserttrue( "El nombre de la sucursal esta mal cargado" , loApp.cSucursalActiva = "Base2")

		loApp.CargarSucursales()
		This.assertEquals( "No se obtuvo correctamente el color de la base de Datos", 65535, loApp.ObtenerColorBD() )

		loApp.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_ChequearParametros
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		_screen.mocks.Agregarmock( "ChequeoParametrosNucleo" )
		_screen.mocks.AgregarSeteoMetodo( 'CHEQUEOPARAMETROSNUCLEO', 'Chequear', .T. )

		lcPath = Addbs( _Screen.zoo.cRutaInicial )
		goServicios.Datos.EjecutarSentencias( "insert into emp ( empCod, ePath, eUnid, color_bd ) values ( 'BASE2', '" + lcPath + "', 'C', 65535 )", "Emp.dbf", lcPath )

		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase
		loApp.cProyecto = "Nucleo"
				
*		goParametros.Nucleo.OrigenDeDatosPreferente = ""
		
		loApp.cSucursalActiva = "Base2"
		loApp.release()

		_Screen.mocks.verificarejecuciondemocksunaclase("ChequeoParametrosNucleo" )
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestValorReplicaBaseDeDatos
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		goParametros.Nucleo.OrigenDeDatosPreferente = "BASEAUX1"
		
		_screen.Mocks.AgregarMock( "ServicioDatos", "ServicioDatosTest", this.Class + ".prg" )
		private goServicios, goDatos
		goServicios = _screen.zoo.crearObjeto( 'ServiciosAplicacion' )
		goDatos = newobject( 'ServicioDatosTest', this.Class + ".prg" )
		goServicios.Datos = goDatos

		loApp = newobject( "AplicacionNucleoTest" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase

		loApp.CargarSucursales()

		with loApp
			.cSucursalActiva = "BASEAUX1"
		endwith
		This.AssertEquals( "No se obtuvo correctamente el valor del campo replica de la base de Datos", .f., loApp.ObtenerValorReplicaBD() )

		with loApp
			.cSucursalActiva = "BASEAUX2"
		endwith
		This.AssertEquals( "No se obtuvo correctamente el valor del campo replica de la base de Datos", .t., loApp.ObtenerValorReplicaBD() )

		loApp.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_TablasPermitenABMReplica
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = _Screen.zoo.Crearobjeto( "AplicacionBase" )		

		with loApp
			This.AssertTrue( "No se encuentra la coleccion con las tablas permitidas." , pemstatus( loApp, "oTablasPermitenABMReplica", 5 ) )
			this.AssertEquals( "Deberian haber dos tablas que permiten ABM en Replica.", 2, loApp.oTablasPermitenABMReplica.Count )
			this.AssertEquals( "No es la tabla esperada(1).", "MEM", upper( alltrim( loApp.oTablasPermitenABMReplica.Item[1] ) ) )
			this.AssertEquals( "No es la tabla esperada(2).", "LOGUEOACCESOS", upper( alltrim( loApp.oTablasPermitenABMReplica.Item[2] ) ) )
			.Release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_EsUnaTablaQuePermiteABMEnReplica
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = _Screen.zoo.Crearobjeto( "AplicacionBase" )		

		with loApp
			&& La unica manera de testear que solo se permiten las tablas de esta coleccion y no alguna otra de mas, es controlando que se testea una por una.
			this.Assertequals( "No se testearon todos los casos posibles", 2, .oTablasPermitenABMReplica.Count )
			This.AssertTrue( "Deberia permitir ABM en esta tabla(1).", .EsUnaTablaQuePermiteABMEnReplica( "mem" ) )
			This.AssertTrue( "Deberia permitir ABM en esta tabla(1.1).", .EsUnaTablaQuePermiteABMEnReplica( "mem.dbf" ) )
			This.AssertTrue( "Deberia permitir ABM en esta tabla(2).", .EsUnaTablaQuePermiteABMEnReplica( "logueoaccesos" ) )
			This.AssertTrue( "Deberia permitir ABM en esta tabla(2.1).", .EsUnaTablaQuePermiteABMEnReplica( "logueoaccesos.dbf" ) )
			.Release()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_NoEsUnaTablaQuePermiteABMEnReplica
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = _Screen.zoo.Crearobjeto( "AplicacionBase" )		

		with loApp
			This.AssertTrue( "No deberia permitir ABM en esta tabla.", !.EsUnaTablaQuePermiteABMEnReplica( "disexpo" ) )
			.Release()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_PermiteABMVerificaTablasPermitidas
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = newobject( "AplicacionNucleoTest" )
		with loApp
			.lPasoPorMetodo = .F.
			.cTablaParametro = "tablaPrueba"
			.nContador = 1
			.oFxu = this
			.PermiteABM( "tablaPrueba1" )
			This.AssertTrue( "Deberia haber pasado por el metodo.", .lPasoPorMetodo )
			.Release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_PermiteABMNoDeberiaVerificarTablasPermitidas
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = newobject( "AplicacionNucleoTest" )

		with loApp
			.lPasoPorMetodo = .F.
			.PermiteABM()
			This.AssertTrue( "No deberia haber pasado por el metodo porque el metodo no pasa el nombre de la tabla como parametro.", !.lPasoPorMetodo )
			.Release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_PermiteModificarOEliminarEnBaseVerificaTablasPermitidas
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = newobject( "AplicacionNucleoTest" )

		with loApp
			.lPasoPorMetodo = .F.
			.cTablaParametro = "tablaSimple"
			.nContador = 1
			.oFxu = this
			.PermiteModificarOEliminarEnBase( "sentencia", "tablaSimple1" )
			This.AssertTrue( "Deberia haber pasado por el metodo.", .lPasoPorMetodo )
			.lPasoPorMetodo = .F.
			.cTablaParametro = "tablaCompuesta"
			.nContador = 1
			.oFxu = this
			.PermiteModificarOEliminarEnBase( "sentencia", "tablaCompuesta1,tablaCompuesta2" )
			This.AssertTrue( "Deberia haber pasado por el metodo (2).", .lPasoPorMetodo )
			.Release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_PermiteModificarOEliminarEnBaseNoDeberiaVerificarTablasPermitidas
		local loApp as aplicacionbase of aplicacionbase.prg

		loApp = newobject( "AplicacionNucleoTest" )

		with loApp
			.lPasoPorMetodo = .F.
			.PermiteModificarOEliminarEnBase()
			This.AssertTrue( "No deberia haber pasado por el metodo (1).", !.lPasoPorMetodo )
			.lPasoPorMetodo = .F.
			.PermiteModificarOEliminarEnBase( "sentencia" )
			This.AssertTrue( "No deberia haber pasado por el metodo (2).", !.lPasoPorMetodo )
			.Release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestPermiteModificarOEliminarEnBase
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		goParametros.Nucleo.OrigenDeDatosPreferente = "BASEAUX1"
		
		_screen.Mocks.AgregarMock( "ServicioDatos", "ServicioDatosTest", this.Class + ".prg" )
		private goServicios, goDatos
		goServicios = _screen.zoo.crearObjeto( 'ServiciosAplicacion' )
		goDatos = newobject( 'ServicioDatosTest', this.Class + ".prg" )
		goServicios.Datos = goDatos

		loApp = newobject( "AplicacionNucleoTest" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase

		loApp.CargarSucursales()

		with loApp
			.cSucursalActiva = "BASEAUX2"
		endwith
		This.AssertEquals( "No debería haber permitido insertar.", .f., loApp.PermiteModificarOEliminarEnBase( "Insert into bla bla bla" ) )
		This.AssertEquals( "No debería haber permitido modificar.", .f., loApp.PermiteModificarOEliminarEnBase( "update tabla bla bla bla" ) )
		This.AssertEquals( "No debería haber permitido eliminar.", .f., loApp.PermiteModificarOEliminarEnBase( "delete from tabla" ) )
		This.AssertEquals( "Debería haber permitido consultar.", .T., loApp.PermiteModificarOEliminarEnBase( "select * from tabla" ) )

		with loApp
			.cSucursalActiva = "BASEAUX1"
		endwith
		This.AssertEquals( "Debería haber permitido.", .T., loApp.PermiteModificarOEliminarEnBase( "Insert into tabla2 bla bla bla" ) )

		loApp.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestPermiteABMSinParametro
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		goParametros.Nucleo.OrigenDeDatosPreferente = "BASEAUX1"
		
		_screen.Mocks.AgregarMock( "ServicioDatos", "ServicioDatosTest", this.Class + ".prg" )
		private goServicios, goDatos
		goServicios = _screen.zoo.crearObjeto( 'ServiciosAplicacion' )
		goDatos = newobject( 'ServicioDatosTest', this.Class + ".prg" )
		goServicios.Datos = goDatos

		loApp = newobject( "AplicacionNucleoTest" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase

		loApp.CargarSucursales()

		with loApp
			.cSucursalActiva = "BASEAUX2"
		endwith
		This.AssertEquals( "No debería haber permitido insertar.", .f., loApp.PermiteABM() )

		with loApp
			.cSucursalActiva = "BASEAUX1"
		endwith
		This.AssertEquals( "Debería haber permitido.", .T., loApp.PermiteABM() )

		loApp.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestPermiteABMConParametroConTablasDeSucursal
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		goParametros.Nucleo.OrigenDeDatosPreferente = "BASEAUX1"
		
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		private goServicios, goDatos
		goServicios = _screen.zoo.crearObjeto( 'ServiciosAplicacion' )
		goDatos = newobject( 'ServicioDatosTest', this.Class + ".prg" )
		goServicios.Datos = goDatos

		loApp = newobject( "AplicacionNucleoTest" )
		with loApp
			.NombreProducto = _screen.zoo.app.NombreProducto
			.TipoDeBase = _screen.zoo.app.TipoDeBase
			.oFxu = this
			.nContador = 1
			.cTablaParametro = "SoyTablaDeSucursal"		
			.CargarSucursales()
			.cSucursalActiva = "BASEAUX2"
			This.AssertEquals( "No debería haber permitido.", .f., .PermiteABM( "SoyTablaDeSucursal1" ) )
			.nContador = 1
			.cSucursalActiva = "BASEAUX1"
			This.AssertEquals( "Debería haber permitido.", .T., .PermiteABM( "SoyTablaDeSucursal1" ) )
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestPermiteABMConParametroConTablasDePuesto
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		goParametros.Nucleo.OrigenDeDatosPreferente = "BASEAUX1"
		
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "PUESTO", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "PUESTO", "[*COMODIN]" )
		private goServicios, goDatos
		goServicios = _screen.zoo.crearObjeto( 'ServiciosAplicacion' )
		goDatos = newobject( 'ServicioDatosTest', this.Class + ".prg" )
		goServicios.Datos = goDatos

		loApp = newobject( "AplicacionNucleoTest" )
		with loApp
			.NombreProducto = _screen.zoo.app.NombreProducto
			.TipoDeBase = _screen.zoo.app.TipoDeBase
			.oFxu = this
			.nContador = 1
			.cTablaParametro = "SoyTablaDePuesto"		
			.CargarSucursales()
			.cSucursalActiva = "BASEAUX2"
			This.AssertEquals( "Debería haber permitido.", .T., .PermiteABM( "SoyTablaDePuesto1" ) )
			.nContador = 1
			.cSucursalActiva = "BASEAUX1"
			This.AssertEquals( "Debería haber permitido.", .T., .PermiteABM( "SoyTablaDePuesto1" ) )
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestPermiteABMConParametroConTablasDeOrganizacion
		Local lcPath As String, loApp as aplicacionBase of AplicacionBase.prg

		goParametros.Nucleo.OrigenDeDatosPreferente = "BASEAUX1"
		
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "ORGANIZACION", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "ORGANIZACION", "[*COMODIN]" )
		private goServicios, goDatos
		goServicios = _screen.zoo.crearObjeto( 'ServiciosAplicacion' )
		goDatos = newobject( 'ServicioDatosTest', this.Class + ".prg" )
		goServicios.Datos = goDatos

		loApp = newobject( "AplicacionNucleoTest" )
		with loApp
			.NombreProducto = _screen.zoo.app.NombreProducto
			.TipoDeBase = _screen.zoo.app.TipoDeBase
			.oFxu = this
			.nContador = 1
			.cTablaParametro = "SoyTablaDeOrganizacion"		
			.CargarSucursales()
			.cSucursalActiva = "BASEAUX2"
			This.AssertEquals( "Debería haber permitido.", .T., .PermiteABM( "SoyTablaDeOrganizacion1" ) )
			.nContador = 1
			.cSucursalActiva = "BASEAUX1"
			This.AssertEquals( "Debería haber permitido.", .T., .PermiteABM( "SoyTablaDeOrganizacion1" ) )
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerCopiadBD
		
		local array laTablas[1], laTablasBD[1]
		local llEncontrado As Boolean, lcEmp as String, loBase as Object, lcDeleted as String, lcCursor as String, lcXml as String, lcDirectorio as String, lcTipoDB as String,;
			lcSucAnt as String, lcSucAnt1 as String, lnId as Integer, loEntidad as entidad OF entidad.prg, lcSuc as String 		

		lcDirectorio = Addbs( _Screen.zoo.cRutaInicial ) + "sucursal\"
		lcCursor = sys( 2015 )

		this.agregarmocks( "OrigenDeDatos,AdnImplant" )
		_screen.mocks.AgregarSeteoMetodo( 'ADNIMPLANT', 'Obtenerobjetoparametros', newobject( "AuxParametros" ) )
		_Screen.mocks.agregarmock( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic", "AuxFactory", "ztestAplicacionBase.prg" )


		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[Se ha generado la Base de Datos COPYABD.]" )

		lcSucAnt1 = _Screen.zoo.app.cSucursalActiva
		_Screen.zoo.app.cSucursalActiva = 'Paises'
		goServicios.Datos.EjecutarSentencias( "delete from Numeraciones", "Numeraciones", "" )		
		
		for i = 1 to 100
			goDatos.EjecutarSentencias( "insert into Numeraciones (talonario, Atributo, Numero ) values ( '" + transform( i ) + "'," + transform( i ) + "," + transform( i ) + " ) ", "Numeraciones", "" )
		endfor

		goServicios.Datos.EjecutarSentencias( "delete from Parametros.cabecera", "", "" )
		goServicios.Datos.EjecutarSentencias( "delete from Registros.cabecera", "", "" )
		goServicios.Datos.EjecutarSentencias( "delete from Parametros.Sucursal", "", "" )
		goServicios.Datos.EjecutarSentencias( "delete from Registros.Sucursal", "", "" )						
		
		goServicios.Datos.EjecutarSentencias( "insert into Parametros.cabecera ( nombre ) values ( 'prueba' )", "", "" )
		goServicios.Datos.EjecutarSentencias( "select id from Parametros.cabecera where nombre = 'prueba'", "", "", lcCursor, set("Datasession"))
		lnId = &lcCursor..Id
		goServicios.Datos.EjecutarSentencias( "insert into Parametros.Sucursal ( IdCabecera, valor ) values ( " + transform( lnId ) + ", 'prueba2' )", "", "" )
		
		use in select( lcCursor )		
		goServicios.Datos.EjecutarSentencias( "insert into Registros.cabecera ( nombre ) values ( 'prueba' )", "", "" )
		goServicios.Datos.EjecutarSentencias( "select * from Registros.cabecera where nombre = 'prueba'", "", "", lcCursor, set("Datasession"))
		lnId = &lcCursor..Id		
		goServicios.Datos.EjecutarSentencias( "insert into Registros.Sucursal ( IdCabecera, valor ) values ( " + transform( lnId ) + ", 'prueba2' )", "", "" )
		use in select( lcCursor )		

************ 1 caso
		lcSuc = goservicios.librerias.obtenernombresucursal( "COPYABD" )
		this.EliminarSucursalTest( "", lcSuc )
		
		loEntidad = _Screen.zoo.instanciarEntidad("basededatos")
				
		try
			loEntidad.Codigo = "COPYABD"
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.nuevo()
		loEntidad.codigo = "COPYABD"
		loEntidad.OrigenDestino_Pk = "ORI1"
		loEntidad.Color = 16744459
		loEntidad.grabar()
		
		loEntidad.release()
		
*		_screen.zoo.App.GenerarBaseDeDatos( 'CopyaBD', lcDirectorio ,'PAISES', 16744459  )

		goServicios.Datos.EjecutarSentencias( "select * from emp where empcod = 'COPYABD'", "Emp", Addbs( _Screen.zoo.cRutaInicial ), "Emp_C", set("Datasession"))
		llEncontrado = reccount( "emp_c" ) > 0

		This.asserttrue( "No se pudo crear la base de datos COPYABD en la tabla EMP. " , llEncontrado )

		lcSucAnt = _Screen.zoo.app.cSucursalActiva
		
		_Screen.zoo.app.cSucursalActiva = 'COPYABD'
		
		if llEncontrado
			This.assertEquals( "No se grabo correctamente el campo Empcod. " , "COPYABD", Alltrim( Upper( emp_c.EMPCOD ) ) )
			This.assertequals( "No se grabó correctamente el campo color_bd.", 16744459, emp_c.color_bd )
		endif
		use In Select( "Emp_c" )

		goDatos.EjecutarSentencias( "select * from Numeraciones", "Numeraciones", "", lcCursor, set("Datasession") )
		
		select ( lcCursor )

		for i = 1 to 100
			locate for alltrim( &lcCursor..Atributo ) = Transform( i )
			This.AssertTrue( "No se encuentra el atributo " + Transform( i ), found() )
			This.AssertTrue( "No Esta blanqueado el numero del atributo" + Transform( i ), found() and empty( &lcCursor..Numero ) )
		EndFor	
		use in select( lcCursor )

		goDatos.EjecutarSentencias( "select * from Parametros.Sucursal", "", "", lcCursor, set("Datasession") )

		select ( lcCursor )
		This.asserttrue( "La tabla Parametros.Sucursal esta vacia", reccount( lcCursor ) > 0 )
		use in select( lcCursor )
		
		goDatos.EjecutarSentencias( "select * from Registros.Sucursal", "", "", lcCursor, set("Datasession") )

		select ( lcCursor )
		This.asserttrue( "La tabla Registros.Sucursal esta vacia", reccount( lcCursor ) > 0 )
		use in select( lcCursor )

		_Screen.zoo.app.cSucursalActiva = lcSucAnt
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestEjecutarComandoMenu
		Local llError As boolean, loForm As Form, loApp as aplicacionBase of AplicacionBase.prg

		_screen.mocks.agregarmock( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "111111", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obs', "FRUTA" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "FRUTA", "3" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "Compumundo", "4" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "hipermegar", "5" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ed        ", "6" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "          ", "7" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "la organiz", "8" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ación mas ", "9" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "torpe del ", "10" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "mundo     ", "11" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Sre', .T., "-1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obtdesencent', 10 )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esd', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Traeralfrente', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Estainstalado', .T., "[" + getenv("COMPUTERNAME") + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[" + upper( alltrim( substr( sys( 0 ), at( "#" , sys( 0 ) ) + 2 ) ) ) + "$]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[*COMODIN]")
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Armarnombreperfilsegunentorno', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Cnombreperfil_access', .T. )
		
		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )

		_Screen.mocks.agregarmock( "mensajes" )
		_Screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "'*OBJETO'" )
		_Screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Advertir', .T., "'*OBJETO',0" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Alertar', .T., "'*OBJETO'" )

		_screen.mocks.agregarmock( "Modulos" )

		loApp = this.oApp
				
		with loApp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
		endwith
		loApp.Iniciar()

		llerror = .F.
		Try
			loApp.EjecutarComandoMenu( "iif( .t., .t., .f. )" )
		Catch
			llerror = .T.
		Endtry
		This.assertequals( "El comando es valido", .F., llError )

		llerror = .F.
		Try
			loApp.EjecutarComandoMenu( "_screen.zoo.crearobjeto( 'din_TEstInexistente' )" )
		Catch
			llerror = .T.
		Endtry
		This.assertequals( "El error debe ser controlado y no debe tirar la excepcion", .F., llError )

		llerror = .F.
		Try
			loApp.EjecutarComandoMenu( "TestErrorControladoYSale" )
		Catch
			llerror = .T.
		Endtry
		This.assertequals( "El error debe ser controlado y debe tirar la excepcion", .T., llError )

		llerror = .F.
		Try
			loApp.EjecutarComandoMenu( "TestErrorNoControlado" )
		Catch
			llerror = .T.
		Endtry
		This.assertequals( "El error on debe ser controlado y debe tirar la excepcion", .T., llError )

		loForm = newobject( "form" )
		llerror = .F.
		addproperty( loForm, "cIdentificadorParaOpcionesDeMenuYToolbar", "1234" )
		try
			loApp.EjecutarComandoMenu( "thisform.refresh()", loForm.cIdentificadorParaOpcionesDeMenuYToolbar )
		Catch
			llerror = .T.
		Endtry
		This.assertequals( "El metodo del formulario se debe ejecutar correctamente", .F., llError )

		loForm .Release()
		loApp.release()
		goServicios.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestValidacionEliminacionBasededatos
		Local llRetorno As Boolean , loApp as aplicacionbase of aplicacionbase.prg

		_screen.mocks.agregarmock( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "111111", "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obs', "FRUTA" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "FRUTA", "3" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "Compumundo", "4" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "hipermegar", "5" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ed        ", "6" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "          ", "7" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "la organiz", "8" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "ación mas ", "9" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "torpe del ", "10" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "mundo     ", "11" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Sre', .T., "-1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Obtdesencent', 10 )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esd', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Traeralfrente', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Estainstalado', .T., "[" + getenv("COMPUTERNAME") + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[" + upper( alltrim( substr( sys( 0 ), at( "#" , sys( 0 ) ) + 2 ) ) ) + "$]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Esmododemo', .T., "[*COMODIN]")
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Armarnombreperfilsegunentorno', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Cnombreperfil_access', .T. )
		
		_screen.mocks.agregarmock( "Modulos" )

		loApp = this.oApp
				
		with loApp
			.Nombre = "Nucleo"
			.cProyecto = "NUCLEO"
			.cListaDeEjecutables = ""
			.Iniciar()
		endwith

		goServicios.Datos.EjecutarSentencias( "insert into emp ( empcod ) values ( 'BASE1' )", "Emp", Addbs( _Screen.zoo.cRutaInicial ) )
		goServicios.Datos.EjecutarSentencias( "insert into emp ( empcod ) values ( 'BASE2' )", "Emp", Addbs( _Screen.zoo.cRutaInicial ) )		

		loApp.Cargarsucursales()
		loApp.cSucursalActiva = 'Base1'

		llRetorno = loApp.PuedoEliminarBasededatos( 'Base1' )
		This.asserttrue( "Fallo la validacion de eliminar una base de datos activa. " , !llRetorno )

		llRetorno = loApp.PuedoEliminarBasededatos( 'PPPP' )
		This.asserttrue( "Fallo la validacion de eliminar una base de datos inexistente. " , !llRetorno )

		loApp.cSucursalActiva = 'Base2'
		
		llRetorno = loApp.PuedoEliminarBasededatos( 'Base1' )
		This.asserttrue( "Fallo la validacion de eliminar una base de datos existente y no activa. " , llRetorno )

		loapp.oMensajes = null
		loapp.release()
		
		_screen.zoo.app.IniciarserviciosSindependencia()
		_screen.zoo.app.iniciarserviciosCondependencia()
		this.Inicializarserviciodatos()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestSetearAplicacion

		With This.oApp
			.cEstadoDelSistema	= "ESTADOTEST"

			.SetearAplicacion()

			this.assertequals( "La versión obtenida es incorrecta", "01.0001.00000", .ObtenerVersion() )
			This.assertequals( "El estado del sistema se seteo mal", "", .cEstadoDelSistema )
		Endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestIniciarMenu
		Local llnEstado

		lnEstado = goServicios.Seguridad.nEstadoDelSistema
		goServicios.Seguridad.nEstadoDelSistema = 1

		With This.oApp
			.cSucursalActiva = goParametros.Nucleo.OrigenDeDatosPreferente
			.ObtenerRutaSucursal( .cSucursalActiva )
			
			If Vartype( .oFormPrincipal ) = "O"
				.oFormPrincipal.Release()
			Endif

			.oFormPrincipal = _Screen.zoo.crearobjeto( "zooFormPrincipal" )
			With .oFormPrincipal
				.Newobject( 'oBarraEstado', 'BarraEstadoTest', 'zTestAplicacionBase.prg' )
				.AddProperty( "cXml", "" )
			Endwith

			.IniciarMenuPrincipal()

			This.assertequals( "No se agrego el CBM", "O", Vartype( .oFormPrincipal.cbm ) )
			This.assertequals( "No se agrego el Menu", "O", Vartype( .oFormPrincipal.omenu ) )
			This.asserttrue( "No se agregaron items al menu", .oFormPrincipal.oMenu.ControlCount > 0 )

			.IniciarMenuPrincipal()

			This.assertequals( "No se agrego el CBM por segunda vez", "O", Vartype( .oFormPrincipal.cbm ) )
			This.assertequals( "No se agrego el Menu por segunda vez", "O", Vartype( .oFormPrincipal.omenu ) )
			This.asserttrue( "No se volvieron a agregarar items al menu", .oFormPrincipal.oMenu.ControlCount  > 0 )
			
			.oFormPrincipal.omenu.Destroy()
			.oFormPrincipal.cbm.dispose()
			.oFormPrincipal.cbm.Destroy()
			.oFormPrincipal.Release()
		endwith
		This.assertequals( "La variable para la licencia no tiene el valor correcto.", "3ec687bb-4880-4c4c-885e-2e716cf97813", _3EC687BB )
		
		goServicios.Seguridad.nEstadoDelSistema = lnEstado
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestQuitarMenuVacio()

		local oMenuXML As Object, lcMenuXML As String, lnEstado As Integer, lnTotalObj As Integer, x As Integer, llVisible As Boolean

		llVisible = .F.
		lnEstado = goServicios.Seguridad.nEstadoDelSistema
		goServicios.Seguridad.nEstadoDelSistema = 1


		*----- Prueba que el menú este activado cuando hay items visibles
		oMenuXML = createobject( "MenuXML" )
		lcMenuXML = oMenuXML.cXMLMenuActivado

		With This.oApp
			.cSucursalActiva = goParametros.Nucleo.OrigenDeDatosPreferente
			.obtenerrutasucursal( .cSucursalActiva )

			If Vartype( .oFormPrincipal ) = "O"
				.oFormPrincipal.Release()
			Endif

			.oFormPrincipal = _Screen.zoo.crearobjeto( "zooFormPrincipal" )
			With .oFormPrincipal
				.Newobject( 'oBarraEstado', 'BarraEstadoTest', 'zTestAplicacionBase.prg' )
				.AddProperty( "cXml", lcMenuXML )
			Endwith

			.IniciarMenuPrincipal(.t.)
			
			lnTotalObj = .oFormPrincipal.cbm.mainmenu.me_13.me_26.ControlCount
			for x = 1 to lnTotalObj
				lcObjClass = .oFormPrincipal.cbm.mainmenu.me_13.me_26.Objects(x).Class
				if lcObjClass == "Commandbarmenuitem1"
					if .oFormPrincipal.cbm.mainmenu.me_13.me_26.Objects(x).Visible
						llVisible = .T.
						exit
					endif
				endif
			next x

			This.assertequals( "La opción ME_26 del submenú ME_13 debería estar habilitada ya que posee items visibles.", .oFormPrincipal.cbm.mainmenu.me_13.me_26.Visible, llVisible )

			.oFormPrincipal.omenu.Destroy()
			.oFormPrincipal.cbm.dispose()
			.oFormPrincipal.cbm.Destroy()
			.oFormPrincipal.Release()
		Endwith
		
		*----- Prueba que el menú este desactivado cuando no hay items visibles
		llVisible = .F.
		lcMenuXML = oMenuXML.cXMLMenuDesactivado

		With This.oApp
			.cSucursalActiva = goParametros.Nucleo.OrigenDeDatosPreferente
			.obtenerrutasucursal( .cSucursalActiva )

			If Vartype( .oFormPrincipal ) = "O"
				.oFormPrincipal.Release()
			Endif

			.oFormPrincipal = _Screen.zoo.crearobjeto( "zooFormPrincipal" )
			With .oFormPrincipal
				.Newobject( 'oBarraEstado', 'BarraEstadoTest', 'zTestAplicacionBase.prg' )
				.AddProperty( "cXml", lcMenuXML )
			Endwith

			.IniciarMenuPrincipal(.t.)
			
			lnTotalObj = .oFormPrincipal.cbm.mainmenu.me_13.me_26.ControlCount
			for x = 1 to lnTotalObj
				lcObjClass = .oFormPrincipal.cbm.mainmenu.me_13.me_26.Objects(x).Class
				if lcObjClass == "Commandbarmenuitem1"
					if .oFormPrincipal.cbm.mainmenu.me_13.me_26.Objects(x).Visible
						llVisible = .T.
						exit
					endif
				endif
			next x

			This.assertequals( "La opción ME_26 del submenú ME_13 debería estar desactivada ya que no posee items visibles.", .oFormPrincipal.cbm.mainmenu.me_13.me_26.Visible, llVisible )

			.oFormPrincipal.omenu.Destroy()
			.oFormPrincipal.cbm.dispose()
			.oFormPrincipal.cbm.Destroy()
			.oFormPrincipal.Release()
		Endwith

		goServicios.Seguridad.nEstadoDelSistema = lnEstado
		oMenuXML = Null
	endfunc
	*---------------------------------------------------------------------------------------------	
	Function zTestValidarExistenciaDLLs
		Local loAplicacion As Object, lcRutaSeguridad as String, llBorrar as Boolean, loArchivos as Object, ;
			lcRutaGdsDll as String

		loAplicacion = This.oAPP
		
		_screen.mocks.agregarmock( "verificadorDll" )
		_screen.mocks.AgregarSeteoMetodo( 'VERIFICADORDLL', 'Verificar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'VERIFICADORDLL', 'Inyectarinformacion', .T., "'*OBJETO'" )
		
		llRetorno = loAplicacion.VerificarExistenciaDLL()
		
		_screen.mocks.verificarejecuciondemocks( 'VERIFICADORDLL' )
		
		loAplicacion = Null

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarConsistenciaInternaTabla
		local llAplicacion as Boolean, lcTablaPrueba  as String, loManejoArchivos as Object
			
		loAplicacion = This.oAPP	
	
		lcTablaPrueba = _screen.zoo.cRutaInicial + "pruebat.dbf"			
		create table &lcTablaPrueba ( Campo c(1) )

		this.asserttrue( 'No se creo el archivo Temporal', file( lcTablaPrueba ) )
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")				
		llRetorno = loAplicacion.ValidarConsistenciaInternaTabla( lcTablaPrueba )
		this.asserttrue( "No se verifico la tabla", llRetorno )
		use in select ( "pruebat" )
		delete file ( lcTablaPrueba )

		strtofile( "Prueba verificar tabla", lcTablaPrueba )
		this.asserttrue( 'No se creo el archivo Temporal simulado', file( lcTablaPrueba ) )
		llRetorno = loAplicacion.ValidarConsistenciaInternaTabla( lcTablaPrueba )
		this.asserttrue( "Se verifico la tabla", llRetorno )
		delete file ( lcTablaPrueba )			
		
		loManejoArchivos.destroy()
		loManejoArchivos = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNativaObtenerRutaSucursal
		local lcSucursal as String, loAplicacion as Object, ;
			lcRetorno as String, lcRuta as String, lcSucursal as String, lnSessionLocal as Integer, i as Integer, loEmp as Object

		lcSucursal = 'Paises'
		loAplicacion = this.oApp

		lcRetorno = loAplicacion.ObtenerRutaSucursal( lcSucursal )

		i = ascan( loAplicacion.aSucursales, alltrim( upper( lcSucursal ) ), 1, 0, 1, 8 )
		
		lcRuta = this.oApp.aSucursales[i,3] + ':' + iif( left( alltrim( this.oApp.aSucursales[i,2] ), 1 ) = "\", "", "\" ) + addbs( alltrim( this.oApp.aSucursales[i,2] ) ) + addbs( alltrim( this.oApp.aSucursales[i,1] ) )
		this.assertequals( "No se obtuvo la ruta de la sucursal 1.", lcRuta, lcRetorno ) 

		lcSucursal = ''
		
		try
			lcRetorno = loAplicacion.ObtenerRutaSucursal( lcSucursal )
			this.Asserttrue( "Deberia pinchar porque no existe la sucursal", .f. )
		catch to loError
			this.assertequals( "Deberia pinchar porque no existe la sucursal (mensaje)", "NO SE ENCUENTRA LA SUCURSAL", alltrim( upper( loError.UserValue.oInformacion.item[1].cMensaje )) )
		endtry

		lcSucursal = 'Libertad'
		try
			lcRetorno = loAplicacion.ObtenerRutaSucursal( lcSucursal )
			this.Asserttrue( "Deberia pinchar porque no existe la sucursal 2", .f. )
		catch to loError
			this.assertequals( "Deberia pinchar porque no existe la sucursal (mensaje) 2", "NO SE ENCUENTRA LA SUCURSAL LIBERTAD", alltrim( upper( loError.UserValue.oInformacion.item[1].cMensaje )) )
		endtry

		goServicios.Datos.EjecutarSentencias( "select * from emp where empcod = 'PAISES'", "emp", addbs( _screen.zoo.cRutaInicial ), "c_emp", set("Datasession"))
		scatter name loEmp
		
		goServicios.Datos.EjecutarSentencias( "insert into emp ( empcod, epath, eunid, NC1, descrip, color_bd ) values ( 'GGG', '" + loEmp.epath + "', '" + loEmp.EUnid + ;
				"','" + loEmp.NC1 + "','" + loEmp.Descrip + "'," + transform( loEmp.Color_bd ) + " )", "emp", addbs( _screen.zoo.cRutaInicial ))
		goServicios.Datos.EjecutarSentencias( "insert into emp ( empcod, epath, eunid, NC1, descrip, color_bd ) values ( 'GGGT', '" + loEmp.epath + "', '" + loEmp.EUnid + ;
				"','" + loEmp.NC1 + "','" + loEmp.Descrip + "'," + transform( loEmp.Color_bd ) + " )", "emp", addbs( _screen.zoo.cRutaInicial ))				

		use in select( "c_emp" )
		
		loAplicacion.CargarSucursales()

		lcSucursal = 'GGG '
		lcRetorno = loAplicacion.ObtenerRutaSucursal( lcSucursal )
		this.assertequals( "No se obtuvo la ruta de la sucursal 2.", upper( addbs( _screen.zoo.cRutaInicial ) + 'ggg\') ,alltrim( upper( lcRetorno ) ) ) 

		lcSucursal = 'GGGT '
		lcRetorno = loAplicacion.ObtenerRutaSucursal( lcSucursal )
		this.assertequals( "No se obtuvo la ruta de la sucursal 3.", upper( addbs( _screen.zoo.cRutaInicial ) + 'gggt\') ,alltrim( upper( lcRetorno ) ) ) 

		lcSucursal = 'GG '
		try
			lcRetorno = loAplicacion.ObtenerRutaSucursal( lcSucursal )
			this.Asserttrue( "Deberia pinchar porque no existe la sucursal 3", .f. )
		catch to loError
			this.assertequals( "Deberia pinchar porque no existe la sucursal (mensaje) 3", "NO SE ENCUENTRA LA SUCURSAL GG", alltrim( upper( loError.UserValue.oInformacion.item[1].cMensaje )) )
		endtry

		loAplicacion = Null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal
		Local lnHandle As Integer
		
		_Screen.Zoo.cRutaInicial = _screen.zoo.obtenerrutatemporal()
		if !directory( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\" )
			md addbs( _Screen.Zoo.cRutaInicial ) + "Generados\"
		endif

		if !directory( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\" )
			md addbs( _Screen.Zoo.cRutaInicial ) + "Generados\"
		endif
			
		Delete File ( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\din_parametros.fxp" )
		Delete File ( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\din_Registros.fxp" )
		Delete File ( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\Din_MenuPrincipal.fxp" )
		
		llRetorno = This.oApp.ValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal()
		This.AssertTrue( "La validacion es erronea din_parametros 1", !llRetorno )
		This.AssertEquals( "La cantidad de errores no es correcta 1.", 3, this.oInfo.Count )
		This.AssertEquals( "El problema de la validacion es incorrecto din_parametros 1", "No se encuentra el archivo din_parametros.fxp", this.oInfo( 1 ).cMensaje )
		This.AssertEquals( "El problema de la validacion es incorrecto din_Registros 1", "No se encuentra el archivo din_registros.fxp", This.oInfo( 2 ).cMensaje )
		This.AssertEquals( "El problema de la validacion es incorrecto Din_MenuPrincipal 1", "No se encuentra el archivo din_menuprincipal.fxp", This.oInfo( 3 ).cMensaje )
		
		lnHandle = fcreate( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\Din_Parametros.fxp" )
		=fClose( lnHandle )
		This.oInfo.Limpiar()

		llRetorno = This.oApp.ValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal()
		This.AssertTrue( "La validacion es erronea 2", !llRetorno )
		This.AssertEquals( "La cantidad de errores no es correcta 2.", 2, this.oInfo.Count )
		This.AssertEquals( "El problema de la validacion es incorrecto din_Registros 2", "No se encuentra el archivo din_registros.fxp", This.oInfo( 1 ).cMensaje )
		This.AssertEquals( "El problema de la validacion es incorrecto Din_MenuPrincipal 2", "No se encuentra el archivo din_menuprincipal.fxp", This.oInfo( 2 ).cMensaje )
		
		lnHandle = fcreate( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\din_Registros.fxp" )
		=fClose( lnHandle )
		This.oInfo.Limpiar()
		
		llRetorno = This.oApp.ValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal()
		This.AssertTrue( "La validacion es erronea 3", !llRetorno )
		This.AssertEquals( "La cantidad de errores no es correcta 3.", 1, this.oInfo.Count )
		This.AssertEquals( "El problema de la validacion es incorrecto Din_MenuPrincipal 3", "No se encuentra el archivo din_menuprincipal.fxp", This.oInfo( 1 ).cMensaje )

		lnHandle = fcreate( addbs( _Screen.Zoo.cRutaInicial ) + "Generados\Din_MenuPrincipal.fxp" )
		=fClose( lnHandle )

		llRetorno = This.oApp.ValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal()
		This.AssertTrue( "La validacion es erronea 4", llRetorno )

	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestValidarExistenciaDeEjecutables
		local llRetorno as Boolean
		
		This.oApp.cListaDeEjecutables = ""
		llRetorno = This.oApp.VerificarExistenciaDeEjecutables()
		This.AssertTrue( "Se Validaron Ejecutables cuando no habia nada para validar. Sin Archivos", llRetorno )

		This.oApp.cListaDeEjecutables = "Archivo1.exe"
		llRetorno = This.oApp.VerificarExistenciaDeEjecutables()
		This.AssertTrue( "Se Validaron mal los Ejecutables. Archivo1.exe 1 ", !llRetorno )

		strtofile( "Archivo de Prueba", addbs( _screen.zoo.cRutaInicial ) + "Archivo1.exe" )
		llRetorno = This.oApp.VerificarExistenciaDeEjecutables()
		This.AssertTrue( "Se Validaron mal los Ejecutables. Archivo1.exe 2", llRetorno )

		This.oApp.cListaDeEjecutables = "Archivo1.exe,Archivo2.exe"
		llRetorno = This.oApp.VerificarExistenciaDeEjecutables()
		This.AssertTrue( "Se Validaron mal los Ejecutables. Archivo2.exe 1", !llRetorno )

		strtofile( "Archivo de Prueba 2", addbs( _screen.zoo.cRutaInicial ) + "Archivo2.exe" )
		llRetorno = This.oApp.VerificarExistenciaDeEjecutables()
		This.AssertTrue( "Se Validaron mal los Ejecutables. Archivo2.exe 2", llRetorno )
		
		delete file addbs( _screen.zoo.cRutaInicial ) + "Archivo1.exe"
		delete file addbs( _screen.zoo.cRutaInicial ) + "Archivo2.exe"

	Endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestVerificarExistenciaBase
		local llRetorno as Boolean, lcPath as String, lcCursor as String, lcValorEsperado as String;
               lcNombreSucursal as String 

		local array laArray(1)
				
		lcCursor = sys( 2015 )

		if goServicios.Datos.EsSqlServer()
            lcNombreSucursal = goServicios.Librerias.ObtenerNombreSucursal("PIRULITO")
			lcValorEsperado = alltrim( upper( "La base de datos: '" + lcNombreSucursal + "' no existe." ) )
		endif

		llRetorno = this.oApp.VerificarExistenciaBase( "PAISES" )
		this.asserttrue( "No validó correctamente PAISES", llRetorno )
		
		This.oApp.SetearInformacion( This.oInfo ) 

		try
			goServicios.Datos.EjecutarSentencias( "select epath from emp where empcod = 'PAISES'", "emp", "", lcCursor, set("Datasession") )
			lcPath = &lcCursor..epath
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
		
		goServicios.Datos.EjecutarSentencias( "insert into emp (empcod, eunid, epath) values ('Pirulito', 'Ñ', '\Path\De\Prueba')", "emp" )

		llRetorno = this.oApp.VerificarExistenciaBase( "Pirulito" )

		this.asserttrue( "No validó correctamente 2 ", !llRetorno )

		if goServicios.Datos.EsNativa()
			lcValorEsperado = alltrim( upper( "La base de datos: 'Ñ:\Path\De\Prueba\Pirulito\' no existe." ) )
		endif
		
		this.assertequals( "El problema generado no es el esperado 2", lcValorEsperado,;
				 alltrim( upper( This.oInfo( 1 ).cMensaje )) )
			
		goServicios.Datos.EjecutarSentencias( "update emp set eunid = '" + ;
			Alltrim( Upper( Left( _Screen.zoo.cRutaInicial, 1 ) ) ) + "' where empcod = 'Pirulito'", "emp" )

		This.oInfo.Limpiar()
		llRetorno = this.oApp.VerificarExistenciaBase( "Pirulito" )

		this.asserttrue( "No validó correctamente 3 ", !llRetorno )

		if goServicios.Datos.EsNativa()
			lcValorEsperado = alltrim( upper( "La base de datos: '" + Alltrim( Left( _Screen.zoo.cRutaInicial, 1 ) ) + ;
								":\Path\De\Prueba\Pirulito\' no existe." ) )
		endif

		this.assertequals( "El problema generado no es el esperado 3", lcValorEsperado, alltrim( upper( This.oInfo( 1 ).cMensaje )) )

		goServicios.Datos.EjecutarSentencias( "update emp set epath = '" + lcPath + "' where empcod = 'Pirulito'", "emp" )

		This.oInfo.Limpiar()
		llRetorno = this.oApp.VerificarExistenciaBase( "Pirulito" )
		this.asserttrue( "No validó correctamente 4", !llRetorno )

		if goServicios.Datos.EsNativa()
			lcValorEsperado = alltrim( upper( "La base de datos: '" + ;
								alltrim( left( _Screen.zoo.cRutaInicial, 1 ) ) + ":" + addbs( lcPath ) + ;
								"Pirulito\' no existe." ) )
		endif
		
		this.assertequals( "El problema generado no es el esperado 4", lcValorEsperado, alltrim( upper( This.oInfo( 1 ).cMensaje ) ) )

		goServicios.Datos.EjecutarSentencias( "delete from emp where empcod = 'Pirulito'", "emp" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarConfig
		local llRetorno as Boolean, lcArchivo as String, llYaTengoUnConfig_FPW as Boolean, lcContenidoConfig_FPW_Anterior as String, ;
			lcArchivoConfig_FPW as String
		
		lcArchivoConfig_FPW = addbs( _screen.Zoo.cRutaInicial )+ "Config.fpw" 
		llYaTengoUnConfig_FPW = file( lcArchivoConfig_FPW )
		lcContenidoConfig_FPW_Anterior = ''
		if llYaTengoUnConfig_FPW
			lcContenidoConfig_FPW_Anterior = filetostr( lcArchivoConfig_FPW )
		endif
		
		try
			delete file ( lcArchivoConfig_FPW )

			llRetorno = this.oAPP.VerificarExistenciaConfig()
			this.asserttrue( "No validó la inexistencia del archivo config.fpw", !llRetorno )

			this.oApp.CrearConfig()
			this.asserttrue( "No creó el archivo config.fpw", file( lcArchivoConfig_FPW ) )

			llRetorno = this.oAPP.VerificarExistenciaConfig()
			this.asserttrue( "No validó la existencia del archivo config.fpw", llRetorno )
		catch to loError
			throw loError
		finally
			if llYaTengoUnConfig_FPW
				delete file ( lcArchivoConfig_FPW )
				strtofile( lcContenidoConfig_FPW_Anterior, lcArchivoConfig_FPW )
			endif
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestLevantarDatosDeAplicacionIni
		local lcRuta as String , lcContenidoIni as String , lcNombreAplicacion as String, goLibreriasAnt as Object

		goLibreriasAnt = goLibrerias
		private goLibrerias
		
		goLibrerias = newObject( "mock_librerias" )
		goLibrerias.cretornoIni = "valor1"
		goServicios.Librerias = goLibrerias

		lcArchivo = "c:\APLICACION.INI"		
		lcNombreAplicacion = juststem( sys( 16,0 ) )

		this.oapp.LevantarDatosDeAplicacionIni( lcArchivo )
		this.assertequals( "La propiedad TipoDeBase se cargo mal", "valor1", this.oApp.cRutaDataConfig )

		this.oApp.cRutaDataConfig = ""
		goLibrerias.cretornoIni = ""
		this.oapp.LevantarDatosDeAplicacionIni( lcArchivo )
		this.assertequals( "La propiedad cRutaDataConfig se cargo mal1", _screen.zoo.cRutaInicial, this.oApp.cRutaDataConfig )

		goLibrerias.Release()
		goServicios.Librerias = goLibreriasAnt
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestLevantarDatosDeDataConfigIni
		local lcRuta as String , lcContenidoIni as String , lcNombreAplicacion as String, goLibreriasAnt as Object

		goLibreriasAnt = goLibrerias
		private goLibrerias
		
		goLibrerias = newObject( "mock_librerias" )
		goLibrerias.cretornoIni = "valor1"
		goServicios.Librerias = goLibrerias
		
		lcArchivo = "c:\DATACONFIG.INI"		
		lcNombreAplicacion = juststem( sys( 16,0 ) )

		this.oApp.cRutaDataConfig = "C:\"
		this.oapp.LevantarDatosDeDataConfigIni()
		this.assertequals( "1. La propiedad TipoDeBase se cargo mal", "VALOR1", this.oApp.TipoDeBase )
		this.assertequals( "1. La propiedad RutaTablasOrganizacion se cargo mal", "valor1", this.oApp.cRutaTablasOrganizacion )
		this.assertequals( "1. La propiedad RutaTablasPuesto se cargo mal", "valor1", this.oApp.cRutaTablasOrganizacion )

		this.oApp.cRutaDataConfig = ""
		goLibrerias.cretornoIni = ""
		this.oapp.LevantarDatosDeDataConfigIni()
		this.assertequals( "2. La propiedad TipoBase se cargo mal1", "NATIVA", this.oApp.TipoDeBase )
		this.assertequals( "2. La propiedad RutaTablasOrganizacion se cargo mal", upper( alltrim( _screen.zoo.cRutaInicial ) ), upper( alltrim( this.oApp.cRutaTablasOrganizacion ) ) )
		this.assertequals( "2. La propiedad RutaTablasPuesto se cargo mal", upper( alltrim( _screen.zoo.cRutaInicial ) ), upper( alltrim( this.oApp.cRutaTablasPuesto ) ) )

		goLibrerias.Release()
		goServicios.Librerias = goLibreriasAnt
	endfunc



	*-----------------------------------------------------------------------------------------
	function zTestObtenerNombre
		this.assertequals( 'El nombre de la aplicación es incorrecto', 'NUCLEO', upper( alltrim( this.oApp.ObtenerNombre() ) ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerNombreProyecto
		this.assertequals( 'El nombre del proyecto es incorrecto', 'NUCLEO', upper( alltrim( this.oApp.ObtenerNombreProyecto() ) ) )
	Endfunc
		
	*-----------------------------------------------------------------------------------------
	function zTestSePuedeIngresar
		
		local loApp as AplicacionBase of AplicacionBase.prg, lcSQL as String, lcRutaRegistroTMP as String, ;
				lcFile1 as String, lcFile2 as String
		
		loApp = newobject( "AplicacionBaseValida" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		
		loApp.Nombre = "Test"
		
		llRetorno = loApp.SePuedeIngresarAux()
		this.asserttrue( "Debe poder ingresar a la aplicacion", llRetorno )

		goServicios.Datos.EjecutarSentencias( "Delete From AccionesAplicaciones", "AccionesAplicaciones", _Screen.zoo.App.cRutaTablasOrganizacion )
		lcSQL = "insert into AccionesAplicaciones ( XX1, XX2 ) " + ;
			" values ( goLibrerias.Encriptar192( upper( alltrim( '" + loApp.Nombre +"' ) ) ), " + ;
				" goLibrerias.Encriptar192( 'INGRESODENEGADO' ) ) "

		goServicios.Datos.EjecutarSentencias( lcSQL, "AccionesAplicaciones", _Screen.zoo.App.cRutaTablasOrganizacion )
		loApp.SetearInformacion( this.oInfo )
		llRetorno = loApp.SePuedeIngresarAux()
		this.asserttrue( "NO se debe poder ingresar a la aplicacion (INGRESO DENEGADO)", !llRetorno )

		if This.oInfo.count > 0
			this.assertequals( "El motivo para no ingresar no es el correcto (INGRESO DENEGADO)", ;
				lower( "acceso denegado." ), ;
				lower( This.oInfo( 1 ).cMensaje ) )
		endif
		goServicios.Datos.EjecutarSentencias( "Delete From AccionesAplicaciones", "AccionesAplicaciones", _Screen.zoo.App.cRutaTablasOrganizacion )
		loApp.release()
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestZGenerarArchivoAplicacionIni
		local loApp as Object, lcRuta as String, lcBien as String, lcGenerado as String

		lcRuta = addbs( _screen.Zoo.obtenerRutaTemporal() ) + "aplicacion.ini"		
		
		loApp = newobject( "AplicacionBaseAux" )
		loApp.LevantarSeteosAplicacionIni( lcRuta, "NUCLEO" )
		
		text to lcBien textmerge noshow pretext 1+2
			[DATOS]
			RUTADATACONFIG=<<_screen.zoo.cRutaInicial>>
			[SETEOSAPLICACION]
			NOMBREAPLICACION=NUCLEO
			NOMBREPRODUCTO=NUCLEO
			NOMBRECOMERCIAL=NUCLEO
			COMPLEJIDADENCONSULTAS=2040
			PAQUETEADN=
			SERIE=
			UTILIZARWINEXEC=SI
			[ADNIMPLANT]
			RUTAZIPGENERADOS=
			VERSIONADNIMPLANT=.NET
			[SEGURIDAD]
			ULTIMOUSUARIOLOGUEADO=
			[POOLDEOBJETOS]
			HABILITADO=SI
			CLASESBASE=NO
			CLASESVISUALES=SI
			CLASESDENEGOCIO=NO
			SEGUNDOSFRECUENCIADEMONITOREO=1
			PORCENTAJEUSOCPU=8
			NUMEROMAXIMODEVERIFICACIONESDEINACTIVIDADDECPU=2
			SEGUNDOSDEULTIMAENTRADAUSUARIO=30
			MINIMORAMFISICALIBRE=256
			HABILITADOBETA=NO
			[POOLDEAPLICACIONES]
			PDA_HABILITADO=SI
			[EXPERIENCIADEUSUARIO]
			HABILITADA=NO
			COMPROBANTES=

		endtext
		lcGenerado = filetostr( lcruta )
		_cliptext =alltrim( upper( lcGenerado ))
		this.Assertequals( "No se genero correctamente aplicacion.ini", alltrim( upper( lcBien )), alltrim( upper( lcGenerado )))
		loapp.release()	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestGenerarArchivoSqlConfigIni
		local loApp as Object, lcRuta as String, lcBien as String, lcGenerado as String, lcDriverSQL as String

		loApp = newobject( "AplicacionBaseAux" )
		loApp.cRutaDataConfig = addbs( _screen.Zoo.obtenerRutaTemporal() ) 

		lcRuta = loApp.cRutaDataConfig  + "DataConfig.ini"
		loApp.LevantarSeteosDataConfigIni( lcRuta )

		if ( !empty( goServicios.Librerias.ObtenerValorRegistroWindows( "Version", "SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion\", "HKLM" ) ) )
			lcDriverSQL = "Sql Server Native Client 11.0"
		else
			lcDriverSQL = "Sql Server Native Client 10.0"
		endif

		text to lcBien textmerge noshow pretext 1+2
			[DATOS]
			TIPOBASE=SQLSERVER
			[SQL]
			SERVIDOR=
			Driver=<<lcDriverSQL>>
			TimeOut=16
			Reintentos=3
			SeguridadIntegrada=SI
			
		endtext

		lcGenerado = filetostr( lcRuta )

		this.Assertequals( "No se genero correctamente DataConfig.ini", alltrim( upper( lcBien )), alltrim( upper( lcGenerado )))
		loapp.release()	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestLoguearCopiaDeBaseDeDatos
		local loLogCopia as object
		
		loLogCopia = _screen.zoo.crearobjeto( "MostrarCopiaDB" )
		
		loLogCopia.Inicializar( "Base1", "Ubicacion1", 10 )
		
		This.assertequals( "No se copio el nombre de la base de datos en el control correcto.", ;
							upper( alltrim( loLogCopia.oForm.txtNombre.value ) ) , "BASE1" )
		This.assertequals( "No se copio el nombre de la ubicacion en el control correcto.", ;
							upper( alltrim( loLogCopia.oForm.txtUbicacion.value ) ) , "UBICACION1" )
		This.assertequals( "No se copio la cantida de archivos en el control correcto.", loLogCopia.oForm.oKontroler.Cantidad , 10 )

		loLogCopia.Actualizar( "Archivo1", "Copiado ok." )
		loLogCopia.Actualizar( "Archivo2", "Copiado ok." )
		loLogCopia.Actualizar( "Archivo3", "Copiado ok." )
		loLogCopia.Actualizar( "Archivo4", "Copiado ok." )						

		This.assertequals( "No se actualizo el porcentaje correctamente.",  loLogCopia.oForm.txtProgreso.Value , 40 )
		loLogCopia.Finalizar()
							
		This.asserttrue( "No se cerro la pantalla de log de copia de base de datos." + vartype( loLogCopia.oForm ) ;
				, vartype( loLogCopia.oForm ) = 'X' )
				
		release loLogCopia
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSetearEstadoMenuPrincipal
		this.oApp.oFormPrincipal = _screen.zoo.crearObjeto ("zooFormPrincipal")

		this.oApp.cSucursalActiva = "PAISES"
		this.oApp.obtenerrutasucursal( this.oApp.cSucursalActiva )

		this.oApp.IniciarMenuPrincipal()
		
		
		this.assertTrue( "El estado del menu no es el correcto 1", this.oApp.oFormPrincipal.oMenu.ME_1.Enabled )  
		this.assertTrue( "El estado del menu 2 no es el correcto 1", this.oApp.oFormPrincipal.oMenu.ME_2.Enabled )  
	
		this.oApp.SetearEstadoMenuPrincipal( .f. )
		this.assertTrue( "El estado del menu no es el correcto 2", !this.oApp.oFormPrincipal.oMenu.ME_1.Enabled )  
		this.assertTrue( "El estado del menu 2 no es el correcto 2", !this.oApp.oFormPrincipal.oMenu.ME_2.Enabled )  
		
		this.oApp.SetearEstadoMenuPrincipal( .t. )
		this.assertTrue( "El estado del menu no es el correcto 3", this.oApp.oFormPrincipal.oMenu.ME_1.Enabled )  
		this.assertTrue( "El estado del menu 2 no es el correcto 3", this.oApp.oFormPrincipal.oMenu.ME_2.Enabled )  		
		
		this.oApp.oFormPrincipal.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarVersionDemo
		local loApp as Object, lcSerie as String
		
		private goFormularios
	
		_Screen.Mocks.AgregarMock( "ManagerFormularios" )
		goFormularios = _screen.zoo.crearobjeto( "ManagerFormularios" )
	
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Mostrarscx', .T., "'MensajeDemo',.T." ) && ZTESTAPLICACIONBASE.ZTESTVALIDARVERSIONDEMO 20/05/08 12:50:09
		
		lcSerie = _screen.zoo.app.cSerie
		_screen.zoo.app.cSerie = "DEMO"
		
		loApp = newobject( "AplicacionBaseValida" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		loApp.cProyecto = "NUCLEO"
		
		goServicios.Datos.EjecutarSentencias( "delete from rio", "rio", addbs( _screen.zoo.cRutaInicial ) + "paises\dbf\" )
		
		this.asserttrue( "La versión demo no se validó correctamente 1", loApp.ValidarVersionDemoAux() )

		** El límite es 20 para esta entidad
		for i = 1 to 21
			goServicios.Datos.EjecutarSentencias( "insert into rio ( codigo ) values ( '" + transform( i ) + "' )", "rio", addbs( _screen.zoo.cRutaInicial ) + "paises\dbf\" )
		endfor

		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Mostrarscx', .f., "'MensajeDemo',.T." ) && ZTESTAPLICACIONBASE.ZTESTVALIDARVERSIONDEMO 20/05/08 12:50:09
	
		&& debio entrar el Buffer
		this.asserttrue( "La versión demo no se validó correctamente 2", loApp.ValidarVersionDemoAux() )
		loApp.tUltimoControl = loApp.tUltimoControl - 7201
		this.asserttrue( "La versión demo no se validó correctamente 3", !loApp.ValidarVersionDemoAux() )

		&& Cuando valida falso no entra al bufer
		this.asserttrue( "La versión demo no se validó correctamente 4", !loApp.ValidarVersionDemoAux() )
		
		** cambia la clase que se instancia
		loApp.tUltimoControl = 0
		
		loApp.cProyecto = "INEXISTENTE"
		this.asserttrue( "La versión demo no se validó correctamente 3", loApp.ValidarVersionDemoAux() )
			
		_screen.zoo.app.cSerie = lcSerie
		loApp.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestSetearAyuda
		goMensajes = Newobject( "mensajes_mock" )
		
		This.oApp.SetearAyuda()
		this.asserttrue("La ayuda no deberia estar seteada", empty( this.oApp.cArchivoDeAyuda ) )

		This.oApp.EjecutarAyuda()
		this.asserttrue( "Deberia haber informado 'Ayuda no disponible'." , goMensajes.lMensajeEnviado )			
		
		goMensajes.lMensajeEnviado = .f.
		this.oApp.cArchivoDeAyuda = "abc"
		This.oApp.EjecutarAyuda()
		this.asserttrue( "No deberia haber informado 'Ayuda no disponible'." , !goMensajes.lMensajeEnviado )			

		goMensajes = _screen.zoo.app.oMensajes
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestIniciarEstilos
		local lnEventos as Integer, i as Integer, llEncontro as Boolean, loApp as Object
		local array laBindeos(1)

		loApp = _Screen.Zoo.CrearObjeto( "AplicacionNucleo" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		loApp.IniciarServiciosConDependencia()
		
		lnEventos = aevents( laBindeos, loApp.oEstilos )
		this.assertequals( "La cantidad de bindeos no es la correcta", 1, lnEventos )
		
		llEncontro = .F.

		for i = 1 to lnEventos
			if upper( alltrim( laBindeos[ lnEventos, 4 ] ) ) == "ACTUALIZARESTILO"
				llEncontro = .T.
			endif
		endfor
		
		this.asserttrue( "El objeto estilos no esta bindeado al parametro", llEncontro )
		
		loApp.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestObtenerPrefijoDB
		local loapp as aplicacionbase of aplicacionbase.prg

		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		
		This.assertnotnull( "No se Instacio la Aplicacion", loApp )

		with loApp
			.NombreProducto = "PREFIJOTEST"
			.lUtilizaPrefijoDB = .t.
			This.Assertequals( "Error: Debería devolver el prefijo", "PREFIJOTEST_", loApp.ObtenerPrefijoDB() )

			.lUtilizaPrefijoDB = .f.
			This.Assertequals( "Error: NO Debería devolver ningun prefijo", "", loApp.ObtenerPrefijoDB() )
			
			.release()
		endwith
	Endfunc	
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeEjecutarZooUpdateSegunParametro
		local loApp as Object, loMensaje as Object, loLibreria as Object
		goParametros.Nucleo.Actualizaciones.BuscarActualizacionesAlIniciar = .T.
		
		_screen.zoo.esbuildautomatico = .F.
		
		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )

		try
			loMensaje = goMensajes
			loLibreria = goLibrerias
			loApp = this.oApp
			
			with loApp 
				.lMockearLibreria = .t.
				.Nombre = "Nucleo"
				.cProyecto = "NUCLEO"
				.cListaDeEjecutables = ""
				.Iniciar()
				
				This.assertequals( "No paso por el metodo", .t., goServicios.Librerias.lPasoPorBuscarActualizaciones )
			endwith
			
		catch to loError
			throw loError
		finally
			loApp.Release()
			goMensajes = loMensaje
			goLibrerias = loLibreria
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_NoDebeEjecutarZooUpdateSegunParametro
		local loApp as Object, loServicio as Object, loLibreria as Object

		_screen.zoo.esbuildautomatico = .F.
			
		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )

		goParametros.Nucleo.Actualizaciones.BuscarActualizacionesAlIniciar = .F.
		try
			loServicio = goServicios
			loMensaje = goMensajes
			loLibreria = goLibrerias			

			loApp = this.oApp
			
			with loApp 
				.lMockearLibreria = .t.
				.Nombre = "Nucleo"
				.cProyecto = "NUCLEO"
				.cListaDeEjecutables = ""

				.Iniciar()
				
				This.assertequals( "No debio pasar por el metodo", .F., goServicios.Librerias.lPasoPorBuscarActualizaciones )
			endwith
			
		catch to loError
			throw loError
		finally
			loApp.Release()
			goMensajes = loMensaje
			goLibrerias = loLibreria
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_NoDebeEjecutarZooUpdateSegunScript
		local loApp as Object, loServicio as Object, loLibreria as Object

		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )

		goParametros.Nucleo.Actualizaciones.BuscarActualizacionesAlIniciar = .T.
		goServicios.Ejecucion.lScriptCargado = .T.
		
		try
			loServicio = goServicios
			loMensaje = goMensajes
			loLibreria = goLibrerias			
			loApp = this.oApp
			
			with loApp 
				.lMockearLibreria = .t.
				.Nombre = "Nucleo"
				.cProyecto = "NUCLEO"
				.cListaDeEjecutables = ""

				.Iniciar()
				
				This.assertequals( "No debio pasar por el metodo", .F., goServicios.Librerias.lPasoPorBuscarActualizaciones )
			endwith
			
		catch to loError
			throw loError
		finally
			loApp.Release()
			goMensajes = loMensaje
			goLibrerias = loLibreria
		endtry
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestU_CambiarNumeroDeSeriePeroCancelaDesdeMensajeDevuelveFalse
		local loAplicacionBase as aplicacionbase of aplicacionbase.prg, llRetorno as Boolean
		loAplicacionBase = createobject( "AplicacionMock_CambioSerie" )
		
		private goMensajes
		_screen.mocks.agregarmock( "Mensajes" )
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Informar', 2, "[El número de serie identifica su licencia para utilizar este producto, presione Aceptar si desea cambiarlo." + chr(13) + chr(10) + chr(13) + chr(10) +;
				"Importante: necesitará comunicarse con Atención al Cliente para realizar esta operacón." + chr(13) + chr(10) + ;
				"Por consultas de teléfonos de contacto y horarios de atención ingrese a nuestro sitio web en www.zoologic.com.ar],1,1" )
		
		private goFormularios
		_screen.mocks.agregarmock( "ManagerFormularios" )
		goFormularios = _screen.zoo.crearobjeto( "ManagerFormularios" )


		private goServicios
		_screen.mocks.agregarmock( "Librerias" )
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )

		*-- Mockear Libreruas
		llRetorno = loAplicacionBase.Cambiars( 2 )
		
		This.AssertTrue( "No debio cambiar el nro de serie.", !llRetorno )
		
		goServicios.Release()
		goMensajes = _screen.zoo.app.oMensajes
		loAplicacionBase.release()
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestU_CambiarNumeroDeSeriePeroCancelaDesdePedidoDeCodigoDevuelveFalse
		local loAplicacionBase as aplicacionbase of aplicacionbase.prg, llRetorno as Boolean
		loAplicacionBase = createobject( "AplicacionMock_CambioSerie" )
		
		private goMensajes
		_screen.mocks.agregarmock( "Mensajes" )
		

		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Informar', 1, "[El número de serie identifica su licencia para utilizar este producto, presione Aceptar si desea cambiarlo." + chr(13) + chr(10) + chr(13) + chr(10) +;
				"Importante: necesitará comunicarse con Atención al Cliente para realizar esta operacón." + chr(13) + chr(10) + ;
				"Por consultas de teléfonos de contacto y horarios de atención ingrese a nuestro sitio web en www.zoologic.com.ar],1,1" )
		
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )
		private goFormularios
		_screen.mocks.agregarmock( "ManagerFormularios" )
		goFormularios = _screen.zoo.crearobjeto( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Pdbrmse', 1, "[L]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .T., "1,[]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .T., "3,[]" )


		private goServicios
		_screen.mocks.agregarmock( "Librerias" )
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'Verificar', .F. )
		

		*-- Mockear Libreruas
		llRetorno = loAplicacionBase.Cambiars( 2 )
		
		This.AssertTrue( "No debio cambiar el nro de serie.", !llRetorno )
		
		goServicios.Release()
		goMensajes = _screen.zoo.app.oMensajes
		loAplicacionBase.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CambiaExitosamenteElNumeroDeSerieDevuelveTrue
		local loAplicacionBase as aplicacionbase of aplicacionbase.prg, llRetorno as Boolean
		loAplicacionBase = createobject( "AplicacionMock_CambioSerie" )
		
		private goMensajes
		_screen.mocks.agregarmock( "Mensajes" )
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )
				
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Informar', 1, "[El número de serie identifica su licencia para utilizar este producto, presione Aceptar si desea cambiarlo." + chr(13) + chr(10) + chr(13) + chr(10) + ;
				"Importante: necesitará comunicarse con Atención al Cliente para realizar esta operacón." + chr(13) + chr(10) + ;
				"Por consultas de teléfonos de contacto y horarios de atención ingrese a nuestro sitio web en www.zoologic.com.ar],1,1" )
		
		private goFormularios
		_screen.mocks.agregarmock( "ManagerFormularios" )
		goFormularios = _screen.zoo.crearobjeto( "ManagerFormularios" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Pdbrmse', 1, "[L]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .T., "1,[]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .T., "3,[]" )

		private goServicios
		_screen.mocks.agregarmock( "Librerias" )
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'Verificar', .T. )
		

		*-- Mockear Libreruas
		llRetorno = loAplicacionBase.Cambiars( 2 )
		
		This.AssertTrue( "Debio cambiar el numero de serie.", llRetorno )
		
		goServicios.Release()
		goMensajes = _screen.zoo.app.oMensajes
		loAplicacionBase.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerMesAnioDeCompilacionDeLaVersionActual
		this.assertequals( "Esta funcion deberia retornar lo que se especifique en Buil.h", "Mayo 1810", _Screen.zoo.app.ObtenerMesAnioDeCompilacionDeLaVersionActual() )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_VerificarEjecucionFixParametros()
		local lcTelefono as String
		lcTelefono = goParametros.Nucleo.DatosGenerales.TelefonoDeLaEmpresa
		
		goParametros.Nucleo.DatosGenerales.TelefonoDeLaEmpresa = ""
		This.oApp.ProcesoDeDatosFixParametros()
		This.Assertequals( "No se ejecuto el proceso de fix de parametros.", "TEST" ,goParametros.Nucleo.DatosGenerales.TelefonoDeLaEmpresa )
		goParametros.Nucleo.DatosGenerales.TelefonoDeLaEmpresa = lcTelefono

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ReiniciarServicioDeMemoria
		local lcServicioMemoriaClase as String

		lcServicioMemoriaClase = goServicios.Memoria.Class

		loObjBindeo = newobject( "objaux" )
		bindevent( goServicios.Memoria, "Detener" , loObjBindeo, "Detener", 1 )

		_screen.zoo.apP.ReiniciarServicios()

		This.asserttrue( "No ejecuto el metodo detener al reiniciar los servicios de memoria.", loObjBindeo.lEjecutoDetener )
		goServicios.Memoria.Detener()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_oMonitorDeIngresoYSalida_Access
		local loMonitor as Object
		
		*Arrange (Preparar)
		_screen.mocks.agregarmock( "ZooLogicSA.Core.MonitorDeIngresoYSalida" , "mock_monitorDeIngresoYSalida", "zTestAplicacionBase.prg" )

		*Act (Actuar)
		_screen.zoo.apP.oMonitorDeIngresoYSalida = null
		loMonitor = _screen.zoo.apP.oMonitorDeIngresoYSalida

		*Assert (Afirmar)
		This.Assertequals( "No se instancio la clase correcta", "Mock_monitordeingresoysalida", loMonitor.Class )
		This.Assertequals( "No se seteo la ruta de trabajo.",_Screen.Zoo.crutainicial, loMonitor.RutaArchivo )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_SetearParametrosModoAvanzadoyEstilo	 
		local lnEstilo as Integer, llModo as Boolean, loAplicacionBase as Object
	
		llModo = goServicios.Parametros.Dibujante.ModoAvanzado
		lnEstilo = goServicios.Parametros.Dibujante.Estilo

		goServicios.Parametros.Dibujante.ModoAvanzado =	.f.
		goServicios.Parametros.Dibujante.Estilo = 1

		loAplicacionBase = newobject( "aplicacionbase_prueba" )
		loAplicacionBase.SetearParametrosModoAvanzadoyEstilo_Prueba()
		
		this.asserttrue( "El parámetro de Modo Avanzado no se seteó correctamente.", goServicios.Parametros.Dibujante.ModoAvanzado ) 
		this.assertequals( "El parámetro de Estilo no se seteó correctamente.", 2, goServicios.Parametros.Dibujante.Estilo ) 
	
		goServicios.Parametros.Dibujante.ModoAvanzado =	llModo
		goServicios.Parametros.Dibujante.Estilo = lnEstilo
		loAplicacionBase.release()
	endfunc 



enddefine



*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------

define class mock_monitorDeIngresoYSalida as custom

	RutaArchivo = ""

enddefine


define class AplicacionMock_CambioSerie as aplicacionbase of aplicacionbase.prg

	*-----------------------------------------------------------------------------------------
	protected function VerificarPantallasAbiertas( tnCantidadPantallas as Integer ) as boolean
		return .F.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReportarRegistroTerminal() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DesRegistrarRegistroTerminal() as Void
	endfunc 

enddefine



*-----------------------------------------------------------------------------------------
define class TestObjetoBindeo as Custom
	oServicios = null
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.oServicios = newobject( "Collection" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BajarServicio( tcObjetoApp as String, tcObjetoGlobal as string ) as Void
		this.AgregarServicio( "g" + alltrim( tcObjetoApp ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServicio( tcClase as String, tcObjetoApp as String, tcObjetoGlobal as string, txPar1 as variant ) as Void
		this.AgregarServicio( alltrim( tcObjetoGlobal ), .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutaDOS ( tcComando As String, tlMostrar As Boolean , tlNoEsperar ) As Boolean
		nodefault 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarServicio( tcServicio as String, tlEsAlta as Boolean ) as Void		
		local loItem as Custom
		if this.oServicios.getkey( alltrim( upper( tcServicio ))) > 0 and tlEsAlta
			this.oServicios.Item[ alltrim( upper( tcServicio )) ].lEstaEnBaja = .f.
		else
			loItem = newobject( 'Custom' )
			loItem.AddProperty( "cNombre", tcServicio )
			loItem.AddProperty( "lEstaEnBaja", .t. )
			this.oServicios.add( loItem, alltrim( upper( tcServicio )))
		endif
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------

define class mensajes_mock as mensajes of mensajes.prg
	lMensajeEnviado = .f.

	function informar( toobject as Variant ) as Void
		This.lMensajeEnviado = .t.
	endfunc 


enddefine
*-----------------------------------------------------------------------------------------

define class AplicacionMock_Seguridad2 as aplicacionbase of aplicacionbase.prg
PidioCodigoDesactivacion = .f.
lDevolver_pedirCodigoDesactivacion = .f.
lPasoPorChequearUnidadRutaySucursal = .f.

	*-----------------------------------------------------------------------------------------
	function PedirCodigoDesactivacion( tcletra as String ) as boolean
		This.PidioCodigoDesactivacion = .t.
		return This.lDevolver_pedirCodigoDesactivacion
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ChequearUnidadRutaySucursal( tcUnidad as string, tcPath as string, tcSucursal as string ) as Boolean
		This.lPasoPorChequearUnidadRutaySucursal = .t.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class AplicacionMock_Seguridad as aplicacionbase of aplicacionbase.prg

	lPasoPorMetodo_VerificarAccesoSeguridadComercial = .f.
	lDevolverVerdadero_VerificarExistenciaTablasSeguridad = .f.
	lPasoPor_VerificarExistenciaTablasSeguridad = .f.
	lcDevolver_VerificarAccesoSeguridadComercial = ""
	lDevolverSegundoParametro_VerificarExistenciaTablasSeguridad = .t.
	RutaParametro_mock = ""
	
	
	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaTablasSeguridad( tcRuta as String ) as Boolean
		local llRetorno as Boolean

		This.lPasoPor_VerificarExistenciaTablasSeguridad = .t.
		This.RutaParametro_mock = tcRuta

		if This.lDevolverSegundoParametro_VerificarExistenciaTablasSeguridad
			llRetorno = This.lDevolverSegundoParametro_VerificarExistenciaTablasSeguridad
		else
			llRetorno = This.lDevolverVerdadero_VerificarExistenciaTablasSeguridad
		endif
			
		return llRetorno
	endfunc 

		*-----------------------------------------------------------------------------------------
	function VerificarAccesoSeguridadComercial( tcLetra as String ) as Void
		This.lPasoPorMetodo_VerificarAccesoSeguridadComercial= .t.
		
		return This.lcDevolver_VerificarAccesoSeguridadComercial
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
Function ValidarPropiedades( toClasFxu , tcPropiedad )

	toClasFxu.asserttrue( "No se encuentra la propiedad " + tcPropiedad , Pemstatus( toClasFxu.oApp, tcPropiedad, 4 ))

Endfunc

*-----------------------------------------------------------------------------------------
Function ValidarObjetosCreados( toClasFxu , tcObjeto )

	toClasFxu.asserttrue( "No se instancio el objeto" + tcObjeto, Vartype( toClasFxu.oApp.&tcObjeto)="O")

Endfunc

*-----------------------------------------------------------------------------------------
Function HacerRenameTablas( tcRutaParametrosOrganizacion As String, tcSucursalActiva As String ) As Void
	Local lcRutaSuc As String

	lcRutaSuc = Addbs( tcRutaParametrosOrganizacion  ) + "Sucursal\" + tcSucursalActiva + "\dbf\"

	Rename ( lcRutaSuc + "Sys_s.dbf" ) To ( lcRutaSuc + "Sys_s.db_" )
	Rename ( lcRutaSuc + "ParametrosSucursal.dbf" ) To ( lcRutaSuc + "ParametrosSucursal.db_" )
	Rename ( tcRutaParametrosOrganizacion  + "ParametrosOrg.dbf" ) To ( tcRutaParametrosOrganizacion  + "ParametrosOrg.db_" )
	Rename ( tcRutaParametrosOrganizacion  + "ParametrosPuesto.dbf" ) To ( tcRutaParametrosOrganizacion  + "ParametrosPuesto.db_" )
	Rename ( tcRutaParametrosOrganizacion  + "Sys_o.dbf" ) To ( tcRutaParametrosOrganizacion  + "Sys_o.db_" )
	Rename ( tcRutaParametrosOrganizacion  + "Sys_p.dbf" ) To ( tcRutaParametrosOrganizacion  + "Sys_p.db_" )
Endfunc

*-----------------------------------------------------------------------------------------
Function RestaurarRenameTablas( tcRutaParametrosOrganizacion As String, tcSucursalActiva As String ) As Void
	Local lcRutaSuc As String

	lcRutaSuc = Addbs( tcRutaParametrosOrganizacion ) + "Sucursal\" + tcSucursalActiva + "\dbf\"

	If File( lcRutaSuc + "Sys_s.db_" )
		Rename ( lcRutaSuc + "Sys_s.db_" ) To ( lcRutaSuc + "Sys_s.dbf" )
	Endif
	If File( lcRutaSuc + "ParametrosSucursal.db_" )
		Rename ( lcRutaSuc + "ParametrosSucursal.db_" ) To ( lcRutaSuc + "ParametrosSucursal.dbf" )
	Endif
	If File( tcRutaParametrosOrganizacion  + "ParametrosOrg.db_" )
		Rename ( tcRutaParametrosOrganizacion  + "ParametrosOrg.db_" ) To ( tcRutaParametrosOrganizacion  + "ParametrosOrg.dbf" )
	Endif
	If File( tcRutaParametrosOrganizacion  + "ParametrosPuesto.db_" )
		Rename ( tcRutaParametrosOrganizacion  + "ParametrosPuesto.db_" ) To ( tcRutaParametrosOrganizacion  + "ParametrosPuesto.dbf" )
	Endif
	If File( tcRutaParametrosOrganizacion  + "Sys_o.db_" )
		Rename ( tcRutaParametrosOrganizacion  + "Sys_o.db_" ) To ( tcRutaParametrosOrganizacion  + "Sys_o.dbf" )
	Endif
	If File( tcRutaParametrosOrganizacion  + "Sys_p.db_" )
		Rename ( tcRutaParametrosOrganizacion  + "Sys_p.db_" ) To ( tcRutaParametrosOrganizacion  + "Sys_p.dbf" )
	Endif

Endfunc


*-----------------------------------------------------------------------------------------
Define Class AplicacionBaseValida As AplicacionNucleo Of AplicacionNucleo.prg

	lCorrerReindexadorOk = .f.
	lCorrerBackupOk = .f.
	lAgregarProblema = .f.
	lEjecutoDesdeMain = .F.
		
	*-----------------------------------------------------------------------------------------
	function ValidarEstructuraAccionesAplicacionesAux( tcRutaTablas ) as Boolean
		return this.ValidarEstructuraAccionesAplicaciones( tcRutaTablas )
	endfunc 
	
	*-----------------------------------------------------------------------------------------	

	function ValidarTablasAuditoriaAux() as Boolean
		return this.ValidarTablasAuditoria()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearTablaAuditoriaAux( tcRutaTablas, tcTabla ) as Void
		this.CrearTablaAuditoria( tcRutaTablas, tcTabla )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarReindexador( tcRuta as String ) as Boolean
		local llRetorno as Boolean
	
		llRetorno = .f.
		
		llRetorno = this.lCorrerReindexadorOk

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarBackup() as boolean

		if this.lCorrerBackupOk
			This.AgregarInformacion( "Problema de backup de test." )
		endif	

		return this.lCorrerBackupOk
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SePuedeIngresarAux() as boolean
		return this.SePuedeIngresar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaTablasSeguridad() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SeteoEsquemaSeguridad() as Void
		return .t.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ejecutoDesdeMain() as Void
		return this.lEjecutoDesdeMain 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarVersionDemoAux() as Boolean
		return this.ValidarVersionDemo()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServiciosSinDependencia() as Void
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarDiferenciasDeEstructurav2( tnProcesos as Integer, tcSucursales as String ) as boolean
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarDiferenciasDeEstructura( tnProcesos as Integer, tcSucursales as String ) as Boolean
		return .t.
	endfunc
		
Enddefine

*-----------------------------------------------------------------------------------------
Define Class BarraEstadoTest As Custom

	*-----------------------------------------------------------------------------------------
	Function SetearColor( tp1 As Variant )

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SetearEstadoDelSistema( tp1 As Variant, tnPanel1 As Integer, tnPanel2 As Integer )

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function setear( tp1 As Variant )

	Endfunc

Enddefine

*-----------------------------------------------------------------------------------------
Function Salir() As Void
endfunc
*-----------------------------------------------------------------------------------------
function estaBloqueado() as Boolean
	local lnReproces as Integer, llReturn as Boolean
	lnReproces = set("Reprocess")
	
	set reprocess to 1 seconds
	
	if isrlocked()
		llReturn = .T.
	else
		if rlock()
			llReturn = .F.
			unlock record recno()
		else
			llReturn = .T.
		endif 
	endif
		
	set reprocess to lnReproces 
	return llReturn
endfunc 

*-----------------------------------------------------------------------------------------
define class goFormulariosAux as managerFormularios of ManagerFormularios.prg
	cFormulario = ""
	lRetorno = .f.
	lParametro = .f.
	lParametro2 = .f.
	*-----------------------------------------------------------------------------------------
	Function MostrarScx( tcFormulario As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant  ) As Variant
		with this
			.cFormulario = tcFormulario 
			.lRetorno = tlRetorno
			.lParametro = txParametro
			.lParametro2 = txParametro2
		endwith
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class goFormulariosAuxMock as managerFormularios of ManagerFormularios.prg

	oColeccionFormularios = null
	
	*-----------------------------------------------------------------------------------------
	Function Mostrar( tcFormulario As String ) As Variant
		if vartype( this.oColeccionFormularios ) <> 'O' or ! pemstatus( this.oColeccionFormularios, 'Count' ,5 ) or  this.oColeccionFormularios.Count= 0 
			this.oColeccionFormularios = _screen.zoo.crearobjeto( "ZooColeccion" )
		endif 
		this.oColeccionFormularios.Agregar( tcFormulario )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class goMensajesAux as Mensajes of Mensajes.prg
	cFormulario = ""
	cMensaje = ""
	lRetorno = .f.
	lParametro = .f.
	lParametro2 = .f.
	lParametro3 = 0
	nRetornarPostergar = .f.
	*-----------------------------------------------------------------------------------------
	Function Alertar( tcMensaje As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant ) As Variant
		with this
			.cFormulario = "Alertar"
			.cMensaje = tcMensaje 
			.lRetorno = tlRetorno
			.lParametro = txParametro
			.lParametro2 = txParametro2
			.lParametro3 = txParametro3
			return dodefault( tcMensaje , tlRetorno , txParametro , txParametro2 , txParametro3 )

		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Advertir( tcMensaje As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant ) As Variant

		if This.nRetornarPostergar
			with this
				.cFormulario = "Advertir" 
				.cMensaje = tcMensaje 
				.lRetorno = tlRetorno
				.lParametro = txParametro
				.lParametro2 = txParametro2
				.lParametro3 = txParametro3
				return dodefault( tcMensaje , tlRetorno , txParametro , txParametro2 , txParametro3 )			
			endwith
		else
			return 2		
		endif
enddefine





*-----------------------------------------------------------------------------------------
function GuardarEntorno( toTest as Object ) as Void
	Local lnProp as Integer, i as integer, lcPropiedad as string, j as integer
	local array laProp[ 1 ]
	
	lnProp = amembers( laProp, _screen.zoo.app, 0 )
	for i = 1 to lnProp 
		lcPropiedad = laProp[ i ]

		if !pemstatus( toTest.oPropiedades, lcPropiedad, 5 )

			if type( "alen( _Screen.zoo.app.&lcPropiedad )" ) = "N"
				lcPropiedad = lcPropiedad + "[" + transform( alen( _Screen.zoo.app.aSucursales, 1 ) ) + "," + ;
												transform( alen( _Screen.zoo.app.aSucursales, 2 ) ) + "]"
			endif
			toTest.oPropiedades.AddProperty( lcPropiedad, null )
		endif
		
		try
			toTest.oPropiedades.&lcPropiedad = _Screen.zoo.app.&lcPropiedad
		catch
		endtry
	endfor

	for i = 1 to alen( _Screen.zoo.app.aSucursales, 1 )
		for j = 1 to alen( _Screen.zoo.app.aSucursales, 2 )
			toTest.oPropiedades.aSucursales[ i, j ] = _Screen.zoo.app.aSucursales[ i, j ] 
		endfor
	endfor

	for i = 1 to alen( _Screen.zoo.app.aArchivosIni, 1 )
		for j = 1 to alen( _Screen.zoo.app.aArchivosIni, 2 )
			toTest.oPropiedades.aArchivosIni[ i, j ] = _Screen.zoo.app.aArchivosIni[ i, j ] 
		endfor
	endfor
endfunc 

*-----------------------------------------------------------------------------------------
function RestablecerEntorno( toTest as Object ) as Void
	Local lnProp as Integer, i as integer, lcPropiedad as string, lcDim as string
	local array laProp[ 1 ]

	lnProp = amembers( laProp, _screen.zoo.app, 0 )
	for i = 1 to lnProp 
		lcPropiedad = laProp[ i ]

		if type( "alen( _Screen.zoo.app.&lcPropiedad )" ) = "N"
			lcDim = "_Screen.zoo.app." + lcPropiedad  + "[" + transform( alen( toTest.oPropiedades.aSucursales, 1 ) ) + "," + ;
											transform( alen( toTest.oPropiedades.aSucursales, 2 ) ) + "]"
			
			dimension &lcDim  
		endif

		try
			_Screen.zoo.app.&lcPropiedad = toTest.oPropiedades.&lcPropiedad 
		catch
		endtry
	endfor

	With toTest.oPropiedades
		goDatos				= .oDatos
		goFormularios		= .oFormularios
		goMonitor			= .oMonitor
		goDatos				= .oDatos
		goLibrerias			= goServicios.Librerias
		_screen.zoo.app.oLibrerias 			= goServicios.Librerias
*		_screen.zoo.app.oExportaciones		= goServicios.Exportaciones
		goMensajes			= .oMensajes
		goControles			= .oServicioControles
		goParametros		= .oParametros
		goRegistry			= .oRegistry
		goModulos			= .oModulos
		goEstilos			= .oEstilos
		goTimer				= .oTimerBase
	endwith

	for i = 1 to alen( _Screen.zoo.app.aSucursales, 1 )
		for j = 1 to alen( _Screen.zoo.app.aSucursales, 2 )
			_Screen.zoo.app.aSucursales[ i, j ] = toTest.oPropiedades.aSucursales[ i, j ] 
		endfor
	endfor

	for i = 1 to alen( _Screen.zoo.app.aArchivosIni, 1 )
		for j = 1 to alen( _Screen.zoo.app.aArchivosIni, 2 )
			_Screen.zoo.app.aArchivosIni[ i, j ] = toTest.oPropiedades.aArchivosIni[ i, j ] 
		endfor
	endfor
	
	_screen.zoo.app.InicializarBaseDeDatos()
endfunc 


define class mock_librerias as Librerias of Librerias.prg
	cRetornoIni = ""
	lPasoPorBuscarActualizaciones = .f.

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDeIni( tcParam1, tcParam2, tcParam3 ) as Void
		return This.cRetornoIni
	endfunc 
	*-----------------------------------------------------------------------------------------
	function BuscarActualizaciones( tlModoSilencioso as Boolean ) as Void
		this.lPasoPorBuscarActualizaciones = .t.
	endfunc 	

enddefine



define class AplicacionBaseAux as AplicacionNucleo Of AplicacionNucleo.prg

	*-----------------------------------------------------------------------------------------
	function GenerarArchivoAplicacionIniAux( tcRutaArchivo as string ) as Void
		this.GenerarArchivoAplicacionIni( tcRutaArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarArchivoDataConfigAux() as Void
		this.GenerarArchivoDataConfig()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ejecutoDesdeExe() as Boolean
		return .t.
	endfunc
enddefine

define class aplicacionbase_prueba as aplicacionbase of aplicacionbase.prg
	lCopio = .t.
	*-----------------------------------------------------------------------------------------
	function CopiarDBSucursales( tcSucursalOrigen as String, tcRutaOrigen as String, tcSucursalDestino as String, tcRutaDestino as String ) as Boolean 
		this.lCopio = .f.
		return this.lCopio
	endfunc
	*-----------------------------------------------------------------------------------------
	function SetearParametrosModoAvanzadoyEstilo_Prueba() as Void
		this.SetearParametrosModoAvanzadoyEstilo()
	endfunc 



enddefine


function agregarMockDeCopiarDB

_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Inicializar', .T., "'CopyaBD','C:\ZOO\NUCLEO\sucursal\CopyaBD\',42" )

_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'ALEMANIA.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'ARGENTIN.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'BOLIVIA.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CANADA.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CANADA2.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CHIPRE.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CHIPRE2.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CONGO.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CUBA.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CUBA2.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CUBA2_CUBOBS.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'CUBA_CUBOBS.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'DETCANADA2.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'HABIT.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'HOLANDA.DBF','Copiado ok.'" ) 
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'HON.DBF','Copiado ok.'" )
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'HON2.DBF','Copiado ok.'" )
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'IPROVIN.DBF','Copiado ok.'" )
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'IPROVIN2.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:25
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'ITALIA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:25
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'ITEMSENE.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:25
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'JAMAICA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:26
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'KOREA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:26
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'LETONIA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:26
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'MALTA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:27
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'MEXICO.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:27
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'ORDAT.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:27
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'PAKISTAN.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:28
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'PAKISTAN_COBS.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:28
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'PARAMETROSSUCURSAL.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:28
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'REPDOM.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:29
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'REPUBLICA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:29
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'RUSIA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:29
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'RUSIA_RUSOBS.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:30
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'SENEGAL.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:30
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'RIO.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:30
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'RIO2.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:30
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'SYS_S.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:30
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'TANZANIA.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:31
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'URUGUAY.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:31
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'URUGUAY2.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:31
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'USU.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:32
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Actualizar', .T., "'X.DBF','Copiado ok.'" ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:32
_screen.mocks.AgregarSeteoMetodo( 'MOSTRARCOPIADB', 'Finalizar', .T. ) && ZTESTAPLICACIONBASE.ZTESTCOPIADBD 29/01/08 13:48:34


endfunc

*-----------------------------------------------------------------------------------------
define class ObjetoBindeo as Custom
	lPasoPorSacaratributossololectura = .f.
	lPasoPorIniciarEstilos = .F.

	*-----------------------------------------------------------------------------------------
	function Sacaratributossololectura( tcRuta as String )
		this.lPasoPorSacaratributossololectura = .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarEstilos( tcClase as String, tcObjetoApp as String, tcObjetoGlobal as string, txPar1 as variant, tcDescripcion as String ) as Void
		if upper( alltrim( tcClase ) ) == "ESTILOS"
			this.lPasoPorIniciarEstilos = .t.
		endif
	endfunc 

enddefine

define class aplicacionbase2 as aplicacionnucleo of aplicacionnucleo.prg
	nOrdenIniciarServiciosConDependencia = 0
	nOrdenIniciarServiciosSinDependencia = 0
	nOrdenSetearAplicacion = 0	
	
	nOrdenDeEjecucion = 0
	*-----------------------------------------------------------------------------------------
	function EjecutoDesdeExe() as Boolean
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarServiciosConDependencia() as Void
		this.nOrdenDeEjecucion = this.nOrdenDeEjecucion + 1
		this.nOrdenIniciarServiciosConDependencia = this.nOrdenDeEjecucion
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServiciosSinDependencia() as Void
		this.nOrdenDeEjecucion = this.nOrdenDeEjecucion + 1
		this.nOrdenIniciarServiciosSinDependencia = this.nOrdenDeEjecucion
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearAplicacion() as Void
		this.nOrdenDeEjecucion = this.nOrdenDeEjecucion + 1
		this.nOrdenSetearAplicacion = this.nOrdenDeEjecucion
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Sacaratributossololectura( tcRuta as string ) as Void
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarDiferenciasDeEstructurav2( tnProcesos as Integer, tcSucursales as String ) as boolean
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
define class AplicacionNucleoPrueba as AplicacionNucleo of AplicacionNucleo.prg
	lPasoPorSalir = .f.
	lPasoPorReindexar = .f.
	lHayEntidadEnEdicion = .f.
	oColDif = null
	
	*-----------------------------------------------------------------------------------------
	function Salir() as Void
		this.lPasoPorSalir = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarReindexador( tcBaseDeDatos as string ) as Void
		this.lPasoPorReindexar = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteFormularioEnEdicion() as boolean

		return This.lHayEntidadEnEdicion

	endfunc 
	
	*-------------------------------------------------------------------
	Function CrearObjeto( tcClase as String, tcLibreria as string, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant )
		local loRetorno as object
		if alltrim( upper( tcClase )) == "ADNIMPLANT"
			loRetorno = newobject( "adnimplant_fake" )
			loRetorno.oColDif = this.oColDif
		else
			loRetorno = dodefault( tcClase, tcLibreria, tvPar1, tvPar2, tvPar3, tvPar4, tvPar5, tvPar6, tvPar7, tvPar8 )
		endif
		return loRetorno
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
Define class AplicacionNucleo_Mock as AplicacionNucleo of AplicacionNucleo.Prg

	lPasoPorSalir = .f.
	lMockearLibreria = .f.

	*-----------------------------------------------------------------------------------------
	function ValidarEmpVacia_Mock() as Boolean
		return This.ValidarEmpVacia()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Salir() as Void
		This.lPasoPorSalir = .t.

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarIntegridadTablas_mock() as Boolean
		return This.ValidarIntegridadTablas()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarDiferenciasDeEstructurav2( tnProcesos as Integer, tcSucursales as String ) as boolean
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CrearGoLibrerias() as Void
		if this.lMockearLibreria
			public goLibrerias
			goServicios.Librerias = newObject( "mock_librerias" )
			goLibrerias = goServicios.Librerias
		else
			dodefault()
		endif
	endfunc 
enddefine

define class AdnImplant_fake as adnimplant of adnimplant.prg
	oColDif = null
	*-----------------------------------------------------------------------------------------
	function Inicializar( tlMuestraForm as Logical, tcBaseMaster as String, tcSucursalDefault as String )
		local loLogueoEnFormulario as Object, loLogueoEnArchivo as Object 

		dodefault( tlMuestraForm, tcBaseMaster )

		with this
			.oManagerAdnImplant = newobject( "ManagerAdnImplant_fake_" + _screen.zoo.app.TipoDeBase  )
			.oManagerAdnImplant.Inicializar( tcBaseMaster, tcSucursalDefault )
			this.enlazar( "oManagerAdnImplant.EventoObtenerInformacion", "inyectarInformacion" )
		endwith
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Procesar( tcSucursales as String, tnProcesos as Integer ) as Void
		_screen.lPasoPorProcesarAdnImplant = .t.
		this.oManagerAdnImplant.oColDif = this.oColDif
		return dodefault( tcSucursales, tnProcesos )
	endfunc	
enddefine

define class ManagerAdnImplant_fake_nativa as ManagerAdnImplantnativa
	oColDif = null
	
	*-----------------------------------------------------------------------------------------
	Function SuscribirObservador( toObservador As iLogueo Of iLogueo.prg ) As Void

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ExistenDiferenciaEstructuraCursores() as Boolean
		return .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDiferenciasDeEstructura( tcSucursal as String, tcTipoDeBase as String ) as ZooColeccion of ZooColeccion.prg
		return this.oColDif 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarReindexador( tcSucursales as String ) as Void
		_screen.lPasoPorReindexar = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearProcesos( tnProcesos as Integer ) as Void
		with this
			.lProcesarSucursal = .f.
			.lProcesarZooMaster = .t.
			.nProcesos = 2
		endwith
	endfunc 	
enddefine

define class ManagerAdnImplant_fake_sqlserver as ManagerAdnImplantsqlserver
	oColDif = null
	
	*-----------------------------------------------------------------------------------------
	Function SuscribirObservador( toObservador As iLogueo Of iLogueo.prg ) As Void

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ExistenDiferenciaEstructuraCursores() as Boolean
		return .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDiferenciasDeEstructura( tcSucursal as String, tcTipoDeBase as String ) as ZooColeccion of ZooColeccion.prg
		return this.oColDif 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarReindexador( tcSucursales as String ) as Void
		_screen.lPasoPorReindexar = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearProcesos( tnProcesos as Integer ) as Void
		with this
			.lProcesarSucursal = .f.
			.lProcesarZooMaster = .t.
			.nProcesos = 2
		endwith
	endfunc	
enddefine

*-----------------------------------------------------------------------------------------
define class MenuXML As Custom

	cXMLMenuActivado    = ""
	cXMLMenuDesactivado = ""

	function cXMLMenuActivado_access
		local lcTexto As String
		text to lcTexto NoShow
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData xml:space="preserve">
	<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsd:element name="VFPData" msdata:IsDataSet="true">
			<xsd:complexType>
				<xsd:choice maxOccurs="unbounded">
					<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
						<xsd:complexType>
							<xsd:attribute name="id" type="xsd:int" use="required"/>
							<xsd:attribute name="ltieneseguridad" type="xsd:boolean" use="required"/>
							<xsd:attribute name="padre" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="myself" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="100"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="codigo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="80"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="etiqueta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="80"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="accesorapido" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="comando" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="200"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="nivel" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="imagen" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="100"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="skipfor" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="200"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="orden" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="comienzagrupo" type="xsd:boolean" use="required"/>
							<xsd:attribute name="tipo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="condicion" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2147483647"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="idinterno" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="entidad" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
						</xsd:complexType>
					</xsd:element>
				</xsd:choice>
				<xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax"/>
			</xsd:complexType>
		</xsd:element>
	</xsd:schema>
	<row id="13" ltieneseguridad="true" padre="                                                                                                                                                                                                                                                              " myself="\&lt;Listados                                                                                          " codigo="Listados                                                                        " etiqueta="\&lt;Listados                                                                      " accesorapido="               " comando="                                                                                                                                                                                                        " nivel="1" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="36" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="ME_13                                                                                                                                                                                                                                                         " entidad="                                        "/>
	<row id="26" ltieneseguridad="true" padre="ME_13                                                                                                                                                                                                                                                         " myself="Cuentas c\&lt;orrientes                                                                                " codigo="Listado de Cuentas Corrientes                                                   " etiqueta="Cuentas c\&lt;orrientes                                                            " accesorapido="               " comando="                                                                                                                                                                                                        " nivel="2" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="7" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="ME_26                                                                                                                                                                                                                                                         " entidad="                                        "/>
	<row id="163" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="\&lt;Estado de cuentas de clientes                                                                     " codigo="Estado de cuentas de clientes                                                   " etiqueta="\&lt;Estado de cuentas de clientes                                                 " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-EDC&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="1" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="IT_163                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="164" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="\&lt;Resumen de cuentas de clientes                                                                    " codigo="Resumen de cuentas de clientes                                                  " etiqueta="\&lt;Resumen de cuentas de clientes                                                " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RSC&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="2" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="IT_164                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="165" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="\&lt;Listado de cobranzas                                                                              " codigo="Listado de cobranzas                                                            " etiqueta="\&lt;Listado de cobranzas                                                          " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RC&quot;                                                                                                                                                             " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="3" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="IT_165                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="166" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Retenciones de \&lt;cobranzas                                                                          " codigo="Retenciones de cobranzas                                                        " etiqueta="Retenciones de \&lt;cobranzas                                                      " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RETEN&quot;                                                                                                                                                          " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="4" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="IT_166                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="167" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Estado de cuentas de \&lt;proveedores                                                                  " codigo="Estado de cuentas de proveedores                                                " etiqueta="Estado de cuentas de \&lt;proveedores                                              " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-EDP&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="5" comienzagrupo="true" tipo="MENU                " condicion="" idinterno="IT_167                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="168" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Re\&lt;sumen de cuentas de proveedores                                                                 " codigo="Resumen de cuentas de proveedores                                               " etiqueta="Re\&lt;sumen de cuentas de proveedores                                             " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RSP&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="6" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="IT_168                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="169" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Listados de p\&lt;agos                                                                                 " codigo="Listados de pagos                                                               " etiqueta="Listados de p\&lt;agos                                                             " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RP&quot;                                                                                                                                                             " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="7" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="IT_169                                                                                                                                                                                                                                                        " entidad="                                        "/>
</VFPData>
		endtext
		return lcTexto
	endfunc
		
	function cXMLMenuDesactivado_access && Submenú con items DESACTIVADOS
		local lcTexto As String
		text to lcTexto NoShow
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData xml:space="preserve">
	<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsd:element name="VFPData" msdata:IsDataSet="true">
			<xsd:complexType>
				<xsd:choice maxOccurs="unbounded">
					<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
						<xsd:complexType>
							<xsd:attribute name="id" type="xsd:int" use="required"/>
							<xsd:attribute name="ltieneseguridad" type="xsd:boolean" use="required"/>
							<xsd:attribute name="padre" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="myself" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="100"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="codigo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="80"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="etiqueta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="80"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="accesorapido" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="comando" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="200"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="nivel" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="imagen" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="100"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="skipfor" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="200"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="orden" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="comienzagrupo" type="xsd:boolean" use="required"/>
							<xsd:attribute name="tipo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="condicion" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2147483647"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="idinterno" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="entidad" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
						</xsd:complexType>
					</xsd:element>
				</xsd:choice>
				<xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax"/>
			</xsd:complexType>
		</xsd:element>
	</xsd:schema>
	<row id="13" ltieneseguridad="true" padre="                                                                                                                                                                                                                                                              " myself="\&lt;Listados                                                                                          " codigo="Listados                                                                        " etiqueta="\&lt;Listados                                                                      " accesorapido="               " comando="                                                                                                                                                                                                        " nivel="1" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="36" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="ME_13                                                                                                                                                                                                                                                         " entidad="                                        "/>
	<row id="26" ltieneseguridad="true" padre="ME_13                                                                                                                                                                                                                                                         " myself="Cuentas c\&lt;orrientes                                                                                " codigo="Listado de Cuentas Corrientes                                                   " etiqueta="Cuentas c\&lt;orrientes                                                            " accesorapido="               " comando="                                                                                                                                                                                                        " nivel="2" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="7" comienzagrupo="false" tipo="MENU                " condicion="" idinterno="ME_26                                                                                                                                                                                                                                                         " entidad="                                        "/>
	<row id="163" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="\&lt;Estado de cuentas de clientes                                                                     " codigo="Estado de cuentas de clientes                                                   " etiqueta="\&lt;Estado de cuentas de clientes                                                 " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-EDC&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="1" comienzagrupo="false" tipo="MENU                " condicion="1=2" idinterno="IT_163                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="164" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="\&lt;Resumen de cuentas de clientes                                                                    " codigo="Resumen de cuentas de clientes                                                  " etiqueta="\&lt;Resumen de cuentas de clientes                                                " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RSC&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="2" comienzagrupo="false" tipo="MENU                " condicion="1=2" idinterno="IT_164                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="165" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="\&lt;Listado de cobranzas                                                                              " codigo="Listado de cobranzas                                                            " etiqueta="\&lt;Listado de cobranzas                                                          " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RC&quot;                                                                                                                                                             " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="3" comienzagrupo="false" tipo="MENU                " condicion="1=2" idinterno="IT_165                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="166" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Retenciones de \&lt;cobranzas                                                                          " codigo="Retenciones de cobranzas                                                        " etiqueta="Retenciones de \&lt;cobranzas                                                      " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RETEN&quot;                                                                                                                                                          " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="4" comienzagrupo="false" tipo="MENU                " condicion="1=2" idinterno="IT_166                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="167" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Estado de cuentas de \&lt;proveedores                                                                  " codigo="Estado de cuentas de proveedores                                                " etiqueta="Estado de cuentas de \&lt;proveedores                                              " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-EDP&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="5" comienzagrupo="true" tipo="MENU                " condicion="1=2" idinterno="IT_167                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="168" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Re\&lt;sumen de cuentas de proveedores                                                                 " codigo="Resumen de cuentas de proveedores                                               " etiqueta="Re\&lt;sumen de cuentas de proveedores                                             " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RSP&quot;                                                                                                                                                            " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="6" comienzagrupo="false" tipo="MENU                " condicion="1=2" idinterno="IT_168                                                                                                                                                                                                                                                        " entidad="                                        "/>
	<row id="169" ltieneseguridad="true" padre="ME_26                                                                                                                                                                                                                                                         " myself="Listados de p\&lt;agos                                                                                 " codigo="Listados de pagos                                                               " etiqueta="Listados de p\&lt;agos                                                             " accesorapido="               " comando="do EjecutarOpcionLince.prg with &quot;LIS;CC-RP&quot;                                                                                                                                                             " nivel="3" imagen="                                                                                                    " skipfor="                                                                                                                                                                                                        " orden="7" comienzagrupo="false" tipo="MENU                " condicion="1=2" idinterno="IT_169                                                                                                                                                                                                                                                        " entidad="                                        "/>
</VFPData>
		endtext
		return lcTexto
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ObjAux as Custom

lEjecutoDetener = .f.
	*-----------------------------------------------------------------------------------------
	function Detener() as Void
		This.lEjecutoDetener = .t.

	endfunc 
enddefine


*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class ServicioDatosTest as ServicioDatos of ServicioDatos.prg
	cCursorXMLAux = ""
	cCursorAux = "cursorEmpAux"
	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		this.CrearCursorEmpAux( this.cCursorAux )
		this.LlenarCursorEmpAux( this.cCursorAux )
		this.cCursorXMLAux = this.PasarCursorEmpAuxAXml( this.cCursorAux )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		use in select( this.cCursorAux )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorEmpAux( tcCursor as String ) as Void
		create cursor &tcCursor ( base C(10), campo2 L, campo3 L, campo4 L, campo5 L, campo6 L, ;
								campo7 L, campo8 L, replicar L )								
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarCursorEmpAux( tcCursor as String ) as Void
		insert into &tcCursor ( base, replicar ) values ( "BASEAUX1", .f. )
		insert into &tcCursor ( base, replicar ) values ( "BASEAUX2", .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PasarCursorEmpAuxAXml( tcCursor as String ) as string
		local lcXml as string
		
		cursortoxml( tcCursor, "lcXml" )
		
		return lcXml
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EjecutarSentencias( tcSentencia as String, tcTablas as string, tcRuta as String, tcCursor as String, tnSesion as Integer ) as Void
		local lnSession as Integer, lcxml as string
		
		lnSesion = this.DataSessionId
		this.DataSessionId = tnSesion
		lcxml = this.cCursorXMLAux
		xmltocursor( lcxml, tcCursor, 4 )
		this.DataSessionId = lnSesion
	endfunc
	
enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class AplicacionNucleoTest as AplicacionNucleo of AplicacionNucleo.prg
	lPermiteAbmReplica = .F.
	lPasoPorMetodo = .F.
	cTablaParametro = ""
	oFxu = null
	nContador = 1
	*-----------------------------------------------------------------------------------------
	function cSucursalActiva_Assign( txVal as Variant ) as Void
		this.cSucursalActiva = txVal
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsUnaTablaQuePermiteABMEnReplica( tcTabla as String ) as Boolean
		this.lPasoPorMetodo = .T.
		this.oFxu.AssertEquals( "No es la tabla esperada que tiene que verificar", upper( alltrim( this.cTablaParametro ) ) + alltrim( str( this.nContador ) ), upper( alltrim( tcTabla ) ) )
		this.nContador = this.nContador + 1
		
		return this.lPermiteAbmReplica
	endfunc
		
enddefine

define class AuxFactory as custom
	RutaArchivoMdfSQLServer = ""
	*-----------------------------------------------------------------------------------------
	function ObtenerGestorBD( toParametros ) as Object
		return newobject( "AuxGestorDB" )
	endfunc 
	
enddefine
*-----------------------------------------------------------------------------------------
define class AuxParametros as Custom
	Sucursal = ""
	EjecutarSilencioso = .f.
	
	function AgregarBDAProcesar( bd, forzar )
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
define class AuxGestorDB as Custom
	*-----------------------------------------------------------------------------------------
	function ListarBDsArchivadas( tcBase ) as Object
		_Screen.mocks.Vaciar()
		return newobject( "collection" )
	endfunc
enddefine
