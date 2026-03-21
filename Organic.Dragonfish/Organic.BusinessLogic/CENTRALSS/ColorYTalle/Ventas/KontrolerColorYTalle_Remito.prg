Define Class KontrolerColorYTalle_Remito As KontrolerRemito Of KontrolerRemito.prg 

	#IF .f.
		Local this as KontrolerColorYTalle_Remito of KontrolerColorYTalle_Remito.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreTransferencia() as String
		return alltrim( this.oEntidad.ObtenerNombreTransferencia() )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarRemitoComoRemito() as Void
		this.oEntidad.cNombreTransferencia = "REMITO"
		this.EjecutarTransferencia()		
		this.oEntidad.cNombreTransferencia = "REMXMOVTRANS"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarRemitoComoRemXMovTrans() as Void
		this.oEntidad.cNombreTransferencia = "REMXMOVTRANS"
		this.EjecutarTransferencia()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ActualizarBarra( tcEstado ) As Void
	
		dodefault( tcEstado )
		this.SetearEnabledMenu( "archivo", "TransferenciaRemito", this.ObtenerEnabledMenu ( "archivo", "Transferencia " ) )

	endfunc
	
enddefine
