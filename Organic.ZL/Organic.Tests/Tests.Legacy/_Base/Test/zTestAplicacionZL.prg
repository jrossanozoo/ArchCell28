**********************************************************************
Define Class zTestAplicacionZL as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestAplicacionZL of zTestAplicacionZL.prg
	#ENDIF
	
	oldruTAARCHIVOTECNOVOZ  = ""
	oldsECCION = ""
	oldENTRADA = ""
	oldRUTAARCHIVOPUESTO = ""
	oldnUMEROLINEASERIE = 0
	oldpOSICIONDESDESERIE = 0
	oldloNGITUDNUMEROSERIE = 0
	oldACTIVARVERIFICACIONCHECKLINE = .f.
	oldACTIVAVERIFICACIONHOST = .f.
	lMockearParametros = .F.
	
	*---------------------------------
	Function Setup

	 this.oldruTAARCHIVOTECNOVOZ 			= goparametros.zl.teCNOVOZ.ruTAARCHIVOTECNOVOZ 
	 this.oldsECCION 						= goregistry.zl.teCNOVOZ.sECCION
	 this.oldENTRADA 						= goregistry.zl.tECNOVOZ.ENTRADA
	 this.oldRUTAARCHIVOPUESTO 				= goparametros.zl.tECNOVOZ.RUTAARCHIVOPUESTO
	 this.oldnUMEROLINEASERIE 				= goparametros.zl.teCNOVOZ.nUMEROLINEASERIE
	 this.oldpOSICIONDESDESERIE		 		= goparametros.zl.teCNOVOZ.pOSICIONDESDESERIE
	 this.oldloNGITUDNUMEROSERIE 			= goparametros.zl.teCNOVOz.loNGITUDNUMEROSERIE
	 this.oldACTIVARVERIFICACIONCHECKLINE 	= goparametros.zl.cHECKLINE.ACTIVARVERIFICACIONCHECKLINE
     this.oldACTIVAVERIFICACIONHOST			= goparametros.zl.robothost.ACTIVARVERIFICACIONHOST  

	EndFunc
	
	*---------------------------------
	Function TearDown

	 goparametros.zl.teCNOVOZ.ruTAARCHIVOTECNOVOZ 			= this.oldruTAARCHIVOTECNOVOZ
	 goregistry.zl.teCNOVOZ.sECCION 						= this.oldsECCION
	 goregistry.zl.tECNOVOZ.ENTRADA							= this.oldENTRADA
	 goparametros.zl.tECNOVOZ.RUTAARCHIVOPUESTO				= this.oldRUTAARCHIVOPUESTO
	 goparametros.zl.teCNOVOZ.nUMEROLINEASERIE 				= this.oldnUMEROLINEASERIE
	 goparametros.zl.teCNOVOZ.pOSICIONDESDESERIE 			= this.oldpOSICIONDESDESERIE
	 goparametros.zl.teCNOVOz.loNGITUDNUMEROSERIE 			= this.oldloNGITUDNUMEROSERIE
	 goparametros.zl.cHECKLINE.ACTIVARVERIFICACIONCHECKLINE = this.oldACTIVARVERIFICACIONCHECKLINE
	 goparametros.zl.robothost.ACTIVARVERIFICACIONHOST 		= this.oldACTIVAVERIFICACIONHOST

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestControlParametrosyRegistrosAlarmaChecklineHostyTecnoVoz
		with this
			.asserttrue( "No existe el parametro goParametros.Zl.MinutosControlChecklineHost", pemstatus( goParametros.Zl, "MinutosControlChecklineHost", 5 ))
			.asserttrue( "No existe el parametro goParametros.Zl.MinutosToleranciaDelControlChecklineHost", pemstatus( goParametros.Zl, "MinutosToleranciaDelControlChecklineHost", 5 ))
			.asserttrue( "No existe el registro goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline", pemstatus( goRegistry.zl.checkline, "FechaHoraUltimoChequeoCheckline", 5 ))		
			.asserttrue( "No existe el registro goRegistry.zl.Host.FechaHoraUltimoChequeoHost", pemstatus( goRegistry.zl.Host, "FechaHoraUltimoChequeoHost", 5 ))				
			.asserttrue( "No existe el parametro goparametros.zl.cHECKLINE.ACTIVARVERIFICACIONCHECKLINE", pemstatus( goParametros.Zl.checkline, "ACTIVARVERIFICACIONCHECKLINE", 5 ))				
			.asserttrue( "No existe el parametro goparametros.zl.robothost.ACTIVARVERIFICACIONHOST", pemstatus( goParametros.Zl.robothost, "ACTIVARVERIFICACIONHOST", 5 ))				
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.SegundosTimerVerificarArchivoTecnoVoz", pemstatus( goparametros.zl.TecnoVoz,"SegundosTimerVerificarArchivoTecnoVoz" , 5 ))
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestInicializarTimerAlarmaCheckline
		local llEstoyUsandoTimers as Boolean
		
		private goParametros 
		goParametros = newobject( "test_parametros" )

		local loApp as Object
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )

		llEstoyUsandoTimers = loApp.lEstoyUsandoTimers
		
		goParametros.Zl.MinutosControlChecklineHost = 0
		with loApp	
			.lEstoyUsandoTimers = .f.
			.InicializarTimerAlarmaChecklineHost()
			this.assertequals( "No deberia haber inicializado el timer (1)", 0, .nIndiceTimerAlarmaChecklineHost )
			.DetenerTimerAlarmaChecklineHost()
		endwith
		
		with loApp
			.lEstoyUsandoTimers = .f.
			.InicializarTimerAlarmaChecklineHost()
			this.assertequals( "No deberia haber inicializado el timer (2)", 0, .nIndiceTimerAlarmaChecklineHost )
			.DetenerTimerAlarmaChecklineHost()
		endwith
		
		goParametros.Zl.MinutosControlChecklineHost = 1
		with loApp
			.lEstoyUsandoTimers = .f.
			.InicializarTimerAlarmaChecklineHost()
			this.assertequals( "No deberia haber inicializado el timer (3)", 0, .nIndiceTimerAlarmaChecklineHost )		
			.DetenerTimerAlarmaChecklineHost()
		endwith
		
		set library to cpptimer.fll additive
		inittimers( 10, 100 )
		
		goParametros.Zl.MinutosControlChecklineHost = 1	
		with loApp	
			.lEstoyUsandoTimers = .t.
			.InicializarTimerAlarmaChecklineHost()
			this.asserttrue( "Deberia haber inicializado el timer", .nIndiceTimerAlarmaChecklineHost > 0 )	
			.DetenerTimerAlarmaChecklineHost()
			this.assertequals( "Deberia haber detenido el timer", 0, .nIndiceTimerAlarmaChecklineHost )
		endwith
		
		loApp.lEstoyUsandoTimers = llEstoyUsandoTimers	
		loApp.release()
		loApp = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestVerificarPropiedadesExistentes() as Void

		local loApp as Object
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		this.asserttrue( "Deberia existir la propiedad 'cRutaLince'", pemstatus( loApp, 'cRutaLince', 5 ) )
		this.asserttrue( "Deberia existir la propiedad 'cRutaZooLogic'", pemstatus( loApp, 'cRutaZooLogic', 5 ) )
		this.asserttrue( "Deberia existir la propiedad 'cProducto'", pemstatus( loApp, 'cProducto', 5 ) )		
		this.assertequals( "Está mal seteada la propiedad cProducto" , "03" , loApp.cProducto )
		This.assertTrue( "La propiedad 'lUtilizaPrefijoDB' no existe", pemstatus( loApp, 'lUtilizaPrefijoDB', 5 ) )		
		This.assertTrue( "No se inicializo correctamente la propiedad 'lUtilizaPrefijoDB' Debe estar siempre en .f.", !loApp.lUtilizaPrefijoDB )

		loApp.release()
		loApp = null

	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestChequeoAlarmaCheckline
		private goMensajes, goRegistry, goParametros
		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.Agregarseteometodoencola( 'MENSAJES', 'Advertir', .T., "[ATENCIÓN: No se encuentra operativa la consola de checkline. Por favor comuníquese con Infraestructura.]" )
		_screen.mocks.Agregarseteometodoencola( 'MENSAJES', 'Advertir', .T., "[ATENCIÓN: No se encuentra operativo el robot del host. Por favor comuníquese con Infraestructura.]" ) && ztestaplicacionzl.ztestchequeoalarmacheckline 05/05/09 14:45:34

		goMensajes = _screen.Zoo.Crearobjeto( "Mensajes" )
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )

		local loApp as Object, ldFecha as Datetime, lnCantMetodosMocks as Integer

		lnCantMetodosMocks = _screen.mocks[1].oMetodos.Count
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		ldFecha = datetime()

		goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
		goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha )
		goRegistry.zl.host.FechaHoraUltimoChequeoHost = transform( ldFecha )		
		loApp.nCantMinutosAlarma = 0
		loApp.ChequeoAlarmaChecklineHost( ldFecha )
		this.assertequals( "No deberia haber enviado el mensaje de alarma (checkline)", lnCantMetodosMocks, _screen.mocks[1].oMetodos.Count )

		goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
		goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha - 20 )
		loApp.nCantMinutosAlarma = 0		
		loApp.ChequeoAlarmaChecklineHost( ldFecha )
		this.assertequals( "No deberia haber enviado el mensaje de alarma (checkline 2)", lnCantMetodosMocks, _screen.mocks[1].oMetodos.Count )		

		goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
		goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha - 80 )
		loApp.nCantMinutosAlarma = 0
		goParametros.Zl.MinutosControlChecklineHost = 1
		goParametros.Zl.Checkline.ACTIVARVERIFICACIONCHECKLINE = .f.
		loApp.ChequeoAlarmaChecklineHost( ldFecha )
		this.assertequals( "No deberia haber enviado el mensaje de alarma checkline (checkline 3)", .f. ,goParametros.Zl.Checkline.ACTIVARVERIFICACIONCHECKLINE  )		

		goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
		goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha - 80 )
		loApp.nCantMinutosAlarma = 0
		goParametros.Zl.MinutosControlChecklineHost = 1
		goParametros.Zl.Checkline.ACTIVARVERIFICACIONCHECKLINE = .t.
		loApp.ChequeoAlarmaChecklineHost( ldFecha )
		this.asserttrue( "Deberia haber enviado el mensaje de alarma checkline (checkline 4)", lnCantMetodosMocks - 1 = _screen.mocks[1].oMetodos.Count )	

		goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
		goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha - 80 )
		loApp.nCantMinutosAlarma = 0
		goParametros.Zl.MinutosControlChecklineHost = 1
		goParametros.Zl.Checkline.ACTIVARVERIFICACIONCHECKLINE = .f.
		loApp.ChequeoAlarmaChecklineHost( ldFecha )
		this.asserttrue( "No deberia haber enviado el mensaje de alarma checkline porque el parametro ACTIVARVERIFICACIONCHECKLINE esta en falso(checkline 5)", lnCantMetodosMocks - 1 = _screen.mocks[1].oMetodos.Count )	
			
		
*		Hasta que se active la alarma del robot del Host
			_screen.mocks.Agregarseteometodoencola( 'MENSAJES', 'Advertir', .T., "[ATENCIÓN: No se encuentra operativa la consola de checkline. Por favor comuníquese con Infraestructura.]" )

			goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
			goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha )
			goRegistry.zl.host.FechaHoraUltimoChequeoHost = transform( ldFecha - 20 )
			loApp.nCantMinutosAlarma = 0		
			goparametros.zl.robothost.ACTIVARVERIFICACIONHOST = .F.		
			loApp.ChequeoAlarmaChecklineHost( ldFecha )
			this.assertequals( "No deberia haber enviado el mensaje de alarma (host)", lnCantMetodosMocks, _screen.mocks[1].oMetodos.Count )		


			goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
			goRegistry.zl.Host.FechaHoraUltimoChequeoHost = transform( ldFecha - 80 )
			loApp.nCantMinutosAlarma = 0
			goParametros.Zl.MinutosControlChecklineHost = 1
			goparametros.zl.robothost.ACTIVARVERIFICACIONHOST = .T.	
			loApp.ChequeoAlarmaChecklineHost( ldFecha )
			this.asserttrue( "Deberia haber enviado el mensaje de alarma (host)", lnCantMetodosMocks - 1 = _screen.mocks[1].oMetodos.Count )		
			
		_screen.mocks.Agregarseteometodoencola( 'MENSAJES', 'Advertir', .T., "[ATENCIÓN: No se encuentra operativo el robot del host. Por favor comuníquese con Infraestructura.]" ) && ztestaplicacionzl.ztestchequeoalarmacheckline 05/05/09 14:45:34

			goParametros.zl.MinutosToleranciaDelControlChecklineHost = 1
			goParametros.Zl.MinutosControlChecklineHost = 1
			goRegistry.zl.Host.FechaHoraUltimoChequeoHost = transform( ldFecha - 80 )
			goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline = transform( ldFecha - 80 )	
			goParametros.Zl.Checkline.ACTIVARVERIFICACIONCHECKLINE = .T.
			goparametros.zl.robothost.ACTIVARVERIFICACIONHOST = .T.				
			loApp.nCantMinutosAlarma = 0
			loApp.ChequeoAlarmaChecklineHost( ldFecha )
			this.asserttrue( "Deberia haber enviado los mensajes de alarma checkline y host", lnCantMetodosMocks - 2 = _screen.mocks[1].oMetodos.Count )
		
		loApp.release()
		loApp = null
	endfunc 
	

	*-----------------------------------------------------------------------------------------
	function zTestInicializarTimerTecnoVoz
		local llEstoyUsandoTimers as Boolean, loApp as Object
		
		private goParametros 
		goParametros = newobject( "test_parametros" )
		
		goparametros.zl.TecnoVoz.SegundosTimerVerificarArchivoTecnoVoz = 0
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		llEstoyUsandoTimers = loApp.lEstoyUsandoTimers
		
		with loApp	
			.lEstoyUsandoTimers = .f.
			.InicializarTimerTecnoVoz()
			this.assertequals( "No deberia haber inicializado el timer (1)", 0, .nIndiceTimerVerificarArchivoTecnoVoz )
			.DetenerTimerTecnoVoz()
		endwith
		
		goparametros.zl.TecnoVoz.SegundosTimerVerificarArchivoTecnoVoz = 60
		with loApp
			.lEstoyUsandoTimers = .f.
			.InicializarTimerTecnoVoz()
			this.assertequals( "No deberia haber inicializado el timer (2)", 0, .nIndiceTimerVerificarArchivoTecnoVoz )		
			.DetenerTimerTecnoVoz()
		endwith
		
		set library to cpptimer.fll additive
		inittimers( 10, 100 )
		

		with loApp	
			.lEstoyUsandoTimers = .t.
			.InicializarTimerTecnoVoz()
			this.asserttrue( "Deberia haber inicializado el timer", .nIndiceTimerVerificarArchivoTecnoVoz > 0 )	
			.DetenerTimerTecnoVoz()
			this.assertequals( "Deberia haber detenido el timer", 0, .nIndiceTimerVerificarArchivoTecnoVoz )
		endwith
		
		loApp.lEstoyUsandoTimers = llEstoyUsandoTimers	
		loApp.release()
		loApp = null
	endfunc 	
EndDefine

*-----------------------------------------------------------------------------------------
define class test_parametros as custom

	function init
		this.addobject( "ZL", "custom" )
		this.zl.addproperty( "MinutosControlChecklineHost", 30 )
		this.zl.addproperty( "MinutosToleranciaDelControlChecklineHost", 10 )

		this.zl.addobject( "CheckLine", "custom" )
		this.zl.CheckLine.addproperty ( "ACTIVARVERIFICACIONCHECKLINE", .f. )

		this.zl.addobject( "robothost", "custom" )
		this.zl.robothost.addproperty( "ACTIVARVERIFICACIONHOST", .f. )

		this.zl.addobject( "TecnoVoz", "custom" )	
		this.zl.TecnoVoz.addproperty( "SegundosTimerVerificarArchivoTecnoVoz", 0 )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class test_registros as custom

	function init
		this.addobject( "ZL", "custom" )
		this.zl.AddObject( "Checkline", "Collection" )	
		this.zl.AddObject( "Host", "Collection" )	
		this.zl.Checkline.addproperty( "FechaHoraUltimoChequeoCheckline", "" )
		this.zl.Host.addproperty( "FechaHoraUltimoChequeoHost", "" )	
	endfunc

enddefine
