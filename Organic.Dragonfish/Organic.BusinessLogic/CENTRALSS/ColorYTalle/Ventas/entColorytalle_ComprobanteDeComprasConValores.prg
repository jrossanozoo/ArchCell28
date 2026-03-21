define class EntColorytalle_ComprobanteDeComprasConValores as Ent_ComprobanteDeComprasConValores of Ent_ComprobanteDeComprasConValores.prg

	#if .f.
		local this as EntColorytalle_ComprobanteDeComprasConValores of EntColorytalle_ComprobanteDeComprasConValores.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		if type( "This.FacturaDetalle" ) = "O"
			This.BindearEvento( This.FacturaDetalle, "EventoVerificarValidezArticulo" , This, "EventoVerificarExistenciaGrupo" ) 
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombresValidadores() as zoocoleccion 
		local loNombreDeValidadores as zoocoleccion OF zoocoleccion.prg
		
		loNombreDeValidadores = dodefault()
		loNombreDeValidadores.Add( "ValidadorComprobanteConValores_Grupo" )

		return loNombreDeValidadores
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoVerificarExistenciaGrupo( toArticulo as entidad OF entidad.prg ) as Boolean
		return This.oValidadores.VALIDADORCOMPROBANTECONVALORES_GRUPO.EventoVerificarExistenciaGrupo( toArticulo )
	endfunc 

enddefine
