define class InformacionAplicacion as Custom
	
	#IF .f.
		Local this as InformacionAplicacion of InformacionAplicacion.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacion() as Object
		local loInformacionAplicacion as Object
	
		loInformacionAplicacion = _screen.Zoo.CrearObjeto ( "ZooLogicSA.Core.Escalares.InformacionAplicacion" )
		
		with loInformacionAplicacion
			.VersionApp = _screen.Zoo.App.ObtenerVersion()
			.TipoDeBaseDatos = this.ObtenerMotorDB()
			.BaseDeDatos = _screen.Zoo.App.ObtenerSucursalActiva()
			.ColorBaseDatos = _screen.zoo.app.nColorBD

			.Serie = _screen.Zoo.App.cSerie
			.Usuariologueado = goServicios.Seguridad.cUsuarioLogueado
			.EstadoSeguridad = goServicios.Seguridad.ObtenerEstadoDeSeguridad() 
			
			.ModoAvanzado = goParametros.Dibujante.ModoAvanzado
			
			.NombreProducto = _screen.zoo.app.NombreProducto
			.IdentificadorCredenciales = goServicios.Librerias.ObtenerDatosDeINI( addbs( _screen.zoo.app.cRutaDataconfig ) + "Dataconfig.ini", "SQL", "NombreProducto" )
			.NombreComercialDelProducto = _screen.zoo.app.Nombre
			.NombreProyecto = _screen.zoo.app.cProyecto 
			.NombreEdicion = _screen.zoo.app.oAspectoAplicacion.ObtenerNombreEdicion()
			
			.RutaInicialAplicacion = _screen.zoo.cRutaInicial 

			.RutaDeImagenes = _screen.zoo.cRutaInicial
				
			if EsIyD()
				.RutaDeImagenes = addbs( _screen.zoo.cRutaInicial )+ ".."
			endif

		endwith
		return loInformacionAplicacion		
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMotorDB() as String
		local lcMotor as String, lcNombrePc as String, lcInstancia as String, lcServer as String, lcVersion as String, ;
			lnPosicionCorte as Integer, lcNumVersion as String
		
		goServicios.Datos.EjecutarSentencias( "select cast(@@version as char(256)) as version, cast(serverproperty ('machinename') as char(256)) as nombrePc, " +;
		"cast(serverproperty ('instancename') as char(256)) as instancia, cast(serverproperty ('servername') as char(256)) as server, " +;
		"cast(serverproperty ('productversion') as char(256)) as numVersion",;
		 "CONCEPTOS", "", "c_DatosMotor", set( "Datasession" ) ) && Usamos una tabla cualquiera para poder hacer la consulta.
		 
		 select c_DatosMotor
		 
		 scan
		 
		 	lnPosicionCorte = atc( "-", c_DatosMotor.version )
		 	lcVersion = alltrim( left( c_DatosMotor.version, lnPosicionCorte - 1 ) )
		 	lcNumVersion = alltrim( c_DatosMotor.numVersion )
		 	lcNombrePc = alltrim( c_DatosMotor.nombrePc )
		 	lcServer = alltrim( c_DatosMotor.server	)
		 	lcInstancia = iif( !isnull( c_DatosMotor.instancia ), alltrim( c_DatosMotor.instancia ), getwordnum( lcServer, 2, "\" ) )
		 	
		 	if upper( alltrim( lcNombrePc ) ) != alltrim( upper( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ) )
		 		lcMotor = lcServer + " - " + lcVersion + " (" + lcNumVersion + ")"
		 	else
		 		lcMotor = lcInstancia + " - " + lcVersion + " (" + lcNumVersion + ")"
		 	endif
		 
		 endscan
			
		return lcMotor

	endfunc 

enddefine

