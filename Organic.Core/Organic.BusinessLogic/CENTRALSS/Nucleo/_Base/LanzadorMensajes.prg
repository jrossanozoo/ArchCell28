define class LanzadorMensajes as zooSession of zooSession.prg

	#IF .f.
		Local this as LanzadorMensajes of LanzadorMensajes.prg
	#ENDIF

	oForm = null
	oMensajeSinEspera = null
	DataSession = 1
	
	*-----------------------------------------------------------------------------------------
	function CrearFormularioInformacion( tnBotones as Integer, tnBotonDefault as Integer, tnIcono as Integer, tcTitulo as String, tnTiempoEspera as Integer ) as Void
		local loFrm as FormInformacion of FormInformacion.prg
		
		if type( "_screen.ActiveForm" ) = 'O'
			this.oForm = _screen.zoo.crearobjeto( "formInformacion","formInformacion.prg", tnBotones, tnBotonDefault, tnIcono, tcTitulo, tnTiempoEspera )
		else
			this.oForm = _screen.zoo.crearobjeto( "formInformacionIndividual","formInformacionIndividual.prg", tnBotones, tnBotonDefault, tnIcono, tcTitulo, tnTiempoEspera )
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oForm = null
		this.oMensajeSinEspera = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oForm = null
		this.oMensajeSinEspera = null

		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerInformacionParaMostrar( tvMensaje as Object ) as zooinformacion of zooInformacion.prg
		local loRetorno as zooinformacion of zooInformacion.prg
		
		if vartype( tvMensaje ) = "O"
			do case

				case alltrim( upper( tvMensaje.class ) ) = "ZOOEXCEPTION"
			
					if tvMensaje.oInformacion.Count = 0
						if empty( tvMensaje.AgregarInformacion( tvMensaje.Message ) )
							tvMensaje.AgregarInformacion( tvMensaje.cStackInfo )
							tvMensaje.AgregarInformacion( "Error de aplicación." )
							loRetorno = tvMensaje.oInformacion
						else
							loRetorno = _Screen.zoo.CrearObjeto( "ZooInformacion" )
							loRetorno.Agregarinformacion( tvMensaje.Message )
						endif 
					else
						loRetorno = tvMensaje.oInformacion
					endif
					

				case alltrim( upper( tvMensaje.class )) = "ZOOINFORMACION"
					if tvMensaje.Count = 0
						tvMensaje.AgregarInformacion( "Se ha enviado una información vacía." )
						tvMensaje.AgregarInformacion( "Error de aplicación." )
					endif
					loRetorno = tvMensaje

				case alltrim( upper( tvMensaje.class ) ) = "EXCEPTION"
					loRetorno = this.ObtenerMensajeDeError( tvMensaje )
					
				otherwise 
					loRetorno = _Screen.zoo.CrearObjeto( "ZooInformacion" )
					loRetorno.AgregarInformacion( "Se ha enviado un objeto incorrecto." )
					loRetorno.AgregarInformacion( "Error de aplicación." )
			endcase
		else
			loRetorno = _Screen.zoo.CrearObjeto( "ZooInformacion" )
			loRetorno.AgregarInformacion( tvMensaje )
		endif

		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeDeError( toError as Exception ) as zooinformacion of zooInformacion.prg
		local loRetorno as zooinformacion of zooInformacion.prg
		
		if vartype( toError.UserValue ) = "O"
			loRetorno = this.ObtenerMensajeDeError( toError.UserValue )
		else
			if vartype( toError.oInformacion ) = "O" and toError.oInformacion.Count > 0
				loRetorno = toError.oInformacion
			else
				loRetorno = _Screen.zoo.CrearObjeto( "ZooInformacion" )
				loRetorno.AgregarInformacion( toError.Message )
				loRetorno.AgregarInformacion( "Error de aplicación." )
			endif
		endif
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerTitulo() As String
		Local lcRetorno As String
		Store "Zoo Logic" To lcRetorno

		If Pemstatus( _Screen, "Zoo", 5 ) And Vartype( _Screen.Zoo ) = "O"
			If Pemstatus( _Screen.Zoo, "App", 5 ) And Vartype( _Screen.Zoo.App ) = "O"
				If Pemstatus( _Screen.Zoo.App, "Nombre", 5 ) And Vartype( _Screen.Zoo.App.Nombre ) = "C" And !Empty( _Screen.Zoo.App.Nombre )
					lcRetorno = _Screen.Zoo.App.Nombre
				Endif
			Endif
		Endif

		Return lcRetorno
	endfunc

enddefine

