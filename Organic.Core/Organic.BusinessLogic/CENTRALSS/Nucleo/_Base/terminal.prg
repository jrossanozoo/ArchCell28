define class Terminal as Servicio of Servicio.prg

	#if .f.
		local this as Terminal of Terminal.prg
	#endif
	
	protected oTerminalActiva, dFechaBlancoSql

	dFechaBlancoSql = null
	nIdSesion = 0
	nTiempoDeEsperaCerrarAplicacion = 0
	nIndiceTimerDeCierre = 0
	nIndiceTimerReportar = 0
	cTablaRegistro = "registroTerminal"
	lEnEsperaDeCierre = .f.
	lSeRegistro = .f.
	tFechaHoraConexion = null
	oTerminalActiva = null
	lForzarInicioRegistro = .f.
	
	*-----------------------------------------------------------------------------------------
	function Registrar() as Void
		local lcRutaTabla as string, lcSql as String 

		this.SetearPropiedadesIniciales()
		if !this.oTerminalActiva.lSesionIniciadaDesdeUnScriptOrganic or ( this.oTerminalActiva.lSesionIniciadaDesdeUnScriptOrganic and this.lForzarInicioRegistro )
			this.LimpiarTablaRegistroTerminal( .t. )
*			this.nIdSesion = this.ObtenerSesionDeTerminalActiva()		
*			if this.nIdSesion > 0
*				lcSql = this.ObtenerSentenciaUltimaConexion() && Te deja conectado
*				this.EjecutarSentencias( lcSql )
*			else
				lcSql = "BEGIN TRANSACTION"
				this.EjecutarSentencias( lcSql )

				lcSql = this.ObtenerSentenciaInsercionConexion() && Te deja desconectado
				this.EjecutarSentencias( lcSql )

				this.nIdSesion = this.ObtenerSesionDeTerminalActiva()

				lcSql = "COMMIT TRANSACTION"
				this.EjecutarSentencias( lcSql )

*			endif

			this.lSeRegistro = .t.
			this.Reportar() && Te conecta.
			this.InicializarTimerReportar()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Reportar() as Void
		local lcSql as string, loError as Exception

		if !this.lEnEsperaDeCierre
			this.VerificarPedidoDeCierre()
		endif

		if this.nIdSesion > 0
			try
				this.ActualizarPropiedades()
				lcSql = "update " + this.cTablaRegistro ;
					+ " set tUltRep = ctot( '" + ttoc( datetime() ) + "'), ";
					+ "ultOper = '" + alltrim( this.oTerminalActiva.cOperacion ) + "' , ";
					+ "tUltOper = ctot( '" + ttoc( this.oTerminalActiva.tFechaUltimaOperacion ) + "' ) , " ;
					+ "bdatos = '" +  alltrim( upper( this.oTerminalActiva.cSucursalActiva ) ) + "', " ;
					+ "Usuario = '" + golibrerias.EscapeCaracteresSqlServer( goServicios.Seguridad.cUsuarioLogueado ) + "', " ;
					+ "conectado = .T. " ;
					+ "where sesion = " + alltrim( str( this.nIdSesion ) )  + " and serie = '" + this.oTerminalActiva.cSerie +"'";
					+ " and USRRED = '"+ golibrerias.EscapeCaracteresSqlServer( alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() ) ) +"'" ;
					+ " and Terminal = '"+ golibrerias.EscapeCaracteresSqlServer( alltrim( goServicios.Librerias.ObtenerNombreEquipo() ) ) +"'" ;
					+ " and Conectado = .t."

				this.EjecutarSentencias( lcSql )
			catch to loError
				this.loguearerror( loError )
			endtry
			
			lcSql = "SELECT @@ROWCOUNT as cuantosUpdate"
			lcCursorCuantos = "" + sys(2015)
			this.EjecutarSentencias( lcSql, lcCursorCuantos )
			if &lcCursorCuantos..CuantosUpdate = 0
				goMensajes.Advertir( "La información de ejecución de la aplicación ha sido corrompida. Se cerrará el sistema para prevenir más errores. Intente iniciar nuevamente") 
				_screen.Zoo.app.Salir( .t. )
			endif

		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarOperacion( tcOperacion as String ) as Void
		local lcOperacion as String, lcVentanaActiva as String, lnNumeroDeVentanasCreadas as Integer
		
		if empty( tcOperacion )
			lcOperacion = alltrim( goServicios.Seguridad.cUltimaOperacion )
			if empty( lcOperacion )
				lcOperacion = "Sin actividad"
			endif
		else
			lcOperacion = tcOperacion
		endif 

		lcVentanaActiva = "No detectada"
		lnNumeroDeVentanasCreadas = _screen.FormCount
		try			
			lcVentanaActiva = _screen.ActiveForm.Caption
		catch
			if _screen.Visible
				lcVentanaActiva = _screen.Caption
			endif
		endtry		

		lcOperacion = lcOperacion + " (VA: " + alltrim( lcVentanaActiva ) + " - CV: " + transform(lnNumeroDeVentanasCreadas) + ")"
		
		this.oTerminalActiva.cOperacion = left( lcOperacion, 254 ) && 254 es por que el campo de la tabla INTERNA tiene ese largo.
		this.oTerminalActiva.tFechaUltimaOperacion = goServicios.seguridad.tFechaUltimaOperacion
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function DesRegistrar() as Void
		local lcSql as String
		this.DetenerTimerReportar()
		if this.lSeRegistro and this.nIdSesion > 0
			lcSql = "update " + this.cTablaRegistro  + " set conectado = .F. where "  + ;
				"sesion = " + transform( this.nIdSesion ) + " and serie = '" + this.oTerminalActiva.cSerie + "'"
			this.EjecutarSentencias( lcSql )
		endif
		this.lSeRegistro = .f.
		this.nIdSesion = 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DetenerTimerDeCierre() as Void
		if this.nIndiceTimerDeCierre # 0 and vartype( goTimer ) == "O" and !isnull( goTimer )
			goTimer.MatarUnTimerEspecifico( this.nIndiceTimerDeCierre )
		endif
		this.nIndiceTimerDeCierre = 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InicializarTimerDeCierre() as Void
		local lnIndiceDisponible as integer

		if this.nIndiceTimerDeCierre = 0
			lnIndiceDisponible = goTimer.CrearNuevoTimer( 60000, "goServicios.Terminal", "VerificarPedidoDeCierre" )
			this.nIndiceTimerDeCierre = lnIndiceDisponible
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Logout() as Void
		if this.lSeRegistro and this.nIdSesion > 0
			this.ActualizarOperacion( "Cerrar sesión" )
			this.EjecutarSentencias( "update " + this.cTablaRegistro + " set " + ;
				" bdatos = '', usuario = '', ULTOPER = '" + this.oTerminalActiva.cOperacion + "'" +;
				" where " + transform( this.nIdSesion ) +" = sesion and serie = '" + this.oTerminalActiva.cSerie + "'" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InicializarTimerReportar() as Void
		local lnManejadorDelTimer as integer

		if this.oTerminalActiva.lEstoyUsandoTimers
			lnManejadorDelTimer = goTimer.CrearNuevoTimer( goregistry.nucleo.MinutosRegistroTerminal, "goServicios.Terminal", "Reportar" )
			this.nIndiceTimerReportar = lnManejadorDelTimer
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarPedidoDeCierre() as Void
		local lcCursor as string, lcSql as string

		lcCursor = sys( 2015 )
		lcSql = "Select accion from " + this.cTablaRegistro + ;
			" where sesion = " + transform( this.nIdSesion ) + " and serie = '" + this.oTerminalActiva.cSerie + "'"
		
		if this.EjecutarSentencias( lcSql, lcCursor )	
			if reccount( lcCursor ) > 0
				go top in ( lcCursor )
				do case
					case upper( alltrim( &lcCursor..Accion ) ) == "FINALIZAR PROCESO"
						this.FinalizarProceso()
					case upper( alltrim( &lcCursor..Accion ) ) == "SALIDA INACTIVIDAD"
						this.FinalizarPorInactividad()
					case upper( alltrim( &lcCursor..Accion ) ) == "SOLICITAR SALIDA"
						this.SolicitarSalida()
					otherwise
						this.lEnEsperaDeCierre = .f.
				endcase
			endif

			use in select( lcCursor )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DetenerTimerReportar() as Void
		if this.nIndiceTimerReportar # 0 and vartype( goTimer ) == "O" and !isnull( goTimer )
			goTimer.MatarUnTimerEspecifico( this.nIndiceTimerReportar )
		endif
		this.nIndiceTimerReportar = 0
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ExisteFormularioEnEdicion() as Void
		local llRetorno as Boolean

		llRetorno = .f.

		for each loForm in _screen.forms
			with loForm
				if type( ".oEntidad" ) = "O" and ( .oEntidad.EsNuevo() or .oEntidad.EsEdicion() )
					llRetorno = .t.
					exit
				endif
			endwith
		endfor

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FinalizarPorInactividad() as Void
		this.lEnEsperaDeCierre = .t.
		goServicios.Mensajes.Alertar( "La aplicación se cerrará por inactividada en <N> segundos." + ;
			"Presione Aceptar para salir ahora.", 0, , , this.nTiempoDeEsperaCerrarAplicacion )
			
		this.SalirDelSistema()	
		*goServicios.Seguridad.LanzarPantalla( "Logout", .t. )                                                                                                                                                       
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FinalizarProceso() as Void
		this.lEnEsperaDeCierre = .t.
		goServicios.Mensajes.Alertar( "La aplicación se cerrará por pedido del administrador en <N> segundos." + ;
			"Presione Aceptar para salir ahora.", 0, , , this.nTiempoDeEsperaCerrarAplicacion )
			
		this.SalirDelSistema()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SolicitarSalida() as Void
		this.lEnEsperaDeCierre = .t.

		if this.ExisteFormularioEnEdicion()
			if goServicios.Mensajes.Advertir( "La aplicación se cerrará por pedido del administrador en <N> segundos." + ;
					"¿Desea posponer el cierre?", 6, , , this.nTiempoDeEsperaCerrarAplicacion ) = 2
				this.InicializarTimerDeCierre()
			else
				this.SalirDelSistema()
			endif
		else
			this.FinalizarProceso()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SalirDelSistema() as Void
		_screen.zoo.app.lSalidaDesdeRegistroTerminal = .t.
		*_screen.Zoo.app.Salir()
		SalidaDelSistema()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaUltimaConexion() as Void
		local lcSql as string, ltFechaEnBlanco as Datetime

		ltFechaEnBlanco = this.dFechaBlancoSql
		this.ActualizarOperacion( "Actualizando Terminal" )
		lcSql = "update " + this.cTablaRegistro + " set " + ;
			"terminal = '" + alltrim( goServicios.Librerias.ObtenerNombreEquipo() ) + "', " + ;
			"usrRed = '" + alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() ) + "', " + ;
			"fecha  = ctot( '" + ttoc( this.tFechaHoraConexion ) + "')," + ;
			"bdatos = '" + alltrim( upper( this.oTerminalActiva.cSucursalActiva ) ) + "', " + ;
			"tultoper = ctot( '" + ttoc( this.tFechaHoraConexion ) + "'), " + ;
			"conectado = .t., " + ;
			"usuario= '" + golibrerias.EscapeCaracteresSqlServer( upper( alltrim( goServicios.Seguridad.cUsuarioLogueado ) ) ) + "', " + ;
			"accion= ''," + ;
			"version= '" + this.oTerminalActiva.cVersion + "', " + ;
			"tUltRep = ctot( '" + ttoc( &ltFechaEnBlanco ) + "'), " + ;
			"ULTOPER = '" + this.oTerminalActiva.cOperacion + "', " + ;
			"serie = '" + this.oTerminalActiva.cSerie + "' " +;
			"where sesion = " + alltrim( str( this.nIdSesion ) ) + " and serie = '" + this.oTerminalActiva.cSerie + "'"

		return lcSql
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaInsercionConexion() as Void
		local lcSql as string, ltFechaEnBlanco as Datetime, lcUsuarioSO as String, lcNombrePC as String

		ltFechaEnBlanco = this.dFechaBlancoSql
		this.ActualizarOperacion( "Registrando Terminal" )
		
		lcUsuarioSO = alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() )
		lcNombrePC = alltrim( goServicios.Librerias.ObtenerNombreEquipo() )
		
		lcUsuarioSO = goServicios.Librerias.EscapeCaracteresSqlServer( lcUsuarioSO )
		lcNombrePC = goServicios.Librerias.EscapeCaracteresSqlServer( lcNombrePC )

		lcSql = "insert into " + this.cTablaRegistro + " (terminal, usrRed, fecha, bdatos, " + ;
			"tUltOper, Conectado, Usuario, Version, serie, tUltRep, ULTOPER ) " +  ;
			" values ( " ;
			+ "'" + lcNombrePC + "', " ;
			+ "'" + lcUsuarioSO + "', " ;
			+ "ctot( '" + ttoc( this.tFechaHoraConexion ) + "'), " ;
			+ "'" + alltrim( upper( this.oTerminalActiva.cSucursalActiva ) ) + "', " ;
			+ "ctot( '" + ttoc( this.tFechaHoraConexion ) + "'), " ;
			+ ".T., " ;
			+ "'" + golibrerias.EscapeCaracteresSqlServer( upper( alltrim( goServicios.Seguridad.cUsuarioLogueado ) ) ) + "', " ;
			+ "'" + this.oTerminalActiva.cVersion + "', " ;
			+ "'" + this.oTerminalActiva.cSerie + "', " ;
			+ "ctot( '" + ttoc( &ltFechaEnBlanco ) + "'), " ;
			+ "'" + this.oTerminalActiva.cOperacion + "' )"
		return lcSql
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSesionDeTerminalActiva() as integer
		local lcCursor as string, lcSql as string, lnRetorno as integer, lni as integer

		lnRetorno = 0
		lcCursor = sys( 2015 )

		lcSql = "SELECT @@IDENTITY as sesion"

		if this.EjecutarSentencias( lcSql, lcCursor )
			if reccount( lcCursor ) > 0
				lnRetorno = &lcCursor..sesion
			endif
			use in select( lcCursor )
		endif
		
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearPropiedadesIniciales() as Void
		this.lSeRegistro = .f.
		this.oTerminalActiva = this.CrearItemRegistroTerminalActiva()
		this.dFechaBlancoSql = alltrim( goRegistry.Nucleo.FechaEnBlancoParaSqlServer )
		this.tFechaHoraConexion = datetime()
		this.nTiempoDeEsperaCerrarAplicacion = goRegistry.Nucleo.TiempoDeEsperaParaCerrarAplicacion
		goServicios.Seguridad.tFechaUltimaOperacion = this.tFechaHoraConexion
		this.ActualizarOperacion( "Registando Terminal" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarPropiedades() as Void
		this.oTerminalActiva.cSucursalActiva = _screen.zoo.app.cSucursalActiva
		this.oTerminalActiva.cSerie = _screen.zoo.app.cSerie
		this.oTerminalActiva.lEstoyUsandoTimers = _screen.zoo.app.lEstoyUsandoTimers
		this.ActualizarOperacion()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CrearItemRegistroTerminalActiva() as ItemTerminal of terminal.prg
		local loItemTerminal as ItemTerminal of terminal.prg
		
		loItemTerminal = newobject( "ItemTerminal", "terminal.prg" )
		loItemTerminal.cSerie = _Screen.zoo.app.cSerie
		loItemTerminal.cSucursalActiva = _Screen.zoo.app.cSucursalActiva
		loItemTerminal.cVersion = _Screen.zoo.app.ObtenerVersion()
		loItemTerminal.cRutaTablasOrganizacion = addbs( _Screen.zoo.app.cRutaTablasOrganizacion )
		loItemTerminal.lEstoyUsandoTimers = _Screen.zoo.app.lEstoyUsandoTimers
		loItemTerminal.lSesionIniciadaDesdeUnScriptOrganic = goServicios.Ejecucion.TieneScriptCargado()
		return loItemTerminal
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function EjecutarSentencias( tcSentencia as String, tcCursor as String ) as Boolean
		local llRetorno as Boolean, loError as Exception

		llRetorno = .f.
		try
			if vartype( goDatos ) == "O" and !isnull( goDatos )
				if empty( tcCursor )
					goDatos.EjecutarSentencias( tcSentencia, this.cTablaRegistro, this.oTerminalActiva.cRutaTablasOrganizacion )
				else
					goDatos.EjecutarSentencias( tcSentencia, this.cTablaRegistro, this.oTerminalActiva.cRutaTablasOrganizacion, tcCursor , this.datasessionid )
				endif

				llRetorno = .t.
			endif
		catch to loError
			this.LoguearError( loError )
		endtry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LoguearError( toError as Exception ) as Void
		local loEx as zooexception OF zooexception.prg
		try
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( toError )
			Endwith		
		catch
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarTablaRegistroTerminal( tlSellamaDesdeElRegistrar as Boolean ) as Void
		local lcFiltro as String 
		lcFiltro = ""
		if tlSellamaDesdeElRegistrar
			lcFiltro = " and serie = '" + this.oTerminalActiva.cSerie + "'"
		endif
		this.EjecutarSentencias( "update " + this.cTablaRegistro + " set conectado = .F. where tultrep <= DATE()-1 " + lcFiltro )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function Detener() as Void
		this.DetenerTimerReportar()
		this.DetenerTimerDeCierre()
		dodefault()
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerOtraTerminalConSerie( tcSerie as String ) as Void
		local loItemTerminal as Object, lcCursor as String, lcNombrePC as String, lcUsuarioSO as String, lcTablaRegistro as String

		loColItemTerminal = _screen.zoo.crearobjeto( "ZooColeccion" )
		loItemTerminal = newobject( "ItemTerminal", "terminal.prg" )

		lcCursor = sys( 2015 )
		lcNombrePC = alltrim( goServicios.Librerias.ObtenerNombreEquipo() )
		lcUsuarioSO = alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() )
		lcTablaRegistro = this.cTablaRegistro 

		text to lcSql noshow textmerge
Select
Terminal,
UsrRed,
Serie,
Conectado,
tUltRep
from <<lcTablaRegistro>>
where Conectado = 1 
AND Serie = '<<tcSerie>>' 
AND terminal = '<<lcNombrePC>>' 
AND UsrRed != '<<lcUsuarioSO>>'
AND tUltRep > DATEADD( minute, -30, GETDATE() )
	  	endtext

		goDatos.EjecutarSentencias( lcSql, this.cTablaRegistro, "", lcCursor , this.datasessionid )
	
		select (lcCursor)
		scan
			loItemTerminal.cSerie = rtrim( &lcCursor..Serie )
			loItemTerminal.cUsuario = rtrim( &lcCursor..UsrRed )
			loItemTerminal.cMaquina = rtrim( &lcCursor..terminal )
			loItemTerminal.tFechaUltimoReporte = &lcCursor..tUltRep 
			loColItemTerminal.Agregar( loItemTerminal )
		endscan

		return loColItemTerminal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesconectarOtrasTerminalesPorInactividad( tcSerie as String ) as Void
		local lcCursor as String, lcNombrePC as String, lcUsuarioSO as String, lcTablaRegistro as String

		lcTablaRegistro = this.cTablaRegistro 
		lcNombrePC = alltrim( goServicios.Librerias.ObtenerNombreEquipo() )
		lcUsuarioSO = alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() )

		text to lcSql noshow textmerge
update <<lcTablaRegistro>>
set accion = 'SALIDA INACTIVIDAD'
where Conectado = 1 
AND Serie = '<<tcSerie>>' 
AND terminal = '<<lcNombrePC>>' 
AND UsrRed != '<<lcUsuarioSO>>'
	  	endtext

		goDatos.EjecutarSentencias( lcSql, this.cTablaRegistro, "", "" , this.datasessionid )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Esto es necesario cuando hay cambio de serie durante la ejecucion (registro, o sea)
	* Al ser el serie parte de la clave del registro, al cambiar no encuentra los datos
	* antiguos e interpreta que la informacion esta corrupta
	function ReasignarSerieEnSesion() as Void
		local lcTablaRegistro as String
		lcTablaRegistro = this.cTablaRegistro 
	
		lcSql = "update " + lcTablaRegistro + " set Serie= '" + _screen.zoo.app.cSerie + "' where sesion = " + trans( this.nIdSesion )

		goDatos.EjecutarSentencias( lcSql, this.cTablaRegistro, "", "" , this.datasessionid )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SolicitarSalidaTodasLasTerminales() as Void
		local lcTablaRegistro as String

		lcTablaRegistro = this.cTablaRegistro 
		lcSql = "update " + lcTablaRegistro + " set Accion= 'SOLICITAR SALIDA'"

		goDatos.EjecutarSentencias( lcSql, this.cTablaRegistro, "", "" , this.datasessionid )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SolicitarSalidaTerminal( tcTerminal as String ) as Void
		local lcTablaRegistro as String

		lcTablaRegistro = this.cTablaRegistro 
		lcSql = "update " + lcTablaRegistro + " set Accion= 'SOLICITAR SALIDA' WHERE terminal = '" + rtrim( tcTerminal ) + "'"

		goDatos.EjecutarSentencias( lcSql, this.cTablaRegistro, "", "" , this.datasessionid )
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemTerminal as Custom
	cSerie = ""
	cSucursalActiva = ""
	cVersion = ""
	cRutaTablasOrganizacion = ""
	lEstoyUsandoTimers = .f.
	lSesionIniciadaDesdeUnScriptOrganic = .f.
	tFechaUltimaOperacion = { / / }
	tFechaUltimoReporte = { / / }
	cOperacion = ""
	cUsuario = ""
	cMaquina = ""
enddefine
