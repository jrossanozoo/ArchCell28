define class ztestColaboradorArticuloTotalizador as FxuTestCase of FxuTestCase.prg
	
	#if .f.
		local this as ztestColaboradorArticuloTotalizador of ztestColaboradorArticuloTotalizador.PRG
	#endif
	
	oColaborador = null
	*-----------------------------------------------------------------------------------------
	function setup
		this.oColaborador = newobject( "ColaboradorTest" )
	endfunc
	*-----------------------------------------------------------------------------------------
	function teardown
		this.oColaborador = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTest_HayArticuloTotalizador
		local loEntidad as Object, loItem as Object
	
		loEntidad = newobject( "Factura_Fake" )

		loItem = newobject( "Item_fake" )
		with loItem
			.articulo_pk = "ART1"
			.articulo = newobject( "Articulo_fake" )
			.articulo.comportamiento = 0
			.Cantidad = 1
			.PrecioConImpuestos = 700.00 
			.PrecioSinImpuestos = 700.00 
			.Monto = 700.00 
			.Neto = 700.00 
		endwith
		loEntidad.FacturaDetalle.add( loItem )
		
		loItem = newobject( "Item_fake" )
		with loItem
			.articulo_pk = "TOT"
			.articulo = newobject( "Articulo_fake" )
			.articulo.comportamiento = 3
			.Cantidad = 1
		endwith
		loEntidad.FacturaDetalle.add( loItem )
		
		this.asserttrue( "El colaborador debió encontrar el artículo totalizador y devolver TRUE", this.oColaborador.HayArticuloTotalizador( loEntidad ) )		
		loEntidad = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTest_HacerBackupDeFacturaDetalle
		local loEntidad as Object, loItem as Object

		loEntidad = newobject( "Factura_Fake" )
		loItem = newobject( "Item_fake" )
		loItem.articulo_pk = "ART1"
		loItem.cantidad = 5
		loEntidad.FacturaDetalle.add( loItem )
		loEntidad.FacturaDetalle.sum_cantidad = 5
		
		this.oColaborador.HacerBackupDeFacturaDetalle_Fake( loEntidad )
		this.assertequals( "El colaborador debió hacer el backup de 1 item de FacturaDetalle.", 1, loEntidad.FacturaDetalle.count )	
		this.assertequals( "El colaborador no acumuló correctamente las cantidades.", 5, loEntidad.oDetalleFacturaBKP.sum_cantidadBKP )		
		loEntidad = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTest_VaciarFacturaDetalle
		local loEntidad as Object, loItem as Object
	
		loEntidad = newobject( "Factura_Fake" )
		
		loItem = newobject( "Item_fake" )
		loItem.articulo_pk = "ART1"
		loEntidad.FacturaDetalle.add( loItem )
		
		this.oColaborador.VaciarFacturaDetalle_Fake( loEntidad )
		this.assertequals( "El colaborador debió eliminar todos los items de FacturaDetalle.", 0, loEntidad.FacturaDetalle.count )		
		loEntidad = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTest_CargarFacturaDetalle
		local loEntidad as Object, loColeccionAux as zoocoleccion of zoocoleccion.prg, loItem as Object
	
		loEntidad = newobject( "Factura_Fake" )
		loColeccionAux = _screen.zoo.CrearObjeto( "ZooColeccion" )
		
		loItem = newobject( "Item_fake" )
		loItem.articulo_pk = "ART1"
		loItem.cantidad = 1
		loColeccionAux.Add( loItem )
		loItem = newobject( "Item_fake" )
		loItem.articulo_pk = "ART2"
		loItem.cantidad = 2
		loColeccionAux.Add( loItem )
		loItem = newobject( "Item_fake" )
		loItem.articulo_pk = "ART3"
		loItem.cantidad = 3
		loColeccionAux.Add( loItem )
		
		this.oColaborador.CargarFacturaDetalle_Fake( loEntidad, loColeccionAux )
		this.assertequals( "El colaborador debió agregar los items enviadoa a FacturaDetalle.", 3, loEntidad.FacturaDetalle.count )
		this.assertequals( "El colaborador no acumuló correctamente las cantidades.", 6, loEntidad.FacturaDetalle.sum_cantidad )	
				
		loEntidad = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztest_AplicarTotalizadores
		local oEntidad as Object, loDetalleImpresion as zoocoleccion of zoocoleccion.prg, loItem as Object
		
		loDetalleImpresion = _screen.zoo.CrearObjeto( "ZooColeccion" )
		
		loEntidad = newobject( "Factura_Fake" )
		this.oColaborador.VaciarFacturaDetalle_Fake( loEntidad )

		loItem = newobject( "Item_fake" )
		with loItem
			.articulo_pk = "ART1"
			.articulo = newobject( "Articulo_fake" )
			.articulo.comportamiento = 0
			.Cantidad = 1
			.PrecioConImpuestos = 700.00 
			.PrecioSinImpuestos = 700.00 
			.Monto = 700.00 
			.Neto = 700.00 
		endwith
		loEntidad.FacturaDetalle.add( loItem )
		
		loItem = newobject( "Item_fake" )
		with loItem
			.articulo_pk = "ART2"
			.articulo = newobject( "Articulo_fake" )
			.articulo.comportamiento = 0
			.Cantidad = 1
			.PrecioConImpuestos = 200.00 
			.PrecioSinImpuestos = 200.00 
			.Monto = 200.00 
			.Neto = 200.00 
		endwith
		loEntidad.FacturaDetalle.add( loItem )
		
		loItem = newobject( "Item_fake" )
		with loItem
			.articulo_pk = "TOT"
			.articulo = newobject( "Articulo_fake" )
			.articulo.comportamiento = 3
			.Cantidad = 1
		endwith
		loEntidad.FacturaDetalle.add( loItem )
		
		loItem = newobject( "Item_fake" )
		with loItem
			.articulo_pk = "ART3"
			.articulo = newobject( "Articulo_fake" )
			.articulo.comportamiento = 0
			.Cantidad = 1
			.PrecioConImpuestos = 880.00 
			.PrecioSinImpuestos = 880.00 
			.Monto = 880.00 
			.Neto = 880.00 
		endwith
		loEntidad.FacturaDetalle.add( loItem )

		this.oColaborador.AplicarTotalizadores_Fake( loEntidad, loDetalleImpresion )
		this.assertequals( "El colaborador incluir en 2 items en el detalle a imprimir.", 2, loDetalleImpresion.count )
		this.assertequals( "El primer item a imprimir debe ser el totalizador TOT.", "TOT", loDetalleImpresion.Item(1).articulo_pk )
		this.assertequals( "El segundo item a imprimir debe ser el artículo ART3.", "ART3", loDetalleImpresion.Item(2).articulo_pk )		
	endfunc 
	
enddefine


*-----------------------------------------------------------------------------------------
define class ColaboradorTest as ColaboradorArticuloTotalizador of ColaboradorArticuloTotalizador.prg

	*-----------------------------------------------------------------------------------------
	function HacerBackupDeFacturaDetalle_Fake( toEntidad ) as Void
		this.HacerBackupDeFacturaDetalle( toEntidad )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VaciarFacturaDetalle_Fake( toEntidad ) as Void
		this.VaciarFacturaDetalle( toEntidad )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function CargarFacturaDetalle_Fake( toEntidad, toColeccionAux ) as Void
		this.CargarFacturaDetalle( toEntidad, toColeccionAux )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function AplicarTotalizadores_Fake( toEntidad, toColeccionAux ) as Void
		this.AplicarTotalizadores( toEntidad, toColeccionAux  )
	endfunc 
	

enddefine

*-----------------------------------------------------------------------------------------
define class Factura_fake as custom

	FacturaDetalle = null
	oDetalleFacturaBKP = null
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.FacturaDetalle = newobject( "FacturaDetalle_fake" )
		this.oDetalleFacturaBKP = _screen.zoo.CrearObjeto( "ZooColeccion" )
		this.oDetalleFacturaBKP.addproperty( "sum_cantidadBKP" )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class FacturaDetalle_fake as zooColeccion of zooColeccion.prg

	oItem = null
	count = 0
	sum_cantidad = 0
	*-----------------------------------------------------------------------------------------
	function CargarItem( tnI as Integer ) as Void
		this.oitem = newobject( "Item_fake" )
		with this.oItem
			.articulo_pk = this.Item[ tnI ].Articulo_PK
			.articulo = this.Item[ tnI ].Articulo
			.Cantidad = this.Item[ tnI ].Cantidad
			.PrecioConImpuestos = this.Item[ tnI ].PrecioConImpuestos 
			.PrecioSinImpuestos = this.Item[ tnI ].PrecioSinImpuestos
			.Monto = this.Item[ tnI ].Monto 
			.Neto = this.Item[ tnI ].Neto 
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function ClonarItemAuxiliar( tnI as Integer ) as Object
		local loObjetoClonado as Object

		loObjetoClonado = newobject( "Item_fake" )
		loObjetoClonado.addproperty( "articulo_pk" )
		loObjetoClonado.articulo_pk = "ART1"
		return loObjetoClonado
	endfunc 
	*-----------------------------------------------------------------------------------------
	function RegenerarColeccionAgrupamientos() as Void
*!*			local lnI as Integer
*!*			with this
*!*				.oColAgrupamientos = Null
*!*				for lnI = 1 to .Count
*!*					if .ValidarExistenciaCamposFijosItemPlano( lnI )
*!*						.AgregarItemAColeccionAgrupada( .Item[lnI] )
*!*					endif
*!*				endfor
*!*			EndWith

	endfunc 



enddefine

*-----------------------------------------------------------------------------------------
define class Item_fake as custom

	articulo_pk = ""
	articulo = null
	Cantidad = 0
	PrecioConImpuestos = 0.00 
	PrecioSinImpuestos = 0.00 
	Monto = 0.00 
	Neto = 0.00 
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.articulo = newobject( "Articulo_fake" )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class Articulo_fake as custom

	codigo = ""
	comportamiento = 0
	*-----------------------------------------------------------------------------------------
	function Init() as Void
	endfunc 

enddefine
