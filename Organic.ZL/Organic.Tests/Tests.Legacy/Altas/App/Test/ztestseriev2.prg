**********************************************************************
Define Class zTestSeriev2 As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As zTestSeriev2 Of zTestSeriev2.PRG
	#Endif
	*-----------------------------------------------------------------------------------------
	Function Setup
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function zTestAssignNumeroSerie
		local loEntidad as Object, lcNumeroDeSerie as String

		This.AgregarMocks("EstadoV2,ContratoV2" )
		_Screen.Mocks.AgregarMock( "SerieV2AD" )
		_screen.mocks.AgregarSeteoMetodo( "SerieV2AD", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( "SerieV2AD", 'ConsultarPorClavePrimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( 'Seriev2ad', 'Limpiar', .T. )
		
		
		loEntidad = _screen.zoo.InstanciarEntidad( "SerieV2" )		
		loEntidad.Nuevo()
		try
			loEntidad.NumeroSerie = "300001"
		catch
			This.AssertTrue( "Debe poder asignar un numero de serie mayor a 300000" , .F. )			
		endtry 

		try
			loEntidad.NumeroSerie = "200000"
		catch
			This.AssertTrue( "Se debe poder asignar un numero menor a 300000" , .f. )
		endtry	

		***  Todos los digitos debe ser numericos
		try
			loEntidad.NumeroSerie = "405654"
		catch
			This.AssertTrue( "Debe validar bien el segundo digito" , .f. )
		endtry 
		this.assertequals( "El campo clave esta incorrecto", "82-84-33", alltrim( loEntidad.clave ) )
		this.assertequals( "El campo activacion esta incorrecto", "", loEntidad.activacion )

		loEntidad.clave = ""

		loEntidad.versionSistema = 6.87

		this.assertequals( "El campo clave esta incorrecto 2", "82-84-33", alltrim( loEntidad.clave ) )
		this.assertequals( "El campo activacion esta incorrecto 2", "68-78-59-72", loEntidad.activacion )

		try 
			loEntidad.NumeroSerie = "       "
		catch
			This.AssertTrue( "No debe validar cuando esta en blanco el numero de serie" , .F.)					
		endtry	
		
		loEntidad.Release()
	Endfunc 

	
	*-----------------------------------------------------------------------------------
	Function zTestHabilitarSerieLince
		local loEntidad as Object, lcNumeroDeSerie as String
		This.Agregarmocks( "EstadoV2,ContratoV2,SistemaV2" )

		loEntidad = _screen.zoo.InstanciarEntidad( "SerieV2" )		
		loEntidad.Nuevo()
		loEntidad.sistema.usaSerie = .T.
		loEntidad.sistema_pk = "01"
		this.asserttrue("El campo serie debe estar deshabilitado", !loEntidad.lhabilitarSerieLince_pk )

		loEntidad.sistema.usaSerie = .F.		
		loEntidad.Sistema_pk = "02"
		this.asserttrue("El campo serie debe estar habilitado", loEntidad.lhabilitarSerieLince_pk )
		
		loEntidad.Release()
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestCargarModulosEnDetalle
		local loEntidad as entidad OF entidad.prg 
		local array laModulos[ 22 ]

        laModulos [ 1 ] = 'Minorista'
        laModulos [ 2 ] = '   Barras'
        laModulos [ 3 ] = '   Tarjetas'
        laModulos [ 4 ] = '   Tick-Fac'
        laModulos [ 5 ] = '   Mayorista'
        laModulos [ 6 ] = '   Compras'
        laModulos [ 7 ] = 'Producción'
        laModulos [ 8 ] = 'Contabilidad'
        laModulos [ 9 ] = 'Fondos'
        laModulos [ 10 ] = 'Red'
        laModulos [ 11 ] = 'DPantalla'
        laModulos [ 12 ] = 'Host'
        laModulos [ 13 ] = 'eHost'
        laModulos [ 14 ] = '   Memo'
        laModulos [ 15 ] = '   CHKLine'
        laModulos [ 16 ] = '   -------'
        laModulos [ 17 ] = '   Centralizad'
        laModulos [ 18 ] = 'Nike'
        laModulos [ 19 ] = 'GTrabajo'
        laModulos [ 20 ] = 'Fidelización'
        laModulos [ 21 ] = 'PromoKits'
        laModulos [ 22 ] = 'ProgTareas'
		loEntidad = _screen.zoo.instanciarentidad("seriev2")		
		
		loEntidad.CargarModulosEnDetalle()
		
		For lni = 1 to alen( laModulos )
			this.assertequals("El campo " + transform(lni) + " no esta bien cargado", laModulos[lni], loEntidad.detaLLEMODULOS.Item[lni].modulo ) 
        endfor
		
		loEntidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestInyectarEntidad
		
		local loEntidad as entidad OF entidad.prg 
		
		loEntidad = _screen.zoo.instanciarentidad("seriev2")
		
		this.assertequals("Tengo que tener la entidad en el oItem", "O", vartype( loEntidad.detallemodulos.oItem.oEntidad ))
		
		loEntidad.release()
	endfunc 

Enddefine
