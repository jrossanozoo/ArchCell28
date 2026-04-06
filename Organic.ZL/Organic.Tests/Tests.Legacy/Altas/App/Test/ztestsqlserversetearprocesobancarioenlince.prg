**********************************************************************
Define Class zTestSqlServerSetearProcesoBancarioenLince as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestSqlServerSetearProcesoBancarioenLince of zTestSetearProcesoBancarioenLince.prg
	#ENDIF
	
	*--------------------------------------------------------------------------------------------------	
	function zTestSqlServerImpactarProcesoBancarioenLince
		local loEntidad as Object, loError as Object, lnCantidadDeRegistros as Number, lcFecha as String 

		loEntidad = newobject( "ZLImpactarProcesoBancarioenLince_Mock" )

        this.agregarmocks("Actualizarzoo") 
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Impactarprocesobancarioenlince', .T. ) 		
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T. )		

		try
			goServicios.Datos.EjecutarSentencias( "delete from DEVBCO where cbu = 'CBUTEST'", "DEVBCO" )
		
			goServicios.Datos.EjecutarSentencias( "Insert into DEVBCO ( numero, razsoc, monto, motivo, cbu, npresen ) values ( 3, '33', 3.3, 'TEST', 'CBUTEST', 33 )", "DEVBCO", "" )
			goServicios.Datos.EjecutarSentencias( "Insert into DEVBCO ( numero, razsoc, monto, motivo, cbu, npresen, impacZL, nrocomprob ) values ( 5, '55', 5.5, 'TEST', 'CBUTEST', 55, datetime(), 555 )", "DEVBCO", "" )

			goServicios.Datos.EjecutarSentencias( "Select numero, impacZL from DEVBCO where cbu = 'CBUTEST'" , "DEVBCO", "", "c_Cursor", set("Datasession") )
			
			select c_Cursor

			count all to lnCantidadDeRegistros for !deleted()
			this.asserttrue( "No se grabó correctamente el registro de test", lnCantidadDeRegistros = 2 )

			locate for numero = 3
			this.asserttrue( "No se encontro el registro con numero 3 en el cursor c_Cursor", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.assertequals( "No se grabó correctamente el registro de test (2)", '', lcFecha )

			locate for numero = 5
			this.asserttrue( "No se encontro el registro con numero 6 en el cursor c_Cursor", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (3)", !empty( lcFecha ) )
 			
		
			loEntidad.Nuevo()
			loEntidad.Grabar()
			
			this.asserttrue( "No pasó por el método 'ImpactarProcesoBancario'", loEntidad.lPasoImpactarProcesoBancario )
			
			goServicios.Datos.EjecutarSentencias("Select numero, impacZL from DEVBCO where cbu = 'CBUTEST'" , "DEVBCO", "", "c_Cursor2", set("Datasession") )

			select c_Cursor2
			count all to lnCantidadDeRegistros for !deleted()
			this.asserttrue( "No se grabó correctamente el registro de test (4)", lnCantidadDeRegistros = 2 )

			locate for numero = 3
			this.asserttrue( "No se encontro el registro con numero 3 en el cursor c_Cursor2", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (5)", !empty( lcFecha ) )

			locate for numero = 5
			this.asserttrue( "No se encontro el registro con numero 6 en el cursor c_Cursor2", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (6)", !empty( lcFecha ) )
	
			loentidad.ultimo()
			loentidad.Eliminar()
			
		catch to loError
			throw loError
		finally
			use in select( "c_Cursor" )
			use in select( "c_Cursor2" )			
			goServicios.Datos.EjecutarSentencias( "delete from DEVBCO where cbu = 'CBUTEST'", "DEVBCO" )
			loEntidad.Release()
		endtry		
	endfunc 

EndDefine

*--------------------------------------------------------------------------------------------------------
define class ZLImpactarProcesoBancarioenLince_Mock as Ent_ZLImpactarEstadoRZenZoo of Ent_ZLImpactarEstadoRZenZoo.PRG

	lPasoImpactarProcesoBancario = .f.
	
	*-----------------------------------------------------------------------------------------
	function ImpactarProcesoBancario() as Boolean
		this.lPasoImpactarProcesoBancario = .t.
		return .t.
	endfunc 
	
enddefine

