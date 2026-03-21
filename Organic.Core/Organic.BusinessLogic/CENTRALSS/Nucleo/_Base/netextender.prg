Define Class NetExtender As zooSession of zooSession.prg

	#IF .f.
		Local this as NetExtender of NetExtender.prg
	#ENDIF

	oAssemblyResolver = null
	protected _oAssemblyResolver as Object, colReferencias as zoocoleccion OF zoocoleccion.prg
	_oAssemblyResolver = null
	colReferencias = null

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this._oAssemblyResolver = null
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function oAssemblyResolver_Access() as object
		if ( vartype( this._oAssemblyResolver ) != "O" or isnull( this._oAssemblyResolver ) ) and !this.lDestroy
			this.InstanciarAssemblyResolver()
		endif
		return this._oAssemblyResolver
	endfunc

	*-----------------------------------------------------------------------------------------
	function colReferencias_Access() as zoocoleccion OF zoocoleccion.prg
		if ( vartype( this.colReferencias ) != "O" or isnull( this.colReferencias ) ) and !this.lDestroy
			this.colReferencias = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.colReferencias
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarReferencia( tcAssembly as String ) as Void
		this.colReferencias.Agregar( tcAssembly )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarReferencias() as Void
		local lcAssembly as String, lcAssemblyConRuta as String, loError as Exception
		do while this.colReferencias.Count > 0
			lcAssembly = upper( alltrim( this.colReferencias.Item[ 1 ] ) )
			this.colReferencias.Remove( 1 )
			if justfname( lcAssembly ) == lcAssembly && No tiene ruta. Solo el nombre de la DLL.
				lcAssemblyConRuta = addbs(  _screen.Zoo.cRutaInicial ) + "bin\" + justfname( lcAssembly )
			else
				lcAssemblyConRuta = lcAssembly
			endif
			if file( lcAssemblyConRuta )
				try
					this.EjecutarComando( "SetCLRClassLibrary( '" + lcAssemblyConRuta + "', .t. )" )
				catch to loError
					This.LevantarExcepcion( "Error al referenciar el assembly " + juststem( lcAssemblyConRuta ) + ".", loError )
				endtry
			else
				This.LevantarExcepcion( "No se encontró el assembly " + juststem( lcAssemblyConRuta ) + "." )
			endif
		enddo
	endfunc

	*-----------------------------------------------------------------------------------------
	*!* Tiene su propio levantar excepcion por que puede no existir el goServicios.Errores en esta instancia
	protected function LevantarExcepcion( tcMensaje as String, toError as Exception )  as ZooException of ZooException.prg
		local loEx as ZooException of ZooException.prg
		loEx = _screen.zoo.CrearObjeto( "ZooException" )
		if vartype( toError ) = "O"
			loEx.Grabar( toError )
		Endif	
		loEx.AgregarInformacion( tcMensaje )
		loEx.Throw()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarComando( tcComando as string, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant ) as variant
		local lvRetorno as variant, lcSetProcedure as String, loError as Exception

		lcSetProcedure = set( "Procedure" )
		try
			execscript( this.ObtenerScriptSetearEntorno( .f. ) )
			if this.RequiereReferencias( tcComando )
				if isnull( this._oAssemblyResolver )
					this.InstanciarAssemblyResolver()
				endif
				this.AgregarReferencias()
			endif
			lvRetorno  = &tcComando
		catch to loError
			This.LevantarExcepcion( loError.Message, loError )
		finally
			set procedure to &lcSetProcedure
		endtry

		return lvRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarControlVisual( toContenedor as Object, tcNombreDelControl as String, tcClase as string, tcAssembly as String ) as void
		local lcSetProcedure as String, loError as Exception, lcRutaBin as String
		lcRutaBin = addbs( _Screen.zoo.cRutaInicial ) + "Bin\"

		lcSetProcedure = set( "Procedure" )
		try
			execscript( this.ObtenerScriptSetearEntorno( .f. ) )
			toContenedor.newobject( tcNombreDelControl, "NetBaseControl", "NetBaseControls.vcx", lcRutaBin + "COMWRAPPER4MANAGED.APP", tcClase, tcAssembly )
		catch to loError
			This.LevantarExcepcion( loError.Message, loError )
		finally
			set procedure to &lcSetProcedure
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InstanciarAssemblyResolver() as Void
		local lcComando as String
		execscript( this.ObtenerScriptSetearEntorno( .f. ) )
		lcComando = ""
		lcComando = "SetCLRClassLibrary( addbs( _screen.zoo.cRutaInicial ) + 'bin\ZooLogicSA.Interoperabilidad.dll', .t. )"
		&lcComando
		lcComando = "ClrCreateObject( 'ZooLogicSA.Interoperabilidad.AssemblyResolver', addbs( _screen.zoo.cRutaInicial ) + 'bin' )"
		this._oAssemblyResolver = &lcComando
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RequiereReferencias( tcComando as String ) as Void
		local lcComando as String, llRetorno as Boolean
		lcComando = "CLRCREATEOBJECT("
		llRetorno = upper( substr( tcComando, 1, len( lcComando ) ) ) == lcComando
		lcComando = "CLRINVOKESTATICMETHOD("
		llRetorno = llRetorno or upper( substr( tcComando, 1, len( lcComando ) ) ) == lcComando
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CLRDebug() as Void
		this.EjecutarComando( "CLRInvokeStaticMethod( 'System.Diagnostics.Debugger', 'Launch' )" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerScriptSetearEntorno( tlFormatoParaFactory as String ) as String
		local lcScript as String, lcSetProc as String, lcDeclare as String, lcRutaBin as String
		lcRutaBin = addbs( _Screen.zoo.cRutaInicial ) + "Bin\"

		lcSetProc	= "'set procedure to [" + lcRutaBin + "COMWRAPPER4MANAGED.APP], CLRExtenderProcedures in [" + lcRutaBin + "COMWRAPPER4MANAGED.APP]"
		lcDeclare	= "'declare long CreateNetExtender in [" + lcRutaBin + "COMWRAPPER4MANAGED.DLL]'"
		if tlFormatoParaFactory
		else
			lcSetProc = lcSetProc + iif( empty( set("Procedure")), "", "," + set("Procedure") )
		endif
		lcScript = lcSetProc + " additive' + chr( 13 ) + chr( 10 ) + " + lcDeclare
		if tlFormatoParaFactory
		else
			lcScript = strtran( lcScript, "'", "" )
		endif
		return lcScript
	endfunc

	*-----------------------------------------------------------------------------------------
	function BindearEventoNet( toPublicador as Object, tcEvento as String, toManejador as Object, tcDelegado as String  ) as Void
		local lcComando as String , lcSetProcedure  as string
	
		lcSetProcedure = set( "Procedure" )
		try
			execscript( this.ObtenerScriptSetearEntorno( .f. ) )
			lcComando = "CLRBindEvent( toPublicador, tcEvento, toManejador, tcDelegado )"
			&lcComando 
		catch to loError
			This.LevantarExcepcion( loError.Message, loError )
		finally
			set procedure to &lcSetProcedure
		endtry

	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesBindearEventoNet( toPublicador as Object, tcEvento as String, toManejador as Object, tcDelegado as String  ) as Void
		local lcComando as String , lcSetProcedure  as string
	
		lcSetProcedure = set( "Procedure" )
		try
			execscript( this.ObtenerScriptSetearEntorno( .f. ) )
			lcComando = "CLRUnBindEvents( toPublicador, tcEvento, toManejador, tcDelegado )"
			&lcComando 
		catch to loError
			This.LevantarExcepcion( loError.Message, loError )
		finally
			set procedure to &lcSetProcedure
		endtry
	endfunc 

enddefine