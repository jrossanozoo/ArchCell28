define class KontrolerConDetalle As KontrolerEdicion Of KontrolerEdicion.prg 

	#if .f.
		local this as KontrolerConDetalle of KontrolerConDetalle.prg
	#endif

	oEntidadACopiar = null
	oFormularioSeleccionParaInsertar = null
	lProcesarPrePantalla = .f.
	oComponentePrePantalla = null
	lHuboCargaAutomatica = .f.
	cDetalleCargaAutomaticaActiva = ""
	lCargaAutomaticaExitosa = .f.
	lTrasladaVendedorConInsertarDesde = .f.

	c_ModificacionPrecios = ""
	
	oArchivos = null
	oAdaptadorTxtADetalleLecturaCB = null
	cRutaArchivo = "" 
	lMostroCartel = .f.
	oInfoLimiteDiseno = null
	lDebePosicionarseEnArticulo = .f.
	lForzarLostFocusCampoLecturaCB = .f.
	*lHuboDistribucionDeCantidades = .f.
	lOrdenarDetalleAlInsertar = .f.
	
	*-----------------------------------------------------------------------------------------
	function Ejecutar( tcAccion as String ) as Boolean
		dodefault( tcAccion )
		this.lMostroCartel = .f.
		if upper( tcAccion ) == "ESCAPAR"
			this.OcultarCampoLecturaCB()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function oArchivos_Access() as Object
		if !this.ldestroy and ( !vartype( this.oArchivos ) = 'O' or isnull( this.oArchivos ) )
			this.oArchivos = _screen.zoo.crearobjeto( 'ManejoArchivos' )
		endif
		return this.oArchivos
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function oAdaptadorTxtADetalleLecturaCB_Access() as Object
		if !this.ldestroy and ( !vartype( this.oAdaptadorTxtADetalleLecturaCB ) = 'O' or isnull( this.oAdaptadorTxtADetalleLecturaCB ) )
			this.oAdaptadorTxtADetalleLecturaCB = _screen.zoo.CrearObjetoPorProducto( 'AdaptadorTxtADetalleLecturaCB' )
		endif
		return this.oAdaptadorTxtADetalleLecturaCB
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function BindearEventosPrePantalla() as Void
		local lnI as Integer, lnJ as Integer, loDetalle as Object, loControlDetalle as Object, loControl as Object, loDetallesPP as zoocoleccion OF zoocoleccion.prg 
		local lnColumna as Integer, lcControl as String
		loDetallesPP = this.oEntidad.ObtenerNombreDetallesConPrePantalla()
		for lnJ = 1 to loDetallesPP.Count 
			loControlDetalle = this.ObtenerControl( loDetallesPP.Item[lnJ] )
			this.BindearEvento( loControlDetalle, "LostFocus", this, "AjustarBanderaLuegoDeCargaAutomatica" )
			this.BindearEvento( loControlDetalle, "LostFocus", this, "EstablecerFocoDetalleDespuesDeCargaAutomaticaEnArticulo" )
			for lnI = 1 to ( loControlDetalle.nCantidadItemsVisibles ) && - 1
				loControl = loControlDetalle.ObtenerCampoPorAtributo( lnI, "Articulo" )
  				this.BindearEvento( loControl, "LostFocus", this, "EstablecerFocoDetalleDespuesDeCargaAutomatica" )
			endfor
			
			for lnColumna = 2 to loControlDetalle.nCantidadColumnas
				lcControl = "loControlDetalle.campo_"+transform(lnColumna)+"_"+transform( loControlDetalle.nCantidadItemsVisibles)
				loControl = &lcControl
				if !goServicios.SaltosDeCampoyValoresSugeridos.DebeSaltarElCampo( this.oEntidad.cNombre, loControlDetalle.cAtributo, iif(!empty(loControl.cAtributoPadre), loControl.cAtributoPadre, loControl.cAtributo) )
		 			this.BindearEvento( loControl, "Gotfocus", this, "EstablecerFocoDetalleDespuesDeCargaAutomatica" )
					exit
				endif
			endfor 
			loDetalle = "this.oEntidad." + loDetallesPP.Item[lnJ]
			this.BindearEvento( &loDetalle, "ProcesarPorPrepantalla", this, "ProcesarPrePantallaDesdeComponente" )
			this.BindearEvento( &loDetalle, "ReposicionarAlVolverDePrePantalla", this, "CambiarFilaActivaAlVolverDePrePantalla" )
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ProcesarPrePantallaDesdeComponente( tcNombreDetalle as String, tcValor as String ) as Void
		local lcAtributo as String, loDetalle as Object, lcNombreAtributo as String

		loDetalle = this.oEntidad.&tcNombreDetalle 
		lcNombreAtributo = loDetalle.ObtenerAtributoPrePantalla()

		lcAtributo = "this." + tcNombreDetalle + "_" + lcNombreAtributo 
		&lcAtributo = tcValor 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarPrePantalla( tcNombreDetalle as String, tcCodigo as String ) as Void
		local loFactoriaPrePantalla as Object, llRetorno as Boolean, loDetalle as detalle OF detalle.prg, lnNroItem as Integer, loDatosDeArticulo as Object, ;
			loDatosDeArticuloComprometido as Object, loDatosCurva as Object, loDatosPaleta as Object, llMostrarColumnasDisponible as Boolean, ;
			lcMascaraCantidades as String, loError as Exception, loDatosDeArticuloEntregaPendiente as Object, llMostrarColumnasDisponibleYPendiente as Boolean, ;
			llIncorporarStockPedidosDeCompra as Boolean, llEsKit as Boolean, loDatosDeArticuloSeniado as Object, llMostrarColumnasDisponibleYSeniado as Boolean, ;
			llCancelaPrePantalla as Boolean
		
		loDetalle = this.oEntidad.&tcNombreDetalle 
		lnNroItem = loDetalle.oItem.NroItem
		llCancelaPrePantalla = .f.
		llEsKit = .F.
		
		if this.ValidarSiDebeCancelarPrePantalla()
			llCancelaPrePantalla = .t.
		endif
		
		if pemstatus( loDetalle.oItem, "Comportamiento", 5)
			llEsKit = loDetalle.oItem.Comportamiento == 4
		endif

		if !llCancelaPrePantalla and !llEskit
			loDatosDeArticulo = this.oComponentePrePantalla.ObtenerDatosDeArticulo( loDetalle, "" )
			
			loDatosCurva = this.oComponentePrePantalla.ObtenerDatosColumna( loDetalle, loDatosDeArticulo )

			loDatosPaleta = this.oComponentePrePantalla.ObtenerDatosFila( loDetalle, loDatosDeArticulo )

			loDatosDeArticuloComprometido = this.oComponentePrePantalla.ObtenerDatosDeArticulo( loDetalle, "COMPROMETIDO" )
			loDatosDeArticuloEntregaPendiente = this.oComponentePrePantalla.ObtenerDatosDeArticulo( loDetalle, "ENTREGAPEN" )
			loDatosDeArticuloPedidoCompra = this.oComponentePrePantalla.ObtenerDatosDeArticulo( loDetalle, "PEDIDODECOMPRA" )
			loDatosDeArticuloPreparado = this.oComponentePrePantalla.ObtenerDatosDeArticulo( loDetalle, "PREPARACIONDEMERCADERIA" )
			llMostrarColumnasDisponible = this.MostrarColumnaStockDisponibleYComprometido()
			llMostrarColumnasDisponibleYPendiente = this.MostrarColumnaStockDisponibleYEntregaPendiente()
			llIncorporarStockPedidosDeCompra = this.IncorporaElStockDePedidosDeCompraAlDisponible()
			loDatosDeArticuloSeniado = this.oComponentePrePantalla.ObtenerDatosDeArticulo( loDetalle, "SENIADO" )
			llMostrarColumnasDisponibleYSeniado = this.MostrarColumnaStockDisponibleYSeniado()
		
			if type( "This.oEntidad." + tcNombreDetalle ) = "O"
				if This.ExisteControl( tcNombreDetalle )
					loGrilla = this.obtenerControl( tcNombreDetalle )
					loControl = loGrilla.ObtenerCampoPorAtributo( 1, "Cantidad" )
					lcMascaraCantidades = loControl.cMascara &&loControl.InputMask
					if this.RestringirIngresoDeDecimalesEnCantidad()
						lcMascaraCantidades = getwordnum( lcMascaraCantidades, 1, "." )
					endif
					lcMascaraCantidades	= strtran( lcMascaraCantidades,",","" )
				EndIf
			endif

			this.lCargaAutomaticaExitosa = .f.

			loRespuesta = this.oComponentePrePantalla.Ejecutar( loDatosDeArticulo, loDatosCurva, loDatosPaleta, loDetalle, loDatosDeArticuloComprometido, llMostrarColumnasDisponible, lcMascaraCantidades, loDatosDeArticuloEntregaPendiente, llMostrarColumnasDisponibleYPendiente, loDatosDeArticuloPedidoCompra, llIncorporarStockPedidosDeCompra, loDatosDeArticuloPreparado, loDatosDeArticuloSeniado, llMostrarColumnasDisponibleYSeniado )
			
			if loRespuesta.Count>0

				try
					this.lHuboCargaAutomatica = .t.
					this.cDetalleCargaAutomaticaActiva = tcNombreDetalle

					this.oComponentePrePantalla.ProcesarRespuestaPrePantalla( loDetalle, loRespuesta )
					this.InformarCambiosAControlGrilla( tcNombreDetalle, loRespuesta, loDetalle )
					this.EjecutarProcesosDespuesDePrePantalla( this.oComponentePrePantalla.oItemsCargados, tcNombreDetalle )
					
					llRetorno = .t.
				catch to loError
					this.lHuboCargaAutomatica = .f.
					goservicios.Errores.levantarexcepcion( loError )
				endtry				
			endif
		endif
		
		return llRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarSiDebeCancelarPrePantalla() as Boolean
		local llRetorno as Boolean
		llRetorno = pemstatus( this.oEntidad, "oCompEnBaseA", 5 ) ;
			and ( !isnull( this.oEntidad.oCompEnBaseA ) ) ;
			and this.oEntidad.oCompEnBaseA.nOperatoria > 1 

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RefrescarGrillaConCargaAutomatica( tcNombreDetalle as String ) as Void
		local loControl as Object
		
		if type( "This.oEntidad." + tcNombreDetalle ) = "O"
			if This.ExisteControl( tcNombreDetalle )
				loControl = this.obtenerControl( tcNombreDetalle  )
				loControl.RefrescarGrilla()
				loControl.AjustarAnchoPosPrepantalla()
			EndIf
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function InformarCambiosAControlGrillaDeParticipantes( tcNombreDetalle as String, toRespuesta as Object, toDetalle as Object ) as Void
		local loControl as Object
		loControl = this.ObtenerControl( tcNombreDetalle )
		if pemstatus( loControl, "CampoLecturaCB", 5 ) and !isnull( loControl.CampoLecturaCB )
			loControl.CampoLecturaCB.lCargaKits = .t.
		endif
		this.InformarCambiosAControlGrilla( tcNombreDetalle, toRespuesta, toDetalle )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InformarCambiosAControlGrilla( tcNombreDetalle as String, toRespuesta as Object, toDetalle as Object ) as Void
		local loControl as Object
		loControl = this.ObtenerControl( tcNombreDetalle )
		if pemstatus( loControl, "CampoLecturaCB", 5 ) and !isnull( loControl.CampoLecturaCB )
			loControl.CampoLecturaCB.nCargadosPorPrepantalla = toRespuesta.Count
			loControl.CampoLecturaCB.nTotalDetalle = toDetalle.Count
		endif
		this.InformarCambiosADetalleEntidad( toRespuesta, toDetalle )
		loControl.AjustarAnchoPosPrepantalla()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InformarCambiosADetalleEntidad( toRespuesta as Object, toDetalle as Object ) as Void
		if pemstatus( toDetalle, "nCargadosPorPrePantalla", 5 ) and pemstatus( toDetalle, "nTotalDetallePrePantalla", 5 )
			toDetalle.nCargadosPorPrePantalla = toRespuesta.Count
			toDetalle.nTotalDetallePrePantalla = toDetalle.Count
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function MostrarColumnaStockDisponibleYComprometido() as boolean
		local llRetorno as Boolean
		
		llRetorno = goParametros.ColorYTalle.GestionDeVentas.HabilitaColumnaStockDisponibleYComprometido &&and this.oEntidad.lItemControlaDisponibilidad
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function MostrarColumnaStockDisponibleYEntregaPendiente() as boolean
		local llRetorno as Boolean
		
		llRetorno = goParametros.ColorYTalle.GestionDeVentas.HabilitaColumnaStockDisponibleYPendiente
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function MostrarColumnaStockDisponibleYSeniado() as boolean
		local llRetorno as Boolean
		
		llRetorno = goParametros.ColorYTalle.GestionDeVentas.HabilitaStockSeniadoEnPantallaDePreCarga
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function IncorporaElStockDePedidosDeCompraAlDisponible() as boolean
		local llRetorno as Boolean

		llRetorno =	goParametros.ColorYTalle.GestionDeVentas.IncorporaElStockDePedidosDeCompraAlDisponible
					
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CambiarFilaActivaAlVolverDePrePantalla( tcNombreDetalle as String ) as Void
		local lcAtributo as String, loControl as Object, loControlArticulo as Object, loDetalle as Object, lnI as Integer, ;
				lnCantidadDeItemVisibles as Integer, lnUltimoGuardado as Integer, lnFilaActiva as Integer, lnPrimerRegistro as Integer

			loControl = this.ObtenerControl( tcNombreDetalle )
			lnCantidadDeItemVisibles = loControl.nCantidadItemsVisibles
			loDetalle = This.oEntidad.&tcNombreDetalle 

			lnUltimoGuardado = 1
			for lnI = 1 to loDetalle.Count
				if loDetalle.ValidarExistenciaCamposFijosItemPlano( lnI )
					lnUltimoGuardado = lnI + 1
				endif
			endfor
			if lnUltimoGuardado > lnCantidadDeItemVisibles
				lnFilaActiva = lnCantidadDeItemVisibles
				lnPrimerRegistro = lnUltimoGuardado - lnCantidadDeItemVisibles + 1
			else
				lnFilaActiva = lnUltimoGuardado
				lnPrimerRegistro = 1
			endif

			loControl.nRegistroInicioPantalla = lnPrimerRegistro
			loControlArticulo = loControl.ObtenerCampoPorAtributo( lnFilaActiva, loControl.campo_1_1.cClaveForanea )
			if pemstatus(loControl, "CampoLecturaCB", 5) and loControl.CampoLecturaCB.enabled
				loControl.CampoLecturaCB.SetearControlOrigen( loControlArticulo )
				loControl.CampoLecturaCB.nFila = loControlArticulo.nFila
				loControl.CampoLecturaCB.top = loControlArticulo.top
				loControl.CampoLecturaCB.nCargadosPorPrePantalla = 0
				loControl.CampoLecturaCB.nTotalDetalle = 0
				loControl.CampoLecturaCB.Value = ""
				loControl.CampoLecturaCB.visible = .t.
			endif
			
			if pemstatus( loDetalle, "nCargadosPorPrePantalla", 5 ) and pemstatus( loDetalle, "nTotalDetallePrePantalla", 5 )
				loDetalle.nCargadosPorPrePantalla = 0
				loDetalle.nTotalDetallePrePantalla = 0
			endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstablecerFocoDetalleDespuesDeCargaAutomatica( tlVieneDesdeCampoLecturaCB as Boolean ) as Void
		local loControl as Object, lnFilaActiva as Integer, lnPrimerRegistro as Integer, ;
			lnCantidadDeItemVisibles as Integer, loControlArticulo as Object, lcNombreDetalle as String, ;
			loControlArt as Object, lcCampoArticulo as String, lcCampoAnterior as String, ;
			lcValorUltimoArticuloVisible as String, lncargadosporprepantalla as Integer

		if This.lHuboCargaAutomatica
			
			lcNombreDetalle = this.cDetalleCargaAutomaticaActiva
			loControl = this.ObtenerControl( lcNombreDetalle )
			llCodigoDeBarrasActivado = pemstatus(loControl, "CampoLecturaCB", 5) and loControl.CampoLecturaCB.enabled
			lnCantidadDeItemVisibles = loControl.nCantidadItemsVisibles
			lcValorUltimoArticuloVisible = "loControl.campo_1_" + transform( lnCantidadDeItemVisibles ) + ".value"
			loDetalle = This.oEntidad.&lcNombreDetalle
			lncargadosporprepantalla = iif( pemstatus( loDetalle, "ncargadosporprepantalla", 5 ), loDetalle.ncargadosporprepantalla, 0 )
			

			lnUltimoGuardado = 1
			for lnI = 1 to loDetalle.Count
				if loDetalle.ValidarExistenciaCamposFijosItemPlano( lnI )
					lnUltimoGuardado = lnI + 1
				endif
			endfor

			if lnUltimoGuardado > lnCantidadDeItemVisibles
				if llCodigoDeBarrasActivado or empty( &lcValorUltimoArticuloVisible )
					lnFilaActiva = lnCantidadDeItemVisibles
					lnPrimerRegistro = lnUltimoGuardado - lnCantidadDeItemVisibles + 1
				else
					lnFilaActiva = lnCantidadDeItemVisibles - iif( lncargadosporprepantalla >= 2, 0, 1 )
					lnPrimerRegistro = lnUltimoGuardado - lnCantidadDeItemVisibles + 2
				endif
			else
				lnFilaActiva = lnUltimoGuardado
				lnPrimerRegistro = 1
			endif
			
			if !llCodigoDeBarrasActivado
				if iif(pemstatus(this.oEntidad, "lCargoPromocion", 5 ), !this.oEntidad.lCargoPromocion, .t.) or lnUltimoGuardado < lnCantidadDeItemVisibles
					this.lDebePosicionarseEnArticulo = ((loControl.nFilaActiva - loControl.nRegistroInicioPantalla + 1) = lnCantidadDeItemVisibles ) or (loControl.nFilaActiva = lnCantidadDeItemVisibles )
					loControl.nRegistroInicioPantalla = lnPrimerRegistro
					loControlArticulo = loControl.ObtenerCampoPorAtributo( lnFilaActiva, loControl.campo_1_1.cClaveForanea )
					if lnFilaActiva = lnCantidadDeItemVisibles
						loControlArt = loControl.ObtenerCampoPorAtributo( lnCantidadDeItemVisibles, "Articulo" )
		  				this.DesBindearEvento( loControlArt, "LostFocus", this, "EstablecerFocoDetalleDespuesDeCargaAutomatica" )
					endif 
					loControlArticulo.GotFocus()
					this.RefrescarGrillaConCargaAutomatica( lcNombreDetalle )
				
					if lnFilaActiva = lnCantidadDeItemVisibles
						this.BindearEvento( loControlArt, "LostFocus", this, "EstablecerFocoDetalleDespuesDeCargaAutomatica" )
					endif					
				endif
			else
				this.lDebePosicionarseEnArticulo = .f. &&((loControl.nFilaActiva - loControl.nRegistroInicioPantalla + 1) = lnCantidadDeItemVisibles ) or (lnFilaActiva = lnCantidadDeItemVisibles )
				loControlArticulo = loControl.ObtenerCampoPorAtributo( lnFilaActiva, loControl.campo_1_1.cClaveForanea )				
				if (!tlVieneDesdeCampoLecturaCB and this.lForzarLostFocusCampoLecturaCB) or iif( pemstatus(this.oEntidad, "lCargoPromocion", 5 ), this.oEntidad.lCargoPromocion, .f.)
					thisform.nKeyCode = iif( pemstatus(this.oEntidad, "lCargoPromocion", 5 ) and this.oEntidad.lCargoPromocion, 0, 24)
					loControl.CampoLecturaCB.valid()
					loControl.CampoLecturaCB.lostFocus()
					loControl.CampoLecturaCB.hacerVisible( loControlArticulo )
					loControl.CampoLecturaCB.visible = .t.
					this.SetearPropiedadesParaPosicionamientoEnGrilla(.t.)
				else
					lcCampoArticulo = "Campo_1_" + transform( lnCantidadDeItemVisibles ) 
					if loControl.oCAMPOANTERIOR.Name != lcCampoArticulo
						lcCampoAnterior = loControl.CampoLecturaCB.ObtenerNombreCampoAnterior()
						loControl.CampoLecturaCB.hacerVisible( loControlArticulo )
						if (lcCampoArticulo != lcCampoAnterior and lnPrimerRegistro != 1)
							thisform.nKeyCode = 24
							loControl.MoverAbajo(1)
							loControl.CampoLecturaCB.valid()  
						endif
					endif
				endif
			endif
			
			This.lHuboCargaAutomatica = .F.
		Endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EstablecerFocoDetalleDespuesDeCargaAutomaticaEnArticulo() as Void
		local loControl as Object, lnFilaActiva as Integer, lnPrimerRegistro as Integer, ;
			lnCantidadDeItemVisibles as Integer, loControlArticulo as Object, lcNombreDetalle as String, ;
			loControlArt as Object 

		if this.lDebePosicionarseEnArticulo
			lcNombreDetalle = this.cDetalleCargaAutomaticaActiva
			loControl = this.ObtenerControl( lcNombreDetalle )
			lnCantidadDeItemVisibles = loControl.nCantidadItemsVisibles
			loDetalle = This.oEntidad.&lcNombreDetalle
			lnUltimoGuardado = 1
			for lnI = 1 to loDetalle.Count
				if loDetalle.ValidarExistenciaCamposFijosItemPlano( lnI )
					lnUltimoGuardado = lnI + 1
				endif
			endfor
			
			if lnUltimoGuardado > lnCantidadDeItemVisibles
				lnFilaActiva = lnCantidadDeItemVisibles
				lnPrimerRegistro = lnUltimoGuardado - lnCantidadDeItemVisibles + 1
			else
				lnFilaActiva = lnUltimoGuardado
				lnPrimerRegistro = 1
			endif

			loControl.nRegistroInicioPantalla = lnPrimerRegistro
			loControlArticulo = loControl.ObtenerCampoPorAtributo( lnFilaActiva, loControl.campo_1_1.cClaveForanea )
			loControlArticulo.SetFocus()
			if pemstatus(loControl, "CampoLecturaCB", 5) and loControl.CampoLecturaCB.enabled
				loControl.CampoLecturaCB.hacerVisible( loControlArticulo )
			endif
		endif
		this.lDebePosicionarseEnArticulo = .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RefrescarGrillasArticulos() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReposicionarItem( toDetalle as detalle OF detalle.prg, tnPosicionOriginal as Integer, tnPosicionPrimerCargaDePrePantalla ) as Void

		if tnPosicionOriginal = 0
			toDetalle.Cargaritem( tnPosicionPrimerCargaDePrePantalla ) 
		else
			toDetalle.Cargaritem( tnPosicionOriginal ) 
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarProcesosDespuesDePrePantalla( toItemsCargados as ZooColeccion OF ZooColeccion.prg, tcNombreDetalle as String ) as Void
		local loDetalle as Object, lnIndice as Integer
		
		loDetalle = this.oEntidad.&tcNombreDetalle 
		
		for lnIndice = 1 to loDetalle.Count
			if !empty( loDetalle.Item[ lnIndice ].Articulo_pk )
				if lnIndice = loDetalle.Count
					loDetalle.CargarItem( lnIndice )
				Endif
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oComponentePrePantalla_Access() as Object
		if !this.ldestroy and ( !vartype( this.oComponentePrePantalla ) = 'O' or isnull( this.oComponentePrePantalla ) )
			this.oComponentePrePantalla = _Screen.zoo.CrearObjetoPorProducto( "ComponentePrePantalla" )
		endif
		return this.oComponentePrePantalla
	endfunc	

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		dodefault()
		if vartype( This.oEntidad ) = "O"
			if pemstatus( This.oEntidad, "EventoAdvertirLimitePorDiseno",5 )
				this.enlazar( "oEntidad.EventoAdvertirLimitePorDiseno", "AdvertirLimiteAlcanzadoSegunDisenoImpresion" )
				this.enlazar( "oEntidad.EventoCancelarCargaLimitePorDiseno","CancelarCargaXLimiteAlcanzadoSegunDisenoImpresion")
			endif
			This.Enlazar( "oEntidad.EventoVerificarLimitesEnDisenoImpresion", "VerificarLimitesEnDisenoImpresion" )

			if This.oEntidad.TieneDetallesConPrePantalla()
				this.BindearEventosPrePantalla()
			endif
			
			if vartype( goParametros.Felino ) = "O"
				this.lTrasladaVendedorConInsertarDesde = goParametros.Felino.GestionDeVentas.TrasladarElVendedorEnInsertarDesde
			endif
			
			if pemstatus( This.oEntidad, "EventoRefrescarDetalle", 5 )
				bindevent( this.oEntidad, 'EventoRefrescarDetalle', this, 'RefrescarDetalle', 1 )
			endif
			
			if pemstatus(This.oEntidad, "lControlaSecuencialEnCodBarAlt", 5 ) and This.oEntidad.lControlaSecuencialEnCodBarAlt
				this.BindearEventosCodBarAlternativo()
			endif	
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarItem( tcTipoDetalle as String ) as boolean
		local llRetorno as Boolean
		
		llRetorno = .f.
		if this.ValidarCantidadItems( tcTipoDetalle )
			thisform.oEntidad.&tcTipoDetalle..Actualizar()
			llRetorno = .t.
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ModificarItem( tcTipoDetalle as String ) as Void
	
		thisform.oEntidad.&tcTipoDetalle..Actualizar()

	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCantidadItems( tcTipoDetalle as String ) as Boolean
		return thisform.oEntidad.&tcTipoDetalle..ValidarCantidadItems()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VaciarDetalle( tcTipoDetalle as String ) as Void
	
		thisform.oEntidad.&tcTipoDetalle..Limpiar()

	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarDetalle( tcTipoDetalle as String, tnFilaActiva as integer ) as Boolean
		local loDetalle as Detalle of Detalle.prg, llRetorno as boolean, ;
			llNoPuede as boolean, loError as Exception, loControl as Object, lnCantidadDeItemVisibles as Integer
			
		llRetorno = .T.
		loDetalle = thisform.oEntidad.&tcTipoDetalle
		llNoPuede = tnFilaActiva > loDetalle.nCantidadItems + loDetalle.nCantidadItemsAdicionales && La cantidad de lineas supera a la permitida.
		if llNoPuede
			llRetorno = .f.
		else
			try
				if loDetalle.lHabilitado and !This.lHuboCargaAutomatica
					loControl = this.ObtenerControl( tcTipoDetalle )
					lnCantidadDeItemVisibles = loControl.nCantidadItemsVisibles
					if this.NoDebeValidarActualizarDetalle() and (tnFilaActiva != (lnCantidadDeItemVisibles -1))
						&& se agrego para el caso en que se agregan los participantes de un kit para que el foco quede donde corresponda
						&& y no por lo que hace a continuacion (zooGrillaExtensible -> CambiarDefila ) si este método devuelve .t.
						llRetorno = .f.
						
					endif
					loDetalle.Actualizar()
					if this.NoDebeValidarActualizarDetallePorOperatoriaEnBaseA()
						this.LimpiarSeDistribuyeronCantidades()
						llRetorno = .f.
					endif
				endif
			catch to loError
				llRetorno = .f.

				goServicios.Mensajes.Advertir( loError )
				
				if thisform.hwnd # _Screen.ActiveForm.hwnd
					throw loError
				endif
			endtry
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroItemActivo( tcTipoDetalle as String ) as integer
		return thisform.oEntidad.&tcTipoDetalle..oItem.NroItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearItemActivo( tcTipoDetalle as String, tnFilaNueva as integer ) as void
		local loDetalle as detalle of detalle.prg, i as integer, lnItemActivo as integer, loItem as object, loItemAnterior as object
		try
			loDetalle = thisform.oEntidad.&tcTipoDetalle
			if loDetalle.count + 1 <= tnFilaNueva - 1
				for i = loDetalle.count + 1 to tnFilaNueva- 1
					loItem = loDetalle.CrearItemAuxiliar()
					loItem.NroItem = loDetalle.Count + 1
					loDetalle.Add( loItem )
				endfor
			endif

			lnItemActivo = this.ObtenerNumeroItemActivo( tcTipoDetalle )
			loDetalle.oitem.oItemAnterior = this.ObtenerItemAnterior( tcTipoDetalle, tnFilaNueva - 1 )
			if tnFilaNueva > 0
				if loDetalle.count < tnFilaNueva 
					loDetalle.LimpiarItem()
				else
					if lnItemActivo # tnFilaNueva
						loDetalle.CargarItem( tnFilaNueva )
					else
						if !loDetalle.oItem.ValidarExistenciaCamposFijos()
							loDetalle.oItem.SetearValoresSugeridos()
						else
							loDetalle.CargarItem( tnFilaNueva )
						endif
					endif
				endif
			endif
		catch to loError
			goServicios.Mensajes.Advertir( loError )	
		endtry					
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaCamposFijos( tcTipoDetalle as String, tnNuevaFila as integer ) as boolean
		local llRetorno as boolean

		loDetalle = thisform.oEntidad.&tcTipoDetalle
		
		if vartype( tnNuevaFila ) = "N" and tnNuevaFila > 0
			llRetorno =  loDetalle.ValidarExistenciaCamposFijosItemPlano( tnNuevaFila )
		else
			llRetorno =  loDetalle.oItem.ValidarExistenciaCamposFijos()
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CantidadDeItems( tcTipoDetalle as String ) as integer

		return thisform.oEntidad.&tcTipoDetalle..count
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarDatosItemActivo( tcDetalle as String, tcAtributo as String ) as boolean

		return .T.

	Endfunc

	*-----------------------------------------------------------------------------------------
	function TieneCamposSumarizables( tcNombreDetalle ) as Boolean 
		local llRetorno as Boolean, loDetalle as Object
		
		assert empty( tcNombreDetalle ) = .F. message "NO se envio el nombre del Detalle"
			
		llRetorno = evaluate( "this.l" + tcNombreDetalle + "TieneSumarizables" )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValorAtributoPlano( tcDetalle as string, toControl as Object, tnRegistroIncioPantalla as integer ) as variant
		local lcAtributo as String, lxRetorno as variant
		lxRetorno = null
		if empty( toControl.cClaveForanea )
			lcAtributo =  alltrim( toControl.cAtributo )
		else
			lcAtributo =  alltrim( toControl.cAtributoPadre ) + "_PK" 
		endif
		lxRetorno = This.ObtenerValorAtributoPlanoSegunAtributoFila( tcDetalle, toControl.nFila, lcAtributo, tnRegistroIncioPantalla )
		return lxRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValorAtributoPlanoSegunAtributoFila( tcDetalle as string, tnFila as Integer, tcAtributo as string, tnRegistroIncioPantalla as integer ) as variant
		local lxRetorno as variant, lcReferenciaRetorno as string
		lxRetorno = null
		if this.CantidadDeItems( tcDetalle ) >= tnFila + tnRegistroIncioPantalla - 1
			lcReferenciaRetorno = "thisform.oEntidad." + tcDetalle + ".item[ tnFila + tnRegistroIncioPantalla - 1 ]." + tcAtributo
			lxRetorno = &lcReferenciaRetorno
		endif
		return lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarFormateosDeLaFilaActiva( tcDetalle as string, toControl as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarFormateosDeLaFilaPlana( tcDetalle as string, toControl as Object, tnRegistroIncioPantalla as integer ) as void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarCondicionDeFocoPrimeraColumnaAccesible( tcDetalle as String, tnFila as Integer ) as Boolean
		return .T.	
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValorAtributoItemActivo( tcDetalle as string, toControl as Object ) as variant
		local lxRetorno as variant, lcAtributo as String

		if empty( toControl.cClaveForanea )
			lcAtributo = alltrim( .cAtributo )
		else
			if pemstatus( toControl, "lClavePrimaria" , 5 ) and toControl.lClavePrimaria
				lcAtributo = alltrim( .cAtributoPadre ) + "_PK"
			else
				lcAtributo = alltrim( toControl.cAtributoPadre ) + "." + alltrim( toControl.cAtributo )
			endif
		endif
		
		lxRetorno = this.ObtenerValorAtributoItemActivoSegunAtributo( tcDetalle, lcAtributo )

		return lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValorAtributoItemActivoSegunAtributo( tcDetalle as string, tcAtributo as String ) as variant
		local lcReferenciaRetorno as string, lxRetorno as variant
		lcReferenciaRetorno =  "thisform.oEntidad" + "." + tcDetalle + ".oItem." + tcAtributo
		lxRetorno = &lcReferenciaRetorno
		return lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CondiciondeFoco( tcTipoDetalle as String , tnFila as Integer , tnColumna as Integer ) as Boolean
		return .T. 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function VerificarItemsCargadosEnDetalle( toDetalle as Object ) as Boolean
		local lni as Integer, llreturn as Boolean

		llReturn = .f.

		for lni = 1 to toDetalle.Count
			if toDetalle.ValidarExistenciaCamposFijosItemPlano( lni )
				llReturn = .t.
				exit
			endif
		endfor

		return llreturn
	Endfunc 
	
	*------------------------------------------------------------------------------------------
	function SalirdeLaGrilla( tcGrilla as String , tcColumna as String ) as Boolean

		local lRetorno as Boolean
		lRetorno = .f.
		return lRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function LostFocusDeControles() as Void
	
		if alltrim( upper( this.cAccion ) )= "SALIR" and ;
								!thisform.oentidad.EsNuevo() and thisform.oEntidad.EsEdicion()
			
			This.HacerLostFocusDeGrillas()
		else
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AdvertirLimiteAlcanzadoSegunDisenoImpresion( toInformacion as Object )
		if vartype( toInformacion ) = 'O'
			if !this.lMostroCartel
				this.lMostroCartel = .t.
			endif
		else
			goServicios.Mensajes.Advertir( toInformacion )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarInformeLimitesAlcanzadosPorDiseno( tcMensaje as String ) as VOID
		this.oInfoLimiteDiseno.AgregarInformacion( tcMensaje )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CancelarCargaXLimiteAlcanzadoSegunDisenoImpresion( tcTipoDetalle as String ) as VOID
		local lodetalle
		loDetalle = thisform.oEntidad.&tcTipoDetalle
		loDetalle.lCancelarCargaLimitePorDiseno = .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarLimitesEnDisenoImpresion( tcDetalle as String ) as Void
		This.oEntidad.VerificarLimitesEnDisenoImpresion( tcDetalle )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function CargaInsertarDetalle() as Void
		
		if this.LlamarFormularioSeleccionDeEntidad()
			This.InsertarDetalle()
		endif

	endfunc
	
	*-----------------------------+------------------------------------------------------------
	function LlamarFormularioSeleccionDeEntidad() as boolean
		local loFormulario as zooFormulario of zooFormulario.prg
		loFormulario = This.oFormularioSeleccionParaInsertar
		lcDetalle = This.oEntidad.ObtenerAtributoDetalleaInsertar()
		try
			if thisform.oEntidad.&lcDetalle..Count > 0
				thisform.oEntidad.&lcDetalle..Actualizar()
			endif
			loFormulario.Closable = .f.
			loFormulario.oKontroler.SeteosVisuales( this )
			this.SetearEstadoMenuYToolBar( .f. )
			loFormulario.AutoCenter = .t.
			loFormulario.Hide()
			loFormulario.Show( 1 )
			if pemstatus( loFormulario.oKontroler.oEntidad, "Ordenar",5 )
				this.lOrdenarDetalleAlInsertar = loFormulario.oKontroler.oEntidad.Ordenar
			endif 	
		finally
			this.SetearEstadoMenuYToolBar( .t. )
		endtry

		llRetorno = !isnull( this.oEntidadACopiar )
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InsertarDetalle() as Void
		local loDetalleDestino as detalle OF detalle.prg, loCopiador as CopiadorDeDetalles of CopiadorDeDetalles.prg, ;
		loControlDetalle as Object, lcNombreDetalle as String, lcCampoCodigo as String, lcCampoArt as String, ;
		lcAtributoVendedorEntidadDestino as String, lcAtributoVendedorEntidadACopiar as String 
		
		loDetalleDestino = This.oEntidad.ObtenerDetalleaInsertar()
		loCopiador = _screen.zoo.crearobjeto( alltrim( loDetalleDestino.cCopiadorDeDetalle ) )
		
		loCopiador.lOrdenarDetalleAlInsertar = this.lOrdenarDetalleAlInsertar 
		
		this.BindearEvento( loCopiador, "EventoInformarLimitePorDiseno", this, "InformarLimitePorDiseno" )
		this.oInfoLimiteDiseno = _screen.zoo.crearObjeto("ZooInformacion")
		this.BindearEvento( loDetalleDestino, "EventoGenerarInformeLimitePorDiseno", this, "GenerarInformeLimitesAlcanzadosPorDiseno")
		loCopiador.oDetalleDestino = loDetalleDestino
		if pemstatus( This.oEntidadACopiar, "cDetalleComprobante", 5 )
			lcNombreDetalle = alltrim( upper( This.oEntidadACopiar.cDetalleComprobante ) ) 

			loCopiador.cNombreTablaDetalle = This.oEntidadACopiar.oAd.ObtenerTablaDetalle( lcNombreDetalle )
			lcCampoCodigo = "This.oEntidadACopiar.oAd.ObtenerCampoDetalle" + lcNombreDetalle + "( 'CODIGO' )"
			lcCampoArt = "This.oEntidadACopiar.oAd.ObtenerCampoDetalle" + lcNombreDetalle + "( 'ARTICULO' )"
			
			loCopiador.cNombreCampoCodigo = &lcCampoCodigo
			loCopiador.cNombreCampoArticulo = &lcCampoArt
			this.TrasladarAtributosCabecera()
		endif
		if upper( alltrim( _screen.Zoo.app.NombreProducto ) ) != "ZL"
			if this.oEntidadACopiar.cDescripcion <> "Esquema de datos fiscales" 
				this.oEntidad.CargarFiltrosInsertarDesde(this.oEntidadACopiar)
			endif
		endif
		this.oEntidad.EventoVerificarLimitesEnDisenoImpresion( loDetalleDestino.cNombre )
 
		loCopiador.Insertardetalle( This.oEntidadACopiar.ObtenerDetalleaInsertar(), This.ObtenerDetallePromociones(), this.oEntidad )
		
		loControlDetalle = This.ObtenerControl( This.oEntidad.ObtenerAtributoDetalleaInsertar() )
		loControlDetalle.RefrescarGrilla()
		
		if pemstatus( this.oEntidad, "SoportaPromociones", 5 ) and this.oEntidad.SoportaPromociones()
			this.oEntidad.AplicarPromocionesForzado()
		endif

		if loDetalleDestino.Count > 0
			loDetalleDestino.Actualizar()
		endif

		if this.oInfoLimiteDiseno.count > 0
				this.oInfoLimiteDiseno.AgregarInformacion("Se ha superado el límite de items por agrupamiento, del diseño '" + alltrim( loDetalleDestino.cDisenoLimitador ) + "'.")
				goServicios.Mensajes.Advertir( this.oInfoLimiteDiseno )
		endif
		
		loDetalleDestino = null		
		loCopiador = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TrasladarAtributosCabecera() as Void
		local lcAtributoVendedorEntidadDestino as String, lcAtributoVendedorEntidadACopiar as String  
		if this.lTrasladaVendedorConInsertarDesde 
			if this.oEntidad.lTieneVendedorComoClaveForanea and this.oEntidadACopiar.lTieneVendedorComoClaveForanea 
				lcAtributoVendedorEntidadDestino = "this.oEntidad." + alltrim( this.oEntidad.cAtributoVendedor )
				if &lcAtributoVendedorEntidadDestino = ""
					lcAtributoVendedorEntidadACopiar = "this.oEntidadACopiar." + alltrim( this.oEntidadACopiar.cAtributoVendedor )
					&lcAtributoVendedorEntidadDestino = &lcAtributoVendedorEntidadACopiar
				endif
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function InformarLimitePorDiseno( toInformacion as Object ) as Void
		if vartype( toInformacion ) = "O"
			goServicios.Mensajes.Enviar(  toInformacion )
		endif 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarBarraOpcionesNoGenericas( tcEstado as String ) as Void
		local lHabilitoImprimirCheque as Boolean, lcPk as String, lHabilitoMenuAccionesSenias as Boolean, llEsEdicion_O_EsNuevo as Boolean

		dodefault( tcEstado )

		llEsEdicion_O_EsNuevo = thisform.oEntidad.EsNuevo() or thisform.oEntidad.EsEdicion()

		This.SetearEnabledMenu( "Acciones", "InsertarDetalle", llEsEdicion_O_EsNuevo )
		This.SetearEnabledMenu( "Acciones", "InsertarPromo", llEsEdicion_O_EsNuevo )
		This.SetearEnabledMenu( "Acciones", "MostrarAsistente", llEsEdicion_O_EsNuevo )
		if vartype( goParametros.Felino ) = "O"
			This.SetearEnabledMenu( "Acciones", "ReEvaluarPromociones", llEsEdicion_O_EsNuevo and !goParametros.Felino.GestionDeVentas.Minorista.Promociones.AplicarPromosAutomaticasAlSalirDelDetalle)
		else
			This.SetearEnabledMenu( "Acciones", "ReEvaluarPromociones", llEsEdicion_O_EsNuevo )
		endif
		this.setearEnabledMenu( "Acciones", "ModificarPrecio", this.ObtenerEstadoMenuParaModificarPrecio() )

		This.SetearEnabledMenu( "ACCIONES", "INSERTARDESDETXT", llEsEdicion_O_EsNuevo )		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oFormularioSeleccionParaInsertar_Access() as void
		if !this.lDestroy and ( vartype( this.oFormularioSeleccionParaInsertar ) != "O" or isnull( this.oFormularioSeleccionParaInsertar ) )
			this.oFormularioSeleccionParaInsertar = _Screen.zoo.crearobjeto( "FrmAbm_SeleccionParaInsertarAvanzado" + goFormularios.ObtenerNombreDeEstilo() )
		endif
		return this.oFormularioSeleccionParaInsertar
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		dodefault()
		if vartype( this.oFormularioSeleccionParaInsertar ) == "O" and !isnull( this.oFormularioSeleccionParaInsertar )
			This.oFormularioSeleccionParaInsertar.oKontroler.oKontrolerEntidad = null
			this.oFormularioSeleccionParaInsertar.Release()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstadoMenuParaModificarPrecio as Boolean
		local llEstado as Boolean
		with thisform 
			do case
				case .oEntidad.EsNuevo()
					llEstado = .F.
				case .oEntidad.EsEdicion()
					llEstado = .T.
				case type( "this.codigo" ) = "C" and !empty( this.Codigo ) and .oEntidad.TieneDetalleComprobanteCargado()
					llEstado = .T.
				otherwise
					llEstado = .F.
			endcase	
		endwith
		return llEstado
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarModificacionPrecios() as Void
		with thisform 
			do case
				case .oEntidad.EsNuevo()
					goServicios.Errores.LevantarExcepcionTexto( "No esta permitido cargar precios a partir de un comprobante en estado nuevo." )
				case !.oEntidad.TieneDetalleComprobanteCargado()
					goServicios.Errores.LevantarExcepcionTexto( "Debe tener cargada la grilla para poder generar una modificación de precios." )
				case !empty( .oEntidad.Codigo ) or .oEntidad.TieneDetalleComprobanteCargado()
					This.LlamarModificacionPrecios()
			endcase
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LLamarModificacionPrecios() as Void
		local lcListaDePrecios as String, lcDetalleComprobante as String, loError as Exception, loEx as Exception
		if pemstatus( This.oEntidad, "ListaDePrecios_Pk", 5 ) and !isnull( This.oEntidad.ListaDePrecios_Pk )
			lcListaDePrecios = This.oEntidad.ListaDePrecios_Pk
		else
			lcListaDePrecios = ""
		endif
		lcDetalleComprobante = thisform.oEntidad.cDetalleComprobante
		ThisForm.AddObject( "oControlModificacionPrecios",  "KontrolerComprobanteDet_Clave" )
		*ThisForm.oControlModificacionPrecios.LlamarModificacionPrecios( This.oEntidad.&lcDetalleComprobante, lcListaDePrecios )
		*ThisForm.RemoveObject( "oControlModificacionPrecios" )
		try 
			ThisForm.oControlModificacionPrecios.LlamarModificacionPrecios( This.oEntidad.&lcDetalleComprobante, lcListaDePrecios )
			ThisForm.RemoveObject( "oControlModificacionPrecios" )
		catch to loError
			gomensajes.EnviarSinEsperaProcesando()
			this.SetearEstadoMenuYToolBar( .t. )
			ThisForm.RemoveObject( "oControlModificacionPrecios" )
			loEx = _screen.zoo.crearobjeto( "ZooException" )
				With loEx				
					.Grabar( loError )
					goServicios.Errores.LevantarExcepcion( "Se superó la cantidad de líneas permitidas en el comprobante." + chr(13) + ;
										 "Para realizar esta acción utilizar la herramienta Modificación masiva de precios." )
				EndWith
		endtry		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InsertarDesdeTxt() as Void
		local llBuscarRuta as Boolean, lcMensaje as String,lnValorNo  as Integer
		lcMensaje = "¿Desea continuar procesando las líneas pendientes del archivo?"
		lcTituloMensaje = "Agregar detalle desde txt."
		lnValorNo = 7 
		
		llBuscarRuta = iif( file( this.cRutaArchivo, 1 ), goMensajes.preguntar( lcMensaje, 4, 1, lcTituloMensaje ) = lnValorNo , .t. )     
		
		if llBuscarRuta	
			this.cRutaArchivo = this.oArchivos.obtenerarchivo( "Archivos de texto (*.txt):txt", "Abrir" )
		endif 
		
		if !empty( this.cRutaArchivo )
			this.IngresarLecturaTxt( this.cRutaArchivo )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function IngresarLecturaTxt( tcRutaArchivo as String ) as Void
		local loDetalle as Detalle.prg, lcContenido as String, loControlDetalle as Object, lcNombreDetalle as String, lcProcesado as String, lcErroneo as String, lcMensaje as String
		
		loDetalle = this.ObtenerDetalleParaIngresoLecturaTxt()
		lcNombreDetalle = iif( !empty( loDetalle.cNombreVisual ), loDetalle.cNombreVisual, "detalle" )
		lcPendientes = ""
		lcProcesado = ""
		lcErroneo = ""
		lcMensaje = ""

		goServicios.Mensajes.EnviarSinEsperaProcesando( "Ingresando lectura a " + lcNombreDetalle )
		
		try
			this.oEntidad.eventoverificarLimitesEnDisenoImpresion( loDetalle.cNombre )
			lcContenido = this.oArchivos.LeerArchivo( tcRutaArchivo )
			if !empty(lcContenido)
				lcPendientes = lcContenido
				this.oAdaptadorTxtADetalleLecturaCB.Cargar( loDetalle, @lcPendientes, @lcProcesado, @lcErroneo,this.oEntidad )
				if( lcContenido = lcPendientes)
					lcMensaje = "No se proceso el archivo debido a que superó el límite disponible."
				else
					this.GenerarArchivosGuardarDetalleDesdeTxt( tcRutaArchivo, lcPendientes, lcProcesado, lcErroneo) 
					lcMensaje = this.GenerarMensajeGuardarDetalleDesdeTxt( tcRutaArchivo, lcPendientes, lcProcesado, lcErroneo) 
				endif
			else
				lcMensaje = lcMensaje + "El archivo se encuentra vacío."
			endif
		finally
			goServicios.Mensajes.EnviarSinEsperaProcesando( "Finalizado, refrescando grilla..." )
			
			if pemstatus( this.oEntidad, "oComponenteFiscal", 5 ) and pemstatus( this.oEntidad.oComponenteFiscal, "RecalcularImpuestos", 5 )
				this.oEntidad.oComponenteFiscal.RecalcularImpuestos(loDetalle,this.oEntidad.impuestosDetalle)
			endif
			
			if pemstatus(this.oEntidad,"AplicarRecalculosGenerales",5)
				this.oEntidad.AplicarRecalculosGenerales()
			else
				loControlDetalle = this.ObtenerControl( loDetalle.cNombre )
				loControlDetalle.RefrescarGrilla()
			endif
			
			if pemstatus( this.oEntidad, "SoportaPromociones", 5 ) and this.oEntidad.SoportaPromociones()
				this.oEntidad.AplicarPromocionesForzado()
			endif
			
			goServicios.Mensajes.EnviarSinEsperaProcesando()
			
			if !empty(lcContenido) and this.oAdaptadorTxtADetalleLecturaCB.lInformarColoresYTallesIncorrectosAsociadosAPaletasYCurvas 
				goServicios.mensajes.Advertir( "Se ingresaron colores y/o talles no asociados a paletas y curvas." )
			endif		
			
			if !empty(lcMensaje)
				goServicios.mensajes.Advertir( lcMensaje )
				this.oInformacion.remove(-1)
			endif	
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDetalleParaIngresoLecturaTxt() as Object
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivosGuardarDetalleDesdeTxt( tcRutaOriginal as String,  tcPendientes as String, tcProcesados as String, tcError as String ) as Void
		local lcRuta as String, lcFecha as String, lcExtencionArchivo as String, lcRutaArchivoSinExtencion as String , lcNombreArchivo as String
		lcExtencionArchivo = "." + justext( tcRutaOriginal )
		lcRutaArchivoSinExtencion  =  left( tcRutaOriginal, len(tcRutaOriginal ) -  len(lcExtencionArchivo) )
		lcNombreArchivo = juststem( tcRutaOriginal )
		lcFecha = dtos( date() ) + strtran( time(), ":", "" )
		
		if !empty( tcPendientes ) 
			lcRuta = lcRutaArchivoSinExtencion  + "_FALTANTES_" + lcFecha + lcExtencionArchivo
			strtofile(tcPendientes ,lcRuta )	
			this.cRutaArchivo = lcRuta
		else
		   this.cRutaArchivo = ""
		endif 
		
		if !empty( tcProcesados )
			lcRuta = lcRutaArchivoSinExtencion  + "_PROCESADOS_" + lcFecha + lcExtencionArchivo
			strtofile(tcProcesados ,lcRuta )
		endif
				
		if !empty( tcError )
			lcRuta = lcRutaArchivoSinExtencion  + "_ERROR_" + lcFecha + lcExtencionArchivo
			strtofile(tcError ,lcRuta )
		endif
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarMensajeGuardarDetalleDesdeTxt( tcRutaOriginal as String, tcPendientes as String, tcProcesados as String, tcError as String ) as String
		local lcNombreArchivo as String, lcMensaje as String , lnCantidadLineas as Integer, lcSaltoDeLineas as String
		lnCantidadLineas = 0
		lcMensaje = ""
		lcNombreArchivo = juststem( tcRutaOriginal )
		lcExtencionArchivo = "." + justext( tcRutaOriginal )
		lcSaltoDeLineas =  chr(13) + chr(10)
		
		if !empty(tcPendientes) 
			lnCantidadLineas = OCCURS(chr(13),tcPendientes)
			lcMensajeSingular = "Quedó 1 lìnea pendiente."
			lcMensajePlural = "Quedaron " + alltrim(str(lnCantidadLineas)) + " líneas pendientes."
			lcMensaje = iif(lnCantidadLineas = 1, lcMensajeSingular, lcMensajePlural )  + " Debe volver a procesar el archivo " + lcNombreArchivo + "_FALTANTES" 
		endif
		
		if (!empty(tcPendientes) or !empty(tcError)) and !empty( tcProcesados ) 
			lnCantidadLineas = OCCURS(chr(13),tcProcesados )
			lcMensajeSingular = "Se proceso correctamente 1 línea."
			lcMensajePlural = "Se procesaron correctamente " + alltrim(str(lnCantidadLineas)) + " líneas."
			
			lcMensaje = iif( empty(lcMensaje), lcMensaje, lcMensaje + lcSaltoDeLineas )
			lcMensaje = lcMensaje + iif( lnCantidadLineas = 1, lcMensajeSingular, lcMensajePlural )
		endif
		
		if !empty(tcError) 
			lnCantidadLineas = OCCURS(chr(13),tcError)
			lcMensajeSingular = "Se ha encontrado 1 línea errónea."
			lcMensajePlural = "Se han encontrado " + alltrim(str(lnCantidadLineas)) + " líneas erróneas."
			
			lcMensaje = iif( empty(lcMensaje), lcMensaje, lcMensaje + lcSaltoDeLineas   )
			lcMensaje = lcMensaje + iif(lnCantidadLineas = 1,lcMensajeSingular, lcMensajePlural  )
		endif
			
		if !empty(tcError) or ( !empty(tcProcesados ) and !empty(tcPendientes))
			lcMensaje = lcMensaje + lcSaltoDeLineas + lcSaltoDeLineas  + "Ver los archivos generados en la carpeta de origen." 
		endif	
		
		return lcMensaje
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemAnterior(tcTipoDetalle as String, tnItem as Integer ) as Object
		local loItemActivo as Object
		loItemActivo = null
		if tnItem > 0
			loItemActivo = thisform.oEntidad.&tcTipoDetalle..item[tnItem]	
		endif
		
		return loItemActivo	
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDetallePromociones() as object
		local loRetorno as Object
		
		loRetorno = null
		
		if pemstatus( this.oEntidadACopiar, "SoportaPromociones", 5 ) and this.oEntidadACopiar.SoportaPromociones()
			loRetorno = this.oEntidadACopiar.PromoArticulosDetalle	
		endif
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsComprobanteDeVentas() as Void
		local llRetorno as Boolean 
		llRetorno = "<VENTAS>" $ this.oEntidad.ObtenerFuncionalidades() 
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RefrescarDetalle( tcDetalle as String ) as Void
		local loControl as Object	
		if !empty(tcDetalle) and evaluate( 'vartype( This.oEntidad.' + tcDetalle + ' ) = "O"' )
			if This.ExisteControl( tcDetalle  )
				loControl = this.obtenerControl( tcDetalle  ) 		
				loControl.RefrescarGrilla()
			EndIf
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NoDebeValidarActualizarDetalle() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NoDebeValidarActualizarDetallePorOperatoriaEnBaseA() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsUnDetalle( toControl ) as Boolean
		local llRetorno as Boolean
		llRetorno = pemstatus( toControl, "cDominio", 5 ) and substr( upper( alltrim( toControl.cDominio ) ),1, 7 ) == "DETALLE"
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oPrimerControl_Access() as Object
		local llPrimerControl as Boolean
		if !this.ldestroy and !isnull( This.oColControlesVisuales )
			local lnI as Integer, loObjeto as Object, loItem as Object,lnFila as Integer, lnColumna as Integer
			for lnI = 1 to This.oColControlesVisuales.Count
				loObjeto = This.ObtenerControl( This.oColControlesVisuales.Item[lnI] )
				if This.EsUnDetalle( loObjeto )
					llPrimerControl = .f.
					for lnFila = 1 to loObjeto.nCantidadItemsVisibles
						for lnColumna = 1 to loObjeto.nCantidadColumnas
							loItem = loObjeto.ObtenerCelda( lnFila, lnColumna )
							if this.EsUnObjetoConFoco( loItem )
								lnFila = loObjeto.nCantidadItemsVisibles
								lnColumna = loObjeto.nCantidadColumnas
								lnI = This.oColControlesVisuales.Count
								This.oPrimerControl = loItem
								llPrimerControl = .f.
								exit For
							endif
						endfor
						if llPrimerControl
							exit For
						endif
					endfor
					if llPrimerControl
						exit For
					endif
				else
					if this.EsUnObjetoConFoco( loObjeto )
	 					This.oPrimerControl = loObjeto
	 					llPrimerControl = .f.
						exit For
					Endif
				Endif
			endfor
			loItem = null
			loObjeto = null
		endif
		Return This.oPrimerControl
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarRestriccionDeDescuentosEnLineaDetalleFactura( tnFilaEnGrilla as Integer ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AjustarBanderaLuegoDeCargaAutomatica() as Void
		This.lHuboCargaAutomatica = .F.
	endfunc 
    
	*-----------------------------------------------------------------------------------------
	function ObtenerInformacionCliente() as String
		local lcRetorno as String
		lcRetorno = ""
		with this.oEntidad
			if vartype( .Cliente ) = 'O' and .Cliente.Codigo != ""
				if .Cliente.SituacionFiscal_PK = 3
					if !empty( .Cliente.NroDocumento )
						lcRetorno = .Cliente.ObtenerDescripcionDelTipoDeDocumento() + ": " + alltrim( .Cliente.NroDocumento ) + " "
					endif
				else
					if !empty( .Cliente.CUIT )
						lcRetorno = "CUIT: " + alltrim( left(alltrim( .Cliente.CUIT ), 2) + "-" + substr(alltrim( .Cliente.CUIT ), 3, 8) + "-" + right(alltrim( .Cliente.CUIT ), 1)) + " "
					endif
				endif
				lcRetorno = lcRetorno + .Cliente.ObtenerDescripcionSituacionFiscalCliente()
			endif
		endwith
        return lcRetorno 
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function BindearEventosCodBarAlternativo()
		local lcDetalle as String
		
		if pemstat( this.oEntidad,"cdetallecomprobante",5 )
			lcDetalle = upper( this.oentidad.cdetallecomprobante )
			
			if inli(lcDetalle, "FACTURADETALLE", "DETALLECONTROLADO", "MOVIMIENTODETALLE" ) and pemstatus( this.oentidad.&lcDetalle..oitem,"lUtilizaLecturaDeCodigoDeBarras", 5 );
					 and this.oentidad.&lcDetalle..oitem.lUtilizaLecturaDeCodigoDeBarras

				if pemstatus( this.oentidad.&lcDetalle..oitem,"PreguntarQueHacerCBRepetidoI", 5 )
					this.BindearEvento( this.oentidad.&lcDetalle..oitem, 'PreguntarQueHacerCBRepetidoI', this, 'PreguntarQueHacerCBRepetido' )
				endif

				if pemstatus( this.oentidad.&lcDetalle,"LimpiarDetalleCodBarAlt", 5 )
					this.BindearEvento( this.oentidad, "Nuevo", this.oentidad.&lcDetalle, "LimpiarDetalleCodBarAlt" )
					this.BindearEvento( this.oentidad, "Modificar", this.oentidad.&lcDetalle, "LimpiarDetalleCodBarAlt" )
				endif

				if pemstatus( this.oentidad.&lcDetalle,"lControlaSecuencialEnCodBarAlt", 5 )					
					this.oentidad.&lcDetalle..lControlaSecuencialEnCodBarAlt = .T.
				endif
			endif
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RestringirIngresoDeDecimalesEnCantidad() as Boolean
		return goServicios.Parametros.Felino.GestionDeVentas.RestringirIngresoDeDecimalesEnCantidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarQueHacerCBRepetido(tcMensaje as String, tnOpcionPregunta as integer, tcNombreDetalle as String ) as VOID
		local llRetorno as Boolean

		do case
			case inlist( tnOpcionPregunta, 1, 2 )
				tcMensaje = tcMensaje + chr(10) + chr(13) + "¿Desea incorporar esta nueva lectura repetida en el detalle?"
				llRetorno = !(goServicios.Mensajes.preguntar( tcMensaje , 4, iif(tnOpcionPregunta=1,0,1) ) = 6 )
			case tnOpcionPregunta = 3
				tcMensaje = tcMensaje + chr(10) + chr(13) + "No se incorporará esta nueva lectura en el detalle."
				this.agregarinformacion( tcMensaje )
				goMensajes.Advertir( tcMensaje )
				llRetorno = .T.
			otherwise
		endcase

		if type("this.oentidad.&tcNombreDetalle..oitem.oCodigoDeBarras.lSeguirPorCBRepetido") = "L"
			this.oentidad.&tcNombreDetalle..oitem.oCodigoDeBarras.lSeguirPorCBRepetido = llRetorno
		endif
	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function OcultarCampoLecturaCB() as Void

		if vartype( this.oEntidad ) = 'O' and !isnull( this.oEntidad ) and pemstatus(this.oEntidad, "cDetalleComprobante", 5) 
			local lcNombreDetalle as String, loControl as Object
			lcNombreDetalle = this.oEntidad.cDetalleComprobante
			if this.ExisteControl( lcNombreDetalle )
				loControl = this.ObtenerControl( lcNombreDetalle )
				if pemstatus(loControl, "CampoLecturaCB", 5)
					loControl.CampoLecturaCB.visible = .f.
				endif
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearPropiedadesParaPosicionamientoEnGrilla( tlValorDefault as Boolean ) as Void
		if tlValorDefault
			this.lForzarLostFocusCampoLecturaCB = .f.
		else
			this.lForzarLostFocusCampoLecturaCB = .t.
		endif
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class KontrolerComprobanteDet_Clave as Clave of Clave.prg
	cEntidad = "COMPROBANTEDET"
	cClaveForanea = "MODIFICACIONPRECIOS"
	cAtributo = "c_ModificacionPrecios"
	
	*-----------------------------------------------------------------------------------------
	function LlamarModificacionPrecios( toDetalle as Object, tcListaDePrecio as String ) as Void
		local loFormulario as Object
		
		with thisform 
			.oKontroler.SetearEstadoMenuYToolBar( .f. )
			loFormulario = goServicios.Formularios.ProcesarSubEntidad( this )
			if vartype( loFormulario ) = "O"
				loFormulario.Nuevo()
				loFormulario.oKontroler.CargarPreciosSegunDetalle( toDetalle, tcListaDePrecio )
				loFormulario.oKontroler.ActualizarFormulario()
				loFormulario.show( 1 )
			endif
			.oKontroler.SetearEstadoMenuYToolBar( .t. )
		endwith
	endfunc
	
	 
enddefine
