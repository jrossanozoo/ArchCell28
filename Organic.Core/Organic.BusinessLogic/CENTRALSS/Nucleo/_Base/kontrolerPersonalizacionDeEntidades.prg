define class kontrolerPersonalizacionDeEntidades as Din_KontrolerPERSONALIZACIONDEENTIDADES of Din_KontrolerPERSONALIZACIONDEENTIDADES.prg

	#IF .f.
		Local this as kontrolerPersonalizacionDeEntidades of kontrolerPersonalizacionDeEntidades.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Inicializar() as void
		dodefault()
		this.BindearEvento( this.oEntidad, "EventoCambioValorOcultarAtributos", this, "SetearObligatoriedadAtributosOcultables" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearObligatoriedadAtributosOcultables() as Void
		this.SetearObligatoriedadAtributo( "DenominacionCorta", !this.oEntidad.Ocultar )
		this.SetearObligatoriedadAtributo( "DenominacionPlural", !this.oEntidad.Ocultar )
		this.SetearObligatoriedadAtributo( "DenominacionSingular", !this.oEntidad.Ocultar )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearObligatoriedadAtributo( tcAtributo as String, tlValor as Boolean ) as Void
		local lcAtributo as String, loControl as Object
		lcAtributo = upper( alltrim ( tcAtributo ) )
		if this.ExisteControl( lcAtributo )
			loControl = this.ObtenerControl( lcAtributo )
			goServicios.Controles.EstablecerObligatoriedadSiNoDeControl( loControl, tlValor )
			goServicios.Controles.SetearColoresEnControl( loControl )
		endif
	endfunc 

	
enddefine
