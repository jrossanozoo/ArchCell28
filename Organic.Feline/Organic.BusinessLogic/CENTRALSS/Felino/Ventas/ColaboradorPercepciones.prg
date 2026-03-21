define class ColaboradorPercepciones as ZooSession of ZooSession.prg

	#if .f.
		local this as ColaboradorPercepciones as ColaboradorPercepciones.prg
	#endif

	oDatosFiscales = null
	nIvainscriptos = 0
	lEsAgenteDePercepcionIIBB = .f.
	lEsAgenteDePercepcionIVA = .f.
	lEsAgenteDePercepcionGANANCIAS = .f.

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.lDestroy = .t.
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerImpuesto( tcTipo as String  ) as Object
		local loRetorno as Object
		do case
			case tcTipo = "IIBB"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoPercepcionIIBB", "", this )
					this.lEsAgenteDePercepcionIIBB = .t.

			case tcTipo = "GANANCIAS"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoPercepcionGanancias", "", this )
					this.lEsAgenteDePercepcionGANANCIAS = .t.
			case tcTipo = "IVA"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoPercepcionIVA", "", this )
				this.lEsAgenteDePercepcionIVA = .t.
			otherwise
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoPercepcion", "", this )
		endcase
		loRetorno.nIvainscriptos = this.nIvainscriptos
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsAgenteDePercepcion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.EsAgenteDePercepcionSegunTipoDeImpuesto( "IIBB" )
		llRetorno = llRetorno or this.EsAgenteDePercepcionSegunTipoDeImpuesto( "GANANCIAS" )
		llRetorno = llRetorno or this.EsAgenteDePercepcionSegunTipoDeImpuesto( "IVA" )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsAgenteDePercepcionSegunTipoDeImpuesto( tcTipo as String ) as Boolean
	local llEsAgenteDePercepcionTipo as Boolean, llRetorno as Boolean
		llEsAgenteDePercepcionTipo = "this.lEsAgenteDePercepcion" + tcTipo
		llRetorno  = this.EstaSeteadoElParametroDeDatosFiscales() and &llEsAgenteDePercepcionTipo 
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstaSeteadoElParametroDeDatosFiscales() as Boolean
		return !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeTenerSeteadoNroDeIibbParaConvenioLocalOMultilateral() as Boolean
		return this.EstaSeteadoElParametroDeDatosFiscales() and this.oDatosFiscales.NroObligatorio
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeAutocompletarJurisdiccionesDePercepcionesEnClientes() as Boolean
		return this.EstaSeteadoElParametroDeDatosFiscales() and this.oDatosFiscales.AutocompletarJurisdic
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeAutocompletarPercepcionesDeAltoRiesgoFiscalEnClientes() as Boolean
		return this.EstaSeteadoElParametroDeDatosFiscales() and this.oDatosFiscales.AutocompletarPercRiesgo
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeTipoImpuesto( tcTipoImpuesto as String ) as String
		local loEntidad as Object, lcDescripcion as String
		lcDescripcion = ""
		if !empty( tcTipoImpuesto )
			loEntidad = _screen.Zoo.InstanciarEntidad( "TipoImpuesto" )
			try
				loEntidad.Codigo = tcTipoImpuesto
				lcDescripcion = alltrim( loEntidad.Descripcion )
			catch
			endtry
			loEntidad.Release()
		endif
		return lcDescripcion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InstanciarDatosFiscales() as Void
		if !this.lDestroy and vartype( this.oDatosFiscales ) # "O"
			if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
				this.oDatosFiscales = _screen.Zoo.InstanciarEntidad( "DatosFiscales" )
				this.oDatosFiscales.Codigo = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			endif
		endif
		return this.oDatosFiscales
	endfunc

enddefine
