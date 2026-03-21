Define Class TipoBase As zooSession of zooSession.prg
	
	#IF .f.
		Local this as TipoBase of TipoBase.prg
	#ENDIF

	oMensaje = null
	
	*-----------------------------------------------------------------------------------------
	function oMensaje_Access() as Void
		if !this.ldestroy and ( !vartype( this.oMensaje ) = 'O' or isnull( this.oMensaje ) )
			this.oMensaje = _screen.zoo.crearobjeto( "mensajeentidad", "", this )
		endif
		
		return this.oMensaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		this.oMensaje = null
		dodefault()
	endfunc
		
	*-----------------------------------------------------------------------------------------
	Function Init() as Boolean 
		Return ( this.Class # "Tipobase" ) and dodefault()
	endfunc

EndDefine

