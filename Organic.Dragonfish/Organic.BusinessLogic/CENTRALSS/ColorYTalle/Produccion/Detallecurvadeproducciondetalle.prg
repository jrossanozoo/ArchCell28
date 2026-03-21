define class DetalleCurvadeProduccionDetalle as Din_DetalleCurvadeproduccionDetalle of Din_DetalleCurvadeproduccionDetalle.prg

	#if .f.
		local this as DetalleCurvadeProduccionDetalle of DetalleCurvadeProduccionDetalle.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function ExisteColorEnDetalle() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		for each loItem in this FOXOBJECT
			if !empty(loItem.Color_PK)
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteTalleEnDetalle() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		for each loItem in this FOXOBJECT
			if !empty(loItem.Talle_PK)
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno
	endfunc 

enddefine
