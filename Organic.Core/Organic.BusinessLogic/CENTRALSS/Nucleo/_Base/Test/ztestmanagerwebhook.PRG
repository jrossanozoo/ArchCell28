**********************************************************************
DEFINE CLASS ztestmanagerwebhook as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS ztestmanagerwebhook OF ztestmanagerwebhook.PRG
	#ENDIF
	
	********************************************************************
	FUNCTION Setup

	ENDFUNC
	
	********************************************************************
	FUNCTION TearDown

	ENDFUNC

	*-----------------------------------------------------------------------------------------
	function zTestAgregarMensajeALaCola
		local toRegistro as Object
		
		GoServicios.webhook = createobject("ManagerWH_FAKE")

		toRegistro = newobject("custom")
		toRegistro.name = "PRUEBA"
		
		goServicios.webhook.AgregarMensajeALaCola( "INGRESAR", toRegistro , "ARTICULO")
		
		this.assertequals("No se envió los parámetros correctos al metodo webhook.AgregarMensajeALaCola (1)","INGRESAR",goServicios.webhook.cEvento )
		this.assertequals("No se envió los parámetros correctos al metodo webhook.AgregarMensajeALaCola (2)","ARTICULO",goServicios.webhook.cEntidad )
		this.assertequals("No se envió los parámetros correctos al metodo webhook.AgregarMensajeALaCola (3)","PRUEBA",goServicios.webhook.oRegistro.Name )

		toRegistro = null
		GoServicios.webhook = null
		
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define class ManagerWH_FAKE as managerwebhook of managerwebhook.prg
	
	cEvento = ""
	oRegistro = null
	cEntidad = ""
	
	*-----------------------------------------------------------------------------------------
	function oNetWebHook_Access() as Object
		this.oNetWebHook = this.ObtenerComponenteWH()
		return this.oNetWebHook
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponenteWH() as Object
		return createobject("FactoryWH_FAKE")
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define class FactoryWH_FAKE as custom

	*-----------------------------------------------------------------------------------------
	function AgregarMensajeALaCola( tcEvento as string, toRegistro as object, tcEntidad as string ) as Void
		with goServicios.webhook
			.cEvento = tcEvento
			.oRegistro = toRegistro 
			.cEntidad = tcEntidad 
		endwith	
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarMensajeComplejo( tcEntidad as String, tcCodigo ) as void	

		goServicios.webhook.lPasoPorElEnviarMensajeComplejo = .T.

	endfunc

enddefine
