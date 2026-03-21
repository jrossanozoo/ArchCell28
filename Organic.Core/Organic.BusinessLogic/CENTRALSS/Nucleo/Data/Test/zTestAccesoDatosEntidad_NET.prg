**********************************************************************
Define Class zTestAccesoDatosEntidad_NET As FxuTestCase Of FxuTestCase.prg

	#If .F.
		local this as zTestAccesoDatosEntidad_NET Of zTestAccesoDatosEntidad_NET.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Setup() as Void
		_screen.netextender.oAssemblyResolver.AddPath( addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TearDown() as Void
		_screen.netextender.oAssemblyResolver.RemovePath( addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerFuncionalidadBasica
*!*			local loEntidad as entidad OF entidad.prg

*!*			Generar( "Color" )
*!*			_screen.zoo.AgregarReferencia( addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba\ZooLogicSA.Nucleo.Entidades.dll" )
*!*			loEntidad = _screen.zoo.instanciarentidad( "Color" )
*!*			InyectarAD( loEntidad )
*!*			with loEntidad
*!*				goDatos.EjecutarSentencias( "delete from Col", "Col.dbf", "" )
*!*				.Nuevo()
*!*				.Codigo = "C1"
*!*				.Descripcion = "Color Uno"
*!*				.Grabar()
*!*				.Nuevo()
*!*				.Codigo = "C2"
*!*				.Descripcion = "Color Dos"
*!*				.Grabar()
*!*				.Nuevo()
*!*				.Codigo = "C3"
*!*				.Descripcion = "Color tres"
*!*				.Grabar()
*!*				.Primero()
*!*				This.Assertequals( "No se paro en el registro correcto 1", "Color Uno", alltrim( .Descripcion ) )
*!*				.Anterior()
*!*				This.Assertequals( "No se paro en el registro correcto 2", "Color Uno", alltrim( .Descripcion ) )
*!*				.Siguiente()
*!*				This.Assertequals( "No se paro en el registro correcto 3", "Color Dos", alltrim( .Descripcion ) )
*!*				.Siguiente()
*!*				This.Assertequals( "No se paro en el registro correcto 4", "Color tres", alltrim( .Descripcion ) )
*!*				.Anterior()
*!*				This.Assertequals( "No se paro en el registro correcto 5", "Color Dos", alltrim( .Descripcion ) )
*!*				.Ultimo()
*!*				This.Assertequals( "No se paro en el registro correcto 6", "Color tres", alltrim( .Descripcion ) )
*!*				.Siguiente()
*!*				This.Assertequals( "No se paro en el registro correcto 7", "Color tres", alltrim( .Descripcion ) )
*!*				.Ultimo()
*!*				.Eliminar()
*!*				try
*!*					.Codigo = "C3"
*!*					this.asserttrue( "Deberia haber pinchado", .f. )
*!*				catch
*!*				endtry
*!*				.Codigo = "C2"
*!*				.Modificar()
*!*				.Descripcion = "TITO"
*!*				.Grabar()
*!*				.Codigo = "C1"
*!*				.Eliminar()
*!*				.Codigo = "C2"
*!*				This.Assertequals( "No se cargaron bien las fechas de alta y modificacion", .fechaAltaFW, .FechaModificacionFW )			
*!*				This.Assertequals( "No se cargaron bien las horas de modificacion y alta", .T., !Empty( .HoraAltaFW ) and !empty( .HoraModificacionFW )	)
*!*				This.Assertequals( "No se cargo bien la descripcion 8", "TITO", alltrim( .Descripcion ) )
*!*				.Eliminar()
*!*				This.AssertTrue( "No anda bien el HayDatos", !.oAD.HayDatos() )
*!*				.Release()
*!*			EndWith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestSqlServerConcurrencia
*!*			local loEntidad as entidad OF entidad.prg, loError as zooexception OF zooexception.prg

*!*			Generar( "Color" )
*!*			goDatos.EjecutarSentencias( "delete from Col", "Col.dbf", "" )
*!*			_screen.zoo.AgregarReferencia( addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba\ZooLogicSA.Nucleo.Entidades.dll" )

*!*			loEntidad = _screen.zoo.instanciarentidad( "Color" )
*!*			InyectarAD( loEntidad )
*!*			
*!*			loEntidad2 = _screen.zoo.instanciarentidad( "Color" )
*!*			InyectarAD( loEntidad2 )

*!*			*!* Alta
*!*			loEntidad.Nuevo()
*!*			loEntidad.Codigo = "C1"
*!*			loEntidad.Descripcion = "Color"
*!*			loEntidad.Grabar()
*!*				
*!*			*!* Modificación a traves de Entidad1.
*!*			loEntidad.Codigo = "C1"
*!*			loEntidad.Modificar()
*!*			loEntidad.Descripcion = "Color 1"
*!*			
*!*			*!* Modificación a traves de Entidad2.
*!*			loEntidad2.Codigo = "C1"
*!*			loEntidad2.Modificar()
*!*			loEntidad2.Descripcion = "Color Uno"

*!*			*!* Grabación a traves de Entidad1.
*!*			loEntidad.Grabar()
*!*			
*!*			try
*!*				*!* Grabación a traves de Entidad2.
*!*				loEntidad2.Grabar()
*!*				this.asserttrue( "Debería haber fallado por concurrencia", .f. )
*!*			catch to loError
*!*				this.assertequals( "El mensaje no es el correcto.", "El registro fue modificado, no se puede actualizar", loError.UserValue.oInformacion.item[ 1 ].cMensaje )
*!*				loEntidad2.Cancelar()
*!*				this.assertequals( "La descripción no es correcta.", "Color 1", loEntidad.Descripcion )
*!*			endtry

*!*			loEntidad.Release()
*!*			loEntidad2.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerSubEntidades
	*Entidades
	*Articulo
	*|->Material
	*|->Proveedor
	*   |->Provincia
		*ActivarLogueoNH()
*!*			
*!*			local loArticulo as entidad OF entidad.prg, loMaterial as entidad OF entidad.prg, loProveedor as entidad OF entidad.prg, loProvincia as entidad OF entidad.prg
*!*					
*!*			Generar( "Articulo" )
*!*			Generar( "Proveedor" )
*!*			Generar( "Provincia" )
*!*			Generar( "Material" )
*!*			
*!*			goDatos.EjecutarSentencias( "delete from Art", "Art.dbf", "" )
*!*			goDatos.EjecutarSentencias( "delete from Proveed", "Proveed.dbf", "" )
*!*			goDatos.EjecutarSentencias( "delete from Mat", "Mat.dbf", "" )
*!*			goDatos.EjecutarSentencias( "delete from Provinci", "Provinci.dbf", "" )						

*!*			_screen.zoo.AgregarReferencia( addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba\ZooLogicSA.Nucleo.Entidades.dll" )

*!*			loArticulo = _screen.zoo.instanciarentidad( "Articulo" )
*!*			InyectarAD( loArticulo )
*!*			InyectarAD( loArticulo.Proveedor )
*!*			InyectarAD( loArticulo.Proveedor.Provincia )
*!*			InyectarAD( loArticulo.Material )
*!*			loMaterial = _screen.zoo.instanciarentidad( "Material" )
*!*			InyectarAD( loMaterial )
*!*			loProveedor = _screen.zoo.instanciarentidad( "Proveedor" )
*!*			InyectarAD( loProveedor )
*!*			InyectarAD( loProveedor.Provincia )
*!*			loProvincia = _screen.zoo.instanciarentidad( "Provincia" )
*!*			InyectarAD( loProvincia )

*!*			with loProvincia
*!*				.Nuevo()
*!*				.Codigo = "P1"
*!*				.Descripcion = "Descrip prov 1"
*!*				.Grabar()

*!*				.Nuevo()
*!*				.Codigo = "P2"
*!*				.Descripcion = "Descrip prov 2"
*!*				.Grabar()
*!*			endwith
*!*			with loProveedor
*!*				.Nuevo()
*!*				.Codigo = "PRVE1"
*!*				.Nombre = "Proveedor 1"
*!*				.Provincia_pk = "P1"
*!*				.Grabar()
*!*				
*!*				.Nuevo()
*!*				.Codigo = "PRVE2"
*!*				.Nombre = "Proveedor 2"
*!*				.Provincia_pk = "P2"
*!*				.Grabar()
*!*	*!*	Hasta que no se defina como solucionar el tema de los null este test queda comentado		
*!*	*!*				.Nuevo()
*!*	*!*				.Codigo = "PRVE3"
*!*	*!*				.Nombre = "Proveedor 3"
*!*	*!*				.Grabar()
*!*			endwith
*!*			with loMaterial
*!*				.Nuevo()
*!*				.Codigo = "MAT1"
*!*				.Descripcion = "Descrip mat 1"
*!*				.Grabar()

*!*				.Nuevo()
*!*				.Codigo = "MAT2"
*!*				.Descripcion = "Descrip mat 2"
*!*				.Grabar()
*!*			endwith
*!*			with loArticulo
*!*				.Nuevo()
*!*				.Codigo = "ART1"
*!*				.Descripcion = "Descrip art 1"
*!*				.Proveedor_Pk = "PRVE1"
*!*				.Material_Pk = "MAT1"
*!*				.Grabar()

*!*				.Nuevo()
*!*				.Codigo = "ART2"
*!*				.Descripcion = "Descrip art 2"
*!*				.Proveedor_Pk = "PRVE2"
*!*				.Material_Pk = "MAT2"
*!*				.Grabar()
*!*			endwith

*!*			******Hasta aca tendria que haber cargado todo bien.
*!*			loArticulo.codigo = "ART1"
*!*			this.assertequals( "Error en el codigo del proveedor del articulo ART1", "PRVE1", loArticulo.Proveedor_pk )
*!*			this.assertequals( "Error en el codigo de la provincia del proveedor del articulo ART1", "P1", loArticulo.Proveedor.Provincia_pk )
*!*			this.assertequals( "Error en la descripcion de la provincia del proveedor del articulo ART1", "Descrip prov 1", alltrim( loArticulo.Proveedor.Provincia.Descripcion ) )
*!*			
*!*	*!*			loProveedor.codigo = "PRVE3"
*!*	*!*			this.assertequals( "Error en el nombre del proveedor 3", "Proveedor 3", alltrim( loProveedor.Nombre ) )
*!*	*!*			this.assertequals( "Error en la provincia del proveedor 3", "", loProveedor.provincia_pk  )

*!*			loArticulo.release()
*!*			loMaterial.release()
*!*			loProveedor.release()
*!*			loProvincia.release()
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
function Generar( tcEntidad as String ) as void
	local loGenerador as Object
	loGenerador = _Screen.zoo.crearObjeto( "GeneradorDinamicoAccesoDatosNET" )
	loGenerador.Generar( tcEntidad )
	loGenerador.Release()
endfunc

*-----------------------------------------------------------------------------------------
function InyectarAD( toEntidad as Object ) as Void
	toEntidad.oAD = _screen.zoo.crearobjeto( "Din_Entidad" + toEntidad.ObtenerNombre() + "AD_NET"  )
	toEntidad.oAD.InyectarEntidad( toEntidad )
	toEntidad.oAD.Inicializar()
endfunc

*-----------------------------------------------------------------------------------------
function ActivarLogueoNH() as void
	local loFileInfo as Object
	loFileInfo = _screen.zoo.crearobjeto( "System.IO.FileInfo", "", addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba\App.Config" )
	_screen.zoo.AgregarReferencia( "Log4Net.dll" )
	_screen.zoo.InvocarMetodoEstatico( "Log4NET.Config.XmlConfigurator", "Configure", loFileInfo )
endfunc