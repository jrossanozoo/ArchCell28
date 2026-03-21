**********************************************************************
define class zTestModulos as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestModulos of zTestModulos.prg
	#endif
	cSerie = ""
	cNombre = ""
	cOrganizacion = ""
*---------------------------------
	function setup
		this.cSerie = _screen.Zoo.app.cSerie
		this.cNombre = _screen.Zoo.app.cNombre
		this.cOrganizacion = _screen.Zoo.app.cOrganizacion
	endfunc

*---------------------------------
	function TearDown
		_screen.Zoo.app.cSerie = this.cSerie
		_screen.Zoo.app.cNombre = this.cNombre
		_screen.Zoo.app.cOrganizacion = this.cOrganizacion
	endfunc
*-----------------------------------------------------------------------------------------
	function zTestVerificarExistenciaDeModuloBase
		local loModulos as Modulos of Modulos.prg

		loModulos = _screen.zoo.crearobjeto( "Modulos" )
		loCol = loModulos.ObtenerModulos()

		with loCol.item[ 1 ]
			this.assertequals( "La descripción del modulo Base es incorrecta", "Base", .cNombre )
		endwith

		loModulos.release()
	endfunc

*-----------------------------------------------------------------------------------------
	function zTestVerificarActivacionDeModuloBase
		local loModulos as Modulos of Modulos.prg, llValorRetornado as Boolean

		loModulos = _screen.zoo.crearobjeto( "Modulos" )

		llValorRetornado = loModulos.ModuloHabilitado( "B" )
		this.asserttrue( "No está activado el módulo base.", llValorRetornado )
		loModulos.release()

	endfunc

*-----------------------------------------------------------------------------------------
	function zTestHabilitarModuloExistente
		local loModulos as Modulos of Modulos.prg, llRet as Boolean, loError as exception, loInfo as zooinformacion of zooInformacion.prg

		private goFormularios
		with _screen.mocks
			.Agregarmock( "ManagerFormularios" )
			goFormularios = _screen.zoo.CrearObjeto( "ManagerFormularios" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "NODEMO", "1" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "0", "1501" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1501,[1]" )
		endwith

		loModulos = newobject( "ModulosMock" )

		loModulos.regmodact( "1" )
		this.asserttrue( "El módulo debe estar habilitado.", loModulos.ModuloHabilitado( "M" ) )

		goFormularios.release()
		loModulos.release()

	endfunc

*-----------------------------------------------------------------------------------------
	function zTestDeshabilitarModuloExistente
		local loModulos as Modulos of Modulos.prg, llRet as Boolean, loError as exception, loInfo as zooinformacion of zooInformacion.prg

		private goFormularios
		with _screen.mocks
			.Agregarmock( "ManagerFormularios" )
			goFormularios = _screen.zoo.CrearObjeto( "ManagerFormularios" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "NODEMO", "1" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "1", "1501" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1501,[0]" )
		endwith

		loModulos = newobject( "ModulosMock" )

		loModulos.regmodact( "0" )
		this.asserttrue( "El módulo debe estar deshabilitado.", !loModulos.ModuloHabilitado( "M" ) )

		goFormularios.release()
		loModulos.release()

	endfunc

*-----------------------------------------------------------------------------------------
	function zTestSetearModuloInexistente
		local loModulos as Modulos of Modulos.prg, loError as exception, loInfo as zooinformacion of zooInformacion.prg

		private goFormularios
		with _screen.mocks
			.Agregarmock( "ManagerFormularios" )
			goFormularios = _screen.zoo.CrearObjeto( "ManagerFormularios" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "NODEMO", "1" )
		endwith

		loModulos = newobject( "ModulosMockSinModulos" )
		try
			loModulos.regmodact( "1" )
			this.asserttrue( "Deberia haber fallado por no existir el módulo.", .f. )
		catch to loError
			loInfo = loError.uservalue.ObtenerInformacion()
			this.assertequals( "La el mensaje de la excepcion no es el correcto.", "NO SE ENCUENTRA EL MÓDULO A HABILITAR (M)", ;
				upper( alltrim( loInfo[ 1 ].cMensaje ) ) )

		endtry

		goFormularios.release()
		loModulos.release()

	endfunc

*-----------------------------------------------------------------------------------------
	function zTestSetearModuloSinEquivalencia
		local loModulos as Modulos of Modulos.prg, loError as exception, loInfo as zooinformacion of zooInformacion.prg

		private goFormularios
		with _screen.mocks
			.Agregarmock( "ManagerFormularios" )
			goFormularios = _screen.zoo.CrearObjeto( "ManagerFormularios" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "NODEMO", "1" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "1", "1501" )
		endwith

		loModulos = newobject( "ModulosMockSinEquivalencia" )
		try
			loModulos.regmodact( "1" )
			this.asserttrue( "Deberia haber fallado por no existir la equivalencia.", .f. )
		catch to loError
			loInfo = loError.uservalue.ObtenerInformacion()
			this.assertequals( "La el mensaje de la excepcion no es el correcto.", "NO SE ENCUENTRA LA EQUIVALENCIA Nº 1",;
				upper( alltrim( loInfo[ 1 ].cMensaje ) ) )
		endtry

		goFormularios.release()
		loModulos.release()

	endfunc

*-----------------------------------------------------------------------------------------
	function zTestHabilitarVariosModulos
		local loModulos as object

		private goFormularios
		with _screen.mocks
			.Agregarmock( "ManagerFormularios" )
			goFormularios = _screen.zoo.CrearObjeto( "ManagerFormularios" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "NODEMO", "1" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Leer', "0", "[*COMODIN]" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1501,[1]" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1502,[0]" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1503,[0]" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1503,[0]" )
			.AgregarSeteoMetodo( 'MANAGERFORMULARIOS', 'Escribir', .t., "1503,[1]" )
		endwith

		loModulos = newobject( "ModulosMockActivos_Inactivos" )
		lcValorEsperado = "10001"

		loModulos.RegModAct( lcValorEsperado )
		lcValorRetornado = loModulos.ObtenerEstadoDeModulos()

		this.assertequals( "Los módulos activos/inactivos son incorrectos", lcValorEsperado, lcValorRetornado )

		release loModulos
	endfunc

*-----------------------------------------------------------------------------------------
	function zTestRegModAct
		local loModulos as object

		loModulos = newobject( "ModulosTest" )

		with loModulos

			.RegModAct( "1100011001101000010" ) && activos: 1, 2, 10, 18

			this.assertequals( "La cantidad de modulos activados es incorrecta 1.", 4, .oColHabilitados.count )
			this.assertequals( "La cantidad de modulos desactivados es incorrecta 1.", 1, .oColDesHabilitados.count )

			this.assertequals( "El modulo activado es incorrecto 1.", "A", .oColHabilitados.item( 1 ) )
			this.assertequals( "El modulo activado es incorrecto 2.", "B", .oColHabilitados.item( 2 ) )
			this.assertequals( "El modulo activado es incorrecto 3.", "C", .oColHabilitados.item( 3 ) )
			this.assertequals( "El modulo activado es incorrecto 4.", "E", .oColHabilitados.item( 4 ) )
			this.assertequals( "El modulo DesActivado es incorrecto 1.", "D", .oColDesHabilitados.item( 1 ) )

			.release()
		endwith

		loModulos = newobject( "ModulosTest" )
		with loModulos
			.RegModAct( "0000000000000000000" ) && todos desactivados

			this.assertequals( "La cantidad de modulos activados es incorrecta 2.", 0, .oColHabilitados.count )
			this.assertequals( "La cantidad de modulos desactivados es incorrecta 2.", 5, .oColDesHabilitados.count )


			this.assertequals( "El modulo DESactivado es incorrecto 1.", "A", .oColDesHabilitados.item( 1 ) )
			this.assertequals( "El modulo DESactivado es incorrecto 2.", "B", .oColDesHabilitados.item( 2 ) )
			this.assertequals( "El modulo DESactivado es incorrecto 3.", "C", .oColDesHabilitados.item( 3 ) )
			this.assertequals( "El modulo DESactivado es incorrecto 4.", "D", .oColDesHabilitados.item( 4 ) )
			this.assertequals( "El modulo DESactivado es incorrecto 5.", "E", .oColDesHabilitados.item( 5 ) )

			.release()
		endwith

		loModulos = newobject( "ModulosTest" )
		with loModulos
			.RegModAct( "1111111111111111111" ) && todos activados

			this.assertequals( "La cantidad de modulos activados es incorrecta 3.", 5, .oColHabilitados.count )
			this.assertequals( "La cantidad de modulos desactivados es incorrecta 3.", 0, .oColDesHabilitados.count )


			this.assertequals( "El modulo activado es incorrecto 1.", "A", .oColHabilitados.item( 1 ) )
			this.assertequals( "El modulo activado es incorrecto 2.", "B", .oColHabilitados.item( 2 ) )
			this.assertequals( "El modulo activado es incorrecto 3.", "C", .oColHabilitados.item( 3 ) )
			this.assertequals( "El modulo activado es incorrecto 4.", "D", .oColHabilitados.item( 4 ) )
			this.assertequals( "El modulo activado es incorrecto 5.", "E", .oColHabilitados.item( 5 ) )

			.release()
		endwith
	endfunc

*-----------------------------------------------------------------------------------------
	function zTestVerificarModuloSaas
		local loModulos as object

		loModulos = newobject( "ModulosTest" )

		this.asserttrue( "Debería existir la propiedad nPosicionModuloSaaS", pemstatus( loModulos, "nPosicionModuloSaaS",5 ))
		this.asserttrue( "Debería existir la verificación del módulo Saas", pemstatus( loModulos, "VerificarModuloSaaS",5 ))
		this.assertequals( "Debería devolver .f. la verificación del módulo Saas", .f., loModulos.VerificarModuloSaaS() )

		loModulos.release

	endfunc
*-----------------------------------------------------------------------------------------
	function ztestRegYValid
		private goFormularios as object
		private goModulos as object

		local loLibrerias as object, loObjeto as custom
		loObjeto = newobject( "Custom" )
		loObjeto.addproperty( "Serie", "DEMO" )
		loObjeto.addproperty( "Nombre", "101010" )
		loObjeto.addproperty( "Org", "101010" )
		goModulos = newobject( "Aux_Mod" )
		goFormularios = newobject( "Aux_Form" )
		loLibrerias = newobject( "Aux_Lib" )
		goModulos.lVerificarModuloSaaS  = .f.
		loLibrerias.lPasoPorValidarCantApp = .f.
		loLibrerias.AuxRegYValid( loObjeto )
		this.Asserttrue( "Debio pasar por el ValidarCantApp", loLibrerias.lPasoPorValidarCantApp )

	endfunc
*-----------------------------------------------------------------------------------------
	function ztestEntidadHabilitada
		local loModulos as Modulos of Modulos.Prg

		loModulos = newobject( "Aux_Mod2" )
		with loModulos
			this.Asserttrue( "No deberia estar habilitada la entidad argentina.", !.EntidadHabilitada( "Argentina" ) )
			this.Asserttrue( "No deberia estar habilitada la entidad Cuba.", !.EntidadHabilitada( "Cuba" ) )
			this.Asserttrue( "No deberia estar habilitada la entidad Honduras.", !.EntidadHabilitada( "Honduras" ) )
			this.Asserttrue( "No deberia estar habilitada la entidad Jamaica al no tener modulos.", !.EntidadHabilitada( "Jamaica" ) )
			.lA = .t.
			.lD = .t.
			.lG = .t.

			this.Asserttrue( "Deberia estar habilitada la entidad argentina 1.", .EntidadHabilitada( "Argentina" ) )
			this.Asserttrue( "Deberia estar habilitada la entidad Cuba 1.", .EntidadHabilitada( "Cuba" ) )
			this.Asserttrue( "Deberia estar habilitada la entidad Honduras 1.", .EntidadHabilitada( "Honduras" ) )
			this.Asserttrue( "Deberia estar habilitada la entidad Jamaica 1.", !.EntidadHabilitada( "Jamaica" ) )
			.lH = .t.
			.lF = .t.
			.lS = .t.
			this.Asserttrue( "Deberia estar habilitada la entidad argentina 2.", .EntidadHabilitada( "Argentina" ) )
			this.Asserttrue( "Deberia estar habilitada la entidad Cuba 2.", .EntidadHabilitada( "Cuba" ) )
			this.Asserttrue( "Deberia estar habilitada la entidad Honduras 2.", .EntidadHabilitada( "Honduras" ) )
			this.Asserttrue( "Deberia estar habilitada la entidad Jamaica 2.", !.EntidadHabilitada( "Jamaica" ) )
			.ld = .f.
			.lF = .f.
			this.Asserttrue( "No deberia estar habilitada la entidad Cuba 3.", !.EntidadHabilitada( "Cuba" ) )
			.release()
		endwith
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class Aux_Form as custom
*-----------------------------------------------------------------------------------------
	function EsD() as Boolean
		return .f.
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
define class Aux_Mod as custom
	lVerificarModuloSaaS = .f.
*-----------------------------------------------------------------------------------------
	function VerificarModuloSaaS() as Boolean
		return this.lVerificarModuloSaaS
	endfunc
*-----------------------------------------------------------------------------------------
    function ActualizarModulosDemo() as Void
    endfunc
enddefine
*-----------------------------------------------------------------------------------------
define class Aux_Lib as librerias of Librerias.prg
	lPAsoPorVAlidarCantApp  = .f.
*-----------------------------------------------------------------------------------------
	function AuxRegYValid( toObject as object ) as Void
		this.RegYValid( toObject )
	endfunc
*-----------------------------------------------------------------------------------------
	function ValidarCantAppMultiSeries() as Void
		this.lPAsoPorVAlidarCantApp = .t.
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ModulosTest as Modulos of Modulos.prg

	oColHabilitados = null
	oColDesHabilitados = null

*-----------------------------------------------------------------------------------------
	function init
		dodefault()
		this.oColHabilitados = _screen.zoo.crearobjeto( "ZooColeccion" )
		this.oColDesHabilitados = _screen.zoo.crearobjeto( "ZooColeccion" )
	endfunc

*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		this.oEquivalencias.agregar( "A", "1" )
		this.oEquivalencias.agregar( "B", "2" )
		this.oEquivalencias.agregar( "", "3" )
		this.oEquivalencias.agregar( "", "4" )
		this.oEquivalencias.agregar( "", "5" )
		this.oEquivalencias.agregar( "", "6" )
		this.oEquivalencias.agregar( "", "7" )
		this.oEquivalencias.agregar( "", "8" )
		this.oEquivalencias.agregar( "", "9" )
		this.oEquivalencias.agregar( "C", "10" )
		this.oEquivalencias.agregar( "", "11" )
		this.oEquivalencias.agregar( "D", "12" )
		this.oEquivalencias.agregar( "", "13" )
		this.oEquivalencias.agregar( "", "14" )
		this.oEquivalencias.agregar( "", "15" )
		this.oEquivalencias.agregar( "", "16" )
		this.oEquivalencias.agregar( "", "17" )
		this.oEquivalencias.agregar( "E", "18" )
		this.oEquivalencias.agregar( "", "19" )
	endfunc

*-----------------------------------------------------------------------------------------
	function HabilitarModulo( tcModulo as string ) as Void
		this.oColHabilitados.agregar( tcModulo )
	endfunc

*-----------------------------------------------------------------------------------------
	function DeshabilitarModulo( tcModulo as string ) as Void
		this.oColDesHabilitados.agregar( tcModulo )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ModulosTest2 as Modulos of Modulos.prg

*-----------------------------------------------------------------------------------------
	function HabilitarModuloAux( tcModulo as string ) as Void
		this.HabilitarModulo( tcModulo )
	endfunc

*-----------------------------------------------------------------------------------------
	function DeshabilitarModuloAux( tcModulo as string ) as Void
		this.DeshabilitarModulo( tcModulo )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class Aux_Mod2 as Modulos of Modulos.Prg
	lA = .f.
	lS = .f.
	lD = .f.
	lF = .f.
	lG = .f.
	lH = .f.
	lB = .f.
*-----------------------------------------------------------------------------------------
	function ModuloHabilitado( tcModulo as string ) as Boolean
		local lcRetorno as string
		lcRetorno = "This.l" + alltrim( tcModulo )
		return &lcRetorno
	endfunc
*-----------------------------------------------------------------------------------------
	function EntidadTieneMenu( tcEntidad as string ) as Boolean
		return .t.
	endfunc
enddefine


*-----------------------------------------------------------------------------------------
define class ModulosMock as Modulos of Modulos.Prg

	protected function LlenarColeccion() as Void
		this.oModulos.Agregar( this.ObtenerModulo( 1501, "ModuloFake", "M" ), "M" )
	endfunc

*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		with this.oEquivalencias
			.agregar( "M", "1" )
		endwith
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class ModulosMockSinModulos as Modulos of Modulos.Prg

*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		with this.oEquivalencias
			.agregar( "M", "1" )
		endwith
	endfunc

enddefine



*-----------------------------------------------------------------------------------------
define class ModulosMockSinEquivalencia as Modulos of Modulos.Prg

*-----------------------------------------------------------------------------------------
	protected function LlenarColeccion() as Void
		this.oModulos.Agregar( this.ObtenerModulo( 1501, "ModuloFake", "M" ), "M" )
	endfunc

*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void

	endfunc

enddefine


*-----------------------------------------------------------------------------------------
define class ModulosMockActivos_Inactivos as Modulos of Modulos.Prg

*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		this.oEquivalencias.agregar( "A", "1" )
		this.oEquivalencias.agregar( "B", "2" )
		this.oEquivalencias.agregar( "C", "3" )
		this.oEquivalencias.agregar( "D", "4" )
		this.oEquivalencias.agregar( "E", "5" )
	endfunc

*-----------------------------------------------------------------------------------------
	protected function LlenarColeccion() as Void
		this.oModulos.Agregar( this.ObtenerModulo( 1501, "ModuloFake_A", "A" ), "A" )
		this.oModulos.Agregar( this.ObtenerModulo( 1502, "ModuloFake_B", "B" ), "B" )
		this.oModulos.Agregar( this.ObtenerModulo( 1503, "ModuloFake_C", "C" ), "C" )
		this.oModulos.Agregar( this.ObtenerModulo( 1503, "ModuloFake_D", "D" ), "D" )
		this.oModulos.Agregar( this.ObtenerModulo( 1503, "ModuloFake_E", "E" ), "E" )
	endfunc

*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDeModulos() as Void
		local lcRetornoEstadoModulos as string, loItem as object

		lcRetornoEstadoModulos = ""

		for each loItem in this.oModulos
			lcRetornoEstadoModulos = lcRetornoEstadoModulos + iif( loitem.lHabilitado, "1", "0" )
		endfor

		return lcRetornoEstadoModulos
	endfunc

enddefine


