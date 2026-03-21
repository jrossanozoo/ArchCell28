**********************************************************************
Define Class zTestLanzadorMensajes As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestLanzadorMensajes Of zTestLanzadorMensajes.prg
	#Endif

	*---------------------------------
	Function Setup

	Endfunc

	*---------------------------------
	Function TearDown

	Endfunc

	*---------------------------------
	Function zTestCrearFormularioInformacion
		local loLanzador as LanzadorMensajes of LanzadorMensajes.prg
		
		loLanzador = _screen.zoo.crearobjeto( "LanzadorMensajes" )
				
		loLanzador.CrearFormularioInformacion( 2, 0, "", "Titulo", 0 )

		this.asserttrue( "El formulario no es el esperado", "Forminformacion" $ loLanzador.oForm.Class )

		loLanzador.Release()
	Endfunc

	*---------------------------------
	Function zTestObtenerTitulo
		local loLanzador as LanzadorMensajes of LanzadorMensajes.prg

		loLanzador = _screen.zoo.crearobjeto( "LanzadorMensajes" )
		
		this.assertequals( "El titulo es incorrecto", _Screen.Zoo.App.Nombre, loLanzador.ObtenerTitulo() )

		loLanzador.Release()
	Endfunc
Enddefine
