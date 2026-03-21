define class ComponenteGestionDeProduccion as din_ComponenteGestionDeProduccion of din_ComponenteGestionDeProduccion.prg

	#IF .f.
		Local this as ComponenteGestionDeProduccion of ComponenteGestionDeProduccion.prg
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
			loColSentencias = This.ObtenerSentenciasDeGeneracionDeMovimientosDeInsumos( loColSentencias )
		else
			if This.lEliminar
				loColSentencias = This.ObtenerSentenciasDeEliminacionDeMovimientosDeInsumos( loColSentencias )
			endif
		endif		
		return loColSentencias
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeGeneracionDeMovimientosDeInsumos( toColSentencias as Object ) as ZooColeccion of ZooColeccion.prg
		local loMovStock as Object, loColSentenciasInsert as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loItem as Object, lnIndCol as Integer, lnCantidadGenerados as Integer, lcNumerosGenerados as String, loColSentencias as zoocoleccion OF zoocoleccion.prg, ;
		loColSentenciasComp as zoocoleccion OF zoocoleccion.prg, lcCursorInvDescartes as String, lnCantInventariosDescartes as Integer, lnCantComprobantesPosibles as Integer, ;
		lcInventario_PK as String, loObtetoDetalle as Object, lnI as Integer, lcDetalle as String, lnTipoEntradaSalida as Integer, ;
		lcCampoCantidad as String, lcInventario_PK as String, lnCantItemsAgregados as Integer

		if type( "toSentencias" ) = "O"
			loColSentencias = toColSentencias
		else
			loColSentencias = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		lnCantidadGenerados = 0
		lcNumerosGenerados = ""

		loMovStock = _screen.zoo.instanciarentidad("MovimientoStockAInvent")

		lnCantInventariosDescartes = 0
		lcCursorInvDescartes = "c_" + sys(2015)
		create cursor &lcCursorInvDescartes ( inventario c(100) )
		for each loItem in this.oEntidadPadre.GestionDescartes
			if !empty( alltrim( loItem.InventarioDest_PK ) )
				select ( lcCursorInvDescartes )
				locate for alltrim( inventario ) == alltrim( loItem.InventarioDest_PK )
				if not found()
					lnCantInventariosDescartes = lnCantInventariosDescartes + 1
					insert into &lcCursorInvDescartes ( inventario ) values (loItem.InventarioDest_PK )
				endif
			endif
		endfor

		lnCantComprobantesPosibles = 3 + lnCantInventariosDescartes
		for lnI = 1 to lnCantComprobantesPosibles

			do case
				case lnI = 1
					lcDetalle = "GestionInsumos"
					lnTipoEntradaSalida = 2
					lcCampoCantidad = "Cantidad"
					lcInventario_PK = this.oEntidadPadre.InventarioOrigen_PK
				case lnI = 2
					lcDetalle = "GestionCurva"
					lnTipoEntradaSalida = 1
					lcCampoCantidad = "CantProducida"
					lcInventario_PK = this.oEntidadPadre.InventarioDestino_PK
				case lnI = 3
					lcDetalle = "GestionInsumosDescartes"
					lnTipoEntradaSalida = 2
					lcCampoCantidad = "Cantidad"
					lcInventario_PK = this.oEntidadPadre.InventarioOrigen_PK
				otherwise
					lcDetalle = "GestionDescartes"
					lnTipoEntradaSalida = 1
					lcCampoCantidad = "CantDescarte"

					select ( lcCursorInvDescartes )
					go ( lnI - 3 )
					lcInventario_PK = &lcCursorInvDescartes..inventario
			endcase

			if this.oEntidadPadre.&lcDetalle..Count > 0
				loMovStock.Nuevo()
				loMovStock.tipo = lnTipoEntradaSalida
				loMovStock.InventarioOrigen_pk = lcInventario_PK
				loMovStock.Zadsfw = "Generado automáticamente por el comprobante de Gestión de orden de producción Nº " + alltrim( str( this.oEntidadPadre.Numero ) ) 

				loMovStock.oAd.GrabarNumeraciones()

				lnCantItemsAgregados = 0

				loObtetoDetalle = this.oEntidadPadre.&lcDetalle
				for each loItem in loObtetoDetalle
					if !empty(loItem.Insumo_pk) and loItem.&lcCampoCantidad > 0

						if lcDetalle <> "GestionDescartes" or ( lcDetalle = "GestionDescartes" and alltrim( loItem.InventarioDest_PK ) == alltrim( lcInventario_PK ) )
							with loMovStock.MovimientoDetalle
								.LimpiarItem()
								.oItem.Insumo_PK = loItem.Insumo_pk
								.oItem.InsumoDetalle = alltrim( loItem.InsumoDetalle )
								.oItem.Color_PK = loItem.Color_PK
								.oItem.ColorDetalle = alltrim( loItem.ColorDetalle )
								.oItem.Talle_PK = loItem.Talle_PK
								.oItem.TalleDetalle = alltrim( loItem.TalleDetalle )
								.oItem.Partida = loItem.Partida
								.oItem.Cantidad = loItem.&lcCampoCantidad
								.Actualizar()

								lnCantItemsAgregados = lnCantItemsAgregados + 1
							endwith
						endif

					endif 
				endfor

				if lnCantItemsAgregados > 0
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
					with loMovStock.oCompMovimientoStockAInvent
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
				endif

				loMovStock.Cancelar()
			endif

		endfor

		toColSentencias.agregar( this.oEntidadPadre.ObtenerSentenciaAccionesDelSistema( lnCantidadGenerados, lcNumerosGenerados, loMovStock.cDescripcion ) )

		loMovStock.release()	

		if used( "cInventarios" )
			use in cInventarios
		endif

		return toColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeEliminacionDeMovimientosDeInsumos( toColSentencias  as zoocoleccion OF zoocoleccion.prg ) as ZooColeccion of ZooColeccion.prg
		local loMovStock as Object, loColSentenciasDelete as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loColSentencias as zoocoleccion OF zoocoleccion.prg, loItem as Object, lnIndCol as Integer,  lcCursorCod as String, lcSql as String, lcCodigoMov as String

		if type( "toSentencias" ) = "O"
			loColSentencias = toColSentencias
		else
			loColSentencias = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif

		loMovStock = _screen.zoo.instanciarentidad("MovimientoStockAInvent")

		lcCursorCod  = "c_" + sys(2015)
		lcSql = "select codigo from compafe where afecta = '" + this.oEntidadPadre.Codigo + "' and lower(afetipo) = 'afectado' and afetipocom = " + str( this.oEntidadPadre.TipoComprobante, 3, 0 )
		goServicios.Datos.EjecutarSentencias(  lcSql, "compafe", "", lcCursorCod, this.datasessionid )

		select ( lcCursorCod )
		scan
			lcCodigoMov = &lcCursorCod..Codigo

			with loMovStock
				.Codigo = lcCodigoMov

				loMovStock.RestaurarStock()

				.lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .t.
				if .ValidarAnulacion()

					loColSentenciasDelete = .oad.ObtenerSentenciasDelete()
					with .MovimientoDetalle.oItem.oCompStock
						.lNuevo = .f.
						.lEdicion = .f.
						.lEliminar = .t.
						.lAnular = .f.
						loColSentenciasAdic = .Grabar()
					endwith

					this.LlenarColeccionSentencias( loColSentenciasDelete, toColSentencias )
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
