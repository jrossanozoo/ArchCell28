define class ComponenteImpuestosVentas as ComponenteImpuestos of ComponenteImpuestos.prg

	#IF .f.
		Local this as ComponenteImpuestosVentas of ComponenteImpuestosVentas.prg
	#ENDIF

	#DEFINE PRECISIONENMONTOS 4
	#DEFINE PRECISIONENCALCULOS 8

	CodigoCliente = ""
	nTotalImpuestosInternos = 0
	oImpuesto = null
	oCliente = null
	oColaboradorPercepciones = null
	nCoeficienteParaAplicacionDePercepcionesIVA = 0
	oImpuestosBase = null
	CodigoDeDatoFiscalAplicado = ""
	JurisdiccionSiempreAplica = ""
	protected FechaDeComprobante
	FechaDeComprobante = date()
	oColaboradorFechasVigentes = null
    lHayBasadoEn = .f.
    lSeEstaCancelandoUnComprobanteEnBaseA = .f.
	lSeEstaCancelandoUnComprobanteCompletoEnBaseA = .f.
    lSeEstaCancelandoUnComprobanteEnFechaPermitida = .f.
	lYaSeInformoQueSeAplicaRG_486_2016_AGIP = .f.
    lYaSeInformoQueSeAplicaRG_296_2019_AGIP = .f.
    lYaSeInformoQueSeAplicaIIBBTucuman = .f.
    lYaSeInformoQueSeAplicaIIBBGBA = .f.
    lForzarAccionCancelatoria = .f.
    oResolucionesIIBB = null

	*-----------------------------------------------------------------------------------------
	function oImpuesto_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oImpuesto ) = 'O' or isnull( this.oImpuesto ) )
				this.oImpuesto = _Screen.zoo.instanciarentidad( 'impuesto' )
			endif
		endif
		return this.oImpuesto
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oCliente_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oCliente ) = 'O' or isnull( this.oCliente ) )
				this.oCliente = _Screen.zoo.instanciarentidad( 'Cliente' )
			endif
		endif
		return this.oCliente
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorFechasVigentes_Access() as Object
		if !this.ldestroy and ( !vartype( this.oColaboradorFechasVigentes ) = 'O' or isnull( this.oColaboradorFechasVigentes ) )
			this.oColaboradorFechasVigentes = _Screen.zoo.CrearObjeto( "ColaboradorFechasVigentes" )
		endif
		return this.oColaboradorFechasVigentes
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CodigoCliente_assign( txValor as Variant ) as Void
		dodefault( txValor ) 
		this.CodigoCliente  = txValor
		if !this.ldestroy 
			this.CargarDetalleImpuestos()
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorPercepciones_Access() as variant
		if this.lDestroy
		else
			if ( vartype( this.oColaboradorPercepciones ) != "O" or isnull( this.oColaboradorPercepciones ) )
				this.oColaboradorPercepciones = _Screen.zoo.CrearObjeto( "ColaboradorPercepciones" )
				this.oColaboradorPercepciones.nIvainscriptos = this.nIvainscriptos
				this.oColaboradorPercepciones.oDatosFiscales = this.oEntidadDatosFiscales
			endif
		endif
		return this.oColaboradorPercepciones
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Vaciar() as Void
		dodefault()
		with this
			if vartype( .oImpuestosComprobante ) = "O" and !isnull( .oImpuestosComprobante )
				.oImpuestosComprobante.remove( - 1 )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		dodefault()
		this.oColaboradorPercepciones = null
		this.CodigoCliente = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AplicarPercepcion() as Boolean
		return !empty( this.CodigoCliente ) and !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar ) and !this.EsRecibo() and this.Aplicar()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsRecibo() as Boolean
		return ( upper( alltrim( this.cTipoDeComprobante ) ) == "RECIBO" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsNotaDeCredito() as Boolean
		return ( "NOTADECREDITO" $ upper( alltrim( this.cTipoDeComprobante ) ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearEnImpuestosDeLaColeccionSiDebenCalcular() as Void
		local lnIndice as Integer, llNoCalcularIIBB as Boolean

		this.oResolucionesIIBB = newobject( "collection" )

		if ( vartype( this.oImpuestos) = "O" and !isnull( this.oImpuestos) )
			this.SumaPorcentajesIIBB = 0
			llNoCalcularIIBB = ( this.TipoConvenioCliente = 4 )

			for lnIndice = 1 to this.oImpuestos.Count

				with this.oImpuestos.Item[lnIndice]
					.nCoeficienteNetoGravadoIVA = this.nCoeficienteNetoGravadoIVA
					if upper( alltrim( .tipoimpuesto ) ) = "IIBB"
						if llNoCalcularIIBB
							.Calcula = .f.
						else
							.Calcula = .ValidaMinimoNoImponible( this.TotalSinImpuestosMenosDescuentosMasRecargos )
							if .Calcula
								this.SumaPorcentajesIIBB = this.SumaPorcentajesIIBB + .Porcentaje
							endif
						endif
						if .Calcula
						    .Calcula = this.DebeCalcularIIBBCabaSegunCorrespondePorNormativaAGIP( this.oImpuestos.Item[lnIndice] )    
						    .Calcula = .Calcula and this.DebeCalcularIIBBTucuman( this.oImpuestos.Item[lnIndice] ) 
						    .Calcula = .Calcula and this.DebeCalcularIIBBGBA( this.oImpuestos.Item[lnIndice] ) 	
						endif
					else
						.Calcula = .AplicaPercepcion(this.nSituacionFiscalCliente)
						.Calcula = .Calcula and .ValidaMinimoNoImponible( this.TotalSinImpuestosMenosDescuentosMasRecargos )
					endif

				endwith
			endfor

			if this.oResolucionesIIBB.Count > 0 and ( !This.lYaSeInformoQueSeAplicaIIBBGBA or !This.lYaSeInformoQueSeAplicaRG_486_2016_AGIP or ;
				!This.lYaSeInformoQueSeAplicaRG_296_2019_AGIP or !This.lYaSeInformoQueSeAplicaIIBBTucuman ) 
			
				this.EventoAdvertirQueNoSeCalcularanPercepcionesDeIibb( this.oResolucionesIIBB )
				
				This.lYaSeInformoQueSeAplicaIIBBGBA = .t.
				This.lYaSeInformoQueSeAplicaRG_486_2016_AGIP = .t.
				This.lYaSeInformoQueSeAplicaRG_296_2019_AGIP = .t.
				This.lYaSeInformoQueSeAplicaIIBBTucuman = .t.
			endif			
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeCalcularIIBBCabaSegunCorrespondePorNormativaAGIP( toImpuesto as Object ) as Boolean
		local lnRetorno as Boolean
        llRetorno = .t.
        if this.EsNotaDeCredito() and toImpuesto.TipoImpuesto = 'IIBB' and toImpuesto.Jurisdiccion = "901"
  	        this.EventoSetearDatosAdicionalesParaCalculoDeImpuestos( toImpuesto.Jurisdiccion )	
            if !this.lForzarAccionCancelatoria
                if this.lSeEstaCancelandoUnComprobanteCompletoEnBaseA and this.lSeEstaCancelandoUnComprobanteEnFechaPermitida
                    llRetorno = .t.
                else
                	if this.lSeEstaCancelandoUnComprobanteEnBaseA
	                    if !this.lSeEstaCancelandoUnComprobanteEnFechaPermitida
	                        llRetorno = .f.
	                        this.oResolucionesIIBB.Add("RG_296_2019_AGIP")
	                    else
	                        llRetorno = .f.
	                        this.oResolucionesIIBB.Add("RG_486_2016_AGIP")
	                    endif
	                else
	                	llRetorno = .f.
	                endif
                 endif   
            endif       
		endif
		return llRetorno
	endfunc
  
  	*-----------------------------------------------------------------------------------------
	function DebeCalcularIIBBTucuman( toImpuesto as Object ) as Boolean
		local lnRetorno as Boolean
        llRetorno = .t.
   
        if this.EsNotaDeCredito() and toImpuesto.TipoImpuesto = 'IIBB' and toImpuesto.Jurisdiccion = "924"
  	        this.EventoSetearDatosAdicionalesParaCalculoDeImpuestos( toImpuesto.Jurisdiccion )	
         	if !this.lForzarAccionCancelatoria
                if this.lSeEstaCancelandoUnComprobanteCompletoEnBaseA and this.lSeEstaCancelandoUnComprobanteEnFechaPermitida
                    llRetorno = .t.
                else            
                	if this.lSeEstaCancelandoUnComprobanteEnBaseA
	                    if !this.lSeEstaCancelandoUnComprobanteEnFechaPermitida
							llRetorno = .f.
	                        this.oResolucionesIIBB.Add("RG_86_2000_DGRTUC" )
	                     endif
	                else
	                	llRetorno = .f.
	                endif
                 endif   
            endif       
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeCalcularIIBBGBA( toImpuesto as Object ) as Boolean
		local lnRetorno as Boolean
        llRetorno = .t.

        if this.EsNotaDeCredito() and toImpuesto.TipoImpuesto = 'IIBB' and toImpuesto.Jurisdiccion = "902"
  	        this.EventoSetearDatosAdicionalesParaCalculoDeImpuestos( toImpuesto.Jurisdiccion )	
         	if !this.lForzarAccionCancelatoria
        	
                if this.lSeEstaCancelandoUnComprobanteCompletoEnBaseA 
                    llRetorno = .t.
                else            
                	if this.lSeEstaCancelandoUnComprobanteEnBaseA
                        llRetorno = .f.
                        this.oResolucionesIIBB.Add( "RN_10_08_GBA" )
	                else
	                	llRetorno = .f.
	                endif
                 endif   
            endif       
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SacarJurisdiccionesExcluidas() as Void
	local lnIndPerc as Integer 

		for lnIndPerc = this.oImpuestos.Count to  1 step -1
			if this.oImpuestos.Item[lnIndPerc].TipoImpuesto = 'IIBB' and  this.oImpuestos.Item[lnIndPerc].Excluido
				this.oImpuestos.quitar( lnIndPerc ) 
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SacarPercepcionesConPorcentajeEnCero() as Void
	local lnIndPerc as Integer 

		for lnIndPerc = this.oImpuestos.Count to  1 step -1
			if  (this.oImpuestos.Item[lnIndPerc].Porcentaje = 0 and alltrim( this.oImpuestos.Item[lnIndPerc].Jurisdiccion ) != "913") or ( this.oImpuestos.Item[lnIndPerc].Porcentaje = 0 and alltrim( this.oImpuestos.Item[lnIndPerc].Jurisdiccion ) = "913" and this.JurisdiccionExcluido( this.oCliente.percepciones, "alltrim( oImpuesto.Jurisdiccion_pk ) = '913'" ))
				this.oImpuestos.quitar( lnIndPerc ) 
			endif
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function JurisdiccionExcluido( toImpuestos as Object, tcCondicion ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.

		for each oImpuesto in toImpuestos foxobject
			if &tcCondicion
				llRetorno = oImpuesto.Excluido
			endif
		endfor
		
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ImpuestosCliente()
		local llRestaurarPorcentajesIIBB as Boolean, loCliente as entidad OF entidad.prg, llEncontro as Boolean
		this.ValidarColeccionImpuestos()
		llRestaurarPorcentajesIIBB = .f.
		if !empty( this.CodigoCliente )
			llEncontro = .t.
			try 
				this.oCliente.Codigo = this.CodigoCliente
			catch
				llEncontro = .f.
			endtry
			if llEncontro
				if this.oCliente.ExcluidoOtraPercep.count # 0
					this.SacarPercepcionesLocalesDelCliente( this.oCliente )
				endif 
				if this.oCliente.Percepciones.count # 0
					this.SetearPorcentajesDePercepcionesDeIIBBDelCliente( this.oCliente )
				else 
					llRestaurarPorcentajesIIBB = .t.
				endif 
				this.SetearRestoDePercepcionesDelCliente( this.oCliente )
			endif
		else
			llRestaurarPorcentajesIIBB = .t.
		endif
		if llRestaurarPorcentajesIIBB
			this.RestaurarPorcentajesIIBB()
			this.SetearPorcentajesDePercepcionesDeIIBBTasaCeroDelCliente( this.oCliente )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearPorcentajesDePercepcionesDeIIBBDelCliente( toCliente as Object ) as Void
		local lnIndImp as Integer, lnIndPerc as Integer
		For lnIndImp = 1 To This.oImpuestos.Count
			This.oImpuestos.Item[lnIndImp].Modificado = .F.
		endfor
		if toCliente.Percepciones.Count > 0
			for lnIndImp = This.oImpuestos.Count to 1 step -1
				if This.oImpuestos[lnIndImp ].TipoImpuesto = "IIBB"
					llJurisdiccionSiempre = alltrim( Upper( This.oImpuestos.Item[lnIndImp ].Jurisdiccion )) = this.JurisdiccionSiempreAplica
					llDejarJurisdiccion = .f.
					llExcluida = .f.
					llEncontro = .f.
					for lnIndPerc = 1 to toCliente.Percepciones.Count
						if This.oImpuestos[lnIndImp ].TipoImpuesto = "IIBB" and Alltrim( Upper( toCliente.Percepciones.Item[lnIndPerc ].Jurisdiccion_PK )) = ;
									alltrim( Upper( This.oImpuestos.Item[lnIndImp ].Jurisdiccion )) and ;
									(!toCliente.Percepciones.Item[lnIndPerc ].Excluido or alltrim( Upper( This.oImpuestos.Item[lnIndImp ].Jurisdiccion )) = this.JurisdiccionSiempreAplica)
							llDejarJurisdiccion = .t.
							llEncontro = .t.
							llExcluida = toCliente.Percepciones.Item[lnIndPerc ].Excluido
							exit
						endif
					next
					do case
					case llJurisdiccionSiempre
						if llEncontro and llExcluida
							This.oImpuestos.Remove(lnIndImp )
						endif
					other
						if !llEncontro or llExcluida
							This.oImpuestos.Remove(lnIndImp )
						endif
					endcase
				endif
			next
		endif

		For lnIndPerc = 1 To toCliente.Percepciones.Count
			For lnIndImp = 1 To This.oImpuestos.Count
				If Alltrim( Upper( toCliente.Percepciones.Item[lnIndPerc].Jurisdiccion_PK )) = ;
							alltrim( Upper( This.oImpuestos.Item[lnIndImp].Jurisdiccion )) And ;
							this.oImpuestos.Item[lnIndImp].TipoImpuesto = 'IIBB' and ;
							toCliente.Percepciones.Item[lnIndPerc].FechaExpiracion >= this.FechaDeComprobante
					This.oImpuestos.Item[lnIndImp].Porcentaje = toCliente.Percepciones.Item[lnIndPerc].Porcentaje
					This.oImpuestos.Item[lnIndImp].Modificado = .T.
				endif
				If Alltrim( Upper( toCliente.Percepciones.Item[lnIndPerc].Jurisdiccion_PK )) = ;
							alltrim( Upper( This.oImpuestos.Item[lnIndImp].Jurisdiccion )) And ;
							this.oImpuestos.Item[lnIndImp].TipoImpuesto = 'IIBB' and ;
							alltrim( toCliente.Percepciones.Item[lnIndPerc].Jurisdiccion_PK ) = "913" and toCliente.TasaCeroAplica
							
					This.oImpuestos.Item[lnIndImp].Porcentaje = toCliente.TasaCeroPorcen
					This.oImpuestos.Item[lnIndImp].Modificado = .T.
				endif
			endfor

		Endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearRestoDePercepcionesDelCliente( toCliente as Object ) as Void

		if (toCliente.ExcluidoPercepcionIVA and this.oColaboradorFechasVigentes.EsFechaVigente( toCliente.vigenciahastaiva )) or inlist(toCliente.situacionfiscal_pk,goRegistry.felino.SituacionFiscalClienteConsumidorFinal,goRegistry.felino.SituacionFiscalClienteExento,goRegistry.felino.SituacionFiscalClienteNoAlcanzado) && 3-Consumidor Final
			this.QuitarImpuestoDeColeccionSegunTipo( "IVA" )
		else
			if !empty( toCliente.PercepcionIva_PK )
				this.ActualizarImpuestoDeClienteEnColeccionSegunTipo( "IVA", toCliente.PercepcionIva_PK )
			endif
		endif

		if toCliente.SituacionGanancias = 2 or ( toCliente.ExcluidoPercepcionGanancias and ( this.oColaboradorFechasVigentes.EsFechaVigente( toCliente.vigenciahastagan ))) or inlist(toCliente.situacionfiscal_pk,goRegistry.felino.SituacionFiscalClienteConsumidorFinal )
			this.QuitarImpuestoDeColeccionSegunTipo( "GANANCIAS" )
		else
			if !empty( toCliente.PercepcionGanancias_PK )
				this.ActualizarImpuestoDeClienteEnColeccionSegunTipo( "GANANCIAS", toCliente.PercepcionGanancias_PK )
			endif
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SacarPercepcionesLocalesDelCliente( toCliente as Object ) as Void
		local lnIndImp as Integer, lnIndPerc as Integer

		if toCliente.ExcluidoOtraPercep.Count > 0
			for lnIndPerc = 1 to toCliente.ExcluidoOtraPercep.Count
				for lnIndImp = This.oImpuestos.Count to 1 step -1
					if This.oImpuestos[lnIndImp ].CodigoImpuesto = toCliente.ExcluidoOtraPercep.Item[lnIndPerc ].Codigo_Pk
						This.oImpuestos.Remove(lnIndImp )
						exit
					endif
				next
			next
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function QuitarImpuestoDeColeccionSegunTipo( tcTipoImpuesto as String ) as Void
		local lnI as Integer, lcClave as String
		with this.oImpuestos
			for lnI = 1 To .Count
				if Alltrim( Upper( .Item[lnI].TipoImpuesto ) ) == tcTipoImpuesto
					lcClave = .Item[lnI].CodigoInterno + .Item[lnI].CodigoImpuesto
					.Quitar( lcClave )
					exit
				endif
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarImpuestoDeClienteEnColeccionSegunTipo( tcTipoImpuesto as String, tcCodigoImpuesto as String ) as Void
		local lnI as Integer, loImpuesto as Object, llEncontroImpuesto as Boolean
		llEncontroImpuesto = .f.
		try
			this.oImpuesto.Codigo = tcCodigoImpuesto
			llEncontroImpuesto = .t.
		catch
		endtry
		if llEncontroImpuesto
			with this.oImpuestos
				for lnI = 1 To .Count
					if Alltrim( Upper( .Item[lnI].TipoImpuesto ) ) == tcTipoImpuesto

						.Item[lnI].Porcentaje = this.oImpuesto.Porcentaje
						.Item[lnI].MinimoNoImponible = this.oImpuesto.Monto
						**.Item[lnI].CodigoInterno = ""
						.Item[lnI].Jurisdiccion = this.oImpuesto.Jurisdiccion_PK
						.Item[lnI].Resolucion = this.DarFormatoResolucion( this.oImpuesto.Resolucion, this.oImpuesto.Porcentaje )
						.Item[lnI].lMontosConIvaIncluido = this.lMontosConIvaIncluido
						.Item[lnI].Calcula = .f.
						.Item[lnI].PorcentajeAnterior = this.oImpuesto.Porcentaje
						.Item[lnI].Modificado = .f.
						.Item[lnI].CodigoImpuesto = this.oImpuesto.Codigo
						.Item[lnI].RegimenImpositivo = this.oImpuesto.RegimenImpositivo_PK
						.Item[lnI].BaseDeCalculo = this.oImpuesto.BaseDeCalculo
						.Item[lnI].Minimo = this.oImpuesto.Minimo
						.Item[lnI].MontoBase = 0
						.Item[lnI].RG5329AplicaPorArticulo = this.oImpuesto.RG5329AplicaPorArticulo
	                    .Item[lnI].RG5329Porcentaje  = this.oImpuesto.RG5329Porcentaje
					
						exit
					endif
				endfor
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPorcentajesDeImpuestos( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Float
		local llRetorno as Float
		llRetorno = dodefault( toItem ) + toItem.TasaImpuestoInterno
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Aplicar() as Boolean
		return ( this.nSituacionFiscalCliente != 3 and this.nSituacionFiscalCliente != 0 ) and ;
			this.EsAgenteDePercepcion() and !this.lComprobanteDeExportacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function Calcular( toItem as ItemArticulosVenta of ItemArticulosVenta.prg, toDetalleImpuestos as Object ) as Void
		local lnIndice as Integer, loImpuesto as Impuesto of Impuesto.prg, lnMonto as Integer, loItem as Object, lnTotalMontoImpuesto as integer, ;
			lcClaveItemEnColeccion as String, lnMontoBase as Number, lcCampoMontoBase as String, lcCampo as String, lnTotalMontoBaseImpuesto as integer, ;
			lnPercepcionIvaRG5329 as integer

		loMontosImpuestos = this.ObtenerItemImpuestosPorArticulo( toItem.NroITem )
		this.SetearEnImpuestosDeLaColeccionSiDebenCalcular()
		this.ValidarColeccionImpuestos()
	
		lnPercepcionIvaRG5329 = iif(toItem.PercepcionIvaRG5329 = 0, 1, toItem.PercepcionIvaRG5329)

		if this.TieneImpuestosManuales()
		else
			for lnIndice = 1 to this.oImpuestos.Count
				lnMontoBase = 0
				lnTotalMontoImpuesto = 0
				lnTotalMontoBaseImpuesto = 0
				loImpuesto = this.oImpuestos.Item[lnIndice]
				lcCampo = "Imp" + transform( lnIndice )
				lcCampoMontoBase = "Base" + transform( lnIndice )
				lcCodigoInterno = loimpuesto.codigointerno	
				lcClaveItemEnColeccion = this.oImpuestoscomprobante.Item[lnIndice].codigoInterno + loImpuesto.CodigoImpuesto

				if loImpuesto.Calcula
					loImpuesto.nSituacionFiscalCliente = this.nSituacionFiscalCliente
					loImpuesto.nCoeficienteNetoGravadoIVA = this.nCoeficienteNetoGravadoIVA
					loImpuesto.nCoeficienteParaAplicacionDePercepcionesIVA = this.nCoeficienteParaAplicacionDePercepcionesIVA

					if loImpuesto.AplicaPercepcion()
	
						if loImpuesto.tipoImpuesto = "IVA" 
						
							if ( lnPercepcionIvaRG5329 = 1 and at('RG5329', lcClaveItemEnColeccion)<=0 ) or ( ( lnPercepcionIvaRG5329 = 2 and at('RG5329', lcClaveItemEnColeccion)>0 ) or ( empty(toItem.articulo_pk) and at('RG5329', lcClaveItemEnColeccion)>0 ) )
								
									lnMonto = loImpuesto.Calcular( toItem )
									loMontosImpuestos.&lcCampo = lnMonto
									lnTotalMontoImpuesto = this.ProcesarImpuestos( lcCampo, .t. )

									lnMontoBase = loImpuesto.ObtenerMontoBase( toItem )
									loMontosImpuestos.&lcCampoMontoBase = lnMontoBase
									lnTotalMontoBaseImpuesto = this.ProcesarImpuestos( lcCampoMontoBase, .t. )
									
								if loImpuesto.EsInferiorAlMinimoDeImpuesto( lnTotalMontoImpuesto )
									lnTotalMontoImpuesto = 0
								endif
						    	this.SetearMontoImpuesto( lcClaveItemEnColeccion, lnTotalMontoImpuesto, lnTotalMontoBaseImpuesto )
							endif

						endif 
						if loImpuesto.tipoImpuesto != "IVA"	
							lnMonto = loImpuesto.Calcular( toItem )
							loMontosImpuestos.&lcCampo = lnMonto
							lnTotalMontoImpuesto = this.ProcesarImpuestos( lcCampo, .t. )

							lnMontoBase = loImpuesto.ObtenerMontoBase( toItem )
							loMontosImpuestos.&lcCampoMontoBase = lnMontoBase
							lnTotalMontoBaseImpuesto = this.ProcesarImpuestos( lcCampoMontoBase, .t. )
						endif		 
					endif
				else
					lnMonto = loImpuesto.Calcular( toItem )
					loMontosImpuestos.&lcCampo = 0
					lnTotalMontoImpuesto = this.ProcesarImpuestos( lcCampo, .f. )			
					lnMontoBase = loImpuesto.ObtenerMontoBase( toItem )
					loMontosImpuestos.&lcCampoMontoBase = 0
					lnTotalMontoBaseImpuesto = this.ProcesarImpuestos( lcCampoMontoBase, .t. )
				endif 

				if loImpuesto.EsInferiorAlMinimoDeImpuesto( lnTotalMontoImpuesto )
					lnTotalMontoImpuesto = 0
				endif
              	if loImpuesto.tipoImpuesto != "IVA" 
			    	this.SetearMontoImpuesto( lcClaveItemEnColeccion, lnTotalMontoImpuesto, lnTotalMontoBaseImpuesto )
				endif
				
			endfor
		endif
		this.oImpuestosComprobante.Sumarizar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDetalleImpuestos() as Void
		local loItem as Custom, lnIndice as Integer, llEncontroDatosFiscales as Boolean
		do case
		case empty( alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar ) )
			this.CodigoDeDatoFiscalAplicado = ""
			this.JurisdiccionSiempreAplica = ""
			this.oImpuestosBase = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
		case this.CodigoDeDatoFiscalAplicado # alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			this.CodigoDeDatoFiscalAplicado = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			this.CargarDetalleImpuestosBase()
		endcase
		llEncontroDatosFiscales = .f.
		this.oImpuestos = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
		if this.AplicarPercepcion()
			if this.oImpuestosBase.Count > 0
				for lnIndice = 1 to this.oImpuestosBase.Count
					loImpuesto = this.oImpuestosBase[ lnIndice ]
					if this.AgregarTipoImpuestoSegunSituacionFiscal() and this.AgregarTipoImpuestoSegunTipoConvenio( loImpuesto )
						this.AgregarImpuestoAColeccion( loImpuesto )
					endif	

				endfor 
			endif
		endif
		this.ImpuestosCliente()
		this.SacarPercepcionesConPorcentajeEnCero()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarDetalleImpuestosAccionCancelatoria() as Void
		local loItem as Custom, lnIndice as Integer, llEncontroDatosFiscales as Boolean
		&& cargar oimpuestosbase desde la factura
		if this.oImpuestosBase.Count > 0
			for lnIndice = 1 to this.oImpuestosBase.Count
				loImpuesto = this.oImpuestosBase[ lnIndice ]
				if this.AgregarTipoImpuestoSegunSituacionFiscal()
					this.AgregarImpuestoAColeccion( loImpuesto )
				endif	

			endfor 
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarTipoImpuestoSegunSituacionFiscal() as Boolean
	local llRetorno as Boolean

		llRetorno = type("this.ocliente.situacionfiscal_pk") = "N" and inlist(this.ocliente.situacionfiscal_pk, 4, 7 )
		llRetorno = llRetorno and inlist( left( upper( loImpuesto.tipoimpuesto ), 3 ), "IVA", "GAN" )

		return !llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarTipoImpuestoSegunTipoConvenio( toItemImpuesto as Object ) as Boolean
	local llRetorno as Boolean

		llRetorno = .t.
		if !empty(alltrim(this.CodigoCliente)) and alltrim(upper(toItemImpuesto.TipoImpuesto)) = "IIBB" and ;
				this.oCliente.TipoConvenio = 4
			llRetorno = .f.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarImpuestoAColeccion( toItemImpuesto as Object ) as Void
		local loItem as Object

		loItem = this.oColaboradorPercepciones.ObtenerImpuesto( toItemImpuesto.TipoImpuesto )
		loItem.AddProperty( "Modificado", .f. )
		with loItem
			.TipoImpuesto = toItemImpuesto.TipoImpuesto
			.Porcentaje = toItemImpuesto.Porcentaje
			.MinimoNoImponible = toItemImpuesto.MinimoNoImponible
			.CodigoInterno = toItemImpuesto.CodigoInterno
			.Jurisdiccion = toItemImpuesto.Jurisdiccion
			.Resolucion = toItemImpuesto.Resolucion
			.lMontosConIvaIncluido = toItemImpuesto.lMontosConIvaIncluido
			.Calcula = toItemImpuesto.Calcula
			.PorcentajeAnterior = toItemImpuesto.PorcentajeAnterior
			.Modificado = toItemImpuesto.Modificado
			.CodigoImpuesto = toItemImpuesto.CodigoImpuesto
			.RegimenImpositivo = toItemImpuesto.RegimenImpositivo
			.BaseDeCalculo = toItemImpuesto.BaseDeCalculo
			.Minimo = toItemImpuesto.Minimo
			.MontoBase = 0
			.RG5329AplicaPorArticulo = toItemImpuesto.RG5329AplicaPorArticulo
			.RG5329Porcentaje = toItemImpuesto.RG5329Porcentaje
			
			if !empty(alltrim(this.cODIGOCLIENTE)) and alltrim(upper(toItemImpuesto.TipoImpuesto)) = "IIBB" and ;
				toItemImpuesto.SegunConvenio
				do case
					case this.tipoConvenioCliente = 1 and !empty(toItemImpuesto.convenioLocal )
						.Porcentaje = toItemImpuesto.convenioLocal
					case this.tipoConvenioCliente = 2 and !empty(toItemImpuesto.ConvenioMultilateral )
						.Porcentaje = toItemImpuesto.ConvenioMultilateral
					case inlist(this.tipoConvenioCliente, 0, 3) and !empty(toItemImpuesto.ConvenioNoInscripto ) && 0 = combo vacio
						.Porcentaje = toItemImpuesto.ConvenioNoInscripto
					case inlist(this.tipoConvenioCliente, 4, 5 ) && Exento o 5 = this.porcentaje
					otherwise
						if !empty(toItemImpuesto.ConvenioNoInscripto)
							.Porcentaje = toItemImpuesto.ConvenioNoInscripto
						endif
				endcase
				.PorcentajeAnterior = .Porcentaje
			endif
		endwith
		this.oImpuestos.Agregar( loItem, loItem.CodigoInterno + loItem.CodigoImpuesto )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsAgenteDePercepcion() as Boolean
		return this.oColaboradorPercepciones.EsAgenteDePercepcion()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsAgenteDePercepcionSegunTipoDeImpuesto( tcTipoImpuesto as String ) as Boolean
		return this.oColaboradorPercepciones.EsAgenteDePercepcionSegunTipoDeImpuesto( tcTipoImpuesto )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RestaurarPorcentajesIIBB() as Void
		local lnIndice as Integer
		this.ValidarColeccionImpuestos()

		for lnIndice = 1 to this.oImpuestos.Count
			if alltrim( this.oImpuestos.Item[lnIndice].TipoImpuesto ) == "IIBB"
				this.oImpuestos.Item[lnIndice].Porcentaje = this.oImpuestos.Item[lnIndice].PorcentajeAnterior
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearPorcentajesDePercepcionesDeIIBBTasaCeroDelCliente( toCliente as Object ) as Void
		local lnIndice as Integer
	
		for lnIndice = 1 to this.oImpuestos.Count
			if alltrim( this.oImpuestos.Item[lnIndice].Jurisdiccion ) = "913" and toCliente.TasaCeroAplica and alltrim( this.oImpuestos.Item[lnIndice].TipoImpuesto ) == "IIBB"
				this.oImpuestos.Item[lnIndice].Porcentaje = toCliente.TasaCeroPorcen
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemImpuestosPorArticulo( tnItemArticulo as Integer ) as Object
		local lnIndice as integer, loObjeto as object

		lnIndice = 0
		if vartype( this.oMontosImpuestosPorArticulo  ) = "O"
			lnIndice = this.oMontosImpuestosPorArticulo.GetKey( transform( tnItemArticulo ) )
		endif

		if lnIndice = 0
			loObjeto = this.AgregarItemImpuestosPorArticulo( tnItemArticulo )
		else
			loObjeto = this.oMontosImpuestosPorArticulo[ lnIndice ]
		endif
		
		return loObjeto
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarItemImpuestosPorArticulo( tnItemArticulo as Integer ) as Object
		local loRetorno as Object, lnIndice as integer, loImpuesto as Impuesto of Impuesto.prg, loItem as Object

		loRetorno = newobject( "custom" )
		if vartype( this.oMontosImpuestosPorArticulo  ) != "O"
			this.oMontosImpuestosPorArticulo  = _Screen.zoo.crearobjeto( "ZooColeccion" )
		endif
		this.ValidarColeccionImpuestos()
		
		with loRetorno
			.AddProperty( "nItemArticulo", tnItemArticulo  )

			for lnIndice = 1 to this.oImpuestos.count 
				loImpuesto = this.oImpuestos[ lnIndice ]
			endfor
			
			for lnIndice = 1 to this.oImpuestosBase.count 
				.AddProperty( "Imp" + transform( lnIndice ), 0 )
				.AddProperty( "Base" + transform( lnIndice ), 0 )
			endfor
		endwith

		if !this.oMontosImpuestosPorArticulo.Buscar( transform( tnItemArticulo ))
			this.AgregarItemAColeccionDeImpuestosPorArticulo( loRetorno, transform( tnItemArticulo ) )
		endif
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarDetalleImpuestosBase() as Void
		local loItem as Custom, lnIndice as Integer, llEncontroDatosFiscales as Boolean
		llEncontroDatosFiscales = .f.

		if !this.lDestroy and ( vartype( this.oImpuestosBase) != "O" or isnull( this.oImpuestosBase) )
			this.oImpuestosBase = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
		endif
	
		if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar ) and !this.EsRecibo()
			try 
				This.oEntidadDatosFiscales.Codigo = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
				this.JurisdiccionSiempreAplica = This.oEntidadDatosFiscales.RetPercSiempreSegunJurisdiccion_PK
				llEncontroDatosFiscales = .t.
			catch
			endtry
			if llEncontroDatosFiscales
				this.JurisdiccionSiempreAplica = this.oEntidadDatosFiscales.RetPercSiempreSegunJurisdiccion_PK
				this.oImpuestosBase = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
				
				for lnIndice = 1 to This.oEntidadDatosFiscales.PerceIIBB.Count
					if this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].Aplicacion = "PRC" ;
					 and ( this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].Tipo_PK <> "IIBB" ;
						   or ( this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].Tipo_PK = "IIBB" and !empty( This.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].Jurisdiccion ) ) )
						this.AgregarImpuestoAColeccionBase( This.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice] )
					endif
									
					if this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].Tipo_PK = "IVA" and this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].Aplicacion = "PRC" and this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].RG5329AplicaPorArticulo  &&this.oEntidadDatosFiscales.oimpuestos.aplicaporarticulo

					   loItem = this.oEntidadDatosFiscales.PerceIIBB.ClonarItemAuxiliar( lnIndice )				 
					   loItem.Codigointerno = substr(loitem.CodigoInterno,1,len(loitem.CodigoInterno)-6) + 'RG5329'
					   loItem.BaseDeCalculo = 'RG5329'
					   loItem.Tag = 'RG5329'
					   loItem.porcentaje = this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].RG5329porcentaje 
					   loItem.RG5329AplicaPorArticulo = this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].RG5329AplicaPorArticulo
					   loItem.RG5329Porcentaje = this.oEntidadDatosFiscales.PerceIIBB.Item[lnIndice].RG5329porcentaje
					   this.AgregarImpuestoAColeccionBase( loItem )
					   loItem = null	   
					endif
					
				endfor 
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarImpuestoAColeccionBase( toItemImpuesto as Object ) as Void
		local loItem as Object
		loItem = this.oColaboradorPercepciones.ObtenerImpuesto( toItemImpuesto.Tipo_PK )
		loItem.AddProperty( "Modificado", .f. )
		with loItem
			.TipoImpuesto = toItemImpuesto.Tipo_PK
			.Porcentaje = toItemImpuesto.Porcentaje
			.MinimoNoImponible = toItemImpuesto.MinimoNoImponible
			.CodigoInterno = toItemImpuesto.CodigoInterno
			.Jurisdiccion = toItemImpuesto.Jurisdiccion
			.Resolucion = this.DarFormatoResolucion( toItemImpuesto.Resolucion, toItemImpuesto.Porcentaje )
			.lMontosConIvaIncluido = this.lMontosConIvaIncluido
			.Calcula = .f.
			.PorcentajeAnterior = toItemImpuesto.Porcentaje
			.Modificado = .f.
			.CodigoImpuesto = toItemImpuesto.Impuesto_PK
			.RegimenImpositivo = toItemImpuesto.RegimenImpositivo
			.BaseDeCalculo = toItemImpuesto.BaseDeCalculo
			.Minimo = toItemImpuesto.MinimoDeRetencion
			.MontoBase = 0
			.SegunConvenio = toItemImpuesto.SegunConvenio
			.ConvenioLocal = toItemImpuesto.ConvenioLocal
			.ConvenioMultilateral = toItemImpuesto.ConvenioMultilateral
			.ConvenioNoInscripto = toItemImpuesto.ConvenioNoInscripto
			.RG5329AplicaPorArticulo   = toItemImpuesto.RG5329AplicaPorArticulo   
			.RG5329Porcentaje = toItemImpuesto.RG5329Porcentaje
		endwith
		this.oImpuestosBase.Agregar( loItem, loItem.CodigoInterno + loItem.CodigoImpuesto )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oEntidadDatosFiscales_Access() as Object
		local loRetorno as Object
		loRetorno = dodefault()
		if !this.ldestroy and (vartype( this.oEntidadDatosFiscales ) # 'O' or isnull( this.oEntidadDatosFiscales ))
			this.CargarDetalleImpuestosBase()
		endif
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFechaDeComprobante( tdFecha as Date ) as Void
		if !empty( tdFecha )
			this.FechaDeComprobante = tdFecha
			this.CargarDetalleImpuestos()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetearDatosAdicionalesParaCalculoDeImpuestos( tcJurisdiccion as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CalcularImpuestoEnBaseAGravamen( toDetalle as detalle OF detalle.prg, toColImpuestos as zoocoleccion OF zoocoleccion.prg ) as Void
		local lnTotalMontoImpuesto as Float, lnMontoBase as Float, lcClaveItemEnColeccion as String, loImpuesto as Collection, ;
				lnTotalMontoImpuesto as Float, lnTotalMontoBaseImpuesto as Float, lnMontoBaseTotal as Float, lnMontoBaseIVA as float, ;
				lnTotalMontoImpuestoRG5329 as Float,lnTotalMontoBaseImpuestoRG5329 as Float, lnMontoNoGravado as Float, lnTotalMontoImpuesto2 as Float, ;
				lnTotalMontoBaseImpuesto2 as Float, loColMontosImpuestos as Collection
				
		this.TotalSinImpuestosMenosDescuentosMasRecargos = 0
		lnMontoBase = 0
		lnMontoBaseTotal = 0
		lnMontoBaseIVA = 0
		lnTotalMontoImpuesto = 0
		lnTotalMontoBaseImpuesto = 0
		this.nPorcentajeDescuento = 0
		this.nPorcentajeRecargo = 0
		
		for each loItem IN toDetalle FOXOBJECT
			lnMontoBase = lnMontoBase + round(loItem.MontoNoGravado,4)
			if loItem.PorcentajeDeIVA > 0
				lnMontoBaseIVA = lnMontoBaseIVA + round(loItem.MontoNoGravado,4)
			endif
		next
		this.TotalSinImpuestosMenosDescuentosMasRecargos = lnMontoBase
		this.nCoeficienteNetoGravadoIVA = goLibrerias.RedondearSegunPrecision( lnMontoBaseIVA / lnMontoBase, PRECISIONENCALCULOS )
		this.SetearEnImpuestosDeLaColeccionSiDebenCalcular()
		this.ValidarColeccionImpuestos()
		this.EventoCargarPorcentajeDescuentoRecargo()	
		loColMontosImpuestos = Null
		loColMontosImpuestos = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		loColMontosImpuestos.AddProperty("TotalMontoImpuesto",0)
		loColMontosImpuestos.AddProperty("TotalMontoBaseImpuesto",0)	
		if this.TieneImpuestosManuales()
		else
			for lnIndice = 1 to this.oImpuestos.Count
				lnTotalMontoImpuesto = 0
				loImpuesto = this.oImpuestos.Item[lnIndice]
				lcClaveItemEnColeccion = loImpuesto.CodigoInterno + loImpuesto.CodigoImpuesto

				if lnMontoBase # 0 and loImpuesto.Calcula
					
					if alltrim(loImpuesto.TipoImpuesto) == "IVA" 				
						loColMontosImpuestos = this.ObtenerMontosImpuestosIVA( loColMontosImpuestos, toDetalle, toColImpuestos, loImpuesto, lcClaveItemEnColeccion )		
						this.SetearMontoImpuesto( lcClaveItemEnColeccion, loColMontosImpuestos.TotalMontoImpuesto, loColMontosImpuestos.TotalMontoBaseImpuesto )		
					else
						lnTotalMontoBaseImpuesto = iif( alltrim( loImpuesto.BaseDeCalculo ) = "GRA", lnMontoBaseIVA, lnMontoBase )
						lnTotalMontoImpuesto = goLibrerias.RedondearSegunPrecision( lnTotalMontoBaseImpuesto * loImpuesto.Porcentaje / 100, PRECISIONENCALCULOS )
						if lnTotalMontoBaseImpuesto < loImpuesto.MinimoNoImponible or lnTotalMontoImpuesto < loImpuesto.Minimo
							lnTotalMontoImpuesto = 0
							lnTotalMontoBaseImpuesto = 0
						endif
						this.SetearMontoImpuesto( lcClaveItemEnColeccion, lnTotalMontoImpuesto, lnTotalMontoBaseImpuesto )
					endif
				else
					lcClaveItemEnColeccion = loImpuesto.CodigoInterno + loImpuesto.CodigoImpuesto
					this.SetearMontoImpuesto( lcClaveItemEnColeccion, 0, 0 )
				endif
        	endfor
		endif
		this.oImpuestosComprobante.Sumarizar()	
 	endfunc
 
	*-----------------------------------------------------------------------------------------
	function ObtenerMontosImpuestosIVA( toColMontosImpuestos, toDetalle as Object, toColImpuestos as Object, toImpuesto as Object, tcClaveItemEnColeccion as String ) as Collection
		local lnTotalMontoImpuestoRG5329 as Float, lnTotalMontoBaseImpuestoRG5329 as Float, lnTotalMontoImpuesto2 as Float, lnTotalMontoBaseImpuesto2 as Float, ;
		 lnMontoNoGravado as Float, oColMontosImpuestos as Collection
		
		lnTotalMontoImpuestoRG5329 = 0 
		lnTotalMontoBaseImpuestoRG5329 = 0
		lnTotalMontoImpuesto2 = 0
		lnTotalMontoBaseImpuesto2 = 0
		lnMontoNoGravado = 0 
		toColMontosImpuestos.TotalMontoImpuesto = 0		
		toColMontosImpuestos.TotalMontoBaseImpuesto = 0
				
		for each loArticulo in toColImpuestos FOXOBJECT
							
			if toImpuesto.RG5329AplicaPorArticulo and loArticulo.nPorcentaje > 0 and (loArticulo.nPercepcionIvaRG5329 = 2 or loArticulo.nPercepcionIvaRG5329 = 3 )

				lnMontoNoGravado = loArticulo.nMontoNoGravado - ( loArticulo.nMontoNoGravado * abs( this.nPorcentajeDescuento ) / 100 ) 
				lnMontoNoGravado = lnMontoNoGravado + ( lnMontoNoGravado * abs ( this.nPorcentajeRecargo ) / 100 )
										
				if loArticulo.nPercepcionIvaRG5329 = 2
					loCoeficiente = goLibrerias.RedondearSegunPrecision( loArticulo.nPorcentaje / this.nIvainscriptos, PRECISIONENCALCULOS )
					lnTotalMontoImpuestoRG5329 = goLibrerias.RedondearSegunPrecision( lnTotalMontoImpuestoRG5329 + lnMontoNoGravado * toImpuesto.rg5329porcentaje / 100 * loCoeficiente, PRECISIONENCALCULOS )
					lnTotalMontoBaseImpuestoRG5329 = lnTotalMontoBaseImpuestoRG5329 + lnMontoNoGravado 
				endif
											
				loCoeficiente = goLibrerias.RedondearSegunPrecision( loArticulo.nPorcentaje / this.nIvainscriptos, PRECISIONENCALCULOS )
				lnTotalMontoImpuesto2 = goLibrerias.RedondearSegunPrecision( lnTotalMontoImpuesto2 + lnMontoNoGravado * toImpuesto.Porcentaje / 100 * loCoeficiente, PRECISIONENCALCULOS )
				lnTotalMontoBaseImpuesto2 = lnTotalMontoBaseImpuesto2 + lnMontoNoGravado 
			endif
		endfor
								
		for each loAlicuota in toDetalle FOXOBJECT
			if loAlicuota.PorcentajeDeIVA > 0
				loCoeficiente = goLibrerias.RedondearSegunPrecision( loAlicuota.PorcentajeDeIVA / this.nIvainscriptos, PRECISIONENCALCULOS )
				toColMontosImpuestos.TotalMontoImpuesto = goLibrerias.RedondearSegunPrecision( toColMontosImpuestos.TotalMontoImpuesto + loAlicuota.MontoNoGravado * toImpuesto.Porcentaje / 100 * loCoeficiente, PRECISIONENCALCULOS )
				toColMontosImpuestos.TotalMontoBaseImpuesto = toColMontosImpuestos.TotalMontoBaseImpuesto + loAlicuota.MontoNoGravado		
			endif	
		next
								
		toColMontosImpuestos.TotalMontoImpuesto = toColMontosImpuestos.TotalMontoImpuesto - lnTotalMontoImpuesto2
		toColMontosImpuestos.TotalMontoBaseImpuesto = toColMontosImpuestos.TotalMontoBaseImpuesto - lnTotalMontoBaseImpuesto2
									
		if lnTotalMontoBaseImpuesto2 < toImpuesto.MinimoNoImponible or lnTotalMontoImpuesto2 < toImpuesto.Minimo
			lnTotalMontoImpuestoRG5329 = 0
			lnTotalMontoBaseImpuestoRG5329 = 0
		endif
		
		if toColMontosImpuestos.TotalMontoBaseImpuesto < toImpuesto.MinimoNoImponible or toColMontosImpuestos.TotalMontoImpuesto < toImpuesto.Minimo
			toColMontosImpuestos.TotalMontoImpuesto = 0
			toColMontosImpuestos.TotalMontoBaseImpuesto = 0
		endif
  								
		if at('RG5329', tcClaveItemEnColeccion) > 0 and toImpuesto.RG5329AplicaPorArticulo
			toColMontosImpuestos.TotalMontoBaseImpuesto = lnTotalMontoBaseImpuestoRG5329
			toColMontosImpuestos.TotalMontoImpuesto = lnTotalMontoImpuestoRG5329	
		endif
		
		return toColMontosImpuestos
	endfunc 

enddefine
