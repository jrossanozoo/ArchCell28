**********************************************************************
Define Class ztestArmadorCuerpoMail as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestArmadorCuerpoMail of ztestArmadorCuerpoMail.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestConfiguracionSmtp
		local loConfiguradorDeMail as ConfiguradorDeMail of ConfiguradorDeMail.prg, lcServidor as String, ;
		loServidor as din_entidadServidorSmtp of din_entidadServidorSmtp.prg
		
		lcServidor = right( sys( 2015 ), 8 )
		
		loServidor = _screen.zoo.instanciarentidad( "CUENTACORREO" )
		loServidor.Nuevo()
		
		loServidor.Codigo = lcServidor
		loServidor.SerVIDOR = "200.015.214"
		loServidor.Usuario = "usuario1"
		loServidor.Password = "456D245D38A938FBB76942B5139CB8AD"

		loServidor.ConexionesSeguras = .t.
		loServidor.TiempoDeEspera = 50
		loServidor.Grabar()

		
		loConfiguradorDeMail = _screen.zoo.crearobjeto( "ConfiguradorDeMail" )
		loConfig = loConfiguradorDeMail.ObtenerconfiguracionPorCodigo( lcServidor )
		
		this.assertequals( "Servidor", "200.015.214" , alltrim( loConfig.Servidor ) )
		this.assertequals( "Servidor", .t. , loConfig.ConexionSegura )
		this.assertequals( "Servidor", 50 , loConfig.Timeout )
		
		loServidor.Release()
		loConfiguradorDeMail.Release()
		
		loConfig = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestArmar
		local loArmador as ArmadorCuerpomail of ArmadorCuerpomail.prg, lcParamMailError As String,;
		loEntidad as din_entidadEmail of din_entidadEmail.prg, loCol as zoocoleccion OF zoocoleccion.prg, loEntidadDatos as Object

		loArmador = _screen.zoo.crearobjeto( "ArmadorCuerpoMail" )
		_screen.mocks.agregarmock( "ManagerImpresion" )
		loCol = _screen.zoo.crearobjeto( "zooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERIMPRESION', 'Generarpdfsalenviarmail', loCol, "'*OBJETO'" )

		this.agregarmocks( "email,factura" )
		_screen.mocks.AgregarSeteoMetodo( 'email', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		loArmador.oManagerImpresion = _screen.zoo.crearobjeto( "ManagerImpresion" )
		
		loEntidad = _Screen.zoo.instanciarentidad( "Email" )

		loEntidad.MailPara = "ParaMail@zoologic.com.ar"
		loEntidad.MailCOPIA = "Copia@zoologic.com.ar"
		loEntidad.MailCopiaOculta = "Oculta@zoologic.com.ar"
		loEntidad.Asunto = "Asuntillo"
		loEntidad.Texto = "Textillo"

		loFactory = _screen.zoo.crearobjeto( "ZoologicSA.Mail.MailFactory" )
		loCuerpoNet = loFactory.ObtenerCuerpoMail()
		loEntidadDatos = _screen.Zoo.InstanciarEntidad( "Honduras" )
		loCuerpo = loArmador.Armar( loCuerpoNet , loEntidad, loEntidadDatos )
		
		this.assertequals( "Error destinatario", ";ParaMail@zoologic.com.ar", loCuerpo.MailPara )
		this.assertequals( "Error con copia", ";Copia@zoologic.com.ar", loCuerpo.MailCC )
		this.assertequals( "Error con copia oculta", ";Oculta@zoologic.com.ar", loCuerpo.MailCCO )
		this.assertequals( "Error asunto", "Asuntillo", loCuerpo.Asunto )		
		this.assertequals( "Error texto", "Textillo", loCuerpo.Texto )				

		loEntidadDatos.release()
		
		loEntidad.MailPara = ""
		
		loEntidadDatos = _screen.Zoo.InstanciarEntidad( "Honduras" )
		loEntidadDatos.cnombre = "COMPROBANTESECOMMERCE"

		goparametros.Nucleo.Sonidosynotificaciones.MailsDeDestinoAnteProblemasDeEjecucionesDesatendidas = "test@zoologic.com.ar"
		lcParamMailError = goparametros.Nucleo.Sonidosynotificaciones.MailsDeDestinoAnteProblemasDeEjecucionesDesatendidas
		loCuerpo = loArmador.Armar( loCuerpoNet , loEntidad, loEntidadDatos )
		
		this.assertequals( "Error destinatario", lcParamMailError, loCuerpo.MailPara )
		this.assertequals( "Error con copia", ";Copia@zoologic.com.ar", loCuerpo.MailCC )
		this.assertequals( "Error con copia oculta", ";Oculta@zoologic.com.ar", loCuerpo.MailCCO )
		this.assertequals( "Error asunto", "Asuntillo", loCuerpo.Asunto )		
		this.assertequals( "Error texto", "Textillo", loCuerpo.Texto )				

	endfunc 

EndDefine
