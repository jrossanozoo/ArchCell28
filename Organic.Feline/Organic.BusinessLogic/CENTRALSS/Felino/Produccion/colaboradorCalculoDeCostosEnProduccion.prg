define class colaboradorCalculoDeCostosEnProduccion as ZooSession of ZooSession.prg

	#IF .f.
		Local this as colaboradorCalculoDeCostosEnProduccion of colaboradorCalculoDeCostosEnProduccion.prg
	#ENDIF

	cNombreEntidad = ""
	cCamposDeCombinacionConcatenados = ""
	UsaCombinacion = .F.
	oFormula = null
	oEntidadPadre = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		this.oEntidadPadre = toEntidad
	endfunc 	

	*-----------------------------------------------------------------------------------------
	Function Destroy() As void
		This.oEntidadPadre = Null
		DoDefault()
	Endfunc		

	*-----------------------------------------------------------------------------------------
	function cCamposDeCombinacionConcatenados_Access() as String
		if !this.lDestroy and empty( this.cCamposDeCombinacionConcatenados )
			this.cCamposDeCombinacionConcatenados = this.ObtenerCamposDeCombinacionConcatenados()
		endif
		return this.cCamposDeCombinacionConcatenados
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposDeCombinacionConcatenados() as String
		local lcRetorno as String
		lcRetorno = "insumo + ccolor + talle + taller + proceso"
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompletarDatosDeEntidadPadre() as Void
		local ldFAltaFW as Date, lhHAltaFW as Time
		ldFAltaFW = this.oEntidadPadre.FechaAltaFW
		lhHAltaFW = this.oEntidadPadre.HoraAltaFW
		replace all FAltaFW with ldFAltaFW, ;
				HAltaFW with lhHAltaFW
	endfunc 

enddefine
