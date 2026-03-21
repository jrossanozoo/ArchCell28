**********************************************************************
Define Class zTestNocturnos_e2e_Produccion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestNocturnos_e2e_Produccion of zTestNocturnos_e2e_Produccion.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto = "0"
		goParametros.Felino.Generales.HabilitaControlStock = .f.
		goParametros.Felino.GestionDeVentas.Tarjetas.PedirDatosExtraDeTarjeta = .f.
		goParametros.Felino.Numeraciones.BocaDeExpendio = 90
		goParametros.Felino.ControladoresFiscales.PuntoDeVenta = 92
		lcFiltroWhere = "fPtoVen = 90"
*!*			goParametros.Felino.Precios.ListaDePrecios = 'LISTA1'
		goParametros.Felino.Precios.ListasDePrecios.ListaDePreciosPreferente = "LISTA1"
		goDatos.EjecutarSentencias( "Delete from Val where jjnum in (Select codigo from comprobantev where " + lcFiltroWhere + ")", "Val, comprobantev" )
		goDatos.EjecutarSentencias( "Delete from ImpVentas where ccod in (Select codigo from comprobantev where " + lcFiltroWhere + ") ", "ImpVentas, comprobantev" )
		goDatos.EjecutarSentencias( "Delete from comprobantevDet where codigo in (Select codigo from comprobantev where " + lcFiltroWhere + ") ", "comprobantevDet, comprobantev" )
		goDatos.EjecutarSentencias( "Delete from comprobantev where " + lcFiltroWhere, "comprobantev" )
		goDatos.EjecutarSentencias( "Delete from cajaSald", "cajaSald" )
	EndFunc
	
	*---------------------------------
	Function TearDown
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTest_00_DatosBasicos
		DefinirColor('BLANCO','Blanco')
		DefinirColor('NEGRO','Nergo')
		DefinirColor('AZUL','Azul')
		DefinirColor('VERDE','Verde')
		DefinirColor('.','...', .t.)
		DefinirTalle('S','Small')
		DefinirTalle('M','Medium')
		DefinirTalle('L','Large')
		DefinirTalle('XL','Extra Large')
		DefinirTalle('.','...', .t.)
		DefinirInventario('INTERNO1','Inventario interno 1')
		DefinirInventario('INTERNO2','Inventario interno 2')
		DefinirInventario('INTERNO3','Inventario interno 3')
		DefinirInventario('EXTERNO1','Inventario externo 1')
		DefinirInventario('EXTERNO2','Inventario externo 2')
		DefinirInventario('EXTERNO3','Inventario externo 3')
		DefinirInventario('EXTERNO4','Inventario externo 4')
		DefinirInventario('DESCARTE','Insumos descartados')
		DefinirInventario('OUTLET','Segunda seleccion')
		DefinirInventario('REUTILIZAR','Insumos para reutilizar')
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_EdicionDeFormulario
		local loEntidad as entidad OF entidad.prg, loError as Object
		loEntidad = _Screen.Zoo.InstanciarEntidad( "Factura" )
		With loEntidad
			.Nuevo()
			.ListaDePrecios_PK = 'LISTA1'
			.Vendedor_PK = '0000000001'
			.FacturaDetalle.Limpiar()
			.FacturaDetalle.oItem.Articulo_PK = "00100101"
			.FacturaDetalle.oItem.Cantidad = 15.51
			.FacturaDetalle.oItem.Precio = 123.04
			.FacturaDetalle.oItem.Descuento = 2.15
			.FacturaDetalle.Actualizar()
			.ValoresDetalle.Limpiar()
			.ValoresDetalle.oItem.Valor_PK = "VIRU"
			.ValoresDetalle.Actualizar()
			this.AssertEquals("Total despues de aplicar el valor antes de grabar",0,.Total)
			.Grabar()
			this.AssertEquals("Total despues de aplicar el valor despues de grabar",0,.Total)
		endwith
		With loEntidad
			.Ultimo()
			this.AssertEquals("Total antes de modificar",0,.Total)
			.Modificar()
			this.AssertEquals("Total despues de modificar",0,.Total)
			.ValoresDetalle.CargarItem(1)
			this.AssertEquals("Total despues de cargar el item",0,.Total)
			.Cancelar()
		endwith
		loEntidad.Release()
	EndFunc

EndDefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
function DefinirColor( tcCodigo as String, tcDescripcion as String, tlComodin as Boolean ) as Void
	local loEntidad as entidad OF entidad.prg, loError as Object
	tlComodin = iif(type('tlComodin')="L",tlComodin,.f.)
	loEntidad = _Screen.Zoo.InstanciarEntidad( "Color" )
	With loEntidad
		try
			.Codigo = tcCodigo
			.Modificar()
		catch to loError
			.Nuevo()
			.Codigo = tcCodigo
		finally
			.Descripcion = tcDescripcion 
			.EsComodinEnProduccion = tlComodin
			.Grabar()
		endtry
	EndWith
	loEntidad.Release()
endfunc 

*-----------------------------------------------------------------------------------------
function DefinirTalle( tcCodigo as String, tcDescripcion as String, tlComodin as Boolean ) as Void
	local loEntidad as entidad OF entidad.prg, loError as Object
	tlComodin = iif(type('tlComodin')="L",tlComodin,.f.)
	loEntidad = _Screen.Zoo.InstanciarEntidad( "Talle" )
	With loEntidad
		try
			.Codigo = tcCodigo
			.Modificar()
		catch to loError
			.Nuevo()
			.Codigo = tcCodigo
		finally
			.Descripcion = tcDescripcion 
			.EsComodinEnProduccion = tlComodin 
			.Grabar()
		endtry
	EndWith
	loEntidad.Release()
endfunc 

*-----------------------------------------------------------------------------------------
function DefinirInventario( tcCodigo as String, tcDescripcion as String ) as Void
	local loEntidad as entidad OF entidad.prg, loError as Object
	loEntidad = _Screen.Zoo.InstanciarEntidad( "Inventario" )
	With loEntidad
		try
			.Codigo = tcCodigo
			.Modificar()
		catch to loError
			.Nuevo()
			.Codigo = tcCodigo
		finally
			.Descripcion = tcDescripcion 
			.Grabar()
		endtry
	EndWith
	loEntidad.Release()
endfunc 


