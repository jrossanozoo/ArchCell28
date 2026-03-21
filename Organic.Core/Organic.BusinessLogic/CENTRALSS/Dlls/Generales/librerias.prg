
#Define _CLAVEENCRIPTACION "ClaveDura"
#Define NCANTMAXAPP 10
#Define CSIDL_PERSONAL 0x0005
#Define NOMBRESERVICIOAAO "Agente Organic"
#Define DESCRIPCIONSERVICIOAAO "Agente de Acciones Organic"

Define Class librerias As Servicio Of Servicio.prg

	#IF .f.
		Local this as librerias of librerias.prg
	#ENDIF

	Protected oColCamposUsuarios As zoocoleccion Of zoocoleccion.prg
	Protected oColCamposPerfiles As zoocoleccion Of zoocoleccion.prg
	protected cFechaEnBlancoSQLServer as String
	protected cLetrasValidas as String
	protected cNumerosValidos as String
	protected cCaracteresEspecialesSkuValidos as String
	protected cCaracteresEspecialesValidos as String
	protected cCaracteresBasicosValidos as String
	protected nPixelsPerInchX as Integer
	protected nPixelsPerInchY as Integer
	protected oColCodigosAsciiParaArmarString as zoocoleccion OF zoocoleccion.prg
	protected oListaDeZooUpdate as zoocoleccion OF zoocoleccion.prg

	protected dDateTimeSQLServer as DateTime
	protected lDebeGenerarSemillaDateTime as Boolean	
	protected oRelojInicial as Object
	protected nLongitudMaximaDeIdentificadorGlobal as Integer
	protected oManagerDeServiciosDeWindows as Object
	protected nPais as Integer
	
	oSituacionFiscal = Null
	cSchemaFunciones = ""
	cAlltrim = ""
	cVal = ""
	cPadr = ""
	cCtot = ""
	cEsIgual = ""
	cMacAdress = ""
	oDatosMaquina = Null
	oEncriptador = null
	oCrypto = null
	oIni = null
	nDecimalesParaMascaraNumericos = null
	nPixelsPorPulgadasEnX = 0
	nPixelsPorPulgadasEnY = 0
	nTimerZooUpdate = 0
	oListaDeZooUpdate = null
	lInicioSituacionFiscal = .f. 
	nLongitudMaximaDeIdentificadorGlobal = 20
	oManagerDeServiciosDeWindows = null
	nPais = null
	lVersionActualizadorSegundoPlano = .f.
	
	oColaboradorActiveDir = null

	lModoPuestoPorUsuarioTerminal = .f.
	lModoPuestoLeido = .f.

	cClaveEncriptadoPkWareCZ = "18B31E8261C09314F6A1B57211841933404511"
	oEncriptadorSHA256 = null

	*-----------------------------------------------------------------------------------------
	function lModoPuestoPorUsuarioTerminal_Access() as Void
		if !this.lModoPuestoLeido and !this.lDesTroy
			this.lModoPuestoPorUsuarioTerminal = (goParametros.nuCLEO.Mododeparametrosdepuesto=2)
			this.lModoPuestoLeido = .t.
		endif
		return this.lModoPuestoPorUsuarioTerminal
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Init() As Void
		DoDefault()
		This.oDatosMaquina =  Newobject ( "DatosMaquina", "DatosMaquina.prg" )
		This.cMacAdress = This.oDatosMaquina.MacAddress()
		this.SetearPixelsPorPulgadas()
		this.CrearSemillaFecha()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorActiveDir_Access() as Void
		local loWrapper as Object
		if !this.lDestroy and isnull( this.oColaboradorActiveDir )
			loWrapper = _Screen.zoo.crearObjeto( "ZooLogicSA.ColaboradorActiveDir.Wrappers.WrapperActiveDir" )
			this.oColaboradorActiveDir = _Screen.Zoo.CrearObjeto( "ZooLogicSA.ColaboradorActiveDir.ColaboradorActiveDir","",loWrapper )
		endif
		return this.oColaboradorActiveDir
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oManagerDeServiciosDeWindows_Access() as Void
		if isnull( this.oManagerDeServiciosDeWindows )
			this.oManagerDeServiciosDeWindows = _Screen.Zoo.CrearObjeto( "ZooLogicSA.Core.AdministracionServicios.ManagerServicio" )
		endif
		return this.oManagerDeServiciosDeWindows
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function HayFormularioPrincipal() As Boolean
		Local llRetorno as Boolean, lni As Integer
		llRetorno = .F.
		For lnI = 1 To _Screen.FormCount
			If type( "_screen.forms[ lni ]" ) == 'O' and pemstatus( _screen.forms[ lni ], "lEsFormularioPrincipal", 5 ) and _screen.forms[ lni ].lEsFormularioPrincipal
				llRetorno = .T.
				exit For
			Endif
		Endfor
		Return llRetorno
	Endfunc	
	
	*-----------------------------------------------------------------------------------------
	function TerminarProcesosRelacionados( tnIdDeProceso as Integer, toProcesosAMantenerAbiertos as Collection ) as Void
		local loBuscadorDeProcesos as Object, loProcesosRelacionados as Object, loProceso as Object, loTarea as Object, llExistenProcesosAMantenerAbiertos as Integer
		loBuscadorDeProcesos = GetObject( "WinMgmts:\\" )
		loProcesosRelacionados = loBuscadorDeProcesos.ExecQuery ("Select * From Win32_Process Where ParentProcessID = " + transform( tnIdDeProceso ) )

		llExistenProcesosAMantenerAbiertos = ( vartype( toProcesosAMantenerAbiertos ) == "O" )
		for each loProceso in loProcesosRelacionados
			if !llExistenProcesosAMantenerAbiertos or !toProcesosAMantenerAbiertos.Buscar( transform( loProceso.ProcessID ) )
				This.TerminarProcesosRelacionados( loProceso.ProcessID )
			endif
		endfor
		Try
			loTarea = _screen.zoo.InvocarMetodoEstatico( "System.Diagnostics.Process", "GetProcessById", tnIdDeProceso )
			loTarea.Kill()
		catch
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AbrirVentanaDeExplorer( tcUrl as String ) as Void
		Try
			loTarea = _screen.zoo.InvocarMetodoEstatico( "System.Diagnostics.Process", "Start", tcUrl )
		catch
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIdProcesoActual() as Integer
		Declare Integer GetCurrentProcessId In kernel32
		return GetCurrentProcessId()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function cLetrasValidas_access() as String
		if !this.ldestroy and empty( This.cLetrasValidas )
			This.cLetrasValidas = alltrim( goRegistry.Nucleo.CadenaDeLetrasValidas )
		endif
		return This.cLetrasValidas
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function cNumerosValidos_access() as String
		if !this.ldestroy and empty( This.cNumerosValidos )
			This.cNumerosValidos = alltrim( goRegistry.Nucleo.CadenaDeNumerosValidos )
		endif
		return This.cNumerosValidos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function cCaracteresEspecialesSkuValidos_access() as String
		if !this.ldestroy and empty( This.cCaracteresEspecialesSkuValidos )
			This.cCaracteresEspecialesSkuValidos = "#"
		endif
		return This.cCaracteresEspecialesSkuValidos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function cCaracteresEspecialesValidos_access() as String
		if !this.ldestroy and empty( This.cCaracteresEspecialesValidos )
			This.cCaracteresEspecialesValidos = alltrim( goRegistry.Nucleo.CadenaDeCaracteresEspecialesValidos )
		endif
		return This.cCaracteresEspecialesValidos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function cCaracteresBasicosValidos_access() as String
		if !this.ldestroy and empty( This.cCaracteresBasicosValidos )
			This.cCaracteresBasicosValidos = alltrim( goRegistry.Nucleo.CadenaDeCaracteresBasicosValidos )
		endif
		return This.cCaracteresBasicosValidos
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function oIni_Access() as Void
		if !this.ldestroy and ( !vartype( this.oIni ) = 'O' or isnull( this.oIni ) )
			*!*	 DRAGON 2028
			_screen._instanceFactory.LoadReference('registry.vcx', "Organic.Core.app")
			this.oIni = Newobject( "OldIniReg", "registry.vcx" )
		endif
		return this.oIni
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oEncriptador_access() as Void
		if !this.ldestroy and ( !vartype( this.oEncriptador ) = 'O' or isnull( this.oEncriptador ) )
			this.oEncriptador = _screen.zoo.crearobjeto("ZooLogicSA.ZED.Encriptacion")
			this.oEncriptador.Clave = _CLAVEENCRIPTACION
		endif
		return this.oEncriptador
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oCrypto_access() as Void
		if !this.ldestroy and ( !vartype( this.Crypto ) = 'O' or isnull( this.oCrypto ) )
			this.oCrypto = _Screen.Zoo.CrearObjeto( "ZooLogicSA.Crypto.EncriptacionManager" )
		endif
		return this.oCrypto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function destroy()
		if type( 'goParametros.oDatos' ) == "O"
			unbindevents( goParametros.oDatos, "CambioParametros", this, "ActualizarCachePais" )
		endif			
		dodefault()
		This.oDatosMaquina = Null
		if !this.lVersionActualizadorSegundoPlano
			this.CerrarDescargasEnProceso()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CargarCamposSeguridad() as Void
		Local lcLongitud As String, lcLongitudUser as String, lcLongitudUserPass as String, lcLongitudUserAd as String

		lcLongitud = '96'
		lcLongitudUser = '124'
		lcLongitudUserPass = '148'
		lcLongitudUserAd = '124'
				
		this.cSchemaFunciones = goServicios.Datos.ObtenerSchemaFunciones()
		this.cAlltrim = goServicios.Datos.ObtenerFuncion( "Alltrim" )
		this.cVal = goServicios.Datos.ObtenerFuncion( "Val" )
		this.cPadr = goServicios.Datos.ObtenerFuncion( "Padr" )
		this.cCtot = goServicios.Datos.ObtenerFuncion( "Ctot" )
		this.cEsIgual = goServicios.Datos.ObtenerEsIgual()
		
		with this
			.oColCamposUsuarios = _Screen.Zoo.CrearObjeto( "zooColeccion" )
			.oColCamposPerfiles = _Screen.Zoo.CrearObjeto( "zooColeccion" )

			.oColCamposUsuarios.agregar( "Id", "Id" )
			.oColCamposUsuarios.agregar( .cPadr + "(" + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX1 ))," + lcLongitud + ",' ' ) as Descrip",   "Descrip" )
			.oColCamposUsuarios.agregar( .cPadr + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX2 ) )," + lcLongitudUser + ",' ' ) as Usuario",   "Usuario" )
			.oColCamposUsuarios.agregar( "XX3 as Clave", "Clave" )
			.oColCamposUsuarios.agregar( .cPadr + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX3 )),"+ lcLongitudUserPass +",' ') as Clave",     "Clavedesencriptada" )
			.oColCamposUsuarios.agregar( .cEsIgual + "( lower( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX4 ) ) ), '.t.' ) as Bloqueado", "Bloqueado" )
			.oColCamposUsuarios.agregar( .cval + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX5 ) ) ) as IntentosF", "Intentosf" )
			.oColCamposUsuarios.agregar( .cCtot + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX6 ) ) ) as FechaBloq",   "Fechabloq" )
			.oColCamposUsuarios.agregar( .cval + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX7 ) ) ) as CantBloq",  "Cantbloq" )
			.oColCamposUsuarios.agregar( .cEsIgual + "( lower( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX8 ) ) ), '.t.' ) as BloqAdm",   "Bloqadm" )
			.oColCamposUsuarios.agregar( .cval + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX9 ) ) ) as Origen",  "Origen" )
			.oColCamposUsuarios.agregar( .cPadr + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX11 ) )," + lcLongitudUserAd + ",' ' ) as UsuarioAd",   "Usuarioad" )
			.oColCamposUsuarios.agregar( .cPadr + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX12 ) )," + lcLongitud + ",' ' ) as Email",   "Email" )

			.oColCamposPerfiles.agregar( "Id", "Id" )
			.oColCamposPerfiles.agregar( .cPadr + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX1 ) ), " + lcLongitud + ", ' ' ) as Nombre",  "Nombre" )
			.oColCamposPerfiles.agregar( .cPadr + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX2 ) ), " + lcLongitud + ", ' ' ) as Descrip", "Descrip" )
			.oColCamposPerfiles.agregar( .cval + "( " + .cSchemaFunciones + ".DesEncriptar192( " + .cAlltrim + "( XX3 ) ) ) as Origen",  "Origen" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarRut( tcRut as String ) as Boolean
		local llRetorno as Boolean, lnPais as Integer
	
		llRetorno = .t.
		lnPais = goServicios.Parametros.Nucleo.DatosGenerales.Pais
		do case
			case lnPais = 2
				llRetorno = this.ValidarRutChile( tcRut )
			case lnPais = 3
				llRetorno = this.ValidarRutUruguay( tcRut )
		endcase
	
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarRutChile( tcRut as String ) as Boolean
		local lnValor as Integer, lnFactor as Integer, lnSuma as Integer, i as Integer,;
			lcRut as String, llRetorno as Boolean, lnAt as Integer, lcVerificadorEsperado as String,;
			lcVerificador as String
		
		tcRut = alltrim( tcRut )
		lcVerificador = upper( Right( tcRut , 1 ) )
		
		llRetorno = .t.

		lcRut = left( tcRut, len( tcRut ) - 1 )
		lcRut = strtran( lcRut, ".", "" )
		lcRut = strtran( lcRut, "-", "" )
		lcRut = alltrim( lcRut )

		lnValor = 0
		lnFactor = 2
		lnSuma = 0

		for i = len( lcRut ) to 1 step -1

			lnValor = val( substr( lcRut, i, 1 ) )
			lnSuma = lnSuma + ( lnValor * lnFactor )
			lnFactor = lnFactor + 1

			if lnFactor = 8
				lnFactor = 2
			endif
		endfor

		lnSuma = 11 - ( mod( lnSuma, 11 ) )
		
		do case
		case lnSuma = 10
			lcVerificadorEsperado = "K"
		case lnSuma = 11
			lcVerificadorEsperado = "0"
		otherwise
			lcVerificadorEsperado = transform( lnSuma )
		endcase
		
		llRetorno = ( lcVerificadorEsperado == lcVerificador )

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ValidarRutUruguay( tcRut as String ) as boolean
		local lcDigitoVerifRut as String, lnSuma as Integer, lnProducto as Integer, lnModulo as Integer, ;
			lnDif as Integer, lcDigito as String
			
		tcRut = alltrim( tcRut )
		if at( "-", tcRut ) > 0 or len( tcRut ) != 12
			return .f.
		endif

		dimension laDigitosRut[ 11 ]
		laDigitosRut[ 1 ] = 4
		laDigitosRut[ 2 ] = 3
		laDigitosRut[ 3 ] = 2
		laDigitosRut[ 4 ] = 9
		laDigitosRut[ 5 ] = 8
		laDigitosRut[ 6 ] = 7
		laDigitosRut[ 7 ] = 6
		laDigitosRut[ 8 ] = 5
		laDigitosRut[ 9 ] = 4
		laDigitosRut[ 10 ] = 3
		laDigitosRut[ 11 ] = 2		
		
		lcDigitoVerifRut = right( tcRut, 1 ) 	
	
		lnSuma = 0
		for i = 1 to 11
			lnProducto = val( substr( tcRut, i, 1 ) ) * laDigitosRut[ i ]
			lnSuma = lnSuma + lnProducto 
		endfor
		lnModulo = mod( lnSuma, 11 )
		lnDif = 11 - lnModulo
		
		do case
			case lnDif < 10
				lcDigito = transform( lnDif )
			case lnDif = 10
				lcDigito = ""
			case lnDif = 11
				lcDigito = "0"
		endcase

		return lcDigitoVerifRut == lcDigito
	endfunc	
	
	*-----------------------------------------------------------------------------------------	
	Function ValidarCuit( tcCuit As String ) As boolean
		Local laDigitosCuit, lcCuitSinGuiones, lnDigitoVerificadorDeCuit, i, lnTotal, lnResultado1, ;
			lnResultado9, lnRestoDelTotal, lnDigitoVerificadorCalculado

		If tcCuit = "99-99999999-9"
			Return .T.
		Endif
		tcCuit = Alltrim( tcCuit )

		Dimension laDigitosCuit[ 10 ]
		Store 2 To laDigitosCuit[ 1 ]
		Store 3 To laDigitosCuit[ 2 ]
		Store 4 To laDigitosCuit[ 3 ]
		Store 5 To laDigitosCuit[ 4 ]
		Store 6 To laDigitosCuit[ 5 ]
		Store 7 To laDigitosCuit[ 6 ]
		Store 2 To laDigitosCuit[ 7 ]
		Store 3 To laDigitosCuit[ 8 ]
		Store 4 To laDigitosCuit[ 9 ]
		Store 5 To laDigitosCuit[ 10 ]
		Store Left( tcCuit, 13 ) To lcCuitSinGuiones
		Store Strtran( lcCuitSinGuiones, "-", "" ) To lcCuitSinGuiones
		if len(lcCuitSinGuiones) <> 11
			return .f.
		endif
		Store Val( Right( tcCuit, 1 ) ) To lnDigitoVerificadorDeCuit
	
		lnTotal = 0

		For i = 1 To 10
			lnResultado1 = Val( Substr( lcCuitSinGuiones, 11 - i, 1 ) ) * laDigitosCuit[ i ]
			If i = 9
				lnResultado9 = lnResultado1
			Endif
			lnTotal = lnTotal + lnResultado1
		Next

		lnRestoDelTotal = Mod( lnTotal, 11 )

		Do Case
			Case lnRestoDelTotal != 0
				lnDigitoVerificadorCalculado = 11 - lnRestoDelTotal

			Case lnRestoDelTotal = 0
				lnDigitoVerificadorCalculado = lnRestoDelTotal

			Case lnRestoDelTotal = 1
				lnTotal = lnTotal - lnResultado9 + laDigitosCuit[ 9 ] * 3
				lnRestoDelTotal = Mod( lnTotal, 11 )
				lnDigitoVerificadorCalculado = 11 - lnRestoDelTotal
		Endcase

		Return lnDigitoVerificadorCalculado = lnDigitoVerificadorDeCuit
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarCBU( tcCBU as String ) as boolean

		local lcCBU as String, lcCBU1 as String, lcCBU2 as String, llRetorno as Boolean, llRetorno2 as Boolean, llRetorno3 as Boolean
		
		lcCBU = alltrim( CHRTRAN( tcCBU, CHRTRAN( tcCBU, "1234567890" ,"" ), "" ) )
		lcCBU1 = substr( lcCBU, 1, 8 )
		lcCBU2 = substr( lcCBU, 9, 14 )

		llRetorno = .T.
		llRetorno2 = .T.		
		llRetorno3 = .T.		
		
		if not empty( lcCBU )
			if LEN(lcCBU1) = 8 
				llRetorno = This.ValidarDigitoCBU( lcCBU1 )
			else 
				llRetorno = .F.
			endif 	

			if LEN(lcCBU2) = 14 
				llRetorno2 = This.ValidarDigitoCBU( lcCBU2 )
			else 
				llRetorno2 = .F.
			endif 	
		endif 	
		
		if llRetorno and llRetorno2
			llRetorno3 = .T.
		Else	
			llRetorno3 = .F.
		endif 	
		
		return llRetorno3 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected FUNCTION ValidarDigitoCBU( tcBloque as String ) as String 

	  *-- Ponderador '9713'
	  #DEFINE Pond '9713'
	  
	  local lnSuma, lnLargo, ln, lcDigitoCBU, lcBloque, llRetorno as Boolean 
	  
	  lnSuma = 0
	  lnLargo = LEN( tcBloque )
	  lcDigitoCBU = SUBSTR( tcBloque, lnLargo, 1 )
	  lcBloque = SUBSTR( tcBloque, 1, lnLargo - 1 )
	  
	  FOR ln = 1 TO lnLargo - 1
	    lnSuma = lnSuma + VAL( SUBSTR( lcBloque, lnLargo - ln, 1 ) ) * VAL( SUBSTR( Pond, MOD( 4 - ln, 4 ) + 1, 1 ) ) 
	  endfor
	  
	  llRetorno = ( lcDigitoCBU = RIGHT( STR( 10 - MOD( lnSuma , 10 ) ), 1 ) )
	  
	  return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oSituacionfiscal_Access() as variant
		if !this.ldestroy and ( !vartype( this.oSituacionfiscal ) = 'O' or isnull( this.oSituacionfiscal ) )
			this.oSituacionfiscal = _Screen.zoo.instanciarentidad( 'Situacionfiscal' )
			this.lInicioSituacionFiscal = .t.
		endif
		return this.oSituacionfiscal
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionSituacionFiscalParaImpresion( tnSituacionFiscal as Integer ) as String
		local lcRetorno as String
		This.oSituacionFiscal.Codigo = tnSituacionFiscal
		lcRetorno = alltrim( This.oSituacionFiscal.Descripcion )
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	* Esta funcion sirve para el acceso a datos.
	* Devuelve el valor recibido por parametro como el equivalente en string.
	Function ValorAString( txValor As Variant ) As String
		Local lcRetorno As String, lcCentury as String
		lcCentury = set( "Century" )
		
		Do Case
			Case Vartype( txValor) = "N"
				*				lcRetorno = Str(txValor, 8, 2 )
				lcRetorno = Transform(txValor)

			Case Vartype( txValor) = "D"
				set century On
				lcRetorno = "ctod( '"+ Dtoc( txValor )+ "' )"
				set century &lcCentury				

			Case Vartype( txValor) = "L"
				lcRetorno = Iif( txValor, ".T.", ".F." )
				
			Case Vartype( txValor) = "C"
				If Left(txValor,1) = "'"
					lcRetorno = txValor
				Else
					if right( alltrim( txValor ) , 1 ) = ']'
						lcRetorno = "'"+ txValor + "'"					
					else
						lcRetorno = "["+ txValor + "]"
					endif
				Endif
				
			Case Vartype( txValor) = "T"
				set century On			
				lcRetorno = "ctod( '"+ Dtoc( Ttod ( txValor ) )+ "' )"
				set century &lcCentury				
		Endcase

		Return lcRetorno
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function ValorAStringAlAnular( toItem as Object ) As String
		Local lcRetorno As String, lcCentury as String
		lcCentury = set( "Century" )
		
		Do Case
			Case Vartype( toItem.xValor ) = "N"
				lcRetorno = Transform( toItem.xValor )
				if "*" $ lcRetorno && Si el transform devuelve Numeric Overflow uso STR
					lcRetorno = str( toItem.xValor, toItem.nLongitud, toItem.nDecimales )
				endif

			Case Vartype( toItem.xValor) = "D"
				set century On
				lcRetorno = "ctod( '"+ Dtoc( toItem.xValor )+ "' )"
				set century &lcCentury				

			Case Vartype( toItem.xValor) = "L"
				lcRetorno = Iif( toItem.xValor, ".T.", ".F." )
				
			Case Vartype( toItem.xValor ) = "C"
				If Left( toItem.xValor, 1 ) = "'"
					lcRetorno = toItem.xValor
				Else
					if right( alltrim( toItem.xValor ) , 1 ) = ']'
						lcRetorno = "'"+ toItem.xValor + "'"					
					else
						lcRetorno = "["+ toItem.xValor + "]"
					endif
				endif
				if upper(alltrim( toItem.cAtributo)) == "ZADSFW"
					lcRetorno = strtran( lcRetorno,chr(13)+chr(10),"//")
				endif 
				
			Case Vartype( toItem.xValor ) = "T"
				set century On			
				lcRetorno = "ctod( '"+ Dtoc( Ttod ( toItem.xValor ) )+ "' )"
				set century &lcCentury				
		Endcase

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ValorAStringSegunTipoBase( txValor As Variant ) As String
		local lcRetorno as String

		if goServicios.Datos.EsSqlServer()
			lcRetorno = this.ValorAStringSqlServer( txValor )
		else
			lcRetorno = this.ValorAString( txValor )
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	* Esta funcion sirve para el acceso a datos.
	* Devuelve el valor recibido por parametro como el equivalente en string.
	Function ValorAStringSqlServer( txValor As Variant ) As String
		Local lcRetorno As String, lcCentury as String
		lcCentury = set( "Century" )
		Do Case
			Case Vartype( txValor) = "N"
				lcRetorno = Transform( txValor )
			Case Vartype( txValor) = "D" or Vartype( txValor) = "T"
				set century On
				lcRetorno = goServicios.Datos.ObtenerFechaFormateada( txValor )
				set century &lcCentury				
			Case Vartype( txValor) = "L"
				lcRetorno = Iif( txValor, " 1 ", " 0 " )
			Case Vartype( txValor) = "C" or Vartype( txValor) = "G"
				If Left(txValor,1) = "'"
					lcRetorno = txValor
				Else
					lcRetorno = "'" + txValor + "'"
				Endif
		Endcase

		Return lcRetorno
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	Function ValorVacio( txValor ) As Variant
		Return This.ValorVacioSegunTipo( Vartype( txValor ) )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValorVacioSegunTipo( tcTipo As String ) As Void
		Local  lxRetorno, lcTipo as String
		
		lcTipo = alltrim( upper( tcTipo ))
		Do Case
			Case inlist( lcTipo, "C" )
				lxRetorno = ""
			Case lcTipo= "N" Or lcTipo= "A"
				lxRetorno = 0
			Case lcTipo= "L"
				lxRetorno = .F.
			Case lcTipo= "D"
				lxRetorno = Ctod("")
			Otherwise
				lxRetorno = ""
		Endcase
		Return 	lxRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function CompararValores( txValor1 As Variant, txValor2 As Variant, tlDesactivarCaseSensitive As boolean ) As boolean
		Local llRetorno As boolean, loError As Exception

		llRetorno = .F.
		If Vartype( txValor1 ) = Vartype( txValor2 )
			If Vartype( txValor1 ) = "C"
				txValor1 = Trim( txValor1 )
				txValor2 = Trim( txValor2 )
				If tlDesactivarCaseSensitive
					txValor1 = Upper( txValor1 )
					txValor2 = Upper( txValor2 )
				Endif
			Endif

			llRetorno = ( txValor1 == txValor2 )
		Else
			loError = _Screen.Zoo.CrearObjeto( "exception" )
			loError.UserValue="Los tipos de datos a comparar son distintos"
			loError.Procedure = This.Class
			Throw loError
		Endif

		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerIp() As String
		return This.oDatosMaquina.IpAddress()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerMacAdress() As String
		Return This.cMacAdress
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerGuid() As String
		local lcGuid as String
		lcGuid = This.ObtenerGuidPk()
		lcGuid = '{' +  substr( lcGuid, 2, 8 ) + '-' + ;
						substr( lcGuid, 11, 4 ) + '-' + ;
						substr( lcGuid, 16, 4 ) + '-' + ;
						substr( lcGuid, 21, 4 ) + '-' + ;
						substr( lcGuid, 26, 12 ) + '}'
		return lcGuid
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerGuidPk() As String
		return This.oDatosMaquina.GetGuid()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function TraducirCaracteresMenu ( tcCadena ) As String

		tcCadena =Strtran(tcCadena ,"•","—")
		tcCadena =Strtran(tcCadena ,"§","Ò")
		tcCadena =Strtran(tcCadena ,"†","·")
		tcCadena =Strtran(tcCadena ,"Ç","È")
		tcCadena =Strtran(tcCadena ,"°","Ì")
		tcCadena =Strtran(tcCadena ,"¢","Û")
		tcCadena =Strtran(tcCadena ,"£","˙")
		tcCadena =Strtran(tcCadena ,"Å","¸")
		tcCadena =Strtran(tcCadena ,"ß","∫")

		Return tcCadena
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Encriptar( tcTexto ) As String
		Local lcRetorno As String, lnLongitud As Integer, lnIndice As Integer

		lnIndice = 1
		lcRetorno = ""
		lnLongitud = Len( tcTexto )
		Do While lnIndice<=lnLongitud
			lcRetorno =lcRetorno +Right( "00" + Ltrim( Str( -Mod( lnIndice, 7 )+ Mod( lnLongitud, 3 ) + ;
				asc( Substr( tcTexto, lnIndice , 1 ) ) ) ), 3 )
			lnIndice = lnIndice + 1
		Enddo

		Return lcRetorno

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Desencriptar( tcTexto ) As String
		Local lcRetorno As String, lnLongitud  As Integer, lnIndice As Integer

		tcTexto = Alltrim( tcTexto )
		lnIndice = 1
		lcRetorno = ""
		lnLongitud = Len( tcTexto )/3

		Do While lnIndice<=lnLongitud
			lcRetorno =lcRetorno +Chr( Val( Substr( tcTexto, 3 * lnIndice-2, 3 ) )+ Mod( lnIndice, 7 ) ;
				-Mod( lnLongitud, 3 ) )
			lnIndice = lnIndice + 1
		Enddo
		Return lcRetorno
	Endfunc

	***********************************************************************
	*
	* Dec2RGB funcion: returns separate RGB values from object color value
	*
	* Usage:
	*         RGB = Dec2RGB(<Decimal Color>) && such as _SCREEN.BACKCOLOR
	*          ? RGB = "192, 192, 192"       && color is light gray if true
	*
	Function DecimalARgb
		Lparameters tnDec

		Local lnArray As Integer
		If tnDec < 0
			Return ""
		Endif

		* Determine the hexadecimal equivalent of the decimal parameter passed
		lcHex = ""
		lnFactor = 24          && set up factor value one exponent greater than
		

		For lnPos = 6 To 1 Step -1
			lnFactor = lnFactor - 4     && decrement factorial
			lnExp = 2 ^ lnFactor        && extrapolate next least power of two
			For lnOrd = 15 To 1 Step -1
				If tnDec < lnExp            && no value greater than current one,
					lcHex = lcHex + "0"    && so store a zero in this position
					Exit                   && go back for the next value
				Endif
				If tnDec >= lnExp * lnOrd  && is value greater than or equal to?
					* find the matching hex value from its ordinal position
					lcHex = lcHex + Substr('123456789ABCDEF', lnOrd, 1)
					Exit
				Endif
			Endfor
			tnDec = tnDec % lnExp     && leave remainder of exponential division
		Endfor

		* reverse the order of the individual color indicators
		lcHex = Right(lcHex, 2) + Substr(lcHex, 3, 2) + Left(lcHex, 2)

		* convert the pairs into decimal values
		lnPick = 2          && offset to determine which pair to convert
		lcRGB = ["]     && start of string delineator

		* parse each color indicator and convert to decimal
		For lnColor = 1 To 3
			lcHue = Substr(lcHex, (lnPick * lnColor) - 1, 2) && pull out color
			lnMSB = Asc(Left(lcHue, 1))     && "Most Significant Bit"
			lnLSB = Asc(Right(lcHue, 1))     && "Least Significant Bit"

			* subtract appropriate value from each to get decimal equivalent
			lnMSB = lnMSB - Iif(lnMSB > 57, 55, 48)
			lnLSB = lnLSB - Iif(lnLSB > 57, 55, 48)

			* then add decimals together
			lcRGB = lcRGB + Transform( lnMSB * 16 + lnLSB, '999') + ", "
		Endfor
		lcRGB = Left(lcRGB, Len(lcRGB) - 2) + ["]  && replace last comma with quote
		lcRGB = Alltrim(Strtran(lcRGB,'"',"",1,5))
		lnArray = Alines(laArray,lcRGB,",")
		loRGB = Createobject("custom")
		loRGB.AddProperty("rojo",Val(laArray[1]))
		loRGB.AddProperty("verde",Val(laArray[2]))
		loRGB.AddProperty("azul",Val(laArray[3]))
		Return loRGB
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarCaracteres( tcTexto As String, tlAceptarMinusculas As boolean, tcCaracteresValidar As String) as Boolean
		Local lnPos As Integer, llRetorno as Boolean
				
		If Pcount() < 2
			tlAceptarMinusculas = .F.
		Endif

		lnPos = 1
		tcTexto = Trim( tcTexto )
		llRetorno = .t.
		
		If Empty( tcCaracteresValidar )
			tcCaracteresValidar = This.ObtenerCaracteresValidos( tlAceptarMinusculas )
		Endif
		
		If Empty( tcTexto )
		else
		
			do while lnPos <= Len( tcTexto ) and llRetorno
				If ( Substr( tcTexto, lnPos, 1 ) $ tcCaracteresValidar )
				Else
					llRetorno = .f.
					This.AgregarInformacion( "'" + Substr( tcTexto, lnPos, 1 ) + ;
							"'  Caracter no v·lido. ( PosiciÛn Nr." + Ltrim( Str( lnPos ) ) + " )." )
				Endif

				lnPos = lnPos + 1
			enddo
		Endif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarNombreArchivo( tcTexto As String, tlAceptarMinusculas As boolean ) As Boolean
		local lcCaracteres as String
		lcCaracteres = This.ObtenerLetrasValidas( tlAceptarMinusculas ) + This.ObtenerNumerosValidos() + "_-. "
		Return This.ValidarCaracteres( tcTexto, tlAceptarMinusculas, lcCaracteres )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function TransformarCadenaCaracteres( tcParametro As String ) As String
		Local lcRetorno As String, lni As Integer, lnLineas As Integer
		Local Array laLineas( 1 )

		lcRetorno = Alltrim( tcParametro )

		lnLineas = Alines( laLineas, lcRetorno, .T. ;
			, " ", "_", "-", "/", "\", ".", "?", "(", ")", "]", "[", "{", "}", ">", "<", "+", "'", '"', "," , ":")
		If lnLineas > 0
			lcRetorno = ""
			For lni = 1 To lnLineas
				lcRetorno = lcRetorno + Proper( laLineas[ lni ] )
			Endfor
		Else
			lcRetorno = Proper(laLineas)
		Endif

		lcRetorno = this.ReemplazarCaracteresEspeciales( lcRetorno )

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function InvertirMayusculasMinusculas( tcTexto as String, tlltrim as Boolean ) as String

		Local lcRetorno as String, lnLongitudTexto as Integer, lcCaracter as string
		store "" to lcRetorno
		
		if tlltrim
			lnLongitudTexto = len( rtrim( tcTexto ) )
		else
			lnLongitudTexto = len( alltrim( tcTexto ) )
		endif
		
		for i = 1 to lnLongitudTexto
			lcCaracter = substr( tcTexto, i, 1 )
			if this.EsLetra( lcCaracter )
				lcRetorno = lcRetorno + this.InvertirCaracter( lcCaracter )
			else
				lcRetorno = lcRetorno + lcCaracter
			endif
		endfor
				
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function EsLetra( tcCaracter as String ) as Boolean
		Local llRetorno as Boolean
		if between(	asc( tcCaracter ), 65, 90 ) or between(	asc( tcCaracter ), 97, 122 )
			llRetorno = .t.
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function InvertirCaracter( tcCaracter as String ) as String
		Local lcRetorno as String, lnAscii as Integer
		
		lnAscii = asc( tcCaracter )
		if lnAscii <= 90
			lcRetorno = chr( lnAscii + 32 )
		else
			lcRetorno = chr( lnAscii - 32 )
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReemplazarCaracteresEspeciales( tcCadena as String ) as string

		Local lcRetorno As String

		lcRetorno = Alltrim( tcCadena )	
		
		lcRetorno = Strtran( lcRetorno, "%", "Porcentaje" )
		lcRetorno = Strtran( lcRetorno, "·", "a" )
		lcRetorno = Strtran( lcRetorno, "È", "e" )
		lcRetorno = Strtran( lcRetorno, "Ì", "i" )
		lcRetorno = Strtran( lcRetorno, "Û", "o" )
		lcRetorno = Strtran( lcRetorno, "˙", "u" )
		lcRetorno = Strtran( lcRetorno, "¡", "A" )
		lcRetorno = Strtran( lcRetorno, "…", "E" )
		lcRetorno = Strtran( lcRetorno, "Õ", "I" )
		lcRetorno = Strtran( lcRetorno, "”", "O" )
		lcRetorno = Strtran( lcRetorno, "⁄", "U" )
		lcRetorno = Strtran( lcRetorno, "Ò", "n" )
		lcRetorno = Strtran( lcRetorno, "—", "N" )
		lcRetorno = Strtran( lcRetorno, "¸", "u" )
		lcRetorno = Strtran( lcRetorno, "‹", "U" )

		lcRetorno = Strtran( lcRetorno, "•", "N" )
		lcRetorno = Strtran( lcRetorno, "§", "n" )
		lcRetorno = Strtran( lcRetorno, "†", "a" )
		lcRetorno = Strtran( lcRetorno, "Ç", "e" )
		lcRetorno = Strtran( lcRetorno, "°", "i" )
		lcRetorno = Strtran( lcRetorno, "¢", "o" )
		lcRetorno = Strtran( lcRetorno, "£", "u" )
		lcRetorno = Strtran( lcRetorno, "Å", "u" )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Dia As String
		Lparameter tdFecha
		Local lcRetorno As String
		Store "" To lcRetorno
		Do Case
			Case Dow(tdFecha)=1
				lcRetorno = "Domingo "
			Case Dow(tdFecha)=2
				lcRetorno = "Lunes   "
			Case Dow(tdFecha)=3
				lcRetorno = "Martes  "
			Case Dow(tdFecha)=4
				lcRetorno = "Miercole"
			Case Dow(tdFecha)=5
				lcRetorno = "Jueves  "
			Case Dow(tdFecha)=6
				lcRetorno = "Viernes "
			Case Dow(tdFecha)=7
				lcRetorno = "Sabado  "
		Endcase

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function DiaDeLaSemanaEnNumero as Integer
		lparameters tcDia
		local lnRetorno as Integer
		store 0 to lnRetorno
		
		do case
			case alltrim( tcDia ) == "Domingo"
				lnRetorno = 1
			case alltrim( tcDia ) == "Lunes"
				lnRetorno = 2
			case alltrim( tcDia ) == "Martes"
				lnRetorno = 3
			case alltrim( tcDia ) == "MiÈrcoles"
				lnRetorno = 4
			case alltrim( tcDia ) == "Jueves"
				lnRetorno = 5
			case alltrim( tcDia ) == "Viernes"
				lnRetorno = 6
			case alltrim( tcDia ) == "S·bado"
				lnRetorno = 7
		endcase
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Mes As String
		Lparameter tdFecha
		Local lcRetorno As String

		Store "" To lcRetorno
		Do Case
			Case Month(tdFecha)=1
				lcRetorno = "Enero"
			Case Month(tdFecha)=2
				lcRetorno = "Febrero"
			Case Month(tdFecha)=3
				lcRetorno = "Marzo"
			Case Month(tdFecha)=4
				lcRetorno = "Abril"
			Case Month(tdFecha)=5
				lcRetorno = "Mayo"
			Case Month(tdFecha)=6
				lcRetorno = "Junio"
			Case Month(tdFecha)=7
				lcRetorno = "Julio"
			Case Month(tdFecha)=8
				lcRetorno = "Agosto"
			Case Month(tdFecha)=9
				lcRetorno = "Septiembre"
			Case Month(tdFecha)=10
				lcRetorno = "Octubre"
			Case Month(tdFecha)=11
				lcRetorno = "Noviembre"
			Case Month(tdFecha)=12
				lcRetorno = "Diciembre"
		Endcase

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function VerificarEspacioDisponible( tcunidad As String ) As boolean
		Local lnEspacioMinimo As Integer, llRetorno As boolean

		llRetorno = .T.
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EsAutoBuildDistribuido() as Boolean
		return pemstatus(_screen,"zoo",5) and ( _screen.zoo.EsBuildAutomatico or _screen.zoo.lDesarrollo ) and val(os(4))>0
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Mail( tcDestinatario As String, tcAsunto As String, tcMensaje As String, tcAdjunto  As String ) As Void
		Local loMailForm As Form , loError As Exception, loEx As Exception

		loMailForm = Createobject("form")
		loMailForm.AddObject("Session1","olecontrol","MSMAPI.mapiSession")
		loMailForm.AddObject("Message1","olecontrol","MSMAPI.mapiMessages")
		loMailForm.Session1.NewSession = .F.
		loMailForm.Session1.DownloadMail = .F.
		loMailForm.Session1.signon
		loMailForm.Message1.sessionid = loMailForm.Session1.sessionid
		loMailForm.Message1.compose
		If !Empty( tcDestinatario )
			loMailForm.Message1.RecipDisplayName = tcDestinatario
		Endif
		If !Empty( tcAsunto )
			loMailForm.Message1.msgsubject = tcAsunto
		Endif
		If !Empty( tcMensaje )
			loMailForm.Message1.msgnotetext = tcMensaje
		Endif
		If !Empty(tcAdjunto)
			loMailForm.Message1.AttachmentPathName = tcAdjunto
		Endif


		Try
			loMailForm.Message1.Send(.T.)
		Catch To loError
		Endtry

		loMailForm.Session1.signoff

		Release loMailForm
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerFormatosImagen() As String
		Local lcReturn As String

		lcReturn = "ani,bmp,cur,dib,exif,gif,gfa,jpg,jpeg,jpe,jfif,ico,png,tif,tiff,emf"

		Return lcReturn

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerVersion( tcArchivo As String ) As String
		Local lcNumVersion As String
		lcNumVersion = ""

		If Agetfileversion( laDatosArchivos , tcArchivo ) = 0
		Else
			lcNumVersion = laDatosArchivos[ 4 ]
		Endif

		Return lcNumVersion
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Encriptar192( tcTexto As String ) As String
		Local lcRetorno As String, lxDato As Variant
		Local loError As Exception, loEx As Exception

		try
			if isnull( tcTexto )
				lcRetorno = ''
			else
				lcRetorno = this.oEncriptador.Encriptar( tcTexto )
			endif
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Endtry

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function DesEncriptar192( tcTexto As String ) As String
		Local lcRetorno As String, lxDato As Variant
		Local loError As Exception, loEx As Exception

		try
			if isnull( tcTexto )
				lcRetorno = ''
			else
				lcRetorno = this.oEncriptador.Desencriptar( tcTexto )
			endif
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Endtry

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerCamposSeguridadUsuarios( tcCampos As String ) As String
		this.CargarCamposSeguridad()
		Return This.ObtenerCaposSeguridad(tcCampos, This.oColCamposUsuarios )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerCamposSeguridadPerfiles( tcCampos As String ) As String
		this.CargarCamposSeguridad()
		Return This.ObtenerCaposSeguridad(tcCampos, This.oColCamposPerfiles )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerCaposSeguridad( tcCampos As String, toColeccion As zoocoleccion Of zoocoleccion.prg ) As Void
		Local lcRetorno As String, lnCantCampos As Integer, i As Integer, loError As Exception, loEx As Exception
		Dimension laCampos[1]

		lcRetorno = ""
		Do Case
			Case Alltrim( tcCampos ) == "*"
				For Each lcItem In toColeccion
					If lcItem != this.cPadr + "( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX3 )),96,' ') as Clave"&&"goLibrerias.DesEncriptar( XX3 ) as Clave"
						lcRetorno = lcRetorno + lcItem + ", "
					Endif
				Endfor
			Case Lower( Alltrim( tcCampos ) ) == "*clavedesencriptada"
				For Each lcItem In toColeccion
					If lcItem != "XX3 as Clave"
						lcRetorno = lcRetorno + lcItem + ", "
					Endif
				Endfor
			otherwise
				lnCantCampos  = Alines( laCampos, tcCampos, 1, "," )
				Try
					For i = 1 To lnCantCampos
						lcRetorno = lcRetorno + toColeccion.Item( Proper( laCampos[ i ] ) ) + ", "
					Endfor
				Catch To loError
					loEx = Newobject( "ZooException", "ZooException.prg" )
					With loEx
						.Grabar( loError )
						.Throw()
					Endwith
				Finally
				Endtry
		Endcase
		Return Left( lcRetorno, Len( lcRetorno ) - 2 )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Comprimir( tcArchivo As String, toColeccionArchivos As zoocoleccion Of zoocoleccion.prg, ;
			tcContraseÒa As String, tlProcSubFolders As boolean, tlPreservePaths As boolean, tlDragon as Boolean ) As boolean
		return this.ComprimirDragonLince( tcArchivo, toColeccionArchivos, tcContraseÒa, tlProcSubFolders, tlPreservePaths, .T. )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ComprimirLince( tcArchivo As String, toColeccionArchivos As zoocoleccion Of zoocoleccion.prg, ;
			tcContraseÒa As String, tlProcSubFolders As boolean, tlPreservePaths As boolean, tlDragon as Boolean ) As boolean
		return this.ComprimirDragonLince( tcArchivo, toColeccionArchivos, tcContraseÒa, tlProcSubFolders, tlPreservePaths, .F. )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ComprimirDragonLince( tcArchivo As String, toColeccionArchivos As zoocoleccion Of zoocoleccion.prg, ;
			tcContraseÒa As String, tlProcSubFolders As boolean, tlPreservePaths As boolean, tlEsDragon as Boolean ) As boolean

		Local llRetorno As String, loCompresor As Object, lcItem As String, loError As Exception, loEx As Exception, lcFile as String
		local array laFile[1]
		local loCompresorV2 as Compresor of Compresor.prg, lcArchivoZip as string
		llRetorno = .T.

		If Empty( tcArchivo )
			Assert .F. Message "Se debe indicar el nombre del archivo ZIP."
			llRetorno = .F.
		else
			tcArchivo = strtran( forceext( tcArchivo, "zip" ), "_PUNTO_", "." )
		Endif
		If llRetorno And ( Vartype( toColeccionArchivos ) != "O" Or ;
				!Inlist( Upper( toColeccionArchivos.Class ), "ZOOCOLECCION", "COLLECTION" ) )

			Assert .F. Message "La colecciÛn de archivos no esta bien indicada."
			llRetorno = .F.
		Endif
		If llRetorno And toColeccionArchivos.Count = 0
			Assert .F. Message "La colecciÛn debe tener al menos un archivo para comprimir."
			llRetorno = .F.
		Endif
		If Empty( tcContraseÒa )
			tcContraseÒa = ""
		Endif

		If llRetorno
			try
				If !Directory( Justpath( tcArchivo ) )
					Md ( Justpath( tcArchivo ) )
				Endif
				Delete File( tcArchivo )

				loCompresorV2 = _screen.zoo.crearobjeto( "Compresor" )
				if tlEsDragon
					loCompresorV2.Comprimir( forceext( tcArchivo, "Zip" ), toColeccionArchivos ,tcContraseÒa , tlProcSubFolders , tlPreservePaths )
				else
					loCompresorV2.ComprimirLince( forceext( tcArchivo, "Zip" ), toColeccionArchivos ,tcContraseÒa , tlProcSubFolders , tlPreservePaths )
				endif
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				release loCompresorV2
			Endtry
		Endif

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ContenidoZip( tcNombreArchivo as String ) as Object
		local loColFiles as Object	
		loColFiles  = _Screen.zoo.InvocarMetodoEstatico( "ionic.zip.zipfile", "Read", tcNombreArchivo )
		return loColFiles
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Descomprimir( tcArchivo As String, tcRuta As String, tcContraseÒa As String ) As boolean

		Local llRetorno As boolean, loCompresor As Object, lcItem As String, loError As Exception, loEx As Exception, lcErrorDesc as String lnErrorCode as Integer
		llRetorno = .T.

		If Empty( tcArchivo )
			Assert .F. Message "Se debe indicar el nombre del archivo ZIP."
			llRetorno = .F.
		Endif

		If Empty( tcRuta )
			tcRuta = Sys(5) + Curdir()
		Endif

		If Empty( tcContraseÒa )
			tcContraseÒa = ""
		Endif

		If llRetorno
			Try
				If !Directory( tcRuta )
					Md ( tcRuta )
				endif

				loCompresorV2 = _screen.zoo.crearobjeto( "Compresor" )
				loCompresorV2.DesComprimir( tcArchivo, tcContraseÒa,  tcRuta )
			Catch To loError
				strtran( "ContraseÒa incorrecta", "The password did not match", loError.Message )
				goServicios.Errores.LevantarExcepcion( loError )
			Finally
				release loCompresorV2
			Endtry
		Endif

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ConstTextoAndGo( tcTexto As String, tlNoEspera As boolean, tlNoCtrlUpArrow As boolean ) As Void
		Local i As Integer, lcTextoTot As String, lcTextoAux As String, lcTexto As String, ;
			loError As Exception

		lcTextoTot = ""
		lcTextoAux = "70-65-84-65-76-32-69-82-82-79-82-32-40"

		Try
			For i = 1 To 13
				lcTexto = Getwordnum( lcTextoAux, i, "-" )
				lcTextoTot = lcTextoTot + Chr( Val( lcTexto ) )
			Endfor
			lcTextoTot = Alltrim( lcTextoTot ) + Alltrim( tcTexto ) + Chr( 41 )
		Catch
		finally
			This.SalirForce( lcTextoTot, tlNoEspera, tlNoCtrlUpArrow )
		Endtry

	Endfunc

	*-----------------------------------------------------------------------------------------
	function SalirForce( tcTexto as string, tlNoEspera as boolean, tlNoCtrlUpArrow as boolean ) as Void
		local lcCodDBloq as string
		try
			if ( !tlNoEspera and !tlNoCtrlUpArrow ) or this.MostrarMensajeSalida( tcTexto, tlNoEspera, tlNoCtrlUpArrow ) = 141
				This.Reparar()
			endif
			_screen.Zoo.app.Salir()
		catch to loError
			this.Salir()
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Reparar() as Void
		goFormularios.Reparar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function Salir() As Void
		If !_Screen.Zoo.esBuildAutomatico
			On Shutdown

			Try
				Clear All
			Catch
			Endtry

			Release All
			Clear Events
			Close Databases All
			Cancel
			Quit
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarMensajeSalida( tcTexto As String, tlNoEspera As boolean, tlNoCtrlUpArrow As boolean ) As Integer
		Local lnRetornoMensaje As Integer, loMensajesSC As mensajes Of mensajes.prg

		If Empty( tcTexto )
			tcTexto = "Fallo en el sistema, se cerrar· la aplicaciÛn. Reinicie, en caso de persistir el problema comunÌquese con Mesa de Ayuda."
		Endif

		lnRetornoMensaje = 0
		If tlNoCtrlUpArrow
			loMensajesSC = _Screen.Zoo.CrearObjeto( "Mensajes" )
		Else
			loMensajesSC = _Screen.Zoo.CrearObjeto( "MensajesSC" )
		Endif

		If tlNoEspera
			lnRetornoMensaje = loMensajesSC.Advertir( tcTexto, , , ,5 )
		Else
			lnRetornoMensaje = loMensajesSC.Advertir( tcTexto )
		Endif

		Return lnRetornoMensaje
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function LongToStr
		Lparameters tnLongVal

		Private lnCnt, lcRetStr, lnLongVal

		lcRetStr  = ''
		lnLongVal = Iif(Empty(tnLongVal), 0, tnLongVal)

		For lnCnt = 24 To 0 Step -8
			lcRetStr  = Chr(Int(lnLongVal/(2^lnCnt))) + lcRetStr
			lnLongVal = Mod(lnLongVal, (2^lnCnt))
		Next

		Return lcRetStr
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function IntToStr( tnIntVal )

		Private lnCnt, lcRetStr, lnIntVal
		lcRetStr = ''
		lnIntVal = Iif(Empty(tnIntVal), 0, tnIntVal)

		For lnCnt = 8 To 0 Step -8
			lcRetStr = Chr(Int(lnIntVal/(2^lnCnt))) + lcRetStr
			lnIntVal = Mod(lnIntVal, (2^lnCnt))
		Next

		Return lcRetStr
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function DecToHex( tnDecNumber )
		Private lnLength, lnTempHex, lcHexNumber, lnDecNumber
		lcHexNumber = ''
		lnDecNumber = Iif(Empty(tnDecNumber), 0, tnDecNumber)

		Do Case
			Case lnDecNumber = 0
				lcHexNumber = '0x00000000'
			Case lnDecNumber > 0
				lcHexNumber = Transform(lnDecNumber, '@0')
			Otherwise
				lcHexNumber = Transform(Abs(lnDecNumber), '@0')
				lnLength    = Iif(Substr(lcHexNumber, 3, 1) = ;
					'0', Len(Substr(lcHexNumber, At('0', lcHexNumber, 2))), ;
					len(Transform(Abs(lnDecNumber), '@0')) - 2)
				lnTempHex   = 0xFFFFFFFF
				lcHexNumber = Transform(lnTempHex - Abs(lnDecNumber) + 1, '@0')
		Endcase

		Return lcHexNumber
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function _10to256(lnNumero As Integer, lnCant As Integer ) As String
		*========================
		* Toma n˙mero en base 10 y lo convierte
		* en "lnCant" caracteres en base 256
		* Usada por: WriteLocalTime()
		*========================
		Local lcRetorno, lnAscii

		lcRetorno = ""
		Do While lnNumero >= 256
			lnAscii = Mod( lnNumero, 256 )
			lcRetorno = lcRetorno + Chr( lnAscii )
			lnNumero = Int( lnNumero / 256 )
		Enddo
		lnAscii = lnNumero
		lcRetorno = lcRetorno + Chr( lnAscii )
		Return Padr( lcRetorno, lnCant, Chr(0) )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EstablecerFechaDeSistema( ldDateTime As Date ) As Void
		Local lcCadena As String, lcHora As String, llRetorno As boolean

		lcHora = This.ObtenerFechaHora()
		lcCadena = This._10to256( Year( ldDateTime ), 2 ) + ;
			this._10to256( Month( ldDateTime ), 2 ) + ;
			this._10to256( Dow( ldDateTime ), 2 ) + ;
			this._10to256( Day( ldDateTime ), 2 ) + ;
			this._10to256( Hour( lcHora ), 2 ) + ;
			this._10to256( Minute( lcHora ), 2 ) + ;
			this._10to256( Sec( lcHora ), 2 ) + ;
			this._10to256( 000, 2) + Space( 24 )

		Declare SetLocalTime In win32api String lcCadena

		llRetorno = SetLocalTime( lcCadena )
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function DecToBin( tnNumero )
		Local lnPase, lcRetorno, i, lnLargo

		lnLargo = 19
		lcRetorno = ""

		For i = 1 To lnLargo
			If tnNumero >= 2
				lnPase = Mod( tnNumero, 2 )
				tnNumero = Int( tnNumero / 2 )
				lcRetorno = Alltrim( Str( lnPase, 1 ) ) + lcRetorno
			Else
				If tnNumero = 1
					lcRetorno = Alltrim( Str( 1 ) ) + lcRetorno
					tnNumero = 0
				Endif
			Endif
		Next

		lcRetorno = Right( Replicate( "0", lnLargo ) + lcRetorno, lnLargo )

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function DecToHexFisica( tnDecNumber, tnDigits )

		Local lnLength, lnTempHex, lcHexNumber, lnDecNumber
		lcHexNumber = ''
		lnDecNumber = Iif(Empty(tnDecNumber), 0, tnDecNumber)

		Do Case
			Case lnDecNumber >= 0
				lcHexNumber = Transform(lnDecNumber, '@0')
			Otherwise
				lcHexNumber = Transform(Abs(lnDecNumber), '@0')
				lnLength    = Iif(Substr(lcHexNumber, 3, 1) = ;
					'0', Len(Substr(lcHexNumber, At('0', lcHexNumber, 2))), ;
					len(Transform(Abs(lnDecNumber), '@0')) - 2)
				lnTempHex   = 0xFFFFFFFF
				lcHexNumber = Transform(lnTempHex - Abs(lnDecNumber) + 1, '@0')
		Endcase

		If Empty( tnDigits )
		Else
			lcHexNumber = Right( lcHexNumber, tnDigits )
		Endif

		Return lcHexNumber
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function OkGSD() As boolean
		Local llRetorno, lcOS
		Store .F. To llRetorno
		Store "" To lcOS

		lcOS = Os(1)

		If "5.02" $ lcOS Or "5.01" $ lcOS Or "5.0" $ lcOS	&& Or "4.9" $ lcOS Or "4.0" $ lcOS
			*- WIN2003, WINXP, WIN2000 - SON LOS SO SOBRE LOS QUE SE TESTEO EXITOSAMENTE
			llRetorno = .T.
		Endif

		Return llRetorno
	Endfunc

	*-------------------------------------------------------------------------------
	Function CalcularEdad( tdNac As Date, tdHoy As Date )
		Local lnAnio As Integer, ldHoy As Date

		ldHoy = Iif( Empty( tdHoy ), This.ObtenerFecha(),tdHoy )
		lnAnio = Year( ldHoy ) - Year( tdNac )

		If Gomonth( tdNac, 12 * lnAnio ) > ldHoy
			lnAnio = lnAnio - 1
		Endif

		Return lnAnio

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function BinToDec( tcNumero )
		Local lnPase, lnRetorno, i, lnLargo, k

		lnLargo = 19
		lnRetorno = 0

		tcNumero = Right( Replicate( "0", lnLargo ) + tcNumero, lnLargo )

		i = lnLargo
		k=1

		Do While i >= 1
			lnRetorno = lnRetorno + ( Val( Substr( tcNumero, k, 1 ) ) * ( 2 ^ ( i - 1 ) ) )
			i = i - 1
			k = k + 1
		Enddo

		Return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaHora() as Datetime
		return this.ObtenerDateTimeSegunSemilla()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerFecha() As Date
		return ttod( this.ObtenerDateTimeSegunSemilla() )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerHora() As Date
		local ldDateTime 
		ldDateTime = this.ObtenerDateTimeSegunSemilla()
		Return padl( transform( hour( ldDateTime )),2,"0" ) + ":" + padl(transform( minute( ldDateTime )) ,2,"0" ) + ":" + padl( transform( sec(ldDateTime)) ,2,"0" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMascaraFecha() as String
		return "99/99/" + replicate( "9" , goParametros.Dibujante.FormatoParaFecha * 2 )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function ObtenerTimeStamp() As Integer
		Local lnTimeStamp
		lnTimeStamp = Round(( Val( Sys(1) ) + Seconds())*1000, 0) + Val( Sys( 2007, This.ObtenerMacAdress() ) )
		Return lnTimeStamp
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObV( tcDisco As String, tnForma As Integer ) As String
		Local lcDisco As String, lcVol As String, lnVol As Integer, lnVolSize As Integer, ;
			lnMax As Integer, lnFSFlags As Integer, lcFSNBuffer As String, lnFSNSize As Integer, ;
			lcRetorno As Integer

		lcDisco 	= Iif( Empty( tcDisco ), "C:\", Addbs( tcDisco ) )
		lcVol		= Space(256) && return buffer
		lnVolSize	= 256        && Size of/lcVol
		lnVol		= 0          && buffer
		lnMax 		= 256
		lnFSFlags   = 0
		lcFSNBuffer = Space(256)
		lnFSNSize   = 256

		Declare Integer GetVolumeInformation In Win32API As GetVolInfo ;
			string  @lcDisco, ;
			string  @lcVol, ;
			integer lnVolSize, ;
			integer @lnVol, ;
			integer @lnMax, ;
			integer @lnFSFlags, ;
			string  @lcFSNBuffer, ;
			integer lnFSNSize

		GetVolInfo( @lcDisco, @lcVol, lnVolSize, @lnVol, @lnMax, @lnFSFlags, ;
			@lcFSNBuffer, lnFSNSize )
		If tnForma = 1
			lcRetorno = Transform( lnVol )
		Else
			Local lcVolHex As String
			lcVolHex = Right( This.DecToHex( lnVol ), 8 )
			lcRetorno = Left( lcVolHex, 4 ) + "-" + Right( lcVolHex, 4 )
		Endif
		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ExisteAplicacionEnEjecucion( tcAplicacion As String ) As boolean
		Return This.ObtenerIdAplicacionEnEjecucion( tcAplicacion ) > 0
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerIdAplicacionEnEjecucion( tcAplicacion As String ) As Integer
		Local lnRetorno As Integer, loBuscador As BuscadorDeProceso Of BuscadorDeProceso.prg

		lnRetorno = 0

		loBuscador = _Screen.Zoo.CrearObjeto( "BuscadorDeProceso" )
		lnRetorno = loBuscador.BuscarExe( tcAplicacion )
		loBuscador.Release()

		Return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerDirectorio( tcDirectorio As String , tcTexto As String , tcTitulo As String ) As String
		Local lcDirectorio As String, lcTexto As String, lcTitulo As String

		If Empty( tcDirectorio )
			lcDirectorio = ""
		Else
			lcDirectorio = Alltrim( tcDirectorio )
		Endif

		If Empty( tcTexto )
			lcTexto = ""
		Else
			lcTexto = Alltrim( tcTexto )
		Endif

		If Empty( tcTitulo )
			lcTitulo = ""
		Else
			lcTitulo = Alltrim( tcTitulo )
		Endif

		lcDirectorio = Getdir( lcDirectorio , lcTexto, lcTitulo )

		Return lcDirectorio
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerAnchoTexto( tcTexto As String, toControl As Label, tlManetenerEspacios as boolean) As Integer
		Local lcFuenteAnt As String, lnFuenteAnt As Integer, lnRetorno As Integer, loError As zooexception Of zooexception.prg, ;
			lnFontBoldAnt As boolean

		lcFuenteAnt = _Screen.FontName
		lnFuenteAnt = _Screen.FontSize
		lnFontBoldAnt = _Screen.FontBold
		Try
			_Screen.FontName = toControl.FontName
			_Screen.FontSize = toControl.FontSize
			_Screen.FontBold = toControl.FontBold

			if tlManetenerEspacios
				lnRetorno = _Screen.TextWidth( tcTexto )
			else
				lnRetorno = _Screen.TextWidth( Alltrim( tcTexto ) )
			endif
		Catch To loError
			Throw loError
		Finally
			_Screen.FontName = lcFuenteAnt
			_Screen.FontSize = lnFuenteAnt
			_Screen.FontBold = lnFontBoldAnt
		Endtry

		Return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDeIniTextoPlano( tcArchivo As String, tcSeccion As String, tcEntrada As String ) as Void
		local lcFile as String , lcRetorno as String, lnHandle as Number
		
		lcRetorno = ""
		lcFile = strtran( filetostr( tcArchivo ), "Ôªø", "" )
		lcSeccion = substr( lcFile, 1, at( "[" , lcFile, 2 ) -1 )
		lcEntrada = strtran( upper( lcSeccion ) , "[" + upper( tcSeccion ) + "]" )
		
		lcString = substr( lcEntrada, at( "=", lcEntrada ) + 1 )
		if at( chr(13), lcString ) > 0            
			lcString = substr( lcString, 1, at( chr(13), lcString ))                    
	    endif        
	    if at( chr(10), lcString ) > 0            
	    	lcString = substr( lcString, 1, at( chr(10), lcString ) )                    
	    endif                    
        lcString = strtran( lcString, chr(13), "" )        
        lcString = strtran( lcString, chr(10), "" )

		return lcString

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerDatosDeIni( tcArchivo As String, tcSeccion As String, tcEntrada As String ) As String
		Local lcIniValor As String, lnRetorno As Integer, lcRetorno As String

		Store "" To lcIniValor, lcRetorno
		Store 0 To lnRetorno
		lnRetorno = this.oIni.GetIniEntry( @lcIniValor, tcSeccion, tcEntrada, tcArchivo )
		
		If lnRetorno = 0
			lcRetorno = lcIniValor
		else

			if vartype( tcarchivo ) <> "X" and file( tcArchivo ) and ( "DATACONFIG" $ upper( tcArchivo ) ) and ( "DATOS" $ upper( tcSeccion ) ) and ( "TIPOBASE" $ upper( TCENTRADA ) )
				lcRetorno = this.ObtenerDatosDeIniTextoPlano( tcArchivo , tcSeccion , tcEntrada )
			endif
		Endif

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EscribirDatosDeIni( tcArchivo As String, tcSeccion As String, tcEntrada As String, tcValor as String ) As Integer
		Local lcIniValor As String, lnRetorno As Integer, lcRetorno As String

		Store "" To lcIniValor, lcRetorno
		Store 0 To lnRetorno
		lnRetorno = this.oIni.WriteIniEntry( tcValor, tcSeccion, tcEntrada, tcArchivo )

		Return lnRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AbrirEnlaceWEB( tcEnlace As String ) As Void

		if goServicios.Modulos.VerificarModuloSaaS()
		else
			Declare Integer ShellExecute In "shell32.dll" ;
				integer HWnd, ;
				string lpszOp, ;
				string lpszFile, ;
				string lpszParams, ;
				string lpszDir, ;
				integer FsShowCmd

			ShellExecute(0, "Open", Alltrim( tcEnlace ), "", "", 1)
		endif 	
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EjecutarGenerarMail( tcDestinatario As String ) As Void
		Declare Integer ShellExecute ;
			in SHELL32.Dll ;
			integer nWinHandle,;
			string cOperation,;
			string cFileName,;
			string cParameters,;
			string cDirectory,;
			integer nShowWindow

		ShellExecute(0, "", "mailto:" + tcDestinatario , "", "",1)
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Verificar( tcSerie as string, tcClave as string, tcSitio as string ) as boolean
		local loObjeto as Object, llRetorno as Boolean

		llRetorno = .f.
		with goFormularios
			loObjeto = _Screen.Zoo.CrearObjeto( "DatosOrg" )
			loObjeto.Inicializar()

			if empty( loObjeto.serie ) or _Screen.Zoo.App.cSerie = "DEMO"
				if !empty( tcSerie ) and !empty( tcClave ) and !empty( tcSitio )
					loObjeto.serie = padl( tcSerie, 6,"0")
					
					lcClave = strtran( transform( val( right( '000000' + alltrim( tcClave ), 6 ) ) ,'99-99-99' ), ' ', '0')
					loObjeto.clave = right( '00' + alltrim( lcClave ), 8 )
					
					if loObjeto.Validar()

						if empty( goParametros.Nucleo.DatosGenerales.NombreDelSitio )
							goParametros.Nucleo.DatosGenerales.NombreDelSitio = alltrim( tcSitio )
						endif
						
						goFormularios.SetearDO( loObjeto )
						this.SalirForce( "Clave de activaciÛn por par·metros CORRECTA. Salida autom·tica.", .T., .t. )
					else
						this.SalirForce( "Clave de activaciÛn por par·metros INCORRECTA. Salida autom·tica.", .T., .t. )						
					endif
					_Screen.Zoo.App.lClaveActivacionIncorrecta = .t. && para provocar siempre la salida automatica, haya sido corracta o no
				else					
					if .MostrarScx( "FrmPedirClave", .t., loObjeto )
						goFormularios.SetearDO( loObjeto )
						llRetorno = .t.
					else
						_Screen.Zoo.App.lClaveActivacionIncorrecta = .t.
						if loObjeto.Cancelo
							_Screen.Zoo.App.Salir()
						else
							if _Screen.Zoo.App.lEstoyCambiandoSerieEnAcercaDe
								this.MostrarMensajeSalida( "Clave de activaciÛn INCORRECTA. Salida autom·tica.", .f., .t. )
							else
								this.SalirForce( "Clave de activaciÛn INCORRECTA. Salida autom·tica.", .f., .t. )
							endif
						endif
					endif
				endif
			endif

			if _Screen.Zoo.App.lEstoyCambiandoSerieEnAcercaDe
			else
				this.RegYValid( loObjeto )
			endif
		endwith

		if llRetorno and _Screen.Zoo.App.UtilizarElAAO()
			_Screen.Zoo.App.ConfigurarAgente()
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function RegYValid( toObjeto As Object ) As Void
		_Screen.Zoo.App.cSerie = toObjeto.serie
		_Screen.Zoo.App.cNombre = toObjeto.Nombre
		_Screen.Zoo.App.cOrganizacion = toObjeto.Org

*!*			if .t.
*!*				if goFormularios.EsD() or upper( alltrim( _screen.Zoo.app.NombreProducto ) ) == "ZL" or goModulos.VerificarModuloSaaS()
*!*				else
*!*					if !_screen.zoo.App.lEsEntornocloud 
*!*						this.ValidarCantApp()
*!*					endif
*!*				endif
*!*			else
			*if !goFormularios.EsD() AND !_screen.zoo.App.lEsEntornocloud 
				this.ValidarCantAppMultiSeries()
			*endif
*!*			endif

		If _Screen.Zoo.App.cSerie != "DEMO"
			This.ValidarIngreso()

			If !goFormularios.EsD()
				_Screen.Zoo.App.lSemaforo = ( goFormularios.ObtDesEncEnt() <= 6 )
			endif
		else 
			goModulos.ActualizarModulosDemo()			
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	function oEncriptadorSHA256_Access() as Void
		if !this.ldestroy and ( !vartype( this.oEncriptadorSHA256 ) = 'O' or isnull( this.oEncriptadorSHA256 ) )
			this.oEncriptadorSHA256 = _screen.dotnetbridge.crearobjeto("ZooLogicSA.Core.EncriptadorSHA256")
		endif
		return this.oEncriptadorSHA256
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesactivarValidacionRegistroTerminal() as Void
		local llRetorno as boolean, lcContenido as String

		llRetorno = .f.

		if _screen.zoo.esBuildAutomatico && <= Lo de Build Automatico no deberia estar, pero el AB/BP inicia la aplicacion de modo parcial y los series por perfil pinchan :(
			llRetorno = .t.
		else
			if !_screen.zoo.app.lEsEntornoCloud 
				if file( "PkWare.rgt" )
					lcContenido = filetostr( "PkWare.rgt" )
					if lcContenido == this.oEncriptadorSHA256.Encriptar( _screen.zoo.app.oVersion.Version, this.cClaveEncriptadoPkWareCZ )
						llRetorno = .t.
	     			endif
     			endif
			endif
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ValidarCantAppMultiSeries() As Void
		local loTerminales as zoocoleccion OF zoocoleccion.prg, loTerminal as ItemTerminal of Terminal.prg loMensajesSC as Object, lcTextoMensaje as String

		if !this.DesactivarValidacionRegistroTerminal()
			loTerminales = goServicios.Terminal.ObtenerOtraTerminalConSerie( _Screen.Zoo.App.cSerie )

			if loTerminales.Count>0

			    loTerminal = loTerminales.Item[1]
				
				loMensajesSC = _Screen.Zoo.CrearObjeto( "Mensajes" )

					lcTextoMensaje = "No se puede iniciar la aplicaciÛn. El serie " + _Screen.Zoo.App.cSerie + " se encuentra en uso en la sesiÛn de usuario " + loTerminal.cUsuario + ". Presione Aceptar para ingresar un nuevo serie, o Cancelar para salir"

					if loMensajesSC.Advertir( lcTextoMensaje, 1, 0 )= 1
						goServicios.Formularios = goFormularios
						_screen.zoo.app.cambiars( 0, .t.)
						this.ValidarCantAppMultiSeries() 
					else
						_screen.Zoo.app.Salir( .t. )
					endif

			endif
			
			goServicios.Terminal.DesconectarOtrasTerminalesPorInactividad( _Screen.Zoo.App.cSerie )
		endif

	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerInfoProceso( tcNombreProceso as String ) as object
		local loObjProcesos as Object, loColProc As Object

		loObjProcesos = Getobject( "winmgmts:" )
		loColProc = loObjProcesos.ExecQuery( "select * from win32_process where name = '" + tcNombreProceso + "'" )
		
		return loColProc
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaDeProceso( tcNombreProceso as String, tcHandle as String ) as Boolean

		local loObjProcesos as Object, llRetorno as Boolean, loItem as Object
		llRetorno = .F.
		loObjProcesos = this.ObtenerInfoProceso( justfname(tcNombreProceso) )
		for each loItem in loObjProcesos
			if val(loItem.Handle) = tcHandle
				llRetorno = .T.
			endif
		endfor
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ValidarIngreso() As Void
		Local lcIdPc As String, lcSV As String, lcCodDBloq As String

		With goFormularios
			If !.EsD()
				lcIdPc = .ObS()
				lcSV = .leer( 3 )

				If Alltrim( lcSV ) != Alltrim( lcIdPc )
					.cLetra = "F"
					lcCodDBloq = .PedirDBloq()
					.Escribir( 3, lcIdPc ) 						&& PC
					.RegMod( lcCodDBloq )						&& M
					.SetEnt( .ObtEntDCodDBloq( lcCodDBloq ) )	&& E
				Endif

				.SRE( -1 )
			Endif
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerValorRegistroWindows( tcClave As String, tcUbicacion As String, tcRaiz  As String) As String
		Local lcRetorno As String
		Local loRegistry As Object, lnError As Integer, lnRaiz As Integer
		Private lcValue As String

		Do Case
			Case tcRaiz = "HKCR"
				lnRaiz = -2147483648
			Case tcRaiz = "HKCU"
				lnRaiz = -2147483647
			Case tcRaiz = "HKLM"
				lnRaiz = -2147483646
			Case tcRaiz = "HKU"
				lnRaiz = -2147483645

			Otherwise
				Assert .F. Message "Mandaste la root para el ojete. Opciones: HKCR, HKCU, HKLM, HKU"
		Endcase
		
		local lcPathVfpStartup as string
		lcPathVfpStartup = Home(1)
		if empty( lcPathVfpStartup )
			lcPathVfpStartup = Home(0)
		endif
		loRegistry = Newobject( "Registry", lcPathVfpStartup+"ffc\registry.vcx" )
		
		lcValue = ''
		loRegistry.GetRegKey( tcClave, @lcValue, tcUbicacion, lnRaiz )
		lcRetorno = lcValue

		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function TwipsToPixels( tnTwips As Long, tnDirection As Long ) As Long		
		#Define DIRECTION_VERTICAL  1
		#Define DIRECTION_HORIZONTAL  0

		local lnTwipsToPixels As Integer as Integer

		If tnDirection = DIRECTION_HORIZONTAL Then
			lnPixelsPerInch = this.nPixelsPorPulgadasEnX
		Else
			lnPixelsPerInch = this.nPixelsPorPulgadasEnY
		Endif

		lnTwipsToPixels = tnTwips / 1440 * lnPixelsPerInch
		
		Return lnTwipsToPixels
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function PixelsToTwips( tnPixels As Long, tnDirection As Long ) As Long
		#Define DIRECTION_VERTICAL  1
		#Define DIRECTION_HORIZONTAL  0
		
		If tnDirection = DIRECTION_HORIZONTAL Then
			lnPixelsPerInch = this.nPixelsPorPulgadasEnX
		Else
			lnPixelsPerInch = this.nPixelsPorPulgadasEnY
		Endif

		lnPixelsToTwips= tnPixels * 1440 / lnPixelsPerInch
		Return lnPixelsToTwips
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerFechaFormateada( txDate as Variant, tcTipoDB as String ) as Date
		local ldRetorno as Date, lcFechaBlanco as String, lcTipoDB as String

		if empty( tcTipoDB )
			lcTipoDB = _screen.Zoo.App.TipoDeBase
		else
			lcTipoDB = alltrim( upper( tcTipoDB ))
		endif
		
		do case
			case lcTipoDB = "NATIVA"
				ldRetorno = txDate

			case lcTipoDB = "SQLSERVER"

				if empty( this.cFechaEnBlancoSQLServer )
					this.cFechaEnBlancoSQLServer = alltrim( goRegistry.Nucleo.FechaEnBlancoParaSqlServer )
				endif

				lcFechaBlanco = this.cFechaEnBlancoSQLServer
				ltFechaEnBlancoSqlServer = evaluate( lcFechaBlanco ) 

				if txdate = ltFechaEnBlancoSqlServer
					ldRetorno = ctod( "" )
				else
					if vartype( txDate ) = "T"
						ldRetorno = ttod( txDate )
					else
						ldRetorno = txDate
					Endif	
				endif

			otherwise
				assert .f. message "Base de Datos no Soportada" 
				
		endcase	
		
		return ldRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerArchivoPlano( tcNombre as String, tnLineas as integer, tnDesde as integer, tnPosicion as integer) as string
		local lcTexto as string, cRutaParametro as string, llRetorno as Boolean 

		lcTexto = ''
		llRetorno = .t.
	
		create cursor c_parametro ( archivo c( 254 ) )
		try 
			append from alltrim( tcNombre ) Sdf
		catch to loError
			llRetorno = .f.
		endtry
		
		if llRetorno
			try
				go tnlineas
				lcTexto = substr( c_parametro.archivo, tnDesde, tnPosicion )
			catch to loError
			endtry
			
		endif	

		use in select( 'c_parametro' )
		
		return lcTexto 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstablecerVentanaEnPrimerPlano( tnHnwd as Long ) as Boolean
		Local llRetorno as Boolean
		
		Declare ShowWindow In WIN32API Integer nHandle, Integer nState
		Declare Long SetForegroundWindow in "user32" long hWnd

		llRetorno = 0
		
		if vartype( tnHnwd ) = "N" and tnHnwd > 0
			llRetorno = ShowWindow( tnHnwd, 1 )
			llRetorno = ( SetForegroundWindow( tnHnwd ) = 1 ) And llRetorno &&Si pudo ponerla en primer plano, SetForegroundWindow devuelve 1 (*)
		else
			assert .f. message "El tipo o el valor del par·metro es incorrecto"
		endif
		
		clear dlls "ShowWindow", "SetForegroundWindow"

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EncriptarPerfilUsuario( tcPerfil as String, tcUsuario as String ) as String

		local lcStrEncriptado as String 
		
		lcStrEncriptado = alltrim( tcPerfil ) + '*' + alltrim( tcUsuario )
		lcStrEncriptado = This.Encriptar192( lcStrEncriptado )
		
		return lcStrEncriptado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesencriptarPerfilUsuario( tcStrPerfilEncriptado as String, tcStrUsuarioEncriptado as String, tnUsuario as int ) as String 

		local lcStrUsuarioDesencriptado as string, lcStrPerfilDesencriptado as string, loEx as Exception, lcRetorno as String 

		if ( empty( tcStrUsuarioEncriptado ) or	empty( tcStrPerfilEncriptado ) )
			lcRetorno = ""
		Else	
			lcStrUsuarioDesencriptado = This.Desencriptar192( alltrim( tcStrUsuarioEncriptado ) )
			lcStrPerfilDesencriptado = This.Desencriptar192( alltrim( tcStrPerfilEncriptado ) )			

			if alltrim( upper( lcStrUsuarioDesencriptado )) == alltrim( upper( lcStrPerfilDesencriptado ))
				lcRetorno = this.ExtraerPerfilUsuario( tcStrUsuarioEncriptado, tnUsuario )
			else
				lcRetorno = ""
			endif 				

		endif 
			
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EncriptarModo( tcIdCampo as String, tcIdOpe as String, tcIdModo as String ) as String 

		local lcStrEncriptado as String 
		
		lcStrEncriptado = alltrim( tcIdCampo ) + '*' + alltrim( tcIdOpe ) + '#' + alltrim( tcIdModo )
		lcStrEncriptado = This.Encriptar192( lcStrEncriptado )
		
		return lcStrEncriptado
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesencriptarModo( tcIdCampo as String, tcIdOpe as String, tcStrEncriptado as String ) as Void
		local lcStrDesencriptado as string, lcIdCampo as String, lcIdOpe as String, lnModo as Integer, lnPosAsterisco as Integer, lnPosSharp as Integer,;
			loError as Exception, loEx as Exception    
		
		if empty( tcIdCampo ) or;
			empty( tcIdOpe ) or;
			empty( tcStrEncriptado ) 
			
			lnModo = 0
		Else	
			lnStrDesencriptado = This.Desencriptar192( alltrim( tcStrEncriptado ) )

			lnPosAsterisco 	= at( '*', lnStrDesencriptado ) 
			lnPosSharp		= at( '#', lnStrDesencriptado ) 

			lcIdCampo 	= substr( lnStrDesencriptado, 1, lnPosAsterisco - 1 )
			lcIdOpe  	= substr( lnStrDesencriptado, lnPosAsterisco + 1, ( lnPosSharp - ( lnPosAsterisco + 1 ) ) ) 
			lnModo		= this.ExtraerModo( tcStrEncriptado )
			
			if alltrim( lcIdCampo ) == alltrim( tcIdCampo ) and;
				alltrim( lcIdOpe ) == alltrim( tcIdOpe )
			else
				lnModo = 0
			endif 				

		endif 
			
		return lnModo

	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ReEncriptarSeguridad( tcClave as String ) as String
		local lcClave as String

		lcClave = this.Desencriptar192( alltrim( tcClave ))
		lcClave = this.Encriptar192( alltrim( lcClave ))
		
		return lcClave
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExtraerPerfilUsuario( tcClave as String, tnUsuario as Int ) as String
		local lnPosAsterisco as Integer, lcRetorno as String
		
		tcClave = goLibrerias.Desencriptar192( alltrim( tcClave ))
		
		lnPosAsterisco 	= at( '*', tcClave ) 
		
		if tnUsuario = 1
			lcRetorno = substr( tcClave , lnPosAsterisco + 1, len( tcClave ) ) 	
		else
			lcRetorno = substr( tcClave , 1, lnPosAsterisco - 1 )
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExtraerModo( tcClave as String ) as Integer 
		local lnRetorno as Integer, lcClave as String 
		
		lcClave = goLibrerias.Desencriptar192( alltrim( tcClave ))
		
		if isdigit( right( lcClave, 1 ))
			lnRetorno = val( right( lcClave, 1 ) )
		else
			lnRetorno =  this.ObtenerUltimoDigitoDeUnaCadena( lcClave ) 
		endif 
		
		return lnRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerUltimoDigitoDeUnaCadena( tcCadena as String ) as Integer  
		local lnRetorno as Integer, i as integer, lnCaracteres as integer, lcCaracter as String 
		lnRetorno = 0

		lnCaracteres = len( tcCadena )
		for i = lnCaracteres to 1 step - 1
			lcCaracter = substr( tcCadena , i, 1 )
			if isdigit( lcCaracter )
				lnRetorno = val( lcCaracter )
				exit
			endif
		endfor

		return lnRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresInvalidos( tcCadena as String  ) as String 
		local lcRetorno, lcCaracteresValidos as String, lnI as Integer 
		lcRetorno = ""
		
		lcCaracteresValidos = alltrim( goregistry.nucleo.cadenadecaracteresvalidos )
		For lnI = 1 To Len( tcCadena )
			If  Substr( tcCadena , lnI, 1 ) $ lcCaracteresValidos 
			else
				if asc( Substr( tcCadena , lnI, 1 ) ) <> 13 and asc( Substr( tcCadena , lnI, 1 ) ) <> 10
					lcRetorno =  lcRetorno + transform( Substr( tcCadena, lnI, 1 ) )
				endif 
			Endif
		Endfor
		return lcRetorno
	endfunc
	 	
	*-----------------------------------------------------------------------------------------
	function InvertirCadena( tcString as string ) as string
		local lcRetorno as string, i as integer, lnCaracteres as integer
		store "" to lcRetorno

		lnCaracteres = len( tcString )
		for i = lnCaracteres to 1 step - 1
			lcRetorno = lcRetorno + substr( tcString, i, 1 )
		endfor

		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RedondearSegunMascara( tnNumero as float ) as float
		if ( isnull( this.nPais ) )
			this.ActualizarCachePais()
			if type( 'goParametros.oDatos' ) == "O"
				bindevent( goParametros.oDatos, "CambioParametros", this, "ActualizarCachePais" )
			endif		
		endif
		return round( tnNumero, this.nDecimalesParaMascaraNumericos )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarCachePais() as Void
		this.nPais = goParametros.Nucleo.DatosGenerales.Pais		
		this.nDecimalesParaMascaraNumericos = iif( this.nPais == 2, 0, 2 ) && Chile .t.
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerBasesDeDatos( tcAgrupamiento as String, tlValidarExistencia as Boolean ) as String
		local loAgrupamiento as ent_Agrupamiento OF ent_Agrupamiento.prg, lcRetorno as String, lcAgrupamiento as String, ;
			llExiste as Boolean
			
		llExiste = .t.
		lcRetorno = ""
		if !empty( tcAgrupamiento ) 
			if this.EsAgrupamiento( tcAgrupamiento )
				lcAgrupamiento = this.ObtenerAgrupamiento( tcAgrupamiento )
				loAgrupamiento = _screen.zoo.Instanciarentidad( "Agrupamiento" )
				if tlValidarExistencia 
					llExiste = loAgrupamiento.VerificarExistenciaClavePrimaria( lcAgrupamiento )
				endif
				if llExiste  
					lcRetorno = loAgrupamiento.ObtenerBasesDeDatos( lcAgrupamiento )				
					loAgrupamiento.release()
				else
					goServicios.Errores.LevantarExcepcion( "No existe el agrupamiento " + transform( tcAgrupamiento ) + "." )
				endif
			else
				lcRetorno = tcAgrupamiento
			endif
		endif
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsAgrupamiento( tcValor as String ) as boolean
		local lcValor as String
		lcValor = alltrim( tcValor )
		return ( left( lcValor , 1 ) == "[" and right( lcValor , 1 ) == "]" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAgrupamiento( tcValor as String ) as string
		local lcValor as String
		lcValor = alltrim( tcValor )
		return substr( lcValor , 2, len( lcValor ) - 2 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPropiedadesTexto( tcTexto as String, tnAnchoMax as Integer, tcFuente as String, tnTamaÒoFuente as Integer ) as Custom
		local loRetorno as Empty, lnAncho as Integer, lnAlto as Integer, lnLineas as Integer

		loRetorno = newobject( "Empty" )
		
		addproperty( loRetorno, "nPixelesAncho" )
		addproperty( loRetorno, "nPixelesAlto" )
		addproperty( loRetorno, "nLineas" )
		addproperty( loRetorno, "cTexto" )
		addproperty( loRetorno, "cFuenteNombre" )
		addproperty( loRetorno, "nFuenteTamaÒo" )				
		
		this.CargarFuenteValida( @tcFuente, @tnTamaÒoFuente )
		
		loRetorno.cFuenteNombre = tcFuente 
		loRetorno.nFuenteTamaÒo = tnTamaÒoFuente 
		
		this.CargarPropiedaesTexto( @tcTexto, tcFuente, tnTamaÒoFuente, tnAnchoMax, @lnAncho, @lnAlto, @lnLineas )
		
		loRetorno.cTexto = tcTexto		
		loRetorno.nPixelesAncho = lnAncho
		loRetorno.nPixelesAlto = lnAlto
		loRetorno.nLineas = lnLineas 
		
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarFuenteValida( tcFuente as String, tnTamaÒoFuente as Integer )  as Void
		if empty( tcFuente )
			tcFuente = _screen.FontName
		endif
		
		if empty( tnTamaÒoFuente )
			tnTamaÒoFuente  = _Screen.FontSize
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CargarPropiedaesTexto( tcMensaje as String, tcFuente as string, tnTamaÒoFuente as Integer, tnAnchoMax as Integer, tnAncho as Integer, tnAlto as Integer, tnLineas as Integer ) as Void
		local array laPalabras[1], laSaltosDeLinea[1]
		local lnCantPalabras as Integer, lnWidth as Integer, i as Integer, j as Integer, lnAncho as Integer

		tcMensaje = strtran( tcMensaje, chr(13) + chr(10), chr(13))
		tcMensaje = strtran( tcMensaje, chr(10) + chr(13), chr(13))			
		lnCantPalabras = alines( laPalabras, tcMensaje, 16, " " )
		lnWidth = 0
		tnLineas = 1
		tnAncho = 0
		
		this.CargarFuenteValida( @tcFuente, @tnTamaÒoFuente )

		for i = 1 to lnCantPalabras
			lcPalabra = laPalabras[ i ]
			
			if chr( 13 ) $ lcPalabra or chr( 10 ) $ lcPalabra
				tnLineas = tnLineas + occurs( chr(13), lcPalabra ) + occurs( chr(10), lcPalabra )
				lnCantSaltosLineas = alines( laSaltosDeLinea, lcPalabra, 0, chr(13), chr(10))
				
				for j = 1 to lnCantSaltosLineas
					lcPalabra = laSaltosDeLinea[ j ]
					lnAncho = this.ObtenerAnchoTextoPixeles( lcPalabra, tcFuente, tnTamaÒoFuente )
					
					if j = 1
						lnWidth = lnWidth + lnAncho
						this.ValidarAnchoMaximo( tnAnchoMax, @lnWidth, lnAncho, tcFuente, tnTamaÒoFuente, @tnAncho, @tnLineas )
					endif
					
					tnAncho = max( lnWidth, tnAncho, lnAncho )
				endfor
				
				lnWidth = lnAncho
			else
				lnAncho = this.ObtenerAnchoTextoPixeles( lcPalabra, tcFuente, tnTamaÒoFuente )			
				lnWidth = lnWidth + lnAncho
			endif

			this.ValidarAnchoMaximo( tnAnchoMax, @lnWidth, lnAncho, tcFuente, tnTamaÒoFuente, @tnAncho, @tnLineas )

			tnAncho = max( tnAncho, lnWidth )
		endfor
	
		tnAncho = tnAncho + fontmetric( 6, tcFuente, tnTamaÒoFuente )
		tnAlto = fontmetric( 1, tcFuente, tnTamaÒoFuente + 1 ) * ( tnLineas + 0.25 )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarAnchoMaximo( tnAnchoMax as Integer, tnWidth as Integer, tnAnchoPalabra as integer, tcFuente as String, tnTamaÒoFuente as Integer, tnAncho as Integer, tnLineas as Integer ) as Void
		this.CargarFuenteValida( @tcFuente, @tnTamaÒoFuente )
		if tnWidth > tnAnchoMax  
			if tnAnchoPalabra > tnAnchoMax 
				if tnWidth - tnAnchoPalabra > 0
					tnLineas = tnLineas + 1 
				endif
				
				tnAncho = tnAnchoMax 
				tnWidth = tnAnchoPalabra % tnAnchoMax 	
				tnLineas = tnLineas + floor( ( tnAnchoPalabra - this.ObtenerAnchoTextoPixeles( "a", tcFuente, tnTamaÒoFuente ) ) / tnAnchoMax  )
			else
				tnLineas = tnLineas + 1  
				tnAncho = max( tnAncho, tnWidth - tnAnchoPalabra, tnAnchoPalabra )
				tnWidth = tnAnchoPalabra
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAnchoTextoPixeles( tcTexto as String, tcFuente as String, tnTamaÒoFuente as Integer ) as integer
		local lnRetorno as Integer, lnCantCaracteres as Integer
		
		this.CargarFuenteValida( @tcFuente, @tnTamaÒoFuente )
		
		lnCantCaracteres = txtwidth( tcTexto, tcFuente, tnTamaÒoFuente )
		lnRetorno = lnCantCaracteres * fontmetric( 6, tcFuente, tnTamaÒoFuente )

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombrePuesto() as String
		local lcRetorno as String

		if this.lModoPuestoPorUsuarioTerminal && _screen.zoo.app.lEsEntornoCloud 
			if _screen.zoo.app.lEsEntornoCloud 
				lcRetorno = this.ObtenerNombreUsuarioSO()
			else
				lcRetorno = this.ObtenerNombreUsuarioSO() + "@" + this.ObtenerNombreEquipo()
			endif
		else
			lcRetorno = this.ObtenerNombreEquipo()
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreEquipo() as Void
		return getenv( "COMPUTERNAME" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteServidorSqlServer() as Void
		local lnId as Integer, llRetorno as Boolean, lnDispLogin as integer
		llRetorno = .f.

		lnDispLogin = sqlgetprop( 0,"DispLogin" )
		sqlsetprop( 0,"DispLogin",3 )
		sqlsetprop( 0,"ConnectTimeOut",5)
		
		lnId = goDatos.oManagerConexionASql.ObtenerNuevaConexionSinDatabase()
		
		sqlsetprop( 0,"DispLogin",lnDispLogin )
		llRetorno = ( lnId > 0 )
		
		if lnId > 0
			sqldisconnect( lnId )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteBaseDeDatosSqlServer( tcBaseDeDatos as String, tlVengoDeGuardarComoBaseEnLinux as Boolean ) as Void
		local loError as Exception, loEx as Exception, lcBaseAnt as String, lcSql as String, llRetorno as Boolean, llDesconectar as Boolean

		llRetorno = .f.
		try
			if tlVengoDeGuardarComoBaseEnLinux
				llDesconectar = .T.
			else
				llDesconectar = goDatos.nIdConexion <= 0
			endif

			if llDesconectar 
				lcBaseAnt = _screen.zoo.app.cNombreBaseDeDatosSql
				goDatos.DesconectarMotorSql()
				_screen.zoo.app.cNombreBaseDeDatosSql = "Master" 
			endif
			
			if this.Existeservidorsqlserver()
				lcSql = "select 1 from Master.sys.databases where upper( name ) = '" + alltrim( upper( tcBaseDeDatos )) + "'"
			
				goDatos.EjecutarSql( lcSql,"c_basedatos", This.DataSessionId )

				llRetorno = ( reccount( "c_basedatos" ) > 0 )
			endif
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			if llDesconectar 
				_screen.zoo.app.cNombreBaseDeDatosSql = lcBaseAnt
				goDatos.DesconectarMotorSql()
			endif
			
			if tlVengoDeGuardarComoBaseEnLinux 
				lnId = goDatos.oManagerConexionASql.ObtenerConexion()
			endif
			
			use in select( "c_basedatos" )
		endtry 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteBaseDeDatosNativa( tcBaseDeDatos as String ) as Void
		local llRetorno as Boolean
		
		llRetorno = directory( tcBaseDeDatos, 1 )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ExisteTablaSqlServer( tcBaseDeDatos as String, tcTabla as String, tcEsquema as string ) as Void
		local loError as Exception, loEx as Exception, lcBaseAnt as String, lcSql as String, llRetorno as Boolean, lcCursor as String
		
		llRetorno = .f.
		lcCursor = sys(2015)
		
		try
			if this.ExisteBaseDeDatosSqlServer( tcBaseDeDatos )
				lcSql = "Select tabla.name as tabla, esquema.name as esquema " + ;
					 		"from [" + tcBaseDeDatos + "].sys.objects tabla inner join [" + tcBaseDeDatos + "].sys.schemas esquema on tabla.schema_id = esquema.schema_id " + ;
					 		"WHERE upper( esquema.name + '.' + tabla.name ) = '" + upper( alltrim( tcEsquema ) + "." + alltrim( tcTabla ) ) + "'"
					
				goDatos.EjecutarSql( lcSql,lcCursor, This.DataSessionId )
				llRetorno = ( reccount( lcCursor ) > 0 )
			endif
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( lcCursor )
		endtry 
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ExisteTablaNativa( tcRuta as String, tcTabla as String )
		local llRetorno as Boolean
		
		llRetorno = .f.
		
		if this.ExisteBaseDeDatosNativa( tcRuta )
			llRetorno = file( forcepath( forceext( tcTabla, "dbf" ), addbs( tcRuta )), 1 )
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteTabla( tcRutaBaseDeDatos as String, tcTabla as String, tcEsquema as String ) as Void	
		local llRetorno as Boolean
		
		llRetorno = .f.
		
		if this.ExisteBaseDeDatos( tcRutaBaseDeDatos )
			if goDatos.EsNativa()
				llRetorno = this.ExisteTablaNativa( tcRutaBaseDeDatos, tcTabla )
			else
				llRetorno = this.ExisteTablaSqlServer( tcRutaBaseDeDatos, tcTabla, tcEsquema )
			endif
		endif
				
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteBaseDeDatos( tcRutaBaseDeDatos as String, tlVengoDeGuardarComoBaseEnLinux as Boolean ) as Void	
		local llRetorno as Boolean
		
		if goDatos.EsNativa()
			llRetorno = this.ExisteBaseDeDatosNativa( tcRutaBaseDeDatos )
		else
			llRetorno = this.ExisteBaseDeDatosSqlServer( tcRutaBaseDeDatos, tlVengoDeGuardarComoBaseEnLinux )
		endif
		
		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function CrearDirectorio( tcCarpeta as String ) as Void
		local lnCant as Integer, i as Integer, lcPath as String, llEsRutaDeRed as Boolean
		local array aDire[1]
		llEsRutaDeRed = .f.

		if !directory( addbs( transform(tcCarpeta)), 1 )
			if occurs('\\',tcCarpeta) > 0
				llEsRutaDeRed = .t.
			endif
			lnCant = alines( aDire, addbs( tcCarpeta ),16, '\' )
			lcPath = ''
			try
				for i = 1 to lnCant
					lcPath = addbs( lcPath ) + alltrim( aDire[i] )
					if !llEsRutaDeRed or ( llEsRutaDeRed and i >= 4 )
						if !directory( lcPath, 1 )
							md ( lcPath )
						endif
					endif
				endfor
			catch to loError
				goServicios.Errores.LevantarExcepcion( "El directorio: " + alltrim( upper( lcPath )) + " no se ha podido crear." )
			endtry
		endif
	EndFunc

	*-----------------------------------------------------------------------------------------
	function ExisteProcesoPorNombreDeVentana( tcNombreDeVentana as String ) 
		local lcWindowName as string, lnWH as long, lnCount as integer, ;
			lnCantidadDeTitulos as Number, ;
			laTitulos as Object, llRetorno as Integer 

		#DEFINE GW_HWNDNEXT         2
		#DEFINE GW_CHILD            5

		declare integer GetDesktopWindow in win32api

		declare integer GetWindowText in WIN32API;
			integer hwnd, ;
			string @ lpString, ;
			integer nMaxCount

		declare integer FindWindow in Win32API;
			string @lpClassName, ;
			string @lpWindowName

		declare integer GetActiveWindow in user32.dll

		declare integer GetWindow in user32.dll ;
			integer hwnd, ;
			integer wCmd

		llRetorno = .f.
		
		store 0 to lnCount

		lnWH = GetDesktopWindow()
		lnWH = GetWindow(lnWH, GW_CHILD)
		
		lcCadena = ''
		if lnWH > 0
			lnWH = GetWindow(lnWH,0)
			do while lnWH>0
				lcWindowName = space(150)
				if GetWindowText(lnWH, @lcWindowName, len( lcWindowName ) ) > 0
					if  at( upper( alltrim( tcNombreDeVentana ) ), upper( alltrim( lcWindowName ) ) ) > 0
						lnCount=lnCount+1
						llRetorno = .t.
					endif
				endif
				lnWH = GetWindow(lnWH, GW_HWNDNEXT)
			enddo
		endif

		return llRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreSucursal( tcSucursal as String ) as String
		local lcPrefijo as String, lcRetorno as String
		
		lcPrefijo = _screen.zoo.app.ObtenerPrefijoDB()
		
		if goDatos.EsNativa() or alltrim( upper( left( tcSucursal, len( lcPrefijo )))) == lcPrefijo
			lcRetorno = alltrim( tcSucursal )
		else
			lcRetorno = lcPrefijo + rtrim( tcSucursal )
		endif

		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function FinalizarProceso() as Void
		Declare Integer GetCurrentProcessId In kernel32
		lnPID = GetCurrentProcessId()
		lcExecute = "TASKKILL /PID " + alltrim(transform(lnPID)) + " /T /F"
		run &lcExecute
	endfunc	

	************************************ <ZOO UPDATE> ****************************************
	*-----------------------------------------------------------------------------------------
	function BuscarActualizaciones( tlEjecutoAplicacionBase as Boolean ) as Void
		if !_screen.zoo.app.lEsEntornoCloud 
			this.EjecutarBuscarActualizacionesas( tlEjecutoAplicacionBase )
		endif
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function EjecutarBuscarActualizacionesas( tlEjecutoAplicacionBase as Boolean ) as Void
		local lnTipoDescarga as Integer
				
		lnTipoDescarga = goparametros.nucleo.actualizaciones.OrigenDeDescarga
		if vartype( this.oListaDeZooUpdate  ) != "O"
			this.oListaDeZooUpdate = _Screen.Zoo.CrearObjeto( "zoocoleccion" )
		endif
		
		if file( addbs( _Screen.Zoo.cRutaInicial ) +  "Bin\ZooLogicSA.Actualizador.exe" ) and tlEjecutoAplicacionBase
		
			this.lVersionActualizadorSegundoPlano = .t.
			
			local lcMajor as String, lcMinor  as String, lcBuild  as String, lcIdProducto as String, lcSerie as String, lcParametros as String
			local loProcessStart as Object 
	 
			lcMajor = _Screen.zoo.app.ObtenerMajor()
			lcMinor = _Screen.zoo.app.ObtenerRelease()
			lcBuild = _Screen.zoo.app.ObtenerBuild()
			lcIdProducto = _screen.zoo.app.cProducto
			lcSerie = _Screen.zoo.app.cserie

			lcParametros = lcMajor + " " + lcMinor + " " + lcBuild + " " + lcIdProducto + " " + lcSerie
	 
			loProcessStart = _screen.dotnetbridge.crearobjeto( "System.Diagnostics.ProcessStartInfo" )
			_screen.dotnetbridge.setearvalorpropiedad( loProcessStart, "FileName", addbs( _Screen.Zoo.cRutaInicial ) +  "Bin\ZooLogicSA.Actualizador.exe" )
			_screen.dotnetbridge.setearvalorpropiedad( loProcessStart, "Arguments", lcParametros  )
			_screen.dotnetbridge.setearvalorpropiedad( loProcessStart, "WindowStyle", 1 )
			_screen.dotnetbridge.invocarmetodoestatico( "System.Diagnostics.Process", "Start", loProcessStart )

		else
			do case
				case lnTipoDescarga == 2 and goParametros.Nucleo.Actualizaciones.DescargarLasActualizacionesDeLaWebParaPublicarlasEnElServidorPropio
					&&Es un servidor de descarga y publicacion LAN
					this.BuscarActualizacionesSegunTipoDescarga( .T. , "OBTENERLAN" )
					this.nTimerZooUpdate  = goServicios.Timer.CrearNuevotimer( 1000, "goServicios.Librerias","VerificarDescargaZooUpdate")
					this.BuscarActualizacionesSegunTipoDescarga( tlEjecutoAplicacionBase, "OBTENERWEB", .t. )
						
				case lnTipoDescarga == 1
					this.BuscarActualizacionesSegunTipoDescarga( tlEjecutoAplicacionBase, "OBTENERWEB" )
						
				case lnTipoDescarga == 2
					this.BuscarActualizacionesSegunTipoDescarga( tlEjecutoAplicacionBase, "OBTENERLAN" )
			endcase
		endif

	
		if !tlEjecutoAplicacionBase
			this.NotificarActualizacionesQueEstenPendientesDePublicar( .t. )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function BuscarActualizacionesSegunTipoDescarga( tlEjecutoAplicacionBase as Boolean, tcTipoDescarga as String, tldebePublicar as Boolean ) as Void
			local loZooUpdate as Object, loParametros as Object
			
			loZooUpdate = This.ObtenerZooUpdate( tlEjecutoAplicacionBase, tcTipoDescarga )
			loParametros = This.ObtenerParametrosCargados( tlEjecutoAplicacionBase, tldebePublicar )
			
			This.CrearRutaDeDescarga( loParametros )
			
			this.oListaDeZooUpdate.Agregar( loZooUpdate )
			loZooUpdate.Actualizar( loParametros)
			
			loParametros = null
			loZooUpdate = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerZooUpdate( tlEsAplicacionBase as Boolean, tcTipoDescarga as String ) as Object
		local lcMetodoEstatico as string, llModoSilencioso as Boolean, loZooUpdate as Object, llDiaHabilitado as Boolean, llMostrarMensajes as Boolean, ;
			llInvocacionPorMenu as Boolean
		
		_Screen.zoo.AgregarReferencia( "zoologicsa.zooupdate.dll" )		
		_Screen.zoo.AgregarReferencia( "zoologicsa.lancelot.dll" )
		lcMetodoEstatico = upper( alltrim( tcTipoDescarga ) )						
		
		loValidadorDeDiasHabilitadosDeLanzarScript = _Screen.Zoo.CrearObjeto( "ZooLogicSA.Lancelot.ReglaDeNegocio.ValidadorDeDiasValidosParaActualizacion" )
		llDiaHabilitado = loValidadorDeDiasHabilitadosDeLanzarScript.Validar( date() )
		loValidadorDeDiasHabilitadosDeLanzarScript = null
		
		llInvocacionPorMenu = !tlEsAplicacionBase
		llMostrarMensajes = llInvocacionPorMenu or ;
						  ( llDiaHabilitado and !goParametros.Nucleo.Actualizaciones.DescargarAutomaticamenteActualizacionesAlIniciar )
			
		if lcMetodoEstatico == "OBTENERWEB"
			loZooUpdate = _Screen.Zoo.InvocarMetodoEstatico( "ZooLogicSA.ZooUpdate.MainFactory", lcMetodoEstatico, llMostrarMensajes, llDiaHabilitado )
		else 
			local loPaquete as Object
			loPaquete = this.obtenerDatosDescargaLan()
			loZooUpdate = _Screen.Zoo.InvocarMetodoEstatico( "ZooLogicSA.ZooUpdate.MainFactory", lcMetodoEstatico, llMostrarMensajes, loPaquete, llDiaHabilitado )
		endif
		
		return loZooUpdate
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaTemporalDescargaZooUpdate() as String
		This.AsegurarExistenciaRuta( addbs( _Screen.zoo.cRutaInicial ) + "Tmp" )
		return addbs( _Screen.zoo.cRutaInicial ) + "Tmp"
	endfunc     

	*-----------------------------------------------------------------------------------------
	protected function ObtenerParametrosCargados( tlEjecutoAplicacionBase as Boolean, tlDebePublicar as Boolean ) as Object
		local loParametros as Object
		loParametro = _screen.zoo.crearobjeto( "ZooLogicSA.ZooUpdate.Parametros" )
			
		with loParametro
			
			.TipoDescarga = goParametros.nucleo.Actualizaciones.OrigenDeDescarga
			.RutaDescargaTemporal = This.ObtenerRutaTemporalDescargaZooUpdate()
			.RutaOrigen = goParametros.nucleo.Actualizaciones.rutaDeDescarga
			.OcultarMensajeNoHayActualizaciones = tlEjecutoAplicacionBase

			
			if tlDebePublicar
				.RutaDescarga = iif( empty( .RutaOrigen ), addbs( _Screen.zoo.cRutaInicial ) + "zooUpdate", .RutaOrigen )
			else
				*-- Fix feo para que funcionen las actualizaciones en Nike. No sacar hasta arreglar de donde obtener el nombre del .EXE
				if upper( alltrim( _Screen.zoo.App.NombreProducto ) ) == "NIKE"
					.RutaDescarga = This.LeerCarpetaScriptsLancelot( addbs( _Screen.zoo.cRutaInicial ) + "Dragonfish.exe.Config" )
				else
					.RutaDescarga = This.LeerCarpetaScriptsLancelot( addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.App.NombreProducto ) + ".exe.Config" )
				endif			
			endif
			
			.RutaDescarga = alltrim( .RutaDescarga )
			
			.Build = _screen.zoo.app.ObtenerBuild()
			.Producto = _screen.zoo.app.cProducto
			.Serie = _screen.zoo.app.cSerie
			.Version = _screen.zoo.app.ObtenerVersion()
		
		endwith
		return loParametro
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function obtenerDatosDescargaLan() as Object
		local loPaquete as Object, loZUDescargaLAN as entidad OF entidad.prg, lcXml as String, lcCursor as String

		lcCursor = sys( 2015 )
		loPaquete= _screen.zoo.crearobjeto( "ZooLogicSA.ZooUpdate.Paquete" )
		
		loZUDescargaLAN = _screen.zoo.instanciarentidad( "ZUDescargaLAN" )	
		lcXML = loZUDESCARGALAN.oad.obtenerdatosentidad( "", "publicada = .t.", "VERSION" ) 
		loZUDescargaLAN.release()
		
		this.xmlacursor( lcXML, lcCursor )
		select ( lcCursor )

		scan
			loVersion = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Aplicacion.VersionOrganic", "ZooLogicSA.Core.Aplicacion", &lcCursor..version )
			
			lnVersionInstalada = _Screen.Zoo.App.oVersion.Major  * 1000000000 + _Screen.Zoo.App.oVersion.Release * 100000 + _Screen.Zoo.App.oVersion.Build
			lnVersionPublicada = loVersion.Major  * 1000000000 + loVersion.Release * 100000 + loVersion.Build
			
			if lnVersionPublicada > lnVersionInstalada 
				loPaquete.Version = &lcCursor..version
				loPaquete.Url = &lcCursor..ArchivoEntrada
				loPaquete.ArchivoDescarga  = justfname( &lcCursor..ArchivoEntrada )
				loPaquete.NombreArchivo = loPaquete.ArchivoDescarga
				exit
			endif
		endscan

		use in select( lcCursor ) 
		
		return loPaquete
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearRutaDeDescarga( loParametros as Object ) as Void
		This.AsegurarExistenciaRuta( loParametros.RutaDescarga )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsegurarExistenciaRuta( tcRuta as String ) as VOID
		local loError as zooexception OF zooexception.prg
		try
			if !directory( tcRuta ) 
				md ( tcRuta )
			endif
		catch to loError
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NotificarActualizacionesQueEstenPendientesDePublicar( tlPuedeMostrarEntidad as Boolean ) as Void
		local llDebeVerificar as Boolean, loEntidad as din_entidadZuDescargaLan OF din_entidadZuDescargaLan.prg, ;
			lcXml as String, lcCursor as String, lnRespuesta as Integer, ;
			loFormulario as formularioEdicion of formularioEdicion.prg
			
		llDebeVerificar = goParametros.Nucleo.Actualizaciones.NotificarmeDeActualizacionesQueEstenPendientesDePublicar
		
		llDebeVerificar = llDebeVerificar and ( goparametros.nucleo.actualizaciones.OrigenDeDescarga == 2 ) &&Lan
		llDebeVerificar = llDebeVerificar and !_screen.zoo.esBuildAutomatico and ;
			( _screen.zoo.app.ejecutoDesdeMain() or _screen.zoo.app.ejecutoDesdeExe() or _screen.zoo.app.EjecutoDesdeFormulario() )

		if llDebeVerificar
			if tlPuedeMostrarEntidad
				loFormulario = goFormularios.procesar( "zuDescargaLan" )
				loEntidad = loFormulario.oKontroler.oEntidad
				*lcXml = loEntidad.obtenerDatosEntidad( "codigo,FECHAMODIFICACIONFW,HORAMODIFICACIONFW", "publicada = .f.", "FECHAMODIFICACIONFW, HORAMODIFICACIONFW" )
				lcXml = loEntidad.obtenerDatosEntidad( "codigo,VERSION", "publicada = .f.", "VERSION" )
				lcCursor = sys(2015)
				this.xmlACursor( lcXml, lcCursor )
				if reccount( lcCursor ) > 0
					lnRespuesta = goServicios.Mensajes.Preguntar( "Tiene actualizaciones listas para ser publicadas. Presione aceptar para publicarla ahora.", 1, 1 )
					if lnRespuesta == 1 &&Aceptar
						loFormulario.oKontroler.oEntidad.Codigo = &lcCursor..Codigo
						loFormulario.oKontroler.Ejecutar( "MODIFICAR" )	
					endif
				endif
				use in select( lcCursor )
				loEntidad = null
				loFormulario = null
			else
				loEntidad = _screen.zoo.instanciarEntidad( "zuDescargaLan" )
				lcXml = loEntidad.obtenerDatosEntidad( "", "publicada = .f.", "VERSION" )
				lcCursor = sys(2015)
				this.xmlACursor( lcXml, lcCursor )
				if reccount( lcCursor ) > 0
					lcMensaje = "Tiene actualizaciones disponibles sin publicar." + chr(13) + chr(10) + ;
								"VersiÛn " + transform( &lcCursor..Version ) + chr(13) + chr(10) + ;
								"Archivo " + transform( &lcCursor..ArchivoEntrada ) + chr(13) + chr(10) + ;
								"Ingrese a Publicaciones LAN dentro del men˙ de ConfiguraciÛn para habilitar la actualizaciÛn a toda su red. "
					goServicios.Mensajes.Informar( lcMensaje )
				endif
				use in select( lcCursor )
				loEntidad.release()				
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarDescargaZooUpdate() as Void
		local lcRutaLog as String, lcContenido as String, loZuDescargaLAN as entidad OF entidad.prg;
		lcRuta as String, lcVersion as String, llParametro as Boolean

		llParametro = .f.
		lcRutaLog = this.ObtenerRutaLogZU()
		if file( lcRutaLog )
			goServicios.Timer.MatarUnTimerEspecifico( this.nTimerZooUpdate )

			lcContenido = filetostr( lcRutaLog )
			delete file &lcRutaLog
	
			if !empty(lcContenido)
				lcRuta = substr( lcContenido, 1, at( "@@", lcContenido ) - 1 )
				lcVersion = substr( lcContenido, at( "@@", lcContenido ) + 2 )
				try	
					llParametro = goParametros.Nucleo.Actualizaciones.PublicarAutomaticamenteLasNuevasActualizaciones
				catch 
					llParametro = .f.
				endtry
					
				try 
					loZUDescargaLAN = _screen.zoo.instanciarentidad( "ZUDescargaLAN" )	
					loZUDescargaLAN.Nuevo() 
					loZUDescargaLAN.ArchivoEntrada = lcRuta 
					loZUDescargaLAN.version = lcVersion 
					loZuDescargaLAN.Publicada = llParametro && goParametros.Nucleo.Actualizaciones.PublicarAutomaticamenteLasNuevasActualizaciones
					loZuDescargaLan.Grabar()
					loZUDescargaLAN.release()
				catch to loerror 
				endtry 
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaLogZU() as string
		return addbs( this.ObtenerRutaTemporalDescargaZooUpdate() ) + "zupublicacion.log"
	endfunc 

	********************************** </ZOO UPDATE> *****************************************
	*-----------------------------------------------------------------------------------------
	function NotificacionDescargarModulo( toSender as Object , toEventsArg as Object ) as Void
		goServicios.Mensajes.EnviarSinEspera( toSender.cModuloADescargar )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NotificacionFalloDescargarModulo( toSender as Object , toEventsArg as Object ) as Void
		This.AgregarInformacion( toSender.cFalloModuloADescargar )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LeerCarpetaScriptsLancelot( tcXml as String ) as String
		local loXml as Object, loNodo as Object, lcRetorno as String
		lcRetorno = "Tmp"
		if file( tcXml )
			loXml = _Screen.zoo.CrearObjeto( "System.XML.XmlDocument" )
			loXml.Load( tcXml )
			loNodo = loXml.SelectSingleNode( "//add[./@key='CarpetaScripts']/@value" )
			lcRetorno = loNodo.Value
			loNodo = null
			loXml = null
		else
			lcRetorno = addbs( _Screen.zoo.cRutaInicial ) + "Scripts"
			This.AsegurarExistenciaRuta( lcRetorno )
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresMasSkuValidos( tlPermiteMayusculas as Boolean ) as String
		local lcRetorno as String
				
		lcRetorno = This.ObtenerCaracteresValidos( tlPermiteMayusculas )
		lcRetorno = lcRetorno + This.ObtenerCaracteresEspecialesSkuValidos()
	
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresValidos( tlPermiteMayusculas as Boolean ) as String
		local lcRetorno as String
				
		lcRetorno = This.ObtenerNumerosValidos() + This.ObtenerLetrasValidas( tlPermiteMayusculas )
		lcRetorno = lcRetorno + This.ObtenerCaracteresBasicosValidos()
	
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNumerosValidos() as String
		return This.cNumerosValidos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLetrasValidas( tcIncluyeMinusculas as Boolean ) as String
		return This.cLetrasValidas + iif( tcIncluyeMinusculas, lower( This.cLetrasValidas ), "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresBasicosValidos() as String
		return This.cCaracteresBasicosValidos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresEspecialesSkuValidos() as String
		return This.cCaracteresEspecialesSkuValidos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteresEspecialesValidos() as String
		return This.cCaracteresEspecialesValidos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLetrasYNumerosValidos( tlIncluyeMinusculas as Boolean ) as String
		local lcRetorno as String
				
		lcRetorno = This.ObtenerNumerosValidos() + This.ObtenerLetrasValidas( tlIncluyeMinusculas ) + " ."
			
		return lcRetorno
	endfunc 

	*---------------------------------------------------------------------------------------------------------------------------------------
	function SHA1( cMessage ) As String
		local SHA1 As Object, SHA1Man As Object, AsciiEnc As Object, Sb As Object, stream, lnLen as Integer, x As Integer

		SHA1 = _screen.zoo.crearobjeto("System.Security.Cryptography.SHA1Managed")
		SHA1Man = SHA1.Create()
		AsciiEnc = _screen.zoo.crearobjeto("System.Text.Asciiencoding")
		Sb = _screen.zoo.crearobjeto("System.Text.StringBuilder")

		stream = SHA1Man.ComputeHash( AsciiEnc.GetBytes( cMessage ) )
		lnLen = len(stream)

		For x = 1 To lnLen
			sb.AppendFormat( "{0:x2}", transform(substr(stream, x, 1) ))
		next x


		return sb.ToString()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValorStringSegunDato( tcValor, tcTipoDato ) as Void
		local lxValor as Variant
		
		tcTipoDato = Alltrim( upper( tcTipoDato ) ) 
		
		do case 
			case tcTipoDato = "N"
				lxValor = val( tcValor )
			case inlist( tcTipoDato, "D", "T" )	
				lxValor = ctod( tcValor )
			case tcTipoDato = "L"			
				lxValor = &tcValor
			otherwise
				lxValor = tcValor
		EndCase		

		return lxValor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConvertirAString( txValor as Variant ) as String
		local lcValor as Variant, lcTipo as String
		
		lcTipo = vartype( txValor )
		if inlist( lcTipo , "D", "T" )	
			lcValor = dtos( txValor )
		else
			lcValor = transform( txValor )
		EndIf
		return lcValor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearPixelsPorPulgadas() as Void
		Declare Integer GetDC In USER32 As GetDC Integer HWnd
		Declare Integer ReleaseDC In USER32 As ReleaseDC Integer HWnd, Integer hdc
		Declare Integer GetDeviceCaps In GDI32 As GetDeviceCaps Integer hdc,     Integer nIndex

		#Define LOGPIXELSX 88
		#Define LOGPIXELSY 90

		Local lnDeviceHandle As Long, lnPixelsPerInch As Long
		lnDeviceHandle = GetDC(0)

		this.nPixelsPorPulgadasEnX = GetDeviceCaps(lnDeviceHandle, LOGPIXELSX)
		this.nPixelsPorPulgadasEnY = GetDeviceCaps(lnDeviceHandle, LOGPIXELSY)

		lnDeviceHandle = ReleaseDC(0, lnDeviceHandle)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RegistrarVersionActualEnZooLogic() as Void
		local loRegistrador as Object, lcSerie as String, lcProducto as String, lcBuild as String
		
		_Screen.zoo.AgregarReferencia( "zoologicsa.zooupdate.dll" )	
		loRegistrador = _screen.zoo.CrearObjeto( "ZooLogicSA.ZooUpdate.RegistrarBuildOrganic" )
		
		lcSerie = _screen.zoo.app.cSerie
		lcProducto = _screen.zoo.app.cProducto
		lcBuild = _screen.zoo.app.ObtenerBuild()

		loRegistrador.RegistrarInformacionDelProducto( lcSerie, lcProducto, lcBuild )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function NumeroALetras( tnMonto as Number, tlSinDecimales as Boolean ) as String 
		local lcRetorno as String, loConversor as Object

		lcRetorno = ""

		loConversor = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Conversiones.ConversorNumerosALetras" )
		loConversor.SinDecimales = tlSinDecimales

		lcRetorno = loConversor.toCustomCardinal( tnMonto )
		loConversor = null

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CadenaConSoloNumeros( tcVal as variant ) as Boolean
		local lxRetorno as Variant, loPar1 as Number
		llRetorno = .t.

		loPar1 = 1
		llRetorno = _screen.zoo.invocarmetodoestatico( "System.Int32", "TryParse", alltrim( tcVal ) , loPar1 )
	
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMisDocumentos() as String
        Local lcRetorno As String, lcFolderPath As String, loError As Exception
        lcFolderPath = Space( 255 )
        Try
              Declare Short SHGetFolderPath In SHFolder.dll ;
                    Integer hwndOwner, ;
                    Integer nFolder, ;
                    Integer hToken, ;
                    Integer dwFlags, ;
                    String @pszPath

              SHGetFolderPath( 0, CSIDL_PERSONAL, 0, 0, @lcFolderPath )
              lcRetorno = Alltrim( lcFolderPath )
              lcRetorno = SubStr( lcRetorno, 01, Len( lcRetorno ) - 01 )
        Catch To loError
              lcRetorno = ""
        Finally
              Clear Dlls "SHGetFolderPath"
        EndTry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCarpetaProductoMisDocumentos( tcCarpeta as string ) as Void
		local lcRuta as String, lcDocumentos as String
		
		lcDocumentos = addbs( getenv("PUBLIC") ) + "Documents"
		lcRuta = addbs( lcDocumentos ) + alltrim( _Screen.zoo.App.Nombre )
		if vartype( tcCarpeta ) = "C" and !empty( tcCarpeta )
			lcRuta = addbs( lcRuta ) + tcCarpeta
		endif
		try
			if !directory( lcRuta ) 
				md( lcRuta )
			endif
		catch
		endtry
		
		return lcRuta
	endfunc
	
 	*-----------------------------------------------------------------------------------------
	function ObtenerVersionExcelInstalada() as Integer
		local loExcel as Object, lnRetorno as Integer
		lnRetorno = 12
		try
			loExcel = newobject( "excel.application" )
			lnRetorno = val( loExcel.Version )
		catch to loError
		endtry
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarExcelInstalado() as boolean
		local loError as Exception, loEx as Exception
		llRetorno = .f.
		try
			loExcel = newobject( "Excel.Application" )
			llExiste = ("EXCEL.EXE" $ Upper( this.ObtenerProgramaAsociado( "xlsx" ) ) ) or ("EXCEL.EXE" $ Upper( this.ObtenerProgramaAsociado( "xlsm" ) ) )
			llRetorno = llExiste and vartype(loExcel)=="O"
		Catch To loError
			llRetorno = .f.
		EndTry

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerProgramaAsociado( tcExtension as String ) as String
		Local lcRetorno As String, lnBuffSize As Number, lcPath As String, lnRetVal As Number
		
			Declare Integer AssocQueryString In "shlwapi.dll" ;
			   LONG ASSOCF, ;
			   LONG ASSOCSTR, ;
			   String pszAssoc, ;
			   String pszExtra, ;
			   String pszOut, ;
			   LONG @pcchOut

			lcRetorno = ""
		    lnBuffSize = 1024
		    lcPath = Replicate( Chr( 0 ),lnBuffSize )
		    lnRetVal = AssocQueryString( 0 , 2, '.' + tcExtension , "open" , @m.lcPath, @lnBuffSize )
		    If lnRetVal = 0
		    	lcRetorno = Left( m.lcPath, At( Chr( 0 ), m.lcPath ) - 1 )
			Endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerColeccionArchivos( tcRuta as String, tcExtencion as String, tlAgregarDatos as Boolean ) as zooColeccion of zooColeccion.prg
		local lnCantidadDeArchivos as Integer, i as Integer, loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as custom, ;
			lcExtension as String
		local array laArchivosZip[ 1 ]

		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		if directory( tcRuta )
			if vartype( tcExtencion ) != "C" or empty( tcExtencion )
				lcExtension = "*.*"
			else
				lcExtension = tcExtencion
			endif
			lnCantidadDeArchivos = adir( laArchivosZip, addbs( tcRuta ) + lcExtension )
			asort( laArchivosZip ) && Ordeno de forma ascendente el array para que reciba en orden los archivos
			
			for i = 1 to lnCantidadDeArchivos
				if tlAgregarDatos
					loItem = _Screen.zoo.crearobjeto( "ItemArchivoLibrerias", "Librerias.prg" )
					loItem.cNombreDeArchivo = laArchivosZip[ i, 1 ]
					loItem.cRutaDelArchivo = addbs( tcRuta )
					loItem.cRutaCompleta = addbs( tcRuta ) + laArchivosZip[ i, 1 ] 
					loItem.nTamanio = laArchivosZip[ i, 2 ]
					loItem.nIdLogueo = i
				else
					loItem = laArchivosZip[ i, 1 ]
				endif

				loRetorno.agregar( loItem )
			endfor
		endif
				
		return loRetorno
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RepararTabla( tcRuta as String, tcFileName as String ) as boolean
		local lnHandle as Integer, lcString as String, lc1stByte as String, lnOffset as Integer, lcRecSize as String, ;
			lnRecSize as Integer, lnActRecs as Integer, lcActCnt as String, lnX as Integer, llRetorno as Boolean, ;
			lnOldtablevalidate as Number
		local array laDir[ 1 ], laByte[ 4 ]

		tcFileName = forceext( alltrim( tcFileName ), "DBF" )
		llRetorno = .f.
		try
			* Get the DOS directory information for the file
			adir( laDir, tcRuta + tcFileName )

			* Open the file for low level access
			lnHandle = fopen( tcRuta + tcFileName, 2 )

			if lnHandle < 0
				local loex as exception
				loex = newobject(  "zooexception", "zooexception.prg" )
				with loex
					.message = "Se produjo un error al abrir el archivo " + tcRuta + tcFileName
					.details = .message
					.grabar()
					.throw()
				endwith 
			endif

			* Read the first 12 bytes from the file header
			lcString = fread( lnHandle, 12 )

			* Get offset to first byte of data from string
			lc1stByte = substr( lcString, 9, 2 )
			lnOffset  = asc( substr( lc1stByte, 1, 1 ) )
			lnOffset  = lnOffset + asc( substr( lc1stByte, 2, 1 ) ) * 256

			* Get Record length from header
			lcRecSize = substr( lcString, 11, 2 )
			lnRecSize = asc( substr( lcRecSize, 1, 1 ) )
			lnRecSize = lnRecSize + asc( substr( lcRecSize, 2 , 1 ) ) * 256

			* Calculate the actual number of records
			* Take the file size and subtract the header
			* Divide the result by the record size
			lnActRecs = int( ( laDir( 2 ) - lnOffset ) / lnRecSize )

			dimension laByte[ 4 ]

			* Convert to base 256 for the actual record count
			laByte[ 4 ] = int( lnActRecs / 256 ^ 3 )
			lnActRecs = lnActRecs - ( laByte[ 4 ] * 256 ^ 3 )

			laByte[ 3 ] = int( lnActRecs / 256 ^ 2 )
			lnActRecs = lnActRecs - ( laByte[ 3 ] * 256 ^ 2 )

			laByte[ 2 ] = int( lnActRecs / 256 )
			laByte[ 1 ] = lnActRecs - ( laByte[ 2 ] * 256 )

			* Build the string
			lcActCnt = ""
			for lnX = 1 to 4
				lcActCnt = lcActCnt + chr( laByte[ lnX ] )
			endfor

			* Position pointer in the file for the write operation
			fseek( lnHandle, 4 )

			* Write the calculated record count to the file
			fwrite( lnHandle, lcActCnt )

			* Close the file
			fclose( lnHandle )
			
			* chequea que lo reparo ok
			try
				use ( tcRuta + tcFileName ) in 0 alias tmp
				this.loguear( "Se reparÛ exitosamente la tabla " + tcRuta + tcFileName )
				llRetorno = .t.
			catch
				llRetorno = .f.
				this.loguear( "No se pudo reparar la tabla " + tcRuta + tcFileName )
			finally
				use in select( "tmp" )
			endtry
		catch to loError
			this.Loguear( "Se produjo un error reparando el archivo " + tcRuta + tcFileName + "." + chr( 13 ) + chr( 10 ) + ;
					loError.Message )
		endtry
		
		return llRetorno
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCodigosAsciiParaArmarExpresionesTipoString() as zoocoleccion OF zoocoleccion.prg
		return This.oColCodigosAsciiParaArmarString
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsCodigoAsciiParaArmarExpresionTipoString( tnKeyCode as Integer ) as Boolean
		local loCol as zoocoleccion OF zoocoleccion.prg
		
		loCol = this.ObtenerCodigosAsciiParaArmarExpresionesTipoString()
		
		return loCol.Buscar( alltrim( str( tnKeyCode ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColCodigosAsciiParaArmarString_Access() as Void
		local lcSeparador as string, lnI as Integer
		dimension arrCodigos[1]
	
		if !this.ldestroy and ( vartype( This.oColCodigosAsciiParaArmarString ) != "O" or This.oColCodigosAsciiParaArmarString = null )
			lcSeparador = ","
			This.oColCodigosAsciiParaArmarString = _screen.zoo.app.CrearObjeto( "ZooColeccion" )
			alines( arrCodigos, alltrim( goRegistry.Nucleo.CodigosAsciiParaArmarExpresionesTipoString ), 4, lcSeparador )
			for lnI = 1 to alen( arrCodigos )
				This.oColCodigosAsciiParaArmarString.Agregar( alltrim( arrCodigos[ lnI ] ), alltrim( arrCodigos[ lnI ] ) )
			next
			
		endif
		return This.oColCodigosAsciiParaArmarString
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReemplazarCodigosAsciiParaArmarExpresionesTipoString( tcCadena as String, toClase as Object ) as String
		local lnCant as Integer, lcRetorno as Boolean, lnI as Integer, lcAscii as string, loCol as zoocoleccion OF zoocoleccion.prg, ;
			llPermiteComillas as Boolean

		lcRetorno = tcCadena
		llPermiteComillas = .t.
		if pcount() > 1 and pemstatus( toClase, "lPermiteCaracteresComilla", 5)
			llPermiteComillas = toClase.lPermiteCaracteresComilla
		endif

		if !empty( tcCadena )
			loCol = this.ObtenerCodigosAsciiParaArmarExpresionesTipoString()
			for lnI = 1 to loCol.count
				lcAscii = loCol.Item[ lnI ]
				if lcAscii = "34" and llPermiteComillas
				else
					if Occurs( chr( &lcAscii ), lcRetorno ) > 0
						lcRetorno = strtran( lcRetorno, chr( &lcAscii ), "" )
					endif
				endif
			next
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarDescargasEnProceso() as Void
		Try		
			if vartype( this.oListaDeZooUpdate ) == "O" 
				for each loItem in this.oListaDeZooUpdate foxobject
					loItem.CancelarDescargasActivas()
				endfor 
				this.oListaDeZooUpdate.remove(-1)
			endif
		Catch
			** No se procesa el error.
		finally
			this.oListaDeZooUpdate = null
		endtry 		
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoDiaDelMes( ldFecha as Date ) as date
		return gomonth( date( year( ldFecha ), month( ldFecha ), 1 ), 1 ) - 1
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SepararEnSegmentos( tcTexto as String, tnAncho as Long, tcSeparador as String ) as String
		local lcSegmentado as String, lnPosicion as Long
		
		lcSegmentado = ''
		lnPosicion = 1
		do while lnPosicion <= len( alltrim( tcTexto ) )
			lcSegmentado = lcSegmentado + substr( alltrim( tcTexto ), lnPosicion, tnAncho ) + tcSeparador
			lnPosicion = lnPosicion + tnAncho
		enddo
		lcSegmentado = left( lcSegmentado, len( lcSegmentado ) - len( tcSeparador ) )
		
		return lcSegmentado
	endfunc 

	*-----------------------------------------------------------------------------------------
	*	Funciones para procesar n˙meros enteros con m·s de 10 dÌgitos significativos
	*-----------------------------------------------------------------------------------------
	protected function EsEntero( tcNumero as String ) as Boolean
		local llEsEntero as Boolean, lnPosicion as Long, lcAux as string
		
		llEsEntero = .T.
		
		lcAux = alltrim( tcNumero )
		lnPosicion = 1
		do while ( lnPosicion <= len( lcAux ) ) and llEsEntero
			llEsEntero = llEsEntero and ( at( substr( lcAux, lnPosicion, 1), '0123456789' ) > 0 )
			lnPosicion = lnPosicion + 1
		enddo
		
		return llEsEntero
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SumaDeLosDigitosDeUnNumero( tcNumero as String ) as Integer
		local lnSuma as Integer, lnDigito as Integer, lcAux as long
		
		lnSuma = 0
		if this.EsEntero( tcNumero )
			lcAux = alltrim( tcNumero )
			do while len( lcAux ) > 0
				lnDigito = val( right( lcAux, 1) )
				lnSuma = lnSuma + lnDigito
				lcAux = left( lcAux, len( lcAux ) - 1 )
			enddo
		endif
				
		return lnSuma
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerResto( tcNumerador as String, tcDivisor as String ) as long
		local lnResto as Long, lnParte as long, lcParte as String, lcResto as String, lnResto as long 
		
		lnResto = 0
		if this.EsEntero( tcNumerador ) and this.EsEntero( tcDivisor ) and ( alltrim( tcDivisor ) = transform( val( tcDivisor ) ) )
			lcResto = alltrim( tcNumerador )
			do while val( lcResto ) > val( alltrim( tcDivisor ) )
				lcParte = ''
				lnParte = 0
				do while val( lcParte ) < val( alltrim( tcDivisor ) )
					lnParte = lnParte + 1
					lcParte = left( lcResto, lnParte )
				enddo
				lcResto = substr( lcResto, lnParte + 1 )
				lnResto = mod( val( lcParte ), val( tcDivisor ) )
				lcResto = transform( lnResto ) + lcResto
			enddo
			
			if val( lcResto ) != lnResto
				lnResto = val( lcResto )
			endif	
		endif
		
		return lnResto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DivisionEntera( tcNumerador as String, tcDivisor as String ) as string
		local lnResto as Long, lcDividendo as String, lnParte as long, lcParte as String, lcResto as String, lnResto as long, lnSalto as long
		
		lcDividendo = ''
		if this.EsEntero( tcNumerador ) and this.EsEntero( tcDivisor ) and ( alltrim( tcDivisor ) = transform( val( tcDivisor ) ) )
			if  val( alltrim( tcNumerador ) ) > val( alltrim( tcDivisor ) )
				lcResto = alltrim( tcNumerador )
				lnResto = 0
				
				do while val( lcResto ) >= val( alltrim( tcDivisor ) )
					lcParte = ''
					lnParte = 0
					do while val( lcParte ) < val( alltrim( tcDivisor ) )
						lnParte = lnParte + 1
						lcParte = left( lcResto, lnParte )
					enddo
					
					lnSalto = lnParte - ( len( transform( lnResto ) ) + 1 )
					if lnSalto > 0
						lcDividendo = lcDividendo + replicate( '0', lnSalto )
					endif
					lcDividendo = lcDividendo + transform( int( val( lcParte ) / val( tcDivisor ) ) )
					
					lcResto = substr( lcResto, lnParte + 1 )
					lnResto = mod( val( lcParte ), val( tcDivisor ) )
					if ( len( lcResto ) > 0 ) and ( val( transform( lnResto ) + lcResto ) < val( alltrim( tcDivisor ) ) )
						lcDividendo = lcDividendo + replicate( '0', len( lcResto ) )
					endif
					
					lcResto = transform( lnResto ) + lcResto
				enddo	
				
				do while left( lcDividendo, 1 ) = '0'
					lcDividendo = substr( lcDividendo, 2 )
				enddo
			else
				lcDividendo = '0'
			endif
		endif
		
		return lcDividendo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConvierteABase32( tcNumero as String, tcSimbolos as string ) as String
		local lcBase32 as String, lnResto as Integer, lcAux as string, lcSimbolos as String, lnInd as Long, llListaValida as Boolean
		
		&& Valida la lista de sÌmbolos
		lcSimbolos = alltrim( tcSimbolos )
		llListaValida = .T.
		if len( lcSimbolos ) > 31
			lnInd = 1
			lcSimbolos = left( lcSimbolos, 32 )
			do while llListaValida and ( lnInd < 32 )
				llListaValida = llListaValida and ( occurs( substr( lcSimbolos, lnInd, 1 ), lcsimbolos ) = 1 )
				lnInd = lnInd + 1
			enddo
		else
			llListaValida = .F.
		endif
				
		lcBase32 = ''
		if llListaValida and this.EsEntero( tcNumero )
			lcAux = alltrim( tcNumero )
			do while val( lcAux ) > 32
				lnResto = this.ObtenerResto( lcAux, '32' )
				lcBase32 = substr(lcSimbolos, lnResto + 1, 1) + lcBase32
				lcAux = this.DivisionEntera( lcAux, '32' )
			enddo
			
			lcBase32 = substr(lcSimbolos, val( lcAux ) + 1, 1) + lcBase32
		endif
		
		return lcBase32
	endfunc 

	*-----------------------------------------------------------------------------------------
	*	Algoritmo de Luhn ( usado para validar tarjetas de crÈdito, IMEI, etc )
	*-----------------------------------------------------------------------------------------
	function DigitoVerificadorDeLuhn( tcNumero AS String ) as Integer
		local lnDigito as Integer, lnResto as Integer, lnPosicion as Integer, lcTransformado as Long, lcAux as Long
		
		lnDigito = 0
		if this.EsEntero( tcNumero )
			lcAux = alltrim( tcNumero )
			lcTransformado = ''
			lnPosicion = 1
			do while lnPosicion <= len( lcAux )
				lnResto = val( substr( lcAux, len( lcAux ) - lnPosicion + 1, 1 ) )
				
				if mod( lnPosicion, 2 ) = 1
					lnResto =  this.SumaDeLosDigitosDeUnNumero( transform( lnResto * 2 ) )
				endif
				
				lcTransformado = transform( lnResto ) + lcTransformado
				lnPosicion = lnPosicion + 1
			enddo
			
			lnDigito = mod( ( 10 - mod( this.SumaDeLosDigitosDeUnNumero( lcTransformado ), 10 ) ), 10 )
		endif
		
		return lnDigito
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConvertirFechaACaracterConFormato( tdFecha as Date, tcFormato as String ) as String
		local loDataTime as Object, lcFechaTexto as String
	
		loDataTime = _screen.zoo.crearobjeto( "System.DateTime","", year( tdFecha ), month( tdFecha ) , day( tdFecha ) )
	    lcFechaTexto = loDataTime.ToString( tcFormato )
	    
	    loDataTime = null
	    
	    return lcFechaTexto
    
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCursorDesdeArchivoXML( tcArchivo as string, tcCursor as string, tnDataSessionId as Integer  ) as Void
		local lnData as Integer, strXML as String, loError as Exception 
		
		lnData = set('Datasession')
		set datasession to ( tnDataSessionId )
			try	
			if file( tcArchivo )
				strXML = filetostr( tcArchivo )
				xmltocursor( strXML, tcCursor, 4 )
			else
				goServicios.Errores.LevantarExcepcion( "El archivo no existe." )	
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( "Error al levantar la informaciÛn del XML " + tcArchivo + " mensaje: "  + loError.Message )
		finally
			set datasession to ( lnData )
		endtry
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function CrearSemillaFecha() as Void
		this.iniciarSemillaFecha()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oRelojInicial_Access() as Void
		if !this.ldestroy and ( !vartype( this.oRelojInicial ) = 'O' or isnull( this.oRelojInicial) ) and vartype( _screen.NetExtender ) = 'O'
			try	
				this.oRelojInicial =  _screen.zoo.crearobjeto( "System.Diagnostics.Stopwatch" )
				this.iniciarSemillaFecha()
			catch to loError
				this.lDebeGenerarSemillaDateTime = .t.
			endtry
		endif
		return this.oRelojInicial 
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function IniciarSemillaFecha() as Void
		this.dDateTimeSQLServer = this.ObtenerFechaServidorSQL()
		if vartype( this.oRelojInicial ) =="O"
			this.oRelojInicial.Reset()
			this.oRelojInicial.start()
		endif
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ObtenerFechaServidorSQL() as DateTime
		local ldDateTime as Datetime
		try 		
			this.xmlacursor( goServicios.Datos.EjecutarSQL( "select getdate() as Fecha" ), "c_DateTime" )
			ldDateTime = c_DateTime.Fecha
			use in select( "c_DateTime" )
			this.lDebeGenerarSemillaDateTime = .F.
		catch to loError 
			this.lDebeGenerarSemillaDateTime = .t.
			ldDateTime = datetime()
		endtry 
		return ldDateTime
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDateTimeSegunSemilla as DateTime
		local lnDiferencia as Integer
		if this.lDebeGenerarSemillaDateTime 
			this.IniciarSemillaFecha() 
		endif 
		lnDiferencia = this.ObtenerDiferenciaReloj()
		ldDateTime = this.dDateTimeSQLServer + lnDiferencia
		
		return ldDateTime
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDiferenciaReloj()as Integer
	local lnDiferencia 

		if vartype( this.oRelojInicial ) =="O"
			lnDiferencia = this.oRelojInicial.ElapsedMilliseconds
			if lnDiferencia > 3600000
				this.Iniciarsemillafecha()
				lnDiferencia = this.oRelojInicial.ElapsedMilliseconds
			endif 
		else 
			lnDiferencia = 0
		endif
		
		return ( lnDiferencia / 1000 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarEditorDeTextoPlano( tcArchivo as String, toSuscriptorACambiosDeArchivo as Object, tcDelegadoANotificar as string ) as Object
		local lcEjecutableEditor as String, loFSWatcher as Object
		lcEjecutableEditor = addbs( _screen.Zoo.cRutaInicial ) + "Componentes\NPP\notepad++.exe"
		loFSWatcher = null
		if ( file( lcEjecutableEditor ) )
			if ( file( tcArchivo ) )
				loFSWatcher = this.ObtenerFSWatcher( tcArchivo, toSuscriptorACambiosDeArchivo, tcDelegadoANotificar )
				goServicios.Ejecucion.EjecutarAplicacion( lcEjecutableEditor, tcArchivo, .t., .t. )
			else
				goServicios.Mensajes.Informar( "El archivo a editar " + tcArchivo + " no existe." )
			endif
		else
			goServicios.Mensajes.Informar( "El editor de texto no se encuentra en la ubicaciÛn " + lcEjecutableEditor + ". Asegurese que la aplicaciÛn este correctamente instalada." )
		endif
		return loFSWatcher
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFSWatcher( tcArchivo as String, toSuscriptorACambiosDeArchivo as Object, tcDelegadoANotificar as string  ) as Object
		local loFSWatcher as Object
		loFSWatcher = null
		if vartype( toSuscriptorACambiosDeArchivo ) == "O" and !isnull( toSuscriptorACambiosDeArchivo ) and pemstatus( toSuscriptorACambiosDeArchivo, tcDelegadoANotificar, 3 ) == "Method"
			loFSWatcher = _screen.Zoo.CrearObjeto( "ZooLogicSA.Interoperabilidad.FSWatcher", "", justpath( tcArchivo ), justfname( tcArchivo ) )
			loFSWatcher.SuscribirACambios( toSuscriptorACambiosDeArchivo, tcDelegadoANotificar )
		endif
		return loFSWatcher
	endfunc

	*-----------------------------------------------------------------------------------------
	function ConvertirABaseSegunCaracteresValidosParaCodigos( nNumero as Integer ) as String
		local baseChars as Object, lcCaracteresValidos as String, lcRetorno as String, lcNumBase as String, lnResto as Integer, lnIndice as Integer
		
		baseChars = newobject( "Collection" )
		lcCaracteresValidos = chrtran( this.ObtenerCaracteresValidos( .f. ), " ", "")
		lcCaracteresValidos = chrtran( this.ObtenerCaracteresValidos( .f. ), "—", "")

		for lnI = 1 to len( lcCaracteresValidos )
			baseChars.Add( substr( lcCaracteresValidos, lnI, 1 ) )
		endfor

        lcRetorno = ""
        lcNumBase = baseChars.Count

		lnResto = nNumero

        do while lnResto > 0
	        lnIndice = ( lnResto % lcNumBase ) + 1
            lcRetorno = baseChars.Item[ lnIndice ] + lcRetorno
            lnResto = int( lnResto / lcNumBase )
		enddo
		
        return lcRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIdentificadorGlobal() as String
		local lcCodigo as String, lcCursor as String
		lcCursor = sys( 2015 )
		goServicios.Datos.EjecutarSQL( "SELECT Funciones.ObtenerIdGlobal() AS IdGlobal", lcCursor, set( "Datasession" ) )
		lcCodigo = alltrim(  &lcCursor..IdGlobal )
		use in select( lcCursor )
		return lcCodigo
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerLongitudMaximaDeIdentificadorGlobal() as Integer
		return this.nLongitudMaximaDeIdentificadorGlobal
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDelServicioAAO() as String
		local lcEstado as String
		lcEstado = this.oManagerDeServiciosDeWindows.EstadoServicio( NOMBRESERVICIOAAO )
		return lcEstado
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTipoDeInicioDelServicioAAO() as String
		local lcTipoDeInicio as String
		lcTipoDeInicio = this.oManagerDeServiciosDeWindows.ObtenerTipoDeInicio( NOMBRESERVICIOAAO )
		return lcTipoDeInicio
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarServicioAAO() as Boolean
		local llServicioIniciado as Boolean, lcEstado as String
		llServicioIniciado = .f.
		if this.oManagerDeServiciosDeWindows.Existe( NOMBRESERVICIOAAO )
			lcEstado = this.ObtenerEstadoDelServicioAAO()
			llServicioIniciado = ( upper( alltrim( lcEstado ) ) == "INICIADO" )
			if !llServicioIniciado
				goServicios.Mensajes.EnviarSinEsperaProcesando( "Intentando iniciar el servicio del " + DESCRIPCIONSERVICIOAAO + "..." )
				this.oManagerDeServiciosDeWindows.IniciarServicio( NOMBRESERVICIOAAO )
				goServicios.Mensajes.EnviarSinEsperaProcesando()
				lcEstado = this.ObtenerEstadoDelServicioAAO()
				llServicioIniciado = ( upper( alltrim( lcEstado ) ) == "INICIADO" )
*!*					if !llServicioIniciado
*!*						goServicios.Mensajes.Advertir( "No fue posible iniciar el servicio del " + DESCRIPCIONSERVICIOAAO + ". El estado actual del mismo es " + ;
*!*							lcEstado + ", el tipo de inicio esta configurado como " + this.oManagerDeServiciosDeWindows.ObtenerTipoDeInicio( NOMBRESERVICIOAAO ) + "." + ;
*!*							chr( 13 ) + chr( 10 ) + chr( 13 ) + chr( 10 ) + ;
*!*							"Las operaciones que dependan de este servicio no se realizar·n hasta que el mismo se encuentre disponible." )
*!*					endif
			endif
		endif
		return llServicioIniciado
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerVersionSistemaOperativo() as String
		local oWMI as Object, oItems as Object, lcVersion as String

		lcVersion = "0.0"

		oWMI = getobject("winmgmts:")
		oItems = oWMI.ExecQuery( "select Version from Win32_OperatingSystem" )

		for each loItem in oItems
			lcVersion = loItem.Version
		endfor

		return lcVersion
	endfunc

	*-----------------------------------------------------------------------------------------
	function EscapeCaracteresSQLServer( tcTexto as TextBox ) as Void
		return 	strtran( tcTexto, "'", "''" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreUsuarioSO() as Void
	    local lcUsuario as String
	    lcUsuario = alltrim( substr( sys( 0 ), at( "#" , sys( 0 ) ) + 2 ) )
	    if right(lcUsuario, 1) == "$"
		    lcUsuario = left(lcUsuario, len(lcUsuario) - 1) && Quitar el signo $ al usuario obtenido por sys (0), para normalizar independientemente del contexto de Windows (Sin $: Dragon - Con $: API)
		endif
	    return lcUsuario
	endfunc

	*-----------------------------------------------------------------------------------------
	function RedondearSegunPrecision( tnNumero as float, tnPrecision as Integer ) as float
		return round( iif(vartype(tnNumero)="N",tnNumero,0), iif(vartype(tnPrecision)="N",tnPrecision,8))
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConvertirNumeroSistemaDecimalAOtraBase( tnNumero as Integer, tnBase as Integer ) as String
		local lcRetorno as String, lnResto as Integer, lcCaracter as String
		
		lcRetorno = ''
		if empty( tnBase )
			tnBase = 10
		endif
		
		do while tnNumero > 0
			lnResto = mod( tnNumero, tnBase )
			tnNumero = int( tnNumero / tnBase )
			lcCaracter = iif( lnresto < 10, str( lnresto, 1 ), chr( lnResto + 55 ) )
			lcRetorno = lcCaracter + lcRetorno
		enddo
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function obtenerLeyendaTaxFree() as Void
		return "[Bienes gravados producidos en el paÌs - ]"	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerLeyendaTaxFreeVacia() as Void
		return "[]"	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReemplazarCaracteresParaLince( tcCadena as String ) as string

		Local lcRetorno As String

		lcRetorno = Alltrim( tcCadena )	
		
		lcRetorno = Strtran( lcRetorno, "·", "†" )
		lcRetorno = Strtran( lcRetorno, "È", "Ç" )
		lcRetorno = Strtran( lcRetorno, "Ì", "°" )
		lcRetorno = Strtran( lcRetorno, "Û", "¢" )
		lcRetorno = Strtran( lcRetorno, "˙", "£" )
		lcRetorno = Strtran( lcRetorno, "¸", "Å" )
		lcRetorno = Strtran( lcRetorno, "Ò", "§" )
		
		lcRetorno = Strtran( lcRetorno, "¡", "A" )
		lcRetorno = Strtran( lcRetorno, "…", "ê" )
		lcRetorno = Strtran( lcRetorno, "Õ", "I" )
		lcRetorno = Strtran( lcRetorno, "”", "O" )
		lcRetorno = Strtran( lcRetorno, "⁄", "U" )
		lcRetorno = Strtran( lcRetorno, "‹", "ö" )
		lcRetorno = Strtran( lcRetorno, "—", "•" )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InvertirString( tcString as String )
		local lnI as Integer, lcRetorno as String

		lcRetorno = ''

		for lnI = len( tcString ) to 1 step -1
			lcRetorno = lcRetorno + substr( tcString, lnI, 1 )
		endfor

		return lcRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroComprobanteFormateado( tcLetra, tnPuntoDeVenta, tnNumero ) as Void
		local lcRetorno
		lcRetorno = alltrim( tcLetra ) + " " + padl( alltrim( str( tnPuntoDeVenta ) ), 4, "0" ) + "-" + padl( alltrim( str( tnNumero  ) ), 8, "0" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EntidadPura( tcEntidad as String ) as String
		local lcEntidad as String
		
		&& En el framework de listados se fuerza la referencia a entidades superiores con el
		&& prefijo Ent# y a los detalles con Det# de tal forma que para obtener el nombre
		&& de la entidad es necesario sacar estos prefijos.
		
		if !empty( tcEntidad ) and vartype( tcEntidad ) == "C"
			lcEntidad = tcEntidad
			
			lcEntidad = upper( alltrim( lcEntidad ) )
			lcEntidad = strtran( lcEntidad, "ENT#", "" )
			lcEntidad = strtran( lcEntidad, "DET#", "" )
		else
			lcEntidad = ""
		endif
		
		return lcEntidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Hashear( tcTexto as String ) as String
		local lcHash as String
		
		try
			if isnull( tcTexto )
				lcHash = ''
			else
				lcHash = this.oCrypto.Hashear( tcTexto )
			endif
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Endtry
		
		return lcHash
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CompararHash( tcTexto as String, tcHash as String ) as Boolean
		local llRetorno as Boolean	

		try
			if isnull( tcTexto )
				llRetorno = .f.
			else
				llRetorno = this.oCrypto.Comparar( tcTexto, tcHash )
			endif
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Endtry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEntornoAB() as Void
        set sysformats off
        set century on
        set currency to 'left'
        set date to british
        set decimals to 2
        set hours to 24
    	set mark to '/'
    	set point to '.'
    	set separator to ','
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLeyendaMonotributo() as String
		return "[El crÈdito fiscal discriminado en el presente comprobante, sÛlo podr· ser computado a efectos del RÈgimen de Sostenimiento e InclusiÛn Fiscal para PequeÒos Contribuyentes de la Ley N∫ 27.618 ]"	
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemArchivoLibrerias as Custom
	cNombreDeArchivo  = ""
	cRutaDelArchivo = ""
	cRutaCompleta = ""
	nTamanio = 0
	nIdLogueo = 0
enddefine


