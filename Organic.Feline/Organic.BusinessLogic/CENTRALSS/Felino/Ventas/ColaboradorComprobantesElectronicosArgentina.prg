Define Class ColaboradorComprobantesElectronicosArgentina as ColaboradorComprobantesDeVenta Of ColaboradorComprobantesDeVenta.prg

	#IF .f.
		Local this as ColaboradorComprobantesElectronicosArgentina of ColaboradorComprobantesElectronicosArgentina.prg
	#ENDIF

	oEntComprobanteEquidad = null

	#define SINESTADO	0
	#define GENERADA	1
	#define NOGENERADA	2
	
	*-----------------------------------------------------------------------------------------
	function oEntComprobanteEquidad_Access() as Void
	
		if !this.lDestroy and ( !vartype( this.oEntComprobanteEquidad ) == "O"  or isnull(  this.oEntComprobanteEquidad ))
			this.oEntComprobanteEquidad = _screen.zoo.instanciarentidad( "FACTURAELECTRONICA" )
		endif
		return this.oEntComprobanteEquidad 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function VerificarConfiguracion() as Void

		lnTipoDeWebService = goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Nacional.TipoDeWebServiceparafacturacionelectronicanacional
		lnSituacionFiscal = goServicios.Parametros.Felino.DatosGenerales.SituacionFiscal
		
		If lnTipoDeWebService = 2 and lnSituacionFiscal = 3
			goServicios.Errores.LevantarExcepcion( "Las empresas con situación fiscal Monotributo no son admitidas por el servicio de facturación electrónica WSMTXCA." + chr(13) + "Verifique los parámetros en Datos de la Empresa --> Situación Fiscal y en Gestión de ventas --> Facturación Electrónica --> Mercado Interno" )
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function VerificarPedidoDeCAE( toComprobanteElectronico as Object ) as Void
	
		If goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.PedirCAEAlFinalizarElComprobante 
			toComprobanteElectronico.EventoPreguntarObtenerCAE()
			If toComprobanteElectronico.lPedirCAE
				toComprobanteElectronico.AutorizarComprobanteElectronico()
			Endif
		Else
			toComprobanteElectronico.ActualizarDatosPorNoPedirCAE()
		Endif		
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SetearNumeroComprobanteElectronico( toComprobanteElectronico as object ) as Void
		Local loFE as Object, loDinComprobante as Object, lnTipoComprobante as Integer, ;
			lnUltimoNro as Integer

		loDinComprobante = _Screen.Zoo.CrearObjeto( "Din_Comprobante" )

		lnTipoComprobante = loDinComprobante.ObtenerNumeroComprobante( toComprobanteElectronico.entidad )
		
		if "exportacion" $ lower( toComprobanteElectronico.Entidad )
			loFE = toComprobanteElectronico.ElectronicoExportacion()
		else
			loFE = toComprobanteElectronico.ElectronicoNacional()
		endif

		toComprobanteElectronico.Numero = loFE.ObtenerUltimoNumeroDeComprobante( lnTipoComprobante, toComprobanteElectronico.PuntoDeVenta, toComprobanteElectronico.Letra )

		loDinComprobante.Release()
		loFE.Release()

	Endfunc

	*-----------------------------------------------------------------------------------------
	function oComprobante_Access()
		if !this.ldestroy and ( !vartype( this.oComprobante ) = 'O' or isnull( this.oComprobante ) )
			this.oComprobante =_Screen.Zoo.InstanciarEntidad( "NotaDeCreditoElectronica" )
			bindevent(this.oComprobante, "EventoPreguntarSiAplicaDescuento", this,"EventoPreguntarSiAplicaDescuento" )
		endif
		return this.oComprobante 
	endfunc

	*-----------------------------------------------------------------------------------------
	function PreCargarNotaDeCredito( toComprobante as Object ) as Boolean 
		local llRetorno as Boolean
		
		this.InyectarEntidad( toComprobante )
		this.lResultadoEventoKontrolerDescuento = toComprobante.oCompDescuentos.lAplicarDescuento	
		llRetorno = .f.
		this.Estado = SINESTADO

		Try
			if this.oComprobante.EsNuevo()
				this.oComprobante.Cancelar()
			endif

			this.oInformacion.Limpiar()
			loComprobante = this.oComprobante
			with loComprobante
				.Nuevo()

				.lForzarAccionCancelatoria = toComprobante.Total = 0
			
				this.CargarCabecera( loComprobante, toComprobante )
				
				this.CargarDetalle( loComprobante, toComprobante )
				
				this.CargarPie( loComprobante, toComprobante )
			 	
			 	.lPedirCAE = .f.
				llRetorno = .t.
			Endwith
		Catch To loError
			llRetorno = .f.

			If Type("loerror") = "O" And Type("loerror.uservalue") = "O" And Type("loerror.uservalue.oinformacion") = "O" And Lower(loerror.uservalue.oinformacion.class) = "zooinformacion" And Type("loerror.uservalue.oinformacion.count") = "N"
				For Each loItem In loError.UserValue.oInformacion
					this.oInformacion.AgregarInformacion( loItem.cMensaje )
				Next
				If loError.userValue.oInformacion.Count > 1
					lcMensaje = "Han ocurrido errores al intentar generar una nota de crédito electrónica por cambio."
				Else
					lcMensaje = "Ha ocurrido un error al intentar generar una nota de crédito electrónica por cambio."
				Endif
				this.oInformacion.AgregarInformacion( lcMensaje )
			Endif

			goServicios.Errores.LevantarExcepcion( this.oInformacion )

		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTotalNotaDeCredito() as Double
		return this.ObtenerTotalComprobanteGenerado()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function GenerarNotaDeCreditoPorDevolucion( toComprobante as Object ) as Boolean 
		Local llRetorno as Boolean, loComprobante as Object, loItem as Object, lcComprobante as String, ;
			loError as Object, llNoValidarsaldo as Boolean 
		
		this.InyectarEntidad( toComprobante )
		this.lResultadoEventoKontrolerDescuento = toComprobante.oCompDescuentos.lAplicarDescuento	
		llRetorno = .f.
		this.Estado = SINESTADO

		Try
			if this.oComprobante.EsNuevo()
				this.oComprobante.Cancelar()
			endif

			this.oInformacion.Limpiar()
			loComprobante = this.oComprobante
			with loComprobante
				.Nuevo()

				.lForzarAccionCancelatoria = toComprobante.Total = 0
				&& Se debería comportar como una accion cancelatoria y se deben calcular IIBB
				&& ver DebeCalcularIIBBCabaSegunCorrespondePorNormativaAGIP en ComponenteImpuestosVentas
				
				this.CargarCabecera( loComprobante, toComprobante )
				
				this.CargarDetalle( loComprobante, toComprobante )

				this.CargarPie( loComprobante, toComprobante )

				this.CargarValores( loComprobante, toComprobante )
				
				lcComprobante = toComprobante.letra +" "+ Padl(Transform( toComprobante.PuntoDeVenta ),4,"0") + "-"+ Padl(Transform( toComprobante.Numero ),8,"0")
			 	.zadsfw = .zadsfw + "Comprobante generado por la " + toComprobante.cDescripcion + " Nº " + lcComprobante + " - Motivo: Devolución"
			 	
			 	.lPedirCAE = .f.
				lNoValidarsaldo = goCaja.oCajasaldos.lNoVerificarCaja
				goCaja.oCajasaldos.lNoVerificarCaja = .t.
				
			 	.Grabar()
			 	
				goCaja.oCajasaldos.lNoVerificarCaja = lNoValidarsaldo
			 	.lPedirCAE = iif( loComprobante.lModoCaeaActivado, .f., .t. )
			 	
				this.Estado = GENERADA
				llRetorno = .t.
			endwith
			
		Catch To loError
			this.Estado = NOGENERADA
			llRetorno = .f.

			If Type("loerror") = "O" And Type("loerror.uservalue") = "O" And Type("loerror.uservalue.oinformacion") = "O" And Lower(loerror.uservalue.oinformacion.class) = "zooinformacion" And Type("loerror.uservalue.oinformacion.count") = "N"
				For Each loItem In loError.UserValue.oInformacion
					this.oInformacion.AgregarInformacion( loItem.cMensaje )
				Next
				If loError.userValue.oInformacion.Count > 1
					lcMensaje = "Han ocurrido errores al intentar generar una nota de crédito electrónica por cambio."
				Else
					lcMensaje = "Ha ocurrido un error al intentar generar una nota de crédito electrónica por cambio."
				Endif
				this.oInformacion.AgregarInformacion( lcMensaje )
			Endif

			goServicios.Errores.LevantarExcepcion( this.oInformacion )

		Endtry
		
		Return llRetorno 
 	endfunc

	*-----------------------------------------------------------------------------------------
	Function EliminarComprobanteGeneradoPorDevolucion() as Void
		If this.oComprobante.EsNuevo()
			this.oComprobante.Cancelar()
		Else
			this.oComprobante.Anular()
			this.oComprobante.Eliminar()
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInfoNotaDeCreditoGenerada() as string 
		local lcRetorno as String 
			if empty( this.oComprobante.CAE )
				lcRetorno = ""
			else
				lcRetorno = this.ObtenerComprobanteGenerado()
			Endif
		return lcRetorno	

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ComprobanteGeneradoOK() as Boolean
		Local llRetorno as Boolean
		llRetorno = this.Estado = GENERADA
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Function ComprobanteNoGenerado() as Boolean
		Local llRetorno as Boolean
		llRetorno = this.Estado = NOGENERADA
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function PedirCaeNotaDeCreditoPorDevolucion() as Void
		this.VerificarPedidoDeCAE( this.oComprobante )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PedirCaeNCPorCorreccionDeAlicuotaGiftCard() as Void
		this.VerificarPedidoDeCAE( this.oComprobante )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarAccionesNCDespuesDeGrabar() as Void
		local llRetorno as Boolean
		with this.oComprobante
			.EnviarAccionesAutomatizadas( 'DespuesDeGrabar' )
			this.GenerarPdfsNC()
			llRetorno = .ImprimirDespuesDeGrabar()
			if .lHabilitaEnviarAlGrabar and .lTieneDiseñosParaEnviarMail
				.EnviarMailAlGrabar()
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarPdfsNC() as Void
		if this.oComprobante.DebeGenerarPDFsDeDisenosAutomaticamente() 
			goServicios.Impresion.GenerarPDFsAlGrabarEntidad( this.oComprobante )
		endif 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarEquidadARCA( tnNumerocomprobante as Number, tcCodigocomprobante as String ) as Void
		local llHayErrorEquidad as Boolean, lcCodigoNuevo as String, lcIDComprobanteEquidad as String, ;
			lcValor as String, lnPuntodeVenta as Number, lcArticuloAutilizarEnComprobantes as String, ;
			loZooException as Object, loLogueador as Object, lcComporbante as String, lcObs as String, ;
			lnNumero as Number, lcComporbanteOrigen as String, lnPuntodeVentaAux as Number
				
		store '' to lcCodigoNuevo, lcIDComprobanteEquidad, lcValor, lcComporbante, lcComporbanteOrigen
		llHayErrorEquidad =.f.
		store 0 to lnPuntodeVenta, lnPuntodeVentaAux 

		gomensajes.enviarsinespera("Sincronizando comprobantes" )
		lcValor = goparametros.felino.gestiondeventas.facturacionelectronica.nacional.valorautilizarencomprobante
		lcIDComprobanteEquidad = alltrim( goregistry.felino.idcomprobanteequidadarca )
		lcArticuloAutilizarEnComprobantes = goparametros.felino.gestiondeventas.facturacionelectronica.nacional.articuloautilizarencomprobantes
		lcClienteParaNoPersonalizado = goparametros.felino.gestiondeventas.facturacionelectronica.nacional.clienteautilizarennotasdecreditodecomprobantessinpersonalizar
	
		try
		*****renumerar último comprobante 
			with this
				.oEntComprobanteEquidad.nuevo()
				lcCodigoNuevo = .oEntComprobanteEquidad.codigo
				.oEntComprobanteEquidad.ledicion = .f.
				.oEntComprobanteEquidad.lnuevo = .f.
				.oEntComprobanteEquidad.codigo = tcCodigocomprobante
				.oEntComprobanteEquidad.cargar()
				lnPuntodeVenta = .oEntComprobanteEquidad.puntodeventa 
				lnNumero = .oEntComprobanteEquidad.numero
				.oEntComprobanteEquidad.modificar()
				.oEntComprobanteEquidad.ledicion = .f.
				.oEntComprobanteEquidad.lnuevo = .T.
				.oEntComprobanteEquidad.codigo = lcCodigoNuevo 
				.oEntComprobanteEquidad.lGenerandoEquidadARCA = .t.
				lcComporbante = alltrim(.oEntComprobanteEquidad.letra) + " " + padl( alltrim(transform(  .oEntComprobanteEquidad.puntodeventa )), 5, "0" ) + "-" + padl(alltrim(transform( .oEntComprobanteEquidad.numero )), 8, "0")
				lcComporbanteOrigen = alltrim(.oEntComprobanteEquidad.letra) + " " + padl( alltrim(transform( lnPuntodeVenta )), 5, "0" ) + "-" + padl(alltrim(transform( lnNumero )), 8, "0")
				lcObs = "Comprobante renumerado por la emisión automática de CAEA. Comprobante origen: " + lcComporbanteOrigen
				
				if !empty(.oEntComprobanteEquidad.ZadsFW)
					.oEntComprobanteEquidad.ZadsFW = .oEntComprobanteEquidad.ZadsFW + chr(13) + lcObs
				else
					.oEntComprobanteEquidad.ZadsFW = lcObs
				endif				
				.oEntComprobanteEquidad.grabar()
				
				lcDescripcion = "Comprobante electrónico renumerado con éxito. Comprobante: " + lcComporbante + " Comprobante origen: " + lcComporbanteOrigen
			endwith			
			
		catch to loError
			lcDescripcion = "Atención!!! no se puedo renumerar automáticamente el comprobante electrónico. Comprobante: " + lcComporbante && + " Comprobante origen: " + lcComporbanteOrigen + ". No se realizará la sincronización del comprobante."
			llHayErrorEquidad = .t.
			this.oEntComprobanteEquidad = null
		finally

			loZooException = _screen.Zoo.CrearObjeto( "ZooException" )
			loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( loZooException )
			loLogueador.Escribir( lcDescripcion )
			goServicios.Logueos.Guardar( loLogueador )
		endtry
	
		if llHayErrorEquidad
		else
			&& crear comprobante equidad ARCA
			try
			
			*************************************************************************************************************
			** comprobante con detalle modificado por un articulo concepto no gravado
			*************************************************************************************************************
				with this
					lcComporbanteOrigen = ""
					lcCodigoDatosFiscales = goparametros.felino.datosimpositivos.codigodedatofiscalautilizar
					goparametros.felino.datosimpositivos.codigodedatofiscalautilizar = ''					
					.oEntComprobanteEquidad.codigo = tcCodigocomprobante
					lnPuntodeVentaAux = .oEntComprobanteEquidad.puntodeventa 
					lnNumero = .oEntComprobanteEquidad.numero									
					.oEntComprobanteEquidad.modificar()
					.oEntComprobanteEquidad.ledicion = .f.
					.oEntComprobanteEquidad.lnuevo = .f.
					.oEntComprobanteEquidad.codigo = lcIDComprobanteEquidad 		
					.oEntComprobanteEquidad.lCargando = .t.
					.oEntComprobanteEquidad.codigo = tcCodigocomprobante
										
					***obtener datos del comprobante CAEA***
					lncaja = .oEntComprobanteEquidad.caja_pk
					lntotalComp = .oEntComprobanteEquidad.total
					lnPuntodeVenta = .oEntComprobanteEquidad.PuntoDeVenta
					****************************************					
					.oEntComprobanteEquidad.lCargando = .f.
					.oEntComprobanteEquidad.ledicion = .T.
					.oEntComprobanteEquidad.lnuevo = .f.
					.oEntComprobanteEquidad.lGenerandoEquidadARCA = .t.
					.oEntComprobanteEquidad.CAE = ""
					.oEntComprobanteEquidad.FechaVencimientoCAE = {//}
					.oEntComprobanteEquidad.nCodigoCAEA = ""
					.oEntComprobanteEquidad.lCAEAInformado = .f.					
					lcComporbante = alltrim(.oEntComprobanteEquidad.letra) + " " + padl( alltrim(transform( lnPuntodeVentaAux )), 5, "0" ) + "-" + padl(alltrim(transform( lnNumero )), 8, "0")
					lcComporbanteOrigen = alltrim(.oEntComprobanteEquidad.letra) + " " + padl( alltrim(transform(  .oEntComprobanteEquidad.puntodeventa )), 5, "0" ) + "-" + padl(alltrim(transform( .oEntComprobanteEquidad.numero )), 8, "0")
					lcObs = "Comprobante sincronizado por circuito de transformación CAEA. Comprobante origen: " + lcComporbanteOrigen
					if !empty(.oEntComprobanteEquidad.ZadsFW)
						.oEntComprobanteEquidad.ZadsFW = .oEntComprobanteEquidad.ZadsFW + chr(13) + lcObs
					else
						.oEntComprobanteEquidad.ZadsFW = lcObs
					endif
					if empty( .oEntComprobanteEquidad.Cliente )
						.oEntComprobanteEquidad.Cliente = lcClienteParaNoPersonalizado
					endif
					.oEntComprobanteEquidad.caja_pk = lncaja
					.oEntComprobanteEquidad.lCargando = .t.
					.oEntComprobanteEquidad.PuntoDeVenta = lnPuntodeVentaAux
					.oEntComprobanteEquidad.lCargando = .f.
					.oEntComprobanteEquidad.numero = tnNumerocomprobante
					
					**** cambiamos el detalle por el articulo concepto en parametros
					.oEntComprobanteEquidad.factuRADETALLE.limpiar()
					.oEntComprobanteEquidad.factuRADETALLE.actualizar()
					.oEntComprobanteEquidad.factuRADETALLE.limpiaritem()
					.oEntComprobanteEquidad.factuRADETALLE.oitem.ARTICULO_PK = lcArticuloAutilizarEnComprobantes
					.oEntComprobanteEquidad.factuRADETALLE.oitem.cantIDAD = 1
					.oEntComprobanteEquidad.factuRADETALLE.oitem.precio = lnTotalComp
					.oEntComprobanteEquidad.factuRADETALLE.oitem.monTO = lnTotalComp
					.oEntComprobanteEquidad.factuRADETALLE.actualizar()
					
					*** Cambiamos el valor del detalle por uno generico en parametros					
					.oEntComprobanteEquidad.valoRESDETALLE.limpiar()
					.oEntComprobanteEquidad.valoRESDETALLE.actualizar()
					.oEntComprobanteEquidad.valoRESDETALLE.limpiaritem()
					.oEntComprobanteEquidad.valoRESDETALLE.oitem.valor_pk = lcValor
					.oEntComprobanteEquidad.valoRESDETALLE.oitem.recibido = .oEntComprobanteEquidad.total &&lnTotalComp
					.oEntComprobanteEquidad.valoRESDETALLE.actualizar()

					lcComporbante = alltrim(.oEntComprobanteEquidad.letra) + " " + padl( alltrim(transform(.oEntComprobanteEquidad.puntodeventa)), 5, "0" ) + "-" + padl(alltrim(transform(.oEntComprobanteEquidad.numero)), 8, "0")
					
					.oEntComprobanteEquidad.Timestamp = .oEntComprobanteEquidad.oAd.ObtenerTimestampActual()					
					.oEntComprobanteEquidad.grabar()
					
					if empty( .oEntComprobanteEquidad.cae )
						oEntComprobanteEquidad.AutorizarComprobanteElectronico()
					endif
					 llTieneCAE = !empty( .oEntComprobanteEquidad.cae )
				endwith	
			

				
			catch to loerror
				llHayErrorEquidad =.t.			
	
				this.oEntComprobanteEquidad.codigo = tcCodigocomprobante 
				this.oEntComprobanteEquidad.anular()
				
			finally
				this.oEntComprobanteEquidad = null
				if llHayErrorEquidad
					lcDescripcion = "Atención!!! el Comprobante no fue sincronizado por circuito de transformación CAEA. Comprobante a sincronizar: " + lcComporbante + " Comprobante origen: " + lcComporbanteOrigen					
				else
					lcDescripcion = "Comprobante sincronizado por circuito de transformación CAEA. Comprobante origen: " + lcComporbanteOrigen					
				endif
				loZooException = _screen.Zoo.CrearObjeto( "ZooException" )
				loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( loZooException )
				loLogueador.Escribir( lcDescripcion )
				goServicios.Logueos.Guardar( loLogueador )

				goregistry.felino.idcomprobanteequidadarca = ''
				goparametros.felino.datosimpositivos.codigodedatofiscalautilizar = lcCodigoDatosFiscales 	
			endtry
		endif
		
		if llHayErrorEquidad
		else
			&& crear nota de crédito del comprobante equidad ARCA
			try
				with this					
					llpedircaealfinalizarelcomprobante = goparametros.felino.gestiondeventas.facturacionelectronica.pedircaealfinalizarelcomprobante
					
					do case
						case !llTieneCAE and llpedircaealfinalizarelcomprobante
							goparametros.felino.gestiondeventas.facturacionelectronica.pedircaealfinalizarelcomprobante = .f.
						
						case llTieneCAE and !llpedircaealfinalizarelcomprobante
							goparametros.felino.gestiondeventas.facturacionelectronica.pedircaealfinalizarelcomprobante = .t.												
					endcase

					.oEntComprobanteEquidad.lGenerandoEquidadARCA = .t.
					.oEntComprobanteEquidad.codigo = tcCodigocomprobante
					.oEntComprobanteEquidad.GenerarComprobante( "notadecreditoelectronica",,lcValor )

					try
						this.ActualizarInfoAdicional( alltrim( this.oEntComprobanteEquidad.compafec.oitem.afecta  ), alltrim( this.oEntComprobanteEquidad.OAD.cTablaPrincipal ))
					catch
					endtry
					
				endwith
			catch to loError
				llHayErrorEquidad = .t.
				this.oEntComprobanteEquidad = null
			finally
				if llHayErrorEquidad 
					lcDescripcion = "No se pudo obtener CAE y/o relizar la nota de crédito correspondiente al comprobante sincronizado automáticamente por circuito de transformación CAEA. Comprobante: " + lcComporbante 
				else
					lcDescripcion = "Nota de crédito correspondiente al comprobante sincronizado automáticamente por circuito de transformación CAEA generado correctamente. Comprobante: " + lcComporbante 
				endif
				loZooException = _screen.Zoo.CrearObjeto( "ZooException" )
				loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( loZooException )
				loLogueador.Escribir( lcDescripcion )
				goServicios.Logueos.Guardar( loLogueador )			
				goparametros.felino.gestiondeventas.facturacionelectronica.pedircaealfinalizarelcomprobante = llpedircaealfinalizarelcomprobante		
			endtry
		endif
		
		loLogueador = null
		loZooException = null
		gomensajes.enviarsinespera()
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function HabilitarCircuitoEquidadARCA() as Boolean
	* Se habilita desde hook ColorYTalle_ColaboradorComprobantesElectronicosArgentina 
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function TiempoDeEspera() as Number
	* se cambia desde hook ColorYTalle_ColaboradorComprobantesElectronicosArgentina
		return 10
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarInfoAdicional( tcCodigo as String, tcTablaPrincipal as String ) as Void
		local lcTabla as String, lcMensajeSistema as String, lcSentencia as String
	
		lcTabla = "[" + _Screen.Zoo.App.Obtenerprefijodb() + _screen.zoo.app.csucursalactiva + "].[" + alltrim( _screen.zoo.app.cSchemaDefault ) + "].["
		lcTabla = lcTabla + tcTablaPrincipal + "]"
		lcMensajeSistema = 'Comprobante sincronizado por circuito de transformación CAEA.'

		text to lcSentencia noshow textmerge
			update <<lcTabla>> set ZadsFW = '<<lcMensajeSistema>>'								  
			where CODIGO = '<<tcCodigo>>'
		endtext

		goServicios.Datos.EjecutarSentencias( lcSentencia, tcTablaPrincipal, "", "", set("Datasession") )
	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function CargarCabecera( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg ) as Void
		toComprobanteDestino.oCompSenias.lCargarSeniasPendientesDelCliente = .f.
		Dodefault( toComprobanteDestino, toComprobanteOrigen )
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function CargarDetalle( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg ) as Void
		toComprobanteDestino.FacturaDetalle.Limpiar()
		DoDefault( toComprobanteDestino, toComprobanteOrigen )
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function CargarPie( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg ) as Void
		With toComprobanteDestino
				.PorcentajeDescuento = toComprobanteOrigen.PorcentajeDescuento
				.RecargoPorcentaje = toComprobanteOrigen.RecargoPorcentaje
		Endwith

	EndFunc 

Enddefine
