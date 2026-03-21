define class Ent_Valor as Din_EntidadValor of Din_EntidadValor.Prg

	#IF .f.
		Local this as Ent_Valor of Ent_Valor.prg
	#ENDIF
	
	lEstoyEnChile = .F.
	lTengoCFIBM = .F.
	lValidarEquivalenciaAFIP = .f.
	oTipoDeValores = null
	nCodigoDeValoresTipoTarjeta = 3
	nCodigoDeValoresTipoChequedeTerceros = 4
	nCodigoDeValoresTipoPagoElectronico = 11
	nCodigoDeValoresTipoAjusteDeCupones = 10
	nCodigoDeValoresTipoChequePropio = 9
	nCodigoDeValoresTipoCuentaBancaria = 13
	llPermitirTipoDeValorAjusteDeCupon = .f.
	TipoParaFiltrarEnBuscador = 0
	oCajaSaldos = null
	oCajaAuditoria = null
	oCajaEstado = null
	oCtaCte = null
	oCtaCteCompra = null
	lPreguntarSiDebeEliminar = .t.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		
		this.lEstoyEnChile = ( GoParametros.Nucleo.DatosGenerales.Pais == 2 )
		
		if Vartype( goControladorFiscal ) = "O" and !isnull( goControladorFiscal )
			this.lTengoCFIBM = goControladorFiscal.lImprimeCheque
			this.lValidarEquivalenciaAFIP = goControladorFiscal.DebeValidarEquivalenciaDeValoresAFIP()
		endif
		this.HabilitarPropiedadesCheques( this.HabilitarAtributosCheques() )
		this.lHabilitarFacturaelectronica = this.lEstoyEnChile
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		this.HabilitarPropiedadesCheques( this.HabilitarAtributosCheques() )
		this.lHabilitarFacturaelectronica = this.lEstoyEnChile
		this.lHabilitarPersonalizarComprobante = .T.
		this.lHabilitarPermiteVuelto = .T.
		this.lHabilitarPermiteModificarFecha = .F.
		this.PermiteModificarFecha = .F.
		this.PersonalizarComprobante = .F.
		this.PermiteVuelto = .F.
		this.lHabilitarVisualizarEnCaja = .T.
		this.VisualizarEnCaja = .F.
		this.lHabilitarChequeElectronico = .F.
		this.lHabilitarHabilitarRetiroEfectivo = .F.
		this.lHabilitarMontoMaximoDeRetiro = .F.
		this.lHabilitarValorParaRetiroDeEfectivo_pk = .f.
		this.lhabilitarvalorDeAcreditacion_pk = .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function Modificar() as Void	
		dodefault()
		this.HabilitarPropiedadesCheques( this.HabilitarAtributosCheques() )
		this.lHabilitarFacturaelectronica = this.lEstoyEnChile
		this.lHabilitarPersonalizarComprobante = this.HabilitarAtributoPersonalizarComprobante()
		this.lHabilitarPermiteVuelto = this.HabilitarAtributoPermiteVuelto()
		this.lHabilitarTipo = ( this.Tipo != this.nCodigoDeValoresTipoAjusteDeCupones )
		This.lHabilitarModoRedondeo = iif( This.ModoRedondeo = 0, .T., iif( inlist( this.Tipo, 1, 2 ), .T., .F. ) )
		this.HabilitarPermiteModificarFecha()
		this.HabilitarPermiteModificarVisualizarEnCaja()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		local llMensajeVta as Boolean, llMensajeCpra as Boolean
		* Verificar que el valor no se esté utilizando en la caja, en la auditoria
		
		with this
			.lPreguntarSiDebeEliminar = .t.
			
			.ValidarSaldoEnCajaYAuditoria()	

	* Verificar que el valor no se esté utilizando en Cta Cte Vta y en Cta Cta Compra, etc.
			if .ValidarSaldoCtaCteParaElValor( .oCtaCte ) 
				llMensajeVta = .t.
			endif
			if 	.ValidarSaldoCtaCteParaElValor( .oCtaCteCompra )
				llMensajeCpra = .t.
			endif
			if llMensajeVta or llMensajeCpra
				.lPreguntarSiDebeEliminar = .f.
				.EventoPreguntarSiEliminaPorCtaCte( llMensajeVta, llMensajeCpra )
			endif
			if .lPreguntarSiDebeEliminar
				dodefault()
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiEliminaPorCtaCte( tlMensajeVta, tlMensajeCpra ) as Void
		&& Evento para pedir confirmacion del usuario
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaldoEnCajaYAuditoria() as Void
		local lcXmlCajas as String, lcXmlCajaAuditoria as String, lcMensaje as String, lcXmlValoresEnCaja as String
		
		*Recorro todas las cajas buscando si se utiliza el valor
		lcXmlCajas = This.oCajaEstado.oAd.ObtenerDatosEntidad( "ID,IDCAJAAUDITORIA" )
		if !empty( lcXmlCajas )
			This.XmlACursor( lcXmlCajas, "curCajas" )
			scan all
				if !goCaja.EstaAbierta( curCajas.Id )
					lcXmlCajaAuditoria = This.oCajaAuditoria.oAd.ObtenerDatosDetalleDetalleValoresAuditoria( "VALOR,MONTO", "IDCAJAAUDITORIA = " + transform( curCajas.IdCajaAuditoria ) + " and VALOR = '" + This.Codigo + "' and Monto != 0" )
					this.XmlACursor( lcXmlCajaAuditoria, "curDetCajaAuditoria" )
					if reccount( "curDetCajaAuditoria" ) > 0
						lcMensaje = "El valor fue utilizado en el último cierre de la caja nº" + transform( curCajas.Id ) + " y tiene saldo pendiente. No puede eliminarse."
						use in select( "curDetCajaAuditoria" )
					endif
				else
					lcXmlValoresEnCaja = this.oCajaSaldos.oAd.ObtenerDatosEntidad( "VALOR", "NUMCAJA = " + transform( curCajas.Id ) + " and VALOR = '" + this.Codigo + "' and SALDO != 0" )
					This.XmlACursor( lcXmlValoresEnCaja, "curCajaSaldos" )
					if reccount( "curCajaSaldos" ) > 0
						lcMensaje = "El valor tiene un saldo pendiente en la caja nº" + transform( curCajas.Id ) + ". No puede eliminarse."
						use in select( "curCajaSaldos" )
					endif
				endif
				if !empty( lcMensaje )
					use in select( "curCajas" )
					goServicios.Errores.LevantarExcepcion( lcMensaje )
				endif
			endscan
			use in select( "curCajas" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaldoCtaCteParaElValor( toCtaCte as Object ) as Boolean
		local  lcXmlCtaCte as String, lcMensaje as String, lcTipoCtaCte as String, llRetorno as Boolean

		if this.Tipo = 6  && Cta Cte
			lcXmlCtaCte = toCtaCte.oAd.ObtenerDatosEntidad( "VALOR", "SALDOCC != 0 and VALOR = '" + this.Codigo + "' ")
			if !empty( lcXmlCtaCte )
				This.XmlACursor( lcXmlCtaCte, "curCtaCte" )
				if reccount( "curCtaCte" ) > 0
					llRetorno = .t.
				endif
				use in select( "curCtaCte" )
			endif
		endif
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function oCajaEstado_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaEstado ) = 'O'
			this.oCajaEstado = _Screen.zoo.InstanciarEntidad( 'CAJAESTADO' )
		endif
		return this.oCajaEstado
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oCajaSaldos_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaSaldos ) = 'O'
			this.oCajaSaldos = _Screen.zoo.InstanciarEntidad( 'CAJASALDOS' )
		endif
		return this.oCajaSaldos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oCajaAuditoria_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaAuditoria ) = 'O'
			this.oCajaAuditoria = _Screen.zoo.InstanciarEntidad( 'CAJAAUDITORIA' )
		endif
		return this.oCajaAuditoria
	endfunc

	*-----------------------------------------------------------------------------------------
	function oCtaCte_Access() as variant
		if !this.ldestroy and !vartype( this.oCtaCte ) = 'O'
			this.oCtaCte = _Screen.zoo.InstanciarEntidad( 'CTACTE' )
		endif
		return this.oCtaCte
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oCtaCteCompra_Access() as variant
		if !this.ldestroy and !vartype( this.oCtaCteCompra ) = 'O'
			this.oCtaCteCompra = _Screen.zoo.InstanciarEntidad( 'CTACTECOMPRA' )
		endif
		return this.oCtaCteCompra
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault()
		if ( this.Tipo != this.nCodigoDeValoresTipoAjusteDeCupones ) and this.lValidarEquivalenciaAFIP and empty( this.EquivCfEpson )
			this.AgregarInformacion( "Debe cargar el campo Controladores fiscales R.G. 3561/13" )
			llRetorno = .F.
		endif
		
		if this.lTengoCFIBM and empty( this.EquivCfIbm )
			this.AgregarInformacion( "Debe cargar el campo Controlador fiscal IBM" )
			llRetorno = .F.
		endif

		if this.lHabilitarFacturaelectronica and empty( this.Facturaelectronica )
			this.AgregarInformacion( "Debe cargar el campo Factura Electrónica" )
			llRetorno = .F.
		endif

		if this.tipo == this.nCodigoDeValoresTipoTarjeta and this.CargaManual()
			if this.ExisteAtributo( "TipoTarjeta" ) and empty( this.TipoTarjeta )
				this.AgregarInformacion( "Debe cargar el campo Tipo de Tarjeta de la solapa Tarjeta" )
				llRetorno = .F.
			endif

			if this.RequiereOperadoraDeTarjetas() and empty( this.oPeradoraTarjeta_PK )
				this.AgregarInformacion( "Debe cargar el campo Operadora de Tarjeta de la solapa Tarjeta." )
				llRetorno = .F.
			endif
		endif
        
        if this.tipo == this.nCodigoDeValoresTipoPagoElectronico and this.CargaManual()
            if this.ExisteAtributo( "PRESTADOR" ) and empty( this.Prestador )
                this.AgregarInformacion( "Debe cargar el campo Prestador de la solapa Pago electrónico." )
                llRetorno = .F.
            endif
        endif

		if this.Descuento > 0 and this.VerificarSiTieneRecargos()
			this.AgregarInformacion( "No se puede ingresar un descuento y recargos en un mismo valor." )
			llRetorno = .F.
		endif
		
		if this.Descuento < 0 
			this.AgregarInformacion( "No se puede ingresar un descuento negativo." )
			llRetorno = .F.
		endif
		
		if this.HabilitarRetiroEfectivo
			if this.ExisteAtributo( "MontoMaximoDeRetiro" ) and this.MontoMaximoDeRetiro <= 0
				this.AgregarInformacion( "El monto máximo de retiro debe ser mayor a cero." )
				llRetorno = .F.
			endif
			
			if ( empty(this.ValorDeAcreditacion_pk ) or ( this.ValorDeAcreditacion.Tipo != 1 and this.ValorDeAcreditacion.Tipo != 13 ) )
				this.AgregarInformacion( "El valor ingresado de acreditación es obligatorio y debe ser de tipo moneda local o cuenta bancaria." )
				llRetorno = .F.
			endif
			
			if ( empty(this.ValorParaRetiroDeEfectivo_pk ) or this.ValorParaRetiroDeEfectivo.Tipo != 1 )
				this.AgregarInformacion( "El valor ingresado para retiro de efectivo es obligatorio y debe ser de tipo moneda local." )
				llRetorno = .F.
			endif
			
			if alltrim( this.ValorParaRetiroDeEfectivo_pk ) = alltrim( this.ValorDeAcreditacion_pk )
				this.AgregarInformacion( "El valor para retiro de efectivo y el valor de acreditación deben ser distintos." )
				llRetorno = .F.
			endif
		endif

		llRetorno = llRetorno and this.ValidarUnicidadEnItemsDePlanes()

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function NoArrastraSaldo() as Boolean
		return !this.ArrastraSaldo
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Validar_Arrastrasaldo( txVal as variant ) as Boolean
		if txVal = .T.
			if goservicios.parametros.felino.gestiondeventas.utilizafondofijo
				if !empty( this.codigo ) and this.ValidarCoincidenciaConValorFondoFijo( this.codigo )
					goMensajes.Advertir( "Tenga en cuenta que este valor está configurado para utilizarlo como fondo fijo." + chr(13) +;
					 "Compruebe los datos ingresados en Configuración --> Parámetros --> Gestión de ventas --> Caja." )
				endif
			endif
		endif
		return dodefault( txVal )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCoincidenciaConValorFondoFijo( tcValor as String ) as Boolean
	local llRetorno as Boolean
		llRetorno = .f.
		if upper( alltrim( tcValor ) ) = upper( alltrim( goservicios.parametros.felino.gestiondeventas.valorsugeridoparaelfondofijo ) )
			llRetorno = .t.
		endif	

		return llRetorno
			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RequiereOperadoraDeTarjetas() as Boolean
		local llRetorno as Boolean, lcModulo as String, llTieneModuloTarjeta as Boolean, loModulos as Object
		llRetorno = .f.
		lcModulo = "T"

		if this.ExisteAtributo( "OperadoraTarjeta_pk" )
			loModulos = goServicios.Modulos.ObtenerModulos()
			llTieneModuloTarjeta = loModulos.Buscar( lcModulo )
			if llTieneModuloTarjeta
				llRetorno = goServicios.Modulos.ModuloHabilitado( lcModulo )
			endif
		endif

		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function ProcesarDespuesDeSetear_Tipo() as void
		if this.HabilitarAtributosCheques()
			this.HabilitarPropiedadesCheques( .t. )
		else
			try
				this.HabilitarPropiedadesCheques( .t. )
				this.PagueseA = ""
				this.Leyenda = ""
				this.BcoADep_PK = ""
				this.ImprimeChequeCFiscal = .F.
				this.CtaCteADep = ""
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				this.HabilitarPropiedadesCheques( .f. )
			endtry
		endif
		this.HabilitarPersonalizarComprobante()
		this.HabilitarPermiteVuelto()
		this.HabilitarArqueoPorTotales()
		this.HabilitarChequeElectronico()
		this.HabilitarModoRedondeo()
		this.HabilitarPermiteModificarFecha()
		this.HabilitarPermiteModificarVisualizarEnCaja()
		this.HabilitarHabilitarRetiroEfectivo()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarDespuesDeSetear_Prestador() as void
		this.HabilitarHabilitarRetiroEfectivo()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarChequeElectronico() as Void
		if inlist( this.Tipo, 12, 14)
			this.lHabilitarChequeElectronico = .T.
		else
			this.lHabilitarChequeElectronico = .T.
			this.ChequeElectronico = .F.
			this.lHabilitarChequeElectronico = .F.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitarPropiedadesCheques( habilita as boolean ) as void
		this.lHabilitarPagueseA = habilita
		this.lHabilitarLeyenda = habilita
		this.lHabilitarBcoADep_PK = habilita
		this.lHabilitarCtaCteADep = habilita
		this.lHabilitarImprimeChequeCFiscal = habilita
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarPersonalizarComprobante() as Void
		this.lHabilitarPersonalizarComprobante = .T.
		if this.HabilitarAtributoPersonalizarComprobante()
			this.PersonalizarComprobante = .F.
		else
			this.PersonalizarComprobante = .T.
			this.lHabilitarPersonalizarComprobante = .F.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarHabilitarRetiroEfectivo() as Void
		if this.tipo = 3 or (this.Tipo == 11 and inlist( this.prestador, "MPQR2" ))
			this.lHabilitarHabilitarRetiroEfectivo = .T.
		else
			this.lHabilitarHabilitarRetiroEfectivo = .F.
			this.lHabilitarMontoMaximoDeRetiro = .F.
			this.lHabilitarValorParaRetiroDeEfectivo_pk = .F.
			this.lhabilitarvalorDeAcreditacion_pk = .F.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function setear_habilitarretiroefectivo( tx_val as Variant )
		
		if vartype( tx_val ) = "L"
			if !tx_val 
				this.ValorDeAcreditacion_pk = ""
				this.ValorParaRetiroDeEfectivo_pk = ""
				this.MontoMaximoDeRetiro = 0
			endif
			this.lHabilitarMontoMaximoDeRetiro = tx_val
			this.lHabilitarValorParaRetiroDeEfectivo_pk = tx_val
			this.lhabilitarvalorDeAcreditacion_pk = tx_val
		endif
	
		dodefault( tx_val )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAtributoPersonalizarComprobante() as boolean
		local loEstadoAtributos as Object
		loEstadoAtributos = This.oTipoDeValores.ObtenerAtributos( this.Tipo )
		return !loEstadoAtributos.PersonalizarComprobante
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarPermiteVuelto() as Void
		this.lHabilitarPermiteVuelto = .T.
		if this.HabilitarAtributoPermiteVuelto()
			this.PermiteVuelto = .T.			
		else
			this.PermiteVuelto = .F.
			this.lHabilitarPermiteVuelto = .F.
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAtributoPermiteVuelto() as boolean
		local loEstadoAtributos as Object
		loEstadoAtributos = This.oTipoDeValores.ObtenerAtributos( this.Tipo )
		return loEstadoAtributos.PermiteVuelto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsImprimible() as boolean
		return this.Tipo = this.nCodigoDeValoresTipoChequedeTerceros and this.ImprimeChequeCFiscal
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarAtributosCheques() as boolean
		return ( this.Tipo = this.nCodigoDeValoresTipoChequedeTerceros and this.lTengoCFIBM )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Personaliza() as boolean
		return this.PersonalizarComprobante
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaja( tnNumeroDeCajaEnProcesoDeCierre as Integer ) as Integer
		local lnCaja as Integer
		if empty( This.Caja_Pk )
			if vartype(tnNumeroDeCajaEnProcesoDeCierre) = 'N' and tnNumeroDeCajaEnProcesoDeCierre != 0
				lnCaja = tnNumeroDeCajaEnProcesoDeCierre
			else
				lnCaja = goCaja.ObtenerNumeroDeCajaActiva()
			endif
		else
			lnCaja = This.Caja_Pk 	
		EndIf
		return lnCaja
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oTipoDeValores_Access() as variant
		if !this.ldestroy and !vartype( this.oTipoDeValores ) = 'O'
			this.oTipoDeValores = _Screen.zoo.CrearObjeto( 'Din_TipoDeValores' )
		endif
		return this.oTipoDeValores
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCuotaGrilla( tnItem as Integer, toPlanesDisponibles as zoocoleccion OF zoocoleccion.prg ) as Void
		local lnCuota as Integer
		lnCuota = 1

		if this.Tipo = this.nCodigoDeValoresTipoTarjeta and toPlanesDisponibles.Count >= tnItem
			lnCuota = toPlanesDisponibles.Item[ tnItem ].Cuotas
		endif

		return lnCuota
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerRecargoTarjeta( tnCuota as Integer, toPlanesDisponibles as zoocoleccion OF zoocoleccion.prg ) as Double
		local lnRecargo as Integer

		lnRecargo = 0
		if this.Tipo = this.nCodigoDeValoresTipoTarjeta
			loItem = this.BuscarDatosPorCuota( tnCuota, toPlanesDisponibles )

			if loItem.Recargo > 0
				lnRecargo = loItem.Recargo
			endif
		endif
				
		return lnRecargo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarDatosPorCuota( tnCuota as Integer, toPlanesDisponibles as zoocoleccion OF zoocoleccion.prg ) as Object
		local i as Integer, loItem as Object
		
		loItem = this.CrearObjeto( "ItemAuxiliar", "Din_DetalleValorDetallePlanes.prg" )
		
		for i = 1 to toPlanesDisponibles.Count
			loItem = toPlanesDisponibles.Item[ i ]

			if loItem.Cuotas = tnCuota
				exit
			endif
		endfor

		return loItem
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDePlanesConRecargo( tnMontoTotal as Double ) as Integer
		local i as Integer, lnRetorno as Integer, loPlanesDisponibles as zoocoleccion OF zoocoleccion.prg
		lnRetorno = 0
		loPlanesDisponibles = this.ObtenerPlanesDisponibles( tnMontoTotal )
		for i = 1 to loPlanesDisponibles.Count
			if this.ObtenerRecargoTarjeta( this.ObtenerCuotaGrilla( i, loPlanesDisponibles ), loPlanesDisponibles ) > 0
				lnRetorno = lnRetorno + 1
			endif
		endfor

		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
	
		if !inlist( this.Tipo, 1, 2 ) and This.ModoRedondeo = 2
			llRetorno = .F.
			this.AgregarInformacion( "El tipo de valor seleccionado no permite aplicar el redondeo al total del valor." )
		endif
	
		if this.Tipo == this.nCodigoDeValoresTipoTarjeta
		else
			this.LimpiarDatosTarjeta()
		endif

		if this.Tipo == this.nCodigoDeValoresTipoPagoElectronico
        else
            this.LimpiarDatosPrestador()
        endif
	

		if this.Tipo == this.nCodigoDeValoresTipoCuentaBancaria and !empty( this.CuentaBancaria_pk )
			if empty( this.CuentaBancaria.MonedaCuenta_pk )
				llRetorno = .F.
				this.AgregarInformacion( "La cuenta bancaria asociada al valor debe tener una moneda." )
			else
				if this.SimboloMonetario_pk != this.CuentaBancaria.MonedaCuenta_pk
					llRetorno = .F.
					this.AgregarInformacion( "La moneda del valor debe coincidir con la moneda de la cuenta bancaria." )
				endif			
			endif
		endif			

		llRetorno = llRetorno and dodefault()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarDatosTarjeta() as Void
		if this.CargaManual()
			if this.ExisteAtributo( "TipoTarjeta" )
				this.TipoTarjeta = ""
			endif
			if this.ExisteAtributo( "operadoraTarjeta_pk" )
				this.operadoraTarjeta_pk = ""
			endif	
			if this.ExisteAtributo( "DetallePlanes" )
				this.DetallePlanes.limpiar()
			endif
		endif
	endfunc
    
    *-----------------------------------------------------------------------------------------
    function LimpiarDatosPrestador() as Void
        if this.CargaManual()
            if this.ExisteAtributo( "Prestador" )
                this.Prestador = ""
            endif
        endif
    endfunc

	*-----------------------------------------------------------------------------------------
	protected function ExisteAtributo( tcAtributo as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if pemstatus( this, tcAtributo, 5 )
			llRetorno = .t.
		endif		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerValorMonedaLocal() as string
		local lcValorLocal as String, lcCursor as String	

		lcCursor = "c_combo_Valor" + sys( 2015 )
		lcXml = This.oAd.obtenerdatosentidad( "Codigo,Descripcion,Tipo", "Tipo = 1", "Codigo" )

		XmltoCursor( lcXml , lcCursor )
		
		lcValorLocal = ""
		if reccount( lcCursor ) > 0
			select &lcCursor
			go top
			lcValorLocal = &lcCursor..Codigo
		endif		
		
		use in select( lcCursor )
		return lcValorLocal

	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadEnItemsDePlanes() as Boolean
		local llRetorno as Boolean, lcCursorPlanes as String, lcCursorRepetidos as String
		llRetorno = .t.
		lcCursorPlanes = this.CrearCursorDeDetalleDePlanes()
		lcCursorRepetidos = sys( 2015 )

		select NroItem ;
			from &lcCursorPlanes ;
			group by Cuotas, MontoDesde, TipoDeMonto ;
			having count( * ) > 1 ;
			into cursor &lcCursorRepetidos
		
		if reccount( lcCursorRepetidos ) > 0
			this.AgregarInformacion( "La combinación de Cuotas, Monto y Tipo de monto en el detalle de Recargos y descuentos por monto no puede repetirse." )
			llRetorno = .f.
		endif

		use in select ( lcCursorPlanes )
		use in select ( lcCursorRepetidos )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeTipoDeMonto( tcId as String ) as String
		local lcRetorno as String
		lcRetorno = ""
		
		do case
			case tcId = "1"
				lcRetorno = "Total cupón"
			case tcId = "2"
				lcRetorno = "Total cuota"
		endcase
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPlanesDisponibles( tnMontoTotal as Double ) as ZooColeccion of ZooColeccion.prg
		local loPlanesDisponibles as ZooColeccion OF ZooColeccion.prg, lcCursorPlanesDisponibles as String
		loPlanesDisponibles = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		lcCursorPlanesDisponibles = this.CrearCursorDePlanesDisponibles( tnMontoTotal )

		select ( lcCursorPlanesDisponibles )
		scan all
			loPlanesDisponibles.Agregar( this.DetallePlanes.Item[ NroItem ] )
		endscan

		use in select ( lcCursorPlanesDisponibles )
		return loPlanesDisponibles
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLDePlanesDiponibles( tnMontoTotal as Double ) as String
		local lcRetorno as String, lcCursorPlanesDisponibles as String
		lcCursorPlanesDisponibles = this.CrearCursorDePlanesDisponibles( tnMontoTotal )
		lcRetorno = this.CursorAXml( lcCursorPlanesDisponibles )
		use in select ( lcCursorPlanesDisponibles )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDePlanesDisponiblesSegunMonto( tnMontoTotal as Double ) as Integer
		local lnRetorno as Integer, lcCursorCuotasDisponibles as String
		lcCursorCuotasDisponibles = this.CrearCursorDeCuotasDisponibles( tnMontoTotal )
		lnRetorno = reccount( lcCursorCuotasDisponibles )
		use in select( lcCursorCuotasDisponibles )
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLDeTodosLosPlanesSinImportarElMonto( tnMontoTotal as Double ) as String
		return this.ObtenerXMLDePlanesDiponibles( 999999999999999 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneDefinidoRecargosPorMontos() as Boolean
		local llRetorno as Boolean, lcCursorPlanes as String
		lcCursorPlanes = this.CrearCursorDeDetalleDePlanes()
		select ( lcCursorPlanes )
		locate for MontoDesde # 0
		llRetorno = found( lcCursorPlanes )
		use in select ( lcCursorPlanes )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMenorMontoEnPlanesDefinidos() as Double
		local lnRetorno as Boolean, lcCursorPlanes as String
		lcCursorPlanes = this.CrearCursorDeDetalleDePlanes()
		calculate min( iif( alltrim( TipoDeMonto ) == "1", MontoDesde, MontoDesde * Cuotas ) ) to lnRetorno in ( lcCursorPlanes )
		use in select ( lcCursorPlanes )
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDePlanesConRecargoSinImportarElMonto() as Integer
		return this.ObtenerCantidadDePlanesConRecargo( 999999999999999 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarSiElValorEstaDisponibleParaMonto( tnMonto as double ) as void
		if this.DetallePlanes.Count > 0 and this.ObtenerCantidadDePlanesDisponiblesSegunMonto( tnMonto ) = 0
			goServicios.Errores.LevantarExcepcion( "No es posible utilizar el valor [" + alltrim( this.Codigo )  + "] para cupones con montos menores a " + transform( this.ObtenerMenorMontoEnPlanesDefinidos() ) + ;
				". Verifique los recargos por monto definidos en el alta del mismo." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDeCuotasDisponibles( tnMontoTotal as Double ) as String
		local lcCursorCuotasDisponibles as String, lcCursorPlanesDisponiblesParaMontoTotal as String, lcCursorPlanesDisponiblesParaMontoPorCuota as String
		lcCursorPlanesDisponiblesParaMontoTotal = this.CrearCursorDePlanesDisponiblesParaMontoTotal( tnMontoTotal )
		lcCursorPlanesDisponiblesParaMontoPorCuota = this.CrearCursorDePlanesDisponiblesParaMontoPorCuota( tnMontoTotal )
		lcCursorCuotasDisponibles = sys( 2015 )

		select distinct Cuotas ;
			from &lcCursorPlanesDisponiblesParaMontoTotal;
			into cursor &lcCursorCuotasDisponibles ;
			union ;
			select Cuotas ;
			from &lcCursorPlanesDisponiblesParaMontoPorCuota;
			order by Cuotas

		use in select ( lcCursorPlanesDisponiblesParaMontoTotal )
		use in select ( lcCursorPlanesDisponiblesParaMontoPorCuota )
		return lcCursorCuotasDisponibles
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDePlanesDisponibles( tnMontoTotal as Double ) as String
		local lcCursorPlanesDisponibles as String, lcCursorCuotasDisponibles as String, lcCursorPlanesDisponiblesParaMontoTotal as String, lcCursorPlanesDisponiblesParaMontoPorCuota as String, ;
			lnCuotas as Integer, lcCursorMejorPlanDisponibleParaCuota as String, loItemDePlan as Object
		lcCursorPlanesDisponibles = this.CrearCursorDeDetalleDePlanesVacio()
		lcCursorCuotasDisponibles = this.CrearCursorDeCuotasDisponibles( tnMontoTotal )
		lcCursorPlanesDisponiblesParaMontoTotal = this.CrearCursorDePlanesDisponiblesParaMontoTotal( tnMontoTotal )
		lcCursorPlanesDisponiblesParaMontoPorCuota = this.CrearCursorDePlanesDisponiblesParaMontoPorCuota( tnMontoTotal )
		
		select ( lcCursorCuotasDisponibles )
		scan all
			lnCuotas = &lcCursorCuotasDisponibles..Cuotas
			lcCursorMejorPlanDisponibleParaCuota = this.ObtenerCursorDeMejorPlanDisponibleParaCuota( lnCuotas, lcCursorPlanesDisponiblesParaMontoTotal, lcCursorPlanesDisponiblesParaMontoPorCuota )
			select ( lcCursorMejorPlanDisponibleParaCuota )
			scatter name loItemDePlan
			this.InsertarItemDePlan( lcCursorPlanesDisponibles, loItemDePlan )
		endscan

		use in select ( lcCursorCuotasDisponibles )
		use in select ( lcCursorPlanesDisponiblesParaMontoTotal )
		use in select ( lcCursorPlanesDisponiblesParaMontoPorCuota )
		return lcCursorPlanesDisponibles
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDePlanesDisponiblesParaMontoTotal( tnMontoTotal as Double ) as String
		local lcCursorPlanesDisponiblesParaMontoTotal as String
		lcCursorPlanesDisponiblesParaMontoTotal = this.CrearCursorDePlanesDisponiblesSegunTipoDeMonto( tnMontoTotal, "1" )
		return lcCursorPlanesDisponiblesParaMontoTotal
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDePlanesDisponiblesParaMontoPorCuota( tnMontoTotal as Double ) as String
		local lcCursorPlanesDisponiblesParaMontoPorCuotas as String
		lcCursorPlanesDisponiblesParaMontoPorCuotas = this.CrearCursorDePlanesDisponiblesSegunTipoDeMonto( tnMontoTotal, "2" )
		return lcCursorPlanesDisponiblesParaMontoPorCuotas
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDePlanesDisponiblesSegunTipoDeMonto( tnMontoTotal as Double, tcTipoDeMonto as String ) as String
		local lcCursorPlanes as String, lcCursorPlanesDisponibles as String, lnCuotas as Integer
		lcCursorPlanes = this.CrearCursorDeDetalleDePlanes()
		lcCursorPlanesDisponibles = sys( 2015 )
		if tcTipoDeMonto = "1"
			lnCuotas = 1
		else
			if reccount( lcCursorPlanes ) = 0
				lnCuotas = 1
			else
				lnCuotas = 0
			endif
		endif
		if tnMontoTotal < 0 
			select c_P.* ;
			from &lcCursorPlanes c_P ;
			where alltrim( c_P.TipoDeMonto ) == tcTipoDeMonto and c_P.MontoDesde in ;
				( select max( c_I.MontoDesde ) ;
					from &lcCursorPlanes c_I ;
					where alltrim( c_I.TipoDeMonto ) == tcTipoDeMonto and c_P.Cuotas == c_I.Cuotas ) ;
			order by c_P.Cuotas ;
			into cursor &lcCursorPlanesDisponibles
		else
			select c_P.* ;
			from &lcCursorPlanes c_P ;
			where alltrim( c_P.TipoDeMonto ) == tcTipoDeMonto and c_P.MontoDesde <= ( tnMontoTotal / evl( lnCuotas, Cuotas ) ) and c_P.MontoDesde in ;
				( select max( c_I.MontoDesde ) ;
					from &lcCursorPlanes c_I ;
					where alltrim( c_I.TipoDeMonto ) == tcTipoDeMonto and c_P.Cuotas == c_I.Cuotas and c_I.MontoDesde <= ( tnMontoTotal / evl( lnCuotas, Cuotas ) ) ) ;
			order by c_P.Cuotas ;
			into cursor &lcCursorPlanesDisponibles
		
		endif 			
		use in select ( lcCursorPlanes )
		return lcCursorPlanesDisponibles
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDeDetalleDePlanes() as String
		local lcCursorPlanes as String, loItem as Object
		lcCursorPlanes = this.CrearCursorDeDetalleDePlanesVacio()
		for each loItem in this.DetallePlanes
			if this.DetallePlanes.ValidarExistenciaCamposFijosItemPlano( loItem.NroItem )
				this.InsertarItemDePlan( lcCursorPlanes, loItem )
			endif
		endfor
		
		return lcCursorPlanes
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearCursorDeDetalleDePlanesVacio() as String
		local lcCursorPlanes as String
		lcCursorPlanes = sys( 2015 )
		create cursor &lcCursorPlanes ( NroItem I, Cuotas N ( 3 ), MontoDesde N ( 15,2 ), TipoDeMonto C ( 1 ), Recargo N( 15, 4 ) )
		return lcCursorPlanes
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeMejorPlanDisponibleParaCuota( tnCuotas as Integer, tcCursorPlanesDisponiblesParaMontoTotal as String, tcCursorPlanesDisponiblesParaMontoPorCuota as String ) as String
		local lcCursorMejorPlanDisponibleParaCuota as String, llEstaDisponibleEnPlanParaMontoTotal as Boolean, llEstaDisponibleEnPlanParaMontoPorCuota as Boolean, lcOperador as String
		select ( tcCursorPlanesDisponiblesParaMontoTotal )
		locate for Cuotas = tnCuotas
		llEstaDisponibleEnPlanParaMontoTotal = found( tcCursorPlanesDisponiblesParaMontoTotal )
		select ( tcCursorPlanesDisponiblesParaMontoPorCuota )
		locate for Cuotas = tnCuotas
		llEstaDisponibleEnPlanParaMontoPorCuota = found( tcCursorPlanesDisponiblesParaMontoPorCuota )

		do case
			case llEstaDisponibleEnPlanParaMontoTotal and llEstaDisponibleEnPlanParaMontoPorCuota
				if goServicios.Parametros.Felino.GestionDeVentas.Tarjetas.FormaDeSeleccionParaRecargosMultiples = 1
					lcOperador = "<="
				else
					lcOperador = ">="
				endif
				if &tcCursorPlanesDisponiblesParaMontoTotal..Recargo &lcOperador &tcCursorPlanesDisponiblesParaMontoPorCuota..Recargo
					lcCursorMejorPlanDisponibleParaCuota = tcCursorPlanesDisponiblesParaMontoTotal
				else
					lcCursorMejorPlanDisponibleParaCuota = tcCursorPlanesDisponiblesParaMontoPorCuota
				endif
			case llEstaDisponibleEnPlanParaMontoTotal
				lcCursorMejorPlanDisponibleParaCuota = tcCursorPlanesDisponiblesParaMontoTotal
			case llEstaDisponibleEnPlanParaMontoPorCuota
				lcCursorMejorPlanDisponibleParaCuota = tcCursorPlanesDisponiblesParaMontoPorCuota
		endcase
		
		return lcCursorMejorPlanDisponibleParaCuota
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InsertarItemDePlan( tcCursorDestino as String, toItemDePlan as Object ) as VOID
		insert into &tcCursorDestino ( NroItem, Cuotas, MontoDesde, TipoDeMonto, Recargo ) values ( toItemDePlan.NroItem, toItemDePlan.Cuotas, toItemDePlan.MontoDesde, toItemDePlan.TipoDeMonto, toItemDePlan.Recargo )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_Tipo( txVal as variant ) as Boolean

		do case
		case txVal = 10 and this.CargaManual() and ( this.llPermitirTipoDeValorAjusteDeCupon = .f. )
			goServicios.Errores.LevantarExcepcion( 'No puede usar este tipo de valor' )
			return .F.
		other
			Return dodefault( txVal ) 
		endcase

	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearValorParaAjusteDeCupon() as String
		local lcCodigoValor as String, llExisteCodigo as Boolean, loError as Object, lcMensajeCapturado  as String, lcRetorno as String, lnIndice as Integer
		lcRetorno = ""
		lcCodigoValor = "AJCUP"
		llExisteCodigo  = .t.
		for lnIndice = 0 to 99
			try
				this.Codigo = lcCodigoValor 
			catch to loError
				lcMensajeCapturado = loError.UserValue.oInformacion.Item[ 1 ].cMensaje
				if lcMensajeCapturado = "El dato buscado "+alltrim( lcCodigoValor ) + " de la entidad VALORES no existe."
					llExisteCodigo  = .f.
				else
					goServicios.Errores.LevantarExcepcion( loError )
				endif
			endtry
			if ( llExisteCodigo  = .f. )
				exit
			endif
			lcCodigoValor = "AJC" + padl( lnIndice, 2, "0")
		endfor
		if ( !llExisteCodigo  )
			with this
				.llPermitirTipoDeValorAjusteDeCupon = .t.
				.Nuevo()
				.Codigo = lcCodigoValor 
				.Descripcion = "Ajuste de Cupon"
				.Tipo = this.nCodigoDeValoresTipoAjusteDeCupones
				.SimboloMonetario_PK = this.ObtenerMonedaDeSistema()
			
				.Grabar()
				lcRetorno = lcCodigoValor 
			endwith
		endif
		return ( lcRetorno )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneCajaAsignada() as Boolean
		return !empty( this.caja_pk )
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarAtributosFaltantesAjusteDeCupon
		local loerror as Exception, llGrabar  as Boolean

		try
			this.codigo = goParametros.Felino.GestionDeVentas.AjusteDeCupon.ValorAUtilizarEnComprobantes
			this.Modificar()
						
			if empty(this.EquivCfIbm) and this.lTengoCFIBM 
				this.EquivCfIbm = 6
				llGrabar = .T.
			endif		
			
			if empty(this.EquivCfEpson) and this.lValidarEquivalenciaAFIP
				this.EquivCfEpson = 99
				llGrabar = .T.
			endif						
						
			if empty(this.FacturaElectronica) and this.lHabilitarFacturaelectronica 
				this.FacturaElectronica = "TC"
				llGrabar = .T.
			endif					
			
			if llGrabar 
				this.Grabar()
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError.UserValue.oInformacion.Item[ 1 ].cMensaje) 					
		endtry

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerValorDeTipoCtaCteSegunMoneda( tcCodigoMoneda as String ) as String
		local lcRetorno as String, lcXML as String

		lcRetorno = ""
		lcXML = this.oad.obtenerdatosentidad( "Codigo, SimboloMonetario, Tipo", "SimboloMonetario = '" + tcCodigoMoneda + "' and Tipo = 6" )
		xmltocursor( lcXML, "tCursorValores" )
		if reccount( "tCursorValores" ) > 0
			go top in ( "tCursorValores" )
			lcRetorno = tCursorValores.codigo
			use in ( "tCursorValores" ) 
		endif 	

		return lcRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDeValor( tcCodigo as String ) as String
		local lcRetorno as String, lcCursor as String, lcCampoCodigo as String, lcXML as String
		lcRetorno = ""
		lcCampoCodigo = this.oAd.ObtenerCampoEntidad( "Codigo" )
		lcXML = this.oad.obtenerdatosentidad( "Descripcion", lcCampoCodigo + " = '" + tcCodigo + "'")
		xmltocursor( lcXML, "lcCursor" )
		if reccount( "lcCursor" ) > 0
			go top in ( "lcCursor" )
			lcRetorno = alltrim( lcCursor.Descripcion )
			use in ( "lcCursor" ) 
		endif 	

		return lcRetorno 
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoMaximoDeRetiroDeEfectivoDeValor( tcCodigo as String ) as Double
		local lnRetorno as Double, lcCursor as String, lcCampoCodigo as String, lcXML as String
		lnRetorno = 0
		lcCampoCodigo = this.oAd.ObtenerCampoEntidad( "Codigo" )
		lcXML = this.oad.obtenerdatosentidad( "MontoMaximoDeRetiro", lcCampoCodigo + " = '" + tcCodigo + "'")
		xmltocursor( lcXML, "lcCursor" )
		if reccount( "lcCursor" ) > 0
			go top in ( "lcCursor" )
			lnRetorno = lcCursor.MontoMaximoDeRetiro
			use in ( "lcCursor" ) 
		endif 	

		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMontoSinRecargoSegunCuota( tnMonto as Double, tnCuotas as Integer ) as Double
		local lnRetorno as Double, lnIndice as Integer
		lnRetorno = tnMonto

		for each loItem in this.DetallePlanes
			if loItem.Cuotas = tnCuotas and loItem.Recargo > 0 and loItem.MontoDesde <= tnMonto
				lnRetorno = round( tnMonto / (1 + loItem.Recargo / 100), 2)
				if lnRetorno  <= loItem.MontoDesde
					lnRetorno = tnMonto
				endif
			endif
		endfor

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AjustarObjetoBusqueda( toBusqueda as Object ) as Void
		if this.TipoParaFiltrarEnBuscador <> 0
			toBusqueda.Filtro  = toBusqueda.Filtro + " and " + this.oAd.cTablaPrincipal + ".CLCFI = " + transform( this.TipoParaFiltrarEnBuscador )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMonedaDeSistema() as String
		local lcRetorno as String
		lcRetorno = goParametros.Felino.Generales.MonedaSistema
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarSiTieneRecargos() as Boolean
		local i as Integer, llRetorno as Boolean

		llRetorno = .F.
		for i = 1 to this.detalleplanes.Count
			if this.detalleplanes.item( i ).recargo > 0
				llRetorno = .T.
				exit
			endif
		endfor

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarArqueoPorTotales() as Void
		if inlist( this.Tipo, 1, 2 )
			this.lHabilitarArqueoPorTotales = .t.
		else
			this.lHabilitarArqueoPorTotales = .T.
			this.ArqueoPorTotales = .f.
			this.lHabilitarArqueoPorTotales = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function limpiarFlag() as Void
		dodefault()
		this.lHabilitarArqueoPorTotales = inlist( this.Tipo, 1, 2 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarModoRedondeo() as Void
		if !inlist( this.Tipo, 1, 2 ) && Si no es Moneda local o extranjera solo puede redondear recargos y descuentos
			this.lHabilitarModoRedondeo = .T.
			this.ModoRedondeo = 1
			this.lHabilitarModoRedondeo = .F.
		else
			this.lHabilitarModoRedondeo = .T.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitarPermiteModificarFecha() as Void

		if inlist( this.Tipo, 1, 2 )
			this.lHabilitarPermiteModificarFecha = .T.
		else
			this.lHabilitarPermiteModificarFecha = .T.		
			if inlist( this.Tipo, 5, 6, 10 )
				this.PermiteModificarFecha = .T.
			else
				this.PermiteModificarFecha = .F.
			endif
			this.lHabilitarPermiteModificarFecha = .F.			
		endif
		
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function ValidarCuentabancaria() as boolean
		local llRetorno
		llRetorno = .t.
		if this.Tipo = 13 
			llRetorno = dodefault()
			if !llRetorno
				this.EventoHacerFocoCuentaBancaria()
			endif
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoHacerFocoCuentaBancaria() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerCodigoSegunTipo( tnTipo as Integer) as string
		local lcValorLocal as String, lcCursor as String	

		lcValorLocal = ""
		if type( 'tnTipo' ) = 'N'
			lcCursor = "c_combo_Valor" + sys( 2015 )
			lcXml = This.oAd.obtenerdatosentidad( "Codigo,Descripcion,Tipo", "Tipo = " + alltrim(str(tnTipo)), "Codigo" )

			XmltoCursor( lcXml , lcCursor )
			
			if reccount( lcCursor ) > 0
				select &lcCursor
				go top
				lcValorLocal = &lcCursor..Codigo
			endif		
			
			use in select( lcCursor )
		endif
		return lcValorLocal

	endfunc
		
	*-----------------------------------------------------------------------------------------
	function TipoValorNoPermiteSetearVisualizarEnCaja( tnTipo as Integer ) as Boolean
		return !(tnTipo = 6 or tnTipo = 13)
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_Visualizarencaja( txVal as variant ) as void
		if !this.lNuevo and !this.lEdicion and !empty(this.Codigo) and this.TipoValorNoPermiteSetearVisualizarEnCaja( this.Tipo )
			this.Visualizarencaja = .t.
		else
			dodefault( txVal )
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarPermiteModificarVisualizarEnCaja() as Void

		if this.Verificarcontexto("CBI")
			this.lHabilitarVisualizarEnCaja = .T.
		else
			if !inlist( this.Tipo, 6, 13 )
				this.lHabilitarVisualizarEnCaja = .T.
				this.VisualizarEnCaja = .T.
				this.lHabilitarVisualizarEnCaja = .F.	
			else
				this.lHabilitarVisualizarEnCaja = .T.
			endif
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Cancelar() as Void
		dodefault()
		if !empty(this.Codigo) and this.TipoValorNoPermiteSetearVisualizarEnCaja( this.Tipo )
			this.VisualizarEnCaja = .t.
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerCondicionDeValoresNoProcesablesEnCierreDeCaja() as String
		local lcRetorno as Strin, lcCursor as String, lcXml as String 
		lcRetorno = ""
		lcCursor = sys( 2015 )
		lcXml = This.oAd.obtenerdatosentidad( "Codigo", "Tipo = 6 or Tipo = 13", "Codigo" )
		XmltoCursor( lcXml , lcCursor )		
		if reccount( lcCursor ) > 0
			select &lcCursor
			scan
				lcRetorno = lcRetorno + iif(!empty(lcRetorno), " or ", "") + "valor = '" + Codigo + "'"
			endscan
		else
			lcRetorno = "1<>1"
		endif			
		use in select( lcCursor )
		return lcRetorno
	endfunc 

enddefine
