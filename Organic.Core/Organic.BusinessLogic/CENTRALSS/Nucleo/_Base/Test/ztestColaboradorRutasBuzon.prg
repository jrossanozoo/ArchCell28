define class zTestColaboradorRutasBuzon as FxuTestCase of FxuTestCase.prg
	
	#if .f.
		local this as zTestColaboradorRutasBuzon of zTestColaboradorRutasBuzon.PRG
	#endif
	
	oColaborador = null	

	*-----------------------------------------------------------------
	function setup
		this.oColaborador = _screen.zoo.CrearObjeto( "ColaboradorRutasBuzon" )
	endfunc

	*-----------------------------------------------------------------
	function teardown
		this.oColaborador = null
	endfunc

	*-----------------------------------------------------------------
	function zTestExtraerUnidad_EsDireccionRed
		this.AssertEquals( "Unidad incorrecta.", "", this.oColaborador.ExtraerUnidad( "\\pruebas\Directorio\de\Prueba" ) )
	endfunc

	*-----------------------------------------------------------------
	function zTestExtraerUnidad_NoEsDireccionRed
		this.AssertEquals( "Unidad incorrecta.", "D", this.oColaborador.ExtraerUnidad( "D:\Directorio\de\Prueba" ) )
	endfunc

	*-----------------------------------------------------------------
	function zTestExtraerRuta_EsDireccionRed
		this.AssertEquals( "Ruta incorrecta.", "\\pruebas\Directorio\de\Prueba\", this.oColaborador.ExtraerRuta( "\\pruebas\Directorio\de\Prueba" ) )
	endfunc

	*-----------------------------------------------------------------
	function zTestExtraerRuta_NoEsDireccionRed
		this.AssertEquals( "Ruta incorrecta.", "\Directorio\de\Prueba\", this.oColaborador.ExtraerRuta( "D:\Directorio\de\Prueba" ) )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestArmarRutaBuzon_EsDireccionRed
		this.AssertEquals( "Ruta buzón incorrecta.", "\\test\C$\pruebas\Directorio\de\Prueba\", this.oColaborador.ArmarRutaBuzon( "\\test\C$\pruebas\Directorio\de\Prueba" ) )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestArmarRutaBuzon_NoEsDireccionRed_UnidadDisponible
		_screen.Mocks.AgregarMock( "Colaboradorrutaunidadmapeada" )
		_screen.Mocks.AgregarSeteoMetodo( 'Colaboradorrutaunidadmapeada', 'Obtenerruta', '\\test\C$\pruebas', '[D:]' )
		
		this.AssertEquals( "Ruta buzón incorrecta.", "\\test\C$\pruebas\Directorio\de\Prueba\", this.oColaborador.ArmarRutaBuzon( "D:\Directorio\de\Prueba" ) )
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutaunidadmapeada" )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestArmarRutaBuzon_NoEsDireccionRed_UnidadNoDisponible
		_screen.Mocks.AgregarMock( "Colaboradorrutaunidadmapeada" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutaunidadmapeada", "Obtenerruta", "", "[C:]" )
		
		this.AssertEquals( "Ruta buzón incorrecta.", "C:\Directorio\de\Prueba\", this.oColaborador.ArmarRutaBuzon( "C:\Directorio\de\Prueba" ) )
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutaunidadmapeada" )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestArmarRutaBuzonEnvia_EsDireccionRed
		this.AssertEquals( "Ruta buzón incorrecta.", "\\test\C$\pruebas\Directorio\de\Prueba\BUZTEST\Envia", this.oColaborador.ArmarRutaBuzonEnvia( "", "\\test\C$\pruebas\Directorio\de\Prueba", "BUZTEST" ) )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestArmarRutaBuzonEnvia_NoEsDireccionRed_UnidadDisponible
		_screen.Mocks.AgregarMock( "Colaboradorrutaunidadmapeada" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutaunidadmapeada", "Obtenerruta", "\\test\C$\pruebas", "[D:]" )
		
		this.AssertEquals( "Ruta buzón incorrecta.", "\\test\C$\pruebas\Directorio\de\Prueba\BUZTEST\Envia", this.oColaborador.ArmarRutaBuzonEnvia( "D", "\Directorio\de\Prueba", "BUZTEST" ) )
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutaunidadmapeada" )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestArmarRutaBuzonEnvia_NoEsDireccionRed_UnidadNoDisponible
		_screen.Mocks.AgregarMock( "Colaboradorrutaunidadmapeada" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutaunidadmapeada", "Obtenerruta", "", "[C:]" )
		
		this.AssertEquals( "Ruta buzón incorrecta.", "C:\Directorio\de\Prueba\BUZTEST\Envia", this.oColaborador.ArmarRutaBuzonEnvia( "C", "\Directorio\de\Prueba", "BUZTEST" ) )
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutaunidadmapeada" )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestValidarDirectorio_DirectorioRedInvalido
		local loBuzonMock as object
		
		_screen.Mocks.AgregarMock( "Buzon" )
		_screen.Mocks.AgregarSeteoPropiedad( "Buzon", "Directorio", "\\" + sys(2015) )
		_screen.Mocks.AgregarSeteoMetodo( "Buzon", "Agregarinformacion", .t., "[Es posible que la ubicación no esté bien escrita o bien haya problemas de red.]" )
		_screen.Mocks.AgregarSeteoMetodo( "Buzon", "Cargamanual", .f. )
		
		loBuzonMock = _screen.zoo.InstanciarEntidad( "Buzon" )
		
		this.AssertTrue( "Validación incorrecta.", !this.oColaborador.ValidarDirectorio( loBuzonMock ) )
		_screen.Mocks.VerificarEjecucionDeMocks( "Buzon" )
	endfunc
	
	*-----------------------------------------------------------------
	function ztestValidarDirectorio_DirectorioLocalInvalido
		local loBuzonMock as object
		
		_screen.Mocks.AgregarMock( "Buzon" )
		_screen.Mocks.AgregarSeteoPropiedad( "Buzon", "Directorio", "X:\" + sys(2015) )
		_screen.Mocks.AgregarSeteoMetodo( "Buzon", "Agregarinformacion", .t., "[La carpeta ingresada no existe.]" )
		_screen.Mocks.AgregarSeteoMetodo( "Buzon", "Cargamanual", .f. )
		
		loBuzonMock = _screen.zoo.InstanciarEntidad( "Buzon" )
		
		this.AssertTrue( "Validación incorrecta.", !this.oColaborador.ValidarDirectorio( loBuzonMock ) )
		_screen.Mocks.VerificarEjecucionDeMocks( "Buzon" )
	endfunc

enddefine