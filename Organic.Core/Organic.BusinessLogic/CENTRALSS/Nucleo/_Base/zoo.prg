Define Class Zoo As ZooSession Of ZooSession.prg
	
	#if .f.
		local this as Zoo of Zoo.prg
	#endif

	hidden oTemporales as Object
	protected lEsExe

	DataSession = 1
	cRutaInicial = ""
	oWsh = Null
	App = Null
	EsBuildAutomatico = .F.
	esBancoDePruebas = .f.
	oTemporales = null
	oServicios = null
	oConstructor = null
	lEsExe = .f.
	nVersionSQLNo = 0
	cVersionSQLNo = ''

	*-------------------------------------------------------------------
	Function Init( ) As Boolean

		DoDefault()

		With This
			.cRutaInicial = Addbs(Sys(5) + Sys(2003))

			DECLARE INTEGER ShellExecute IN "shell32.dll" ;
			INTEGER hwnd, STRING lpszOp, STRING lpszFile, ;
			STRING lpszParams, STRING lpszDir, INTEGER FsShowCmd

			Declare Long WinExec In kernel32.Dll String lpCmdLine, Long nCmdShow
			.oWsh = Createobject("WScript.Shell")
			.seteos()
			.lEsExe = ( _vfp.StartMode = 4 )
		endwith
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function oConstructor_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy  and !isnull( this.App ) and isnull( this.oConstructor )
			this.oConstructor = this.CrearObjetoPorProducto( "ZooConstructor", "ZooConstructor.prg" )
		endif
		return this.oConstructor
	endfunc

	*-------------------------------------------------------------------
	Function seteos () As VOID

		Set StrictDate To 0
		Set Cpdialog Off
		Set Collate To "MACHINE"
		Set Notify Off
		Set Ansi On
		Set Escape Off
		Set Asserts Off
		Set Exclusive Off
		Set Dohistory Off
		Set Optimize On
		Set Multilock On
		set deleted on

	Endfunc

	*-------------------------------------------------------------------
	Function AgregarPath ( tcPath As String )

		Local lcPathActual, lcPath
		lcPath = Alltrim( tcPath )
		lcPathActual = Set( "path" )
		Set Path To ( Iif( Empty( lcPathActual ), "", lcPathActual + "," ) + Addbs( lcPath ) )

	Endfunc

	*-------------------------------------------------------------------
	Function EjecutaDOS ( tcComando As String, tlMostrar As Boolean , tlNoEsperar ) As Boolean

		Local llRetorno, llMostrar, loError
		llRetorno = .T.

		llMostrar = Iif(tlMostrar ,1,0)

		Try
			If tlNoEsperar
				=WinExec(Alltrim(tcComando),2)
			else
				if vartype( goTimer ) == "O"			
					goTimer.FrenarTodosLosTimers()			
				endif
				This.oWsh.Run( Alltrim( tcComando ), llMostrar , !tlNoEsperar )
			Endif
		Catch To loError
			llRetorno = .F.
		finally
			If !tlNoEsperar
				if vartype( goTimer ) == "O"
					goTimer.EncenderTodosLosTimersFrenados()
				endif
			endif
		Endtry

		Return llRetorno
	Endfunc

	*-------------------------------------------------------------------
	Function IniciarAplicacion ( tcAplicacion As String )

		This.App = This.CrearObjeto( tcAplicacion )
		
		this.InstanciarServiciosAplicacion()
		
		this.BorrarCarpetaTemporal()
		this.oTemporales.cProyecto = this.app.cProyecto
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function InstanciarServiciosAplicacion() as Void
		local lcNombreArchivo as String
		
		with this
			if vartype( this.app.cProyecto ) = "C"
				lcNombreArchivo = "ServiciosAplicacion" + this.app.cProyecto
			else
				lcNombreArchivo = "ServiciosAplicacion"
			endif
			if this.BuscarClase( lcNombreArchivo + ".fxp" ) or ( !this.lEsExe and this.BuscarClase( lcNombreArchivo + ".prg" ) )
				this.oServicios = this.crearObjeto( lcNombreArchivo )
			else
				this.oServicios = this.crearObjeto( "ServiciosAplicacion" )
			endif
			public goServicios
			goServicios = this.oServicios
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerHerenciaDenombre( tcCadenaPrefijo as string, tcEntidad as string, tcSubfijo as string )

		local llCondicion as logical, lnCont as Integer, lcNombreArchivo as String
		llCondicion = .t.
		lnCont = 0
		lcNombreArchivo = ""

		for lnCont = 1 to getwordcount( tcCadenaPrefijo , "," )
			lcNombreArchivo = getwordnum( tcCadenaPrefijo, lnCont, "," ) + alltrim( tcEntidad ) + alltrim( tcSubfijo )
			if this.BuscarClase(lcNombreArchivo + ".fxp") or ( !this.lEsExe and this.BuscarClase( lcNombreArchivo + ".prg" ) )
				exit for
			else
				lcNombreArchivo = ""
			endif
		endfor

		return lcNombreArchivo

	endfunc 

	*-------------------------------------------------------------------
	Function InstanciarEntidad ( tcEntidad As String, tnNivel As Integer, tlEsSubEntidad As Boolean )As Object
		Local loEntidad As Object, lcEntidad As String, loError As Object, loEx as zooexception OF zooexception.prg

		lcEntidad = Alltrim( Upper( tcEntidad ) )

		if this.EsEntidadV2( lcEntidad )
			lcEntidad = this.ObtenerNombreentidadV2( lcEntidad )
		else 
			lcEntidad = "Din_" + Alltrim( Upper( tcEntidad ) )
		endif

		try
			do case
				case pcount() > 1
					loEntidad = This.CrearObjeto( lcEntidad ,"", tnNivel, tlEsSubEntidad  )
				otherwise
					loEntidad = This.CrearObjeto( lcEntidad )
			endcase
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Finally
		Endtry

		Return loEntidad

	Endfunc

	*-------------------------------------------------------------------
	Function InstanciarComponente ( tcComponente As String )As Object
		Local loComponente As Object, lcComponente As String, loError As Object, loEx as zooexception OF zooexception.prg
		lcComponente = Alltrim( Upper( tcComponente ) )
		lcComponente = this.ObtenerNombreComponente( lcComponente )
		Try
			loComponente = This.CrearObjeto( lcComponente )
			if pemstatus( loComponente, "Inicializar", 5 )
				loComponente.inicializar()
			EndIf	
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Finally
		Endtry

		Return loComponente

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CrearObjetoPorProducto( tcClase as String, tcLibreria as String, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant ) as Object
		local loObjeto as Object, lcClase As String, lcClasePorProducto as String, lcComando as String, lni as Integer, lcLibreriaPorProducto As String

		if empty( tcLibreria )
			tcLibreria = forceext( tcClase, "prg" )
		endif

		lcClasePorProducto = _screen.zoo.app.cProyecto + "_" + tcClase
		lcLibreriaPorProducto = _screen.zoo.app.cProyecto + "_" + tcLibreria

		if this.BuscarClase( forceext( lcLibreriaPorProducto, "fxp" ) ) or ( !this.lEsExe and this.BuscarClase( forceext( lcLibreriaPorProducto, "prg" ) ) )
			lcClase = lcClasePorProducto
			tcLibreria = lcLibreriaPorProducto
		else
			lcClase = tcClase
		endif
	
		lcComando = "This.CrearObjeto( '" + lcClase + "', '"+ tcLibreria + "'"
	
		for lni = 1 to pcount()-2
			lcComando = lcComando + ", tvPar" + transform( lni )
		endfor
		
		lcComando = lcComando + " )"

		loObjeto = &lcComando

		Return loObjeto
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreComponente( tcComponente as String ) as String
		local lcRetorno as string, lcArchivo as string
		
		lcArchivo = _screen.zoo.app.cProyecto + + "_" + tcComponente 
		lcRetorno = ""
		
		if this.BuscarClase( lcArchivo + ".fxp" ) or ( !this.lEsExe and this.BuscarClase( lcArchivo  + ".prg" ) )
			lcRetorno = Alltrim( Upper( lcArchivo ) )
		else
			lcArchivo = tcComponente
			if this.BuscarClase( lcArchivo + ".fxp" ) or ( !this.lEsExe and this.BuscarClase( lcArchivo  + ".prg" ) )
				lcRetorno = Alltrim( Upper( lcArchivo ) )
			else
				lcRetorno = "Din_" + Alltrim( Upper( tcComponente ) )
			endif
		endif

		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenernombreEntidadV2( tcEntidad as String ) as String
		local lcRetorno as string, lcArchivo as string
		
		lcArchivo = "Ent" + _screen.zoo.app.cProyecto + "_" + tcEntidad 
		lcRetorno = ""
		
		if this.BuscarClase( lcArchivo + ".fxp" ) or ( !this.lEsExe and this.BuscarClase( lcArchivo  + ".prg" ) )
			lcRetorno = Alltrim( Upper( lcArchivo ) )
		else
			lcArchivo = "Ent_" + tcEntidad 

			if this.BuscarClase( lcArchivo + ".fxp" ) or ( !this.lEsExe and this.BuscarClase( lcArchivo  + ".prg" ) )
				lcRetorno = Alltrim( Upper( lcArchivo ) )
			else
				lcRetorno = "Din_Entidad" + Alltrim( Upper( tcEntidad ) )
			endif
		endif

		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function EsEntidadV2( tcEntidad ) as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Destroy() As Void
		Local loError As Exception
		
		try
			DoDefault()
		catch to loError
			if type( "goServicios.Errores" ) = "O" and !isnull( goServicios.Errores )
				goServicios.Errores.LevantarExcepcion( loError )
			else
				throw loError
			endif
		finally
	        this.BorrarCarpetaTemporal()
	    endtry
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SeteoRutaTemporal( tcProyecto as String ) As Void
		this.oTemporales.SetearCarpetaParaProyecto( tcProyecto )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerRutaTemporal( tlNuevo as Boolean ) As String
		return this.oTemporales.ObtenerCarpeta( tlNuevo )
	endfunc

    *-----------------------------------------------------------------------------------------
    protected function BorrarCarpetaTemporal() as Void
		this.oTemporales.BorrarCarpeta()
    endfunc 

	*-----------------------------------------------------------------------------------------
	function CLRDebug() as Void
		_screen.NetExtender.CLRDebug()
	endfunc

	*-------------------------------------------------------------------
	Function NuevoObjeto( toObjetoContenedor as object, tcNombre as string, tcClase as String, tcLibreria as string, tvPar1 as Variant, tvPar2 as Variant, tvPar3 as Variant, tvPar4 as Variant, tvPar5 as Variant , tvPar6 as Variant, tvPar7 as Variant, tvPar8 as Variant )

		Local loReturn As Object, lnParametrosReales As Integer, lcClase as String, lcConstructor as string, lcComando as String, ;
			lnParamAux as Integer, lcClase as String, lcLibreria as String , lcPrgSinExtension as String, llSeteoProcedure as Boolean , ;
			loError as Exception, loEx as Exception, loRetorno as object, lcConstructor as String, lcProcAnt as string
			
		lnParametrosReales = Pcount() - 4	

		loReturn = Null
		lcLibreria = tcLibreria 
		lcClase = alltrim( upper( tcClase ) )

		*-------------------------------------------------------------------
		*Instanciación de Mocks
		if pemstatus(_screen, "Mocks", 5 ) and vartype( _Screen.Mocks ) = "O"
			local lnItem as Integer
			lnItem = _Screen.Mocks.BuscarMock( lcClase )
			if !empty( lnItem )
				lcClase = _Screen.Mocks.Item[lnItem].cNombreClaseMock
				lcLibreria = iif( empty( lcLibreria ), "", "Mock_" + lcLibreria )
			else 
				lcClase = tcClase
			endif
		else
			lcClase = tcClase
		endif
		*-------------------------------------------------------------------

		If empty( lcLibreria )
			lcLibreria = lcClase + ".prg"
		EndIf

		loRetorno = null
		lcProcAnt = ""
		lcProcAnt = set( "Procedure" )

		try
			lcComando = this.ObtenerSentenciaNewObjectConDesgloseParametros( "NewObject", tcNombre, lcClase, lcLibreria , "", lnParametrosReales )

			if upper( justext( lcLibreria ) ) == "PRG"
				llSeteoProcedure = .t.
				lcPrgSinExtension = juststem( lcLibreria ) &&forceext( lcLibreria, "" )
				
				if ( this.lEsExe and upper( justext( lcLibreria ) ) == "PRG" )
					lcPrgSinExtension = forceext( lcLibreria, "fxp" )
				endif

				*!* El additive solo es necesario para LINCEORGANIC. En el resto de los productos no se utiliza ya que no es necesario
				*!* e impacta en la performance de la aplicación.
				if upper( alltrim( _screen.Zoo.App.cProyecto ) ) == "LINCEORGANIC"
					set procedure to &lcPrgSinExtension additive
				else
					set procedure to &lcPrgSinExtension
				endif
			endif

			loRetorno = toObjetoContenedor.&lcComando 
		Catch To loError
			local lnError as Integer
			lnError = 0
			With loError				
				if .ErrorNo = 1 and left( lower( lcLibreria ), 4 ) == "din_"
					do case
						case !this.BuscarClase( strtran( lower( lcLibreria ), ".prg", ".fxp" ) )
							lnError = 10
						case !this.BuscarClase( lcLibreria ) 
							lnError	= 20
					endcase
				endif
			endwith

			loError.Message = tcNombre + ": " + loError.Message

			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx				
				.Grabar( loError )
				.nZooErrorNo = lnError
				.Throw()
			EndWith
		finally
			if llSeteoProcedure 
				set procedure to &lcProcAnt 
			endif
		EndTry

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function ObtenerSentenciaNewObjectConDesgloseParametros( tcComando as string, tcNombre as string, tcClase as string, tcLibreria as String, tcApp as String, tnParametros as Integer )
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
		
		if ( this.lEsExe and upper( justext( lcLibreria ) ) == "PRG" )
			lcLibreria = forceext( lcLibreria, "fxp" )
		endif

		lcRetorno = tcComando + "( '" + tcNombre+ "', '" + tcClase + "', '" + lcLibreria + "', '" + tcApp + "'"
		
		for lni = 1 to tnParametros
			lcRetorno = lcRetorno + ", tvPar" + transform( lni )
		endfor
		lcRetorno = lcRetorno + " )"

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function oTemporales_Access() as Object
		local loLectorFpw as Object
		if vartype( this.oTemporales ) != "O" and isnull( this.oTemporales )
			loLectorFpw = newobject( "LectorFpw", "LectorFpw.prg", "", this.cRutaInicial )
			this.oTemporales = newobject( "ManagerTemporales", "ManagerTemporales.prg", "", "", loLectorFpw )
		endif
		
		return this.oTemporales
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function UsaCapaDePresentacion() as Boolean
		return !pemstatus( _screen, "lUsaCapaDePresentacion", 5 ) or _screen.lUsaCapaDePresentacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeInformarErrores() as Void
		return goServicios.Ejecucion.lInformarVisualmenteErrores
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsModoSystemStartUp() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .f.
		if pemstatus( _screen, "lEsModoSystemStartUp", 5 )
			llRetorno = _screen.lEsModoSystemStartUp
		endif		 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoDesdePool( tcClase as String, tcLibreria as String, tnParametros as Integer ) as Void
		local loRetorno as Object
		loRetorno = null
		
		if this.PoolDeObjetosHabilitado() and tnParametros = 0 and upper( alltrim( tcClase ) ) == upper( alltrim( juststem( tcLibreria ) ) )
			loRetorno = goServicios.PoolDeObjetos.ObtenerObjeto( tcClase )
		endif

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function PoolDeObjetosHabilitado() as Void
		return vartype( goServicios ) == "O" and goServicios.oColServiciosActivos.GetKey( "SERVICIOPOOLDEOBJETOS" ) > 0 and goServicios.PoolDeObjetos.EstaHabilitado()
	endfunc

enddefine
