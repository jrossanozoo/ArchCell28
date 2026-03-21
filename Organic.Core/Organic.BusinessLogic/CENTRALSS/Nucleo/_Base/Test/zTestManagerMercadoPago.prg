**********************************************************************
Define Class zTestManagerMercadoPago as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestManagerMercadoPago of zTestManagerMercadoPago.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestCtor
		local oManagerMercadoPago as Object
		
		oManagerMercadoPago = _screen.zoo.CrearObjetoPorProducto( 'ManagerMercadoPago' )

		this.asserttrue("La colección 'oColAccesos' no esta definida", type("oManagerMercadoPago.oColAccesos")="O")
		*this.asserttrue("La colección 'oColDispositivos' no esta definida", type("oManagerMercadoPago.oColDispositivos")="O")
	
		oManagerMercadoPago = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerActualizarToken
		local oManagerMercadoPago as Object, lcToken as String
		
		oManagerMercadoPago = _screen.zoo.CrearObjetoPorProducto( 'ManagerMercadoPago' )

		* Token no cargado
		lcToken = oManagerMercadoPago.ObtenerToken("User1", 1)
		this.asserttrue("No debería haber devuelto un TOken", empty(lcToken))
			
		* Token ya guardado (integracion 1)
		oManagerMercadoPago.ActualizarToken("User1", 1, "Token_User1_1")
		lcToken = oManagerMercadoPago.ObtenerToken("User1", 1)
		this.assertequals("Deberia haber encontrado el Token 'Token_User1_1'", "Token_User1_1", lcToken )
			
		* Actualizar-Blanquear Token existente
		oManagerMercadoPago.ActualizarToken("User1", 1, "")
		lcToken = oManagerMercadoPago.ObtenerToken("User1", 1)
		this.asserttrue("Deberia haber blanqueado el Token 'Token_User1_1'", empty(lcToken))

		* Token ya guardado (integracion 2)
		oManagerMercadoPago.ActualizarToken("User1", 2, "Token_User1_2")
		lcToken = oManagerMercadoPago.ObtenerToken("User1", 2)
		this.assertequals("Deberia haber encontrado el Token 'Token_User1_2'", "Token_User1_2", lcToken)

		this.assertequals("La cantidad de registros en la colección no es la esperada", 2, oManagerMercadoPago.oColAccesos.count)

		* Actualizo Token ya guardado (User1, integracion 1)
		oManagerMercadoPago.ActualizarToken("User1", 1, "Token_User1_1_actualizado")
		lcToken = oManagerMercadoPago.ObtenerToken("User1", 1)
		this.assertequals("Deberia haber devuelto el Token 'Token_User1_1_actualizado'", "Token_User1_1_actualizado", lcToken)

		* Busco que para el User1 e integracion 2 el token siga siendo el correcto
		lcToken = oManagerMercadoPago.ObtenerToken("User1", 2)
		this.assertequals("Deberia haber devuelto el Token 'Token_User1_2'", "Token_User1_2", lcToken)
			
		oManagerMercadoPago = null
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		function zTestDispositivosHabilitados
*!*			local oManagerMercadoPago as Object
*!*			
*!*			oManagerMercadoPago = _screen.zoo.CrearObjetoPorProducto( 'ManagerMercadoPago' )

*!*			this.asserttrue("La caja 'CajaQR' no debería estar habilitada", !oManagerMercadoPago.DispositivoHabilitado( "User1", 1, "CajaQR" ))

*!*			oManagerMercadoPago.AgregarDispositivoHabilitado( "User1", 1, "CajaQR" )
*!*			this.asserttrue("La caja 'CajaQR' debería estar habilitada", oManagerMercadoPago.DispositivoHabilitado( "User1", 1, "CajaQR" ))

*!*			oManagerMercadoPago.AgregarDispositivoHabilitado( "User1", 2, "POINT_901" )
*!*			this.asserttrue("El dispositivo 'POINT_901' debería estar habilitado", oManagerMercadoPago.DispositivoHabilitado( "User1", 2, "POINT_901" ))
*!*			
*!*			this.assertequals("La cantidad de dispositivos/Cajas habilitados no es la esperada", 2, oManagerMercadoPago.oColDispositivos.Count)

*!*			this.asserttrue("El dispositivo 'POINT_888' no debería estar habilitado", !oManagerMercadoPago.DispositivoHabilitado( "User1", 2, "POINT_888" ))

*!*			oManagerMercadoPago.AgregarDispositivoHabilitado( "User1", 2, "POINT_888" )
*!*			this.asserttrue("El dispositivo 'POINT_888' debería estar habilitado", oManagerMercadoPago.DispositivoHabilitado( "User1", 2, "POINT_888" ))

*!*			this.assertequals("La cantidad de dispositivos/Cajas habilitados no es la esperada", 3, oManagerMercadoPago.oColDispositivos.Count)
*!*			
*!*			oManagerMercadoPago = null

*!*		endfunc 


EndDefine
