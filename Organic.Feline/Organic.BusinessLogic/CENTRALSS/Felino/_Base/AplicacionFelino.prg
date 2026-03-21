Define Class AplicacionFelino As AplicacionBase Of AplicacionBase.prg

	#if .f.
		local this as AplicacionFelino of AplicacionFelino.prg
	#endif
	protected lEsBuildAutomatico as Boolean
	
	lEsBuildAutomatico = .f.
	Nombre = "Zoo Logic Felino"
	NombreProducto = "FELINO"
	cProyecto = "FELINO"
	oBasculaBase = null
	oCaja =  null 
	oControlComprobantesFaltantes = null
	oColaboradorAccionesAutomaticas = null
	nPais = 0
	nControladorafiscal = 0
	lConfigurarLogo = .f.
	
	*-----------------------------------------------------------------------------------------
	function iniciar( tcSerie as string, tcClave as string, tcSitio as string ) as Boolean
	   public glProcesaAPSA as Boolean, glProcesaTOTALSALE as Boolean, glProcesaPUNTASHOPPING as Boolean, ;
	   			glProcesaCABALLITOSHOPPING as Boolean, glProcesarVENTASFISERV as Boolean, glModuloVentasFiServ as Boolean
	   local llRetorno as Boolean
	   
		llRetorno = dodefault( tcSerie, tcClave, tcSitio )
		this.lEsBuildAutomatico = _screen.zoo.esBuildAutomatico
		if llRetorno
			glProcesaAPSA = .F.
			glProcesaTOTALSALE = .F.
			glProcesaPUNTASHOPPING = .F.
			glProcesaCABALLITOSHOPPING = .F.
			glProcesarVENTASFISERV = .F.
			glModuloVentasFiServ = .F.
			with this
				.IniciarControlador()
				.EnlazarParametros()
				.IniciarBascula()
				.AgregarConfiguradoresAdicionalesAlAgente()
				.nPais = goparametros.Nucleo.DatosGenerales.Pais
				.nControladorafiscal = goParametros.Felino.ControladoresFiscales.Codigo
				.lDesplegarCombos = goParametros.Felino.Generales.AperturaAutomaticaDeCombos
				.IniciarInterfazFiServ()                                                                                              
				if !this.lDesarrollo and !this.lEsBuildAutomatico
					.ObtenerModulosOnline()                                                                                             
					.ActivarModuloVentasFiServ()
					.VerificarModuloDFCloud()
				endif
			endwith
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarConfiguradoresAdicionalesAlAgente() as Void
		local loConfigurador as Object
		if this.UtilizarElAAO() and !goServicios.Ejecucion.TieneScriptCargado() and !_screen.zoo.EsBUILDAUTOMATICO and !_screen.zoo.lDesarrollo and !this.lEsEntornoCloud
			loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOBackupSqlServer", "", goServicios.Parametros )		 
			this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic.AgregarConfiguradorAdicional( loConfigurador, "ConfigurarAAOBackupSqlServer" )
			
		endif
		loConfigurador = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EnlazarParametros() as Void
		with this
			bindevent( goparametros.oDatos, "CambioParametros", this, "VerificarControladorFiscal", 1 )
			bindevent( goparametros.oDatos, "CambioParametros", this.oColaboradorAccionesAutomaticas, "GeneraAccionesAutomaticasAPSA", 1 )
			bindevent( goparametros.oDatos, "CambioParametros", this.oColaboradorAccionesAutomaticas, "GeneraAccionesAutomaticasTOTALSALE", 1 )
			bindevent( goparametros.oDatos, "CambioParametros", this.oColaboradorAccionesAutomaticas, "GeneraAccionesAutomaticasPUNTASHOPPING", 1 )
			bindevent( goparametros.oDatos, "CambioParametros", this.oColaboradorAccionesAutomaticas, "GeneraAccionesAutomaticasCABALLITOSHOPPING", 1 )
            bindevent( goparametros.oDatos, "CambioParametros", this.oColaboradorAccionesAutomaticas, "GeneraAccionesAutomaticasVENTASFISERV", 1 )
			bindevent( goparametros.oDatos, "CambioParametros", this.oColaboradorAccionesAutomaticas, "GeneraAccionesAutomaticasParaRetenciones", 1 )
			bindevent( goParametros.oDatos, "AntesDeCargarNodosDeParametros", this, "ConfigurarParametrosParaPromocionesBancarias", 1 )
			bindevent( goparametros.oDatos, "CambioParametros", this, "VerificarCargaAjusteDeCupon" )
			bindevent( goparametros.oDatos, "CambioParametros", this, "PersistirNumeroDeCaja" )
			bindevent( goparametros.oDatos, "CambioParametros", this, "VerificarMemoriaServidorDeDatos" )
			bindevent( goparametros.oDatos, "EventoConfigurarLogo", this, "EventoConfigurarLogo" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PersistirNumeroDeCaja() as Void
		This.oCaja.SetearNumeroDeCajaActivaSegunValorEnParametros()
		This.oCaja.AsignarNumeroaEstadosDeCaja()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarMemoriaServidorDeDatos() as Void

		local lcMemoriaDisponibleParaElServidorDeDatos as String
		lcMemoriaDisponibleParaElServidorDeDatos = substr( alltrim( upper( goServicios.Parametros.Felino.Backup.MemoriaDisponibleParaElServidorDeDatos ) ), 1, 2 )
		do case
			case lcMemoriaDisponibleParaElServidorDeDatos = "20"
				This.SetearMemoriaMinimaDisponibleParaElServidorDeDatos( 0.2 )
			case lcMemoriaDisponibleParaElServidorDeDatos = "30"
				This.SetearMemoriaMinimaDisponibleParaElServidorDeDatos( 0.3 )
			case lcMemoriaDisponibleParaElServidorDeDatos = "40"
				This.SetearMemoriaMinimaDisponibleParaElServidorDeDatos( 0.4 )
		endcase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMemoriaMinimaDisponibleParaElServidorDeDatos( tnPorcentajeDeMemoria as float ) as Void
		&&Maximo de memoria establecido
		local lnMemoria as Integer, lnMinimo as Integer
		lnMemoria = This.ObtenerMemoriaFisicaServidorDeDatos()
		lnMinimo = lnMemoria * tnPorcentajeDeMemoria
		lnMinimo = max( 300, lnMinimo )
		this.SetearMemoriaMinimaParaServidorDeDatos( lnMinimo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMemoriaFisicaServidorDeDatos() as Integer
		local lnRetorno as Integer, lcSQL as String
		lcSQL = "create table #SVer(ID int,  Name  sysname, Internal_Value int, Value nvarchar(512));" + "insert #SVer exec master.dbo.xp_msver;" + "SELECT * FROM #SVer WHere Name = 'PhysicalMemory';" + "drop table #SVer;"
		goServicios.Datos.EjecutarSentencias( lcSQL, "", "", "c_MemoriaFisica", set("Datasession" ) )
		lnRetorno = c_MemoriaFisica.Internal_Value
		use in select( "c_MemoriaFisica" )
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMemoriaMinimaParaServidorDeDatos( tnMinimo as Float ) as Void
		local lcSQL as String
		lcSQL = "sp_configure 'max server memory', " + transform( int( tnMinimo )) + ";" + "RECONFIGURE;"
		goServicios.Datos.EjecutarSentencias( lcSQL, "", "", "", set("Datasession" ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarCargaAjusteDeCupon() as Void
		local llGrabar as String, loError as Exception

		if (this.nPais != 2 and goparametros.nuCLEO.daTOSGENERALES.paIS = 2) or ( this.nControladorafiscal <> 30 and goparametros.felINO.conTROLADORESFISCALES.coDIGO = 30)
						
			if !empty( goParametros.Felino.GestionDeVentas.AjusteDeCupon.ValorAUtilizarEnComprobantes )
				try
					loEntidad = _Screen.Zoo.InstanciarEntidad( "Valor" )
					loEntidad.VerificarAtributosFaltantesAjusteDeCupon()
				catch to loError
					goServicios.mensajes.Alertar( loError )
				finally
					loEntidad.Release()
				endtry
			endif			

		endif

		this.nPais = goparametros.nucleo.datosgenerales.pais
		this.nControladorafiscal = goparametros.Felino.ControladoresFiscales.Codigo

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarBascula() as Void
		with this
			.oBasculaBase = _screen.zoo.crearObjeto( "BasculaBase" )
			.oBasculaBase.inicializarBascula()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IniciarInterfazFiServ() as Void
		Public goInterfazFiServ as Object
		
        goInterfazFiServ = null

		try
			goInterfazFiServ = _screen.zoo.crearObjeto( "InterfazFiServ" )
		catch
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LoguearErrorModulosOnline( toError as Object ) as Void
		local lcMensajeError as String, loLogueador as Object
    	lcMensajeError = ""
	    lcMensajeError = "MODULOSACTIVACIONONLINE - " + iif(vartype( toError.uservalue ) = 'O', toError.uservalue.message, toError.message)
        loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( toError )
        loLogueador.Escribir( lcMensajeError )
        goServicios.Logueos.Guardar( loLogueador )
        loLogueador = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActivarModuloVentasFiServ() as Void   
		try
            glModuloVentasFiServ = goColaboradorModulosOnLine.ModuloHabilitado('0078')		
        catch to loError
			this.LoguearErrorModulosOnline( loError )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarModuloDFCloud() as Void   
		local llModuloDFCloud as Boolean, llErrorModulosOnline as Boolean, loError as Exception
		llErrorModulosOnline = .f.
		try
            llModuloDFCloud = goColaboradorModulosOnLine.ModuloHabilitado('0079')            
        catch to loError
        	llErrorModulosOnline = .t.
			this.LoguearErrorModulosOnline( loError )
		endtry
		if !llErrorModulosOnline
			do case
				case this.lEsEntornoCloud and !llModuloDFCloud
		           	goServicios.Errores.LevantarExcepcion( "El serie no tiene contratado el módulo de Dragonfish Cloud." ) 
				case !this.lEsEntornoCloud and llModuloDFCloud
		           	goServicios.Errores.LevantarExcepcion( "Es necesario tener el archivo cloud.config para que funcione correctamente el entorno de Dragonfish Cloud." ) 
		    endcase	        
        endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerModulosOnLine() as Void
		Public goColaboradorModulosOnLine as Object
		goColaboradorModulosOnLine = null

		try
			goColaboradorModulosOnLine = _screen.zoo.crearObjeto( "modulosActivacionOnLine" )
            goColaboradorModulosOnLine.ObtenerModulos()		
        catch to loError
            this.LoguearErrorModulosOnline( loError )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarExistenciaDeBackUp() as Void
		local lcMensaje as String, loEnt as Ent_RegistroDeMantenimiento of Ent_RegistroDeMantenimiento.prg, lnDias as Integer, ;
			llDebeValidarRegistroDeMantenimiento as Boolean

		llDebeValidarRegistroDeMantenimiento = NOT ( this.lDesarrollo or this.lEsBuildAutomatico )
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and !goServicios.Ejecucion.TieneScriptCargado()
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and goServicios.Datos.EsSqlServer()
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and goServicios.Parametros.felino.Backup.EjecutarTareasDeBackupDeFormaAutomatizada
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and goServicios.Parametros.felino.Backup.NotificarLaAusenciaDeRegistroDeBackup
		
		if llDebeValidarRegistroDeMantenimiento
			lnDias = goServicios.Parametros.felino.Backup.NotificarElFaltanteDeBackupsLuegoDeDias	
			loEnt = _screen.zoo.instanciarentidad( "RegistroDeMantenimiento" )
			try
				if !loEnt.VerificarUltimaTareaRealizadaCorrectamente( 2, lnDias ) and !loEnt.VerificarUltimaTareaRealizadaCorrectamente( 7, lnDias )
					lcMensaje = 'Hace más de ' + transform( lnDias ) + ;
						' días que no se realiza backup. Verifique el estado del mismo.'
					goMensajes.Advertir( lcMensaje )
				endif
			finally
				if vartype( loEnt ) == "O"
					loEnt.Release()
				endif
			endtry
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function oColaboradorAccionesAutomaticas_Access() as Void
		if !This.ldestroy and ( !vartype( this.oColaboradorAccionesAutomaticas ) = 'O' or isnull( this.oColaboradorAccionesAutomaticas ) )
			this.oColaboradorAccionesAutomaticas = _Screen.zoo.CrearObjeto( 'ColaboradorAccionesAutomaticas' )
		endif
		return this.oColaboradorAccionesAutomaticas
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalDefault() as Void
		return "FELINO"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServiciosConDependencia() as Void
		dodefault()
		This.IniciarCaja()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function iniciarCaja() as Void
		Public goCaja as Object 
		This.oCaja = _Screen.zoo.instanciarComponente( "ComponenteCaja" )
		goCaja = This.oCaja
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarControlador() as Void
		local loControladorFiscal as Object, llRetorno as Boolean, llMatarServicio  as Boolean, loInformacion as Object,;
			loError as Exception, lnVelocidadTransmisionNueva as integer, llCambioVelocidad as boolean

		Public goControladorFiscal as Object 

		llMatarServicio = .f.
		goControladorFiscal = null
		With This
			loControladorFiscal = this.ObtenerControladorFiscal()
			if !Isnull( loControladorFiscal ) And !Empty( loControladorFiscal.cClase )
				try	
					goControladorFiscal = this.ObtenerInstanciaControladorfiscal( Upper( Alltrim( loControladorFiscal.cClase ) ) )
					goControladorFiscal.nPuerto = Max( 1, goParametros.Felino.ControladoresFiscales.Puerto )
					goControladorFiscal.nCodigoAnterior = goParametros.Felino.ControladoresFiscales.Codigo
					***Evento para que se bindee el monitorQa
					_Screen.EventoCreacionOcxFiscal = 1
				
					try
						llRetorno = goControladorFiscal.Inicializar()
					catch to loError
			
						if pemstatus( loError, "UserValue", 5 ) and  vartype( loError.UserValue ) = "O"  and goControladorFiscal.SemaforoBloqueado() and ;
							vartype( loError.UserValue.oInformacion )='O' and loError.UserValue.oInformacion.count >0 and ;
						 loError.UserValue.oInformacion.item(1).cmensaje = "No se puede realizar la operación. El controlador fiscal esta ocupado."
							llRetorno = .T.
						else
							goServicios.Errores.LevantarExcepcion( loError )
						endif	
					endtry
					
					if llRetorno 
					else
						llCambioVelocidad = .f.
						lnVelocidadTransmisionNueva = val( goServicios.Parametros.Felino.ControladoresFiscales.VelocidadDeConexionHostSerie )						
						if goControladorFiscal.ConfigurarVelocidadTransmision()
							goControladorFiscal.nVelocidadTransmision = lnVelocidadTransmisionNueva
							llCambioVelocidad = .t.
						endif
						
						loInformacion = goControladorFiscal.ObtenerInformacion()
						if loInformacion.count >= 2
							if loInformacion.item[ 2 ].nnumero = 122
								llMatarServicio = .t.
							endif
						endif
						if loInformacion.count != 0 
							if llCambioVelocidad
								goServicios.Mensajes.Advertir( "El cambio en la velocidad de conexión Host Serie se hará efectivo " + ;
									"una vez que se apague y se vuelva a encender el controlador fiscal.", 0, 0, 'Impresora Fiscal' )
							else
								This.CargarInformacion( goControladorFiscal.ObtenerInformacion() )
								goMensajes.Advertir( This.ObtenerInformacion() )
							endif
						endif
						if llMatarServicio 
						else
							This.MatarCF()
						endif
					endif 
					
				catch to loError
					if pemstatus( loError, "UserValue", 5 ) and  vartype( loError.UserValue ) = "O" 
						This.CargarInformacion( loError.UserValue.oInformacion )
						This.AgregarInformacion( 'El servicio de controlador fiscal no estará disponible.' ) 
						goMensajes.Advertir( This.oInformacion )
						This.MatarCF()
					else 
						goServicios.Errores.LevantarExcepcion( loError )
					endif
				finally
					if vartype( loInformacion ) == "O"
						loInformacion = null
					endif
				endtry
			endif
		endwith

		loControladorFiscal = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function MatarCF() as Void
		try 
			goControladorFiscal.Release()
		catch
		finally
			goControladorFiscal = null
		endtry
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerInstanciaControladorfiscal( tcClase as String ) as Object
 		local loControladorFiscal as Object, lcPath as String, loError as Exception
 		
 		try 

			loControladorFiscal = this.ObtenerInstanciaControladorFiscalEspecifica( tcClase )
 			_screen.zoo.app.oControladorFiscal = loControladorFiscal
			_screen.zoo.app.oControladorFiscal.ConfigurarEntorno()
			_screen.zoo.app.oControladorFiscal.inittardio()
			
			this.DispararEventosDll()
			
		catch to loError
		endtry 

		return _screen.zoo.app.oControladorFiscal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInstanciaControladorFiscalEspecifica( tcClase as String ) as Object
		local loControladorFiscal as Object, lcPath as String, loRutaZoo as Object, lcRutaZoo as String, loError as Exception

		if this.lDesarrollo or _screen.zoo.EsBuildAutomatico
			try 
				loControladorFiscal = _screen.zoo.crearobjeto( tcClase ) 
			catch to loError 
			endtry
		endif

		if type( "loControladorFiscal" ) !="O" 

			loRutaZoo = _screen.zoo.invocarmetodoestatico( "System.IO.Directory", "GetParent", addbs( _screen.zoo.crutaINICIAL ) + "." )
			lcRutaZoo = loRutaZoo.FullName()

			do case
		 		case file( curdir() + "cf.app")
					lcPath = curdir() + "cf.app"
		 		case file( addbs( lcRutaZoo ) + "FELINO\CF\cf.app" )
					lcPath =  addbs( lcRutaZoo ) + "FELINO\CF\cf.app" 
		 		otherwise
			 		lcPath = "cf.app"
	 		endcase
	 		lcPath = "[" + lcPath + "]"
	 		
 			do &lcPath with tcClase, loControladorFiscal

		endif

		return loControladorFiscal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerVersionCFAPP() as Void
		local lcPath as String
		do case
 		case file( curdir() + "cf.app")
			lcPath = curdir() + "cf.app"
 		case file( substr( curdir(), 1, at( "zoo", curdir() ) +5 ) + "FELINO\CF\cf.app" )
			lcPath =  substr( curdir(), 1, at( "zoo", curdir() ) +5 ) + "FELINO\CF\cf.app" 
 		otherwise
	 		lcPath = "cf.app"
 		endcase
	 	lcPath = "[" + lcPath + "]"
 		do &lcPath
 		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DispararEventosDll() as void
		local lcListaEventos as string, lcEjecutar as String 
		
		lcListaEventos = _screen.zoo.app.oControladorFiscal.ObtenerNombreEventosaDisparar()

		for lnI = 1 to GetWordCount( lcListaEventos, "|")
			
			lcAtributo = alltrim( GetWordNum( lcListaEventos, lnI, "|") )

			lcEjecutar = "_screen.zoo.app.oControladorFiscal." + alltrim( lcAtributo ) 
			&lcEjecutar 
		endfor
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoCreacionOcxFiscal() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerControladorFiscal() As Object
		Local lnCodigo As Integer, loControlador As Object, lcCodigo as String, loControladores as Object, lnKey as Integer

		lnCodigo = 0
		loControlador = null
		loControladores = null
		
		if _screen.zoo.UsaCapaDePresentacion()
			lnCodigo = goParametros.Felino.ControladoresFiscales.Codigo
			if lnCodigo > 0
				loControladores = This.CrearObjeto( 'ModelosControladoresFiscales' )
				
				lnKey = loControladores.oModelos.GetKey( alltrim( str( lnCodigo ) ) )
				if lnKey > 0 and loControladores.oModelos.Item( lnKey ).lHabilitado
					loControlador = loControladores.oModelos.Item( lnKey )
				else
					goParametros.Felino.ControladoresFiscales.Codigo = 0
					goMensajes.enviar( "El código de Controlador Fiscal configurado es incorrecto.", 0, 2 )
				endif
			endif
		endif
		
		return loControlador
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoConfigurarLogo( tlConfigura as boolean ) as void
		this.lConfigurarLogo = tlConfigura
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarControladorFiscal() as Void
		local loError as Exception 
		
		This.VerificarInicializacionControladorFiscal()
		
		if vartype( goControladorFiscal ) = 'O' and !isnull( goControladorFiscal )
			try
				goControladorFiscal.CompararEncabezados_Y_Pies()
				if this.lConfigurarLogo
					this.lConfigurarLogo = .f.
					goControladorFiscal.ConfigurarLogo()
				endif
			catch to loError
				if goControladorFiscal.EsErrorConexion( loError.Message )
					goServicios.Mensajes.Alertar( goControladorFiscal.ObtenerMensajeSugerenciaErrorDeConexion( loError.Message ) )
				else
					goServicios.mensajes.Alertar( loError )
				endif
			endtry
	
		endif	
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function VerificarInicializacionControladorFiscal() as Void
		if ( vartype( goControladorFiscal ) # 'O' and !empty( goparametros.Felino.ControladoresFiscales.Codigo ) ) ;
			or ( vartype( goControladorFiscal ) = 'O'and !isnull( goControladorFiscal ) and ( goControladorFiscal.nCodigoAnterior != goparametros.Felino.ControladoresFiscales.Codigo ;
				or goControladorFiscal.nPuerto != goParametros.Felino.ControladoresFiscales.Puerto ;
				or ( goparametros.Felino.ControladoresFiscales.Codigo = 33 and ( goControladorFiscal.nVelocidadTransmision <> val( goServicios.Parametros.Felino.ControladoresFiscales.VelocidadDeConexionHostSerie ) ) ) ) )
				this.iniciarControlador()
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function VerificarOrigenDeDatosFaltantes( tcCodigoBase as String ) as void
		local 	lcTabla as String, lcSql as String , lcXml as String , loOrigenDeDatos as entidad OF entidad.prg,;
				lcBaseDeDatosActualizadas as String 
		
		dodefault()

		loOrigenDeDatos = _screen.zoo.instanciarentidad( "OrigenDeDatos" )
		lcBaseDeDatosActualizadas = ""
		
		goDatos.EjecutarSentencias( "Select empcod, nc1 from emp where empcod != '' " + ;
			"and empcod is not null and upper( ltrim( rtrim( empcod ) ) ) = '" + ;
			upper( alltrim( tcCodigoBase ) ) + "'", "emp.dbf", addbs( alltrim( _screen.Zoo.cRutaInicial )), ;
			"c_emp", this.DataSessionId )
		
		select c_Emp

		if empty( c_emp.nc1 )
			This.AgregarOrigendeDatos( loOrigenDeDatos, alltrim( c_Emp.Empcod ) )
			lcSql = "Update emp set nc1 = empcod where upper( ltrim( rtrim( empcod ) ) ) = '" + upper( alltrim( c_Emp.Empcod ) ) + "'"
			goDatos.EjecutarSentencias( lcSql, "emp.dbf", addbs( alltrim( _screen.Zoo.cRutaInicial ) ) )
		Else
			try
				loOrigenDeDatos.Codigo = alltrim( c_Emp.nc1 )
			catch
				This.AgregarOrigendeDatos( loOrigenDeDatos, alltrim( c_Emp.nc1 ) )
			endtry
		endif				

		use in select( "c_emp" )
		loOrigenDeDatos.Release()
		
		return 
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AgregarOrigendeDatos( toOrigenDeDatos as String, tcCodigo as String ) as Void
		toOrigenDeDatos.Nuevo()
		toOrigenDeDatos.Codigo = tcCodigo
		toOrigenDeDatos.Grabar()
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		dodefault()
		this.oBasculaBase = null
        release goColaboradorModulosOnLine
        this.DestruirObjetoFiServ()
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function Salir( tlSalidaForzada as Boolean ) as Void
		this.oBasculaBase = null
        release goColaboradorModulosOnLine
        this.DestruirObjetoFiServ()

		dodefault( tlSalidaForzada )
	endfunc 
	
    *-----------------------------------------------------------------------------------------
    protected function DestruirObjetoFiServ() as Void
        try   
            if vartype( goInterfazFiServ ) = 'O' and !isnull( goInterfazFiServ )
                if goInterfazFiServ.idConexion > 0
                    goInterfazFiServ.DestruirObjetosNet()
                endif
                release goInterfazFiServ
            endif
         catch
         endtry
    endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReiniciarServicios( tlSaltaFiscal as Boolean ) as Void
		goServicios.Impresion.release()

		if !tlSaltaFiscal and vartype( goControladorFiscal ) != "O"
			this.IniciarControlador()
		endif
		
		dodefault()
		goCaja.release()
		this.iniciarCaja()
		goServicios.SaltosDeCampoYValoresSugeridos.detener()
		goServicios.Entidades.AccionesAutomaticas.RefrescarColeccionDeEntidadesConAccionesAutomaticas()
		goservicios.WebHook.release()
        this.IniciarInterfazFiServ() 
		this.ObtenerModulosOnline()                                                                                             
		this.ActivarModuloVentasFiServ()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarReferencias() as Void
		dodefault()
		this.AgregarReferencia( "ZooLogicSA.Redondeos.dll" )
		this.AgregarReferencia( "ZooLogicSA.FacturacionElectronicaV2.dll" )
		this.AgregarReferencia( "ZooLogicSA.FacturacionElectronicaV2.UIConfiguracion.dll" )
		this.AgregarReferencia( "ZooLogicSA.AceptacionDeValores.dll" )		
		this.AgregarReferencia( "ZooLogicSA.ControladoresFiscales.dll" )
		this.AgregarReferencia( "ZooLogicSA.ControladoresFiscales.EpsonTMT900FA.dll" )
		this.AgregarReferencia( "ZooLogicSA.ControladoresFiscales.HasarPT1000F.dll" )
		this.AgregarReferencia( "ZooLogicSA.ControladoresFiscales.Sam4sELLIX40F.dll" )
		this.AgregarReferencia( "ZooLogicSA.DispositivosPinpad.VisaPos.dll" )
		this.AgregarReferencia( "ZooLogicSA.COT.Adaptador.dll" )
		this.AgregarReferencia( "ZooLogicSA.COT.CertificadoDigital.dll" )
		this.AgregarReferencia( "ZooLogicSA.DisplayVFD.dll" )
		this.AgregarReferencia( "ZooLogicSA.Omnicanalidad.dll" )
		this.AgregarReferencia( "ZooLogicSA.ActivacionOnline.dll" )
		this.AgregarReferencia( "ZooLogicSA.CodigoQR.dll" )
		this.AgregarReferencia( "ZooLogicSA.SireWS.dll" )
		this.AgregarReferencia( "ZooLogicSA.FacturacionelectronicaUruguay.dll" )	
		this.AgregarReferencia( "ZooLogicSA.EditorHTML.UI.dll" )
		this.AgregarReferencia( "ZooLogicSA.LasPiedrasShopping.dll" )		
		this.AgregarReferencia( "ZooLogicSA.DispositivoPosnet.dll" )		
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarMenuPrincipal() as Void
		dodefault()
		this.ActualizarMenuServicio()
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarMenuServicio() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDelLogin() as Void
		local loHelper as Object, lcValorPrimerUso as String
		dodefault()
		if !this.lEsEntornoCloud
			this.ValidarExistenciaDeBackUp()	
			this.ValidarEjecucionMantenimientoBD()
		endif

		loHelper = _screen.zoo.crearobjeto("HelperPropiedadesExtendidasBD")
		lcValorPrimerUso = loHelper.obtenervalorpropiedadextendidadb("ZOOLOGICMASTER", "PrimerUso")

		* null: no existe la propiedad extendida, caso normal, no hacer nada
		if ( !isnull(lcValorPrimerUso) )
			*!* OJO *!*
			*!* Cuando se active la funcionalidad de precios con vigencia descomentar esta accion *!*
			
			*!* goParametros.Felino.Precios.UsarPreciosConVigencia = .f.
			
			*!* OJO *!*
		endif
		
		if pemstatus( goParametros.Felino.Precios, "UsarPreciosConVigencia", 5 ) and !goParametros.Felino.Precios.UsarPreciosConVigencia
			*!* OJO *!*
			*!* Cuando se active la funcionalidad de precios con vigencia quitar esta accion *!*
			goParametros.Felino.Precios.UsarPreciosConVigencia = .t.
			*!* OJO *!*
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function  ConfigurarParametrosParaPromocionesBancarias() as Void
		local loEntidad as Object, lcCodigoValor as String, lcCursor  as String, lcTabla as String, llExisteCodigo as Boolean, lcCampoCodigoValor as String, lcCampoTipoValor as String
		if empty( goParametros.Felino.GestionDeVentas.AjusteDeCupon.ValorAUtilizarEnComprobantes )
			loEntidad = _Screen.Zoo.InstanciarEntidad( "Valor" )
			lcCursor = sys( 2015 )
			lcTabla = loEntidad.oAd.cTablaPrincipal
			lcCampoCodigoValor = loEntidad.oAD.ObtenerCampoEntidad( "Codigo" )
			lcCampoTipoValor = loEntidad.oAD.ObtenerCampoEntidad( "Tipo" )
			goServicios.Datos.EjecutarSentencias( "Select " + lcCampoCodigoValor + " as Codigo from " + lcTabla  + " where " + lcCampoTipoValor + " = 10", lcTabla , "", lcCursor,  set ( "Datasession" ) )
			llExisteCodigo  = !empty( &lcCursor..Codigo )
			use in select( lcCursor )
			if not llExisteCodigo 
				lcCodigoValor = loEntidad.CrearValorParaAjusteDeCupon()
				if !empty( lcCodigoValor  )
					goParametros.Felino.GestionDeVentas.AjusteDeCupon.ValorAUtilizarEnComprobantes = lcCodigoValor 
				endif
			endif
			loEntidad.Release()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificacionDeParametrosRZ() as Void
		local loParametrosRzPuesto as Object, loVerificadorParametrosRazonSocial as VerificadorParametrosRazonSocial of VerificadorParametrosRazonSocial.prg

		loParametrosRzPuesto = _screen.zoo.crearobjeto( "ParametrosRzPuesto" )
		loVerificadorParametrosRazonSocial = _screen.zoo.crearobjeto( "VerificadorParametrosRazonSocial", "VerificadorParametrosRazonSocial.prg", loParametrosRzPuesto )
		
		if loVerificadorParametrosRazonSocial.PuestoDebeMigrarParametrosASucursal()
			
			do case 
				case loVerificadorParametrosRazonSocial.BaseDeDatosNoTieneParametrosRz()
					loVerificadorParametrosRazonSocial.MigrarParametros()
				case loVerificadorParametrosRazonSocial.BaseDeDatosTieneParametrosDistintos()
					goMensajes.Advertir( "Se encontraron diferencias entre el puesto y la base de datos para los parámetros referidos a los datos de la empresa." + chr(13)+ "Compruebe los datos ingresados en Configuración --> Parámetros --> Datos de la Empresa" )

					this.Loguear( "Se encontraron diferencias entre el puesto y la base de datos para los parámetros referidos a los datos de la empresa." )
					this.Loguear( "Valores en Puesto: " + loVerificadorParametrosRazonSocial.ObtenerValoresParametrosParaLogPuesto() )
					this.Loguear( "Valores en Base de Datos: " + loVerificadorParametrosRazonSocial.ObtenerValoresParametrosParaLogSucursal() )
					this.FinalizarLogueo()

			endcase

			loVerificadorParametrosRazonSocial.MarcarBDComoProcesada()
		endif
		
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ValidarEjecucionMantenimientoBD() as Void
		local loEnt as RegistroDeMantenimiento of RegistroDeMantenimiento.prg, loConectorDeRedes as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg, ;
			loError as exception, lcMensaje as String 

		llDebeValidarRegistroDeMantenimiento = NOT ( this.lDesarrollo or this.lEsBuildAutomatico )
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and !goServicios.Ejecucion.TieneScriptCargado()
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and goServicios.Datos.EsSqlServer()
		llDebeValidarRegistroDeMantenimiento = llDebeValidarRegistroDeMantenimiento and goServicios.Parametros.felino.Backup.EjecutarTareasDeBackupDeFormaAutomatizada
		
		if llDebeValidarRegistroDeMantenimiento
			lnDias = 2
			loEnt = _screen.zoo.instanciarentidad( "RegistroDeMantenimiento" )
			try
				if !loEnt.VerificarUltimaTareaRealizadaCorrectamente( 3, lnDias ) && 3 -> Mantenimiento de bases de datos
					loConectorDeRedes = _screen.zoo.crearobjeto("ConectorAgenteDeAccionesOrganic" )
					if !_Screen.zoo.EsModoSystemStartup()
						loConectorDeRedes.EjecutarMantenimiento()
					endif
					loConectorDeRedes.release()
				endif
			catch to loError
				this.loguear( "Se produjo un error al comunicarse con el Agente de Acciones Organic. No se pudo realizar el mantenimiento. " ) 
				if pemstatus( loError, "UserValue", 5 ) and  vartype( loError.UserValue ) = "O"  and ;
					vartype( loError.UserValue.oInformacion )='O' and loError.UserValue.oInformacion.count >0 
					 lcMensaje = loError.UserValue.oInformacion.item(1).cmensaje 
				else
					lcMensaje = loError.Message
				endif	
				this.loguear( lcMensaje ) 
				
			finally
				if vartype( loEnt ) == "O"
					loEnt.Release()
				endif
			endtry
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function UtilizaCF() as Boolean
		return goServicios.Parametros.Felino.ControladoresFiscales.Codigo > 0	and goServicios.Parametros.Felino.ControladoresFiscales.Codigo != 30 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarMigradorDeParametros() as Void
		local loFactoryMigradorParametros as Object, loMigrador as Object 
		
		**** Esta llamada se deja porque la migración de parámetros de Razón Social muestra un mensaje de 
		**** advertencia que en el nuevo circuito de migración de parámetros no se implementó, en un futuro
		**** se va a quitar eta migración.
		
		this.VerificacionDeParametrosRZ()
		***************************************************************************************************
		
		loFactoryMigradorParametros = _screen.zoo.crearobjeto( "FactoryMigradorDeParametros" )
		loMigrador = loFactoryMigradorParametros.Obtenermigradordeparametros()
		loMigrador.EjecutarMigraciones()		
	endfunc 
	
enddefine
