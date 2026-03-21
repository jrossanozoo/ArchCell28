define class LanzadorMensajesSilenciosos as LanzadorMensajes of LanzadorMensajes.prg
	
	#IF .f.
		Local this as LanzadorMensajesSilenciosos of LanzadorMensajesSilenciosos.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local loInfoMensaje as zooinformacion of zooInformacion.prg, lcMensaje as String, lnRetorno as Integer, lnI as Integer 
		
		loInfoMensaje = this.ObtenerInformacionParaMostrar( tvMensaje )			
		this.CrearFormularioInformacion( tnBotones, tnBotonDefault, tnIcono, tcTitulo, tnTiempoEspera )
		this.oForm.FormatearMensaje( loInfoMensaje )

		lnRetorno = this.oForm.oBotonDefault.nRespuesta
		this.oForm.Release()

		lcMensaje = iif( empty( tcTitulo ), this.ObtenerTitulo(), tcTitulo ) + chr( 13 ) + chr( 10 )
		
		lcMensaje = lcMensaje + loInfoMensaje.Item[ loInfoMensaje.Count ].cMensaje + chr( 13 ) + chr( 10 )
		for lnI = ( loInfoMensaje.Count - 1 ) to 1 step -1 foxobject
			lcMensaje = lcMensaje + chr( 9 ) + loInfoMensaje.Item[ lnI ].cMensaje + chr( 13 ) + chr( 10 )
		endfor
		
		this.Loguear( lcMensaje )			
		this.FinalizarLogueo()

		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarSinEspera( tcMensaje as String, tcTitulo as string, tcTextoBoton as String, tcIcono as String, tlNoHacePausa as Boolean ) as Void
	endfunc	
	
enddefine
