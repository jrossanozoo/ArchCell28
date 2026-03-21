define class ColaboradorCalculoDePrecios as ZooSession of ZooSession.prg

	#IF .f.
		Local this as ColaboradorCalculoDePrecios of ColaboradorCalculoDePrecios.prg
	#ENDIF

	ImportarSinTransaccion = .F.
	cNombreEntidad = ""
	cCamposDeCombinacionConcatenados = ""
	UsaCombinacion = .F.
	oFormula = null
	llHuboErroresAlActualizarPrecios = .F.
	oColCamposABorrar = null	
	oEntidadPadre = null
	oEntidadPrecioDeArticulo = null
	lHayPreciosNegativos = .F.
	lUsarPreciosConVigencia = .F.
	
	*-------------------------------------------------------------------
	Function Init() as Boolean
		DoDefault()
		this.lUsarPreciosConVigencia = goParametros.Felino.Precios.UsarPreciosConVigencia
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function cCamposDeCombinacionConcatenados_Access() as String
		if !this.lDestroy and empty( this.cCamposDeCombinacionConcatenados )
			this.cCamposDeCombinacionConcatenados = this.ObtenerCamposDeCombinacionConcatenados()
		endif
		return this.cCamposDeCombinacionConcatenados
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposDeCombinacionConcatenados() as String
		local lcRetorno as String
		lcRetorno = goServicios.Estructura.ObtenerSentenciaInsertAtributosCombinacion( sys(2015) )
		lcRetorno = substr( lcRetorno, at( "(", lcRetorno ) + 1, at( ")", lcRetorno ) - 2 )
		lcRetorno = strtran( lcRetorno, ",", "+" )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function oFormula_Access() as entidad of entidad.prg
		if !this.lDestroy and vartype( this.oFormula ) # "O"
			this.oFormula = _screen.Zoo.InstanciarEntidad( "Formula" )
		endif
		return this.oFormula
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oEntidadPrecioDeArticulo_Access() as entidad of entidad.prg
		if !this.lDestroy and vartype( this.oEntidadPrecioDeArticulo ) # "O"
			this.oEntidadPrecioDeArticulo = _screen.Zoo.InstanciarEntidad( "PrecioDeArticulo" )
		endif
		return this.oEntidadPrecioDeArticulo
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarCambioDePreciosParaLista( toColListasACalcularPrecio as ZooColeccion OF ZooColeccion.prg, txCodigo as Variant, tcProveedor as String ) as Boolean
		local lcCursor as String, lcFormula as String, lcListaDePrecios as String, llRetorno as Boolean
		llRetorno = .T.
		with this
			.llHuboErroresAlActualizarPrecios = .F.
			for each loItem in toColListasACalcularPrecio foxobject
				if !.llHuboErroresAlActualizarPrecios
					this.oColCamposABorrar = _screen.Zoo.CrearObjeto( "ZooColeccion" )
					lcFormula = loItem.Formula
					lcListaDePrecios = loItem.ListaDePrecios
					lcCursor = .ObtenerConsultaPrecios( lcListaDePrecios, lcFormula, tcProveedor )
					.ActualizarCamposParaVigencia(lcCursor, lcListaDePrecios)
					.AplicarActualizaciones( lcCursor, lcFormula, lcListaDePrecios )
					this.EliminarNuevoCampoTemporal( lcCursor )
					if !.lHayPreciosNegativos 
						.Serializar_E_Importar( lcCursor, txCodigo )
						.lHayPreciosNegativos = .F.
					else
						llRetorno = .F.
					endif
					use in select( lcCursor )
					this.oColCamposABorrar.Release()
				else
					llRetorno = .F.

				endif
			endfor
		endwith
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarNuevoCampoTemporal( tcCursor as String, tcNuevoCampo as String ) as Void
		local loItem as Object
		for each loItem in this.oColCamposABorrar foxobject
			select &tcCursor
			alter table &tcCursor drop column ( loItem )
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Serializar_E_Importar( tcCursor as String, txCodigo as Variant ) as Void
		local loSimuladorImportacion as Object, loSimuladorDisenoImpo as Object, lcXmlParametro as String, lnCodigo as Integer 
		local lnCantidadImportar as Integer, lnTamanioSegmento as Integer, lcCursorSegmento as String, lnInicioSegmento as Integer, lnFinSegmento as Integer, lntotal as Integer
		local lcIdentificadorEntidad as String 
		
		loSimuladorImportacion = newobject( "SimuladorImportacion" )
		loSimuladorDisenoImpo = newobject( "SimuladorDisenoImpo" )
		loSimuladorDisenoImpo.oColSubAreas = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		select ( tcCursor )
		Replace all DescFW with Transform( txCodigo )
		lcIdentificadorEntidad  = goServicios.Entidades.ObtenerIdentificadorDeEntidad( this.cNombreEntidad )
		replace all EntOri with lcIdentificadorEntidad
		lcCodigo = this.CambiarCodigoOrigen( txCodigo )
		replace all CodOri with lcCodigo
		
		if type( "this.oEntidadPadre" ) = "O"
			this.CompletarDatosDeEntidadPadre()
		endif 		

		this.EventoComienzoImportacion()
		
		lnCantidadImportar = reccount( tcCursor )
		lnTamanioSegmento = goServicios.Registry.Nucleo.CantidadDeElementosEnSegmentoAImportar
		lntotal = ceiling( lnCantidadImportar / lnTamanioSegmento )

		for lnI = 1 to lntotal 
			
			this.EventoImportandoEtapa( lnI, lntotal )
			
			lcCursorSegmento = sys(2015)
			lnInicioSegmento = ( lnTamanioSegmento * ( lnI - 1 ) ) + 1
		 	lnFinSegmento = lnTamanioSegmento * lnI 
			
			select * from &tcCursor. where between( recno(), lnInicioSegmento, lnFinSegmento ) into cursor &lcCursorSegmento.
			
			lcXmlParametro = loSimuladorImportacion.ObtenerDatosAImportar( loSimuladorDisenoImpo, lcCursorSegmento )
			This.ImportarPrecioDeArticulo( lcXmlParametro )
			
			use in ( lcCursorSegmento )
		endfor
		
		loSimuladorImportacion.Release()

		this.EventoFinImportacion()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoComienzoImportacion() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoImportandoEtapa( tnEtapa as Integer, tntotal as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinImportacion() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CambiarCodigoOrigen( txCodigo as Variant ) as Variant
		local lcCodigo as string

		if type( "txCodigo" ) = "N"
			lcCodigo = transform( txCodigo )
		else
			lcCodigo = txCodigo
		endif
		return lcCodigo
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompletarDatosDeEntidadPadre() as Void
		replace all FechaVig with this.ObtenerFechaBaseParaVigencia()
		replace all FAltaFW with this.oEntidadPadre.FechaAltaFW   
		replace all TimestampA with goServicios.Datos.ObtenerTimestamp()
		replace HAltaFW with this.oEntidadPadre.HoraAltaFW
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ImportarPrecioDeArticulo( tcXml as String ) as void
		with this.oEntidadPrecioDeArticulo
			.cPrefijoImportar = "c_Imp"
			.cContexto = "I"
			if This.ImportarSinTransaccion
				try
					.Importar_SinTransaccion( tcXml )
				catch
					this.AgregarInformacion( "Ocurrió un error durante el proceso. "+;
					 "Revise el log para mayor información." ) 
					goServicios.Errores.LevantarExcepcion( this.ObtenerInformacion() )
				endtry
			else
				.Importar( tcXml )
			Endif	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerConsultaPrecios( tcListaDePrecios as String, tcFormula as String, tcProveedor as String ) as String
		local lcCursor as String, lcCursorPrecioArticulo as String, lcCursorStock as String, lcRetorno as String, lcCursorPrecioArticuloVacio as String
		lcRetorno = sys( 2015 )
		lcRetorno = this.ObtenerCursorPreciosDeArticulo( tcListaDePrecios, tcProveedor )

		this.AgregarPreciosDeListasIncluidasEnLaFormula( lcRetorno, tcFormula, tcListaDePrecios, tcProveedor )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function UnirCursores( tcCursorPrecioArticulo as String, tcCursorStock as String, tcListaDePrecio as String) as String
		local lcArticulosFaltantes as String, lcCampo as String, lnTimestampA as Integer, ldFechaVigencia as Date  
		lcCampo = this.cCamposDeCombinacionConcatenados
		lcArticulosFaltantes = sys(2015)
		lnTimestampA = goServicios.Datos.ObtenerTimestamp()
		ldFechaVigencia = date()	

		select * ;
			from &tcCursorStock ;	
			where &lcCampo not in ( select &lcCampo from &tcCursorPrecioArticulo ) ;
			into cursor ( lcArticulosFaltantes ) readwrite
 		
		Replace all ListaPre with tcListaDePrecio, FechaVig with ldFechaVigencia, FechaVig with ldFechaVigencia, Codigo with transform( lnTimestampA ) + tcListaDePrecio+&lcCampo in ( lcArticulosFaltantes )

		insert into &tcCursorPrecioArticulo select * from  &lcArticulosFaltantes 
			
		return tcCursorPrecioArticulo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorPreciosDeArticulo( tcListaDePrecios as String, tcProveedor as String ) as String
		local lcCursor as String, lcSelect as String, lcOrder As String, lcTablas as String, lcConsulta as String
		lcCursor = sys( 2015 )
		lcSelect = goServicios.Estructura.ObtenerSelectConsultaPrecios( this.ObtenerFechaBaseParaVigencia(), tcListaDePrecios )
		if !empty( tcProveedor )
			lcSelect = lcSelect + goServicios.Estructura.ObtenerWhereArticuloDeProveedor() + "=[" + alltrim( tcProveedor ) + "]"
		endif
		lcOrder =  goServicios.Estructura.ObtenerAgrupamientoyOrdenConsultaPrecios() 		
		lcTablas = goServicios.Estructura.ObtenerTablasConsultaPrecios()
		lcConsulta = strtran( strtran( lcSelect, "[", "'" ), "]", "'" ) + lcOrder 
		lcCursor = this.ObtenerCursorRetorno( tcListaDePrecios, lcConsulta, lcTablas )	
			
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorRetorno( cListaDePrecios as String, tcConsulta as String, tcTablas as String ) as String
		local lcRetorno as String, lcWhere as string, lcConsulta as String, lcCursorTemporal as String  
		lcRetorno = sys( 2015 )
		lcCursorTemporal = sys( 2015 )
		
		lcConsulta = goServicios.Estructura.ObtenerEstructuraPrecios()
		goServicios.Datos.EjecutarSentencias( lcConsulta, tcTablas, "", lcCursorTemporal , This.DataSessionId )
		goServicios.Datos.EjecutarSentencias( tcConsulta, tcTablas, "", lcRetorno, This.DataSessionId )

		if used( lcCursorTemporal ) and used( lcRetorno )
			select ( lcCursorTemporal )
			append from (dbf( lcRetorno ))
		endif		
		return lcCursorTemporal  
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorStock( tcCursorPrecioArticuloVacio as String ) as String
		local lcCursor as String
		if This.UsaCombinacion                          
			lcCursor = this.ObtenerCursorStockArticuloCombinacion( tcCursorPrecioArticuloVacio )
		else 
			lcCursor = this.ObtenerCursorStockArticulo( tcCursorPrecioArticuloVacio )
		endif
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorStockArticulo( tcCursorPrecioArticuloVacio as String  ) as String
		local lcCursor as String, lcSelect as String, lcWhere As String, lcTablas as String, lcConsulta as String, lcCampo as String
		lcCursor = sys( 2015 )
		lcSelect = goServicios.Estructura.ObtenerSelectStockArticulo()
		lcTablas = goServicios.Estructura.ObtenerTablasStockArticulo()
		
		lcConsulta = strtran( lcSelect, "[", "'" )
		lcConsulta = strtran( lcConsulta, "]", "'" )

		goServicios.Datos.EjecutarSentencias( lcConsulta, lcTablas, "", lcCursor, This.DataSessionId )

		lcCampo = goServicios.Estructura.ObtenerSentenciaInsertAtributosArticulos( lcCursor )
		lcSql= "insert into &tcCursorPrecioArticuloVacio " + lcCampo 
	
		select ( lcCursor )		
		scan
			&lcSql	
		endscan
		use in select( lcCursor )
		return tcCursorPrecioArticuloVacio
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorStockArticuloCombinacion( tcCursorPrecioArticuloVacio as String  ) as String
		local lcCursor as String, lcSelect as String, lcWhere As String, lcTablas as String, lcConsulta as String, lcCampo as String

		lcCursor = sys( 2015 )
		lcSelect = goServicios.Estructura.ObtenerSelectStockArticuloCombinacion()
		lcTablas = goServicios.Estructura.ObtenerTablasStockArticuloCombinacion()
		
		lcConsulta = strtran( lcSelect , "[", "'" )
		lcConsulta = strtran( lcConsulta, "]", "'" )
		goServicios.Datos.EjecutarSentencias( lcConsulta, lcTablas, "", lcCursor, This.DataSessionId )

		lcCampo = goServicios.Estructura.ObtenerSentenciaInsertAtributosCombinacion( lcCursor )
		lcSql= "insert into &tcCursorPrecioArticuloVacio " + lcCampo 

		select ( lcCursor )		
		scan
			&lcSql	
		endscan
		use in select( lcCursor )
		return tcCursorPrecioArticuloVacio
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablaCampo( tcEntidad as String, tcAtributo as String  ) as String
		local lcRetorno as String, lcCursor as String
		lcCursor = sys( 2015 )
		goServicios.Estructura.ObtenerCursorEstructuraAdn( This.DataSessionId , lcCursor )
		select &lcCursor
		locate for	upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) and ;
					upper( alltrim( Atributo ) ) == upper( alltrim( tcAtributo ) )
		lcRetorno = alltrim( Tabla ) + "." + alltrim( Campo )
		use in select( lcCursor )
		return lcRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AplicarActualizaciones( tcCursor as String, tcCodigoFormula as string, tcListaDePrecio as String ) as Void
		local lcListaPrecio As String, lnValor as Float, lcListaPrecio_A as String, lcExpresion as String, lnLen as Integer, loError as zooexception OF zooexception.prg, ;
			lnPrecioAnterior as Double, lcMensajeALoguear as String, loFormula as Object
		lnLen = len( &tcCursor..ListaPre )
		with this.oFormula
			.Codigo = tcCodigoFormula
			lcExpresion = .ObtenerExpresionaevaluar()
			select ( tcCursor )
			scan for ListaPre = tcListaDePrecio
				try
					lnPrecioAnterior = PDirecto
					if &lcExpresion < 0
						this.lHayPreciosNegativos = .T. 
						this.llHuboErroresAlActualizarPrecios = .t.
						go bottom
					endif
					replace PDirecto with &lcExpresion in ( tcCursor )
				catch to loError
					replace PDirecto with lnPrecioAnterior in ( tcCursor )
					this.llHuboErroresAlActualizarPrecios = .t.
				endtry
			endscan
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarPreciosDeListasIncluidasEnLaFormula( tcCursorPrecioArticulo as String, tcCodigoFormula as String, tcListaDePreciosAActualizar as String, tcProveedor as String ) as void
		local loMapeosDeListasDePrecios as zoocoleccion OF zoocoleccion.prg, loFormula as Object, loMapeo as String, lcNuevoCampo as String
		this.oFormula.Codigo = tcCodigoFormula
		loFormula = this.oFormula
		loMapeosDeListasDePrecios = loFormula.ObtenerMapeosDeListasDePrecios()
		for each loMapeo in loMapeosDeListasDePrecios
			lcNuevoCampo = sys( 2015 )
			this.AgregarNuevoCampoParaPrecio( tcCursorPrecioArticulo, lcNuevoCampo )
			this.AgregarMapeoDeFuncionPrecioDeLista( loMapeo, tcCursorPrecioArticulo + "." + lcNuevoCampo )
			this.CompletarCampoParaPrecio( tcCursorPrecioArticulo, lcNuevoCampo, loMapeo.ElementoDeLaFormula, tcListaDePreciosAActualizar, tcProveedor )
			this.oColCamposABorrar.Agregar( lcNuevoCampo )			
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarMapeoDeFuncionPrecioDeLista( toMapeo as Object, tcElementoAEvaluar as String ) as Void
		toMapeo.ElementoAEvaluar = tcElementoAEvaluar
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarNuevoCampoParaPrecio( tcCursorPrecioArticulo as String, tcNuevoCampo as String ) as void
		local laEstructuraDelCursor[ 1, 1 ], lcCampo as String, lnElementoDelCampo as Integer, lcTipoDeDato as String, lnLongitud as Integer, lnNumeroDeDecimales as Integer, ;
			lcComandoDeCreacionDeCampo as String
		lcCampo = "PDirecto"
		afields( laEstructuraDelCursor, tcCursorPrecioArticulo )
		lnElementoDelCampo = ascan( laEstructuraDelCursor, lcCampo, 1, alen( laEstructuraDelCursor, 0 ), 0, 1 )
		lcTipoDeDato = laEstructuraDelCursor[ lnElementoDelCampo + 1 ]
		lnLongitud = laEstructuraDelCursor[ lnElementoDelCampo + 2 ]
		lnNumeroDeDecimales = laEstructuraDelCursor[ lnElementoDelCampo + 3 ]
		lcComandoDeCreacionDeCampo = "alter table " + tcCursorPrecioArticulo + " add column " + tcNuevoCampo + " " + lcTipoDeDato + "( " + transform( lnLongitud ) + "," + transform( lnNumeroDeDecimales ) + " )"
		&lcComandoDeCreacionDeCampo
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompletarCampoParaPrecio( tcCursorPrecioArticulo as String, tcNuevoCampo as String, tcListaDePrecios as String, tcListaDePreciosAActualizar as String, tcProveedor as String ) as void
		local lcCursor as String, lcCampo as String, lcCamposDeCombinacionConcatenados as String, lcCombinacionABuscar as String, lcIndexar as String, ;
			lcCamposDeCombinacionSeparadosPorComas as String, lcInsertDePreciosParaCombinacionesFaltantes as String


			lcCursor = this.ObtenerCursorPreciosDeArticulo( tcListaDePrecios, tcProveedor )

			lcCamposDeCombinacionSeparadosPorComas = goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
			lcCamposDeCombinacionConcatenados = this.cCamposDeCombinacionConcatenados

			lcInsertDePreciosParaCombinacionesFaltantes = "insert into " + tcCursorPrecioArticulo ;
				+ "  ( " + lcCamposDeCombinacionSeparadosPorComas + ", listapre ) " ;
				+ " select " + lcCamposDeCombinacionSeparadosPorComas + ", '" + tcListaDePreciosAActualizar + "' as listapre " ;
				+ "  from " + lcCursor ;
				+ "  where " + lcCamposDeCombinacionConcatenados + " not in ( select " + lcCamposDeCombinacionConcatenados + " from " + tcCursorPrecioArticulo + " )"
			&lcInsertDePreciosParaCombinacionesFaltantes

			select ( lcCursor ) 
			lcIndexar = 'index on ' + strtran( goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados(), ", ", " + " ) + ' tag "Codigo"'
			&lcIndexar 
			select ( tcCursorPrecioArticulo )
			scan all
				lcCombinacionABuscar = &lcCamposDeCombinacionConcatenados.
				select ( lcCursor )
				seek lcCombinacionABuscar in ( lcCursor )
				if found( lcCursor )
					replace &tcNuevoCampo with nvl(&lcCursor..PDirecto,0) in ( tcCursorPrecioArticulo )
				endif
				select ( tcCursorPrecioArticulo )
			endscan
			
			use in select( lcCursor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		this.oEntidadPadre = toEntidad
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFechaBaseParaVigencia( toItem as Object ) as Date
		local ldRetorno as Date 

		if type( "this.oEntidadPadre" ) = "O" and pemstatus( this.oEntidadPadre, "ObtenerFechaBaseParaVigencia", 5)
			ldRetorno = this.oEntidadPadre.ObtenerFechaBaseParaVigencia()
		else 
			ldRetorno = date()
		endif 
		
		return ldRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarCamposParaVigencia( tcCursor as String, tcListaDePrecio as String ) as Void
		local lcCampo as String, lnTimestampA as Integer, ldFechaVigencia as Date 
		lcCampo = this.cCamposDeCombinacionConcatenados
		lnTimestampA = goServicios.Datos.ObtenerTimestamp()
		ldFechaVigencia = date()		
		if this.lUsarPreciosConVigencia
			replace all TimestampA with lnTimestampA, FechaVig with ldFechaVigencia in ( tcCursor )
		endif
		Replace all ListaPre with tcListaDePrecio, FechaVig with ldFechaVigencia, Codigo with transform( TimestampA ) + " " + tcListaDePrecio+&lcCampo in ( tcCursor )	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function Destroy() As void
		This.oEntidadPadre = Null
		DoDefault()
	Endfunc		

enddefine

*--------------------------------------------------------------------------------------------
define class SimuladorImportacion as MapeadorDatosImportacion of MapeadorDatosImportacion.prg

	DataSession = 1

	*-----------------------------------------------------------------------------------------
	function AntesDePoblarTablaAImportar( toColTablas ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDePoblarTablaAImportar( toColTablas ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PoblarTablaAImportar( toDiseno as Object, tcXMLMapeo As String, toColTablasDestino as Collection ) as Void
		&&tcXmlMapeo aca va a ser el cursor que cree en ObtenerconsultaPrecios
		local lcTabla as String
		lcTabla = This.cPrefijoTabla + toDiseno.Entidad
		select &lcTabla
		delete all
		append From dbf( tcXmlMapeo )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class SimuladorDisenoImpo as Custom
	Entidad = "PRECIODEARTICULO"
	oColSubAreas = Null
enddefine
