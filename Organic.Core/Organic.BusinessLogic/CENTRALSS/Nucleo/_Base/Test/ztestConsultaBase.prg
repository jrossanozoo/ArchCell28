**********************************************************************
Define Class ztestConsultaBase as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestConsultaBase of ztestConsultaBase.prg
	#ENDIF
	cTipoDeBase = ""
	cCentury = ""
	tFechaBlanco = {}
	nDataSessionID = 0
	
	*---------------------------------
	Function Setup
		This.cCentury = set( "Century" )
		this.nDataSessionID = set("Datasession" )
		if goDatos.EsSqlServer()
			This.tFechaBlanco = goRegistry.Nucleo.FechaEnBlancoParaSqlServer
		endif
	EndFunc
	
	*---------------------------------
	Function TearDown
		local lcCentury as String
		if goDatos.EsSqlServer()
			goRegistry.Nucleo.FechaEnBlancoParaSqlServer = This.tFechaBlanco
		endif
		lcCentury =  This.cCentury 
		set Century &lcCentury
		set datasession to ( this.nDataSessionID )
	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestTransformarValorSegunTipoDeDato
		local loConsulta As ConsultaBase of ConsultaBase.Prg, lxValor as Variant, ltDateTime as Datetime, ldDate as String
		
		set century on
		loConsulta = newobject( "AuxConsultaBase" )

		if goDatos.EsNativa()
			lxValor = loConsulta.TransformarValorSegunTipoDeDatoAux( {}, "D" )
			This.Assertequals( "No retorno el valor correcto 1", {}, lxValor )
		else
			ltDateTime = datetime()
			goRegistry.Nucleo.FechaEnBlancoParaSqlServer = "{" + transform( ltDateTime ) + "}"
			lxValor = loConsulta.TransformarValorSegunTipoDeDatoAux( {}, "D" )
			This.Assertequals( "No retorno el valor correcto 1", ltDateTime, lxValor )
			ldDate = {01/01/1801}
			ltDateTime = {01/01/1501 01:01:01}
			This.Assertequals( "No es correcto el valor 1", "ctod( '01/01/1801' )" , GoServicios.Librerias.ValorAString( ldDate ) )
			This.Assertequals( "No es correcto el valor 2", "ctod( '01/01/1501' )" , GoServicios.Librerias.ValorAString( ltDateTime ) )
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloUnElementoFramentoCero
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String
			
		lcCursor = sys( 2015 ) + "_Test94951"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		insert into &lcCursor ( CODIGO, database ) values ( "000001", "SUCURSAL1" )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 1, loCodigosPK.Count )

		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 1, 0 )
		this.assertequals( "El framento es incorrecto! (1).", "", lcFragmento )
			
		loConsulta.release()
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloUnElementoFramentoUno
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String
			
		lcCursor = sys( 2015 ) + "_Test94952"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		insert into &lcCursor ( CODIGO, database ) values ( "000001", "SUCURSAL1" )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 1, loCodigosPK.Count )
		
		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 1, 1 )
		this.assertequals( "El framento es incorrecto! (2).", " in ('000001')", lcFragmento )
						
		loConsulta.release()
		use in select( lcCursor )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloUnElementoFramentoDiezMil
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String
			
		lcCursor = sys( 2015 ) + "_Test94953"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		insert into &lcCursor ( CODIGO, database ) values ( "000001", "SUCURSAL1" )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 1, loCodigosPK.Count )

		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 1, 10000 )
		this.assertequals( "El framento es incorrecto! (3).", " in ('000001')", lcFragmento )		
		use in select( lcCursor )
		loConsulta.release()
		loCodigosPK.release()
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloCienElementosFragmentoCero
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String, lcValorEsperado as String, ;
			lcCodigo as String, i as Integer
			
		lcCursor = sys( 2015 ) + "_Test949545654"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		lcValorEsperado = ""
		for i = 1 to 100
			lcCodigo = padl( transform( i ), 6, "0" )
			insert into &lcCursor ( CODIGO, database ) values ( lcCodigo, "SUCURSAL1" )
			lcValorEsperado = lcValorEsperado + ",'" + lcCodigo + "'"
		endfor
		lcValorEsperado = substr( lcValorEsperado, 2 )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 100, loCodigosPK.Count )

		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 1, 0 )
		this.assertequals( "El framento es incorrecto! (1).", "", lcFragmento )
				
		loConsulta.release()
		use in select( lcCursor )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloCienElementosFragmentoUno
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String, lcValorEsperado as String, ;
			lcCodigo as String, i as Integer
			
		lcCursor = sys( 2015 ) + "_Test949545655"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		lcValorEsperado = ""
		for i = 1 to 100
			lcCodigo = padl( transform( i ), 6, "0" )
			insert into &lcCursor ( CODIGO, database ) values ( lcCodigo, "SUCURSAL1" )
			lcValorEsperado = lcValorEsperado + ",'" + lcCodigo + "'"
		endfor
		lcValorEsperado = substr( lcValorEsperado, 2 )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 100, loCodigosPK.Count )
		
		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 1, 1 )
		this.assertequals( "El framento es incorrecto! (2).", " in ('000001')", lcFragmento )
		
		loConsulta.release()
		use in select( lcCursor )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloCienElementosFragmentoDiezMil
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String, lcValorEsperado as String, ;
			lcCodigo as String, i as Integer
			
		lcCursor = sys( 2015 ) + "_Test949545656"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		lcValorEsperado = ""
		for i = 1 to 100
			lcCodigo = padl( transform( i ), 6, "0" )
			insert into &lcCursor ( CODIGO, database ) values ( lcCodigo, "SUCURSAL1" )
			lcValorEsperado = lcValorEsperado + ",'" + lcCodigo + "'"
		endfor
		lcValorEsperado = substr( lcValorEsperado, 2 )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 100, loCodigosPK.Count )

		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 1, 10000 )
		this.assertequals( "El framento es incorrecto! (3).", " in (" + lcValorEsperado + ")", lcFragmento )		
		
		loConsulta.release()
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloCienElementosFragmentoDiezMilSegundoFragento
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String, lcValorEsperado as String, ;
			lcCodigo as String, i as Integer
			
		lcCursor = sys( 2015 ) + "_Test949545656"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo C(10), database C( 200 ) ) 
		select ( lcCursor )
		lcValorEsperado = ""
		for i = 1 to 100
			lcCodigo = padl( transform( i ), 6, "0" )
			insert into &lcCursor ( CODIGO, database ) values ( lcCodigo, "SUCURSAL1" )
			lcValorEsperado = lcValorEsperado + ",'" + lcCodigo + "'"
		endfor
		lcValorEsperado = substr( lcValorEsperado, 2 )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 100, loCodigosPK.Count )

		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 99, 10000 )
		this.assertequals( "El framento es incorrecto! (3).", " in ('000099','000100')", lcFragmento )		
		
		loConsulta.release()
	endfunc 		
	

	*-----------------------------------------------------------------------------------------
	function zTestObtenerFragmentoColeccionInSqlServerSoloCienElementosFragmentoDiezMilSegundoFragentoNumerico
		local loConsulta as AuxConsultaBase of ztestConsultaBase.prg, lcCursor as String, ;
			loCodigosPK as zoocoleccion OF zoocoleccion.prg, lcFragmento as String, lcValorEsperado as String, ;
			lcCodigo as String, i as Integer
			
		lcCursor = sys( 2015 ) + "_Test949545656"
		loConsulta = newobject( "AuxConsultaBase" )
		set datasession to ( loConsulta.DataSessionID )
		
		create cursor &lcCursor ( codigo N(10), database C( 200 ) ) 
		select ( lcCursor )
		lcValorEsperado = ""
		for i = 1 to 100
			insert into &lcCursor ( CODIGO, database ) values ( i, "SUCURSAL1" )
			lcCodigo = transform( i )
			lcValorEsperado = lcValorEsperado + "," + lcCodigo
		endfor
		lcValorEsperado = substr( lcValorEsperado, 2 )
		
		loCodigosPK = loConsulta.ObtenerColeccionInSqlServer_TEST( lcCursor, "SUCURSAL1", "CODIGO" )
		this.assertequals( "Cantidad de entradas incorrectas.", 100, loCodigosPK.Count )

		lcFragmento = loConsulta.ObtenerFragmentoColeccionInSqlServer_TEST( loCodigosPK, 99, 10000 )
		this.assertequals( "El framento es incorrecto! (3).", " in (99,100)", lcFragmento )		
		
		loConsulta.release()
	endfunc 		
		

EndDefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------

define class AuxConsultaBase as ConsultaBase of ConsultaBase.Prg
	
	*-----------------------------------------------------------------------------------------
	function TransformarValorSegunTipoDeDatoAux( txValor as Variant, tcTipoDato as String ) as variant
		return This.TransformarValorSegunTipoDeDato( txValor, tcTipoDato )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionInSqlServer_TEST( tcCursor as String, tcSucursal as String, tcCampoPk as String ) as zoocoleccion OF zoocoleccion.prg	
		return this.ObtenerColeccionInSqlServer( tcCursor, tcSucursal, tcCampoPk )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFragmentoColeccionInSqlServer_TEST( toColeccion as zoocoleccion OF zoocoleccion.prg, tnInicio as Integer, tnCantidad as Integer ) as string
		return this.ObtenerFragmentoColeccionInSqlServer( toColeccion, tnInicio, tnCantidad )
	endfunc	
enddefine
