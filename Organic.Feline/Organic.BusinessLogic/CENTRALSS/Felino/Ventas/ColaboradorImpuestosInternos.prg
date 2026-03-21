define class ColaboradorImpuestosInternos as ZooSession of ZooSession.prg

	#if .f.
		local this as ColaboradorImpuestosInternos as ColaboradorImpuestosInternos.prg
	#endif

	#define PRECISION 8
	
	protected cCodigoDeDatoFiscalAUtilizar
	cCodigoDeDatoFiscalAUtilizar = null
	
	oDatosFiscales = null
	TotalImpuestosInternos = 0
	lAplicaImpuestosInternos = .f.

	*-----------------------------------------------------------------------------------------
	function oDatosFiscales_Access() as Void
		if !this.lDestroy and (vartype( this.oDatosFiscales ) # "O" or isnull( this.oDatosFiscales ))
			if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
				this.oDatosFiscales = _screen.Zoo.InstanciarEntidad( "DatosFiscales" )
				this.oDatosFiscales.Codigo = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			endif
		endif
		return this.oDatosFiscales
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.ldestroy = .t.
		if vartype( this.oDatosFiscales ) = "O" and !isnull( this.oDatosFiscales )
			this.oDatosFiscales.Release()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function AplicaImpuestosInternos() as Boolean
		return this.lAplicaImpuestosInternos
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearSiAplicaImpuestosInternos() as Void
		this.lAplicaImpuestosInternos = this.EstaSeteadoElParametroDeDatosFiscales() and this.ExisteImpuestoInternoSeteadoEnDatosFiscales()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstaSeteadoElParametroDeDatosFiscales() as Boolean
		if isnull( this.cCodigoDeDatoFiscalAUtilizar )
			this.ObtenerYSetearParametroDeCodigoDeDatosFiscales()
		endif
		return !empty( this.cCodigoDeDatoFiscalAUtilizar )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteImpuestoInternoSeteadoEnDatosFiscales() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		if vartype( this.oDatosFiscales ) = "O" and !isnull( this.oDatosFiscales )
			
			local loDet as Object
			loDet = this.oDatosFiscales.PerceIIBB
			for each loItem in loDet foxObject
				if upper( alltrim( loItem.Aplicacion ) ) == "OTR" and upper( alltrim( loItem.Tipo_PK ) ) == alltrim( "IMPINTERNO" )
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTasaEfectiva( tnTasaNominal as Float ) as Float
		local lnRetorno as Float
		lnRetorno = round( (100 * tnTasaNominal) / (100 - tnTasaNominal ), PRECISION)
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerYSetearParametroDeCodigoDeDatosFiscales() as Void
		this.cCodigoDeDatoFiscalAUtilizar = goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar
	endfunc 

enddefine
