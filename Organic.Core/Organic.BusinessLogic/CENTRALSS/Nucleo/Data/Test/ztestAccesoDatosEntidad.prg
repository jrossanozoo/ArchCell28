**********************************************************************
define class ztestAccesoDatosEntidad as FxuTestCase of FxuTestCase.prg
	#if .f.
		local this as ztestAccesoDatosEntidad of ztestAccesoDatosEntidad.PRG
	#endif

	cTextoLargo = ""

	*-----------------------------------------------------------------------------------------
	function Setup
		text to this.cTextoLargo noshow textmerge
Desocupado lector, sin juramento me podrás creer que quisiera que este libro, como hijo del entendimiento, 
fuera el más hermoso, el más gallardo y más discreto que pudiera imaginarse. Pero no he podido yo contravenir
a la orden de naturaleza; que en ella cada cosa engendra su semejante. Y así, ¿qué podía engendrar el estéril
y mal cultivado ingenio mío sino la historia de un hijo seco, avellanado, antojadizo y lleno de pensamientos
varios y nunca imaginados por otro alguno, bien como quien se engendró en una cárcel, donde toda incomodidad
tiene su asiento y donde todo triste ruido hace su habitación?
		endtext
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local load as AccesoDatosEntidad of AccesoDatosEntidad.prg

		try
			load = _screen.zoo.crearobjeto( "Accesodatosentidad" )
		catch
		endtry

		this.Assertequals( "No se instancio", "L", vartype( load ) )

		load = newobject( "TestAccesodatosentidad" )
		this.Assertequals( "No se instancio", "O", vartype( load ) )
		This.Asserttrue( "Mal seteada la variable", loAd.lProcesarConTransaccion )
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerEstructura
		local loEntidad as Entidad of Entidad.prg, i as integer
		local array laTablaReal[ 1 ], laCursorEstructura[ 1 ]

		goServicios.Datos.EjecutarSentencias( "select * from uruguay", "Uruguay.dbf", addbs( _screen.zoo.cRutaInicial ) + addbs( _screen.Zoo.app.cSucursalActiva ) + "Dbf\", "Uruguay", set("Datasession"))

		afields( laTablaReal, "Uruguay" )
		use in select( "Uruguay" )

		loEntidad = _screen.Zoo.InstanciarEntidad( "Uruguay" )
		xmltocursor( loEntidad.oAD.ObtenerEstructura( alltrim( loEntidad.oAD.cTablaPrincipal ) ), "c_EstructuraUruguay", 4 )
		afields( laCursorEstructura, "c_EstructuraUruguay" )
		use in select( "c_EstructuraUruguay" )
		loEntidad.release()

		for i = 1 to alen( laTablaReal, 1 )
			lnPosicionCampo = ascan( laCursorEstructura, laTablaReal[ i, 1 ] )
			this.AssertEquals( "El nombre del campo es incorrecto " +  transform( i ) , laTablaReal[ i, 1 ], laCursorEstructura[ lnPosicionCampo ] )
			this.AssertEquals( "El Tipo de Dato es incorrecto " +  transform( i ), laTablaReal[ i, 2 ], laCursorEstructura[ lnPosicionCampo + 1 ] )
			this.AssertEquals( "La Longitud es incorrecta " +  transform( i ), laTablaReal[ i, 3 ], laCursorEstructura[ lnPosicionCampo + 2 ] )
			this.AssertEquals( "Los Decimales son incorrectos " +  transform( i ), laTablaReal[ i, 4 ], laCursorEstructura[ lnPosicionCampo + 3 ] )
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerConvertirDateSql
		local load as object, lcFecha as string

		load = newobject( "TestAccesodatosentidad" )

		lcFecha = load.ConvertirDateSql_Test( date(2010,07,31) )
		this.assertequals( "La fecha no es correcta", "20100731" , lcFecha )

		lcFecha = load.ConvertirDateSql_Test( {} )
		this.assertequals( "La fecha no es correcta", "19000101", lcFecha )

		lcFecha = load.ConvertirDateSql_Test( {^0009-01-01} )
		this.assertequals( "La fecha no es correcta", "20090101", lcFecha )

		lcFecha = load.ConvertirDateSql_Test( {^0980-05-13} )
		this.assertequals( "La fecha no es correcta", "19800513", lcFecha )

		lcFecha = load.ConvertirDateSql_Test( {^0065-05-13} )
		this.assertequals( "La fecha no es correcta", "19650513", lcFecha )

		load.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestNativaLlenarArrayMemos_Integral
		local loEntidad as object

		loEntidad = _screen.zoo.InstanciarEntidad( "Color" )
		loEntidad.oAD = newobject( "din_entidadColorAD_TEST" )
		loEntidad.oAD.InyectarEntidad( loEntidad )
		loEntidad.oAD.Inicializar()
		loEntidad.Nuevo()
		loEntidad.Codigo = "01"
		loEntidad.Observacion = this.cTextoLargo
		loEntidad.oAD.LlenarArrayMemo_test( "cObs", "Observacion", loEntidad.Codigo )
		this.assertequals( "La cantidad de sentencias no es correcta", 9, alen( loEntidad.oAD.aSqlMemos ) )
		this.assertequals( "No esta la sentencia delete", "delete from col_cobs where colcod = 01", lower( loEntidad.oAD.aSqlMemos[1] ) )
		this.assertequals( "No esta la sentencia insert de orden 1", ;
			"insert  into col_cobs(colcod, orden, texto ) values ( 01,1,'desocupado lector, sin juramento me podrás creer que quisiera que este libro, co')", ;
			lower( loEntidad.oAD.aSqlMemos[2] ) )
		this.assertequals( "No esta la sentencia insert de orden 2", ;
			"insert  into col_cobs(colcod, orden, texto ) values ( 01,2,'mo hijo del entendimiento, æðfuera el más hermoso, el más gallardo y más discret')", ;
			lower( loEntidad.oAD.aSqlMemos[3] ) )

		loEntidad.Cancelar()
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestNativaGenerarSentenciasTablaMemo
		local loAcceso as Object
		
		loAcceso = newobject( "AccesoDatosEntidad_Nativa_test" )
		loAcceso.GenerarSentenciasInsertTablaMemo_TEST( this.cTextoLargo, "MiTabla", "pk" )
		this.assertequals( "La cantidad de sentencias no es correcta", 8, alen( loAcceso.aSqlMemos ) )
		this.assertequals( "No esta la sentencia insert de orden 1", ;
			"insertar en la tabla mitabla( pk, orden, texto) values (pk,1,'desocupado lector, sin juramento me podrás creer que quisiera que este libro, co' )", ;
			lower( loAcceso.aSqlMemos[1] ) )
		this.assertequals( "No esta la sentencia insert de orden 2", ;
			"insertar en la tabla mitabla( pk, orden, texto) values (pk,2,'mo hijo del entendimiento, æðfuera el más hermoso, el más gallardo y más discret' )", ;
			lower( loAcceso.aSqlMemos[2] ) )
		loAcceso.release()
	endfunc 

enddefine

define class TestAccesodatosentidad as  Accesodatosentidad of Accesodatosentidad.prg

	*-----------------------------------------------------------------------------------------
	function ConvertirDateSql_Test( tdValor as date ) as string
		return this.ConvertirDateSql( tdValor )
	endfunc

enddefine

define class din_entidadColorAD_TEST as din_entidadColorAD of din_entidadColorAD.prg

	*-----------------------------------------------------------------------------------------
	function LlenarArrayMemo_test( tcCampo as String, tcAtributo as String, txValorClavePrimaria as variant ) as void 
		this.LlenarArrayMemo( tcCampo, tcAtributo, txValorClavePrimaria )
	endfunc

enddefine

define class AccesoDatosEntidad_Nativa_test as AccesoDatosEntidad_Nativa of AccesoDatosEntidad_Nativa.prg

	*-----------------------------------------------------------------------------------------
	function GenerarSentenciasInsertTablaMemo_TEST( tcTexto as String, tcTabla as String, txValorClavePrimaria as String ) as Void
		this.GenerarSentenciasInsertTablaMemo( tcTexto, tcTabla, txValorClavePrimaria )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaInsertMemo( tcTabla as String, txValorClavePrimaria as String, tcOrden as String, tcTexto as String ) as String
		return "insertar en la tabla " + tcTabla + "( PK, orden, texto) values (" + txValorClavePrimaria + "," + tcOrden + ",'" + tcTexto + "' )"
	endfunc 
enddefine
