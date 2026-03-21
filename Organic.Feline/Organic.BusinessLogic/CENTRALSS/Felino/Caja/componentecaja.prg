define class ComponenteCaja as din_ComponenteCaja of din_ComponenteCaja.prg 

	#if .f.
		Local this as ComponenteCaja as ComponenteCaja.prg
	#endif

	#DEFINE NUEVALINEA chr(13) + chr(10)
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
	#define TIPOVALORAJUSTEDECUPON  		10

	nThisDataSession = 0
	oCajaEstado = Null
	oCajaSaldos = Null
	oCajaAuditoria = Null
	oMovimientosCaja = Null
	nDataSessionMovimientosCaja = 0	
	cComprobante = ""
	dFecha = {}
	nSignoDeMovimiento = 1
	nNumeroComp = 0
	nPuntoDeVenta = 0
	cSecuencia = ""
	nVueltoAnterior = 0
	cCodigoVueltoAnterior = ""
	nVueltoCotizado = 0
	nSignoDeMovimientoAnterior = 1
	oTipoDeValores = Null
	cComponenteAsociado = ""
	oValor = Null
	oColValoresComponentes = null
	oColSaldos = null
	cLeyendaFondoFijo = ""
	lGeneroComprobanteCaja = .t.
	oControlComprobantesFaltantes = null
	lYaGeneroContracomprobante = .F.
	lGeneroAjusteDeCupon = .t.
	llNoPermitirAperturaAutomaticaDeCaja = .f.
	oComprobantesYGruposCaja = null
	lGenerarReciboAplicandoCuponesHuerfanos = .f.
	nNumeroDeCajaActiva = 0
	nNumeroDeCajaEnProcesoDeCierre = 0
	lValidoCuponesElectronicos = .t.
	oFechaYHoraApertura = null
	oControlConcurrencia= null
	oDatosDelArqueoDeCaja = null
	
	*-----------------------------------------------------------------------------------------
	function oControlConcurrencia_Access() as Object

		if !this.lDestroy and !( vartype( this.oControlConcurrencia ) == "O" )
			this.oControlConcurrencia= _screen.Zoo.Crearobjeto( "ControlConcurrenciaCajas" )
		endif
		
		return this.oControlConcurrencia

	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as void
		dodefault()
		this.SetearNumeroDeCajaActivaSegunValorEnParametros()
	endfunc	

	*-----------------------------------------------------------------------------------------
	function SetearNumeroDeCajaActivaSegunValorEnParametros() as Void
		this.nNumeroDeCajaActiva = goParametros.Felino.GestionDeVentas.NumeroDeCaja
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarNumeroaEstadosDeCaja() as Void
		This.oCajaEstado.AsignarNumeroDeCajaaEstados( int ( goParametros.Felino.GestionDeVentas.NumeroDeCaja ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroDeCajaActiva() as Integer
		return this.nNumeroDeCajaActiva
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaApertura( tnNroCaja as Integer ) as Object
		local lcSentencia as string, lcNumeroCaja as String
				
		this.oFechaYHoraApertura = newobject( "fechaYHoraDeUltimaApertura", "componentecaja.prg" )
		lcNumeroCaja = str( tnNroCaja )
		lcSentencia = "select top 1 Caja.FALTAFW, Caja.HALTAFW from CajaAudi as Caja "
		lcSentencia = lcSentencia + "where Caja.TAREA = 'APERTURA' and Caja.NUMCAJA = " + lcNumeroCaja
		lcSentencia = lcSentencia + " order by Caja.CODIGO desc"
		goServicios.Datos.EjecutarSentencias( lcSentencia, "CajaAudi", , "c_FechaHora", this.DataSessionId)
		
		this.oFechaYHoraApertura.Fecha = ttod(c_FechaHora.FALTAFW)
		this.oFechaYHoraApertura.Hora = c_FechaHora.HALTAFW
		
		return this.oFechaYHoraApertura
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeAperturaAnterior( tnNroCaja as Integer, tnCantDias as Integer ) as Object
		local lcSentencia as string, lcNumeroCaja as String, lcCantidad as String
		*!* tnCantDias indica cuantas cajas hacia atras voy a buscar. Si tnCantDias = 0, busco la ultima caja.
		
		lcNumeroCaja = transform( tnNroCaja )
		lcCantidad = transform( 1 + iif( type( "tnCantDias" ) = "N", tnCantDias, 0 ) )
		
		this.oFechaYHoraApertura = newobject( "fechaYHoraDeUltimaApertura", "componentecaja.prg" )
		lcSentencia = "select top 1 FALTAFW, HALTAFW from ("
		lcSentencia = lcSentencia + "select top " + lcCantidad + " Caja.FALTAFW, Caja.HALTAFW, Caja.CODIGO "
		lcSentencia = lcSentencia + "from CajaAudi as Caja "
		lcSentencia = lcSentencia + "where Caja.TAREA = 'APERTURA' and Caja.NUMCAJA = " + lcNumeroCaja
		lcSentencia = lcSentencia + " order by Caja.CODIGO desc"
		lcSentencia = lcSentencia + ") as c order by CODIGO asc"
		
		goServicios.Datos.EjecutarSentencias( lcSentencia, "CajaAudi", , "c_FechaHora", this.DataSessionId)
		
		this.oFechaYHoraApertura.Fecha = ttod(c_FechaHora.FALTAFW)
		this.oFechaYHoraApertura.Hora = c_FechaHora.HALTAFW
		
		return this.oFechaYHoraApertura
	endfunc 

	*--------------------------------------------------------------------------------------------------------	
	function oControlComprobantesFaltantes_Access() as variant
		if !this.ldestroy and !vartype( this.oControlComprobantesFaltantes ) = 'O'
			local loControlComprobantesFaltantesFactory as Object
			loControlComprobantesFaltantesFactory = newobject( "ControlComprobantesFaltantesFactory", "ControlComprobantesFaltantesFactory.prg" )
			this.oControlComprobantesFaltantes = loControlComprobantesFaltantesFactory.ObtenerInstancia()
		endif
		return this.oControlComprobantesFaltantes
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oValor_Access() as variant
		if !this.ldestroy and !vartype( this.oValor ) = 'O'
			this.oValor = _Screen.zoo.Instanciarentidad( "Valor" )
			this.enlazar( 'oValor.EventoObtenerInformacion', 'inyectarInformacion' )
		endif
		return this.oValor
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oTipoDeValores_Access() as variant
		if !this.ldestroy and !vartype( this.oTipoDeValores ) = 'O'
			this.oTipoDeValores = _Screen.zoo.CrearObjeto( 'Din_TipoDeValores' )
		endif
		return this.oTipoDeValores
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oComprobantesYGruposCaja_Access() as variant
		if !this.ldestroy and !vartype( this.oComprobantesYGruposCaja ) = 'O'
			this.oComprobantesYGruposCaja = _Screen.zoo.CrearObjeto( 'Din_ComprobantesYGruposCaja' )
		endif
		return this.oComprobantesYGruposCaja
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oCajaEstado_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaEstado ) = 'O'
			this.oCajaEstado = _Screen.zoo.Instanciarentidad( "CajaEstado" )
			this.enlazar( 'oCajaEstado.EventoObtenerInformacion', 'inyectarInformacion' )
		endif
		return this.oCajaEstado
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oCajaSaldos_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaSaldos ) = 'O'
			this.oCajaSaldos = _Screen.zoo.Instanciarentidad( "CajaSaldos" )
			this.enlazar( 'oCajaSaldos.EventoObtenerInformacion', 'inyectarInformacion' )
		endif
		return this.oCajaSaldos
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oCajaAuditoria_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaAuditoria ) = 'O'
			this.oCajaAuditoria = _Screen.zoo.Instanciarentidad( "CajaAuditoria" )
			this.enlazar( 'oCajaAuditoria.EventoObtenerInformacion', 'inyectarInformacion' )			
		endif
		return this.oCajaAuditoria
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oMovimientosCaja_Access() as variant
		if !this.ldestroy and !vartype( this.oMovimientosCaja ) = 'O'
			this.oMovimientosCaja = _Screen.zoo.Instanciarentidad( "MovimientoDeCaja" )
			this.enlazar( 'oMovimientosCaja.EventoObtenerInformacion', 'inyectarInformacion' )
		endif
		return this.oMovimientosCaja
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerComponente( tnTipo as Integer) as String
		return This.oTipoDeValores.ObtenerComponente( tnTipo )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTodosLosComponentes() as zooColeccion of ZooColeccion.prg
		local lcXml as String, lcComponente as String

		if vartype( this.oColValoresComponentes ) != "O"
			this.oColValoresComponentes = _Screen.zoo.Crearobjeto( "ZooColeccion" )
			lcXml = This.oTipoDeValores.GenerarXmlTipoDeValores()
			This.XmlACursor( lcXml, "cValores" )
			select cValores
			scan
				lcComponente = alltrim( upper( This.ObtenerComponente( cValores.Codigo ) ) )
				if this.oColValoresComponentes.GetKey( lcComponente ) > 0
				Else
					this.oColValoresComponentes.Add( lcComponente,lcComponente )
				endif
				select cValores
			Endscan
			use in select( "cValores" )
		endif
		
		return this.oColValoresComponentes
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeProcesarElItem( tnTipo as Integer ) as Boolean
		return upper( alltrim( This.cComponenteAsociado ) ) == upper( alltrim( This.ObtenerComponente( tnTipo ) ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeProcesarVuelto() as Boolean
		This.oValor.Codigo = This.oEntidadPadre.ObtenerCodigoValorVuelto()
		return This.DebeProcesarElItem( This.oValor.Tipo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Abrir( tnCaja as Integer ) as Void
		local loCajaAuditoria as Object, lcMessage as String, loError as Object, loEx as Object, llHuboError as Boolean,;
			 lcMensajeInconsistencia as String

		lcMensajeInconsistencia = ""
		llHuboError = .F.
		lcMessage = ""
		if _Screen.Zoo.App.ObtenerValorReplicaBD()
			lcMessage = "No está permitido abrir cajas en bases de datos de réplica."
		Else
			try
				this.oCajaEstado.ID = tnCaja
				
				if this.EstaAbierta( tnCaja ) 
					lcMessage = "La caja nº " + transform( tnCaja ) + " ya se encuentra abierta."
				else
					with this.oCajaAuditoria
					
						.Nuevo()
						.CajaEstado_PK = tnCaja

						if !empty( this.oCajaEstado.IdCajaAuditoria )
							loCajaAuditoria = _screen.zoo.instanciarentidad( "CajaAuditoria" )
							try
								try
									loCajaAuditoria.id = this.oCajaEstado.IdCajaAuditoria
								catch
									lcMensajeInconsistencia = "Se detectó una inconsistencia en la apertura de la caja." + chr(13) + chr(10) + ;
																"Debe ejecutar la herramienta de Ajustes de movimientos y saldos de caja según comprobantes, utilizando el criterio de ajuste histórico para asegurar la consistencia de la misma."
									This.AgregarRegistroFaltanteDeCajaAuditoria( this.oCajaEstado.IdCajaAuditoria, tnCaja )
									loCajaAuditoria.id = this.oCajaEstado.IdCajaAuditoria
								finally
									.DetalleValoresAuditoria = loCajaAuditoria.DetalleValoresAuditoria
									.MontoTotal	= loCajaAuditoria.MontoTotal
								endtry
							catch to loError
								llHuboError = .T.
							finally
								loCajaAuditoria.DetalleValoresAuditoria = Null
								loCajaAuditoria.Release()
							endtry
						endif
						if llHuboError
							.Cancelar()
						else
							.Grabar()
						endif
					endwith	

					** se registra el cambio en la caja de estados
					try
						with this.oCajaEstado
							.modificar()
							.Estado = "A"
							.Fecha = this.oCajaAuditoria.Fecha
							.IdCajaAuditoria = this.oCajaAuditoria.id
							.grabar()
						endwith
					catch to loError
						lcMessage = "No se pudo actualizar el estado de la caja nº " + transform( tnCaja ) + "."
					endtry

					** se registra el cambio en la caja de estados
					if empty( lcMessage )
						try
							this.oCajaSaldos.ActualizarSaldosPorAperturaDeCaja( tnCaja, this.oCajaAuditoria )
						catch to loError
							lcMessage = "No se pudo actualizar el saldo de la caja nº " + transform( tnCaja ) + "."
						endtry
					endif
					
				endif
			catch to loError&& no existe la caja buscada
				lcMessage = "No existe la caja nº " + transform( tnCaja ) + "."
			endtry	
		Endif	
		if !empty( lcMessage ) or !empty( lcMensajeInconsistencia )
			if vartype( loError ) = 'O'
				loEx = _screen.zoo.CrearObjeto( "ZooException" )
				loEx.Grabar( loError )
				if !empty( lcMessage )
					loEx.AgregarInformacion( lcMessage )
				endif
				if !empty( lcMensajeInconsistencia )
					loEx.AgregarInformacion( lcMensajeInconsistencia )
				endif
				goServicios.Errores.LevantarExcepcion( loEx )
			else
				if empty( lcMessage )
					goServicios.Mensajes.Advertir( lcMensajeInconsistencia )
				else
					lcMessage = lcMessage + chr(13) + chr(10) + lcMensajeInconsistencia
					goServicios.Errores.LevantarExcepcion( lcMessage )
				endif
			endif
		endif
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDatosDelAqueoDeCaja( toDatos as Object ) as Void
		this.oDatosDelArqueoDeCaja = toDatos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Cerrar( tnCaja as Integer ) as Boolean
		local loEx as ZooException of ZooException.prg, loCajaAuditoria as Object, lcMessage as String, ;
			loColeccionSaldos as zoocoleccion OF zoocoleccion.prg, llRetorno as Boolean, loError as Object, ;
			loHuecos as zoocoleccion OF zoocoleccion.prg, loHueco as rangocomprobantes of rangocomprobantes.prg, ;
			loComprobantes as Object, lcMensajeAdicional as String, lcDetalleHuecos as String, lnComprobante as Integer, ;
			lcValoresInexistentes as String

		llretorno = .F.
		if _Screen.Zoo.App.ObtenerValorReplicaBD()
			goServicios.Errores.LevantarExcepcion( "No está permitido cerrar cajas en bases de datos de réplica" )
		Else
			bindevent( this.oControlComprobantesFaltantes, "EventoPreguntarSiLlenaHuecos", This, "EventoPreguntarSiLlenaHuecos", 1 )
			bindevent( this.oControlComprobantesFaltantes, "EventoMostrarMensajeGenerandoAnulados", This, "EventoMostrarMensajeGenerandoAnulados", 1 )
			bindevent( this.oControlComprobantesFaltantes, "EventoQuitarMensajeGenerandoAnulados", This, "EventoQuitarMensajeGenerandoAnulados", 1 )
			bindevent( this.oControlComprobantesFaltantes, "EventoExistenComprobantesEnElHueco", This, "EventoExistenComprobantesEnElHueco", 1 )

			lcMensajeAdicional = ""
			lcMessage = ""
			this.lGeneroComprobanteCaja = .t.
			this.lGeneroAjusteDeCupon = .t.
			try
				this.oCajaEstado.Id = tnCaja
				if !this.EstaAbierta( tnCaja )
					lcMessage = "La caja nº " + transform( tnCaja ) + " ya se encuentra cerrada"
				else

					this.oControlConcurrencia.TomarCaja( this.oCajaEstado.Id)

					try

						if this.oControlConcurrencia.CajaTomada( this.oCajaEstado.Id )

							* Valido que todos los valores existentes en la caja no hayan sido borrados
							lcValoresInexistentes = this.ExistenTodosLosValoresDeLaCaja()
							if empty( lcValoresInexistentes )

								this.nNumeroDeCajaEnProcesoDeCierre = tnCaja

								if this.ExistenCuponesHuerfanos( tnCaja )
									this.EventoPreguntarGenerarReciboAplicandoCuponesHuerfanos( tnCaja )
									if this.lGenerarReciboAplicandoCuponesHuerfanos
										this.EventoGenerarReciboAplicandoCuponesHuerfanos()
									else
										lcMessage = "La caja nº " + transform( tnCaja ) + " no se pudo cerrar."
									endif
								endif

								if empty( lcMessage ) and this.ConsultarDispositivoPoint()
									this.EventoValidarCuponesPointPendientes( tnCaja )
									if !this.lValidoCuponesElectronicos
										lcMessage = "La caja nº " + transform( tnCaja ) + " no se pudo cerrar."
									endif
								endif
																
								if empty( lcMessage )
									if goParametros.Nucleo.DatosGenerales.Pais = 3
										this.EventoRevisarComprobantesDeContingenciaUruguaySinCAE()
									endif
									loHuecos = this.oControlComprobantesFaltantes.ControlarHuecosPorCaja( this.oCajaEstado )
									if goParametros.Felino.GestionDeVentas.RetirarValoresAlRealizarElCierreDeCaja
										this.GenerarComprobanteDeCaja( tnCaja )
									endif
									if this.lGeneroComprobanteCaja
										this.GenerarAuditoriaDeCaja( tnCaja )
										if this.oCajaEstado.ID != tnCaja
											this.oCajaEstado.ID = tnCaja
										endif
										this.GenerarEstadoDeCaja()
										this.llNoPermitirAperturaAutomaticaDeCaja = .t.
										this.EventoGeneraNCParaAjustesDeCupon( tnCaja )
										if Not this.lGeneroAjusteDeCupon
											lcMessage = "Ocurrió un error en la generación de notas de crédito por promoción bancaria al cerrar la caja Nº " + transform( tnCaja ) + "." + NUEVALINEA
											lcMessage = lcMessage + "Los ajustes de cupón quedarán pendientes de generar." + NUEVALINEA
											lcMessage = lcMessage + this.MensajeEspecificoDePromocionBancaria() + NUEVALINEA
											lcMessage = lcMessage + this.ReferenciaAlArchivoDeLog()
											this.EventoAdvertirFalloEnGeneraNCParaAjustesDeCupon( lcMessage )
											lcMessage = ""
										endif
									else
										lcMessage = "La caja nº " + transform( tnCaja ) + " no se pudo cerrar. No se generó ningún comprobante de caja."
									endif
								endif
								this.EventoCancelarPedidosAPagarEnCaja()
                                this.EventoCerrarLotesLaPos()
                                this.EventoCancelarSeniasVencidas()
                                this.EventoInformarComprobantesCAEA()
                                this.EventoObtenerCAEA()
                              
							else
								lcMessage = "La caja nº" + transform( tnCaja ) + " no se pudo cerrar. Tiene los valores ( " + rtrim( lcValoresInexistentes ) + " ) en la caja y han sido eliminados."
							endif
						else
							lcMessage = this.oControlConcurrencia.ObtenerMensajeDeImposibilidadDeCierre( this.oCajaEstado.Id )
						endif
					finally
						this.oControlConcurrencia.LiberarCaja( this.oCajaEstado.Id )
					endtry

				endif
			catch to loError  && no existe la caja buscada
			finally
				this.nNumeroDeCajaEnProcesoDeCierre = 0
				this.llNoPermitirAperturaAutomaticaDeCaja = .f.
				if !empty( lcMessage )
					loEx = Newobject(  "ZooException", "ZooException.prg" )
					With loEx
						if vartype( loError ) = 'O'
							.Grabar( loError )
						endif
						.AgregarInformacion( lcMessage )
						.nZooErrorNo = 9001
					endwith
					lcMessage = ""
				else
					do case
					case vartype( loError ) = 'O' and vartype( loError.Uservalue ) = 'O'
						loEx = NewObject(  "ZooException", "ZooException.prg" )
						With loEx
							.UserValue = loError.UserValue
							.nZooErrorNo = loError.UserValue.nZooErrorNo
						endwith
					case vartype( loError ) = 'O'
						goServicios.Errores.LevantarExcepcion( loError )
					otherwise
						llRetorno = .t.
					endCase
				endif
			endtry

			if type( "loHuecos" ) = "O" and !isnull( loHuecos ) and loHuecos.Count > 0
				loComprobantes = newobject( "din_Comprobante", "din_Comprobante.prg" )
				loRenderHuecos = newobject( "RenderRangoComprobantes", "RenderRangoComprobantes.prg", "", loComprobantes )
				lcDetalleHuecos = loRenderHuecos.ObtenerString( loHuecos )
				this.AgregarInformacion( lcDetalleHuecos )

				this.loguear( "Por el cierre de la caja Nº " + transform( tnCaja ) + ;
					" se generaron los siguientes comprobantes anulados:" + chr(13) + chr(10) + lcDetalleHuecos )
				this.FinalizarLogueo()

				lcMensajeAdicional = chr(13) + chr(10) + " Se han generado comprobantes faltantes."
			endif

			if vartype( loEx ) = 'O'
				loEx.Grabar()
				loEx.Throw()
			endif

			this.AgregarInformacion("Caja Nº " + transform( tnCaja ) + " cerrada." + lcMensajeAdicional )
			this.EnviarResumenDelDia()
		Endif
		return llRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ExistenTodosLosValoresDeLaCaja() as String
		local lcRetorno as String, lcXmlValoresEnCaja as String, lcCurValoresEnCaja as String, lcXmlCodValores as String, ;
				lcCurCodValores as String, c_ValoresInexistentes as String
		lcCurValoresEnCaja = sys( 2015 )
		lcXmlValoresEnCaja = ""
		lcCurCodValores = sys( 2015 )
		lcXmlCodValores = ""
		lcRetorno = ""
		
		lcXmlValoresEnCaja = this.oCajaSaldos.oAd.ObtenerDatosEntidad( "VALOR", "NUMCAJA = " + transform( this.oCajaEstado.Id ) )
		
		if !empty( lcXmlValoresEnCaja )
			This.XmlACursor( lcXmlValoresEnCaja, lcCurValoresEnCaja )
			
			select distinct valor from &lcCurValoresEnCaja into cursor &lcCurValoresEnCaja
			
			lcXmlCodValores = this.oValor.oAd.ObtenerDatosEntidad( "CODIGO" )
			if !empty( lcXmlCodValores )
				This.XmlACursor( lcXmlCodValores, lcCurCodValores )
				select valor from &lcCurValoresEnCaja where valor not in (select * from &lcCurCodValores ) into cursor c_ValoresInexistentes
				
				if reccount( "c_ValoresInexistentes" ) > 0
					scan all
						lcRetorno = lcRetorno + rtrim( c_ValoresInexistentes.Valor ) + ", "
					endscan
					lcRetorno = left( lcRetorno, len( lcRetorno ) - 2 )
					use in select( "c_ValoresInexistentes" )
				endif
				use in select( lcCurCodValores )
				
			endif
			use in select( lcCurValoresEnCaja )
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EnviarResumenDelDia() as Void
		local loFactory as FactoryAccionEnSegundoPlano of FactoryAccionEnSegundoPlano.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg

		loFactory = _screen.zoo.CrearObjetoPorProducto( "FactoryAccionEnSegundoPlano" )
		loAccion = loFactory.Obtener( "RESUMENDELDIA" )
		loAccion.Enviar()

		loFactory.Release()
		loAccion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarAuditoriaDeCaja( tnCaja as Integer ) as Void
		local loItem as Object, loColeccionSaldos as Object
		with this.oCajaAuditoria
			try 
				.Nuevo()
				.Tarea = "CIERRE"
				.CajaEstado_PK = tnCaja
				** Obtengo el saldo de los valores
				loColeccionSaldos = this.oCajaSaldos.ObtenerSaldos( tnCaja )
				for each loItem in loColeccionSaldos
					with .DetalleValoresAuditoria
						.LimpiarItem()
						try
							.oItem.Valor_PK = loItem.Valor
							.oItem.Monto = loItem.Saldo
						catch
						endtry
						.Actualizar()
					endwith
					.MontoTotal = .MontoTotal + loItem.Saldo
				endfor
				.Grabar()			
			catch to loError
				.Cancelar()
				throw
			endtry 
					
		endwith	

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarEstadoDeCaja() as Void
		** se registra el cambio en la caja de estados
		with this.oCajaEstado
			.Modificar()
			.Estado = "C"
			.Fecha = this.oCajaAuditoria.Fecha
			.IdCajaAuditoria = this.oCajaAuditoria.id
			.Grabar()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarEstadoDeCajaPersonalizado( tnCaja as Integer ) as Void
		with this.oCajaEstado
			.buscar()
			.Estado = "C"
			.Fecha = this.oCajaAuditoria.Fecha
			.IdCajaAuditoria = tnCaja
			.Grabar()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSaldo( toValor ) as float
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarSaldos( tcValor as String, tnCaja as Integer, tfMonto as Float )  as zoocoleccion OF zoocoleccion.prg  
		local loColSaldos as zoocoleccion OF zoocoleccion.prg
		local loError as Exception, loEx as Exception, llRetorno as boolean
		loColSaldos = _screen.zoo.crearobjeto( "zoocoleccion" )
		with This.oCajaSaldos
			if .EsNuevo()
				.Cancelar()
			endif
			.limpiar()
			
			try
				.BuscarCajaYValor( tnCaja , tcValor, this.cComprobante ) && Ahora este metodo da de alta el valorcajaComprobante
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError ) 
			endtry
			.Modificar()
			Try
				.Saldo = tfMonto 
				.TipoComprobante = this.cComprobante    
				llRetorno = .Validar()
				if llRetorno
					loColSaldos = .ObtenerSentenciasUpdate()
				else
				goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )					
				EndIf	
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError ) 
			Finally
				.Cancelar()
			endtry 
		EndWith	
		return loColSaldos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimaFechaApertura() as date
		return date()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimaFechaCierre() as date
		return date()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EstaAbierta( tnCaja as Integer ) as boolean
		return this.oCajaEstado.EstaAbierta( tnCaja )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarColeccion( toColMovimientos, toColSaldos) as zoocoleccion OF zoocoleccion.prg 
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object 
		loColRetorno = _screen.zoo.Crearobjeto( "zoocoleccion" )
		
		for each loItem in toColMovimientos
			loColRetorno.agregar( loItem )
		endfor 

		for each loItem in toColSaldos
			loColRetorno.agregar( loItem )
		endfor 
		return  loColRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	 function ActualizarMovimientodeCaja( tcValor AS String, tnCaja as Integer, tfMonto As Float, tfCotizacion As Float, tcDescripcion as String, tnTipoValor as Integer, tcItemValor as String ) AS zoocoleccion OF zoocoleccion.prg  
		local lcMessage as String, loColMov as zoocoleccion OF zoocoleccion.prg, lnCaja as Integer, llRetorno as Boolean
		lcMessage = ""
		loColMov = _screen.zoo.CrearObjeto( 'zooColeccion' )
		with This.oMovimientoDeCaja
			.Nuevo()
			Try	
				.Fecha = date()
				.Hora = time()
				.CajaEstado_PK = tnCaja
				.FechaCaja = .CajaEstado.Fecha
				.TipoComprobante = this.cComprobante 
				.Monto = tfMonto 
				.Descripcion = tcDescripcion 
				.Cotizacion = tfCotizacion
				.NumeroComprobante = this.nNumeroComp
				.Accion = iif( This.oEntidadPadre.EsNuevo(), 'A', iif( This.oEntidadPadre.EsEdicion(), 'M', 'B' ) )
				.Valor_PK = tcValor
				.CajaAuditoria_PK = .CajaEstado.IdCajaAuditoria
				.FechaComprobante = this.dFecha
				.PuntoDeVenta = This.nPuntoDeVenta
				.Secuencia = This.cSecuencia
				if type( 'tnTipoValor' ) = 'N'
					.TipoValor = tnTipoValor
				endif
				if type( 'tcItemValor' ) = 'C'
					.ItemValor = tcItemValor
				endif
				llRetorno = .Validar()
				if llRetorno
					loColMov = .ObtenerSentenciasInsert()
				else
					goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() ) 
				EndIf
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError ) 
			finally
				.cancelar()
			EndTry
		EndWith
		return loColMov
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GrabarCanjeDeCupon( toDetalleAEnt as Object, tlAnular as Boolean ) as ZooColeccion of ZooColeccion.prg
		local loCol as zoocoleccion OF zoocoleccion.prg	
		loCol = This.ObtenerDatosDeValorQueGeneroElCupon( toDetalleAEnt, tlAnular )

		Return this.ObtenerColeccionSaldosYMovimientosDeCaja( loCol )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDatosDeValorQueGeneroElCupon( toDetalleAEnt as Object, tlAnular as Boolean ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as Object, lcConsulta as String, lcTabla as String, lcCursor as String, loCol as zoocoleccion OF zoocoleccion.prg ,;
		loItem as Object
		loCol = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		for each loItem in toDetalleAEnt foxobject
			if !empty( loItem.Valor_pk )
				loRetorno = newobject( "auxCupon", "ComponenteCaja.prg", "", loItem )
				if tlAnular
				else
					loRetorno.Monto = loRetorno.Monto * -1
				Endif	
				loCol.Agregar( loRetorno )
			endif
		endfor
		Return loCol
	endfunc

	*-----------------------------------------------------------------------------------------
	function Grabar() as zoocoleccion OF zoocoleccion.prg
		local loItem as Object, loColSentencias as zoocoleccion OF zoocoleccion.prg, ;
			loColAnterior as zoocoleccion OF zoocoleccion.prg, loColFinal as zoocoleccion OF zoocoleccion.prg, ;
			loColAgrupado as zoocoleccion OF zoocoleccion.prg
		local lnX1 as Integer, loError0 as Exception, loInfo as zoocoleccion OF zoocoleccion.prg, loErrorParaReintentar as zoocoleccion OF zoocoleccion.prg
		with this
			if This.oEntidadPadre.lAfectaCaja
				for lnX1 = 1 to 3
					&& para evitar un error de concurrencia
					try 
						loColAgrupado = _Screen.zoo.Crearobjeto( "ZooColeccion" )		
						loColAnterior = .ObtenerColSentenciasAnterior()
						if This.oEntidadPadre.EsEdicion() or This.oEntidadPadre.EsNuevo()
							loColFinal = .ObtenerColSentenciasFinal()
						else
							loColFinal = _Screen.zoo.Crearobjeto( "ZooColeccion" )
						Endif	
						for each loItem in loColAnterior
							loColAgrupado.Agregar( loItem )
						endfor
						for each loItem in loColFinal
							loColAgrupado.Agregar( loItem )
						endfor
						loColSentencias = .ObtenerColeccionSaldosYMovimientosDeCaja( loColAgrupado )
						if !this.lYaGeneroContracomprobante ;
						  and  This.oEntidadPadre.EsComprobanteDeCaja() ;
						  and upper( this.cComponenteAsociado ) <> "CHEQUESDETERCEROS" ; 
						  and This.oEntidadPadre.CorrespondeGenerarContracomprobante() ;
						  and This.oEntidadPadre.EsNuevo() ;
						  and !this.oEntidadPadre.VerificarContexto( "CB" )
						     this.GenerarContracomprobanteDeCaja( loColsentencias )
						endif
						lnX1 = 3
					catch to loError0
						loInfo = this.oCajaSaldos.ObtenerInformacion()
						loErrorParaReintentar = loInfo.Filtrar('#ITEM.nNumero ='+transform(this.oCajaSaldos.ObtenerCodigoErrorParaValidacionTimestamp()))
						if loErrorParaReintentar.Count = 0 or lnX1=3
							goServicios.Errores.LevantarExcepcion( loError0 )					
						endif
					endtry
				endfor 
			else
				loColSentencias = _Screen.zoo.Crearobjeto( "ZooColeccion" )
			Endif
		endwith
		return loColSentencias

	endfunc 

	*------------------------------------------------------------------------------------------
	protected function GenerarContracomprobanteDeCaja( toColeccion as zoocoleccion OF zoocoleccion.prg ) as Void
		local loContraCom as Object, loColSentenciasInsert as zoocoleccion OF zoocoleccion.prg, loColSentenciasAdic as zoocoleccion OF zoocoleccion.prg, ;
		loItem as Object, lnIndCol as Integer
		
		if !this.EstaAbierta( This.oEntidadPadre.CajaDestino_pk )
			This.Abrir( This.oEntidadPadre.CajaDestino_pk )
		endif

		loContraCom = _screen.zoo.instanciarentidad("comprobantedecaja")
		loContraCom.Nuevo()
		loContraCom.lEstaGenerandoContraComprobante = .t.
		loContraCom.Concepto_pk = this.oEntidadPadre.Concepto_pk
		loContraCom.tipo = 1
		loContraCom.Vendedor_pk = this.oEntidadPadre.Vendedor_pk
		loContraCom.OrigenDestino_pk = this.oEntidadPadre.OrigenDestino_pk
		loContraCom.CajaOrigen_pk = This.oEntidadPadre.CajaDestino_pk
		loContraCom.Observacion = 'Generado automáticamente originado en el comprobante de caja Nº ' + alltrim( str( this.oEntidadPadre.Numero ) )
		loContraCom.oAd.GrabarNumeraciones()
		for each loItem in  this.oEntidadPadre.valores
			if !empty(loItem.Valor_pk)
				with loContraCom.Valores
					.LimpiarItem()
					.oItem.Valor_PK = loItem.Valor_pk
					.oItem.ValorDetalle = alltrim( loItem.Valordetalle )
					.oItem.lHabilitarMonto = .t.
					.oItem.NumeroCheque_PK = loItem.NumeroCheque_PK
					.oItem.NumeroInterno = loItem.NumeroInterno
					.oItem.Monto = loItem.Monto
					.oItem.lHabilitarCaja_pk = .T.
					.oItem.Caja_pk = This.oEntidadPadre.CajaDestino_pk
					.Actualizar()
				endwith
			endif 
		endfor

		loColSentenciasInsert = loContraCom.oAD.ObtenerSentenciasInsert()
		loColSentenciasAdic = loContraCom.valores.oItem.oCompCajero.Grabar()
		for lnIndCol = 1 to loColSentenciasInsert.count
		      toColeccion.agregar( loColSentenciasInsert.item(lnIndCol) )
		endfor
		for lnIndCol = 1 to loColSentenciasAdic.count
		      toColeccion.agregar( loColSentenciasAdic.item(lnIndCol) )
		endfor
		this.lYaGeneroContracomprobante = .T.
		loContraCom.release()	

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionSaldosYMovimientosDeCaja( toColeccionSaldos as ZooColeccion of ZooColeccion.prg ) as ZooColeccion of ZooColeccion.prg
		local	loColSentencias as zoocoleccion OF zoocoleccion.prg, loColCaja as zoocoleccion OF zoocoleccion.prg, ;
				loColMov as zoocoleccion OF zoocoleccion.prg, lcItemAux as String, loItem as Object
		loColSentencias = _screen.zoo.crearobjeto( "ZooColeccion" )
		create cursor c_Saldos ( valor c(5), Caja N(2), monto n(16,2), Cotiza n(15,5), detalle c( 50 ), tipovalor n(2,0), ItemValor C(38) )

		for each loItem in toColeccionSaldos
			if loItem.TipoValor = TIPOVALORCIRCUITOCHEQUETERCERO
				insert into c_saldos ( Valor, Caja, Monto, Cotiza, Detalle, TipoValor, ItemValor ) values( loItem.Valor, loItem.Caja, loItem.Monto, loItem.Cotiza, loItem.Detalle, loItem.TipoValor, loItem.ItemValor )
			else
				insert into c_saldos ( Valor, Caja, Monto, Cotiza, Detalle, TipoValor ) values( loItem.Valor, loItem.Caja, loItem.Monto, loItem.Cotiza, loItem.Detalle, loItem.TipoValor )
			endif
		endfor
			
		select Valor, Caja, sum( Monto ) as _Monto ;
			from c_saldos ;
			group by Valor, Caja ;
			having _Monto != 0  ;
			into cursor c_agrupado
		scan 
			loColCaja = this.ActualizarSaldos( c_agrupado.valor, c_agrupado.Caja, c_agrupado._Monto )
			for each lcItemAux in loColCaja
				loColSentencias.Agregar( lcItemAux )
			endfor 
		endscan
		select c_saldos
		scan
			loColMov = this.ActualizarMovimientodeCaja( c_saldos.Valor, c_saldos.Caja, c_saldos.Monto, c_saldos.Cotiza, c_saldos.Detalle, c_saldos.TipoValor,  c_saldos.ItemValor )
			
			for each lcItemAux in loColMov
				loColSentencias.Agregar( lcItemAux )
			endfor 
		endscan
		
		use in select( "c_agrupado" )
		use in select( "c_Saldos" )		
		return loColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColSentenciasAnterior() as zoocoleccion OF zoocoleccion.prg  
		local loItem as Object, loColSentencias as zoocoleccion OF zoocoleccion.prg, loItemFinal as Object 
		
		loColSentencias = _screen.zoo.crearobjeto( "zoocoleccion" )
		
		for each loItem in this.oDetalleAnterior
			if This.DebeProcesarElItem( loItem.Tipo ) and this.SeDebeVisualizarEnCaja( loItem )
				loItemFinal = this.ObtenerObjetoSentenciaValor( loItem, .t. )
				loColSentencias.agregar( loItemFinal ) 
				loItemFinal.destroy()
			Endif	
		endfor
		if This.nVueltoAnterior > 0
			if This.DebeProcesarVuelto()
				This.cCodigoVueltoAnterior = iif ( empty( alltrim( This.cCodigoVueltoAnterior )), alltrim( goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto ), This.cCodigoVueltoAnterior )
				loItemFinal = this.ObtenerObjetoSentenciaVuelto( This.nVueltoAnterior, .t. )
				loColSentencias.agregar( loItemFinal ) 
				loItemFinal .destroy()
			EndIf	
		endif
		return loColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColSentenciasFinal() as zoocoleccion OF zoocoleccion.prg  
		local lnIndColS as Integer, loItem as Object, loColSentencias as zoocoleccion OF zoocoleccion.prg
		
		lnIndColS = 1
		loColSentencias = _screen.zoo.crearobjeto( "zoocoleccion" )
		for lnIndColS = 1 to this.oDetallePadre.count
			if this.oDetallePadre.ValidarExistenciaCamposFijosItemPlano( lnIndColS )
				if This.DebeProcesarElItem( this.oDetallePadre[ lnIndColS ].Tipo ) and this.SeDebeVisualizarEnCaja( this.oDetallePadre( lnIndColS ) )
					loItem = this.ObtenerObjetoSentenciaValor( this.oDetallePadre[ lnIndColS ], .f. )
					loColSentencias.Agregar( loItem ) 
					loItem.destroy()
				Endif	
			endif	
		endfor

		if This.nVueltoCotizado > 0
			if This.DebeProcesarVuelto()		
				loItem = this.ObtenerObjetoSentenciaVuelto( This.nVueltoCotizado, .f. )
				loColSentencias.Agregar( loItem ) 
				loItem.Destroy()
			EndIf
		endif

		return loColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function SetearDatosComprobante( tnComprobante, tdFecha, tcLetra, tnNumeroComprobante, tnPuntoDeVenta, tcSecuencia as String ) as Void

		with this
			.cComprobante = .ObtenerTipoComprobante( tnComprobante, tcLetra )
			.dFecha = tdFecha
			.nNumeroComp = tnNumeroComprobante
			.nPuntoDeVenta = tnPuntoDeVenta
			.cSecuencia = tcSecuencia
		endwith 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTipoComprobante( tnComprobante as int, tcLetra as String ) as String
	local lcCodigoComprobante as String, lcRetorno as String

		lcRetorno = ''
		if empty( tcLetra )
			tcLetra = ''
		endif
		if vartype( tnComprobante ) = "C"
			tnComprobante = val( tnComprobante ) 
		endif 

		lcRetorno = this.oComprobantesYGruposCaja.BuscaIdComprobante( tnComprobante, tcLetra )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionTipoComprobante( tcTipoComprobante as String ) as String
		local lcRetorno as String
		lcRetorno = ""
		if this.oComprobantesYGruposCaja.Buscar( alltrim( tcTipoComprobante ) )
			lcRetorno = this.oComprobantesYGruposCaja.Item[ alltrim( tcTipoComprobante ) ].Comprobante
		endif
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoSentenciaVuelto( tnVuelto as float, tlEsAnterior as Boolean ) as Object
		local lnMonto as float
		
		lnMonto = -tnVuelto
		lnMonto = iif( tlEsAnterior, (-1) * lnMonto * This.nSignoDeMovimientoAnterior, lnMonto * This.nSignoDeMovimiento )
		
		return this.CrearObjetoSentencia( This.cCodigoVueltoAnterior, This.oEntidadPadre.Caja_Pk, lnMonto, 1, "Vuelto" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoSentenciaValor( toItem as Object, tlEsAnterior as Boolean ) as Object
		local lcDetalle as String, lxValor as Variant, lnMonto as Integer, lnCotiza as Integer, lnCaja as Integer
		lxValor = toItem.valor_pk
		lnCaja = toItem.Caja_Pk
		if pemstatus( toItem, "Recibido", 5)
			lnMonto = iif( tlEsAnterior, (-1) * toItem.Recibido * this.ObtenerSignoDelDetalle( This.nSignoDeMovimientoAnterior ), toItem.Recibido * this.ObtenerSignoDelDetalle( This.nSignoDeMovimiento ) )
		else
			lnMonto = iif( tlEsAnterior, (-1) * toItem.Total * this.ObtenerSignoDelDetalle( This.nSignoDeMovimientoAnterior ), toItem.Total * this.ObtenerSignoDelDetalle( This.nSignoDeMovimiento ) )
		endif
		lcDetalle = toItem.ValorDetalle
		lnCotiza = iif( toItem.Cotiza = 0, 1 , toItem.Cotiza )
		lnTipoValor = toItem.Tipo
		if tlEsAnterior
			lcItemValor = ""
		else
			lcItemValor = this.ObtenerItemValor( toItem )
		endif

		return this.CrearObjetoSentencia( lxValor, lnCaja, lnMonto, lnCotiza, lcDetalle, lnTipoValor, lcItemValor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSignoDelDetalle( tnSigno as Integer ) as Integer
		local lnSignoRetorno as Integer
		lnSignoRetorno = tnSigno
		if alltrim( upper( This.oDetallePadre.cNombre ) ) = "VALORESAENT"
			lnSignoRetorno = -1 * tnSigno
		endif 
		
		return lnSignoRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearObjetoSentencia( txValor as Variant, tnCaja as Integer, tnMonto as Float, tnCotiza as float, tcDetalle as String, tnTipoValor as Integer, tcItemValor as String ) as Object
		local loItemFinal as Object
	
		loItemFinal = newobject( "custom" )
		addproperty( loItemFinal, "Valor", txValor )
		addproperty( loItemFinal, "Caja", tnCaja )
		addproperty( loItemFinal, "Monto", tnMonto )
		addproperty( loItemFinal, "Cotiza", tnCotiza )
		addproperty( loItemFinal, "Detalle", tcDetalle )
		addproperty( loItemFinal, "TipoValor", iif(type('tnTipoValor')='N',tnTipoValor,0) )
		addproperty( loItemFinal, "ItemValor", iif(type('tcItemValor')='C',tcItemValor,'') )

		return loItemFinal
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarSaldoDeUnValor( tcValor as String, tnCaja as Integer, tnMonto as float ) as Boolean
		return ( this.oCajaSaldos.ObtenerSaldoValor( tnCaja, tcValor ) >= tnMonto )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAnulacion( toEntidad as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if !this.oCajaSaldos.NoVerificaSaldos()
			if toEntidad.SignoDeMovimiento = 1
				llRetorno = this.oCajaSaldos.ValidarDetalleValoresContraSaldosDeCaja( toEntidad.ValoresDetalle, .t., toEntidad.SignoDeMovimiento )
 				this.agregarInformacion( this.oCajaSaldos.cMensajeSaldoNegativo )
			endif
			if !llRetorno
 				toEntidad.CargarInformacion( this.oCajaSaldos.ObtenerInformacion() )
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarVuelto( tcCodigoDeValorParaVuelto as String, toEntidad As Object, tnVuelto as float, tnSignoDeMovimiento as Integer, tlInvertirSigno as Boolean ) as Boolean
		local llRetorno as Boolean, lcCodigoDeValorSugeridoParaVuelto as String, lnSigno as Integer
		lnSigno = this.oCajaSaldos.ObtenerSigno( tlInvertirSigno )
		
		llRetorno = this.ValidarSaldoDeUnValor( tcCodigoDeValorParaVuelto, toEntidad.Caja_Pk, tnVuelto * tnSignoDeMovimiento * lnSigno )
		if !llRetorno
			this.AgregarInformacion( "Saldo insuficiente para el valor " + alltrim( tcCodigoDeValorParaVuelto ), 1 )
			this.AgregarInformacion( "No hay saldo en la caja para dar vuelto" )
		endif 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Recibir( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String, tcCursorCabecera as String ) as Void
		local loTablasMovimientos as zoocoleccion OF zoocoleccion.prg, lcCursor as String
		lcCursor = sys( 2015 )
		with This
			=.oMovimientoDeCaja.oAd
			.GuardarDataSession()
			try
				.SetearDataSession( toEntidad.DataSessionId )
				.AbrirTablasSqlServer()
				select * from &tcCursorDetalle into cursor &lcCursor ReadWrite
				.CrearCursorFiltrado( toEntidad, tcAtributoDetalle, lcCursor, tcCursorCabecera )
				loTablasMovimientos = .PrepararXMLMovimientos( toEntidad, lcCursor )
				.CerrarTablasSqlServer()
				.oMovimientoDeCaja.cPrefijoRecibir = toEntidad.cPrefijoRecibir
				.oMovimientoDeCaja.lActualizaRecepcion = .T.
				.oMovimientoDeCaja.cIdentificadorConexion = toEntidad.cIdentificadorConexion

				.oMovimientoDeCaja.Recibir( loTablasMovimientos )
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError ) 
			finally
				use in select( lcCursor )			
				.RestaurarDataSession()
			EndTry
		EndWith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirTablasSqlServer() as Void
		local lcTabla as String
		if goDatos.EsSqlServer()
			lcTabla = This.oMovimientoDeCaja.oAd.cTablaPrincipal
			goDatos.EjecutarSentencias( "Select * From " + lcTabla + " where 1 = 0", lcTabla, "", lcTabla, This.oMovimientoDeCaja.DataSessionId )
		EndIf
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CerrarTablasSqlServer() as Void
		if alltrim( upper( _Screen.zoo.App.TipoDeBase ) ) = "NATIVA"
		else
			use in select( This.oMovimientoDeCaja.oAd.cTablaPrincipal )
		EndIf
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GuardarDataSession() as Void
		with This
			.nDataSessionMovimientosCaja	= .oMovimientoDeCaja.DataSessionId
			.nThisDataSession				= .DataSessionId
		EndWith	

	*-----------------------------------------------------------------------------------------
	protected function RestaurarDataSession() as Void
		with This
			.oMovimientoDeCaja.DataSessionId	= .nDataSessionMovimientosCaja
			.DataSessionId					= .nThisDataSession
		EndWith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDataSession( tnDataSessionId as Integer ) as Void
		with This
			store tnDataSessionId to .DataSessionId, .oMovimientoDeCaja.DataSessionId
		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorFiltrado( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String, tcCursorCabecera as String ) as Void
		local	lcCamposSelect as String, lcCamposGroupBy as String, lcWhere as String, ;
				lcCursor as String
		lcCursor = toEntidad.cPrefijoRecibir + This.oMovimientoDeCaja.ObtenerNombre()
		.AgregarSignoCursorDetalle( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )
		if toEntidad.EsComprobanteConVuelto()
			.AgregarVueltoCursorDetalle( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )
		endif

		.ReasignarTipoCajaCursorDetalle( tcCursorDetalle )
		.ReasignarCotizacion( tcCursorDetalle )
		.AgregarCamposFaltantesCursorDetalle( tcCursorDetalle )
		.ProcesarValoresCajayAuditoria( tcCursorDetalle )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarSignoCursorDetalle( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String , tcCursorCabecera as String ) as Void
		local	lcCampoCodigoCabecera as String, lcCampoCodigoDetalle as String, lcMetodo as String, ;
				lcConsulta as String, lcCursor as String, lcCampoSigno as String,  lcCampoValor as String, ;
				lcCampoCotiza as String, lcCampoMonto as String, lcCampoDetalle as String, lcCampoFecha as String, ;
				lcCampoNroComp as String, lcCampoLetra as String, lcCampoTipoComp as String, lcCampoCaja as String, ;
				lcCampoPuntoDeVenta As String
				
		lcCursor = sys( 2015 )
		lcMetodo = "ObtenerCampoDetalle" + alltrim( tcAtributoDetalle )
		lcCampoCodigoDetalle = toEntidad.oAd.&lcMetodo( toEntidad.&tcAtributoDetalle..oItem.cAtributoPk )
		lcCampoCodigoCabecera = toEntidad.oAd.ObtenerCampoEntidad( toEntidad.ObtenerAtributoClavePrimaria() )
		lcCampoSigno	= toEntidad.oAd.ObtenerCampoEntidad( "SignoDeMovimiento" )
		lcCampoFecha	= toEntidad.oAd.ObtenerCampoEntidad( "Fecha" )
		lcCampoNroComp	= toEntidad.oAd.ObtenerCampoEntidad( "Numero" )

		do Case
			case upper( alltrim( toEntidad.ObtenerNombre() ) ) == "COMPROBANTEDECAJA"
				lcCampoLetra	= "Space( 1 ) "
				lcCampoTipoComp	= "98"
				lcCampoPuntoDeVenta = "0 "
			otherwise
				lcCampoLetra		= " Cab." + toEntidad.oAd.ObtenerCampoEntidad( "Letra" )
				lcCampoTipoComp		= " Cab." + toEntidad.oAd.ObtenerCampoEntidad( "TipoComprobante" )
				lcCampoPuntoDeVenta = " Cab." + toEntidad.oAd.ObtenerCampoEntidad( "PuntoDeVenta" )
		EndCase

		lcCampoValor 	= toEntidad.oAd.&lcMetodo( "Valor" )
		lcCampoCotiza	= toEntidad.oAd.&lcMetodo( "Cotiza" )
		lcCampoMonto	= toEntidad.oAd.&lcMetodo( "Recibido" )
		if empty( lcCampoMonto ) 
			lcCampoMonto	= toEntidad.oAd.&lcMetodo( "Monto" )
		endif
		lcCampoCaja 	= toEntidad.oAd.&lcMetodo( "Caja" )
		lcCampoDetalle	= toEntidad.oAd.&lcMetodo( "ValorDetalle" )

		lcConsulta = "select Det." + lcCampoValor + " as Valor, Det." + lcCampoCaja + " as Caja,Det." + lcCampoCotiza + " as Cotiza, Det." + lcCampoMonto + " as Monto, Det." + lcCampoDetalle + " as Detalle," + ;
							" Cab." + lcCampoSigno + " as Signo, Cab." + lcCampoFecha + " As FechaComprobante, " + ;
							" Cab." + lcCampoNroComp + " as Numero, " + lcCampoPuntoDeVenta + " as PuntoDeVenta," + lcCampoLetra + " As Letra, " + ;
							lcCampoTipoComp + " as TipoComp, '  ' as TipoCaja " + ;
						"from " + tcCursorDetalle + " Det inner join " + tcCursorCabecera + " Cab " + ;
							" on Det." + lcCampoCodigoDetalle + " = Cab." + lcCampoCodigoCabecera + ;
						" into cursor " + lcCursor
		&lcConsulta
		&& Se hace el inner join para asegurarse que los items sean los correctos de la cabecera...
		use in select( tcCursorDetalle )
		select * from &lcCursor into cursor &tcCursorDetalle ReadWrite
		use in select( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarVueltoCursorDetalle( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String , tcCursorCabecera as String ) as Void
		local	lcConsulta as String, lcCampoSigno as String,  lcCampoValor as String, lcCampoVuelto as String, ;
				lcCampoFecha as String, lcCampoNroComp as String, lcCampoLetra as String, lcCampoTipoComp as String, lcCampoCaja as String

				
		lcCampoSigno 		= toEntidad.oAd.ObtenerCampoEntidad( "SignoDeMovimiento" )
		lcCampoValor 		= toEntidad.oAd.ObtenerCampoEntidad( "IdVuelto" )
		lcCampoCaja 		= toEntidad.oAd.ObtenerCampoEntidad( "Caja" )		
		lcCampoVuelto		= toEntidad.oAd.ObtenerCampoEntidad( "Vuelto" )
		lcCampoFecha		= toEntidad.oAd.ObtenerCampoEntidad( "Fecha" )
		lcCampoNroComp		= toEntidad.oAd.ObtenerCampoEntidad( "Numero" )
		lcCampoLetra		= toEntidad.oAd.ObtenerCampoEntidad( "Letra" )
		lcCampoTipoComp		= toEntidad.oAd.ObtenerCampoEntidad( "TipoComprobante" )
		lcCampoPuntoDeVenta = toEntidad.oAd.ObtenerCampoEntidad( "PuntoDeVenta" )	

		lcConsulta = "Insert Into " + tcCursorDetalle + " ( Valor, Caja, Cotiza, Monto, Detalle, Signo, FechaComprobante, Numero, Letra, TipoComp, PuntoDeVenta ) " + ;
						" Select " + lcCampoValor + "," + lcCampoCaja + ", 1, " + lcCampoVuelto + ", 'Vuelto', -1 * " + lcCampoSigno + "," + ;
									lcCampoFecha + "," + lcCampoNroComp + "," + lcCampoLetra + "," + lcCampoTipoComp + "," + lcCampoPuntoDeVenta + ;
							" From " + tcCursorCabecera + " Where " + lcCampoVuelto + " != 0 "
		&lcConsulta
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReasignarTipoCajaCursorDetalle( tcCursorDetalle as String ) as VOID
		Replace all TipoCaja with This.ObtenerTipoComprobante( &tcCursorDetalle..TipoComp, &tcCursorDetalle..Letra ) in &tcCursorDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReasignarCotizacion( tcCursorDetalle as String ) as VOID
		Replace all Cotiza with 1 for empty( Cotiza ) in &tcCursorDetalle
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarCamposFaltantesCursorDetalle( tcCursorDetalle as String ) as Void
		local	lcCampoCajaEstado as String,  lcCampoFechaCaja as String, lcCampoAccion as String, ;
				lcCampoCajaAuditoria as String, lcCampoFecha as String, lcCampoHora as String, lcCampoTurno as String, lcCampoTarea As String, ;
				lcCampoId as String, lcCampoVendedor as String, lcConsulta as String, lcCursor as String, lcTabla as String, lnTurno as Integer, ;
				lcExpresionConCamposDeAtributosGenericosParaSelect as String, lcCampoSecuencia as String, lcCampoTipoValor as String, lcCampoItemValor as String

		lcCursor = sys( 2015 )
		with This.oMovimientoDeCaja
			lcTabla				= alltrim( .oAd.cTablaPrincipal )
			lcCampoCajaEstado	= .oAd.ObtenerCampoEntidad( "CajaEstado" )
			lcCampoCajaAuditoria= .oAd.ObtenerCampoEntidad( "CajaAuditoria" )
			lcCampoFechaCaja	= .oAd.ObtenerCampoEntidad( "FechaCaja" )
			lcCampoAccion		= .oAd.ObtenerCampoEntidad( "Accion" )
			lcCampoFecha		= .oAd.ObtenerCampoEntidad( "Fecha" )
			lcCampoHora			= .oAd.ObtenerCampoEntidad( "Hora" )
			lcCampoTurno		= .oAd.ObtenerCampoEntidad( "Turno" )
			lcCampoId			= .oAd.ObtenerCampoEntidad( "Id" )
			lcCampoVendedor		= .oAd.ObtenerCampoEntidad( "Vendedor" )
			lcCampoTarea		= .oAd.ObtenerCampoEntidad( "Tarea" )
			lcCampoSecuencia	= .oAd.ObtenerCampoEntidad( "Secuencia" )
			lcCampoTipoValor	= .oAd.ObtenerCampoEntidad( "TipoValor" )
			lcCampoItemValor	= .oAd.ObtenerCampoEntidad( "ItemValor" )
			lnTurno				= .ObtenerTurno()
		endwith

		lcExpresionConCamposDeAtributosGenericosParaSelect = this.ObtenerExpresionConCamposDeAtributosGenericosParaSelect( lcTabla, 4 )
		lcConsulta = "Select *, " + ;
							lcExpresionConCamposDeAtributosGenericosParaSelect + ", " + ;
							lcTabla + "." + lcCampoCajaEstado	+ " as CajaEstado, " + ;
							lcTabla + "." + lcCampoCajaAuditoria+ " as CajaAuditoria, " + ;
							lcTabla + "." + lcCampoFechaCaja	+ " as FechaCaja, " + ;
							lcTabla + "." + lcCampoAccion		+ " as Accion, " + ;
							lcTabla + "." + lcCampoFecha		+ " as Fecha, " + ;
							lcTabla + "." + lcCampoHora			+ " as Hora, " + ;
							lcTabla + "." + lcCampoTurno		+ " as Turno, " + ;
							lcTabla + "." + lcCampoId			+ " as Id, " + ;
							lcTabla + "." + lcCampoTarea		+ " as Tarea, " + ;
							lcTabla + "." + lcCampoVendedor		+ " as Vendedor, " + ;
							lcTabla + "." + lcCampoSecuencia	+ " as Secuencia, " + ;
							lcTabla + "." + lcCampoTipoValor	+ " as TipoValor, " + ;
							lcTabla + "." + lcCampoItemValor	+ " as ItemValor " + ;
						" From " + tcCursorDetalle + " Into Cursor " + lcCursor																																																																																				
		&lcConsulta
	
		use in select( tcCursorDetalle )
		select * from &lcCursor into cursor &tcCursorDetalle ReadWrite
		use in select( lcCursor )
		
		update &tcCursorDetalle Set Accion = "A", Fecha = date(), Hora = time(), Turno = lnTurno, Id = goLibrerias.ObtenerGuidPk(), Vendedor = "", ;
				CajaEstado = 0, CajaAuditoria = 0, FechaCaja = {}, Tarea = "", Monto = Monto * Signo, CajaEstado = Caja

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarValoresCajayAuditoria( tcCursorDetalle as String ) as Void
		local lcCursor As String, loValor as Din_EntidadValor of Din_EntidadValor.Prg, lnCaja as Integer, ldFecha as Date, lnCajaAudi as Integer
		lcCursor = sys( 2015 )
		loValor = _Screen.zoo.instanciarEntidad( "Valor" )
		select Distinct Valor,Caja ;
			from &tcCursorDetalle ;
			into cursor &lcCursor ReadWrite

		select &lcCursor
		scan All
			loValor.Codigo = &lcCursor..Valor
			if This.DebeProcesarElItem( loValor.Tipo )
				lnCaja = &lcCursor..Caja
				if this.EstaAbierta( lnCaja )
				else
					This.Abrir( lnCaja )
				endif
				This.oCajaEstado.Id = lnCaja
				ldFecha = This.oCajaEstado.Fecha
				lnCajaAudi = This.oCajaEstado.IdCajaAuditoria
				update &tcCursorDetalle set CajaEstado = lnCaja, FechaCaja = ldFecha, CajaAuditoria = lnCajaAudi where Valor = &lcCursor..Valor and Caja = lnCaja
			else
				delete from &tcCursorDetalle where Valor = &lcCursor..Valor
			Endif	
			select &lcCursor
		EndScan
		loValor.Release()		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PrepararXMLMovimientos( toEntidad  as Object, tcCursorDetalle as String ) as zoocoleccion OF zoocoleccion.prg
		local lcCursor as String, lcCamposSelect as String
		lcCursor = toEntidad.cPrefijoRecibir + This.oMovimientoDeCaja.ObtenerNombre()
		lcCamposSelect = This.ObtenerCamposSelectMovimientoDeCaja()
		select &lcCamposSelect ;
			from &tcCursorDetalle ;
			into cursor &lcCursor
		return This.PrepararXmlGenerico( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PrepararXmlGenerico( tcCursor as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _Screen.zoo.crearobjeto( "zooColeccion" )
		copy to ( _Screen.zoo.ObtenerRutaTemporal() + tcCursor )
		use in select( tcCursor )
		loRetorno.Agregar( _Screen.zoo.ObtenerRutaTemporal() + tcCursor )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerCamposSelectMovimientoDeCaja() As String
	
		local	lcCampoCajaEstado as String,  lcCampoFechaCaja as String, lcCampoAccion as String, ;
				lcCampoCajaAuditoria as String, lcCampoFecha as String, lcCampoHora as String, lcCampoTurno as String, ;
				lcCampoId as String, lcCampoVendedor as String, lcCampoCotiza as String, lcCampoValor As String, lcCampoNumeroComp as String, ;
				lcCampoFechaComp as String, lcCampoTipoComp as String, lcCampoMonto as String, lcCampoDescripcion as String, lcCampoTarea as String, ;
				lcRetorno as String, lcCampoPuntoDeVenta as String, lcExpresionConCamposDeAtributosGenericosParaSelect as String, lcCampoSecuencia as String, ;
				lcCampoTipoValor as String, lcCampoItemValor as String

		with This.oMovimientoDeCaja
			lcCampoCajaEstado	= .oAd.ObtenerCampoEntidad( "CajaEstado" )
			lcCampoCajaAuditoria= .oAd.ObtenerCampoEntidad( "CajaAuditoria" )
			lcCampoFechaCaja	= .oAd.ObtenerCampoEntidad( "FechaCaja" )
			lcCampoMonto		= .oAd.ObtenerCampoEntidad( "Monto" )
			lcCampoDescripcion	= .oAd.ObtenerCampoEntidad( "Descripcion" )
			lcCampoCotiza		= .oAd.ObtenerCampoEntidad( "Cotizacion" )
			lcCampoAccion		= .oAd.ObtenerCampoEntidad( "Accion" )
			lcCampoValor		= .oAd.ObtenerCampoEntidad( "Valor" )
			lcCampoFecha		= .oAd.ObtenerCampoEntidad( "Fecha" )
			lcCampoHora			= .oAd.ObtenerCampoEntidad( "Hora" )
			lcCampoTurno		= .oAd.ObtenerCampoEntidad( "Turno" )
			lcCampoId			= .oAd.ObtenerCampoEntidad( "Id" )
			lcCampoVendedor		= .oAd.ObtenerCampoEntidad( "Vendedor" )
			lcCampoNumeroComp	= .oAd.ObtenerCampoEntidad( "NumeroComprobante" )
			lcCampoFechaComp	= .oAd.ObtenerCampoEntidad( "FechaComprobante" )
			lcCampoTipoComp		= .oAd.ObtenerCampoEntidad( "TipoComprobante" )
			lcCampoTarea		= .oAd.ObtenerCampoEntidad( "Tarea" )
			lcCampoPuntoDeVenta = .oAd.ObtenerCampoEntidad( "PuntoDeVenta" )
			lcCampoSecuencia 	= .oAd.ObtenerCampoEntidad( "Secuencia" )
			lcCampoTipoValor	= .oAd.ObtenerCampoEntidad( "TipoValor" )
			lcCampoItemValor	= .oAd.ObtenerCampoEntidad( "ItemValor" )
		endwith

		lcExpresionConCamposDeAtributosGenericosParaSelect = this.ObtenerExpresionConCamposDeAtributosGenericosParaSelect( "", 2 )
		lcRetorno = ""
		lcRetorno = lcRetorno + lcExpresionConCamposDeAtributosGenericosParaSelect + ","
		lcRetorno = lcRetorno + " 0						As TimeStamp, "
		lcRetorno = lcRetorno + " CajaEstado			As " + lcCampoCajaEstado	+ ","
		lcRetorno = lcRetorno + " CajaAuditoria			As " + lcCampoCajaAuditoria	+ ","
		lcRetorno = lcRetorno + " FechaCaja				As " + lcCampoFechaCaja		+ ","
		lcRetorno = lcRetorno + " Monto					As " + lcCampoMonto			+ ","
		lcRetorno = lcRetorno + " Detalle				As " + lcCampoDescripcion	+ ","
		lcRetorno = lcRetorno + " Cotiza				As " + lcCampoCotiza		+ ","
		lcRetorno = lcRetorno + " Accion				As " + lcCampoAccion		+ ","
		lcRetorno = lcRetorno + " Valor					As " + lcCampoValor			+ ","
		lcRetorno = lcRetorno + " Fecha					As " + lcCampoFecha			+ ","
		lcRetorno = lcRetorno + " Hora					As " + lcCampoHora			+ ","
		lcRetorno = lcRetorno + " Turno					As " + lcCampoTurno			+ ","
		lcRetorno = lcRetorno + " Id					As " + lcCampoId			+ ","
		lcRetorno = lcRetorno + " Vendedor				As " + lcCampoVendedor		+ ","
		lcRetorno = lcRetorno + " Numero				As " + lcCampoNumeroComp	+ ","
		lcRetorno = lcRetorno + " FechaComprobante		As " + lcCampoFechaComp		+ ","
		lcRetorno = lcRetorno + " TipoCaja				As " + lcCampoTipoComp		+ ","
		lcRetorno = lcRetorno + " PuntoDeVenta			As " + lcCampoPuntoDeVenta 	+ ","
		lcRetorno = lcRetorno + " Tarea					As " + lcCampoTarea			+ ","
		lcRetorno = lcRetorno + " Secuencia				As " + lcCampoSecuencia		+ ","
		lcRetorno = lcRetorno + " TipoValor				As " + lcCampoTipoValor		+ ","
		lcRetorno = lcRetorno + " ItemValor				As " + lcCampoItemValor

		return lcRetorno
	endfunc 

	*------------------------------------------------------------------------------------------------------------------------
	function GenerarComprobanteDeCaja( tnCaja as Integer ) as Boolean 
		local llSinFormulario as Boolean, llRetorno as Boolean, lcCodigoConcepto as String, ;
		lcCodigoOrigen as String, loCamposObligatorios as Object 
		this.ObtenerColeccionSaldoValores( tnCaja )
		if this.VerificarExistenciaDeSaldos()
			llSinFormulario = goParametros.Felino.GestionDeVentas.GenerarComprobanteDeCajaAutomaticamenteAlCerrarLaCaja 
			*loCamposObligatorios = this.ObtenerValoresCamposObligatorios()
			llSinFormulario = llSinFormulario or ( pemstatus(_screen,"lUsaServicioRest", 5) and _Screen.lUsaServicioRest )
			if llSinFormulario && and loCamposObligatorios.DatosCompletos
				this.ProcesarEntidadComprobanteDeCaja()
			else
				this.EventoProcesarFormularioComprobanteDeCaja()
			endif
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarControlConcurrencia( toEntidad as entidad OF entidad.prg ) as Void
		local loVal 
		loVal = _screen.zoo.crearobjeto( "ValidadorEntidadComprobanteDeCajaAlCierre", "ValidadorEntidadComprobanteDeCajaAlCierre.prg", this.oCajaEstado.Id, this.oControlConcurrencia )
		toEntidad.AgregarValidador( loVal )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionSaldoValores( tnCaja as Integer ) as Void
		local loColMovimientos as Collection, loColaborador as Object, lcEstado as String, lcFiltro as String
		try
			this.oCajaEstado.Id = tnCaja
			lnIDCierre = this.oCajaEstado.IdCajaAuditoria
		catch
			lnIDCierre = 0
		endtry
		loColMovimientos = this.oCajaSaldos.ObtenerSaldos( tnCaja )
		this.oColSaldos = _screen.zoo.crearobjeto( "zooColeccion" )
		for each loSaldo in loColMovimientos FOXOBJECT
			loItem = newobject("ItemSaldos")
			loItem.Valor = loSaldo.Valor
			loItem.Saldo = loSaldo.Saldo
			loItem.MedioDePago = loSaldo.MedioDePago
			this.oColSaldos.Agregar( loItem )
		endfor
		if goParametros.Felino.GestionDeVentas.IncluirLosChequesEnElComprobanteDeCajaGeneradoPorCierreAutomatico and lnIDCierre > 0
			lcEstado = this.ObtenerEstadoConcepto()
			loColaborador = _Screen.Zoo.CrearObjeto( "ColaboradorCheques", "ColaboradorCheques.prg" )
			lcFiltro = loColaborador.ObtenerCadenaEstadosDeSeleccionSegunEntidadValorMovimientoYEstado("COMPROBANTEDECAJA",12,2,lcEstado)
			loColMovimientos = this.oMovimientosCaja.ObtenerCierreDetallado( tnCaja, lnIDCierre, lcFiltro )
			for each loSaldo in loColMovimientos FOXOBJECT
				loItem = newobject("ItemSaldos")
				loItem.Valor = loSaldo.Valor
				loItem.Saldo = loSaldo.Monto
				loItem.NumeroInterno = loSaldo.NumeroInterno
				this.oColSaldos.Agregar( loItem )
			endfor
			release loColaborador
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarExistenciaDeSaldos() as Boolean 
		local llRetorno as Boolean, loItem as Object  
		llRetorno = .F.
		for each loItem in this.oColSaldos
			if !empty( loItem.saldo ) 
				llRetorno = .t.
				exit
			endif	
		endfor
				
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarEntidadComprobanteDeCaja() as Boolean 
		local llretorno as Boolean, loEntidad as ent_ComprobanteDeCaja of ent_ComprobanteDeCaja.prg, lnNumeroDeComprobante as Integer
		llRetorno = .t.
		loEntidad = _screen.zoo.instanciarentidad( "ComprobanteDeCaja" )
		with loEntidad
			.Ultimo()
			lnNumeroDeComprobante = .Numero
			.Nuevo()
			.SetearCajaEnProcesoDeCierre( this.nNumeroDeCajaEnProcesoDeCierre )
			this.TrasladarVendedorDelArqueoAlComprobante( loEntidad )
	  		loCamposObligatorios = this.ObtenerValoresCamposObligatorios()
	  		this.CargarDatosObligatoriosComprobanteDeCaja( loEntidad, loCamposObligatorios )
	  		this.CargarDetalleValores( loEntidad )
	  		if this.ValidacionAdicional( loEntidad )
				.Observacion = "Comprobante generado automáticamente al realizar el cierre de caja." + chr(13) + alltrim( .Observacion )
				.Grabar()
				if .Numero <= lnNumeroDeComprobante
					llRetorno = .f.
				endif
			else
				this.EventoAvisarObligatoriosIncompletos()
				this.EventoProcesarFormularioComprobanteDeCaja()				
			endif
			.release()
		endwith
	
		return llretorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TrasladarVendedorDelArqueoAlComprobante( toEntidad as Object ) as Void
		if this.ValidarTrasladarVendedorDelArqueoAlComprobante( toEntidad )
			toEntidad.vendedor_pk = this.oDatosDelArqueoDeCaja.cVendedor
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarTrasladarVendedorDelArqueoAlComprobante( toEntidad as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if toEntidad.cajaorigen.usavendedorarqueoencierre and vartype( this.oDatosDelArqueoDeCaja ) == "O"
			llRetorno = !empty( this.oDatosDelArqueoDeCaja.cVendedor )
			llRetorno = ( llRetorno and toEntidad.vendedor_pk != this.oDatosDelArqueoDeCaja.cVendedor )
			llRetorno = ( llRetorno and toEntidad.Caja_pk == this.oDatosDelArqueoDeCaja.nCaja )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidacionAdicional( toEntidad ) as boolean
		return toEntidad.ValidacionBasica()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoProcesarFormularioComprobanteDeCaja( ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoAvisarObligatoriosIncompletos() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAvisarFaltaParametrosFondoFijo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarCodigoConcepto() as Void
		local lcRetorno as String, loEntidad as Object, lcCodigoSugerido as String   
		lcRetorno = ""
		lcCodigoSugerido = alltrim( goParametros.Felino.GestionDeVentas.ConceptoSugeridoParaElCierreDeCaja )
		if !goParametros.Nucleo.PermiteCodigosEnMinusculas
			lcCodigoSugerido = upper( lcCodigoSugerido )
		endif
		if !empty( lcCodigoSugerido )
			loEntidad = _screen.zoo.instanciarentidad( "ConceptoCaja" )
			try
				loEntidad.Codigo = lcCodigoSugerido
                	if loEntidad.Tipo = 1
                    	lcRetorno = ""
                    else
                        lcRetorno = lcCodigoSugerido
                    endif
			catch
			finally
				loEntidad.release()	
			endtry
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarCodigoOrigen() as Void
		local lcRetorno as String, loEntidad as Object, lcCodigoSugerido as String   
		lcRetorno = ""
		lcCodigoSugerido = alltrim( goParametros.Felino.GestionDeVentas.OrigenDestinoSugeridoParaElCierreDeCaja )
		if !goParametros.Nucleo.PermiteCodigosEnMinusculas
			lcCodigoSugerido = upper( lcCodigoSugerido )
		endif
		if !empty( lcCodigoSugerido )
			loEntidad = _screen.zoo.instanciarentidad( "OrigenDeDatos" )
			try
				loEntidad.Codigo = lcCodigoSugerido
				lcRetorno = lcCodigoSugerido
			catch
			finally
				loEntidad.release()	
			endtry
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarCodigoVendedor() as Void
		local lcRetorno as String, loEntidad as Object, lcCodigoSugerido as String   
		lcRetorno = ""
		lcCodigoSugerido = alltrim( goParametros.Felino.GestionDeVentas.VendedorSugeridoParaElCierreDeCaja )
		if !goParametros.Nucleo.PermiteCodigosEnMinusculas
			lcCodigoSugerido = upper( lcCodigoSugerido )
		endif
		if !empty( lcCodigoSugerido )

			loEntidad = _screen.zoo.instanciarentidad( "Vendedor" )
			try
				loEntidad.Codigo = lcCodigoSugerido
				lcRetorno = lcCodigoSugerido
			catch
			finally
				loEntidad.release()	
			endtry
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarDatosObligatoriosComprobanteDeCaja( toEntidad as Object, toCamposObligatorios as Object ) as void

		toEntidad.tipo = 2
		this.CargarOrigenDestino( toEntidad, toCamposObligatorios.Origen )
		this.CargarConceptos( toEntidad, toCamposObligatorios.Concepto )
		this.CargarVendedor( toEntidad, toCamposObligatorios.Vendedor )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarOrigenDestino( toEntidad as Object, tcCodigoOrigen as String  ) as VOID 
		if !empty( tcCodigoOrigen ) and empty( toEntidad.OrigenDestino_pk )
			try  
				toEntidad.OrigenDestino_pk = tcCodigoOrigen
			catch
				goServicios.Errores.LevantarExcepcion( "Se produjo un error al cargar el Origen / Destino '" + tcCodigoOrigen + "'" )
			endtry 	
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarConceptos( toEntidad as Object, tcCodigoConcepto as String ) as VOID 
		if !empty( tcCodigoConcepto ) and empty( toEntidad.Concepto_pk )
			try  
				toEntidad.Concepto_pk = tcCodigoConcepto
			catch 
				goServicios.Errores.LevantarExcepcion( "Se produjo un error al cargar el concepto '" + tcCodigoConcepto + "'" )
			endtry 	
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarVendedor( toEntidad as Object, tcCodigoVendedor as String  ) as VOID 
		if !empty( tcCodigoVendedor ) and empty( toEntidad.Vendedor_pk )
			try  
				toEntidad.Vendedor_pk = tcCodigoVendedor
			catch
				goServicios.Errores.LevantarExcepcion( "Se produjo un error al cargar el Vendedor '" + tcCodigoVendedor + "'" )
			endtry 	
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValoresCamposObligatorios() as Object 
		local loCamposObligatorios as Object 
		loCamposObligatorios = createobject( "Custom" )

		addproperty( loCamposObligatorios, "Concepto", this.VerificarCodigoConcepto() )
		addproperty( loCamposObligatorios, "Origen"	 , this.VerificarCodigoOrigen() )
		addproperty( loCamposObligatorios, "Vendedor", this.VerificarCodigoVendedor() )
		addproperty( loCamposObligatorios, "DatosCompletos", !empty( loCamposObligatorios.Concepto ) and !empty( loCamposObligatorios.Origen ) and !empty( loCamposObligatorios.Vendedor )  )		

		return loCamposObligatorios 
	endfunc 

	*-----------------------------------------------------------------------------------------	*-----------------------------------------------------------------------------------------
	function CargarDetalleValores( toEntidad as Object) as Void
		local loItem as Object, llReservaFondoFijo as Boolean, lcValorFondoFijo as String, lnMontoFondoFijo as Integer, llFondoFijoReservado as Boolean, ;
			  lnMontoFijoAcumulado as Int, lcValoresInexistentes as String
		lcValoresInexistentes = ""
		if empty( toEntidad.Valores.cMonedaComprobante )
			toEntidad.Valores.cMonedaComprobante = alltrim( toEntidad.MonedaComprobante_pk )
		endif
		if empty( toEntidad.Valores.cMonedaSistema )
			toEntidad.Valores.cMonedaSistema = alltrim( toEntidad.MonedaSistema_pk )
		endif
		this.cLeyendaFondoFijo = ""
		llFondoFijoReservado = .f.
		lnMontoFijoAcumulado = 0
		llReservaFondoFijo = goParametros.Felino.GestionDeVentas.UtilizaFondoFijo
		if llReservaFondoFijo
			lcValorFondoFijo = upper( alltrim( goParametros.Felino.GestionDeVentas.ValorSugeridoParaElFondoFijo ) )
			lnMontoFondoFijo = goParametros.Felino.GestionDeVentas.MontoSugeridoDelFondoFijo
		endif

		for each loItem in this.oColSaldos
			with toEntidad.Valores
				.LimpiarItem()
				if !empty( loItem.saldo ) 
					if this.AsignarValorAlDetalle( .oItem, loItem)
						if .oItem.Valor.NoArrastraSaldo() 
							.oItem.ValorDetalle = alltrim( .oItem.Valor.descripcion )
							
							if !empty( loItem.NumeroInterno)
								.oItem.NumeroInterno = loItem.NumeroInterno
								.oItem.lHabilitarMonto = .t.
							endif

							.oItem.AsignarMontoAItem( loItem.Saldo ) 
							
							if ( llReservaFondoFijo and .oItem.Valor_PK = lcValorFondoFijo )
								lnMontoFijoAcumulado = lnMontoFijoAcumulado + .oItem.Monto
								if this.ActualizarSegunFondoFijo( .oItem, lnMontoFondoFijo )
									.Actualizar()
								endif
								llFondoFijoReservado = .t.
							else
								.Actualizar()
							endif
						endif
					else
						lcValoresInexistentes = lcValoresInexistentes + rtrim( loItem.Moneda ) + ", "

						.LimpiarItem()  
					endif
				endif	
			endwith
		endfor
		if !empty( lcValoresInexistentes )
			lcValoresInexistentes = left( lcValoresInexistentes, len( lcValoresInexistentes ) - 2 )
			if at( "," , lcValoresInexistentes ) > 0
				goServicios.Mensajes.Informar( "Los valores " + lcValoresInexistentes + " no fueron cargados porque no están dados de alta en el sistema" )
			else
				goServicios.Mensajes.Informar( "El valor " + lcValoresInexistentes + " no fue cargado porque no está dado de alta en el sistema" )
			endif
		endif
		if llReservaFondoFijo and llFondoFijoReservado and ( lnMontoFijoAcumulado < lnMontoFondoFijo )
			this.AgregarLeyendaFondoInsuficiente( lnMontoFijoAcumulado )
		endif 		

		if llReservaFondoFijo and !llFondoFijoReservado
			this.EventoAvisarFaltaParametrosFondoFijo()
		endif
		
		toEntidad.Observacion = alltrim( this.cLeyendaFondoFijo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AsignarValorAlDetalle( toItemDetalle as Object, toItemSaldo as Object) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		try 
			toItemDetalle.Valor_Pk = toItemSaldo.Valor
		catch to loError
			toItemDetalle.Valor_Pk = ""
			toItemDetalle.Limpiar()
			This.Loguear( "El valor " + rtrim( toItemSaldo.Valor ) + " no existe." + chr( 13 ) +;
				"Debe crearlo para poder utilizarlo en el comprobante de caja" )
			this.FinalizarLogueo()
			llRetorno = .F.
		endtry
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLeyendaFondoInsuficiente( tnMontoFijoAcumulado as Integer ) as Void
		local lcLeyenda as String, loValor as Object, lcSimbolo as String  
		
		this.oValor.Codigo = upper( alltrim( goParametros.Felino.GestionDeVentas.ValorSugeridoParaElFondoFijo ) )
		this.oValor.Cargar()
		lcValorFondoFijo = upper( alltrim( this.oValor.Descripcion ) )
		lcSimbolo = alltrim( this.oValor.SimboloMonetario.Simbolo )
		
		lcLeyenda = "El monto disponible para el valor " + alltrim( this.oValor.Codigo ) + " (" + lcValorFondoFijo + ") es insuficiente para cubrir el fondo fijo definido de " + lcSimbolo + ;
					transform( goParametros.Felino.GestionDeVentas.MontoSugeridoDelFondoFijo ) +  ". "
		
		if tnMontoFijoAcumulado > 0
			lcLeyenda = lcLeyenda + this.cLeyendaFondoFijo 
		endif 	
		
		this.cLeyendaFondoFijo = lcLeyenda 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarSegunFondoFijo( toItem as Object, tnMontoFondoFijo as Integer ) as Boolean 
		local llRetorno as Boolean , lnMonto as Integer, lcSimbolo as String  
		llRetorno = .t.
		lnMonto = toItem.Monto
		toItem.Monto = toItem.Monto - tnMontoFondoFijo
		if toItem.Monto <= 0
			llRetorno = .f.		
		endif
		if this.oValor.Codigo != upper( alltrim( goParametros.Felino.GestionDeVentas.ValorSugeridoParaElFondoFijo ) )
			this.oValor.Codigo = upper( alltrim( goParametros.Felino.GestionDeVentas.ValorSugeridoParaElFondoFijo ) )
			this.oValor.Cargar()
		endif 			
		lcSimbolo = alltrim( this.oValor.SimboloMonetario.Simbolo )		
		this.cLeyendaFondoFijo = "Se reservan " + lcSimbolo + iif( llRetorno ,transform( tnMontoFondoFijo ) , transform( round( lnMonto, 2 ) )) + " del valor " + alltrim( toItem.Valor_pk ) +;
			" (" + alltrim( toItem.ValorDetalle ) + ") en concepto de Fondo Fijo."

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeCerrarCaja( tnCaja ) as Void
		**Evento
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiLlenaHuecos( toHuecos ) as Void
		**Evento
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitarGenerarAnulados() as Void
		this.oControlComprobantesFaltantes.lLlenarHuecos = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesHabilitarGenerarAnulados() as Void
		this.oControlComprobantesFaltantes.lLlenarHuecos = .F.	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeGenerandoAnulados() as Void
		**Evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoQuitarMensajeGenerandoAnulados() as Void
		**Evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoExistenComprobantesEnElHueco( tcComprobantes as String, toHueco as Object ) as Void
		this.loguear( "No se puede generar automáticamente comprobantes anulados debido que al menos uno de ellos ya existe. " + ;
						"Los comprobantes que pre-existen son: " + tcComprobantes )
		this.FinalizarLogueo()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InicializaLYaGeneroContracomprobante() as Void
		this.lYaGeneroContracomprobante = .F.	
	endfunc
  
	*-----------------------------------------------------------------------------------------
	function EventoGeneraNCParaAjustesDeCupon( tnCaja as Integer ) as Void
		**Evento
	endfunc

	*-----------------------------------------------------------------------------------------
	function  EventoAdvertirFalloEnGeneraNCParaAjustesDeCupon( tcMensaje as String )  as Void
		**Evento
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarGenerarReciboAplicandoCuponesHuerfanos( tnCaja as Integer ) as Void
		**Evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoGenerarReciboAplicandoCuponesHuerfanos() as Void
		**Evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoValidarCuponesPointPendientes( tnCaja as integer ) as Void
		**Evento
	endfunc    

	*-----------------------------------------------------------------------------------------
	function EventoCancelarPedidosAPagarEnCaja() as Void
		**Evento
	endfunc 
    
    *-----------------------------------------------------------------------------------------
    function EventoCerrarLotesLaPos() as void
        **Evento
    endfunc
    
    *-----------------------------------------------------------------------------------------
	function EventoCancelarSeniasVencidas() as Void
		**Evento
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoInformarComprobantesCAEA() as Void
		**Evento
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoObtenerCAEA() as Void
		**Evento
	endfunc
    
	*-----------------------------------------------------------------------------------------
	function DebeRealizarAperturaAutomaticaDeCaja() as Void
		local llRetorno as Boolean
		if this.llNoPermitirAperturaAutomaticaDeCaja
			llRetorno = .f.
		else
			llRetorno = goParametros.Felino.GestionDeVentas.AperturaAutomaticaDeCaja
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function MensajeEspecificoDePromocionBancaria() as String
		local lcRetorno as String, lnComprobante as Integer, loComprobantes as din_Comprobante of din_Comprobante.prg
		lcRetorno = ""
		loComprobantes = newobject( "din_Comprobante", "din_Comprobante.prg" )
		lnComprobante = loComprobantes.ObtenerNumeroComprobante( goParametros.Felino.GestionDeVentas.AjusteDeCupon.TipoDeComprobanteAGenerar )
		do case
			case lnComprobante = 3
				lcRetorno = "Verifique los parámetros."
			case lnComprobante = 5
				lcRetorno = "Verifique la configuración del controlador fiscal y la conexión del mismo."
			case lnComprobante = 28
				lcRetorno = "Verifique la configuración de la factura electronica, la vigencia del certificado y la conexión a internet."
		endcase
		loComprobantes.Release()
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReferenciaAlArchivoDeLog() as String
		local lcRetorno as String, lnComprobante as Integer, loComprobantes as din_Comprobante of din_Comprobante.prg
			lcRetorno = "Para mas información revise el archivo "
			lcRetorno = lcRetorno + alltrim( _screen.zoo.cRutaInicial ) + "Log" + "\Log.err"
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExistenCuponesHuerfanos( tnCaja as Integer ) as Boolean
		local llRetorno as Boolean, loEntidad as ent_CuponesHuerfanos or ent_CuponesHuerfanos.prg
		loEntidad = _Screen.Zoo.InstanciarEntidad( "CuponesHuerfanos" )
		llRetorno = loEntidad.ObtenerCantidadDeCuponesHuerfanosPorCaja( tnCaja ) > 0
		loEntidad.Release()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroDeCajaAUsarEnValores() as Integer
		local lnNumeroDeCaja as Integer
		if this.HaySeteadoUnNumeroDeCajaEnProcesoDeCierre()
			lnNumeroDeCaja = this.nNumeroDeCajaEnProcesoDeCierre
		else
			lnNumeroDeCaja = this.ObtenerNumeroDeCajaActiva()
		endif
		return lnNumeroDeCaja
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HaySeteadoUnNumeroDeCajaEnProcesoDeCierre as Boolean
		return ( this.nNumeroDeCajaEnProcesoDeCierre <> 0 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarRegistroFaltanteDeCajaAuditoria( tnIdCajaAudi as Integer, tnCaja as Integer ) as Void
		local lcQuery as String
		
		lcQuery = "Insert into Zoologic.CajaAudi (Codigo, fecha, montotot, numcaja,tarea ) values ( " + transform( tnIdCajaAudi ) + ", getdate(), 0, " + transform( tnCaja ) + ", 'CIERRE' )"
		goServicios.Datos.EjecutarSentencias( lcQuery, "CAJAAUDI", "", "", This.DatasessionId )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ConsultarDispositivoPoint() as Boolean
		local llRetorno as boolean
		llRetorno = .f.
		goServicios.Datos.EjecutarSentencias( "Select top 1 codigo from Pos where pagoelec = 1 and integrado = 1", "Pos", "", "c_DipositivoPoint", this.DataSessionId )
		llRetorno = reccount() > 0
		use in ( "c_DipositivoPoint" )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemValor( toItem as Object ) as String
		local lcRetorno as String
		lcRetorno = ""
		if vartype( toItem ) = "O" and !isnull( toItem ) and type( "toItem.Tipo" ) = "N"
			do case
			case inlist( toItem.Tipo, TIPOVALORCHEQUETERCERO, TIPOVALORCIRCUITOCHEQUETERCERO)
				lcRetorno = toItem.NumeroCheque_PK
			case inlist( toItem.Tipo, TIPOVALORCHEQUEPROPIO)
				lcRetorno = toItem.NumeroChequePropio_PK
			endcase
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeCaja( tnIdCaja as Integer ) as String
		local lcDescripcion as String, lcXml as String, lcCursor as String
		lcDescripcion = ""
		lcCursor = 'C' + sys( 2015 )
		lcXml = this.oCajaEstado.oAD.ObtenerDatosEntidad( "Descripcion", "id = " + alltrim( str( tnIdCaja ) ) )
		XmlToCursor( lcXml, lcCursor )
		if used( lcCursor ) and reccount( lcCursor ) = 1
			lcDescripcion = &lcCursor..Descripcion
		endif
		use in select( lcCursor )
		return lcDescripcion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstadoConcepto() as String
		local lcRetorno as String, loEntidad as Object, lcCodigoSugerido as String   
		lcRetorno = ""
		lcCodigoSugerido = alltrim( goParametros.Felino.GestionDeVentas.ConceptoSugeridoParaElCierreDeCaja )
		if !goParametros.Nucleo.PermiteCodigosEnMinusculas
			lcCodigoSugerido = upper( lcCodigoSugerido )
		endif
		if !empty( lcCodigoSugerido )
			loEntidad = _screen.zoo.instanciarentidad( "ConceptoCaja" )
			try
				loEntidad.Codigo = lcCodigoSugerido
                	if loEntidad.Tipo = 1
                    	lcRetorno = ""
                    else
                        lcRetorno = iif(empty(loEntidad.EstadoCheque),"ENTRE",loEntidad.EstadoCheque)
                    endif
			catch
			finally
				loEntidad.release()	
			endtry
		endif
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SeDebeVisualizarEnCaja( toItem as Object ) as Boolean 
		local llRetorno as Boolean 
		if !inlist( toItem.Tipo, TIPOVALORCUENTACORRIENTE, TIPOVALORCUENTABANCARIA )
			llRetorno = .t.
		else
			if pemstatus(toItem, "VisualizarEnEstadoDeCaja",5)
				llRetorno = toItem.VisualizarEnEstadoDeCaja
			else
				llRetorno = .t.
			endif
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoRevisarComprobantesDeContingenciaUruguaySinCAE() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarSaldosValoresNoProcesablesEnCierreDeCaja( tnCaja as Integer ) as Void
		local lcSentencia as String 
		lcSentencia = "delete from [" + _screen.zoo.app.nombreProducto + "_" + _screen.zoo.app.csucursalactiva + "].[ZooLogic].[CAJASALD]" 
		lcSentencia = lcSentencia + " where (" + this.oValor.ObtenerCondicionDeValoresNoProcesablesEnCierreDeCaja() + ") and numCaja = " + transform( tnCaja )
		goServicios.Datos.EjecutarSentencias( lcSentencia, "CajaSald", "", "", this.DataSessionId )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerConfiguracionDeAlivioDeCaja( tcBase as String, tnCaja as Integer  ) as Collection
		local loRetorno as Collection, lcSentencia as String, lcCursor as String, loitem as Object 
		
		loRetorno = _screen.zoo.crearobjeto( "Zoocoleccion" )
		lcSentencia ="select a.codigo, a.TIPOALIVIO, det.VALOR, det.Valordesc, det.MONTOADV,det.MONTOMAX"
		lcSentencia = lcSentencia +" from <<ESQUEMA>>.ALIVIO a  left join <<ESQUEMA>>.ALIVIODET det on det.CODIGO = a.CODIGO "
		lcSentencia = lcSentencia +" where a.BASEDATOS = '"+ tcBase +"' and det.CAJA = " + transform( tnCaja )
		lcCursor = "c_" + sys(2015)
		goServicios.Datos.EjecutarSentencias( lcSentencia, "ALIVIO,ALIVIODET", "", lcCursor, set( "Datasession" ) )

		select ( lcCursor )
		scan
			loitem = newobject("itemaliviodecaja","Componente.prg")
			with loitem
				.Valor = valor
				.MontoDeAdvertencia = montoadv
				.MontoMaximo = montomax
				.TipoControl = tipoalivio
				.ValorDescripcion = rtrim(valordesc)
			endwith 
			loRetorno.Add(loItem, rtrim(valor) )
		endscan
		
		use in select( lcCursor )

		
		return loRetorno

	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
define Class auxCupon as Custom

	Valor = ""
	Cotiza = 0
	Caja = 0
	Detalle = ""
	Monto = 0.00

	*-----------------------------------------------------------------------------------------
	function Init( toCupon as Object ) as Void
		with This
			.Caja = toCupon.Caja_PK
			.Valor = toCupon.Valor_pk
			.Monto = toCupon.Monto
			.Cotiza = toCupon.Cotiza
			.Detalle = toCupon.ValorDetalle
		EndWith
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class fechaYHoraDeUltimaApertura as Custom

	Fecha = {}
	Hora = ""

enddefine

*-----------------------------------------------------------------------------------------
define class ItemSaldos as Custom

	Valor = ""
	Saldo = 0
	MedioDePago = ""
	NumeroInterno = ""

enddefine

define class ItemAlivioDeCaja as Custom
	Valor = ""
	MontoDeAdvertencia = 0
	MontoMaximo = 0
	TipoControl = 0
	ValorDescripcion = ""

enddefine
