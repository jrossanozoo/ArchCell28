**********************************************************************
Define Class zTestMemos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestMemos of zTestMemos.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerDosRegistros
		
		local loMemos as Object, lcResultado as String, lcEsperado as String
		loMemos = newobject( "Memos", "memos.prg" )
		
		create cursor curMemos ( orden I, texto C( 80 ) )
		
		insert into curMemos values ( 1, "Esta es la primera parte del texto")
		insert into curMemos values ( 2, "esta es la segunda parte del texto")

		lcResultado = loMemos.Obtener( "curMemos" )
		
		lcEsperado = padr( "Esta es la primera parte del texto" , 80, " ") + padr( "esta es la segunda parte del texto" , 80, " ") 
		this.assertequals( "Error en el obtener", lcEsperado , lcResultado )
		
		use in select( "curMemos" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerCaracteresReemplazados
		
		local loMemos as Object, lcResultado as String, lcEsperado as String
		loMemos = newobject( "Memos", "memos.prg" )
		
		create cursor curMemos ( orden I, texto C( 80 ) )
		
		insert into curMemos values ( 1, "Esta es la primera parte del texto" + chr( 230 ) + chr( 240 ))

		lcResultado = loMemos.Obtener( "curMemos" )
		
		lcEsperado = padr( "Esta es la primera parte del texto" + chr( 13 ) + chr( 10 ) , 80, " ")
		this.assertequals( "Error en el obtener", lcEsperado , lcResultado )
		
		use in select( "curMemos" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestObtenerCursorVacio
		
		local loMemos as Object, lcResultado as String, lcEsperado as String
		loMemos = newobject( "Memos", "memos.prg" )
		
		create cursor curMemos ( orden I, texto C( 80 ) )

		lcResultado = loMemos.Obtener( "curMemos" )
		
		this.assertequals( "Error en el obtener", "", lcResultado )
		
		use in select( "curMemos" )
	endfunc 



EndDefine
