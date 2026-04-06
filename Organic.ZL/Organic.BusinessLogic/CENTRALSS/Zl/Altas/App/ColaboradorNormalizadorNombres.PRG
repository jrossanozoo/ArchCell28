define class ColaboradorNormalizadorNombres as  zoosession of zoosession.prg

	*-----------------------------------------------------------------------------------------
	Function Procesar( tctexto as string  ) as void
		local lcCursor as String, lcSQL as String, lcret as String 
		lcret = alltrim( tctexto )
		if !empty(lcret)
			lcCursor = "C" + sys( 2015 )
			text to lcSQL textmerge noshow
				select convert( varchar(254), [ZL].[func_NormalizarNombre]('<<alltrim( lcret )>>') ) as lcret
			endtext 
			goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, this.DataSessionId )
			if used( lcCursor ) and reccount( lcCursor ) > 0
				lcret = alltrim( &lcCursor..lcret )
			endif
			use in select( lcCursor )
		endif
		return lcret
	endfunc 

enddefine
