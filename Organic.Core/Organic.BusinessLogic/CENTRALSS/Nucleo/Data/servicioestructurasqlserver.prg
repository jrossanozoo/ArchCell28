define class ServicioEstructuraSqlServer as ServicioEstructura Of ServicioEstructura.prg

	#IF .f.
		Local this as ServicioEstructuraSqlServer of ServicioEstructuraSqlServer.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function ObtenerXmlEstructura() as Void
		return this.oDinEstructuraAdn.ObtenerSqlServer()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEsquema( tcTabla as String ) as String
		local lcRetorno as String, loEstructura as zoocoleccion OF zoocoleccion.prg

		lcRetorno = ""
		
		if !empty( tcTabla )
			loEstructura = this.ObtenerEstructuraTabla( tcTabla )

			if loEstructura.Count > 0
				lcRetorno = loEstructura[1].Esquema
				if empty( lcRetorno )
					lcRetorno = _screen.zoo.app.cSchemaDefault
				endif
			endif
		endif
				
		return alltrim( lcRetorno )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CopiarTablasSucursal( tcRutaOrigen as String, tcRutaDestino as String, tcSucursalOrigen as String, tcSucursalDestino as String ) as Void
		this.oDinEstructuraAdn.CopiarTablasSucursalSqlServer( tcRutaOrigen, tcRutaDestino, tcSucursalOrigen, tcSucursalDestino )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTablaConEsquema( tcTabla as String ) as String
		tcTabla = alltrim( tcTabla )
		return this.ObtenerEsquema( tcTabla ) + "." + tcTabla
	endfunc 
enddefine