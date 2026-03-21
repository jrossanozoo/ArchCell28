Define Class DatosMaquina As Session

	*!* Windows Sockets
	#Define WS_VERSION_REQD        257
	#Define WS_VERSION_MAJOR    1
	#Define WS_VERSION_MINOR    1
	#Define MIN_SOCKETS_REQD    1
	#Define SOCKET_ERROR        -1
	#Define WSADESCRIPTION_LEN     256
	#Define WSASYS_STATUS_LEN     128

	*!* Windows NetBIOS
	#Define NCBENUM                     55
	#Define NCBASTAT                    51
	#Define NCBNAMSZ                    16
	#Define HEAP_ZERO_MEMORY            8
	#Define HEAP_GENERATE_EXCEPTIONS    4
	#Define NCBRESET                    50

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		
		*!* Instrucciones DECLARE DLL para obtener un GUID
		Declare Integer CoCreateGuid In Ole32.Dll String @lpGuid
	endfunc 


	*!* Devuelve las direcciones MAC
	*!* Sintaxis: MACAddress()
	*!* Valor devuelto: lcRetVal
	*!* lcRetVal viene expresado como una cadena con el formato: 00-04-76-A4-73-3A, 00-04-76-A4-72-13, ...
	Function MACAddress
		Local lcNBC, lcAdapter, lnAdapter, lcSource, lnSource, lcRetVal, lnLength, lnLEnum, lcLEnum
		*!* Instrucciones DECLARE DLL para manipular NetBIOS
		Declare Integer GetProcessHeap In Win32API
		Declare Integer Netbios In Netapi32.Dll String @lpNBC
		Declare Integer HeapFree In Win32API Integer hHeap, Integer dwFlags, String @lpMem
		Declare Integer HeapAlloc In Win32API Integer hHeap, Integer dwFlags, Integer dwBytes
		Declare Integer RtlMoveMemory In Win32API String @lpDestination, Integer nSource, Integer nBytes
		*!* Valores
		lcRetVal  = ''
		lcNBC     = Replicate(Chr(0), 64)
		lcLEnum   = Replicate(Chr(0), 256)
		lcAdapter = Replicate(Chr(0), 600)
		*!* Reservar buffer memoria
		lnLEnum = HeapAlloc(GetProcessHeap(), Bitor(HEAP_GENERATE_EXCEPTIONS, HEAP_ZERO_MEMORY), 256)
		If lnLEnum <> 0
			*!* Valores
			lcNBC = Chr(NCBENUM) + Replicate(Chr(0), 3) + this.LongToStr(lnLEnum) + ;
				this.IntToStr(256) + Substr(lcNBC, 11, 544)
			*!* Enum LANŽs
			If Netbios(@lcNBC) = 0
				*!* Leer buffer memoria
				lnSource = lnLEnum
				RtlMoveMemory(@lcLEnum, lnSource, 256)
				*!* Valores
				lnLength = Asc(Substr(lcLEnum, 1, 1))
				*!* Examinar LAN`s
				For lnCnt = 1 To lnLength
					*!* Valores
					lcAdapter = Replicate(Chr(0), 600)
					lcNBC     = Chr(NCBRESET) + Replicate(Chr(0), 47) +  ;
						SUBSTR(lcLEnum, lnCnt+1, 1) + Replicate(Chr(0), 15)
					*!* Reset LAN
					If Netbios(@lcNBC) = 0
						*!* Reservar buffer memoria
						lnAdapter = HeapAlloc(GetProcessHeap(), ;
							BITOR(HEAP_GENERATE_EXCEPTIONS, HEAP_ZERO_MEMORY), 600)
						If lnAdapter <> 0
							*!* Valores
							lcNBC = Chr(NCBASTAT) + Replicate(Chr(0), 3) + this.LongToStr(lnAdapter) + ;
								this.IntToStr(600) + '*               ' + Replicate(Chr(0), 22) + ;
								SUBSTR(lcLEnum, lnCnt+1, 1) + Replicate(Chr(0), 15)
							*!* Status LAN
							If Netbios(@lcNBC)  = 0
								*!* Leer buffer memoria
								lnSource = lnAdapter

								RtlMoveMemory(@lcAdapter, lnSource, 600)
								
								*!* Componer cadena MAC con guiones y separar multiples MAC`s con comas
								with this
									lcRetVal = lcRetVal + Right(.DecToHex(Asc(Substr(lcAdapter, 1, 1))), 2) + ;
										'-' + Right(.DecToHex(Asc(Substr(lcAdapter, 2, 1))), 2) + ;
										'-' + Right(.DecToHex(Asc(Substr(lcAdapter, 3, 1))), 2) + ;
										'-' + Right(.DecToHex(Asc(Substr(lcAdapter, 4, 1))), 2) + ;
										'-' + Right(.DecToHex(Asc(Substr(lcAdapter, 5, 1))), 2) + ;
										'-' + Right(.DecToHex(Asc(Substr(lcAdapter, 6, 1))), 2) + ;
										IIF(lnCnt = lnLength, '', ',')
								endwith
							Endif
							*!* Liberar buffer memoria
							lcSource = this.LongToStr(lnAdapter)

							*** Si se instancia como DLL da error
							if _VFP.StartMode != 5 
								HeapFree(GetProcessHeap(), 0, @lcSource)
							endif
						Endif
					Endif
				Endfor
			Endif
			*!* Liberar buffer memoria
			lcSource = this.LongToStr(lnLEnum)

			*** Si se instancia como DLL da error
			if _VFP.StartMode != 5 
				HeapFree(GetProcessHeap(), 0, @lcSource)
			endif
		Endif
		*!* Retorno
		Return lcRetVal
	Endfunc

	*!* Devuelve las direcciones IP
	*!* Sintaxis: IPAddress()
	*!* Valor devuelto: lcRetVal
	*!* lcRetVal viene expresado como una cadena con el formato: 192.100.100.100, 192.100.100.101, ...
	Function IPAddress
		Local lnCnt, lpWSAData, lpWSHostEnt, lpHostName, lcRetVal, lpHostIp_Addr, ;
			lpHostEnt_Addr, lnHostEnt_Lenght, lnHostEnt_AddrList
		*!* Instrucciones DECLARE DLL para manipular Windows Sockets
		Declare Integer WSAGetLastError In WSock32.Dll
		Declare Integer WSAStartup In WSock32.Dll Integer wVersionRequested , String @lpWSAData
		Declare Integer WSACleanup In WSock32.Dll
		Declare Integer gethostname In WSock32.Dll String @lpHostName, Integer iHostNameLenght
		Declare Integer gethostbyname In WSock32.Dll String lpHostName
		Declare RtlMoveMemory In Win32API String @lpDest, Integer nSource, Integer nBytes
		*!* Valores
		lcRetVal           = ''
		lpHostName         = Space(256)
		lnHostEnt_Addr     = 0
		lnHostEnt_Lenght   = 0
		lnHostEnt_AddrList = 0
		lnHostIp_Addr      = 0
		lpTempIp_Addr      = Chr(0)
		lpHostIp_Addr      = Replicate(Chr(0), 4)
		lpWSHostEnt        = Replicate(Chr(0), 4 +4 +2 +2 +4)
		lpWSAData          = Replicate(Chr(0), 2 +2 + ;
			WSADESCRIPTION_LEN +1 +WSASYS_STATUS_LEN +1 +2 +2 +4)
		*!* Iniciar Windows Sockets
		If WSAStartup(WS_VERSION_REQD, @lpWSAData) =  0
			*!* Valores
			lnVersion    = this.StrToInt(Substr(lpWSAData, 1, 2))
			lnMaxSockets = this.StrToInt(Substr(lpWSAData, 391, 2))
			*!* Determinar si Windows Sockets responde
			If gethostname(@lpHostName, 256) <> SOCKET_ERROR
				*!* Valores
				lpHostName = Alltrim(lpHostName)
				lnHostEnt_Addr = gethostbyname(lpHostName)
				*!* Determinar si Windows Sockets no dio error
				If lnHostEnt_Addr <> 0
					*!* Mover bloques de memoria
					RtlMoveMemory(@lpWSHostEnt, lnHostEnt_Addr, 16)
					*!* Valores
					lnHostEnt_AddrList = this.StrToLong(Substr(lpWSHostEnt, 13, 4))
					lnHostEnt_Lenght   = this.StrToInt(Substr(lpWSHostEnt, 11, 2))
					*!* Obtener todas las direcciones IP de la máquina
					Do While .T.
						*!* Mover bloques de memoria
						RtlMoveMemory(@lpHostIp_Addr, lnHostEnt_AddrList, 4)
						*!* Valores
						lnHostIp_Addr = this.StrToLong(lpHostIp_Addr)
						*!* No hay o no quedan más direcciones validas
						If lnHostIp_Addr = 0
							Exit
						Else
							*!* Separar multiples IP`s con comas
							lcRetVal = lcRetVal + Iif(Empty(lcRetVal), '', ',')
						Endif
						lpTempIp_Addr = Replicate(Chr(0), lnHostEnt_Lenght)
						*!* Mover bloques de memoria
						RtlMoveMemory(@lpTempIp_Addr, lnHostIp_Addr, lnHostEnt_Lenght)
						*!* Componer cadena IP con puntos
						For lnCnt = 1 To lnHostEnt_Lenght
							lcRetVal = lcRetVal + Transform(Asc(Substr(lpTempIp_Addr, lnCnt, 1))) + ;
								IIF(lnCnt = lnHostEnt_Lenght, '', '.')
						Endfor
						*!* Continuar con la siguiente direccion
						lnHostEnt_AddrList = lnHostEnt_AddrList + 4
					Enddo
				Endif
			Endif
		Endif
		*!* Parar Windows Sockets
		If WSACleanup() <> 0
			lcRetVal = ''
		Endif
		*!* Retorno
		Return lcRetVal
	Endfunc

	*!* Obtiene un GUID en formato 1nnnnnnnn1nnnn1nnnn1nnnn1nnnnnnnnnnnn1
	*!* Sintaxis: GetGuid()
	*!* Valor devuelto: lcGuid
	Function GetGuid
		Local lnCnt, lcGuid, lcData1, lcData2, lcData3, lcData4, lcData5
		
		*!* Valores
		lnCnt   = 0
		lcGuid  = ''
		lcData1 = ''
		lcData2 = ''
		lcData3 = ''
		lcData4 = ''
		lcData5 = ''
		lpGuid  = Replicate(Chr(0), 17)
		*!* Obtener el GUID
		If CoCreateGuid(@lpGuid) = 0
			*!* Valores
			with this
				lcData1 = Right(Transform(.StrToLong(Left(lpGuid, 4)), '@0'), 8)           && Los 8 primeros digitos
				lcData2 = Right(Transform(.StrToLong(Substr(lpGuid, 5, 2)), '@0'), 4)      && Los 4 segundos digitos
				lcData3 = Right(Transform(.StrToLong(Substr(lpGuid, 7, 2)), '@0'), 4)      && Los 4 terceros digitos
				lcData4 = Right(Transform(.StrToLong(Substr(lpGuid, 9, 1)), '@0'), 2) + ;
					RIGHT(Transform(.StrToLong(Substr(lpGuid, 10, 1)), '@0'), 2)              && Los 4 cuartos digitos
				lcData5 = ''
			endwith 
			*!* Los 12 digitos finales
			For lnCnt = 1 To 6
				lcData5 = lcData5 + Right(Transform(this.StrToLong(Substr(lpGuid, 10 + lnCnt, 1))), 2)
			Endfor
			*!* Verifica la longitud de los 12 digitos finales. Si son menores de 12 es que el resto son 0
			If Len(lcData5) < 12
				lcData5 = lcData5 + Replicate('0', 12 - Len(lcData5))
			Endif
			*!* Valores
			lcGuid = '1' + lcData1 + '1' + lcData2 + '1' + lcData3 + '1' + lcData4 + '1' + lcData5 + '1'
		Endif
		*!* Retorno
		Return lcGuid
	Endfunc

	********************************************************************************
	** Libreria de funciones de conversion de tipo                                **
	********************************************************************************

	*!* Convierte un long integer a un 4-byte character string
	*!* Sintaxis: LongToStr(tnLongVal)
	*!* Valor devuelto: lcRetStr
	*!* Argumentos: tnLongVal
	*!* lnLongVal especifica el long integer a convertir
	hidden Function LongToStr
		Lparameters tnLongVal
		Local lnCnt, lcRetStr, lnLongVal
		*!* Valores
		lcRetStr  = ''
		lnLongVal = Iif(Empty(tnLongVal), 0, tnLongVal)
		*!* Convertir
		For lnCnt = 24 To 0 Step -8
			lcRetStr  = Chr(Int(lnLongVal/(2^lnCnt))) + lcRetStr
			lnLongVal = Mod(lnLongVal, (2^lnCnt))
		Next
		*!* Retorno
		Return lcRetStr
	Endfunc

	*!* Convierte un 4-byte character string a un long integer
	*!* Sintaxis: StrToLong(tcLongStr)
	*!* Valor devuelto: lnRetval
	*!* Argumentos: tcLongStr
	*!* tcLongStr especifica el 4-byte character string a convertir
	hidden Function StrToLong
		Lparameters tcLongStr
		Local lnCnt, lnRetVal, lcLongStr
		*!* Valores
		lnRetVal  = 0
		lcLongStr = Iif(Empty(tcLongStr), '', tcLongStr)
		*!* Convertir
		For lnCnt = 0 To 24 Step 8
			lnRetVal  = lnRetVal + (Asc(lcLongStr) * (2^lnCnt))
			lcLongStr = Right(lcLongStr, Len(lcLongStr) - 1)
		Next
		*!* Retorno
		Return lnRetVal
	Endfunc

	*!* Convierte un integer a un 2-byte character string
	*!* Sintaxis: IntToStr(tnIntVal)
	*!* Valor devuelto: lcRetStr
	*!* Argumentos: tnIntVal
	*!* lnIntVal especifica el integer a convertir
	hidden Function IntToStr
		Lparameters tnIntVal
		Local lnCnt, lcRetStr, lnIntVal
		*!* Valores
		lcRetStr = ''
		lnIntVal = Iif(Empty(tnIntVal), 0, tnIntVal)
		*!* Convertir
		For lnCnt = 8 To 0 Step -8
			lcRetStr = Chr(Int(lnIntVal/(2^lnCnt))) + lcRetStr
			lnIntVal = Mod(lnIntVal, (2^lnCnt))
		Next
		*!* Retorno
		Return lcRetStr
	Endfunc

	*!* Convierte un 2-byte character string a un integer
	*!* Sintaxis: StrToInt(tcIntStr)
	*!* Valor devuelto: lnRetval
	*!* Argumentos: tcIntStr
	*!* tcIntStr especifica el 2-byte character string a convertir
	hidden Function StrToInt
		Lparameters tcIntStr
		Local lnCnt, lnRetVal, lcIntStr
		*!* Valores
		lnRetVal = 0
		lcIntStr = Iif(Empty(tcIntStr), '', tcIntStr)
		*!* Convertir
		For lnCnt = 0 To 8 Step 8
			lnRetVal = lnRetVal + (Asc(lcIntStr) * (2^lnCnt))
			lcIntStr = Right(lcIntStr, Len(lcIntStr) - 1)
		Next
		*!* Retorno
		Return lnRetVal
	Endfunc


	*!* Convierte un numero decimal a una hex character string
	*!* Sintaxis: DecToHex(tnDecNumber)
	*!* Valor devuelto: lcHexNumber
	*!* Argumentos: tnDecNumber
	*!* tnDecNumber especifica el numero decimal a convertir
	hidden Function DecToHex
		Lparameters tnDecNumber
		Local lnLength, lnTempHex, lcHexNumber, lnDecNumber
		*!* Valores
		lcHexNumber = ''
		lnDecNumber = Iif(Empty(tnDecNumber), 0, tnDecNumber)
		*!* Convertir
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
		*!* Retorno
		Return lcHexNumber
	Endfunc


Enddefine
