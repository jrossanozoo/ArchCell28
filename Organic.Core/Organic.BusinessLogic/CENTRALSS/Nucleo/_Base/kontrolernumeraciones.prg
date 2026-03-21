define class kontrolerNumeraciones as din_kontrolerNumeraciones of din_kontrolerNumeraciones.prg

	#IF .f.
		Local this as kontrolerNumeraciones of kontrolerNumeraciones.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	Function Inicializar() as void
		local loControl as Object
		
		dodefault()
		
		This.cEstado = "EDICION"
		this.oEntidad.Modificar()
		loControl = this.ObtenerControl( "TALONARIOS" )
		loControl.nCantidadFilas = this.oEntidad.Talonarios.Count
		loControl = null

		thisform._Botonera.cCaptionB1 = "Grabar"
		thisform._Botonera.cCaptionB2 = "Salir"
	
	endfunc

	*-----------------------------------------------------------------------------------------
	Function Ejecutar( tcAccion As String ) As Void
		if inlist( upper( tcAccion ), "GRABAR", "CANCELAR", "SALIR" )
			this.Precancelar()
		endif

		dodefault( tcAccion )
		
		if upper( tcAccion ) == "GRABAR"
			This.PostCancelar()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Precancelar() as Void
		this.oEntidad.lLanzarExcepcion = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PostCancelar() as Void
		Thisform.salir()
	endfunc 


enddefine

