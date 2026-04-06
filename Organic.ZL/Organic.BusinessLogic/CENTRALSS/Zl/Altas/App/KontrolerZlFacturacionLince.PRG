define class KontrolerZlFacturacionLince as din_KontrolerZlFacturacionLince of din_KontrolerZlFacturacionLince.prg

	*-----------------------------------------------------------------------------------------
	function Validar() as Void
		local loControl as Object,llRetorno as Boolean

		llRetorno = .t.

		loControl = this.obtenerControl( "AccRealiz" )
		if !empty( loControl.Value )
			goMensajes.Advertir( "Los comprobantes ya se encuentran emitidos, deberá generar un nuevo registro." )
			llRetorno = .f.
		endif

		if llRetorno
			lcTexto = "Verifique que lo datos para la facturación sean correctos" + chr( 13 )
			loControl = this.ObtenerControl( "Fechafacturacion" )
			lcTexto = lcTexto + "Fecha Facturación: " + transform( loControl.Value )+ chr( 13 )
			loControl = this.ObtenerControl( "RutaLince" )
			lcTexto = lcTexto + "Ruta Lince: " + transform( loControl.Value )
			loControl = this.ObtenerControl( "RutaPlanillaXLS" )
			lcTexto = lcTexto + "Archivo XLS: " + transform( loControl.Value )+ chr( 13 )
			lcTexto = lcTexto + "¿Desea continuar?"
			llRetorno =	goMensajes.Preguntar( lcTexto, 4, 1 ) = 6
		endif

		return llRetorno
	endfunc

enddefine