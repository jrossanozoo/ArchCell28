**********************************************************************
Define Class ztestMantenimientoSystemStartUp as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestMantenimientoSystemStartUp of ztestMantenimientoSystemStartUp.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_MantenimientoSystemStartUpCTOR
		local loMantenimientoSSU as Object
		
	*Arrange (Preparar)
		loMantenimientoSSU = newobject( "MantenimientoSystemStartUp", "MantenimientoSystemStartUp.prg" )
	*Assert (Afirmar)
		this.AssertEquals( "No se seteo bien la propiedad cClaveRegistry", "Software\Microsoft\Windows\CurrentVersion\Run", loMantenimientoSSU.cClaveRegistry )
		this.AssertEquals( "No se seteo bien la propiedad cValorRegistry", ["] + alltrim( sys( 16, 0 ) ) + [" SYSTEMSTARTUP], loMantenimientoSSU.cValorRegistry )
		this.AssertNotNull( "No creo el objeto Registry", loMantenimientoSSU.oManejoRegistry )
		loMantenimientoSSU = null
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	Function zTestU_SetearValorEnRegistryParaAgregarElSystemStartUp_CASO1 
		local loMantenimientoSSU as Object, loMockRegistry as Object, lcValorEnRegistry as String
				
*		CASO 1) ir a la registry y verificar q este. Previamente no tiene que estar
	*Arrange (Preparar)
		loMockRegistry = newobject( "MockRegistry", this.Class + ".prg")
		loMantenimientoSSU = newobject( "MantenimientoSystemStartUp", "MantenimientoSystemStartUp.prg" )
		loMantenimientoSSU.cArchivoExe = this.class + ".fxp"
		loMantenimientoSSU.oManejoRegistry = loMockRegistry		
		loMockRegistry.lPasoPorElSet = .f.
		loMockRegistry.nCantidadPasoPorElDelete = 0
		loMockRegistry.lPasoPorElGet = .f.

	*Act (Actuar)
		loMockRegistry.cRetornoGetRegKey = ""
		loMantenimientoSSU.SetearValorEnRegistry( "DRAGON" )

	*Assert (Afirmar)
		this.AssertTrue( "No paso por el metodo get del valor en la registry", loMockRegistry.lPasoPorElGet)
		this.AssertTrue( "No paso por el metodo setear el valor en la registry", loMockRegistry.lPasoPorElSet)
		this.AssertEquals( "No tenia que pasar por el metodo Delete el valor en la registry", 1, loMockRegistry.nCantidadPasoPorElDelete)

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SetearValorEnRegistryParaAgregarElSystemStartUp_CASO2 
		local loMantenimientoSSU as Object, loMockRegistry as Object, lcValorEnRegistry as String
				
*		CASO 2) ir a la registry y verificar q este. Asegurando que tiene que estar
	*Arrange (Preparar)
		loMockRegistry = newobject( "MockRegistry", this.Class + ".prg")
		loMantenimientoSSU = newobject( "MantenimientoSystemStartUp", "MantenimientoSystemStartUp.prg" )
		loMantenimientoSSU.cArchivoExe = this.class + ".fxp"
		loMantenimientoSSU.oManejoRegistry = loMockRegistry		
		loMockRegistry.lPasoPorElGet = .f.
		loMockRegistry.lPasoPorElSet = .f.
		loMockRegistry.nCantidadPasoPorElDelete = 0
		
	*Act (Actuar)
		loMockRegistry.cRetornoGetRegKey = "DRAGON"
		loMantenimientoSSU.SetearValorEnRegistry( "DRAGON" )

	*Assert (Afirmar)
		this.AssertTrue( "No paso por el metodo get del valor en la registry", loMockRegistry.lPasoPorElGet)
		this.AssertTrue( "No paso por el metodo setear el valor en la registry", loMockRegistry.lPasoPorElSet)
		this.AssertEquals( "No tenia que pasar por el metodo Delete el valor en la registry", 2, loMockRegistry.nCantidadPasoPorElDelete)

	endfunc 


	*-----------------------------------------------------------------------------------------
	Function zTestI_MantenimientoSystemStartUpDentroDeSalidaUnicaSistema_CASO1
		local loSalida as Object, loMockMantenimiento as Object
				
*		CASO1 )se tuvo que haber usado nuestra clase y se tuvo que haber ejecutado el metodo SetearValorEnRegistry de la clase Mantenimiento, con el valor DragonFish Color y Talle
	*Arrange (Preparar)
		this.agregarmocks( "ManagerEjecucion" )
		 _screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Tienescriptcargado', .F. )
		 _screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Cerrarinstanciasdeaplicacion', .T., ".T." )
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		goServicios.Ejecucion =  _screen.zoo.crearobjeto( "ManagerEjecucion" )

		this.agregarmocks( "Librerias" )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'ObtenerDatosDeINI', "SI", "[*COMODIN],[SETEOSAPLICACION],[REGENERARSTARTUP]"  )
		goServicios.Librerias = _screen.zoo.crearobjeto( "Librerias" )		

		_Screen.Mocks.AgregarMock( "MantenimientoSystemStartUp" )
		_Screen.Mocks.AgregarMock( "GarbageCollector" )
		_Screen.Mocks.agregarseteometodo( "GarbageCollector", "GarbageCollectorArchivos", .T., "[*COMODIN]" )
		_screen.mocks.agregarseteometodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz]" )				
		 _screen.mocks.AgregarSeteoMetodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz],[scriptverificacionREST_]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANTENIMIENTOSYSTEMSTARTUP', 'Setearvalorenregistry', .T., "[" + _screen.zoo.app.ObtenerNombre() + "]" )
		loSalida = newobject( "MockSalidaUnicaSistema", this.Class + ".prg" )

	*Act (Actuar)
		loSalida.Salir()

	*Assert (Afirmar)
		_screen.mocks.verificarejecuciondemocks( "MantenimientoSystemStartUp" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestI_MantenimientoSystemStartUpDentroDeSalidaUnicaSistema_CASO2
		local loSalida as Object, loMockMantenimiento as Object, llResultado as Boolean, ;
				loMock as Object, loMetodoMock as Object
				
*		CASO2 )testear que no se ejecute para un script organic

	*Arrange (Preparar)
		this.agregarmocks( "ManagerEjecucion" )
		 _screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Tienescriptcargado', .T. )
		 _screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Cerrarinstanciasdeaplicacion', .T., ".T." )

		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		goServicios.Ejecucion =  _screen.zoo.crearobjeto( "ManagerEjecucion" )

		this.agregarmocks( "Librerias" )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'ObtenerDatosDeINI', "SI", "[*COMODIN],[SETEOSAPLICACION],[REGENERARSTARTUP]"  )
		goServicios.Librerias = _screen.zoo.crearobjeto( "Librerias" )		

		_Screen.Mocks.AgregarMock( "MantenimientoSystemStartUp" )
		_Screen.Mocks.AgregarMock( "GarbageCollector" )
		_Screen.Mocks.agregarseteometodo( "GarbageCollector", "GarbageCollectorArchivos", .T., "[*COMODIN]" )
		_screen.mocks.agregarseteometodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz]" )				
		 _screen.mocks.AgregarSeteoMetodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz],[scriptverificacionREST_]" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MANTENIMIENTOSYSTEMSTARTUP', 'Setearvalorenregistry', .T., "[DragonFish Color y Talle]" )
		loSalida = newobject( "MockSalidaUnicaSistema", this.Class + ".prg" )
		llResultado = .f.

	*Act (Actuar)
		loSalida.Salir()

	*Assert (Afirmar)

		for each loMock in _screen.Mocks FoxObject
			if alltrim( upper( loMock.cNombreClaseReal ) ) = "MANTENIMIENTOSYSTEMSTARTUP"
				if !loMock.lUsado
					for each loMetodoMock in loMock.oMetodos FoxObject
						if alltrim( upper( loMetodoMock.cMetodo ) ) = "SETEARVALORENREGISTRY"
							llResultado = .t.
							exit
						endif
					next
					exit
				endif
			endif
		Next
		this.AssertTrue( "No deberia haberse llamado el metodo SetearValorEnRegistry de la clase MantenimientoSystemStartUp porque es un script organic", llResultado )

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestI_MantenimientoSystemStartUpDentroDeSalidaUnicaSistema_CASO3
		local loSalida as Object, loMockMantenimiento as Object, llResultado as Boolean, ;
				loMock as Object, loMetodoMock as Object
				
*		CASO3 )testear que no se ejecute en caso que se especifique por ini que no lo haga
	*Arrange (Preparar)
		this.agregarmocks( "ManagerEjecucion" )
		 _screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Tienescriptcargado', .F. )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Cerrarinstanciasdeaplicacion', .T., ".T." ) 
		
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		goServicios.Ejecucion =  _screen.zoo.crearobjeto( "ManagerEjecucion" )
		
		this.agregarmocks( "Librerias" )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'ObtenerDatosDeINI', "NO", "[*COMODIN],[SETEOSAPLICACION],[REGENERARSTARTUP]"  )
		goServicios.Librerias = _screen.zoo.crearobjeto( "Librerias" )		
		
		_Screen.Mocks.AgregarMock( "MantenimientoSystemStartUp" )
		_Screen.Mocks.AgregarMock( "GarbageCollector" )
		_Screen.Mocks.agregarseteometodo( "GarbageCollector", "GarbageCollectorArchivos", .T., "[*COMODIN]" )
		_screen.mocks.agregarseteometodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz]" )				
		 _screen.mocks.AgregarSeteoMetodo( 'GARBAGECOLLECTOR', 'Garbagecollectorsegunextension', .T., "[*COMODIN],[sz],[scriptverificacionREST_]" )
		_screen.mocks.AgregarSeteoMetodo( 'MANTENIMIENTOSYSTEMSTARTUP', 'Setearvalorenregistry', .T., "[DragonFish Color y Talle]" )
		loSalida = newobject( "MockSalidaUnicaSistema", this.Class + ".prg" )
		llResultado = .f.

	*Act (Actuar)
		loSalida.Salir()

	*Assert (Afirmar)
		for each loMock in _screen.Mocks FoxObject
			if alltrim( upper( loMock.cNombreClaseReal ) ) = "MANTENIMIENTOSYSTEMSTARTUP"
				if !loMock.lUsado
					for each loMetodoMock in loMock.oMetodos FoxObject
						if alltrim( upper( loMetodoMock.cMetodo ) ) = "SETEARVALORENREGISTRY"
							llResultado = .t.
							exit
						endif
					next
					exit
				endif
			endif
		Next
		this.AssertTrue( "No deberia haberse llamado el metodo SetearValorEnRegistry de la clase MantenimientoSystemStartUp porque el ini decia que no", llResultado )

	endfunc 

EndDefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class MockRegistry as custom
	cRetornoGetRegKey = ""
	lPasoPorElGet = .f.
	nCantidadPasoPorElDelete = 0
	lPasoPorElSet = .f.
	*-----------------------------------------------------------------------------------------
	function GetRegKey( tcProducto as String, tcValorActual as String, tcClave as String, tcHKEY_CURRENT_USER as String ) 
		this.lPasoPorElGet = .t.
		tcValorActual = this.cRetornoGetRegKey
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DeletekeyValue( tcProducto as String, tcClave as String, tcHKEY_CURRENT_USER as String ) as Boolean
		this.nCantidadPasoPorElDelete = this.nCantidadPasoPorElDelete + 1
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetRegKey( tcProducto as String, tcValor as String, tcClave as String, tcHKEY_CURRENT_USER as string, tlBoolean as Boolean )
		this.lPasoPorElSet = .t.
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class MockSalidaUnicaSistema as SalidaUnicaSistema of SalidaUnicaSistema.prg

	*-----------------------------------------------------------------------------------------
	function MarcarSalida() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ClearAndSetSysMenuTo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarTodosLosFormularios() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarBufferControladorFiscal() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarAplicacion() as Void
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function MatarAplicacion() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutoDesdeExe() as Boolean
		return .t.
	endfunc 
enddefine

