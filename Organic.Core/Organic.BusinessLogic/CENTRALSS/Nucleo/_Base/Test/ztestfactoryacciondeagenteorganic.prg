**********************************************************************
Define Class zTestFactoryAccionDeAgenteOrganic As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestFactoryAccionDeAgenteOrganic Of zTestFactoryAccionDeAgenteOrganic.prg
	#Endif

	*---------------------------------
	Function zTestU_Obtener_Exportaciones
		local loFactory as FactoryAccionDeAgenteOrganic of FactoryAccionDeAgenteOrganic.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg

		loFactory = _screen.zoo.crearobjeto( "FactoryAccionDeAgenteOrganic" )
		loAccion = loFactory.Obtener( "exportacion" )

		this.Assertequals( "No se instanció el objeto esperado", "Exportacioninstruccionesscript", loAccion.oInstrucciones.Class )

		loFactory.release()
		loAccion.release()
	Endfunc

	*---------------------------------
	Function zTestU_Obtener_ResumenDelDia
		local loFactory as FactoryAccionDeAgenteOrganic of FactoryAccionDeAgenteOrganic.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg
		
		loFactory = _screen.zoo.crearobjeto( "FactoryAccionDeAgenteOrganic" )
		loAccion = loFactory.Obtener( "ResumenDelDia" )

		this.Assertequals( "No se instanció el objeto esperado", "Resumendeldiainstruccionesscript", loAccion.oInstrucciones.Class )

		loFactory.release()
		loAccion.release()
	Endfunc

	*---------------------------------
	Function zTestU_Obtener_EnviaRecibeYProcesar
		local loFactory as FactoryAccionDeAgenteOrganic of FactoryAccionDeAgenteOrganic.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg
		
		loFactory = _screen.zoo.crearobjeto( "FactoryAccionDeAgenteOrganic" )
		loAccion = loFactory.Obtener( "EnviaRecibeYProcesar" )

		this.Assertequals( "No se instanció el objeto esperado", "Enviarecibeyprocesarinstruccionesscript", loAccion.oInstrucciones.Class )

		loFactory.release()
		loAccion.release()
	endfunc
	
	*---------------------------------
	Function zTestU_Obtener_ProcesarTransferencia
		local loFactory as FactoryAccionDeAgenteOrganic of FactoryAccionDeAgenteOrganic.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg
		
		loFactory = _screen.zoo.crearobjeto( "FactoryAccionDeAgenteOrganic" )
		loAccion = loFactory.Obtener( "ProcesarTransferencia" )

		this.Assertequals( "No se instanció el objeto esperado", "Procesartransferenciainstruccionesscript", loAccion.oInstrucciones.Class )

		loFactory.release()
		loAccion.release()
	endfunc

	*---------------------------------
	Function zTestU_Obtener_Inexistente
		local loFactory as FactoryAccionDeAgenteOrganic of FactoryAccionDeAgenteOrganic.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, ;
			loError as Exception, loInfo as object
		
		loFactory = _screen.zoo.crearobjeto( "FactoryAccionDeAgenteOrganic" )
		try
			loAccion = loFactory.Obtener( "Inexistente" )
			this.Asserttrue( "Debe dar error", .f. )
		catch to loError
			loInfo = loError.uservalue.ObtenerInformacion()
			if type( "loInfo.Count" ) = "N"
				this.Assertequals( "El mensaje de error no es el esperado", "No se pudieron obtener las instrucciones correspondientes a la clave INEXISTENTE", ;
					loInfo(1).cmensaje )
			else
				throw loError
			endif
		endtry

		loFactory.release()
	Endfunc

Enddefine
