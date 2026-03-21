define class GestorBaseDeDatos as zoosession of zoosession.prg

	#if .f.
		local this as GestorBaseDeDatos of GestorBaseDeDatos.prg
	#endif

	oHelper = null
	cNombreArchivado = ""

	*-----------------------------------------------------------------------------------------
	function Init( toHelper as HelperGestorBaseDeDatos of HelperGestorBaseDeDatos.prg )
		this.oHelper = toHelper
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarBaseDeDatos() as Boolean
		local lcRutaOrigen as String, lcSucursalOrigen as String, lcRutaDestino as String, ;
			llRetorno  as Boolean, loError as zooexception OF zooexception.prg, loAdnImplant as Object

		llRetorno = .f.
	
		try
			if _screen.zoo.app.CargarSucursales()
				lcSucursalOrigen = this.oHelper.ObtenerSucursalOrigen()
				lcNuevaBaseDeDatos = this.oHelper.ObtenerBaseDeDatos()
				lcRutaOrigen = this.oHelper.ObtenerRutaOrigen()
				lcRutaDestino = this.oHelper.ObtenerRutaDestino()	
				
				loAdnImplant = _screen.zoo.crearobjeto( "AdnImplant" )
				loAdnImplant.cRutaArchivoMDF = iif( this.oHelper.EsSQLServer(), this.oHelper.cRutaArchivoMDF, "" ) 

				llRetorno = loAdnImplant.EjecutarAdnImplantV2( 1, lcNuevaBaseDeDatos, .t. )
				if llRetorno
					If alltrim( upper( _Screen.Zoo.App.ObtenerSucursalDefault() ) ) == alltrim( upper( lcNuevaBaseDeDatos ) )
					Else
						goServicios.Estructura.CopiarTablasSucursal( lcRutaOrigen, lcRutaDestino, lcSucursalOrigen, lcNuevaBaseDeDatos )
					Endif
				endif
			endif
		catch to loError
			llRetorno = .f.
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			if !llRetorno
				this.oHelper.EliminarCreacionErronea()
			endif
			this.oHelper.Finalizar()
		endtry

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarBaseDeDatosReplica() as Boolean
		local lcRutaOrigen as String, lcSucursalOrigen as String, lcRutaDestino as String, ;
			llRetorno  as Boolean, loError as zooexception OF zooexception.prg, loAdnImplant as Object

		llRetorno = .f.
		
		try
			if _screen.zoo.app.CargarSucursales()
				lcNuevaBaseDeDatos = this.oHelper.ObtenerBaseDeDatos()
				
				loAdnImplant = _screen.zoo.crearobjeto( "AdnImplant" )
				llRetorno = loAdnImplant.EjecutarAdnImplantV2( 3, lcNuevaBaseDeDatos, .t. )
			endif
		catch to loError
			llRetorno = .f.
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			if !llRetorno
				this.oHelper.EliminarCreacionErronea()
			endif		
			this.oHelper.Finalizar()
		endtry

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function RestaurarBaseDeDatos( tcBaseDeDatos as string ) as Boolean
		local llRetorno as Boolean, loAdnImplant as Object
		
		llRetorno = .t.
		
		try
			_screen.zoo.app.CargarSucursales()

			loAdnImplant = _screen.zoo.crearobjeto( "AdnImplant" )
			
			llRetorno = loAdnImplant.EjecutarAdnImplantV2( 15, tcBaseDeDatos, .t. ) && Ejecuta el adnimplant para corregir collation

			if llRetorno 
				llRetorno = loAdnImplant.EjecutarAdnImplantV2( 0, tcBaseDeDatos, .t. )
			endif

		catch to loError		
			goServicios.Mensajes.Enviar( loError.message )
			llRetorno = .f.
		endtry
		
		return llRetorno 
	endfunc	

	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaBDEliminada( tcBaseDeDatos as String ) as Boolean 
		local llRetorno as Boolean, lcXml as String, lcCursor as String
		llRetorno = .f.
		
		llRetorno = goServicios.Librerias.ExisteBaseDeDatos( goServicios.Librerias.ObtenerNombreSucursal( tcBaseDeDatos ) )
			
		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function VerificarSiEsBDMarcadaComoReplica( tcBaseDeDatos as String, tlVengoDeGuardarComoBaseEnLinux as Boolean ) as Boolean
		local llRetorno as Boolean, lcCursor as String, lcNombreBD as String, lcConsulta as String
		llRetorno = .f.

		lcNombreBD = goServicios.Librerias.ObtenerNombreSucursal( tcBaseDeDatos )

		if goServicios.Librerias.ExisteBaseDeDatos( lcNombreBD, tlVengoDeGuardarComoBaseEnLinux )
			lcCursor = sys( 2015 )
			try
				&& Cuando es restauración de snapshot en este punto no tiene el esquema ADNImplant y sus tablas.
				&& Se maneja la excepción y se asume que no es una BD de replica.
				lcConsulta = "SELECT Ubicacion FROM [" + lcNombreBD + "].[ADNIMPLANT].[EstructuraBDVersion] WHERE Ubicacion = 'REPLICA'"
				goServicios.Datos.EjecutarSentencias( lcConsulta, "", "", lcCursor, set( "Datasession" ) )
				llRetorno = ( reccount( lcCursor ) > 0 )
				use in select( lcCursor )
			catch
			endtry
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ArchivarBD() as Void
		local loFactoryNet as Object, loGestorNet as Object, loParametrosNet as Object, loRet as Object
		
		loParametrosNet = This.ObtenerParametrosNet()
		loGestorNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.LanzadorDeProcesos","", loParametrosNet  )  
		lcSucursal = this.oHelper.ObtenerBaseDeDatos()
		loRet = loGestorNet.ArchivarBD( lcSucursal )
		
		if loRet.ResultadoEjecucion.Estado = 0  && Estado OK
			This.cNombreArchivado = loRet.NombreBDAsignado
		else
			goServicios.Errores.LevantarExcepcion( "No se pudo archivar la base de datos " + this.oHelper.ObtenerBaseDeDatos() )
		Endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarBD( tcCodigo as String ) as Void
		local loFactoryNet as Object, loGestorNet as Object, loParametrosNet as Object, loRet as Object
		loFactoryNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )  
		loParametrosNet = This.ObtenerParametrosNet()

		loGestorNet = 	loFactoryNet.ObtenerGestorBD( loParametrosNet )
		loRet = loGestorNet.EliminarBD( tcCodigo )
		if loRet.ResultadoEjecucion.Estado = 0  && Estado OK
		else
			goServicios.Errores.LevantarExcepcion( "No se pudo eliminar fisicamente la base de datos " + this.oHelper.ObtenerBaseDeDatos() )
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearCopiaBD( tcCodigoOriginal as String, tcCodigoNuevo as String ) as Void
		local loFactoryNet as Object, loGestorNet as Object, loParametrosNet as Object, loRet as Object

		loFactoryNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )  
		loParametrosNet = This.ObtenerParametrosNet()
		loGestorNet = 	loFactoryNet.ObtenerGestorBD( loParametrosNet )

		loRet = loGestorNet.CrearCopiaBD( tcCodigoOriginal, tcCodigoNuevo  )

		if loRet.ResultadoEjecucion.Estado = 0  && Estado OK
		else
			goServicios.Errores.LevantarExcepcion( "No se pudo copiar la base de datos " + this.oHelper.ObtenerBaseDeDatos() )
		Endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerParametrosNet() as Object
		local loAdnImplant as Object,  loParametrosNet as Object
		loAdnImplant = _screen.zoo.crearobjeto( "AdnImplant" )
		loParametrosNet = loAdnImplant.ObtenerObjetoParametros()
		loParametrosNet.AgregarBDAProcesar( this.oHelper.ObtenerBaseDeDatos(), .t. )
		return loParametrosNet
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ListarBDsArchivadas( tcBase ) as Object

		local loFactoryNet as Object, loGestorNet as Object, loParametrosNet as Object, loRet as Object
		loFactoryNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )  
		loParametrosNet = This.ObtenerParametrosNet()
		loParametrosNet.EjecutarSilencioso = .T.
		loGestorNet = 	loFactoryNet.ObtenerGestorBD( loParametrosNet)
		loRet = loGestorNet.ListarBDsArchivadas( tcBase )
		return loRet
	endfunc

	*-----------------------------------------------------------------------------------------
	function DesarchivarBD( tcBaseArchivada as String ) as Void
		local loFactoryNet as Object, loGestorNet as Object, loParametrosNet as Object, loRet as Object
		loFactoryNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )  
		loParametrosNet = This.ObtenerParametrosNet()
		loGestorNet = 	loFactoryNet.ObtenerGestorBD( loParametrosNet )
		loRet = loGestorNet.DesarchivarBD( tcBaseArchivada)		
		if loRet.ResultadoEjecucion.Estado = 0  && Estado OK
		else
			goServicios.Errores.LevantarExcepcion( "No se pudo desarchivar la base de datos " + tcBaseArchivada )
		Endif
	endfunc 

enddefine
