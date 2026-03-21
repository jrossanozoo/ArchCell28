define class colaboradorLiquidacionDeTaller as ZooSession OF ZooSession.prg


	oGestion = null
	oOrden = null
	oFiltros = null
	cFirmaFiltros = ""
	oLiquidacion = null
	oCotizacionGestion = null
	oArticulo = null
	oInsumo = null
	oFacturaDeCompra = null
	oRemitoDeCompra = null
	
	*-----------------------------------------------------------------------------------------
	function oCotizacionGestion_Access()
		if !this.ldestroy and !vartype( this.oCotizacionGestion ) = 'O'
			this.oCotizacionGestion = _screen.zoo.InstanciarEntidad( 'CotizacionProduccion' )
		endif
		return this.oCotizacionGestion 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oArticulo_Access()
		if !this.ldestroy and !vartype( this.oArticulo ) = 'O'
			this.oArticulo = _screen.zoo.InstanciarEntidad( 'Articulo' )
		endif
		return this.oArticulo 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oInsumo_Access()
		if !this.ldestroy and !vartype( this.oInsumo ) = 'O'
			this.oInsumo = _screen.zoo.InstanciarEntidad( 'Insumo' )
		endif
		return this.oInsumo 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oGestion_Access()
		if !this.ldestroy and !vartype( this.oGestion ) = 'O'
			this.oGestion = _screen.zoo.InstanciarEntidad( 'Gestiondeproduccion' )
		endif
		return this.oGestion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oOrden_Access()
		if !this.ldestroy and !vartype( this.oOrden ) = 'O'
			this.oOrden = _screen.zoo.InstanciarEntidad( 'ordendeproduccion' )
		endif
		return this.oOrden
	endfunc

	*-----------------------------------------------------------------------------------------
	function oFacturaDeCompra_Access()
		if !this.ldestroy and !vartype( this.oFacturaDeCompra ) = 'O'
			this.oFacturaDeCompra = _screen.zoo.InstanciarEntidad( 'FacturaDeCompra' )
		endif
		return this.oFacturaDeCompra
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oRemitoDeCompra_Access()
		if !this.ldestroy and !vartype( this.oRemitoDeCompra ) = 'O'
			this.oRemitoDeCompra = _screen.zoo.InstanciarEntidad( 'RemitoDeCompra' )
		endif
		return this.oRemitoDeCompra
	endfunc

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarLiquidacion( toEntidad as Object ) as Void
		this.oLiquidacion = toEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		this.oFiltros = createobject("ObjetoBusquedaLiquidacion")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarConsulta()
		this.oLiquidacion.LiquidacionTallerProduccion.Limpiar()
		this.oLiquidacion.LiquidacionTallerDescarte.Limpiar()
		this.oLiquidacion.LiquidacionTallerInsumos.Limpiar()
		this.oLiquidacion.LiquidacionTallerAdicionales.Limpiar()
		this.oLiquidacion.GestiondeProduccion.Limpiar()
		this.InyectarProducido()
		if this.oLiquidacion.Descartes = 1
			this.InyectarDescartado()
		endif
		if this.oLiquidacion.Insumos = 1
			this.InyectarInsumos()
		endif
		this.InyectarAdicionales()
	endfunc


	*-----------------------------------------------------------------------------------------
	function InyectarProducido() as Void
		local lItemAux as Object, regitem as Custom
		
		goServicios.Datos.EjecutarSQL( this.SentenciaDetalleProduccionEnGestion(), "datosfiltrados", this.dataSessionId )
		select datosfiltrados
		go top
		do while !eof()
			scatter name regitem
			try
				=addproperty( regitem, "Semielaborado", regitem.Insumo )
				=addproperty( regitem, "SemielaboradoDetalle", regitem.InsumoDetalle )
				=addproperty( regitem, "Cantidad", regitem.Resto )
				=addproperty( regitem, "Monto", regitem.Cantidad*regitem.Costo )
				=addproperty( regitem, "NroItem", recno() )
				
				this.IngresarItemADetalle( this.oLiquidacion.LiquidacionTallerProduccion, regitem )
				*this.AgregarGestionDeProduccion( regitem )
				
			catch to loerror
				goServicios.Errores.LevantarExcepcion( loError )	
				exit
			endtry
			skip
		enddo
		this.oLiquidacion.LiquidacionTallerProduccion.Sumarizar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarDescartado() as Void
		goServicios.Datos.EjecutarSQL( this.SentenciaDetalleDescartesEnGestion(), "datosfiltrados", this.dataSessionId )
		select datosfiltrados
		go top
		do while !eof()
			scatter name regitem
			try
				=addproperty( regitem, "Semielaborado", regitem.Insumo )
				=addproperty( regitem, "SemielaboradoDetalle", regitem.InsumoDetalle )
				=addproperty( regitem, "Cantidad", regitem.Resto )
				=addproperty( regitem, "Monto", regitem.Cantidad*regitem.Costo )
				=addproperty( regitem, "NroItem", recno() )
				
				this.IngresarItemADetalle( this.oLiquidacion.LiquidacionTallerDescarte, regitem )
				*this.AgregarGestionDeProduccion( regitem )
				
			catch to loerror
				goServicios.Errores.LevantarExcepcion( loError )	
				exit
			endtry
			skip
		enddo
		this.oLiquidacion.LiquidacionTallerDescarte.Sumarizar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarInsumos() as Void
		goServicios.Datos.EjecutarSQL( this.SentenciaDetalleInsumosEnGestion(), "datosfiltrados", this.dataSessionId )
		select datosfiltrados
		go top
		do while !eof()
			scatter name regitem
			try
				=addproperty( regitem, "Semielaborado", regitem.Insumo )
				=addproperty( regitem, "SemielaboradoDetalle", regitem.InsumoDetalle )
				=addproperty( regitem, "Cantidad", regitem.Resto )
				=addproperty( regitem, "Monto", regitem.Cantidad*regitem.Costo )
				=addproperty( regitem, "NroItem", recno() )
				
				this.IngresarItemADetalle( this.oLiquidacion.LiquidacionTallerInsumos, regitem )
				*this.AgregarGestionDeProduccion( regitem )
				
			catch to loerror
				goServicios.Errores.LevantarExcepcion( loError )	
				exit
			endtry
			skip
		enddo
		if this.oLiquidacion.Descartes = 1
			goServicios.Datos.EjecutarSQL( this.SentenciaDetalleInsumosDescartesEnGestion(), "datosfiltrados", this.dataSessionId )
			select datosfiltrados
			go top
			do while !eof()
				scatter name regitem
				try
					=addproperty( regitem, "Semielaborado", regitem.Insumo )
					=addproperty( regitem, "SemielaboradoDetalle", regitem.InsumoDetalle )
					=addproperty( regitem, "Cantidad", regitem.Resto )
					=addproperty( regitem, "Monto", regitem.Cantidad*regitem.Costo )
					=addproperty( regitem, "NroItem", recno() )
					
					this.IngresarItemADetalle( this.oLiquidacion.LiquidacionTallerInsumos, regitem )
					*this.AgregarGestionDeProduccion( regitem )
					
				catch to loerror
					goServicios.Errores.LevantarExcepcion( loError )	
					exit
				endtry
				skip
			enddo		
		endif 		
		this.oLiquidacion.LiquidacionTallerInsumos.Sumarizar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarAdicionales() as Void
		goServicios.Datos.EjecutarSQL( this.SentenciaDetalleAdicionales() , "datosfiltrados", this.dataSessionId )
		select datosfiltrados
		go top
		do while !eof()
			scatter name regitem
			try
				=addproperty( regitem, "Cantidad", regitem.Resto )
				=addproperty( regitem, "Monto", regitem.Cantidad*regitem.Costo )
				=addproperty( regitem, "NroItem", recno() )
				this.IngresarItemADetalle( this.oLiquidacion.LiquidacionTallerAdicionales, regitem )
				*this.AgregarGestionDeProduccion( regitem )
			catch to loerror
				goServicios.Errores.LevantarExcepcion( loError )	
				exit
			endtry
			skip
		enddo
		this.oLiquidacion.LiquidacionTallerAdicionales.Sumarizar()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarGestionDeProduccion( regitem )
		with this.oLiquidacion.GestionDeProduccion
			if !.Buscar( regitem.Gestion )
				lItemAux = .CrearItemAuxiliar()
				lItemAux.codigo			 = this.oLiquidacion.Codigo
				lItemAux.TipoComprobante = this.oGestion.TipoComprobante
				lItemAux.TipoCompCaracter= alltrim( this.oLiquidacion.cDescripcion ) + " Nº " + alltrim(transform( this.oLiquidacion.Numero )) 
				lItemAux.PuntodeVenta	 = 9999
				lItemAux.Numero			 = this.oLiquidacion.Numero
				lItemAux.Fecha			 = this.oLiquidacion.fechahasta
				lItemAux.Tipo			 = "Afectado"
				lItemAux.Afecta			 = regitem.Gestion
				lItemAux.NombreEntidad	 = this.oLiquidacion.cNombre
				lItemAux.NroItem		 = .Count + 1
				.Add( lItemAux, lItemAux.Afecta )
			endif
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IngresarItemADetalle( toDestino as Object, toItem as Object ) as boolean 
		local loItem as Object, llRetorno as Boolean, llOtraMoneda as Boolean, lAntesUsarPrecioDeLista as Boolean
		llRetorno = .f.
		try
			with toDestino
				loitem = This.CopiarItem( toDestino, toItem )
				.AgregarItemPlano( loitem )
			endwith
			llRetorno = .t.
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CopiarItem( toDestino as object, toItem as Object ) as object
		local loRetorno as Object, lnProp as Integer, lnInd as Integer, lcProp as String, lcPropPK as String
		local array laProp[ 1 ]
		
		loRetorno = toDestino.CrearItemAuxiliar()
		lnProp = amembers( laProp, toItem, 0, "U" )

		for lnInd = 1 to lnProp
			lcProp = laProp[ lnInd ]
			do case
				case pemstatus( loRetorno, lcProp + "_PK", 5 )
					lcPropPK = lcProp + "_PK"
					loRetorno.&lcPropPK = toItem.&lcProp
				case pemstatus( loRetorno, lcProp, 5 )
					loRetorno.&lcProp = toItem.&lcProp
			endcase 
		endfor
		return loRetorno
	endfunc
	
	*Producido-----------------------------------------------------------------------------------------
	function SentenciaDetalleProduccionEnGestion() as String
		local lcArtDefault as String
		lcArtDefault = rtrim( goParametros.Felino.Generales.ArticuloDefaultLiquidacionProcesoProduccion )
		return this.SentenciaDetalleBase( lcArtDefault, "GESTIONCURVA", "CantProducida", "CotizacionOrdenProduccion", "LiquidacionTallerProduccion" )
	endfunc
	
	*Descartes-----------------------------------------------------------------------------------------
	function SentenciaDetalleDescartesEnGestion() as String
		local lcArtDefault as String
		lcArtDefault = rtrim( goParametros.Felino.Generales.ArticuloDefaultLiquidacionProcesoDescarte )
		return this.SentenciaDetalleBase( lcArtDefault, "GestionDescartes", "CantDescarte", "CotizacionOrdenDescarte", "LiquidacionTallerDescarte" )
	endfunc 

	*Insumos-----------------------------------------------------------------------------------------
	function SentenciaDetalleInsumosEnGestion() as String
		local lcArtDefault as String
		lcArtDefault = rtrim( goParametros.Felino.Generales.ArticuloDefaultLiquidacionInsumosProduccion )
		return this.SentenciaDetalleBase( lcArtDefault, "GestionInsumos", "Cantidad", "CotizacionOrdenInsumos", "LiquidacionTallerInsumos" )
	endfunc 
	
	*InsumosDescartados-----------------------------------------------------------------------------------------
	function SentenciaDetalleInsumosDescartesEnGestion() as String
		local lcArtDefault as String
		lcArtDefault = rtrim( goParametros.Felino.Generales.ArticuloDefaultLiquidacionInsumosDescarte )
		return this.SentenciaDetalleBase( lcArtDefault, "GestionInsumosDescartes", "Cantidad", "CotizacionOrdenInsumos", "LiquidacionTallerInsumos" )
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoDetalleDeGestion( tcDetalle, tcNombreCampo ) as string
		local lctexto as String
		lctexto = "this.oGestion.oAD.ObtenerCampoDetalle"+tcDetalle+"('"+tcNombreCampo+"')"
		return &lctexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoDetalleDeCotizacion( tcDetalle, tcNombreCampo ) as string
		local lctexto as String
		lctexto = "this.oCotizacionGestion.oAD.ObtenerCampoDetalle"+tcDetalle+"('"+tcNombreCampo+"')"
		return &lctexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoDetalleDeLiquidacion( tcDetalle, tcNombreCampo ) as string
		local lctexto as String
		lctexto = "this.oLiquidacion.oAD.ObtenerCampoDetalle"+tcDetalle+"('"+tcNombreCampo+"')"
		return &lctexto
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposSelectDetalleDeGestion( tcDetalle, tcNombreCampos ) as string
		local lctexto as String
		lctexto = "this.oGestion.oAD.ObtenerCamposSelectDetalle"+tcDetalle+"('"+tcNombreCampos+"')"
		return &lctexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposSelectDetalleDeCotizacion( tcDetalle, tcNombreCampos ) as string
		local lctexto as String
		lctexto = "this.oCotizacionGestion.oAD.ObtenerCamposSelectDetalle"+tcDetalle+"('"+tcNombreCampos+"')"
		return &lctexto
	endfunc 	
	*-----------------------------------------------------------------------------------------
	protected function SentenciaDetalleBase( tcArtDefault as String, tcDetaGestion as String, tcAtributoCantidad, tcDetaCotizacion as string, tcDetaLiquidacion as string ) as String
		local lcselect as String, lcCampos as String, lcEnter as String
		local lcArtDefault as String, lcSetenciaArticulo as String
		
		&& Sentencia para obtener articulo
		lcSetenciaArticulo = "coalesce( "
		lcSetenciaArticulo = lcSetenciaArticulo + "nullif(DetCotiza."+this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, "articulo" ) +",'')"
		do case
			case "insumo" $ lower(tcDetaGestion) and !("descarte" $ lower(tcDetaGestion))
				lcSetenciaArticulo = lcSetenciaArticulo + ",nullif(insumos."+this.oInsumo.oAd.ObtenerCampoEntidad("ArticuloLiquidacionProduccion")+",'')"
			case "insumo" $ lower(tcDetaGestion) and "descarte" $ lower(tcDetaGestion)
				lcSetenciaArticulo = lcSetenciaArticulo + ",nullif(insumos."+this.oInsumo.oAd.ObtenerCampoEntidad("ArticuloLiquidacionDescarte")+",'')"
			otherwise
				lcSetenciaArticulo = lcSetenciaArticulo + ",nullif(procesos."+this.oLiquidacion.ProcesoDesde.oAd.ObtenerCampoEntidad("ArticuloLiquidacionProduccion")+",'')"
		endcase
		lcSetenciaArticulo = lcSetenciaArticulo +",'"+tcArtDefault+"')" 

		lcEnter = chr(13) + chr(10)
		lcCampos = "Insumo,InsumoDetalle,Color,ColorDetalle,Talle,TalleDetalle,IdItemInsumo"
		lcCampos = this.ObtenerCamposSelectDetalleDeGestion( tcDetaGestion, lcCampos )
        
        lcselect = "select gestiones."+this.oGestion.oAd.obtenercampoentidad("Numero")+" as NumeroGestion, " 
        lcselect = lcselect + " ordenes."+this.oOrden.oAd.obtenercampoentidad("Numero")+" as NumeroOrden, " 
        lcselect = lcselect + " gestiones."+this.oGestion.oAd.obtenercampoentidad("Codigo")+" as Gestion, " + lcEnter 
		lcselect = lcselect + lcSetenciaArticulo +" as Articulo, " + lcEnter 

		&& Descripcion del articulo
		lcselect = lcselect + "coalesce( articulos1."+this.oArticulo.oAd.ObtenerCampoEntidad("descripcion")+","
		lcselect = lcselect + "articulos2."+this.oArticulo.oAd.ObtenerCampoEntidad("descripcion")+","
		lcselect = lcselect + "articulos3."+this.oArticulo.oAd.ObtenerCampoEntidad("descripcion")+","
		lcselect = lcselect + "'') as articulodetalle, " + lcEnter 
					
		&& Obtener Costo de articulo
		lcselect = lcselect + "coalesce( DetCotiza." + this.oCotizacionGestion.oAD.ObtenerCampoDetalleCotizacionOrdenProduccion( "costo" )+", "
		lcselect = lcselect + " Funciones.ObtenerCostoDeInsumoPonderado("
		lcselect = lcselect + "'"+rtrim(this.oFiltros.cListaDeCosto)+"'"
		lcselect = lcselect + ",producido."+this.ObtenerCampoDetalleDeGestion(tcDetaGestion,"insumo")
		lcselect = lcselect + ",gestiones."+this.oGestion.oAd.ObtenerCampoEntidad("proceso")
		lcselect = lcselect + ",'"+rtrim( this.oFiltros.cTaller )+"'"
		lcselect = lcselect + ",producido."+this.ObtenerCampoDetalleDeGestion(tcDetaGestion,"color")
		lcselect = lcselect + ",producido."+this.ObtenerCampoDetalleDeGestion(tcDetaGestion,"talle")
		lcselect = lcselect + ",producido."+this.ObtenerCampoDetalleDeGestion(tcDetaGestion,tcAtributoCantidad)
		lcselect = lcselect + "),0) as costo, " + lcEnter 
		
        lcselect = lcselect + " gestiones."+this.oGestion.oAd.ObtenerCampoEntidad("proceso")+" as proceso, " 
        lcselect = lcselect + " procesos."+this.oLiquidacion.ProcesoDesde.oAd.ObtenerCampoEntidad("descripcion")+" as procesodetalle, " 

		&& Diferencia para ingresar
		lcselect = lcselect + "producido."+this.ObtenerCampoDetalleDeGestion( tcDetaGestion, tcAtributoCantidad )+"-coalesce(DetaLiqui.Restar,0) as Resto, " + lcEnter 

        lcselect = lcselect + this.AgregarPrefijoACampos( lcCampos, "producido" ) + " from " + this.oGestion.oAD.cEsquema + "." + this.oGestion.oAD.ObtenerTablaDetalle( tcDetaGestion )+ " as producido" + lcEnter 

        *** Join de Cabecera gestion de orden de produccion
        lcselect = lcselect + " left join " + this.oGestion.oAD.cEsquema  + "." + this.oGestion.oAD.cTablaPrincipal + " as gestiones on gestiones.codigo=producido."+this.ObtenerCampoDetalleDeGestion(tcDetaGestion, "CODIGO" ) + lcEnter 

        *** Join de proceso de orden de Produccion
        lcselect = lcselect + " left join " + this.oLiquidacion.ProcesoDesde.oAD.cEsquema  + "." + this.oLiquidacion.ProcesoDesde.oAD.cTablaPrincipal + " as procesos on procesos.codigo=gestiones."+this.oGestion.oAD.ObtenerCampoEntidad( "Proceso" ) + lcEnter 


		*** Join de cotizacion de gestion de orden de produccion
		
        lcselect = lcselect + " left join (select " + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("codigo") +", "+ this.oCotizacionGestion.oAd.ObtenerCampoEntidad("GestionDeProduccion") + ", row_number() over (partition by " + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("GestionDeProduccion") + " order by " + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("numero") + " desc) as rowNum from "+ this.oCotizacionGestion.oAD.cEsquema  + "." + this.oCotizacionGestion.oAD.cTablaPrincipal + ") as CabCotiza on CabCotiza." + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("GestionDeProduccion") + "=gestiones." + this.oGestion.oAd.ObtenerCampoEntidad("codigo") + " and CabCotiza.rowNum = 1" + lcEnter 		

        lcselect = lcselect + " left join " + this.oCotizacionGestion.oAD.cEsquema  + "." + this.oCotizacionGestion.oAD.ObtenerTablaDetalle( tcDetaCotizacion ) + " as DetCotiza ";
        						+"on DetCotiza."+this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, "codigo" )+"=CabCotiza."+this.oCotizacionGestion.oAd.ObtenerCampoEntidad("codigo")+" and producido."+this.ObtenerCampoDetalleDeGestion( tcDetaGestion, "IdItemInsumo" )+"=DetCotiza." + this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, "IdItemInsumo" ) + lcEnter 

        *** Join de Insumo
        lcselect = lcselect + " left join " + this.oInsumo.oAD.cEsquema  + "." + this.oInsumo.oAD.cTablaPrincipal + " as insumos on insumos."+this.oInsumo.oAd.ObtenerCampoEntidad("codigo")+"=producido."+this.ObtenerCampoDetalleDeGestion( tcDetaGestion, "insumo" ) + lcEnter 

        *** Join de Articulo
        lcselect = lcselect + " left join " + this.oArticulo.oAD.cEsquema  + "." + this.oArticulo.oAD.cTablaPrincipal + " as articulos1 on articulos1."+this.oArticulo.oAd.ObtenerCampoEntidad("codigo")+"=DetCotiza."+this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, "articulo" ) + lcEnter 

		do case
			case "insumo" $ lower(tcDetaGestion) and !("descarte" $ lower(tcDetaGestion))
				lcselect = lcselect + " left join " + this.oArticulo.oAD.cEsquema  + "." + this.oArticulo.oAD.cTablaPrincipal + " as articulos2 on articulos2."+this.oArticulo.oAd.ObtenerCampoEntidad("codigo")+"=insumos."+this.oInsumo.oAd.ObtenerCampoEntidad("ArticuloLiquidacionProduccion") + lcEnter 
			case "insumo" $ lower(tcDetaGestion) and "descarte" $ lower(tcDetaGestion)
				lcSetenciaArticulo = lcSetenciaArticulo + ",nullif(insumos."+this.oInsumo.oAd.ObtenerCampoEntidad("ArticuloLiquidacionDescarte")+",'')"
				lcselect = lcselect + " left join " + this.oArticulo.oAD.cEsquema  + "." + this.oArticulo.oAD.cTablaPrincipal + " as articulos2 on articulos2."+this.oArticulo.oAd.ObtenerCampoEntidad("codigo")+"=insumos."+this.oInsumo.oAd.ObtenerCampoEntidad("ArticuloLiquidacionDescarte") + lcEnter 
			otherwise
		        lcselect = lcselect + " left join " + this.oArticulo.oAD.cEsquema  + "." + this.oArticulo.oAD.cTablaPrincipal + " as articulos2 on articulos2."+this.oArticulo.oAd.ObtenerCampoEntidad("codigo")+"=procesos."+this.oLiquidacion.ProcesoDesde.oAd.ObtenerCampoEntidad("ArticuloLiquidacionProduccion") + lcEnter 
		endcase

        lcselect = lcselect + " left join " + this.oArticulo.oAD.cEsquema  + "." + this.oArticulo.oAD.cTablaPrincipal + " as articulos3 on articulos3."+this.oArticulo.oAd.ObtenerCampoEntidad("codigo")+"='"+tcArtDefault+"'" + lcEnter 
        
        *** Join de proceso de orden de Produccion
        lcselect = lcselect + " left join " + this.oOrden.oAD.cEsquema  + "." + this.oOrden.oAD.cTablaPrincipal + " as ordenes on ordenes.codigo=gestiones."+this.oGestion.oAD.ObtenerCampoEntidad( 'OrdenDeProduccion' ) + lcEnter 

        *** Join de detalle de liquidacion
        lcselect = lcselect + " left join ( select " + this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion, "IdItemInsumo" )+", sum("+this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion , "cantidad" )+") as Restar from " + this.oLiquidacion.oAD.cEsquema  + "." + this.oLiquidacion.oAD.ObtenerTablaDetalle( tcDetaLiquidacion ) +" group by " + this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion, "IdItemInsumo" ) + ") as DetaLiqui ";
        						+"on DetaLiqui."+this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion, "IdItemInsumo" )+"=producido."+this.ObtenerCampoDetalleDeGestion( tcDetaGestion, "IdItemInsumo" ) + lcEnter 

		*** Join de Comprobantes relacionados, para poder excluir
*        lcselect = lcselect + " left join ( select "+this.oLiquidacion.oAd.ObtenerCampoDetalleGestionDeProduccion("afecta")+" from " + this.oLiquidacion.oAD.cEsquema  + "." + this.oLiquidacion.oAD.ObtenerTablaDetalle("GestionDeProduccion") + " where "+this.oLiquidacion.oAd.ObtenerCampoDetalleGestionDeProduccion("NombreEntidad")+"='LIQUIDACIONDETALLER') as relacionados on gestiones."+this.oGestion.oAD.ObtenerCampoEntidad( 'codigo' ) +"=relacionados."+this.oLiquidacion.oAd.ObtenerCampoDetalleGestionDeProduccion("afecta") + lcEnter 

        lcselect = lcselect + " where " + this.ObtenerWhere() + lcEnter 
        lcselect = lcselect + " and producido." + this.ObtenerCampoDetalleDeGestion( tcDetaGestion, tcAtributoCantidad ) + "-coalesce(DetaLiqui.Restar,0)>0"+ lcEnter 
		return lcselect
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SentenciaDetalleAdicionales() as String
		local lcselect as String, lcCampos as String, lcEnter as String
		local lcArtDefault as String, lcSetenciaArticulo as String
		
		tcAtributoCantidad = "Cantidad"
		tcDetaCotizacion = "CotizacionOrdenAdicionales"
		tcDetaLiquidacion = "LiquidacionTallerAdicionales"

		lcEnter = chr(13) + chr(10)
		lcCampos = "Articulo,ArticuloDetalle,Color,ColorDetalle,Talle,TalleDetalle,IdItemArticulo,Costo"
		lcCampos = this.ObtenerCamposSelectDetalleDeCotizacion( tcDetaCotizacion, lcCampos )

		&& Diferencia para ingresar
		lcselect = "select adicionales."+this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, tcAtributoCantidad )+"-coalesce(DetaLiqui.Restar,0) as Resto, " + lcEnter 

        lcselect = lcselect + this.AgregarPrefijoACampos( lcCampos, "adicionales" ) + lcEnter 
		lcselect = lcselect + " from " + this.oCotizacionGestion.oAD.cEsquema + "." + this.oCotizacionGestion.oAD.ObtenerTablaDetalle( tcDetaCotizacion )+ " as adicionales" + lcEnter 

		*** Join de cotizacion de gestion de orden de produccion
        lcselect = lcselect + " left join (select " + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("codigo") +", "+ this.oCotizacionGestion.oAd.ObtenerCampoEntidad("GestionDeProduccion") + ", row_number() over (partition by " + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("GestionDeProduccion") + " order by " + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("numero") + " desc) as rowNum from "+ this.oCotizacionGestion.oAD.cEsquema  + "." + this.oCotizacionGestion.oAD.cTablaPrincipal + ") as CabCotiza " + lcEnter 
		lcselect = lcselect + " on CabCotiza." + this.oCotizacionGestion.oAd.ObtenerCampoEntidad("codigo") + "=adicionales."+this.ObtenerCampoDetalleDeCotizacion(tcDetaCotizacion, "CODIGO" ) + " and CabCotiza.rowNum = 1" + lcEnter 		

        *** Join de Cabecera gestion de orden de produccion
        lcselect = lcselect + " left join " + this.oGestion.oAD.cEsquema  + "." + this.oGestion.oAD.cTablaPrincipal + " as gestiones on gestiones.codigo=CabCotiza."+this.oCotizacionGestion.oAD.ObtenerCampoEntidad("GESTIONDEPRODUCCION" ) + lcEnter 

        *** Join de Proceso de orden de Produccion
        lcselect = lcselect + " left join " + this.oLiquidacion.ProcesoDesde.oAD.cEsquema  + "." + this.oLiquidacion.ProcesoDesde.oAD.cTablaPrincipal + " as procesos on procesos.codigo=gestiones."+this.oGestion.oAD.ObtenerCampoEntidad( "Proceso" ) + lcEnter 

        *** Join de Orden de Produccion
        lcselect = lcselect + " left join " + this.oOrden.oAD.cEsquema  + "." + this.oOrden.oAD.cTablaPrincipal + " as ordenes on ordenes.codigo=gestiones."+this.oGestion.oAD.ObtenerCampoEntidad( 'OrdenDeProduccion' ) + lcEnter 

        *** Join de detalle de adicionales en liquidaciones
        lcselect = lcselect + " left join ( select " + this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion, "IdItemArticulo" )+", sum("+this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion , "cantidad" )+") as Restar from " + this.oLiquidacion.oAD.cEsquema  + "." + this.oLiquidacion.oAD.ObtenerTablaDetalle( tcDetaLiquidacion ) +" group by " + this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion, "IdItemArticulo" ) + ") as DetaLiqui ";
        						+"on DetaLiqui."+this.ObtenerCampoDetalleDeLiquidacion( tcDetaLiquidacion, "IdItemArticulo" )+"=adicionales."+this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, "IdItemArticulo" ) + lcEnter 

		&& Armando el where especial para los adicionales
		lcselect = lcselect + " where " + this.ObtenerWhere() + lcEnter 
        lcselect = lcselect + " and adicionales." + this.ObtenerCampoDetalleDeCotizacion( tcDetaCotizacion, tcAtributoCantidad ) + "-coalesce(DetaLiqui.Restar,0)>0"+ lcEnter 

		return lcselect
	endfunc



	*-----------------------------------------------------------------------------------------
	protected function BuscarUltimoComprobanteProveedor( toEntComprobante ) as Object
		local lcselect as string, loRetorno as object
        lcselect =  "select top 1 " + toEntComprobante.oAD.ObtenerCampoEntidad( 'proveedor' ) +","+ toEntComprobante.oAD.ObtenerCampoEntidad( 'PuntoDeVenta' ) +" as PuntoDeVenta, "+toEntComprobante.oAD.ObtenerCampoEntidad( 'Numero' )+" as numero, "+toEntComprobante.oAD.ObtenerCampoEntidad( 'letra' )+" as letra";
        + " from " + toEntComprobante.oAD.cEsquema  + "." + toEntComprobante.oAD.cTablaPrincipal;
        + " where " + toEntComprobante.oAD.ObtenerCampoEntidad( 'proveedor' ) + "='" + this.oLiquidacion.Proveedor_pk + "'";
        + " order by " + toEntComprobante.oAD.ObtenerCampoEntidad( 'PuntoDeVenta' ) + " desc, " + toEntComprobante.oAD.ObtenerCampoEntidad( 'Numero' )+" desc"
        goServicios.Datos.EjecutarSQL( lcselect, "infotemp", this.dataSessionId )
		loRetorno = newobject("empty")
		addproperty(loRetorno,"Letra",iif(toEntComprobante.cNombre = "FACTURADECOMPRA","B","X"))
		addproperty(loRetorno,"PuntodeVenta", this.oLiquidacion.Numero)
		addproperty(loRetorno,"Numero",this.oLiquidacion.Numero)
		select infotemp
		if reccount()>0
			loRetorno.Letra = infotemp.letra
			loRetorno.PuntoDeVenta = infotemp.PuntoDeVenta
			loRetorno.Numero = infotemp.Numero + 1
		endif
		use 
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarPrefijoACampos(cNames, cPrefix) as string
	    local cResult, i, nWordCount
	    * Inicializar la cadena de resultado
	    cResult = ""
	    nWordCount = getwordcount( cNames, "," )
	    * Recorrer cada palabra y agregar el prefijo
	    for i = 1 to nWordCount
	        cResult = cResult + cPrefix + "." + alltrim( getwordnum( cNames, i, "," ) )
	        if i < nWordCount
	            cResult = cResult + ", "
	        endif
	    endfor
	    return cResult
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFirmaFiltros() as String
		local laPropiedades[1], lnCount, lcretorno as String
		lnCount = amembers( laPropiedades, this.oFiltros, 0) && 0 para obtener solo propiedades
		lcretorno = ""
		for i = 1 to lnCount
		    lcPropiedad = laPropiedades[i]
		    if pemstatus( this.oFiltros, lcPropiedad,4)
			    lcValor = transform(EVALUATE("this.oFiltros." + lcPropiedad))
			    lcretorno = lcretorno + lcValor
			endif
		endfor
		return lcretorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerWhere() as String
		local lcFiltros as String
		lfinal = transform(this.oFiltros.nOrdenHasta)
		if empty(lfinal)
			lfinal = "0"
		endif
		lcFiltros = ""
		lcFiltros = lcFiltros + "gestiones."+ this.oGestion.oAd.obtenercampoentidad("Taller")+" = '"+this.oFiltros.cTaller +"'"
		lcFiltros = lcFiltros + " and gestiones."+ this.oGestion.oAd.obtenercampoentidad("Proceso")+" between '"+this.oFiltros.cProcesoDesde +"' and '"+this.oFiltros.cProcesoHasta +"'"
		lcFiltros = lcFiltros + " and gestiones."+ this.oGestion.oAd.obtenercampoentidad("numero")+" between "+transform(this.oFiltros.nGestionDesde) +" and "+transform(this.oFiltros.nGestionHasta)
		lcFiltros = lcFiltros + " and gestiones."+ this.oGestion.oAd.obtenercampoentidad("fecha")+" between "+ goServicios.Datos.ObtenerFechaFormateada( this.oFiltros.dFechaDesde ) + " and " + goServicios.Datos.ObtenerFechaFormateada( this.oFiltros.dFechaHasta )
		lcFiltros = lcFiltros + " and ordenes."+ this.oOrden.oAd.obtenercampoentidad("Numero")+" between "+ transform(this.oFiltros.nOrdenDesde) + " and " + lfinal
		lcFiltros = lcFiltros + " and gestiones.codigo is not null "
		*lcFiltros = lcFiltros + " and relacionados."+this.oLiquidacion.oAd.ObtenerCampoDetalleGestionDeProduccion("afecta")+" is null"
		return lcFiltros
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearComprobante() as Boolean
		local loEntidad as Object, loError as Exception, llRet as Boolean, oInfoProv as Object
		llRet = .t.

		do case
			case this.oLiquidacion.Comprobante = "FACTURADECOMPRA"
				loEntidad = this.oFacturaDeCompra
				if empty(goParametros.Felino.Generales.CodigoValorUtilizadoParaLiquidacionDeTalleres)
					this.oLiquidacion.AgregarInformacion( "Es necesario que el parametro: Gestión de Producción > Código de valor utilizado para liquidación de talleres, no este vacio para generar el comprobante " +loEntidad.cDescripcion )
					llRet = .f.
				endif
			case this.oLiquidacion.Comprobante = "REMITODECOMPRA"
				loEntidad = this.oRemitoDeCompra
			otherwise
				loEntidad = null
		endcase
		
		if !empty( this.oLiquidacion.Comprobante )
			if empty( goparametros.Felino.Precios.ListasdePrecios.ListaDePreciosPreferenteCompras )
				this.oLiquidacion.AgregarInformacion( "Es necesario que el parametro: Precios > Lista de precios > Lista de Precios Preferente Compras, no este vacio para generar el comprobante " +loEntidad.cDescripcion )
				llRet = .f.
			endif
			if empty( this.oLiquidacion.proveedor_pk )
				this.oLiquidacion.AgregarInformacion( "El taller debe tener un proveedor asignado para generar: " +loEntidad.cDescripcion +", modifique en el alta de taller y vuelva a cargarlo" )
				llRet = .f.
			endif
		endif
		
		if !isnull(loEntidad) and llRet
			this.oLiquidacion.eventoMensajeSinEspera( "Creando "+loEntidad.cDescripcion )
			try 
				with loEntidad
					if .esnuevo()
						.Cancelar()
					endif
					*oInfoProv = this.BuscarUltimoComprobanteProveedor( loEntidad )
					.Nuevo()
					.Letra = this.oLiquidacion.LetraComprobante
					.PuntodeVentaExtendido = this.oLiquidacion.PuntoDeVentaComprobante
					.PuntodeVenta = this.oLiquidacion.PuntoDeVentaComprobante
					.Numero = this.oLiquidacion.NumeroComprobante
					.Proveedor_pk = this.oLiquidacion.Proveedor_pk
					*.ListaDePrecios_pk = "" && si no esta cargado con el valor por default falla
					with .FacturaDetalle
						for each loLine in this.oLiquidacion.LiquidacionTallerProduccion
							.LimpiarItem()
							.oItem.articulo_pk	= loLine.articulo_pk
							.oItem.Cantidad		= loLine.Cantidad
							.oItem.Precio		= loLine.Costo
							.Actualizar()
						endfor
						for each loLine in this.oLiquidacion.LiquidacionTallerDescarte
							.LimpiarItem()
							.oItem.articulo_pk	= loLine.articulo_pk
							.oItem.Cantidad		= loLine.Cantidad
							.oItem.Precio		= loLine.Costo
							.Actualizar()
						endfor
						for each loLine in this.oLiquidacion.LiquidacionTallerInsumos
							.LimpiarItem()
							.oItem.articulo_pk	= loLine.articulo_pk
							.oItem.Cantidad		= loLine.Cantidad
							.oItem.Precio		= loLine.Costo
							.Actualizar()
						endfor
						for each loLine in this.oLiquidacion.LiquidacionTallerAdicionales
							.LimpiarItem()
							.oItem.articulo_pk	= loLine.articulo_pk
							.oItem.Cantidad		= loLine.Cantidad
							.oItem.Precio		= loLine.Costo
							.Actualizar()
						endfor
					endwith
					if loEntidad.cNombre = "FACTURADECOMPRA"
						loEntidad.TipoComprobanteRG1361 = 1
						loEntidad.ValoresDetalle.LimpiarItem()
						loEntidad.ValoresDetalle.oItem.Valor_pk = rtrim(goParametros.Felino.Generales.CodigoValorUtilizadoParaLiquidacionDeTalleres)
						loEntidad.ValoresDetalle.Actualizar()
					endif
					.zADSFW = "Generado desde " + alltrim( this.oLiquidacion.cDescripcion ) + " Nº " + alltrim(transform( this.oLiquidacion.Numero )) 
					.Grabar()
					this.oLiquidacion.zADSFW = this.oLiquidacion.zADSFW + "Genero comprobante " + alltrim( loEntidad.cDescripcion ) + " numero interno " + alltrim(transform( loEntidad.Numint, "@L 9999999999" )) 
				endwith 
			catch to loError
				llRet = .f.
				lcMensaje = iif( pemstatus(loError.UserValue,"oInformacion",5) and !isnull(loError.UserValue.oInformacion) and loError.UserValue.oInformacion.Count>0, loError.UserValue.oInformacion.Item(1).cMensaje,loError.Message) +  " ("+loEntidad.cDescripcion+")"
				this.oLiquidacion.AgregarInformacion( lcMensaje )
			finally
				this.oLiquidacion.eventoMensajeSinEspera()
			endtry
		endif
		return llRet 
	endfunc 

enddefine

define class ObjetoBusquedaLiquidacion as custom
	cListaDeCosto = ""
	cTaller = "TALLEREXTERNO"
	nOrdenDesde = 0
	nOrdenHasta = 999999999
	cProcesoDesde = ""
	cProcesoHasta = "ZZZZZZZZZZZZZZZZZZZZZ"
	dFechaDesde = ctod("  /  /    ")
	dFechaHasta = date()
	nGestionDesde = 0
	nGestionHasta = 999999999
	nDescartes = 0
	nInsumos = 0
enddefine
