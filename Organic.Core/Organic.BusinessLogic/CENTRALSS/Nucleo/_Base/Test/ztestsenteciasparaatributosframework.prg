**********************************************************************
DEFINE CLASS ZtestSenteciasParaAtributosFramework as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	LOCAL THIS AS ZtestSenteciasParaAtributosFramework OF ZtestSenteciasParaAtributosFramework.PRG
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	FUNCTION Setup
	ENDFUNC

	*-----------------------------------------------------------------------------------------
	FUNCTION TearDown
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerSentenciaCamposInsert 
		local loSentenciasAtributosFW as Object, lcSentencia as String, lcCursor as String. lcCampos as String 

			
		lcCursor = sys( 2015 )

		if !used( "AtributosGenericos" )
			use ( addbs( _screen.zoo.cRutaInicial ) + "\adn\dbc\AtributosGenericos" ) in 0 shared 
		endif

		Select campo from AtributosGenericos where tipo='E' into cursor &lcCursor.
		lcCampos = ''

		scan
			if empty( lcCampos ) 
				lcCampos = alltrim(campo)
			else
				lcCampos = lcCampos +", "+ alltrim(campo)
			endif				
		endscan

		use in select( lcCursor )
		use in select( "AtributosGenericos" )

		*Arrange (Preparar)
		loSentenciasAtributosFW = _Screen.zoo.CrearObjeto( "SentenciasParaAtributoFramework", "SentenciasParaAtributoFramework.prg" )

		*Act (Actuar)
		lcSentencia = loSentenciasAtributosFW.ObtenerSentenciaCamposInsert()

		*Assert (Afirmar)
		this.AssertEquals( "No trajo la sentencia de campos insert que se esperaba", lcCampos , lcSentencia )

		loSentenciasAtributosFW = null
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerSentenciaValoresInsert
		local loSentenciasAtributosFW as objeto, lcDatos as String, lcUsuario as String, ldFechaVacia as String, ;
		lcStringVacio as String, ldFechaActual as String, lcHoraActual as String, lcUsuarioActual as String, ;
		lcSerieActual as String, lcSucursalActual as String, lcVersionActual as String, lcSentencia as string

        lcUsuario = padr( alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() ), 20, " " )		

		*Arrange (Preparar)
		loSentenciasAtributosFW =  _Screen.zoo.CrearObjeto( "SentenciasParaAtributoFramework", "SentenciasParaAtributoFramework.prg" )
		
		*Act (Actuar)
		lcDatos = loSentenciasAtributosFW.ObtenerSentenciaValoresInsert()

		ldFechaVacia     = goServicios.Librerias.ValorAStringSegunTipoBase(ctod(''))
		lcStringVacio    = goServicios.Librerias.ValorAStringSegunTipoBase('')
		ldFechaActual    = goServicios.Librerias.ValorAStringSegunTipoBase( goServicios.Librerias.ObtenerFecha() ) 		
		lcHoraActual     = goServicios.Librerias.ValorAStringSegunTipoBase( goServicios.Librerias.ObtenerHora() )
		lcUsuarioActual  = goServicios.Librerias.ValorAStringSegunTipoBase( lcUsuario )
		lcSerieActual    = goServicios.Librerias.ValorAStringSegunTipoBase( alltrim( _screen.Zoo.App.cSerie ) )
		lcSucursalActual = goServicios.Librerias.ValorAStringSegunTipoBase( alltrim( _screen.Zoo.App.cSucursalActiva ) )
		lcVersionActual  = goServicios.Librerias.ValorAStringSegunTipoBase( _screen.Zoo.App.ObtenerVersion() ) 
        
		lcSentencia = ldFechaVacia +", "+ ;
					lcStringVacio +", "+ ;
                  	ldFechaActual + ", " + ;
                  	lcHoraActual + ", " + ;
                  	ldFechaActual + ", " + ;
                  	lcHoraActual + ", " + ;
  					ldFechaVacia +", "+ ;
					lcStringVacio +", "+ ;
					ldFechaVacia +", "+ ;
					lcStringVacio +", "+ ;
                  	lcUsuarioActual + ", " + ;
                  	lcUsuarioActual + ", " + ;
                  	lcSerieActual + ", " + ;
                  	lcSerieActual + ", " + ;
                  	lcSucursalActual + ", " + ;
                  	lcSucursalActual + ", " + ;
                  	lcVersionActual + ", " + ;
                  	lcVersionActual + ", " + ;
	                lcStringVacio
		
		*Assert (Afirmar)
		this.AssertEquals( "No trajo los datos para el insert que se esperaban", lcDatos , lcSentencia )

		loSentenciasAtributosFW = null

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerValorAStringSiLleganCorchetes() as Void
	local lcText as String, lcRetorno as String

		*Act (Actuar)
		lcTexto = "Parámetro con indicador de nivel [O]"
		lcRetorno = goServicios.Librerias.ValorAString( lcTexto ) 
		
		*Assert (Afirmar)
		this.AssertEquals( "No consideró los corchetes al final como texto.", "'" + lcTexto + "'" , lcRetorno )

	endfunc 


ENDDEFINE
