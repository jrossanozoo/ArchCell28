define class ValidadorAceptacionDeValores as ValidadorDeEntidad of ValidadorDeEntidad.prg

	#IF .f.
		Local this as ValidadorAceptacionDeValores of ValidadorAceptacionDeValores.prg
	#ENDIF

	oArgumentosComprobante = null
	oCupon = null
	oValidadorAdapterNet = null

	*-----------------------------------------------------------------------------------------
	function oValidadorAdapterNet_Access() as Variant
		if !this.lDestroy and ( !vartype( this.oValidadorAdapterNet ) = 'O' or isnull( this.oValidadorAdapterNet ) )
			this.oValidadorAdapterNet = _screen.zoo.crearobjeto( "AdapterValidadorAceptacionDeValores" )
			this.enlazar( 'oValidadorAdapterNet.EventoObtenerInformacion', 'inyectarInformacion' )
		endif
		return this.oValidadorAdapterNet
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerValores()	as zoocoleccion 
		local loColValores as zoocoleccion OF zoocoleccion.prg
		
		loColValores = _screen.zoo.crearobjeto( "zoocoleccion" )
		for each loItem in this.oEntidad.ValoresDetalle
			if !empty( loItem.Valor_pk )
				if Empty( loItem.Cuotas ) and !Empty( loItem.Cupon_pk )
					try
						This.oCupon.Codigo = loItem.Cupon_pk
						loItem.Cuotas = This.oCupon.Cuotas
					catch to loError
					endtry
				endif	
				loColValores.Add( loItem )
			endif
		endfor
		
		return loColValores
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		local loArgumentos as Object, llRetorno as Boolean, resultado as Object, loValores as zoocoleccion OF zoocoleccion.prg

		llRetorno = .t.
		if ( "FACTURA" $ upper( alltrim ( This.oEntidad.ObtenerNombre() ) ) ) or ( "DEBITO" $ upper( alltrim ( This.oEntidad.ObtenerNombre() ) ) )
			This.CompletarArgumentosComprobante()
			loValores = This.ObtenerValores()
			llRetorno = This.oValidadorAdapterNet.Validar( this.oArgumentosComprobante, loValores )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oArgumentosComprobante_Access() as Variant
		if !this.lDestroy and ( !vartype( this.oArgumentosComprobante ) = 'O' or isnull( this.oArgumentosComprobante ) )
			this.oArgumentosComprobante = this.oValidadorAdapterNet.oArgumentos
		endif
		return this.oArgumentosComprobante
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oCupon_Access() as Variant
		if !this.lDestroy and ( !vartype( this.oCupon ) = 'O' or isnull( this.oCupon ) )
			this.oCupon = _screen.zoo.Instanciarentidad( 'Cupon' )
		endif
		return this.oCupon
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompletarArgumentosComprobante() as Void

		with this.oArgumentosComprobante
			.CantidadArticulos 		= this.oEntidad.FacturaDetalle.Sum_Cantidad		
			.MontoDescuentos 		= this.oEntidad.montoDescuento3
			.PorcentajeDescuentos 	= this.oEntidad.PorcentajeDescuento
			.MontoRecargos 			= this.oEntidad.RecargoMonto2       
			.PorcentajeRecargos 	= this.oEntidad.RecargoPorcentaje
			.Sucursal 				= goParametros.Nucleo.Sucursal
			.ListaDePrecios 		= this.oEntidad.ListaDePrecios_pk
			if empty( this.oEntidad.Fecha )
				.FechaComprobante 		= this.ObtenerFechaYHora( date() )
			else
				.FechaComprobante 		= this.ObtenerFechaYHora( this.oEntidad.Fecha )
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerFechaYHora( ldFecha ) as Void
		local lnAno as Integer, lnMes as Integer, lnDia as Integer, lnHoras as Integer, lnMinutos as integer, ldRetorno as datetime
		lnAno = year( ldFecha )
		lnMes = month( ldFecha )
		lnDia = day( ldFecha )
		if this.oEntidad.lEdicion
			lnHoras = val(left( this.oEntidad.HoraModificacionFW, 2 ) )
			lnMinutos = val( substr( this.oEntidad.HoraModificacionFW, 4, 2 ) )		
		else
			lnHoras = val(left( golibrerias.obtenerhora(), 2 ))	
			lnMinutos = val(substr( golibrerias.obtenerhora(), 4, 2 ) )	
		endif
		ldRetorno = datetime( lnAno, lnMes, lnDia, lnHoras, lnMinutos, 00 )
		return ldRetorno 
	endfunc 

enddefine

