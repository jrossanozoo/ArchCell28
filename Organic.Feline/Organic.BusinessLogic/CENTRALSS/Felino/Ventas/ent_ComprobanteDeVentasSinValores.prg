define class Ent_ComprobanteDeVentasSinValores as Her_EntidadComprobanteDeVentas of Her_EntidadComprobanteDeVentas.prg

	#if .f.
		local this as Ent_ComprobanteDeVentasSinValores as Ent_ComprobanteDeVentasSinValores.prg
	#endif

	lAplicarDescuentoDeValores = .f.
	lCambioMonedaComprobante = .f.
	cProvinciaDirecciondeEntrega = ""
	oProvincia = null 
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		If Type( "This.FacturaDetalle" ) = "O"
			This.BindearEvento( This.FacturaDetalle, "EventoVerificarValidezArticulo" , This, "EventoVerificarRestriccionArticulo" )
			If Type( "This.FacturaDetalle.oItem" ) = "O"
				This.BindearEvento( This.FacturaDetalle.oItem.Articulo, "AjustarObjetoBusqueda" , This, "EventoSetearFiltroBuscadorArticulo" ) 		
			Endif 
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oProvincia_Access() as Void
		if !this.lDestroy and !( vartype( this.oProvincia ) == "O" )
			this.oProvincia  = _screen.zoo.instanciarentidad( "Provincia" )
		endif
		return this.oProvincia 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIvaLiberadoSegunProvicinciaEntrega() as Void
		&& se bindea en kontrolercomprobantedeventassinvalores
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EvaluarSiProvicinciadeEntregaTieneIvaLiberado() as Void
		local llEsIvaLiberado as Boolean
		llEsIvaLiberado = .f.
		
		if !empty( this.cProvinciaDirecciondeEntrega )
			this.oProvincia = _Screen.Zoo.InstanciarEntidad( "Provincia" )
			this.oProvincia.Codigo = this.cProvinciaDirecciondeEntrega
			if pemstatus( this.oProvincia, "IvaLiberado", 5 )
				llEsIvaLiberado = this.oProvincia.IvaLiberado
			endif
		endif
		if pemstatus( this, "oComponenteFiscal", 5 ) and type( "this.oComponenteFiscal" ) = "O"
			this.oComponenteFiscal.lIvaLiberadoAnterior = this.oComponenteFiscal.lIvaLiberado
			this.oComponenteFiscal.lIvaLiberado = llEsIvaLiberado
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AsignarTransportista() as Void
		if empty( this.Transportista_Pk )
			this.Transportista_Pk = This.Cliente.transportista_PK
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function AsignarDatosCliente() as Void
		local lcDireccionEntrega as String
		
		if ( this.lNuevo or this.lEdicion ) and ( this.lCambioCliente and !empty( this.Cliente_Pk ) )
			with this.Cliente
				if pemstatus( this, "Transportista_PK", 5 ) and !empty( .Transportista_PK )
					this.Transportista_Pk = .Transportista_PK
				endif
				
				lcDireccionEntrega = this.DireccionPreferente( This.cliente )

				if pemstatus( this, "DireccionEntrega", 5 ) 
					this.DireccionEntrega = lcDireccionEntrega
				endif
				
				if pemstatus( this, "ForPago_PK", 5 ) and !empty( .CondicionDePago_PK )
					this.ForPago_PK = .CondicionDePago_PK
				endif
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function DireccionPreferente( toCliente) as String
		local lcDireccionPreferente as String
		
		lcDireccionPreferente = ""
		for each loDireccion in toCliente.OtrasDirecciones
			if loDireccion.preferente
				lcDireccionPreferente = this.ArmarDireccionPreferente(loDireccion)
				exit
			endif
		endfor
		if empty( lcDireccionPreferente )
			with toCliente
				lcDireccionPreferente = iif( alltrim( .Calle ) == "", "", alltrim( .Calle ) + " " ) + ;
					 					 iif( .Numero == 0, "", transform( .Numero ) + " " ) + ;
										 iif( alltrim( .Piso ) == "", "", alltrim( .Piso ) + " " ) + ;
										 iif( alltrim( .Departamento ) == "", "", alltrim( .Departamento ) + " " ) + ;
										 iif( alltrim( .Localidad ) == "", "", alltrim( .Localidad ) + " " ) + ;
										 iif( alltrim( .CodigoPostal ) == "", "", "(" + alltrim( .CodigoPostal ) + ") " ) + ;
										 iif( alltrim( .Provincia.Descripcion ) == "", "", alltrim( .Provincia.Descripcion ) + " - " ) + ; 
										 iif( alltrim( .Pais.Descripcion ) == "", "", alltrim( .Pais.Descripcion ) )
			endwith
		endif
		if empty( lcDireccionPreferente ) and  toCliente.OtrasDirecciones.Count = 1  
			for each loDireccion in toCliente.OtrasDirecciones
				lcDireccionPreferente = this.ArmarDireccionPreferente(loDireccion)
				exit
			endfor
		endif
		
		return lcDireccionPreferente
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ArmarDireccionPreferente( toItemDireccion ) as String
		local lcDireccion as String
	
		with toItemDireccion
			lcDireccion = alltrim(.Calle)
			if !empty(.Numero)
				lcDireccion = lcDireccion + " " + transform(.Numero)
			endif
			if !empty(.Piso)
				lcDireccion = lcDireccion + " " + alltrim(.Piso)
			endif
			if !empty(.Departamento)
				lcDireccion = lcDireccion + " " + alltrim(.Departamento)
			endif
			
			if !empty(.Localidad) or !empty(.CodigoPostal)
				lcDireccion = lcDireccion + ","
			endif
			if !empty(.Localidad)
				lcDireccion = lcDireccion + " " + alltrim(.Localidad)
			endif
			if !empty(.CodigoPostal)
				lcDireccion = lcDireccion + " (" + alltrim(.CodigoPostal) + ")"
			endif
			
			if !empty(.ProvinciaDetalle)
				lcDireccion = lcDireccion + ", " + alltrim(.ProvinciaDetalle)
			endif
			
			if !empty(.PaisDetalle)
				lcDireccion = lcDireccion + " - " + alltrim(.PaisDetalle)
			endif
			
			if !empty(.Notas)
				lcDireccion = lcDireccion + ", " + alltrim(.Notas)
			endif
			
		endwith
		return lcDireccion

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteConValores() as Boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombresValidadores() as zoocoleccion 
		local loNombreDeValidadores as zoocoleccion OF zoocoleccion.prg
	
		loNombreDeValidadores = dodefault()
	    loNombreDeValidadores.Add( "ValidadorComprobanteSinValores" )
        for i=1 to loNombreDeValidadores.Count 
  			if loNombreDeValidadores.Item(i)= "ValidadorComprobanteConValores"
   				loNombreDeValidadores.Remove(i)
   				exit
   			endif
   		endfor
		return loNombreDeValidadores
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llRetorno as boolean

		llRetorno = dodefault()
		
		llRetorno = llRetorno and this.oValidadores.Validar()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearFiltroBuscadorArticulo( toEntidad as entidad OF entidad.prg ) as Boolean
		return This.oValidadores.VALIDADORCOMPROBANTESINVALORES.EventoSetearFiltroBuscadorArticulo( toEntidad )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoVerificarRestriccionArticulo( toArticulo as entidad OF entidad.prg ) as Boolean
		return This.oValidadores.VALIDADORCOMPROBANTESINVALORES.EventoVerificarRestriccionArticulo( toArticulo )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPedirCotizacion() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function IngreseCotizacion() as String
		return this.EventoPedirCotizacion()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaCotizacion() as Date
		local ldFechaUltCotizacion as Date
		ldFechaUltCotizacion = this.MonedaComprobante.ObtenerFechaUltimaCotizacion( this.Fecha )
		return ldFechaUltCotizacion
	endfunc 
		
enddefine
