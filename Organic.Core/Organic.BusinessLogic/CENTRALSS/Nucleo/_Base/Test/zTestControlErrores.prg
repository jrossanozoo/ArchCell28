#include registry.h

**********************************************************************
Define Class zTestControlErrores As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestControlErrores Of zTestControlErrores.prg
	#Endif
	
	*-----------------------------------------------------------------------------------------
	function zTestEsErrorControlado
		local loErrores as Object, loEx as object, lni  as integer, llRetorno as object
		
		loErrores = _screen.zoo.crearobjeto( "ControlErrores" )
		loEx = _screen.zoo.crearobjeto( "zooException" )
		
		for lni = 1 to 100
			loEx.nZooErrorNo = lni
			llRetorno = loErrores.EsErrorControlado( loEx )
			if inlist( loEx.nZooErrorNo, 10, 20 )
				this.asserttrue( "El error debe ser controlado (" + transform( lni ) + ")", llRetorno )
			else
				this.asserttrue( "El error debe ser controlado (" + transform( lni ) + ")", !llRetorno )
			endif
			inkey( 0.25 )
		endfor
		
		loEx.destroy()
		loErrores.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestControlarError
		local loErrores as Object, loEx as object, lcValor as String

		private goMensajes
		_screen.mocks.agregarmock( "mensajes" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "[*COMODIN]" )
		goMensajes = _screen.zoo.crearobjeto( "mensajes" )
		
		loErrores = _screen.zoo.crearobjeto( "ControlErrores" )
		loEx = _screen.zoo.crearobjeto( "zooException" )
		
		loEx.nZooErrorNo = 10
		llRetorno = loErrores.ControlarError( loEx )
		this.asserttrue( "El error debe ser controlado (10)", llRetorno )
		
		loEx.nZooErrorNo = 20
		llRetorno = loErrores.ControlarError( loEx )
		this.asserttrue( "El error debe ser controlado (20)", llRetorno )

		loEx.nZooErrorNo = 0
		llRetorno = loErrores.ControlarError( loEx )
		this.asserttrue( "El error no debe ser controlado", !llRetorno )
		
		loEx.destroy()
		loErrores.release()
	endfunc 
Enddefine