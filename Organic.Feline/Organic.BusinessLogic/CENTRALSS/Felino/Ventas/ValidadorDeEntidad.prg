define class ValidadorDeEntidad as ZooSession of ZooSession.prg

	#IF .f.
		Local this as ValidadorDeEntidad of ValidadorDeEntidad.prg
	#ENDIF

	oEntidad = null

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		return DoDefault() And ( This.Class # "Entidad" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidad = toEntidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		This.oEntidad = null
		dodefault()
	endfunc 

enddefine

