define class ent_ServidoresComunicaciones as Din_EntidadServidoresComunicaciones of Din_EntidadServidoresComunicaciones.prg
	#if .f.
		local this as ent_ServidoresComunicaciones of ent_ServidoresComunicaciones.prg
	#endif
	
	lSeAsignoPorPrimeraVez = .f.

	*-----------------------------------------------------------------------------------------
	function LuegoDeAsignarMetodo() as Void
		this.lHabilitarServidorCheckline = .T.
		this.lHabilitarServidoreHost = .T.
		this.lHabilitarModoPasivo = .T.
		this.lHabilitarPuertoControlServidor = .T.
		this.lHabilitarTipoEnvioDeDatos = .T.
		
		this.lHabilitarBucket = .F.
		this.lHabilitarRegion = .F.
		this.lHabilitarAccessKey = .F.
		this.lHabilitarSecretKey = .F.
			
		do case
			case empty( this.Metododecomunicacion ) or this.Metododecomunicacion = 1  && SMTP
				this.ServidorCheckline = .F.
				this.ServidoreHost = .F.

				this.lHabilitarModoPasivo = .F.
				this.lHabilitarServidorCheckline = .F.
				this.lHabilitarServidorEHost = .F.
				this.lHabilitarPuertoControlServidor = .F.
				this.lHabilitarTipoEnvioDeDatos = .F.
			case this.Metododecomunicacion = 2
				if !this.lSeAsignoPorPrimeraVez
					this.PuertoControlServidor = 21
					this.TipoEnvioDeDatos = goParametros.ZL.valoresSugeridos.TransferenciaDeDatosFTPSugerida
					this.ModoPasivo = .t.
					this.lSeAsignoPorPrimeraVez = .t.
				endif
			case this.Metododecomunicacion = 3
				this.ServidorCheckline = .F.
				this.ServidoreHost = .F.

				this.lHabilitarModoPasivo = .F.
				this.lHabilitarServidorCheckline = .F.
				this.lHabilitarServidorEHost = .F.
				this.lHabilitarPuertoControlServidor = .F.
				this.lHabilitarTipoEnvioDeDatos = .F.
			
			
				this.lHabilitarBucket = .T.
				this.lHabilitarRegion = .T.
				this.lHabilitarAccessKey = .T.
				this.lHabilitarSecretKey = .T.
		endcase
		
	endfunc 
	*--------------------------------------------------------------------------------------------------------
enddefine