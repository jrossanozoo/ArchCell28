define class Ent_PersonalizacionDeEntidades as Din_EntidadPersonalizacionDeEntidades of Din_EntidadPersonalizacionDeEntidades.prg

	#if .f.
		local this as Ent_PersonalizacionDeEntidades of Ent_PersonalizacionDeEntidades.prg
	#endif
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Entidad( txVal as variant ) as void
		if this.CargaManual() and ( this.esNuevo() or this.esEdicion() ) 
			this.ValidarEntidadConComportamiento( txVal )
		endif	
		dodefault( txVal )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarEntidadConComportamiento( txval as String ) as void
		local lcXml as String, lcCursor as String, lcMensaje as String

		lcXml = this.oAD.ObtenerDatosEntidad("codigo", "entidad = '" + alltrim(txval ) + "' and codigo != '" + this.Codigo + "'", "", "" )
		lcCursor = "c_" + sys(2015)
		this.XmlACursor( lcXml, lcCursor ) 
		select (lcCursor)
		if reccount() > 0
			lcMensaje = "Atención! La entidad " + alltrim( txval ) + " posee un comportamiento previamente cargado " + ;
				"(" + alltrim( Codigo ) + ")."
			goServicios.Errores.LevantarExcepcion( lcMensaje )
		endif
		use in select (lcCursor)

	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Ocultar( txVal as variant ) as void
		dodefault( txVal )
		this.lHabilitarDenominacionCorta = .t.
		this.lHabilitarDenominacionPlural = .t.
		this.lHabilitarDenominacionSingular = .t.
		if txVal
			this.DenominacionPlural = ""
			this.DenominacionSingular = ""
			this.DenominacionCorta = ""
			this.lHabilitarDenominacionCorta = .f.
			this.lHabilitarDenominacionPlural = .f.
			this.lHabilitarDenominacionSingular = .f.		
		endif
		this.EventoCambioValorOcultarAtributos()

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoCambioValorOcultarAtributos() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			this.ValidarObligatoriedadDenominaciones()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarObligatoriedadDenominaciones() as Void
		if !this.Ocultar and ( empty( this.DenominacionSingular ) or empty( this.DenominacionPlural ) or empty( this.DenominacionCorta ) )
			goServicios.Errores.LevantarExcepcion( "Es necesario completar las denominaciones para grabar la personalización." )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean		
		llRetorno = dodefault()
		if llRetorno
			goservicios.PersonalizacionDeEntidades.RefrescarPersonalizaciones()
			goServicios.Seguridad.RefrescarMenuYBarraDelFormularioPrincipal()
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		dodefault()
		goservicios.PersonalizacionDeEntidades.RefrescarPersonalizaciones()
		goServicios.Seguridad.RefrescarMenuYBarraDelFormularioPrincipal()
	endfunc 

enddefine
