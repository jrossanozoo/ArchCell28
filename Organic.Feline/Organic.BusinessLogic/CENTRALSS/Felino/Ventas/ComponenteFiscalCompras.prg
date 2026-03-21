define class ComponenteFiscalCompras as ComponenteFiscal of ComponenteFiscal.prg

	#If .F.
		Local This As ComponenteFiscalCompras Of ComponenteFiscalCompras.prg
	#Endif

	nSituacionFiscalProveedor = 0 
	cLetraComprobante = ""
	oEntidadPadre = null

	*-----------------------------------------------------------------------------------------
	function init( tcTipoDeComprobante as String ) as Void
		dodefault( tcTipoDeComprobante )
		this.oComponenteImpuestos.InyectarComponenteFiscal( this )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.nSituacionFiscalProveedor = This.oSFiscal.ConsumidorFinal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oEntidadPadre = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidadPadre( toEntidadPadre as Object ) as Void
		this.oEntidadPadre = toEntidadPadre
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionDeIvaDelArticulo( toItem as Object ) as Integer 
		return ( toItem.Articulo_CondicionIvaCompras )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeDeIvaDelArticulo( toItem as Object ) as Number 
		return ( toItem.Articulo_PorcentajeIvaCompras )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsArticuloGravado( toItem as Object ) as Boolean 
		return ( toItem.Articulo_CondicionIvaCompras != this.oTipoIVA.NoGravado )			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponenteImpuestos() as Object 
		return _screen.zoo.crearobjeto( "ComponenteImpuestosCompras" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearSituacionFiscalProveedor( tnSituacionFiscalCliente as Number ) as Void
		if empty( tnSituacionFiscalCliente )
			this.nSituacionFiscalProveedor = This.oSFiscal.ConsumidorFinal
		else
			this.nSituacionFiscalProveedor= tnSituacionFiscalCliente
		endif

		if type( "this.oComponenteImpuestos" ) = "O"
			this.oComponenteImpuestos.nSituacionFiscalCliente =  this.nSituacionFiscalProveedor
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeIVA( toItem as Object ) as Float
		local lnPorcIVA as Float
		if this.nSituacionFiscalProveedor = This.oSFiscal.Inscripto
			lnPorcIva = dodefault( toItem )
		else
			lnPorcIva = 0
		Endif
		return lnPorcIVA
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarImpuestos() as Boolean
		local llReturn as Boolean
		llRetorno = .t.

		if ((this.nSituacionFiscalEmpresa = this.oSFiscalEmpresa.Inscripto or this.PermiteFacturaAaMonotributistas() ) and this.nSituacionFiscalProveedor = this.oSFiscal.Inscripto and ;
			inlist( This.cLetraComprobante, 'A', 'M', 'X', 'R' ))  or (vartype( this.oEntidadPadre ) = "O" and  this.oEntidadPadre.TipoComprobanteRG1361 = 5)

			llRetorno = .f.
	
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function cLetraComprobante_Access() as String
		local lcRetorno as String
		if empty( This.cLetraComprobante ) and type( "This.oEntidadPadre" ) = 'O' and !isnull( This.oEntidadPadre ) and !( inlist( upper( alltrim( this.oEntidadPadre.cNombre ) ), "FACTURADECOMPRA", "NOTADECREDITOCOMPRA" ) and this.oEntidadPadre.TipoComprobanteRG1361 = 3 )
			lcRetorno = "A"
		else
			lcRetorno = This.cLetraComprobante
		endif
		return lcRetorno	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarLetraContraSituacionFiscalDelProveedor( tcLetra as String, toProveedor as din_entidadProveedor of din_entidadProveedor.prg ) as Boolean
		local llRetorno as Boolean, loLetras as zoocoleccion OF zoocoleccion.prg, lcLetra as String
		llRetorno = .f.
		loLetras = this.ObtenerLetrasValidasSegunSituacionFiscalDelProveedor( toProveedor )
		for each lcLetra in loLetras Foxobject
			if upper( lcLetra ) == upper( tcLetra )
				llRetorno = .t.
			endif
		endfor
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetrasValidasSegunSituacionFiscalDelProveedor( toProveedor as din_entidadProveedor of din_entidadProveedor.prg ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loProveedorLetraFiscal as Object
		
		loProveedorLetraFiscal = newobject( "proveedorletrafiscal", "proveedorletrafiscal.prg", "",;
			this.lComprobantesAMonotributistas, this.oComprobantes, this.oSFiscal, this.oSFiscalEmpresa, this.nSituacionFiscalEmpresa )
		
		loRetorno = loProveedorLetraFiscal.ObtenerLetraValidaSegunSituacionFiscalDelProveedor( toProveedor.situacionFiscal_Pk )
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerLetrasValidas( tcEntidad as String ) as String
		local lcRetorno as String, loProveedorLetraFiscal as Object
		
		loProveedorLetraFiscal = newobject( "proveedorletrafiscal", "proveedorletrafiscal.prg", "",;
			this.lComprobantesAMonotributistas, this.oComprobantes, this.oSFiscal, this.oSFiscalEmpresa, this.nSituacionFiscalEmpresa )
		lcRetorno = loProveedorLetraFiscal.ObtenerLetrasValidas( tcEntidad )
		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSituacionfiscalParaUnProveedor( tnSituacionFiscal as Integer ) as Boolean
		local llRetorno as Boolean
		llRetorno = !inList( tnSituacionFiscal, goRegistry.Felino.SituacionFiscalClienteConsumidorFinal, goRegistry.Felino.SituacionFiscalClienteLiberado, goRegistry.Felino.SituacionFiscalClienteInscriptoNoResponsable )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LetraFiscalValida( tcLetra as String ) as Boolean
		local loProveedorLetraFiscal as Object, llRetorno as Boolean, lcLetra as String, ;
			loLetras as zoocoleccion OF zoocoleccion.prg
		
		llRetorno = .f.
		loProveedorLetraFiscal = newobject( "proveedorletrafiscal", "proveedorletrafiscal.prg", "",;
			this.lComprobantesAMonotributistas, this.oComprobantes, this.oSFiscal, this.oSFiscalEmpresa, this.nSituacionFiscalEmpresa )
			
		loLetras = loProveedorLetraFiscal.ObtenerConjuntoDeLetrasFiscalesValidasParaFacturas()
		for each lcLetra in loLetras foxobject
			if lcLetra == tcLetra
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsCargaManualDePrecio( toItem as Object ) as Boolean
		return toItem.PreciodeLista = 0 or toItem.PreciodeLista <> this.nImporte
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestos( toDetalleComprobante as Detalle of detalle.prg, ;
			toDetalleImpuestos as detalle of detalle.prg ) as Void

		if this.TieneImpuestosManuales()
		else
			toDetalleImpuestos.Limpiar()
		endif
		this.VaciarColeccionDeImpuestos()
		dodefault( toDetalleComprobante, toDetalleImpuestos )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CalcularImpuestos( toItem as Object, toDetalleImpuestos as Object ) as Void
		if this.TieneImpuestosManuales()
		else
			DoDefault( toItem, toDetalleImpuestos )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneImpuestosManuales() as Boolean
		local llRetorno as Boolean
		llRetorno = this.oEntidadPadre.TieneImpuestosManuales()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarImpuestosManuales( toDetalle as zoocoleccion OF zoocoleccion.prg ) as Void
		This.ActualizarImpuestosManualesEnDetalleImpuestos( toDetalle )
		This.ProrratearImpuestosManualesEnDetalleDeArticulos( toDetalle )
		This.EventoDespuesDeActualizarImpuestosManuales()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarImpuestosManualesEnDetalleImpuestos( toDetalle as zoocoleccion OF zoocoleccion.prg ) as Void
		local lnTotalIVA as Double, lnMontoDeIva as Double
		lnTotalIVA = 0
		lnMontoDeIva = 0

		for lnItem = 1 to this.oImpuestosDetalle.Count
			lnMontoDeIva = toDetalle.Item[ lnItem ].MontoDeIva
			lnMontoDeIvaSinDescuento = toDetalle.Item[ lnItem ].MontoDeIva
			this.oImpuestosDetalle.CargarItem( lnItem )
			if this.oImpuestosDetalle.oItem.MontoDeIva = this.oImpuestosDetalle.Item[ lnItem ].MontoDeIvaSinDescuento
			else
				lnMontoDeIvaSinDescuento = lnMontoDeIva * this.oImpuestosDetalle.oItem.MontoDeIvaSinDescuento / this.oImpuestosDetalle.oItem.MontoDeIva
			endif

			this.oImpuestosDetalle.oItem.MontoDeIva = lnMontoDeIva
			this.oImpuestosDetalle.oItem.MontoDeIvaSinDescuento = lnMontoDeIvaSinDescuento
			this.oImpuestosDetalle.Actualizar()
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProrratearImpuestosManualesEnDetalleDeArticulos( toDetalle as zoocoleccion OF zoocoleccion.prg ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProrratearDescuentoEnDetalleDeImpuestos( tnTotalNeto as Integer, tnDescuento as Integer, toDetalle as detalle OF detalle.prg )
		for lnItem = 1 to this.oImpuestosDetalle.Count
			this.oImpuestosDetalle.CargarItem( lnItem )
			this.oImpuestosDetalle.oItem.MontoNoGravado = this.oImpuestosDetalle.oItem.MontoNoGravadoSinDescuento * (tnTotalNeto - tnDescuento) / tnTotalNeto
			this.oImpuestosDetalle.oItem.MontoDeIva = this.oImpuestosDetalle.oItem.MontoDeIvaSinDescuento * (tnTotalNeto - tnDescuento) / tnTotalNeto
			this.oImpuestosDetalle.Actualizar()
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeActualizarImpuestosManuales() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearPrecio( toItem as Object ) as Void
		with toItem
			.Precio = round( iif( This.MostrarImpuestos(), .PrecioConImpuestos, .PrecioSinImpuestos ), 4 )
		endwith
	endfunc  
	
	*-----------------------------------------------------------------------------------------
	protected function AsignarMontosDeImpuestos( toItem as Object ) as Void
		local	llMuestraImpuestos as boolean, lnCantidad as Float, lnMonto as Float, lnNeto as Float, lnBruto as float, lnPorcentajeDescuento as Float, ;
				lnPorcentajeMontoDescuento as Float, lnPorcentajeMontoDescuentoConImpuestos as Float, lnPorcentajeMontoDescuentoSinImpuestos as Float, ;
				lnMontoDescuento as Float, lnMontoDescuentoSinImpuestos as Float, lnMontoDescuentoConImpuestos as Float,;
				lnMontoVisualConImpuestos as float, lnMontoVisualSinImpuestos as float

		if this.TieneImpuestosManuales()
		else
			llMuestraImpuestos = this.MostrarImpuestos()
			lnCantidad	= toItem.Cantidad
			lnNeto		= toItem.PrecioSinImpuestos
			lnBruto		= toItem.PrecioConImpuestos
			lnPorcentajeImpuestos = this.oComponenteImpuestos.ObtenerPorcentajesDeImpuestos( toItem )

			*** Porcentaje de descuento ***
			lnPorcentajeDescuento = toItem.Descuento  && Porcentaje.
			lnPorcentajeMontoDescuentoConImpuestos = ( lnBruto * lnPorcentajeDescuento / 100 ) * lnCantidad
			lnPorcentajeMontoDescuentoSinImpuestos = ( lnNeto * lnPorcentajeDescuento / 100 ) * lnCantidad
			
			*** Monto de descuento ***
			lnMontoDescuento				= toItem.MontoDescuento * iif( lnCantidad < 0, -1, 1 )
			lnMontoDescuentoSinImpuestos	= iif( llMuestraImpuestos, lnMontoDescuento / ( 1 + ( lnPorcentajeImpuestos / 100 ) ), lnMontoDescuento )
			lnMontoDescuentoConImpuestos	= iif( llMuestraImpuestos, lnMontoDescuento, lnMontoDescuento * ( 1 + ( lnPorcentajeImpuestos / 100 ) ) )

			*** ASIGNACIONES ***
			with toItem
				.MontoPorcentajeDescuentoConImpuesto = lnPorcentajeMontoDescuentoConImpuestos
				.MontoPorcentajeDescuentoSinImpuesto = lnPorcentajeMontoDescuentoSinImpuestos
				.MontoDescuentoConImpuestos = lnMontoDescuentoConImpuestos
				.MontoDescuentoSinImpuestos	= lnMontoDescuentoSinImpuestos
				
				.Neto	= ( lnNeto * lnCantidad ) - lnPorcentajeMontoDescuentoSinImpuestos - lnMontoDescuentoSinImpuestos 
				.Bruto	= ( lnBruto * lnCantidad ) - lnPorcentajeMontoDescuentoConImpuestos - lnMontoDescuentoConImpuestos

				this.AsignarMontoInternoEnItem( toItem )
				.MontoIVA = .Bruto - .Neto - this.ObtenerMontoImpuestoInterno( toItem )
				.Impuestos = goLibrerias.RedondearSegunMascara( .MontoIVA )
				
				lnMontoVisualConImpuestos = goLibrerias.RedondearSegunMascara( .Bruto )
				lnMontoVisualSinImpuestos = goLibrerias.RedondearSegunMascara( .Neto )
				.Monto = iif( llMuestraImpuestos, lnMontoVisualConImpuestos, lnMontoVisualSinImpuestos )

				.AjustePorRedondeoSinImpuestos = round(( .Neto - lnMontoVisualSinImpuestos ), 4 )
				.AjustePorRedondeoConImpuestos = round(( .Bruto - lnMontoVisualConImpuestos ), 4 )
				
				&& Se usan en otro lado
				this.nImporte = .Neto
				this.nImporteIva = .MontoIVA
			endwith
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPercepciones() as Object
		loImp = _screen.Zoo.InstanciarEntidad( "Impuesto" )
		loColImpuestos = _screen.zoo.CrearObjeto( "ZooColeccion" )
		xmltocursor( loImp.oAD.obtenerdatosentidad( "codigo, tipo", "aplicacion = 'PRC' and tipo = 'IVA'",,,),"c_percepIva")
		scan
			loColImpuestos.Agregar( alltrim( c_PercepIva.tipo ) , alltrim( c_PercepIva.codigo ) )
		endscan
		use in select( "c_percepIva" )
		loImp.Release()
		return loColImpuestos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarIVALiquidacionesA() as Void

		with this.oImpuestosDetalle
			.oItem.PorcentajeDeIVA = this.oEntidadPadre.nPorcentajeIVALiquidacionA
			.oItem.MontoDeIVA = this.oEntidadPadre.Impuestos
			.oItem.MontoDeIVASinDescuento = this.oEntidadPadre.Impuestos
			.Actualizar()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PermiteFacturaAaMonotributistas() as Boolean
		local llRetorno as Boolean
		llRetorno = ((this.nSituacionFiscalEmpresa = this.oSFiscalEmpresa.Monotributo) and this.lComprobantesAMonotributistas )
		return llRetorno
	endfunc 

enddefine

