**********************************************************************
Define Class zTestTipoEscalar As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTipoEscalar Of zTipoEscalar.prg
	#Endif

	*---------------------------------
	Function Setup

	Endfunc

	*---------------------------------
	Function zTestAbstracta()

		Local oTipo As TipoEscalar Of TipoEscalar.prg

		oTipo = Newobject( "TipoEscalar", "TipoEscalar.prg" )

		This.AssertTrue( "No tiene que poder instanciarse", Vartype(oTipo)#"O" )
	Endfunc

	*---------------------------------
	Function zTestConcreta()

		Local oTipo As TipoEscalar Of TipoEscalar.prg

		oTipo = CreateObject( "Concreta" )
		
		This.AssertTrue( "No se pudo instanciar", Vartype(oTipo)="O" )
		
		this.Assertequals( "Valor erróneo", .f., oTipo.Valor )
		
		oTipo.release()
	Endfunc

	*---------------------------------
	Function TearDown

	Endfunc

Enddefine


*============
Define Class Concreta As TipoEscalar Of TipoEscalar.prg
	
Enddefine

