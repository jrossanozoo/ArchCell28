**********************************************************************
Define Class zTestMensajes as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestMensajes of zTestMensajes.prg
	#ENDIF
	
	lBuildAutomatico = .f.
	
	*-----------------------------------		
	Function Setup
		this.lBuildAutomatico = _screen.zoo.EsBuildAutomatico
		_screen.zoo.EsBuildAutomatico = .f.
		goParametros.Nucleo.SonidosYNotificaciones.ReproducirSonidos = .f.
	EndFunc
	
	*-----------------------------------	
	Function TearDown
		_screen.zoo.EsBuildAutomatico = this.lBuildAutomatico
	endfunc
	
	*-----------------------------------
	function zTestEnviarExcepcion
		local loException as zooException as zooException.prg, lnRetorno as Integer

		loMensajes = newobject( "Mensajes2" )
		loException = _screen.zoo.crearobjeto( "zooException" )

		loException.LineContents = "Contenido de la linea de Prueba"
		loException.Lineno = 222
		loException.Message = "Mensaje de Prueba"
		loException.Procedure = "Metodo de prueba"

		lnRetorno = loMensajes.Enviar( loException )
		this.asserttrue( "No se mostro el mensaje de error", lnRetorno = 1)
		
		loException = null
	endfunc
	
	*---------------------------------
	Function zTestObtenerTitulo
		local loMensajes as mensajes of mensajes.prg

		_Screen.mocks.AgregarMock( "LanzadorMensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'LANZADORMENSAJES', 'Obtenertitulo', "Titulo del mensaje" )

		loMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
		
		this.assertequals( "El titulo no es el esperado", "Titulo del mensaje", loMensajes.ObtenerTitulo() )

		loMensajes.release()
				
		_screen.mocks.verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestEnviarSinEsperaDesdeFormulario
		local loMensajes as mensajes of mensajes.prg
	
		llUsaCapaDePresentacion = _screen.lUsaCapaDePresentacion
		_screen.lUsaCapaDePresentacion = .t.	

		_Screen.mocks.AgregarMock( "LanzadorMensajesSonoros" )
		_screen.mocks.AgregarSeteoMetodo( 'LANZADORMENSAJESSONOROS', 'Enviarsinespera', .T., "[Prueba desde test],[titulo del mensaje],[texto del boton],[Informacion.gif],.F." )
		_screen.mocks.AgregarSeteoMetodo( 'LANZADORMENSAJESSONOROS', 'Enviarsinespera', .T., ".F.,.F.,.F.,[Informacion.gif],.F." )


		loMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
		
		loMensajes.EnviarSinEspera( "Prueba desde test", "titulo del mensaje", "texto del boton" )

		loMensajes.enviarsinespera()
		
		loMensajes.release()
				
		_screen.mocks.verificarejecuciondemocks()
		
		_screen.lUsaCapaDePresentacion = llUsaCapaDePresentacion
	endfunc

	*---------------------------------
	Function zTestEnviarSinEsperaProcesandoDesdeFormulario
		local loMensajes as mensajes of mensajes.prg
		
		llUsaCapaDePresentacion = _screen.lUsaCapaDePresentacion
		_screen.lUsaCapaDePresentacion = .t.

		_Screen.mocks.AgregarMock( "LanzadorMensajesSonoros" )
		_screen.mocks.AgregarSeteoMetodo( 'LANZADORMENSAJESSONOROS', 'Enviarsinespera', .T., "[Prueba desde test],[titulo del mensaje],[texto del boton],[Procesando.gif],.F." )
		_screen.mocks.AgregarSeteoMetodo( 'LANZADORMENSAJESSONOROS', 'Enviarsinespera', .T., ".F.,.F.,.F.,[Informacion.gif],.F." )

		loMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
		
		loMensajes.EnviarSinEsperaProcesando( "Prueba desde test", "titulo del mensaje", "texto del boton" )

		loMensajes.enviarsinespera()
		
		loMensajes.release()
				
		_screen.mocks.verificarejecuciondemocks()
		
		_screen.lUsaCapaDePresentacion = llUsaCapaDePresentacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestEnviarEstiloWindows
		local loMensajes as object 

		loMensajes = newobject( "Mensajes2" )	

		lnRetorno = loMensajes.enviarEstiloWindows("Estilo seteado en 2")		
        this.assertequals( "El estilo quedo mal seteado en 1", 2, goParametros.Dibujante.Estilo )
        this.asserttrue( "No se recibió valor de retorno", vartype( lnRetorno ) = "N" )

		loMensajes = newobject( "Mensajes2" )		
		lnRetorno = loMensajes.enviarEstiloWindows("Estilo seteado en 2", 4)	
        this.assertequals( "El estilo quedo mal seteado en 1", 2, goParametros.Dibujante.Estilo )
        this.asserttrue( "No se recibió valor de retorno", vartype( lnRetorno ) = "N" )

		loMensajes = newobject( "Mensajes2" )		
		lnRetorno = loMensajes.enviarEstiloWindows("Estilo seteado en 2", 4, 1)		
        this.assertequals( "El estilo quedo mal seteado en 1", 2, goParametros.Dibujante.Estilo )
        this.asserttrue( "No se recibió valor de retorno", vartype( lnRetorno ) = "N" )
        
		loMensajes = newobject( "Mensajes2" )
		lnRetorno = loMensajes.enviarEstiloWindows("Estilo seteado en 2", 4, 1, 1)		
        this.assertequals( "El estilo quedo mal seteado en 1", 2, goParametros.Dibujante.Estilo )
        this.asserttrue( "No se recibió valor de retorno", vartype( lnRetorno ) = "N" )

		loMensajes = newobject( "Mensajes2" )		
		lnRetorno = loMensajes.enviarEstiloWindows("Estilo seteado en 2", 4, 1, 1, "Titulo") 
        this.assertequals( "El estilo quedo mal seteado en 1", 2, goParametros.Dibujante.Estilo )
        this.asserttrue( "No se recibió valor de retorno", vartype( lnRetorno ) = "N" )       

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestMensajeCortado
		local loinfo as zooinformacion of zooInformacion.prg , loFormInformacion as Object 

		loInfo 	= _screen.zoo.crearobjeto( "zooInformacion" )
		loFormInformacion = _screen.zoo.crearobjeto( "formInformacion","forminformacion.prg", 1 )
		
		lcTexto = "¿Esta es la prueba 1 de un mensaje largo en estilo clasico pero ahora con una fuente mas grande" + chr( 13 )
		lcTexto = lcTexto + "Problema 2" + chr( 13 )
		lcTexto = lcTexto + "Esta es la prueba 3 de un mensaje largo en estilo clasico pero ahora con una fuente mas grande" + chr( 13 )
		lcTexto = lcTexto + "Problema 4"
		loInfo.Agregarinformacion( lcTexto )		
		loFormInformacion.FormatearMensaje( loInfo)
		
		This.assertequals( "El Top del editbox pral debe ser 25", 25,loFormInformacion.edtCabecera.top )				
		
		This.assertequals( "El height del editbox pral debe ser 59", 59,loFormInformacion.edtCabecera.height )						

		loFormInformacion .release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestAlertar
		local loMensajes as Object, lcMensaje  as String  	

		loMensajes = newobject( "MensajesPrueba" )	
		lcMensaje = 'Prueba de test sobre alertar.'	
		
		loMensajes.Alertar( lcMensaje )
		this.assertequals( "No se seteó correctamente el mensaje 1", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 1", .f., loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 1", 0, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 1", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 1", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 1", .f., loMensajes.nTiempoEspera )
			
		loMensajes.Alertar( lcMensaje ,0 )
		this.assertequals( "No se seteó correctamente el mensaje 2", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 2", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 2", 0, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 2", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 2", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 2", .f., loMensajes.nTiempoEspera )
					
		loMensajes.Alertar( lcMensaje ,0,0 )		
		this.assertequals( "No se seteó correctamente el mensaje 3", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 3", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 3", 0, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 3", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 3", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 3", .f., loMensajes.nTiempoEspera )
		
		loMensajes.Alertar( lcMensaje ,0,0,"Titulo 4" )	
		this.assertequals( "No se seteó correctamente el mensaje 4", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 4", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 4", 0, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 4", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 4", "Titulo 4", loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 4", .f., loMensajes.nTiempoEspera )	
   		
   		loMensajes.Alertar( lcMensaje ,0,0,"Titulo 5",3 )	
		this.assertequals( "No se seteó correctamente el mensaje 5", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 5", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 5", 0, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 5", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 5", 'Titulo 5', loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 5", 3, loMensajes.nTiempoEspera )	
   		
   		loMensajes.release()
   		loMensajes = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAdvertir
		local loMensajes as Object, lcMensaje  as String  
	
		loMensajes = newobject( "MensajesPrueba" )	
		lcMensaje = 'Prueba de test sobre Advertir.'	
		
		loMensajes.Advertir( lcMensaje )
		this.assertequals( "No se seteó correctamente el mensaje 1", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 1", .f., loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 1", 2, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 1", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 1", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 1", .f., loMensajes.nTiempoEspera )
			
		loMensajes.Advertir( lcMensaje,0 )
		this.assertequals( "No se seteó correctamente el mensaje 2", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 2", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 2", 2, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 2", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 2", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 2", .f., loMensajes.nTiempoEspera )
					
		loMensajes.Advertir( lcMensaje,0,0 )		
		this.assertequals( "No se seteó correctamente el mensaje 3", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 3", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 3", 2, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 3", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 3", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 3", .f., loMensajes.nTiempoEspera )
		
		loMensajes.Advertir( lcMensaje,0,0,"Titulo 4" )	
		this.assertequals( "No se seteó correctamente el mensaje 4", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 4", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 4", 2, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 4", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 4", "Titulo 4", loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 4", .f., loMensajes.nTiempoEspera )	
   		
   		loMensajes.Advertir( lcMensaje,0,0,"Titulo 5",3 )	
		this.assertequals( "No se seteó correctamente el mensaje 5", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 5", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 5", 2, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 5", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 5", 'Titulo 5', loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 5", 3, loMensajes.nTiempoEspera )	
   		
   		loMensajes.release()
   		loMensajes = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestPreguntar
		local loMensajes as Object, lcMensaje  as String  
	
		loMensajes = newobject( "MensajesPrueba" )	
		lcMensaje = 'Prueba de test sobre Advertir.'	
		
		loMensajes.Preguntar( lcMensaje )
		this.assertequals( "No se seteó correctamente el mensaje 1", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 1", .f., loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 1", 1, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 1", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 1", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 1", .f., loMensajes.nTiempoEspera )
			
		loMensajes.Preguntar( lcMensaje,0 )
		this.assertequals( "No se seteó correctamente el mensaje 2", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 2", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 2", 1, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 2", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 2", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 2", .f., loMensajes.nTiempoEspera )
					
		loMensajes.Preguntar( lcMensaje,0,0 )		
		this.assertequals( "No se seteó correctamente el mensaje 3", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 3", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 3", 1, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 3", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 3", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 3", .f., loMensajes.nTiempoEspera )
		
		loMensajes.Preguntar( lcMensaje,0,0,"Titulo 4" )	
		this.assertequals( "No se seteó correctamente el mensaje 4", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 4", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 4", 1, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 4", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 4", "Titulo 4", loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 4", .f., loMensajes.nTiempoEspera )	
   		
   		loMensajes.Preguntar( lcMensaje,0,0,"Titulo 5",3 )	
		this.assertequals( "No se seteó correctamente el mensaje 5", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 5", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 5", 1, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 5", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 5", 'Titulo 5', loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 5", 3, loMensajes.nTiempoEspera )	
   		
   		loMensajes.release()
   		loMensajes = null

	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestInformar
		local loMensajes as Object, lcMensaje  as String  
	
		loMensajes = newobject( "MensajesPrueba" )	
		lcMensaje = 'Prueba de test sobre Advertir.'	
		
		loMensajes.Informar( lcMensaje )
		this.assertequals( "No se seteó correctamente el mensaje 1", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 1", .f., loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 1", 3, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 1", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 1", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 1", .f., loMensajes.nTiempoEspera )
			
		loMensajes.Informar( lcMensaje,0 )
		this.assertequals( "No se seteó correctamente el mensaje 2", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 2", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 2", 3, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 2", .f., loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 2", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 2", .f., loMensajes.nTiempoEspera )
					
		loMensajes.Informar( lcMensaje,0,0 )		
		this.assertequals( "No se seteó correctamente el mensaje 3", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 3", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 3", 3, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 3", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 3", .f., loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 3", .f., loMensajes.nTiempoEspera )
		
		loMensajes.Informar( lcMensaje,0,0,"Titulo 4" )	
		this.assertequals( "No se seteó correctamente el mensaje 4", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 4", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 4", 3, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 4", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 4", "Titulo 4", loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 4", .f., loMensajes.nTiempoEspera )	
   		
   		loMensajes.Informar( lcMensaje,0,0,"Titulo 5",3 )	
		this.assertequals( "No se seteó correctamente el mensaje 5", lcMensaje, loMensajes.vMensaje )
   		this.assertequals( "No se setearon correctamente los botones 5", 0, loMensajes.nBotones )
   		this.assertequals( "No se seteó correctamente el icono 5", 3, loMensajes.nIcono )
   		this.assertequals( "No se seteó correctamente el boton default 5", 0, loMensajes.nBotonDefault )
   		this.assertequals( "No se seteó correctamente el titulo 5", 'Titulo 5', loMensajes.cTitulo )
   		this.assertequals( "No se seteó correctamente el tiempo de espera 5", 3, loMensajes.nTiempoEspera )	
   		
   		loMensajes.release()
   		loMensajes = null

	endfunc 

	*-----------------------------------
	function zTestEnviarExcepcionConInformacion
		local loException as zooException as zooException.prg, lnRetorno as Integer, ;
			loMensajes as Object


		llUsaCapaDePresentacion = _screen.lUsaCapaDePresentacion
		_screen.lUsaCapaDePresentacion = .t.

		loMensajes = newobject( "mockMensajes" )	
		
		loException = _screen.zoo.crearobjeto( "zooException" )

		loException.LineContents = "Contenido de la linea de Prueba"
		loException.Lineno = 222
		loException.Message = "Mensaje de Prueba"
		loException.Procedure = "Metodo de prueba"
		loException.AgregarInformacion( "Texto de la informacion" )
		
		loMensajes.oTest = this

		this.asserttrue( "La colecion de informacion esta vacia.", 1 = loException.oInformacion.Count )
		lnRetorno = loMensajes.Enviar( loException )
		
		this.assertequals( "Debe limpiarse la coleccion de informacion despues de mostrar mensaje.", 0 , loException.oInformacion.Count )		
		loException = null
		loMensajes.release()
		_screen.lUsaCapaDePresentacion = llUsaCapaDePresentacion
	endfunc
	*-----------------------------------
	function zTestEnviarInformacion
		local loInformacion as zooinformacion of zooInformacion.prg, loMensajes as Object
		
		llUsaCapaDePresentacion = _screen.lUsaCapaDePresentacion
		_screen.lUsaCapaDePresentacion = .t.
		
		loMensajes = newobject( "mockMensajes" )	
		
		loInformacion = _Screen.zoo.Crearobjeto( "ZooInformacion" )
		loInformacion.AgregarInformacion( "Texto de la informacion" )
		
		loMensajes.oTest = this

		lnRetorno = loMensajes.Enviar( loInformacion )
		this.assertequals( "No debe limpiarse la coleccion de informacion despues de mostrar mensaje.", 0 , loInformacion.Count )
		loInformacion.release()
		loMensajes.release()
		_screen.lUsaCapaDePresentacion = llUsaCapaDePresentacion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestRetornoMensaje
		local loMensajes as Mensajes of mensajes.prg, lnRetorno as Integer, lnTimer as Integer;
		lnBotonAceptar as Integer, lnBotonCancelar as Integer, lnBotonAnular as Integer, lnBotonReintentar as Integer, ;
		lnBotonIgnorar as Integer, lnBotonSi as Integer, lnBotonNo as Integer
		
		loMensajes = newobject( "Mensajes2" )
		lnBotonAceptar = 1
		lnBotonCancelar = 2 
		lnBotonAnular = 3
		lnBotonReintentar = 4
		lnBotonIgnorar = 5
		lnBotonSi = 6
		lnBotonNo = 7 
		lnTimer = 0.2
				
		* Boton aceptar
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonAceptar ))
		this.assertequals( "Deberia devolver " + transform( lnBotonAceptar ), lnBotonAceptar, lnRetorno )

		* Boton aceptar y cancelar		
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonAceptar ), 1)
		this.assertequals( "Deberia devolver " + transform( lnBotonAceptar ), lnBotonAceptar, lnRetorno )		
		
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonCancelar ), 1,, 1 )
		this.assertequals( "Deberia devolver " + transform( lnBotonCancelar ), lnBotonCancelar , lnRetorno )				

		* Boton anular, reintentar, ignorar
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonAnular ), 2 )
		this.assertequals( "Deberia devolver " + transform( lnBotonAnular ), lnBotonAnular , lnRetorno )		
		
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonReintentar ), 2,, 1 )
		this.assertequals( "Deberia devolver " + transform( lnBotonReintentar ), lnBotonReintentar , lnRetorno )				

		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonIgnorar ), 2,, 2 )
		this.assertequals( "Deberia devolver " + transform( lnBotonIgnorar ), lnBotonIgnorar , lnRetorno )						
		
		* Boton si, no, cancelar
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonSi ), 3 )
		this.assertequals( "Deberia devolver " + transform( lnBotonSi ), lnBotonSi , lnRetorno )

		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonNo ), 3,,1 )
		this.assertequals( "Deberia devolver " + transform( lnBotonNo ), lnBotonNo , lnRetorno )
		
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonCancelar ), 3,, 2 )
		this.assertequals( "Deberia devolver " + transform( lnBotonCancelar ), lnBotonCancelar , lnRetorno )				
					
		* Boton si, no
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonSi ), 4 )
		this.assertequals( "Deberia devolver " + transform( lnBotonSi ), lnBotonSi , lnRetorno )

		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonNo ), 4,,1 )
		this.assertequals( "Deberia devolver " + transform( lnBotonNo ), lnBotonNo , lnRetorno )

		* Boton reintentar, cancelar
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonReintentar ), 5 )
		this.assertequals( "Deberia devolver " + transform( lnBotonReintentar ), lnBotonReintentar , lnRetorno )
		
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonCancelar ), 5,, 1 )
		this.assertequals( "Deberia devolver " + transform( lnBotonCancelar ), lnBotonCancelar , lnRetorno )	
		
		* Boton cancelar
		lnRetorno = loMensajes.Enviar( "Retorno " + transform( lnBotonCancelar ), 10 )
		this.assertequals( "Deberia devolver " + transform( lnBotonCancelar ), lnBotonCancelar , lnRetorno )					

		loMensajes.release()
	

	endfunc 
enddefine

********************************************************************************************
* Esta clase es solo para ponerle un timeout automaticamente asi no se cuelga el autobuild *
* NO CAMBIAR NADA DE LA FUNCIONALIDAD                                                      *
********************************************************************************************
define class Mensajes2 as Mensajes of Mensajes.prg
	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return dodefault( tvMensaje, tnBotones, tnIcono, tnBotonDefault, tcTitulo, iif( empty( tnTiempoEspera ), 0.2, tnTiempoEspera ) )
	endfunc 

enddefine

******************************************************************************************
define class FormPrueba as form

	function init( toTest )
		local lnForm as Integer, loMensajes as object
		lnForm = _screen.FormCount 
		loMensajes = newobject( "Mensajes2" )
		
		loMensajes.enviarsinespera( "Prueba desde form", "Titulo" )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en la cantidad de formularios", lnForm + 1, _screen.FormCount )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en el formulario que se abrio", loMensajes.oMensajeSinEspera.cNombreForm, _vfp.Forms[ 1 ].name)
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Debe mostrar un titulo", 1, _vfp.Forms[ 1 ].titlebar )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Debe mostrar un titulo", "Titulo", _vfp.Forms[ 1 ].caption )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en el texto", "Prueba desde form", _vfp.Forms[ 1 ].edtMensaje.text )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en la imagen", "INFORMACION.GIF", justfname( upper( _vfp.Forms[ 1 ].Imagen.picture ) ) )
		
		toTest.asserttrue( "No se mostró el mensaje sin espera desde el formulario. El formulario esta invisible", _vfp.Forms[ 1 ].visible )

		loMensajes.enviarsinespera()
		toTest.assertequals( "No se ocultó el mensaje sin espera desde el formulario. La cantidad de formularios debe ser igual", lnForm, _screen.FormCount )
		loMensajes.release()
	endfunc

enddefine

******************************************************************************************
define class MensajesPrueba as mensajes2

	vMensaje = ''
	nBotones = 0
	nIcono = 0
	nBotonDefault = 0
	cTitulo = ''
	nTiempoEspera = 0
	
	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		with this
			.vMensaje = tvMensaje 
			.nBotones = tnBotones 
			.nIcono = tnIcono 
			.nBotonDefault = tnBotonDefault 
			.cTitulo = tcTitulo 
			.nTiempoEspera = tnTiempoEspera 
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function Test_EnviarEventoSonoro( tnTipo as Integer ) as Void
		this.EnviarEventoSonoro( tnTipo )
	endfunc 

enddefine
******************************************************************************************
define class mockMensajes as mensajes2
	oTest = null

	*-----------------------------------------------------------------------------------------
	function CrearFormularioInformacion( tnBotones as Integer, tnBotonDefault as Integer, tnIcono as Integer, tcTitulo as String, tnTiempoEspera as Integer ) as Void
		this.oForm = newobject( "mockFormInformacion" )
		this.oForm.oTest = this.oTest
	endfunc 
enddefine

******************************************************************************************
define class mockFormInformacion as FormInformacion of FormInformacion.prg
	oTest = null
	*-----------------------------------------------------------------------------------------
	function FormatearMensaje( tvMensaje ) as VOID 
		with this.oTest
			.assertEquals( "No llego un zooInformacion", "ZOOINFORMACION", upper( tvMensaje.class ) )
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function show( tnParametro as Integer ) as Void
		nodefaul
	endfunc 
	

enddefine
