define class ComponenteFinalDeProduccion as din_ComponenteFinalDeProduccion of din_ComponenteFinalDeProduccion.prg

	#IF .f.
		Local this as ComponenteFinalDeProduccion of ComponenteFinalDeProduccion.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		This.oEntidadPadre = toEntidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VotarCambioEstadoELIMINAR( tcEstado as String ) as boolean
		local llRetorno as Boolean, llAunExistenLosComprobantesRelacionados as Boolean
		llRetorno = .T.
		return llRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function VotarCambioEstadoGRABAR( tcEstado as String ) as boolean
		local llRetorno as Boolean, llRespuesta as Boolean
		llRetorno = .T.
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg
		local loColSentencias as zoocoleccion OF zoocoleccion.prg
		loColSentencias = dodefault()
		if This.lNuevo
			loColSentencias = This.ObtenerSentenciasDeGeneracionDeMovimientoDeStockDesdeProduccion( loColSentencias )
		else
			if This.lEliminar
				loColSentencias = This.ObtenerSentenciasDeEliminacionDeMovimientoDeStockDesdeProduccion( loColSentencias )
			endif
		endif		
		return loColSentencias
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeGeneracionDeMovimientoDeStockDesdeProduccion( toColSentencias as Object ) as ZooColeccion of ZooColeccion.prg
		local loMovStock as Object, loColSentenciasInsert as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loItem as Object, lnIndCol as Integer, lnCantidadGenerados as Integer, lcNumerosGenerados as String, loColSentencias as zoocoleccion OF zoocoleccion.prg, ;
		loColSentenciasComp as zoocoleccion OF zoocoleccion.prg, lcCursorInv as String

		if type( "toSentencias" ) = "O"
			loColSentencias = toColSentencias
		else
			loColSentencias = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		lnCantidadGenerados = 0
		lcNumerosGenerados = ""

		lcCursorInv  = "c_" + sys(2015)
		create cursor &lcCursorInv ( inventario c(100) )
		for each loItem in this.oEntidadPadre.MovimientoDetalle
			if !empty( alltrim( loItem.Inventario_PK ) ) and loItem.Cantidad > 0 and loItem.CantidadStockDF > 0
				select ( lcCursorInv )
				locate for alltrim( inventario ) == alltrim( loItem.Inventario_PK )
				if not found()
					insert into &lcCursorInv ( inventario ) values (loItem.Inventario_PK )
				endif
			endif
		endfor

		loMovStock = _screen.zoo.instanciarentidad("MovimientoStockDesdeProducc")

		select ( lcCursorInv )
		scan
			loMovStock.Nuevo()
			**this.lInvertirSigno = loMovStock.lInvertirSigno
			loMovStock.InventarioOrigen_pk = &lcCursorInv..inventario
			loMovStock.tipo = 2
			loMovStock.Zadsfw = "Generado automáticamente por el comprobante de Finalización de producción Nº " + alltrim( str( this.oEntidadPadre.Numero ) ) 
			loMovStock.oAd.GrabarNumeraciones()
			for each loItem in  this.oEntidadPadre.MovimientoDetalle
				if !empty(loItem.Insumo_Pk) and alltrim( loItem.Inventario_pk ) == alltrim( &lcCursorInv..inventario ) and loItem.Cantidad > 0 and loItem.CantidadStockDF > 0
					with loMovStock.MovimientoDetalle
						.LimpiarItem()
						.oItem.Insumo_Pk = loItem.Insumo_Pk
						.oItem.InsumoDetalle = alltrim( loItem.InsumoDetalle )
						.oItem.Color_PK = loItem.Color_PK
						.oItem.ColorDetalle = alltrim( loItem.ColorDetalle )
						.oItem.Talle_PK = loItem.Talle_PK
						.oItem.TalleDetalle = alltrim( loItem.TalleDetalle )
						.oItem.Partida = loItem.Partida
						.oItem.Unidad_PK = loItem.Unidad_PK
						.oItem.Cantidad = loItem.Cantidad

						.oItem.Articulo_Pk = loItem.Articulo_Pk
						.oItem.ArticuloDetalle = alltrim( loItem.ArticuloDetalle )
						.oItem.ColorArt_PK = loItem.ColorArt_PK
						.oItem.ColorArtDetalle = alltrim( loItem.ColorArtDetalle )
						.oItem.TalleArt_PK = loItem.TalleArt_PK
						.oItem.TalleArtDetalle = alltrim( loItem.TalleArtDetalle )
						.oItem.UnidadStockDF_PK = loItem.UnidadStockDF_PK
						**.oItem.UnidadStockDFDetalle = loItem.UnidadArtDetalle
						.oItem.Rinde = loItem.Rinde
						.oItem.CantidadStockDF = loItem.CantidadStockDF
						.Actualizar()
					endwith
				endif 
			endfor

			with loMovStock.Compafec
				with .oItem
					.tipoComprobante = this.oEntidadPadre.TipoComprobante
					.Letra = ''
					.PuntoDeVenta = 9999
					.Numero = this.oEntidadPadre.Numero
					.Afecta = this.oEntidadPadre.Codigo
					.TipoCompCaracter = alltrim( this.oEntidadPadre.cDescripcion ) + " Nº " + alltrim(transform( this.oEntidadPadre.Numero )) 
					.Fecha = this.oEntidadPadre.Fecha
					.Tipo = "Afectado"
					.Origen = this.oEntidadPadre.BaseDeDatosAltaFw
					.NombreEntidad = ""
				endwith 
				.actualizar()	
			endwith	

			lnCantidadGenerados = lnCantidadGenerados + 1
			lcNumerosGenerados = lcNumerosGenerados + iif( empty( lcNumerosGenerados ), "", ", " ) + alltrim( str( loMovStock.Numero ) )

			loColSentenciasInsert = loMovStock.oAD.ObtenerSentenciasInsert()
			with loMovStock.oCompMovimientoStockDesdeProducc
				.lNuevo = this.oEntidadPadre.EsNuevo()
				.lEdicion = this.oEntidadPadre.EsEdicion()
				.lEliminar = this.oEntidadPadre.lEliminar
				.lAnular = this.oEntidadPadre.lAnular
				loColSentenciasComp = .Grabar()
			endwith
			with loMovStock.MovimientoDetalle.oItem.oCompStockProduccion
				.lNuevo = this.oEntidadPadre.EsNuevo()
				.lEdicion = this.oEntidadPadre.EsEdicion()
				.lEliminar = this.oEntidadPadre.lEliminar
				.lAnular = this.oEntidadPadre.lAnular
				loColSentenciasAdic = .Grabar()
			endwith
			this.LlenarColeccionSentencias( loColSentenciasInsert, toColSentencias )
			this.LlenarColeccionSentencias( loColSentenciasComp, toColSentencias )
			this.LlenarColeccionSentencias( loColSentenciasAdic, toColSentencias )

			loMovStock.Cancelar()
		endscan

		toColSentencias.agregar( this.oEntidadPadre.ObtenerSentenciaAccionesDelSistema( lnCantidadGenerados, lcNumerosGenerados, loMovStock.cDescripcion ) )

		loMovStock.release()	
		if used( lcCursorInv )
			use in ( lcCursorInv )
		endif

		return toColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeEliminacionDeMovimientoDeStockDesdeProduccion( toColSentencias  as zoocoleccion OF zoocoleccion.prg ) as ZooColeccion of ZooColeccion.prg
		local loMovStock as Object, loColSentenciasDelete as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loColSentencias as zoocoleccion OF zoocoleccion.prg, loItem as Object, lnIndCol as Integer,  lcCursorCod as String, lcSql as String, ;
		lcCodigoMov as String, loColSentenciasComp as zoocoleccion OF zoocoleccion.prg

		if type( "toSentencias" ) = "O"
			loColSentencias = toColSentencias
		else
			loColSentencias = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif

		loMovStock = _screen.zoo.instanciarentidad("MovimientoStockDesdeProducc")

		lcCursorCod  = "c_" + sys(2015)
		lcSql = "select codigo from compafe where afecta = '" + this.oEntidadPadre.Codigo + "' and lower(afetipo) = 'afectado' and afetipocom = " + str( this.oEntidadPadre.TipoComprobante, 3, 0 )
		goServicios.Datos.EjecutarSentencias(  lcSql, "compafe", "", lcCursorCod, this.datasessionid )

		select ( lcCursorCod )
		scan
			lcCodigoMov = &lcCursorCod..Codigo

			with loMovStock
				.Codigo = lcCodigoMov
				
				.RestaurarStock()

				.lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .t.
				if .ValidarAnulacion()

					loColSentenciasDelete = .oad.ObtenerSentenciasDelete()

					with loMovStock.oCompMovimientoStockDesdeProducc
						.lNuevo = this.oEntidadPadre.EsNuevo()
						.lEdicion = this.oEntidadPadre.EsEdicion()
						.lEliminar = this.oEntidadPadre.lEliminar
						.lAnular = this.oEntidadPadre.lAnular
						loColSentenciasComp = .Grabar()
					endwith
					with loMovStock.MovimientoDetalle.oItem.oCompStockProduccion
						.lNuevo = this.oEntidadPadre.EsNuevo()
						.lEdicion = this.oEntidadPadre.EsEdicion()
						.lEliminar = this.oEntidadPadre.lEliminar
						.lAnular = this.oEntidadPadre.lAnular
						**.lInvertirSigno = ! .lInvertirSigno 
						loColSentenciasAdic = .Grabar()
					endwith

					this.LlenarColeccionSentencias( loColSentenciasDelete, toColSentencias )
					this.LlenarColeccionSentencias( loColSentenciasComp, toColSentencias )
					this.LlenarColeccionSentencias( loColSentenciasAdic, toColSentencias )

				endif
				.lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .f.

			endwith
		endscan

		if used( lcCursorCod )
			use in select ( lcCursorCod )
		endif
		loMovStock.release()	

		return toColSentencias
	endfunc 

    *-----------------------------------------------------------------------------------------
	protected function LlenarColeccionSentencias( toColOrigen as zoocoleccion OF zoocoleccion.prg, toColDestino as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcItem as String
		for each lcItem in toColOrigen
			toColDestino.Agregar( lcItem )
		EndFor	
	endfunc 

enddefine
