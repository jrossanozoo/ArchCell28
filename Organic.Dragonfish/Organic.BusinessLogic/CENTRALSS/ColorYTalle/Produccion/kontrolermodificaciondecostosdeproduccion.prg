define class kontrolerModificacionDeCostosDeProduccion as Din_kontrolerModificacionDeCostosDeProduccion Of Din_kontrolerModificacionDeCostosDeProduccion.prg

	#if .f.
		local this as KontrolerModificacionPrecios of KontrolerModificacionPrecios.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		if vartype( this.oEntidad ) == "O"
			this.BindearEvento( this.oEntidad, "EventoMensajeAletarVersionSQL", this, "MensajeAletarVersionSQL" )
		endif
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MensajeAletarVersionSQL() as Void
		goMensajes.Alertar('Para usar costos en el modulo de producción debe actualizar el motor de base de datos a SQL Server 2022')
	endfunc 

enddefine
