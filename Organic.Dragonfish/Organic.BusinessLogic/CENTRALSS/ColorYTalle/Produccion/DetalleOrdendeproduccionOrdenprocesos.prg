define class DetalleOrdendeproduccionOrdenprocesos as Din_DetalleOrdendeproduccionOrdenprocesos of Din_DetalleOrdendeproduccionOrdenprocesos.prg

	#if .f.
		local this as DetalleOrdendeproduccionOrdenprocesos of DetalleOrdendeproduccionOrdenprocesos.prg
	#endif

	oEntidad = null

	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.oItem.InyectarDetalle( this )
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidad = toEntidad
	endfunc 

enddefine
