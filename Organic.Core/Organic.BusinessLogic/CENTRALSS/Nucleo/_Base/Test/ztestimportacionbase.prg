**********************************************************************
Define Class zTestImportacionBase as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestImportacionBase of zTestImportacionBase.prg
	#ENDIF

	oldextensionparaarchivosconerrores = ""
	nTipoLog = 0
	
	*---------------------------------
	Function Setup
		This.oldextensionparaarchivosconerrores = goRegistry.nuCLEO.Importaciones.extensionparaarchivosconerrores
		this.nTipoLog = goParametros.Nucleo.Importacion.tipoDeLog 
	EndFunc
	
	*---------------------------------
	Function TearDown
		goRegistry.nucleo.Importaciones.extensionparaarchivosconerrores	= This.oldextensionparaarchivosconerrores
		goParametros.Nucleo.Importacion.tipoDeLog = this.nTipoLog
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInterfaz
		local loImportacion as importacionbase of importacionBase.prg
		
		loImportacion = _screen.zoo.crearobjeto( "importacionBase" )
		
		this.asserttrue( "Falta el metodo validar", pemstatus( loImportacion, "validar", 5 ) )
		this.asserttrue( "Falta el metodo procesar", pemstatus( loImportacion, "procesar", 5 ) )		

		this.asserttrue( "Falta la propiedad ruta", pemstatus( loImportacion, "ruta", 5 ) )
		this.asserttrue( "Falta la propiedad oArchivos", pemstatus( loImportacion, "oArchivos", 5 ) )		
		
		loImportacion = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestProcesar
		local loImportacion as importacionbase of importacionBase.prg, loColeccion as zoocoleccion OF zoocoleccion.prg

		_Screen.Mocks.AgregarMock( "ManagerMonitor" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Iniciarlogueorecepcion', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Iniciarlogueocabecera', .T., "0,.F.,.F." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".T." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".T." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".T." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".T." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueotransferencia', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".F." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Loguearavisos', .T., "[Error mock]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".F." )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Loguearavisos', .T., "[Error mock]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".F." )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Loguearavisos', .T., "[Error mock]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".F." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Loguearavisos', .T., "[Error mock]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueotransferencia', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".T.,.F.,.F." ) 
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Incrementaravancetransferencia', .T., "1,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERMONITOR', 'Finalizarlogueocabecera', .T., ".F.,.F.,.F." )



		_Screen.Mocks.AgregarMock( "Mensajes" )

		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "[El proceso a finalizado con errores. Verifique el monitor.]" ) 


		private goMonitor
		goMonitor = _screen.zoo.crearobjeto( "ManagerMonitor" )

		private goMensajes
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )


		loColeccion = _screen.zoo.crearobjeto( "zooColeccion" )
		loArchivo1 = newobject( "oArchivo" )
		loArchivo1.cNombre = "Archivos1.txt"
		loArchivo2 = newobject( "oArchivo" )
		loArchivo2.cNombre = "Archivos1.txt"		
		loArchivo3 = newobject( "oArchivo" )
		loArchivo3.cNombre = "Archivos1.txt"		
		loArchivo4 = newobject( "oArchivo" )
		loArchivo4.cNombre = "Archivos1.txt"		

		loColeccion.Add( loArchivo1 )
		loColeccion.Add( loArchivo2 )
		loColeccion.Add( loArchivo3 )		
		loColeccion.Add( loArchivo4 )				
		
		loImportacion = newobject( "importacionBase_mock" )
		loImportacion.Validacion = .t.

		loImportacion.Procesar( loColeccion )
		This.asserttrue( "No paso por Importacion cuando la validacion era correcta." ,loImportacion.lPasoPorImportar )
		
		This.assertequals( "La cantidad de archivos en la coleccion interna no es la correcta." ,4 , loImportacion.oArchivos.Count )

		loImportacion.Validacion = .f.
		loImportacion.lPasoPorImportar = .f.
		loImportacion.Procesar( loColeccion )
		This.asserttrue( "Paso por Importacion cuando la validacion no era correcta." ,!loImportacion.lPasoPorImportar )

		release loImportacion

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestObtenerNombreCompleto
	local loImportacion as importacionbase of importacionBase.prg

		loImportacion = _screen.zoo.crearobjeto( "importacionBase" )
		loImportacion.Ruta = "c:\DIR\"

		loColeccion = _screen.zoo.crearobjeto( "zooColeccion" )
		loArchivo1 = newobject( "oArchivo" )
		loArchivo1.cNombre = "Archivos1.txt"
		loArchivo2 = newobject( "oArchivo" )
		loArchivo2.cNombre = "Archivos1.txt"		
		loArchivo3 = newobject( "oArchivo" )
		loArchivo3.cNombre = "Archivos1.txt"		
		loArchivo4 = newobject( "oArchivo" )
		loArchivo4.cNombre = "Archivos1.txt"		

		loColeccion.Add( loArchivo1 )
		loColeccion.Add( loArchivo2 )
		loColeccion.Add( loArchivo3 )		
		loColeccion.Add( loArchivo4 )	
		loImportacion.oArchivos = loColeccion
		lcRutaCompleta = loImportacion.ObtenerNombreCompleto( loArchivo1 ) 
		
		This.assertequals( "El nombre a obtener no es correcto.", upper( "C:\DIR\ARCHIVOS1.TXT" ) , alltrim( upper( lcRutaCompleta ) ) ) 
		
		release loImportacion
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestObtenerProximoNombreArchivoError
		local loImportacion as importacion of Importacionbase.prg, lcRuta as String ,;
				lcArchivoError as String 
		
		goRegistry.nuCLEO.Importaciones.eXTENSIONPARAARCHIVOSCONERRORES = "Pro"
		lcArchivo = addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.Pro"
		delete file ( addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.Pro*" )

		loImportacion = _screen.zoo.crearobjeto( "importacionBase" )
		
		lcArchivoError = loImportacion.ObtenerArchivoError( addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.txt" )
		This.assertequals( "El archivo de error no es el correcto 1.", alltrim( upper( lcArchivo ) ) , alltrim( upper( lcArchivoError ) ) )

		
		strtofile( "Error1", lcArchivo )
		lcArchivoError = loImportacion.ObtenerArchivoError( addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.txt" )
		This.assertequals( "El archivo de error no es el correcto 2.", ;
				alltrim( upper( addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.pro1" ) ) , alltrim( upper( lcArchivoError ) ) )
					
		for i = 1 to 9 
			lcArchivo = addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.pro" + alltrim( transform( i ) )
			strtofile( "Error1", lcArchivo, 1 )
		endfor
			
		lcArchivoError = loImportacion.ObtenerArchivoError( addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.txt" )
		This.assertequals( "El archivo de error no es el correcto 3.", ;
		upper( alltrim( addbs( _screen.zoo.obtenerrutatemporal() ) + "Archivo.pro10" ) ) , alltrim( upper( lcArchivoError ) ) )
				
		release loImportacion

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestObtenerNombreErrAlImportar_pasarPor
		local loImportacion as importacion of Importacionbase.prg, loArchivo as Object
		
		loImportacion = Newobject( "importacionBase_Err" )
		loArchivo = newobject( "oArchivo" )
		loImportacion.ImportarMock( loArchivo )
		
		This.asserttrue( "No paso por obtener nombre de archivo error al importar.", loImportacion.lPasoPorobtenerNombredeArchivoErr )
		This.assertequals( "El nombre de archivo error a retornar no es el correcto.", "NombreRetorno.err" ,loImportacion.cArchivoError )

		release loImportacion
	endfunc 

EndDefine


define class importacionBase_Err as ImportacionBase of ImportacionBase.prg

lPasoPorobtenerNombredeArchivoErr = .f.

	function init
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ImportarMock( toArchivo as Object ) as Void
		This.Importar( toArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerArchivoError( tcArchivo as String ) as String
		This.lPasoPorobtenerNombredeArchivoErr = .t.
		return "NombreRetorno.err"
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------

define class importacionBase_mock as ImportacionBase of ImportacionBase.prg

Validacion = .f.
lPasoPorImportar = .f.
lPasoporValidarCamposObligatorios = .f.

	*-----------------------------------------------------------------------------------------
	function Validar( toArchivo as Object ) as boolean
		
		if This.Validacion
		else
			This.AgregarInformacion( "Error mock" )
		endif
		
		return This.Validacion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Importar( toArchivo as Object ) as Void
		This.lPasoPorImportar = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposObligatorios() as Void
		This.lPasoporValidarCamposObligatorios = .t.
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class importacionBase_mockVal as importacionBase of importacionBase.prg

lPasoporValidarCamposObligatorios = .f.

	*-----------------------------------------------------------------------------------------
	function ValidarCamposObligatorios() as Void
		This.lPasoporValidarCamposObligatorios = .t.
	endfunc 
enddefine


Define class oArchivo as Custom

cNombre = ""
nTamanio = 0
cRuta = ""
nIdLogueo = 0

enddefine

