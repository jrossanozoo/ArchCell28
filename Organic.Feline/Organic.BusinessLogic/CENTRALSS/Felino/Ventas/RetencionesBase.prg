define class RetencionesBase as componente of componente.prg

	#if .f.
		local this as RetencionesBase of RetencionesBase.prg
	#endif

	cTipo = ""
	oComprobanteRet = null
	oEntidadPadre = null
	oEntidadImpuestos = null

	*-----------------------------------------------------------------------------------------
	protected function InyectarComprobanteRetSegunTipo( toComprobanteDeRetenciones as Object ) as Void
		this.oComprobanteRet = toComprobanteDeRetenciones
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oEntidadImpuestos_Access() as variant
		if this.lDestroy
		else
			if ( !vartype( this.oEntidadImpuestos ) = 'O' or isnull( this.oEntidadImpuestos ) )
				this.oEntidadImpuestos = _Screen.zoo.instanciarentidad( 'Impuesto' )
			endif
		endif
		return this.oEntidadImpuestos
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		This.oEntidadPadre = toEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.lDestroy = .t.
 		This.oEntidadPadre = Null
	
		if type( "This.oComprobanteRet.TipoImpuesto" ) = "O" and !isnull( This.oComprobanteRet.TipoImpuesto )
			This.oComprobanteRet.TipoImpuesto.lDestroy = .t.
			This.oComprobanteRet.TipoImpuesto.Release()
		endif
		if type( "This.oComprobanteRet" ) = "O" and !isnull( This.oComprobanteRet )
			This.oComprobanteRet.lDestroy = .t.
			This.oComprobanteRet.Release()
		endif
		if type( "This.oEntidadImpuestos" ) = "O" and !isnull( This.oEntidadImpuestos )
			This.oEntidadImpuestos.lDestroy = .t.
			This.oEntidadImpuestos.Release()
		endif
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PudoEncontrarYSetearElComprobanteDeRetencionesDeLaOrdenDePago() as Boolean
		local llRetorno as Boolean, lcCodigoDeComprobanteDeRetenciones as String
		llRetorno = .F.
		lcCodigoDeComprobanteDeRetenciones = this.ObtenerCodigoDeComprobanteDeRetenciones()
		if !empty( alltrim( lcCodigoDeComprobanteDeRetenciones ) )
			llRetorno = this.SetearComprobanteDeRetencionesExistente( lcCodigoDeComprobanteDeRetenciones )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCodigoDeComprobanteDeRetenciones() as String
		local lcCodigo as String, lnI as Integer
		lcCodigo = ""
		for lnI = 1 to This.oEntidadPadre.ImpuestosComprobante.Count
			if alltrim( This.oEntidadPadre.ImpuestosComprobante.Item[ lnI ].TipoImpuestoCDR ) == this.cTipo
				lcCodigo = This.oEntidadPadre.ImpuestosComprobante.Item[ lnI ].CodigoCDR
				exit
			endif
		endfor
		if empty( lcCodigo ) and this.oEntidadPadre.EsEdicion()
			lcCodigo = this.ObtenerCodigoDeComprobanteDeRetencionesEliminadoEnLaEdicion()
		endif
		if empty( lcCodigo ) and this.cTipo = "IIBB" and !empty( this.oEntidadPadre.NumeroCDR )
			lcCodigo = this.ObtenerCodigoDeComprobanteDeRetencionesPorCompatibilidadHaciaAtras()
		endif
		return lcCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCodigoDeComprobanteDeRetencionesEliminadoEnLaEdicion() as String
		local lcCodigo as String, loItem as Object
		lcCodigo = ""
		if this.oEntidadPadre.oColeccionOriginalRetenciones.Count > 0
			for each loItem in this.oEntidadPadre.oColeccionOriginalRetenciones foxobject
				if alltrim( loItem.TipoImpuestoCDR ) == this.cTipo
					lcCodigo = loItem.CodigoCDR
					exit
				endif
			endfor
		endif
		return lcCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCodigoDeComprobanteDeRetencionesPorCompatibilidadHaciaAtras() as String
		local lcCodigo as String, lcSentencia as String, lcCursor as String, lcTabla as String, lcCampoCodigo as String, ;
			lcCampoPuntoDeVenta as String, lcCampoNumero as String, lcCampoAnulado as String, lcCampoTipoImpuesto as String
		lcCodigo = ""
		lcCursor = sys( 2015 )

		lcTabla = this.oComprobanteRet.oAD.cTablaPrincipal
		lcCampoCodigo = this.oComprobanteRet.oAD.ObtenerCampoEntidad( 'Codigo' )
		lcCampoPuntoDeVenta = this.oComprobanteRet.oAD.ObtenerCampoEntidad( 'PuntoDeVenta' )
		lcCampoNumero = this.oComprobanteRet.oAD.ObtenerCampoEntidad( 'Numero' )
		lcCampoAnulado = this.oComprobanteRet.oAD.ObtenerCampoEntidad( 'Anulado' )
		lcCampoTipoImpuesto = this.oComprobanteRet.oAD.ObtenerCampoEntidad( 'TipoImpuesto' )

		lcSentencia = "select " + lcCampoCodigo
		lcSentencia = lcSentencia + " from <<esquema>>." + lcTabla
		lcSentencia = lcSentencia + " Where " + lcCampoPuntoDeVenta + " = " + alltrim( str( this.oEntidadPadre.PuntoDeVentaCDR ) )
		lcSentencia = lcSentencia + "   and " + lcCampoNumero       + " = " + alltrim( str( this.oEntidadPadre.NumeroCDR ) )
		lcSentencia = lcSentencia + "   and " + lcCampoTipoImpuesto + " = '" + this.cTipo + "'"
		lcSentencia = lcSentencia + "   and " + lcCampoAnulado      + " = 0 "
		goServicios.Datos.EjecutarSentencias( lcSentencia, lcTabla, '', lcCursor, this.DataSessionId )
		if used( lcCursor )
			select &lcCursor
			lcCodigo = &lcCampoCodigo
			use in &lcCursor
		endif
		return lcCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearComprobanteDeRetencionesExistente( tcCodigo as String ) as Boolean
		local llRetorno as Boolean, loError as Exception
		llRetorno = .F.
		try
			This.oComprobanteRet.Codigo = tcCodigo
			llRetorno = .T.
		catch to loError
		endtry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Grabar() as zoocoleccion OF zoocoleccion.prg
		local loColRetorno as zoocoleccion OF zoocoleccion.prg
		loColRetorno = _Screen.zoo.Crearobjeto( "zoocoleccion" )

		if !this.oEntidadPadre.VerificarContexto( "BC" )
			do case 
				case this.oEntidadPadre.EsNuevo()
					this.ObtenerSentenciasAltaComprobanteDeRetencion( loColRetorno )
				case this.oEntidadPadre.EsEdicion()
					if This.PudoEncontrarYSetearElComprobanteDeRetencionesDeLaOrdenDePago()
						This.ObtenerSentenciasUpdateComprobanteDeRetencion( loColRetorno )
					else
						This.ObtenerSentenciasAltaComprobanteDeRetencion( loColRetorno )
					endif
				case This.oEntidadPadre.lAnular
					if This.PudoEncontrarYSetearElComprobanteDeRetencionesDeLaOrdenDePago()
						This.ObtenerSentenciasAnulacionComprobanteDeRetencion( loColRetorno )
					endif
			endcase
		endif

		return loColRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ComprobanteExistenteEnCDR( tcCodigo as String ) as Boolean
		local llRetorno as Boolean, lnI as Integer
		llRetorno = .F.
		for lnI = 1 to This.oComprobanteRet.ComprobantesDetalle.Count
			if This.oComprobanteRet.ComprobantesDetalle.Item[lnI].CodigoComprobante = tcCodigo
				llRetorno = .T.
				Exit
			endif
		EndFor
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneImpuestos() as boolean
		local llRetorno as Boolean, lnI as Integer
		llRetorno = .f.
		for lnI = 1 to This.oEntidadPadre.ImpuestosComprobante.Count
			if this.EsRetencionDelTipoDeImpuestoAGrabar( This.oEntidadPadre.ImpuestosComprobante.Item[ lnI ] )
				llRetorno = .t.
				exit for
			endif
		endfor
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsRetencionDelTipoDeImpuestoAGrabar( toItemImpuestoOrdenDePago as Object ) as Boolean
		local llRetorno as Boolean, lnI as Integer
		with toItemImpuestoOrdenDePago
			if alltrim( .TipoImpuestoCDR ) == this.cTipo ;
			 and !empty( .CodImp_Pk ) ;
			 and .Monto > 0 ;
			 and this.EsRetencion( .CodImp_Pk )
				llRetorno = .t.
			else
				llRetorno = .f.
			endif
		endwith
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsRetencion( tcCodigo as String ) as Boolean
		local loImpuesto as Object
		loImpuesto = this.ObtenerImpuesto( tcCodigo )
		return upper( alltrim( loImpuesto.Aplicacion ) ) == "RTN"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerImpuesto( tcCodigo as String  ) as Object
		local loRetorno as Object
		if this.oEntidadImpuestos.Codigo # tcCodigo
			this.oEntidadImpuestos.Codigo = tcCodigo
		endif
		loRetorno = this.oEntidadImpuestos
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentenciaActualizacionDeReferenciaACDREnOrdenDePago( toColSentencias as ZooColeccion OF ZooColeccion.prg ) as void
		local loItem as Object
		for each loItem in this.oEntidadPadre.ImpuestosComprobante foxobject
			if alltrim( loItem.TipoImpuestoCDR ) == this.cTipo
				loItem.CodigoCDR = this.oComprobanteRet.Codigo
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasAltaComprobanteDeRetencion( toColSentencias as zoocoleccion OF zoocoleccion.prg ) as Void
		local loColSentencias as zoocoleccion OF zoocoleccion.prg, lcItem as String, loError as zooexception OF zooexception.prg
		if This.TieneImpuestos()
			with This.oComprobanteRet
				Try
					.Nuevo()
					this.SetearComprobanteDeRetencionesDesdeOrdenDePago()
					If .Validar()
						.oAd.GrabarNumeraciones()
						loColSentencias = .ObtenerSentenciasInsert()
						for each lcItem in loColSentencias
							toColSentencias.Agregar( lcItem )
						endfor
						this.AgregarSentenciaActualizacionDeReferenciaACDREnOrdenDePago( toColSentencias )
					else
						goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
					EndIf	
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.Cancelar()
				Endtry	

			Endwith
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasAnulacionComprobanteDeRetencion( toColSentencias as zoocoleccion OF zoocoleccion.prg ) as Void
		local loColSentencias as zoocoleccion OF zoocoleccion.prg, lcItem as String
		with This.oComprobanteRet
			Try
				.lAnular = .T.
				loColSentencias = .ObtenerSentenciasUpdate()
				for each lcItem in loColSentencias
					toColSentencias.Agregar( lcItem )
				endfor
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			Endtry
		EndWith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasUpdateComprobanteDeRetencion( toColSentencias as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcItem as String, loColSentencias as zoocoleccion OF zoocoleccion.prg
		with This.oComprobanteRet
			Try
				if this.TieneImpuestos()
					.Modificar()
					This.SetearComprobanteDeRetencionesDesdeOrdenDePago()
				else
					.lAnular = .T.
				Endif
				loColSentencias = .ObtenerSentenciasUpdate()
				for each lcItem in loColSentencias
					toColSentencias.Agregar( lcItem )
				endfor
				this.AgregarSentenciaActualizacionDeReferenciaACDREnOrdenDePago( toColSentencias )
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			Finally
				if .EsEdicion()
					.Cancelar()
				Endif	
			Endtry	
		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearComprobanteDeRetencionesDesdeOrdenDePago() as Void
		local lnI as Integer, lnTotalComprobanteDeRetencion as Number
		lnTotalComprobanteDeRetencion = 0
		this.CargarCabeceraComprobanteDeRetenciones( This.oComprobanteRet, this.oEntidadPadre )
		This.oComprobanteRet.ImpuestosDetalle.Limpiar()
		for lnI = 1 to This.oEntidadPadre.ImpuestosComprobante.Count
			if this.EsRetencionDelTipoDeImpuestoAGrabar( This.oEntidadPadre.ImpuestosComprobante.Item[ lnI ] )
				lnTotalComprobanteDeRetencion = lnTotalComprobanteDeRetencion + this.CargarImpuestosDetalle( .ImpuestosDetalle, This.oEntidadPadre.ImpuestosComprobante.Item[ lnI ] )
			endif
		endfor
		This.oComprobanteRet.Total = lnTotalComprobanteDeRetencion
		This.oComprobanteRet.ComprobantesDetalle.Limpiar()
		this.CargarDetalleComprobanteDeRetenciones( This.oComprobanteRet.ComprobantesDetalle, This.oEntidadPadre.OrdenDePagoDetalle )
	EndFunc	
	
	*-----------------------------------------------------------------------------------------
	function CargarImpuestosDetalle ( toImpuestos as zoocoleccion OF zoocoleccion.prg, toItem as Object ) as Number
		toImpuestos.LimpiarItem()
		toImpuestos.oItem.CodImp_Pk = toItem.CodImp_Pk
		toImpuestos.oItem.Monto = toItem.Monto
		toImpuestos.oItem.CodImpDetalle = toItem.CodImpDetalle
		toImpuestos.oItem.ConvenioMultilateral = toItem.convenioMultilateral
		toImpuestos.oItem.PorcentajeDeConvenio = toItem.porcentajeConvenio
		toImpuestos.oItem.PorcentajeDeBase = toItem.porcentajeBase 
		toImpuestos.oItem.Porcentaje = toItem.porcentaje
		toImpuestos.oItem.MontoBase = toItem.MontoBase 

		toImpuestos.oItem.MinimoNoImp = toItem.MinimoNoImp
		toImpuestos.oItem.AcumuladoPagos = toItem.AcumuladoPagos
		toImpuestos.oItem.AcumuladoRetenciones = toItem.AcumuladoRetenciones
		toImpuestos.oItem.EscalaMontoFijo = toItem.EscalaMontoFijo
		toImpuestos.oItem.EscalaPorcentaje = toItem.EscalaPorcentaje
		toImpuestos.oItem.EscalaSobreExcedente = toItem.EscalaSobreExcedente

		toImpuestos.oItem.Jurisdiccion = toItem.Jurisdiccion
		toImpuestos.oItem.JurisdiccionDescripcion = toItem.JurisdiccionDescripcion
		toImpuestos.oItem.Resolucion = toItem.Resolucion
		toImpuestos.oItem.MinimoNoImponible = toItem.MinimoNoImponible
		toImpuestos.oItem.BaseDeCalculo = toItem.BaseDeCalculo
		toImpuestos.oItem.RegimenImpositivo = toItem.RegimenImpositivo
		toImpuestos.oItem.RegimenImpositivoDescripcion = toItem.RegimenImpositivoDescripcion
		toImpuestos.oItem.Escala = toItem.Escala
		toImpuestos.oItem.Minimo = toItem.Minimo

		toImpuestos.oItem.esRG2616AR = toItem.esRG2616AR
		toImpuestos.oItem.esRG1575AR = toItem.esRG1575AR
		
		toImpuestos.oItem.MontoComprobanteOrigen = this.oEntidadPadre.OrdenDePagoDetalle.Sum_Monto

		toImpuestos.Actualizar()
		return toItem.Monto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarCabeceraComprobanteDeRetenciones( toComprobante as Object, toEntidadPadre as Object ) as Void
		with toComprobante
			.PuntoDeVenta = toEntidadPadre.PuntoDeVenta
			.Proveedor_Pk = toEntidadPadre.Proveedor_Pk
			.ProveedorDescripcion = toEntidadPadre.ProveedorDescripcion
			.MonedaComprobante_Pk = toEntidadPadre.MonedaComprobante_Pk
			.MonedaSistema_Pk = toEntidadPadre.MonedaSistema_Pk
			.LetraOrdenDePago = toEntidadPadre.Letra
			.PuntoDeVentaOrdenDePago = toEntidadPadre.PuntoDeVenta
			.NumeroOrdenDePago = toEntidadPadre.Numero
			.ImpuestosManuales = toEntidadPadre.ImpuestosManuales
			.fecha = toEntidadPadre.fecha
			.TipoImpuesto_PK = this.cTipo
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarDetalleComprobanteDeRetenciones( toComprobantesDetalle as zoocoleccion OF zoocoleccion.prg, toOrdenDePagoDetalle as zoocoleccion OF zoocoleccion.prg ) as Void
		local lnI as Integer
		for lnI = 1 to toOrdenDePagoDetalle.Count
			if !empty( toOrdenDePagoDetalle.Item[lnI].Monto ) and !This.ComprobanteExistenteEnCDR( toOrdenDePagoDetalle.Item[lnI].CodigoComprobante )
				toComprobantesDetalle.LimpiarItem()
				toComprobantesDetalle.oItem.Descripcion = toOrdenDePagoDetalle.Item[lnI].Descripcion
				toComprobantesDetalle.oItem.Letra = toOrdenDePagoDetalle.Item[lnI].Letra
				toComprobantesDetalle.oItem.PuntoDeVenta = toOrdenDePagoDetalle.Item[lnI].PuntoDeVenta
				toComprobantesDetalle.oItem.NumeroDeComprobante = toOrdenDePagoDetalle.Item[lnI].NumeroDeComprobante
				toComprobantesDetalle.oItem.TipoDeComprobante = toOrdenDePagoDetalle.Item[lnI].TipoDeComprobante
				toComprobantesDetalle.oItem.CodigoComprobante = toOrdenDePagoDetalle.Item[lnI].CodigoComprobante
				toComprobantesDetalle.Actualizar()
			endif
		EndFor
	endfunc 



enddefine
