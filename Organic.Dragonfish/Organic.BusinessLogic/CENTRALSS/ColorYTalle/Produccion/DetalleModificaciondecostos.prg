Define Class detalleModificacionDeCostos as Detalle of Detalle.prg

	#If .F.
		Local This As detalleModificacionDeCostos As detalleModificacionDeCostos.prg
	#Endif
	
	oEntidad = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad As Object ) as Void
		This.oEntidad = toEntidad
		This.oItem.InyectarEntidad( toEntidad )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsModoEdicion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.CargaManual() and iif(pemstatus(This,"oEntidad",5),vartype(This.oEntidad) # 'O' or (This.oEntidad.EsNuevo() or This.oEntidad.EsEdicion()),.t.) && )((pemstatus(This,"oEntidad",5) This.oEntidad) = null or (This.oEntidad.EsNuevo() or This.oEntidad.EsEdicion()))
		return llRetorno
	endfunc 

EndDefine
