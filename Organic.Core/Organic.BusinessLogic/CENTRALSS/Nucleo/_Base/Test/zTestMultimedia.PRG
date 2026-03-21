**********************************************************************
Define Class zTestMultimedia As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestMultimedia Of zTestMultimedia.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Setup
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
	endfunc 

	*---------------------------------
	Function zTestInstanciarClase
		local loClase as multimedia of multimedia.prg
		loClase = _screen.zoo.crearObjeto( "Multimedia" )
		loClase.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_VerificarQueSeReproduscanLosSonidosSegunSeteoDeParametro
		local loClase as multimedia of multimedia.prg
		loClase = _screen.zoo.crearObjeto( "MockMultimedia", "ZtestMultimedia.prg" )
		
		goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos = .t.
		loClase.ReproducirSonido( "Pepe.mp3" )
		this.assertequals( "La respuesta no es correcta 1", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.
		
		loClase.ReproducirSonido( "Pepe.Mid" )
		this.assertequals( "La respuesta no es correcta 2", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		
		
		loClase.ReproducirSonido( "Pepe.wav" )
		this.assertequals( "La respuesta no es correcta 3", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.
		
		loClase.ReproducirAlertar()
		this.assertequals( "La respuesta no es correcta 4", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		

		loClase.ReproducirInformar()
		this.assertequals( "La respuesta no es correcta 5", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		


		loClase.ReproducirExclamacion()
		this.assertequals( "La respuesta no es correcta 6", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		
				
		loClase.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_VerificarQueNoSeReproduscanLosSonidosSegunSeteoDeParametro
		local loClase as multimedia of multimedia.prg
		loClase = _screen.zoo.crearObjeto( "MockMultimedia", "ZtestMultimedia.prg" )
		
		goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos = .f.
		loClase.ReproducirSonido( "Pepe.mp3" )
		this.assertequals( "La respuesta no es correcta 1", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.
		
		loClase.ReproducirSonido( "Pepe.Mid" )
		this.assertequals( "La respuesta no es correcta 2", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		
		
		loClase.ReproducirSonido( "Pepe.wav" )
		this.assertequals( "La respuesta no es correcta 3", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.
		
		loClase.ReproducirAlertar()
		this.assertequals( "La respuesta no es correcta 4", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		

		loClase.ReproducirInformar()
		this.assertequals( "La respuesta no es correcta 5", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		


		loClase.ReproducirExclamacion()
		this.assertequals( "La respuesta no es correcta 6", goParametros.nucleo.SonidosYNotificaciones.ReproducirSonidos, loClase.EmitioSonido )
		loClase.EmitioSonido = .f.		
				
		loClase.release()
	endfunc 			
Enddefine



*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class MockMultimedia as multimedia of multimedia.prg

	EmitioSonido = .f.
	
	*-----------------------------------------------------------------------------------------
	function ReproducirWav( txVal as Variant ) as Void
		this.EmitioSonido = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReproducirMP3( txVal as Variant ) as Void
		this.EmitioSonido = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReproducirMid( txVal as Variant ) as Void
		this.EmitioSonido = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReproducirSonidosDelSistemaOperativo( txVal as Variant ) as Void
		this.EmitioSonido = .t. 
	endfunc 

enddefine
