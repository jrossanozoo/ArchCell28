Define Class kontrolerConBuscador As Kontroler Of Kontroler.prg
	oColEntidades = null
	
	*-----------------------------------------------------------------------------------------
	function Buscar( toTextBoxDesdeHasta as Object, tcSigno as String, tcString as String ) as Void
		local lxVal As Variant
		with toTextBoxDesdeHasta
			lxVal = .xValorAnterior
			toTextBoxDesdeHasta.oEntidad = This.ObtenerInstancia( toTextBoxDesdeHasta.cClaveForanea )
	 		goServicios.Controles.Buscar( thisform, toTextBoxDesdeHasta, tcSigno, tcString )
	 		toTextBoxDesdeHasta.oEntidad = Null
			.setfocus()
			.xValorAnterior = lxVal
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function oColEntidades_Access() as Object 
		if !this.ldestroy and ( !vartype( this.oColEntidades ) = 'O' or isnull( this.oColEntidades ) )
			this.oColEntidades = this.crearobjeto( 'ZooColeccion' )
		endif
		return this.oColEntidades 
	endfunc 
	*-----------------------------------------------------------------------------------------
	hidden function ObtenerInstancia( tcEntidad as String ) as Object
		local lcEntidad as String
		lcEntidad = alltrim( upper( tcEntidad ) )
		with This.oColEntidades as zoocoleccion OF zoocoleccion.prg
			if .Buscar( lcEntidad )
			else
				.Agregar( _Screen.zoo.instanciarentidad( lcEntidad ), lcEntidad )
			Endif			
			return .Item( lcEntidad )
		Endwith
	endfunc 	
	*-----------------------------------------------------------------------------------------
	Function Destroy()
		do While This.oColEntidades.Count > 0
			loItem = This.oColEntidades.Item[1]
			loItem.Release()
		EndDo
		dodefault()
	endfunc
	*-----------------------------------------------------------------------------------------
	function SetearEstadoMenuYToolBar( tlPar ) as Void
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VerificarBuscar( toTextBoxDesdeHasta as Object ) as Void

		local lcSigno as String, lcString as String, llRetorno as Boolean    
		llRetorno = .t.
		with toTextBoxDesdeHasta
			do case
				case left( .value, 1 ) = "?" and substr( .value, 2, 1 ) # "?"
					lcSigno = "?"
					lcString = rtrim( substr( .value, 2 ) )

				case left( .value, 2 ) = "??"
					lcSigno = "??"
					lcString = rtrim( substr( .value,  3) )
				otherwise
					llRetorno = .f.
			endcase
		 	if llRetorno 
		 		this.Buscar( toTextBoxDesdeHasta, lcSigno, lcString )
			endif
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	Function SetearAyuda( tcTexto As String ) As Void
	endfunc 

EndDefine