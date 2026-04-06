**********************************************************************
Define Class zTestEspecificacionDeProducto as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestEspecificacionDeProducto of zTestEspecificacionDeProducto.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	Function Setup
		*open database  C:\ZOO\ZL\adn\dbc\metadata.dbc
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	Function TearDown
		use in select( "Propiedades" )
		set database to ( addbs( _screen.zoo.cRutaiNICIAL ) + "adn\dbc\metadata" )
		close database
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestTipodeValores
		local lnCodigo as Integer
		
		use in select( "TipodeValores" )
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\TipoDeValores" )
		This.AssertEquals( "La cantidad de registros no es la correcta", 7, reccount() )

		lnCodigo = 1
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Moneda Local", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .F., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .T., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .F., PersonalizarComprobante )
		
		lnCodigo = 2
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Moneda Extranjera", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .T., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .T., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .F., PersonalizarComprobante )

		lnCodigo = 3
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Tarjeta de Crédito", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .F., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .F., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .F., PersonalizarComprobante )

		lnCodigo = 4
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Cheque", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .F., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "Cheques", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .F., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .F., PersonalizarComprobante )

		lnCodigo = 5
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Pagaré", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .F., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .F., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .F., PersonalizarComprobante )

		lnCodigo = 6
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Cuenta Corriente", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .F., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "CuentaCorrienteValores", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .F., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .T., PersonalizarComprobante )

		lnCodigo = 7
		locate for Codigo = lnCodigo
		This.AssertEquals( "Descripcion del codigo " + transform( lnCodigo ) + " no es correcta", "Ticket", alltrim( Descripcion ) )
		This.AssertEquals( "Pide cotizacion del codigo " + transform( lnCodigo ) + " no es correcto", .F., PideCotizacion )
		This.AssertEquals( "Componente del codigo " + transform( lnCodigo ) + " no es correcto", "", alltrim( Componente ) )
		This.AssertEquals( "Permite vuelto " + transform( lnCodigo ) + " no es correcto", .F., PermiteVuelto )
		This.AssertEquals( "Personalizar comprobante " + transform( lnCodigo ) + " no es correcto", .F., PersonalizarComprobante )

		use in select( "TipodeValores" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestComponentes
		use in select( "Componente" )
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\componente" )
		This.Assertequals( "La cantidad de componentes no es correcta", 19, reccount() )
		
		locate for alltrim( lower ( Componente ) ) = "comunicacion" and lower( alltrim( Entidad ) ) == "grupocomunicacion" and orden = 1 and ;
				lower( alltrim( Combinacion ) ) == "" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente COMUNICACION", found() )

		locate for alltrim( lower ( Componente ) ) = "precios" and lower( alltrim( Entidad ) ) == "preciodearticulo" and orden = 2 and ;
				lower( alltrim( Combinacion ) ) == "preciodearticulo" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente PRECIOS", found() )

		locate for alltrim( lower ( Componente ) ) = "caja" and lower( alltrim( Entidad ) ) == "" and orden = 3 and ;
				lower( alltrim( Combinacion ) ) == "" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente CAJA", found() )

		locate for alltrim( lower ( Componente ) ) = "cuentacorriente" and lower( alltrim( Entidad ) ) == "ctacte" and orden = 4 and ;
				lower( alltrim( Combinacion ) ) == "ctacte" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente CUENTACORRIENTE", found() )

		locate for alltrim( lower ( Componente ) ) = "cajero" and lower( alltrim( Entidad ) ) == "cajasaldos,movimientodecaja" and orden = 5 and ;
				lower( alltrim( Combinacion ) ) == "" and alltrim( lower( componentesrelacionados ) ) == "cuentacorrientevalores,valores" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente CAJERO", found() )

		locate for alltrim( lower ( Componente ) ) = "valores" and lower( alltrim( Entidad ) ) == "" and orden = 6 and ;
				lower( alltrim( Combinacion ) ) == "" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente VALORES", found() )

		locate for alltrim( lower ( Componente ) ) = "servicios" and lower( alltrim( Entidad ) ) == "zlitemsservicios,relaciontiis,comasigitemseresqcom,zlservicioslotebaja" and orden = 7 and ;
				lower( alltrim( Combinacion ) ) == "zlitemsservicios" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente CTACTEITEMRECIBO", found() )

		locate for alltrim( lower ( Componente ) ) = "ctacteitemrecibo" and lower( alltrim( Entidad ) ) == "ctacte" and orden = 8 and ;
				lower( alltrim( Combinacion ) ) == "ctacte" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "cuentacorrienteventasbase" and graba = .T.
		This.Asserttrue( "Problemas con componente CTACTEITEMRECIBO", found() )

		locate for alltrim( lower ( Componente ) ) = "cuentacorrientevaloresventas" and lower( alltrim( Entidad ) ) == "ctacte" and orden = 9 and ;
				lower( alltrim( Combinacion ) ) == "ctacte" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "cuentacorrienteventasbase" and graba = .T.
		This.Asserttrue( "Problemas con componente CTACTEITEMVALORES", found() )

		locate for alltrim( lower ( Componente ) ) = "esquemacomision" and lower( alltrim( Entidad ) ) == "comasigitemseresqcom" and orden = 10 and ;
				lower( alltrim( Combinacion ) ) == "" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente ESQUEMACOMISION", found() )

		locate for alltrim( lower ( Componente ) ) = "cheques" and lower( alltrim( Entidad ) ) == "cheque" and orden = 11 and ;
				lower( alltrim( Combinacion ) ) == "cheque" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "componentevalores" and graba = .T.
		This.Asserttrue( "Problemas con componente CHEQUES", found() )

		locate for alltrim( lower ( Componente ) ) = "facturacionelectronica" and lower( alltrim( Entidad ) ) == "cae" and orden = 16 and ;
				lower( alltrim( Combinacion ) ) == "" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "" and graba = .F.
		This.Asserttrue( "Problemas con componente facturacionelectronica", found() )

		locate for alltrim( lower ( Componente ) ) = "cuentacorrientevalores" and lower( alltrim( Entidad ) ) == "ctacte" and orden = 17 and ;
				lower( alltrim( Combinacion ) ) == "ctacte" and alltrim( lower( componentesrelacionados ) ) == "cuentacorrientevaloresventas,cuentacorrientevalorescompras" and ;
				alltrim( lower( herencia ) ) == "" and graba = .T.
		This.Asserttrue( "Problemas con componente Cuenta Corriente Valores", found() )

		locate for alltrim( lower ( Componente ) ) = "cuentacorrientevalorescompras" and lower( alltrim( Entidad ) ) == "ctactecompra" and orden = 18 and ;
				lower( alltrim( Combinacion ) ) == "ctactecompra" and alltrim( lower( componentesrelacionados ) ) == "" and ;
				alltrim( lower( herencia ) ) == "cuentacorrientecomprasbase" and graba = .T.
		This.Asserttrue( "Problemas con componente Cuenta Corriente Valores", found() )

		use in select( "Componente" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestVerificarColores
		Local llAbrir As boolean

		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\propiedades" ) in 0 shared again 
		
		select propiedades
		locate for idControl = 17 and idEstilo = 1
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. ", 3182595, Propiedades.ForeColor ) 
		locate for idControl = 17 and idEstilo = 2
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 2. ", 3182595, Propiedades.ForeColor ) 


		locate for idControl = 10 and idEstilo = 1
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 10 ", 3182595, Propiedades.BorderColor ) 


		locate for idControl = 14 and idEstilo = 1
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 14 . Border", 3182595, Propiedades.BorderColor )
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 14 . ForeColor ", 3182595, Propiedades.ForeColor )
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 14 . BackColor ", 3182595, Propiedades.BackColor )
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 14 . nBackColorConFoco ", 3182595, Propiedades.nBackColorConFoco )
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 14 . SelectedBackColor ", 3182595, Propiedades.SelectedBackColor )

		locate for idControl = 14 and idEstilo = 2
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 2. Control 14 . ForeColor ", 3182595, Propiedades.ForeColor )
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 2. Control 14 . SelectedBackColor ", 3182595, Propiedades.SelectedBackColor )		

		locate for idControl = 13 and idEstilo = 1
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 13 . Border", 3182595, Propiedades.BorderColor )
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 1. Control 13 . BackColor ", 3182595, Propiedades.BackColor )
			
		locate for idControl = 13 and idEstilo = 2
		this.assertequals( "No esta seteado correctamente el color de la linea. Estilo 2. Control 13 . Border", 3182595, Propiedades.BorderColor )
		
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosGenericoa
		local lcTabla as String, llAbrio as boolean

		lcTabla = "AtributosGenericos"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( atributo ) ) == "FECHATRANSFERENCIA"
		this.asserttrue( "Debe existir el atributo FechaTransferencia en AtributosGenericos", found() )
		locate for upper( alltrim( atributo ) ) == "ESTADOTRANSFERENCIA"
		this.asserttrue( "Debe existir el atributo EstadoTransferencia en AtributosGenericos", found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionArticulos
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "ARTICULOV2"
		lcTablaEntidad = "ARTICULO"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "IDENT"
		this.asserttrue( "Debe existir el atributo IDENT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODLINCE"
		this.asserttrue( "Debe existir el atributo CODLINCE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PRECIO1"
		this.asserttrue( "Debe existir el atributo PRECIO1 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PRECIO2"
		this.asserttrue( "Debe existir el atributo PRECIO2 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PRECIO3"
		this.asserttrue( "Debe existir el atributo PRECIO3 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PRECIO4"
		this.asserttrue( "Debe existir el atributo PRECIO4 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PRECIO5"
		this.asserttrue( "Debe existir el atributo PRECIO5 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "DESCRIP"
		this.asserttrue( "Debe existir el atributo DESCRIP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ACLARACION"
		this.asserttrue( "Debe existir el atributo ACLARACION en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TEXTO1ANT"
		this.asserttrue( "Debe existir el atributo TEXTO1ANT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TEXTO2ANT"
		this.asserttrue( "Debe existir el atributo TEXTO2ANT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TEXTO1DESP"
		this.asserttrue( "Debe existir el atributo TEXTO1DESP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TEXTO2DESP"
		this.asserttrue( "Debe existir el atributo TEXTO2DESP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	function zTestComprobarTestConDiccionario
		local lnCantAtributos as String, lcNombreEntidad as String, lcTabla as String

		lcRuta = addbs( _Screen.zoo.cRutaInicial ) + "Adn\dbc\"
		lcTabla = "Diccionario"
		if !used( lcTabla )
			use (lcRuta + lcTabla ) shared in 0
		endif
	
		lcTabla = "Entidad"
		if !used( lcTabla )
			use ( lcRuta + lcTabla ) shared in 0
		endif

		select diccionario.entidad, count(atributo) as cantidad;
			from diccionario ;
			Left join entidad ;
			on upper( alltrim( diccionario.Entidad ) ) == upper( alltrim( entidad.Entidad ) );
			where !empty(tabla) and ;
			entidad.orden = 1 and ;
			alltrim( upper( entidad.tipo ) ) == "E" ;
			group by 1 ;
			into cursor curEntidades

		lcNombreEntidad = "ZLSERVICIOSLOTE"
		lnCantAtributos = 10
		locate for alltrim( upper( entidad ) ) == lcNombreEntidad
		this.asserttrue( "No se encontro la entidad " + lcNombreEntidad + " en el diccionario.", found() )
		this.assertequals ( "No coincden la cantidad de atributos de la entidad " + lcNombreEntidad, lnCantAtributos, curEntidades.Cantidad )

		select Diccionario
		locate for upper( alltrim( atributo ) ) == 'RAZONSOCIAL' and alltrim( upper( entidad ) ) == lcNombreEntidad 			
		
		if found()
			This.assertEquals ( "El campo RazonSocial no tiene cargado el campo 'CLAVEFORANEA'", 'ZLRAZONSOCIALES', upper( alltrim( Diccionario.claveforanea ) ) )
		endif

		locate for upper( alltrim( atributo ) ) == 'CLIENTE' and alltrim( upper( entidad ) ) == lcNombreEntidad 	
		if found()
			This.assertEquals ( "El campo CLIENTE no tiene cargado el campo 'CLAVEFORANEA'", 'ZLCLIENTES', upper( alltrim( Diccionario.claveforanea ) ) )
		endif

		locate for upper( alltrim( atributo ) ) == 'CLASIFICACION' and alltrim( upper( entidad ) ) == lcNombreEntidad 	
		if found()
			This.assertEquals ( "El atributo Clasificacion no tiene cargado el campo 'CLAVEFORANEA'", 'CLASIFICACIONV2', upper( alltrim( Diccionario.claveforanea ) ) )
		endif

		locate for upper( alltrim( atributo ) ) == 'CONTACTO' and alltrim( upper( entidad ) ) == lcNombreEntidad 	
		if found()
			This.assertEquals ( "El atributo Clasificacion no tiene cargado el campo 'CLAVEFORANEA'", 'CONTACTOS', upper( alltrim( Diccionario.claveforanea ) ) )
		endif

		locate for upper( alltrim( atributo ) ) == 'REGPOR' and alltrim( upper( entidad ) ) == lcNombreEntidad 	
		if found()
			This.assertEquals ( "El atributo Clasificacion no tiene cargado el campo 'CLAVEFORANEA'", 'LEGAJOOPS', upper( alltrim( Diccionario.claveforanea ) ) )
		endif

		locate for upper( alltrim( atributo ) ) == 'CODCONTR' and alltrim( upper( entidad ) ) == lcNombreEntidad 	
		if found()
			This.assertEquals ( "El atributo Clasificacion no tiene cargado el campo 'CLAVEFORANEA'", 'CONTRATOV2', upper( alltrim( Diccionario.claveforanea ) ) )
		endif

		use in select( "Diccionario" )
		use in select( "Entidad" )
		use in select( "curEntidades" )
	
	endfunc

	
	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionCliente
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "CLIENTEV2"
		lcTablaEntidad = "CLIENTES"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPCODIGO"
		this.asserttrue( "Debe existir el atributo CMPCODIGO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPNOMBRE"
		this.asserttrue( "Debe existir el atributo CMPNOMBRE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPCATEG"
		this.asserttrue( "Debe existir el atributo CMPCATEG en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPCORRED"
		this.asserttrue( "Debe existir el atributo CMPCORRED en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPDOMAIN"
		this.asserttrue( "Debe existir el atributo CMPDOMAIN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPANTEU"
		this.asserttrue( "Debe existir el atributo CMPANTEU en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPAGREU"
		this.asserttrue( "Debe existir el atributo CMPAGREU en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPSHOST"
		this.asserttrue( "Debe existir el atributo CMPSHOST en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPACUENT"
		this.asserttrue( "Debe existir el atributo CMPACUENT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPFECHA"
		this.asserttrue( "Debe existir el atributo CMPFECHA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPACLAVE"
		this.asserttrue( "Debe existir el atributo CMPACLAVE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPCLASIF"
		this.asserttrue( "NO Debe existir el atributo CMPCLASIF en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , !found() )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPESTADO"
		this.asserttrue( "Debe existir el atributo CMPESTADO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPPHOST"
		this.asserttrue( "Debe existir el atributo CMPPHOST en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionContrato
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "CONTRATOV2"
		lcTablaEntidad = "CONTRATO"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODIGO"
		this.asserttrue( "Debe existir el atributo CODIGO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ORDEN"
		this.asserttrue( "Debe existir el atributo ORDEN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "NOMBRE"
		this.asserttrue( "Debe existir el atributo NOMBRE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "DESCMIN"
		this.asserttrue( "Debe existir el atributo DESCMIN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "MESESSUG"
		this.asserttrue( "Debe existir el atributo MESESSUG en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionCorredor
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "CORREDORV2"
		lcTablaEntidad = "CORREDOR"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODIGO"
		this.asserttrue( "Debe existir el atributo CODIGO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODLINCE"
		this.asserttrue( "Debe existir el atributo CODLINCE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "NOMBRE"
		this.asserttrue( "Debe existir el atributo NOMBRE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionDireccion
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "DIRECCIONV2"
		lcTablaEntidad = "DIR"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODIGO"
		this.asserttrue( "Debe existir el atributo CODIGO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "DIRECCION"
		this.asserttrue( "Debe existir el atributo DIRECCION en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "LOCALIDAD"
		this.asserttrue( "Debe existir el atributo LOCALIDAD en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CP"
		this.asserttrue( "Debe existir el atributo CP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PROVINCIA"
		this.asserttrue( "Debe existir el atributo PROVINCIA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "WEB"
		this.asserttrue( "Debe existir el atributo WEB en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "EMAIL"
		this.asserttrue( "Debe existir el atributo EMAIL en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TELEFONO"
		this.asserttrue( "Debe existir el atributo TELEFONO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FAX"
		this.asserttrue( "Debe existir el atributo FAX en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TIEMPO"
		this.asserttrue( "Debe existir el atributo TIEMPO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TRANSPORTE"
		this.asserttrue( "Debe existir el atributo TRANSPORTE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "DESCRIP"
		this.asserttrue( "Debe existir el atributo DESCRIP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc


	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionEstado
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "ESTADOV2"
		lcTablaEntidad = "ESTADO"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla )

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODIGO"
		this.asserttrue( "Debe existir el atributo CODIGO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "NOMBRE"
		this.asserttrue( "Debe existir el atributo NOMBRE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionPlanes
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "PLANESV2"
		lcTablaEntidad = "PLANES"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla ) 

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "IDENT"
		this.asserttrue( "Debe existir el atributo IDENT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODFAC"
		this.asserttrue( "Debe existir el atributo CODFAC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "DESCRIP"
		this.asserttrue( "Debe existir el atributo DESCRIP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FECHAINI"
		this.asserttrue( "Debe existir el atributo FECHAINI en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FECHAFIN"
		this.asserttrue( "Debe existir el atributo FECHAFIN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TERMINAL"
		this.asserttrue( "Debe existir el atributo TERMINAL en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "VACIO"
		this.asserttrue( "Debe existir el atributo VACIO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "TIVENT"
		this.asserttrue( "Debe existir el atributo TIVENT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CAMBMODU"
		this.asserttrue( "Debe existir el atributo CAMBMODU en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "RSCLIENTE"
		this.asserttrue( "Debe existir el atributo RSCLIENTE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "COMISIONA"
		this.asserttrue( "Debe existir el atributo COMISIONA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionProveedor
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "PROVEEDOR"
		lcTablaEntidad = "PROVEED"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla ) 

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLCFI"
		this.asserttrue( "Debe existir el atributo CLCFI en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLCOD"
		this.asserttrue( "Debe existir el atributo CLCOD en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLCONTAC"
		this.asserttrue( "Debe existir el atributo CLCONTAC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLCP"
		this.asserttrue( "Debe existir el atributo CLCP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLCUIT"
		this.asserttrue( "Debe existir el atributo CLCUIT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLDIR"
		this.asserttrue( "Debe existir el atributo CLDIR en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLEMAIL"
		this.asserttrue( "Debe existir el atributo CLEMAIL en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLFAX"
		this.asserttrue( "Debe existir el atributo CLFAX en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLIMPD"
		this.asserttrue( "Debe existir el atributo CLIMPD en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLEMAIL"
		this.asserttrue( "Debe existir el atributo CLEMAIL en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLFAX"
		this.asserttrue( "Debe existir el atributo CLFAXen la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLIMPD"
		this.asserttrue( "Debe existir el atributo CLIMPD en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLIVA"
		this.asserttrue( "Debe existir el atributo CLIVA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLLOC"
		this.asserttrue( "Debe existir el atributo CLLOC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLMON1"
		this.asserttrue( "Debe existir el atributo CLMON1 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLMON2"
		this.asserttrue( "Debe existir el atributo CLMON2 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLMON3"
		this.asserttrue( "Debe existir el atributo CLMON3 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLMON4"
		this.asserttrue( "Debe existir el atributo CLMON4 en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLMONTO"
		this.asserttrue( "Debe existir el atributo CLMONTO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLNOM"
		this.asserttrue( "Debe existir el atributo CLNOM en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLPAGEWEB"
		this.asserttrue( "Debe existir el atributo CLPAGEWEB en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLPRV"
		this.asserttrue( "Debe existir el atributo CLPRV en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLTLF"
		this.asserttrue( "Debe existir el atributo CLTLF en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLTPO"
		this.asserttrue( "Debe existir el atributo CLTPO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
				
		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionRazonSocial
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "RAZONSOCIALV2"
		lcTablaEntidad = "RAZONSOCIAL"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla ) 

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CMPCOD"
		this.asserttrue( "Debe existir el atributo CMPCOD en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CLIENTE"
		this.asserttrue( "Debe existir el atributo CLIENTE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "DESCRIP"
		this.asserttrue( "Debe existir el atributo DESCRIP en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ESTADO"
		this.asserttrue( "Debe existir el atributo ESTADO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FANTASIA"
		this.asserttrue( "Debe existir el atributo FANTASIA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CUIT"
		this.asserttrue( "Debe existir el atributo CUIT en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODDIR"
		this.asserttrue( "Debe existir el atributo CODDIR en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "VERSIONSIS"
		this.asserttrue( "Debe existir el atributo VERSIONSIS en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CORREDOR"
		this.asserttrue( "Debe existir el atributo CORREDOR en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "SITFISCAL"
		this.asserttrue( "Debe existir el atributo SITFISCAL en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionSerie
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "SERIEV2"
		lcTablaEntidad = "SERIES"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla ) 

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "NROSERIE"
		this.asserttrue( "Debe existir el atributo NROSERIE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODRS"
		this.asserttrue( "Debe existir el atributo CODRS en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CONTACTO"
		this.asserttrue( "Debe existir el atributo CONTACTO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "INSTFECHA"
		this.asserttrue( "Debe existir el atributo INSTFECHA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FECHABAJA"
		this.asserttrue( "Debe existir el atributo FECHABAJA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FECHABLOQ"
		this.asserttrue( "Debe existir el atributo FECHABLOQ en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ENTRADAS"
		this.asserttrue( "Debe existir el atributo ENTRADAS en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "MESES"
		this.asserttrue( "Debe existir el atributo MESES en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "FECHAREDUC"
		this.asserttrue( "Debe existir el atributo FECHAREDUC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "MESESREDUC"
		this.asserttrue( "Debe existir el atributo MESESREDUC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ULTCODFECH"
		this.asserttrue( "Debe existir el atributo ULTCODFECH en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ULTCODMES"
		this.asserttrue( "Debe existir el atributo ULTCODMES en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ULTCODDISC"
		this.asserttrue( "Debe existir el atributo ULTCODDISC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ULTCODVER"
		this.asserttrue( "Debe existir el atributo ULTCODVER en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ESTADOADM"
		this.asserttrue( "Debe existir el atributo FECHABAJA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CONTADM"
		this.asserttrue( "Debe existir el atributo CONTADM en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CORREADM"
		this.asserttrue( "Debe existir el atributo CORREADM en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "USOSADM"
		this.asserttrue( "Debe existir el atributo USOSADM en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PUESTO"
		this.asserttrue( "Debe existir el atributo PUESTO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "PLAN"
		this.asserttrue( "Debe existir el atributo PLAN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CDIREC"
		this.asserttrue( "Debe existir el atributo CDIREC en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "SERIELIN"
		this.asserttrue( "Debe existir el atributo SERIELIN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "SISTEMA"
		this.asserttrue( "Debe existir el atributo SISTEMA en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function zTestVerificarAtributosBasicosMigracionUso
		local lcTabla as String, llAbrir as boolean, lcEntidad as String, lcTablaEntidad as String  

		lcTabla = "Diccionario"
		lcEntidad = "USOV2"
		lcTablaEntidad = "USOS"
		If !Used(lcTabla)
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\" + lcTabla )
		Endif

		select ( lcTabla ) 

		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "CODIGO"
		this.asserttrue( "Debe existir el atributo CODIGO en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "ORDEN"
		this.asserttrue( "Debe existir el atributo ORDEN en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( tabla ) ) == lcTablaEntidad and upper( alltrim( campo ) ) == "NOMBRE"
		this.asserttrue( "Debe existir el atributo NOMBRE en la entidad " + lcEntidad + ", en la tabla " + lcTablaEntidad  , found() )

		If llAbrir
			Use In Select( lcTabla )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestSeguridadEntidadesDescuentos
		local lcEntidad as String, lcOperacion as String, lcTitulo as String
		use in select( "seguridadEntidades" )
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\seguridadentidades" ) in 0
		
		lcOperacion = "DESCUENTOCOMPROBANTE"
		lcTitulo = "Descuento"
		lcEntidad = "FACTURA"
		
		select SeguridadEntidades
		
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "TICKETFACTURA"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "TICKETNOTADECREDITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "TICKETNOTADEDEBITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "NOTADECREDITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "NOTADEDEBITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 

		use in select( "seguridadEntidades" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestSeguridadEntidadesDescuentosDeLinea
		local lcEntidad as String, lcOperacion as String, lcTitulo as String
		use in select( "seguridadEntidades" )
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\seguridadentidades" ) in 0
		
		lcOperacion = "DESCUENTOLINEAARTICU"
		lcTitulo = "Descuento de Línea"
		lcEntidad = "FACTURA"
		
		select SeguridadEntidades
		
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "TICKETFACTURA"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "TICKETNOTADECREDITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "TICKETNOTADEDEBITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "NOTADECREDITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 
		lcEntidad = "NOTADEDEBITO"
		TestEspecificoParaLaTablaDeSeguridadEntidades( this, lcEntidad, lcOperacion, lcTitulo ) 

		use in select( "seguridadEntidades" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestVerificarObligatorios
		Local loEntidad As entidad Of entidad.prg, llAbrir As boolean, lcItem As String, lcEntidad As String, llOk as boolean

		If !Used( "diccionario" )
			llAbrir = .T.
			Select 0
			Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" )
		Endif

		lcEntidad = "CONTACTOS"
		Select diccionario

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "TITULO"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo TITULO", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el TITULO como obligatorio", diccionario.Obligatorio )

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "PRIMERNOMBRE"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo PRIMERNOMBRE", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el PRIMERNOMBRE como obligatorio", diccionario.Obligatorio )
		
		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "APELLIDO"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo APELLIDO", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el APELLIDO como obligatorio", diccionario.Obligatorio )

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "CLIENTE"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo CLIENTE", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el CLIENTE como obligatorio", diccionario.Obligatorio )

		lcEntidad = "MDAINCMDA"
		Select diccionario

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "CLIENTE"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo CLIENTE", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el CLIENTE como obligatorio", diccionario.Obligatorio )

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "RAZONSOCIAL"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo RAZONSOCIAL", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el RAZONSOCIAL como obligatorio", diccionario.Obligatorio )

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "CONSULTA"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo CONSULTA", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el CONSULTA como obligatorio", diccionario.Obligatorio )


		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "TIPOINCIDENTE"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo TIPOINCIDENTE", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el TIPOINCIDENTE como obligatorio", diccionario.Obligatorio )

		Locate For Upper( Alltrim( entidad ) ) = lcEntidad and alltrim( upper( Atributo ) ) == "SUBTIPOINCIDENTE"
		llOk = found()
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el atributo SUBTIPOINCIDENTE", llOk )
		This.Asserttrue( "La entidad " + lcEntidad + " debe tener el SUBTIPOINCIDENTE como obligatorio", diccionario.Obligatorio )

		If llAbrir
			Use In Select( "diccionario" )
		Endif

	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function zTestEntidadValorAtributoPersonalizarComprobante
		use in select( "Diccionario" )
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" )
		locate for alltrim( upper( Entidad ) ) == "VALOR" and upper( alltrim( Atributo ) ) == "PERSONALIZARCOMPROBANTE"
		This.Asserttrue( "No Existe el atriburo PersonalizarComprobante en valor", found() )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo ALTA", .T., Alta )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo GRUPO", 1, Grupo )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo SUBGRUPO", 1, SubGrupo )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo TIPOSUBGRUPO", 1, TipoSubGrupo )		
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo ETIQUETA", "Personalizar Comprobante", alltrim( Etiqueta ) )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo ETIQUETACORTA", "Perso. Comp.", alltrim( EtiquetaCorta )  )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo VALORSUGERIDO", "=.F.", alltrim( ValorSugerido ) )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo AYUDA", "Indica si se debe personalizar el comprobante", alltrim( Ayuda  ) )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo RESERVADO", .T., Reservado )
		This.AssertEquals( "El atributo PersonalizarComprobante tiene mal definido el campo GENHABILITAR", .T., GenHabilitar )
		
		use in select( "Diccionario" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificarPersonalizacionenValor	 

		use ( addbs( _screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" ) in 0
		select diccionario
		locate for alltrim( upper( Entidad ) ) == "VALOR"  and alltrim( upper( atributo ) ) == "TIPO"

		if found()
			This.assertequals( "El valor de la column DESPUESDEASIGNACION no es el correcto.", ;
				upper( "this.ProcesarDespuesDeSetear_Tipo()" ), alltrim( upper( diccionario.DESPUESDEASIGNACION ) ) )
		else
			This.asserttrue( "No se encuentra el atributo en la entidad valor", .f. )
		endif
		use in select( "diccionario" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_DisenoTransformacionLince
		
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" )
		select * from diccionario where upper( alltrim( entidad ) ) = "ITEMATRIBUTOSLINCE" ;
		and inlist( upper( alltrim( atributo ) ) , "ATRIBUTO", "ETIQUETA" ) ;
		into cursor "c_diseno"
		
		select c_diseno
		scan
			this.assertequals( "El formato del atributo " + alltrim( c_diseno.atributo ) + " no es el correcto. ", "!K", alltrim( c_diseno.formato ) )
		endscan

		use in select ( "diccionario" )
		use in select ( "c_Diseno" )		

	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	Function ztestU_VerificarValorSugeridoParaComboOrdenamientoEnListaDePrecios
		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" )
		locate for alltrim( upper( Entidad ) ) == "LISTADEPRECIOS" and upper( alltrim( atributo ) ) == "ORDENCONSULTA"
		This.AssertTrue( "No se encontro el Atributo ORDENCONSULTA.", found() )
		This.assertequals( "El sugerido del atributo Ordenamiento no es el correcto.", upper( alltrim( valorsugerido ) ), "=THIS.OBTENERPRIMERAPOSICIONDEORDENAMIENTOLIBRE()" )
		use in select ( "Diccionario" )

	endfunc 	
	
EndDefine







*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
function TestEspecificoParaLaTablaDeSeguridadEntidades( toFoxUNit as Object, tcEntidad as String, tcOperacion as String, tcTitulo as String ) as Void
		local loError as Exception
		try
			locate for upper( alltrim( Entidad ) ) == tcEntidad and upper( alltrim( Operacion ) ) == tcOperacion and ;
						alltrim( DescripcionOperacion ) = tcTitulo
			toFoxUNit.Asserttrue( "No se encuentra la operacion " + tcOperacion + " para la entidad " + tcEntidad, found() )
		catch to loError
			toFoxUNit.Asserttrue( "ERROR - No se encuentra la operacion " + tcOperacion + " para la entidad " + tcEntidad + " - Exceptio: " + transform(loError.message), .f. )
		endtry
endfunc 


