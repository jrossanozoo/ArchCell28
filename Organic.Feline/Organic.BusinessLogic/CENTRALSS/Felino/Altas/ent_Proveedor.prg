define class Ent_Proveedor as Din_EntidadProveedor of Din_EntidadProveedor.prg

	#if .f.
		local this as Ent_Proveedor of Ent_Proveedor.prg
	#endif

	oColaboradorRetenciones = null
	oColaboradorRetencionesDesdePadron = null
	ocolaboradorpercepcionesExcluidosIvaGanancia = null
	oColaboradorFechasVigentes = null
	cCuitAnterior = ""
	lPermiteAltaProveedorExistente = .f.
	lPermitePorcentaje0EnTasa0 = .t.
	nPais = 0

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.nPais = goParametros.Nucleo.DatosGenerales.Pais
		this.enlazar( "Situacionfiscal_PK_Assign", "EventoModificarEtiquetasYSolapas")
	endfunc

	*-----------------------------------------------------------------------------------------
	function Modificar() as Boolean
		local llRetorno as Boolean
		dodefault()
		llRetorno = .T.
		
		if this.nPais != 3
			this.HabilitarDeshabilitarSiprib()
		endif
		this.HabilitarAtributos()

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColaboradorRetencionesDesdePadron_Access() as Object
		with this
			if !this.lDestroy and ( vartype( .oColaboradorRetencionesDesdePadron ) # "O"  or isnull( .oColaboradorRetencionesDesdePadron ) )
				.oColaboradorRetencionesDesdePadron = _Screen.Zoo.CrearObjeto( "ColaboradorPercepcionesAltoRiesgoFiscal" )
			endif
		endwith
		return this.oColaboradorRetencionesDesdePadron
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorRetenciones_Access() as variant
		if this.lDestroy
		else 
			if ( vartype( this.oColaboradorRetenciones ) != "O" or isnull( this.oColaboradorRetenciones ) )
				this.oColaboradorRetenciones = _Screen.zoo.CrearObjeto( "ColaboradorRetenciones" )
			endif
		endif
		return this.oColaboradorRetenciones
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorPercepcionesExcluidosIvaGanancia_Access() as Object
		if this.lDestroy
		else
			if ( vartype( this.oColaboradorPercepcionesExcluidosIvaGanancia ) != "O" or isnull( this.oColaboradorPercepcionesExcluidosIvaGanancia ) )
				this.oColaboradorPercepcionesExcluidosIvaGanancia = _Screen.zoo.CrearObjeto( "ColaboradorPercepcionesExcluidosIvaGanancia" )
			endif
		endif
		return this.oColaboradorPercepcionesExcluidosIvaGanancia
	endfunc 	

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorFechasVigentes_Access() as Object
		if !this.ldestroy and ( !vartype( this.oColaboradorFechasVigentes ) = 'O' or isnull( this.oColaboradorFechasVigentes ) )
			this.oColaboradorFechasVigentes = _Screen.zoo.CrearObjeto( "ColaboradorFechasVigentes" )
		endif
		return this.oColaboradorFechasVigentes
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarCamposObligatoriosDefinidosPorUsuario() as Boolean
		local llRetorno as Boolean, loCol as zoocoleccion OF zoocoleccion.prg, lnI as Integer, ;
				lcAtributo as String, lcDescAtributo as String, lcDetalle as String

		llRetorno = .t.
		loCol = this.oColAtributosObligatoriosDefinidosPorUsuario
		
		for lnI = 1 to loCol.Count
			lcAtributo = loCol.Item( lnI ).cAtributo
			lcDescAtributo = loCol.Item( lnI ).cEtiqueta
			lcDetalle = alltrim( loCol.Item( lnI ).cDetalle )
			this.lOmiteObligatorioEnPack = loCol.Item( lnI ).lOmiteObligatorioEnPack
			if this.SituacionFiscal_PK !=3 
				if upper( alltrim( lcAtributo ) ) != 'NRODOCUMENTO' 
					if !this.EsAtributoObligatorioExistente( lcAtributo )
						llRetorno = this.EsValidoAtributoObligatorio( lcAtributo, lcDescAtributo, lcDetalle ) and llRetorno
					endif
				endif	
			else
				if !this.EsAtributoObligatorioExistente( lcAtributo )
					llRetorno = this.EsValidoAtributoObligatorio( lcAtributo, lcDescAtributo, lcDetalle ) and llRetorno
				endif
			endif
		next
		
		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Cuit_DespuesDeAsignar() as Void
		local llEsRest as Boolean
		
		dodefault()		
		if !empty( this.Cuit )

			if  this.oColaboradorPercepcionesExcluidosIvaGanancia.FiguraEnPadronDeGanancias( this.Cuit )
				this.ExcluidoRetencionGanancias = this.oColaboradorPercepcionesExcluidosIvaGanancia.lExcluidoGanancia
				this.VigenciaHastaGan = ctod( this.oColaboradorPercepcionesExcluidosIvaGanancia.cFechaVigenciaGanancias )
			endif
			
			if  this.oColaboradorPercepcionesExcluidosIvaGanancia.FiguraEnPadronDeIva( this.Cuit )
				this.ExcluidoRetencionIva = this.oColaboradorPercepcionesExcluidosIvaGanancia.lExcluidoIva
				this.VigenciaHastaIva = ctod( this.oColaboradorPercepcionesExcluidosIvaGanancia.cFechaVigenciaIva )
			endif
			
			llEsRest = pemstatus(_screen,"lUsaServicioRest", 5) and _Screen.lUsaServicioRest
			
			if !this.VerificarContexto( "BCI" ) and !llEsRest
				if this.Cuit != this.cCuitAnterior
					this.cCuitAnterior = this.Cuit
					this.VerificarDatosPadron()
				endif
			endif
		endif
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_RetencionGanancias( txVal as variant ) as void

		dodefault( txVal )
		if !empty(txval)
			if this.RetencionGanancias.Tipo_PK # 'GANANCIAS' or this.RetencionGanancias.Aplicacion # 'RTN'
				goServicios.Errores.LevantarExcepcion( 'El tipo de impuesto debe ser ganancias (GANANCIAS) y la aplicación debe ser retención.' )
			endif
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorGanancias( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaPago as String, lccondicionAnulado as String, loOrdenDePago
		toBusqueda.Filtro = toBusqueda.Filtro + " and impuesto.tipo = 'GANANCIAS' and aplicacion = 'RTN'"
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_RetencionIVA( txVal as variant ) as void

		dodefault( txVal )
		if !empty(txval)
			if this.RetencionIVA.Tipo_PK # 'IVA' or this.RetencionIVA.Aplicacion # 'RTN'
				goServicios.Errores.LevantarExcepcion( 'El tipo de impuesto debe ser impuesto al valor agregado (IVA) y la aplicación debe ser retención.' )
			endif
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorIVA( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaPago as String, lccondicionAnulado as String, loOrdenDePago
		toBusqueda.Filtro = toBusqueda.Filtro + " and impuesto.tipo = 'IVA' and aplicacion = 'RTN'"
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Retencionsuss( txVal as variant ) as void

		dodefault( txVal )
		if !empty(txval)
			if this.RetencionSuss.Tipo_PK # 'SUSS' or this.RetencionSuss.Aplicacion # 'RTN'
				goServicios.Errores.LevantarExcepcion( 'El tipo de impuesto debe ser Seguridad Social (SUSS) y la aplicación debe ser retención.' )
			endif
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorSUSS( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaPago as String, lccondicionAnulado as String, loOrdenDePago
		toBusqueda.Filtro = toBusqueda.Filtro + " and impuesto.tipo = 'SUSS' and aplicacion = 'RTN'"
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsProveedorExcluidoDeRetencion( tcTipoDeImpuesto as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		do case
		case tcTipoDeImpuesto = "IVA"
			llRetorno = this.ExcluidoRetencionIVA and this.oColaboradorFechasVigentes.EsFechaVigente( this.VigenciaHastaIva )
		case tcTipoDeImpuesto = "GANANCIAS"
			llRetorno = this.ExcluidoRetencionGanancias and this.oColaboradorFechasVigentes.EsFechaVigente( this.VigenciaHastaGan )
		case tcTipoDeImpuesto = "SUSS"
			llRetorno = this.ExcluidoRetencionSUSS
		endcase
		return llRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function Validar_Fechanacimiento( txVal as variant ) as Boolean
		local ldFecha, lcSetCentury, llRetorno

		llRetorno = dodefault( txVal )
		lcSetCentury = set("Century")
		set century on
		ldFecha = date()

		if ldFecha < txVal
			llRetorno = .F.
			set century &lcSetCentury
			goServicios.Errores.LevantarExcepcion( "La fecha de nacimiento no puede ser posterior a la fecha actual." )
		endif
		
		set century &lcSetCentury
		return llRetorno		
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargaAutomaticaRetenciones() as Void 
		if this.HabilitarPrecargaDeRetencionesDesdePadron()
			goMensajes.EnviarSinEsperaProcesando( "Verificando si el CUIT está incluído en los padrones de recaudacion por sujeto..." )
			this.EventoPrecargarRetenciones()
			goMensajes.EnviarSinEsperaProcesando()
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarPrecargaDeRetencionesDesdePadron() as Boolean
		local llRetorno as Boolean
		
		llRetorno = this.oColaboradorRetenciones.EsAgenteDeRetencionSegunTipoDeImpuesto("IIBB") 
		llRetorno = llRetorno and this.CargaManual() and ( this.EsNuevo() or this.EsEdicion() )
		llRetorno = llRetorno and !empty( this.cuit )	

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPrecargarRetenciones() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarUnDetalle( toDetalle as detalle OF detalle.prg, tcEtiqueta as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( toDetalle, tcEtiqueta )
		if upper( alltrim( tcEtiqueta )) == upper( alltrim( 'Retenciones' ))
			llRetorno = llRetorno and this.ValidarJurisdiccionEnDetalle( toDetalle )
		endif
		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ValidarJurisdiccionEnDetalle( toDetalle as detalle OF detalle.prg ) as Boolean
		local llRetorno as boolean, lnIndice as Integer, loItem as Object
		llRetorno = .T.
		llRetorno = dodefault()
		for lnIndice = 1 to toDetalle.Count
			loItem = toDetalle.item[ lnIndice ]
			if empty( loItem.Jurisdiccion_pk )
				loop
			else
				do case
				case loItem.Excluido
					if !empty( loItem.FechaExpiracion ) or !empty( loItem.Porcentaje )
						llRetorno = .f.
						this.AgregarInformacion( "Si la jurisdicción (" + alltrim(loItem.Jurisdiccion_PK) + ") tiene marca de excluida no puede tener valor en porcentaje ni en fecha de expiración.", 0 )
					endif
				other
					if !empty( loItem.Porcentaje ) and empty( loItem.FechaExpiracion )
						llRetorno = .f.
						this.AgregarInformacion( "No puede dejar vacía la fecha de expiración si carga un porcentaje en la jurisdicción (" + alltrim(loItem.Jurisdiccion_PK) + ").", 0 )
					endif
				endcase
			endif
		endfor
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarDeshabilitarSiprib() as Void
		local llHabilitarControlesSiprib as Boolean
		
		llHabilitarControlesSiprib = .F.
		for each Retenciones in this.Retenciones
			if alltrim(Retenciones.jurisdiccion_pk ) = "921"
				llHabilitarControlesSiprib = .T.
			endif
		endfor

		if llHabilitarControlesSiprib
			this.lHabilitarCodigoSiprib_PK = .T.
		else
			if this.esedicion() or this.esnuevo()
				this.codigoSIPRIB_PK = ""
				this.lHabilitarCodigoSiprib_PK = .F.
			endif
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarDatosPadron() as Void
		local loColaboradorConsultarPadron as Object, loDatosPadron as Object, loError as Object, lnIdSituacionFiscal as Integer, ;
			lcDescripcion as String, lcDomicilioFiscal as String, lcCodigoPostal as String, lcLocalidad as String, lcProvincia as String, ;
			lcIdProvincia as String
			
		try
			this.EventoMensajeInicioProcesando()
			
			goServicios.ConsultaAFIP.ObtenerDatosAcceso()
			loDatos = goServicios.ConsultaAFIP.ObtenerDatos( this.Cuit )
			
			if !isnull( loDatos.DatosCliente )
				this.EventoSeCargaronDatosAfip()
			
				lnIdSituacionFiscal = val( loDatos.DatosCliente.IdSituacionFiscal )
				lcAux = nvl( loDatos.DatosCliente.Descripcion, "" )
				lcDescripcion = substr( alltrim( lcAux ), 1, 60 )
				lcDomicilioFiscal = nvl( loDatos.DatosCliente.DomicilioFiscal, "" )
				lcCodigoPostal = nvl( loDatos.DatosCliente.CodigoPostal, "" )
				lcLocalidad = nvl( loDatos.DatosCliente.Localidad, "" )
				lcProvincia = nvl( loDatos.DatosCliente.Provincia, "" )
				lcIdProvincia = nvl( loDatos.DatosCliente.IdProvincia, "" )
				
				with this
					if lnIdSituacionFiscal != 0
						.SituacionFiscal_PK = lnIdSituacionFiscal 
						.Nombre = lcDescripcion 
						.Calle = lcDomicilioFiscal 
						.CodigoPostal = lcCodigoPostal 
						.Localidad = lcLocalidad 
						if !empty( lcProvincia ) and !empty( lcIdProvincia  )
							.BuscarProvincia( loDatos.DatosCliente.Provincia, loDatos.DatosCliente.IdProvincia )
						endif
						.CargarPais()
					else
						if ( !empty( lcDescripcion ) or !empty( lcDomicilioFiscal ) or !empty( lcCodigoPostal ) or ; 
								!empty( lcLocalidad ) or  !empty( lcProvincia ) or !empty( lcIdProvincia ) )
							.SituacionFiscal_PK = 3 &&Consumidor Final
							if empty( .Nombre )
								.Nombre = lcDescripcion 
							endif
							if empty( .Calle )
								.Calle = lcDomicilioFiscal 
							endif
							if empty( .CodigoPostal )
								.CodigoPostal = lcCodigoPostal 
							endif
							if empty( .Localidad )
								.Localidad = lcLocalidad 
							endif
							if !empty( lcProvincia ) and !empty( lcIdProvincia  ) and empty( .Provincia_pk  )
								.BuscarProvincia( loDatos.DatosCliente.Provincia, loDatos.DatosCliente.IdProvincia )
							endif
							.CargarPais()
						endif
					endif
				endwith
			endif
		catch
		finally
			this.EventoMensajeFinProcesando()
		endtry
	endfunc

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = .F. 
		llRetorno = dodefault()
		llRetorno = llRetorno and this.ValidarTasaCero()
	return llRetorno
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarTasaCero() as Boolean
		local llRetorno as Boolean, lcMensaje as String

		this.lPermitePorcentaje0EnTasa0 = .t.
		
		if this.tasaceroaplica and this.tasaceroporcen <= 0
			this.EventoPreguntaPermitePorcentaje0EnTasa0()
			
			if !this.lPermitePorcentaje0EnTasa0
				this.AgregarInformacion( 'El proceso ha sido cancelado por el usuario.' )
			endif
		endif

		return this.lPermitePorcentaje0EnTasa0
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Tasaceroporcen( txVal as variant ) as void

		dodefault( txVal )
		if txval < 0
			goServicios.Errores.LevantarExcepcion( 'El valor no puede ser negativo.' )
		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntaPermitePorcentaje0EnTasa0() as void
		&& Para que se Bindee el Kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSeCargaronDatosAfip() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeInicioProcesando() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeFinProcesando() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoModificarEtiquetasYSolapas( txval ) as Void
		this.EventoModificarEtiquetas()
		this.EventoRefrescarSolapas()
		this.EventoSetearDefaultTipoConvenio()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoRefrescarSolapas() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoModificarEtiquetas() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSetearDefaultTipoConvenio() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() AS boolean
		local llRetorno as boolean
		llRetorno = dodefault()		
		llRetorno = ( llRetorno and this.ValidarCamposRepetidos() )
		if llRetorno and this.nPais = 3
			llRetorno = this.ValidarRelacionPaisTipoDocParaUruguay()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposRepetidos() as boolean
		local llRetorno as Boolean, lnPermiteDniCuitDeProveedorRepetido as Integer

		lnPermiteDniCuitDeProveedorRepetido = goParametros.Dibujante.PermiteDniCuitDeProveedorRepetido
		if this.situacionfiscal_pk = 3
			llRetorno = This.ValidarNroDocumentoRepetido( this.TipoDocumento, this.NroDocumento, lnPermiteDniCuitDeProveedorRepetido )
		else
			llRetorno = This.ValidarCUITRepetido(this.CUIT, lnPermiteDniCuitDeProveedorRepetido )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCuitRepetido( tcCuit as String, lnPermiteDniCuitDeProveedorRepetido as integer ) as Boolean
		local llRetorno as Boolean, lcTabla as String, lcXml as String, lcMensajeError as String

		llRetorno = .t.
		lcMensajeError = ""
		with this
			if lnPermiteDniCuitDeProveedorRepetido != 1 and !empty( tcCuit )
				lcTabla = sys( 2015 )
				lcXml = .oAD.ObtenerDatosEntidad( '', 'CUIT == "' + tcCuit + '" and !( alltrim( Codigo ) == "' + alltrim( This.Codigo ) + '")','' , '' )
				.XmlACursor( lcXml, lcTabla )
				if reccount( lcTabla ) >= 1
					
					if lnPermiteDniCuitDeProveedorRepetido = 2
						lcMensajeError = "El CUIT del proveedor a grabar ya existe."
						llRetorno = .f.
					else	
						this.lPermiteAltaProveedorExistente = iif( lnPermiteDniCuitDeProveedorRepetido = 3, .t., .f. )
						this.EventoPreguntaAltaProveedorExistente( "CUIT", lnPermiteDniCuitDeProveedorRepetido )
						if this.lPermiteAltaProveedorExistente
							llRetorno = .t.
						else
							lcMensajeError = "Modifique el numero de CUIT."
							llRetorno = .f.
						endif
					endif
									
				endif
				use in select( lcTabla )
				
				if !empty( lcMensajeError )
					this.AgregarInformacion( lcMensajeError )
				endif				
			endif	
		endwith
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarNroDocumentoRepetido( tcTipo as String, tcDni as String, lnPermiteDniCuitDeProveedorRepetido as integer ) as Boolean
		local llRetorno as Boolean, lcTabla as String, lcXml as String, lcMensajeError as String
				 
		llRetorno = .t.
		lcMensajeError = ""
		with this
			if lnPermiteDniCuitDeProveedorRepetido != 1 and !empty( tcDni )
				lcTabla = sys( 2015 )
				lcXml = .oAD.ObtenerDatosEntidad( '', 'TipoDocumento == "' + tcTipo + '" and NroDocumento == "' + tcDni + '" and !( alltrim( Codigo ) == "' + alltrim( This.Codigo ) + '")','' , '' )
				.XmlACursor( lcXml, lcTabla )
				if reccount( lcTabla ) >= 1
					
					if lnPermiteDniCuitDeProveedorRepetido = 2
						lcMensajeError = "El número de documento del proveedor a grabar ya existe."
						llRetorno = .f.
					else	
						this.lPermiteAltaProveedorExistente = iif( lnPermiteDniCuitDeProveedorRepetido = 3, .t., .f. )
						this.EventoPreguntaAltaProveedorExistente( "DOCUMENTO", lnPermiteDniCuitDeProveedorRepetido )
						if this.lPermiteAltaProveedorExistente
							llRetorno = .t.
						else
							lcMensajeError = "Modifique el numero de documento."
							llRetorno = .f.
						endif
					endif
									
				endif
				use in select( lcTabla )
				
				if !empty( lcMensajeError )
					this.AgregarInformacion( lcMensajeError )
				endif
			endif
		endwith
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntaAltaProveedorExistente( tcTipoDoc as String, tnInteraccion as Integer ) as Void
		*!* Bindeado en el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BuscarProvincia( tcDescripcionProvincia as String, tcIdProvincia as String ) as Void
		local lcCursor as String, lcXmlDatos as String
		
		lcCursor = sys(2015)
		if tcIdProvincia = "0"
			lcXmlDatos = this.Provincia.oad.ObtenerDatosEntidad( "Codigo", "Descripcion like '%" + alltrim( tcDescripcionProvincia ) + "%' or Descripcion like '%C.A.B.A.%'" )
		else
			lcXmlDatos = this.Provincia.oad.ObtenerDatosEntidad( "Codigo", "Descripcion like '%" + alltrim( tcDescripcionProvincia ) + "%'" )
		endif
		xmlToCursor( lcXmlDatos, lcCursor )
		
		if reccount( lcCursor ) = 1
			this.Provincia_pk = &lcCursor..Codigo
		else
			this.Localidad = alltrim( this.Localidad + " Provincia: " + alltrim( tcDescripcionProvincia ) )
		endif
		use in ( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarPais() as Void
		local lcCursor as String, lcXmlDatos as String
		
		lcCursor = sys(2015)
		lcXmlDatos = this.Pais.oad.ObtenerDatosEntidad( "Codigo", "Descripcion like '%Argentina%'" )
		xmlToCursor( lcXmlDatos, lcCursor )
		
		if reccount( lcCursor ) = 1
			this.Pais_pk = &lcCursor..Codigo
		else
			this.Localidad = alltrim( this.Localidad + " Pais: Argentina" )
		endif
		use in ( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function limpiarFlag() as Void
		dodefault()
		this.cCuitAnterior = ""
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoBusquedaEspecial( tcAtributo as String, toRetorno as Object ) as Void
		local lcDatosAyuda as String, lcAtributo as String
		lcAtributo = upper(alltrim(tcAtributo))

		toRetorno.lIgualarAnchoDeAtributo = .t. && Todos tienen el ancho del subgrupo
		lcDatosAyuda = "rtrim(CLNOM) + '  - Fijo: (' + rtrim(CLTLF) + ') - E-Mail: (' + rtrim(CLemail) + ')' as Ayuda"
		toRetorno.Atributo = alltrim( tcAtributo )
		do case
			case lcAtributo == "NOMBRE" 	&& NOMBRE = RAZON SOCIAL
				toRetorno.Campo = "CLNOM"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD,CLNOM, case CLIVA when 3 then clnrodoc else CLCUIT end as Documento, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,CLNOM,Documento,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,250,78,250"
			case lcAtributo == "NRODOCUMENTO"
				toRetorno.Campo = "CLNRODOC"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD, case CLIVA when 3 then clnrodoc else CLCUIT end as Documento,CLNOM, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,Documento,CLNOM,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,78,250,250"
			case lcAtributo == "CUIT"
				toRetorno.Campo = "CLCUIT"
				toRetorno.CamposQuery =lcDatosAyuda + ",CLCOD, case CLIVA when 3 then clnrodoc else CLCUIT end as Documento,CLNOM, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,Documento,CLNOM,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,78,250,250"
			case lcAtributo == "RUT"
				toRetorno.Campo = "RUT"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD, case CLIVA when 3 then clnrodoc else CLCUIT end as Documento,CLNOM, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,Documento,CLNOM,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,78,250,250"
			case lcAtributo == "EMAIL"
				toRetorno.Campo = "CLEMAIL"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD,CLEMAIL,CLNOM, case CLIVA when 3 then clnrodoc else CLCUIT end as Documento "
				toRetorno.CamposSelect = "Ayuda,CLCOD,CLEMAIL,CLNOM,Documento"
				toRetorno.lcAnchoColumnas = "0,0,212,212,78"
		endcase
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerWhereBusqueda( tcAtributo as String, tcParcial as String ) as String
		local lcRetorno as String
		lcCampo = this.oAd.ObtenerCampoEntidad( tcAtributo )
		lcRetorno = lcCampo + " like '%" + This.oAd.FormatearTextoSql( tcParcial ) + "%'"
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSelectBusqueda( tcCamposQuery as String ) as String
		local lcRetorno as String
		lcRetorno = "select top 10 " + alltrim( tcCamposQuery ) + " from " + alltrim( this.oAd.cEsquema ) + "." + alltrim( this.oAd.cTablaPrincipal )
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarRelacionPaisTipoDocParaUruguay() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		do case
			case inlist( this.TipoDocumento, "02", "03" ) and this.pais_pk != "UY"
				this.AgregarInformacion( "Si indica RUT o tipo de documento C.I., el país debe ser Uruguay." )
				llRetorno = .f.
			case this.TipoDocumento == "06" and !inlist( this.pais_pk, "AR", "BR", "CL", "PY" )
				this.AgregarInformacion( "Si indica tipo de documento D.N.I., el país debe ser Argentina, Brasil, Chile o Paraguay." )
				llRetorno = .f.
		endcase
		
		return llRetorno
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Situacionfiscal( txVal as variant ) as void

		dodefault( txVal )
		this.HabilitarAtributos()

	endfunc
	
	*-------------------------------------------------------------------------------------------------
	function Nuevo() As Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault()
		this.HabilitarAtributos()

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarAtributos() as Void

		this.lHabilitarCUIT = iif( this.nPais = 3, .f., .t. )
		this.lHabilitarRUT  = iif( this.nPais = 3, .t., .f. )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AsignarSitFiscalDesdeUruguay( txValor as variant ) as Void

		if this.nPais = 3
			this.SituacionFiscal_pk = iif( inlist( this.SitFiscalUruguay, 0, 2 ), 3, 1 ) 
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault() 
		if this.nPais = 3
			llRetorno = llRetorno and this.SetearLaSituacionFiscalUruguay()
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearLaSituacionFiscalUruguay() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		try
			this.SitFiscalUruguay = iif( inlist( this.SituacionFiscal_pk, 3, 0 ), 2, 1 )
		catch to loError
			llRetorno = .f.
		endtry
			
		return llRetorno
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Rut( txVal as Variant ) as Void
	
		dodefault( txVal )
		if this.nPais = 3 and !empty( txVal )
			this.TipoDocumento =  "02"
		endif

	endfunc
	
enddefine
