**********************************************************************
Define Class zTestZoo as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestZoo of zTestZoo.prg
	#ENDIF

	cProyecto = ""
	
	*-----------------------------------------------------------------------------------------
	function Setup
		this.cProyecto = _screen.zoo.app.cProyecto 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
		_screen.zoo.app.cProyecto = this.cProyecto
	endfunc 

	*-----------------------------------
	function zTestObtenerRutaTemporal
		local lcRutaTemporal as String

		lcRutaTemporal = _screen.Zoo.Obtenerrutatemporal()
		this.asserttrue( "No existe la carpeta temporal", directory( lcRutaTemporal ) )
	endfunc

	*-----------------------------------
	function zTestEliminarRutaTemporal
		local lcRutaTemporal as String, loZoo as Object 
		
		loZoo = newobject( "Zoo", "Zoo.prg" )	
		
		lcRutaTemporal = loZoo.Obtenerrutatemporal()
		md ( lcRutaTemporal + 'Carpetaloca' )
		strtofile( 'hfksjhjafhjkfhjsks', lcRutaTemporal + "pepe.txt" )
		strtofile( 'hfksjhjafhjkfhjsks', lcRutaTemporal + "Carpetaloca\pepedentrodecarpetaloca.txt" )
		this.asserttrue( 'No se creo el archivo Temporal "pepe.txt"', file( lcRutaTemporal + "pepe.txt" ) )
		this.asserttrue( 'No se creo el archivo Temporal "pepedentrodecarpetaloca.txt"', file( lcRutaTemporal + "pepe.txt" ) )		
		this.asserttrue( "No existe la carpeta temporal", !directory( lcRutaTemporal + "Carpetaloca\pepedentrodecarpetaloca.txt" ) )
		loZoo.release()
		this.asserttrue( "No Se Pudo eliminar la carpeta temporal", !Directory( lcRutaTemporal ) )

	endfunc	

	*-----------------------------------
	function zTestObtenerHerenciaDenombre
		local lcArchivo as String, loZoo as Object 
		
		loZoo = newobject( "Zoo", "Zoo.prg" )

		lcArchivo = lozoo.ObtenerHerenciaDenombre( "tra_transferencia,tr2_transferencia,tr3_transferencia,tr4_transferencia", "rio", "consulta" )
		this.assertEquals( "No se esta obteniendo el nombre correctamente(1)", "tra_transferenciarioconsulta" ,lcArchivo )
		
		lcArchivo = lozoo.ObtenerHerenciaDenombre( "tr1_transferencia,tra_transferencia,tr3_transferencia,tr4_transferencia", "rio", "consulta" )
		this.assertEquals( "No se esta obteniendo el nombre correctamente(2)", "tra_transferenciarioconsulta" ,lcArchivo )
		
		lcArchivo = lozoo.ObtenerHerenciaDenombre( "tr1_transferencia,tr2_transferencia,tra_transferencia,tr4_transferencia", "rio", "consulta" )
		this.assertEquals( "No se esta obteniendo el nombre correctamente(3)", "tra_transferenciarioconsulta" ,lcArchivo )
		
		lcArchivo = lozoo.ObtenerHerenciaDenombre( "tr1_transferencia,tr2_transferencia,tr3_transferencia,tra_transferencia", "rio", "consulta" )
		this.assertEquals( "No se esta obteniendo el nombre correctamente(4)", "tra_transferenciarioconsulta" ,lcArchivo )
		
		lcArchivo = lozoo.ObtenerHerenciaDenombre( "tr1_transferencia,tr2_transferencia,tr3_transferencia,tr4_transferencia", "rio", "consulta" )
		this.asserttrue( "No se esta obteniendo el nombre correctamente(5)", empty( lcArchivo ) )

		loZoo.release()

	endfunc	
	
	
	

	*-----------------------------------------------------------------------------------------
	function zTestInstanciarEntidad
		local loEntidad as Object, lcEntidad as string

		lcEntidad = "Rusia"
		loEntidad = _screen.zoo.instanciarentidad( lcEntidad ) 
		this.assertequals( "No se instancio la entidad " + lcentidad, "O", vartype( loEntidad ) )
		this.assertequals( "La entidad instanciada no es de la clase correcta", ;
			"DIN_ENTIDAD" + upper( lcEntidad ), upper(loEntidad.class) )
		this.assertTrue( "No debe existir el ENT de la entidad " + lcEntidad, ;
			!file( "ENT_" + upper( lcEntidad ) + ".prg" ) )
		this.assertTrue( "No debe existir el prg del proyecto (" + lcEntidad + ")", ;
			!file( upper( _screen.zoo.app.cProyecto ) + "_" + upper( lcEntidad ) + ".prg" ) )

		loentidad.release()

		lcEntidad = "Bolivia" 
		loEntidad = _screen.zoo.instanciarentidad( lcEntidad ) 
		this.assertequals( "No se instancio la entidad " + lcentidad, "O", vartype( loEntidad ) )
		this.assertequals( "La entidad instanciada no es de la clase correcta", ;
			"ENT_" + upper( lcEntidad ), upper(loEntidad.class) )
		this.assertTrue( "No debe existir el prg del proyecto (" + lcEntidad + ")", ;
			!file( upper( _screen.zoo.app.cProyecto ) + "_" + upper( lcEntidad ) + ".prg" ) )
	
		loentidad.release()

		_screen.zoo.app.cProyecto = "PROYINEXISTENTE"
		
		lcEntidad = "Alemania"
		loEntidad = _screen.zoo.instanciarentidad( lcEntidad ) 
		this.assertequals( "No se instancio la entidad " + lcentidad, "O", vartype( loEntidad ) )
		this.assertTrue( "No existe el ENT de la entidad " + lcEntidad, file( "ENT_" + upper( lcEntidad ) + ".prg" ) )
		this.assertequals( "La entidad instanciada no es de la clase correcta", ;
				"ENTPROYINEXISTENTE_" + upper( lcEntidad ), upper( loEntidad.class ) )
	
		loentidad.release()

		_screen.zoo.app.cProyecto = this.cProyecto
		
		lcEntidad = "Italia"
		loEntidad = _screen.zoo.instanciarentidad( lcEntidad ) 
		this.assertequals( "No se instancio la entidad " + lcentidad, "O", vartype( loEntidad ) )
		this.assertTrue( "No existe el ENT de la entidad " + lcEntidad, file( "ENT_" + upper( lcEntidad ) + ".prg" ) )
		this.assertequals( "La entidad instanciada no es de la clase correcta", ;
			"ENTNUCLEO_" + upper( lcEntidad ), upper( loEntidad.class ) )
	
		loentidad.release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestInstanciarComponente
		local loComponente as Object, lcComponente as string

		lcComponente = "ComponenteMuralla"
		loComponente = _screen.zoo.instanciarComponente( lcComponente ) 
		this.assertequals( "No se instancio el Componente " + lcComponente, "O", vartype( loComponente ) )
		this.assertequals( "El Componente instanciado no es de la clase correcta", ;
			"DIN_" + upper( lcComponente ), upper(loComponente.class) )
		this.assertTrue( "No debe existir el prg del proyecto (" + lcComponente + ")", ;
			!file( upper( _screen.zoo.app.cProyecto ) + "_" + upper( lcComponente ) + ".prg" ) )

		loComponente.release()

		lcComponente = "ComponenteRio" 
		loComponente = _screen.zoo.instanciarComponente( lcComponente ) 
		this.assertequals( "No se instancio el Componente " + lcComponente, "O", vartype( loComponente ) )
		this.assertequals( "El Componente instanciado no es de la clase correcta", ;
			upper( lcComponente ), upper(loComponente.class) )
		this.assertTrue( "No debe existir el prg del proyecto (" + lcComponente + ")", ;
			!file( upper( _screen.zoo.app.cProyecto ) + "_" + upper( lcComponente ) + ".prg" ) )
	
		loComponente.release()

		_screen.zoo.app.cProyecto = "PROYINEXISTENTE"
		
		lcComponente = "ComponentePrueba"
		loComponente = _screen.zoo.instanciarComponente( lcComponente ) 
		this.assertequals( "No se instancio el Componente " + lcComponente, "O", vartype( loComponente ) )
		this.assertequals( "El Componente instanciado no es de la clase correcta", upper( lcComponente ), upper( loComponente.class ) )
	
		loComponente.release()

		_screen.zoo.app.cProyecto = this.cProyecto
		
		lcComponente = "ComponentePrueba"
		loComponente = _screen.zoo.instanciarComponente( lcComponente ) 
		this.assertequals( "No se instancio El Componente " + lcComponente, "O", vartype( loComponente ) )
		this.assertequals( "El Componente instanciado no es de la clase correcta", ;
			"NUCLEO_" + upper( lcComponente ), upper( loComponente.class ) )
	
		loComponente.release()

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CrearObjetoPorProductoGenerico
		local loZoo as zoo of zoo.prg, loObjeto as Object, lcClase as String, lcRuta as String
		lcRuta = addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba"
		lcClase = sys( 2015 )
		GenerarClase( lcRuta, lcClase )
		loZoo = _screen.zoo.crearobjeto( "Zoo" )
		loObjeto = loZoo.CrearObjetoPorProducto( lcClase )
		this.assertequals( "La clase no se instanció correctamente.", upper( alltrim( lcClase ) ), upper( alltrim( loObjeto.class ) ) )
		loZoo.Release()
		loObjeto = null
		clear class &lcClase
		delete file ( addbs( lcRuta ) + lcClase + ".*" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CrearObjetoPorProductoEspecifico
		local loZoo as zoo of zoo.prg, loObjeto as Object, lcClase as String, lcRuta as String
		lcRuta = addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba"
		lcClase = "NUCLEO_" + sys( 2015 )
		GenerarClase( lcRuta, lcClase )
		loZoo = _screen.zoo.crearobjeto( "Zoo" )
		loObjeto = loZoo.CrearObjetoPorProducto( lcClase )
		this.assertequals( "La clase no se instanció correctamente.", upper( alltrim( lcClase ) ), upper( alltrim( loObjeto.class ) ) )
		loZoo.Release()
		loObjeto = null
		clear class &lcClase
		delete file ( addbs( lcRuta ) + lcClase + ".*" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CrearObjetoPorProductoConUnParametro
		local loZoo as zoo of zoo.prg, loObjeto as Object, lcClase as String, lcRuta as String
		lcRuta = addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba"
		lcClase = "NUCLEO_" + sys( 2015 )
		GenerarClase( lcRuta, lcClase )
		loZoo = _screen.zoo.crearobjeto( "Zoo" )
		loObjeto = loZoo.CrearObjetoPorProducto( lcClase, "", "1" )
		this.assertequals( "La clase no se instanció correctamente 1.", "1", loObjeto.cPar1 )
		this.assertequals( "La clase no se instanció correctamente 2.", .f., loObjeto.cPar2 )
		this.assertequals( "La clase no se instanció correctamente 3.", .f., loObjeto.cPar3 )
		this.assertequals( "La clase no se instanció correctamente 4.", .f., loObjeto.cPar4 )
		this.assertequals( "La clase no se instanció correctamente 5.", .f., loObjeto.cPar5 )
		this.assertequals( "La clase no se instanció correctamente 6.", .f., loObjeto.cPar6 )
		this.assertequals( "La clase no se instanció correctamente 7.", .f., loObjeto.cPar7 )
		this.assertequals( "La clase no se instanció correctamente 8.", .f., loObjeto.cPar8 )
		loZoo.Release()
		loObjeto = null
		clear class &lcClase
		delete file ( addbs( lcRuta ) + lcClase + ".*" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CrearObjetoPorProductoConCuatroParametros
		local loZoo as zoo of zoo.prg, loObjeto as Object, lcClase as String, lcRuta as String
		lcRuta = addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba"
		lcClase = "NUCLEO_" + sys( 2015 )
		GenerarClase( lcRuta, lcClase )
		loZoo = _screen.zoo.crearobjeto( "Zoo" )
		loObjeto = loZoo.CrearObjetoPorProducto( lcClase, "", "1", "2", "3", "4" )
		this.assertequals( "La clase no se instanció correctamente 1.", "1", loObjeto.cPar1 )
		this.assertequals( "La clase no se instanció correctamente 2.", "2", loObjeto.cPar2 )
		this.assertequals( "La clase no se instanció correctamente 3.", "3", loObjeto.cPar3 )
		this.assertequals( "La clase no se instanció correctamente 4.", "4", loObjeto.cPar4 )
		this.assertequals( "La clase no se instanció correctamente 5.", .f., loObjeto.cPar5 )
		this.assertequals( "La clase no se instanció correctamente 6.", .f., loObjeto.cPar6 )
		this.assertequals( "La clase no se instanció correctamente 7.", .f., loObjeto.cPar7 )
		this.assertequals( "La clase no se instanció correctamente 8.", .f., loObjeto.cPar8 )
		loZoo.Release()
		loObjeto = null
		clear class &lcClase
		delete file ( addbs( lcRuta ) + lcClase + ".*" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CrearObjetoPorProductoConOchoParametros
		local loZoo as zoo of zoo.prg, loObjeto as Object, lcClase as String, lcRuta as String
		lcRuta = addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba"
		lcClase = "NUCLEO_" + sys( 2015 )
		GenerarClase( lcRuta, lcClase )
		loZoo = _screen.zoo.crearobjeto( "Zoo" )
		loObjeto = loZoo.CrearObjetoPorProducto( lcClase, "", "1", "2", "3", "4", "5", "6", "7", "8" )
		this.assertequals( "La clase no se instanció correctamente 1.", "1", loObjeto.cPar1 )
		this.assertequals( "La clase no se instanció correctamente 2.", "2", loObjeto.cPar2 )
		this.assertequals( "La clase no se instanció correctamente 3.", "3", loObjeto.cPar3 )
		this.assertequals( "La clase no se instanció correctamente 4.", "4", loObjeto.cPar4 )
		this.assertequals( "La clase no se instanció correctamente 5.", "5", loObjeto.cPar5 )
		this.assertequals( "La clase no se instanció correctamente 6.", "6", loObjeto.cPar6 )
		this.assertequals( "La clase no se instanció correctamente 7.", "7", loObjeto.cPar7 )
		this.assertequals( "La clase no se instanció correctamente 8.", "8", loObjeto.cPar8 )
		loZoo.Release()
		loObjeto = null
		clear class &lcClase
		delete file ( addbs( lcRuta ) + lcClase + ".*" )
	endfunc

EndDefine

*-----------------------------------------------------------------------------------------
function GenerarClase( tcRuta as string, tcNombreClase as String ) as string
	local lcContenidoClase as String
	
	text to lcContenidoClase noshow textmerge
		define class <<tcNombreClase>> as custom
			cPar1 = ""
			cPar2 = ""
			cPar3 = ""
			cPar4 = ""
			cPar5 = ""
			cPar6 = ""
			cPar7 = ""
			cPar8 = ""
			
			*-----------------------------------------------------------------------------------------
			function init( tcPar1 as String, tcPar2 as String, tcPar3 as String, tcPar4 as String, tcPar5 as String , tcPar6 as String, tcPar7 as String, tcPar8 as String ) as boolean
				this.cPar1 = tcPar1
				this.cPar2 = tcPar2
				this.cPar3 = tcPar3
				this.cPar4 = tcPar4
				this.cPar5 = tcPar5
				this.cPar6 = tcPar6
				this.cPar7 = tcPar7
				this.cPar8 = tcPar8
			endfunc

		enddefine
	endtext
	strtofile( lcContenidoClase, addbs( tcRuta ) + tcNombreClase + ".prg" )
endfunc