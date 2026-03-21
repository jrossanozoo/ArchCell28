define class KontrolerOrdenDeProduccion as din_KontrolerOrdenDeProduccion of din_KontrolerOrdenDeProduccion.prg

	#if .f.
		local this as KontrolerOrdenDeProduccion of KontrolerOrdenDeProduccion.prg
	#endif

	#define OKORCANCEL 1
	#define YESORNO 4
	#define FIRSTBUTTON 0
	#define SECONDBUTTON 256
	#define SELECTBUTTONOK 1
	#define SELECTBUTTONCANCEL 2
	#define SELECTBUTTONYES 6
	#define SELECTBUTTONNO 7

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		local loControl1 as Object, loControl2 as Object, loEtiqueta1 as Object, loEtiqueta2 as Object
		dodefault()
		This.BindearEvento( This.oEntidad, "EventoRefrescarGrilla" , This, "RefrescarGrilla" )
		This.BindearEvento( This.oEntidad, "EventoConfirmarCambio" , This, "ConfirmarCambio" )
		This.BindearEvento( This.oEntidad, "eventoEnviarMensajeSinEspera" , This, "EnviarMensajeSinEspera" )

*!*			loEtiqueta1 = this.ObtenerControl('BLANCO1_ORDENDEPRODUCCIONBLANCO1')
*!*			loEtiqueta2 = this.ObtenerControl('BLANCO2_ORDENDEPRODUCCIONBLANCO2')
*!*			loEtiqueta1.Visible = .f.
*!*			loEtiqueta2.Visible = .f.
*!*			loControl1 = this.ObtenerControl('Blanco1')
*!*			loControl2 = this.ObtenerControl('Blanco2')
*!*			loControl1.Visible = .f.
*!*			loControl2.Visible = .f.

	endfunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarGrilla( tcDetalle as String ) as Void
		local loZooGrilla as Object
		if This.Existecontrol( tcDetalle )
			loZooGrilla = This.ObtenerControl( tcDetalle )
			loZooGrilla.RefrescarGrilla()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConfirmarCambio( tcMensajeDeConfirmacion as String, tcTitulo as String ) as Void
		if goServicios.Mensajes.Preguntar( tcMensajeDeConfirmacion, YESORNO, FIRSTBUTTON, tcTitulo ) != SELECTBUTTONYES
			goServicios.Errores.LevantarExcepcion( "Proceso cancelado por el usuario." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarMensajeSinEspera( tcMensaje as String) as Void
		if empty(tcMensaje)
			goMensajes.EnviarSinEsperaProcesando()
		else
			goMensajes.EnviarSinEsperaProcesando( tcMensaje )
		endif
	endfunc 

enddefine
