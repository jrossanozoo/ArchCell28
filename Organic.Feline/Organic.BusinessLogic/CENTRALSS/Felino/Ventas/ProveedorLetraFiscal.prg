define class ProveedorLetraFiscal as custom

	#IF .f.
		Local this as ProveedorLetraFiscal of ProveedorLetraFiscal.prg
	#ENDIF

	oComprobantes = null
	oSFiscalCliente = null
	oSFiscalEmpresa = null
	nSituacionFiscalEmpresa = 0
	lTieneCliente = .F.
	cNombreComprobante = ""
	lComprobantesAMonotributistas = .t.

	*-----------------------------------------------------------------------------------------
	function Init( tcMonoA as Boolean, toComprobantes as Object, toSFiscalCliente as Object, toSFiscalEmpresa as Object, tnSituacionFiscalEmpresa as Integer, tlTieneCliente as Boolean, tcEntidad as String ) as Void
		with this
			.oComprobantes = toComprobantes
			.oSFiscalCliente = toSFiscalCliente 
			.oSFiscalEmpresa = toSFiscalEmpresa
			.nSituacionFiscalEmpresa = iif( vartype(tnSituacionFiscalEmpresa) = "N", tnSituacionFiscalEmpresa, goParametros.Felino.DatosGenerales.SituacionFiscal )
			.lTieneCliente = tlTieneCliente
			.cNombreComprobante = tcEntidad
			.lComprobantesAMonotributistas = tcMonoA
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetra( tnSituacionFiscalCliente as Integer, tcTipoDeComprobante as String ) as String
		local lcRetorno as String
		store "" to lcRetorno
		with this
			do case
			case tcTipoDeComprobante == "REMITO"
				 if .nSituacionFiscalEmpresa = .oSFiscalEmpresa.Inscripto 
					 lcRetorno = "R"					 
				 else
					 lcRetorno = "X"
				 endif
			case tcTipoDeComprobante == "DEVOLUCION"
				 lcRetorno = "X"
			
			case tcTipoDeComprobante == "PEDIDO"
			      lcRetorno = "X"
			      
			case tcTipoDeComprobante == "RECIBO"
			      lcRetorno = "X"
			other
				if inlist ( tcTipoDeComprobante, "FACTURAELECTRONICAEXPORTACION" , "NOTADECREDITOELECTRONICAEXPORTACION" , "NOTADEDEBITOELECTRONICAEXPORTACION" ,;
				"FACTURADEEXPORTACION" , "NOTADECREDITODEEXPORTACION" , "NOTADEDEBITODEEXPORTACION" )
					lcRetorno = "E"
				else
					if ( inlist( this.nSituacionFiscalEmpresa, .oSFiscalEmpresa.Monotributo, .oSFiscalEmpresa.Exento, .oSFiscalEmpresa.NoAlcanzado ) )
						
						if !this.lTieneCliente and vartype( goControladorFiscal ) = 'O' and goControladorFiscal.oCaracteristicas.lTicketBNumeracionIndependiente ;
								and inlist( this.cNombreComprobante, "TICKETFACTURA", "TICKETNOTADECREDITO" )
							lcRetorno = ""
						else
							lcRetorno = "C"
						endif
						
					else
						if ( tnSituacionFiscalCliente = .oSFiscalCliente.Inscripto or ( this.lComprobantesAMonotributistas and tnSituacionFiscalCliente = .oSFiscalCliente.Monotributo ) )
							if .nSituacionFiscalEmpresa = .oSFiscalEmpresa.Inscripto
								lcRetorno = this.ObtenerLetraDeComprobanteParaResponsableInscripto()
							else
								lcRetorno = this.ObtenerLetraInscripto()
							endif
						else
						
							if !this.lTieneCliente and vartype( goControladorFiscal ) = 'O' and goControladorFiscal.oCaracteristicas.lTicketBNumeracionIndependiente ;
								and inlist( this.cNombreComprobante, "TICKETFACTURA", "TICKETNOTADECREDITO" )
								
								lcRetorno = ""
							else
								lcRetorno = "B"
							endif
						endif
					endif	
				endif
			endcase
		endwith

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetrasValidas( tcEntidad as String ) as string
		local lcRetorno as String
		store "" to lcRetorno
		with this
			if inlist( upper( tcEntidad ), "RECIBO", "PEDIDO", "PRESUPUESTO", "DEVOLUCION", ;
											"REQUERIMIENTODECOMPRA", "SOLICITUDDECOMPRA", "CANCELACIONDECOMPRA", "PEDIDODECOMPRA", "PRESUPUESTODECOMPRA" )
				lcRetorno = "X"
			else
				if (inlist( this.nSituacionFiscalEmpresa, .oSFiscalEmpresa.Monotributo, .oSFiscalEmpresa.Exento, .oSFiscalEmpresa.NoAlcanzado ))
					do case
						case upper( tcEntidad ) == "REMITO"
							lcRetorno = "X"
						case upper( tcEntidad ) == "REMITODECOMPRA"
							lcRetorno = "RX"
						otherwise
							lcRetorno = "C"
					endcase
				else
					If upper( tcEntidad ) == "REMITO" or upper( tcEntidad ) == "REMITODECOMPRA" 
						lcRetorno = "RX"
					else
						lcRetorno = this.ObtenerLetraInscripto() + "B "
					endif 
				endif
			endif
		endwith

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetraInscripto() as Void
		local lcRetorno as String

		with this
			do case
				case .oComprobantes.Permitido = .oComprobantes.A
					lcRetorno = "A"
				case .oComprobantes.Permitido = .oComprobantes.M
					lcRetorno = "M"
				case .oComprobantes.Permitido = .oComprobantes.E
					lcRetorno = "E"
			endcase
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetraValidaSegunSituacionFiscalDelProveedor( tnSituacionFiscalDelProveedor as Integer ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.crearobjeto( "zooColeccion" )
		
		if goParametros.Nucleo.DatosGenerales.Pais = 3
			loRetorno.Agregar( "A" )
			loRetorno.Agregar( "B" )
		else
			do case
				case tnSituacionFiscalDelProveedor == goRegistry.Felino.SituacionFiscalClienteExento && and inlist( lcLetra, "C" )
					loRetorno.Agregar( "C" )
					loRetorno.Agregar( "E" )
				case tnSituacionFiscalDelProveedor == goRegistry.Felino.SituacionFiscalClienteInscripto && and inlist( lcLetra, "A", "M", "B", "E" )
					loRetorno.Agregar( "A" )
					loRetorno.Agregar( "M" )
					loRetorno.Agregar( "B" )
					loRetorno.Agregar( "E" )
					loRetorno.Agregar( "" )
				case tnSituacionFiscalDelProveedor == goRegistry.Felino.SituacionFiscalClienteMonotributo &&& and inlist( lcLetra, "C", "E" )
					loRetorno.Agregar( "C" )
					loRetorno.Agregar( "E" )					
				case tnSituacionFiscalDelProveedor == goRegistry.Felino.SituacionFiscalClienteNoAlcanzado && and inlist( lcLetra, "C" )
					loRetorno.Agregar( "C" )
					loRetorno.Agregar( "E" )
			endcase
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerConjuntoDeLetrasFiscalesValidasParaFacturas() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion of zoocoleccion.prg
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		loRetorno.Agregar( "A" )
		loRetorno.Agregar( "B" )
		loRetorno.Agregar( "C" )		
		loRetorno.Agregar( "E" )
		loRetorno.Agregar( "M" )
		loRetorno.Agregar( "" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetraDeComprobanteParaResponsableInscripto() as String
		local lcRetorno as String
		do case
		case goParametros.Felino.DatosGenerales.TipoDeComprobanteAEmitirComoResponsableInscripto = 2
			lcRetorno = "M"
		otherwise
			lcRetorno = "A"
		endcase
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetraParaComprobanteDeVentas( tnSituacionFiscal as Integer ) as String
		local loSituacionFiscalEmpresa as Object, loSituacionFiscalCliente as Object, lcRetorno as String
		loSituacionFiscalEmpresa = _Screen.Zoo.CrearObjeto( "situacionFiscalEmpresa", "componentefiscal.prg" )
		loSituacionFiscalCliente = _Screen.Zoo.CrearObjeto( "situacionFiscal", "componentefiscal.prg" )
		do case
		case goParametros.Felino.DatosGenerales.SituacionFiscal = loSituacionFiscalEmpresa.Inscripto and tnSituacionFiscal = loSituacionFiscalCliente.Inscripto
			if goParametros.Felino.DatosGenerales.TipoDeComprobanteAEmitirComoResponsableInscripto = 2
				lcRetorno = "M"
			else
				lcRetorno = "A"
			endif
		case goParametros.Felino.DatosGenerales.SituacionFiscal = loSituacionFiscalEmpresa.Inscripto and tnSituacionFiscal # loSituacionFiscalCliente.Inscripto
			lcRetorno = "B"
		case goParametros.Felino.DatosGenerales.SituacionFiscal # loSituacionFiscalEmpresa.Inscripto and goParametros.Felino.DatosGenerales.SituacionFiscal # 0
			lcRetorno = "C"
		otherwise
			lcRetorno = ''
		endcase
		release loSituacionFiscalEmpresa, loSituacionFiscalCliente
		return lcRetorno
	endfunc 

*!*	loSituacionFiscalEmpresa
*!*		Inscripto = 0
*!*		Monotributo = 0
*!*		Exento = 0
*!*		NoAlcanzado = 0

*!*	loSituacionFiscal
*!*		Inscripto = 0
*!*		ConsumidorFinal = 0
*!*		InscriptoNoResp = 0
*!*		Exento = 0
*!*		Monotributo = 0
*!*		NoAlcanzado = 0

	*-----------------------------------------------------------------------------------------
	function ObtenerLetrasValidasParaComprobanteDeCompras( tnSituacionFiscal as Integer ) as Object
		local loSituacionFiscalEmpresa as Object, loSituacionFiscalProveedor as Object, loRetorno as Object
		loSituacionFiscalEmpresa = _Screen.Zoo.CrearObjeto( "situacionFiscalEmpresa", "componentefiscal.prg" )
		loSituacionFiscalProveedor = _Screen.Zoo.CrearObjeto( "situacionFiscal", "componentefiscal.prg" )
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		do case
		case goParametros.Felino.DatosGenerales.SituacionFiscal = loSituacionFiscalEmpresa.Inscripto and tnSituacionFiscal = loSituacionFiscalProveedor.Inscripto
			loRetorno.Agregar( "A" )
			loRetorno.Agregar( "E" )
			loRetorno.Agregar( "M" )
			loRetorno.Agregar( "" )
		case goParametros.Felino.DatosGenerales.SituacionFiscal = loSituacionFiscalEmpresa.Inscripto and tnSituacionFiscal # loSituacionFiscalCliente.Inscripto
			loRetorno.Agregar( "C" )		
			loRetorno.Agregar( "E" )
			loRetorno.Agregar( "" )
		case goParametros.Felino.DatosGenerales.SituacionFiscal # loSituacionFiscalEmpresa.Inscripto and goParametros.Felino.DatosGenerales.SituacionFiscal # 0
			loRetorno.Agregar( "C" )		
			loRetorno.Agregar( "E" )
			loRetorno.Agregar( "" )
			lcRetorno = "C"
		otherwise
			loRetorno.Agregar( "" )
		endcase
		release loSituacionFiscalEmpresa, loSituacionFiscalProveedor
		return loRetorno
	endfunc 

enddefine

