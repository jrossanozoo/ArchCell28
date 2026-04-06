Define Class zTestRazonSocialV2 as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestRazonSocialV2 of zTestRazonSocialV2.prg
	#ENDIF
	

	
	*---------------------------------
	Function Setup

	endfunc
	*-----------------------------------------------------------------------------------------
	Function zTestValidarDiccionario
		local lcEntidad as String 
	
	
		lcEntidad = "RAZONSOCIALV2"

		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" ) in 0 
		
		select Diccionario
		locate for upper( alltrim( atributo ) ) == 'TELEFONODESCRIPCION' and alltrim( upper( entidad ) ) == lcEntidad			
		
		if found()
			This.assertEquals ( "No esta cargado el campo 'ATRIBUTOFORANEO'", 'DIRECCIONES.TELEFONO', upper( alltrim( Diccionario.atributoforaneo ) ) )
		endif
		      
		select Diccionario
		use       
		
	Endfunc	
	
	*-----------------------------------------------------------------------------------------
	Function zTestValidarCodigoRazonSocialV2
		local loEntidad as Object, llValidacion as boolean
			
		This.Agregarmocks("zlClientes" )
		 _screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )

		loEntidad = _screen.zoo.InstanciarEntidad( "RazonSocialV2" )		
		loEntidad.Nuevo()
		loEntidad.Cliente_PK = "123" 
		loEntidad.Codigo = "40565" 

		llValidacion = loEntidad.Validar()
		This.AssertTrue( "Todos los Digitos Deben ser Numericos: "  + " 40565" , llValidacion )
		
		loEntidad.codigo = "A0565" 
		llValidacion = loEntidad.Validar()
		This.AssertTrue( "Todos los Digitos Deben ser Numericos: "  + " A35654" , !llValidacion )
		
		loEntidad.Release()

	Endfunc 
	
		*-----------------------------------------------------------------------------------------
	function zTestLimpiarDireccionAlCambiarCliente

		local loEntidad as Object, loRazonSoc as Object, loObjBind as object
			
		This.Agregarmocks("zlClientes,DireccionV2" )
		_screen.mocks.AgregarSeteoMetodo( 'DireccionV2', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		 _screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
		loObjBind = newobject( "TestObjBind" )
		loRazonSoc = _screen.zoo.instanciarentidad( "razonsocialv2" )
		
		bindevent( lorazonSoc.Direcciones, "Limpiar", loObjBind, "Limpiar" )
		loRazonSoc.Nuevo()
		loRazonSoc.Cliente_PK = '00001'

		loRazonSoc.Direcciones_PK = ''
		This.assertequals ( "No debe asignar la direccion al blanquear", "", alltrim( loRazonSoc.Direcciones_PK ) )
		
		loObjBInd.Limpio = .f.
		loRazonSoc.Direcciones.Cliente_PK = '00002'
		loRazonSoc.Direcciones_PK = '00002'
		
		This.assertequals ( "No debe asignar la direccion", "", alltrim( loRazonSoc.Direcciones_PK ) )
		This.assertequals ( "No limpio", .t., loObjBInd.Limpio )

		loObjBInd.Limpio = .f.
		loRazonSoc.Direcciones.Cliente_PK = '00001'		
		loRazonSoc.Direcciones_PK = '00001'
			
		This.assertequals ( "Debe asignar la direccion", "00001", alltrim( loRazonSoc.Direcciones_PK ) )
		This.assertequals ( "No debe limpiar", .f., loObjBInd.Limpio )
		
		loObjBInd.Limpio = .f.
		loRazonSoc.Cliente_PK = '00002'		

		This.assertequals ( "Se debe blanquear la direccion", "", alltrim( loRazonSoc.Direcciones_PK ) )
		This.assertequals ( "Debe limpiar al cambiar cliente", .t., loObjBInd.Limpio )
		
		loRazonSoc.Cancelar()
		loRazonSoc.lCargando = .T.

		loObjBInd.Limpio = .f.
		loRazonSoc.Direcciones_PK = '00001'	
		This.assertequals ( "Se debe blanquear la direccion (1)", "00001", alltrim( loRazonSoc.Direcciones_PK ) )
		This.assertequals ( "No debe ejecutar limpiar al cargar (1)", .f., loObjBInd.Limpio )

		loObjBInd.Limpio = .f.
		loRazonSoc.Direcciones.Cliente_PK = '00001'		
		loRazonSoc.Cliente_PK = '00002'		
		This.assertequals ( "Se debe blanquear la direccion (2)", "00001", alltrim( loRazonSoc.Direcciones_PK ) )
		This.assertequals ( "No debe ejecutar limpiar al cargar (2)", .f., loObjBInd.Limpio )
		
		
		loRazonSoc.Release()
		loObjBInd.destroy()
	endfunc 

	*---------------------------------
	Function TearDown

	EndFunc

EndDefine


define class TestObjBind as custom
	Limpio = .f.
	
	function Limpiar()
		this.Limpio = .t.
	endfunc

enddefine

