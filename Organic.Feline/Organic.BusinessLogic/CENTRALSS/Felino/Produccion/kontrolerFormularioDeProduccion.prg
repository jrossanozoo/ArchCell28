define class kontrolerFormularioDeProduccion as KontrolerConDetalle of KontrolerConDetalle.prg

	#If .F.
		Local This As kontrolerFormularioDeProduccion As kontrolerFormularioDeProduccion.prg
	#Endif

	cProcesoActivo = ""
	cBackColor = null
	cForeColor = null
	cDisabledBackColor = null
	cDisabledForeColor = null
	nFilaActiva = 0

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.EnlazarControlesDeGrilla()
		This.BindearEvento( This.oEntidad, "eventoEnviarMensajeSinEspera" , This, "EnviarMensajeSinEspera" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function HabilitarFilaEnGrillaSegunProceso( toControlDetalle as Object, tcProceso as String ) As Void
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EnlazarControlesDeGrilla() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FocoEnGrilla( tnItem as Integer) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BindearFiltroBusquedaColorEnCurva( toObjetoBusqueda as Object ) as Void
		This.BindearEvento( toObjetoBusqueda, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorColorEnCurva" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BindearFiltroBusquedaTalleEnCurva( toObjetoBusqueda as Object ) as Void
		This.BindearEvento( toObjetoBusqueda, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorTalleEnCurva" )
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

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemGrilla as Custom

	NroFila = 0
	Detalle = ''

	*-----------------------------------------------------------------------------------------
	function GotFocus() as Void
		this.SetearFilaEnProcesos( this.NroFila  )
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearFilaEnProcesos( tnFila as Integer) as Void
	endfunc 

enddefine

