**********************************************************************
Define Class ztestManagerTecnoVoz As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestManagerTecnoVoz Of ztestManagerTecnoVoz.prg
	#Endif


	*-----------------------------------------------------------------------------------------
	function TearDown
		=EliminarTemporarios()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestControlParametrosYRegistrosTecnoVoz
		
		with this
			.asserttrue( "No existe el registro goregistry.zl.TecnoVoz.Seccion",  pemstatus( goregistry.zl.TecnoVoz, "Seccion" , 5))
		 	.asserttrue( "No existe el registro goregistry.zl.TecnoVoz.Entrada", pemstatus( goregistry.zl.TecnoVoz,  "Entrada" , 5))
			.asserttrue( "No existe el registro goregistry.zl.TecnoVoz.CheckSumUltimoArchivo" , pemstatus( goregistry.zl.TecnoVoz, "CheckSumUltimoArchivo" , 5 ))
		 	.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.RutaArchivoPuesto", pemstatus( goparametros.zl.TecnoVoz, "RutaArchivoPuesto", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.RutaArchivoTecnoVoz", pemstatus( goparametros.zl.TecnoVoz, "RutaArchivoTecnoVoz", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.NumeroLineaReferencia", pemstatus( goparametros.zl.TecnoVoz, "NumeroLineaReferencia" ,5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.PosicionDesdeReferencia", pemstatus( goparametros.zl.TecnoVoz, "PosicionDesdeReferencia", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.LongitudNumeroReferencia", pemstatus( goparametros.zl.TecnoVoz, "LongitudNumeroReferencia", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.NumeroLineaSerie", pemstatus( goparametros.zl.TecnoVoz, "NumeroLineaSerie", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.PosicionDesdeSerie", pemstatus( goparametros.zl.TecnoVoz, "PosicionDesdeSerie", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.LongitudNumeroSerie", pemstatus( goparametros.zl.TecnoVoz, "LongitudNumeroSerie", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.NumeroLineaRazonSocial", pemstatus( goparametros.zl.TecnoVoz, "NumeroLineaRazonSocial", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.PosicionDesdeRazonSocial", pemstatus( goparametros.zl.TecnoVoz, "PosicionDesdeRazonSocial", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.LongitudRazonSocial", pemstatus( goparametros.zl.TecnoVoz, "LongitudRazonSocial", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.NumeroLineaIndicadorAbreIncidenteAutomaticamente", pemstatus( goparametros.zl.TecnoVoz, "NumeroLineaIndicadorAbreIncidenteAutomaticamente", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.IndicadorAbreIncidenteAutomaticamente", pemstatus( goparametros.zl.TecnoVoz, "IndicadorAbreIncidenteAutomaticamente", 5 ))
			.asserttrue( "No existe el parametro goparametros.zl.TecnoVoz.LongitudMotivoAbreIncidenteAutomaticamente", pemstatus( goparametros.zl.TecnoVoz, "LongitudMotivoAbreIncidenteAutomaticamente", 5 ))
		endwith 
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ztestInstanciarManagerTecnoVoz
		local  loApp as Object

		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		loApp.lEstoyUsandoTimers = .t.
		
		this.asserttrue( "Deberia haber inicializado el ManagerTecnoVoz", pemstatus( loApp, "oTecnoVoz" , 5 ) and vartype( loApp.oTecnoVoz ) = 'O' )
	
		loApp.release()
		loApp = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerValorSugeridoTecnoVoz
		local lcTexto as String 

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		lcTexto = loApp.ObtenerValorSugeridoTecnoVoz()

	   	this.assertequals( "El numero de serie esperado es el 501795", "501795", upper( alltrim( lcTexto ) ) ) 

		loApp.release()
		loApp = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerValorSugeridoReferencia() 

		local lcTexto as String 

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		lcTexto = loApp.ObtenerValorSugeridoReferencia()

		this.assertequals( "El valor de referencia esperado es el 374136001", "374136001", upper( alltrim( lcTexto ) ) ) 

		loApp.release()
		loApp = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerRazonSocialDeTecnovoz() 

		local lcTexto as String 

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		lcTexto = loApp.ObtenerRazonSocialDeTecnovoz()

		this.assertequals( "La Razon Social no es la esperada 05374", "05374", upper( alltrim( lcTexto ) ) ) 

		loApp.release()
		loApp = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerMotivoAperturaAutomaticaDeIncidente() 

		local lcTexto as String 

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		lcTexto = loApp.ObtenerMotivoAperturaAutomaticaDeIncidente()

		this.assertequals( "El motivo de apertura Automatica de Incidente no es el esperado", "Problemas al intentar restaurar Backup", alltrim( lcTexto ) )

		loApp.release()
		loApp = null
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestVerificarCambiosArchivoTecnoVoz() 

		local lDebeAbrirIncidenteAuto as Boolean, lcTexto as String 

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		lcTexto = alltrim( goregistry.zl.TecnoVoz.CheckSumUltimoArchivo )
				
		this.assertequals( "El CheckSum del Ultimo Archivo generado por TecnoVoz en la Registry no es el esperado",  '1877384782', lcTexto )
	
		lDebeAbrirIncidenteAuto = loApp.oTecnoVoz.VerificarCambiosArchivoTecnoVoz()
		this.assertequals( "Deberia realizar apertura Automatica de Incidente", .T., lDebeAbrirIncidenteAuto )

		lDebeAbrirIncidenteAuto = loApp.oTecnoVoz.VerificarCambiosArchivoTecnoVoz()
		this.assertequals( "NO Deberia realizar apertura Automatica de Incidente", .F., lDebeAbrirIncidenteAuto )

		=ModificarArchivoTecnoVoz()
		
		lDebeAbrirIncidenteAuto = loApp.oTecnoVoz.VerificarCambiosArchivoTecnoVoz()
		this.assertequals( "Deberia realizar apertura Automatica de Incidente(2)", .T., lDebeAbrirIncidenteAuto )

		lDebeAbrirIncidenteAuto = loApp.oTecnoVoz.VerificarCambiosArchivoTecnoVoz()
		this.assertequals( "NO Deberia realizar apertura Automatica de Incidente(2)", .F., lDebeAbrirIncidenteAuto )
		
		loApp.release()
		loApp = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz() 

		local lDebeAbrirIncidenteAuto as Boolean, lcTexto as String 

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		lDebeAbrirIncidenteAuto = loApp.oTecnoVoz.DebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz()
		this.assertequals( "Deberia realizar apertura Automatica de Incidente", .T., lDebeAbrirIncidenteAuto )


		loApp.release()
		loApp = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNODebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz() 

		local lDebeAbrirIncidenteAuto as Boolean

		private goParametros , goRegistry
		goParametros = newobject( "test_parametros" )
		goRegistry = newobject( "test_registros" )
		=SeteosInicialesTecnoVoz()
		
		loApp = newobject( "AplicacionZL", "AplicacionZL.prg" )
		goparametros.zl.TecnoVoz.IndicadorAbreIncidenteAutomaticamente = 'SARAZA'				

		lDebeAbrirIncidenteAuto = loApp.oTecnoVoz.DebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz()
		this.assertequals( "NO Deberia realizar apertura Automatica de Incidente", .F., lDebeAbrirIncidenteAuto )

		loApp.release()
		loApp = null
		
	endfunc 
	
Enddefine


*-----------------------------------------------------------------------------------------
define class test_parametros as custom

	function init
		this.addobject( "ZL", "custom" )
		this.zl.addobject( "TecnoVoz", "custom" )	
		this.zl.TecnoVoz.addproperty( "SegundosTimerVerificarArchivoTecnoVoz", 0 )
		
	 	this.zl.TecnoVoz.addproperty( "RutaArchivoPuesto", '')
		this.zl.TecnoVoz.addproperty( "RutaArchivoTecnoVoz", '')
		this.zl.TecnoVoz.addproperty( "NumeroLineaReferencia", 0 )
		this.zl.TecnoVoz.addproperty( "PosicionDesdeReferencia", 0)
		this.zl.TecnoVoz.addproperty( "LongitudNumeroReferencia", 0 )
		this.zl.TecnoVoz.addproperty( "NumeroLineaSerie", 0 )
		this.zl.TecnoVoz.addproperty( "PosicionDesdeSerie", 0 )
		this.zl.TecnoVoz.addproperty( "LongitudNumeroSerie", 0 )
		this.zl.TecnoVoz.addproperty( "NumeroLineaRazonSocial", 0 )
		this.zl.TecnoVoz.addproperty( "PosicionDesdeRazonSocial", 0 )
		this.zl.TecnoVoz.addproperty( "LongitudRazonSocial", 0 )
		this.zl.TecnoVoz.addproperty( "NumeroLineaIndicadorAbreIncidenteAutomaticamente", 0 )
		this.zl.TecnoVoz.addproperty( "PosicionDesdeIndicadorAbreIncidenteAutomaticamente", 0 )
		this.zl.TecnoVoz.addproperty( "LongitudIndicadorAbreIncidenteAutomaticamente", 0 )
		this.zl.TecnoVoz.addproperty( "IndicadorAbreIncidenteAutomaticamente", '' )
		this.zl.TecnoVoz.addproperty( "NumeroLineaMotivoAbreIncidenteAutomaticamente", 0 )
		this.zl.TecnoVoz.addproperty( "PosicionDesdeMotivoAbreIncidenteAutomaticamente", 0 )
		this.zl.TecnoVoz.addproperty( "LongitudMotivoAbreIncidenteAutomaticamente", 0 )

		
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class test_registros as custom

	function init
		this.addobject( "ZL", "custom" )
		this.zl.AddObject( "TecnoVoz", "Collection" )	
		this.zl.TecnoVoz.addproperty( "CheckSumUltimoArchivo", "" )
		this.zl.TecnoVoz.addproperty( "Seccion" , 0 )
		this.zl.TecnoVoz.addproperty( "Entrada", 0 )
	endfunc

enddefine



*-----------------------------------------------------------------------------------------
function SeteosInicialesTecnoVoz() as Void

	local lcRutaParametro as string, lcCadenaArchivo as String, ;
	lcCadenaArchivoIni as String, lcRutaIni as String   

text to lcCadenaArchivo noShow
\TECNOVOZ\TBL\RECSAMP7
19442
I
  Serie: 501795 // R. Social: 05374-Esposito Andrea Graciela; // Cliente: 01462-Grisino Ramos    // Lince Indumentaria  //Implementador: Sin implementar //Carga obligatoria de incidente: Problemas al intentar restaurar Backup                      //    
0
20081002
16212801
004



VIR
7
374136001
1144645061
8100

0

endtext 

	   lcRutaParametro =  addbs( _screen.zoo.obtenerrutatemporal() ) + "Pos006.dat"

	   strtofile( lcCadenaArchivo, lcRutaParametro )

text to lcCadenaArchivoIni noShow
[Call-Center]
TecnoDrive=S
WsNumber=6
ACDNum=1
Extension=217
Trace=1
Address=192.168.0.22
Port=5024
;permite pasar tonos DTMF
ipcall=yes
CallAlert=0
endtext 

	lcRutaIni =  Addbs( _Screen.zoo.obtenerrutatemporal() ) + "archivoini.ini"

	Strtofile( lcCadenaArchivoIni , lcRutaIni )

	goparametros.zl.teCNOVOZ.ruTAARCHIVOTECNOVOZ = Alltrim(lcRutaIni)
	goregistry.zl.teCNOVOZ.sECCION = 'Call-Center'
	goregistry.zl.teCNOVOZ.ENTRADA = 'WsNumber'
	goparametros.zl.teCNOVOZ.RUTAARCHIVOPUESTO = Addbs( _Screen.zoo.obtenerrutatemporal() )
	goparametros.zl.teCNOVOZ.nUMEROLINEASERIE = 4
	goparametros.zl.teCNOVOZ.pOSICIONDESDESERIE = 10
	goparametros.zl.teCNOVOZ.loNGITUDNUMEROSERIE = 6
	goparametros.zl.teCNOVOZ.NumeroLineaReferencia = 14
	goparametros.zl.teCNOVOZ.PosicionDesdeReferencia = 1
	goparametros.zl.teCNOVOZ.LongitudNumeroReferencia = 10
	goparametros.zl.TecnoVoz.NumeroLineaRazonSocial = 4
	goparametros.zl.TecnoVoz.PosicionDesdeRazonSocial = 31
	goparametros.zl.TecnoVoz.LongitudRazonSocial = 5
	goparametros.zl.TecnoVoz.NumeroLineaIndicadorAbreIncidenteAutomaticamente = 4
	goparametros.zl.TecnoVoz.IndicadorAbreIncidenteAutomaticamente = 'Carga obligatoria de incidente:' 
	goparametros.zl.TecnoVoz.LongitudMotivoAbreIncidenteAutomaticamente = 60
	goregistry.zl.TecnoVoz.CheckSumUltimoArchivo = '1877384782'
endfunc

*-----------------------------------------------------------------------------------------
function ModificarArchivoTecnoVoz() as Void

	local lcRutaParametro as string, lcCadenaArchivo as String, ;
	lcCadenaArchivoIni as String, lcRutaIni as String   

text to lcCadenaArchivo noShow
\TECNOVOZ\TBL\RECSAMP7
19442
I
  Serie: 501790 // R. Social: 05374-Esposito Andrea Graciela; // Cliente: 01462-Grisino Ramos    // Lince Indumentaria  //Implementador: Sin implementar //Carga obligatoria de incidente: Problemas al intentar restaurar Backup                      //    
0
20081002
16212801
004



VIR
7
374136001
1144645061
8100

0

endtext 

	   lcRutaParametro =  addbs( _screen.zoo.obtenerrutatemporal() ) + "Pos006.dat"

	   strtofile( lcCadenaArchivo, lcRutaParametro )

endfunc 


*-----------------------------------------------------------------------------------------
function EliminarTemporarios() as VOID 

	Local lcRutaParametro as string, lcRutaIni as String   

	lcRutaParametro =  addbs( _screen.zoo.obtenerrutatemporal() ) + "Pos006.dat"
	lcRutaIni =  Addbs( _Screen.zoo.obtenerrutatemporal() ) + "archivoini.ini"
	
	delete file &lcRutaParametro 
	delete file &lcRutaIni

endfunc 
