*---------------------------------------------------------------------
* mainTest.prg
* Punto de entrada principal para la ejecucion de tests
*---------------------------------------------------------------------

LOCAL loTestInit

TRY
	*-- En modo COM (DOVFP), _VFP.AutoYield es .F. por default.
	*-- En modo EXE/IDE es .T. por default.
	_VFP.AutoYield = .T.

	ValidarBaseDeDatosRequeridas()

	SET PROCEDURE TO DovfpTestInit.fxp ADDITIVE

	loTestInit = CREATEOBJECT("DovfpTestInit")
	
	*-- 1. PRIMERO: Seteos basicos (carga AppReferences, crea _instanceFactory, goDoVfpMock)
	loTestInit.SeteosBasicos()
	
	*-- 2. Registrar MockSetupRegistry (necesita estar despues de SeteosBasicos)
	loTestInit.RegistrarMockSetupRegistry("OrganicGeneratorMockSetupRegistry", "OrganicGeneratorMockSetupRegistry.prg")

	InstanciarMocksGlobales()

	goDovfpTestInit.InstanciarZooMock()
	goDovfpTestInit.InstanciarZooAplicacion("Generadores")

	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "adn\dbc\") ADDITIVE
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "clasesdeprueba\") ADDITIVE
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "data\") ADDITIVE

	_screen.Zoo.App.cSucursalActiva = "GATOS"

CATCH TO loException
	lcConsolidatedMsg = ExtraerInfoCompletaExcepcion( loException )
	ERROR lcConsolidatedMsg
ENDTRY


*-----------------------------------------------------------------------------------------
* Extrae toda la informacion util de una excepcion, recorriendo recursivamente UserValue
* Ignora excepciones "pasa mano" (User Thrown Error) y extrae info de ZooException
*-----------------------------------------------------------------------------------------
FUNCTION ExtraerInfoCompletaExcepcion( toException as Exception ) as String
	LOCAL lcResult as String, loCurrentEx as Object, lnNivel as Integer
	LOCAL lcMensaje as String, lcInfo as String, lcStack as String, llEsPasaMano as Boolean
	
	lcResult = ""
	loCurrentEx = toException
	lnNivel = 0
	
	* Recorrer toda la cadena de excepciones anidadas
	DO WHILE VARTYPE(loCurrentEx) = "O" AND !ISNULL(loCurrentEx)
		lnNivel = lnNivel + 1
		lcMensaje = ""
		lcInfo = ""
		lcStack = ""
		
		* Determinar si es una excepcion "pasa mano" (solo hace throw sin info real)
		llEsPasaMano = .F.
		IF PEMSTATUS(loCurrentEx, "Message", 5)
			lcMensaje = ALLTRIM(loCurrentEx.Message)
			* Si el mensaje es generico de User Thrown Error, es un pasa mano
			IF UPPER(lcMensaje) == "USER THROWN ERROR" OR ;
			   UPPER(lcMensaje) == "USER THROWN ERROR ." OR ;
			   EMPTY(lcMensaje)
				llEsPasaMano = .T.
			ENDIF
		ENDIF
		
		* Solo agregar info si NO es pasa mano
		IF !llEsPasaMano
			* Agregar separador de nivel si hay info previa
			IF !EMPTY(lcResult)
				lcResult = lcResult + CHR(13) + CHR(10) + "--- Nivel " + TRANSFORM(lnNivel) + " ---" + CHR(13) + CHR(10)
			ENDIF
			
			* Mensaje principal
			IF !EMPTY(lcMensaje)
				lcResult = lcResult + "Mensaje: " + lcMensaje + CHR(13) + CHR(10)
			ENDIF
			
			* ErrorNo (si es significativo)
			IF PEMSTATUS(loCurrentEx, "ErrorNo", 5) AND loCurrentEx.ErrorNo > 0 AND loCurrentEx.ErrorNo <> 2071
				lcResult = lcResult + "ErrorNo: " + TRANSFORM(loCurrentEx.ErrorNo) + CHR(13) + CHR(10)
			ENDIF
			
			* Procedure y LineNo
			IF PEMSTATUS(loCurrentEx, "Procedure", 5) AND !EMPTY(loCurrentEx.Procedure)
				lcResult = lcResult + "Procedure: " + loCurrentEx.Procedure
				IF PEMSTATUS(loCurrentEx, "LineNo", 5) AND loCurrentEx.LineNo > 0
					lcResult = lcResult + " (Linea: " + TRANSFORM(loCurrentEx.LineNo) + ")"
				ENDIF
				lcResult = lcResult + CHR(13) + CHR(10)
			ENDIF
			
			* Details
			IF PEMSTATUS(loCurrentEx, "Details", 5) AND !EMPTY(loCurrentEx.Details)
				lcResult = lcResult + "Details: " + ALLTRIM(loCurrentEx.Details) + CHR(13) + CHR(10)
			ENDIF
			
			* LineContents
			IF PEMSTATUS(loCurrentEx, "LineContents", 5) AND !EMPTY(loCurrentEx.LineContents)
				lcResult = lcResult + "LineContents: " + ALLTRIM(loCurrentEx.LineContents) + CHR(13) + CHR(10)
			ENDIF
			
			* ObtenerTextoInformacion (metodo de ZooException)
			IF PEMSTATUS(loCurrentEx, "ObtenerTextoInformacion", 5)
				TRY
					lcInfo = loCurrentEx.ObtenerTextoInformacion()
					IF !EMPTY(lcInfo)
						lcResult = lcResult + "Info: " + lcInfo + CHR(13) + CHR(10)
					ENDIF
				CATCH
					* Ignorar errores al obtener info
				ENDTRY
			ENDIF
			
			* TengoInformacion + oInformacion (alternativa)
			IF PEMSTATUS(loCurrentEx, "TengoInformacion", 5)
				TRY
					IF loCurrentEx.TengoInformacion() AND PEMSTATUS(loCurrentEx, "oInformacion", 5)
						IF PEMSTATUS(loCurrentEx.oInformacion, "SerializarInformacion", 5)
							lcInfo = loCurrentEx.oInformacion.SerializarInformacion()
							IF !EMPTY(lcInfo) AND !(lcInfo $ lcResult)
								lcResult = lcResult + "Informacion: " + lcInfo + CHR(13) + CHR(10)
							ENDIF
						ENDIF
					ENDIF
				CATCH
					* Ignorar errores
				ENDTRY
			ENDIF
			
			* cStackInfo (propiedad de ZooException)
			IF PEMSTATUS(loCurrentEx, "cStackInfo", 5) AND !EMPTY(loCurrentEx.cStackInfo)
				lcStack = loCurrentEx.cStackInfo
				* Solo agregar si no esta ya en el resultado (evitar duplicados)
				IF !(lcStack $ lcResult)
					lcResult = lcResult + "Stack: " + lcStack + CHR(13) + CHR(10)
				ENDIF
			ENDIF
		ENDIF
		
		* Avanzar al siguiente nivel (UserValue)
		IF PEMSTATUS(loCurrentEx, "UserValue", 5) AND VARTYPE(loCurrentEx.UserValue) = "O"
			loCurrentEx = loCurrentEx.UserValue
		ELSE
			EXIT
		ENDIF
		
		* Limite de seguridad para evitar loops infinitos
		IF lnNivel > 20
			lcResult = lcResult + CHR(13) + CHR(10) + "*** ADVERTENCIA: Se alcanzo el limite de niveles de excepcion ***"
			EXIT
		ENDIF
	ENDDO
	
	* Si no se encontro nada util, devolver el mensaje original
	IF EMPTY(lcResult)
		lcResult = "Sin informacion detallada disponible"
		IF VARTYPE(toException) = "O" AND PEMSTATUS(toException, "Message", 5)
			lcResult = lcResult + " - Mensaje original: " + ALLTRIM(toException.Message)
		ENDIF
	ENDIF
	
	RETURN lcResult
ENDFUNC

*-----------------------------------------------------------------------------------------
* Instancia todos los mocks globales necesarios para los tests
* Estos mocks son compartidos por todos los tests del proyecto
*-----------------------------------------------------------------------------------------
FUNCTION InstanciarMocksGlobales() As Void
	LOCAL loMock, loMockManager, loSetup

	*-- ManagerEjecucion (DEBE ir al principio para evitar inicialización de AAO)
	*-- Al devolver TieneScriptCargado() = .T., se omite la verificación del AAO
	loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
	loSetup = loMock.Setup("TieneScriptCargado")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("EjecutarAplicacion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	loMock = goDoVfpMock.Mock("ManagerExportaciones", "ManagerExportaciones.prg", "STRICT")

	LOCAL loMockAccionesAutomaticas
	loMockAccionesAutomaticas = goDoVfpMock.Mock("ManagerAccionesAutomaticas", "ManagerAccionesAutomaticas.prg", "LOOSE")
	loSetup = loMockAccionesAutomaticas.Setup("LaEntidadTieneAccionesAutomaticas")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)
	loSetup = loMockAccionesAutomaticas.Setup( 'LaEntidadTieneAccionesAutomaticas' )
	loSetup.Returns(.F.)
	loSetup = loMockAccionesAutomaticas.Setup("CantidadDeEntidadesQueTienenAccionesAutomaticas")
	loSetup.Returns(0)
	loSetup = loMockAccionesAutomaticas.Setup("LaEntidadTieneIniciarDespuesDeGuardar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)

	loMock = goDoVfpMock.Mock("ManagerEntidades", "ManagerEntidades.prg", "LOOSE")
	loSetup = loMock.SetupGet("AccionesAutomaticas")
	loSetup.Returns(loMockAccionesAutomaticas.Object)
	loSetup = loMock.Setup("ObtenerEntidad")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(NULL)
	loSetup = loMock.Setup("ExisteEntidad")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)

	loMock = goDoVfpMock.Mock("Multimedia", "Multimedia.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ManagerImportaciones", "ManagerImportaciones.prg", "STRICT")
	&& loMock = goDoVfpMock.Mock("ManagerListados", "ManagerListados.prg", "STRICT")
	loMock = goDoVfpMock.Mock("Memoria", "Memoria.prg", "STRICT")
	loSetup = loMock.Setup("SetearDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("GrabarDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	&& loMock = goDoVfpMock.Mock("ManagerImpresion", "ManagerImpresion.prg", "STRICT")
	&& loSetup = loMock.Setup("DebeGenerarPDFsDeDisenosAutomaticamente")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(.F.)

	loMock = goDoVfpMock.Mock("ServicioEstructura", "ServicioEstructura.prg", "STRICT")

	PUBLIC goDovfpMockMensajes
	goDovfpMockMensajes = goDoVfpMock.Mock("Mensajes", "Mensajes.prg", "LOOSE")
	loSetup = goDovfpMockMensajes.Setup("EnviarSinEspera")
	loSetup.Returns(.T.)
	loSetup = goDovfpMockMensajes.Setup("Enviar")
	loSetup.Returns(.T.)
	loSetup = goDovfpMockMensajes.Setup("EnviarSinEsperaProcesando")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	loMock = goDoVfpMock.Mock("TimerBase", "TimerBase.prg", "LOOSE")
	loSetup = loMock.Setup("InicializarTimers")
	loSetup.Returns(.T.)
	loMock.Setup("MatarTodosLosTimers")
	loSetup = loMock.Setup("MatarUnTimerEspecifico")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("FrenarTodosLosTimers")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("CrearNuevoTimer")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(1)
	loSetup = loMock.Setup("CrearNuevoTimer")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(1)

	loMock = goDoVfpMock.Mock("ManagerConsultaAFIP", "ManagerConsultaAFIP.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ManagerWebHook", "ManagerWebHook.prg", "STRICT")
	loMock = goDoVfpMock.Mock("Terminal", "Terminal.prg", "LOOSE")
	loSetup = loMock.Setup("ObtenerOtraTerminalConSerie")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("DesconectarOtrasTerminalesPorInactividad")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Registrar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Desregistrar")
	loSetup.Returns(.T.)
	loMock = goDoVfpMock.Mock("ServicioSaltosDeCampoYValoresSugeridos", "ServicioSaltosDeCampoYValoresSugeridos.prg", "LOOSE")
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerValorSugeridoDeUnaEntidadDetalle")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("ObtenerColeccionAtributosObligatorios")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("ObtenerColeccionAtributosNoVisibles")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))

	loSetup = loMock.Setup("ObtenerPersonalizacionDeEtiquetas")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))


	loMock = goDoVfpMock.Mock("ServicioPersonalizacionDeEntidades", "ServicioPersonalizacionDeEntidades.prg", "LOOSE")
	loSetup = loMock.Setup("ObtenerPersonalizacionEntidad")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("TienePersonalizacion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerEntidadesAOcultar")
	loSetup.Returns(CREATEOBJECT("MockColeccionBusqueda"))

	loMock = goDoVfpMock.Mock("ServicioRegistroDeActividad", "ServicioRegistroDeActividad.prg", "LOOSE")
	loSetup = loMock.Setup("EstaHabilitado")
	loSetup.Returns(.F.)
	loSetup = loMock.SetupGet("lEstaHabilitado")
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("IniciarRegistro")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
	loSetup = loMock.Setup("FinalizarRegistro")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("HabilitarTrazaExtendidaMensajeria")
	loSetup.Returns(.T.)
    loSetup = loMock.Setup("DeshabilitarTrazaExtendidaMensajeria")
    loSetup.Returns(.T.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)
	loMock = goDoVfpMock.Mock("ServicioMonitorSaludBasesDeDatos", "ServicioMonitorSaludBasesDeDatos.prg", "STRICT")

	loMock = goDoVfpMock.Mock("SerializadorDeEntidades", "SerializadorDeEntidades.prg", "STRICT")
	loMock = goDoVfpMock.Mock("WindowsToastNotification", "WindowsToastNotification.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ServicioNotificacionEnSegundoPlano", "ServicioNotificacionEnSegundoPlano.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ColaboradorDecimalesEnCantidad", "ColaboradorDecimalesEnCantidad.prg", "LOOSE")
	loSetup = loMock.Setup("AjustarMascara")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerDecimalesSegunAtributo")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(0)

	loMock = goDoVfpMock.Mock("tiemporeal", "tiemporeal.prg", "LOOSE")
	loMock.Setup("EscucharAccesoADatos")
	loSetup = loMock.Setup("ObtenerTagEstimulo")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
	loSetup = loMock.Setup("ProcesarBuffers")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerTagExcluirSentenciaSQL")
	loSetup.Returns("")

	loMock = goDoVfpMock.Mock("ManagerMercadoPago", "ManagerMercadoPago.prg", "STRICT")

	&& loMock = goDoVfpMock.Mock("ManagerMonitor", "ManagerMonitor.prg", "STRICT")
	&& loSetup = loMock.Setup("EnviarTransferencia")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())

	&& loMockDominios = goDoVfpMock.Mock("Dominios", "Dominios.prg", "LOOSE")

	&& loMock = goDoVfpMock.Mock("ServicioControles", "ServicioControles.prg", "LOOSE")
	&& loSetup = loMock.SetupGet("oDominios")
	&& loSetup.Returns(loMockDominios.Object)

	loMock = goDoVfpMock.Mock("ConfigurarAgenteDeAccionesOrganic", "ConfigurarAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("ConfigurarAgentePorActualizacion")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ConfigurarAgenteInicial")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Configurar")
	loSetup.Returns(.T.)

	&& Mocks para objetos _Access de AplicacionBase
	loMock = goDoVfpMock.Mock("PoolDeConexiones", "PoolDeConexiones.prg", "LOOSE")
	loSetup = loMock.Setup("DesconectarTodo")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("DevolverConexion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerConexion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(NULL)

	loMock = goDoVfpMock.Mock("AspectoAplicacion", "AspectoAplicacion.prg", "LOOSE")
	loSetup = loMock.Setup("ObtenerNombreEdicion")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerPieIzquierdoAbm")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerPieDerechoAbm")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerIconoDeLaAplicacion")
	loSetup.Returns("IconoGENERADORES.ico")
	loSetup = loMock.Setup("ObtenerPieIzquierdoListado")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerPieDerechoListado")
	loSetup.Returns("")

ENDFUNC

*-----------------------------------------------------------------------------------------
* Clase helper para mockear colecciones con método Buscar
*-----------------------------------------------------------------------------------------
DEFINE CLASS MockColeccionBusqueda AS Custom
    FUNCTION Buscar(tcValor)
        RETURN .F.  && No encuentra nada - no hay entidades a ocultar
    ENDFUNC
ENDDEFINE

*-----------------------------------------------------------------------------------------
* Callbacks para capturar argumentos de mensajes
* Cada callback tiene la firma exacta del método que intercepta
* NOTA: dovfp pasa los argumentos del método mockeado directamente a Invoke()
*-----------------------------------------------------------------------------------------

*-- Callback para EnviarSinEspera(tcMensaje, tcTitulo, tcTextoBoton)
DEFINE CLASS CallbackEnviarSinEspera AS Custom
	oMensajesCapturados = .NULL.

	FUNCTION Init(toCollection)
		THIS.oMensajesCapturados = m.toCollection
	ENDFUNC
	
	FUNCTION Invoke
		LPARAMETERS tcMensaje, tcTitulo, tcTextoBoton
		LOCAL loCaptura
		loCaptura = CREATEOBJECT("Empty")
		ADDPROPERTY(loCaptura, "Metodo", "EnviarSinEspera")
		ADDPROPERTY(loCaptura, "Mensaje", EVL(m.tcMensaje, ""))
		ADDPROPERTY(loCaptura, "Titulo", EVL(m.tcTitulo, ""))
		ADDPROPERTY(loCaptura, "Timestamp", DATETIME())
		THIS.oMensajesCapturados.Add(loCaptura)
	ENDFUNC
ENDDEFINE

*-- Callback para Enviar(tcMensaje, tcTitulo, tnTipoIcono)
DEFINE CLASS CallbackEnviar AS Custom
	oMensajesCapturados = .NULL.

	FUNCTION Init(toCollection)
		THIS.oMensajesCapturados = m.toCollection
	ENDFUNC
	
	FUNCTION Invoke
		LPARAMETERS tcMensaje, tcTitulo, tnTipoIcono
		LOCAL loCaptura
		loCaptura = CREATEOBJECT("Empty")
		ADDPROPERTY(loCaptura, "Metodo", "Enviar")
		ADDPROPERTY(loCaptura, "Mensaje", EVL(m.tcMensaje, ""))
		ADDPROPERTY(loCaptura, "Titulo", EVL(m.tcTitulo, ""))
		ADDPROPERTY(loCaptura, "TipoIcono", EVL(m.tnTipoIcono, 0))
		ADDPROPERTY(loCaptura, "Timestamp", DATETIME())
		THIS.oMensajesCapturados.Add(loCaptura)
	ENDFUNC
ENDDEFINE

*-- Callback para EnviarSinEsperaProcesando(tcMensaje, tcTitulo, tcTextoBoton, tlNoHacePausa)
DEFINE CLASS CallbackEnviarSinEsperaProcesando AS Custom
	oMensajesCapturados = .NULL.
	
	FUNCTION Init(toCollection)
		THIS.oMensajesCapturados = m.toCollection
	ENDFUNC
	
	FUNCTION Invoke
		LPARAMETERS tcMensaje, tcTitulo, tcTextoBoton, tlNoHacePausa
		LOCAL loCaptura
		loCaptura = CREATEOBJECT("Empty")
		ADDPROPERTY(loCaptura, "Metodo", "EnviarSinEsperaProcesando")
		ADDPROPERTY(loCaptura, "Mensaje", EVL(m.tcMensaje, ""))
		ADDPROPERTY(loCaptura, "Titulo", EVL(m.tcTitulo, ""))
		ADDPROPERTY(loCaptura, "Timestamp", DATETIME())
		THIS.oMensajesCapturados.Add(loCaptura)
	ENDFUNC
ENDDEFINE


*-----------------------------------------------------------------------------------------
* Funcion helper: Limpiar mensajes capturados
* Usar en Setup() de cada test para comenzar con coleccion limpia
*-----------------------------------------------------------------------------------------
FUNCTION LimpiarMensajesCapturados() AS Void
	IF TYPE("goDovfpTestInit.oMockSetupRegistry") = "O" AND !ISNULL(goDovfpTestInit.oMockSetupRegistry)
		IF !ISNULL(goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados)
			DO WHILE goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados.Count > 0
				goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados.Remove(1)
			ENDDO
		ENDIF
	ENDIF
ENDFUNC


*-----------------------------------------------------------------------------------------
* Funcion helper: Obtener mensajes capturados como string
* Retorna todos los mensajes concatenados con saltos de linea
*-----------------------------------------------------------------------------------------
FUNCTION ObtenerMensajesCapturados() AS String
	LOCAL lcResultado, i, loMensaje, loCol
	
	lcResultado = ""
	
	IF TYPE("goDovfpTestInit.oMockSetupRegistry") = "O" AND !ISNULL(goDovfpTestInit.oMockSetupRegistry)
		loCol = goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados
		IF !ISNULL(loCol)
			FOR i = 1 TO loCol.Count
				loMensaje = loCol.Item(i)
				
				IF i > 1
					lcResultado = lcResultado + CHR(13) + CHR(10) + "---" + CHR(13) + CHR(10)
				ENDIF
				
				lcResultado = lcResultado + ;
					"[" + loMensaje.Metodo + "] " + ;
					loMensaje.Mensaje + ;
					IIF(!EMPTY(loMensaje.Titulo), " (" + loMensaje.Titulo + ")", "")
			ENDFOR
		ENDIF
	ENDIF
	
	RETURN lcResultado
ENDFUNC


*=========================================================================================
* CLASES DE CALLBACK PARA CAPTURAR ERRORES LOGUEADOS
*=========================================================================================

*-- Callback para ObtenerObjetoLogueo (captura info de quién pide el logueo)
DEFINE CLASS CallbackObtenerObjetoLogueo AS Custom
	oErroresCapturados = .NULL.
	
	FUNCTION Init(toCollection)
		THIS.oErroresCapturados = m.toCollection
	ENDFUNC
	
	FUNCTION Invoke
		LPARAMETERS toQuienPide
		*-- No capturamos aquí, capturamos en MockObjetoLogueo.Escribir()
	ENDFUNC
ENDDEFINE


*-- Mock de ObjetoLogueo que captura el texto de error cuando se escribe
DEFINE CLASS MockObjetoLogueo AS Custom
	oErroresCapturados = .NULL.
	cIdLogueo = ""
	cLogger = ""
	cClaseOrigen = ""
	oUltimoLog = .NULL.
	NivelParaLogueoPorDefecto = 4
	Accion = ""
	
	FUNCTION Init(toCollection)
		THIS.oErroresCapturados = m.toCollection
		THIS.cIdLogueo = SYS(2015)  && Generar ID único
	ENDFUNC
	
	*-- Método que captura el error cuando se escribe
	*-- Firma: Escribir(tcTexto, tnNivelLog) - tnNivelLog es opcional
	FUNCTION Escribir(tcTexto, tnNivelLog)
		LOCAL loCaptura
		loCaptura = CREATEOBJECT("Empty")
		ADDPROPERTY(loCaptura, "TextoError", EVL(m.tcTexto, ""))
		ADDPROPERTY(loCaptura, "ClaseOrigen", THIS.cClaseOrigen)
		ADDPROPERTY(loCaptura, "Logger", THIS.cLogger)
		ADDPROPERTY(loCaptura, "NivelLog", EVL(m.tnNivelLog, THIS.NivelParaLogueoPorDefecto))
		ADDPROPERTY(loCaptura, "Timestamp", DATETIME())
		THIS.oErroresCapturados.Add(loCaptura)
	ENDFUNC
	
	*-- Métodos adicionales que puede necesitar ObjetoLogueo
	FUNCTION EscribirAlUltimo(tcTexto)
	ENDFUNC
	
	FUNCTION Release
	ENDFUNC
ENDDEFINE



*-----------------------------------------------------------------------------------------
* Valida que todas las bases de datos requeridas esten disponibles
* Llama a run-adnImplant.ps1 -Validate y lanza excepcion si falta alguna base
*-----------------------------------------------------------------------------------------
FUNCTION ValidarBaseDeDatosRequeridas() AS Void
	LOCAL lcScriptPath, lcCommand, lnExitCode, lcErrorMsg
	LOCAL loShell, loExec, lcSearchPath, i
	
	*-- Obtener directorio de trabajo actual (bin\Test cuando dovfp ejecuta)
	lcSearchPath = SYS(5) + SYS(2003)
	
	*-- Subir 3 niveles desde bin\Test hasta Organic.Core
	*-- bin\Test -> bin -> Organic.Tests -> Organic.Core
	FOR i = 1 TO 3
		lcSearchPath = FULLPATH(ADDBS(lcSearchPath) + "..")
	ENDFOR
	lcSearchPath = ADDBS(lcSearchPath)
	
	lcScriptPath = lcSearchPath + "run-adnImplant.ps1"
	
	*-- Ejecutar PowerShell invisible usando Run() con archivo temporal
	*-- PowerShell escribe el output con Out-File, luego VFP lo lee
	
	TRY
		*-- Crear archivo temporal para capturar output
		LOCAL lcTempFile
		lcTempFile = ADDBS(SYS(2023)) + SYS(2015) + ".txt"
		
		*-- Escapar comillas simples en rutas para PowerShell
		LOCAL lcScriptEscaped, lcTempEscaped
		lcScriptEscaped = STRTRAN(m.lcScriptPath, "'", "''")
		lcTempEscaped = STRTRAN(m.lcTempFile, "'", "''")
		
		*-- Comando PowerShell que ejecuta script y guarda output en archivo
		LOCAL lcPSCommand
		TEXT TO lcPSCommand TEXTMERGE NOSHOW
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& {try { & '<<lcScriptEscaped>>' -Validate *>&1 | Out-File -FilePath '<<lcTempEscaped>>' -Encoding UTF8; exit $LASTEXITCODE } catch { $_ | Out-File -FilePath '<<lcTempEscaped>>' -Encoding UTF8; exit 1 }}"
		ENDTEXT
		
		*-- Ejecutar con ventana oculta (0) y esperar a que termine (.T.)
		LOCAL loShell
		loShell = CREATEOBJECT("WScript.Shell")
		lnExitCode = loShell.Run(m.lcPSCommand, 0, .T.)
		
		*-- Esperar brevemente a que el archivo se escriba
		LOCAL lnAttempts
		lnAttempts = 0
		DO WHILE !FILE(m.lcTempFile) AND lnAttempts < 10
			INKEY(0.1)
			lnAttempts = lnAttempts + 1
		ENDDO
		
		*-- Leer resultado del archivo temporal
		lcErrorMsg = ""
		IF FILE(m.lcTempFile)
			lcErrorMsg = FILETOSTR(m.lcTempFile)
			*-- Eliminar archivo temporal
			TRY
				DELETE FILE (m.lcTempFile)
			CATCH
				*-- Ignorar error si no se puede eliminar
			ENDTRY
		ELSE
			lcErrorMsg = "No se pudo capturar output del script PowerShell (archivo temporal no creado)"
		ENDIF
		
	CATCH TO loShellError
		*-- Limpiar archivo temporal si existe
		IF !EMPTY(m.lcTempFile) AND FILE(m.lcTempFile)
			TRY
				DELETE FILE (m.lcTempFile)
			CATCH
			ENDTRY
		ENDIF
		ERROR "Error ejecutando validacion de base de datos: " + loShellError.Message
		RETURN
	ENDTRY
	
	*-- Si exit code != 0, lanzar error VFP con mensaje claro
	IF m.lnExitCode != 0
		LOCAL lcMensajeFinal
		
		*-- Limpiar output: quitar espacios extras y normalizar saltos de linea
		lcErrorMsg = STRTRAN(STRTRAN(m.lcErrorMsg, CHR(13)+CHR(10), CHR(10)), CHR(13), CHR(10))
		lcErrorMsg = STRTRAN(m.lcErrorMsg, CHR(10), CHR(13)+CHR(10))
		
		*-- Construir mensaje completo en variable (evita LineContents con concatenaciones)
		lcMensajeFinal = "VALIDACION DE BASE DE DATOS FALLIDA" + CHR(13) + CHR(10) + ;
			CHR(13) + CHR(10) + ;
			"Output de PowerShell:" + CHR(13) + CHR(10) + ;
			REPLICATE("-", 60) + CHR(13) + CHR(10) + ;
			m.lcErrorMsg + CHR(13) + CHR(10) + ;
			REPLICATE("-", 60) + CHR(13) + CHR(10) + ;
			CHR(13) + CHR(10) + ;
			"Los tests no pueden ejecutarse sin las bases de datos requeridas." + CHR(13) + CHR(10) + ;
			"Ejecute: run-adnImplant.ps1 para crear las bases faltantes"
		
		ERROR m.lcMensajeFinal
	ENDIF
ENDFUNC
