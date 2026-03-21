*---------------------------------------------------------------------
* mainTest.prg
* Punto de entrada principal para la ejecucion de tests
*---------------------------------------------------------------------

LOCAL loTestInit

TRY
	ValidarBaseDeDatosRequeridas()

	SET PROCEDURE TO DovfpTestInit.fxp ADDITIVE

	loTestInit = CREATEOBJECT("DovfpTestInit")
	
	*-- 1. PRIMERO: Seteos basicos (carga AppReferences, crea _instanceFactory, goDoVfpMock)
	&& loTestInit.SeteosBasicos()
	goDovfpTestInit.SeteosBasicos()
	
	*-- 2. Registrar MockSetupRegistry (necesita estar despues de SeteosBasicos)
	&& loTestInit.RegistrarMockSetupRegistry("OrganicColorYTalleMockSetupRegistry", "OrganicColorYTalleMockSetupRegistry.prg")
	goDovfpTestInit.RegistrarMockSetupRegistry("OrganicColorYTalleMockSetupRegistry", "OrganicColorYTalleMockSetupRegistry.prg")

	*-- 3. Instanciar todos los mocks globales (USA goDoVfpMock, debe ir despues de SeteosBasicos)
	InstanciarMocksGlobales()
	
	*-- 4. Instanciar ZooMock V1
	
	&& loTestInit.InstanciarZooMock()
	goDovfpTestInit.InstanciarZooMock()

	*-- 5. Instanciar Zoo y aplicacion
	&& loTestInit.InstanciarZooAplicacion("ColorYTalle")
	goDovfpTestInit.InstanciarZooAplicacion("ColorYTalle")
	
	*-- 6. ACTIVAR SUCURSAL ANIMALES (conecta a la base de datos SQL Server)
	_screen.Zoo.App.cSucursalActiva = "DEMO"
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "adn\dbc\") ADDITIVE
	SET PATH TO ( addbs( _Screen.Zoo.cRutaInicial ) + "clasesdeprueba\") ADDITIVE
	
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
	LOCAL loMock, loSetup

	*-- ManagerEjecucion (DEBE ir al principio para evitar inicialización de AAO)
	*-- Al devolver TieneScriptCargado() = .T., se omite la verificación del AAO
	loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
	loSetup = loMock.Setup("TieneScriptCargado")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("EjecutarAplicacion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- ManagerDeConfiguracionDeAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ManagerDeConfiguracionDeAgenteDeAccionesOrganic", "ManagerDeConfiguracionDeAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- ConfigurarAAOBackupSqlServer
	loMock = goDoVfpMock.Mock("ConfigurarAAOBackupSqlServer", "ConfigurarAAOBackupSqlServer.prg", "LOOSE")

	*-- Managers STRICT (sin comportamiento definido, fallan si se llaman)
	loMock = goDoVfpMock.Mock("ManagerExportaciones", "ManagerExportaciones.prg", "STRICT")
	loMock = goDoVfpMock.Mock("Multimedia", "Multimedia.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ManagerImportaciones", "ManagerImportaciones.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ManagerListados", "ManagerListados.prg", "STRICT")
	
	*-- Memoria (LOOSE - permite llamadas sin configuración explícita)
	loMock = goDoVfpMock.Mock("Memoria", "Memoria.prg", "LOOSE")
	loSetup = loMock.Setup("SetearDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("GrabarDatosFormulario")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loMock = goDoVfpMock.Mock("ServicioEstructura", "ServicioEstructura.prg", "STRICT")

	loMock = goDoVfpMock.Mock("ManagerWebHook", "ManagerWebHook.prg", "STRICT")
	loSetup = loMock.Setup("TieneQueMandar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)

	*-- ServicioMonitorSaludBasesDeDatos
	loMock = goDoVfpMock.Mock("ServicioMonitorSaludBasesDeDatos", "ServicioMonitorSaludBasesDeDatos.prg", "LOOSE")
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)

	loMock = goDoVfpMock.Mock("SerializadorDeEntidades", "SerializadorDeEntidades.prg", "STRICT")
	loMock = goDoVfpMock.Mock("WindowsToastNotification", "WindowsToastNotification.prg", "STRICT")

	*-- ServicioNotificacionEnSegundoPlano
	loMock = goDoVfpMock.Mock("ServicioNotificacionEnSegundoPlano", "ServicioNotificacionEnSegundoPlano.prg", "LOOSE")
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)

	*-- ServicioPoolDeObjetos
	loMock = goDoVfpMock.Mock("ServicioPoolDeObjetos", "ServicioPoolDeObjetos.prg", "LOOSE")
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)

	loMock = goDoVfpMock.Mock("ManagerMercadoPago", "ManagerMercadoPago.prg", "STRICT")
	loMock = goDoVfpMock.Mock("ManagerMonitor", "ManagerMonitor.prg", "STRICT")

	loMock = goDoVfpMock.Mock("ConfigurarAAOBackupSqlServer", "ConfigurarAAOBackupSqlServer.prg", "LOOSE")

	*-- ManagerDeConfiguracionDeAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ManagerDeConfiguracionDeAgenteDeAccionesOrganic", "ManagerDeConfiguracionDeAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	
	*-- ColaboradorDecimalesEnCantidad (PrecisionDecimalEnCantidad en goServicios)
	*-- NO mockear - debe ser la clase real para validaciones en tests
	*loMock = goDoVfpMock.Mock("ColaboradorDecimalesEnCantidad", "ColaboradorDecimalesEnCantidad.prg", "LOOSE")
	*loSetup = loMock.Setup("AjustarMascara")
	*loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	*loSetup.Returns("999,999,999.99")

	*-- Seguridad, ManagerEntidades y AccionesAutomaticas: Usar clases reales (ya están instanciadas en goServicios)

	*-- ManagerDeConfiguracionDeAgenteDeAccionesOrganic
	loMock = goDoVfpMock.Mock("ManagerDeConfiguracionDeAgenteDeAccionesOrganic", "ManagerDeConfiguracionDeAgenteDeAccionesOrganic.prg", "LOOSE")
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	&& do mockMagagerTemporales
	&& *-- ManagerTemporales
	&& loMock = goDoVfpMock.Mock("ManagerTemporales", "ManagerTemporales.prg", "LOOSE")
	&& loSetup = loMock.Setup("ObtenerCarpeta")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(addbs(sys(2023)))

	*-- ConfigurarAAOBackupSqlServer
	loMock = goDoVfpMock.Mock("ConfigurarAAOBackupSqlServer", "ConfigurarAAOBackupSqlServer.prg", "LOOSE")

	&& do MockManagerImpresion
	&& *-- ManagerImpresion
	&& loMock = goDoVfpMock.Mock("ManagerImpresion", "ManagerImpresion.prg", "LOOSE")
	&& loSetup = loMock.Setup("DebeGenerarPDFsDeDisenosAutomaticamente")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(.F.)
	&& loSetup = loMock.Setup("Detener")
	&& loSetup.Returns(.T.)
	&& loSetup = loMock.Setup("ObtenerNombreFuncion")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns("")

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

	*-- ManagerLogueos (captura errores logueados para diagnóstico)
	*-- Los errores capturados se guardan en goDovfpTestInit.oMockSetupRegistry.oErroresCapturados
	PUBLIC goDovfpMockLogueos
	
	goDovfpMockLogueos = goDoVfpMock.Mock("ManagerLogueos", "ManagerLogueos.prg", "LOOSE")
	
	*-- ObtenerObjetoLogueo: Retorna un objeto que captura el error cuando se escribe
	loSetup = goDovfpMockLogueos.Setup("ObtenerObjetoLogueo")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup = loSetup.WithCallback(CREATEOBJECT("CallbackObtenerObjetoLogueo", goDovfpTestInit.oMockSetupRegistry.oErroresCapturados))
	loSetup.Returns(CREATEOBJECT("MockObjetoLogueo", goDovfpTestInit.oMockSetupRegistry.oErroresCapturados))
	
	*-- Guardar: No hace nada (el error ya se capturó en Escribir)
	loSetup = goDovfpMockLogueos.Setup("Guardar")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)

	*-- TimerBase
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

	&& do mockServicioSaltosDeCampoYValoresSugeridos
	&& *-- ServicioSaltosDeCampoYValoresSugeridos
	&& loMock = goDoVfpMock.Mock("ServicioSaltosDeCampoYValoresSugeridos", "ServicioSaltosDeCampoYValoresSugeridos.prg", "LOOSE")
	&& loSetup = loMock.Setup("Iniciar")
	&& loSetup.Returns(.T.)
	&& loSetup = loMock.Setup("Detener")
	&& loSetup.Returns(.T.)
	&& loSetup = loMock.Setup("ObtenerValorSugeridoDeUnaEntidadDetalle")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(CREATEOBJECT("Collection"))
	&& loSetup = loMock.Setup("ObtenerValorSugerido")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), , goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns("")
	&& loSetup = loMock.Setup("ObtenerColeccionAtributosObligatorios")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(CREATEOBJECT("Collection"))
	&& loSetup = loMock.Setup("ObtenerColeccionAtributosNoVisibles")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(CREATEOBJECT("Collection"))
	&& loSetup = loMock.Setup("ObtenerPersonalizacionDeEtiquetas")
	&& loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	&& loSetup.Returns(CREATEOBJECT("Collection"))

	*-- PersonalizacionDeEntidades: Usar clase real (ya está instanciada en goServicios)

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
	loSetup = loMock.Setup("ObtenerTagEstimulo")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
	loSetup = loMock.Setup("ProcesarBuffers")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("TieneContratadoElServicioDeOmnicanalidad")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)

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
	loSetup = loMock.Setup("AgregarConfiguradorAdicional")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
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

	*-- Salida (evitar que VFP se cierre durante tests)
	loMock = goDoVfpMock.Mock("Salida", "Salida.prg", "LOOSE")
	loSetup = loMock.Setup("SalidaDelSistema")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.T.)
ENDFUNC


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

procedure mockMagagerTemporales
	*-- ManagerTemporales
	loMock = goDoVfpMock.Mock("ManagerTemporales", "ManagerTemporales.prg", "LOOSE")
	loSetup = loMock.Setup("ObtenerCarpeta")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(addbs(sys(2023)))
endproc

procedure MockManagerImpresion
	*-- ManagerImpresion
	loMock = goDoVfpMock.Mock("ManagerImpresion", "ManagerImpresion.prg", "LOOSE")
	loSetup = loMock.Setup("DebeGenerarPDFsDeDisenosAutomaticamente")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(.F.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerNombreFuncion")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
endproc

procedure mockServicioSaltosDeCampoYValoresSugeridos
	*-- ServicioSaltosDeCampoYValoresSugeridos
	loMock = goDoVfpMock.Mock("ServicioSaltosDeCampoYValoresSugeridos", "ServicioSaltosDeCampoYValoresSugeridos.prg", "LOOSE")
	loSetup = loMock.Setup("Iniciar")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("Detener")
	loSetup.Returns(.T.)
	loSetup = loMock.Setup("ObtenerValorSugeridoDeUnaEntidadDetalle")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("ObtenerValorSugerido")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), , goDoVfpMock.oIt.IsAny())
	loSetup.Returns("")
	loSetup = loMock.Setup("ObtenerColeccionAtributosObligatorios")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("ObtenerColeccionAtributosNoVisibles")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))
	loSetup = loMock.Setup("ObtenerPersonalizacionDeEtiquetas")
	loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
	loSetup.Returns(CREATEOBJECT("Collection"))

endproc
