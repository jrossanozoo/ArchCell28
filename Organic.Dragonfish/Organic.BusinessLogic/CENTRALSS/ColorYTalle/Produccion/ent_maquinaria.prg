define class Ent_Maquinaria as din_EntidadMaquinaria of din_EntidadMaquinaria.prg

	#if .f.
		local this as Ent_Maquinaria of Ent_Maquinaria.prg
	#endif

	*--------------------------------------------------------------------------------------------------------
	function Setear_TipoMaquinaria( txVal as variant ) as void

		local llHaCambiado as Boolean
		llHaCambiado = txVal # this.TipoMaquinaria
		dodefault( txVal )
		if this.CargaManual() and (this.EsNuevo() or this.EsEdicion())
			if llHaCambiado and txVal # 1
				this.EventoHabilitarCaracteristicas( .t. )
				this.Marca = ''
				this.Modelo = ''
				this.Serie = ''
			endif
			this.EventoHabilitarCaracteristicas( txVal  == 1 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoHabilitarCaracteristicas( tlHabilitar ) as Void
	endfunc 

enddefine

