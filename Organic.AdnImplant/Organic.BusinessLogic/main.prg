#include build.h
#include dovfp.h

parameters tcRutaScriptEjecucion as String, tcLlamoLancelot as String, tcSerie as String, tcClave as String, tcSitio as String

Local loError As Exception, loEx, loControlErrores As Object, llInstancioAplicacion as Boolean, llTieneScript as Boolean, lcComando as string, lcArchivo as String,;
	lcError as String, llModoSystemStartUp as Boolean, lcRutaCompletaDelArchivoExe as String, lcExtension as String

try
	*!*	 DRAGON 2028
	_screen.AddProperty( "_instanceFactory" )
	_screen._instanceFactory = newobject( "InstanceFactory", "InstanceFactory.prg" )
	_screen._instanceFactory.UsingAppReferences()

	InstanciarDatosDeStartup( tcRutaScriptEjecucion, tcLlamoLancelot )
	SetearRutaDeLaAplicacionEnDondeEstaElExe()
	EjecutarExtensionDeCodigo( tcRutaScriptEjecucion, tcLlamoLancelot )

	llModoSystemStartUp = .F.

	if empty( tcRutaScriptEjecucion )
		llTieneScript = .f.
	else
		if upper( alltrim( tcRutaScriptEjecucion ) ) == "LANCELOT"
			llTieneScript = .f.
			tcRutaScriptEjecucion = .f.
		else 
			if EsSystemStartUp( tcRutaScriptEjecucion )
				llTieneScript = .f.
				tcRutaScriptEjecucion = .f.
				llModoSystemStartUp = .T.
				goDatosDeStartupDeLaApp.lIngresoSystemStartup = .t.
			else
				if EsBlanqueo( tcRutaScriptEjecucion )
					tcRutaScriptEjecucion  = CrearScript( tcRutaScriptEjecucion )
				endif

				llTieneScript = .t.
				if pcount() = 2
					*!* tcLlamoLancelot: En este caso se utiliza el segundo parámetro para casos en que se desea evitar la perdida de foco que provoca la ejecución de un script.
					PonerVentanaAlFrente( val( tcLlamoLancelot ) )
				endif

				goDatosDeStartupDeLaApp.lEsScriptOrganic = .t.

			endif
		endif
	endif

	if !llTieneScript and !llModoSystemStartUp
		lcRutaCompletaDelArchivoExe = upper( SYS( 16, 0 ) )

		if empty( tcLlamoLancelot ) or tcLlamoLancelot <> ObtenerParametroLancelotParaComparar()

	*!*		DRAGONFISH 2028
			#IF DOVFP_BUILD_DEBUG
				MostrarMensaje( "DOVFP_BUILD_DEBUG" ,64, "Zoo Logic - Inicio de la aplicación" )
			#ELSE
		*!*		DRAGONFISH 2028
				lcComando = JUSTSTEM( lcRutaCompletaDelArchivoExe )
				lcComando = alltrim( substr( lcComando, 1, len( lcComando )-5 ) )
				lcExtension = JUSTEXT( lcRutaCompletaDelArchivoExe )
						
				lcArchivo = lcComando + "." + lcExtension

				if file( lcArchivo )
					MostrarMensaje( "Run. "  + lcArchivo + " -" + lcComando ,64, "Zoo Logic - Inicio de la aplicación" )

					loWsh = Createobject( "WScript.Shell" )
					loWsh.Run( lcComando, 1, .F. )
				else
					lcError = "ATENCION: Faltan archivos necesarios para la ejecución de la aplicación. " + ;
					"Reinstale el producto para solucionar este inconveniente."

					MostrarMensaje( lcError ,16, "Zoo Logic - Inicio de la aplicación" )
				endif	

				if upper(lcExtension) != "FXP"
					quit && Salida del sistema
				else
					MostrarMensaje( "Salida del sistema. "  + lcArchivo + " -" + lcComando ,64, "Zoo Logic - Inicio de la aplicación" )
				endif
			#ENDIF
		endif
	endif

	Local loServicioAplicaciones As ServicioAplicaciones Of ServicioAplicaciones.prg,;
		lcNombreAplicacion As String, lcNombreAplicacionUsuario as string,;
		lcPaqueteAdn as String

	Store "" To lcNombreAplicacion
	Store "" To lcNombreAplicacionUsuario 

	Do Conf_Sets
	lcNombreAplicacion = LevantarDatosDelINI( "NOMBREAPLICACION" )
	lcNombreAplicacionUsuario = LevantarDatosDelINI( "NOMBRECOMERCIAL" )

	lcPaqueteAdn = LevantarDatosDelINI( "PAQUETEADN" )
	if ( !empty( lcPaqueteAdn ) )
		VerificarEInstalarPaqueteAdn( lcPaqueteAdn )
	endif

	If !Empty( lcNombreAplicacion )
		
		if empty( tcRutaScriptEjecucion )
			loServicioAplicaciones = Newobject( "ServicioAplicacionesVisual", "ServicioAplicacionesVisual.prg", "", lcNombreAplicacion, lcNombreAplicacionUsuario )
		else
			loServicioAplicaciones = Newobject( "ServicioAplicaciones", "ServicioAplicaciones.prg", "", lcNombreAplicacion, lcNombreAplicacionUsuario )
		endif
		_Screen.Visible = .F.
		loServicioAplicaciones.lMostrarAdnImplant = .t.
		llInstancioAplicacion = loServicioAplicaciones.InstanciarAplicacion( tcRutaScriptEjecucion, llModoSystemStartUp, tcSerie, tcClave, tcSitio )
	endif

Catch To loError
	Local llDesglosar
	llDesglosar = .T.

	do case
		case inlist( loError.Errorno, 1, 1103) 
			loError.Message = 'Hubo un problema al intentar leer los datos, uno o mas archivos necesarios no existen. Consulte con el administrador del sistema.'
		case loError.Errorno = 111
			loError.Message = 'Hubo un problema al intentar leer los datos, uno o mas archivos son de solo lectura. Consulte con el administrador del sistema.'
		case loError.Errorno = 1705
			loError.Message = 'Hubo un problema al intentar leer los datos, no se tiene acceso a uno o mas archivos. Consulte con el administrador del sistema.'
	endcase
						
	If _screen._instanceFactory.LoadReference( "ZooException", "", .f. )
		loEx = Newobject( "ZooException", "ZooException.prg" )
		With loEx
			.Grabar( loError )
		Endwith

		loControlErrores = Newobject( "ControlErrores", "controlErrores.prg" )
		If loControlErrores.EsErrorControlado( loEx )
			If loControlErrores.ControlarError( loEx )
				llDesglosar = .F.
			Endif
		endif
	Else
		loEx = Null
	Endif

	If llDesglosar
		Do DesglosarError With loError, loEx
	Endif

finally
	if vartype( loServicioAplicaciones ) == "O" and pemstatus( loServicioAplicaciones, "lSalioDelSistema", 5 )
		if !loServicioAplicaciones.lSalioDelSistema
			Do SalidaDelSistema
		EndIf	
	else
		Do SalidaDelSistema
	endif
endtry

*-----------------------------------------------------------------------------------------
function VerificarEInstalarPaqueteAdn( tcPaqueteAdn as String ) as VOID
	local loManagerPaqueteADN as PaqueteADN of PaqueteADN.prg, loError as Exception
	
	loManagerPaqueteADN = Newobject( "PaqueteAdn", "PaqueteAdn.prg" )

	if loManagerPaqueteADN.VerificarNombrePaquete( tcPaqueteAdn )
		if loManagerPaqueteADN.TieneQueAplicarcambios( tcPaqueteAdn )
			loManagerPaqueteADN.AplicarCambios( tcPaqueteAdn )
			if !EsIyD()
				loWsh = Createobject( "WScript.Shell" )
*				loWsh.Run( "C:\Dragonfish\ZoologicSA.AdnImplant.exe 2", 1, .F. )
				loWsh.Run( addbs( sys(5) ) + curdir() + "ZoologicSA.AdnImplant.exe", 1, .F. )
			endif
		endif
	else
		if loManagerPaqueteADN.TieneErroresParaLoguear()
			If _screen._instanceFactory.LoadReference( "ZooException", "", .f. )
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					For i = 1 to loManagerPaqueteADN.CantidadErrores()
						loError = createobject( "Exception" )
						loError.Message = loManagerPaqueteADN.MensajeError( i )
						.Grabar( loError )
					Next
				endwith
			Endif
		endif
	endif
	
	loManagerPaqueteADN.Release()
endfunc

*-----------------------------------------------------------------------------------------
Procedure Conf_Sets() As Void
	Close All			&& No se usa la librería porque en esta instancia todavía no está disponible.
	Set Talk Off
	Set Cursor On
	Set Sysmenu Off
	Set Reprocess To 40
	Set Date BRITISH
	Set Decimals To 4
	Set Echo Off
	Set Escape Off
	Set Safety Off
	Set Menu Off
	Set Bell On
	Set Status Off
	Set Hours To 24
	Set Autosave Off
	Set Mouse Off
	Set Exact On
	Set Separator To ","
	Set Point To "."
	Set Century Off
	Set Century to 19 rollover 80
	Set Mark To "/"
	Set Readborder Off
	Set Status Bar Off
	Set Cpdialog Off
	Set ENGINEBEHAVIOR 70
	set ansi on
	_TOOLTIPTIMEOUT = 0
	Deactivate Window ("Standard")

	*----- Soluciona un problema que se presenta en Vista en lista desplegables como combos, list, etc. Al pasar de
	*----- un item a otro queda todo seleccionado como si fuera multiple selección.
	If Val(Os(3)) >= 6
		Declare Integer GdiSetBatchLimit In WIN32API Integer
		GdiSetBatchLimit(1)
	Endif
EndProc

*-----------------------------------------------------------------------------------------
function DesglosarError( toError As Exception, toEx As zooException Of zooExcpetion.prg )
	Local lcError As String, loError As Exception, lnLinea as Integer 

	try
		goMensajes.Alertar( toEx )
	Catch To loError
		lcError = ""

		If vartype( toError.oInformacion ) = "O" and !isnull( toError.oInformacion ) ;
				and upper( toError.oInformacion.class ) = "ZOOINFORMACION" and toError.oInformacion.count > 0
			lnLinea = 1
			for each loItem in toError.oInformacion foxobject
				lcError = lcError + iif( lnLinea > 1, chr( 9 ), "" ) + loItem.cMensaje + chr( 13 ) + chr( 10 )
				lnLinea = lnLinea + 1
			endfor
			MostrarMensaje( lcError , 16, "Zoo Logic - Inicio de la aplicación - Error" )
		else
			if vartype( toError.UserValue ) = "O"
				do DesglosarError with toError.UserValue, toEx
			else
				lcError = lcError + "Error: " + toError.Message + Chr( 13) + ;
					"Nro. Error: " + Transform( toError.ErrorNo ) + Chr( 13 ) + ;
					"Detalle: " + toError.Details + Chr( 13) + ;
					"Procedimiento: " + toError.Procedure + Chr( 13) + ;
					"Linea: " + toError.LineContents + Chr( 13 ) + ;
					"Nro. Linea: " + Transform( toError.Lineno )
		
				MostrarMensaje( lcError , 16, "Zoo Logic - Inicio de la aplicación" )
			endif
		endif
		
	Endtry
endfunc

*-----------------------------------------------------------------------------------------
Function ObtenerFormularioPrincipal As Object
	Local loForm As Object, lnFormus As Integer, i As Integer

	lnForms = _Screen.FormCount
	For i = 1 To lnForms
		If Lower( Alltrim( _Screen.Forms[ i ].Class ) ) = "zooformprincipal"
			loForm = _Screen.Forms[ i ]
		Endif
	Endfor

	Return loForm
Endfunc

*-----------------------------------------------------------------------------------------
Function LevantarDatosDelINI( tcOpcion As String ) As String

	Local loIni As Object, lcIniValor As String, lcSeccion As String, lcSeccion As String, ;
		lcOpcion As String, lcArchivo As String, lnRetorno As Integer, lcRetorno As String

	*!*	 DRAGON 2028
	_screen._instanceFactory.LoadReference('registry.vcx', "Organic.Core.app")
	loIni = Newobject( "OldIniReg", "registry.vcx" )

	Store "" To lcIniValor, lcSeccion, lcOpcion, lcArchivo, lcRetorno
	Store 0 To lnRetorno
	lcSeccion = "SETEOSAPLICACION"
	lcArchivo =  sys(5) + curdir()+ "APLICACION.INI"

	If !File( lcArchivo )	
		MostrarMensaje( "No existe el archivo aplicacion.ini y este es necesario para iniciar la aplicación", 16, "Zoo Logic - Inicio de la aplicación" )
		exit
	endif

	Do Case
		Case Upper( Alltr( tcOpcion ) ) = "NOMBREAPLICACION"
			lcOpcion = "NombreAplicacion"
			lnRetorno = loIni.GetIniEntry( @lcIniValor, lcSeccion, lcOpcion, lcArchivo )
			If lnRetorno = -109
				MostrarMensaje( "Problemas con el archivo APLICACION.INI,en la sección " + lcSeccion + " o la entrada " + lcOpcion + ".", 16, "Zoo Logic - Inicio de la aplicación" )
				llRetorno = .F.
			Else
				lcRetorno = lcIniValor
			Endif

		Case Upper( Alltr( tcOpcion ) ) = "NOMBRECOMERCIAL"
			lcOpcion = "NombreComercial"
			lnRetorno = loIni.GetIniEntry( @lcIniValor, lcSeccion, lcOpcion, lcArchivo )
			lcRetorno = lcIniValor
		
		otherwise
			lcOpcion = tcOpcion
			lnRetorno = loIni.GetIniEntry( @lcIniValor, lcSeccion, lcOpcion, lcArchivo )
			lcRetorno = lcIniValor
	Endcase

	Release loIni

	return lcRetorno
endfunc

*-----------------------------------------------------------------------------------------
function Lanzar() as VOID
	if type( "_screen.Forms(1)" ) == 'O' 
		if upper( alltrim( _screen.Forms(1).name ) ) == upper( alltrim( "frmresumenmodificaciones" ))
			_screen.Forms(1).release
		EndIf	
	endif	

	if vartype( oFormPyR ) == 'O' 
		oFormPyR.show()
		return
	endif

	public oFormPyR

	oFormPyR = _screen.zoo.crearobjeto( "Din_FormPrincipalPARAMETROSEstilo2" )
	oFormPyR.show()
endproc

*-----------------------------------------------------------------------------------------
function LanzarFormularioDuro() as VOID
	lparameters tcFormulario

	lcNombreClase = sys( 2015 )
	if vartype( &lcNombreClase ) == 'O'
		release &lcNombreClase
	endif

	public &lcNombreClase

	&lcNombreClase = _screen.zoo.crearobjeto( tcFormulario )
	if vartype(&lcNombreClase) = "O"
		&lcNombreClase..show(1)
	endif
endfunc

*-----------------------------------------------------------------------------------------
function SalidaDelSistema() as VOID
	Local loError As Exception, loEx as Exception, loControlErrores As Object, lcPath as String, loSalida as Object

	try 

		loSalida = _screen.zoo.crearObjeto( "SalidaUNICASistema" )
		loSalida.Salir()

		set path to &lcPath
	Catch To loError
		Local llDesglosar
		llDesglosar = .T.

		If _screen._instanceFactory.LoadReference( "ZooException", "", .f. )
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
			Endwith

			loControlErrores = Newobject( "ControlErrores", "controlErrores.prg" )
			If loControlErrores.EsErrorControlado( loEx )
				If loControlErrores.ControlarError( loEx )
					llDesglosar = .F.
				Endif
			Endif

		else
			loEx = Null
		Endif

		If llDesglosar
			Do DesglosarError With loError, loEx
		Endif
	endtry
endfunc

*-----------------------------------------------------------------------------------------
function QuedaElBenditoFormulario() as Boolean
	local llRetorno as Boolean

	lnForms = _screen.formcount
	if lnForms = 2
		for i = 1 to lnForms
			if pemstatus( _screen.forms[ i ], "lEsFormularioPrincipal", 5 ) and _screen.forms[ i ].lEsFormularioPrincipal
			else
				if pemstatus( _screen.forms[ i ], "oKontroler", 5 ) and lower( _screen.forms[ i ].oKontroler.class ) =  lower( "KontrolerFrmMensajeDeCerrado" )
					llRetorno = .t.
				endif
			endif
		endfor
	endif
	return llRetorno
endfunc

*-----------------------------------------------------------------------------------------
function ObtenerParametroLancelotParaComparar() as String
	local lcParametroLancelot as String
	
	* MOD( Fecha Julieana / 39 ) * 9 + month(date())*2 + Fecha Julieana + day(date())*3
	lcParametroLancelot = alltrim( str( mod( int( val( sys( 11, date() ) ) ), 39 ) * 9 + month( date() ) * 2 + int( val( sys( 11, date() ) ) ) + day( date() ) * 3 ) )

	return lcParametroLancelot	
endfunc

*-----------------------------------------------------------------------------------------
function MostrarMensaje( tcMessageText, tnDialogBoxType, tcTitleBarText, tnTimeout ) as Integer
	local lcArchivo as String, lcDir as String, lcMensaje as String, llMuestraMensaje as Boolean, lnRetorno as Integer, loEx as Exception
	
	if empty( tnTimeout )
		tnTimeout = 120000 
	endif
	
	if empty( tcTitleBarText ) or vartype( tcTitleBarText ) # "C"
		tcTitleBarText = "Zoo Logic - mensaje al iniciar la aplicación"
	endif
	lcDir = addbs( sys( 5 ) + curdir() ) + "log"
	if !directory( lcDir )
		md ( lcDir )
	endif
	
	if empty( tcMessageText )
		lcMensaje = "Mensaje desconocido -> '" + transform( tcMessageText ) + "' es null: " + transform( isnull( tcMessageText ) )
	else
		lcMensaje = tcMessageText
	endif
	
	lcMensaje = "Inicio aplicación: " + lcMensaje 
	lcArchivo = addbs( lcDir ) + "log.err"

	strtofile( chr(13) + chr(10) + replicate( "*", 81 ) + chr(13) + chr(10) + lcMensaje, lcArchivo, 1 )

	if type( "_screen.zoo" ) == "O" and !isnull( _screen.zoo ) and _screen.zoo.EsBuildAutomatico 
		loEx = Newobject( "Exception" )
		loEx.Message = tcTitleBarText + " - " + lcMensaje
		throw loEx
	else

		try
			if type( "_screen.zoo" ) == "O" and !isnull( _screen.zoo )
				llMuestraMensaje = !_screen.zoo.EsModoSystemStartUp() and _screen.Zoo.UsaCapaDePresentacion()
			else
				llMuestraMensaje = .f.
			endif
		catch
			llMuestraMensaje = .f.
		endtry
	
		if llMuestraMensaje 
			lnRetorno = messagebox( lcMensaje, tnDialogBoxType, tcTitleBarText, tnTimeout )
		else
			lnRetorno = 0
		endif
	endif
	
	return lnRetorno 
endfunc 

*-----------------------------------------------------------------------------------------
function SetearRutaDeLaAplicacionEnDondeEstaElExe() as Void
	local lcDirectorioExe as String
	if !EsIyD()
		&& Esto es exclusivamente para dar soporte a la TaskBar de Windows 7 o superior, para que cuando lanzan un replica de 
		&& la aplicación, esta cambie inmediatamente el path por donde se encuentra instalado el producto.
		&& El path default que indica Windows a la aplicacion es Windows\System y este path no es soportado por la aplicación.
		&& Ademas con este cambio de directorio es posible correr u script organic sin necesidad de estar parado en el path de la aplicación.
		lcDirectorioExe = Justpath( sys(16,1) )
		set default to ( lcDirectorioExe )
	endif
endfunc 

*-----------------------------------------------------------------------------------------
function EsSystemStartUp( tcScript as String ) as Boolean
	local lcTexto as String, llRetorno as Boolean
 
	llRetorno = .f.
	if upper( alltrim( transform( tcScript ) ) ) == "SYSTEMSTARTUP" 
		llRetorno = .t.
	else  
		try
			if file( tcScript )
				lcTexto = upper( filetostr( tcScript ) )
				llRetorno = ( left( lcTexto, 13 ) == "SYSTEMSTARTUP" )
				if ( llRetorno )
					Delete File( tcScript )
				endif
			endif
		catch
		endtry
	endif

	return llRetorno
endfunc 

*-----------------------------------------------------------------------------------------
function EjecutarExtensionDeCodigo( tcRutaScriptEjecucion as String, tcLlamoLancelot as String ) as Void
	local lcArchivoExtension as String, loErrorExtension as exception, loExtension as Object, ;
		lxddsdd as String, loArchivos as Collection

	&& Aca se permite la mutabilidad de la aplicación por permitir código dinamico extensible.
	try
		loArchivos = ObtenerArchivosDeExtensionDeCodigo()
		for each lcArchivoExtension in loArchivos foxObject 

			if file( lcArchivoExtension )
				loExtension = newobject( "zooSystemStartup", lcArchivoExtension )
				lxddsdd = "S" + "TA"
				if loExtension.cVerificador == ( lxddsdd + "RT" + "U" + "P" )
					loExtension.Ejecutar( tcRutaScriptEjecucion, tcLlamoLancelot )
				endif
			endif
			LiberarExtensionDeCodigo()
		endfor
		loArchivos = null
	catch to loErrorExtension
		LiberarExtensionDeCodigo()
		IntentarLoguearErrorEnDisco( loErrorExtension.message, "zooSystemStartup.err" )
	endtry
endfunc 

*-----------------------------------------------------------------------------------------
function LiberarExtensionDeCodigo() as Void
	&& Asegura que los archivos ZooSystemStartup queden sin tomar por si un ItemRPC los quiere renombrar.
	try
		clear class zoosystemstartup
	catch
	endtry
	try
		clear class zoosystemstartup.prg
	catch
	endtry
	try
		clear class zoosystemstartup.fxp
	catch
	endtry
endfunc 

*-----------------------------------------------------------------------------------------
function ObtenerArchivosDeExtensionDeCodigo() as Collection
	local loRetorno as Collection, loErrorArchivosExtensionDeCodigo as Exception, lnCantidad as Integer, i as Integer
	
	loRetorno = null
	
	try
		local array laArchivos[ 1 ]
		loRetorno = newobject( "collection" )
		lnCantidad = adir( laArchivos, "zooSystemStartup*.fxp" )

		asort( laArchivos ) && Ordeno de forma ascendente
		
		for i = 1 to lnCantidad
			loRetorno.Add( laArchivos[ i, 1 ] )
		endfor		
	catch to loErrorArchivosExtensionDeCodigo
		loRetorno = null
		IntentarLoguearErrorEnDisco( loErrorArchivosExtensionDeCodigo.message, "zooSystemStartupGetFiles.err" )
	finally 
		laArchivos = null
	endtry
	
	return loRetorno
endfunc 

*-----------------------------------------------------------------------------------------
function IntentarLoguearErrorEnDisco( tcMensaje as String, tcArchivo as String ) as Void
	local loError as Exception
	try
		strtofile( transform( tcMensaje ) + chr(13) + chr(10), tcArchivo, 1 )
	catch to loError
	endtry
endfunc

*-----------------------------------------------------------------------------------------
function InstanciarDatosDeStartup( tcRutaScriptEjecucion as String, tcLlamoLancelot as String ) as Void
	public goDatosDeStartupDeLaApp as DatosDeStartup of DatosDeStartup.prg
	goDatosDeStartupDeLaApp = newobject( "DatosDeStartup", "DatosDeStartup.prg" )
	goDatosDeStartupDeLaApp.Registrar( 1 )
	goDatosDeStartupDeLaApp.cParametro1DeInicio = tcRutaScriptEjecucion
	goDatosDeStartupDeLaApp.cParametro2DeInicio = tcLlamoLancelot
endfunc 

*-----------------------------------------------------------------------------------------
function PonerVentanaAlFrente( tnHWnd as Integer ) as Void
	declare integer BringWindowToTop in Win32API integer hwnd
	BringWindowToTop( tnHWnd )
	clear dlls "BringWindowToTop"
endfunc

*-----------------------------------------------------------------------------------------
function EsBlanqueo( tcScript as String ) as Boolean
	return inlist( upper( alltrim( transform( tcScript ) ) ), "BLANQUEARSERIE", "BLANQUEARSERIESYSTEM" )
endfunc 

*-----------------------------------------------------------------------------------------
function CrearScript( tcParametroEjecucion as String ) as Void
	local lcNombreArchivoScriptTemp as String, loDatosDeStartupDeLaApp as Object

	lcNombreArchivoScriptTemp = "TMP\" + sys(2015)+  ".sz"
	
	loFactoryScriptsIntegrados = newobject( "FactoryScriptsIntegrados", "FactoryScriptsIntegrados.prg" )

	strtofile( loFactoryScriptsIntegrados.ObtenerScript( tcParametroEjecucion ), lcNombreArchivoScriptTemp )

	return lcNombreArchivoScriptTemp

endfunc
