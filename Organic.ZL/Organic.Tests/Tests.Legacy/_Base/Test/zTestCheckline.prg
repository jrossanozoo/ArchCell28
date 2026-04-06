**********************************************************************
Define Class zTestCheckline as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestCheckline of zTestCheckline.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestCelular
		local loEntidad as entidad OF entidad.prg, llRetorno as Boolean, loInfo as zooInformacion of zooInformacion.prg

		This.AgregarMocks( "SerieV2" )
		_screen.mocks.AgregarSeteoMetodo( 'SerieV2', 'Validarnroserie', .T., "[407000]" )
		_screen.mocks.AgregarSeteoMetodo( 'SerieV2', 'Actualizarclaveyactivacion', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'seriev2', 'Limpiarinformacion', .T. )
		
		loEntidad = _screen.zoo.instanciarentidad( 'CHECKLINE' )
		
		loEntidad.Nuevo()
		loEntidad.lHabilitarCelular = .t.
		loEntidad.Serie_Pk = "407000"
		with loEntidad.Celular
			.LimpiarItem()
			.oItem.Telefono = "11"
			.Actualizar()
			.LimpiarItem()
			.oItem.Telefono = "1234567890"
			.Actualizar()
			.LimpiarItem()
			.oItem.Telefono = "12345678901"
			.Actualizar()
		endwith
		loInfo = loEntidad.obtenerInformacion()
		llRetorno = loEntidad.ValidacionBasica()
		
		this.asserttrue( "Deberia dar error al poner un nro de celular invalido", !llRetorno )
		this.assertEquals( "La cantidad de problemas es incorrecta", 2, loInfo.Count )
		this.assertEquals( "El problema 1 es invalido", "El numero de celular 11 es inválido.", loInfo.item[ 1 ].cMensaje )
		this.assertEquals( "El problema 2 es invalido", "El numero de celular 12345678901 es inválido.", loInfo.item[ 2 ].cMensaje )
		
		with loEntidad.Celular
			.CargarItem( 1 )
			.oItem.Telefono = "1122334455"
			.Actualizar()
			.CargarItem( 3 )
			.oItem.Telefono = "2345678901"
			.Actualizar()
		endwith
		llRetorno = loEntidad.ValidacionBasica()

		this.asserttrue( "Deberia dar ok al poner un nro de celular valido", llRetorno )
		
		loEntidad.Cancelar()
		
		loEntidad.release()
		loEntidad = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestHabilitarEmailyCelular
		local loEntidad as entidad OF entidad.prg
		
		loEntidad = _screen.zoo.instanciarentidad( 'CHECKLINE' )
		loEntidad.Nuevo()
		
		loEntidad.HabilitarEmail = .t.
		this.asserttrue( "No seteo correctamente la propiedad lHabilitarEmail (1)", loEntidad.lHabilitarEmail )

		loEntidad.HabilitarEmail = .f.
		this.asserttrue( "No seteo correctamente la propiedad lHabilitarEmail (2)", !loEntidad.lHabilitarEmail )		
		
		loEntidad.HabilitarCelular = .t.
		this.asserttrue( "No seteo correctamente la propiedad lHabilitarCelular (1)", loEntidad.lHabilitarCelular )

		loEntidad.HabilitarCelular = .f.
		this.asserttrue( "No seteo correctamente la propiedad lHabilitarCelular (2)", !loEntidad.lHabilitarCelular )		

		loEntidad.Cancelar()
		
		loEntidad.release()
		loEntidad = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidacionGrabar
		local loEntidad as entidad OF entidad.prg, llError as Boolean

		This.AgregarMocks( "SerieV2" )
		_screen.mocks.AgregarSeteoMetodo( "SerieV2", 'Validarnroserie', .T., "[407000]" )
		_screen.mocks.AgregarSeteoMetodo( "SerieV2", 'Validarnroserie', .T., "[407001]" ) 
		_screen.mocks.AgregarSeteoMetodo( "SerieV2", 'Actualizarclaveyactivacion', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'seriev2', 'Limpiarinformacion', .T. )
		
		loEntidad = _screen.zoo.instanciarentidad( 'CHECKLINE' )
		with loEntidad
			.Nuevo()
			.lHabilitarCelular = .f.
			llError = .f.
			try
				.Grabar()
			catch
				llError = .t.
			endtry
			
			this.asserttrue( "Deberia tirar error al intentar grabar sin nro de serie", llError )
			
			llError = .f.
			
			.Serie_PK = '407000'
			.lHabilitarCelular = .f.
			try
				.Grabar()
			catch
				llError = .t.
			endtry
			
			this.asserttrue( "No deberia tirar error al intentar grabar con nro de serie", !llError )

			llError = .f.
			.Ultimo()
			.Eliminar()
			
			llError = .f.
			.Nuevo()
			.Serie_Pk = '407000'
			.lHabilitarCelular = .t.
			with .Celular
				.LimpiarItem()
			 	.oItem.Telefono = '123'
			 	.Actualizar()
			endwith
			try
				.Grabar()
			catch
				llError = .t.
			endtry
			
			this.asserttrue( "Deberia tirar error al intentar grabar con un nro de celular invalido", llError )
			
			.cancelar()
		endwith
		
		loEntidad.release()
		loEntidad = null			
	endfunc 

EndDefine
