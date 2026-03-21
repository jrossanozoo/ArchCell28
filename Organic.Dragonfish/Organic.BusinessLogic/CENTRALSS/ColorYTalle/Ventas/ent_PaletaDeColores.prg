define class Ent_PaletadeColores as Din_EntidadPaletaDeColores of Din_EntidadPaletaDeColores.Prg

	#IF .f.
		Local this as Ent_PaletadeColores of Ent_PaletadeColores.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function ColorValido( tcColor as String ) as Boolean
		local llRetorno as Boolean, lnI As Integer
		llRetorno = .F.
		for lnI = 1 to This.Colores.Count
			if llRetorno
				exit
			endif
			llRetorno = ( rtrim(tcColor) == rtrim(This.Colores.Item[lnI].Color_Pk) )
		EndFor
		return llRetorno
	endfunc 

enddefine
