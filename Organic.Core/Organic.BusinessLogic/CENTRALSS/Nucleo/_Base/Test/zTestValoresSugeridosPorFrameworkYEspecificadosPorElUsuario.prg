**********************************************************************
Define Class zTestValoresSugeridosPorFrameworkYEspecificadosPorElUsuario as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestValoresSugeridosPorFrameworkYEspecificadosPorElUsuario of zTestValoresSugeridosPorFrameworkYEspecificadosPorElUsuario.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
	EndFunc
	
	*---------------------------------
	Function TearDown
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnAtributoPlanoDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', ["Soy charrua."], "[URUGUAY],[],[Descripcion]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		loEntidad.ValorSugeridoDescripcion()
		this.assertequals( "El valor sugerido no es el esperado.", "Soy charrua.", loEntidad.Descripcion )
		loEntidad.release()
		_screen.mocks.verificarejecuciondemocks()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnBlancoEnAtributoPlanoDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [""], "[URUGUAY],[],[Descripcion]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		loEntidad.ValorSugeridoDescripcion()
		this.assertequals( "El valor sugerido no es el esperado.", "", loEntidad.Descripcion )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoPorElFrameworkEnAtributoPlanoDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', null, "[URUGUAY],[],[Descripcion]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		loEntidad.ValorSugeridoDescripcion()
		this.assertequals( "El valor sugerido no es el esperado.", "Soy uruguay.", loEntidad.Descripcion )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnAtributoSubEntidadDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "HONDURAS" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', ["SACRAMENTO"], "[URUGUAY],[],[Colonia]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		loEntidad.ValorSugeridoColonia()
		this.assertequals( "El valor sugerido no es el esperado.", "SACRAMENTO", alltrim( loEntidad.Colonia_PK ) )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnBlancoEnAtributoSubEntidadDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "HONDURAS" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [""], "[URUGUAY],[],[Colonia]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		loEntidad.ValorSugeridoColonia()
		this.assertequals( "El valor sugerido no es el esperado.", "", alltrim( loEntidad.Colonia_PK ) )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoPorElFrameworkEnAtributoSubEntidadDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "HONDURAS" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', null, "[URUGUAY],[],[Colonia]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		loEntidad.ValorSugeridoColonia()
		this.assertequals( "El valor sugerido no es el esperado.", "COLONIA", alltrim( loEntidad.Colonia_PK ) )
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnAtributoPlanoDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', ["Paysandu"], "[URUGUAY],[Detalleprovincia],[Gobernador]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		loEntidad.ValorSugeridoGobernador()
		this.assertequals( "El valor sugerido no es el esperado.", "Paysandu", loEntidad.Gobernador )
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnBlancoEnAtributoPlanoDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [], "[URUGUAY],[Detalleprovincia],[Gobernador]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		loEntidad.ValorSugeridoGobernador()
		this.assertequals( "El valor sugerido no es el esperado.", "", loEntidad.Gobernador )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoPorElFrameworkEnAtributoPlanoDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', null, "[URUGUAY],[Detalleprovincia],[Gobernador]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		loEntidad.ValorSugeridoGobernador()
		this.assertequals( "El valor sugerido no es el esperado.", "Rivera", loEntidad.Gobernador )
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnAtributoSubEntidadDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "Cuba,ComportamientoCodigoSugeridoEntidad" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', ["Rocha"], "[URUGUAY],[Detalleprovincia],[Cubita]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		loEntidad.ValorSugeridoCubita()
		this.assertequals( "El valor sugerido no es el esperado.", "Rocha", alltrim( loEntidad.Cubita_PK ) )
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoDefinidoPorElUsuarioEnBlancoEnAtributoSubEntidadDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "Cuba,ComportamientoCodigoSugeridoEntidad" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [], "[URUGUAY],[Detalleprovincia],[Cubita]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		loEntidad.ValorSugeridoCubita()
		this.assertequals( "El valor sugerido no es el esperado.", "", alltrim( loEntidad.Cubita_PK ) )
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DebeOfrecerElValorSugeridoPorElFrameworkEnAtributoSubEntidadDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "Cuba,ComportamientoCodigoSugeridoEntidad" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', null, "[URUGUAY],[Detalleprovincia],[Cubita]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		loEntidad.ValorSugeridoCubita()
		this.assertequals( "El valor sugerido no es el esperado.", "Flores", alltrim( loEntidad.Cubita_PK ) )
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_MensajeDeErrorPorValorSugeridoInvalidoDefinidoPorElUsuarioEnAtributoPlanoDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg, loError as zooexception OF zooexception.prg, lcMensajeEsperado as String
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [0 + "A"], "[URUGUAY],[],[Descripcion]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		try
			loEntidad.ValorSugeridoDescripcion()
			this.asserttrue( "Debió dar error.", .f. )
		catch to loError
			lcMensajeEsperado = [Se produjo un error al intentar asignar el valor sugerido 0 + "A" del atributo Descripción para la entidad Uruguay.] + chr( 10 ) + [Verifique el valor especificado en la entidad Comportamiento de atributos.] + chr( 10 ) + [El tipo de dato del atributo es caracter.]
			this.assertequals( "El mensaje de error no es el esperado.", lcMensajeEsperado, loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
		endtry
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MensajeDeErrorPorValorSugeridoInvalidoDefinidoPorElUsuarioEnAtributoSubEntidadDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg, lcMensajeEsperado as String
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "HONDURAS" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [0 + "A"], "[URUGUAY],[],[Colonia]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		try
			loEntidad.ValorSugeridoColonia()
			this.asserttrue( "Debió dar error.", .f. )
		catch to loError
			lcMensajeEsperado = [Se produjo un error al intentar asignar el valor sugerido 0 + "A" del atributo Colonia para la entidad Uruguay.] + chr( 10 ) + [Verifique el valor especificado en la entidad Comportamiento de atributos.] + chr( 10 ) + [El tipo de dato del atributo es caracter.]
			this.assertequals( "El mensaje de error no es el esperado.", lcMensajeEsperado, loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
		endtry
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_MensajeDeErrorPorValorSugeridoInvalidoDefinidoPorElUsuarioEnAtributoPlanoDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg, lcMensajeEsperado as String
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [0 + "A"], "[URUGUAY],[Detalleprovincia],[Gobernador]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		try
			loEntidad.ValorSugeridoGobernador()
			this.asserttrue( "Debió dar error.", .f. )
		catch to loError
			lcMensajeEsperado = [Se produjo un error al intentar asignar el valor sugerido 0 + "A" del atributo Tal para el detalle Provincias.] + chr( 10 ) + [Verifique el valor especificado en la entidad Comportamiento de atributos.] + chr( 10 ) + [El tipo de dato del atributo es caracter.]
			this.assertequals( "El mensaje de error no es el esperado.", lcMensajeEsperado, loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
		endtry
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_MensajeDeErrorPorValorSugeridoInvalidoDefinidoPorElUsuarioEnAtributoSubEntidadDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg, lcMensajeEsperado as String
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		this.AgregarMocks( "Cuba,ComportamientoCodigoSugeridoEntidad" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [0 + "A"], "[URUGUAY],[Detalleprovincia],[Cubita]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		try
			loEntidad.ValorSugeridoCubita()
			this.asserttrue( "Debió dar error.", .f. )
		catch to loError
			lcMensajeEsperado = [Se produjo un error al intentar asignar el valor sugerido 0 + "A" del atributo Cuba para el detalle Provincias.] + chr( 10 ) + [Verifique el valor especificado en la entidad Comportamiento de atributos.] + chr( 10 ) + [El tipo de dato del atributo es caracter.]
			this.assertequals( "El mensaje de error no es el esperado.", lcMensajeEsperado, loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
		endtry
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MensajeDeErrorPorValorSugeridoConTipoDeDatoIncorrectoEnAtributoDeEntidad
		local loEntidad as Din_EntidadCanada of Din_EntidadCanada.prg, loError as zooexception OF zooexception.prg, lcMensajeEsperado as String
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [0], "[URUGUAY],[],[Descripcion]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad = newobject( "Uruguay_Accesor" )
		try
			loEntidad.ValorSugeridoDescripcion()
			this.asserttrue( "Debió dar error.", .f. )
		catch to loError
			lcMensajeEsperado = [Se produjo un error al intentar asignar el valor sugerido 0 del atributo Descripción para la entidad Uruguay.] + chr( 10 ) + [Verifique el valor especificado en la entidad Comportamiento de atributos.] + chr( 10 ) + [El tipo de dato del atributo es caracter.]
			this.assertequals( "El mensaje de error no es el esperado.", lcMensajeEsperado, loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
		endtry
		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MensajeDeErrorPorValorSugeridoConTipoDeDatoIncorrectoEnAtributoDeItem
		local loItem as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg, lcMensajeEsperado as String
		_screen.Mocks.AgregarMock( "ServicioSaltosDeCampoYValoresSugeridos" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS', 'Obtenervalorsugerido', [0], "[URUGUAY],[Detalleprovincia],[Gobernador]" )
		private goServicios
		goServicios = _screen.zoo.CrearObjeto( "ServiciosAplicacion" )
		loEntidad =  newobject( "ItemUruguayDetalleProvincia_Accesor" )
		try
			loEntidad.ValorSugeridoGobernador()
			this.asserttrue( "Debió dar error.", .f. )
		catch to loError
			lcMensajeEsperado = [Se produjo un error al intentar asignar el valor sugerido 0 del atributo Tal para el detalle Provincias.] + chr( 10 ) + [Verifique el valor especificado en la entidad Comportamiento de atributos.] + chr( 10 ) + [El tipo de dato del atributo es caracter.]
			this.assertequals( "El mensaje de error no es el esperado.", lcMensajeEsperado, loError.UserValue.oInformacion.Item[ 2 ].cMensaje )
		endtry
		loEntidad.release()
	endfunc

enddefine

define class Uruguay_Accesor as Din_EntidadUruguay of Din_EntidadUruguay.prg
	lNuevo = .t.
	*-----------------------------------------------------------------------------------------
	function Init( t1, t2, t3, t4 ) As Boolean
	endfunc 
enddefine

define class ItemUruguayDetalleProvincia_Accesor as Din_ItemUruguayDetalleProvincia of Din_ItemUruguayDetalleProvincia.prg
	lNuevo = .t.
	lEsSubEntidad = .t.

	*-----------------------------------------------------------------------------------------
	function Init( t1, t2, t3, t4 ) As Boolean
	endfunc 
enddefine