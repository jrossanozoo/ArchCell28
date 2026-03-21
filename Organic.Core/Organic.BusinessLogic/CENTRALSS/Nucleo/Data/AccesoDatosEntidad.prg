define class AccesoDatosEntidad as zooSession of zooSession

	#if .f.
		local this as AccesoDatosEntidad of AccesoDatosEntidad.prg
	#endif

	datasession = 1

	cNombreCursor = ""
	
	protected oEntidad
	oEntidad = null
	
	colSentencias = null
	cUbicacionDB = ""
	cEsquema = ""
	cTipoDB = ""
	oColTablasCursores = null
	lProcesarConTransaccion = .T.
	cTablaPrincipal = ""
	lRecibePorBulkCopy = .f.
	oConexion = null
	oMensajesConexion = null
	
	*--------------------------------------------------------------------------------------------------------
	Function oConexion_Access() As object
		if !this.ldestroy and ( vartype( this.oConexion ) != 'O' or isnull( this.oConexion ) )
			this.oConexion = goServicios.Datos
		endif
		return this.oConexion
	endfunc

	*-------------------------------------------------------------------------------------------------
	Function Init()
		return DoDefault() And ( This.Class # "Accesodatosentidad" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColTablasCursores_Access() as ZooColeccion of ZooColeccion.prg
		if !this.ldestroy and ( vartype( this.oColTablasCursores ) != 'O' or isnull( this.oColTablasCursores ) )
			this.oColTablasCursores = this.crearobjeto( 'ZooColeccion' )
		endif
		return this.oColTablasCursores
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Inserta en la tabla
	function Insertar() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Modifica los valores de la tabla
	function Actualizar() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasInsert() as zooColeccion
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasUpdate() as zooColeccion
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasDelete() as zooColeccion
		*** Esta funcion se genera
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Primero() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Anterior() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Siguiente() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Ultimo() as Void
		*** Esta funcion se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad of entidad.prg )
		this.oEntidad = toEntidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		this.lDestroy = .t.
		
		this.oEntidad = null
		this.colSentencias = null
		this.oConexion = null
		use in select( this.cNombreCursor )
		
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarPorClavePrimaria( tlLlenarAtributos as Boolean ) as Boolean
		*** se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarPorClaveCandidata() as boolean
		&& se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConsultarPorAtributoSecundario( tcAtributo as string ) as Boolean
		*** se genera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMemo( tcTabla as String ) as string
		local lxCodigo as variant, lcCodigo as string, lcAtributo as string, lcTabla as string, lcSql as string, ;
			lcMemo as string , lnLetraActual as integer, lcXml as string

		with this
			lcTabla = tcTabla
			lcMemo = ''
			lcPaseMemo = ''
			
			select ( lcTabla )
			scan
				lcPaseMemo = lcPaseMemo + &lcTabla..Texto
			endscan

			if empty( lcPaseMemo )
			else
				lcMemo = strtran( strtran( lcPaseMemo, chr( 230 ), chr( 13 ) ), chr( 240 ), chr( 10 ) )
			endif
		endwith
		return lcMemo
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ObtenerEstructura( tcTabla as String ) As String
		return this.ObtenerDatos( "*", "0=1", "", "", "", tcTabla, "" )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	protected Function ObtenerDatos( tcAtributos As String, tcHaving As String, tcOrder As String , tcFunc As String, ;	
		tcWhere as string, tcTabla as String, tcDetalle as String, tnTope as Integer ) As String
		
		Local	lcXml As Boolean, lcAtributos As String, lcWhereYHaving As String, lcOrder As String, ; 
				lcPrimero as String, lcPrimerAtributo As String, lcGroupBy As String, lcCursor as String, ;
				lcNombreFuncion as String, lcObtenerCampo as String, lcObtenerCamposSelect as String, ;
				lcCamposHaving as String 

		lcNombreFuncion = iif( empty( tcDetalle ), "Entidad", "Detalle" + tcDetalle )
		lcWhereYHaving = tcWhere
		If empty( tcHaving )
		else
			lcWhereYHaving = this.ObtenerWhereYHaving( tcHaving, lcWhereYHaving, lcNombreFuncion )
		endif
		
		If empty( tcOrder )
			lcOrder = ' '
		Else
			lcOrder = ' Order By ' + tcOrder 
		EndIf

		lcGroupBy = ' '

		if empty( tcFunc )
			lcAtributos = tcAtributos
		else
			lcPrimero = getwordnum( tcAtributos, 1, ',' ) 
			lcObtenerCampo = "This.ObtenerCampo" + lcNombreFuncion + "( lcPrimero )" 
			lcPrimerAtributo = tcFunc + '(' + &lcObtenerCampo + ') As ' + tcFunc + '_' + lcPrimero 
			do Case
				case getwordcount( tcAtributos, ',' ) = 0
					lcAtributos = lcPrimerAtributo
					
				case getwordcount( tcAtributos, ',' ) = 1
					lcAtributos = lcPrimerAtributo
					
				case getwordcount( tcAtributos, ',' ) > 1
					lcGroupBy = strtran( tcAtributos, lcPrimero + ',' )
					lcObtenerCamposSelect = "This.ObtenerCamposSelect" + lcNombreFuncion + "( lcGroupBy )"
					lcAtributos = lcPrimerAtributo + ',' + &lcObtenerCamposSelect
					lcObtenerCamposGroupBy = "this.ParsearCampos" + lcNombreFuncion + "( lcGroupBy )"
					lcGroupBy = ' Group By ' + &lcObtenerCamposGroupBy
			EndCase
		endif
		lcXml = this.EjecutarConsulta( lcAtributos, tcTabla , lcWhereYHaving, lcOrder, lcGroupBy, tnTope )

		*----------Fin Consulta----------------
		Return lcXml 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EjecutarConsulta( tcAtributos as String, tcTabla as String, tcWhereYHaving as String, tcOrder as String, tcGroupBy as string, tnTope as Integer ) as String
		local lcCursor as String, lcXml as String
		
		lcCursor = sys( 2015 )
		
		if !empty( tnTope )
			lcTop = "TOP " + transform( tnTope )
		else
			lcTop = ""
		endif

		this.oConexion.EjecutarSentencias( "select " + lcTop + " " + tcAtributos + " from " + tcTabla + tcWhereYHaving + tcOrder + tcGroupBy, tcTabla, "", lcCursor, set("Datasession") )
		lcXml = this.CursorAXml( lcCursor )
		
		use in select( lcCursor )
		
		return lcXml
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ejecutarSentencias( loColeccionSentencias as zoocoleccion OF zoocoleccion.prg ) as Void

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerWhereYHaving( tcHaving as String, tcWhereYHaving as string, tcNombreFuncion as String ) as String

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConvertirDateSql( tdValor as Date ) as String
		local lcRetorno as String
       	if empty( tdValor )
       		tdValor = {01/01/1900}
       	endif
    	do case
    		case year(tdValor) <= 10
    			tdValor = date(year(tdValor)+2000,month(tdValor),day(tdValor))
    		case year(tdValor) <= 99
    			tdValor = date(year(tdValor)+1900,month(tdValor),day(tdValor))
        	case year(tdValor) <= 1000
    			tdValor = date(year(tdValor)+1000,month(tdValor),day(tdValor))
    	endcase
    	if year(tdValor) < 1753
    		tdValor = date(year(tdValor)+1753,month(tdValor),day(tdValor))
    	endif
        lcRetorno = dtos( tdValor )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FormatearTextoSql( tcCadena as String ) as String
		tcCadena = rtrim( strtran( tcCadena, "'", "''" ) )
		
		return tcCadena
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConvertirAtributosCadenaSql( tcNombreFuncion as string, tcCadena as String ) as String
		local lnCant as Integer, i as Integer, lcRetorno as String, lcCampo as String, lcObtenerCampo as String
		local array laPalabras[ 1 ]

		lcRetorno = ""

		tcCadena = this.ConvertirFuncionesSql( tcCadena )

		lnCant = this.GenerarListaDePalablas( tcCadena, @laPalabras )
		for i = 1 to lnCant
			lcObtenerCampo = "this.ObtenerCampo" + tcNombreFuncion + "( laPalabras[ i ] )"
			lcCampo = &lcObtenerCampo
			if empty( lcCampo )
				lcRetorno = lcRetorno + laPalabras[ i ] + " "
			else
				lcRetorno = lcRetorno + lcCampo + " "
			endif
		endfor

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarListaDePalablas( tcCadena as String, taLista as Array ) as Integer
		local i as integer, loListaDePalabras as object, lcExpresionRegular as String
		lcExpresionRegular = ""

		do case
			case "'" $ tcCadena
				lcExpresionRegular = "([\'].?[\'])|(\'\')|[\'].+?[\']|([\(]+?[\'].+?[\'].+?[\']+?[\)])|[^\' ]+"
			case '"' $ tcCadena
				lcExpresionRegular = '([\"].?[\"])|(\"\")|[\"].+?[\"]|([\(]+?[\"].+?[\"].+?[\"]+?[\)])|[^\" ]+'
		endcase
		if !empty( lcExpresionRegular )
			loListaDePalabras = _screen.DotNetBridge.InvocarMetodoEstatico( "System.Text.RegularExpressions.Regex", "Matches", tcCadena, lcExpresionRegular )
			dimension taLista( loListaDePalabras.Count )
			for i = 0 to loListaDePalabras.Count - 1
				taLista( i + 1 ) = _screen.DotNetBridge.ObtenerValorPropiedad( loListaDePalabras.Item(i), "Value" )
			endfor
		else
			alines( taLista, tcCadena, 1 + 8, " " )
		endif

		return alen( taLista, 1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDate( tcCursor as String, tcAtributo as string ) as date
		return &tcCursor..&tcAtributo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoGenerico( tcNombreFuncion as string, tcCampo as String ) as String
		** Generar
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConvertirFuncionesSql( tcCadena as string ) as String
		local lnCantNots as Integer, lnPos as Integer

		** Reemplaza funciones con las correspondientes en sql
		tcCadena = strtran( lower( tcCadena ), "alltrim", "funciones.alltrim" )
		tcCadena = strtran( lower( tcCadena ), "empty", "funciones.empty" )
		tcCadena = strtran( lower( tcCadena ), "==", "=" )
		tcCadena = strtran( lower( tcCadena ), "ctod", "" )
		tcCadena = strtran( lower( tcCadena ), '"', "'" )
		*tcCadena = strtran( lower( tcCadena ), '.f.', "0" )
		*tcCadena = strtran( lower( tcCadena ), '.t.', "1" )

		lnCantNots = occurs( "!", tcCadena )
		for i = 1 to lnCantNots
			lnPos = at( "!", tcCadena, i )
			if substr( tcCadena, lnPos + 1, 1 ) != "="
				tcCadena = strtran( tcCadena, "!", "not ", i, 1 )
			endif
		endfor
		return tcCadena
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUbicacionSucursal() as Boolean
		return ( empty( this.cUbicacionDB ) or alltrim( upper( this.cUbicacionDB ) ) == "SUCURSAL" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUbicacionPuesto() as Boolean
		return ( alltrim( upper( this.cUbicacionDB ) ) == "PUESTO" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaTabla() as String
		return this.cRutaTablas
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUbicacionDB() as String
		local lcRetorno as string
		if this.EsUbicacionSucursal()
			lcRetorno = _screen.zoo.app.cSucursalActiva
		else
			lcRetorno = this.cUbicacionDB
		endif
		
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function InicializarMensajesConexion() as Void
		this.oMensajesConexion = _Screen.zoo.crearobjeto("ZooColeccion")
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMensajesConexion() as String
		local lcRetorno as String
		
		lcRetorno = ""

		for lnI = 1 to this.oMensajesConexion.Count 
			lcRetorno = lcRetorno + this.oMensajesConexion.Item[lnI] + chr(13) + chr(10)
		endfor

		return lcRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	Function Importar( tcXmlDatos As String, tlCompletoConValidaciones as Boolean ) As Void
		local loError as zooException of zooException.prg, loConexion as Object, loTransaction as Object
		private	lcXmlDatos as String
			
		pcXmlDatos = tcXmlDatos 
		with this
			try
			
				.IniciarImportacion()
				.AbrirCursores( tcXmlDatos, .oEntidad.cPrefijoImportar )

				loConexion = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.ManejadorArchivos.WrapperConexion", goServicios.Datos.oManagerConexionASql.ObtenerCadenaConexionNet()+";Connection Timeout=600" )

				if tlCompletoConValidaciones 
					this.oEntidad.PreprocesarCursorParaImportacionEnBloque( .oEntidad.cPrefijoImportar + .oEntidad.cNombre  )
				endif

				if .ValidarDatosAImportar()
					.EliminarDuplicaciones()
					.ActualizarCamposImpo()
					.CrearTablaDeTrabajo( loConexion )

					if tlCompletoConValidaciones 
						.CrearTablaDeTrabajoDetalles( loConexion )
						.CrearTablaDeTrabajoErroresValidacion( loConexion )
						.EliminarDatosInvalidos( loConexion )
					endif

					.CargarTablaDeTrabajo( loConexion )

					if tlCompletoConValidaciones 
						.AplicarReglaDeNegocioTablaDeTrabajo( loConexion )
					endif
					
					.EjecutarReglaDeNegocioPersonalizadaEnTablaTrabajo( loConexion )
					.ImportarTablaDeTrabajo( loConexion )

					if tlCompletoConValidaciones 
						.CrearReporteErroresImportacion( loConexion )
						.EliminarTablasDeTrabajo( loConexion )
						.EliminarTablasDeTrabajoErroresValidacion( loConexion )
					endif
					loConexion.Commit()
					goServicios.RealTime.AgregarAlta( .oEntidad.cNombre )
				endif
			catch to loError
				loConexion.RollBack()
				loEx = _screen.zoo.crearobjeto( "ZooException" )
				With loEx				
					.Grabar( loError)
					goServicios.Errores.LevantarExcepcionEnmascarada( "Se produjo un error al importar", loEx )
				EndWith
			finally
				.FinalizarImportacion()
				loConexion.Close()
			endtry
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearTablaDeTrabajoDetalles() as Void
		* Generado si tiene la funcionalidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CrearTablaDeTrabajoErroresValidacion( toConexion as Object ) as Void
		local lcSentencia as string

		toConexion.EjecutarNonQuery( 'Use [' + goLibrerias.obtenernombresucursal( alltrim( _Screen.zoo.app.cSucursalActiva ) ) + ']' )

		text to lcSentencia textmerge noshow
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('ZooLogic.TablaTrabajoErroresValidacion_<<this.cTablaPrincipal>>') AND type in ('U')) DROP TABLE ZooLogic.TablaTrabajoErroresValidacion_<<this.cTablaPrincipal>>
				Create Table ZooLogic.TablaTrabajoErroresValidacion_<<this.cTablaPrincipal>> ( 
					 "Nrolinea" numeric( 20, 0 ) not null, 
					"Motivo" text null )
		endtext

		toConexion.EjecutarNonQuery( lcSentencia )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CargarTablaDeTrabajoDetalles( toConexion as Object ) as void
		* Generado si tiene la funcionalidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AplicarReglaDeNegocioTablaDeTrabajo( toConexion as Object ) As Void
		* Generado si tiene la funcionalidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarTablasDeTrabajo( toConexion ) as Void
		* Generado si tiene la funcionalidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarTablasDeTrabajoErroresValidacion( toConexion ) as Void
		local lcSentencia as string
		text to lcSentencia textmerge noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('ZooLogic.TablaTrabajoErroresValidacion_<<this.cTablaPrincipal>>') AND type in ('U')) DROP TABLE ZooLogic.TablaTrabajoErroresValidacion_<<this.cTablaPrincipal>>
		endtext
		toConexion.EjecutarNonQuery( lcSentencia )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearReporteErroresImportacion( toConexion as Object  ) as Void
		local loDataReader as Object, lcCursor as String, lcCursorInformacionErrores as String

		loDataReader = toConexion.EjecutarQuery( [SELECT cast( Nrolinea AS INT ), cast( Motivo AS VARCHAR(MAX) )FROM ZooLogic.TablaTrabajoErroresValidacion_] + this.cTablaPrincipal )
		
		lcCursor = sys(2015)
		
		CREATE CURSOR &lcCursor ( Nrolinea n( 20,0 ), Motivo v(254) )

		try
            do while ( _screen.dotnetbridge.invocarmetodo( loDataReader, "Read" )  )
				insert into &lcCursor ( Nrolinea, Motivo ) values ( _Screen.DotNetBridge.invocarmetodo ( loDataReader,"GetInt32", 0 ), _Screen.DotNetBridge.invocarmetodo ( loDataReader,"GetString", 1 ) )
            enddo
		finally
            _screen.dotnetbridge.invocarmetodo( loDataReader, "Close" ) 
			lcCursorInformacionErrores = this.Cursoraxml( lcCursor )
			this.oEntidad.InformarErroresImportacion( lcCursorInformacionErrores ) 
        endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Recibir( toListaTablas as zoocoleccion OF zoocoleccion.prg, tlLoguear as Boolean ) as Void
	
		if this.lRecibePorBulkCopy 
			this.RecibirPorBulkCopy( toListaTablas, tlLoguear )
		else
			this.RecibirPorSentenciaIndividual( toListaTablas, tlLoguear )
		endif
	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RecibirPorBulkCopy( toListaTablas as zoocoleccion OF zoocoleccion.prg, tlLoguear as Boolean ) as Void
		local loError as zooexception OF zooexception.prg, loConexion as Object, loTransaction as Object
		
		with this
			try
				* idem anterior
				.AbrirCursoresRecepcion( toListaTablas )
				.BlanquearCamposTransferencia()

				loConexion = _screen.dotnetbridge.CrearObjeto( "ZooLogicSA.ManejadorArchivos.WrapperConexion", goServicios.Datos.oManagerConexionASql.ObtenerCadenaConexionNet() )

				.InicializarMensajesConexion()

				.RecibirCabeceraBulkCopy( loConexion, tlLoguear )
				
				* Idem Anterior
				.RecibirDetalles()
				.RecibirComponentes()
				.EventoAntesDeFinalizarRecibir()

				*.FinalizarTransaccionRecibir()
				loConexion.Commit()
				goServicios.RealTime.AgregarAlta( .oEntidad.cNombre )
			catch to loError
				loConexion.RollBack()
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.FinalizarRecibir()
				loConexion.Close()
			endtry
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RecibirPorSentenciaIndividual( toListaTablas as zoocoleccion OF zoocoleccion.prg, tlLoguear as Boolean ) as Void
		local loError as zooexception OF zooexception.prg 
	
		with this
			try
				.AbrirConexionRecibir()
				.AbrirCursoresRecepcion( toListaTablas )
				.BlanquearCamposTransferencia()
				.IniciarTransaccionRecibir()
				.RecibirCabecera( tlLoguear )
				.RecibirDetalles()
				.RecibirComponentes()
				.EventoAntesDeFinalizarRecibir()
				.FinalizarTransaccionRecibir()
				.EnviarColaWebHook()
			catch to loError
				.RollbackTransaccionRecibir()
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.CerrarConexionRecibir()
				.FinalizarRecibir()
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function RecibirCabeceraBulkCopy( toConexion as Object, tlLoguear as Boolean, toTransaction as Object ) As Void
		local lcCursor as String
		lcCursor = This.oEntidad.cPrefijoRecibir + this.oEntidad.cNombre

		with this
			Try
				.EliminarDuplicaciones()
				.ActualizarCamposRecepcion()
				.CrearTablaDeTrabajo( toConexion )
				.CargarTablaDeTrabajo( toConexion )
				.EjecutarReglaDeNegocioPersonalizadaEnTablaTrabajo( toConexion )
				.ImportarTablaDeTrabajo( toConexion )
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		endwith
		delete from &lcCursor where empty( ESTTRANS )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeFinalizarRecibir() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecibirCabecera( tlLoguear as Boolean ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecibirDetalles() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecibirComponentes() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirConexionRecibir() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CerrarConexionRecibir() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarTransaccionRecibir() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FinalizarTransaccionRecibir() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RollbackTransaccionRecibir() as Void
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	Function EnviarColaWebHook() As Void
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function VerificarInsercionUnicidadAntesDelCommit( txValorClavePrimaria as Variant ) as void
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function BlanquearCamposTransferencia() as Void
		local lcCursor as String
		lcCursor = This.oEntidad.cPrefijoRecibir + this.oEntidad.ObtenerNombre()
		Update &lcCursor Set ESTTRANS = [], FECTRANS = {} 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FinalizarRecibir() as Void
		This.CerrarCursores()
		use in select( "cExistentes" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarDuplicaciones() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirCursores( tcXmlDatos as String, tcPrefijoImportar as String ) as Void
		local loContainer as zooDataContainer of zooDataContainer.prg, lcCursor as string
		this.oColTablasCursores.quitar( -1 )
		loContainer = newobject( 'zooDataContainer', 'zooDataContainer.prg' )
		loContainer.Cargar( tcXmlDatos )
		for Each lcCursor in loContainer.oTablas
			If This.EsAliasDeProceso( lcCursor, tcPrefijoImportar )
				loContainer.ToCursor( lcCursor )
				go top in ( lcCursor )
				this.oColTablasCursores.agregar( lcCursor )
			EndIf
		EndFor
		loContainer.release()	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AbrirCursoresRecepcion( toListaTablas as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcCursor as String
		this.oColTablasCursores.quitar( -1 )

		for Each lcCursor in toListaTablas
			If This.EsAliasDeProceso( juststem(lcCursor), this.oEntidad.cPrefijoRecibir )
				use ( lcCursor ) in 0 shared
				go top in ( juststem(lcCursor) )
				this.oColTablasCursores.agregar( juststem(lcCursor) )
			EndIf
		EndFor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarImportacion() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FinalizarImportacion() as Void
		this.CerrarCursores()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearTablaDeTrabajo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarTablaDeTrabajo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ImportarTablaDeTrabajo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarCamposImpo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaTriggerImportacion() as string
		return ""
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarDatosAImportar() as Boolean
		return .T.
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	Function CerrarCursores() As Void
		local lcCursor as string
		for Each lcCursor in this.oColTablasCursores
			use in select( lcCursor )
		EndFor
		this.oColTablasCursores.quitar( -1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function LoguearRecepcion( tcMensaje as String, tlLoguea as Boolean ) as Void
		if tlLoguea
			This.Loguear( tcMensaje )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizaEnRecepcion() as Boolean
		Return This.oEntidad.lActualizaRecepcion and dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerIdentificador( toEntidad as entidad OF entidad.prg ) as String
		local lcRetorno as string, lcCursor as integer, lcWhereYHaving as string, lcCursorAD as string, ;
			lcAtributoAD as string, lcClavePrimaria as string, lcComillas as string, lcValorClavePrimaria as string

		lcComillas = ""
		lcCursor = "c_" + sys( 2015 )		
		lcClavePrimaria = toEntidad.ObtenerAtributoClavePrimaria()
		lcValorClavePrimaria = toEntidad.&lcClavePrimaria
		
		if type( "lcValorClavePrimaria" ) = "C"
			lcComillas = "'"
		endif
		
		lcAtributoAD = toEntidad.oAd.ObtenerCampoEntidad( lcClavePrimaria )
		lcWhereYHaving = " Where " + lcAtributoAD + " = " + lcComillas + transform( lcValorClavePrimaria ) + lcComillas
		this.oConexion.EjecutarSentencias( "Select * From " + toEntidad.oAd.cTablaPrincipal + lcWhereYHaving , toEntidad.oAd.cTablaPrincipal, "", lcCursor, set("Datasession") )
		
		lcRetorno = this.ObtenerIdentificadorParaLoguear( lcCursor )

		use in select( lcCursor )
		
		return lcRetorno		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerIdentificadorParaLoguear( tcCursor as strin ) As String
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarCampoMemo( tcCursor as String, tcCampoMemo as String, tcCampoPK as String, tcAtributo as String ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearConexionParaTransaccion() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearConexionGlobal() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFechaUltimoUpdateEnTablas() as DateTime
		* Generado
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ComprobarTransaccion() as Void
		local lcCursorError as String, lcCursorTran as String, lnCantTran as Integer, loError as Exception
		
		lcCursorTran = sys(2015)
		lcMensaje = ""
		
		try
			this.oConexion.EjecutarSql("SELECT @@TRANCOUNT as total", lcCursorTran , this.DataSessionId )
			try
				select (lcCursorTran )
				lnCantTran = &lcCursorTran..total
				
				if lnCantTran == 0
				
					lcMensaje = "La transacción en curso fue cancelada de forma inesperada."
					
					Text to lcCadena noshow textmerge
						SELECT cast( text AS VARCHAR(250)) as mensaje 
						FROM sys.messages WHERE message_id = @@Error 
							AND language_id = ( 
											select msglangid 
											from sys.syslanguages 
											where langid=@@langid 
											)
					endtext
					
					lcCursorError = sys(2015)
					this.oConexion.EjecutarSql( lcCadena, lcCursorError , this.DataSessionId )
					
					if RECCOUNT( lcCursorError )
						lcMensaje = lcMensaje + ": " + &lcCursorError..mensaje 
					endif

				endif
			finally
				use in select (lcCursorTran)
			endtry
		catch to loError
		endtry
		
		if !empty( lcMensaje )
			goServicios.Errores.LevantarExcepcionTexto( lcMensaje )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ComprobarResultadoDeEjecucionDelUpdate() as Void
		local lcCursorRowCount as String, lnCantUpdate as Integer, loError as Exception, loEx as Exception, loExcepcionNumeroYaUsado as Object
		lcCursorRowCount = sys(2015)
		try
			this.oConexion.EjecutarSql("SELECT @@ROWCOUNT as total", lcCursorRowCount , this.DataSessionId )
			select (lcCursorRowCount )
			lnCantUpdate = &lcCursorRowCount..total
			if lnCantUpdate == 0
				loExcepcionNumeroYaUsado = newobject( "ExcepcionNumeroYaUsado", "numeraciones.prg" )
				loEx = _screen.zoo.crearobjeto("zooexception")
				loEx.ErrorNo = loExcepcionNumeroYaUsado.ErrorNo
				loEx.Message = loExcepcionNumeroYaUsado.Message
				goServicios.Errores.LevantarExcepcion( loEx )
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in ( lcCursorRowCount )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarReglaDeNegocioPersonalizadaEnTablaTrabajo( toConexion ) as Void
		* Se sobreescribe en el acceso a datos de cada entidad de ser necesario ent_**ad_sqlserver.prg
	endfunc

enddefine
