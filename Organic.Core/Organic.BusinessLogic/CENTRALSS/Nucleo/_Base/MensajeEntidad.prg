define class MensajeEntidad as Custom

	#if .f.
		local this as MensajeEntidad of MensajeEntidad.prg
	#endif

	protected _nRespuesta as Integer
	_nRespuesta = 0
	oObjeto = null
	
	*-----------------------------------------------------------------------------------------
	function Init( toObjeto as Object ) as Void
		this.oObjeto = toObjeto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearRespuesta( tnRespuesta as Integer ) as Void
		this._nRespuesta = tnRespuesta 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRespuesta() as Void
		return this._nRespuesta
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Alertar( tcMensaje as string, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return this.Enviar( "Alertar", tcMensaje, tnBotones, tnBotonDefault, tcTitulo, tnTiempoEspera )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Advertir( tcMensaje as string, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return this.Enviar( "Advertir", tcMensaje, tnBotones, tnBotonDefault, tcTitulo, tnTiempoEspera )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Preguntar( tcMensaje as string, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return this.Enviar( "Preguntar", tcMensaje, tnBotones, tnBotonDefault, tcTitulo, tnTiempoEspera )	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Informar( tcMensaje as string, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return this.Enviar( "Informar", tcMensaje, tnBotones, tnBotonDefault, tcTitulo, tnTiempoEspera )	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensaje( tcTipoMensaje as String, toObjeto as object, tcMensaje as string, tnBotones as Integer, tnBotonDefault as Integer, tcTitulo as String, tnTiempo as Integer ) as Integer
		*** Evento que sirve para que le controler muestre un mensaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Enviar( tcTipoMensaje as String, tcMensaje as string, tnBotones as Integer, tnBotonDefault as Integer, tcTitulo as String, tnTiempo as Integer ) as Integer
		this._nRespuesta = 0
		this.EventoMensaje( tcTipoMensaje, this.oObjeto, tcMensaje, tnBotones, tnBotonDefault, tcTitulo, tnTiempo )

		this.DefaultRespuestaMensaje( tnBotones, tnBotonDefault )
		
		return this._nRespuesta
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DefaultRespuestaMensaje( tnBotones as Integer, tnBotonDefault as Integer ) as Void
		if this._nRespuesta = 0
			if empty( tnBotones )
				tnBotones = 0
			endif
			
			if empty( tnBotonDefault )
				tnBotonDefault = 0
			endif			
			
			do case
				case 	(tnBotones = 0) or;
						(tnBotones = 1 and tnBotonDefault = 0) or;
						(tnBotones = 6 and tnBotonDefault = 0)	
					this._nRespuesta = 1
				case 	(tnBotones = 1 and tnBotonDefault = 1) or;
						(tnBotones = 5 and tnBotonDefault = 1) or;
						(tnBotones = 6 and tnBotonDefault = 1) or;
						(tnBotones = 3 and tnBotonDefault = 2) or;
						(tnBotones = 10)	
					this._nRespuesta = 2	
				case 	tnBotones = 2 and tnBotonDefault = 0
					this._nRespuesta = 3
				case 	(tnBotones = 2 and tnBotonDefault = 1) or;
						(tnBotones = 5 and tnBotonDefault = 0)
					this._nRespuesta = 4				
				case 	tnBotones = 2 and tnBotonDefault = 2								
					this._nRespuesta = 5				
				case 	(tnBotones = 3 and tnBotonDefault = 0) or;
						(tnBotones = 4 and tnBotonDefault = 0)
					this._nRespuesta = 6
				case 	(tnBotones = 3 and tnBotonDefault = 1) or;
						(tnBotones = 4 and tnBotonDefault = 1)
					this._nRespuesta = 7				
			endcase
		endif		
	endfunc 	
enddefine
