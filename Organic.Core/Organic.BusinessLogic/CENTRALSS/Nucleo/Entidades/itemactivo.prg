define class ItemActivo as zooSession of zooSession.prg

	#IF .f.
		Local this as ItemActivo of ItemActivo.prg
	#ENDIF

	lLimpiando = .f.
	lCargando = .f.
	
	NroItem = 0
	lNuevo = .f.
	lEdicion = .f.
	oValidacionDominios	= null	
	datasession = 1
	oMensaje = null
	lEstaSeteandoValorSugerido = .f.
	oComportamientoCodigoSugerido = null
	lBuscandoCodigo = .f.
	lEsSubEntidad = .f.
	lInstanciarSubEntidadaDemanda = .t.
	lEstaImportando = .f.
	oItemAnterior = null
	lTieneAtributosSumarizados = .f.
	lSeteandoAtributoAcumulado = .f.

	*-----------------------------------------------------------------------------------------
	function oMensaje_Access() as Object
		if !this.ldestroy and ( !vartype( this.oMensaje ) = 'O' or isnull( this.oMensaje ) )
			this.oMensaje = _screen.zoo.crearobjeto( "mensajeentidad", "", this )
		endif
		
		return this.oMensaje
	endfunc 
	
	*-------------------------------------------------------------------------------------------------
	Function Init()
		local llRetorno as Boolean
		
		llRetorno = DoDefault() And ( This.Class # "Itemactivo" )
		if llRetorno
			this.oValidacionDominios = goServicios.Controles.oDominios
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Limpiar( tlForzar as boolean ) as void
		*** esta funcion se va a generar
		if tlForzar
		else
			this.NroItem = 0
		Endif	
	endfunc

	*-----------------------------------------------------------------------------------------
	*** agrega a la coleccion lo que esta en el item activo
	function ValidarExistenciaCamposFijosItemPlano() as boolean
		*** Este método se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	*** agrega a la coleccion lo que esta en el item activo
	function ValidarExistenciaCamposFijos() as boolean
		*** Este método se genera
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CambioSumarizado() as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambioCombinacion() as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function EsNuevo() As Boolean
		Return This.lNuevo
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function EsEdicion() As Boolean
		Return This.lEdicion
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Habilitar( tlHabilitar as Boolean ) as Void
		*** Este método se genera
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function CargaManual() as Void
		return !This.lCargando .and. !This.lLimpiando .and. !This.lDestroy
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HaCambiado( tcAtributo as String, toItem as Object ) as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as Void
	*** Este método se sobrescribe
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerComponente( tcComponente as String ) as Object 
		local lcComponente as String, loRetorno as Object
		
		loRetorno = null
		lcComponente = "This.oComp" + alltrim( tcComponente )
		
		if type( lcComponente  ) = "O"
			loRetorno = &lcComponente
		endif
		
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as VOID
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oValidacionDominios = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oComportamientoCodigoSugerido_Access() as Object
		if !this.ldestroy and !vartype( this.oComportamientoCodigoSugerido ) = 'O'
			this.oComportamientoCodigoSugerido = _Screen.zoo.Instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		endif
		return this.oComportamientoCodigoSugerido
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeSugerirCodigo() as Boolean
		return .f.
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function SetearValoresSugeridos() as void
	*** Este método se sobrescribe
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PuedeEjecutarHaCambiado() as boolean
		return .t.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function PuedeEjecutarCambioSumarizado() as boolean
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function BindearComponentes() as Void
		dodefault()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DesbindearComponentes() as Void
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsItemRetiroEnEfectivo() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ElementoAnterior( tcAtributo) as Object
	local lcRetorno as Object, lcAtributo as String
		lcRetorno = null
		lcAtributo = iif(pemstatus( this, tcAtributo+"_PK", 5 ), tcAtributo + "_PK", tcAtributo)
		if vartype(this.oItemAnterior)="O"
			lcRetorno = this.oItemAnterior.&lcAtributo
			else
			do case
				case vartype(this.&lcAtributo)="C"
					lcRetorno= ""
				case vartype(this.&lcAtributo)="N"
					lcRetorno= 0
			endcase
		endif                                                                                                                                                                                                                                                                  
		return lcRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidarSiCambioElValorDelAtributo( tcAtributo as String, txValOld as variant, txVal as variant ) as Boolean
		local llRetorno as Boolean
		do case
			case inlist( upper( tcAtributo ), "IDITEMARTICULOS" )	&& "IDITEMVALORES"
				llRetorno = .f.
			case upper( tcAtributo ) = "CANTIDAD"
				if pemstatus( this, "Articulo_Pk", 5 ) and empty( this.Articulo_Pk )
					llRetorno = .f.
				else
					llRetorno = ( txValOld != txVal )
				endif
			otherwise
				llRetorno = ( txValOld != txVal )
		endcase
		return llRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AcumularSumarizado( tlForzar as Boolean, tcAtributo as String, tnValor as Decimal, tnValorAnt as Decimal ) as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TotalizarSumarizado( ttoItem as Object ) as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 

enddefine
