**********************************************************************
define class zTestComunicacionInterprocesos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestComunicacionInterprocesos of zTestComunicacionInterprocesos.prg
	#ENDIF

	*---------------------------------
	function Setup
	endfunc

	*---------------------------------
	function TearDown
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_EnviarRecibirYVerificarDatosDelMensaje
		local loComunicacionInterprocesos as Object, loProveedorInterprocesos as ProveedorInterprocesos of ProveedorInterprocesos.prg, lcCanal as String, lcMensaje as String, i as Integer
		lcCanal = sys( 2015 )
		loComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
		loProveedorInterprocesos = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loComunicacionInterprocesos.RegistrarProveedor( loProveedorInterprocesos, lcCanal )
		this.asserttrue( "Aún no se debió haber recibido ni procesado un mensaje.", empty( loProveedorInterprocesos.cCanal ) and  empty( loProveedorInterprocesos.cCanalParaRespuesta ) and empty( loProveedorInterprocesos.cContenido ) )

		lcMensaje = ""
		for i = 1 to 100000
			lcMensaje = lcMensaje + sys( 2015 )
		endfor

		loProveedorInterprocesos.cCanalParaRespuesta = sys( 2015 )
		loComunicacionInterprocesos.EnviarMensaje( lcMensaje, lcCanal )
		EsperarRespuesta( 5, loProveedorInterprocesos )

		this.assertequals( "El canal no es el esperado.", lcCanal, loProveedorInterprocesos.cCanal )
		this.assertequals( "El canal para respuesta no es el esperado.", "----------", loProveedorInterprocesos.cCanalParaRespuesta )
		this.assertequals( "El contenido no es el esperado.", lcMensaje, loProveedorInterprocesos.cContenido )

		loComunicacionInterprocesos.Release()
		loProveedorInterprocesos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_RegistrarYDesRegistrarUnProveedor
		local loComunicacionInterprocesos as Object, loProveedorInterprocesos as ProveedorInterprocesos of ProveedorInterprocesos.prg, lcCanal as String, lcMensaje as String
		lcCanal = sys( 2015 )
		loComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
		loProveedorInterprocesos = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loComunicacionInterprocesos.RegistrarProveedor( loProveedorInterprocesos, lcCanal )
		lcMensaje = "Hola mundo."
		loComunicacionInterprocesos.EnviarMensaje( lcMensaje, lcCanal )
		EsperarRespuesta( 5, loProveedorInterprocesos )
		this.asserttrue( "Debió haber recibido y procesado el mensaje.", !empty( loProveedorInterprocesos.cCanal ) and  !empty( loProveedorInterprocesos.cCanalParaRespuesta ) and !empty( loProveedorInterprocesos.cContenido ) )

		loProveedorInterprocesos.cCanal = ""
		loProveedorInterprocesos.cCanalParaRespuesta = ""
		loProveedorInterprocesos.cContenido = ""
		loComunicacionInterprocesos.DesRegistrarProveedor( loProveedorInterprocesos, lcCanal )
		loComunicacionInterprocesos.EnviarMensaje( lcMensaje, lcCanal )
		EsperarRespuesta( 1, loProveedorInterprocesos )
		this.asserttrue( "No debió haber recibido ni procesado el mensaje.", empty( loProveedorInterprocesos.cCanal ) and  empty( loProveedorInterprocesos.cCanalParaRespuesta ) and empty( loProveedorInterprocesos.cContenido ) )

		loComunicacionInterprocesos.Release()
		loProveedorInterprocesos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_RegistrarYDesRegistrarTodosLosProveedores
		local loComunicacionInterprocesos as Object, loProveedorInterprocesos as ProveedorInterprocesos of ProveedorInterprocesos.prg, lcCanal as String, ;
			loProveedorInterprocesos2 as ProveedorInterprocesos of ProveedorInterprocesos.prg, lcMensaje as String
		lcCanal = sys( 2015 )
		loComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
		loProveedorInterprocesos = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loProveedorInterprocesos2 = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loComunicacionInterprocesos.RegistrarProveedor( loProveedorInterprocesos, lcCanal )
		loComunicacionInterprocesos.RegistrarProveedor( loProveedorInterprocesos2, lcCanal )
		lcMensaje = "Hola mundo."
		loComunicacionInterprocesos.EnviarMensaje( lcMensaje, lcCanal )
		EsperarRespuesta( 5, loProveedorInterprocesos )
		EsperarRespuesta( 5, loProveedorInterprocesos2 )
		this.asserttrue( "Proveedor1 debió haber recibido y procesado el mensaje.", !empty( loProveedorInterprocesos.cCanal ) and  !empty( loProveedorInterprocesos.cCanalParaRespuesta ) and !empty( loProveedorInterprocesos.cContenido ) )
		this.asserttrue( "Proveedor2 Debió haber recibido y procesado el mensaje.", !empty( loProveedorInterprocesos2.cCanal ) and  !empty( loProveedorInterprocesos2.cCanalParaRespuesta ) and !empty( loProveedorInterprocesos2.cContenido ) )

		loProveedorInterprocesos.cCanal = ""
		loProveedorInterprocesos.cCanalParaRespuesta = ""
		loProveedorInterprocesos.cContenido = ""

		loProveedorInterprocesos2.cCanal = ""
		loProveedorInterprocesos2.cCanalParaRespuesta = ""
		loProveedorInterprocesos2.cContenido = ""

		loComunicacionInterprocesos.DesRegistrarTodosLosProveedores()

		loComunicacionInterprocesos.EnviarMensaje( lcMensaje, lcCanal )
		EsperarRespuesta( 1, loProveedorInterprocesos )
		EsperarRespuesta( 1, loProveedorInterprocesos2 )
		this.asserttrue( "Proveedor1 no debió haber recibido ni procesado el mensaje.", empty( loProveedorInterprocesos.cCanal ) and  empty( loProveedorInterprocesos.cCanalParaRespuesta ) and empty( loProveedorInterprocesos.cContenido ) )
		this.asserttrue( "Proveedor2 no debió haber recibido ni procesado el mensaje.", empty( loProveedorInterprocesos2.cCanal ) and  empty( loProveedorInterprocesos2.cCanalParaRespuesta ) and empty( loProveedorInterprocesos2.cContenido ) )

		loComunicacionInterprocesos.Release()
		loProveedorInterprocesos.Release()
		loProveedorInterprocesos2.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_EnviarMensajeYEsperarRespuestaSincronica
		local loComunicacionInterprocesos as Object, loProveedorInterprocesos as ProveedorInterprocesos of ProveedorInterprocesos.prg, lcCanal as String
		lcCanal = sys( 2015 )
		loComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
		loProveedorInterprocesos = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loComunicacionInterprocesos.RegistrarProveedor( loProveedorInterprocesos, lcCanal )
		this.assertequals( "La respuesta no es la esperada.", "1586", loComunicacionInterprocesos.EnviarMensajeYEsperarRespuestaEnModoSincronico( "1585", lcCanal, 2 ) )

		loComunicacionInterprocesos.Release()
		loProveedorInterprocesos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_EnviarMensajeYEsperarRespuestaAsincronica
		local loComunicacionInterprocesos as Object, loProveedorInterprocesos as ProveedorInterprocesos of ProveedorInterprocesos.prg, ;
			loClienteInterprocesos as ProveedorInterprocesos of ProveedorInterprocesos.prg, lcCanal as String
		lcCanal = sys( 2015 )
		loComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
		loProveedorInterprocesos = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loComunicacionInterprocesos.RegistrarProveedor( loProveedorInterprocesos, lcCanal )
		
		loClienteInterprocesos = _screen.Zoo.CrearObjeto( "ProveedorInterprocesosTest", "zTestComunicacionInterprocesos.prg" )
		loComunicacionInterprocesos.EnviarMensajeYEsperarRespuestaEnModoAsincronico( "1598", lcCanal, loClienteInterprocesos )
		EsperarRespuesta( 5, loClienteInterprocesos )
		this.assertequals( "El contenido no es el esperado.", "1599", loClienteInterprocesos.cContenido )

		loComunicacionInterprocesos.Release()
		loProveedorInterprocesos.Release()
		loClienteInterprocesos.Release()
	endfunc

enddefine

define class ProveedorInterprocesosTest as ProveedorInterprocesos of ProveedorInterprocesos.prg

	cCanal = ""
	cCanalParaRespuesta = ""
	cContenido = ""

	*-----------------------------------------------------------------------------------------
	protected function ProcesarMensaje( toMensaje as String ) as Void
		local loComunicacionInterprocesos as Object
		this.cCanal = toMensaje.cCanal
		this.cCanalParaRespuesta = toMensaje.cCanalParaRespuesta
		this.cContenido = toMensaje.cContenido

		if !empty( toMensaje.cCanalParaRespuesta )
			loComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
			loComunicacionInterprocesos.EnviarMensaje( transform( val( toMensaje.cContenido ) + 1 ), toMensaje.cCanalParaRespuesta )
			loComunicacionInterprocesos.Release()
		endif
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
function EsperarRespuesta( tnSegundosDeEspera as Integer, toClienteInterprocesos as Object ) as Void
local lnSeconds as Integer
lnSeconds = seconds()
do while empty( toClienteInterprocesos.cContenido ) and seconds() < lnSeconds + tnSegundosDeEspera
	=inkey( 1, "H" )
enddo
endfunc