define class ComponenteStockProduccion as Din_ComponenteStockProduccion of Din_ComponenteStockProduccion.prg

	#if .f.
		local this as ComponenteStockProduccion of ComponenteStockProduccion.prg
	#endif

	oInsumo = null
	oColStockInicial = null
	oColStock = null
	oItem = null
	nSigno = 1
	lInvertirSigno = .F.
	lProcesarStock = .T.
	nFaltanteInsumos = 0
	nFaltanteCombinacion = 0
	cErrorValidarDisponibilidad = ""
	lHabilitaControlStock = .F.
	nDataSessionStockCombinacion = 0
	nThisDataSession = 0
	cAtributoEstadoStock = ""
	oColaboradorConsultasDeStock = null
	nCodigoDeErrorPorFaltaDeStock = 9845
	lEventoNoHayStockEnInsumos = .f.
	oCopiadorDeItemsStockAColeccion = null

	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		dodefault()
		This.oColStockInicial = _screen.zoo.Crearobjeto( "zoocoleccion" )
		this.inicializar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function inicializar() as Void
		dodefault()


		** generar en din_
		with this
			.oCombinacion = _screen.zoo.crearobjeto( 'zooColeccion' )
			.oCombinacion.Add( 'Insumo_Pk' )
			.oCombinacion.Add( 'Color_Pk' )
			.oCombinacion.Add( 'Talle_Pk' )
			.oCombinacion.Add( 'Partida' )
			.oCombinacion.Add( 'Inventario_Pk' )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		This.oItem = Null
		This.oColStock = Null
		This.oColStockInicial = Null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarDetalle( toDetalle As detalle OF detalle.prg ) as Void
		This.oColStock = toDetalle
		This.oItem = toDetalle.oItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearStockInicial() as Void
		local loItem As Itemactivo of ItemActivo.Prg
		
		This.oColStockInicial.Remove( -1 )
		for each loItem in This.oColStock foxobject
			if this.lProcesarStock
				This.CopiarItemAColeccionOriginal( This.oColStockInicial, loItem )
			endif
		endfor				
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarStockInicial() as Void
		local loItem as Object
		for each loItem in this.oColStockInicial foxobject
			loItem.Cantidad = loItem.Cantidad * 2
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function oInsumo_Access()
		if !this.ldestroy and !vartype( this.oInsumo ) = 'O'
			this.oInsumo = _screen.zoo.InstanciarEntidad( 'Insumo' )
		endif
		Return this.oInsumo
	endfunc

	*-----------------------------------------------------------------------------------------
	Function oCopiadorDeItemsStockAColeccion_Access()
		if !this.ldestroy and !vartype( this.oCopiadorDeItemsStockAColeccion ) = 'O'
			this.oCopiadorDeItemsStockAColeccion = _screen.zoo.CrearObjeto( 'CopiadorDeItemsStockProduccionAColeccion' )
			this.oCopiadorDeItemsStockAColeccion.InyectarCombinacion( this.oCombinacion )
		endif
		Return this.oCopiadorDeItemsStockAColeccion
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColaboradorConsultasDeStock_Access()
		if !this.lDestroy and vartype( this.oColaboradorConsultasDeStock ) # "O"
			this.oColaboradorConsultasDeStock = _screen.Zoo.CrearObjeto( "ColaboradorConsultasDeStockProduccion" )
			this.oColaboradorConsultasDeStock.cAgrupamiento = ""   && goParametros.Nucleo.AgrupamientoParaConsultaDeStock
		endif
		Return this.oColaboradorConsultasDeStock
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerStockCombinacion( toItem As Object ) as float
		local lnRetorno as Integer, loItem as Object, lcItemComb as String, lnCantAcum as Integer, llComparacion as Boolean
		lnRetorno = 0
		try 
			this.oColaboradorConsultasDeStock.cTabla = this.oEntidad.oAD.cTablaPrincipal
			this.oColaboradorConsultasDeStock.cCampoCantidad = this.oEntidad.oAD.ObtenerCampoentidad( "Cantidad" )
			loFiltros = this.oColaboradorConsultasDeStock.ObtenerFiltrosParaConsultaStockCombinacion( toItem, this.oEntidad )
			lnRetorno = this.oColaboradorConsultasDeStock.ObtenerStockDisponible( loFiltros )
			lnCantAcum = 0
			for each loItem in this.oColStockInicial foxobject
				llComparacion = .t.
				for each lcItemComb in this.oCombinacion foxobject
					if !goLibrerias.CompararValores( loItem.&lcItemComb, toItem.&lcItemComb )
						llComparacion = .f.
					endif
				endfor
				
				if llComparacion
					lnCantAcum = lnCantAcum + loItem.Cantidad 
				endif
			endfor
			
			if this.lInvertirSigno
				lnRetorno = lnRetorno - lnCantAcum
			else
				lnRetorno = lnRetorno + lnCantAcum
			endif
		catch
			lnRetorno = 0
		Endtry		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerStockCombinacionEstado( toItem As Object, tcEstadoDeStock as String ) as float
		local lnRetorno as Integer, lnCantAcum as Integer, loFiltros as Object
		lnRetorno = 0

		try 
			this.oColaboradorConsultasDeStock.cTabla = this.oEntidad.oAD.cTablaPrincipal
			this.oColaboradorConsultasDeStock.cCampoCantidad = this.oEntidad.oAD.ObtenerCampoentidad( tcEstadoDeStock )
			loFiltros = this.oColaboradorConsultasDeStock.ObtenerFiltrosParaConsultaStockCombinacion( toItem, this.oEntidad )
			lnRetorno = this.oColaboradorConsultasDeStock.ObtenerStockDisponible( loFiltros )

			lnCantAcum = this.ObtenerCantidadAContemplarSiEstaModificandoComprobante( toItem, tcEstadoDeStock )

			lnCantAUsarComprometida = 0
			
			if this.lInvertirSigno
				lnRetorno = lnRetorno - lnCantAcum + lnCantAUsarComprometida
			else
				lnRetorno = lnRetorno + lnCantAcum - lnCantAUsarComprometida
			endif	
		catch to loError
			lnRetorno = 0
		Endtry		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadAContemplarSiEstaModificandoComprobante( toItem As Object, tcEstadoDeStock as String ) as Integer
		local loItem as Object, lcItemComb as String, lnCantAcum as Integer, llComparacion as Boolean
		lnCantAcum = 0
		for each loItem in this.oColStockInicial foxobject
			llComparacion = .t.
			for each lcItemComb in this.oCombinacion foxobject
				if !goLibrerias.CompararValores( loItem.&lcItemComb, toItem.&lcItemComb )
					llComparacion = .f.
				endif
			endfor
			
			if llComparacion
				lnCantAcum = lnCantAcum + loItem.Cantidad 
			endif
		endfor
		return lnCantAcum
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearyCargarCombinacion( toItem as Object ) as Boolean
		this.SetearCombinacion( toItem )
		return this.CargarEntidad()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function TieneDisponible() As Boolean
		Local llRetorno as Boolean, llGeneraStock as Boolean
		llRetorno = .F.
		&& Precondicion para validar disponibilidad
		if This.DebeValidarDisponibilidad()
			llRetorno = This.ValidarDisponibilidad( this.oItem )
			
		else
			llRetorno = .T.
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarDisponibilidad() as Boolean
		local llGeneraStock as Boolean, llRetorno as Boolean

		llRetorno = .F.
		llRetorno = This.lProcesarStock and this.TieneHabilitadoElControlDeStock() and !This.oItem.lEstaSeteandoValorSugerido and ( this.DebeValidarStock() ) ;
				and This.oItem.Inventario.ControlaStock
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarStock() as Boolean
		local llRetorno as Boolean
		
		llRetorno = this.CantidadRestaStock() and this.ValidaGeneraStock() &&or this.DebeValidarStockDisponible( tlGeneraStock )

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidaGeneraStock() as Boolean
		local llRetorno as Boolean, llGeneraStock as Boolean
		
		llGeneraStock = this.GeneraStock( This.oItem )
		llRetorno = llGeneraStock &&  and !this.lPermitePasarStockEnNegativoRompiendoTodo
		
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function TieneHabilitadoElControlDeStock() as Boolean
		local llRetorno as Boolean
		
*!*			llRetorno = goParametros.Felino.Generales.HabilitaControlStockEnProduccion
		llRetorno = .t.
		
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function CantidadRestaStock() as Boolean
		local llRetorno
		
		llRetorno = This.oItem.Cantidad # 0 and (( this.lInvertirSigno and This.oItem.Cantidad < 0 ) or ( !this.lInvertirSigno and This.oItem.Cantidad > 0 ))
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarStockEnItem() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function GeneraStock( toItem as Object ) As Boolean
		Local llRetorno as Boolean, llExisteInsumo as Boolean, loError as Exception, lcInsumo as String, loEntidad as Object
		llRetorno = !toItem.NoProcesarStock and !empty( toItem.Insumo_Pk )
		Return llRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected Function ValidarDisponibilidad( toItem as Object ) As boolean
		Local	lnCantItem as float, lnDisponibilidadCombinacion As Float, ;
				lnAcumuladoInsumo as Float, lnAcumuladoCombinacion as Float, ;
				lnCantidadSolicitadaCombinacion as Float, lnDisponibilidadActual as Integer, ;
				llRetorno as Boolean
		store 0 to	lnCantItem, ;
					lnDisponibilidadCombinacion, lnDisponibilidadDeInsumo, ;
					lnAcumuladoInsumo, lnAcumuladoCombinacion, lnDisponibilidadActual, ;
					lnCantidadSolicitadaCombinacion, lnCantidadSolicitadaInsumo
		store "" to This.cErrorValidarDisponibilidad
		store .T. to llRetorno
		
		lnCantItem = This.ObtenerCantidadItem( toItem )

		lnAcumuladoCombinacion	= This.obtenerAcumuladoCombinacion( toItem )

		lnCantidadSolicitadaCombinacion = lnCantItem + lnAcumuladoCombinacion
		lnDisponibilidadCombinacion = this.ObtenerDisponibilidad( "Cantidad", toItem )

		lnDisponibilidadActual = lnDisponibilidadCombinacion
		If  iif( lnDisponibilidadActual < 0, 0, lnDisponibilidadActual ) < lnCantidadSolicitadaCombinacion
			This.cErrorValidarDisponibilidad = "La Combinación no tiene stock disponible"
			llRetorno = .F.
		endif
		if llRetorno
		else
			This.nFaltanteCombinacion = lnCantidadSolicitadaCombinacion - lnDisponibilidadCombinacion
		Endif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AdvierteNoTieneDisponible() As boolean
		Local	lnCantItem as float, lnDisponibilidadCombinacion As Float, lnAcumuladoCombinacion as Float, lnCantidadSolicitadaCombinacion as Float, llRetorno as Boolean

		store 0 to	lnCantItem, lnDisponibilidadCombinacion, lnAcumuladoCombinacion, lnCantidadSolicitadaCombinacion
		
		llRetorno = .f.

		lnCantItem = This.ObtenerCantidadItem( this.oItem )
		lnAcumuladoCombinacion	= This.obtenerAcumuladoCombinacion( this.oItem )
		
		lnCantidadSolicitadaCombinacion = lnCantItem + lnAcumuladoCombinacion
		lnDisponibilidadCombinacion = this.ObtenerDisponibilidad( "Cantidad", this.oItem )
		If  lnDisponibilidadCombinacion < lnCantidadSolicitadaCombinacion 
			llRetorno = .T.
		endif

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDisponibilidad( tcAtributo as String, toItem as Object ) as integer
		local lnRetorno as Integer, lcEstadoDeStock as String
		
		if upper( alltrim( tcAtributo ) ) = "CANTIDAD"
			lnRetorno = This.ObtenerStockCombinacion( toItem ) 
		else
			lnRetorno = 0

		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDisponibilidadDeItem( tcAtributo as String, toItem as Object ) as integer
		local lnRetorno as Integer, lcEstadoDeStock as string

		if upper( alltrim( tcAtributo ) ) = "CANTIDAD"
			lnRetorno = This.ObtenerStockCombinacion( toItem ) 
		else
			lnRetorno = 0
		endif
		
		return lnRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerStockInicialCombinacion( toItem as Object ) as Void
		local lnRetorno as Integer
		
		lnRetorno = This.ObtenerStockCombinacion( toItem  ) 
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadItem( toItem, tlEstaValidandoMinimoDeResposicion as Boolean ) as Integer
		local llInvertirSigno as Boolean, lnCantidad as Integer
		
		llInvertirSigno = this.lInvertirSigno
		lnCantidad = toItem.Cantidad * iif( This.lInvertirSigno, -1, 1 )
		this.lInvertirSigno = llInvertirSigno
		
		Return lnCantidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAcumuladoInsumo() As integer
		local loItemColeccion as Object, lnRetorno as Integer, lnPosicion as Integer

		lnRetorno = 0 
		loItemColeccion = This.oColStock.ObtenerSiguiente( .t. )
		lnPosicion = 1
		do while !isnull( loItemColeccion )
			if 	goLibrerias.CompararValores( loItemColeccion.Insumo_Pk, this.oItem.Insumo_Pk ) and ;
				This.oItem.NroItem != lnPosicion and this.lProcesarStock

 				lnRetorno = lnRetorno + loItemColeccion.Cantidad 
 			endif 
 			loItemColeccion = This.oColStock.obtenerSiguiente()
 			lnPosicion = lnPosicion + 1 
		enddo
		if This.lInvertirSigno
			lnRetorno = lnRetorno * -1
		Endif
		return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerAcumuladoCombinacion( toItem as Object ) As integer
		local loItemColeccion as Object, lnRetorno as Integer, lnPosicion as Integer

		lnRetorno = 0 
		loItemColeccion = This.oColStock.ObtenerSiguiente( .t. )
		lnPosicion = 1
		do while !isnull( loItemColeccion )
			if 	this.CompararItemConItem( toItem, loItemColeccion ) and ;
				toItem.NroItem != lnPosicion and this.lProcesarStock

 				lnRetorno = lnRetorno + loItemColeccion.Cantidad 
 			endif 
 			loItemColeccion = This.oColStock.ObtenerSiguiente()
 			lnPosicion = lnPosicion + 1 
		enddo

		if This.lInvertirSigno
			lnRetorno = lnRetorno * -1
		Endif
		return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompararItemConItem( toItem1 as Object, toItem2 As Object ) as Boolean
		local lcAtributo as String, llRetorno as Boolean
		
		llRetorno = .T.
				
		if vartype( this.oItemKit ) = 'O' and toItem2.IdKit = this.oItemKit.IdKit
			llRetorno = .F.
		else
			for lnCantidad = 1 to this.oCombinacion.count
				lcAtributo = this.oCombinacion[ lnCantidad ]
				if toItem1.&lcAtributo != toItem2.&lcAtributo
					llRetorno = .F.
					exit
				endif 	
			endfor 
		endif	

		return llRetorno	

	endfunc 

	*-----------------------------------------------------------------------------------------
	* Obtiene el stock de la tabla y le resta lo que tenia incialmente en el movimiento actual
	Function ObtenerStockInsumo( tcInsumo_Pk as String ) As Float
		local loItem as Object, lnCantAcum as Integer, lnRetorno as float, loFiltros as Object, lnCantidadDisponible as Double

		lnCantAcum = 0
		for each loItem in this.oColStockInicial foxobject
			if goLibrerias.CompararValores( loItem.Insumo_Pk, tcInsumo_Pk )
				lnCantAcum = lnCantAcum + loItem.Cantidad 
			endif
		endfor

		this.oColaboradorConsultasDeStock.cTabla = this.oStockCombinacion.oAD.cTablaPrincipal
		this.oColaboradorConsultasDeStock.cCampoCantidad = this.oStockCombinacion.oAD.ObtenerCampoentidad( "Cantidad" )

		loFiltros = this.oColaboradorConsultasDeStock.ObtenerFiltrosParaConsultaStockCombinacion( this.oStockCombinacion, tcInsumo_Pk )

		lnCantidadDisponible = this.oColaboradorConsultasDeStock.ObtenerStockDisponible( loFiltros )
		if this.lInvertirSigno
			lnRetorno = lnCantidadDisponible - lnCantAcum
		else
			lnRetorno = lnCantidadDisponible + lnCantAcum
		endif

		return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarEnCombinaciones( ) as Boolean
		local lcAtributo as String, llRetorno as Boolean, lnAtributosVacios as Integer
		lnAtributosVacios = 0
		llRetorno = .T.
		
		for lnCantidad = 1 to this.oCombinacion.count
			lcAtributo = this.oCombinacion[ lnCantidad ]
			if empty( this.oItem.&lcAtributo ) 
				lnAtributosVacios = lnAtributosVacios + 1
			endif 	
		endfor 		

		if lnAtributosVacios = this.oCombinacion.count - 1
			llRetorno = .F.
		endif

		return llRetorno	

	endfunc

	*-----------------------------------------------------------------------------------------
	function Grabar() as zoocoleccion OF zoocoleccion.prg 
		local loColAfectante As zooColeccion of ZooColeccion.prg, loColAfectado As zooColeccion of ZooColeccion.prg, ;
				loColStockAfectado as zoocoleccion OF zoocoleccion.prg, loColStockInicialAfectado as zoocoleccion OF zoocoleccion.prg, ;
				lnI as Integer, loColRetorno As zoocoleccion OF zoocoleccion.prg, llInvertirSigno as Boolean, lnNumeroMovimientoDeStock as Integer, ;
				llInventarioControlaStock as Boolean

		loColRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )

		llInventarioControlaStock = .f.

		if this.EsMovimientoStockAInventario() and this.oEntidadPadre.EsTipoMovimientoSalida()
			llInventarioControlaStock = this.oEntidadPadre.InventarioOrigen.ControlaStock
		endif

		if this.EsMovimientoStockAProduccion()
			llInventarioControlaStock = this.oEntidadPadre.InventarioDestino.ControlaStock
		endif

		if this.EsMovimientoStockDesdeProduccion()
			llInventarioControlaStock = this.oEntidadPadre.InventarioOrigen.ControlaStock
		endif


		This.cAtributoEstadoStock = this.oEntidadPadre.ObtenerEstadoDeStockDeComprobante( this.oEntidadPadre.cComprobante )


		This.lHabilitaControlStock = llInventarioControlaStock

		llInvertirSigno = This.lInvertirSigno
		This.lInvertirSigno = this.ObtenerSigno( This.lInvertirSigno )
		loColAfectante = This.GrabarComprobante( This.oColStock, This.oColStockInicial ) && Afectante

		loColAfectado = _screen.zoo.crearobjeto( "zoocoleccion" )

		for lnI = 1 to loColAfectante.Count
			loColRetorno.Add( loColAfectante.Item[ lnI] )
		endfor
		for lnI = 1 to loColAfectado.Count
			loColRetorno.Add( loColAfectado.Item[ lnI] )
		endfor
		This.lInvertirSigno = llInvertirSigno


		if this.EsMovimientoStockAInventario() ;
		  and !This.oEntidadPadre.lEsUnContraMovimiento ;
		  and !this.oEntidadPadre.VerificarContexto( "CB" )
			do case
				case This.oEntidadPadre.EsNuevo()
					this.GenerarContraMovimientos( loColRetorno )
				case This.oEntidadPadre.lEliminar
					this.EliminarContraMovimientos( loColRetorno )
			endcase
		endif


		return loColRetorno
	endfunc

	*------------------------------------------------------------------------------------------
	protected function GenerarContraMovimientos( toColeccion as zoocoleccion OF zoocoleccion.prg ) as Void
		local loContraMov as Object, loColSentenciasInsert as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loItem as Object, lnIndCol as Integer, lnCantidadGenerados as Integer, lcNumerosGenerados as String, lcCursorInv as String

		lnCantidadGenerados = 0
		lcNumerosGenerados = ""

		lcCursorInv  = "c_" + sys(2015)
		create cursor &lcCursorInv ( inventario c(100) )
		for each loItem in this.oEntidadPadre.MovimientoDetalle
			if !empty( alltrim( loItem.InventarioDestino_PK ) )
				select ( lcCursorInv )
				locate for alltrim( inventario ) == alltrim( loItem.InventarioDestino_PK )
				if not found()
					insert into &lcCursorInv ( inventario ) values (loItem.InventarioDestino_PK )
				endif
			endif
		endfor

		loContraMov = _screen.zoo.instanciarentidad("MovimientoStockAInvent")
		loContraMov.lEsUnContraMovimiento = .t.
		**loContraMov.lInvertirSigno = !loContraMov.lInvertirSigno

		select ( lcCursorInv )
		scan
			loContraMov.Nuevo()
			this.lInvertirSigno = loContraMov.lInvertirSigno
			loContraMov.InventarioOrigen_pk = &lcCursorInv..inventario
			loContraMov.tipo = 1
			loContraMov.Zadsfw = "Generado automáticamente originado en el movimiento de stock entre inventarios Nº " + alltrim( str( this.oEntidadPadre.Numero ) ) ;
								+ " (Invetario origen: " + alltrim( this.oEntidadPadre.InventarioOrigen_PK ) + ")"
			loContraMov.oAd.GrabarNumeraciones()
			for each loItem in  this.oEntidadPadre.MovimientoDetalle
				if !empty(loItem.Insumo_Pk) and alltrim( loItem.InventarioDestino_pk ) == alltrim( &lcCursorInv..inventario )
					with loContraMov.MovimientoDetalle
						.LimpiarItem()
						.oItem.Insumo_Pk = loItem.Insumo_Pk
						.oItem.InsumoDetalle = alltrim( loItem.InsumoDetalle )
						.oItem.Color_PK = loItem.Color_PK
						.oItem.ColorDetalle = alltrim( loItem.ColorDetalle )
						.oItem.Talle_PK = loItem.Talle_PK
						.oItem.TalleDetalle = alltrim( loItem.TalleDetalle )
						.oItem.Partida = loItem.Partida
	**					.oItem.Inventario_PK = loItem.InventarioDestino_PK
						.oItem.Cantidad = loItem.Cantidad
						.Actualizar()
					endwith
				endif 
			endfor

			with loContraMov.Compafec
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
			lcNumerosGenerados = lcNumerosGenerados + iif( empty( lcNumerosGenerados ), "", ", " ) + alltrim( str( loContraMov.Numero ) )

			loColSentenciasInsert = loContraMov.oAD.ObtenerSentenciasInsert()
			with loContraMov.MovimientoDetalle.oItem.oCompStockProduccion
				.lNuevo = this.oEntidadPadre.EsNuevo()
				.lEdicion = this.oEntidadPadre.EsEdicion()
				.lEliminar = this.oEntidadPadre.lEliminar
				.lAnular = this.oEntidadPadre.lAnular
				loColSentenciasAdic = .Grabar()
			endwith
			for lnIndCol = 1 to loColSentenciasInsert.count
			      toColeccion.agregar( loColSentenciasInsert.item(lnIndCol) )
			endfor
			for lnIndCol = 1 to loColSentenciasAdic.count
				toColeccion.agregar( loColSentenciasAdic.item(lnIndCol) )
			endfor

			loContraMov.Cancelar()
		endscan

		if lnCantidadGenerados > 0
			toColeccion.agregar( this.oEntidadPadre.ObtenerSentenciaAccionesDelSistema( lnCantidadGenerados, lcNumerosGenerados, loContraMov.cDescripcion ) )
		endif

**		this.lYaGeneroContracomprobante = .T.
		loContraMov.release()	
		if used( lcCursorInv )
			use in ( lcCursorInv )
		endif

	endfunc 


	*------------------------------------------------------------------------------------------
	protected function EliminarContraMovimientos( toColeccion as zoocoleccion OF zoocoleccion.prg ) as Void
		local loContraMov as Object, loColSentenciasDelete as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loItem as Object, lnIndCol as Integer, lcCursorCod as String, lcSql as String, lcCodigoContraMov as String

		loContraMov = _screen.zoo.instanciarentidad("MovimientoStockAInvent")
		loContraMov.lEsUnContraMovimiento = .t.

		lcCursorCod  = "c_" + sys(2015)
		lcSql = "select codigo from compafe where afecta = '" + this.oEntidadPadre.Codigo + "' and lower(afetipo) = 'afectado' and afetipocom = 93 " 
		goServicios.Datos.EjecutarSentencias(  lcSql, "compafe", "", lcCursorCod, this.datasessionid )

		select ( lcCursorCod )
		scan
			lcCodigoContraMov = &lcCursorCod..Codigo

			with loContraMov
				.Codigo = lcCodigoContraMov

				.RestaurarStock()

				.lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .t.
				**if .ValidarAntesDeAnularForzadaParaProduccion()
				if .ValidarAnulacion()

					loColSentenciasDelete = .oAd.ObtenerSentenciasDelete()
					with .MovimientoDetalle.oItem.oCompStock
						.lNuevo = this.oEntidadPadre.EsNuevo()
						.lEdicion = this.oEntidadPadre.EsEdicion()
						.lEliminar = this.oEntidadPadre.lEliminar
						.lAnular = this.oEntidadPadre.lAnular
						**.lInvertirSigno = ! .lInvertirSigno 
						loColSentenciasAdic = .Grabar()
					endwith

					for lnIndCol = 1 to loColSentenciasDelete.count
						toColeccion.agregar( loColSentenciasDelete.item(lnIndCol) )
					endfor
					for lnIndCol = 1 to loColSentenciasAdic.count
						toColeccion.agregar( loColSentenciasAdic.item(lnIndCol) )
					endfor

				endif
				.lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .f.

			endwith
		endscan

		loContraMov.release()	

		if used( lcCursorCod )
			use in select ( lcCursorCod )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ClonarColeccionStock( toColeccion as Object ) as ZooColeccion of ZooColeccion.prg
		local loRetorno as Object, lnI as Integer
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		for lnI = 1 to toColeccion.Count
			if This.EsUnItemAfectado( toColeccion.Item[ lnI ] )
				This.CopiarItemAColeccionOriginal( loRetorno, toColeccion.Item[ lnI ] )
				loRetorno.Item( loRetorno.Count ).NoProcesarStock = .F.
			Endif
		endfor
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsUnItemAfectado( toItem as Object ) as Boolean
		return This.oEntidadPadre.EsUnItemAfectado( toItem )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ModificaStockBasadoEn() as Boolean
		return This.oEntidadPadre.ModificaStockBasadoEn()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function TieneFuncionalidadBasadoEn() as Boolean
		return This.oEntidadPadre.TieneFuncionalidadBasadoEn()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RestaStockActualDelInicial( toStockInicial as Object, toColStockAGrabar as zoocoleccion OF zoocoleccion.prg ) as zoocoleccion of zoocoleccion.prg
		local loItemStock as Object, loItemGrabar as Object, llExiste as Boolean, lnCantidad as Number, lcItem as Strin

		** recorre la coleccion a grabar y resta el inicial
		for each loItemStock in toStockInicial foxobject
			if !loItemStock.NoProcesarStock
				lcItem = ""
				for lnCantidad = 1 to this.oCombinacion.count
					lcAtributo = this.oCombinacion[ lnCantidad ]

					lcItem =  lcItem  + loItemStock.&lcAtributo
				endfor

				if toColStockAGrabar.buscar( lcItem )
					toColStockAGrabar.item( lcItem ).cantidad = toColStockAGrabar.item( lcItem ).cantidad - loItemStock.cantidad
				else
					lnCantidad = loItemStock.Cantidad * ( -1 )
					this.oCopiadorDeItemsStockAColeccion.CopiarItemAColeccion( toColStockAGrabar, loItemStock, lcItem )
					toColStockAGrabar.Item( toColStockAGrabar.Count ).Cantidad = lnCantidad
				endif
			endif
		endfor		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GrabarComprobante( toColStockActual as Object, toStockInicial as Object ) as zoocoleccion OF zoocoleccion.prg 
		local	loItemStock as Object, loItemGrabar as Object, lcItemAux as String , lnCantidad as Integer, ;
				llExiste as Boolean, loColSentencias as zoocoleccion OF zoocoleccion.prg, ;
				loColInsumoFinal as zoocoleccion OF zoocoleccion.prg , loColCombinacionFinal as zoocoleccion OF zoocoleccion.prg, ;
				loColArtAuxiliar as zoocoleccion OF zoocoleccion.prg, lnError as Integer, ;
				loInfo as Object, loItem as Object, loInfoStockArt as Object, loInfoStockComb as Object, ;
				loErrorArt as zooexception OF zooexception.prg, loErrorComb as zooexception OF zooexception.prg, llAnular as Boolean
		loColCombinacionFinal	= _screen.zoo.crearobjeto( "zoocoleccion" )
		loColStockAGrabar		= _screen.zoo.crearobjeto( "zoocoleccion" )		
		loColSentencias			= _screen.zoo.crearobjeto( "zoocoleccion" )		
		loInfo					= this.CrearObjeto( "ZooInformacion" )

		if this.EsMovimientoStockAProduccion()
			this.ReemplazarArticuloPorInsumo()
		endif

		for each loItemStock in toColStockActual foxobject
			llAnular = ( this.lAnular or ( !this.lNuevo and this.lEliminar ) )
			if !empty( loItemStock.Insumo_Pk ) and !empty( loItemStock.cantidad ) and iif( vartype( loItemStock.CantidadInsumo ) = "U", .t., !empty( loItemStock.CantidadInsumo ) ) and !llAnular and this.lProcesarStock and !loItemStock.NoProcesarStock
					***
					***loItemStock.cantidad = loItemStock.CantidadInsumo
					***loItemStock.Insumo_Pk = loItemStock.Insumo_pk    &&&&&&&&&&&&
					***
					***
					this.AgruparPorCombinacion( loColStockAGrabar, loItemStock )
			endif
		endfor 		
		this.RestaStockActualDelInicial( toStockInicial, @loColStockAGrabar )

		**************** Agrupar por articulos y por combinaciones ****************
		if toStockInicial.Count > 0
			for each loItemStock in loColStockAGrabar foxobject
				if !empty( loItemStock.Insumo_Pk ) and !empty( loItemStock.cantidad ) and this.lProcesarStock and !loItemStock.NoProcesarStock
					this.AgruparPorCombinacion( loColCombinacionFinal, loItemStock )
				endif
			endfor 	
		else
			loColCombinacionFinal.agregarrango( loColStockAGrabar )
		endif
		llTiroExcepcion = .F.
		**************** Obtener sentencias sql para actualizar stockCombinacion ****************		
		loColArtAuxiliar = null
		loColArtAuxiliar = _Screen.Zoo.CrearObjeto( "ZooColeccion" )

		for each loItemStock in loColCombinacionFinal foxobject
			try
				This.lEventoNoHayStockEnInsumos = .f.
				this.GrabarEnCombinacion( loItemStock, @loColArtAuxiliar )
				for each lcItemAux in loColArtAuxiliar foxobject
					loColSentencias.agregar( lcItemAux )
				endfor
				if This.lEventoNoHayStockEnInsumos
					This.oStockCombinacion.ExcepcionNoHayStock()
				endif
			catch to loErrorCom
				llTiroExcepcion = .T.
				lnError = 0
				if vartype( loErrorCom.UserValue ) = 'O' and !isnull( loErrorCom.UserValue )
					lnError = loErrorCom.UserValue.nZooErrorNo
				endif
				if ( this.oEntidad.nCodigoDeErrorPorFaltaDeStock == lnError or this.nCodigoDeErrorPorFaltaDeStock == lnError ) and !this.oEntidad.lPiezaCerrada
					loInfo.AgregarInformacion( this.FormarMensajeComb( loItemStock ) )
				else
					goServicios.Errores.LevantarExcepcion( loErrorCom )
				endif
			endtry
		endfor
		if llTiroExcepcion
			if loInfo.Count > 1
				lcMensajeSinStock = "Sin stock ó stock afectado por otro/s comprobante/s."
				if !goParametros.Felino.Generales.PermitirPasarSinStock
					lcMensajeSinStock = "No se puede realizar esta operación. " + lcMensajeSinStock
				endif
				loInfo.AgregarInformacion( lcMensajeSinStock )
			endif
			if goParametros.Felino.Generales.PermitirPasarSinStock
				This.eventoNoHayStock( loInfo )
			else
				goServicios.Errores.LevantarExcepcion( loInfo )			
			endif
		endif
	
		if this.EsMovimientoStockAProduccion()
			this.ReemplazarInsumoPorArticulo()
		endif
		return loColSentencias		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoNoHayStock( toInfo ) as Void

	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionAcumuladoCombinacion( loDetalle as Object ) as Object
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		
		for each loItem in loDetalle foxobject
			if !empty( loItem.Insumo_Pk )
				this.AgruparPorCombinacion( loRetorno, loItem )
			endif
		endfor

		return loRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function AgruparPorCombinacion( toColCombinacionFinal as object , toItemStock as Object  ) as Void
		local lnCantidad as Integer, lcItem as String, lcAtributo as String

		lcItem = ""
		for lnCantidad = 1 to this.oCombinacion.count
			lcAtributo = this.oCombinacion[ lnCantidad ]

*!*				if upper( lcAtributo ) = "Insumo_Pk" and vartype( toItemStock.Insumo_pk ) = "C"   &&&&&&&&&&&&
*!*					lcItem =  lcItem  + rtrim( toItemStock.Insumo_pk )								&&&&&&&&&&&&
*!*				else																						&&&&&&&&&&&&

				**lcItem =  lcItem  + rtrim( toItemStock.&lcAtributo )
				lcItem =  lcItem  + toItemStock.&lcAtributo

*!*				endif

		endfor

		if toColCombinacionFinal.buscar( lcItem )
			if this.EsMovimientoStockAProduccion()
				toColCombinacionFinal.item( lcItem ).cantidad = toColCombinacionFinal.item( lcItem ).cantidad + toItemStock.CantidadInsumo
			else
				toColCombinacionFinal.item( lcItem ).cantidad = toColCombinacionFinal.item( lcItem ).cantidad + toItemStock.cantidad
			endif
		else
			this.oCopiadorDeItemsStockAColeccion.CopiarItemAColeccion( toColCombinacionFinal , toItemStock , lcItem  ) 
		endif
	endfunc 
	*-----------------------------------------------------------------------------------------
	function CopiarItemAColeccionOriginal( toColeccion as Object, toItem as Object ) as Void
		This.oCopiadorDeItemsStockAColeccion.CopiarItemAColeccion( toColeccion, toItem )
		if This.TieneFuncionalidadBasadoEn()
			This.AgregarAtributosBasadoEn( toColeccion.Item[ toColeccion.count ], toItem )
		Endif

	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosBasadoEn( toItemStock as Object, toItem as Object ) as Void
		This.oEntidadPadre.AgregarAtributosBasadoEn( toItemStock, toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoNoHayStockEnInsumo() as Void
		this.lEventoNoHayStockEnInsumos = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GrabarEnCombinacion( toItem as Object, toColArt as Object ) as Void
		local loError as zooexception OF zooexception.prg, llObtener as Boolean ;
			, lcAtributoEstadoStock as String
		local lcCompGenerado as String, lcNombreDescrip as String, lcNumCompGenerado as String
		lcAtributoEstadoStock = This.cAtributoEstadoStock

		if this.generaStock( toItem ) 
			this.SetearCombinacion( toItem )

			this.oEntidad.lHabilitaControlStock = this.lHabilitaControlStock ;
			and (( this.lInvertirSigno and toItem.Cantidad < 0 ) or ( !this.lInvertirSigno and toItem.Cantidad > 0 ))
*!*				this.oEntidad.lHabilitaControlStock = !this.lPermitePasarStockEnNegativoRompiendoTodo And this.lHabilitaControlStock ;
*!*				and (( this.lInvertirSigno and toItem.Cantidad < 0 ) or ( !this.lInvertirSigno and toItem.Cantidad > 0 ))

			if this.CargarEntidad()
				this.oEntidad.ModificarSinBuscarYCargar()
				llObtener = .F.
			Else
				this.oEntidad.Nuevo()
				try
					this.SetearCombinacion( toItem )
					**this.oEntidad.ReasignarPk_Con_CC()
					this.oEntidad.Codigo = goLibrerias.ObtenerGuidPk()   &&&&&&&&&&
					llObtener = .T.
				catch to loError
					this.oEntidad.CancelarSinBuscarYCargar()
					goServicios.Errores.LevantarExcepcion( loError )
				Endtry
			endif
			if vartype( this.oEntidadPadre.DescripcionFW ) != "U"
				if !isnull(this.oEntidadPadre) and vartype(this.oEntidadPadre) == "O" and pemstatus(this.oEntidadPadre,"ComprobanteGenerado", 5)
					lcCompGenerado = upper(substr(this.oEntidadPadre.ComprobanteGenerado,1,10))
					lcNombreDescrip = upper(substr(this.oEntidadPadre.DescripcionFW,1,20))				

					this.oEntidad.DescripcionComprobante = this.oEntidadPadre.DescripcionFW

				else
					this.oEntidad.DescripcionComprobante = this.oEntidadPadre.DescripcionFW
				endif
			endif

			Try
				This.bindearevento( this.oEntidad, "EventoNoHayStock", This, "EventoNoHayStockEnInsumo" )
				this.oEntidad.lGrabandoComponente = .t.

				if this.lInvertirSigno
					**this.oEntidad.&lcAtributoEstadoStock. = + toItem.Cantidad
					this.oEntidad.&lcAtributoEstadoStock = + toItem.Cantidad
				else
					**this.oEntidad.&lcAtributoEstadoStock. = - toItem.Cantidad
					this.oEntidad.&lcAtributoEstadoStock = - toItem.Cantidad
				endif
			catch to loError
				this.oEntidad.CancelarSinBuscarYCargar()
				goServicios.Errores.LevantarExcepcion( loError )
			finally 
				this.desbindearevento( this.oEntidad, "EventoNoHayStock", This, "EventoNoHayStockEnInsumo" )
				this.oEntidad.lGrabandoComponente = .f.
			Endtry
			&& Se deja de validar porque la asignacion es en linea y el control lo hace el assign de cantidad
			&& El resto de los atributos fueron validados en la entidad que esta consumiendo el componente
			toColArt = this.oEntidad.ObtenerSentenciasSQL( llObtener ) 
			this.oEntidad.CancelarSinBuscarYCargar()
		else
			toColArt = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarCantidadCombinacionDelAgrupamientoAEntidadDeStock( toItem as Object ) as Void
		if this.oEntidad.VerificaStockAgrupamiento()
			this.oEntidad.nCantidadDisponibleEnAgrupamiento = this.ObtenerDisponibilidadDeItem( "Cantidad", toItem )
			this.oEntidad.lFlagEsNuevo = this.lNuevo
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function nSigno_Assign( tnValue )
		if tnValue= 1 or tnValue = -1
			this.nSigno = tnValue
		else
			this.nSigno = 1
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ConsultarStockDeInsumo( tcCodInsumo as String ) as String
		local lcXmlRetorno as String

		this.xmlacursor( this.oEntidad.oAd.ObtenerDatosEntidad( "", "insumo = '" + tcCodInsumo + "'" ), "c_StockDisp" )

		lcSql = "select " + this.oEntidad.cAtributosCombinacion + ", sum( cantidad ) as sum_cantidad " + ;
				" from c_StockDisp " + ;
				" group by " + this.oEntidad.cAtributosCombinacion  + ;
				" into cursor c_StockDisp "
			
		&lcSql

		lcXmlRetorno = this.cursoraxml( "c_StockDisp" )
		
		use in select( "c_StockDisp" )
			
		return lcXmlRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Recibir( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String, tcCursorCabecera as String ) as Void
		local loError as Exception, loTablasComb as zoocoleccion OF zoocoleccion.prg, loTablasArt as zoocoleccion OF zoocoleccion.prg
		with This
			if !.lComponenteDetalleKits
				.GuardarDataSession()
				try
					.SetearDataSession( toEntidad.DataSessionId )
					.AbrirTablasSqlServer()
					.cAtributoEstadoStock = toEntidad.ObtenerEstadoDeStockDeComprobante( toEntidad.cNombre )
					.CrearCursorFiltrado( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )
*!*						.AgregarDatosAfectaciones( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera ) 
					.AgregarCampoClavePrimariaAStockCombinacion( toEntidad.cPrefijoRecibir + This.oStockCombinacion.ObtenerNombre() )
					loTablasComb = .PrepararXMLCombinacion( toEntidad )
				
					.CerrarTablasSqlServer()
					if This.lProcesarStock

						.oStockCombinacion.lActualizaRecepcion = .T.
						.oStockCombinacion.cPrefijoRecibir = toEntidad.cPrefijoRecibir
						.oStockCombinacion.cIdentificadorConexion = toEntidad.cIdentificadorConexion
						.oStockCombinacion.Recibir( loTablasComb ) && StockCombinacion

					Endif	
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError ) 
				finally
					.RestaurarDataSession()
				endtry
			endif
		EndWith	
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AbrirTablasSqlServer() as Void
		local lcTabla as String, lcCampoPK as String, lcCamposIndice as String

		if goServicios.Datos.EsSqlServer()
			lcTabla = This.oStockCombinacion.oAd.cTablaPrincipal
			goServicios.Datos.EjecutarSentencias( "Select * From " + lcTabla, lcTabla, "", lcTabla, This.oStockCombinacion.DataSessionID )
			lcTabla = This.oInsumo.oAd.cTablaPrincipal
			goServicios.Datos.EjecutarSentencias( "Select * From " + lcTabla, lcTabla, "", lcTabla, This.oStockCombinacion.DataSessionID )
			select ( This.oStockCombinacion.oAd.cTablaPrincipal )
			lcCamposIndice = strtran( This.oStockCombinacion.oAd.cExpresionCCPorCampos, "#tabla#.", "", 1, -1, 1 )
			index on &lcCamposIndice tag ( This.oStockCombinacion.oAd.cTagClaveCandidata )
			select ( This.oInsumo.oAd.cTablaPrincipal )
			lcCampoPk = This.oInsumo.oAd.ObtenerCampoEntidad( This.oInsumo.ObtenerAtributoClavePrimaria() )
			index on &lcCampoPK tag ( This.oInsumo.oAd.cTagClavePk )
		EndIf
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function CerrarTablasSqlServer() as Void
		if goServicios.Datos.EsSqlServer()
			use in select( This.oStockCombinacion.oAd.cTablaPrincipal )
		EndIf
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function PrepararXMLCombinacion( toEntidad  as Object ) as zoocoleccion OF zoocoleccion.prg
		local lcCursorCombinacion as String, lcCamposSelect as String, lcAtributoEstadoStock 
	
		lcCursorCombinacion = toEntidad.cPrefijoRecibir + This.oStockCombinacion.ObtenerNombre()
		lcCamposSelect = This.ObtenerCamposSelectStockCombinacion()
		lcAtributoEstadoStock = this.obtenerExpresionConCampoSegunEstadoStock( .f.)
		if !empty( lcAtributoEstadoStock )
			lcCamposSelect = lcCamposSelect + "," + lcAtributoEstadoStock
		endif 
		select &lcCamposSelect ;
			from &lcCursorCombinacion ;
			into cursor &lcCursorCombinacion 

		return This.PrepararXmlGenerico( lcCursorCombinacion )
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function PrepararXmlGenerico( tcCursor as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _Screen.zoo.crearobjeto( "zooColeccion" )
		copy to ( _Screen.zoo.ObtenerRutaTemporal() + tcCursor )
		use in select( tcCursor )
		loRetorno.Agregar( _Screen.zoo.ObtenerRutaTemporal() + tcCursor )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorFiltrado( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String, tcCursorCabecera as String ) as Void
		local	lcCamposSelect as String, lcCamposGroupBy as String, lcWhere as String, ;
				lcCursorCombinacion as String, lcCursorInsumos as String, lcCursorEntidad as String, lcCampoPk as String, ;
				lcCampoConsulta1 as String, lcCampoConsulta2 as String, lcCampoDescripcionFW as String, lcAtributoEstadoDeStock as String

		lcCursorCombinacion = toEntidad.cPrefijoRecibir + This.oStockCombinacion.ObtenerNombre()
		lcCursorEntidad = toEntidad.cPrefijoRecibir + toEntidad.ObtenerNombre()

		with this
			lcCamposSelect = .ObtenerCamposSelect( toEntidad, tcAtributoDetalle )
			lcCampoPk = .ObtenerCampoPK( toEntidad, tcAtributoDetalle )
			lcWhere = .ObtenerWhere( toEntidad, tcAtributoDetalle )
			.AgregarSignoCursorDetalle( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )
			lcCampoConsulta1 = "cd." + lcCampoPk
			lcCampoConsulta2 = "ce." + toEntidad.oAd.ObtenerCampoEntidad( toEntidad.ObtenerAtributoClavePrimaria() )

			lcCampoDescripcionFW = this.ObtenerCampoDescripcionFW( toEntidad )
			select &lcCamposSelect, &lcCampoConsulta1, &lcCampoDescripcionFW ;
				from &tcCursorDetalle cd inner join &lcCursorEntidad ce on &lcCampoConsulta1 = &lcCampoConsulta2 ;
				where &lcWhere ;
				into cursor &lcCursorCombinacion ReadWrite
				 
			.AgregarCampoCantidadOriginalAStockCombinacion( lcCursorCombinacion )
			.AgregarCamposTransferencias( lcCursorCombinacion )
			lcAtributoEstadoDeStock = This.catributoestadostock
			
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function GuardarDataSession() as Void
		with This
			.nDataSessionStockCombinacion = .oStockCombinacion.DataSessionId
			.nThisDataSession = .DataSessionId
		EndWith	
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function RestaurarDataSession() as Void
		with This
			.oStockCombinacion.DataSessionId	=	.nDataSessionStockCombinacion
			.DataSessionId						=	.nThisDataSession
		EndWith	
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function SetearDataSession( tnDataSessionId as Integer ) as Void
		with This
			store tnDataSessionId to .DataSessionId, .oStockCombinacion.DataSessionId &&, .oStockInsumos.DataSessionId
		EndWith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposSelect( toEntidad as Object, tcAtributoDetalle as String ) as String
		local lcListaCampos as String, lcItem as String, lcCampo as String, lcMetodo as String, lcCampoPk as String, lcEstadoStock 

		lcEstadoStock = this.cAtributoEstadoStock
		tcAtributoDetalle = alltrim( tcAtributoDetalle )
		lcMetodo = "ObtenerCampoDetalle" + tcAtributoDetalle
		lcCampo = toEntidad.oAd.&lcMetodo( "Cantidad" )
		lcListaCampos = " " + lcCampo + " * Signo as " + lcEstadoStock + " "
		for each lcItem in This.oCombinacion foxobject
			lcItem = strtran( upper( lcItem ) , "_PK", "" )
			lcCampo = toEntidad.oAd.&lcMetodo( lcItem )
				lcListaCampos = lcListaCampos + "," + lcCampo + " as " + lcItem
		endfor
		return lcListaCampos
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposSelectStockCombinacion() as String
		local lcListaCampos as String, lcItem as String, lcCampo as String, lcMetodo as String, lcAtributoEstadoStock

		lcAtributoEstadoStock = this.cAtributoEstadoStock 
		with This.oStockCombinacion.oAd
			lcCampo = .ObtenerCampoEntidad( lcAtributoEstadoStock )
			lcListaCampos = this.ObtenerExpresionConCamposDeAtributosGenericosParaSelect( "", 3 ) + ", "+ lcAtributoEstadoStock + " as " + lcCampo
			lcCampo = .ObtenerCampoEntidad( lcAtributoEstadoStock + "Original" )
			lcListaCampos = lcListaCampos + "," + lcCampo
			lcCampo = .ObtenerCampoEntidad( This.oStockCombinacion.ObtenerAtributoClavePrimaria() )
			lcListaCampos = lcListaCampos + "," + lcCampo

			for each lcItem in This.oCombinacion foxobject
				lcItem = strtran( upper( lcItem ) , "_PK", "" )
				lcCampo = .ObtenerCampoEntidad( lcItem )
				lcListaCampos = lcListaCampos + "," + lcItem + " as " + lcCampo
			endfor
			
			lcListaCampos = lcListaCampos + "," + .ObtenerCampoEntidad( "DescripcionFW" )
		EndWith
		return lcListaCampos
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoPK( toEntidad as Object, tcAtributoDetalle as String ) as String
		local lcMetodo as String
		
		lcMetodo = "ObtenerCampoDetalle" + alltrim( tcAtributoDetalle )
		
		return toEntidad.oAd.&lcMetodo( toEntidad.&tcAtributoDetalle..oItem.cAtributoPK )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerWhere( toEntidad as Object, tcAtributoDetalle as String ) as String
		local	lcWhere as String, lcMetodo as String, lcTablaStockInsumos As String, lcCampoNoProcesarStock as String, ;
				lcCampoInsumoStock as String ,lcCampoGeneraStock as String, lcCampoInsumo as String

		lcMetodo = "ObtenerCampoDetalle" + alltrim( tcAtributoDetalle )
		lcCampoNoProcesarStock = toEntidad.oAd.&lcMetodo( "NoProcesarStock" )
		lcCampoInsumo = toEntidad.oAd.&lcMetodo( "Insumo" )
		lcCampoInsumoStock = This.oInsumo.oAd.ObtenerCampoEntidad( This.oInsumo.ObtenerAtributoClavePrimaria() )
		lcCampoGeneraStock = This.oInsumo.oAd.ObtenerCampoEntidad( "Comportamiento" )
		lcTablaStockInsumos = This.oInsumo.oAd.cTablaPrincipal

		lcWhere =	"!" + lcCampoNoProcesarStock + " and " + ;
					lcCampoInsumo + " In ( Select " + lcCampoInsumoStock + " from " + lcTablaStockInsumos + " where " + lcCampoGeneraStock + " <= 1 ) " 

		return lcWhere
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarSignoCursorDetalle( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String , tcCursorCabecera as String ) as Void
		local lcEntidad as String, lcCampoCodigoCabecera as String, lcCampoCodigoDetalle as String, lcMetodo as String, ;
				lcCampoTipo as String, lcConsulta as String, lcCursor as String, lnSigno as Integer

		lcCursor = sys( 2015 )
		lcEntidad = upper( alltrim( toEntidad.ObtenerNombre() ) )
		lcMetodo = "ObtenerCampoDetalle" + alltrim( tcAtributoDetalle )
		lcCampoCodigoDetalle = toEntidad.oAd.&lcMetodo( toEntidad.&tcAtributoDetalle..oItem.cAtributoPk )
		lcCampoCodigoCabecera = toEntidad.oAd.ObtenerCampoEntidad( toEntidad.ObtenerAtributoClavePrimaria() )

		if lcEntidad == "MOVIMIENTODESTOCK" or lcEntidad == "MOVIMIENTOSDESTOCKINTERNOS"
			lcCampoTipo = toEntidad.oAd.ObtenerCampoEntidad( "Tipo" )
			***No sacar el 01 que esta en la linea de abajo, sino despues el -1 no entra
			lcConsulta = "select " + tcCursorDetalle + ".*, iif( " + tcCursorCabecera + "." + lcCampoTipo + " = 2, -1, 01 ) as Signo " 
		else
			lnSigno = iif( toEntidad.lInvertirSigno, 01, -1 )
			lcConsulta = "select " + tcCursorDetalle + ".*, " + transform( lnSigno ) + " as Signo "
		endif
		lcConsulta = lcConsulta + ;
			"from " + tcCursorDetalle + " inner join " + tcCursorCabecera + ;
				" on " + tcCursorDetalle + "." + lcCampoCodigoDetalle + " = " + tcCursorCabecera + "." + lcCampoCodigoCabecera + ;
			" into cursor " + lcCursor

		&lcConsulta
		
		&& Se hace el inner join para asegurarse que los items sean los correctos de la cabecera...
		use in select( tcCursorDetalle )
		select * from &lcCursor into cursor &tcCursorDetalle 
		use in select( lcCursor )
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarCampoClavePrimariaAStockCombinacion( tcCursorCombinacion ) as Void
		local lcCursor as String, lcCampoPK As String, lnLen As Integer, lcTablaPrincipal as String
		lcCursor = sys( 2015 )

		lcCampoPk = This.oStockCombinacion.oAd.ObtenerCampoEntidad( This.oStockCombinacion.ObtenerAtributoClavePrimaria() )
		lcTablaPrincipal = This.oStockCombinacion.oAd.cTablaPrincipal
		select Insumo + Color + Talle as &lcCampoPk, * ;
			from &tcCursorCombinacion ;
			into cursor &lcCursor

		use in select( tcCursorCombinacion )
			select * from &lcCursor into cursor &tcCursorCombinacion ReadWrite
		use in select( lcCursor )

	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarCampoCantidadOriginalAStockCombinacion( tcCursorCombinacion as String ) as Void
		local	lcCampoCantidadOriginal As String, lcTablaPrincipal as String, lcClaveBusqueda as String, lcTag as String, ;
				lcCampoCantidad as String, lcCombinacion as String, lnCantidadOriginal as Integer, lcOrderBy as String, i as Integer,;
				lcAtributoEstadoStock as String , lcListaCampos, lcant, lcEstadoDeStock

		with This.oStockCombinacion
			lcEstadoDeStock  = this.catributoestadostock
			lcOrderBy = .oAtributosCC.Item[ 1 ]
			for i = 2 to .oAtributosCC.count
				lcOrderBy = lcOrderBy + ", " + .oAtributosCC.Item[ i ]
			endfor
			lcOrderBy = strtran( lcOrderBy, "_pk" )
			with .oAd
				lcClaveBusqueda = .cExpresionCCPorAtributos
				lcTag = .cTagClaveCandidata
				lcTablaPrincipal = .cTablaPrincipal
				lcCampoCantidad = .ObtenerCampoEntidad( lcEstadoDeStock   )
					lcCampoCantidadOriginal = .ObtenerCampoEntidad( lcEstadoDeStock +"Original" )
			endwith
		EndWith		
		
		lcAtributoEstadoStock = this.obtenerExpresionConCampoSegunEstadoStock( .t. )
		if empty( lcAtributoEstadoStock )
			select *, &lcEstadoDeStock  as &lcCampoCantidadOriginal ;
				from &tcCursorCombinacion ;
				order by &lcOrderBy ;
				into cursor &tcCursorCombinacion readwrite
		else
			select *, &lcEstadoDeStock  as &lcCampoCantidadOriginal , &lcAtributoEstadoStock  ;
				from &tcCursorCombinacion ;
				order by &lcOrderBy ;
				into cursor &tcCursorCombinacion readwrite
		Endif
		lcCombinacion = ""
		scan
			if lcCombinacion != &lcClaveBusqueda
				lcCombinacion = &lcClaveBusqueda
				if seek( &lcClaveBusqueda, lcTablaPrincipal, lcTag )
					lnCantidadOriginal = &lcTablaPrincipal..&lcCampoCantidad
					lcant = &lcTablaPrincipal..&lcCampoCantidad  + &lcEstadoDeStock 
				else
					lnCantidadOriginal = 0
					lcant = &lcTablaPrincipal..&lcCampoCantidad
				endif
				
			endif
			replace &lcCampoCantidadOriginal with lnCantidadOriginal in &tcCursorCombinacion

		endscan
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarCamposTransferencias( tcCursorInsumos as String ) as Void
		local lcCursor as String, lcCursorAtributosGenericos as String, lcListaCampos as String
		lcCursorAtributosGenericos = sys( 2015 )
		lcCursor = sys( 2015 )

		lcListaCampos = this.ObtenerExpresionConCamposDeAtributosGenericosParaSelect( "", 3 )
		goServicios.Datos.EjecutarSentencias( "Select " + lcListaCampos + " From " + This.oEntidad.oAd.cTablaPrincipal + " where 0=1", This.oEntidad.oAd.cTablaPrincipal, "", lcCursorAtributosGenericos, This.DataSessionId )
		append blank in ( lcCursorAtributosGenericos )

		select &tcCursorInsumos..*, &lcCursorAtributosGenericos..* ;
			from &tcCursorInsumos., &lcCursorAtributosGenericos. into cursor &lcCursor

		use in select( tcCursorInsumos )
		select * from &lcCursor into cursor &tcCursorInsumos readWrite
		use in select( lcCursor )
		use in select( lcCursorAtributosGenericos )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoDescripcionFW( toEntidad as Object ) as String
		local lcCampo as String
		
		lcCampo = ""
		if vartype( toEntidad.DescripcionFW ) != "U"
			lcCampo = "ce." + toEntidad.oAD.ObtenerCampoEntidad( "DescripcionFW" )
		else
			lcCampo = '"" as descFW'
		endif
		return lcCampo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadOriginal( toItem as Object ) as Number
		local lnCantidadOriginal as Integer
		lnCantidadOriginal = This.ObtenerStockInsumo( toItem.Insumo_Pk )
		return lnCantidadOriginal
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadOriginalDeCombinacion( toItem as Object ) as Number
		local lnCantidadOriginal as Integer
		lnCantidadOriginal = this.ObtenerDisponibilidadDeItem( "Cantidad", toItem )
		return lnCantidadOriginal
	endfunc 
	*-----------------------------------------------------------------------------------------
	function FormarMensajeComb( toItemStock as Object ) as string
		local lcClaveInexistente as String, lcItem as String, lnCantidadOriginal as Number
		lcClaveInexistente = "Combinación sin stock ó afectada: "
		for each lcItem in this.oCombinacion
			if !empty( toItemStock.&lcItem )
				lcClaveInexistente = lcClaveInexistente + proper( strtran( upper( lcItem ), "_PK" ) ) + ": " + alltrim( toItemStock.&lcItem ) + " - "
			else
				lcClaveInexistente = lcClaveInexistente + "Sin " + proper( strtran( upper( lcItem ), "_PK" ) ) + " - "
			endif
		endfor

		lnCantidadAcumulada = iif( type("toItemStock",1) = "C", 0,  this.obteneracumuladocombinacion( toItemStock )) + toItemStock.Cantidad

		lnCantidadOriginal = This.ObtenerCantidadOriginalDeCombinacion( toItemStock )
		lcClaveInexistente = substr( lcClaveInexistente, 1, len( lcClaveInexistente ) - 3 ) + ;
			" (Actual: " + this.TruncarDecimalesAMostrar( alltrim( goServicios.Librerias.ValorAString( lnCantidadOriginal ) ), 6 ) + ;
			", Total requerido: " + this.TruncarDecimalesAMostrar( alltrim( goServicios.Librerias.ValorAString( abs( lnCantidadAcumulada  ) ) ), 6 )  + ")."

		return lcClaveInexistente
	endfunc
	*-----------------------------------------------------------------------------------------
	function AntesDeVerificarDisponibilidadDeStockAlSetearCantidad() as Void
		&& Para sobreescribir
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerExpresionConCampoSegunEstadoStock( tlConInicializacion ) as String 
		local lcolCadena as zoocoleccion, lcRetorno as String 
		lcRetorno = ""		
		lcCadena = iif( tlConInicializacion, " 0000000.00 as ", "" )

		lcolCadena = this.ObtenerEstadosDeStock()
		
		with this.oEntidad
			for lni = 1 to lcolCadena.count
				if !empty( lcolCadena.item( lnI ) ) and upper(alltrim( lcolCadena.item( lnI ) )) != upper(alltrim( this.catributoestadostock))
					lcRetorno  = lcRetorno  + lcCadena +  .oAd.ObtenerCampoEntidad( lcolCadena.item( lnI ) ) + ", " + lcCadena +  .oAd.ObtenerCampoEntidad( lcolCadena.item( lnI ) + "Original" ) + ", "
				endif 
			endfor
		endwith

		return substr( lcRetorno,1, len( lcRetorno ) - 2 )
		
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerEstadosDeStock() as zoocoleccion  
		local lcolRetorno as zoocoleccion OF zoocoleccion.prg 
		lcolRetorno = this.oEntidadPadre.ObtenerEstadosDeStock( )
		return lcolRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerStockCombinacionesDeInsumo( tcCodigo As String, tcAtributoEstadoDeStock as String ) as String
		local lcRetorno as String, loFiltros as zoocoleccion OF zoocoleccion.prg
				
		this.oColaboradorConsultasDeStock.cTabla = this.oStockCombinacion.oAD.cTablaPrincipal
		
		this.oColaboradorConsultasDeStock.cCampoCantidad = this.oStockCombinacion.oAD.ObtenerCampoentidad( tcAtributoEstadoDeStock )

		loFiltros = this.oColaboradorConsultasDeStock.ObtenerFiltrosParaConsultaStockCombinacionesDeInsumo( tcCodigo, this.oEntidad )
		lcRetorno = this.oColaboradorConsultasDeStock.ObtenerCombinacionesConStockDeInsumo( loFiltros, this.ObtenerCamposAtributosCombinacion(), this.ObtenerCamposAtributosCombinacionAsNombreDeAtributo() )

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAtributosCombinacion() as String
		local lcRetorno as String, lcAtributo as String
		
		lcRetorno = ""

		for each lcItem in This.oCombinacion foxobject
		
			lcAtributo = strtran( lcItem, "_PK", "",1,1,1 )
			
			if !empty(lcRetorno)
				lcRetorno = lcRetorno + ", "
			endif
			lcRetorno = lcRetorno + this.oEntidad.oAd.ObtenerCampoEntidad( lcAtributo  ) 
		endfor

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAtributosCombinacionAsNombreDeAtributo() as String
		local lcRetorno as String, lcAtributo as String
		
		lcRetorno = ""

		for each lcItem in This.oCombinacion foxobject
		
			lcAtributo = strtran( lcItem, "_PK", "",1,1,1 )
			
			if !empty(lcRetorno)
				lcRetorno = lcRetorno + ", "
			endif
			lcRetorno = lcRetorno + this.oEntidad.oAd.ObtenerCampoEntidad( lcAtributo  ) + " as " + lcAtributo
		endfor

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadTotalDeItem( toItem as Object ) as Integer	
		lnCantItem = This.ObtenerCantidadItem( toItem )
		lnAcumuladoCombinacion	= This.obtenerAcumuladoCombinacion( toItem )
		Return ( lnCantItem + lnAcumuladoCombinacion ) * iif( This.lInvertirSigno, -1, 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FormarMensajeCombDisponible( toItemStock as Object ) as object
		local lcClaveInexistente as String, lcItem as String, lnCantidadOriginal as Number, lnCantidadDisponible as Number
		lcClaveInexistente = "Combinación sin stock ó afectada: "

			for each lcItem in this.oCombinacion
				if !empty( toItemStock.&lcItem )
					lcClaveInexistente = lcClaveInexistente + proper( strtran( upper( lcItem ), "_PK" ) ) + ": " + alltrim( toItemStock.&lcItem ) + " - "
				else
					lcClaveInexistente = lcClaveInexistente + "Sin " + proper( strtran( upper( lcItem ), "_PK" ) ) + " - "
				endif
			endfor
			lnCantidadOriginal = This.ObtenerCantidadOriginalDeCombinacion( toItemStock )
		lnCantidadDisponible = lnCantidadOriginal
		lnCantidadAcumuladaComb = this.obteneracumuladocombinacion( toItemStock ) + ( toItemStock.Cantidad * iif(this.lInvertirSigno, -1, 1))
			lcClaveInexistente = substr( lcClaveInexistente, 1, len( lcClaveInexistente ) - 3 ) + ;
				" (Disponible: " + this.TruncarDecimalesAMostrar( alltrim( goServicios.Librerias.ValorAString( lnCantidadDisponible ) ), 6 ) + ;
				", Total requerido: " + this.TruncarDecimalesAMostrar( alltrim( goServicios.Librerias.ValorAString( abs( lnCantidadAcumuladaComb ) ) ), 6 ) + ")."
			return lcClaveInexistente
			
	endfunc
	*-----------------------------------------------------------------------------------------
	function FormarMensajeCombSegunDisponible( toItemStock as Object ) as object
		local lcClaveInexistente as String
		lcClaveInexistente = "Combinación sin stock ó afectada: "
		lcClaveInexistente = this.FormarMensajeComb( toItemStock )
		return lcClaveInexistente
			
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function EsImportacion() as Boolean
		local lRetorno as Boolean
		
		lRetorno = .f.
		if pemstatus(this, 'oEntidadPadre', 5) and vartype("this.oEntidadPadre") == 'O' 
			lRetorno = this.oEntidadPadre.VerificarContexto( "I" )
		endif
		
		return lRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarEntidad() as Boolean
		local llRetorno as Boolean, loError as Exception, loEx as Exception
		This.LimpiarInformacion()
		llRetorno = .T.
		try 
			This.oEntidad.Buscar()
			llRetorno = This.oEntidad.Cargar()
		catch to loError
			if loError.ErrorNo = 2071 && Error generado por el Usuario
				This.CargarInformacion( loError.UserValue.ObtenerInformacion() )
				llRetorno = .F.
			else
				goServicios.Errores.LevantarExcepcion( loError )
			Endif
		Endtry
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoEstadoStock() as String
		local lcRetorno as String
		if this.EsComprobanteConEntregaPosterior( this.oEntidadPadre )
			lcRetorno = this.oEntidadPadre.oCompEnBaseA.oEntidadAfectada.ObtenerEstadoDeStockDeComprobante( this.oEntidadPadre.oCompEnBaseA.oEntidadAfectada.cComprobante, .t. )
		else
			lcRetorno = This.oEntidadPadre.ObtenerEstadoDeStockDeComprobanteAfectado()
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsComprobanteConEntregaPosterior( toEntidadPadre as object ) as Boolean
		local llRetorno as Boolean
		llRetorno = pemstatus(toEntidadPadre.oCompEnBaseA.oEntidadAfectada, "lEsComprobanteConEntregaPosterior", 5) and  toEntidadPadre.oCompEnBaseA.oEntidadAfectada.lEsComprobanteConEntregaPosterior
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerInvertirSigno( tcEstadoStock as String ) as Boolean
		local llRetorno as Boolean
		if alltrim(upper(tcEstadoStock)) == ESTADOENTREGAPENDIENTE
			llRetorno = .f.
		else
			llRetorno = !This.oEntidadPadre.ObtenerInvertiSignoDeComprobanteAfectado()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSigno( tlValorActual as Boolean ) as Boolean
		local llRetorno as Boolean
*!*			if this.lNuevo or this.lEdicion
			llRetorno = tlValorActual
*!*			else
*!*				llRetorno = ! tlValorActual
*!*			endif

		return llRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EsNotaDeCreditoEnBaseAComprobanteOnline() as Boolean
		local llRetorno as Boolean
		llRetorno = this.oEntidadPadre.EsNotaDeCredito() and this.oEntidadPadre.BasadoEnComprobanteOnline
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadItemAlGrabar( tlEstaValidandoMinimoDeResposicion as Boolean ) as Float
		local llRetorno as float
		llRetorno = this.ObtenerCantidadItem( this.oItem, tlEstaValidandoMinimoDeResposicion )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDisponibilidadAlGrabar( tcAtributo as String, toItem as Object ) as integer
		local lnRetorno as Integer
		lnRetorno = this.ObtenerDisponibilidad( tcAtributo, toItem )
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarColeccionesStock() as Void
		this.oColStock.Remove(-1)
		this.oColStockInicial.Remove(-1)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarArticuloPorInsumo() as Void
		local loItem as Object
		for each loItem in This.oColStock foxobject
			loItem.AddProperty( 'ArticuloTemporal_pk', loItem.Insumo_Pk )
			loItem.Insumo_Pk = loItem.Insumo_pk
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarInsumoPorArticulo() as Void
		local loItem as Object
		for each loItem in This.oColStock foxobject
			loItem.Insumo_Pk = loItem.ArticuloTemporal_pk
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsMovimientoStockAInventario() as Boolean
		return upper( alltrim( This.oEntidadPadre.cNombre ) ) == "MOVIMIENTOSTOCKAINVENT"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsMovimientoStockAProduccion() as Boolean
		return upper( alltrim( This.oEntidadPadre.cNombre ) ) == "MOVIMIENTOSTOCKAPRODUCC"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsMovimientoStockDesdeProduccion() as Boolean
		return upper( alltrim( This.oEntidadPadre.cNombre ) ) == "MOVIMIENTOSTOCKDESDEPRODUCC"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TruncarDecimalesAMostrar( tcStringNumero as String, tnCantDecimales as Integer ) as String
		return substr( tcStringNumero, 1, at( ".", tcStringNumero ) + tnCantDecimales )
	endfunc 

enddefine
