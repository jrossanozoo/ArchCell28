define class ent_GestionDeProduccion as din_EntidadGestionDeProduccion of din_EntidadGestionDeProduccion.prg

	#If .F.
		Local This As ent_GestionDeProduccion of ent_GestionDeProduccion.prg
	#Endif

	TipoComprobante = 91

	lHaCambiado_Proceso_PK = .f.

	lContinuarActualizacionInsumosConSalidasMultiples = .f.
	lYaHizoLaPreguntaDeSalidasMultiples = .f.
	lDebeLoguearPreguntaDeSalidasMultiplesAfirmativa = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		bindevent( this.GestionCurva.oItem, "EventoRecalcularInsumosSegunItemActivoSalida", this, "RecalcularInsumosSegunItemActivoSalida" )
		bindevent( this.GestionCurva.oItem, "EventoRecalcularDescartesSegunItemActivoSalida", this, "RecalcularDescartesSegunItemActivoSalida" )
		this.oCompGestionDeProduccion.InyectarEntidad( this )
		this.GestionCurva.oItem.InyectarEntidad( This )
	endfunc

	*-------------------------------------------------------------------------------------------------
	Function Nuevo()
		dodefault()
		this.lContinuarActualizacionInsumosConSalidasMultiples = .f.
		this.lYaHizoLaPreguntaDeSalidasMultiples = .f.
		this.lDebeLoguearPreguntaDeSalidasMultiplesAfirmativa = .f.
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Proceso( txVal as variant ) as void
		local loOrden as Object, loItemProceso as Object, loItemInsumo as Object, loItemSalida as Object, loItemCurva as Object, ;
			lnCantAProducir as Number, lnCantYaProducida as Number, lcCursorCantProd  as String, lcSql as String, ;
			lcColorCurvaAnterior as String, lcTalleCurvaAnterior as String

		dodefault( txVal )

		if this.lHaCambiado_Proceso_PK

			loOrden = _Screen.Zoo.InstanciarEntidad( "OrdenDeProduccion" )
			loOrden.Codigo = This.OrdenDeProduccion_PK

			this.InventarioOrigen_PK = ""
			this.InventarioDestino_PK = ""
			this.Taller_PK = ""

			for each loItemProceso in loOrden.OrdenProcesos foxobject
				if alltrim( loItemProceso.Proceso_PK ) == alltrim( txVal )
					this.InventarioOrigen_PK = loItemProceso.InventarioEntrada_PK
					this.InventarioDestino_PK = loItemProceso.InventarioSalida_PK
					this.Taller_PK = loItemProceso.Taller_PK
					exit
				endif
			endfor

			text to lcSql textmerge noshow
	  			select d.martdf as articulo, d.ccolor as color_art, d.ctalle as talle_art, d.insumo, d.codcolor, d.codtalle, sum(d.cantprod + d.cantdesc) cantidad
				 from zoologic.GestionProd g
				  inner join zoologic.GESPCURV d on g.codigo = d.GesProdCur
				 where g.ordendepro = '<<This.OrdenDeProduccion_PK>>'
				   and g.proceso = '<<txVal>>'
				   and d.insumo <> ''
				 group by d.martdf, d.ccolor, d.ctalle, d.insumo, d.codcolor, d.codtalle
			endtext
			lcCursorCantProd  = "c_" + sys(2015)
			goServicios.Datos.EjecutarSentencias( lcSql , "GESTIONPROD" , "", lcCursorCantProd, this.DataSessionId )

			this.GestionCurva.Limpiar()
			this.GestionInsumos.Limpiar()
			this.GestionDescartes.Limpiar()
			this.GestionInsumosDescartes.Limpiar()

			with this.GestionCurva
				.Limpiar()
				for each loItemSalida in loOrden.OrdenSalidas foxobject
					if alltrim( loItemSalida.Proceso_PK ) == alltrim( txVal )

						lnCantAProducir = 0
						for each loItemCurva in loOrden.OrdenCurva foxobject
							if !empty( loItemCurva.Producto_PK ) ;
							 and alltrim( loItemCurva.Color_PK ) == alltrim( loItemSalida.ColorM_PK ) ;
							 and alltrim( loItemCurva.Talle_PK ) == alltrim( loItemSalida.TalleM_PK )
								lnCantAProducir = loItemCurva.Total * loItemSalida.Cantidad
								exit
							endif
						endfor

						lnCantYaProducida = 0
						select ( lcCursorCantProd )
						locate for articulo = loOrden.ProductoFinal_PK and color_art = loItemSalida.ColorM_PK and talle_art = loItemSalida.TalleM_PK ;
						 and insumo = loItemSalida.Semielaborado_PK and codcolor = loItemSalida.Color_PK and codtalle = loItemSalida.Talle_PK
						if found()
							lnCantYaProducida = &lcCursorCantProd..cantidad
						endif

						if lnCantYaProducida < lnCantAProducir
							.LimpiarItem()
							.oItem.Articulo_PK = loOrden.ProductoFinal_PK
							.oItem.ColorM_PK = loItemSalida.ColorM_PK
							.oItem.TalleM_PK = loItemSalida.TalleM_PK
							.oItem.Insumo_PK = loItemSalida.Semielaborado_PK
							.oItem.Color_PK = loItemSalida.Color_PK
							.oItem.Talle_PK = loItemSalida.Talle_PK
							.oItem.CantProducida = lnCantAProducir - lnCantYaProducida 
							.Actualizar()
						endif
					endif
				endfor
			endwith

			with this.GestionInsumos
				.Limpiar()
				lcColorCurvaAnterior = ""
				lcTalleCurvaAnterior = ""
				for each loItemCurva in this.GestionCurva foxobject
					if !empty( loItemCurva.Insumo_PK )

						if !( lcColorCurvaAnterior == loItemCurva.ColorM_PK and lcTalleCurvaAnterior == loItemCurva.TalleM_PK )

							for each loItemInsumo in loOrden.OrdenInsumos foxobject
								if alltrim( loItemInsumo.Proceso_PK ) == alltrim( txVal );
								   and alltrim( loItemInsumo.ColorM_PK ) == alltrim( loItemCurva.ColorM_PK ) ;
								   and alltrim( loItemInsumo.TalleM_PK ) == alltrim( loItemCurva.TalleM_PK )

									.LimpiarItem()
									.oItem.Articulo_PK = loOrden.ProductoFinal_PK
									.oItem.ColorM_PK = loItemInsumo.ColorM_PK
									.oItem.TalleM_PK = loItemInsumo.TalleM_PK
									.oItem.Insumo_PK = loItemInsumo.Insumo_PK
									.oItem.Color_PK = loItemInsumo.Color_PK
									.oItem.Talle_PK = loItemInsumo.Talle_PK

									.oItem.Cantidad = ( loItemInsumo.Cantidad * loItemCurva.CantProducida / iif( loItemSalida.Cantidad = 0, 1, loItemSalida.Cantidad ) )

									.oItem.CantPorUnidad = loItemInsumo.Cantidad
									.Actualizar()
								endif
							endfor

						endif
						lcColorCurvaAnterior = loItemCurva.ColorM_PK
						lcTalleCurvaAnterior = loItemCurva.TalleM_PK
					endif
				endfor
			endwith

			This.EventoRefrescarDetalle( "GestionCurva" )
			This.EventoRefrescarDetalle( "GestionInsumos" )
			This.EventoRefrescarDetalle( "GestionDescartes" )
			This.EventoRefrescarDetalle( "GestionInsumosDescartes" )

			loOrden.Release()
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorGestion( toBusqueda as Object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorOrden( toBusqueda as Object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorProceso( toBusqueda as Object ) as Void
		local lcTablaProcesos as String
		toBusqueda.Tabla = toBusqueda.Tabla + "," + This.OrdenDeProduccion.oAd.ObtenerTablaDetalle( "OrdenProcesos" )
		lcTablaProcesos = iif( !empty( this.oAd.cEsquema ), this.oAd.cEsquema + ".", "" ) + This.OrdenDeProduccion.oAd.ObtenerTablaDetalle( "OrdenProcesos" )
		toBusqueda.Filtro = toBusqueda.Filtro + " and ProcProduc.codigo in ( select codigo from " + lcTablaProcesos + " where codorden = '" + this.OrdenDeProduccion_PK + "' )"
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularInsumosSegunItemActivoSalida() as Void
		local lnItemInsumo as Integer, lnNroItem  as Integer, lcArticulo as String, lcColor as String, lcTalle as String, lnCantProducida as Number, ;
			lcSemielaborado as String, lnCantSalidaPorUnidad as Number, loItemCurva as object, loItemSalidaOrden as Object

		lcArticulo = this.GestionCurva.oItem.Articulo_PK
		lcColor = this.GestionCurva.oItem.ColorM_PK
		lcTalle = this.GestionCurva.oItem.TalleM_PK
		lnCantproducida = this.GestionCurva.oItem.CantProducida
		lcSemielaborado = this.GestionCurva.oItem.Insumo_PK

		if lnCantproducida = 0
			this.EliminarInsumos( lcArticulo, lcColor, lcTalle )
		else

			with this.GestionInsumos
				for lnItemInsumo = 1 to .Count

					lnNroItem = .Item[ lnItemInsumo ].NroItem
					.CargarItem( lnNroItem )

					lnCantSalidaPorUnidad = 1
					for each loItemSalidaOrden in this.OrdenDeProduccion.OrdenSalidas foxobject
						if   alltrim( loItemSalidaOrden.Proceso_PK ) == alltrim( this.Proceso_PK );
						 and alltrim( loItemSalidaOrden.Semielaborado_PK ) == alltrim( lcSemielaborado );
						 and alltrim( loItemSalidaOrden.ColorM_PK ) == alltrim( lcColor );
						 and alltrim( loItemSalidaOrden.TalleM_PK ) == alltrim( lcTalle )
							lnCantSalidaPorUnidad = loItemSalidaOrden.Cantidad
							exit
						endif
					endfor

					if !empty( alltrim( .oItem.Insumo_PK ) )
						if alltrim( .oItem.Articulo_PK ) == alltrim( lcArticulo ) and alltrim( .oItem.ColorM_PK ) == alltrim( lcColor ) and alltrim( .oItem.TalleM_PK ) == alltrim( lcTalle )
							.oItem.Cantidad = .oItem.CantPorUnidad * lnCantProducida / lnCantSalidaPorUnidad
							.Actualizar()
						endif
					endif
				endfor
				This.EventoRefrescarDetalle( "GestionInsumos" )
			endwith

		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularDescartesSegunItemActivoSalida() as Void
		local lnItemInsumo as Integer, lcArticulo as String, lcColorM as String, lcTalleM as String, lcInsumo as String, lcColor as String, lcTalle as String, ;
			lnCantDescarte as Integer, llDescarteEncontrado as Boolean, lnI as Integer, lnNroItem as Integer, loItemInsumo as Object, llInsumoDescarteEncontrado as Boolean, ;
			loItemSalidaOrden as Object, lnCantSalidaPorUnidad as Number

		lcArticulo = this.GestionCurva.oItem.Articulo_PK
		lcColorM = this.GestionCurva.oItem.ColorM_PK
		lcTalleM = this.GestionCurva.oItem.TalleM_PK
		lcInsumo = this.GestionCurva.oItem.Insumo_PK
		lcColor = this.GestionCurva.oItem.Color_PK
		lcTalle = this.GestionCurva.oItem.Talle_PK
		lnCantDescarte = this.GestionCurva.oItem.CantDescarte

		if lnCantDescarte = 0
			this.EliminarDescartes( lcArticulo, lcColorM, lcTalleM, lcInsumo )
			this.EliminarInsumosDescartes( lcArticulo, lcColorM, lcTalleM, lcInsumo )
		else
			with this.GestionDescartes
				llDescarteEncontrado = .f.

				for lnI = 1 to .Count
					lnNroItem = .Item[ lnI ].NroItem
					if !empty( alltrim( .Item[ lnI ].Insumo_PK ) )
						if  alltrim( .Item[ lnI ].Articulo_PK ) == alltrim( lcArticulo ) and alltrim( .Item[ lnI ].ColorM_PK ) == alltrim( lcColorM ) and alltrim( .Item[ lnI ].TalleM_PK ) == alltrim( lcTalleM ) ;
							and alltrim( .Item[ lnI ].Insumo_PK ) == alltrim( lcInsumo ) and alltrim( .Item[ lnI ].Color_PK ) == alltrim( lcColor ) and alltrim( .Item[ lnI ].Talle_PK ) == alltrim( lcTalle )

							if lnCantDescarte > 0
								.CargarItem( lnNroItem )
								.oItem.CantDescarte = lnCantDescarte
								.Actualizar()
							else
								.Quitar( lnI )
							endif

							llDescarteEncontrado = .T.
						endif
					endif
				endfor

				if !llDescarteEncontrado and this.GestionCurva.oItem.CantDescarte > 0
					.LimpiarItem()
					.oItem.Articulo_PK = lcArticulo
					.oItem.ColorM_PK = lcColorM
					.oItem.TalleM_PK = lcTalleM
					.oItem.Insumo_PK = lcInsumo
					.oItem.Color_PK = lcColor
					.oItem.Talle_PK = lcTalle
					.oItem.CantDescarte = lnCantDescarte
					.Actualizar()
				endif

				lnCantSalidaPorUnidad = 1
				for each loItemSalidaOrden in this.OrdenDeProduccion.OrdenSalidas foxobject
					if   alltrim( loItemSalidaOrden.Proceso_PK ) == alltrim( this.Proceso_PK );
					 and alltrim( loItemSalidaOrden.Semielaborado_PK ) == alltrim( lcInsumo );
					 and alltrim( loItemSalidaOrden.ColorM_PK ) == alltrim( lcColorM );
					 and alltrim( loItemSalidaOrden.TalleM_PK ) == alltrim( lcTalleM )
						lnCantSalidaPorUnidad = loItemSalidaOrden.Cantidad
						exit
					endif
				endfor

			endwith

			for each loItemInsumo in this.OrdenDeProduccion.OrdenInsumos foxobject
				if alltrim( loItemInsumo.Proceso_PK ) == alltrim( this.Proceso_PK ) and alltrim( loItemInsumo.ColorM_PK ) == alltrim( lcColorM ) and alltrim( loItemInsumo.TalleM_PK ) == alltrim( lcTalleM )

					with this.GestionInsumosDescartes

						llInsumoDescarteEncontrado = .f.

						for lnI = .Count to 1 step -1 
							lnNroItem = .Item[ lnI ].NroItem
							if !empty( alltrim( .Item[ lnI ].Insumo_PK ) )
								if   alltrim( .Item[ lnI ].Articulo_PK ) == alltrim( lcArticulo ) ;
								 and alltrim( .Item[ lnI ].ColorM_PK ) == alltrim( lcColorM ) ;
								 and alltrim( .Item[ lnI ].TalleM_PK ) == alltrim( lcTalleM ) ;
								 and alltrim( .Item[ lnI ].Insumo_PK ) == alltrim( loItemInsumo.Insumo_PK ) ;
								 and alltrim( .Item[ lnI ].Color_PK ) == alltrim( loItemInsumo.Color_PK ) ;
								 and alltrim( .Item[ lnI ].Talle_PK ) == alltrim( loItemInsumo.Talle_PK ) 
									if lnCantDescarte > 0
										.CargarItem( lnNroItem )
										.oItem.Cantidad = lnCantDescarte * loItemInsumo.Cantidad / lnCantSalidaPorUnidad
										.Actualizar()
									else
										.Quitar( lnNroItem )
									endif
									llInsumoDescarteEncontrado = .T.
								endif
							endif
						endfor

						if !llInsumoDescarteEncontrado
							.LimpiarItem()
							.oItem.Articulo_PK = lcArticulo
							.oItem.Insumo_PK = loItemInsumo.Insumo_PK
							.oItem.ColorM_PK = lcColorM
							.oItem.TalleM_PK = lcTalleM
							.oItem.Color_PK = loItemInsumo.Color_PK
							.oItem.Talle_PK = loItemInsumo.Talle_PK
							.oItem.Cantidad = lnCantDescarte * loItemInsumo.Cantidad / lnCantSalidaPorUnidad
							.Actualizar()
						endif

					endwith
				endif
			endfor

			This.EventoRefrescarDetalle( "GestionDescartes" )
			This.EventoRefrescarDetalle( "GestionInsumosDescartes" )
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function EliminarInsumos( tcArticulo_PK as String, tcColorM_PK as String, tcTalleM_PK as String ) as Void
		local lnI as Integer, lnItemsInsumosEliminados as Integer
		lnItemsInsumosEliminados = 0
		with this.GestionInsumos
			for lnI = .Count to 1 step -1
				if .Item[lnI].Articulo_PK = tcArticulo_PK and .Item[lnI].ColorM_PK = tcColorM_PK and .Item[lnI].TalleM_PK = tcTalleM_PK
					.Quitar( lnI )
					lnItemsInsumosEliminados = lnItemsInsumosEliminados + 1
				endif
			endfor
			if lnItemsInsumosEliminados > 0
				this.RenumerarNroItemDelDetalle( "GestionInsumos" )
				This.EventoRefrescarDetalle( "GestionInsumos" )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarDescartes( tcArticulo_PK as String, tcColorM_PK as String, tcTalleM_PK as String, tcInsumo_PK as String ) as Void
		local lnI as Integer, lnItemsDescartesEliminados as Integer
		lnItemsDescartesEliminados = 0
		with this.GestionDescartes
			for lnI = .Count to 1 step -1
				if .Item[lnI].Articulo_PK = tcArticulo_PK and .Item[lnI].ColorM_PK = tcColorM_PK and .Item[lnI].TalleM_PK = tcTalleM_PK and .Item[lnI].Insumo_PK = tcInsumo_PK
					.Quitar( lnI )
					lnItemsDescartesEliminados = lnItemsDescartesEliminados + 1
				endif
			endfor
			if lnItemsDescartesEliminados > 0
				this.RenumerarNroItemDelDetalle( "GestionDescartes" )
				This.EventoRefrescarDetalle( "GestionDescartes" )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarInsumosDescartes( tcArticulo_PK as String, tcColorM_PK as String, tcTalleM_PK as String, tcInsumo_PK as String ) as Void
		local lnI as Integer, lnItemsInsumosDescartesEliminados as Integer
		lnItemsInsumosDescartesEliminados = 0
		with this.GestionInsumosDescartes
			for lnI = .Count to 1 step -1
				if .Item[lnI].Articulo_PK = tcArticulo_PK and .Item[lnI].ColorM_PK = tcColorM_PK and .Item[lnI].TalleM_PK = tcTalleM_PK  && and .Item[lnI].Insumo_PK = tcInsumo_PK
					.Quitar( lnI )
					lnItemsInsumosDescartesEliminados = lnItemsInsumosDescartesEliminados + 1
				endif
			endfor
			if lnItemsInsumosDescartesEliminados > 0
				this.RenumerarNroItemDelDetalle( "GestionInsumosDescartes" )
				This.EventoRefrescarDetalle( "GestionInsumosDescartes" )
			endif
		endwith
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_OrdenDeProduccion( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal )
			this.lHabilitarOrdenDeProduccion_PK = .f.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ExistenSalidasMultiplesEnElProceso( tcArticulo_PK as String, tcColorM_PK as String, tcTalleM_PK as String ) as Boolean
		local llHaySalidasMultiples as Boolean, lnI as Integer, lnCantidadDeSalidasEncontradas as Integer
		llHaySalidasMultiples = .f.
		lnCantidadDeSalidasEncontradas = 0

		with this.GestionCurva
			for lnI = 1 to .Count
				if alltrim( .Item[ lnI ].Articulo_PK ) == alltrim( tcArticulo_PK ) and alltrim( .Item[ lnI ].ColorM_PK ) == alltrim( tcColorM_PK ) and alltrim( .Item[ lnI ].TalleM_PK ) == alltrim( tcTalleM_PK )
					lnCantidadDeSalidasEncontradas = lnCantidadDeSalidasEncontradas + 1
				endif
			endfor
		endwith
		if lnCantidadDeSalidasEncontradas > 1
			llHaySalidasMultiples = .t.
		endif

		return llHaySalidasMultiples
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.lDebeLoguearPreguntaDeSalidasMultiplesAfirmativa
			this.Loguear( "Gestión de producción Nro " + alltrim( str( this.Numero, 12, 0 ) ) + ". " ;
						+ "Se ha respondido que sí a la pregunta sobre permitir continuar modificando o eliminando ítems en la gestión " ;
						+ "de producción aún cuando los cálculos automáticos de insumos pudieran no realizarse correctamente por existir " ;
						+ "salidas múltiples para el mismo proceso de producción." )
		endif
		llRetorno = dodefault()
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RenumerarNroItemDelDetalle( tcNombreDetalle as String ) as Void
		local loItem as object, lnI as integer, lcDetalle as String
		lcDetalle = "this." + tcNombreDetalle
		lnI = 0
		for each loItem in ( lcDetalle ) foxobject
			if loItem.NroItem != 0
				lnI = lnI + 1
				loItem.NroItem = lnI
			endif
		endfor
	endfunc

enddefine
