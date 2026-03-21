**********************************************************************
Define Class zTestComportamientoCodigoSugeridoEntidad as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestComportamientoCodigoSugeridoEntidad of zTestComportamientoCodigoSugeridoEntidad.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function zTestU_CargarAnchoDisponible
		local loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg, lcEntidad as String 	

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )

		with loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
			.Nuevo()
			.Entidad = "CLIENTE"
			this.assertequals( "El ancho disponible no es el correcto.", 5, .AnchoDisponible )
			.release()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CargarDescripcionDeEntidad
		local loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg, lcEntidad as String 	

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )

		with loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
			.Nuevo()
			.Entidad = "CLIENTE"
			this.assertequals( "La descripción de la entidad no es correcta.", "Cliente", .DescripcionDeLaEntidad )
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarAnchoASugerir
		local loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg, ;
			loInformacion as zooinformacion of zooInformacion.prg

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )


		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg

			.Nuevo()
			.Entidad = "CLIENTE"
			.AnchoDisponible = 6

			.AnchoASugerir = 5
			this.asserttrue( "Debería ser válido 1.", .ValidacionBasica() )
			.AnchoASugerir = 6
			this.asserttrue( "Debería ser válido 2.", .ValidacionBasica() )
			
			.AnchoASugerir = 0
			this.asserttrue( "Debería ser inválido 1.", !.ValidacionBasica() )
			loInformacion = .ObtenerInformacion()
			this.assertequals( "El mensaje de error no es el correcto 1.", "El ancho a sugerir debe ser mayor a cero.", loInformacion( 1 ).cMensaje )
			
			loInformacion.Remove( -1 )
			try
				.AnchoASugerir = 7
				this.asserttrue( "Debería ser inválido 2.", !.ValidacionBasica() )
			catch to loError
				this.assertequals( "El mensaje de error no es el correcto 2.", "El ancho a sugerir no puede ser mayor al ancho disponible.",;
				loError.UserValue.oInformacion.Item( 1 ).cMensaje )
			endtry

		
			.Release()
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarAnchoASugerirConPrefijoEntidad
		local loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg, ;
			loInformacion as zooinformacion of zooInformacion.prg

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )

		goServicios.Registry.Nucleo.MensajeErrorCuandoNoSePuedeHacerVistaPrevia = "ERROR ANCHO"

		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )

		loObjectoAtrapaEvento = newobject( "objetoMock" )
		with loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
			.Nuevo()
			.Entidad = "CLIENTE"
			.AnchoDisponible = 6
			.AnchoASugerir = 3

			bindevent( loEntidad, "EventoCodigoSugeridoConError", loObjectoAtrapaEvento, "BindeoAEventoCodigoNoValido" , 1 )
			bindevent( loEntidad, "EventoCodigoSugeridoValido", loObjectoAtrapaEvento, "BindeoAEventoCodigoValido" , 1 )

			goParametros.Nucleo.PrefijoBaseDeDatos = "EN"
			.PrefijoEntidad = "E"
			.UsarPrefijoBaseDeDatos = .T.
		
			This.asserttrue( "No se ejecuto el evento EventoCodigoSugeridoConError", loObjectoAtrapaEvento.lSeEjecutoElEvento )
			This.assertequals( "El valor del atributo vista previa no es el correcto.", "ERROR ANCHO", alltrim( loEntidad.vistaPrevia ) )

			.AnchoASugerir = 4
			This.asserttrue( "No se ejecuto el evento EventoCodigoSugeridoValido", loObjectoAtrapaEvento.lSeEjecutoElEventoValido )

			loObjectoAtrapaEvento = null
			.Release()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_BlanquearYDeshabilitarOpcionesAlDesseleccionarSugerir
		local loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
			.Sugerir = .t.
			.AnchoDisponible = 1
			.UsarPrefijoBaseDeDatos = .t.
			.AnchoASugerir = 1
			.BusquedaExtendida = .t.
			
			.Sugerir = .f.

			this.assertequals( "El valor de la propiedad UsarPrefijoBaseDeDatos no es correcto.", .f., .UsarPrefijoBaseDeDatos )
			this.assertequals( "El valor de la propiedad AnchoASugerir no es correcto.", 0, .AnchoASugerir )
			this.assertequals( "El valor de la propiedad BusquedaExtendida no es correcto.", .f., .BusquedaExtendida )
			
			this.assertequals( "El valor de la propiedad lHabilitarUsarPrefijoBaseDeDatos no es correcto.", .f., .lHabilitarUsarPrefijoBaseDeDatos )
			this.assertequals( "El valor de la propiedad lHabilitarAnchoASugerir no es correcto.", .f., .lHabilitarAnchoASugerir )
			this.assertequals( "El valor de la propiedad lHabilitarBusquedaExtendida no es correcto.", .f., .lHabilitarBusquedaExtendida )
			.release()
		endwith
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_HabilitarOpcionesAlSeleccionarSugerir
		local loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		loEntidad.Sugerir = .f.
		loEntidad.lHabilitarUsarPrefijoBaseDeDatos = .t.
		loEntidad.lHabilitarAnchoASugerir = .t.
		loEntidad.lHabilitarBusquedaExtendida = .t.
		
		loEntidad.Sugerir = .t.

		this.asserttrue( "El valor de la propiedad lHabilitarUsarPrefijoBaseDeDatos no es correcto.", loEntidad.lHabilitarUsarPrefijoBaseDeDatos )
		this.assertequals( "El valor de la propiedad lHabilitarAnchoASugerir no es correcto.", .t., loEntidad.lHabilitarAnchoASugerir )
		this.assertequals( "El valor de la propiedad lHabilitarBusquedaExtendida no es correcto.", .t., loEntidad.lHabilitarBusquedaExtendida )

		loEntidad.release()
	endfunc


	*-------------------------------------------------------------------------------------------
	function zTestU_AsignarVistaPreviaDespuesDeSetearAtributos
		local loEntidad as entidad OF entidad.prg, lcCodigoFormateadoSugerido as String 	

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )

		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )

		goServicios.Registry.Nucleo.NumeroVistaPreviaCodigoSugerido = 8

		with loEntidad as Ent_ComportamientoCodigoSugeridoEntidad of Ent_ComportamientoCodigoSugeridoEntidad.prg
			.Nuevo()
			.Entidad = "CLIENTE"
			.Sugerir = .t.
			.UsarPrefijoBaseDeDatos = .T.
			.AnchoDisponible = 6
			goParametros.Nucleo.PrefijoBaseDeDatos = "PLO"
			.AnchoASugerir = 6

			This.assertequals( "El codigo formateado no es el correcto.", "PLO008", upper( alltrim( .VistaPrevia ) ) )

			.PrefijoEntidad = "I"
			This.assertequals( "El codigo formateado no es el correcto despues de setear prefijo base de datos.", "PLOI08", upper( alltrim( .VistaPrevia ) ) )

			.PrefijoEntidad = "I"
			This.assertequals( "El codigo formateado no es el correcto despues de setear prefijo Base de datos.", "PLOI08", upper( alltrim( .VistaPrevia ) ) )

			.UsarPrefijoBaseDeDatos = .f.
			This.assertequals( "El codigo formateado no es el correcto despues de setear prefijo Prefijo de Base de Datos.", "I00008", upper( alltrim( .VistaPrevia ) ) )

			.AnchoASugerir = 4
			This.assertequals( "El codigo formateado no es el correcto despues de setear prefijo Ancho a Sugerir.", "I008", upper( alltrim( .VistaPrevia ) ) )

			.Release()
		endwith

	endfunc 	

	
	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerCodigoSugerido
		local loCliente as din_entidadCliente of din_entidadCliente.prg, loEntidad as entidad OF entidad.prg

		goServicios.Datos.EjecutarSentencias( "Delete from cli", "Cli", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		goParametros.Nucleo.PrefijoBaseDeDatos = ""
	
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "CLIENTE"
				.Buscar()
				.Cargar()
				.Modificar()
			catch 
				.Nuevo()
				.Entidad = "CLIENTE"
			endtry			
			.Sugerir = .t.
			.AnchoASugerir = 5
			.UsarPrefijoBaseDeDatos = .f.
			.Grabar()
		endwith

		loCliente = _screen.zoo.instanciarentidad( "Cliente" )
		with loCliente as din_entidadCliente of din_entidadCliente.prg
			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "00001", alltrim( .Codigo ) ) 
			.Cancelar()
			.Release()
		endwith
		
		loEntidad.Modificar()
		loEntidad.UsarPrefijoBaseDeDatos = .t.
		loEntidad.Grabar()
		loEntidad.Release()
		goParametros.Nucleo.PrefijoBaseDeDatos = "SUC"
		loCliente = _screen.zoo.instanciarentidad( "Cliente" )

		with loCliente as din_entidadCliente of din_entidadCliente.prg
			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "SUC01", alltrim( .Codigo ) ) 
			.Nombre = "NOM1"
			.Grabar()
			
			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "SUC02", alltrim( .Codigo ) ) 
			.Nombre = "NOM2"
			.Grabar()
			
			.Nuevo()
			.Codigo = "SUC04"
			.Nombre = "NOM4"
			.Grabar()

			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "SUC03", alltrim( .Codigo ) ) 
			.Release()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerCodigoSugeridoConMenorAnchoQueElDisponible
		local loCliente as din_entidadCliente of din_entidadCliente.prg, loEntidad as entidad OF entidad.prg

		goServicios.Datos.EjecutarSentencias( "Delete from cli", "Cli", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		goParametros.Nucleo.PrefijoBaseDeDatos = ""
	
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "CLIENTE"
				.Buscar()
				.Cargar()
				.Modificar()
			catch 
				.Nuevo()
				.Entidad = "CLIENTE"
			endtry			
			.Sugerir = .t.
			.AnchoASugerir = 4
			.Grabar()
		endwith

		loCliente = _screen.zoo.instanciarentidad( "Cliente" )
		with loCliente as din_entidadCliente of din_entidadCliente.prg
			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "0001", alltrim( .Codigo ) ) 
			.Cancelar()
			

			loEntidad.Modificar()
			loEntidad.UsarPrefijoBaseDeDatos = .t.
			loEntidad.Grabar()
			loEntidad.Release()
			goParametros.Nucleo.PrefijoBaseDeDatos = "SUC"


			.Inicializar()
			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "SUC1", alltrim( .Codigo ) ) 
			.Nombre = "NOM1"
			.Grabar()
			
			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "SUC2", alltrim( .Codigo ) ) 
			.Nombre = "NOM2"
			.Grabar()
			
			.Nuevo()
			.Codigo = "SUC04"
			.Nombre = "NOM4"
			.Grabar()

			.Nuevo()
			This.assertequals( "El codigo de cliente no es el correcto.", "SUC3", alltrim( .Codigo ) ) 
			.Release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerCodigoSugeridoConSaltoDeCampos
		local loMALTA as din_entidadMALTA of din_entidadMALTA.prg, loMALTA1 as din_entidadMALTA of din_entidadMALTA.prg

		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "MALTA"
				.Buscar()
				.Cargar()
				.Modificar()
			catch 
				.Nuevo()
				.Entidad = "MALTA"
			endtry			
			.Sugerir = .t.
			.Salta = .t.
			.Grabar()
			.Release()
		endwith

		loMALTA = _screen.zoo.Instanciarentidad( "MALTA" )
		loMALTA.Nuevo()

		loMALTA1 = _screen.zoo.Instanciarentidad( "MALTA" )
		loMALTA1.Nuevo()

		loMALTA.Grabar()
		This.assertequals( "El codigo MALTA no se grabo correctamente.", "00001", loMALTA.Codigo )

		loMALTA1.Grabar()
		This.assertequals( "El codigo MALTA no se grabo correctamente.", "00002", loMALTA1.Codigo )

		loMALTA.Release()
		loMALTA1.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestI_BusquedaEnSubEntidadConSoporteParaBusquedaExtendida
		local loEntidad as entidad OF entidad.prg, loRio as entidad OF entidad.prg, lcCodigoMalta as String
		
		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "MALTA"
				.Buscar()
				.Cargar()
				.Modificar()
			catch 
				.Nuevo()
				.Entidad = "MALTA"
			endtry			
			.Sugerir = .t.
			.BusquedaExtendida = .t.		
			.Grabar()
		endwith

		loMalta = _screen.zoo.instanciarentidad( "Malta" )
		loMalta.Nuevo()
		loMalta.Grabar()
		
		loRio = _screen.zoo.instanciarentidad( "Rio" )
		loRio.Nuevo()

		try
			loRio.Malta_pk = alltrim( str( val( loMalta.Codigo ) ) ) 
			this.assertequals( "El codigo buscado en malta no coincide con el cargado en malta.", alltrim( loMalta.Codigo), alltrim( loRio.Malta_Pk ) )
		catch to loError
			this.asserttrue( "Debio haber encontrado el codigo de malta con busqueda extendida.", .f. )
		endtry
		
		loEntidad.Release()
		loMalta.Release()
		loRio.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestI_ztestI_BusquedaEnSubEntidadSinSoporteParaBusquedaExtendida
		local loEntidad as entidad OF entidad.prg, loRio as entidad OF entidad.prg, lcCodigoMalta as String , ;
			loError as Exception
		
		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "MALTA"
				.Buscar()
				.Cargar()
				.Modificar()
				
			catch 
				.Nuevo()
				.Entidad = "MALTA"
			endtry			
			.Sugerir = .t.
			.BusquedaExtendida = .f.		
			.Grabar()
		endwith

		loMalta = _screen.zoo.instanciarentidad( "Malta" )
		loMalta.Nuevo()
		loMalta.Grabar()
		
		loRio = _screen.zoo.instanciarentidad( "Rio" )
		loRio.Nuevo()
		
		try
			loRio.Malta_pk = alltrim( str( val( loMalta.Codigo ) ) )
			this.asserttrue( "No debio haber encontrado el codigo.", .F. )
		catch to loError 
			this.assertequals( "El mensaje de error no es correcto.", "El dato buscado 1 de la entidad MALTA no existe.", loError.userValue.oInformacion.item( 1 ).cMensaje )
		endtry
		
		loEntidad.Release()
		loMalta.Release()
		loRio.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestI_MensajeFalloBusquedaEnSubEntidadConSoporteParaBusquedaExtendida
		local loEntidad as entidad OF entidad.prg, loRio as entidad OF entidad.prg, lcCodigoMalta as String , ;
			loError as Exception
		
		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "MALTA"
				.Buscar()
				.Cargar()
				.Modificar()
			catch 
				.Nuevo()
				.Entidad = "MALTA"
			endtry			
			.Sugerir = .t.
			.BusquedaExtendida = .t.		
			.Grabar()
		endwith
		
		loRio = _screen.zoo.instanciarentidad( "Rio" )
		loRio.Nuevo()
		
		try
			loRio.Malta_pk = "1"
			this.asserttrue( "No debio haber encontrado el codigo.", .F. )
		catch to loError 
			this.assertequals( "El mensaje de error no es correcto.", "El dato buscado 1 de la entidad MALTA no existe.", loError.userValue.oInformacion.item( 1 ).cMensaje )
		endtry
		
		loEntidad.Release()
		loRio.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SoportaBusquedaSugerida
		local loMalta as entidad OF entidad.prg
		This.agregarmocks( "ComportamientoCodigoSugeridoEntidad" )

		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Cargamanual', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Cargaranchodisponible', 5 ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Cargamanual', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Cargaranchoasugerir', 5 ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Buscar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Cargar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Esedicion', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Anchoasugerir_despuesdeasignar', .T. )
		_screen.mocks.agregarseteopropiedad( 'comportamientocodigosugeridoentidad', 'Sugerir', .T. ) 
		_screen.mocks.agregarseteopropiedad( 'comportamientocodigosugeridoentidad', 'BusquedaExtendida', .T. ) 		

		_screen.mocks.AgregarSeteoMetodo( 'comportamientocodigosugeridoentidad', 'Sugerir_despuesdeasignar', .T. ) 

		loMalta = _screen.zoo.instanciarentidad( "Malta" )
		llRetorno = loMalta.SoportaBusquedaExtendida()
		
		This.Asserttrue( "No soporta busqueda extendida.", llRetorno ) 

		loMalta.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestI_MensajeFalloBusquedaEnEntidadConClaveSugerida
		local loEntidad as entidad OF entidad.prg, loCliente as entidad OF entidad.prg
		
		goServicios.Datos.EjecutarSentencias( "Delete from cli", "cli", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "CLIENTE"
				.Buscar()
				.Cargar()
				.Modificar()
				
			catch 
				.Nuevo()
				.Entidad = "CLIENTE"
			endtry			
			.Sugerir = .t.
			.BusquedaExtendida = .t.		
			.Grabar()
		endwith
		
		loCliente = _screen.zoo.instanciarentidad( "CLIENTE" )
		
		try
			loCliente.Codigo = "1"
			this.asserttrue( "No debio haber encontrado el codigo.", .F. )
		catch to loError 
			this.assertequals( "El mensaje de error no es correcto.", "El dato buscado 1 de la entidad CLIENTE no existe.", loError.userValue.oInformacion.item( 1 ).cMensaje )
		endtry
		
		loEntidad.Release()
		loCliente.Release()		
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_BusquedaEnEntidadConClaveSugerida
		local loEntidad as entidad OF entidad.prg, loCliente as entidad OF entidad.prg
		
		goServicios.Datos.EjecutarSentencias( "Delete from cli", "cli", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
		
		loEntidad = _screen.Zoo.InstanciarEntidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as din_ComportamientoCodigoSugeridoEntidad of din_ComportamientoCodigoSugeridoEntidad.prg
			try
				.Entidad = "CLIENTE"
				.Buscar()
				.Cargar()
				.Modificar()
				
			catch 
				.Nuevo()
				.Entidad = "CLIENTE"
			endtry			
			.Sugerir = .t.
			.AnchoASugerir = 5
			.BusquedaExtendida = .t.		
			.Grabar()
		endwith
		
		loCliente = _screen.zoo.instanciarentidad( "CLIENTE" )
		loCliente.Nuevo()
		loCliente.Nombre = "NOM1"
		loCliente.Grabar()
		
		try
			loCliente.Codigo = "1"
			this.assertequals( "El codigo recuperado no es el correcto." , "00001", alltrim( loCliente.Codigo ) )
			this.assertequals( "El codigo recuperado no es el correcto." , "NOM1", alltrim( loCliente.Nombre ) )
		catch to loError 
			this.asserttrue( "Fallo la busqueda con clave sugerida." )
		endtry
		
		loEntidad.Release()
		loCliente.Release()		
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_InicializarComportamientoCodigoSugeridoDesactivado
		local loMalta as entidad OF entidad.prg, loEntidad as ent_ComportamientoCodigoSugeridoEntidad OF ent_ComportamientoCodigoSugeridoEntidad.prg

		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		try
			loEntidad.Entidad = "MALTA"
			loEntidad.Eliminar()
		catch
		endtry

		loMalta = _screen.zoo.instanciarentidad( "Malta" )
		loMalta.Nuevo()

		this.assertequals( "No seteo correctamente el valor de Sugerir", .f., loMalta.oComportamientoCodigoSugerido.Sugerir )
		this.assertequals( "No seteo correctamente el valor de AnchoASugerir", 5, loMalta.oComportamientoCodigoSugerido.AnchoASugerir )
		this.assertequals( "No seteo correctamente el valor de UsarPrefijoBaseDeDatos", .f., loMalta.oComportamientoCodigoSugerido.UsarPrefijoBaseDeDatos )

		loMalta.Release()

		*---------------------------------------------------
		loEntidad.Nuevo()
		loEntidad.Entidad = "MALTA"
		loEntidad.Sugerir = .t.
		loEntidad.AnchoASugerir = 2
		loEntidad.Grabar()

		loMalta = _screen.zoo.instanciarentidad( "Malta" )
		loMalta.Nuevo()

		this.assertequals( "No seteo correctamente el valor de Sugerir cargado en la entidad comportamiento", .t., loMalta.oComportamientoCodigoSugerido.Sugerir )
		this.assertequals( "No seteo correctamente el valor de AnchoASugerir cargado en la entidad comportamiento", 2, loMalta.oComportamientoCodigoSugerido.AnchoASugerir )

		loEntidad.Release()
		loMalta.Release()

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_InicializarComportamientoCodigoSugeridoActivadoConPrefijoDeBaseDeDatosActivado
		local loBolivia as entidad OF entidad.prg, loEntidad as Din_EntidadComportamientoCodigoSugeridoEntidad of Din_entidadComportamientoCodigoSugeridoEntidad.prg

		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		try
			loEntidad.Entidad = "BOLIVIA"
			loEntidad.Eliminar()
		catch 
		endtry

		loBolivia = _screen.zoo.instanciarentidad( "BOLIVIA" )
		loBolivia.Nuevo()

		this.asserttrue( "El comportamiento PrefijoDeBaseDeDatos debería estar activado.", ;
			loBolivia.oComportamientoCodigoSugerido.UsarPrefijoBaseDeDatos )

		loBolivia.ReleasE()
		
		*---------------------------------------------------
		loEntidad.Nuevo()
		loEntidad.Entidad = "BOLIVIA"
		loEntidad.UsarPrefijoBaseDeDatos = .f.
		loEntidad.Grabar()
		
		loBolivia = _screen.zoo.instanciarentidad( "BOLIVIA" )
		loBolivia.Nuevo()

		this.asserttrue( "El comportamiento PrefijoDeBaseDeDatos debería estar desactivado por estar cargado en la entidad comportamiento.", ;
			!loBolivia.oComportamientoCodigoSugerido.UsarPrefijoBaseDeDatos )

		loBolivia.Release()
		loEntidad.Release()

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_BusquedaDeCodigoSugeridoEnDetalle
		local loEntidad as entidad OF entidad.prg, loMalta as entidad OF entidad.prg, loJava as entidad OF entidad.prg

		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as entidad OF entidad.prg
			try
				.Entidad = "MALTA"
				.Buscar()
				.Cargar()
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.Entidad = "MALTA"
			.Grabar()
			.Release()
		endwith		

		loMalta = _screen.zoo.instanciarentidad( "Malta" )
		with loMalta as entidad OF entidad.prg
			try
				.Codigo = "1"
				.Eliminar()
			catch 
			endtry
	
			loMalta.Nuevo()
			loMalta.Codigo = "00001"
			loMalta.Grabar()

			loMalta.Release()
		endwith

		loJava = _screen.zoo.instanciarentidad( "java" )
		with loJava as entidad OF entidad.prg
			.Nuevo()	
			.DetalleJava.LimpiarItem()
			with .DetalleJava.oItem
				.Malta_pk = "1"
				This.assertequals( "No encontro el codigo mediante la busqueda sugerida.", "00001", alltrim( .Malta_pk ) )
			endwith
			.Cancelar()
			.Release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarPrefijoEntidadConPermiteCodigosEnMinusculasDeshabilitado
		local loEntidad as entidad OF entidad.prg, loInfo as zooinformacion of zooInformacion.prg

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )

		goParametros.Nucleo.PermiteCodigosEnMinusculas = .f.
		loEntidad = _screen.zoo.Instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad
			.Nuevo()
			.Entidad = "MALTA"
			try
				.PrefijoEntidad = "ji"
				This.asserttrue( "No fallo la validacion para minusculas para codigos.", .f. )
			catch to loError
				loInfo = loError.UserValue.ObtenerInformacion()
				This.assertequals( "La descripcion del error no es la correcta.", "Caracter inválido en el código.", alltrim( loInfo( 1 ).cMensaje ) )
			endtry

			.Release()		
		endwith
		loInfo = null
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarPrefijoEntidadConPermiteCodigosEnMinusculasHabilitado
		local loEntidad as entidad OF entidad.prg, loInfo as zooinformacion of zooInformacion.prg

		lcEntidad = "Comportamientocodigosugeridoentidad"
		This.Mockearaccesodatos( lcEntidad )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad", 'Limpiar', .T. ) 

		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Consultarporclaveprimaria', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + "ad_sqlserver", 'Limpiar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )
		_screen.mocks.AgregarSeteoMetodo( 'Comportamientocodigosugeridoentidadad_sqlserver', 'Obtenerdatosentidad', ObtenerXMLDeDatosDeEntidad(), "[Entidad, DescripcionDeLaEntidad],[DescripcionDeLaEntidad == ''],.F.,.F." )

		goParametros.Nucleo.PermiteCodigosEnMinusculas = .t.
		loEntidad = _screen.zoo.Instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad
			.Nuevo()
			.Entidad = "MALTA"
			try
				.PrefijoEntidad = "ji"
			catch to loError
				This.asserttrue( "Fallo la validacion para minusculas para codigos.", .f. )
			endtry

			.Release()		
		endwith
		loInfo = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestI_BusquedaExtendidaSubEntidadesBuscaNoEncuentraBuscayEncuentra 
		local loEntidadRio as din_entidadRio of din_entidadRio.prg, loMalta as entidad OF entidad.prg, ;
			loError as Exception, loEntidad as entidad OF entidad.prg

		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as entidad OF entidad.prg
			try
				.Entidad = "MALTA"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.Entidad = "MALTA"
			.Grabar()
			.Release()
		endwith
		
		loMalta = _screen.zoo.instanciarentidad( "Malta" ) 
		with loMalta as din_entidadMalta of Din_entidadMalta.prg
			.Nuevo()
			.Grabar()
			.Release()
		endwith

		loEntidadRio = _screen.zoo.instanciarentidad( "Rio" )
		with loEntidadRio as din_entidadRio of din_entidadRio.prg
			.Nuevo()
			try
				.Malta_pk = "5"
			catch to loError
				this.assertequals( "El mensaje de error no es el correcto.", "El dato buscado 5 de la entidad MALTA no existe." , alltrim( loError.UserValue.oInformacion.Item( 1 ).cMensaje ) )
			endtry
		
			try
				.Malta_pk = "00001"
			catch to loError
				This.asserttrue( "No tendria que haber dado error." + alltrim( loError.UserValue.oInformacion.Item( 1 ).cMensaje ), .f. )
			endtry

			.Release()
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestI_CompletarDescripcionDeEntidades
		local loEntidad as entidad OF entidad.prg
		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		loEntidad.Nuevo()
		try
			loEntidad.Entidad = "CUBA"
			loEntidad.Grabar()
		catch
			loEntidad.Cancelar()
		endtry
		loEntidad.Nuevo()
		try
			loEntidad.Entidad = "MALTA"
			loEntidad.Grabar()
		catch
			loEntidad.Cancelar()
		endtry
		loEntidad.Release()
		goDatos.EjecutarSentencias( "update COMCODSU set DesEntidad = '' where upper( alltrim( entidad ) ) == 'CUBA' or upper( alltrim( entidad ) ) == 'MALTA'", "COMCODSU", Addbs( _Screen.zoo.cRutaInicial ) )
		
		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		loEntidad.CompletarDescripcionDeEntidades()
		loEntidad.Entidad = "CUBA"
		this.assertequals( "La descripción de la entidad debería estar cargada (1).", "Cuba", alltrim( loEntidad.DescripcionDeLaEntidad ) )
		loEntidad.Entidad = "MALTA"
		this.assertequals( "La descripción de la entidad debería estar cargada (2).", "Malta", alltrim( loEntidad.DescripcionDeLaEntidad ) )
		loEntidad.Release()
	endfunc
	
	
	*-----------------------------------------------------------------------------------------
	Function zTestI_AlNavegarQueNoHagaBusquedaExtendidaEnLasSubEntidades
		local loEntidadRio as din_entidadRio of din_entidadRio.prg, loMalta as entidad OF entidad.prg, ;
			loError as Exception, loEntidad as entidad OF entidad.prg

		goServicios.Datos.EjecutarSentencias( "Delete from malta", "malta" )

		loEntidad = _screen.zoo.instanciarentidad( "ComportamientoCodigoSugeridoEntidad" )
		with loEntidad as entidad OF entidad.prg
			try
				.Entidad = "MALTA"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.Entidad = "MALTA"
			.BusquedaExtendida = .t.
			.Grabar()
			.Release()
		endwith
		
		loMalta = _screen.zoo.instanciarentidad( "Malta" ) 
		with loMalta as din_entidadMalta of Din_entidadMalta.prg
			.Nuevo()
			.Grabar()
			.Release()
		endwith
		
		loMalta = _screen.zoo.instanciarentidad( "Malta" ) 
		with loMalta as din_entidadMalta of Din_entidadMalta.prg
			.Nuevo()
			.Codigo = "1"
			.Grabar()
			.Release()
		endwith
		

		loEntidadRio = _screen.zoo.instanciarentidad( "Rio" )
		lcCodigoAleatorio = right( sys( 2015 ), 8 )
		with loEntidadRio as din_entidadRio of din_entidadRio.prg
			.Nuevo()
			.Codigo = lcCodigoAleatorio 
			.Malta_pk = "1"
			.Grabar()


			loMalta = _screen.zoo.instanciarentidad( "Malta" ) 
			with loMalta as din_entidadMalta of Din_entidadMalta.prg
				.Codigo = "1"
				.Eliminar()
				.Release()
			endwith
			
			.limpiar()
			.Codigo = lcCodigoAleatorio
			
			this.assertequals( "La subentidad no es la correcta.", "1" ,alltrim( loEntidadRio.Malta_pk ) )
			
			.Release()
		endwith

	endfunc 
	

enddefine


*-----------------------------------------------------------------------------------------
define class Rio_accessor as Din_EntidadRio of Din_EntidadRio.prg

lPasoPorObtenerPKAAsignar = .f.

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPKAAsignar( txVal as Variant, toEntidad as entidad OF entidad.prg ) as Variant
		This.lPasoPorObtenerPKAAsignar = .t.
		return txVal
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class objetoMock as Custom
lSeEjecutoElEvento = .f.
lSeEjecutoElEventoValido = .f.
	*-----------------------------------------------------------------------------------------
	function BindeoAEventoCodigoValido() as Void
		This.lSeEjecutoElEventoValido = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BindeoAEventoCodigoNoValido() as Void
		This.lSeEjecutoElEvento = .t.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
function ObtenerXMLDeDatosDeEntidad() as String
	local lcXml as String
	text to lcXml
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData xml:space="preserve">
	<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsd:element name="VFPData" msdata:IsDataSet="true">
			<xsd:complexType>
				<xsd:choice maxOccurs="unbounded">
					<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
						<xsd:complexType>
							<xsd:attribute name="entidad" use="optional">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="descripciondelaentidad" use="optional">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
						</xsd:complexType>
					</xsd:element>
				</xsd:choice>
				<xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax"/>
			</xsd:complexType>
		</xsd:element>
	</xsd:schema>
</VFPData>
	endtext
	return lcXml
endfunc