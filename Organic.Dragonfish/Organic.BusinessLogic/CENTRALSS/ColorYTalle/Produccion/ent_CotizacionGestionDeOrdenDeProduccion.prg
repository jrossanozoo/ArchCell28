define class ent_CotizacionGestionDeOrdenDeProduccion as din_EntidadCotizacionGestionDeOrdenDeProduccion of din_EntidadCotizacionGestionDeOrdenDeProduccion.prg

	#if .f.
		local this as ent_CotizacionGestionDeOrdenDeProduccion of ent_CotizacionGestionDeOrdenDeProduccion.prg
	#endif

	protected cListaDeCostosPreferente as String
	protected cArticuloDefaultProcesoProduccion as String
	protected cArticuloDefaultProcesoDescarte as String
	protected cArticuloDefaultInsumoProduccion as String
	protected cArticuloDefaultInsumoDescarte as String

	oComponenteCostosDeProduccion = null
	oColaboradorProduccion = null
	oColaboradorCostos = null
	oGestion = null
	cListaCotizada = ''
	cGestionCotizada = ''
	lCargaDeGestion = .f.
	lContinuarConActualizacionDeDetalles = .f.
	lContinuarConActualizacionDeCostos = .f.
	oArticulo = null

	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.cListaDeCostosPreferente = goParametros.Felino.Generales.ListaDeCostosPreferenteParaCotizacionesYLiquidacionesDeProduccion
		this.cArticuloDefaultProcesoProduccion = goParametros.Felino.Generales.ArticuloDefaultLiquidacionProcesoProduccion
		this.cArticuloDefaultProcesoDescarte = goParametros.Felino.Generales.ArticuloDefaultLiquidacionProcesoDescarte
		this.cArticuloDefaultInsumoProduccion = goParametros.Felino.Generales.ArticuloDefaultLiquidacionInsumosProduccion
		this.cArticuloDefaultInsumoDescarte = goParametros.Felino.Generales.ArticuloDefaultLiquidacionInsumosDescarte
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oComponenteCostosDeProduccion_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oComponenteCostosDeProduccion ) = 'O' or isnull( this.oComponenteCostosDeProduccion ) )
				this.oComponenteCostosDeProduccion = _Screen.Zoo.InstanciarComponente('ComponenteCostosProduccion')
			endif
		endif
		return this.oComponenteCostosDeProduccion
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorProduccion_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oColaboradorProduccion ) = 'O' or isnull( this.oColaboradorProduccion ) )
				this.oColaboradorProduccion = _Screen.zoo.CrearObjetoPorProducto( 'ColaboradorProduccion' )
			endif
		endif
		return this.oColaboradorProduccion
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorCostos_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oColaboradorCostos ) = 'O' or isnull( this.oColaboradorCostos ) )
				this.oColaboradorCostos = _Screen.zoo.CrearObjetoPorProducto( 'colaboradorCalculoDeCostosEnProduccion' )
			endif
		endif
		return this.oColaboradorCostos
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Gestiondeproduccion( txVal as variant ) as void
		local loError as Object, lnRespuesta as Integer, lcMensaje as String
		this.cGestionCotizada = txVal
		try 
			this.lCargaDeGestion = .t.
			dodefault( txVal )
			this.oGestion = this.oColaboradorProduccion.ObtenerGestionDeProduccion( txVal )

			this.OrdenDeProduccion_PK = this.oGestion.OrdenDeProduccion_PK
			this.Taller_PK = this.oGestion.Taller_PK
			this.Proveedor_PK = this.oGestion.Proveedor_PK
			this.Proceso_PK = this.oGestion.Proceso_PK
			this.ListaDeCosto_PK = iif(empty(this.oGestion.ListaDeCosto_PK),this.cListaDeCostosPreferente,this.oGestion.ListaDeCosto_PK)

			this.Moneda_PK = this.ListaDeCosto.Moneda_PK
			this.Insumos = this.oGestion.InsumoEnLiquidacion
			this.Descartes = this.oGestion.DescarteEnLiquidacion
			
			*this.LlenarInsumosDesdeGestionDeOrden()
			this.LlenarDesdeLiquidacionPrecargada()

		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			this.lCargaDeGestion = .f.
		endtry

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Listadecosto( txVal as variant ) as void
		dodefault( txVal )
		this.Moneda_PK = this.ListaDeCosto.Moneda_PK
		if this.cListaCotizada # txVal
			this.RecalculoDeCostos()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function LlenarInsumosDesdeGestionDeOrden() as Void
		local lcSentencia as String, loItem as Object, lcArticulo as String, lcTabla as String
		if this.CotizacionOrdenProduccion.Count > 0
			this.CotizacionOrdenProduccion.Limpiar()
		endif
		if this.CotizacionOrdenDescarte.Count > 0
			this.CotizacionOrdenDescarte.Limpiar()
		endif
		if this.CotizacionOrdenInsumos.Count > 0
			this.CotizacionOrdenInsumos.Limpiar()
		endif
		
		this.cListaCotizada = this.ListaDeCosto_PK
		lcTabla = 'gespcurv'
		lcSentencia = this.OcolaboradorCostos.ObtenerSentenciaProductosDeGestionCotizados( this.Gestiondeproduccion_PK, this.cListaCotizada, ;
						this.Proceso_PK, this.Taller_PK )
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
		lcArticulo = alltrim(this.ObtenerArticuloParaLiquidacionDeProduccion( this.Proceso ))

		this.EventoIniciarProceso( 'Cargando y cotizando gestión de orden de producción' )
		
		scan 
			if CantidadProducida > 0
				with this.CotizacionOrdenProduccion
					.LimpiarItem()
					.oItem.Codigo = Codigo
					.oItem.Semielaborado_PK = Insumo
					.oItem.Color_PK = codColor
					.oItem.Talle_PK = codTalle
					.oItem.Cantidad = CantidadProducida
					.oItem.Costo = iif(type('Costo')='N',Costo,0)
					.oItem.Monto = Costo * CantidadProducida

					.oItem.Articulo_PK = lcArticulo
					.Actualizar()
				endwith
			endif
		endscan

		if this.oColaboradorProduccion.DebeInlcuirDescartesEnLiquidacion( this.Taller_PK, this.Proceso_PK )
			lcArticulo = alltrim(this.ObtenerArticuloParaLiquidacionDeDescarte( this.Proceso ))

			lcTabla = 'gespdesc'
			lcSentencia = this.OcolaboradorCostos.ObtenerSentenciaDescartesDeGestionCotizados( this.Gestiondeproduccion_PK, this.cListaCotizada, ;
							this.Proceso_PK, this.Taller_PK )
			lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
			lcArticulo = alltrim(this.ObtenerArticuloParaLiquidacionDeProduccion( this.Proceso ))

			scan 
				if CantidadDescartada > 0
					with this.CotizacionOrdenDescarte
						.LimpiarItem()
						.oItem.Codigo = Codigo
						.oItem.Semielaborado_PK = Insumo
						.oItem.Color_PK = codColor
						.oItem.Talle_PK = codTalle
						.oItem.Cantidad = CantidadDescartada
						.oItem.Costo = iif(type('Costo')='N',Costo,0)
						.oItem.Monto = Costo * CantidadDescartada

						.oItem.Articulo_PK = lcArticulo
						.Actualizar()
					endwith
				endif
			endscan

		endif

		if this.oColaboradorProduccion.DebeInlcuirInsumosEnLiquidacion( this.Taller_PK, this.Proceso_PK )

			lcTabla = 'gespins'
			lcSentencia = this.OcolaboradorCostos.ObtenerSentenciaInsumosDeProductosDeGestionCotizados( this.Gestiondeproduccion_PK, this.cListaCotizada, ;
							this.Proceso_PK, this.Taller_PK )
			lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

			scan 
				if Cantidad > 0
					with this.CotizacionOrdenInsumos
						.LimpiarItem()
						.oItem.Codigo = Codigo
						.oItem.Insumo_PK = Insumo
						.oItem.Color_PK = codColor
						.oItem.Talle_PK = codTalle
						.oItem.Cantidad = Cantidad
						.oItem.Costo = iif(type('Costo')='N',Costo,0)
						.oItem.Monto = Costo * Cantidad
						lcArticulo = this.ObtenerArticuloParaInsumosDeProduccion( lc_gespins.ArticuloProduccion )
						.oItem.Articulo_PK = lcArticulo
						.Actualizar()
					endwith
				endif
			endscan

			lcTabla = 'gespind'
			lcSentencia = this.OcolaboradorCostos.ObtenerSentenciaInsumosDeDescartesDeGestionCotizados( this.Gestiondeproduccion_PK, this.cListaCotizada, ;
							this.Proceso_PK, this.Taller_PK )
			lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

			scan 
				if Cantidad > 0
					with this.CotizacionOrdenInsumos
						.LimpiarItem()
						.oItem.Codigo = Codigo
						.oItem.Insumo_PK = Insumo
						.oItem.Color_PK = codColor
						.oItem.Talle_PK = codTalle
						.oItem.Cantidad = Cantidad
						.oItem.Costo = iif(type('Costo')='N',Costo,0)
						.oItem.Monto = Costo * Cantidad
						lcArticulo = this.ObtenerArticuloParaInsumosDeProduccion( lc_gespind.ArticuloDescarte )
						.oItem.Articulo_PK = lcArticulo
						.Actualizar()
					endwith
				endif
			endscan

		endif
		this.EventoFinalizarProceso()
		this.eventoDespuesDeActualizarDetalle()
	endfunc 


	*-----------------------------------------------------------------------------------------
	function LlenarDesdeLiquidacionPrecargada() as Void
		local lcSentencia as String, loItem as Object, lcArticulo as String, lcTabla as String

		with this.oColaboradorProduccion.oLiquiAux
			if .EsNuevo()
				.Cancelar()
			endif
			.Nuevo()
			.GestionDesde		= this.GestiondeProduccion.Numero
			.GestionHasta		= this.GestiondeProduccion.Numero
			.Descartes 			= this.oGestion.DescarteEnLiquidacion
			.Insumos			= this.oGestion.InsumoEnLiquidacion
			.taller_pk			= this.Taller_PK
			.ListaDeCosto_PK	= this.ListaDeCosto_PK
			&& Esto debe pre cargar en la entidad oLiquiAux solo lo que queda pendiente de liquidación en caso 
			&& que ya tengamos liquidaciones parciales realizadas
		endwith 

		if this.CotizacionOrdenProduccion.Count > 0
			this.CotizacionOrdenProduccion.Limpiar()
		endif
		if this.CotizacionOrdenDescarte.Count > 0
			this.CotizacionOrdenDescarte.Limpiar()
		endif
		if this.CotizacionOrdenInsumos.Count > 0
			this.CotizacionOrdenInsumos.Limpiar()
		endif
		
		this.EventoIniciarProceso( 'Cargando y cotizando gestión de orden de producción' )
		
		try 
			lcArticulo = alltrim(this.ObtenerArticuloParaLiquidacionDeProduccion( this.Proceso ))
			this.RecorrerYAgregarItem(this.oColaboradorProduccion.oLiquiAux.LiquidacionTallerProduccion, this.CotizacionOrdenProduccion, lcArticulo )
			lcArticulo = alltrim(this.ObtenerArticuloParaLiquidacionDeDescarte( this.Proceso ))
			this.RecorrerYAgregarItem(this.oColaboradorProduccion.oLiquiAux.LiquidacionTallerDescarte, this.CotizacionOrdenDescarte, lcArticulo )
			lcArticulo = this.ObtenerArticuloParaInsumosDeProduccion( "" )
			this.RecorrerYAgregarItem(this.oColaboradorProduccion.oLiquiAux.LiquidacionTallerInsumos, this.CotizacionOrdenInsumos, lcArticulo )
			this.RecorrerYAgregarItem(this.oColaboradorProduccion.oLiquiAux.LiquidacionTallerAdicionales, this.CotizacionOrdenAdicionales, "" )
		catch to loError
			** arreglo
		endtry 

		this.EventoFinalizarProceso()
		this.eventoDespuesDeActualizarDetalle()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RecorrerYAgregarItem( tcColeOrigen as Object, tcColeDestino as Object, tcArticulo ) as Void
		local loItem as Object
		for each loItem in tcColeOrigen
			with tcColeDestino
				.LimpiarItem()
				if pemstatus(.oItem,"insumo_pk",5) and pemstatus(loItem,"insumo_pk",5)
					.oItem.insumo_pk = loItem.insumo_pk
				endif
				if pemstatus(.oItem,"Semielaborado_PK",5) and pemstatus(loItem,"Semielaborado_pk",5)
					.oItem.Semielaborado_PK	= loItem.Semielaborado_pk
				endif
				if pemstatus(.oItem,"Color_PK",5) and pemstatus(loItem,"Color_PK",5)
					.oItem.Color_PK		= loItem.Color_pk
				endif
				if pemstatus(.oItem,"Talle_PK",5) and pemstatus(loItem,"Talle_PK",5)
					.oItem.Talle_PK		=loItem.Talle_pk
				endif
				.oItem.Cantidad		= loItem.Cantidad
				.oItem.Costo		= loItem.Costo
				.oItem.Monto		= loItem.Costo * loItem.Cantidad
				.oItem.Articulo_PK	= iif(empty(loItem.Articulo_pk),tcArticulo,loItem.Articulo_pk)
				if pemstatus(.oItem,"IdItemInsumo",5)
					.oItem.IdItemInsumo	= loItem.IdItemInsumo
				else
					.oItem.IdItemArticulo	= loItem.IdItemArticulo
				endif
				.Actualizar()
			endwith
		endfor

	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function RecalculoDeCostos() as Void
		this.cListaCotizada = this.ListaDeCosto_PK
		for each loItem in this.CotizacionOrdenProduccion FOXOBJECT
			loItem.Costo = this.oComponenteCostosDeProduccion.ObtenerCostoPonderado( ;
							this.cListaCotizada, loItem.Semielaborado_PK, this.Taller_PK, this.Proceso_PK, ;
							loItem.Color_PK, loItem.Talle_PK, loItem.Cantidad )
			loItem.Monto = loItem.Costo * loItem.Cantidad
		endfor
		for each loItem in this.CotizacionOrdenDescarte FOXOBJECT
			loItem.Costo = this.oComponenteCostosDeProduccion.ObtenerCostoPonderado( ;
							this.cListaCotizada, loItem.Semielaborado_PK, this.Taller_PK, this.Proceso_PK, ;
							loItem.Color_PK, loItem.Talle_PK, loItem.Cantidad )
			loItem.Monto = loItem.Costo * loItem.Cantidad
		endfor
		for each loItem in this.CotizacionOrdenInsumos FOXOBJECT
			loItem.Costo = this.oComponenteCostosDeProduccion.ObtenerCostoPonderado( ;
							this.cListaCotizada, loItem.Insumo_PK, this.Taller_PK, this.Proceso_PK, ;
							loItem.Color_PK, loItem.Talle_PK, loItem.Cantidad )
			loItem.Monto = loItem.Costo * loItem.Cantidad
		endfor
		for each loItem in this.CotizacionOrdenAdicionales FOXOBJECT
			loItem.Costo = this.oComponenteCostosDeProduccion.ObtenerCostoPonderado( ;
							this.cListaCotizada, loItem.Articulo_PK, this.Taller_PK, this.Proceso_PK, ;
							loItem.Color_PK, loItem.Talle_PK, loItem.Cantidad )
			loItem.Monto = loItem.Costo * loItem.Cantidad
		endfor
		this.eventoDespuesDeActualizarDetalle()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeInlcuirInsumosEnLiquidacion( toTaller as Object, tcProceso as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeInlcuirDescartesEnLiquidacion( toTaller as Object, tcProceso as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoDespuesDeActualizarDetalle() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerArticuloParaLiquidacionDeProduccion( toProceso as Object ) as String
		local lcRetorno as String
		try
			this.oArticulo.Codigo = lcRetorno
			if this.oArticulo.Comportamiento # 2
				lcRetorno = ''
			endif
		catch
			lcRetorno = ''
		endtry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerArticuloParaLiquidacionDeDescarte( toProceso as Object ) as String
		local lcRetorno as String
		lcRetorno = iif(empty(toProceso.ArticuloLiquidacionDescarte_PK),this.cArticuloDefaultProcesoDescarte,toProceso.ArticuloLiquidacionDescarte_PK)
		try
			this.oArticulo.Codigo = lcRetorno
			if this.oArticulo.Comportamiento # 2
				lcRetorno = ''
			endif
		catch
			lcRetorno = ''
		endtry
		return lcRetorno
	endfunc 


	*--------------------------------------------------------------------------------------------------------
	function oArticulo_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oArticulo ) = 'O' or isnull( this.oArticulo ) )
				this.oArticulo = _Screen.Zoo.InstanciarEntidad( "Articulo" )
			endif
		endif
		return this.oArticulo 
	endfunc


	*-----------------------------------------------------------------------------------------
	protected function ObtenerArticuloParaInsumosDeProduccion( tcInsumo as String ) as String
		local lcRetorno as String, loArticulo as Object
		lcRetorno = iif(type('tcInsumo') # 'C' or empty(tcInsumo),this.cArticuloDefaultInsumoProduccion,tcInsumo)
		try
			this.oArticulo.Codigo = lcRetorno
			if this.oArticulo.Comportamiento # 2
				lcRetorno = ''
			endif
		catch
			lcRetorno = ''
		endtry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerArticuloParaInsumosDeDescarte( tcInsumo as String ) as String
		local lcRetorno as String, loArticulo as Object
		lcRetorno = iif(type('tcInsumo') # 'C' or empty(tcInsumo),this.cArticuloDefaultInsumoDescarte,tcInsumo)
		try
			this.oArticulo.Codigo = lcRetorno
			if this.oArticulo.Comportamiento # 2
				lcRetorno = ''
			endif
		catch
			lcRetorno = ''
		endtry
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDeCostos( toTaller as Object ) as String
		local lcRetorno as String, loArticulo as Object
		if empty(toTaller.ListaDeCosto_PK)
			lcRetorno = this.cListaDeCostosPreferente
		else
			lcRetorno = this.Gestiondeproduccion.Taller.ListaDeCosto_PK
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoIniciarProceso( tcMensaje as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinalizarProceso() as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Listadecosto( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = This.CargaManual() and dodefault( txVal, txValOld )
		if llRetorno and !this.lCargaDeGestion and this.cListaCotizada # '' and this.cListaCotizada # txVal
			this.EventoPreguntarActualizarCostos()
			if this.lContinuarConActualizacionDeCostos
				llRetorno = dodefault( txVal, txValOld )
			else
				llRetorno = .f.
				this.ListaDeCosto_PK = txValOld
			endif
		endif
		Return 
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Gestiondeproduccion( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = This.CargaManual() and dodefault( txVal, txValOld )
		if llRetorno and this.cGestionCotizada # '' and txValOld # '' and txValOld # txVal
			this.EventoPreguntarActualizarDetalle()
			if this.lContinuarConActualizacionDeDetalles
				if this.CotizacionOrdenProduccion.Count > 0
					this.CotizacionOrdenProduccion.Limpiar()
				endif
				if this.CotizacionOrdenDescarte.Count > 0
					this.CotizacionOrdenDescarte.Limpiar()
				endif
				if this.CotizacionOrdenInsumos.Count > 0
					this.CotizacionOrdenInsumos.Limpiar()
				endif
				this.eventoDespuesDeActualizarDetalle()
				llRetorno = dodefault( txVal, txValOld )
			else
				llRetorno = .f.
				this.Gestiondeproduccion_PK = txValOld
			endif
		endif
		Return llRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarActualizarDetalle() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarActualizarCostos() as Void
	endfunc 

enddefine
