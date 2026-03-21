**********************************************************************
Define Class zTestSalidaUnicaSistema as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestSalidaUnicaSistema of zTestSalidaUnicaSistema.prg
	#ENDIF
	
	oSalida = null

	*---------------------------------
	Function Setup
		this.oSalida = newobject( "SalidaUnicaSistema_TEST" )
	EndFunc
	
	*---------------------------------
	Function TearDown
		this.oSalida = null
	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestSalidaForzada
		this.oSalida.SalidaDelSistema( .t. )

		this.asserttrue( "Ejecuto el método IsServerAvailable", !this.oSalida.lPasoPorIsServerAvailable )
		this.asserttrue( "No se Ejecuto el método CerrarTodosLosFormularios", this.oSalida.lPasoPorCerrarTodosLosFormularios )
		this.asserttrue( "No se Ejecuto el método CerrarAplicacion", this.oSalida.lPasoPorCerrarAplicacion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSalidaSinForzarYServidorNoAvailable
		this.oSalida.SalidaDelSistema()

		this.asserttrue( "No se Ejecuto el método IsServerAvailable", this.oSalida.lPasoPorIsServerAvailable )
		this.asserttrue( "No se Ejecuto el método CerrarTodosLosFormularios", this.oSalida.lPasoPorCerrarTodosLosFormularios )
		this.asserttrue( "No se Ejecuto el método CerrarAplicacion", this.oSalida.lPasoPorCerrarAplicacion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSalidaSinForzar_ServidorAvailableYFormPpalCerrado
		this.oSalida.lRetornoIsServerAvailable = .t.

		this.oSalida.SalidaDelSistema()

		this.asserttrue( "No se Ejecuto el método IsServerAvailable", this.oSalida.lPasoPorIsServerAvailable )
		this.asserttrue( "No se Ejecuto el método DesregistrarTerminal", this.oSalida.lPasoPorDesregistrarTerminal )
		this.asserttrue( "No se Ejecuto el método Salir", this.oSalida.lPasoPorSalir )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSalidaSinForzar_ServidorAvailableYFormPpalAbierto
		local loParametros as Collection
		
		this.oSalida.lRetornoIsServerAvailable = .t.
		this.oSalida.oRetornoObtenerFormularioPrincipal = this.oServicioMocks.GenerarMock( "zooFormPrincipal" )
		loParametros = newobject( "collection" )
		loParametros.Add( .t. )
		this.oSalida.oRetornoObtenerFormularioPrincipal.Establecerexpectativa( "CerrarSubFormularios", .t., loParametros )

		this.oSalida.SalidaDelSistema()

		this.asserttrue( "No se Ejecuto el método IsServerAvailable", this.oSalida.lPasoPorIsServerAvailable )
		this.asserttrue( "No se Ejecuto el método DesregistrarTerminal", this.oSalida.lPasoPorDesregistrarTerminal )
		this.asserttrue( "No se Ejecuto el método Salir", this.oSalida.lPasoPorSalir )
		this.oSalida.oRetornoObtenerFormularioPrincipal.ValidarLlamadas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_GarbageCollectorArchivos
		local loObj as Object
		
	*Arrange (Preparar)
		_Screen.Mocks.AgregarMock( "GarbageCollector" )
		_Screen.Mocks.agregarseteometodo( "GarbageCollector", "GarbageCollectorArchivos", .T., "[*COMODIN]" )
		_screen.mocks.agregarseteometodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz]" )
		_screen.mocks.AgregarSeteoMetodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz],[scriptverificacionREST_]" )

		loObj = newobject( "SalidaUnicaSistema_AUX" )
		
	*Act (Actuar)
		loObj.Salir()

	*Assert (Afirmar)
		_screen.mocks.verificarejecuciondemocks("GARBAGECOLLECTOR" )

		loObj = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_FicharSalida
		local loObj as Object
		
		*Arrange (Preparar)
		*_screen.mocks.agregarmock( "ZooLogicSA.Core.MonitorDeIngresoYSalida", "mock_MonitorDeIngresoYSalida", "zTestSalidaUnicaSistema.prg" )

		loObj = newobject( "SalidaUnicaSistema_AUX" )
		toMonitorDeIngresoYSalida = _screen.zoo.crearObjeto("mock_MonitorDeIngresoYSalida", "zTestSalidaUnicaSistema.prg" )
		loObj.InyectarMonitorIngresoYSalida( toMonitorDeIngresoYSalida )

		*Act (Actuar)
		loObj.SalidaDelSistema()

		*Assert (Afirmar)
		this.AssertEquals( "No se llamó al método FicharSalida.", .t., toMonitorDeIngresoYSalida.lSalidaFichada  )
		
	endfunc
	
EndDefine

define class mock_MonitorDeIngresoYSalida as custom
	lSalidaFichada = .f.
	
	*-----------------------------------------------------------------------------------------
	function FicharSalida() as Void
		this.lSalidaFichada = .t.
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
define class SalidaUnicaSistema_TEST as SalidaUnicaSistema of SalidaUnicaSistema.prg

	lPasoPorIsServerAvailable = .f.
	lRetornoIsServerAvailable = .f.
	lPasoPorCerrarTodosLosFormularios = .f.
	lPasoPorCerrarAplicacion = .f.
	lPasoPorObtenerFormularioPrincipal = .f.
	oRetornoObtenerFormularioPrincipal = null
	lPasoPorDesregistrarTerminal = .f.
	lPasoPorSalir = .f.

	*-----------------------------------------------------------------------------------------
	protected function IsServerAvailable() as Boolean
		this.lPasoPorIsServerAvailable = .t.
		return this.lRetornoIsServerAvailable
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CerrarTodosLosFormularios( tlValor as Boolean ) as VOID
		this.lPasoPorCerrarTodosLosFormularios = .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarAplicacion() as VOID
		this.lPasoPorCerrarAplicacion = .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFormularioPrincipal() as Void
		this.lPasoPorObtenerFormularioPrincipal = .t.
		return this.oRetornoObtenerFormularioPrincipal
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DesregistrarTerminal() as Void
		this.lPasoPorDesregistrarTerminal = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Salir() as Void
		this.lPasoPorSalir = .t.
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
define class SalidaUnicaSistema_AUX as SalidaUnicaSistema of SalidaUnicaSistema.prg
	*-----------------------------------------------------------------------
	Function LimpiarBufferControladorFiscal() As Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarAplicacion() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function MatarAplicacion() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarTodosLosFormularios( tlNoGuardarMemoria as Boolean ) as Void
	endfunc

	protected function ClearAndSetSysMenuTo() as VOID
	endfunc
enddefine