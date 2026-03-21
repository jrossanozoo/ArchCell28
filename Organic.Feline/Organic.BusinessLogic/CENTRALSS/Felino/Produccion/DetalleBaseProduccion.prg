define class DetalleBaseProduccion as Detalle of Detalle.prg

	#If .F.
		Local This As DetalleBaseProduccion As DetalleBaseProduccion.prg
	#Endif

	oEntidad = null
	esDetalleEnProduccion = .f.
	esDetalleConCurvaDeProduccion = .f.
	lUsaClaveEnItem = .f.

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

	*-----------------------------------------------------------------------------------------
	function AgregarItemPlano( toItem as Object ) as Void
		local lcClave as String
		lcClave = this.ObtenerClaveParaItem( toItem )
		if empty( lcClave )
			dodefault( toItem )
		else
			with this
				if .ValidarCantidadItems() 
					.add( toItem, lcClave  )
				else
					goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
				endif
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClaveParaItem( toItem as Object ) as String
		return ''
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemAuxiliar() as Object
		local loItem as Object
		loItem = newobject('ItemAuxiliar', this.class+'.prg')
		return loItem
	endfunc 

enddefine
