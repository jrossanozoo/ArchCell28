Define Class timerBase As zooClaseBase of zooClaseBase.prg

	#IF .f.
		Local this as timerBase of timerBase.prg
	#ENDIF
	
	oGrupoDeTimersCreados = null
	nHandelerTimer1Seg = 0	
	cEstadoDeLosTimers = ""
	nCantidadDeTimers  = 0
	cClasePublica = "goTimer"
	lLaLibreriaYaFueDeclarada = .f.
	nUltimoManejadorExterno = 0
	cRutaDeFll = ""
	
	*-----------------------------------------------------------------------------------------
	function init
		local lcRutaFllEnExe as String
		dodefault()
		this.oGrupoDeTimersCreados = newobject( "zoocoleccion", "zoocoleccion.prg" )
		lcRutaFllEnExe =  addbs( _screen.zoo.crutainicial ) + "cpptimer.fll"
		if file(lcRutaFllEnExe) 
			this.cRutaDeFll = lcRutaFllEnExe
		else
			this.cRutaDeFll = "cpptimer.fll"
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InicializarTimers() as Void
		if _screen.Zoo.app.lEstoyUsandoTimers
			this.CrearTimerCada1Segundo() &&Inicializa el timer base de la aplicacion Organic.
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function CrearTimerCada1Segundo() as Integer
		local lcClase as String

		this.nHandelerTimer1Seg = this.CrearNuevoTimer( 1000, this.cClasePublica, "Evento1Sec" )
		
		return this.nHandelerTimer1Seg
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function SacarParentesisSiEstanAlFinal( tcMetodoEventoAEjecutar as String ) as String
		local lcResultado as String
			lcResultado = strtran( tcMetodoEventoAEjecutar, "(", "" )
			lcResultado = strtran( lcResultado, ")", "" )
			lcResultado = alltrim( lcResultado )
		return lcResultado 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearNuevoTimer( tnMilisegundos As Integer, tcObjetoPublico As String, tcMetodoEventoAEjecutar As String, tcParametroParaElMetodo as String ) As Integer
		local lnManejadorInterno as Integer, lcMetodoEvento as String, lcMetodoEventoDeConsulta  as String
		
		if vartype( tcParametroParaElMetodo ) # "C"
			tcParametroParaElMetodo = ""
		endif

		lnManejadorInterno = this.NuevoTimer( tnMilisegundos, tcObjetoPublico, tcMetodoEventoAEjecutar, tcParametroParaElMetodo )

		this.nCantidadDeTimers = this.nCantidadDeTimers + 1
		lcMetodoEvento = this.SacarParentesisSiEstanAlFinal( tcMetodoEventoAEjecutar ) + "()"	
		lnManejadorExterno = this.MeterTimerEnLaColeccion( lnManejadorInterno, tnMilisegundos, tcObjetoPublico, lcMetodoEvento, tcParametroParaElMetodo ) &&tocar esto.
		
		return lnManejadorExterno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden Function NuevoTimer( tnMilisegundos As Integer, tcObjetoPublico As String, tcMetodoEventoAEjecutar As String, tcParametroParaElMetodo as String, tlRecursivo as Boolean ) As Integer
		Local lcMetodoEventoDeConsulta as String, lcMetodoEvento as String, ;
			  loEx as zooexception OF zooexception.prg, lcMetodoEvento as String, ;
			  lnManejador as Integer, loError as Exception, lnManejadorExterno  as Integer
		
		lnManejador = this.ObtenerManejadorInterno()
		lcMetodoEvento = this.SacarParentesisSiEstanAlFinal( tcMetodoEventoAEjecutar )
		lcEventoAEjecutar = tcObjetoPublico + "." + lcMetodoEvento + "(" + alltrim(tcParametroParaElMetodo) + ")"
		
		if vartype( &tcObjetoPublico ) = "O"
			If Pemstatus( &tcObjetoPublico, lcMetodoEvento, 5 ) and ( lnManejador # 0 )
				try
					lnManejador = SetupTimer( lnManejador, int( tnMilisegundos ), lcEventoAEjecutar )
					if lnManejador == -1
						lnManejador = 0
						goServicios.Errores.LevantarExcepcion( "No se pudo iniciar el timer. Error Interno de la librería: "  + lcEventoAEjecutar )
					endif
				Catch To loError
					lnManejador = 0
					if loError.ErrorNo == 1098 and !tlRecursivo
						this.SetearLibreria()
						lnManejador = this.NuevoTimer( tnMilisegundos, tcObjetoPublico, tcMetodoEventoAEjecutar, tcParametroParaElMetodo, .t. )
					else
						goServicios.Errores.LevantarExcepcion( "No se pudo iniciar el timer: " + transform( loError.Message ) )
					endif
				Endtry
			Else
				goServicios.Errores.LevantarExcepcion( "No se pudo iniciar el timer. No existe el método/evento:"  + lcEventoAEjecutar )	
			Endif
		else
			goServicios.Errores.LevantarExcepcion( "No se pudo iniciar el timer. No existe el objeto:"  + tcObjetoPublico )
		endif
		
		Return lnManejador &&Manejador Interno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MatarUnTimerEspecifico( tnHandler As Integer ) As Boolean
		local loError as Exception, llRetorno as Boolean, lcManejadorExterno as String 
		llRetorno = .f.
		lcManejadorExterno = transform( tnHandler )
		try
			if this.ogrupodetimerscreados.buscar( lcManejadorExterno )
				llRetorno = this.PararTimer( this.ogrupodetimerscreados.item( lcManejadorExterno ).nHandler )
				this.ogrupodetimerscreados.quitar( lcManejadorExterno  )
			endif
			this.nCantidadDeTimers = this.ogrupodetimerscreados.count
		catch to loError
			goServicios.Errores.LevantarExcepcion( "Error al quitar un timer especifico" + transform( loError.Message ) )
		endtry
		return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function PararTodosLosTimers() as Boolean
		local loError as Exception, i as Integer
		try
			KillTimers() &&KillTimers no funciona, es por esto que se realiza un MatarUnTimerEspecifico de los timers creados.		
		catch to loError
		finally
			if vartype( this.oGrupoDeTimersCreados ) == "O" and !isnull( this.oGrupoDeTimersCreados )
				for i = 1 to this.oGrupoDeTimersCreados.count
					this.PararTimer( this.oGrupoDeTimersCreados.item(i).nHandler )
				endfor
			endif		
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MatarTodosLosTimers() as Void
		local loError as Exception, i as Integer
		try
			this.PararTodosLosTimers()
		catch to loError
			goServicios.Errores.LevantarExcepcion( "Error al querer quitar todos los timers: " + transform(loError.Message ))
		finally
			with this
				.cEstadoDeLosTimers = ""
				if vartype( this.oGrupoDeTimersCreados ) == "O" and !isnull( this.oGrupoDeTimersCreados )
					.oGrupoDeTimersCreados.remove(-1)
				endif			
				.nCantidadDeTimers = 0
				.nHandelerTimer1Seg = 0
				.LiberarLaLibreriaDelTimer()
			endwith
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FrenarTodosLosTimers() as Void
		try
			this.PararTodosLosTimers()
			this.cEstadoDeLosTimers = "FRENADOS"
		catch to loError
			goServicios.Errores.LevantarExcepcion( "Error al querer frenar todos los timers: " + transform( loError.Message ) )
		endtry	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EncenderTodosLosTimersFrenados() as Void
		local lnHandler as Integer
		if this.cEstadoDeLosTimers == "FRENADOS"
			for i=1 to this.oGrupoDeTimersCreados.count
				loItem = this.oGrupoDeTimersCreados.item( i )
				with loItem
					lnHandler = this.NuevoTimer( .nMilisegundos, .cObjeto, .cMetodoEvento, .cParametroParaEvento )
				endwith
				this.oGrupoDeTimersCreados.item( i ).nHandler = lnHandler
			endfor
			this.cEstadoDeLosTimers = "INICIADOS"
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Evento1sec() as Void
		***Sin codigo, es solo un evento para que desde afuera se bindeen
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden Function ObtenerManejadorInterno( tcEsRecursivo as Boolean ) As Integer
		Local lnRetorno As Integer, loError as Exception
				
		lnRetorno = 0

		if this.VerificarDeclararciondeLibreria()		
			Try
				lnRetorno = GetFreeTimerIndex()
				if ( ( lnRetorno == 0 ) and ( this.nCantidadDeTimers >= 0 ) and ( !tcEsRecursivo ) ) ;
					 OR ( ( lnRetorno > 1 and this.nCantidadDeTimers == 0 ) )
					this.SetearLibreria()
					lnRetorno = this.ObtenerManejadorInterno(.t.)
				else
					do case 
						case Empty( lnRetorno )
							goServicios.Errores.LevantarExcepcion( "No hay más timers disponibles. Total:"  + Transform( int( goregistry.Nucleo.CantidadTimerBase ) ) )
						otherwise	
							this.cEstadoDeLosTimers = "INICIADOS"
					endcase
				endif
			Catch To loError
				goServicios.Errores.LevantarExcepcion( "Error al querer obtener el manejador interno de un timer: " + transform( loError.Message ) )
			endtry
		endif

		Return lnRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	hidden function VerificarDeclararcionDeLibreria() as boolean
		local lcLibreriasEnMemoria As String, llRetorno as Boolean, loError as Exception
		
		llRetorno = .t.
		lcLibreriasEnMemoria = ""

		try
			lcLibreriasEnMemoria = Set("Library")
			If Atc( "CPPTIMER.FLL", lcLibreriasEnMemoria  ) # 0 and this.lLaLibreriaYaFueDeclarada
				&& Ya está en memoria - no se setea nuevamente ya que rompe los timer actuales.
			Else
				llRetorno = this.SetearLibreria()
				this.lLaLibreriaYaFueDeclarada = llRetorno
			endif
		catch to loError
			llRetorno = .f.
			goServicios.Errores.LevantarExcepcion( "Error al querer verificar la declaración de la libreria: " + transform( loError.Message ) )
		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function SetearLibreria() as Boolean
		local loError as Exception, llRetorno as Boolean
		
		llRetorno = .t.
		this.LiberarLaLibreriaDelTimer()
		
		if file( this.cRutaDeFll )
			try
				Set Library To ( this.cRutaDeFll ) Additive
				inittimers( int( goregistry.Nucleo.CantidadTimerBase ), int( goregistry.Nucleo.PrecisionTimerBase ) )
			catch to loError
				goServicios.Errores.LevantarExcepcion( "Error declarando la libreria:"  + Transform( loError.Message ) )		
				llRetorno = .f.
			endtry	
		else
			goServicios.Errores.LevantarExcepcion( "Error no se encuentra la libreria del timer es la siguiente ruta: " + this.cRutaDeFll  )		
			llRetorno = .f.
		endif
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function MeterTimerEnLaColeccion( tnHandler as Integer, tnMilisegundos as Integer, tcObjetoPublico as String, tcMetodoEventoAEjecutar as String, tcParametroParaEseEvento as String ) as Void
		local loItem as Custom, lnManejadorExterno  as Integer
		
		lnManejadorExterno = this.ObtenerManejadorExterno()
		loItem = newobject( "custom" )
		loItem.AddProperty( "nHandler", tnHandler )
		loItem.AddProperty( "nMilisegundos", tnMilisegundos )
		loItem.AddProperty( "cObjeto", tcObjetoPublico  )
		loItem.AddProperty( "cMetodoEvento", tcMetodoEventoAEjecutar )
		loItem.AddProperty( "cParametroParaEvento", tcParametroParaEseEvento )
		loItem.AddProperty( "oGrupoDeTimersCreados", lnManejadorExterno)
		this.oGrupoDeTimersCreados.Agregar( loItem, transform( lnManejadorExterno ) )
		
		return lnManejadorExterno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function ObtenerManejadorExterno() as Integer
		this.nUltimoManejadorExterno = this.nUltimoManejadorExterno + 1
		return this.nUltimoManejadorExterno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function PararTimer( tnManejador as Integer ) as Boolean
		local llRetorno as Boolean, loError as Exception
		llRetorno = .t.
		try
			StopTimer( tnManejador )
		catch to loError
			llRetorno = .f.
		endtry
		return llRetorno
	endfunc 
	 
	*-----------------------------------------------------------------------------------------
	hidden function LiberarLaLibreriaDelTimer() as Void
		local loError as Exception
		try
			release library "cpptimer.fll"
		catch to loError
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function release() as Void
		this.MatarTodosLosTimers()
		dodefault()	
	endfunc 
	
Enddefine

