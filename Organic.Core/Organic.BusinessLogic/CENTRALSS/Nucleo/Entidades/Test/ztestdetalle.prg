**********************************************************************
Define Class zTestDetalle as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestDetalle of zTestDetalle.prg
	#ENDIF
	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loDetalle as Collection
		
		loDetalle = newobject( "TestDetalle" )
		this.assertequals( "No se instancio el detalle", "O",  vartype( loDetalle ) )
		This.Asserttrue( "Mal seteada la propiedad lVerificarLimitesEnDisenoImpresion", !loDetalle.lVerificarLimitesEnDisenoImpresion )
		lodetalle.release()
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function zTestLimpiar
		local loDetalle as detalle of detalle.prg
		
		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRUSIARepublicas" )
		loDetalle.inicializar()
		with loDetalle
			.LimpiarItem()
			.oItem.Nombre = "REP1"
			.oItem.Descripcion = "DESC REP1"
			.Actualizar()
			.LimpiarItem()
			.oItem.Nombre = "REP2"
			.oItem.Descripcion = "DESC REP2"
			.Actualizar()

			.Limpiar()
		endwith

		This.Assertequals( "la coleccion de agrupamientos no se limpio", 0, loDetalle.oColAgrupamientos.Count )
		this.assertequals( "No se eliminaron los items", 0, loDetalle.count )	
		this.assertequals( "No se vacio el item activo (nom)", "", loDetalle.oItem.Nombre )
		this.assertequals( "No se vacio el item activo (desc)", "", loDetalle.oItem.Descripcion )

		loDetalle.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestActualizar
		local loDetalle as detalle of detalle.prg, loObjeto as Object
		
		loObjeto = newobject( "ObjetoBindeoTest" )
		
		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRUSIARepublicas" )
		loDetalle.inicializar()
		bindevent( loDetalle, "CambioSumarizado", loObjeto, "CambioSumarizado", 1 )
		
		with loDetalle
			loObjeto.lEjecuto = .f.
			.LimpiarItem()
			.oItem.Nombre = "REP1"
			.oItem.Descripcion = "DESC REP1"
			.Actualizar()

			this.assertequals( "No se eliminaron los items", 1, loDetalle.count )	
			this.assertequals( "No se vacio el item activo (nom) 1", "REP1", loDetalle[ 1 ].Nombre )
			this.assertequals( "No se vacio el item activo (desc) 1", "DESC REP1", loDetalle[ 1 ].Descripcion )
			this.assertequals( "Se disparo el evento CambioSumarizado 1", .t., !loObjeto.lEjecuto )

			loObjeto.lEjecuto = .f.
			.LimpiarItem()
			.oItem.Nombre = "REP2"
			.oItem.Descripcion = "DESC REP2"
			.Actualizar()

			this.assertequals( "No se eliminaron los items", 2, loDetalle.count )	
			this.assertequals( "No se vacio el item activo (nom) 2", "REP2", loDetalle[ 2 ].Nombre )
			this.assertequals( "No se vacio el item activo (desc) 2", "DESC REP2", loDetalle[ 2 ].Descripcion )
			this.assertequals( "Se disparo el evento CambioSumarizado 2", .t., !loObjeto.lEjecuto )

			loObjeto.lEjecuto = .f.
			.CargarItem( 1 )
			.oItem.Nombre = "REP3"
			.oItem.Descripcion = "DESC REP3"
			.Actualizar()

			this.assertequals( "No se eliminaron los items", 2, loDetalle.count )	
			this.assertequals( "No se vacio el item activo (nom) 3", "REP3", loDetalle[ 1 ].Nombre )
			this.assertequals( "No se vacio el item activo (desc) 3", "DESC REP3", loDetalle[ 1 ].Descripcion )
			this.assertequals( "Se disparo el evento CambioSumarizado 3", .t., !loObjeto.lEjecuto )

		endwith
		loDetalle.release()

		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleCanadaDetallecanada" )
		loDetalle.inicializar()
		bindevent( loDetalle, "CambioSumarizado", loObjeto, "CambioSumarizado", 1 )
		bindevent( loDetalle, "Sumarizar", loObjeto, "Sumarizar", 1 )
		bindevent( loDetalle, "Totalizar", loObjeto, "Totalizar", 1 )
		bindevent( loDetalle, "Acumular", loObjeto, "Acumular", 1 )
		with loDetalle
			loObjeto.lEjecuto = .f.
			.LimpiarItem()
			.oItem.Nombre = "TORONTO"
			.oItem.Gobernador = "IRON JOHN"
			.oItem.Codigo = 1
			this.assertequals( "e disparo el evento Totalizar 1", .t., !loObjeto.lEjecutoTotalizar )
			.oItem.Cantidad = 1
			this.assertequals( "No se disparo el evento Acumular 1", .t., loObjeto.lEjecutoAcumular )
			.oItem.Precio = 10
			.Actualizar()

			this.assertequals( "No se eliminaron los items", 1, loDetalle.count )	
			this.assertequals( "No se vacio el item activo (nom) 1", "TORONTO", loDetalle[ 1 ].Nombre )
			this.assertequals( "No se vacio el item activo (desc) 1", "IRON JOHN", loDetalle[ 1 ].Gobernador )
			this.assertequals( "No se disparo el evento Sumarizar 1", .t., loObjeto.lEjecutoSumarizar )


			loObjeto.lEjecuto = .f.
			loObjeto.lEjecutoSumarizar = .f.
			loObjeto.lEjecutoTotalizar = .f.
			loObjeto.lEjecutoAcumular = .f.
			.LimpiarItem()
			.oItem.Nombre = "ALBERTA"
			.oItem.Gobernador = "RAUL"
			.oItem.Codigo = 1
			this.assertequals( "e disparo el evento Totalizar 2", .t., !loObjeto.lEjecutoTotalizar )
			.oItem.Cantidad = 1
			this.assertequals( "No se disparo el evento Acumular 2", .t., loObjeto.lEjecutoAcumular )
			.oItem.Precio = 10
			.Actualizar()

			this.assertequals( "No se eliminaron los items", 2, loDetalle.count )	
			this.assertequals( "No se vacio el item activo (nom) 2", "ALBERTA", loDetalle[ 2 ].Nombre )
			this.assertequals( "No se vacio el item activo (desc) 2", "RAUL", loDetalle[ 2 ].Gobernador )
			this.assertequals( "No se disparo el evento Sumarizar 2", .t., loObjeto.lEjecutoSumarizar )

			loObjeto.lEjecuto = .f.
			loObjeto.lEjecutoSumarizar = .f.
			loObjeto.lEjecutoTotalizar = .f.
			loObjeto.lEjecutoAcumular = .f.
			.CargarItem( 1 )
			.oItem.Nombre = "LONDON"
			.oItem.Gobernador = "JUAN"
			.oItem.Codigo = 1
			this.assertequals( "e disparo el evento Totalizar 3", .t., !loObjeto.lEjecutoTotalizar )
			.oItem.Cantidad = 1
			this.assertequals( "Se disparo el evento Acumular 3", .t., !loObjeto.lEjecutoAcumular )
			.oItem.Cantidad = 2
			this.assertequals( "No se disparo el evento Acumular 3", .t., loObjeto.lEjecutoAcumular )
			.oItem.Precio = 10
			.Actualizar()

			this.assertequals( "No se eliminaron los items", 2, loDetalle.count )	
			this.assertequals( "No se vacio el item activo (nom) 3", "LONDON", loDetalle[ 1 ].Nombre )
			this.assertequals( "No se vacio el item activo (desc) 3", "JUAN", loDetalle[ 1 ].Gobernador )
			this.assertequals( "No se disparo el evento Sumarizar 3", .t., loObjeto.lEjecutoSumarizar )

		endwith
		loDetalle.release()
		loObjeto.destroy()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarUnicidadDetalle
		local loEntidad as entidad of entidad.prg, llValidacion as Boolean
		
		_screen.mocks.agregarmock( "Numeraciones" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Setearentidad', .T., "'*OBJETO'" )

		loEntidad = _Screen.zoo.instanciarentidad( "Rusia" )
		with loEntidad.Republicas
			llValidacion = .Validar()
			This.AssertTrue ( "Error al validar. La entidad rusia no tiene unicidad de detalle", llValidacion )
		endwith
		loEntidad.release()
		loEntidad = _Screen.zoo.instanciarentidad( "LETONIA" )
		with loEntidad.Habitantes
		
			.LimpiarItem()
			with .oItem
				.Nombre = "PEPE"
				.Color = "CO1"
				.Edad = 15
			endwith
			.Actualizar()

			.LimpiarItem()
			with .oItem
				.Nombre = "JUAN"
				.Color = "CO2"
				.Edad = 17
			endwith
			.Actualizar()
			llValidacion = .Validar()
			This.AssertTrue ( "LA validacion debe ser correcta", llValidacion )
		
			.LimpiarItem()
			with .oItem
				.Nombre = "JUAN"
				.Color = "CO3"
				.Edad = 17
			endwith
			.Actualizar()

			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser incorrecta si solo se repite uno de los atributos de unicidad", ;
				llValidacion )

			.LimpiarItem()
			with .oItem
				.Nombre = "JUAN"
				.Color = "CO2"
				.Edad = 17
			endwith
			.Actualizar()

			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser incorrecta", !llValidacion )

			.Remove( 4 )
			.LimpiarItem()
			.Actualizar( )
			
			.LimpiarItem()
			.Actualizar( )
		
			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser correcta al agregar dos items en blanco", llValidacion )
			
		endwith
				
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarUnicidadDetalle_ArregloProblemaSiHayEspaciosEnLosExtremos
		local loEntidad as entidad of entidad.prg, llValidacion as Boolean
		
		_screen.mocks.agregarmock( "Numeraciones" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Setearentidad', .T., "'*OBJETO'" )

		loEntidad = _Screen.zoo.instanciarentidad( "Rusia" )
		with loEntidad.Republicas
			llValidacion = .Validar()
			This.AssertTrue ( "Error al validar. La entidad rusia no tiene unicidad de detalle", llValidacion )
		endwith
		loEntidad.release()
		loEntidad = _Screen.zoo.instanciarentidad( "LETONIA" )
		with loEntidad.Habitantes
		
			.LimpiarItem()
			with .oItem
				.Nombre = "PEPE"
				.Color = "CO1"
				.Edad = 15
			endwith
			.Actualizar()

			.LimpiarItem()
			with .oItem
				.Nombre = "JUAN"
				.Color = "CO2"
				.Edad = 17
			endwith
			.Actualizar()
			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser correcta si los valores son distintos", llValidacion )
		
			.LimpiarItem()
			with .oItem
				.Nombre = "JUAN"
				.Color = "CO3"
				.Edad = 17
			endwith
			.Actualizar()

			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser incorrecta si solo se repite uno de los atributos de unicidad", llValidacion )

			with .oItem
				.Nombre = " JUAN"
			endwith
			.Actualizar()

			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser correcta si hay espacios a la izquierda", llValidacion )

			.LimpiarItem()
			with .oItem
				.Nombre = "JUAN   "
				.Color = "CO2"
				.Edad = 17
			endwith
			.Actualizar()

			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser incorrecta si hay espacios a la derecha", !llValidacion )

			.Remove( 4 )
			.LimpiarItem()
			.Actualizar( )
			
			.LimpiarItem()
			.Actualizar( )
		
			llValidacion = .Validar()
			This.AssertTrue ( "La validacion debe ser correcta al agregar dos items en blanco", llValidacion )
			
		endwith
				
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCantidadItems
		local loDetalle as detalle of detalle.prg, llTiroExcepcion as Boolean
		
		llTiroExcepcion = .f.

		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRUSIARepublicas" )
		loDetalle.inicializar()
		loDetalle.nCantidadItems = 10
		for i = 1 to loDetalle.nCantidadItems
			with loDetalle
				.LimpiarItem()
				.oItem.Nombre = "REP" + transform( i, '99' )
				.oItem.Descripcion = "DESC REP" + transform( i, '99' )
				.Actualizar()
			endwith
		endfor

		with loDetalle
			.LimpiarItem()
			.oItem.Nombre = "REP" + transform( i, '99' )
			.oItem.Descripcion = "DESC REP" + transform( i, '99' )
			try
				.Actualizar()
			catch to loError
				this.assertequals( "El mensaje de error no es el esperado.", loError.UserValue.oInformacion.item( 1 ).cMensaje, ;
									"La cantidad de líneas supera a la permitida. Deberá realizar otro comprobante para completar la operación." )
				llTiroExcepcion = .t.
			endtry
		endwith


		this.AssertTrue( "No arrojo excepcion al agregar un item de más que el máximo posible.", llTiroExcepcion )
		
		loDetalle.Release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarUnicidadAlGrabar
		local loEntidad As Entidad of Entidad.prg, llEncontro as Boolean, loError as Exception, lcError as String
				
		_screen.mocks.agregarmock( "Numeraciones" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Setearentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Grabar', 0, "'Numero'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenernumero', 0, "'Numero'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenerservicio', .T., "'Numero'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenerservicio', .f., "'Codigo'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenernumero', 0, "'Codigo'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Grabar', 1, "'Codigo'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Ultimonumero', 0, "'Codigo'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Talonarioconnumeraciondisponible', .T. )

		loEntidad = _Screen.Zoo.Instanciarentidad ( "Letonia" )
		with loEntidad
			llEncontro = .t.
			try
				.Codigo = 1
			catch
				llEncontro = .f.
			endtry
			if llEncontro
				.Eliminar()
			endif
			
			llEncontro = .t.
			try
				.Codigo = 2
			catch
				llEncontro = .f.
			endtry
			if llEncontro
				.Eliminar()
			endif

			.Nuevo()
			
			.Codigo = 1
			.Descripcion = "1"

			with .Habitantes
				.LimpiarItem()
				with .oItem
					.Nombre = "GO1"
					.Color = "NOM1"
				endwith
				.Actualizar()

				.LimpiarItem()
				with .oItem
					.Nombre = "GO1"
					.Color = "NOM1"
				endwith
				.Actualizar()
			endwith

			llGrabo = .T.
			try 
				.Grabar()
			catch 
				llGrabo = .F.	
			endtry
			This.AssertTrue( "No debio grabar por no haber unicidad en el detalle", !llGrabo )
			.Cancelar()
			
			.Nuevo()
			.Descripcion = "1"
			.Codigo = 1
			with .Habitantes
				.LimpiarItem()
				with .oItem
					.Nombre = "GO1"
					.Color = "NOM1"
				endwith
				.Actualizar()

				.LimpiarItem()
				with .oItem
					.Nombre = "GO2"
					.Color = "NOM2"
				endwith
				.Actualizar()
			endwith

			lcError = ""
			llGrabo = .T.
			try 
				.Grabar()
			catch to loError
				llGrabo = .F.
				lcError = loError.UserValue.message
				.Cancelar()
			endtry
			This.AssertTrue( "Debio grabar por haber unicidad en el detalle (" + lcError + ")", llGrabo )
			
			****

			_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenernumero', 1, "'Codigo'" )
			_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Grabar', 2, "'Codigo'" )
			_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Ultimonumero', 1, "'Codigo'" )
			
			.Nuevo()
			.Descripcion = "2"
			.Codigo = 2
			with .Habitantes
				.LimpiarItem()
				with .oItem
					.Nombre = ""
					.Color = ""
				endwith
				.Actualizar()

				.LimpiarItem()
				with .oItem
					.Nombre = "GO1"
					.Color = "NOM2"
				endwith
				.Actualizar()

				.LimpiarItem()
				with .oItem
					.Nombre = "GO1"
					.Color = "NOM1"
				endwith
				.Actualizar()
			endwith

			lcError = ""
			llGrabo = .T.
			try 
				.Grabar()
			catch to loError
				llGrabo = .F.	
				lcError = loError.UserValue.message
			endtry
			This.AssertTrue( "Debio grabar por haber unicidad en el detalle 1. (" + lcError + ")", llGrabo )
		endwith
		loEntidad.Release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestCargaManual
		local loDetalle As Detalle of Detalle.Prg
		loDetalle = newobject( "AuxCargaMAnual" )
		loDetalle.lCargando = .T.
		loDetalle.lLimpiando = .T.
		loDetalle.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .T., lDestroy = .T.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .T.
		loDetalle.lLimpiando = .F.
		loDetalle.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .F., lDestroy = .T.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .T.
		loDetalle.lLimpiando = .T.
		loDetalle.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .T., lDestroy = .F.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .T.
		loDetalle.lLimpiando = .F.
		loDetalle.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .F., lDestroy = .F.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .F.
		loDetalle.lLimpiando = .T.
		loDetalle.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .T., lDestroy = .T.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .F.
		loDetalle.lLimpiando = .F.
		loDetalle.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .F., lDestroy = .T.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .F.
		loDetalle.lLimpiando = .T.
		loDetalle.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .T., lDestroy = .F.", !loDetalle.CargaManual() )
		loDetalle.lCargando = .F.
		loDetalle.lLimpiando = .F.
		loDetalle.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .F., lDestroy = .F.", loDetalle.CargaManual() )
		loDetalle = Null
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestValidarItem 
		Local loDetalle as detalle OF detalle.prg, llRetorno as Boolean
		
		loDetalle = NewObject( "AuxCargaManual" )
		llRetorno = loDetalle.Validarcantidaditems()
		This.assertequals( "La validación no retorno un valor booleano.", "L", vartype( llRetorno ) )
				
		loDetalle.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificarMetodoCargarItem
		Local loDetalle as detalle OF detalle.prg
		loDetalle = newobject( "TestDetalle" )
		loDetalle.lPasoPor_CargarItem = .F.
		loDetalle.CargarItem( 1 )
		This.asserttrue( "Debe pasar por el metodo _CargarItem.", loDetalle.lPasoPor_CargarItem )
		loDetalle.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidacionDetalleObligatorio
		local loEnt as Din_EntidadNASDROVIA of Din_EntidadNASDROVIA.prg, llValida as Boolean, loInfo as object 

		loEnt = _screen.zoo.InstanciarEntidad( "Nasdrovia" )
			
		with loEnt
			.Nuevo()
			llValida = .Republicas.ValidacionDetalleObligatorio()
			this.asserttrue( "Debe fallar la validación por detalle obligatorio(1)", !llValida )

			with .Republicas
				.LimpiarItem()
				.Actualizar()
			endwith
			llValida = .Republicas.ValidacionDetalleObligatorio()
			this.asserttrue( "Debe fallar la validación por detalle obligatorio(2)", !llValida )
			
			with .Republicas
				.LimpiarItem()
				.oItem.Nombre = "REP NSD"
				.oItem.Descripcion = "DESC REP NSD"
				.Actualizar()
			endwith

			llValida = .Republicas.ValidacionDetalleObligatorio()
			this.asserttrue( "NO debe fallar la validación por detalle obligatorio", llValida )
			.Release()

		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestValidarDetalleSegunDisenoImpresion
		local loDetalle as detalle of detalle.prg, llRetorno as Boolean 

		loDetalle = newobject( "AuxDetalleRusia" )
		loObjeto = newobject( "ObjetoBindeoTest" )
		loObjeto.oDetalle = loDetalle
		with loDetalle
			.inicializar()
			bindevent( loDetalle, "EventoAdvertirLimitePorDiseno", loObjeto, "EventoAdvertirLimitePorDiseno", 1 )
			bindevent( loDetalle, "EventoCancelarCargaLimitePorDiseno", loObjeto, "EventoCancelarCargaLimitePorDiseno", 1 )
			bindevent( loDetalle, "EventoGenerarInformeLimitePorDiseno", loObjeto, "EventoGenerarInformeLimitePorDiseno", 1 )
			
			.nCantidadDeItemsCargados = 15
			.nTipoDeValidacionSegunDisenoImpresion = 0
			.nLimiteSegunDisenoImpresion = 14		
			loObjeto.lCancelaxLimite = .f.
			loObjeto.lAdvirtioLimite = .f.
			llRetorno = .ValidarItemsSegunDisenoImpresion()
			this.assertequals( "Debería dar TRUE la validación xq NO valida ", .t. , llRetorno )
			this.assertequals( "No debería haber disparado el evento xq no valida" , .f., loObjeto.lAdvirtioLimite )
			this.assertequals( "No debería haber disparado el evento 2 xq no valida" , .f., loObjeto.lCancelaxLimite)

			.nCantidadDeItemsCargados = 10
			.nTipoDeValidacionSegunDisenoImpresion = 2
			.nLimiteSegunDisenoImpresion = 14		
			loObjeto.lCancelaxLimite = .f.
			loObjeto.lAdvirtioLimite = .f.
			llRetorno = .ValidarItemsSegunDisenoImpresion()
			this.assertequals( "Debería dar TRUE la validación xq valida pero No alcanzó el límite ", .t. , llRetorno )
			this.assertequals( "No debería haber disparado el evento xq no alcanzó el límite y valida (no advierte)" , .f., loObjeto.lAdvirtioLimite )
			this.assertequals( "No debería haber disparado el evento 2 xq no valida 2" , .f., loObjeto.lCancelaxLimite)
			
			.nCantidadDeItemsCargados = 10
			.nTipoDeValidacionSegunDisenoImpresion = 2
			.nLimiteSegunDisenoImpresion = 9
			loObjeto.lCancelaxLimite = .f.
			loObjeto.lAdvirtioLimite = .f.

			llRetorno = .ValidarItemsSegunDisenoImpresion()
			this.assertequals( "Debería dar TRUE la validación xq valida  y alcanzó el límite 3, PERO NO HUBO BINDEO", .T. , llRetorno )
			this.assertequals( "No debería haber disparado el evento xq alcanzó el límite pero valida ( no advierte )" , .f., loObjeto.lAdvirtioLimite )
			this.assertequals( "No debería haber disparado el evento 2 xq no valida 3" , .t., loObjeto.lCancelaxLimite)

			loObjeto.lCancelarCargaLimitePorDiseno = .T.
			llRetorno = .ValidarItemsSegunDisenoImpresion()
			this.assertequals( "Debería dar FALSE la validación xq valida  y alcanzó el límite 3", .F. , llRetorno )
			this.assertequals( "No debería haber disparado el evento xq alcanzó el límite pero valida ( no advierte )" , .f., loObjeto.lAdvirtioLimite )
			this.assertequals( "No debería haber disparado el evento 2 xq no valida 3" , .t., loObjeto.lCancelaxLimite)

			.nCantidadDeItemsCargados = 10
			.nTipoDeValidacionSegunDisenoImpresion = 1
			.nLimiteSegunDisenoImpresion = 14		
			loObjeto.lCancelaxLimite = .f.
			loObjeto.lAdvirtioLimite = .f.
			llRetorno = .ValidarItemsSegunDisenoImpresion()
			this.assertequals( "Debería dar TRUE la validación xq Advierte pero No alcanzó el límite ", .t. , llRetorno )
			this.assertequals( "No debería haber disparado el evento xq no valida" , .f., loObjeto.lCancelaxLimite  )
			this.assertequals( "No debería haber disparado el evento 2 xq no valida 4" , .f., loObjeto.lCancelaxLimite)

			.nCantidadDeItemsCargados = 10
			.nTipoDeValidacionSegunDisenoImpresion = 1
			.nLimiteSegunDisenoImpresion = 9
			loObjeto.lCancelaxLimite = .f.
			loObjeto.lAdvirtioLimite = .f.

			llRetorno = .ValidarItemsSegunDisenoImpresion()
			this.assertequals( "Debería dar TRUE la validación xq Avierte y alcanzó el límite 5", .T. , llRetorno )
			this.assertequals( "DEBERIA haber disparado el evento xq Avierte y alcanzó el límite" , .T., loObjeto.lAdvirtioLimite )
			this.assertequals( "No debería haber disparado el evento 2 xq no valida 5" , .f., loObjeto.lCancelaxLimite)
			loObjeto.oDetalle = Null
			.release()
		endwith	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_AtributosAgrupamiento
		local loDetalle as detalle OF detalle.prg
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )

		loDetalle.cAtributosAgrupamiento = ""
		This.AssertEquals( "No obtiene cAtributoAgrupamiento correctamente", "NroItem", loDetalle.cAtributosAgrupamiento )
		loDetalle.cAtributosAgrupamiento = "Nombre,Gobernador,Precio,Fecha"		
		This.AssertEquals( "No obtiene cAtributoAgrupamiento correctamente", "Nombre,Gobernador,Precio,Fecha" , loDetalle.cAtributosAgrupamiento )

		loDetalle.release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_ColeccionAgrupamientosSinAtributosAgrupamiento
		local loDetalle as detalle OF detalle.prg
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loDetalle.cAtributosAgrupamiento = ""
		This.Assertequals( "la cantidad de items de la collecion agrupamientos no es correcta", 0, loDetalle.oColAgrupamientos.Count )
		with loDetalle
			.LimpiarItem()
			.Actualizar()
		endwith
		This.Asserttrue( "No deberia existir el item 1", !loDetalle.oColAgrupamientos.Buscar( "-1" ) )
		with loDetalle
			.LimpiarItem()
			.Actualizar()
		endwith
		This.Asserttrue( "No deberia existir el item 2", !loDetalle.oColAgrupamientos.Buscar( "-2" ) )
		with loDetalle
			.CargarItem( 2 )
			.oItem.Cantidad = 10
			.Actualizar()
		endwith
		This.Asserttrue( "No deberia existir el item 2a", !loDetalle.oColAgrupamientos.Buscar( "-2" ) )
		with loDetalle
			.CargarItem( 1 )
			.oItem.Gobernador = "PPPP"
			.Actualizar()
		endwith
		This.Asserttrue( "Deberia existir el item 1", !loDetalle.oColAgrupamientos.Buscar( "-1" ) )
		This.Assertequals( "la cantidad de items de la collecion agrupamientos no es correcta (2)", 0, loDetalle.oColAgrupamientos.Count )
		loDetalle.release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_ColeccionAgrupamientosConAtributosAgrupamiento
		local loDetalle as detalle OF detalle.prg
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loDetalle.cAtributosAgrupamiento = "Gobernador,Precio,Fecha"
		This.Assertequals( "la cantidad de items de la collecion agrupamientos no es correcta", 0, loDetalle.oColAgrupamientos.Count )
		with loDetalle
			.LimpiarItem()
			.Actualizar()
		endwith
		This.Assertequals( "la cantidad de items de la collecion agrupamientos no es correcta 1", 0, loDetalle.oColAgrupamientos.Count )		
		with loDetalle
			.LimpiarItem()
			.oItem.Gobernador = "PPP"
			.oItem.Precio = 12.25
			.oItem.Fecha = {12/12/2001}
			.Actualizar()
		endwith
		This.Assertequals( "Mal item PPP", 1, loDetalle.oColAgrupamientos.Item[ "-PPP-12.25-20011212" ].Cantidad )
		with loDetalle
			.LimpiarItem()
			.oItem.Gobernador = "PPP"
			.oItem.Precio = 12.25
			.oItem.Fecha = {12/12/2001}
			.Actualizar()
		endwith
		This.Assertequals( "Mal item PPP 2", 2, loDetalle.oColAgrupamientos.Item[ "-PPP-12.25-20011212" ].Cantidad )		
		with loDetalle
			.CargarItem(2)
			.oItem.Gobernador = "PPPPP"
			.oItem.Precio = 12.25
			.oItem.Fecha = {12/12/2001}
			.Actualizar()
		endwith
		This.Assertequals( "Mal PPPPPP", 1, loDetalle.oColAgrupamientos.Item[ "-PPPPP-12.25-20011212" ].Cantidad )
		This.Assertequals( "Mal PPP 3", 1, loDetalle.oColAgrupamientos.Item[ "-PPP-12.25-20011212" ].Cantidad )
		loDetalle.release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztest_CantidadDeTipoDeValoresCargados
		local loDetalle as Object, loPago as Object, lnMonto as Integer, lnCanti as Integer, lcCanti as String, lnCantidadValores as Integer

		lnCantidadValores = 0
		loDetalle= _screen.zoo.crearobjeto( "Din_DetalleRusiaRepublicas" )
		lnMonto = 20
		lcCanti = ""

		for lnCanti=1 to 11
			lcCanti = padl(lnCanti,2,"0")

			loPago = createobject("session")

			with loPago
				.addproperty('Valor_PK',lcCanti )
				.addproperty('ValorDetalle',"MONEDA "+lcCanti )
				.addproperty("Monto",lnMonto+lnCanti )
				.addproperty("Total",lnMonto+lnCanti )
				.addproperty("nroitem", lnCanti )
				.addproperty("CantTipoValoresAcumulados", 0 )
				.addproperty("PesosAlCambio", lnMonto+lnCanti )
				do case
					case lnCanti = 1
						.addproperty("Tipo", 3 )
						.addproperty("NumeroCupon", 3333 )
						.addproperty("NumeroLoteCupon", 555 )
						.addproperty("NumeroTarjeta", "777777777777777" )
						.addproperty("cupon_pk", "456456" )
					case lnCanti = 2
						.addproperty("Tipo", 3 )
						.addproperty("NumeroCupon", 4444 )
						.addproperty("NumeroLoteCupon", 333 )
						.addproperty("NumeroTarjeta", "8888888" )
						.addproperty("cupon_pk", "121212" )
					case lnCanti = 3
						.addproperty("Tipo", 1 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 4
						.addproperty("Tipo", 1 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 5
						.addproperty("Tipo", 1 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 6
						.addproperty("Tipo", 2 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 7
						.addproperty("Tipo", 2 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 8
						.addproperty("Tipo", 6 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 9
						.addproperty("Tipo", 6 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 10
						.addproperty("Tipo", 9 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
					case lnCanti = 11
						.addproperty("Tipo", 9 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )						
				otherwise
						.addproperty("Tipo", 1 )
						.addproperty("NumeroCupon", 0 )
						.addproperty("NumeroLoteCupon", 0 )
						.addproperty("NumeroTarjeta", "" )
						.addproperty("cupon_pk", "" )
				endcase
				
			endwith
			loDetalle.add( loPago )
		endfor
		
		lnCantidadValores = loDetalle.CantidadDeTipoDeValoresCargados()
		This.AssertEquals( "La Cantidad de tipo de valores acumulados no es correcta", 5, lnCantidadValores )
		
		loDetalle.Release()
		
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_ActualizarColAgrupamientosAlCargar
	
		local loDetalle as detalle OF detalle.prg
		loDetalle = newobject( "Din_DetalleCanadaDetalleCanada", "Din_DetalleCanadaDetalleCanada.Prg" )
		create cursor c_DetalleCanada ( Codigo c(10), NroItem N(10), Nombre c(10), Gobernador C(10), Cantidad N(10,2), Precio N(10,2 ), Fecha D )
		insert into c_DetalleCanada( Codigo, nroItem, Nombre, gobernador ) values ( "1", 1, "1", "1" )
		insert into c_DetalleCanada( Codigo, nroItem, Nombre, gobernador ) values ( "1", 2, "1", "2" )
		insert into c_DetalleCanada( Codigo, nroItem, Nombre, gobernador ) values ( "1", 3, "2", "1" )
		insert into c_DetalleCanada( Codigo, nroItem, Nombre, gobernador ) values ( "1", 4, "1", "1" )						
		loDetalle.Limpiar()
		loDetalle.Cargar()
		This.AssertEquals( "La Cantidad de items cargados no es correcta", 0, loDetalle.CantidadDeItemsAgrupadosCargados() )
		
		loDetalle.Limpiar()
		loDetalle.Cargar()
		loDetalle.cAtributosAgrupamiento = "Nombre,gobernador"
		This.AssertEquals( "La Cantidad de items cargados no es correcta", 3, loDetalle.CantidadDeItemsAgrupadosCargados() )
		
		use in select( "c_DetalleCanada" )

	endfunc 
	*-----------------------------------------------------------------------------------------
	Function zTestU_ActualizarColAgrupamientosAlAsignarAgrupamientos
		local loDetalle as detalle OF detalle.prg
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loDetalle.cAtributosAgrupamientoDefault = "TIMESTAMP"
		This.Assertequals( "la cantidad de items de la collecion agrupamientos no es correcta", 0, loDetalle.oColAgrupamientos.Count )
		with loDetalle
			.LimpiarItem()
			.Actualizar()
		endwith
		This.Assertequals( "la cantidad de items de la collecion agrupamientos no es correcta 1", 0, loDetalle.oColAgrupamientos.Count )		
		with loDetalle
			.LimpiarItem()
			.oItem.Gobernador = "PPP"
			.Actualizar()
		endwith
		This.Assertequals( "Mal item 2", 1, loDetalle.oColAgrupamientos.Item[ "-2" ].Cantidad )
		with loDetalle
			.LimpiarItem()
			.oItem.Gobernador = "PPP"
			.Actualizar()
		endwith
		This.Assertequals( "Mal item 3", 1, loDetalle.oColAgrupamientos.Item[ "-3" ].Cantidad )		
		with loDetalle
			.LimpiarItem()
			.oItem.Gobernador = "PPPPP"
			.Actualizar()
		endwith
		This.Assertequals( "Mal Item 4", 1, loDetalle.oColAgrupamientos.Item[ "-4" ].Cantidad )
		This.AssertEquals( "La Cantidad de items cargados no es correcta", 3, loDetalle.CantidadDeItemsAgrupadosCargados() )			
		
		loDetalle.cAtributosAgrupamiento = "Gobernador"
		This.AssertEquals( "La Cantidad de items cargados no es correcta", 2, loDetalle.CantidadDeItemsAgrupadosCargados() )
		This.Assertequals( "Mal item PPP", 2, loDetalle.oColAgrupamientos.Item[ "-PPP" ].Cantidad )
		This.Assertequals( "Mal item PPPPP", 1, loDetalle.oColAgrupamientos.Item[ "-PPPPP" ].Cantidad )
		loDetalle.release()	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDispararEventoAlAgregarUnItem
		local loDetalle as detalle OF detalle.prg
		
		* Arrange
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loBindeoDetalle = createobject( "BindeoDetalle" )
		bindevent( loDetalle, "EventoSeAgregounItem", loBindeoDetalle, "CambiarFlagAgregarItem",1 )
		
		* Act
		with loDetalle
			.LimpiarItem()
			.Actualizar()
		endwith
		
		* Assert
		this.asserttrue( "Debio disparar el evento por agregar item.", loBindeoDetalle.lPasoPorElEventoAgregarItem )
		loDetalle.Release()	
		loBindeoDetalle = null
		
	endfunc 
*------
	function zTestValidarCantidadesSegunDisenoImpresionDesdeEnBaseA
		local lnI, loDetalle as detalle of detalle.prg, llRetorno as Boolean, loControl as Object 
		locontrol = createobject( "BindeoAuxiliar" )
		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRUSIARepublicas" )
 		loControl.oDetalle = loDetalle

		loDetalle.inicializar()
		bindevent(loDetalle, "EventoCancelarCargaLimitePorDiseno",loControl,"ActualizarPropiedad",4)
		loDetalle.nLimiteSegunDisenoImpresion = 3
		loDetalle.nTipoDeValidacionSegunDisenoImpresion = 2
		loDetalle.lCancelarCargaLimitePorDiseno = .t.
		** Cargo 2 items (no llegan al límite de impresión)
		for lnI = 1 to 2
			with loDetalle
				.LimpiarItem()
				.oItem.Nombre = "IT" + transform( lnI, '99' )
				.oItem.Descripcion = "DESC IT" + transform( lnI, '99' )
				.Actualizar()
			endwith
		endfor
 		loControl.lCancela = .t.
		this.asserttrue(" NO Debe dar false xq no alcanza el límite ", loDetalle.ValidarCantidadesSegunDisenoImpresionDesdeEnBaseA())
 		loControl.lCancela = .f.
		this.asserttrue(" NO Debe dar false xq no alcanza el límite  y el flag que no cancele", loDetalle.ValidarCantidadesSegunDisenoImpresionDesdeEnBaseA())
		
		** Cargo 2 items más (superando el límite de impresión)	con el flag de cancelar apagado para que no corte	
		loDetalle.lCancelarCargaLimitePorDiseno = .f.
		for lnI = 3 to 4
			with loDetalle
				.LimpiarItem()
				.oItem.Nombre = "IT" + transform( lnI , '99' )
				.oItem.Descripcion = "DESC IT" + transform( lnI , '99' )
				.Actualizar()
			endwith
		endfor
		*prendo el flag para que cancele si corresponde y valido
		loDetalle.lCancelarCargaLimitePorDiseno = .t.
 		loControl.lCancela = .t.
		this.asserttrue("Debe dar false xq el límite es 2 y carga 3 y el flag que cancela", !loDetalle.ValidarCantidadesSegunDisenoImpresionDesdeEnBaseA())
 		loControl.lCancela = .f.
		this.asserttrue("Debe dar true xq el límite es 2 y carga 3 y el flag que no cancele", loDetalle.ValidarCantidadesSegunDisenoImpresionDesdeEnBaseA())

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestUObtenerItemActualizadoConItemActivo
		local loDetalle as Din_DetalleRusiaRepublicas of Din_DetalleRusiaRepublicas.prg, ;
			loItem as ItemAuxiliar of Din_DetalleRusiaRepublicas.prg, i as Integer, loItemActual as Object

		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRusiaRepublicas" )


		for i = 1 to 10
			loItem = loDetalle.Crearitemauxiliar()
			
			loItem.codigo = "CODIGO" + alltrim( transform( i ) )
			loItem.Descripcion = "Descripcion " + alltrim( transform( i ) )
			loItem.NOMBRE = "Nombre" + alltrim( transform( i ) )
			loItem.NroItem = i
			
			loDetalle.Add( loItem )
		endfor

		loDetalle.Cargaritem( 3 )
		loDetalle.oItem.Nombre = "NombreItem"
		
		loItemActual = loDetalle.ObtenerItemActual( 3 )
		
		This.assertequals( "Atributo nombre incorrecto", "NombreItem", loItemActual.Nombre )
		
		loDetalle.Release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestUObtenerItemActualizadoConItemPlano
		local loDetalle as Din_DetalleRusiaRepublicas of Din_DetalleRusiaRepublicas.prg, ;
			loItem as ItemAuxiliar of Din_DetalleRusiaRepublicas.prg, i as Integer, loItemActual as Object

		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRusiaRepublicas" )


		for i = 1 to 10
			loItem = loDetalle.Crearitemauxiliar()
			
			loItem.codigo = "CODIGO" + alltrim( transform( i ) )
			loItem.Descripcion = "Descripcion " + alltrim( transform( i ) )
			loItem.NOMBRE = "Nombre" + alltrim( transform( i ) )
			loItem.NroItem = i
			
			loDetalle.Add( loItem )
		endfor

		loDetalle.Cargaritem( 3 )
		loDetalle.oItem.Nombre = "NombreItem"
		
		loItemActual = loDetalle.ObtenerItemActual( 6 )
		
		This.assertequals( "Atributo nombre incorrecto", "Nombre6", loItemActual.Nombre )
		
		loDetalle.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestUObtenerItemActualizadoSinItemActivo
		local loDetalle as Din_DetalleRusiaRepublicas of Din_DetalleRusiaRepublicas.prg, ;
			loItem as ItemAuxiliar of Din_DetalleRusiaRepublicas.prg, i as Integer, loItemActual as Object

		loDetalle = _screen.zoo.crearobjeto( "Din_DetalleRusiaRepublicas" )


		for i = 1 to 10
			loItem = loDetalle.Crearitemauxiliar()
			
			loItem.codigo = "CODIGO" + alltrim( transform( i ) )
			loItem.Descripcion = "Descripcion " + alltrim( transform( i ) )
			loItem.NOMBRE = "Nombre" + alltrim( transform( i ) )
			loItem.NroItem = i
			
			loDetalle.Add( loItem )
		endfor

		loItemActual = loDetalle.ObtenerItemActual( 6 )
		
		This.assertequals( "Atributo nombre incorrecto", "Nombre6", loItemActual.Nombre )
		
		loDetalle.Release()
	endfunc	

	*-----------------------------------------------------------------------------------------
	Function zTestU_SetearEsNavegacion()
		local loDetalle as detalle OF detalle.prg, loItem as Object

		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loDetalle.SetearEsNavegacion( .f. )
		This.AssertTrue( "La propiedad debe estar en TRUE ", loDetalle.lEsNavegacion )
		loDetalle.SetearEsNavegacion( .t. )
		This.AssertTrue( "La propiedad debe estar en FALSE", !loDetalle.lEsNavegacion )
		loDetalle.release()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_TieneAlMenosUnItemValido()
		local loDetalle as detalle OF detalle.prg, loItem as Object
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loItem = createobject("custom")
		addproperty(loItem,"gobernador","XXX")
		addproperty(loItem,"precio",10)
		This.AssertTrue( "No debe tener item cargados", !loDetalle.TieneAlMenosUnItemValido() )
		loDetalle.agregaritemplano( loItem )
		loDetalle.agregaritemplano( loItem )
		This.AssertTrue( "Debe tener al menos un item cargado", loDetalle.TieneAlMenosUnItemValido() )
		loItem = null
		loDetalle.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_SuperaCantidadMaximaDeItemsAgrupadosAlCargar_DentroDelLimite() as Void
		local loDetalle as detalle OF detalle.prg, loItem as Object
		
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loItem = createobject( "custom" )
		
		loDetalle.nLimiteSegunDisenoImpresion = 3
		loDetalle.cAtributosAgrupamiento = "ARTICULO_PK,ARTICULODETALLE"
		loDetalle.cDisenoLimitador = "DisenoTest"
		loDetalle.cAtributosAgrupamientoDefault = "NroItem" 
		loDetalle.lCancelarCargaLimitePorDiseno = .t.
		
		AddProperty( loItem, "precio",10 )
		AddProperty( loItem, "ARTICULO_PK","A1" )
		AddProperty( loItem, "ARTICULODETALLE","Art1" )
		
		for i = 1 to 5						
			loDetalle.AgregarItemPlano( loItem )		
		endfor

		for each loItemAux in loDetalle
			llRetorno = loDetalle.ValidarCantidadesSegunDisenoImpresionDesdeEnBaseAConAgrupamientos( loItemAux )
		endfor
		
		This.AssertTrue( "No deberia haber errores", llRetorno )
		
		loInformacion = loDetalle.ObtenerInformacion()
		This.AssertEquals( "No deberia haber informacion", loInformacion.Count, 0 )
		
		loItem = null
		loDetalle.Release()
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_SuperaCantidadMaximaDeItemsAgrupadosAlCargar_FueraDelLimite() as Void
		local loDetalle as detalle OF detalle.prg, loItem as Object
		
		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		loObjeto = newobject( "ObjetoBindeoTest" )
		loObjeto.oDetalle = loDetalle
		with loDetalle
			.inicializar()				
			.nLimiteSegunDisenoImpresion = 2
			.cAtributosAgrupamiento = "ARTICULO_PK,ARTICULODETALLE"
			.cDisenoLimitador = "DisenoTest"
			.cAtributosAgrupamientoDefault = "NroItem" 
			.lCancelarCargaLimitePorDiseno = .t.
		endwith
		
		loObjeto.lCancelaxLimite = .t.
		loObjeto.lCancelarCargaLimitePorDiseno = .t.
		bindevent( loDetalle, "EventoCancelarCargaLimitePorDiseno", loObjeto, "EventoCancelarCargaLimitePorDiseno", 1 )
		
		loItem1 = createobject( "custom" )
		
		addproperty( loItem1, "precio",10 )
		addproperty( loItem1, "ARTICULO_PK","A1" )
		addproperty( loItem1, "ARTICULODETALLE","Art1" )
					
		loDetalle.AgregarItemPlano( loItem1 )		
		
		loItem2 = createobject( "custom" )
		
		addproperty( loItem2, "precio",10 )
		addproperty( loItem2, "ARTICULO_PK","A2" )
		addproperty( loItem2, "ARTICULODETALLE","Art2" )
					
		loDetalle.AgregarItemPlano( loItem2 )			
		
		loItem3 = createobject( "custom" )
		
		addproperty( loItem3, "precio",10 )
		addproperty( loItem3, "ARTICULO_PK","A3" )
		addproperty( loItem3, "ARTICULODETALLE","Art3" )
					
		loDetalle.AgregarItemPlano( loItem3 )		
				
		for each loItemAux in loDetalle
			llRetorno = loDetalle.ValidarCantidadesSegunDisenoImpresionDesdeEnBaseAConAgrupamientos( loItemAux )
		endfor
		
		This.AssertTrue( "Debería haber errores", !llRetorno )
		
		loInformacion = loDetalle.ObtenerInformacion()
		This.AssertEquals( "Debería haber información", 1, loInformacion.Count )
		
		loItem1 = null
		loItem2 = null
		loItem3 = null
		loObjeto.Destroy()
		loDetalle.Release()
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CantidadDeItemsSinCamposObligatorios() as Void
		local loDetalle as detalle OF detalle.prg, loItem as Object

		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleDISENOIMPRESIONEntidades" )
		
		loItem = _Screen.Zoo.Crearobjeto( "Din_ItemDISENOIMPRESIONEntidades" )
		loItem.nroitem = 1
		This.AssertEquals( "La cantidad esta mal 1", loDetalle.Cantidaddeitemscargados(), 0 )
		loDetalle.Add(loItem)
		This.AssertEquals( "La cantidad esta mal 2", loDetalle.Cantidaddeitemscargados(), 1 )
		loItem = _Screen.Zoo.Crearobjeto( "Din_ItemDISENOIMPRESIONEntidades" )
		loItem.nroitem = 2
		loDetalle.Add(loItem)
		This.AssertEquals( "La cantidad esta mal 3", loDetalle.Cantidaddeitemscargados(), 2 )
		loItem = _Screen.Zoo.Crearobjeto( "Din_ItemDISENOIMPRESIONEntidades" )
		loItem.nroitem = 3
		loDetalle.Add(loItem)
		This.AssertEquals( "La cantidad esta mal 4", loDetalle.Cantidaddeitemscargados(), 3 )
		loItem = _Screen.Zoo.Crearobjeto( "Din_ItemDISENOIMPRESIONEntidades" )		
		loItem.nroitem = 4
		loDetalle.Add(loItem)
		This.AssertEquals( "La cantidad esta mal 5", loDetalle.Cantidaddeitemscargados(), 4 )
				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestLimpiarDetalleCodBarAlt
		local loDetalle as detalle OF detalle.prg, loItem as Object

		loDetalle = _Screen.Zoo.Crearobjeto( "Din_DetalleCanadaDetalleCanada" )
		
		loDetalle.oColCBAltYaLeidos.Agregar( "12345" )
		loDetalle.oColCBAltYaLeidosConIDArt.Agregar( "12345", "guid" )
		loDetalle.lCargoDatosDesdeTXT = .T.	

		loDetalle.LimpiarDetalleCodBarAlt()

		This.assertequals ( "No se limpio la colección 'oColCBAltYaLeidos'", 0, loDetalle.oColCBAltYaLeidos.Count )
		This.assertequals( "No se limpio la colección 'oColCBAltYaLeidosConIDArt'", 0, loDetalle.oColCBAltYaLeidosConIDArt.Count )
		This.asserttrue( "La propiedad 'lCargoDatosDesdeTXT' no tiene el valor esperado'oColCBAltYaLeidosConIDArt'", !loDetalle.lCargoDatosDesdeTXT )

		loDetalle.release()

	endfunc 

enddefine

******************************************************************
define class AuxCargaManual as detalle of detalle.prg
	*-----------------------------------------------------------------------------------------
	function Init() as Void
	endfunc 
enddefine
******************************************************************
define class TestDetalle as detalle of detalle.prg
	lPasoPor_CargarItem = .F.
	*--------------------------------------------------------------------------------------------------------
	function _CargarItem( tnItem as integer )
		This.lPasoPor_CargarItem = .T.
		dodefault( tnItem )
	endfunc
			
enddefine

define class ObjetoBindeoTest as custom

	oDetalle = null
	lEjecuto = .f.
	lAdvirtioLimite = .f.
	lCancelaxLimite = .f.
	lCancelarCargaLimitePorDiseno = .f.
	lEjecutoSumarizar = .f.
	lEjecutoTotalizar = .f.
	lEjecutoAcumular = .f.
	
	function CambioSumarizado()
		this.lEjecuto = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoAdvertirLimitePorDiseno( tcMensaje as String ) as Void
		this.lAdvirtioLimite = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoGenerarInformeLimitePorDiseno( tcMensaje as String ) as Void
		this.lAdvirtioLimite = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoCancelarCargaLimitePorDiseno( tcDetalle ) as Void
		this.lCancelaxLimite = .t.
		This.oDetalle.lCancelarCargaLimitePorDiseno = This.lCancelarCargaLimitePorDiseno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Sumarizar() as boolean
		this.lEjecutoSumarizar = .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Totalizar( toItem as Object ) as Void
		this.lEjecutoTotalizar = .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Acumular( tlForzar as Boolean, tcAtributo as String, tnValor as Decimal, tnValorAnt as Decimal ) as Void
		this.lEjecutoAcumular = .T.
	endfunc 


enddefine

********************************************************************
********************************************************************
define class AuxDetalleRusia as Din_DetalleRUSIARepublicas of Din_DetalleRUSIARepublicas.prg

	*-----------------------------------------------------------------------------------------
	function nCantidadDeItemsCargados_Access() as Number
		return this.nCantidadDeItemsCargados
	endfunc
	
enddefine
********************************************************************
********************************************************************
define class AuxDetalleArgentina as Din_DetalleArgentinaProvincia of Din_DetalleArgentinaProvincia.prg

	*-----------------------------------------------------------------------------------------
	function nCantidadDeItemsCargados_Access() as Number
		return this.nCantidadDeItemsCargados
	endfunc
	
enddefine
*-----------------------------------------------------------------------------------------
define class AuxBindeo as Custom
	oDetalle = null
		*-----------------------------------------------------------------------------------------
	function EventoCancelarCargaLimitePorDiseno( tcNombre as String ) as Void
		This.oDetalle.lCancelarCargaLimitePorDiseno = .T.
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class BindeoDetalle as Custom
	lPasoPorElEventoAgregarItem = .F.
	*-----------------------------------------------------------------------------------------
	function CambiarFlagAgregarItem() as Void
		this.lPasoPorElEventoAgregarItem = .T.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class BindeoAuxiliar as custom

	oDetalle = null
	lCancela = .f.

	*-----------------------------------------------------------------------------------------
	function ActualizarPropiedad( tcDetalle )
		this.oDetalle.lCancelarCargaLimitePorDiseno  = this.lCancela 
	endfunc

enddefine

