define class Ent_Cupon as din_EntidadCupon of din_EntidadCupon.prg

	#IF .f.
		Local this as din_EntidadCupon of din_EntidadCupon.prg
	#ENDIF

	nMontoOriginal = 0
	lInicializado = .f.
	oColaboradorPos = null
	PromocionAplicada = ""
	cCuponAnuladoParticular = ""
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPosDefault() as String
		local llExiste as Boolean, lcCodigo as String

		lcCodigo = goParametros.Felino.GestionDeVentas.Tarjetas.DispositivoPosDefault		
		if !empty(lcCodigo) and !this.Pos.ExistePos( lcCodigo )
			lcCodigo = ""
		endif		
		return lcCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDatosCierreDeLote() as Void
		local lcXml as string, lcCursor as String

		lcCursor = sys(2015)
	
		lcXml = this.obtenerDatosEntidad( "Lote, CodigoCierreDeLote, NumeroCierreDeLote, FechaCierreDeLote, HoraCierreDeLote" , "Codigo='" + this.Codigo + "'" )
		this.Xmlacursor( lcXml, lcCursor )

		select (lcCursor)

		this.CodigoCierreDeLote = &lcCursor..CodigoCierreDeLote
		this.NumeroCierreDeLote = &lcCursor..NumeroCierreDeLote
		this.FechaCierreDeLote = goservicios.librerias.obtenerfechaformateada( &lcCursor..FechaCierreDeLote )
		this.HoraCierreDeLote = &lcCursor..HoraCierreDeLote

		use in select (lcCursor)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneCierreDeLote() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.

		lnCantidad = this.ObtenerCantidadDeRegistrosConFiltro( "Codigo='" + this.Codigo + "' and rtrim( ltrim( CodigoCierreDeLote ) ) <> ''" )
		if lnCantidad > 0
			llRetorno = .t.
		endif
		
		return llRetorno  
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SeCambioMontoOriginal() as boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		if this.EsEdicion()
			llRetorno = this.nMontoOriginal != this.monto
		endif	
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Cargar() as Void
		dodefault()
		this.nMontoOriginal = this.monto
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() AS boolean
		local llRetorno as boolean
		llRetorno = dodefault() and This.ValidarTipoDeCupon()
		if llRetorno and this.Pos.EsDispositivoPoint()
			llRetorno = This.ValidarNumeroDeCupon()
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarTipoDeCupon() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.

		if this.Monto > 0 and this.EsDeTipoConSignoNegativo()
			llRetorno = .f.
			This.AgregarInformacion( "El monto de un cupón de tipo [" + this.TipoCupon + "] debe ser negativo.", 1 )
		endif
		
		if this.Monto < 0 and this.EsDeTipoConSignoPositivo()
			llRetorno = .f.
			This.AgregarInformacion( "El monto de un cupón de tipo [" + this.TipoCupon + "] debe ser positivo.", 1 )
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarNumeroDeCupon() as boolean
		local llRetorno as Boolean 				 
		llRetorno = .t.	
		if empty( this.NumeroCupon )
			llRetorno = .f.	
			this.AgregarInformacion( "El número de cupón no puede quedar vacío." )
		endif 
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsDeTipoCompra( tcTipo as String ) as boolean
		local lcTipo as String
		if pcount() > 0
			lcTipo = tcTipo
		else
			lcTipo = this.TipoCupon
		endif
		return upper( alltrim( lcTipo ) ) == "C"
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsDeTipoAnulacionDeCompra( tcTipo as String ) as boolean
		local lcTipo as String
		if vartype( tcTipo ) # 'C'
			tcTipo = this.TipoCupon
		endif
		return upper( alltrim( tcTipo ) ) == "AC" && upper( alltrim( lcTipo ) ) == "AC"
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsDeTipoDevolucion( tcTipo as String ) as boolean
		local lcTipo as String
		if vartype(tcTipo) # 'C'
			tcTipo = this.TipoCupon
		endif
		return upper( alltrim( tcTipo ) ) == "D" && upper( alltrim( lcTipo ) ) == "D"
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsDeTipoAnulacionDeDevolucion( tcTipo as String ) as boolean
		local lcTipo as String
		if vartype( tcTipo ) # 'C'
			tcTipo = this.TipoCupon
		endif
		return upper( alltrim( tcTipo ) ) == "AD" && upper( alltrim( lcTipo ) ) == "AD"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsDeTipoConSignoPositivo( tcTipo as String ) as boolean
		local lcTipo as String
		if vartype( tcTipo ) # 'C'
			tcTipo = this.TipoCupon
		endif
		return this.EsDeTipoCompra( tcTipo ) or this.EsDeTipoAnulacionDeDevolucion( tcTipo )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsDeTipoConSignoNegativo( tcTipo as String ) as boolean
		local lcTipo as String
		if vartype( tcTipo ) # 'C'
			tcTipo = this.TipoCupon
		endif
		return this.EsDeTipoAnulacionDeCompra( tcTipo ) or this.EsDeTipoDevolucion( tcTipo )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneCanjeDeCupon() as boolean
		return !empty( This.NumeroDeCanje )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDelTipo( tcTipo as String ) as string
		local lcRetorno as String
		
		do case
			case tcTipo = "C"
				lcRetorno = "Compra"
			case tcTipo = "AC"
				lcRetorno = "Anulación compra"
			case tcTipo = "D"
				lcRetorno = "Devolución"
			case tcTipo = "AD"
				lcRetorno = "Anulación devolución"
			otherwise
				lcRetorno = ""
		endcase
	
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function lActualizaRecepcion_Access() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCuponesHuerfanos( tnSigno as Integer, tlIncluirAnulaciones as boolean ) as zoocoleccion OF zoocoleccion.prg 
		local lcHaving as String
		lcHaving =  "alltrim( Comprobante ) = '' and Autorizado = .t. "
		if type( "tnSigno" ) = "N"
			do case
				case tnSigno > 0
					lcHaving = lcHaving + " and ( TipoCupon = 'C' or TipoCupon = 'AC' )"
					lcHaving = lcHaving + iif( tlIncluirAnulaciones, "", "and NumeroDeCuponAfectado = 0" )
				case tnSigno < 0					
					lcHaving = lcHaving + " and ( TipoCupon = 'D' or TipoCupon = 'AD' )"
			endcase
		endif 
		return this.ObtenerColeccionDeCuponesHuerfanos( lcHaving )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCuponesHuerfanosEnDispositivoPos( tcPOS as String ) as zoocoleccion OF zoocoleccion.prg 
		local lcHaving as String
		lcHaving =  "alltrim( Comprobante ) = '' and Autorizado = .t. and NumeroDeCuponAfectado = 0"
		if vartype( tcPOS ) = "C"
			lcHaving = lcHaving + " and POS = '" + tcPOS + "'"
		else
			lcHaving = lcHaving + " and POS = ''"
		endif
		return this.ObtenerColeccionDeCuponesHuerfanos( lcHaving )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCuponesHuerfanosPorCaja( tnCaja as integer, tlIncluirAnulaciones as boolean ) as zoocoleccion of zoocoleccion.prg 
		local lcHaving as string
		lcHaving =  "alltrim( Comprobante ) = '' and Autorizado = .t. and IdCaja = " + alltrim( transform( tnCaja ) )
		lcHaving = lcHaving + iif( tlIncluirAnulaciones, "", " and NumeroDeCuponAfectado = 0" )
		return this.ObtenerColeccionDeCuponesHuerfanos( lcHaving )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionDeCuponesHuerfanos( tcFiltro as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcXml as String, lcCursor as String, loCuponHuerfano as Object
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		lcXml = this.oAd.ObtenerDatosEntidad( "", tcFiltro )
		lcCursor = sys(2015)
		this.XmlaCursor( lcXml, lcCursor )		
		if reccount( lcCursor ) > 0
			scan 
				scatter name loCuponHuerfano
				loRetorno.Agregar( loCuponHuerfano )
			endscan 
		endif		
		use in select( lcCursor )		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsCuponHuerfano( tcCodigoCupon as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if vartype( tcCodigoCupon ) = "C" and !empty( tcCodigoCupon )
			try
				this.Codigo = tcCodigoCupon
				if empty( this.Comprobante )
					llRetorno = .t.
				endif
			catch
			endtry
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarSiElCuponSigueHuerfano( tcCodigoCupon as String ) as Boolean 
		local llRetorno as Boolean, lcHaving as String, lcXml as String, lcCursor as String 	
		lcHaving =  "Codigo = '" + tcCodigoCupon + "'  and ( alltrim( Comprobante ) != '' )"
		lcXml = this.oAd.ObtenerDatosEntidad( "", lcHaving )	
		lcCursor = sys(2015)
		this.XmlaCursor( lcXml, lcCursor )		
		if reccount( lcCursor ) = 0
			llRetorno = .t.
		endif		

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDatosCupon( tcCodigo as String ) as Object 
		local loRetorno as Object, lcHaving as String, lcXml as String, lcCursor as String 
		
		lcHaving =  "alltrim( Codigo ) = '" + tcCodigo + "'"
		lcXml = this.oAd.ObtenerDatosEntidad( "", lcHaving )	
		lcCursor = sys(2015)
		this.XmlaCursor( lcXml, lcCursor )		
		if reccount( lcCursor ) > 0
			scatter name loRetorno
		else
			loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		endif		
		use in select( lcCursor )		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaIntegrado() as Boolean
		local llRetorno as Boolean
		llRetorno = this.AutorizacionPOS
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaAnulado() as Boolean
		local llRetorno as Boolean
		llRetorno = empty( This.NumeroDeCanje ) and !empty(this.FechaBaja)
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeCupones( tnNumeroCupon as Integer, tnMonto as Double, tnCuotas as Integer, tdFecha as Date ) as zooColeccion
		local loColeccion as zoocoleccion OF zoocoleccion.prg, lcFiltro as String, loCupon as Object, lcCursor as String, lcCampos as String, lcXml as String
		loColeccion = _screen.zoo.CrearObjeto( "ZooColeccion" )
		lcFiltro  = ""
		if vartype( tnNumeroCupon ) = "N" and !empty( tnNumeroCupon )
			lcFiltro = lcFiltro + " NumeroCupon = " + alltrim( str(tnNumeroCupon))
		endif
		if vartype( tnMonto ) = "N" and !empty( tnMonto )
			lcFiltro = lcFiltro + iif(empty(lcFiltro),""," and ") + " Monto = " + alltrim( str( abs( tnMonto ), 15, 2 ) )
		endif
		if vartype( tnCuotas ) = "N" and !empty( tnCuotas )
			lcFiltro = lcFiltro + iif(empty(lcFiltro),""," and ") + " Cuotas = " + alltrim( str(tnCuotas))
		endif

		if !empty( lcFiltro )
			lcCursor = "DatosCupon"
			lcCampos = "Codigo, Monto, Cuotas, TipoDocumentoTitular, NroDocumentoTitular, "
			lcCampos = lcCampos + "NombreTitular, TelefonoTitular, EntidadFinanciera, "
			lcCampos = lcCampos + "FechaComprobante, NumeroCupon, FechaCupon, HoraCupon, "
			lcCampos = lcCampos + "NumeroReferencia, CodigoPlan"
			lcXml = this.oAd.ObtenerDatosEntidad( lcCampos, lcFiltro, "FechaCupon DESC, HoraCupon DESC" )
			this.XmlACursor( lcXml, lcCursor )
			scan
				scatter name loCupon
				loColeccion.Agregar( loCupon, datoscupon.Codigo )
			endscan
		endif
		return loColeccion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeCuponesParaAfectar( tnNumeroCupon as Integer, tnMonto as Double, tnCuotas as Integer ) as zooColeccion
		local loColeccion as zoocoleccion OF zoocoleccion.prg, lcFiltro as String, loCupon as Object, lcCursor as String, lcCampos as String, lcXml as String
		loColeccion = _screen.zoo.CrearObjeto( "ZooColeccion" )
		lcFiltro  = " NumeroDeCuponAfectado = 0 and NumeroDeCanje = 0 "
		if vartype( tnNumeroCupon ) = "N" and !empty( tnNumeroCupon )
			lcFiltro = lcFiltro + " and NumeroCupon = " + alltrim( str(tnNumeroCupon,12))
		endif
		if vartype( tnMonto ) = "N" and !empty( tnMonto )
			lcFiltro = lcFiltro + " and Monto = " + alltrim( str( abs( tnMonto ), 15, 2 ) )
		endif
		if vartype( tnCuotas ) = "N" and !empty( tnCuotas )
			lcFiltro = lcFiltro + " and Cuotas = " + alltrim( str(tnCuotas))
		endif

		if !empty( lcFiltro )
			lcCursor = "DatosCupon" && sys( 2015 )
			lcCampos = "Codigo,Monto,Cuotas,TipoDocumentoTitular,NroDocumentoTitular,"
			lcCampos = lcCampos + "NombreTitular,TelefonoTitular,EntidadFinanciera,"
			lcCampos = lcCampos + "FechaComprobante,NumeroCupon,FechaCupon,HoraCupon,"
			lcCampos = lcCampos + "NumeroDeCuponAfectado,NumeroDeCanje,RecargoMonto,"
			lcCampos = lcCampos + "NumeroReferencia,UltimosDigitos,CodigoPlan"
			
			lcXml = this.oAd.ObtenerDatosEntidad( lcCampos, lcFiltro, "FechaCupon DESC, HoraCupon DESC" )
			this.XmlACursor( lcXml, lcCursor )
			scan
				scatter name loCupon
				loColeccion.Agregar( loCupon, datoscupon.Codigo )
			endscan
		endif
		return loColeccion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaInicializado() as Boolean
		return this.lInicializado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_Valor( txVal as variant ) as void
		dodefault( txVal )
		this.EstablecerTipoTarjeta()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstablecerTipoTarjeta() as Void
		if !this.EstaIntegrado()
			this.Tipotarjeta = this.valor.tipoTarjeta
		endif 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EstaValidado() as Boolean
		local llRetorno as Boolean
		llRetorno = this.Validacion
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarPagoPoint() as Void
		local lnRespuesta as integer, loDatosTarjeta as object, llPudoValidar as boolean, llNoHuboError as boolean,;
				lcMensajeDeError as string

		if 6 = goMensajes.Preguntar( "¿Desea realizar la validación de todos lus cupones pendientes de la caja " + transform( this.idCaja.id ) + "?", 4, 1 )
			this.oColaboradorPos.ValidarCuponesPorLoteParaCierreDeCaja( this.idCaja.id, .f. )
		else
			loDatosTarjeta = this.CrearDatosTarjetaCustom()
			llNoHuboError = this.oColaboradorPos.ValidarCuponManual( loDatosTarjeta , @llPudoValidar, .f. )		
			if llNoHuboError and !llPudoValidar 
				lcMensajeDeError = alltrim( this.oColaboradorPos.oComponenteNet.Respuesta.DatosRespuestaError.Message ) + " ¿Desea validar manualmente?"
				lnRespuesta = goMensajes.Preguntar( lcMensajeDeError, 4 )
				llPudoValidar = ( lnRespuesta = 6 )
			endif
			if llPudoValidar 
				this.Modificar()
				this.Validacion = .t.
				this.Grabar()
			else
				if this.HayInformacion()
					this.oMensaje.Informar( this.oInformacion )
					this.LimpiarInformacion()
				endif
			endif
		endif
		
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oColaboradorPOS_Access() as object
		local loFactory as object
		if !this.lDestroy
			loFactory = _screen.Zoo.CrearObjeto( "FactoryColaboradoresDispositivoPOS" )
			if type( "this.oColaboradorPOS" ) <> "O" or isnull( this.oColaboradorPOS )
				this.oColaboradorPOS = loFactory.ColaboradorSegunPrestador( this.POS.Prestador )
				this.oColaboradorPOS.InyectarEntidadPos( this.POS )
				this.enlazar( 'oColaboradorPOS.EventoObtenerInformacion', 'inyectarInformacion' )
			else
				if ( !empty( this.Pos.Prestador ) and this.POS.Prestador <> this.oColaboradorPOS.cPrestador) or ( empty( this.Pos.Prestador ) and this.oColaboradorPOS.cPrestador <> "POSNET" )
					this.oColaboradorPOS.oEntidadPos = null
					this.oColaboradorPOS.release()
					this.oColaboradorPOS = loFactory.ColaboradorSegunPrestador( this.POS.Prestador )
					this.oColaboradorPOS.InyectarEntidadPos( this.POS )
					this.enlazar( 'oColaboradorPOS.EventoObtenerInformacion', 'inyectarInformacion' )
				endif
			endif
		endif
		return this.oColaboradorPOS
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearDatosTarjetaCustom() as Object
		local loCupon as Object

		loCupon = newobject( "custom" )
		addproperty( loCupon, "NumeroCupon", this.NumeroCupon  )
		addproperty( loCupon, "Tipocupon", this.TipoCupon )
		addproperty( loCupon, "TotalConRecargo", this.Monto )
		addproperty( loCupon, "Pos", this.Pos )
		addproperty( loCupon, "oInformacion", this.oInformacion )
		addproperty( loCupon, "DispositivoMovil", this.DispositivoMovil )
		return loCupon
	endfunc 

enddefine
