define class Dominios as zooSession of zooSession.prg

	#IF .f.
		Local this as Dominios of Dominios.prg
	#ENDIF

	datasession = 1
	oParserMails = null	
	oValidadorMail = null
	oValidacionesBloque = null
	oColaboradorGestionVendedor = null
	oColaboradorValidacionMail = null
	
	*-----------------------------------------------------------------------------------------
	function oValidacionesBloque_Access() as variant
		if !this.ldestroy and ( !vartype( this.oValidacionesBloque ) = 'O' or isnull( this.oValidacionesBloque ) )
			this.oValidacionesBloque = _screen.zoo.crearobjeto( "DominiosHelperValidacionesBloque" )
		endif
		return this.oValidacionesBloque 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorGestionVendedor_Access() as variant
		if !this.ldestroy and ( !vartype( this.oColaboradorGestionVendedor ) = 'O' or isnull( this.oColaboradorGestionVendedor ) )
			this.oColaboradorGestionVendedor = _screen.zoo.crearobjeto( "ColaboradorGestionVendedor" )
		endif
		return this.oColaboradorGestionVendedor 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorValidacionMail_Access() as variant
		if !this.ldestroy and ( !vartype( this.oColaboradorValidacionMail ) = 'O' or isnull( this.oColaboradorValidacionMail ) )
			this.oColaboradorValidacionMail = _screen.zoo.crearobjeto( "ColaboradorValidacionMail" )
		endif
		return this.oColaboradorValidacionMail 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarDominio_Mail( tcMail as string ) as Boolean
		return this.oColaboradorValidacionMail.ValidarMail(tcMail, this)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarDominio_MailAtributo( tcMail as string ) as Boolean
		local llRetorno as Boolean, lcMailAValidar as String, lcMailAValidar as String ;
		 lcMailErroneo as String, llValidacionMail as Boolean
		
		llRetorno = .t.
		lcMailErroneo = ""
		llValidacionMail = .t.

		loColeccionMails = this.oParserMails.Parsear( tcMail, "|")
		for each lcMailAValidar in loColeccionMails 
			llValidacionMail = this.oValidadorMail.Validar( lcMailAValidar )
			if !llValidacionMail
				if This.EsAtributo( lcMailAValidar )
					llValidacionMail = .t.
				else
					lcMailErroneo = lcMailErroneo + alltrim( lcMailAValidar ) + ", "
				endif
			endif
			llRetorno = llRetorno and llValidacionMail
		endfor
		
		if llRetorno
		else
			lcMailErroneo = left( lcMailErroneo , len( alltrim( lcMailErroneo ) ) - 1 )
			This.AgregarInformacion( "Formato de Email inválido para: " + lcMailErroneo )
		EndIf	
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsAtributo( lcCadena as String ) as boolean
		
		return ( left( lcCadena, 1 ) = "." )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oParserMails_Access() as Variant
		
		if !this.ldestroy and ( !vartype( this.oParser ) = 'O' or isnull( this.oParser ) )
			This.oParserMails = _screen.zoo.crearobjeto( "ParserMails" )
		endif
		
		return this.oParserMails		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function oValidadorMail_Access() as Variant
		if !this.ldestroy and ( !vartype( this.oValidadorMail ) = 'O' or isnull( this.oValidadorMail ) )
			This.oValidadorMail = _screen.zoo.crearobjeto( "ValidadorMail" )
		endif
		
		return this.oValidadorMail
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_FechaComprobanteDeCompra( tdFecha as Date ) as Void
		return this.ValidarRangoDeFechasDeComprobanteDeCompras( tdFecha )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ValidarDominio_FechaComprobante( tdFecha as Date ) as Boolean
		return This.ValidarRangoDeFechas( tdFecha )	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_FechaSaldo( tdFecha as Variant ) as Boolean
		return This.ValidarRangoDeFechas( tdFecha )
	endfunc 
	
		*-----------------------------------------------------------------------------------------
	protected function ValidarRangoDeFechasDeComprobanteDeCompras( tdFecha as Variant ) as Boolean
		local llRetorno as Boolean, LdFechaDesde as Date
		
		llRetorno = .t.
		LdFechaDesde = goParametros.Felino.Fechas.desdefechadecomprobantesdecompra
		
		if empty( ldFechaDesde )
			llRetorno = this.ValidarRangoDeFechas( tdFecha )
		else
			if LdFechaDesde > tdFecha
				This.AgregarInformacion( "La fecha del Comprobante no se encuentra dentro del rango permitido." )
				llRetorno = .f.
			endif
		endif
		return llRetorno 
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	Protected function ValidarRangoDeFechas( tdFecha as Variant ) as Boolean
		Local	lnMesesAntes As Integer, lnMesesDespues As Integer, ldFechaDesde As Date, ldFechaHasta as Date, ;
				ldValor As Date, lcObjeto as string, lcString1 as String, llRetorno as Boolean
		
		llRetorno = .t.
		ldValor = tdFecha

		Store 0 To lnMesesAntes, lnMesesDespues
		Store Date( 1900, 1, 1 ) To ldFechaDesde, ldFechaHasta

		lcObjeto = 'goParametros.Felino.Fechas'
		lcString1 = 'goParametros.Felino'

		do case 
			case vartype( tdFecha ) == 'N'
				llRetorno = .T.
			case vartype( &lcString1 ) <> 'O'
				llRetorno = .T.
			case vartype( &lcObjeto ) <> 'O'
				llRetorno = .T.
			case !pemstatus( &lcObjeto,'DesdeFecha', 5 )
				llRetorno = .T.
			case !pemstatus( &lcObjeto,'HastaFecha', 5 )
				llRetorno = .T.
			case !pemstatus( &lcObjeto,'DesdeMes', 5 )
				llRetorno = .T.
			case !pemstatus( &lcObjeto,'HastaMes', 5 )
				llRetorno = .T.
			case empty( tdFecha )
				llRetorno = .T.
			otherwise

				ldFechaDesde   = goParametros.Felino.Fechas.DesdeFecha
				ldFechaHasta   = goParametros.Felino.Fechas.HastaFecha
				lnMesesAntes   = goParametros.Felino.Fechas.DesdeMes
				lnMesesDespues = goParametros.Felino.Fechas.HastaMes

				With This
					Do Case
						Case  Empty( ldFechaDesde ) and Empty( ldFechaHasta ) and Empty( lnMesesAntes ) and Empty( lnMesesDespues )
							If ( ldValor < Date( )-( Day( Date( ) ) - 1 ) ) Or ( ldValor > Gomonth( Date( ), 1 ) - Day( Gomonth( Date( ), 1 ) ) )
								llRetorno = .F.
							endif

						Case Empty( lnMesesAntes ) And Empty( lnMesesDespues )
							If ldValor < ldFechaDesde Or ldValor > ldFechaHasta
								llRetorno = .F.
							Endif

						Case Empty( ldFechaDesde ) And Empty( ldFechaHasta )
							Do Case
								Case Empty( lnMesesAntes )
									If ldValor > Gomonth( Date( ), lnMesesDespues ) Or ldValor < Date( ) - ( Day( Date( ) ) -1 )
										llRetorno = .F.
									Endif

								Case Empty( lnMesesDespues )
									If ldValor < Gomonth( Date( ), -lnMesesAntes ) Or ldValor > Gomonth( Date( ), 1 ) - Day( Gomonth( Date( ), 1 ) )
										llRetorno = .F.
									Endif

								Otherwise
									If	ldValor < Gomonth( Date( ),-lnMesesAntes ) Or ldValor > Gomonth( Date( ), lnMesesDespues )
										llRetorno = .F.
									Endif
							Endcase

						Otherwise
							If 	( ldValor < ldFechaDesde   and !Empty( ldFechaDesde ) )						 Or ;
								( ldValor > ldFechaHasta   and !Empty( ldFechaHasta ) )						 Or ;
								( !Empty( lnMesesAntes )   and ldValor < Gomonth( Date( ), -lnMesesAntes ) ) Or ;
								( !Empty( lnMesesDespues ) and ldValor > Gomonth( Date( ), lnMesesDespues ) )

								llRetorno = .F.
							endif
					Endcase
				endwith
		endcase

		if llRetorno
		else
			This.AgregarInformacion( "La fecha del Comprobante no se encuentra dentro del rango permitido." )
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_PrecioNoNegativo( txVal ) as Boolean
		local loEx as Exception, llRetorno as Boolean

		llRetorno = .t.
		if txVal < 0
			llRetorno = .f.
			This.AgregarInformacion( "EL precio del articulo no puede ser negativo." )	
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_PrecioNoNegativoParametroFoco( txVal ) as Boolean
		return this.ValidarDominio_PrecioNoNegativo( txVal )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_NumericoNoNegativo( txVal ) as Boolean
		local loEx as Exception, llRetorno as Boolean

		llRetorno = .t.
		if txVal < 0
			llRetorno = .f.
			This.AgregarInformacion( "El valor no puede ser negativo." )	
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_CampoNumericoNoNegativo( txVal ) as Boolean
		local loEx as Exception, llRetorno as Boolean

		llRetorno = .t.
		if txVal < 0
			llRetorno = .f.
			This.AgregarInformacion( "El valor no puede ser negativo." )	
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_Talle( tcTalle as string ) as Boolean
		local llRetorno as Boolean, lnValor as Integer, lnbucle as Integer, lcCaracter as Character

		lnBucle = 1		
		llRetorno = .t.
		lcCaracteresValidos = goLibrerias.ObtenerCaracteresValidos( .f. )
		
		if Empty( tcTalle )
		else
			do while lnBucle <= len( tcTalle ) and llRetorno
				lcCaracter = substr( tcTalle, lnbucle, 1 )
				lnValor = occurs( lcCaracter, lcCaracteresValidos )
				
				if lnValor > 0 
				else
					lcPosicion = alltrim( str( lnbucle, len( alltrim( str( lnbucle ) ) ) ) )
					llRetorno = .f.
					This.AgregarInformacion( "'" + lcCaracter + "'" + " Caracter no válido. ( Posición Nro. " + lcPosicion + " )." )
				EndIf	
				lnBucle = lnBucle + 1 
			enddo
		EndIf	
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCaracter(tcCaracter as Character, tlPermiteCaracterEspecial as Boolean ) as Boolean
		local llRetorno as Boolean, lcCaracteres as string
		
		llRetorno = .F.
		lcCaracteres = goLibrerias.ObtenerCaracteresValidos( this.oEntidad.lPermiteMinusculasPK )

		if tlPermiteCaracterEspecial 
			lcCaracteres = lcCaracteres + "+?"
		endif

		llRetorno = ( occurs( tcCaracter, lcCaracteres ) > 0 )

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarDominio_MesAnio( tcMesAnio as string ) as Boolean
		local llRetorno as Boolean, lcMes as String, lcAnio as String
		llRetorno = .t.
		lcMes = ""
		lcAnio = ""

		if !empty( tcMesAnio )
			lcMes = alltrim( substr( tcMesAnio, 1, 2 ) )
			lcAnio = alltrim( substr( tcMesAnio, 3, 2 ) )
			if empty( lcMes ) or empty( lcAnio ) or empty( ctod( "01/" + lcMes + "/" + lcAnio ) )
				llRetorno = .f.
				This.AgregarInformacion( "Mes/Año inválido." )
			endif
		endif

		return llRetorno

	endfunc


	*-----------------------------------------------------------------------------------------
	function ValidarMinimofecha( txVal ) as Boolean
		local loEx as Exception, llRetorno as Boolean

		llRetorno = .t.
		if !empty( txVal ) and vartype( txVal )== "D" and txVal < date( 1753, 1 , 1 )
			llRetorno = .f.
			This.AgregarInformacion( "Fecha inválida." )	
		endif
		return llRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarDominio_FechaCalendario( txVal ) as Boolean
		return this.ValidarMinimofecha( txVal ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_Fecha( txVal ) as Boolean
		return this.ValidarMinimofecha( txVal ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_FechaLargaCalendario( txVal ) as Boolean
		return this.ValidarMinimofecha( txVal ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominio_ImpuestoInterno( txVal ) as Boolean
		return this.ValidarDominio_NumericoNoNegativo( txVal ) 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarDominio_CODIGOVENDEDOR( txVal, toEntidad ) as Boolean
		local llEsCodigoVendedorValido as Boolean,lcMensajeError as String
		llEsCodigoVendedorValido = .t. 
		if !Empty( txVal ) and goParametros.felino.generales.utilizaAsignacionDeVendedorABaseDeDatos
			llEsCodigoVendedorValido = this.oColaboradorGestionVendedor.validarVendedor(txVal,toEntidad)
		endif
		
		if !llEsCodigoVendedorValido 
			lcMensajeError = "El vendedor "+ alltrim(txVal) +" no está habilitado para operar en la sucursal o base de datos."
			This.AgregarInformacion(lcMensajeError)
		endif
			
		return llEsCodigoVendedorValido 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_Fecha( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_Fecha( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_Mail( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_Mail( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_MailAtributo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_MailAtributo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_FechaComprobante( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_FechaComprobante( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_PrecioNoNegativo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_PrecioNoNegativo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_PrecioNoNegativoParametroFoco( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_PrecioNoNegativoParametroFoco( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_NumericoNoNegativo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_NumericoNoNegativo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_CampoNumericoNoNegativo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_CampoNumericoNoNegativo( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_Talle( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_Talle( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_MesAnio( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_MesAnio( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_FechaCalendario( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_FechaCalendario( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_FechaLargaCalendario( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_FechaLargaCalendario( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDominioBloqueImportacion_ImpuestoInterno( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion ) as Void
		this.oValidacionesBloque.ValidarDominio_ImpuestoInterno( tcEsquemaTabla, tcEsquemaTablaErroresValidacion, tcCampo, toConexion )
	endfunc 

enddefine