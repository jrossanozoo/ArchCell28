define class KontrolerMaquinaria as Din_KontrolerMAQUINARIA of Din_KontrolerMAQUINARIA.prg

	#if .f.
		local this as KontrolerMaquinaria of KontrolerMaquinaria.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		DoDefault()
		bindevent( thisform.oentidad, "EventoHabilitarCaracteristicas", this, "HabilitarCaracteristicas", 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarCaracteristicas( tlHabilitar ) as Void
		thisform.oEntidad.lHabilitarMarca = tlHabilitar
		thisform.oEntidad.lHabilitarModelo = tlHabilitar
		thisform.oEntidad.lHabilitarSerie = tlHabilitar
	endfunc 

enddefine
