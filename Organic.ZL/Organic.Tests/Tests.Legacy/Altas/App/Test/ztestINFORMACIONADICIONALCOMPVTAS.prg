define class zTestINFORMACIONADICIONALCOMPVTAS as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestINFORMACIONADICIONALCOMPVTAS of zTestINFORMACIONADICIONALCOMPVTAS.prg
	#endif

	*** ESTOS TESTs SON PARA VALIDAR LOS ATRIBUTOS OBLIGATORIOS DE LA ENTIDAD (DETALLE) 'ITEMCOMPROBANTE' Y VERIFICAR QUE SE PUEDA CARGAR EL DETALLE***
	*** SI ESTOS TESTs PINCHAN LOS COMPROBANTES RELACIONADOS EN LA ENTIDAD PRESUPUESTOS (Y OTRAS) NO VAN A FUNCIONAR ***

	*-----------------------------------------------------------------------------------------
	function zTestValidarDiccionario
		local lcEntidad as String, lnSelect as Integer

		lcEntidad = "ITEMCOMPROBANTE"
		lnSelect = select()
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" ) in 0

		select Diccionario
		select count(Atributo) as Cant from Diccionario where Obligatorio and upper( Entidad ) = upper( lcEntidad ) into cursor lcCursor

		if lcCursor.Cant = 5
			select lcCursor
			use
			select Diccionario

			locate for upper( alltrim( Atributo ) ) == "NUMERO" and upper( alltrim( Entidad ) ) == lcEntidad and Obligatorio
			if not found()
				this.AssertTrue( "El atributo 'NUMERO' debería existir en la entidad y ser Obligatorio", .f. )
			endif

			locate for upper( alltrim( Atributo ) ) == "TIPOCOMPCARACTER" and upper( alltrim( Entidad ) ) == lcEntidad and Obligatorio
			if not found()
				this.AssertTrue( "El atributo 'TIPOCOMPCARACTER' debería existir en la entidad y ser Obligatorio", .f. )
			endif

			locate for upper( alltrim( Atributo ) ) == "FECHA" and upper( alltrim( Entidad ) ) == lcEntidad and Obligatorio
			if not found()
				this.AssertTrue( "El atributo 'FECHA' debería existir en la entidad y ser Obligatorio", .f. )
			endif

			locate for upper( alltrim( Atributo ) ) == "INTERVINIENTE" and upper( alltrim( Entidad ) ) == lcEntidad and Obligatorio
			if not found()
				this.AssertTrue( "El atributo 'INTERVINIENTE' debería existir en la entidad y ser Obligatorio", .f. )
			endif

			locate for upper( alltrim( Atributo ) ) == "CODIGOENTIDAD" and upper( alltrim( Entidad ) ) == lcEntidad and Obligatorio
			if not found()
				this.AssertTrue( "El atributo 'CODIGOENTIDAD' debería existir en la entidad y ser Obligatorio", .f. )
			endif
		else
			this.AssertTrue( "La cantidad de atributos obligatorios en el detalle debe ser 5 (cinco) para ZL", .f. )
		endif

		select Diccionario
		use
		select( lnSelect )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestINFORMACIONADICIONALCOMPVTAS
		local loEntidad as Object

		loEntidad = _Screen.Zoo.InstanciarEntidad( "INFORMACIONADICIONALCOMPVTAS" )

		with loEntidad
			try
				with .Comprobantes
					.Limpiar()
					.LimpiarItem()
					with .oItem
						.Numero = 111111
						.TipoCompCaracter = "TAREA"
						.Fecha = date()
						.Interviniente = "PRESUPUESTOS"
						.CodigoEntidad = "222222"
					endwith
					.Actualizar()
				endwith
			catch to loError
				this.AssertTrue( "No debería haber pinchado", .f. )
			endtry
		endwith

		with loEntidad.Comprobantes.oItem
			this.AssertEquals( "Debería ser igual el Numero", 111111, .Numero )
			this.AssertEquals( "Debería ser igual el TipoCompCaracter", "TAREA", .TipoCompCaracter )
			this.AssertEquals( "Debería ser igual la Fecha", date(), .Fecha )
			this.AssertEquals( "Debería ser igual el Interviniente", "PRESUPUESTOS", .Interviniente )
			this.AssertEquals( "Debería ser igual el CodigoEntidad", "222222", .CodigoEntidad )
		endwith

		loEntidad.release()
	endfunc

enddefine
