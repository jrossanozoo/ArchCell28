define class ComponenteFiscalManual as ComponenteFiscalVentas of ComponenteFiscalVentas.prg

	#IF .f.
		Local this as ComponenteFiscalManual of ComponenteFiscalManual.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Init( tcTipoDeComprobante as String ) as Boolean

		llRetorno = !( This.Class == "Componentefiscalmanual" )
		If llRetorno
			llRetorno = dodefault( tcTipoDeComprobante )
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPuntoDeVenta( tcletra, tctipoComprobante, tcFuncionalidades ) as integer
		local lnRetorno as Integer
		lnRetorno = dodefault( tcletra, tctipoComprobante, tcFuncionalidades )
		if empty( lnRetorno )
			lnRetorno = this.nBocaDeExpendio
		endif
		return lnRetorno
	endfunc
	
enddefine

