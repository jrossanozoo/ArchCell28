define class Ent_CurvaDeTalles as Din_EntidadCurvaDeTalles of Din_EntidadCurvaDeTalles.Prg

	#IF .f.
		Local this as Ent_CurvaDeTalles of Ent_CurvaDeTalles.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function TalleValido( tcTalle as String ) as Boolean
		local llRetorno as Boolean, lnI As Integer
		llRetorno = .F.
		for lnI = 1 to This.Talles.Count
			if llRetorno
				exit
			endif
			llRetorno = ( rtrim(tcTalle) == rtrim(This.Talles.Item[lnI].Talle_Pk) )
		EndFor
		return llRetorno
	endfunc 

enddefine
