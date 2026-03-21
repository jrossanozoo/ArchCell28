define class Ent_DatosFiscales as din_EntidadDatosFiscales of din_EntidadDatosFiscales.prg

	#IF .f.
		Local this as Ent_DatosFiscales of Ent_DatosFiscales.prg
	#ENDIF

	oImpuestos = null

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		if this.TieneComponenteDeAccionesAutomaticasParaDatosFiscales()
			this.oCompAccionesAutomaticasParaDatosFiscales.InyectarEntidad( this )
		endif
		this.BindearEvento( This.PerceIIBB, "Actualizar", this, "SetearEstadoParametrosPercIIBB" )
		this.BindearEvento( This, "Modificar", this, "SetearEstadoParametrosPercIIBB" )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oImpuestos_Access() as variant
		if !this.ldestroy and ( !vartype( this.oImpuestos ) = 'O' or isnull( this.oImpuestos ) )
			this.oImpuestos = _screen.zoo.instanciarentidad( 'Impuesto' )
		endif
		return this.oImpuestos
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function CambiosDetallePerceiibb()
		dodefault()

		try
			if !this.CargaManual()
				for each loItem in this.Perceiibb
					this.oImpuestos.Codigo 	= loItem.Impuesto_pk
	 				loItem.Aplicacion = this.oImpuestos.Aplicacion				
					loItem.Tipo_pk = this.oImpuestos.Tipo_PK				
					loItem.Jurisdiccion = this.oImpuestos.Jurisdiccion_pk		
					loItem.Resolucion = this.oImpuestos.Resolucion 	
					loItem.Minimonoimponible = this.oImpuestos.Monto
					loItem.Porcentaje = this.oImpuestos.Porcentaje
					loItem.Regimen = this.oImpuestos.Regimen 
					loItem.RegimenImpositivo = this.oImpuestos.RegimenImpositivo_PK
					loItem.MinimoDeRetencion = this.oImpuestos.Minimo
					loItem.Escala = this.oImpuestos.Escala
					loItem.RG2616Porcentaje = this.oImpuestos.RG2616Porcentaje
					loItem.RG2616Regimen = this.oImpuestos.RG2616Regimen_PK
					loItem.RG2616Meses = this.oImpuestos.RG2616Meses
					loItem.RG2616MontoMaximoBienes = this.oImpuestos.RG2616MontoMaximoBienes
					loItem.RG2616MontoMaximoServicios = this.oImpuestos.RG2616MontoMaximoServicios
					loItem.BaseDeCalculo = this.oImpuestos.BaseDeCalculo
					loItem.RG1575Regimen = this.oImpuestos.RG1575Regimen_PK
					loItem.RG1575Porcentaje = this.oImpuestos.RG1575Porcentaje
					loItem.RG1575BaseDeCalculo = this.oImpuestos.RG1575BaseDeCalculo
					loItem.ConvenioLocal = this.oImpuestos.ConvenioLocal
					loItem.ConvenioMultilateral = this.oImpuestos.ConvenioMultilateral
					loItem.ConvenioNoInscripto = this.oImpuestos.ConvenioNoInscripto
					loItem.SegunConvenio = this.oImpuestos.SegunConvenio
					loItem.conveniomultilextranajuris = this.oImpuestos.conveniomultilextranajuris
					loItem.RG5329AplicaPorArticulo = this.oImpuestos.RG5329AplicaPorArticulo
					loItem.RG5329Porcentaje = this.oImpuestos.RG5329Porcentaje
				endfor
			endif
		
		catch to loerror
				this.EventoAlAsignarCodigoDeImpuestoNoExistente()
		endtry			

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoAlAsignarCodigoDeImpuestoNoExistente() as void
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Destroy()
		this.lDestroy = .t.
		if vartype( this.oImpuestos ) = "O" and !isnull( this.oImpuestos )
			this.oImpuestos.Release()
		endif
		if type( "This.perceIIBB.oItem.Tipo" ) = "O" and !isnull( This.perceIIBB.oItem.Tipo )
			This.perceIIBB.oItem.Tipo.Release()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			goServicios.Entidades.AccionesAutomaticas.RefrescarColeccionDeEntidadesConAccionesAutomaticas()
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneComponenteDeAccionesAutomaticasParaDatosFiscales() as Boolean
		return vartype( this.oCompAccionesAutomaticasParaDatosFiscales ) = "O" and !isnull( this.oCompAccionesAutomaticasParaDatosFiscales )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstadoParametrosPercIIBB() as Void
		local lnI as Integer, llHayPercepcionIIBB as Boolean 
		for lnI = 1 to this.PerceIIBB.count
			if upper(alltrim(this.PerceIIBB.item[lnI].aplicacion )) = "PRC" ;
				and upper(alltrim(this.PerceIIBB.item[lnI].tipo_pk )) = "IIBB"
				llHayPercepcionIIBB = .t.
				exit
			endif 
		endfor

		with this
			.lHabilitarNroObligatorio = llHayPercepcionIIBB
			.lHabilitarAutocompletarJurisdic = llHayPercepcionIIBB
			.lHabilitarAutocompletarPercRiesgo = llHayPercepcionIIBB
		endwith 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		with this
			.lHabilitarNroObligatorio = .f.
			.lHabilitarAutocompletarJurisdic = .f.
			.lHabilitarAutocompletarPercRiesgo = .f.
			.lhabilitarMontoMinimo = this.Reintegro
		endwith 
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneCargadaAlgunaPercepcionSegunTipoDeImpuesto( tcTipoImpuesto as String ) as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		for each loItem in this.PerceIIBB
			if upper( alltrim( loItem.Aplicacion ) ) == "PRC" and upper( alltrim( loItem.Tipo_PK ) ) == alltrim( tcTipoImpuesto )
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		local llRetorno as boolean, loSinCC as Object, lcCuenta as String, lcDetalleCuentas as String
		llRetorno = dodefault()		
		if !empty(this.RetPercSiempreSegunJurisdiccion_PK)
			if !this.PerceIIBB.ValidarExisteJurisdiccion( this.RetPercSiempreSegunJurisdiccion_PK )
				llRetorno = .F.
				this.AgregarInformacion( "La jurisdicción ingresada en Configuración adicional debe corresponder a un impuesto del esquema de datos fiscales." )
			endif
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearEstadoMinimo() as Void
		this.lhabilitarMontoMinimo = this.Reintegro
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function modificar() as Void
		dodefault()
		this.lhabilitarMontoMinimo = this.Reintegro
	endfunc  

	*-----------------------------------------------------------------------------------------
	function TieneImpuestosInternos() as Void
	local llRetorno as Boolean 
	with this.perceIIBB
		for lnI = 1 to .Count
			if upper( .item[ lnI ].Tipo_Pk ) = "IMPINTERNO"
				llRetorno = .t.
				exit
			endif
		endfor
	endwith	
	return llRetorno

enddefine
