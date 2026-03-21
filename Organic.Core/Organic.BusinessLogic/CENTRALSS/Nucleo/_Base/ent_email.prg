Define class ent_email as din_EntidadEMail of din_EntidadEMail.prg
	
	#if .f.
		local this as ent_email of ent_email.prg
	#endif

	ArchivoXml = addbs( _screen.zoo.cRutaInicial ) + "Generados\dat_datosMail.XML"
	ArchivoXmlE = addbs( _screen.zoo.cRutaInicial ) + "Generados\dat_datosMailE.XML"

	*-----------------------------------------------------------------------------------------
	function AutoCompletarFe() as Void
		local loAdapter as XMLAdapter, lcAlias As String
		lcArchivoXML = This.ArchivoXml

		loAdapter = CreateObject( "XMLAdapter" )
		loAdapter.LoadXML( lcArchivoXML, .T. )

		lcAlias = loAdapter.Tables.Item(1).alias

		with loAdapter.Tables(1)
			.ToCursor()
		endwith
		loAdapter = null

		select ( lcAlias )
		locate for codigo = "FE"

		this.Texto = strtran( cuerpo, "<PARAMETRO>", goParametros.nucleo.DatosGenerales.RazonSocialDeLaEmpresa )

		this.Asunto = evaluate( asunto )
		this.mailpara = Mailpara

		use in select( lcAlias )
		this.CompletarDetalleEntidades()		
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AutoCompletarEcom() as Void
		local loAdapter as XMLAdapter, lcAlias As String
		lcArchivoXML = This.ArchivoXmlE

		loAdapter = CreateObject( "XMLAdapter" )
		loAdapter.LoadXML( lcArchivoXML, .T. )

		lcAlias = loAdapter.Tables.Item(1).alias

		with loAdapter.Tables(1)
			.ToCursor()
		endwith
		loAdapter = null

		select ( lcAlias )
		locate for codigo = "ECOM"
		
		this.Texto = cuerpo

		this.Asunto = evaluate( asunto )
		this.mailpara = Mailpara
		this.EnviarAlGuardar = .T.
		
		use in select( lcAlias )
		
		with this.Entidades
			.limpiar()	
			.oItem.limpiar()	
			.oItem.entidad = "VALEDECAMBIO"
			.actualizar()
		endwith 
		
			
	endfunc 		
		
	*-----------------------------------------------------------------------------------------
	function CompletarDetalleEntidades() as Void
		local loArreglo as zoocoleccion OF zoocoleccion.prg, loArreglo as Object , lnI as Integer 
		
		loArreglo = _screen.zoo.crearobjeto("zoocoleccion")
		loArreglo.agregar("FACTURAELECTRONICA")
		loArreglo.agregar("NOTADECREDITOELECTRONICA")
		loArreglo.agregar("NOTADEDEBITOELECTRONICA")
		with this.Entidades
			.limpiar()	
			for lnI = 1 to loArreglo.Count 
				.oItem.limpiar()	
				.oItem.entidad = loArreglo.Item( lnI )
				.actualizar()
			endfor
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as Void
		local llRetorno as Boolean

		llRetorno = dodefault()
		
		if empty( this.MailPara ) and empty( this.MailCopia ) and empty( this.MailCopiaOculta )
			this.AgregarInformacion( "Debe ingresar direcciones de e-mail de destinatarios." )
			llRetorno = .f.
		endif

		return llRetorno 
	endfunc 

enddefine