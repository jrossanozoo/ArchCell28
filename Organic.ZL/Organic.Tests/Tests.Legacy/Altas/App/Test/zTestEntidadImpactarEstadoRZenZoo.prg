**********************************************************************
Define Class zTestEntidadImpactarEstadoRZenZoo as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestEntidadImpactarEstadoRZenZoo of zTestEntidadImpactarEstadoRZenZoo.prg
	#ENDIF
	
	*--------------------------------------------------------------------------------------------------
	Function Setup

	endfunc
	
	*--------------------------------------------------------------------------------------------------	
	function zTestImpactarEstadoRZenZoo
		local loEntidad as Object, loError as Object, lnCantidadDeRegistros as Number, lcFecha as String 

		loEntidad = newobject( "ZLImpactarEstadoRZenZoo_Mock" )

		try
			goServicios.Datos.EjecutarSentencias( "delete from ASESTRZAD where regpor = 'TEST'", "ASESTRZAD" )

			goServicios.Datos.EjecutarSentencias( "Insert into ASESTRZAD ( cestado, cmphoraini, fecha, nrz, regpor ) values ( '1', '11:11:11', datetime(), '00001', 'TEST' )", "ASESTRZAD", "" )
			goServicios.Datos.EjecutarSentencias( "Insert into ASESTRZAD ( cestado, cmphoraini, fecha, nrz, regpor, impacZL, nrocomprob ) values ( '2', '10:10:10', datetime(), '00002', 'TEST', datetime(), 8888 )", "ASESTRZAD", "" )
			
			goServicios.Datos.EjecutarSentencias("Select cestado, impacZL from ASESTRZAD where regpor = 'TEST'", "ASESTRZAD", '', "c_Cursor", set("Datasession") )
			
			select c_Cursor

			count all to lnCantidadDeRegistros for !deleted()
			this.asserttrue( "No se grabó correctamente el registro de test", lnCantidadDeRegistros = 2 )

			locate for cestado = '1'
			this.asserttrue( "No se encontro el registro con cestado 1 en el cursor c_Cursor", found() )
			
			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.assertequals( "No se grabó correctamente el registro de test (2)", '', lcFecha )

			locate for cestado = '2'
			this.asserttrue( "No se encontro el registro con cestado 2 en el cursor c_Cursor", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (3)", !empty( lcFecha ) )

			loEntidad.Nuevo()
			loEntidad.Grabar()

			this.asserttrue( "No pasó por el método 'ImpactarProcesoBancario'", loEntidad.lPasoImpactarProcesoBancario )
					
			goServicios.Datos.EjecutarSentencias("Select cestado, impacZL from ASESTRZAD where regpor = 'TEST'", "ASESTRZAD", "", "c_Cursor2", set("Datasession") )

			select c_Cursor2

			count all to lnCantidadDeRegistros for !deleted()
			this.asserttrue( "No se grabó correctamente el registro de test (4)", lnCantidadDeRegistros = 2 )

			locate for cestado = '1'
			this.asserttrue( "No se encontro el registro con cestado 1 en el cursor c_Cursor2", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (5)", !empty( lcFecha ) )

			locate for cestado = '2'
			this.asserttrue( "No se encontro el registro con cestado 2 en el cursor c_Cursor2", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (6)", !empty( lcFecha ) )
			
			loentidad.ultimo()
			loentidad.Eliminar()
			
		catch to loError
			throw loError
		finally
			use in select( "c_Cursor" )
			use in select( "c_Cursor2" )			
			goServicios.Datos.EjecutarSentencias( "delete from ASESTRZAD where regpor = 'TEST'", "ASESTRZAD" )
			loEntidad.Release()
		endtry		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestImpactarReducMesesTempEnZoo
		
		local loEntidad as Object, loError as Object, lnCantidadDeRegistros as Number, lcFecha as String 

		loEntidad = newobject( "ZLImpactarEstadoRZenZoo_Mock" )

		try
			goServicios.Datos.EjecutarSentencias( "delete from Crmtem where regpor = 'TEST'", "Crmtem" )

			goServicios.Datos.EjecutarSentencias( "Insert into Crmtem ( numero, Razonsoc, regpor, Haltafw ) values ( 1001, '00001', 'TEST', '11:11:11' )", "Crmtem" )
			goServicios.Datos.EjecutarSentencias( "Insert into Crmtem ( numero, Razonsoc, regpor, Haltafw, nrocomprob, impaczl ) values ( 1002, '00001', 'TEST', '22:22:22', 8888, datetime() )", "Crmtem" )
			
			goServicios.Datos.EjecutarSentencias("Select numero, impacZL from Crmtem where regpor = 'TEST'", "Crmtem", "", "c_Cursor", set("Datasession") )
			
			select c_Cursor

			count all to lnCantidadDeRegistros for !deleted()
			this.asserttrue( "No se grabó correctamente el registro de test", lnCantidadDeRegistros = 2 )

			locate for numero = 1001
			this.asserttrue( "No se encontro el registro con numero 1001 en el cursor c_Cursor", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.assertequals( "No se grabó correctamente el registro de test (2)", '', lcFecha )

			locate for numero = 1002
			this.asserttrue( "No se encontro el registro con numero 1002 en el cursor c_Cursor", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (3)", !empty( lcFecha ) )
			
			loEntidad.Nuevo()
			loEntidad.Grabar()

			this.asserttrue( "No pasó por el método 'ImpactarProcesoBancario'", loEntidad.lPasoImpactarProcesoBancario )
			
			goServicios.Datos.EjecutarSentencias("Select numero, impacZL from Crmtem where regpor = 'TEST'", "Crmtem", "", "c_Cursor2", set("Datasession") )

			select c_Cursor2

			count all to lnCantidadDeRegistros for !deleted()
			this.asserttrue( "No se grabó correctamente el registro de test (4)", lnCantidadDeRegistros = 2 )

			locate for numero = 1001
			this.asserttrue( "No se encontro el registro con numero 1001 en el cursor c_Cursor2", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (5)", !empty( lcFecha ) )

			locate for numero = 1002
			this.asserttrue( "No se encontro el registro con numero 1002 en el cursor c_Cursor2", found() )

			lcFecha = alltrim( dtos( goLibrerias.ObtenerFechaFormateada( c_Cursor.impacZL ) ) )
			this.asserttrue( "No se grabó correctamente el registro de test (6)", !empty( lcFecha ) )
			
			loentidad.ultimo()
			loentidad.Eliminar()
			
		catch to loError
			throw loError
		finally
			use in select( "c_Cursor" )
			use in select( "c_Cursor2" )			
			goServicios.Datos.EjecutarSentencias( "delete from Crmtem where regpor = 'TEST'", "Crmtem" )
			loEntidad.Release()
		endtry		
	endfunc
	
EndDefine

*--------------------------------------------------------------------------------------------------------
define class ZLImpactarEstadoRZenZoo_Mock as Ent_ZLImpactarEstadoRZenZoo of Ent_ZLImpactarEstadoRZenZoo.PRG

	lPasoImpactarProcesoBancario = .f.
	
	protected function ImpactarProcesoBancario() as Boolean
		this.lPasoImpactarProcesoBancario = .t.
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerActualizadorZoo() as Object
		return newobject( "MockActualizarZoo" )
	endfunc 	

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class MockActualizarZoo as ActualizarZoo of ActualizarZoo.prg
	*-----------------------------------------------------------------------------------------
	function ImpactarProcesoBancarioenLince( tnNumero as Integer ) as void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MigrarRazonSocial() as Void
	endfunc 
		
enddefine

