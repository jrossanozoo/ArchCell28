**********************************************************************
define class zTestPublServidoresComunicaciones as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestPublServidoresComunicaciones of zTestPublServidoresComunicaciones.prg
	#endif

	*---------------------------------
	function setup
		goServicios.Datos.EjecutarSentencias( 'delete from SRVCOMPUB', 'SRVCOMPUB' )
		goServicios.Datos.EjecutarSentencias( 'delete from SRVCOMPUBDET', 'SRVCOMPUBDET' )
	endfunc

	*---------------------------------
	function TearDown
		goServicios.Datos.EjecutarSentencias( 'delete from SRVCOMPUB', 'SRVCOMPUB' )
		goServicios.Datos.EjecutarSentencias( 'delete from SRVCOMPUBDET', 'SRVCOMPUBDET' )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSubirAServidorLocal
		local loEntidad as ent_PublServidoresComunicaciones of ent_PublServidoresComunicaciones.prg, lcServidor as string, ;
			lcCarpetaLocal

		lcServidor = alltrim( left( sys( 0 ), at( "#", sys( 0 ) ) - 1 ) )
		lcCarpetaLocal = "\\" + lcServidor + "\c$\" + sys( 2015 )
		mkdir ( lcCarpetaLocal )
		mkdir ( addbs( lcCarpetaLocal ) + "zoo680" )
		mkdir ( addbs( lcCarpetaLocal ) + "zoo693" )

		this.agregarmocks( "ConfServidoresComunicaciones, ServidoresZLZ, Mensajes, ServidoresComunicaciones, DireccionesDeDescarga" )

		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Cambiosdetalledirecciones', .t. )
		_screen.mocks.AgregarSeteoMetodo( 'C', 'Cambiosdetalledirecciones', .t. )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .T., "[Direcciones.EventoAdvertirLimitePorDiseno],[EventoAdvertirLimitePorDiseno]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .T., "[Direcciones.EventoCancelarCargaLimitePorDiseno],[EventoCancelarCargaLimitePorDiseno]" ) 

		_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Confservidorescomunicaciones', 'Obtenerdatosdetalledirecciones', ObtenerXMLDireccionesMock(), "[],[Codigo = 1],[Tipo]" )

		loEntidad = _screen.Zoo.InstanciarEntidad( "PublServidoresComunicaciones" )
		with loEntidad
			.Nuevo()
			LlenarAtributosPublServidoresComunicaciones( loEntidad )
			with .servidoresASubir
				.oItem.Servidor_PK = 1
				.oItem.Modo = 2
				.oItem.ModoV = "Local"
				.oItem.Direccion = strtran( lcCarpetaLocal, "c$", "cc$" )
				.oItem.Resultado = ""
				.oItem.ServidorDeOrigen = "www." + lcServidor + ".com.ar"

				.Actualizar()
			endwith
			.Grabar()
			this.assertequals( "No se actualizó el resultado", "Invalid path or file name.", .servidoresASubir.Item[1].Resultado )

			.Nuevo()
			LlenarAtributosPublServidoresComunicaciones( loEntidad )
			with .servidoresASubir
				.CargarItem( 1 )
				.oItem.Servidor_PK = 1
				.oItem.Modo = 2
				.oItem.ModoV = "Local"
				.oItem.Direccion = lcCarpetaLocal
				.oItem.Resultado = ""
				.oItem.ServidorDeOrigen = "www." + lcServidor + ".com.ar"

				.Actualizar()
			endwith
			.Grabar()

			this.assertequals( "No se actualizó el resultado", "OK", .servidoresASubir.item[1].Resultado )
			this.asserttrue( "No se subió el archivo a la carpeta zoo680", file( addbs( lcCarpetaLocal ) + "zoo680\zoologic.zoo" ) )
			this.asserttrue( "No se subió el archivo a la carpeta zoo693", file( addbs( lcCarpetaLocal ) + "zoo693\zoologic.zoo" ) )
			this.asserttrue( "No se subió el archivo a la carpeta zoo2009", file( addbs( lcCarpetaLocal ) + "zoo2009\zoologic.zoo" ) )
			this.asserttrue( "No se subió el archivo config a la carpeta zoo680", file( addbs( lcCarpetaLocal ) + "zoo680\config.json" ) )
			this.asserttrue( "No se subió el archivo config a la carpeta zoo693", file( addbs( lcCarpetaLocal ) + "zoo693\config.json" ) )
			this.asserttrue( "No se subió el archivo config a la carpeta zoo2009", file( addbs( lcCarpetaLocal ) + "zoo2009\config.json" ) )
			delete file ( addbs( lcCarpetaLocal ) + "zoo680\zoologic.zoo" )
			delete file ( addbs( lcCarpetaLocal ) + "zoo693\zoologic.zoo" )
			delete file ( addbs( lcCarpetaLocal ) + "zoo2009\zoologic.zoo" )
			delete file ( addbs( lcCarpetaLocal ) + "zoo680\config.json" )
			delete file ( addbs( lcCarpetaLocal ) + "zoo693\config.json" )
			delete file ( addbs( lcCarpetaLocal ) + "zoo2009\config.json" )
			rd ( addbs( lcCarpetaLocal ) + "zoo680" )
			rd ( addbs( lcCarpetaLocal ) + "zoo693" )
			rd ( addbs( lcCarpetaLocal ) + "zoo2009" )
			rd ( lcCarpetaLocal )
		endwith
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarLlenadoDeServidores
		local loEntidad as ent_PublServidoresComunicaciones of ent_PublServidoresComunicaciones.prg, loError as zooexception of zooexception.prg, ;
			loInfo as object

		this.agregarmocks( "ConfServidoresComunicaciones, ServidoresZLZ, Mensajes, ServidoresComunicaciones, DireccionesDeDescarga" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'C', 'Cambiosdetalledirecciones', .t. )

		_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Confservidorescomunicaciones', 'Obtenerdatosdetalledirecciones', ObtenerXMLDireccionesMock(), "[],[Codigo = 1],[Tipo]" )

		loEntidad = _screen.Zoo.InstanciarEntidad( "PublServidoresComunicaciones" )

		with loEntidad
			.Nuevo()
			.Configuracion_PK = 1
			try
				.Grabar()
				this.asserttrue( "Debe dar error por falta de llenado de detalle de servidores a los cuales subir", .f. )
			catch to loError
				loInfo = .ObtenerInformacion()
				this.assertequals( "El mensaje de error no es el correcto", "Falta agregar al menos un servidor de alojamiento", loInfo[1].cMensaje )
			endtry

			with .servidoresASubir
				.oItem.Servidor_PK = 1
				.oItem.Modo = 2
				.oItem.ModoV = ""
				.oItem.Direccion = ""
				.oItem.Resultado = ""

				.Actualizar()
			endwith
		endwith

		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestCrearZooLogicZooManual
		local loEntidad as ent_PublServidoresComunicaciones of ent_PublServidoresComunicaciones.prg, lcDato as string
		private goLibrerias

		this.agregarmocks( "Librerias, ConfServidoresComunicaciones, ServidoresZLZ, Mensajes, ServidoresComunicaciones, DireccionesDeDescarga" )
		
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Cambiosdetalledirecciones', .t. )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .T., "[Direcciones.EventoAdvertirLimitePorDiseno],[EventoAdvertirLimitePorDiseno]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .T., "[Direcciones.EventoCancelarCargaLimitePorDiseno],[EventoCancelarCargaLimitePorDiseno]" ) 

		_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Confservidorescomunicaciones', 'Obtenerdatosdetalledirecciones', ObtenerXMLDireccionesMock(), "[],[Codigo = 1],[Tipo]" )

		goLibrerias = newobject( "Mock_Librerias" )

		loEntidad = newobject( "TEST_Publservidorescomunicaciones" )

		with loEntidad
			LlenarAtributosPublServidoresComunicaciones( loEntidad )

			.CrearZoologicZoo_AUX( _screen.Zoo.ObtenerRutaTemporal() )
			local lcArchivo as string
			lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + "ZooLogic.zoo"

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Identificacion", "Servidor de Origen" )
			this.assertequals( "El dato no coincide Sección: Identificacion - Entrada: Servidor de Origen", "Creado en carpeta local", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Identificacion", "Numero de Orden" )
			this.assertequals( "El dato no coincide Sección: Identificacion - Entrada: Numero de Orden", "001", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Identificacion", "Fecha Publicacion" )
			this.Asserttrue( "El dato no coincide Sección: Identificacion - Entrada: Fecha Publicacion", !empty( ctot( lcDato ) ) )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Identificacion", "Firma digital" )
			this.assertequals( "El dato no coincide Sección: Identificacion - Entrada: Firma digital", "479606", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_Status" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_Status", .Configuracion.EstadoServidor1, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_Domain" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_Domain", .Configuracion.Servidor1.Dominio, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_POP3host" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_POP3host", .Configuracion.Servidor1.Pop3Host, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_SMTPhost" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_SMTPhost", .Configuracion.Servidor1.SMTPHost, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_AnteponerUserName" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_AnteponerUserName", .Configuracion.Servidor1.AnteponerUserName, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_AgregarUserName" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_AgregarUserName", .Configuracion.Servidor1.AgregarUserName, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_AnteponerCuenta" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_AnteponerCuenta", .Configuracion.Servidor1.AnteponerCuenta, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_AnteponerClave" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_AnteponerClave", .Configuracion.Servidor1.AnteponerClave, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_AgregarUserName" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_AgregarUserName", .Configuracion.Servidor1.AgregarUserName, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_SMTPAutenticacion" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_SMTPAutenticacion", "Si", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_SMTPAut_UserName" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_SMTPAut_UserName", .Configuracion.Servidor1.SMTPAut_UserName, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_SMTPAut_Password" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_SMTPAut_Password", .Configuracion.Servidor1.SMTPAut_Password, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_UtilizaConfiguracionPersonalizada" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_UtilizaConfiguracionPersonalizada", "NO", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_MetodoDeComunicacion" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_MetodoDeComunicacion", transform( .Configuracion.MetodoDeComunicacion1 ), lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_ModoPasivo" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_ModoPasivo", "", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_TipoEnvioFTP" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_TipoEnvioFTP", "", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_ControlPortServer" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_ControlPortServer", "", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_PuertoLocaldatos" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_PuertoLocaldatos", "", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor1_DireccionLocaldatos" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor1_DireccionLocaldatos", "", upper( lcDato ) )

************* SERVIDOR 2
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor2_Status" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor2_Status", "Activo", lcDato )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor2_ModoPasivo" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor2_ModoPasivo", "SI", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor2_TipoEnvioFTP" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor2_TipoEnvioFTP", "BINARIO", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor2_ControlPortServer" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor2_ControlPortServer", "21", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor2_PuertoLocaldatos" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor2_PuertoLocaldatos", "", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor2_DireccionLocaldatos" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor2_DireccionLocaldatos", "", upper( lcDato ) )

************* SERVIDOR 3
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor3_Status" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor3_Status", "Activo", lcDato )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor3_ModoPasivo" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor3_ModoPasivo", "NO", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor3_TipoEnvioFTP" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor3_TipoEnvioFTP", "ASCII", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor3_ControlPortServer" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor3_ControlPortServer", "45021", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor3_PuertoLocaldatos" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor3_PuertoLocaldatos", "", upper( lcDato ) )
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "Servidores", "Servidor3_DireccionLocaldatos" )
			this.assertequals( "El dato no coincide Sección: Servidores - Entrada: Servidor3_DireccionLocaldatos", "", upper( lcDato ) )

************* URLs
			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Firma digital" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Firma digital", "949447", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Baja llaves" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Baja llaves", "No", lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Servidor de llaves 1" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Servidor de llaves 1", golibrerias.encriptar( .Configuracion.Direcciones.item[1].Direccion ), ;
			lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Servidor de llaves 2" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Servidor de versiones 2", golibrerias.encriptar( .Configuracion.Direcciones.item[5].Direccion ) ;
			, lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Servidor de retornos 1" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Servidor de retornos 1", golibrerias.encriptar( .Configuracion.Direcciones.item[2].Direccion ), ;
			lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Servidor de estadisticas 1" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Servidor de estadisticas 1", ;
			golibrerias.encriptar( .Configuracion.Direcciones.item[3].Direccion ), lcDato )

			lcDato = goLibrerias.ObtenerDatosDeIni( lcArchivo, "URLs", "Servidor de versiones 1" )
			this.assertequals( "El dato no coincide Sección: URLs - Entrada: Servidor de versiones 1", ;
			golibrerias.encriptar( .Configuracion.Direcciones.item[4].Direccion ), lcDato )

		endwith
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSugerirServidores
		local loEntidad as ent_PublServidoresComunicaciones of ent_PublServidoresComunicaciones.prg, ;
			loObjBusqueda as object, lcRutaSucursal as string

		this.agregarmocks( "ConfServidoresComunicaciones, ServidoresZLZ, Mensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'servidoreszlz', 'Eventocambioetiquetas', .T. )

		_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Confservidorescomunicaciones', 'Obtenerdatosdetalledirecciones', ObtenerXMLDireccionesMock(), "[],[Codigo = 1],[Tipo]" )
		loEntidad = _screen.Zoo.InstanciarEntidad( "Publservidorescomunicaciones" )
		loEntidad.Nuevo()
		this.Assertequals( "No debe haber datos en la grilla de servidores a subir", 0, loEntidad.ServidoresASubir.count )
		loEntidad.Configuracion_PK = 1
		with loEntidad.ServidoresASubir
			.LimpiarItem()
			with .oItem	
				.Servidor_PK = 1
				.Modo = 1
				.Servidor.ServidorPublicacion = "Servidor1"
				.Servidor.DireccionZLZ = "direccion 1"
				.Servidor.ModoSubida = 1
				.Servidor.ServidorZlZ = "Servidor 1"
				.Servidor.UsuarioZlZ = "admin1"
				.Servidor.ContraseñaZlZ = "Contra1"				
			endwith
			.Actualizar()

			.LimpiarItem()
			with .oItem
				.Servidor_PK = 2
				.Modo = 1
				.Servidor.ServidorPublicacion = "Servidor1"
				.Servidor.DireccionZLZ = "direccion 1"
				.Servidor.ModoSubida = 1
				.Servidor.ServidorZlZ = "Servidor 1"
				.Servidor.UsuarioZlZ = "admin1"
				.Servidor.ContraseñaZlZ = "Contra1"			
			endwith
			.Actualizar()
		endwith
		
		loEntidad.Grabar()

		loEntidad.Nuevo()
		loEntidad.Configuracion_PK = 1
		
		loEntidad.ServidoresASubir.CargarItem(1)
		loEntidad.ServidoresASubir.oitem.Modo = 1
		loEntidad.ServidoresASubir.actualizar()
		
		loEntidad.ServidoresASubir.CargarItem(2)
		loEntidad.ServidoresASubir.oitem.Modo = 1
		loEntidad.ServidoresASubir.actualizar()
		
		this.Assertequals( "Debe haber datos en la grilla de servidores a subir", 2, loEntidad.ServidoresASubir.count )
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide", 1, loEntidad.ServidoresASubir.item[1].Servidor_PK )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide", 2, loEntidad.ServidoresASubir.item[2].Servidor_PK )
		loEntidad.Grabar()
		loEntidad.release()
	

		
		loEntidad = _screen.Zoo.InstanciarEntidad( "Publservidorescomunicaciones" )
		loEntidad.Ultimo()
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide a", 1, loEntidad.ServidoresASubir.item[1].Servidor_PK )
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide b", "Servidor1", alltrim( loEntidad.ServidoresASubir.item[1].ServidorDeOrigen ) )
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide c", "direccion 1", alltrim( loEntidad.ServidoresASubir.item[1].Direccion ) )
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide d", 1, loEntidad.ServidoresASubir.item[1].Modo )
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide e", "FTP", alltrim( loEntidad.ServidoresASubir.item[1].ModoV ) )
		this.Assertequals( "El dato 1 de la grilla de servidores a subir no coincide f", ;
			lower( "No se pudo conectar al servidor Servidor 1. OLE IDispatch exception code 0 from XceedSoftware.XceedFtp.1: The address was not recognized as a valid IP address or hostname..." ), ;
			strtran( strtran( lower( alltrim( loEntidad.ServidoresASubir.item[1].Resultado ) ), chr(13), "" ), chr(10), "" ) )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide a", 2, loEntidad.ServidoresASubir.item[2].Servidor_PK )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide b", "Servidor1", alltrim( loEntidad.ServidoresASubir.item[2].ServidorDeOrigen ) )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide c", "direccion 1", alltrim( loEntidad.ServidoresASubir.item[2].Direccion ) )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide d", 1, loEntidad.ServidoresASubir.item[2].Modo )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide e", "FTP", alltrim( loEntidad.ServidoresASubir.item[2].ModoV ) )
		this.Assertequals( "El dato 2 de la grilla de servidores a subir no coincide f", ;
			lower( "No se pudo conectar al servidor Servidor 1. OLE IDispatch exception code 0 from XceedSoftware.XceedFtp.1: The address was not recognized as a valid IP address or hostname..." ), ;
			strtran( strtran( lower( alltrim( loEntidad.ServidoresASubir.item[1].Resultado ) ), chr(13), "" ), chr(10), "" ) )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ZtestObtenerConfig
		local loEntidad as Object, lcConfig as String
		
		this.agregarmocks( "Librerias, ConfServidoresComunicaciones, ServidoresZLZ, Mensajes, ServidoresComunicaciones, DireccionesDeDescarga" )
		
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor1.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor2.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Servidor3.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .t., "[Direcciones.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Cambiosdetalledirecciones', .t. )
		_screen.mocks.AgregarSeteoMetodo( 'C', 'Cambiosdetalledirecciones', .t. )
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .T., "[Direcciones.EventoAdvertirLimitePorDiseno],[EventoAdvertirLimitePorDiseno]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'confservidorescomunicaciones', 'Enlazar', .T., "[Direcciones.EventoCancelarCargaLimitePorDiseno],[EventoCancelarCargaLimitePorDiseno]" ) 

		loEntidad = _screen.Zoo.InstanciarEntidad( "PublServidoresComunicaciones" )
		with loEntidad
			.Nuevo()

			.Configuracion_PK = 1
			.Configuracion.Servidor1_PK = 98
			.Configuracion.Servidor1.MetodoDeComunicacion = 3
			.Configuracion.EstadoServidor1 = "Activo"			
			.Configuracion.Servidor1.Bucket = "bucket1"
			.Configuracion.Servidor1.Region = "region1"
			.Configuracion.Servidor1.AccessKey = "access1"
			.Configuracion.Servidor1.SecretKey = "secret1"
			.Configuracion.Servidor1.role= "role1"			
			
			.Configuracion.Servidor2_PK = 99
			.Configuracion.Servidor2.MetodoDeComunicacion = 3
			.Configuracion.EstadoServidor2 = "Baja"
			.Configuracion.Servidor2.Bucket = "bucket2"
			.Configuracion.Servidor2.Region = "region2"
			.Configuracion.Servidor2.AccessKey = "access2"
			.Configuracion.Servidor2.SecretKey = "secret2"
			.Configuracion.Servidor2.role= "role2"

			text to lcConfig textmerge
{
  "bucket": "bucket1",
  "endpoint": "region1",
  "accesKey": "access1",
  "secretkey": "secret1",
  "role": "role1",
  "bucketBajada": "bucket2",
  "endpointBajada": "region2",
  "accesKeyBajada": "access2",
  "secretkeyBajada": "secret2",
  "roleBajada": "role2" 
}
			endtext
			
			this.Assertequals( "El archivo config generado es incorrecto", lcConfig, .ObtenerConfig() )
					
			.Cancelar()
			.Release()
		endwith

	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class TEST_Publservidorescomunicaciones as ent_Publservidorescomunicaciones of ent_Publservidorescomunicaciones.prg

	*-----------------------------------------------------------------------------------------
	function CrearZoologicZoo_AUX( tcRuta as string ) as string
		return this.CrearZoologicZoo( tcRuta )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_Librerias as Librerias of Librerias.prg

*-----------------------------------------------------------------------------------------
function ObtenerFechaHora()
	return ctot( "30/03/09 10:40:18" )
endfunc

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
function ObtenerXMLDireccionesMock() as Void
	local lcCadena as string

	text to lcCadena noshow textmerge
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData xml:space="preserve">
	<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsd:element name="VFPData" msdata:IsDataSet="true">
			<xsd:complexType>
				<xsd:choice maxOccurs="unbounded">
					<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
						<xsd:complexType>
							<xsd:attribute name="tipo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="codigo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="entdireccion" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="tipov" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="direccion" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
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
	<row tipo="1" codigo="1" entdireccion="1" tipov="Llaves              " direccion="http://www.zoologicnet.com.ar/zoologic/conexiones/conexiones.asp                                                                                                                                                                                              "/>
	<row tipo="1" codigo="1" entdireccion="5" tipov="Llaves              " direccion="http://www.zoologicnet.com.ar/zoologic/conexiones/conexiones2.asp                                                                                                                                                                                             "/>
	<row tipo="2" codigo="1" entdireccion="2" tipov="Retorno             " direccion="http://www.zoologicnet.com.ar/zoologic/retorno.asp                                                                                                                                                                                                            "/>
	<row tipo="3" codigo="1" entdireccion="3" tipov="Estadísticas        " direccion="http://www.zoologicnet.com.ar/zoologic/elince/zoo2009                                                                                                                                                                                                         "/>
	<row tipo="4" codigo="1" entdireccion="4" tipov="Versión             " direccion="http://www.zoologicnet.com.ar/zoologic/elince/zoo2009                                                                                                                                                                                                         "/>
</VFPData>
	ENDTEXT

	return lcCadena
endfunc

*-----------------------------------------------------------------------------------------
function LlenarAtributosPublServidoresComunicaciones( toEntidad ) as Void
	with toEntidad
		.Configuracion_PK = 1
		.Configuracion.Servidor1_PK = 1
		.Configuracion.EstadoServidor1 = "Activo"
		.Configuracion.Servidor1.Dominio = "zoologic3.com.ar"
		.Configuracion.Servidor1.Pop3Host = "pop3.zoologic3.com.ar"
		.Configuracion.Servidor1.SMTPHost = "smtp.zoologic3.com.ar"
		.Configuracion.Servidor1.AnteponerUserName = ""
		.Configuracion.Servidor1.AgregarUserName = "@zoologic3.com.ar"
		.Configuracion.Servidor1.AnteponerCuenta = ""
		.Configuracion.Servidor1.AnteponerClave = ""
		.Configuracion.Servidor1.SMTPAut_UserName = ""
		.Configuracion.Servidor1.SMTPAut_Password = ""
		.Configuracion.Servidor1.ModoPasivo = .f.
		.Configuracion.Servidor1.PuertoControlServidor = 0
		.Configuracion.Servidor1.TipoEnvioDeDatos = 1
		.Configuracion.MetodoDeComunicacion1 = 1

		.Configuracion.Servidor2_PK = 2
		.Configuracion.EstadoServidor2 = "Activo"
		.Configuracion.Servidor2.Dominio = "zoologic3.com.ar"
		.Configuracion.Servidor2.Pop3Host = ""
		.Configuracion.Servidor2.SMTPHost = ""
		.Configuracion.Servidor2.AnteponerUserName = ""
		.Configuracion.Servidor2.AgregarUserName = ".zoologic3.com.ar"
		.Configuracion.Servidor2.AnteponerCuenta = ""
		.Configuracion.Servidor2.AnteponerClave = ""
		.Configuracion.Servidor2.SMTPAut_UserName = ""
		.Configuracion.Servidor2.SMTPAut_Password = ""
		.Configuracion.Servidor2.ModoPasivo = .t.
		.Configuracion.Servidor2.PuertoControlServidor = 21
		.Configuracion.Servidor2.TipoEnvioDeDatos = 1
		.Configuracion.MetodoDeComunicacion2 = 2

		.Configuracion.Servidor3_PK = 3
		.Configuracion.EstadoServidor3 = "Activo"
		.Configuracion.Servidor3.Dominio = "zoologic3.com.ar"
		.Configuracion.Servidor3.Pop3Host = ""
		.Configuracion.Servidor3.SMTPHost = ""
		.Configuracion.Servidor3.AnteponerUserName = ""
		.Configuracion.Servidor3.AgregarUserName = ".zoologic3.com.ar"
		.Configuracion.Servidor3.AnteponerCuenta = ""
		.Configuracion.Servidor3.AnteponerClave = ""
		.Configuracion.Servidor3.SMTPAut_UserName = ""
		.Configuracion.Servidor3.SMTPAut_Password = ""
		.Configuracion.Servidor3.ModoPasivo = .f.
		.Configuracion.Servidor3.PuertoControlServidor = 45021
		.Configuracion.Servidor3.TipoEnvioDeDatos = 2
		.Configuracion.MetodoDeComunicacion3 = 2

		with .Configuracion.Direcciones
			.oItem.EntDireccion_PK = 1
			.oItem.Tipo = 1
			.oItem.TipoV = ""
			.oItem.Direccion = "http://www.zoologicnet.com.ar/zoologic/conexiones/conexiones.asp"
			.Actualizar()

			.LimpiarItem()
			.oItem.EntDireccion_PK = 2
			.oItem.Tipo = 2
			.oItem.TipoV = ""
			.oItem.Direccion = "http://www.zoologicnet.com.ar/zoologic/retorno.asp"
			.Actualizar()

			.LimpiarItem()
			.oItem.EntDireccion_PK = 3
			.oItem.Tipo = 3
			.oItem.TipoV = ""
			.oItem.Direccion = "http://www.zoologicnet.com.ar/zoologic/elince/zoo2009"
			.Actualizar()

			.LimpiarItem()
			.oItem.EntDireccion_PK = 4
			.oItem.Tipo = 4
			.oItem.TipoV = ""
			.oItem.Direccion = "http://www.zoologicnet.com.ar/zoologic/elince/zoo2009"
			.Actualizar()

			.LimpiarItem()
			.oItem.EntDireccion_PK = 5
			.oItem.Tipo = 5
			.oItem.TipoV = ""
			.oItem.Direccion = "http://www.zoologicnet.com.ar/zoologic/conexiones/conexiones2.asp"
			.Actualizar()
		endwith
	endwith
endfunc


