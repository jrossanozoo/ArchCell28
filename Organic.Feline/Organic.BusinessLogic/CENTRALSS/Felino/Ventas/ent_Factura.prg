define class Ent_Factura as Din_EntidadFactura of Din_EntidadFactura.prg 
	*MOCK*cComprobante = "FACTURA"

	#if .f.
		Local this as Ent_Factura of Ent_Factura.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		this.cComprobante = "FACTURA"
		this.lPermiteComprobanteAsociado = .f.
		this.lImprimeNumeroDeDespachoDeArticulos = .T.
		this.lEsComprobanteConEntregaPosterior = .T.
		this.lAnularConUsuarioRestringido = .f.
		this.lUtilizaSecuenciaFiscal = .f.
		this.lObtenerCodigoGTIN = .f.
		this.lImprimir = .f.
		this.lAdvertirSiSuperaLimiteDeCredito = goServicios.Parametros.Felino.GestionDeVentas.CuentaCorriente.AdvertirAlSuperarElLimiteDeCredito
		this.lPermiteAgruparPacksAutomaticamente = .t.
		dodefault()
		if vartype( this.oComponenteFiscal ) != "O"
			this.oComponenteFiscal = _screen.Zoo.CrearObjeto( "ComponenteFiscalManualArgentina", "ComponenteFiscalManualArgentina.prg", this.cComprobante )
		endif
	endfunc 

enddefine
