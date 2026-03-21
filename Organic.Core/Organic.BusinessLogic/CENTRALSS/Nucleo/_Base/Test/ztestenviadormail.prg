**********************************************************************
DEFINE CLASS ZtestEnviadorMail as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS ZtestEnviadorMail OF ZtestEnviadorMail.PRG
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function zTestAgregarMensajedeCierre()
		local lcMensaje as String, loEnviador as Object, lcEnter as string

		lcEnter = chr(13) + chr(10)
		
		loEnviador = newobject( "EnviadorDeMail_fake" )
		
		lcMensaje = "Este es un mensaje de error."

		lcMensaje = loEnviador.AgregarMensajeDeCierre( lcMensaje )
		
		this.assertequals( "El mensaje de error deberia ser: 'Este es un mensaje de error. Para mayor información revisar el archivo log.err'",;
			 "Este es un mensaje de error."+lcEnter+"Para mayor información revisar el archivo log.err", lcMensaje )
		
	endfunc 
	*-----------------------------------------------------------------------------------------

enddefine

*-----------------------------------------------------------------------------------------

define class EnviadorDeMail_fake as EnviadordeMail of EnviadordeMail.prg

	function oColaboradorNotificacionesPorMail_Access() as variant

		return null

	endfunc

enddefine