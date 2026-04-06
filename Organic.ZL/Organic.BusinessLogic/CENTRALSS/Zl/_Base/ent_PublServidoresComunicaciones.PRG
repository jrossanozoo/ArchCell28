define class ent_PublServidoresComunicaciones as Din_EntidadPublServidoresComunicaciones of Din_EntidadPublServidoresComunicaciones.prg
	#if .f.
		local this as Ent_PublServidoresComunicaciones of Ent_PublServidoresComunicaciones.prg
	#endif

	cServidorDeOrigen = "Creado en carpeta local"
	cFechaPublicacion = ""
	cRutaArchivo = ""
	lConfirmaCrearZooLogicZoo = .f.
	cCarpeta = "zoo2009"
	cPrefijoCarpeta = "zoo"
	nLenPrefijo = len( this.cPrefijoCarpeta )
	oFTP = null
	lHayServidores = .f.

	*-----------------------------------------------------------------------------------------
	function EventoConfirmaCrearZooLogicZoo() as Void
		*** Para enlazar desde el Kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoArchivoCreado( tcArchivo as string ) as Void
		*** Para enlazar desde el Kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			llRetorno = this.ValidarServidoresIngresados()
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarServidoresIngresados() as Boolean
		local llRetorno as Boolean

		local loItem as object
		dodefault()
		llRetorno = .f.
		for each loItem in this.ServidoresASubir
			if !empty( loItem.Servidor_PK )
				llRetorno = .t.
				exit
			endif
		endfor

		if !llRetorno
			this.AgregarInformacion( "Falta agregar al menos un servidor de alojamiento" )
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearZooLogicZooManual() as Void
		local lcRuta as string, lcArchivo as string

		this.EventoConfirmaCrearZooLogicZoo()
		if this.lConfirmaCrearZooLogicZoo
			if !empty( this.cRutaArchivo )
				lcArchivo = this.CrearZooLogicZOO( this.cRutaArchivo )
				this.EventoArchivoCreado( lcArchivo )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DespuesDeGrabar() as Boolean
		local llNuevo as Boolean, llEdicion as Boolean, loError as zooexception of zooexception.prg

		try
			llNuevo = this.lNuevo
			llEdicion = this.lEdicion
			dodefault()
			if this.lNuevo
				store .f. to this.lNuevo, this.lEdicion
				this.Modificar()
				this.PublicarZooLogicZOO()
				this.Grabar()
			endif
		catch to loError
			throw loError
		finally
			this.lNuevo = llNuevo
			this.lEdicion = llEdicion
		endtry
		return !this.HayInformacion()
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function PublicarZooLogicZOO() as Void
		local lcArchivo as string, lcArchivoConfig as string

		lcArchivo = this.CrearZoologicZoo( _screen.Zoo.ObtenerRutaTemporal() )
		if !empty( lcArchivo ) and file( lcArchivo )
			this.SubirALosServidores( lcArchivo )
			delete file ( lcArchivo )
		endif
		
		lcArchivoConfig = this.CrearConfigBuckets( _screen.Zoo.ObtenerRutaTemporal() )
		if !empty( lcArchivoConfig ) and file( lcArchivoConfig )
			this.SubirConfig( lcArchivoConfig )
			delete file ( lcArchivoConfig )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function SubirALosServidores( tcArchivoZoo as string ) as Void
		local loItem as object
		for i = 1 to this.ServidoresASubir.count
			with this.ServidoresASubir
				.CargarItem( i )
				if !empty( .oItem.Servidor_PK )
					goLibrerias.oIni.WriteIniEntry( .oItem.Servidor.ServidorPublicacion, ;
					"Identificacion", "Servidor de Origen", tcArchivoZoo )
					this.FirmarArchivo( tcArchivoZoo )
					do case
						case .oItem.Modo = 1
							this.CopiarAServidorFTP( .oItem, tcArchivoZoo )
						case .oItem.Modo = 2
							this.CopiarAServidorLocal( .oItem, tcArchivoZoo )
						case .oItem.Modo = 3
							 this.CopiarABucket( .oItem, tcArchivoZoo )
						otherwise
							this.agregarinformacion( "El modo de subida contiene un protocolo no soportado ( Servidor: " + ;
								lower( alltrim( .oItem.Servidor.ServidorPublicacion ) ) + " - Modo: " + ;
								transform( .oItem.Servidor.ModoSubida ) + ")." )
					endcase
				endif
				.Actualizar()
			endwith
		endfor
		if this.HayInformacion()
			this.Agregarinformacion( "Hubo problemas durante la publicación" )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function SubirConfig( tcArchivo as string ) as Void
		local loItem as object
		for i = 1 to this.ServidoresASubir.count
			with this.ServidoresASubir
				.CargarItem( i )
				if !empty( .oItem.Servidor_PK )
					do case
						case .oItem.Modo = 2
	  						 this.CopiarAServidorLocal( .oItem, tcArchivo )
						case .oItem.Modo = 3
							 this.CopiarABucket( .oItem, tcArchivo )
					endcase
				endif
				.Actualizar()
			endwith
		endfor
		if this.HayInformacion()
			this.Agregarinformacion( "Hubo problemas durante la publicación" )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function CopiarAServidorFTP( toItem as object, tcArchivoZoo as string ) as Void
		local loColFTP as object, i as integer, llExiste as Boolean, lcMensaje as string, ;
			loError as object

		with this.oFtp
			if this.ConectarFTP( toItem )
				lcDestino = this.cCarpeta
				loColFTP = .GetFolderContents( "", 0 )
				llExiste = .f.
				*jbarrionuevo # 18/03/09 15:17:35 Verifica la existencia d ela carpeta en el servidor
				try
					for i = 1 to loColFTP.count
						if lower( loColFTP.item[i].ItemName ) = lower( lcDestino )
							llExiste = .t.
						endif
					endfor
					if !llExiste
						.CreateFolder( lcDestino )
					endif

					loColFTP = .GetFolderContents( "", 0 )
					for i = 1 to loColFTP.count
						if !inlist( loColFTP.item[i].ItemName, ".", ".." ) and loColFTP.item[i].ItemType = 1 ;
								and lower( left( loColFTP.item[i].ItemName, this.nlenPrefijo ) ) == lower( this.cPrefijoCarpeta )

							if .CurrentState != 0
								.SendFile( tcArchivoZoo, 0, addbs( loColFTP.item[i].ItemName ) + justfname( tcArchivoZoo ), .f. )
							else
								lcMensaje = "Se perdió la conexión con el servidor " + alltrim( toItem.Servidor.ServidorZLZ )
								this.AgregarInformacion( lcMensaje )
								toItem.Resultado = lcMensaje
								exit
							endif
						endif
					endfor

					toItem.Resultado = "OK"
				catch to loError
					toItem.Resultado = loError.message
				endtry

				if .CurrentState != 0
					this.oFtp.Disconnect()
				endif
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function ConectarFTP( toItem as object ) as Boolean
		local loError as exception

		with this.oFtp
			if .CurrentState != 0
				try
					.Disconnect()
				catch to loError
					toItem.Resultado = "No se pudo desconectar del servidor " + .ServerAddress + ". " + loError.message
					this.AgregarInformacion( "No se pudo desconectar del servidor " + .ServerAddress + ". " + loError.message )
				endtry
			endif
			if !empty( toItem.Servidor.ServidorZlZ ) and !empty( toItem.Servidor.UsuarioZlZ )
				.ServerAddress = alltrim( toItem.Servidor.ServidorZlZ )
				.UserName = alltrim( toItem.Servidor.UsuarioZlZ )
				.password = alltrim( toItem.Servidor.ContraseñaZlZ )
				try
					.connect()
					if .CurrentState = 0
						toItem.Resultado = "No se pudo conectar al servidor " + .ServerAddress
						this.agregarinformacion( "No se pudo conectar al servidor " + .ServerAddress )
					else
						if empty( toItem.Direccion )
							.ChangeCurrentFolder( "\" )
						else
							.ChangeCurrentFolder( alltrim( toItem.Direccion ) )
						endif
					endif
				catch to loError
					toItem.Resultado = "No se pudo conectar al servidor " + .ServerAddress + ". " + loError.message
					this.agregarinformacion( "No se pudo conectar al servidor " + .ServerAddress + ". " + loError.message )
				endtry
			endif
		endwith
		return this.oFtp.CurrentState != 0
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function CopiarAServidorLocal( toItem as object, tcArchivoZoo as string ) as Void
		local lcDestino as string, i as integer, lnTotal as integer, loError as object
		dimension laDir[1]

		lcDestino = addbs( alltrim( toItem.Direccion ) ) + this.cCarpeta
		try
			if !directory( lcDestino )
				mkdir ( lcDestino )
			endif

			lnTotal = adir( laDir, addbs( toItem.Direccion ) + "*.*", "D" )
			for i = 1 to lnTotal
				if lower( left( laDir[ i, 1 ], this.nlenPrefijo ) ) == lower( this.cPrefijoCarpeta ) and "D" $ upper( laDir[ i, 5 ] )
					copy file ( tcArchivoZoo ) to ( addbs( alltrim( toItem.Direccion ) ) + laDir[ i, 1 ] + "\" + justfname( tcArchivoZoo ) )
				endif
			endfor
			toItem.Resultado = "OK"
		catch to loError
			toItem.Resultado = loError.message
			this.AgregarInformacion( "No se pudo copiar al servidor local. Dirección: " + alltrim( toItem.Direccion ) )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function CopiarABucket( toItem as object, tcArchivo as string ) as Void
		local loConector as object, lcBucket as String, lcAccessKey as String, lcSecretKey as string, lcRegion as String, loRespuesta as Object
			
		try
			lcBucket = alltrim( toitem.servidor.servidorzlz )
			lcAccessKey = alltrim( toitem.servidor.usuariozlz )
			lcSecretKey = alltrim( toitem.servidor.contraseñazlz )
			lcRegion = alltrim( toitem.servidor.direccionzlz )
			loConector = _screen.zoo.crearobjeto( "ZoologicSA.S3Amazon.ConectorZL", "ZoologicSA.S3Amazon", lcAccessKey, lcSecretKey, lcRegion )	
			loRespuesta = loConector.Publicar( lcBucket, tcArchivo )
			if loRespuesta.Estado
				toItem.Resultado = "OK"
			else
				toItem.Resultado = loRespuesta.MensajeError
				this.AgregarInformacion( "No se pudo copiar al servidor local. Bucket: " + alltrim( lcBucket ) )
			endif
		catch to loError
			toItem.Resultado = loError.message
			this.AgregarInformacion( "No se pudo copiar al servidor local. Bucket: " + alltrim( lcBucket ) )
		endtry

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearZooLogicZOO( tcRuta as string ) as string
		local lcCadena as string, lcSetDate as string, lcArchivo as string, lcRetorno as string

		lcArchivo = addbs( tcRuta ) + "zoologic.zoo"
		if file( lcArchivo )
			delete file &lcArchivo
		endif
		lcSetDate = set( "Date" )
		set date british
		this.cFechaPublicacion = ttoc( goLibrerias.ObtenerFechaHora() )

		lcCadena = ""
		lcCadena = lcCadena + "[explicaciones]" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + ";;; ***********************************************************************" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + ";;; **************   No cambiar el contenido de este archivo  *************" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + ";;; ***********************************************************************" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "[DownLoad]" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Fecha de DownLoad  =" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "[Identificacion]" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor de Origen = " + alltrim( this.cServidorDeOrigen )  + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Fecha Publicacion  =" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Numero de Orden    = " + padl( this.Configuracion.Orden, 3, "0" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Firma Digital      =" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "[Servidores]" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_Status           = " + iif( !empty( this.Configuracion.Servidor1_PK ), alltrim( this.Configuracion.EstadoServidor1 ), 'Inactivo')  + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_Domain           = " + alltrim( this.Configuracion.Servidor1.Dominio ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_POP3host         = " + alltrim( this.Configuracion.Servidor1.POP3host ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_SMTPhost         = " + alltrim( this.Configuracion.Servidor1.SMTPhost ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_AnteponerUserName= " + alltrim( this.Configuracion.Servidor1.AnteponerUserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_AgregarUserName  = " + alltrim( this.Configuracion.Servidor1.AgregarUserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_AnteponerCuenta  = " + alltrim( this.Configuracion.Servidor1.AnteponerCuenta ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_AnteponerClave   = " + alltrim( this.Configuracion.Servidor1.AnteponerClave ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_SMTPAutenticacion= " + iif( !empty( this.Configuracion.Servidor1_PK ), 'Si', '' ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_SMTPAut_UserName = " + alltrim( this.Configuracion.Servidor1.SMTPAut_UserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_SMTPAut_Password = " + alltrim( this.Configuracion.Servidor1.SMTPAut_Password ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_UtilizaConfiguracionPersonalizada = NO" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_MetodoDeComunicacion = " + transform( this.Configuracion.MetodoDeComunicacion1 ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_ModoPasivo = " + icase( inlist( this.Configuracion.MetodoDeComunicacion1, 0, 1 ), "", ;
			this.Configuracion.Servidor1.ModoPasivo, "Si", ;
			"No" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_PuertoLocaldatos = " + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_DireccionLocaldatos = " + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_TipoEnvioFTP = " + icase( inlist( this.Configuracion.MetodoDeComunicacion1, 0, 1 ), "", ;
			this.Configuracion.Servidor1.TipoEnvioDeDatos = 1, "Binario", ;
			"Ascii" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor1_ControlPortServer = " + iif( this.Configuracion.MetodoDeComunicacion1 = 1 or ;
			empty( this.Configuracion.Servidor1.PuertoControlServidor ), "", ;
			transform( this.Configuracion.Servidor1.PuertoControlServidor ) ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + chr( 13 ) + chr( 10 )
********** Servidor 2
		lcCadena = lcCadena + "Servidor2_Status           = " + iif( !empty( this.Configuracion.Servidor2_PK ), alltrim( this.Configuracion.EstadoServidor2 ), 'Inactivo' ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_Domain           = " + alltrim( this.Configuracion.Servidor2.Dominio ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_POP3host         = " + alltrim( this.Configuracion.Servidor2.POP3host ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_SMTPhost         = " + alltrim( this.Configuracion.Servidor2.SMTPhost ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_AnteponerUserName= " + alltrim( this.Configuracion.Servidor2.AnteponerUserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_AgregarUserName  = " + alltrim( this.Configuracion.Servidor2.AgregarUserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_AnteponerCuenta  = " + alltrim( this.Configuracion.Servidor2.AnteponerCuenta ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_AnteponerClave   = " + alltrim( this.Configuracion.Servidor2.AnteponerClave ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_SMTPAutenticacion= " + iif( !empty( this.Configuracion.Servidor2_PK ), 'Si', '' ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_SMTPAut_UserName = " + alltrim( this.Configuracion.Servidor2.SMTPAut_UserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_SMTPAut_Password = " + alltrim( this.Configuracion.Servidor2.SMTPAut_Password ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_UtilizaConfiguracionPersonalizada = NO" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_MetodoDeComunicacion = " + transform( this.Configuracion.MetodoDeComunicacion2 ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_ModoPasivo = " + icase( inlist( this.Configuracion.MetodoDeComunicacion2, 0, 1 ), "", ;
			this.Configuracion.Servidor2.ModoPasivo, "Si", ;
			"No" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_PuertoLocaldatos = " + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_DireccionLocaldatos = " + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_TipoEnvioFTP = " + icase( inlist( this.Configuracion.MetodoDeComunicacion2, 0, 1 ), "", ;
			this.Configuracion.Servidor2.TipoEnvioDeDatos = 1, "Binario", ;
			"Ascii" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor2_ControlPortServer = " + iif( this.Configuracion.MetodoDeComunicacion2 = 1 or ;
			empty( this.Configuracion.Servidor2.PuertoControlServidor ), "", ;
			transform( this.Configuracion.Servidor2.PuertoControlServidor ) ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + chr( 13 ) + chr( 10 )
********** Servidor 3
		lcCadena = lcCadena + "Servidor3_Status           = " + iif( !empty( this.Configuracion.Servidor3_PK ), alltrim( this.Configuracion.EstadoServidor3 ), 'Inactivo' ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_Domain           = " + alltrim( this.Configuracion.Servidor3.Dominio ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_POP3host         = " + alltrim( this.Configuracion.Servidor3.POP3host ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_SMTPhost         = " + alltrim( this.Configuracion.Servidor3.SMTPhost ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_AnteponerUserName= " + alltrim( this.Configuracion.Servidor3.AnteponerUserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_AgregarUserName  = " + alltrim( this.Configuracion.Servidor3.AgregarUserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_AnteponerCuenta  = " + alltrim( this.Configuracion.Servidor3.AnteponerCuenta ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_AnteponerClave   = " + alltrim( this.Configuracion.Servidor3.AnteponerClave ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_SMTPAutenticacion= " + iif( !empty( this.Configuracion.Servidor3_PK ), 'Si', '' ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_SMTPAut_UserName = " + alltrim( this.Configuracion.Servidor3.SMTPAut_UserName ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_SMTPAut_Password = " + alltrim( this.Configuracion.Servidor3.SMTPAut_Password ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_UtilizaConfiguracionPersonalizada = NO" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_MetodoDeComunicacion = " + transform( this.Configuracion.MetodoDeComunicacion3 ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_ModoPasivo = " + icase( inlist( this.Configuracion.MetodoDeComunicacion3, 0, 1 ), "", ;
			this.Configuracion.Servidor3.ModoPasivo, "Si", ;
			"No" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_PuertoLocaldatos = " + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_DireccionLocaldatos = " + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_TipoEnvioFTP = " + icase( inlist( this.Configuracion.MetodoDeComunicacion3, 0, 1 ), "", ;
			this.Configuracion.Servidor3.TipoEnvioDeDatos = 1, "Binario", ;
			"Ascii" ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Servidor3_ControlPortServer = " + iif( this.Configuracion.MetodoDeComunicacion3 = 1 or ;
			empty( this.Configuracion.Servidor3.PuertoControlServidor ), "", ;
			transform( this.Configuracion.Servidor3.PuertoControlServidor ) ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "[URLs]" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Firma digital =" + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "Baja llaves = " + iif( this.Configuracion.BajaLlavesDelServidor, 'Si', 'No' ) + chr( 13 ) + chr( 10 )
		lcCadena = lcCadena + "" + this.AgregarUrls() + chr( 13 ) + chr( 10 )

		lcRetorno = ""
		if ( strtofile( lcCadena, lcArchivo ) > 0 )
			this.FirmarArchivo( lcArchivo )
			lcRetorno = lcArchivo
		endif

		set date &lcSetDate
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function AgregarUrls() as string
		local lcXml as string, lcCursor as string, lcRetorno as string, lnTipo as Integer, ;
			i as Integer
	
		lcRetorno = ""

		lcXml = this.Configuracion.oAD.ObtenerDatosDetalleDirecciones( "", "Codigo = " + ;
			goLibrerias.ValorAString( this.Configuracion.Orden ), "Tipo" )
		lcCursor = "c" + sys( 2015 )
		if !empty( lcXml )
			this.XmlACursor( lcXml, lcCursor )
			lcRetorno = ""
			lnTipo = 0
			scan for !empty( &lcCursor..EntDireccion )
				if lnTipo != &lcCursor..Tipo
					lnTipo = &lcCursor..Tipo
					i = 1
				endif
				do case
					case &lcCursor..Tipo = 1 && Llaves
						lcRetorno = lcRetorno + "Servidor de llaves " + transform( i ) + " = " + ;
							golibrerias.Encriptar( alltrim( &lcCursor..Direccion )) + chr( 13 ) + chr( 10 )
					case &lcCursor..Tipo = 2 && Retorno
						lcRetorno = lcRetorno + "Servidor de retornos " + transform( i ) + " = " + ;
							golibrerias.Encriptar( alltrim( &lcCursor..Direccion )) + chr( 13 ) + chr( 10 )
					case &lcCursor..Tipo = 3 && Estadísticas
						lcRetorno = lcRetorno + "Servidor de estadisticas " + transform( i ) + " = " + ;
							golibrerias.Encriptar( alltrim( &lcCursor..Direccion )) + chr( 13 ) + chr( 10 )
					case &lcCursor..Tipo = 4 && Versión
						lcRetorno = lcRetorno + "Servidor de versiones " + transform( i ) + " = " + ;
							golibrerias.Encriptar( alltrim( &lcCursor..Direccion )) + chr( 13 ) + chr( 10 )
					case &lcCursor..Tipo = 5 && Llaves/Credenciales
						lcRetorno = lcRetorno + "Servidor de llaves/credenciales " + transform( i ) + " = " + ;
							golibrerias.Encriptar( alltrim( &lcCursor..Direccion )) + chr( 13 ) + chr( 10 )
				endcase
				i = i + 1
			endscan
		endif
		use in select( lcCursor )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function FirmarArchivo( tcArchivo as string ) as string
		local lnChkSum as integer, lcChkParcial as string, lcChkSum as String

		*jbarrionuevo # 06/03/09 11:41:21 Se utiliza el objeto oINI de goLibrerias en lugar de los métodos
		*jbarrionuevo # 06/03/09 11:41:21 para leer y escribir de goLibrerias, por compatibilidad con ZooLogic.

		goLibrerias.oIni.WriteIniEntry(this.cFechaPublicacion,"Identificacion","Fecha Publicacion",tcArchivo)
		lnChkSum=0
		lcChkParcial=""
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Identificacion","Servidor de Origen",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*5)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*33)+(asc(left(lcChkParcial,1))*52)+64256)/6.1)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Identificacion","Fecha Publicacion",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*3)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*54)+(asc(left(lcChkParcial,1))*22)+55441)/3.3)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Identificacion","Numero de Orden",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*2)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*94)+(asc(left(lcChkParcial,1))*31)+54631)/4.4)

		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_Status",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*7)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*43)+(asc(left(lcChkParcial,1))*64)+54531)/5.5)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_Domain",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*8)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*38)+(asc(left(lcChkParcial,1))*24)+12541)/6.6)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_POP3host",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*9)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*67)+(asc(left(lcChkParcial,1))*28)+57641)/7.7)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_SMTPhost",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*5)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*12)+(asc(left(lcChkParcial,1))*15)+32457)/8.9)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_AnteponerUserName",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*3)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*78)+(asc(left(lcChkParcial,1))*76)+85141)/3.4)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_AgregarUserName",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*2)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*64)+(asc(left(lcChkParcial,1))*65)+89214)/5.9)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor1_AnteponerCuenta",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*7)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*74)+(asc(left(lcChkParcial,1))*72)+85872)/9.2)


		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_Status",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*4)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*43)+(asc(left(lcChkParcial,1))*77)+65478)/2.5)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_Domain",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*5)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*38)+(asc(left(lcChkParcial,1))*66)+45678)/7.6)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_POP3host",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*7)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*67)+(asc(left(lcChkParcial,1))*55)+45056)/5.7)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_SMTPhost",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*7)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*12)+(asc(left(lcChkParcial,1))*44)+45655)/3.9)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_AnteponerUserName",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*5)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*78)+(asc(left(lcChkParcial,1))*33)+12322)/1.4)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_AgregarUserName",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*3)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*64)+(asc(left(lcChkParcial,1))*22)+45685)/2.9)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor2_AnteponerCuenta",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*4)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*74)+(asc(left(lcChkParcial,1))*11)+89799)/9.7)


		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_Status",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*8)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*25)+(asc(left(lcChkParcial,1))*77)+54665)/6.3)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_Domain",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*7)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*34)+(asc(left(lcChkParcial,1))*66)+45448)/5.4)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_POP3host",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*6)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*66)+(asc(left(lcChkParcial,1))*55)+56356)/4.5)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_SMTPhost",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*5)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*11)+(asc(left(lcChkParcial,1))*44)+45563)/3.6)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_AnteponerUserName",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*4)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*76)+(asc(left(lcChkParcial,1))*33)+12777)/2.7)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_AgregarUserName",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*5)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*60)+(asc(left(lcChkParcial,1))*22)+45888)/1.8)
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"Servidores","Servidor3_AnteponerCuenta",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*6)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*70)+(asc(left(lcChkParcial,1))*11)+89999)/2.9)
		lcChkSum=alltrim(str(lnChkSum))
		goLibrerias.oIni.WriteIniEntry(lcChkSum,"Identificacion","Firma Digital",tcArchivo)

		* Firma digital 2 --------------------------------------------------------------------
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"URLs","Baja llaves",tcArchivo)
		lcChkParcial=alltrim(lcChkParcial)
		lnChkSum=lnChkSum+int(((len(alltrim(lcChkParcial))*6)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*70)+(asc(left(lcChkParcial,1))*11)+89999)/2.9)

		lnChkSum = lnChkSum + this.AcumularChkSumURLs( "Servidor de llaves ", tcArchivo )
		lnChkSum = lnChkSum + this.AcumularChkSumURLs( "Servidor de retornos ", tcArchivo )
		lnChkSum = lnChkSum + this.AcumularChkSumURLs( "Servidor de estadisticas ", tcArchivo )
		lnChkSum = lnChkSum + this.AcumularChkSumURLs( "Servidor de versiones ", tcArchivo )
	
		goLibrerias.oIni.WriteIniEntry(transform(lnChkSum),"URLs","Firma Digital",tcArchivo)
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AcumularChkSumURLs( tcPrefijo as String, tcArchivo as String ) as Integer
		local i as Integer, lcChkParcial as String, lnChkSumUrls as Integer 
		
		i = 1
		lcChkParcial = ""
		lnChkSumUrls = 0
		goLibrerias.oIni.GetIniEntry(@lcChkParcial,"URLs",tcPrefijo + transform( i ),tcArchivo)
		
		if !empty( lcChkParcial )
			lnChkSumUrls=lnChkSumUrls+int(((len(alltrim(lcChkParcial))*6)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*70)+(asc(left(lcChkParcial,1))*11)+89999)/2.9)		

			do while !empty( lcChkParcial )
				i = i + 1
				lcChkParcial = ""
				goLibrerias.oIni.GetIniEntry(@lcChkParcial,"URLs",tcPrefijo + transform( i ),tcArchivo)
				lcChkParcial=alltrim(lcChkParcial)
				lnChkSumUrls=lnChkSumUrls+int(((len(alltrim(lcChkParcial))*6)+val(sys(2007,lcChkParcial))+(asc(left(lcChkParcial,1))*70)+(asc(left(lcChkParcial,1))*11)+89999)/2.9)
			enddo
		endif 
				
		return lnChkSumUrls
	endfunc 
	*-----------------------------------------------------------------------------------------
	function oFTP_access() as Void
		if !this.ldestroy and ( vartype( this.oFTP ) != 'O' or isnull( this.oFTP ) )
			this.oFtp = newobject( "XceedSoftware.XceedFtp.1" )
			if !this.oFTP.License( "FTP11-2RMNZ-UZCN1-AYYA" )
				local loex as exception

				loex = newobject(  "zooexception", "zooexception.prg" )
				with loex
					.message = "La licencia para acceso FTP de Xceed Software no es válida"
					.details = .message
					.grabar()
					.throw()
				endwith
			endif
		endif
		return this.oFTP
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function SetearValoresSugeridos() as void
		dodefault()
		with this
			if .EsNuevo()
				.ValorSugeridoServidoresASubir()
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValorSugeridoServidoresASubir() as Void
		local lcXml as String, lcCursor as String, lnPublicacion as Integer
		
		if this.oAd.HayDatos()
			lcXml = this.oAD.ObtenerDatosEntidad( "Codigo", "", "", "max" )
			lcCursor = "c" + sys( 2015 )
			this.XmlACursor( lcXml, lcCursor )
			lnPublicacion = &lcCursor..Max_Codigo
			use in select( lcCursor )
			lcXml = this.oAD.ObtenerDatosDetalleServidoresASubir( "Servidor", "Codigo = " + ;
				transform( lnPublicacion ) )
			this.XmlACursor( lcXml, lcCursor )
			scan for !empty( &lcCursor..Servidor )
				this.ServidoresASubir.LimpiarItem()
				this.ServidoresASubir.oItem.Servidor_PK = &lcCursor..Servidor
				this.ServidoresASubir.Actualizar()
			endscan
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CrearConfigBuckets( tcRuta as string ) as String
		local lcArchivo as String, lcRetorno as String, lcConfig as String 
		  
		lcRetorno = ""
		lcArchivo = addbs( tcRuta ) + "config.json"
		if file( lcArchivo )
			delete file &lcArchivo
		endif
		  
		lcConfig = this.ObtenerConfig()
			
		if !empty( lcConfig ) and ( strtofile( lcConfig, lcArchivo ) > 0 )
			lcRetorno = lcArchivo
		endif

		return lcRetorno
	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerConfig() as String
		local lcBucket as String, lcRegion as String, lcAccessKey as String, lcSecretKey as String, lcBucketBajada as String, lcRegionBajada as String, ;
		      lcAccessKeyBajada as String, lcSecretKeyBajada as String, lcPropiedad as string, lnServidorBucket as Integer, lnServidorBucketBajada as Integer, lcConfig as string
		      
		lcbucket = ""
		lcRegion = ""
		lcAccessKey = ""
		lcSecretKey = ""
		lcRole = ""
		lcBucketBajada = ""
		lcRegionBajada = ""
		lcAccessKeyBajada = ""
		lcSecretKeyBajada = ""
		lcRoleBajada = ""
		
		lnServidorBucket = this.ObtenerNumeroSevidorBucket()	  
		if !empty( lnServidorBucket )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucket ) ) + ".Bucket"
			lcBucket = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucket ) ) + ".Region"
			lcRegion = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucket ) ) + ".AccessKey"
			lcAccessKey = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucket ) ) + ".SecretKey"
			lcSecretKey = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucket ) ) + ".Role"
			lcRole = alltrim( &lcPropiedad )
		endif
		
		lnServidorBucketBajada = this.ObtenerNumeroSevidorBucketBajada()	  
		if !empty( lnServidorBucketBajada )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucketBajada ) ) + ".Bucket"
			lcBucketBajada = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucketBajada ) ) + ".Region"
			lcRegionBajada = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucketBajada ) ) + ".AccessKey"
			lcAccessKeyBajada = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucketBajada ) ) + ".SecretKey"
			lcSecretKeyBajada = alltrim( &lcPropiedad )
			lcPropiedad = "this.Configuracion.Servidor" + alltrim( str( lnServidorBucketBajada ) ) + ".Role"
			lcRoleBajada = alltrim( &lcPropiedad )
		endif
		
		*if !empty( lnServidorBucketBajada ) or !empty( lnServidorBucket )
		
			text to lcConfig textmerge
{
  "bucket": "<<lcBucket>>",
  "endpoint": "<<lcRegion>>",
  "accesKey": "<<lcAccessKey >>",
  "secretkey": "<<lcSecretKey >>",
  "role": "<<lcRole>>",
  "bucketBajada": "<<lcBucketBajada>>",
  "endpointBajada": "<<lcRegionBajada>>",
  "accesKeyBajada": "<<lcAccessKeyBajada>>",
  "secretkeyBajada": "<<lcSecretKeyBajada>>",
  "roleBajada": "<<lcRoleBajada>>" 
}
			endtext
		*endif

		return lcConfig
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroSevidorBucket() as integer
		local lnRetorno as integer
		
		if this.Configuracion.Servidor1.MetodoDeComunicacion = 3 and alltrim( upper( this.Configuracion.EstadoServidor1 ) ) = "ACTIVO"
			lnRetorno = 1
		endif		
		if this.Configuracion.Servidor2.MetodoDeComunicacion = 3 and alltrim( upper( this.Configuracion.EstadoServidor2 ) ) = "ACTIVO"
			lnRetorno = 2
		endif		
		if this.Configuracion.Servidor3.MetodoDeComunicacion = 3 and alltrim( upper( this.Configuracion.EstadoServidor3 ) ) = "ACTIVO"
			lnRetorno = 3
		endif
		
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroSevidorBucketBajada() as integer
		local lnRetorno as integer
		
		if this.Configuracion.Servidor1.MetodoDeComunicacion = 3 and alltrim( upper( this.Configuracion.EstadoServidor1 ) ) = "BAJA"
			lnRetorno = 1
		endif		
		if this.Configuracion.Servidor2.MetodoDeComunicacion = 3 and alltrim( upper( this.Configuracion.EstadoServidor2 ) ) = "BAJA"
			lnRetorno = 2
		endif		
		if this.Configuracion.Servidor3.MetodoDeComunicacion = 3 and alltrim( upper( this.Configuracion.EstadoServidor3 ) ) = "BAJA"
			lnRetorno = 3
		endif
		
		return lnRetorno
	endfunc

enddefine
