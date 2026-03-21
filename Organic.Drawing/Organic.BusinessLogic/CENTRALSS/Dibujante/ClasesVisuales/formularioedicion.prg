Define Class formularioEdicion As ZooFormulario Of ZooFormulario.prg

	#if .f.
		local this as formularioEdicion of formularioEdicion.prg
	#endif

	 cXmlMenu = ''
	 cXmlToolbar = ''
	 cXml = ''
	 lUsaControlesExtensibles = .f.
	 cSubgrupoExtensible = ""
***
	*-----------------------------------------------------------------------------------------
	function Height_Assign( txVal ) as Void
		if this.lUsaControlesExtensibles 
			this.MaxHeight = txVal
			this.MinHeight = txVal
		endif
		this.Height = txVal
		if pemstatus( this, "oBarraEstado", 5 )
			this.oBarraEstado.Top = txVal - this.oBarraEstado.Height
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AjustarFormulario( toContenedorBase as integer, tnDiferencia as Integer ) as Void
		local loGrupo as zooContenedor of zooContenedor.prg, lnMayorAlto as integer, lnAlto as integer, lnAltoColumna as integer, ;
			llModificarAlto as integer, lnAux as integer, lnPosicion, llValorAnterior, lAcomodarRestantes, lcsubgrupo

			llValorAnterior = thisform.lockscreen 
			thisform.lockscreen = .t.
			lcsubgrupo = alltrim( thisform.csUBGRUPOEXTENSIBLE)
			lAcomodarRestantes = .t.
		with this
			lnMayorAlto = 0
			lnAltoColumna = 0
			if type ('tnDiferencia') <> 'N'
				 tnDiferencia = 0
			endif	 
			if pemstatus( this, "PnlGrupos",5)
				lnPosicion = this.PnlGrupos.top

				this.acomodarDentroDelPage( toContenedorbase , tndiferencia)
				if tndiferencia >0
					lnAltoColumna = tocontenedorbase.height
				endif
				if this.PnlGrupos.objects.Count > 1
					tndiferencia = 0
					lAcomodarRestantes = .f.
				endif
			else
				lnPosicion = toContenedorbase.top
				if tndiferencia >0
					lnAltoColumna = tocontenedorbase.height
				endif
			endif
			if lAcomodarRestantes
				for lnI = 1 to thisform.controlcount
					loGrupo = thisform.controls[ lnI ]
					if upper(alltrim(logrupo.Class)) = "CONTENEDORSUBGRUPO"
						if pemstatus( loGrupo, "visible",5) and loGrupo.Visible and logrupo.Top > lnPosicion 
							loGrupo.Top = loGrupo.Top + tndiferencia
						endif
					ENDIF
				endfor 	
			endif
			.SetearAltoFormulario( tnDiferencia, lnAltoColumna, lnMayorAlto )
			thisform.lockscreen = llValorAnterior
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function acomodarDentroDelPage( toContenedorbase , tndiferencia)as Void
		local lni, logrupo 
			for lnI = 1 to toContenedorbase.parent.controlcount 
				loGrupo = toContenedorbase.parent.controls[ lnI ]
				if upper(alltrim(logrupo.Class)) = "CONTENEDORSUBGRUPO"
					if pemstatus( loGrupo, "visible",5) and loGrupo.Visible and logrupo.Top > toContenedorbase.top
						loGrupo.Top = loGrupo.Top + tndiferencia
					endif
				ENDIF
			endfor 	

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAltoFormulario( tnDiferencia as integer, tnAltoColumna as integer, tnMayorAlto as integer ) as VOID
		local llModificarAlto  as Boolean, lnAltoAnterior as integer
		with this
			llModificarAlto  = .f.
			lnAltoAnterior = tnAltoColumna - tnDiferencia
			
			if tnDiferencia < 0
				if tnAltoColumna > tnMayorAlto 
					llModificarAlto  = .t.
				else
					if lnAltoAnterior > tnMayorAlto
						tnDiferencia = tnMayorAlto - lnAltoAnterior
						llModificarAlto  = .t.
					endif
				endif
			else
				if tnAltoColumna > tnMayorAlto
					llModificarAlto  = .t.

					if lnAltoAnterior < tnMayorAlto
						tnDiferencia = tnAltoColumna - tnMayorAlto
					endif
				endif
			endif
			
			if llModificarAlto and .height + tnDiferencia > 0 
				.height = .height + tnDiferencia
				._BOTONERA.top = ._BOTONERA.top + tnDiferencia 
			endif
		endwith
	endfunc 

***

	*-----------------------------------------------------------------------------------------
	Function Destroy
		DoDefault()
		If Pemstatus( This, "CBM", 5 ) And Vartype( This.CBM ) = "O"
			if Pemstatus( This.CBM, "oMenu", 5 ) And Vartype( This.CBM.oMenu ) = "O"
				thisform.RemoveObject( "oMenu" )
			endif
			
			this.cbm.dispose()
		endif 
		If Pemstatus( This, "oEntidad", 5 ) And Vartype( This.oEntidad ) = "O"
			This.oEntidad.Release()
		Endif
	Endfunc

	*-------------------------------------------------------------------------
	Function QueryUnload
		local loError as Exception
		try
			if type( "This.oKontroler" ) = "O" and !isnull( This.oKontroler )
				This.oKontroler.Ejecutar( "Salir" )
				if !This.oKontroler.lEstadoUltimoProceso
					nodefault
				endif
			endif
		catch to loError
			Do DesglosarError in main.prg With loError, null
		endtry
	Endfunc

	*-------------------------------------------------------------------------
	Function KeyPress( nkeycode, nshiftaltctrl )

		If inlist( nkeycode, 23, goRegistry.Dibujante.TeclaAccesoRapidoGrabar ) And (This.oentidad.esnuevo() Or This.oentidad.esedicion()) and !This.oentidad.EstaEnProceso()
			if This.oKontroler.RefrescarControlActivo()
				This.oKontroler.ejecutar("GRABAR")
				noDefault
			Endif	
		Endif

		If nkeycode = 27
			If ( This.oentidad.esnuevo() Or This.oentidad.esedicion() Or upper( This.oKontroler.cEstado ) = "BUSQUEDA" )  and !This.oentidad.EstaEnProceso()
				This.oKontroler.ejecutar("CANCELAR")
			Endif
		endif
		
		if nKeyCode = 97 and nshiftaltctrl = 2 and !( This.oentidad.esnuevo() Or This.oentidad.esedicion() Or upper( This.oKontroler.cEstado ) = "BUSQUEDA" );
			 and !This.oentidad.EstaEnProceso()
			This.oKontroler.ejecutar("SALIR")
		endif	

		If Pemstatus( This, "pnlGrupos", 5 ) 
			if type( "ThisForm.ActiveControl" ) = "O" .And. upper( ThisForm.ActiveControl.baseClass )= "COMBOBOX"
			else
				if  !This.oentidad.EstaEnProceso()
					do case			
						case nKeyCode = 148 And nShiftAltCtrl = 2	&& Ctrl + Tab ( alterna solapas )
							This.pnlGrupos.ActivarSiguienteSolapa( this.pnlGrupos.ActivePage )
						case nKeyCode = 148 And nShiftAltCtrl = 3	&& Ctrl + Shift + Tab ( alterna solapas )
							This.pnlGrupos.ActivarAnteriorSolapa( this.pnlGrupos.ActivePage )						
						case nKeyCode = 31 And nShiftAltCtrl = 2	&& Ctrl + PageUp ( alterna solapas )
							This.pnlGrupos.RetrocedeSolapa( this.pnlGrupos.ActivePage )
						case nKeyCode = 30 And nShiftAltCtrl = 2	&& Ctrl + PageDown ( alterna solapas )
							This.pnlGrupos.AvanzaSolapa( this.pnlGrupos.ActivePage )
					endcase			
				endif 	
			EndIf
		endif
		
		If upper( this.oKontroler.cEstado ) == "NULO" and this.lHayDatos and ( Between( nKeyCode, 50, 52 ) or inlist( nKeyCode, 5, 4, 19, 24 ) );
			 and !This.oentidad.EstaEnProceso()
			Local lnTecla As Integer
			lnTecla = nKeyCode

			Do Case
				Case lnTecla = 50 or lnTecla = 19
					this.oKontroler.Ejecutar( "Anterior" )
				Case lnTecla = 51 or lnTecla = 4
					this.oKontroler.Ejecutar( "Siguiente" )
				Case lnTecla = 52 or lnTecla = 24
					this.oKontroler.Ejecutar( "Ultimo" )
				Case lnTecla = 5
					this.oKontroler.Ejecutar( "Primero" )
			Endcase
			noDefault
		Endif

		*/Ctrl+Shift+O
		if nKeyCode = 15 and nshiftaltctrl = 3 and (this.oEntidad.EsNuevo() or this.oEntidad.EsEdicion()) and ;
				pemstatus( this.oEntidad, "ValoresDetalle", 5 ) and pemstatus( this.oKontroler, "HacerFocoEnDetalleValores", 5 )
			this.oKontroler.HacerFocoEnDetalleValores()
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerNombreEntidad() As Void
		Local lcRetorno As String

		lcRetorno = ""
		If Vartype( This.oEntidad ) = "O"
			lcRetorno = This.oEntidad.obtenerNombre()
		Endif
		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarMenuyToolbarBasico() as Void
*!*			Public _3EC687BB
*!*			_3EC687BB = .T. 
*	    Public _464DBF4E
*	    _464DBF4E = .T.

		thisform.newobject( 'CBM', 'CommandbarsManager', 'argcommandbars.vcx' ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function AgregarMenuyToolbar() void
		local loMenuManager as MenuPrincipal of MenuPrincipal.prg	
		
		this.AgregarMenuyToolbarBasico()
		
		If VarType( Thisform.CBM ) != 'O' or IsNull( Thisform.CBM )
			Return .F. 
		EndIf 
		
		if _screen.zoo.lDesarrollo  && Es solo para desarrollo ya que en el exe se mantiene vivo por el menu del form principal.
			thisform.CBM.KeepAlive = .t. && Esta propiedad hace que la instanciacion de los formularios tarde menos con respecto al menú.
		endif
		
		loMenuManager = newobject( 'MenuPrincipal', 'MenuPrincipal.prg' ) 
		with loMenuManager
			.cMenu = 'din_menuabm' + alltrim( this.ObtenerNombreEntidad() )
			.AgregarMenu( thisform ) 
			.Agregartoolbar( thisform ) 
		endwith

		with Thisform
			_screen.Zoo.App.AsignarClaveMenu()
			.CBM.InitCommandBars() 
			.oToolbar.Dock( 0, .oMenu.Left + .oMenu.Width, .oMenu.Top )
		endwith
		
		loMenuManager = null
	 endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDelInit() as Void
		local lnSolapa as Integer, lcSolapa as String   
		dodefault()
		if pemstatus( this,"pnlGrupos",5 ) 
			for lnSolapa = 1 to thisform.pnlGrupos.pagecount
				lcSolapa = "thisform.pnlGrupos.page" + alltrim(str( lnSolapa ))
				&lcSolapa..backcolor = thisform.backcolor
			endfor 	
		endif
	endfunc 

Enddefine
