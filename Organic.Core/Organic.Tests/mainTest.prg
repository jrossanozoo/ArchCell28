*---------------------------------------------------------------------
* mainTest.prg
* Punto de entrada principal para la ejecucion de tests
*---------------------------------------------------------------------

LOCAL loTestInit

TRY
	*-- Modo unattended: convierte dialogos modales en errores capturables.
	*-- Critico para CI/CD (Azure DevOps) donde no hay desktop interactivo.
	&& IF !EMPTY(GETENV("TF_BUILD"))
	&& 	SYS(2335, 0)
	&& endif
	*-- En modo COM (DOVFP), _VFP.AutoYield es .F. por default.
	*-- En modo EXE/IDE es .T. por default.
	_VFP.AutoYield = .T.

	*-- En CI/CD, el pipeline ejecuta ADN Implant y prerequisitos en steps dedicados.
	*-- NO ejecutar EjecutarScriptPowerShell desde mainTest.prg en modo COM (dovfp):
	*-- VFP ejecuta DO mainTest.prg como llamada COM sincrona, y durante el loop
	*-- INKEY(0.5) de EjecutarScriptPowerShell, VFP no puede responder a heartbeats
	*-- COM de dovfp. Tras 180s sin respuesta, dovfp mata el worker ? death loop.
	IF EMPTY(GETENV("TF_BUILD"))
		ValidarBaseDeDatosRequeridas()
		ValidarPrerequisitos()
	ENDIF
	
	SET PROCEDURE TO DovfpTestInit.fxp ADDITIVE

	loTestInit = CREATEOBJECT("DovfpTestInit")
	
	goDovfpTestInit.SeteosBasicos()
	
	goDovfpTestInit.RegistrarMockSetupRegistry("OrganicCoreMockSetupRegistry", "OrganicCoreMockSetupRegistry.prg")

	InstanciarMocksGlobales()

	goDovfpTestInit.InstanciarZooMock()
	goDovfpTestInit.InstanciarZooAplicacion("Nucleo")

	
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "clasesdeprueba\" ) additive
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "adn\" ) ADDITIVE
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "..\taspein\data\" ) ADDITIVE
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "bin\test\generados\" ) ADDITIVE

	&& _screen.Zoo.App.cSucursalActiva = "PAISES"
	_screen.Zoo.App.cSucursalActiva = "Paises"

	*-- Resetear PrefijoBaseDeDatos para limpiar estado persistido por test runs anteriores
	goParametros.Nucleo.PrefijoBaseDeDatos = ""

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
			IF UPPER(lcMensaje) == "USER THROWN ERROR" OR ;
			   UPPER(lcMensaje) == "USER THROWN ERROR ." OR ;
			   EMPTY(lcMensaje)
				llEsPasaMano = .T.
			ENDIF
		ENDIF
		
		* Extraer info util: Details, Procedure, LineNo, etc.
		* Aunque sea "pasa mano", estas propiedades pueden tener el error real
		LOCAL lcDetails, lcProcedure, lcLineContents
		lcDetails = ""
		lcProcedure = ""
		lcLineContents = ""
		
		IF PEMSTATUS(loCurrentEx, "Details", 5) AND !EMPTY(loCurrentEx.Details)
			lcDetails = ALLTRIM(loCurrentEx.Details)
		ENDIF
		IF PEMSTATUS(loCurrentEx, "Procedure", 5) AND !EMPTY(loCurrentEx.Procedure)
			lcProcedure = ALLTRIM(loCurrentEx.Procedure)
		ENDIF
		IF PEMSTATUS(loCurrentEx, "LineContents", 5) AND !EMPTY(loCurrentEx.LineContents)
			lcLineContents = ALLTRIM(loCurrentEx.LineContents)
		ENDIF

		* Si es pasa mano pero tiene Details, usarlo como mensaje principal
		IF llEsPasaMano AND !EMPTY(lcDetails)
			lcMensaje = lcDetails
			llEsPasaMano = .F.  && Tiene info real, no es pasa mano
		ENDIF
		
		* Si es pasa mano puro (sin Details), buscar en UserValue antes de descartar
		IF llEsPasaMano
			IF PEMSTATUS(loCurrentEx, "UserValue", 5) AND VARTYPE(loCurrentEx.UserValue) = "O"
				* Hay mas niveles, skip este pasa mano
			ELSE
				IF !EMPTY(lcProcedure) OR !EMPTY(lcLineContents)
					llEsPasaMano = .F.
					lcMensaje = "Error en " + lcProcedure
				ENDIF
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
			IF !EMPTY(lcDetails) AND !(lcDetails $ lcResult)
				lcResult = lcResult + "Details: " + lcDetails + CHR(13) + CHR(10)
			ENDIF
			
			* LineContents
			IF !EMPTY(lcLineContents) AND !(lcLineContents $ lcResult)
				lcResult = lcResult + "LineContents: " + lcLineContents + CHR(13) + CHR(10)
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
	LOCAL loMock, loSetup

	*-- ManagerEjecucion
	loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
	loSetup = loMock.Setup("TieneScriptCargado")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("EjecutarAplicacion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("CerrarInstanciasDeAplicacion")
	loSetup = loMock.Setup("HayAppAbiertas")
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("HabilitarMonitorSaludBasesDeDatos")
	loSetup = loMock.Setup("Detener")

	*-- Managers
	*-- LOOSE: VFP llama DESTROY al destruir objetos mockeados. En STRICT mode,
	*-- Setup("Destroy") sin Returns() no registra correctamente y causa
	*-- MockException en CI/CD con dovfp parallel workers. LOOSE evita esto.
	loMock = goDoVfpMock.Mock("ManagerExportaciones", "ManagerExportaciones.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("Multimedia", "Multimedia.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ManagerImportaciones", "ManagerImportaciones.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ManagerListados", "ManagerListados.prg", "LOOSE")
	
	*-- Memoria
	loMock = goDoVfpMock.Mock("Memoria", "Memoria.prg", "LOOSE")
	loSetup = loMock.Setup("SetearDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loMock = goDoVfpMock.Mock("ServicioEstructura", "ServicioEstructura.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ManagerConsultaAFIP", "ManagerConsultaAFIP.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ManagerWebHook", "ManagerWebHook.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ServicioMonitorSaludBasesDeDatos", "ServicioMonitorSaludBasesDeDatos.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("SerializadorDeEntidades", "SerializadorDeEntidades.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("WindowsToastNotification", "WindowsToastNotification.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ServicioNotificacionEnSegundoPlano", "ServicioNotificacionEnSegundoPlano.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ManagerMercadoPago", "ManagerMercadoPago.prg", "LOOSE")
	loMock = goDoVfpMock.Mock("ManagerMonitor", "ManagerMonitor.prg", "LOOSE")
	loSetup = loMock.Setup("EnviarTransferencia")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup = loMock.Setup("CrearCarpetaTemporal")
	loSetup.Returns("")
	loSetup = loMock.Setup("ArmarZipTransferenciaAgrupada")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")

	loMock = goDoVfpMock.Mock("ConfigurarAAOBackupSqlServer", "ConfigurarAAOBackupSqlServer.prg", "LOOSE")

	*-- ManagerDeConfiguracionDeAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ManagerDeConfiguracionDeAgenteDeAccionesOrganic", "ManagerDeConfiguracionDeAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	
	*-- ColaboradorDecimalesEnCantidad (PrecisionDecimalEnCantidad en goServicios)
	loMock = goDoVfpMock.Mock("ColaboradorDecimalesEnCantidad", "ColaboradorDecimalesEnCantidad.prg", "LOOSE")
	loSetup = loMock.Setup("AjustarMascara")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns("999,999,999.99")

	*-- ManagerAccionesAutomaticas
	LOCAL loMockAccionesAutomaticas
	loMockAccionesAutomaticas = goDoVfpMock.Mock("ManagerAccionesAutomaticas", "ManagerAccionesAutomaticas.prg", "LOOSE")
	loSetup = loMockAccionesAutomaticas.Setup("LaEntidadTieneAccionesAutomaticas")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)
	loSetup = loMockAccionesAutomaticas.Setup("LaEntidadTieneAccionesAutomaticas")
	loSetup.Returns(.F.)
	loSetup = loMockAccionesAutomaticas.Setup("CantidadDeEntidadesQueTienenAccionesAutomaticas")
	loSetup.Returns(0)
	loSetup = loMockAccionesAutomaticas.Setup("RefrescarColeccionDeEntidadesConAccionesAutomaticas")
	loSetup = loMockAccionesAutomaticas.Setup("Detener")

	*-- ManagerEntidades
	loMock = goDoVfpMock.Mock("ManagerEntidades", "ManagerEntidades.prg", "LOOSE")
	loSetup = loMock.SetupGet("AccionesAutomaticas")
	loSetup.Returns(loMockAccionesAutomaticas.Object)
	loSetup = loMock.Setup("Detener")

	*-- ManagerDeConfiguracionDeAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ManagerDeConfiguracionDeAgenteDeAccionesOrganic", "ManagerDeConfiguracionDeAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- ConfigurarAAOBackupSqlServer
	loMock = goDoVfpMock.Mock("ConfigurarAAOBackupSqlServer", "ConfigurarAAOBackupSqlServer.prg", "LOOSE")

	*-- ManagerImpresion
	loMock = goDoVfpMock.Mock("ManagerImpresion", "ManagerImpresion.prg", "LOOSE")
	loSetup = loMock.Setup("DebeGenerarPDFsDeDisenosAutomaticamente")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("DebeImprimirDisenosAutomaticamente")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerNombreFuncion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")

	*-- Mensajes (publico para acceso desde tests)
	*-- Los mensajes capturados se guardan en goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados
	PUBLIC goDovfpMockMensajes
	
	goDovfpMockMensajes = goDoVfpMock.Mock("Mensajes", "Mensajes.prg", "LOOSE")
	
	*-- EnviarSinEspera(tcMensaje, tcTitulo, tcTextoBoton): captura mensaje y retorna .T.
	loSetup = goDovfpMockMensajes.Setup("EnviarSinEspera")
	loSetup = loSetup.WithCallback(CREATEOBJECT("CallbackEnviarSinEspera", goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados))
	loSetup.Returns(.T.)
	
	*-- Enviar(tcMensaje, tcTitulo, tnTipoIcono): captura mensaje y retorna valor
	loSetup = goDovfpMockMensajes.Setup("Enviar")
	loSetup = loSetup.WithCallback(CREATEOBJECT("CallbackEnviar", goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados))
	loSetup.Returns(1)
	
	*-- EnviarSinEsperaProcesando(tcMensaje, tcTitulo, tcTextoBoton, tlNoHacePausa): captura mensaje
	loSetup = goDovfpMockMensajes.Setup("EnviarSinEsperaProcesando")
	loSetup = loSetup.WithCallback(CREATEOBJECT("CallbackEnviarSinEsperaProcesando", goDovfpTestInit.oMockSetupRegistry.oMensajesCapturados))
	loSetup.Returns(.T.)

	loSetup = goDovfpMockMensajes.Setup("Detener")

	*-- ManagerLogueos
	PUBLIC goDovfpMockLogueos
	
	goDovfpMockLogueos = goDoVfpMock.Mock("ManagerLogueos", "ManagerLogueos.prg", "LOOSE")
	
	*-- ObtenerObjetoLogueo
	loSetup = goDovfpMockLogueos.Setup("ObtenerObjetoLogueo")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup = loSetup.WithCallback(CREATEOBJECT("CallbackObtenerObjetoLogueo", goDovfpTestInit.oMockSetupRegistry.oErroresCapturados))
	loSetup.Returns(CREATEOBJECT("MockObjetoLogueo", goDovfpTestInit.oMockSetupRegistry.oErroresCapturados))
	
	loSetup = goDovfpMockLogueos.Setup("Guardar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- GuardarParcialmente: necesario para ObjetoLogueo.Escribir cuando el buffer se llena
	loSetup = goDovfpMockLogueos.Setup("GuardarParcialmente")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- Terminar: necesario para tests que cierran el servicio de logueos
	loSetup = goDovfpMockLogueos.Setup("Terminar")
	loSetup.Returns(.T.)

	loSetup = goDovfpMockLogueos.Setup("Detener")

	*-- TimerBase
	loMock = goDoVfpMock.Mock("TimerBase", "TimerBase.prg", "LOOSE")
	loSetup = loMock.Setup("InicializarTimers")
	loSetup.Returns(.T.)
	loSetup = loMock.SetupGet("Timer")
	loSetup.Returns(0)
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
	loSetup = loMock.Setup("EncenderTodosLosTimersFrenados")
	loSetup.Returns(.T.)

	*-- Terminal
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
	loSetup = loMock.Setup("Detener")

	*-- ServicioSaltosDeCampoYValoresSugeridos
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

	loSetup = loMock.Setup("Detener")

	*-- ServicioPersonalizacionDeEntidades
	loMock = goDoVfpMock.Mock("ServicioPersonalizacionDeEntidades", "ServicioPersonalizacionDeEntidades.prg", "LOOSE")

	*-- ServicioRegistroDeActividad
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

	*-- tiemporeal
	loMock = goDoVfpMock.Mock("tiemporeal", "tiemporeal.prg", "LOOSE")
	loMock.Setup("EscucharAccesoADatos")
	loSetup = loMock.Setup("AgregarAlta")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerTagEstimulo")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
	loSetup = loMock.Setup("ProcesarBuffers")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	loSetup = loMock.Setup("Detener")

	*-- InstaladorAgenteDeAccionesOrganic (debe ir ANTES de ConfigurarAgenteDeAccionesOrganic)
	*-- Este mock evita que se ejecute el instalador real del AAO durante los tests
	loMock = goDoVfpMock.Mock("InstaladorAgenteDeAccionesOrganic", "InstaladorAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("Instalar")
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("DebeActualizar")
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("HayNuevaVersionAAO")
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("MarcarComoActualizado")
	loSetup.Returns(.T.)

	*-- DatosAAO (usado por InstaladorAgenteDeAccionesOrganic)
	loMock = goDoVfpMock.Mock("DatosAAO", "DatosAAO.prg", "LOOSE")
	loSetup = loMock.Setup("ObtenerVersionUltimaActualizacion")
	loSetup.Returns("99.99.9999")
	loSetup = loMock.Setup("SetearVersionUltimaActualizacion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- ConectorAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ConectorAgenteDeAccionesOrganic", "ConectorAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("EjecutaScriptOrganicPorMedioDelGestor")
	loSetup.Returns(.T.)

	*-- Configuradores AAO (creados en ConfigurarAgenteDeAccionesOrganic.Init)
	loMock = goDoVfpMock.Mock("ConfigurarAAODatosAplicacion", "ConfigurarAAODatosAplicacion.prg", "LOOSE")
	loSetup = loMock.Setup("Configurar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	loMock = goDoVfpMock.Mock("ConfigurarAAOEnviarYRecibir", "ConfigurarAAOEnviarYRecibir.prg", "LOOSE")
	loSetup = loMock.Setup("Configurar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	loMock = goDoVfpMock.Mock("ConfigurarAAOResumenDelDia", "ConfigurarAAOResumenDelDia.prg", "LOOSE")
	loSetup = loMock.Setup("Configurar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- ConfigurarAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ConfigurarAgenteDeAccionesOrganic", "ConfigurarAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("ConfigurarAgentePorActualizacion")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ConfigurarAgenteInicial")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Configurar")
	loSetup.Returns(.T.)

	*-- PoolDeConexiones
	loMock = goDoVfpMock.Mock("PoolDeConexiones", "PoolDeConexiones.prg", "LOOSE")
	loSetup = loMock.Setup("DesconectarTodo")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("DevolverConexion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerConexion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(NULL)

	*-- AspectoAplicacion
	loMock = goDoVfpMock.Mock("AspectoAplicacion", "AspectoAplicacion.prg", "LOOSE")
	loSetup = loMock.Setup("ObtenerNombreEdicion")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerIconoDeLaAplicacion")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerPieIzquierdoAbm")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerPieDerechoAbm")
	loSetup.Returns("")
	*-- Metodos usados en zooFormPrincipal.Init (retornan "" para evitar error 1732 al asignar .NULL. a propiedades de controles)
	loSetup = loMock.Setup("ObtenerRutaImagenFondoArriba")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerTituloAplicacion")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerRutaImagenFondoDerecha")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerRutaImagenFondoIzquierda")
	loSetup.Returns("")

	*-- Salida (evitar que VFP se cierre durante tests)
	loMock = goDoVfpMock.Mock("Salida", "Salida.prg", "LOOSE")
	loSetup = loMock.Setup("SalidaDelSistema")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- Seguridad
	loMock = goDoVfpMock.Mock("Seguridad", "Seguridad.prg", "LOOSE")
	loSetup = loMock.SetupGet("cUsuarioLogueado")
	loSetup.Returns("ADMIN")
	loSetup = loMock.SetupGet("cUsuarioOtorgaPermiso")
	loSetup.Returns("")
	loSetup = loMock.SetupGet("lEsAdministrador")
	loSetup.Returns(.F.)
	loSetup = loMock.SetupGet("cUsuarioAdministrador")
	loSetup.Returns("ADMIN")
	loSetup = loMock.SetupGet("cIdPerfilAdministrador")
	loSetup.Returns("")
	loSetup = loMock.SetupGet("nEstadoDelSistema")
	loSetup.Returns(2)
	loSetup = loMock.SetupGet("cBaseDeDatosSeleccionada")
	loSetup.Returns("Paises")
	loSetup = loMock.SetupGet("cLongitudMaximaUsuario")
	loSetup.Returns(100)
	loSetup = loMock.SetupGet("lBlquearAdminPorSeguridadCentralizada")
	loSetup.Returns(.F.)
	loSetup = loMock.SetupGet("lForzarUsuarioAdministrador")
	loSetup.Returns(.F.)
	loSetup = loMock.SetupGet("cUltimoUsuarioLogueado")
	loSetup.Returns("ADMIN")
	loSetup = loMock.Setup("ObtenerUltimoUsuarioLogueado")
	loSetup.Returns("ADMIN")
	loSetup = loMock.SetupGet("ObtenerUltimoUsuarioLogueado")
	loSetup.Returns("ADMIN")
	loSetup = loMock.Setup("ObtenerUltimoUsuarioLogueadoParaLogin")
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerEstadoDelSistema")
	loSetup.Returns(2)
	loSetup = loMock.Setup("ObtenerBaseQueElUsuarioLogueadoPuedeAcceder")
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("PedirAccesoTransferencia")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	_screen._instanceFactory.LoadReference('zooinformacion.prg', "Organic.Core.app", .T.)
	loSetup = loMock.Setup("ObtenerInformacion")
	loSetup.Returns(NEWOBJECT("ZooInformacion", "ZooInformacion.prg"))

	*-- operacionesseguridadadnimplant (PRG de AdnImplant, no existe en bin de test)
	*-- Necesario para TearDown de zTestKontrolerCambioDeClave y zTestSeguridad
	*-- que llaman LlenarTablasSeguridad() via _screen.zoo.crearobjeto()
	loMock = goDoVfpMock.Mock("operacionesseguridadadnimplant", "operacionesseguridadadnimplant.prg", "LOOSE")
	loSetup = loMock.Setup("LlenarTablasSeguridad")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Release")
	loSetup.Returns(.T.)
ENDFUNC


*-----------------------------------------------------------------------------------------
* Callbacks para capturar argumentos de mensajes
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

DEFINE CLASS CallbackObtenerObjetoLogueo AS Custom
	oErroresCapturados = .NULL.
	
	FUNCTION Init(toCollection)
		THIS.oErroresCapturados = m.toCollection
	ENDFUNC
	
	FUNCTION Invoke
		LPARAMETERS toQuienPide
	ENDFUNC
ENDDEFINE


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
		THIS.cIdLogueo = SYS(2015) 
	ENDFUNC
	
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
	LOCAL lcScriptPath, lnExitCode, lcErrorMsg
	
	lcScriptPath = ObtenerRutaRaizProyecto() + "run-adnImplant.ps1"
	
	IF !FILE(m.lcScriptPath)
		ERROR "Script no encontrado: " + m.lcScriptPath
		RETURN
	ENDIF
	
	lcErrorMsg = ""
	lnExitCode = EjecutarScriptPowerShell(m.lcScriptPath, "-Validate", 120, @lcErrorMsg)
	
	*-- Si exit code != 0, lanzar error VFP con mensaje claro
	IF m.lnExitCode != 0
		LOCAL lcMensajeFinal
		
		*-- Limpiar output: quitar espacios extras y normalizar saltos de linea
		lcErrorMsg = STRTRAN(STRTRAN(m.lcErrorMsg, CHR(13)+CHR(10), CHR(10)), CHR(13), CHR(10))
		lcErrorMsg = STRTRAN(m.lcErrorMsg, CHR(10), CHR(13)+CHR(10))
		
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


*-----------------------------------------------------------------------------------------
* Reemplazo de INKEY() para tests que necesitan despachar callbacks de cpptimer.fll.
*
* PROBLEMA: En modo COM (DOVFP), INKEY() NO procesa mensajes Windows durante su espera.
* cpptimer.fll usa _Execute() (C API) para encolar callbacks, y esa cola interna 
* solo se despacha con DOEVENTS FORCE o READ EVENTS.
* En produccion, READ EVENTS mantiene el event loop activo.
* En tests COM no hay READ EVENTS, por lo que los callbacks nunca se ejecutan.
*
* NOTA: DOEVENTS (sin FORCE) no alcanza en COM mode sin forms visibles.
* DOEVENTS FORCE fuerza el procesamiento independientemente de la visibilidad.
*
* USO: En tests con timers, usar InkeyConEventos(1) en vez de inkey(1)
*-----------------------------------------------------------------------------------------
FUNCTION InkeyConEventos(tnSegundos AS Number) AS Number
	LOCAL lnEnd AS Number, lnKey AS Number
	lnEnd = SECONDS() + tnSegundos
	lnKey = 0
	DO WHILE SECONDS() < lnEnd
		DOEVENTS FORCE
		lnKey = INKEY(0.05)
		IF lnKey != 0
			EXIT
		ENDIF
		DOEVENTS FORCE
	ENDDO
	RETURN lnKey
ENDFUNC


*-----------------------------------------------------------------------------------------
* Valida que los prerequisitos de tests esten instalados (Crystal, FinePrint, MSXML4)
* Solo verifica, NO instala. La instalacion se hace en el pipeline antes de dovfp test.
* En local, ejecutar: .\install-test-prerequisites.ps1
*-----------------------------------------------------------------------------------------
FUNCTION ValidarPrerequisitos() AS Void
	LOCAL lcScriptPath, lnExitCode, lcOutput
	
	lcScriptPath = ObtenerRutaRaizProyecto() + "install-test-prerequisites.ps1"
	
	IF !FILE(m.lcScriptPath)
		*-- Script no encontrado, no es critico
		RETURN
	ENDIF
	
	lcOutput = ""
	lnExitCode = EjecutarScriptPowerShell(m.lcScriptPath, "-Validate", 60, @lcOutput)
	
	IF m.lnExitCode != 0
		*-- Limpiar output
		lcOutput = STRTRAN(STRTRAN(m.lcOutput, CHR(13)+CHR(10), CHR(10)), CHR(13), CHR(10))
		lcOutput = STRTRAN(m.lcOutput, CHR(10), CHR(13)+CHR(10))
		
		ERROR "PREREQUISITOS FALTANTES" + CHR(13) + CHR(10) + ;
			CHR(13) + CHR(10) + ;
			m.lcOutput + CHR(13) + CHR(10) + ;
			CHR(13) + CHR(10) + ;
			"Ejecute: .\install-test-prerequisites.ps1 para instalarlos"
	ENDIF
ENDFUNC


*-----------------------------------------------------------------------------------------
* Obtiene la ruta raiz del proyecto Organic.Core subiendo 3 niveles desde bin\Test
*-----------------------------------------------------------------------------------------
FUNCTION ObtenerRutaRaizProyecto() AS String
	LOCAL lcSearchPath, i
	
	lcSearchPath = SYS(5) + SYS(2003)
	
	*-- Subir 3 niveles desde bin\Test hasta Organic.Core
	*-- bin\Test -> bin -> Organic.Tests -> Organic.Core
	FOR i = 1 TO 3
		lcSearchPath = FULLPATH(ADDBS(lcSearchPath) + "..")
	ENDFOR
	
	RETURN ADDBS(lcSearchPath)
ENDFUNC


*-----------------------------------------------------------------------------------------
* Ejecuta un script PowerShell SIN bloquear el thread COM de VFP.
*
* PROBLEMA: WScript.Shell.Run(cmd, 0, .T.) bloquea el thread de VFP completamente.
* Cuando dovfp ejecuta tests en paralelo (-test_parallel N), el test runner se
* comunica con cada VFP worker via COM. Si VFP esta bloqueado en .Run(.T.),
* no puede responder a COM y el runner lo da por muerto y lo mata.
*
* SOLUCION: WScript.Shell.Exec() abre ventana negra de cmd. En su lugar usamos:
* - Run(powershell, 0, .F.)  0=hidden, .F.=non-blocking
* - PowerShell escribe output y exit code a temp files
* - VFP hace polling con INKEY() que mantiene el message pump activo
*
* Parametros:
*   tcScriptPath - Ruta completa al script .ps1
*   tcArgs       - Argumentos adicionales para el script (ej: "-Validate")
*   tnTimeout    - Timeout maximo en segundos (default 120)
*   tcOutput     - [OUT por referencia] Output capturado del script
* Retorna: Exit code del proceso (o -1 si timeout)
*-----------------------------------------------------------------------------------------
FUNCTION EjecutarScriptPowerShell(tcScriptPath AS String, tcArgs AS String, tnTimeout AS Number, tcOutput AS String) AS Number
	LOCAL loShell AS Object
	LOCAL lcTempDir AS String, lcOutputFile AS String, lcExitCodeFile AS String, lcSentinelFile AS String
	LOCAL lcScriptEscaped AS String, lcPSCommand AS String, lcRunCommand AS String
	LOCAL lnStart AS Number, lnTimeout AS Number, lnExitCode AS Number
	LOCAL lnFileHandle AS Number
	
	lnTimeout = IIF(VARTYPE(tnTimeout) = "N" AND tnTimeout > 0, tnTimeout, 120)
	tcOutput = ""
	
	*-- Crear archivos temporales unicos (usando SYS(2015) como id unico)
	lcTempDir = ADDBS(SYS(2023))
	LOCAL lcUniqueId
	lcUniqueId = SYS(2015)
	lcOutputFile   = lcTempDir + "dovfp_ps_out_" + lcUniqueId + ".txt"
	lcExitCodeFile = lcTempDir + "dovfp_ps_ec_"  + lcUniqueId + ".txt"
	lcSentinelFile = lcTempDir + "dovfp_ps_done_" + lcUniqueId + ".txt"
	
	*-- Asegurar que no existan de una ejecucion previa
	IF FILE(m.lcOutputFile)
		DELETE FILE (m.lcOutputFile)
	ENDIF
	IF FILE(m.lcExitCodeFile)
		DELETE FILE (m.lcExitCodeFile)
	ENDIF
	IF FILE(m.lcSentinelFile)
		DELETE FILE (m.lcSentinelFile)
	ENDIF
	
	*-- Escapar comillas simples en rutas para PowerShell
	lcScriptEscaped = STRTRAN(m.tcScriptPath, "'", "''")
	
	*-- Construir comando PowerShell que:
	*-- 1) Ejecuta el script y captura todo el output
	*-- 2) Escribe output a archivo temporal
	*-- 3) Escribe exit code a archivo temporal
	*-- 4) Escribe sentinel para que VFP sepa que termino
	LOCAL lcOutEsc, lcEcEsc, lcSentEsc
	lcOutEsc  = STRTRAN(m.lcOutputFile, "'", "''")
	lcEcEsc   = STRTRAN(m.lcExitCodeFile, "'", "''")
	lcSentEsc = STRTRAN(m.lcSentinelFile, "'", "''")
	
	TEXT TO lcPSCommand TEXTMERGE NOSHOW
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& { try { $output = & '<<lcScriptEscaped>>' <<tcArgs>> *>&1 | Out-String; $ec = $LASTEXITCODE; if ($null -eq $ec) { $ec = 0 } } catch { $output = $_.ToString(); $ec = 1 }; $output | Out-File -FilePath '<<lcOutEsc>>' -Encoding UTF8 -Force; $ec.ToString() | Out-File -FilePath '<<lcEcEsc>>' -Encoding UTF8 -Force; 'done' | Out-File -FilePath '<<lcSentEsc>>' -Encoding UTF8 -Force }"
	ENDTEXT
	
	*-- Ejecutar con Run(cmd, 0=hidden, .F.=non-blocking)
	*-- Esto NO abre ventana y NO bloquea el thread COM
	loShell = CREATEOBJECT("WScript.Shell")
	loShell.Run(m.lcPSCommand, 0, .F.)
	
	*-- Polling: esperar a que aparezca el archivo sentinel
	lnStart = SECONDS()
	DO WHILE !FILE(m.lcSentinelFile)
		*-- INKEY() procesa mensajes Windows, manteniendo VFP responsivo a COM
		INKEY(0.5)
		
		*-- Proteccion contra hang indefinido
		IF SECONDS() - lnStart > lnTimeout
			*-- Intentar leer lo que haya de output
			IF FILE(m.lcOutputFile)
				tcOutput = FILETOSTR(m.lcOutputFile)
			ENDIF
			tcOutput = tcOutput + CHR(13) + CHR(10) + "[TIMEOUT: " + TRANSFORM(lnTimeout) + "s excedido]"
			
			*-- Limpiar archivos temporales
			IF FILE(m.lcOutputFile)
				DELETE FILE (m.lcOutputFile)
			ENDIF
			IF FILE(m.lcExitCodeFile)
				DELETE FILE (m.lcExitCodeFile)
			ENDIF
			IF FILE(m.lcSentinelFile)
				DELETE FILE (m.lcSentinelFile)
			ENDIF
			
			loShell = NULL
			RETURN -1
		ENDIF
	ENDDO
	
	*-- Leer output
	IF FILE(m.lcOutputFile)
		tcOutput = FILETOSTR(m.lcOutputFile)
	ENDIF
	
	*-- Leer exit code
	lnExitCode = 0
	IF FILE(m.lcExitCodeFile)
		LOCAL lcExitCodeStr
		lcExitCodeStr = ALLTRIM(STRTRAN(STRTRAN(FILETOSTR(m.lcExitCodeFile), CHR(13), ""), CHR(10), ""))
		IF ISDIGIT(lcExitCodeStr) OR LEFT(lcExitCodeStr, 1) = "-"
			lnExitCode = VAL(lcExitCodeStr)
		ENDIF
	ENDIF
	
	*-- Limpiar archivos temporales
	TRY
		IF FILE(m.lcOutputFile)
			DELETE FILE (m.lcOutputFile)
		ENDIF
		IF FILE(m.lcExitCodeFile)
			DELETE FILE (m.lcExitCodeFile)
		ENDIF
		IF FILE(m.lcSentinelFile)
			DELETE FILE (m.lcSentinelFile)
		ENDIF
	CATCH
		*-- No critico si no se pueden borrar los temporales
	ENDTRY
	
	loShell = NULL
	RETURN lnExitCode
ENDFUNC