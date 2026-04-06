**********************************************************************
Define Class ztestEntidadTalonario As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestEntidadTalonario Of ztestEntidadTalonario.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function TearDown
		use in select( "diccionario" )
	endfunc 


	*---------------------------------
	Function zTestVerificarDiccionario
		local lcCursor as String
		
		use in select( "diccionario" )
		
		select 0
		use ( addbs( _Screen.zoo.cRutaInicial ) + "adn\dbc\diccionario" ) shared

		lcCursor = sys( 2015)
		select * from Diccionario ;
			where upper( alltrim( Entidad ) ) == "TALONARIO" ;
			into cursor ( lcCursor )

		this.assertTrue( "No existe la entidad TALONARIO", _tally > 0 )

		select * from ( lcCursor ) ;
			where upper( alltrim( atributo ) ) not in ( "CODIGO", "NUMERO", "DELEGARNUMERACION", "RESERVARNUMERO", "MAXIMONUMERO" ) and ;
					!GenHabilitar and alta ;
			into cursor c_TestAux
		this.assertEquals( "Todos los atributos menos CODIGO y NUMERO deben tener GenHabilitar = .t. ", 0, _tally )
		
		select * from ( lcCursor ) ;
			where empty( AdmiteBusqueda ) and alta;
			into cursor c_TestAux
		this.assertEquals( "Todos los atributos deben tener AdmiteBusqueda > 0", 0, _tally )
		
		lcAtributo = "ENTIDAD"
		select * from ( lcCursor ) ;
			where alltrim( upper( atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )

		lcAtributo = "CODIGO"
		select * from ( lcCursor ) ;
			where alltrim( upper( atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )

		lcAtributo = "NUMERO"
		select * from ( lcCursor ) ;
			where alltrim( upper( atributo ) ) == lcAtributo ;
			into cursor c_TestAux
		this.assertEquals( "No existe el atributo " + lcAtributo, 1, _tally  )

		use in select( "diccionario" )
		use in select( lcCursor )
		use in select( "c_TestAux" )
	Endfunc

	*---------------------------------
	Function zTestGenHabilitar
		local loEnt as ent_talonario of ent_talonario.prg, lcCursor as string, lcAtributo as string

		if vartype( glCorrerTestDeZL ) = "L"
		Else
			return
		endif
		
		use in select( "diccionario" )
		
		select 0
		use ( addbs( _Screen.zoo.cRutaInicial ) + "adn\dbc\diccionario" ) shared

		lcCursor = sys( 2015)
		select atributo, genhabilitar from Diccionario ;
			where upper( alltrim( Entidad ) ) == "TALONARIO" and not inlist( upper( alltrim( atributo ) ), "TALONARIORELA","NUMERO", "RESERVARNUMERO" ) ;
			into cursor ( lcCursor )
		
		loEnt = _screen.zoo.instanciarentidad( "Talonario" )
		try
			loEnt.Codigo = "TALTEST"
			loent.Eliminar()
		catch
		endtry
		
		select ( lcCursor )
		scan for &lcCursor..GenHabilitar
			lcAtributo = "lHabilitar" + alltrim( Atributo )
			this.assertequals( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Instanciar", .t., loEnt.&lcAtributo )
		endscan
		
		loEnt.Nuevo()

		select ( lcCursor )
		scan for &lcCursor..GenHabilitar
			lcAtributo = "lHabilitar" + alltrim( Atributo )
			this.assertequals( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo", .t., loEnt.&lcAtributo )
		endscan

		loEnt.Formula= "'TALTEST'"
		loent.Grabar()

		
		loEnt.Modificar()

		select ( lcCursor )
		scan for &lcCursor..GenHabilitar
			lcAtributo = "lHabilitar" + alltrim( Atributo )
			this.assertequals( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar", .f., loEnt.&lcAtributo )
		endscan
				
		try
			loEnt.Codigo = "TALTEST"
			loent.Eliminar()
		catch
		endtry
		loEnt.release()
		use in select( "diccionario" )
		use in select( lcCursor )

	endfunc

	*---------------------------------
	Function zTestGrabar
		local loEnt as ent_talonario of ent_talonario.prg, lcCursor as string, lcAtributo as string, lcCodigo as string, ;
			lcAtributo as string, lcTalon as string, loError as Exception
		if vartype( glCorrerTestDeZL ) = "L"
		Else
			return
		endif

		use in select( "diccionario" )
		
		select 0
		use ( addbs( _Screen.zoo.cRutaInicial ) + "adn\dbc\diccionario" ) shared

		lcCursor = sys( 2015)
		select atributo, genhabilitar, TipoDato from Diccionario ;
			where upper( alltrim( Entidad ) ) == "TALONARIO" and alta;
			into cursor ( lcCursor )
		
		loEnt = _screen.zoo.instanciarentidad( "Talonario" )
		try
			loEnt.Codigo = "TALTEST"
			loent.Eliminar()
		catch
		endtry

		lcCodigo = "TALALL"
		lcTalon = "'TALALL'"

		select * from ( lcCursor ) ;
			where upper( alltrim( atributo ) ) not in ( "CODIGO", "NUMERO", "ENTIDAD", "DELEGARNUMERACION", "TALONARIORELA", "RESERVARNUMERO", "MAXIMONUMERO", "ASIGNACION" ) ;
			into cursor c_TestAux
		select c_TestAux
		scan
			lcTalon = lcTalon + "#" + alltrim( c_TestAux.atributo ) + "@"
			lcCodigo = lcCodigo + icase( c_TestAux.TipoDato = "N", "1", c_TestAux.TipoDato = "D", dtoc( date() ), "A" )
		endscan
		
		try
			loEnt.Codigo = lcCodigo
			loent.Eliminar()
		catch
		endtry

		****		
		loEnt.Nuevo()
		loEnt.Formula = "'TALTEST'"
		loEnt.Numero = 400
		
		loent.Grabar()

		this.assertequals( "No se seteo correctamente el TALONARIO", "TALTEST", upper( alltrim( loEnt.Codigo )))

		****		
		loEnt.Nuevo()
		loEnt.Formula = lcTalon 
		loEnt.Numero = 800
		select c_TestAux
		scan
			lcAtributo = alltrim( Atributo )
			loEnt.&lcAtributo = icase( vartype( loEnt.&lcAtributo ) = "N", 1, vartype( loEnt.&lcAtributo ) = "D", date(), "A" )
		endscan
		loent.Grabar()

		****		
		loEnt.Nuevo()
		loEnt.Formula = lcTalon 
		loEnt.Numero = 800
		select c_TestAux
		scan
			lcAtributo = alltrim( Atributo )
			loEnt.&lcAtributo = icase( vartype( loEnt.&lcAtributo ) = "N", 1, vartype( loEnt.&lcAtributo ) = "D", date(), "A" )
		endscan
		
		try
			loent.Grabar()
			this.assertTrue( "Debe dar error", .f. )
		catch to loError
			loInfo = loError.UserValue.ObtenerInformacion() 
			this.assertequals( "El mensaje de error es erroneo" , "EL CÓDIGO " + lcCodigo + " YA EXISTE.", upper( loInfo[1].cMensaje ) )
		endtry
		
		**********
		try
			loEnt.Codigo = "TALTEST"
			loent.Eliminar()
		catch
		endtry

		try
			loEnt.Codigo = lcCodigo
			loent.Eliminar()
		catch
		endtry

		loEnt.release()
		use in select( "diccionario" )
		use in select( lcCursor )
		use in select( "c_TestAux" )
	endfunc
Enddefine
