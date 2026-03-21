define class ztestBuzon as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as ztestBuzon of ztestBuzon.prg
	#endif
	
	*-----------------------------------------------------------------------------------------
	function zTestReasignarUnidadYRuta_DireccionRed
		local loBuzon as ent_buzon of Ent_Buzon.prg
		
		_screen.Mocks.AgregarMock( "Colaboradorrutasbuzon" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Armarrutabuzon", "\\test\C$\prueba\Directorio\de\Prueba\", "[D:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Extraerunidad", "", "[\\test\C$\prueba\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Extraerruta", "\\test\C$\prueba\Directorio\de\Prueba\", "[\\test\C$\prueba\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Validardirectorio", .t., "[*OBJETO]" )
		
		loBuzon = _Screen.zoo.instanciarEntidad( "Buzon" )
		with loBuzon
			try
				.Codigo = "BUZTEST"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "BUZTEST"
			
			.Directorio = "D:\Directorio\de\Prueba"
			this.AssertEquals( "Unidad incorrecta.", "", .HUnid )
			this.AssertEquals( "Ruta incorrecta.", "\\test\C$\prueba\Directorio\de\Prueba\", .HPath )
			
			.Serie = 123456
			.Grabar()
			.Codigo = "BUZTEST"
			this.AssertEquals( "Directorio incorrecto.", "\\test\C$\prueba\Directorio\de\Prueba\", .Directorio )
			
			.Eliminar()
			.release()
		endwith
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutasbuzon" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestReasignarUnidadYRuta_DireccionLocal
		local loBuzon as ent_buzon of Ent_Buzon.prg
		
		_screen.Mocks.AgregarMock( "Colaboradorrutasbuzon" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Armarrutabuzon", "C:\Directorio\de\Prueba\", "[C:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Extraerunidad", "C", "[C:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Extraerruta", "\Directorio\de\Prueba\", "[C:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Validardirectorio", .t., "[*OBJETO]" )
		
		loBuzon = _screen.Zoo.InstanciarEntidad( "Buzon" )
		with loBuzon
			try
				.Codigo = "BUZTEST"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "BUZTEST"
			
			.Directorio = "C:\Directorio\de\Prueba"
			this.AssertEquals( "Unidad incorrecta.", "C", .HUnid )
			this.AssertEquals( "Ruta incorrecta.", "\Directorio\de\Prueba\", .HPath )
			
			.Serie = 123456
			.Grabar()
			.Codigo = "BUZTEST"
			this.AssertEquals( "Directorio incorrecto.", "C:\Directorio\de\Prueba\", .Directorio )
			
			.Eliminar()
			.release()
		endwith
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutasbuzon" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarIncorrecto
		local loBuzon as ent_buzon of Ent_Buzon.prg
		
		_screen.Mocks.AgregarMock( "Colaboradorrutasbuzon" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Armarrutabuzon", "H:\Directorio\de\Prueba\", "[H:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Extraerunidad", "H", "[H:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Extraerruta", "\Directorio\de\Prueba\", "[H:\Directorio\de\Prueba\]" )
		_screen.Mocks.AgregarSeteoMetodo( "Colaboradorrutasbuzon", "Validardirectorio", .f., "[*OBJETO]" )
		
		loBuzon = _screen.Zoo.InstanciarEntidad( "Buzon" )
		with loBuzon
			try
				.Codigo = "BUZTEST"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "BUZTEST"
			.Directorio = "H:\Directorio\de\Prueba"
			.Serie = 123456
			
			this.AssertTrue( "Directorio incorrecto.", !.Validar() )
			
			.Eliminar()
			.release()
		endwith
		
		_screen.Mocks.VerificarEjecucionDeMocks( "Colaboradorrutasbuzon" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestBuzonEsFranquicia
		local loBuzon as object
		
		_screen.mocks.agregarmock( "Buzonad_sqlserver" )
		_screen.mocks.Agregarseteometodo( 'Buzonad_sqlserver', 'Inyectarentidad', .t., "'*OBJETO'" )
		_screen.mocks.Agregarseteometodo( 'Buzonad_sqlserver', 'Obtenerdatosentidad', ObtenerXml_ConDatos(), "[Codigo],[HSERIE = 654321 and COMPORT = 2],.F.,.F.,.F." )
		
		loBuzon = _screen.zoo.instanciarentidad ("buzon")
		
		this.AssertTrue("El serie debería ser franquicia.", loBuzon.esSeriefranquicia(654321))
		
		loBuzon.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestBuzonNoEsFranquicia
		local loBuzon as object
		
		_screen.mocks.agregarmock( "Buzonad_sqlserver" )
		_screen.mocks.Agregarseteometodo( 'Buzonad_sqlserver', 'Inyectarentidad', .t., "'*OBJETO'" )
		_screen.mocks.Agregarseteometodo( 'Buzonad_sqlserver', 'Obtenerdatosentidad', ObtenerXml_SinDatos(), "[Codigo],[HSERIE = 654321 and COMPORT = 2],.F.,.F.,.F." )
		
		loBuzon = _screen.zoo.instanciarentidad ("buzon")
		
		this.AssertTrue("El serie NO debería ser franquicia.", !loBuzon.esSeriefranquicia(654321))
		
		loBuzon.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestCompletarItemTransferencia
		local loItemTransferencia as Object, loBuzon as Object, lcXml as String, lcRutaTemporal as String
		
		lcRutaTemporal = _screen.zoo.obtenerrutatemporal()
		
		this.AgregarMocks( "Cliente" )

		loBuzon = _screen.zoo.InstanciarEntidad( "Buzon" )
		with loBuzon	
			try
				.Codigo = "BZTEST"
				.eliminar()
			catch
			finally 
				.nuevo()		
				.Codigo = "BZTEST"
				.Directorio = _screen.zoo.obtenerrutatemporal()
				.serie = 123456
				.Cliente_pk = "CLI1"
				.lHabilitarEsBuzonLince = .t.
				.EsBuzonLince = .t.
				.grabar()
			endtry
		
			loItem = _screen.zoo.crearObjeto( "ItemFiltroTransferencia" )	
			.CompletarItemTransferencia( "Cliente", "CLI1", .t., loItem )
			this.AssertEquals( "El buzón no es correcto", "BZTEST", alltrim( loItem.cBuzon ) )
			this.AssertEquals( "El destino del buzón no es correcto", lcRutaTemporal + "BZTEST\Envia", loItem.cBuzonDestino )
			this.AssertTrue( "La base de datos debe estar vacía", empty( loItem.cBaseDeDatos ) )
			this.AssertTrue( "Es buzón lince deberia ser .t.", loItem.lEsBuzonLince )
			
			try
				.Codigo = "BZTEST"
				.eliminar()
			catch
			finally 
				.nuevo()		
				.Codigo = "BZTEST"
				.Directorio = _screen.zoo.obtenerrutatemporal()
				.serie = 123456
				.Cliente_pk = "CLI1"
				.BaseDeDatos = "BDTEST"
				.grabar()
			endtry
			
			loItem = _screen.zoo.crearObjeto( "ItemFiltroTransferencia" )	
			.CompletarItemTransferencia( "Cliente", "CLI1", .f., loItem )
			this.AssertEquals( "La base de datos no es correcta", "BDTEST", alltrim( loItem.cBaseDeDatos ) )
			this.AssertTrue( "El buzón debe estar vacío", empty( loItem.cBuzon ) )
			this.AssertTrue( "El destino del buzón debe estar vacío", empty( loItem.cBuzonDestino ) )
			this.AssertTrue( "Es buzón lince deberia ser .f.", !loItem.lEsBuzonLince )
			
			.release()
		endwith
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_SetearBaseDeDatos
		local loBuzon as Object
		this.AgregarMocks( "ORIGENDEDATOS,BASEDEDATOS" )
		_screen.mocks.AgregarSeteoPropiedad( "BaseDeDatos", "OrigenDestino_pk", "DEST" )
		loBuzon = _screen.zoo.Instanciarentidad( "Buzon" )
		with loBuzon
			.Nuevo()
			this.AssertTrue( "1. EsBuzonLince debería estar habilitado", .lHabilitarEsBuzonLince )
			this.AssertTrue( "2. Destino debería estar habilitado", .lHabilitarOrigenDeDatos_pk )
			
			.EsBuzonLince = .t.
			.BaseDeDatos = "ALGO"
			this.AssertTrue( "3. EsBuzonLince no debería estar habilitado", !.lHabilitarEsBuzonLince )
			this.AssertTrue( "4. EsBuzonLince no debería estar en falso", !.EsBuzonLince )			
			this.AssertTrue( "5. Destino no debería estar habilitado", !.lHabilitarOrigenDeDatos_pk )
			this.AssertEquals( "6. El Destino no es correcto", "DEST", alltrim( .OrigenDeDatos_pk ) )
			.BaseDeDatos = ""
			this.AssertTrue( "7. EsBuzonLince debería estar habilitado", .lHabilitarEsBuzonLince )
			this.AssertTrue( "8. Destino debería estar habilitado", .lHabilitarOrigenDeDatos_pk )
			.Release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSerieSegunComportamientoFranquicia
		local loBuzon as Object, loInformacion as Object		
		loBuzon = _screen.zoo.Instanciarentidad( "Buzon" )
		with loBuzon
			.Nuevo()
			.Comportamiento = 2
			this.AssertTrue( "La validación debería ser .f.", !.ValidarSerieSegunComportamientoFranquicia() )
			loInformacion = .ObtenerInformacion()
			this.AssertEquals( "El mensaje de error no es correcto", loInformacion.item(1).cMensaje, "Debe cargar el campo Serie, necesario para el circuito de franquicias." )
			.Serie = 123
			this.AssertTrue( "La validación debería ser .t.", .ValidarSerieSegunComportamientoFranquicia() )
			.Release()
		endwith
	endfunc 

	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
function ObtenerXml_SinDatos()
	local lcXML as String
	
	text to lcXML textmerge pretext 1 + 2 + 4 + 8 noshow
		<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
		<VFPData xml:space="preserve">
			<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
				<xsd:element name="VFPData" msdata:IsDataSet="true">
					<xsd:complexType>
						<xsd:choice maxOccurs="unbounded">
							<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
								<xsd:complexType>
									<xsd:attribute name="codigo" use="required">
										<xsd:simpleType>
											<xsd:restriction base="xsd:string">
												<xsd:maxLength value="8"/>
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

	return lcXML
endfunc

*-----------------------------------------------------------------------------------------
function ObtenerXml_ConDatos()
	local lcXML as String
	
	text to lcXML textmerge pretext 1 + 2 + 4 + 8 noshow
		<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
			<VFPData xml:space="preserve">
				<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
					<xsd:element name="VFPData" msdata:IsDataSet="true">
						<xsd:complexType>
							<xsd:choice maxOccurs="unbounded">
								<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
									<xsd:complexType>
										<xsd:attribute name="codigo" use="required">
											<xsd:simpleType>
												<xsd:restriction base="xsd:string">
													<xsd:maxLength value="8"/>
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
				<row codigo="BUZON2  "/>
			</VFPData>

	endtext

	return lcXML
endfunc