Define Class EnvioMail As Custom

	cSubject = "" 
	cMessage = "" 
	cRecipient = "" 
	cMailServer = "" 
	cSenderEMail = "" 
	cSenderName = "" 
	cCCList = "" 
	cBCCList = "" 
	cErrorMsg = "" 
	cLastErrorString = ""
	cAttachment = "" 
	cContentType = "" 
	cUsuario = "" &&'Zoologic\abuse' &&"502329h@zoologic3.com.ar"
	cPassword = "" &&'Lince1534' &&"886074"
	
	Protected oMail, oMsg, oFrom
	oMail = Null
	oMsg = Null
	oFrom = Null
	
	nInkeyDesconectar = 10
	nInkeyReConectar = 10
	nInkeyLuegoDeEnviar = 0.5
	nCantidadReintentos = 3

	*-----------------------------------------------------------------------------------------
	Function Init() As Void
		This.oMail = Createobject("Mabry.SmtpX")
		This.oMsg = CreateObject("Mabry.MimeMessage.1") && es el objeto mensaje
		This.oFrom = CreateObject("COM.Address") && es el remitente

		with this.oMail
			.LicenseKey = "ALAA-RZ28XYT3M5Q1"
			.Blocking = .T.

			.AuthenticationType = 1 &&  && AuthLogin
			.ConnectionType = 1 &&  && ESMTPConnection
			this.cUsuario = 'zoologic\clientesinmail'
			*.LogonName = 'zoologic\clientesinmail'
			*.LogonPassword = 'AudiTT2007'
			*Ver permisos de la cuenta en Active Directory'
			this.cPassword = 'AudiTT2007'
			**'502329h@zoologic3.com.ar'
			**'886074'
		endwith		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function cErrorMsg_Access() as Void
		local lcError as String 
		lcError = alltrim( str( this.oMail.LastError ) )
		if lcError = '0'
			lcError = ''
		endif
		
		return lcError
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cLastErrorString_Access() as Void
		return this.oMail.LastErrorString
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function cUsuario_assign( tcValor As String ) As Void
		This.cUsuario = tcValor
		this.oMail.LogonName = tcValor
	Endfunc
	*-----------------------------------------------------------------------------------------

	Function cPassword_assign( tcValor As String ) As Void
		This.cPassword = tcValor
		this.oMail.LogonPassword = tcValor
	Endfunc
	*-----------------------------------------------------------------------------------------

	Function SendMail() As Boolean
		local a as integer, b as Integer, llOk as Boolean

		llok = .T.

		with this

			A=.omail.state
			B=.omail.lasterror
			IF B # 0
				llOk = .Reconectar( "Error antes de enviar" )
			endif

			IF a>0 and b=0 and llOk
				llOk = .SendMessage()
				
				.oMsg = null
				.oMsg = CreateObject( "Mabry.MimeMessage.1" )
				.oMsg.From  = .oFrom
				.oMsg.CC = .cCCList 
				.oMsg.BCC = .cBCCList 
				.oMsg.Subject = .cSubject
			else
				llok = .F.
			endif
		endwith
		
		return llOk		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function SendMessage() as Boolean
		local llRetorno as Boolean
	
		llRetorno = .T.
	
		with this	
			.omail.Sendmessage( .omsg )
			inkey( .nInkeyLuegoDeEnviar )
			
			if .omail.lasterror > 0
				llRetorno = .Reconectar( "Error al enviar" )
				if llRetorno 
					.omail.Sendmessage( .omsg )
					inkey( .nInkeyLuegoDeEnviar )
					llRetorno = ( .omail.lasterror = 0 )
				endif
			endif
		endwith
		
		return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function Reconectar( tcMotivo as String ) as Boolean
		local llRetorno as boolean, lnA as integer, lni as integer
		
		if empty( tcMotivo )
			tcMotivo  = ""
		else
			tcMotivo = " - " + tcMotivo
		endif
		
		lni = 0
		do while lni < this.nCantidadReintentos and !llRetorno
			llRetorno = .t.
			
			wait window "Reestableciendo conexión en " + transform( this.nInkeyDesconectar ) + " seg." + tcMotivo + " (Intento: " + transform( lni + 1 ) + ") ..." timeout this.nInkeyDesconectar
			try
				this.Desconectar()
			catch
				llRetorno = .f.
			endtry

			llRetorno = llRetorno  and ( This.omail.lasterror = 0 )

			if llRetorno 
				wait window "Reconectando en " + transform( this.nInkeyReconectar ) + " seg. (" + transform( lni + 1 ) + ") ..." timeout this.nInkeyReconectar
				try
					this.Conectar()
				catch
					llRetorno = .f.
				endtry
				llRetorno = llRetorno and This.omail.state > 0 and This.omail.lasterror = 0
			endif

			if llRetorno 
				lnA = This.omail.state
				llRetorno = llRetorno and ( This.omail.lasterror = 0 )
			endif

			lni = lni + 1
		enddo
				
		IF !llRetorno 
			wait window "Error al reintentar conectar " + tcMotivo + " (" + this.oMail.LastErrorString + ")" timeout 2
		endif

		wait clear
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function cSubject_assign( tcValor As String ) As Void
		This.cSubject = tcValor
		this.oMsg.Subject = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cMessage_assign( tcValor As String ) As Void
		This.cMessage = tcValor
		this.oMsg.body = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cRecipient_assign( tcValor As String ) As Void
		This.cRecipient = tcValor
		this.oMSG.to = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cMailServer_assign( tcValor As String ) As Void
		This.cMailServer = tcValor
		This.oMail.Host = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cSenderEMail_assign( tcValor As String ) As Void
		This.cSenderEMail = tcValor
		this.oFrom.text = this.cSenderName + " <" + alltrim(This.cSenderEMail) + ">"
		this.oMsg.From  = this.oFrom
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cSenderName_assign( tcValor As String ) As Void
		This.cSenderName = alltrim( tcValor )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cCCList_assign( tcValor As String ) As Void
		This.cCCList = tcValor
		this.oMSG.CC = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cBCCList_assign( tcValor As String ) As Void
		This.cBCCList = tcValor
		this.oMSG.bcc = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cAttachment_assign( tcValor As String ) As Void
		if !empty( tcValor)
			This.cAttachment = tcValor
			this.oMSG.AttachFile (tcValor)
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cContentType_assign( tcValor As String ) As Void
		This.cContentType = tcValor
		this.omsg.ContentType = tcValor
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Conectar() as Void
		with this.omail
			try
				.connect()
			catch
				wait window "Error al conectar al servidor SMTP [" + alltrim( .LastErrorString ) + "]" timeout 5
			endtry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Desconectar() as Void
		try
			this.omail.disconnect()
		catch
		endtry
	endfunc 

Enddefine