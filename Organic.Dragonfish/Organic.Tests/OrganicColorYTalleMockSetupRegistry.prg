***********************************************************************
*	OrganicColorYTalleMockSetupRegistry.prg
*	
*	Registro de setups y teardowns de mocks específicos para Organic.Dragonfish.
*	Hereda de MockSetupRegistry (dovfp.FxuLegacy) y agrega los setups
*	particulares de este proyecto.
*	
*	USO:
*	  En mainTest.prg:
*	    PUBLIC goMockSetupRegistry
*	    goMockSetupRegistry = NEWOBJECT("OrganicColorYTalleMockSetupRegistry", "OrganicColorYTalleMockSetupRegistry.prg")
*	
*	CÓMO AGREGAR UN NUEVO SETUP ESPECÍFICO:
*	  1. Crear un método con el nombre: Setup_<NombreDelTest>
*	     Ejemplo: Para zTestEntidadCliente -> Setup_zTestEntidadCliente
*	  2. Implementar los mocks específicos en ese método
*	  3. El método será invocado automáticamente antes del Setup() del test
*	
*	CÓMO AGREGAR UN NUEVO TEARDOWN ESPECÍFICO:
*	  1. Crear un método con el nombre: TearDown_<NombreDelTest>
*	  2. Implementar los Verify de los mocks en ese método
*	  3. El método será invocado automáticamente después del TearDown() del test
*	
*	CONVENCIÓN DE NOMBRES:
*	  - Setup_<NombreClaseTest>                 -> Para toda la clase de test
*	  - Setup_<NombreClaseTest>_<NombreMetodo>  -> Para un método específico
*	  - TearDown_<NombreClaseTest>              -> Para toda la clase de test
*	  - TearDown_<NombreClaseTest>_<NombreMetodo> -> Para un método específico
*	
***********************************************************************

Define Class OrganicColorYTalleMockSetupRegistry As MockSetupRegistry Of MockSetupRegistry.prg

	*-- Colección para capturar mensajes enviados por el mock de Mensajes
	oMensajesCapturados = .NULL.
	
	*-- Colección para capturar errores logueados por ManagerLogueos
	oErroresCapturados = .NULL.
	
	*-- Backup para EnviarRecibirYProcesarAutomaticamente
	lEnviarRecibirYProcesarAutomaticamente_Backup = .F.
	
	*-- Init: Crear colecciones
	PROCEDURE Init
		DODEFAULT()
		THIS.oMensajesCapturados = CREATEOBJECT("Collection")
		THIS.oErroresCapturados = CREATEOBJECT("Collection")
	ENDPROC

	*-----------------------------------------------------------------------------------------
	* Setup_Default: Se ejecuta ANTES de cada test
	* Limpia los mensajes capturados para que cada test empiece con la colección vacía
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
	EndFunc

	*=======================================================================================
	* SECCIÓN: SETUPS ESPECÍFICOS POR TEST
	* 
	* Agregar métodos aquí siguiendo la convención:
	*   Setup_<NombreClaseTest>                 -> Para toda la clase
	*   Setup_<NombreClaseTest>_<NombreMetodo>  -> Para un método específico
	*=======================================================================================
	
	*-----------------------------------------------------------------------------------------
	* EJEMPLO: Setup para zTestEntidadArticulo (toda la clase)
	*-----------------------------------------------------------------------------------------
	* Function Setup_ZTESTENTIDADARTICULO() As Void
	*     LOCAL loMock, loSetup
	*     loMock = THIS.oMockManager.Mock("AlgunServicio", "AlgunServicio.prg", "LOOSE")
	*     loSetup = loMock.Setup("AlgunMetodo")
	*     loSetup.Returns(.T.)
	* EndFunc
	
	*-----------------------------------------------------------------------------------------
	* EJEMPLO: Setup para un método específico de un test
	*-----------------------------------------------------------------------------------------
	* Function Setup_ZTESTENTIDADARTICULO_ZTESTCREARARTICULO() As Void
	*     LOCAL loMock, loSetup
	*     loMock = THIS.oMockManager.Mock("OtroServicio", "OtroServicio.prg", "STRICT")
	*     loSetup = loMock.Setup("OtroMetodo")
	*     loSetup.Returns("valor específico para este test")
	* EndFunc
	
	*=======================================================================================
	* SETUPS REALES - Agregar a continuación los setups específicos migrados desde maintest
	*=======================================================================================
	
	*-- Los setups genéricos que aplican a todos los tests permanecen en maintest.prg
	*-- Solo los setups que son específicos para ciertos tests van aquí

	*=======================================================================================
	* ZTESTAPLICACIONBASE - Tests que necesitan ManagerFormularios.Leer("111111")
	*=======================================================================================
	
	*-----------------------------------------------------------------------------------------
	* Setup para zTestAplicacionBase - Configura ManagerFormularios.Leer para varios tests
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTAPLICACIONBASE() As Void
		LOCAL loMock, loSetup
		
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestModulos - Configura ManagerFormularios.Leer para módulos
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTMODULOS() As Void
		LOCAL loMock, loSetup
		
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestFuncion_Alltrim - necesita goDatos.EjecutarSQL
	* Este test es de integración y prueba funciones SQL reales.
	* El mock simula la ejecución SQL devolviendo un cursor con los datos esperados.
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTFUNCION_ALLTRIM_ZTESTSQLSERVERFUNCIONALIDAD() As Void
		LOCAL loMock, loSetup
		
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestChequeoDeDatosBasicos - Configura ManagerConexionASql
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTCHEQUEODEDATOSBASICOS() As Void
		LOCAL loMock, loMockManager, loSetup
		
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown genérico que verifica que no hubo llamadas inesperadas a mocks STRICT
	* Se puede sobrescribir por test si se necesita verificación específica
	* ADEMÁS: Muestra los mensajes/errores capturados para diagnóstico
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
		
		*-- SIEMPRE mostrar resumen de capturas (para diagnóstico)
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
	* Setup para zTestAplicacionBase.ztestAperturaAutomatidaDeEntidades
	* Configura mock para ManagerAccionesAutomaticas.LaEntidadTieneAccionesAutomaticas
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTAPLICACIONBASE_ZTESTAPERTURAAUTOMATIDADEENTIDADES() As Void
		*-- Agregar mock legacy para ManagerAccionesAutomaticas
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestAplicacionBase - Verifica mocks específicos
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTAPLICACIONBASE() As Void
		*-- No verificamos ManagerFormularios porque es LOOSE y tiene muchos métodos
		*-- que pueden o no ser llamados dependiendo del test específico
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestModulos - Verifica mocks específicos
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTMODULOS() As Void
		*-- Similar a zTestAplicacionBase, no verificamos estrictamente
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	* Setup para zTest0_ValidarAdnImplant_LogErrores
	* Crea los 4 archivos de log vacíos que los tests esperan encontrar
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
		
		*-- Crear archivos vacíos si no existen
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
	* Setup para zTestEspecificacionMonitorQA
	* Guarda los mocks y los reemplaza con objetos reales para que el test pueda verificar firmas
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTESPECIFICACIONMONITORQA() As Void
		*-- Verificar que tenemos la instancia del test
		IF ISNULL(THIS.oTestInstanceActual)
			RETURN
		ENDIF
		
		*-- Guardar el mock de Mensajes en una propiedad del test
		IF TYPE("_screen.zoo.oServicios.Mensajes") = "O"
			THIS.oTestInstanceActual.AddProperty("__OriginalMockMensajes", _screen.zoo.oServicios.Mensajes)
			
			*-- Instanciar el objeto real Mensajes
			_screen.zoo.oServicios.Mensajes = newobject("Mensajes", "Mensajes.prg")
		ENDIF
		
		*-- Guardar el mock de Ejecucion en una propiedad del test
		IF TYPE("_screen.zoo.oServicios.Ejecucion") = "O"
			THIS.oTestInstanceActual.AddProperty("__OriginalMockEjecucion", _screen.zoo.oServicios.Ejecucion)
			
			*-- Instanciar el objeto real ManagerEjecucion
			_screen.zoo.oServicios.Ejecucion = newobject("ManagerEjecucion", "ManagerEjecucion.prg")
		ENDIF
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	* TearDown para zTestEspecificacionMonitorQA
	* Restaura los mocks originales
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTESPECIFICACIONMONITORQA() As Void
		*-- Verificar que tenemos la instancia del test
		IF ISNULL(THIS.oTestInstanceActual)
			RETURN
		ENDIF
		
		*-- Restaurar el mock de Mensajes
		IF PEMSTATUS(THIS.oTestInstanceActual, "__OriginalMockMensajes", 5)
			_screen.zoo.oServicios.Mensajes = THIS.oTestInstanceActual.__OriginalMockMensajes
			REMOVEPROPERTY(THIS.oTestInstanceActual, "__OriginalMockMensajes")
		ENDIF
		
		*-- Restaurar el mock de Ejecucion
		IF PEMSTATUS(THIS.oTestInstanceActual, "__OriginalMockEjecucion", 5)
			_screen.zoo.oServicios.Ejecucion = THIS.oTestInstanceActual.__OriginalMockEjecucion
			REMOVEPROPERTY(THIS.oTestInstanceActual, "__OriginalMockEjecucion")
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestALanzadorMensajesSonoros
	* Configura el mock de Mensajes.ObtenerTitulo()
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTALANZADORMENSAJESSONOROS() As Void
		*-- Verificar que tenemos la instancia del test
		IF ISNULL(THIS.oTestInstanceActual)
			RETURN
		ENDIF
		
		*-- Guardar el mock de Mensajes en una propiedad del test
		IF TYPE("_screen.zoo.oServicios.Mensajes") = "O"
			THIS.oTestInstanceActual.AddProperty("__OriginalMockMensajes", _screen.zoo.oServicios.Mensajes)
			
			local loMock, loSetup
			loMock = goDoVfpMock.Mock("Mensajes", "Mensajes.prg", "LOOSE")
			loSetup = loMock.Setup("ObtenerTitulo")
			loSetup.Returns(_Screen.Zoo.App.Nombre)

			*-- Instanciar el objeto real Mensajes
			_screen.zoo.oServicios.Mensajes = loMock.Object
			goMensajes = _screen.zoo.oServicios.Mensajes
		ENDIF

	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestALanzadorMensajesSonoros
	* NO se limpia el Setup de ObtenerTitulo porque:
	* 1. El mock de Mensajes es LOOSE (no requiere verificación estricta)
	* 2. goDoVfpMock no provee método para remover setups individuales
	* 3. El setup no interfiere con otros tests
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTALANZADORMENSAJESSONOROS() As Void
		*-- No requiere limpieza
		*-- Verificar que tenemos la instancia del test
		IF ISNULL(THIS.oTestInstanceActual)
			RETURN
		ENDIF
		
		*-- Restaurar el mock de Mensajes
		IF PEMSTATUS(THIS.oTestInstanceActual, "__OriginalMockMensajes", 5)
			_screen.zoo.oServicios.Mensajes = THIS.oTestInstanceActual.__OriginalMockMensajes
			goMensajes = _screen.zoo.oServicios.Mensajes
			REMOVEPROPERTY(THIS.oTestInstanceActual, "__OriginalMockMensajes")
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic
	* Guarda el mock original de Ejecucion para restaurarlo en TearDown
	* Los setups específicos se encargan de configurar cada caso
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC() As Void
		*-- Guardar el mock original de Ejecucion para restaurarlo después
		IF !ISNULL(THIS.oTestInstanceActual) AND TYPE("_screen.zoo.oServicios.Ejecucion") = "O"
			THIS.oTestInstanceActual.AddProperty("__OriginalMockEjecucion", _screen.zoo.oServicios.Ejecucion)
		ENDIF
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestAccionDeAgenteOrganic
	* Recrea el mock de ManagerEjecucion con la configuración original de mainTest.prg
	* porque los setups específicos crean un nuevo mock que invalida el original
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTACCIONDEAGENTEORGANIC() As Void
		LOCAL loMock, loSetup
		
		*-- Recrear el mock de ManagerEjecucion con la configuración original de mainTest.prg
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("TieneScriptCargado")
		loSetup.Returns(.T.)
		loSetup = loMock.Setup("EjecutarAplicacion")
		loSetup = loSetup.WithArgs(goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny(), goDoVfpMock.oIt.IsAny())
		loSetup.Returns(.T.)
		
		*-- Asignar el mock recreado a goServicios.Ejecucion
		_screen.zoo.oServicios.Ejecucion = loMock.Object
		
		*-- Limpiar la propiedad temporal si existe
		IF !ISNULL(THIS.oTestInstanceActual) AND PEMSTATUS(THIS.oTestInstanceActual, "__OriginalMockEjecucion", 5)
			REMOVEPROPERTY(THIS.oTestInstanceActual, "__OriginalMockEjecucion")
		ENDIF
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic::zTestU_ObtenerScript_Ok
	* Configura el mock con "Paises" como base de datos
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC_ZTESTU_OBTENERSCRIPT_OK() As Void
		LOCAL loMock, loSetup, lcScript, lcIdApp
		
		*-- Obtener el IdApp actual
		lcIdApp = IIF(TYPE("_Screen.Zoo.App.cIdAplicacion") = "C", _Screen.Zoo.App.cIdAplicacion, "")
		
		*-- Generar script encriptado con 7 líneas usando "Paises"
		lcScript = goServicios.Librerias.Encriptar( "<script><C><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cUsuarioLogueado><C><ADMIN>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cSucursalActiva><C><Paises>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando1><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando2><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		
		*-- Configurar mock de Ejecucion
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		*-- Asignar el mock a goServicios.Ejecucion
		_screen.zoo.oServicios.Ejecucion = loMock.Object
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic::zTestU_GuardarScript_Ok
	* Configura el mock con "Paises" como base de datos (mismo que zTestU_ObtenerScript_Ok)
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC_ZTESTU_GUARDARSCRIPT_OK() As Void
		LOCAL loMock, loSetup, lcScript, lcIdApp
		
		*-- Obtener el IdApp actual
		lcIdApp = IIF(TYPE("_Screen.Zoo.App.cIdAplicacion") = "C", _Screen.Zoo.App.cIdAplicacion, "")
		
		*-- Generar script encriptado con 7 líneas usando "Paises"
		lcScript = goServicios.Librerias.Encriptar( "<script><C><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cUsuarioLogueado><C><ADMIN>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cSucursalActiva><C><Paises>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando1><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando2><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		
		*-- Configurar mock de Ejecucion
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		*-- Asignar el mock a goServicios.Ejecucion
		_screen.zoo.oServicios.Ejecucion = loMock.Object
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAccionDeAgenteOrganic::zTestU_ObtenerScript_Ok_ConBaseDeDatos
	* Configura el mock para devolver un script con "OTRA" como base de datos
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTACCIONDEAGENTEORGANIC_ZTESTU_OBTENERSCRIPT_OK_CONBASEDEDATOS() As Void
		LOCAL loMock, loSetup, lcScript, lcIdApp
		
		*-- Obtener el IdApp actual
		lcIdApp = IIF(TYPE("_Screen.Zoo.App.cIdAplicacion") = "C", _Screen.Zoo.App.cIdAplicacion, "")
		
		*-- Generar script encriptado con 7 líneas usando "OTRA" como base de datos
		lcScript = goServicios.Librerias.Encriptar( "<script><C><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cUsuarioLogueado><C><ADMIN>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<cSucursalActiva><C><OTRA>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando1><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<Comando2><accion><>" ) + CHR(13) + CHR(10)
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		
		*-- Configurar mock de Ejecucion
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		*-- Asignar el mock a goServicios.Ejecucion
		_screen.zoo.oServicios.Ejecucion = loMock.Object
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAnalizadorConfiguracionAAO
	* Configura el mock de goServicios.Ejecucion.GenerarContenidoDelScriptScript()
	* para devolver un script que contenga "EnviaRecibeProcesa.sz"
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTANALIZADORCONFIGURACIONAAO() As Void
		LOCAL loMock, loSetup, lcScript
		
		*-- Generar script simple que contenga EnviaRecibeProcesa.sz
		lcScript = "EnviaRecibeProcesa.sz"
		
		*-- Configurar mock de Ejecucion
		loMock = goDoVfpMock.Mock("ManagerEjecucion", "ManagerEjecucion.prg", "LOOSE")
		loSetup = loMock.Setup("GenerarContenidoDelScriptScript")
		loSetup.Returns(lcScript)
		
		*-- Asignar el mock a goServicios.Ejecucion
		_screen.zoo.oServicios.Ejecucion = loMock.Object
	EndFunc

	*-----------------------------------------------------------------------------------------
	* Setup para zTestAnalizadorConfiguracionAAO.zTestObtenerParametrosEnviarYRecibir
	* Guarda y setea EnviarRecibirYProcesarAutomaticamente a .F. para que el test funcione
	*-----------------------------------------------------------------------------------------
	Function Setup_ZTESTANALIZADORCONFIGURACIONAAO_ZTESTOBTENERPARAMETROSENVIARYRECIBIR() As Void
		THIS.lEnviarRecibirYProcesarAutomaticamente_Backup = goServicios.Parametros.nucleo.Comunicaciones.EnviarRecibirYProcesarAutomaticamente
		goServicios.Parametros.nucleo.Comunicaciones.EnviarRecibirYProcesarAutomaticamente = .F.
	EndFunc

	*-----------------------------------------------------------------------------------------
	* TearDown para zTestAnalizadorConfiguracionAAO.zTestObtenerParametrosEnviarYRecibir
	* Restaura el valor original de EnviarRecibirYProcesarAutomaticamente
	*-----------------------------------------------------------------------------------------
	Function TearDown_ZTESTANALIZADORCONFIGURACIONAAO_ZTESTOBTENERPARAMETROSENVIARYRECIBIR() As Void
		goServicios.Parametros.nucleo.Comunicaciones.EnviarRecibirYProcesarAutomaticamente = THIS.lEnviarRecibirYProcesarAutomaticamente_Backup
	EndFunc

enddefine

