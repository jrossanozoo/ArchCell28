define class ItemBaseProduccion as ItemActivo of ItemActivo.prg

	#If .F.
		Local This As ItemBaseProduccion As ItemBaseProduccion.prg
	#Endif

	oEntidad = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad As Object ) as Void
		This.oEntidad = toEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsModoEdicion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.CargaManual() and iif(pemstatus(This,"oEntidad",5),vartype(This.oEntidad) # 'O' or (This.oEntidad.EsNuevo() or This.oEntidad.EsEdicion()),.t.) && )((pemstatus(This,"oEntidad",5) This.oEntidad) = null or (This.oEntidad.EsNuevo() or This.oEntidad.EsEdicion()))
		return llRetorno
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		function ObtenerClaveParaItem( toItem as Object ) as String
*!*			local lcRetorno as String
*!*			lcRetorno = ''
*!*			return lcRetorno
*!*		endfunc 

enddefine
