**********************************************************************
DEFINE CLASS zTestGestorDeMail as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestGestorDeMail OF zTestGestorDeMail.PRG
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function zTestEnvioDeMailDePrueba
		local loGestor as GestorDeMail of GestorDeMail.prg, loEntidad as entidad OF entidad.prg
		
		loFactory = _screen.zoo.crearobjeto( "ZoologicSA.Mail.MailFactory" )
		loConfiguracion = loFactory.ObtenerConfiguracion
		_screen.mocks.agregarmock( "CuentaCorreo" )
		_screen.mocks.agregarmock( "ConfiguradorDeMail" )
		_screen.mocks.agregarmock( "EnviadorDeMail" )		
		
		_screen.mocks.AgregarSeteoMetodo( 'ENVIADORDEMAIL', 'Obtenerconfiguracion', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'ENVIADORDEMAIL', 'Enviarmail', .T., "'*OBJETO',.T." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURADORDEMAIL', 'Obtenerconfiguracionsegunentidad', loConfiguracion , "'*OBJETO'" )
		loGestor = _screen.zoo.crearobjeto( "GestorDeMail" )
		loEntidad = _screen.zoo.instanciarentidad( "CuentaCorreo" )

		loGestor.EnviarMailPrueba( loEntidad )
		
		_Screen.mocks.verificarejecuciondemocks( "ENVIADORDEMAIL" )

		loGestor.Release()		
		loEntidad.Release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerXmlDisenosCumplenCondicion
		local loDisenios as Object, loEntidad as Object, loGestor as Object, lcXml as String, loItemDisenio as Object, loDiseniosFiltrados as Object
		local lcValorXml
		
		lcValorXml = ObtenerXml_DiseniosEmailTest()
		loColeccionInfo = _screen.zoo.crearobjeto( "ZooInformacion" )
		this.AgregarMocks( "CANADA,EMAIL,EMAILAD_SQLSERVER" )
		_screen.mocks.AgregarSeteoPropiedad( 'CANADA', 'LETRA', 'B' )
		_screen.mocks.AgregarSeteoPropiedad( 'CANADA', 'Numero', 5000 )
		_screen.mocks.AgregarSeteoPropiedad( 'CANADA', 'Descripcion', '' )
		_screen.mocks.AgregarSeteoMetodo( 'CANADA', 'Obtenerinformacion', loColeccionInfo ) && ztestgestordemail.ztestu_obtenerxmldisenoscumplencondicion 22/12/20 18:32:37
		_screen.mocks.AgregarSeteoMetodo( 'CANADA', 'Agregarinformacion', .T., "[*COMODIN]" ) && ztestgestordemail.ztestu_obtenerxmldisenoscumplencondicion 22/12/20 18:46:28
		
		_screen.mocks.AgregarSeteoMetodo( 'EMAILAD_SQLSERVER', 'ObtenerDatosEntidad', lcValorXml, "[Codigo, Descripcion, Entidad, Condicion],[codigo in ('DISE99A','DISE99A','DISE99A')],[Codigo]" )
		
		loDisenios = _screen.zoo.crearobjeto( "zoocoleccion" )	
		loEntidad = _screen.zoo.instanciarentidad( "CANADA" )
		loGestor = _screen.zoo.crearobjeto( "GestorDeMail" )

		lcXml = loGestor.ObtenerXmlDiseniosCumplenCondicion( loEntidad, loDisenios )
		
		this.assertequals( "El XML de Diseños de Email debería estar vacío.", "", lcXml )
		
		loItemDisenio = newobject( "ItemDisenios" )
		loItemDisenio.Codigo = "DISE121"
		loDisenios.Add( loItemDisenio )
		loItemDisenio.Codigo = "DISE787"
		loDisenios.Add( loItemDisenio )
		loItemDisenio.Codigo = "DISE99A"
		loDisenios.Add( loItemDisenio )
		
		lcXml = loGestor.ObtenerXmlDiseniosCumplenCondicion( loEntidad, loDisenios )
		
		loDiseniosFiltrados = _screen.zoo.crearobjeto( "zoocoleccion" )
		xmltocursor( lcXml, "cDiseniosMail" )
		select cDiseniosMail
		scan
			loItemDisenio = newobject( "ItemDisenios" )
			loItemDisenio.Codigo = cDiseniosMail.Codigo
			loDiseniosFiltrados.Add( loItemDisenio )
		endscan
		use in select( "cDiseniosMail" )
		
		this.assertequals( "El número de diseños obtenidos no es correcto.", 2, loDiseniosFiltrados.Count )
		this.assertequals( "El código de Diseño de Email(1) no es correcto.", "DISE121", rtrim( loDiseniosFiltrados[1].Codigo ) )
		this.assertequals( "El código de Diseño de Email(2) no es correcto.", "DISE99A", rtrim( loDiseniosFiltrados[2].Codigo ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ZtestEnviarDesdeFormulario
		local loDisenios as Object, loEntidad as Object, loGestor as Object, lcXml as String, loItemDisenio as Object, loDiseniosFiltrados as Object
		local lcValorXml
		
		loColeccionInfo = _screen.zoo.crearobjeto( "ZooInformacion" )
		this.AgregarMocks( "CANADA,EMAIL,EMAILAD_SQLSERVER" )
		_screen.mocks.AgregarSeteoPropiedad( 'CANADA', 'LETRA', 'B' )
		_screen.mocks.AgregarSeteoPropiedad( 'CANADA', 'Numero', 5000 )
		_screen.mocks.AgregarSeteoPropiedad( 'CANADA', 'Descripcion', '' )
		_screen.mocks.AgregarSeteoMetodo( 'CANADA', 'Obtenerinformacion', loColeccionInfo ) && ztestgestordemail.ztestu_obtenerxmldisenoscumplencondicion 22/12/20 18:32:37
		_screen.mocks.AgregarSeteoMetodo( 'CANADA', 'Agregarinformacion', .T., "[*COMODIN]" ) && ztestgestordemail.ztestu_obtenerxmldisenoscumplencondicion 22/12/20 18:46:28
				
		loDisenios = _screen.zoo.crearobjeto( "zoocoleccion" )	
		loEntidad = _screen.zoo.instanciarentidad( "CANADA" )
		addproperty( loEntidad , "EMail", "Sarasa@gmail.com" )
		addproperty( loEntidad ,  "cCodigoDisenoMail", "DISE121" )

		loGestor = newobject( "Test_GestorDeMail" )
		
		loItemDisenio = newobject( "ItemDisenios" )
		loItemDisenio.Codigo = "DISE121"
		loDisenios.Add( loItemDisenio )
		
		loColDisenosPdfComprobanteAdjunto = _screen.zoo.crearobjeto( "zooColeccion" )
		loDiseniosFiltrados = _screen.zoo.crearobjeto( "zoocoleccion" )
		loItemDisenio = newobject( "ItemDisenios" )
		loItemDisenio.Codigo ="DISE121"
		loDiseniosFiltrados.Add( loItemDisenio )
		lcCodigoDisenoMail = "DISE121"
		llRetorno = loGestor.EnviarMailSiHayDisenos( loEntidad, .f., loColDisenosPdfComprobanteAdjunto, 1,  lcCodigoDisenoMail )
		this.asserttrue( "Deberia haber devuelto FALSO", !llRetorno )
		loRespuesta = _screen.zoo.crearobjeto( "RespuestaSeleccionDiseno" )
		loRespuesta.cRespuesta = "DISE121"
		loColDisenosPdfComprobanteAdjunto.Add( loRespuesta.cRespuesta )
		llRetorno = loGestor.EnviarMailSiHayDisenos( loEntidad, .f., loColDisenosPdfComprobanteAdjunto, 1,  lcCodigoDisenoMail )
		this.asserttrue( "Deberia haber enviado el mail", loGestor.lPasoPorEnviar )
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestEnviarEmailAlGrabar
		local loGestor as GestorDeMail of GestorDeMail.prg, loEntidad as entidad OF entidad.prg
		
		_screen.mocks.agregarmock( "Proveedor" )
		_screen.mocks.agregarmock( "Buzon" )
		_screen.mocks.AgregarSeteoMetodo( 'proveedor', 'Cargamanual', .T. )
		_screen.mocks.Agregarseteopropiedad( "Proveedor","Email","")
		
		loGestor = newobject( "Test_GestorDeMail" )
		loEntidad = _screen.zoo.instanciarentidad( "Proveedor" )
		
		loGestor.EnviarMailAlGrabar( loEntidad, .t. )
		this.asserttrue( "Deberia haber saltado por email vacio", loGestor.lUltimoMailVacio )
		
		loEntidad.Email = "Sarasa@gmail.com"

		loGestor.EnviarMailAlGrabar( loEntidad, .t. )
		this.asserttrue( "Deberia haber salido por email lleno", !loGestor.lUltimoMailVacio )
		
		
		loGestor = newobject( "test_gestorDeMailPDFAdjunto" )
		loEntidad = newobject( "aux_proveedor" )
		
		loGestor.EnviarMailAlGrabar( loEntidad, .t. )
		this.asserttrue( "Deberia haber pasado por Enviar Mail Con Pdf Personalizado", loGestor.lPasoPorPDFPersonalizado )
		
		loEntidad.Release()
		loGestor.Release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestTieneMail
		local loEntidad  as entidad OF entidad.prg

		_screen.mocks.agregarmock( "Proveedor" )
		_screen.mocks.agregarmock( "Buzon" )
		_screen.mocks.AgregarSeteoMetodo( 'proveedor', 'Cargamanual', .T. )
		_screen.mocks.Agregarseteopropiedad( "Proveedor","Email","")

		loEntidad = _screen.zoo.instanciarentidad( "Proveedor" )
		loGestor = newobject( "Test_GestorDeMail" )
		loEntidad.Email = "Sarasa@gmail.com"
		this.asserttrue( "No debió dar error ya que la entidad tiene mail.", loGestor.TieneMail( loEntidad ) )
		
		loEntidad.Email = ""
		this.asserttrue( "Debió dar error ya que la entidad no tiene mail.", !loGestor.TieneMail( loEntidad ) )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEnviarMailConPdfPersonalizado
		local loGestor as GestorDeMail of GestorDeMail.prg, loEntidad as entidad OF entidad.prg
		
		loGestor = newobject( "test_gestorDeMailEnviarArchivoAdjunto" )
		loEntidad = newobject( "aux_proveedor" )
		loEntidad.cAuxRuta = ""
		loGestor.EnviarMailConPdfPersonalizado( loEntidad, .t., "123" )
		this.asserttrue( "No debió enviar mail adjunto ya que no tiene definida la ruta del archivo.", !loGestor.lPasoPorEnviarArchivoAdjunto )
		
		loEntidad.cAuxRuta = "ABCD"
		loGestor.EnviarMailConPdfPersonalizado( loEntidad, .t., "123" )
		this.asserttrue( "Debió enviar mail adjunto ya que tiene definida la ruta del archivo.", loGestor.lPasoPorEnviarArchivoAdjunto )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	
enddefine

*-----------------------------------------------------------------------------------------
function ObtenerXml_DiseniosEmailTest() as String
    local lcRetorno as string
    
    text to lcRetorno textmerge noshow
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
										<xsd:maxLength value="20"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="descripcion" use="optional">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="80"/>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
							<xsd:attribute name="condicion" use="optional">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="254"/>
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
	<row codigo="DISE121             " descripcion="                                                                                " condicion=".LETRA == [B] OR .LETRA == [C]                                                                                                                                                                                                                                "/>
	<row codigo="DISE787             " descripcion="                                                                                " condicion=".DESCRIPCION != &quot;&quot;                                                                                                                                                                                                                                                  "/>
	<row codigo="DISE99A             " descripcion="                                                                                " condicion=".NUMERO &gt; 2000                                                                                                                                                                                                                                                 "/>
</VFPData>
	endtext     
	       
	return lcRetorno
endfunc
	
*-----------------------------------------------------------------------------------------
define class ItemDisenios as custom

Codigo = ""

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Test_GestorDeMail as GestorDeMail of GestorDeMail.prg
	lUltimoMailVacio = .f.
	lPasoPorEnviar = .f.
	
	*-----------------------------------------------------------------------------------------
	function ExistenDisenosParaLaEntidadAlGrabar( tcEntidad as String ) as boolean
		return .t.
	endfunc

	
	*-----------------------------------------------------------------------------------------
	function ObtenerDiseniosDeEntidad( tcEntidad as string, tlDiseniosAlGrabarEntidad as Boolean, tlMailVacio as Boolean ) as zoocoleccion of zoocoleccion.prg
		local loDisenios as Object, loItemDisenio as object
		this.lUltimoMailVacio = tlMailVacio

		loDisenios = _screen.zoo.crearobjeto( "zoocoleccion" )
		loItemDisenio = newobject( "ItemDisenios" )
		loItemDisenio.Codigo = "DISE121"
		loDisenios.Add( loItemDisenio )
		return loDisenios
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerXmlDiseniosCumplenCondicion( toEntidad as Object, toDisenios as String ) as String
		local lcDisenios as String, loItemDisenio as Object, lcDisenios as String, lcXml as String, lcXmlCumpleCondicion as String 
		return ""
	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerDisenios( tcXml as Object ) as Object
		local loDisenios as Object, loItemDisenio as Object 
		
		return _screen.zoo.crearobjeto( "zoocoleccion" )
	endfunc
	*-----------------------------------------------------------------------------------------
	function EnviarMailSiHayDisenos( toEntidad as entidad OF entidad.prg, tlNoPreguntarConfirmaEnvioDeMail as Boolean, toColDisenosPdfComprobanteAdjunto as Object, tnDisenosComprobanteAdjunto As Integer, tcCodigoDisenoMail As String ) as Boolean
		local llRetorno as boolean
		
		if toColDisenosPdfComprobanteAdjunto.count > 0
			this.EnviarMailSiHayDisenosPdfComprobanteAdjunto( toEntidad, tlNoPreguntarConfirmaEnvioDeMail, toColDisenosPdfComprobanteAdjunto, tnDisenosComprobanteAdjunto,  tcCodigoDisenoMail )
			llRetorno = .t.
		endif
		return llRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	function Enviar( tcCodigoDisenoMail as string, toEntidad as entidad OF entidad.prg, tlNoPreguntarConfirmaEnvioDeMail as Boolean ) as Void
		This.lPasoPorEnviar = .t.
	endfunc
	*-----------------------------------------------------------------------------------------
	function EnviarMailSiHayDisenosPdfComprobanteAdjunto( toEntidad,tlNoPreguntarConfirmaEnvioDeMail as Boolean,toColDisenosPdfComprobanteAdjunto,tnDisenosComprobanteAdjunto As Integer,tcCodigoDisenoMail As String) as Void
		if toColDisenosPdfComprobanteAdjunto.count > 0
			this.Enviar( tcCodigoDisenoMail , toEntidad, tlNoPreguntarConfirmaEnvioDeMail )
		endif
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Test_GestorDeMailSoloImprime as GestorDeMail of GestorDeMail.prg
	
	*-----------------------------------------------------------------------------------------
	function ExistenDisenosParaLaEntidadAlGrabar( tcEntidad as String ) as boolean
		return .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDiseniosDeEntidad( tcEntidad as string, tlDiseniosAlGrabarEntidad as Boolean, tlMailVacio as Boolean ) as zoocoleccion of zoocoleccion.prg
		local loDisenios as Object, loItemDisenio as object

		loDisenios = _screen.zoo.crearobjeto( "zoocoleccion" )
		if !tlMailVacio
			loItemDisenio = newobject( "ItemDisenios" )
			loItemDisenio.Codigo = "DISE121"
			loDisenios.Add( loItemDisenio )
		endif

		return loDisenios
	endfunc
	
	*-----------------------------------------------------------------------------------------
	
	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class aux_proveedor as Din_Entidadproveedor of Din_Entidadproveedor.prg
	cAuxRuta = ""
	cComprobante = "aaa"
	cContexto = "R"
	
	*-----------------------------------------------------------------------------------------
	function EnviaPdfPersonalizadoPorMail() as Boolean
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerRutaDePdfPersonalizadoParaEnvioDeMail() as String
		return this.cAuxRuta
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class test_gestorDeMailPDFAdjunto as Test_GestorDeMail of ztestgestordemail.prg
	lPasoPorPDFPersonalizado = .f.
	

	*-----------------------------------------------------------------------------------------
	function ObtenerDisenios( tcXml as Object ) as Object
		local loDisenios as Object, loItemDisenio as object

		loDisenios = _screen.zoo.crearobjeto( "zoocoleccion" )
		loItemDisenio = newobject( "ItemDisenios" )
		loItemDisenio.Codigo = "DISE121"
		loDisenios.Add( loItemDisenio )

		return loDisenios
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EnviarMailConPdfPersonalizado( toEntidad as Object, llAlGrabar as Boolean, lcCodigoDisenoMail as String )
		this.lPasoPorPDFPersonalizado = .t.
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------

define class test_gestorDeMailEnviarArchivoAdjunto as Test_GestorDeMail of ztestgestordemail.prg
	lPasoPorEnviarArchivoAdjunto = .f.

	*-----------------------------------------------------------------------------------------
	function ObtenerDisenios( tcXml as Object ) as Object
		local loDisenios as Object, loItemDisenio as object

		loDisenios = _screen.zoo.crearobjeto( "zoocoleccion" )
		loItemDisenio = newobject( "ItemDisenios" )
		loItemDisenio.Codigo = "DISE121"
		loDisenios.Add( loItemDisenio )

		return loDisenios
	endfunc
 
	*-----------------------------------------------------------------------------------------
	function EnviarArchivoAdjunto( tcCodigoDisenoMail as String, tcComprobante as String, tcRutaDelPdf as String ) as Void
		this.lPasoPorEnviarArchivoAdjunto = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConfirmaEnviodeMail( tcCodigoDisenoMail as String) as Void
		return .T.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function loguear( tcMensaje as String ) as Void
	endfunc 

enddefine
