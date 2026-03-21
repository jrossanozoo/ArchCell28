define class ZooCustom as Custom

	#IF .f.
		Local this as ZooCustom of ZooCustom.prg
	#ENDIF

	protected oInformacion, cFormatoFechaNet, lEsExe

	lDesarrollo = .f.
	lDestroy = .f.
	lEsExe = .f.
	oInformacion = null
	cFormatoFechaNet = ""

	*-------------------------------------------------------------------
	Function Init() as Boolean
		dodefault()
		this.lDesarrollo = EsIyD()
		this.lEsExe = ( _vfp.StartMode == 4 )
		This.cFormatoFechaNet = "dd/MM/yyyy"
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		*this.Destroy() se llama con el release this automaticamente
		release this 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function oInformacion_Access() as variant
		With This
			If !.ldestroy and !vartype( .oInformacion ) = 'O' and isnull( .oInformacion )
				If !Vartype( .oInformacion ) = 'O' and Isnull( .oInformacion )
					.oInformacion = newObject( "ZooInformacion", "ZooInformacion.prg" )
				Endif
			Endif
		Endwith
		Return This.oInformacion
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AgregarInformacion( tcInformacion as String, tnNumero as Integer, txInfoExtra as Variant ) as Void
		Do Case
		Case Pcount() = 1
			This.oInformacion.AgregarInformacion( tcInformacion )
		Case Pcount() = 2
			This.oInformacion.AgregarInformacion( tcInformacion, tnNumero )
		Case Pcount() = 3
			This.oInformacion.AgregarInformacion( tcInformacion, tnNumero, txInfoExtra )
		Otherwise
			Assert Pcount() = 0 Message "Llamaron al AgregarInformacion del zooSession con parametros incorrectos"
		Endcase
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function LimpiarInformacion() as Void
		This.oInformacion.Limpiar()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function HayInformacion() as Boolean
		return This.oInformacion.HayInformacion()
	Endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacion() as zooInformacion of zooInformacion.prg
		return this.oInformacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function CargarInformacion( toInformacion as zooInformacion of zooInformacion.prg ) as VOID
		Local lnCont as Integer
		With toInformacion
			For lnCont = 1 to toInformacion.Count
				This.AgregarInformacion( .item[ lnCont ].cMensaje, .item[ lnCont ].nNumero , .item[ lnCont ].xInfoExtra )
			Endfor
		Endwith
		toInformacion.Limpiar()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function CursorAXML( tcNombreCursor) as String
		Local lcRetorno as String
		
		cursortoxml(tcNombreCursor,"lcRetorno", 3, 4, 0, "1")
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function XmlACursor( tcXml as String, tcNombreCursor as String ) as Void
		xmltocursor( tcXml, tcNombreCursor, 4 ) 
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

