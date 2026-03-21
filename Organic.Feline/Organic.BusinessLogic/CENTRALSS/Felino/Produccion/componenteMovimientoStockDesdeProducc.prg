define class ComponenteMovimientoStockDesdeProducc as din_ComponenteMovimientoStockDesdeProducc of din_ComponenteMovimientoStockDesdeProducc.prg

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
		with this
			if .lNuevo
				loColSentencias = .ObtenerSentenciasDeGeneracionDeMovimientoDeStockDragon( loColSentencias )
			else
				if .lEliminar
					loColSentencias = .ObtenerSentenciasDeEliminacionDeMovimientoDeStockDragon( loColSentencias )
				endif
			endif		
		endwith
		return loColSentencias		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeGeneracionDeMovimientoDeStockDragon( toColSentencias as Object ) as ZooColeccion of ZooColeccion.prg
		local loMovStock as Object, loColSentenciasInsert as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loColSentencias as zoocoleccion OF zoocoleccion.prg, loItem as Object, lnIndCol as Integer

		if type( "toSentencias" ) = "O"
			loColSentencias = toColSentencias
		else
			loColSentencias = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif

		loMovStock = _screen.zoo.instanciarentidad("MovimientoDeStock")
		**loMovStock.lInvertirSigno = !loMovStock.lInvertirSigno

		with loMovStock
			.Nuevo()
			.OrigenDestino_pk = this.oEntidadPadre.ObtenerOrigenDestinoParaBaseActiva()
			.tipo = 1
			.Zadsfw = "Generado automáticamente por el movimiento de insumos desde producción Nº " + alltrim( str( this.oEntidadPadre.Numero ) ) ;
					+ " (Invetario origen: " + alltrim( this.oEntidadPadre.InventarioOrigen_PK ) + ")"

			.oAd.GrabarNumeraciones()
			for each loItem in  this.oEntidadPadre.MovimientoDetalle
				if !empty(loItem.Articulo_pk)
					with loMovStock.MovimientoDetalle
						.oitem.articulo_pk = loItem.articulo_pk
						.oitem.articuloDetalle = loItem.Articulodetalle 
						.oitem.Color_pk = loItem.color_pk
						.oitem.ColorDetalle = loItem.colordetalle
						.oitem.Talle_pk = loItem.talle_pk
						.oitem.cantidad = loItem.cantidadStockDF
						.Actualizar()
						.LimpiarItem()
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

			loColSentenciasInsert = .oAD.ObtenerSentenciasInsert()
			with loMovStock.MovimientoDetalle.oItem.oCompStock
				.lNuevo = this.oEntidadPadre.EsNuevo()
				.lEdicion = this.oEntidadPadre.EsEdicion()
				.lEliminar = this.oEntidadPadre.lEliminar
				.lAnular = this.oEntidadPadre.lAnular
				loColSentenciasAdic = .Grabar()
			endwith
			this.LlenarColeccionSentencias( loColSentenciasInsert, toColSentencias )
			this.LlenarColeccionSentencias( loColSentenciasAdic, toColSentencias )
		endwith

		toColSentencias.agregar( this.oEntidadPadre.ObtenerSentenciaAccionesDelSistema( 1, alltrim( str( loMovStock.Numero ) ), loMovStock.cDescripcion ) )
		loMovStock.release()

		return toColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeEliminacionDeMovimientoDeStockDragon( toColSentencias  as zoocoleccion OF zoocoleccion.prg ) as ZooColeccion of ZooColeccion.prg
		local loMovStock as Object, loColSentenciasDelete as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loColSentencias as zoocoleccion OF zoocoleccion.prg, loItem as Object, lnIndCol as Integer

		if type( "toSentencias" ) = "O"
			loColSentencias = toColSentencias
		else
			loColSentencias = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif

		loMovStock = _screen.zoo.instanciarentidad("MovimientoDeStock")
		with loMovStock
			.Codigo = this.ObtenerCodigoDeMovimientoDeStock()

			.lSaltearValidacionProduccion = .t.
			if .ValidarAntesDeAnularForzadaParaProduccion()

				loColSentenciasDelete = .oad.ObtenerSentenciasDelete()
				with .MovimientoDetalle.oItem.oCompStock
					.lNuevo = .f.
					.lEdicion = .f.
					.lEliminar = .t.
					.lAnular = .f.
					.lInvertirSigno = ! .lInvertirSigno 
					loColSentenciasAdic = .Grabar()
				endwith

				for lnIndCol = 1 to loColSentenciasDelete.count
					toColSentencias .agregar( loColSentenciasDelete.item(lnIndCol) )
				endfor
				for lnIndCol = 1 to loColSentenciasAdic.count
				      toColSentencias .agregar( loColSentenciasAdic.item(lnIndCol) )
				endfor

			endif
			.lSaltearValidacionProduccion = .f.

			.release()	
		endwith

		return toColSentencias
	endfunc 

    *-----------------------------------------------------------------------------------------
	protected function LlenarColeccionSentencias( toColOrigen as zoocoleccion OF zoocoleccion.prg, toColDestino as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcItem as String
		for each lcItem in toColOrigen
			toColDestino.Agregar( lcItem )
		EndFor	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCodigoDeMovimientoDeStock() as String
		local lcCodigo as String, lcXml as String, lcCursorCod as String, lcSql as String
		lcCodigo = ""
		lcCursorCod  = "c_" + sys(2015)
		lcSql = "select codigo from compafe where afecta = '" + this.oEntidadPadre.Codigo + "' and lower(afetipo) = 'afectado' and afetipocom = 92 " 
		goServicios.Datos.EjecutarSentencias(  lcSql, "compafe", "", lcCursorCod, this.datasessionid )
		lcCodigo = &lcCursorCod..Codigo
		use in select ( lcCursorCod )
		return lcCodigo
	endfunc 

enddefine
