define class PedirClave as zooSession of zoosession.prg

	#if .f.
		local this as PedirClave of PedirClave.prg
	#endif

	cClaveIngresada = ""
	cIdUsuario 		= ""
	lScreenVisible = .F.
&& A Esta Altura no me interesa si hay usuarios conectados o el tipo de la operacion
	*-----------------------------------------------------------------------------------------
	function PedirClave( ) as String
		local loformClave As Object, lnIntentos As Integer, lnInd as Integer, loUsuarioyClave as Object, lcUsuario as String,;
				llRetorno as Boolean, loServicioPantalla as Object
		lnIntentos = goRegistry.Nucleo.Seguridad.NumeroDeIntentosDeLogueo
		lcUsuario = ""
		with This	
			loServicioPantalla = _screen.zoo.CrearObjeto( "ServicioPantalla" )			
			for lnInd = 1 to lnIntentos
			
				llRetorno = .t.
				loServicioPantalla.DeshabilitarFormularioActivo()
				try
					This.lScreenVisible = _screen.Visible
					if goServicios.Librerias.HayFormularioPrincipal()
					else
						_screen.Visible = .T.
					Endif	
					if GoParametros.Dibujante.Estilo = 1
						loUsuarioyClave = goServicios.Formularios.MostrarScx( "frmUsuarioYClaveLince",.t., lcUsuario )
					else		
						loUsuarioyClave = goServicios.Formularios.MostrarScx( "frmUsuarioYClaveWindows",.t., lcUsuario )
					endif	
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					_screen.Visible = This.lScreenVisible
				EndTry	
				loServicioPantalla.HabilitarFormularioActivo()
				if This.Cancelo()
					lnInd = lnIntentos
					.cIdUsuario = "CANCEL"
				else
					if goServicios.Seguridad.ValidarUsuarioYClave( loUsuarioYClave.Usuario, loUsuarioYClave.Clave , .t.)
						if .ExpiroLaClave()
							llRetorno = .f.
							This.AgregarInformacion( "La clave ingresada ha expirado." )
							lcUsuario = loUsuarioYClave.Usuario
						else
							lnInd = lnIntentos
							.cIdUsuario = goServicios.Seguridad.cIdUsuarioValidado
						EndIf					
					else
						This.CargarInformacion( goServicios.Seguridad.ObtenerInformacion() )
						llRetorno = .f.
					endif 
					
					if llRetorno
					else
						goServicios.Seguridad.cIdUsuarioValidado = ""
						goServicios.mensajes.enviar( This.ObtenerInformacion(), 0, 2, , "Información del Sistema" )
					endif
				endif
			EndFor
			loServicioPantalla.Release()
			return .cIdUsuario
			
		EndWith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExpiroLaClave() as Boolean 
		This.cClaveIngresada	= ""
		This.cIdUsuario			= ""
		return .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Cancelo() as Boolean
		return lastkey() = 27
	endfunc 

enddefine
