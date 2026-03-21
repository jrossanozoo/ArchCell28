define class ent_basededatos as din_entidadbasededatos of din_entidadbasededatos.prg

	#if .f.
		local this as ent_basededatos of ent_basededatos.prg
	#endif
	
	protected lLimpiandoRutaBackup, lLimpiandoRutaArchivoMDF, cDefaultRutaBackup, cDefaultRutaMDF 
	
	oSeguridad = null
	oColaboradorParametros = null
	lBaseDeDatosGenerada = .f.
	oOrigenDestino = null	

	cDefaultRutaBackup = chr(91) + "Ruta predeterminada del servidor SQL (C:\ZLBackups)" + chr(93)
	cDefaultRutaMDF = chr(91) + "Ruta predeterminada del servidor SQL" + chr(93)
	lLimpiandoRutaArchivoMDF = .f.
	lLimpiandoRutaBackup = .f.

	oAplicacion = null
	lExisteBaseDeDatos = .t.
	lArchivar = .F.
	cNombreArchivado = ""
	lQuiereDesarchivar = .F.
	
	oWrapperDB = null
	oColaboradorPropiedadesRep = null	
	
	lDeclararSitio = .T.
	lRestaurandoBackUp = .f.
	lEsWindows = .T.
		
	*-----------------------------------------------------------------------------------------
	function oColaboradorPropiedadesRep_Access() as Void
		if !this.ldestroy and ( !vartype( this.oColaboradorPropiedadesRep ) = 'O' or isnull( this.oColaboradorPropiedadesRep ) )
			this.oColaboradorPropiedadesRep = _screen.zoo.crearobjeto( "ColaboradorPropiedadesRep" )
		endif
		return this.oColaboradorPropiedadesRep 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oWrapperDB_Access() as Void
		if !this.ldestroy 
			this.oWrapperDB = _screen.zoo.crearobjeto( "WrapperInformacionBaseDeDatos", "WrapperInformacionBaseDeDatos.PRG", alltrim( this.Codigo ) )
		endif
		return this.oWrapperDB 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oSeguridad_Access() as Void
		if !this.ldestroy and ( !vartype( this.oSeguridad ) = 'O' or isnull( this.oSeguridad ) )
			this.oSeguridad = goServicios.seguridad
		endif
		return this.oSeguridad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oOrigenDestino_Access() as Void
		if !this.ldestroy and ( !vartype( this.oOrigenDestino ) = 'O' or isnull( this.oOrigenDestino ) )
			this.oOrigenDestino = _Screen.zoo.instanciarentidad( "OrigenDeDatos" )
		endif
		return this.oOrigenDestino
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorParametros_Access() as Void
		if !this.ldestroy and ( !vartype( this.oColaboradorParametros ) = 'O' or isnull( this.oColaboradorParametros ) )
			this.oColaboradorParametros = _screen.zoo.crearobjeto( "ColaboradorParametros" )
		endif
		return this.oColaboradorParametros
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oAplicacion_Access() as Void
		if !this.ldestroy and ( !vartype( this.oAplicacion ) = 'O' or isnull( this.oAplicacion ) )
			this.oAplicacion = _screen.zoo.app
		endif
		return this.oAplicacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.lHabilitarRutaCompleta = goServicios.datos.esNativa()
		this.lHabilitarRutaMDF = goServicios.Datos.esSqlServer()
		this.lEsWindows = this.EsServidorSQLWindows()
		this.lHabilitarRealizaBackup = goServicios.Datos.esSqlServer()
		this.lHabilitarRutaBackup = goServicios.Datos.esSqlServer() and this.lEsWindows
			
		this.lPermiteMinusculasPK = .f.
		if goServicios.Datos.esSqlServer()
			this.enlazar( "Setear_Rutamdf", "RutaMDF_DespuesDeAsignar" )
			this.enlazar( "Setear_RutaBackup", "RutaBackup_DespuesDeAsignar" )
		endif
		
		try
			this.oColeccionVS.Agregar( ".ValorSugeridoRutacompleta()", "RutaCompleta" )
		catch
			&&Se morfa la excepcion si ya esta en la coleccion por venir definido por el usuario
		endtry		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarArchivar() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Archivar() as Void
		local  loGestorDB as Object, loHelper as Object
		Try
			if _screen.zoo.app.puedoeliminarbasededatos( this.codigo ) 
				if this.ProcesaPaquetes
					This.AgregarInformacion( "No se puede Archivar la base de datos que procesa paquetes de datos, seleccione otra base de datos que procese paquetes de datos y reintente." )
					goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
				else
					This.EventoPreguntarArchivar()
					if This.lArchivar
						loHelper = _screen.zoo.crearobjeto( "HelperGestorBaseDeDatosSqlServer", "HelperGestorBaseDeDatosSqlServer.prg", this.Codigo )
						if !empty( this.RutaMdf ) and alltrim( this.RutaMdf ) != this.cDefaultRutaMDF
							loHelper.cRutaArchivoMDF = addbs( alltrim( .RutaMdf ) )
						endif
						loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos", "GestorBaseDeDatos.prg", loHelper )
						loGestorDB.ArchivarBD()
						This.Limpiar()
						This.RefrescarDespuesDeEliminar()
						This.cNombreArchivado = loGestorDB.cNombreArchivado
					endif
				endif 
			else
				this.AgregarInformacion( "No se puede Archivar la sucursal activa." )
				goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			This.lArchivar = .F.
		EndTry	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()

		this.lHabilitarRutaCompleta = goServicios.datos.esNativa()
		this.lHabilitarRutaMDF = goServicios.Datos.esSqlServer()
		
		this.lHabilitarPreferente = .T.
		this.lHabilitarSucursal_pk = .t.

		if goServicios.Datos.esSqlServer()
			this.RutaMDF = this.cDefaultRutaMDF
			this.RealizaBackup = .t.

			if !this.leswindows
				this.lHabilitarRutaBackup = .T.
			endif
			
			this.RutaBackup = this.cDefaultRutaBackup

			if !this.leswindows
				this.lHabilitarRutaBackup = .f.
			endif

		else
			this.lHabilitarRutaMDF = .f.
			this.lHabilitarRealizaBackup = .f.
			this.lHabilitarRutaBackup = .f.
			this.RealizaBackup = .f.		
		endif
		
		if "<GUARDARCOMO>" $ this.ObtenerFuncionalidades()
			this.lEsGuardarComo = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RutaMDF_DespuesDeAsignar( tx1, tx2, tx3, tx4 ) as Void
		dodefault( tx1, tx2, tx3, tx4 )
		if alltrim( this.RutaMDF ) == "" and !this.lLimpiandoRutaArchivoMDF 
			this.RutaMDF = this.cDefaultRutaMDF
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RutaBackup_DespuesDeAsignar( tx1, tx2, tx3, tx4 ) as Void
		dodefault( tx1, tx2, tx3, tx4 )
		if alltrim( this.RutaBackup ) == "" and !this.lLimpiandoRutaArchivoMDF 
			this.RutaBackup = this.cDefaultRutaBackup
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		this.lHabilitarOrigenDestino_pk = .F.
		this.lHabilitarRutaCompleta = .F.
		this.lHabilitarRutaMDF = .F.
		this.lHabilitarSucursal_pk = .f.
		
		if goServicios.Datos.esSqlServer()
			this.lHabilitarRealizaBackup = .t.
			this.lHabilitarRutaBackup = this.lEsWindows
		else
			this.lHabilitarRealizaBackup = .f.
			this.lHabilitarRutaBackup = .f.
		endif		
		this.lHabilitarConectada = this.PuedeModificarAtributoConectada()
		this.lHabilitarPreferente = !this.replica
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReasignarAtributosRuta() as Void
		*Sacamos los ":" que vienen junto a la letra
		this.Unidad = left( justdrive( alltrim( this.RutaCompleta ) ), 1 )
		this.Ruta = substr( addbs( alltrim( this.RutaCompleta ) ), 3 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Cargar() as boolean 
		local llRetorno as Boolean, loError as Exception

		llRetorno = dodefault()

		this.idBaseDeDatos = this.oWrapperdb.obtener('IDBaseDeDatos')
		
		with this
			if This.oAplicacion.VerificarExistenciaBase( .Codigo )
				if llRetorno and goServicios.datos.esNativa()
					.CargarRutaCompleta()
				endif
				this.lHabilitarConectada = !( upper( alltrim( this.Codigo ) ) == _screen.zoo.app.ObtenerSucursalDefault() )
				.CargarInformacionDeBaseDeDatos()
			else
				.lExisteBaseDeDatos = .f.
				.oMensaje.Advertir( " La Base de Datos " + upper( alltrim( .Codigo ) ) + " no existe." )
				.Loguear( " La Base de Datos " + upper( alltrim( .Codigo ) ) + " no existe." )
			endif

		endwith

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearSucPreferente() as Void
		this.lHabilitarPreferente = .T.
		this.Preferente = ( alltrim( this.Codigo ) == alltrim( goParametros.Nucleo.OrigenDeDatosPreferente ) )
		this.lHabilitarPreferente = !this.Preferente
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearSucProcesadoraDePaquetesDeDatos() as Void
		local lcBase as String 
		if !this.Replica
			lcBase = upper( alltrim( goParametros.Nucleo.Comunicaciones.procesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos ))
			if upper(alltrim( lcBase )) == "[PREF]"
				lcBase = alltrim( goParametros.Nucleo.OrigenDeDatosPreferente )
			endif 	
			this.lHabilitarProcesaPaquetes = .T.
			this.ProcesaPaquetes = ( alltrim( this.Codigo ) == lcBase  )
			this.lHabilitarProcesaPaquetes = !this.ProcesaPaquetes
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearConectadaZNube() as Void
		local lcTabla as String, lcBD as String
		
		if this.lHabilitarConectada
			lcTabla = this.oColaboradorPropiedadesRep.ObtenerNombreTablaPropiedadesRep()
			lcBD = alltrim( _screen.zoo.app.NombreProducto ) + "_" + alltrim( this.Codigo )
			this.Conectada = this.oColaboradorPropiedadesRep.ObtenerInformacionDeEstadoConectadoBD( goServicios.Datos, lcBD, lcTabla )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function _Cancelar() as Void
		dodefault()
		this.CargarRutaCompleta()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarRutaCompleta() as Void
		if this.lHabilitarRutacompleta 
			if !empty( this.unidad )
				this.RutaCompleta = alltrim(this.unidad) + ":" + alltrim(this.ruta)
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValorSugeridoRutacompleta() as void
		if goServicios.Datos.esNativa()
			this.Rutacompleta = _Screen.Zoo.cRutaInicial
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarRutaCompleta() as boolean
		local llRetorno as Boolean 
		llRetorno = .T.
		if goServicios.Datos.esNativa()
			llRetorno = dodefault()		
		endif
		return llRetorno	
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() as boolean
		local llRetorno as Boolean, lcTabla as String, lcFecha as String, lcUsuario as String, lcBD as String , lcMensaje as String 
		local lcProcesarPaquete as String, lcOrigenPreferente as String, llEsLaDemoIgual as Boolean, loAgenteAccionesOrganic as Object

		llRetorno = dodefault()
		lcMensaje = ""

		if this.Preferente
			goParametros.Nucleo.OrigenDeDatosPreferente = alltrim( this.Codigo )
		else
			if alltrim( upper( this.Codigo ) ) <> "DEMO"
				if alltrim( upper( goParametros.Nucleo.origenDeDatosPreferente ) ) == "DEMO"
					goParametros.Nucleo.origenDeDatosPreferente = alltrim( this.Codigo )
					this.Preferente = .t.
					lcMensaje = "La base de datos 'DEMO' estaba seteada como preferente. El sistema ha establecido como nueva base de datos preferente a la base '" + alltrim( this.Codigo ) + "'." + chr(13)
		endif
			endif
		endif

		if this.ProcesaPaquetes
			goParametros.Nucleo.Comunicaciones.procesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = alltrim( this.Codigo )
		else
			if !this.replica
				if alltrim( upper( this.Codigo ) ) != "DEMO"
					lcProcesarPaquete = alltrim( upper( goParametros.Nucleo.Comunicaciones.procesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos ) )
					lcOrigenPreferente = alltrim( upper( goParametros.Nucleo.origenDeDatosPreferente ) )
					llEsLaDemoIgual = ((lcProcesarPaquete == "DEMO") or ( lcProcesarPaquete == "[PREF]" and lcOrigenPreferente == "DEMO"))
					if llEsLaDemoIgual 
						goParametros.Nucleo.Comunicaciones.procesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = alltrim( this.Codigo )
						this.ProcesaPaquetes = .t.
						lcMensaje = lcMensaje + "La base de datos que procesa paquetes de datos estaba seteada con la base 'DEMO'. El sistema ha establecido como base de datos procesadora de paquetes de datos a la base '" + alltrim( this.Codigo ) + "'."					
					endif
				endif
			endif
		endif

		if this.EsNuevo() and !this.lRestaurandoBackUp 
			this.CrearDB( !this.lEsWindows and ("<GUARDARCOMO>" $ this.ObtenerFuncionalidades() and this.lEsGuardarComo ))
			if This.lBaseDeDatosGenerada
				This.ActualizarParametros()
			endif
		endif

		if !empty( lcMensaje )
			goServicios.mensajes.Informar( lcMensaje , 0, 0, "Base de Datos")
		endif

		if this.EsEdicion() or ( this.EsNuevo() and This.lBaseDeDatosGenerada )
			if !this.Replica and This.lBaseDeDatosGenerada
				this.ConfigurarInformaStock()
			endif

			this.CambiarColorBarraEstado()

			if empty( alltrim( this.RutaBackup ) )
				this.rutaBACKUP = this.cDefaultRutaBackUp
			endif 

			lcTabla = this.oColaboradorPropiedadesRep.ObtenerNombreTablaPropiedadesRep()
			lcBD = alltrim( _screen.zoo.app.NombreProducto ) + "_" + rtrim( this.Codigo )
			lcFecha = dtos( datetime()) + " " + time()
			lcUsuario = goServicios.Seguridad.cUsuarioLogueado
			this.oColaboradorPropiedadesRep.InsertarInformacionDeEstadoConectadoBD( goServicios.Datos, lcBD, lcTabla, this.Conectada, lcFecha, lcUsuario )
		endif

		* Declaración de sitio en zNube
		if this.lDeclararSitio and !this.lRestaurandoBackUp 
			loAAO = _Screen.zoo.CrearObjeto( "ConectorAgenteDeAccionesOrganic", "ConectorAgenteDeAccionesOrganic.prg" )
			goServicios.Librerias.IniciarServicioAAO()
			loAAO.DeclararSitio()
			loAAO = null
		endif

		if _vfp.StartMode = 4 and _screen.zoo.app.cProducto = '06'			
			this.InformarEstadisticasAPI()
		endif
		
	endfunc
	
		*-----------------------------------------------------------------------------------------
	function InformarEstadisticasAPI() as Void
		local loMEstadisticas as Object
		&& Llamada a DLL que informa Estadisticas a la API de ZNube
		
		loMEstadisticas = newobject("ManagerClaseEstadisticas","estadisticasfactory.prg")
		
		loMEstadisticas.InformarEstadisticas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearDB( tlVengoDeGuardarComoBaseEnLinux as Boolean ) as Void
		local llRetorno as Boolean, lnRestaurarBD as Integer, lcAux as String, loGestorDB as Object, loHelper as Object, ;
			lcMensaje1 as String, lcMensaje2 as String, lcInfoCopia as String

		lnRestaurarBD = 0
		llRetorno = .F.
		This.lBaseDeDatosGenerada = .F.
		with this as ent_BaseDeDatos of ent_BaseDeDatos.prg
			if goDatos.EsNativa()
				lcAux = addbs( alltrim( This.RutaCompleta )) + alltrim( this.codigo )
				loHelper = _screen.zoo.crearobjeto( "HelperGestorBaseDeDatosNativa", "HelperGestorBaseDeDatosNativa.prg", .RutaCompleta, .codigo )
			else
				lcAux = alltrim( .codigo )
				loHelper = _screen.zoo.crearobjeto( "HelperGestorBaseDeDatosSqlServer", "HelperGestorBaseDeDatosSqlServer.prg", .codigo )

				if !empty( .RutaMdf ) and alltrim( .RutaMdf ) != this.cDefaultRutaMDF
					loHelper.cRutaArchivoMDF = addbs( alltrim( .RutaMdf ) )
				endif
			endif

			loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos", "GestorBaseDeDatos.prg", loHelper )
			if !this.replica
				lnRestaurarBD = This.VerificarExistenciasDeBases( loGestorDB, lcAux )
			endif

			do case
				case lnRestaurarBD = 2
					llRetorno = .F.
					if this.lQuiereDesarchivar
						lcMensaje2 = "desarchivar"
					else
						lcMensaje2 = "generar"
					endif
				case lnRestaurarBD = 1
					if loGestorDB.VerificarSiEsBDMarcadaComoReplica( this.Codigo, tlVengoDeGuardarComoBaseEnLinux  )
						this.Replica = .t.
						goServicios.Datos.EjecutarSentencias( "UPDATE Emp Set Replica = 1 WHERE EmpCod = '" + this.Codigo + "'", "Emp" )
						llRetorno = loGestorDB.RestaurarBaseDeDatos( .Codigo )
					else
						llRetorno = loGestorDB.RestaurarBaseDeDatos( .Codigo )
					endif
					if "<GUARDARCOMO>" $ this.ObtenerFuncionalidades() and this.lEsGuardarComo
				
						lcInfoCopia = "Se generó la base de datos " + alltrim( .Codigo ) ;
											  + " como copia de " + .cCodigoPrevioGuardarComo;
											  + " el " + dtoc( date() ) + " a las " + time() + " hs." + chr(13) + chr(10)
								
						.zadsfw = lcInfoCopia
		
	
						lcMensaje1 = "creado como copia"
						lcMensaje2 = "crear como copia"
					else
						lcMensaje1 = "restaurado"
						lcMensaje2 = "restaurar"
					endif
				otherwise
					lcMensaje1 = "generado"
					lcMensaje2 = "generar"
					if this.replica
						llRetorno = loGestorDB.GenerarBaseDeDatosReplica()	
					else
						llRetorno = loGestorDB.GenerarBaseDeDatos()
					endif
			endcase 

			if llRetorno
				.oSeguridad.AgregarBaseDeDatos( alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueadoParaLogin() ), alltrim( .codigo ) )
				.oSeguridad.RefrescarMenuYBarraDelFormularioPrincipal()
				.oMensaje.Informar( "Se ha " + lcMensaje1 + " la Base de Datos " + upper( alltrim( .codigo ) ) + "." )
				.lBaseDeDatosGenerada = .t.	
			else
				This.lEliminar = .T.
				This.EliminarSinValidaciones()
				This.Limpiar()
				This.lEliminar = .F.
				if lnRestaurarBD != 2
					.oMensaje.Informar( "No se pudo " + lcMensaje2 + " la Base de Datos." )
				endif
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarExistenciasDeBases( toGestor as Object, tcBase as String ) as integer
		local lnRetorno as Integer, lcTextoAdicional as String
		lcTextoAdicional = ""
		lnRetorno = 0
		If toGestor.VerificarExistenciaBDEliminada( tcBase )
			if toGestor.VerificarSiEsBDMarcadaComoReplica( this.Codigo )
				lcTextoAdicional = "de réplica "
			endif
				lnRetorno = This.omensaje.Preguntar( "Se encontró una copia de la base de datos " + lcTextoAdicional + alltrim( this.codigo )+ ". Se procederá a restaurarla.", 1 )
		else
			if goServicios.datos.EsSqlServer()

				if "<GUARDARCOMO>" $ this.ObtenerFuncionalidades() and this.lEsGuardarComo
				
					local lcMensaje as String
					
					lcMensaje = "Se creará la base de datos " + lcTextoAdicional + alltrim( this.Codigo )+ " como copia de " + this.cCodigoPrevioGuardarComo + ". Durante el proceso es recomendable no utilizar la base de datos origen. ¿Desea continuar?"
				
					if This.omensaje.Preguntar( lcMensaje, 1 ) == 1
						toGestor.CrearCopiaBD( this.cCodigoPrevioGuardarComo , this.Codigo )
						lnRetorno = 1
					else
						lnRetorno = 2
					endif
				else
					loListArchivadas = toGestor.ListarBDsArchivadas( tcBase )
					if loListArchivadas.Count > 0
						lnRetorno = This.VerificarRecuperarBaseDeDatosArchivadas( toGestor, loListArchivadas )
					Endif
				Endif	

			Endif	

		Endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarRecuperarBaseDeDatosArchivadas( toGestor as Object, toListaArchivadas as Object ) as integer
		local lnRetorno as Integer, loError as Exception
		lnRetorno = 0
		This.cNombreArchivado = ""
		This.lQuiereDesarchivar = .F.
		This.EventoPreguntarSeleccionarArchivada( toListaArchivadas )
		if This.lQuiereDesarchivar	
			This.EventoSeleccionarArchivada( toListaArchivadas )
			if !empty( This.cNombreArchivado )
				try
					toGestor.DesarchivarBD( This.cNombreArchivado )
					lnRetorno = 1
				catch to loError
					lnRetorno = 2
				endtry
			else
				lnRetorno = 2
			endif
		Endif
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSeleccionarArchivada( toListaArchivadas as Object ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoSeleccionarArchivada( toListaArchivadas as Object ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarReplica() as Void
		local loGestorDB as GestorBaseDeDatos of GestorBaseDeDatos.prg
		
		loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos" )
		loGestorDB.GenerarBaseDeDatos( this.codigo , this.RutaCompleta, this.OrigenDestino_PK, this.Color )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		if !_screen.zoo.app.puedoeliminarbasededatos( this.codigo ) 
			this.AgregarInformacion( "No se puede eliminar la sucursal activa." )
			goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
		else
			if this.ProcesaPaquetes
				This.AgregarInformacion( "No se puede anular la base de datos que procesa paquetes de datos, seleccione otra base de datos que procese paquetes de datos y reintente." )
				goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
			else
			This.Bindearevento( this, "EventoPreguntarEliminar", this, "EliminarBaseDeDatosSqlServer" )
			dodefault()
			This.DesBindearevento( this, "EventoPreguntarEliminar", this, "EliminarBaseDeDatosSqlServer" )
			if This.lEliminar
				This.RefrescarDespuesdeEliminar()
				this.InformarEstadisticasAPI()
			Endif
		endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarBaseDeDatosSqlServer() as Void
		if This.lEliminar
			if goServicios.Datos.EsSqlServer() and !This.lArchivar
				try 
					This.EliminarBD( This.Codigo )
				catch to loError
					This.lEliminar = .f.
					goServicios.Errores.LevantarExcepcion( loError )
				Endtry	
			Endif
		Endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RefrescarDespuesDeEliminar() as Void
		this.oSeguridad.RefrescarMenuYBarraDelFormularioPrincipal()
		_screen.zoo.app.CargarSucursales()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarBD( tcCodigo as String ) as Void
		local  loGestorDB as Object, loHelper as Object
		loHelper = _screen.zoo.crearobjeto( "HelperGestorBaseDeDatosSqlServer", "HelperGestorBaseDeDatosSqlServer.prg", this.Codigo )
		if !empty( this.RutaMdf ) and alltrim( this.RutaMdf ) != this.cDefaultRutaMDF
			loHelper.cRutaArchivoMDF = addbs( alltrim( .RutaMdf ) )
		endif
		loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos", "GestorBaseDeDatos.prg", loHelper )
		loGestorDB.EliminarBD( tcCodigo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GuardarComo() as Void
		dodefault()
		this.replica=.f.
		this.lHabilitarPreferente = .T.
		this.preferente = .f.
		this.lHabilitarPreferente = .F.
		
		this.lHabilitarprocesapaquetes = .t.
		this.procesapaquetes = .f.
		this.lHabilitarprocesapaquetes = .f.

		if !this.lEsWindows
			this.lHabilitarRutaBackup = .f.
		endif
		
		this.idBaseDeDAtos = ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		this.Descripcion = this.Codigo
		
		if !goServicios.datos.esNativa()
			this.Ruta = goServicios.Librerias.ObtenerNombreSucursal( this.Codigo )
		endif

		if alltrim( this.RutaCompleta ) == this.cDefaultRutaMDF
			this.lLimpiandoRutaArchivoMDF = .t.
			this.RutaMDF = ""
			this.lLimpiandoRutaArchivoMDF = .f.
		endif

		if alltrim( this.RutaBackUP ) == this.cDefaultRutaBackup
			this.lLimpiandoRutaArchivoMDF  = .t.
			
			if this.lEsWindows
				this.RutaBackup = ""
			endif
			
			this.lLimpiandoRutaArchivoMDF  = .f.
		endif		
		
		Return dodefault()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oSeguridad = null
		This.oColaboradorParametros = null
		this.oColaboradorPropiedadesRep = null
		This.oAplicacion = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresValidos() as string
		local lcValidos as String 
		lcValidos = dodefault()
		***Elimino de los caracteres validos para el codigo el / ya que trae problemas al generar base de datos.
		lcValidos = strtran( lcValidos, "/", "" )
		return lcValidos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarInformaStock() as Void
		local loConf as object, lcRuta as string, loError as Exception, loEx as zooexception OF zooexception.prg

		try
			lcRuta = ""
			if goServicios.Datos.EsNativa()
				lcRuta = addbs( this.RutaCompleta ) + alltrim( this.Codigo ) + "\dbf"
			else
				lcRuta = goServicios.Datos.oManagerConexionASql.ObtenerCadenaConexionNet( this.Codigo )
			endif

			_screen.zoo.agregarreferencia( "ZooLogicSA.SR.AO.Configurador.dll" )
			loConf = _screen.zoo.crearobjeto( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO","", ;
				_screen.zoo.cRutaInicial, this.InformaStock, alltrim( this.Codigo ), lcRuta )

			loConf.Configurar()
		catch to loError
			loex = newobject( "zooexception", "zooexception.prg" )
			loex.grabar( loError )
		finally
			loConf = null
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerParametrosSucursal() as Void
		local lcOrigenDestino as String
		this.lEstaSeteandoValorSugerido = .t.
		lcOrigenDestino = This.oColaboradorParametros.ObtenerParametroDeBaseDeDatos( 'Codigo Origen De Sucursal', This.Codigo )
		
		if !empty( lcOrigenDestino )
		else
			lcOrigenDestino = This.OrigenDestino_pk
		endif
		This.VerificarOrigenDestino( lcOrigenDestino )
		This.OrigenDestino_pk = lcOrigenDestino
		This.Sucursal_pk = This.oColaboradorParametros.ObtenerParametroDeBaseDeDatos( 'Sucursal', This.Codigo )
		this.lEstaSeteandoValorSugerido = .f.

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarParametros() as Void
		This.oColaboradorParametros.SetearParametrosAOtraBaseDeDatos( "goServicios.Parametros.Nucleo.Transferencias.CodigoOrigenDeSucursal", This.Codigo, This.OrigenDestino_pk )
		This.oColaboradorParametros.SetearParametrosAOtraBaseDeDatos( "goServicios.Parametros.Nucleo.Sucursal", This.Codigo, This.Sucursal_pk )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarOrigenDestino( tcOrigenDestino as String ) as Void
		local loError
		try
			this.oOrigenDestino.Codigo = tcOrigenDestino
		catch to loError
			this.oOrigenDestino.Nuevo()
			this.oOrigenDestino.Codigo = tcOrigenDestino
			this.oOrigenDestino.Grabar()
		Endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearGuid( tcGuid as string ) as void
		local loInformacionBaseDeDatos as WrapperInformacionBaseDeDatos of WrapperInformacionBaseDeDatos.PRG
		
		if !this.EsNuevo() and !this.EsEdicion() and this.Replica
			loInformacionBaseDeDatos = this.oWrapperDB 
			loInformacionBaseDeDatos.Setear( "IDBaseDeDatos", tcGuid )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		local llRetorno as Boolean

		llRetorno  = dodefault()
		if llRetorno and !this.ValidarCrearBDTipoReplica()
			llRetorno = .f.
			this.agregarinformacion( "No se puede generar una base de datos de réplica en motor nativa. cambie el valor e intente nuevamente." )
		endif
		
		if this.DebeValidarRutaMDF() and !this.ValidarRutaEnServidorDeSqlServer( this.RutaMDF )
			llRetorno = .f.
			this.agregarinformacion( "La ruta indicada para los archivos de la base de datos no es válida dentro del servidor SQL Server. Verifique que exista y que tenga permisos de escritura y lectura." )
		endif

		if this.lEsWindows and this.ValidarExistenciaRutaEnServidorDeSqlServer( this.RutaBackup ) and this.DebeValidarRutaBackupSQL() and !this.ValidarRutaEnServidorDeSqlServer( this.RutaBackup )
			llRetorno = .f.
			this.agregarinformacion( "La ruta para el backup de la base de datos no es válida dentro del servidor SQL Server. Verifique que exista y que tenga permisos de escritura y lectura." )
		endif
				
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarRutaBackupSQL() as Boolean
		return !empty( this.RutaBackup ) and goServicios.Datos.EsSqlServer() and alltrim( this.RutaBackup )!= this.cDefaultRutaBackup
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DebeValidarRutaMDF() as Boolean
		return !empty( this.RutaMDF ) and goServicios.Datos.EsSqlServer() and alltrim( this.RutaMDF )!= this.cDefaultRutaMDF
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_ProcesaPaquetes( txVariant as Variant ) as Void
		if this.Replica and txVariant
			this.oMensaje.Advertir( "La Base de Datos <es una Replica>, no se puede habilitar como Procesadora de paquete de datos")
		else
			dodefault(txVariant)
		endif 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_Replica( txVariant as Variant ) as Void
		local llEstado as Boolean
		dodefault(txVariant)
		if this.Replica && override si estan seteados
			this.ForzarDeshabilitar( "ProcesaPaquetes" )
			this.ForzarDeshabilitar( "Realizabackup" )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ForzarDeshabilitar( tcPropiedad as String ) as Void
		local llValorAnteriorHabilitar as Boolean, lcPropiedad as String, lcPropiedadGenHabilitar as String
		
		lcPropiedad = "this." + tcPropiedad
		lcPropiedadGenHabilitar = "this.lHabilitar" + tcPropiedad 
		
		llValorAnteriorHabilitar = &lcPropiedadGenHabilitar 
		
		&lcPropiedadGenHabilitar = .t.
		
		&lcPropiedad = .f.
		
		&lcPropiedadGenHabilitar = llValorAnteriorHabilitar

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCrearBDTipoReplica() as Boolean
		local llRetorno as Boolean
		if ( this.Replica )
			llRetorno = goServicios.Datos.EsSqlServer()
		else
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 
				
	*-----------------------------------------------------------------------------------------
	function CambiarColorBarraEstado() as Void

		If _Screen.zoo.App.ncolorbd <> This.Color and Type("_screen.zoo.app.oformprincipal.oBarraestado") = "O"
			if alltrim(_Screen.zoo.App.csucursalactiva) = alltrim(This.codigo)
				_Screen.zoo.App.ncolorbd = This.Color
				_Screen.zoo.App.oformprincipal.obarraestado.setearcolor()
			ENDIF
			_Screen.zoo.App.CargarSucursales()
		ENDIF
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarExistenciaRutaEnServidorDeSqlServer( tcRuta as String ) as Boolean
		local lcRuta as String, lcSemilla as String, lcCrearDB as String, lcEliminarDB as String, ;
			llRetorno as Boolean, loError as Exception, lcCrearDirectorio as String
			
		llRetorno = .t.
		lcRuta = addbs( alltrim( tcRuta ) )
		if empty( tcRuta ) 
			lcRuta = "C:\ZlBackups\"
		endif

		try
			lcCrearDirectorio = [EXEC master..xp_cmdshell N'MD "] + lcRuta + ["']
			goServicios.Datos.EjecutarSentencias( lcCrearDirectorio , "Sys.Object" )
		catch to loError
			llRetorno = .f.
		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarRutaEnServidorDeSqlServer( tcRuta as String ) as Boolean
		local lcRuta as String, lcSemilla as String, lcCrearDB as String, lcEliminarDB as String, ;
			llRetorno as Boolean, loError as Exception, lcCrearDirectorio as String
			
		llRetorno = .t.
		lcRuta = addbs( alltrim( tcRuta ) )
		lcSemilla = "T" + strtran( sys( 2015 ), "_", "" )
		lcCrearDB = "CREATE DATABASE [" + lcSemilla + "] ON PRIMARY ( NAME = N'" + lcSemilla + "', FILENAME = N'" + lcRuta + lcSemilla + ".mdf' )"
		lcEliminarDB = "DROP DATABASE [" + lcSemilla + "]"

		try
			goServicios.Datos.EjecutarSentencias( lcCrearDB, "Sys.Object" )
			goServicios.Datos.EjecutarSentencias( lcEliminarDB, "Sys.Object" )
		catch to loError
			llRetorno = .f.
		endtry

		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Limpiar( tlForzar as boolean ) as void
		this.lLimpiandoRutaArchivoMDF = .t.
		this.lLimpiandoRutaBackup = .t.
			
		dodefault( tlForzar )
		
		this.lLimpiandoRutaArchivoMDF = .f.
		this.lLimpiandoRutaBackup = .f.		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function _EsRegistroModificable() as Void
		
		dodefault()
		
		if !this.lExisteBaseDeDatos
			goServicios.Errores.LevantarExcepcion( "El registro de la entidad " + ;
				alltrim( this.cDescripcion ) + " no puede ser modificado porque la Base de Datos no puede accederse." )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarInformacionDeBaseDeDatos() as Void
	local loError as Exception
		
		with this

			try
				.SetearSucPreferente()
				.SetearSucProcesadoraDePaquetesDeDatos()
				.SetearConectadaZNube()
				.ObtenerParametrosSucursal()
				.lExisteBaseDeDatos = .t.
			catch to loError
				.lExisteBaseDeDatos = .f.
				.oMensaje.Advertir( "Existen problemas al intentar acceder a la Base de Datos " + upper( alltrim( .Codigo ) ) + "." )
			endtry
		endwith

	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ObtenerRutaBackupDefault() as String
		return this.cDefaultRutaBackup
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SeteosSegunCodigoDeBD() as Void
		if upper( rtrim( this.Codigo ) ) == _screen.zoo.app.ObtenerSucursalDefault()
			this.Conectada = .f.
		endif
	
		this.lHabilitarConectada = !( upper( rtrim( this.Codigo ) ) == _screen.zoo.app.ObtenerSucursalDefault())
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PuedeModificarAtributoConectada() as Boolean
		return !( upper( alltrim( this.Codigo ) ) == _screen.zoo.app.ObtenerSucursalDefault() ) and !this.Replica
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsServidorSQLWindows() as Boolean
		local llRetorno as Boolean, lcCursor as String
		
		lcCursor = "c_" + sys(2015)

		goServicios.Datos.EjecutarSentencias( "Select windows_release as version from sys.dm_os_windows_info", "", "", lcCursor, set( "Datasession" ) )
	
        select ( lcCursor )	
        
		if reccount( lcCursor ) > 0 and !empty( &lcCursor..version ) 
			llRetorno = .T.
		endif

		use in ( lcCursor )

		return llRetorno

	endfunc 

enddefine