**********************************************************************
Define Class zTestConectorAgenteDeAccionesOrganic as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		local this as zTestConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
	EndFunc
	
	*---------------------------------
	Function TearDown
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loConectorAO as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
			loFactory as FakeFactoryConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg
		loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganic", "zTestConectorAgenteDeAccionesOrganic.prg" )
		loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )
		this.AssertEquals( "No instancio el conector.", "O", vartype( loConectorAO ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEnviarInstrucciones
		local loConectorAO as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
			loFactory as FakeFactoryConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg, ;
			lcRutaAplicacion as String, lcNombreExe as String, loInstruccionesOrganic as zoocoleccion OF zoocoleccion.prg, ;
			loZooLogicSAConectorDeRedesConectorWCF as Object, lcContenidoDeScript as String, lnCantLineas as integer, ;
			lcAtributo as String, lcTipoDato as String

		local loFactoryAccionOrganic as FactoryInstruccionesScript of FactoryInstruccionesScript.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg
		
		local array laLineas[1]

		loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganic", "zTestConectorAgenteDeAccionesOrganic.prg" )
		loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )
		loConectorAO.lDesarrollo = .f.
		
		lcRutaAplicacion = "c:\JhonMalkovich\"
		lcNombreExe = "JhonMalkovich"

		****** creo conjunto de instrucciones ********
		loFactoryAccionOrganic = _screen.zoo.CrearObjeto( "FactoryAccionDeAgenteOrganic" )
		loAccion = loFactoryAccionOrganic.Obtener( "EXPORTACION" )
		with loAccion
			.cNombreProducto = lcNombreExe 
			.cRutaAplicacion = lcRutaAplicacion 
			.cDescripcion = "Descripcion"
			.oParametros.Agregar( "CodigoDeExportacion", "CodigoDeExportacion" )
			.oParametros.Agregar( "AtributoFiltro", "AtributoFiltro")
			.oParametros.Agregar( "CodigoDesde", "CodigoDesde" )
			.oParametros.Agregar( "CodigoHasta", "CodigoHasta" )
			.oParametros.Agregar( "Estado", "Estado" )
			.oParametros.Agregar( "AccionTipoAntes", "AccionTipoAntes" )
			.oParametros.Agregar( "Entidad1", "Entidad" )
			.oParametros.Agregar( "DespuesDeGrabar", "Evento" )
		endwith

		lcContenidoDeScript = ObtenerContenidoDeScriptOrganic( loAccion.oInstrucciones )

		loConectorAO.EnviaInstrucciones( loAccion )

		loZooLogicSAConectorDeRedesConectorWCF = loFactory.oConectorDeRedWCF

		this.AssertEquals( "No se envio correctamente la ruta de la aplicacion.", lcRutaAplicacion, loZooLogicSAConectorDeRedesConectorWCF.cUltimaRutaAplicacion  )
		this.AssertEquals( "No se envio correctamente el nombre de la aplicacion.", lcNombreExe, loZooLogicSAConectorDeRedesConectorWCF.cUltimoNombreExe )
		this.AssertEquals( "No se envio correctamente la acción.", "Script", loZooLogicSAConectorDeRedesConectorWCF.cAccion )
		this.AssertEquals( "No se envio correctamente la descripción.", "exportando datos", loZooLogicSAConectorDeRedesConectorWCF.cDescripcion )

		lnCantLineas = alines( laLineas, loZooLogicSAConectorDeRedesConectorWCF.cUltimoScript, 5, chr( 13 ) + chr( 10 ) )
		
		this.assertequals( "La cantidad de lineas es incorrecta", 7, lnCantLineas )
		
		lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 1 )
		lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 2 ) )
		lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 3 )
		
		this.assertequals( "El atributo es erroneo (2)", "IdAplicacion", lcAtributo )
		this.assertequals( "El tipodato es erroneo (2)", "C", lcTipoDato )
		this.asserttrue( "El valor es erroneo (2)", !empty( lcValor ) )

		lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 1 )
		lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 2 ) )
		lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 3 )
		
		this.assertequals( "El atributo es erroneo (3)", "cUsuarioLogueado", lcAtributo )
		this.assertequals( "El tipodato es erroneo (3)", "C", lcTipoDato )
		this.assertequals( "El valor es erroneo (3)", "ADMIN", lcValor )

		lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 1 )
		lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 2 ) )
		lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 3 )
		
		this.assertequals( "El atributo es erroneo (4)", "cSucursalActiva", lcAtributo )
		this.assertequals( "El tipodato es erroneo (4)", "C", lcTipoDato )
		this.assertequals( "El valor es erroneo (4)", "PAISES", upper( lcValor ) )

		lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 5 ] ), "<", ">", 1 )
		lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 5 ] ), "<", ">", 2 ) )
		lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 5 ] ), "<", ">", 3 )
		
		this.assertequals( "El atributo es erroneo (5)", 'this.oAtributoAuxiliar1 = _screen.zoo.crearobjeto( "LanzadorDeExportacionEnAccionAutomatica" )', lcAtributo )
		this.assertequals( "El tipodato es erroneo (5)", "ACCION", lcTipoDato )
		this.assertequals( "El valor es erroneo (5)", "", lcValor )

		lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 6 ] ), "<", ">", 1 )
		lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 6 ] ), "<", ">", 2 ) )
		lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 6 ] ), "<", ">", 3 )
		
		this.assertequals( "El atributo es erroneo (6)", "this.oAtributoAuxiliar1.Procesar( 'CodigoDeExportacion', 'AtributoFiltro', 'CodigoDesde', 'CodigoHasta', 'Estado', AccionTipoAntes , 'Entidad1' , 'DespuesDeGrabar' )", lcAtributo )
		this.assertequals( "El tipodato es erroneo (6)", "ACCION", lcTipoDato )
		this.assertequals( "El valor es erroneo (6)", "", lcValor )
		
		lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 7 ] ), "<", ">", 1 )
		lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 7 ] ), "<", ">", 2 ) )
		lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 7 ] ), "<", ">", 3 )
		
		this.assertequals( "El atributo es erroneo (7)", "_Screen.Zoo.App.Salir()", lcAtributo )
		this.assertequals( "El tipodato es erroneo (7)", "ACCION", lcTipoDato )
		this.assertequals( "El valor es erroneo (7)", "", lcValor )
		
		loFactory = null
		loConectorAO = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestVerificarEstadoDeEjecutorDeScriptOrganic
		local loConectorAO as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
			loFactory as FakeFactoryConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg, ;
			lcRutaAplicacion as String, lcNombreExe as String, loInstruccionesOrganic as zoocoleccion OF zoocoleccion.prg, ;
			loZooLogicSAConectorDeRedesConectorWCF as Object, lcContenidoDeScript as String, lnCantLineas as integer, ;
			lcAtributo as String, lcTipoDato as String, lcValor as String, llRetorno as Boolean
		
		local array laLineas[1]
		
		_Screen.mocks.agregarmock( "Zoologicsa.ConectorDeRedes.ConfiguracionAgenteOrganic", "ConfiguracionAgenteOrganicParaTest", "zTestConectorAgenteDeAccionesOrganic.prg" )

		loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganic", "zTestConectorAgenteDeAccionesOrganic.prg" )
		loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )
		loConectorAO.lDesarrollo = .f.
		
		llRetorno = loConectorAO.EjecutaScriptOrganicPorMEdioDelGestor()
		this.AssertEquals( "No se obtuvo el estado del ejecutor de tareas organic.", .t., llRetorno )
		
		loFactory = null
		loConectorAO = null
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		function zTestObtenerDisponibilidadAAO
*!*			local loConectorAO as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
*!*				loFactory as FakeFactoryConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg, ;
*!*				lcRutaAplicacion as String, lcNombreExe as String, loInstruccionesOrganic as zoocoleccion OF zoocoleccion.prg, ;
*!*				loZooLogicSAConectorDeRedesConectorWCF as Object, lcContenidoDeScript as String, lnCantLineas as integer, ;
*!*				lcAtributo as String, lcTipoDato as String, lcValor as String, lnRetorno as Integer
*!*			
*!*			local array laLineas[1]
*!*			
*!*			_Screen.mocks.agregarmock( "Zoologicsa.ConectorDeRedes.ConfiguracionAgenteOrganic", "ConfiguracionAgenteOrganicParaTest", "zTestConectorAgenteDeAccionesOrganic.prg" )

*!*			loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganic", "zTestConectorAgenteDeAccionesOrganic.prg" )
*!*			loFactory.llLDEBELEVANTARERRORELENVIAR = .t.
*!*			loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )

*!*			loConectorAO.lDesarrollo = .t.
*!*			loConectorAO.lEsBuildAutomatico = .t.
*!*			lnRetorno = loConectorAO.ObtenerDisponibilidadAAO()
*!*			
*!*			this.AssertEquals( "La disponibilidad no es la correcta 1.", 1, lnRetorno ) &&  No esta disponible.

*!*			loConectorAO.lDesarrollo = .t.
*!*			loConectorAO.lEsBuildAutomatico = .f.
*!*			lnRetorno = loConectorAO.ObtenerDisponibilidadAAO()
*!*			this.AssertEquals( "La disponibilidad no es la correcta 1.1.", 1, lnRetorno) &&  No esta disponible.
*!*					
*!*			loConectorAO.lDesarrollo = .f.
*!*			loConectorAO.lEsBuildAutomatico = .f.		

*!*			lnRetorno = loConectorAO.ObtenerDisponibilidadAAO()
*!*			this.AssertEquals( "La disponibilidad no es la correcta 3.", 3, lnRetorno ) &&  Esta disponible.
*!*			
*!*			loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganic", "zTestConectorAgenteDeAccionesOrganic.prg" )
*!*			loFactory.llLDEBELEVANTARERRORELENVIAR = .f.
*!*			loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )
*!*			loConectorAO.lDesarrollo = .f.
*!*			loConectorAO.lEsBuildAutomatico = .f.	 
*!*			lnRetorno = loConectorAO.ObtenerDisponibilidadAAO()
*!*			this.AssertEquals( "La disponibilidad no es la correcta 2.", 2, lnRetorno ) &&  No esta disponible con error.		
*!*			
*!*			loFactory = null
*!*			loConectorAO = null
*!*		endfunc 
		
		
	*-----------------------------------------------------------------------------------------
	function zTestObtenerConfirmarEliminacionDeDBAlAAOConTicketParaCerrarCircuitoDeEliminacionRemota
		local loConectorAO as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
			loFactory as FakeFactoryConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg, ;
			lcRutaAplicacion as String, lcNombreExe as String, loInstruccionesOrganic as zoocoleccion OF zoocoleccion.prg, ;
			loZooLogicSAConectorDeRedesConectorWCF as Object, lcContenidoDeScript as String, lnCantLineas as integer, ;
			lcAtributo as String, lcTipoDato as String, lcValor as String, lnRetorno as Integer
		
		local array laLineas[1]
		
		_Screen.mocks.agregarmock( "Zoologicsa.ConectorDeRedes.ConfiguracionAgenteOrganic", "ConfiguracionAgenteOrganicParaTest", "zTestConectorAgenteDeAccionesOrganic.prg" )

		loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganic_ELIMINARDB", "zTestConectorAgenteDeAccionesOrganic.prg" )
		loFactory.llLDEBELEVANTARERRORELENVIAR = .f.
		loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )

		loConectorAO.lDesarrollo = .t.
		loConectorAO.lEsBuildAutomatico = .t.
		loConectorAO.ConfirmarEliminacionDeDBAlAAO( "123456", "1234", "GUIDBASEDEDATOS", "BASEDEDATOS" )
		
		this.assertequals( "La primer clave es incorrecta.", "OperationTicketId", loFactory.oConectorDeRedWCF.oDato.Item[0].clave )
     	this.assertequals( "El primer valor es incorrecto.", "1234", loFactory.oConectorDeRedWCF.oDato.Item[0].valor )
		
		this.assertequals( "La segunda variable es incorrecta.", "ActionID", loFactory.oConectorDeRedWCF.oDato.Item[1].clave )
		this.assertequals( "El segundo valor es incorrecto.", "123456", loFactory.oConectorDeRedWCF.oDato.Item[1].valor )
		
		this.assertequals( "La tercera variable es incorrecta.", "IdBaseDeDatos", loFactory.oConectorDeRedWCF.oDato.Item[2].clave )
		this.assertequals( "El tercero valor es incorrecto.", "GUIDBASEDEDATOS", loFactory.oConectorDeRedWCF.oDato.Item[2].valor )
		
		this.assertequals( "La cuarta variable es incorrecta.", "NombreDb", loFactory.oConectorDeRedWCF.oDato.Item[3].clave )
		this.assertequals( "El cuarto valor es incorrecto.", "BASEDEDATOS", loFactory.oConectorDeRedWCF.oDato.Item[3].valor )
		
		this.assertequals( "La quinta variable es incorrecta.", "Serie", loFactory.oConectorDeRedWCF.oDato.Item[4].clave )
		this.assertequals( "El quinto valor es incorrecto.", _Screen.zoo.app.cserie, loFactory.oConectorDeRedWCF.oDato.Item[4].valor )
				
		loFactory = null
		loConectorAO = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_EjecutarPedirMandatoDeReplicaDeSubida
		local loConectorAO as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
			loFactory as FakeFactoryConectorAgenteDeAccionesOrganic of zTestConectorAgenteDeAccionesOrganic.prg, loBases as zoocoleccion OF zoocoleccion.prg, lcAccion as String
		loFactory =  _screen.zoo.crearobjeto( "FakeFactoryConectorAgenteDeAccionesOrganicSolicitarMandato", "zTestConectorAgenteDeAccionesOrganic.prg" )
		loConectorAO = _screen.zoo.crearobjeto( "ConectorAgenteDeAccionesOrganic","", loFactory )
		loBases = _Screen.zoo.crearobjeto( "zooColeccion" )
		loBases.Add( "PAISES" )
		loBases.Add( "COUNTRYS" )
		lcAccion = "cierre de caja"
		loConectorAO.EjecutarPedirMandatoDeReplicaDeSubida( loBases, lcAccion )
		
		this.AssertEquals( "La acción no es la esperada.", "ComunicacionZNubeSoloReplicaDeSubida", loFactory.oConectorDeRedWCF.cAccion )
		this.AssertEquals( "La acción no es la esperada.", "Pedir mandato a zNube", loFactory.oConectorDeRedWCF.cDescripcion )
		this.AssertEquals( "La clave no es la esperada.", "Tipo", loFactory.oConectorDeRedWCF.oDatos.Item[ 0 ].Clave )
		this.AssertEquals( "El valor no es el esperado.", "Mandato", loFactory.oConectorDeRedWCF.oDatos.Item[ 0 ].Valor )
		this.AssertEquals( "El valor no es el esperado.", "BasesDeDatos", loFactory.oConectorDeRedWCF.oDatos.Item[ 1 ].Clave )
		this.AssertTrue( "El valor no es el esperado countrys.", "COUNTRYS" $ loFactory.oConectorDeRedWCF.oDatos.Item[ 1 ].Valor )
		this.AssertEquals( "El valor no es el esperado.", "DescripcionDeLaAccion", loFactory.oConectorDeRedWCF.oDatos.Item[ 2 ].Clave )
		this.AssertEquals( "El valor no es el esperado.", "cierre de caja", loFactory.oConectorDeRedWCF.oDatos.Item[ 2 ].Valor )
		this.AssertEquals( "El valor no es el esperado.", "FechaDeLaAccion", loFactory.oConectorDeRedWCF.oDatos.Item[ 3 ].Clave )
		this.AssertEquals( "El valor no es el esperado.", golibrerias.convertirFechaacaracterconformato( date(), "dd/MM/yyyy" ), loFactory.oConectorDeRedWCF.oDatos.Item[ 3 ].Valor )
		this.AssertEquals( "El valor no es el esperado.", "HoraDeLaAccion", loFactory.oConectorDeRedWCF.oDatos.Item[ 4 ].Clave )

					
		this.AssertEquals( "No instancio el conector.", "O", vartype( loConectorAO ) )
	endfunc

EndDefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ConfiguracionAgenteOrganicParaTest as custom
	function EjecutaScriptOrganicPorMedioDelGestor()
		return .t.
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ConfiguracionAgenteOrganicParaTest2 as custom
	function EjecutaScriptOrganicPorMedioDelGestor()
		return .t.
	endfunc
	function enviar()
		return .t.
	endfunc	
enddefine
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class FakeFactoryConectorAgenteDeAccionesOrganic as Custom

	oConectorDeRedWCF = null
	lllDebeLevantarErrorElEnviar = .f.
	
	*-----------------------------------------------------------------------------------------
	function Obtener( tcTipoDeConector as String ) as Object
		local loConectorDeRedes as Object
		if tcTipoDeConector == "conectoragenteorganic"
			loConectorDeRedes = newobject( "FACEZooLogicSAConectorDeRedesConectorWCF" )
			loConectorDeRedes.lllDebeLevantarErrorElEnviar = this.lllDebeLevantarErrorElEnviar
		else
			loConectorDeRedes = null
		endif
		this.oConectorDeRedWCF = loConectorDeRedes
		return loConectorDeRedes
	endfunc 	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class FakeFactoryConectorAgenteDeAccionesOrganic_ELIMINARDB as Custom

	oConectorDeRedWCF = null
	lllDebeLevantarErrorElEnviar = .f.
	
	*-----------------------------------------------------------------------------------------
	function Obtener( tcTipoDeConector as String ) as Object
		local loConectorDeRedes as Object
		if tcTipoDeConector == "conectoragenteorganic"
			loConectorDeRedes = newobject( "ZooLogicSAConectorDeRedesConectorWCF_TESTEliminarDB" )
			loConectorDeRedes.lllDebeLevantarErrorElEnviar = this.lllDebeLevantarErrorElEnviar
		else
			loConectorDeRedes = null
		endif
		this.oConectorDeRedWCF = loConectorDeRedes
		return loConectorDeRedes
	endfunc 	
enddefine

*-----------------------------------------------------------------------------------------
define class FACEZooLogicSAConectorDeRedesConectorWCF as Custom
	
	cAccion = ""
	cDescripcion = ""
	cUltimoScript = ""
	cUltimaRutaAplicacion = ""
	cUltimoNombreExe = ""
	nTimeOut = 0
	lllDebeLevantarErrorElEnviar = .f.
	lRetorno_EjecutaScriptOrganicPorMEdioDelGestor = .f.

	cDato = ""
	
	*-----------------------------------------------------------------------------------------
	function Enviar( tcAccion as string, tcDescripcion as string, toDatos as object ) as Void
		this.cAccion = tcAccion 
		this.cDescripcion = tcDescripcion 

		if type( "toDatos.Count" ) = "N"
			this.cUltimoNombreExe = toDatos.Item[0].Valor
			this.cUltimoScript = toDatos.Item[1].Valor
			this.cUltimaRutaAplicacion = toDatos.Item[2].Valor
			this.nTimeOut = toDatos.Item[3].Valor
		else
			this.cDato = toDatos
		endif
		
		if this.lllDebeLevantarErrorElEnviar and .t.
			goServicios.Errores.LevantarExcepcion( newobject( "Exception" ) )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutaScriptOrganicPorMEdioDelGestor() as Boolean
		return this.lRetorno_EjecutaScriptOrganicPorMEdioDelGestor 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ping() as Boolean
		local llRetorno as Boolean
		llRetorno = this.lllDebeLevantarErrorElEnviar 
		
		return llRetorno
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
define class ZooLogicSAConectorDeRedesConectorWCF_TESTEliminarDB as Custom
	
	lllDebeLevantarErrorElEnviar = .f.
	lRetorno_EjecutaScriptOrganicPorMEdioDelGestor = .f.
	cAccion = ""
	cDescripcion = ""
	oDato = null
	
	*-----------------------------------------------------------------------------------------
	function Enviar( tcAccion as string, tcDescripcion as string, toDatos as object ) as Void
		this.cAccion = tcAccion 
		this.cDescripcion = tcDescripcion 

		this.ODato = toDatos

		
		if this.lllDebeLevantarErrorElEnviar and .t.
			goServicios.Errores.LevantarExcepcion( newobject( "Exception" ) )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutaScriptOrganicPorMEdioDelGestor() as Boolean
		return this.lRetorno_EjecutaScriptOrganicPorMEdioDelGestor 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ping() as Boolean
		local llRetorno as Boolean
		llRetorno = this.lllDebeLevantarErrorElEnviar 
		
		return llRetorno
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
function ObtenerContenidoDeScriptOrganic( toInstrucciones as zoocoleccion OF zoocoleccion.prg ) as String
	local lcRetorno as String
	lcRetorno = goServicios.Ejecucion.GenerarContenidoDelScriptScript( "", "", toInstrucciones, .t., .f.)
	return lcRetorno
endfunc 

*-----------------------------------------------------------------------------------------
define class FakeFactoryConectorAgenteDeAccionesOrganicSolicitarMandato as Custom
	oConectorDeRedWCF = null

	*-----------------------------------------------------------------------------------------
	function Obtener( tcTipoDeConector as String ) as Object
		local loConectorDeRedes as Object
		if tcTipoDeConector == "conectoragenteorganic"
			loConectorDeRedes = newobject( "FAKEZooLogicSAConectorDeRedesConectorWCF" )
		else
			loConectorDeRedes = null
		endif
		this.oConectorDeRedWCF = loConectorDeRedes
		return loConectorDeRedes
	endfunc 	

enddefine

*-----------------------------------------------------------------------------------------
define class FAKEZooLogicSAConectorDeRedesConectorWCF as Custom
	
	cAccion = ""
	cDescripcion = ""
	oDatos = ""
	
	*-----------------------------------------------------------------------------------------
	function Enviar( tcAccion as string, tcDescripcion as string, toDatos as object ) as Void
		this.cAccion = tcAccion 
		this.cDescripcion = tcDescripcion 
		this.oDatos = toDatos
	endfunc 

enddefine