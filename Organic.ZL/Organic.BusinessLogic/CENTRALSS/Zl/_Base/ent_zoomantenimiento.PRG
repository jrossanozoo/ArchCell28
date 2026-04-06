Define Class Ent_ZooMantenimiento As din_entidadZooMantenimiento of din_entidadZooMantenimiento.prg
	oGestorClaves = null
	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		_Screen.zoo.agregarreferencia( "ZooLogicSA.Core.BasesDeDatos.dll" )
		this.oGestorClaves = _screen.zoo.crearobjeto( "ZooLogicSA.Core.BasesDeDatos.GestorPasswords")
	endfunc
	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			this.SetearClaveDelDia( this.Fecha )
		endif
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	function SetearClaveDelDia( tdDate as Date ) as Void
		if empty( tdDate )
			this.Clave = ""
		Else
			this.Clave = this.oGestorClaves.ObtenerClaveDelDia( dtos( tdDate ) )
		Endif	
	endfunc 


enddefine
