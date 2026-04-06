#Define RY_FIND 1
#Define RY_OPEN 3
#Define RY_CLOSE 4
#Define RY_READ 5
#Define RY_READ_USERID 10

#Define ERR_SUCCESS 0
#Define ERR_NO_PARALLEL_PORT 1
#Define ERR_NO_DRIVER 2
#Define ERR_NO_ROCKEY 3
#Define ERR_INVALID_PASSWORD 4
#Define ERR_INVALID_PASSWORD_OR_ID 5
#Define ERR_SETID 6
#Define ERR_INVALID_ADDR_OR_SIZE 7
#Define ERR_UNKNOWN_COMMAND 8
#Define ERR_NOTBELEVEL3 9
#Define ERR_READ 10
#Define ERR_WRITE 11
#Define ERR_RANDOM 12
#Define ERR_SEED 13
#Define ERR_CALCULATE 14
#Define ERR_NO_OPEN 15
#Define ERR_OPEN_OVERFLOW 16
#Define ERR_NOMORE 17
#Define ERR_NEED_FIND 18
#Define ERR_DECREASE 19
#Define ERR_AR_BADCOMMAND 20
#Define ERR_AR_UNKNOWN_OPCODE 21
#Define ERR_AR_WRONGBEGIN 22
#Define ERR_AR_WRONG_END 23
#Define ERR_AR_VALUEOVERFLOW 24
#Define ERR_NET_LOGINAGAIN 1001
#Define ERR_NET_NETERROR 1002
#Define ERR_NET_LOGIN 1003
#Define ERR_NET_INVALIDHANDLE 1004
#Define ERR_NET_BADARDWARE 1005
#Define ERR_NET_REFUSE 1006
#Define ERR_NET_BADSERVER 1007

#INCLUDE build.h
#INCLUDE dovfp.h
_screen._instanceFactory.LoadReference("AplicacionFelino", "Organic.Feline.app")

*-----------------------------------------------------------------------------------------
Define Class AplicacionZL As AplicacionFelino Of AplicacionFelino.prg

	cSchemaDefault = "ZL"
	Nombre = "Zoo Logic ZL"
	NombreProducto = "ZL"
	cProyecto = 'ZL'
	cProducto = "03"
	nIndiceTimerAlarmaChecklineHost = 0
	nIndiceTimerVerificarArchivoTecnoVoz = 0
	MilisegundosTimerVerificarArchivoTecnoVoz = 0
	nCantMinutosAlarma = 0
	cRutaZooLogic = ''
	cRutaLince = ''
	cRutaLincePro = ''
	lUtilizaPrefijoDB = .F.
	oTecnoVoz = Null

	*-----------------------------------------------------------------------------------------
	Function ObtenerSucursalDefault() As Void
		Return "ZL"
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Iniciar( tcSerie as string, tcClave as string, tcSitio as string ) As Void
		Public lcClase As String, goRobotCheckLine As Object, goRobotHost As Object
		** goRobotCheckLine: Se utiliza para el servicio de checkline. Este se enciende o apaga desde una opción de menu.
		** goRobotHost: Se utiliza para el servicio de chequeo de log de e-host. Este se enciende o apaga desde una opción de menu.
		DoDefault()
		This.ObtenerRutaZooLogic()
		This.ObtenerRutaLince()
		This.ObtenerRutaLincePro()
		This.InicializarTimerTecnoVoz()
	Endfunc
*!* ZL 2028	
	*------------------------------------------------------------------------
	function TargetModeDebug() as boolean
		local llTargetMode as boolean
		*!*	 DRAGON 2028
		#IF DOVFP_BUILD_DEBUG
			llTargetMode = .t.
		#ELSE	
			llTargetMode = .f.
		#ENDIF
		return llTargetMode
	endfunc
*!*	 ZL 2028
	*-----------------------------------------------------------------------------------------
	function SetearAplicacion() as Void
		with this
			.oVersion = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Aplicacion.VersionOrganic", "ZooLogicSA.Core.Aplicacion", transform( NUMEROMAJOR ), transform( NUMERORELEASE ), transform( NUMEROBUILD ) )
			.cNombreExe = NOMBREEXE
			.cEstadoDelSistema	=	""
		endwith
	endfunc

*!*	 ZL 2028
	*-----------------------------------------------------------------------------------------
	function ObtenerMesAnioDeCompilacionDeLaVersionActual() as String
		return MESDELBUILD + ' ' + ANIODELBUILD
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function InicializarTimerAlarmaChecklineHost() As Void
		Local lnIndiceDisponible As Integer
		If goParametros.zl.MinutosControlChecklineHost > 0 And This.lEstoyUsandoTimers
			lnIndiceDisponible = goTimer.CrearNuevoTimer( 60000, "_screen.zoo.app", "ChequeoAlarmaChecklineHost", "datetime()" )
			This.nIndiceTimerAlarmaChecklineHost = lnIndiceDisponible
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function InicializarTimerTecnoVoz() As Void
		Local lnIndiceDisponible As Integer
		This.MilisegundosTimerVerificarArchivoTecnoVoz = goParametros.zl.TecnoVoz.SegundosTimerVerificarArchivoTecnoVoz * 1000
		If This.MilisegundosTimerVerificarArchivoTecnoVoz > 0 And This.lEstoyUsandoTimers
			lnIndiceDisponible = goTimer.CrearNuevoTimer( This.MilisegundosTimerVerificarArchivoTecnoVoz, "_screen.zoo.app", "AbrirIncidenteAutomaticamenteArchrivoTecnoVoz" )
			This.nIndiceTimerVerificarArchivoTecnoVoz = lnIndiceDisponible
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AbrirIncidenteAutomaticamenteArchrivoTecnoVoz() As Void
		local loAccion as Collection, lnOportunidad as Number, lcAccion as String, loEntidad as Object   
		loAccion = newobject( "Collection" )
		If This.VerificarCambiosArchivoTecnoVoz() And This.DebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz()
			Do Case
				Case  "INCIDENTE" $ Upper( goParametros.zl.TecnoVoz.IndicadorAbreIncidenteAutomaticamente )
					loAccion.Add('NUEVO')
					goServicios.Ejecucion.MostrarenNuevoHilo( "MDAINCMDA" , loAccion )

				Case  "OPORTUNIDAD"	$ Upper( goParametros.zl.TecnoVoz.IndicadorAbreIncidenteAutomaticamente )
					lnOportunidad = This.ObtenerOportunidadComercialAPartirDeTecnovoz()
					loEntidad = _Screen.zoo.Instanciarentidad( "OPORTUNIDADSLR" )
					lcAccion = "BUSCAR:" + loEntidad.obteneratributoclaveprimaria() + "=" +transform( lnOportunidad )
					loAccion.Add( lcAccion ) 
					loAccion.Add( 'MODIFICAR' ) 
					goServicios.Ejecucion.MostrarenNuevoHilo( "OPORTUNIDADSLR" , loAccion )

			Endcase
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function VerificarCambiosArchivoTecnoVoz() As Boolean
		Return This.oTecnoVoz.VerificarCambiosArchivoTecnoVoz()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function DebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz() As Boolean
		Return This.oTecnoVoz.DebeAbrirIncidenteAutomaticamenteArchrivoTecnoVoz()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ChequeoAlarmaChecklineHost( tdFecha As Datetime ) As Void
		Local lnSegundosDiferenciaCheckline As numeric, lnSegundosDiferenciaHost As numeric

		This.nCantMinutosAlarma = This.nCantMinutosAlarma + 1

		If ( This.nCantMinutosAlarma >= goParametros.zl.MinutosControlChecklineHost )
			This.nCantMinutosAlarma = 0
			lnSegundosDiferenciaCheckline = tdFecha - Ctot( goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline )
			lnSegundosDiferenciaHost = tdFecha - Ctot( goRegistry.zl.Host.FechaHoraUltimoChequeoHost )

			If ( lnSegundosDiferenciaCheckline > goParametros.zl.MinutosToleranciaDelControlChecklineHost * 60 ;
					or Empty( goRegistry.zl.checkline.FechaHoraUltimoChequeoCheckline )) And goParametros.zl.checkline.ACTIVARVERIFICACIONCHECKLINE
				goMensajes.advertir( "ATENCIÓN: No se encuentra operativa la consola de checkline. Por favor comuníquese con Infraestructura." )
			Endif
			If (lnSegundosDiferenciaHost > goParametros.zl.MinutosToleranciaDelControlChecklineHost * 60 ;
					or Empty( goRegistry.zl.Host.FechaHoraUltimoChequeoHost )) And goParametros.zl.robothost.ACTIVARVERIFICACIONHOST
				goMensajes.advertir( "ATENCIÓN: No se encuentra operativo el robot del host. Por favor comuníquese con Infraestructura." )
			Endif
		Endif

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerValorSugeridoReferencia() As String
		Return This.oTecnoVoz.ObtenerValorSugeridoReferencia()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function DetenerTimerAlarmaChecklineHost() As Void
		If This.nIndiceTimerAlarmaChecklineHost # 0
			StopTimer( This.nIndiceTimerAlarmaChecklineHost )
		Endif
		This.nIndiceTimerAlarmaChecklineHost = 0
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function DetenerTimerTecnoVoz() As Void
		If This.nIndiceTimerVerificarArchivoTecnoVoz # 0
			StopTimer( This.nIndiceTimerVerificarArchivoTecnoVoz )
		Endif
		This.nIndiceTimerVerificarArchivoTecnoVoz = 0
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValHK() As Boolean
		Local llRetorno As Boolean, lnP1 As Integer, lnP2 As Integer, lnP3 As Integer, ;
			lnlnP4 As Integer, lcBuffer As String, lnRetCode As Integer, lnHandle As Integer, ;
			lcData As String, lcUsuario As String, lcDeclare As String, lnLp1 As Integer, ;
			lnLp2 As Integer, lnService

		Declare Integer NetRockey In NRCLIENT.Dll Integer lnservice, Integer @ lnhandle, Long @ lnlp1, ;
			long @ lnlp2, Integer @ lnp1, Integer @ lnp2, Integer @ lnp3, Integer @ lnp4, String @ lcbuffer

		lnP1 = Val( goLibrerias.desencriptar192( "11CA2BB00F47A7463CD72328B84466A8" ) )
		lnP2 = Val( goLibrerias.desencriptar192( "F04812A68A73F0A10465BB8D234C545C" ) )
		lnP3 = 0
		lnp4 = 0
		lnLp1 = 0
		lnLp2 = 0
		lnRetCode = 0
		lnHandle = 0
		lcBuffer = Space(1024)
		lcData = ""
		lcUsuario = ""
		llRetorno = .F.

		lnRetCode = NetRockey(RY_FIND, @lnHandle, @lnLp1, @lnLp2, @lnP1, @lnP2, @lnP3, @lnp4, @lcBuffer)
		If lnRetCode = ERR_SUCCESS
			lnRetCode = NetRockey(RY_OPEN, @lnHandle, @lnLp1, @lnLp2, @lnP1, @lnP2, @lnP3, @lnp4, @lcBuffer)
			If lnRetCode = ERR_SUCCESS
				lnLp1 = 0
				lnRetCode = NetRockey(RY_READ_USERID, @lnHandle, @lnLp1, @lnLp2, @lnP1, @lnP2, @lnP3, @lnp4, @lcBuffer)
				If ( lnRetCode = ERR_SUCCESS Or lnRetCode > 100  )
					If This.ValidarUsuario( lnLp1 )
						lnP1 = 0
						lnP2 = 96
						lcBuffer = Space(100)
						lnRetCode = NetRockey(RY_READ, @lnHandle, @lnLp1, @lnLp2, @lnP1, @lnP2, @lnP3, @lnp4, @lcBuffer)
						If lnRetCode = ERR_SUCCESS
							If This.ValidarData( lcBuffer )
								llRetorno = .T.
							Endif
						Endif
					Endif
				Endif
			Endif
			lnRetCode = NetRockey(RY_CLOSE, @lnHandle, @lnLp1, @lnLp2, @lnP1, @lnP2, @lnP3, @lnp4, @lcBuffer)
		Endif

		If lnRetCode != ERR_SUCCESS
			This.AnalizarError( lnRetCode )
		Endif

		Clear Dlls
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ValidarUsuario( tnLectura ) As Boolean
		Local a,b,c,d,e,F,g

		a = "1"
		b = "4"
		c = "3"
		d = "8"
		e = "8"
		F = "7"
		g = "3"
		h = "2"

		Return Alltrim( Transform( tnLectura ) ) == a+b+c+d+e+F+g+h
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ValidarData( tnLectura ) As Boolean
		Local zl10, zl20, zl30, zl40, zl50, zl60, zl70, zl80, zl90, zl10,  ;
			zl11, zl12, zl13, zl14, zl15, zl16, zl17, zl18, zl19, zl20,  ;
			zl21, zl22, zl23, zl24, zl25, zl26, zl27, zl28, zl29, zl30,  ;
			zl31, zl32, zl33, zl34, zl35, zl36, zl37, zl38, zl39, zl40

		zl01 = '5'
		zl02 = 'B'
		zl03 = 'E'
		zl04 = 'D'
		zl05 = '5'
		zl06 = '5'
		zl07 = '6'
		zl08 = '7'
		zl09 = '3'
		zl10 = 'A'
		zl11 = 'B'
		zl12 = 'B'
		zl13 = '1'
		zl14 = 'A'
		zl15 = 'A'
		zl16 = '7'
		zl17 = 'D'
		zl18 = '6'
		zl19 = 'C'
		zl20 = '7'
		zl21 = 'E'
		zl22 = 'A'
		zl23 = 'E'
		zl24 = '4'
		zl25 = '3'
		zl26 = '7'
		zl27 = '9'
		zl28 = 'E'
		zl29 = 'B'
		zl30 = '6'
		zl31 = '9'
		zl32 = '6'
		zl33 = 'A'
		zl34 = '5'
		zl35 = '8'
		zl36 = '4'
		zl37 = '9'
		zl38 = 'F'
		zl39 = '6'
		zl40 = 'D'

		Return goLibrerias.desencriptar192( Alltrim( Transform( tnLectura ) ) ) == ;
			zl01 + zl02 + zl03 + zl04 + zl05 + zl06 + zl07 + zl08 + zl09 + zl10 +  ;
			zl11 + zl12 + zl13 + zl14 + zl15 + zl16 + zl17 + zl18 + zl19 + zl20 +  ;
			zl21 + zl22 + zl23 + zl24 + zl25 + zl26 + zl27 + zl28 + zl29 + zl30 +  ;
			zl31 + zl32 + zl33 + zl34 + zl35 + zl36 + zl37 + zl38 + zl39 + zl40
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function AnalizarError( tnError As Integer ) As Void
		Local lcMensaje
		Do Case
			Case tnError = ERR_NO_PARALLEL_PORT
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"7702F144FD7209176D76283111CE29C218EE0DB7FD1595162D63BD31A6145468" ) )
			Case tnError = ERR_NO_DRIVER
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"6D0ACBC3A1D66444F581DD1EEFDD8337A707F6F1D7788D3F03454A626D1D5850" ) )
			Case tnError = ERR_NO_ROCKEY
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"724A9AAE0B917B6ECFDF7492D7079CD656F97647D90BDE8E80DCB69BEF2DEF96" ) )
			Case tnError = ERR_INVALID_PASSWORD
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"85066895D2450229272D7AA60A5D7A175A1A6D8CA0FA430E0249C3A995758800" + ;
					"0BA556A0537DC318F055A967007CE8247D4F42B14AF5BB90D95D13601D381920" ) )
			Case tnError = ERR_INVALID_PASSWORD_OR_ID
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"D11187290862DC8A975515219B0C19DFAE41307847CE672B77E150344662C344" ) )
			Case tnError = ERR_SETID
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( "A8A01747A9B5A1194B43A466A1525DA9" ) )
			Case tnError = ERR_INVALID_ADDR_OR_SIZE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"09715FBB7CCCF8B9A5EFB04DC47F1AC68963E259C388E9FE488F3C090CE82D50" + ;
					"C25B7BC20E1638618E667C513532DBE8" ) )
			Case tnError = ERR_UNKNOWN_COMMAND
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"095B68E5F2B6941725023BB1CAB649A166873CBBE520B7D58DD1A4C059F525F0" ) )
			Case tnError = ERR_NOTBELEVEL3
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"F2744508AF004D03ED7306AA3F887D3E" ) )
			Case tnError = ERR_READ
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"B5F9881667AF35992232BBE722DFAB58B6F6DEE34A157816EC8E421E09E45BDA" ) )
			Case tnError = ERR_WRITE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"C4914A1F5061B258EBD9A93B3FF825584B9A7B5B19B68E910E57088C8B9F1085" ) )
			Case tnError = ERR_RANDOM
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"B92249C1ABC1F2C4CDA0C2B9873D569E14F5CDE42A53FB155D5EA020563CF032" + ;
					"F87339324BB556D7E56ED4FC6DD95871" ) )
			Case tnError = ERR_SEED
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"D2214BD78054731A90BEB8777CF2907A6F80CABA13594594013AE7A611CF8A74" + ;
					"12B3AF7A0B9A50D871761B9DFBBB1545BB2C4A7F6DDC853EE2FD06E44056FBB1" ) )
			Case tnError = ERR_CALCULATE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"0721027A46F9144346E877942A34C5B320867DAC3CA80A33F8931EC40E6E56DB" ) )
			Case tnError = ERR_NO_OPEN
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"CD59DF7622CAAF0E1FBFB0620C362D420C79771859A7E9F7AE7B5C6B88137679" + ;
					"696C1869CF409AF11B2C627375A56AFD4F95E4596300CA2BAC0B06DD8FE65BA6" ) )
			Case tnError = ERR_OPEN_OVERFLOW
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"62FD9ECDDB35ED981A43BD260C46DFDEDB1B81E48C252E0B84174FE51A967128" + ;
					"01BC0050DC8046F4262D4869F39C08E6" ) )
			Case tnError = ERR_NOMORE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"53D55496878F0BB200ED66DBEEBAC8B6C363E742D42083BF08AF03676A92F8C7" + ;
					"5CF0A78C42505EBE4223C53F6AC8CB9B" ) )
			Case tnError = ERR_NEED_FIND
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"EB73DC2A101AA05166C5DAF716845038F9C6A2359E6820F1284CA4E7012999A1" + ;
					"9CEAB1A79854F0AF03DE202F5EB80B13F032F9F14E032AF7B7D5469C199915B6" ) )
			Case tnError = ERR_DECREASE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"603E1F1F47003244154D1FAF5D2E50655C9FCC5B8A37A43E154DD817FBB208E9" ) )
			Case tnError = ERR_AR_BADCOMMAND
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"A007BE8D9C3EAB9E5544F09466F065DF58D31695732B9DD5C49C2C0920B1BB56" ) )
			Case tnError = ERR_AR_UNKNOWN_OPCODE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"C06988CB3B5257DEBDCC0AF5D03CDF06071D39DDF021C698756BA7EDA0A4F173" ) )
			Case tnError = ERR_AR_WRONGBEGIN
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"51AC7400AA0F6CC0B302A590FD767A2551466E068F3CCBAA02B6D3D645E69D57" + ;
					"4D939B981F6F7EE0E0A661540D145569403A0F5A81C38792E904569F7BE7DF18" ) )
			Case tnError = ERR_AR_WRONG_END
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"51AC7400AA0F6CC0B302A590FD767A2551466E068F3CCBAA02B6D3D645E69D57" + ;
					"73EB870D92B04E82642AEA8057686DDCC8C21B37551396269078B9F01111DE74" ) )
			Case tnError = ERR_NET_LOGINAGAIN
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"99AC4B0A4E2D7FD19215BF3B0A242615CBB7C16E250F8A4138A3A66DF37CDD0F" + ;
					"D1D0F9065498BD04CF6D2212BB3BE342303A0BA51FE53976B0A8D89233C9B84D" ) )
			Case tnError = ERR_NET_NETERROR
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"26E7F544EC5FF99432DD1CF34C40C490" ) )
			Case tnError = ERR_NET_LOGIN
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"BE679E2B2F23D900E4A17ACCEF7D24B3D9B5E1BFA15283A503217170AAD16A0A" ) )
			Case tnError = ERR_NET_INVALIDHANDLE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"A30B2CD91E220DD0758638C309B24809EE8646AE9BF91E812FA6DD8E5EF3C57A" + ;
					"83C1DDFB2FA1F5B5DF51CB8EBF620CD09F8B9D7775B039A8D69AC96EB51AD16A" ) )
			Case tnError = ERR_NET_BADARDWARE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"0DB1A45372E97043A8CEB21E125253866567F60F2F06176E3B6AF88E4376887B" ) )
			Case tnError = ERR_NET_REFUSE
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"F5176E8EFD404791F5BD901D050C2A43E9CC0CE4ADB9044D17E53C7D4595C66E" + ;
					"7294CF216B84FA228F609E104F803E6769567C48FABFC475FE0DB520E86BE3E5" + ;
					"DA38256F1BF1829A5F9B165C178232DA" ) )
			Case tnError = ERR_NET_BADSERVER
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"45DE01FD726FED556B6F08545A58B6AE15B0FA62A220469430524168AEFA8E60" + ;
					"8CA03CBF485061E9A736EF73C3A9125C54FF1C4B3FFDE85695A3B269EAF5EDE9" ) )
			Otherwise
				lcMensaje = goLibrerias.encriptar192( goLibrerias.desencriptar192( ;
					"E168673F88649D181E078B56391A7EEAE44C2A3918D2B8D0826965F42B8EB1DD" ;
					) + Transform( tnError ) + goLibrerias.desencriptar192( ;
					"69A9F59AB9D2A94C4E6AE8F27B9781B2" )  )
		Endcase
		This.Loguear( lcMensaje )
		This.FinalizarLogueo()
		goLibrerias.ConstTextoAndGo( goLibrerias.desencriptar192( "C216B76B34D929EE6E07B1FF97DF6A5B" ), .F., .T. )
	Endfunc

	*------------------------------------------
	Function RutaNombreTxtTecnoVoz() As String
		Return This.oTecnoVoz.ObtenerRutaArchivoTecnoVoz()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerRutaZooLogic() As Void
		Local lcRetorno As String, lnRetorno As Integer

		lcRetorno = ""
		lnRetorno = 0
		lnRetorno = goLibrerias.OINI.getIniEntry( @lcRetorno, "ZOOLOGIC", "RutaVistas", _Screen.zoo.App.aarchivosini[2] )

		If lnRetorno = 0
			This.cRutaZooLogic = lcRetorno
		Endif

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerRutaLince() As Void
		Local lcRetorno As String, lnRetorno As Integer

		lcRetorno = ""
		lnRetorno = 0
		lnRetorno = goLibrerias.OINI.getIniEntry( @lcRetorno, "LINCE", "RutaLince", _Screen.zoo.App.aarchivosini[2] )

		If lnRetorno = 0
			This.cRutaLince = lcRetorno
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerRutaLincePro() As Void
		Local lcRetorno As String, lnRetorno As Integer

		lcRetorno = ""
		lnRetorno = 0
		lnRetorno = goLibrerias.OINI.getIniEntry( @lcRetorno, "LINCE", "RutaLincePro", _Screen.zoo.App.aarchivosini[2] )

		If lnRetorno = 0
			This.cRutaLincePro = lcRetorno
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerValorSugeridoTecnoVoz() As String
		Return This.oTecnoVoz.ObtenerValorSugeridoTecnoVoz()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SincronizarHistorias() As Void
		goMensajes.enviarsinespera( "Sincronizando historias" )
		goServicios.Datos.EjecutarSentencias( "zl.PivotalActivityCLR 0,0,0", "" )
		goMensajes.enviarsinespera( .F. )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SincronizarProyectos() As Void
		goMensajes.enviarsinespera( "Sincronizando proyectos" )
		goServicios.Datos.EjecutarSentencias( "zl.SyncProjectsCLR", "" )
		goMensajes.enviarsinespera( .F. )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function oTecnoVoz_Access() As variant
		If !This.ldestroy And ( Vartype( This.oTecnoVoz ) != 'O' Or Isnull( This.oTecnoVoz ) )
			This.oTecnoVoz = _Screen.zoo.crearobjeto( 'ManagerTecnoVoz' )
		Endif
		Return This.oTecnoVoz
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerRazonSocialDeTecnoVoz() As String
		Return This.oTecnoVoz.ObtenerRazonSocialDeTecnoVoz()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerMotivoAperturaAutomaticaDeIncidente() As String
		Return This.oTecnoVoz.ObtenerMotivoAperturaAutomaticaDeIncidente()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerOportunidadComercialAPartirDeTecnovoz() As Number
		local lOportunidad as Number, lcMotivo as String 
		lcMotivo 	 = strtran( alltrim( This.oTecnoVoz.ObtenerMotivoAperturaAutomaticaDeIncidente() ), " ", "," ) 
		lOportunidad = val( left( lcMotivo, at( ",", lcMotivo ) -1 ) )
		Return lOportunidad  
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EjecutarMigradorDeParametros() As Void
		&& No aplica la migracion de parámetros en ZL
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerClaseLogin() As String
		Return "Kontrolerzl_Login"
	Endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarReferencias() as Void
		dodefault()
		this.AgregarReferencia( "ZooLogicSA.OrganicServiciosREST.Zl.dll" )
		this.AgregarReferencia( "ZooLogicSA.OrganicServiciosREST.Zl.Generados.dll" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarServicioREST() as Void
		goServicios.Mensajes.EnviarSinEspera( "Iniciando servicio REST..." )
		local loEntidad as Object
		loEntidad = _Screen.Zoo.InstanciarEntidad( "SERVICIOREST" )
		loEntidad.Codigo = "REST"
		loEntidad.IniciarServicio()
		goServicios.Mensajes.EnviarSinEspera( .F. )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ResetearSerieApp( tcSerie as string, tcClave as string, tcSitio as string ) as Void
		this.SetearDatosDelMotor()
		if this.lEsLocalDB
			_Screen.Zoo.App.lF2 = .t.
			this.lSeccion9 = .t.
		else
			dodefault( tcSerie, tcClave, tcSitio )
		endif
	endfunc

Enddefine
