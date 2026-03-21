define class sms as zooSession of zoosession.prg

	nLongitud = 0
	oCOM = null

	*-----------------------------------------------------------------------------------------
	function init()
		this.oCOM = createobject("MSCOMMLib.MSComm")
	endfunc

	*-----------------------------------------------------------------------------------------
	function destroy()
		this.oCOM = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarMensaje( tcNumero as string, tcMensaje as string, tnPuerto as integer ) as boolean
		local llRetorno as Boolean, lcCadena as string, lnPuerto as Integer
		store "" to lcCadena

		lnPuerto = iif( empty( tnPuerto ), 15, tnPuerto )

		with this
			if .PuertoValido( lnPuerto ) and .AbrirPuerto()
				lcCadena = .ObtenerCadena( tcNumero, tcMensaje )
				.EnviarComando( "ATZ" + chr(13) )
				.EnviarComando( "AT+CMGF=0" + chr(13) )
				.EnviarComando( "AT+CSMS=0" + chr(13) )
				.EnviarComando( [AT+CPMS="ME","ME"] + chr(13) )
				.EnviarComando( "AT+CMGS=" + alltrim( str( this.nLongitud ) ) + chr(13) )
				.EnviarComando( lcCadena + chr(26)+ chr(13) )
				.CerrarPuerto()
				llRetorno = .t.
			endif
		endwith

		return llRetorno
	endfunc


	*-----------------------------------------------------------------------------------------
	hidden function ObtenerCadena( tcNumero, tcTexto ) as string
		local lcPrefijo as string, lcNumero as string, lcTexto as string, lcRetorno as string, lcCantidadCaracteres as string

		lcPrefijo = "0011000A81"
		lcNumero = this.ObtenerNumero( tcNumero )
		lcTexto = this.TextoaSMS( tcTexto )
		lcCantidadCaracteres = upper( padl( this.Dec2BasX( len( tcTexto ), 16 ), 2, "0" ) )
		lcRetorno = lcPrefijo + lcNumero + "0000FF" + lcCantidadCaracteres + lcTexto

		this.nLongitud = int( len( lcRetorno ) / 2 ) - 1

		return lcRetorno
	endfunc


	*-----------------------------------------------------------------------------------------
	hidden function ObtenerNumero( tcNumero as string ) as string
		local lcRetorno as string, i as integer
		store "" to lcRetorno

		for i = 1 to 9 step 2
			lcRetorno = lcRetorno + this.InvertirCadena( substr( tcNumero, i, 2 ) )
		endfor

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function InvertirCadena( tcString ) as string
		local lcRetorno as string, i as integer, lnCaracteres as Integer
		store "" to lcRetorno

		lnCaracteres = len( tcString )
		for i = lnCaracteres to 1 step - 1
			lcRetorno = lcRetorno + substr( tcString, i, 1 )
		endfor

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function TextoaSMS( tcTexto as string ) as string
		local lcRetorno as string, lnCantidad as integer, lnCaracteres as integer, lnCaracteres2 as integer, lcOcteto as string
		store "" to lcRetorno

		lnCantidad = len( tcTexto )
		local array laSeptetos[ lnCantidad, 4 ]
		local array laOctetos[ lnCantidad ]
		store "" to laOctetos

		for i = 1 to lnCantidad
			lcCaracter = substr( tcTexto, i, 1 )
			laSeptetos[ i, 1 ] = ( transform( this.dectobin( asc( lcCaracter ) ) ) )
		endfor

		lnCaracteres = 7
		lnCaracteres2 = 0
		for i = 1 to lnCantidad
			laSeptetos[ i, 2 ] = lnCaracteres
			laSeptetos[ i, 3 ] = left( laSeptetos[ i, 1 ], lnCaracteres )
			laSeptetos[ i, 4 ] = right( laSeptetos[ i, 1 ], lnCaracteres2 )
			lnCaracteres = lnCaracteres - 1
			lnCaracteres2 = lnCaracteres2 + 1
			if lnCaracteres = -1
				lnCaracteres = 7
				lnCaracteres2 = 0
			endif
		endfor

		for i = 1 to alen( laSeptetos, 1 ) - 1
			laOctetos[i] = ( laSeptetos[ i + 1, 4 ] + laSeptetos[ i, 3 ] )
		endfor
		laOctetos[ lnCantidad ] = laSeptetos[ lnCantidad, 3 ]

		for each lcOcteto in laOctetos
			if !empty( lcOcteto )
				lcRetorno = lcRetorno + padl( this.Dec2BasX( this.Bin2Dec( lcOcteto ), 16 ), 2, "0" )
			endif
		endfor

		return upper( lcRetorno )
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function DecToBin( tnNumero as integer ) as string
		local lnPase as integer, lcRetorno as string, i as integer, lnLargo as integer

		lnLargo = 7
		lcRetorno = ""

		for i = 1 to lnLargo
			if tnNumero >= 2
				lnPase = mod( tnNumero, 2 )
				tnNumero = int( tnNumero / 2 )
				lcRetorno = alltrim( str( lnPase, 1 ) ) + lcRetorno
			else
				if tnNumero = 1
					lcRetorno = alltrim( str( 1 ) ) + lcRetorno
					tnNumero = 0
				endif
			endif
		next

		lcRetorno = right( replicate( "0", lnLargo ) + lcRetorno, lnLargo )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function dec2basx( tnTempNum as Integer, tnNewBase as Integer ) as String 
		local lnWorkVal as Integer, lnDividend as Integer, lnDigit as Integer, lcRetorno as String

		store 0 to lnWorkVal, lnDividend, lnDigit

		lnWorkVal = tnTempNum
		lcRetorno = ''

		do while lnWorkVal != 0
			lnDigit = mod( lnWorkVal, tnNewBase )
			lnDividend = lnWorkVal / tnNewBase
			lnWorkVal = int( lnDividend )

			do case
				case lnDigit = 10
					lcRetorno = 'a' + lcRetorno
				case lnDigit = 11
					lcRetorno = 'b' + lcRetorno
				case lnDigit = 12
					lcRetorno = 'c' + lcRetorno
				case lnDigit = 13
					lcRetorno = 'd' + lcRetorno
				case lnDigit = 14
					lcRetorno = 'e' + lcRetorno
				case lnDigit = 15
					lcRetorno = 'f' + lcRetorno
				otherwise
					lcRetorno = ltrim( str( lnDigit ) ) + lcRetorno
			endcase
		enddo
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function bin2dec( tcBinNum as String ) as Integer
		local lnRetval as Integer, lnIndex as Integer, lnDigits as Integer

		store 0 to lnRetVal
		tcBinNum = alltrim( tcBinNum )
		store len( tcBinNum ) to lnDigits
		
		for lnIndex = 0 to lnDigits
			if substr( tcBinNum, lnDigits - lnIndex, 1) = '1'
				lnRetVal = lnRetVal + 2 ^ lnIndex
			endif
		next
		
		return int( lnRetVal )
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function AbrirPuerto() as Boolean
		local llRetorno as Boolean, loError as Exception

		if this.oCOM.PortOpen = .f.
			try
				this.oCOM.PortOpen = .t.
				llRetorno = .t.
			catch to loError
				loError.Message = "No se pudo abrir el puerto de conexión. Verifique que el celular este conectado al puerto COM" + transform( this.oCOM.CommPort )
				throw loError
*!*					? 'Error : El puerto está abierto'
			endtry
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function CerrarPuerto() as Void
		this.oCOM.PortOpen = .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function EnviarComando( tcComando as string ) as Void
		this.oCOM.output = tcComando
		inkey(.1)
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function PuertoValido( tnPuerto as integer ) as boolean
		local llRetorno as boolean
		try
			this.oCOM.CommPort = tnPuerto
			this.oCOM.Settings = "9600,N,8,1"
			llRetorno = .t.
		catch
		endtry

		return llRetorno
	endfunc

enddefine
