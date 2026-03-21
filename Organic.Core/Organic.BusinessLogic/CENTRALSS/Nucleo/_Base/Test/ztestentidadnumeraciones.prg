**********************************************************************
Define Class ztestEntidadNumeraciones As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestEntidadNumeraciones Of ztestEntidadNumeraciones.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function TearDown
		use in select( "diccionario" )
		use in select( "numeraciones" )
	endfunc 


	*---------------------------------
	Function zTestInstanciar
		local loEnt as ent_Numeraciones of ent_Numeraciones.prg, loError as Exception
					
		loEnt = _Screen.zoo.Instanciarentidad( "Numeraciones" )
		this.assertTrue( "El atributo lLanzarExcepcion debe estar habilitado la inicar la entidad", loEnt.llanzarexcepcion )
		
		loEnt.release()
	endfunc
	
	*---------------------------------
	Function zTestVerificarDiccionario
		local lcCursor as String
		
		use in select( "diccionario" )
		
		select 0
		use ( addbs( _Screen.zoo.cRutaInicial ) + "adn\dbc\diccionario" ) shared

		lcCursor = sys( 2015)
		select * from Diccionario ;
			where upper( alltrim( Entidad ) ) == "NUMERACIONES" and !deleted();
			into cursor ( lcCursor )
		this.assertTrue( "No existe la entidad Numeraciones", _tally > 0 )

		select * from ( lcCursor ) ;
			where upper( alltrim( atributo ) ) not in ( "CODIGO" ) and ;
					( !empty( tabla ) or !empty( campo ) );
			into cursor c_TestAux
		this.assertEquals( "Todos los atributos de la cabecera menos CODIGO deben tener vacio la tabla y el campo", 0, _tally )
		
		lcAtributo = "TALONARIOS"
		select * from ( lcCursor ) ;
			where alltrim( upper( atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )
		this.assertequals( "Error en el dominio del detalle", "DETALLEITEMTALONARIO", upper( alltrim( c_TestAux.Dominio ) ) )
		

		lcAtributo = "CODIGO"
		select * from ( lcCursor ) ;
			where alltrim( upper( atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )

		use in select( lcCursor )
	************
		lcCursor = sys( 2015)
		select * from Diccionario ;
			where upper( alltrim( Entidad ) ) == "ITEMTALONARIO" and !deleted();
			into cursor ( lcCursor )
		this.assertTrue( "No existe la entidad ItemTalonario", _tally > 0 )

		select * from ( lcCursor ) ;
			where upper( alltrim( atributo ) ) not in ( "CODIGO", "NUMERO" ) and !SaltoCampo;
			into cursor c_TestAux
		this.assertEquals( "Todos los atributos del detalle menos NUMERO deben tener SaltoCampo = .t. (At. con Error: " + alltrim( c_TestAux.Atributo ) + ")", 0, _tally )

		lcAtributo = "TALONARIO"
		select a.*, d.Campo as CampoDic, d.Tabla as TablaDic from ( lcCursor ) a ;
			inner join diccionario d on alltrim( upper( d.atributo ) ) == "CODIGO" and ;
				alltrim( upper( d.entidad ) ) == "TALONARIO" ;
			where alltrim( upper( a.atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )
		this.assertequals( "Error en el campo (" + lcAtributo + ")", upper( alltrim( c_TestAux.CampoDic) ), upper( alltrim( c_TestAux.Campo) ) )
		this.assertequals( "Error en la tabla  (" + lcAtributo + ")", upper( alltrim( c_TestAux.TablaDic) ), upper( alltrim( c_TestAux.Tabla) ) )

		lcAtributo = "NUMERO"
		select a.*, d.Campo as CampoDic, d.Tabla as TablaDic from ( lcCursor ) a ;
			inner join diccionario d on alltrim( upper( a.atributo ) ) == alltrim( upper( d.atributo ) ) and ;
				alltrim( upper( d.entidad ) ) == "TALONARIO" ;
			where alltrim( upper( a.atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )
		this.assertequals( "Error en el campo (" + lcAtributo + ")", upper( alltrim( c_TestAux.CampoDic) ), upper( alltrim( c_TestAux.Campo) ) )
		this.assertequals( "Error en la tabla  (" + lcAtributo + ")", upper( alltrim( c_TestAux.TablaDic) ), upper( alltrim( c_TestAux.Tabla) ) )


	****
		select a.*, d.Campo as CampoDic, d.Tabla as TablaDic from ( lcCursor ) a ;
				left join diccionario d on alltrim( upper( a.atributo ) ) == alltrim( upper( d.atributo ) ) and ;
											alltrim( upper( d.entidad ) ) == "TALONARIO" ;
			where alltrim( upper( a.tabla ) ) == "NUMERACIONES" and alltrim( upper( a.Atributo ) ) != "TALONARIO" ;
			into cursor c_TestAux
			
		scan
			lcAtributo = upper( alltrim( c_TestAux.Atributo ) )
			this.assertequals( "Error en el campo (" + lcAtributo + ")", upper( alltrim( c_TestAux.CampoDic) ), upper( alltrim( c_TestAux.Campo) ) )
			this.assertequals( "Error en la tabla  (" + lcAtributo + ")", upper( alltrim( c_TestAux.TablaDic) ), upper( alltrim( c_TestAux.Tabla) ) )
		endscan

		use in select( "diccionario" )
		use in select( lcCursor )
		use in select( "c_TestAux" )
	Endfunc


	*---------------------------------
	Function zTestGrabar
		local loEnt as ent_Numeraciones of ent_Numeraciones.prg
			
		goServicios.Datos.EjecutarSentencias( "delete from numeraciones", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Entidad, Atributo, Talonario, Numero ) values ( 'Nepal','Numero','TAL1', 1 )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Entidad, Atributo, Talonario, Numero ) values ( 'Nepal','Numero','TAL2', 2 )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		loEnt = _Screen.zoo.Instanciarentidad( "Numeraciones" )
		this.assertequals( "No se seteo correctamente el Numeraciones", "O", vartype( loEnt ) )
		
		with loEnt
			.Modificar()
			with .Talonarios
				.CargarItem( 1 )
				.oItem.Numero = 10
				.Actualizar()
			endwith
			.Grabar()
		endwith
		
		goServicios.Datos.EjecutarSentencias( "select * from numeraciones", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\", "numeraciones", set("Datasession") )

		select numeraciones
		locate for alltrim( upper( Talonario ) ) == "TAL1"
		this.assertequals( "No se grabo el número de TAL1", 10, Numeraciones.Numero )
		locate for alltrim( upper( Talonario ) ) == "TAL2"
		this.assertequals( "No se de modificar el número de TAL2", 2, Numeraciones.Numero )
		use in select( "numeraciones" )

		with loEnt
			with .Talonarios
				.CargarItem( 2 )
				.oItem.Numero = 20
				.Actualizar()
			endwith
			.Grabar()
		endwith
		
		goServicios.Datos.EjecutarSentencias( "select * from numeraciones", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\", "numeraciones", set("Datasession") )
		
		locate for alltrim( upper( Talonario ) ) == "TAL1"
		this.assertequals( "No se de modificar el número de TAL1", 10, Numeraciones.Numero )
		locate for alltrim( upper( Talonario ) ) == "TAL2"
		this.assertequals( "No se grabo el número de TAL2", 20, Numeraciones.Numero )
		use in select( "numeraciones" )

		goServicios.Datos.EjecutarSentencias( "select * from IniTal", "IniTal", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\", "IniTal", set("Datasession") )

		select IniTal
		this.assertequals( "No se deben grabar datos en la tabla de la cabecera", 0, reccount() )
		use in select( "IniTal" )

		loEnt.release()

		goServicios.Datos.EjecutarSentencias( "delete from numeraciones", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
	endfunc

	*---------------------------------
	Function zTestAccionesNoPermitidas
		local loEnt as ent_Numeraciones of ent_Numeraciones.prg, loError as Exception
					
		loEnt = _Screen.zoo.Instanciarentidad( "Numeraciones" )
		
		Try
			loent.Nuevo()
			this.asserttrue( "Debe dar error NUEVO", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Nuevo", "NO SE PUEDE HACER NUEVO.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) ) 
		EndTry
		
		Try
			loent.Siguiente()
			this.asserttrue( "Debe dar error SIGUIENTE", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Siguiente", "NO SE PUEDE HACER SIGUIENTE.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) )
		EndTry
		
		Try
			loent.Anterior()
			this.asserttrue( "Debe dar error ANTERIOR", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Previo", "NO SE PUEDE HACER ANTERIOR.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) )
		EndTry

		Try
			loent.Ultimo()
			this.asserttrue( "Debe dar error ULTIMO", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Ultimo", "NO SE PUEDE HACER ULTIMO.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) )
		EndTry
		
		Try
			loent.Primero()
			this.asserttrue( "Debe dar error PRIMERO", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Primero", "NO SE PUEDE HACER PRIMERO.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) )
		EndTry
		
		Try
			loent.Buscar()
			this.asserttrue( "Debe dar error BUSCAR", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Buscar", "NO SE PUEDE HACER BUSCAR.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) )
		EndTry

		Try
			loent.Eliminar()
			this.asserttrue( "Debe dar error ELIMINAR", .f. )
		Catch To loError
			this.assertequals( "El el mensaje de error es incorrecto. Eliminar", "NO SE PUEDE HACER ELIMINAR.", ;
				alltrim( upper( loError.uservalue.oinformacion.Item( 1 ).cMensaje ) ) )
		EndTry

		loEnt.release()
	endfunc	

	*---------------------------------
	Function zTestAccionesNoPermitidas_SinTirarExcpecion
		local loEnt as ent_Numeraciones of ent_Numeraciones.prg, loError as Exception
					
		loEnt = _Screen.zoo.Instanciarentidad( "Numeraciones" )
		loEnt.llanzarexcepcion = .f.
		
		Try
			loent.Nuevo()
		Catch To loError
			this.asserttrue( "No debe dar error NUEVO", .f. )
		EndTry
		
		Try
			loent.Siguiente()
		Catch To loError
			this.asserttrue( "No debe dar error SIGUIENTE", .f. )
		EndTry
		
		Try
			loent.Anterior()
		Catch To loError
			this.asserttrue( "No debe dar error ANTERIOR", .f. )
		EndTry

		Try
			loent.Ultimo()
		Catch To loError
			this.asserttrue( "No debe dar error ULTIMO", .f. )
		EndTry
		
		Try
			loent.Primero()
		Catch To loError
			this.asserttrue( "No debe dar error PRIMERO", .f. )
		EndTry
		
		Try
			loent.Buscar()
		Catch To loError
			this.asserttrue( "No debe dar error BUSCAR", .f. )
		EndTry

		Try
			loent.Eliminar()
		Catch To loError
			this.asserttrue( "No debe dar error ELIMINAR", .f. )
		EndTry

		loEnt.release()
	endfunc	
	*-----------------------------------------------------------------------------------------
	Function zTestCargar
		local loEnt as ent_Numeraciones of ent_Numeraciones.prg, loError as Exception
		
		goServicios.Datos.EjecutarSentencias( "delete from numeraciones", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Talonario, Numero, taloRela ) values ( 'TAL1', 1 , '' )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Talonario, Numero, taloRela ) values ( 'TAL2', 1 , '' )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Talonario, Numero, taloRela ) values ( 'TAL3', 1 , '' )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Talonario, DelegNum , Numero, taloRela ) values ( 'TAL4', .t., 0 , 'TAL1' )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( Talonario, DelegNum , Numero, taloRela ) values ( 'TAL5', .t., 0 , 'TAL2' )", "numeraciones", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		
		loEnt = _Screen.zoo.Instanciarentidad( "Numeraciones" )
		loEnt.Cargar()

		This.assertequals( "La cantidad de talonarios cargados no es la correcta." , 3 , loEnt.Talonarios.count )

		loEnt.Release()

	endfunc 


Enddefine
