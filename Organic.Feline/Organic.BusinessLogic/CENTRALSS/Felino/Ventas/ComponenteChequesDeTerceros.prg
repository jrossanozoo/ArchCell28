define class componenteChequesDeTerceros As din_componenteChequesDeTerceros Of din_componenteChequesDeTerceros.prg

	#If .F.
		Local This As componenteChequesDeTerceros Of componenteChequesDeTerceros.prg
	#Endif

*!* -->		#include valores.h
	#define TIPOVALORMONEDALOCAL			1
	#define TIPOVALORMONEDAEXTRANJERA		2
	#define TIPOVALORTARJETA       			3
	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO  			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO  	14
	#define TIPOVALORCUENTABANCARIA			13
	#define TIPOVALORPAGOELECTRONICO		11
	#define TIPOVALORCUENTACORRIENTE   		6
	#define TIPOVALORVALEDECAMBIO			8
	#define TIPOVALORPAGARE					5
	#define TIPOVALORTICKET					7
	#define TIPOVALORAJUSTEDECUPON  10

	#define TIPOMOVIMIENTONODEFINIDO 0
	#define TIPOMOVIMIENTOENTRADA			1
	#define TIPOMOVIMIENTOSALIDA			2
	#define ESTADOINGRESADO					1
	#define ESTADOSELECCIONADO				2
*!*		#include valores.h   <--
	#define PRECISIONMONTOS    4

	cNombre = "CHEQUESDETERCEROS"

	*-----------------------------------------------------------------------------------------
	Function Destroy() As Void
		If this.ldestroy and Vartype( This.oClonadorDeCheques ) = "O" And !Isnull( This.oClonadorDeCheques )
			This.oClonadorDeCheques = null
		Endif
		DoDefault()
	Endfunc

   	*-----------------------------------------------------------------------------------------
	protected function GenerarCheque( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg, toRetorno as object, tnIncremento as Integer ) as zoocoleccion OF zoocoleccion.prg 
		local loItem as object, loError as Exception, lcEstado as String, lcCodigoComprobanteOrigen as String, lnCaja as Integer && , loDetalle  as string, loItemValor as object
		with this
			loItem = this.ObtenerItemAsociadoACheque( .oDetallePadre, toCheque.NroItem )
			if !this.EsValorTipoChequeDeTerceros( loItem.Tipo )
				goServicios.Errores.LevantarExcepcion( "Error en los datos de los cheques. Verifique los valores" )
			endif
			with .oEntidad
				.nuevo()
				try
					
					*** Datos cargados por el usuario
					 this.ResolverNumeracionEntidad( this.oEntidad )	
					.Fecha = toCheque.Fecha
					.FechaEmision = toCheque.FechaEmision					
					.Numero = toCheque.NumeroCheque
					.NombreLibrador = left(toCheque.NombreLibrador,60)
					if this.nPAIS = 1
						.CodigoTributarioLibrador = toCheque.CodigoTributarioLibrador
					else
						.CodigoTributarioLibradorRUT = toCheque.CodigoTributarioLibradorRUT
					endif
					.TelefonoLibrador = toCheque.TelefonoLibrador
					.AutorizacionAlfa = toCheque.AutorizacionAlfa 
					.EntidadFinanciera_PK = toCheque.EntidadFinanciera
					.Observacion = toCheque.Observacion
					
					*** Datos asociados al item
					.Monto = this.ObtenerMontoORecibido(loItem)
					.FechaEndoso = loItem.FechaComp

					*** Datos asociados al valor
					.Valor = toCheque.Valor
					.Tipo = toCheque.Tipo
					.EntidadFinancieraEndoso_PK = toCheque.EntidadFinancieraEndoso
					.LeyendaEndoso = toCheque.LeyendaEndoso
					.CuentaEndoso = toCheque.CuentaEndoso
					.PagueseA = toCheque.PagueseA 
					.Moneda_PK = this.ObtenerMonedaEnValor( loItem.Valor_PK )
					.ChequeElectronico = this.ovalor.chequeelectronico
					
					*** Datos asociados al comprobante
					if !this.oEntidadPadre.EsComprobanteDeCaja()
						if this.oEntidadPadre.oLibradorDeCheque.cNombre = "PROVEEDOR" 
							.Proveedor_pk = this.oEntidadPadre.Proveedor_Pk
						else 
							.Vendedor = this.oEntidadPadre.Vendedor_Pk
							.Cliente_pk = this.oEntidadPadre.Cliente_Pk
						endif
					endif

					lcCodigoComprobanteOrigen = this.ObtenerCodigoDeComprobante()
					
					with this.oEntidadPadre
						this.SetearCombinacionEnEntidadOrigen( .TipoComprobante, .Letra, .PuntoDeVenta, .Numero, .signodemovimiento, lcCodigoComprobanteOrigen )
					endwith

					if loItem.Caja_PK = 0
						lnCaja = goCaja.ObtenerNumeroDeCajaActiva()
					else
						lnCaja = loItem.Caja_PK
					endif
					this.GenerarInteraccionEnElHistorialDelCheque( lnCaja )

					if .Validar()
						loItem.NumeroInterno = Padl( Transform( .PuntoDeVenta ), 4, "0" ) + "-" + Padl( Transform( .NumeroC ), 8, "0" )

						if this.MostrarNumeroCheque()
							loItem.cEtiquetaNumeroCheque = this.ObtenerStringNumeroCheque( toCheque.NumeroCheque )
						endif 

						loItem.NumeroCheque_pk = .Codigo
						this.LlenarColeccionSentencias( .ObtenerSentenciasInsert( ), toRetorno )
					else
						goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
					endif
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.Cancelar()
				endtry
				
			endwith
		endwith
		
		return toRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarChequeSelecionadoDeLaCartera( tcIdChequeSeleccionado as String, toItem as ItemActivo of ItemActivo.Prg ) as void
		local loEx as Object, lcDescripcionDeEstadosDeSeleccion as String, lcMensajeAdicional as String
		if empty( tcIdChequeSeleccionado )
			toItem.NumeroInterno = ""
		else
			if this.oChequesADarDeBajaDeLaCartera.Buscar( tcIdChequeSeleccionado ) and toItem.NumeroCheque_pk != tcIdChequeSeleccionado
				goServicios.Errores.LevantarExcepcion( "No puede utilizar el mismo cheque dos veces." )
			else
				if this.oChequesADarDeBajaDeLaCartera.Buscar( toItem.NumeroCheque_pk ) and toItem.NumeroCheque_pk != tcIdChequeSeleccionado
					this.oChequesADarDeBajaDeLaCartera.Quitar( toItem.NumeroCheque_pk )
					toItem.NumeroCheque_pk = ""
				endif
				if this.oChequesADarDeBajaDeLaCartera.Buscar( toItem.NumeroCheque_pk ) and toItem.NumeroCheque_pk == tcIdChequeSeleccionado
					this.oChequesADarDeBajaDeLaCartera.Quitar( toItem.NumeroCheque_pk )
					toItem.NumeroCheque_pk = ""
				endif				
				
			endif

			this.oEntidad.Codigo = tcIdChequeSeleccionado
			
			this.ValidarMonedaDeCheque( toItem )
			this.ValidarTipoDeCheque( toItem )

			if !this.ExistenInteraccionesPosterioresALasDelComprobante( toItem.NumeroCheque.HistorialDetalle, this.ObtenerCodigoDeComprobante() ) ;
 			 or this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.buscar( tcIdChequeSeleccionado )

				if this.oColaboradorCheques.ValidarEstadoDeChequeSeleccionadoSegunEstadoDestino( this.oEntidadPadre, this.oEntidad.Estado, toItem.Tipo, this.ObtenerNombreDetallePadre() )
	 				this.oChequesADarDeBajaDeLaCartera.Agregar( tcIdChequeSeleccionado, tcIdChequeSeleccionado )
					this.CargarDatosDeChequeEnItem( toItem, tcIdChequeSeleccionado )
				else
					lcDescripcionDeEstadosDeSeleccion = this.oColaboradorCheques.ObtenerDescripcionDeEstadosDeSeleccionSegunEntidad( this.oEntidadPadre, toItem.Tipo, this.ObtenerNombreDetallePadre() )
					lcMensajeAdicional = ""
					do case
						case empty( lcDescripcionDeEstadosDeSeleccion )
							lcMensajeAdicional = "no hay ningún estado de cheque disponible para selección."
						case occurs( ',', lcDescripcionDeEstadosDeSeleccion ) = 0
							lcMensajeAdicional = "sólo se pueden seleccionar cheques que tengan estado " + lcDescripcionDeEstadosDeSeleccion + "."
						otherwise
							lcMensajeAdicional = "sólo se pueden seleccionar cheques que tengan alguno de los siguientes estados: " + lcDescripcionDeEstadosDeSeleccion + "."
					endcase
					this.AgregarInformacion( "El estado actual del cheque seleccionado es '" ;
											+ alltrim( this.oColaboradorCheques.ObtenerDescripcion( this.oEntidad.Estado ) ) + "',";
											+ " por lo cual no puede utilizarse en éste tipo de comprobante" ;
											+ iif( this.LaEntidadPadreTieneUnConceptoConEstadoCargado(), " mediante el concepto " + alltrim( this.oEntidadPadre.Concepto_pk ), "" ) ;
											+ "." ;
											+ chr(10) + chr(13) ;
											+ "Para la información ingresada hasta el momento en ésta operación " + lcMensajeAdicional )
					loEx = Newobject( 'ZooException', 'ZooException.prg' )
					loEx.oInformacion = this.ObtenerInformacion()
					loEx.Throw()
				endif

			else
				this.AgregarInformacion( " El cheque seleccionado ya fue utilizado en " + this.oEntidad.ObtenerDescripcionDeUltimoAfectante() )
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				loEx.oInformacion = this.ObtenerInformacion()
				loEx.Throw()
			endif
		endif
	endfunc		

   	*-----------------------------------------------------------------------------------------
	protected function GenerarCheques( toRetorno as zoocoleccion OF zoocoleccion.prg ) as zoocoleccion OF zoocoleccion.prg
		local  loCheque  as object, loRetorno as zoocoleccion OF zoocoleccion.prg
	 	loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )

		for each loCheque in this.oCheques foxobject
			if empty( loCheque.Codigo )
				toRetorno = this.GenerarCheque( loCheque, loRetorno, 0)
			endif
		endfor

		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarObjetoCheque( tcNumeroCheque as String ) as Object
		local loCheque as Object, loEntidad as Object, loUltimaInteraccion as Object, loDetalleCheque as Object

		loEntidad = _Screen.Zoo.InstanciarEntidad( "Cheque" )
		with loEntidad
			.Codigo = alltrim( tcNumeroCheque )
			loCheque = createobject( "empty" )
			addproperty( loCheque, "Codigo", loEntidad.Codigo )
			addproperty( loCheque, "ComprobanteOrigen", loEntidad.ComprobanteOrigen )
			addproperty( loCheque, "FechaPago", loEntidad.Fecha )
			addproperty( loCheque, "Monto", loEntidad.Monto )
			addproperty( loCheque, "PagueseA", loEntidad.PagueseA )
			addproperty( loCheque, "Leyenda", loEntidad.LeyendaEndoso )
			addproperty( loCheque, "CodigoVendedor", loEntidad.Vendedor )
			addproperty( loCheque, "NombreVendedor", "" )
			addproperty( loCheque, "SerieOrigen", loEntidad.SerieOrigen )
			addproperty( loCheque, "NombreLibrador", loEntidad.NombreLibrador )
			addproperty( loCheque, "LetraOrigen", loEntidad.LetraOrigen )
			addproperty( loCheque, "PuntoDeVentaOrigen", loEntidad.PuntoDeVentaOrigen )
			addproperty( loCheque, "NumeroOrigen", loEntidad.NumeroOrigen )
			addproperty( loCheque, "TipoDeComprobanteOrigen", loEntidad.TipoDeComprobanteOrigen )
			addproperty( loCheque, "SignoDeMovimientoOrigen", loEntidad.SignoDeMovimientoOrigen )
			addproperty( loCheque, "CodigoComprobanteOrigen", loEntidad.CodigoComprobanteOrigen )
			addproperty( loCheque, "Valor", loEntidad.Valor )
			addproperty( loCheque, "Tipo", loEntidad.Tipo )
			addproperty( loCheque, "Numero", loEntidad.Numero )
			addproperty( loCheque, "BDOrigen", loEntidad.BDOrigen )
			addproperty( loCheque, "AutorizacionAlfa", loEntidad.AutorizacionAlfa )			
			if this.nPais = 1
				addproperty( loCheque, "CodigoTributarioLibrador", loEntidad.CodigoTributarioLibrador )	
			else
				addproperty( loCheque, "CodigoTributarioLibradorRUT", loEntidad.CodigoTributarioLibradorRUT )
			endif
			addproperty( loCheque, "TelefonoLibrador", loEntidad.TelefonoLibrador )
			addproperty( loCheque, "EntidadFinancieraEndoso", loEntidad.EntidadFinanciera.Descripcion )
			addproperty( loCheque, "CtaADep", loEntidad.CuentaEndoso )
			addproperty( loCheque, "EntidadFinancieraCodigo", loEntidad.EntidadFinanciera_pk )
			addproperty( loCheque, "ComprobanteAfectante", alltrim( loEntidad.DescripcionTipoComprobanteAfectante + " " + loEntidad.ComprobanteAfectante  ) )

			addproperty( loCheque, "Tipo", loEntidad.Tipo )
			addproperty( loCheque, "Estado", loEntidad.Estado )

			loDetalleCheque = _Screen.zoo.crearobjeto( "zooColeccion" )
			loUltimaInteraccion = createobject( "empty" )
			addproperty( loUltimaInteraccion, "NroItem", iif( loEntidad.HistorialDetalle.Count = 0, 0, loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].NroItem ) )
			addproperty( loUltimaInteraccion, "Comprobante", iif( loEntidad.HistorialDetalle.Count = 0, "", loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Comprobante ) )
			addproperty( loUltimaInteraccion, "TipoDeComprobante", iif( loEntidad.HistorialDetalle.Count = 0, 0, loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].TipoDeComprobante ) )
			addproperty( loUltimaInteraccion, "Estado", iif( loEntidad.HistorialDetalle.Count = 0, "", loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Estado ) )
			addproperty( loUltimaInteraccion, "Tipo", iif( loEntidad.HistorialDetalle.Count = 0, 0, loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Tipo ) )
			loDetalleCheque.Agregar( loUltimaInteraccion )
			addproperty( loCheque, "HistorialDetalle", loDetalleCheque )

			.Release()
		endwith

		return loCheque
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarCheque( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg, toItem as object ) as void
		with this.oEntidad
			.Codigo = toItem.NumeroCheque_PK
			toCheque.Codigo = .Codigo
			toCheque.NumeroCheque = .Numero
			toCheque.AutorizacionAlfa = .AutorizacionAlfa
			toCheque.Fecha = .Fecha
			toCheque.FechaEmision = .FechaEmision
			toCheque.EntidadFinanciera = .EntidadFinanciera_PK
			toCheque.NombreLibrador = .NombreLibrador
			if this.nPais = 1
				toCheque.CodigoTributarioLibrador = .CodigoTributarioLibrador
			else
				toCheque.CodigoTributarioLibradorRUT = .CodigoTributarioLibradorRUT
			endif
			toCheque.TelefonoLibrador = .TelefonoLibrador
			toCheque.Valor = .Valor
			toCheque.Monto = .Monto
			toCheque.Vendedor = .Vendedor
			toCheque.nroItem = toItem.nroItem
			toCheque.Moneda = .Moneda_PK
			toCheque.Tipo = toItem.Tipo
			toCheque.Accion = iif(.HistorialDetalle.Count = 1, ESTADOINGRESADO, ESTADOSELECCIONADO )
			toCheque.Observacion = .Observacion
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ModificarCheques() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lnIndCH as Integer, loItem as Object ,;
			lcDetalle as String, loItem as object
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		with this
			for lnIndCH = 1 to .oDetalleAnterior.count 
				loItem = this.ObtenerItemAsociadoACheque(.oDetalleAnterior, lnIndCH)
				if this.EsValorTipoChequeDeTerceros( loItem.Tipo ) and !this.EstaEnDetalle( loItem, .oDetallePadre )
					.AgregarSententiciasEliminarCheque(loItem.NumeroCheque_pk, loRetorno )
				endif
			endfor

			for lnIndCH = 1 to .oDetallePadre.count 
				loItem = .oDetallePadre.Item(lnIndCH)
				if this.EsValorTipoChequeDeTerceros( loItem.Tipo ) and (!this.oEntidadPadre.EsComprobanteDeCaja() or this.ExisteChequeAsociadoAlValor( loItem ))
					loCheque = this.BuscarEnoColCheque( loItem.NroItem )
					if !this.EstaEnDetalle( loItem, .oDetalleAnterior )
						loRetorno = .GenerarCheque( loCheque, loRetorno, 0 )
					else
						loRetorno = .ModificarUnCheque( loCheque, loRetorno)
					endif	
				endif
			endfor
		
		endwith
		
		return loRetorno
	endfunc 

   	*-----------------------------------------------------------------------------------------
	protected function ModificarUnCheque( toCheque as Componente_ItemDatosCheque of ComponenteChequesDeTerceros.prg, toRetorno as object ) as zoocoleccion OF zoocoleccion.prg 
		local loItem as object, loError as Exception && loDetalle  as string, loItemValor as object, 
		with this
			loItem = this.ObtenerItemAsociadoACheque( this.oDetallePadre, toCheque.NroItem )
			if !this.EsValorTipoChequeDeTerceros( loItem.Tipo )
				goServicios.Errores.LevantarExcepcion( "Error en los datos de los cheques. Verifique los valores" )
			endif

			with .oEntidad
				
				try
					.codigo = toCheque.codigo
					.modificar()
					
					*** Datos cargados por el usuario
					.Fecha = toCheque.Fecha
					.FechaEmision = toCheque.FechaEmision					
					.Numero = toCheque.NumeroCheque
					.EntidadFinanciera_PK = toCheque.EntidadFinanciera
					
					this.ActualizarCodigoTributarioLibrador( toCheque )
					
					.Vendedor = this.oEntidadPadre.Vendedor_Pk
					.cliente_pk = this.oEntidadPadre.cliente_pk
					*** Datos asociados al item
					.Monto = abs( loItem.Monto )
				
					if pemstatus( this.oEntidad, "Observacion" ,5 )	
						.Observacion = toCheque.Observacion
					endif
						
					if empty( .Moneda_PK )
						.Moneda_PK = this.ObtenerMonedaEnValor( loItem.Valor_PK )
					endif
					
					if .Validar()
						this.LlenarColeccionSentencias( .ObtenerSentenciasUpdate( ), toRetorno )
					else
						goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
					endif
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.Cancelar()
				endtry
				
			endwith
		endwith
		
		return toRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ReinicializarComponenteEspecifico() as Void
		if type( "this.oCheques" ) = "O" and !isnull( this.oCheques )
			this.oCheques.Release()
		endif
		this.oCheques = _Screen.zoo.crearobjeto( "zooColeccion" )

	endfunc

 	*-----------------------------------------------------------------------------------------
	protected function EsUnItemModificable( toItem ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if type( "toItem" ) = "O" and !isnull( toItem )
			llRetorno = empty( toItem.NumeroCheque_PK ) or !this.ExistenInteraccionesPosterioresALasDelComprobante( toItem.NumeroCheque.HistorialDetalle, this.ObtenerCodigoDeComprobante() )
		Endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarLosDatosDeCancelacionEnLosChequesUtilizadosEnElComprobante() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcIdCheque as String, loDetalle as Object, loItem as Object, lcMoneda as String, ;
			ldFecha as Date, lnCaja as Integer, loSentenciasUpdate as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.CrearObjeto( "Zoocoleccion" )	
		for each lcIdCheque in this.oChequesADarDeBajaDeLaCartera
			with this.oEntidad as din_EntidadCheque of din_EntidadCheque.prg
				.Codigo = lcIdCheque 
				.Modificar()

				if this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Buscar( lcIdCheque  )
					this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Quitar( lcIdCheque )
				endif

				lnCaja = 0
				loDetalle = this.oDetallePadre
				for each loItem in loDetalle
					if loItem.NumeroCheque_pk = lcIdCheque
						lcMoneda = this.ObtenerMonedaEnValor( loItem.Valor_PK )
						if pemstatus( loItem, "Caja_PK", 5 )
							lnCaja = loItem.Caja_PK
						endif
						exit
					endif
				endfor

				if empty( .Moneda_PK )
					.Moneda_PK = lcMoneda
				endif
				
				if !this.YaExisteUnaInteraccionParaElComprobante( .HistorialDetalle, this.ObtenerCodigoDeComprobante() )
					if this.SeEstaGenerandoUnContraComprobanteDeCaja()
						this.GenerarInteraccionFakeSoloParaAumentarElNroItem( lnCaja )
					endif

					this.GenerarInteraccionEnElHistorialDelCheque( lnCaja )
				endif

				loSentenciasUpdate = .ObtenerSentenciasUpdate()
				if this.SeEstaGenerandoUnContraComprobanteDeCaja()
					loSentenciasUpdate = this.ModificarSentenciasPorSerContraComprobanteDeCaja( loSentenciasUpdate )
				endif
				this.AgregarSentencias( loSentenciasUpdate, loRetorno )
				.Cancelar()
			endwith
		endfor
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstaEnDetalle( toItem as Object, toDetalle as Object ) as boolean
		local lnIndCH as Integer, llRetorno as Boolean
		llRetorno = .f.
		if !empty(toItem.NumeroCheque_pk)
			for lnIndCH = 1 to toDetalle.count
				 if this.EsValorTipoChequeDeTerceros( toDetalle.Item[lnIndCH].Tipo ) and toDetalle.item[lnIndCH].NumeroCheque_pk = toItem.NumeroCheque_pk
				 	llRetorno = .t.
				 	exit
				 endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDeCajaUsandoCarteraDeCheques( toEntidad as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean, loDetalle as Collection, lnEstado as Integer
		llRetorno = this.lUtilizarCarteraDeCheque
		if toEntidad.EsComprobanteDeCaja()
			loDetalle = toEntidad.ObtenerDetalleDeValores()
			if loDetalle.Count > 0
				lnEstado = loDetalle.ObtenerTipoDeUsoDeChequesDeTerceros()
				if lnEstado > 0
					llRetorno = lnEstado = ESTADOSELECCIONADO
				endif
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AnularOEliminarCheques() As zoocoleccion Of zoocoleccion.prg
		return This.EliminarCheques()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EliminarCheques() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lnIndCH as Integer, ;
			lcDetalle as String, loItem as object
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		with this
			for lnIndCH = 1 to .oDetallePadre.count 
				loItem = this.ObtenerItemAsociadoACheque(.oDetallePadre,lnIndCH)
				if this.EsValorTipoChequeDeTerceros( loItem.Tipo )
					.AgregarSententiciasEliminarCheque( .oDetallePadre.Item( lnIndCH ).NumeroCheque_pk, loRetorno )
				endif
			endfor
		endwith
		return loRetorno
	endfunc

  	*-----------------------------------------------------------------------------------------
	function AgregarSententiciasEliminarCheque( tcNumeroCheque as String, toRetorno as object ) as void
		local lcDetalle  as string, lnNroItem as Integer
		with this
			.oentidad.codigo = tcNumeroCheque
			lnNroItem = 1
			for each loItem in This.oEntidad.HistorialDetalle foxobject
				if loItem.CodigoComprobante = this.ObtenerCodigoDeComprobante()
					lnNroItem = loItem.NroItem
					exit
				endif
			endfor
			if lnNroItem <> 1
				goServicios.Errores.LevantarExcepcion( "No puede modificar el cheque porque tiene movimientos posteriores." )
			endif

			if .oEntidad.Tipo = TIPOVALORCIRCUITOCHEQUETERCERO
				if .oEntidad.HistorialDetalle.Count < 2
					.LlenarColeccionSentencias( .oEntidad.ObtenerSentenciasDelete( ), toRetorno )
				endif
			else
				.LlenarColeccionSentencias( .oEntidad.ObtenerSentenciasDelete( ), toRetorno )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVotoAnular() as Boolean
		local llRetorno as Boolean, lnIndCH as Integer, loCheque as din_entidadCheque of din_entidadCheque.prg

		with this
			llRetorno = .t.
			for lnIndCH = 1 to .oDetallePadre.count
				if this.EsValorTipoChequeDeTerceros( .oDetallePadre.Item[lnIndCH].Tipo )
					if .ValidarChequeActivo( .oDetallePadre.Item(lnIndCH).NumeroCheque_pk )
						loCheque = .ArmarObjetoCheque( .oDetallePadre.Item(lnIndCH).NumeroCheque_pk ) 
						.Agregarinformacion( "Cheque número: " + alltrim( .oDetallePadre.Item(lnIndCH).NumeroInterno ) +;
						" - Monto: " + transform( loCheque.Monto ) + " - Entidad Financiera: " + alltrim( loCheque.EntidadFinancieraCodigo ) + ;
						" - Comprobante: " + alltrim( loCheque.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Comprobante ) )
						loCheque = null
						llRetorno = .f.
					endif
				endif 
			endfor 

		endwith

		if !llRetorno
			this.AgregarInformacion( "No se puede anular el comprobante ya que incluye al menos un valor del tipo Cheque afectado por otra operación." )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarQueNoSeEsteCancelandoUnChequeCancelado() as Boolean
		local llRetorno as Boolean, lcIdCheque as String
		llRetorno = .t.
		for each lcIdCheque in this.oChequesADarDeBajaDeLaCartera foxobject

			this.oEntidad.Codigo = lcIdCheque

			if !this.YaExisteUnaInteraccionParaElComprobante( this.oEntidad.HistorialDetalle, this.ObtenerCodigoDeComprobante() )
				if !this.oColaboradorCheques.ValidarEstadoDeChequeSeleccionadoSegunEstadoDestino( this.oEntidadPadre, this.oEntidad.Estado, this.oEntidad.Tipo, this.ObtenerNombreDetallePadre() )
					llRetorno = .f.
					this.AgregarInformacion( "El estado del cheque " + this.oEntidad.ObtenerStringDeNumeroInterno() + " [" ;
											+ alltrim( this.oColaboradorCheques.ObtenerDescripcion( this.oEntidad.Estado ) ) + "]";
											+ " hace que no pueda ser utilizado en éste tipo de comprobante" ;
											+ iif( this.LaEntidadPadreTieneUnConceptoConEstadoCargado(), " mediante el concepto " + alltrim( this.oEntidadPadre.Concepto_pk ), "" ) ;
											+ "." )
				endif
			endif
		endfor
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarDatosDeChequeEnItem( toItem as object, tcIdCheque as String ) as Void
		this.AsignarMontoORecibido( toItem, this.oEntidad.Monto )
		with toItem
			.lCargando = .t.
			.NumeroInterno = padl( transform( this.oEntidad.PuntoDeVenta ), 4, "0" ) + "-" + padl( transform( this.oEntidad.NumeroC ), 8, "0" )
			if this.MostrarNumeroCheque()
				.cEtiquetaNumeroCheque = this.ObtenerStringNumeroCheque( this.oEntidad.Numero )
			endif 
			.lCargando = .f.
			.NumeroCheque_pk = tcIdCheque 
			.Fecha = this.oEntidad.Fecha
			if pemstatus( toItem, "ChequeElectronico", 5 ) and pemstatus( this.oEntidad, "ChequeElectronico", 5 )
				.ChequeElectronico = this.oEntidad.ChequeElectronico 
			endif
			if .Tipo = TIPOVALORCIRCUITOCHEQUETERCERO and !this.oColaboradorCheques.EsComprobanteDeCajaGeneradoPorAceptacionDeValoresEnTransito( this.oEntidadPadre )
				.lHabilitarCaja_PK = .T.
				.Caja_PK = this.ObtenerCajaDelCheque( tcIdCheque )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarEntidad() as boolean
		local llOk as Boolean
		llOk = dodefault()
		llOk = llOk or this.oEntidadPadre.EsComprobanteDeCaja()
		if !llOk
			If Pemstatus( This.oEntidadPadre, "cComprobante", 5 ) And Type( "this.oEntidadPadre.cComprobante" ) = "C"
				llOk = .T.
				Do Case
				Case This.oEntidadPadre.cComprobante == "FACTURADECOMPRA"
				Case This.oEntidadPadre.cComprobante == "NOTADECREDITOCOMPRA"
				Case This.oEntidadPadre.cComprobante == "NOTADEDEBITOCOMPRA"
				Case This.oEntidadPadre.cComprobante == "ORDENDEPAGO"
				Case This.oEntidadPadre.cComprobante == "RECIBO"			
				Case This.oEntidadPadre.cComprobante == "PAGO"
				Case This.oEntidadPadre.cComprobante == "COMPROBANTEPAGO"
				Otherwise
					llOk = .F.
				Endcase
			endif
		endif
		return llOk
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCargaEntidad( toCheque as entidad OF entidad.prg ) as boolean
		local llRetorno as boolean, llCargoMonto as Boolean

		llCargoMonto = .f.
		
		if empty( toCheque.Monto )
			llCargoMonto = .t.
			toCheque.Monto = 0.01
		endif
		
		llRetorno = toCheque.Validar()

		if llCargoMonto
			toCheque.Monto = 0
		endif

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function MarcarItemSiEsChequeElectronico( toItem as object )
		if pemstatus(toItem.Valor, "ChequeElectronico", 5)
			toItem.ChequeElectronico =  toItem.Valor.ChequeElectronico
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoCheque( toItem as object ) as Componente_ItemDatosCheque of ComponenteCheques.prg
		local loRetorno as Componente_ItemDatosCheque of ComponenteCheques.prg
		if type( "toItem" ) = "O" and !isnull( toItem ) and this.oCheques.Buscar( transform( toItem.NroItem ) )
			loRetorno = this.oCheques.Item[ transform( toItem.NroItem ) ]
		else
			loRetorno  = newobject( "Componente_ItemDatosCheque", "ComponenteChequesDeTerceros.prg" )
			if type( "toItem" ) = "O" and !isnull( toItem )
				with loRetorno
					.NroItem = toItem.NroItem
					if !isnull(this.oEntidadPadre.oLibradorDeCheque)
						this.SetearCodigoTributario( loRetorno )
						.NombreLibrador = this.oEntidadPadre.oLibradorDeCheque.Nombre
						.TelefonoLibrador = this.oEntidadPadre.oLibradorDeCheque.Telefono
					endif
					if !toItem.ChequeElectronico
						if toItem.FechaComp = goServicios.Librerias.ObtenerFecha()
							.Fecha = toItem.FechaComp + 1
						else
							if empty(toItem.FechaComp)
								if this.oEntidadPadre.Fecha = goServicios.Librerias.ObtenerFecha()
									.Fecha = this.oEntidadPadre.Fecha + 1
								else
									.Fecha = this.oEntidadPadre.Fecha
								endif
							else
								.Fecha = toItem.FechaComp
							endif
						endif
						.FechaEmision = this.oEntidadPadre.Fecha
					endif
					.Valor = toItem.Valor_PK
					.Tipo = toItem.Valor.tipo
					.CuitCliente = this.ObtenerCuitCliente( toItem )
					.LeyendaEndoso = toItem.Valor.Leyenda
					.CuentaEndoso = toItem.Valor.CtaCteADep
					.EntidadFinancieraEndoso = toItem.Valor.BcoADep_Pk
					if "<VENTAS>" $ this.oEntidadPadre.ObtenerFuncionalidades()
						.Vendedor = This.oEntidadPadre.Vendedor_Pk
					endif
					.PagueseA = toItem.Valor.PagueseA
					.Moneda = toItem.Valor.SimboloMonetario_Pk
				endwith
				this.PreCargarCheque( loRetorno )
			endif
		endif
		loRetorno.lEnabled = This.EsUnItemModificable( toItem )
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function IngresarUnNuevoCheque( toItem ) as Void
		local loCheque as Object
		with this

			.MarcarItemSiEsChequeElectronico(toItem)
			loCheque = .ObtenerObjetoCheque( toItem )
			
			loCheque.Monto = this.ObtenerMontoORecibido( toItem )

			.EventoPedirCheque( loCheque )
			if empty( loCheque.NumeroCheque ) and !toItem.ChequeElectronico
			else
				if alltrim(toItem.NumeroInterno) == "+"
					toItem.NumeroInterno = space(len(toItem.NumeroInterno))
				endif
				
				if this.MostrarNumeroCheque()
					toItem.cEtiquetaNumeroCheque = this.ObtenerStringNumeroCheque( loCheque.NumeroCheque )
				endif
				
				if !empty( loCheque.DescripcionEntidadFinanciera )
					toItem.ValorDetalle = loCheque.DescripcionEntidadFinanciera
					toItem.valor.descripcion = loCheque.DescripcionEntidadFinanciera
				endif
				loCheque.Accion = ESTADOINGRESADO
				.AgregarCheque( loCheque, toItem.NroItem )

				toItem.Fecha = loCheque.Fecha
				this.AsignarMontoORecibido(toItem, loCheque.Monto)

				this.AsignarNumeroDeItemAlItemCero( toItem )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCheque( toDatos as Componente_ItemDatosCheque of ComponenteCheques.prg, tnNroItem as integer )
		if this.oCheques.Buscar( transform( tnNroItem ) )
		else
			this.oCheques.Agregar( toDatos, transform( tnNroItem ) )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta al hacer nuevo en la entidad
	function Reinicializar( tlLimpiar as Boolean ) as Void
		local llUtilizaCarteraDeCheques as Boolean
		llUtilizaCarteraDeCheques = this.LaEntidadDebeUtilizarLaCarteraDeChequesYDarlosDebaja( this.oEntidadPadre)
		if llUtilizaCarteraDeCheques or this.oEntidadPadre.EsComprobanteDeCaja()
			if type( "this.oChequesADarDeBajaDeLaCartera" ) = "O" and !isnull( this.oChequesADarDeBajaDeLaCartera )
				this.oChequesADarDeBajaDeLaCartera.Release()
			endif
			if type( "this.oChequesDadosDebajaDeLaCarteraAntesDeModificar " ) = "O" and !isnull( this.oChequesDadosDebajaDeLaCarteraAntesDeModificar )
				this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Release()
			endif			
			this.oChequesADarDeBajaDeLaCartera = _Screen.zoo.crearobjeto( "zooColeccion" )
			this.oChequesDadosDebajaDeLaCarteraAntesDeModificar = _Screen.zoo.crearobjeto( "zooColeccion" )
		endif
		if !llUtilizaCarteraDeCheques or this.oEntidadPadre.EsComprobanteDeCaja()
			if type( "this.oCheques" ) = "O" and !isnull( this.oCheques)
				this.oCheques.Release()
			endif
			this.oCheques = _Screen.zoo.crearobjeto( "zooColeccion" )
		endif
		if !tlLimpiar
			for each loItem in This.oDetalleAnterior foxobject
				if (!llUtilizaCarteraDeCheques or (this.oEntidadPadre.EsComprobanteDeCaja() and inlist(loItem.Tipo,TIPOVALORCHEQUETERCERO,TIPOVALORCIRCUITOCHEQUETERCERO))) and this.EsValorTipoChequeDeTerceros( loItem.Tipo ) and !empty( loItem.Valor_PK ) and !empty( loItem.NumeroCheque_PK )
					this.lUtilizarCarteraDeCheque = .f.
					loCheque = this.ObtenerObjetoCheque()
					this.CargarCheque( loCheque, loItem )		
					this.AgregarCheque( loCheque, loItem.NroItem )
				endif
				if (llUtilizaCarteraDeCheques or (this.oEntidadPadre.EsComprobanteDeCaja() and loItem.Tipo == TIPOVALORCIRCUITOCHEQUETERCERO)) and this.EsValorTipoChequeDeTerceros( loItem.Tipo ) and !empty( loItem.Valor_PK ) and !empty( loItem.NumeroCheque_PK )
					this.lUtilizarCarteraDeCheque = .t.
					this.oChequesADarDeBajaDeLaCartera.Agregar( loItem.NumeroCheque_PK, loItem.NumeroCheque_PK )
					this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Agregar( loItem.NumeroCheque_PK, loItem.NumeroCheque_PK )
				endif
			endfor
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeSetearAtributo( toItemValor as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
		local lcMensaje as String 
		if empty( toItemValor.NumeroCheque_PK ) or This.oEntidadPadre.VerificarContexto( "BC" )
			if upper( tcAtributo ) == "VALOR_PK" and !Empty( txValOld  ) 
				this.Removerdatossicambiotipo( toItemValor )
			endif 
		else
			do Case
				case this.DebeUtilizarCarteraDecheque()
					&& Controlodo
					if upper( tcAtributo ) == "MONTO"
						if this.ValidarAfectacionDelItem( toItemValor, this.ObtenerCodigoDeComprobante() )

							goServicios.Errores.LevantarExcepcionTexto( "No se puede modificar el monto del cheque desde este comprobante." )
						endif
					endif 	
					if upper( tcAtributo ) == "VALOR_PK" and txValOld != txVal 
						this.Removerdatossicambiotipo( toItemValor )	
					endif 				
					if upper( tcAtributo ) == "NUMEROINTERNO" and !empty( txValOld ) and empty( txVal )
						this.RemoverDatosSiCambioTipo( toItemValor )	
					endif

				case ( upper( tcAtributo ) == "NUMEROCHEQUE_PK" and empty( txValOld ) ) or upper( tcAtributo ) == "CONDICIONRECARGO"
					&& CONTROLADO	
				case upper( tcAtributo ) == "VALOR_PK"
					if this.ValidarAfectacionDelItem( toItemValor, this.ObtenerCodigoDeComprobante() )
						toItemValor.&tcAtributo. = txValOld
						lcMensaje = "Cheque afectado por " + this.oEntidad.ObtenerDescripcionDeUltimoAfectante( toItemValor.numerocheque )
						goServicios.Errores.LevantarExcepcionTexto( "No se puede modificar/eliminar un valor afectado a otro comprobante."+ chr(13)+ lcmensaje )
					else 
						if txValOld != txVal 
							this.Removerdatossicambiotipo( toItemValor )	
						endif 	
					endif
					
				case empty( toItemValor.Valor_pk )
					&& Esta Limpiando el Item
				otherwise
					if this.ValidarAfectacionDelItem( toItemValor, this.ObtenerCodigoDeComprobante() )
						toItemValor.&tcAtributo. = txValOld
						lcMensaje = "Cheque afectado por " + this.oEntidad.ObtenerDescripcionDeUltimoAfectante( toItemValor.numerocheque )
						goServicios.Errores.LevantarExcepcionTexto( "No se pueden modificar los valores del cheque." + chr(13)+ lcmensaje)
					endif
			EndCase
		Endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function AsignarNumeroDeItemAlItemCero( toItem as object ) as Void
		local loItem as object
		if this.oCheques.Buscar( "0" )
			loItem = this.oCheques.Item[ "0" ]
			this.oCheques.Quitar( "0" )

			loItem.NroItem = toItem.NroItem

			this.AgregarCheque( loItem, transform( toItem.NroItem ) )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarInteraccionEnElHistorialDelCheque( tnCaja as Integer ) as Void
		local lcEstado as String
		lcEstado = ""

		with this.oEntidad.HistorialDetalle
			.LimpiarItem()
			.oItem.Fecha = this.oEntidadPadre.FechaAltaFW
			.oItem.Hora = this.oEntidadPadre.HoraAltaFW
			.oItem.IdentificadorEntidadComprobante = upper( This.oEntidadPadre.obtenerIdentificadorDeComprobante( This.oEntidadPadre.TipoComprobante ) )
			.oItem.CodigoComprobante = this.ObtenerCodigoDeComprobante()
			.oItem.TipoDeComprobante = This.oEntidadPadre.TipoComprobante
			this.SetearDatosAlItemActivoDelHistorialSegunEntidadPadre()
			if pemstatus( this.oEntidadPadre, "Concepto_PK", 5 )
				.oItem.Concepto_PK = this.oEntidadPadre.Concepto_PK
				.oItem.ConceptoDetalle = this.oEntidadPadre.Concepto.Descripcion
			endif
			.oItem.Serie = _screen.zoo.app.cSerie
			.oItem.Version = _screen.zoo.app.ObtenerVersion()
			.oItem.BaseDeOrigen = _screen.zoo.app.cSucursalActiva
			if this.oEntidadPadre.ccomprobante = "DESCARGACHEQUE"
				.oItem.DestinoDeDescarga_PK = this.oEntidadPadre.DestinoDescarga_pk
				.oItem.DestinoDeDescargaDescripcion = this.oEntidadPadre.DestinoDescarga.Descripcion
			endif
			if pemstatus( this.oEntidadPadre, "Vendedor_PK", 5 )
				.oItem.Vendedor = this.oEntidadPadre.Vendedor_PK
				.oItem.VendedorDescripcion = this.oEntidadPadre.Vendedor.Nombre
			endif

			lcEstado = this.oColaboradorCheques.ObtenerEstadoDestinoParaElCheque( This.oEntidadPadre, this.oEntidad.Tipo, this.ObtenerNombreDetallePadre(), this.oEntidad.HistorialDetalle )
			.oItem.Estado = lcEstado

			.oItem.Tipo = this.oColaboradorCheques.ObtenerTipoMovimiento( .oItem.Estado )

			if .oItem.Tipo <> 0 and this.oEntidad.Tipo = TIPOVALORCIRCUITOCHEQUETERCERO
				.oItem.CajaEstado = tnCaja
				.oItem.CajaEstadoDetalle = goCaja.ObtenerDescripcionDeCaja( .oItem.CajaEstado )
			endif

			.Actualizar()

			this.oEntidad.Estado = lcEstado
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreCargarCheque( toCheque as Object ) as Void
		local lcPropiedad as String, lcPropiedadMemo as String, lnI as Integer, loColAtributos as zoocoleccion OF zoocoleccion.prg, loItem as Object

		llPrimerCheque = vartype( this.oCheques ) # "O" or isnull( this.oCheques ) or this.oCheques.Count = 0
		this.oClonadorDeCheques.PreCargarCheque( toCheque, llPrimerCheque )

	endfunc 
		
	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function RemoverDatosSiCambioTipo( toItem as Object ) as Void
		local llHabilitarNumInt as Boolean 
		if this.DebeUtilizarCarteraDecheque()
			if this.oChequesADarDeBajaDeLaCartera.Buscar( toItem.NumeroCheque_PK )
				this.oChequesADarDeBajaDeLaCartera.Quitar( toItem.NumeroCheque_PK )
				toItem.NumeroCheque_PK = ""
				if pemstatus( toItem, "lHabilitarNumeroInterno", 5 )
					llHabilitarNumInt = toItem.lHabilitarNumeroInterno
					toItem.lHabilitarNumeroInterno = .t.
					toItem.NumeroInterno = ""
					toItem.lHabilitarNumeroInterno = llHabilitarNumInt
				endif
				This.RestaurarFechaComprobante( toItem )
			endif
		else
			if this.oCheques.Buscar( transform( toItem.NroItem ) )
				this.oCheques.Quitar( transform( toItem.NroItem ) )
				toItem.NumeroCheque_PK = ""
			endif
		endif
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function GenerarInteraccionFakeSoloParaAumentarElNroItem( tnCaja as Integer ) as Void
		this.GenerarInteraccionEnElHistorialDelCheque( tnCaja )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LaEntidadDebeUtilizarLaCarteraDeChequesYDarlosDebaja( toEntidad as entidad OF entidad.prg ) as Boolean
		local lcNombre as String, llRetorno as Boolean, loEntidad as Entidad of Entidad.prg
		llRetorno = .f.
		if type( "toEntidad" ) = "O" and !isnull( toEntidad )
			loEntidad = toEntidad
		else
			loEntidad = this.oEntidadPadre
		endif
		if pemstatus( loEntidad, "cComprobante", 5 ) and type( "loEntidad.cComprobante" ) = "C"
			lcNombre = upper( toEntidad.cComprobante )
			if inlist( lcNombre, "FACTURADECOMPRA", "ORDENDEPAGO", "COMPROBANTEPAGO", "NOTADECREDITO", "NOTADECREDITOELECTRONICA", "TICKETNOTADECREDITO", "NOTADEDEBITOCOMPRA", "PAGO" ) ;
			 or this.EsCanjeDeCuponesUsandoCarteraDeCheques( loEntidad ) or this.EsComprobanteDeCajaUsandoCarteraDeCheques( loEntidad )
				llRetorno = .t.
			endif
		endif
 		return llRetorno
	endfunc 

  	*-----------------------------------------------------------------------------------------
	protected function CargarDatosDeCancelacionEnLosCheques() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.CrearObjeto( "Zoocoleccion" )
		if this.oEntidadPadre.lAnular or ( this.oEntidadPadre.cNombre = "COMPROBANTEDECAJA" and !this.oEntidadPadre.lNuevo and !this.oEntidadPadre.lEdicion )
			this.oChequesADarDeBajaDeLaCartera.Remove( -1 )
		endif

		if this.oEntidadPadre.cNombre = "COMPROBANTEDECAJA"
			for lnIndCH = 1 to this.oDetalleAnterior.count 
				loItem = this.ObtenerItemAsociadoACheque(this.oDetalleAnterior, lnIndCH)
				if this.EsValorTipoChequeDeTerceros( loItem.Tipo ) and !this.EstaEnDetalle( loItem, this.oDetallePadre )
					this.AgregarSententiciasEliminarCheque(loItem.NumeroCheque_pk, loRetorno )
				endif
			endfor
		endif

		this.AgregarSentencias( this.CargarLosDatosDeCancelacionEnLosChequesUtilizadosEnElComprobante(), loRetorno )
		this.AgregarSentencias( this.LimpiarDatosDeCancelacionEnLosChequesQueFueronRemovidosDelComprobante(), loRetorno )

		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarChequeAsociado( toItem as Object ) as Boolean 
		local llRetorno as Boolean 
		llRetorno = .t.
		if (toItem.Tipo = TIPOVALORCIRCUITOCHEQUETERCERO) or (toItem.Tipo = TIPOVALORCHEQUETERCERO and !this.oEntidadPadre.EsComprobanteDeCaja())
			if this.oCheques.Buscar( transform( toItem.NroItem ) )
			else
				llRetorno = .f.
			endif
		endif
		return llRetorno
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreClonadorDeCheques() as String
		local lcRetorno as String

		if this.nPais = 2
			lcRetorno = "ClonadorChequesChile"
		else
			lcRetorno = "ClonadorChequesArgentina"
		endif
		
		return lcRetorno
	endfunc 

	*---------------------------------------------------------------------------------
	function oClonadorDeCheques_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oClonadorDeCheques ) = 'O' or isnull( this.oClonadorDeCheques )
				this.oClonadorDeCheques = this.ObtenerClonadorDeCheques()
			endif
		endif
		return this.oClonadorDeCheques
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarMemoriaCheque( toCheque as Componente_ItemDatosCheque ) as Void
		this.oClonadorDeCheques.ActualizarClonDelCheque( toCheque )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClonadorDeCheques() as Object
		local loRetorno as Object
		
		loRetorno = _Screen.Zoo.CrearObjeto( this.ObtenerNombreClonadorDeCheques() )
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsChequeIngresado( tnNroItem as Integer) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		for each loItem in this.oCheques
			if loItem.Nroitem = tnNroItem
				llRetorno = (loItem.Accion = ESTADOINGRESADO)
				exit
			endif
		next
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlDeChequesEnCartera( tnTipoValor as Integer ) as String
		local lcRetorno as String, lcXml as String, lcFiltroEstados as String 
		lcRetorno = "" 

		lcFiltroEstados = this.oColaboradorCheques.ObtenerCadenaEstadosDeSeleccionSegunEntidad( this.oEntidadPadre, tnTipoValor )
		if empty( lcFiltroEstados )
			lcFiltroEstados = "''"
		endif

		lcXml = this.oEntidad.ObtenerDatosEntidad( "", " tipo = " + str( tnTipoValor ) + " and estado in (" + lcFiltroEstados + ") " , "FECHAALTAFW, HORAALTAFW" )
		this.XmlACursor( lcXml, "c_ChequesDisponibles" )
		
		create cursor c_ChequesEnCartera ( idCheque C(38), NumeroInterno C(14), Numero N(8),;
			FechaOrigen D, FechaVto D, Importe N( 16,2 ), Banco C(5), FECHAALTAFW D, HORAALTAFW C(8) )
		select( "c_ChequesDisponibles" )
		scan
			insert into c_ChequesEnCartera ( idCheque, NumeroInterno, Numero, FechaOrigen, FechaVto, Importe, Banco, FECHAALTAFW, HORAALTAFW  ) ;
				values ( ;
				c_ChequesDisponibles.Codigo, ;
				padl( transform( c_ChequesDisponibles.PuntoDeVenta ),4 ,"0" ) + "-" + padl( transform( c_ChequesDisponibles.NumeroC ), 8, "0" ), ;
				c_ChequesDisponibles.Numero, ;
				c_ChequesDisponibles.FechaOrigen, ;
				c_ChequesDisponibles.FechaVencimiento, ;
				c_ChequesDisponibles.Monto, ;
				c_ChequesDisponibles.EntidadFinanciera, ;
				c_ChequesDisponibles.FECHAALTAFW, ;
				c_ChequesDisponibles.HORAALTAFW )
		endscan
		lcRetorno = this.CursorAXml( "c_ChequesEnCartera" )
		use in select( "c_ChequesEnCartera" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function DebeUtilizarCarteraDecheque() as Boolean
		Local llRetorno as Boolean, lnSigno as Integer
		if this.oEntidadPadre.EsComprobanteDeCaja()
			llRetorno = this.EsComprobanteDeCajaUsandoCarteraDeCheques( this.oEntidadPadre )
		else
			llRetorno = this.lUtilizarCarteraDeCheque
		endif
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarDatosDeCancelacionEnLosChequesQueFueronRemovidosDelComprobante() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcIdCheque as String
		loRetorno = dodefault()
		if vartype( this.oChequesDadosDebajaDeLaCarteraAntesDeModificar ) = "O"
			for each lcIdCheque in this.oChequesDadosDebajaDeLaCarteraAntesDeModificar
				with this.oEntidad as din_EntidadCheque of din_EntidadCheque.prg
					.Codigo = lcIdCheque 

					if this.ExistenInteraccionesPosterioresALasDelComprobante( .HistorialDetalle, this.ObtenerCodigoDeComprobante() )
						goServicios.Errores.LevantarExcepcion( "No puede modificar el cheque porque tiene movimientos posteriores." )
					endif

					.Modificar()
					this.EliminarInteraccionEnElHistorialDelCheque( .HistorialDetalle, this.ObtenerCodigoDeComprobante() )
					.Estado = this.ObtenerEstadoDeUltimaInteraccion( .HistorialDetalle )

					this.AgregarSentencias( .ObtenerSentenciasUpdate(), loRetorno )
					.Cancelar()
				endwith
			endfor
		endif
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearDatosChequeParaAPI( toCheque as Object, toDatos as Object, toItem as Object ) as Void
		toCheque.EntidadFinanciera = toDatos.EntidadFinanciera_PK		
		toCheque.DescripcionEntidadFinanciera = toDatos.EntidadFinanciera.Descripcion
		toCheque.NumeroCheque = toDatos.Numero
		toCheque.Fecha = toDatos.Fecha
		toCheque.FechaEmision = toDatos.FechaEmision
		toCheque.CodigoTributarioLibrador = toDatos.CodigoTributarioLibrador
		if empty( toDatos.Monto )
			toCheque.Monto = this.ObtenerMontoORecibido( toItem )
		else
			toCheque.Monto = toDatos.Monto
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabarEntidadPadre() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno and this.oEntidadPadre.cNombre == "PAGO"
			this.CargarDesdeElPagoLosValoresCircuitoChequeTercero()
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarDesdeElPagoLosValoresCircuitoChequeTercero() as Void
		local loItem as Object
		this.oChequesADarDeBajaDeLaCartera.Remove( -1 )
		this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Remove( -1 )
		for each loItem in this.oDetallePadre foxobject
			if loItem.Tipo = TIPOVALORCIRCUITOCHEQUETERCERO and !empty( loItem.Valor_PK ) and !empty( loItem.NumeroCheque_PK )
				this.oChequesADarDeBajaDeLaCartera.Agregar( loItem.NumeroCheque_PK, loItem.NumeroCheque_PK )
				this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Agregar( loItem.NumeroCheque_PK, loItem.NumeroCheque_PK )
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsChequeDeTercero( tnTipo as Integer ) as Boolean
		return tnTipo = TIPOVALORCHEQUETERCERO or tnTipo = TIPOVALORCIRCUITOCHEQUETERCERO
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAfectacionDelItem( toItem as Object, tcCodigoComprobanteAfectante as String ) as Boolean 
		local llRetorno as Boolean, loError as Object 
		try
			llRetorno = toItem.NumeroCheque.EstaAfectado( toItem.NumeroCheque_PK, tcCodigoComprobanteAfectante )
		catch to loError
			llRetorno = .f.
		endtry 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearYVerificarDatosUsandoLaCarteraDeCheques( toItem as ItemActivo of ItemActivo.Prg ) as Void
		local lcIdChequeSeleccionado as String, lcXmlCarteraDeCheques as String, lnCantidadDeChequesEnCartera as Integer, lcEstadosDeSeleccion as String, lcMensaje as String
		lcXmlCarteraDeCheques = this.ObtenerXmlDeChequesEnCartera( toItem.Tipo )
		this.XmlACursor( lcXmlCarteraDeCheques, "c_CarteraDeCheques" )
		lnCantidadDeChequesEnCartera = reccount( "c_CarteraDeCheques" )
		use in select( "c_CarteraDeCheques" )
		if lnCantidadDeChequesEnCartera == 0
			if this.EsValorTipoChequeDeTerceros( toItem.Tipo )
				lcEstadosDeSeleccion = this.oColaboradorCheques.ObtenerDescripcionDeEstadosDeSeleccionSegunEntidad( this.oEntidadPadre, toItem.Tipo, this.ObtenerNombreDetallePadre() )
				if empty( lcEstadosDeSeleccion )
					lcMensaje = "Para la información ingresada hasta el momento en ésta operación no hay ningún estado de cheque disponible de selección."
				else
					lcMensaje = "No existen cheques disponibles en la cartera con los siguientes estados: " + lcEstadosDeSeleccion
				endif
			else
				lcMensaje = "No existen cheques disponibles en la cartera."
			endif
			goServicios.Errores.LevantarExcepcion( lcMensaje )
		else
			lcIdChequeSeleccionado = this.ObtenerChequeDeCarteraAUtilizar( lcXmlCarteraDeCheques, toItem )
			this.AgregarChequeSelecionadoDeLaCartera( lcIdChequeSeleccionado, toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaDeUpdateDeCabecera( tcSentencia as String ) as Boolean
		return ( upper( substr( tcSentencia, 1, 6 ) ) = "UPDATE" and "ZOOLOGIC.CHEQUE " $ upper( tcSentencia ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaParaElHistorialDelContraComprobante( tcSentencia as String, tcIdentificadorDelComprobanteDeCaja as String ) as Boolean
		return ( "ZOOLOGIC.CHEQUEHIST" $ upper( tcSentencia ) and tcIdentificadorDelComprobanteDeCaja $ upper( tcSentencia ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDatosChequeElectronico( toCheque as object ) as Void
		local loColSentencias as Object, loError as Object, llEjecutoBegin as Boolean, lcMensaje as String 

		if this.ValidarIngresoNumeroChequeUnico(toCheque, toCheque.NumeroCheque)
			try
			
				this.EventoMensajeProcesando("Procesando")
				loColSentencias = this.ObtenerSentenciasUpdateChequeElectronico(toCheque)
				goservicios.datos.ejecutarsql( "BEGIN TRANSACTION", .f., this.dataSessionID )
				llEjecutoBegin = .T.
				for each lcSentencia in loColSentencias
					lcResultado = goServicios.Datos.EjecutarSQL( lcSentencia, .f., this.dataSessionID )
				endfor
				goServicios.Datos.EjecutarSQL( "COMMIT TRANSACTION", .f., this.dataSessionID )	
				
			catch to loError	
				if llEjecutoBegin
					goServicios.Datos.EjecutarSQL( "ROLLBACK TRANSACTION", .f., this.dataSessionID )
				endif
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				this.EventoFinMensajeProcesando()
			endtry	
		else
			lcMensaje = "El número de cheque " + transform( toCheque.NumeroCheque ) + " para la entidad financiera " + rtrim( toCheque.EntidadFinanciera ) + ;
						" - " + alltrim( toCheque.DescripcionEntidadFinanciera ) + " se encuentra duplicado."
			this.EventoMostrarMensajeChequeDuplicado(lcMensaje)	

		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasUpdateChequeElectronico( toCheque as object ) as object
		local loSentencias as Object, loRegistro as Object, lcSentencia as String, lcTabla as String, lcCampoNumeroChque as String, ;
		lcCampoCodigo as String,lcCampoFechaEmision as string, lcCampoFechaDePago as String, lcCodigo as string,;
		lcFechaEmision as date, lcFechaEmision as date, ldFecha as date, lcFecha as String lcHora as String, lcFechaEnBlanco as String
				
		loSentencias = _screen.zoo.CrearObjeto( "ZooColeccion" )
		with this.oEntidad
			lcTabla = .oAd.cEsquema + "." + .oAd.cTablaPrincipal

			lcCampoNumeroCheque = .oAd.ObtenerCampoEntidad( "Numero" )
			lcCampoFechaEmision = .oAd.ObtenerCampoEntidad( "FechaEmision" )
			lcCampoFechaDePago = .oAd.ObtenerCampoEntidad( "Fecha" )
			lcCampoCodigo = .oAd.ObtenerCampoEntidad( "Codigo" )
			
			ldFecha = goServicios.Librerias.ObtenerFecha()
			lcFecha = dtoc( ldFecha, 1 )
			lcHora = goServicios.Librerias.ObtenerHora()
			lcFechaEnBlanco = dtos( evaluate( goRegistry.Nucleo.FechaEnBlancoParaSQLServer ) )
			
			if !empty(toCheque.Codigo)
				lcNumeroCheque = toCheque.NumeroCheque
				lcFechaEmision = iif(empty(toCheque.FechaEmision), lcFechaEnBlanco ,toCheque.FechaEmision)
				lcFechaDePago = iif(empty(toCheque.Fecha), lcFechaEnBlanco ,toCheque.Fecha)
				lcCodigo = toCheque.Codigo
									
				text to lcSentencia noshow textmerge
					update <<lcTabla>> set <<lcCampoNumeroCheque >> = '<<lcNumeroCheque >>' , 
										   <<lcCampoFechaEmision >> = '<<lcFechaEmision >>',
											<<lcCampoFechaDePago >> = '<<lcFechaDePago >>',
											FModiFW = '<<lcFecha>>' , 
								   			HModiFW = '<<lcHora>>' , 
								   			UmodiFW = '<<goServicios.Seguridad.cUsuarioLogueado>>' , 
								   			SmodiFW = '<<_Screen.Zoo.App.cSerie>>' , 
								   			VmodiFW = '<<_screen.zoo.app.cVersionSegunIni>>' , 
								   			BDmodiFW = '<<_screen.zoo.app.cSucursalActiva>>'
					where <<lcCampoCodigo>> = '<<lcCodigo>>'
				endtext
				
				loSentencias.Agregar( lcSentencia )
			endif
		
		endwith
		return loSentencias
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeProcesando(tcMensaje as String) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinMensajeProcesando() as Void

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeChequeDuplicado(tcMensaje as String) as Void
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarIngresoNumeroChequeUnico(toCheque as object, tnNumeroCheque as Integer ) as boolean
		local lnNumeroCheque as Integer, llExistente as Boolean, lcCursor as String, lcXml as String 
		llExistente = .f. 
		********************************************************************************************************
		* Verificamos que todo cheque, en la coleccion de cheques, Sea unico en numero y entidad financiera
		********************************************************************************************************
		lnNumeroCheque = tnNumeroCheque
		if goServicios.Parametros.Felino.GestionDeVentas.ChequeDeTerceros.RestringirIngresoDeChequesDuplicados and lnNumeroCheque  !=0
			lcCursor = sys(2015)
			try
				lcXml = this.oEntidad.ObtenerDatosEntidad( "Codigo",  " Codigo != '" +  toCheque.Codigo  + "' and EntidadFinanciera = '" +  toCheque.EntidadFinanciera  + "'  and Numero = " + transform(lnNumeroCheque)  , "" )
				this.XmlACursor( lcXml, lcCursor )
				select (lcCursor)
				llExistente = (_Tally > 0)
				use in select (lcCursor)
			catch to loErr
			endtry
		endif

		return !llExistente
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define Class Componente_ItemDatosCheque as Custom

	Codigo = ""
	NumeroCheque = 0
	Monto = 0
	Tipo = 0
	Valor = ""
	Moneda = ""
	NroItem = 0
	Fecha = {}
	FechaEmision = {}
	CuitCliente = ""
	EntidadFinanciera = ""
	CodigoTributarioLibrador = ""
	CodigoTributarioLibradorRUT = ""
	TelefonoLibrador = ""
	NombreLibrador = ""
	AutorizacionAlfa = ""
	DescripcionEntidadFinanciera = ""
	EntidadFinancieraEndoso = ""
	CuentaEndoso = ""
	LeyendaEndoso = ""
	FechaEndoso = {}
	Vendedor = ""
	PagueseA = ""
	Estado = ""
	Accion = 0
	HistorialDetalle = null
	Observacion = ""

	lEnabled = .T.
	oInformacion = null

	*-----------------------------------------------------------------------------------------
	function oInformacion_Access() as Object
		if ( vartype( this.oInformacion ) != "O" or isnull( this.oInformacion ) )
			this.oInformacion = _Screen.zoo.crearobjeto( "zooInformacion", "zooInformacion.prg" )
		endif
		Return this.oInformacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		local loDetalleCheque as Object, loInteraccion as Object
		loDetalleCheque = _Screen.zoo.crearobjeto( "zooColeccion" )
		loInteraccion = createobject( "empty" )
		addproperty( loInteraccion, "NroItem", 0 )
		addproperty( loInteraccion, "Comprobante", "" )
		addproperty( loInteraccion, "TipoDeComprobante", 0 )
		addproperty( loInteraccion, "Estado", "" )
		addproperty( loInteraccion, "Tipo", 0 )
		loDetalleCheque.Agregar( loInteraccion )
		this.HistorialDetalle = loDetalleCheque		
	endfunc

EndDefine
