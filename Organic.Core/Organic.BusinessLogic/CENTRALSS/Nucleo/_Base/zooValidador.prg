Define Class zooValidador as ZooCustom of ZooCustom.prg

	#IF .f.
		Local this as zooValidador of zooValidador.prg
	#ENDIF

	Protected oInformacion
	oInformacion = null

	*-----------------------------------------------------------------------------------------
	Function Destroy()
		dodefault()
		this.lDestroy = .t.
		If Type( "This.oInformacion" ) = "O"
			This.oInformacion.Limpiar()
			This.oInformacion.Release()
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function oInformacion_Access() as Object
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
	function setearInformacion( toInformacion as Object ) as Void
		this.oInformacion = toInformacion
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function inyectarInformacion( toQuienLlama as Object ) as Void
		toQuienLlama.setearInformacion( this.oInformacion )
	endfunc 
	
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
	function eventoObtenerInformacion( toYoMismo as Object ) as Void
		****Si hay algun otro objeto escuchando le va a inyectar un objeto Informacion
	endfunc 

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
	function AgregarInformacionDeExcepcion( toError as Exception ) As Void
		local loEx as zooexception OF zooexception.prg
		if lower( toError.Class ) == "exception"
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx				
				.Grabar( toError )
				.ExceptionToInformacion( This.oInformacion )
			EndWith
		Else
			toError.ExceptionToInformacion( This.oInformacion )
		EndIf	
	endfunc 

Enddefine

