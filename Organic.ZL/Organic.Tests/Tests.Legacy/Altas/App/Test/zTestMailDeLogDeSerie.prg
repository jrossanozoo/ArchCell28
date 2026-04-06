**********************************************************************
Define Class zTestMailDeLogDeSerie as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestMailDeLogDeSerie of zTestMailDeLogDeSerie.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestCargarYBindeos
		local loMailDeLog as Object, loAdjunto as Object, i as Integer, lnCodigoAdjunto as Integer
		
		This.Agregarmocks( "SerieV2" )
		_screen.mocks.AgregarSeteoMetodo( 'SerieV2', 'Validarnroserie', .T., "[105605]" )
		_screen.mocks.AgregarSeteoMetodo( 'SerieV2', 'Actualizarclaveyactivacion', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'seriev2', 'Limpiarinformacion', .T. )
		loMailDeLog = _screen.zoo.instanciarentidad( "MailDeLogDeSerie" )
		loAdjunto = _screen.zoo.instanciarentidad( "Adjunto" )

		with loMailDeLog
			.Nuevo()
			.FechaHora = dtoc( date() )
			.De = "de"
			.Asunto = "asunto"
			.Para = "para"
			.Cuerpo = "cuerpo"
			.Serie_pk = "105605"
			.VersionDeEHost = "12346"
			.VersionZoologicZoo = "63251"
			
			for i = 1 to 5
				with loAdjunto
					.Nuevo()
					.Nombre = transform( i )
					.Texto = replicate( transform( i ), 10 )
					.Grabar()
					lnCodigoAdjunto = loAdjunto.Codigo
				endwith
				with .Adjuntos
					.LimpiarItem()
					.oItem.Adjunto_pk = lnCodigoAdjunto
					.Actualizar()
				endwith
			endfor
			
			.Grabar()
			.Ultimo()
			
			this.assertequals( "El contenido del adjunto es incorrecto 1", "1111111111", alltrim( .DetalleAdjunto ) )
			.Adjuntos.CargarItem( 2 )
			this.assertequals( "El contenido del adjunto es incorrecto 2", "2222222222", alltrim( .DetalleAdjunto ) )
			.Adjuntos.CargarItem( 3 )
			this.assertequals( "El contenido del adjunto es incorrecto 3", "3333333333", alltrim( .DetalleAdjunto ) )
			.Adjuntos.CargarItem( 4 )
			this.assertequals( "El contenido del adjunto es incorrecto 4", "4444444444", alltrim( .DetalleAdjunto ) )
			.Adjuntos.CargarItem( 5 )
			this.assertequals( "El contenido del adjunto es incorrecto 5", "5555555555", alltrim( .DetalleAdjunto ) )
		endwith		
				
		loMailDeLog.Release()
		loAdjunto.Release()
	endfunc 

EndDefine
