**********************************************************************
Define Class ztestEntidadBaseDeDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestEntidadBaseDeDatos of ztestEntidadBaseDeDatos.prg
	#ENDIF

	*---------------------------------
	Function Setup
		
	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestNativa_UDesgloseRutaCompletaEnUnidadYRuta
		local loEnt as entidad OF entidad.prg 
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		
		loEnt.RutaCompleta = "c:\pepe\pepa"
		
		this.Assertequals( "Error en la carga de la unidad", "c", loEnt.unidad )
		this.Assertequals( "Error en la carga de la ruta", "\pepe\pepa\", loEnt.ruta )
		
		loEnt.Release()
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function zTestNativaU_CargarRutaCompletaAlNavegar
			
		*Arrange (Preparar)
		local loEnt as entidad OF entidad.prg 

		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )

		*Act (Actuar)
		*Todos los productos tienen al menos una base de datos
		loEnt.Siguiente()

		*Assert (Afirmar)
		this.Assertequals( "No cargo la rutaCompleta", alltrim(loEnt.unidad) + ":" + alltrim(loEnt.ruta), alltrim(loEnt.RutaCompleta) )
		
		loEnt.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestSqlServer_CargarRutaCompletaAlNavegar
			
		*Arrange (Preparar)
		local loEnt as entidad OF entidad.prg 
		
		_screen.mocks.agregarmock( "ColaboradorParametros" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'ObtenerparametrodeBaseDeDatos', "", "[*COMODIN],[*COMODIN]" )

		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )

		*Act (Actuar)
		*Todos los productos tienen al menos una base de datos
		loEnt.Siguiente()

		*Assert (Afirmar)
		this.Assertequals( "No tendria que tener nada que cargar en rutacompleta", "", alltrim(loEnt.RutaCompleta) )
		
		loEnt.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestNativaControlRutaCompletaVacia
		*Arrange (Preparar)
		local loEnt as entidad OF entidad.prg, loInfo as zooinformacion of zooInformacion.prg
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		
		*Act (Actuar)
		loEnt.ValidacionBasica()
		*Assert (Afirmar)
		*Espero el error del campo obligatorio vacio
		this.asserttrue( "El atributo rutacompleta tiene que estar habilitado", loEnt.lHabilitarRutaCompleta )
		
		loInfo = loEnt.ObtenerInformacion()
		this.assertequals( "El error no es el esperado", "Debe cargar el campo Ruta", loInfo.Item(1).cMensaje )
		
		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestNativaControlRutaCompletaLlena
		*Arrange (Preparar)
		local loEnt as entidad OF entidad.prg, loInfo as zooinformacion of zooInformacion.prg
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		
		*Act (Actuar)
		loEnt.RutaCompleta = _Screen.zoo.obtenerRutaTemporal()
		loEnt.ValidacionBasica()
		*Assert (Afirmar)
		*Espero el error del campo obligatorio vacio
		this.asserttrue( "El atributo rutacompleta tiene que estar habilitado", loEnt.lHabilitarRutaCompleta )

		loInfo = loEnt.ObtenerInformacion()

		this.assertequals( "Espero solo los errores de codigo vacio y de origen vacio", 2, loInfo.Count )
	
		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestSqlServerControlRutaCompletaVacia
		*Arrange (Preparar)
		local loEnt as entidad OF entidad.prg, loInfo as zooinformacion of zooInformacion.prg
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		
		*Act (Actuar)
		loEnt.ValidacionBasica()
		*Assert (Afirmar)
		this.asserttrue( "El atributo rutacompleta tiene que estar deshabilitado", !loEnt.lHabilitarRutaCompleta )
		*Espero el error del campo obligatorio vacio
		loInfo = loEnt.ObtenerInformacion()
		this.assertequals( "Solo espero los errores de codigo y origen vacios", 2, loInfo.Count )
				
		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestSqlServerControlRutaCompletaLlena
		*Arrange (Preparar)
		local loEnt as entidad OF entidad.prg, loInfo as zooinformacion of zooInformacion.prg
		*Act (Actuar)
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		*Assert (Afirmar)
		this.asserttrue( "El atributo rutacompleta tiene que estar deshabilitado", !loEnt.lHabilitarRutaCompleta )
	
		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNativaModificacion
		local loEnt as entidad OF entidad.prg 

		This.Agregarmocks( "OrigenDeDatos" )
		_screen.mocks.agregarmock( "ColaboradorParametros" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Sucursal],[PAISES  ]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Codigo Origen De Sucursal],[PAISES  ]" )

		loEnt = _Screen.zoo.instanciarentidad( "Basededatos" )

		loEnt.Ultimo()
		loEnt.BloquearRegistro = .F.
		loEnt.Modificar()
		
		this.Asserttrue( "No se tiene que poder modificar la ruta", !loEnt.lHabilitarRutaCompleta )
		this.Asserttrue( "No se tiene que poder modificar el origen", !loEnt.lHabilitarOrigenDestino_pk )		

		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "PAISES  ", "[Codigo Origen De Sucursal],[PAISES  ]" )

		loEnt.Cancelar()
		loEnt.Release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestCargarPreferente
		
		local loEnt as entidad OF entidad.prg , lcCodigo as String 

		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )

		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		
		loEnt.Ultimo()
		loEnt.BloquearRegistro = .F.
		loEnt.Modificar()
			
		lcCodigo = loEnt.codigo

		goParametros.Nucleo.OrigenDeDatosPreferente = lcCodigo
		loEnt.SetearSucPreferente()
		this.asserttrue( "La suc. es preferente", loEnt.Preferente )
		
		goParametros.Nucleo.OrigenDeDatosPreferente = "SASAZA"
		loEnt.SetearSucPreferente( )
		this.asserttrue( "La suc. NO es preferente", !loEnt.Preferente )
		
		loEnt.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestInicializar
		local loEnt as entidad OF entidad.prg, lParametrosAnterior as Boolean &&, lcServidor as string		
		
		lParametrosAnterior = goParametros.nucleo.permiteCodigosEnMinusculas

		goParametros.nucleo.permiteCodigosEnMinusculas = .t.
	
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )
		
		this.assertTrue( "El valor de la propiedad Permite Minusculas no es el esperado.", !loEnt.lPermiteMinusculasPk )
		
		loEnt.release()

		goParametros.nucleo.permiteCodigosEnMinusculas = lParametrosAnterior
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestInicializarConServidorLinux
		local loEnt as entidad OF entidad.prg
		
		loEnt = newobject( "Fake_basededatos" )
						
		this.assertTrue( "No debería estar habilitado el campo lHabilitarRutaBackup", !loEnt.lHabilitarRutaBackup )
		
		loEnt.release()

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestNuevoConServidorLinux
		local loEnt as entidad OF entidad.prg
		
		loEnt = newobject( "Fake_basededatos" )
		loEnt.Nuevo()

		this.assertequals("El valor del campo rutabackup no es el esperado", loEnt.RutaBackup, loEnt.GetcDefaultRutaBackup() )
		this.assertTrue( "No debería estar habilitado el campo lHabilitarRutaBackup", !loEnt.lHabilitarRutaBackup )

		loEnt.Cancelar()
		loEnt.release()

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestModificacionServidorLinux
		local loEnt as entidad OF entidad.prg 

		This.Agregarmocks( "OrigenDeDatos" )
		_screen.mocks.agregarmock( "ColaboradorParametros" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Sucursal],[PAISES  ]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Codigo Origen De Sucursal],[PAISES  ]" )

		loEnt = newobject( "Fake_basededatos" )
		loEnt.Ultimo()
		loEnt.Modificar()

		this.assertTrue( "No debería estar habilitado el campo lHabilitarRutaBackup", !loEnt.lHabilitarRutaBackup )		

		loEnt.Cancelar()
		loEnt.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestGuardarComoConServidorLinux
		local loEnt as entidad OF entidad.prg
		
		loEnt = newobject( "Fake_basededatos" )

		loEnt.GuardarComo()

		this.assertTrue( "No debería estar habilitado el campo lHabilitarRutaBackup", !loEnt.lHabilitarRutaBackup )

		loEnt.release()

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabar
		local loEnt as entidad OF entidad.prg , lcServidor as string
		
		private poTestDespuesDeGrabar as TestParametrosOrganicDTOBindeo of ztestEntidadBaseDeDatos.prg

		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )
		
		poTestDespuesDeGrabar = _screen.zoo.crearobjeto( "TestParametrosOrganicDTOBindeo", "ztestEntidadBaseDeDatos.prg" )
		
		_screen.mocks.Agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "TestParametrosOrganicDTO", this.Class + ".prg" )
		

		loEnt = newobject( "BaseDeDatos_Test" )
		loEnt.lDeclararSitio = .F.
		lcServidor = upper( _screen.zoo.app.cNombreDelServidorSQL )
		
		loEnt.nuevo()
		loEnt.Codigo = "PEPELEPU"
		loEnt.Unidad = "C"
		loEnt.ruta = "producto"
		loEnt.Preferente = .T.
		loEnt.InformaStock = .F.

		loEnt.lBaseDeDatosGenerada = .t.

		loEnt.DespuesDeGrabar()
		this.Assertequals( "Error en el parametro de la suc. preferente", "PEPELEPU", goParametros.Nucleo.OrigenDeDatosPreferente )

		this.assertTrue( "No paso por la configuracion de consultas interlocales", poTestDespuesDeGrabar.lPaso )
		this.assertequals( "Error en los datos de configuracion de consultas interlocales (1)", _Screen.zoo.cRutaInicial, poTestDespuesDeGrabar.cRuta )
		this.assertTrue( "Error en los datos de configuracion de consultas interlocales (2)", !poTestDespuesDeGrabar.lInformaStock )
		this.assertequals( "Error en los datos de configuracion de consultas interlocales (3)", "PEPELEPU", poTestDespuesDeGrabar.cBase )
		
		if goServicios.Datos.EsNativa()
			this.assertequals( "Error en los datos de configuracion de consultas interlocales (4)", ;
				addbs( upper( _Screen.zoo.cRutaInicial ) ) + "PEPELEPU\DBF", upper( poTestDespuesDeGrabar.cConexion ) )
		else
			**** Se hace asi para verificar el string de conexion debido a que varia por PC y tipo de seguridad
			this.assertTrue( "Error en los datos de configuracion de consultas interlocales (4.1)", ;
				"DATA SOURCE=" + lcServidor $ upper( poTestDespuesDeGrabar.cConexion ) )

			this.assertTrue( "Error en los datos de configuracion de consultas interlocales (4.2)", ;
				"INITIAL CATALOG=NUCLEO_" $ upper( poTestDespuesDeGrabar.cConexion ) )

			this.assertequals( "Error en los datos de configuracion de consultas interlocales (4.3)", ;
				"PEPELEPU" , right( upper( poTestDespuesDeGrabar.cConexion ), 8 ) )
		endif
			
		goParametros.Nucleo.OrigenDeDatosPreferente = "SARAZA"
		loEnt.Preferente = .F.
		loEnt.InformaStock = .T.

		loEnt.DespuesDeGrabar()
		this.Assertequals( "Error en el parametro de la suc. preferente", "SARAZA", goParametros.Nucleo.OrigenDeDatosPreferente )

		this.assertTrue( "No paso por la configuracion de consultas interlocales", poTestDespuesDeGrabar.lPaso )
		this.assertequals( "Error en los datos de configuracion de consultas interlocales (1)", _Screen.zoo.cRutaInicial, poTestDespuesDeGrabar.cRuta )
		this.assertTrue( "Error en los datos de configuracion de consultas interlocales (2)", poTestDespuesDeGrabar.lInformaStock )
		this.assertequals( "Error en los datos de configuracion de consultas interlocales (3)", "PEPELEPU", poTestDespuesDeGrabar.cBase )
		
		if goServicios.Datos.EsNativa()
			this.assertequals( "Error en los datos de configuracion de consultas interlocales (4)", ;
				addbs( upper( _Screen.zoo.cRutaInicial ) ) + "PEPELEPU\DBF", upper( poTestDespuesDeGrabar.cConexion ) )
		else
			**** Se hace asi para verificar el string de conexion debido a que varia por PC y tipo de seguridad
			this.assertTrue( "Error en los datos de configuracion de consultas interlocales (4.1)", ;
				"DATA SOURCE=" + lcServidor $ upper( poTestDespuesDeGrabar.cConexion ) )

			this.assertTrue( "Error en los datos de configuracion de consultas interlocales (4.2)", ;
				"INITIAL CATALOG=NUCLEO_" $ upper( poTestDespuesDeGrabar.cConexion ) )

			this.assertequals( "Error en los datos de configuracion de consultas interlocales (4.3)", ;
				"PEPELEPU" , right( upper( poTestDespuesDeGrabar.cConexion ), 8 ) )

		endif
		
		loEnt.lNuevo = .T.
		loEnt.cancelar()		
		loEnt.Release()
		loMockAD = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabarNuevo_NuevaDB
		local loEnt as entidad OF entidad.prg, loApp as Object, loSeguridad as Object, loPar1 as Object,;
			loPar2 as Object, loPar3 as Object, loPar4 as Object, lcCodigo as String, lcRuta as String, lnColor as Integer,;
			loOrigen as entidad OF entidad.prg, loError as zooexception OF zooexception.prg
			

		this.agregarmocks( "OrigenDeDatos,GestorBaseDeDatos" )
		_screen.mocks.Agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "TestParametrosOrganicDTO", this.Class + ".prg" )
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )

		lcCodigo = padr(alltrim( _Screen.zoo.app.csucursalActiva ), 8, " ")
		lcRuta = addbs(_Screen.zoo.app.obtenerrutasucursal( _Screen.zoo.app.csucursalActiva ))
		lcRuta = left(lcRuta, len(lcRuta) - 1 )
		lnColor = 156

		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarexistenciabdeliminada', .f., '"*COMODIN"' )
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Generarbasededatos', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Listarbdsarchivadas', newobject( "Collection" ) , "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[Se ha generado la Base de Datos " + alltrim(upper(lcCodigo)) + ".]" )

		loSeguridad = newobject( "mockSeguridad" )			

		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )

		loent.oSeguridad = loSeguridad
		loEnt.lDeclararSitio = .F.
		loEnt.Codigo = alltrim(upper(lcCodigo))
		if goServicios.Datos.EsNativa()
			loEnt.RutaCompleta = _screen.zoo.cRutaInicial
		endif
		loEnt.OrigenDestino_pk = lcCodigo
		loEnt.Color = lnColor
				
		loEnt.lNuevo = .T.
		loEnt.DespuesDeGrabar()

		loEnt.release()	

		*Controlo las llamadas contra seguridad
		this.Assertequals( "Error en el parametro 1 de AgregarBaseDeDatos", alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueadoParaLogin() ), loSeguridad.parAgregarBaseDeDatos1 )
		this.Assertequals( "Error en el parametro 2 de AgregarBaseDeDatos", upper(alltrim(lcCodigo)), loSeguridad.parAgregarBaseDeDatos2 )
		this.Asserttrue( "No paso po rel refrescar", loSeguridad.pasoPorRefrescarMenuYBarraDelFormularioPrincipal )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabarNuevo_DBRestaurada
		local loEnt as entidad OF entidad.prg, loApp as Object, loSeguridad as Object, loPar1 as Object,;
			loPar2 as Object, loPar3 as Object, loPar4 as Object, lcCodigo as String, lcRuta as String, lnColor as Integer,;
			loOrigen as entidad OF entidad.prg

		this.agregarmocks( "OrigenDeDatos,GestorBaseDeDatos" )
		_screen.mocks.Agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "TestParametrosOrganicDTO", this.Class + ".prg" )
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )

		lcCodigo = padr(alltrim( _Screen.zoo.app.csucursalActiva ), 8, " ")
		lcRuta = addbs(_Screen.zoo.app.obtenerrutasucursal( _Screen.zoo.app.csucursalActiva ))
		lcRuta = left(lcRuta, len(lcRuta) - 1 )
		lnColor = 156
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarexistenciabdeliminada', .t., '"*COMODIN"' )
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'RestaurarBaseDeDatos', .T., '"' + upper( lcCodigo ) + '"' ) 
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarsiesbdmarcadacomoreplica', .f., "[PAISES  ]" ) && ztestentidadbasededatos.ztestdespuesdegrabarnuevo_dbrestaurada 01/12/15 14:57:06
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarsiesbdmarcadacomoreplica', .F., "[PAISES  ],.F." ) && ztestentidadbasededatos.ztestdespuesdegrabarnuevo_dbrestaurada 15/11/23 15:45:10
		
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[Se ha restaurado la Base de Datos " +upper (alltrim(lcCodigo)) + ".]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Preguntar', 1, "[Se encontró una copia de la base de datos " + upper(alltrim(lcCodigo)) + ". Se procederá a restaurarla.],1" )
		
		loSeguridad = newobject( "mockSeguridad" )			
		
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )

		loent.oSeguridad = loSeguridad
		loEnt.lDeclararSitio = .F.
		loEnt.Codigo = upper( lcCodigo )
		if goServicios.Datos.EsNativa()
			loEnt.RutaCompleta = _screen.zoo.cRutaInicial
		endif
		loEnt.OrigenDestino_pk = lcCodigo
		loEnt.Color = lnColor
				
		loEnt.lNuevo = .T.
		loEnt.DespuesDeGrabar()

		loEnt.release()	

		*Controlo las llamadas contra seguridad
		this.Assertequals( "Error en el parametro 1 de AgregarBaseDeDatos", alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueadoParaLogin() ), loSeguridad.parAgregarBaseDeDatos1 )
		this.Assertequals( "Error en el parametro 2 de AgregarBaseDeDatos", upper(alltrim(lcCodigo)), loSeguridad.parAgregarBaseDeDatos2 )
		this.Asserttrue( "No paso po rel refrescar", loSeguridad.pasoPorRefrescarMenuYBarraDelFormularioPrincipal )


	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabarNuevo_DBRestauradaNoRecuperada
		local loEnt as entidad OF entidad.prg, loApp as Object, loSeguridad as Object, loPar1 as Object,;
			loPar2 as Object, loPar3 as Object, loPar4 as Object, lcCodigo as String, lcRuta as String, lnColor as Integer,;
			loOrigen as entidad OF entidad.prg
			
		this.agregarmocks( "OrigenDeDatos,GestorBaseDeDatos" )
		_screen.mocks.Agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "TestParametrosOrganicDTO", this.Class + ".prg" )
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )

		lcCodigo = padr(alltrim( _Screen.zoo.app.csucursalActiva ), 8, " ")
		lcRuta = addbs(_Screen.zoo.app.obtenerrutasucursal( _Screen.zoo.app.csucursalActiva ))
		lcRuta = left(lcRuta, len(lcRuta) - 1 )
		lnColor = 156

		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarexistenciabdeliminada', .t., '"*COMODIN"' )
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'RestaurarBaseDeDatos', .T., '"' + upper( lcCodigo ) + '"' ) 
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarsiesbdmarcadacomoreplica', .f., "[PIRULO]" ) && ztestentidadbasededatos.ztestdespuesdegrabarnuevo_dbrestauradanorecuperada 01/12/15 17:36:16
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.]" )


		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Preguntar', 2, "[Se encontró una copia de la base de datos PIRULO. Se procederá a restaurarla.],1" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[No se pudo generar la Base de Datos.]" )

		loSeguridad = newobject( "mockSeguridad" )			
		
		loEnt = _Screen.zoo.instanciarentidad( "basededatos" )

		loent.oSeguridad = loSeguridad
		loEnt.Nuevo()
		loEnt.Codigo = "PIRULO"
		if goServicios.Datos.EsNativa()
			loEnt.RutaCompleta = _screen.zoo.cRutaInicial
		endif
		loEnt.OrigenDestino_pk = lcCodigo
		loEnt.Color = lnColor
		loEnt.Grabar()				

*		loEnt.DespuesDeGrabar()

		loEnt.release()	

		*Controlo las llamadas contra seguridad
		this.Assertequals( "Error en el parametro 1 de AgregarBaseDeDatos", "", loSeguridad.parAgregarBaseDeDatos1 )
		this.Asserttrue( "Paso po rel refrescar", !loSeguridad.pasoPorRefrescarMenuYBarraDelFormularioPrincipal )



	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEliminarDBActiva
		local loEntidad as entidad OF entidad.prg, loError as zooexception OF zooexception.prg
	
		
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		
		loEntidad.Codigo = upper(alltrim(_Screen.zoo.app.csucursalActiva))
		try
			loEntidad.Eliminar()
		catch to loError
			this.Assertequals( "El error no es el esperado", "No se puede eliminar la sucursal activa.", loError.UserValue.oInformacion.Item[1].cMensaje )
		endtry
		
		loEntidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNativaValorSugeridoRutacompleta
		local loEntidad as entidad OF entidad.prg 
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.ValorSugeridoRutaCompleta()
		this.assertequals( "En nativa tiene que tener valor default", _Screen.zoo.crutainicial, loEntidad.RutaCompleta )
		loEntidad.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSqlServerValorSugeridoRutacompleta
		local loEntidad as entidad OF entidad.prg 
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.ValorSugeridoRutaCompleta()
		this.asserttrue( "En SQL no tiene que tener valor default", empty(loEntidad.RutaCompleta ))
		loEntidad.release()		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarIngreso
		local loEntidad as entidad OF entidad.prg, llRetorno as Boolean 
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )		

		***Primer assert para asegurar que sigue haciendo el dodefault
		llRetorno = loEntidad.ValidarIngreso( "\" )
		this.asserttrue( "No tendria que soportar el \", !llRetorno )
		
		***Segundo assert con el control agregado en el ent_basededatos
		llRetorno = loEntidad.ValidarIngreso( "/" )
		this.asserttrue( "No tendria que soportar el /", !llRetorno )
		
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestCargar
		local loEntidad as entidad OF entidad.prg

		_screen.mocks.agregarmock( "ColaboradorParametros") 
		_screen.mocks.AgregarSeteoMetodoEnCola( 'COLABORADORPARAMETROS', 'ObtenerparametrodeBaseDeDatos', "CodigoSuc", "[Sucursal],[]" )		
		_screen.mocks.AgregarSeteoMetodoEnCola( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Codigo Origen De Sucursal],[]" )
		_screen.mocks.agregarmock( "AplicacionBase") 
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .t., "[]" )
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )
		
		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "Sucursal,OrigenDeDatos" )

		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )		

		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.oAplicacion = _screen.zoo.crearobjeto( "AplicacionBase" )

		loEntidad.Cargar()

		_screen.mocks.verificarejecuciondemocks( "ColaboradorParametros" )
		loentidad.release()
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestCargarBasedeDatosInexistenteConMensaje
		local loEntidad as entidad OF entidad.prg

		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "OrigenDeDatos,AplicacionBase" )
		_screen.mocks.agregarmock( "MENSAJEENTIDAD" )

		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[ La Base de Datos SUC1 no existe.]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .F., "[SUC1]" )
		
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.oAplicacion = _screen.zoo.crearobjeto( "AplicacionBase" )

		loEntidad.Codigo = "SUC1"
		loEntidad.Cargar()
		_screen.mocks.VerificarEjecucionDeMocks( "MENSAJEENTIDAD" )
		
		loentidad.release()
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestCargarBasedeDatosInaccesibleConMensaje
		local loEntidad as entidad OF entidad.prg

		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "OrigenDeDatos,AplicacionBase" )
		_screen.mocks.agregarmock( "MENSAJEENTIDAD" )
		_screen.mocks.agregarmock( "ColaboradorParametros" )
		
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Existen problemas al intentar acceder a la Base de Datos SUC1.]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .T., "[SUC1]" )		
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', .f., "[Codigo Origen De Sucursal],[SUC1]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', .f., "[Sucursal],[SUC1]" )

		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.oAplicacion = _screen.zoo.crearobjeto( "AplicacionBase" )

		loEntidad.Codigo = "SUC1"
		loEntidad.Cargar()
		_screen.mocks.VerificarEjecucionDeMocks( "MENSAJEENTIDAD" )
		
		loentidad.release()
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestNoPermitirModificarBasedeDatosInexistente
		local loEntidad as entidad OF entidad.prg, loError as Exception, loInfo as zooinformacion of zooInformacion.prg

		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "OrigenDeDatos,AplicacionBase,MENSAJEENTIDAD" )
		
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .F., "[SUC1]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[ La Base de Datos SUC1 no existe.]" )
		
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.oAplicacion = _screen.zoo.crearobjeto( "AplicacionBase" )

		loEntidad.Codigo = "SUC1"
		loEntidad.Cargar()
		try
			loEntidad.Modificar()
			this.asserttrue( "Se pudo modificar una Base de Datos inexistente", .f. )
		catch to loError
			loInfo = loError.UserValue.Obtenerinformacion()
			this.assertequals( "El mensaje de error no es el esperado.", "El registro de la entidad Base de Datos no puede ser modificado porque la Base de Datos no puede accederse.", loInfo(1).cmensaje )
		endtry
		
		loentidad.release()
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestNoPermitirModificarBasedeDatosInaccesible
		local loEntidad as entidad OF entidad.prg, loError as Exception, loInfo as zooinformacion of zooInformacion.prg

		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "OrigenDeDatos,AplicacionBase,MENSAJEENTIDAD" )
		_screen.mocks.agregarmock( "ColaboradorParametros" )

		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .t., "[SUC1]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Existen problemas al intentar acceder a la Base de Datos SUC1.]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', .f., "[Codigo Origen De Sucursal],[SUC1]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', .f., "[Sucursal],[SUC1]" )
		
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.oAplicacion = _screen.zoo.crearobjeto( "AplicacionBase" )

		loEntidad.Codigo = "SUC1"
		loEntidad.Cargar()
		try
			loEntidad.Modificar()
			this.asserttrue( "Se pudo modificar una Base de Datos inaccesible", .f. )
		catch to loError
			loInfo = loError.UserValue.Obtenerinformacion()
			this.assertequals( "El mensaje de error no es el esperado.", "El registro de la entidad Base de Datos no puede ser modificado porque la Base de Datos no puede accederse.", loInfo(1).cmensaje )
		endtry
		
		loentidad.release()
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabarVerificarEjecucionColaboradorCuandoCreaDB
		local loEntidad as entidad OF entidad.prg

		_screen.mocks.Agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "TestParametrosOrganicDTO", this.Class + ".prg" )

		_screen.mocks.agregarmock( "ColaboradorParametros" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Codigo Origen De Sucursal],[BASE1]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[Sucursal],[BASE1]" )

		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Setearparametrosaotrabasededatos', .T., "[goServicios.Parametros.Nucleo.Transferencias.CodigoOrigenDeSucursal],[BASE1],[Paises  ]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Setearparametrosaotrabasededatos', .T., "[goServicios.Parametros.Nucleo.Sucursal],[BASE1],[]" )
		
		_screen.mocks.agregarmock( "AplicacionBase") 
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .t., "[BASE1]" )
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )
		
		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "Sucursal,OrigenDeDatos,GestorBaseDeDatos" )

		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )		

		lcCodigo = padr( alltrim( _Screen.zoo.app.csucursalActiva ), 8, " ")
		lcRuta = addbs(_Screen.zoo.app.obtenerrutasucursal( _Screen.zoo.app.csucursalActiva ) )
		lcRuta = left(lcRuta, len( lcRuta ) - 1 )
		lnColor = 156
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Verificarexistenciabdeliminada', .f., '"*COMODIN"' )
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'GenerarBaseDeDatos', .t. ) 
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Listarbdsarchivadas', newobject( "Collection" ) , "[*COMODIN]" )

		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[Se ha generado la Base de Datos BASE1.]" )

		loSeguridad = newobject( "mockSeguridad" )
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )

		loEntidad.oSeguridad = loSeguridad
		loEntidad.oAplicacion = _screen.zoo.crearobjeto( "AplicacionBase" )
		loEntidad.lDeclararSitio = .F.
		loEntidad.Codigo = "BASE1"
		if goServicios.Datos.EsNativa()
			loEntidad.RutaCompleta = _screen.zoo.cRutaInicial
		endif
		loEntidad.OrigenDestino_pk = lcCodigo
		loEntidad.Color = lnColor
				
		loEntidad.lNuevo = .T.

		loEntidad.DespuesDeGrabar()
		This.asserttrue( "La base de datos fue Generada." , loEntidad.lbaseDeDatosGenerada )
		_screen.mocks.verificarejecuciondemocks( "ColaboradorParametros" )
		
		loEntidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabarVerificarEjecucionMetodoCambiarColorBarraEstado
		local loEntidadTest as Object

		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )

		loEntidadTest = _Screen.zoo.crearobjeto( "BaseDeDatos_Test", "ztestentidadbasededatos.prg" )
		loEntidadTest.lNuevo = .t.
		loEntidadTest.lBaseDeDatosGenerada = .t.
		loEntidadTest.lDeclararSitio = .F.
		loEntidadTest.DespuesDeGrabar()

		This.asserttrue( "No paso por el método CambiarColorBarraEstado." , loEntidadTest.lPasoPorMetodoCambiarColorBarraEstado )

		loEntidadTest.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabarVerificarNoEjecucionColaboradorCuandoNoCreaDB
		local loEntidad as entidad OF entidad.prg

		_screen.mocks.Agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "TestParametrosOrganicDTO", this.Class + ".prg" )
	
		_screen.mocks.agregarmock( "ColaboradorParametros" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "", "[*COMODIN],[*COMODIN]" )
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )

		This.MockearAccesoDatos( "BaseDeDatos" )
		This.Agregarmocks( "Sucursal,OrigenDeDatos,GestorBaseDeDatos" )

		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad', 'Eliminar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Basededatosad_SqlServer', 'Eliminar', .T. )


		lcCodigo = padr(alltrim( _Screen.zoo.app.csucursalActiva ), 8, " ")
		lcRuta = addbs(_Screen.zoo.app.obtenerrutasucursal( _Screen.zoo.app.csucursalActiva ) )
		lcRuta = left(lcRuta, len( lcRuta ) - 1 )
		lnColor = 156
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'VerificarExistenciaBDEliminada', .f., '"*COMODIN"' )
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'GenerarBaseDeDatos', .f. ) 
		_screen.mocks.AgregarSeteoMetodo( 'GESTORBASEDEDATOS', 'Listarbdsarchivadas', newobject( "Collection" ) , "[*COMODIN]" )		

		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[No se pudo generar la Base de Datos.]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Informar', .T., "[Se ha generado la Base de Datos " + alltrim(upper(lcCodigo)) + ".]" )

		loSeguridad = newobject( "mockSeguridad" )
		
		loEntidad = _Screen.zoo.instanciarentidad( "basededatos" )
		loEntidad.oSeguridad = loSeguridad
		loEntidad.lDeclararSitio = .F.
		loEntidad.Codigo = alltrim( upper( lcCodigo ) )
		if goServicios.Datos.EsNativa()
			loEntidad.RutaCompleta = _screen.zoo.cRutaInicial
		endif
		loEntidad.OrigenDestino_pk = lcCodigo
		loEntidad.Color = lnColor
				
		loEntidad.lNuevo = .T.

		loEntidad.DespuesDeGrabar()
		This.asserttrue( "La base de datos no fue Generada." , !loEntidad.lbaseDeDatosGenerada )
		_screen.mocks.verificarejecuciondemocks( "ColaboradorParametros" )
		
	endfunc 

	*---------------------------------
	Function zTestSetearGuid
		local loEnt as Ent_RegistroDeMantenimiento of Ent_RegistroDeMantenimiento.prg, lcContenido as string, lcArchivo as string

		this.agregarmocks( "OrigenDeDatos,GestorBaseDeDatos,Sucursal" )
		_screen.mocks.agregarmock( "WrapperInformacionBaseDeDatos", "TestWrapperInformacionBaseDeDatos", this.Class + ".prg" )

		_Screen.Mocks.AgregarMock( "ColaboradorParametros" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', [Origen], "[Codigo Origen De Sucursal],[Codigo]" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPARAMETROS', 'Obtenerparametrodebasededatos', "Codigo", "[Sucursal],[Codigo]" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Existen problemas al intentar acceder a la Base de Datos CODIGO.]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[ La Base de Datos CODIGO no existe.]" ) 		
		
		if goServicios.Datos.Esnativa()
			_Screen.Mocks.AgregarMock( "BasedeDatosAD", "AccesoDatosParaTest", this.Class + ".prg" )
		else
			_Screen.Mocks.AgregarMock( "BasedeDatosAD_SQLSERVER", "AccesoDatosParaTest", this.Class + ".prg" )
		endif
		loEnt = _screen.zoo.InstanciarEntidad( "BaseDeDatos" )
		loEnt.Codigo = "Codigo"
		loEnt.Replica = .t.

		loEnt.SetearGuid( "guid" )
		
		lcArchivo = addbs( _Screen.zoo.ObtenerRutaTemporal() ) + "TestWrapperInformacionBaseDeDatosData.txt"
		this.asserttrue( "Debe existir el archivo donde loguea el wrapper que seteo el guid", file( lcArchivo ) )		

		lcContenido = filetostr( lcArchivo )
		this.assertequals( "No se seteo correctamente el archivo", "IDBaseDeDatos = guid", lcContenido )
		
		delete file ( lcArchivo )

		loEnt.Replica = .f.
		this.asserttrue( "No debe setear el guid si la base no es de replica", !file( lcArchivo ) )		

		loEnt.Release()
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function zTestDespuesDeGrabar_ActualizarPropiedadesRep
		local loEnt as entidad OF entidad.prg
			
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Insertarinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )
		
		loEnt = newobject( "BaseDeDatos_Test" )
		loEnt.lNuevo = .t.
		loEnt.lBaseDeDatosGenerada = .t.
		loEnt.lDeclararSitio = .F.
		loEnt.DespuesDeGrabar()

		loEnt.release()	
		_screen.mocks.verificarejecuciondemocks( "COLABORADORPROPIEDADESREP" )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestCargarInformacionDeBaseDeDatos_ObtenerPropiedadesRep
		local loEnt as entidad OF entidad.prg
			
		_screen.mocks.agregarmock( "ColaboradorPropiedadesRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenernombretablapropiedadesrep', "TablaRep" )
		_screen.mocks.AgregarSeteoMetodo( 'COLABORADORPROPIEDADESREP', 'Obtenerinformaciondeestadoconectadobd', .T., "'*OBJETO',[*COMODIN],[*COMODIN]" )
		
		loEnt = _Screen.zoo.InstanciarEntidad( "BaseDeDatos" )

		loEnt.CargarInformacionDeBaseDeDatos()

		loEnt.release()	
		_screen.mocks.verificarejecuciondemocks( "COLABORADORPROPIEDADESREP" )
		
	endfunc 

EndDefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class mockSeguridad as custom
	parAgregarBaseDeDatos1 = ""
	parAgregarBaseDeDatos2 = ""
	
	pasoPorRefrescarMenuYBarraDelFormularioPrincipal = .F.
	*-----------------------------------------------------------------------------------------
	function AgregarBaseDeDatos( tcPar1 as String , tcPar2 as String ) as Void
		this.parAgregarBaseDeDatos1 = tcPar1
		this.parAgregarBaseDeDatos2 = tcPar2
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarMenuYBarraDelFormularioPrincipal() as Void
		this.pasoPorRefrescarMenuYBarraDelFormularioPrincipal = .T.
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class mockApp as custom
	parVerificarExistenciaBDEliminada1 = ""
	retornoVerificarExistenciaBDEliminada = .F.

	parRestaurarBaseDeDatos1 = ""
	parRestaurarBaseDeDatos2 = ""
	parRestaurarBaseDeDatos3 = ""
	parRestaurarBaseDeDatos4 = 0
	retornoRestaurarBaseDeDatos	= .F.
	
	parGenerarBaseDeDatos1 = ""
	parGenerarBaseDeDatos2 = ""
	parGenerarBaseDeDatos3 = ""
	parGenerarBaseDeDatos4 = 0
	retornoGenerarBaseDeDatos	= .F.
	cSucursalActiva = "Paises"
		
	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaBDEliminada( tcPar1 as String ) as Boolean 
		this.parVerificarExistenciaBDEliminada1 = tcPar1
		return this.retornoVerificarExistenciaBDEliminada
	endfunc 
	*-----------------------------------------------------------------------------------------
	function RestaurarBaseDeDatos( tcPar1 as String , tcPar2 as String, tcPar3 as String, tnPar4 as Integer ) as Boolean 
		this.parRestaurarBaseDeDatos1 = tcPar1 
		this.parRestaurarBaseDeDatos2 = tcPar2
		this.parRestaurarBaseDeDatos3 = tcPar3
		this.parRestaurarBaseDeDatos4 = tnPar4 
		return this.retornoRestaurarBaseDeDatos
	endfunc 
	*-----------------------------------------------------------------------------------------
	function GenerarBaseDeDatos( tcPar1 as String , tcPar2 as String , tcPar3 as String , tnPar4 as Integer ) as Boolean 
		this.parGenerarBaseDeDatos1 = tcPar1 
		this.parGenerarBaseDeDatos2 = tcPar2
		this.parGenerarBaseDeDatos3 = tcPar3
		this.parGenerarBaseDeDatos4 = tnPar4 
		return this.retornoGenerarBaseDeDatos
	endfunc 
enddefine


define class TestParametrosOrganicDTOBindeo as  custom

	lPaso = .f.

	cRuta = ""
	lInformaStock = .f.
	cBase = ""
	cConexion =  ""

enddefine


define class TestParametrosOrganicDTO as custom
	
	*-----------------------------------------------------------------------------------------
	function Init( tcRuta, tlInformaStock, tcBase, tcConexion ) as Void
		if type( "poTestDespuesDeGrabar" ) = "O"
			poTestDespuesDeGrabar.cRuta= tcRuta
			poTestDespuesDeGrabar.lInformaStock = tlInformaStock
			poTestDespuesDeGrabar.cBase = tcBase
			poTestDespuesDeGrabar.cConexion = tcConexion 
		endif
	endfunc 

	function Configurar()
		if type( "poTestDespuesDeGrabar" ) = "O"
			poTestDespuesDeGrabar.lPaso = .t.
		endif
	endfunc

enddefine

define class TestWrapperInformacionBaseDeDatos as WrapperInformacionBaseDeDatos of WrapperInformacionBaseDeDatos.prg

	cArchivo = ""
	
	*-----------------------------------------------------------------------------------------
	function Init( tcBase as String ) as Void
		dodefault( tcBase )
		
		this.cArchivo = addbs( _Screen.zoo.ObtenerRutaTemporal() ) + "TestWrapperInformacionBaseDeDatosData.txt"
		
		if file( this.cArchivo )
			delete file ( this.cArchivo )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Obtener( tcAtributo as String )
		local lcRetorno as String
		
		lcRetorno = ""
		
		if upper( alltrim( tcAtributo ) ) == "IDBASEDEDATOS"		
			lcRetorno = "1234567890"
		endif
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear( tcIdAtributo as String, tcValor as string ) as void
		strtofile( tcIdAtributo + " = " + tcValor, this.cArchivo, 0 )
	endfunc

enddefine

define class AccesoDatosParaTest as AccesoDatosEntidad of AccesoDatosEntidad.prg

	lInserto = .f.
	
	*-----------------------------------------------------------------------------------------
	function INICIALIZAR () as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function hayDatos() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Insertar() as Void
		this.lInserto = .t.
	endfunc 


	*-----------------------------------------------------------------------------------------
	function Cargar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarPorClavePrimaria( tlLlenarAtributos as Boolean ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarPorClaveCandidata() as boolean
		return .t.
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	Function ObtenerDatosEntidad( tcAtributos As String, tcHaving As String, tcOrder As String , tcFunc As String ) As String
		return ""
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	Function ObtenerCamposSelectEntidad( tcCampos As String ) As String
		Return ""
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	Function ObtenerCampoEntidad( tcAtributo As String ) As String
		Return ""
	Endfunc
	
enddefine

*--------------------------------------------------------------------------------------------------------
define class BaseDeDatos_Test as Ent_BaseDeDatos of Ent_BaseDeDatos.prg

	lPasoPorMetodoCambiarColorBarraEstado = .F.

	*--------------------------------------------------------------------------------------------------------
	function CambiarColorBarraEstado()
		this.lPasoPorMetodoCambiarColorBarraEstado = .T.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearDB( param1, param2 ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarParametros() as Void
	endfunc 

enddefine

*--------------------------------------------------------------------------------------------------------
define class Fake_BaseDeDatos as Ent_BaseDeDatos of Ent_BaseDeDatos.prg
	
	*-----------------------------------------------------------------------------------------
	function EsServidorSQLWindows() as Boolean
		return .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GetcDefaultRutaBackup() as String
		return this.cDefaultRutaBackup
	endfunc 

enddefine