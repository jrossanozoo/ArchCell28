define class Ent_Senia as din_EntidadSenia of din_EntidadSenia.prg

	#IF .f.
		Local this as Ent_Senia of Ent_Senia.prg
	#ENDIF	

    protected oListaAtributos as zoocoleccion OF zoocoleccion.prg
	
	oListaAtributos = null
	oListaAtributosItemSeniado = null
	oComprobante = null
	lInvertirSigno = .t.
	cComprobante = ""
	oComponente = null
	cDetalleComprobante = "ArticulosDetalle"
	lExisteKontroler = .f.
		
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.oComponente = _screen.zoo.CrearObjeto( "Din_ComponenteComprobante" )
		this.cComprobante = "SENIA"
		with this.ArticulosDetalle.oitem
			.lInvertirSigno = This.lInvertirSigno
			
			if .lControlaStock
				.oCompStock.nSigno = iif( This.lInvertirSigno, -1, 1 )
				.oCompStock.lInvertirSigno = This.lInvertirSigno
				.oCompStock.InyectarEntidad( this )
				.oCompStock.InyectarDetalle( this.ArticulosDetalle )
			endif
		endwith
	endfunc 

	*--------------------------------------------------------------------------------------------
	protected function oListaAtributos_access() as zoocoleccion OF zoocoleccion.prg
		local lcCursor as String
		if !this.ldestroy and ( !vartype( this.oListaAtributos ) = 'O' or isnull( this.oListaAtributos ) )
			this.oListaAtributos = _screen.zoo.crearobjeto( "zooColeccion" )
			lcCursor = sys( 2015 )
			this.XMLACursor( filetostr( "Din_EstructuraSeniaObjeto.Xml" ), lcCursor )
			select Atributo, ClaveForanea from &lcCursor where upper( alltrim( Entidad ) ) = upper( alltrim( "ITEMSENIAS" ) ) into cursor c_Atributos
		
			select ( "c_Atributos" )
			scan
				if empty( c_Atributos.ClaveForanea )
					this.oListaAtributos.Agregar( alltrim( c_Atributos.Atributo ) )
				else
					this.oListaAtributos.Agregar( alltrim( c_Atributos.Atributo ) + "_PK" )				
				endif
			endscan
			use in ( lcCursor )
			use in ( "c_Atributos" )
		endif
		
		return this.oListaAtributos 
	endfunc 

	*--------------------------------------------------------------------------------------------
	protected function oListaAtributosItemSeniado_access() as zoocoleccion OF zoocoleccion.prg
		local lcCursor as String, loObjeto as Object
		if !this.ldestroy and ( !vartype( this.oListaAtributosItemSeniado ) = 'O' or isnull( this.oListaAtributosItemSeniado ) )
			this.oListaAtributosItemSeniado = _screen.zoo.crearobjeto( "zooColeccion" )
			lcCursor = sys( 2015 )
			loObjeto = _Screen.Zoo.CrearObjeto( "din_Estructuraadn" )
			this.XMLACursor( loObjeto.ObtenerNativa(), lcCursor )
			select Atributo, EsFK from &lcCursor where upper( alltrim( Entidad ) ) = upper( alltrim( "ITEMARTICULOSSENIADOS" ) ) into cursor c_Atributos
		
			select ( "c_Atributos" )
			scan
				if !c_Atributos.EsFK
					this.oListaAtributosItemSeniado.Agregar( alltrim( c_Atributos.Atributo ) )
				else
					this.oListaAtributosItemSeniado.Agregar( alltrim( c_Atributos.Atributo ) + "_PK" )				
				endif
			endscan
			use in ( lcCursor )
			use in ( "c_Atributos" )
		endif
		
		return this.oListaAtributosItemSeniado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CopiarDetalle( toDetalleOrigen as Detalle of Detalle.prg, toDetalleDestino as detalle of Detalle.prg ) as Void
		local lnNroItem as Integer, loItemOrigen as Object, loItemDestino as Object
		for lnNroItem = 1 to toDetalleOrigen.Count
			loItemOrigen = toDetalleOrigen.Item( lnNroItem )
			if toDetalleOrigen.ValidarExistenciaCamposFijosItemPlano( lnNroItem )
				loItemDestino = this.ObtenerCopiaDeItemArticuloASeniado( loItemOrigen, toDetalleDestino.CrearItemAuxiliar(), .f. )
				loItemDestino.NroItem = toDetalleDestino.CantidadDeItemsCargados() + 1
				toDetalleDestino.AgregarItemPlano( loItemDestino )
			endif
		endfor	
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ObtenerCopiaDeItemArticuloASeniado( toItemOrigen as Object, toItemDestino as Object, tlQuitarPrefijoPKAItemOrigen as Boolean, tlItemArticulosSeniados as Boolean ) as Object
		local lcAtributoOrigen as String, lcAtributoDestino as String, llTieneAtributoCantidad as Boolean, loListaAtributos as Object
		llTieneAtributoCantidad = .f.
	
		loListaAtributos = iif( tlItemArticulosSeniados, this.oListaAtributosItemSeniado, this.oListaAtributos )
		
		for each lcAtributo in loListaAtributos foxobject
			lcAtributoOrigen = iif( tlQuitarPrefijoPKAItemOrigen, strtran( lcAtributo, "_PK", ""  ), lcAtributo )
			if upper( lcAtributo ) == "CANTIDAD"
				llTieneAtributoCantidad = .T.
				&&La cantidad debe ser el ultimo atributo en setearse, caso contrario el control de stock no funcionaria.
			else
				lcAtributoDestino = lcAtributo
				toItemDestino.&lcAtributoDestino = toItemOrigen.&lcAtributoOrigen				
			endif
		endfor
		if llTieneAtributoCantidad
			toItemDestino.Cantidad = toItemOrigen.Cantidad
		endif

		return toItemDestino
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CancelarSinBuscarYCargar() as Void
		This.lEdicion = .F.
		This.lNuevo = .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDeComprobanteDeVentas( tnTipoComprobante as integer ) as String
		local lcRetorno as String 
		lcRetorno = ""

		if ! empty( tnTipoComprobante )	
			lcRetorno = this.oComprobante.ObtenerNombreDeComprobanteDeVentas( tnTipoComprobante )
		endif 	

		return lcRetorno 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAbreviaturaDeComprobanteDeVentas( tnTipoComprobante as integer ) as String
		local lcRetorno as String 
		lcRetorno = ""

		if ! empty( tnTipoComprobante )	
			lcRetorno = upper( this.oComprobante.ObtenerIdentificadorDeComprobante( tnTipoComprobante ) )
		endif 	

		return lcRetorno 

	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Tipocomprobanteorigen( txVal as variant ) as void
		dodefault( txVal )
		this.DescripcionTipocomprobanteorigen = this.ObtenerNombreDeComprobanteDeVentas( txVal )
		this.TipoComprobanteOrigenAbreviado = this.ObtenerAbreviaturaDeComprobanteDeVentas( txVal  )
	endfunc	

	*--------------------------------------------------------------------------------------------------------
	function Setear_TipocomprobanteAfectante( txVal as variant ) as void
		dodefault( txVal )
		this.DescripcionTipocomprobanteAfectante = this.ObtenerNombreDeComprobanteDeVentas( txVal )
		this.TipoComprobanteAfectanteAbreviado = this.ObtenerAbreviaturaDeComprobanteDeVentas( txVal  )
	endfunc	

	*-----------------------------------------------------------------------------------------
	function oComprobante_Access() as Object 
		if !this.ldestroy and ( !vartype( this.oComprobante ) = 'O' or isnull( this.oComprobante ) )
			this.oComprobante = this.crearobjeto( 'Din_COMPROBANTE' )
		endif
		return this.oComprobante
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EstaCancelada() as Boolean
		return ( ! empty( alltrim( this.ComprobanteAfectante ) ))
	endfunc 

	*-----------------------------------------------------------------------------------------
	function lActualizaRecepcion_Access() as Boolean
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDeStockDeComprobante( tcEntidad ) as String  
		local lcRetorno as String 
		lcRetorno = this.oComponente.ObtenerEstadoDeStockDeComprobante( tcEntidad )
		if empty( lcRetorno )
			lcRetorno = "SENIADO"
		Endif	
		return lcRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ModificaStockBasadoEn() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadosDeStock( ) as zoocoleccion  
		return this.oComponente.ObtenerEstadosDeStock( )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneFuncionalidadBasadoEn() as Boolean
		return pemstatus( this, "oCompEnBaseA", 5 )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		
		if this.lExisteKontroler
			This.SetearStockInicial()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearStockInicial() as Void
		local loDetalle as Object
		loDetalle = This.cDetalleComprobante
		This.&loDetalle..oItem.SetearStockInicial()
	endfunc	

enddefine
