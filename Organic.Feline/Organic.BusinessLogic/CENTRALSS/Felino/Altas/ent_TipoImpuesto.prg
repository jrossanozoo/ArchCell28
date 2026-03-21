define class Ent_TipoImpuesto as Din_EntidadTipoImpuesto of Din_EntidadTipoImpuesto.prg


	*-----------------------------------------------------------------------------------------
	function EsTipoIngresosBrutos() as Boolean
		return (upper(alltrim(this.Codigo)) == "IIBB")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTipoGanancias() as Boolean
		return (upper(alltrim(this.Codigo)) == "GANANCIAS")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTipoValorAgregado() as Boolean
		return (upper(alltrim(this.Codigo)) == "IVA")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTipoSeguridadSocial() as Boolean
		return (upper(alltrim(this.Codigo)) == "SUSS")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTipoImpuestoInterno() as Boolean
		return (upper(alltrim(this.Codigo)) == "IMPINTERNO")
	endfunc 

enddefine
