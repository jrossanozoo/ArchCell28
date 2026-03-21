define class Funcionalidades as custom

	#IF .f.
		Local this as Funcionalidades of Funcionalidades.prg
	#ENDIF

	CaracteresFinalizadores = "<>:"

	*-----------------------------------------------------------------------------------------
	protected function ObtenerUbicacionFuncionalidad( tcFunc as string, tcFuncDispo as String ) as integer

		local lcFuncionalidad as String, lnOcurrencia as Integer, lnRetorno as integer, ;
		 lnUbic as Integer, lcCaracterFin as String
		
		lcFuncBuscada = alltrim( tcFunc )
		lnOcurrencia = 1
		lnRetorno = 0
		lnUbic = at( "<" + lcFuncBuscada , tcFuncDispo , lnOcurrencia )
		do while lnUbic != 0
			lcCaracterFin = substr( tcFuncDispo, lnUbic + len( lcFuncBuscada ) + 1 , 1 )		
			
			if lcCaracterFin $ this.CaracteresFinalizadores
				lnRetorno = lnUbic
				exit
			endif
			lnOcurrencia = lnOcurrencia + 1
			lnUbic = at( "<" + lcFuncBuscada , tcFuncDispo, lnOcurrencia )
		enddo 
		
		return lnRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneFuncionalidad( tcFuncionalidadBuscada as String, tcFuncDispo as String ) as Boolean
		return This.ObtenerUbicacionFuncionalidad( tcFuncionalidadBuscada, tcFuncDispo ) > 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValor( tcFuncionalidad as String, tcFuncDispo as String ) as String
		local lcRetorno as String, lcFuncionalidad as String, lnUbic as Integer, lnUbicDosPuntos as Integer, lcValoresYResto as String

		lcRetorno = ""
		lnUbic = this.ObtenerUbicacionFuncionalidad( tcFuncionalidad, tcFuncDispo )
		if lnUbic > 0
			lcFuncionalidad = alltrim( tcFuncionalidad )
			lnUbicDosPuntos = lnUbic + len( lcFuncionalidad ) + 1
			if substr( tcFuncDispo , lnUbicDosPuntos, 1 ) == ":"
				lcValoresYResto = substr( tcFuncDispo, lnUbicDosPuntos + 1 )
				lcRetorno = left( lcValoresYResto, at( ">", lcValoresYResto ) - 1 )
			endif
		endif
		return lcRetorno
	endfunc 


enddefine
