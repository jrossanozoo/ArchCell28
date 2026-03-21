Define Class zooColaborador as ZooCustom of ZooCustom.prg

	#IF .f.
		Local this as zooColaborador of zooColaborador.prg
	#ENDIF

	Protected oInformacion, oMensaje, lEsExe

	oInformacion = null
	oMensaje = null

	lDesarrollo = .f.
	lDestroy = .f.
	lEsExe = .f.
	DataSession = 1

	*-------------------------------------------------------------------
	Function Init() as Boolean
		this.lDesarrollo = EsIyD()
		this.lEsExe = ( _vfp.StartMode == 4 )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Destroy()
		this.lDestroy = .t.
		If Type( "this.oMensaje" ) = "O"
			this.oMensaje.Release()
		Endif
		If Type( "This.oInformacion" ) = "O"
			This.oInformacion.Limpiar()
			This.oInformacion.Release()
		Endif
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
	Function oMensaje_Access() as Void
		If !this.ldestroy and ( !Vartype( this.oMensaje ) = 'O' or Isnull( this.oMensaje ) )
			this.oMensaje = Newobject( "Mensajes", "Mensajes.prg" )
		Endif
		
		Return this.oMensaje
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

Enddefine

