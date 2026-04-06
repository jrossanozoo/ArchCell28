**********************************************************************
Define Class zTestValorSugeridoZL as FxuTestCase OF FxuTestCase.prg


	#If .F.
		Local This As ztestvalorsugeridoZL Of ztestvalorsugeridoZL.prg
	#Endif

	oValorSugerido = null
	Serie = ""

	*-----------------------------------------------------------------------------------------
	Function Setup
		this.oValorsugerido = _screen.zoo.crearobjeto("ValorSugeridoZL")
		*!*	 DRAGON 2028
		goServicios.Datos.EjecutarSentencias('delete from Series','Series')
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ztestObtenerMinimo

		local lcRetorno as string, loSerie as Object
		
		private gomensajes as Object

		_screen.mocks.agregarmock( "Mensajes" )
		_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )

		goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )

		This.oValorsugerido.nTamanioCampo = 6
		
		this.oValorsugerido.SetearPropiedades( "Series", "NroSerie", "" )
		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "300000" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 1 ", "300000", lcRetorno )

		=CrearSerie( this, "999999" )
		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "300000" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 2 ", "300000", lcRetorno )

		=CrearSerie( this, "300000" )
		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "300000" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 3 ", "300001", lcRetorno )

		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "100" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 4 ", "", lcRetorno )

		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "010000" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 5 ", "", lcRetorno )

		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "1000D0" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 6 ", "", lcRetorno )

		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "110000" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 7 ", "", lcRetorno )

		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "309999" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 8 ", "309999", lcRetorno )

		=CrearSerie( this, "309999" )
		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "309999" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 9 ", "400000", lcRetorno )

		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "909999" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 10 ", "909999", lcRetorno )

		=CrearSerie( this, "909999" )
		lcRetorno =	this.oValorsugerido.ObtenerMinimo( "909999" )
		This.AssertEquals( "No se obtuvo valor sugerido correcto 11 ", "", lcRetorno )
	
		goMensajes = _Screen.zoo.app.oMensajes
	endfunc


	*-----------------------------------------------------------------------------------------
	Function TearDown
		this.oValorSugerido.release()
	Endfunc
EndDefine


*-----------------------------------------------------------------------------------------
function CrearSerie( toFxuTestCase as Object, tcValor as String )
	goServicios.Datos.EjecutarSentencias( "insert into Series (NroSerie) values ('" + tcValor + "')", 'Series' )
endfunc

