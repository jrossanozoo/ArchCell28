*-----------------------------------------------------------------------------------------
Define Class ColaboradorImpuestos As ZooSession Of ZooSession.prg

	#If .F.
		Local This As ColaboradorImpuestos As ColaboradorImpuestos.prg
	#Endif
	#Define Precision 8
	#Define PrecisionMonto 4

	oComprobante = Null

	*-----------------------------------------------------------------------------------------
	Function InyectarComprobante( toComprobante As ent_comprobante Of ent_comprobante.prg ) As Void
		If Vartype( toComprobante ) = "O"
			This.oComprobante = toComprobante
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerMontoBaseRecargoFinanciero( toComprobante As Object, tnMontoTotal As Decimal ) As Decimal
		Local lnRetorno As Decimal, lnCoeficiente As Decimal
		lnRetorno = 0
		lnCoeficiente = This.CalcularCoeficienteDeImpuestos( toComprobante )
		If lnCoeficiente # 0
			lnRetorno = goLibrerias.RedondearSegunPrecision(tnMontoTotal / lnCoeficiente, PrecisionMonto)
		Endif
		Return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function CalcularCoeficienteDeImpuestos( toComprobante As Object ) As Decimal
		Local lnRetorno As Integer, loItem as Object, loItemBase as Object
		lnRetorno = 0.00
		If This.EsComprobanteDeVentasConImpuestos( toComprobante )

			lnPorcentaje = 0
			loColImpuestos = toComprobante.ImpuestosComprobante
			For Each loItem In loColImpuestos FoxObject
				if (loItem.Monto > 0)
					lnPorcentaje = lnPorcentaje + loItem.Porcentaje
				endif
			next
			lnRetorno = goLibrerias.RedondearSegunPrecision( ((100 + lnPorcentaje + toComprobante.IvaDelSistema )/100),Precision)
		Endif
		Return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSumaDePorcentajesDeImpuestos( toComprobante as Object ) as float
		local lnPorcentaje as float, loColImpuestos as Object
		lnPorcentaje = 0.00
		If This.EsComprobanteDeVentasConImpuestos( toComprobante )
			loColImpuestos = toComprobante.ImpuestosComprobante
			For Each loItem In loColImpuestos FoxObject
				if (loItem.Monto > 0)
					lnPorcentaje = lnPorcentaje + (loItem.Porcentaje/100)
				endif
			next
		endif
		return lnPorcentaje 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function EsComprobanteDeVentasConImpuestos( toComprobante As Object ) As Boolean
		If Aclass( laHerencia, toComprobante ) > 0
			llRetorno = ( Ascan( laHerencia, "ENT_COMPROBANTEDEVENTAS" ) > 0  And Vartype(toComprobante.ImpuestosDetalle) = "O" And !Isnull(toComprobante.ImpuestosDetalle))
		Else
			llRetorno = .F.
		Endif
		Return llRetorno
	Endfunc

Enddefine