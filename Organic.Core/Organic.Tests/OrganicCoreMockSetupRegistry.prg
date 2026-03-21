***********************************************************************
*	OrganicCoreMockSetupRegistry.prg
*	
*	Registro de setups y teardowns de mocks especificos para Organic.Core.
*	Hereda de MockSetupRegistry (dovfp.FxuLegacy) y agrega los setups
*	particulares de este proyecto.
*	
*	USO:
*	  En mainTest.prg:
*	    PUBLIC goMockSetupRegistry
*	    goMockSetupRegistry = NEWOBJECT("OrganicCoreMockSetupRegistry", "OrganicCoreMockSetupRegistry.prg")
*	
*	COMO AGREGAR UN NUEVO SETUP ESPECIFICO:
*	  1. Crear un metodo con el nombre: Setup_<NombreDelTest>
*	     Ejemplo: Para zTestEntidadCliente -> Setup_zTestEntidadCliente
*	  2. Implementar los mocks especificos en ese metodo
*	  3. El metodo sera invocado automaticamente antes del Setup() del test
*	
*	COMO AGREGAR UN NUEVO TEARDOWN ESPECIFICO:
*	  1. Crear un metodo con el nombre: TearDown_<NombreDelTest>
*	  2. Implementar los Verify de los mocks en ese metodo
*	  3. El metodo sera invocado automaticamente despues del TearDown() del test
*	
*	CONVENCION DE NOMBRES:
*	  - Setup_<NombreClaseTest>                 -> Para toda la clase de test
*	  - Setup_<NombreClaseTest>_<NombreMetodo>  -> Para un metodo especifico
*	  - TearDown_<NombreClaseTest>              -> Para toda la clase de test
*	  - TearDown_<NombreClaseTest>_<NombreMetodo> -> Para un metodo especifico
*	
***********************************************************************

Define Class OrganicCoreMockSetupRegistry As MockSetupRegistry Of MockSetupRegistry.prg

	*-----------------------------------------------------------------------------------------
	* Crea un mock de ManagerEjecucion
	* IMPORTANTE: Mantener sincronizado con InstanciarMocksGlobales() de mainTest.prg
	*-----------------------------------------------------------------------------------------
	Function CrearMockManagerEjecucion(tlTieneScriptCargado As Boolean) As Object
		LOCAL loMock, loSetup
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("TieneScriptCargado")
		loSetup.Returns(tlTieneScriptCargado)
		loSetup = loMock.SetupGet("lScriptCargado")
		loSetup.Returns(tlTieneScriptCargado)
		loSetup = loMock.Setup("EjecutarAplicacion")
		loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
		loSetup.Returns(.T.)
		loSetup = loMock.Setup("CerrarInstanciasDeAplicacion")
		loSetup = loMock.Setup("HayAppAbiertas")
		loSetup.Returns(.F.)
		loSetup = loMock.Setup("HabilitarMonitorSaludBasesDeDatos")
		loSetup = loMock.Setup("Detener")
		RETURN loMock
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Crea un mock de ManagerImpresion
	*-----------------------------------------------------------------------------------------
	Function CrearMockManagerImpresion() As Object
		LOCAL loMock, loSetup
		loMock = goDoVfpMock.Mock("ManagerImpresion", "ManagerImpresion.prg", "LOOSE")
		loSetup = loMock.Setup("DebeImprimirDisenosAutomaticamente")
		loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
		loSetup.Returns(.F.)
		loSetup = loMock.Setup("DebeGenerarPDFsDeDisenosAutomaticamente")
		loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
		loSetup.Returns(.F.)
		loSetup = loMock.Setup("Detener")
		loSetup.Returns(.T.)
		loSetup = loMock.Setup("ObtenerNombreFuncion")
		loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny())
		loSetup.Returns("")
		RETURN loMock
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Reemplaza goServicios.Parametros.nucleo.Comunicaciones con un Custom plano
	* para evitar que los _Access de las propiedades disparen llamadas WCF.
	* Guarda el objeto original en la instancia del test para restaurar en TearDown.
	* tlHabilitada: valor para EnviarRecibirYProcesarAutomaticamente
	*-----------------------------------------------------------------------------------------
	Function ReemplazarComunicacionesConFake(tlHabilitada As Boolean) As Void
		LOCAL loComunicaciones
		
		*-- Backup del objeto real (sin leer propiedades, solo la referencia)
		IF !ISNULL(THIS.oTestInstanceActual)
			ADDPROPERTY(THIS.oTestInstanceActual, "__ComunicacionesBackup", goServicios.Parametros.nucleo.Comunicaciones)
		ENDIF
		
		*-- Crear objeto plano sin _Access/_Assign (no dispara WCF)
		loComunicaciones = CREATEOBJECT("Custom")
		ADDPROPERTY(loComunicaciones, "EnviarRecibirYProcesarAutomaticamente", tlHabilitada)
		ADDPROPERTY(loComunicaciones, "FrecuenciaEnMinutos", 20)
		ADDPROPERTY(loComunicaciones, "ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos", "")
		
		*-- Reemplazar
		goServicios.Parametros.nucleo.Comunicaciones = loComunicaciones
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Restaura el objeto Comunicaciones original guardado por ReemplazarComunicacionesConFake
	*-----------------------------------------------------------------------------------------
	Function RestaurarComunicaciones() As Void
		IF !ISNULL(THIS.oTestInstanceActual) AND ;  
		   PEMSTATUS(THIS.oTestInstanceActual, "__ComunicacionesBackup", 5)
			goServicios.Parametros.nucleo.Comunicaciones = THIS.oTestInstanceActual.__ComunicacionesBackup
			REMOVEPROPERTY(THIS.oTestInstanceActual, "__ComunicacionesBackup")
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup_Default: Se ejecuta ANTES de cada test
	*-----------------------------------------------------------------------------------------
	Function Setup_Default() As Void
		*-- Limpiar mensajes capturados del test anterior
		IF !ISNULL(THIS.oMensajesCapturados)
			DO WHILE THIS.oMensajesCapturados.Count > 0
				THIS.oMensajesCapturados.Remove(1)
			ENDDO
		ENDIF
		
		*-- Limpiar errores capturados del test anterior
		IF !ISNULL(THIS.oErroresCapturados)
			DO WHILE THIS.oErroresCapturados.Count > 0
				THIS.oErroresCapturados.Remove(1)
			ENDDO
		ENDIF

		*-- Prevenir "Property SETEARMINUTOSVENCIMIENTO is not found" en AumentarBufferDeParametrosyRegistros.
		*-- FxuTestCaseLegacy llama SetearMinutosVencimiento solo cuando nMinutosVencimiento* > 0.
		*-- Al forzar 0, se omite la llamada al metodo que no existe en algunos entornos de Core.
		IF !ISNULL(THIS.oTestInstanceActual)
			TRY
				IF PEMSTATUS(THIS.oTestInstanceActual, "nMinutosVencimientoParametrosOrganizacion", 5)
					THIS.oTestInstanceActual.nMinutosVencimientoParametrosOrganizacion = 0
					THIS.oTestInstanceActual.nMinutosVencimientoParametrosPuesto = 0
					THIS.oTestInstanceActual.nMinutosVencimientoParametrosSucursal = 0
					THIS.oTestInstanceActual.nMinutosVencimientoRegistryOrganizacion = 0
					THIS.oTestInstanceActual.nMinutosVencimientoRegistryPuesto = 0
					THIS.oTestInstanceActual.nMinutosVencimientoRegistrySucursal = 0
				ENDIF
			CATCH
				*-- Ignorar: el test puede no tener estas propiedades (tests no-legacy)
			ENDTRY
		ENDIF
	EndFunc


	*-----------------------------------------------------------------------------------------
	* Setup para ztestKontrolerSeguridad
	* Carga seguridad.vcx desde Organic.Core.app (donde esta compilado)
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTKONTROLERSEGURIDAD() As Void
		_screen._instanceFactory.LoadReference('seguridad.vcx', "Organic.Core.app")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para ztestkontrolerperfiles
	* Carga seguridad.vcx via LoadReference
	* Preserva Mensajes para restaurar en TearDown (crearobjeto lo sobreescribe)
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTKONTROLERPERFILES() As Void
		_screen._instanceFactory.LoadReference('seguridad.vcx', "Organic.Core.app")
		THIS.ReemplazarServicioGlobal("Mensajes", goMensajes)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestFitKontrolerSeguridadPerfiles
	* Carga seguridad.vcx via LoadReference
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTFITKONTROLERSEGURIDADPERFILES() As Void
		_screen._instanceFactory.LoadReference('seguridad.vcx', "Organic.Core.app")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para ztestKontrolerUsuarios
	* Carga seguridad.vcx via LoadReference para Frm_usuariosEstilo2
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTKONTROLERUSUARIOS() As Void
		_screen._instanceFactory.LoadReference('seguridad.vcx', "Organic.Core.app")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para ztestkontrolerperfiles
	* Restaura Mensajes y limpia classlib seguridad
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTKONTROLERPERFILES() As Void
		THIS.RestaurarServicioGlobal("Mensajes")
		TRY
			CLEAR CLASSLIB seguridad
		CATCH
		ENDTRY
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestSeguridad
	* Carga los PRGs de formularios de login/usuario via LoadReference con DO (.T.)
	* para que NEWOBJECT encuentre las clases padre definidas en esos PRGs
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTSEGURIDAD() As Void
		_screen._instanceFactory.LoadReference('frm_frmlogin_windowsestilo2.prg', "Organic.Core.app", .T.)
		_screen._instanceFactory.LoadReference('frm_frmusuarioyClavelinceestilo1.prg', "Organic.Core.app", .T.)
		_screen._instanceFactory.LoadReference('frm_frmusuarioyClavewindowsestilo2.prg', "Organic.Core.app", .T.)

		*-- Los tests de zTestSeguridad necesitan la Seguridad REAL (no el mock)
		*-- porque acceden a oCol_Accesos, CrearColeccionHabilitaMenu(), etc.
		THIS.ReemplazarServicioGlobal("Seguridad", _screen.zoo.crearobjeto("Seguridad"))
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTSEGURIDAD() As Void
		THIS.RestaurarServicioGlobal("Seguridad")
	EndFunc

	*=======================================================================================
	* LISTADOS - Tests que necesitan VCXs de reportes cargadas via LoadReference
	*=======================================================================================

	*-----------------------------------------------------------------------------------------
	* TearDown generico 
	*-----------------------------------------------------------------------------------------
	Function TearDown_Default() As Void
		LOCAL lcMensajes, i, loMensaje, llTestFailed, lnMensajes, lnErrores
		
		lnMensajes = 0
		lnErrores = 0
		
		*-- Contar mensajes capturados
		IF !ISNULL(THIS.oMensajesCapturados)
			lnMensajes = THIS.oMensajesCapturados.Count
		ENDIF
		
		*-- Contar errores capturados
		IF !ISNULL(THIS.oErroresCapturados)
			lnErrores = THIS.oErroresCapturados.Count
		ENDIF
		
		IF !ISNULL(THIS.oTestInstanceActual) AND (lnMensajes > 0 OR lnErrores > 0)
			THIS.oTestInstanceActual.MessageOut("=== CAPTURAS: " + TRANSFORM(lnMensajes) + " mensajes, " + TRANSFORM(lnErrores) + " errores ===")
		ENDIF
		
		*-- Mostrar mensajes capturados si hay
		IF lnMensajes > 0
			*-- Construir reporte de mensajes
			lcMensajes = ""
			FOR i = 1 TO THIS.oMensajesCapturados.Count
				loMensaje = THIS.oMensajesCapturados.Item(i)
				
				IF i > 1
					lcMensajes = lcMensajes + CHR(13) + CHR(10)
				ENDIF
				
				lcMensajes = lcMensajes + ;
					"[" + loMensaje.Metodo + "] " + ;
					loMensaje.Mensaje + ;
					IIF(!EMPTY(loMensaje.Titulo), " (" + loMensaje.Titulo + ")", "")
			ENDFOR
			
			*-- Mostrar en el output del test
			IF !ISNULL(THIS.oTestInstanceActual)
				THIS.oTestInstanceActual.MessageOut("--- MENSAJES CAPTURADOS ---")
				THIS.oTestInstanceActual.MessageOut(lcMensajes)
			ENDIF
		ENDIF
		
		*-- Mostrar errores capturados si hay
		IF lnErrores > 0
			LOCAL lcErrores, loError
			*-- Construir reporte de errores
			lcErrores = ""
			FOR i = 1 TO THIS.oErroresCapturados.Count
				loError = THIS.oErroresCapturados.Item(i)
				
				IF i > 1
					lcErrores = lcErrores + CHR(13) + CHR(10) + "---" + CHR(13) + CHR(10)
				ENDIF
				
				lcErrores = lcErrores + ;
					"[" + TRANSFORM(loError.Timestamp) + "] " + ;
					"Clase: " + loError.ClaseOrigen + CHR(13) + CHR(10) + ;
					"Error: " + loError.TextoError
			ENDFOR
			
			*-- Mostrar en el output del test
			IF !ISNULL(THIS.oTestInstanceActual)
				THIS.oTestInstanceActual.MessageOut("--- ERRORES LOGUEADOS ---")
				THIS.oTestInstanceActual.MessageOut(lcErrores)
			ENDIF
		ENDIF
		
		*-- Por defecto no hacemos VerifyAll porque muchos mocks son LOOSE
		*-- y algunos setups de BINDEVENT nunca se invocan (solo se registran)
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	* Setup para zTest0_ValidarAdnImplant_LogErrores
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTEST0_VALIDARADNIMPLANT_LOGERRORES() As Void
		LOCAL lcRutaLog, lcArchivo1, lcArchivo2, lcArchivo3, lcArchivo4
		
		*-- Obtener ruta de logs (bin\App\Log)
		lcRutaLog = ADDBS(_screen.zoo.cRutaInicial) + "Log\"
		
		*-- Crear directorio si no existe
		IF !DIRECTORY(lcRutaLog)
			MKDIR (lcRutaLog)
		ENDIF
		
		*-- Definir nombres de archivos
		lcArchivo1 = lcRutaLog + "AdnImplant.log"
		lcArchivo2 = lcRutaLog + "AdnImplant_Errores.log"
		lcArchivo3 = lcRutaLog + "AdnImplant_ConfiguracionBasica.log"
		lcArchivo4 = lcRutaLog + "AdnImplant_ArchivosSql.log"
		
		IF !FILE(lcArchivo1)
			STRTOFILE("", lcArchivo1)
		ENDIF
		IF !FILE(lcArchivo2)
			STRTOFILE("", lcArchivo2)
		ENDIF
		IF !FILE(lcArchivo3)
			STRTOFILE("", lcArchivo3)
		ENDIF
		IF !FILE(lcArchivo4)
			STRTOFILE("", lcArchivo4)
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para ztestEntidadBaseDeDatos
	* Inyecta mock de ManagerImpresion via ReemplazarServicioGlobal
	* Evita que Impresion_Access() -> CrearObjetoServicios() intente crear el real
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTENTIDADBASEDEDATOS() As Void
		LOCAL loMock
		loMock = THIS.CrearMockManagerImpresion()
		THIS.ReemplazarServicioGlobal("Impresion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para ztestEntidadBaseDeDatos
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTENTIDADBASEDEDATOS() As Void
		THIS.RestaurarServicioGlobal("Impresion")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestEspecificacionMonitorQA
	* Guarda los mocks y los reemplaza con objetos reales para que el test pueda verificar firmas
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTESPECIFICACIONMONITORQA() As Void
		THIS.ReemplazarServicioGlobal("Mensajes", NEWOBJECT("Mensajes", "Mensajes.prg"))
		THIS.ReemplazarServicioGlobal("Ejecucion", NEWOBJECT("ManagerEjecucion", "ManagerEjecucion.prg"))
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	* TearDown para zTestEspecificacionMonitorQA
	* Restaura los mocks originales
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTESPECIFICACIONMONITORQA() As Void
		THIS.RestaurarServicioGlobal("Mensajes")
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestALanzadorMensajesSonoros
	* Configura el mock de Mensajes.ObtenerTitulo()
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTALANZADORMENSAJESSONOROS() As Void
		THIS.BackupVariablePublica("goServicios")
		THIS.BackupVariablePublica("goParametros")
		
		LOCAL loMock, loSetup
		loMock = goDoVfpMock.Mock("Mensajes", "Mensajes.prg", "LOOSE")
		loSetup = loMock.Setup("ObtenerTitulo")
		loSetup.Returns(_Screen.Zoo.App.Nombre)

		THIS.ReemplazarServicioGlobal("Mensajes", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestALanzadorMensajesSonoros
	* Restaura Mensajes, goServicios y goParametros
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTALANZADORMENSAJESSONOROS() As Void
		THIS.RestaurarServicioGlobal("Mensajes")
		THIS.RestaurarVariablePublica("goParametros")
		THIS.RestaurarVariablePublica("goServicios")

		IF TYPE("goServicios") = "O" AND !ISNULL(goServicios)
			_screen.zoo.oServicios = goServicios
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC() As Void
		THIS.ReemplazarServicioGlobal("Ejecucion", _screen.zoo.oServicios.Ejecucion)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestAccionDeAgenteOrganic
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTACCIONDEAGENTEORGANIC() As Void
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic::zTestU_ObtenerScript_Ok
	* Configura el mock con "Paises" como base de datos
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC_ZTESTU_OBTENERSCRIPT_OK() As Void
		LOCAL loMock, loSetup, lcScript, lcIdApp
		
		lcIdApp = IIF(TYPE("_Screen.Zoo.App.cIdAplicacion") = "C", _Screen.Zoo.App.cIdAplicacion, "")
		
		lcScript = goServicios.Librerias.Encriptar( "<script><C><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cUsuarioLogueado><C><ADMIN>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cSucursalActiva><C><Paises>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando1><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando2><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic::zTestU_GuardarScript_Ok
	* Configura el mock con "Paises" como base de datos (mismo que zTestU_ObtenerScript_Ok)
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC_ZTESTU_GUARDARSCRIPT_OK() As Void
		LOCAL loMock, loSetup, lcScript, lcIdApp
		
		lcIdApp = IIF(TYPE("_Screen.Zoo.App.cIdAplicacion") = "C", _Screen.Zoo.App.cIdAplicacion, "")
		
		lcScript = goServicios.Librerias.Encriptar( "<script><C><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cUsuarioLogueado><C><ADMIN>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cSucursalActiva><C><Paises>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando1><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando2><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic::zTestU_ObtenerScript_Ok_ConBaseDeDatos
	* Configura el mock para devolver un script con "OTRA" como base de datos
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC_ZTESTU_OBTENERSCRIPT_OK_CONBASEDEDATOS() As Void
		LOCAL loMock, loSetup, lcScript, lcIdApp
		
		lcIdApp = IIF(TYPE("_Screen.Zoo.App.cIdAplicacion") = "C", _Screen.Zoo.App.cIdAplicacion, "")
		
		lcScript = goServicios.Librerias.Encriptar( "<script><C><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cUsuarioLogueado><C><ADMIN>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cSucursalActiva><C><OTRA>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando1><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando2><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAnalizadorConfiguracionAAO
	* Configura el mock de goServicios.Ejecucion.GenerarContenidoDelScriptScript()
	* para devolver un script que contenga "EnviaRecibeProcesa.sz"
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTANALIZADORCONFIGURACIONAAO() As Void
		LOCAL loMock, loSetup, lcScript
		
		lcScript = "EnviaRecibeProcesa.sz"
		
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestAnalizadorConfiguracionAAO
	* Restaura el mock original de Ejecucion
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTANALIZADORCONFIGURACIONAAO() As Void
		THIS.RestaurarComunicaciones()
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAnalizadorConfiguracionAAO.zTestObtenerParametrosEnviarYRecibir
	* Con lDesarrollo=.F., ObtenerParametrosEnviarYRecibir() lee
	* EnviarRecibirYProcesarAutomaticamente cuyo _Access dispara WCF en localhost:7532.
	* Solucion: reemplazar Comunicaciones con un Custom plano sin _Access.
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTANALIZADORCONFIGURACIONAAO_ZTESTOBTENERPARAMETROSENVIARYRECIBIR() As Void
		THIS.ReemplazarComunicacionesConFake(.F.)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAnalizadorConfiguracionAAO.zTestObtenerParametrosEnviarYRecibir_VerificarValores
	* Este test setea lDesarrollo=.F. y lEsBuildAutomatico=.F., espera Habilitada=.T.
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTANALIZADORCONFIGURACIONAAO_ZTESTOBTENERPARAMETROSENVIARYRECIBIR_VERIFICARVALORES() As Void
		THIS.ReemplazarComunicacionesConFake(.T.)
	EndFunc


	*-----------------------------------------------------------------------------------------
	* Setup para zTestRegistroTerminal
	* Guarda el mock de Ejecucion y lo reemplaza con TieneScriptCargado ? .F.
	* Si el per-method setup ya inyecto un mock, NO sobreescribir.
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTREGISTROTERMINAL() As Void
		*-- Si el per-method setup ya configuro Ejecucion (guardo backup), no sobreescribir
		IF !ISNULL(THIS.oTestInstanceActual) AND ;
		   PEMSTATUS(THIS.oTestInstanceActual, "__OriginalMockEjecucion", 5)
			RETURN
		ENDIF
		LOCAL loMock
		loMock = THIS.CrearMockManagerEjecucion(.F.)
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestRegistroTerminal
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTREGISTROTERMINAL() As Void
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestRegistroTerminal::zTestRegistrarConScriptOrganicCargado
	* Este test necesita TieneScriptCargado=.T. (a diferencia de los demas que usan .F.)
	* ReemplazarServicioGlobal guarda backup en __OriginalMockEjecucion, lo que hace
	* que Setup_ZTESTREGISTROTERMINAL (clase) detecte que ya fue configurado y no sobreescriba.
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTREGISTROTERMINAL_ZTESTREGISTRARCONSCRIPTORGANICCARGADO() As Void
		LOCAL loMock
		loMock = THIS.CrearMockManagerEjecucion(.T.)
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestLanzadorDeConsulta
	* Cierra el cursor C_DATOSMOTOR que queda abierto despues de Procesar()
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTLANZADORDECONSULTA() As Void
		IF USED("C_DATOSMOTOR")
			USE IN SELECT("C_DATOSMOTOR")
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestObjetoLogueo::zTestObtenerOrigenLogueo_EsUI
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTOBJETOLOGUEO_ZTESTOBTENERORIGENLOGUEO_ESUI() As Void
		LOCAL loMock
		loMock = THIS.CrearMockManagerEjecucion(.F.)
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	Function TearDown_ZTESTOBJETOLOGUEO_ZTESTOBTENERORIGENLOGUEO_ESUI() As Void
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestObjetoLogueo::zTestObtenerOrigenLogueo_EsSystemStartUp
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTOBJETOLOGUEO_ZTESTOBTENERORIGENLOGUEO_ESSYSTEMSTARTUP() As Void
		LOCAL loMock
		loMock = THIS.CrearMockManagerEjecucion(.F.)
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	Function TearDown_ZTESTOBJETOLOGUEO_ZTESTOBTENERORIGENLOGUEO_ESSYSTEMSTARTUP() As Void
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestManagerLogueos (toda la clase)
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTMANAGERLOGUEOS() As Void
		LOCAL loMock
		loMock = THIS.CrearMockManagerEjecucion(.F.)
		THIS.ReemplazarServicioGlobal("Ejecucion", loMock.Object)
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestManagerLogueos
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTMANAGERLOGUEOS() As Void
		THIS.RestaurarServicioGlobal("Ejecucion")
	EndFunc


	*-----------------------------------------------------------------------------------------
	* Setup para ztestNocturnosvisualizacionfrx
	* Carga VCXs de reportes desde Organic.Core.app
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTNOCTURNOSVISUALIZACIONFRX() As Void
		_screen._instanceFactory.LoadReference('sfrepobj.vcx', "Organic.Core.app")
		_screen._instanceFactory.LoadReference('sfctrls.vcx', "Organic.Core.app")
		_screen._instanceFactory.LoadReference('_reportlistener.vcx', "Organic.Core.app")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para ztestNocturnosPreparacionSalida
	* Carga VCXs de reportes desde Organic.Core.app
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTNOCTURNOSPREPARACIONSALIDA() As Void
		_screen._instanceFactory.LoadReference('sfrepobj.vcx', "Organic.Core.app")
		_screen._instanceFactory.LoadReference('sfctrls.vcx', "Organic.Core.app")
		_screen._instanceFactory.LoadReference('_reportlistener.vcx', "Organic.Core.app")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestKontrolerCambioDeClave
	* Reemplaza Seguridad LOOSE con un objeto real para que acceda a cUsuarioLogueado
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTKONTROLERCAMBIODECLAVE() As Void
		THIS.ReemplazarServicioGlobal("Seguridad", _screen.zoo.crearobjeto("Seguridad"))
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestKontrolerCambioDeClave
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTKONTROLERCAMBIODECLAVE() As Void
		THIS.RestaurarServicioGlobal("Seguridad")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para ztestprocesotransferencias
	* Reemplaza Seguridad LOOSE con un objeto real para que acceda a cUsuarioLogueado
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTPROCESOTRANSFERENCIAS() As Void
		THIS.ReemplazarServicioGlobal("Seguridad", _screen.zoo.crearobjeto("Seguridad"))
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para ztestprocesotransferencias
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTPROCESOTRANSFERENCIAS() As Void
		THIS.RestaurarServicioGlobal("Seguridad")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestManagerTransferenciasaBaseDeDatos
	* Safety cleanup: desvincular eventos de SaltosDeCampoYValoresSugeridos
	* para evitar error 1184 si un assert falla antes del unbindevents explicito
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTMANAGERTRANSFERENCIASABASEDEDATOS() As Void
		TRY
			UNBINDEVENTS(goServicios.SaltosDeCampoYValoresSugeridos)
		CATCH
		ENDTRY
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestManagerEjecucion
	* Reemplaza Seguridad LOOSE con un objeto real con propiedades escribibles
	* Los tests escriben cUsuarioLogueado y cUsuarioAdministrador via LogIn/EjecutarAcciones
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTMANAGEREJECUCION() As Void
		THIS.ReemplazarServicioGlobal("Seguridad", _screen.zoo.crearobjeto("Seguridad"))
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestManagerEjecucion
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTMANAGEREJECUCION() As Void
		THIS.RestaurarServicioGlobal("Seguridad")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestLanzadorMensajesSilenciosos
	* Reemplaza Seguridad LOOSE con un objeto real para que acceda a cUsuarioOtorgaPermiso
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTLANZADORMENSAJESSILENCIOSOS() As Void
		THIS.ReemplazarServicioGlobal("Seguridad", _screen.zoo.crearobjeto("Seguridad"))
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestLanzadorMensajesSilenciosos
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTLANZADORMENSAJESSILENCIOSOS() As Void
		THIS.RestaurarServicioGlobal("Seguridad")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup/TearDown para zTestAplicacionBase
	* InicializarBaseDeDatos() usa cBaseDeDatosSeleccionada primero; si devuelve "Paises"
	* pisa cualquier cSucursalActiva que el test haya seteado.
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTAPLICACIONBASE() As Void
		LOCAL loMock, loSetup, lcStubs
		loMock = goDoVfpMock.Mock("Seguridad", "Seguridad.prg", "LOOSE")
		loSetup = loMock.SetupGet("cBaseDeDatosSeleccionada")
		loSetup.Returns("")
		loSetup = loMock.SetupGet("cUltimoUsuarioLogueado")
		loSetup.Returns("ADMIN")
		loSetup = loMock.Setup("ObtenerUltimoUsuarioLogueado")
		loSetup.Returns("ADMIN")
		loSetup = loMock.SetupGet("ObtenerUltimoUsuarioLogueado")
		loSetup.Returns("ADMIN")
		loSetup = loMock.Setup("ObtenerUltimoUsuarioLogueadoParaLogin")
		loSetup.Returns("ADMIN")
		loSetup = loMock.Setup("RefrescarMenuYBarraDelFormularioPrincipal")
		loSetup.Returns(.T.)
		THIS.ReemplazarServicioGlobal("Seguridad", loMock.Object)
		_screen._instanceFactory.LoadReference('zooformprincipal.prg', "", .t.)
	EndFunc

	Function TearDown_ZTESTAPLICACIONBASE() As Void
		THIS.RestaurarServicioGlobal("Seguridad")
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup/TearDown para zTestEntidad
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTENTIDAD() As Void
		THIS.ReemplazarServicioGlobal("RegistroDeActividad", _screen.zoo.crearobjeto("ServicioRegistroDeActividad"))
	EndFunc

	Function TearDown_ZTESTENTIDAD() As Void
		THIS.RestaurarServicioGlobal("RegistroDeActividad")
	EndFunc


enddefine

