define class zooClaseBase as Custom

	#IF .f.
		Local this as zooClaseBase of zooClaseBase.prg
	#ENDIF

	protected lEsExe
	lDesarrollo = .f.
	lDestroy = .f.
	lEsExe = .f.

	*-------------------------------------------------------------------
	Function Init
		this.lDesarrollo = EsIyD()
		this.lEsExe = ( _vfp.StartMode == 4 )
	EndFunc

	*-----------------------------------------------------------------------------------------
	function Destroy()
		local lnCantidad as Integer, laPropiedades as array, lnTablaActual as Integer,;
		lnIndProp as Integer, lcPropiedad as String, lcEliminaReferencia as String    
		dimension laPropiedades(1)

		this.lDestroy = .t.
		dodefault()
		lnCantidad = Amembers( laPropiedades,this,0,"UG+" )
		this.Finalizar()
		for lnIndProp = 1 to lnCantidad
			lcPropiedad = "this."+ alltrim( laPropiedades[lnIndProp] )
			if vartype( evaluate( lcPropiedad ) ) = "O"
				if pemstatus(&lcPropiedad,"release",5)
					lcEliminaReferencia = lcPropiedad + ".release"
					&lcEliminaReferencia
				else
					lcEliminaReferencia = lcPropiedad + " = null"
					&lcEliminaReferencia
				endif
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------	
	function Finalizar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		*this.Destroy() se llama con el release this automaticamente
		release this 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Enlazar( tcDelegando as String , tcDelegado As String ) as Void
		local lnPunto as Integer, lcObjeto as String, lcEvento As String, lcDelegando As String
	
		lcDelegando = tcDelegando
		if substr( lcDelegando, 1, 1 ) = "."
			lcDelegando = substr( lcDelegando, 2 )
		else

		Endif

		lnPunto  = at( ".", lcDelegando )
		
		if lnPunto = 0
			lcObjeto = "this"
		else
			lcObjeto = "this." + substr( lcDelegando, 1, lnPunto - 1 )
		endif
		lcEvento = substr( lcDelegando, lnPunto + 1 )

		this.BindearEvento( &lcObjeto, lcEvento, this, tcDelegado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BindearEvento(toObjetoSource, tcEvento, toObjetoHandler, tcDelegado) as Void
		if this.EsObjetoNet( toObjetoSource )
			_screen.netextender.BindearEventoNet( toObjetoSource, tcEvento, toObjetoHandler, tcDelegado )
		else
			bindevent( toObjetoSource, tcEvento, toObjetoHandler, tcDelegado, 1 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesBindearEvento( toPublicador as Object, tcEvento as String, toManejador as Object, tcDelegado as String ) as Void
		if this.EsObjetoNet( toPublicador )
			_screen.netextender.DesBindearEventoNet( toPublicador, tcEvento, toManejador, tcDelegado )
		else
			unbindevent( toPublicador, tcEvento, toManejador, tcDelegado )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsObjetoNet( toObjeto as Object ) as Boolean
		local llRetorno as Boolean, loError as Exception
		llRetorno = .F.

		try
			toObjeto.Equals( toObjeto )
			llRetorno = .T.
		catch to loError
		endtry
		
		return llRetorno 		
	endfunc 

enddefine
