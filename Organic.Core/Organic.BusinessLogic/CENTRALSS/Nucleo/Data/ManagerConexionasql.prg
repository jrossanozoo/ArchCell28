define class managerConexionASql as zooSession of zooSession.prg

	#if .f.
		local this as managerConexionASql of managerConexionASql.prg
	#endif

	#Define SERVIDORLOCALINICIADO 1
	#Define SERVIDORREMOTOVALIDO 2
	#Define SERVIDORLOCALREINICIADO 3
	#Define SERVIDORLOCALSININICIAR 4
	#Define SERVIDORREMOTOSINACCESO 5
	#Define SERVIDORLOCALINEXISTENTE 6
	#Define SERVIDORREMOTOERROR 7

	#Define PERMISO_LECTURA   0x80000000  
	#Define PERMISO_ESCRITURA 0x40000000  
	#Define PERMISO_EJECUCION 0x20000000  

	#Define GENERIC_READ	0x80000000

	nHandler = 0
	nTimeOut = 0
	nReintentos = 0
	lServicioFrenado = .f.
	oProveedorStringConnection = null
	lDBInicializada = .f.
	oConexionSQL = null
	
	*-----------------------------------------------------------------------------------------
	function oProveedorStringConnection_Access() as Object
		local lcRutaDataConfig as String
		if !this.ldestroy and ( !vartype( this.oProveedorStringConnection ) = 'O' or isnull( this.oProveedorStringConnection ) )
			_screen.zoo.AgregarReferencia( "ZoologicSA.Core.DbConnection.dll" )
			lcRutaDataConfig = addbs(_screen.zoo.app.cRutaDataConfig ) + "dataconfig.ini"
			this.oProveedorStringConnection  = _screen.zoo.crearObjeto( "ZoologicSA.Core.DbConnection.ProveedorDeStringConnection","", lcRutaDataConfig )
		endif
		return this.oProveedorStringConnection
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oConexionSQL_Access() as Object
		if !this.ldestroy and ( !vartype( this.oConexionSQL ) = 'O' or isnull( this.oConexionSQL ) )
			this.oConexionSQL  = _screen.zoo.crearObjeto( "ConexionMotorSQL","managerConexionASql.PRG" )
		endif
		return this.oConexionSQL
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerConexion() as Integer
		if this.nHandler <= 0
			this.nHandler = this.Conectar()
		endif
		return this.nHandler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MarcarDBParaInicializar() as Void
		this.lDBInicializada = .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeInicializarDB() as Boolean
		return !this.lDBInicializada
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNuevaConexion() as Integer
		return this.Conectar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringConnect() as string
		local lcStringConnect as String
		lcStringConnect = this.oProveedorStringConnection.Obtener( "ODBC", this.ObtenerNombreBaseDeDatos() ) 
		return lcStringConnect
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringConnectMaster() as string
		local lcStringConnect as String
		
		lcStringConnect = this.oProveedorStringConnection.Obtener( "ODBC", "master" ) 
		return lcStringConnect
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringConnectSinDb() as String
		local lcStringConnect as String
		lcStringConnect = this.oProveedorStringConnection.Obtener( "ODBC" )
		return lcStringConnect 
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarConexionADBEspecifica( tcDB as String ) as Boolean
		local lnConexion as Integer, llRetorno as Boolean, lnIntentos as Integer
		lnConexion = 0
		llRetorno = .f.
		lnIntentos = max( this.nReintentos, 1 )
		do while lnIntentos > 0 and lnConexion <= 0
			try
				lnConexion = this.Conectar( this.ObtenerStringConnectADBEspecifica( tcDB ) )
			catch
			endtry
			lnIntentos = lnIntentos - 1
		enddo
		if ( lnConexion > 0 )
			llRetorno = .t.
			sqldisconnect( lnConexion )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringConnectADBEspecifica( tcDB as String ) as string
		local lcStringConnect as String
		
		lcStringConnect = this.oProveedorStringConnection.Obtener( "ODBC", tcDB ) 
		return lcStringConnect
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDelServidor() as String
		return _Screen.Zoo.App.cNombreDelServidorSQL
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreBaseDeDatos() as String
		return _Screen.Zoo.App.cNombreBaseDeDatosSQL
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNuevaConexionSinDatabase() as Void
		return this.Conectar( this.ObtenerStringConnectSinDb())
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNuevaConexionSeguridadIntegrada() as String
		local lcConexion as String
		lcConexion =  this.ObtenerStringConnectSinDb()
		lcConexion = strtran( lcConexion, "Trusted_Connection=No", "Trusted_Connection=Yes" )
		return this.Conectar( lcConexion)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Conectar( tcStringConnect as String ) as Integer
		local lnHandler as Integer, lcStringConnect as String
		lnHandler = 0
		if empty( tcStringConnect )
			lcStringConnect = this.ObtenerStringConnect()
		else
			lcStringConnect = tcStringConnect 
		endif
		
		lnHandler = this.ObtenerIdConexion( lcStringConnect )
		
		if lnHandler > 0
			sqlexec( lnHandler , "SET LANGUAGE Español" )
				
			* Para la conexión se va a utilizar transacciones del tipo READ COMMITTED
			sqlexec( lnHandler , "SET TRANSACTION ISOLATION LEVEL READ COMMITTED" )
		endif

		return lnHandler
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdConexion( tcStringConnect as String ) as Integer
		local lnHandler as Integer, lnEstadoSQL as Integer, lcAviso as String, lcServidor as String, lcNuevaLinea as String, lcProblemaEnBaseDeDatos as String
		local array laError[ 1 ]
		lcNuevaLinea = chr( 13 ) + chr( 10 )
		lcAviso = ""
		lcProblemaEnBaseDeDatos = ""
		lnHandler = this.GetConnectionHandler( tcStringConnect )
		if lnHandler < 1
			this.oConexionSQL = _screen.zoo.crearObjeto( "ConexionMotorSQL","managerConexionASql.PRG" )
			lnHandler = this.oConexionSQL.ObtenerIdConexion( tcStringConnect )
			if lnHandler < 1
				lnEstadoSQL = this.oConexionSQL.VerificarAccesoAServidor( tcStringConnect )
				this.oProveedorStringConnection = null
				lcServidor = iif( empty( this.oConexionSQL.Servidor ), this.ObtenerNombreDelServidor(), this.oConexionSQL.Servidor )

				lcServidor = iif( empty( this.oConexionSQL.Servidor ), this.ObtenerNombreDelServidor(), addbs( this.oConexionSQL.Servidor ) + strtran( this.oConexionSQL.Instancia ,"MSSQL$", "" ) )
				lcAviso = "Ocurrió un error al intentar acceder a los datos." + lcNuevaLinea + lcNuevaLinea
				lcAviso = lcAviso + "Servidor: " + lcServidor + "." + lcNuevaLinea
				lcAviso = lcAviso + "Base de datos: " + this.oConexionSQL.BaseDeDatos + "." + lcNuevaLinea + lcNuevaLinea
				lcAviso = lcAviso + "Detalle: "

				do case
					case this.EsServidorNoVerificado()
						lcAviso = "El código de servidor no es correcto. Este equipo no ha sido habilitado para acceder al servidor " + lcServidor
*!*						case lnEstadoSQL = SERVIDORLOCALREINICIADO
*!*						case lnEstadoSQL = SERVIDORLOCALINICIADO
*!*						case lnEstadoSQL = SERVIDORREMOTOVALIDO
					case lnEstadoSQL = SERVIDORLOCALSININICIAR
						lcAviso = lcAviso + 'No está iniciado el servicio de SQL Server en el equipo local y el sistema no permite iniciarlo automáticamente. '
						lcAviso = lcAviso + 'Debe intentar manualmente con el siguiente procedimiento: Abra el Administrador de Tareas,'
						lcAviso = lcAviso + ' busque en la solapa Servicios el nombre ' + this.oConexionSQL.Instancia
						lcAviso = lcAviso + ', márquelo con el mouse, abra la lista de opciones con el boton derecho y ejecute Iniciar.'
					case lnEstadoSQL = SERVIDORREMOTOSINACCESO
						lcAviso = lcAviso + 'No está iniciado el servicio de SQL Server en el servidor remoto, el acceso esta bloqueado por un firewall o es incorrecta la '
						lcAviso = lcAviso + 'referencia a la instancia del servidor. Por favor comuníquese con el '
						lcAviso = lcAviso + 'administrador del sistema o corrija la referencia al servidor en el archivo DATACONFIG.INI ubicado en la carpeta de instalación del producto.'
						lcAviso = lcAviso + lcNuevaLinea + '(linea: SERVER=' + this.oConexionSQL.Servicio + ')'
					case lnEstadoSQL = SERVIDORLOCALINEXISTENTE
						lcAviso = lcAviso + 'No existe el servicio de SQL Server en el equipo local. '
						lcAviso = lcAviso + 'Por favor, verifique que la instancia ' + strtran( this.oConexionSQL.Instancia ,'MSSQL$','' )
						lcAviso = lcAviso + ' de SQL Server esté instalada o corrija la referencia al servidor en el archivo DATACONFIG.INI ubicado en la carpeta de instalación del producto.'
						lcAviso = lcAviso + lcNuevaLinea + '(linea: SERVER=' + this.oConexionSQL.Servicio + ')'
*!*						case lnEstadoSQL = SERVIDORREMOTOERROR
*!*							lcAviso = lcAviso + 'No se pudo conectar a la base de datos en el servidor ' + strtran( this.oConexionSQL.Instancia ,"MSSQL$", "" )
*!*							lcAviso = lcAviso + ' del equipo remoto ' + lcServidor + '.'
*!*							lcAviso = lcAviso + lcNuevaLinea + 'Error de acceso.'
*!*							lcAviso = lcAviso + 'Por favor comuníquese con el administrador del sistema.'
					otherwise
						lcProblemaEnBaseDeDatos = this.ObtenerProblemaEnBaseDeDatos( this.oConexionSQL.BaseDeDatos )
						if empty( lcProblemaEnBaseDeDatos )
							aerror( laError )
							if ( laError[ 1 ] == 1526 and type( "laError[ 3 ]" ) == "C" )
								lcAviso = lcAviso + laError[ 3 ]
							else
								lcAviso = lcAviso + "No existe información adicional sobre el error ocurrido."
							endif
						else
							lcAviso = lcAviso + lcProblemaEnBaseDeDatos
						endif
				endcase
				lcStringConnect = this.StringDeConexionConUsuarioYClave( tcStringConnect )
				
				if golibrerias.EsAutobuildDistribuido() and "Trusted_Connection=No" $ lcStringConnect and !( "Uid=" $ lcStringConnect )
					this.oProveedorStringConnection = null
					lcStringConnect =  this.ObtenerStringConnect()
					lcStringConnect = strtran( lcStringConnect, "Trusted_Connection=No", "Trusted_Connection=Yes" )
				endif 	
				
				lcAviso = lcAviso + lcNuevaLinea + lcNuevaLinea + "¿Desea intentar acceder a los datos nuevamente?" + lcNuevaLinea + lcNuevaLinea
				lcAviso = lcAviso + "ATENCIÓN: Si selecciona CANCELAR se procederá a cerrar la aplicación." + lcNuevaLinea
				lcAviso = lcAviso + "Si tiene procesos pendientes de grabación, los datos que no fueron guardados se perderán." 

				lnHandler = this.TryConnect( lcStringConnect, lcAviso )
			endif
			this.oConexionSQL = null
		endif
		return lnHandler
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsServidorNoVerificado() as Boolean
		local llRetorno as Boolean, lcPasswordAdministrativa as String, loError as Exception, lcCodigoDeServidor as String, loCredencialesSQLServer as Object
		llRetorno = .f.
		try
			*!* Se intenta obtener el código de servidor con la pwd administrativa para compararlo con el código de servidor almacenado en el DataConfig.ini
			lcPasswordAdministrativa = _screen.Zoo.InvocarMetodoEstatico( "ZooLogicSA.Core.BasesDeDatos.InfoUsuariosServidorSql", "ObtenerPasswordAdministrativa" )
			
			lcNombreProducto =  goServicios.Librerias.ObtenerDatosDeINI( addbs( _screen.zoo.app.crutadaTACONFIG )+"Dataconfig.ini", "SQL", "NombreProducto" )
			
			loCredencialesSQLServer = _screen.Zoo.CrearObjeto( "ZooLogicSA.Core.BasesDeDatos.CredencialesSqlServer", "", this.ObtenerNombreDelServidor(), lcPasswordAdministrativa, lcNombreProducto )
			if loCredencialesSQLServer.ServidorVerificado and !empty( loCredencialesSQLServer.CodigoDeServidor )
				lcCodigoDeServidor = upper( alltrim( goServicios.Librerias.ObtenerDatosDeINI( _screen.Zoo.App.aArchivosIni[ 2 ], "SQL", "CodigoDeServidor" ) ) )
				llRetorno  = !( lcCodigoDeServidor == loCredencialesSQLServer.CodigoDeServidor )
			endif
		catch to loError
		endtry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerProblemaEnBaseDeDatos( tcDB as String ) as String
		local lcRetorno as String, lnConexionAMaster as Integer, loGestorDeExcepciones as Object
		lcRetorno = ""
		try
			lnConexionAMaster = this.GetConnectionHandler( this.ObtenerStringConnectMaster() )
			if lnConexionAMaster > 0
				loGestorDeExcepciones = _screen.Zoo.CrearObjeto( "GestorDeExcepcionesSQLServer" )
				lcRetorno = loGestorDeExcepciones.ObtenerProblemaEnBaseDeDatos( tcDB, lnConexionAMaster )
			endif
		catch
			if lnConexionAMaster > 0
				sqldisconnect( lnConexionAMaster )
			endif
		endtry
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TryConnect( tcStringConnect as String, tcAviso as String ) as Integer
		local lnIntentos as Integer, lnRetorno as Integer, lnHandler as Integer, lcStringConnect as String
		lnIntentos = max( this.nReintentos, 1 )
		lcStringConnect = tcStringConnect
		do while .t.
			lnRetorno = 0
			lnHandler = this.GetConnectionHandler( lcStringConnect )
			if lnHandler > 0
				exit
			else
				if !this.lServicioFrenado
					this.FrenarServicios()
				endif
				if lnIntentos = 0
					if ( _Screen.Zoo.UsaCapaDePresentacion() or _screen.Zoo.DebeInformarErrores() ) and !_Screen.Zoo.EsModoSystemStartUp()
						lnRetorno = MessageBox( tcAviso, 5 + 48 + 256, goServicios.Mensajes.ObtenerTitulo() )
						if lnRetorno = 4
							lnIntentos = max( this.nReintentos, 1 )
							lcStringConnect = this.StringDeConexionConUsuarioYClave( tcStringConnect )
						else
							goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual() )
						endif
						this.oConexionSQL = null
					else
						goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual() )
					Endif
				endif
			endif

			lnIntentos = lnIntentos - 1			
		enddo
		if this.lServicioFrenado
			this.ReiniciarServicios()
		endif

		return lnHandler
	endfunc

	*-----------------------------------------------------------------------------------------
	function LoguearErrorSql() as Void
		local array laError[ 1 ]
		aerror( laError )
		try
			This.Loguear( "Error Número: " + transform( laError[ 1 ] ) )
			This.Loguear( "Error SQL: " + laError[ 2 ] )
			This.Loguear( "Error ODBC: " + laError[ 3 ] )
			This.Loguear( "Estado SQL: " + laError[ 4 ] )
			This.Loguear( "Código de Error SQL: " + transform( laError[ 5 ] ) )
			This.Finalizarlogueo()
		catch to loError
		Endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function ReiniciarServicios( ) as Void
		if type( "goServicios.Timer" ) = "O" and !isnull( goServicios.Timer )
			goServicios.Timer.EncenderTodosLosTimersFrenados()
		endif
		this.lServicioFrenado = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function FrenarServicios() as VOID	
		this.lServicioFrenado = .t.
		if type( "goServicios.Timer" ) = "O" and !isnull( goServicios.Timer )
			goServicios.Timer.FrenarTodosLosTimers()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GetConnectionHandler( tcStringConnect as String ) as Void
		local lnHandler as Integer
		sqlsetprop( 0,"DispLogin",3 )
		sqlsetprop( 0,"ConnectTimeOut",iif( this.nTimeOut < 5, 15, this.nTimeOut - 2 ))

		lnHandler = sqlstringconnect( tcStringConnect )

		return lnHandler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Reconectar() as integer
		return this.Conectar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarConexion() as Void
		if this.nHandler > 0 
			try
				if sqldisconnect( this.nHandler ) <= 0
					goServicios.Errores.LevantarExcepcion( "No se pudo cerrar la conexión." )
				endif
			catch to loError
				goServicios.Errores.LevantarExcepcion( "Error al intentar cerrar la conexión. " + loError.Message )
			endtry
			this.nHandler = 0
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		this.CerrarConexion()
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCadenaConexionNet( tcBase as String ) as string
		local lcBase as string, lcStringConnect as String
		
		if vartype( tcBase ) != "C" or empty( tcBase )
			lcBase = this.ObtenerNombreBaseDeDatos()
		else
			lcBase = goServicios.Librerias.ObtenerNombreSucursal( tcBase )
		endif
		lcStringConnect = this.oProveedorStringConnection.Obtener( "SQL", lcBase )
		return lcStringConnect
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCadenaConexionNetSinDB() as string
		local lcStringConnect as String
		lcStringConnect = this.oProveedorStringConnection.Obtener( "SQL" )
		return lcStringConnect
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function StringDeConexionConUsuarioYClave( tcStringConnect as String) as String
		local llRetorno as String, lcStringConnect as String, lcCadena as String
		llRetorno = ''
		if at('Uid=',tcStringConnect) > 0
			llRetorno = tcStringConnect
		else
			this.oProveedorStringConnection = null
			lcStringConnect = this.ObtenerStringConnect()
			for lnIndice = 1 to occurs( ';', lcStringConnect )
				lcCadena = strextract( lcStringConnect, ';', ';',lnIndice)
				if empty(lcCadena)
					lcCadena = strextract( lcStringConnect, ';', '',lnIndice)
				endif
				if !empty(lcCadena) and (left(lcCadena,4) = 'Uid=' or left(lcCadena,4) = 'Pwd=')
					tcStringConnect = tcStringConnect + ';' + lcCadena
				endif
			next
			llRetorno = tcStringConnect
		endif
		return llRetorno
	endfunc 

enddefine

***************************************************************************************************************************
* Clase para el manejo de la conexion al Motor SQL
***************************************************************************************************************************
define class ConexionMotorSQL as Session

	Servidor = ''
	Servicio = ''
	Instancia = ''
	Usuario = ''
	Clave = ''
	BaseDeDatos = ''
	Cadena = ''
	EsServidorLocal = null
	TienePermisoDeEjecucion = null
	VersionDeMotor = 0
	declare aListaErrores[1]

	*-----------------------------------------------------------------------------------------
	function ObtenerIdConexion( tcCadenaConexion as String ) as Integer
		local lnRetorno as Integer
		lnRetorno = sqlstringconnect( tcCadenaConexion )
		if lnRetorno <= 0
			aerror( this.aListaErrores )

		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDeCadena( tcCadenaConexion as String ) as Void
		local lcStringConnect as String
		this.Servicio = ''
		this.Servidor = ''
		this.Instancia = ''
		this.Usuario = ''
		this.Clave = ''
		this.BaseDeDatos = ''
		if vartype( tcCadenaConexion ) = 'C' and !empty( tcCadenaConexion )
			lcStringConnect = tcCadenaConexion
			for lnIndice = 1 to occurs( ';', lcStringConnect )
				lcCadena = strextract( lcStringConnect, ';', ';',lnIndice)
				if empty(lcCadena)
					lcCadena = strextract( lcStringConnect, ';', '',lnIndice)
				endif
				do case
				case !empty(lcCadena) and left(lcCadena,7) = 'Server='
					this.Servicio = substr(lcCadena,8) && lcCadena
					this.Servidor = upper( left( this.Servicio, at('\',this.Servicio)-1) )
					this.Instancia = "MSSQL$" + upper(substr( this.Servicio, at('\',this.Servicio)+1 ))
				case !empty(lcCadena) and left(lcCadena,4) = 'Uid='
					this.Usuario = substr(lcCadena,5) && lcCadena
				case !empty(lcCadena) and left(lcCadena,4) = 'Pwd='
					this.Clave = substr(lcCadena,5) && lcCadena
				case !empty(lcCadena) and left(lcCadena,9) = 'Database='
					this.BaseDeDatos = substr(lcCadena,10) && lcCadena
				endcase
			next
		else
			this.oProveedorStringConnection = null
			lcStringConnect = this.ObtenerStringConnect()
			for lnIndice = 1 to occurs( ';', lcStringConnect )
				lcCadena = strextract( lcStringConnect, ';', ';',lnIndice)
				if empty(lcCadena)
					lcCadena = strextract( lcStringConnect, ';', '',lnIndice)
				endif
				do case
				case !empty(lcCadena) and left(lcCadena,7) = 'Server='
					this.Servicio = lcCadena
					this.Servidor = upper( left( lcCadena, at('\',lcCadena)-1) )
					this.Instancia = "MSSQL$" + upper(substr( lcCadena, at('\',lcCadena)+1 ))
				case !empty(lcCadena) and left(lcCadena,4) = 'Uid='
					this.Usuario = lcCadena
				case !empty(lcCadena) and left(lcCadena,4) = 'Pwd='
					this.Clave = lcCadena
				case !empty(lcCadena) and left(lcCadena,9) = 'Database='
					this.BaseDeDatos = lcCadena
				endcase
			next
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsServidorLocal_access() as Variant
		if this.EsServidorLocal = null
			this.EsServidorLocal = this.EsMaquinaLocal( this.Servidor )
		endif
		return this.EsServidorLocal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TienePermisoDeEjecucion_access() as Variant
		if this.TienePermisoDeEjecucion = null
		endif
		return this.TienePermisoDeEjecucion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsMaquinaLocal( tcServidor ) as Boolean
		local lcNombreEquipo as String, llRetorno as Boolean
		llRetorno = .f.
		lcNombreEquipo = upper( left( sys(0), at('#',sys(0))-2) )
		llRetorno = inlist( upper( tcServidor ) , lcNombreEquipo, '.', 'LOCALHOST', '127.0.0.1' )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ServicioExistente( lcServiceName as String, lcMachineName as String ) as Boolean
		DECLARE INTEGER OpenSCManager IN advapi32.DLL ;
			STRING, STRING, INTEGER
		DECLARE INTEGER OpenService IN advapi32.DLL ;
			INTEGER, STRING, INTEGER

		local lnManager as Integer, lnService as Integer, llRetorno as Boolean
		lnManager = OpenSCManager(lcMachineName, NULL, GENERIC_READ)
		llRetorno = .f.
		IF (lnManager > 0)
			lnService = OpenService(lnManager, lcServiceName, GENERIC_READ)
			llRetorno = IIF(lnService > 0, .T.,.F.)
		ENDIF

		RETURN llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarAccesoAServidor( tcStringConnect as String ) as Integer
		local lnRetorno as Integer, loShell as Object , lcServicioSQL as String, lcServidorSQL as String, ;
				lcInstanciaSQL as String, lcNombreEquipo as String, lnIntentos as Integer, llInicio as Boolean, lnInicio as Integer
		lnRetorno = 0
		lcStringConnect = tcStringConnect

		this.ObtenerDatosDeCadena( lcStringConnect )
		if this.EsMaquinaLocal( this.Servidor )
			if this.ServicioExistente( this.Instancia, this.Servidor )
				loShell = CREATEOBJECT("Shell.Application")
				if loShell.IsServiceRunning( this.Instancia )
					lnRetorno = SERVIDORLOCALINICIADO
				else
					if loShell.CanStartStopService( this.Instancia )
						lnIntentos = 3
						llInicio = .f.
						do while !llInicio and lnIntentos > 0
							llInicio = loShell.ServiceStart( this.Instancia,.t.)
							lnIntentos = lnIntentos - 1
						enddo
						if llInicio = .t.
							lnRetorno = SERVIDORLOCALREINICIADO
						else
							lnRetorno = SERVIDORLOCALSININICIAR
						endif
					else
						lnRetorno = SERVIDORLOCALSININICIAR
					endif
				endif
				loShell = null
			else
				lnRetorno = SERVIDORLOCALINEXISTENTE
			endif
		else
			if this.ServicioRemotoExistente( lcStringConnect )
				lnHandleSQL = SQLSTRINGCONNECT( lcStringConnect )
				if lnHandleSQL > 0
					lnRetorno = SERVIDORREMOTOVALIDO
					sqldisconnect( lnHandleSQL )
				else
					lnRetorno = SERVIDORREMOTOERROR
				endif
			else
				lnRetorno = SERVIDORREMOTOSINACCESO
			endif
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ServicioRemotoExistente( tcStringConnect as String ) as Boolean
		local lcStringConnectServer as String, llRetorno as Boolean, lnHandleSQL as Integer
		llRetorno = .f.
		lcStringConnectServer = this.ObtenerCadenaAServidor(tcStringConnect)
		lnHandleSQL = this.ObtenerIdConexion( lcStringConnectServer )
		llRetorno = ( lnHandleSQL > 0 )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCadenaAServidor( tcCadenaConexion as String ) as String
		local lcStringConnect as String, lcRetorno as String, llSeguridadIntegrada as Boolean
		lcRetorno = ''
		if vartype( tcCadenaConexion ) = 'C' and !empty( tcCadenaConexion )
			lcStringConnect = tcCadenaConexion
			lcRetorno = left(lcStringConnect,at(';',lcStringConnect)-1)
			for lnIndice = 1 to occurs( ';', lcStringConnect )
				lcCadena = strextract( lcStringConnect, ';', ';',lnIndice)
				if empty(lcCadena)
					lcCadena = strextract( lcStringConnect, ';', '',lnIndice)
				endif
				llSeguridadIntegrada = .t.
				do case
				case !empty(lcCadena) and left(lcCadena,7) = 'Server='
					lcRetorno = lcRetorno + ';' + lcCadena
				case !empty(lcCadena) and left(lcCadena,19) = 'Trusted_Connection=' 
*!*						lcRetorno = lcRetorno + ';' + 'Trusted_Connection=Yes' 
*!*						lcRetorno = lcRetorno + ';' + lcCadena
				case !empty(lcCadena) and left(lcCadena,4) = 'Uid='
					lcRetorno = lcRetorno + ';' + lcCadena
					llSeguridadIntegrada = .f.
				case !empty(lcCadena) and left(lcCadena,4) = 'Pwd='
					lcRetorno = lcRetorno + ';' + lcCadena
				case !empty(lcCadena) and left(lcCadena,9) = 'Database='
				endcase
			next
			if llSeguridadIntegrada
				lcRetorno = lcRetorno + ';' + 'Trusted_Connection=Yes' 
			else
				lcRetorno = lcRetorno + ';' + 'Trusted_Connection=No' 
			endif
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUsuarioAdministrador() as Boolean
		local llRetorno as Boolean, lnManager as Integer
		declare Integer OpenSCManager in Advapi32.dll Integer,Integer,Integer
		declare Integer CloseServiceHandle in Advapi32.dll Integer
		lnManager = OpenSCManager(0,0,PERMISO_LECTURA+PERMISO_ESCRITURA+PERMISO_EJECUCION)
		if lnManager # 0
		    CloseServiceHandle(lnManager)
		endif
		llRetorno = (lnManager>0)
		return llRetorno
	endfunc 

enddefine
