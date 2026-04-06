define class zl_ValidadorModificacionPrecios as zooSession of zooSession.prg

oEntidad = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		This.oEntidad = toEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		This.oEntidad = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as Void
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneListasAnidadas() as Boolean
		return .F.
	endfunc 
enddefine

