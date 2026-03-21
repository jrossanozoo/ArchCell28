Define Class ManagerFormularios As Servicio Of Servicio.prg

	#if .f.
		local this as ManagerFormularios of ManagerFormularios.prg
	#endif

	DataSession = 1
	cArchivo1 = "PkWare.Sys"
	cArchivo2 = "KSoze32.Dat"
	nSegundos = 30
	cLetra = ""
	nFormularioSingleton = 0
	dDChk = null
	oDes = null
	lFuncionBringWindowToTopDeclarada = .f.

	cRutaArchivosPK = ""
	cRutaArchivoInstalacion1 = ""
	cRutaArchivoInstalacion2 = ""
	cNombrePerfil = ""
	
	lModoSeriesPorPerfil = .t.
	cClaveEncriptadoPkWareCZ = "18B31E8261C09314F6A1B57211841933404511"
	oEncriptadorSHA256 = null
	nIntegridad = 0
	lErrorIntegridad = .f.

	*-----------------------------------------------------------------------------------------
	Function Init() as Boolean
		local llRetorno as Boolean, loError as Exception
		try
			DECLARE INTEGER GetSystemMenu IN user32 INTEGER hWnd, INTEGER bRevert
			DECLARE INTEGER EnableMenuItem IN user32 INTEGER hWnd, INTEGER uIDEnableItem, INTEGER uEnable
		catch to loError
		EndTry	

		if this.DesactivarModoSeriesPorPerfil()
			this.lModoSeriesPorPerfil = .f.
		endif

		if this.lModoSeriesPorPerfil
			this.cRutaArchivosPK = addbs( getenv( "tmp" ) ) + "zooTmp\" + _Screen.Zoo.app.cProducto + sys(2015)
			if !directory( this.cRutaArchivosPK )
				mkdir ( this.cRutaArchivosPK )
			endif

			this.cRutaArchivoInstalacion1 = this.cArchivo1
			this.cArchivo1 = sys(2015) + ".sys"

			this.cRutaArchivoInstalacion2 = this.cArchivo2
			this.cArchivo2 = sys(2015) + ".dat"
			
		else
			this.cRutaArchivosPK = _Screen.Zoo.cRutaInicial
		endif

		llRetorno = dodefault()
		Return	llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarInformacionLocalSeriesPorPerfil( tcPerilNuevo as String ) as Void
		local lcRutaArchivo1 as String, lcRutaArchivo2 as String

		if this.lModoSeriesPorPerfil
			lcRutaArchivo1 = addbs( this.cRutaArchivosPK ) + this.cArchivo1
			lcRutaArchivo2 = addbs( this.cRutaArchivosPK ) + this.cArchivo2
			
			if FILE( lcRutaArchivo1 )
				delete file lcRutaArchivo1 
			endif

			if FILE( lcRutaArchivo2 )
				delete file lcRutaArchivo2		
			endif
			
			this.cArchivo1 = sys(2015) + ".sys"
			this.cArchivo2 = sys(2015) + ".dat"
			
			this.cNombrePerfil = tcPerilNuevo 
			_screen.zoo.app.ResetearSerieApp()
			
			goModulos = null
			_screen.zoo.app.oModulos = null
			_screen.zoo.app.IniciarServicioModulos()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesactivarModoSeriesPorPerfil() as Boolean
		local llRetorno as Boolean, lcContenido as String

		llRetorno = .f.

		if _screen.zoo.esBuildAutomatico && <= Lo de Build Automatico no deberia estar, pero el AB/BP inicia la aplicacion de modo parcial y los series por perfil pinchan :(
			llRetorno = .t.
		else
			if !_screen.zoo.app.lEsEntornoCloud 
				if file( "PkWare.cz" )
					lcContenido = filetostr( "PkWare.cz" )
					if lcContenido == this.oEncriptadorSHA256.Encriptar( _screen.zoo.app.oVersion.Version, this.cClaveEncriptadoPkWareCZ )
						llRetorno = .t.
	     			endif
     			endif
			endif
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oEncriptadorSHA256_Access() as Void
		if !this.ldestroy and ( !vartype( this.oEncriptadorSHA256 ) = 'O' or isnull( this.oEncriptadorSHA256 ) )
			this.oEncriptadorSHA256 = _screen.dotnetbridge.crearobjeto("ZooLogicSA.Core.EncriptadorSHA256")
		endif
		return this.oEncriptadorSHA256
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarNombrePerfilSegunEntorno( tcNombreUsuario ) as String
		local lcNombrePerfil as String

		if _screen.zoo.app.lEsEntornoCloud 
			lcNombrePerfil = tcNombreUsuario 
		else
			lcNombrePerfil = tcNombreUsuario + "@" + golibrerias.ObtenerNombreEquipo()
		endif

		return lcNombrePerfil 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cNombrePerfil_Access() as String
		if !this.lDestroy and alltrim( this.cNombrePerfil ) = ""
			this.cNombrePerfil = this.ArmarNombrePerfilSegunEntorno( golibrerias.ObtenerNombreUsuarioSO() )
		endif
		
		return this.cNombrePerfil
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Destroy()
		dodefault()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oDes_Access() as Object
		if !this.lDestroy
			if vartype( this.oDes ) # 'O'
				this.oDes = newobject( 'des','des.prg' )
			endif
		endif
		
		return this.oDes
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDeEstilo( tnEstilo as Integer ) as string
		local lnEstilo as Integer, lcEstilo as string
		
		if !empty( tnEstilo ) and type( "tnEstilo" ) = "N" and tnEstilo > 0
			lnEstilo = tnEstilo
		else
			lnEstilo = goParametros.Dibujante.Estilo
		endif
		
		lcEstilo = "Estilo" + transform( lnEstilo )

		return lcEstilo  
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsD( tcS as String ) as Boolean
		*A partir del 20/05/2009 la seguridad comercial siemrpe corre, independientemente de si esta en desarrollo o no
		*esto es porque hubo casos donde no se testeaba funcionalidad incorrecta
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	* se refactorizo porque estaba repetido pero esta seteando un modo en el lugar incorrecto *mrusso
	protected function SetearModo() as String
		local lcModo as string

		If goParametros.Dibujante.ModoAvanzado
			lcModo = "Avanzado"
			_Screen.zoo.App.lEsSimple = .F.
		Else
			lcModo = "Simple"
			_Screen.zoo.App.lessimple = .T.
		endif
		
		return lcModo 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Mostrar( tcEntidad As String, tnEstilo as integer) As Void
		Local loForm As form, loError as exception, llEntidadInexistente as boolean
		
		this.Fechar2()

		If Vartype( tcEntidad ) != "C"
			Assert .F. Message "Se debe indicar el nombre de la entidad a mostrar"
		Endif
		
		try
			loForm = this.Procesar( tcEntidad, tnEstilo )
		catch to loError
			llEntidadInexistente = type( "loError.uservalue.message" ) = "C" and ;
				upper( alltrim( loError.uservalue.message ) ) = "FILE 'DIN_ABM" + upper( tcEntidad ) + "AVANZADOESTILO2.PRG' DOES NOT EXIST."
			
			if _screen.zoo.lDesarrollo and llEntidadInexistente
				messagebox( "La entidad '" + tcEntidad + "' no existe o hubo errores al generar su formulario." )
			else
				throw loError
			endif
		endtry
		
		if vartype( loForm ) = "O"
			loForm.Show()

			this.DarFocoALaAplicacion( loForm )
		Endif

	Endfunc

	*-----------------------------------------------------------------------------
	Function ProcesarOpciones( tcTipo as String, tnEstilo as Integer ) As Object
		Local loFormulario As Object, lcEstilo As String, lnEstilo As Integer

		lcEstilo = this.ObtenerNombreDeEstilo( tnEstilo )
		loFormulario = _Screen.zoo.crearobjeto( "din_FormPrincipal" + tcTipo + lcEstilo )

		Return loFormulario
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarListado( tcListadoID as string ) as Object
		Local loFormulario As Object, lcModo As String, lcNombre As String, lcListado as String

		lcListado = proper( alltrim( transform( tcListadoID ) ) )
		if empty( lcListado ) 
			Assert .F. Message "Se debe indicar el ID del listado a mostrar"
		else
			lcNombre = "Din_Listado" + lcListado + "FormularioEstilo" + ;
				transform( goParametros.Dibujante.Estilo )

			loFormulario = _Screen.zoo.crearobjeto( lcNombre )
		endif
		
		Return loFormulario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarListadoSecuencial( tcListadoID as string ) as Object
		Local loFormulario As Object, lcModo As String, lcNombre As String, lcListado
		
		lcListado = proper( alltrim( transform( tcListadoID ) ) )
		if empty( lcListado )
			Assert .F. Message "Se debe indicar el ID del listado secuencial a mostrar"
		else
			lcNombre = "Din_ListadoSecuencial" + lcListado + "FormularioEstilo" + ;
				transform( goParametros.Dibujante.Estilo )

			loFormulario = _Screen.zoo.crearobjeto( lcNombre )
		endif
		
		Return loFormulario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarTransferencia( tcEntidad as string ) as Object
		Local loFormulario As Object, lcModo As String, lcNombre As String
		
		if empty( tcEntidad ) or vartype( tcEntidad ) != "C"
			Assert .F. Message "Se debe indicar el número de la Transferencia a mostrar"
		else
			lcNombre = "Din_Transferencia" + alltrim( tcEntidad ) + "FormularioEstilo" + ;
				transform( goParametros.Dibujante.Estilo )

			loFormulario = _Screen.zoo.crearobjeto( lcNombre )
		endif
		
		Return loFormulario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarExportacion( tcEntidad as string ) as Object
		Local loFormulario As Object, lcModo As String, lcNombre As String
		
		if empty( tcEntidad ) or vartype( tcEntidad ) != "C"
			Assert .F. Message "Se debe indicar el número de la Exportación a mostrar"
		else
			lcNombre = "Din_Exportacion" + alltrim( tcEntidad ) + "FormularioEstilo" + ;
				transform( goParametros.Dibujante.Estilo )

			loFormulario = _Screen.zoo.crearobjeto( lcNombre )
		endif
		
		Return loFormulario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarTransferenciaAgrupada( tcEntidad as string ) as Object
		Local loFormulario As Object, lcModo As String, lcNombre As String
		
		if empty( tcEntidad ) or vartype( tcEntidad ) != "C"
			Assert .F. Message "Se debe indicar el número de la Transferencia a mostrar"
		else
			lcNombre = "Din_TransferenciaAgrupada" + alltrim( tcEntidad ) + "FormularioEstilo" + ;
				transform( goParametros.Dibujante.Estilo )

			loFormulario = _Screen.zoo.crearobjeto( lcNombre )
		endif
		
		Return loFormulario
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function MostrarFormDuro( tcFormulario As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant  ) As Variant
		local lcComando as string, lxRetorno as Variant, lcNombreVar as string , loError  as Exception   

		this.Fechar2()
		
		If Empty( tcFormulario )
			Assert .F. Message "Se debe indicar el nombre del formulario a mostrar"
		Else
			lcComando = "_Screen.zoo.crearobjeto( 'Frm_" + tcFormulario + "Estilo" + transform( goParametros.Dibujante.Estilo ) + "', ''"



			Do Case
				Case Pcount() = 3
					lcComando = lcComando + ", txParametro"
				Case Pcount() = 4
					lcComando = lcComando +  ", txParametro, txParametro2"
				Case Pcount() = 5
					lcComando = lcComando +  ", txParametro, txParametro2, txParametro3"
				Case Pcount() = 6
					lcComando = lcComando +  ", txParametro, txParametro2, txParametro3, txParametro4"
			endcase
			
			lcComando = lcComando + " )"

			if type( "txParametro" ) = "O" and !isnull( txParametro ) and pemstatus( txParametro, "SetearEstadoMenuYToolBar", 5 )
				txParametro.SetearEstadoMenuYToolBar( .f. )
			endif

			try
				tcFormulario = tcFormulario + sys( 2015 )

				if tlRetorno
					lcNombreVar = "lx" + tcFormulario 	
					public ( lcNombreVar )
					local ( tcFormulario ) as form
					&tcFormulario = &lcComando
				
					if vartype(&tcFormulario) = "O"
						&tcFormulario..cVariableRetorno = lcNombreVar
						if !empty( goServicios.Seguridad.cVengoDe )
							&tcFormulario..Caption = &tcFormulario..Caption + " - " + goServicios.Seguridad.cVengoDe
						endif

						this.DarFocoALaAplicacion( &tcFormulario )
						
						&tcFormulario..show(1)
						lxRetorno =  &lcNombreVar
					endif

					release ( lcNombreVar )
				else
					public ( tcFormulario )
					&tcFormulario= &lcComando
					if vartype(&tcFormulario) = "O"
						if !empty( goServicios.Seguridad.cVengoDe )
							&tcFormulario..Caption = &tcFormulario..Caption + " - " + goServicios.Seguridad.cVengoDe
						endif
					 	&tcFormulario..show()
						this.DarFocoALaAplicacion( &tcFormulario )
					endif 	
				endif
				
				*-- Funcionalidad solo disponible para formularios heredados de ZooForm
				if type(  "_Screen.Forms( 1 ).cNombreFormulario" ) <> "U" and vartype(  _Screen.Forms( 1 ).cNombreFormulario ) != "U" and empty(  _Screen.Forms( 1 ).cNombreFormulario )
						_Screen.Forms( 1 ).cNombreFormulario = tcFormulario
				endif
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				if type( "txParametro" ) = "O" and !isnull( txParametro ) and pemstatus( txParametro, "SetearEstadoMenuYToolBar", 5 )
					txParametro.SetearEstadoMenuYToolBar( .t. )
				endif
			endtry
		endif
		
		return lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarScx( tcFormulario As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant  ) As Variant
		local lxRetorno as Variant, lcComando as string

		this.Fechar2()
		
		If Empty( tcFormulario )
			Assert .F. Message "Se debe indicar el nombre del formulario a mostrar"
		Else
			if tlRetorno
				lcComando = "lxRetorno = this.MostrarFormDuro( tcFormulario, tlRetorno "
			else
				lcComando = "this.MostrarFormDuro( tcFormulario, tlRetorno "
			endif
			
		
			Do Case
				Case Pcount() = 3
					lcComando = lcComando + ", txParametro"
				Case Pcount() = 4
					lcComando = lcComando + ", txParametro, txParametro2"
				Case Pcount() = 5
					lcComando = lcComando + ", txParametro, txParametro2, txParametro3"
				Case Pcount() = 6
					lcComando = lcComando + ", txParametro, txParametro2, txParametro3, txParametro4"
			endcase

			lcComando = lcComando + ")" 
			&lcComando
			
		endif
		
		return lxRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function MostrarScxSingleton( tcFormulario As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant ) As Variant
		local lxRetorno as Variant

		this.nFormularioSingleton = 0

		this.Fechar2()
				
		If This.EstaInstanciado( tcFormulario )

			*-- Funcionalidad solo disponible para formularios heredados de ZooForm
			if this.nFormularioSingleton > 0 and vartype(  _Screen.Forms( this.nFormularioSingleton ).cNombreFormulario ) != "U"
				_screen.Forms( this.nFormularioSingleton ).show()
			endif			

		Else
			If Empty( tcFormulario )
				Assert .F. Message "Se debe indicar el nombre del formulario a mostrar"
			Else
				Local lcFormulario As String
				Do Case
					Case Pcount() = 3
						lxRetorno = This.MostrarScx( tcFormulario , tlRetorno, txParametro )
					Case Pcount() = 4
						lxRetorno = This.MostrarScx( tcFormulario, tlRetorno, txParametro, txParametro2 )
					Case Pcount() = 5
						lxRetorno = This.MostrarScx( tcFormulario, tlRetorno, txParametro, txParametro2, txParametro3 )
					Case Pcount() = 6
						lxRetorno = This.MostrarScx( tcFormulario, tlRetorno, txParametro, txParametro2, txParametro3, txParametro4 )
					Otherwise
						lxRetorno = This.MostrarScx( tcFormulario, tlRetorno )
				endcase
			endif
		endif
		
		return lxRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarScxSegunEstiloSingleton( tcFormulario As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant ) As Variant
		local lxRetorno as Variant, lcFormulario As String, lcComando AS String
		lxRetorno = .T.
		this.nFormularioSingleton = 0
		lcFormulario = tcFormulario + Iif( goParametros.Dibujante.Estilo = 1, "_Lince", "_Windows" )

		this.Fechar2()

		If This.EstaInstanciado( lcFormulario )

			*-- Funcionalidad solo disponible para formularios heredados de ZooForm		
			if this.nFormularioSingleton > 0 and vartype(  _Screen.Forms( this.nFormularioSingleton ).cNombreFormulario ) != "U"
			
				_screen.Forms( this.nFormularioSingleton ).show()
				
			endif			

		Else
			If Empty( tcFormulario )
				Assert .F. Message "Se debe indicar el nombre del formulario a mostrar"
			Else
				Do Case
					Case Pcount() = 3
						lxRetorno = This.MostrarScx( lcFormulario , tlRetorno, txParametro )
					Case Pcount() = 4
						lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro, txParametro2 )
					Case Pcount() = 5
						lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro, txParametro2, txParametro3 )
					Case Pcount() = 6
						lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro, txParametro2, txParametro3, txParametro4 )
					Otherwise
						lxRetorno = This.MostrarScx( lcFormulario, tlRetorno )
				endcase
			endif
		endif
		
		return lxRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarScxSegunEstilo( tcFormulario As String, tlRetorno as Boolean, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant  ) As Variant
		local lxRetorno as Variant

		this.Fechar2()

		If Empty( tcFormulario )
			Assert .F. Message "Se debe indicar el nombre del formulario a mostrar"
		Else
			Local lcFormulario As String
			lcFormulario = tcFormulario + Iif( goParametros.Dibujante.Estilo = 1, "_Lince", "_Windows" )
			Do Case
				Case Pcount() = 3
					lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro )
				Case Pcount() = 4
					lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro, txParametro2 )
				Case Pcount() = 5
					lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro, txParametro2, txParametro3 )
				Case Pcount() = 6
					lxRetorno = This.MostrarScx( lcFormulario, tlRetorno, txParametro, txParametro2, txParametro3, txParametro4 )
				Otherwise
					lxRetorno = This.MostrarScx( lcFormulario, tlRetorno )
			Endcase

		endif
		
		return lxRetorno
	Endfunc

	*-----------------------------------------------------------------------------
	Function Procesar( tcEntidad As String, tnEstilo as integer ) As Object
		Local loFormulario As Object, lcModo As String, lcEstilo As String, lcClase as String, lcRegistroDeActividad as String

		if goServicios.Modulos.EntidadHabilitada( tcEntidad )
			lcModo = this.SetearModo()
			lcEstilo = this.ObtenerNombreDeEstilo( tnEstilo )
			lcClase = "Din_Abm" + Alltrim( tcEntidad ) + lcModo + lcEstilo
			lcRegistroDeActividad = goServicios.RegistrodeActividad.IniciarRegistro( proper( tcEntidad ), "Apertura de formulario" )
				loFormulario = _Screen.zoo.ObtenerObjetoDesdePool( lcClase, lcClase, 0 )
				if isnull( loFormulario )
					loFormulario = _Screen.zoo.crearobjeto( lcClase )
				endif
			goServicios.RegistroDeActividad.FinalizarRegistro( lcRegistroDeActividad )
		EndIf
		Return loFormulario
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ProcesarScx( tcFormulario As String, txParametro As Variant, txParametro2 As Variant, txParametro3 As Variant, txParametro4 As Variant ) as Object
		local lcComando as string

		this.Fechar2()
		
		If Empty( tcFormulario )
			Assert .F. Message "Se debe indicar el nombre del formulario a mostrar"
			lcComando = ""
		Else
			lcComando = "_Screen.zoo.crearobjeto( 'Frm_" + tcFormulario + "Estilo" + transform( goParametros.Dibujante.Estilo ) + "', ''"
			Do Case
				Case Pcount() = 3
					lcComando = lcComando + ", txParametro"
				Case Pcount() = 4
					lcComando = lcComando +  ", txParametro, txParametro2"
				Case Pcount() = 5
					lcComando = lcComando +  ", txParametro, txParametro2, txParametro3"
				Case Pcount() = 6
					lcComando = lcComando +  ", txParametro, txParametro2, txParametro3, txParametro4"
			endcase
			
			lcComando = lcComando + " )"

			if type( "txParametro" ) = "O" and !isnull( txParametro ) and pemstatus( txParametro, "SetearEstadoMenuYToolBar", 5 )
				txParametro.SetearEstadoMenuYToolBar( .f. )
			endif
		endif
		return &lcComando
	endfunc 

	*-----------------------------------------------------------------------------
	Function ProcesarSubEntidad( txPadre As Variant, tnEstilo as integer ) As Object
		Local loFormulario As Object, lcModo As String, lcEstilo As String, lcEntidad As String

		lcModo = this.SetearModo()
		lcEstilo = this.ObtenerNombreDeEstilo( tnEstilo )
		
		if vartype( txPadre ) = "O"
			lcEntidad = txPadre.cClaveForanea
			if goServicios.Modulos.EntidadHabilitada( txPadre.cClaveForanea )
				loFormulario = _Screen.zoo.crearobjeto( "Din_Abm" + Alltrim( lcEntidad ) + lcModo + lcEstilo + "SubEntidad", "" )
				if vartype( loFormulario ) = "O"
					loFormulario.oControlPadre = txPadre
				endif
			EndIf	
		else
			lcEntidad = txPadre
			if goServicios.Modulos.EntidadHabilitada( lcEntidad )
				loFormulario = _Screen.zoo.crearobjeto( "Din_Abm" + Alltrim( lcEntidad ) + lcModo + lcEstilo + "SubEntidad", "", null )
			Endif	
		endif

		Return loFormulario
	Endfunc

	*-----------------------------------------------------------------------------
	Function MostrarV8x( tcPrograma As String, tcParametro as String ) As VOID

		Local loError As Exception, loEx As Exception
		try
			this.Fechar2()		
			
			gcProgram = tcPrograma
			gcParametro = tcParametro
			glFormularioAbierto = .F.
			clear events
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				goMensajes.Enviar( loEx )
			Endwith
		Finally
		Endtry


	Endfunc

	*-----------------------------------------------------------------------------------------
	function SetearS( tcS as String ) as Void
		this.Escribir( 1, tcS )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Escribir( tnId as Integer, tcContenido as String ) as Void
		local loColIds1 as Collection, loColIds2 as Collection, i as integer, lnHandler1 as Integer, ;
			lnHandler2 as Integer
		
		loColIds1 = this.ArmarColeccion1( tnId )
		loColIds2 = this.ArmarColeccion2( tnId )

		this.ResetCheckIntegridad()
		
		lnHandler1 = this.ObtenerHandler( 1 )
		if lnHandler1 < 0
			goLibrerias.ConstTextoAndGo( "PK", .t., .t.)
		endif
		lnHandler2 = this.ObtenerHandler( 2 )
		if lnHandler2 < 0
			goLibrerias.ConstTextoAndGo( "KZ", .t., .t. )
		endif

		this.CheckIntegridad()

		for i = 1 to 5
			fseek( lnHandler1, loColIds1.item( i ), 0 )
			fseek( lnHandler2, loColIds2.item( i ), 0 )
			tcContenido = left( tcContenido + replicate( "Ï", 10 ), 10 )
			fwrite( lnHandler1, substr( tcContenido, 2 * i - 1, 2 ), 2 )
			fwrite( lnHandler2, substr( tcContenido, 2 * i - 1, 2 ), 2 )
		endfor

		if this.lModoSeriesPorPerfil and !this.lErrorIntegridad 
			if !empty( _Screen.zoo.app.cSerie )
				this.SubirArchivosDesdeHandlers( lnHandler1 , lnHandler2 )
			else
				this.CopiarInstalacion( sys(2015), this.cNombrePerfil )
			endif
		endif

		fclose( lnHandler1 )
		fclose( lnHandler2 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SubirArchivosDesdeHandlers( tnHandlerT1 as Integer, tnHandlerT2 as Integer ) as Void
		local lnSize as Integer, lcContenidoFinal1 as String, lcArchivoTempSys as String, lnHandlerTemp as Integer, loStorage as Object, loSqlKeyExpresion as Object
		local lcContenidoFinal2 as String, lcArchivoTempDat as String

		lnSize =  FSEEK( tnHandlerT1, 0, 2 )   && Move pointer to EOF
		=FSEEK( tnHandlerT1,0, 0 )      	&& Move pointer to BOF
		lcContenidoFinal1 = fread( tnHandlerT1, lnSize )

		lcArchivoTempSys = addbs( this.cRutaArchivosPK ) + sys( 2015 ) + "_1"

		lnHandlerTemp = fcreate( lcArchivoTempSys )
		fwrite( lnHandlerTemp, lcContenidoFinal1 )
		=fclose( lnHandlerTemp )
		

		lnSize =  FSEEK( tnHandlerT2, 0, 2 )   && Move pointer to EOF
		=FSEEK( tnHandlerT2,0, 0 )      	&& Move pointer to BOF
		lcContenidoFinal2 = fread( tnHandlerT2, lnSize )

		lcArchivoTempDat = addbs( this.cRutaArchivosPK ) + sys( 2015 ) + "_2"

		lnHandlerTemp = fcreate( lcArchivoTempDat )
		fwrite( lnHandlerTemp, lcContenidoFinal2 )
		=fclose( lnHandlerTemp )
		

		loStorage = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.Core.Storage.SqlFileStorage", goDatos.oManagerConexionASql.ObtenerCadenaConexionNet() )

		_screen.dotnetbridge.invocarmetodo( loStorage , "SubirArchivos", "[ORGANIZACION].[ARCHIVOSSYS]", this.cNombrePerfil , lcArchivoTempSys, lcArchivoTempDat )

		delete file &lcArchivoTempSys.
		delete file &lcArchivoTempDat.

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SubirArchivoDesdeHandler( tnTipo as Integer, tnHandler as Integer ) as Void
		local lnSize as Integer, lcContenidoFinal as String, lcArchivoTemp as String, lnHandlerTemp as Integer, loStorage as Object, loSqlKeyExpresion as Object

		lnSize =  FSEEK( tnHandler, 0, 2 )   && Move pointer to EOF
		=FSEEK( tnHandler ,0, 0 )      	&& Move pointer to BOF
		lcContenidoFinal = fread( tnHandler, lnSize )

		lcArchivoTemp = addbs( this.cRutaArchivosPK ) + sys( 2015 )

		lnHandlerTemp = fcreate( lcArchivoTemp  )
		fwrite( lnHandlerTemp, lcContenidoFinal )
		=fclose( lnHandlerTemp )

		loStorage = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.Core.Storage.SqlFileStorage", goDatos.oManagerConexionASql.ObtenerCadenaConexionNet() )

		loSqlKeyExpresion = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.Core.Storage.SqlKeyExpresion" )
		_screen.dotnetbridge.invocarmetodo( loSqlKeyExpresion, "Agregar", "Perfil", this.cNombrePerfil )
		_screen.dotnetbridge.invocarmetodo( loSqlKeyExpresion, "Agregar", "Tipo", transform( tnTipo ) )
		_screen.dotnetbridge.invocarmetodo( loStorage , "SubirArchivo", "[ORGANIZACION].[ARCHIVOSSYS]", "Contenido", loSqlKeyExpresion, lcArchivoTemp )

		delete file &lcArchivoTemp.

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ResetCheckIntegridad() as VOID 
		this.nIntegridad = 0
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CheckIntegridad() as VOID
		if mod(this.nIntegridad,2) != 0
			this.lErrorIntegridad = .t.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Leer( tnId as Integer, tlMantener as Boolean, tlNoSalir as Boolean, tlFix as Boolean ) as String
		local loColIds1 as Collection, loColIds2 as Collection, i as number, lcRetorno as string, lnHandler1 as Integer, ;
			lnHandler2 as Integer, lcRetorno1 as string, lcRetorno2 as string

		store "" to lcRetorno, lcRetorno1, lcRetorno2

		loColIds1 = this.ArmarColeccion1( tnId )
		loColIds2 = this.ArmarColeccion2( tnId )

		this.ResetCheckIntegridad()
		
		lnHandler1 = this.ObtenerHandler( 1 )
		if lnHandler1 < 0 and !tlNoSalir
			goLibrerias.ConstTextoAndGo( "PK", .t., .t. )
		endif
		lnHandler2 = this.ObtenerHandler( 2 )
		if lnHandler2 < 0 and !tlNoSalir
			goLibrerias.ConstTextoAndGo( "KZ", .t., .t. )
		endif
		
		this.CheckIntegridad()
		
		for i = 1 to 5
			fseek( lnHandler1, loColIds1.item( i ), 0 )
			fseek( lnHandler2, loColIds2.item( i ), 0 )
			lcRetorno1 = lcRetorno1 + fread( lnHandler1, 2 )
			lcRetorno2 = lcRetorno2 + fread( lnHandler2, 2 )
		endfor
	
		fclose( lnHandler1 )
		fclose( lnHandler2 )

		if lcRetorno1 = lcRetorno2
			lcRetorno = strtran( lcRetorno1, "Ï", " " )
			if !tlMantener
				lcRetorno = alltrim( lcRetorno )
			endif
		else
			lcRetorno = this.VldS( tnId )

			if empty( lcRetorno )
				if !tlFix and tnId >= 40 and loColIds1.Count == 5 and loColIds2.Count == 5
					this.Escribir( tnId, "0" )
					lcRetorno = this.Leer( tnId, tlMantener, tlNoSalir, .t. )
				else
					if tlNoSalir
						lcRetorno = "PK#KZ"
					else
						if inlist( tnId, 1 )
							*** forzar salida sin activacion
							goLibrerias.ConstTextoAndGo( "PK#KZ", .f., .t. )
						else
							goLibrerias.ConstTextoAndGo( "PK#KZ" )
						endif
					endif
				endif
			endif
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BajarArchivo( tnTipo as Integer) as Void
		local lcArchivo as String, lcArchivoInstalacion as String, lcRutaArchivo as String, loStorage as Object, loSqlKeyExpresion as Object, lcRutaOriginal as String, lnCant as Integer

		if tnTipo = 1
			lcArchivo = this.cArchivo1
			lcArchivoInstalacion = this.cRutaArchivoInstalacion1
		else
			lcArchivo = this.cArchivo2
			lcArchivoInstalacion = this.cRutaArchivoInstalacion2
		endif
		
		lcRutaArchivo = addbs( this.cRutaArchivosPK ) + lcArchivo
		
		if !FILE( lcRutaArchivo  )

			loStorage = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.Core.Storage.SqlFileStorage", goDatos.oManagerConexionASql.ObtenerCadenaConexionNet() )

			loSqlKeyExpresion = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.Core.Storage.SqlKeyExpresion" )
			_screen.dotnetbridge.invocarmetodo( loSqlKeyExpresion, "Agregar", "Perfil", this.cNombrePerfil )
			_screen.dotnetbridge.invocarmetodo( loSqlKeyExpresion, "Agregar", "Tipo", transform( tnTipo ) )
			
			lnCant = 0
			do while !FILE( lcRutaArchivo  ) and lnCant<3
				_screen.dotnetbridge.invocarmetodo( loStorage , "BajarArchivo", "[ORGANIZACION].[ARCHIVOSSYS]", "Contenido", loSqlKeyExpresion , lcRutaArchivo    )
				lnCant = lnCant + 1
			enddo
			
			if !FILE( lcRutaArchivo  )
				lcRutaOriginal = addbs( _Screen.Zoo.cRutaInicial ) + lcArchivoInstalacion 
				this.nIntegridad = this.nIntegridad + 1
				If !file( lcRutaOriginal )
					goLibrerias.ConstTextoAndGo( "INSTALL", .t., .t. )
				endif
				
				try
					copy file ('"' + lcRutaOriginal + '"') to ('"' + lcRutaArchivo + '"')
				catch to loError
					goLibrerias.ConstTextoAndGo( "CL" + lcRutaOriginal + " " + lcRutaArchivo, .t., .t. )
				endtry
			endif

		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHandler( tnArchivo as Integer ) as Integer
		local lnSecs as integer, lnHandler as Integer, lcArchivo as String, lcRutaOrigen as String

		lnHandler = 0

		if tnArchivo = 1
			lcArchivo = this.cArchivo1
		else
			lcArchivo = this.cArchivo2
		endif

		if this.lModoSeriesPorPerfil
			this.Bajararchivo( tnArchivo )
		endif

		lcRutaOrigen = this.cRutaArchivosPK 
		
		if !( "\" $ lcArchivo )
			lcArchivo = addbs( lcRutaOrigen ) + lcArchivo	
		endif

		if !file( lcArchivo )
			lnHandler = -1
		else
			lnHandler = fopen( lcArchivo, 2 )
			
			lnSecs = seconds()
			do while ( seconds() - lnSecs ) < this.nSegundos and lnHandler < 0
				lnHandler = fopen( lcArchivo, 2 )
			enddo
		endif

		return lnHandler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetEnt( tnEnt as Integer ) as Void
		local lcValor as String, lcDia as string, lcHora as String, ldDate as date, ;
			lcHora as String, ltHoraEnDateTime as Datetime
		
		ldDate = goLibrerias.ObtenerFecha()
		lcHora = goLibrerias.ObtenerHora()
		ltHoraEnDateTime = ctot( lcHora )
		lcValor = transform( day( ldDate ) * ( tnEnt +  sec( ltHoraEnDateTime )^ 3 ) )

		lcDia = strtran( dtoc( ldDate ), "/", "" )
		lcHora = 	padl( hour( ltHoraEnDateTime ), 2, "0" ) + ;
					padl( minute( ltHoraEnDateTime ), 2, "0" ) + ;
					padl( sec( ltHoraEnDateTime ), 2, "0" )
		
		with this
			.Escribir( 31, lcDia )
			.Escribir( 32, lcHora )
			.Escribir( 33, lcValor )
		endwith			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtDesEncEnt() as integer
		local ltDateTime as Datetime, lcResEnt as String, lnValor as integer, lcDia as string, ;
			lcHora as String, lnRetorno as Integer, lcDiaAux as string, lcHoraAux as String, ;
			lnEnRp as Integer

		with this
			lcDiaAux = .Leer( 31 )
			lcDia = substr( lcDiaAux, 1, 2 ) + "/" + substr( lcDiaAux, 3, 2 ) + "/" + substr( lcDiaAux, 5, 2 )
			lcHoraAux = .Leer( 32 )
			lcHora = substr( lcHoraAux, 1, 2 ) + ":" + substr( lcHoraAux, 3, 2 ) + ":" + substr( lcHoraAux, 5, 2 )
			
			ltDateTime = ctot( lcDia + " " + lcHora )
			lnValor = val( .Leer( 33 ) )
		endwith			
		
		lnRetorno = ( lnValor / day( ltDateTime ) ) - sec( ltDateTime )^ 3 
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RpEnIn( tnEnt as Integer ) as Void
		goDatos.EjecutarSentencias( "update reporte set R16 = '" + this.Sefu1A( c_R.R16, 6, tnEnt ) + "'", ;
			"reporte.dbf", _screen.zoo.cRutaInicial )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RpEnOut() as Integer
		local lcXml as String, lnRetorno as Integer

		goDatos.EjecutarSentencias( "Select r16 from reporte", "reporte.dbf", _screen.zoo.cRutaInicial ;
			, "c_R", this.DatasessionId )

		lnRetorno = this.sefu2A( c_R.R16, 6 )
		
		use in select( "c_R" )
		
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Sefu1A( tcTexto as String, tnCosa1 as integer, tnCosa2 as Integer ) as String
		local lcParte2 as String, i as Integer, lcN1 as String, lcN1Bis as String, lnTE as Integer, ;
			lcParte2Bis as String

		tcTexto = alltrim( tcTexto )
		
		store "" to lcParte2Bis, lcN1
		
		lcParte2 = substr( tcTexto, tnCosa1 + 1 )
		
		for i = 1 to len( lcParte2 )
			lcN1 = lcN1 + padl( asc( substr( lcParte2, i, 1 ) ), 2, "0" )
		endfor

		lnTE = this.Sefu2A( tcTexto, tnCosa1 )
		
		lcN1Bis = transform( val( lcN1 ) - lnTE + tnCosa2 )
		
		for i = 1 to len( lcN1Bis ) / 2
			lcParte2Bis = lcParte2Bis + chr( val( substr( lcN1Bis, 2 * i - 1, 2 ) ) )
		endfor

		return substr( tcTexto, 1, tnCosa1 ) + lcParte2Bis
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Sefu2A( tcTexto as String, tnCosa as Integer ) as Integer
		local lcN1 as String, lcN2 as String, lcTexto as String, lnTE as Integer, i as Integer
		
		tcTexto = alltrim( tcTexto )
		store "" to lcN1, lcN2
		lcPriPar = substr( tcTexto, 1, tnCosa )
		
		for i = 1 to tnCosa
			lcN1 = lcN1 + padl( asc( substr( tcTexto, i, 1 ) ), 2, "0" )
		endfor
		
		for i = tnCosa + 1 to len( tcTexto )
			lcN2 = lcN2 + padl( asc( substr( tcTexto, i, 1 ) ), 2, "0" )
		endfor
		
		lnTE = (-1) * ((((((59 * 5^2)*2^4) - 1)*2^5 * 5^3) + 36200000163) * 3) + ( val( lcN2 ) - val( lcN1 ) ) 
		
		return lnTE
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SRE( tnE as Integer ) as void
		local lnCantE as Integer, llOk as boolean, lcVerModulo As String

		if !this.EsD()
			lnCantE = this.ObtDesEncEnt()
	
			lcArch = this.RutaNombreArchivoCambioModulos()
			if this.VerificaExistenciaArchivoCambioModulos( lcArch )
				if this.VerificaContenidoArchivoModulos( lcArch )
					lnCantE = this.PDBRMSE( "Z" )
					
					try
						if lnCantE > 0
							lcDesactivacion = strtran( This.ObtenerC( _Screen.Zoo.App.cSerie ), "-", "" )
							lnDes = int( val( lcDesactivacion ) /2 )
							lcHashVerificacion = goservicios.Librerias.Sha1( Transf( lnDes ) + "BIEN" )

							strtofile( transform( lnDes ) + chr(13) + chr(10) + lcHashVerificacion, lcArch )
							delete file ( lcArch )
						endif
					catch to loError
					endtry
				else
					try
						delete file ( lcArch )
					catch to loError
					endtry
				endif
			else
				llOk = .t.
				if this.Feria() and this.laCefu3()
					if lnCantE < -50 and tnE <= 0
						this.PDBRMSE( "H" )
					endif
				else
					if lnCantE <= 0 and tnE < 0
						lnCantE = this.PDBRMSE( "Z" )
					endif
				endif

				if llOk
					this.SetEnt( lnCantE + tnE )
				endif
				This.LogueoSC( "ENT", This.Face1(alltrim(transform(lnCantE))) + "*" + This.Face1(alltrim(transform(tnE))) )
			endif

			*----- Verificamos si hubo cambio en la versión de módulos
			lcVerModulo = This.Leer(39)
			if lcVerModulo != this.ObVerMod()
				lnCantE = this.PDBRMSE( "Z" )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificaContenidoArchivoModulos( tcArchivo As String ) as Boolean
		local array laContenidoArchivo[01]
		local lnTotalLineas As Integer, llRetorno As Boolean

		llRetorno = .T.
		lcDesactivacion = strtran( This.ObtenerC( _Screen.Zoo.App.cSerie ), "-", "" )
		lnDes = int( val( lcDesactivacion ) /2 )
		lcHashVerificacion = goservicios.Librerias.Sha1( Transf( lnDes ) + "BIEN" )
		lnTotalLineas = alines( laContenidoArchivo, filetostr( tcArchivo ) )

		if lnTotalLineas != 2
			llRetorno = .T.
		else
			*----- Verifica si el serie del txt es el mismo de la PC que corre esto
			if ( val( laContenidoArchivo[01] ) = lnDes )
				if ( laContenidoArchivo[02] == lcHashVerificacion )	&& Verifica el hash para saber si ya corrio o es primera vez
					llRetorno = .F.
				else
					llRetorno = .T.
				endif
			else
				llRetorno = .T.
			endif
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RutaNombreArchivoCambioModulos() as String
		local lcArchivo As String, lcRuta As String

		lcRuta = _Screen.Zoo.cRutaInicial
		lcArchivo = addbs( lcRuta ) + "\drmm.dat"

		return lcArchivo
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificaExistenciaArchivoCambioModulos( tcArchivo As String ) as Boolean
		return file( tcArchivo )
	endfunc

	*-----------------------------------------------------------------------------------------
	function PDBRMSE( tcLetra as String ) as Integer
		local lcCodDBloq as String, lnCantE as Integer, lcAppAux As String

		*----- Nuevos códigos solo para ZL y DragonFish por ahora.
		lcAppAux = alltrim(_Screen.zoo.app.cProducto )
		if  inlist( lcAppAux , "03", "06" )
			with this
				lnCantE = 0
				.laCefu4()
				.cLetra = tcLetra
				lcCodDBloq = .PedirDBloq()
				if !empty( lcCodDBloq )
					.RegMod( lcCodDBloq )						&& M
					lnCantE = val( this.oDes.cEntradas )
					.SetEnt( lnCantE )							&& E
					.BlankR11()
					this.SetearVersionModulos()
				endif
			endwith
		else
			with this
				lnCantE = 0
				.laCefu4()
				.cLetra = tcLetra
				lcCodDBloq = .PedirDBloq()
				if !empty( lcCodDBloq )
					.RegMod( lcCodDBloq )						&& M
					lnCantE = .ObtEntDCodDBloq( lcCodDBloq )
					.SetEnt( lnCantE )							&& E
					.BlankR11()
					this.SetearVersionModulos()
				endif
			endwith
		endif
		
		return lnCantE
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Reparar() as Void
		local i as Integer, lcCodBloq as String, lcAppAux As String

		with This
			.cLetra = "H"
			.laCefu4()
			lcCodDBloq = .PedirDBloq()

			if !empty( lcCodDBloq )
				.Escribir( 3, .ObS() ) 	
				.RegMod( lcCodDBloq )	&& M
		
				*----- Nuevos códigos solo para ZL y DragonFish por ahora.
				lcAppAux = alltrim(_Screen.zoo.app.cProducto )
				if  inlist( lcAppAux , "03", "06" )
					lnCantE = val( this.oDes.cEntradas )
				else
					lnCantE = .ObtEntDCodDBloq( lcCodDBloq )
				endif

				.SetEnt( lnCantE )

				for i = 4 to 11 				&& Blanquea nombre y apellido y organizacion
					.Escribir( i, "" )
				Endfor
				.BlankR11()

				this.SetearVersionModulos()		&& Versión de módulos
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Feria() as boolean
		local llRetorno as Boolean, ldFecha as Date, lcHora as string
		
		ldFecha = goLibrerias.ObtenerFecha()
		lcHora = goLibrerias.ObtenerHora()

		llRetorno = .f.
		do case
			case dow( ldFecha ) = 1
				llRetorno = .t.
			case dow( ldFecha ) = 2
				llRetorno = .t.
			case dow( ldFecha ) = 6
				llRetorno = .t.
			case dow( ldFecha ) = 7
				llRetorno = .t.
			case val(left( lcHora, 2 ) ) < 9
				llRetorno = .t.
			case val(left( lcHora, 2 ) ) >= 15
				llRetorno = .t.
			case day( ldFecha ) = 1 and month( ldFecha ) = 1
				llRetorno = .t.
			case day( ldFecha ) = 24 and month( ldFecha ) = 3
				llRetorno = .t.
			case day( ldFecha ) = 26 and month( ldFecha ) = 3
				llRetorno = .t.
			case day( ldFecha ) = 2 and month( ldFecha ) = 4
				llRetorno = .t.
			case day( ldFecha ) = 1 and month( ldFecha ) = 5
				llRetorno = .t.
			case day( ldFecha ) = 25 and month( ldFecha ) = 5
				llRetorno = .t.
			case month( ldFecha ) = 6 and  ldFecha  = this.FeriadoCalculado( 3, 2, 6, year(  ldFecha  ) )
				llRetorno = .t.
			case day( ldFecha ) = 9 and month( ldFecha ) = 7
				llRetorno = .t.
			case month( ldFecha ) = 8 and  ldFecha  = this.FeriadoCalculado( 3, 2, 8, year(  ldFecha  ) )
				llRetorno = .t.
			case month( ldFecha ) = 10 and  ldFecha  = this.FeriadoLey23555( ctod( "12/10/" + transform( year(  ldFecha  ) ) ) )
				llRetorno = .t.
			case day( ldFecha ) = 14 and month( ldFecha ) = 11
				llRetorno = .t.
			case day( ldFecha ) = 8 and month( ldFecha ) = 12
				llRetorno = .t.
			case day( ldFecha ) = 24 and month( ldFecha ) = 12
				llRetorno = .t.
			case day( ldFecha ) = 25 and month( ldFecha ) = 12
				llRetorno = .t.
			case day( ldFecha ) = 31 and month( ldFecha ) = 12
				llRetorno = .t.
			case dow( ldFecha ) = 3
				rand( -1 )
				if rand() * 10 > 8.5
					llRetorno = .t.
				endif
			case dow( ldFecha ) = 4
				rand( -1 )
				if rand() * 10 > 8.9
					llRetorno = .t.
				endif
		endcase
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	*FERIADOCALCULADO Ley Nº 24.445 ----------------------------------------------------------
	* Parametros: 
	*	tnOrdinal = El ordinal que se desea saber (primero, segundo, tercero...)
	*	tnDiaSem = 1 Domingo, 2 Lunes, ..., 7 Sábado
	*	tnMes = Numero de mes del que se desea saber el feriado
	*	tnAnio = Año del que se desea saber el feriado
	*-----------------------------------------------------------------------------------------
	protected function FeriadoCalculado( tnOrdinal as Integer, tnDiaSem as Integer, ;
		tnMes as Integer, tnAnio as Integer ) as Date

		return date( tnAnio, tnMes, 1 ) + tnOrdinal * 7 - ;
	    	dow( date( tnAnio, tnMes, 1 ) + tnOrdinal * 7 - 1, tnDiaSem ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	*FERIADOLEY23555 -------------------------------------------------------------------------
	* Si el feriado cae martes o miércoles, pasa al lunes anterior. Si cae jueves o viernes, -
	* pasa al lunes siguiente ----------------------------------------------------------------
	*-----------------------------------------------------------------------------------------
	function FeriadoLey23555( tdFecha as Date ) as Date
		local ldFecha as Date, pnDOW as Integer
		
		pnDOW = dow( tdFecha, 1 )
		do case
			case pnDOW = 3 &&martes
				ldFecha = tdFecha - 1
			case pnDOW = 4 &&miércoles
				ldFecha = tdFecha - 2
			case pnDOW = 5 &&miércoles
				ldFecha = tdFecha + 4
			case pnDOW = 6 &&miércoles
				ldFecha = tdFecha + 3
			otherwise &&lunes, sábado o domingo.
				ldFecha = tdFecha
		endcase

		return ldFecha
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesRegS() as Void
		this.Escribir( 1, "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmBloq() as String
		local lcAppAux As String

		*----- Nuevos códigos solo para ZL y DragonFish por ahora.
		lcAppAux = alltrim(_Screen.zoo.app.cProducto )
		if  inlist( lcAppAux , "03", "06" )
			local lcSegut as String, lcRetorno as String
			
			with this
				lcSegut = .CompactarSegut( .ObS() )
			
				lcRetorno = .oDes.Getb( .cLetra, lcSegut )
			endwith
		else
			local lcSegut as String, lcRetorno as string, lcPase as String, lcCheckSum as String, i as integer, ;
				lcAleatorio as String, lcModulos as String, lcSerie as String, lcVersion as String, ;
				loModulos as zoocoleccion OF zoocoleccion.prg, loItem as Object, lnCheckSum as Integer

			store "" to lcSerie, lcVersion

			with this
				lcSerie = .leer( 1 )

				lcVersion = iif( empty( _screen.zoo.app.cVersionPKW ) or val( _screen.zoo.app.cVersionPKW ) < 1, "1.00", _screen.zoo.app.cVersionPKW )
				if empty( .cLetra )
					.cLetra = "Z"
				endif

				lcSegut = .CompactarSegut( .ObS() )
				lcAleatorio = right( "000000" + ltrim( str( int( rand( 0 ) * 1000000000 ) ) ), 2 )

				loModulos = goModulos.ObtenerModulos()
			
				lcModulos = ""
				for each loItem in loModulos
					lcModulos = lcModulos + iif( loItem.lHabilitado, "1", "0" )
				endfor
				lcModulos = right( "000000" + alltrim( str( .BinToDec( lcModulos ) ) ), 6 )

				lcRetorno = .cLetra + "." ;
					+ substr( lcSerie, 1, 1 ) + substr( lcSerie, 3, 1 ) + "." + substr( lcSerie, 4, 2 ) + "." ;
					+ substr( lcSerie, 6, 1 ) + substr( lcSegut, 1, 1 ) + "." + substr( lcSegut, 2, 2 ) + "." ;
					+ substr( lcModulos, 1, 2 ) + "." + substr( lcModulos, 3, 2 ) + "." + substr( lcModulos, 5, 2 ) + "." + ;
					lcAleatorio

				lcPase = lcRetorno + left( lcVersion, 1 ) + substr( lcVersion, 3, 2 )

				lnCheckSum = 0
				for i = 1 to 28
					lnCheckSum = lnCheckSum + asc( substr( lcPase, i, 1 ) )
				next

				lcCheckSum = right( alltrim( str( lnCheckSum ) ), 2 )
				lcRetorno = lcRetorno + "." + lcCheckSum + "." + left( lcVersion, 1 ) + substr( lcVersion, 3, 2 )
			endwith
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BinToDec( tcNumero as String ) as Integer
		local lnRetorno as Integer, i as Integer, lnLargo as Integer, k as Integer

		lnLargo = 19
		lnRetorno = 0

		tcNumero = right( replicate( "0", lnLargo ) + tcNumero, lnLargo )

		i = lnLargo
		k = 1

		do while i >= 1
			lnRetorno = lnRetorno + ( val( substr( tcNumero, k, 1 ) ) * ( 2 ^ ( i - 1 ) ) )
			i = i - 1
			k = k + 1
		enddo

		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompactarSegut( tcSegut as String ) as String
		local lcRetorno
		store "" to lcRetorno

		lcRetorno = right( "000000000" + alltrim( tcSegut ), 9 )
		lcRetorno = right( "000000000" + alltrim( str( ( asc( substr( lcRetorno, 1, 1 ) ) * 256 ) ;
			+ ( asc( substr( lcRetorno, 2, 1 ) ) * 128 ) + ( asc( substr( lcRetorno, 3, 1 ) ) * 64 ) ;
			+ ( asc( substr( lcRetorno, 4, 1 ) ) * 32 ) + ( asc( substr( lcRetorno, 5, 1 ) ) * 16 ) ;
			+ ( asc( substr( lcRetorno, 6, 1 ) ) * 8 ) + ( asc( substr( lcRetorno, 7, 1 ) ) * 4 ) ;
			+ ( asc( substr( lcRetorno, 8, 1 ) ) * 2 ) + ( asc( substr( lcRetorno, 9, 1 ) ) * 1 ) ) ), 3 )

		lcRetorno = padl( alltrim( str( val( lcRetorno ) ) ), 3, "0" )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function PedirDBloq() as Void
		local lcCodBloq as String, lcCodDesBloq as String, lnSecs as Integer, llDesAutoOk as Boolean, loerror As Exception, lcM as String, lcE As String;
		lnSeconds as double

		llDesAutoOk = .f.
		lcCodDesBloq = ""
		lnCantidadDeIntententosFallidosAlPedirCodigo = goServicios.Registry.Nucleo.Sc.CantidadDeIntententosFallidosAlPedirCodigo
		lcCodBloq = this.ArmBloq()

		if this.cLetra # "L"
			This.LogueoSC( "", lcCodBloq + "(AUTO)" )
			goMensajes.EnviarSinEspera( "Espere por favor..." )			

			if goServicios.Registry.Nucleo.Sc.PedirSCAutomaticamente = .t.
				lcCodDesBloq = this.DesAuto( lcCodBloq )
			else
				This.LogueoSC( "", "Pedido Automatico Falso")
			endif

			llDesAutoOk = !empty( lcCodDesBloq ) and this.VDB( lcCodDesBloq, lcCodBloq )
			
			lcM = strtran( substr( lcCodDesBloq, 01, 08 ), "-", "" )
			lcE = strtran( substr( lcCodDesBloq, 13, 05 ), "-", "" )
			This.LogueoSC( "ENT", lcM + "*" + lcE + "*" + iif( llDesAutoOk, "OK", "MAL" ) )

			goMensajes.Enviarsinespera( .t. )
		endif

		if llDesAutoOk
			goServicios.Registry.Nucleo.Sc.CantidadDeIntententosFallidosAlPedirCodigo = 0
		else
			try
				_Screen.Zoo.App.lf2 = .F.
				This.LogueoSC( "", lcCodBloq )

				lnSeconds = seconds()				
				lcCodDesBloq = This.MostrarSCX( "frmCodigobloq", .t., lcCodBloq )
				lnSeconds = seconds() - lnSeconds 
				goServicios.Mensajes.nSegundosInteraccion = goServicios.Mensajes.nSegundosInteraccion + lnSeconds
				
			catch to loerror
				goServicios.Errores.LevantarExcepcion( loerror )
			finally
				_Screen.Zoo.App.lf2 = .T.
			endtry
		endif

		if empty( lcCodDesBloq ) and this.cLetra # "L" 
			_screen.zoo.app.salir()
		else
			if llDesAutook
			else
				This.VBloqAuto( lnCantidadDeIntententosFallidosAlPedirCodigo )
			endif
		endif

		return strtran( lcCodDesBloq, "-", "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DesAuto( tcCodBloq as String ) as String
		local lcCodBloq as String, lcCandado as String, lcDesBloq as String
		
		lcCodBloq = substr( strtran( tcCodBloq, ".", "" ), 2 )
		lcCandado = this.ArmarCandado()
		lcDesBloq = this.PedirDesAuto( "www.zoologicnet.com.ar", lcCodBloq, lcCandado )
		if empty( lcDesBloq )
			lcDesBloq = this.PedirDesAuto( "zoologic.dyndns.org", lcCodBloq, lcCandado )
		endif
		
		return lcDesBloq
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function PedirDesAuto( tcDominio as String, tcCodRetorno as String, tcCandado as String ) as String
		local lcUrl as String, lcDesactivacion as String, lcNombreArchivo as String, i as Integer, lcSerie as String
		store "" to lcDesactivacion
		
		lcSerie = _Screen.Zoo.App.cSerie
		if empty( lcSerie )
			lcSerie = this.leer( 1 )
		endif
		lcNombreArchivo = addbs( _Screen.Zoo.cRutaInicial ) + "desbloq.zzz"
		with this
			lcUrl = "http://" + tcDominio + "/zoologic/retorno.asp?a=" + lcSerie + "&b=" + tcCandado + "&c=" + .cLetra + "&d=" + tcCodRetorno+ "&e=Web_Auto"

			i = 1
			do while i <= 2 and empty( lcDesactivacion )
				if .DownloadRet( lcUrl, lcNombreArchivo )
					if file( lcNombreArchivo )
						lcDesactivacion =  filetostr( lcNombreArchivo )
						delete file ( lcNombreArchivo )
					endif
				endif
				i = i + 1 
			enddo
		endwith

		return lcDesactivacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DownloadRet( tcUrl as String, tcNombreArchivo as String ) as Boolean
		local llRetorno as Boolean, loAccInternet as AccesoAInternet of accesoAInternet.prg
		store .f. to llRetorno

		try
			loAccInternet = _screen.zoo.CrearObjeto( "AccesoAInternet" )
			delete file lower( tcNombreArchivo )
			llRetorno = loAccInternet.DescargarArchivo( tcUrl, tcNombreArchivo )
		catch
		endtry

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ArmarCandado() as String
		local lcRetorno as String, lcSerie as String
		store "" to lcRetorno
		
		lcSerie = this.Leer( 1 )
		lcRetorno = asc( substr( lcSerie, 1, 1 ) ) * 109
		lcRetorno = lcRetorno + asc ( substr( lcSerie, 2, 1 ) ) * 277
		lcRetorno = lcRetorno + asc ( substr( lcSerie, 3, 1 ) ) * 199
		lcRetorno = lcRetorno + asc ( substr( lcSerie, 4, 1 ) ) * 251
		lcRetorno = lcRetorno + asc ( substr( lcSerie, 5, 1 ) ) * 178
		lcRetorno = lcRetorno + asc ( substr( lcSerie, 6, 1 ) ) * 199
		lcRetorno = lcRetorno * day ( goLibrerias.ObtenerFecha() ) * 179
		lcRetorno = alltrim ( str( int( lcRetorno * month( goLibrerias.ObtenerFecha() ) ) ) )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ArmarColeccion1( tnId as Integer ) as Collection
		local loColeccion as Collection
		
		loColeccion = newobject( "Collection" )
		
		with loColeccion
			do case
				case tnId = 1
					.add( 2290 )
					.add( 8110 )
					.add( 5350 )
					.add( 5289 )
					.add( 1635 )
				case tnId = 2
					.add( 7886 )
					.add( 8054 )
					.add( 345 )
					.add( 7981 )
					.add( 2080 )
					
				case tnId = 3
					.add( 1236 )
					.add( 2402 )
					.add( 670 )
					.add( 1003 )
					.add( 4935 )

				case tnId = 4
					.add( 3440 )
					.add( 2472 )
					.add( 1766 )
					.add( 5739 )
					.add( 2062 )

				case tnId = 5
					.add( 7376 )
					.add( 3206 )
					.add( 3852 )
					.add( 6638 )
					.add( 1795 )

				case tnId = 6
					.add( 2193 )
					.add( 4020 )
					.add( 3679 )
					.add( 3689 )
					.add( 5052 )

				case tnId = 7
					.add( 3041 )
					.add( 3157 )
					.add( 3189 )
					.add( 6048 )
					.add( 3224 )

				case tnId = 8
					.add( 5370 )
					.add( 5211 )
					.add( 4259 )
					.add( 6756 )
					.add( 2524 )

				case tnId = 9
					.add( 2578 )
					.add( 6902 )
					.add( 7593 )
					.add( 5569 )
					.add( 7824 )

				case tnId = 10
					.add( 1601 )
					.add( 8092 )
					.add( 6823 )
					.add( 1962 )
					.add( 2086 )

				case tnId = 11
					.add( 4738 )
					.add( 5090 )
					.add( 639 )
					.add( 1597 )
					.add( 8453 )

				case tnId = 12
					.add( 1478 )
					.add( 6708 )
					.add( 2227 )
					.add( 5564 )
					.add( 1680 )

				case tnId = 13
					.add( 2868 )
					.add( 963 )
					.add( 5696 )
					.add( 7267 )
					.add( 4253 )

				case tnId = 14
					.add( 3054 )
					.add( 1851 )
					.add( 969 )
					.add( 5642 )
					.add( 7363 )
					
				case tnId = 15
					.add( 1866 )
					.add( 5166 )
					.add( 709 )
					.add( 4300 )
					.add( 3001 )
					
				case tnId = 16
					.add( 3953 )
					.add( 5603 )
					.add( 3431 )
					.add( 5238 )
					.add( 6224 )
					
				case tnId = 17
					.add( 4876 )
					.add( 8049 )
					.add( 7424 )
					.add( 2329 )
					.add( 3091 )
					
				case tnId = 18
					.add( 573 )
					.add( 814 )
					.add( 2974 )
					.add( 2161 )
					.add( 4790 )
					
				case tnId = 19
					.add( 2096 )
					.add( 701 )
					.add( 7092 )
					.add( 4061 )
					.add( 132 )
					
				case tnId = 20
					.add( 6367 )
					.add( 3402 )
					.add( 6774 )
					.add( 7254 )
					.add( 4217 )
					
				case tnId = 21
					.add( 4651 )
					.add( 8394 )
					.add( 163 )
					.add( 6744 )
					.add( 7102 )
					
				case tnId = 22
					.add( 1148 )
					.add( 4814 )
					.add( 8132 )
					.add( 5185 )
					.add( 5953 )
					
				case tnId = 23
					.add( 4381 )
					.add( 3337 )
					.add( 2563 )
					.add( 1367 )
					.add( 5275 )
					
				case tnId = 24
					.add( 3842 )
					.add( 6692 )
					.add( 427 )
					.add( 3985 )
					.add( 301 )
					
				case tnId = 25
					.add( 5435 )
					.add( 1394 )
					.add( 7053 )
					.add( 2886 )
					.add( 2879 )
					
				case tnId = 26
					.add( 8030 )
					.add( 4280 )
					.add( 3278 )
					.add( 6660 )
					.add( 2675 )
					
				case tnId = 27
					.add( 658 )
					.add( 1890 )
					.add( 5689 )
					.add( 3990 )
					.add( 2713 )
					
				case tnId = 28
					.add( 7989 )
					.add( 4836 )
					.add( 3397 )
					.add( 1299 )
					.add( 7553 )
					
				case tnId = 29
					.add( 3096 )
					.add( 4963 )
					.add( 7515 )
					.add( 3187 )
					.add( 4180 )
					
				case tnId = 30		
					.add( 7722 )
					.add( 8078 )
					.add( 488 )
					.add( 8044 )
					.add( 5658 )

				case tnId = 31				
					.add( 2543 )
					.add( 105 )
					.add( 5430 )
					.add( 1998 )
					.add( 7301 )

				case tnId = 32	
					.add( 1442 )
					.add( 1942 )
					.add( 8501 )
					.add( 6329 )
					.add( 500 )
				case tnId = 33	
					.add( 949 )
					.add( 2685 )
					.add( 4092 )
					.add( 1977 )
					.add( 304 )
					
				case tnId = 34	
					.add( 4824 )
					.add( 2288 )
					.add( 1545 )
					.add( 5871 )
					.add( 74 )

				case tnId = 35	
					.add( 1154 )
					.add( 2279 )
					.add( 1827 )
					.add( 6770 )
					.add( 308 )

				case tnId = 36
					.add( 1063 )
					.add( 2963 )
					.add( 6399 )
					.add( 4111 )
					.add( 636 )

				case tnId = 37	
					.add( 6028 )
					.add( 6516 )
					.add( 6263 )
					.add( 4795 )
					.add( 6526 )

				case tnId = 38
					.add( 8555 )
					.add( 9183 )
					.add( 2477 )
					.add( 5614 )
					.add( 3858 )

				case tnId = 39
					.add( 3141 )
					.add( 6418 )
					.add( 7211 )
					.add( 3615 )
					.add( 5705 )

				case tnId = 40
					.add( 3602 )
					.add( 6110 )
					.add( 1971 )
					.add( 9062 )
					.add( 4050 )
					
				case tnId = 41
					.add( 9007 )
					.add( 7166 )
					.add( 4892 )
					.add( 5025 )
					.add( 5725 )										

				case tnId = 42
					.add( 3166 )
					.add( 6067 )
					.add( 7221 )
					.add( 9203 )
					.add( 6123 )
			endcase
		endwith		
		
		return loColeccion 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarColeccion2( tnId as Integer ) as Collection
		local loColeccion as Collection
		
		loColeccion = newobject( "Collection" )
		
		with loColeccion
			do case
				case tnId = 1
					.add( 725 )
					.add( 6550 )
					.add( 3226 )
					.add( 19 )
					.add( 1982 )

				case tnId = 2
					.add( 785 )
					.add( 927 )
					.add( 3124 )
					.add( 4228 )
					.add( 5109 )

				case tnId = 3
					.add( 220 )
					.add( 7458 )
					.add( 5265 )
					.add( 3215 )
					.add( 8462 )

				case tnId = 4
					.add( 5075 )
					.add( 7019 )
					.add( 3251 )
					.add( 8942 )
					.add( 5263 )
					
				case tnId = 5
					.add( 4852 )
					.add( 1965 )
					.add( 6594 )
					.add( 8884 )
					.add( 6378 )
					
				case tnId = 6
					.add( 8564 )
					.add( 5648 )
					.add( 7523 )
					.add( 3218 )
					.add( 1592 )
					
				case tnId = 7
					.add( 3571 )
					.add( 6548 )
					.add( 8456 )
					.add( 6532 )
					.add( 1254 )

				case tnId = 8
					.add( 5847 )
					.add( 4785 )
					.add( 4458 )
					.add( 6676 )
					.add( 4544 )
					
				case tnId = 9
					.add( 7758 )
					.add( 5428 )
					.add( 5135 )
					.add( 6432 )
					.add( 2772 )
					
				case tnId = 10
					.add( 114 )
					.add( 252 )
					.add( 779 )
					.add( 3256 )
					.add( 5214 )
					
				case tnId = 11
					.add( 6537 )
					.add( 8523 )
					.add( 1652 )
					.add( 7895 )
					.add( 6874 )
					
				case tnId = 12
					.add( 8574 )
					.add( 4582 )
					.add( 6523 )
					.add( 2549 )
					.add( 6435 )
					
				case tnId = 13
					.add( 3253 )
					.add( 8548 )
					.add( 548 )
					.add( 1595 )
					.add( 4584 )
					
				case tnId = 14
					.add( 3128 )
					.add( 135 )
					.add( 1128 )
					.add( 602 )
					.add( 3633 )
					
				case tnId = 15
					.add( 127 )
					.add( 446 )
					.add( 1542 )
					.add( 4235 )
					.add( 6323 )

				case tnId = 16
					.add( 2636 )
					.add( 5120 )
					.add( 8475 )
					.add( 3668 )
					.add( 1758 )
					
				case tnId = 17
					.add( 2078 )
					.add( 4096 )
					.add( 8192 )
					.add( 1417 )
					.add( 1523 )
					
				case tnId = 18
					.add( 730 )
					.add( 450 )
					.add( 1819 )
					.add( 4200 )
					.add( 3056 )
					
				case tnId = 19
					.add( 3366 )
					.add( 7558 )
					.add( 4589 )
					.add( 6466 )
					.add( 6785 )
					
				case tnId = 20
					.add( 13 )
					.add( 3999 )
					.add( 7342 )
					.add( 3884 )
					.add( 8443 )
					
				case tnId = 21
					.add( 8903 )
					.add( 172 )
					.add( 1590 )
					.add( 8965 )
					.add( 3877 )

				case tnId = 22
					.add( 1328 )
					.add( 4771 )
					.add( 1377 )
					.add( 2204 )
					.add( 5450 )
					
				case tnId = 23
					.add( 2940 )
					.add( 4586 )
					.add( 6556 )
					.add( 5777 )
					.add( 2411 )
					
				case tnId = 24
					.add( 8588 )
					.add( 4913 )
					.add( 5226 )
					.add( 5096 )
					.add( 7779 )

				case tnId = 25
					.add( 1019 )
					.add( 4400 )
					.add( 7416 )
					.add( 8028 )
					.add( 2747 )
					
				case tnId = 26
					.add( 1360 )
					.add( 5596 )
					.add( 4747 )
					.add( 2000 )
					.add( 1170 )
					
				case tnId = 27
					.add( 3068 )
					.add( 6830 )
					.add( 4402 )
					.add( 2699 )
					.add( 6186 )

				case tnId = 28
					.add( 8691 )
					.add( 3392 )
					.add( 1855 )
					.add( 5518 )
					.add( 418 )
					
				case tnId = 29
					.add( 580 )
					.add( 7039 )
					.add( 6091 )
					.add( 6116 )
					.add( 6868 )
					
				case tnId = 30
					.add( 8852 )
					.add( 6996 )
					.add( 1166 )
					.add( 6611 )
					.add( 4985 )

				case tnId = 31				
					.add( 5486 )
					.add( 506 )
					.add( 1989 )
					.add( 333 )
					.add( 8989 )

				case tnId = 32	
					.add( 8546 )
					.add( 6954 )
					.add( 654 )
					.add( 102 )
					.add( 2458 )

				case tnId = 33	
					.add( 111 )
					.add( 7531 )
					.add( 9513 )
					.add( 4563 )
					.add( 4289 )
					
				case tnId = 34	
					.add( 3270 )
					.add( 8298 )
					.add( 7890 )
					.add( 2795 )
					.add( 4881 )

				case tnId = 35	
					.add( 1534 )
					.add( 4356 )
					.add( 4636 )
					.add( 7596 )
					.add( 9191 )

				case tnId = 36	
					.add( 4760 )
					.add( 5769 )
					.add( 7985 )
					.add( 3622 )
					.add( 3888 )

				case tnId = 37	
					.add( 9050 )
					.add( 8771 )
					.add( 7771 )
					.add( 3335 )
					.add( 2322 )

				case tnId = 38
					.add( 3467 )
					.add( 4082 )
					.add( 2128 )
					.add( 6562 )
					.add( 5240 )

				case tnId = 39
					.add( 5544 )
					.add( 1268 )
					.add( 8764 )
					.add( 9418 )
					.add( 6666 )

				case tnId = 40
					.add( 5003 )
					.add( 1743 ) 
					.add( 9520 )
					.add( 4672 )
					.add( 2989 )	

				case tnId = 41
					.add( 7007 )
					.add( 9166 )
					.add( 2892 )
					.add( 3025 )
					.add( 3725 )									

				case tnId = 42
					.add( 2390 )
					.add( 6722 )
					.add( 7923 )
					.add( 9017 )
					.add( 5933 )

			endcase
		endwith		
		
		return loColeccion 
	endfunc 

	* -----------------------------------------------------------------------------------------
	function ObtenerC( tcSerie as String ) as string
		local lcRetorno as String 
		lcRetorno = ''

		lcRetorno = 			( asc( substr( tcSerie, 1, 1 ) ) * 7 )
		lcRetorno = lcRetorno + ( asc( substr( tcSerie, 2, 1 ) ) * 5 )
		lcRetorno = lcRetorno + ( asc( substr( tcSerie, 3, 1 ) ) * 3 )
		lcRetorno = lcRetorno + ( asc( substr( tcSerie, 4, 1 ) ) * 2 )
		lcRetorno = lcRetorno + ( asc( substr( tcSerie, 5, 1 ) ) * pi() )
		lcRetorno = lcRetorno + ( asc( substr( tcSerie, 6, 1 ) ) )
		lcRetorno = lcRetorno * pi() * 1000
		lcRetorno = lcRetorno + val( tcSerie )
		
		lcRetorno = strtran( transform( val( right( '000000' + alltrim( str( lcRetorno, 20 ) ), 6 ) ) ,'99-99-99' ), ' ', '0')
		lcRetorno = right( '00' + alltrim( lcRetorno ), 8 )

		return lcRetorno
	endfunc
	
	* -----------------------------------------------------------------------------------------
	function ObtenerActualizacion( tcSerie, tcVersion ) as String
		local lcRetorno, lcVersion, lcCodigo, lcCheck
		store '' to lcRetorno, lcVersion, lcCodigo, lcCheck

		lcVersion = strtran( tcVersion, '.', '' )

		if empty( lcVersion )
		else
			lcRetorno = right( '0000000' + alltrim( str( val( tcSerie ) * 7 ) ), 7 )

			lcCodigo =				val( substr( lcRetorno, 1, 1 ) ) * 33
			lcCodigo = lcCodigo + ( val( substr( lcRetorno, 2, 1 ) ) * 51 )
			lcCodigo = lcCodigo + ( val( substr( lcRetorno, 3, 1 ) ) * 74 )
			lcCodigo = lcCodigo + ( val( substr( lcRetorno, 4, 1 ) ) * 119 )
			lcCodigo = lcCodigo + ( val( substr( lcRetorno, 5, 1 ) ) * 123 )
			lcCodigo = lcCodigo + ( val( substr( lcRetorno, 6, 1 ) ) * 227 )
			lcCodigo = lcCodigo + ( val( substr( lcRetorno, 7, 1 ) ) * 351 )

			lcCodigo = int( lcCodigo * ( lcCodigo / 2 ) )
			lcCodigo = lcCodigo + ( val( substr( lcVersion, 1, 1 ) ) * 33 )
			lcCodigo = lcCodigo + ( val( substr( lcVersion, 2, 1 ) ) * 55 )
			lcCodigo = lcCodigo + ( val( substr( lcVersion, 3, 1 ) ) * 77 )

			lcCheck =			asc( substr( lcRetorno, 1, 1 ) )
			lcCheck = lcCheck + asc( substr( lcRetorno, 2, 1 ) )
			lcCheck = lcCheck + asc( substr( lcRetorno, 3, 1 ) )
			lcCheck = lcCheck + asc( substr( lcRetorno, 4, 1 ) )
			lcCheck = lcCheck + asc( substr( lcRetorno, 5, 1 ) )
			lcCheck = lcCheck + asc( substr( lcRetorno, 6, 1 ) )
			lcCheck = right( alltrim( str( lcCheck ) ), 1 )

			lcRetorno = lcVersion + right( '0000' + alltrim( str( lcCodigo ) ), 4 ) + lcCheck
			lcRetorno = substr( lcRetorno, 1, 2 ) + '-' + substr( lcRetorno, 3, 2 ) + '-' + substr( lcRetorno, 5, 2 ) + '-' + substr( lcRetorno, 7, 2 )

		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerMF() as String

		Local lcReturn As String
		lcReturn = ""

		Declare Integer GetAdaptersInfo In iphlpapi ;
			string @pAdapterInfo, Long @pOutBufLen

		Local lcBuffer As String, lnBufsize As Number, q As Number
		lnBufsize = 0
		lcBuffer = ""

	* usually returns: ERROR_BUFFER_OVERFLOW (111)
		=GetAdaptersInfo(@lcBuffer, @lnBufsize)

	* build buffer string from nulls
		lcBuffer = Replicate(Chr(0), lnBufsize)

		If GetAdaptersInfo(@lcBuffer, @lnBufsize) <> 0 && ERROR_SUCCESS
	* no way, José
		Else
			Local lnAddrlen, lcAddress, ii
	* 401st byte = size of NIC address string
			lnAddrlen = Asc(Substr(lcBuffer, 401, 1))
	* NIC address starts = byte 405
			lcAddress = Substr(lcBuffer, 405, lnAddrlen)

			For q = 1 To lnAddrlen
				lcReturn = lcReturn + goLibrerias.DecToHexFisica( Asc(Substr(lcAddress,q,1) ), 2 )
			Next
		Endif

		Return Upper( lcReturn )
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObS() as String
		local lcS as character, lcRetorno as characterç

		store "" to lcRetorno

		lcS = this.leer( 1 )
		if !this.EsD( lcS )
			local lcM, lcD, lcV
			store "" to lcM, lcD, lcV

			this.BC( @lcM, @lcD, @lcV )


			lcRetorno = this.VM( lcS, lcM )
			if empty( lcRetorno )
				lcRetorno = this.VD( lcS, lcD )
			endif
			if empty( lcRetorno )
				lcRetorno = this.VV()
			endif

		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function BC( tcM as String, tcD as String, tcV as String ) as String
		if !file( addbs( _screen.zoo.cRutaInicial ) + "ID.TXT" )
			return
		endif

		local lcContenido, lcCLVS, lnPosi1, lnPosi2, lnPosi3
		store "" to lcContenido, lcCLVS
		store 0 to lnPosi1, lnPosi2, lnPosi3

		lcContenido = filetostr( addbs( _screen.zoo.cRutaInicial ) + "id.txt" )

		lcCLVS = left( this.LimpiarC( lcContenido ), 30 )

		
		lnPosi1 = at( "M", lcCLVS )
		if lnPosi1 # 0
			tcM = substr( lcCLVS, lnPosi1, 10 )
		endif

		lnPosi2 = at( "D", lcCLVS )
		if lnPosi2 # 0
			tcD = substr( lcCLVS, lnPosi2, 10 )
		endif

		lnPosi3 = iif( ( lnPosi1 + lnPosi2 = 12 ), 21, iif( ( (lnPosi1 + lnPosi2 = 22) or (lnPosi1 + lnPosi2 = 1) ), 11, 1 ) )
		tcV = substr( lcCLVS, lnPosi3, 10 )
		
		return
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LimpiarC( tcContenido as String ) as String
		local lcRetorno as String
		store "" to lcRetorno

		lcRetorno = alltrim( tcContenido )
		lcRetorno = strtran( lcRetorno, chr( 10 ), "" )
		lcRetorno = strtran( lcRetorno, chr( 13 ), "" )
		lcRetorno = strtran( lcRetorno, chr( 32 ), "" )
		lcRetorno = strtran( lcRetorno, chr( 9 ), "" )
		lcRetorno = alltrim( lcRetorno )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VM( tcS as String, tcIdM as String ) as String
		local lcRetorno as String, lcContenido as String
		store "" to lcRetorno, lcContenido, pcConte2, pcConte3

		if tcIdM # this.IdM( tcS )
			
			if !_screen.zoo.app.lEsEntornoCloud 
				lcContenido = goServicios.Transferencias.obtenerMA()
			else
				lcContenido = goLibrerias.ObtenerNombreEquipo()
			endif
			
			if this.ChkCarpe( _screen.zoo.cRutaInicial, this.IdM( this.leer( 1 ) ) )
				lcRetorno = lcContenido
			else
				lcRetorno = right( "000000000" + lcContenido + sys( 2007, upper( _screen.zoo.cRutaInicial ) ), 9 )
			endif
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function IdM( tcS as String ) as String
		local lcRetorno as String
		store "" to lcRetorno

		lcRetorno = asc( substr( tcS, 1, 1 ) ) * 9
		lcRetorno = lcRetorno + ( asc( substr( tcS, 2, 1 ) ) * 7 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 3, 1 ) ) * 17 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 4, 1 ) ) * 19 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 5, 1 ) ) * 11 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 6, 1 ) ) * 13 )
		lcRetorno = lcRetorno + val( tcS )
		lcRetorno = lcRetorno * 393 * val( tcS )
		lcRetorno = "M" + right( "0000000000" + alltrim( str( lcRetorno, 20 ) ) , 9 )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ChkCarpe( tcRuta, tcIdM ) as Void
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDO( toObjeto as Object ) as Void
		this.SetearS( toObjeto.Serie )
		for i = 1 to 4
			this.Escribir( i + 3, this.Fraccionar10( toObjeto.Nombre, i ) )
			this.Escribir( i + 7, this.Fraccionar10( toObjeto.Org, i ) )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Fraccionar10( tcCadena as String, tnParte as Integer ) as Void
		return strtran( padr( substr( tcCadena, (( tnParte - 1 ) * 10) + 1, 10 ), 10 ), " ", "Ï" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VD( tcS, tcD ) as Void
		private pcRetorno
		store "" to pcRetorno

		if tcD != this.IdD( tcS )
			pcRetorno = this.FACE77( tcS )
		endif

		return pcRetorno
	endfunc

	* -----------------------------------------------------------------------------------------
	function ObtenerClaveBlanqueoAdmin( tcX2 )
		local lcRetorno as string, lcClave as string, lcId as string, lcIdDisco as string
		lcRetorno = ''

		with this
			lcClave = .ObtenerC( tcX2 )
			lcId = .idv( tcX2 )
			lcIdDisco = .idd( tcX2 )

			lcRetorno = 			( asc( substr( lcClave  , 1, 1 ) ) * 3 )
			lcRetorno = lcRetorno + ( asc( substr( lcId     , 2, 1 ) ) * 14 )
			lcRetorno = lcRetorno + ( asc( substr( lcIdDisco, 3, 1 ) ) * 9 )
			lcRetorno = lcRetorno + ( asc( substr( lcId     , 4, 1 ) ) * 7 )
			lcRetorno = lcRetorno + ( asc( substr( lcClave  , 5, 1 ) ) * 4 )
			lcRetorno = lcRetorno + ( asc( substr( lcIdDisco, 6, 1 ) ) * 8 )
			lcRetorno = lcRetorno + val( tcX2 )
			lcRetorno = lcRetorno * 351 * val( tcX2 )
			lcRetorno = 'B' + right( '0000000000' + alltrim( str( lcRetorno, 20 ) ), 9 )

		endwith

		return lcRetorno
	endfunc
 
	*-----------------------------------------------------------------------------------------
	protected function IdD( tcS as String ) as String
		local lcRetorno
		store "" to lcRetorno

		lcRetorno = asc( substr( tcS, 1, 1 ) ) * 5
		lcRetorno = lcRetorno + ( asc( substr( tcS, 2, 1 ) ) * 17 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 3, 1 ) ) * 11 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 4, 1 ) ) * 9 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 5, 1 ) ) * 7 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 6, 1 ) ) * 11 )
		lcRetorno = lcRetorno + val( tcS )
		lcRetorno = lcRetorno * 477 * val( tcS )
		lcRetorno = "D" + right( "0000000000" + alltrim( str( lcRetorno, 20 ) ), 9 )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Face74( tnTipo as Integer, tcS as String )
		do case
		case tnTipo = 1
			this.GuardarIdTxt( this.IdM( tcS ) )
		case tnTipo = 2
			this.GuardarIdTxt( this.IdD( tcS ) )
			this.GuardarIdTxt( this.IdV( tcS ) )
		otherwise
		endcase

		goLibrerias.ConstTextoAndGo( "CHK'38' - REINTENTE el ingreso.", .t. )
	endfunc

	*-----------------------------------------------------------------------------------------
	function IdV( tcS as String )
		local lcRetorno
		store "" to lcRetorno

		lcRetorno = asc( substr( tcS, 1, 1 ) ) * 3
		lcRetorno = lcRetorno + ( asc( substr( tcS, 2, 1 ) ) * 11 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 3, 1 ) ) * 17 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 4, 1 ) ) * 7 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 5, 1 ) ) * 5 )
		lcRetorno = lcRetorno + ( asc( substr( tcS, 6, 1 ) ) * 9 )
		lcRetorno = lcRetorno + val( tcS )
		lcRetorno = lcRetorno * 567 * val( tcS )
		lcRetorno = right( "0000000000" + alltrim( str( lcRetorno, 20 ) ), 10 )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Face77( tcS as String )
		local lcArchivo as String, lcOldDefa As String, lcRutaOrigen as String
		
		lcRutaOrigen = _Screen.Zoo.cRutaInicial
		
		lcArchivo = addbs( lcRutaOrigen ) + "pkware.exe"
		
		if !file( lcArchivo )
			goLibrerias.ConstTextoAndGo( "PK.EXE'30'", .t. )
		endif

		local lnRandom, lcExe, lnSegInicial, lcRetorno, lnHandler, lcConte, lcConte2;
			, lcConte3, llPrimerParte, i

		store "" to lcRetorno

		lnRandom = rand( -1 )
		lnRandom = int( rand() * 100000 )

		lnSegInicial = seconds()
		
		if this.lModoSeriesPorPerfil
			lcOldDefa = lcRutaOrigen 
		else
			lcOldDefa = sys(5) + sys(2003)
		endif

		set default to ( addbs( lcRutaOrigen ) )
		_Screen.Zoo.EjecutaDOS( '"' + lcArchivo + '" ' + transform( lnRandom ), .f., .f. )
		set default to ( lcOldDefa )

		if !file( addbs( lcRutaOrigen  ) + "RXTUW.DAT" )
			goLibrerias.ConstTextoAndGo( "PK.EXE'32'", .t. )		
		endif
		if ( seconds() - lnSegInicial ) > 30
			this.Face74( 2, tcS )
		endif

		store fopen( "RXTUW.DAT" ) to lnHandler
		lcConte = fread( lnHandler, 50 )
		= fclose( lnHandler )

		delete file ( "RXTUW.DAT" )

		lcConte2 = ""
		lcConte3 = ""
		llPrimerParte = .t.
		for i = 1 to len( lcConte )
			if !inlist( asc( substr( lcConte, i, 1 ) ), 10, 13, 32 )
				if llPrimerParte
					lcConte2 = lcConte2 + substr( lcConte, i, 1 )
				else
					lcConte3 = lcConte3 + substr( lcConte, i, 1 )
				endif
			else
				llPrimerParte = .f.
			endif
		next
		lcConte2 = alltrim( lcConte2 )
		lcConte3 = alltrim( lcConte3 )

		lcOrig1 = goLibrerias.DecToBin( 65443 )
		lcOrig2 = goLibrerias.DecToBin( lnRandom + 15674 )
		lcOrigF = ""
		for llPrimerParte = 1 to 19
			if ( substr( lcOrig1, llPrimerParte, 1 ) = "1" and substr( lcOrig2, llPrimerParte, 1 ) = "0" ) ;
					or ( substr( lcOrig1, llPrimerParte, 1 ) = "0" and substr( lcOrig2, llPrimerParte, 1 ) = "1" )
				lcOrigF = lcOrigF + "1"
			else
				lcOrigF = lcOrigF + "0"
			endif
		endfor
		lcOrigF = alltrim( str( goLibrerias.BinToDec( lcOrigF ) ) )

		if lcConte2 == lcOrigF
			if lcConte3 = "0"
				lcRetorno = ""
			else
				if this.ChkCarpe( lcRutaOrigen, this.IdM( this.leer( 1 ) ) )
					lcRetorno = lcConte3
				else
					lcRetorno = right( "000000000" + lcConte3 ;
						+ sys( 2007, upper( left( lcRutaOrigen , len( lcRutaOrigen  ) -1 ) ) ), 9 )
				endif
			endif
		else
			goLibrerias.ConstTextoAndGo( "PK.EXE'36'", .t. )
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VV()
		local lcV as String
		lcV = goLibrerias.ObV( "", 2 )

		if this.ChkCarpe( _screen.zoo.cRutaInicial, this.IdM( this.leer( 1 ) ) )
			lcRetorno = lcV
		else
			lcRetorno = right( "000000000" + lcV + sys( 2007, upper( left( _screen.zoo.cRutaInicial, len( _screen.zoo.cRutaInicial ) -1 ) ) ), 9 )
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GuardarIdTxt( tcContenido )
		local lnHandler
		store 0 to lnHandler

		if file( this.cPathLince + "ID.TXT" )
			lnHandler = fopen( this.cPathLince + "ID.TXT", 12 )
			if lnHandler >= 0
				= fseek( lnHandler, 0, 2 )
			endif
		else
			lnHandler = fcreate( this.cPathLince + "ID.TXT" )
		endif
		if lnHandler >= 0
			= fputs( lnHandler, tcContenido )
			= fclose( lnHandler )
		endif

		return
	endfunc

	*-----------------------------------------------------------------------------------------
	function Vdb( tcCDesact as string, tcCRet as string ) as boolean
		local lcAppAux As String

		*----- Nuevos códigos solo para ZL y DragonFish por ahora.
		lcAppAux = alltrim(_Screen.zoo.app.cProducto )
		if  inlist( lcAppAux , "03", "06" )
			local llRetorno as Boolean

			llRetorno = this.oDes.DesarmarRetorno( _screen.zoo.app.ObtenerBuild(), tcCDesact )
		else
			local llRetorno as boolean, i as integer, lcControl as string, lnControl as integer, lcControl2 as string, ;
				ldFecha as fate, lcM as String, lcE as String

			lnControl = 0
			llRetorno = .t.
			tcCDesact = trim( tcCDesact )

			for i = 1 to 17
				lnControl = lnControl + asc( substr( tcCDesact, i, 1 ) )
			next

			lcControl = right( alltrim( str( lnControl ) ), 2 )

			ldFecha = goLibrerias.ObtenerFecha() 
			lcControl2 = right( "00";
				+ str( ( val( substr( tcCRet, 6, 2 ) ) ;
				+ val( substr( tcCRet, 9, 2 ) ) ;
				+ val( substr( tcCRet, 12, 2 ) ) ;
				+ val( substr( tcCRet, 15, 2 ) ) ;
				+ val( substr( tcCRet, 18, 2 ) ) ;
				+ val( substr( tcCRet, 21, 2 ) ) ) * ;
				( val( substr( tcCRet, 24, 2 ) ) + 1 ) * ;
				( val( alltrim( substr( tcCRet, 27, 2 ) ) ) + 1 ) * ;
				7 / day( ldFecha ) / month( ldFecha ) ), 2 )

			if substr( tcCDesact, 19, 2 ) # lcControl or substr( tcCDesact, 10, 2 ) # lcControl2
				llRetorno = .f.
			endif

			lcM = strtran( substr( tcCDesact, 01, 08 ), "-", "" )
			lcE = strtran( substr( tcCDesact, 13, 05 ), "-", "" )
			This.LogueoSC( "ENT", lcM + "*" + lcE + "*" + tcCRet + "*" + iif(llRetorno, "OK", "MAL") )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RegMod( tcCodDes as String ) as Void
		local lcAppAux As String

		*----- Nuevos códigos solo para ZL y DragonFish por ahora.
		lcAppAux = alltrim(_Screen.zoo.app.cProducto )
		if  inlist( lcAppAux , "03", "06" )
			local lcCalculo as String
			
			lcCalculo = goLibrerias.DecToBin( val( this.oDes.cModulos ))
			goModulos.RegModAct( lcCalculo )
			
			this.Escribir( 13, this.oDes.cCHKTotal )	&& unicidad interna
		else
			local lcCalculo as String

			lcCalculo = goLibrerias.DecToBin( val( alltrim( substr( tcCodDes, 1, 2 ) ) ;
				+ alltrim( substr( tcCodDes, 3, 2 ) ) ;
				+ alltrim( substr( tcCodDes, 5, 2 ) ) ) )

			goModulos.RegModAct( lcCalculo )
			this.Escribir( 13, alltrim( substr( tcCodDes, 10, 2 ) ) )	&& unicidad interna
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtEntDCodDBloq( tcCodDes as String ) as Integer
		return int( val( alltrim( substr( tcCodDes, 9, 2 ) ) + alltrim( substr( tcCodDes, 11, 2 ) ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstaInstanciado( tcFormulario as String ) 

		local llRetorno as Boolean, lni as Integer 
		llRetorno = .f. 

		for lni=1 to _screen.FormCount
			if pemstatus( _screen.Forms( lni ), "cNombreFormulario", 5 ) and alltrim( upper( _screen.Forms( lni ).cNombreFormulario ) ) == alltrim( upper( tcFormulario ) )
				llRetorno = .t.
				this.nFormularioSingleton = lni
				exit
			endif
		next
		
		return llRetorno
		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VldS( tnId as Integer ) as String
		local lcRetorno as String

		lcRetorno = ""
		if tnId = 1
			this.Escribir( 1, "" )
			this.Escribir( 3, "" )
			goLibrerias.Verificar()
			lcRetorno = this.leer( 1 )
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Fechar2() as Void
		local loerror As Exception, lcSerie As String

		try
			lcSerie = upper( alltrim( this.Leer( 1 ) ) ) && Obtengo el serie
			do case
				case lcSerie == "DEMO"
					if empty( _Screen.zoo.App.cSucursalActiva ) or _Screen.zoo.App.ValidarVersionDemo()
					else
						goServicios.Errores.LevantarExcepcion( "Para poder seguir utilizando el sistema deberá actualizar su versión." )
					EndIf
				case _screen.zoo.app.lf2 and this.dDChk != goLibrerias.ObtenerFecha()
					this.SRE( -1 )
					this.dDChk = goLibrerias.ObtenerFecha()
			endCase
		catch to loerror
			_Screen.Zoo.App.lf2 = .T.
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
	endfunc

	* -----------------------------------------------------------------------------------------
	function ObtenerELince( tcSerie ) as String
		local lcRetorno
		lcRetorno = ''

		lcRetorno = 			( asc( substr( this.cSerie, 1, 1 ) ) * 5 )
		lcRetorno = lcRetorno + ( asc( substr( this.cSerie, 2, 1 ) ) * 7 )
		lcRetorno = lcRetorno + ( asc( substr( this.cSerie, 3, 1 ) ) * 15 )
		lcRetorno = lcRetorno + ( asc( substr( this.cSerie, 4, 1 ) ) * 9 )
		lcRetorno = lcRetorno + ( asc( substr( this.cSerie, 5, 1 ) ) * 3 )
		lcRetorno = lcRetorno + ( asc( substr( this.cSerie, 6, 1 ) ) * 7 )
		lcRetorno = lcRetorno + val( this.cSerie )
		lcRetorno = lcRetorno * 765 * val( this.cSerie )
		lcRetorno = right( '0000000000' + alltrim( str( lcRetorno, 20 ) ), 10 )

		return lcRetorno
	endfunc

	* -----------------------------------------------------------------------------------------
	function ObtenerClaveSalto( tcIdMac ) as String

		return 'M' + left( tcIdMac, 7 ) + '.zoo'

	endfunc
	
	* -----------------------------------------------------------------------------------------
	function ObtenerBoxSalida( tcBoxSerie ) as String

		return left( alltrim( sys( 2007, left( tcBoxSerie, 6 ) ) ) + "     ", 5 )

	endfunc

	* -----------------------------------------------------------------------------------------
	function ObtenerRed( tcUlogica, tcSerie ) as String
		local lcRetorno, lSerie, lCuenta

		tcUlogica = upper( tcUlogica )
		lcRetorno = "U" + tcUlogica
		lnCuenta  = 0

		lnCuenta =			  ( asc( substr( tcSerie, 1, 1 ) ) * 13 )
		lnCuenta = lnCuenta + ( asc( substr( tcSerie, 2, 1 ) ) + 456 )
		lnCuenta = lnCuenta + ( asc( substr( tcSerie, 3, 1 ) ) * 5 )
		lnCuenta = lnCuenta + ( asc( substr( tcSerie, 4, 1 ) ) * 7 )
		lnCuenta = lnCuenta + ( asc( substr( tcSerie, 5, 1 ) ) * 6 )
		lnCuenta = lnCuenta + ( asc( substr( tcSerie, 6, 1 ) ) * 13 )
		lnCuenta = lnCuenta + ( asc( tcUlogica ) * 33 )
		lnCuenta = lnCuenta + val( tcSerie ) * 5
		lnCuenta = lnCuenta * 86 * val( tcSerie )
		lcRetorno = lcRetorno + right( "0000000000" + alltrim( str( lnCuenta, 20 ) ), 8 )

		return lcRetorno
	endfunc

	* -----------------------------------------------------------------------------------------
	function ObtenerClaveFecha( tdFecha, tcSerie ) as String
		local lcRetorno

		if empty( tcSerie )
			lcRetorno = '40x...+'
		else
			lcRetorno = tcSerie 
		endif

		lcRetorno = lcRetorno + chr( 64 + day( tdFecha ) ) + chr( 64 + month( tdFecha ) )
		return lcRetorno
	endfunc

	* -----------------------------------------------------------------------------------------	
	function ObtenerClaveRestore( tdFecha ) as String

		return "lince" + chr( 64 + day( tdFecha ) ) + chr( 64 + month( tdFecha ) )
 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function face1( tcTexto as String) as String
		local lcTexto as String, lnLongitud, i

		store 1 to i
		store "" to lcTexto

		lnLongitud = len( tcTexto )
		do while i <= lnLongitud
			lcTexto= lcTexto + right( "00" + ltrim( str( -mod( i, 15 ) + mod( lnLongitud, 7 ) + asc( substr( tcTexto, i, 1) ) ) ), 3 )
			i = i + 1
		enddo
		*Encrip
		return lcTexto
	endfunc

	*-----------------------------------------------------------------------------------------}
	protected function laCefu3() as Boolean
		local llRetorno as Boolean, a as String, b as String, c as String, d as String

		llRetorno = .f.
		a = "SALID"
		c = "B"
		b = "NORMAL"
		d = "1"

		goDatos.EjecutarSentencias( "select * from reporte", "reporte.dbf", _screen.zoo.cRutaInicial ;
			, "c_R34", this.DataSessionId )

		llRetorno = ( alltrim( c_R34.r11 ) != this.face1( a+c+b ) )

		use in select( "c_R34" )
		
		if alltrim( this.leer( 38 ) ) == "1"
		else
			llRetorno = .t.
		endif		
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------}
	protected function laCefu4() as void
		local llRetorno as Boolean, a as String, b as String, c as String, d as String, e as String
	
		c = "NORMAL"
		a = "SALID" + "B" + c
		d = "1"
		
		e = this.face1( a )
		goDatos.EjecutarSentencias( "update reporte set R11 = '" + e + "'", "reporte.dbf", _screen.zoo.cRutaInicial )
		
		this.escribir( 38, d )
	endfunc
	
	*-----------------------------------------------------------------------------------------}
	protected function BlankR11() as void
		local a as String

		a = this.face1( "SALID"+"A"+"NORMAL" )
		goDatos.EjecutarSentencias( "update reporte set R11 = '" + a + "'", "reporte.dbf", _screen.zoo.cRutaInicial )

		this.escribir( 38, "0" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VBloqAuto( tnCantidadIntentos as Integer ) as Void

		if inlist( This.cLetra, "Z", "H" )
			if ( tnCantidadIntentos + 1 ) = goServicios.Registry.Nucleo.Sc.CantidadMaximaDeIntentosFallidosSC
				goServicios.Registry.Nucleo.sc.PedirSCAutomaticamente = .f.
				goServicios.Registry.Nucleo.Sc.CantidadDeIntententosFallidosAlPedirCodigo = 0
			else
				goServicios.Registry.Nucleo.Sc.CantidadDeIntententosFallidosAlPedirCodigo = tnCantidadIntentos + 1
			endif
		endif

	endfunc

	*-----------------------------------------------------------------------------------------}
	function ObVerMod() as String
		return transform( _Screen.Zoo.App.oModulos.nVersion )
	endfunc

	*-----------------------------------------------------------------------------------------}
	function SetearVersionModulos() as Void
		this.Escribir( 39, this.ObVerMod() )
	endfunc 

	*-----------------------------------------------------------------------------------------}
	function LogueoSC( tcTipoIng as String, tcValorGrabar as String ) as void
		local lcS, lcM, lcD, lcV, loLog As Object
		store "" to lcM, lcD, lcV

		lcS = this.leer( 1 )

		If Empty( Alltrim( tcTipoIng ) )
			tcTipoIng = "Ok"
		EndIf

		try
			if upper( alltrim( tcTipoIng ) ) == "ENT"
				pcVG = ""
				pcVM = ""
				pcVD = ""
				pcVv = ""
			else
				this.BC( @lcM, @lcD, @lcV )

				store this.VM( lcS, lcM ) to pcVG, pcVM
				pcVD = this.VD( lcS, lcD )
				pcVv = this.VV()
			endif

			loLog = newobject( "logSC", "logsc.prg" )
			loLog.cDesactivacion = tcValorGrabar
			loLog.cVG = pcVG
			loLog.cVD = pcVD
			loLog.cVV = pcVV
			loLog.cVM = pcVM
			loLog.TipoIng = tcTipoIng

			loLog.Loguear()

			loLog = Null
		catch to loEx

		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFormularioPrincipalActual() as form
		local loForm as form

		loForm = _Screen
		if type( "_Screen.ActiveForm" ) = "O"
			loForm = _Screen.ActiveForm
		endif
		
		return loForm
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DarFocoALaAplicacion( txAplicacion as Variant ) as void
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		* 19/04/2011 * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		* Arreglo para que cuando el algo el saca el foco a la aplicacion, esta vuelva a tener foco!!!!

		local lcCaption as String, loWshShell as object, loForm as form

		if ( vartype( txAplicacion ) = "C" )
			lcCaption = txAplicacion 
		else
			if ( vartype( txAplicacion ) = "O" )
				loForm = txAplicacion 
			else
				loForm = this.ObtenerFormularioPrincipalActual()
			endif

			this.TraerAlFrente( loForm )

			lcCaption = loForm.Caption
		endif
					
		loWshShell = CreateObject( "WScript.Shell" )
		loWshShell.AppActivate( lcCaption  )
		loWshShell = null

		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		* 19/04/2011 * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
	endfunc	

	*-----------------------------------------------------------------------------------------
	function TraerAlFrente( toForm as Form ) as Void
		local lnHandler as Integer, lnIntento as integer, loError as object

		if vartype( toForm ) = "O" and !isnull( toForm )
			toForm.ZOrder(0)
			
			lnHandler = toForm.HWnd
			if lnHandler > 0
			
				lnIntento = 0
				do while lnIntento < 2
					try
						this.DeclararFuncionBringWindowToTop( lnIntento = 1 )

						SetForegroundWindow( lnHandler )
						BringWindowToTop( lnHandler )

						lnIntento = 2
					catch to loError
						lnIntento = lnIntento + 1
						
						if lnIntento > 1
							goServicios.Errores.LevantarExcepcion( loError )
						endif
					endtry
				enddo
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Este metodo es para sacarle el tiempo de declaracion de las funciones al init y distribuirlo en el consumo.
	protected function DeclararFuncionBringWindowToTop( tlForzar as boolean ) as Void
		if !this.lFuncionBringWindowToTopDeclarada or tlForzar 
			
			Clear Dlls SetForegroundWindow 
			Clear Dlls BringWindowToTop 

			DECLARE Integer SetForegroundWindow IN WIN32API Integer nHwnd
			declare integer BringWindowToTop in Win32API integer hwnd

			this.lFuncionBringWindowToTopDeclarada = .t.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearReferenciasFormularioPadreHijo( toFormularioHijo as form ) as void
		local loFormularioPadre as Form
		loFormularioPadre = iif( type( "_screen.ActiveForm" ) == "O", _screen.ActiveForm, null )
		if !isnull( loFormularioPadre ) and vartype( loFormularioPadre.oUltimoFormularioHijo ) != "U"
			loFormularioPadre.oUltimoFormularioHijo = toFormularioHijo
			toFormularioHijo.oFormularioPadre = loFormularioPadre
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsUnFormularioModal( toFormulario as form, tnModo as Integer ) as boolean
		return ( !empty( tnModo ) and tnModo == 1 ) or toFormulario.WindowType = 1
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsUnFormularioVisible( toFormulario as form ) as boolean
		return toFormulario.Visible
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeTraerAlFrenteFormularioHijo( toFormularioPadre as form ) as boolean
		return vartype( toFormularioPadre.oUltimoFormularioHijo ) == "O" and !isnull( toFormularioPadre.oUltimoFormularioHijo ) and toFormularioPadre.oUltimoFormularioHijo.Visible
	endfunc

	*-----------------------------------------------------------------------------------------
	function EliminarReferenciasFormularioPadreHijo( toFormularioHijo as form ) as void
		local loFormularioPadre as Form
		if vartype( toFormularioHijo.oFormularioPadre ) != "U" and !isnull( toFormularioHijo.oFormularioPadre ) and vartype( toFormularioHijo.oFormularioPadre.oUltimoFormularioHijo ) != "U"
			toFormularioHijo.oFormularioPadre.oUltimoFormularioHijo = null
			loFormularioPadre = toFormularioHijo.oFormularioPadre
			toFormularioHijo.oFormularioPadre = null
			if pemstatus( loFormularioPadre, "oKontroler", 5 ) and !isnull( loFormularioPadre.oKontroler ) and pemstatus( loFormularioPadre.oKontroler, "SetearEstadoMenuYToolBar", 5 ) and ;
				this.TieneMenuOToolBarDeshabilitados( loFormularioPadre )
				loFormularioPadre.oKontroler.SetearEstadoMenuYToolBar( .t. )
			endif
			this.TraerAlFrente( loFormularioPadre )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneMenuOToolBarDeshabilitados( toForm as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		
		if ( pemstatus( toForm, "oMenu", 5 ) and vartype( toForm.oMenu ) == "O" and toForm.oMenu.Enabled ) or ;
			( pemstatus( toForm, "oToolbar", 5 ) and vartype( toForm.oToolbar ) == "O" and toForm.oToolbar.Enabled )
			llRetorno = .f.
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsModoDemo( tcNombrePerfilDestino as String ) as Boolean
		local lcNombrePerfilDestino as String, lcSerie as String

		loFormulariosTemp = _screen.zoo.crearobjeto( "managerformularios" )

		With loFormulariosTemp
			local loError as Exception, loEx as Exception
			Try
				.cArchivo1 = Addbs( Justpath( Strtran( .cRutaArchivoInstalacion1, '"', "" ) ) ) + sys(2015) + ".sys"
				.cArchivo2 = Addbs( Justpath( Strtran( .cRutaArchivoInstalacion2, '"', "" ) ) ) + sys(2015) + ".dat"
				.cNombrePerfil = tcNombrePerfilDestino 
				lcSerie = .leer( 1, .F., .T. )
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry 

		endwith
		
		return (lcSerie = "DEMO")
				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EstaInstalado( tcNombrePerfilDestino as String ) as Boolean
		local lcCursor as String, lcSql as String, llRetorno as Boolean 

		lcCursor = sys( 2015 )

		text to lcSql noshow textmerge
Select count(1) as cuantos
from [ORGANIZACION].[ARCHIVOSSYS]
where Perfil = '<<tcNombrePerfilDestino>>' and Tipo = 1
	  	endtext

		goDatos.EjecutarSentencias( lcSql, "[ORGANIZACION].[ARCHIVOSSYS]", "", lcCursor , this.datasessionid )
		
		llRetorno = .f.

		select (lcCursor)
		go top
		if &lcCursor..cuantos > 0
			llRetorno = .t.
		endif
		
		use in (lcCursor)
	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CopiarInstalacion( tcNombreOrigen, tcNombreDestino ) as Void
		local lcNombrePerfilDestino as String, lcSql as String

		if  upper( rtrim( tcNombreOrigen )) != upper( rtrim( tcNombreDestino ))

			goDatos.EjecutarSentencias( "BEGIN TRANSACTION", "[ORGANIZACION].[ARCHIVOSSYS]", "" )

			goDatos.EjecutarSentencias( "DELETE FROM [ORGANIZACION].[ARCHIVOSSYS] WHERE PERFIL='" + tcNombreDestino + "'", "[ORGANIZACION].[ARCHIVOSSYS]", "" )

			text to lcSql noshow textmerge
	  INSERT INTO [ORGANIZACION].[ARCHIVOSSYS]
	  ( PERFIL, CONTENIDO, TIPO )
	  SELECT '<<tcNombreDestino>>', CONTENIDO, TIPO
	  FROM [ORGANIZACION].[ARCHIVOSSYS]
	  WHERE PERFIL='<<tcNombreOrigen>>'
		  	endtext

			goDatos.EjecutarSentencias( lcSql, "[ORGANIZACION].[ARCHIVOSSYS]", "" )

			goDatos.EjecutarSentencias( "COMMIT TRANSACTION", "[ORGANIZACION].[ARCHIVOSSYS]", "" )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarPerfilesMismoMA( )
		local lcCursorConsultaArchivosSYS as String, lcXml as String, lcCursorRetorno as String, lcArchivo1 as String, lcArchivo2 as String, lcNombrePerfil as String, lcSerie as String, lcID as String, lcRetorno as String
		
		lcCursorConsultaArchivosSYS = sys(2015)
		lcXml = goServicios.Datos.ejecutarsql( "SELECT [PERFIL] FROM [ORGANIZACION].[ARCHIVOSSYS] GROUP BY [PERFIL]" )
		xmltocursor( lcXml, lcCursorConsultaArchivosSYS )
		
		lcCursorRetorno = sys(2015)
		create cursor &lcCursorRetorno. ( perfil C (254), serie C(6))

		select &lcCursorConsultaArchivosSYS.
		scan
			With goFormularios
				local loError as Exception, loEx as Exception

				lcArchivo1 = .cArchivo1
				lcArchivo2 = .cArchivo2
				lcNombrePerfil = .cNombrePerfil
				Try
					.cArchivo1 = Addbs( Justpath( Strtran( .cRutaArchivoInstalacion1, '"', "" ) ) ) + sys(2015) + ".sys"
					.cArchivo2 = Addbs( Justpath( Strtran( .cRutaArchivoInstalacion2, '"', "" ) ) ) + sys(2015) + ".dat"
					.cNombrePerfil = &lcCursorConsultaArchivosSYS..Perfil

					lcSerie = .leer( 1, .F., .T. )
					lcID = .leer( 3, .F., .T. )

					if ( lcID == goServicios.Transferencias.obtenerMA() or _screen.zoo.app.lEsEntornoCloud or ( upper( alltrim(lcNombrePerfil )) = upper(alltrim(.cNombrePerfil )) and lcSerie = "DEMO" ) )
						insert into &lcCursorRetorno. values ( &lcCursorConsultaArchivosSYS..Perfil, .leer( 1, .F., .T. ))
					endif
				Catch To loError
				Finally
					.cArchivo1 = lcArchivo1
					.cArchivo2 = lcArchivo2
					.cNombrePerfil = lcNombrePerfil 
				endtry 

			endwith
		endscan

		use in &lcCursorConsultaArchivosSYS.
		
		lcRetorno = this.CursorAXML( lcCursorRetorno )
		use in &lcCursorRetorno.
		
		return lcRetorno
	endfunc

enddefine
