Define Class ColaboradorPromociones As ZooSession Of ZooSession.prg

	#If .F.
		Local This As ColaboradorPromociones As ColaboradorPromociones.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function InicializarColaborador() as Void
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionPromocionesBancariasEspecificas( tdVigencia as Date, tlHayCuotasSinRecargo as Boolean, tlSoloConCuotasSinRecargo as Boolean ) as Collection
		Return null
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AgregarComprobanteParaEvaluacion( toComprobante as Object ) as Void
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerPromocionEvaluada( toEntidad as Object, toPromociones as Collection ) as Object
		Return null
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerTopeDeCuotasConRecargo( tcCodigo as String ) as Integer
		Return 0
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerCodigoDePromocionSugerida( toEntidad as Object, toPromociones as Collection ) as String
		Return ""
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionPromocionesBancariasPriorizadas( tdVigencia as Date, tlHayCuotasSinRecargo as Boolean, tlSoloConCuotasSinRecargo as Boolean ) as Collection
		Return null
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function debeEvaluarPromocionesBancarias( tdFecha as Date ) as Boolean
		Return .f.
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EstaConfiguradoParaPromocionesBancarias() as Boolean
		Return .f.
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function existenPromocionesBancariasVigentesConCuotasSinRecargo( tdFechaComprobante as Date ) as Boolean
		Return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function existenPromocionesBancariasVigentes( tdFechaComprobante as Date ) as Boolean
		Return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ExistenCuotasSinRecargo() as Boolean
		Return .f.
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Function EsPromocionBancariaConCuotas( tcPromocion as String ) as Boolean
		Return .f.
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Function ImplementaPromociones() as Boolean
		Return .f.
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function HayPromocionesAutomaticasVigentes( tdFecha as Date ) as Boolean
		return .F.
	endfunc 

EndDefine

*-----------------------------------------------------------------------------------------
Define Class PromocionBancaria As Custom

	Codigo = ""
	Detalle = ""
	Esquema = ""
	CuotasSinRecargo = 0

EndDefine
