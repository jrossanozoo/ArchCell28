**********************************************************************
Define Class zTestNumeracionesClavesDuplicadas as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestNumeracionesClavesDuplicadas of zTestNumeracionesClavesDuplicadas.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerNuevoNumeroCuandoHayConcurrencia
		local loNumeraciones as Numeraciones of Numeraciones.prg ,loError as zooexception OF zooexception.prg, ;
			loChile as Din_entidadChile of Din_entidadChile.prg, loActualizador as custom

		goServicios.Datos.EjecutarSentencias( "delete from chile where 1 = 1" , "CHILE" )

		loChile = _screen.zoo.instanciarentidad( "Chile" )
		loChile.Nuevo()
		loChile.DescrIPCION ="Chile"
		loCHile.Grabar()
		loCHile.Release()
		
		goServicios.Datos.EjecutarSentencias( "UPDATE NUMERACIONES Set numero = 15 where entidad = 'CHILE'" , "NUMERACIONES" )
		
		loChile = _screen.zoo.instanciarentidad( "Chile" )
		loNumeraciones = _screen.zoo.crearobjeto( "Numeraciones" )
		loNumeraciones.Inicializar()
		loNumeraciones.SetearEntidad( loChile ) 

		loActualizador = newobject( "ActualizarTalonario" )
		bindevent( loNumeraciones, "EventoAntesDeGrabarNuevoNumeroDeTalonario", loActualizador, "Actualizar" , 1 )

		lnNumero = loNumeraciones.Grabar( "Codigo" )
		this.assertequals( "No debe ser el mismo numero.", lnNumero, 22 )
		loNumeraciones.Release()

	endfunc 
	
enddefine

define class ActualizarTalonario as Custom

	*-----------------------------------------------------------------------------------------
	function Actualizar() as Void

		goServicios.Datos.EjecutarSentencias( "UPDATE NUMERACIONES Set numero = 21 where entidad = 'CHILE'" , "NUMERACIONES" )
	endfunc 

enddefine


