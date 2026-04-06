**********************************************************************
Define Class zTestKontrolerSeriev2 as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestKontrolerSerie of zTestKontrolerSerie.prg
	#ENDIF
	

	*---------------------------------
	Function Setup
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestSetearPropiedadesClaveYActivacion
		local loForm as Object, loControl as Object, lcEntidad as String
		
		lcEntidad = "SERIEV2"
		_Screen.Mocks.AgregarMock( lcEntidad + "AD" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "AD", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "AD", 'ConsultarPorClavePrimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "AD", 'Haydatos', .T. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "AD", 'Limpiar', .T. )


		loForm = goformularios.procesar("seriev2")
		loForm.okontroler.nuevo()
		
		loControl = loForm.oKontroler.ObtenerControl( "Clave" )
		this.asserttrue("El control 1 debe estar deshabilitado", loControl.readonly )
		this.asserttrue("El control 1 debe estar tabStop en falso", !loControl.TabStop )
				
		loControl = loForm.oKontroler.ObtenerControl( "Activacion" )
		this.asserttrue("El control 2 debe estar deshabilitado", loControl.readonly )
		this.asserttrue("El control 2 debe estar tabStop en falso", !loControl.TabStop )
		
		loForm.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestPrimerControl

		local loForm as Object
		
		
		loForm = goformularios.procesar("seriev2")
		loForm.okontroler.nuevo()
		this.assertequals( "El foco no esta en el control correcto","SISTEMA", loForm.cprimercontrol )
		
		loForm.release()
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestCargarCampoSerie
		local loForm as Object, lcEntidad as String, loControl as Object, ;
			lcCursor as String, lcXml as String    

		_screen.mocks.agregarmock("ValorSugeridoZL")
		_screen.mocks.AgregarSeteoMetodo( "ValorSugeridoZL" , 'ObtenerMinimoSerieDisponible', 300001 )
		_screen.mocks.AgregarSeteoMetodo( "ValorSugeridoZL" , 'ObtenerMinimoSerieDisponibleTomaInventario', 404444 )		
		_screen.mocks.AgregarSeteoMetodo( 'VALORSUGERIDOZL', 'Setearpropiedades', .T., "'Series','NroSerie',''" ) 
		
		use in select("sistema")
		
		lcCursor = sys(2015)
		
		goServicios.Datos.EjecutarSentencias( 'select codigo as codigo, descrip as Descripcion, usaserie as ' +;
			'usaserie from sistema where 1=2', 'sistema', '', lcCursor, set("Datasession")  )

		select (lcCursor)
		insert into (lcCursor) values ("01", "LINCE", .t.)
		insert into (lcCursor) values ("02", "TOMA INVENTARIO", .f.)		
		cursortoxml(lcCursor , "lcXml", 3,4, 0, "1")

		use in select(lcCursor)
		
		This.AgregarMocks( "SistemaV2" )
		_screen.mocks.AgregarSeteoMetodoAccesoADatos( "SistemaV2", 'Obtenerdatosentidad', lcXml, "[],[],[Descripcion]" )		
	
		
		loForm = goformularios.procesar("seriev2")
		loForm.okontroler.nuevo()
		loForm.okontroler.oentidad.sistema_pk = "01"
		
		loForm.okontroler.oentidad.sistema.usaserie = .T.
		loForm.okontroler.cargarCampoSerie()
		loControl = loForm.okontroler.ObtenerControl( "NumeroSerie" )
		this.assertequals( "El campo serie no se cargo correctamente",300001 , loControl.value )

		loForm.okontroler.oentidad.sistema.usaserie = .F.
		loForm.okontroler.cargarCampoSerie()
		loControl = loForm.okontroler.ObtenerControl( "NumeroSerie" )
		this.assertequals( "El campo serie no se cargo correctamente",404444 , loControl.value )

		
		loForm.okontroler.oentidad.sistema_pk = ""
		loForm.okontroler.cargarCampoSerie()
		this.assertequals( "El campo serie no se cargo correctamente","", loControl.value )
		
		
		loForm.release()		
	
	endfunc 

enddefine
