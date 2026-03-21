define class ComponenteFiscal as zoosession of zoosession.prg

	#if .f.
		local this as ComponenteFiscal of ComponenteFiscal.prg
	#endif

	#DEFINE PRECISIONENREDONDEO 12
	
	oFiscal = null
	nSituacionFiscalEmpresa = 0
	cTipoDeComprobante = ''
	lInicializado = .f.

	oSFiscalEmpresa = null
	oSFiscal = Null
	oComprobantes = null
	oTipoLista = null
	oTipoIVA = null
	oColImpuestos = null
	oImpuestosDetalle = null
	oEntPercepciones = null

	nIVAInscriptos = 0
	nIVANoInscripto = 0
	nBocaDeExpendio = 0
	nPuntoDeVenta = 0
	
	nImporte = 0
	nImporteIva = 0
	nPorcentajeIVA = 0
	oComponenteNumeracion = null
	lExisteControlador = .F.
	cItemsAImprimirEnComprobante = ""
	lPreprocesar = .t.
	cEstadoInicializado = ""
	
	lImprimir = .F.
	oComponenteImpuestos = null
	lSeAgregoRecargoPorCambio = .f.

	lEsComprobanteElectronico = .F.
	lExportacion = .f.
	nPorcentajeIVAOriginal = 0
	nTasaNominalImpuestoInterno = 0
	nTasaEfectivaImpuestoInterno = 0
	nImporteImpuestoInterno = 0
	lComprobantesAMonotributistas = .t.

	protected FechaDeComprobante
	FechaDeComprobante = {}
	
	lEstaRecalculandoImpuestosAntesDeGrabar = .F.
	lEsUruguay = .f.

	lIvaLiberado = .f. 
	lIvaLiberadoAnterior = .f. 

	*-----------------------------------------------------------------------------------------
	function EventoCambioTotalImpuesto() as Void
		****
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciaPropiedades() as Void
		
		this.CargarPropiedadesDelSistema()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.lDestroy = .T.
		this.oImpuestosDetalle = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		dodefault()
		this.oImpuestosDetalle = null
	
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function Init( tcTipoDeComprobante as String ) as Void
	
		if pcount() < 1
			assert .f. message "Debe indicar el Tipo de Comprobante"
		endif
		
		dodefault()
		
		this.lEsUruguay = ( goServicios.Parametros.Nucleo.DatosGenerales.Pais = 3 )
		this.cTipoDeComprobante = tcTipoDeComprobante
		this.lComprobantesAMonotributistas = goParametros.Felino.GestionDeVentas.HabilitaComprobantesLetraAParaMonotributistasRG500321AFIP =< ;
			goServicios.librerias.ObtenerFecha()
		this.CargarPropiedadesDelSistema()
		this.oColImpuestos = _screen.zoo.CrearObjeto( "ZooColeccion" )

		this.oComponenteImpuestos = this.ObtenerComponenteImpuestos()
		this.oComponenteImpuestos.lComprobanteDeExportacion = this.lExportacion
		this.oComponenteImpuestos.lMontosConIvaIncluido = this.MostrarImpuestos()
		this.oComponenteImpuestos.cTipoDeComprobante = this.cTipoDeComprobante	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PermiteAccionesDeAbm() as Boolean 
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteControlador() as Boolean
		Return This.lExisteControlador
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetra() as string
		local lcRetorno as Character

		store "" to lcRetorno

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPuntoDeVenta() as integer
		return 0
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarPropiedadesDelSistema() as Void
		local lnPermitido as Integer
		
		with this
			.lIvaLiberadoAnterior = .lIvaLiberado
			.lIvaLiberado = this.EvaluarSiCorrespondeAplicarLey19640() 
			.oSFiscalEmpresa = newobject('SituacionFiscalEmpresa')
			.oComprobantes = newobject('Comprobantes')
			.oTipoLista = newobject( 'TipoLista' )
			.oSFiscal = newobject( 'SituacionFiscal' )
			.oTipoIVA = newobject( 'TipoIVA' )
			.nIVANoInscripto = goParametros.felino.datosImpositivos.IvaNoInscriptos

			if this.lEsComprobanteElectronico or this.lExportacion
				if this.lExportacion
					if this.lEsComprobanteElectronico
						.nBocaDeExpendio = goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Exportacion.PuntoDeVenta
					else
						.nBocaDeExpendio = goServicios.Parametros.Felino.GestionDeVentas.ComercioExterior.PuntoDeVenta
					endif
				else
					if this.lEsUruguay 
						if goRegistry.Felino.FEUruguayModoContingenciaActivado
							.nBocaDeExpendio = goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Uruguay.PuntoDeVentaComprobantesDeContingencia
						else
							.nBocaDeExpendio = goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Uruguay.PuntoDeVentaComprobantesElectronicos
						endif
					else
						if goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Nacional.habilitarfacturacionelectronicaanticipadacaea and goregistry.felino.FEmodoCaeaActivado
							.nBocaDeExpendio = goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Nacional.puntodeventacaea
						else
							.nBocaDeExpendio = goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Nacional.PuntoDeVenta
						endif
					endif
				endif
			Else
				.nBocaDeExpendio = goServicios.Parametros.felino.Numeraciones.BocaDeExpendio
			EndIf

			if .oSFiscalEmpresa.ValidarSituacionFiscal( goParametros.Felino.DatosGenerales.SituacionFiscal )
				.nSituacionFiscalEmpresa = goParametros.Felino.DatosGenerales.SituacionFiscal
			else
				goServicios.Errores.LevantarExcepcion( 'La situación fiscal asignada a la empresa no es válida. Edite los parámetros de la empresa y asigne una nueva.' )
			endif
		endwith

		* 1-Tipo de IVA Venta - Gravado fijo
		* 2-Tipo de IVA Venta - No Gravado
		* 3-Tipo de IVA Venta - Gravado libre

		*!*	Situaciones Fiscales Empresa
		*!*	1. Responsable Inscripto
									*!*	2. Responsable No Inscripto !!!!!!!! NO VA MAS
		*!*	3. Responsable Monotributo
		*!*	4. Exento
		*!*	5. Inscripto No Responsable
		*!*	6. Liberado
		*!*	7. No Alcanzado

		*!*	Situaciones Fiscales Cliente
		*!*	1. Responsable Inscripto
									*!*	2. Responsable No Inscripto !!!!!!!! NO VA MAS
		*!*	3. Consumidor Final-
		*!*	4. Exento
		*!*	5. Inscripto No Responsable
		*!*	6. Liberado
		*!*	7. Responsable Monotributo
		*---------------------------------------------------- NO DESARROLLADOS
		*!*	8. Monotributista Social
		*!*	9. Pequeño contribuyente eventual
		*!*	10. Pequeño contribuyente eventual social
		*!*	11. No Categorizado
		*!*	12. No Alcanzado
 	endfunc 

	*---------------------------------------------------------------------------------------
	function ObtenerParametroDeNumeracion() as String
		local lcComprobante as String, lcRetorno as String, lcParametro as String

		lcComprobante = this.cTipoDeComprobante
		if upper( lcComprobante ) # "FACTURA"
			lcParametro = "Habilita" + goLibrerias.TransformarCadenaCaracteres( lower( lcComprobante ))
			if goParametros.Felino.Numeraciones.&lcParametro
				lcComprobante = "Factura"
			endif
		endif

		lcRetorno = "UltimoNumeroEmitidoDe" + goLibrerias.TransformarCadenaCaracteres( lower( lcComprobante )) + ;
					"Tipo" + alltrim( upper( this.ObtenerLetra() ) )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreProcesarItem( tcAtributo as String, toItem as Object ) as Void
		if this.Preprocesar()
			if toItem.Oferta <= 1 	
				do case
					case lower(tcAtributo) = 'articulo_pk' and empty(evaluate("toItem."+tcAtributo))
						this.nImporte = 0
					case !toItem.UsarPrecioDeLista and inlist( upper( tcAtributo ), "TIPOLISTADEPRECIO", "ACTUALIZARPRECIO", "PRECIODELISTA" )
						if this.EsItemRelacionadoASenia( toItem )
							this.nImporte = this.ObtenerPrecioDeItemRelacionadoASenia( toItem )
						else
							this.nImporte =  this.ObtenerPrecio( toItem )
						endif
					case toItem.UsarPrecioDeLista
						this.nImporte = toItem.PrecioDeLista
					otherwise 
						this.nImporte = this.ObtenerPrecio( toItem )
				endcase
				this.procesarItem( toItem )
			endif
			this.CalcularImpuestos( toItem, this.oImpuestosDetalle )
		endif			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarItem( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Void
		store 0 to this.nImporteIva, this.nPorcentajeIVA
			with this
				.SetearPorcentajeDeImpuestos( toItem )
				.SetearImporteSinImpuestos( toItem )
				.SetearMontosImpuestos()
				.SetearPrecios( toItem )
				.AsignarMontosDeImpuestos( toItem )
			endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearPorcentajeDeImpuestos( toItem as Object ) as Void
		with this
			.SetearPorcentajeIva( toItem )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMontosImpuestos() as Void
		with this
			.nImporteIva = .CalcularIVA()
		endwith
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EvaluarSiCorrespondeAplicarLey19640() as Void   
		local lcComprobante as String, llRetorno as boolean
		store .f. to llRetorno 
		lcComprobante = iif(type( "this.cTipoDeComprobante" ) = "C" , this.cTipoDeComprobante , "")
		if (upper( lcComprobante ) = "REMITO" or  upper( lcComprobante ) = "PEDIDO") and this.lIvaLiberado 
			llretorno = .t.
		endif
		
		return llretorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearPorcentajeIva( toItem as Object ) as Void
		this.nPorcentajeIVAOriginal = this.ObtenerPorcentajeIVA( toItem )
		if this.lExportacion or this.EvaluarSiCorrespondeAplicarLey19640() 
			this.nPorcentajeIVA = 0
		else
			this.nPorcentajeIVA = this.nPorcentajeIVAOriginal
		endif
		toItem.PorcentajeIVA = this.nPorcentajeIVA
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeIVA( toItem as Object ) as Float
		local lnTipoIVA as integer, lnPorcentajeIvaGravado as Float, lnPorcIVA as Float
		lnPorcIVA = 0
		with this
			lnTipoIVA = .ObtenerCondicionDeIvaDelArticulo( toItem ) 
			lnPorcentajeIvaGravado = .ObtenerPorcentajeDeIvaDelArticulo( toItem )   
			
			lnPorcIVA = this.ObtenerPorcentajeIVASegunTipoIVA( lnTipoIVA, lnPorcentajeIvaGravado, toItem )
			
		endwith
		return lnPorcIVA
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPorcentajeIVASegunTipoIVA( tnTipoIVA as Integer, tnPorcentajeIvaGravado as Integer, toItem as Object ) as Integer
		local lnIva as Integer
		
		with this
			do case
				case tnTipoIVA == .oTipoIVA.NoGravado 
					lnIva = 0
				case tnTipoIVA = .oTipoIVA.GravadoLibre and tnPorcentajeIvaGravado > 0
					lnIva = tnPorcentajeIvaGravado
				case tnTipoIVA = .oTipoIVA.GravadoFijoReducido
					lnIva = goParametros.Felino.DatosImpositivos.IvaAlicuotaReducida
				otherwise
		&& En una NC cancelatoria, los artículos que se cargan manualmente después del en base a tienen que tener el IVA actual
					if pemstatus( this, "lAccionCancelatoria", 5 ) and this.lAccionCancelatoria and empty( toItem.Afe_codigo )
						lnIva = goParametros.Felino.DatosImpositivos.IvaInscriptos
					else
						lnIva = .nIVAInscriptos
					endif
			endcase
		endwith		
		
		return lnIva
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionDeIvaDelArticulo( toItem as Object ) as Integer 
		local lnRetorno as Integer
		lnRetorno = 0
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeDeIvaDelArticulo( toItem as Object ) as Number 
		local lnRetorno as number
		lnRetorno = 0
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularIVA() as float	
		local lnRetorno
		lnRetorno = 0
		if this.nPorcentajeIVA > 0 
			lnRetorno = this.nImporte * ( this.nPorcentajeIVA / 100 )
		endif
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CalcularIVAOriginal() as float	
		local lnRetorno
		lnRetorno = 0
		if this.nPorcentajeIVAOriginal > 0 
			lnRetorno = this.nImporte * ( this.nPorcentajeIVAOriginal / 100 )
		endif
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearPrecios( toItem as Object ) as Void
		with toItem
			.PrecioSinImpuestos = this.nImporte 

			if !this.EvaluarSiCorrespondeAplicarLey19640() 
				.PrecioConImpuestos = this.nImporte + this.TotalImpuestos()
			else
				.PrecioConImpuestos = this.nImporte + this.CalcularIvaOriginal() 
			endif

			this.SetearPrecio( toItem )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearPrecio( toItem as Object ) as Void
		** método para ser pisado por los componentes fiscales de ventas y compras (por diferencia en la cant. de decimales)		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TotalImpuestos() as Double
		local lnRetorno as Double
		lnRetorno = this.nImporteIVA
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarMontosDeImpuestos( toItem as Object ) as Void
		** método para ser pisado por los componentes fiscales de ventas y compras (por diferencia en la cant. de decimales)		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearImporteSinImpuestos( toItem as Object ) as Void
		with this
			if .MostrarImpuestos()
				if toItem.TipoListaDePrecio = .oTipoLista.MasIva
					if .EsCargaManualDePrecio( toItem )
						.RestarImpuestos()
					endif
				else
					.RestarImpuestos()
				endif
			else
				if toItem.TipoListaDePrecio = .oTipoLista.IvaIncluido and !.EsCargaManualDePrecio( toItem ) and upper(alltrim(toitem.afe_letra)) != "E"
					.RestarImpuestos()
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsCargaManualDePrecio( toItem as Object ) as Boolean
		return !toItem.UsarPrecioDeLista
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RestarImpuestos() as Void
		with this
			*.nImporte = ( .nImporte ) / (( (.nPorcentajeIVAOriginal + .nTasaEfectivaImpuestoInterno) / 100 ) + 1 )
			.nImporte = this.CalcularImporteSinImpuestos( .nImporte, .nPorcentajeIVAOriginal, .nTasaEfectivaImpuestoInterno ) 
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CalcularImporteSinImpuestos( tnImporte as Integer, tnPorcentajeIVAOriginal as Integer, tnTasaEfectivaImpuestoInterno as Integer ) as Void
		return ( tnImporte ) / (( (tnPorcentajeIVAOriginal + tnTasaEfectivaImpuestoInterno) / 100 ) + 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularImpuestos( toItem as Object, toDetalleImpuestos as Object ) as Void
		local loItemImpuestos as ItemColeccionImpuestos, lcNroItem as String, lnMontoAnterior as float, ;
			lnPorcentajeAnterior as float, llEncontro as Boolean, lnIvaASumar as float, lnIvaARestar as float, ;
			lnIndice as integer, lnMontoNoGravadoAnterior as float, lnMontoImpuestoInternoAnterior as float, ;
			lnPorcentajeIvaDelItem as float, llExisteIvaEnDetalleImpuestos as Boolean

		llEncontro = .f.
		llExisteIvaEnDetalleImpuestos = .f.
		lcNroItem = transform( toItem.NroItem )
		lnMontoAnterior = 0
		lnPorcentajeAnterior = 0
		lnMontoNoGravadoAnterior = 0 
		lnMontoImpuestoInternoAnterior = 0 

		if this.oColImpuestos.Buscar( lcNroItem )
			lnMontoAnterior = this.oColImpuestos[ lcNroItem ].nMonto
			lnPorcentajeAnterior = this.oColImpuestos[ lcNroItem ].nPorcentaje
			lnMontoNoGravadoAnterior = this.oColImpuestos[ lcNroItem ].nMontoNoGravado
			lnMontoImpuestoInternoAnterior = this.oColImpuestos[ lcNroItem ].nMontoImpuestoInterno

			** si existe se quita el item para luego agregarlo y recalcular
			this.oColImpuestos.quitar( lcNroItem ) 
		endif
		
		lnPorcentajeIvaDelItem = iif( lnMontoNoGravadoAnterior # 0, lnPorcentajeAnterior, this.nPorcentajeIva )
		
		this.AgregarItemEnColeccionDeImpuestos( toItem.NroItem, this.nPorcentajeIva, This.nImporteIva, this.nImporte, this.nImporteImpuestoInterno, toItem.PercepcionIvaRG5329 )
		
		local llRefrescar as Boolean, lnPorcentajeDeIva as Boolean, lnMontoIva  as Double, lnMontoNoGravado  as Double, lnMontoImpuestoInterno as Double

		llRefrescar = .t.
		lnPorcentajeDeIva = 0
		lnMontoIva = 0
		lnMontoNoGravado = 0
		lnMontoImpuestoInterno = 0
		** Se modifica la coleccion de impuestos de la entidad
		for lnIndice = 1 to toDetalleImpuestos.count
			toDetalleImpuestos.CargarItem( lnIndice )
			loItem = toDetalleImpuestos.oItem
			
			llRefrescar = .t.
			lnPorcentajeDeIva = loItem.PorcentajeDeIVA
			
			if lnPorcentajeDeIva = lnPorcentajeIvaDelItem 
				llExisteIvaEnDetalleImpuestos = .t.
			endif
			
			do case
				case ( lnPorcentajeDeIva == this.nPorcentajeIVA ) and ( lnPorcentajeDeIva == lnPorcentajeAnterior )
					lnMontoIva = this.nImporteIva - lnMontoAnterior
					lnMontoNoGravado = this.nImporte - lnMontoNoGravadoAnterior
					lnMontoImpuestoInterno = this.nImporteImpuestoInterno - lnMontoImpuestoInternoAnterior
					llEncontro = .t.
					
				case ( lnPorcentajeDeIva == this.nPorcentajeIVA ) and ( lnPorcentajeDeIva != lnPorcentajeAnterior )
					lnMontoIva = this.nImporteIva
					lnMontoNoGravado = this.nImporte
					lnMontoImpuestoInterno = this.nImporteImpuestoInterno
					llEncontro = .t.
					
				case ( lnPorcentajeDeIva != this.nPorcentajeIVA ) and ( lnPorcentajeDeIva == lnPorcentajeAnterior )
					lnMontoIva =  lnMontoAnterior * -1
					lnMontoNoGravado = lnMontoNoGravadoAnterior * -1
					lnMontoImpuestoInterno = lnMontoImpuestoInternoAnterior * -1
					
				otherwise
					llRefrescar = .f.
			endcase
						
			if llRefrescar
				loItem.MontoDeIvaSinDescuento = loItem.MontoDeIvaSinDescuento + lnMontoIva
				loItem.MontoNoGravadoSinDescuento = loItem.MontoNoGravadoSinDescuento + lnMontoNoGravado 
				loItem.MontoDeImpuestoInternoSinDescuento = loItem.MontoDeImpuestoInternoSinDescuento + lnMontoImpuestoInterno
				loItem.RecalcularMontosConDescuentosYRecargos()
				toDetalleImpuestos.Actualizar()
			endif
		endfor	

		if toDetalleImpuestos.count = 0
			this.lPreprocesar = .f.
			this.EventoCambioTotalImpuesto()
			this.lPreprocesar = .t.			
		endif

		lnPorcentajeDeIva = this.nPorcentajeIVA
		lnMontoIva = this.nImporteIva
		lnMontoNoGravado = this.nImporte
		lnMontoImpuestoInterno = this.nImporteImpuestoInterno
			
		if !llExisteIvaEnDetalleImpuestos and lnMontoNoGravadoAnterior # 0
			lnPorcentajeDeIva = lnPorcentajeIvaDelItem 
			lnMontoIva = lnMontoIva - lnMontoAnterior
			lnMontoNoGravado = lnMontoNoGravado - lnMontoNoGravadoAnterior
			lnMontoImpuestoInterno = lnMontoImpuestoInterno- lnMontoImpuestoInternoAnterior
		endif

		if ( !llExisteIvaEnDetalleImpuestos or !llEncontro ) and lnMontoNoGravado # 0
			with toDetalleImpuestos
				.LimpiarItem()
				.oItem.PorcentajeDeIva = lnPorcentajeDeIva
				.oItem.MontoDeIvaSinDescuento = lnMontoIva
				.oItem.MontoNoGravadoSinDescuento = lnMontoNoGravado 
				.oItem.MontoDeImpuestoInternoSinDescuento = lnMontoImpuestoInterno 
				.Actualizar()
			endwith
			llEncontro = .t.
		endif		

		if llEncontro
			this.oComponenteImpuestos.Calcular( toItem, toDetalleImpuestos )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RenumerarNroItemDetalleImpuestos( toDetalleImpuestos as Object ) as Void
		local lnNroItem as Integer, loItem as Object
		this.EliminarItemSinImpuesto( toDetalleImpuestos ) 
		lnNroItem = 1
		for each loItem in toDetalleImpuestos foxobject
			loItem.NroItem = lnNroItem
			lnNroItem = lnNroItem + 1
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarItemSinImpuesto( toDetalleImpuestos as Object ) as Void
		local lnNroItem as Integer, loItem as Object
		lnNroItem = 1
		for each loItem in toDetalleImpuestos foxobject
			with toDetalleImpuestos.Item[ lnNroItem ]
				if empty( .MontoDeIvaSinDescuento ) and empty( .MontoNoGravadoSinDescuento ) and empty( .MontoDeImpuestoInternoSinDescuento )
					toDetalleImpuestos.Remove( lnNroItem )
					this.EliminarItemSinImpuesto( toDetalleImpuestos ) 
					exit
				endif
			endwith
			lnNroItem = lnNroItem + 1
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarNumeroDeItemAlItemCero( tnItem as integer ) as Void
		local loItem as Object

		if this.oColImpuestos.Buscar( "0" )
			loItem = this.oColImpuestos.Item( "0" )
			this.oColImpuestos.quitar( "0" ) 
			this.oColImpuestos.Agregar( loItem, transform( tnItem ) )
		endif

		this.oComponenteImpuestos.AsignarNumeroDeItemAlItemCero( tnItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarImpuestos() as Void
		this.oComponenteImpuestos.CargarImpuestos()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarImpuestosComprobante( toDetalle as detalle OF detalle.prg ) as Void
		this.oComponenteImpuestos.InyectarImpuestosComprobante( toDetalle )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarItemEnColeccionDeImpuestos( tnNroItem as integer, tnPorcentajeIva as Float, tnImporteIva As Float, tnImporte as float, tnImpuestoInterno as Float, tnPercepcionIvaRG5329 as Integer ) as Void
		local loItemImpuestos as object

		** Se agrega en la coleccion interna de impuestos
		loItemImpuestos = newobject( "ItemColeccionImpuestos" )
		loItemImpuestos.nNroItem = tnNroItem
		loItemImpuestos.nPorcentaje = tnPorcentajeIVA
		loItemImpuestos.nMonto = tnImporteIva 
		loItemImpuestos.nMontoNoGravado = tnImporte
		loItemImpuestos.nMontoImpuestoInterno = tnImpuestoInterno
		loItemImpuestos.nPercepcionIvaRG5329 = tnPercepcionIvaRG5329

		this.oColImpuestos.agregar( loItemImpuestos, transform( tnNroItem ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VaciarColeccionDeImpuestos() as Void
		This.oColImpuestos.Remove( -1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LlenarColeccionDeImpuestos( toDetalle As object ) as Void
		local loItem As Object, lnMontoImpuestoInterno as Double
		this.VaciarColeccionDeImpuestos()
		for each loItem in toDetalle
			lnMontoImpuestoInterno = this.ObtenerMontoImpuestoInterno (loItem )
			This.AgregarItemEnColeccionDeImpuestos( loItem.NroItem , loItem.PorcentajeIva, loItem.MontoIva, loItem.Neto, lnMontoImpuestoInterno, loItem.PercepcionIvaRG5329 )
		EndFor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarAColeccionDeImpuestos( toComprobante as Object ) as Void
		This.RecalcularMontosConDescuentosYRecargos( toComprobante.ImpuestosDetalle )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSetearCalculando( tlValor as Boolean ) as Void
		*** Bindeado a la entidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestos( toDetalleComprobante as Detalle of detalle.prg, ;
			toDetalleImpuestos as detalle of detalle.prg ) as Void
		local lnIndice as Integer, loItem as Object, lnBackupIndice as Integer

		lnBackupIndice = 0
		for lnIndice = 1 to toDetalleComprobante.Count
			if !empty( toDetalleComprobante.Item[ lnIndice ].Articulo_pk )
				lnBackupIndice = lnIndice 
				this.PreProcesarItem( "", toDetalleComprobante.Item[ lnIndice ] )
				if lnIndice = toDetalleComprobante.Count
					toDetalleComprobante.CargarItem( lnIndice )
				endif
			else
				if lnBackupIndice > 0 and lnIndice != lnBackupIndice and lnIndice = toDetalleComprobante.Count
					toDetalleComprobante.CargarItem( lnBackupIndice )
				endif
			endif
		endfor
		
		&& Para sumarizar necesito estar parado en un item sino me suma el ultimo item 2 veces		
		if this.lEstaRecalculandoImpuestosAntesDeGrabar
			toDetalleComprobante.ActivarVerificacionDeCambiosAlSumarizar()		
		endif	
		toDetalleComprobante.Sumarizar()
		if this.lEstaRecalculandoImpuestosAntesDeGrabar
			if toDetalleComprobante.lHuboCambiosAlSumarizar 
				This.EventoRecalcularImpuestos()
			endif
		else
			This.EventoRecalcularImpuestos()
		endif
		
		this.oComponenteImpuestos.CargarImpuestos()
		this.oComponenteImpuestos.Recalcular( toDetalleComprobante )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoRecalcularImpuestos() as Void
		&& para que se bindeen
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarDescuentoGlobal( tnPorcentaje as Float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nPorcentajeDescuentoGlobal = tnPorcentaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarDescuentoGlobal2( tnPorcentaje as Float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nPorcentajeDescuentoGlobal2 = tnPorcentaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarDescuentoFinanciero( tnMontoBaseDelDescuento as float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nMontoBaseDescuentoFinanciero = tnMontoBaseDelDescuento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarDescuentoGlobal4( tnPorcentaje as Float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nPorcentajeDescuentoGlobal4 = tnPorcentaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarRecargoGlobal( tnPorcentaje as Float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nPorcentajeRecargoGlobal = tnPorcentaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarRecargoFinanciero( tnMontoBaseDelRecargo as float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nMontoBaseRecargoFinanciero = tnMontoBaseDelRecargo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarRecargoGlobal3( tnPorcentaje as Float, toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.nPorcentajeRecargoGlobal3 = tnPorcentaje
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function InyectarImpuestosDetalle( toImpuestoDetalle as detalle OF detalle.prg ) as Void
		this.oImpuestosDetalle = toImpuestoDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		this.oColImpuestos.Remove( -1 )
		this.oComponenteImpuestos.CargarImpuestos()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Imprimir( toColeccion as Object ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Preprocesar() as Boolean
		return this.lPreprocesar
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ChequearCorrectaInicializacion() as Void
		return this.cEstadoInicializado
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarImprimir( tnRespuestaSugerida as Integer ) as Void
		&&Evento para suscribirse desde la entidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function deboImprimir() as Boolean
		return .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeControlador( tcTexto as String ) as Void
		***A este metodo esta enlazada la entidad, y de esta el kontroler para terminar haciendo un goMensajes.enviarSinEspera( tcTexto )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarItemsDetalleArticulos( toDetalle as din_detalleFacturaFacturaDetalle of din_detalleFacturaFacturaDetalle.prg ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTotalComprobanteSinPersonalizar( tnTotal as float, tcSimboloMonetarioComprobante as String, tlSoloHayValoresTarjetaOPagoElectronico as Boolean ) As Boolean
		local llRetorno As Boolean
		llRetorno = .t.
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarFechaComprobanteFiscal( tdFecha as date ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BloquearCF() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ErrorAlGrabar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestosPorCambioDeNeto( tnTotalNeto as Integer, toDetalle as detalle OF detalle.prg )
		local lnCoeficienteNetoGravadoIVA as Number, lnCoeficienteParaAplicacionDePercepcionesIVA as Number
		lnCoeficienteNetoGravadoIVA = this.ObtenerCoeficienteNetoGravadoIVA()
		this.oComponenteImpuestos.CalcularImpuestoEnBaseAGravamen( this.oImpuestosDetalle, this.oColImpuestos )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCoeficienteNetoGravadoIVA() as Number
		local lnMontoNeto as Number, lnMontoNetoGravadoIVA as Number, lnCoeficienteNetoGravadoIVA as Number, lnI as integer
		lnCoeficienteNetoGravadoIVA = 0
		lnMontoNeto = 0
		lnMontoNetoGravadoIVA = 0
		for lnI = 1 to this.oImpuestosDetalle.Count
			lnMontoNeto = lnMontoNeto + this.oImpuestosDetalle.item[ lnI ].MontoNoGravadoSinDescuento
			if this.oImpuestosDetalle.item[ lnI ].PorcentajeDeIva > 0
				lnMontoNetoGravadoIVA = lnMontoNetoGravadoIVA + this.oImpuestosDetalle.item[ lnI ].MontoNoGravadoSinDescuento
			endif
		endfor
		if lnMontoNeto <> 0
			lnCoeficienteNetoGravadoIVA = lnMontoNetoGravadoIVA / lnMontoNeto
		endif
		return lnCoeficienteNetoGravadoIVA
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCoeficienteParaAplicacionDePercepcionesIVA() as Number
		local lnMontoNetoGravadoIVA as Number, lnMontoIVA as Number, lnCoeficiente as Number, lnI as integer
		lnCoeficiente = 1
		lnMontoNetoGravadoIVA = 0
		lnMontoIVA = 0
		for lnI = 1 to this.oImpuestosDetalle.Count
			if this.oImpuestosDetalle.item[ lnI ].PorcentajeDeIva > 0
				lnMontoNetoGravadoIVA = lnMontoNetoGravadoIVA + this.oImpuestosDetalle.item[ lnI ].MontoNoGravadoSinDescuento
				lnMontoIVA = lnMontoIVA + this.oImpuestosDetalle.item[ lnI ].MontoDeIvaSinDescuento
			endif
		endfor
		if lnMontoNetoGravadoIVA <> 0 and this.nIvainscriptos > 0
			lnCoeficiente = lnMontoIVA / lnMontoNetoGravadoIVA / ( this.nIvainscriptos / 100 )
		endif
		return lnCoeficiente
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HayArticulosGravadosConDiferentesPorcentajesDeIva() as Boolean
		local llPorcentajesDistintos as Boolean, lnI as integer, lnPorcentajeAnterior as Number
		llPorcentajesDistintos = .f.
		lnPorcentajeAnterior = 0
		for lnI = 1 to this.oImpuestosDetalle.Count
			if this.oImpuestosDetalle.item[ lnI ].PorcentajeDeIva > 0 and this.oImpuestosDetalle.item[ lnI ].MontoDeIva <> 0
				if lnPorcentajeAnterior <> 0 and lnPorcentajeAnterior <> this.oImpuestosDetalle.item[ lnI ].PorcentajeDeIva
					llPorcentajesDistintos = .t.
					exit
				endif
				lnPorcentajeAnterior = this.oImpuestosDetalle.item[ lnI ].PorcentajeDeIva
			endif
		endfor
		return llPorcentajesDistintos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTextoConPorcentajesDeIvaDelComprobante( tnPorcentajeDelImpuesto as Number ) as String
		local lcTexto as String, lnI as integer, lnPorcentajeAnterior as Number, lnCantidadDePorcentajesUsados as Number, lnPorcentajeProporcional as Number
		lcTexto = ""
		lnPorcentajeAnterior = 0
		lnCantidadDePorcentajesUsados = 0
		with this.oImpuestosDetalle
			for lnI = 1 to .Count
				if .item[ lnI ].PorcentajeDeIva > 0 and .item[ lnI ].MontoDeIva <> 0
					lnCantidadDePorcentajesUsados = lnCantidadDePorcentajesUsados + 1
					if lnPorcentajeAnterior <> .item[ lnI ].PorcentajeDeIva

						if this.nIvainscriptos <> 0
							lnPorcentajeProporcional = .item[ lnI ].PorcentajeDeIva / this.nIvainscriptos * tnPorcentajeDelImpuesto
						else
							lnPorcentajeProporcional = 0
						endif

						lcTexto = lcTexto + iif( empty( lcTexto ), "", ", " ) + alltrim( transform( lnPorcentajeProporcional, "###.##" ) +  + "%" )
					endif
					lnPorcentajeAnterior = .item[ lnI ].PorcentajeDeIva
				endif
			endfor
		endwith
		if lnCantidadDePorcentajesUsados > 1
			lcTexto = "(" + lcTexto + ")"
		endif
		if empty( lcTexto )
			lcTexto = "0.00%"
		endif
		return lcTexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerPorcentajeSumarizadoIIBB() as Integer 
		return this.oComponenteImpuestos.SumaPorcentajesIIBB
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SoltarControladorFiscal() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPrecio( toItem as Object ) as Number
		local lnPrecio as Number

		if this.MostrarImpuestos()
			lnPrecio = toItem.PrecioConImpuestos
		else
			lnPrecio = toItem.PrecioSinImpuestos
		endif
		
		return lnPrecio
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsItemRelacionadoASenia( toItem as Object ) as Boolean
		&& se implementa
		return .F.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPrecioDeItemRelacionadoASenia( toItem as Object ) as Number
		local lnRetorno as Number
		if toItem.TipoDeItem = 1 && Es item de emisión de senia.
			if this.MostrarImpuestos()
				lnRetorno = toItem.PrecioConImpuestos
			else
				lnRetorno = toItem.PrecioSinImpuestos
			endif
		else
			lnRetorno = toItem.Precio
		endif
		
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarDetalleArticulos( toDetalle as Din_detalleFacturaFacturadetalle of Din_detalleFacturaFacturadetalle.prg ) as Void
		local lnNroItem as Integer, lnCant as Integer, loItem as Object, lnItemActivo as Integer, lnMontoAux as Number
		with toDetalle
			lnItemActivo = .oItem.NroItem
			lnCant = .Count

			for lnNroItem = 1 to lnCant
				if .ValidarExistenciaCamposFijosItemPlano( lnNroItem )
				
					if .DebeCargarItemPorActualizarDetalleArticulos()
						.Cargaritem( lnNroItem )
						loItem = .oItem
					else
						loItem = .item[ lnNroItem ]
					endif
					if !this.EsItemRelacionadoASenia( loItem )
						loItem.UsarPrecioDeLista = .t.
					endif
					lnMontoAux = loItem.Monto
					.oItem.EventoCambioParticipantes( "ACTUALIZARPRECIO", loItem )
					.oItem.EventoComponenteFiscal( "ACTUALIZARPRECIO", loItem )
					.oItem.EventoHaCambiadoMonto( loItem, loItem.Cantidad, lnMontoAux)
					if .DebeCargarItemPorActualizarDetalleArticulos()
						.Actualizar()
					endif
				endif
			endfor
			if lnItemActivo > 0 and lnCant > 0
				.Cargaritem( lnItemActivo )
			endif
		endwith			
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularImpuestosDesdeItem( toItem ) as Void
		this.CalcularImpuestos( toItem, this.oImpuestosDetalle )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneImpuestosManuales() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearParametroPuntoDeVenta( tnPuntoDeVenta as Integer ) as Void
		this.nBocaDeExpendio = tnPuntoDeVenta
		if this.lEsComprobanteElectronico 
			if this.lExportacion
				this.SetearParametroPuntoDeVentaElectronicaExportacion( tnPuntoDeVenta )
			else
				if this.lEsUruguay 
					this.SetearParametroPuntoDeVentaElectronicaUruguay( tnPuntoDeVenta )
				else
					this.SetearParametroPuntoDeVentaElectronicaNacional( tnPuntoDeVenta )
				endif
			endif
		Else
			this.SetearParametroPuntoDeVentaLocal( tnPuntoDeVenta )
		EndIf	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearParametroPuntoDeVentaLocal( tnPuntoDeVenta as Integer ) as Void
		if goServicios.Parametros.felino.Numeraciones.BocaDeExpendio = 0
			goServicios.Parametros.felino.Numeraciones.BocaDeExpendio = tnPuntoDeVenta
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearParametroPuntoDeVentaElectronicaNacional( tnPuntoDeVenta as Integer ) as Void
		if goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Nacional.PuntoDeVenta = 0
			goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Nacional.PuntoDeVenta = tnPuntoDeVenta
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearParametroPuntoDeVentaElectronicaUruguay( tnPuntoDeVenta as Integer ) as Void
		local llModoContingenciaActivado as Boolean
		
		llModoContingenciaActivado = goRegistry.Felino.FEUruguayModoContingenciaActivado
		
		if goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Uruguay.PuntoDeVentaComprobantesElectronicos = 0 and !llModoContingenciaActivado 
			goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Uruguay.PuntoDeVentaComprobantesElectronicos = tnPuntoDeVenta
		endif
		if goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Uruguay.PuntoDeVentaComprobantesDeContingencia = 0 and llModoContingenciaActivado 
			goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Uruguay.PuntoDeVentaComprobantesDeContingencia = tnPuntoDeVenta
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearParametroPuntoDeVentaElectronicaExportacion( tnPuntoDeVenta as Integer ) as Void
		if goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Exportacion.PuntoDeVenta = 0
			goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Exportacion.PuntoDeVenta = tnPuntoDeVenta
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMontoImpuestoInterno( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Double
		return 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarMontoInternoEnItem( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalculaImpuestosInternos() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTasaEfectiva( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Float
		return 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPrecioSinimpuestos( toItem as Object, tnPrecio as Decimal ) as Decimal
		local lnResultado as Decimal
		if vartype( tnPrecio ) = "N" and tnPrecio # 0 and vartype( toItem ) = "O" and !isnull( toItem )
			lnPorcImpuestos = this.ObtenerPorcentajeIVA( toItem ) + this.ObtenerTasaEfectiva( toItem )
			lnResultado = tnPrecio * 100 / (100 + lnPorcImpuestos)
		else
			lnResultado = 0
		endif
		return lnResultado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularMontosConDescuentosYRecargos( toDetalleImpuestos as Object ) as Void
		toDetalleImpuestos.RecalcularMontosConDescuentosYRecargos()
	endfunc 

	*------------------lExisteControlador-----------------------------------------------------------------------
	function SetearFechaDeComprobante( tdFecha as Date ) as Void
		this.FechaDeComprobante = tdFecha
		this.oComponenteImpuestos.SetearFechaDeComprobante( tdFecha )
	endfunc 

	
enddefine

*--------------------------------- Definicion de Clases ----------------------------------
*-----------------------------------------------------------------------------------------
define class ItemColeccionImpuestos as Custom

	nNroItem = 0
	nPorcentaje = 0
	nMonto = 0
	nMontoNoGravado = 0 
	nMontoImpuestoInterno = 0
	nPercepcionIvaRG5329 = 0
enddefine

*-----------------------------------------------------------------------------------------
define class SituacionFiscalEmpresa as custom

	Inscripto = 0
	Monotributo = 0
	Exento = 0
	NoAlcanzado = 0
	lComprobantesAMonotributistas = .t.

	*-----------------------------------------------------------------------------------------
	function init
		with this
			.Inscripto = goRegistry.felino.SituacionFiscalEmpresaInscripto
			.Monotributo = goRegistry.felino.SituacionFiscalEmpresaMonotributo
			.Exento = goRegistry.felino.SituacionFiscalEmpresaExento
			.NoAlcanzado = goRegistry.felino.SituacionFiscalEmpresaNoAlcanzado
			.lComprobantesAMonotributistas = goParametros.Felino.GestionDeVentas.HabilitaComprobantesLetraAParaMonotributistasRG500321AFIP =< ;
			goServicios.librerias.ObtenerFecha()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarSituacionFiscal( tnSitFiscal As Integer ) as Boolean
		return inlist( tnSitFiscal, this.Inscripto, this.Monotributo, this.Exento, this.NoAlcanzado )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class Comprobantes as Custom	
	
	Permitido = 0
	A = 0
	B = 0
	C = 0
	E = 0
	M = 0
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		with this
			.Permitido = 1
			.A = goRegistry.felino.TipoDeComprobantePermitidoA
			.B = goRegistry.felino.TipoDeComprobantePermitidoB
			.C = goRegistry.felino.TipoDeComprobantePermitidoC
			.E = goRegistry.felino.TipoDeComprobantePermitidoE
			.M = goRegistry.felino.TipoDeComprobantePermitidoM
		endwith
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class TipoLista as custom

	IvaIncluido = 0
	MasIva = 0
	
	*-----------------------------------------------------------------------------------------
	function init
		with this
			.IvaIncluido = goRegistry.felino.ListaDePreciosIVAincluido
			.MasIva = goRegistry.felino.ListaDePreciosMasIVA
		endwith
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class TipoIVA as custom
	GravadoFijo = 0
	GravadoFijoReducido = 0
	NoGravado = 0
	GravadoLibre = 0

	*-----------------------------------------------------------------------------------------
	function init
		with this
			.GravadoFijo = goRegistry.felino.TipoDeIVAVentaGravadoFijo
			.GravadoFijoReducido = goRegistry.felino.TipoDeIVAVentaGravadoFijoReducido
			.NoGravado = goRegistry.felino.TipoDeIVAVentaNoGravado
			.GravadoLibre = goRegistry.felino.TipoDeIVAVentaGravadoLibre
		endwith
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class SituacionFiscal as custom

	Inscripto = 0
	ConsumidorFinal = 0
	InscriptoNoResp = 0
	Exento = 0
	Monotributo = 0
	NoAlcanzado = 0

	*-----------------------------------------------------------------------------------------
	function init
		with this
			.Inscripto = goRegistry.felino.SituacionFiscalClienteInscripto
			.ConsumidorFinal = goRegistry.felino.SituacionFiscalClienteConsumidorFinal
			.Exento = goRegistry.felino.SituacionFiscalClienteExento
			.InscriptoNoResp = goRegistry.felino.SituacionFiscalClienteInscriptoNoResponsable
			.Monotributo = goRegistry.felino.SituacionFiscalClienteMonotributo
			.NoAlcanzado = goRegistry.felino.SituacionFiscalClienteNoAlcanzado
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarSituacionFiscal( tnSitFiscal As Integer ) as Boolean
		return inlist( tnSitFiscal, 0, this.Inscripto, this.ConsumidorFinal, this.Exento, this.Monotributo, this.InscriptoNoResp, this.NoAlcanzado  )
	endfunc 

enddefine
