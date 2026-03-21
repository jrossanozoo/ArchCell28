define class Ent_Impuesto as Din_EntidadImpuesto of Din_EntidadImpuesto.prg

	#if .f.
		local this as ent_Impuesto as ent_Impuesto.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Modificar() as void
		dodefault()
		this.HabilitarAtributosSegunTipoYAplicacion()
		this.SetearValorDeBaseDeCalculoParaComprobantesM()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Nuevo() as void
		dodefault()
		this.HabilitarAtributosSegunTipoYAplicacion()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Destroy() as void
		this.lDestroy = .t.
		if type( "This.Tipo" ) = "O" and !isnull( This.Tipo )
			This.Tipo.lDestroy = .t.
			This.Tipo.Release()
		endif
		if type( "This.RegimenImpositivo" ) = "O" and !isnull( This.RegimenImpositivo )
			This.RegimenImpositivo.lDestroy = .t.
			This.RegimenImpositivo.Release()
		endif
		if type( "This.RG2616Regimen" ) = "O" and !isnull( This.RegimenImpositivo )
			This.RG2616Regimen.lDestroy = .t.
			This.RG2616Regimen.Release()
		endif
		if type( "This.Jurisdiccion" ) = "O" and !isnull( This.Jurisdiccion )
			This.Jurisdiccion.lDestroy = .t.
			This.Jurisdiccion.Release()
		endif
		dodefault()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		Local llValidacionManual as boolean, lcMensajeError as Stringl,lnTipoDeImpuesto as Integer
		local llEsTipoIngresosBrutos as Boolean, llEsTipoGanancias as Boolean, llEsTipoValorAgregado as Boolean, llEsTipoSeguridadSocial as Boolean
		llEsTipoIngresosBrutos = this.Tipo.EsTipoIngresosBrutos()
		llEsTipoGanancias = this.Tipo.esTipoGanancias()
		llEsTipoValorAgregado = this.Tipo.esTipoValorAgregado()
		llEsTipoSeguridadSocial = this.Tipo.esTipoSeguridadSocial()

		llValidacionManual  = dodefault()

		if alltrim(this.BaseDeCalculo) = "POR" and ( this.PorcentajeBase <= 0 or this.PorcentajeBase >= 100 )
			llValidacionManual  = .F.
			lcMensajeError = "Debe ingresar valor positivo menor a 100 en porcentaje sobre base de cálculo."
			This.AgregarInformacion( lcMensajeError, 9005, 'PorcentajeBase')
		endif

		if llEsTipoIngresosBrutos and empty( this.Jurisdiccion_PK )
			llValidacionManual  = .F.
			lcMensajeError = "Debe ingresar una jurisdiccion para este tipo de impuesto."
			This.AgregarInformacion( lcMensajeError, 9005, 'Jurisdiccion' )
		endif

		if llEsTipoSeguridadSocial and empty( this.Porcentaje )
			llValidacionManual  = .F.
			lcMensajeError = "Debe ingresar un porcentaje para este tipo de impuesto."
			This.AgregarInformacion( lcMensajeError,9005, 'Porcentaje' )
		endif

		if this.oInformacion.Count > 1
			lcMensajeError = "Errores de validacion"
			This.AgregarInformacion( lcMensajeError)
		endif
		return llValidacionManual

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Basedecalculo( txVal as variant ) as void

		dodefault( txVal )

		if ( alltrim(txVal) == "POR" ) 
			this.lHabilitarPorcentajeBase = .t.
		else
			this.PorcentajeBase = 0
			this.lHabilitarPorcentajeBase = .f.
		endif

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Aplicacion( txVal as variant ) as void

		dodefault( txVal )
		if ( alltrim(txVal) == "RTN" ) 
			if this.Tipo.esTipoGanancias() or this.Tipo.EsTipoValorAgregado()
				this.lHabilitarPagoParcial = .f.
			else
				this.lHabilitarPagoParcial = .t.
				if empty(this.PagoParcial)
					this.PagoParcial = 2
				endif
			endif
		else
			if (this.PagoParcial >0) and this.lHabilitarPagoParcial = .t.
				this.PagoParcial = 0
			endif
			this.lHabilitarPagoParcial = .f.
		endif
		this.SetearValorDeBaseDeCalculoParaComprobantesM()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Tipo( txVal as variant ) as void
		dodefault( txVal )
		this.SetearValorDeBaseDeCalculoParaComprobantesM()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HabilitarAtributosSegunTipoYAplicacion() as Void
		local lnTipoDeImpuesto as Integer, llEsTipoIngresosBrutos as Boolean, llEsTipoGanancias as Boolean, llEsTipoValorAgregado as Boolean, ;
				llEsTipoSeguridadSocial as Boolean, llEsRetencion as Boolean, llEsPercepcion as Boolean, llEsImpuestoInterno as Boolean 
		llEsTipoIngresosBrutos = this.Tipo.EsTipoIngresosBrutos()
		llEsTipoGanancias = this.Tipo.esTipoGanancias()
		llEsTipoValorAgregado = this.Tipo.esTipoValorAgregado()
		llEsTipoSeguridadSocial = this.Tipo.esTipoSeguridadSocial()
		llEsRetencion = this.EsRetencion()
		llEsPercepcion = this.EsPercepcion()
		llEsImpuestoInterno = this.Tipo.EsTipoImpuestoInterno()
		this.lHabilitarBaseDeCalculo = .t.
		do case
		case llEsTipoGanancias and llEsRetencion
			this.BaseDeCalculo = 'PAG'
		case llEsTipoGanancias and llEsPercepcion or llEsImpuestoInterno
			this.BaseDeCalculo = 'BGI'
		case llEsTipoValorAgregado
			this.BaseDeCalculo = 'GRA'
		endcase

		this.lHabilitarJurisdiccion_PK = llEsTipoIngresosBrutos and !llEsImpuestoInterno
		this.lHabilitarPorcentaje = !llEsImpuestoInterno
		this.lHabilitarPorcentajeBase = llEsTipoIngresosBrutos and llEsRetencion and !llEsImpuestoInterno
		this.lHabilitarEscala = llEsTipoGanancias and llEsRetencion and !llEsImpuestoInterno
		this.lHabilitarEscalaDetalle = llEsTipoGanancias and llEsRetencion and !llEsImpuestoInterno
		this.lHabilitarMonto = !llEsTipoValorAgregado and !llEsTipoSeguridadSocial and !llEsImpuestoInterno
		this.lHabilitarMinimo = ( llEsRetencion or llEsPercepcion ) and !llEsImpuestoInterno
		this.lHabilitarRegimenImpositivo_PK = llEsTipoGanancias or llEsTipoValorAgregado or llEsTipoSeguridadSocial or llEsTipoIngresosBrutos  and !llEsImpuestoInterno
        this.lHabilitarRG5329AplicaPorArticulo = llEsPercepcion and llEsTipoValorAgregado

		if llEsPercepcion
			this.lHabilitarBaseDeCalculo = .f.
		else
			this.lHabilitarBaseDeCalculo = !llEsTipoGanancias and !llEsTipoValorAgregado and !llEsImpuestoInterno
		endif
		this.lHabilitarPagoParcial = !llEsTipoGanancias and !llEsTipoValorAgregado and llEsRetencion and !llEsImpuestoInterno
		
		this.lHabilitarRG2616Porcentaje = llEsRetencion and (llEsTipoGanancias or llEsTipoValorAgregado) and !llEsImpuestoInterno
		this.lHabilitarRG2616Regimen_PK = llEsRetencion and (llEsTipoGanancias or llEsTipoValorAgregado) and !llEsImpuestoInterno
		this.lHabilitarRG2616Meses = llEsRetencion and (llEsTipoGanancias or llEsTipoValorAgregado) and !llEsImpuestoInterno
		this.lHabilitarRG2616MontoMaximoServicios = llEsRetencion and (llEsTipoGanancias or llEsTipoValorAgregado) and !llEsImpuestoInterno
		this.lHabilitarRG2616MontoMaximoBienes = llEsRetencion and (llEsTipoGanancias or llEsTipoValorAgregado) and !llEsImpuestoInterno

		this.lHabilitarSegunConvenio = llEsTipoIngresosBrutos
		this.HabilitarConvenioAlicuotasIIBB()
		this.EventoAtributosObligatoriosPorTipoDeImpuesto()
		this.BlanquearAtributosPorTipoDeImpuesto()
		this.SetearHabilitacionDeAtributosParaComprobantesM()
		
		this.SetearHabilitacionAtributosIIBBTucuman()		
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAtributosObligatoriosPorTipoDeImpuesto() as Void
*!*---- Para que se bindee el controler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BlanquearAtributosPorTipoDeImpuesto() as Void
		local lnTipoDeImpuesto as Integer, llEsTipoIngresosBrutos as Boolean, llEsTipoGanancias as Boolean, ;
		llEsTipoValorAgregado as Boolean, llEsTipoSeguridadSocial as Boolean, llEsTipoImpuestoInterno as Boolean
		llEsTipoIngresosBrutos = this.Tipo.EsTipoIngresosBrutos()
		llEsTipoGanancias = this.Tipo.esTipoGanancias()
		llEsTipoValorAgregado = this.Tipo.esTipoValorAgregado()
		llEsTipoSeguridadSocial = this.Tipo.esTipoSeguridadSocial()
		llEsTipoImpuestoInterno = this.Tipo.EsTipoImpuestoInterno()
		
		if !llEsTipoIngresosBrutos and !empty(this.Jurisdiccion_PK) or llEsTipoImpuestoInterno
			this.lHabilitarJurisdiccion_PK = .t.
			this.Jurisdiccion_PK = ''
			this.lHabilitarJurisdiccion_PK = .f.
		endif

		if !llEsTipoGanancias and !llEsTipoValorAgregado and !llEsTipoSeguridadSocial and !llEsTipoIngresosBrutos and !empty(this.RegimenImpositivo_PK) or llEsTipoImpuestoInterno
			this.lHabilitarRegimenImpositivo_PK = .t.
			this.RegimenImpositivo_PK = ''
			this.lHabilitarRegimenImpositivo_PK = .f.
		endif
	
		if !llEsTipoValorAgregado
        	this.lHabilitarRG5329AplicaPorArticulo = .t.
        	this.RG5329AplicaPorArticulo = .f.
        	this.lHabilitarRG5329AplicaPorArticulo = .f.
        	this.lHabilitarRG5329Porcentaje =  .t.
        	this.RG5329Porcentaje = 0
        	this.lHabilitarRG5329Porcentaje =  .f.
        endif

		if llEsTipoImpuestoInterno
			this.lHabilitarPorcentaje= .t.
			this.Porcentaje = 0
			this.lHabilitarPorcentaje= .f.
			
			this.lHabilitarMonto = .t.
			this.Monto = 0
			this.lHabilitarMonto = .f.
			
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearHabilitacionDeAtributosParaComprobantesM() as Void
		local llHabilitarAtributos as Boolean
		llHabilitarAtributos = this.EsRetencion() and ( this.Tipo.esTipoGanancias() or this.Tipo.esTipoValorAgregado() )
		this.lHabilitarRG1575BaseDeCalculo	= .f.
		this.lHabilitarRG1575Regimen_PK		= llHabilitarAtributos
		this.lHabilitarRG1575Porcentaje		= llHabilitarAtributos
		if !llHabilitarAtributos
			this.BlanquearAtributosParaComprobantesM()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BlanquearAtributosParaComprobantesM() as Void
		local llHabilitarRG1575BaseDeCalculo as Boolean, llHabilitarRG1575Regimen_PK as Boolean, ;
			llHabilitarRG1575Porcentaje as Boolean

		llHabilitarRG1575Regimen_PK          = this.lHabilitarRG1575Regimen_PK
		llHabilitarRG1575Porcentaje          = this.lHabilitarRG1575Porcentaje
		llHabilitarRG1575BaseDeCalculo       = this.lHabilitarRG1575BaseDeCalculo

		this.lHabilitarRG1575Regimen_PK          = .t.
		this.lHabilitarRG1575Porcentaje          = .t.
		this.lHabilitarRG1575BaseDeCalculo       = .t.

		this.RG1575Regimen_PK          = ""
		this.RG1575Porcentaje          = 0
		this.RG1575BaseDeCalculo       = ""

		this.lHabilitarRG1575Regimen_PK          = llHabilitarRG1575Regimen_PK
		this.lHabilitarRG1575Porcentaje          = llHabilitarRG1575Porcentaje
		this.lHabilitarRG1575BaseDeCalculo       = llHabilitarRG1575BaseDeCalculo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearValorDeBaseDeCalculoParaComprobantesM() as Void
		if this.EsNuevo() or this.EsEdicion()
			this.lHabilitarRG1575BaseDeCalculo = .t.
			do case
				case this.EsRetencion() and this.Tipo.esTipoGanancias()
					this.RG1575BaseDeCalculo = 'BGI'
				case this.EsRetencion() and this.Tipo.esTipoValorAgregado()
					this.RG1575BaseDeCalculo = 'IVA'
				otherwise
					this.RG1575BaseDeCalculo = ''
			endcase
			this.lHabilitarRG1575BaseDeCalculo = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearHabilitacionAtributosIIBBTucuman() as Void
		local llHabilitar as Boolean
		
		llHabilitar = this.EsPercepcion() and this.Tipo.EsTipoIngresosBrutos() and alltrim( this.Jurisdiccion_pk ) = "924"
		
		this.lHabilitarIIBBTucCoeficienteCero = llHabilitar 
		this.lHabilitarIIBBTucReduccionAlicuota = llHabilitar 
		this.lHabilitarIIBBTucAlicuotaNoInscriptos = llHabilitar 		
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarEscalaoPorcentaje() as Void
		local llEsTipoGanancias as Boolean, llEsImpuestoInterno as Boolean
		llEsTipoGanancias = this.Tipo.esTipoGanancias()
		llEsImpuestoInterno = this.Tipo.EsTipoImpuestoInterno()
		this.lHabilitarEscalaDetalle = llEsTipoGanancias and this.Escala
		this.lHabilitarPorcentaje = !llEsTipoGanancias or !this.Escala and !llEsImpuestoInterno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarConvenioAlicuotasIIBB() as Void
		local llEsTipoIIBB as Boolean, llHabilitoAlicuotas as Boolean
	
		llEsTipoIIBB = this.Tipo.EsTipoIngresosBrutos()
		llEsImpuestoInterno = this.Tipo.EsTipoImpuestoInterno()
		llHabilitoAlicuotas = llEsTipoIIBB and this.SegunConvenio and !llEsImpuestoInterno
		this.lHabilitarConvenioLocal = llHabilitoAlicuotas
		this.lHabilitarConvenioMultilateral = llHabilitoAlicuotas
		this.lHabilitarConvenioNoInscripto = llHabilitoAlicuotas
		this.lHabilitarConvenioMultilExtranaJuris = llHabilitoAlicuotas
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Tipo( txVal as variant, lxValOld as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, lxValOld )
		if llRetorno
			if txVal # lxValOld
				this.lHabilitarBaseDeCalculo = .t.
				this.lHabilitarPagoParcial = .t.
				do case
				case txVAL = 'GANANCIAS'
					if this.EsRetencion()
						this.BaseDeCalculo = 'PAG'
					endif
					if this.EsPercepcion()
						this.BaseDeCalculo = 'BGI'
					endif
					this.PagoParcial = 2
				case txVAL = 'IVA'
					this.PagoParcial = 1
					this.BaseDeCalculo = 'GRA'
				otherwise
					if this.EsPercepcion()
						this.BaseDeCalculo = 'BGI'
					else
						if inlist( lxValOld, 'GANANCIAS', 'IVA') and !inlist( txVAL, 'GANANCIAS', 'IVA')
							this.BaseDeCalculo = 'TOT'
						endif
					endif
				endcase
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsPercepcion() as Boolean
		return this.Aplicacion = "PRC"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsRetencion() as Boolean
		return this.Aplicacion = "RTN"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorTipo( toBusqueda as Object ) as Void
		toBusqueda.Filtro = toBusqueda.Filtro + " and ( tipo = '"+alltrim( this.Tipo_PK)+"' or tipo = '' )"
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_RG2616Regimen( txVal as variant ) as void
		dodefault( txVal )
		if this.CargaManual()
			if !this.ValidarTipoEnRegimenRG2616()
				goServicios.Errores.LevantarExcepcion( this.ObtenerMensajePorTiposDistintosEnRegimenRG2616() )
			endif
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	Function Grabar() As Void
		local loError as Object
		if this.lHabilitarRegimenImpositivo_PK or this.lHabilitarRG2616Regimen_PK
			loError = Newobject( "ZooException", "ZooException.prg" )
			if !this.ValidarTipoEnRegimen()
				loError.Agregarinformacion( this.ObtenerMensajePorTiposDistintosEnRegimen() )
			endif
			if !this.ValidarTipoEnRegimenRG2616()
				loError.Agregarinformacion( this.ObtenerMensajePorTiposDistintosEnRegimenRG2616() )
			endif
			if loError.oInformacion.Count > 0
				if loError.oInformacion.Count > 1
					loError.Agregarinformacion( "Hay errores en la configuración del impuesto" )
				endif
				goServicios.Errores.LevantarExcepcion( loError )
			endif
		endif
		dodefault()
		return
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajePorTiposDistintosEnRegimen() as String
		local lcRetorno as String
		lcRetorno = "El régimen ingresado (" + alltrim(this.RegimenImpositivo_PK) + ") es de un tipo específico (" + alltrim(this.RegimenImpositivo.ObtenerTipoDeImpuesto()) + ") distinto al del impuesto (" + alltrim(this.Tipo_PK) + ")."
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajePorTiposDistintosEnRegimenRG2616() as String
		local lcRetorno as String
		lcRetorno = "El régimen de la RG2616 ingresado (" + alltrim(this.RG2616Regimen_PK) +") es de un tipo específico (" + alltrim(this.RG2616Regimen.ObtenerTipoDeImpuesto()) + ") distinto al del impuesto (" + alltrim(this.Tipo_PK) + ")."
		return lcRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Regimenimpositivo( txVal as variant ) as void
		dodefault( txVal )
		if this.CargaManual()
			if !this.ValidarTipoEnRegimen()
				goServicios.Errores.LevantarExcepcion( this.ObtenerMensajePorTiposDistintosEnRegimen() )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarTipoEnRegimen() as Boolean
		local llRetorno as Boolean
		llRetorno = empty(this.RegimenImpositivo_PK) or inlist( this.RegimenImpositivo.ObtenerTipoDeImpuesto(), "", this.Tipo_PK )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarTipoEnRegimenRG2616() as Boolean
		local llRetorno as Boolean
		llRetorno = empty(this.RG2616Regimen_PK) or inlist( this.RG2616Regimen.ObtenerTipoDeImpuesto(), "", this.Tipo_PK )
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean, loInformacion as zooinformacion of zooInformacion.prg, lcMensaje as String
		llRetorno = dodefault()
		if llRetorno
			loInformacion = _Screen.Zoo.CrearObjeto( "zooInformacion" )
			if this.Tipo.EsTipoIngresosBrutos() and (this.EsPercepcion() or this.EsRetencion())
				this.ValidarCamposNecesariosParaIIBB( loInformacion )
			endif
			
			if this.EsPercepcion() and this.Tipo.EsTipoIngresosBrutos() and alltrim( this.Jurisdiccion_pk ) = "924" 
				this.ValidarCamposNecesariosIIBBTucuman( loInformacion )
			endif
			
			
			if this.Tipo.esTipoValorAgregado() and (this.EsPercepcion() or this.EsRetencion())
				this.ValidarCamposNecesariosParaIVA( loInformacion )
				this.ValidarCamposNecesariosParaRG2616( loInformacion )
				this.ValidarCamposNecesariosParaRG1575( loInformacion )
			endif

			if this.Tipo.esTipoGanancias() and this.EsPercepcion()
				this.ValidarCamposNecesariosParaPercepcionGanancias( loInformacion )
			endif

			if this.Tipo.esTipoGanancias() and this.EsRetencion()
				this.ValidarCamposNecesariosParaRetencionGanancias( loInformacion )
				this.ValidarCamposNecesariosParaRG2616( loInformacion )
				this.ValidarCamposNecesariosParaRG1575( loInformacion )
			endif

			if loInformacion.Count > 0
				this.EventoNotificarIncosistencia( loInformacion )
			endif
			loInformacion.Release()
		endif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarCamposNecesariosParaIIBB( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String, llCondicion1 as Boolean, llCondicion2 as Boolean

		llCondicion1 = this.SegunConvenio and empty( this.ConvenioLocal ) and empty( this.ConvenioMultilateral ) and empty( this.ConvenioNoInscripto ) and ;
					   empty( this.ConvenioMultilExtranaJuris )

		llCondicion2 = !this.SegunConvenio and empty( this.Porcentaje )
		

		if llCondicion1 or llCondicion2
			if llCondicion1			
				toInformacion.AgregarInformacion( 'Ha indicado que elige porcentaje según convenio. ' +;
				'Debe ingresar al menos un valor para convenio local, multilateral, multirateral con extraña jurisdiccón o no inscripto.' + ;
					 ' Caso contrario, no se efectuará el cálculo.' )
			else	
				toInformacion.AgregarInformacion('El porcentaje está vacío. Si no carga un valor en porcentaje no se efectuará el cálculo.' )
			endif
		endif

		return
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCamposNecesariosParaIVA( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String
		if (!empty( this.RegimenImpositivo_PK ) or !empty( this.minimo )) and empty( this.Porcentaje )
			lcMensaje = ''
			do case
			case !empty( this.RegimenImpositivo_PK ) and empty( this.minimo )
				lcMensaje = 'Ha cargado el régimen imponible' 
			case empty( this.RegimenImpositivo_PK ) and !empty( this.minimo )
				lcMensaje = 'Ha cargado el mínimo de impuesto' 
			case !empty( this.RegimenImpositivo_PK ) and !empty( this.minimo )
				lcMensaje = 'Ha cargado el régimen imponible, el mínimo de impuesto' 
			endcase
			toInformacion.AgregarInformacion( lcMensaje + ' y el porcentaje esta vacio. Si no carga un valor en porcentaje no se efectuará el cálculo genérico.' )
		endif
		return
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCamposNecesariosParaPercepcionGanancias( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String
		if (!empty( this.RegimenImpositivo_PK ) or !empty( this.minimo ) or !empty( this.monto )) and empty( this.Porcentaje )
			lcMensaje = ''
			if !empty( this.RegimenImpositivo_PK )
				lcMensaje = 'Ha cargado el régimen imponible' 
			endif
			if !empty( this.minimo )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'Ha cargado el régimen imponible', ', el mínimo de impuesto' )
			endif
			if !empty( this.monto )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'Ha cargado el régimen imponible', ', el mínimo no imponible' )
			endif
			toInformacion.AgregarInformacion( lcMensaje + ' y el porcentaje esta vacio. Si no carga un valor en porcentaje no se efectuará el cálculo genérico.' )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCamposNecesariosParaRetencionGanancias( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String
		if (!empty( this.RegimenImpositivo_PK ) or !empty( this.minimo ) or !empty( this.monto )) and (empty( this.Porcentaje ) and (!this.Escala or (this.Escala and this.EscalaDetalle.Count=0)))
			lcMensaje = ''
			if !empty( this.RegimenImpositivo_PK )
				lcMensaje = 'Ha cargado el régimen imponible' 
			endif
			if !empty( this.minimo )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'Ha cargado el régimen imponible', ', el mínimo de impuesto' )
			endif
			if !empty( this.monto )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'Ha cargado el régimen imponible', ', el mínimo no imponible' )
			endif

			do case
			case empty( this.Porcentaje ) and !this.Escala
				lcMensaje = lcMensaje + ' y no ha cargado porcentaje ni marcado según escala.'
			case empty( this.Porcentaje ) and this.Escala and this.EscalaDetalle.Count=0
				lcMensaje = lcMensaje + ' y ha seleccionado escala pero no ha cargado ningún dato en escalas aplicables.'
			endcase
			toInformacion.AgregarInformacion( lcMensaje + ' No se efectuará el cálculo genérico.' )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCamposNecesariosParaRG2616( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String
		if (!empty( this.RG2616Regimen_PK ) or !empty( this.RG2616Meses ) or !empty( this.RG2616MontoMaximoServicios ) or !empty( this.RG2616MontoMaximoBienes )) and empty( this.RG2616Porcentaje )
			lcMensaje = ''
			if !empty( this.RG2616Regimen_PK )
				lcMensaje = 'En la resolucion 2616/09, monotributo, ha cargado el régimen imponible' 
			endif
			if !empty( this.RG2616Meses )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'En la resolucion 2616/09, monotributo, ha cargado la cantidad de meses', ', la cantidad de meses' )
			endif

			if !empty( this.RG2616MontoMaximoServicios )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'En la resolucion 2616/09, monotributo, ha cargado el monto máximo de servicios', ', el monto máximo de servicios' )
			endif
			if !empty( this.RG2616MontoMaximoBienes )
				lcMensaje = lcMensaje + iif( empty(lcMensaje),'En la resolucion 2616/09, monotributo, ha cargado el monto máximo de bienes', ', el monto máximo de bienes' )
			endif
			lcMensaje = lcMensaje + ' y no ha cargado su porcentaje. '
			toInformacion.AgregarInformacion( lcMensaje + ' No se efectuará el cálculo correspondiente.' )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCamposNecesariosParaRG1575( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String
		if !empty( this.RG1575Regimen_PK ) and empty( this.RG1575Porcentaje )
			lcMensaje = 'En la resolucion 1575/03, comprobantes clase M, ha cargado el régimen imponible y no ha cargado su porcentaje. '
			toInformacion.AgregarInformacion( lcMensaje + ' No se efectuará el cálculo correspondiente.' )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposNecesariosIIBBTucuman( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local lcMensaje as String

		if this.IIBBTucCoeficienteCero = 0 or this.IIBBTucReduccionAlicuota = 0 or this.IIBBTucAlicuotaNoInscriptos = 0 
			lcMensaje = "Ha indicado la jurisdicción 924-Tucumán y no se han completado todos los datos de Regímenes Especiales - IIBB Tucumán."
			toInformacion.AgregarInformacion( lcMensaje + ' Las alìcuotas a aplicar pueden resultar erróneas.' )		
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsRetencionGeneral() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		do case
			case this.Aplicacion = "RTN" and this.Porcentaje # 0 and inlist(this.tipo_PK,"IVA","IIBB","SUSS")
				llRetorno = .t.
			case this.Aplicacion = "RTN" and this.tipo_PK = "GANANCIAS" and (this.Porcentaje # 0 or this.Escala)
				llRetorno = .t.
		endcase
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsRetencionRG1575() as Boolean
		return this.Aplicacion = "RTN" and this.RG1575Porcentaje # 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsRetencionRG2616() as Boolean
		return this.Aplicacion = "RTN" and this.RG2616Porcentaje # 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoNotificarIncosistencia( toInformacion as zooinformacion of zooInformacion.prg ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_Rg5329aplicaporarticulo( txVal as variant ) as void
		dodefault( txVal )
		if this.Tipo.esTipoValorAgregado()
			if this.RG5329AplicaPorArticulo 
				this.lHabilitarRG5329Porcentaje = .t.
				if empty( this.Rg5329porcentaje ) 
					this.Rg5329porcentaje = 1.5
				endif
			else
				this.Rg5329porcentaje = 0
				this.lHabilitarRG5329Porcentaje = .f.
			endif
		endif
	endfunc

enddefine
