**********************************************************************
Define Class ztestRegistroDeActividad as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestRegistroDeActividad of ztestRegistroDeActividad.prg
	#ENDIF
	
	oServicio = Null
	
	*---------------------------------
	Function Setup
		this.oServicio = _Screen.zoo.CrearObjeto( "ServicioRegistroDeActividad" )
		this.oServicio.EstaHabilitado() && Se fuerza el buffer y caching.
		
		this.oServicio.lEstaHabilitado = .T.
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerU_Registrar
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		This.oServicio.Registrar( "TEST", "Registrar" )
		This.oServicio.Detener()

		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad", "Registrar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST", alltrim( c_ver.Invocador ) )
		use in select( "c_Ver" )
	endfunc 
 
	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerU_IniciarYFinalizarRegistro
		local lcCodigo as String
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		lcCodigo = This.oServicio.IniciarRegistro( "TEST", "Registrar" )
		This.oServicio.FinalizarRegistro( lcCodigo )
		This.oServicio.Detener()
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad", "Registrar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST", alltrim( c_ver.Invocador ) )
		
		use in select( "c_Ver" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerU_IniciarYFinalizarRegistroConADS
		local lcCodigo as String
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		lcCodigo = This.oServicio.IniciarRegistro( "TEST", "Registrar" )
		This.oServicio.FinalizarRegistro( lcCodigo, "TITO" )
		This.oServicio.Detener()
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad", "Registrar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW", "TITO", alltrim( c_ver.ZADSFW ) )		
		
		use in select( "c_Ver" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerU_IniciarYFinalizarRegistros
		local lcCodigo as String, loCol As zoocoleccion OF zoocoleccion.prg
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		loCol = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST1", "Registrar1" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST2", "Registrar2" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST3", "Registrar3" ) )				
		This.oServicio.FinalizarRegistros( loCOl )
		This.oServicio.Detener()
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad", "Registrar1", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST1", alltrim( c_ver.Invocador ) )
		skip
		This.Assertequals( "No es correcta actividad", "Registrar2", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST2", alltrim( c_ver.Invocador ) )
		skip
		This.Assertequals( "No es correcta actividad", "Registrar3", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST3", alltrim( c_ver.Invocador ) )
		use in select( "c_Ver" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerU_IniciarYFinalizarRegistrosADS
		local lcCodigo as String, loCol As zoocoleccion OF zoocoleccion.prg
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		loCol = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST1", "Registrar1" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST2", "Registrar2" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST3", "Registrar3" ) )				
		This.oServicio.FinalizarRegistros( loCOl, "MANZANA" )
		This.oServicio.Detener()
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad", "Registrar1", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST1", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW", "MANZANA", alltrim( c_ver.ZADSFW ) )				
		skip
		This.Assertequals( "No es correcta actividad", "Registrar2", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST2", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW", "MANZANA", alltrim( c_ver.ZADSFW ) )				
		skip
		This.Assertequals( "No es correcta actividad", "Registrar3", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST3", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW", "MANZANA", alltrim( c_ver.ZADSFW ) )				
		use in select( "c_Ver" )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerU_Iniciar_Eliminar_YFinalizarRegistros
		local lcCodigo as String, loCol As zoocoleccion OF zoocoleccion.prg
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		loCol = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST1", "Registrar1" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST2", "Registrar2" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST3", "Registrar3" ) )				
		This.oServicio.EliminarRegistro( loCOl.Item(2) )

		This.oServicio.FinalizarRegistros( loCOl )
		This.oServicio.Detener()
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad", "Registrar1", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST1", alltrim( c_ver.Invocador ) )
		skip
		This.Assertequals( "No es correcta actividad", "Registrar3", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador", "TEST3", alltrim( c_ver.Invocador ) )
		use in select( "c_Ver" )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerU_Iniciar_EliminarTodos_FinalizarRegistros
		local lcCodigo as String, loCol As zoocoleccion OF zoocoleccion.prg
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		loCol = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST1", "Registrar1" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST2", "Registrar2" ) )
		loCol.Agregar( This.oServicio.IniciarRegistro( "TEST3", "Registrar3" ) )				
		This.oServicio.EliminarRegistros( loCol )
		This.oServicio.FinalizarRegistro()
		This.oServicio.Detener()
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta la cantidad de registros", 0, reccount( "c_Ver" ) )
		use in select( "c_Ver" )
	endfunc 	
EndDefine
