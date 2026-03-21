**********************************************************************
Define Class zTestResumenDelDiaInstruccionesScript As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestResumenDelDiaInstruccionesScript Of zTestResumenDelDiaInstruccionesScript.prg
	#Endif

*!*		cBaseDeDatos = ""
*!*		cBuzones = ""
*!*		lHabilitado = .f.
	
	*-----------------------------------------------------------------------------------------
	function Setup
*!*			this.cBaseDeDatos = goServicios.Parametros.Nucleo.Comunicaciones.ProcesarPaquetesDeLTipoABaseDeDatosEnLaBaseDeDatos
*!*			this.cBuzones = goServicios.Parametros.Nucleo.Comunicaciones.EnviarALosBuzones
*!*			this.lHabilitado = goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja

		goServicios.Parametros.Nucleo.Comunicaciones.ProcesarPaquetesDeLTipoABaseDeDatosEnLaBaseDeDatos = "PRUEBA"
		goServicios.Parametros.Nucleo.Comunicaciones.EnviarALosBuzones = "BOX1,BOX2"
		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .t.
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		function TearDown
*!*			goServicios.Parametros.Nucleo.Comunicaciones.ProcesarPaquetesDeLTipoABaseDeDatosEnLaBaseDeDatos = this.cBaseDeDatos
*!*			goServicios.Parametros.Nucleo.Comunicaciones.EnviarALosBuzones = this.cBuzones
*!*			goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = this.lHabilitado
*!*		endfunc 

	*---------------------------------
	Function zTestU_Init
		local loInstrucciones as ResumenDelDiaInstruccionesScript of ResumenDelDiaInstruccionesScript.prg
		
		_screen.mocks.Agregarmock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "", "[ResumenDelDia],[TimeOut]" )

		loInstrucciones = _Screen.zoo.crearobjeto( "ResumenDelDiaInstruccionesScript" )
		
		this.assertequals( "Error en la Base De Datos", "", loInstrucciones.cBaseDeDatos )
		this.assertequals( "Error en el time out", 1200000,loInstrucciones.nTimeOut )
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )
		this.assertequals( "Error en la descripcion", "ResumenDelDia", loInstrucciones.cTipo )
		this.assertequals( "Error en la descripcion", "enviando resumen del día", loInstrucciones.cDescripcion )

		loInstrucciones.release()

		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "999999999999", "[ResumenDelDia],[TimeOut]" )

		loInstrucciones = _Screen.zoo.crearobjeto( "ResumenDelDiaInstruccionesScript" )
		this.assertequals( "Error en el time out", 999999999999,loInstrucciones.nTimeOut )

		loInstrucciones.release()

		_screen.mocks.verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar_ConErrorEnBoxes
		local loInstrucciones as ResumenDelDiaInstruccionesScript of ResumenDelDiaInstruccionesScript.prg, lcScript as string
		
		goServicios.Parametros.Nucleo.Comunicaciones.EnviarALosBuzones = ""

		loInstrucciones = _Screen.zoo.crearobjeto( "ResumenDelDiaInstruccionesScript" )

		loInstrucciones.Actualizar( null )
		
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )

		loInstrucciones.release()

		_screen.mocks.Verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar_ConParametroNoHabilitado
		local loInstrucciones as ResumenDelDiaInstruccionesScript of ResumenDelDiaInstruccionesScript.prg, lcScript as string

		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		
		loInstrucciones = _Screen.zoo.crearobjeto( "ResumenDelDiaInstruccionesScript" )

		loInstrucciones.Actualizar()
		
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )

		loInstrucciones.release()

		_screen.mocks.Verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar_Comunicando
		local loInstrucciones as ResumenDelDiaInstruccionesScript of ResumenDelDiaInstruccionesScript.prg, lcScript as string
		
		goServicios.Parametros.Nucleo.Comunicaciones.EnviarYRecibirPaquetesDeDatosLuegoDeEmpaquetarResumenDelDiaAlCerrarLaCaja = .t.

		_screen.mocks.agregarmock( "Buzon" )
		_screen.mocks.AgregarSeteoMetodo( 'Buzon', 'Esedicion', .T. )
		_screen.mocks.agregarseteopropiedad( "Buzon", "Directorio", "c:\buzon" )
		_screen.mocks.AgregarSeteoMetodo( 'Buzon', 'Cargamanual', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Buzon', 'Directorio_despuesdeasignar', .T. ) 
		
		loInstrucciones = _Screen.zoo.crearobjeto( "ResumenDelDiaInstruccionesScript" )
		loInstrucciones.Actualizar()
		
		this.assertequals( "Error en la cantidad de instrucciones", 20, loInstrucciones.Count )

		this.assertequals( "Instruccion 1 incorrecta", ;
			'loTransferencia = goServicios.transferencias.ProcesarTransferenciaAgrupada( 1 )', ;
			alltrim( loInstrucciones[1] ) )

		this.assertequals( "Instruccion 2 incorrecta", ;
			'loDestino1 = loTransferencia.CrearObjetoDestino()', ;
			alltrim( loInstrucciones[2] ) )

		this.assertequals( "Instruccion 3 incorrecta", ;
			"loDestino1.cDescripcion = 'BOX1'", ;
			alltrim( loInstrucciones[3] ) )

		this.assertequals( "Instruccion 4 incorrecta", ;
			"loDestino1.cDestino = 'c:\buzon\BOX1\envia'", ;
			alltrim( loInstrucciones[4] ) )

		this.assertequals( "Instruccion 5 incorrecta", ;
			'loTransferencia.oDestinos.Agregar( loDestino1 )', ;
			alltrim( loInstrucciones[5] ) )

		this.assertequals( "Instruccion 6 incorrecta", ;
			'loDestino2 = loTransferencia.CrearObjetoDestino()', ;
			alltrim( loInstrucciones[6] ) )

		this.assertequals( "Instruccion 7 incorrecta", ;
			"loDestino2.cDescripcion = 'BOX2'", ;
			alltrim( loInstrucciones[7] ) )

		this.assertequals( "Instruccion 8 incorrecta", ;
			"loDestino2.cDestino = 'c:\buzon\BOX2\envia'", ;
			alltrim( loInstrucciones[8] ) )

		this.assertequals( "Instruccion 9 incorrecta", ;
			'loTransferencia.oDestinos.Agregar( loDestino2 )', ;
			alltrim( loInstrucciones[9] ) )

		this.assertequals( "Instruccion 10 incorrecta", ;
			'loTransferencia.oFiltros[1].Valor1 = date() - 3', ;
			alltrim( loInstrucciones[10] ) )

		this.assertequals( "Instruccion 11 incorrecta", ;
			'loTransferencia.oFiltros[1].Valor2 = date()', ;
			alltrim( loInstrucciones[11] ) )

		this.assertequals( "Instruccion 12 incorrecta", ;
			'goServicios.Transferencias.FinalizarTransferenciaAgrupada( loTransferencia )', ;
			alltrim( loInstrucciones[12] ) )

		this.assertequals( "Instruccion 13 incorrecta", ;
			'loDestino1.release()', ;
			alltrim( loInstrucciones[13] ) )

		this.assertequals( "Instruccion 14 incorrecta", ;
			'loDestino2.release()', ;
			alltrim( loInstrucciones[14] ) )

		this.assertequals( "Instruccion 15 incorrecta", ;
			'loTransferencia.release()', ;
			alltrim( loInstrucciones[15] ) )

		this.assertequals( "Instruccion 16 incorrecta", ;
			"loFactoryResumenDelDia = _screen.zoo.CrearObjetoPorProducto( 'FactoryAccionEnSegundoPlano' )", ;
			alltrim( loInstrucciones[16] ) )

		this.assertequals( "Instruccion 17 incorrecta", ;
			"loAccionResumenDelDia = loFactoryResumenDelDia.Obtener( 'ENVIARECIBEYPROCESAR' )", ;
			alltrim( loInstrucciones[17] ) )

		this.assertequals( "Instruccion 18 incorrecta", ;
			'loAccionResumenDelDia.Enviar()', ;
			alltrim( loInstrucciones[18] ) )

		this.assertequals( "Instruccion 19 incorrecta", ;
			'loFactoryResumenDelDia.release()', ;
			alltrim( loInstrucciones[19] ) )

		this.assertequals( "Instruccion 20 incorrecta", ;
			'loAccionResumenDelDia.release()', ;
			alltrim( loInstrucciones[20] ) )
			
		loInstrucciones.release()
		
		_screen.mocks.Verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar_SinComunicar
		local loInstrucciones as ResumenDelDiaInstruccionesScript of ResumenDelDiaInstruccionesScript.prg, lcScript as string
		
		goServicios.Parametros.Nucleo.Comunicaciones.EnviarYRecibirPaquetesDeDatosLuegoDeEmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		
		_screen.mocks.agregarmock( "Buzon" )
		_screen.mocks.AgregarSeteoMetodo( 'Buzon', 'Esedicion', .T. )
		_screen.mocks.agregarseteopropiedad( "Buzon", "Directorio", "c:\buzon" )
		_screen.mocks.AgregarSeteoMetodo( 'Buzon', 'Cargamanual', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Buzon', 'Directorio_despuesdeasignar', .T. ) 
		
		loInstrucciones = _Screen.zoo.crearobjeto( "ResumenDelDiaInstruccionesScript" )
		loInstrucciones.Actualizar()
		
		this.assertequals( "Error en la cantidad de instrucciones", 15, loInstrucciones.Count )

		this.assertequals( "Instruccion 1 incorrecta", ;
			'loTransferencia = goServicios.transferencias.ProcesarTransferenciaAgrupada( 1 )', ;
			alltrim( loInstrucciones[1] ) )

		this.assertequals( "Instruccion 2 incorrecta", ;
			'loDestino1 = loTransferencia.CrearObjetoDestino()', ;
			alltrim( loInstrucciones[2] ) )

		this.assertequals( "Instruccion 3 incorrecta", ;
			"loDestino1.cDescripcion = 'BOX1'", ;
			alltrim( loInstrucciones[3] ) )

		this.assertequals( "Instruccion 4 incorrecta", ;
			"loDestino1.cDestino = 'c:\buzon\BOX1\envia'", ;
			alltrim( loInstrucciones[4] ) )

		this.assertequals( "Instruccion 5 incorrecta", ;
			'loTransferencia.oDestinos.Agregar( loDestino1 )', ;
			alltrim( loInstrucciones[5] ) )

		this.assertequals( "Instruccion 6 incorrecta", ;
			'loDestino2 = loTransferencia.CrearObjetoDestino()', ;
			alltrim( loInstrucciones[6] ) )

		this.assertequals( "Instruccion 7 incorrecta", ;
			"loDestino2.cDescripcion = 'BOX2'", ;
			alltrim( loInstrucciones[7] ) )

		this.assertequals( "Instruccion 8 incorrecta", ;
			"loDestino2.cDestino = 'c:\buzon\BOX2\envia'", ;
			alltrim( loInstrucciones[8] ) )

		this.assertequals( "Instruccion 9 incorrecta", ;
			'loTransferencia.oDestinos.Agregar( loDestino2 )', ;
			alltrim( loInstrucciones[9] ) )

		this.assertequals( "Instruccion 10 incorrecta", ;
			'loTransferencia.oFiltros[1].Valor1 = date() - 3', ;
			alltrim( loInstrucciones[10] ) )

		this.assertequals( "Instruccion 11 incorrecta", ;
			'loTransferencia.oFiltros[1].Valor2 = date()', ;
			alltrim( loInstrucciones[11] ) )

		this.assertequals( "Instruccion 12 incorrecta", ;
			'goServicios.Transferencias.FinalizarTransferenciaAgrupada( loTransferencia )', ;
			alltrim( loInstrucciones[12] ) )

		this.assertequals( "Instruccion 13 incorrecta", ;
			'loDestino1.release()', ;
			alltrim( loInstrucciones[13] ) )

		this.assertequals( "Instruccion 14 incorrecta", ;
			'loDestino2.release()', ;
			alltrim( loInstrucciones[14] ) )

		this.assertequals( "Instruccion 15 incorrecta", ;
			'loTransferencia.release()', ;
			alltrim( loInstrucciones[15] ) )
			
		loInstrucciones.release()
		
		_screen.mocks.Verificarejecuciondemocks()
	Endfunc
Enddefine
