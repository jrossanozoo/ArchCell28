define class ColaboradorValidacionMail as Custom

	#IF .f.
		Local this as ColaboradorValidacionMail of ColaboradorValidacionMail.prg
	#ENDIF

	oParserMails = null
	oValidadorMail = null

	*-----------------------------------------------------------------------------------------
	function ValidarMail(tcMail as string, toObjetoPadre as object) as Boolean
		local llRetorno as Boolean, lcMailAValidar as String, lcMailAValidar as String ;
		 lcMailErroneo as String, llValidacionMail as Boolean
		
		llRetorno = .t.
		lcMailErroneo = ""
		llValidacionMail = .t.

		loColeccionMails = this.oParserMails.Parsear( tcMail, "|")
		for each lcMailAValidar in loColeccionMails 
			llValidacionMail = this.oValidadorMail.Validar( lcMailAValidar )
			if !llValidacionMail
				lcMailErroneo = lcMailErroneo + alltrim( lcMailAValidar ) + ", "
			endif
			llRetorno = llRetorno and llValidacionMail
		endfor
		
		if llRetorno
		else
			lcMailErroneo = left( lcMailErroneo , len( alltrim( lcMailErroneo ) ) - 1 )
			toObjetoPadre.AgregarInformacion( "Formato de Email inválido para: " + lcMailErroneo )
		EndIf	
		
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function oParserMails_Access() as Variant
		
		if  !vartype( this.oParser ) = 'O' or isnull( this.oParser ) 
			This.oParserMails = _screen.zoo.crearobjeto( "ParserMails" )
		endif
		
		return this.oParserMails		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function oValidadorMail_Access() as Variant
		if  !vartype( this.oValidadorMail ) = 'O' or isnull( this.oValidadorMail ) 
			This.oValidadorMail = _screen.zoo.crearobjeto( "ValidadorMail" )
		endif
		
		return this.oValidadorMail
	endfunc 



enddefine