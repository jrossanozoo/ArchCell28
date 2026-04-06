define class ColaboradorValidarTelefonos as zoosession of zoosession.prg

	oValidarTelefonos = null

	*--------------------------------------------------------------------------------------------------------
	function oValidarTelefonos_Access() as Variant
		if !this.ldestroy and ( vartype( this.oValidarTelefonos	) != 'O' or isnull( this.oValidarTelefonos ) )
			this.oValidarTelefonos = this.ObtenerClaseValidarTelefonos()
		endif
		return this.oValidarTelefonos
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClaseValidarTelefonos() as Object
		_Screen.Zoo.AgregarReferencia( "ZooLogicSA.ValidarTelefonos.dll" )
		return _Screen.Zoo.CrearObjeto( "ZooLogicSA.ValidarTelefonos.ValidarTelefono" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar( tcTelefono as string ) as boolean 
		local lRet as Boolean, loerror as Exception
		lRet = .t.
		try 
			lRet = this.oValidarTelefonos.IsValid( tcTelefono ) 
		catch to loerror

		endtry 	
		return lRet
	endfunc 

enddefine
