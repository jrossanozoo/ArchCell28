define class EjecutorZLServicioREST as Din_ejecutorserviciorest of Din_ejecutorserviciorest.prg

	lMaster = .f.
	oOperacionesZlSeries = null
	oOperacionesZlRazonSociales = null
	oOperacionesZlClientes = null
	oOperacionesFacturacion = null
	oOperacionesContactos = null
	oOperacionesMail = null
	
	*-----------------------------------------------------------------------------------------
	function Init( toEntidadConfiguracion as Din_EntidadSERVICIOREST of Din_EntidadSERVICIOREST.prg, tlMaster as Boolean ) as Void
		dodefault( toEntidadConfiguracion )
		this.lMaster = tlMaster
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oOperacionesZlSeries_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOperacionesZlSeries ) = 'O' or isnull( this.oOperacionesZlSeries ) )
			this.oOperacionesZlSeries = _screen.zoo.crearObjeto( "ServicioRestOperacionesZlSeries" )
		endif
		return this.oOperacionesZlSeries 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambiarNombre( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesEntidadZlseries, "CambiarNombre", tcRequest )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSeriesCliente( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlSeries , "ObtenerSeriesCliente", tcRequest ) &&ObtenerSeriesCliente
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerArticulosPorRazonSocialYProducto( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlSeries , "ObtenerArticulosPorRazonSocialYProducto", tcRequest ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerArticulosPorSerie( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlSeries , "ObtenerArticulosPorSerie", tcRequest ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerArticulosPorSerieParaModificar( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlSeries , "ObtenerArticulosPorSerieParaModificar", tcRequest )
	endfunc

	*-----------------------------------------------------------------------------------------
	function oOperacionesZlRazonSociales_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOperacionesZlRazonSociales ) = 'O' or isnull( this.oOperacionesZlRazonSociales ) )
			this.oOperacionesZlRazonSociales = _screen.zoo.crearObjeto( "ServicioRestOperacionesZlRazonSociales" )
		endif
		return this.oOperacionesZlRazonSociales
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRazonesSocialesDelCliente( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlRazonSociales, "ObtenerRazonesSocialesDelCliente", tcRequest ) &&ObtenerRazonesSocialesDelCliente
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerContribuyentePadronAFIPWS( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlRazonSociales, "ObtenerContribuyentePadronAFIPWS", tcRequest ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSeriesProductosParaRazonesSocialesPorCliente( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlRazonSociales, "ObtenerSeriesProductosParaRazonesSocialesPorCliente", tcRequest ) 
	endfunc
				
	*-----------------------------------------------------------------------------------------
	function oOperacionesZlClientes_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOperacionesZlClientes ) = 'O' or isnull( this.oOperacionesZlClientes ) )
			this.oOperacionesZlClientes = _screen.zoo.crearObjeto( "ServicioRestOperacionesZlClientes" )
		endif
		return this.oOperacionesZlClientes
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoDeClienteParaZnube( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlClientes, "ObtenerCodigoDeClienteParaZnube", tcRequest ) &&ObtenerCodigoDeClienteParaZnube
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerRazonSocialxSeriexCliente( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlSeries, "ObtenerRazonSocialxSeriexCliente", tcRequest )
	endfunc
	*-----------------------------------------------------------------------------------------
	function ReenviarMailPendiente( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesZlRazonSociales, "ReenvioMailTerminosYCondiciones", tcRequest )
	endfunc

	*-- Facturación -----------------------------------------------------------------------------------------------------------------------------------------------
	*-----------------------------------------------------------------------------------------
	function oOperacionesFacturacion_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOperacionesFacturacion ) = 'O' or isnull( this.oOperacionesFacturacion ) )
			this.oOperacionesFacturacion = _screen.zoo.crearObjeto( "ServicioRestOperacionesFacturacion" )
		endif
		return this.oOperacionesFacturacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerComprobantesPagos( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesFacturacion, "ObtenerComprobantesPagos", tcRequest )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDeudas( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesFacturacion, "ObtenerDeudas", tcRequest )
	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerFacturaEstimadaCliente( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesFacturacion, "ObtenerFacturaEstimadaCliente", tcRequest )
	endfunc
	
	
	*-- Contactos -----------------------------------------------------------------------------------------------------------------------------------------------
	*-----------------------------------------------------------------------------------------
	function oOperacionesContactos_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOperacionesContactos ) = 'O' or isnull( this.oOperacionesContactos ) )
			this.oOperacionesContactos = _screen.zoo.crearObjeto( "ServicioRestOperacionesContactos" )
		endif
		return this.oOperacionesContactos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMailsContactos( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesContactos, "ObtenerMailsContactos", tcRequest )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMailsContactosParaRazonesSociales( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesContactos, "ObtenerMailsContactosEnRazonSocial", tcRequest )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oOperacionesMail_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOperacionesMail ) = 'O' or isnull( this.oOperacionesMail ) )
			this.oOperacionesMail = _screen.zoo.crearObjeto( "ServicioRestOperacionesMail" )
		endif
		return this.oOperacionesMail 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesvincularMail( tcRequest as String ) as Object
		return this.EjecutarOperacion( this.oOperacionesMail, "DesvincularMail", tcRequest )
	endfunc 	
	
enddefine
