Define Class ztestWindowsToastNotification as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestWindowsToastNotification of ztestWindowsToastNotification.prg
	#ENDIF
	
	oWTN = null
	
	*---------------------------------
	Function Setup
		this.oWTN = _screen.zoo.crearobjeto("WindowsToastNotificationFake", "ztestWindowsToastNotification.prg" )
	EndFunc
	
	*---------------------------------
	Function TearDown
		this.oWTN = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestU_EnviarPorTipoParametrosDefault() as Void

		*Titulo tipo 1
		this.oWTN.cRespuesta = ""		
		this.oWTN.EnviarPorTipo(1,"Mensaje")
		this.assertequals( "El título para el tipo '1' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Falló el envío de e-mail;Mensaje" )
		
		*Titulo tipo 2
		this.oWTN.cRespuesta = ""
		this.oWTN.EnviarPorTipo(2,"Mensaje")
		this.assertequals( "El título para el tipo '2' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Falló la recepción de transferencia;Mensaje" )

		*Titulo tipo 3
		this.oWTN.cRespuesta = ""
		this.oWTN.EnviarPorTipo(3,"Mensaje")
		this.assertequals( "El título para el tipo '3' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Falló la obtención de CAE;Mensaje" )
	
		*Titulo tipo 4
		this.oWTN.cRespuesta = ""
		this.oWTN.EnviarPorTipo(4,"Mensaje")
		this.assertequals( "El título para el tipo '4' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Falló la comunicación con Mercado Libre;Mensaje" )
		
		*Titulo tipo 5  por Default = desactivado
		this.oWTN.cRespuesta = ""
		this.oWTN.EnviarPorTipo(5,"Mensaje")
		this.assertequals( "El título para el tipo '5' o el mensaje es incorrecto - desactivado", this.oWTN.cRespuesta, "" )
		
		*Titulo tipo 5  activado
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros4()
		this.oWTN.EnviarPorTipo(5,"Mensaje")
		this.assertequals( "El título para el tipo '5' o el mensaje es incorrecto - activado", this.oWTN.cRespuesta, "Paquete de precios de artículos procesado;Mensaje" )
		this.oWTN.ActualizarParametros()

		*Titulo tipo otherwise
		this.oWTN.cRespuesta = ""
		this.oWTN.EnviarPorTipo(6,"Mensaje")
		this.assertequals( "El título para el tipo '6' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Falló el envio de transferencia;Mensaje" )
		
		*Titulo tipo otherwise
		this.oWTN.cRespuesta = ""
		this.oWTN.EnviarPorTipo(7,"Mensaje")
		this.assertequals( "El título para el tipo 'otherwise' o el mensaje es incorrecto", this.oWTN.cRespuesta, "" )
		this.asserttrue( "No debe poder enviar la notificación", !this.oWTN.lPuedeEnviar )

		*Titulo tipo 10 - desactivado
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros3()
		this.oWTN.EnviarPorTipo(10,"Mensaje")
		this.assertequals( "El título para el tipo '9' o el mensaje es incorrecto", this.oWTN.cRespuesta, "" )
	
		*Titulo tipo 10 - activado
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros4()
		this.oWTN.EnviarPorTipo(10,"Mensaje")
		this.assertequals( "El título para el tipo '9' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Error en el informe de venta a Las Piedras Shopping;Mensaje" )
		
		*Titulo tipo 11
		this.oWTN.cRespuesta = ""		
		this.oWTN.EnviarPorTipo(11,"Mensaje")
		this.assertequals( "El título para el tipo '11' o el mensaje es incorrecto", this.oWTN.cRespuesta, "Falló la autenticación de e-mail;Mensaje" )
	
		*Sin IDAgrupador debe loguear
		this.oWTN.cRespuesta = ""
		this.oWTN.CambiarIdAgrupador("")
		this.oWTN.EnviarPorTipo(1,"Mensaje")
		this.assertequals( "No está logueando si el IdAgrupador esta vacío", this.oWTN.cRespuesta, "Paso por Log" )
			
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	function ztestU_EnviarPorTipoNotificacionesDesactivadas() as Void
		
		*Mesajes desactivados
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros2()
		this.oWTN.EnviarPorTipo(1,"Mensaje")
		this.assertequals( "Notificaciones desactivadas, no debe enviar la notificación", this.oWTN.cRespuesta, "" )
		
		*Mensajes para NotificarFalloDeEmail desactivados
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros3()
		this.oWTN.EnviarPorTipo(1,"Mensaje")
		this.assertequals( "Notificaciones para error Email desactivadas, no debe enviar la notificación", this.oWTN.cRespuesta, "" )
		
		*Mensajes para NotificarFalloRecepcionTrnas desactivados
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros3()
		this.oWTN.EnviarPorTipo(2,"Mensaje")
		this.assertequals( "Notificaciones para error en recepción de transferencias desactivadas, no debe enviar la notificación", this.oWTN.cRespuesta, "" )	
		
		*Mensajes para NotificarFalloAlObtenerCAE desactivados
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros3()
		this.oWTN.EnviarPorTipo(3,"Mensaje")
		this.assertequals( "Notificaciones para error en obtención de CAE desactivadas, no debe enviar la notificación", this.oWTN.cRespuesta, "" )	

		*Mensajes para NotificarFalloAlObtenerCAE desactivados
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros3()
		this.oWTN.EnviarPorTipo(4,"Mensaje")
		this.assertequals( "Notificaciones para error en Comunicación Mercado Libre, no debe enviar la notificación", this.oWTN.cRespuesta, "" )	
		
		*Mensajes para NotificarRecepcionPaquetesConPrecios desactivados
		this.oWTN.cRespuesta = ""
		this.oWTN.ActualizarParametros3()
		this.oWTN.EnviarPorTipo(5,"Mensaje")
		this.assertequals( "Notificaciones para Notificar Recepcion Paquetes Con Precios , no debe enviar la notificación", this.oWTN.cRespuesta, "" )	
	endfunc
	
enddefine

	*******************************************************************************************
	*******************************************************************************************	
	
define class WindowsToastNotificationFake as WindowsToastNotification  of WindowsToastNotification.prg

	cRespuesta = ""
	*-----------------------------------------------------------------------------------------
	function init() as Void
		this.cIdAgrupador = "Agrupador"
		this.cPathIcono = "Ruta"
		this.ActualizarParametros()
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ActualizarParametros() as Void
		this.lNotificacionesActivas = .t.
		this.lOcultarBanner = .f.
		this.cTiempoBanner = "short"
		this.lNotificarFalloDeEmail = .t.
		this.lNotificarFalloRecepcionTrans = .t.
		this.lNotificarFalloAlObtenerCAE = .t.
		this.lNotificarFalloComunicacionML = .t.
		this.lNotificarRecepcionPaquetesConPrecios = .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParametros2() as Void
		this.lNotificacionesActivas = .f.
		this.lOcultarBanner = .f.
		this.cTiempoBanner = "short"
		this.lNotificarFalloDeEmail = .t.
		this.lNotificarFalloRecepcionTrans = .t.
		this.lNotificarFalloAlObtenerCAE = .t.
		this.lNotificarFalloComunicacionML = .t.
		this.lNotificarRecepcionPaquetesConPrecios = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParametros3() as Void
		this.lNotificacionesActivas = .T.
		this.lOcultarBanner = .f.
		this.cTiempoBanner = "short"
		this.lNotificarFalloDeEmail = .F.
		this.lNotificarFalloRecepcionTrans = .F.
		this.lNotificarFalloAlObtenerCAE = .F.
		this.lNotificarFalloComunicacionML = .F.
		this.lNotificarRecepcionPaquetesConPrecios = .f.
		this.lNotificarErrorEnInformedeVentaLPS = .f.
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParametros4() as Void
		this.lNotificacionesActivas = .t.
		this.lOcultarBanner = .f.
		this.cTiempoBanner = "short"
		this.lNotificarFalloDeEmail = .t.
		this.lNotificarFalloRecepcionTrans = .t.
		this.lNotificarFalloAlObtenerCAE = .t.
		this.lNotificarFalloComunicacionML = .t.
		this.lNotificarRecepcionPaquetesConPrecios = .t.
		this.lNotificarErrorEnInformedeVentaLPS = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CambiarIdAgrupador( tcString as String) as Void
		this.cIdAgrupador = tcString
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EnviarNotificacionObjetoNet( tcIdAgrupador, tcTitulo, tcMensaje, tcPathIcono, tlOcultarBanner, tcTiempoBanner, tcRutaLog  ) as VOID				
		this.cRespuesta = tcTitulo + ";" + tcMensaje
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function GrabarErrorEnLog( tcMensajeLogueo, toError ) as Void
		this.cRespuesta = "Paso por Log"
	endfunc

enddefine
