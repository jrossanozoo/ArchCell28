define class ManejoArchivos as custom

	#IF .f.
		Local this as ManejoArchivos of ManejoArchivos.prg
	#ENDIF

	oZoo = null
	
	*-----------------------------------------------------------------------------------------
	function oZoo_Access() as Object
		if vartype( this.oZoo ) != "O"
			this.oZoo = newobject( "zoo", "zoo.PRG" )
		endif
		return this.oZoo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearAtributos( tcAtributo, tcArchivo, tcExtensiones ) as Boolean
		return this.SetearAtributosConFiltroDeCarpeta( tcAtributo, tcArchivo, tcExtensiones, "" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearAtributosConFiltroDeCarpeta( tcAtributo, tcArchivo, tcExtensiones, tcFiltroDeCarpeta as String ) as void
		local lcCarpeta as String, lcMensaje as String

		lcCarpeta = upper( justpath( tcArchivo ) )

		if !directory( lcCarpeta, 1 ) or ( !empty( tcFiltroDeCarpeta ) and ( upper( tcFiltroDeCarpeta ) $ lcCarpeta ) )
			return .f.
		endif
		
		local i as integer, lcArchivo as string, llRetorno as Boolean, lnCantidadArchivos as Integer, loError as zooexception of zooexception.prg
		llRetorno = .t.
		
		lcMensaje = ""
		
		if empty( tcExtensiones )
			local array laArchivos[1]

			if occurs( "*", tcArchivo ) # 0
				llRetorno = this.PonerAtributos( justpath( tcArchivo ), tcAtributo )
			else
				*lcAtributoLeido = this.LeerAtributo( tcArchivo )
				*if lcAtributoLeido != tcAtributo
					llRetorno = this.PonerAtributos( tcArchivo, tcAtributo )
				*endif
			endif

			if occurs( "*", tcArchivo ) # 0
				lnCantidadArchivos = adir( laArchivos, tcArchivo, "HD" )

				for i = 3 to alen( laArchivos, 1 )
					lcArchivo = addbs( justpath( tcArchivo ) ) + laArchivos[ i, 1 ]
					
					if "D" $ upper( laArchivos[ i, 5 ] )
						&& Recursividad
						this.SetearAtributosConFiltroDeCarpeta( tcAtributo, addbs( lcArchivo ) + "*", tcExtensiones, tcFiltroDeCarpeta )
						llRetorno = .t. && Se fuerza el true, no debe cortarse la recursividad.
					else
						
						lcArchivo = addbs( justpath( tcArchivo ) ) + laArchivos[ i, 1 ]
						lcPermisos = upper( laArchivos[ i, 5 ] )

						if ( tcAtributo != "N"  and !( tcAtributo $ lcPermisos  ) ) or ( tcAtributo == "N"  and lcPermisos != "....." ) 
							llRetorno = this.PonerAtributos( lcArchivo, tcAtributo )
						endif

						if !llRetorno
							&& Loguear problema. nunca cortar la recursividad por un archivo que no se pudo tratar.
							*lcMensaje = lcMensaje + "Error al tratar de aplicar atributo '" + tcAtributo + "' al archivo " + lcArchivo + ": " + this.ObtenerErrorWinApi()
							llRetorno = .t.
						endif
					endif
				endfor
			endif
		else
			local lnExtensiones as integer
			local array laExtensiones[1]
			if juststem( tcArchivo ) != justfname( tcArchivo )
				tcArchivo = addbs( justpath( tcArchivo ) ) + juststem( tcArchivo )
			endif
			lnExtensiones = alines( laExtensiones, tcExtensiones, "," )
			for i = 1 to alen( laExtensiones, 1 )
				lcArchivo = tcArchivo + "." + laExtensiones[i]
				llRetorno = this.PonerAtributos( lcArchivo, tcAtributo )
				if !llRetorno
					exit
				endif
			endfor
		endif
		
		if !empty( lcMensaje )
			if .f. and type( "goServicios.logueos" ) == "O"
				goServicios.logueos.Loguear( lcMensaje )
				goServicios.logueos.FinalizarLogueo()
			else
				do IntentarLoguearErrorEnDisco with lcMensaje, "manejoarchivos.err" in main
			endif
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerErrorWinApi() as String
		DECLARE Long GetLastError IN WIN32API
		return this.WinApiErrMsg( GetLastError() )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function WinApiErrMsg( tnErrorCode as Integer ) as Void
		DECLARE Long FormatMessage IN kernel32 Long dwFlags, Long lpSource, Long dwMessageId, ;
												Long dwLanguageId, String @lpBuffer, Long nSize, Long Arguments

		lcErrBuffer = REPL(CHR(0),1000)
		lnNewErr = FormatMessage(0x1000, 0, tnErrorCode, 0, @lcErrBuffer,500,0)
		lcErrorMessage = LEFT(lcErrBuffer, AT(CHR(0),lcErrBuffer)- 1 )

		return lcErrorMessage
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function LeerAtributo( tcArchivo As String ) As String
		local lcRetorno as string

		lcRetorno = this.GetAttribFile(tcArchivo)

		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function CrearCarpeta( tcCarpeta as String ) as Void
		if !directory( tcCarpeta )
			md ( tcCarpeta )
		endif
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function BorrarCarpeta( tcdirectorio As String ) As Boolean

		Local lcdirectorio as string , llret as Boolean, lcSetSafe as String, llSalir as boolean
		local array lamatriz(1)

		lcSetSafe = set( "Safety" )
		set safety off 
		llSalir = .f.
		
		If Directory( tcdirectorio, 1 )

			lcdirectorio = "'" + tcdirectorio + "'"
			Do While !llSalir and Adir( lamatriz, tcdirectorio + "\*.*", "HD" ) > 2
*				If 'R' $ lamatriz(3,5) Or 'H' $ lamatriz(3,5) Or 'A' $ lamatriz(3,5)
				If !( 'D' $ lamatriz(3,5) )
					this.SetAttribFile( addbs( tcdirectorio ) + lamatriz[3,1], 0 )
					
					try
						Delete File ( addbs( tcdirectorio ) + lamatriz[3,1] )
					catch
						llSalir = .t.
					endtry
				
				Else
					llSalir = !This.BorrarCarpeta( tcdirectorio + "\" + lamatriz(3,1) )
				Endif
			Enddo

			if !llSalir 
				try 
					Delete File ( tcdirectorio + "\*.*" )
				catch
				endtry 

				If Adir( lamatriz, tcdirectorio + "\*.*","HD" ) = 2
					
					try 
						Rmdir &lcdirectorio
					catch
					endtry 				
					
				endif
			endif 
				
			If Directory( tcdirectorio, 1 )
				llret = .F.
			Else
				llret = .T.
			Endif
		Else
			llret = .T.
		Endif
		
		set safety &lcSetSafe
		
		Return llret

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function BorrarArchivo( tcArchivo As String ) As Boolean
		local lcSetSafe as String, llRetorno as Boolean 

		llRetorno = .f.
		lcSetSafe = set( "safety" )
		set safety off
		
		this.SetAttribFile( tcArchivo, 0 )
		
		try
			Delete File ( tcArchivo )
			llRetorno = .t.
		catch
			llRetorno = .f.
		endtry
	
		
		set safety &lcSetSafe
		
		Return llRetorno

	Endfunc

	*-----------------------------------------------------------------------------------------
	hidden function PonerAtributos( tcArchivo as string, tcAtributo as string ) as Boolean
		local llCambioAtributo as Boolean, lnAtributo as Integer, i as Integer, lcAtributoIndividual as String

		lnAtributo = 0
		for i = 1 to len( tcAtributo )	
			lcAtributoIndividual = substr(tcAtributo,i,1)
			do case
				case upper( lcAtributoIndividual ) = "N"  && Normal (N)
					lnAtributo = lnAtributo + 128					
				case upper( lcAtributoIndividual ) = "R"  && Solo Lectura (R)
					lnAtributo = lnAtributo + 1
				case upper( lcAtributoIndividual ) = "H"  && Oculto (H)
					lnAtributo = lnAtributo + 2
				case upper( lcAtributoIndividual ) = "S"  && Sistema (S)
					lnAtributo = lnAtributo + 4
				case upper( lcAtributoIndividual ) = "D"  && Directorio (D)
					lnAtributo = lnAtributo + 16
				case upper( lcAtributoIndividual ) = "A"  && Archivo (A)
					lnAtributo = lnAtributo + 32
			endcase
		endfor	
		llCambioAtributo = .t.
		if lnAtributo > 0
			llCambioAtributo = this.SetAttribFile( tcArchivo, lnAtributo )
		endif

		return llCambioAtributo
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function GetAttribFile(tcArchivo) as string

		* Retorna los atributos de un archivo
		* PARAMETROS: tcFile = Ruta completa del archivo
		* RETORNA: Caracter

		* R: Solo lectura (1), H: Oculto (2), S: Sistema (4), D: Directorio (16),
		* A: Archivo (32), N: Normal (128)
		* USO: ? GetAttribFile("C:BOOT.INI")

		local lnAtributo as integer, lcRetorno as string

		declare integer GetFileAttributes in WIN32API string cFileName

		lcRetorno = ""
		lnAtributo = GetFileAttributes(tcArchivo)

		if lnAtributo < 0
			gomensajes.enviar( "No se puede obtener el atributo del archivo: " + alltrim( tcArchivo ) ,0,0,0)	
		else

			if bittest(lnAtributo,0) && 1
				lcRetorno = lcRetorno + "R"
			endif

			if bittest(lnAtributo,1) && 2
				lcRetorno = lcRetorno + "H"
			endif

			if bittest(lnAtributo,2) && 4
				lcRetorno = lcRetorno + "S"
			endif

			if bittest(lnAtributo,4) && 16
				lcRetorno = lcRetorno + "D"
			endif

			if bittest(lnAtributo,5) && 32
				lcRetorno = lcRetorno + "A"
			endif

			if bittest(lnAtributo,7) && 128
				lcRetorno = lcRetorno + "N"
			endif

		endif

		return lcRetorno

	endfunc


	*-----------------------------------------------------------------------------------------
	hidden function SetAttribFile( tcArchivo, tnAtributo ) as Boolean

		* Setea los atributos de un archivo
		* PARAMETROS: tcArchivo= Ruta completa del archivo; tnAtributo:
		* 1: Solo lectura (R), 2: Oculto (H), 4: Sistema (S), 16: Directorio (D),  32: Archivo (A);
		* 128: Normal (N)
		* USO: ? SetAttribFile("C:BOOT.INI", 1+3+32)
		local llRetorno as Boolean 
		
		
		declare integer SetFileAttributes in win32api string cFileName, integer nFileAttributes
		try
			llRetorno = ( SetFileAttributes( tcArchivo, tnAtributo ) > 0)
		catch	
			llRetorno = .f.
		endtry
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerArchivo( tcExtension as String, tcTexto as String ) as string

		if vartype( tcExtension ) # 'C'
			tcExtension = ''
		endif
		if vartype( tcTexto ) # 'C'
			tcTexto = ''
		endif
				
		return getFile( tcExtension, tcTexto )

	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerImagenEnDirectorioEspecifico( tcExtension as String, tcTexto as String, tcDirectorio as String ) as string
		local loError as zooexception OF zooexception.prg, lcRutaBkp as String, lcRetorno as String
		lcRetorno = ""

		if directory( tcDirectorio )
			try
				lcRutaBkp = addbs( sys(5) + curdir() )
				set default to &tcDirectorio
				lcRetorno = this.ObtenerImagen( tcExtension, tcTexto )
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )	
			finally
				set default to &lcRutaBkp
			endtry			
		else
			goServicios.Errores.LevantarExcepcion( "El directorio '" + tcDirectorio + "' configurado para seleccionar el archivo no existe." )
		endif
				
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerImagen( tcExtension as String, tcTexto as String ) as string

		if vartype( tcExtension ) # 'C'
			tcExtension = ''
		endif
		if vartype( tcTexto ) # 'C'
			tcTexto = ''
		endif
				
		return getPict( tcExtension, tcTexto )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCarpeta( tcDirectorio as String, tcTexto as String ) as string
		if vartype( tcDirectorio ) # 'C'
			tcDirectorio = ''
		endif
		if vartype( tcTexto ) # 'C'
			tcTexto = 'Seleccione la carpeta y haga click en el botón Aceptar'
		endif	
		
		return getdir( tcDirectorio, tcTexto, "Carpeta", 16+64)

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MoverArchivo( tcArchivoOrigen as String, tcArchivoDestino as String, tlSobreEscribir as Boolean ) as Boolean
		local lcArchivoTemporal as String

		lcArchivoTemporal = this.oZoo.ObtenerRutaTemporal() + sys( 2015 )
		if tlSobreEscribir and file( tcArchivoDestino )
			try
				rename ( tcArchivoDestino ) to ( lcArchivoTemporal )
			catch to loEx
				goServicios.Errores.LevantarExcepcion( loEx ) 
			endtry
		endif

		try
			rename ( tcArchivoOrigen ) to ( tcArchivoDestino )
		catch to loEx
			if tlSobreEscribir and file( lcArchivoTemporal )
				rename ( lcArchivoTemporal ) to ( tcArchivoDestino )
			endif
			goServicios.Errores.LevantarExcepcion( loEx ) 
		endtry

		if tlSobreEscribir
			try
				delete file ( lcArchivoTemporal )
			endtry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	procedure WinSetFileTime
		lparameters m.uFl, m.cTimeType, m.nYear, m.nMonth, m.nDay, m.nHour, m.nMinute, m.nSec, m.nThou
		#define OF_READWRITE 2
		local m.lpFileInformation, m.cS, m.nPar, m.fh, m.lpFileInformation, m.lpSYSTIME, m.cCreation,;
			m.cLastAccess, m.cLastWrite, m.cBuffTime, m.cBuffTime1, m.cTT,m.nYear1, m.nMonth1, m.nDay1, m.nHour1,;
			m.nMinute1, m.nSec1, m.nThou1

		m.nPar = parameters()
		if m.nPar < 1
			return .F.
		endif

		=this.Decl()  && declara funciones externas

		m.cTT = iif( m.nPar >= 2 and type( "m.cTimeType" ) = "C" and !empty( m.cTimeType ), lower( substr( m.cTimeType, 1, 1 ) ), "c" )
		m.nYear1 = iif( m.nPar >= 3 and type( "m.nYear" ) $ "FIN" and m.nYear >= 1800, round( m.nYear, 0 ), -1 )
		m.nMonth1 = iif( m.nPar >= 4 and type( "m.nMonth" ) $ "FIN" and between( m.nMonth, 1, 12 ), round( m.nMonth, 0 ), -1 )
		m.nDay1 = iif( m.nPar >= 5 and type( "m.nDay" ) $ "FIN" and between( m.nDay, 1, 31 ), round( m.nDay, 0 ), -1 )
		m.nHour1 = iif( m.nPar >= 6 AND type( "m.nHour" ) $ "FIN" AND between( m.nHour, 0, 23 ), round( m.nHour, 0 ), -1 )
		m.nMinute1 = iif( m.nPar >= 7 AND type( "m.nMinute" ) $ "FIN" AND between( m.nMinute, 0, 59 ), round( m.nMinute, 0 ), -1 )
		m.nSec1 = iif( m.nPar >= 8 AND type( "m.nSec" ) $ "FIN" AND between( m.nSec, 0, 59 ), round( m.nSec, 0 ), -1 )
		m.nThou1 = iif( m.nPar >= 9 AND type( "m.nThou" ) $ "FIN" AND between( m.nThou, 0, 999 ), round( m.nThou, 0 ), -1 )
		m.lpFileInformation = repli ( chr(0), 53 )
		m.lpSYSTIME = repli ( chr(0), 16 )

		if GetFileAttributesEx(m.uFl, 0, @lpFileInformation) = 0
	    	return .F.
		endif

		m.cCreation = substr( m.lpFileInformation, 5, 8 )
		m.cLastAccess = substr( m.lpFileInformation, 13, 8 )
		m.cLastWrite = substr( m.lpFileInformation, 21, 8 )
		m.cBuffTime = iif( m.cTT = "w", m.cLastWrite, iif( m.cTT = "a", m.cLastAccess, m.cCreation ) )
		FileTimeToSystemTime( m.cBuffTime, @lpSYSTIME )
		m.lpSYSTIME = iif( m.nYear1 >= 0, this.Int2Word( m.nYear1 ), substr( m.lpSYSTIME, 1, 2 ) ) + iif( m.nMonth1 >= 0, this.Int2Word( m.nMonth1 ), ;
						substr( m.lpSYSTIME, 3, 2 ) ) + substr( m.lpSYSTIME, 5, 2 ) + iif( m.nDay1 >= 0, this.Int2Word( m.nDay1 ), substr( m.lpSYSTIME, 7, 2 ) ) +;
						iif( m.nHour1 >= 0, this.Int2Word( m.nHour1 ), substr( m.lpSYSTIME, 9, 2 ) ) +;
						iif( m.nMinute1 >= 0, this.Int2Word( m.nMinute1 ), substr( m.lpSYSTIME, 11, 2 ) ) +;
						iif( m.nSec1 >= 0, this.Int2Word( m.nSec1 ), substr( m.lpSYSTIME, 13, 2 ) ) +;
						iif( m.nThou1 >= 0, this.Int2Word( m.nThou1 ), substr( m.lpSYSTIME, 15, 2 ) )
		SystemTimeToFileTime( m.lpSYSTIME, @cBuffTime )
		m.cBuffTime1 = m.cBuffTime
		LocalFileTimeToFileTime( m.cBuffTime1, @cBuffTime )
		
		do case
		    case m.cTT = "w"
				m.cLastWrite = m.cBuffTime
			case m.cTT = "a"
				m.cLastAccess = m.cBuffTime
			otherwise
				m.cCreation = m.cBuffTime
		endcase

		m.fh = _lopen( m.uFl, OF_READWRITE )
		if m.fh < 0
			return .F.
		endif

		SetFileTime( m.fh, m.cCreation, m.cLastAccess, m.cLastWrite )
		_lclose( m.fh )

		*!* ----------------------- COMO USAR ------------------------------------------
		*!*
		*!* Modifica la FechaHora de un archivo
		*!* Uso:
		*!* m.lRsltC=WinSetFileTime("C:\Imagenes\Foto.JPG","c",2001,08,29,18,01,01,300)
		*!* m.lRsltW=WinSetFileTime("C:\Imagenes\Foto.JPG","w",2001,08,29,18,01,04,000)
		*!* m.lRsltA=WinSetFileTime("C:\Imagenes\Foto.JPG","a",2001,08,30,0,0,0,000)
		*!*
		*!* m.cTimeType
		*!* c - creación (default)
		*!* a - acceso
		*!* w - escritura
		*!*
		*!* FechaHora Creación
		*!*? WinSetFileTime("C:\MiImagen.jpg","c",2002,01,01,18,59,59,300)
		*!*
		*!* FechaHora último acceso
		*!*? WinSetFileTime("C:\MiImagen.jpg","a",2002,01,02,18,59,59,300)
		*!*
		*!* FechaHora Modificación
		*!*? WinSetFileTime("C:\MiImagen.jpg","w",2002,01,03,18,59,59,300)
		*!*
		*!* ---------------------------------------------------------------------------

		return .T.
	endproc

	*-----------------------------------------------------------------------------------------
	procedure Int2Word
		lparameters m.nVal

		return chr( mod( m.nVal, 256 ) ) + chr( int( m.nVal / 256 ) )
	endproc

	*-----------------------------------------------------------------------------------------
	procedure DECL
		declare integer SetFileTime in kernel32;
			integer hFile, string lpCreationTime, string lpLastAccessTime, string lpLastWriteTime
		declare integer GetFileAttributesEx in kernel32;
		    string lpFileName, integer fInfoLevelId, string @ lpFileInformation
		declare integer LocalFileTimeToFileTime in kernel32;
		    string LOCALFILETIME, string @ FILETIME
		declare integer FileTimeToSystemTime in kernel32;
		    string FILETIME, string @ SYSTEMTIME
		declare integer SystemTimeToFileTime in kernel32;
		    string lpSYSTEMTIME, string  @ FILETIME
		declare integer _lopen in kernel32;
		    string lpFileName, integer iReadWrite
		declare integer _lclose in kernel32 integer hFile
	endproc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerArchivosEnDirectorio( tcPattern as String, tcPath as String, tlFullDirectories as Boolean ) as zooColeccion OF zooColeccion.prg
		local loCol as zooColeccion OF zooColeccion.prg, loDirInfo as Object, loFiles as Object, lnI as Integer
		
		loCol = this.oZoo.CrearObjeto( "ZooColeccion" )
		loDirInfo = this.oZoo.CrearObjeto( "System.IO.DirectoryInfo", .F., tcPath )
		loFiles = loDirInfo.GetFiles( tcPattern, iif( tlFullDirectories, 1, 0 ) )
		for lnI = 1 to alen( loFiles )
			loCol.Agregar( loFiles( lnI ).FullName )
		endfor
		
		loFiles = null
		loDirInfo = null
		
		return loCol
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LeerArchivo( tcRuta as String ) as String
		return filetostr( tcRuta )
	endfunc 

enddefine
