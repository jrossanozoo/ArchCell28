define class ItemArticulosProduccion as ItemBaseProduccion of ItemBaseProduccion.Prg

	#if .f.
		local this as ItemArticulosProduccion of ItemArticulosProduccion.prg
	#endif

	oDetalle = null

	lTieneStockDisponible = .T.
	lControlaStock = .T.
	lInvertirSigno = .f.
	lPermiteCantidadesNegativas = .T.
	NoProcesarStock = .F.
	lAfectadoPorUnaPromocion = .f.
	lCalcularImpuestosInternos = .f.
	nMontoAnterior = 0
	nCantidadAnterior = 0
	lSeteandoCantidad = .F.
	lAdvertirMinimoReposicion = .T.
	oCombinacion = null
	lSoportaKits = .f.
	IdKit = ""

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()

		if vartype( This.oCompStock ) <> "O" and vartype( This.oCompStockProduccion ) = "O"
			this.AddProperty( "oCompStock" )
			this.oCompStock = this.oCompStockProduccion
		endif

		This.lControlaStock = This.EsComponenteStock()
		this.enlazar( "haCambiado", "eventoComponenteStock"  ) 
		this.enlazar( "haCambiado", "eventoComponenteKitDeArticulos" )

		if This.lControlaStock
			this.oCompStock.lInvertirSigno = this.lInvertirSigno
			This.BindearEvento( This.oCompStock, "eventoNoHayStock" , This, "eventoNoHayStock" ) 
			if pemstatus( this.oCompStock, "EventoInformarArticuloConColorOTalleFueraDePaletaOCurva", 5 )
				this.enlazar(".oCompStock.EventoInformarArticuloConColorOTalleFueraDePaletaOCurva","EventoInformarArticuloConColorOTalleFueraDePaletaOCurva")		
			endif
			if pemstatus( this.oCompStock, "EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva", 5 )
				this.enlazar(".oCompStock.EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva","EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva")		
			endif
		endif
		this.oCombinacion = AtributosCombinacionFactory()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoAntesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as VOID
		local lcAtributo as String
		lcAtributo = upper( alltrim( tcAtributo ) )
		do case
			case lcAtributo == "CANTIDAD"
				this.nCantidadAnterior = this.Cantidad
				this.lSeteandoCantidad = .T.
			case lcAtributo == "MONTO" and txValOld != txVal
				this.nMontoAnterior = this.Monto
		endcase
		dodefault( toObject, tcAtributo, txValOld, txVal ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
		local lcAtributo as String
		lcAtributo = upper( alltrim( tcAtributo ) )		
		if lcAtributo == "CANTIDAD"
			this.lSeteandoCantidad = .F.
		endif
		dodefault( toObject, tcAtributo, txValOld, txVal ) 


********************
********************
********************
			if (lcAtributo == "CANTIDAD" or lcAtributo == "RINDE") and this.cNombre = "MOVIMIENTOSTOCKAPRODUCC"
				this.CantidadInsumo = this.Cantidad * this.Rinde
			endif

			if (lcAtributo == "CANTIDAD" or lcAtributo == "RINDE") and this.cNombre = "MOVIMIENTOSTOCKDESDEPRODUCC"
				this.CantidadStockDF = round( this.Cantidad / iif( this.Rinde = 0, 1, this.Rinde ), 2 )
			endif
			if (lcAtributo == "CANTIDAD" or lcAtributo == "RINDE") and this.cNombre = "FINALDEPRODUCCION"
				this.CantidadStockDF = round( this.Cantidad / iif( this.Rinde = 0, 1, this.Rinde ), 2 )
			endif
********************
********************
********************


	endfunc
		
	*-----------------------------------------------------------------------------------------
	function eventoComponenteKitDeArticulos( tcAtributo as String, toItem as Object ) as Void
		local lcAtributo as String
		if this.lSoportaKits
			lcAtributo = alltrim( upper( tcAtributo ) )
			do case
				case lcAtributo == "CANTIDAD"
					lnCantidadAnterior = this.nCantidadAnterior
					this.nCantidadAnterior = this.Cantidad
					this.EventoHaCambiadoCantidad( toItem, lnCantidadAnterior, this.nMontoAnterior )
				case lcAtributo == "MONTO"
					this.EventoHaCambiadoMonto( toItem, this.nCantidadAnterior, this.nMontoAnterior )
			endcase
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoHaCambiadoMonto( toItem as Object, tnCantidadAnterior as Number, tnMontoAnterior as Number ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoHaCambiadoCantidad( toItem as Object, tnCantidadAnterior as Number, tnMontoAnterior as Number ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function eventoComponenteStock( tcAtributo as String, toItem as Object ) as Void
		local loError as Exception, lcAtributo as String, lcInformacion as String
		lcAtributo = alltrim( upper( tcAtributo ) )
		
		if lcAtributo == "CANTIDAD"
			try 
				This.lCargando = .T.
				this.lAdvertirMinimoReposicion = .T.
				dodefault( lcAtributo )
				This.EventoAntesDeVerificarDisponibilidadDeStockAlSetearCantidad()
				if this.lSoportaKits and this.Articulo.Comportamiento = 4
					This.lTieneStockDisponible = This.TieneDisponibleDeParticipantes()
					if !This.lTieneStockDisponible
						if goParametros.Felino.Generales.PermitirPasarSinStock
						else			
							goServicios.Errores.LevantarExcepcion( this.oCompStock.oColErroresParticipantes )
						endif
					endif
				else
					This.lTieneStockDisponible = This.TieneDisponible()
					if !This.lTieneStockDisponible
						lcInformacion = this.ocompstock.FormarMensajeCombSegunDisponible( This )
						this.limpiarInformacion()
						this.agregarinformacion( lcInformacion )
						if goParametros.Felino.Generales.PermitirPasarSinStock
						else
							this.Cantidad = goLibrerias.ValorVacio( this.Cantidad )
						endif
						This.EventoNoHayStock( this.oInformacion )
					endif
				endif
			catch to loError
				This.lTieneStockDisponible = .f.
				this.Cantidad = goLibrerias.ValorVacio( this.Cantidad )
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				This.lCargando = .F.
			endtry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsComponenteStock() as Boolean
		return  dodefault() ;
				and ( ( vartype( This.oCompStock ) = "O" and ;
						( upper( This.oCompStock.Class ) == "COMPONENTESTOCK" or upper( This.oCompStock.Class ) == upper( _screen.zoo.app.cProyecto ) + "_COMPONENTESTOCK" ) ) ;
					 or ;
					  ( vartype( This.oCompStockProduccion ) = "O" and ;
						( upper( This.oCompStockProduccion.Class ) == "COMPONENTESTOCKPRODUCCION" or upper( This.oCompStockProduccion.Class ) == upper( _screen.zoo.app.cProyecto ) + "_COMPONENTESTOCKPRODUCCION" ) ) ;
					)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeVerificarDisponibilidadDeStockAlSetearCantidad() as Void
		if This.lControlaStock
			This.oCompStock.AntesDeVerificarDisponibilidadDeStockAlSetearCantidad()
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneDisponible() as Boolean
		local llRetorno As Boolean
		llRetorno = dodefault()
		if this.TieneArticuloCargado()
			if This.lControlaStock
				this.oCompStock.lInvertirSigno = this.lInvertirSigno
				llRetorno = llRetorno and This.oCompStock.TieneDisponible()
			EndIf	
		endif
		Return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarDetalle( toDetalle As detalle OF detalle.prg ) as Void
		dodefault( toDetalle )
		if This.lControlaStock
			This.oCompStock.InyectarDetalle( toDetalle )
			if this.cNombre = "MOVIMIENTOSTOCKAPRODUCC"
				This.oCompStockProduccion.InyectarDetalle( toDetalle )
			endif
		EndIf	
		This.oDetalle = toDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearStockInicial()
		dodefault( )
		if This.lControlaStock
			This.oCompStock.SetearStockInicial()
			if this.cNombre = "MOVIMIENTOSTOCKAPRODUCC"
				This.oCompStockProduccion.SetearStockInicial()
			endif
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarStockInicial()
		dodefault( )
		This.oCompStock.EliminarStockInicial()
		if this.cNombre = "MOVIMIENTOSTOCKAPRODUCC"
			This.oCompStockProduccion.EliminarStockInicial()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoNoHayStock( toInformacion ) as Void
		dodefault( toInformacion )
		&& para que se enganche alguien
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function eventoAlcanzoMinimoDeReposicion( toInformacion ) as Void
		dodefault( toInformacion )
		&& para que se enganche alguien
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function Validar_Cantidad( txVal as integer ) as boolean
		local llRetorno as boolean

		llRetorno = dodefault( txVal )
		
		if llRetorno and !This.lPermiteCantidadesNegativas and txVal < 0
			goServicios.Errores.LevantarExcepcionTexto( "No se pueden ingresar cantidades negativas" )
		endif 

		if this.cNombre = "FINALDEPRODUCCION" and txVal > this.CantidadLimite
			goServicios.Errores.LevantarExcepcionTexto( "No se puede ingresar una cantidad mayor a la pendiente de finalización (" + alltrim( str( this.CantidadLimite ) ) + ")" )
		endif
		
		return llRetorno
	endfunc		

	*--------------------------------------------------------------------------------------------------------
	function Setear_Articulo( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal )
			This.VerificarValidezArticulo( this.Articulo )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarValidezArticulo( toArticulo as entidad OF entidad.prg ) as Void
		*** Para el evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoInformarArticuloConColorOTalleFueraDePaletaOCurva( toInformacion as Object ) as Void
		&& este metodo levanta el evento disparado por el colaborador para que lo pueda capturar el kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva() as Void
		&& este metodo levanta el evento disparado por el colaborador para que lo pueda capturar el kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneArticuloCargado() as Boolean 
		if this.cNombre = "MOVIMIENTOSTOCKAINVENT"
			return ( !empty( This.Insumo_pk ) or this.NroItem != 0 ) and ( This.EsEdicion() or This.EsNuevo() )
		else
			return ( !empty( This.Articulo_pk ) or this.NroItem != 0 ) and ( This.EsEdicion() or This.EsNuevo() )
		endif


	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneDisponibleDeParticipantes() as Boolean
		local llRetorno As Boolean
		llRetorno = dodefault()
		if this.TieneArticuloCargado()
			if This.lControlaStock
				this.oCompStock.lInvertirSigno = this.lInvertirSigno
				llRetorno = llRetorno and This.oCompStock.TieneDisponibleDeParticipantes()
			EndIf	
		endif
		Return llRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as Void
		dodefault()
		this.lAdvertirMinimoReposicion = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoCambioAtributoDeCombinacion( tcAtributo as String, toItem as Object ) as Void
		local lcAtributo as String, loItem as Object

		if this.EsAtributoDeCombinacion( tcAtributo )
			this.lAdvertirMinimoReposicion = .t.
		endif 

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsAtributoDeCombinacion( tcAtributo as String ) as Void
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		
		if vartype( this.oCombinacion ) = "O"
			for each loItem in this.oCombinacion 
				if upper( alltrim( loItem ) ) == upper( alltrim( tcAtributo ) ) 
					llRetorno = .t.
					exit
				endif 
			endfor
		endif
		
		return llRetorno
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function ActualizarColeccionParticipantes() as Void
	endfunc 


enddefine

