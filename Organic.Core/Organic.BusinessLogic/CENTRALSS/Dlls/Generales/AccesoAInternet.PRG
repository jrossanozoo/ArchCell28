define class AccesoAInternet as Custom

	lUltimaDescarga = .f.
	cMensajeDeError = ""
	oXhtmlRequest = null
	cObjetoXMLHTTPUsado = ""
	cEstadoHTTP = ""
	nIDTimer = 0
	lXMLHTTPFunciono = .f.

	*-----------------------------------------------------------------------------------------
	function init
		set library to "cpptimer.fll" additive
		_Screen.Zoo.App.SetarUsoDeTimers()
		if _Screen.Zoo.App.lEstoyUsandoTimers
			this.nIDTimer = GetFreeTimerIndex()
			if this.nIDTimer = 0
				inittimers( 10, 100 )
				this.nIDTimer = 1
			endif
		endif
		public goTimeOut as "TimeOut" of "c:\programa\lin-prog\e-lince\e-clases\accesoainternet.prg"
		goTimeOut = newobject( "TimeOut" )
		goTimeOut.lTimeOut = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DescargarArchivo( tcDominio as String, tcRutaDeDescarga as String ) as Boolean
		local llRetorno as Boolean, lcParcheContraTemporales as String, lcDominio as String
		
		llRetorno = .f.
		lcDominio = tcDominio 
		
		lcParcheContraTemporales = "r1ppq2=" + alltrim( strtran( sys(2015),"_","") )
		if "?" $ lcDominio 
			lcDominio = lcDominio + chr(38) + lcParcheContraTemporales
		else
			lcDominio = lcDominio + "?" + lcParcheContraTemporales
		endif
		
		if this.DescargarConXMLHTTP( lcDominio, tcRutaDeDescarga )
			llRetorno = .t.
		else
			if !this.lXMLHTTPFunciono
				if this.URLDownloadToFile( lcDominio, tcRutaDeDescarga )
					llRetorno = .t.
				endif
			endif
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function URLDownloadToFile( tcDominio  as String, tcRutaDeDescarga as String ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcDominio as String
				
		llRetorno = .f.
		lcDominio = tcDominio

		this.lUltimaDescarga = .f.
		try
			declare integer URLDownloadToFile in urlmon;
				integer, string, string, integer, integer
			lcParcheContraTemporales = "r1ppq2=" + alltrim( strtran( sys(2015),"_","") )
			if "?" $ lcDominio 
				lcDominio = lcDominio + chr(38) + lcParcheContraTemporales
			else
				lcDominio = lcDominio + "?" + lcParcheContraTemporales
			endif
			this.BorrarArchivoLocal( tcRutaDeDescarga )
			if URLDownloadToFile( 0, lcDominio, tcRutaDeDescarga, 0, 0 ) == 0
				llRetorno = .t.
				this.lUltimaDescarga = .t.
			endif
		catch to loError
			this.cMensajeDeError = alltrim( loError.message )
		endtry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function BorrarArchivoLocal( tcRutaYNombre as string ) as Boolean
		local loError as exception, llRetorno as Boolean

		llRetorno = .f.

		try
			if file( tcRutaYNombre )
				delete file( tcRutaYNombre )
			endif
			llRetorno = .t.
		catch to loError
			llRetorno = .f.	
		endtry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DescargarConXMLHTTP( tcDominio as String, tcRutaDeDescarga as String ) as Boolean
		local loError as Exception, lcArchivoTMP as String, lcDominio as String, llRetorno as Boolean, lcArchivoLocal as String
		
		llRetorno = .f.
		lcArchivoLocal = ""
		lcArchivoTMP = ""
		
		try
			this.oXhtmlRequest = this.CrearObjectoXMLHTTP()
			if vartype( this.oXhtmlRequest ) = "O"
				lcDominio = tcDominio
				lcArchivoTMP = sys(5) + curdir() + sys( 2015 )
				lcArchivoLocal = tcRutaDeDescarga
				
				this.cEstadoHTTP = "Enviando petición"
				with this.oXhtmlRequest
					.open( "GET", lcDominio, .t. ) && <-- el true es asincronico.
				    .send( null )	
				endwith
				
				SetupTimer( this.nIDTimer, 30000 , "goTimeOut.DarTimeOut()" )
				do while this.oXhtmlRequest.readyState # 4 and !goTimeOut.lTimeOut
					inkey( 0.5, "H" )
					lcReadyState = this.oXhtmlRequest.readyState
					doevents
					do case
						case lcReadyState = 0
							this.cEstadoHTTP = "No Inicializado"
						case lcReadyState = 1
							this.cEstadoHTTP = "Cargando"
						case lcReadyState = 2
							this.cEstadoHTTP = "Cargado"
						case lcReadyState = 3
							this.cEstadoHTTP = "Interactuando"
						otherwise
							this.cEstadoHTTP = "Estado no reconocido."
					endcase
					doevents
				enddo
				
				StopTimer( this.nIDTimer )	
				if !goTimeOut.lTimeOut and this.oXhtmlRequest.status = 200
					this.BorrarArchivoLocal( lcArchivoLocal )
					strtofile( this.oXhtmlRequest.responsebody, lcArchivoLocal, 1 ) && OK.
					llRetorno = .t.
				else
					this.cEstadoHTTP = "ERROR"
					if !goTimeOut.lTimeOut	
						this.cMensajeDeError = this.oXhtmlRequest.statusText && Error al bajar.
					else
						this.cEstadoHTTP = this.cEstadoHTTP + " - Time Out"
					endif
				endif
				goTimeOut.lTimeOut = .f.
				this.lXMLHTTPFunciono = .t.				
			endif
		catch to loError
			this.cEstadoHTTP = "ERROR"
			this.cMensajeDeError = loError.Message
		endtry
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearObjectoXMLHTTP() as Object
		local loObjeto as Object, llok as Boolean
		
		llok = .f.
		loObjeto = null
		
		if vartype( this.oXhtmlRequest ) = "O"
			this.oXhtmlRequest = null
		endif

		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk
				loObjeto = createobject( "Msxml2.XMLHTTP.7.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.7.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*		
		try
			if !llOk
				loObjeto = createobject( "Msxml2.XMLHTTP.6.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.6.0"			
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*		
		try
			if !llOk
				loObjeto = createobject( "Msxml2.XMLHTTP.5.0" )
				llok = .t.		
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.5.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk
				loObjeto = createobject( "Msxml2.XMLHTTP.4.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.4.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk			
				loObjeto = createobject( "Msxml2.XMLHTTP.3.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.3.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk		
				loObjeto = createobject( "Msxml2.XMLHTTP.2.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.2.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk		
				loObjeto = createobject( "Msxml2.XMLHTTP.1.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.1.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk		
				loObjeto = createobject( "Msxml2.XMLHTTP" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.1.0"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk		
				loObjeto = createobject( "Msxml2.ServerXMLHTTP.3.0" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Msxml2.XMLHTTP.1.0"
			endif
		catch to loError
		endtry		
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk		
				loObjeto = createobject( "MSXML2.ServerXMLHTTP" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "MSXML2.ServerXMLHTTP"
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		try
			if !llOk		
				loObjeto = createobject( "Microsoft.XMLHTTP" )
				llok = .t.
				this.cObjetoXMLHTTPUsado = "Microsoft.XMLHTTP" 
			endif
		catch to loError
		endtry
		*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		
		return loObjeto
	endfunc 


enddefine


define class TimeOut as Custom

	lTimeOut = .f.
	
	*-----------------------------------------------------------------------------------------
	function DarTimeOut() as Void
		this.lTimeOut = .t.
	endfunc 

enddefine
