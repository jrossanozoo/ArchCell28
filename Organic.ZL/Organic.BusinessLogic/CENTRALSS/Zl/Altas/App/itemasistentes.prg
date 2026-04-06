define class ItemAsistentes as ItemActivo of ItemActivo.prg

	*-----------------------------------------------------------------------------------------
	function ValidarLegajoActivo() as Boolean
		local llRetorno as Boolean

		with this
			llRetorno = .t.
			if alltrim( .Legajo_pk ) <> ""
				.Legajo.Codigo = upper( alltrim( .Legajo_pk ) )
				if !.Legajo.UsuarioActivo
					llRetorno = .f.
					goServicios.Errores.LevantarExcepcion( "El asistente ingresado no está activo en ZL." )
				endif
			endif
		endwith

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_Legajo( txVal as variant, txValOld as variant ) as Boolean
		return this.ValidarLegajoActivo() and dodefault( txVal, txValOld )
	endfunc

enddefine
