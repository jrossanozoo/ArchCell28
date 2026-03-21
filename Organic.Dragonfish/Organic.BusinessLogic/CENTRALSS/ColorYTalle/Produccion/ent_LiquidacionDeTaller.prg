define class ent_LiquidacionDeTaller as din_EntidadLiquidacionDeTaller of din_EntidadLiquidacionDeTaller.prg

	#if .f.
		local this as ent_LiquidacionDeTaller of ent_LiquidacionDeTaller.prg
	#endif

	oColaborador = null
	lCambioAlgunDetalle = .f.
	lContinuarConActualizacionDeDetalles = .F.
	
	*-----------------------------------------------------------------------------------------
	function oColaborador_Access()
		if !this.ldestroy and !vartype( this.oColaborador ) = 'O'
			this.oColaborador = _screen.zoo.CrearObjeto( 'colaboradorLiquidacionDeTaller' )
		endif
		return this.oColaborador
	endfunc
	
	*-------------------------------------------------------------------------------------------------
	Function Init( t1, t2, t3, t4 ) As Boolean
		Local llRetorno As Boolean

		llRetorno = DoDefault(t1, t2, t3, t4 )
		If llRetorno
			if _Screen.Zoo.nVersionSQLNo < 2014
				messagebox("Para usar costos en el módulo de producción debe actualizar el motor de base de datos a SQL Server 2022",16,"Restricción de acceso",10000)
				this.release()
			endif
		Endif
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Inicializar()
		dodefault()
		this.oColaborador.InyectarLiquidacion( this )
		this.oColaborador.Inicializar()
		This.BindearEvento( this.LiquidacionTallerProduccion, "EventoCambioSum_Monto", This, "CalcularTotal" )
		This.BindearEvento( this.LiquidacionTallerProduccion.oItem, "EventoCambioItem", This, "CambioItem" )
		This.BindearEvento( this.LiquidacionTallerDescarte, "EventoCambioSum_Monto", This, "CalcularTotal" )
		This.BindearEvento( this.LiquidacionTallerDescarte.oItem, "EventoCambioItem", This, "CambioItem" )
		This.BindearEvento( this.LiquidacionTallerInsumos, "EventoCambioSum_Monto", This, "CalcularTotal" )
		This.BindearEvento( this.LiquidacionTallerInsumos.oItem, "EventoCambioItem", This, "CambioItem" )
		This.BindearEvento( this.LiquidacionTallerAdicionales, "EventoCambioSum_Monto", This, "CalcularTotal" )
		This.BindearEvento( this.LiquidacionTallerAdicionales.oItem, "EventoCambioItem", This, "CambioItem" )
	endfunc

*!*		*-------------------------------------------------------------------------------------------------
*!*		Function Init( t1, t2, t3, t4 ) As Boolean
*!*			Local llRetorno As Boolean

*!*			llRetorno = DoDefault(t1, t2, t3, t4 )
*!*			If llRetorno
*!*				if _Screen.VersionSQLNo < '2014'
*!*					messagebox("Para usar costos en el módulo de producción debe actualizar el motor de base de datos a SQL Server 2022",16,"Restricción de acceso",10000)
*!*	*!*					goMensajes.Alertar('Para usar costos en el modulo de producción debe actualizar el motor de base de datos a SQL Server 2022')
*!*					this.release()
*!*	*!*					goServicios.Errores.LevantarExcepcion( "Para usar costos en el modulo de producción debe actualizar el motor de base de datos a SQL Server 2022" )
*!*				endif
*!*			Endif
*!*			Return llRetorno
*!*		endfunc

	*-----------------------------------------------------------------------------------------
	function eventoMensajeSinEspera( tcMensaje as String ) as Void
		&& para Bindear en el Kontroler
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		this.lCambioAlgunDetalle = .f.
		this.lContinuarConActualizacionDeDetalles = .t.
		this.Comprobante = ""
		this.listadeCOSTO_PK = rtrim( goParametros.Felino.Generales.ListaDeCostosPreferenteParaCotizacionesYLiquidacionesDeProduccion )
	endfunc

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault() and this.oColaborador.CrearComprobante()
		return llRetorno
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function TrasladarFiltros()
		local lFirma as string
		lFirma = this.oColaborador.ObtenerFirmaFiltros()
		with this.oColaborador.oFiltros
			.cTaller = this.Taller_pk
			.nOrdenDesde = this.OrdenDesde
			.nOrdenHasta = this.OrdenHasta
			.cProcesoDesde = this.ProcesoDesde_PK
			.cProcesoHasta = this.ProcesoHasta_PK
			.nGestionDesde = this.GestionDesde
			.nGestionHasta = this.GestionHasta
			.dFechaDesde = this.FechaDesde
			.dFechaHasta = this.FechaHasta
			.cListaDeCosto = this.ListaDeCosto_pk
			.nDescartes = this.Descartes
			.nInsumos = this.Insumos
		endwith
		
		if this.esnuevo() and !empty( this.Taller_pk ) and !empty( this.ListaDeCosto_pk ) and lFirma <> this.oColaborador.ObtenerFirmaFiltros()
			if this.lCambioAlgunDetalle
				this.EventoPreguntarActualizarDetalles()
			else
				this.lContinuarConActualizacionDeDetalles = .t.
			endif
			if this.lContinuarConActualizacionDeDetalles
				this.lCambioAlgunDetalle = .f.
				this.oColaborador.InyectarConsulta()
			endif
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CalcularTotal() as Boolean
		this.Total = this.LiquidacionTallerProduccion.Sum_Monto + this.LiquidacionTallerDescarte.Sum_Monto;
						+ this.LiquidacionTallerInsumos.Sum_Monto + this.LiquidacionTallerAdicionales.Sum_Monto
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Taller( txVal as variant ) as void
		dodefault( txVal )
		with this.Taller
			this.Descartes 			= iif(!empty(.DescarteEnLiquidacion),.DescarteEnLiquidacion,this.Descartes)
			this.Insumos			= iif(!empty(.InsumoEnLiquidacion),.InsumoEnLiquidacion,this.Insumos)
			this.ListaDeCosto_pk	= iif(!empty(.ListaDeCosto_pk),.ListaDeCosto_pk,this.ListaDeCosto_pk)
			this.Proveedor_pk		= .Proveedor_pk
			this.Moneda_PK 			= this.ListaDeCosto.Moneda_PK
		endwith
		this.TrasladarFiltros()
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambioItem() as Void
		this.lCambioAlgunDetalle = .t.
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_ListaDeCosto( txVal as variant ) as void
		dodefault( txVal )
		with this.ListaDeCosto
			this.Moneda_PK 			= .Moneda_PK
		endwith
		this.TrasladarFiltros()
	endfunc


	*--------------------------------------------------------------------------------------------------------
	function Setear_OrdenDesde( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	function Setear_OrdenHasta( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_ProcesoDesde( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	function Setear_ProcesoHasta( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_GestionDesde( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	function Setear_GestionHasta( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_FechaDesde( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	function Setear_FechaHasta( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Descartes( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	function Setear_Insumos( txVal as variant ) as void
		dodefault( txVal )
		this.TrasladarFiltros()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_Comprobante( txVal as variant ) as void
		dodefault( txVal )
		this.lHabilitarLetraComprobante = !empty(txVal)
		this.lHabilitarPuntoDeVentaComprobante = !empty(txVal)
		this.lHabilitarNumeroComprobante = !empty(txVal)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarActualizarDetalles() as Void
		&& para Bindear en el Kontroler
	endfunc 
	
enddefine
