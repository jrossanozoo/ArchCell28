define class ColaboradorValidacionControlDeStockProduccionDisponible as ZooSession of ZooSession.prg

	oComponenteStock = NULL

	*--------------------------------------------------------------------------------------------------------
	function oComponenteStock_Access() as variant
		if !this.ldestroy and ( !vartype( this.oComponenteStock ) = 'O' or isnull( this.oComponenteStock ) )
			this.oComponenteStock = _screen.zoo.CrearObjeto( "ComponenteStockProduccion" )
		endif
		return this.oComponenteStock
	endfunc

 	*-----------------------------------------------------------------------------------------
	function DebeValidarStockDisponible( toItem as Object, tlItemControlaDisponibilidad as Boolean ) as Boolean
		local llRetorno as Boolean
		if pemstatus( toItem, 'lCargandoPromo', 5 ) and toItem.lCargandoPromo
			llRetorno = .f.
		else
			llRetorno = this.TieneHabilitadoElControlDeStock( toItem )
			llRetorno = llRetorno and this.ProcesaStock( toItem )
			llRetorno = llRetorno and this.GeneraStock( toItem )
			llRetorno = llRetorno and this.ItemAdvierteStockDisponible( toItem, tlItemControlaDisponibilidad )
			llRetorno = llRetorno and this.AdvierteNoTieneDisponible( toItem )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function GeneraStock( toItem as Object ) As Boolean
		Local llRetorno as Boolean
		
		llRetorno = this.oComponenteStock.GeneraStock( toItem )
		
		Return llRetorno 
	Endfunc


	*-----------------------------------------------------------------------------------------
	protected function ProcesaStock( toItem as Object ) as Boolean
		local llRetorno
		llRetorno = !toItem.NoProcesarStock
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ItemAdvierteStockDisponible( toItem as Object, tlItemControlaDisponibilidad as Boolean ) as Boolean
		local llRetorno as Boolean	

		llRetorno = toItem.oCompStockProduccion.oEntidadPadre.AdvierteStockDisponible() and tlItemControlaDisponibilidad
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function TieneHabilitadoElControlDeStock( toItem as Object ) as Boolean
		local llRetorno as Boolean	

		llRetorno = toItem.oCompStockProduccion.TieneHabilitadoElControlDeStock()
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AdvierteNoTieneDisponible( toItem as Object ) as Boolean
		local llRetorno As Boolean
		llRetorno = .F.
		if !empty( toItem.Articulo_pk ) and ( toItem.EsEdicion() or toItem.EsNuevo() )
			if toItem.lControlaStock
				toItem.oCompStockProduccion.lInvertirSigno = toItem.lInvertirSigno
				llRetorno = toItem.oCompStockProduccion.AdvierteNoTieneDisponible()
			EndIf	
		endif
		Return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarStockDispoibleAlGrabar( toEntidad as Object, toDetalle as Object ) as Boolean
		local loItem as Object, loAcumuladoCombinacion as Object, lnDisponibilidadCombinacion As Float, lnCantidadSolicitadaCombinacion as Float, llRetorno as Boolean, ;
				lnDisponibilidadCombinacionEstado as float, lcEstadoDeStock as String, loObjetoInformacion as Object, lcMensaje as String, lnDisponibilidadActual as float, ;
				lnCantidadPedidoDeCompra as float

		llRetorno = .T.
				
		store 0 to	lnDisponibilidadCombinacion, lnCantidadSolicitadaCombinacion, lnDisponibilidadCombinacionEstado
		store .T. to llRetorno
		
		if toDetalle.oItem.lControlaStock
			this.SetearDatosEnComponenteStock( toEntidad, toDetalle )
			loAcumuladoCombinacion = This.ObtenerAcumuladoCombinacion( toDetalle )

			for each loItem in loAcumuladoCombinacion foxobject		
				lnCantidadPedidoDeCompra = 0
				lnDisponibilidadCombinacion = This.ObtenerStockCombinacion( loItem, "Cantidad" )
				lnDisponibilidadCombinacionEstado = This.ObtenerStockCombinacion( loItem, "Pedido" ) 
				lnDisponibilidadCombinacionEstado = lnDisponibilidadCombinacionEstado + This.ObtenerStockCombinacion( loItem, "EntregaPen" )
				if this.IncorporaElStockDePedidosDeCompraAlDisponible()
					lnCantidadPedidoDeCompra = This.ObtenerStockCombinacion( loItem, "PEDCOMP" )
				endif
				lnCantidadSolicitadaCombinacion = loItem.Cantidad * iif( toEntidad.lInvertirSigno, -1, 1 ) * this.FactorDeCorreccionDeDisponiblePorInvertirSigno( toEntidad )
				lnDisponibilidadActual = lnDisponibilidadCombinacion - lnDisponibilidadCombinacionEstado + lnCantidadPedidoDeCompra

				If  lnDisponibilidadActual < lnCantidadSolicitadaCombinacion and this.GeneraStock( loItem )
					lcMensaje = this.FormarMensajeComb( loItem, lnDisponibilidadActual )
					toEntidad.AgregarInformacion( lcMensaje, 1 )
					llRetorno = .F.
				endif
			endfor
			
			loObjetoInformacion = toEntidad.ObtenerInformacion()
			
			if loObjetoInformacion.Count > 1
				toEntidad.AgregarInformacion( "Combinaciones sin stock disponible.", 1 )
			endif
		endif

		Return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosEnComponenteStock( toEntidad as Object, toDetalle as Object ) as Void
		if toEntidad.lEsComprobanteConStock
			with this.oComponenteStock
				.InyectarEntidad( toEntidad )
				.InyectarDetalle( toDetalle )
				.oColStockInicial = toDetalle.oItem.oCompStockProduccion.oColStockInicial
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormarMensajeComb( toItemStock as Object, tnDisponibilidadActual as Integer ) as string
		local lcClaveInexistente as String, lcItem as String, loCombinacion as Object
		
		loCombinacion = this.oComponenteStock.oCombinacion

		lcClaveInexistente = "Combinación sin stock disponible: "

		for each lcItem in loCombinacion
			if !empty( toItemStock.&lcItem )
				lcClaveInexistente = lcClaveInexistente + proper( strtran( upper( lcItem ), "_PK" ) ) + ": " + alltrim( toItemStock.&lcItem ) + " - "
			else
				lcClaveInexistente = lcClaveInexistente + "Sin " + proper( strtran( upper( lcItem ), "_PK" ) ) + " - "
			endif
		endfor
		lcClaveInexistente = substr( lcClaveInexistente, 1, len( lcClaveInexistente ) - 3 ) + ;
			" (Disponible: " + alltrim( goServicios.Librerias.ValorAString( tnDisponibilidadActual ) ) + ;
			" Requerido: " + alltrim( goServicios.Librerias.ValorAString( abs( toItemStock.Cantidad ) ) ) + ")."

		return lcClaveInexistente
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStockCombinacion( toItem as Object, tcEstadoDeStock as String ) as Integer
		local lnRetorno as Integer, loItem as Object, lcItemComb as String, lnCantAcum as Integer, llComparacion as Boolean
		lnRetorno = 0

		if upper( alltrim( tcEstadoDeStock ) ) = "CANTIDAD"
			lnRetorno = this.oComponenteStock.ObtenerStockCombinacion( toItem )
		else
			lnRetorno = this.oComponenteStock.ObtenerStockCombinacionEstado( toItem, tcEstadoDeStock )
		endif

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerAcumuladoCombinacion( toDetalle as Object ) As Object
		local loRetorno as Object
		loRetorno = this.oComponenteStock.ObtenerColeccionAcumuladoCombinacion( toDetalle )
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function FactorDeCorreccionDeDisponiblePorInvertirSigno( toEntidad as Object ) as number
		return iif( alltrim( upper( toEntidad.cComprobante ) ) = "PEDIDO", -1, 1 ) && porque el pedido tiene invertir signo, para validar correctamente el stock disponible, sino rompe nota de credito.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IncorporaElStockDePedidosDeCompraAlDisponible() as Boolean
		return this.oComponenteStock.IncorporaElStockDePedidosDeCompraAlDisponible()
	endfunc 


enddefine
