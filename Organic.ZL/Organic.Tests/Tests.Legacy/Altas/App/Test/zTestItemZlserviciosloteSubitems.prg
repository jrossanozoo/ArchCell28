**********************************************************************
define class zTestItemZlserviciosloteSubitems as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestItemZlserviciosloteSubitems of zTestItemZlserviciosloteSubitems.PRG
	#endif

	*-----------------------------------------------------------------------------------------
	function zTestAsignarParametroNroSerieParaValorSugerido

		This.agregarmocks( "zlSeries,zlaltagrupocom, PRODUCTOZL" )	
		_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Numero_despuesdeasignar', .T. )
		local loObjestSubitem as Object
		loObjestSubitem = newobject( "ItemZlServiciosLoteSubItems", "ItemZlServiciosLoteSubItems.prg" )
				
		loObjestSubitem.Serie_Pk = "NOSERIE"
		loObjestSubitem.GrupoCom_Pk = 01

		This.assertequals( "El valor del parametro no se asigno con el valor correcto", "NOSERIE" , alltrim( goParametros.Zl.ValoresSugeridos.NroSerieSugeridoDefault ) )
		
		loObjestSubitem.Serie_Pk = "1234567890"
		loObjestSubitem.GrupoCom_Pk = 01
		this.assertequals( "No se Asigno el valor correcto al Parametro 2.", "1234567890", alltrim( goParametros.Zl.ValoresSugeridos.NroSerieSugeridoDefault ) )

		loObjestSubitem.Serie_Pk = "NOSERIE"
		loObjestSubitem.GrupoCom_Pk = 01

		This.assertequals( "El valor del parametro no se asigno con el valor correcto 1 ", "NOSERIE" , alltrim( goParametros.Zl.ValoresSugeridos.NroSerieSugeridoDefault ) )
		
		loObjestSubitem.Release()
	endfunc 

enddefine
