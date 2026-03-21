**********************************************************************
Define Class ztestServicioNotificacionEnSegundoPlano as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestServicioNotificacionEnSegundoPlano of ztestServicioNotificacionEnSegundoPlano.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		
	EndFunc
	
	*---------------------------------
	Function TearDown
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestFechaActualSinVerificar
		local loServicio as Object, llResultado1 as Boolean, llResultado2 as Boolean, llResultado as Boolean
		
		loServicio = newobject( "ServicioNotificacionEnSegundoPlano", "ServicioNotificacionEnSegundoPlano.prg" )
		
		this.asserttrue( "El servicio no devolvio el valor esperado (1)", loServicio.fechaActualSinVerificar() )
		
		loServicio.dUltimaEjecucion = date()
		llResultado1 = !loServicio.fechaActualSinVerificar()
		
		loServicio.dUltimaEjecucion = date()
		llResultado2 = !loServicio.fechaActualSinVerificar()
		
		llResultado = llResultado1 or llResultado2
		
		this.asserttrue( "El servicio no devolvio el valor esperado (2)", llResultado )
		
		loServicio.dUltimaEjecucion = date() - 1
		this.asserttrue( "El servicio no devolvio el valor esperado (3)", loServicio.fechaActualSinVerificar() )
		
		loServicio = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestNotificarCAIsVencidos
		local loServicio as Object, lcMsg as string
		
		private goServicios
		goServicios = createobject( "Custom" )
		goServicios.addProperty("NotificacionWindowsToast")
		goServicios.NotificacionWindowsToast = createobject( "NotificacionWindowsToast_FAKE" )
		
		loServicio = createobject( "ServicioNotificacionEnSegundoPlano_fake" )
		
		lcMsg = "Mensaje"
		
		loMsgs = _screen.zoo.crearObjeto( "ZooColeccion" )
		loMsgs.add( lcMsg )
	
		loServicio.notificarCAIsVencidos( loMsgs )
		this.assertequals("El mensaje del logueo no es el esperado (1)", lcMsg, goServicios.NotificacionWindowsToast.cMensajegGo )
		
		loMsgs.add(lcMsg)
		loServicio.notificarCAIsVencidos(loMsgs)
		this.assertequals("El mensaje del logueo no es el esperado (2)", "Ver lista completa en ZooSession.log", goServicios.NotificacionWindowsToast.cMensajegGo )
		
		loServicio = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerCAIsVencidos
		local loMsgs as Collection
		
		lcInsert1 = "insert into numeraciones ( TALONARIO, LETRA, ENTIDAD) values ( '1A1133', 'A', 'ALEMANIA' )"
		lcDelete1 = "delete from numeraciones where talonario = '1A1133'"
		goServicios.Datos.EjecutarSentencias( lcDelete1, "numeraciones" )
		goServicios.Datos.EjecutarSentencias( lcInsert1, "numeraciones" )
		
		lcInsert2 = "insert into numeraciones ( TALONARIO, LETRA, ENTIDAD) values ( '1A1134', 'A', 'BOLIVIA' )"
		lcDelete2 = "delete from numeraciones where talonario = '1A1134'"
		goServicios.Datos.EjecutarSentencias( lcDelete2, "numeraciones" )
		goServicios.Datos.EjecutarSentencias( lcInsert2, "numeraciones" )
		
		
		lcInsert3 = "insert into detallecais ( CODIGO, FECHAVTO, NROITEM ) values ( '1A1133', CAST(GETDATE() as date), 1 )"
		lcDelete3 = "delete from detallecais  where codigo = '1A1133'"
		goServicios.Datos.EjecutarSentencias( lcDelete3, "detallecais" )
		goServicios.Datos.EjecutarSentencias( lcInsert3, "detallecais" )
		
		lcInsert4 = "insert into detallecais ( CODIGO, FECHAVTO, NROITEM ) values ( '1A1134', CAST(GETDATE() + 20 as date), 1 )"
		lcDelete4 = "delete from detallecais  where codigo = '1A1134'"
		goServicios.Datos.EjecutarSentencias( lcDelete4, "detallecais" )
		goServicios.Datos.EjecutarSentencias( lcInsert4, "detallecais" )
		
		
		loServicio = newobject( "ServicioNotificacionEnSegundoPlano", "ServicioNotificacionEnSegundoPlano.prg" )
		
		loMsgs = loServicio.ObtenerCAIsVencidos(10)
		
		this.assertequals("La coleccion debe tener un elemento", 1, loMsgs.Count)
		this.asserttrue("La descripcion no es la esperada", "Talonario 1A1133 ( Alemania A )" $ loMsgs.item(1))
		
		
		goServicios.Datos.EjecutarSentencias( lcDelete1, "numeraciones" )
		goServicios.Datos.EjecutarSentencias( lcDelete2, "numeraciones" )
		goServicios.Datos.EjecutarSentencias( lcDelete3, "detallecais" )
		goServicios.Datos.EjecutarSentencias( lcDelete4, "detallecais" )
		
	endfunc
enddefine

*-----------------------------------------------------------------------------------------

define class ServicioNotificacionEnSegundoPlano_fake as ServicioNotificacionEnSegundoPlano of ServicioNotificacionEnSegundoPlano.prg

	*-----------------------------------------------------------------------------------------
	function reescribirLog(toparam as Object ) as Void
	endfunc 
enddefine


define class NotificacionWindowsToast_fake as custom
	
	cMensajegGo = ""
	************************************************
	function EnviarPorTipo( tnParam1 as numeric, tcParam2 as string)
		this.cMensajegGo = tcParam2
	endfunc
	
	function ActualizarParametros() as Void
		
	endfunc
enddefine

