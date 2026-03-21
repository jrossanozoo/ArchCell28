define class ColoryTalle_AspectoAplicacion as AspectoAplicacion of AspectoAplicacion.prg

	#IF .f.
		Local this as ColoryTalle_AspectoAplicacion of ColoryTalle_AspectoAplicacion.prg
	#ENDIF

	nModo = 1

	*-----------------------------------------------------------------------------------------
	function ObtenerTituloAplicacion() as String
		local lcRetorno as String
		lcRetorno = dodefault()
		if this.nModo = 2
			lcRetorno = "Dragonfish Pymes"
		endif
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function nModo_Access() as Integer
		local lnRetorno as Integer
		lnRetorno = goParametros.Colorytalle.ModoComercial
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaImagenFondoIzquierda() as Void
		if this.nModo = 2
			lcImagen2 = "Logo" + _Screen.Zoo.App.cProyecto + "Pyme.png"
			if !file( lcImagen2 ) 
				lcImagen2 = "Logo" + _Screen.Zoo.App.cProyecto + "Pyme.jpg" 
			endif
			lcImagen2 = "Logo" + _Screen.Zoo.App.cProyecto + "Pyme.png"
		else
			lcImagen2 = dodefault()
		endif
		return lcImagen2
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPieIzquierdoAbm() as Void
		if this.nModo = 2
			lcRetorno = 'pieizquierdocolorytallePyme.jpg'
		else
			lcRetorno = dodefault()
		endif
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreCompletoEdicion() as String
		local lcRetorno as String
		if this.nModo = 2
			lcRetorno = "Dragonfish"
		else
			lcRetorno = dodefault()
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreEdicion() as String
		local lcRetorno as String

		if this.nModo = 2
			lcRetorno = "Pyme"
		else
			lcRetorno = ""
		endif
		
		return lcRetorno 
	endfunc 
	
enddefine
