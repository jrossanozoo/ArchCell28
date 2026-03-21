**********************************************************************
Define Class ztestVerificacionConfiguracionBasica as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestVerificacionConfiguracionBasica of ztestVerificacionConfiguracionBasica.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc
		*-----------------------------------------------------------------------------------------
	function ztestVerificarCampoBloqueoEnTablasDeConfiguracionBasica
		local lcDirectorio as String, i as Integer, lcTabla as String
		local loArray as Object
		lcDirectorio = 	addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) )
		lcDirectorio = lcDirectorio + "ConfiguracionBasica\"
		
		loArray = _screen.zoo.invocarmetodoestatico( "System.IO.Directory", "GetFiles", lcDirectorio , "*.dbf*", 1 )
		for i = 1 to loArray.Length
			lcTabla = loArray.GetValue( i )
			if atc( "DatosBasicos", lcTabla ) = 0 and atc( "archivos", lcTabla ) = 0 and !( "\DATOSDEFAULTENTIDADESESPECIALES\" $ upper( alltrim( lcTabla ) ) ) 
				use ( lcTabla ) in 0 alias Auxiliar
				select Auxiliar
				This.Assertequals( "No existe el campo BloqReg en " + lcTabla, type( "Auxiliar.BloqReg" ), "L" )
				use in select( "Auxiliar" )
			endif
		EndFor
	endfunc 
EndDefine
