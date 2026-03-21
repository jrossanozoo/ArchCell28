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
			where upper( alltrim( atributo ) ) not in ( "CODIGO", "DELEGARNUMERACION", "MAXIMONUMERO" ) and ;
					!GenHabilitar and alta;
			into cursor c_TestAux
		this.assertEquals( "Todos los atributos menos CODIGO, NUMERO Y MAXIMONUMERO deben tener GenHabilitar = .t. ", 0, _tally )
		
		select * from ( lcCursor ) ;
			where empty( AdmiteBusqueda ) and alta;
			into cursor c_TestAux
		this.assertEquals( "Todos los atributos deben tener AdmiteBusqueda > 0", 1, _tally )
		
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

		lcAtributo = "RESERVARNUMERO"
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
		local loEnt as ent_talonario of ent_talonario.prg, lcCursor as string, lcAtributo as string, loError as Exception
		
		use in select( "diccionario" )
		select 0
		use ( addbs( _Screen.zoo.cRutaInicial ) + "adn\dbc\diccionario" ) shared

		lcCursor = sys( 2015)
		select atributo, genhabilitar from Diccionario ;
			where upper( alltrim( Entidad ) ) == "TALONARIO" and not inlist( upper( alltrim( atributo )), "TALONARIORELA", "NUMERO", "RESERVARNUMERO" ) ;
			into cursor ( lcCursor )
		
		loEnt = _screen.zoo.instanciarentidad( "Talonario" )
		try
			loEnt.Codigo = "TALTEST"
			loent.Eliminar()
		catch
		endtry
		try
			loEnt.Codigo = "TALP1"
			loent.Eliminar()
		catch
		endtry
		try
			loEnt.Codigo = "TALD1"
			loent.Eliminar()
		catch
		endtry
		try
			loEnt.Codigo = "TALDP11"
			loent.Eliminar()
		catch
		endtry
		
		********
		select ( lcCursor )
		scan for &lcCursor..GenHabilitar
			lcAtributo = "lHabilitar" + alltrim( Atributo )
			this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Instanciar", loEnt.&lcAtributo )
		endscan
		
		********
		loEnt.Nuevo()
		select ( lcCursor )
		scan for &lcCursor..GenHabilitar
			lcAtributo = "lHabilitar" + alltrim( Atributo )
			this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo", loEnt.&lcAtributo )
		endscan


		********
		loEnt.Formula= "'TALP'+#presidente@"
		loEnt.Presidente = "1"
		lcAtributo = "lHabilitarEntidad"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (Presidente)", loEnt.&lcAtributo )
		lcAtributo = "lHabilitarPresidente"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (Presidente)", loEnt.&lcAtributo )
		lcAtributo = "lHabilitarDescripcion"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (Presidente)", !loEnt.&lcAtributo )

		try
			loent.Grabar()
		catch to loError
			loent.release()
			throw loError
		endtry

		loEnt.Modificar()
		lcAtributo = "lHabilitarEntidad"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (Presidente)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarPresidente"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (Presidente)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarDescripcion"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (Presidente)", !loEnt.&lcAtributo )

		********
		loEnt.Cancelar()
		loEnt.Nuevo()
		loEnt.Formula = "'TALD'+#descripcion@"
		loEnt.descripcion = "1"
		lcAtributo = "lHabilitarEntidad"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (descripcion)", loEnt.&lcAtributo )
		lcAtributo = "lHabilitarPresidente"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (descripcion)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarDescripcion"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (descripcion)", loEnt.&lcAtributo )

		try
			loent.Grabar()
		catch to loError
			loent.release()
			throw loError
		endtry

		loEnt.Modificar()
		lcAtributo = "lHabilitarEntidad"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (descripcion)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarPresidente"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (descripcion)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarDescripcion"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (descripcion)", !loEnt.&lcAtributo )

		********
		loEnt.Cancelar()
		loEnt.Nuevo()
		loEnt.Formula = "'TALDP'+#descripcion@+#presidente@"
		loEnt.Presidente = "1"
		loEnt.descripcion = "1"
		lcAtributo = "lHabilitarEntidad"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (descripcion+presidente)", loEnt.&lcAtributo )
		lcAtributo = "lHabilitarPresidente"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (descripcion+presidente)", loEnt.&lcAtributo )
		lcAtributo = "lHabilitarDescripcion"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Nuevo (descripcion+presidente)", loEnt.&lcAtributo )

		try
			loent.Grabar()
		catch to loError
			loent.release()
			throw loError
		endtry

		loEnt.Modificar()
		lcAtributo = "lHabilitarEntidad"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (descripcion+presidente)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarPresidente"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (descripcion+presidente)", !loEnt.&lcAtributo )
		lcAtributo = "lHabilitarDescripcion"
		this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar (descripcion+presidente)", !loEnt.&lcAtributo )

		********
		loEnt.Cancelar()
		loEnt.Nuevo()
		loEnt.Formula = "'TALTEST'"

		try
			loent.Grabar()
		catch to loError
			loent.release()
			throw loError
		endtry

		loEnt.Modificar()

		select ( lcCursor )
		scan for &lcCursor..GenHabilitar
			lcAtributo = "lHabilitar" + alltrim( Atributo )
			this.Asserttrue( "No esta seteado correctamente el GenHabilitar (" + lcAtributo + "). Modificar", !loEnt.&lcAtributo )
		endscan
				
		********
		try
			loEnt.Codigo = "TALTEST"
			loent.Eliminar()
		catch
		endtry
		try
			loEnt.Codigo = "TALP1"
			loent.Eliminar()
		catch
		endtry
		try
			loEnt.Codigo = "TALD1"
			loent.Eliminar()
		catch
		endtry
		try
			loEnt.Codigo = "TALDP11"
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
			lcAtributo as string, lcTalon as string, loError as Exception, loInfo as Object
			
		use in select( "diccionario" )

		select 0
		use ( addbs( _Screen.zoo.cRutaInicial ) + "adn\dbc\diccionario" ) shared

		lcCursor = sys( 2015 )
		select atributo, genhabilitar, TipoDato from Diccionario ;
			where upper( alltrim( Entidad ) ) == "TALONARIO" and alta ;
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

		this.assertequals( "No se seteo correctamente el TALONARIO", "TALTEST", upper( alltrim( loEnt.Codigo ) ) )

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
			this.assertTrue( "Debe dar error al querer duplicar el talonario", .f. )
		catch to loError
			loInfo = loError.UserValue.ObtenerInformacion()
			this.assertequals( "El mensaje de error es erroneo" , "EL CÓDIGO " + lcCodigo + " YA EXISTE.", upper( loInfo[ 1 ].cMensaje ) )
		endtry

		loent.Cancelar()		
		loEnt.Codigo = lcCodigo
		loEnt.Modificar()
		loEnt.Numero = -1
		try
			loent.Grabar()
			this.assertTrue( "Debe dar error al ingresra un numero negativo", .f. )
		catch to loError
			loInfo = loError.UserValue.ObtenerInformacion()
			this.assertequals( "El mensaje de error es erroneo" , "LA NUMERACIÓN DEBE SER MAYOR QUE 0", upper( loInfo.item[ 1 ].cMensaje ) )
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

	*-----------------------------------------------------------------------------------------
	function zTestValidarTalonarioRelacionado
		local loEnt as ent_talonario of ent_talonario.prg, lcCodigo as String ,;
			loError as Exception
		
		loEnt = _screen.zoo.instanciarentidad( "Talonario" )

		lcCodigo = "TAL1"
		try
			loEnt.Codigo = lcCodigo
			loent.Eliminar()
		catch
		endtry
		
		lcCodigo = "TAL2"
		try
			loEnt.Codigo = lcCodigo
			loent.Eliminar()
		catch
		endtry

		loEnt.Nuevo()
		
		with loEnt
			.Formula = "'TAL1'"
			.Grabar()
			
			.Modificar()
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TAL1"
			try
				.Grabar()
				This.asserttrue( "No dio error al grabar un talonario relacionado a este mismo talonario", .f. )
			catch to loError
				This.assertequals( "El mensaje de error no es el correcto.", "EL TALONARIO CARGADO PARA ENUMERAR NO DEBE SER IGUAL AL CODIGO." ,;
						upper( alltrim( loError.UserValue.oInformacion.Item( 1 ).cMensaje ) ) )
			endtry
			
			.Nuevo()
			.Formula = "'TAL2'"
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TAL1"
			.Grabar()


			.Codigo = "TAL1"
			.Modificar()
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TAL2"
			
			try
				.grabar()
				This.asserttrue( "No dio error al grabar un talonario relacionado mediante otro a este mismo talonario", .f. )
			catch to loError
				This.assertequals( "El mensaje de error no es el correcto.", "NO SE PUEDE DELEGAR A UN TALONARIO QUE ESTÁ DELEGADO." ,;
						upper( alltrim( loError.UserValue.oInformacion.Item( 1 ).cMensaje ) ) )

			endtry
			
		endwith
		
		lcCodigo = "TAL1"
		try
			loEnt.Codigo = lcCodigo
			loent.Eliminar()
		catch
		endtry

		lcCodigo = "TAL2"
		try
			loEnt.Codigo = lcCodigo
			loent.Eliminar()
		catch
		endtry
		
		
		with loEnt
			.Nuevo()
			.Formula = "'TAL2'"
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = ""

			try
				.Grabar()
				This.asserttrue( "No tiene que grabar porque falta talonario relacionado.", .f. )
			catch to loError
				This.assertequals( "El mensaje no es el correcto al falta talonario relacionado.", "DEBE CARGAR UN TALONARIO." ,;
					upper( alltrim( loError.UserValue.oInformacion.Item( 1 ).cMensaje ) ) ) 
			endtry

		endwith		
		loEnt.release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestObtenerTalonario
		local loEnt as entidad OF entidad.prg

		loEnt = _screen.zoo.instanciarentidad( "Talonario" )
		with loEnt
			try
				.Codigo = "TAL1"
				.Eliminar()
			catch
			endtry
			try
				.Codigo = "TAL2"
				.Eliminar()
			catch
			endtry
			try
				.Codigo = "TAL3"
				.Eliminar()
			catch
			endtry
			try
				.Codigo = "TAL4"
				.Eliminar()
			catch
			endtry
			
			.nuevo()
			.formula = "'TAL1'"
			
			.grabar()

			.Nuevo()
			.formula = "'TAL2'"
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TAL1"
			.Grabar()
			
			.Nuevo()
			.formula = "'TAL3'"
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TAL1"
			.Grabar()
			
			.Nuevo()
			.formula = "'TAL4'"
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TAL1"
			.Grabar()


			
			lcTalonario = alltrim( .ObtenerTalonario( "TAL1" ) )
			this.assertequals( "El talonario tiene numeracion propia, tiene que ser el mismo el que numero",;
				 "TAL1",lcTalonario )
			 
			lcTalonario = alltrim( .ObtenerTalonario( "TAL2" ) )
			this.assertequals( "El talonario TAL2 NO tiene numeracion propia, numera mediante TAL1",;
				 "TAL1", lcTalonario )
			
			lcTalonario = alltrim( .ObtenerTalonario( "TAL3" ) )
			this.assertequals( "El talonario TAL3 NO tiene numeracion propia, ni tampoco TAL2, numera mediante TAL1",;
				 "TAL1", lcTalonario )
			
			
			loEnt.release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_NoGrabarSiNumeroEsMayorAlMaximo
		local loEnt as ent_talonario OF ent_talonario.prg

		loEnt = _screen.zoo.instanciarentidad( "Talonario" )

		with loEnt

			try
				.Codigo = "TALONARIOTEST"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.formula = "'TALONARIOTEST'"
			.Numero = 11
			.MaximoNumero = 10
			try
				.Grabar()
				This.asserttrue( "No debe poder grabar con el numero mayor al maximo del talonario", .f. )
			catch to loError
				This.assertequals( "El mensaje no es el correcto por numero igual al maximo.", "NO SE PUEDE CARGAR UN TALONARIO CON EL ÚLTIMO NÚMERO (11) MAYOR AL MÁXIMO (10)." ,upper( alltrim( loError.UserValue.oInformacion.Item( 1 ).cMensaje ) ) ) 
			endtry
			
		endwith

		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_EventoInformarTamanioTalonario
		
		local loEnt as ent_talonario OF ent_talonario.prg, loEscucha as escucha of ztestentidadtalonario
		
		loEnt = _Screen.Zoo.InstanciarEntidad( "Talonario" )
		
		loEscucha = newobject( "escucha", "ztestentidadtalonario.prg" )
		
		bindevent( loEnt, "InformarTamanioTalonario", loEscucha, "EscuchaTamanio", 1 )

		with loEnt

			try
				.Codigo = "TALONARIOTEST"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.formula = "'TALONARIOTEST'"
			.Numero = 6
			.MaximoNumero = 10

			.Validar()
			This.asserttrue( "El tamaño del talonario informado es incorrecto.", loEscucha.llamoEvento ) 
			This.assertequals( "El tamaño del talonario informado es incorrecto.", 4 ,loEscucha.tamanio ) 
			
		endwith

		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_EventoNoInformarTamanioTalonarioSiMaximoEstaVacio
		
		local loEnt as ent_talonario OF ent_talonario.prg, loEscucha as escucha of ztestentidadtalonario
		
		loEnt = _Screen.Zoo.InstanciarEntidad( "Talonario" )
		
		loEscucha = newobject( "escucha", "ztestentidadtalonario.prg" )
		
		bindevent( loEnt, "InformarTamanioTalonario", loEscucha, "EscuchaTamanio", 1 )

		with loEnt

			try
				.Codigo = "TALONARIOTEST"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.formula = "'TALONARIOTEST'"
			.Numero = 0
			.MaximoNumero = 0

			.Validar()
			This.asserttrue( "El tamaño del talonario informado es incorrecto.", !loEscucha.llamoEvento ) 
			
		endwith

		loEnt.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarYSetearNumeroInternoCheques
		local loEnt as ent_talonario OF ent_talonario.prg
		
		loEnt = _Screen.zoo.CrearObjeto( "Talonario_Test", "ztestEntidadTalonario.prg" )
		with loEnt
			.Entidad = "CHEQUE"
			.PuntoDeVenta = 1
			.ValidarYSetearNumeroInternoCheques_test()
			This.assertequals( "El número obtenido es incorrecto.", 5, .numero ) 
			.release()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarDuplicidadDeTalonarioEnCheques
		local loEnt as ent_talonario OF ent_talonario.prg, loEx as Object, lcInformacion as String, lcMensaje as String
		
		lcInformacion = ""
		
		loEnt = _Screen.zoo.CrearObjeto( "Talonario_Test", "ztestEntidadTalonario.prg" )
		with loEnt
		
			try
				.Codigo = "CH55"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.Codigo = "CH55"
			.Entidad = "CHEQUE"
			.PuntoDeVenta = 55
			.Numero = 1
			
			try
				if !.ValidarDuplicidadDeTalonarioEnCheques_test()
					loEx = Newobject( 'ZooException', 'ZooException.prg' )
					loEx.oInformacion = loEnt.ObtenerInformacion()
					loEx.Throw()
				endif
			catch to loError
				lcInformacion = loError.uservalue.oinformacion.Item[1].cMensaje
			endtry
		
			.Cancelar()
			.release()
		endwith
		
		lcMensaje = "Ya existe el talonario 22 para la entidad CHEQUE."
		This.assertequals( "El mensaje es incorrecto.", lcMensaje, lcInformacion ) 
	endfunc

Enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class escucha as custom 

	tamanio = 0
	llamoEvento = .f.

	function EscuchaTamanio ( tnTamanio as Integer ) as Void
		this.tamanio = tnTamanio
		this.llamoEvento = .t.
	endfunc

enddefine

define class Talonario_Test as ent_Talonario of ent_Talonario.prg

	*-----------------------------------------------------------------------------------------
	function ValidarYSetearNumeroInternoCheques_test() as Void
		this.ValidarYSetearNumeroInternoCheques()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarDuplicidadDeTalonarioEnCheques_test() as Boolean
		return this.ValidarDuplicidadDeTalonarioEnCheques()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function BuscarUltimoNumeroExistenteParaEntidadSeleccionada( tcEntidadSeleccionada as String, tcPuntoDeVenta as String ) as Integer
		return 5
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTalonarioDeEntidadSeleccionada( tcEntidadSeleccionada as String, tcPuntoDeVenta as String ) as String
		return "22"
	endfunc		

enddefine

