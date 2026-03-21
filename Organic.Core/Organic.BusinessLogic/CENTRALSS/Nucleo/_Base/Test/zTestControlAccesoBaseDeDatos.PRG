**********************************************************************
Define Class zTestControlAccesoBaseDeDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestControlAccesoBaseDeDatos of zTestControlAccesoBaseDeDatos.prg
	#ENDIF
	
	*---------------------------------
	Function zTestControlAccesoBaseDeDatosDisponible
		local loControl as ControlAccesoBaseDeDatos of ControlAccesoBaseDeDatos.prg, loInformacion as zooinformacion of zooInformacion.prg
		
		loControl = _Screen.zoo.crearobjeto( "ControlAccesoBaseDeDatos" )
		loInformacion = loControl.BaseDeDatosDisponible( _Screen.zoo.app.cSucursalActiva )
		this.assertequals( "La base de datos actual no deberia traer información.", null, loInformacion )
		loControl = null
	endfunc

	*---------------------------------
	Function zTestControlAccesoBaseDeDatosNoDisponible
		local loControl as ControlAccesoBaseDeDatos of ControlAccesoBaseDeDatos.prg, loInformacion as zooinformacion of zooInformacion.prg

		loControl = _Screen.zoo.crearobjeto( "TEST_ControlAccesoBaseDeDatos", "zTestControlAccesoBaseDeDatos.prg" )
		loControl.test_lValidarOk = .f.

		loInformacion = loControl.BaseDeDatosDisponible( _Screen.zoo.app.cSucursalActiva )
		if goDatos.EsNativa()
			this.assertequals( "La base de datos actual no deberia traer información por trabajar con nativa.", null, loInformacion )
		else
			this.assertequals( "La Cantidad de informacion es incorrecta.", 1, loInformacion.count )
			this.assertequals( "El mensaje generico es incorrecto.", "Erros de la tarea.", loInformacion.item[1].cmensaje )
		endif

		loControl = null
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class TEST_ControlAccesoBaseDeDatos as ControlAccesoBaseDeDatos of ControlAccesoBaseDeDatos.prg
	
	test_lValidarOk = .f.
	*-----------------------------------------------------------------------------------------
	function CrearControladorAccesos( toConfiguradorDb as Object ) as Void
		local loRetorno as Object
		loRetorno = newobject( "FactoryControladorAccesos", "zTestControlAccesoBaseDeDatos.prg" )
		loRetorno.lValidarOk = this.test_lValidarOk
		return loRetorno
	endfunc 

enddefine
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class FactoryControladorAccesos as custom
	
	lValidarOk = .f.
	cBaseRecibida = ""
	
	*-----------------------------------------------------------------------------------------
	function ValidarAcceso( tcBaseDeDatos, tlEsReplica )
		local loResultado as Object
		this.cBaseRecibida = tcBaseDeDatos
		loResultado = newobject( "TEST_Resultado", "zTestControlAccesoBaseDeDatos.prg" )
		loResultado.resultado = this.lValidarOk 
		loResultado.Mensaje = "Erros de la tarea."
		loResultado.RESULTADOSVALIDACIONES = newobject( "collection" )
		return loResultado
	endfunc 
	
enddefine
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class TEST_Resultado as Custom
	RESULTADOSVALIDACIONES = null
	resultado = .f.
	mensaje = ""
enddefine
