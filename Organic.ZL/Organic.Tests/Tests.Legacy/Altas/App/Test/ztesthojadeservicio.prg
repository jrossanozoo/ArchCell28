Define Class ztesthojadeservicio As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztesthojadeservicio Of ztesthojadeservicio.prg
	#Endif


	*-----------------------------------------------------------------------------------------
	Function Setup
		local loEntidad as Object
		CrearFuncion_ServiciosFacturablesDesdePresupuestosPendientes()
		loEntidad = _Screen.zoo.InstanciarEntidad( "TIPOARTICULOITEMSERVICIO" )
		try
				loEntidad.cCod = '99'
		catch
				loEntidad.Nuevo()
				loEntidad.Ccod = '99'
				loEntidad.descrip = "test" 
				loentidad.Grabar()
		endtry
		loEntidad.Release()
            
		loEntidad = _Screen.zoo.InstanciarEntidad( "TALONARIO" )
		try
				loEntidad.Codigo = 'HOJASERVICIO'
		catch
				loEntidad.Nuevo()
				loEntidad.Codigo = 'HOJASERVICIO'
				loEntidad.entidad = "HOJADESERVICIO" 
				loentidad.Grabar()
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "Zlisarticulos" )
		try
			loEntidad.Codigo = '9999'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '9999'
			loEntidad.descrip = "test" 
			loEntidad.tipoArticulo_pk = "99" 
			loentidad.Grabar()
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "ottarea" )
		try
			loEntidad.Codigo = '9999'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '9999'
			loEntidad.Articulo_pk = '9999'
			loentidad.Grabar()
		endtry
		
		try
			loEntidad.Codigo = '8888'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '8888'
			loEntidad.Articulo_pk= '9999'
			loentidad.Grabar()
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "SERVICIOOT" )
		try
			loEntidad.Codigo = '7777'
		catch
			with loEntidad
				.Nuevo()
				.Codigo = '7777'
				
				.DetTar.LimpiarItem()
				with .DetTar.Oitem
					.CodTar_pk = '9999'
				endwith
				.DetTar.Actualizar()

				.DetTar.LimpiarItem()
				with .DetTar.Oitem
					.CodTar_pk = '8888'
				endwith
				.DetTar.Actualizar()
				.Articulo_pk = '9999'
				.grabar()
			endwith
		endtry
		loentidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "seriev2" )
		try
			loEntidad.NumeroSerie = '407008'
		catch
			loEntidad.Nuevo()
			loEntidad.NumeroSerie = '407008'
			loentidad.Grabar()
		endtry
		try
			loEntidad.NumeroSerie = '407009'
		catch
			loEntidad.Nuevo()
			loEntidad.NumeroSerie = '407009'
			loentidad.Grabar()
		endtry

		loEntidad.Release()
		
	Endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
    &&    loEntidad = _Screen.zoo.InstanciarEntidad( "TIPOARTICULOITEMSERVICIO" )
    &&    try
    &&        loEntidad.ccod = '99'
    &&        loEntidad.Eliminar()
    &&    catch
    &&    endtry
    &&         loEntidad.release()

    &&    loEntidad = _Screen.zoo.InstanciarEntidad( "talonario" )
    &&    try
    &&        loEntidad.codigo = 'HOJADESERVICIO'
    &&        loEntidad.Eliminar()
    &&    catch
    &&    endtry
    &&         loEntidad.release()


	&& 	loEntidad = _Screen.zoo.InstanciarEntidad( "ottarea" )
	&& 	try
	&& 		loEntidad.Codigo = '9999'
	&& 		loEntidad.Eliminar()
	&& 	catch
	&& 	endtry
		
	&& 	try
	&& 		loEntidad.Codigo = '8888'
	&& 		loEntidad.Eliminar()
	&& 	catch
	&& 	endtry

	&& 	loEntidad.Release()

	&& 	loEntidad = _Screen.zoo.InstanciarEntidad( "SERVICIOOT" )
	&& 	try
	&& 		loEntidad.Codigo = '7777'
	&& 		loEntidad.Eliminar()
	&& 	catch
	&& 	endtry
		
	&& 	loEntidad.release()

	&& 	loEntidad = _Screen.zoo.InstanciarEntidad( "Zlisarticulos" )
	&& 	try
	&& 		loEntidad.Codigo = '9999'
	&& 		loEntidad.Eliminar()
	&& 	catch
	&& 	endtry
	&& 	loEntidad.release()

	&& 	loEntidad = _Screen.zoo.InstanciarEntidad( "seriev2" )
	&& 	try
	&& 		loEntidad.NumeroSerie = '407008'
	&& 		loEntidad.Eliminar()
	&& 		loEntidad.NumeroSerie = '407009'
	&& 		loEntidad.Eliminar()
		
	&& 	catch
	&& 	endtry
		
	&& 	loEntidad.release()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestSQLServerIntanciar
		Local loEntidad As Object

		loEntidad = _Screen.zoo.InstanciarEntidad( "HojadeServicio" )
		loEntidad.Inicializar()
		This.assertnotnull ("No se pudo instanciar la entidad", loEntidad)
		this.assertnotnull( "No tiene la lista de precios", loEntidad.ListaDePrecios )
		this.assertnotnull( "No tiene el componente de precios", loEntidad.DetalleServicios.oItem.oCompPrecios )
		this.assertnotnull( "No tiene el componente la referencia a la lista de precios", loEntidad.DetalleServicios.oItem.oListaDePrecios )
		
		loEntidad.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerCargadeservicioytareas
	local loEntidad as Entidad of Entidad.prg, lnCantidadTareas as Integer, lcTarea as String 
	
		lnCantidadTareas = 0
		lcTarea = ''
		loEntidad = _Screen.zoo.InstanciarEntidad( "HOJADESERVICIO" )
		
		with loEntidad
			.Nuevo()
			.DetalleServicios.LimpiarItem()
			with .DetalleServicios
				.oItem.Servicio_pk = '7777'
			endwith
			.DetalleServicios.Actualizar()

			This.assertequals( "No se grabó el numero de servicio en el detalle.", '7777', 	alltrim( .DetalleTareas.oItem.codserv_pk ) )
			this.assertequals( "La cantidad de tareas no es la correcta", 2 , .DetalleTareas.Count )
			
			with .DetalleServicios
				.CargarItem( 1 )
				.oItem.Servicio_pk = '7777'
			endwith
	
			this.assertequals( "La cantidad de tareas no es la correcta", 2 , .DetalleTareas.Count )				

			with .DetalleTareas                           
				.CargarItem( 1 )
				lcTarea = .oItem.Tarea_pk
				.oItem.Tarea_pk = ''
				.Actualizar()
				this.asserttrue( "Se elimino una tarea asociada a un Servicio.", !empty( loEntidad.DetalleTareas.oitem.tarea_pk ) )								
			endwith
				
			for each loItem in .DetalleTareas		
				if loItem.CodServ_pk = '7777'
 					lnCantidadTareas = lnCantidadTareas + 1 
				endif
			endfor
			this.assertequals( "Se borraron tareas correspondientes al servicio 7777", 2 , lnCantidadTareas )				

		endwith

		loEntidad.Release()                     
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerAsignacionDeClave
	
	local loEntidad as Entidad of Entidad.prg, lnCantidadTareas as Integer, lcTarea as String 
	
		loEntidad = _Screen.zoo.InstanciarEntidad( "HOJADESERVICIO" )
		*loEntidad.oObtencionDatosComboRazonSocial = newobject( "ObtencionDatosComboRazonSocial_aux" )
		
		with loEntidad
			.Nuevo()
			.NroSerie_Pk = "407008"
			this.assertequals( "Asignó mal la clave para el serie 407008", "77-41-56" , .ClaveSerie )
			.NroSerie_Pk = "407009"
			this.assertequals( "Asignó mal la clave para el serie 407009", "77-72-98" , .ClaveSerie )

			.cancelar()
			.release()
		endwith
		
	endfunc 


enddefine
	
*-------------------------------------------------------------------------------------------------------------
define class ObtencionDatosComboRazonSocial_aux as Custom

 	*-----------------------------------------------------------------------------------------
	function ObtenerDatos( tnroserie as String ) as string 
		local  lcXml as String

		lcXml = ''
		do case 
			case tnroserie = '407008'
			text to lcxml noshow
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData xml:space="preserve">
	<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsd:element name="VFPData" msdata:IsDataSet="true">
			<xsd:complexType>
				<xsd:choice maxOccurs="unbounded">
					<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
						<xsd:complexType>
							<xsd:attribute name="distinct_codigo" use="optional">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
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
	<row distinct_codigo="00238"/>
</VFPData>
endtext			
			
			case tnroserie = '407009'
			
			text to lcxml noshow
			<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData xml:space="preserve">
	<xsd:schema id="VFPData" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsd:element name="VFPData" msdata:IsDataSet="true">
			<xsd:complexType>
				<xsd:choice maxOccurs="unbounded">
					<xsd:element name="row" minOccurs="0" maxOccurs="unbounded">
						<xsd:complexType>
							<xsd:attribute name="distinct_codigo" use="optional">
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsd:maxLength value="5"/>
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
	<row distinct_codigo="00106"/>
</VFPData>
endtext
			
		endcase
		

		return lcXml	
	endfunc 


enddefine

****************************************************************************************


*-----------------------------------------------------------------------------------------
Function CrearFuncion_ServiciosFacturablesDesdePresupuestosPendientes
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncServiciosFacturablesDesdePresupuestosPendientesPorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[FuncServiciosFacturablesDesdePresupuestosPendientesPorCliente]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION ZL.FuncServiciosFacturablesDesdePresupuestosPendientesPorCliente
		( 
			@Cliente varchar(5)
		)
		RETURNS TABLE
		AS
		RETURN
		(select '' as Servicio, 1 as pendientes where 1=2)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc