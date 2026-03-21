define class ent_FinalDeProduccion as din_EntidadFinalDeProduccion of din_EntidadFinalDeProduccion.prg

	#If .F.
		Local This As ent_FinalDeProduccion As ent_FinalDeProduccion.prg
	#Endif

	TipoComprobante = 90
	lContinuarConActualizacionDelDetalle = .t.
	lHaCambiado_Proceso_PK = .f.
	lDebeAdvertirFaltantedestock = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
*!*			bindevent( this.GestionCurva.oItem, "EventoRecalcularInsumosSegunItemActivoSalida", this, "RecalcularInsumosSegunItemActivoSalida" )
*!*			bindevent( this.GestionCurva.oItem, "EventoRecalcularDescartesSegunItemActivoSalida", this, "RecalcularDescartesSegunItemActivoSalida" )
		this.oCompFinalDeProduccion.InyectarEntidad( this )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_OrdenDeProduccion( txVal as variant ) as void
		local lcCursorProcesos as String, lcUltimoProceso as String
		if !empty( txVal )
			lcCursorProcesos = sys( 2015 )
			this.XmlACursor( this.OrdenDeProduccion.oAd.ObtenerDatosDetalleOrdenProcesos( 'proceso', "codigoorden = '" + txVal + "' ", 'orden desc' ), lcCursorProcesos )
			lcUltimoProceso = &lcCursorProcesos..Proceso

			this.Proceso_PK = lcUltimoProceso
			if used( lcCursorProcesos )
				use in ( lcCursorProcesos )
			endif

			this.lHabilitarOrdenDeProduccion_PK = .f.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorProceso( toBusqueda as Object ) as Void
		local lcTablaProcesos as String
		toBusqueda.Tabla = toBusqueda.Tabla + "," + This.OrdenDeProduccion.oAd.ObtenerTablaDetalle( "OrdenProcesos" )
		lcTablaProcesos = iif( !empty( this.oAd.cEsquema ), this.oAd.cEsquema + ".", "" ) + This.OrdenDeProduccion.oAd.ObtenerTablaDetalle( "OrdenProcesos" )
		toBusqueda.Filtro = toBusqueda.Filtro + " and ProcProduc.codigo in ( select codigo from " + lcTablaProcesos + " where codorden = '" + this.OrdenDeProduccion_PK + "' )"
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Proceso( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.

		if this.EsModoEdicion() and !empty( txVal ) and !empty( txValOld ) and !( alltrim( txVal ) == alltrim( txValOld ) )

			this.lContinuarConActualizacionDelDetalle = .f.
			this.EventoPreguntarActualizarDetalle()
			if this.lContinuarConActualizacionDelDetalle
				llRetorno = dodefault( txVal, txValOld )
			else
				llRetorno = .f.
				this.Proceso_PK = txValOld
			endif
		else
			llRetorno = dodefault( txVal, txValOld )
		endif
		Return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Proceso( txVal as variant ) as void
		local loOrden as Object, loItemProceso as Object, loItemInsumo as Object, loModelo as Object, loItemSalidaModelo as Object, lcOrdenDeProduccion_PK  as String, ;
			lcCurGest as String, lcCursorFin as String, lcSql as String, loInventario as Object, lnCantPendiente as Number

		loInventario = _Screen.Zoo.InstanciarEntidad( "inventario" )

		dodefault( txVal )

		if this.lHaCambiado_Proceso_PK

			lcOrdenDeProduccion_PK = This.OrdenDeProduccion_PK

			text to lcSql textmerge noshow
				select g.INVENTDEST, d.insumo, d.codcolor, d.codtalle, d.partida, 
				       case when i.CODART = '' then o.PRODUCTO else i.CODART end codart,
					   i.unidadr, sum( d.cantprod ) cantprod,
					   case when i.CODART = '' then i2.cantidadr else i.cantidadr end rinde, max(s.cocant) stockactual
				 from <<this.oAd.cEsquema>>.GESTIONPROD g 
				  inner join <<this.oAd.cEsquema>>.GESPCURV d on g.codigo = d.gesprodcur
				  left join <<this.oAd.cEsquema>>.ins i on d.insumo = i.INSCOD
				  inner join <<this.oAd.cEsquema>>.ordenprod o on g.ordendepro = o.codigo 
				  left join ( select top 1 codart, unidadr, cantidadr from <<this.oAd.cEsquema>>.ins ) i2 on o.producto = i2.codart 
				  left join <<this.oAd.cEsquema>>.stockinv s on  d.insumo = s.coart
												and d.codcolor = s.cocol
												and d.codtalle = s.talle
												and d.partida = s.nropartida
												and g.inventdest = s.invent
				 where g.ordendepro = '<<lcOrdenDeProduccion_PK>>'
				   and g.proceso = '<<txVal>>'
				   and d.insumo <> ''
				 group by g.INVENTDEST, d.insumo, d.codcolor, d.codtalle, d.partida, i.unidadr,
				          case when i.CODART = '' then o.PRODUCTO else i.CODART end,
				          case when i.CODART = '' then i2.cantidadr else i.cantidadr end
			endtext
			
			lcCurGest  = "c_" + sys(2015)
			goServicios.Datos.EjecutarSentencias( lcSql , "GESTIONPROD" , "", lcCurGest, this.DataSessionId )


		***restar cantidades ya finalizadas
			text to lcSql textmerge noshow
	  			select d.INVENTORIG, d.insumo, d.ccolor, d.talle, d.partida, sum(d.canti) cantfin
				 from <<this.oAd.cEsquema>>.FINALPROD f
				  inner join <<this.oAd.cEsquema>>.DETARTFINALPROD d on f.codigo = d.numr
				 where f.ordenprod = '<<lcOrdenDeProduccion_PK>>'
				   and f.proceso = '<<txVal>>'
				 group by d.INVENTORIG, d.insumo, d.ccolor, d.talle, d.partida
			endtext
			lcCursorFin  = "c_" + sys(2015)
			goServicios.Datos.EjecutarSentencias( lcSql , "FINALPROD" , "", lcCursorFin, this.DataSessionId )


			with this.MovimientoDetalle
				.Limpiar()
				select &lcCurGest
				scan

	*!*					if alltrim( loItemSalidaModelo.Proceso_PK ) == alltrim( txVal ) ;
	*!*					 and alltrim( loItemSalidaModelo.Color_PK ) == alltrim( loItemCurva.Color_PK ) ;
	*!*					 and alltrim( loItemSalidaModelo.Talle_PK ) == alltrim( loItemCurva.Talle_PK )

						lnCantPendiente = 0

						if isnull(&lcCurGest..rinde)
							replace &lcCurGest..rinde with 1
						endif
						if isnull(&lcCurGest..StockActual)
							replace &lcCurGest..StockActual with 0
						endif

						select &lcCursorFin
						locate for  INVENTORIG = &lcCurGest..inventdest ;
								and insumo = &lcCurGest..insumo ;
								and ccolor = &lcCurGest..codcolor ;
								and talle = &lcCurGest..codtalle ;
								and partida = &lcCurGest..partida 
						if found()
							lnCantPendiente = &lcCurGest..cantprod - &lcCursorFin..cantfin
							if lnCantPendiente < 0
								lnCantPendiente = 0
							endif
						else
							lnCantPendiente = &lcCurGest..cantprod
						endif

						loInventario.Codigo = &lcCurGest..inventdest
						if loInventario.ControlaStock
							if lnCantPendiente > &lcCurGest..StockActual
								lnCantPendiente = &lcCurGest..StockActual
								if lnCantPendiente < 0
									lnCantPendiente = 0
								endif
							endif
						endif

						if lnCantPendiente > 0 
							.LimpiarItem()
							.oItem.Inventario_PK = &lcCurGest..inventdest
							.oItem.Insumo_PK = &lcCurGest..insumo
							.oItem.Color_PK = &lcCurGest..codcolor
							.oItem.Talle_PK = &lcCurGest..codtalle
							.oItem.Partida = &lcCurGest..partida
							.oItem.Unidad_PK = &lcCurGest..unidadr
							.oItem.CantidadLimite = lnCantPendiente
							.oItem.Cantidad = lnCantPendiente
							.oItem.Articulo_PK = &lcCurGest..codart
							.oItem.ColorArt_PK = &lcCurGest..codcolor
							.oItem.TalleArt_PK = &lcCurGest..codtalle
							.oItem.UnidadStockDF_PK = .oItem.Articulo.UnidadDeMedida_PK
							.oItem.Rinde = &lcCurGest..rinde
							.oItem.CantidadStockDF = lnCantPendiente / iif( &lcCurGest..rinde = 0, 1, &lcCurGest..rinde )  

							.Actualizar()
						endif

	*!*					endif


				endscan
				This.EventoRefrescarDetalle( "MovimientoDetalle" )
			endwith

			if used( lcCurGest )
				use in (lcCurGest)
			endif
			if used( lcCursorFin )
				use in (lcCursorFin)
			endif

		endif

		loInventario.Release()


*!*			loOrden = _Screen.Zoo.InstanciarEntidad( "OrdenDeProduccion" )
*!*			loOrden.Codigo = This.OrdenDeProduccion_PK
*!*			loModelo = _Screen.Zoo.InstanciarEntidad( "ModeloDeProduccion" )
*!*			loModelo.Codigo = loOrden.Modelo_PK
*!*		
*!*			for each loItemProceso in loOrden.OrdenProcesos foxobject
*!*				if alltrim( loItemProceso.Proceso_PK ) == alltrim( txVal )
*!*					this.InventarioOrigen_PK = loItemProceso.InventarioEntrada_PK
*!*					this.InventarioDestino_PK = loItemProceso.InventarioSalida_PK
*!*					this.Taller_PK = loItemProceso.Taller_PK
*!*					exit
*!*				endif
*!*			endfor

*!*			
*!*			with this.GestionCurva
*!*				.Limpiar()
*!*				for each loItemCurva in loOrden.OrdenCurva foxobject
*!*					for each loItemSalidaModelo in loModelo.ModeloSalidas foxobject
*!*						if alltrim( loItemSalidaModelo.Proceso_PK ) == alltrim( txVal ) ;
*!*						 and alltrim( loItemSalidaModelo.Color_PK ) == alltrim( loItemCurva.Color_PK ) ;
*!*						 and alltrim( loItemSalidaModelo.Talle_PK ) == alltrim( loItemCurva.Talle_PK )
*!*							.LimpiarItem()
*!*							.oItem.ColorM_PK = loItemSalidaModelo.ColorM_PK
*!*							.oItem.TalleM_PK = loItemSalidaModelo.TalleM_PK
*!*							.oItem.Insumo_PK = loItemSalidaModelo.Semielaborado_PK
*!*							.oItem.Color_PK = loItemSalidaModelo.Color_PK
*!*							.oItem.Talle_PK = loItemSalidaModelo.Talle_PK
*!*							.oItem.CantProducida = loItemCurva.Total
*!*							.Actualizar()
*!*						endif
*!*					endfor
*!*				endfor
*!*				This.EventoRefrescarDetalle( "GestionCurva" )
*!*			endwith


*!*			with this.GestionInsumos
*!*				.Limpiar()
*!*				for each loItemInsumo in loOrden.OrdenInsumos foxobject
*!*					if alltrim( loItemInsumo.Proceso_PK ) == alltrim( txVal )
*!*						.LimpiarItem()
*!*						.oItem.ColorM_PK = loItemInsumo.ColorM_PK
*!*						.oItem.TalleM_PK = loItemInsumo.TalleM_PK
*!*						.oItem.Insumo_PK = loItemInsumo.Insumo_PK
*!*						.oItem.Color_PK = loItemInsumo.Color_PK
*!*						.oItem.Talle_PK = loItemInsumo.Talle_PK
*!*						.oItem.Cantidad = loItemInsumo.Cantidad * loOrden.Cantidad
*!*						.oItem.CantPorUnidad = loItemInsumo.Cantidad   &&&&&&&&&&&&&&&&&&&
*!*						.Actualizar()
*!*					endif
*!*				endfor
*!*				This.EventoRefrescarDetalle( "GestionInsumos" )
*!*			endwith

*!*			loOrden.Release()
*!*			loModelo.Release()
	endfunc


	*-----------------------------------------------------------------------------------------
	function RecalcularInsumosSegunItemActivoSalida() as Void
		local lnItemInsumo as Integer
		lcColor = this.GestionCurva.oItem.Color_PK
		lcTalle = this.GestionCurva.oItem.Talle_PK
		lnCantproducida = this.GestionCurva.oItem.CantProducida

		with this.GestionInsumos
			for lnI = 1 to .Count
				lnNroItem = .Item[ lnI ].NroItem
				.CargarItem( lnNroItem )
				if !empty( alltrim( .oItem.Insumo_PK ) )
					if alltrim( .oItem.ColorM_PK ) == alltrim( lcColor ) and alltrim( .oItem.TalleM_PK ) == alltrim( lcTalle )
						.oItem.Cantidad = .oItem.CantPorUnidad * lnCantProducida
						.Actualizar()
					endif
				endif
			endfor
			This.EventoRefrescarDetalle( "GestionInsumos" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularDescartesSegunItemActivoSalida() as Void
		local lnItemInsumo as Integer
		lcInsumo = this.GestionCurva.oItem.Insumo_PK
		lcColorM = this.GestionCurva.oItem.ColorM_PK
		lcTalleM = this.GestionCurva.oItem.TalleM_PK
		lcColor = this.GestionCurva.oItem.Color_PK
		lcTalle = this.GestionCurva.oItem.Talle_PK
		lnCantDescarte = this.GestionCurva.oItem.CantDescarte

		with this.GestionDescartes
			llDescarteEncontrado = .f.

			for lnI = 1 to .Count
				lnNroItem = .Item[ lnI ].NroItem
				if !empty( alltrim( .Item[ lnI ].Insumo_PK ) )
					if alltrim( .Item[ lnI ].ColorM_PK ) == alltrim( lcColorM ) and alltrim( .Item[ lnI ].TalleM_PK ) == alltrim( lcTalleM )
						.CargarItem( lnNroItem )
						.oItem.CantDescarte = lnCantDescarte
						.Actualizar()
						llDescarteEncontrado = .T.
					endif
				endif
			endfor

			if !llDescarteEncontrado and this.GestionCurva.oItem.CantDescarte > 0
				.LimpiarItem()
				.oItem.ColorM_PK = lcColorM
				.oItem.TalleM_PK = lcTalleM
				.oItem.Insumo_PK = lcInsumo
				.oItem.Color_PK = lcColor
				.oItem.Talle_PK = lcTalle
				.oItem.CantDescarte = lnCantDescarte
				.Actualizar()
			endif

		endwith


		for each loItemInsumo in this.GestionInsumos foxobject
			if alltrim( loItemInsumo.ColorM_PK ) == alltrim( lcColorM ) and alltrim( loItemInsumo.TalleM_PK ) == alltrim( lcTalleM )

				with this.GestionInsumosDescartes

					llInsumoDescarteEncontrado = .f.

					for lnI = 1 to .Count
						lnNroItem = .Item[ lnI ].NroItem
						.CargarItem( lnNroItem )
						if !empty( alltrim( .oItem.Insumo_PK ) )
							if   alltrim( .oItem.Insumo_PK ) == alltrim( loItemInsumo.Insumo_PK ) ;
							 and alltrim( .oItem.ColorM_PK ) == alltrim( lcColorM ) ;
							 and alltrim( .oItem.TalleM_PK ) == alltrim( lcTalleM )
								.oItem.Cantidad = lnCantDescarte * loItemInsumo.CantPorUnidad
								.Actualizar()
								llInsumoDescarteEncontrado = .T.
							endif
						endif
					endfor

					if !llInsumoDescarteEncontrado
						.LimpiarItem()
						.oItem.Insumo_PK = loItemInsumo.Insumo_PK
						.oItem.ColorM_PK = lcColorM
						.oItem.TalleM_PK = lcTalleM
						.oItem.Color_PK = loItemInsumo.Color_PK
						.oItem.Talle_PK = loItemInsumo.Talle_PK
						.oItem.Cantidad = lnCantDescarte * loItemInsumo.CantPorUnidad
						.Actualizar()
					endif

				endwith
			endif
		endfor

		This.EventoRefrescarDetalle( "GestionDescartes" )
		This.EventoRefrescarDetalle( "GestionInsumosDescartes" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsModoEdicion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.CargaManual() and !this.EstaEnProceso() and (this.EsNuevo() or this.EsEdicion())
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarActualizarDetalle() as Void
	endfunc 

enddefine
