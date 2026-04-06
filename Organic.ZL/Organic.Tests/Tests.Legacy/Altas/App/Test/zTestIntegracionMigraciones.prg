Define Class zTestIntegracionMigraciones as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestIntegracionMigraciones of zTestIntegracionMigraciones.prg
	#ENDIF
	cRutaZoologic = ""
	cRutaLince = ""
	
	*-----------------------------------------------------------------------------------------
	function Setup
		local lcUbucacion as String, loManejaArchivos as Object

		This.cRutaZoologic = _Screen.Zoo.App.cRutaZoologic
		This.cRutaLince = _Screen.Zoo.App.cRutaLince

		*!*	 DRAGON 2028
	    lcSentencia = "DELETE FROM Zl.Razonsocial"
	    godatos.ejecutarSentencias( lcSentencia, "ZL.Razonsocial" )
	    lcSentencia = "DELETE FROM Zl.DEVBCO"
	    godatos.ejecutarSentencias( lcSentencia, "ZL.DEVBCO" )
	    lcSentencia = "DELETE FROM Zl.RECMOT"
	    godatos.ejecutarSentencias( lcSentencia, "ZL.RECMOT" )
	    lcSentencia = "DELETE FROM Zl.CLIENTES"
	    godatos.ejecutarSentencias( lcSentencia, "ZL.CLIENTES" )

		loManejaArchivos = newobject( "manejoarchivos", "..\Dlls\Generales\manejoarchivos.prg" )

		lcUbucacion = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val.dbf" )

		lcUbucacion = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\IDX\"
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val1.idx" )
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val2.idx" )
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val3.idx" )
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val4.idx" )
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val5.idx" )
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val6.idx" )
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "val7.idx" )

		lcUbucacion = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"
		loManejaArchivos.SetearAtributos( "N", addbs( lcUbucacion ) + "*.*" )
		loManejaArchivos = null

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TearDown
		local lcUbucacion as String, loManejaArchivos as Object

		_Screen.Zoo.App.cRutaZoologic = This.cRutaZoologic
		_Screen.Zoo.App.cRutaLince = This.cRutaLince

		loManejaArchivos = newobject( "manejoarchivos", "..\Dlls\Generales\manejoarchivos.prg" )

		lcUbucacion = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"
		loManejaArchivos.SetearAtributos( "R", addbs( lcUbucacion ) + "val.dbf" )
		
		lcUbucacion = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\IDX\"
		loManejaArchivos.SetearAtributos( "R", addbs( lcUbucacion ) + "val4.idx" )

		lcUbucacion = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"
		loManejaArchivos.SetearAtributos( "R", addbs( lcUbucacion ) + "*.*" )
		loManejaArchivos = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerMigrarMediosDePago
		local loEntidad as entidad OF entidad.prg, lcCodigo as String, loError as Exception, lcCursor as String, loError as Exception

		*-- Arrange
		_Screen.zoo.app.cRutaZoologic = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"
		
		lcCodigo = right( sys( 2015 ), 5 )
		
        lcSentencia = "INSERT INTO Zl.Razonsocial (cmpcod ,medpago) values ('" + lcCodigo + "', 'AMEX')"
        godatos.ejecutarSentencias( lcSentencia, "ZL.Razonsocial" )

		Try		
			use ( _Screen.Zoo.App.cRutaZoologic + "\Rz" ) in 0 shared alias Rz
			Insert into RZ (rzcod, rzfacsino) values( lcCodigo, 0 )
		catch to loError
			This.asserttrue( "No se pudo abrir la tabla RZ(Mock)", .f. )
		finally
			use in select( "rz" )
		Endtry
		
		
        *-- Act
		loEntidad = _Screen.zoo.InstanciarEntidad( "zlmigrarclientesalince" )
		loEntidad.DespuesDeGrabar()
		loEntidad.Release()

		*-- Assert
		lcCursor = sys( 2015 )
		try
			use ( _Screen.Zoo.App.cRutaZoologic + "\Rz" ) in 0 shared alias Rz
			select * from rz where rzcod = lcCodigo into cursor &lcCursor
		
			This.assertequals( "No se actualizo el medio de pago(rzfacsino)", 1, &lcCursor..rzfacsino )
			This.assertequals( "No se actualizo el medio de pago(rzftipo)", 2, &lcCursor..rzftipo )
		catch to loError
			throw loError
		Finally
			use in select( "rz" )
			use in select( lcCursor )
		Endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerMigrarRazonSocialAClienteNuevo
		local lcSentencia as String, lcCodigo as String, loEntidad as Object, lcCursor as String, loError as Exception

		*-- Arrange
		_Screen.zoo.app.cRutaZoologic = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"		
		lcCodigo = right( sys( 2015 ), 5 )
		
        lcSentencia = "INSERT INTO Zl.Razonsocial (cmpcod, Cliente, VersionSis, Descrip, SitFiscal, CBU, Cuit)" + ;
						"values ('" + lcCodigo + "','" + lcCodigo + "', 12.3, 'Cliente de prueba Zoologic', 9," + ;
						" '1234567890123456789012', '30707791973')"
        
        godatos.ejecutarSentencias( lcSentencia, "ZL.Razonsocial" )
        
        
        *-- Act
		loEntidad = _Screen.zoo.InstanciarEntidad( "zlmigrarclientesalince" )
		loEntidad.DespuesDeGrabar()
		loEntidad.Release()
		
		*-- Assert
		lcCursor = sys( 2015 )
		try
			use ( _Screen.Zoo.App.cRutaZoologic + "\Rz" ) in 0 shared alias Rz
			select * from rz where rzcod = lcCodigo into cursor &lcCursor
		
			This.assertequals( "No se actualizo la Razon Social(RZCod)", lcCodigo, &lcCursor..RZCod )
			This.assertequals( "No se actualizo la Razon Social(RZEstado)", 2, &lcCursor..RZEstado )
			This.assertequals( "No se actualizo la Razon Social(RZCliente)", lcCodigo, &lcCursor..RZCliente )
			This.assertequals( "No se actualizo la Razon Social(RZVersion)", "12.3", &lcCursor..RZVersion )
			This.assertequals( "No se actualizo la Razon Social(RZnom)", 'Cliente de prueba Zoologic', alltrim( &lcCursor..RZnom ) )
			This.assertequals( "No se actualizo la Razon Social(RZSitFiscal)", 9, &lcCursor..RZSitFiscal )
			This.assertequals( "No se actualizo la Razon Social(RZFcbu1)", '123-4567-8', alltrim( &lcCursor..RZFcbu1 ) )
			This.assertequals( "No se actualizo la Razon Social(RZFcbu2)", '90-123-456-789-012', alltrim( &lcCursor..RZFcbu2 ) )
			This.assertequals( "No se actualizo la Razon Social(RZCuit)", '30-70779197-3', alltrim( &lcCursor..RZCuit ) )
			
		catch to loError
			throw loError
		Finally
			use in select( "rz" )
			use in select( lcCursor )
		Endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerMigrarRazonSocialAClienteYaExistente
		local lcSentencia as String, lcCodigo as String, loEntidad as Object, lcCursor as String, loError as Exception
		
		*-- Arrange
		_Screen.zoo.app.cRutaZoologic = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"		
		lcCodigo = right( sys( 2015 ), 5 )
		
        lcSentencia = "INSERT INTO Zl.Razonsocial (cmpcod, Cliente, VersionSis, Descrip, SitFiscal)" + ;
						"values ('" + lcCodigo + "','" + lcCodigo + "', 12.3, 'Cliente de prueba Zoologic', 8 )"

        godatos.ejecutarSentencias( lcSentencia, "ZL.Razonsocial" )
        
		Try		
			use ( _Screen.Zoo.App.cRutaZoologic + "\Rz" ) in 0 shared alias Rz
			Insert into RZ ( rzcod, RZFcbu1, RZFcbu2, RZCuit ) values( lcCodigo, 'VALOR_ORIGINAL', 'VALOR_ORIGINAL', 'VALOR_ORIGINAL' )
		catch to loError
			This.asserttrue( "No se pudo abrir la tabla RZ(Mock)", .f. )
		finally
			use in select( "rz" )
		Endtry
        
        *-- Act
		loEntidad = _Screen.zoo.InstanciarEntidad( "zlmigrarclientesalince" )
		loEntidad.DespuesDeGrabar()
		loEntidad.Release()
		
		*-- Assert
		lcCursor = sys( 2015 )
		try
			use ( _Screen.Zoo.App.cRutaZoologic + "\Rz" ) in 0 shared alias Rz
			select * from rz where rzcod = lcCodigo into cursor &lcCursor
		
			This.assertequals( "No se actualizo la Razon Social(RZCod)", lcCodigo, &lcCursor..RZCod )
			This.assertequals( "No se actualizo la Razon Social(RZEstado)", 0, &lcCursor..RZEstado )
			This.assertequals( "No se actualizo la Razon Social(RZCliente)", lcCodigo, &lcCursor..RZCliente )
			This.assertequals( "No se actualizo la Razon Social(RZVersion)", "12.3", &lcCursor..RZVersion )
			This.assertequals( "No se actualizo la Razon Social(RZnom)", 'Cliente de prueba Zoologic', alltrim( &lcCursor..RZnom ) )
			This.assertequals( "No se actualizo la Razon Social(RZSitFiscal)", 4, &lcCursor..RZSitFiscal )

			This.assertequals( "No se actualizo la Razon Social(RZFcbu1)", '', alltrim( &lcCursor..RZFcbu1 ) )
			This.assertequals( "No se actualizo la Razon Social(RZFcbu2)", '', alltrim( &lcCursor..RZFcbu2 ) )
			This.assertequals( "No se actualizo la Razon Social(RZCuit)", '', alltrim( &lcCursor..RZCuit ) )
			
		catch to loError
			throw loError
		Finally
			use in select( "rz" )
			use in select( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerImpactarProcesoBancarioEnLince
		local lcSentencia as String, lcCodigo as String, loEntidad as Object, lcCursor as String, ;
				loError as Exception, lcMotivo as String, lcRutaTabla as String, lcRutaIDX as String

		*-- Arrange
		_Screen.zoo.app.cRutaLince = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF"

		lcCodigo = right( sys( 2015 ), 5 )
		lcMotivo = right( sys( 2015 ), 4 )
		
		lcSentencia = "insert into Zl.DEVBCO (Numero, RazSoc, nPresen, Motivo ) values (1, '" + lcCodigo + "', 10, '" + lcMotivo + "')"
        godatos.ejecutarSentencias( lcSentencia, "Zl.DEVBCO" )
        
		lcSentencia = "insert into Zl.RECMOT (ccod, esRechazo ) values ('" + lcMotivo + "', .t. )"
		godatos.ejecutarSentencias( lcSentencia, "Zl.RECMOT" )

		Try		

			lcRutaTabla = addbs( alltrim( _Screen.Zoo.App.cRutaLince ) ) + iif( "\DBF" $ alltrim( upper( _Screen.Zoo.App.cRutaLince ) ), "" , addbs( "DBF" ) )
			lcRutaIDX = addbs( left( alltrim( lcRutaTabla ),len( lcRutaTabla )-4) + "IDX" )

			use ( lcRutaTabla + "\Val" ) in 0 excl alias Val
			select val
			zap 
			set index to ( lcRutaIDX + "val1" )
			set index to ( lcRutaIDX + "val2" ) additive
			set index to ( lcRutaIDX + "val3" ) additive
			set index to ( lcRutaIDX + "val4" ) additive
			set index to ( lcRutaIDX + "val5" ) additive
			set index to ( lcRutaIDX + "val6" ) additive
			set index to ( lcRutaIDX + "val7" ) additive
			reindex
			set order to val4			
			
			Insert into VAL ( jjcli, jjbjcli, jjbjnum, jjbjfch, jjobs, jjcuotas, jjcuotot, jjdias, jjTarje, jjAcfCup, jjAcNum, jjAcCod, jjHabil ) ;
						values( lcCodigo, "V_ORI", 600000010, ctod( "11/12/1976" ), "Valor Original", 9, 9, 9, "X", ctod( "11/12/1976" ),1,'BLA',1 )

			Insert into VAL ( jjcli, jjbjcli, jjbjnum, jjbjfch, jjobs, jjcuotas, jjcuotot, jjdias, jjTarje, jjAcfCup, jjAcNum, jjAcCod, jjHabil) ;
						values( lcCodigo, "V_ORI", 600000009, ctod( "11/12/1976" ), "Valor Original", 9, 9, 9, "X", ctod( "11/12/1976" ),2,'BLA2',2 )

		catch to loError
			This.asserttrue( "No se pudo abrir la tabla VAL(Mock)", .f. )
		finally
			use in select( "Val" )
		endtry

        *-- Act
		loEntidad = _Screen.zoo.InstanciarEntidad( "ZLImpactarEstadoRZenZoo" )
		loEntidad.Nuevo()
		loEntidad.Grabar()
		loEntidad.Release()

		*-- Assert
		lcCursor = sys( 2015 )
		try
			use ( _Screen.zoo.app.cRutaLince + "\Val" ) in 0 shared alias Val
			select * from Val where Jjcli = lcCodigo and Jjbjnum = 600000010 into cursor &lcCursor
			This.assertequals( "No se actualizo la VAL(jjbjnum) 1", 0, &lcCursor..jjbjnum )
			This.assertequals( "No se actualizo la VAL(jjbjfch) 1", ctod(''), &lcCursor..jjbjfch )
			This.assertequals( "No se actualizo la VAL(jjbjcli) 1", "", alltrim( &lcCursor..jjbjcli ) )
			This.assertequals( "No se actualizo la VAL(jjobs) 1", "", alltrim( &lcCursor..jjobs ) )
			This.assertequals( "No se actualizo la VAL(jjcuotas) 1", 0, &lcCursor..jjcuotas )
			This.assertequals( "No se actualizo la VAL(jjcuotot) 1", 0, &lcCursor..jjcuotot )
			This.assertequals( "No se actualizo la VAL(jjdias) 1", 0, &lcCursor..jjdias )
			This.assertequals( "No se actualizo la VAL(jjTarje) 1", "", alltrim( &lcCursor..jjTarje ) )
			This.assertequals( "No se actualizo la VAL(jjAcfCup) 1", ctod(''), &lcCursor..jjAcfCup )
			This.assertequals( "No se actualizo la VAL(jjAcNum) 1", 0, &lcCursor..jjAcNum )
			This.assertequals( "No se actualizo la VAL(jjAcCod) 1", '', alltrim( &lcCursor..jjAcCod ) )
			This.assertequals( "No se actualizo la VAL(jjAcfCup) 1", 0, &lcCursor..jjHabil )

			
			
			select * from Val where Jjcli = lcCodigo and Jjbjnum = 600000009 into cursor &lcCursor
			This.assertequals( "Se actualizo la VAL(jjbjnum) 2", 600000009, &lcCursor..jjbjnum )
			This.assertequals( "Se actualizo la VAL(jjbjfch) 2", ctod( "11/12/1976" ), &lcCursor..jjbjfch )
			This.assertequals( "Se actualizo la VAL(jjbjcli) 2", "V_ORI", alltrim( &lcCursor..jjbjcli ) )
			This.assertequals( "Se actualizo la VAL(jjobs) 2", "Valor Original", alltrim( &lcCursor..jjobs ) )
			This.assertequals( "Se actualizo la VAL(jjcuotas) 2", 9, &lcCursor..jjcuotas )
			This.assertequals( "Se actualizo la VAL(jjcuotot) 2", 9, &lcCursor..jjcuotot )
			This.assertequals( "Se actualizo la VAL(jjdias) 2", 9, &lcCursor..jjdias )
			This.assertequals( "Se actualizo la VAL(jjTarje) 2", "X", alltrim( &lcCursor..jjTarje ) )
			This.assertequals( "Se actualizo la VAL(jjAcfCup) 2", ctod( "11/12/1976" ), &lcCursor..jjAcfCup )
			This.assertequals( "No se actualizo la VAL(jjAcNum) 2", 2, &lcCursor..jjAcNum )
			This.assertequals( "No se actualizo la VAL(jjAcCod) 2", 'BLA2', alltrim( &lcCursor..jjAcCod ) )
			This.assertequals( "No se actualizo la VAL(jjAcfCup) 2", 2, &lcCursor..jjHabil )
			
			

		catch to loError
			throw loError
		Finally
			use in select( "Val" )
			use in select( lcCursor )
		endtry

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSqlServerMigrarDeNuevosClientes
		local loEntidad as entidad OF entidad.prg, lcCodigo as String, loError as Exception, lcCursor as String, loError as Exception

		*-- Arrange
		_Screen.zoo.app.cRutaZoologic = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"		
		lcCodigo = right( sys( 2015 ), 5 )
		
        lcSentencia = "INSERT INTO Zl.Clientes (cmpCodigo, cmpNombre) values ('" + lcCodigo + "', 'Prueba Zoologic')"
        godatos.ejecutarSentencias( lcSentencia, "ZL.Clientes" )

        *-- Act
		loEntidad = _Screen.zoo.InstanciarEntidad( "zlmigrarclientesalince" )
		loEntidad.DespuesDeGrabar()
		loEntidad.Release()

		*-- Assert
		lcCursor = sys( 2015 )
		try
			use ( _Screen.Zoo.App.cRutaZoologic + "\Cli" ) in 0 shared alias Cli
			select * from Cli where CLCOD = lcCodigo into cursor &lcCursor
		
			This.assertequals( "No se actualizo la Razon Social(clCod)", lcCodigo, alltrim( &lcCursor..clCod ) )
			This.assertequals( "No se actualizo la Razon Social(clNom)", "Prueba Zoologic", alltrim( &lcCursor..clNom ) )
			This.assertequals( "No se actualizo la Razon Social(clEstado)", 2, &lcCursor..clEstado )
			
		catch to loError
			throw loError
		Finally
			use in select( "Cli" )
			use in select( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerMigrarClientesExistentes
		local loEntidad as entidad OF entidad.prg, lcCodigo as String, loError as Exception, lcCursor as String, loError as Exception

		*-- Arrange
		_Screen.zoo.app.cRutaZoologic = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\VistasZoologic"				
		lcCodigo = right( sys( 2015 ), 5 )
		
        lcSentencia = "INSERT INTO Zl.Clientes (cmpCodigo, cmpNombre) values ('" + lcCodigo + "', 'Prueba Zoologic')"
        godatos.ejecutarSentencias( lcSentencia, "ZL.Clientes" )

		Try		
			use ( _Screen.Zoo.App.cRutaZoologic + "\Cli" ) in 0 shared alias Cli
			Insert into Cli ( CLCOD, clnom, clestado ) values( lcCodigo, 'NombreOriginal', 9 )
		catch to loError
			This.asserttrue( "No se pudo abrir la tabla CLI(Mock)", .f. )
		finally
			use in select( "CLI" )
		endtry

        *-- Act
		loEntidad = _Screen.zoo.InstanciarEntidad( "zlmigrarclientesalince" )
		loEntidad.DespuesDeGrabar()
		loEntidad.Release()

		*-- Assert
		lcCursor = sys( 2015 )
		try
			use ( _Screen.Zoo.App.cRutaZoologic + "\Cli" ) in 0 shared alias Cli
			select * from Cli where CLCOD = lcCodigo into cursor &lcCursor
		
			This.assertequals( "No se actualizo la Razon Social(clCod)", lcCodigo, alltrim( &lcCursor..clCod ) )
			This.assertequals( "No se actualizo la Razon Social(clNom)", "Prueba Zoologic", alltrim( &lcCursor..clNom ) )
			This.assertequals( "No se actualizo la Razon Social(clEstado)", 2, &lcCursor..clEstado )
			
		catch to loError
			throw loError
		Finally
			use in select( "Cli" )
			use in select( lcCursor )
		endtry
	endfunc 
enddefine