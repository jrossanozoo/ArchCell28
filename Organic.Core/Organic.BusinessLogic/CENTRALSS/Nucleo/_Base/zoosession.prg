Define Class ZooSession As Session

	#IF .f.
		Local this as ZooSession of ZooSession.prg
	#ENDIF

	protected oLogueo, oInformacion, cFormatoFechaNet, lEsExe
	lDesarrollo = .f.
	lDestroy = .f.
	oLogueo = null
	oInformacion = null
	cFormatoFechaNet = ""
	lLogueoPropio = .T.
	lLoguear = .T.
	lEsExe = .f.
	lNoLoguearRestAPI = .F.
	lNoCheckSessionOpen = .f. && para omitir el objeto del analisis de sessiones abiertas de test de foxunit
	
	*-------------------------------------------------------------------
	Function Init() as Void
		This.SeteosPrivados()	
		this.lDesarrollo = EsIyD()
		this.lEsExe = ( _vfp.StartMode == 4 )
	endfunc

	*-------------------------------------------------------------------
	Function SeteosPrivados() as Void 
		ConfigurarSeteosPrivadosDeLaSesion()
		This.cFormatoFechaNet = "dd/MM/yyyy"
	Endfunc

	*-----------------------------------------------------------------------------------------
	function BuscarClase( tcClase as String ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = .f.

		this.Crear_oClases()
		
		if _screen.oClases.GetKey( sys(2007, alltrim( lower( tcClase )),0,1)) > 0
			llRetorno = .t.
		else
			if this.ExisteArchivoClase( tcClase )
				this.AgregarClaseAColeccion( tcClase )
				llRetorno = .t.
			endif
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteArchivoClase( tcFile as String ) as Boolean 
		local llRetorno as Boolean 
		
		llRetorno = .f.
		
		if _VFP.StartMode = 5 and !_screen.zoo.EsBuildAutomatico &&and "FOXEXTENDER" $ upper( sys( 16 ) )
			try
				do ( tcFile ) 
				llRetorno = .t.
			catch
			endtry
		else
			llRetorno = file( tcFile )
		endif
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarClaseAColeccion( tcClase as String ) as Void
		if !alltrim( upper( "mock" ) )$alltrim( upper( tcClase ) )
			_screen.oClases.Add( tcClase, sys(2007, alltrim( lower( tcClase )),0,1))
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Crear_oClases() as Void
		if !pemstatus( _screen, "oClases", 5 )	
			_screen.AddObject( "oClases", "Collection" )
		endif
		
		if !vartype( _screen.oClases ) = 'O' and isnull( _screen.oClases )
			_screen.oClases = newobject( "Collection" )
		endif
	endfunc 

	*-------------------------------------------------------------------
	Function CrearObjeto( tcClase as String, tcLibreria as string, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant )

		Local loReturn As Object, lnParametrosReales As Integer, lcClase as String, lcConstructor as string, lcComando as String, ;
			lnParamAux as Integer, lcClase as String, lcLibreria as String , lcSetProcedure as String,;
			loErrorBase as Exception, loEx as Exception, loRetorno as object, lcConstructor as String, lcProcedure as String,;
			lcSetClassLib as String, lcSet as String, loMock as Object, lcClaseProxy as String 
			
		loReturn = Null
		lcLibreria = tcLibreria
		lcClaseProxy = ""
		
		*-------------------------------------------------------------------
		if pemstatus(_screen, "Mocks", 5 ) and vartype( _Screen.Mocks ) = "O"	
			*Instanciación de Mocks
			*Objeto solo instanciado en DESARROLLO.
			if _screen.Mocks.lUtilizarMockV2 and this.buscarClase( forceext( "MockV2_" + tcClase, "prg" ) )
				lcClase = "MockV2_" + tcClase
			else
				if _screen.Mocks.lUtilizarMockV1
					local lnItem as Integer
					lcClase = this.ObtenerNombreClase( tcClase )
					lnItem = _Screen.Mocks.BuscarMock( lcClase )
					
					if !empty( lnItem )
						loMock = _Screen.Mocks.Item[lnItem]
						loMock.lUsado = .t.

						lcClase = loMock.cNombreClaseMock
						
						if empty( loMock.cNombrePrgMock )
							lcLibreria = iif( empty( lcLibreria ), "", "Mock_" + justfname( lcLibreria ) )
						else
							lcLibreria = loMock.cNombrePrgMock
						endif
					else
						lcClase = tcClase
					endif
				else
					lcClase = tcClase
				endif
			endif
		else
			lcClase = tcClase
		endif
		*-------------------------------------------------------------------

		If empty( lcLibreria )
			lcLibreria = forceext( lcClase, "prg" )
		endif
		
		If Pcount() > 1
			lnParamAux = 2
		Else
			lnParamAux = 1
		EndIf

		lnParametrosReales = Pcount() - lnParamAux	

		loRetorno = null
		
		try
			if this.EsClaseNet( lcClase )
				if !pemstatus( _screen, "NetExtender", 5 )
					goServicios.Errores.LevantarExcepcion( "Para instanciar un objeto net debe haber iniciado la aplicación." )
				endif
				lcComando = this.ObtenerSentenciaConDesgloseParametros( "ClrCreateObject", lcClase, "", "", lnParametrosReales )
				loRetorno = this.CrearObjetoNet( lcComando, tvPar1, tvPar2, tvPar3, tvPar4, tvPar5, tvPar6, tvPar7, tvPar8 )
			else

				lcClase = justfname( lcClase )
				
				if lnParametrosReales = 0 and vartype( _Screen.Zoo ) = "O" and !isnull( _Screen.Zoo ) and !isnull( _screen.Zoo.oConstructor )
					lcClaseProxy = _screen.Zoo.oConstructor.ObtenerNombreClaseProxy( lcClase, lcLibreria )
				endif

				if !empty( lcClaseProxy )
					loRetorno = _screen.Zoo.oConstructor.CrearObjeto( lcClaseProxy, set( "Datasession" ) )
				else
					lcSetProcedure = set('Procedure')
					lcSetClassLib = set("Classlib")			
				
					if upper( justext( lcLibreria )) = "VCX"
						lcSet  = "SET CLASSLIB TO "
					else
						lcSet = "SET PROCEDURE TO "
					endif			
					
					if this.lEsExe and upper( justext( lcLibreria ) ) == "PRG"
						&& En el Exe solo se pueden instanciar los archivos FXP, si no se fuerza la extensión recorre todo el path buscando el PRG.
						lcLibreria = forceext( lcLibreria, "fxp" )
						lcProcedure = lcLibreria
					else
						lcProcedure = forceext( lcLibreria, "" )
					endif		
					
					lcSet = lcSet + "'" + lcProcedure + "'"					
					if this.BuscarClase( lcLibreria ) 
						&lcSet
					endif
														
					if lnParametrosReales > 0
						lcComando = this.ObtenerSentenciaConDesgloseParametros( "NewObject", lcClase, lcLibreria , "", lnParametrosReales )
						loRetorno = &lcComando
					else
						loRetorno = newobject( lcClase, lcLibreria )
					endif
				
					if !(lower(lcSetClassLib) == lower(set("Classlib")))
						set classlib to &lcSetClassLib
					endif	
					set procedure to &lcSetProcedure

				endif

			endif

		Catch To loErrorBase	
			local lnError as Integer
			lnError = 0			
			if loErrorBase.ErrorNo = 1 and left( lower( lcLibreria ), 4 ) == "din_"
				do case
					case !this.BuscarClase( strtran( lower( lcLibreria ), ".prg", ".fxp" ) )
						lnError = 10
					case !this.BuscarClase( lcLibreria ) 
						lnError	= 20
				endcase
			endif
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loErrorBase )
				.nZooErrorNo = lnError
				.Throw()
			EndWith
		EndTry

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function EsClaseNet( tcClase as String ) as boolean
		return "." $ tcClase
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsClaseBase( tcClase as String, tcLibreria as String ) as Boolean
		return ( upper( alltrim( tcClase ) ) == "ZOOCOLECCIONPROXY" ) or upper( alltrim( tcClase ) ) == "ZOOCOLECCION" and upper( alltrim( tcClase ) ) == upper( alltrim( juststem( tcLibreria ) ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarReferencia( tcAssembly as String ) as Void
		_screen.NetExtender.AgregarReferencia( tcAssembly )
		_screen.DotNetBridge.AgregarReferencia( tcAssembly )
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function CrearObjetoNET( tcComando as string, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant ) as variant
		return _screen.NetExtender.EjecutarComando( tcComando, tvPar1, tvPar2, tvPar3, tvPar4, tvPar5, tvPar6, tvPar7, tvPar8 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function InvocarMetodoEstatico( tcClase as String, tcMetodo as String, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant ) as Variant
		local lcComando as String
		lcComando = this.ObtenerSentenciaConDesgloseParametros( "CLRInvokeStaticMethod", alltrim( tcClase ) + "', '" + alltrim( tcMetodo ), "", "", pcount() -2 )
		return _screen.NetExtender.EjecutarComando( lcComando, tvPar1, tvPar2, tvPar3, tvPar4, tvPar5, tvPar6, tvPar7, tvPar8 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorPropiedadEstatica( tcClase as String, tcPropiedad as String ) as Variant
		local lcComando as String
		lcComando = this.ObtenerSentenciaConDesgloseParametros( "CLRInvokeStaticMethod", alltrim( tcClase ) + "', '" + alltrim( "Get_" + tcPropiedad ), "", "", pcount() -2 )
		return _screen.NetExtender.EjecutarComando( lcComando )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearValorPropiedadEstatica( tcClase as String, tcPropiedad as String, tvPar1 as Variant ) as Variant
		local lcComando as String
		lcComando = this.ObtenerSentenciaConDesgloseParametros( "CLRInvokeStaticMethod", alltrim( tcClase ) + "', '" + alltrim( "Set_" + tcPropiedad ), "", "", pcount() -2 )
		return _screen.NetExtender.EjecutarComando( lcComando, tvPar1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function ObtenerSentenciaConDesgloseParametros( tcComando as string, tcClase as string, tcLibreria as String, tcApp as String, tnParametros as Integer )
		local lcRetorno as string, lni as integer, lcLibreria as string, lcApp as string
		
		if empty( tcLibreria )
			lcLibreria = ""
		else
			lcLibreria = alltrim( tcLibreria )
		endif
		
		if empty( tcApp )
			lcApp = ""
		else
			lcApp = alltrim( tcApp )
		endif

		if inlist( upper( tcComando ), "CLRCREATEOBJECT", "CLRINVOKESTATICMETHOD" )
			lcRetorno = tcComando + "( '" + tcClase + "'"
		else
			if empty( tnParametros ) and empty( tcApp )
				lcRetorno = tcComando + "( '" + tcClase + "', '" + lcLibreria + "'"
			else
				lcRetorno = tcComando + "( '" + tcClase + "', '" + lcLibreria + "', '" + tcApp + "'"
			endif
		endif
		
		for lni = 1 to tnParametros
			lcRetorno = lcRetorno + ", tvPar" + transform( lni )
		endfor
		lcRetorno = lcRetorno + " )"

		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function ObtenerNombreClase( tcClase ) as String
		Local lcRetorno as String, lcNombreApp as String

		if upper( substr( alltrim( tcClase ), len( alltrim( tcClase ) ) - 1 ) ) = "UO"
			if !this.lEsExe and this.BuscarClase( alltrim( tcClase ) + "UO.prg" )
				lcRetorno = strtran( tcClase, "Din_","" ,1 ,1 )
			else 
				lcRetorno = tcClase
			endif 
		else 
			if type( "_screen.zoo.app.cProyecto" ) = "C"
				lcNombreApp = upper( _screen.zoo.app.cProyecto )
			else
				lcNombreApp = ""
			endif
				
			do case
				case upper( left( tcClase, 4 ) ) = "ENT_"
					lcRetorno = strtran( upper( tcClase ), "ENT_","" ,1 ,1 )

				case upper( left( tcClase, 4 + len( lcNombreApp ) ) ) = "ENT" + lcNombreApp + "_"
					lcRetorno = strtran( upper( tcClase ), "ENT" + lcNombreApp + "_", "", 1 ,1 )

				case upper( left( tcClase, 11 ) ) = "DIN_ENTIDAD"
					lcRetorno = strtran( tcClase, "Din_Entidad","" ,1 ,1 )

				otherwise
					lcRetorno = strtran( tcClase, "Din_","" ,1 ,1 )
			endcase
		endif 

		return lcRetorno
	endfunc 

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
	function Destroy()
		local lnCantidad as Integer, laPropiedades as array, lnTablaActual as Integer,;
		lnInd as Integer, lcPropiedad as String, lcEliminaReferencia as String    
		dimension laPropiedades(1)

		this.lDestroy = .t.
		this.FinalizarLogueo()
		lnCantidad = Amembers( laPropiedades,this,0,"UG+" )
		this.Finalizar()
		for lnInd = 1 to lnCantidad
			lcPropiedad = "this."+ alltrim( laPropiedades[lnInd] )
			if vartype( evaluate( lcPropiedad ) ) = "O"
				if pemstatus(&lcPropiedad,"release",5)
					lcEliminaReferencia = lcPropiedad + ".release"
					&lcEliminaReferencia
				endif
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------	
	function Finalizar()
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

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		*this.Destroy() se llama con el release this automaticamente
		release this 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Loguear( tcTexto as String, tnNivel as Integer ) as Void
		if This.lLoguear and this.Sedebeloguear()
			if  vartype( goServicios ) = 'O'
				this.oLogueo.Escribir( tcTexto, tnNivel )
			endif
		EndIf
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FinalizarLogueo() as Void
		if vartype( this.oLogueo ) = 'O' and vartype( goServicios ) = 'O' and vartype( goServicios.Logueos ) = 'O'
			local loLogueoAux as Object
			*No cambiar este paso por el aux, esta para que no queden referencias cruzadas
			loLogueoAux = this.oLogueo
			this.oLogueo = null
			if this.lLogueoPropio
				goServicios.Logueos.guardar( loLogueoAux )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MensageLogueoInicial() as String
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoObtenerLogueo( toYoMismo as Object ) as Void
		****Si hay algun otro zooSession escuchando le va a inyectar un objeto logueo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oLogueo_Access() as Object
		with this
			if !.ldestroy and !vartype( .oLogueo ) = 'O' and isnull( .oLogueo ) and vartype( goServicios ) = 'O'
				this.eventoObtenerLogueo( this )
				if !vartype( .oLogueo ) = 'O' and isnull( .oLogueo )
					.oLogueo = goServicios.Logueos.obtenerObjetoLogueo( this )
					.SetearAccion()
					.lLogueoPropio = .T.
				else
					.lLogueoPropio = .F.				
				endif	
			endif
		endwith
		return this.oLogueo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function setearLogueo( toLogueo as Object ) as Void
		this.oLogueo = toLogueo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function inyectarLogueo( toQuienLlama as Object ) as Void
		toQuienLlama.setearLogueo( this.oLogueo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearAccion() as string
		local lcAccionASetear as String

		lcAccionASetear = this.MensageLogueoInicial()
		if empty( lcAccionASetear )
		else
			This.oLogueo.Accion = lcAccionASetear
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oInformacion_Access() as Object
		with this
			if !.ldestroy and !vartype( .oInformacion ) = 'O' and isnull( .oInformacion )
				this.eventoObtenerInformacion( this )
				if !vartype( .oInformacion ) = 'O' and isnull( .oInformacion )
					.oInformacion = this.CrearObjeto( "ZooInformacion" )
				endif	
			endif
		endwith
		return this.oInformacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function setearInformacion( toInformacion as Object ) as Void
		this.oInformacion = toInformacion
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function inyectarInformacion( toQuienLlama as Object ) as Void
		toQuienLlama.setearInformacion( this.oInformacion )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function eventoObtenerInformacion( toYoMismo as Object ) as Void
		****Si hay algun otro zooSession escuchando le va a inyectar un objeto Informacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarInformacion( tcInformacion as String, tnNumero as Integer, txInfoExtra as Variant ) as Void
		do case
		case pcount() = 1
			this.oInformacion.AgregarInformacion( tcInformacion )
		case pcount() = 2
			this.oInformacion.AgregarInformacion( tcInformacion, tnNumero )
		case pcount() = 3
			this.oInformacion.AgregarInformacion( tcInformacion, tnNumero, txInfoExtra )
		otherwise
			assert pcount() = 0 message "Llamaron al AgregarInformacion del zooSession con parametros incorrectos"
		endcase
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function LimpiarInformacion() as Void
		this.oInformacion.Limpiar()
	endfunc 	

	*-----------------------------------------------------------------------------------------
	Function HayInformacion() as Boolean
		return This.oInformacion.HayInformacion()
	Endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacion() as zooInformacion of zooInformacion.prg
		return this.oInformacion
	endfunc 
	
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

	*-----------------------------------------------------------------------------------------
	function CargarInformacion( toInformacion as zooInformacion of zooInformacion.prg ) as Void
		local lnCont as Integer
		with toInformacion
			for lnCont = 1 to toInformacion.Count
				This.AgregarInformacion( .item[ lnCont ].cMensaje, .item[ lnCont ].nNumero , .item[ lnCont ].xInfoExtra )
			endfor
		endwith		
		toInformacion.Limpiar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ParsearFecha( txFecha as Variant ) as Date
		local ldFecha as Date
		if vartype( txFecha ) = "O"
			ldFecha = ctod( txFecha.ToString( This.cFormatoFechaNet ) )
		Else
			ldFecha = txFecha
		EndIf	
		Return ldFecha
	endfunc

	*-----------------------------------------------------------------------------------------
	function SeDebeLoguear() as Boolean
		local llRetorno as Boolean

		llRetorno = .T.	
		
		if  pemstatus(_screen,"lUsaServicioRest", 5) and _Screen.lUsaServicioRest and goservicios.lnologuearrestapi
			llRetorno = .F.
		endif

		return llRetorno
		
	endfunc 

enddefine
