define class VerificarMocks as Zoosession of ZooSession.Prg

	#IF .f.
		Local this as VerificarMocks of VerificarMocks.prg
	#ENDIF

	protected oProcesoDinamico
	oProcesoDinamico = Null

	*-----------------------------------------------------------------------------------------
	function VerificarGeneracionMocks( tcClase as String , tcLibreria as String ) as Void
		local lcPrg as String
		lcPrg = tcClase + ".prg" 
		if ( !empty( tcLibreria ) and file( tcLibreria ) ) or file( lcPrg ) 
		Else
			This.GenerarMocks( tcClase )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarMocks( tcClase as String ) as Void
		local lcClase as String, llEsClaseMock as Boolean, llEsEntidad as Boolean
		lcClase = strtran( upper( tcClase ), "MOCK_" , "" )
		llEsClaseMock	= This.VerificarClaseMock( lcClase )
		llEsEntidad 	= This.VerificarEntidad( lcClase )
		do Case
			case llEsClaseMock
				This.oProcesoDinamico.GenerarMockEspecifico( lcClase, "CLASESMOCK", .T., 2 )
			case llEsEntidad
				This.oProcesoDinamico.GenerarMockEspecifico( lcClase, "ENTIDAD", .T., 2 )
			otherwise
				goServicios.Errores.LevantarExcepcion( "No se pudo resolver el mock a generar( " + tcClase + ")" ) 
		EndCase		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarClaseMock( tcClase as String ) as Void
		local llRetorno
		use in select( "ClasesMock" )
		select 0
		use ClasesMock
		locate for upper( alltrim( Entidad ) ) == upper( alltrim( tcCLase ) )
		llRetorno = found()
		use in select( "ClasesMock" )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarEntidad( tcClase as String ) as Void
		local llRetorno
		use in select( "EntidadParaMocks" )
		select 0
		use Entidad again alias "EntidadParaMocks"
		locate for upper( alltrim( Entidad ) ) == upper( alltrim( tcCLase ) )
		llRetorno = found()
		use in select( "EntidadParaMocks" )
		return llRetorno		
	endfunc

	*-----------------------------------------------------------------------------------------
	function oProcesoDinamico_Access() as variant
		with this
			if !.ldestroy and !vartype( .oProcesoDinamico ) = 'O' and isnull( .oProcesoDinamico )
				lcClase = "ProcesoDinamico"
				.oProcesoDinamico = This.CrearObjeto( lcClase )
			endif
		endwith
		return this.oProcesoDinamico
	endfunc

enddefine
