Define Class ValidarBase As zooSession Of zooSession.prg

	#IF .f.
		Local this as ValidarBase of ValidarBase.prg
	#ENDIF

	protected oInformacionIndividual
	*-----------------------------------------------------------------------------------------
	Function Init( tcRuta ) As VOID
		dodefault()
		This.oInformacionIndividual = this.crearobjeto( "ZooInformacion" )
	Endfunc

	*-----------------------------------------------------------------------------------------	
	Protected Function AgregarInformacionGeneral( tcDescripcion As String ) As VOID
		local toItem as Object

		If This.oInformacionIndividual.Count > 0
			for each toItem in This.oInformacionIndividual
				This.AgregarInformacion( space( 10 ) + toItem.cMensaje, toItem.nNumero )
			endfor
			This.AgregarInformacion( tcDescripcion )
			This.oInformacionIndividual.Limpiar()
		Endif
	Endfunc

enddefine

