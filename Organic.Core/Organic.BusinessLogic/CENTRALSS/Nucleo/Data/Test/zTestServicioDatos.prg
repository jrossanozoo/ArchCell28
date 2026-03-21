**********************************************************************
Define Class zTestServicioDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestServicioDatos of zTestServicioDatos.prg
	#ENDIF
	
	nnroreintentos = 0
	ntiemporeintentos = 0
	dimension aSucursales[ 1 ]

	*---------------------------------
	Function Setup
		this.nnroreintentos	= GOREGISTRY.NUCLEO.NUMERODEREINTENTOSDECONEXION
		this.ntiemporeintentos 	= GOREGISTRY.NUCLEO.TIEMPODEESPERAPARAREINTENTOCONEXION
		acopy( _screen.zoo.app.aSucursales, this.aSucursales )
		_Screen.zoo.app.CargarSucursales()
	EndFunc
	
	*---------------------------------
	Function TearDown
		GOREGISTRY.NUCLEO.NUMERODEREINTENTOSDECONEXION	= this.nnroreintentos 
		GOREGISTRY.NUCLEO.TIEMPODEESPERAPARAREINTENTOCONEXION = this.ntiemporeintentos
		dimension _screen.zoo.app.aSucursales[ 1 ]
		acopy( this.aSucursales, _screen.zoo.app.aSucursales )		
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestObtenerSD
		Local loDatos As servicioDatos Of servicioDatos.prg, lcRetorno As String
		Local lcBuffer As String, iSzBuffer As Integer, lcRetval As String

		Declare Long GetComputerName In WIN32API String @, Long @
		lcBuffer = Space( 250 )
		iSzBuffer = 250
		lcRetval = GetComputerName( @lcBuffer, @iSzBuffer )
		*----- El test no siempre termina verde cuando se lo ejecuta en ZooAB01 y creemos que el problema pasa por el Raid de discos.
		If "ZOOAB01" $ Upper( Alltrim( lcBuffer ) )
		Else
			loDatos = _Screen.zoo.CrearObjeto( "servicioDatos" )
			
			Declare String GetSerialNumber In "GDS.dll" Integer DriveNo, String RegCode
			lcRetorno = Upper( GetSerialNumber( 0, '46A3A-MP6H3-3697B-D4GYB-Q8HSY' ) )
			
			This.Assertequals( "No se obtuvo el valor esperado", lcRetorno, loDatos.obtenersd() )
		EndIf

		Clear Dlls "GetComputerName"
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function zTestSqlServerConexionSql
		local loDatos as servicioDatos of servicioDatos.prg

		_screen.mocks.agregarmock( "ManagerConexionASql" )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERCONEXIONASQL', 'Obtenerconexion', 99 )
		_screen.mocks.AgregarSeteoMetodo( 'MANAGERCONEXIONASQL', 'Cerrarconexion', .T. )

		loDatos = _screen.zoo.CrearObjeto( "servicioDatos" )

		loDatos.ConectarMotorSQL()
		this.assertequals( "El id de conexión es incorrecto 1", 99, loDatos.ObtenerIdConexion() )

		loDatos.DesconectarMotorSQL()
		this.assertequals( "El id de conexión es incorrecto 2", 0, loDatos.ObtenerIdConexion() )
		
		loDatos.Release()			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerReconectarSqlMaximosIntentos
		local loDatos as servicioDatos of servicioDatos.prg

		loDatos = newobject( "servicioDatosTest" )
		loDatos.oManagerConexionaSql.nReintentos = 4	
		loDatos.oManagerConexionaSql.nSimularConexionAlIntento = 4
		lnHadler = loDatos.reconectarmotorsql() && loDatos.tryconnect()
		this.assertequals("No pasó las 4 veces que indica el registro", 4, loDatos.omANAGERCONEXIONASQL.nReintentosTest )
			
		lodatos.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerReconectarSqlConReintentosMenorAlMaximo
		local loDatos as servicioDatos of servicioDatos.prg

		loDatos = newobject( "servicioDatosTest" )
		loDatos.oManagerConexionaSql.nReintentos = 23
		loDatos.omANAGERCONEXIONASQL.nSimularConexionAlIntento = 9

		lnHadler = loDatos.reconectarmotorsql()
		this.assertequals("No pasó las 9 veces que indica el registro", 9, loDatos.omANAGERCONEXIONASQL.nReintentosTest )
		
		lodatos.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestSqlServerEjecutarSqlOptimista
		local loDatos as ServicioDatos of ServicioDatos.Prg
				
		loDatos = _Screen.zoo.CrearObjeto( "ServicioDatos" )
		with loDatos
			loDatos.ConectarMotorSql()
			This.Asserttrue( "No Debe haber conexiones activas 1", !.HayTransaccionesActivas() )
			.EjecutarSql( "BEGIN TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 2", .HayTransaccionesActivas() )
			.EjecutarSql( "BEGIN TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 3", .HayTransaccionesActivas() )			
			.EjecutarSql( "BEGIN TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 4", .HayTransaccionesActivas() )			
			.EjecutarSql( "BEGIN TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 5", .HayTransaccionesActivas() )
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "COMMIT TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 6", .HayTransaccionesActivas() )			
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "COMMIT TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 7", .HayTransaccionesActivas() )			
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "Select max( id ) from sysobjects" )
			.EjecutarSql( "ROLLBACK TRANSACTION" )
			This.Asserttrue( "Debe haber conexiones activas 8", .HayTransaccionesActivas() )			
			.EjecutarSql( "ROLLBACK TRANSACTION" )
			This.Asserttrue( "No Debe haber conexiones activas 9", !.HayTransaccionesActivas() )			
			loDatos.DesconectarMotorSql()
			.Release()
		EndWith
	endfunc
	*-----------------------------------------------------------------------------------------
	function ztestSqlServerEjecutarSqlPesimista1
		local loDatos as ServicioDatos of ServicioDatos.Prg, loInfo as zooinformacion of zooInformacion.prg, lcSentencia as String
		
		lcSentencia = "insert into " + goServicios.Estructura.ObtenerEsquema("Hon") + ".HON ( Honcod, Honnom ) values ( '1','1' )"
		loDatos = _Screen.zoo.CrearObjeto( "ServicioDatos" )
		with loDatos
			.ConectarMotorSql()
			.EjecutarSentencias( "delete from HON", "HON.dbf", "" )
			Try
				.ejecutarSentencias( "BEGIN TRANSACTION", "" )
				.ejecutarSentencias( lcSentencia, "HON" )
				Try
					.ejecutarSentencias( "BEGIN TRANSACTION", "" )
					.ejecutarSentencias( lcSentencia, "HON" )
					This.Assetrue( "Debio Tirar Excepcion", .F. )
					.ejecutarSentencias( "COMMIT TRANSACTION", "" )
				catch to loError
					.ejecutarSentencias( "ROLLBACK TRANSACTION", "" )
					goServicios.Errores.LevantarExcepcion( loError )
				endtry
				.ejecutarSentencias( "COMMIT TRANSACTION", "" )
			catch to loError
				.ejecutarSentencias( "ROLLBACK TRANSACTION", "" )
				loInfo = loError.UserValue.ObtenerInformacion() 
			EndTry	
			This.Assertequals( "La Información del error no es correcta", "Instrucción SQL no realizada: " + lcSentencia, loInfo.Item[1].cMensaje )
			.EjecutarSentencias( "Select * From HON", "HON", "", "C_Test", set("Datasession") )
			This.Assertequals( "El cursor vino con datos", 0, reccount( "c_Test" ) )
			use in select( "c_Test" )
			.DesconectarMotorSql()
			.Release()
		EndWith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestEjecutarSentencias
		local loServicioDatos as Object, lcTipoAccesoDatos as String, lcCursor as String 

		try
			loServicioDatos = createobject( "ServicioDatosTest" )
				
			with loServicioDatos
				if goDatos.EsNativa()
					.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA" )
					This.asserttrue( "No paso por el metodo correspondiente a NATIVA.", .lPasoPorEjecutarScriptNativa )
					This.asserttrue( "No debió pasar por el metodo correspondiente a SQLSERVER", !.lPasoPorEjecutarSQL )
					This.assertequals( "La sentencia que se recibio no es correcta para NATIVA", "SELECT * FROM UNATABLA", upper( .cSentencia ) )
				else
					.EjecutarSentencias( "SELECT * FROM HON", "HON" )
					This.asserttrue( "No debió pasar por el metodo correspondiente a NATIVA.", !.lPasoPorEjecutarScriptNativa )
					This.asserttrue( "No paso por el metodo correspondiente a SQLSERVER", .lPasoPorEjecutarSQL )
					This.assertequals( "La sentencia que se recibio no es correcta para SQLSERVER", "SELECT * FROM ZOOLOGIC.HON", upper( .cSentencia ) )
				endif

			endwith


			if alltrim( goServicios.Estructura.ObtenerUbicacion( "MEXICO" ) ) = "SUCURSAL"
				lcCursor = "tmp_Mexico" + sys( 2015 )
				try
					goServicios.Datos.EjecutarSentencias( "SELECT * FROM MEXICO WHERE 1=2", "MEXICO", "", lcCursor, set("Datasession" ) )
				catch to loError
				endtry
				This.asserttrue( "El cursor basado en la tabla de sucursal Mexico no se creo.", used( lcCursor ) )
				use in select( lcCursor )
			else
				This.asserttrue( "La tabla MEXICO no es de sucursal.", .f. )
			endif


			if alltrim( goServicios.Estructura.ObtenerUbicacion( "EMP" ) ) = "PUESTO"
				lcCursor = "tmp_Emp" + sys( 2015 )
				try
					goServicios.Datos.EjecutarSentencias( "SELECT * FROM EMP WHERE 1=2", "EMP", "", lcCursor, set("Datasession" ) )
				catch to loError
				endtry
				This.asserttrue( "El cursor basado en la tabla de puesto Emp no se creo.", used( lcCursor ) )
				use in select( lcCursor )
			else
				This.asserttrue( "La tabla EMP no es de puesto.", .f. )
			endif
			
			
			if alltrim( goServicios.Estructura.ObtenerUbicacion( "REGLATRANS" ) ) = "ORGANIZACION"
				lcCursor = "tmp_ReglaTrans" + sys( 2015 )
				try
					goServicios.Datos.EjecutarSentencias( "SELECT * FROM REGLATRANS WHERE 1=2", "REGLATRANS", "", lcCursor, set("Datasession" ) )
				catch to loError
				endtry
				This.asserttrue( "El cursor basado en la tabla de organizaciono ReglaTrans no se creo.", used( lcCursor ) )
				use in select( lcCursor )
			else
				This.asserttrue( "La tabla REGLATRANS no es de organización.", .f. )
			endif


			if alltrim( goServicios.Estructura.ObtenerUbicacion( "PERFILESOPERACIONES" ) ) = "SEGURIDAD"
				lcCursor = "tmp_PerfilesOperaciones" + sys( 2015 )
				try
					goServicios.Datos.EjecutarSentencias( "SELECT * FROM PERFILESOPERACIONES WHERE 1=2", "PERFILESOPERACIONES", "", lcCursor, set("Datasession" ) )
				catch to loError
				endtry
				This.asserttrue( "El cursor basado en la tabla de seguridad PerfilesOperaciones no se creo.", used( lcCursor ) )
				use in select( lcCursor )
			else
				This.asserttrue( "La tabla PERFILESOPERACIONES no es de seguridad.", .f. )
			endif

		catch to loError
			throw loError
		Finally 	
			loServicioDatos.Release()
		Endtry
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestModificarParametrosAntesDeEjecutarSentencia
		local loServicioDatos as ServicioDatos of ServicioDatos.prg, loError as Exception
		
		loServicioDatos = createobject( "ServicioDatosTest2" )
		with loServicioDatos
******* NATIVA **************
			if goDatos.EsNativa()
				.cTipoDeBase = "NATIVA"
				.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La tabla que se desea abrir no es correcta (1)", ;
					upper( addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) ) + "DBF\UNATABLA", ;
					upper( .cTablas ) )

				.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA", _screen.zoo.cRutaInicial )
				this.assertequals( "La tabla que se desea abrir no es correcta (2)", ;
					upper( _screen.zoo.cRutaInicial ) + "UNATABLA", upper( .cTablas ) )

				.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA,OTRATABLA, YUNAMAS", _screen.zoo.cRutaInicial )
				this.assertequals( "La tabla que se desea abrir no es correcta (3)", ;
					upper( _screen.zoo.cRutaInicial ) + "UNATABLA, " + upper( _screen.zoo.cRutaInicial ) + "OTRATABLA, " + ;
					upper( _screen.zoo.cRutaInicial ) + "YUNAMAS", upper( .cTablas ) )

				.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA,OTRATABLA, YUNAMAS" )
				this.assertequals( "La tabla que se desea abrir no es correcta (4)", ;
					upper( addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) ) + "DBF\UNATABLA, " + ;
					upper( addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) ) + "DBF\OTRATABLA, " + ;
					upper( addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) ) + "DBF\YUNAMAS", upper( .cTablas ) )

				try
					.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .t." )
					this.asserttrue( "Debería haber dado error (1)", .f. )
				catch to loError
					this.assertequals( "El error no es el correcto (1)", ;
						"SE DEBE INDICAR LAS TABLAS SOBRE LAS CUALES SE REALIZA LA EJECUCIÓN DE SENTENCIAS.", ;
						upper( loError.uservalue.oInformacion.Item[1].cMensaje ) )
				endtry

				try
					.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .t.", "UNATABLA", "", "micursor" )
					this.asserttrue( "Debería haber dado error (2)", .f. )
				catch to loError
					this.assertequals( "El error no es el correcto (2)", ;
						"SE DEBE INDICAR LA DATASESSION EN LA QUE SE DESEA CREAR EL CURSOR.", ;
						upper( loError.uservalue.oInformacion.Item[1].cMensaje ) )
				endtry
			else
******* SQLSERVER **************
				.cTipoDeBase = "SQLSERVER"
				.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .t.", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (1)", ;
					"SELECT * FROM .UNATABLA WHERE BOOLEANO = 1", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .f.", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (2)", ;
					"SELECT * FROM .UNATABLA WHERE BOOLEANO = 0", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT GOLIBRERIAS.DesEncriptar192( campo ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (3)", ;
					"SELECT FUNCIONES.DESENCRIPTAR192( CAMPO ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT alltrim( ' texto ' ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (4)", ;
					"SELECT FUNCIONES.ALLTRIM( ' TEXTO ' ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT ctot( 'fecha' ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (5)", ;
					"SELECT FUNCIONES.CTOT( 'FECHA' ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT datetime() FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (6)", ;
					"SELECT FUNCIONES.DATETIME() FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT dtos( date() ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (7)", ;
					"SELECT FUNCIONES.DTOS( GETDATE() ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT empty( '' ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (8)", ;
					"SELECT FUNCIONES.EMPTY( '' ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT padl( '', 10, ' ' ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (9)", ;
					"SELECT FUNCIONES.PADL( '', 10, ' ' ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT padr( '', 10, ' ' ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (10)", ;
					"SELECT FUNCIONES.PADR( '', 10, ' ' ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )

				.EjecutarSentencias( "SELECT val( '0' ) FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - sintaxis fox (11)", ;
					"SELECT FUNCIONES.VAL( '0' ) FROM .UNATABLA", upper( alltrim( .cSentenciaEjecutada ) ) )


				.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (1)", ;
					"SELECT * FROM .UNATABLA", upper( .cSentenciaEjecutada ) )

				.EjecutarSentencias( "SELECT * FROM TABLA1", "TABLA1" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (2)", ;
					"SELECT * FROM .TABLA1", upper( .cSentenciaEjecutada ) )

				.EjecutarSentencias( "SELECT * FROM TABLA1 INNER JOIN TABLA2", "TABLA1, TABLA2" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (3)", ;
					"SELECT * FROM .TABLA1 INNER JOIN .TABLA2", upper( .cSentenciaEjecutada ) )

				.EjecutarSentencias( "SELECT * FROM TABLA2 INNER JOIN TABLA1", "TABLA1, TABLA2" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (4)", ;
					"SELECT * FROM .TABLA2 INNER JOIN .TABLA1", upper( .cSentenciaEjecutada ) )

				.EjecutarSentencias( "SELECT * FROM UNATABLA", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (5)", ;
					"SELECT * FROM .UNATABLA", upper( .cSentenciaEjecutada ) )

				.EjecutarSentencias( "SELECT * FROM UNATABLA WHERE CAMPO = 'asdf'", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (6)", ;
					"SELECT * FROM .UNATABLA WHERE CAMPO = 'asdf'", ;
					.cSentenciaEjecutada )

				.EjecutarSentencias( "SELECT EMPCOD FROM EMP WHERE EMPCOD = 'asdf'", "EMP" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (7)", ;
					"SELECT EMPCOD FROM PUESTO.EMP WHERE EMPCOD = 'asdf'", ;
					.cSentenciaEjecutada )

				.EjecutarSentencias( "SELECT EMPCOD FROM EMP WHERE EMPCOD = 'asdf'", "EMP" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (8)", ;
					"SELECT EMPCOD FROM PUESTO.EMP WHERE EMPCOD = 'asdf'", ;
					.cSentenciaEjecutada )

				.EjecutarSentencias( "DELETE FROM EMP WHERE EMPCOD = 'asdf'", "EMP" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (9)", ;
					"DELETE FROM PUESTO.EMP WHERE EMPCOD = 'asdf'", ;
					.cSentenciaEjecutada )

				.EjecutarSentencias( "DELETE FROM " + _screen.zoo.app.cBDMaster + "." + _screen.zoo.app.cSchemaDefault + ".EMP WHERE EMPCOD = 'asdf'", "" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (10)", ;
					"DELETE FROM " + _screen.zoo.app.cBDMaster + "." + _screen.zoo.app.cSchemaDefault + ".EMP WHERE EMPCOD = 'asdf'", ;
					.cSentenciaEjecutada )

				.EjecutarSentencias( "insert into UnaTabla ( campo1, campo2, campo3 ) values ( 'asdf', 'ASFD', 'AsDf' )", "UNATABLA" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (11)", ;
					"insert into .UNATABLA ( campo1, campo2, campo3 ) values ( 'asdf', 'ASFD', 'AsDf' )", ;
					.cSentenciaEjecutada )
				
				try
					.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .t." )
					this.asserttrue( "Debería haber dado error (3)", .f. )
				catch to loError
					this.assertequals( "El error no es el correcto (3)", ;
						"SE DEBE INDICAR LAS TABLAS SOBRE LAS CUALES SE REALIZA LA EJECUCIÓN DE SENTENCIAS.", ;
						upper( loError.uservalue.oInformacion.Item[1].cMensaje ) )
				endtry

				try
					.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .t.", "UNATABLA", "", "micursor" )
					this.asserttrue( "Debería haber dado error (4)", .f. )
				catch to loError
					this.assertequals( "El error no es el correcto (4)", ;
						"SE DEBE INDICAR LA DATASESSION EN LA QUE SE DESEA CREAR EL CURSOR.", ;
						upper( loError.uservalue.oInformacion.Item[1].cMensaje ) )
				endtry

				.EjecutarSentencias( "insert into UnaTabla ( campo1, campo2, campo3 ) Select unatabla.campo1, " + ;
										"unatabla.campo2, otratabla.campo3 from unatabla, otraTabla,otraMas where otraTabla.campo3 = 'pepe'", "UNATABLA,OTRATABLA,OTRAMAS" )
				this.assertequals( "La sentencia no esta correctamente armada - tabla (12)", "insert into .UNATABLA ( campo1, campo2, campo3 ) Select unatabla.campo1, " + ;
										"unatabla.campo2, otratabla.campo3 from .UNATABLA, .OTRATABLA,.OTRAMAS where otraTabla.campo3 = 'pepe'", ;
							.cSentenciaEjecutada )
				
			endif

******* DESCONOCIDA_O_MAL_ESCRITA **************
			.cTipoDeBase = "DESCONOCIDA_O_MAL_ESCRITA"
			try
				.EjecutarSentencias( "SELECT * FROM UNATABLA where booleano = .t.", "UNATABLA.DBF" )
				this.asserttrue( "Debería haber dado error (5)", .f. )
			catch to loError
				this.assertequals( "El error no es el correcto (5)", ;
					"EL TIPO DE BASE DE DATOS ESPECIFICADA PARA LA APLICACIÓN, ES INCORRECTA.", ;
					upper( loError.uservalue.oInformacion.Item[1].cMensaje ) )
			endtry
		endwith
	endfunc 
    *-----------------------------------------------------------------------------------------
    function zTestNativaObtenerFormatoFecha
        local ldFecha as Date, lcRetorno as String
        
        ldFecha = ctod("10/08/2010")
        lcRetorno = goServicios.Datos.ObtenerFechaFormateada( ldFecha )
        
        this.assertequals( "El formato de la fecha es incorrecto", "{10/08/10}", lcRetorno )
        
    endfunc
    *-----------------------------------------------------------------------------------------
    function zTestSqlServerObtenerFormatoFecha
        local ldFecha as Date, lcRetorno as String
        
        ldFecha = ctod("10/08/2010")
        lcRetorno = goServicios.Datos.ObtenerFechaFormateada( ldFecha )
        
        this.assertequals( "El formato de la fecha es incorrecto", "Convert(DateTime, '20100810')", alltrim(lcRetorno) )
        
    endfunc
	*-----------------------------------------------------------------------------------------
	function zTestNativaActualizar
		local loZooData as ZooData of ZooData.prg, lcRutaTabla as String, lcRutaTemporal as String, ;
			lcTablaAuxiliar as String 

		loZooData = newobject( 'ZooData', 'ZooData.prg' )
		loZooData.AbreTabla( 'sys_s' )
		this.asserttrue( "La tabla SYS_S se abrio", !used('sys_s') )

		lcRutaTabla = lower( addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) + 'DBF\' ) 
		loZooData.AbreTabla( 'sys_s', '', 0, lcRutaTabla )
		this.asserttrue( "La tabla SYS_S no se abrio", used('sys_s') )

		if used('sys_s')
			lcRutaTablaAbierta = addbs( justpath( lower( dbf('sys_s') ) ) )
			this.assertequals( "La tabla SYS_S no se abrio en la ruta correcta", ;
				lcRutaTabla, lcRutaTablaAbierta )
		endif

		loZooData.CerrarTablas( 'sys_s' )
		this.asserttrue( "La tabla SYS_S no se cerro", !used('sys_s') )

		lcRutaTemporal = addbs( _screen.zoo.obtenerrutatemporal() )
		lcTablaAuxiliar  = 'sys_s' + sys( 2015 )
		create table ( lcRutaTemporal + lcTablaAuxiliar ) ( codigo c(1) )
		use in ( lcTablaAuxiliar )
		if used( lcTablaAuxiliar )
			this.asserttrue( "La tabla auxiliar " + lcRutaTemporal + lcTablaAuxiliar + " no se pudo crear y cerrar con exito", .f. )
		else
			use ( lcRutaTemporal + lcTablaAuxiliar ) alias sys_s in 0

			lcRutaTabla = lower( addbs( _screen.zoo.app.obtenerrutasucursal( _screen.zoo.app.cSucursalActiva ) ) + 'DBF\' ) 

			loZooData.AbreTabla( 'sys_s', '', 0, lcRutaTabla )
			lcRutaTablaAbierta = addbs( justpath( lower( dbf('sys_s') ) ) )

			this.assertequals( "La tabla SYS_S no se abrio de la ruta correcta", ;
				lcRutaTabla, lcRutaTablaAbierta )
			
			loZooData.CerrarTablas( 'sys_s' )
			this.asserttrue( "La tabla SYS_S no se cerro al testear que respete bien las rutas", !used('sys_s') )
		endif

		loZooData.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestNATIVATraductorSentencias
		this.assertequals( "Error en el colaborador que esta usando para traducir las sentencias", "ZooLogicSA.TraductorSentencias.TraductorSentenciasNativa", goservicios.datoS.oTraductor.getType().toString() )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVERTraductorSentencias
		this.assertequals( "Error en el colaborador que esta usando para traducir las sentencias", "ZooLogicSA.TraductorSentencias.TraductorSentenciasSqlServer", goservicios.datoS.oTraductor.getType().toString() )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarExistenciaEnEntidadConCodigoExistente
		local loEntidadParaBusqueda as entidad OF entidad.prg, lcEntidadBuscada as String
		lcEntidadBuscada = "Cuba"
		_screen.Mocks.AgregarMock( lcEntidadBuscada )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'EsEdicion', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'EsNuevo', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Limpiar', .t. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Cargar', .t. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'ObtenerNombre', lcEntidadBuscada )
		_Screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Cargamanual', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Obtenerfuncionalidades', "" ) 
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Inicializarcomportamientocodigosugerido', null, "'*OBJETO'" )
		_screen.Mocks.AgregarSeteoMetodo( lcEntidadBuscada, "ObtenerAtributoClavePrimaria", "Codigo" )
		_Screen.Mocks.AgregarMock( lcEntidadBuscada + "AD" )
		_Screen.Mocks.AgregarMock( lcEntidadBuscada + "AD_SQLSERVER" )
		_screen.Mocks.AgregarSeteoMetodoAccesoADatos( lcEntidadBuscada, 'Inyectarentidad', .t., "'*OBJETO'" )
		_screen.Mocks.AgregarSeteoMetodoAccesoADatos( lcEntidadBuscada, 'ConsultarPorClavePrimaria', .t. )
		
		loEntidadParaBusqueda = _screen.Zoo.InstanciarEntidad( lcEntidadBuscada )
		this.assertequals( "Debió dar que existia la entidad buscada.", .t., goServicios.Datos.ValidarExistenciaEnEntidad( loEntidadParaBusqueda, "0" ) )

		loEntidadParaBusqueda.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarExistenciaEnEntidadConCodigoInexistente
		local loEntidadParaBusqueda as entidad OF entidad.prg, lcEntidadBuscada as String, loEntidadQueConsume as Entidad OF Entidad.prg, lcEntidadQueConsume as String, loInformacion as zoocoleccion OF zoocoleccion.prg
		lcEntidadBuscada = "Cuba"
		_screen.Mocks.AgregarMock( lcEntidadBuscada )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'EsEdicion', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'EsNuevo', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Limpiar', .t. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Cargar', .t. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'ObtenerNombre', lcEntidadBuscada )
		_Screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Cargamanual', .F. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Obtenerfuncionalidades', "" ) 
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Inicializarcomportamientocodigosugerido', null, "'*OBJETO'" )
		_screen.Mocks.AgregarSeteoMetodo( lcEntidadBuscada, "ObtenerAtributoClavePrimaria", "Codigo" )
		_Screen.Mocks.AgregarMock( lcEntidadBuscada + "AD" )
		_Screen.Mocks.AgregarMock( lcEntidadBuscada + "AD_SQLSERVER" )
		_screen.Mocks.AgregarSeteoMetodoAccesoADatos( lcEntidadBuscada, 'Inyectarentidad', .t., "'*OBJETO'" )
		_screen.Mocks.AgregarSeteoMetodoAccesoADatos( lcEntidadBuscada, 'ConsultarPorClavePrimaria', .f. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidadBuscada, 'Consultarporclaveprimariasugerida', .F. )		
		
		lcEntidadQueConsume = "Honduras"

		loEntidadParaBusqueda = _screen.Zoo.InstanciarEntidad( lcEntidadBuscada )
		loEntidadQueConsume = _screen.Zoo.InstanciarEntidad( lcEntidadQueConsume )

		this.assertequals( "Debió dar que no existia la entidad buscada.", .f., goServicios.Datos.ValidarExistenciaEnEntidad( loEntidadParaBusqueda, "0", loEntidadQueConsume ) )
		loInformacion = loEntidadQueConsume.ObtenerInformacion()
		this.assertequals( "La información agregada no es la esperada.", "El dato buscado 0 de la entidad CUBA no existe.", ;
			loInformacion.Item[ 1 ].cMensaje )

		loEntidadParaBusqueda.release()
		loEntidadQueConsume.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_VerificaPermiteModificarOEliminarEnGoDatosEjecutarSentencias
		local loObjeto as Object
		
	*Arrange (Preparar)

		loObjeto = newobject( "ObjetoAux" )
		loObjeto.lPaso = .f.
		bindevent( _screen.zoo.app, "PermiteModificarOEliminarEnBase", loObjeto, "MetodoParaBindear" )

	*Act (Actuar)
		try
			goDatos.EjecutarSentencias( "Update tabla set campo = 'valor'", "tabla" )
		catch
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "Debería haber pasado por el método para verificar si puede modificar o eliminar una base según si es réplica o no.", loObjeto.lPaso )
		
		loObjeto = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_PermitirModificarPorqueLaBaseNoEsReplica
		local llPermite as Boolean, loApp as Object, loAppAnt as Object
		
	*Arrange (Preparar)
		loAppAnt = _screen.zoo.app
		loApp = newobject( "AplicacionNucleoTest" )
		loApp.lEsBaseReplica = .f.
		_screen.zoo.app = loApp
		llPermite = .t.		

	*Act (Actuar)
		try
			llPermite = loApp.PermiteModificarOEliminarEnBase( "Update tabla set campo = 'valor'" )
		catch
			llPermite = .f.
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "Debería haber permitido ejecutar esta sentencia en una base que no es réplica.", llPermite )		
		
		_screen.zoo.app = loAppAnt
		loApp.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_PermitirEjecutarSentenciaEnBaseReplicaPorqueNoModificaNiEliminaNiNuevo
		local llPermite as Boolean, loApp as Object, loAppAnt as Object
		
	*Arrange (Preparar)
		loAppAnt = _screen.zoo.app
		loApp = newobject( "AplicacionNucleoTest" )
		loApp.lEsBaseReplica = .t.
		_screen.zoo.app = loApp
		llPermite = .t.		

	*Act (Actuar)
		try
			llPermite = loApp.PermiteModificarOEliminarEnBase( "Select * from tabla" )
		catch
			llPermite = .f.
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "Debería haber permitido ejecutar esta sentencia en una base que no es réplica.", llPermite )		
		
		_screen.zoo.app = loAppAnt
		loApp.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_PermitirEjecutarSentenciaEnBaseReplicaPorqueNoEsSobreTablaSucursal
		local llPermite as Boolean, loApp as Object, loAppAnt as Object, loerror as Exception, ;
			loBackupServicioEstructura as Object
		
	*Arrange (Preparar)
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "PUESTO", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "PUESTO", "[*COMODIN]" )
		loApp = newobject( "AplicacionNucleoTest" )
		loApp.lEsBaseReplica = .t.
		llPermite = .t.		

	*Act (Actuar)
		try
			loBackupServicioEstructura = goServicios.Estructura
		 	goServicios.Estructura = null
			llPermite = loApp.PermiteModificarOEliminarEnBase( "Delete from tabladepuesto", "tabladepuesto" )
		catch to loerror
			this.asserttrue( "No debe dar error. " + loerror.message, .f. )
			llPermite = .f.
		finally
			goServicios.Estructura = loBackupServicioEstructura
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "Debería haber permitido ejecutar esta sentencia sobre una tabla de puesto.", llPermite )		
		
		loApp.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_NoPermitirModificarPorquLaBaseEsReplica
		local llPermite as Boolean, loApp as Object, loAppAnt as Object, lcMensajeError as string, lcMensajeErrorExpected as string, ;
				loError as Exception, lnErrorInterno as Integer, lnErrorInternoExpected, ;
				loBackupServicioEstructura as Object
		
	*Arrange (Preparar)
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		loAppAnt = _screen.zoo.app
		loApp = newobject( "AplicacionNucleoTest" )
		loApp.lEsBaseReplica = .t.
		_screen.zoo.app = loApp
		llPermite = .t.		
		lcMensajeError = ""
		lnErrorInterno = 0
		lcMensajeErrorExpected = "No está permitido modificar registros en una base de datos de réplica."
		lnErrorInternoExpected = 403

	*Act (Actuar)
		try
			loBackupServicioEstructura = goServicios.Estructura
		 	goServicios.Estructura = null
			goDatos.EjecutarSentencias( "Update tabla set campo = 'valor'", "tabla" )
		catch to loError
			llPermite = .f.
			lcMensajeError = loError.UserValue.oInformacion.Item[3].cMensaje
			lnErrorInterno = loError.UserValue.nZooErrorNo
		finally
			goServicios.Estructura = loBackupServicioEstructura		
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "No debería haber permitido ejecutar esta sentencia en una base réplica.", !llPermite )
		this.AssertEquals( "No es el mensaje de error correcto.", lcMensajeErrorExpected, lcMensajeError )
*//		this.AssertEquals( "No es el número de error correcto.", lnErrorInternoExpected, lnErrorInterno )
		
		_screen.zoo.app = loAppAnt
		loApp.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_NoPermitirEliminarPorquLaBaseEsReplica
		local llPermite as Boolean, loApp as Object, loAppAnt as Object, lcMensajeError as string, lcMensajeErrorExpected as string, ;
				loError as Exception, lnErrorInterno as Integer, lnErrorInternoExpected, ;
				loBackupServicioEstructura as Object
		
	*Arrange (Preparar)
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		loAppAnt = _screen.zoo.app
		loApp = newobject( "AplicacionNucleoTest" )
		loApp.lEsBaseReplica = .t.
		_screen.zoo.app = loApp
		llPermite = .t.		
		lcMensajeError = ""
		lnErrorInterno = 0
		lcMensajeErrorExpected = "No está permitido modificar registros en una base de datos de réplica."
		lnErrorInternoExpected = 403

	*Act (Actuar)
		try
			loBackupServicioEstructura = goServicios.Estructura
		 	goServicios.Estructura = null
			goDatos.EjecutarSentencias( "Delete tabla", "tabla" )
		catch to loError
			llPermite = .f.
			lcMensajeError = loError.UserValue.oInformacion.Item[3].cMensaje
			lnErrorInterno = loError.UserValue.nZooErrorNo
		finally
			goServicios.Estructura = loBackupServicioEstructura		
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "No debería haber permitido ejecutar esta sentencia en una base réplica.", !llPermite )
		this.AssertEquals( "No es el mensaje de error correcto.", lcMensajeErrorExpected, lcMensajeError )
*		this.AssertEquals( "No es el número de error correcto.", lnErrorInternoExpected, lnErrorInterno )
		
		_screen.zoo.app = loAppAnt
		loApp.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_NoPermitirNuevoPorquLaBaseEsReplica
		local llPermite as Boolean, loApp as Object, loAppAnt as Object, lcMensajeError as string, lcMensajeErrorExpected as string, ;
				loError as Exception, lnErrorInterno as Integer, lnErrorInternoExpected, ;
				loBackupServicioEstructura as Object
		
	*Arrange (Preparar)
		this.agregarmocks( "ServicioEstructuraNativa,ServicioEstructuraSqlServer,ServicioEstructura" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURASQLSERVER', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'SERVICIOESTRUCTURANATIVA', 'Obtenerubicacion', "SUCURSAL", "[*COMODIN]" )
		loAppAnt = _screen.zoo.app
		loApp = newobject( "AplicacionNucleoTest" )
		loApp.lEsBaseReplica = .t.
		_screen.zoo.app = loApp
		llPermite = .t.		
		lcMensajeError = ""
		lnErrorInterno = 0
		lcMensajeErrorExpected = "No está permitido modificar registros en una base de datos de réplica."
		lnErrorInternoExpected = 403

	*Act (Actuar)
		try
			loBackupServicioEstructura = goServicios.Estructura
		 	goServicios.Estructura = null
			goDatos.EjecutarSentencias( "Insert Into tabla ( campo ) values ( 'a' )", "tabla" )
		catch to loError
			llPermite = .f.
			lcMensajeError = loError.UserValue.oInformacion.Item[3].cMensaje
			lnErrorInterno = loError.UserValue.nZooErrorNo
		finally
			goServicios.Estructura = loBackupServicioEstructura		
		endtry

	*Assert (Afirmar)
		this.AssertTrue( "No debería haber permitido ejecutar esta sentencia en una base réplica.", !llPermite )
		this.AssertEquals( "No es el mensaje de error correcto.", lcMensajeErrorExpected, lcMensajeError )
*		this.AssertEquals( "No es el número de error correcto.", lnErrorInternoExpected, lnErrorInterno )
		
		_screen.zoo.app = loAppAnt
		loApp.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatos_NoExisteBase
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, loLista as zoocoleccion OF zoocoleccion.prg
		_Screen.zoo.app.CargarSucursales()
		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTest2", "zTestServicioDatos.prg" )
		loServicioDatos.cTipoDeBase = "SQLSERVER"
		
		************ Si no existe la base entonces no se debe envolver nada. ************
		loServicioDatos.cSentenciaEjecutada = ""
		
		loServicioDatos.EjecutarSentencias( "Select campo1, campo2, alltrim(campo2), * from " + _Screen.zoo.app.nombreProducto + "_BaseQueNoExiste.zoologic.art order by 1", "art" )
		this.assertequals( "Problema 2.", "Select campo1, campo2, funciones.alltrim(campo2), * from " + _Screen.zoo.app.nombreProducto + "_BaseQueNoExiste.zoologic.art order by 1", loServicioDatos.cSentenciaEjecutada )
		

		loServicioDatos.release()
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatos_ExisteBase
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, loLista as zoocoleccion OF zoocoleccion.prg
		_Screen.zoo.app.CargarSucursales()
		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTest2", "zTestServicioDatos.prg" )
		loServicioDatos.cTipoDeBase = "SQLSERVER"
		
		************ Base que se debe ernvolver en parantesis nada. ************
		loServicioDatos.cSentenciaEjecutada = ""

		loServicioDatos.EjecutarSentencias( "Select * from " + _Screen.zoo.app.nombreProducto + "_cOUNTRYS.zoologic.art order by 1", "art" )
		this.assertequals( "Problema 1.", "Select * from [" + _Screen.zoo.app.nombreProducto + "_COUNTRYS].zoologic.art order by 1", loServicioDatos.cSentenciaEjecutada )

		loServicioDatos.release()	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatos_CacheBases
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, loLista as zoocoleccion OF zoocoleccion.prg
		_Screen.zoo.app.CargarSucursales()
		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTest2", "zTestServicioDatos.prg" )
		loServicioDatos.cTipoDeBase = "SQLSERVER"
		
	
		************ Si se agregar bases de datos la lista se debe refrescar. ************
		loServicioDatos.EjecutarSentencias( "Select * from " + _Screen.zoo.app.nombreProducto + "_BASE cOn EspacIo.zoologic.art order by 1", "art" ) &&Aqui se actualiza el cache
		loServicioDatos.cSentenciaEjecutada = ""
		loLista = loServicioDatos.__ObtenerListaDeBasesDeDatos()
		lnCantidad = loLista.count
		loLista.Agregar( "baseFake" )	
		loServicioDatos.EjecutarSentencias( "Select campo1, campo2, alltrim(campo2), * from " + _Screen.zoo.app.nombreProducto + "_BASE cOn EspacIo.zoologic.art order by 1", "art" ) &&Aqui se actualiza el cache
		loLista = loServicioDatos.__ObtenerListaDeBasesDeDatos()
		this.assertequals( "Al agregar o quitar bases de datos se debe mantener el cache.", lnCantidad, loLista.Count )

		loServicioDatos.release()
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatos_EnvolverBaseEspacios
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, loLista as zoocoleccion OF zoocoleccion.prg
		_Screen.zoo.app.CargarSucursales()
		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTest2", "zTestServicioDatos.prg" )
		loServicioDatos.cTipoDeBase = "SQLSERVER"
		
		************ Si consulta con una base de datos con espacio se debe envolver entre corchetes. ************
		local lncantidadFilas as Integer, lncantidadColumnas as Integer

		lncantidadFilas = alen( _screen.zoo.app.asucursales, 1 )
		lncantidadColumnas = alen( _screen.zoo.app.asucursales, 2 )
		dimension _screen.zoo.app.asucursales[lncantidadFilas+1,lncantidadColumnas]
		_screen.zoo.app.asucursales[lncantidadFilas +1,1] = "BasE Con espacios"
		
		loServicioDatos.cSentenciaEjecutada = ""

		loServicioDatos.EjecutarSentencias( "Select campo1, campo2, alltrim(campo2), * from " + _Screen.zoo.app.nombreProducto + "_BasE Con espacios.zoologic.art order by 1", "art" )
		loLista = loServicioDatos.__ObtenerListaDeBasesDeDatos()
		this.assertequals( "Al agregar o quitar bases de datos se debe mantener el cache.", "Select campo1, campo2, funciones.alltrim(campo2), * from [" + _Screen.zoo.app.nombreProducto + "_BasE Con espacios].zoologic.art order by 1", loServicioDatos.cSentenciaEjecutada )
			
		loServicioDatos.release()
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatosCentral
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, ;
			lcSql as string, lcSqlEsperado as String

		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTestParaProbarEnvolverEntreCorchetes", "zTestServicioDatos.prg" )
		
		lcSql = "Select campo1, campo2, alltrim(campo2), * from DRAGONFISH_CENTRAL.zoologic.art order by 1"
		lcSqlEsperado = "Select campo1, campo2, alltrim(campo2), * from [DRAGONFISH_CENTRAL].zoologic.art order by 1"
		
		loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsASC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql asc", lcSqlEsperado, lcSql  )
		
        loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsDESC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql desc", lcSqlEsperado, lcSql )
				
		loServicioDatos.release()
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatosCentralDos
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, ;
			lcSql as string, lcSqlEsperado as String

		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTestParaProbarEnvolverEntreCorchetes", "zTestServicioDatos.prg" )

		
		lcSql = "Select campo1, campo2, alltrim(campo2), * from DRAGONFISH_CENTRAL2.zoologic.art order by 1"
		lcSqlEsperado = "Select campo1, campo2, alltrim(campo2), * from [DRAGONFISH_CENTRAL2].zoologic.art order by 1"

		loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsASC()		
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql asc", lcSqlEsperado, lcSql  )
		
        loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsDESC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql desc", lcSqlEsperado, lcSql )
				
						
		loServicioDatos.release()
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatosCentralDosConUnions
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, ;
			lcSql as string, lcSqlEsperado as String

		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTestParaProbarEnvolverEntreCorchetes", "zTestServicioDatos.prg" )
		
		
        lcSql = "SELECT * FROM DRAGONFISH_CENTRAL2.ZooLogic.Art UNION " + ;
						  "SELECT * FROM DRAGONFISH_C2.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_CENTRALES_UNIDAS.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_2B.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_CENTRAL.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_DEMO CUATRO2.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_DEMO CUATRO OCHO.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_CENTRAL.ZooLogic.Art UNION " + ;
                          "WHERE DRAGONFISH_C2.ZooLogic.Art.CAMPO1 = true"
                          
        lcSqlEsperado = "SELECT * FROM [DRAGONFISH_CENTRAL2].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_C2].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_CENTRALES_UNIDAS].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_2B].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_CENTRAL].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_DEMO CUATRO2].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_DEMO CUATRO OCHO].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_CENTRAL].ZooLogic.Art UNION " + ;
                          "WHERE [DRAGONFISH_C2].ZooLogic.Art.CAMPO1 = true";
                          	
        loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsASC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql asc", lcSqlEsperado, lcSql )

		loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsDESC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql desc", lcSqlEsperado, lcSql )
		
		loServicioDatos.release()
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLSERVER_EnvolverEntreCorchetesLaBaseDeDatosCentralDosConUnionsYMinusculas
		local loServicioDatos as ServicioDatosTest2 of zTestServicioDatos.prg, ;
			lcSql as string, lcSqlEsperado as String

		loServicioDatos = _screen.zoo.crearobjeto( "ServicioDatosTestParaProbarEnvolverEntreCorchetes", "zTestServicioDatos.prg" )
		
		
        lcSql = "SELECT * FROM DRAGONFISH_CENTRAL2.ZooLogic.Art UNION " + ;
						  "SELECT * FROM DRAGONFISH_C2.ZooLogic.Art UNION " + ;
                          "SELECT * FROM dragonfish_CENTralES_UNIDAS.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_2B.ZooLogic.Art UNION " + ;
                          "select * FROM dragonfish_CENTral.ZooLogic.Art UNION " + ;
                          "SELECT * FROM dragonfish_DEMO CUatRO2.ZooLogic.Art UNION " + ;
                          "SELECT * FROM DRAGONFISH_DEMO CUATrO OChO.ZooLogic.Art UNION " + ;
                          "SELECT * FROM dragonfish_CENTral.ZooLogic.Art UNION " + ;
                          "WHERE DRAGONFISH_C2.ZooLogic.Art.CAMPO1 = true"
                          
        lcSqlEsperado = "SELECT * FROM [DRAGONFISH_CENTRAL2].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_C2].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_CENTRALES_UNIDAS].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_2B].ZooLogic.Art UNION " + ;
                          "select * FROM [DRAGONFISH_CENTRAL].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_DEMO CUATRO2].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_DEMO CUATRO OCHO].ZooLogic.Art UNION " + ;
                          "SELECT * FROM [DRAGONFISH_CENTRAL].ZooLogic.Art UNION " + ;
                          "WHERE [DRAGONFISH_C2].ZooLogic.Art.CAMPO1 = true";
                          	
        loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsASC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql asc", lcSqlEsperado, lcSql )

		loServicioDatos._TEST_ListaDeBasesDeDatos = ObtenerListaDeDBsDESC()
		lcSql = loServicioDatos._TEST_EnvolverBaseDeDatosEntreCorchetes( lcSql )
		this.assertequals( "probando la t-sql desc", lcSqlEsperado, lcSql )
		
		loServicioDatos.release()
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestObtenerEntidadesEnMenu
		local loServicioEstructura as ServicioEstructura of ServicioEstructura.prg
		
			loServicioEstructura = _screen.zoo.crearobjeto( "servicioestructura" )
			_screen.mocks.agregarmock( "Din_EstructuraAdn" )
			loServicioEstructura.oDinEstructuraAdn = _screen.zoo.CrearObjeto( "Mock_Din_EstructuraAdn" )
			lcXmlEntidades = filetostr( addbs( _screen.zoo.cRutaInicial ) + "\clasesdeprueba\XmlEntidadesEnMenu.txt" )
			_screen.mocks.AgregarSeteoMetodo( 'DIN_ESTRUCTURAADN', 'Obtenerentidadesmenuprincipalitems', lcXmlEntidades )
			lcNombreCursor = loServicioEstructura.ObtenerNombreCursorEstructura()
			create cursor &lcNombreCursor ( campo1 c(19))
			
			lcXml = loServicioEstructura.ObtenerEntidadesmenuprincipalitems( set ( "DataSession" ) )
			
			this.assertequals( "Cantidad de entidades incorrecta.", 2, reccount( lcXml ) )

			use in select( lcNombreCursor )
			use in select( lcXml )
			loServicioEstructura.Release()
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerReemplazoSintaxisBooleanos
		local loDatos as Object, lcSentencia as String, lcResultadoEsperado as String
		
		loDatos = CreateObject( "FakeServicioDatos" )
		lcSentencia = "update zoologic.Tabla set campo1 = '.t.e.s.t.', campo2 = .t. where campo3 = '.T.E.S.T' and campo4 = .T."
		lcResultadoEsperado = "update zoologic.Tabla set campo1 = '.t.e.s.t.', campo2 = 1 where campo3 = '.T.E.S.T' and campo4 = 1"
		lcSentencia = loDatos.FakeObtenerReemplazoSintaxisBooleanos( lcSentencia, ".t.", "1" )
		this.assertequals( "No reemplazó correctamente los booleanos", lcSentencia , lcResultadoEsperado )
		
		lcSentencia = "select funciones.ObtenerAlgo('.F.A.L.S.O.',.f.,'cod .f. cod',.F.)"
		lcResultadoEsperado = "select funciones.ObtenerAlgo('.F.A.L.S.O.',0,'cod .f. cod',0)"
		lcSentencia = loDatos.FakeObtenerReemplazoSintaxisBooleanos( lcSentencia, ".f.", "0" )
		this.assertequals( "No reemplazó correctamente los booleanos", lcSentencia , lcResultadoEsperado )
		
		loDatos = null
	endfunc

enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
function ObtenerListaDeDBsDESC() as Collection
	local loLista as Collection, lnCantidad as Integer, i as Integer, loListaOrdenada as Collection

	loLista = ObtenerListaDeDBs()
	loListaOrdenada =_Screen.zoo.crearobjeto( "zoocoleccion" )
	lnCantidad = loLista.Count
	create cursor ordenDecendente ( lista c(30) )
	select ordenDecendente 
	
	

	for i = 1 to lnCantidad
		insert into ordenDecendente ( lista ) values ( loLista.item(i) )
	endfor
	
	select lista from ordenDecendente order by lista desc into array laListaOrdenada
	
	for i = 1 to lnCantidad
		loListaOrdenada.Agregar( laListaOrdenada[i] )
	endfor

	use in select( "ordenDecendente" )
	return loListaOrdenada
endfunc

*--------------------------------------------------------------------
function ObtenerListaDeDBsASC() as Collection
	local loLista as Collection, lnCantidad as Integer, i as Integer, loListaOrdenada as Collection

	loLista = ObtenerListaDeDBs()
	loListaOrdenada =_Screen.zoo.crearobjeto( "zoocoleccion" )
	lnCantidad = loLista.Count
	create cursor ordenDecendente ( lista c(30) )
	select ordenDecendente 
	
	

	for i = 1 to lnCantidad
		insert into ordenDecendente ( lista ) values ( loLista.item(i) )
	endfor
	
	select alltrim( lista ) as lista from ordenDecendente order by lista asc into array laListaOrdenada
	
	for i = 1 to lnCantidad
		loListaOrdenada.Agregar( alltrim( laListaOrdenada[i] ) )
	endfor

	use in select( "ordenDecendente" )
	return loListaOrdenada
endfunc

*--------------------------------------------------------------------
function ObtenerListaDeDBs() as Collection
    retorno = _Screen.zoo.crearobjeto( "zoocoleccion" )

    retorno.Agregar( "DRAGONFISH_CENTRAL" )
    retorno.Agregar( "DRAGONFISH_CENTRAL2" )
    retorno.Agregar( "DRAGONFISH_DEMO2" )
    retorno.Agregar( "DRAGONFISH_DEMO" )
    retorno.Agregar( "DRAGONFISH_DEMOTi" )
    retorno.Agregar( "DRAGONFISH_CENTRALES" )
    retorno.Agregar( "DRAGONFISH_CENTRALES_UNIDAS" )
    retorno.Agregar( "DRAGONFISH_DEMO3" )
    retorno.Agregar( "DRAGONFISH_DEMO CUATRO" )
    retorno.Agregar( "DRAGONFISH_DEMO CINCO" )
    retorno.Agregar( "DRAGONFISH_DEMO CUATRO OCHO" )
    retorno.Agregar( "DRAGONFISH_CENTRAL" )
    retorno.Agregar( "DRAGONFISH_CENTRAL2" )
    retorno.Agregar( "DRAGONFISH_CENTRAL3" )
    retorno.Agregar( "DRAGONFISH_CENTRALYIRIGOYEC" )
    retorno.Agregar( "DRAGONFISH_C1" )
    retorno.Agregar( "DRAGONFISH_C2" )
    retorno.Agregar( "DRAGONFISH_D2" )
    retorno.Agregar( "DRAGONFISH_E2" )
    retorno.Agregar( "DRAGONFISH_DEMO CUATRO2" )
    retorno.Agregar( "DRAGONFISH_DEMO CUATRO3" )
    retorno.Agregar( "DRAGONFISH_2A" )
    retorno.Agregar( "DRAGONFISH_2B" )
    retorno.Agregar( "DRAGONFISH_2B" )

    return retorno
endfunc 

*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class ServicioDatosTestParaProbarEnvolverEntreCorchetes as serviciodatos of serviciodatos.prg

	_TEST_ListaDeBasesDeDatos = null
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDeBasesDeDatosParaSQL() as Void
		return this._TEST_ListaDeBasesDeDatos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function _TEST_EnvolverBaseDeDatosEntreCorchetes( tcCadenaSQl as String ) as String
		return this.EnvolverBaseDeDatosEntreCorchetes( tcCadenaSQl ) 
	endfunc 
	
enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class ServicioDatosTest2 as serviciodatos of serviciodatos.prg

	cSentenciaEjecutada = ""
	cTablas = ""
	cTipoDeBase = ""
	
	*-----------------------------------------------------------------------------------------
	function __ObtenerListaDeBasesDeDatos() as Void
		return this._ListaDeBasesDeDatosParaSQL
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsSqlServer() as Void
		return this.cTipoDeBase = "SQLSERVER"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsNativa() as Void
		return this.cTipoDeBase = "NATIVA"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarScriptNativa( tcScript, tcTabla, tcCursor as string, tnSession as integer ) as Void
		This.cSentenciaEjecutada = tcScript
		this.cTablas = tcTabla
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarSQL( tcSql as String, tcCursor as string, tnSession as integer ) as String
		This.cSentenciaEjecutada = tcSql
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEsquema( tcTabla as String ) as String
		if upper( alltrim( tcTabla ) ) = "TABLA1"
			return "ESQUEMA."
		else
			return ""
		endif
	endfunc
enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class ServicioDatosTest as serviciodatos of serviciodatos.prg
	lPasoPorEjecutarScriptNativa = .F.
	lPasoPorEjecutarSQL = .F.
	cSentencia = ""
	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		dodefault()
		this.oManagerConexionASql = newobject( "ManagerConexionASqlTest" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oManagerConexionASql_Access() as Void
		if isnull( this.oManagerConexionASql )
			this.oManagerConexionASql = newobject( "ManagerConexionASqlTest" )
			bindevent( this.oManagerConexionASql, "Destroy", this, "DestroyManagerConexion" )
		endif
		
		return this.oManagerConexionASql
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarScriptNativa( tcScript, tcTabla, tcCursor as string, tnSession as integer ) as Void
		This.cSentencia = tcScript
		This.lPasoPorEjecutarScriptNativa = .T.
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarSQL( tcSql as String, tcCursor as string, tnSession as integer ) as String
		This.cSentencia = tcSql
		This.lPasoPorEjecutarSQL = .T.
		return ""
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEsquema( tcTabla as String ) as String
		return "paises"
	endfunc	
enddefine

*----------------------------------------------------------------------
*----------------------------------------------------------------------
define class ManagerConexionASqlTest  as managerconexionasql of managerconexionasql.prg
	nReintentosTest = 0
	nSimularConexionAlIntento = 0
		
	*-----------------------------------------------------------------------------------------
	protected function GetConnectionHandler( tcStringConnect as String ) as Void
		local lnRetorno as Integer 
		lnRetorno = -1 
		
		if this.nSimularConexionAlIntento = this.nReintentosTest
			lnRetorno = 1
		else
			this.nReintentosTest = this.nReintentosTest + 1
		endif
	
		return lnRetorno
	endfunc



	*-----------------------------------------------------------------------------------------
	function Reconectar() as integer
		local llRetorno as Integer
		lcStringConnect = this.ObtenerStringConnect()
		llRetorno = this.TryConnect( lcStringConnect )

		return llRetorno
	endfunc 



enddefine

*----------------------------------------------------------------------
*----------------------------------------------------------------------
define class ServicioDatosAux as ServicioDatos of ServicioDatos.prg
	
	lPermiteModificarOEliminar = .f.
	*-----------------------------------------------------------------------------------------
	function PermiteModificarOEliminarEnBase_AUX( tcSentencia as String ) as Void
		this.lPermiteModificarOEliminar = this.PermiteModificarOEliminarEnBase( tcSentencia )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarScriptNativa( tcScript as String, tcTabla as String, tcCursor as string, tnSession as integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarSQL( tcSql as String, tcCursor as string, tnSession as integer ) as String
	endfunc 
	
enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class AplicacionNucleoTest as AplicacionNucleo of AplicacionNucleo.prg

	lEsBaseReplica = .f.
	*-----------------------------------------------------------------------------------------
	function cSucursalActiva_Assign( txVal as Variant ) as Void
		this.cSucursalActiva = txVal
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValorReplicaBD() as Boolean
		return this.lEsBaseReplica
	endfunc 

enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class ObjetoAux as Custom

	lPaso = .f.
	
	*-----------------------------------------------------------------------------------------
	function MetodoParaBindear( tcSentencia as String, tcTablas as string ) as Boolean
		this.lPaso = .t.
		
		return .t.
	endfunc 

enddefine

*--------------------------------------------------------------------
*--------------------------------------------------------------------
define class FakeServicioDatos as ServicioDatos of ServicioDatos.prg

	*-----------------------------------------------------------------------------------------
	function FakeObtenerReemplazoSintaxisBooleanos( tcSql as String, tcBuscado as String, tcReemplazo as String ) as String
		return this.ObtenerReemplazoSintaxisBooleanos( tcSql, tcBuscado, tcReemplazo )
	endfunc 

enddefine
