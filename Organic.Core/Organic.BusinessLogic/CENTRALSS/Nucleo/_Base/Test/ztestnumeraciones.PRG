**********************************************************************
Define Class ztestnumeraciones As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As ztestnumeraciones Of ztestnumeraciones.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function Setup
		goServicios.Datos.EjecutarSentencias( "delete from numeraciones", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function TearDown
		goServicios.Datos.EjecutarSentencias( "delete from numeraciones", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )	
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function zTestObtenerNumero
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Int, loError As Exception, loTal As entidad Of entidad.prg, ;
				loInfo as zooinformacion of zooInformacion.prg

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		try
			loEntidad.presidente = "Capo"
			loTal.codigo = "CAPOCAPO"
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "Deberia haber creado el talonario CAPO", "EL DATO BUSCADO CAPOCAPO DE LA ENTIDAD TALONARIO NO EXISTE.", ;
					Upper( loInfo[1].cMensaje ) )
		Endtry
		loInfo = null
		lnNumero = loNumeraciones.obtenerNumero( "Habitantes" )
		This.assertequals( "El numero no es el correcto", 1, lnNumero )
		
		goServicios.Datos.EjecutarSentencias( "select * from numeraciones", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\", "Numeraciones", set("Datasession") )		
		
		select Numeraciones
		Locate For Alltrim( Upper( talonario ) ) == "CAPOCAPO"
		This.AssertTrue( "No se encontro el talonario CAPOCAPO", Found() )
		Use

		Try
			loTal.Codigo = "CAPOCAPO"
			loTal.Modificar()
			loTal.Numero = 7
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry
		loError = null
		lnNumero = loNumeraciones.obtenerNumero( "Habitantes" )
		This.assertequals( "El numero no es el correcto 2", 8, lnNumero )

		loNumeraciones.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()

		loEntidad = _Screen.zoo.instanciarEntidad( "LETONIA" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		
		Try
			lnNumero = loNumeraciones.obtenerNumero( "Numero" )
			This.assertequals( "El talonario TALLETONIA deberia haber devuelto el numero 1", 1, lnNumero )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "El talonario TALLETONIA deberia haber sido creado automaticamente", "EL DATO BUSCADO TALLETONIA DE LA ENTIDAD TALONARIO NO EXISTE.", ;
					Upper( loInfo[1].cMensaje ) )
		Endtry
		loInfo = null
		lnNumero = loNumeraciones.obtenerNumero( "Numero" )
		This.assertequals( "El numero no es el correcto", 1, lnNumero )

		goServicios.Datos.EjecutarSentencias( "select * from numeraciones", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\", "Numeraciones", set("Datasession") )		

		select Numeraciones
		Locate For Alltrim( ( talonario ) ) == "TALLETONIA"
		This.AssertTrue( "No se encontro el talonario TALLETONIA", Found() )
		Use

		Try
			loTal.Codigo = "TALLETONIA"
			loTal.Modificar()
			loTal.Numero = 10
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		lnNumero = loNumeraciones.obtenerNumero( "Numero" )
		This.assertequals( "El numero no es el correcto 2", 11, lnNumero )

		loNumeraciones.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
		loTal.Release()
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function zTestObtenerNumeroDesdeServicioReal
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Int
		Private goControladorFiscal

		goControladorFiscal = Newobject( "TestControladorFiscal" )
		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		With loEntidad
			.nombre = "MEXICO"
			.presidente = "ElCapo"
			.cComprobante = "TICKETFACTURA"
			.Nuevo()
		Endwith

		loNumeraciones = _Screen.zoo.crearobjeto( "Numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		goControladorFiscal.nNumero = 0
		loEntidad.lPasoPorEventoErrorAlObtenerNumeracionDeServicio = .F.
		lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .T. )
		This.assertequals( "No se obtuvo el número correctamente", 1, lnNumero )
		This.AssertTrue( "Pasó por el evento de error", !loEntidad.lPasoPorEventoErrorAlObtenerNumeracionDeServicio )

		goControladorFiscal.nNumero = -1
		loEntidad.lPasoPorEventoErrorAlObtenerNumeracionDeServicio = .F.
		lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .T. )
		This.assertequals( "No se obtuvo el número correctamente", 0, lnNumero )
		This.AssertTrue( "No pasó por el evento de error", loEntidad.lPasoPorEventoErrorAlObtenerNumeracionDeServicio )

		loNumeraciones.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function zTestObtenerNumeroDesdeServicioNoReal
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Integer, loError as Exception, loInfo as zooinformacion of zooInformacion.prg
		Private goControladorFiscal

		goControladorFiscal = Newobject( "TestControladorFiscal" )
		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		With loEntidad
			.nombre = "MEXICO"
			.presidente = "ElCapo"
			.cComprobante = "TICKETFACTURA"
			.Nuevo()
		Endwith
		loNumeraciones = _Screen.zoo.crearobjeto( "Numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		
		goControladorFiscal.nNumeroBufferTF = 10
		lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .F. )
		This.assertequals( "No se obtuvo el número correctamente 1", 11, lnNumero )
		
		goControladorFiscal.nNumeroBufferTF = 20
		goControladorFiscal.nNumeroBufferTD = 10
		goControladorFiscal.oCaracteristicas.lNDebitoNumeracionIndependiente = .F.
		loEntidad.cComprobante = "TICKETNOTADEDEBITO"
		lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .F. )
		This.assertequals( "No se obtuvo el número correctamente 2", 21, lnNumero )
		
		goControladorFiscal.nNumeroBufferTF = 20
		goControladorFiscal.nNumeroBufferTD = 10
		goControladorFiscal.oCaracteristicas.lNDebitoNumeracionIndependiente = .T.
		loEntidad.cComprobante = "TICKETNOTADEDEBITO"
		lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .F. )
		This.assertequals( "No se obtuvo el número correctamente 2", 11, lnNumero )
		
		goControladorFiscal.nNumeroBufferTC = 30
		loEntidad.cComprobante = "TICKETNOTADECREDITO"
		lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .F. )
		This.assertequals( "No se obtuvo el número correctamente", 31, lnNumero )
		
		loEntidad.cComprobante = "MANZANA"
		Try
			lnNumero = loNumeraciones.obtenerNumeroDesdeServicio( "CF", .F. )
			This.AssertTrue( "Debio haber Pinchado", .F. )
		catch to loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.AssertEquals( "El Mensaje no es correcto", "El comprobante no acepta este servicio. mexico", loInfo.Item[1].cMensaje )
		EndTry				
		loNumeraciones.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerNumeroStringDesdeServicioNoReal
		local loEntidad As Object, loNumeraciones As Object, lnNumero As Integer, loError as Exception, loInfo as zooinformacion of zooInformacion.prg

		_screen.mocks.agregarmock( "MEXICO" )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Cargamanual', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Nuevo', .T. )

		loEntidad = Newobject( "MEXICO_Test" )
		loEntidad.Nuevo()

		loNumeraciones = _Screen.Zoo.CrearObjeto( "Numeraciones" )
		loNumeraciones.Inicializar()
		loNumeraciones.SetearEntidad( loEntidad )
		lnNumero = loNumeraciones.ObtenerNumeroDesdeServicio( "FUNCION" )
		this.assertequals( "No se obtuvo el número correctamente", "123", lnNumero )

		loNumeraciones.LiberarEntidad()
		loEntidad.release()
		loNumeraciones.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerNumeroStringSinServicio
		local loEntidad As Object, loNumeraciones As Object, lnNumero As Integer, loError as Exception, loInfo as zooinformacion of zooInformacion.prg

		_screen.mocks.agregarmock( "MEXICO" )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Cargamanual', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Nuevo', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', 'FUNCION' )

		loEntidad = _Screen.Zoo.InstanciarEntidad( "MEXICO" )
		loEntidad.Nuevo()

		loNumeraciones = _Screen.Zoo.CrearObjeto( "Numeraciones" )
		loNumeraciones.Inicializar()
		loNumeraciones.SetearEntidad( loEntidad )

		try
			lnNumero = loNumeraciones.ObtenerNumero( "FUNCION" )
		catch to loError
			loInfo = loError.UserValue.ObtenerInformacion()
			this.assertequals( "El Mensaje no es correcto", "La entidad mexico no tiene numeración asociada para el atributo FUNCION", loInfo.Item[1].cMensaje )
		endtry

		loNumeraciones.LiberarEntidad()
		loEntidad.release()
		loNumeraciones.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestUltimoNumero

		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Int, lnUltimoNro As Integer

		_Screen.mocks.agregarmock( "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esedicion', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'CargaManual', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )
	
		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loEntidad.nombre = "MEXICO"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		goServicios.Datos.EjecutarSentencias( "insert into numeraciones ( talonario, numero ) values ( 'ELCAPOELCAPO', 10 )", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		loEntidad.presidente = "ElCapo"
		lnUltimoNro = loNumeraciones.UltimoNumero( "Habitantes" )
		This.assertequals( "El numero no es el correcto ", 10, lnUltimoNro )

		goServicios.Datos.EjecutarSentencias( "update numeraciones set numero = 8 where talonario = 'ELCAPOELCAPO'", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		loEntidad.presidente = "ElCapo"
		lnUltimoNro = loNumeraciones.UltimoNumero( "Habitantes" )
		This.assertequals( "El numero no es el correcto ", 8, lnUltimoNro )
		
		loNumeraciones.LiberarEntidad()
		loEntidad.oNumeraciones.Release()
		loEntidad.Release()
		loNumeraciones.Release()

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestEliminar
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Int, loTal As entidad Of entidad.prg, ;
			loInfo as zooinformacion of zooInformacion.prg

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loEntidad.cContexto = ""
		loEntidad.nombre = "MEXICO"
		loEntidad.lnuevo = .t.
		loEntidad.ledicion = .t.

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		Try
			loEntidad.presidente = "Capo"
			loTal.codigo = "CAPOCAPO"
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "Deberia haber creado el talonario CAPO", "EL DATO BUSCADO CAPOCAPO DE LA ENTIDAD TALONARIO NO EXISTE.", ;
					Upper( loInfo[1].cMensaje ) )
		Endtry
		loInfo = null

		lnNumero = loNumeraciones.Actualizar( "Habitantes" )
		This.assertequals( "El numero no es el correcto ", 0, lnNumero )

		lnNumero = loNumeraciones.Grabar( "Habitantes" )
		This.assertequals( "El numero no es el correcto 2", 1, lnNumero )

		goServicios.Datos.EjecutarSentencias( "update numeraciones set numero = 8 where talonario = 'CAPOCAPO'", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		lnNumero = loNumeraciones.Actualizar( "Habitantes" )
		This.assertequals( "El numero no es el correcto 3", 7, lnNumero )

		lnNumero = loNumeraciones.obtenerNumero( "Habitantes" )
		This.assertequals( "El numero no es el correcto 4", 8, lnNumero )

		goServicios.Datos.EjecutarSentencias( "update numeraciones set numero = 0 where talonario = 'CAPOCAPO'", "Numeraciones", addbs( _Screen.zoo.cRutaInicial ) + alltrim( _Screen.zoo.app.cSucursalActiva ) + "\Dbf\" )

		lnNumero = loNumeraciones.Actualizar( "Habitantes" )
		This.assertequals( "El numero no es el correcto 5", 0, lnNumero )

		lnNumero = loNumeraciones.Grabar( "Habitantes" )
		This.assertequals( "El numero no es el correcto 6", 1, lnNumero )

		loNumeraciones.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()

		loTal.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestEliminar_EnModoTransferenciaCentralizada
		Local loEntidad As Object, loNumeraciones As Object, lnNumeroAux As Int, lnNumeroFinal As Integer,;
			loNumAux As Object, lnNumeroAux As Integer, loInfo as zooinformacion of zooInformacion.prg

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )

		loEntidad.presidente = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumAux = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		loNumAux.inicializar()
		loNumAux.setearEntidad( loEntidad )

		loEntidad.cContexto = "C"

		try
			lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )
			This.AssertTrue( "Debe dar error ya que no tiene que existir el talonario", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO 11 DE LA ENTIDAD MEXICO NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry
		loEntidad.Habitantes = 10
		lnNumeroFinal = loNumeraciones.Actualizar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "Debe generar el talonario", 10, lnNumeroFinal )
		This.assertequals( "No debe modificar el atributo (1)", 10, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (1)", 10, lnNumeroAux )

		loEntidad.Habitantes = 3
		lnNumeroFinal = loNumeraciones.Actualizar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "No debe modificar el atributo (2)", 3, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (2)", 10, lnNumeroAux )

		loNumeraciones.LiberarEntidad()
		loNumAux.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
		loNumAux.Release()

		use in select( "Numeraciones" )

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestEliminar_EnModoTransferenciaBD
		Local loEntidad As Object, loNumeraciones As Object, lnNumeroAux As Int, lnNumeroFinal As Integer,;
			loNumAux As Object, lnNumeroAux As Integer, loTal As entidad Of entidad.prg, loInfo as zooinformacion of zooInformacion.prg


		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )

		loEntidad.presidente = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumAux = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		loNumAux.inicializar()
		loNumAux.setearEntidad( loEntidad )

		*		loEntidad.lTransferencia = .t.
		loEntidad.cContexto = "B"

		Try
			lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )
			This.AssertTrue( "Debe dar error ya que no tiene que existir el talonario", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO 11 DE LA ENTIDAD MEXICO NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		loEntidad.Habitantes = 10

		lnNumeroFinal = loNumeraciones.Actualizar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "Debe generar el talonario", 10, lnNumeroFinal )
		This.assertequals( "No debe modificar el atributo (1)", 10, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (1)", 10, lnNumeroAux )

		loEntidad.Habitantes = 3
		lnNumeroFinal = loNumeraciones.Actualizar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "No debe modificar el atributo (2)", 3, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (2)", 10, lnNumeroAux )

		loNumeraciones.LiberarEntidad()
		loNumAux.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
		loNumAux.Release()
		loTal.Release()

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestGrabar
		Local loEntidad As Object, loNumeraciones As Object, lnNumeroInicial As Int, lnNumeroFinal As Integer,;
			loNumAux As Object, lnNumeroAux As Integer, loTal As entidad Of entidad.prg, loInfo as zooinformacion of zooInformacion.prg

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loEntidad.presidente = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumAux = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		loNumAux.inicializar()
		loNumAux.setearEntidad( loEntidad )

		Try
			lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO 11 DE LA ENTIDAD MEXICO NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.entidad = "MEXICO"
			loTal.Codigo = "11"
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry
		lnNumeroInicial = loNumeraciones.obtenerNumero( "Habitantes" )
		lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )

		This.assertequals("No coinciden los numero obtenidos y grabados", lnNumeroInicial, lnNumeroFinal )

		lnNumeroInicial = loNumeraciones.obtenerNumero( "Habitantes" )
		lnNumeroAux = loNumAux.Grabar( "Habitantes" )
		lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )

		This.assertequals("No coinciden los numero obtenidos y grabados 2", lnNumeroInicial + 1 , lnNumeroFinal )

		loNumeraciones.LiberarEntidad()
		loNumAux.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
		loNumAux.Release()

		loTal.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestGrabar_EnModoTransferenciaCentralizada
		Local loEntidad As Object, loNumeraciones As Object, lnNumeroAux As Int, lnNumeroFinal As Integer,;
			loNumAux As Object, lnNumeroAux As Integer, loTal As entidad Of entidad.prg

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loEntidad.presidente = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumAux = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		loNumAux.inicializar()
		loNumAux.setearEntidad( loEntidad )

		loEntidad.cContexto = "C"

		Try
			lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )
			This.AssertTrue( "Debe dar error ya que no tiene que existir el talonario", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO 11 DE LA ENTIDAD MEXICO NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		loEntidad.Habitantes = 10

		lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "Debe generar el talonario", 10, lnNumeroFinal )
		This.assertequals( "No debe modificar el atributo (1)", 10, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (1)", 10, lnNumeroAux )

		loEntidad.Habitantes = 3
		lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "No debe modificar el atributo (2)", 3, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (2)", 10, lnNumeroAux )


		*-- Busca el talonario y verifica que tenga el valor Presidente correcto
		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )
		loTal.Codigo = "11"
		This.assertequals( "No se lleno el atributo relacionados (1)", Alltrim( loEntidad.presidente ), Alltrim( loTal.presidente ) )

		loNumeraciones.LiberarEntidad()
		loNumAux.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
		loNumAux.Release()
		loTal.Release()

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestGrabar_EnModoTransferenciaBS
		Local loEntidad As Object, loNumeraciones As Object, lnNumeroAux As Int, lnNumeroFinal As Integer,;
			loNumAux As Object, lnNumeroAux As Integer, loTal As entidad Of entidad.prg


		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loEntidad.presidente = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumAux = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		loNumAux.inicializar()
		loNumAux.setearEntidad( loEntidad )

		loEntidad.cContexto = "C"

		Try
			lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )
			This.AssertTrue( "Debe dar error ya que no tiene que existir el talonario", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO 11 DE LA ENTIDAD MEXICO NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		loEntidad.Habitantes = 10

		lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "Debe generar el talonario", 10, lnNumeroFinal )
		This.assertequals( "No debe modificar el atributo (1)", 10, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (1)", 10, lnNumeroAux )

		loEntidad.Habitantes = 3
		lnNumeroFinal = loNumeraciones.Grabar( "Habitantes" )
		lnNumeroAux = loNumAux.UltimoNumero( "Habitantes" )

		This.assertequals( "No debe modificar el atributo (2)", 3, loEntidad.Habitantes )
		This.assertequals( "El ultimo numero es incorrecto (2)", 10, lnNumeroAux )


		*-- Busca el talonario y verifica que tenga el valor Presidente correcto
		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )
		loTal.Codigo = "11"
		This.assertequals( "No se lleno el atributo relacionados (1)", Alltrim( loEntidad.presidente ), Alltrim( loTal.presidente ) )

		loNumeraciones.LiberarEntidad()
		loNumAux.LiberarEntidad()
		loEntidad.Release()
		loNumeraciones.Release()
		loNumAux.Release()
		loTal.Release()

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestDosNumeradoresUnaEntidad
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Integer, loTal As entidad Of entidad.prg, loError As Exception ,;
			ln1 As Integer, ln2 As Integer, ln3 As Integer , llExiste

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loEntidad = _Screen.zoo.instanciarEntidad("italia")

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		loEntidad.descripcion = "Desc1"
		Try
			ln1 = loNumeraciones.Grabar( "Habitantes" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO ITALIADESC1 DE LA ENTIDAD ITALIA NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.Codigo = "ITALIADESC1"
			loTal.entidad = "ITALIA"
			loTal.descripcion = "DESC1"
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		ln1 = loNumeraciones.Grabar( "Habitantes" )
		This.assertequals( "El numero es incorrecto (1)", 1, ln1 )

		loEntidad.descripcion = "DESC2"
		Try
			ln2 = loNumeraciones.Grabar( "Habitantes" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO ITALIADESC2 DE LA ENTIDAD ITALIA NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.Codigo = "ITALIADESC2"
			loTal.entidad = "ITALIA"
			loTal.descripcion = "DESC2"
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry


		ln2 = loNumeraciones.Grabar( "Habitantes" )
		This.assertequals( "El numero es incorrecto (2)", 1, ln2 )

		loEntidad.descripcion = "DESC1"
		ln3 = loNumeraciones.Grabar( "Habitantes" )

		This.assertequals( "El numero es incorrecto (3)", 2, ln3 )

		lnNumero = loNumeraciones.obtenerNumero( "Habitantes" )
		This.assertequals( "El numero es incorrecto (4)", 3, lnNumero )

		loEntidad.descripcion = "DESC2"
		lnNumero = loNumeraciones.obtenerNumero( "Habitantes" )
		This.assertequals( "El numero es incorrecto (5)", 2, lnNumero )

		loEntidad.Release()
		loNumeraciones.Release()
		loTal.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestUnNumeradorDosEntidades
		Local loEntidad As entidad Of entidad.prg, loNumeraciones As Object, loTal As entidad Of entidad.prg, loError As Exception, ;
			ln1 As Integer, ln2 As Integer, loLetonia As entidad Of entidad.prg, loAlemania As entidad Of entidad.prg

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loAlemania = _Screen.zoo.instanciarEntidad( "alemania" )
		loAlemania.descripcion = "1"
		loLetonia = _Screen.zoo.instanciarEntidad( "letonia" )
		loLetonia.descripcion = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loAlemania )

		Try
			ln1 = loNumeraciones.Grabar( "codigo" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO TALLETONIA1 DE LA ENTIDAD ALEMANIA NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.Codigo = "TALLETONIA1"
			loTal.entidad = "ALEMANIA"
			loTal.descripcion = "1"
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry
		ln1 = loNumeraciones.Grabar( "codigo" )
	
		This.assertequals( "El numero es incorrecto (1)", 1, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loLetonia )
		ln2 = loNumeraciones.Grabar( "codigo" )
		This.assertequals( "El numero es incorrecto (2)", 2, ln2 )
		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		ln1 = loNumeraciones.Grabar( "codigo" )
		This.assertequals( "El numero es incorrecto (3)", 3, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loLetonia )
		ln2 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (4)", 4, ln2 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		ln1 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (5)", 4, ln1 )

		loNumeraciones.LiberarEntidad()
		loAlemania.Release()
		loLetonia.Release()
		loNumeraciones.Release()

		loTal.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestDosNumeradoresDosEntidades
		Local loNumeraciones As Object, loTal As entidad Of entidad.prg, loError As Exception, ;
			ln1 As Integer, ln2 As Integer, loLetonia As entidad Of entidad.prg, loAlemania As entidad Of entidad.prg

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loAlemania = _Screen.zoo.instanciarEntidad("alemania")
		loAlemania.descripcion = "1"

		loLetonia = _Screen.zoo.instanciarEntidad("letonia")
		loLetonia.descripcion = "1"

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()

		loNumeraciones.setearEntidad( loAlemania )

		Try
			ln1 = loNumeraciones.Grabar( "codigo" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO TALLETONIA1 DE LA ENTIDAD ALEMANIA NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.Codigo = "TALLETONIA1"
			loTal.Grabar()

			loTal.Nuevo()
			loTal.Codigo = "TALLETONIAALGO"
			loTal.Grabar()

			loTal.Nuevo()
			loTal.Codigo = "TALLETONIAOTROALGO"
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry
		ln1 = loNumeraciones.Grabar( "codigo" )
		This.assertequals( "El numero es incorrecto (1)", 1, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loLetonia )
		ln2 = loNumeraciones.Grabar( "codigo" )
		This.assertequals( "El numero es incorrecto (2)", 2, ln2 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		ln1 = loNumeraciones.Grabar( "codigo" )
		This.assertequals( "El numero es incorrecto (3)", 3, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loLetonia )
		ln2 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (4)", 4, ln2 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		ln1 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (5)", 4, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		loAlemania.descripcion = "Algo"
		ln1 = loNumeraciones.Grabar( "codigo" )
		This.assertequals( "El numero es incorrecto (6)", 1, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		loAlemania.descripcion = "Algo"
		ln1 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (7)", 2, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		loAlemania.descripcion = "OtroAlgo"
		ln1 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (8)", 1, ln1 )

		loNumeraciones.LiberarEntidad()
		loNumeraciones.setearEntidad( loAlemania )
		loAlemania.descripcion = "1"
		ln1 = loNumeraciones.obtenerNumero( "codigo" )
		This.assertequals( "El numero es incorrecto (9)", 4, ln1 )

		loNumeraciones.LiberarEntidad()
		loAlemania.Release()
		loLetonia.Release()
		loNumeraciones.Release()

		loTal.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestUnaEntidadDosAtributosNumerados
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Integer, loTal As entidad Of entidad.prg, loError As Exception ,;
			ln1 As Integer, ln2 As Integer, ln3 As Integer , llExiste

		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		loEntidad = _Screen.zoo.instanciarEntidad("letonia")

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		loEntidad.descripcion = "Desc1"
		Try
			ln1 = loNumeraciones.Grabar( "Numero" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO TALLETONIA DE LA ENTIDAD LETONIA NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.Codigo = "TALLETONIA"
			loTal.descripcion = ""
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		Try
			ln1 = loNumeraciones.Grabar( "Codigo" )
			This.AssertTrue( "Debe dar error", .F. )
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()		
			This.assertequals( "El mensaje de error es incorrecto", "EL TALONARIO TALLETONIADESC1 DE LA ENTIDAD LETONIA NO EXISTE", Upper( loInfo[2].cMensaje ) )
		Endtry

		Try
			loTal.Nuevo()
			loTal.Codigo = "TALLETONIADESC1"
			loTal.descripcion = "DESC1"
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		ln1 = loNumeraciones.Grabar( "Numero" )
		This.assertequals( "El numero es incorrecto (1)", 1, ln1 )

		ln2 = loNumeraciones.Grabar( "Codigo" )
		This.assertequals( "El numero es incorrecto (2)", 1, ln2 )

		ln3 = loNumeraciones.Grabar( "Numero" )
		This.assertequals( "El numero es incorrecto (3)", 2, ln3 )

		lnNumero = loNumeraciones.obtenerNumero( "Numero" )
		This.assertequals( "El numero es incorrecto (4)", 3, lnNumero )

		lnNumero = loNumeraciones.obtenerNumero( "Codigo" )
		This.assertequals( "El numero es incorrecto (5)", 2, lnNumero )

		loEntidad.Release()
		loNumeraciones.Release()
		loTal.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerTalonarioNoPropio
		local loNumeraciones as Object, loEntidad as entidad OF entidad.prg, loTal as entidad OF entidad.prg
		
		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )
		with loTal
			try
				.Codigo = "TALLETONIADES1"
				.eliminar()
			catch 
			endtry
			
			try
				.Codigo = "TALLETONIADES2"
				.eliminar()
			catch 
			endtry
			
			.Nuevo()
			.Codigo = "TALLETONIADES1"
			.Entidad = "Letonia"
			.Descripcion = "Des1"
			.Numero = 15
			.grabar()
					
			.Nuevo()
			.Codigo = "TALLETONIADES2"
			.Entidad = "Letonia"
			.Descripcion = "Des2"
			.DelegarNumeracion = .t.
			.TalonarioRela_pk = "TALLETONIADES1"
			.grabar()

		endwith

		loEntidad = _Screen.zoo.instanciarEntidad("letonia")

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )
		loEntidad.descripcion = "Des2"

		lnNumero = loNumeraciones.obtenerNumero( "Codigo" )
		This.assertequals( "El numero es incorrecto (1)", 16, lnNumero )
		
		
		loNumeraciones.release()
		loEntidad.release()
		loTal.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestReservarNumero
		
		local loTalonario As entidad Of entidad.prg, loEntidad As Object, loNumeraciones As Object, lnNumeroReservado As Integer,;
			  lnNumero as Integer, lnNumeroNoReservado As Integer

		loTalonario = _Screen.zoo.instanciarEntidad( "Talonario" )

		try
			loTalonario.Codigo = "TALFRANCIA2"
			loent.Eliminar()
		catch
		endtry

		try
			loTalonario.Codigo = "TALFRANCIA3"
			loent.Eliminar()
		catch
		endtry

		loTalonario.Nuevo()
		loTalonario.codigo = "TALFRANCIA2"
		loTalonario.Descripcion = "DESCR1"
		loTalonario.Numero = 100
		loTalonario.Entidad = "FRANCIA"
		loTalonario.ReservarNumero = .T.
		loTalonario.Grabar()

		loTalonario.Nuevo()
		loTalonario.codigo = "TALFRANCIA3"
		loTalonario.Descripcion = "DESCR2"
		loTalonario.Numero = 200
		loTalonario.Entidad = "FRANCIA"
		loTalonario.ReservarNumero = .F.
		loTalonario.Grabar()

		loEntidad = _Screen.zoo.instanciarEntidad("Francia")

		try
			loEntidad.codigo = 12345
			loEntidad.eliminar()
		catch
		endtry

		loEntidad.nuevo()
		loEntidad.codigo = 12345
		
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		this.assertequals( "La numeracion del talonario TALFRANCIA2 no es la correcta", 101, loNumeraciones.UltimoNumero("NUMERO") )
		this.assertequals( "La numeracion del talonario TALFRANCIA3 no es la correcta", 200, loNumeraciones.UltimoNumero("HABITANTES") )

		loEntidad.grabar()

		this.assertequals( "No deberia haber grabado la numeracion del talonario TALFRANCIA2 nuevamente", 101, loNumeraciones.UltimoNumero("NUMERO") )
		this.assertequals( "La numeracion del talonario TALFRANCIA3 no es la correcta, deberia haber grabado el numero", 201, loNumeraciones.UltimoNumero("HABITANTES") )
		
		loEntidad.modificar()
		this.assertequals( "No deberia haber modificado la numeracion del talonario TALFRANCIA2", 101, loNumeraciones.UltimoNumero("NUMERO") )
		this.assertequals( "No deberia haber modificado la numeracion del talonario TALFRANCIA3", 201, loNumeraciones.UltimoNumero("HABITANTES") )

		loEntidad.cancelar()

		loEntidad.Release()
		loNumeraciones.Release()
		loTalonario.Release()
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function zTestAgregarTalonarioAutomaticamenteAlDarNuevoEnLaEntidad
		
		local loTalonario As entidad Of entidad.prg, loEntidad As Object, loNumeraciones As Object,;
			  lnNumero as Integer

		loTalonario = _Screen.zoo.instanciarEntidad( "Talonario" )
		
		loEntidad = _Screen.zoo.instanciarEntidad( "FRANCIA" )
		loEntidad.nuevo()
		loEntidad.Cancelar()
		
		try
			loTalonario.codigo = "TALFRANCIA2"
		catch
			This.AssertTrue( "Deberir haber creado el talonario TALFRANCIA2", .F. )		
		endtry

		try
			loTalonario.codigo = "TALFRANCIA3"
		catch
			This.AssertTrue( "Deberir haber creado el talonario TALFRANCIA3", .F. )		
		endtry

		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )
		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		with loTalonario
			.Modificar()
			.Numero = 100
			.Grabar()
		endwith
		
		lnNumero = loNumeraciones.obtenerNumero( "Habitantes" )
		This.assertequals( "El talonario TALFRANCIA3 deberia haber devuelto el numero 101", 101, lnNumero )
		
		loEntidad.release()
		loTalonario.release()
		loNumeraciones.release()
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerNumeroConTalonarioLleno
		
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Int, loError As Exception, loTal As entidad Of entidad.prg, ;
				loInfo as zooinformacion of zooInformacion.prg

		_Screen.mocks.agregarmock( "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esedicion', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'CargaManual', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )


		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		try
			loTal.Nuevo()
			loTal.Codigo = "TESTTEST"
			loTal.Numero = 7
			loTal.MaximoNumero = 7
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		Try
			loEntidad.presidente = "TEST"
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "No controló el maximo para el talonario", "SE HA LLEGADO AL MÁXIMO DISPONIBLE (7) PARA EL TALONARIO DE MEXICO (TESTTEST).", ;
					Upper( loInfo[1].cMensaje ) )
		endtry 
		
		loTal.Codigo = "TESTTEST"
		loTal.Eliminar()
		
		loEntidad.oNumeraciones.Release()
		loEntidad.Release()
		loNumeraciones.Release()
		loTal.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerNumeroTalonarioSinLimiteNoDebeControlar
		
		Local loEntidad As Object, loNumeraciones As Object, lnNumero As Int, loError As Exception, loTal As entidad Of entidad.prg, ;
				loInfo as zooinformacion of zooInformacion.prg

		_Screen.mocks.agregarmock( "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esedicion', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'CargaManual', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )


		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		try
			loTal.Nuevo()
			loTal.Codigo = "TESTTEST"
			loTal.Numero = 7
			loTal.MaximoNumero = 0
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		Try
			loEntidad.presidente = "TEST"
		Catch To loError
			loInfo = loError.UserValue.ObtenerInformacion()
			This.assertequals( "No controló el maximo para el talonario", "SE HA LLEGADO AL MÁXIMO DISPONIBLE (7) PARA EL TALONARIO DE MEXICO.", ;
					Upper( loInfo[1].cMensaje ) )
		endtry 
		
		loTal.Codigo = "TESTTEST"
		loTal.Eliminar()
		
		loEntidad.oNumeraciones.Release()
		loEntidad.Release()
		loNumeraciones.Release()
		loTal.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_TalonarioConNumeracionDisponible
		
		Local loEntidad As Object, loNumeraciones As numeraciones of numeraciones.prg, lnNumero As Int, loError As Exception, loTal As entidad Of entidad.prg, ;
				loInfo as zooinformacion of zooInformacion.prg

		_Screen.mocks.agregarmock( "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esedicion', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'CargaManual', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )


		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		try
			loTal.Nuevo()
			loTal.Codigo = "TESTTEST"
			loTal.Numero = 7
			loTal.MaximoNumero = 10
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		try
			loEntidad.presidente = "TEST"
		catch
		endtry

		llTalonarioConDisponibilidad = loEntidad.oNumeraciones.TalonarioConNumeracionDisponible()
		This.assertTrue( "el talonario tiene numeros disponibles", llTalonarioConDisponibilidad )
		
		loTal.Codigo = "TESTTEST"
		loTal.Eliminar()

		loEntidad.oNumeraciones.Release()
		loEntidad.Release()
		loNumeraciones.Release()
		loTal.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_TalonarioSinNumeracionDisponible
		
		Local loEntidad As Object, loNumeraciones As numeraciones of numeraciones.prg, lnNumero As Int, loError As Exception, loTal As entidad Of entidad.prg, ;
				loInfo as zooinformacion of zooInformacion.prg

		_Screen.mocks.agregarmock( "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esedicion', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'CargaManual', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )


		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		try
			loTal.Nuevo()
			loTal.Codigo = "TESTTEST"
			loTal.Numero = 7
			loTal.MaximoNumero = 7
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		try
			loEntidad.presidente = "TEST"
		catch
		endtry

		llTalonarioConDisponibilidad = loEntidad.oNumeraciones.TalonarioConNumeracionDisponible()
		This.assertTrue( "el talonario no tiene numeros disponibles", !llTalonarioConDisponibilidad )
		
		loTal.Codigo = "TESTTEST"
		loTal.Eliminar()
		
		loEntidad.oNumeraciones.Release()
		loEntidad.Release()
		loNumeraciones.Release()
		loTal.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_TalonarioSinLimiteNoDebeLimitarDisponibilidad
		
		Local loEntidad As Object, loNumeraciones As numeraciones of numeraciones.prg, lnNumero As Int, loError As Exception, loTal As entidad Of entidad.prg, ;
				loInfo as zooinformacion of zooInformacion.prg

		_Screen.mocks.agregarmock( "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esedicion', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'CargaManual', .T. )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Obtenernombre', "MEXICO" )
		_Screen.mocks.AgregarSeteoMetodo( 'mexico', 'Esnuevo', .T. )


		loTal = _Screen.zoo.instanciarEntidad( "Talonario" )

		try
			loTal.Nuevo()
			loTal.Codigo = "TESTTEST"
			loTal.Numero = 7
			loTal.MaximoNumero = 0
			loTal.Grabar()
		Catch To loError
			loTal.Release()
			Throw loError
		Endtry

		loEntidad = _Screen.zoo.instanciarEntidad( "MEXICO" )
		loNumeraciones = _Screen.zoo.crearobjeto( "numeraciones" )

		loNumeraciones.inicializar()
		loNumeraciones.setearEntidad( loEntidad )

		try
			loEntidad.presidente = "TEST"
		catch
		endtry

		llTalonarioConDisponibilidad = loEntidad.oNumeraciones.TalonarioConNumeracionDisponible()
		This.assertTrue( "el talonario no tiene limite", llTalonarioConDisponibilidad )
		
		loTal.Codigo = "TESTTEST"
		loTal.Eliminar()

		loEntidad.oNumeraciones.Release()
		loEntidad.Release()
		loNumeraciones.Release()
		loTal.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDarDeAltaTalonarioAlEliminarEnCasoDeQueNoExistaTalonario
		local loChile as din_entidadChile of din_entidadChile.prg, loError as zooexception OF zooexception.prg, loInformacion as zooinformacion of zooInformacion.prg
		
		loChile = _screen.zoo.instanciarentidad( "Chile" )
		
		loChile.Nuevo()
		loChile.DescrIPCION = "Chile Desc"
		loChile.Grabar()

		loTalonario = _screen.zoo.instanciarentidad( "Talonario" )
		loTalonario.Codigo = "Talchile"
		
		loTalonario.Eliminar()
		
		
		try
			loChile.Eliminar()
			
		catch to loError
			if vartype( loError.UserValue ) = "O"
				loInformacion = loError.UserValue.ObtenerInformacion()
				if loInformacion.hayinformacion()
					this.asserttrue( "No debe dar error por falta de talonario.", alltrim( loInformacion[1].cMensaje ) <> "El dato buscado TALCHILE de la entidad TALONARIO no existe." )
				else
					this.asserttrue( loError.UserValue.Message, .f. )
				endif
			else
				this.asserttrue( loError.Message, .f. )
			endif
		endtry
		loTalonario.Release()
		loChile.Release()

	endfunc 
	

Enddefine

********************************************************************************************************
Define Class TestControladorFiscal As Custom
	nNumero = 0
	nNumeroBufferTF = 0
	nNumeroBufferTC = 0	
	nNumeroBufferTD = 0
	*-----------------------------------------------------------------------------------------
	Function Init() as void
		this.AddProperty( "oCaracteristicas", newobject("Custom") )
		this.oCaracteristicas.addproperty( "lNDebitoNumeracionIndependiente", .F. )
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function ObtenerUltimoNumFactura( tcLetra )
		Return This.nNumero
	Endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoNumNotaCreditoBuffer( tcLetra as String ) as integer
		return This.nNumeroBufferTC
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoNumFacturaBuffer( tcLetra as String ) as integer
		return This.nNumeroBufferTF
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoNumNotaDebitoBuffer( tcLetra as String ) as integer
		if this.oCaracteristicas.lNDebitoNumeracionIndependiente
			return This.nNumeroBufferTD 
		else
			return This.nNumeroBufferTF
		endif
	endfunc 

Enddefine


**********************************************************************************************
define class MEXICO_Test as Din_EntidadMexico of Din_EntidadMexico.prg
	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroString() as String
		local lcRetorno as String
		lcRetorno = "123"
		return lcRetorno
	endfunc
enddefine
