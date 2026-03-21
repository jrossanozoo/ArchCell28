**********************************************************************
define class zTestKontrolerAcercaDe as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestKontrolerAcercaDe of zTestKontrolerAcercaDe.prg
	#endif
	cSerie = ""
	cNombre = ""
	cOrganizacion = ""
	
	*---------------------------------
	function setup
		with this
			.cSerie = _screen.zoo.app.cSerie
			.cNombre = _screen.zoo.app.cNombre
			.cOrganizacion = _screen.zoo.app.cOrganizacion
		endwith
	endfunc

	*---------------------------------
	function TearDown
		with this
			_screen.zoo.app.cSerie = .cSerie
			_screen.zoo.app.cNombre = .cNombre
			_screen.zoo.app.cOrganizacion = .cOrganizacion
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestVerificarCantidadDeModulosCargados
		local loFormularioAcercaDe as Frm_AcercadeEstilo2 of Frm_AcercadeEstilo2.prg , loZooColeccion as zoocoleccion of zoocoleccion.prg

		private goModulos
		_screen.mocks.agregarmock( "Modulos" )
        
        goColaboradorModulosOnLine = newobject( "ModulosActivacionOnLineFake" )
		goModulos = _screen.zoo.crearobjeto( "Modulos" )

		loZooColeccion = _screen.zoo.crearobjeto( "zooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Obtenermodulos', loZooColeccion )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Esproductomodularizado', .T. )
		
		loFormularioAcercaDe = _screen.zoo.app.crearobjeto( "Frm_AcercadeEstilo2" )
		with loFormularioAcercaDe as Frm_AcercadeEstilo2 of Frm_AcercadeEstilo2.prg
			this.assertequals( "No se cargó la cantidad de módulos del producto.", 0, .oleTreeView.Nodes.count )
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarNombresDeVersion
		local loFormularioAcercaDe as Frm_AcercadeEstilo2 of Frm_AcercadeEstilo2.prg , loZooColeccion as zoocoleccion of zoocoleccion.prg

		private goModulos
		_screen.mocks.agregarmock( "Modulos" )
		goModulos = _screen.zoo.crearobjeto( "Modulos" )
        goColaboradorModulosOnLine = newobject( "ModulosActivacionOnLineFake" )
		loZooColeccion = _screen.zoo.crearobjeto( "zooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Obtenermodulos', loZooColeccion )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Esproductomodularizado', .T. )

		_screen.zoo.app.cSerie = "Serie"
		_screen.zoo.app.cNombre = "cNombre"
		_screen.zoo.app.cOrganizacion = "cOriganizacion"

		loFormularioAcercaDe = _screen.zoo.app.crearobjeto( "Frm_AcercadeEstilo2" )
		with loFormularioAcercaDe as Frm_AcercadeEstilo2 of Frm_AcercadeEstilo2.prg
			This.assertequals( "El Nombre de la organizacion no es el correcto.", "cOriganizacion", alltrim( .lblorganizacion.Caption ) )
			This.assertequals( "El Serie mostrado no es el correcto.", "Serie", alltrim( .lBLSERIE.Caption ) )
			.release()
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_BuscarActualizacionesConExito
		local loControler as Object

		_screen.mocks.agregarmock( "Librerias", "TestLibreriasnucleo" )
		_screen.mocks.agregarmock( "Mensajes" )
		
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 6, "[¿Confirma la actualización de módulos?],4,1" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 6, "[Se actualizaron los módulos del sistema. ¿Desea salir de la aplicación para que lo cambios tomen efecto?],4" )
				

		private goMensajes
		private goLibrerias
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

		goLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )
				
		loControler = createobject( "Mock_kontroleracercade" )
		loControler.Retorno_EjecutarActualizacionDeModulo = .T.
		loControler.ActualizarModulos()

		This.assertequals( "No se ejecuto correctamente.", 0, _Screen.Mocks(3).oMetodos.Count )
		goMensajes = _screen.zoo.app.oMensajes
		
		loControler = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_BuscarActualizacionesConExitoForzandoSalida
		local loControler as Object, loBindeo as Object

		_screen.mocks.agregarmock( "Librerias", "TestLibreriasnucleo" )
		_screen.mocks.agregarmock( "Mensajes" )
        goColaboradorModulosOnLine = newobject( "ModulosActivacionOnLineFake" )
		
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 6, "[¿Confirma la actualización de módulos?],4,1" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 6, "[Se actualizaron los módulos del sistema. ¿Desea salir de la aplicación para que lo cambios tomen efecto?],4" )
*!*			_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., "[Espere por favor...]" ) 
*!*			_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., ".T." ) 
		

		private goMensajes
		private goLibrerias
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

		goLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

		loControler = createobject( "Mock_kontroleracercade" )
		loControler.Retorno_EjecutarActualizacionDeModulo = .T.
		
		loBindeo = createobject( "oBindeo" ) 
		bindevent( loControler, "SalirDelSistema", loBindeo, "SalirDelSistema",1) 
		
		loControler.ActualizarModulos()

		this.asserttrue( "No paso por la salida del sistema", loBindeo.llSalida )
		
		goMensajes = _screen.zoo.app.oMensajes
		loBindeo = null
		loControler = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_BuscarActualizacionesConExitoSinForzarSalida
		local loControler as Object, loBindeo as Object
        
		_screen.mocks.agregarmock( "Librerias", "TestLibreriasnucleo" )

		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 6, "[¿Confirma la actualización de módulos?],4,1" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 7, "[Se actualizaron los módulos del sistema. ¿Desea salir de la aplicación para que lo cambios tomen efecto?],4" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., "[Espere por favor...]" ) 
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviarsinespera', .T., ".T." ) 
		

		private goMensajes
		private goLibrerias
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

		goLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

		loControler = createobject( "Mock_kontroleracercade" )
		loControler.Retorno_EjecutarActualizacionDeModulo = .T.
		
		loBindeo = createobject( "oBindeo" ) 
		bindevent( loControler, "SalirDelSistema", loBindeo, "SalirDelSistema",1) 
		
		loControler.ActualizarModulos()

		this.asserttrue( "No debio pasar por la salida del sistema", !loBindeo.llSalida )
		
		goMensajes = _screen.zoo.app.oMensajes
		loBindeo = null
		loControler = null
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestU_BuscarActualizacionesConFallo
		local loControler as Object

		_screen.mocks.agregarmock( "Mensajes" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Preguntar', 6, "[¿Confirma la actualización de módulos?],4,1" )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Advertir', .T., "'No se pudieron actualizar los módulos. Inténtelo nuevamente.'" )
		goMensajes = _screen.zoo.crearobjeto( "Mensajes" )
				
		loControler = createobject( "Mock_kontroleracercade" )
		loControler.Retorno_EjecutarActualizacionDeModulo = .F.
		loControler.ActualizarModulos()

		This.assertequals( "No se ejecuto correctamente.", 0, _Screen.Mocks(3).oMetodos.Count )
		goMensajes = _screen.zoo.app.oMensajes
		
		loControler = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_DeshabilitarBotonActualizarModulosConSerieDEMO
		local loFormularioAcercaDe as Frm_AcercadeEstilo2 of Frm_AcercadeEstilo2.prg , loZooColeccion as zoocoleccion of zoocoleccion.prg

		private goModulos
		_screen.mocks.agregarmock( "Modulos" )
		goModulos = _screen.zoo.crearobjeto( "Modulos" )
        goColaboradorModulosOnLine = newobject( "ModulosActivacionOnLineFake" )
		loZooColeccion = _screen.zoo.crearobjeto( "zooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Obtenermodulos', loZooColeccion )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Esproductomodularizado', .T. )

		_screen.zoo.app.cSerie = "DEMO"
		_screen.zoo.app.cNombre = "cNombre"
		_screen.zoo.app.cOrganizacion = "cOriganizacion"

		loFormularioAcercaDe = _screen.zoo.app.crearobjeto( "Frm_AcercadeEstilo2" )
		This.asserttrue( "No se deshabilito el boton.",  !loFormularioAcercaDe.CmdActualizarModulos.Enabled )
		loFormularioAcercaDe.release()

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DeshabilitarBotonActualizarModulosConSerieValido
		local loFormularioAcercaDe as Frm_AcercadeEstilo2 of Frm_AcercadeEstilo2.prg , loZooColeccion as zoocoleccion of zoocoleccion.prg

		private goModulos
		_screen.mocks.agregarmock( "Modulos" )
		goModulos = _screen.zoo.crearobjeto( "Modulos" )
        goColaboradorModulosOnLine = newobject( "ModulosActivacionOnLineFake" )
		loZooColeccion = _screen.zoo.crearobjeto( "zooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Obtenermodulos', loZooColeccion )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Esproductomodularizado', .T. )

		_screen.zoo.app.cSerie = "407000"
		_screen.zoo.app.cNombre = "cNombre"
		_screen.zoo.app.cOrganizacion = "cOriganizacion"

		loFormularioAcercaDe = _screen.zoo.app.crearobjeto( "Frm_AcercadeEstilo2" )
		This.asserttrue( "No se habilito el boton.",  loFormularioAcercaDe.CmdActualizarModulos.Enabled )
		loFormularioAcercaDe.release()

	endfunc


enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_kontroleracercade as kontroleracercade of kontroleracercade.prg

	Retorno_EjecutarActualizacionDeModulo = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearDatosEmpresa() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarActualizacionDeModulo() as Boolean
		return this.Retorno_EjecutarActualizacionDeModulo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SalirDelSistema() as Void
	endfunc 
	
enddefine


define class oBindeo as custom

llSalida = .f.
	*-----------------------------------------------------------------------------------------
	function SalirDelSistema() as Void
		this.llSalida = .t.
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
define class ModulosActivacionOnLineFake as Custom
    
    nEstado = 0
    cMensajeError  = ""
    cMensajeLogueo = ""
    Resultado = null
    oModulos = null
    *-----------------------------------------------------------------------------------------    
    function init() as object
    local loRetorno as Object, loModulo1 as Object, loModulo2 as object
        
        this.oModulos = newobject("collection")
        loRetorno = newobject("RespuestaNetAux")
        loRetorno.Resultado = newobject("Collection")
        return loRetorno
    endfunc    
enddefine

*-----------------------------------------------------------------------------------------
define class RespuestaNetAux as custom
    Estado = 0
    MensajeError = ""
    Resultado = null
    itemModulo = null 
enddefine

*-----------------------------------------------------------------------------------------
define class ItemModulosAux as custom
    nId = 0
    cNombre = ""
    lHabilitado = .f.
    cDescripcion = ""
    cmodulo = ""
enddefine     