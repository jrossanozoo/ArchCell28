define class ServicioDatos as Servicio of Servicio.prg
	
	#if .f.
		local this as ServicioDatos of ServicioDatos.prg
	#endif
	
	protected cClaseDatos, oFunciones, lCursorIgualATabla, _ListaDeBasesDeDatosParaSQL, oRegex
	
	cClaseDatos = "ZooDataLince"
	
	oAccesoDatos = null
	oManagerConexionASql = null
	nIdConexion = 0
	nTransaccionesActivas = 0
	lEjecuteRollback = .F.
	cSchemaFuncionesSQLServer = "funciones"
	cSchemaFuncionesNativa = "goLibrerias"
	cTipoDeBase = "NATIVA"
	lCursorIgualATabla = .f.
	oTraductor = null
	_ListaDeBasesDeDatosParaSQL = null
	oRegex = null
	oReemplazadorSentencias = null
	nTSPunto = 0
	nTimeStampA	= 0
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		
		with this
			.oAccesoDatos = .CrearObjeto( .cClaseDatos )
			.CrearManagerConexion()
			.CargarArrayDeFuncionesAReemplazarEnSqlServer()
			.InicializarReemplazadorSentencias()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InicializarReemplazadorSentencias() as Void
		this.oReemplazadorSentencias = _screen.DotNetBridge.CrearObjeto( "ZooLogicSA.ReemplazadorSentencias.ReemplazadorSentencia" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarArrayDeFuncionesAReemplazarEnSqlServer() as Void
		this.oFunciones = _screen.zoo.CrearObjeto( "zooColeccion" )
		this.oFunciones.agregar( "alltrim" )
		this.oFunciones.agregar( "ctot" )
		this.oFunciones.agregar( "datetime" )
		this.oFunciones.agregar( "dtos" )
		this.oFunciones.agregar( "empty" )
		this.oFunciones.agregar( "padl" )
		this.oFunciones.agregar( "padr" )
		this.oFunciones.agregar( "val" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Actualizar( tcSql as String, tcTablas as String  ) as Void
		local laConsultas, lnConsultas as Integer, i as Integer, loError as Exception, loEx as Exception,;
			  lcConsulta as String 	
		
		dimension laConsultas[1]
		lnConsultas = alines( laConsultas, tcSQL, 1, "|" )
		
		with this
			Try
				if .EsNativa()
					.oAccesoDatos.AbrirTablas( tcTablas )
				endif
				
				for i = 1 to lnConsultas
					lcConsulta = laConsultas[ i ]
					&lcConsulta
				endfor
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.oAccesoDatos.CerrarTablas( tcTablas )
			endtry 

		endwith
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	*jbarrionuevo # 08/04/10 17:06:23 No USAR esta funcion, usar EJECUTARSENTENCIAS
	function EjecutarScriptNativa( tcScript as String, tcTabla as String, tcCursor as string, tnSession as integer ) as Void
		local lnSession as integer, lnSessionAccesoDatos as integer, lcScript as String, loError as Object, lcCursor as String, ;
			loColAlias as zoocoleccion OF zoocoleccion.prg
			
			
		if empty( tcScript ) or isnull( tcScript )
			goServicios.Errores.LevantarExcepcion( "La sentencia que se pretende ejecutar está vacía o es nula." )
		endif
		with this
			lcCursor = tcCursor
						
			try	
				if !empty( tnSession )
					lnSession = .DataSessionId
					lnSessionAccesoDatos = .oAccesoDatos.DataSessionId
					.DataSessionId = tnSession
					.oAccesoDatos.DataSessionId = tnSession
				endif

				lcScript = tcScript
				loColAlias = .AbrirTablas( tcTabla, tcCursor )
				lcScript = .ReemplazarTablasPorAlias( loColAlias, lcScript )

				if this.lCursorIgualATabla
					lcCursor = sys(2015)
				endif
				
				if !empty( tcCursor )
					lcScript = lcScript + " into cursor " + lcCursor + " readwrite"
				endif
				execscript( lcScript )
				
				if this.lCursorIgualATabla
					lcScript = "select * from " + lcCursor + " into cursor " + tcCursor + " readwrite"
					execscript( lcScript )
				endif
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				if vartype( loColAlias ) = "O"
					.oAccesoDatos.CerrarTablas( .ObtenerAliasSeparadosPorComa( loColAlias ) )
				endif
				
				if this.lCursorIgualATabla
					use in select( lcCursor )
				endif
				
				if !empty( tnSession )
					.DataSessionId = lnSession
					.oAccesoDatos.DataSessionId = lnSessionAccesoDatos
				endif		
			endtry 
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Consultar( tcSql as String, tcTablas as String  ) as Void
		local lcCursor as String, lcXML as String, loError as Exception, lcConsulta as string

		with this
			try
				.oAccesoDatos.AbrirTablas( tcTablas )
				lcCursor = "c_" + sys(2015)
				lcConsulta =  tcSql + " into cursor " + lcCursor
				&lcConsulta
				lcXML = this.CursorAXml( lcCursor )
				use in ( lcCursor )	
			Catch To loError
				goServicios.errores.LevantarExcepcion( loError )
			finally
				.oAccesoDatos.CerrarTablas( tcTablas )			
			endtry
		endwith
		
		return lcXML

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		dodefault()
		this.oAccesoDatos = null 
		this.oManaGERCONEXIONASQL = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerSD() as String
		Local lcRetorno As String, lcRegistro As String, lnNumeroDisco As Integer

		Store "" To lcRetorno
		Store '46A3A-MP6H3-3697B-D4GYB-Q8HSY' To lcRegistro
		Store 0 To lnNumeroDisco

		try
			Declare String GetSerialNumber In "GDS.dll" Integer DriveNo, String RegCode
			lcRetorno = GetSerialNumber( lnNumeroDisco, lcRegistro )
		catch
			lcRetorno = ""
		endtry

		Return Upper( lcRetorno )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearManagerConexion() as Void
		this.oManagerConexionASql = _screen.zoo.crearobjeto( "ManagerConexionASql" )
		bindevent( this.oManagerConexionASql, "Destroy", this, "DestroyManagerConexion" )		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oManagerConexionASql_Access() as Void
		if !this.lDestroy and isnull( this.oManagerConexionASql )
			this.CrearManagerConexion()
		endif
		
		return this.oManagerConexionASql
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConectarMotorSQL() as Void
		this.nIdConexion = this.oManagerConexionASql.ObtenerConexion()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesconectarMotorSQL() as Void
		this.oManagerConexionASql.CerrarConexion()
		this.nIdConexion = 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerIdConexion() as Integer
		return this.nIdConexion
	endfunc 

	*-----------------------------------------------------------------------------------------
	*jbarrionuevo # 08/04/10 17:06:23 No USAR esta funcion, usar EJECUTARSENTENCIAS
	function EjecutarSQL( tcSql as String, tcCursor as string, tnSession as integer ) as String
		local lnOk as Integer, lcXml as String, loError as Exception , loInfo as zooinformacion of zooInformacion.prg, lcCursor as String, ;
			lnSession as Integer
			
		&& Casos de uso
		&& Si no tengo transacciones activas puedo reconectarme
		
		lcXml = ""
		try
			if !empty( tnSession )
				lnSession = this.DataSessionId
				this.DataSessionId = tnSession
			endif
			
			try	
				if empty( tcCursor )
					lcCursor = "c_" + sys(2015)
				else
					lcCursor = tcCursor 
				endif
				
				if this.nIdConexion = 0
					this.ConectarMotorSQL()
				endif
				
				if vartype( goServicios )=="O"
					goServicios.RealTime.EscucharAccesoADatos( tcSql ) 
				endif
				
				lnOk = This.EjecutarSentenciaSQlEspecifica( this.nIdConexion, tcSql , lcCursor )
				if lnOk <= 0
					lnOk = this.ReconectarMotorSQL() && Si Hay Transacciones activas devuelve -1 y no Reconecta
					if lnOk > 0
						lnOk = This.EjecutarSentenciaSQlEspecifica( this.nIdConexion, tcSql , lcCursor )
					endif
				endif
				
			catch To loError
				goServicios.Errores.LevantarExcepcion( loError ) 
			endtry

			if lnOk <= 0
				this.LevantarExcepcionErrorSql( tcSql )
			endif

			if empty( tcCursor )
				if used( lcCursor )
					lcXml = this.cursoraxml( lcCursor )
					use in select( lcCursor )
				endif
			endif
		catch to loError
			use in select( lcCursor )
			goServicios.Errores.LevantarExcepcion( loError ) 
		finally
			if !empty( tnSession )
				this.DataSessionId = lnSession
			endif		
		endtry
		
		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarExcepcionErrorSql( tcSql as String ) as String
		local loGestorDeExcepciones as Object
		local array laError[ 1 ]
		aerror( laError )
		loGestorDeExcepciones = _screen.Zoo.CrearObjeto( "GestorDeExcepcionesSQLServer" )
		loGestorDeExcepciones.LevantarExcepcion( tcSql, @laError )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EjecutarSentenciaSQlEspecifica( tnHandle as Integer, tcSql as String, tcCursor as String ) as Integer
		local lnRetorno as Integer
		lnRetorno = 1
		
		do Case
			case upper( alltrim( tcSql ) ) == "BEGIN TRANSACTION"
				lnRetorno = sqlexec( tnHandle, tcSql , tcCursor )
				if lnRetorno > 0
					This.nTransaccionesActivas = This.nTransaccionesActivas + 1
				endif
			case upper( alltrim( tcSql ) ) == "COMMIT TRANSACTION"
				if This.HayTransaccionesActivas()
					lnRetorno = sqlexec( tnHandle, tcSql , tcCursor )
					if lnRetorno > 0
						This.nTransaccionesActivas = This.nTransaccionesActivas - 1 
						try
							if goregistry.nucleo.EjecutarCheckPointAlHacerCommitTransaction
								sqlexec( tnHandle, "CHECKPOINT" )
							Endif	
						catch to loError
						endtry
					endif
					
				else
					goServicios.Errores.LevantarExcepcion( "No se puede ejecutar el COMMIT TRANSACTION, no hay transacciones activas" )
				EndIf
			case upper( alltrim( tcSql ) ) == "ROLLBACK TRANSACTION"
				if This.HayTransaccionesActivas()
					This.nTransaccionesActivas = This.nTransaccionesActivas - 1 
					If sqlexec( tnHandle, tcSql , tcCursor ) > 0
					else 
						&& Si Pincha el rollback la conexion no es segura
						This.DesconectarMotorSQL()
						This.ConectarMotorSQL()
					endif
				else
					This.DesconectarMotorSQL()
					This.ConectarMotorSQL()
					&& Nos desconectamos, porque por algun motivo pincho algun begin transaction y se van a ejecutar mas rollbacks de los que correspondan.
					&& Ademas esa conexion es muy problable que este rota
				Endif				
			otherwise
			lnRetorno = sqlexec( tnHandle, tcSql , tcCursor )
			if lnRetorno = -1
				this.AnalizarError()
			endif
			
		if !empty( tcCursor ) and used( tcCursor ) 
			select * from ( tcCursor ) into cursor ( tcCursor ) readwrite
		endif 

			
		EndCase
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AnalizarError() as Void
		local lnCantErrores as Integer
		local array laErrors[1]

		lnCantErrores = aerror( laErrors )
		if lnCantErrores > 0
			if this.EsErrorDeConexion( laErrors[ 1, 5 ], laErrors[ 1, 3 ], laErrors[ 1, 2 ] )
				this.DesconectarMotorSql()
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsErrorDeConexion( tnError as Integer, tcODBC_Error as String, tcMensaje as String ) as Boolean
		return tnError = 233 or "communication link failure" $ lower( tcODBC_Error )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReconectarMotorSQL() as Integer
		local lnHandle as Integer
		lnHandle = -1

		if this.nIdConexion > 0 or This.HayTransaccionesActivas()
		Else
			this.oManagerConexionASql.nHandler = 0
			this.nIdConexion = this.oManagerConexionASql.Reconectar()
			
			if this.nIdConexion > 0
				lnHandle = this.nIdConexion
			endif
		EndIf	
		return lnHandle	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HayTransaccionesActivas() as Boolean
		return This.nTransaccionesActivas > 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DestroyManagerConexion() as Void
		this.nIdConexion = 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsSqlServer() as boolean
		local llRetorno as Boolean
		
		if pemstatus( _screen, "zoo", 5 ) and vartype( _screen.zoo ) == "O" and ;
			pemstatus( _screen.zoo, "app", 5 ) and vartype( _screen.zoo.app ) == "O"
			llRetorno = ( upper( alltrim( _screen.zoo.app.TipoDeBase )) = "SQLSERVER" )
		else
			llRetorno = ( upper( alltrim( this.cTipoDeBase )) = "SQLSERVER" )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsNativa() as boolean
		local llRetorno as Boolean
		
		if pemstatus( _screen, "zoo", 5 ) and vartype( _screen.zoo ) == "O" and ;
			pemstatus( _screen.zoo, "app", 5 ) and vartype( _screen.zoo.app ) == "O"		
			llRetorno = ( upper( alltrim( _screen.zoo.app.TipoDeBase )) = "NATIVA" )
		else
			llRetorno = ( upper( alltrim( this.cTipoDeBase )) = "NATIVA" )
		endif		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSchemaSeguridad() as String
		local lcRetorno as String
		
		if this.EsSqlServer()
			lcRetorno = "seguridad."
		else
			lcRetorno = ""
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSchemaFunciones() as String
		local lcRetorno as String
		
		if this.EsSqlServer()
			lcRetorno = this.cSchemaFuncionesSQLServer
		else
			lcRetorno = this.cSchemaFuncionesNativa
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFuncion( tcFuncion as String, lEsFuncionLocal as Boolean ) as String
		local lcRetorno as String
		
		do case
			case this.EsSqlServer()
				lcRetorno = this.ObtenerSchemaFunciones() + "." + tcFuncion
			case lEsFuncionLocal
				lcRetorno = "goDatos.f" + tcFuncion
			otherwise 
				lcRetorno = tcFuncion
		endcase
		
		return lcRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEsIgual() as String
		local lcRetorno as String
		
		if this.EsSqlServer()
			lcRetorno = this.ObtenerSchemaFunciones() + ".EsIgual"
		else
			lcRetorno = "goDatos.fEsIgual" 
		endif
		
		return lcRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function fEsIgual( txValorAEvaluar as Variant, txValorEsperado as Variant ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = ( txValorAEvaluar = txValorEsperado )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function fEntre( txValorAEvaluar as Variant, txRangoDesde as Variant, txRangoHasta as Variant ) as Int
		local lnRetorno as Integer
		
		lnRetorno = iif( between( txValorAEvaluar, txRangoDesde, txRangoHasta ), 1 , 0 )
		
		return lnRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerSchemaSucursal() as String
		local lcRetorno as String
		
		if this.EsSqlServer()
			lcRetorno = _screen.zoo.app.cSucursalActiva + "."
		else
			lcRetorno = ""
		endif
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarCantidadDeParametrosDeEjecutarSentencias( tnCantidadParametros ) as Void
		if tnCantidadParametros < 2
			goServicios.Errores.LevantarExcepcion( "Se debe indicar las tablas sobre las cuales se realiza la ejecución de sentencias." )
		else
			if tnCantidadParametros = 4
				goServicios.Errores.LevantarExcepcion( "Se debe indicar la datasession en la que se desea crear el cursor." )
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarSentencias( tcSentencia as String, tcTablas as string, tcRuta as String, tcCursor as String, tnSesion as Integer ) as Void
		this.ValidarCantidadDeParametrosDeEjecutarSentencias( pcount() )
		this.ValidarPermiteModificarOEliminarEnBase( tcSentencia, tcTablas )
		
		local lcNuevaCadenaSql as String, lcTablasConRuta as String

		lcNuevaCadenaSql = strtran( tcSentencia, "<<ESQUEMA>>.", "", 1, -1, 1 )
		lcNuevaCadenaSql = this.oTraductor.Traducir( lcNuevaCadenaSql )
		
		do case
			case This.EsSqlServer()
				lcNuevaCadenaSql = this.AgregarEsquemas( lcNuevaCadenaSql, tcTablas )
				lcNuevaCadenaSql = this.ReemplazarSintaxisDeNativa( lcNuevaCadenaSql )
				lcNuevaCadenaSql = this.EnvolverBaseDeDatosEntreCorchetes( lcNuevaCadenaSql )
				this.EjecutarSQL( lcNuevaCadenaSql, tcCursor, tnSesion )
			case This.EsNativa()
				lcTablasConRuta = this.AgregarRutaALasTablas( tcRuta, tcTablas )
				this.EjecutarScriptNativa( lcNuevaCadenaSql, lcTablasConRuta, tcCursor, tnSesion )
			otherwise
				goServicios.Errores.LevantarExcepcion( "El tipo de base de datos especificada para la aplicación, es incorrecta." )
		endcase
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarPermiteModificarOEliminarEnBase( tcSentencia as String, tcTablas as String ) as Void
		if !_screen.zoo.app.PermiteModificarOEliminarEnBase( tcSentencia, tcTablas )
			local loErrorAccesoDatos as zooexception of ZooException.prg
			loErrorAccesoDatos = Newobject( 'ZooException', 'ZooException.prg' )
			loErrorAccesoDatos.oInformacion.agregarInformacion( "Tablas: " + transform( tcTablas ) )
			loErrorAccesoDatos.oInformacion.agregarInformacion( "Sentencia: " + transform( tcSentencia ) )
			loErrorAccesoDatos.oInformacion.agregarInformacion( "No está permitido modificar registros en una base de datos de réplica." )
			
			loErrorAccesoDatos.nZooErrorNo = 403
			loErrorAccesoDatos.ErrorNo = loErrorAccesoDatos.nZooErrorNo
			goServicios.Errores.LevantarExcepcion( loErrorAccesoDatos )
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function EnvolverBaseDeDatosEntreCorchetes( tcCadenaSQl as String ) as String
		local lcRetorno as String, loBasesDeDatos as zoocoleccion OF zoocoleccion.prg, lcRetorno as String, ;
			lcItemBase as String
	
		lcRetorno = tcCadenaSQl
		loBasesDeDatos = this.ObtenerListaDeBasesDeDatosParaSQL()
		if ( !isnull( loBasesDeDatos ) )
			if isnull( this.oRegex )
				this.oRegex = _Screen.zoo.crearobjeto( "ZooLogicSA.Core.DBConnection.HelperExpresionesRegulares" )
			endif
			lcRetorno = tcCadenaSQl
			for each lcItemBase in loBasesDeDatos foxObject
				lcRetorno = this.oRegex.Reemplazar( lcRetorno , " " + lcItemBase + "\.", " [" + lcItemBase + "].", .t. ) && Parametro 1 es IGNORE_CASE
			endfor
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDeBasesDeDatosParaSQL() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, i as Integer, laSucursalas as Object, ;
			lnCantidad as Integer
			
		loRetorno = null
		if !empty( _Screen.zoo.app.aSucursales )

			lnCantidad = alen( _Screen.zoo.app.aSucursales, 1 )
			if isnull( this._ListaDeBasesDeDatosParaSQL ) or lnCantidad != this._ListaDeBasesDeDatosParaSQL.Count			
				loRetorno = _Screen.zoo.crearobjeto( "zoocoleccion" )
				for i = 1 to lnCantidad
					loRetorno.Agregar( alltrim( _screen.zoo.app.NombreProducto ) + "_" + alltrim( _Screen.zoo.app.aSucursales[i,1] ) )
				endfor
				this._ListaDeBasesDeDatosParaSQL = loRetorno
			else
				loRetorno = this._ListaDeBasesDeDatosParaSQL
			endif
		endif
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oTraductor_Access() as object
		if !this.ldestroy and !vartype( this.oTraductor ) = 'O' and isnull( this.oTraductor )
			this.AgregarReferencia( "ZooLogicSA.TraductorSentencias.dll")
			do case
				case this.EsSqlServer()
					this.oTraductor = this.CrearObjeto( "ZooLogicSA.TraductorSentencias.TraductorSentenciasSqlServer" )
				case this.EsNativa()
					this.oTraductor = this.CrearObjeto( "ZooLogicSA.TraductorSentencias.TraductorSentenciasNativa" )
				otherwise
					goServicios.Errores.LevantarExcepcion( "El tipo de base de datos especificada para la aplicación, es incorrecta." )
			endcase
		endif
		
		return this.oTraductor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarRutaALasTablas( tcRuta as string, tcTablas as string ) as string
		local lcRetorno as string, lnTablas  as Integer, i as Integer, lcTabla as String
		local array laTablas[1]
		
		lcRetorno = ""
		lnTablas = alines( laTablas, tcTablas, 1 + 4, "," )
		for i = 1 to lnTablas
			lcTabla = juststem( laTablas[ i ] )
			lcRetorno = lcRetorno + ", " + this.ObtenerRutaSegunUbicacion( tcRuta, lcTabla ) + laTablas[ i ]
		endfor
		
		return substr( lcRetorno, 3 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaSegunUbicacion( tcRuta as string, tcTabla as String ) as String
		local lcUbicacion as String, lcRetorno as String
		

			lcUbicacion = goServicios.Estructura.ObtenerUbicacion( tcTabla )
			lcRetorno = ""
			do case 
				case lcUbicacion = "SUCURSAL" or empty( lcUbicacion )
					if empty( tcRuta )
						lcRetorno = addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) + "dbf\" 
					else
						lcRetorno = addbs( tcRuta )
					endif
				case lcUbicacion = "PUESTO"
					lcRetorno = _screen.zoo.app.cRutaTablasPuesto
					
				case lcUbicacion = "ORGANIZACION"
					lcRetorno = _screen.zoo.app.cRutaTablasOrganizacion
					
				case lcUbicacion = "SEGURIDAD"
					lcRetorno = _screen.zoo.app.cRutaTablasSeguridad					
			endcase			
			
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarEsquemas( tcSentencia as string, tcTablas as string ) as string
		local lcRetorno as String, lnTablas  as Integer, i as Integer
		local array laTablas[1]

		lnTablas = alines( laTablas, tcTablas, 1 + 4, "," )
		lcRetorno = tcSentencia
		for i = 1 to lnTablas
			lcRetorno = this.AgregarEsquemaALaTabla( lcRetorno, laTablas[ i ] )
		endfor

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarEsquemaALaTabla( tcSentencia as string, tcTabla as string ) as string
		local lcTabla as string, lcEsquema as string

		lcTabla = juststem( tcTabla )
		lcEsquema = alltrim( goServicios.Estructura.ObtenerEsquema( lcTabla ) )

		return this.ReemplazarEnSentencia( tcSentencia, lcTabla, lcEsquema + "." + lcTabla )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarEnSentencia( tcSentencia as String, tcTabla as string, tcReemplazo as String ) as String
		local lcSentencia, loError as Exception, lnIntentos as Integer
		lcSentencia = ""
		lnIntentos = 0
		do while lnIntentos<2
			try 
				lcSentencia = this.oReemplazadorSentencias.Reemplazar( tcSentencia, tcTabla, tcReemplazo )
				lnIntentos = 3
			catch to loError when "80131014" $ loError.Message
				try
					this.InicializarReemplazadorSentencias()
				catch
					this.ReiniciarDotNetBridge()
				endtry 
				lnIntentos = lnIntentos + 1
			endtry
		enddo
		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReiniciarDotNetBridge()
		if pemstatus(_screen.zoo,"app",5) and !isnull(_screen.zoo.app) and vartype(_screen.zoo.app) = "O"
			_screen.DotNetBridge = null
			clear dlls "ClrCreateInstanceFrom"
			_screen.zoo.app.InstanciarWWDotNetBridge()
			_screen.zoo.app.AgregarReferencias()
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarSintaxisDeNativa( tcSql as String ) as String
		local lcSql as String, lcEsquemaFunciones as String, lcItem as Integer, lnPos as Integer, ;
			lcPosWhere as Integer, lnPosPriParentesis as Integer, lnPosUltParentesis as Integer
		
		lcSql = tcSql
		lcSql = this.ObtenerReemplazoSintaxisBooleanos( lcSql, ".t.", "1" )
		lcSql = this.ObtenerReemplazoSintaxisBooleanos( lcSql, ".f.", "0" )
		lcSql = strtran( lcSql, " == ", " = ", 1, -1, 1  )
        lcSql = strtran( lcSql, " == ", " = ", 1, -1, 1  )
        lcSql = strtran( lcSql, " date(", " getdate(", 1, -1, 1  )
        lcSql = strtran( lcSql, " goServicios.Librerias.ObtenerGuidPK", " newid", 1, -1, 1  )
        lcSql = strtran( lcSql, " golibrerias.ObtenerGuidPK", " newid", 1, -1, 1  )
		lcSql = strtran( lcSql, " goServicios.Librerias.", " funciones.", 1, -1, 1  )
		lcSql = strtran( lcSql, " golibrerias.", " funciones.", 1, -1, 1  )
		for each lcItem in this.oFunciones foxObject
			lcItem = lower( alltrim( lcItem ) )
			lcSql = strtran( lcSql, " " + lcItem + "(", " " + ;
				alltrim( this.cSchemaFuncionesSQLServer ) + "." + lcItem + "(", 1, -1, 1  )
		endfor
		lcPosWhere = at( "where ", lower( lcSql ) )
		do while rat( "isnull", lower( lcSql ) ) > 0 and rat( "isnull", lower( lcSql ) ) > lcPosWhere
			lnPosPriParentesis = at( "(", substr( lcSql, rat( "isnull", lower( lcSql ) ) ) )
			lnPosUltParentesis = at( ")", substr( lcSql, rat( "isnull", lower( lcSql ) ) ) )
			lcSql = substr( lcSql, 1 , rat( "isnull", lower( lcSql ) ) - 1 ) + ;
					" (" + substr( lcSql, rat( "isnull", lower( lcSql ) ) + lnPosPriParentesis, lnPosUltParentesis - lnPosPriParentesis - 1 ) + ;
					") is null " + substr( lcSql, rat( "isnull", lower( lcSql ) ) + lnPosUltParentesis )
		enddo
		
		return lcSql
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerReemplazoSintaxisBooleanos( tcSql as String, tcBuscado as String, tcReemplazo as String ) as String
		local lcRetorno as String, lnPosicion as Integer, lnCant as Integer, lnI as Integer
		
		lcRetorno = tcSql
		lnCant = occurs( lower( tcBuscado ), lower( lcRetorno ) )
		lnOrden = 1
		if lnCant > 0
			for lnI  = lnCant to 1 step -1
				lnPosicion = atc( tcBuscado, lcRetorno, lnI )
				*if substr( lcRetorno, lnPosicion - 1, 1 ) != "'" && significa que no es string
				if !this.EsString( lcRetorno, lnPosicion )
					*if this.VerificarBooleanoEnConsulta( lcRetorno, lnPosicion )
						lcRetorno = strtran( lcRetorno, tcBuscado, tcReemplazo, lnI, 1, 1 )
					*else
					*	lnOrden = lnOrden + 1
					*endif
				endif
			endfor
		endif
		
		return lcRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EsString( tcRetorno, tnPosicion ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		tcRetorno = left( tcRetorno, tnPosicion )
		lnCantComillas = occurs( "'", tcRetorno )
		if mod( lnCantComillas, 2 ) != 0
			llRetorno = .t.
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEsquema( tcTabla as String ) as String
		return goServicios.Estructura.ObtenerEsquema( tcTabla )
	endfunc 
    
    *-----------------------------------------------------------------------------------------
    function ObtenerFechaFormateada( tdFecha as Date ) as String
        local lcRetorno as String
        
        if This.EsSqlServer()
        	if empty( tdFecha )
        		tdFecha = {01/01/1900}
        	endif
        	do case
        		case year(tdFecha) <= 10
        			tdFecha = date(year(tdFecha)+2000,month(tdFecha),day(tdFecha))
        		case year(tdFecha) <= 99
	        		tdFecha = date(year(tdFecha)+1900,month(tdFecha),day(tdFecha))
	        	case year(tdFecha) <= 1000
        			tdFecha = date(year(tdFecha)+1000,month(tdFecha),day(tdFecha))
        	endcase
        	if year(tdFecha) < 1753
        		tdFecha = date(year(tdFecha)+1753,month(tdFecha),day(tdFecha))
        	endif
	        lcRetorno = " Convert(DateTime, '" + dtos( tdFecha ) + "') " 	        
        else
            lcRetorno = "{" + dtoc( tdFecha ) + "}" 
        endif
    
        return lcRetorno
    endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirTablas( tcTablas as String, tcCursor as String ) as zoocoleccion OF zoocoleccion.prg
		local loColAlias as zoocoleccion OF zoocoleccion.prg, i as Integer, llRetorno  As Boolean, lnTotalTablas As Integer, ;
			lcSoloTabla as String, lcTabla as string, lcAlias as string

		&& se cambio por performance
		loColAlias = NewObject( "Collection" )
		
		lnTotalTablas = getwordcount( tcTablas, "," )
		
		if empty( tcCursor )
			tcCursor = ""
		endif
		
		For i = 1 to lnTotalTablas
			lcTabla = alltrim( getwordnum( tcTablas, i, "," ) )
			lcSoloTabla = juststem( lcTabla )
			this.lCursorIgualATabla = ( alltrim( upper( lcSoloTabla )) == alltrim( upper( tcCursor )))
			lcAlias = ""
			if !used( lcTabla )
				lcAlias = lcSoloTabla + sys( 2015 )
			endif
			llRetorno = this.oAccesoDatos.AbreTabla( lcTabla, lcAlias )
			if !llRetorno
				this.oAccesoDatos.CerrarTablas( this.ObtenerAliasSeparadosPorComa( loColAlias ) )
				goServicios.Errores.LevantarExcepcion( "No se pudo realizar la apertura de la tabla. (" + lcTabla + ")" )
			endif
			loColAlias.Add( lcAlias, lcSoloTabla )
		endfor
		
		return loColAlias
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarTablasPorAlias( toColAlias as zoocoleccion OF zoocoleccion.prg, tcScript as String ) as String
		local i as Integer
		
		for i = 1 to toColAlias.count
				tcScript = this.ReemplazarEnSentencia( tcScript, toColAlias.GetKey( i ), toColAlias.Item[ i ] )
		endfor
		
		return tcScript
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAliasSeparadosPorComa( toColAlias as zoocoleccion OF zoocoleccion.prg ) as String
		local lcRetorno as String, lcAlias as String
		
		lcRetorno = ""
		for each lcAlias in toColAlias foxobject
			if !empty( lcAlias )
				lcRetorno = lcRetorno + "," + lcAlias
			endif
		endfor
		
		return substr( lcRetorno, 2 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaEnEntidad( toEntidad as String, tcCodigoABuscar as String, toEntidadParaAlmacenarLaInformacion as entidad OF entidad.prg ) as Boolean
		local llRetono as Boolean, loError as zooexception OF zooexception.prg, lcAtributoPK as String
		llRetono = .f.
		try
			lcAtributoPK = toEntidad.ObtenerAtributoClavePrimaria()
			toEntidad.&lcAtributoPK. = tcCodigoABuscar
			llRetono = .t.
		catch to loError
			if Vartype( loError.UserValue ) = "O" and vartype( loError.UserValue.oInformacion ) = "O" and loError.UserValue.oInformacion.Count > 0 and ;
				"EL DATO BUSCADO " + alltrim( tcCodigoABuscar ) + " DE LA ENTIDAD " $ upper( alltrim( loError.UserValue.oInformacion.Item[ 1 ].cMensaje ) )
				if pcount() >= 3 and vartype( toEntidadParaAlmacenarLaInformacion ) == "O"
					toEntidadParaAlmacenarLaInformacion.AgregarInformacion( loError.UserValue.oInformacion.Item[ 1 ].cMensaje )
				endif
			else
				goServicios.Errores.LevantarExcepcion( loError )
			endif
		endtry
		
		return llRetono
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTimestamp() as Integer 	
		local lnLatencia as Integer, lnMilisengundosdesde00 as Integer, lnMilisegundosdesde19950101 as Integer, lnSegundos  as Integer 
		
		&& como esta la funcion en le motor - pzubizarreta 17/02/2017
		&& floor(cast((DATEDIFF(ss, '19950101', GETDATE())) as numeric(14,0)) * 1000 +  cast( DATEDIFF(ms, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())), GETDATE()) as numeric(14,0)) / 100)

		lnMilisegundosdesde19950101 = int( ctot( dtoc( date() ) + " " + time() ) - datetime( 1995,1,1,0,0,0 ) )* 1000
		lnSegundos = seconds()
		lnMilisengundosdesde00 = int( lnSegundos * 1000 )

		lnLatencia = 3*60*1000 && 3 min en unidades de la formula del timestampa
		
		if abs(lnMilisengundosdesde00-this.nTSPunto)>lnLatencia
			this.nTimeStampA = 0
			this.nTSPunto = lnMilisengundosdesde00
			try 
				this.EjecutarSentenciaSQlEspecifica( this.nIdConexion, "select [Funciones].[ObtenerTimeStamp]() as timestampa", "temptimestampa" )
				select ("temptimestampa")
				this.nTimeStampA = timestampa
				use in select("temptimestampa")
			catch 
				&& en caso que el motor de base de datos no funcione
			endtry 

			if this.nTimeStampA = 0
				this.nTimeStampA = lnMilisegundosdesde19950101 + lnMilisengundosdesde00
			endif

		endif 
		
		return this.nTimeStampA + abs( lnMilisengundosdesde00-this.nTSPunto )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarBooleanoEnConsulta( tcSql as String, tcPosicion as Number) as Boolean
		local lcRetorno as String, lnPosicionIgual as Number, lnPosicionComilla as Number, lcEntreIgualYBooleano  as String
		lcRetorno = .t.
		lnPosicionIgual = ratc( "=", substr( tcSql, 1, tcPosicion ) , 1 )
		if lnPosicionIgual > 0 
			lcEntreIgualYBooleano = substr( tcSql, lnPosicionIgual, tcPosicion - lnPosicionIgual )
			lnPosicionComilla = atc( "'", lcEntreIgualYBooleano , 1 ) 
			if lnPosicionComilla > 0 
				lcRetorno = .f. 
			endif
		endif		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreBD( tcBD as String ) as String
		return this.ObtenerPrefijoDeBaseDeDatos( tcBD ) + alltrim( tcBD )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPrefijoDeBaseDeDatos( tcBD as String ) as String
		local lcRetorno as String, lcUbicacion as String, loMapeadorADN as Object, loEstructura as Object, i as Integer, loDatosPorDefecto as Object, loBD as Object
		lcUbicacion = addbs( _screen.Zoo.cRutaInicial ) + "Generados"
        loMapeadorADN = _screen.Zoo.CrearObjeto( "ZooLogicSA.Core.ADN.Estructuras.MapeadorEstructuraAdn" )
        loEstructura = loMapeadorADN.Mapear( lcUbicacion )
        lcRetorno = loEstructura.DatosEstructuraPorDefecto.PrefijoBD + "_"
        for i = 0 to loEstructura.DatosEstructuraPorDefecto.BasesDeDatosPorDefecto.Count - 1
        	loDatosPorDefecto = loEstructura.DatosEstructuraPorDefecto
        	loBD = loDatosPorDefecto.BasesDeDatosPorDefecto.Item[ i ]
			if ( upper( alltrim( loBD.Nombre ) ) == upper( alltrim( tcBD ) ) )
				if ( !loBD.LlevaPrefijo )
					lcRetorno = ""
					exit
				endif
			endif
      	endfor
      	return lcRetorno
      endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarConexionADBEspecifica( tcDB as String ) as Void
		return this.oManagerConexionASql.VerificarConexionADBEspecifica( tcDB )
	endfunc

enddefine
