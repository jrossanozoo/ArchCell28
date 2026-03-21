**********************************************************************
Define Class ztestzooDataAgrupamiento as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestzooDataAgrupamiento of ztestzooDataAgrupamiento.prg
	#ENDIF
	nDataSessionId	= 0
	cTipoBase = ""
	cSucursalActiva = ""
	*---------------------------------
	Function Setup
		This.nDataSessionId = set( "Datasession" )
		This.cSucursalActiva = _screen.Zoo.App.cSucursalActiva
	EndFunc
	
	*---------------------------------
	Function TearDown
		set datasession to This.nDataSessionId 
		_screen.Zoo.App.cSucursalActiva = This.cSucursalActiva
	EndFunc
	*-----------------------------------------------------------------------------------------
	function ztestDefinirAgrupamiento
		local loZooData as ZooDataAgrupamientos of ZooDataAgrupamientos.Prg
		=CargarDatosBasicos( )
		loZooData = _Screen.zoo.CrearObjeto( "ZooDataAgrupamientos_" + _screen.Zoo.App.TipoDeBase )
		loZooData.cSucursales = ""
		loZooData.DefinirAgrupamiento( "[1]" )
		This.Assertequals ( "no es correcto 1", "PAISES", loZooData.cSucursales )
		loZooData.cSucursales = ""
		loZooData.DefinirAgrupamiento( "COUNTRYS" )
		This.Assertequals ( "no es correcto 2", "COUNTRYS", loZooData.cSucursales )
		loZooData.cSucursales = ""
		loZooData.DefinirAgrupamiento( "[2]" )
		This.Assertequals ( "no es correcto 3", "COUNTRYS,PAISES", loZooData.cSucursales )
		loZooData.Release()
	endfunc

    *-------------------------------------------------------------------------
	function ztestAbrirTablasConAgrupamiento
		local loZooData as ZooDataAgrupamientos of ZooDataAgrupamientos.Prg, lcNombreSucursalPaises as String, lcNombreSucursalCountries as String
        
		=CargarDatosBasicos( )
		_screen.Zoo.App.cSucursalActiva = This.cSucursalActiva
        lcNombreSucursalPaises = upper( goServicios.Librerias.ObtenerNombreSucursal( _screen.Zoo.App.cSucursalActiva ) )
        lcNombreSucursalCountries = upper( goServicios.Librerias.ObtenerNombreSucursal( "COUNTRYS" ) )
		loZooData = _Screen.zoo.CrearObjeto( "ZooDataAgrupamientos_" + _screen.Zoo.App.TipoDeBase )
		loZooData.cSucursales = ""
		loZooData.DefinirAgrupamiento( "[2]" )
		loZooData.AbrirTablaAgrupamientos( "CUBA" )
		set datasession to loZooData.DataSessionId
		select Cuba
		locate for alltrim( Database ) == lcNombreSucursalPaises and CubCod = "XXXXXXX1" and CubNom = "P_CUBANITOSQL 1" 
		This.Asserttrue( "No encontro 1", found() )
		locate for alltrim( Database ) == lcNombreSucursalPaises and CubCod = "XXXXXXX2" and CubNom = "P_CUBANITOSQL 2" 
		This.Asserttrue( "No encontro 2", found() )
		locate for alltrim( Database ) == lcNombreSucursalCountries and CubCod = "XXXXXXX1" and CubNom = "C_CUBANOTESQL 1" 
		This.Asserttrue( "No encontro 3", found() )
		locate for alltrim( Database ) == lcNombreSucursalCountries and CubCod = "XXXXXXX2" and CubNom = "C_CUBANOTESQL 2" 
		This.Asserttrue( "No encontro 4", found() )
		use in select( "Cuba" )
		set datasession to This.nDataSessionId
		loZooData.Release()
	endfunc	
	
EndDefine

*-----------------------------------------------------------------------------------------
function CargarDatosBasicos( ) as Void
	local loEntidad as entidad OF entidad.prg
	loEntidad = _Screen.zoo.instanciarEntidad( "agrupamiento" )
	with loEntidad
		try
			.Codigo = "1"
			.Eliminar()
		catch to loerror
		endtry
		try
			.Codigo = "2"
			.Eliminar()
		catch
		endtry
		.Nuevo()
		.Codigo = "1"
		.BaseDeDatosDetalle.LimpiarItem()
		.BaseDeDatosDetalle.oItem.BaseDeDatos_Pk = "PAISES"
		.BaseDeDatosDetalle.oItem.Incluye = .T.
		.BaseDeDatosDetalle.Actualizar()
		.Grabar()
		.Nuevo()
		.Codigo = "2"
		.BaseDeDatosDetalle.LimpiarItem()
		.BaseDeDatosDetalle.oItem.BaseDeDatos_Pk = "COUNTRYS"
		.BaseDeDatosDetalle.oItem.Incluye = .T.
		.BaseDeDatosDetalle.Actualizar()
		.AgrupamientoDetalle.LimpiarItem()
		.AgrupamientoDetalle.oItem.Agrupamiento_Pk = "1"
		.AgrupamientoDetalle.oItem.Incluye = .T.
		.AgrupamientoDetalle.Actualizar()
		.Grabar()
		.Release()
	endwith
	
		_screen.Zoo.App.cSucursalActiva	 = "PAISES"
        goServicios.Datos.EjecutarSentencias("Delete from Cuba", "Cuba", _screen.zoo.crutaINICIAL + "Paises\dbf\")
		loEntidad = _Screen.zoo.instanciarEntidad( "Cuba" )
		with loEntidad
			.nuevo()
			.Codigo = "1"
			.Nombre = "P_CUBANITOSQL 1"
			.Grabar()
			.nuevo()
			.Codigo = "2"
			.Nombre = "P_CUBANITOSQL 2"
			.Grabar()
			.Release()
		endwith
		_screen.Zoo.App.cSucursalActiva	 = "COUNTRYS"
        goServicios.Datos.EjecutarSentencias("Delete from Cuba", "Cuba", _screen.zoo.crutaINICIAL + "countrys\dbf\")
		loEntidad = _Screen.zoo.instanciarEntidad( "Cuba" )
		with loEntidad
			.nuevo()
			.Codigo = "1"
			.Nombre = "C_CUBANOTESQL 1"
			.Grabar()
			.nuevo()
			.Codigo = "2"
			.Nombre = "C_CUBANOTESQL 2"
			.Grabar()
			.Release()
		endwith

endfunc 
