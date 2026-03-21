define class ServicioEstructura as Servicio Of Servicio.prg

	#IF .f.
		Local this as ServicioEstructura of ServicioEstructura.prg
	#ENDIF

	protected cCursorEstructura as String, oDinEstructuraAdn as Din_EstructuraAdn of Din_EstructuraAdn.prg, cSchemaDefault as String, cRutaEstructura as String, oEstructuraTablas as Collection
	protected oAtributosPk as zoocoleccion OF zoocoleccion.prg, cCursorFuncionalidades as String , cCursorEntidadesMenu as String
	
	cRutaEstructura = ""
	lCambioRuta = .f.
	lDinEstructuraAdnActivo = .f.
	cCursorEstructura = sys( 2015 )
	oDinEstructuraAdn = null
	oEstructuraTablas = null
	oAtributosPk = Null
	cCursorFuncionalidades = "c_FuncionalesPorSesion"
	cCursorEntidadesMenu = "c_EntidadesMenuPrincipal"

		
	*-----------------------------------------------------------------------------------------
	function oDinEstructuraAdn_access() as Void
		if this.HayQueIniciarEstructuraAdn()
			this.IniciarEstructuraAdn()
		endif
		
		return this.oDinEstructuraAdn
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HayQueIniciarEstructuraAdn() as Boolean
		local llRetorno as Boolean

		llRetorno = !this.lDestroy and ( vartype( this.oDinEstructuraAdn ) != 'O' or isnull( this.oDinEstructuraAdn ) or this.lCambioRuta or !used( this.cCursorEstructura ) )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarEstructuraAdn() as Void
		if this.VerificarArchivoDeEstructura()
			this.oEstructuraTablas = newobject( "Collection" )
			this.oDinEstructuraAdn = _screen.zoo.crearobjeto( "Din_EstructuraAdn", this.cRutaEstructura + "Din_EstructuraAdn.prg" )
			this.ObtenerCursorEstructuraAdn( this.DataSessionId, this.cCursorEstructura )
			this.lCambioRuta = .f.
			this.lDinEstructuraAdnActivo = .t.
			this.oAtributosPk = newobject( "Collection" )
*			This.oDinEstructuraAdn.ObtenerColeccionAtributosPk()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar( tcRutaDinEstructura as String ) as Void	
		if empty( tcRutaDinEstructura )
			tcRutaDinEstructura = addbs( _screen.zoo.cRutaInicial ) + "generados\"
		endif
		
		this.lCambioRuta = !( alltrim( upper( this.cRutaEstructura )) == alltrim( upper( addbs( tcRutaDinEstructura ) )))
		this.cRutaEstructura = addbs( tcRutaDinEstructura )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorXml( tcXml as string, tnDataSessionId as integer, tcCursor as String ) as Void
		local lnDataSession as Integer
		
		if empty( tnDataSessionId )
			tnDataSessionId = 1
		endif
		
		lnDataSession = this.DataSessionId
		set datasession to ( tnDataSessionId )
				
		this.XmlACursor( tcXml, tcCursor )
		set datasession to ( lnDataSession )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarArchivoDeEstructura() as Void
		if !this.ExisteArchivoDeEstructura()
			goServicios.Errores.LevantarExcepcion( "No se encuentra la Estructura del ADN. Consulte con el Administrador del sistema." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Compilar( tcArchivo as String ) as Void
		local llRetorno as Boolean   
		llRetorno = .t.
		try
			clear class ( juststem( tcArchivo ) )
			compile ( tcArchivo )
		catch
			llRetorno = .f.
		endtry
		return llRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteArchivoDeEstructura() as Boolean 
		local llRetorno as Boolean, lcArchivoEstruc

		lcArchivoEstruc = this.cRutaEstructura + "din_EstructuraAdn"
		llRetorno = file( lcArchivoEstruc + ".fxp" )
		if llRetorno
		else
			if file( lcArchivoEstruc + ".prg" )
				llRetorno = this.Compilar( lcArchivoEstruc + ".prg" )
			endif
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreCursorEstructura() as String
		return this.cCursorEstructura
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEsquema( tcTabla as String ) as String
		*** Subclaseado
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerVersion() as String
		Return this.oDinEstructuraAdn.ObtenerVersion()
	endfunc


	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionOperaciones( tnDataSessionId as integer, tcClavePadre as String, toColOperaciones as ZooColeccion of ZooColeccion.prg ) As ZooColeccion of ZooColeccion.prg
		return this.oDinEstructuraAdn.ObtenerColeccionOperaciones( tnDataSessionId, tcClavePadre, toColOperaciones )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CopiarTablasSucursal( tcRutaOrigen as String, tcRutaDestino as String, tcSucursalOrigen as String, tcSucursalDestino as String ) as Void
		*** Subclaseado
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEstructuraTabla( tcTabla as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as Collection, lcCursor as String, lcCursorAdn as String, loItem as Empty, loError as Exception
		loRetorno = newobject( "Collection" )
		lcCursor = sys( 2015 )
		lcCursorAdn = this.cCursorEstructura

		if this.HayQueIniciarEstructuraAdn()
			this.IniciarEstructuraAdn()
		endif
		try
			if this.oEstructuraTablas.Getkey( alltrim( upper( tcTabla ))) > 0
				loRetorno = this.oEstructuraTablas.Item[ alltrim( upper( tcTabla )) ]
			else
				select * ;
				from &lcCursorAdn ;
				where alltrim( upper( tabla )) == alltrim( upper( tcTabla )) ;
					and !inlist( alltrim( upper( esquema )), "PARAMETROS", "REGISTROS" );
				order by Campo into cursor &lcCursor
				
				select ( lcCursor )
				
				addproperty( loRetorno, "Tabla", alltrim( upper( tcTabla )) )
				
				scan
					SCATTER NAME loItem 
*!*						loItem = newobject( "Empty" )
*!*						addproperty( loItem, "Campo", &lcCursor..Campo )
*!*						addproperty( loItem, "TipoDato", &lcCursor..TipoDato )
*!*						addproperty( loItem, "Tamaño", &lcCursor..Longitud )
*!*						addproperty( loItem, "Decimales", &lcCursor..Decimales )
*!*						addproperty( loItem, "Ubicacion", &lcCursor..Ubicacion )
*!*						addproperty( loItem, "EsPK", &lcCursor..EsPK )
*!*						addproperty( loItem, "EsCC", &lcCursor..EsCC )
*!*						addproperty( loItem, "Esquema", &lcCursor..Esquema )			
					
					loRetorno.Add( loItem, alltrim( upper( &lcCursor..Campo )))
				endscan
				
				this.oEstructuraTablas.Add( loRetorno, alltrim( upper( tcTabla )))
			endif
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( lcCursor )
		endtry 
	
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarFuncionalidad( tcEntidad as string, tcFuncionalidad as string ) as boolean
		return this.oDinEstructuraAdn.VerificarFuncionalidad( tcEntidad, tcFuncionalidad )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFuncionalidades() as String
		return this.oDinEstructuraAdn.ObtenerFuncionalidades()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCursorEstructuraAdn( tnDataSessionId as integer, tcCursor as String ) as Void
		local lcXml as String, lnDataSession as Integer
		lcXml = this.ObtenerXmlEstructura()
		lnDataSession = set("Datasession")
		
		this.ObtenerCurSorXml( lcXml, @tnDataSessionId, tcCursor )
		
		set datasession to ( tnDataSessionId )
		select &tcCursor
		
		index on alltrim( upper( tabla )) tag tabla 
		
		set order to tabla
		
		set datasession to ( lnDataSession )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerXmlEstructura() as String
		*** Subclaseado
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAuditoriaDetalle( tnDataSessionId as integer, tcCursor as String ) as Void
		local lcXml as String
		lcXml = this.ObtenerXmlCamposAuditoriaDetalle()
		
		this.ObtenerCursorXml( lcXml, tnDataSessionId, tcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerXmlCamposAuditoriaDetalle() as String
		return this.oDinEstructuraAdn.ObtenerCamposAuditoriaDetalle()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAuditoriaEntidad( tnDataSessionId as integer, tcCursor as String ) as Void
		local lcXml as String
		lcXml = this.ObtenerXmlCamposAuditoriaEntidad()
		
		this.ObtenerCursorXml( lcXml, tnDataSessionId, tcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXmlCamposAuditoriaEntidad() as String
		return this.oDinEstructuraAdn.ObtenerCamposAuditoriaEntidad()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerOperaciones( tnDataSessionId as integer, tcCursor as String ) As Void
		local lcXml as String
		lcXml = this.ObtenerXmlOperaciones()
		
		this.ObtenerCursorXml( lcXml, tnDataSessionId, tcCursor )	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerXmlOperaciones() As String
		Return this.oDinEstructuraAdn.ObtenerOperaciones()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerIndices( tnDataSessionId as integer, tcCursor as String ) As Void
		local lcXml as String
		lcXml = this.ObtenerXmlIndices()
		
		this.ObtenerCursorXml( lcXml, tnDataSessionId, tcCursor )	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerXmlIndices() As String
		Return this.oDinEstructuraAdn.ObtenerIndices()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Release() as Void
		dodefault()
		clear class din_estructuraadn

		use in select( this.cCursorEstructura )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerUbicacion( tcTabla as String ) as String
		local lcRetorno as String, loEstructura as zoocoleccion OF zoocoleccion.prg

		lcRetorno = ""
		
		if !empty( tcTabla )
			loEstructura = this.ObtenerEstructuraTabla( tcTabla )

			if loEstructura.Count > 1
				if empty( loEstructura[1].Ubicacion )
					lcRetorno = "SUCURSAL"
				else
					lcRetorno = upper( loEstructura[1].Ubicacion )
				endif
			endif
		endif
				
		return alltrim( lcRetorno )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTablaConEsquema( tcTabla as String ) as String
		** Escribita en subclases
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionModulosPorEntidad() as Object
		return this.oDinEstructuraAdn.ObtenerColeccionModulosPorEntidad()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSelectConsultaPrecios( tdFechaVigencia as Date, tcListaDePrecios as String, tlNoVerificarCalculadaAlMomento as Boolean ) as String
		return this.oDinEstructuraAdn.ObtenerSelectConsultaPrecios( tdFechaVigencia, tcListaDePrecios, tlNoVerificarCalculadaAlMomento )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSelectPreciosVigentes( tdFechaVigencia as Date, tcListaDePrecios as String ) as String
		return this.oDinEstructuraAdn.ObtenerSelectPreciosVigentes( tdFechaVigencia, tcListaDePrecios )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSelectConsultaPreciosConPrecioActual( tdFechaVigencia as Date, tcListaDePrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String
		return this.oDinEstructuraAdn.ObtenerSelectConsultaPreciosConPrecioActual( tdFechaVigencia, tcListaDePrecios, tlNoVerificarCalculadaAlMomento, tcListaActual )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFuncionPrecioRealDeLaCombinacionConVigencia( tdFechaVigencia as Date, tcListaDePrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String
		return this.oDinEstructuraAdn.ObtenerFuncionPrecioRealDeLaCombinacionConVigencia( tdFechaVigencia, tcListaDePrecios, tlNoVerificarCalculadaAlMomento, tcListaActual )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia( tdFechaVigencia as Date, tcListaDePrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String
		return this.oDinEstructuraAdn.ObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia( tdFechaVigencia, tcListaDePrecios, tlNoVerificarCalculadaAlMomento, tcListaActual )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFuncionPrecioRealDelStockConVigencia( tdFechaVigencia as Date, tcListaDePrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String
		return this.oDinEstructuraAdn.ObtenerFuncionPrecioRealDelStockConVigencia( tdFechaVigencia, tcListaDePrecios, tlNoVerificarCalculadaAlMomento, tcListaActual )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerWhereConsultaPrecios() as String
		return this.oDinEstructuraAdn.ObtenerWhereConsultaPrecios()
	endfunc

	*------------------------------------------------------------------------------------
	Function ObtenerWhereVigenciaConsultaPrecios( tdFechaVigencia as Date, tcLista as String ) as String
		return this.oDinEstructuraAdn.ObtenerWhereVigenciaConsultaPrecios( tdFechaVigencia, tcLista )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerAgrupamientoyOrdenConsultaPrecios() as String
		return this.oDinEstructuraAdn.ObtenerAgrupamientoyOrdenConsultaPrecios()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerWhereArticuloDeProveedor() as Void
		return this.oDinEstructuraAdn.ObtenerWhereArticuloDeProveedor()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstructuraPrecios() as Void
		return this.oDinEstructuraAdn.ObtenerEstructuraPrecios()
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerTablasConsultaPrecios() as String
		return this.oDinEstructuraAdn.ObtenerTablasConsultaPrecios()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTablasParticipantes() as String
		return this.oDinEstructuraAdn.ObtenerTablasParticipantes()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTablasStockCombinacion() as String
		return this.oDinEstructuraAdn.ObtenerTablasStockCombinacion()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCampoClavePrimariaParticipantes() as String
		return this.oDinEstructuraAdn.ObtenerCampoClavePrimariaParticipantes()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCampoClaveArticulo() as String
		return this.oDinEstructuraAdn.ObtenerCampoClaveArticulo()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLeftJoinsCombinacion() as String
		return this.oDinEstructuraAdn.ObtenerLeftJoinsCombinacion()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLeftJoinsCombinacionPrecios() as String
		return this.oDinEstructuraAdn.ObtenerLeftJoinsCombinacionPrecios()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAnchoAtributoPK( tcEntidad as String ) as Number
		local lnLongitud as Numberm, lnId as Number, loColAtributosPk as zoocoleccion OF zoocoleccion.prg

		loColAtributosPk = this.oDinEstructuraAdn.ObtenerColeccionAtributosPk()

		lnLongitud = 0
		with this
			if loColAtributosPk.Count > 0
				lnId = loColAtributosPk.GetKey( Alltrim( Upper( tcEntidad ) ) )
				if lnId > 0
					lnLongitud = val( loColAtributosPk.item[ lnId ] )
				endif
			endif
		endwith
				
		loColAtributosPk = null
		return lnLongitud

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSelectStockArticulo() as String
		return this.oDinEstructuraAdn.ObtenerSelectStockArticulo()
	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerWhereStockArticulo() as String
		return this.oDinEstructuraAdn.ObtenerWhereStockArticulo()
	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerTablasStockArticulo() as String
		return this.oDinEstructuraAdn.ObtenerTablasStockArticulo()
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerSelectStockArticuloCombinacionConPrecios( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String
		return this.oDinEstructuraAdn.ObtenerSelectStockArticuloCombinacionConPrecios( tdFechaVigencia, tcListaPrecios, tlNoVerificarCalculadaAlMomento, tcListaActual )
	EndFunc
	*-----------------------------------------------------------------------------------------
	Function ObtenerSelectStockArticuloCombinacion() as String
		return this.oDinEstructuraAdn.ObtenerSelectStockArticuloCombinacion()
	EndFunc
	*------------------------------------------------------------------------------------
	Function ObtenerWhereStockArticuloCombinacion() as String
		return this.oDinEstructuraAdn.ObtenerWhereStockArticuloCombinacion()	
	endfunc
	*-----------------------------------------------------------------------------------------
	Function ObtenerTablasStockArticuloCombinacion() as String
		return this.oDinEstructuraAdn.ObtenerTablasStockArticuloCombinacion()
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerSentenciaInsertAtributosArticulos( tcCursor as String ) as String
		return this.oDinEstructuraAdn.ObtenerSentenciaInsertAtributosArticulos( tcCursor )
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerSentenciaInsertAtributosCombinacion( tcCursor as String ) as String
		return this.oDinEstructuraAdn.ObtenerSentenciaInsertAtributosCombinacion( tcCursor )
	EndFunc

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionEntidadesConMotivo() as Object
		return this.oDinEstructuraAdn.ObtenerColeccionEntidadesConMotivo()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionEntidadesConOrigenDestino() as Object
		return this.oDinEstructuraAdn.ObtenerColeccionEntidadesConOrigenDestino()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadesMenuPrincipalItems( tnDataSessionId as Integer ) as string
		local lcXML as string, lnDataSession as Integer

		lnDataSession = this.DataSessionId

		set datasession to ( tnDataSessionId )
		
		if !used( this.cCursorEntidadesMenu )
			lcXML = this.oDinEstructuraAdn.ObtenerEntidadesMenuPrincipalItems()
			xmltocursor( lcXml, this.cCursorEntidadesMenu, 4 ) 			
		endif
		
		set datasession to ( lnDataSession )	
		return this.cCursorEntidadesMenu
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerCursorConFuncionalidades( tnDataSessionId as Integer ) as string
		local lcXML as string, lnDataSession as Integer

		lnDataSession = this.DataSessionId

		set datasession to ( tnDataSessionId )
		
		if !used( this.cCursorFuncionalidades )
			lcXML = this.ObtenerFuncionalidades()
			xmltocursor( lcXml, this.cCursorFuncionalidades, 4 ) 			
		endif
		set datasession to ( lnDataSession )	
		return this.cCursorFuncionalidades
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAtributosCombinacionDeStock() as String 
		return this.oDinEstructuraAdn.ObtenerCamposAtributosCombinacionDeStock()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAtributosCombinacionConcatenados() as String 
		return this.oDinEstructuraAdn.ObtenerCamposAtributosCombinacionConcatenados()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosDeFiltrosDeDescuentos() as String 
		return this.oDinEstructuraAdn.ObtenerAtributosDeFiltrosDeDescuentos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValidacionesDeFiltrosDeDescuentos() as String 
		return this.oDinEstructuraAdn.ObtenerValidacionesDeFiltrosDeDescuentos()
	endfunc 

enddefine
