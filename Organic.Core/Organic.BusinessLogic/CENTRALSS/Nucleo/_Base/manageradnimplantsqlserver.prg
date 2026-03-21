define class ManagerAdnImplantSQLSERVER as ManagerAdnImplant of ManagerAdnImplant.prg
	
	#IF .f.
		Local this as ManagerAdnImplantSQLSERVER of ManagerAdnImplantSQLSERVER.prg
	#ENDIF

	oEjecutadorFixes = null
	lTienePermisosDeAdmin = .f.
	GestorPermisos = null
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		local loFactoryNet as Object
		dodefault()
		loFactoryNet = _Screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.InterfazVisual.FactoryOrganic", "ZooLogicSA.AdnImplant.InterfazVisual" )
		
		this.GestorPermisos = loFactoryNet.ObtenerGestorDePermisos()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarBaseDeDatos() as Boolean
		local llRetorno as Boolean, lnValor as Integer, llExisteInstanciaSqlServer as Boolean, loPermisos  as Object,;
			llPermisoConectarBD as Boolean
		llRetorno = .t.
		lnValor = 0
		llPermisoConectarBD = .f.

		this.Iniciarprogreso( "Validando base de datos " + alltrim( this.cBaseDeDatosEnProceso ) + "...", 4, "Chequeando base de datos " + alltrim( this.cBaseDeDatosEnProceso ) + "...", "" )

		loPermisos = this.GestorPermisos.ObtenerPermisosServer()
		llExisteInstanciaSqlServer = loPermisos.ConectarServidor

		if llExisteInstanciaSqlServer
			this.ObtenerPermisosDeServidor()
			loPermisos = this.GestorPermisos.ObtenerPermisosDB( goServicios.Librerias.ObtenerNombreSucursal( this.cBaseDeDatosEnProceso ) )
			llPermisoConectarBD = loPermisos.ConectarBaseDeDatos
		endif
		
*inkey(6)
		
		if llExisteInstanciaSqlServer and llPermisoConectarBD
			this.Notificar( "Base de datos " + alltrim( this.cBaseDeDatosEnProceso ) + " existente...", "" )
		else
			do case
				case !llExisteInstanciaSqlServer
					goMensajes.Alertar( "ATENCIÓN: No se pudo conectar al servidor " + _Screen.Zoo.App.cNombreDelServidorSQL ) 
				case this.lPreguntar
					this.Notificar( "ATENCIÓN: No se ha encontrado la Base de datos " + alltrim( this.cBaseDeDatosEnProceso ), "" )
					lnValor = goMensajes.Advertir( "ATENCIÓN: No se ha encontrado la Base de datos " + alltrim( this.cBaseDeDatosEnProceso ) + "." ;
						+ chr( 13 ) + chr( 10 ) + "Presione Aceptar para continuar o Cancelar para salir del sistema.", 1, 1 ) 				
				otherwise 
					this.notificar( "ATENCIÓN: No se ha encontrado la Base de datos " + alltrim( this.cBaseDeDatosEnProceso ), "" )
					lnValor = 1
			endcase
			if lnValor = 1
				if this.lTienePermisosDeAdmin
					this.Notificar( "Creando base de datos " + alltrim( this.cBaseDeDatosEnProceso ) + "...", "" )
					this.EjecutarScriptCrearDB( this.cBaseDeDatosEnProceso )
					this.ModificarTamañoBaseDeDatos( this.cBaseDeDatosEnProceso )
				else
					this.Notificar( "Su usuario no posee los permisos necesarios para realizar cambios.", "" )
					llRetorno = .f.
				endif
			else
				this.Notificar( "No se creó la base de datos " + alltrim( this.cBaseDeDatosEnProceso ), "" )
				llRetorno = .f.
			endif
		endif
					
		if llRetorno and this.lTienePermisosDeAdmin
			this.Notificar( "Configurando base de datos " + alltrim( this.cBaseDeDatosEnProceso ) + "...", "" )
			this.CrearYPrepararBDSQL()
		endif
		
		this.Notificar( "Validación finalizada...", "" )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HayQueEjecutarDatosBasicos( tcUbicacion as String ) as Void
		this.lEjecutarDatosBasicos = !goLibrerias.ExisteBaseDeDatos( this.cBaseDeDatosEnProceso ) and upper( alltrim( goLibrerias.ObtenerNombreSucursal( this.cSucursalDefault ))) == upper( alltrim( this.cBaseDeDatosEnProceso ))
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function CrearYPrepararBDSQL() as Void
		local loFunciones as Object
		
		loFunciones = _screen.zoo.crearobjeto( "funcionesSQLServer","funcionesSQLServer.prg")
		loFunciones.Crear()
		
		loFunciones.Release()
		clear class loFunciones
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarScriptCrearDB( tcNombreDB as String ) as Void
		local lcSql as String, loError as zooexception OF zooexception.prg, lnConexionBase as Integer
		lcSql = ""

		if !empty( tcNombreDB )
			try
				lnConexionBase = goDatos.oManagerConexionASql.ObtenerNuevaConexionSinDatabase()
				if lnConexionBase > 0
					goDatos.nIdConexion = lnConexionBase
*					lcSql = this.ObtenerSentenciasParaCrearBaseDeDatos( tcNombreBD )
					text to lcSql textmerge noshow pretext 7
						CREATE DATABASE [<< tcNombreDB >>]

						EXEC dbo.sp_dbcmptlevel @dbname='<< tcNombreDB >>', @new_cmptlevel=90
						
						IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
						begin
							EXEC [<< tcNombreDB >>].[dbo].[sp_fulltext_database] @action = 'enable'
						end

						ALTER DATABASE [<< tcNombreDB >>] SET ANSI_NULL_DEFAULT OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET ANSI_NULLS OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET ANSI_PADDING OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET ANSI_WARNINGS OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET ARITHABORT OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET AUTO_CLOSE OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET AUTO_CREATE_STATISTICS ON 

						ALTER DATABASE [<< tcNombreDB >>] SET AUTO_SHRINK OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET AUTO_UPDATE_STATISTICS ON 

						ALTER DATABASE [<< tcNombreDB >>] SET CURSOR_CLOSE_ON_COMMIT OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET CURSOR_DEFAULT  GLOBAL 

						ALTER DATABASE [<< tcNombreDB >>] SET CONCAT_NULL_YIELDS_NULL OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET NUMERIC_ROUNDABORT OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET QUOTED_IDENTIFIER OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET RECURSIVE_TRIGGERS OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET  ENABLE_BROKER 

						ALTER DATABASE [<< tcNombreDB >>] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET DATE_CORRELATION_OPTIMIZATION OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET TRUSTWORTHY OFF 

						ALTER DATABASE [<< tcNombreDB >>] SET ALLOW_SNAPSHOT_ISOLATION ON 

						ALTER DATABASE [<< tcNombreDB >>] SET PARAMETERIZATION SIMPLE 

						ALTER DATABASE [<< tcNombreDB >>] SET  READ_WRITE 

						ALTER DATABASE [<< tcNombreDB >>] SET RECOVERY FULL WITH NO_WAIT

						ALTER DATABASE [<< tcNombreDB >>] SET  MULTI_USER 

						ALTER DATABASE [<< tcNombreDB >>] SET PAGE_VERIFY CHECKSUM  

						ALTER DATABASE [<< tcNombreDB >>] SET DB_CHAINING OFF 							
					endtext

					goDatos.EjecutarSql( lcSql )

				endif
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				goDatos.DesconectarMotorSQL()
			endtry					
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ModificarTamañoBaseDeDatos( tcNombreDB as string ) as Void
		local loError as Exception, loEx as Exception, lcSql as String, lnConexionBase as Integer

		try
			if !empty( tcNombreDB )
				lnConexionBase = goDatos.oManagerConexionASql.ObtenerNuevaConexionSinDatabase()
				if lnConexionBase > 0
					goDatos.nIdConexion = lnConexionBase
	
					text to lcSql textmerge noshow pretext 7
						use [<< tcNombreDB >>]
						select * from sys.sysfiles 
					endtext

					goDatos.EjecutarSql( lcSql, "curArchivosSQL", this.DataSessionId )
					lcSql = ""
					select curArchivosSql
					scan all
						lcSql = lcSql + "ALTER DATABASE [" + tcNombreDB + "] MODIFY FILE ( NAME = N'" + alltrim( curArchivosSql.name ) + ;
										"', SIZE = " + transform( this.nTamañoBaseDatos ) + "KB, FILEGROWTH = " + transform( this.nCrecimientoBaseDatos ) + "KB )" + chr(13) + chr(10)
					endscan
					goDatos.EjecutarSql( lcSql )
				endif
			endif				
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( "curArchivosSQL" )
			goDatos.DesconectarMotorSQL()
		endtry		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ProcesarTablas() as Void
		local loEx as zooexception OF zooexception.prg, lcError as String, loError as Exception
		
		if this.lTienePermisosDeAdmin
			with this
				try
					.EjecutarScripts( this.cScript, "" )
					if .EsMaster()
						.CargarOperacionesSeguridad()
					endif
				catch to loError
					if this.EsMaster()
						loError.Message = "Se ha producido un error al intentar actualizar los datos de la base de datos " + alltrim( upper( this.cBaseMaster )) + "."
						throw loError
					else
						lcError = this.DesgloceError( loError )
						.NotificarSinIncrementar( "Error: " + lcError, "" )
						goServicios.Errores.LevantarExcepcion( loError )
					endif
				endtry
			endwith
		else
			this.Notificar( "Su usuario no posee los permisos necesarios para realizar cambios.", "" )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarSinonimos() as Void
		local lcTablaAdn as String, lcAux as String, loError as Exception
		
		lcAux = sys(2015)

		Try
			lcTablaAdn = this.cCursorEstructuraAdnNuevo
			if !this.EsMaster()
				select distinct tabla, "" campo, "" tipodato, 0 longitud, 0 decimales, "SUCURSAL" ubicacion, .f. espk, .f. esCC, esquema, .f. esFK ;
				from &lcTablaAdn ;
				where alltrim( upper( ubicacion )) != "SUCURSAL" ;
				into cursor &lcAux
				
				select tabla, campo, tipodato, longitud, decimales, ubicacion, espk, esCC, esquema, esFK ;
				from &lcTablaAdn ;
				where alltrim( upper( ubicacion )) == "SUCURSAL" ;
				union all ;
				select tabla, campo, tipodato, longitud, decimales, ubicacion, espk, esCC, esquema, esFK ;
				from &lcAux ;
				into cursor &lcTablaAdn
				
				this.cXmlEstructuraAdnNuevo = this.CursorAxml( lcTablaAdn )
			endif
			
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( lcAux )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaTablasSegunUbicacionEnProceso( tcUbicacion as String ) as string
		local lcRetorno as String

		lcRetorno = ""
		return lcRetorno
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	function ObtenerCadenaConexionNet() as Void
		return goDatos.oManagerConexionASql.ObtenerCadenaConexionNet()
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected Function NotificarCambioDeSurcursal( tcSucursal as String, tlSoloParcial as Boolean ) As Void
		if !tlSoloParcial
			this.Notificarbarragral( "Base de datos: " + this.cBaseDeDatosEnProceso )
		endif	
		
		this.NotificarSinIncrementar( "Base de datos: " + this.cBaseDeDatosEnProceso, "" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function NotificarFinProcesoSucursal( tcSucursal as String ) As Void
		this.Notificar( "Actualización de la base de datos: " + this.cBaseDeDatosEnProceso  + " finalizada...", "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function NotificarErrorProcesoSucursal( tcSucursal as String ) As Void
		this.Notificar( "Error al realizar el backup de la base de datos: " + this.cBaseDeDatosEnProceso, "" )
	endfunc 			
	
	*-----------------------------------------------------------------------------------------
	protected function GrabarParametrosYRegistros( tlEsParametro as Boolean, tcUbicacion as String, tcNombreParametro as String, tcValor as String, tcProyecto as string, tnIdNodo as Integer ) as Void
		local lcCursor as String, loError as zooexception OF zooexception.prg, lcNombreTabla as String, lcId as String, i as Integer, lcCabecera as string

		lcCursor = sys( 2015 )
		lcNombreTabla = this.ObtenerNombreTabla( tcUbicacion, tlEsParametro )
		lcCabecera = forceext( lcNombreTabla, "cabecera" )
		lcId = ""
				
		if empty( tnIdNodo )
			tnIdNodo = 1
		endif
		
		if empty( tcProyecto )
			tcProyecto = _Screen.zoo.app.cProyecto
		endif

		try
			if goServicios.Librerias.ExisteTabla( this.cBaseDeDatosEnProceso, tcUbicacion, juststem( lcNombreTabla ))
				for i = 1 to 2
					goDatos.EjecutarSentencias( "select id from " + lcCabecera + " where nombre = '" + alltrim( upper( tcNombreParametro )) + "'", "cabecera", "", lcCursor, set("Datasession"))
				
					if reccount( lcCursor ) > 0
						lcId = transform( &lcCursor..Id )
						exit
					else
						goDatos.EjecutarSentencias( "insert into " + lcCabecera + " ( idNodo, Nombre, Proyecto ) values ( " + transform( tnIdNodo ) + ", '" + ;
							alltrim( upper( tcNombreParametro )) + "', '" + tcProyecto + "' )", "Cabecera", "" )
					endif
				endfor
				
				goDatos.EjecutarSentencias( "select 1 from " + lcNombreTabla + " where idCabecera = " + lcId , tcUbicacion, "", lcCursor, set("Datasession"))

				if reccount( lcCursor ) > 0
					goDatos.EjecutarSentencias( "update " + lcNombreTabla + " set valor = '" + tcValor + "' where idCabecera = " + lcId, tcUbicacion, "" )	
				else
					goDatos.EjecutarSentencias( "insert into " + lcNombreTabla + " ( idcabecera, valor ) values ( " + lcId + ", '" + tcValor + "' )", tcUbicacion, "" )
				endif
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select ( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreTabla( tcUbicacion as String, tlEsParametro as Boolean ) as String
		local lcRetorno as String
		
		if tlEsParametro
			lcRetorno = "Parametros."
		else
			lcRetorno = "Registros."
		endif
		
		lcRetorno = lcRetorno + tcUbicacion
		
		return lcRetorno
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	function CargarMatrizSucursales( tcTabla as String )	
		select padr( goServicios.Librerias.obtenernombresucursal( empcod ) , 50 ) empcod, epath, eunid, NC1, usuario, fchlog, descrip, color_bd ;
			from &tcTabla into array ( This.aSucursales )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AsignarRutaTablas() as Void
		Replace Ubicacion with upper( alltrim( this.cBaseMaster )) for upper( alltrim( Ubicacion ) ) != 'SUCURSAL' in cNuevo_aux
		Replace Ubicacion with upper( alltrim( this.cBaseMaster )) for upper( alltrim( Ubicacion ) ) != 'SUCURSAL' in cActual_aux		
		
		if !this.EsMaster()
			Replace Ubicacion with upper( alltrim( this.cBaseDeDatosEnProceso )) for upper( alltrim( Ubicacion ) ) == 'SUCURSAL' in cNuevo_aux
			Replace Ubicacion with upper( alltrim( this.cBaseDeDatosEnProceso )) for upper( alltrim( Ubicacion ) ) == 'SUCURSAL' in cActual_aux
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablasFinal() as Void
		local lcUbicacion as String
		
		if this.EsMaster()
			lcUbicacion = "upper( alltrim( Ubicacion )) != 'SUCURSAL'"
		else
			lcUbicacion = "upper( alltrim( Ubicacion )) == '" + upper( alltrim( this.cBaseDeDatosEnProceso )) + "'"
		endif
		
		select * ;
		from cActual_aux ;
		where &lcUbicacion;
		into cursor cActual
		
		select * ;
		from cNuevo_aux ;
		where &lcUbicacion;
		into cursor cNuevo	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorCreate() as Void
		select distinct n.tabla, n.campo, n.tipodato, n.longitud, n.decimales, n.ubicacion, n.espk, n.escc, n.esquema, n.EsFk ;
		from cNuevo n left join cActual a on n.tabla == a.tabla and n.esquema == a.esquema ;
		where isnull( a.tabla );
		order by n.tabla, n.esquema, n.campo ;
		into cursor ( this.cCursorCreate ) nofilter
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAlter() as Void
		local lcCNuevo as String, lcCActual as String
		lcCNuevo = sys(2015)
		lcCActual = sys(2015)
		select tabla, esquema from cNuevo group by tabla, esquema into cursor &lcCNuevo
		select tabla, esquema from cActual group by tabla, esquema into cursor &lcCActual 

		select distinct b.tabla, b.campo, b.tipodato, b.longitud, b.decimales, b.ubicacion, b.espk, b.escc, b.esquema, b.EsFk, ;
						c.tabla tabla_a, c.campo campo_a, c.tipodato tipodato_a, c.longitud longitud_a, c.decimales decimales_a, ;
						c.ubicacion ubicacion_a, c.espk espk_a, c.escc escc_a, c.esquema esquema_a ;
		from &lcCNuevo n inner join &lcCActual a on n.tabla == a.tabla and n.esquema == a.esquema ;
		inner join cNuevo b on a.tabla == b.tabla and a.esquema == b.esquema ;
		left join cActual c on b.tabla == c.tabla and b.esquema == c.esquema and b.campo == c.Campo;
		where isnull( c.tabla ) or ;
			( ( alltrim( upper( b.TipoDato ) ) == "C" and alltrim( upper( c.TipoDato ) ) != "C" and b.Longitud >= c.Longitud ) or ;
			( alltrim( upper( b.TipoDato ) ) == "V" and alltrim( upper( c.TipoDato ) ) != "V" and b.Longitud >= c.Longitud ) or ;
			( alltrim( upper( b.TipoDato ) ) == alltrim( upper( c.TipoDato ) ) and b.Longitud > c.Longitud or b.Decimales > c.Decimales ) );
		order by b.tabla, b.esquema, b.campo ;									
		into cursor ( this.cCursorAlter ) nofilter
	
		use in select( lcCNuevo )
		use in select( lcCActual )
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerBaseDeDatosParaDatosBasicos( tcUbicacion as String ) as string
		return alltrim( this.cBaseDeDatosEnProceso )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPermisosDeServidor() as Void
		local lnConexionBase as Integer
	
		lnConexionBase = goDatos.oManagerConexionASql.ObtenerNuevaConexionSinDatabase()
		if lnConexionBase > 0
			goDatos.nIdConexion = lnConexionBase
		endif
		
		try
			goDatos.ejecutarSentencias( "select is_member('db_owner') as dato", "", "", "c_PermisosUsuarioLogueado", this.DataSessionId )
			if c_PermisosUsuarioLogueado.dato = 1
				this.lTienePermisosDeAdmin = .t.
			else
				this.lTienePermisosDeAdmin = .f.
			endif
		catch to loError
			this.lTienePermisosDeAdmin = .f.
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			goDatos.DesconectarMotorSQL()
			use in select( "c_PermisosUsuarioLogueado" )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oEjecutadorFixes_access() as Void
		if vartype( this.oEjecutadorFixes ) != "O" or isnull( this.oEjecutadorFixes )
			_screen.Zoo.agregarreferencia( "ZooLogicSA.AdnImplant.dll" )
			_screen.Zoo.agregarreferencia( "ZooLogicSA.Core.Adn.dll" )
			this.oEjecutadorFixes = EjecutadorDeFixesFactory()
		endif
		return this.oEjecutadorFixes
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarFixes( tcUbicacion as string ) as Void
		local lcStringConnection as String

		lcStringConnection = goDatos.oManagerConexionASql.ObtenerCadenaConexionNet()
		this.Notificar( "Ejecutando fixes (" + proper( tcUbicacion ) + ")...", "" )
		this.oEjecutadorFixes.Ejecutar( this.cBaseDeDatosEnProceso, lcStringConnection, tcUbicacion, this.cVersionAdnNuevo )
		this.Notificar( "Ejecución finalizada.", "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConexionZoologicMaster( tcDb as String ) as Boolean
		local loPermisos as Object
		
		loPermisos = this.GestorPermisos.ObtenerPermisosDB( goServicios.Librerias.ObtenerNombreSucursal( tcDb ) )
		return loPermisos.ConectarBaseDeDatos
	endfunc
	
enddefine
