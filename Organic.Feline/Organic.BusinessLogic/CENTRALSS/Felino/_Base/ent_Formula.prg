define class Ent_Formula as Din_EntidadFormula of Din_EntidadFormula.prg

	#IF .f.
		Local this as ent_Formula of Ent_Formula.prg
	#ENDIF

	protected nSesionDeDatosOriginal as Integer

	oAnalizadorDeFunciones = null
	oListaDePrecios = null
	oRedondeo = null
	nSesionDeDatosOriginal = 0
	oMoneda = null
	oArticulo = null
	oColaboradorFormulasYListasDePrecios = null
	oColaboradorCalculoDePrecios = null
	oManagerPropiedadesDeBaseDeDatos = null
	lContinuaProcesando = .T.
	lGrabarProcesandoCambioDePreciosParaListasRelacionadas = .t.

	*-------------------------------------------------------------------------------------------------
	Function Init( t1, t2, t3, t4 ) As Boolean
		dodefault( t1, t2, t3, t4 )
		this.nSesionDeDatosOriginal = this.DataSessionId
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oManagerPropiedadesDeBaseDeDatos_Access() as Object
		with this
			if !this.ldestroy and ( !vartype( .oManagerPropiedadesDeBaseDeDatos ) = 'O' or isnull( .oManagerPropiedadesDeBaseDeDatos ) )
				.oManagerPropiedadesDeBaseDeDatos = _Screen.Zoo.CrearObjeto( "ManagerPropiedadesDeBaseDeDatos" )
			endif
		endwith
		return this.oManagerPropiedadesDeBaseDeDatos 
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorFormulasYListasDePrecios_Access() as Object
		with this
			if !this.ldestroy and ( !vartype( .oColaboradorFormulasYListasDePrecios ) = 'O' or isnull( .oColaboradorFormulasYListasDePrecios ) )
				.oColaboradorFormulasYListasDePrecios = _Screen.Zoo.CrearObjeto( "ColaboradorFormulasYListasDePrecios" )
			endif
		endwith
		return this.oColaboradorFormulasYListasDePrecios
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorCalculoDePrecios_Access() as Object
		with this
			if !this.ldestroy and ( !vartype( .oColaboradorCalculoDePrecios ) = 'O' or isnull( .oColaboradorCalculoDePrecios ) )
				.oColaboradorCalculoDePrecios = _Screen.Zoo.CrearObjetoPorProducto( "ColaboradorCalculoDePrecios" )
				with .oColaboradorCalculoDePrecios
					.DataSessionId = this.DataSessionId
					.ImportarSinTransaccion = .F.
					.cNombreEntidad = this.cNombre
					.UsaCombinacion = .T.
					.oFormula = this
				endwith
			endif
		endwith
		return this.oColaboradorCalculoDePrecios
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oAnalizadorDeFunciones_Access() as Object
		if !this.lDestroy and ( vartype( this.oAnalizadorDeFunciones) # "O" or !( this.Expresion == this.oAnalizadorDeFunciones.cExpresion ) )
			this.CrearAnalizadorDeFunciones()
		endif
		return this.oAnalizadorDeFunciones
	endfunc

	*-----------------------------------------------------------------------------------------
	function oRedondeo_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oRedondeo ) # "O"
			this.oRedondeo = _screen.Zoo.InstanciarEntidad( "RedondeoDePrecios" )
		endif
		return this.oRedondeo
	endfunc

	*-----------------------------------------------------------------------------------------
	function oListaDePrecios_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oListaDePrecios) # "O"
			this.oListaDePrecios= _screen.Zoo.InstanciarEntidad( "ListaDePrecios" )
		endif
		return this.oListaDePrecios
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oMoneda_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oMoneda ) # "O"
			this.oMoneda = _screen.Zoo.InstanciarEntidad( "Moneda" )
		endif
		return this.oMoneda
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerMapeosDeListasDePrecios() as zoocoleccion OF zoocoleccion.prg
		return this.oAnalizadorDeFunciones.oColMapeoDeListasDePreciosDeLaFormula
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigosDeListasDePrecios() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loMapeo as Object
		loRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loMapeo in this.oAnalizadorDeFunciones.oColMapeoDeListasDePreciosDeLaFormula
			loRetorno.Agregar( loMapeo.ElementoDeLaFormula )
		endfor
		return loRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigosDeRedondeos() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loMapeo as Object
		loRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loMapeo in this.oAnalizadorDeFunciones.oColMapeoDeRedondeoDeLaFormula
			loRetorno.Agregar( loMapeo.ElementoDeLaFormula )
		endfor
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerParametrosDeCotizaciones() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loMapeo as Object
		loRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loMapeo in this.oAnalizadorDeFunciones.oColMapeoDeCotizacionDeLaFormula
			loRetorno.Agregar( loMapeo )
		endfor
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerExpresionAEvaluar() as String
		local lcRetorno as String
		lcRetorno = this.ReemplazarElementosVariablesDeLaFormula()
		lcRetorno = this.ObtenerExpresionSinCaracteresNoValidos( lcRetorno )
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PrecioDeLista( tnPrecioDeLista as Double ) as Void
		return tnPrecioDeLista
	endfunc

	*-----------------------------------------------------------------------------------------
	function oArticulo_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oArticulo ) # "O"
			this.oArticulo = _screen.Zoo.InstanciarEntidad( "Articulo" )
		endif
		return this.oArticulo
	endfunc

	*-----------------------------------------------------------------------------------------
	function FactorIvaArticulo( tcTipoIva as string, tcIdArticulo as string ) as Double
		&& funcion que respeta regla de negocios dominio COMBOCONDICIONIVA
		local lnFactor as Double, lnPorcentaje as Double, lnCondicion as Integer
		lnPorcentaje = 0
		try
			with this.oArticulo
				if .codigo != rtrim( tcIdArticulo )
					.codigo = rtrim( tcIdArticulo )
				endif
				if upper(tcTipoIva) = "COMPRA"
					lnCondicion = .CondicionIvaCompras
					lnPorcentaje = .PorcentajeIvaCompras					
				else
					lnCondicion = .CondicionIvaVentas
					lnPorcentaje = .PorcentajeIvaVentas
				endif
				do case
					case lnCondicion = 1 && por Default es el 21 %
						lnPorcentaje = goParametros.Felino.DatosImpositivos.IvaInscriptos
					case lnCondicion = 4 && por lo generar el 10,5%
						lnPorcentaje = goParametros.Felino.DatosImpositivos.IvaAlicuotaReducida
					case lnCondicion = 3 && % personalizado
					otherwise && No Gravado
						lnPorcentaje = 0
				endcase
			endwith 
		catch to loError
			lnPorcentaje = -100
		finally
			lnFactor = 1 + ( lnPorcentaje /100 )
		endtry
		
		return lnFactor 
	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Redondeo( tnMonto as Double, tcCodigoDeRedondeo as String ) as Void

		if vartype( tcCodigoDeRedondeo ) # "C"
			this.oRedondeo.Codigo = tcCodigoDeRedondeo
		else
			if this.oRedondeo.Codigo != tcCodigoDeRedondeo
				this.oRedondeo.Codigo = tcCodigoDeRedondeo
			endif
		endif
		return this.oRedondeo.Redondear( tnMonto )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Cotizacion( tdFecha as Date, tcMoneda as String ) as Double
		local lnCotizacion as Double
		lnCotizacion = this.oMoneda.ObtenerCotizacionVigente( tdFecha, tcMoneda, goParametros.Felino.Generales.MonedaSistema )
		return lnCotizacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambiarSesionDeDatos( tnSesionDeDatos as Integer ) as Void
		this.DataSessionId = tnSesionDeDatos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RestaurarSesionDeDatos() as Void
		this.DataSessionId = this.nSesionDeDatosOriginal
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		Local llRetorno as boolean, llVotacion as boolean
		llRetorno = .t.
		llRetorno = dodefault()
		With This
			llRetorno = .ValidarExistenciaDeListasDePrecios( this ) and llRetorno
			llRetorno = .ValidarExistenciaDeRedondeos( this ) and llRetorno
			llRetorno = .ValidarExistenciaDeCotizaciones( this ) and llRetorno
		endwith
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeListasDePrecios( toEntidadQueSolicitaLaValidacion as entidad OF entidad.prg ) as Boolean
		local i as Integer, llRetorno as Boolean, loListasDePrecios as zoocoleccion OF zoocoleccion.prg, lcListaDePrecios as String
		llRetorno = .t.
		loListasDePrecios = this.ObtenerCodigosDeListasDePrecios()
		for each lcListaDePrecios in loListasDePrecios
			 llRetorno = goServicios.Datos.ValidarExistenciaEnEntidad( this.oListaDePrecios, lcListaDePrecios, toEntidadQueSolicitaLaValidacion ) and llRetorno
		endfor
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeRedondeos( toEntidadQueSolicitaLaValidacion as entidad OF entidad.prg ) as Boolean
		local i as Integer, llRetorno as Boolean, loRedondeos as zoocoleccion OF zoocoleccion.prg, lcRedondeo as String
		llRetorno = .t.
		loRedondeos = This.ObtenerCodigosDeRedondeos()
		for each lcRedondeo in loRedondeos
			 llRetorno = goServicios.Datos.ValidarExistenciaEnEntidad( this.oRedondeo, lcRedondeo, toEntidadQueSolicitaLaValidacion ) and llRetorno
		endfor
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeCotizaciones( toEntidadQueSolicitaLaValidacion as entidad OF entidad.prg ) as Boolean
		local i as Integer, llRetorno as Boolean, loParametrosDeCotizaciones as zoocoleccion OF zoocoleccion.prg, loParametro as String, lnCotizacion as Integer, ;
			lcSetCenturyAnterior as String, lcCentury as String, loError as zooexception OF zooexception.prg, ldFecha as Date
		llRetorno = .t.
		loParametrosDeCotizaciones = This.ObtenerParametrosDeCotizaciones()
		for each loParametro in loParametrosDeCotizaciones
			llRetorno = goServicios.Datos.ValidarExistenciaEnEntidad( this.oMoneda, loParametro.Moneda, toEntidadQueSolicitaLaValidacion ) and llRetorno
			if llRetorno
				this.oMoneda.Codigo = loParametro.Moneda
				if "(" $ loParametro.Fecha
					ldFecha = evaluate( loParametro.Fecha )
				else
					ldFecha = ctod( loParametro.Fecha )
				endif
				lnCotizacion = this.oMoneda.ObtenerCotizacionVigente( ldFecha, loParametro.Moneda, goParametros.Felino.Generales.MonedaSistema )
				if lnCotizacion = 0
					llRetorno = .f.
					try
						lcSetCenturyAnterior = set( "Century" )
						lcCentury = "set century " + iif( goParametros.Dibujante.FormatoParaFecha = 2, "on", "off" )
						&lcCentury
						toEntidadQueSolicitaLaValidacion.AgregarInformacion( "No existen cotizaciones de la moneda (" + alltrim( this.oMoneda.Codigo ) + ") " ;
							+ alltrim( this.oMoneda.Descripcion ) + " para la fecha " + dtoc( ldFecha  ) + "."  )
					catch to loError
						goServicios.Errores.LevantarExcepcion( loError )
					finally
						set century &lcSetCenturyAnterior
					endtry
				 endif
			endif
		endfor
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerExpresionSinCaracteresNoValidos( tcExpresion as String ) as String
		local lcRetorno as String
		lcRetorno = strtran( tcExpresion, chr( 13 ), "" )
		lcRetorno = strtran( lcRetorno, chr( 10 ), "" )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarElementosVariablesDeLaFormula() as String
		local lcRetorno as String, loMapeoDeElementoDeLaFormula as Object
		lcRetorno = this.oAnalizadorDeFunciones.ReemplazarElementosVariablesDeLaFormula()

		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearAnalizadorDeFunciones() as Void
		this.oAnalizadorDeFunciones = _screen.Zoo.CrearObjeto( "AnalizadorDeFunciones", "", this.Expresion )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FormulaUtilizadaEnLista() as Boolean
	local llRetorno as Boolean
		llRetorno = .F.
		llRetorno = this.oColaboradorFormulasYListasDePrecios.FormulaUtilizadaEnLista( this.Codigo )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAnulacion() as Boolean
		local llRetorno as Boolean 
		llRetorno = .T.
		If this.FormulaUtilizadaEnLista()
			this.AgregarInformacion( "La fórmula está utilizada en una lista de precios.", 0 )
			llRetorno = .F.
		endif
		if llRetorno
			llRetorno = dodefault()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosEntidadConMemo() as string
		local lcXml as String, lcRetorno as String, lcCursor as string

		lcCursor = sys( 2015 )

		lcXml = this.ObtenerDatosEntidad( "Codigo, Expresion" )
		this.XmlACursor( lcXml, lcCursor )
		this.oAD.CargarCampoMemo( lcCursor , "Codigo", "Expresion" )
		lcRetorno = this.CursorAXml( lcCursor )
		use in select( lcCursor )

		return lcRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ValidarRecursividad() as Boolean
		local llRetorno
		llRetorno = .T.
		if !this.oColaboradorFormulasYListasDePrecios.ValidarExistenciaDeFormulaEnListaContenida( this.Codigo, this.Expresion )
			llRetorno = .F.
			goServicios.Errores.LevantarExcepcion( "La modificación no podrá realizarse debido a que genera una referencia circular." )
		endif
		llRetorno = llRetorno
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Grabar() as Void
		local llTieneTriggerRecursivo as Boolean, llTieneListasAnidadas as Boolean
		this.lContinuaProcesando = .T.
		if this.lGrabarProcesandoCambioDePreciosParaListasRelacionadas
			llTieneTriggerRecursivo = this.ConsultarTriggersRecursivosEnBaseDeDatos()
			llTieneListasAnidadas = this.ConfirmarDeseaContinuar()
			if !llTieneTriggerRecursivo and llTieneListasAnidadas
				this.EventoMensajeNoPuedeContinuar( "La operación no puede completarse debido a que la propiedad RECURSIVE_TRIGGERS de la base de datos se encuentra deshabilitada y la misma no puede habilitarse. Comuníquese con su administrador de base de datos." )
				this.lContinuaProcesando = .F.
				this.Cancelar()
			else
				if llTieneListasAnidadas
					this.EventoMensajeDeseaContinuar( "Se calcularán los precios de todas las listas que dependan de esta fórmula. El proceso puede demorar unos minutos. ¿Desea Continuar?" )
				endif
				if this.lContinuaProcesando
					try
						this.ValidarRecursividad()
						this.EventoMensajeProcesando( "Calculando precios..." )
						this.ProcesarCambioDePreciosParaListasRelacionadas()
					catch to loError
						goServicios.Errores.LevantarExcepcion( loError )
					finally
						this.EventoFinMensajeProcesando()
					endtry
				else
					this.Cancelar()
				endif
			endif
		endif

		if this.lContinuaProcesando
			dodefault()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ConsultarTriggersRecursivosEnBaseDeDatos() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		llRetorno = this.oManagerPropiedadesDeBaseDeDatos.ConsultarTriggersRecursivosEnBaseDeDatos()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeProcesando( tcMensaje as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinMensajeProcesando() as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeDeseaContinuar( tcMensaje as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeNoPuedeContinuar( tcMensaje as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ConfirmarDeseaContinuar() as Boolean
		local llRetorno as Boolean, loColeccion as zoocoleccion OF zoocoleccion.prg
		llRetorno = .F.
		loColeccion = this.ObtenerColeccionDeListasRelacionadasConFormulaPK()
		llRetorno = ( loColeccion.Count > 0 )
		loColeccion.Release()
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ProcesarCambioDePreciosParaListasRelacionadas() as Void
		local loColListasRelacionadas as ZooColeccion OF ZooColeccion.prg, loItem as Object, llProcesoBien as Boolean
		llProcesoBien = .T.
		loColListasRelacionadas = this.ObtenerColeccionDeListasRelacionadasConFormulaPK()
		for each loItem in loColListasRelacionadas foxobject
			if llProcesoBien
				llProcesoBien = this.ProcesarCambioDePreciosParaLista( loItem.ListaDePrecios, loItem.Proveedor )
			endif
		endfor
		
		if !llProcesoBien
			goServicios.Errores.LevantarExcepcion( "Error en la actualización de precios. Revise que los resultados de la fórmula no sean negativos." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionDeListasRelacionadasConFormulaPK() as ZooColeccion OF ZooColeccion.prg
		local loRetorno as ZooColeccion OF ZooColeccion.prg, loEntidad as Object, lcXml as String, lcCursor as String, loItem as Object
		lcCursor = sys( 2015 )
		loRetorno = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		loEntidad = _Screen.Zoo.InstanciarEntidad( "ListaDePreciosCalculada" )
		lcXml = loEntidad.ObtenerDatosEntidad( "ListaDePrecios,Proveedor", "Formula = '" + upper( alltrim( this.Codigo ) ) + "'" )
		loEntidad.Release()
		xmltocursor( lcXml, lcCursor )
		select * from &lcCursor order by ListaDePrecios,Proveedor into cursor &lcCursor
		select &lcCursor
		scan
			scatter name loItem
			loRetorno.Agregar( loItem )
		endscan
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarCambioDePreciosParaLista( tcListaDePreciosPK as String, tcProveedor as String ) as Boolean
		local loColListasACalcularPrecio as ZooColeccion OF ZooColeccion.prg, loItem as Object, llRetorno as Boolean
		llRetorno = .T.
		loColListasACalcularPrecio = this.oColaboradorFormulasYListasDePrecios.ObtenerColeccionListaUnicaCalcularPrecio( tcListaDePreciosPK, this.Codigo, tcProveedor )
		llRetorno = this.oColaboradorCalculoDePrecios.ProcesarCambioDePreciosParaLista( loColListasACalcularPrecio, this.Codigo, tcProveedor )
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		this.SetearAtributoExprSql()
		return dodefault()
	endfunc

	*-------------------------------------------------------------------------------------------------
	protected function SetearAtributoExprSql() as Void
		this.ExprSql = this.oAnalizadorDeFunciones.ReescribirFuncionFactorIvaArticuloParaSQL( this.oAnalizadorDeFunciones.ReemplazarFuncionesIifPorCaseEnLaFormula( this.Expresion, .f. ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()	
		this.SetearValorLGrabarProcesandoCambioDePreciosParaListasRelacionadas( .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		this.SetearValorLGrabarProcesandoCambioDePreciosParaListasRelacionadas( .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValorLGrabarProcesandoCambioDePreciosParaListasRelacionadas( tlValor ) as Void
		this.lGrabarProcesandoCambioDePreciosParaListasRelacionadas = tlValor
	endfunc 

enddefine
