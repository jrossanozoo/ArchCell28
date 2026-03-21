**********************************************************************
Define Class ztestrenderzooinformacion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestrenderzooinformacion of ztestrenderzooinformacion.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerStringDesdeInfoVacia
		local loInfo as zooinformacion of zooInformacion.prg, loRender as Object 
		
		loRender = newobject( "RenderZooInformacion", "RenderZooInformacion.prg" )
		loInfo = newobject( "zooInformacion", "zooInformacion.prg" )
		
		this.assertequals( "Esta mal el texto", "", loRender.ObtenerString( loInfo ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerStringDesdeInfoLlena
		local loInfo as zooinformacion of zooInformacion.prg, loRender as Object, lcEsperado as String 
		
		loRender = newobject( "RenderZooInformacion", "RenderZooInformacion.prg" )
		loInfo = newobject( "zooInformacion", "zooInformacion.prg" )
		
		loInfo.AgregarInformacion( "detalle del problema" )
		loInfo.AgregarInformacion( "Titulo del problema" )

text to lcEsperado noshow
Titulo del problema
detalle del problema
endtext
		this.assertequals( "Esta mal el texto", lcEsperado, loRender.ObtenerString( loInfo ) )
	endfunc 

EndDefine
