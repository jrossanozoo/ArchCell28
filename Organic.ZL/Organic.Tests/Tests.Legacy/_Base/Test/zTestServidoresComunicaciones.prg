**********************************************************************
Define Class zTestServidoresComunicaciones as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestServidoresComunicaciones of zTestServidoresComunicaciones.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarSiPermiteoNoSeleccionarServidor
		local loEntidad as ent_ServidoresComunicaciones of ent_ServidoresComunicaciones.prg, loError as Exception
		

		this.agregarmocks( "Proveedor" )
	
		loEntidad = _screen.Zoo.InstanciarEntidad( "ServidoresComunicaciones" )

		with loEntidad
			.Nuevo()
			.proveedor 				= 'Servidor de Prueba_' + sys(2015)
			.subentproveedor_pk 	= '1'
			.dominio 				= 'zooologic6.com.ar'
			.pop3host  				= 'mail.zooologic6.com.ar'
			.smtphost				= 'mail.zooologic6.com.ar'
			.anteponerusername		= '' 
			.agregarusername		= '@zoologic6.com.ar'
			.anteponercuenta		= '' 
			.anteponerclave			= '' 
			
			.metododecomunicacion 	= 1
			try 
				.servidorcheckline 		= .T.
				This.asserttrue( 'No deberia permitir el checkeo de servidores checkline porque la comunicacion es por SMTP', .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 1",;
					"No se puede cambiar este valor (Entidad: Servidores de comunicaciones - Atributo: Servidorcheckline)",;
					loError.userValue.oInformacion.Item[1].cMensaje )
			finally
			endtry 
			
			try 
				.servidorehost			= .T.
				This.asserttrue( 'No deberia permitir el checkeo de servidores host porque la comunicacion es por SMTP', .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 2",;
					"No se puede cambiar este valor (Entidad: Servidores de comunicaciones - Atributo: Servidorehost)"	,;
						loError.userValue.oInformacion.Item(1).cMensaje )
			finally
			endtry 

			.metododecomunicacion 	= 2
			try 
				.servidorcheckline 		= .T.
				.servidorehost			= .T.
			catch to loError
				This.asserttrue( 'Deberia permitir el checkeo de servidores checkline/host porque la comunicacion es por FTP', .F. )
			finally
			endtry
			
			this.assertequals( "El puerto sugerido no es el correcto", 21, .PuertoControlServidor )
			this.assertequals( "El modo pasivo sugerido no es el correcto", .t., .ModoPasivo )
			this.assertequals( "El envío de datos sugerido no es el correcto", 1, .TipoEnvioDeDatos )

			.metododecomunicacion 	= 1
			try 
				.servidorcheckline 		= .T.
				This.asserttrue( 'No deberia permitir el checkeo de servidores checkline porque la comunicacion es por SMTP 2', .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 2",;
				"No se puede cambiar este valor (Entidad: Servidores de comunicaciones - Atributo: Servidorcheckline)",;
					loError.userValue.oInformacion.Item(1).cMensaje )
			finally
			endtry 
			
			this.assertequals( "El puerto sugerido no es el correcto 2", 21, .PuertoControlServidor )
			this.assertequals( "El modo pasivo sugerido no es el correcto 2", .t., .ModoPasivo )
			this.assertequals( "El envío de datos sugerido no es el correcto 2", 1, .TipoEnvioDeDatos )

			try 
				.servidorehost			= .T.
				This.asserttrue( 'No deberia permitir el checkeo de servidores host porque la comunicacion es por SMTP 2', .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 2",;
					"No se puede cambiar este valor (Entidad: Servidores de comunicaciones - Atributo: Servidorehost)",;
						loError.userValue.oInformacion.Item(1).cMensaje )
			finally
			endtry 

			this.asserttrue( "No se deshabilitó el atributo Servidorehost", !.servidorehost )
			this.asserttrue( "No se deshabilitó el atributo Servidorcheckline", !.servidorcheckline )

			.metododecomunicacion 	= 1
			try 
				.servidorcheckline 		= .T.
				This.asserttrue( 'No deberia permitir el checkeo de servidores checkline porque la comunicacion es por SMTP 3', .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 3",;
				"No se puede cambiar este valor (Entidad: Servidores de comunicaciones - Atributo: Servidorcheckline)",;
					loError.userValue.oInformacion.Item(1).cMensaje )
			finally
			endtry 
			
			.metododecomunicacion 	= 1
			try 
				.servidorehost			= .T.
				This.asserttrue( 'No deberia permitir el checkeo de servidores host porque la comunicacion es por SMTP 3', .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 3",;
				"No se puede cambiar este valor (Entidad: Servidores de comunicaciones - Atributo: Servidorehost)",;
					loError.userValue.oInformacion.Item(1).cMensaje )
			finally
			endtry 

			this.asserttrue( "No se deshabilitó el atributo Servidorehost 2", !.servidorehost )
			this.asserttrue( "No se deshabilitó el atributo Servidorcheckline 2", !.servidorcheckline )
			
		endwith
		loEntidad.release()
	endfunc


enddefine