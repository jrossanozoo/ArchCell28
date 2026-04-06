**********************************************************************
DEFINE CLASS ztestsqlserverFacturacionLince as FxuTestCase OF FxuTestCase.prg
	#IF .f.

	LOCAL THIS AS ztestsqlserverFacturacionLince OF ztestsqlserverFacturacionLince.prg
	#ENDIF


	*-----------------------------------------------------------------------------------------
	function Setup
		local lcSql as String 
		
		lcSql = "delete from zl.RzIncoap  where convert( varchar, Fmodifw, 103  ) = convert( varchar, GETDATE(), 103  )"

		goServicios.Datos.ejecutarsentencias( lcSql, "", "", "", set("Datasession" ) )

	endfunc 
	

	FUNCTION TearDown
 

	ENDFUNC

*-----------------------------------------------------------------------------------------

	function zTestSQLServerGenerarFacturacionYNotasDeCreditoYCobranzas
		local loActZoo as Object, lcComprobante as String, lcRazonSocial as String , ;
			loManejaArchivos as Object, locol as collection,;
			lcUbicacionDbf as String, loInfoProblemasEnFac as Collection, lcXml as String ,;
			lnCampos as Integer, lcCampo1 as String, lcTabla as String , i as Integer, ;
			lcCampo2 as String, ldFecha as Date, lcRutaLince as string 

		local array laGenerados(1), laEsperados(1)

		private goServicios
		goServicios = _Screen.zoo.crearobjeto( "serviciosaplicacion" )
		goServicios.Librerias = createobject( "Mock_LibreriasTest" )
 	
		ldFecha = goServicios.Librerias.ObtenerFecha()
		
		PrepararEntornoLince( 1 ) 
		
		lcUbicacionDbf = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"
		lcRutaLince = strtran( upper(lcUbicacionDbf),"\DBF\", "")
		loActZoo = _Screen.zoo.CrearObjeto( "ActualizarZooAux", "zTestSqlServerRazonesSocialesIncobrables.prg" )

		this.asserttrue ( "Facturacion Electronica", loActZoo.oFacturacionLince.GeneraFacElec )
		locol = loActZoo.LanzarFacturacionEnLince( "mi_exel.xls", lcRutaLince, ldFecha )
		loInfoProblemasEnFac = loActZoo.oFacturacionLince.ObtenerInformacion()
		this.assertEquals( "Hubo problemas en la Generacion de la facturacion", 0, loInfoProblemasEnFac.Count )
		this.assertEquals( "No se genero La cantidad correcta de comprobantes" , 2, locol.Count )
		this.assertEquals( "No se genero La Factura B" , "Factura B Nº 1-3022377", locol.Item(1) )
		this.assertEquals( "No se genero La Factura A" , "Factura A Nº 1-4122364", locol.Item(2) )
				
		lcRazonSocial = "00004"
		locol = loActZoo.GenerarComprobantesRazonesSocialesIncobrables( lcRazonSocial, lcRutaLince, ldFecha )
		this.assertEquals( "No se genero La cantidad correcta de comprobantes para la Razon social " + lcRazonSocial, 2, locol.Count )
		this.assertEquals( "No se genero La Nota de credito para la Razon social " + lcRazonSocial, "Nota de crédito B Nº 1-3000646", locol.Item(1) )
		this.assertEquals( "No se genero El Canje de Valores para la Razon social " + lcRazonSocial, "Canje de valores Nº 1", locol.Item(2) )		
		
		
		lcRazonSocial = "09462"
		locol = loActZoo.GenerarComprobantesRazonesSocialesIncobrables( lcRazonSocial, lcRutaLince, ldFecha )
		this.assertEquals( "No se genero La cantidad correcta de comprobantes para la Razon social " + lcRazonSocial, 2, locol.Count )
		this.assertEquals( "No se genero La Nota de credito para la Razon social " + lcRazonSocial, "Nota de crédito A Nº 1-4002215", locol.Item(1) )
		this.assertEquals( "No se genero La Cobranza para la Razon social " + lcRazonSocial, "Cobranza Nº 1000013", locol.Item(2) )

		use ( addbs( lcUbicacionDbf ) + "ctb.dbf" ) in select( "ctb" ) share 
		use ( addbs( lcUbicacionDbf ) + "val.dbf" ) in select( "val" ) share 
		use ( addbs( lcUbicacionDbf ) + "fac.dbf" ) in select( "fac" ) share 	
		use ( addbs( lcUbicacionDbf ) + "facm.dbf" ) in select( "facm" ) share 
		
		lcTabla = "Ctb"
		lcXml = DevolverCtb()
		xmltocursor( lcXml, "Cur_" + lcTabla, 4 )

		this.assertEquals( "La cantidad de registros generados en la tabla " + upper(lcTabla) + " no es correcta", reccount( "Cur_"+lcTabla ), reccount( lcTabla ))

		lnCampos = afields( laEsperados, "Cur_"+ lcTabla )
		afields( laGenerados , lcTabla )
		
		go top in &lcTabla
		select ( "Cur_" + lcTabla )
		scan
			for i=1 to lnCampos 
				lcCampo1 = "cur_"+ lcTabla + "." + field( i )
				lcCampo2 = lcTabla + "." + field( i )
				this.assertequals( "No coincide el valor del campo " + field( i ) + " en la tabla " + upper( lcTabla ) + ".DBF", &lcCampo1 , &lcCampo2 )
			endfor 
			if recno() < reccount()
				skip 1 in ( lcTabla )
			endif 		
		endscan

		lcTabla = "Val"
		lcXml = DevolverVal()
		
		xmltocursor( lcXml, "Cur_" + lcTabla, 4 )
		this.assertEquals( "La cantidad de registros generados en la tabla " + upper(lcTabla) + " no es correcta", reccount( "Cur_"+lcTabla ), reccount( lcTabla ))

		lnCampos = afields( laEsperados, "Cur_"+ lcTabla )
		afields( laGenerados , lcTabla )
		
		go top in &lcTabla
		select ( "Cur_" + lcTabla )
		scan
			for i=1 to lnCampos 
				lcCampo1 = "cur_"+ lcTabla + "." + field( i )
				lcCampo2 = lcTabla + "." + field( i )
				this.assertequals( "No coincide el valor del campo " + field( i ) + " en la tabla " + upper( lcTabla ) + ".DBF", &lcCampo1 , &lcCampo2 )
			endfor 
			if recno() < reccount()
				skip 1 in ( lcTabla )
			endif 		
		endscan

		lcTabla = "Fac"
		lcXml = DevolverFac()

		xmltocursor( lcXml, "Cur_" + lcTabla, 4 )
		this.assertEquals( "La cantidad de registros generados en la tabla " + upper(lcTabla) + " no es correcta", reccount( "Cur_"+lcTabla ), reccount( lcTabla ))

		lnCampos = afields( laEsperados, "Cur_"+ lcTabla )
		afields( laGenerados , lcTabla )
		
		go top in &lcTabla
		select ( "Cur_" + lcTabla )
		scan
			for i=1 to lnCampos 
				if !inlist( upper( field(i) ), "FHORA", "FFCH" )
					lcCampo1 = "cur_"+ lcTabla + "." + field( i )
					lcCampo2 = lcTabla + "." + field( i )
					this.assertequals( "No coincide el valor del campo " + field( i ) + " en la tabla " + upper( lcTabla ) + ".DBF", &lcCampo1 , &lcCampo2 )
				endif 	
			endfor 
			if recno() < reccount()
				skip 1 in ( lcTabla )
			endif 		
		endscan


		lcTabla = "FacM"
		lcXml = DevolverFacM()
		
		xmltocursor( lcXml, "Cur_" + lcTabla, 4 )
		this.assertEquals( "La cantidad de registros generados en la tabla " + upper(lcTabla) + " no es correcta", reccount( "Cur_"+lcTabla ), reccount( lcTabla ))

		lnCampos = afields( laEsperados, "Cur_"+ lcTabla )
		afields( laGenerados , lcTabla )
		
		go top in &lcTabla
		select ( "Cur_" + lcTabla )
		scan
			for i=1 to lnCampos 
				lcCampo1 = "cur_"+ lcTabla + "." + field( i )
				lcCampo2 = lcTabla + "." + field( i )
				this.assertequals( "No coincide el valor del campo " + field( i ) + " en la tabla " + upper( lcTabla ) + ".DBF", &lcCampo1 , &lcCampo2 )
			endfor 
			if recno() < reccount()
				skip 1 in ( lcTabla )
			endif 		
		endscan

		use in select( "ctb" ) 
		use in select( "Cur_Ctb" )
		use in select( "val" ) 
		use in select( "Cur_val" ) 
		use in select( "fac" ) 
		use in select( "Cur_fac" ) 
		use in select( "facm" ) 
		use in select( "Cur_facm" ) 		
		loActZoo.release()
	endfunc


ENDDEFINE



*-----------------------------------------------------------------------------------------
function PrepararEntornoLince( tnTalonariofacturacion as Integer ) as Void
	local loManejaArchivos as Object, lcUbicacionDbf as String, lcUbicacionIdx as String,;
		  lcXml as String, lcTempDbf as String 
	
	*!*	 DRAGON 2028
	loManejaArchivos = newobject( "manejoarchivos", "manejoarchivos.prg" )
	_Screen.Zoo.App.cRutaLince = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"
	lcUbicacionDbf = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"
	lcUbicacionIdx = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\IDX\"

	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "usu.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "ctb.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "fac.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "facm.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "val.dbf" )	
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "cli.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "art.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "X.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "St.dbf" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "Corre.dbf" )	
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionDbf  ) + "Series.dbf" )		
	
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "ctb1.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "ctb2.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "ctb3.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "ctb4.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "ctb5.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "ctb6.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "fac1.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "fac2.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "fac3.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "fac4.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "fac5.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "fac6.idx" )	
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "facm1.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val1.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val2.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val3.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val4.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val5.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val6.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "val7.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli1.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli2.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli3.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli4.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli5.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli6.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "cli7.idx" )	
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "art1.idx" )
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "St1.idx" )	
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "St2.idx" )		
	loManejaArchivos.SetearAtributos( "N", addbs( lcUbicacionIdx ) + "corre1.idx" )
			
	use ( addbs( lcUbicacionDbf  ) + "ctb.dbf" ) in select( "ctb" ) exclu
	select ctb 
	set index to ( lcUbicacionIdx + "ctb1" )
	set index to ( lcUbicacionIdx + "ctb2" ) additive
	set index to ( lcUbicacionIdx + "ctb3" ) additive
	set index to ( lcUbicacionIdx + "ctb4" ) additive
	set index to ( lcUbicacionIdx + "ctb5" ) additive
	set index to ( lcUbicacionIdx + "ctb6" ) additive	
	zap
	reindex compact 
	use in select( 'Ctb' )

	use ( addbs( lcUbicacionDbf  ) + "fac.dbf" ) in select( "fac" ) exclu
	select fac 
	set index to ( lcUbicacionIdx + "fac1" )
	set index to ( lcUbicacionIdx + "fac2" ) additive
	set index to ( lcUbicacionIdx + "fac3" ) additive
	set index to ( lcUbicacionIdx + "fac4" ) additive
	set index to ( lcUbicacionIdx + "fac5" ) additive
	set index to ( lcUbicacionIdx + "fac6" ) additive	
	zap
	reindex compact 
	use in select( 'fac' )

	use ( addbs( lcUbicacionDbf  ) + "facm.dbf" ) in select( "facm" ) exclu
	select facm 
	set index to ( lcUbicacionIdx + "facm1" )
	zap
	reindex compact 
	use in select( 'facm' )	

	
	use ( addbs( lcUbicacionDbf  ) + "val.dbf" ) in select( "val" ) exclu
	select val 
	set index to ( lcUbicacionIdx + "val1" )
	set index to ( lcUbicacionIdx + "val2" ) additive
	set index to ( lcUbicacionIdx + "val3" ) additive
	set index to ( lcUbicacionIdx + "val4" ) additive
	set index to ( lcUbicacionIdx + "val5" ) additive
	set index to ( lcUbicacionIdx + "val6" ) additive	
	set index to ( lcUbicacionIdx + "val7" ) additive	
	zap
	reindex compact 
	use in select( 'val' )	
	

	use ( addbs( lcUbicacionDbf  ) + "cli.dbf" ) in select( "cli" ) exclu
	select cli 
	set index to ( lcUbicacionIdx + "cli1" )
	set index to ( lcUbicacionIdx + "cli2" ) additive
	set index to ( lcUbicacionIdx + "cli3" ) additive
	set index to ( lcUbicacionIdx + "cli4" ) additive
	set index to ( lcUbicacionIdx + "cli5" ) additive
	set index to ( lcUbicacionIdx + "cli6" ) additive	
	set index to ( lcUbicacionIdx + "cli7" ) additive	
	zap
	reindex compact 

	*!*	 DRAGON 2028
	lcXml = ObtenerCursorClientes()
	lcTempDbf = addbs(sys(2023)) + sys(2015) + ".dbf"
	xmltocursor( lcXml, "Mi_cursor", 4 )
	select * from Mi_cursor into table (lcTempDbf)
	use in select( "Mi_cursor" )
	select cli
	append from (lcTempDbf)
	use in select( juststem(lcTempDbf) )
	erase (lcTempDbf)
	lcXml = ObtenerCursorValores()
	lcTempDbf = addbs(sys(2023)) + sys(2015) + ".dbf"
	xmltocursor( lcXml, "Mi_cursor", 4 )
	select * from Mi_cursor into table (lcTempDbf)
	use in select( "Mi_cursor" )
	select cli
	append from (lcTempDbf)
	use in select( juststem(lcTempDbf) )
	erase (lcTempDbf)
	use in select( 'cli' )		
	
	
	use ( addbs( lcUbicacionDbf  ) + "art.dbf" ) in select( "art" ) exclu
	select art 
	set index to ( lcUbicacionIdx + "art1" )
	zap
	reindex compact 
	lcXml = ObtenerCursorArticulos()
	lcTempDbf = addbs(sys(2023)) + sys(2015) + ".dbf"
	xmltocursor( lcXml, "Mi_cursor", 4 )
	select * from Mi_cursor into table (lcTempDbf)
	use in select( "Mi_cursor" )
	select art
	append from (lcTempDbf)
	use in select( juststem(lcTempDbf) )
	erase (lcTempDbf)
	use in select( 'art' )	


	use ( addbs( lcUbicacionDbf  ) + "Corre.dbf" ) in select( "Corre" ) exclu
	select Corre 
	set index to ( lcUbicacionIdx + "Corre1" )
	zap
	insert into Corre (cocod, conom ) values ( '058', 'EJ DSUBIRON' )                                                 
	insert into Corre (cocod, conom ) values ( '003', 'EJ MCAODURO' )                                                 
	reindex compact 
	use in select( 'Corre' )	


	use ( addbs( lcUbicacionDbf  ) + "St.dbf" ) in select( "St" ) share
	select st
	set index to ( lcUbicacionIdx + "St1" )
	set index to ( lcUbicacionIdx + "St2" ) additive
	Set Order To 1
	
	
	seek( 4255 + ( tnTalonariofacturacion ) * 6 )
	replace st.stn1 with 122363 &&Factura A
	seek( 4255 + ( ( tnTalonariofacturacion ) * 6 ) + 3 )
	replace st.stn1 with 22376  &&Factura B
	
	seek( 4255 + ( tnTalonariofacturacion ) * 6 ) + 1
	replace st.stn1 with 2214 &&Nota de cred A
	seek( 4255 + ( ( tnTalonariofacturacion ) * 6 ) + 3 ) + 1
	replace st.stn1 with 645  &&Nota de cred B
	
	
	Use In Select("st")
	
	use ( addbs( lcUbicacionDbf  ) + "X.dbf" ) in select( "X" ) share
	select X
	go top
	replace X.xreca with 1000012 ,;
			X.XSQC with 78 ,;
			X.hnum with 101

	Use In Select("X")
	
	loManejaArchivos = null
	
endfunc 

*******************************************************************************************
define class ActualizarZooAux as ActualizarZoo of ActualizarZoo.prg

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerEsquemaTablaSQL( tcTabla as String ) as String 
		return tcTabla
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		local ldFecha as Date 
		dodefault()
		ldFecha = goServicios.Librerias.ObtenerFecha()
		this.oFacturacionLince = newobject( "FacturacionLinceAux", "zTestSqlServerRazonesSocialesIncobrables.prg" )
		this.oFacturacionLince.txtArtTT = "  TT  M"+right(alltrim(str(year(ldFecha))),2)+ right("0"+alltrim(str(month(ldFecha))),2)	
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function EjecutarSentencia( tcSql, tcCursor, tnIdSesion ) as VOID 
		local lcSql as String, lcUbicacionDbf as String

		lcUbicacionDbf = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"

		use ( addbs( lcUbicacionDbf  ) + "ctb.dbf" ) in select( "ctb" ) share 
		use ( addbs( lcUbicacionDbf  ) + "val.dbf" ) in select( "val" ) share 

		lcSql = strtran( tcSql, "isnull" , "nvl" ) 
		lcSql = strtran( lcSql, "is null", "=null" ) + " into Cursor " + tcCursor + " READWRITE"
		&lcSql

		use in select( "ctb" )
		use in select( "val" ) 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCONDICIONDEPAGO( tcRazonSocial , tMontoDeudaCtaCte, tMontoDeudaCupones ) as Boolean 
		return .t.
	endfunc 	

enddefine

*****************************************************************************************************
define class FacturacionLinceAux as FacturacionLince of FacturacionLince.prg


	*-----------------------------------------------------------------------------------------	
	protected function EjecutarSentencia( tcSql, tcCursor, tnIdSesion ) as VOID 
		local lcSql as String, lcUbicacionDbf as String, llAbroFacYo as Boolean 

		llAbroFacYo = !used( 'Fac' )
		
		lcUbicacionDbf = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\SucursalLince\DBF\"
		if llAbroFacYo 
			use ( addbs( lcUbicacionDbf  ) + "fac.dbf" ) in select( "fac" ) share 
		endif 	

		lcSql = strtran( tcSql, "Floor", "int" ) + " into Cursor " + tcCursor + " READWRITE"
		&lcSql

		if llAbroFacYo 
			use in select( "fac" )
		endif 	
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearYLLenarFcAuxDeUnXLS( tcOrigenDeDatos ) as Void
		local lcXml as String 
		lcXml = ObtenerCursorFacturacionXLS()
		xmltocursor( lcXml, "FcAux", 4 )
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerEsquemaTablaSQL( tcTabla as String ) as String 
		return tcTabla
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerOrderByConsultaDeuda() as String
		local lcRetorno as String 
		lcRetorno = "group by fart, fcotxt ,ft051, ftxt, fxIva1, fperson  " +;
					" order by fcotxt desc, fart desc"
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerWhereAdicional() as String
		return " and left(fart , 2) = 'IT' " 
	endfunc 	
		
enddefine

	

*****************************************************************************************************
*-----------------------------------------------------------------------------------------
function ObtenerCursorClientes() as String 
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
							<xsd:attribute name="clcod" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cltpo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clnom" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cldir" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clloc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cliva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcuit" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cldto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clser" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clser2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="climpd" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="climpa" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cltlf" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmonto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cllist" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvcod" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvdias" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvporj" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvcuotas" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvdiaini" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvdiapag" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvcodpag" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcan4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clruta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="4"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clfax" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcontac" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clobs" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="76"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvend" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clprov" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clngan" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clfecha" type="xsd:date" use="required"/>
							<xsd:attribute name="clcfi" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clacum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clfing" type="xsd:date" use="required"/>
							<xsd:attribute name="cd1" type="xsd:date" use="required"/>
							<xsd:attribute name="cl1" type="xsd:boolean" use="required"/>
							<xsd:attribute name="cn1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cnx1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc011" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc051" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc101" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc201" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc401" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc601" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clco_dto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="6"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clentr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clt_dir" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clt_cuit" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clre_ivap" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clre_ivam" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpe_ibp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpe_ibm" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clogic" type="xsd:boolean" use="required"/>
							<xsd:attribute name="clretivac" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretganc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretibrc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretivav" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretganv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretibrv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clemail" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpageweb" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clprv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcuoreal" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcobade" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clperibru" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cltope" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clavanacum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clacumtot" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretsegv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretsegc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clsitib" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clnroib" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="20"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="regiibb" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmayde1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmayde2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpais" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="monex" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
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
	<row clcod="00004" cltpo="1" clnom="Godoy Maria Paula                                           " cldir="H. Quiroga - Local 353 4901                                 " clloc="Ituzaingo                               " clcp="1714    " cliva="3" clcuit="27-22782400-5  " cldto="0.00" clser="1" clser2="1" climpd="00004   " climpa="        " cltlf="                                                            " clmonto="0.00" cllist="3" clvcod="F    " clvdias="0" clvporj="0.00" clvcuotas="0" clvdiaini="0" clvdiapag="0" clvcodpag="     " clcan4="0" clpun1="0.00" clpun2="0.00" clpun3="0.00" clpun4="0.00" clmon1="0.00" clmon2="0.00" clmon3="0.00" clmon4="0.00" clruta="    " clfax="                                                            " clcontac="                                                            " clobs=" - GODOY MARIA PAULA                                                        " clvend="     " clprov="01" clngan="          " clfecha="    -  -  " clcfi="1" clacum="-7.68" clfing="    -  -  " cd1="    -  -  " cl1="false" cn1="0" cnx1="0.00" cc011=" " cc051="003  " cc101="          " cc201="                    " cc401="                                        " cc601="00004 - NATURAL LIFE                                        " clco_dto="      " clentr="CBU Nº 0720281288000035904768                               " clt_dir="Buenos Aires - Argentina                                    " clt_cuit="               " clre_ivap="0.00" clre_ivam="0.00" clpe_ibp="0.00" clpe_ibm="0.00" clogic="false" clretivac="  " clretganc="   " clretibrc="  " clretivav=" " clretganv=" " clretibrv=" " clemail="                                                            " clpageweb="                                                            " clprv="01" clcuoreal="0" clcobade="0" clperibru="X" cltope="0.00" clavanacum="0.00" clacumtot="0.00" clretsegv=" " clretsegc="  " clsitib="0" clnroib="0" regiibb="1.00" clmayde1="0.00" clmayde2="0.00" clpais="   " monex="0"/>
	<row clcod="09462" cltpo="1" clnom="Batatalandia SA                                             " cldir="Ramon Falcon 3246                                           " clloc="Cuidadela                               " clcp="1702    " cliva="1" clcuit="30-71175509-4  " cldto="0.00" clser="1" clser2="0" climpd="09745   " climpa="        " cltlf="                                                            " clmonto="0.00" cllist="3" clvcod="PRE  " clvdias="0" clvporj="0.00" clvcuotas="0" clvdiaini="0" clvdiapag="0" clvcodpag="     " clcan4="0" clpun1="0.00" clpun2="0.00" clpun3="0.00" clpun4="0.00" clmon1="0.00" clmon2="0.00" clmon3="0.00" clmon4="0.00" clruta="    " clfax="                                                            " clcontac="                                                            " clobs="                                                                            " clvend="     " clprov="01" clngan="          " clfecha="    -  -  " clcfi="1" clacum="0.00" clfing="    -  -  " cd1="    -  -  " cl1="false" cn1="0" cnx1="0.00" cc011=" " cc051="058  " cc101="          " cc201="                    " cc401="                                        " cc601="                                                            " clco_dto="      " clentr="                                                            " clt_dir="Buenos Aires - Argentina                                    " clt_cuit="               " clre_ivap="0.00" clre_ivam="0.00" clpe_ibp="0.00" clpe_ibm="0.00" clogic="false" clretivac="  " clretganc="   " clretibrc="  " clretivav=" " clretganv=" " clretibrv=" " clemail="                                                            " clpageweb="                                                            " clprv="01" clcuoreal="0" clcobade="0" clperibru=" " cltope="0.00" clavanacum="0.00" clacumtot="0.00" clretsegv=" " clretsegc="  " clsitib="0" clnroib="0" regiibb="0.00" clmayde1="0.00" clmayde2="0.00" clpais="   " monex="0"/>
</VFPData>
endtext
return lcXml
endfunc 

*-----------------------------------------------------------------------------------------
function ObtenerCursorArticulos() as String 
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
							<xsd:attribute name="artcod" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="13"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artdes" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artuni" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artpr1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artpr2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artpr3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artpr4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artiva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="arttip" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artppc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artppv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artcnf" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artfab" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artremi" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artbrev" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artpuntada" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artgrupo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artcolor" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="17"/>
										<xsd:fractionDigits value="4"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr5" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr6" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr7" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr8" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr9" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="apr10" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="aoferta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="acant" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="acantmin" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="12"/>
										<xsd:fractionDigits value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="astock" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="amate" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="aesta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="aano" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="abarra1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="13"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="abarra2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="13"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ad1" type="xsd:date" use="required"/>
							<xsd:attribute name="ad2" type="xsd:date" use="required"/>
							<xsd:attribute name="ad3" type="xsd:date" use="required"/>
							<xsd:attribute name="ad4" type="xsd:date" use="required"/>
							<xsd:attribute name="ad5" type="xsd:date" use="required"/>
							<xsd:attribute name="al1" type="xsd:boolean" use="required"/>
							<xsd:attribute name="al2" type="xsd:boolean" use="required"/>
							<xsd:attribute name="al3" type="xsd:boolean" use="required"/>
							<xsd:attribute name="an1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="an2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="an3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="an4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="an5" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="anx1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="anx2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="anx3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="anx4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="anx5" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at051" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at052" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at053" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at054" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at101" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at102" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at103" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at104" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at105" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at201" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at202" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at203" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at204" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at205" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at401" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at402" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at403" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at404" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at601" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="at602" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artconiva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artporiva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artesunkit" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artcondevo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artrinde" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="4"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="artimport" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
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
	<row artcod="  TT  A201110" artdes="Abono mensual software Zoo Logic 10/2011" artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="          " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="0" acant="11.00" acantmin="0.000" astock="1" amate="          " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2009-09-17" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="0" artcondevo="0" artrinde="0.0000" artimport="0"/>
	<row artcod="  TT  A201111" artdes="Abono mensual software Zoo Logic 11/2011" artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="          " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="0" acant="1.00" acantmin="0.000" astock="1" amate="          " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2009-09-17" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="0" artcondevo="0" artrinde="0.0000" artimport="0"/>
	<row artcod="IT0069993    " artdes="FFac:20091023 S:103044 Art:BA           " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2009-11-02" ad2="2011-11-01" ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="0" artcondevo="1" artrinde="0.0000" artimport="0"/>
	<row artcod="IT0069994    " artdes="FFac:20091023 S:103044 Art:TC           " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2009-11-02" ad2="2011-11-01" ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="0" artcondevo="1" artrinde="0.0000" artimport="0"/>
	<row artcod="IT0073075    " artdes="FFac:20100115 S:106714 Art:LBA          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2010-02-01" ad2="2011-11-01" ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="0" artcondevo="1" artrinde="0.0000" artimport="0"/>
	<row artcod="IT0099005    " artdes="FFac:20090129 S:103797 Art:LBA          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099006    " artdes="FFac:20111019 S:103797 Art:LBN          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099007    " artdes="FFac:20090129 S:103799 Art:LBA          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099008    " artdes="FFac:20090129 S:103799 Art:LBN          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099009    " artdes="FFac:20111020 S:103799 Art:LDP          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099010    " artdes="FFac:20090129 S:103800 Art:LBA          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099011    " artdes="FFac:20090129 S:103800 Art:LBN          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
	<row artcod="IT0099012    " artdes="FFac:20111020 S:103800 Art:LDP          " artuni="   " artpr1="0.00" artpr2="0.00" artpr3="0.00" artpr4="0.00" artiva="1" arttip="0" artppc="        " artppv="        " artcnf=" " artfab="     " artremi="1" artbrev="2" artpuntada="0" artgrupo="A         " artcolor="0" apr1="0.0000" apr2="0.00" apr3="0.00" apr4="0.00" apr5="0.00" apr6="0.00" apr7="0.00" apr8="0.00" apr9="0.00" apr10="0.00" aoferta="1" acant="0.00" acantmin="0.000" astock="2" amate="LS11      " aesta="1" aano="  " abarra1="             " abarra2="             " ad1="2011-11-01" ad2="    -  -  " ad3="    -  -  " ad4="    -  -  " ad5="    -  -  " al1="false" al2="false" al3="false" an1="0.00" an2="0" an3="0" an4="0" an5="0" anx1="0.00" anx2="0.00" anx3="0.00" anx4="0.00" anx5="0.00" at051="     " at052="     " at053="     " at054="     " at101="          " at102="          " at103="          " at104="          " at105="          " at201="                    " at202="                    " at203="                    " at204="                    " at205="                    " at401="                                        " at402="                                        " at403="                                        " at404="                                        " at601="                                                            " at602="                                                            " artconiva="1" artporiva="0.00" artesunkit="1" artcondevo="1" artrinde="0.0000" artimport="2"/>
</VFPData>
endtext
return lcXml
endfunc 

*-----------------------------------------------------------------------------------------
function ObtenerCursorValores() as String 
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
							<xsd:attribute name="clcod" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cltpo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clnom" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cldir" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clloc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cliva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcuit" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cldto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clser" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clser2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="climpd" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="climpa" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cltlf" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmonto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cllist" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvcod" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvdias" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvporj" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvcuotas" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvdiaini" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvdiapag" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvcodpag" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcan4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpun4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmon4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clruta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="4"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clfax" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcontac" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clobs" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="76"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clvend" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clprov" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clngan" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clfecha" type="xsd:date" use="required"/>
							<xsd:attribute name="clcfi" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clacum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clfing" type="xsd:date" use="required"/>
							<xsd:attribute name="cd1" type="xsd:date" use="required"/>
							<xsd:attribute name="cl1" type="xsd:boolean" use="required"/>
							<xsd:attribute name="cn1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cnx1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc011" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc051" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc101" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc201" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc401" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cc601" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clco_dto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="6"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clentr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clt_dir" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clt_cuit" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clre_ivap" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clre_ivam" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpe_ibp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpe_ibm" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clogic" type="xsd:boolean" use="required"/>
							<xsd:attribute name="clretivac" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretganc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretibrc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretivav" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretganv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretibrv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clemail" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpageweb" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clprv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcuoreal" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="2"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clcobade" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clperibru" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cltope" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clavanacum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clacumtot" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretsegv" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clretsegc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clsitib" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clnroib" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="20"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="regiibb" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmayde1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clmayde2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="clpais" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="monex" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
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
	<row clcod="C    " cltpo="7" clnom="CTA CTE                                                     " cldir="                                                            " clloc="                                        " clcp="        " cliva="1" clcuit="               " cldto="0.00" clser="0" clser2="0" climpd="        " climpa="        " cltlf="                                                            " clmonto="0.00" cllist="0" clvcod="     " clvdias="0" clvporj="0.00" clvcuotas="0" clvdiaini="30" clvdiapag="0" clvcodpag="     " clcan4="1" clpun1="0.00" clpun2="0.00" clpun3="0.00" clpun4="0.00" clmon1="0.00" clmon2="0.00" clmon3="0.00" clmon4="0.00" clruta="    " clfax="                                                            " clcontac="                                                            " clobs="                                                                            " clvend="     " clprov="  " clngan="          " clfecha="    -  -  " clcfi="5" clacum="0.00" clfing="    -  -  " cd1="    -  -  " cl1="false" cn1="0" cnx1="0.00" cc011=" " cc051="     " cc101="          " cc201="                    " cc401="                                        " cc601="                                                            " clco_dto="      " clentr="                                                            " clt_dir="                                                            " clt_cuit="               " clre_ivap="0.00" clre_ivam="0.00" clpe_ibp="0.00" clpe_ibm="0.00" clogic="false" clretivac="  " clretganc="   " clretibrc="  " clretivav=" " clretganv=" " clretibrv=" " clemail="                                                            " clpageweb="                                                            " clprv="  " clcuoreal="0" clcobade="0" clperibru=" " cltope="0.00" clavanacum="0.00" clacumtot="0.00" clretsegv=" " clretsegc="  " clsitib="0" clnroib="0" regiibb="0.00" clmayde1="0.00" clmayde2="0.00" clpais="   " monex="0"/>
	<row clcod="P    " cltpo="7" clnom="PESOS                                                       " cldir="                                                            " clloc="                                        " clcp="        " cliva="1" clcuit="               " cldto="0.00" clser="0" clser2="0" climpd="        " climpa="        " cltlf="                                                            " clmonto="0.00" cllist="0" clvcod="     " clvdias="0" clvporj="0.00" clvcuotas="0" clvdiaini="0" clvdiapag="0" clvcodpag="     " clcan4="0" clpun1="0.00" clpun2="0.00" clpun3="0.00" clpun4="0.00" clmon1="0.00" clmon2="0.00" clmon3="0.00" clmon4="0.00" clruta="    " clfax="                                                            " clcontac="                                                            " clobs="                                                                            " clvend="     " clprov="  " clngan="          " clfecha="    -  -  " clcfi="1" clacum="0.00" clfing="    -  -  " cd1="    -  -  " cl1="false" cn1="0" cnx1="0.00" cc011=" " cc051="     " cc101="          " cc201="                    " cc401="                                        " cc601="                                                            " clco_dto="      " clentr="                                                            " clt_dir="                                                            " clt_cuit="               " clre_ivap="0.00" clre_ivam="0.00" clpe_ibp="0.00" clpe_ibm="0.00" clogic="false" clretivac="  " clretganc="   " clretibrc="  " clretivav=" " clretganv=" " clretibrv=" " clemail="                                                            " clpageweb="                                                            " clprv="  " clcuoreal="0" clcobade="0" clperibru="X" cltope="0.00" clavanacum="0.00" clacumtot="0.00" clretsegv=" " clretsegc="  " clsitib="0" clnroib="0" regiibb="0.00" clmayde1="0.00" clmayde2="0.00" clpais="   " monex="0"/>
	<row clcod="F    " cltpo="7" clnom="FRANCES                                                     " cldir="                                                            " clloc="                                        " clcp="        " cliva="1" clcuit="               " cldto="0.00" clser="0" clser2="0" climpd="        " climpa="        " cltlf="                                                            " clmonto="0.00" cllist="0" clvcod="017  " clvdias="0" clvporj="0.00" clvcuotas="1" clvdiaini="0" clvdiapag="0" clvcodpag="F    " clcan4="1" clpun1="0.00" clpun2="0.00" clpun3="0.00" clpun4="0.00" clmon1="0.00" clmon2="0.00" clmon3="0.00" clmon4="0.00" clruta="    " clfax="                                                            " clcontac="                                                            " clobs="                                                                            " clvend="     " clprov="  " clngan="          " clfecha="    -  -  " clcfi="3" clacum="0.00" clfing="    -  -  " cd1="    -  -  " cl1="false" cn1="1" cnx1="0.00" cc011=" " cc051="     " cc101="          " cc201="                    " cc401="                                        " cc601="                                                            " clco_dto="      " clentr="                                                            " clt_dir="                                                            " clt_cuit="               " clre_ivap="0.00" clre_ivam="0.00" clpe_ibp="0.00" clpe_ibm="0.00" clogic="false" clretivac="  " clretganc="   " clretibrc="  " clretivav=" " clretganv=" " clretibrv=" " clemail="                                                            " clpageweb="                                                            " clprv="  " clcuoreal="1" clcobade="1" clperibru=" " cltope="0.00" clavanacum="0.00" clacumtot="0.00" clretsegv=" " clretsegc="  " clsitib="0" clnroib="0" regiibb="0.00" clmayde1="0.00" clmayde2="0.00" clpais="   " monex="0"/>
	<row clcod="PRE  " cltpo="7" clnom="PREPAGO                                                     " cldir="                                                            " clloc="                                        " clcp="        " cliva="1" clcuit="               " cldto="0.00" clser="0" clser2="0" climpd="        " climpa="        " cltlf="                                                            " clmonto="0.00" cllist="0" clvcod="     " clvdias="0" clvporj="0.00" clvcuotas="0" clvdiaini="30" clvdiapag="0" clvcodpag="     " clcan4="1" clpun1="0.00" clpun2="0.00" clpun3="0.00" clpun4="0.00" clmon1="0.00" clmon2="0.00" clmon3="0.00" clmon4="0.00" clruta="    " clfax="                                                            " clcontac="                                                            " clobs="                                                                            " clvend="     " clprov="  " clngan="          " clfecha="    -  -  " clcfi="5" clacum="0.00" clfing="    -  -  " cd1="    -  -  " cl1="false" cn1="0" cnx1="0.00" cc011=" " cc051="     " cc101="          " cc201="                    " cc401="                                        " cc601="                                                            " clco_dto="      " clentr="                                                            " clt_dir="                                                            " clt_cuit="               " clre_ivap="0.00" clre_ivam="0.00" clpe_ibp="0.00" clpe_ibm="0.00" clogic="false" clretivac="  " clretganc="   " clretibrc="  " clretivav=" " clretganv=" " clretibrv=" " clemail="                                                            " clpageweb="                                                            " clprv="  " clcuoreal="0" clcobade="0" clperibru=" " cltope="0.00" clavanacum="0.00" clacumtot="0.00" clretsegv=" " clretsegc="  " clsitib="0" clnroib="0" regiibb="0.00" clmayde1="0.00" clmayde2="0.00" clpais="   " monex="0"/>
</VFPData>
endtext
return lcXml
endfunc 

*-----------------------------------------------------------------------------------------
function ObtenerCursorFacturacionXLS() as String 
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
							<xsd:attribute name="fperson" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fart" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="16"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcant" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fprecio" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="grupo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="3"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="serie" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="indent" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="descrip" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fnped" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcae" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="20"/>
										<xsd:fractionDigits value="0"/>
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
	<row fperson="00004                                                       " fart="IT0069993       " fcant="1.00" fprecio="99.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20091023 S:103044 Art:BA                                                                                                                                                                                                                                 " fnped="                                                            " fcae=""/>
	<row fperson="00004                                                       " fart="IT0069994       " fcant="1.00" fprecio="54.00" grupo="1" serie="201111           " indent="0" descrip="FFac:20091023 S:103044 Art:TC                                                                                                                                                                                                                                 " fnped="                                                            " fcae=""/>
	<row fperson="00004                                                       " fart="IT0073075       " fcant="1.00" fprecio="99.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20100115 S:106714 Art:LBA                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="00004                                                       " fart="  TT  A201111   " fcant="1.00" fprecio="0.00" grupo="1" serie="0                   " indent="0" descrip="                                                                                                                                                                                                                                                              " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099006       " fcant="0.42" fprecio="26.50" grupo="1" serie="201110           " indent="0" descrip="FFac:20111019 S:103797 Art:LBN                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099009       " fcant="0.39" fprecio="22.00" grupo="1" serie="201110           " indent="0" descrip="FFac:20111020 S:103799 Art:LDP                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099012       " fcant="0.39" fprecio="22.00" grupo="1" serie="201110           " indent="0" descrip="FFac:20111020 S:103800 Art:LDP                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="  TT  A201110   " fcant="1.00" fprecio="0.00" grupo="1" serie="0                   " indent="0" descrip="                                                                                                                                                                                                                                                              " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099005       " fcant="1.00" fprecio="99.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20090129 S:103797 Art:LBA                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099006       " fcant="1.00" fprecio="26.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20111019 S:103797 Art:LBN                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099007       " fcant="1.00" fprecio="99.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20090129 S:103799 Art:LBA                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099008       " fcant="1.00" fprecio="26.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20090129 S:103799 Art:LBN                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099009       " fcant="1.00" fprecio="22.00" grupo="1" serie="201111           " indent="0" descrip="FFac:20111020 S:103799 Art:LDP                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099010       " fcant="1.00" fprecio="99.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20090129 S:103800 Art:LBA                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099011       " fcant="1.00" fprecio="26.50" grupo="1" serie="201111           " indent="0" descrip="FFac:20090129 S:103800 Art:LBN                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="IT0099012       " fcant="1.00" fprecio="22.00" grupo="1" serie="201111           " indent="0" descrip="FFac:20111020 S:103800 Art:LDP                                                                                                                                                                                                                                " fnped="                                                            " fcae=""/>
	<row fperson="09462                                                       " fart="  TT  A201111   " fcant="1.00" fprecio="0.00" grupo="1" serie="0                   " indent="0" descrip="                                                                                                                                                                                                                                                              " fnped="                                                            " fcae=""/>
</VFPData>
endtext
return lcXml
endfunc 

*-----------------------------------------------------------------------------------------
function DevolverFacm() as String 
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
							<xsd:attribute name="fnume" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fnped" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fndes" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcven" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fnrem" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fvto" type="xsd:date" use="required"/>
							<xsd:attribute name="fcorre" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcorretxt" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="30"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftrans" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fctecta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fvalend" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fexed" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fagrupy" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdto2por" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdto2mto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fentr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fndev" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcod_piva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpor_piva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimp_piva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcod_pgan" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpor_pgan" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimp_pgan" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcod_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpor_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimp_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext01" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext02" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext03" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext04" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext05" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext06" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext07" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext08" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext09" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext10" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext11" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext12" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext13" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext14" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext15" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext16" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext17" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext18" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext19" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescext20" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="160"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdto2grav1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdto2grav2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcae" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="20"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcoh1_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpoh1_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimh1_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcoh2_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpoh2_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimh2_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcoh3_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpoh3_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimh3_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcoh4_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpoh4_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimh4_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcoh5_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpoh5_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimh5_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcoh6_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpoh6_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fimh6_pibr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="incoterm" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ffvtocae" type="xsd:date" use="required"/>
						</xsd:complexType>
					</xsd:element>
				</xsd:choice>
				<xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax"/>
			</xsd:complexType>
		</xsd:element>
	</xsd:schema>
	<row fnume="113022377" fnped="                                                            " fndes="                                        " fcven="                                        " fnrem="                                                            " fvto="2011-11-18" fcorre="003  " fcorretxt="EJ MCAODURO                   " ftrans="                                                            " fctecta="0" fvalend="0" fexed="0" fagrupy="1" fdto2por="0" fdto2mto="0" fentr="CBU N§ 0720281288000035904768                               " fndev="                                                            " fcod_piva="  " fpor_piva="0" fimp_piva="0" fcod_pgan="  " fpor_pgan="0" fimp_pgan="0" fcod_pibr="  " fpor_pibr="0" fimp_pibr="0" fdescext01="                                                                                                                                                                " fdescext02="                                                                                                                                                                " fdescext03="                                                                                                                                                                " fdescext04="                                                                                                                                                                " fdescext05="                                                                                                                                                                " fdescext06="                                                                                                                                                                " fdescext07="                                                                                                                                                                " fdescext08="                                                                                                                                                                " fdescext09="                                                                                                                                                                " fdescext10="                                                                                                                                                                " fdescext11="                                                                                                                                                                " fdescext12="                                                                                                                                                                " fdescext13="                                                                                                                                                                " fdescext14="                                                                                                                                                                " fdescext15="                                                                                                                                                                " fdescext16="                                                                                                                                                                " fdescext17="                                                                                                                                                                " fdescext18="                                                                                                                                                                " fdescext19="                                                                                                                                                                " fdescext20="                                                                                                                                                                " fdto2grav1="0" fdto2grav2="0" fcae="0" fcoh1_pibr="  " fpoh1_pibr="0" fimh1_pibr="0" fcoh2_pibr="  " fpoh2_pibr="0" fimh2_pibr="0" fcoh3_pibr="  " fpoh3_pibr="0" fimh3_pibr="0" fcoh4_pibr="  " fpoh4_pibr="0" fimh4_pibr="0" fcoh5_pibr="  " fpoh5_pibr="0" fimh5_pibr="0" fcoh6_pibr="  " fpoh6_pibr="0" fimh6_pibr="0" incoterm="   " ffvtocae="    -  -  "/>
	<row fnume="114122364" fnped="                                                            " fndes="                                        " fcven="                                        " fnrem="                                                            " fvto="2011-11-18" fcorre="058  " fcorretxt="EJ DSUBIRON                   " ftrans="                                                            " fctecta="0" fvalend="0" fexed="0" fagrupy="1" fdto2por="0" fdto2mto="0" fentr="                                                            " fndev="                                                            " fcod_piva="  " fpor_piva="0" fimp_piva="0" fcod_pgan="  " fpor_pgan="0" fimp_pgan="0" fcod_pibr="  " fpor_pibr="0" fimp_pibr="0" fdescext01="                                                                                                                                                                " fdescext02="                                                                                                                                                                " fdescext03="                                                                                                                                                                " fdescext04="                                                                                                                                                                " fdescext05="                                                                                                                                                                " fdescext06="                                                                                                                                                                " fdescext07="                                                                                                                                                                " fdescext08="                                                                                                                                                                " fdescext09="                                                                                                                                                                " fdescext10="                                                                                                                                                                " fdescext11="                                                                                                                                                                " fdescext12="                                                                                                                                                                " fdescext13="                                                                                                                                                                " fdescext14="                                                                                                                                                                " fdescext15="                                                                                                                                                                " fdescext16="                                                                                                                                                                " fdescext17="                                                                                                                                                                " fdescext18="                                                                                                                                                                " fdescext19="                                                                                                                                                                " fdescext20="                                                                                                                                                                " fdto2grav1="0" fdto2grav2="0" fcae="0" fcoh1_pibr="  " fpoh1_pibr="0" fimh1_pibr="0" fcoh2_pibr="  " fpoh2_pibr="0" fimh2_pibr="0" fcoh3_pibr="  " fpoh3_pibr="0" fimh3_pibr="0" fcoh4_pibr="  " fpoh4_pibr="0" fimh4_pibr="0" fcoh5_pibr="  " fpoh5_pibr="0" fimh5_pibr="0" fcoh6_pibr="  " fpoh6_pibr="0" fimh6_pibr="0" incoterm="   " ffvtocae="    -  -  "/>
	<row fnume="313000646" fnped="                                                            " fndes="                                        " fcven="                                        " fnrem="                                                            " fvto="2011-11-18" fcorre="003  " fcorretxt="EJ MCAODURO                   " ftrans="                                                            " fctecta="0" fvalend="0" fexed="0" fagrupy="1" fdto2por="0" fdto2mto="0" fentr="CBU N§ 0720281288000035904768                               " fndev="                                                            " fcod_piva="  " fpor_piva="0" fimp_piva="0" fcod_pgan="  " fpor_pgan="0" fimp_pgan="0" fcod_pibr="  " fpor_pibr="0" fimp_pibr="0" fdescext01="                                                                                                                                                                " fdescext02="                                                                                                                                                                " fdescext03="                                                                                                                                                                " fdescext04="                                                                                                                                                                " fdescext05="                                                                                                                                                                " fdescext06="                                                                                                                                                                " fdescext07="                                                                                                                                                                " fdescext08="                                                                                                                                                                " fdescext09="                                                                                                                                                                " fdescext10="                                                                                                                                                                " fdescext11="                                                                                                                                                                " fdescext12="                                                                                                                                                                " fdescext13="                                                                                                                                                                " fdescext14="                                                                                                                                                                " fdescext15="                                                                                                                                                                " fdescext16="                                                                                                                                                                " fdescext17="                                                                                                                                                                " fdescext18="                                                                                                                                                                " fdescext19="                                                                                                                                                                " fdescext20="                                                                                                                                                                " fdto2grav1="0" fdto2grav2="0" fcae="0" fcoh1_pibr="  " fpoh1_pibr="0" fimh1_pibr="0" fcoh2_pibr="  " fpoh2_pibr="0" fimh2_pibr="0" fcoh3_pibr="  " fpoh3_pibr="0" fimh3_pibr="0" fcoh4_pibr="  " fpoh4_pibr="0" fimh4_pibr="0" fcoh5_pibr="  " fpoh5_pibr="0" fimh5_pibr="0" fcoh6_pibr="  " fpoh6_pibr="0" fimh6_pibr="0" incoterm="   " ffvtocae="    -  -  "/>
	<row fnume="314002215" fnped="                                                            " fndes="                                        " fcven="                                        " fnrem="                                                            " fvto="2011-11-18" fcorre="058  " fcorretxt="EJ DSUBIRON                   " ftrans="                                                            " fctecta="0" fvalend="0" fexed="0" fagrupy="1" fdto2por="0" fdto2mto="0" fentr="                                                            " fndev="                                                            " fcod_piva="  " fpor_piva="0" fimp_piva="0" fcod_pgan="  " fpor_pgan="0" fimp_pgan="0" fcod_pibr="  " fpor_pibr="0" fimp_pibr="0" fdescext01="                                                                                                                                                                " fdescext02="                                                                                                                                                                " fdescext03="                                                                                                                                                                " fdescext04="                                                                                                                                                                " fdescext05="                                                                                                                                                                " fdescext06="                                                                                                                                                                " fdescext07="                                                                                                                                                                " fdescext08="                                                                                                                                                                " fdescext09="                                                                                                                                                                " fdescext10="                                                                                                                                                                " fdescext11="                                                                                                                                                                " fdescext12="                                                                                                                                                                " fdescext13="                                                                                                                                                                " fdescext14="                                                                                                                                                                " fdescext15="                                                                                                                                                                " fdescext16="                                                                                                                                                                " fdescext17="                                                                                                                                                                " fdescext18="                                                                                                                                                                " fdescext19="                                                                                                                                                                " fdescext20="                                                                                                                                                                " fdto2grav1="0" fdto2grav2="0" fcae="0" fcoh1_pibr="  " fpoh1_pibr="0" fimh1_pibr="0" fcoh2_pibr="  " fpoh2_pibr="0" fimh2_pibr="0" fcoh3_pibr="  " fpoh3_pibr="0" fimh3_pibr="0" fcoh4_pibr="  " fpoh4_pibr="0" fimh4_pibr="0" fcoh5_pibr="  " fpoh5_pibr="0" fimh5_pibr="0" fcoh6_pibr="  " fpoh6_pibr="0" fimh6_pibr="0" incoterm="   " ffvtocae="    -  -  "/>
</VFPData>
endtext
return lcXml
endfunc 



*-----------------------------------------------------------------------------------------
function DevolverFac() as String
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
							<xsd:attribute name="fnum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fven" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ffch" type="xsd:date" use="required"/>
							<xsd:attribute name="fart" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="13"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcant" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fprun" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fneto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpesos" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fvuelto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fturno" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fhora" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="8"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="funid" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="4"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftxt" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftarjeta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcheques" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fobs" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fusd" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fusdpesos" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcotiz" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fccte" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcliente" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="30"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="facumula" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftac" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcfi" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fsmto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fsdias" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fsvto" type="xsd:date" use="required"/>
							<xsd:attribute name="fsret" type="xsd:date" use="required"/>
							<xsd:attribute name="fsepos" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fsena" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fperson" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcolo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcotxt" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftall" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fsubtot" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcfitot" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="flista" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpedido" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fremito" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fpodes" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdescu" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftotal" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftactot" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fiva1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fiva2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fxiva1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fxiva2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fx1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fx2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fx3" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fx4" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fx5" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fd1" type="xsd:date" use="required"/>
							<xsd:attribute name="fd2" type="xsd:date" use="required"/>
							<xsd:attribute name="ft051" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ft101" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ft401" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ft402" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fl1" type="xsd:boolean" use="required"/>
							<xsd:attribute name="fmayomin" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fc2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fn11" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftipo" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fco_dto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="6"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="famate" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fstockcomb" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fstockarti" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcompfis" type="xsd:boolean" use="required"/>
							<xsd:attribute name="fnrocaja" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fxivaart" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fgraviva1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fgraviva2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdsctgrav1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fdsctgrav2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftactgrav1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ftactgrav2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fkit" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fmonto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fmotdev" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fmotdescli" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fmotdescto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="fcai" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="14"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="frectarj" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="frecgrav1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="frecgrav2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
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
	<row fnum="113022377" fven="ZOO  " ffch="2011-11-18" fart="IT0069993    " fcant="1.00" fprun="120.40" fneto="120.40" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20091023 S:103044 Art:BA           " ftarjeta="306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="306.13" ftactot="0" fiva1="53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="1    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="113022377" fven="ZOO  " ffch="2011-11-18" fart="IT0069994    " fcant="1.00" fprun="65.34" fneto="65.34" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20091023 S:103044 Art:TC           " ftarjeta="306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="306.13" ftactot="0" fiva1="53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="2    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="113022377" fven="ZOO  " ffch="2011-11-18" fart="IT0073075    " fcant="1.00" fprun="120.40" fneto="120.40" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20100115 S:106714 Art:LBA          " ftarjeta="306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="306.13" ftactot="0" fiva1="53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="3    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="113022377" fven="ZOO  " ffch="2011-11-18" fart="  TT  A201111" fcant="1.00" fprun="0.00" fneto="0.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="Abono mensual software Zoo Logic 11/2011" ftarjeta="306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="0                   " ftall="   " fsubtot="306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="306.13" ftactot="0" fiva1="53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="4    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099006    " fcant="0.42" fprun="26.50" fneto="11.13" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111019 S:103797 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201110           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="1    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099009    " fcant="0.39" fprun="22.00" fneto="8.58" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103799 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201110           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="2    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099012    " fcant="0.39" fprun="22.00" fneto="8.58" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103800 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201110           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="3    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="  TT  A201110" fcant="1.00" fprun="0.00" fneto="0.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="Abono mensual software Zoo Logic 10/2011" ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="0                   " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="4    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099005    " fcant="1.00" fprun="99.50" fneto="99.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103797 Art:LBA          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="5    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099006    " fcant="1.00" fprun="26.50" fneto="26.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111019 S:103797 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="6    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099007    " fcant="1.00" fprun="99.50" fneto="99.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103799 Art:LBA          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="7    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099008    " fcant="1.00" fprun="26.50" fneto="26.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103799 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="8    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099009    " fcant="1.00" fprun="22.00" fneto="22.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103799 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="9    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099010    " fcant="1.00" fprun="99.50" fneto="99.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103800 Art:LBA          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="10   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099011    " fcant="1.00" fprun="26.50" fneto="26.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103800 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="11   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="IT0099012    " fcant="1.00" fprun="22.00" fneto="22.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103800 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="12   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="114122364" fven="ZOO  " ffch="2011-11-18" fart="  TT  A201111" fcant="1.00" fprun="0.00" fneto="0.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="Abono mensual software Zoo Logic 11/2011" ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="544.85" fcliente="BATATALANDIA SA               " facumula="544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="0                   " ftall="   " fsubtot="450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="544.85" ftactot="0" fiva1="94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="13   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="313000646" fven="ZOO  " ffch="2011-11-18" fart="IT0069993    " fcant="-1.00" fprun="-81.38" fneto="-81.38" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20091023 S:103044 Art:BA           " ftarjeta="-306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="-306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-306.13" ftactot="0" fiva1="-53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="1    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="313000646" fven="ZOO  " ffch="2011-11-18" fart="IT0069994    " fcant="-1.00" fprun="-79.06" fneto="-79.06" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20091023 S:103044 Art:TC           " ftarjeta="-306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="-306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-306.13" ftactot="0" fiva1="-53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="2    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="313000646" fven="ZOO  " ffch="2011-11-18" fart="IT0073075    " fcant="-1.00" fprun="-145.68" fneto="-145.68" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20100115 S:106714 Art:LBA          " ftarjeta="-306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="-306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-306.13" ftactot="0" fiva1="-53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="3    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="313000646" fven="ZOO  " ffch="2011-11-18" fart="  TT  A201111" fcant="-1.00" fprun="0.00" fneto="0.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="Abono mensual software Zoo Logic 11/2011" ftarjeta="-306.13" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="0.00" fcliente="GODOY MARIA PAULA             " facumula="-306.13" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="00004" fcolo="  " fcotxt="                    " ftall="   " fsubtot="-306.13" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-306.13" ftactot="0" fiva1="-53.13" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="4    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-253.00" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099006    " fcant="-0.42" fprun="-26.50" fneto="-11.13" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111019 S:103797 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201110           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="1    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099009    " fcant="-0.39" fprun="-22.00" fneto="-8.58" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103799 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201110           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="2    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099012    " fcant="-0.39" fprun="-22.00" fneto="-8.58" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103800 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201110           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="3    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="  TT  A201110" fcant="-1.00" fprun="0.00" fneto="0.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="Abono mensual software Zoo Logic 10/2011" ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="                    " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="4    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099005    " fcant="-1.00" fprun="-99.50" fneto="-99.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103797 Art:LBA          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="5    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099006    " fcant="-1.00" fprun="-26.50" fneto="-26.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111019 S:103797 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="6    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099007    " fcant="-1.00" fprun="-99.50" fneto="-99.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103799 Art:LBA          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="7    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099008    " fcant="-1.00" fprun="-26.50" fneto="-26.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103799 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="8    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099009    " fcant="-1.00" fprun="-22.00" fneto="-22.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103799 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="9    " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099010    " fcant="-1.00" fprun="-99.50" fneto="-99.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103800 Art:LBA          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="10   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099011    " fcant="-1.00" fprun="-26.50" fneto="-26.50" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20090129 S:103800 Art:LBN          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="11   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="IT0099012    " fcant="-1.00" fprun="-22.00" fneto="-22.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="FFac:20111020 S:103800 Art:LDP          " ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="201111           " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="12   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
	<row fnum="314002215" fven="ZOO  " ffch="2011-11-18" fart="  TT  A201111" fcant="-1.00" fprun="0.00" fneto="0.00" fpesos="0" fvuelto="0" fturno="1" fhora="11:03:28" funid="    " ftxt="Abono mensual software Zoo Logic 11/2011" ftarjeta="0.00" fcheques="0" fobs="                                        " fusd="0" fusdpesos="0" fcotiz="1.00" fccte="-544.85" fcliente="BATATALANDIA SA               " facumula="-544.85" ftac="0" fcfi="0" fsmto="0" fsdias="0" fsvto="    -  -  " fsret="    -  -  " fsepos="0" fsena="0" fperson="09462" fcolo="  " fcotxt="                    " ftall="   " fsubtot="-450.29" fcfitot="0" flista="3" fpedido="0" fremito="0" fpodes="0" fdescu="0" ftotal="-544.85" ftactot="0" fiva1="-94.56" fiva2="0" fxiva1="21.00" fxiva2="0" fx1="0" fx2="0" fx3="0" fx4="0" fx5="0" fd1="    -  -  " fd2="2011-11-18" ft051="13   " ft101="          " ft401="                                        " ft402="                                        " fl1="false" fmayomin="M" fc2=" " fn11="2" ftipo="1" fco_dto="      " famate="          " fstockcomb="0" fstockarti="0" fcompfis="true" fnrocaja="0" fxivaart="21.00" fgraviva1="-450.29" fgraviva2="0" fdsctgrav1="0" fdsctgrav2="0" ftactgrav1="0" ftactgrav2="0" fkit="0" fmonto="0" fmotdev="   " fmotdescli="   " fmotdescto="   " fcai="0" frectarj="0" frecgrav1="0" frecgrav2="0"/>
</VFPData>
endtext
return lcXml
endfunc 


*-----------------------------------------------------------------------------------------
function DevolverVal() as String 
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
							<xsd:attribute name="jjnum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjt" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjco" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjfe" type="xsd:date" use="required"/>
							<xsd:attribute name="jjde" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="25"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjnu" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjm" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcli" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjfecha" type="xsd:date" use="required"/>
							<xsd:attribute name="jjven" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjtotfac" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjbjnum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjbjfch" type="xsd:date" use="required"/>
							<xsd:attribute name="jjbjcli" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjobs" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjturno" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jj101" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jj401" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcuotas" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjdias" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcuotot" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjacnum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjacfcup" type="xsd:date" use="required"/>
							<xsd:attribute name="jjaccod" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjtarje" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcorre" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjhabil" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcompfis" type="xsd:boolean" use="required"/>
							<xsd:attribute name="jjcielote" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjnrcaja" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjrechaz" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcotiz" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjentfin" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjcuitlib" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="15"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjmtorec" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjxrec" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="jjmtoreimp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
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
	<row jjnum="113022377" jjt="3" jjco="F    " jjfe="2011-11-18" jjde="00004   TT  M1111        " jjnu="102" jjm="306.13" jjcli="00004" jjfecha="2011-11-18" jjven="ZOO  " jjtotfac="306.13" jjbjnum="800000001" jjbjfch="2011-11-18" jjbjcli="00004" jjobs="                                        " jjturno="1" jj101="          " jj401="                                        " jjcuotas="0" jjdias="0" jjcuotot="0" jjacnum="0" jjacfcup="    -  -  " jjaccod="     " jjtarje="     " jjcorre="003  " jjhabil="0" jjcompfis="false" jjcielote="0" jjnrcaja="0" jjrechaz="0" jjcotiz="1.00" jjentfin="     " jjcuitlib="               " jjmtorec="0" jjxrec="0" jjmtoreimp="0"/>
	<row jjnum="114122364" jjt="5" jjco="PRE  " jjfe="2011-11-18" jjde="09462   TT  M1111        " jjnu="103" jjm="544.85" jjcli="09462" jjfecha="2011-11-18" jjven="ZOO  " jjtotfac="544.85" jjbjnum="0" jjbjfch="    -  -  " jjbjcli="     " jjobs="                                        " jjturno="1" jj101="          " jj401="                                        " jjcuotas="0" jjdias="0" jjcuotot="0" jjacnum="0" jjacfcup="    -  -  " jjaccod="     " jjtarje="     " jjcorre="058  " jjhabil="0" jjcompfis="false" jjcielote="0" jjnrcaja="0" jjrechaz="0" jjcotiz="1.00" jjentfin="     " jjcuitlib="               " jjmtorec="0" jjxrec="0" jjmtoreimp="0"/>
	<row jjnum="313000646" jjt="3" jjco="TJAJU" jjfe="2011-11-18" jjde="00004   TT  M1111        " jjnu="104" jjm="-306.13" jjcli="00004" jjfecha="2011-11-18" jjven="ZOO  " jjtotfac="-306.13" jjbjnum="800000001" jjbjfch="2011-11-18" jjbjcli="00004" jjobs="                                        " jjturno="1" jj101="          " jj401="                                        " jjcuotas="0" jjdias="0" jjcuotot="0" jjacnum="0" jjacfcup="    -  -  " jjaccod="     " jjtarje="     " jjcorre="003  " jjhabil="0" jjcompfis="false" jjcielote="0" jjnrcaja="0" jjrechaz="0" jjcotiz="1.00" jjentfin="     " jjcuitlib="               " jjmtorec="0" jjxrec="0" jjmtoreimp="0"/>
	<row jjnum="800000001" jjt="1" jjco="AJ   " jjfe="2011-11-18" jjde="AJUSTE PES               " jjnu="0" jjm="0.01" jjcli="00004" jjfecha="2011-11-18" jjven="ZOO  " jjtotfac="0.01" jjbjnum="0" jjbjfch="    -  -  " jjbjcli="     " jjobs="                                        " jjturno="1" jj101="          " jj401="                                        " jjcuotas="0" jjdias="0" jjcuotot="0" jjacnum="0" jjacfcup="    -  -  " jjaccod="     " jjtarje="     " jjcorre="     " jjhabil="0" jjcompfis="false" jjcielote="0" jjnrcaja="0" jjrechaz="0" jjcotiz="1.00" jjentfin="     " jjcuitlib="               " jjmtorec="0" jjxrec="0" jjmtoreimp="0"/>
	<row jjnum="800000001" jjt="1" jjco="AJ   " jjfe="2011-11-18" jjde="AJUSTE PES               " jjnu="0" jjm="-0.01" jjcli="00004" jjfecha="2011-11-18" jjven="ZOO  " jjtotfac="0.01" jjbjnum="0" jjbjfch="    -  -  " jjbjcli="     " jjobs="                                        " jjturno="1" jj101="          " jj401="                                        " jjcuotas="0" jjdias="0" jjcuotot="0" jjacnum="0" jjacfcup="    -  -  " jjaccod="     " jjtarje="     " jjcorre="     " jjhabil="0" jjcompfis="false" jjcielote="0" jjnrcaja="0" jjrechaz="0" jjcotiz="1.00" jjentfin="     " jjcuitlib="               " jjmtorec="0" jjxrec="0" jjmtoreimp="0"/>
	<row jjnum="314002215" jjt="5" jjco="CCAJU" jjfe="2011-11-18" jjde="09462   TT  M1111        " jjnu="105" jjm="-544.85" jjcli="09462" jjfecha="2011-11-18" jjven="ZOO  " jjtotfac="-544.85" jjbjnum="0" jjbjfch="    -  -  " jjbjcli="     " jjobs="                                        " jjturno="1" jj101="          " jj401="                                        " jjcuotas="0" jjdias="0" jjcuotot="0" jjacnum="0" jjacfcup="    -  -  " jjaccod="     " jjtarje="     " jjcorre="058  " jjhabil="0" jjcompfis="false" jjcielote="0" jjnrcaja="0" jjrechaz="0" jjcotiz="1.00" jjentfin="     " jjcuitlib="               " jjmtorec="0" jjxrec="0" jjmtoreimp="0"/>
</VFPData>
endtext
return lcXml
endfunc

*-----------------------------------------------------------------------------------------
function DevolverCtb() as String 
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
							<xsd:attribute name="cnum" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cven" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccue" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cfch" type="xsd:date" use="required"/>
							<xsd:attribute name="cvto" type="xsd:date" use="required"/>
							<xsd:attribute name="cpar" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cm1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cm2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cs1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cs2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ctxto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="60"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cseq" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cref" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cusu" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="1"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ctotal" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="civa1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="civa2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cxiva1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cxiva2" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="7"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cefec" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cdolares" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ctarjeta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccheque" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccte" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccambio" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cvuelto" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cobs" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="csh1" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cpodes" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="5"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cdescu" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="15"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ct101" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="10"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ct401" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="40"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccorre" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="criva_nco" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="crgan_nco" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cribr_nco" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="criva_imp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="crgan_imp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cribr_imp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccompfis" type="xsd:boolean" use="required"/>
							<xsd:attribute name="cnrtalon" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cnrfiscal" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cnrocaja" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="civadist" type="xsd:boolean" use="required"/>
							<xsd:attribute name="cporciva" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="9"/>
										<xsd:fractionDigits value="4"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ctipcompr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cptovta" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cnrocompr" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="8"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="ccontfisca" type="xsd:boolean" use="required"/>
							<xsd:attribute name="cnrocai" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="14"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cvtocai" type="xsd:date" use="required"/>
							<xsd:attribute name="ccanthojas" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="3"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="crseg_nco" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="10"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="crseg_imp" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="11"/>
										<xsd:fractionDigits value="2"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cib_juri" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="3"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cib_suc" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="4"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cib_fech" type="xsd:date" use="required"/>
							<xsd:attribute name="cib_nrco" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="16"/>
										<xsd:fractionDigits value="0"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="cturno" use="required">
								<xsd:simpleType>
									<xsd:restriction base="xsd:decimal">
										<xsd:totalDigits value="1"/>
										<xsd:fractionDigits value="0"/>
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
	<row cnum="114122364" cven="ZOO  " ccue="09462" cfch="2011-11-18" cvto="2011-11-18" cpar="1.00" cm1="544.85" cm2="544.85" cs1="0.00" cs2="0.00" ctxto="Factura Nr. A 0003-00122364                                 " cseq="79" cref="0" cusu=" " ctotal="544.85" civa1="94.56" civa2="0.00" cxiva1="21.00" cxiva2="0.00" cefec="0.00" cdolares="0.00" ctarjeta="0.00" ccheque="0.00" ccte="544.85" ccambio="0.00" cvuelto="0.00" cobs="                                        " csh1="0.00" cpodes="0.00" cdescu="0.00" ct101="          " ct401="                                        " ccorre="058  " criva_nco="0" crgan_nco="0" cribr_nco="0" criva_imp="0.00" crgan_imp="0.00" cribr_imp="0.00" ccompfis="false" cnrtalon="0" cnrfiscal="0" cnrocaja="0" civadist="false" cporciva="17.3552" ctipcompr="  " cptovta="0" cnrocompr="0" ccontfisca="false" cnrocai="0" cvtocai="    -  -  " ccanthojas="0" crseg_nco="0" crseg_imp="0.00" cib_juri="   " cib_suc="0" cib_fech="    -  -  " cib_nrco="0" cturno="0"/>
	<row cnum="314002215" cven="ZOO  " ccue="09462" cfch="2011-11-18" cvto="2011-11-18" cpar="1.00" cm1="-544.85" cm2="-544.85" cs1="0.00" cs2="0.00" ctxto="N.Cr‚d. Nr. A 0003-00002215                                 " cseq="80" cref="0" cusu=" " ctotal="-544.85" civa1="-94.56" civa2="0.00" cxiva1="21.00" cxiva2="0.00" cefec="0.00" cdolares="0.00" ctarjeta="0.00" ccheque="0.00" ccte="-544.85" ccambio="0.00" cvuelto="0.00" cobs="                                        " csh1="0.00" cpodes="0.00" cdescu="0.00" ct101="          " ct401="                                        " ccorre="058  " criva_nco="0" crgan_nco="0" cribr_nco="0" criva_imp="0.00" crgan_imp="0.00" cribr_imp="0.00" ccompfis="false" cnrtalon="0" cnrfiscal="0" cnrocaja="0" civadist="false" cporciva="17.3552" ctipcompr="  " cptovta="0" cnrocompr="0" ccontfisca="false" cnrocai="0" cvtocai="    -  -  " ccanthojas="0" crseg_nco="0" crseg_imp="0.00" cib_juri="   " cib_suc="0" cib_fech="    -  -  " cib_nrco="0" cturno="0"/>
	<row cnum="201000013" cven="ZOO  " ccue="09462" cfch="2011-11-18" cvto="2011-11-18" cpar="1.00" cm1="-544.85" cm2="-544.85" cs1="0.00" cs2="0.00" ctxto="Rec X 0001-01000013 Factura Nr. A 0003-00122364             " cseq="81" cref="79" cusu=" " ctotal="0.00" civa1="0" civa2="0" cxiva1="0" cxiva2="0" cefec="0" cdolares="0" ctarjeta="0" ccheque="0.00" ccte="0" ccambio="0" cvuelto="0" cobs="                                        " csh1="-544.85" cpodes="0" cdescu="0" ct101="          " ct401="                                        " ccorre="     " criva_nco="0" crgan_nco="0" cribr_nco="0" criva_imp="0" crgan_imp="0" cribr_imp="0" ccompfis="false" cnrtalon="0" cnrfiscal="0" cnrocaja="0" civadist="false" cporciva="0" ctipcompr="  " cptovta="0" cnrocompr="0" ccontfisca="false" cnrocai="0" cvtocai="    -  -  " ccanthojas="0" crseg_nco="0" crseg_imp="0" cib_juri="   " cib_suc="0" cib_fech="    -  -  " cib_nrco="0" cturno="1"/>
	<row cnum="201000013" cven="ZOO  " ccue="09462" cfch="2011-11-18" cvto="2011-11-18" cpar="1.00" cm1="544.85" cm2="544.85" cs1="0.00" cs2="0.00" ctxto="Rec X 0001-01000013 N.Cr‚d. Nr. A 0003-00002215             " cseq="82" cref="80" cusu=" " ctotal="0.00" civa1="0" civa2="0" cxiva1="0" cxiva2="0" cefec="0" cdolares="0" ctarjeta="0" ccheque="0.00" ccte="0" ccambio="0" cvuelto="0" cobs="                                        " csh1="544.85" cpodes="0" cdescu="0" ct101="          " ct401="                                        " ccorre="     " criva_nco="0" crgan_nco="0" cribr_nco="0" criva_imp="0" crgan_imp="0" cribr_imp="0" ccompfis="false" cnrtalon="0" cnrfiscal="0" cnrocaja="0" civadist="false" cporciva="0" ctipcompr="  " cptovta="0" cnrocompr="0" ccontfisca="false" cnrocai="0" cvtocai="    -  -  " ccanthojas="0" crseg_nco="0" crseg_imp="0" cib_juri="   " cib_suc="0" cib_fech="    -  -  " cib_nrco="0" cturno="1"/>
</VFPData>
endtext
return lcXml
endfunc

***********************************************************************************************
define class Mock_LibreriasTest as Librerias of Librerias.Prg

	*-----------------------------------------------------------------------------------------
	function ObtenerFecha() as date 
		return ctod( "18/11/2011" )		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Obtenerhora() as string 
		return "11:03:28"
	endfunc 

enddefine
