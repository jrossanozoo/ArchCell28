define class Ent_Cliente as Din_EntidadCliente of Din_EntidadCliente.prg

	#if .f.
		local this as Ent_Cliente of Ent_Cliente.prg
	#endif

	lHabilitarCUIT = .f.
	lHabilitarRUT = .f.
	nPais = 0
	lPermiteModificarSegunClasificacion = .T.
	lClasificacionRequiereSeguridadModifClienteOriginal = .T.
	lClasificacionRequiereSeguridadModifClienteAnterior = .T.	
	oColaboradorPercepciones = null
	oColaboradorPercepcionesAltoRiesgoFiscal = null
	cClaveTributaria = ""
	lSitFiscalConClave = .t.
	ocolaboradorpercepcionesExcluidosIvaGanancia = null
	oColaboradorValidacionMail = null
	lDebeValidarAtributo = .t.
	lEligioUnCodigoDeLaLista = .F.
	oLogueadorOperacionesAvanzadas = null
	cCuitAnterior = ""
	oSituacionFiscal = null
	oTipoDocumento = null
	oImpuestos = null
	lPreguntarSiDebeEliminar = .f.
	nMensajeEliminarCliente = 0
	lPermiteAltaClienteExistente = .f.
	lPermitePorcentaje0EnTasa0 = .t.
	lPermiteMailDuplicado = .t.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
	
		dodefault()
		this.nPais = goParametros.Nucleo.DatosGenerales.Pais 
		this.AsignarClaveTributariaPorPais()
		this.enlazar( "Situacionfiscal_PK_Assign", "EventoModificarSolapasYEtiquetas")		
		if vartype( This.PercepcionGanancias )= 'O'
			This.BindearEvento( This.PercepcionGanancias, "AjustarObjetoBusqueda" , This, "SetearFiltroBuscadorGanancias" )
		endif
		if vartype( This.PercepcionIVA )= 'O'
			This.BindearEvento( This.PercepcionIVA, "AjustarObjetoBusqueda" , This, "SetearFiltroBuscadorIVA" )
		endif

	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function oImpuestos_Access() as variant
		if !this.ldestroy and ( !vartype( this.oImpuestos ) = 'O' or isnull( this.oImpuestos ) )
			this.oImpuestos = _screen.zoo.instanciarentidad( 'Impuesto' )
		endif
		return this.oImpuestos
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function CambiosDetalleExcluidoOtraPercep() as void
		dodefault()
		try
			for each loItem in this.ExcluidoOtraPercep
				this.oImpuestos.Codigo 	= loItem.Codigo_pk
 				loItem.Aplicacion = this.oImpuestos.Aplicacion				
				loItem.Tipo_pk = this.oImpuestos.Tipo_PK				
				loItem.Porcentaje = this.oImpuestos.Porcentaje
			endfor
		
		catch to loerror
		endtry
		
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Destroy()
		this.lDestroy = .t.
		if vartype( this.oImpuestos ) = "O" and !isnull( this.oImpuestos )
			this.oImpuestos.Release()
		endif
		if type( "This.ExcluidoOtraPercep.oItem.Tipo" ) = "O" and !isnull( This.ExcluidoOtraPercep.oItem.Tipo )
			This.ExcluidoOtraPercep.oItem.Tipo.Release()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorGanancias( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaPago as String, lccondicionAnulado as String, loOrdenDePago
		toBusqueda.Filtro = toBusqueda.Filtro + " and impuesto.tipo = 'GANANCIAS' and impuesto.aplicacion = 'PRC'"
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorIVA( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaPago as String, lccondicionAnulado as String, loOrdenDePago
		toBusqueda.Filtro = toBusqueda.Filtro + " and impuesto.tipo = 'IVA' and impuesto.aplicacion = 'PRC'"
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_PercepcionGanancias( txVal as variant ) as void

		dodefault( txVal )
		if !empty(txval)
			if !this.PercepcionGanancias.Tipo.esTipoGanancias() or !this.PercepcionGanancias.EsPercepcion()
				goServicios.Errores.LevantarExcepcion( 'El tipo de impuesto debe ser ganancias (GANANCIAS) y la aplicación debe ser percepción.' )
			endif
		endif

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_PercepcionIVA( txVal as variant ) as void

		dodefault( txVal )
		if !empty(txval)
			if !this.PercepcionIVA.Tipo.EsTipoValorAgregado() or !this.PercepcionIVA.EsPercepcion()
				goServicios.Errores.LevantarExcepcion( 'El tipo de impuesto debe ser impuesto al valor agregado (IVA) y la aplicación debe ser percepción.' )
			endif
		endif

	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function AsignarClaveTributariaPorPais() as Void
	
		if inlist( this.nPais, 2, 3 )
			this.cClaveTributaria = "RUT"
		else
			this.cClaveTributaria = "CUIT"
		endif

	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Pais( txVal as variant ) as void
		dodefault( txVal )
		this.EventoCambioPais()		
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoCambioPais() as Void
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Nuevo() As Boolean
		This.lClasificacionRequiereSeguridadModifClienteOriginal = .F.
		This.lClasificacionRequiereSeguridadModifClienteAnterior = .F.			
		llRetorno = dodefault()	
		if llRetorno
			if this.nPais = 1
				this.SetearHabilitarCUIT()
			else
				this.HabilitarAtributos()
			endif
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearHabilitarCUIT( tlLimpiaCUIT as Boolean ) as Void
		do case
			case this.SituacionFiscal_pk = 3
				this.lHabilitarTipoDocumento = .T.
				this.lHabilitarNroDocumento = .T.
				if tlLimpiaCUIT
					this.lHabilitarCuit	= .T.
					this.Cuit = ""
				endif
				this.lHabilitarCuit	= .f.
			case this.SituacionFiscal_pk = 7 && Monotributista - DNI Y CUIT habilitados
				this.lHabilitarTipoDocumento = .T.
				this.lHabilitarNroDocumento = .T.
				this.lHabilitarCuit	= .T.
			otherwise
				this.lHabilitarTipoDocumento = .t.
				this.lHabilitarNroDocumento = .t.
				this.TipoDocumento = "05"
				this.NroDocumento = ""
				this.lHabilitarTipoDocumento = .f.
				this.lHabilitarNroDocumento = .f.
				this.lHabilitarCuit	= .t.	
		endcase
		this.lHabilitarRUT = .F.
	endfunc 


	*-----------------------------------------------------------------------------------------
	function Modificar() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		This.PermiteModificarSegunClasificacion()
		if This.lPermiteModificarSegunClasificacion
			llRetorno = dodefault()
		else
			goServicios.Errores.LevantarExcepcion( "La configuración de la clasificación del cliente no permite su modificación." )
		endif
		if this.nPais = 1
			this.SetearHabilitarCUIT()
		else
			this.HabilitarAtributos()
		endif
		return llRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function PermiteModificarClasificacion( ) as Void

		if ( This.lClasificacionRequiereSeguridadModifClienteOriginal and ;
			This.lClasificacionRequiereSeguridadModifClienteAnterior = This.lClasificacionRequiereSeguridadModifClienteOriginal ) ;
			or This.Clasificacion.RequiereSeguridadModifCliente 
			
			This.lPermiteModificarSegunClasificacion = ;
				goServicios.Seguridad.PedirAccesoEntidad( alltrim( upper( This.ObtenerNombre() ) ) , "MODIFICARSEGUNCLASIF", .f., "" ) 
		else
			This.lPermiteModificarSegunClasificacion = .T.	
		endif		
		if This.lPermiteModificarSegunClasificacion
			This.lClasificacionRequiereSeguridadModifClienteAnterior = This.Clasificacion.RequiereSeguridadModifCliente
		endif 	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function PermiteModificarSegunClasificacion() as Void  
		local llRequiereSeguridad as Boolean

		try
			llRequiereSeguridad = This.Clasificacion.RequiereSeguridadModifCliente
		catch 
			llRequiereSeguridad = .f.
		endtry
		
		This.lClasificacionRequiereSeguridadModifClienteOriginal = llRequiereSeguridad 
		This.lClasificacionRequiereSeguridadModifClienteAnterior = llRequiereSeguridad 
		
		if llRequiereSeguridad 
			This.lPermiteModificarSegunClasificacion = ;
				goServicios.Seguridad.PedirAccesoEntidad( alltrim( upper( This.ObtenerNombre() ) ) , "MODIFICARSEGUNCLASIF", .f., "" ) 
		else
			This.lPermiteModificarSegunClasificacion = .T.	
		endif	
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Eliminar() as Boolean
		local llRetorno as Boolean, lnMensaje as String
				
		this.nMensajeEliminarCliente = 0

		llRetorno = .T.

		this.TieneSaldoPendienteCtaCte()

		if this.nMensajeEliminarCliente > 0 
			this.lPreguntarSiDebeEliminar =  .F.
			this.EventoPreguntarSiEliminaSiTieneSaldoPendienteCtaCte( this.nMensajeEliminarCliente )
			if this.lPreguntarSiDebeEliminar
					llRetorno = .F.
			endif	
		endif
		
		if llRetorno 
			This.PermiteModificarSegunClasificacion()

			if This.lPermiteModificarSegunClasificacion
				llRetorno = dodefault()
			else
				goServicios.Errores.LevantarExcepcion( "La configuración de la clasificación del cliente no permite su eliminación." )
			endif
		endif
			
		return llRetorno 
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	function TieneSaldoPendienteCtaCte() as Void
		local loComponente as Object, lcCursorCtaCte as String, lcSentencia as String, ;
		lnMontoCheques as Integer, lnDeudaTotal  as Integer, clGlobalid as String
				
		lnMontoCheques = 0
		lnDeudaTotal = 0
		lcCursorCtaCte = sys(2015)
		
		try
			lcGlobalid = this.obteneridglobal( this.codigo )
		Catch to loError
		endtry
		

		if type( "lcGlobalid" ) = 'C' and !empty(lcGlobalid)
			lcWhereCtaCte = "where CLGlobalid = '" + alltrim(lcGlobalid) + "' "
			this.nMensajeEliminarCliente = 2
		else
			lcWhereCtaCte = "where Cliente = '" + this.codigo + "' "
			this.nMensajeEliminarCliente = 1
		endif
		
		lcSentencia = "Select coalesce( sum(abs(TOTALCC)*sign((signo * sign(TOTALCC)) + 1 )) - sum(abs(TOTALCC)*sign(-(signo * sign(TOTALCC)) + 1 )), 0, sum(abs(TOTALCC)*sign((signo * sign(TOTALCC)) + 1 )) "
		lcSentencia = + lcSentencia + " - sum(abs(TOTALCC)*sign(-(signo * sign(TOTALCC)) + 1 )) ) as deuda from " + _screen.zoo.app.cschemadefault + ".CTACTE " + lcWhereCtaCte 

		goServicios.Datos.EjecutarSentencias( lcSentencia, "CTACTE", "", lcCursorCtaCte, this.DataSessionId )

		select( lcCursorCtaCte )
			if Deuda <> 0
				lnDeudaTotal = Deuda
			endif
		use in select( "lcCursorCtaCte" ) 	
			
		if goParametros.Felino.GestionDeVentas.CuentaCorriente.IncluirChequesDeTercerosNoVencidosAlSaldoDeudor
			loComponente = _screen.zoo.instanciarcomponente( "ComponenteCheques" )
			lnMontoCheques = loComponente.ObtenerMontoDeChequesPendientesDelCliente( this.Codigo ) 
			lnDeudaTotal = lnDeudaTotal + lnMontoCheques 
		endif

		if lnDeudaTotal = 0
			this.nMensajeEliminarCliente = 0
		endif
					

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiEliminaSiTieneSaldoPendienteCtaCte( tnMensaje as Integer ) as Void
		&& Evento para pedir confirmacion del usuario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoModificar() as Void
		&& Para que se enganche el Kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoEliminar() as Void
		&& Para que se enganche el Kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoValidarClasificacion() as Void
		&& Para que se enganche el Kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() AS boolean
		local llRetorno as boolean, llValidarMail, llCamposRepetidos
		llRetorno = dodefault()		
			
		if llRetorno	
			
			llValidarMail = this.oColaboradorValidacionMail.ValidarMail(this.email, this)
			llCamposRepetidos = this.ValidarCamposRepetidos()	
			
			llRetorno = llValidarMail and llCamposRepetidos 
			
		endif
		
		if goParametros.Felino.DatosImpositivos.CuitValidoObligatorioEnElAltaDeClientes = 2		
			if !This.ValidarCUIToRUT()		
				llRetorno = .F.
			endif
		endif
		
		if This.ValidarNroIIBB()
		else
			this.AgregarInformacion( 'Debe cargar el Número de IIBB si el cliente tiene Convenio Local, Multilateral o Exento' )
			llRetorno = .F.
		endif
		
		if llRetorno and this.nPais = 3
			llRetorno = this.ValidarRelacionPaisTipoDocParaUruguay()
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposRepetidos() as Boolean
		local llRetorno as Boolean, lnPermiteDniCuitDeClienteRepetido as Integer, lnPermiteMailRepetido as Integer
		
		lnPermiteDniCuitDeClienteRepetido = goParametros.Dibujante.PermiteDniCuitDeClienteRepetido
		lnPermiteMailRepetido = goparametros.Dibujante.PermiteMailDeClienteRepetido
		
		llRetorno = .t.

		if This.ValidarNombreRepetido( this.nombre )
		else
				llRetorno = .F.
		endif 
		
		if llRetorno
			llRetorno = this.ValidarMailRepetido( this.email, lnPermiteMailRepetido )
		endif

		if llRetorno and inlist( this.SituacionFiscal_Pk, 3, 7 )
			llRetorno = This.ValidarNroDocumentoRepetido( this.NroDocumento, lnPermiteDniCuitDeClienteRepetido )
		endif
		
		if llRetorno and this.SituacionFiscal_Pk != 3
			llRetorno = This.ValidarCuitRepetido(this.CUIT, lnPermiteDniCuitDeClienteRepetido )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_Nombre( txValor as Variant ) as Boolean 
		if dodefault( txValor ) And This.ValidarNombreRepetido( txValor )
		else
			local loEx as Exception
			loEx = Newobject(  "ZooException", "ZooException.prg" )
			With loEx
				.Message = "El Nombre de Cliente a grabar ya existe."
				.Details = .Message
				.Grabar()
				.Throw()
			endwith 
		endif
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarNombreRepetido( tcNombre as String ) as Boolean
		local llRetorno as Boolean, lcTabla as String, lcXml as String
		llRetorno = .T.
		with this
			llPermiteNombreClienteRepetido = goParametros.Dibujante.PermiteNombreDeClienteRepetido
			if !llPermiteNombreClienteRepetido  and !empty( tcNombre )
				lcTabla = sys( 2015 )
				lcXml = .oAD.ObtenerDatosEntidad( '', 'Nombre == "' + tcNombre + '" and !( alltrim( Codigo ) == "' + alltrim( This.Codigo ) + '")','' , '' )
				.XmlACursor( lcXml, lcTabla )
				if reccount( lcTabla ) >= 1
					llRetorno = .F.
					this.AgregarInformacion( "El Nombre de Cliente a grabar ya existe." )
				endif	
				use in select( lcTabla )
			endif	
		endwith
		return llRetorno
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarMailRepetido( tcMail as String, lnPermiteMailDeClienteRepetido as integer ) as Boolean
		local llRetorno as Boolean, lcTabla as String, lcXml as String, lcMensajeError as String
				 
		llRetorno = .t.
		lcMensajeError = ""
		with this
			if lnPermiteMailDeClienteRepetido != 1 and !empty( tcMail )
				lcTabla = sys( 2015 )
				lcXml = .oAD.ObtenerDatosEntidad( '', 'EMAIL == "' + alltrim( tcMail ) + '" and !( alltrim( Codigo ) == "' + alltrim( This.Codigo ) + '")','' , '' )
				.XmlACursor( lcXml, lcTabla )
				if reccount( lcTabla ) >= 1
					
					if lnPermiteMailDeClienteRepetido = 2
						lcMensajeError = "El MAIL del cliente a grabar ya existe."
						llRetorno = .f.
					else	
						this.lPermiteMailDuplicado = iif( lnPermiteMailDeClienteRepetido = 3, .t., .f. )
						this.EventoPreguntarSiPermiteMailDuplicado( lnPermiteMailDeClienteRepetido )
						if this.lPermiteMailDuplicado 
							llRetorno = .t.
						else
							lcMensajeError = "Modifique el MAIL."
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
	protected function ValidarCuitRepetido( tcCuit as String, lnPermiteDniCuitDeClienteRepetido as integer ) as Boolean
		local llRetorno as Boolean, lcTabla as String, lcXml as String, lcMensajeError as String
				 
		llRetorno = .t.
		lcMensajeError = ""
		with this
			if lnPermiteDniCuitDeClienteRepetido != 1 and !empty( tcCuit )
				lcTabla = sys( 2015 )
				lcXml = .oAD.ObtenerDatosEntidad( '', 'CUIT == "' + tcCuit + '" and !( alltrim( Codigo ) == "' + alltrim( This.Codigo ) + '")','' , '' )
				.XmlACursor( lcXml, lcTabla )
				if reccount( lcTabla ) >= 1
					
					if lnPermiteDniCuitDeClienteRepetido = 2
						lcMensajeError = "El CUIT del cliente a grabar ya existe."
						llRetorno = .f.
					else	
						this.lPermiteAltaClienteExistente = iif( lnPermiteDniCuitDeClienteRepetido = 3, .t., .f. )
						this.EventoPreguntaAltaClienteExistente( "CUIT", lnPermiteDniCuitDeClienteRepetido )
						if this.lPermiteAltaClienteExistente
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
	protected function ValidarNroDocumentoRepetido( tcDni as String, lnPermiteDniCuitDeClienteRepetido as integer ) as Boolean
		local llRetorno as Boolean, lcTabla as String, lcXml as String, lcMensajeError as String
				 
		llRetorno = .t.
		lcMensajeError = ""
		with this
			if lnPermiteDniCuitDeClienteRepetido != 1 and !empty( tcDni )
				lcTabla = sys( 2015 )
				lcXml = .oAD.ObtenerDatosEntidad( '', 'NroDocumento == "' + tcDni + '" and !( alltrim( Codigo ) == "' + alltrim( This.Codigo ) + '")','' , '' )
				.XmlACursor( lcXml, lcTabla )
				if reccount( lcTabla ) >= 1
					
					if lnPermiteDniCuitDeClienteRepetido = 2
						lcMensajeError = "El número de documento del cliente a grabar ya existe."
						llRetorno = .f.
					else	
						this.lPermiteAltaClienteExistente = iif( lnPermiteDniCuitDeClienteRepetido = 3, .t., .f. )
						this.EventoPreguntaAltaClienteExistente( "DOCUMENTO", lnPermiteDniCuitDeClienteRepetido )
						if this.lPermiteAltaClienteExistente
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
	function EventoPreguntaAltaClienteExistente( tcTipoDoc as String, tnInteraccion as Integer ) as Void
		*!* Bindeado en el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiPermiteMailDuplicado( tnSiguere as Integer ) as Void
		*!* Bindeado en el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCUIToRUT() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .T.
		
		if inlist( this.nPais, 1, 3 )
			this.lSitFiscalConClave  = inlist( this.SituacionFiscal_Pk, 1, 4, 7 )
		endif

		if !this.ValidarClaveTributaria()
			llRetorno = this.ProcesarErrorClaveTributaria()	
		endif		
		
		return llRetorno
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarClaveTributaria() as Boolean
		local llRetorno as Boolean, lcAtributo as String, lcValidador as String, lcPais as String

		lcPais = iif( this.nPais = 3, "Uruguay", "" )
		lcAtributo = "this." + this.cClaveTributaria 
		lcValidador = "goLibrerias.Validar" + this.cClaveTributaria + lcPais + "( this." + this.cClaveTributaria + " )" 

		llRetorno = .t.
		if ( empty( &lcAtributo ) or ( &lcValidador = .f. ) ) and this.lSitFiscalConClave
			llRetorno = .f.
		endif
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarErrorClaveTributaria() as Boolean
		local llRetorno as Boolean

		if goParametros.Felino.DatosImpositivos.CuitValidoObligatorioEnElAltaDeClientes = 2
			this.AgregarInformacion( 'El ' + this.cClaveTributaria + ' está vacío o es inválido.' )
			llRetorno = .f.
		else
			this.EventoAdvertirPorErrorEnClaveTributaria()
			llRetorno = .t.
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAdvertirPorErrorEnClaveTributaria() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function ValidarNroIIBB() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		with this.oColaboradorPercepciones	
			if vartype(.oDatosFiscales) = "O" and .oDatosFiscales.TieneCargadaAlgunaPercepcionSegunTipoDeImpuesto( "IIBB") and;
			.DebeTenerSeteadoNroDeIibbParaConvenioLocalOMultilateral() and ;
			inlist( this.TipoConvenio, 1, 2, 4) and empty( this.NroIIBB )

				llRetorno = .F.
			endif
		endwith 
		return llRetorno 
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

	*-----------------------------------------------------------------------------------------
	function Setear_SituacionFiscal( txVal as variant ) as void
		
		dodefault( txVal )
		
		if this.nPais = 1
			this.SetearHabilitarCUIT( .t. )
			this.EventoEstablecerObligatoriedadClaveTributaria()
		else
			this.lHabilitarCUIT = .F.
			this.lHabilitarRUT = .T.			
		endif
		
		this.HabilitarIIBB()
		this.AutocompletarJurisdicciones()

	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function EventoEstablecerObligatoriedadClaveTributaria() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerTopeCtaCte() as Integer
		local lnTope as Integer

		return iif ( this.TopeCtaCte > 0, This.TopeCtaCte, goParametros.Felino.GestionDeVentas.CuentaCorriente.ElSaldoAdeudadoNoPuedeExceder )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Tipoconvenio( txVal as variant ) as void
		dodefault( txVal )
		this.lHabilitarNroIIBB = this.HabilitarNroIIBB()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HabilitarIIBB() as Void
		
		this.lHabilitarTipoConvenio = !inlist(this.SituacionFiscal_Pk, 0, 3)

		if this.lHabilitarTipoConvenio and empty( this.TipoConvenio )
			this.TipoConvenio = 1
		endif
		
		this.lHabilitarNroIIBB = this.lHabilitarTipoConvenio and this.HabilitarNroIIBB()
		
		if this.SituacionFiscal_Pk # 0 and !this.lHabilitarTipoConvenio
			this.lHabilitarTipoConvenio = .t.
			this.TipoConvenio = 0
			this.lHabilitarTipoConvenio = .f.
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AutocompletarJurisdicciones() as Void
		if this.lHabilitarNroIIBB and this.Percepciones.count = 0 and this.oColaboradorPercepciones.DebeAutocompletarJurisdiccionesDePercepcionesEnClientes()
			this.EventoInsertarJurisdicciones()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoInsertarJurisdicciones() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarNroIIBB() as Void
		return inlist( this.TipoConvenio,1,2,4 )
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
	function RequiereLimiteDeConsumo() as Boolean
	local llRequiereLimiteDeConsumo as Boolean

		try
			llRequiereLimiteDeConsumo = this.Clasificacion.RequiereLimiteDeConsumo
		catch
			llRequiereLimiteDeConsumo = .f.
		endtry
		return llRequiereLimiteDeConsumo 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_Clasificacion( txValor as Variant, txValorOld as Variant ) as boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault( txValor, txValorOld )

		if llRetorno and ( txValor # txValorOld )
			This.PermiteModificarClasificacion()
			if !This.lPermiteModificarSegunClasificacion
				llRetorno = .f.
				This.Clasificacion_pk = ""
				goServicios.Errores.LevantarExcepcion( "La configuración de la clasificación del cliente no permite su modificación." )
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSituacionFiscalValidoCliente() as Integer
		local lnSituacionFiscalCliente as Integer
		
		if pemstatus( this, "SituacionFiscal", 5 ) and !empty( This.SituacionFiscal_pk )
			lnSituacionFiscalCliente = this.ObtenerSituacionFiscalCliente()
		else 
			lnSituacionFiscalCliente = goRegistry.felino.SituacionFiscalClienteConsumidorFinal
		endif
		
		return lnSituacionFiscalCliente 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSituacionFiscalCliente() as Integer
		local lnSituacionFiscalCliente as Integer, lcCursor, lcCadena, lcXml 
		
		lcCursor = sys( 2015 ) 
		lcCadena = "Codigo = '" + alltrim( this.Codigo )+ "'" 
		lcXml = this.ObtenerDatosEntidad( "SituacionFiscal", lcCadena ) 
		xmltocursor( lcXml, lcCursor ) 
		select ( lcCursor ) 
		lnSituacionFiscalCliente = &lcCursor..SituacionFiscal 
		use in select( lcCursor ) 
	
		return lnSituacionFiscalCliente 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionSituacionFiscalCliente() as Integer
		local lcSituacionFiscalCliente as String, lcCursor as String, lcCadena as String, lcXml as String
		lcSituacionFiscalCliente = ""
		lcCursor = sys( 2015 ) 
		lcCadena = "Codigo = '" + alltrim(str( this.SituacionFiscal_PK ))+ "'" 
		lcXml = this.oSituacionFiscal.ObtenerDatosEntidad( "Descripcion", lcCadena ) 
		xmltocursor( lcXml, lcCursor ) 
		select ( lcCursor ) 
		lcSituacionFiscalCliente = alltrim( &lcCursor..Descripcion )
		use in select( lcCursor ) 
	
		return lcSituacionFiscalCliente 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDelTipoDeDocumento() as String
		local lcRetorno as String 
		lcRetorno = ""
		lcRetorno = this.oTipoDocumento.ObtenerDescripcionTipoDocumento( this.TipoDocumento )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerListaDePreciosValidoCliente() as String
		local lcListaDePrecios as String
		
		if pemstatus( this, "ListaDePrecio_PK", 5 ) and !empty( This.ListaDePrecio_PK )
			lcListaDePrecios = This.ListaDePrecio_PK
		else
			lcListaDePrecios = goParametros.Felino.Precios.ListasDePrecios.ListaDePreciosPreferente
		endif
		
		return lcListaDePrecios 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAtributos() as Void

		this.lHabilitarCUIT = iif( this.nPais = 1, .t., .f. )
		this.lHabilitarRUT  = iif( this.nPais = 1, .f., .t. )
		
		
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function EventoModificarEtiquetas() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoRefrescarSolapas() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoModificarSolapasYEtiquetas( txval ) as Void
 		this.EventoRefrescarSolapas()
		this.EventoModificarEtiquetas()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeAsignarCUIT() as Void
		local llEsRest as Boolean
		if this.HabilitarPrecargaDePercepcionesAltoRiesgoFiscal()
			goMensajes.EnviarSinEsperaProcesando( "Verificando si el CUIT está incluído en los padrones de contribuyentes de alto riesgo fiscal..." )
			this.EventoPrecargarPercepcionesDeAltoRiesgoFiscal()
			goMensajes.EnviarSinEsperaProcesando()
		endif
	
		if !empty( this.Cuit )
			if  this.oColaboradorPercepcionesExcluidosIvaGanancia.FiguraEnPadronDeGanancias( this.Cuit )
				this.ExcluidoPercepcionGanancias = this.oColaboradorPercepcionesExcluidosIvaGanancia.lExcluidoGanancia
				this.VigenciaHastaGan = ctod( this.oColaboradorPercepcionesExcluidosIvaGanancia.cFechaVigenciaGanancias )
			endif
			
			if  this.oColaboradorPercepcionesExcluidosIvaGanancia.FiguraEnPadronDeIva(this.Cuit)
				this.ExcluidoPercepcionIVA = this.oColaboradorPercepcionesExcluidosIvaGanancia.lExcluidoIva
				this.VigenciaHastaIva = ctod( this.oColaboradorPercepcionesExcluidosIvaGanancia.cFechaVigenciaIva )
			endif
			
			llEsRest = pemstatus(_screen,"lUsaServicioRest", 5) and _Screen.lUsaServicioRest
			
			if !this.VerificarContexto( "BCI" ) and !llEsRest
				if this.Cuit != this.cCuitAnterior and len( alltrim( this.cuit ) ) > 10
					this.cCuitAnterior = this.Cuit
					this.VerificarDatosPadron()
				endif
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HabilitarPrecargaDePercepcionesAltoRiesgoFiscal() as Boolean
		local llRetorno as Boolean

	    llRetorno = vartype(this.oColaboradorPercepciones.oDatosFiscales) = "O" and  this.oColaboradorPercepciones.oDatosFiscales.TieneCargadaAlgunaPercepcionSegunTipoDeImpuesto( "IIBB") 		
		llRetorno = llRetorno and this.oColaboradorPercepciones.DebeAutocompletarPercepcionesDeAltoRiesgoFiscalEnClientes()
		llRetorno = llRetorno and this.CargaManual() and ( this.EsNuevo() or this.EsEdicion() )
		llRetorno = llRetorno and !empty( this.cuit )

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPrecargarPercepcionesDeAltoRiesgoFiscal() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColaboradorPercepcionesAltoRiesgoFiscal_Access() as Object
		with this
			if !this.lDestroy and ( vartype( .oColaboradorPercepcionesAltoRiesgoFiscal ) # "O"  or isnull( .oColaboradorPercepcionesAltoRiesgoFiscal ) )
				.oColaboradorPercepcionesAltoRiesgoFiscal = _Screen.Zoo.CrearObjeto( "ColaboradorPercepcionesAltoRiesgoFiscal" )
			endif
		endwith
		return this.oColaboradorPercepcionesAltoRiesgoFiscal
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColaboradorValidacionMail_Access() as Object
		with this
			if !this.lDestroy and ( vartype( .oColaboradorValidacionMail ) # "O"  or isnull( .oColaboradorValidacionMail ) )
				.oColaboradorValidacionMail = _Screen.Zoo.CrearObjeto( "ColaboradorValidacionMail" )
			endif
		endwith
		return this.oColaboradorValidacionMail
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorPercepciones_Access() as variant
		if this.lDestroy
		else
			if ( vartype( this.oColaboradorPercepciones ) != "O" or isnull( this.oColaboradorPercepciones ) )
				this.oColaboradorPercepciones = _Screen.zoo.CrearObjeto( "ColaboradorPercepciones" )
				this.oColaboradorPercepciones.InstanciarDatosFiscales()
			endif
		endif
		return this.oColaboradorPercepciones
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
	function oLogueadorOperacionesAvanzadas_access() as variant
		if !this.ldestroy and ( type( "this.oLogueadorOperacionesAvanzadas" ) <> 'O' or isnull( this.oLogueadorOperacionesAvanzadas ))
			this.oLogueadorOperacionesAvanzadas = _screen.Zoo.CrearObjeto( "LogueoOperacionesAvanzadas" )
		endif
		return this.oLogueadorOperacionesAvanzadas
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oSituacionFiscal_access() as variant
		if !this.ldestroy and ( type( "this.oSituacionFiscal" ) <> 'O' or isnull( this.oSituacionFiscal ))
			this.oSituacionFiscal = _screen.Zoo.InstanciarEntidad( "SituacionFiscal" )
		endif
		return this.oSituacionFiscal
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oTipoDocumento_access() as variant
		if !this.ldestroy and ( type( "this.oTipoDocumento" ) <> 'O' or isnull( this.oTipoDocumento))
			this.oTipoDocumento = _screen.Zoo.CrearObjeto( "TipoDocumento" )
		endif
		return this.oTipoDocumento
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarUnDetalle( toDetalle as detalle OF detalle.prg, tcEtiqueta as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( toDetalle, tcEtiqueta )
		if upper( alltrim( tcEtiqueta )) == upper( alltrim( 'Percepciones' ))
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
	function EsValidoAtributoObligatorio( tcAtributo, tcDescAtributo, tcDetalle ) as Void
		local llRetorno as Boolean, llHacerValidacion as Boolean, llContexto as Boolean
		this.lDebeValidarAtributo = .t.
		llHacerValidacion = .T.
		llContexto = this.VerificarContexto( "IR" )
		llRetorno = .t.
		this.EventoDebeValidarAtributoObligatorio( tcAtributo, tcDetalle ) && esto no se ejecuta si no hay formulario (ej. al importar clientes)
		
		if this.lDebeValidarAtributo
			
			* Si llContexto = .T. el evento no se ejecutó (por estar en el kontroler) y no analizó si debe validarlo o no.
			* Buscar si el atributo esta en la coleccion de Atributos que tienen comportamiento "obligatorio" definido por el usuario
			if llContexto
				if inlist( upper( alltrim( tcAtributo ) ), "PRIMERNOMBRE","SEGUNDONOMBRE","NOMBRE","CUIT","NRODOCUMENTO" ) 
					llRetorno = this.EvaluarSiEstaVacio( tcAtributo )

					if !llRetorno
						this.AgregarInformacion( "Debe cargar el campo " + alltrim( tcDescAtributo ), 9005, alltrim( upper( tcAtributo ) ) )
					endif
					
					llHacerValidacion = .F.
				else
					llHacerValidacion = .T.
				endif
			else
				llHacerValidacion = .T.
			endif
			if llHacerValidacion
				llRetorno = dodefault( tcAtributo, tcDescAtributo, tcDetalle )
			endif
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EvaluarSiEstaVacio( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, loCol as Object, loItem as Object
		
		loCol = this.oColAtributosObligatoriosDefinidosPorUsuario
		for each loItem in loCol foxobject
			if alltrim( upper( loItem.cAtributo ) ) == upper( alltrim( tcAtributo ) )
				if This.SituacionFiscal_pk = 3 && Consumidor Final
					if inlist( tcAtributo, "PRIMERNOMBRE", "SEGUNDONOMBRE", "APELLIDO", "NRODOCUMENTO" )
						llRetorno = !empty( this.&tcAtributo )
					else
						llRetorno = .T.
					endif
				else && Resp.Inscripto, Monotributista y demás
					if inlist( tcAtributo, "CUIT", "NOMBRE" )
						llRetorno = !empty( this.&tcAtributo )
					else
						llRetorno = .t.
					endif
				endif
				exit
			endif
		endfor
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDebeValidarAtributoObligatorio( tcAtributo, tcDetalle ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerIdGlobal( tcCodigoCliente as String ) as String
		local lcIdGlobal as String
		if pcount() = 0
			lcIdGlobal = this.ObtenerIdGlobalDelClienteSeteado()
		else
			lcIdGlobal = this.ObtenerIdGlobalPorCodigoDeCliente( tcCodigoCliente )
		endif
		return lcIdGlobal
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdGlobalDelClienteSeteado() as String
		return this.IdGlobal
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdGlobalPorCodigoDeCliente( tcCodigoCliente as String ) as String
		local lcIdGlobal as String, lcXml as String, lcNombreCursor as String
		lcIdGlobal = ""
		with this
			lcNombreCursor = sys( 2015 )
			lcXml = .oAD.ObtenerDatosEntidad( "IdGlobal", "Codigo == '" + tcCodigoCliente + "'" )
			.XmlACursor( lcXml, lcNombreCursor )
			if reccount( lcNombreCursor ) >= 1
				lcIdGlobal = &lcNombreCursor..IdGlobal
			endif	
			use in select( lcNombreCursor )
		endwith
		return lcIdGlobal
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoDeClientePorIdGlobal( tcIdGlobal as String ) as String
		local lcCodigo as String, lcXml as String, lcNombreCursor as String
		lcCodigo = ""
		with this
			lcNombreCursor = sys( 2015 )
			lcXml = .oAD.ObtenerDatosEntidad( "Codigo", "IdGlobal == '" + tcIdGlobal + "'" )
			.XmlACursor( lcXml, lcNombreCursor )
			if reccount( lcNombreCursor ) >= 1
				lcCodigo = &lcNombreCursor..Codigo
			endif	
			use in select( lcNombreCursor )
		endwith
		return lcCodigo
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = .F. 
		if dodefault() and this.ValidarDescuento()
			llRetorno = .T.
		else 
			this.AgregarInformacion( "El Descuento seleccionado tiene un modo de funcionamiento no permitido para la operación." )
		endif
		llRetorno = llRetorno and this.ValidarTasaCero()
		return llRetorno
	endfunc

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

	*-------------------------------------------------------------------------------------------------
	Function ValidarDescuento() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			if alltrim( this.DescuentoPreferente_PK ) != "" and this.DescuentoPreferente.ModoFuncionamiento != 4 and this.DescuentoPreferente.ModoFuncionamiento != 6
					llRetorno = .F.
			endif
		endif
		
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoBusquedaEspecial( tcAtributo as String, toRetorno as Object ) as Void
		local lcDatosAyuda as String, lcAtributo as String, lcTributo as String
		lcAtributo = upper(alltrim(tcAtributo))
		
		lcTributo = iif( this.nPais = 1, "CLCUIT", "RUT" )
		toRetorno.lIgualarAnchoDeAtributo = .t. && Todos tienen el ancho del subgrupo
		lcDatosAyuda = "rtrim(CLNOM) + '  - Móvil: (' + rtrim(CLMOVIL) + ') - Fijo: (' + rtrim(CLTLF) + ') - E-Mail: (' + rtrim(CLemail) + ')' as Ayuda"
		toRetorno.Atributo = alltrim( tcAtributo )
		do case
			case inlist(lcAtributo, "PRIMERNOMBRE", "SEGUNDONOMBRE", "APELLIDO", "NOMBRE" ) && NOMBRE = RAZON SOCIAL
				toRetorno.Campo = "CLNOM"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD,CLNOM, case CLIVA when 3 then clnrodoc else " + lcTributo + " end as Documento, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,CLNOM,Documento,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,250,78,250"
			case lcAtributo == "NRODOCUMENTO"
				toRetorno.Campo = "CLNRODOC"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD, case CLIVA when 3 then clnrodoc else " + lcTributo + " end as Documento,CLNOM, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,Documento,CLNOM,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,78,250,250"
			case lcAtributo == "CUIT"
				toRetorno.Campo = "CLCUIT"
				toRetorno.CamposQuery =lcDatosAyuda + ",CLCOD, case CLIVA when 3 then clnrodoc else " + lcTributo + " end as Documento,CLNOM, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,Documento,CLNOM,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,78,250,250"
			case lcAtributo == "RUT"
				toRetorno.Campo = "RUT"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD, case CLIVA when 3 then clnrodoc else " + lcTributo + " end as Documento,CLNOM, CLEMAIL"
				toRetorno.CamposSelect = "Ayuda,CLCOD,Documento,CLNOM,CLEMAIL"
				toRetorno.lcAnchoColumnas = "0,0,78,250,250"
			case lcAtributo == "EMAIL"
				toRetorno.Campo = "CLEMAIL"
				toRetorno.CamposQuery = lcDatosAyuda + ",CLCOD,CLEMAIL,CLNOM, case CLIVA when 3 then clnrodoc else " + lcTributo + " end as Documento "
				toRetorno.CamposSelect = "Ayuda,CLCOD,CLEMAIL,CLNOM,Documento"
				toRetorno.lcAnchoColumnas = "0,0,212,212,78"
		endcase
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerWhereBusqueda( tcAtributo as String, tcParcial as String ) as String
		local lcRetorno as String, lcPN as String, lcSN as String, lcApe as String
		lcPN = ""
		lcSN = ""
		lcApe = ""
		if inlist( alltrim( upper( tcAtributo ) ), "PRIMERNOMBRE", "SEGUNDONOMBRE", "APELLIDO" )
			if alltrim( upper( tcAtributo ) ) != "PRIMERNOMBRE"
				lcPN = This.oAd.FormatearTextoSql( alltrim( upper( this.PrimerNombre ) ) )
			endif
			if alltrim( upper( tcAtributo ) ) != "SEGUNDONOMBRE"
				lcSN = This.oAd.FormatearTextoSql( alltrim( upper( this.SegundoNombre ) ) )
			endif
			if alltrim( upper( tcAtributo ) ) != "APELLIDO"
				lcApe = This.oAd.FormatearTextoSql( alltrim( upper( this.Apellido ) ) )
			endif
			lcCampo = this.oAd.ObtenerCampoEntidad( "NOMBRE" )
			
			lcRetorno = lcCampo + " like '%" + This.oAd.FormatearTextoSql( tcParcial ) + "%'" + iif( !empty( lcPN ), " and " + lcCampo + " like '%" + lcPN + "%'", "" ) + ;
						+ iif( !empty( lcSN), " and " + lcCampo + " like '%" + lcSN + "%'", "" ) + + iif(!empty(lcApe), " and " + lcCampo + " like '%" + lcApe + "%'", "" )
		else
			lcCampo = this.oAd.ObtenerCampoEntidad( tcAtributo )
			lcRetorno = lcCampo + " like '%" + This.oAd.FormatearTextoSql( tcParcial ) + "%'"
		endif		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSelectBusqueda( tcCamposQuery as String ) as String
		local lcRetorno as String
		lcRetorno = "select top 10 " + alltrim( tcCamposQuery ) + " from " + alltrim( this.oAd.cEsquema ) + "." + alltrim( this.oAd.cTablaPrincipal )
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarFiltrosInsertarDesde( toFiltros as object ) as void
		this.oLogueadorOperacionesAvanzadas.CargarFiltrosInsertarDesde( toFiltros )
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarDatosPadron() as Void
		local loColaboradorConsultarPadron as Object, loDatosPadron as Object, loError as Object, lnIdSituacionFiscal as Integer, ;
			lcDescripcion as String, lcDomicilioFiscal as String, lcCodigoPostal as String, lcLocalidad as String, lcProvincia as String, ;
			lcIdProvincia as String, lcAux as String, lcMensajeError as String, loErrorALoguear as Object, loError as Object 

		try
			this.EventoMensajeInicioProcesando()
		
			loDatos = this.ConsultarDatosEnAFIP( this.Cuit )
		
			if !isnull( loDatos.DatosCliente )
				this.EventoSeCargaronDatosAfip()
			
				lnIdSituacionFiscal = val( loDatos.DatosCliente.IdSituacionFiscal )
				lcDescripcion = nvl( loDatos.DatosCliente.Descripcion, "" )
				lcDomicilioFiscal = nvl( loDatos.DatosCliente.DomicilioFiscal, "" )
				lcCodigoPostal = nvl( loDatos.DatosCliente.CodigoPostal, "" )
				lcLocalidad = nvl( loDatos.DatosCliente.Localidad, "" )
				lcProvincia = nvl( loDatos.DatosCliente.Provincia, "" )
				lcIdProvincia = nvl( loDatos.DatosCliente.IdProvincia, "" )
				lcMensajeError = nvl( loDatos.DatosCliente.MensajeError, "" )
				
				with this
					if lnIdSituacionFiscal != 0 or (lnIdSituacionFiscal = 99 and !empty( lcMensajeError ))
						if .SituacionFiscal_pk != 3 and !empty( lcMensajeError )
							lcMensajeError = "AFIP informa: " + lcMensajeError + chr(13) + "No se puede determinar situación fiscal."
							this.EventoMostrarMensajeAfip( lcMensajeError )
							loError = _screen.zoo.crearobjeto( "zooException" )
							loErrorALoguear = CREATEOBJECT("exception")
							loErrorALoguear.Message = "CUIT:" + this.CUIT + chr(13) + lcMensajeError
							loError.Grabar( loErrorALoguear )
						else
							.SituacionFiscal_PK = lnIdSituacionFiscal
						endif
						if .SituacionFiscal_pk = 3
							lcAux = substr( alltrim( lcDescripcion ), 1, 60 )
							.PrimerNombre = lcAux 
						else
							.Nombre = strtran( lcDescripcion, "'", "" )
						endif
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
							if empty( .PrimerNombre )
								.PrimerNombre = lcDescripcion 
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
		catch to loError
		finally
			this.EventoMensajeFinProcesando()
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeAfip( tcMensaje as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarDatosEnAFIP( tcCuit as String ) as Object
		local loRetorno as Object
		
		goServicios.ConsultaAFIP.ObtenerDatosAcceso()
		loRetorno = goServicios.ConsultaAFIP.ObtenerDatos( tcCuit ) 
		
		return loRetorno
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
			this.Localidad = alltrim( this.Localidad + "Provincia: " + alltrim( tcDescripcionProvincia ) )
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
			this.Localidad = alltrim( this.Localidad + " - Pais: Argentina" )
		endif
		use in ( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function limpiarFlag() as Void
		dodefault()
		this.cCuitAnterior = ""
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_TopeCtaCte( txval as Variant ) as boolean
		local llRetorno as boolean
		
		llRetorno = dodefault( txVal )
		llRetorno = llRetorno and goServicios.Seguridad.PedirAccesoEntidad( alltrim( upper( This.ObtenerNombre() ) ) , "MODIFICARLIMITEDECRE", .f., "" )		
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_ListaDePrecio( txval as Variant, txValOld as variant ) as boolean
		local llRetorno as boolean
		
		llRetorno = dodefault( txVal, txValOld )
		if this.CargaManual()		
			llRetorno = llRetorno and goServicios.Seguridad.PedirAccesoEntidad( alltrim( upper( This.ObtenerNombre() ) ) , "SALTOCAMPOLPRECIO", .f., "" )		
			if !llRetorno
				this.ListaDePrecio_PK = txValOld
			endif			
		endif
		
		return llRetorno
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
