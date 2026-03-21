**********************************************************************
Define Class zTestCrearAplicacionIni As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestCrearAplicacionIni Of zTestCrearAplicacionIni.prg
	#Endif

	*---------------------------------
	Function Setup

	Endfunc

	*---------------------------------
	Function TearDown

	Endfunc

	*---------------------------------
	Function zTestU_ValidarExistencia
		local loTarget as crearAplicacionINI of crearAplicacionINI.prg, lcRuta as string, lcArchivo as string
		
		loTarget = _Screen.zoo.crearobjeto( "CrearAplicacionINI" )
		
		with loTarget
			.cArchivo = "MiArchivo.Ini"
			.cPathArchivoIni = addbs( _screen.zoo.ObtenerRutaTemporal() ) + .cArchivo 

			lcArchivo = .cPathArchivoIni
			
			delete file ( lcArchivo )
		endwith
		
		loTarget.ValidarExistencia( "ruta inicial", "nombre aplicacion", "producto", "nombre aplicacion para usuario" )
		
		this.AssertTrue( "No se creo el archivo", file( lcArchivo ) )

		this.assertequals( "", "ruta inicial", LevantarDatosDelINI(  "DATOS", "RutaDataConfig", lcArchivo ) )
		this.assertequals( "", "nombre aplicacion", LevantarDatosDelINI( "SETEOSAPLICACION", "NombreAplicacion", lcArchivo ) )
		this.assertequals( "", "PRODUCTO", LevantarDatosDelINI( "SETEOSAPLICACION", "NombreProducto", lcArchivo ) )
		this.assertequals( "", "nombre aplicacion para usuario", LevantarDatosDelINI( "SETEOSAPLICACION", "NombreComercial", lcArchivo ) )
		this.assertequals( "", "", LevantarDatosDelINI( "ADNIMPLANT", "RutaZipGenerados", lcArchivo ) )
		this.assertequals( "", ".NET", LevantarDatosDelINI( "ADNIMPLANT", "VERSIONADNIMPLANT", lcArchivo ) )
		
	Endfunc

enddefine

*-----------------------------------------------------------------------------------------
Function LevantarDatosDelINI( tcSeccion as string, tcOpcion As String, tcArchivo as string ) As String

	Local loIni As Object, lcIniValor As String, lcSeccion As String, lcSeccion As String, ;
		lcOpcion As String, lcArchivo As String, lnRetorno As Integer, lcRetorno As String

	loIni = Newobject( "OldIniReg", "registry.vcx" )

	Store "" To lcIniValor, lcSeccion, lcOpcion, lcArchivo, lcRetorno
	Store 0 To lnRetorno

	lnRetorno = loIni.GetIniEntry( @lcIniValor, tcSeccion, tcOpcion, tcArchivo )

	Release loIni

	return lcIniValor

Endfunc

