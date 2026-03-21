define class ColaboradorRetenciones as ZooSession of ZooSession.prg

	#if .f.
		local this as ColaboradorRetenciones as ColaboradorRetenciones.prg
	#endif

	protected oDatosFiscales, oImpuesto, oImpuestoRetencion, oComprobante, oColEsquemaFiscal, oColEsquema, ;
			oComprobanteDeRetencionesIIBB, oComprobanteDeRetencionesIVA, oComprobanteDeRetencionesGanancias, oComprobanteDeRetencionesSUSS

	oDatosFiscales = null
	oImpuesto = null
	oComprobanteDeRetencionesIIBB = null
	oComprobanteDeRetencionesIVA = null
	oComprobanteDeRetencionesGanancias = null
	oComprobanteDeRetencionesSUSS = null
	oImpuestoRetencion = null
	oComprobante = null
	lEstaSeteadoParaHacerRetenciones = .f.
	lDebeRetenerRegimenGeneral = .f.
	lDebeRetenerRG1575 = .f.
	lDebeRetenerRG2616 = .f.

	oColEsquemaFiscal = null
	oColEsquema = null
	cCodigoDatoFiscal = ""
	cCodigoProveedor = ""
	JurisdiccionSiempreAplica = ""
	dFechaComprobante = {}
	oColaboradorSireWS = null

	*-----------------------------------------------------------------------------------------
	function oDatosFiscales_Access() as Object
		if !this.lDestroy and vartype( this.oDatosFiscales ) # "O"
			if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
				this.oDatosFiscales = _screen.Zoo.InstanciarEntidad( "DatosFiscales" )
				try
					this.oDatosFiscales.Codigo = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
					this.JurisdiccionSiempreAplica = this.oDatosFiscales.RetPercSiempreSegunJurisdiccion
				catch to loError
					this.JurisdiccionSiempreAplica = ""
					if !empty(goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar)
						loExcepcion = Newobject( "ZooException", "ZooException.prg" )
						lcMensaje = "El dato fiscal ("  + alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar ) +  ") configurado en parámetros no existe." && " No se usará ningún esquema."
						loExcepcion.Message = lcMensaje
						loExcepcion.errorNo = 9999
						loExcepcion.Details = "Error de configuración del esquema de datos fiscales en parámetros."
						loExcepcion.Grabar( loExcepcion )
						loExcepcion = null
					endif
					goServicios.Errores.LevantarExcepcion( loError )
				endtry
			endif
		endif
		return this.oDatosFiscales
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oImpuesto_Access() as Object
		if this.lDestroy
		else
			if ( !vartype( this.oImpuesto ) = 'O' or isnull( this.oImpuesto ) )
				this.oImpuesto = _Screen.zoo.instanciarentidad( 'Impuesto' )
			endif
		endif
		return this.oImpuesto
	endfunc

	*-----------------------------------------------------------------------------------------
	function oComprobanteDeRetencionesIIBB_Access() as Object
		if !this.lDestroy and vartype( this.oComprobanteDeRetencionesIIBB ) # "O"
			this.oComprobanteDeRetencionesIIBB = _screen.Zoo.InstanciarEntidad( "ComprobanteDeRetenciones" )
		endif
		return this.oComprobanteDeRetencionesIIBB
	endfunc

	*-----------------------------------------------------------------------------------------
	function oComprobanteDeRetencionesIVA_Access() as Object
		if !this.lDestroy and vartype( this.oComprobanteDeRetencionesIVA ) # "O"
			this.oComprobanteDeRetencionesIVA = _screen.Zoo.InstanciarEntidad( "ComprobanteDeRetencionesIVA" )
		endif
		return this.oComprobanteDeRetencionesIVA
	endfunc

	*-----------------------------------------------------------------------------------------
	function oComprobanteDeRetencionesGanancias_Access() as Object
		if !this.lDestroy and vartype( this.oComprobanteDeRetencionesGanancias ) # "O"
			this.oComprobanteDeRetencionesGanancias = _screen.Zoo.InstanciarEntidad( "ComprobanteDeRetencionesGanancias" )
		endif
		return this.oComprobanteDeRetencionesGanancias
	endfunc

	*-----------------------------------------------------------------------------------------
	function oComprobanteDeRetencionesSUSS_Access() as Object
		if !this.lDestroy and vartype( this.oComprobanteDeRetencionesSUSS ) # "O"
			this.oComprobanteDeRetencionesSUSS = _screen.Zoo.InstanciarEntidad( "ComprobanteDeRetencionesSUSS" )
		endif
		return this.oComprobanteDeRetencionesSUSS
	endfunc

	*-----------------------------------------------------------------------------------------
	function oImpuestoRetencion_Access() as Object
		if !this.lDestroy and vartype( this.oImpuestoRetencion ) # "O"
			this.oImpuestoRetencion = _screen.Zoo.CrearObjeto( "ImpuestoRetencion" )
		endif
		return this.oImpuestoRetencion
	endfunc

	*-----------------------------------------------------------------------------------------
	function oComprobante_Access() as Object
		if !this.lDestroy and vartype( this.oComprobante ) # "O"
			this.oComprobante = _screen.Zoo.CrearObjeto( "ent_comprobanteDeCompras" )
		endif
		return this.oComprobante
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColEsquema_Access() as Collection
		if this.lDestroy
		else
			if ( !vartype( this.oColEsquema ) = 'O' or isnull( this.oColEsquema ) )
				this.oColEsquema = _screen.zoo.CrearObjeto( "ZooColeccion" )
			endif
		endif
		return this.oColEsquema
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColEsquemaFiscal_Access() as Collection
		if this.lDestroy
		else
			if ( !vartype( this.oColEsquemaFiscal ) = 'O' or isnull( this.oColEsquemaFiscal ) )
				this.oColEsquemaFiscal = _screen.zoo.CrearObjeto( "ZooColeccion" )
			endif
		endif
		return this.oColEsquemaFiscal
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarComprobante( toComprobante as ent_ComprobanteDeCompras of ent_ComprobanteDeCompras.prg ) as Void
		this.oComprobante = toComprobante
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.lDestroy = .t.
		if vartype( this.oDatosFiscales ) = "O" and !isnull( this.oDatosFiscales )
			this.oDatosFiscales.lDestroy = .t.
			this.oDatosFiscales.Release()
		endif
		if vartype( this.oImpuesto ) = "O" and !isnull( this.oImpuesto )
			this.oImpuesto.lDestroy = .t.
			this.oImpuesto.Release()
		endif
		if vartype( this.oComprobanteDeRetencionesIIBB ) = "O" and !isnull( this.oComprobanteDeRetencionesIIBB )
			this.oComprobanteDeRetencionesIIBB.lDestroy = .t.
			this.oComprobanteDeRetencionesIIBB.Release()
		endif
		if vartype( this.oComprobanteDeRetencionesIVA ) = "O" and !isnull( this.oComprobanteDeRetencionesIVA )
			this.oComprobanteDeRetencionesIVA.lDestroy = .t.
			this.oComprobanteDeRetencionesIVA.Release()
		endif
		if vartype( this.oComprobanteDeRetencionesGanancias ) = "O" and !isnull( this.oComprobanteDeRetencionesGanancias )
			this.oComprobanteDeRetencionesGanancias.lDestroy = .t.
			this.oComprobanteDeRetencionesGanancias.Release()
		endif
		if vartype( this.oComprobanteDeRetencionesSUSS ) = "O" and !isnull( this.oComprobanteDeRetencionesSUSS )
			this.oComprobanteDeRetencionesSUSS.lDestroy = .t.
			this.oComprobanteDeRetencionesSUSS.Release()
		endif
		if vartype( this.oImpuestoRetencion ) = "O" and !isnull( this.oImpuestoRetencion )
			this.oImpuestoRetencion.lDestroy = .t.
			this.oImpuestoRetencion.Release()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarConfiguracionRetenciones() as Void
		local loColEsquema as zoocoleccion OF zoocoleccion.prg
		if empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			this.lEstaSeteadoParaHacerRetenciones = .f.
			this.lDebeRetenerRegimenGeneral = .f.
			this.lDebeRetenerRG1575 = .f.
			this.lDebeRetenerRG2616 = .f.
			this.cCodigoDatoFiscal = ""
			this.cCodigoProveedor = ""
			this.JurisdiccionSiempreAplica = ""
		else
			this.lEstaSeteadoParaHacerRetenciones = .f.
			this.lDebeRetenerRegimenGeneral = .f.
			this.lDebeRetenerRG1575 = .f.
			this.lDebeRetenerRG2616 = .f.

			if alltrim(this.cCodigoDatoFiscal) # alltrim(goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar)
				this.oColEsquemaFiscal = this.ObtenerColeccionDeRetencionesDeDatosFiscales()
				this.cCodigoDatoFiscal = alltrim(goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar)
				if type( "this.oComprobante.Proveedor" ) = "O" and !isnull(this.oComprobante.Proveedor)
					this.oColEsquema = this.ObtenerColeccionDeRetencionesSegunProveedor( this.oComprobante.Proveedor ) &&_PK )
					this.cCodigoProveedor = alltrim(this.oComprobante.Proveedor_PK)
				else
					this.oColEsquema = this.ObtenerColeccionDeRetencionesBase()
					this.cCodigoProveedor = ""
				endif
			else
				if alltrim(this.cCodigoProveedor) # alltrim(this.oComprobante.Proveedor_PK) or this.dFechaComprobante # this.oComprobante.Fecha
					this.oColEsquema = this.ObtenerColeccionDeRetencionesSegunProveedor( this.oComprobante.Proveedor ) && _PK )
					this.cCodigoProveedor = alltrim(this.oComprobante.Proveedor_PK)
					this.dFechaComprobante = this.oComprobante.Fecha
				endif
			endif

			for each loImpuesto in this.oColEsquema
				this.oImpuesto.Codigo = loImpuesto.Codigo
				if this.oImpuesto.EsRetencionGeneral()
					this.lDebeRetenerRegimenGeneral = .t.
				endif
				if this.oImpuesto.EsRetencionRG1575()
					this.lDebeRetenerRG1575 = .t.
				endif
				if this.oImpuesto.EsRetencionRG2616()
					this.lDebeRetenerRG2616 = .t.
				endif
			next

			this.lEstaSeteadoParaHacerRetenciones = this.lDebeRetenerRegimenGeneral or this.lDebeRetenerRG1575 or this.lDebeRetenerRG2616
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaSeteadoParaHacerRetenciones() as Boolean

		this.ActualizarConfiguracionRetenciones()
		return this.lEstaSeteadoParaHacerRetenciones
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerImpuestoRetencion( tcTipo as String, toOrdenDePago as Object ) as Object
		local loRetorno as Object
		do case
			case tcTipo = "IIBB"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoRetencionIIBB", , toOrdenDePago )
			case tcTipo = "GANANCIAS"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoRetencionGanancias", , toOrdenDePago )
			case tcTipo = "IVA"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoRetencionIVA", , toOrdenDePago )
			case tcTipo = "SUSS"
				loRetorno = _screen.zoo.CrearObjeto( "ImpuestoRetencionSuss", , toOrdenDePago )
		endcase
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsAgenteDeRetencion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.EsAgenteDeRetencionSegunTipoDeImpuesto( "IIBB" )
		llRetorno = llRetorno or this.EsAgenteDeRetencionSegunTipoDeImpuesto( "GANANCIAS" )
		llRetorno = llRetorno or this.EsAgenteDeRetencionSegunTipoDeImpuesto( "IVA" )
		llRetorno = llRetorno or this.EsAgenteDeRetencionSegunTipoDeImpuesto( "SUSS" )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsAgenteDeRetencionSegunTipoDeImpuesto( tcTipo as String ) as Boolean
		return this.TieneDatosFiscalesConfiguradoComoParaRetener( tcTipo, .f. )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeActuarComoAgenteDeRetencion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.DebeActuarComoAgenteDeRetencionEnTipoDeImpuesto( "IVA" )
		llRetorno = llRetorno or this.DebeActuarComoAgenteDeRetencionEnTipoDeImpuesto( "GANANCIAS" )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeActuarComoAgenteDeRetencionEnTipoDeImpuesto( tcTipo as String ) as Boolean
		return this.TieneDatosFiscalesConfiguradoComoParaRetener( tcTipo, .t. )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneDatosFiscalesConfiguradoComoParaRetener( tcTipoImpuesto as String, tlBuscaImpuestosSeteadosParaComprobantesM as Boolean ) as Boolean
		local llRetorno as Boolean, loError as Object
		llRetorno = .f.
		if this.EstaSeteadoElParametroDeDatosFiscales()
			try
*!*					this.oDatosFiscales.Codigo = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
				this.JurisdiccionSiempreAplica = this.oDatosFiscales.RetPercSiempreSegunJurisdiccion
			catch to loError
				this.JurisdiccionSiempreAplica = ""
				if !empty(goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar)
					loExcepcion = Newobject( "ZooException", "ZooException.prg" )
					lcMensaje = "El dato fiscal ("  + alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar ) +  ") configurado en parámetros no existe." && " No se usará ningún esquema."
					loExcepcion.Message = lcMensaje
					loExcepcion.errorNo = 9999
					loExcepcion.Details = "Error de configuración del esquema de datos fiscales en parámetros."
					loExcepcion.Grabar( loExcepcion )
					loExcepcion = null
				endif
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
			llRetorno = this.ExisteImpuestoDeRetencionSeteadoEnDatosFiscales( tcTipoImpuesto, tlBuscaImpuestosSeteadosParaComprobantesM )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstaSeteadoElParametroDeDatosFiscales() as Boolean
		return !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteImpuestoDeRetencionSeteadoEnDatosFiscales( tcTipoImpuesto as String, tlBuscaImpuestosSeteadosParaComprobantesM as Boolean ) as Boolean
		local llRetorno as Boolean, loItem as Object, lcFiltroSegunTipoDeComprobantes as String
		llRetorno = .f.
		if tlBuscaImpuestosSeteadosParaComprobantesM
			lcFiltroSegunTipoDeComprobantes = " loItem.RG1575Porcentaje > 0 "
		else
			lcFiltroSegunTipoDeComprobantes = " ( loItem.Porcentaje > 0 or loItem.Escala ) "
		endif
		if vartype( this.oDatosFiscales ) = "O"
			for each loItem in this.oDatosFiscales.PerceIIBB
				if upper( alltrim( loItem.Aplicacion ) ) == "RTN" ;
				and upper( alltrim( loItem.Tipo_PK ) ) == alltrim( tcTipoImpuesto ) ;
				and &lcFiltroSegunTipoDeComprobantes
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadComprobanteDeRetenciones( tcTipoImpuesto as String ) as Object
		local loEntidad as Object, lcNombreEntidad as String
		lcNombreEntidad = this.ObtenerNombreEntidadComprobanteDeRetenciones( tcTipoImpuesto )
		loEntidad = _screen.Zoo.InstanciarEntidad( lcNombreEntidad )
		return loEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreEntidadComprobanteDeRetenciones( tcTipoImpuesto as String ) as String
		local lcNombreEntidad as String
		lcNombreEntidad = ""
		do case
			case tcTipoImpuesto = 'IIBB'
				lcNombreEntidad = "ComprobanteDeRetenciones"
			case tcTipoImpuesto = 'IVA'
				lcNombreEntidad = "ComprobanteDeRetencionesIva"
			case tcTipoImpuesto = 'GANANCIAS'
				lcNombreEntidad = "ComprobanteDeRetencionesGanancias"
			case tcTipoImpuesto = 'SUSS'
				lcNombreEntidad = "ComprobanteDeRetencionesSuss"
		endcase
		return lcNombreEntidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerComprobanteDeRetencionesInstanciado( tcTipoImpuesto as String ) as Object
		local loEntidad as Object, lcNombrePropiedad as String
		lcNombrePropiedad = "this.oComprobanteDeRetenciones" + alltrim( tcTipoImpuesto )
		loEntidad = &lcNombrePropiedad
		return loEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeTipoImpuesto( tcTipoImpuesto as String ) as String
		local loEntidad as Object, lcDescripcion as String
		lcDescripcion = ""
		if !empty( tcTipoImpuesto )
			loEntidad = _screen.Zoo.InstanciarEntidad( "TipoImpuesto" )
			try
				loEntidad.Codigo = tcTipoImpuesto
				lcDescripcion = alltrim( loEntidad.Descripcion )
			catch
			endtry
			loEntidad.Release()
		endif
		return lcDescripcion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ImprimirComprobanteDeRetenciones( tcTipoImpuesto as String, tcCodigoComprobante as String, tlDespuesDeGrabar as Boolean, tlEsNuevo as Boolean, lnNroItem as integer ) as Boolean
		local llRetorno as Boolean, loComprobanteDeRetenciones as Object, loError as Exception
		llRetorno = .t.
		local loImpuesto as object
		
		loComprobanteDeRetenciones = this.ObtenerComprobanteDeRetencionesInstanciado( tcTipoImpuesto )
		
		with LoComprobanteDeRetenciones
			try
				.lNuevo = .f.
				.Codigo = tcCodigoComprobante
					
					if !empty(lnNroItem) and alltrim( tcTipoImpuesto ) = "IIBB" and .impuestosdetalle.count > 0
						local lnI as integer
						for lnI = 1 to .impuestosdetalle.count
							if alltrim( .impuestosdetalle.item [ lnI ].jurisdicciondescripcion ) = ""
								local loImpuesto as object
								loImpuesto = this.ObtenerImpuesto( .impuestosdetalle.item[ lnI ].codimp_pk )
								.impuestosdetalle.item [ lnI ].jurisdicciondescripcion = loImpuesto.Jurisdiccion.Descripcion
								loImpuesto.release()
								&& Se realiza la escritura a la fuerza dado que las retenciones de IIBB manuales no traen cargada la Jurisdiccion.
							endif
						endfor
							
					endif
					
					
				.lNuevo = tlEsNuevo
				
				if tlDespuesDeGrabar
					llRetorno = .ImprimirDespuesDeGrabar()
				else
					llRetorno = .Imprimir()
				endif
			catch to loError
				goServicios.Mensajes.Advertir( loError )
			endtry
		endwith
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipDesdeAtributos( tcCodigoImpuesto as String, toItemImpuestoComprobante as Object ) as string
		local lcTexto as String, loItemAuxiliarDatosRetencion as Object

		loItemAuxiliarDatosRetencion = this.oImpuestoRetencion.ObtenerItemAuxiliarDatosRetencion()
		this.oImpuesto.Codigo = tcCodigoImpuesto

		with loItemAuxiliarDatosRetencion
			.CodImp = tcCodigoImpuesto
			.CodImpDetalle = toItemImpuestoComprobante.CodImpDetalle
			.TipoImpuesto = toItemImpuestoComprobante.TipoImpuestoCDR
			.Jurisdiccion = this.oImpuesto.Jurisdiccion_pk
			.Resolucion = this.oImpuesto.Resolucion
			.Porcentaje = toItemImpuestoComprobante.Porcentaje
			.PorcentajeDeBase = toItemImpuestoComprobante.PorcentajeBase
			.ConvenioMultilateral = toItemImpuestoComprobante.ConvenioMultilateral
			.PorcentajeDeConvenio = toItemImpuestoComprobante.PorcentajeConvenio
			.MontoBase = toItemImpuestoComprobante.MontoBase

			.MinimoNoImp = this.oImpuesto.Monto
			.AcumuladoPagos = toItemImpuestoComprobante.AcumuladoPagos
			.AcumuladoRetenciones = toItemImpuestoComprobante.AcumuladoRetenciones
			.EscalaMontoFijo = toItemImpuestoComprobante.EscalaMontoFijo
			.EscalaPorcentaje = toItemImpuestoComprobante.EscalaPorcentaje
			.EscalaSobreExcedente = toItemImpuestoComprobante.EscalaSobreExcedente

			.MontoRetencion = toItemImpuestoComprobante.Monto

			.esRG2616AR = toItemImpuestoComprobante.esRG2616AR
			.esRG1575AR = toItemImpuestoComprobante.esRG1575AR

			.CertificadoSire = toItemImpuestoComprobante.CertificadoSire
			.CodSeguridadSIRE = toItemImpuestoComprobante.CodSeguridadSIRE
		endwith

		lcTexto = this.FormatearTextoParaTooltip( loItemAuxiliarDatosRetencion )
		return lcTexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipDesdeComprobanteDeRetenciones( tcCodigoImpuesto as String, tcCodigoCDR as String ) as String
		local lcTexto as String, loCDR as Object, lcTipoImpuesto as String

		this.oImpuesto.Codigo = tcCodigoImpuesto
		lcTipoImpuesto = this.oImpuesto.Tipo_pk

		loCDR = this.ObtenerEntidadComprobanteDeRetenciones( lcTipoImpuesto )
		loCDR.Codigo = tcCodigoCDR

		lcTexto = this.ObtenerTooltipDeImpuestoEnComprobanteDeRetenciones( tcCodigoImpuesto, loCDR )
		return lcTexto
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipDeImpuestoEnComprobanteDeRetenciones( tcCodigoImpuesto as String, toComprobanteDeRetenciones as Object ) as String
		local lcTexto as String, loItemAuxiliarDatosRetencion as Object, loCDR as Object, lcTipoImpuesto as String, lnI as Integer, lcCodigoCDR as String

		loItemAuxiliarDatosRetencion = this.oImpuestoRetencion.ObtenerItemAuxiliarDatosRetencion()

		loCDR = toComprobanteDeRetenciones
		lcCodigoCDR = loCDR.codigo
		for lnI = 1 to loCDR.ImpuestosDetalle.Count
			if loCDR.ImpuestosDetalle.Item[lnI].CodImp_pk == tcCodigoImpuesto

				with loItemAuxiliarDatosRetencion
					.CodImp = loCDR.ImpuestosDetalle.Item[lnI].CodImp_PK
					.CodImpDetalle = loCDR.ImpuestosDetalle.Item[lnI].CodImpDetalle
					.TipoImpuesto = loCDR.TipoImpuesto_PK
					.Jurisdiccion = loCDR.ImpuestosDetalle.Item[lnI].Jurisdiccion
					.Resolucion = loCDR.ImpuestosDetalle.Item[lnI].Resolucion
					.Porcentaje = loCDR.ImpuestosDetalle.Item[lnI].Porcentaje
					.PorcentajeDeBase = loCDR.ImpuestosDetalle.Item[lnI].PorcentajeDeBase
					.ConvenioMultilateral = loCDR.ImpuestosDetalle.Item[lnI].ConvenioMultilateral
					.PorcentajeDeConvenio = loCDR.ImpuestosDetalle.Item[lnI].PorcentajeDeConvenio
					.MontoBase = loCDR.ImpuestosDetalle.Item[lnI].MontoBase

					.MinimoNoImp = loCDR.ImpuestosDetalle.Item[lnI].MinimoNoImp
					.AcumuladoPagos = loCDR.ImpuestosDetalle.Item[lnI].AcumuladoPagos
					.AcumuladoRetenciones = loCDR.ImpuestosDetalle.Item[lnI].AcumuladoRetenciones
					.EscalaMontoFijo = loCDR.ImpuestosDetalle.Item[lnI].EscalaMontoFijo
					.EscalaPorcentaje = loCDR.ImpuestosDetalle.Item[lnI].EscalaPorcentaje
					.EscalaSobreExcedente = loCDR.ImpuestosDetalle.Item[lnI].EscalaSobreExcedente

					.MontoRetencion = loCDR.ImpuestosDetalle.Item[lnI].Monto

					.esRG2616AR = loCDR.ImpuestosDetalle.Item[lnI].esRG2616AR
					.esRG1575AR = loCDR.ImpuestosDetalle.Item[lnI].esRG1575AR

					.CertificadoSire = iif( .TipoImpuesto = "IVA", this.oColaboradorSireWS.ObtenerNumeroCertificadoSireParaTooltipOP( lcCodigoCDR ), "" )

				endwith

				exit
			endif
		endfor

		lcTexto = this.FormatearTextoParaTooltip( loItemAuxiliarDatosRetencion )
		return lcTexto
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FormatearRenglon( tcTexto as String, tnNumero as Number, tcMascara as String ) as String
		local lcRenglon as String, lnLongitudTexto as Integer, lnLongitudNumero as Integer
		lnLongitudTexto = 24
		lnLongitudNumero = 16
		lcRenglon = padr( tcTexto, lnLongitudTexto, " " ) + padl( alltrim( transform( tnNumero, tcMascara ) ), lnLongitudNumero, " " )
		return lcRenglon
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUltimaOrdenDePagoDelProveedor( tcProveedor as String, tnNumero as Integer, tnPtoVenta as integer ) as Boolean
		local llRetorno as Boolean, loEntidad as Object
		llRetorno = .f.
		lcCursor = sys( 2015 )
		loEntidad = _Screen.Zoo.InstanciarEntidad( "OrdenDePago" )
		lcTabla = loEntidad.oAD.cTablaPrincipal
		lcNumero = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Numero' )
		lcProveedor = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Proveedor' )
		lcPuntoDeVenta = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'PuntoDeVenta' )
		loEntidad.Release()
		try
			lcSentencia = "Select top 1 ( " + lcPuntoDeVenta + " * 1000000000) + " + lcNumero + " UltimoNro, " + lcPuntoDeVenta + " as pto, " + lcNumero + " as nro"
			lcSentencia = lcSentencia + " From <<esquema>>." + lcTabla + " "
			lcSentencia = lcSentencia + " Where " + lcProveedor + " = '" + tcProveedor + "' order by faltafw desc, haltafw desc"
			goServicios.Datos.EjecutarSentencias(lcSentencia, lcTabla, '', lcCursor, this.DataSessionId)
			lnUltimaNro = iif(isnull(&lcCursor..nro),0.00,&lcCursor..nro)
			lnUltimaPto = iif(isnull(&lcCursor..pto),0.00,&lcCursor..pto)
			llRetorno = ( tnNumero = lnUltimaNro ) and ( tnPtoVenta = lnUltimaPto )
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimaOrdenDePagoDelProveedor( tcProveedor as String ) as Integer
		local lnRetorno as Integer, loEntidad as Object
		llRetorno = 0
		lcCursor = sys( 2015 )
		loEntidad = _Screen.Zoo.InstanciarEntidad( "OrdenDePago" )
		lcTabla = loEntidad.oAD.cTablaPrincipal
		lcNumero = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Numero' )
		lcProveedor = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Proveedor' )
		lcPuntoDeVenta = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'PuntoDeVenta' )
		loEntidad.Release()
		try
			lcSentencia = "Select top 1 ( " + lcPuntoDeVenta + " * 1000000000) + " + lcNumero + " UltimoNro, " + lcPuntoDeVenta + ", " + lcNumero
			lcSentencia = lcSentencia + " From <<esquema>>." + lcTabla + " "
			lcSentencia = lcSentencia + " Where " + lcProveedor + " = '" + tcProveedor + "' order by faltafw desc, haltafw desc"
			goServicios.Datos.EjecutarSentencias(lcSentencia, lcTabla, '', lcCursor, this.DataSessionId)
			lnRetorno = iif(isnull(&lcCursor..UltimoNro),0.00,&lcCursor..UltimoNro)
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeOrdenDePagoAnteriorDelProveedor( tcProveedor as String, tnNumero as Integer ) as Date
		local ldRetorno as Date, loEntidad as Object
		ldRetorno = {}
		lcCursor = sys( 2015 )
		loEntidad = _Screen.Zoo.InstanciarEntidad( "OrdenDePago" )
		lcTabla = loEntidad.oAD.cTablaPrincipal
		lcNumero = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Numero' )
		lcProveedor = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Proveedor' )
		lcFecha = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Fecha' )
		loEntidad.Release()
		try
			lcSentencia = "Select " + lcFecha + " UltimaFecha From <<esquema>>." + lcTabla + " "
			lcSentencia = lcSentencia + " Where " + lcProveedor + " = '" + tcProveedor + "'"
			lcSentencia = lcSentencia + " and " + lcNumero + " in (Select max(" + lcNumero + ") "
			lcSentencia = lcSentencia + " From <<esquema>>." + lcTabla + " where " + lcProveedor + " = '" + tcProveedor + "'"
			lcSentencia = lcSentencia + " and " + lcNumero + " < " + str(tnNumero) + ")"
			goServicios.Datos.EjecutarSentencias(lcSentencia, lcTabla, '', lcCursor, this.DataSessionId)
			ldRetorno = iif(isnull(&lcCursor..UltimaFecha),0.00,&lcCursor..UltimaFecha)
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
		ldRetorno = iif( vartype( ldRetorno ) = 'T', ttod( ldRetorno ), ldRetorno)

		return ldRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaOrdenDePagoDelProveedor( tcProveedor as String ) as Date
		local ldRetorno as Date, loEntidad as Object
		ldRetorno = {}
		lcCursor = sys( 2015 )
		loEntidad = _Screen.Zoo.InstanciarEntidad( "OrdenDePago" )
		lcTabla = loEntidad.oAD.cTablaPrincipal
		lcProveedor = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Proveedor' )
		lcFecha = lcTabla + "." + loEntidad.oAD.ObtenerCampoEntidad( 'Fecha' )
		loEntidad.Release()
		try
			lcSentencia = "Select max(" + lcFecha + ") UltimaFecha From <<esquema>>." + lcTabla + " "
			lcSentencia = lcSentencia + " Where " + lcProveedor + " = '" + tcProveedor + "'"
			goServicios.Datos.EjecutarSentencias(lcSentencia, lcTabla, '', lcCursor, this.DataSessionId)
			ldRetorno = iif(isnull(&lcCursor..UltimaFecha), {},&lcCursor..UltimaFecha)
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
		ldRetorno = iif( vartype( ldRetorno ) = 'T', ttod( ldRetorno ), ldRetorno)

		return ldRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarAccionesAutomatizadasDeUnComprobanteDeRetencion( tcTipoImpuesto as String, tcCodigoComprobante as String ) as Void
		local loComprobanteDeRetenciones as Object, loError as Exception, llPudoSetearElCodigoDeComprobante as Boolean, llEsNuevo as Boolean, loEx as Object, llImprimir as Boolean

		llImprimir = .t.
		loComprobanteDeRetenciones = this.ObtenerComprobanteDeRetencionesInstanciado( tcTipoImpuesto )
		llPudoSetearElCodigoDeComprobante = .f.
		try
			llEsNuevo = loComprobanteDeRetenciones.lNuevo
			loComprobanteDeRetenciones.lNuevo = .f.
			loComprobanteDeRetenciones.Codigo = tcCodigoComprobante
			loComprobanteDeRetenciones.lNuevo = llEsNuevo

			llPudoSetearElCodigoDeComprobante = .t.
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			loEx.Grabar( loError )
			goServicios.Mensajes.Advertir( "No se pudieron ejecutar las acciones automáticas del comprobante de retención de tipo " + alltrim( tcTipoImpuesto ) + "." )
		endtry

		if llPudoSetearElCodigoDeComprobante
		
			with loComprobanteDeRetenciones
				.AccionesAutomatizadas( 'DespuesDeGrabar' )
				goServicios.Impresion.GenerarPDFsAlGrabarEntidad( loComprobanteDeRetenciones )
				llImprimir = .ImprimirDespuesDeGrabar()
				if llImprimir and .lHabilitaEnviarAlGrabar and .lTieneDiseñosParaEnviarMail
					.EnviarMailAlGrabar()
				endif
			endwith
				
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarPagoSegunComprobantes( tnMontoAPagar as Decimal, toInformacion as Object ) as Boolean
		local llRetorno as Boolean, lnCantidad as Integer
		llRetorno = .t.

		if this.lDebeRetenerRG1575 and this.lDebeRetenerRegimenGeneral and this.oComprobante.Proveedor.SituacionFiscal.EsResponsableInscripto() and ;
			this.oComprobante.OrdenDePagoDetalle.oItem.NroItem # 0 and this.oComprobante.OrdenDePagoDetalle.oItem.Letra = "M"
			for each loItemImpuesto in this.oColEsquema FOXOBJECT
				if loItemImpuesto.RG1575MontoMinimoRetencion # 0
					loCalculoTipo = 0
					for lnItem = 1 to this.oComprobante.OrdenDePagoDetalle.Count
						if lnItem = this.oComprobante.OrdenDePagoDetalle.oItem.NroItem
							loItemDetalle = this.oComprobante.OrdenDePagoDetalle.oItem
						else
							loItemDetalle = this.oComprobante.OrdenDePagoDetalle.Item[lnItem]
						endif
						lnMonto = iif(lnItem = this.oComprobante.OrdenDePagoDetalle.oItem.NroItem, tnMontoAPagar , loItemDetalle.Monto)
						if lnMonto # 0
							if loItemDetalle.TotalComprobanteSinImpuestos > loItemImpuesto.RG1575MontoMinimoRetencion
								if loCalculoTipo = 1
									llRetorno = .f.
									toInformacion.Agregarinformacion( "Error al aplicar retención de " + loItemImpuesto.Tipo_PK + ". No puede generar retenciones para distintos regimenes." )
									exit
								else
									loCalculoTipo = 2
								endif
							else
								if loCalculoTipo = 2
									llRetorno = .f.
									toInformacion.Agregarinformacion( "Error al aplicar retención de " + loItemImpuesto.Tipo_PK + ". No puede generar retenciones para distintos regimenes." )
									exit
								else
									loCalculoTipo = 1
								endif
							endif
						endif
					next
				endif
			next
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActuaComoAgenteDeRetenciónRG2616() as Boolean
		local llRetorno as Boolean
		llRetorno = this.ActuaComoAgenteDeRetencionRG2616SegunTipoDeImpuesto( "GANANCIAS" )
		llRetorno = llRetorno or this.ActuaComoAgenteDeRetencionRG2616SegunTipoDeImpuesto( "IVA" )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActuaComoAgenteDeRetenciónRG1575() as Boolean
		local llRetorno as Boolean
		llRetorno = this.ActuacomoAgenteDeRetencionRG1575SegunTipoDeImpuesto( "GANANCIAS" )
		llRetorno = llRetorno or this.ActuacomoAgenteDeRetencionRG1575SegunTipoDeImpuesto( "IVA" )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActuacomoAgenteDeRetencionRG2616SegunTipoDeImpuesto( tcTipo as String ) as Boolean
		return this.TieneDatosFiscalesConfiguradoComoParaRetenerRG2616( tcTipo, .f. )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneDatosFiscalesConfiguradoComoParaRetenerRG2616( tcTipoImpuesto as String, tlBuscaImpuestosSeteadosParaComprobantesM as Boolean ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if this.EstaSeteadoElParametroDeDatosFiscales()
			llRetorno = this.ExisteImpuestoDeRetencionSeteadoEnDatosFiscales( tcTipoImpuesto, tlBuscaImpuestosSeteadosParaComprobantesM )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActuacomoAgenteDeRetencionRG1575SegunTipoDeImpuesto( tcTipo as String ) as Boolean
		return this.TieneDatosFiscalesConfiguradoComoParaRetenerRG1575( tcTipo, .f. )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneDatosFiscalesConfiguradoComoParaRetenerRG1575( tcTipoImpuesto as String, tlBuscaImpuestosSeteadosParaComprobantesM as Boolean ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if this.EstaSeteadoElParametroDeDatosFiscales()
			llRetorno = this.ExisteImpuestoDeRetencionSeteadoEnDatosFiscales( tcTipoImpuesto, tlBuscaImpuestosSeteadosParaComprobantesM )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearTextoParaTooltip( toDatosRetencion as Object ) as String
		local lcRetorno as String, lcMascaraNumeros as String, lcMascaraPorcentajes as String, lnTotalDePagos as Number, lnPagoActualNeto as Number, ;
			lnMontoExcedente as Number, lnSubtotalLuegoDeExcedente as Number, lnRetencionesAcumuladas as Number

		with toDatosRetencion
			do case
			case alltrim( .TipoImpuesto ) == "GANANCIAS" and !.esRG2616AR and !.esRG1575AR
				lcRetorno = this.FormatearTextoParaTooltipGanancias(toDatosRetencion)
			case .esRG1575AR
				lcRetorno = this.FormatearTextoParaTooltipRG1575(toDatosRetencion)
			case .esRG2616AR
				lcRetorno = this.FormatearTextoParaTooltipRG2616(toDatosRetencion)
			otherwise
				lcRetorno = this.FormatearTextoParaTooltipGenerico(toDatosRetencion)
			endcase
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearTextoParaTooltipGenerico( toDatosRetencion as Object ) as String
		local lcRetorno as String, lcMascaraNumeros as String, lcMascaraPorcentajes as String, lnTotalDePagos as Number, lnPagoActualNeto as Number, ;
			lnMontoExcedente as Number, lnSubtotalLuegoDeExcedente as Number, lnRetencionesAcumuladas as Number
		lcMascaraNumeros = "99999999999999.99"
		lcMascaraPorcentajes = "999999.99"
		with toDatosRetencion
			lcRetorno = alltrim( .CodImp ) + " - " + alltrim( .CodImpDetalle ) + chr(13)
			lcRetorno = lcRetorno + "Retención de " + this.ObtenerDescripcionDeTipoImpuesto( .TipoImpuesto ) + "" + chr(13) 
			lcRetorno = lcRetorno + iif( empty( alltrim( .Jurisdiccion ) ), "", " Jurisdicción: " + alltrim( .Jurisdiccion ) + chr(13) )
			lcRetorno = lcRetorno + iif( empty( alltrim( .Resolucion ) ), "", " Resolución: " + alltrim( .Resolucion ) + chr(13) )

			lcRetorno = lcRetorno + this.FormatearRenglon( " + Monto base         ", .MontoBase, lcMascaraNumeros ) + chr(13)
			if .Porcentaje <> 0
				lcRetorno = lcRetorno + this.FormatearRenglon( " x  Porcentaje:", .Porcentaje, lcMascaraPorcentajes ) + " %" + chr(13)
			endif
			if .PorcentajeDeBase <> 0
				lcRetorno = lcRetorno + this.FormatearRenglon( " x  Porcentaje base:", .PorcentajeDeBase, lcMascaraPorcentajes ) + " %" + chr(13)
			endif
			if !empty( alltrim( .ConvenioMultilateral ) )
				lcRetorno = lcRetorno + "   Convenio:" + alltrim( .ConvenioMultilateral ) + chr(13)
				lcRetorno = lcRetorno + this.FormatearRenglon( " x  Porcentaje de convenio: ", .PorcentajeDeConvenio, lcMascaraPorcentajes ) + " %" + chr(13)
			endif

			lcRetorno = lcRetorno + this.FormatearRenglon( " = Monto retención:", .MontoRetencion, lcMascaraNumeros )
	
			lcRetorno = lcRetorno + this.ObtenerTooltipCertificadoSire( toDatosRetencion )
			
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearTextoParaTooltipGanancias( toDatosRetencion as Object ) as String
		local lcRetorno as String, lcMascaraNumeros as String, lcMascaraPorcentajes as String, lnTotalDePagos as Number, lnPagoActualNeto as Number, ;
			lnMontoExcedente as Number, lnSubtotalLuegoDeExcedente as Number, lnRetencionesAcumuladas as Number
		lcMascaraNumeros = "99999999999999.99"
		lcMascaraPorcentajes = "999999.99"
		with toDatosRetencion
			lcRetorno = alltrim( .CodImp ) + " - " + alltrim( .CodImpDetalle ) + chr(13)
			lcRetorno = lcRetorno + "Retención de " + this.ObtenerDescripcionDeTipoImpuesto( .TipoImpuesto ) + "" + chr(13) 
			lnTotalDePagos = round( .MontoBase + .MinimoNoImp, 2 )
			lnPagoActualNeto = round( lnTotalDePagos - .AcumuladoPagos, 2 )
			lnMontoExcedente = round( .MontoBase - .EscalaSobreExcedente, 2 )

			lcRetorno = lcRetorno + this.FormatearRenglon( " + Pagos ant. del mes:", .AcumuladoPagos, lcMascaraNumeros ) + chr(13)
			lcRetorno = lcRetorno + this.FormatearRenglon( " + Pago actual (neto):", lnPagoActualNeto, lcMascaraNumeros ) + chr(13)
			lcRetorno = lcRetorno + this.FormatearRenglon( " = Pagos acumulados:", lnTotalDePagos, lcMascaraNumeros ) + chr(13)
			lcRetorno = lcRetorno + this.FormatearRenglon( " - Mínimo no imp.:", .MinimoNoImp, lcMascaraNumeros ) + chr(13)
			lcRetorno = lcRetorno + this.FormatearRenglon( " = Monto base:", .MontoBase, lcMascaraNumeros ) + chr(13)
			if .EscalaPorcentaje <> 0
				lnSubtotalLuegoDeExcedente = round( lnMontoExcedente * .EscalaPorcentaje / 100 , 2 )
				lnRetencionesAcumuladas = round( lnSubtotalLuegoDeExcedente + .EscalaMontoFijo, 2 )
				lcRetorno = lcRetorno + "  Según escala " + chr(13)
				lcRetorno = lcRetorno + this.FormatearRenglon( " +   Excedente de " + alltrim( transform( .EscalaSobreExcedente, "99999999999999" ) ) + ":", lnMontoExcedente, lcMascaraNumeros ) + chr(13)
				lcRetorno = lcRetorno + this.FormatearRenglon( " x   Porcentaje:", .EscalaPorcentaje, lcMascaraPorcentajes ) + " %" + chr(13)
				lcRetorno = lcRetorno + this.FormatearRenglon( " =   Subtotal:", lnSubtotalLuegoDeExcedente, lcMascaraNumeros ) + chr(13)
				lcRetorno = lcRetorno + this.FormatearRenglon( " +   Monto fijo:", .EscalaMontoFijo, lcMascaraNumeros ) + chr(13)
			else
				lnSubtotalLuegoDeExcedente = round( lnMontoExcedente * .Porcentaje / 100 , 2 )
				lnRetencionesAcumuladas = round( lnSubtotalLuegoDeExcedente + .EscalaMontoFijo, 2 )
				if .Porcentaje <> 0
					lcRetorno = lcRetorno + this.FormatearRenglon( " x  Porcentaje:", .Porcentaje, lcMascaraPorcentajes ) + " %" + chr(13)
				endif
			endif
			lcRetorno = lcRetorno + this.FormatearRenglon( " = Retención total:", lnRetencionesAcumuladas, lcMascaraNumeros ) + chr(13)
			lcRetorno = lcRetorno + this.FormatearRenglon( " - Retenciones ant.:", .AcumuladoRetenciones, lcMascaraNumeros ) + chr(13)
			lcRetorno = lcRetorno + this.FormatearRenglon( " = Monto retención:", .MontoRetencion, lcMascaraNumeros )
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearTextoParaTooltipRG1575( toDatosRetencion as Object ) as String
		local lcRetorno as String, lcMascaraNumeros as String, lcMascaraPorcentajes as String, lnTotalDePagos as Number, lnPagoActualNeto as Number, ;
			lnMontoExcedente as Number, lnSubtotalLuegoDeExcedente as Number, lnRetencionesAcumuladas as Number
		lcMascaraNumeros = "99999999999999.99"
		lcMascaraPorcentajes = "999999.99"
		with toDatosRetencion
			lcRetorno = alltrim( .CodImp ) + " - " + alltrim( .CodImpDetalle ) + chr(13)
			lcRetorno = lcRetorno + "Retención de " + this.ObtenerDescripcionDeTipoImpuesto( .TipoImpuesto ) + "" + chr(13) 
			lcRetorno = lcRetorno + "AFIP - R.G. 1575/03" + chr(13) 

			lcRetorno = lcRetorno + this.FormatearRenglon( " + Monto base         ", .MontoBase, lcMascaraNumeros ) + chr(13)
			if .Porcentaje <> 0
				lcRetorno = lcRetorno + this.FormatearRenglon( " x  Porcentaje:", .Porcentaje, lcMascaraPorcentajes ) + " %" + chr(13)
			endif

			lcRetorno = lcRetorno + this.FormatearRenglon( " = Monto retención:", .MontoRetencion, lcMascaraNumeros )
			lcRetorno = lcRetorno + this.ObtenerTooltipCertificadoSire( toDatosRetencion )

		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearTextoParaTooltipRG2616( toDatosRetencion as Object ) as String
		local lcRetorno as String, lcMascaraNumeros as String, lcMascaraPorcentajes as String, lnTotalDePagos as Number, lnPagoActualNeto as Number, ;
			lnMontoExcedente as Number, lnSubtotalLuegoDeExcedente as Number, lnRetencionesAcumuladas as Number
		lcMascaraNumeros = "99999999999999.99"
		lcMascaraPorcentajes = "999999.99"
		with toDatosRetencion
			lcRetorno = alltrim( .CodImp ) + " - " + alltrim( .CodImpDetalle ) + chr(13)
			lcRetorno = lcRetorno + "Retención de " + this.ObtenerDescripcionDeTipoImpuesto( .TipoImpuesto ) + "" + chr(13) 
			lcRetorno = lcRetorno + "AFIP - R.G. 2616/09 Monotributo" + chr(13) 

			lcRetorno = lcRetorno + this.FormatearRenglon( " + Monto base         ", .MontoBase, lcMascaraNumeros ) + chr(13)
			if .Porcentaje <> 0
				lcRetorno = lcRetorno + this.FormatearRenglon( " x  Porcentaje:", .Porcentaje, lcMascaraPorcentajes ) + " %" + chr(13)
			endif
			lcRetorno = lcRetorno + this.FormatearRenglon( " = Monto retención:", .MontoRetencion, lcMascaraNumeros )
			lcRetorno = lcRetorno + this.ObtenerTooltipCertificadoSire( toDatosRetencion )
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerImpuesto( tcCodigo as String  ) as Object
		local loRetorno as Object
		if this.oImpuesto.Codigo # tcCodigo
			this.oImpuesto.Codigo = tcCodigo
		endif
		loRetorno = this.oImpuesto
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionDeRetencionesDeDatosFiscales() as Collection
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, loItemDatoFiscal as zoocoleccion OF zoocoleccion.prg
		loColRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loItemDatoFiscal in this.oDatosFiscales.PerceIIBB foxobject
			if loItemDatoFiscal.Aplicacion = "RTN" and this.EsTipoDeImpuestoHabilitado( loItemDatoFiscal.Tipo_PK )
				loItem = this.ObtenerItemImpuesto( loItemDatoFiscal.Impuesto_PK )
				try
					if inlist(loItemDatoFiscal.Tipo_PK,"GANANCIAS","IVA","SUSS")
						loColRetorno.Agregar( loItem, alltrim(loItemDatoFiscal.Tipo_PK) )
					else
						loColRetorno.Agregar( loItem, alltrim(loItemDatoFiscal.Tipo_PK) + alltrim(loItemDatoFiscal.Jurisdiccion)+alltrim(loItemDatoFiscal.Resolucion) )
					endif
				Catch To loError
					if loError.errorno = 2062
						goServicios.Errores.LevantarExcepcionTexto( "Error al aplicar retención de " + alltrim(loItemDatoFiscal.Tipo_PK) + ". Hay mas de un impuesto del mismo tipo en el esquema de datos fiscales." )
					else
						goServicios.Errores.LevantarExcepcion( loError )
					endif
				endtry
			endif
		endfor
		return loColRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeRetencionesSegunProveedor( toProveedor as ent_proveedor of ent_proveedor.prg ) as ZooColeccion of ZooColeccion.Prg
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, loItemDatoFiscal as zoocoleccion OF zoocoleccion.prg
		loColRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loItem in this.oColEsquemaFiscal FOXOBJECT
			loItemBase = this.ObtenerItemImpuestoRetencion(loItem)
			if inlist(loItemBase.Tipo_PK,"GANANCIAS","IVA","SUSS")
				if vartype(toProveedor) # "O" or isnull(toProveedor) or loItemBase.CorrespondeRetener( toProveedor )
					loColRetorno.Agregar( loItemBase, alltrim(loItemBase.Tipo_PK) )
				endif
			else
				if this.DebeIncluirJurisdiccionEnProveedor( toProveedor, alltrim(loItemBase.Jurisdiccion_PK) )
					loColRetorno.Agregar( loItemBase, alltrim(loItemBase.Tipo_PK) + alltrim(loItemBase.Jurisdiccion_PK)+alltrim(loItemBase.Resolucion) )
				endif
			endif
		next
		if loColRetorno.count > 0 and vartype( toProveedor ) = "O" and !isnull( toProveedor ) and vartype( toProveedor.Codigo ) = "C" and !empty( toProveedor.Codigo )
			this.ActualizarConfiguracionEspecificaDeProveedor(loColRetorno,toProveedor)
		endif
		return loColRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeRetencionesBase() as ZooColeccion of ZooColeccion.Prg
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, loItemDatoFiscal as zoocoleccion OF zoocoleccion.prg
		loColRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loItem in this.oColEsquemaFiscal FOXOBJECT
			loItemBase = this.ObtenerItemImpuestoRetencion(loItem)
			if inlist(loItemBase.Tipo_PK,"GANANCIAS","IVA","SUSS")
				loColRetorno.Agregar( loItemBase, alltrim(loItemBase.Tipo_PK) )
			else
				loColRetorno.Agregar( loItemBase, alltrim(loItemBase.Tipo_PK) + alltrim(loItemBase.Jurisdiccion_PK)+alltrim(loItemBase.Resolucion) )
			endif
		next
		return loColRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarConfiguracionEspecificaDeProveedor( toColeccion as ZooColeccion of ZooColeccion.Prg, toProveedor as ent_proveedor of ent_proveedor.prg ) as Void
		local loImpuesto as ent_impuesto of ent_impuesto.prg, loError as zooException or zooException.prg
		loImpuesto = _Screen.Zoo.InstanciarEntidad( "Impuesto" )
	
		if vartype( toProveedor ) = "O" and !isnull( toProveedor )
			with toProveedor
					if !.EsProveedorExcluidoDeRetencion( "GANANCIAS" ) and !empty(.RetencionGanancias_PK)
						try 
							loImpuesto.Codigo = .RetencionGanancias_PK
							this.ActualizarItemEnEsquemaConDatoDeProveedor( toColeccion, loImpuesto )
						catch to loError
						endtry
					endif
					if !.EsProveedorExcluidoDeRetencion( "IVA" ) and !empty(.RetencionIVA_PK)
						try 
							loImpuesto.Codigo = .RetencionIVA_PK
							this.ActualizarItemEnEsquemaConDatoDeProveedor( toColeccion, loImpuesto )
						catch to loError
						endtry
					endif
					if !.EsProveedorExcluidoDeRetencion( "SUSS" ) and !empty(.RetencionSUSS_PK)
						try 
							loImpuesto.Codigo = .RetencionSUSS_PK
							this.ActualizarItemEnEsquemaConDatoDeProveedor( toColeccion, loImpuesto )
						catch to loError
						endtry
					endif
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarItemEnEsquemaConDatoDeProveedor( toColeccion as ZooColeccion of ZooColeccion.Prg, toImpuesto as ent_Impuesto of ent_Impuesto.prg ) as Void
		for each loItemImpuesto in toColeccion FOXOBJECT
			if loItemImpuesto.Tipo_PK = toImpuesto.Tipo_PK and loItemImpuesto.Aplicacion = toImpuesto.Aplicacion
				loItemImpuesto.Codigo = toImpuesto.Codigo
				loItemImpuesto.Porcentaje = toImpuesto.Porcentaje

				if toImpuesto.SegunConvenio
					loItemImpuesto.SegunConvenio = toImpuesto.SegunConvenio
					loItemImpuesto.ConvenioLocal = toImpuesto.ConvenioLocal
					loItemImpuesto.ConvenioMultilateral = toImpuesto.ConvenioMultilateral
					loItemImpuesto.ConvenioNoInscripto = toImpuesto.ConvenioNoInscripto
					loItemImpuesto.conveniomultilextranajuris = toImpuesto.conveniomultilextranajuris
				endif
				
				loItemImpuesto.CargarPorcentajeVigenteDelProveedor( this.oComprobante.Proveedor, this.oComprobante.Fecha  )
				loItemImpuesto.BaseDeCalculo = toImpuesto.BaseDeCalculo
				loItemImpuesto.Minimo = toImpuesto.Minimo
				loItemImpuesto.Monto = toImpuesto.Monto
				loItemImpuesto.RegimenImpositivo_PK = toImpuesto.RegimenImpositivo_PK
				loItemImpuesto.RegimenImpositivoDescripcion = toImpuesto.RegimenImpositivo.Descripcion
				loItemImpuesto.Jurisdiccion_PK = toImpuesto.Jurisdiccion_PK
				loItemImpuesto.JurisdiccionDescripcion = toImpuesto.Jurisdiccion.Descripcion
				loItemImpuesto.Resolucion = toImpuesto.Resolucion
				loItemImpuesto.PagoParcial = toImpuesto.PagoParcial
				loItemImpuesto.RG2616Porcentaje = toImpuesto.RG2616Porcentaje
				loItemImpuesto.RG2616Regimen_PK = toImpuesto.RG2616Regimen_PK
				loItemImpuesto.RG2616Meses = toImpuesto.RG2616Meses
				loItemImpuesto.RG2616MontoMaximoBienes = toImpuesto.RG2616MontoMaximoBienes
				loItemImpuesto.RG2616MontoMaximoServicios = toImpuesto.RG2616MontoMaximoServicios
				loItemImpuesto.RG2616RegimenDescripcion = toImpuesto.RG2616Regimen.Descripcion
				loItemImpuesto.RG1575Regimen_PK = toImpuesto.RG1575Regimen_PK
				loItemImpuesto.RG1575Porcentaje = toImpuesto.RG1575Porcentaje
				loItemImpuesto.RG1575BaseDeCalculo = toImpuesto.RG1575BaseDeCalculo
				loItemImpuesto.RG1575MontoMinimoRetencion = toImpuesto.RG1575MontoMinimoRetencion

				loItemImpuesto.Escala = toImpuesto.Escala
				loItemImpuesto.oEscalaDetalle = _screen.zoo.CrearObjeto( "ZooColeccion" )  
				
				if loItemImpuesto.Escala
					for each loItemDetalle in toImpuesto.EscalaDetalle foxobject
						loItemEscala = newobject( "ItemEscala" )
						loItemEscala.MontoDesde = loItemDetalle.MayorA
						loItemEscala.MontoHasta = loItemDetalle.Hasta
						loItemEscala.Porcentaje = loItemDetalle.Porcentaje
						loItemEscala.MontoBase = loItemDetalle.MontoFijo
						loItemImpuesto.oEscalaDetalle.add( loItemEscala )
					endfor
				endif
			endif
		next
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemImpuestoRetencion( toItemImpuesto as Object ) as Object
		local loItem as Object, loItemImpuesto as Object
		loImpuesto = toItemImpuesto

		loItem = this.ObtenerImpuestoRetencion( loImpuesto.Tipo_PK )
		loItem.Codigo = loImpuesto.Codigo
		loItem.Tipo_PK = loImpuesto.Tipo_PK
		loItem.Aplicacion = loImpuesto.Aplicacion
		loItem.Resolucion = loImpuesto.Resolucion
		loItem.Monto = loImpuesto.Monto

		loItem.RegimenImpositivo_PK = loImpuesto.RegimenImpositivo_PK
		loItem.RegimenImpositivoDescripcion = loImpuesto.RegimenImpositivoDescripcion
		loItem.Porcentaje = loItem.ObtenerPorcentajeDelImpuesto( loImpuesto.Porcentaje )
		loItem.BaseDeCalculo = loImpuesto.BaseDeCalculo
		loItem.PagoParcial = loImpuesto.PagoParcial
		loItem.Minimo = loImpuesto.Minimo
		loItem.MinimoNoImponible = loImpuesto.Monto
		loItem.RG1575MontoMinimoRetencion = loImpuesto.RG1575MontoMinimoRetencion
		loItem.Jurisdiccion_PK = loImpuesto.Jurisdiccion_PK
		loItem.JurisdiccionDescripcion = loImpuesto.JurisdiccionDescripcion

		if loImpuesto.SegunConvenio
			loitem.SegunConvenio = loImpuesto.SegunConvenio
			loitem.ConvenioLocal = loImpuesto.ConvenioLocal
			loitem.ConvenioMultilateral = loImpuesto.ConvenioMultilateral
			loitem.ConvenioNoInscripto = loImpuesto.ConvenioNoInscripto
			loitem.ConvenioMultilExtranaJuris = loImpuesto.ConvenioMultilExtranaJuris              
		endif
		
		loItem.CargarPorcentajeVigenteDelProveedor( this.oComprobante.Proveedor, this.oComprobante.Fecha  )
		loItem.PorcentajeBase = loImpuesto.PorcentajeBase
		loItem.RG2616Porcentaje = loImpuesto.RG2616Porcentaje
		loItem.RG2616Regimen_PK = loImpuesto.RG2616Regimen_PK
		loItem.RG2616Meses = loImpuesto.RG2616Meses
		loItem.RG2616MontoMaximoBienes = loImpuesto.RG2616MontoMaximoBienes
		loItem.RG2616MontoMaximoServicios = loImpuesto.RG2616MontoMaximoServicios
		loItem.Escala = loImpuesto.Escala
		loItem.oEscalaDetalle = _screen.zoo.CrearObjeto( "ZooColeccion" )
		if loItem.Escala
			for each loItemDetalle in loImpuesto.oEscalaDetalle foxobject
				loItemEscala = newobject( "ItemEscala" )
				loItemEscala.MontoDesde = loItemDetalle.MontoDesde
				loItemEscala.MontoHasta = loItemDetalle.MontoHasta
				loItemEscala.Porcentaje = loItemDetalle.Porcentaje
				loItemEscala.MontoBase = loItemDetalle.MontoBase
				loItem.oEscalaDetalle.add( loItemEscala )
			endfor
		endif

		loItem.MontoMinimoParaComprobantesM = loImpuesto.RG1575MontoMinimoRetencion

		loItem.RG1575Regimen_PK = loImpuesto.RG1575Regimen_PK
		loItem.RG1575Porcentaje = loImpuesto.RG1575Porcentaje
		loItem.RG1575BaseDeCalculo = loImpuesto.RG1575BaseDeCalculo

		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemImpuesto( tcCodigoImpuesto as String ) as Object	
		local loItem as Object, loImpuesto as Object

		loImpuesto = this.ObtenerImpuesto( tcCodigoImpuesto )
		loItem = this.ObtenerImpuestoRetencion( loImpuesto.Tipo_PK )
		loItem.Codigo = loImpuesto.Codigo
		loItem.Tipo_PK = loImpuesto.Tipo_PK
		loItem.Aplicacion = loImpuesto.Aplicacion
		loItem.JurisdiccionDescripcion = loImpuesto.Jurisdiccion.Descripcion
		loItem.Resolucion = loImpuesto.Resolucion
		loItem.Monto = loImpuesto.Monto

		loItem.RegimenImpositivo_PK = loImpuesto.RegimenImpositivo_PK
		loItem.RegimenImpositivoDescripcion = loImpuesto.RegimenImpositivo.Descripcion
		loItem.Porcentaje = loItem.ObtenerPorcentajeDelImpuesto( loImpuesto.Porcentaje )
		loItem.BaseDeCalculo = loImpuesto.BaseDeCalculo
		loItem.PagoParcial = loImpuesto.PagoParcial
		loItem.Minimo = loImpuesto.Minimo
		loItem.MinimoNoImponible = loImpuesto.Monto

		* si toma comprobantes M ver si blanquea todo el resto de los valores (como minimos, etc)

		loItem.Jurisdiccion_PK = loImpuesto.Jurisdiccion_PK
		if loImpuesto.SegunConvenio
			loitem.SegunConvenio = loImpuesto.SegunConvenio
			loitem.ConvenioLocal = loImpuesto.ConvenioLocal
			loitem.ConvenioMultilateral = loImpuesto.ConvenioMultilateral
			loitem.ConvenioNoInscripto = loImpuesto.ConvenioNoInscripto
			loitem.ConvenioMultilExtranaJuris = loImpuesto.ConvenioMultilExtranaJuris
		endif
		
*!*			loItem.CargarPorcentajeVigenteDelProveedor( this.oComprobante.Proveedor, this.oComprobante.Fecha  )
		loItem.PorcentajeBase = loImpuesto.PorcentajeBase
		loItem.RG2616Porcentaje = loImpuesto.RG2616Porcentaje
		loItem.RG2616Regimen_PK = loImpuesto.RG2616Regimen_PK
		loItem.RG2616Meses = loImpuesto.RG2616Meses
		loItem.RG2616MontoMaximoBienes = loImpuesto.RG2616MontoMaximoBienes
		loItem.RG2616MontoMaximoServicios = loImpuesto.RG2616MontoMaximoServicios
		loItem.RG2616RegimenDescripcion = loImpuesto.RG2616Regimen.Descripcion
		loItem.Escala = loImpuesto.Escala
		loItem.oEscalaDetalle = _screen.zoo.CrearObjeto( "ZooColeccion" )
		if loItem.Escala
			for each loItemDetalle in loImpuesto.EscalaDetalle foxobject
				loItemEscala = newobject( "ItemEscala" )
				loItemEscala.MontoDesde = loItemDetalle.MayorA
				loItemEscala.MontoHasta = loItemDetalle.Hasta
				loItemEscala.Porcentaje = loItemDetalle.Porcentaje
				loItemEscala.MontoBase = loItemDetalle.MontoFijo
				loItem.oEscalaDetalle.add( loItemEscala )
			endfor
		endif

		loItem.MontoMinimoParaComprobantesM = loImpuesto.RG1575MontoMinimoRetencion && this.oDatosFiscales.ObtenerMontoMinimoParaComprobantesM()

		loItem.RG1575Regimen_PK = loImpuesto.RG1575Regimen_PK
		loItem.RG1575Porcentaje = loImpuesto.RG1575Porcentaje
		loItem.RG1575BaseDeCalculo = loImpuesto.RG1575BaseDeCalculo
		loItem.RG1575MontoMinimoRetencion = loImpuesto.RG1575MontoMinimoRetencion
		
		loImpuesto.Release()

		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAplicacionRetencion( tcAplicacion as String ) as Boolean
		return ( alltrim( upper( tcAplicacion )) = "RTN" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsProveedorResponsableInscriptoEnIva( toProveedor as Object ) as Boolean
		return (toProveedor.SituacionFiscal_PK = goServicios.Registry.FELINO.SituacionFiscalClienteInscripto)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsRetencion( tcCodigo as String ) as Boolean
		local llRetorno as Boolean, lcXml as String, lcCursor as String
		
		llRetorno = .f.	
		lcXml = This.oImpuesto.OAD.ObtenerDatosEntidad( "CODIGO", "CODIGO = '" + tcCodigo + "' AND APLICACION = 'RTN'", "", "" ) 
		lcCursor = "c_" + sys( 2015)
		This.XmlACursor( lcXml, lcCursor )
		select ( lcCursor )
		if reccount( lcCursor ) > 0
			llRetorno = .t.
		endif
		use in select ( lcCursor )
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsTipoDeImpuestoHabilitado( tcTipoDeImpuesto as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = inlist(tcTipoDeImpuesto,"IVA","GANANCIAS","IIBB","SUSS")
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeIncluirJurisdiccionEnProveedor( toProveedor as ent_Proveedor of ent_Proveedor.prg, tcJurisdiccion as String ) as Boolean
		local llRetorno as Boolean, lcJurisdiccion as String
		llRetorno = .t.

		if toProveedor.Retenciones.Count = 0 or this.EsExtranaJurisdiccionValida( toProveedor )
		else
			llJurisdiccionSiempre = alltrim( Upper( this.oDatosFiscales.RetPercSiempreSegunJurisdiccion_PK )) = tcJurisdiccion
			llDejarJurisdiccion = .f. && llEncontro = .f.
			llExcluida = .f.
			llEncontro = .f.
			for each loItem in toProveedor.Retenciones FOXOBJECT
				if upper( alltrim( loItem.Jurisdiccion_PK)) = upper( alltrim( tcJurisdiccion))
					llExcluida = loItem.Excluido
					llEncontro = .t.
					exit
				endif
			next
			do case
			case llJurisdiccionSiempre
				if llEncontro and llExcluida
					llRetorno = .f.
				endif
			other
				if !llEncontro or llExcluida
					llRetorno = .f.
				endif
			endcase
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsExtranaJurisdiccionValida( toProveedor ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		
		for each loItem in toProveedor.Retenciones FOXOBJECT
			if loItem.SedeExtraJuris and !loItem.Excluido
			else
				llRetorno = .f.
				exit
			endif
		next
		
		return llRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionEsquema() as Collection
		return this.oColEsquema
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTooltipCertificadoSire( toDatosRetencion ) as String
		local lcRetorno as String
		lcRetorno = ""
		if !empty( toDatosRetencion.CertificadoSire )
			lcRetorno = lcRetorno + "   Cert. Sire: " + .CertificadoSire
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oColaboradorSireWS_Access()as Object	
		if !this.lDestroy and vartype( this.oColaboradorSireWS ) # "O" Or Isnull(this.oColaboradorSireWS )
			this.oColaboradorSireWS = _Screen.zoo.crearobjeto( "ColaboradorSireWS", "ColaboradorSireWS.prg" )
		endif
		Return this.oColaboradorSireWS

	endfunc
	
enddefine

*--------------------------------
define class ItemEscala as custom
	MontoDesde = 0
	MontoHasta = 0
	Porcentaje = 0
	MontoBase = 0
enddefine
