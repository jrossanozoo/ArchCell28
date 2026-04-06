***********************************************************************
*	OrganicZLMockSetupRegistry.prg
*	
*	Registro de setups y teardowns de mocks específicos para Organic.Core.
*	Hereda de MockSetupRegistry (dovfp.FxuLegacy) y agrega los setups
*	particulares de este proyecto.
*	
*	USO:
*	  En mainTest.prg:
*	    PUBLIC goMockSetupRegistry
*	    goMockSetupRegistry = NEWOBJECT("OrganicZLMockSetupRegistry", "OrganicZLMockSetupRegistry.prg")
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

Define Class OrganicZLMockSetupRegistry As MockSetupRegistry Of MockSetupRegistry.prg

	*-- Colección para capturar mensajes enviados por el mock de Mensajes
	oMensajesCapturados = .NULL.
	
	*-- Colección para capturar errores logueados por ManagerLogueos
	oErroresCapturados = .NULL.
	
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

EndDefine
