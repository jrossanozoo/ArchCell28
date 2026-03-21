define class ServicioNotificacionEnSegundoPlano as Servicio of Servicio.prg

	#IF .f.
		Local this as ServicioNotificacionEnSegundoPlano of ServicioNotificacionEnSegundoPlano.prg
	#ENDIF

	protected oMonitorDeActividadDeAplicacion as Object
	
	oMonitorDeActividadDeAplicacion = null
	dUltimaEjecucion = { / / }
	
	#IF .f.
		local this as ServicioNotificacionEnSegundoPlano of ServicioNotificacionEnSegundoPlano.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function oMonitorDeActividadDeAplicacion_Access() as Object
		if !this.lDestroy and isnull( this.oMonitorDeActividadDeAplicacion )
			this.oMonitorDeActividadDeAplicacion = _screen.zoo.CrearObjeto( "MonitorDeActividadDeAplicacion" )
		endif
		return this.oMonitorDeActividadDeAplicacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function Iniciar() as Void
		dodefault()	
		this.ConfigurarMonitorDeActividad()	
	endfunc

	*-----------------------------------------------------------------------------------------
	function Ejecutar() as Void
		if this.oMonitorDeActividadDeAplicacion.VerificarSiElUsuarioNoEstaInteractuando()
			if ( this.fechaActualSinVerificar() )
				this.verificarCAIsVencidos()	
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function FechaActualSinVerificar() as Boolean
		return this.dUltimaEjecucion != date()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ReescribirLog( toMsgs as Object ) as void
		goservicios.errores.loguear( "CAIs próximos a vencer" )
		for each msg in toMsgs
			goservicios.errores.loguear( msg )
		endfor
		goServicios.errores.finalizarlogueo()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function NotificarCAIsVencidos(toMsgs as Object) as void
		do case
			case toMsgs.count = 1
				this.reescribirLog( toMsgs )
				goservicios.NotificacionWindowsToast.EnviarPorTipo( 9, toMsgs.item(1))
				
			case toMsgs.count > 1
				lcMsg = "Ver lista completa en ZooSession.log"
				this.reescribirLog( toMsgs )
				goservicios.NotificacionWindowsToast.EnviarPorTipo( 9, lcMsg )
		endcase
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCAIsVencidos( tcRangoDias as Number ) as Collection
		local lcAliasAnt as string, lcSql as string, loMsgs as Object, lcCursor as string,;
		lcEntidad as string, lcNombreDin as string, lcDescripcionEntidad as String, loEntidad as Object,;
		lcDescripcion as string
		
		lcSql = "SELECT detalle.CODIGO, CAST(MAX(FECHAVTO) AS date) AS ULTIMAFECHAVTO, talonario.ENTIDAD as ENTIDAD, talonario.LETRA as LETRA ";
			+ "FROM zoologic.detallecais as detalle ";
			+ "left join zoologic.numeraciones as talonario on CODIGO = TALONARIO ";
			+ "group by CODIGO, ENTIDAD, LETRA ";
			+ "having (max(FECHAVTO) - " + alltrim(transform(tcRangoDias)) + ")";
			+ " <= CAST(GETDATE() AS date) and CAST(GETDATE() AS date) <= max(FECHAVTO)"
		
		lcAliasAnt = alias()
		
		lcCursor = "c_" + sys(2015)
		goServicios.Datos.EjecutarSentencias( lcSql, "detallecais", "", lcCursor, this.DataSessionId)
		
		loMsgs = _screen.zoo.crearobjeto("ZooColeccion")
		
		select ( lcCursor )
		scan
			lcEntidad = upper( alltrim( &lcCursor..ENTIDAD ) )
			lcNombreDin = "din_entidad" + lcEntidad
			try 
				loEntidad = newobject( lcNombreDin, lcNombreDin + ".prg" )
				lcDescripcionEntidad = loEntidad.obtenerdescripcion()
			catch
				lcDescripcionEntidad = lcEntidad 
			endtry
			
			lcDescripcion = " ( " + lcDescripcionEntidad + " " + upper(alltrim(&lcCursor..LETRA)) + " ) "
			
	        lcMsg = "Talonario " + alltrim(&lcCursor..CODIGO) + lcDescripcion + "vence el " + transform(&lcCursor..ULTIMAFECHAVTO)
	    	loMsgs.add( lcMsg )
	    endscan
	    use in (lcCursor)
	    
	    if !empty(lcAliasAnt) and used(lcAliasAnt)
	    	select(lcAliasAnt)
	    endif
	    
	    return loMsgs
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarCAIsVencidos() as void
		local loMsgs as Object, lnRangoDias as Number
		
		this.dUltimaEjecucion = date()
		lnRangoDias = goservicios.parametros.nucleo.SONIDOSYNOTIFICACIONES.windows.RangoVencimientoCAIs
		
		if lnRangoDias > 0 
		    loMsgs = this.obtenerCAIsVencidos(lnRangoDias)
		    if loMsgs.count > 0
			    this.notificarCAIsVencidos(loMsgs)
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarMonitorDeActividad() as Void
		this.oMonitorDeActividadDeAplicacion.nSegundosFrecuenciaDeMonitoreo = 30
		this.BindearEvento( this.oMonitorDeActividadDeAplicacion, "EventoAplicacionInactiva", this, "Ejecutar" )
		this.oMonitorDeActividadDeAplicacion.Iniciar()
	endfunc

enddefine