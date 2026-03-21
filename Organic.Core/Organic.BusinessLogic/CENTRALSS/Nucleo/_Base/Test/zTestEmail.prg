**********************************************************************
Define Class zTestEmail as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestEmail of zTestEmail.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		
	EndFunc
	
	*---------------------------------
	Function TearDown
	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestCargarEntidadConDatosBasicos
		local loEntidad as ent_eMail of ent_email.prg
		
		loEntidad = _screen.zoo.instanciarentidad( "Email" )
		loEntidad.Nuevo()		

		loEntidad.ArchivoXml = addbs( _screen.zoo.cRutaInicial ) + "clasesdeprueba\dat_datosMail.XML"		
		loEntidad.AutoCompletarFe()
		
		this.assertequals( "Dato en asunto incorrecto", "Factura Electrónica", alltrim( loEntidad.Asunto ) )
		this.Assertequals( "Dato en Destinatario incorrecto.", ".CLIENTE.MAIL", loEntidad.MailPara )

		loEntidad.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificarRutaArchivoAutoCompletar
		local loEntidad as ent_eMail of ent_email.prg
		
		loEntidad = _screen.zoo.instanciarentidad( "Email" )
		this.assertequals( "Dato en asunto incorrecto", addbs( _screen.zoo.cRutaInicial ) + "Generados\dat_datosMail.XML", loEntidad.ArchivoXml )

		loEntidad.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTest_Validar
		local loEntidad as ent_email of ent_email.prg, loInformacion as zooInformacion of zooInformacion.prg
		
		this.agregarmocks( "cuentacorreo" )
		
		loEntidad = _screen.zoo.instanciarentidad( "email" )
		loEntidad.Nuevo()
		
		loEntidad.codigo = right( sys( 2015 ), 8 )
		loEntidad.Servidor_pk = "CODIGO1"
		loEntidad.Entidades.Limpiar()
		
		loEntidad.Entidades.oItem.Entidad = "ENTIDAD1"
		loEntidad.Entidades.Actualizar()
		
		llRetorno = loEntidad.Validar()
		
		loInformacion = loEntidad.ObtenerInformacion()

		this.assertequals( "Faltan atributos", "Debe ingresar direcciones de e-mail de destinatarios.", loInformacion.Item(1).cMensaje )

		loEntidad.Cancelar()
		loEntidad.Release()

	endfunc 

EndDefine