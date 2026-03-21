define class AplicacionColoryTalle as AplicacionFelino of AplicacionFelino.prg

	#IF .f.
		Local this as AplicacionColoryTalle of AplicacionColoryTalle.prg
	#ENDIF

	Nombre = "Zoo Logic Dragonfish Color y Talle"
	NombreProducto = "DRAGONFISH"
	cProyecto = "ColoryTalle"
	lEsCambioSucursal = .F.
	cProducto = "06"
    
    *-----------------------------------------------------------------------------------------
    function Iniciar( tcSerie as string, tcClave as string, tcSitio as String ) as Boolean
        dodefault( tcSerie, tcClave, tcSitio )
        if !goServicios.Ejecucion.TieneScriptCargado()   
            this.ObtenerLimiteEnComprobanteSinPersonalizar()
        endif
    endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarServiciosSinDependencia() as Void
		dodefault()
		this.SetearDatosDelMotor()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalDefault() as Void
		return "DEMO"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarMenuPrincipal() as Void
		dodefault()
		this.ActualizarMenuServicio()

		goservicios.ServicioNotificacionEnSegundoPlano.iniciar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutandoSalidaDelSistema() as Void
		*Evento
		goservicios.ServicioNotificacionEnSegundoPlano.detener()
		dodefault() 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarMenuServicio() as Void
		try
			with this.oFormPrincipal.oMenu.me_1001
				.visible = .t.
				.caption = "&Sistema"
				.it_1009.caption = iif( goservicios.seguridad.nEstadoDelSistema = 1,"&Activar","Des&activar") + " seguridad"
			endwith 
		catch
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarReferencias() as Void
		dodefault()
		this.AgregarReferencia( 'ZooLogicSA.OrganicServiciosREST.ColoryTalle.Generados.dll' )
		this.AgregarReferencia( 'ZooLogicSA.OrganicServiciosREST.ColoryTalle.dll' )
		this.AgregarReferencia( "ZooLogicSA.MensajeriaPostVentaMercadoLibre.dll" )
		this.AgregarReferencia( 'ZooLogicSA.EtiquetasEnvioMercadoLibre.dll' )
		this.AgregarReferencia( 'ZoologicSA.PreSeleccion.UI.dll' )
        this.AgregarReferencia( 'ZooLogicSA.ConectorWebAPI.dll' )
        this.AgregarReferencia( 'ZooLogicSA.Buscador.DevExForms.dll' )
        this.AgregarReferencia( 'ZooLogicSA.Buscador.Presentacion.dll' )
	endfunc
    
    *-----------------------------------------------------------------------------------------
    protected function ObtenerLimiteEnComprobanteSinPersonalizar() as Void
		public goColaboradorWebAPI as object
		local lcMensajeError as String, loError as Exception, loLogueador as Object
        goColaboradorWebAPI = null
        try
            goColaboradorWebAPI = _screen.zoo.crearObjeto( "colaboradorWebAPI" )
            if goServicios.Parametros.Felino.GestionDeVentas.ObtenerAutomaticamenteLimiteParaComprobantesSinPersonalizar
                goColaboradorWebAPI.ActualizarLimiteTotalEnParametros()
                goColaboradorWebAPI.ActualizarLimiteTotalEnParametrosUsandoTarjetaOPagoElec()
            endif   
        catch to loError
            lcMensajeError = "ConectorWebAPI - " + iif(vartype( loError.uservalue ) = 'O',  loError.uservalue.message,loError.message)
            loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( loError )
            loLogueador.Escribir( lcMensajeError )
            goServicios.Logueos.Guardar( loLogueador )
            loLogueador = null
        endtry    
    endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DespuesDelLogin() as Void
		local loConfigurador as Object
		dodefault()
		loConfigurador = _screen.zoo.CrearObjetoPorProducto("ColaboradorConfiguradorModoComercial")
		loConfigurador.VerificarConfigurarModoComercial()
		
		if !this.lDesarrollo and !this.lEsBuildAutomatico and !goServicios.Ejecucion.TieneScriptCargado() 
			this.ObtenerParametrizacionIterfazLasPiedrasShopping()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerParametrizacionIterfazLasPiedrasShopping() as Void
		local loColaborador as Object

		if this.nPais = 3 
			try
				with goParametros.Felino.Interfases.LasPiedrasShopping
					if !empty( .Usuario ) and !empty( .Contrasena ) and .HabilitarExportacionLasPiedrasShopping
						loColaborador = _screen.zoo.crearobjeto( "ColaboradorLasPiedrasShopping" )
						loColaborador.ActualizarParametrizacion()
					endif
				endwith 
			catch to loError
			endtry
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosDelMotor() as Void
		local loColaborador as Objects
		loColaborador = _screen.zoo.CrearObjeto( "ColaboradorBarraDeEstadoMotorDB", "ColaboradorBarraDeEstadoMotorDB.prg" )
		loColaborador.ObtenerCaracteristicasMotodDB( "c_DatosMotor", this.DataSessionId )

		if used( "c_DatosMotor" ) and reccount( "c_DatosMotor" ) > 0
			select c_DatosMotor

			go top

			lcNumVersion = alltrim( c_DatosMotor.numVersion )
			
			do case
				case left(lcNumVersion ,3) = '17.'
					lnVersionSQL = 2025
					lcVersionSQL = '2025'
				case left(lcNumVersion ,3) = '16.'
					lnVersionSQL = 2022
					lcVersionSQL = '2022'
				case left(lcNumVersion ,3) = '15.'
					lnVersionSQL = 2019
					lcVersionSQL = '2019'
				case left(lcNumVersion ,3) = '14.'
					lnVersionSQL = 2017
					lcVersionSQL = '2017'
				case left(lcNumVersion ,3) = '13.'
					lnVersionSQL = 2016
					lcVersionSQL = '2016'
				case left(lcNumVersion ,3) = '12.'
					lnVersionSQL = 2014
					lcVersionSQL = '2014'
				case left(lcNumVersion ,3) = '11.'
					lnVersionSQL = 2012
					lcVersionSQL = '2012'
				case left(lcNumVersion ,3) = '10.5'
					lnVersionSQL = 2008
					lcVersionSQL = '2008 R2'
				case left(lcNumVersion ,3) = '10.'
					lnVersionSQL = 2008
					lcVersionSQL = '2008'
				case left(lcNumVersion ,2) = '9.'
					lnVersionSQL = 2005
					lcVersionSQL = '2005'
				otherwise
					lnVersionSQL = 0
					lcVersionSQL = ''
			endcase
			_Screen.Zoo.nVersionSQLNo = lnVersionSQL
			_Screen.Zoo.cVersionSQLNo = lcVersionSQL

			use in( "c_DatosMotor" )
		endif

		release loColaborador

	endfunc 

EndDefine
