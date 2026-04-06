**********************************************************************
define class ztestentidadtipomodulos as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as ztestentidadtipomodulos of ztestentidadtipomodulos.PRG
	#endif

	*-----------------------------------------------------------------------------------------
	function zTestValidarDatos
		local lcRuta as String, lcTabla as String, loError as zooexception OF zooexception.prg, ;
				loEntidad as entidad OF entidad.prg, lnCantidad as Integer

		use in select('tipomodu')

		*!*	 DRAGON 2028
		goServicios.Datos.EjecutarSentencias( 'delete from tipomodu', 'tipomodu' )

		loEntidad = _screen.zoo.instanciarentidad( "TipoModulos" )
		loEntidad.release()

		Try
			goServicios.Datos.EjecutarSentencias( "select cCod,Descr from tipomodu where cCod = '1' or cCod = '2' or cCod = '3'", ;
				'tipomodu', '', 'c_CursorAuxiliar', set("Datasession") )
			
			select c_CursorAuxiliar
			locate for cCod = '1'
			This.assertequals( "Codigo de registro 1 es incorrecta(1)", "1", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 1 es incorrecta(1)", "Requiere Serie Toma de Inventario", alltrim( c_CursorAuxiliar.Descr ) )
			locate for cCod = '2'
			This.assertequals( "Codigo de registro 2 es incorrecta(1)", "2", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 2 es incorrecta(1)", "Requiere Alta de Grupo de Comunicaciones", alltrim( c_CursorAuxiliar.Descr ) )
			locate for cCod = '3'
			This.assertequals( "Codigo de registro 3 es incorrecta(1)", "3", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 3 es incorrecta(1)", "Centraliza Grupos de Comunicaciones", alltrim( c_CursorAuxiliar.Descr ) )
		catch to loError
			throw loError
		finally
			use in select('c_CursorAuxiliar')
		endtry

		*-- Prueba con la tabla correctamente cargada
		loEntidad = _screen.zoo.instanciarentidad( "TipoModulos" )
		loEntidad.release()

		Try
			goServicios.Datos.EjecutarSentencias( "select cCod,Descr from tipomodu where cCod = '1' or cCod = '2' or cCod = '3'", ;
				'tipomodu', '', 'c_CursorAuxiliar', set("Datasession") )
			
			select c_CursorAuxiliar
			locate for cCod = '1'
			This.assertequals( "Codigo de registro 1 es incorrecta(2)", "1", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 1 es incorrecta(2)", "Requiere Serie Toma de Inventario", alltrim( c_CursorAuxiliar.Descr ) )
			locate for cCod = '2'
			This.assertequals( "Codigo de registro 2 es incorrecta(2)", "2", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 2 es incorrecta(2)", "Requiere Alta de Grupo de Comunicaciones", alltrim( c_CursorAuxiliar.Descr ) )
			locate for cCod = '3'
			This.assertequals( "Codigo de registro 3 es incorrecta(2)", "3", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 3 es incorrecta(2)", "Centraliza Grupos de Comunicaciones", alltrim( c_CursorAuxiliar.Descr ) )
		catch to loError
			throw loError
		finally
			use in select('c_CursorAuxiliar')
		endtry


		*-- Prueba con descripciones Incorrectas

		goServicios.Datos.EjecutarSentencias( "update tipomodu set descr = 'ERROR 1' where ccod = '1'", 'tipomodu', '' )
		goServicios.Datos.EjecutarSentencias( "update tipomodu set descr = 'ERROR 2' where ccod = '2'", 'tipomodu', '' )
		goServicios.Datos.EjecutarSentencias( "update tipomodu set descr = 'ERROR 3' where ccod = '3'", 'tipomodu', '' )

		loEntidad = _screen.zoo.instanciarentidad( "TipoModulos" )
		loEntidad.release()

		Try
			goServicios.Datos.EjecutarSentencias( "select cCod,Descr from tipomodu where cCod = '1' or cCod = '2' or cCod = '3'", ;
				'tipomodu', '', 'c_CursorAuxiliar', set("Datasession") )
			
			select c_CursorAuxiliar
			locate for cCod = '1'
			This.assertequals( "Codigo de registro 1 es incorrecta(3)", "1", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 1 es incorrecta(3)", "Requiere Serie Toma de Inventario", alltrim( c_CursorAuxiliar.Descr ) )
			locate for cCod = '2'
			This.assertequals( "Codigo de registro 2 es incorrecta(3)", "2", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 2 es incorrecta(3)", "Requiere Alta de Grupo de Comunicaciones", alltrim( c_CursorAuxiliar.Descr ) )
			locate for cCod = '3'
			This.assertequals( "Codigo de registro 3 es incorrecta(3)", "3", alltrim( c_CursorAuxiliar.cCod ) )
			This.assertequals( "Descripcion de registro 3 es incorrecta(3)", "Centraliza Grupos de Comunicaciones", alltrim( c_CursorAuxiliar.Descr ) )
		catch to loError
			throw loError
		finally
			use in select('c_CursorAuxiliar')
		endtry


	endfunc 

enddefine
