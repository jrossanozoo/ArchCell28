define class AdnImplant as ZooSession of ZooSession.prg

	#if .f.
		local this as AdnImplant of AdnImplant.prg
	#endif
	
	lMuestraForm = .f.
	cRutaArchivoMDF = ""
	
	*-----------------------------------------------------------------------------------------
	function Inicializar( tlMuestraForm as Logical, tcBaseMaster as String, tcSucursalDefault as String )
		local loLogueoEnFormulario as Object, loLogueoEnArchivo as Object 

		dodefault( tlMuestraForm , tcBaseMaster )
		
		with this
			.lMuestraForm = tlMuestraForm 
		endwith
			
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoParametros( tnModoProceso as Integer ) as Object
		local	loFactoryNet as Object, loParametros as Object, ;
				loVersion as Object, lnMomento as Integer, lcVersion as String, lcRutaGenerados as String,;
				lcRutaPersonalSP as String 

			lcRutaGenerados = addbs( _Screen.zoo.cRutaInicial ) + "Generados"
			lcRutaPersonalSP = addbs( _Screen.zoo.cRutaInicial ) + "ScriptDB"
			loFactoryNet = _Screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic")
			lcVersion = this.ObtenerVersion()	
			if type ("lcVersion") != "C"
				lcVersion = ""
			endif
			loVersion = loFactoryNet.ObtenerVersion( lcVersion )
			if vartype( tnModoProceso ) == "N" 
				loParametros = loFactoryNet.ObtenerParametros( tnModoProceso )
			else 
				loParametros = loFactoryNet.ObtenerParametros()
			endif 
			
	        with loParametros
	       		.RutaCreacionArchivosMDF= this.cRutaArchivoMDF
	        	.VersionAplicacion= loVersion
	        	.NombreAplicacion = _Screen.Zoo.App.cProyecto
	        	.NombreProducto = _Screen.Zoo.App.NombreProducto
	        	.RutaGenerados = lcRutaGenerados 
	        	.RutaAplicacion= _Screen.zoo.cRutaInicial
	        	.RutaArchivosConfiguracionLog = _Screen.zoo.cRutaInicial
	        	.EjecutarSilencioso = _screen.Zoo.EsModoSystemStartUp() or !_Screen.Zoo.UsaCapaDePresentacion()
	        endwith
		return loParametros
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		protected function DebeEjecutarAdnImplant( tnProcesos as Integer, tcSucursales as String, tlForzarCambios as Boolean ) as Boolean
*!*			local llRetorno as Boolean, ldFechaRegistry as Date, lcRegistry as String, loError as Exception, loEx as zooexception OF zooexception.prg, ;
*!*				lcRegistryVersion as String
*!*					
*!*			&&tnProcesos = 1 : Sucursal
*!*			&&tnProcesos = 2 : Puesto, Organizacion, Seguridad
*!*			llRetorno = .f.	
*!*			try	
*!*				lcRegistry = "goServicios.Registry.Nucleo."
*!*				if tlForzarCambios or _screen.zoo.App.oMonitorDeIngresoYSalida.HaySalidasErroneas()
*!*					llRetorno = .t.
*!*				else
*!*					if tnProcesos = 1
*!*						lcRegistryVersion = lcRegistry + "VersionBaseDeDatosSucursal"
*!*						lcRegistry = lcRegistry + "UltimaFechaValidacionCorrectaBDSucursal"
*!*					else
*!*						lcRegistryVersion = lcRegistry + "VersionBaseDeDatosOrganizacion"
*!*						lcRegistry = lcRegistry + "UltimaFechaValidacionCorrectaBDOrganizacion"
*!*					endif
*!*					ldFechaRegistry = &lcRegistry
*!*					if this.TieneFechaVaciaEnSQLServer( ldFechaRegistry )
*!*						llRetorno = .t.
*!*					else
*!*						llRetorno = ( date() - ldFechaRegistry ) >= goServicios.Registry.Nucleo.CantidadDeDiasUltimaFechaValidacionCorrectaBD
*!*					endif
*!*					
*!*					&& Se ejecuta la validación de versión siempre y cuando la validacion de la fecha no fuerce la corrida del adnimnplant
*!*					llRetorno = llRetorno or this.DebeCorrerAdnImplantPorVersion( &lcRegistryVersion )
*!*					
*!*					loConfiguraciones = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Configuraciones.Configuraciones" )
*!*						
*!*					&& esta parte debe ser solo para v3
*!*					if !llRetorno and loConfiguraciones.AdnImplant.VersionMotorAdnImplant == "V3"
*!*						local lcBaseDeDatos as String
*!*						if empty( tcSucursales )
*!*							lcBaseDeDatos = _screen.zoo.app.cBDMaster
*!*						else
*!*							lcBaseDeDatos = goServicios.Librerias.ObtenerNombreSucursal( tcSucursales )
*!*						endif
*!*						llRetorno = this.DebeEjecutarSegunPropExt( lcBaseDeDatos ) 
*!*						llRetorno = llRetorno or this.DebeEjecutarSegunRestoreBackup( lcBaseDeDatos )
*!*						llRetorno = llRetorno or this.DebeEjecutarSegunSemaforo( lcBaseDeDatos )
*!*					endif
*!*				endif
*!*			catch to loError
*!*				llRetorno = .t. &&Corre el ADNImplant ya que no se pudo determinar si ya corrio.
*!*				loEx = newobject( "ZooException", "ZooException.prg" )
*!*				with loEx as zooexception OF zooexception.prg
*!*					loEx.Message = "Se va a realizar el control en la base de datos ya que ocurrio un error al verificar si se debe correr el control (proceso:" + transform( tnProcesos ) + ")."
*!*					.Grabar( loError )
*!*				endwith
*!*			endtry
*!*					
*!*			return llRetorno
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarUlfimaFechaValidacionCorrectaBD( tnProcesos as Integer ) as Void
		if tnProcesos = 1
			goServicios.Registry.Nucleo.UltimaFechaValidacionCorrectaBDSucursal = date()
			goServicios.Registry.Nucleo.VersionBaseDeDatosSucursal = _screen.zoo.app.oVersion.Version
		else
			goServicios.Registry.Nucleo.UltimaFechaValidacionCorrectaBDOrganizacion = date()
			goServicios.Registry.Nucleo.VersionBaseDeDatosOrganizacion = _screen.zoo.app.oVersion.Version
		endif
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		protected function DebeCorrerAdnImplantPorVersion( tcVersionParametro as String ) as Boolean
*!*			local llRetorno as Boolean
*!*		
*!*			llRetorno = .t.
*!*			if alltrim( tcVersionParametro ) == alltrim( _screen.zoo.app.oVersion.Version )
*!*				llRetorno = .f.
*!*			endif
*!*			
*!*			return llRetorno
*!*		endfunc 


*!*		*-----------------------------------------------------------------------------------------
*!*		protected function TieneFechaVaciaEnSQLServer( tdFecha as Date ) as Boolean
*!*			local lcFechaString as String

*!*			lcFechaString = ""
*!*			if !empty( tdFecha )
*!*				lcFechaString = alltrim( strtran( transform( golibrerias.obtenerfechaformateada( tdFecha, "SQLSERVER" ) ), "/", "" ) )
*!*			endif
*!*		
*!*			return empty( lcFechaString )
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
*!*		protected function DebeEjecutarSegunPropExt( tcBaseDeDatos as String ) as Boolean
*!*			local lcSentencia as String, lcCursor as String, llRetorno as Boolean
*!*			
*!*			llRetorno = .f.
*!*			
*!*			lcSentencia = "select name as nombre, value as valor " + ;
*!*							"from " + tcBaseDeDatos + ".sys.extended_properties " + ;
*!*							"where class_desc = 'DATABASE'"
*!*			
*!*			lcCursor = "c_PropiedadesExtendidas"

*!*			goDatos.EjecutarSentencias( lcSentencia, "", "", lcCursor, this.DataSessionId )
*!*			select ( lcCursor )

*!*			locate for alltrim( upper( nombre ) ) == 'ESTADODEPROCESO'
*!*			if found() and alltrim( upper( valor ) ) != "ONLINE"
*!*				llRetorno = .t.
*!*			endif
*!*			
*!*			use in select( lcCursor )
*!*			
*!*			return llRetorno 
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
*!*		protected function DebeEjecutarSegunRestoreBackup( tcBaseDeDatos as String ) as Boolean
*!*			local lcSentencia as String, lcCursorBackups as String, lcCursorChequeoIntegridad as String, ldFechaUltimoChequeo as Datetime, ;
*!*				llRetorno as Boolean, loError as Exception

*!*			llRetorno = .f.
*!*			lcCursorChequeoIntegridad = "c_ChequeoIntegridad"
*!*			lcCursorBackups = "c_RestauracionBackups"
*!*			lcSentencia = "SELECT [FechaUltimoChequeoIntegridad] FROM [" + tcBaseDeDatos + "].[ADNIMPLANT].[EstructuraBDVersion]"

*!*			try
*!*				goDatos.EjecutarSentencias( lcSentencia, "", "", lcCursorChequeoIntegridad, this.DataSessionId )
*!*				select( lcCursorChequeoIntegridad )
*!*				if reccount() > 0
*!*					ldFechaUltimoChequeo = &lcCursorChequeoIntegridad..FechaUltimoChequeoIntegridad
*!*					lcSentencia = "SELECT " + ;
*!*									"MAX(restore_date) as FechaUltimoRestore " + ;
*!*									"FROM msdb.dbo.restorehistory WITH (nolock) " + ;
*!*									"WHERE (destination_database_name = '" + tcBaseDeDatos + "') " + ;
*!*									"GROUP BY destination_database_name "
*!*									
*!*					goDatos.EjecutarSentencias( lcSentencia, "", "", lcCursorBackups, this.DataSessionId )
*!*					select ( lcCursorBackups )
*!*					if reccount() > 0 and &lcCursorBackups..FechaUltimoRestore > ldFechaUltimoChequeo 
*!*						llRetorno = .t.				
*!*					endif				
*!*				else
*!*					llRetorno = .t.
*!*				endif
*!*			catch to loError
*!*				throw loError
*!*			finally
*!*				use in select( lcCursorBackups )		
*!*				use in select( lcCursorChequeoIntegridad )
*!*			endtry
*!*			
*!*			return llRetorno
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
*!*		protected function DebeEjecutarSegunSemaforo( tcBaseDeDatos as String ) as Boolean
*!*			local lcSentencia as String, lcCursor as String, llRetorno as Boolean

*!*			llRetorno = .f.
*!*			
*!*			try
*!*				lcSentencia = "SELECT [BaseDeDatos],[Ubicacion],[Bloqueada],[ModoDeProceso],[FechaUltimoCambio],[NombrePC] " +;
*!*								"FROM [ADNIMPLANT].[dbo].[Semaforo] " + ;
*!*								"where BaseDeDatos = '" + tcBaseDeDatos + "' and Bloqueada = 1"
*!*				
*!*				lcCursor = "c_Semaforo"

*!*				goDatos.EjecutarSentencias( lcSentencia, "", "", lcCursor, this.DataSessionId )
*!*				select ( lcCursor )
*!*				if reccount() > 0
*!*					llRetorno = .t.
*!*				endif
*!*			catch to loError
*!*				llRetorno = .t.
*!*			finally		
*!*				use in select( lcCursor )
*!*			endtry
*!*			
*!*			return llRetorno 
*!*		endfunc 


	*-----------------------------------------------------------------------------------------
	function EjecutarAdnImplantV2( tnProcesos as Integer, tcSucursales as String, tlForzarCambios as Boolean ) as boolean
		local	loFactoryNet as Object, loParametros as Object, loLanzadorAdnImplant as Object,;
				lnMomento as Integer,llOk as Boolean

        *Nativa = 0
        *SQLServer = 1

        *StandAlone = 0
        *Instalacion = 1
        *Actualizacion = 2
        *Login = 3
        *LoginSuc = 4       		
        *Replica = 5
        
*!*	***** Modo Proceso ADNImplant
*!*			Nulo = 0
*!*	        Instalacion = 1
*!*	        Actualizacion = 2
*!*	        CreacionReplica = 3
*!*	        Validacion = 4
*!*	        ValidacionCompletaEnSegundoPlano = 5 //Este modo de proceso no existe como tal, solo es una variante de la validacion de todas las base de datos
*!*	        Reparacion = 6
*!*	        VerificacionInstalacion = 7
*!*	        Eliminacion = 8
*!*	        Archivar = 9
*!*	        Desarchivar = 10 
*!*	        EjecucionFixes = 11
*!*	        Migracion = 12 
*!*	        RestauracionSnapshot = 13
*!*	        SinTareas = 14 
*!*	        CorreccionCollation = 15
**********************************************

*!*			do case
*!*				case tnProcesos = 1
*!*					lnMomento = 4
*!*				case tnProcesos = 2
*!*					lnMomento = 3
*!*				case tnProcesos = 3
*!*					lnMomento = 1
*!*				case tnProcesos = 4 && replica
*!*					lnMomento = 5
*!*				case tnProcesos = 5 && actualizacion
*!*					lnMomento = 2
*!*				case tnProcesos = 6 && restauracionBD
*!*					lnMomento = 13
*!*				otherwise
*!*					lnMomento = 0
*!*			endcase
		
		loParametros = This.ObtenerObjetoParametros( tnProcesos )
		loFactoryNet = _Screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )
		
		local lnI as Integer
		for lnI = 1 to getwordcount( tcSucursales, ',' )
			lcSucursal = getwordnum( tcSucursales, lnI, ',' )
			loParametros.AgregarBDAProcesar( lcSucursal , .t. )        
		endfor

        loParametros.EjecutarSilencioso = _screen.Zoo.EsModoSystemStartUp() or !_Screen.Zoo.UsaCapaDePresentacion()
		loLanzadorAdnImplant = loFactoryNet.ObtenerLanzador()
		
		llOk = this.LlamarAdnimplantYRetornarFoco( loLanzadorAdnImplant, loParametros )

		loLanzadorAdnImplant= null

		if llOk
			this.ActualizarUlfimaFechaValidacionCorrectaBD( tnProcesos )
		endif
		
		return llOk
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVersion() as String 
		local lcRetorno as String 

		if this.EstoyEnDesarrollo()
			lcRetorno = ""
		else
			lcRetorno = _Screen.Zoo.App.ObtenerVersion()
		endif
		
		return lcRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function EstoyEnDesarrollo() as Boolean
		return _Screen.Zoo.lDesarrollo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarModoReparacion( tcBaseDeDatos as String ) as Boolean
		local loParametros as Object, loFactoryNet as Object, llRetorno as Boolean

		loParametros = This.ObtenerObjetoParametros( 6 ) && Modo Reparación
		loFactoryNet = _Screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )
		loParametros.AgregarBDAProcesar( tcBaseDeDatos, .t. )        

		loAdnImplant = loFactoryNet.ObtenerLanzador()
		
		llRetorno = this.LlamarAdnimplantYRetornarFoco( loAdnImplant, loParametros )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlamarAdnimplantYRetornarFoco( toAdnImplant as object, toParametros as Object ) as Boolean
		local loForm, loWshShell, loCliqueador, llOk as Boolean

		loForm = _screen
		if type( "_Screen.ActiveForm" ) = "O"
			loForm = _Screen.ActiveForm
		endif

		try
			llOk = toAdnImplant.Lanzar( toParametros )
		finally
			if vartype( loForm ) != "O" or isnull( loForm ) 
				loForm = _screen
			endif

			loWshShell = CreateObject( "WScript.Shell" )
			loWshShell.AppActivate( _screen.Caption )
			loWshShell.AppActivate( loForm.Caption )
			loWshShell = null

			if loForm.Visible
				if type( "goFormularios" ) = "O" and !isnull( goFormularios )
					goFormularios.TraerAlFrente( loForm )
				endif
					
				loCliqueador = _screen.zoo.crearobjeto( "CliqueadorParaDarFoco" )
				loCliqueador.Procesar(loForm )
			endif
		endtry

		return llOk 
	endfunc 


enddefine