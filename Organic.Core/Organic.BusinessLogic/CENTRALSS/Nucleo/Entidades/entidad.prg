Define Class Entidad As TipoBase Of TipoBase.prg

	#If .F.
		Local This As Entidad As Entidad.prg
	#Endif

	protected cAtributoPK, lEntidadEditable, lInicializarCodigoSugeridoHabilitado as Boolean

	cNombre = ""

	lEdicion = .F.
	lNuevo = .F.
	lLimpiando = .f.
	lCargando = .f.
	lEliminar = .T.
	lAnular = .f.
	cAtributoPK = ""
	lPermiteMinusculasPK = .f.
	cContexto = ""
	lProcesando = .F.
	oValidacionDominios	= null
	oAD = null

	oNumeraciones =  null
	cAtributoAAuditar = ""
	lActualizaRecepcion = .T.
	cPrefijoRecibir = ""
	cPrefijoImportar = ""
	lReAsignarPk_Con_CC = .F.
	FechaAltaFW = {}
	HoraAltaFW = ""
	FechaModificacionFW = {}
	HoraModificacionFW = ""
	UsuarioAltaFW = ""
	UsuarioModificacionFW = ""
	SerieAltaFW = ""	
	SerieModificacionFW = ""
	BaseDeDatosAltaFW = ""
	BaseDeDatosModificacionFW = ""
	VersionAltaFW = ""
	VersionModificacionFW = ""
	
	lEntidadEditable = .t.
	BloquearRegistro = .f.
	oExtension = null
	RetornoExtension = .t.
	oAtributosAuditoria = null
	lTieneAccionesAutomaticas = .f.
	oAtributosAnulacion = null
	oProveedorAtributosAnulacion = null
	lEstaSeteandoValorSugerido = .f.
	oComportamientoCodigoSugerido = null
	lEsSubEntidad = .f.
	lInicializarCodigoSugeridoHabilitado = .f.
	lAccionAutomaticaTipoAntes = .F.	
	lBuscandoCodigo = .f.
	lActivando = .f.
	lInstanciarSubEntidadaDemanda = .t.
	oColAtributosObligatoriosDefinidosPorUsuario = null
	oRegistrosDeActividadesAlGrabar = Null	
	lHabilitaEnviarAlGrabar = .f.
	cIdentificadorConexion = ""
	lEsEntidadConEdicionRestringida = .f.
	oAtributosConEdicionRestringida	= null
	cEvento = ""

	oValidadoresComp = null
	oObservadoresDeImportacion = null
	lIgnorarCamposObligatoriosDefinidosPorUsuario = .F.
	oGestorDeMail = null
	lTieneDiseñosParaEnviarMail = .t.
	lEnviaMailErroresSegundoPlanoHerramientaEcommerce = .f.
	lEnviaMailTiquetDeCambioEnSegundoPlano = .f.
	
	lDebeRenumerarAlEnviarABaseDeDatos = .F.
	
	lEligioUnCodigoDeLaLista = .F.
	lActualizarSoloEquivalenciasDeLince = .f.
	CamposEquivalenciaLince = ""
	cCaracteres = ""
	oTalle = null
	lWHIngresar = .f.
	lWHModificar = .f.
	lWHEliminar = .f.
	cDescripcionSingular = ""
	lControlaSecuencialEnCodBarAlt = .F.
	lIgnorarClaveprimariaEnRecepcionBD = .f.
	lOmiteObligatorioEnPack = .f.
	
	cUsuarioQueAutorizoSeguridad = ""
	
	lConfirmarImpresion = 0
	
	*-------------------------------------------------------------------------------------------------
	Function Init( t1, t2, t3, t4 ) As Boolean
		Local llRetorno As Boolean, lcXml As String

		llRetorno = DoDefault() And ( This.Class # "Entidad" )
		If llRetorno
			With This
				.oValidacionDominios = goServicios.Controles.oDominios
				.IniciarAccionesAutomaticas()
				.Inicializar()
				.InstanciarExtension()
			Endwith
		Endif
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function oRegistrosDeActividadesAlGrabar_Access() as ZooColeccion of ZooColeccion.Prg
		if !this.ldestroy and !vartype( this.oRegistrosDeActividadesAlGrabar ) = 'O'
			this.oRegistrosDeActividadesAlGrabar = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oRegistrosDeActividadesAlGrabar
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarRegistrosDeActividadAlGrabar() as Void
		this.oRegistrosDeActividadesAlGrabar.Remove( -1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarRegistroDeActividad( tcActividad as String) as Void
		if goServicios.RegistroDeActividad.EstaHabilitado()
			This.oRegistrosDeActividadesAlGrabar.Agregar( goServicios.RegistroDeActividad.IniciarRegistro( proper( this.ObtenerNombre() ) , tcActividad ), tcActividad )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarRegistroDeActividadExtendido( tcActividad as String) as Void
		if	goServicios.RegistroDeActividad.EstaHabilitado() and goServicios.RegistroDeActividad.lTrazaExtendidaHabilitada
			This.oRegistrosDeActividadesAlGrabar.Agregar( goServicios.RegistroDeActividad.IniciarRegistro( proper( this.ObtenerNombre() ), tcActividad ), tcActividad )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarRegistrosDeActividad() as Void
		if goServicios.RegistroDeActividad.EstaHabilitado()
			goServicios.RegistroDeActividad.DeshabilitarTrazaExtendidaMensajeria()
			goServicios.RegistroDeActividad.EliminarRegistros( This.oRegistrosDeActividadesAlGrabar )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstablecerTiemposEnRegistroDeActividad( tcItem as String ) as Void
		if goServicios.RegistroDeActividad.EstaHabilitado()
			goServicios.RegistroDeActividad.EstablecerTiemposEnRegistro( This.oRegistrosDeActividadesAlGrabar.Item[tcItem])
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstablecerTiemposEnRegistroDeActividadExtendido( tcItem as String ) as Void
		if goServicios.RegistroDeActividad.EstaHabilitado() and goServicios.RegistroDeActividad.lTrazaExtendidaHabilitada
			goServicios.RegistroDeActividad.EstablecerTiemposEnRegistro( This.oRegistrosDeActividadesAlGrabar.Item[tcItem])
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FinalizarRegistrosDeActividad( tcAgrupadordeActividad as String ) as Void
		if goServicios.RegistroDeActividad.EstaHabilitado()
			goServicios.RegistroDeActividad.FinalizarRegistros( This.oRegistrosDeActividadesAlGrabar, tcAgrupadordeActividad )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.lDestroy = .t.
		this.oNumeraciones = null
		this.oAd = null
		this.oValidacionDominios = null
		this.oExtension = null
		this.oColAtributosObligatoriosDefinidosPorUsuario = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function _EntidadEditable() as Void
		if this.lEntidadEditable
		else
			goServicios.Errores.LevantarExcepcion( "La entidad " + alltrim( this.cNombre ) + " no puede ser modificada." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function _EsRegistroModificable() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		if this.EsRegistroBloqueado() and !this.lEsEntidadConEdicionRestringida &&!this.EsEntidadConEdicionRestringida()
			lcMotivo = " porque es Sólo lectura."
		endif
		if this.EsRegistroInactivo()
			lcMotivo = " porque está Inactivo."
		endif
		if !_Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )
			lcMotivo = " porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica."
		endif
		if this.EstaModificandoUnRegistroDeLince()
			lcMotivo = " porque es un registro proveniente de un paquete de datos de Lince Indumentaria."
		endif 
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "El registro de la entidad " + ;
				alltrim( this.cDescripcion ) + " no puede ser modificado" + lcMotivo )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstaModificandoUnRegistroDeLince() as Boolean
		return .f. && Se sobreescribe en ent_comprobantedeventas
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function EsRegistroBloqueado() as Boolean
		return this.BloquearRegistro
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsRegistroInactivo() as Boolean
		return !this.lActivando and "<DESACTIVABLE>" $ this.ObtenerFuncionalidades() and this.InactivoFW
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsRegistroEditable() as Boolean
		return !this.EsRegistroBloqueado() and !this.EsRegistroInactivo() and _Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function _EsRegistroEliminable() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		if this.BloquearRegistro
			lcMotivo = " porque es Sólo lectura."
		endif
*!*			if "<DESACTIVABLE>" $ this.ObtenerFuncionalidades() and !this.InactivoFW
*!*				lcMotivo = " porque está Activo."
*!*			endif
		if !_Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )
			lcMotivo = " porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica."
		endif
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "El registro de la entidad " + ;
				alltrim( this.cDescripcion ) + " no puede ser eliminado" + lcMotivo )
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function _EsEntidadQuePermiteNuevo() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		if !_Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )
			lcMotivo = " porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica."
		endif
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "La entidad " + ;
				alltrim( this.cDescripcion ) + " no permite hacer nuevo" + lcMotivo )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function _EsRegistroAnulable() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		if !_Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )
			lcMotivo = " porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica."
		endif
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "El registro de la entidad " + ;
				alltrim( this.cDescripcion ) + " no puede ser anulado" + lcMotivo )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeria( tcMensaje as String, tnCantidadDePasos as Integer ) as Void
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerNombre() as string
		return this.cNombre
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreOriginal() as string
		return this.ObtenerNombre()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoClavePrimaria() as string
		return this.cAtributoPK
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarEstimulos() as Void

	endfunc 
	*-----------------------------------------------------------------------------------------
	function AgregarEstimulo( tc1 ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function SeDebeEstimular() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		&& para los casos que una entidad es llama desde la herramienta ecommerce para que procese 
		&& todo el bloque de operaciones como un unico estimulo
		if pemstatus(this,"lVieneDeEcommerce",5) 
			llRetorno = llRetorno and !this.lVieneDeEcommerce
		endif
		llRetorno = llRetorno and inlist(this.cContexto,"","R")
		return llRetorno 
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Nuevo() As Boolean
		local loError as zooException OF zooException.prg
		
		with This
			try
				.lEnviaMailTiquetDeCambioEnSegundoPlano = .f.
				.lEnviaMailErroresSegundoPlanoHerramientaEcommerce = .f.
				._EntidadEditable()
				._EsEntidadQuePermiteNuevo()
				.lProcesando = .t.		
				.LimpiarInformacion()
				._Nuevo()
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.lProcesando = .f.
			endtry
		endwith 
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function SetearComponentes() as Void
	endfunc 
	
	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		this.AccionesAutomatizadas( 'AntesDeGrabar' )
		if This.lReAsignarPk_Con_CC
			if This.EsNuevo()
				This.ReasignarPK_Con_CC()
			EndIf
		endif
		Return dodefault()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EventoTalonarioLleno() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarDisponibilidadTalonario() as Void
		if vartype( this.oNumeraciones )=="O"
			if !this.oNumeraciones.TalonarioConNumeracionDisponible()
				this.EventoTalonarioLleno()
			endif
		endif
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function DespuesDeGrabar() As Boolean
		local loError as Exception, loEx as ZooException of ZooException.prg, llRetorno as Boolean
		llRetorno = .F.
		this.VerificarDisponibilidadTalonario()

		if ( "I" = this.cContexto )
			this.EnviarAccionesAutomatizadas( 'DespuesDeImportar' )
			llRetorno = .t.
			if this.CondicionesParaElEnvioDeeMailAlImportar()
				llRetorno = this.AccionesParaEnvioDeEMail()
			endif
		else
			this.EnviarAccionesAutomatizadas( 'DespuesDeGrabar' )
			llRetorno = this.AccionesParaEnvioDeEMail()
		endif	
		
		if this.SeDebeEstimular() and ( this.lNuevo or this.lEdicion )
			goServicios.RealTime.ProcesarBuffers( "Al Grabar Entidad " + this.cNombre )
		endif
		
		this.lEnviaMailTiquetDeCambioEnSegundoPlano = .f.
		this.lEnviaMailErroresSegundoPlanoHerramientaEcommerce = .f.

		return llRetorno  
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CondicionesParaElEnvioDeeMailAlImportar() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarElEnvioDeeMailAlImportarPorBuffer() as Boolean
		return ( this.cContexto = "I" and this.CondicionesParaElEnvioDeeMailAlImportar() )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearEnvioDeeMailAlImportarPorBuffer() as Void
		if this.ValidarElEnvioDeeMailAlImportarPorBuffer()
			this.oGestorDeMail.lAlmacenarEnBuffer = .t.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AccionesParaEnvioDeEMail() as Boolean
		llRetorno = .f.

		this.GenerarPDFsDespuesDeGrabar()
		llRetorno = this.ImprimirDespuesDeGrabar()
		if this.lHabilitaEnviarAlGrabar and this.lTieneDiseñosParaEnviarMail and !this.EvaluarEnvioDeMailEnProcesoPrevio()
			this.EnviarMailAlGrabar()
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarEnvioDeeMailAlImportarPorBuffer() as Void
		if this.ValidarElEnvioDeeMailAlImportarPorBuffer() 
			this.oGestorDeMail.ProcesarBuffer()
			this.oGestorDeMail.lAlmacenarEnBuffer = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EvaluarEnvioDeMailEnProcesoPrevio() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarAccionesAutomatizadas( tcMetodo as String ) as void
		local loEx as Object, loError as Object
		this.LoguearAccion()
		try
			this.AccionesAutomatizadas( tcMetodo )
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			loEx.Grabar( loError )
			if ( loEx.nZooErrorNo = 7123 )
				this.oMensaje.Advertir( loEx.Obtenerinformacion() )
			else
				loEx.Throw()
			endif
		endtry
	endfunc 


	*-----------------------------------------------------------------------------------------
***Codigo copiado del ent_comprobantedeventas, refactorizar
	Function Anular() as void
		Local lnCodigo As Integer, loError as Exception
			
		if at( "<ANULABLE>", this.ObtenerFuncionalidades() ) > 0
			with This
				try
					._EsRegistroAnulable()
					.lAnular = .T.
					.lEdicion = .F.
					.lNuevo = .F.
					.lProcesando = .t.
					.LimpiarInformacion()
					._Anular()
					.LanzarEventoPreguntarAnular()
					if .lAnular
						If .ValidarAntesDeAnular()
							.SetearColeccionSentenciasAnterior_ANULAR()
							lnCodigo = .Codigo
							.oAtributosAnulacion = .CrearObjeto( 'zooColeccion' )
							.ObtenerAtributosAnulacion()
							.AntesDeAnular()
							try
								.oAD.Actualizar()
							Catch To loError
								goServicios.Errores.LevantarExcepcion( loError )
							Finally
								.Codigo = lnCodigo
								.ActualizarEstado()
								.LoguearAccion()
								.DespuesDeAnular()
								.lAnular = .F.
							endtry
						else				
							.lAnular = .f.
							goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
						endif
					endif
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.lProcesando = .f.
				endtry
			endwith
		else
			this.Loguear("Se esta tratando anular la entidad " + this.ObtenerNombre() + " y la misma no es anulable.")
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	Function CargarAtributosAnulacion() As Void
		Local loItem as Object, lcEjecutar as String, loError as Exception, loEx as zooexception OF zooexception.prg

		With This
			.lCargando = .t.
			Try
				For Each loItem In this.oAtributosAnulacion
					lcEjecutar = "this." + alltrim( loItem.cAtributo ) + " = " + goLibrerias.ValorAStringAlAnular( loItem )
					&lcEjecutar
				Endfor
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			Finally
				.lCargando = .f.
			endtry 
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeAnular() as Void
		this.AccionesAutomatizadas( 'AntesDeAnular' )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeAnular() as Void
		if this.lWHModificar
			goServicios.WebHook.Enviar( this, 'MODIFICAR')
		endif
		
		if this.SeDebeEstimular() and this.lAnular
			goServicios.RealTime.ProcesarBuffers("Al Anular Entidad " + this.cNombre)
		endif

		this.AccionesAutomatizadas( 'DespuesDeAnular' )
	endfunc

	*-----------------------------------------------------------------------------------------
	function LanzarEventoPreguntarAnular() as Void
		this.EventoPreguntarAnular( "" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ValidarAntesDeAnular() As Boolean
		Local llRetorno as Boolean

		llRetorno = .T.
		if this.EstaAnulado()
			This.AgregarInformacion( "El comprobante ya se encuentra anulado" )
			llRetorno = .F.
		endif

		Return llRetorno
	Endfunc
	*-----------------------------------------------------------------------------------------
	protected function LoguearAccion() as Void
		local lcLogueo as String, lcPK as String, lcAtributo as String, lcFuncionalidades as String
		
		lcPk = this.cAtributoPK
		lcLogueo = ""
		lcFuncionalidades = this.ObtenerFuncionalidades()		

		if at( "<ANULABLE>", lcFuncionalidades ) > 0
			if this.lAnular 
				lcLogueo = lcLogueo + "Anular:"
			endif
		endif

		if empty( lcLogueo )
			do case
			case this.EsNuevo()
				lcLogueo = lcLogueo + "Nuevo:"
			case this.EsEdicion()
				lcLogueo = lcLogueo + "Modificar:"
			case this.lEliminar
				lcLogueo = lcLogueo + "Eliminar:"
			endcase
		endif

		lcLogueo = this.cNombre + " -> " + lcLogueo
		
		*****Obtener identificador del registro en cuestion
		if type( "this.oAtributosCC" ) = "O"
			for each lcAtributo in this.oAtributosCC
				lcLogueo = lcLogueo + " " + upper( lcAtributo ) + " " + alltrim( transform( this.&lcAtributo ) ) + ","
			endfor 
		endif
		if !empty( lcPk )
			lcLogueo = lcLogueo + " " + upper( lcPk ) + " " + alltrim( transform( this.&lcPk ) ) + "."
		endif
		
		this.loguear( lcLogueo )
		this.finalizarLogueo()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFuncionalidades() as String
		return ''
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAnulacion() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		
		if "<ANULABLE>" $ this.ObtenerFuncionalidades()
			if this.EstaAnulado()
			else
				llRetorno = .F.
				This.AgregarInformacion( "No se puede eliminar un comprobante no anulado" )
			endif 
		endif
		
		Return llRetorno
	endfunc 
	*-------------------------------------------------------------------------------------------------
	Function Eliminar() As void
		local loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		With This
			try
				if .ValidarAnulacion()
					._EntidadEditable()
					._EsRegistroEliminable()
					.lProcesando = .t.		
					.LimpiarInformacion()
					.EventoPreguntarEliminar()
					.EliminarSinValidaciones()
					if .lEliminar
						goServicios.RealTime.ProcesarBuffers("Al Eliminar Entidad " + this.cNombre)
						if this.lWHEliminar
							goServicios.WebHook.Enviar( this, 'ELIMINAR')
						endif
						.Limpiar()
					EndIf	
				else
					goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
				endif
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.lProcesando = .f.
			endtry
		endwith 
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected Function EliminarSinValidaciones() as Void
		This._EliminarSinValidaciones()
		this.LoguearAccion()		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarEliminar() as Void
		this.leliminar = .t.
		&&Evento disparado al eliminar
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarAnular( tcMensaje as String ) as Void
		&&Evento disparado al eliminar
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EstaAnulado() as Boolean
		return this.Anulado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RestaurarGenHabilitar() as Void
		*** Este método se genera
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function Limpiar( tlForzar as Boolean ) as void
		*** Este método se genera
	endfunc 
	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		local loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		With This
			try
				._EntidadEditable()
				._EsRegistroModificable()
				.lProcesando = .t.		
				.LimpiarInformacion()
				._Modificar()
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.lProcesando = .f.
			endtry
		endwith 
	Endfunc
	*-------------------------------------------------------------------------------------------------
	Function ValidarPK() As boolean
		Local llRetorno as Boolean, lcAtributo As String, lxValor As Variant
		
		llRetorno = .T.
		
		With This
			lcAtributo = .cAtributoPK
			lxValor = .&lcAtributo

			If Empty( lxValor )
				this.AgregarInformacion("Seleccione un registro",0)
				llRetorno = .F.
			Endif
		Endwith

		Return llRetorno
	Endfunc

	*-------------------------------------------------------------------------------------------------
	Function ValidacionBasica() As boolean
		local lRetorno
		if this.lIgnorarCamposObligatoriosDefinidosPorUsuario
			llRetorno = .T.
		else
			llRetorno = this.ValidarCamposObligatoriosDefinidosPorUsuario()
		endif
		llRetorno = llRetorno and this.ValidarAgrupamientoPublicaciones() 
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarAgrupamientoPublicaciones() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if pemstatus( this, "tipoAgrupamientoPublicaciones", 5 ) and pemstatus( this, "AgruPubliDetalle", 5 )
			if this.tipoAgrupamientoPublicaciones = 3 and this.VerificarAgruPubliDetalleSinDatos()
				this.AgregarInformacion( 'Se debe cargar un agrupamiento si la publicación es personalizada' )
				llRetorno = .f.
			endif
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarAgruPubliDetalleSinDatos() as Void
		local llRetorno as Boolean
		llRetorno = .f.
		if this.AgruPubliDetalle.Count = 0
			llRetorno = .T.
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColAtributosObligatoriosDefinidosPorUsuario_Access() as Object
		local loRetorno as Object
		
		loRetorno = null
		if !this.lDestroy		
			loRetorno = goServicios.SaltosDeCampoyValoresSugeridos.ObtenerColeccionAtributosObligatorios( this.ObtenerNombre() )
		endif
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposObligatoriosDefinidosPorUsuario() as Boolean
		local llRetorno as Boolean, loCol as zoocoleccion OF zoocoleccion.prg, lnI as Integer, ;
				lcAtributo as String, lcDescAtributo as String, lcDetalle as String

		llRetorno = .T.
		loCol = this.oColAtributosObligatoriosDefinidosPorUsuario

		for lnI = 1 to loCol.Count
			lcAtributo = loCol.Item( lnI ).cAtributo
			lcDescAtributo = loCol.Item( lnI ).cEtiqueta
			lcDetalle = alltrim( loCol.Item( lnI ).cDetalle )
			this.lOmiteObligatorioEnPack = loCol.Item( lnI ).lOmiteObligatorioEnPack
			if !this.EsAtributoObligatorioExistente( lcAtributo )
				llRetorno = this.EsValidoAtributoObligatorio( lcAtributo, lcDescAtributo, lcDetalle ) and llRetorno
			endif
		next		
		
		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function obtenerAtributosObligatorios() as ZooColeccion
		&& SE SOBREESCRIBE
		return null
	endfunc 
    	
	*-----------------------------------------------------------------------------------------
	protected function EsAtributoObligatorioExistente( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, loCol as zoocoleccion OF zoocoleccion.prg, lnI as Integer
		
		llRetorno = .F.
		loCol = this.obtenerAtributosObligatorios()
		if !isnull( loCol )
			for lnI = 1 to loCol.Count
				if upper( alltrim( tcAtributo ) ) == upper( alltrim( loCol.Item( lnI ) ) )
					llRetorno = .T.
					exit
				endif
			next
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsValidoAtributoObligatorio( tcAtributo as String, tcDescAtrib as String, tcDetalle as String ) as Boolean
		local llValido as Boolean, lcPosibleAtributoPk as String, lcPosibleAtributo as String, ;
			lcDetalle as string, loDetalle as Object, lcAtributo as String, lcOtroAtributo as String, lcMensajeAdvertencia As String
		llValido = .T.
	
		if empty( tcDetalle )
			lcPosibleAtributoPk = "this." + alltrim( tcAtributo ) + "_PK"
			if this.ExisteAtributoPk( lcPosibleAtributoPk )
				llValido = !Empty( &lcPosibleAtributoPk )
			else
				lcOtroAtributo = "this." + alltrim( tcAtributo )
				if this.ExisteAtributo( lcOtroAtributo )
					llValido = !Empty( this.&tcAtributo. )
				else
					llValido = .T.
				endif
			endif
			if !llValido
				lcMensajeAdvertencia = "Debe cargar el campo " + alltrim( tcDescAtrib ) + " de la entidad " + this.cNombre
				if This.VerificarContexto( "R" )
					this.Loguear( lcMensajeAdvertencia )
					this.finalizarLogueo()
				endif
				this.AgregarInformacion( lcMensajeAdvertencia, 9005, alltrim( upper( tcAtributo ) ) )
			endif
		else
			lcDetalle = "this." + alltrim( tcDetalle )
			lcAtributo = alltrim( tcAtributo )
			lcPosibleAtributo =  lcDetalle + ".oItem." + lcAtributo
			lcPosibleAtributoPk = lcPosibleAtributo + "_PK"
			if this.ExisteAtributoPk( lcPosibleAtributoPk )
				lcAtributo = lcAtributo + "_PK"
			endif
			loDetalle = &lcDetalle
			llValido = this.ValidarCampoObligatorioEnDetalle( loDetalle, lcAtributo, "Articulo_Pk" )
			if !llValido
				this.AgregarInformacion( "Debe cargar el campo " + alltrim( tcDescAtrib ) + " en todos los elementos obligatorios del detalle." )
			endif
		endif
			
		return llValido
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarCampoObligatorioEnDetalle( toDetalle as Object, tcAtributo as String, tcAtributoPrincipal as string ) as Boolean
		local lnI as Integer, llRetorno as Boolean, llespack as boolean
		
		llRetorno = .T.
		for lnI = 1 to toDetalle.count
			llespack = this.EsItemPack( toDetalle, lnI )
		    if !this.EsItemSenia( toDetalle, lnI ) and !this.EsItemGiftCard( toDetalle, lnI ) 
			    if !llespack or ( llespack and !this.lOmiteObligatorioEnPack )
					if toDetalle.ValidarExistenciaCamposFijosItemPlano( lnI ) and empty( toDetalle.Item[ lnI ].&tcAtributo )
						llRetorno = .F.
						exit
					endif
			 	endif
			endif
		next
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsItemSenia( toDetalle as Object, tnItem as Integer ) as Void
		local llRetorno as Boolean
		llRetorno = .f.
		if type( "toDetalle.oItem.oCompSenias" ) == "O" and !isnull( toDetalle.oItem.oCompSenias )
			if empty( tnItem ) or tnItem = toDetalle.oItem.NroItem
				loItem = toDetalle.oItem
			else
				loItem = toDetalle.Item[ tnItem ]
			endif
			llRetorno = toDetalle.oItem.oCompSenias.VerificarSiEsItemSenia( loItem  ) or toDetalle.oItem.oCompSenias.VerificarSiEsItemCancelacionSenia( loItem  )
		endif
		return llRetorno
	endfunc 
    *-----------------------------------------------------------------------------------------
	protected function EsItemPack( toDetalle as Object, tnItem as Integer ) as Void
		local llRetorno as Boolean
		llRetorno = .f.
			if empty( tnItem ) or tnItem = toDetalle.oItem.NroItem
				loItem = toDetalle.oItem
			else
				loItem = toDetalle.Item[ tnItem ]
			endif
			
			if pemstatus( loItem, "comportamiento", 5 )
				llRetorno = iif(loItem.comportamiento=5,.T.,.F.)
			endif
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function EsItemGiftCard( toDetalle as Object, tnItem as Integer ) as Void
		local llRetorno as Boolean
		llRetorno = .f.
		if type( "toDetalle.oItem.oCompGiftCard" ) == "O" and !isnull( toDetalle.oItem.oCompGiftCard )
			if empty( tnItem ) or tnItem = toDetalle.oItem.NroItem
				loItem = toDetalle.oItem
			else
				loItem = toDetalle.Item[ tnItem ]
			endif
			llRetorno = toDetalle.oItem.oCompGiftCard.VerificarSiEsItemGiftCard( loItem  ) 
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteAtributoPk( tcAtributoPk as String ) as Boolean
		local llRetorno as Boolean, lcAtributoPk as String 
		
		try
			probarAtributo = &tcAtributoPk
			llRetorno = .T.
		catch
			llRetorno = .F.
		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteAtributo( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, lcAtributo as String, probarAtributo as Variant
		try
			probarAtributo = &tcAtributo
			llRetorno = .T.
		catch
			llRetorno = .F.
		endtry
		
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Validar() As boolean
		local llValidacion as Boolean, llConsulta as Boolean
		With This
			llValidacion = .ValidacionBasica()
			if llValidacion
				llConsulta = .ValidarExistencia()
				If llConsulta And .lNuevo
					this.AgregarInformacion( "El código a grabar ya existe", 0 )
					llValidacion = .F.
				Endif
				If !llConsulta And .lEdicion And !.lNuevo
					this.AgregarInformacion( "El código a grabar no existe", 0 )
					llValidacion = .F.
				Endif
			endif
		endwith
		llValidacion = this.ValidarExtension() and llValidacion

		if llValidacion
			llValidacion = llValidacion and this.ValidacionesCompuestas()
		endif

		Return llValidacion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidacionesCompuestas() as Boolean
		local llRetorno as Boolean, loValidador as Validador of Validador.prg
	
		llRetorno = .t.

		try
			for each loValidador in This.oValidadoresComp
				llRetorno = llRetorno and loValidador.Validar( This )
				
				if !llRetorno
					exit
				endif
			endfor
		catch
			llRetorno = .f. && ??
		endtry	
	
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oValidadoresComp_Access() as Object

		if !this.lDestroy and !( vartype( this.oValidadoresComp ) == "O" )
			this.oValidadoresComp = _screen.Zoo.Crearobjeto( "ZooColeccion" )
		endif
		
		return this.oValidadoresComp

	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarValidador( loValidador as Object ) as Void
		this.oValidadoresComp.Agregar( loValidador )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ValidarExtension() as Boolean
		local llRetorno as Boolean, loExt as Object

		llretorno = .t.

		try
			for each loExt in This.oExtension
				llretorno = loExt.lRetorno and llRetorno
			endfor
		catch
		endtry
		
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------
	protected Function ValidarExistencia() As Boolean
		&& Esto esta sobreescrito en las entidades cuya claveprimaria tiene numeracion
		local llRetorno as Boolean
		llRetorno = .t.

		if this.EsNuevo() and This.DebeSugerirCodigo()
			llRetorno = .f.
		else
			llRetorno = This.oAd.ConsultarPorClavePrimaria()
		endif
		
		return llRetorno
	endfunc
	
	*-------------------------------------------------------------------------------------------------
	Function Cancelar() As void
		local loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		With This
			try
				.lProcesando = .t.		
*				.LimpiarInformacion()
				._Cancelar()
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.lProcesando = .f.
			endtry
		endwith 
	Endfunc

	*-------------------------------------------------------------------------------------------------
	Function Primero() As Boolean
		Local	llRetorno As Boolean, loError as zooException OF zooException.prg, ;
				loEx as zooException OF zooException.prg
		
		llRetorno = .F.
		try
			With This
				.LimpiarInformacion()
				.oAD.Primero()
				llRetorno = .Cargar()
				Store .F. To .lEdicion, .lNuevo, .lAnular
			Endwith
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		Finally
		EndTry

		Return llRetorno
	Endfunc

	*-------------------------------------------------------------------------------------------------
	Function Anterior () As Boolean
		Local	lcAtributo As String,	lxValor As Variant, llRetorno As Boolean, ;
				loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		llRetorno = .F.
		try
			With This
				.LimpiarInformacion()
				lcAtributo = .cAtributoPK
				lxValor = .&lcAtributo
				If Empty( lxValor )
					llRetorno = .Primero()
				Else
					.oAD.Anterior()
					llRetorno = .Cargar()
					Store .F. To .lEdicion, .lNuevo, .lAnular
				Endif
			Endwith
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		Finally
		EndTry

		Return llRetorno
	Endfunc
	*-------------------------------------------------------------------------------------------------
	Function Siguiente () As Boolean
		Local	lcAtributo As String, lxValor As Variant, llRetorno As Boolean, ;
				loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		llRetorno = .F.
		try
			With This
				.LimpiarInformacion()
				lcAtributo = .cAtributoPK
				lxValor = .&lcAtributo
				If Empty( lxValor )
					llRetorno = .Primero()
				Else
					.oAD.Siguiente()
					llRetorno = .Cargar()
					Store .F. To .lEdicion, .lNuevo, .lAnular
				Endif
			Endwith
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		Finally
		EndTry

		Return llRetorno
	Endfunc
	*-------------------------------------------------------------------------------------------------
	Function Ultimo () As Boolean
		Local	llRetorno As Boolean,	loError as zooException OF zooException.prg, ;
			 	loEx as zooException OF zooException.prg
		Try
			With This
				.LimpiarInformacion()
				.oAD.Ultimo()
				llRetorno = .Cargar()
				Store .F. To .lEdicion, .lNuevo, .lAnular
			Endwith
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		Finally
		EndTry

		Return llRetorno
	Endfunc
	*--------------------------------------------------------------------------------------------------------
	function Buscar( ) as Void
		return This._Buscar()
	EndFunc	
	*-----------------------------------------------------------------------------------------
	Function EsNuevo() As Boolean
		Return This.lNuevo
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function EsEdicion() As Boolean
		Return This.lEdicion
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function HayDatos() As Boolean
		local llHayDatos as Boolean
		if vartype( This.oAD ) = "O"
			llHayDatos = This.oAD.HayDatos( )
		endif
		return llHayDatos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CambioSumarizado() as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerProximoNumeroEnString() as String
		local lcCampo as String, lcXml as String, lcPK as string, lcMaximo as string, lcProximoValor as string
		
		lcPK = Alltrim( This.cAtributoPK )
		lcXml = this.oAD.ObtenerDatosTabla( lcPK, , , "max" )
				
		this.xmlACursor( lcXml, "c_Valores" )
		
		lcMaximo = nvl( evaluate( "c_Valores.max_" + lcPK ), "0" )
			
		lcProximoValor = padl( alltrim( str( val( lcMaximo  ) + 1 )), len( evaluate( "c_Valores.max_" + lcPK ) ), "0" )

		use in select( "c_Valores" )

		return lcProximoValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIngreso( tcTexto as string, tlPermiteCaracterEspecial as boolean ) as boolean
		local llRetorno as Boolean, lnLargoCadena as integer, lcCaracter as string , ;
			lnNumeroCaracter as Integer

		lnLargoCadena = 0
		lnNumeroCaracter = 1
		lcCaracter = ""
		llRetorno = .t.
		
		if empty(tcTexto)
		else
			lnLargoCadena = len( alltrim( tcTexto ) )
			do while( lnNumeroCaracter <= lnLargoCadena and llRetorno )
				lcCaracter = substr( tcTexto, lnNumeroCaracter, 1 )
				llRetorno = this.ValidarCaracter( lcCaracter, tlPermiteCaracterEspecial )
				lnNumeroCaracter = lnNumeroCaracter + 1 
			enddo
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarCaracter(tcCaracter as Character, tlPermiteCaracterEspecial as Boolean ) as Boolean
		local lcCaracteres  as string
	
		if empty( this.cCaracteres )
			this.cCaracteres = this.ObtenerCaracteresValidos()
		endif
		lcCaracteres = this.cCaracteres
		
		if tlPermiteCaracterEspecial 
			lcCaracteres = lcCaracteres + "+?"
		endif
		
		return occurs( tcCaracter, lcCaracteres ) > 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCaracteresValidos() as Void
		return goLibrerias.ObtenerCaracteresValidos( this.lPermiteMinusculasPK )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function CargaManual() as Void
		return !This.lCargando and !This.lLimpiando and !This.lDestroy
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasDelete() as zoocoleccion OF zoocoleccion.prg
		return this.oAD.ObtenerSentenciasDelete() 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasInsert() as zoocoleccion OF zoocoleccion.prg
		if This.lReAsignarPk_Con_CC
			This.ReAsignarPk_Con_CC()
		EndIf	
		return this.oAD.ObtenerSentenciasInsert() 
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasUpdate() as zoocoleccion OF zoocoleccion.prg
		this.FechaModificacionFW = goServicios.Librerias.ObtenerFecha()
		this.HoraModificacionFW = goServicios.Librerias.ObtenerHora()
		this.UsuarioModificacionFW = alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() )
		this.SerieModificacionFW = alltrim( _screen.Zoo.App.cSerie )
		this.BaseDeDatosModificacionFW = alltrim( _screen.Zoo.App.cSucursalActiva )
		this.VersionModificacionFW = alltrim( _screen.zoo.app.ObtenerVersion() )
		return this.oAD.ObtenerSentenciasUpdate() 
	endfunc 	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcion() as String 
		return this.cDescripcion
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoNUEVO( tcEstado as String ) as void
		**Esta escrito en el generado
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoELIMINAR( tcEstado as String ) as void
		**Esta escrito en el generado
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoModificar( tcEstado as String ) as void
		**Esta escrito en el generado
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoCANCELAR( tcEstado as String ) as void
		**Esta escrito en el generado
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoGRABAR( tcEstado as String ) as void
		**Esta escrito en el generado
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoANULAR( tcEstado as String ) as void
		**Esta escrito en el generado
	endfunc
	*--------------------------------------------------------------------------------------------------------
	function actualizarEstado() as void
		**Esta escrito en el generado
	endfunc	
	*-----------------------------------------------------------------------------------------
	function VerificarContexto( tcTipos as String ) as boolean
		local llRetorno as boolean, i as Integer, lcLetra as string
		
		if empty( tcTipos )
			llRetorno = empty( this.cContexto )
		else
			tcTipos = upper( alltrim( tcTipos ) )
			llRetorno = .f.
			for i = 1 to len( tcTipos )
				lcLetra = substr( tcTipos, i, 1 )
				llRetorno = ( lcLetra $ this.cContexto ) or llRetorno
				if llRetorno
					exit
				endif
			endfor 
		endif
		
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	Protected function _Nuevo() as Void
	*** Este método se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function _Modificar() as Void
	*** Este método se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function _EliminarSinValidaciones() as Void
	*** Este método se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function _Cancelar() as Void
	*** Este método se genera
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as Void
	*** Este método se sobrescribe
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaEnProceso() as Boolean
		local lRetorno as Boolean

		with this
			lRetorno = ( .lProcesando or .lCargando or .lLimpiando or .lDestroy )
		endwith

		return lRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Imprimir() as Boolean
		local llRetorno as Boolean, loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		llRetorno = .F.
		with this
			.LimpiarInformacion()
			try
				llRetorno = goServicios.Impresion.imprimir( this )
				if llRetorno
					this.AccionesAutomatizadas( 'Imprimir' )
				endif
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			Finally
			endtry 
		endwith
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPdf() as Boolean
		local llRetorno as Boolean, loError as zooException OF zooException.prg, loEx as zooException OF zooException.prg
		llRetorno = .F.
		with this

			if .PermiteGenerarPdf()
				.LimpiarInformacion()
				Try
					goServicios.Impresion.GenerarPdfDesdeMenu( this )
					llRetorno = .T.
				Catch To loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.BorrarArchivoQR()
				endtry 
			else
				if this.HayInformacion()
					goServicios.Mensajes.Advertir( this.ObtenerInformacion() )
				endif
			endif
		endwith
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PermiteGenerarPdf() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarPorClaveCandidata() as Boolean
		return This.oAd.ConsultarPorClaveCandidata()
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function _Buscar() as Void
		&&Se Genera
	endfunc 
	*-----------------------------------------------------------------------------------------
	function BorrarArchivoQR() as Void
		&&sobreescrita en comprobantes electronicos
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function Recibir( toListaTablas as zoocoleccion OF zoocoleccion.prg, tlLoguear as Boolean ) as Void
		this.BindearEvento( This.oAd, "EventoAntesDeFinalizarRecibir", this, "AntesDeFinalizarRecibir" )
		This.oAd.Recibir( toListaTablas, tlLoguear  )
		this.DesBindearEvento( This.oAd, "EventoAntesDeFinalizarRecibir", this, "AntesDeFinalizarRecibir" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AntesDeFinalizarRecibir() as Void
		*** Este método se sobrescribe
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oObservadoresDeImportacion_Access() as variant
		if !this.ldestroy and ( !vartype( this.oObservadoresDeImportacion ) = 'O' or isnull( this.oObservadoresDeImportacion ) )
			this.oObservadoresDeImportacion = _Screen.zoo.crearobjeto( 'ZooColeccion' )
		endif
		return this.oObservadoresDeImportacion 
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarObservadorDeImportacion( toProcesoImportacion as ProcesoImportacion of ProcesoImportacion.prg ) as Void
		this.oObservadoresDeImportacion.Agregar( toProcesoImportacion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InformarErroresImportacion( tcCursorInformacionErrores as String ) as Void
		local lnI as Integer 
		
		for lnI = 1 to this.oObservadoresDeImportacion.Count
			this.oObservadoresDeImportacion.Item[lnI].InformarErroresImportacion( tcCursorInformacionErrores )
		endfor

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Importar( tcXmlDatos as String, tlCompletoConValidaciones as Boolean ) as Void
		This.oAd.Importar( tcXmlDatos, tlCompletoConValidaciones )
	endfunc  

	*-----------------------------------------------------------------------------------------
	function Importar_SinTransaccion( tcXmlDatos as String ) as Void
		This.oAd.lProcesarConTransaccion = .F.
		This.oAd.Importar( tcXmlDatos )
		This.oAd.lProcesarConTransaccion = .T.
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstado() as String
		local lcEstado as String
		with this	
			do case
				case .EsNuevo() and !.EsEdicion()
					lcEstado = "NUEVO"
				case !.EsNuevo() and .EsEdicion()
					lcEstado = "EDICION"				
				otherwise
					lcEstado = "NULO"
			endcase
		endwith		
		return lcEstado
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InicializarComponentes( tlLimpiar as Boolean ) as Void
		dodefault( tlLimpiar )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarAtributosVirtuales() as void
		*** Este método se genera
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReasignarPk_Con_CC() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSiguienteNumerico() as Integer
		local lcXml as String, lnMaximo as Integer, lcCursor as String , lcPk as String, lcCampo as String   
		lcCursor = sys(2015)
		lcPK = Alltrim( This.cAtributoPK )
		lcXml = this.oAD.ObtenerDatosEntidad( lcPk, , , "Max" )
		this.xmlACursor( lcXml, lcCursor )
		lcCampo = alltrim( lcCursor ) + ".max_" + lcPk
		lnMaximo = nvl( &lcCampo , 0 ) + 1	
		use in select( lcCursor )
		return lnMaximo
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ObtenerCantidadRegistros() as integer
		return this.oAD.ObtenerCantidadRegistros()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeRegistrosConFiltro( tcHaving As String ) as Void
		local lcXml as String, lcCursor as String, lnCantidad as Integer
		lcXml = this.oAd.ObtenerDatosEntidad( "", tcHaving )
		lcCursor = sys(2015)
		this.xmlACursor( lcXml, lcCursor )
		select( lcCursor )
		lnCantidad = reccount( lcCursor )
		use in select(lcCursor)
		return lnCantidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosEntidad( tcAtributos As String, tcHaving As String, tcOrder As String , tcFunc As String, tnTope as Integer ) As String
		local lcXml as String
		lcXml = this.oAD.ObtenerDatosEntidad( tcAtributos, tcHaving, tcOrder, tcFunc, tnTope )
		return lcXml
	endfunc

		*-----------------------------------------------------------------------------------------
	function DebeCrearValoresParaAtributos() as Boolean
		*return !this.VerificarContexto("C") and !this.VerificarContexto("B")
		return !this.VerificarContexto( 'CB' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FechaAltaFW_Access() as Date

		if !this.ldestroy and this.EsNuevo() and this.DebeCrearValoresParaAtributos()
			This.FechaAltaFW = goServicios.Librerias.ObtenerFecha()
		endif
		return This.FechaAltaFW
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HoraAltaFW_Access() as String
		
		if !this.ldestroy and this.EsNuevo() and this.DebeCrearValoresParaAtributos()
			this.HoraAltaFW = goLibrerias.ObtenerHora()
		endif
		return this.HoraAltaFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function UsuarioAltaFW_Access() as Date

		if !this.lDestroy and this.EsNuevo() and this.DebeCrearValoresParaAtributos()
			This.UsuarioAltaFW = alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() ) + this.UsuarioAutorizante()
		endif
		return This.UsuarioAltaFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function SerieAltaFW_Access() as Date

		if !this.lDestroy and this.EsNuevo() and this.DebeCrearValoresParaAtributos()
			This.SerieAltaFW = alltrim( _screen.Zoo.App.cSerie )
		endif
		return This.SerieAltaFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function BaseDeDatosAltaFW_Access() as Date

		if !this.lDestroy and this.EsNuevo() and this.DebeCrearValoresParaAtributos()
			This.BaseDeDatosAltaFW = alltrim( _screen.Zoo.App.cSucursalActiva )
		endif
		return This.BaseDeDatosAltaFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function VersionAltaFW_Access() as String 

		if !this.lDestroy and this.EsNuevo() and this.DebeCrearValoresParaAtributos()
			This.VersionAltaFW = _screen.zoo.app.ObtenerVersion()
		endif
		return This.VersionAltaFW
		
	endfunc


	*-----------------------------------------------------------------------------------------	
	function FechaModificacionFW_Access() as Date
		if !this.ldestroy and ( This.EsNuevo() or This.EsEdicion() or this.lAnular ) and this.DebeCrearValoresParaAtributos()
			This.FechaModificacionFW = goServicios.Librerias.ObtenerFecha()
		endif
		return This.FechaModificacionFW
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HoraModificacionFW_Access() as String

		if !this.ldestroy and ( This.EsNuevo() or This.EsEdicion() or this.lAnular ) and this.DebeCrearValoresParaAtributos()
			this.HoraModificacionFW = goServicios.Librerias.ObtenerHora()
		endif
		return this.HoraModificacionFW
	endfunc

	*-----------------------------------------------------------------------------------------
	function UsuarioModificacionFW_Access() as Date

		if !this.lDestroy and ( This.EsNuevo() or This.EsEdicion() ) and this.DebeCrearValoresParaAtributos()
			This.UsuarioModificacionFW = alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() )  + this.UsuarioAutorizante()
		endif
		return This.UsuarioModificacionFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function SerieModificacionFW_Access() as Date

		if !this.lDestroy and ( This.EsNuevo() or This.EsEdicion() ) and this.DebeCrearValoresParaAtributos()
			This.SerieModificacionFW = alltrim( _screen.Zoo.App.cSerie )
		endif
		return This.SerieModificacionFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function BaseDeDatosModificacionFW_Access() as Date

		if !this.lDestroy and ( This.EsNuevo() or This.EsEdicion() ) and this.DebeCrearValoresParaAtributos()
			This.BaseDeDatosModificacionFW = alltrim( _screen.Zoo.App.cSucursalActiva )
		endif
		return This.BaseDeDatosModificacionFW
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function VersionModificacionFW_Access() as String

		if !this.lDestroy and ( This.EsNuevo() or This.EsEdicion() ) and this.DebeCrearValoresParaAtributos()
			This.VersionModificacionFW = _screen.zoo.app.ObtenerVersion()
		endif
		return This.VersionModificacionFW
		
	endfunc

	

	*-----------------------------------------------------------------------------------------
	function ErrorAlGrabar() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ErrorAlValidar() as Void
	endfunc

	*-----------------------------------------------------------------------------------------

	function ObtenerAtributosCombinacion() as Void
		local loColRetorno as object
		
		loColRetorno = _screen.zoo.CrearObjeto( 'zooColeccion' )
		return loColRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TransformarAlAsignar( txVal as Variant ) as Variant

		return txVal 
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function PermiteEjecutarTriggers() as boolean
	
		*-- Mètodo para escribir validaciones que permitan o no ejecutar los triggers
	
		local llRetorno as Boolean 
		
		llRetorno = .T.
		
		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function InstanciarExtension() as void
		Local lcNombreObj as Object, loObj as Object, loExt as Object, loColExt as zoocoleccion OF zoocoleccion.prg,;
				lcRutaExtensiones as String, lcUltimaExtension as String, lcRuta as String 

		lcRuta = alltrim( addbs( _Screen.zoo.cRutaInicial ) + "Personal\" )
		lcUltimaExtension = ""
		lcNombreObj =  "Ext_" + This.ObtenerNombre()
		lcRutaExtensiones = lcRuta + lcNombreObj

		loColExt = This.ObtenerExtensiones( lcRutaExtensiones )

		if loColExt.Count > 0
			This.oExtension = _screen.zoo.crearobjeto( "zoocoleccion" )			
		endif
		
		for each loExt in loColExt 
			if lcUltimaExtension = upper( alltrim( juststem( loExt ) ) )
			else
				try
					loObj = _screen.zoo.crearobjeto( Getwordnum( loExt, 1, '.' ), lcRuta + loExt;
							 , This )
					This.oExtension.Add( loObj )
					lcUltimaExtension = upper( alltrim( juststem( loExt ) ) )
				catch to loError
				endtry
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerExtensiones( tcRuta as String ) as zoocoleccion OF zoocoleccion.prg
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, lnCantExt as Integer
			loColRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
			lnCantExt = adir( laExt, alltrim( tcRuta ) + "_*.*" )
			if lnCantExt > 0
				for i = 1 to alen( laExt, 1 )
					if this.EsExtensionValidaParaFox( laExt( i, 1 ) )
						loColRetorno.Add( laExt( i, 1 ) )
					endif
				endfor
			endif
		return loColRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsExtensionValidaParaFox( tcNombre as string ) as Boolean
		local llRetorno as Boolean, lcExtension as string, loColExtensionesValidas as zoocoleccion OF zoocoleccion.prg
		
		llRetorno = .F.
		
		if !empty( tcNombre )			
			lcExtension = substr( tcNombre, at( ".", tcNombre ) )
			loColExtensionesValidas = this.ObtenerExtensionesValidasParaFox()
			for each lcExt in loColExtensionesValidas
				if upper( lcExt ) == upper( lcExtension )
					llRetorno = .T.
					exit
				endif
			next
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerExtensionesValidasParaFox() as zoocoleccion OF zoocoleccion.prg
		local loCol as zoocoleccion OF zoocoleccion.prg
		
		loCol = _screen.zoo.CrearObjeto( "ZooColeccion" )
		loCol.Agregar( ".FXP" )
		loCol.Agregar( ".PRG" )

		return loCol
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Cargar() as Boolean
		Return This.oAd.Cargar()
	endfunc
	
	*-----------------------------------------------------------------------------------------			
	function ImprimirDespuesDeGrabar() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.EsNuevo() and ( this.DeboImprimir() or this.DebeImprimirDisenosAutomaticamente() ) and !this.VerificarContexto( 'CBI' )
			llRetorno = this.Imprimir()	
		endif 				
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------			
	protected function GenerarPDFsDespuesDeGrabar() as ZooColeccion of ZooColeccion.Prg
		if this.EsNuevo() and ( this.DebeGenerarPDFsDeDisenosAutomaticamente() ) and !this.VerificarContexto( 'CBI' )
			goServicios.Impresion.GenerarPDFsAlGrabarEntidad( this )
		endif 				
	endfunc

	*-----------------------------------------------------------------------------------------				
	protected function DeboImprimir() as Boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------				
	function DebeImprimirDisenosAutomaticamente() as Boolean
		*!* Se delega esta tarea al manager de impresión ya que este tiene una lógica optimizada
		*!* para determinar esto sin tener que instanciar la entidad DisenoImpresion.
		return goServicios.Impresion.DebeImprimirDisenosAutomaticamente( this )
	endfunc

	*-----------------------------------------------------------------------------------------				
	function DebeGenerarPDFsDeDisenosAutomaticamente() as Boolean
		return goServicios.Impresion.DebeGenerarPDFsDeDisenosAutomaticamente( this )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IniciarAccionesAutomaticas() as Void
		this.lTieneAccionesAutomaticas = goServicios.Entidades.AccionesAutomaticas.LaEntidadTieneAccionesAutomaticas( this.cNombre )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AccionesAutomatizadas( tcMetodo as String ) as Void
		if this.lTieneAccionesAutomaticas
			goServicios.Entidades.AccionesAutomaticas.EjecutarAccionesAutomaticasSegunEntidadMetodo( this, tcMetodo )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarUnDetalle( toDetalle as detalle OF detalle.prg, tcEtiqueta as String ) as Boolean
		local llRetorno as Boolean

		llRetorno = .T.

		toDetalle.cContexto = this.cContexto

		if toDetalle.ValidacionDetalleObligatorio()
		else
			llRetorno = .F.
			this.AgregarInformacion( "El detalle " + alltrim( tcEtiqueta ) + " debe contener al menos un ítem cargado." )
		endif
		
		if toDetalle.validar()
		else
			llRetorno = .F.
		endif
		
		return llRetorno
	endfunc 	

 	*-----------------------------------------------------------------------------------------
	function ActualizarProgressBar( tnValor as Integer ) as void
	endfunc 

	
	*--------------------------------------------------------------------------------------------------------
	Function ObtenerAtributosAnulacion() As void
		local loColaboradorAnulacion as object, loAtributos as zooColeccion of zooColeccion.prg,;
			loAtributo as itemAtributoAnulacion of ItemAtributoAnulacion.prg, lcAtributo as string
			
		loAtributos = this.oProveedorAtributosAnulacion.ObtenerAtributosAnulacion()
		
		for each loAtributo in loAtributos
			lcAtributo = loAtributo.cAtributo
			loAtributo.xValor = this.&lcAtributo.
		endfor

		loAtributos.Item[ "ANULADO" ].xValor = .T.
		
		this.oAtributosAnulacion = loAtributos
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoAdvertirLimitePorDiseno( toInfoAuxiliar ) as Void
		&&Evento disparado desde el detalle para advertir que alcanzó el limite segun el diseño de impresión
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoCancelarCargaLimitePorDiseno( tcDetalle as String ) as Void
		&&Evento disparado desde el detalle para advertir que alcanzó el limite segun el diseño de impresión
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoVerificarLimitesEnDisenoImpresion( tcDetalle as String ) as Void

	endfunc 
	*-----------------------------------------------------------------------------------------
	function VerificarLimitesEnDisenoImpresion( tcDetalle as String ) as Void
		local loLimite as Object, lcCadena as String
		loLimite = goServicios.Impresion.ObtenerObjetoConLimitesDeImpresion( this, tcDetalle )
		if isnull( loLimite )
			lcCadena = "This." + tcDetalle + ".nLimiteSegunDisenoImpresion = 0"
			&lcCadena
			lcCadena = "This." + tcDetalle + ".nTipoDeValidacionSegunDisenoImpresion = 0"
			&lcCadena
			lcCadena = "This." + tcDetalle + ".cDisenoLimitador = ''"
			&lcCadena
			lcCadena = "This." + tcDetalle + ".cAtributosAgrupamiento = ''"
			&lcCadena
		else
			lcCadena = "This." + tcDetalle + ".nLimiteSegunDisenoImpresion = " + transform( loLimite.Limite )
			&lcCadena
			lcCadena = "This." + tcDetalle + ".nTipoDeValidacionSegunDisenoImpresion = " + transform( loLimite.Restriccion )
			&lcCadena
			lcCadena = "This." + tcDetalle + ".cDisenoLimitador = '" + alltrim( loLimite.diseno ) + "'"
			&lcCadena
			lcCadena = "This." + tcDetalle + ".cAtributosAgrupamiento = '" +  alltrim( loLimite.AtributosAgrupamiento ) + "'"
			&lcCadena
		endif
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ConsultarPorClavePrimariaSugerida() as Boolean
		local llRetorno as Boolean, lcClaveOriginal as Variant, lcAtributoClavePrimaria as String 
		llRetorno = .f.
		
		with This as entidad OF entidad.prg

			lcAtributoClavePrimaria = .ObtenerAtributoClavePrimaria()
			lcClaveOriginal = .&lcAtributoClavePrimaria 

			lcEjecutar = "this." + alltrim( lcAtributoClavePrimaria ) + " = [" + This.oComportamientoCodigoSugerido.FormatearCodigoSugerido( lcClaveOriginal ) + "]"
			&lcEjecutar

			llRetorno = .oAD.ConsultarPorClavePrimaria()
			if llRetorno 
			else
				lcEjecutar = "." + alltrim( lcAtributoClavePrimaria ) + " = [" + lcClaveOriginal + "]"
				&lcEjecutar
			endif
		endwith
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function oComportamientoCodigoSugerido_Access() as Void
		local loComportamientoCodigoSugerido as Object
		if !this.ldestroy and !vartype( this.oComportamientoCodigoSugerido ) = 'O'
			loComportamientoCodigoSugerido = _Screen.zoo.CrearObjeto( "DecoradorDeCodigosDeEntidades" )
			this.InicializarComportamientoCodigoSugerido(loComportamientoCodigoSugerido )
			this.oComportamientoCodigoSugerido = loComportamientoCodigoSugerido
		endif
		return this.oComportamientoCodigoSugerido
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InicializarComportamientoCodigoSugerido( toComportamientoCodigoSugerido as Object ) as Void
		if !toComportamientoCodigoSugerido.CargarComportamiento( upper( This.ObtenerNombre() ) )
			toComportamientoCodigoSugerido.Sugerir = This.lInicializarCodigoSugeridoHabilitado
			This.InicializandoEntidadComportamientoSugerido( toComportamientoCodigoSugerido )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeSugerirCodigo() as Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaClavePrimaria( txVal as Variant ) as Boolean
		return this.oAd.VerificarExistenciaClavePrimaria( txVal )
	endfunc

	*-----------------------------------------------------------------------------------------
	function FormatearCodigoSugerido( txVal as String ) as String
		return This.oComportamientoCodigoSugerido.FormatearCodigoSugerido( txVal )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SoportaBusquedaExtendida( txVal as Variant ) as boolean
		return This.oComportamientoCodigoSugerido.SoportaBusquedaExtendida() 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InicializandoEntidadComportamientoSugerido( toEntidadComportamientoSugerido as entidad OF entidad.prg ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreTransferencia() as String
		return this.ObtenerNombre()
	endfunc

	*-----------------------------------------------------------------------------------------
	function AjustarObjetoBusqueda( toBusqueda as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneDetallesConPrePantalla() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReasignarValorSugeridoEnCasoDeConcurrencia() as string
		local lxCod as Variant, lcAtributo as string, lcRetorno as string
		
		lcRetorno = ""
		lcAtributo = this.ObtenerAtributoClavePrimaria()

		if this.DebeSugerirCodigo()
			lxCod = this.&lcAtributo

			this.SetearCodigoSugerido()

			if !this.oComportamientoCodigoSugerido.EsCodigoConSaltoDeCampoDefinidoPorElUsuario( this )
				lcRetorno = 'El código ' + transform( lxCod ) + ' ya existe. Se ha asignado el próximo disponible.'
			endif
		else
			lcRetorno = 'La clave primaria a grabar ya existe'
		endif

		return lcRetorno  
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneDetalleComprobanteCargado() as Boolean
		return .f. && Se sobreescribe en ent_comprobante
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDetalleAfectacioInfoAdicional() as object 
		return this.Compafec
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadItemsInfoAdicional() as Integer 
		local lnRetorno as Integer, loDetAfec as Object 
		lnRetorno = 0
		loDetAfec = this.ObtenerDetalleAfectacioInfoAdicional()
		if vartype( loDetAfec ) = "O"
			lnRetorno = loDetAfec.count
		endif
		return lnRetorno 	

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMensajeClaveCandidataExistente() as String
		return "La clave candidata a grabar ya existe"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarMail( tlNoPreguntarConfirmaEnvioDeMail as Boolean ) as Void
		this.oGestorDeMail.EnviarDesdeFormulario( this, tlNoPreguntarConfirmaEnvioDeMail )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarMailAlGrabar() as Void
		try
			if this.oGestorDeMail.lAlmacenarEnBuffer 
				this.oGestorDeMail.EnviarMailAlGrabar( this, .t. )
			else
				this.oGestorDeMail.EnviarMailAlGrabar( this )
			endif
			this.lTieneDiseñosParaEnviarMail = this.oGestorDeMail.lTieneDiseños
		catch to loError
			goServicios.mensajes.enviar( loError )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsAtributoEditableEnEntidadConEdicionRestringida( tcNombreAtributo as String ) as Boolean
		return this.oAtributosConEdicionRestringida.Buscar( upper( alltrim( tcNombreAtributo ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oAtributosConEdicionRestringida_Access() as ZooColeccion of ZooColeccion.Prg
		if !this.ldestroy and !vartype( this.oAtributosConEdicionRestringida ) = 'O'
			this.oAtributosConEdicionRestringida = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oAtributosConEdicionRestringida
	endfunc 

	*-----------------------------------------------------------------------------------------
	function lEsEntidadConEdicionRestringida_Access() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if vartype( this.oAtributosConEdicionRestringida ) = 'O' and this.oAtributosConEdicionRestringida.Count > 0
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oTalle_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oTalle ) = 'O' or isnull( this.oTalle ) )
				this.oTalle = _Screen.zoo.instanciarentidad( 'Talle' )
			endif
		endif
		return this.oTalle
	endfunc


	*-----------------------------------------------------------------------------------------
	function ObtenerUltimaModificacionEnRegistros() as DateTime
		return this.oAd.ObtenerFechaUltimoUpdateEnTablas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarReglaDeNegocioPersonalizadaImportacion( toConexion as Object ) as Void
		* A sobreescribir en los ent_*.prg
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PreprocesarCursorParaImportacionEnBloque( tcNombreCursor as String ) as Void
		* A sobreescribir en los ent_*.prg
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oGestorDeMail_Access() as ZooColeccion of ZooColeccion.Prg
		if !this.ldestroy and !vartype( this.oGestorDeMail ) = 'O'
			this.oGestorDeMail = _Screen.zoo.CrearObjeto( "GestorDeMail" )
		endif
		return this.oGestorDeMail
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerWhereAdicionalParaSentenciaUpdate() as String
		local lcRetorno as String
		lcRetorno = ""
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoBusquedaEspecial( tcAtributo as String ) as object
		return null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPorInsertar() as Void

	endfunc 
		*-----------------------------------------------------------------------------------------
	function EventoMensajeDenegarModificar_Anular_EliminarEmpaquetado( tcTexto as string ) as Void
*!*		Evento para ser camputrado desde el Kontroler
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearUltimaAccionYEstado(tcAccion as String, tcEstado as String) as Void
*!*		Evento para ser camputrado desde el Kontroler
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SeguridadEnEntidadMenuConDosOperaciones(tcOperacion as String, tcAccion as String, tcEstado as String ) as Void

		if !empty(this.estadotransferencia) &&= "enviado-recibido"
			if goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombre(), tcOperacion )
				this.EventoSetearUltimaAccionYEstado( tcAccion ,tcEstado )
			else
				lcEntidad = this.ObtenerDescripcion()
				lcMensaje = 'Verifique la seguridad para '+ lower(tcAccion)+ ' un ' + lower(lcEntidad) + ' empaquetado'
				this.EventoMensajeDenegarModificar_Anular_EliminarEmpaquetado( lcMensaje )
				return .f.
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneContratadoElServicio( tnServicio as Integer ) as Boolean
		* Servicio 2 = Entrega online
		return goServicios.RealTime.TieneContratadoElServicioDeOmnicanalidad( tnServicio )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoRefrescarDetalle( tcDetalle as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposSegunEquivalencia( taEst ) as Void
		local loTransformacionLince , loColMatcheos , lnI, lcCadena, lnPos
		lcCadena = ""
		return lcCadena 
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function NoValidarDetallePorOperatoriaEnBaseA() as Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipTalle( tcCodigoTalle as String ) as string 
		local lcDescripcionTalle as String
		lcDescripcionTalle = ""	
		try 
			if this.oTalle.CODIGO # tcCodigoTalle
				this.oTalle.CODIGO = tcCodigoTalle
			endif
			lcDescripcionTalle = this.oTalle.Descripcion
		catch
		endtry
		
		return lcDescripcionTalle 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneQueLoguearExcepciones() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function UsuarioAutorizante() as String
				
		return iif( empty( this.cUsuarioQueAutorizoSeguridad ),"", "_" + this.cUsuarioQueAutorizoSeguridad )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarConfirmacionImpresion( tcMensaje as String, tnBotones as Integer, tnRespuestaSugerida as Integer ) as void s
		if this.cContexto = "R" and tnRespuestaSugerida = 0
			this.lConfirmarImpresion = 1
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviaPdfPersonalizadoPorMail() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaDePdfPersonalizadoParaEnvioDeMail() as String
		return ""
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class ItemRegistroActividad as Custom
	cCodigo = ""
enddefine





