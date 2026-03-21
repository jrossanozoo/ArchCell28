**********************************************************************
Define Class zTestEspecificacionDeProducto as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestEspecificacionDeProducto of zTestEspecificacionDeProducto.prg
	#ENDIF
	
	*---------------------------------
	Function zTestParametros
		local loError as Exception, lcCursor as string, lcParametro as string
		
		lcCursor = sys( 2015 )
		
		try
			select 0
			use ( addbs( _screen.zoo.cRutaInicial ) + "Adn\Dbc\Parametros" ) shared
			
			lcParametro = "ACTUALIZAR SUBENTIDADES A LRECIBIR"
			select * from Parametros ;
				where upper( alltrim( Parametro ) ) == lcParametro ;
				into cursor ( lcCursor )
			
			this.assertTrue( "El parámetro " + lcParametro + " es inexistente", _tally > 0 )
			this.assertEquals( "El parámetro " + lcParametro + " debe tener como primer ubicación la Sucursal", 1, &lcCursor..Sucursal )
			this.assertEquals( "El parámetro " + lcParametro + " debe tener como segunda ubicación la Organización", 2, &lcCursor..Organizacion )
			this.assertEquals( "El parámetro " + lcParametro + " debe tener como tercera ubicació el Puesto", 3, &lcCursor..Puesto )

			lcParametro = "PAÍS"
			select * from Parametros ;
				where upper( alltrim( Parametro ) ) == lcParametro ;
				into cursor ( lcCursor )
			
			this.assertTrue( "El parámetro " + lcParametro + " es inexistente", _tally > 0 )
			this.assertEquals( "El parámetro " + lcParametro + " debe tener como primer ubicación la Sucursal", 2, &lcCursor..Sucursal )
			this.assertEquals( "El parámetro " + lcParametro + " debe tener como segunda ubicación la Organización", 1, &lcCursor..Organizacion )
			this.assertEquals( "El parámetro " + lcParametro + " debe tener como tercera ubicació el Puesto", 3, &lcCursor..Puesto )
		catch to loError
			throw loError
		finally
			use in select ( "Parametros" )
			use in select( lcCursor )
		endtry
	EndFunc

EndDefine
