define class AccesoDatosEntidad_NET  as AccesoDatosEntidad of AccesoDatosEntidad.prg

	#if .f.
		local this as AccesoDatosEntidad_NET of AccesoDatosEntidad_NET.prg
	#endif

	oDAL = null
	oDTO = null
	cArchivoLogPrueba = ""
	tFechaVaciaSqlServer = {}

	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as boolean
		if dodefault()
			with this
				.cArchivoLogPrueba = SYS(0) + '_' + transform( date() ) + '_' + strtran( time(), ':', '.' ) + '_' + transform( golibrerias.obtenertimestamp() ) + '.txt' 
				.cArchivoLogPrueba = strtran( strtran( strtran( .cArchivoLogPrueba, '/', '-' ), ' ', '' ), '#', '' )
				.cTipoDB = 'SQLSERVER'
				.tFechaVaciaSqlServer = evaluate( goRegistry.Nucleo.FechaEnBlancoParaSqlServer )
			endwith
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearObjetoDal( tcEntidad as String ) as Object
		local lcClaseDAL as String, lcArchivoDeConfiguracion as String, lcStringDeConexion as String
		lcClaseDAL = "ZooLogicSA." + alltrim( _Screen.zoo.app.ObtenerNombreProyecto() ) + ".Repositorios." + tcEntidad + "DAL"
		lcArchivoDeConfiguracion = addbs( _screen.zoo.cRutaInicial ) + "ClasesDePrueba\App.config"
		lcStringDeConexion = goServicios.Datos.oManagerConexionASql.ObtenerCadenaConexionNet()
		return this.CrearObjeto( lcClaseDAL, "", lcArchivoDeConfiguracion, lcStringDeConexion )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Destroy() as boolean
		This.oDto = Null
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Cargar() as boolean
		local llRetorno as Boolean
		llRetorno = !isnull( This.oDto )
		if llRetorno
			This.AsignarAtributos( This.oDto, This.oEntidad )
		endif
		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Insertar() as boolean

		local loDTO as Object, loError as zooexception OF zooexception.prg

		this.VerificarUnicidad()
		loDTO = this.oDAL.NuevoDTO()
		this.AsignarAtributos( This.oEntidad, loDto )
		try
			this.oDAL.Grabar( loDTO )
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Actualizar() as boolean
		local loError as Exception, loDTO as Object
		Try
			loDTO = this.oDAL.ObtenerPorId( this.ObtenerValorAtributoClavePrimaria() )
			This.AsignarAtributos( This.oEntidad, loDto )
			this.oDAL.Grabar( loDTO )
		Catch to loError
			if !isnull( this.oDAL.UltimaExcepcion ) and this.oDAL.UltimaExcepcion.Tipo == "NHIBERNATE.STALEOBJECTSTATEEXCEPTION"
				This.LevantarExepcionPorConcurrencia()
			else
				goServicios.Errores.LevantarExcepcion( loError )
			endif
		EndTry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LevantarExepcionPorConcurrencia() as void
		local loEx as zooexception of zooexception.prg
		loEx = Newobject( "ZooException", "ZooException.prg" )
		With loEx
			loEx.AgregarInformacion( "El registro fue modificado, no se puede actualizar", 9003 )
			goServicios.Errores.LevantarExcepcion( loEx )
		endwith
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Eliminar() as boolean
		local loError as Exception, loDTO as Object

		Try
			loDTO = this.oDAL.ObtenerPorId( this.ObtenerValorAtributoClavePrimaria() )
			this.oDAL.Eliminar( loDTO )
		Catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		EndTry

	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function VerificarUnicidad() as void
		local lcError as string
		lcError = ''
		If this.ConsultarPorClavePrimaria()
			lcError  = 'La clave primaria a grabar ya existe'
		else
		endif
		if !empty( lcError )
			goServicios.Errores.LevantarExcepcionTexto( lcError )
		endif
	endfunc	
	
	*--------------------------------------------------------------------------------------------------------
	function HayDatos() as boolean
		return this.oDAL.HayDatos()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ConsultarPorClavePrimaria( tlLlenarAtributos as Boolean ) as Boolean
		this.oDTO = this.oDAL.ObtenerPorId( this.ObtenerValorAtributoClavePrimaria() )
		return !isnull( this.oDTO )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	Function Primero() As Boolean
		this.oDTO = this.oDAL.Primero()
		return !isnull( this.oDTO )
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	Function Siguiente() As Boolean
		this.oDTO = this.oDAL.Siguiente( this.ObtenerValorAtributoClavePrimaria() )
		return !isnull( this.oDTO )
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	Function Anterior() As Boolean
		this.oDTO = this.oDAL.Anterior( this.ObtenerValorAtributoClavePrimaria() )
		return !isnull( this.oDTO )
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	Function Ultimo() As Boolean
		this.oDTO = this.oDAL.Ultimo()
		return !isnull( this.oDTO )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValorAtributoClavePrimaria() as Variant
		local lcPK as String
		lcPk = This.oEntidad.ObtenerAtributoClavePrimaria()
		return THis.oEntidad.&lcPk.
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function ObtenerTimestampActual() as integer
		local loDTO as Object
		loDTO = this.oDAL.ObtenerPorId( this.ObtenerValorAtributoClavePrimaria() )
		return loDTO.TimeStamp
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ParsearFechaNet( toDestino as Object, txFecha as Variant ) as Date
		local ldRetorno as Object
		if This.EsObjetoNet( toDestino ) and empty( txFecha )
			ldRetorno =  This.tFechaVaciaSqlServer
		else
			ldRetorno =  This.ParsearFecha( txFecha )
		EndIf
		return ldRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		this.oDTO = null
	endfunc 

enddefine

*!*		&& LISTA DE FUNCIONES A IMPLEMENTAR
*!*		function ConsultarPorAtributoSecundario( tcAtributo ) as Boolean
*!*		Function ObtenerDatosEntidad( tcAtributos As String, tcHaving As String, tcOrder As String , tcFunc As String ) As String
*!*		Function ParsearCamposEntidad( tcCampos As String ) As String
*!*		Function ObtenerCamposSelectEntidad( tcCampos As String ) As String
*!*		Function ObtenerCampoEntidad( tcAtributo As String ) As String
*!*		function ObtenerTablaDetalle( tcDetalle as string ) as String
*!*		function ObtenerObjetoBusqueda() as Void y su Clase
*!*		Function Recibir( tcXmlDatos As String ) As Void
*!*		Function Importar( tcXmlDatos As String ) As Void
*!*		Function oSp_Access() As object
*!*		&& Funciones que no tendrian mas sentido ??
*!*		function ObtenerSentenciasInsert() as zooColeccion of zooColeccion.prg
*!*		function ObtenerSentenciasUpdate() as zooColeccion of zooColeccion.prg
*!*		function ObtenerSentenciasDelete() as zooColeccion of zooColeccion.prg
*!*		&& Funciones que no tendrian mas sentido ??
