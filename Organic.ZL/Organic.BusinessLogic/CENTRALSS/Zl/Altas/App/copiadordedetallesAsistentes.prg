define class copiadordedetallesAsistentes as CopiadorDeDetalles of CopiadorDeDetalles.prg

	*-----------------------------------------------------------------------------------------
	function AntesDeInsertarDetalle( toDetalle as Object ) as Void
		local lnItem as Integer, lcSQL as String

		if toDetalle.Count > 0
			lnItem = toDetalle.Count

			do while lnItem > 0
				lcSQL = "select Activo from ZL.Legops where Ccod in ('" + upper( alltrim( toDetalle( lnItem ).Legajo_pk ) ) + "') and Activo = 0"
				goServicios.Datos.EjecutarSentencias( lcSQL, "", "", "c_Cursor", this.DataSessionId )

				if reccount( "c_Cursor" ) > 0
					toDetalle.Remove( lnItem )
				endif

				use in c_Cursor
				lnItem = lnItem - 1
			enddo
		endif
	endfunc

enddefine
