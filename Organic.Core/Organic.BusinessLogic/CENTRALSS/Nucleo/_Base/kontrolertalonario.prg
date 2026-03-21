define class KontrolerTalonario as din_KontrolerTalonario of din_KontrolerTalonario.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar( "oEntidad.InformarTamanioTalonario", "AdvertenciaTamanioTalonario" )
	endfunc

	*-----------------------------------------------------------------------------------------
	Function Grabar() As Boolean
		local llRetorno as Boolean
		
		this.oEntidad.SetearCodigo()
		llRetorno = dodefault()
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function AdvertenciaTamanioTalonario( tnCantidad as Integer ) as Void
		if tnCantidad==0
			goMensajes.Advertir( "Atención: no hay números disponibles en este talonario." )
		endif
	endfunc 

enddefine

