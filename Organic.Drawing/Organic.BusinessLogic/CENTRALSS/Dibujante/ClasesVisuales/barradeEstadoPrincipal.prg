define class BarraDeEstadoPrincipal as BarraDeEstadoBase of BarraDeEstadoBase.prg

	#if .f.
		local this as BarraDeEstadoPrincipal of BarraDeEstadoPrincipal.prg
	#endif

	height = 22
	
	*-----------------------------------------------------------------------------------------
	Function Setear()
		if !this.lGruposYaGenerados
			this.GenerarGrupos()
		endif

		this.SetearGrupos()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearGrupos() as void
		local lnPanel as Integer, lcReplica as String, lcReplicaAbreviada as String, loMotorDB as Object

		loMotorDB = _screen.zoo.CrearObjeto( "BarraDeEstadoMotorDB", "BarraDeEstadoMotorDB.prg" )
		
		lnPanel = 1
		lcReplica = ""
		lcReplicaAbreviada = ""
		if _Screen.zoo.App.ObtenerValorReplicaBD()
			lcReplica = " <Réplica>"
			lcReplicaAbreviada = " <R>"
		Endif	
		This.SetearPanel( "Base de datos: " + _Screen.zoo.App.csucursalactiva + lcReplicaAbreviada, lnPanel )
		this.SetearTooltip( _Screen.zoo.App.csucursalactiva + lcReplica, lnPanel )

		*Motor de BD
		lnPanel = lnPanel + 1
		This.SetearPanel( "Instancia: " + loMotorDB.ObtenerMotorDB(), lnPanel )
		this.SetearTooltip( loMotorDB.ObtenerMotorDB(), lnPanel)

		lnPanel = lnPanel + 1
		This.SetearPanel( "Usuario: " + goServicios.Seguridad.cUsuarioLogueado, lnPanel )
		this.SetearTooltip( goServicios.Seguridad.cUsuarioLogueado, lnPanel )

		lnPanel = lnPanel + 1
		**Este metodo tambien se llama desde zooFormPrincipal
		this.SetearEstadoDelSistema( goServicios.Seguridad.ObtenerEstadoDeSeguridad(), lnPanel, lnPanel + 1 ) && En panel 4 y 5		

		lnPanel = lnPanel + 2		
		this.SetearSemaforo( _screen.zoo.app.lSemaforo, lnPanel )
		this.SetearTooltip( "", lnPanel )		

		lnPanel = lnPanel + 1		
		This.SetearPanel( "Serie: " + alltrim(_screen.zoo.app.cSerie), lnPanel )
		this.SetearTooltip( alltrim(_screen.zoo.app.cSerie), lnPanel )		

		lnPanel = lnPanel + 1
		this.SetearPanel( "Versión: " + _screen.zoo.app.ObtenerVersion(), lnPanel )
		this.SetearTooltip( "Versión: " + _screen.zoo.app.ObtenerVersion(), lnPanel )
	Endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarGrupos() as Void

		This.AddPanel( "", 168, .F., 0, "Nombre de la base de datos" )	&& cuarto parametro = 2 es alieneado centrado
		This.AddPanel( "", 10, .T., 0, "Instancia" )
		This.AddPanel( "", 318, .F., 0, "Usuario logueado" )
		This.AddPanel( "", 20, .F., 2, "Estado de seguridad" )
		this.AddPanel( "", 20, .F., 2, "Modo de uso" )		
		this.AddPanel( "", 20, .F., 2, "Alarma de pocas entradas" )
		this.AddPanel( "", 80, .F., 0, "Número de serie" )
		this.AddPanel( "", 150, .F., 0, "Datos de compilación" )	
				
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearSemaforo(tcEstado as Boolean, tnPanel as Integer ) as Void
		if tcEstado = .t. && Activado
			this.panels(tnPanel).icon = "semaforo2.png"
			This.RenderPanels() 
			this.SetearToolTip("ALERTA de pocas entradas",tnPanel)
		else
			this.Panels(tnPanel).Icon = ""
			this.RenderPanels()
			this.SetearToolTip("",tnPanel)
		endif 
	endfunc 

enddefine
