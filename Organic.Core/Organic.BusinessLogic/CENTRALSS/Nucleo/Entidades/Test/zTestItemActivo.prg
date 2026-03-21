**********************************************************************
Define Class zTestItemActivo As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestItemActivo Of zTestItemActivo.prg
	#Endif

	*---------------------------------
	Function zTestInstanciar
		local loItemActivo as ItemActivo of ItemActivo.prg

		try
			loItemActivo = _Screen.zoo.crearobjeto( "ItemActivo" )
		catch
		endtry
		
		this.Assertequals( "No se instancio", "L", vartype( loItemActivo ) )

		loItemActivo = newobject( "TestItemActivo" )
		this.Assertequals( "No se instancio", "O", vartype( loItemActivo ) )
		this.Assertequals( "No se instancio el objecto validacionDominios", "O", vartype( loItemActivo.oValidacionDominios ) )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEsNuevo
		local loItem as ItemActivo of ItemActivo.prg, llRetorno as Boolean

		loItem = _screen.zoo.crearobjeto( "Din_ItemRusiaRepublicas" )
		loItem.lNuevo = .t.
		llRetorno = loItem.EsNuevo()
		this.assertequals( "La función EsNuevo no devolvió True", .t., llRetorno )
		loItem.lNuevo = .f.
		llRetorno = loItem.EsNuevo()
		this.assertequals( "La función EsNuevo no devolvió False", .f., llRetorno )

		loItem.Destroy()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestCargaManual
		local loItem As ItemActivo of ItemActivo.Prg
		loItem = newobject( "AuxCargaMAnual" )
		loItem.lCargando = .T.
		loItem.lLimpiando = .T.
		loItem.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .T., lDestroy = .T.", !loItem.CargaManual() )
		loItem.lCargando = .T.
		loItem.lLimpiando = .F.
		loItem.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .F., lDestroy = .T.", !loItem.CargaManual() )
		loItem.lCargando = .T.
		loItem.lLimpiando = .T.
		loItem.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .T., lDestroy = .F.", !loItem.CargaManual() )
		loItem.lCargando = .T.
		loItem.lLimpiando = .F.
		loItem.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .F., lDestroy = .F.", !loItem.CargaManual() )
		loItem.lCargando = .F.
		loItem.lLimpiando = .T.
		loItem.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .T., lDestroy = .T.", !loItem.CargaManual() )
		loItem.lCargando = .F.
		loItem.lLimpiando = .F.
		loItem.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .F., lDestroy = .T.", !loItem.CargaManual() )
		loItem.lCargando = .F.
		loItem.lLimpiando = .T.
		loItem.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .T., lDestroy = .F.", !loItem.CargaManual() )
		loItem.lCargando = .F.
		loItem.lLimpiando = .F.
		loItem.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .F., lDestroy = .F.", loItem.CargaManual() )
		loItem = Null
		
	endfunc 
		*-----------------------------------------------------------------------------------------
	function zTestCambioCombinacion
		local loItem As ItemActivo of ItemActivo.Prg
		loItem = newobject( "AuxCargaManual" )
		This.AssertTrue( "No existe la Firma del CambioCombinacion", pemstatus( loItem, "CambioCombinacion", 5) )
		loItem = Null

	endfunc 
		*-----------------------------------------------------------------------------------------
	function zTestElementoAnterior
		local loItem as ItemActivo of ItemActivo.prg, lcRetorno as String, lnRetorno as Number

		loItem = _screen.zoo.crearobjeto( "Din_ItemCanadaDetallecanada" )
		loItemAnterior = _screen.zoo.crearobjeto( "Din_ItemCanadaDetallecanada" )
		loItemAnterior.Gobernador = "Pepe"
		loItemAnterior.Codigo = 123
		loItemAnterior.Precio = 456
		loItem.oItemAnterior = loItemAnterior
		loItem.lNuevo = .t.
		lcRetorno = loItem.ElementoAnterior('Gobernador')
		lnRetorno = loItem.ElementoAnterior('Codigo')
		this.assertequals( "La función Elemento Anterior no devolvió Pepe", "Pepe", lcRetorno )
		this.assertequals( "La función Elemento Anterior no devolvió 123", 123, lnRetorno )
		loItem.lNuevo = .f.

		loItem.Destroy()
	endfunc 

enddefine

******************************************************************
define class AuxCargaManual as ItemActivo of ItemActivo.prg
	*-----------------------------------------------------------------------------------------
	function Init() as Void
	endfunc 
enddefine
*********************************
define class TestItemActivo as ItemActivo of ItemActivo.prg

enddefine

