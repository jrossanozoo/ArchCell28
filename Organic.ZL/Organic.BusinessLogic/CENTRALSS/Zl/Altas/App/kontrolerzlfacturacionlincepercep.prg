Define Class KontrolerZlFacturacionLincePercep As din_KontrolerZlFacturacionLincePercep Of din_KontrolerZlFacturacionLincePercep.prg

	*-----------------------------------------------------------------------------------------
	function Validar() as Void
		local loControl as Object,llRetorno as Boolean
		
		llRetorno = .t.
		
		loControl = this.obtenerControl( "AccRealiz" )
		if !empty(loControl.Value)
			goMensajes.advertir("Los comprobantes ya se encuentran emitidos, deberá generar un nuevo registro.")
			llRetorno = .f.
		endif
		
		if llRetorno		
			lcTexto = "Verifique que lo datos para la facturación sean correctos" + chr(13)
			loControl = this.obtenerControl( "Fechafacturacion" )
			lcTexto = lcTexto + "Fecha Facturación: " + transform(loControl.Value)+ chr(13)
			loControl = this.obtenerControl( "RutaLince" )
			lcTexto = lcTexto + "Ruta Lince: " + transform(loControl.Value)
			loControl = this.obtenerControl( "RutaPlanillaXLS" )
			lcTexto = lcTexto + "Archivo XLS: " + transform(loControl.Value)+ chr(13)
			lcTexto = lcTexto + "¿Desea continuar?"
			llRetorno =	goMensajes.Preguntar( lcTexto, 4 , 1 ) = 6
		endif
		
		return llRetorno

	endfunc 
	
Enddefine
