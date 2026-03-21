**********************************************************************
Define Class zTestChequeoDeDatosBasicos As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestChequeoDeDatosBasicos Of zTestChequeoDeDatosBasicos.prg
	#Endif

	*---------------------------------
	Function zTestU_ChequeoDeConfiguracionBasica_DisImp
		local lcDirectorio as String
		
		lcDirectorio = 	addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) )
		lcDirectorio = lcDirectorio + "ConfiguracionBasica\especifico\Nucleo"
		
		use in select( "DisImp")

		try
			select 0
			use ( addbs( lcDirectorio ) + "DisImp.dbf" ) shared
			
			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en bloqreg", .t., bloqreg )
			
			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo", "ALEMANIA", alltrim( cCod ) )
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en bloqreg", .t., bloqreg )
		finally
			use in select( "DisImp")
		endtry
	Endfunc

	*---------------------------------
	Function zTestU_ChequeoDeConfiguracionBasica_DisImp_cObs
		local lcDirectorio as String
		
		lcDirectorio = 	addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) )
		lcDirectorio = lcDirectorio + "ConfiguracionBasica\especifico\Nucleo"
		
		use in select( "DisImp_cobs")

		try
			select 0
			use ( addbs( lcDirectorio ) + "DisImp_cobs.dbf" ) shared
			
			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en bloqreg", .t., bloqreg )
			
			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en bloqreg", .t., bloqreg )

			skip
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en bloqreg", .t., bloqreg )
		finally
			use in select( "DisImp_cobs")
		endtry
	Endfunc

	*---------------------------------
	Function zTestU_ChequeoDeConfiguracionBasica_DisImpo
		local lcDirectorio as String
		
		lcDirectorio = 	addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) )
		lcDirectorio = lcDirectorio + "ConfiguracionBasica\especifico\Nucleo"
		
		use in select( "DisImpo")

		try
			select 0
			use ( addbs( lcDirectorio ) + "DatosBasicos\DisImpo.dbf" ) shared

			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo", "URUGUAY", alltrim( cCod ) )

			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )

			skip
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en codigo", "PERU", alltrim( cCod ) )

			skip
			this.AssertEquals( "El 4to registro de la configuracion basica es incorrecto. Error en codigo", "ALEMANIA", alltrim( cCod ) )
		finally
			use in select( "DisImpo")
		endtry
	Endfunc

	*---------------------------------
	Function zTestU_ChequeoDeConfiguracionBasica_DisImpo_cObs
		local lcDirectorio as String
		
		lcDirectorio = 	addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) )
		lcDirectorio = lcDirectorio + "ConfiguracionBasica\especifico\Nucleo"
		
		use in select( "DisImpo_obs")

		try
			select 0
			use ( addbs( lcDirectorio ) + "DatosBasicos\DisImpo_cobs.dbf" ) shared

			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )

			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo", "ARGENTINA", alltrim( cCod ) )

			skip
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en codigo", "URUGUAY", alltrim( cCod ) )

		finally
			use in select( "DisImpo_cobs")
		endtry
	Endfunc

	*---------------------------------
	Function zTestU_ChequeoDeConfiguracionBasicaInsertadaEnLaSucursal_DisImp
		local lcDirectorio as String, lcTabla as string

		lcDirectorio = 	addbs( _Screen.zoo.crutainicial ) + "paises\dbf"
		lcTabla = "DisImp"
		goServicios.Datos.Ejecutarsentencias( "delete from " + lcTabla, lcTabla, lcDirectorio, "", set("Datasession") )

		EjecutarScriptsDeDatosBasicos()
		
		use in select( "DisImp")
		use in select( "c_DisImp")

		try
			goServicios.Datos.Ejecutarsentencias( "select * from " + lcTabla + " order by cCod", lcTabla, lcDirectorio, "c_" + lcTabla, set("Datasession") )
			select ( "c_" + lcTabla )
			
			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ALEMANIA", alltrim( cCod ) )
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en bloqreg (" + lcTabla + ")", .t., bloqreg )
			
			if ( goServicios.Datos.EsSqlServer() )
				this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "", alltrim( cObs ) )
			else
				this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en cObs(" + lcTabla + ")", "", alltrim( cObs ) )
			endif
			
			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en bloqreg (" + lcTabla + ")", .t., bloqreg )

			if ( goServicios.Datos.EsSqlServer() )
				this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Observacion1 Observacion2 Observacion3", alltrim( cObs ) )
			else
				this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en cObs(" + lcTabla + ")", "", alltrim( cObs ) )
			endif
		finally
			use in select( "DisImp")
			use in select( "c_DisImp")
		endtry
	Endfunc

	*---------------------------------
	Function zTestNativaU_ChequeoDeConfiguracionBasicaInsertadaEnLaSucursal_DisImp_cObs
		local lcDirectorio as String, lcTabla as string
		
		lcDirectorio = 	addbs( _Screen.zoo.crutainicial ) + "paises\dbf"
		lcTabla = "DisImp_cobs"
		goServicios.Datos.Ejecutarsentencias( "delete from " + lcTabla, lcTabla, lcDirectorio, "", set("Datasession") )

		EjecutarScriptsDeDatosBasicos()

		use in select( "DisImp_cObs")
		use in select( "c_DisImp_cobs")

		try
			goServicios.Datos.Ejecutarsentencias( "select * from " + lcTabla + " order by cCod", lcTabla, lcDirectorio, "c_" + lcTabla, set("Datasession") )
			select ( "c_" + lcTabla )
			
			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en bloqreg (" + lcTabla + ")", .t., bloqreg )
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Observacion1", alltrim( texto ) )
			
			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en bloqreg (" + lcTabla + ")", .t., bloqreg )
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Observacion2", alltrim( texto ) )

			skip
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en bloqreg (" + lcTabla + ")", .t., bloqreg )
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Observacion3", alltrim( texto ) )
		finally
			use in select( "DisImp_cobs")
			use in select( "c_DisImp_cobs")
		endtry
	Endfunc

	*---------------------------------
	Function zTestU_ChequeoDeConfiguracionBasicaInsertadaEnLaSucursal_DisImpo
		local lcDirectorio as String, lcTabla as string

		lcDirectorio = 	addbs( _Screen.zoo.crutainicial )
		lcDirectorio = 	left( lcDirectorio, len( lcDirectorio ) - 1 )
		lcTabla = "DisImpo"

		goServicios.Datos.Ejecutarsentencias( "delete from " + lcTabla, lcTabla, lcDirectorio, "", set("Datasession") )

		EjecutarScriptsDeDatosBasicos()

		use in select( "DisImpo")
		use in select( "c_DisImpo")

		try
			goServicios.Datos.Ejecutarsentencias( "select * from " + lcTabla + " order by cCod", lcTabla, lcDirectorio, "c_" + lcTabla, set("Datasession") )
			select ( "c_" + lcTabla )

			go top
			this.AssertEquals( "El 4to registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ALEMANIA", alltrim( cCod ) )

			if ( goServicios.Datos.EsSqlServer() )
				this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "", alltrim( cObs ) )
			else
				this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en cObs(" + lcTabla + ")", "", alltrim( cObs ) )
			endif

			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )

			if ( goServicios.Datos.EsSqlServer() )
				this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "ObservacionLa segunda parte", alltrim( cObs ) )
			else
				this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en cObs(" + lcTabla + ")", "", alltrim( cObs ) )
			endif

			skip
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "PERU", alltrim( cCod ) )

			if ( goServicios.Datos.EsSqlServer() )
				this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "", alltrim( cObs ) )
			else
				this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en cObs(" + lcTabla + ")", "", alltrim( cObs ) )
			endif

			skip
			this.AssertEquals( "El 4to registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "URUGUAY", alltrim( cCod ) )

			if ( goServicios.Datos.EsSqlServer() )
				this.AssertEquals( "El 4to registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Otra", alltrim( cObs ) )
			else
				this.AssertEquals( "El 4to registro de la configuracion basica es incorrecto. Error en cObs(" + lcTabla + ")", "", alltrim( cObs ) )
			endif
		finally
			use in select( "DisImpo")
			use in select( "c_DisImpo")
		endtry
	Endfunc

	*---------------------------------
	Function zTestNativaU_ChequeoDeConfiguracionBasicaInsertadaEnLaSucursal_DisImpo_cObs
		local lcDirectorio as String, lcTabla as string
		
		lcDirectorio = 	addbs( _Screen.zoo.crutainicial )
		lcDirectorio = 	left( lcDirectorio, len( lcDirectorio ) - 1 )
		lcTabla = "DisImpo_cobs"
		
		goServicios.Datos.Ejecutarsentencias( "delete from " + lcTabla, lcTabla, lcDirectorio, "", set("Datasession") )
		EjecutarScriptsDeDatosBasicos()

		use in select( "DisImpo_cobs")
		use in select( "c_DisImpo_cobs")

		try
			goServicios.Datos.Ejecutarsentencias( "select * from " + lcTabla + " order by cCod", lcTabla, lcDirectorio, "c_" + lcTabla, set("Datasession") )
			select ( "c_" + lcTabla )

			go top
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 1er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Observacion", alltrim( texto ) )

			skip
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "ARGENTINA", alltrim( cCod ) )
			this.AssertEquals( "El 2do registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "La segunda parte", alltrim( texto ) )

			skip
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en codigo (" + lcTabla + ")", "URUGUAY", alltrim( cCod ) )
			this.AssertEquals( "El 3er registro de la configuracion basica es incorrecto. Error en cObs (" + lcTabla + ")", "Otra", alltrim( texto ) )

		finally
			use in select( "DisImpo_cobs")
			use in select( "c_DisImpo_cobs")
		endtry
	Endfunc
Enddefine

*-----------------------------------------------------------------------------------------
function EjecutarScriptsDeDatosBasicos() 
	local loEjecutadorScripts as Object, lcXmlEstructuraAdn as string, loEstructuraAdn as Object, loManager as managertaspein of managertaspein.prg

	local lcRuta as String
	
	lcRuta = _screen.zoo.ObtenerRutaTemporal( .t. )

	copy file ( addbs( _screen.zoo.cRutaInicial ) + "generados\dat_DisI*.*" ) to ( addbs( lcRuta ) + "dat_DisI*.*" )
	copy file ( addbs( _screen.zoo.cRutaInicial ) + "generados\Din_estructuraAdn.prg" ) to ( addbs( lcRuta ) + "Din_estructuraAdn.prg" )
	if adir( laXML, addbs( _screen.zoo.cRutaInicial ) + "generados\Din_ADN*.xml") > 0
		copy file ( addbs( _screen.zoo.cRutaInicial ) + "generados\Din_ADN*.xml" ) to ( addbs( lcRuta ) + "Din_ADN*.xml" )
	endif

	EjecutarScriptsDeDatosBasicosAux( lcRuta )
endfunc 


*-----------------------------------------------------------------------------------------
function EjecutarScriptsDeDatosBasicosAux( tcRutaGenerados as String ) as Void
	local loEjecutadorScripts as Object, lcXmlEstructuraAdn as string, loEstructuraAdn as Object

	tcRutaGenerados = addbs( tcRutaGenerados )
	loEstructuraAdn = _screen.zoo.crearObjeto( "Din_estructuraAdn", tcRutaGenerados + "Din_estructuraAdn.prg" )
	if goDatos.esNativa()
		lcXmlEstructuraAdn = loEstructuraAdn.ObtenerNativa()
	else
		lcXmlEstructuraAdn = loEstructuraAdn.ObtenerSqlServer()
	endif
	loEstructuraAdn.Release()

	loEjecutadorScripts = _screen.zoo.crearobjeto( "ZooLogicSA.EjecutadorDeScripts.Ejecutador", "", _screen.zoo.app.TipoDeBase )
	with loEjecutadorScripts
		.esNativa = goDatos.esNativa()
		if !goDatos.esNativa()
			.CadenaDeConexion = goDatos.oManagerConexionASql.ObtenerCadenaConexionNet()
		endif
		EjecutarScriptsZooLogicMaster( tcRutaGenerados, lcXmlEstructuraAdn, loEjecutadorScripts, "ORGANIZACION" )
		EjecutarScriptsZooLogicMaster( tcRutaGenerados, lcXmlEstructuraAdn, loEjecutadorScripts, "PUESTO" )
		EjecutarScriptsTodasLasSucursales( tcRutaGenerados, lcXmlEstructuraAdn, loEjecutadorScripts )
	endwith		
endfunc 

*-----------------------------------------------------------------------------------------
function EjecutarScriptsZooLogicMaster( tcRutaGenerados as String, tcXmlEstructuraAdn as String, toEjecutadorScripts as Object, tcUbicacion as String ) as Void
	toEjecutadorScripts.BaseDeDatos = _screen.zoo.app.cBdMaster
	if goDatos.esNativa()
		with _screen.zoo.app
			toEjecutadorScripts.BaseDeDatos = iif( tcUbicacion = "PUESTO", .cRutaTablasPuesto, .cRutaTablasOrganizacion )
		endwith
	endif
	toEjecutadorScripts.EjecutarScripts( tcRutaGenerados, "sdb", tcXmlEstructuraAdn, tcUbicacion )
	toEjecutadorScripts.EjecutarScripts( tcRutaGenerados, "szl", tcXmlEstructuraAdn, tcUbicacion )
endfunc 

*-----------------------------------------------------------------------------------------
function EjecutarScriptsTodasLasSucursales( tcRutaGenerados as String, tcXmlEstructuraAdn as String, toEjecutadorScripts as Object ) as Void
	local lnCantSuc as Integer, i as Integer, lcSucursal as String
	
	lnCantSuc = Alen( _Screen.Zoo.App.aSucursales, 1 )

	For i = 1 To lnCantSuc
		lcSucursal = Alltrim( _Screen.Zoo.App.aSucursales[ i, 1 ] )
		if goDatos.esNativa()
			lcSucursal = addbs( _Screen.Zoo.App.ObtenerRutaSucursal( lcSucursal ) ) + "dbf\"
		endif
		toEjecutadorScripts.BaseDeDatos = lcSucursal
		toEjecutadorScripts.EjecutarScripts( tcRutaGenerados, "sdb", tcXmlEstructuraAdn, "SUCURSAL" )
		toEjecutadorScripts.EjecutarScripts( tcRutaGenerados, "szl", tcXmlEstructuraAdn, "SUCURSAL" )
	endfor
endfunc 
