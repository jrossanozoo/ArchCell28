**********************************************************************
define class zTestAutoCompletar as FxuTestCase of FxuTestCase.prg
	#if .f.
		local this as zTestAutoCompletar of zTestAutoCompletar.prg
	#endif


	oAutocompletar = null
	RegistrosUtilizadosPorAutoCompletar = 0
	nDataSessionId = 0
	*--------------------------------------------------------------------------
	function setup
		This.nDataSessionId = set( "Datasession" )
		=IngresarDatos()
		this.oAutocompletar =  _screen.zoo.crearobjeto( "Autocompletar","Autocompletar.prg" )
		this.RegistrosUtilizadosPorAutoCompletar = goRegistry.Nucleo.RegistrosUtilizadosPorAutoCompletar

	endfunc
	*-----------------------------------------------------------------------------------------
	function TearDown()
		
		This.oAUTOCOMPLETAR.oAD.Release()
		this.oAutocompletar.release()
		=BorrarDatos( )
		goRegistry.Nucleo.RegistrosUtilizadosPorAutoCompletar = this.RegistrosUtilizadosPorAutoCompletar
		set datasession to this.nDataSessionId
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestCambioDeHerencia
	
		this.assertequals( "La herencia no es la correcta", "zoosession", lower( this.oAutocompletar.parentclass ) )
		this.asserttrue( "No existe la variable oAD", pemstatus( this.oAutocompletar, "oAD", 5 ) )
		this.oAutocompletar.SetearPropiedades( "Hon","HonNom",".t." )
		do Case
			case _Screen.zoo.App.TipoDeBase = "NATIVA"
				this.assertequals( "La clase del oAd no es la correcta", "din_autocompletardo", lower( this.oAutocompletar.oAd.class ) )
			case _Screen.zoo.App.TipoDeBase = "SQLSERVER"
				this.assertequals( "La clase del oAd no es la correcta", "din_autocompletardosqlserver", lower( this.oAutocompletar.oAd.class ) )
			otherwise
				This.Asserttrue( "TESTEAR !!!!", .F. )
		EndCase		
				
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtener
	
		local lcTexto as String
		this.oAutocompletar.SetearPropiedades( "Hon","HonNom",".t." )			       
		lcTexto = this.oAutocompletar.Obtener( "A" )
		set datasession to this.oAutocompletar.datasessionId
		This.AssertTrue( "Debe estar abierta la tabla", used( "c_honAuto" ) )
		set datasession to this.nDataSessionId

		this.messageout( "Valor Obtenido: " + alltrim(lcTexto) )
		lcTexto = left( upper( lcTexto ), 1 )
		this.Assertequals( "No se obtuvo el texto deseado", "A", lcTexto )
		this.messageout( "Prefijo: " + alltrim( this.oAutocompletar.cPrefijo ) )

		this.oAutocompletar.SetearPropiedades( "Hon","HonNom",".t." )			       
		set datasession to this.oAutocompletar.datasessionId
		This.AssertTrue( "No debe estar abierta la tabla", !used( "c_honAuto" ) )
		set datasession to this.nDataSessionId
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestNoObtener
		local lcTexto as String
		this.oAutocompletar.SetearPropiedades( "Hon","HonNom",".t." )
		lcTexto = this.oAutocompletar.Obtener( "Z" )
		this.messageout( "Valor Obtenido: " + alltrim( lcTexto) )
		this.AssertEquals( "No Tiene que Obtener ningun Valor", "",  lcTexto )
		this.messageout( "Prefijo: " + alltrim(this.oAutocompletar.cPrefijo ) )
	
	endfunc
	
	
	*---------------------------------------------------------------------------------------------------
	function zTestCambioInteractivo
		local lcTexto as string
		
		this.oAutocompletar.SetearPropiedades( "Hon","HonNom","" )
		lcTexto = CodigoClase( "g" ,This )
		this.AssertEquals( "Se paso una g y devolvio " + alltrim( lcTexto ), "GRIS", alltrim( upper( lcTexto ) ) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gr" ,This )
		this.AssertEquals( "Se paso una gr y devolvio " + alltrim( lcTexto ), "GRIS", alltrim( upper( lcTexto ) ) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gri" ,This )
		this.AssertEquals( "Se paso una gri y devolvio " + alltrim( lcTexto ), "GRIS", alltrim( upper( lcTexto ) ) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gris" ,This )
		this.AssertEquals( "Se paso una gris y devolvio " + alltrim( lcTexto ), "GRIS", alltrim( upper( lcTexto ) ) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gris " ,This )
		this.AssertEquals( "Se paso una 'gris ' y devolvio " + alltrim(lcTexto ), "GRIS", alltrim( upper( lcTexto ) ) )
		this.AssertTrue( "Se paso una gris  y devolvio " + alltrim( lcTexto ), "GRIS" = alltrim(lcTexto) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gris " ,This )
		this.AssertEquals( "Se paso una 'gris ' y devolvio " + alltrim( lcTexto ), "GRIS", alltrim( upper( lcTexto ) ) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gris p" ,This )
		this.AssertEquals( "Se paso una 'gris p' y devolvio " + alltrim( lcTexto ), "GRIS PLATA", alltrim( upper( lcTexto ) ) )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )
		lcTexto = CodigoClase( "gris pomo" ,This )
		this.AssertEquals( "No devuelve lo que se esperaba", "" , lcTexto )
		this.messageout( "Prefijo " + alltrim(this.oAutocompletar.cPrefijo ) )

	endfunc

enddefine


*-------------------------------------------------------------------------
function CodigoClase( tcTexto, toObjTest )
	local lnPosicion
	if pcount() = 0
		return .t.
	endif

	with toObjTest

		if len(.oAutocompletar.cPrefijo) = 0
			lcValor = alltrim(tcTexto)
		else

			lcValue = tcTexto
			lnTamanioPrefijo = len( .oAutocompletar.cPrefijo )
			lnPosicion = iif ( .oAutocompletar.cPrefijo $ upper( lcValue ) , lnTamanioPrefijo + 1, lnTamanioPrefijo )
			lcValor = left( lcValue, lnPosicion )

		endif

		lcNuevoValor = alltrim( .oAutocompletar.Obtener( lcValor ) )

		return lcNuevoValor
	endwith
endfunc

*-----------------------------------------------------------------------------------------
Function CrearCursor() As Void
	local lnDatasessionId as Integer lcRetorno as String, loXml as Object, lnDatasession as Integer 
			
	lnDatasession = set( "Datasession" )

	loXml = _screen.zoo.crearobjeto( "ZooXml", "ZooXml.prg" )
	set datasession to loXml.datasessionId
	
	Create Cursor c_HonAuto ( honcod c(5), honnom c(40) )
	Insert Into c_HonAuto Values ( "C01", "ALAMBRE" )
	Insert Into c_HonAuto Values ( "C02", "APACHE" )
	Insert Into c_HonAuto Values ( "C03", "AZUL" )
	Insert Into c_HonAuto Values ( "C04", "BOCA" )
	Insert Into c_HonAuto Values ( "C05", "BANCO" )
	Insert Into c_HonAuto Values ( "C06", "GRIS" )
	Insert Into c_HonAuto Values ( "C06", "GRIS PLATA" )
	
	
	LOCAL loAdapter as XMLAdapter
	loAdapter = CREATEOBJECT( "XMLAdapter" )
	loAdapter.AddTableSchema( "c_HonAuto" )
	loAdapter.ToXML( "c:\xml.txt",,.T. ) 
	
	lcRetorno = filetostr( "c:\xml.txt" )
	
	delete file "c:\xml.txt"
	set datasession to lnDatasession
	return lcRetorno
	
Endfunc

*-----------------------------------------------------------------------------------------
Function IngresarDatos( ) As Void
	BorrarDatos()
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C01', 'ALAMBRE' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C02', 'APACHE' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C03', 'AZUL' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C04', 'BOCA' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C05', 'BANCO' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C06', 'GRIS' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
	goServicios.Datos.EjecutarSentencias( "Insert Into hon ( honcod, honnom ) Values ( 'C07', 'GRIS PLATA' )", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
endfunc

*-----------------------------------------------------------------------------------------
Function BorrarDatos( ) As Void
	goServicios.Datos.EjecutarSentencias( "delete from hon", "hon", goDatos.oAccesoDatos.cRutaTablas + "dbf\" )
Endfunc
