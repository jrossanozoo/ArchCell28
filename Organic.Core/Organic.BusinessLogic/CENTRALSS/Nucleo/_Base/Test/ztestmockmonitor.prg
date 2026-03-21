**********************************************************************
Define Class ztestMockMonitor as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestMockMonitor of ztestMockMonitor.prg
	#ENDIF

	*---------------------------------
	Function Setup
	EndFunc
	
	*---------------------------------
	Function TearDown
	EndFunc
	*-----------------------------------------------------------------------------------------
	function zTestRecibir

		local loMockMonitor As Object, llCorrioBien as Boolean

		_Screen.Mocks.Agregarmock( "Proceso" )
		_Screen.Mocks.Agregarmock( "PreparacionSalida" )
		_Screen.Mocks.Agregarmock( "Visualizacion" )
		_screen.mocks.AgregarSeteoMetodo( 'Proceso', 'Ejecutar', 2, '1' )		
		_Screen.Mocks.AgregarSeteoMetodo( "PreparacionSalida", "Ejecutar", 3, '2' )
		_Screen.Mocks.AgregarSeteoMetodo( "Visualizacion", "Ejecutar", '*THROW', '3' )
		loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
		llCorrioBien = .F.
		try 
			loMockMonitor.Recibir( 1 )
		catch
			llCorrioBien = .T.
		endtry
		This.assertTrue( "No corrio en el orden correcto", llCorrioBien )
	
		loMockMonitor.Release()
	endfunc

	
	*-----------------------------------------------------------------------------------------
	function zTestSesionDeDatos
		local loMockMonitor As Object
		
		_Screen.Mocks.Agregarmock( "Proceso" )
		_Screen.Mocks.Agregarmock( "PreparacionSalida" )
		_Screen.Mocks.Agregarmock( "Visualizacion" )
		_screen.mocks.AgregarSeteoMetodo( 'Proceso', 'Ejecutar', 2, '1' )		
		_Screen.Mocks.AgregarSeteoMetodo( "PreparacionSalida", "Ejecutar", 3, '2' )
		_Screen.Mocks.AgregarSeteoMetodo( "Visualizacion", "Ejecutar", '*THROW', '3' )
		loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
		this.assertequals( "La sesion de datos de Visualizacion debe ser Publica", 1, loMockMonitor.Datasession )
		
		loMockMonitor.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestRecibirExportaciones

		local loMockMonitor As Object, llCorrioBien as Boolean, loError as Exception, loObjetoExpotacion as object

		_Screen.Mocks.Agregarmock( "ProcesoExportacion" )
		_Screen.Mocks.Agregarmock( "PreparacionSalidaExportacion" )
		_Screen.Mocks.Agregarmock( "DistribucionExportacion" )
		_screen.mocks.AgregarSeteoMetodo( "ProcesoExportacion", "Ejecutar", "*THROW", "'*OBJETO'" )
		_Screen.Mocks.AgregarSeteoMetodo( "PreparacionSalidaExportacion", "Ejecutar", "*THROW", "2" )
		_Screen.Mocks.AgregarSeteoMetodo( "DistribucionExportacion", "Ejecutar", "*THROW", "'*OBJETO'" )

		loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
		llCorrioBien = .F.		
		loObjetoExpotacion = _Screen.Zoo.CrearObjeto("ObjetoExportacion")
				
		try 
			loMockMonitor.RecibirExportacion( loObjetoExpotacion )
		catch to loError
			llCorrioBien = ( loError.Uservalue.Message =  "Error Generador por Mock Ejecutar('*OBJETO')")
		endtry
		This.assertTrue( "No corrio en el orden correcto 1", llCorrioBien )		

		_screen.mocks.AgregarSeteoMetodo( "ProcesoExportacion", "Ejecutar", 2, "'*OBJETO'" )
		llCorrioBien = .F.
		try 
			loMockMonitor.RecibirExportacion( loObjetoExpotacion )
		catch to loError
			llCorrioBien = ( loError.Uservalue.Message =  "Error Generador por Mock Ejecutar(2)")
		endtry
		This.assertTrue( "No corrio en el orden correcto 2", llCorrioBien )		

		_screen.mocks.AgregarSeteoMetodo( "ProcesoExportacion", "Ejecutar", "'*OBJETO'", "'*OBJETO'" )
		_Screen.Mocks.AgregarSeteoMetodo( "PreparacionSalidaExportacion", "Ejecutar", loObjetoExpotacion , "'*OBJETO'" )
		llCorrioBien = .F.
		try 
			loMockMonitor.RecibirExportacion( loObjetoExpotacion )
		catch to loError
			llCorrioBien = ( loError.Uservalue.Message =  "Error Generador por Mock Ejecutar('*OBJETO')")			
		endtry
		This.assertTrue( "No corrio en el orden correcto 3", llCorrioBien )
		
		_Screen.Mocks.AgregarSeteoMetodo( "DistribucionExportacion", "Ejecutar", 4, "'*OBJETO'" )
		try  
			loMockMonitor.RecibirExportacion( loObjetoExpotacion )
		catch to loError
			This.assertTrue( "No se ejecuto correctamente", .F. )
		endtry
		loMockMonitor.Release()
		
	endfunc

EndDefine