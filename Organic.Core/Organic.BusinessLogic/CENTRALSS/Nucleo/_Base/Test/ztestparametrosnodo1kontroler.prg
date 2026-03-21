**********************************************************************
Define Class ztestParametrosNodo1Kontroler As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestParametrosNodo1Kontroler Of ztestParametrosNodo1Kontroler.prg
	#Endif

	nSesion = 0
	
	lnCodigoConroladorFiscal = 0
	
	*---------------------------------
	Function Setup
	EndFunc

	*---------------------------------
	Function Teardown
	endfunc

	*---------------------------------
	Function zTestSqlServerDeshabilitarCodigoMinusculas
		local loFormParam as Form, loControlCodigo  as Object , loControl  as Object 

		local loForm as Form, loControl as object, lcControl as string, lcParam as string, lp1, lp2, loItem
		
		loForm = _screen.zoo.crearobjeto( "FormularioParametros" )
		loForm.AddProperty( "ColControles", _screen.zoo.CrearObjeto( "zooColeccion" ) )

		loItem = _Screen.zoo.crearobjeto( "ITemAdndibujante")
		loItem.Dominio = "CARACTER"

		loForm.NewObject( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO", "etiquetadato", "etiquetadato.prg", "", loItem  )
					 		 
		loForm.ColControles.Agregar( "thisform.NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO.txtDato", "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO" )
											   
		loForm.NewObject( "oKontroler", "parametrosnodo1kontroler", "parametrosnodo1kontroler.prg" )

		loForm.oKontroler.Inicializar()

		loControl = loForm.oKontroler.ObtenerControl( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO" )

		if file( _screen.zoo.cRutaInicial + "PermiteCodigoEnMinusculas.txt" )
			this.asserttrue( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO bebe estar deshabilitado para SQLSERVER", loControl.enabled )
		else
			this.asserttrue( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO bebe estar deshabilitado para SQLSERVER", !loControl.enabled )
		endif

		loForm.Release()

	endfunc
	
	*---------------------------------
	Function zTestNativaHabilitarCodigoMinusculas
		local loFormParam as Form, loControlCodigo  as Object , loControl  as Object 

		local loForm as Form, loControl as object, lcControl as string, lcParam as string, lp1, lp2, loItem
		
		loForm = _screen.zoo.crearobjeto( "FormularioParametros" )
		loForm.AddProperty( "ColControles", _screen.zoo.CrearObjeto( "zooColeccion" ) )

		loItem = _Screen.zoo.crearobjeto( "ITemAdndibujante")
		loItem.Dominio = "CARACTER"

		loForm.NewObject( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO", "etiquetadato", "etiquetadato.prg", "", loItem  )
					 		 
		loForm.ColControles.Agregar( "thisform.NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO.txtDato", "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO" )
											   
		loForm.NewObject( "oKontroler", "parametrosnodo1kontroler", "parametrosnodo1kontroler.prg" )

		loForm.oKontroler.Inicializar()

		loControl = loForm.oKontroler.ObtenerControl( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO" )
		
		this.asserttrue( "NUCLEONODO1_PERMITECODIGOSENMINUSCULASDATO debe estar habilitado para NATIVA", loControl.enabled )

		loForm.Release()

	endfunc

enddefine
	