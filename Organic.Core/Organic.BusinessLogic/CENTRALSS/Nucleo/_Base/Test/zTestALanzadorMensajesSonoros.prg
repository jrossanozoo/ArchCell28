**********************************************************************
Define Class zTestALanzadorMensajesSonoros As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestALanzadorMensajesSonoros Of zTestALanzadorMensajesSonoros.prg
	#Endif

	*---------------------------------
	Function Setup

	Endfunc

	*---------------------------------
	Function TearDown

	Endfunc

	*---------------------------------
	Function zTestEnviarSinEsperaDesdeFormulario
		local loForm as Form, lnForm as Integer, loLanzador as object, loError as Exception, loEx as Exception

		loForm = newobject( "FormPrueba" , "zTestALanzadorMensajesSonoros.prg", "", this )
		lnForm = _screen.FormCount
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorMensajesSonoros2", "zTestALanzadorMensajesSonoros.prg" )
		clear typeahead
		
		loLanzador.enviarsinespera( "Prueba desde test" )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en la cantidad de formularios", lnForm + 1, _screen.FormCount )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en el formulario que se abrio", loLanzador.oMensajeSinEspera.cNombreForm, _vfp.Forms[ 1 ].name)
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. No debe mostrar un titulo", 0, _vfp.Forms[ 1 ].titlebar )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en el texto", "Prueba desde test", _vfp.Forms[ 1 ].edtMensaje.text )
		this.asserttrue( "No se mostró el mensaje sin espera desde el screen. El formulario esta invisible", _vfp.Forms[ 1 ].visible )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en la imagen", "INFORMACION.GIF", justfname( upper( _vfp.Forms[ 1 ].Imagen.picture ) ) )
		This.assertequals( "El SET CURSOR no quedo correctamente seteado.", "ON", set( "cursor" ) )
	
		Try
			loLanzador.enviarsinespera( "Prueba desde test con otro texto" )
		catch to loerror
			this.asserttrue("Pincho al mandar el segundo mensaje", .F.)
		EndTry
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en la cantidad de formularios", lnForm + 1, _screen.FormCount )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en el formulario que se abrio", ;
			loLanzador.oMensajeSinEspera.cNombreForm, _vfp.Forms[ 1 ].name)
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. No debe mostrar un titulo", 0, _vfp.Forms[ 1 ].titlebar )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en el texto", ;
			"Prueba desde test con otro texto", _vfp.Forms[ 1 ].edtMensaje.text )
		this.asserttrue( "No se mostró el mensaje sin espera desde el screen por segunda vez. El formulario esta invisible", _vfp.Forms[ 1 ].visible )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en la imagen", "INFORMACION.GIF", ;
			justfname( upper( _vfp.Forms[ 1 ].Imagen.picture ) ) )
		This.assertequals( "El SET CURSOR no quedo correctamente seteado 2.", "ON", set( "cursor" ) )

		loLanzador.enviarsinespera()
		this.assertequals( "No se ocultó el mensaje sin espera desde el screen. Error en la cantidad de formularios", lnForm, _screen.FormCount )
		This.assertequals( "El SET CURSOR no quedo correctamente seteado. 3", "ON", set( "cursor" ) )
		
		loLanzador.release()
		this.assertequals( "No se cerro el formulario sin espera al morir el servicio", lnForm, _screen.FormCount )
		
		loForm.Release()
				
	endfunc

	*---------------------------------
	Function zTestEnviarSinEsperaSinFormulario
		local lnForm as Integer, loLanzador as object, lcTitulo as String
		
		lcTitulo = ""
		lnForm = _screen.FormCount 
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorMensajesSonoros2", "zTestALanzadorMensajesSonoros.prg" )

		loLanzador.enviarsinespera( "Prueba desde test" )
		clear typeahead 
		this.assertequals( "Envio desde screen. El formulario no se mostro", lnForm + 1, _screen.FormCount )

		Try
			loLanzador.enviarsinespera( "Prueba desde test con otro texto" )
		Catch
			this.asserttrue("Pincho al mandar el segundo mensaje", .F.)
		EndTry

		clear typeahead 
		this.assertequals( "Envio desde screen por segunda vez. El formulario no se mostro2", lnForm + 1, _screen.FormCount )

		loLanzador.enviarsinespera()
		this.assertequals( "El formulario no se ocultó. Error en la cantidad de forms", lnForm, _screen.FormCount )
		
		* Pasar un título por parámetro
		loLanzador.EnviarSinEspera("mensaje con título", "tituloxxx")
		this.assertequals( "No se seteó correctamente el título", upper( "tituloxxx" ), upper( _screen.ActiveForm.caption ) )
		clear typeahead 
		loLanzador.enviarsinespera()
		
		* Pasar un título vacío como parámetro
		lcTitulo = loLanzador.ObtenerTitulo()
		this.assertequals( "No se seteó correctamente el título", upper(lcTitulo) , upper( _Screen.Zoo.App.Nombre ) )

		loLanzador.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_EventoSonoroConParametroActivado
		local loLanzador as Object, lcMensaje as String, loForm as Object
		
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorMensajesPrueba", "zTestALanzadorMensajesSonoros.prg" )
		loLanzador.lEsBuildAutomatico = .f.
		loForm = createobject( 'Form' )
		loForm.addproperty( "lEmitirAlarmaEspecial", .f. )
		loLanzador.addproperty( "oForm", loForm )
		
		lcMensaje = 'Prueba de test sobre Advertir con Alerta sonora.'	
		
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "serviciosAplicacion" )
		goServicios.multimedia = _Screen.zoo.crearobjeto( "MockMultimedia", "zTestALanzadorMensajesSonoros.prg" )

		goParametros.Nucleo.SonidosYNotificaciones.ReproducirSonidos = .t.
		with loLanzador
		
			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( 0 )
			this.asserttrue( "El valor esperado no es el correcto. 0", goServicios.multimedia.EmitioAlertar )
			
			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( 1 )
			this.asserttrue( "El valor esperado no es el correcto. 1", goServicios.multimedia.EmitioExclamacion )
			
			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( 2 )
			this.asserttrue( "El valor esperado no es el correcto. 2", goServicios.multimedia.EmitioExclamacion )

			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( 3 )
			this.asserttrue( "El valor esperado no es el correcto. 3", goServicios.multimedia.EmitioInformar )
			
			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( 4 )
			this.asserttrue( "El valor esperado no es el correcto. 4", goServicios.multimedia.EmitioExclamacion )			
			
			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( .f. )
			this.asserttrue( "El valor esperado no es el correcto. 5", goServicios.multimedia.EmitioExclamacion )						
			
			goServicios.multimedia.SetearEnFalseTodosLosFlags()
			.TEST_EnviarEventoSonoro( 65494 )
			this.asserttrue( "El valor esperado no es el correcto. 6", goServicios.multimedia.EmitioExclamacion )			
		endwith
   		loLanzador.release()
   		goServicios.Release()	
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_EnviarConMultimedia
		local loLanzador as Object, lcMensaje as String 
		
		loLanzador = _Screen.zoo.crearobjeto( "Mock_Lanzador_Enviar", "zTestALanzadorMensajesSonoros.prg" )
		loLanzador.lEsBuildAutomatico = .f.
				
		lcMensaje = 'Prueba de test sobre Advertir con Alerta sonora.'	
		
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "serviciosAplicacion" )
		goServicios.multimedia = _Screen.zoo.crearobjeto( "MockMultimedia", "zTestALanzadorMensajesSonoros.prg" )
		goServicios.Registry = goRegistry

		goParametros.Nucleo.SonidosYNotificaciones.ReproducirSonidos = .t.
		with loLanzador
			.Enviar( "casa" )
			this.assertequals( "El valor esperado no es el correcto. 0", .f., .nEnvioEventoSonoro )	
			
			.Enviar( "casa",0, 0 )
			this.assertequals( "El valor esperado no es el correcto. 1", 0, .nEnvioEventoSonoro )			

			.Enviar( "casa",0, 1 )
			this.assertequals( "El valor esperado no es el correcto. 2", 1, .nEnvioEventoSonoro )	

			.Enviar( "casa",0, 2 )
			this.assertequals( "El valor esperado no es el correcto. 3", 2, .nEnvioEventoSonoro )									

			.Enviar( "casa",0, 3 )
			this.assertequals( "El valor esperado no es el correcto. 4", 3, .nEnvioEventoSonoro )
			
			.Enviar( "casa",0, 4 )
			this.assertequals( "El valor esperado no es el correcto. 5", 4, .nEnvioEventoSonoro )			

			.Enviar( "casa",0, .t. )
			this.assertequals( "El valor esperado no es el correcto. 6", .t., .nEnvioEventoSonoro )			
			
			.Enviar( "casa",0, -3 )
			this.assertequals( "El valor esperado no es el correcto. 7", -3, .nEnvioEventoSonoro )			
		endwith
   		loLanzador.release()
   		goServicios.Release()	
	endfunc
			
	*---------------------------------
	Function zTestErrorCuandoseAbrenDosFormSinEsperaaLaVez
		local lnForm as Integer, loLanzador as object, lcTitulo as String
		
		lcTitulo = ""
		lnForm = _screen.FormCount 
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorMensajesSonoros2", "zTestALanzadorMensajesSonoros.prg" )

		loLanzador.enviarsinespera( "Prueba desde test" )
		clear typeahead 

		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en la cantidad de formularios", lnForm + 1, _screen.FormCount )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en el formulario que se abrio", loLanzador.oMensajeSinEspera.cNombreForm, _vfp.Forms[ 1 ].name)
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. No debe mostrar un titulo", 0, _vfp.Forms[ 1 ].titlebar )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en el texto", "Prueba desde test", _vfp.Forms[ 1 ].edtMensaje.text )
		this.asserttrue( "No se mostró el mensaje sin espera desde el screen. El formulario esta invisible", _vfp.Forms[ 1 ].visible )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen. Error en la imagen", "INFORMACION.GIF", justfname( upper( _vfp.Forms[ 1 ].Imagen.picture ) ) )

		Try
			loLanzador.enviarsinespera( "Prueba desde test con otro texto" )
		catch to loError
			this.asserttrue("Pincho al mandar el segundo mensaje" + chr( 13 ) + loError.message, .F.)
		EndTry

		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en la cantidad de formularios", lnForm + 1, _screen.FormCount )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en el formulario que se abrio", ;
			loLanzador.oMensajeSinEspera.cNombreForm, _vfp.Forms[ 1 ].name)
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. No debe mostrar un titulo", 0, _vfp.Forms[ 1 ].titlebar )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en el texto", "Prueba desde test con otro texto", _vfp.Forms[ 1 ].edtMensaje.text )
		this.asserttrue( "No se mostró el mensaje sin espera desde el screen por segunda vez. El formulario esta invisible", _vfp.Forms[ 1 ].visible )
		this.assertequals( "No se mostró el mensaje sin espera desde el screen por segunda vez. Error en la imagen", "INFORMACION.GIF", ;
			justfname( upper( _vfp.Forms[ 1 ].Imagen.picture ) ) )

		loLanzador.release()

	endfunc 
	
	
enddefine

********************************************************************************************
* Esta clase es solo para ponerle un timeout automaticamente asi no se cuelga el autobuild *
* NO CAMBIAR NADA DE LA FUNCIONALIDAD                                                      *
********************************************************************************************
define class LanzadorMensajesSonoros2 as LanzadorMensajesSonoros of LanzadorMensajesSonoros.prg
	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return dodefault( tvMensaje, tnBotones, tnIcono, tnBotonDefault, tcTitulo, iif( empty( tnTiempoEspera ), 0.1, tnTiempoEspera ) )
	endfunc 

enddefine

******************************************************************************************
define class FormPrueba as form

	function init( toTest )
		local lnForm as Integer, loLanzador as object
		lnForm = _screen.FormCount 
		loLanzador = newobject( "LanzadorMensajesSonoros2" )
		
		loLanzador.enviarsinespera( "Prueba desde form", "Titulo" )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en la cantidad de formularios", lnForm + 1, _screen.FormCount )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en el formulario que se abrio", loLanzador.oMensajeSinEspera.cNombreForm, _vfp.Forms[ 1 ].name)
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Debe mostrar un titulo", 1, _vfp.Forms[ 1 ].titlebar )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Debe mostrar un titulo", "Titulo", _vfp.Forms[ 1 ].caption )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en el texto", "Prueba desde form", _vfp.Forms[ 1 ].edtMensaje.text )
		toTest.assertequals( "No se mostró el mensaje sin espera desde el formulario. Error en la imagen", "INFORMACION.GIF", justfname( upper( _vfp.Forms[ 1 ].Imagen.picture ) ) )
		
		toTest.asserttrue( "No se mostró el mensaje sin espera desde el formulario. El formulario esta invisible", _vfp.Forms[ 1 ].visible )

		loLanzador.enviarsinespera()
		toTest.assertequals( "No se ocultó el mensaje sin espera desde el formulario. La cantidad de formularios debe ser igual", lnForm, _screen.FormCount )
		loLanzador.release()
	endfunc

enddefine


******************************************************************************************
define class LanzadorMensajesPrueba as LanzadorMensajesSonoros of LanzadorMensajesSonoros.prg

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
define class MockMultimedia as multimedia of multimedia.prg

	EmitioExclamacion = .f.
	EmitioInformar = .f.
	EmitioAlertar = .f.
	ReprodujoSonidoEspecial = .f.
	*-----------------------------------------------------------------------------------------
	function SetearEnFalseTodosLosFlags() as Void
		with this
			.EmitioExclamacion = .f.
			.EmitioInformar = .f.
			.EmitioAlertar = .f.	
			.ReprodujoSonidoEspecial = .f.
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReproducirAlertar() as Void
		this.EmitioAlertar = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReproducirInformar() as Void
		this.EmitioInformar = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReproducirExclamacion() as Void
		this.EmitioExclamacion = .t. &&Advertir y preguntar.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReproducirSonido( tcArchivo as String ) as Void
		this.ReprodujoSonidoEspecial = .t.
	endfunc 

enddefine


define class Mock_Lanzador_Enviar as LanzadorMensajesSonoros of LanzadorMensajesSonoros.prg

	nEnvioEventoSonoro = -1

	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		return dodefault( tvMensaje, tnBotones, tnIcono, tnBotonDefault, tcTitulo, iif( empty( tnTiempoEspera ), 0.1, tnTiempoEspera ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EnviarEventoSonoro( tnVal as Integer ) as Void
		this.nEnvioEventoSonoro = tnVal
	endfunc 
	

enddefine
