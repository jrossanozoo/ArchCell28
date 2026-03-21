define class ServicioControles as Servicio of Servicio.prg

	#if .f.
		local this as zooColeccion of zooColeccion.prg
	#endif 

	lSeEstaEjecutandoValid = .f.
	ConChequeoDeRepeticiondeCodigoDejandoPasarElBlanco = .f.
	ConChequeoDeExistenciaDeCodigoDejandoPasarElBlanco = .f.
	nCantidadDeItemsDeDetallePorDefecto = .f.
	nPorcentajeVisualDeDetallePorDefecto = .f.
	cDescripcionUltimaLinea = .f.
	cIconoDefaultDeLosFormularios = .f.
	oDominios = null
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		this.oDominios = _screen.zoo.crearobjeto( "Dominios" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oDominios_Access() as Void
		if ( vartype( this.oDominios ) != 'O' or isnull( this.oDominios ) ) and !this.lDestroy
			this.oDominios = _screen.zoo.crearobjeto( "Dominios" )
		endif
		
		return this.oDominios
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEtiquetaSegunColumna( toControl as object ) as Void
		local lcRetorno as String
		lcRetorno = ""
		
		if pemstatus(toControl,"oItem",5)
			with toControl
				if .oItem.UsaEtiquetaLarga or empty( alltrim(.oItem.etiquetaCorta) )
					lcRetorno = this.ObtenerEtiquetaLarga(toControl)
				else
					lcRetorno = this.ObtenerEtiquetaCorta(toControl)
				endif
			endwith
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEtiquetaLarga( toControl as object ) as Void
		local lcRetorno as String
		lcRetorno = ""
		
		if pemstatus(toControl,"oItem",5)
			with toControl
				lcRetorno = alltrim(.oItem.etiqueta)
			endwith
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEtiquetaCorta( toControl as object ) as Void
		local lcRetorno as String
		lcRetorno = ""
		
		if pemstatus(toControl,"oItem",5)
			with toControl
				lcRetorno = alltrim(.oItem.etiquetaCorta)
			endwith
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SePuedeAjustar( toControl as Object ) as boolean
		local llRetorno as boolean
		llRetorno = .f.
		
		if pemstatus( toControl, "oItem", 5 ) and vartype( toControl.oItem ) = "O" and ;
			pemstatus( toControl.oItem, "Ajustable", 5 )
				
			llRetorno =	toControl.oItem.Ajustable
		endif	

		return llRetorno	
	endfunc 

	*-------------------------------------------------------------------------------------
	function GenerarControlesOrdenados( toControl as Object ) as collection
		local loRetorno as collection, loObjeto as object, lnColumna as Integer, lnFila as integer, ;
			lnMaxFila as Integer, lnMaxColumna as integer, lnItem as integer&&, llEsta

		loRetorno = null

		if pemstatus( toControl, "controls", 5 )
			loRetorno = newobject( "ItemControlesOrdenados" )

			lnMaxFila = 0
			lnMaxColumna = 0
			for each loObjeto in toControl.controls
				lnMaxFila = max( lnMaxFila, loObjeto.nFila )
				lnMaxColumna = max( lnMaxColumna, loObjeto.nColumna )
			endfor
			
			loRetorno.MaxColumna = lnMaxColumna + 1
			loRetorno.MaxFila = lnMaxFila + 1
			
			for lnFila = 0 to lnMaxFila
				for lnColumna = 0 to lnMaxColumna
					lnItem = 1
					do while lnItem <= toControl.controlcount 
						loObjeto = toControl.controls[ lnItem ]
						
						if lnColumna = loObjeto.nColumna and lnFila = loObjeto.nFila
							loRetorno.add( loObjeto )
						endif
						lnItem = lnItem + 1
					enddo
				endfor
			endfor
		endif
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------
	function ObtenerTipoSubGrupo( toControl as Object ) as integer
		local lnRetorno as integer

		lnRetorno = 0
		if vartype(toControl.oItem) = "O" and pemstatus(toControl.oItem, "TipoSubGrupo", 5)
			lnRetorno = toControl.oItem.TipoSubGrupo
		endif
		
		if between( lnRetorno, 1, 3 )
		else
			This.AgregarInformacion( "Se ha encontrado un grupo con tipo erróneo" )
			goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
		endif
		
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionSubGrupo( toControl as Object ) as string
		local lcRetorno as String, loError as Exception, loEx as Exception

		try 
			lcRetorno = toControl.oItem.DescripcionSubGrupo
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		Finally
		EndTry
		
		return lcRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------	
	function SePuedeOrdenar( toControl as Object ) as Boolean
		local llRetorno as boolean
	
		llRetorno = .f.
		if pemstatus(toControl, "lSePuedeOrdenar", 5)
			llRetorno = toControl.lSePuedeOrdenar
		endif
		
		return llRetorno
	endfunc

	*-------------------------------------------------------------------------------------------------	
	function SePuedeAcomodar( toControl as Object ) as Boolean
		local llRetorno as boolean
	
		llRetorno = .t.
		if pemstatus(toControl, "lSePuedeAcomodar", 5)
			llRetorno = toControl.lSePuedeAcomodar
		endif
		
		return llRetorno
	endfunc

	*-------------------------------------------------------------------------------------------------	
	function TieneSaltoCampo( toControl as Object ) as Boolean
		local llRetorno as boolean
	
		llRetorno = .f.
		if pemstatus(toControl, "lSaltoCampo", 5)
			llRetorno = toControl.lSaltoCampo
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsUnControlSeteable( toCtrl as object ) as boolean
		local llRetorno as boolean
		
		llRetorno = .f.

		if PEMSTATUS( toCtrl, 'lesSeteable', 5)
			llRetorno = toCtrl.lEsSeteable
			if llretorno and PEMSTATUS( toCtrl, 'ltienesaltocampo', 5)
				llretorno = !toCtrl.ltienesaltocampo
			endif 
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsUnControlSeteableInternamente( toCtrl as object ) as boolean
		local llRetorno as boolean
		
		llRetorno = .f.

		if PEMSTATUS( toCtrl, 'lEsSeteableInternamente', 5)
			llRetorno = toCtrl.lEsSeteableInternamente
		endif
		
		return llRetorno
	endfunc


	*-----------------------------------------------------------------------------------------
	function EsUnContenedorSeteable( loCtrl as Object ) as boolean
		local llRetorno as Boolean
		
		llRetorno = .f.
				
		if PEMSTATUS(loCtrl, 'ControlCount', 5)
			if PEMSTATUS(loCtrl, 'lEsHabilitable', 5)
				llRetorno = loCtrl.lEsHabilitable
			endif
		else
			llRetorno = .t.
		endif
		 
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEvento( toFormulario as Form, toControl as Object, tcOrigen as String, tcMetodoOrigen as String , tcMetodoDestino as String, tnFlag as Boolean ) as Void
		local lnFilas as Integer
		lnFilas = 1
		
		with toControl
			if isnull( .aEventos )
			else
				lnFilas = alen( .aEventos, 1 ) + 1
			endif

			dimension toControl.aEventos( lnFilas, 5 )

			.aEventos[ lnFilas, 1 ] = tcOrigen
			if left( tcOrigen, 1 ) != "."
				if left( lower( tcOrigen ), 8 ) != "thisform"
					.aEventos[ lnFilas, 1 ] = "." + tcOrigen
				endif
			endif

			.aEventos[ lnFilas, 2 ] = tcMetodoOrigen

			.aEventos[ lnFilas, 3 ] = ""

			.aEventos[ lnFilas, 4 ] = tcMetodoDestino
			.aEventos[ lnFilas, 5 ] = tnFlag
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEventoGenerico( toControl as Object, tcObjetoOrigen as String, tcMetodoOrigen as String, tcObjetoDestino as String, tcMetodoDestino as String, tnFlag as Boolean ) as Void
		local lnFilas as Integer
		lnFilas = 1
		
		with toControl
			if isnull( .aEventos )
			else
				lnFilas = alen( .aEventos, 1 ) + 1
			endif

			dimension toControl.aEventos( lnFilas, 5 )

			.aEventos[ lnFilas, 1 ] = tcObjetoOrigen 
			.aEventos[ lnFilas, 2 ] = tcMetodoOrigen
			.aEventos[ lnFilas, 3 ] = tcObjetoDestino 
			.aEventos[ lnFilas, 4 ] = tcMetodoDestino
			.aEventos[ lnFilas, 5 ] = tnFlag
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Buscar( toForm as form, toControl as Object, tcSigno as String, ;
						tcString as string, tlClaveCandidata as Boolean ) as Boolean 

		local lcolBusqueda as object, loFormBusqueda as form, loError as Exception, llClosable as Boolean, llFormClosableOld as Boolean

		try
			_screen.zoo.app.SetearEstadoMenuPrincipal( .F. ) 
			llClosable = this.SetearClosableFormularioPrincipalPrincipal(.f.)
			
			if pemstatus( toForm, "oKontroler", 5 ) and vartype( toForm.oKontroler ) = "O"
				&&Es muy importante setear estas propiedades del menu principal y el Closable del formprincipal.
				toForm.oKontroler.SetearEstadoMenuYToolBar( .f. )
			endif

			lColBusqueda = toControl.oEntidad.oAD.ObtenerObjetoBusqueda()

			this.SetearValorControlVisual( toControl )
			toControl.oEntidad.AjustarObjetoBusqueda( lColBusqueda )		
			if vartype( toForm.oEntidad ) = "O"
				loFormBusqueda = this.ObtenerFormulario( lcolBusqueda, tcSigno, tcString, toControl, tlClaveCandidata, toForm.oEntidad )
			Else	
				loFormBusqueda = this.ObtenerFormulario( lcolBusqueda, tcSigno, tcString, toControl, tlClaveCandidata )
			Endif	
			
			if vartype(loFormBusqueda) = "O"
				llFormClosableOld = toForm.Closable
				toForm.Closable = .F.
				loFormBusqueda.show( 1 )
				toForm.Closable = llFormClosableOld
				
				if empty( toControl.value )
					if !(empty( toControl.xValorAnterior ) or isnull(toControl.xValorAnterior))
						toControl.value = toControl.TransformarValorParaObtener( toControl.xValorAnterior )
					else
						toControl.value = toControl.TransformarValorParaObtener( toControl.value )				
					endif
				else
					toControl.value = toControl.TransformarValorParaObtener( toControl.Value )
				endif
				
			else
				toControl.value = ""
			endif
		
			if pemstatus( toForm, "oKontroler", 5 ) and vartype( toForm.oKontroler ) = "O"
				toForm.oKontroler.SetearEstadoMenuYToolBar( .t. )
			endif
		catch to loError
			throw loError
		finally
			
			_screen.zoo.app.SetearEstadoMenuPrincipal( .t. ) 
			this.SetearClosableFormularioPrincipalPrincipal(llClosable)
		endtry
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearValorControlVisual( toControl as Object ) as Void
		toControl.value = ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFormulario( tcolBusqueda as collection, tcSigno as string, tcString as string, ;
					toControl as Object, tlClaveCandidata as Boolean, toEntidadPrincipal as Object ) as object
		local lcTipoBuscador,lcTipoBusqueda 
		lcTipoBuscador = "Buscadorv7.vcx"
		lcTipoBusqueda = tcSigno

		if vartype( toControl.lTeclaAccesoBuscadorEspecifico ) = "L" .And. toControl.lTeclaAccesoBuscadorEspecifico
			if upper( toControl.cBuscador ) != "BUSCADORCOMPROBANTESENPICKING.VCX"
				toControl.lTeclaAccesoBuscadorEspecifico = .F.
			endif			
			if !empty(toControl.cBuscador)
				lcTipoBuscador = toControl.cBuscador
			endif
			if !inlist(upper(toControl.cBuscador), "BUSCADORNUEVOENBASEASUBENTIDAD.VCX","BUSCADORNUEVOENBASEANUMERO.VCX","BUSCADORCOMPROBANTESENPICKING.VCX")
				lcTipoBusqueda = "??" 
			endif
		endif
		
		return _Screen.Zoo.CrearObjetoPorProducto("buscador", lcTipoBuscador, tcolBusqueda, lcTipoBusqueda, tcString, toControl, tlClaveCandidata, toEntidadPrincipal )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar( toControl as Object, toForm as Object ) as integer
		local lnRetorno as Integer, lxValor as Variant, lcValidarAntesDeSetear as String, ;
			lcValidarDespuesDeSetear as String, lcProcesarDespuesDeValidar as String, ;
			llValidarSegunEstado as Boolean, lcDespuesDelValid as String

		this.lSeEstaEjecutandoValid = .t.
		
		lcValidarAntesDeSetear = this.ObtenerFirmaHoock( toControl, "toForm.oKontroler", "ValidarAntesDeSetear" )
		lcValidarDespuesDeSetear = this.ObtenerFirmaHoock( toControl, "toForm.oKontroler", "ValidarDespuesDeSetear" )
		lcProcesarDespuesDeValidar = this.ObtenerFirmaHoock( toControl, "toForm.oKontroler", "ProcesarDespuesDeValidar" )
		lcDespuesDelValid = this.ObtenerFirmaHoock( toControl, "toForm.oKontroler", "DespuesDelValid" )
		llValidarSegunEstado = .t.
		lnRetorno = 0
		llSigue = .t.

		if  inlist( upper( alltrim( toForm.oKontroler.cAccion ) ) , "CANCELAR", "SIGUIENTE", "ANTERIOR", "ULTIMO", "PRIMERO", "NULO",  "ESCAPAR") 
			llValidarSegunEstado = .F.
		endif 

		if llValidarSegunEstado 
			with toControl
				llEjecutaValid =  !.lValidaSoloSiModifico or ( isnull( .xValorAnterior ) or .Value # .xValorAnterior ) ;
									or ( ( pemstatus( toControl, "lClavePrimaria", 5 ) and pemstatus( toControl, "cDominio", 5 ) ) and;
											 .lClavePrimaria and upper( alltrim( .cDominio ) ) == "CODIGO" and empty( .Value ) )

				if llEjecutaValid

					**** Validacion previa al seteo del atributo
					if .ValidarAntesDeSetearAtributo() and &lcValidarAntesDeSetear
						lxValor = .TransformarValorParaSetear( .Value )

						Try
							.SetearValorEnElAtributo( lxValor )
						Catch To loError
							loEx = Newobject( "ZooException", "ZooException.prg" )
							With loEx
								.Grabar( loError )
								goMensajes.Enviar( loEx )
							EndWith

							llSigue = .f.
						Finally
						EndTry

						**** Validacion posterior al seteo del atributo (Por ejemplo: Verificar Existencia.
						if llSigue and .ValidarDespuesDeSetearAtributo() and &lcValidarDespuesDeSetear
							lnRetorno = toControl.ObtenerProximoControl()
						endif
					endif

					if llSigue
						**** Ejecucion de codigo (kontroler) luego del ValidarDespuesDeSetearAtributo
						if &lcProcesarDespuesDeValidar
						else
							lnRetorno = 0
						endif

						**** Ejecucion de codigo (visual) luego de validacion. Por ejemplo: Buscar.
						*    El metodo del Kontroler recibe el valor de la validacion del verificar existencia

						if .DespuesDelValid( lnRetorno )
						else
							lnRetorno = 0
						endif
						
						**** Ejecucion de codigo (kontroler) luego de finalizada la validacion
						if &lcDespuesDelValid
						else
							lnRetorno = 0
						endif
					endif
				else
					lnRetorno = toControl.ObtenerProximoControl()
				endif
			endwith
		else
			if upper( alltrim( toForm.oKontroler.cAccion ) ) == "ESCAPAR"
				lnRetorno = 0
			else
				lnRetorno = toControl.ObtenerProximoControl()
			endif
		endif

		lnRetorno = this.ResolverRetornoParaGrilla( toControl, lnRetorno )
				
		this.lSeEstaEjecutandoValid = .f.
		
		return lnRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResolverRetornoParaGrilla( toControl as object, tnRetorno as Integer ) as integer
		*** Esto deberia llamarse desde los controles de la grilla para no ensuciar el servicio controles
		if toControl.lDetalle and !empty( toControl.parent.cScroleo ) and tnRetorno # 0
			tnRetorno = toControl.parent.scrolear( tnRetorno , toControl )
		endif
		
		return tnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFirmaHoock( toControl as object, tcObjetoDelHocck as string, tcNombreFuncion as String, tcParametros as string ) as String
		local lcCadena as String

		lcCadena = this.ArmarMacroSustitucionHoock( toControl, tcObjetoDelHocck, tcNombreFuncion )
		
		with toControl
			do case
				case upper( tcNombreFuncion ) = upper( "ValidarAntesDeSetear" )
					lcCadena = lcCadena + "( toControl )"

				case upper( tcNombreFuncion ) = upper( "ProcesarDespuesDeValidar" )
					lcCadena = lcCadena + "( lnRetorno # 0 )"

				case empty( tcParametros )
					lcCadena = lcCadena + "()"

				otherwise
					lcCadena = lcCadena + "( " + tcParametros + " )"
			endcase
		endwith
			
		return lcCadena
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarNombreHoock( toControl as object, tcObjetoDelHocck as string, tcNombreFuncion as String ) as String
		local lcCadena as String
		
		lcCadena = this.ArmarMacroSustitucionHoock( toControl, tcObjetoDelHocck, tcNombreFuncion )
			
		lcCadena = right( lcCadena, len( lcCadena ) - rat( ".", lcCadena ) )
		
		return lcCadena
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarMacroSustitucionHoock( toControl as object, tcObjetoDelHocck as string, tcNombreFuncion as String ) as String
		local lcCadena as String
		
		if empty( tcObjetoDelHocck )
			lcCadena = alltrim( tcNombreFuncion )
		else
			lcCadena = tcObjetoDelHocck + "." + alltrim( tcNombreFuncion )
		endif

		with toControl
			if this.EsControlDentroDeGrilla( toControl )
				lcCadena = lcCadena  + "_" + alltrim( .Parent.cAtributo )
			endif
		
			if pemstatus( toControl, "cAtributoPadre", 5 ) and !empty( .cAtributoPadre )
				lcCadena = lcCadena + "_" +  alltrim( .cAtributoPadre )
			endif
			
			if pemstatus( toControl, "cAtributo", 5 ) and !empty( .cAtributo )
				lcCadena = lcCadena + "_" + alltrim( .cAtributo )
			endif
		endwith
			
		return lcCadena
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EjecutarHoock( toControl as object, toObjetoHoock as object, tcNombreFuncion as String, tcParametros as string ) as variant
		local lcHoockPerderFoco as String, lxRetorno as variant
		
		lxRetorno = null

		lcHoockPerderFoco = this.ArmarNombreHoock( toControl, "", tcNombreFuncion )
		if pemstatus( toObjetoHoock, lcHoockPerderFoco, 5 )
			lcHoockPerderFoco = this.ObtenerFirmaHoock( toControl, "", tcNombreFuncion, tcParametros )
			lxRetorno = toObjetoHoock.&lcHoockPerderFoco
		endif
		
		return lxRetorno 
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function EsControlDentroDeGrilla( toControl as object ) as Void
		return pemstatus( toControl, "lDetalle", 5 ) and toControl.lDetalle and inlist( upper( toControl.parent.class ), "ZOOGRILLAEXTENSIBLE", "GRILLAEXTCOMPECOMMERCE" ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Actualizar( toControl as Object ) as Void
		local lxValor as Variant

		with toControl
			lxValor = .ObtenerValorDelAtributo()
			.Value = .TransformarValorParaObtener( lxValor )
			if pemstatus( tocontrol, "xValorAnterior",5 )
				toControl.xValorAnterior = .value 
			endif 
			This.SetearMascara( toControl , "desactivar" )
			.refresh()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCaracteresEspeciales( tnKey as Integer ) as Boolean
		local llRetorno as Boolean
		local array laCaracteresValidos[ 35 ]
		llRetorno = .f.
		
		laCaracteresValidos[ 1 ] = 28
		laCaracteresValidos[ 2 ] = -1
		laCaracteresValidos[ 3 ] = -2
		laCaracteresValidos[ 4 ] = -3
		laCaracteresValidos[ 5 ] = -4
		laCaracteresValidos[ 6 ] = -5
		laCaracteresValidos[ 7 ] = -6
		laCaracteresValidos[ 8 ] = -7
		laCaracteresValidos[ 9 ] = -8
		laCaracteresValidos[ 10 ] = -9
		laCaracteresValidos[ 11 ] = 133
		laCaracteresValidos[ 12 ] = 134
		laCaracteresValidos[ 13 ] = 22
		laCaracteresValidos[ 14 ] = 1
		laCaracteresValidos[ 15 ] = 7
		laCaracteresValidos[ 16 ] = 6
		laCaracteresValidos[ 17 ] = 18
		laCaracteresValidos[ 18 ] = 3
		laCaracteresValidos[ 19 ] = 5
		laCaracteresValidos[ 20 ] = 24
		laCaracteresValidos[ 21 ] = 4
		laCaracteresValidos[ 22 ] = 19
		laCaracteresValidos[ 23 ] = 13
		laCaracteresValidos[ 24 ] = 127
		laCaracteresValidos[ 25 ] = 9
		laCaracteresValidos[ 26 ] = 32
		*** SHIFT
		laCaracteresValidos[ 27 ] = 55
		laCaracteresValidos[ 28 ] = 49
		laCaracteresValidos[ 29 ] = 57
		laCaracteresValidos[ 30 ] = 51
		laCaracteresValidos[ 31 ] = 56
		laCaracteresValidos[ 32 ] = 50
		laCaracteresValidos[ 33 ] = 54
		laCaracteresValidos[ 34 ] = 52
		laCaracteresValidos[ 35 ] = 15
		
		llRetorno = ascan( laCaracteresValidos, tnKey ) > 0
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	* GotFocus de los controles visuales (textbox, editbox, checkbox, combobox )
	function ObtenerFoco( toControl as Object, toForm as object ) as Void
			
		with toControl
			if !.ReadOnly and .enabled
				.ForeColor 	= .nForeColorConFoco
			endif
			.BackColor 	= .nBackColorConFoco
					
			this.SetearMascara( toControl , "activar" )
		
			if vartype( toForm.oKontroler ) == "O" and pemstatus( toControl, "ObtenerAyuda",5 )
				toForm.oKontroler.SetearAyuda( .ObtenerAyuda() )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	* LostFocus de loc controles visuales (textbox, editbox, checkbox, combobox )
	function PerderFoco( toControl as Object, toForm as object ) as Void
		local lcHoockPerderFoco as String
		
		This.SetearColoresEnControl( toControl )
		This.SetearMascara( toControl , 'desactivar' )
		
		clear typeahead 

		if this.lSeEstaEjecutandoValid
		else
			toForm.SetearUltimaTecla( 0, 0 )
			if vartype( toForm.oKontroler ) == "O"
				toForm.oKontroler.SetearAyuda( "" )
			
				this.EjecutarHoock( toControl, toForm.oKontroler, "PerderFoco", "toControl")
			endif
		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearColoresEnControl( toControl as Object ) as Void

		with toControl 
          if ((pemstatus( tocontrol, 'lEsObligatorio', 5 ) and .lEsObligatorio) or ;
             (pemstatus( tocontrol, 'lClavePrimaria', 5 ) and .lClavePrimaria) and ;
              pemstatus( tocontrol, 'cClaveForanea', 5 ) and empty( .cClaveForanea ) ) and ;
                !.lDetalle and empty( .Value )
				
				.ForeColor = .nForeColorObligSinFoco 
				.BackColor = .nBackColorObligSinFoco
			else
				.ForeColor = .nForeColorSinFoco
				.BackColor = .nBackColorSinFoco	
			endif 						
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstablecerObligatoriedadDeControl( toControl as Object ) as Void
		if pemstatus( toControl, "lEsObligatorio", 5 )
			toControl.lEsObligatorio = .T.
		else
			toControl.addProperty( "lEsObligatorio", .T. )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstablecerObligatoriedadSiNoDeControl( toControl as Object, tlValor as Boolean ) as Void
		if pemstatus( toControl, "lEsObligatorio", 5 )
			toControl.lEsObligatorio = tlValor 
		else
			toControl.addProperty( "lEsObligatorio", tlValor  )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearMascara( toControl as Object, tcAccion as String ) as Void

		if empty( tcAccion ) or vartype( tcAccion ) != 'C' or !inlist( upper( alltrim( tcAccion ) ), "ACTIVAR", "DESACTIVAR" )
			return 
		endif 

		with toControl 
			if pemstatus( toControl, "InputMask", 5 ) and pemstatus( toControl, "cMascara", 5 ) ;
					and !empty( .cMascara )

				if pemstatus( toControl, "cMascaraDinamica", 5 ) and !empty( .cMascaraDinamica )
					.cMascara = evaluate( .cMascaraDinamica )
				endif
				

				if upper( alltrim( tcAccion ) ) = "ACTIVAR"
					.InputMask	= .cMascara					
				else 	
					
					if  !empty( .Value ) or ;
						( type( "_screen.ActiveForm.ActiveControl" ) = "O" and _screen.ActiveForm.ActiveControl = toControl )
						
						.InputMask 	= .cMascara
					else
						.InputMask	= ""
					endif 
				endif 
			endif 
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsValorVacio( txValor as Variant , tcMascara as String ) as Boolean
		
		local llRetorno as boolean
		
		llRetorno = .f.
		
		do case
			case  empty( txValor )
				llRetorno = .T.		
		
			case  strtran( tcMascara , '9', ' ' ) = txValor 
				llRetorno = .T.		
		endcase 
		
		return llRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	* ObtenerProximoControl de los zoo controles visuales (zootextbox, zooeditbox, zoocheckbox, zoocombobox )
	function ObtenerProximoControl( toForm as object ) as Void
		local lnRetorno as integer, lnKeyCode as integer, lnShiftAltCtrl as integer

		lnKeyCode = toForm.nKeyCode
		lnShiftAltCtrl = toForm.nShiftAltCtrl

		lnRetorno = 1

		if lnKeyCode = 18 or lnKeyCode = 5 or lnKeyCode = 19 or ( ( lnKeyCode = 15 or lnKeyCode = 9 ) and lnShiftAltCtrl = 1 ) &&FLECHA ARRIBA o FLECHA IZQUIERDA o TABULACION IZQUIERDA
			lnRetorno = -1
		else
			if lnKeyCode = 300
				lnRetorno = 0
			endif
		endif
		
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerModoDeComportamiento( tcModo as String ) as integer
		if empty( this.&tcModo )
			this.&tcModo = goRegistry.Dibujante.ModoDeComportamiento.&tcModo
		endif		
		
		return this.&tcModo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeItemsDeDetallePorDefecto() as Void
		if empty( this.nCantidadDeItemsDeDetallePorDefecto )
			this.nCantidadDeItemsDeDetallePorDefecto = goRegistry.Nucleo.CantidadDeItemsDeDetallePorDefecto
		endif		
		
		return this.nCantidadDeItemsDeDetallePorDefecto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPorcentajeVisualDeDetallePorDefecto() as Void
		if empty( this.nPorcentajeVisualDeDetallePorDefecto )
			this.nPorcentajeVisualDeDetallePorDefecto = goRegistry.Dibujante.zooGrillaExtensible.PorcentajeVisualDeDetallePorDefecto
		endif		
		
		return this.nPorcentajeVisualDeDetallePorDefecto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionUltimaLinea() as Void
		if empty( this.cDescripcionUltimaLinea )
			this.cDescripcionUltimaLinea = alltrim( goRegistry.Dibujante.zooGrillaExtensible.DescripcionUltimaLinea )
		endif		
		
		return this.cDescripcionUltimaLinea
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIconoDefaultDeLosFormularios() as Void
		if empty( this.cIconoDefaultDeLosFormularios )
			this.cIconoDefaultDeLosFormularios = alltrim( goRegistry.Dibujante.IconoDefaultDeLosFormularios )
		endif		
		
		return this.cIconoDefaultDeLosFormularios
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearClosableFormularioPrincipalPrincipal( tlHabilitado as Boolean ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if type( "_Screen.zoo.app.oFormPrincipal" ) == "O" and !isnull( _Screen.zoo.app.oFormPrincipal )
			llRetorno = _Screen.zoo.app.oFormPrincipal.Closable
			_Screen.zoo.app.oFormPrincipal.Closable = tlHabilitado
		endif
		
		return llRetorno
	endfunc 
		
enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemControlesOrdenados as zooColeccion of zooColeccion.prg
	MaxColumna = 0
	MaxFila = 0
enddefine

