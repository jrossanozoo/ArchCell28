Define Class ent_Moneda as din_EntidadMoneda of din_EntidadMoneda.prg 

	#IF .f.
		Local this as ent_Moneda of ent_Moneda.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	Function ObtenerCotizacion( tdFecha as Date, tcMonedaValor as String, tcMonedaComprobante as String ) as number
		Local lcXml as string, lnRetorno as integer, lcCursor as string, ldFechaAux as date, lcFecha as String, ;
				lcCodigoMonedaSugerida as String, lcHora as String

		lnRetorno = 0
		lcCodigoMonedaSugerida = goparametros.Felino.Generales.MonedaSistema
		if pcount() = 1
			tcMonedaValor = This.Codigo
			tcMonedaComprobante = lcCodigoMonedaSugerida
		Endif	
			
		if tcMonedaValor = tcMonedaComprobante
			lnRetorno = 1
		else
			if type( 'tcMonedaValor' ) # "C"
				tcMonedaValor = ''
			endif
			lcCursor = sys( 2015 )

			lcFecha = "'" + dtos( tdFecha ) + "'"
			
			if tcMonedaValor = lcCodigoMonedaSugerida and ;
				tcMonedaComprobante # lcCodigoMonedaSugerida
				tcMonedaValor = tcMonedaComprobante
				tcMonedaComprobante = lcCodigoMonedaSugerida
			endif

			lcHora = this.ObtenerHoraDeCotizacion( tdFecha )
								
			lcXml = this.oAD.ObtenerDatosDetalleCotizaciones( "COTIZACION", ;
								"upper( alltrim( CODIGO ) ) == '" + alltrim( upper( tcMonedaValor ) ) + "' and " + ;
								"FECHA = " + lcFecha + " and replace(HORA,':','') <= '" + lcHora + "'", "FECHA ASC, HORA ASC" )

			this.Xmlacursor( lcXml, lcCursor )
			if Reccount( lcCursor ) # 0
				Go Bottom in &lcCursor
				lnRetorno = &lcCursor..Cotizacion
			endif

			Use In Select( lcCursor )
			
		endif	
		Return lnRetorno	
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerFechaUltimaCotizacion( tdFecha as Date, tcMoneda as string ) as Float
		Local lcXml as string, ldReturn as Date, lcCursor as string,;
		llExit as Boolean

		ldReturn = {//}
		llExit = .F.
		lcCursor = sys( 2015 )
		lcMoneda = iif( Vartype( 'tcMoneda' ) = "C" and !Empty( tcMoneda ), tcMoneda, This.Codigo )
		lcXml = this.oAD.ObtenerDatosDetalleCotizaciones( "FECHA"," upper( alltrim( CODIGO ) ) == '" +;
				alltrim( upper( lcMoneda ) ) + "' ","FECHA, HORA ASC", .F., .F. )
		this.Xmlacursor( lcXml, lcCursor )
		
		if Reccount( lcCursor ) > 0
			Select( lcCursor )
			Index on Fecha tag Fecha
			Set Order to Fecha Descending
			Scan For !llExit
				if vartype( tdFecha ) = "D" and tdFecha < goServicios.Librerias.ObtenerFechaFormateada( &lcCursor..Fecha )
				else
					ldReturn = goServicios.Librerias.ObtenerFechaFormateada( &lcCursor..Fecha )
					llExit = .T.
				endif
			Endscan
			use in select( lcCursor )
		endif
		
		Return ldReturn
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerCotizacionMoneda( tcMoneda as String, tdFecha as Date ) as float
		Local loMoneda as Object, lnCotizacion as float
	
		lnCotizacion = 0
		Do Case
		Case Empty( tcMoneda )
			goServicios.Errores.LevantarExcepcion( "No se puede obtener la cotización sin una moneda." )
		Case !this.oAd.verificarexistenciaclaveprimaria(tcMoneda)
			goServicios.Errores.LevantarExcepcion( "El dato buscado "+Alltrim(tcMoneda)+" de la entidad MONEDA no existe." )
		Endcase
		
		lnCotizacion = this.ObtenerCotizacionEfectiva(tdFecha, tcMoneda)
		if lnCotizacion = 0
			lnCotizacion = Iif( Empty( goRegistry.Felino.CotizacionPorDefault ), 1, goRegistry.Felino.CotizacionPorDefault )
		endif 
		
	Return lnCotizacion

	*-----------------------------------------------------------------------------------------
	Function ConvertirImporteBase( tnImporte as float, tcMonedaOrig as String, tcMonedaDest as string, tdFecha as Date  ) as float
		Local lnCotizacionOrigen as float, lnCotizacionDestino as float, lnRetorno as float 

		lnRetorno = 0
		lnCotizacionOrigen = 1
		lnCotizacionDestino = 1
		If tnImporte # 0
			If tcMonedaOrig == tcMonedaDest
			Else
				lnCotizacionDestino = this.ObtenerCotizacionMoneda( tcMonedaDest, tdFecha )
				If lnCotizacionDestino > 0
					lnCotizacionOrigen = this.ObtenerCotizacionMoneda( tcMonedaOrig, tdFecha )
				Endif
			Endif
		Endif
	
		lnRetorno = ( tnImporte * lnCotizacionOrigen ) / lnCotizacionDestino
		
		Return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ConvertirImporte( tnImporte as float, tcMonedaOrig as String, tcMonedaDest as string, tdFecha as Date  ) as float
		Local lnCotizacionOrigen as float, lnCotizacionDestino as float, lnRetorno as float 
	
		lnRetorno = this.ConvertirImporteBase( tnImporte, tcMonedaOrig, tcMonedaDest, tdFecha )
		lnRetorno = goLibrerias.RedondearSegunMascara( lnRetorno )		
		
		Return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ConvertirImporteConRedondeo( tnImporte as float, tcMonedaOrig as String, tcMonedaDest as string, tdFecha as Date, tnRedondeo as Integer ) as float
		Local lnCotizacionOrigen as float, lnCotizacionDestino as float, lnRetorno as float 

		lnRetorno = this.ConvertirImporteBase( tnImporte, tcMonedaOrig, tcMonedaDest, tdFecha )
		lnRetorno = goLibrerias.RedondearSegunPrecision( lnRetorno, tnRedondeo )
		
		Return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerCotizacionVigente( tdFecha as Date, tcMonedaValor as String, tcMonedaComprobante as String ) as number
		Local lcXml as string, lnRetorno as integer, ldFechaAux as date, lcFecha as String, ;
				lcMonedaValor as String, lcMonedaBase as String

		lcMonedaValor = iif(type('tcMonedaValor')="C" and !empty(tcMonedaValor),tcMonedaValor,This.Codigo)
		lcMonedaBase = iif(type('tcMonedaComprobante')="C" and !empty(tcMonedaComprobante),tcMonedaComprobante,goParametros.Felino.Generales.MonedaSistema)
		ldFechaAux = iif(type('tdFecha')="D",tdFecha,date())

		if alltrim(lcMonedaValor) = alltrim(lcMonedaBase)
			lnRetorno = 1
		else

			lcFecha = "'" + dtos( ldFechaAux ) + "'"
			if lcMonedaBase = goParametros.Felino.Generales.MonedaSistema
				lnRetorno = this.ObtenerCotizacionEspecifica( lcMonedaValor, lcFecha )
			else
				lnRetorno = this.ObtenerCotizacionEspecifica( lcMonedaValor, lcFecha ) / this.ObtenerCotizacionEspecifica( lcMonedaBase, lcFecha )
			endif
			
		endif	
		Return lnRetorno	
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerSimboloDeMoneda() as String
		Return this.Simbolo 
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerCotizacionEspecifica( tcMonedaValor as String, tcFecha as String ) as Float
		Local lcCursor as String, lcXml as String, lcCursorAux as String, lcHora as String, lnRetorno as Float

		lnRetorno = 0
		lcCursor = sys( 2015 )
		lcCursorAux = sys( 2015 )
		lcHora = alltrim( str( hour( golibrerias.ObtenerFechaHora() ) ) ) + right( '00' + alltrim( str( minute( golibrerias.ObtenerFechaHora() ) ) ), 2 )

		lcXml = this.oAD.ObtenerDatosDetalleCotizaciones( "COTIZACION, FECHA, HORA", ;
							"upper( alltrim( CODIGO ) ) == '" + alltrim( upper( tcMonedaValor ) ) + "' and " + ;
							"FECHA <= " + tcFecha, "FECHA,HORA ASC" )

		this.Xmlacursor( lcXml, lcCursorAux )
		
		Select * From &lcCursorAux ;
			Where ( Val( Strtran( HORA, ":", "" ) ) <= Val( lcHora ) and "'" + Dtos( FECHA ) + "'" = tcFecha ) Order By FECHA asc, HORA asc;
		Into Cursor &lcCursor
		
		if Reccount( lcCursor ) = 0
			Use In Select( lcCursor )
			Select * From &lcCursorAux Where "'" + Dtos( FECHA ) + "'" < tcFecha Order By FECHA Asc, HORA Asc Into Cursor &lcCursor
		endif

		if Reccount( lcCursor ) # 0
			go bottom in &lcCursor
			lnRetorno = &lcCursor..Cotizacion
		endif

		Use In Select( lcCursor )
		Use In Select( lcCursorAux ) 

		Return lnRetorno
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerHoraDeCotizacion( tdFecha ) as Void
		Local lcRetorno as String 

		if tdfecha < date() 
			lcRetorno = '2359'
		else
			lcRetorno = right( '00' + alltrim( str( hour( golibrerias.ObtenerFechaHora() ) ) ), 2 ) + right( '00' + alltrim( str( minute( golibrerias.ObtenerFechaHora() ) ) ), 2 )
		endif
		
		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerItemUltimaCotizacion() as ItemAuxiliar of Din_DetalleMONEDACotizaciones.prg
		return this.cotizaciones.ObtenerItemUltimaCotizacion()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerCotizacionEfectiva( tdFecha as Date, tcMonedaValor as String, tcMonedaComprobante as String ) as Float
		Local lcXml as String, lnRetorno as Integer, lcCursor as String, ldFechaAux as Date, lcFecha as String, ;
				lcMonedaComprobante as String, lcMonedaValor as String, lcHora as String, lcMonedaBase as String, ;
				lcSentencia as String, lnCoeficiente as Number

		lnRetorno = 0

		lcMonedaBase = goParametros.Felino.Generales.MonedaSistema
		lcMonedaValor = Iif(Vartype('tcMonedaValor')="C" and !Empty(tcMonedaValor),tcMonedaValor,This.Codigo)
		lcMonedaComprobante = Iif(Vartype('tcMonedaComprobante')="C" and !Empty(tcMonedaComprobante),tcMonedaComprobante,goParametros.Felino.Generales.MonedaSistema)
		lcFecha = "'" + dtos( tdFecha ) + "'"
		lcFechaUltimaCotizacion = this.ObtenerFechaUltimaCotizacion( tdFecha, lcMonedaValor )
		lcHora = this.ObtenerHoraDeCotizacion( lcFechaUltimaCotizacion )

		Do Case
		Case lcMonedaValor = lcMonedaComprobante
			lnRetorno = 1
		Case lcMonedaComprobante = lcMonedaBase
			lnCoeficiente = this.ObtenerCotizacionSegunMoneda( lcFecha, lcHora, lcMonedaValor )
			lnRetorno = lnCoeficiente
		Otherwise
			lnCoeficiente = this.ObtenerCotizacionSegunMoneda( lcFecha, lcHora, lcMonedaValor )
			lnRetorno = this.ObtenerCotizacionEspecifica( lcFecha, lcHora, lcMonedaComprobante )
			lnRetorno = Round( lnCoeficiente / lnRetorno, 8)
		Endcase
		Return lnRetorno
	EndFunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCotizacionSegunMoneda( tcFecha as Date, tcHora as String, tcMoneda as String ) as Number
		Local lnRetorno as Number
		lcSentencia = "Select top 1 cotiz from zoologic.cotiza "
		lcSentencia = lcSentencia + " where codigo = '" + Alltrim(tcMoneda) + "' and fecha <= convert(datetime," + tcFecha + ")"
        lcSentencia = lcSentencia + " and replace(HORA,':','') <= '" + tcHora + "'"
		lcSentencia = lcSentencia + " order by fecha desc, hora desc"

		goServicios.Datos.Ejecutarsentencias( lcSentencia, 'cotiza', '', 'cCotiza', this.oAd.DataSessionId )
		If Reccount('cCotiza') = 1
			Go Top In cCotiza
			lnRetorno = cCotiza.cotiz
		Else
			lnRetorno = 0
		Endif
		Use In cCotiza
		Return lnRetorno
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function ValidarEquivalenciaAfip() as boolean
		local llRetorno as boolean
		
		if goParametros.Nucleo.DatosGenerales.Pais = 3
			llRetorno = .t.
		else
			llRetorno = dodefault()
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarDeshabilitarMonedaCotizacionAFIP() as Void
	
		if pemstatus( this, "lHabilitarMonedaCotizacionAFIP_PK", 5 )
			this.lHabilitarMonedaCotizacionAFIP_PK = .f.
			if goParametros.Nucleo.DatosGenerales.Pais = 1 and alltrim( upper( this.codigo ) ) != "PESOS" and ;
					!empty( this.EquivalenciaAfip_PK ) 
				this.lHabilitarMonedaCotizacionAFIP_PK = .t.
			endif
			this.EventoHabilitarDeshabilitarMonedaCotizacionAFIP()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoHabilitarDeshabilitarMonedaCotizacionAFIP() as Void
		* para que se bindee el kontroler
	endfunc 

	*-------------------------------------------------------------------------------------------------
	function Nuevo() as Boolean
		dodefault()
		this.HabilitarDeshabilitarMonedaCotizacionAFIP()
	endfunc
	
	*-------------------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		this.HabilitarDeshabilitarMonedaCotizacionAFIP()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarMontoPositivo() as Boolean
    local llRetorno as Boolean
    llRetorno = .f.
    if vartype(this.Monto) = "N" and this.Monto > 0
        llRetorno = .t.
    endif
    return llRetorno
	endfunc

EndDefine
