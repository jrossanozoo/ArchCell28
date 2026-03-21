define class Ent_CalculodePrecios as Din_EntidadCalculodePrecios of Din_EntidadCalculodePrecios.prg

	#if .f.
		local this as Ent_CalculodePrecios of Ent_CalculodePrecios.prg
	#endif

	protected cCamposDeCombinacionConcatenados as String

	ImportarSinTransaccion = .F.
	oListaDePrecios = null
	oRedondeo = null
	cCamposDeCombinacionConcatenados = ""
	cCamposDeCombinacionDeStock = ""
	llHuboErroresAlActualizarPrecios = .f.
	oColaboradorCalculoDePrecios = null
	oColaboradorFormulasYListasDePrecios = null
	oManagerPropiedadesDeBaseDeDatos = null
	oColCamposABorrar = null
	cCursorDefinitivo = ""
	lcListadePrecio = ""
	lcListadePrecioDelItem = ""
	oFactoriaPrePantalla = null
	nCantidadOriginal = 0
	oListasCalculadas = null
	f_Articulo_PaletaDeColores_Desde_PK = ""
	f_Articulo_PaletaDeColores_Hasta_PK = "ZZZZZZZZZZ"
	f_Articulo_CurvaDeTalles_Desde_PK = ""
	f_Articulo_CurvaDeTalles_Hasta_PK = "ZZZZZZZZZZ" 
	lConfirmacion = .t.
	lVisualizacion = .F.
	lUsarPreciosConVigencia = .F.
	  
	*--------------------------------------------------------------------------------------------------------
	function oManagerPropiedadesDeBaseDeDatos_Access() as Object
		with this
			if !this.ldestroy and ( !vartype( .oManagerPropiedadesDeBaseDeDatos ) = 'O' or isnull( .oManagerPropiedadesDeBaseDeDatos ) )
				.oManagerPropiedadesDeBaseDeDatos = _Screen.Zoo.CrearObjeto( "ManagerPropiedadesDeBaseDeDatos" )
			endif
		endwith
		return this.oManagerPropiedadesDeBaseDeDatos 
	endfunc

	*-----------------------------------------------------------------------------------------
	function oRedondeo_Access() as Object
		if !this.lDestroy and vartype( this.oRedondeo ) # "O"
			this.oRedondeo = _screen.Zoo.InstanciarEntidad( "RedondeoDePrecios" )
		endif
		return this.oRedondeo
	endfunc

	*-----------------------------------------------------------------------------------------
	function oListaDePrecios_Access() as Object
		if !this.lDestroy and vartype( this.oListaDePrecios) # "O"
			this.oListaDePrecios = _screen.Zoo.InstanciarEntidad( "ListaDePrecios" )
		endif
		return this.oListaDePrecios
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function cCamposDeCombinacionConcatenados_Access() as String
		if !this.lDestroy and empty( this.cCamposDeCombinacionConcatenados )
			this.cCamposDeCombinacionConcatenados = this.ObtenerCamposDeCombinacionConcatenados()
		endif
		return this.cCamposDeCombinacionConcatenados
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function cCamposDeCombinacionDeStock_Access() as String
		if !this.lDestroy and empty( this.cCamposDeCombinacionDeStock )
			this.cCamposDeCombinacionDeStock = goServicios.Estructura.ObtenerCamposAtributosCombinacionDeStock()
		endif
		return this.cCamposDeCombinacionDeStock
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorCalculoDePrecios_Access() as Object
		if !this.lDestroy and vartype( this.oColaboradorCalculoDePrecios ) # "O"
			this.oColaboradorCalculoDePrecios = _Screen.Zoo.CrearObjetoPorProducto( "ColaboradorCalculoDePrecios" )
			this.oColaboradorCalculoDePrecios.ImportarSinTransaccion = this.ImportarSinTransaccion
			this.oColaboradorCalculoDePrecios.cNombreEntidad = "CALCULODEPRECIOS"
			this.oColaboradorCalculoDePrecios.DataSessionId = this.DataSessionId
			this.oColaboradorCalculoDePrecios.cCamposDeCombinacionConcatenados = this.cCamposDeCombinacionConcatenados
			this.oColaboradorCalculoDePrecios.UsaCombinacion = this.UsaCombinacion
		endif
		return this.oColaboradorCalculoDePrecios
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

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.BindearEventoHaCambiado()
		this.lUsarPreciosConVigencia = goServicios.Parametros.Felino.Precios.UsarPreciosConVigencia
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		this.lHabilitarPrecioKitPackxParticipante = .f.		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarPrecios() as Void
		local lcCursor as String, lcCursorDatos as String, lnI as Integer, llDatosValidos as Boolean
		llDatosValidos = this.ValidarTriggersRecursivosHabilitados()
		llDatosValidos = llDatosValidos and this.ValidarExistenciaDeListasDePrecios()
		llDatosValidos = llDatosValidos and this.ValidarExistenciaDeRedondeos()
		llDatosValidos = llDatosValidos and this.ValidarExistenciaDeCotizaciones()
		this.oListasCalculadas = this.ObtenerListasCalculadas()
		this.nCantidadOriginal = this.ModPrecios.Count
		if this.ModPrecios.Count = 0
			this.CompletarListas()
		endif			

		lcCamposCombinacion = goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()	
		lcXMLListas = "" 
		if llDatosValidos
			this.llHuboErroresAlActualizarPrecios = .f.
			this.cCursorDefinitivo = sys( 2015 )
			with This.ModPrecios
				if This.ModPrecios.Count > 0
					this.EventoComienzoCalculoDePrecios()
				endif
				for lnI = 1 to This.ModPrecios.Count	
					.CargarItem( lnI )
					if !empty( .oItem.LPrecio_Pk )
						this.oColCamposABorrar = _screen.Zoo.CrearObjeto( "ZooColeccion" )
						lcCursor = This.ObtenerConsultaPrecios( lnI )
						this.AplicarActualizaciones( lcCursor, lnI )
						
						set datasession to this.DataSessionId
						
						this.EliminarCamposTemporales( lcCursor )
						
						if !used( this.cCursorDefinitivo )
							select * from &lcCursor into cursor ( this.cCursorDefinitivo ) readwrite
						else
							insert into ( this.cCursorDefinitivo ) select * from &lcCursor
						endif
						
						use in select( lcCursor )
					endif
				endfor
			endwith
			
			Try
				this.BindearEvento( this.oColaboradorCalculoDePrecios, "EventoComienzoImportacion", this, "EventoComienzoSerializar_E_Importar" )
				this.BindearEvento( this.oColaboradorCalculoDePrecios, "EventoImportandoEtapa", this, "EventoImportandoEtapaSerializar_E_Importar" )
				this.BindearEvento( this.oColaboradorCalculoDePrecios, "EventoFinImportacion", this, "EventoFinSerializar_E_Importar" )
				if !this.llHuboErroresAlActualizarPrecios
					try
						lcCursorDatos = sys( 2015 )
						if used( this.cCursorDefinitivo )
							if this.lUsarPreciosConVigencia
								this.QuitarListasRepetidas( this.cCursorDefinitivo )
							endif
							if this.verConfirmacion()
								loFactoriaInformacionAplicacion = _Screen.Zoo.CrearObjeto( "InformacionAplicacion" ) 						
								loInformacionAplicacion = loFactoriaInformacionAplicacion.ObtenerInformacion()
								select &lcCamposCombinacion, listapre, codigo, pdirecto, pactual as actual from ( this.cCursorDefinitivo ) where listapre not in ( this.PasarListasAString( this.oListasCalculadas ) ) order by timestampa asc into cursor &lcCursorDatos readwrite
								if reccount( lcCursorDatos ) > 0
									loEntidades = this.ObtenerDatosDeEntidadesParaNet()
									lcXMLListas = this.ObtenerXMLListasDePrecios( lcCursorDatos )
*									this.xmlaCursor( lcXMLListas, "c_listas")
									cursortoxml( lcCursorDatos,"lcXMLPrecios",3,4, 0, "1")
									loPrePantalla  = this.oFactoriaPrePantalla.ObtenerPrePantalla()
									loRespuesta = loPrePantalla.Ejecutar( loEntidades, loInformacionAplicacion, lcXMLListas, lcXMLPrecios, this.FechaVigencia )
									if this.nCantidadOriginal != this.ModPrecios.count
										for i = this.ModPrecios.Count to this.nCantidadOriginal +1 step -1
											this.ModPrecios.Remove( i )
										endfor
									endif			
									if loRespuesta.Procesado = "f"
										this.agregarinformacion("El proceso ha sido cancelado por el usuario")
										goServicios.Errores.LevantarExcepcion( this.ObtenerInformacion() )
										this.EventoFinMensajeProcesando()
										
									endif
									this.ProcesarRespuesta( loRespuesta )	
								endif		
							endif		
							this.Serializar_E_Importar( this.cCursorDefinitivo )
							this.EventoFinMensajeProcesando()
						endif
					catch to loError
						goServicios.Errores.LevantarExcepcion( loError )
					finally
						use in select ( lcCursorDatos )
					endtry
				else
					this.FinalizarLogueo()
				endif
			finally
				use in select( this.cCursorDefinitivo )
				this.DesBindearEvento( this.oColaboradorCalculoDePrecios, "EventoComienzoImportacion", this, "EventoComienzoSerializar_E_Importar" )
				this.DesBindearEvento( this.oColaboradorCalculoDePrecios, "EventoImportandoEtapa", this, "EventoImportandoEtapaSerializar_E_Importar" )
				this.DesBindearEvento( this.oColaboradorCalculoDePrecios, "EventoFinImportacion", this, "EventoFinSerializar_E_Importar" )
			endtry 
		else
			goServicios.Errores.LevantarExcepcion( this.ObtenerInformacion() )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoComienzoCalculoDePrecios() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoComienzoSerializar_E_Importar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoImportandoEtapaSerializar_E_Importar( tnEtapa as Integer, tntotal as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinSerializar_E_Importar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarTriggersRecursivosHabilitados() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.ExistenDependenciasParaCalcularRecursivamente() and !this.ConsultarTriggersRecursivosEnBaseDeDatos()
			llRetorno = .F.
			This.AgregarInformacion( "La operación no puede completarse debido a que la propiedad RECURSIVE_TRIGGERS de la base de datos se encuentra deshabilitada y la misma no puede habilitarse. Comuníquese con su administrador de base de datos." )
		endif
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ExistenDependenciasParaCalcularRecursivamente() as Boolean
		local llRetorno as Boolean, loColeccion as zoocoleccion OF zoocoleccion.prg, loItem as Object

		for each loItem in This.ModPrecios foxobject
			if !llRetorno
				llRetorno = this.oColaboradorFormulasYListasDePrecios.TieneListasAnidadas( loItem.LPrecio_PK )
			endif
		endfor
		return llRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ConsultarTriggersRecursivosEnBaseDeDatos() as Boolean
		local llRetorno as Boolean
		llRetorno = this.oManagerPropiedadesDeBaseDeDatos.ConsultarTriggersRecursivosEnBaseDeDatos()
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function oFactoriaPrePantalla_Access() as Object
		if !this.ldestroy and ( !vartype( this.oFactoriaPrePantalla ) = 'O' or isnull( this.oFactoriaPrePantalla ) )
			this.oFactoriaPrePantalla = _Screen.Zoo.CrearObjeto( "ZooLogicSA.PrePantallaDePrecios.UI.FactoriaPrePantalla" )
		endif
		return this.oFactoriaPrePantalla
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function Serializar_E_Importar( tcCursor as String ) as Void
		this.oColaboradorCalculoDePrecios.Serializar_E_Importar( tcCursor, this.Codigo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ImportarPrecioDeArticulo( tcXml as String ) as void
		this.oColaboradorCalculoDePrecios.ImportarPrecioDeArticulo( tcXml )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarCamposTemporales( tcCursor as String ) as Void
		local loItem as Object
		for each loItem in this.oColCamposABorrar foxobject
			select &tcCursor
			alter table &tcCursor drop column ( loItem )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarCambioDePreciosParaListasRelacionadas() as Void
		local loColListasRelacionadas as ZooColeccion OF ZooColeccion.prg, loItem as Object, llProcesoBien as Boolean
		llProcesoBien = .T.
		for each loItem in This.ModPrecios foxobject
			if llProcesoBien
				llProcesoBien = this.ProcesarCambioDePreciosParaLista( loItem.LPrecio_PK )
			endif
		endfor
		
		if !llProcesoBien
			goServicios.Errores.LevantarExcepcion( "Error en la actualización de precios. Revise que los resultados de la fórmula no sean negativos." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarCambioDePreciosParaLista( tcListaDePreciosPK as String ) as Boolean
		local loColListasACalcularPrecio as ZooColeccion OF ZooColeccion.prg, loItem as Object, llRetorno as Boolean
		llRetorno = .T.
		loColListasACalcularPrecio = this.oColaboradorFormulasYListasDePrecios.ObtenerColeccionListasACalcularPrecio_SoloDependencias( tcListaDePreciosPK )
		llRetorno = this.oColaboradorCalculoDePrecios.ProcesarCambioDePreciosParaLista( loColListasACalcularPrecio, this.Codigo )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerConsultaPrecios( tnItem as Integer ) as String
		local lcCursor as String, lcCursorPrecioArticulo as String, lcCursorStock as String, lcCursorPrecioArticuloVacio as String, lcRetorno as String, loItem as Object

		lcCursorPrecioArticulo = this.ObtenerCursorPreciosDeArticulo( tnItem, "" )
		if this.ValidarIngresoFiltrosCombinacion()
			lcCursorPrecioArticuloVacio = sys( 2015 )
			select * from &lcCursorPrecioArticulo where .f. into cursor ( lcCursorPrecioArticuloVacio ) readwrite
			lcCursorStock = this.ObtenerCursorStock( lcCursorPrecioArticuloVacio )
			This.UnirCursores( tnItem, lcCursorPrecioArticulo, lcCursorStock )
			use in select ( lcCursorPrecioArticuloVacio )
		endif

		loItem = This.ModPrecios.oItem
		if loItem.EsAccionFormula()
			this.AgregarPreciosDeListasIncluidasEnLaFormula( lcCursorPrecioArticulo, loItem )
		endif

		return lcCursorPrecioArticulo
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function UnirCursores( tnItem, tcCursorPrecioArticulo, tcCursorStock ) as Void
		local lcArticulosFaltantes as String, lcCampo as String, lnTimestampA as Integer, ldFechaVigencia as Date
		
		lcCampo = this.cCamposDeCombinacionConcatenados
		lcArticulosFaltantes = sys(2015)
		lnTimestampA = this.ObtenerTimesTampA()
		ldFechaVigencia = this.FechaVigencia		
		select * ;
			from &tcCursorStock ;
			where &lcCampo not in ( select &lcCampo from &tcCursorPrecioArticulo ) ;
			into cursor ( lcArticulosFaltantes ) readwrite

		if tnItem <= This.ModPrecios.Count
			with This.ModPrecios
				.CargarItem( tnItem )
				Replace all ListaPre with .oItem.LPrecio_Pk, FechaVig with ldFechaVigencia, TimestampA with lnTimestampA, ;
					PDirecto with nvl( PDirecto, 0 ), Codigo with transform( lnTimestampA ) + .oItem.LPrecio_Pk+&lcCampo, ;
					PActual with nvl( PActual, 0 ) in ( lcArticulosFaltantes )
			endwith
			insert into &tcCursorPrecioArticulo select * from  &lcArticulosFaltantes 
		endif
		
		use in select ( lcArticulosFaltantes )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarListasDeFormulas( tcListaDePrecios as String, toEntFormula as Object ) as String
		local loMapeosDeListasDePrecios as zoocoleccion OF zoocoleccion.prg, loMapeo as Object
			
		loMapeosDeListasDePrecios = toEntFormula.ObtenerMapeosDeListasDePrecios()
		lcRetorno = "[" + tcListaDePrecios + "]"
		
		for each loMapeo in loMapeosDeListasDePrecios foxobject
			lcRetorno = lcRetorno + ", [" + loMapeo.ElementoDeLaFormula + "]"
		endfor
		
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorPreciosDeArticulo( tnItem as Integer, tcListaDePrecios as String ) as String
		local lcCursor as String, lcSelect as String, lcWhere As String, lcTablas as String, lcConsulta as String, ;
			  lcListaDePrecios as String, lcListaDePrecioItem as String, lcCadena as String, lcFuncionPrecio as String, ;
			  lcSelectKits as String, lcListas as String
			  
		lcListaDePrecios = this.ObtenerListaDePreciosParaConsulta( tnItem, tcListaDePrecios )
		lcListaDePrecioItem = this.ObtenerListaDePreciosDelItem( tnItem )
		this.lcListadePrecioDelItem = iif( empty( lcListaDePrecioItem ), lcListaDePrecios, lcListaDePrecioItem )
		this.lcListadePrecio = lcListaDePrecios 

		lcSelect = goServicios.Estructura.ObtenerSelectConsultaPreciosConPrecioActual( this.ObtenerFechaBaseParaVigencia(), this.lcListadePrecio, .t., this.lcListadePrecioDelItem )
		lcSelect = strtran( lcSelect, "From PRECIOAR", "From (" + goServicios.Estructura.ObtenerSelectPreciosVigentes( this.ObtenerFechaBaseParaVigencia(), this.lcListadePrecio ) + ") as PRECIOS" )

		if !empty( this.lcListadePrecio )
			with This.ModPrecios
				.CargarItem( tnItem )
				if .oItem.EsAccionFormula()
					lcListas = this.AgregarListasDeFormulas( this.lcListadePrecio, .oItem.Formula )
					if atc( this.lcListadePrecioDelItem, lcListas ) = 0
						lcListas = lcListas + ", [" + this.lcListadePrecioDelItem + "]"
					endif
					lcSelect = strtran( lcSelect, ' = [' + this.lcListadePrecio + ']', ' IN (' + lcListas + ')' )
				else
					if this.lcListadePrecio != this.lcListadePrecioDelItem
						lcListas = "[" + this.lcListadePrecio + "], [" + this.lcListadePrecioDelItem + "]"
						lcSelect = strtran( lcSelect, ' = [' + this.lcListadePrecio + ']', ' IN (' + lcListas + ')' )
					endif
				endif
			endwith
		endif

		if this.PrecioKitPackxParticipante
			lcFuncionPrecio = goServicios.Estructura.ObtenerFuncionPrecioRealDeLaCombinacionConVigencia( this.ObtenerFechaBaseParaVigencia(), this.lcListadePrecio, .t., this.lcListadePrecioDelItem )
			lcSelect = this.ObtenerSelectKitsYPacks( lcSelect, lcFuncionPrecio, goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados(), this.lcListadePrecio )
		endif	

		lcWhere = "'" + goServicios.Estructura.ObtenerWhereConsultaPrecios() + " "
		lcWhere = lcWhere + "'"

		lcTablas = goServicios.Estructura.ObtenerTablasConsultaPrecios()
		lcConsulta = strtran( lcSelect + " Where " + &lcWhere, "[", "'" )
		lcCadena = this.ObtenerString( lcSelect )
		lcConsulta = this.ModificaWhereParaFiltroDePrecio( lcSelect, lcConsulta )
		lcConsulta = strtran( lcConsulta, "]", "'" )

		if this.PrecioKitPackxParticipante
			lcConsulta = this.ObtenerSelectPieKitsYPacks( lcConsulta, "ARTICULO", goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados() )
			lcTablas = lcTablas + ", " + goServicios.Estructura.ObtenerTablasParticipantes()
		endif
		
		lcConsulta = strtran( lcConsulta, "PRECIOAR", "PRECIOS" )
		lcConsulta = strtran( lcConsulta, "From PRECIOS", "From PRECIOAR" )

		lcConsulta = "select T.* from (" + lcConsulta + ") as T where T.PACTUAL >= " + transform( This.f_PRECIODIRECTO_Desde ) + " and T.PACTUAL <= " + transform( This.f_PRECIODIRECTO_Hasta )
		lcGroupYOrder = goServicios.Estructura.ObtenerAgrupamientoyOrdenConsultaPrecios()
		lcGroupYOrder = strtran(lcGroupYOrder, "PRECIOAR", "T")

	 	lcGroupYOrder = substr(lcGroupYOrder, 1, at("order by", lcGroupYOrder, 1)-1) + ", T.PDIRECTO, T.TIMESTAMPA, T.LISTAPRE, T.PACTUAL" + substr(lcGroupYOrder, at("order by", lcGroupYOrder, 1)-1, len(lcGroupYOrder))		
		lcConsulta = lcConsulta + lcGroupYOrder

		lcCursor = this.ObtenerCursorRetorno( lcConsulta, lcTablas, this.lcListadePrecio )
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerListaDePreciosParaConsulta( tnItem as Integer, tcListaDePrecios as String ) as String 
		local lcRetorno as String 
		
		lcRetorno = ""
		
		if tnItem > 0 and tnItem <= This.ModPrecios.Count
			with This.ModPrecios
				.CargarItem( tnItem )
				do case
					case !empty( tcListaDePrecios )
						lcRetorno = tcListaDePrecios
					case !empty( .oItem.LPrecio_Pk ) and empty( .oItem.LPrecioA_Pk )
						lcRetorno = .oItem.LPrecio_Pk
					case !empty( .oItem.LPrecio_Pk ) and !empty( .oItem.LPrecioA_Pk )						
						lcRetorno = .oItem.LPrecioA_Pk
				EndCase
			EndWith
		endif
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerListaDePreciosDelItem( tnItem as Integer ) as String 
		local lcRetorno as String
		lcRetorno = ""
		if tnItem <= This.ModPrecios.Count
			with This.ModPrecios
				.CargarItem( tnItem )
				if !empty( .oItem.LPrecio_Pk ) 
					lcRetorno = .oItem.LPrecio_Pk
				endif
			EndWith
		endif
		return lcRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorRetorno( tcConsulta as String, tcTablas as String, tcWhereLP as String ) as String
		local lcRetorno as String, lcWhere as string, lcConsulta as String, lcCursorTemporal as String, lcTablaCampoLP as String, ;
			lcCamposCombinacion as string, lnCamposCombinacion as Integer, lnI as Integer, lcWhereCombinacion as String, ;
			lcOnCombinacion as String, lcSelectNuevos as String, lcWhereNuevos as String, lcAux as String

		lcCursorTemporal = sys( 2015 )
		lcRetorno = sys( 2015 )
		
		goServicios.Datos.EjecutarSentencias( tcConsulta, tcTablas, "", lcCursorTemporal, This.DataSessionId )
		
		if used( this.cCursorDefinitivo )
			lcTablaCampoLP = This.ObtenerTablaCampo( "PrecioDeArticulo", "ListaDePrecio" )
			lcWhere = lcTablaCampoLP + " = '" + alltrim( upper( strtran( tcWhereLP, "and", "" ) ) ) + "'"
			select * from ( this.cCursorDefinitivo ) precioar where &lcWhere into cursor &lcRetorno readwrite
			if !eof( lcRetorno ) and used( lcCursorTemporal )
				lcCamposCombinacion = goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
				lnCamposCombinacion = alines( laCamposCombinacion, lcCamposCombinacion, "," )
				lcWhereCombinacion = ""
				lcOnCombinacion = ""
				lcSelectNuevos = ""
				lcWhereNuevos = ""
				for lnI = 1 to lnCamposCombinacion
					if lnI = 1
						lcWhereNuevos = lcWhereNuevos + "empty( nvl( &lcRetorno.." + laCamposCombinacion[ lnI ] + ", '' ) )"
					endif
					lcSelectNuevos = lcSelectNuevos + "&lcCursorTemporal.." + laCamposCombinacion[ lnI ] + ", "
					lcOnCombinacion = lcOnCombinacion + "&lcCursorTemporal.." + laCamposCombinacion[ lnI ] + " = "
					lcOnCombinacion = lcOnCombinacion + "&lcRetorno.." + laCamposCombinacion[ lnI ] + " and "
				endfor
				lcWhereNuevos = iif( empty( lcWhereNuevos ), ".f.", lcWhereNuevos )
				lcSelectNuevos = iif( empty( lcSelectNuevos ), " * ", substr( lcSelectNuevos, 1, len( lcSelectNuevos ) -2 ) )
				lcOnCombinacion = substr( lcOnCombinacion, 1, len( lcOnCombinacion ) -5 )
				lcWhereCombinacion = iif( empty( lcOnCombinacion ), ".f.", lcOnCombinacion )
				
	 			update &lcRetorno set PActual = nvl(( select PActual from &lcCursorTemporal where &lcWhereCombinacion ), 0)
				
				lcAux = sys( 2015 )
				select &lcSelectNuevos, &lcCursorTemporal..pdirecto, &lcCursorTemporal..timestampa, &lcCursorTemporal..listapre, &lcCursorTemporal..pactual ;
							from &lcCursorTemporal left join &lcRetorno on &lcOnCombinacion where &lcWhereNuevos into cursor &lcAux 
				select ( lcRetorno )
				append from ( dbf( lcAux ) )
				use in select ( lcAux )
			endif
		endif	
		
		if !used( this.cCursorDefinitivo ) or eof( lcRetorno )
			lcConsulta = goServicios.Estructura.ObtenerEstructuraPrecios()
			lcConsulta = strtran( Proper( lcConsulta ), "* From", "*, PDirecto as PActual From" )
			goServicios.Datos.EjecutarSentencias( lcConsulta, tcTablas, "", lcRetorno , This.DataSessionId )		
			if used( lcRetorno ) and used( lcCursorTemporal )
				select ( lcRetorno )
				append from (dbf( lcCursorTemporal ))
			endif
		endif
		
		if used( lcCursorTemporal )
			use in select ( lcCursorTemporal )
		endif
	
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorPreciosDeArticuloSegunParticipantes( tnItem as Integer, tcListaDePrecios as String ) as String
		local lcCursor as String, lcSelect as String, lcWhere As String, lcTablas as String, lcConsulta as String, ;
			  lcListaDePrecios as String, lcCadena as String, lcJoinsPrecio as String, lcSelectComb as String, ;
			  lcSelectUnion as String, lcListas as String

		lcListaDePrecios = this.ObtenerListaDePreciosParaConsulta( tnItem, tcListaDePrecios )

		lcSelect = goServicios.Estructura.ObtenerSelectConsultaPreciosConPrecioActual( this.ObtenerFechaBaseParaVigencia(), lcListaDePrecios, .t., this.lcListadePrecioDelItem )

		lcListas = ""
		if !empty( lcListaDePrecios )
			with This.ModPrecios
				.CargarItem( tnItem )
				lcListas = this.AgregarListasDeFormulas( lcListaDePrecios, .oItem.Formula )
				if atc( .oItem.lprecio_pk, lcListas ) = 0
					lcListas = lcListas + ", [" + .oItem.lprecio_pk + "]"
				endif
			endwith
		endif

		lcJoinsPrecio = substr( lcSelect, atc( "INNER", upper(lcSelect), 2 ) )

		lcSelectComb = this.ObtenerSelectCombParaUnirConPrecioAR()

		lcSelectUnion = this.ObtenerSelectKitsYPacksParaFormula( lcListaDePrecios ) + this.ObtenerSelectPrecio( lcListaDePrecios, lcListas )
		lcSelectUnion = lcSelectUnion + " Union " + lcSelectComb 
		lcSelectUnion = lcSelectUnion + ") CPRECIOS"

		lcWhere = "'" + goServicios.Estructura.ObtenerWhereConsultaPrecios() + " '"
		lcWhere = &lcWhere
		lcWhere = this.ModificaWhereParaFiltroDePrecio( "", lcWhere )
		lcWhere = strtran(lcWhere, "ObtenerPrecioRealDeLaCombinacionConVigencia", "ObtenerPrecioDeLaCombinacionConVigencia")

		lcConsulta = strtran( lcJoinsPrecio + " Where " + lcWhere, "PRECIOAR", "CPRECIOS" )
		lcConsulta = strtran( lcSelectUnion + " " + lcConsulta , "[", "'" )
		lcConsulta = strtran( lcConsulta, "]", "'" )
		lcConsulta = strtran(lcConsulta, "ObtenerPrecioRealDeLaCombinacionConVigencia", "ObtenerPrecioDeLaCombinacionConVigencia")

		lcConsulta = this.ObtenerSelectPieKitsYPacks( lcConsulta, "ARTICULO", goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados() )
		lcConsulta = strtran( lcConsulta, " TimestampA,", "" )

		lcTablas = goServicios.Estructura.ObtenerTablasConsultaPrecios()
		lcTablas = lcTablas + ", " + goServicios.Estructura.ObtenerTablasStockCombinacion()
		lcTablas = lcTablas + ", " + goServicios.Estructura.ObtenerTablasParticipantes()

		lcConsulta = "select T.* from (" + lcConsulta + ") as T where T.PACTUAL >= " + transform( This.f_PRECIODIRECTO_Desde ) + " and T.PACTUAL <= " + transform( This.f_PRECIODIRECTO_Hasta )
		lcGroupYOrder = goServicios.Estructura.ObtenerAgrupamientoyOrdenConsultaPrecios()
		lcGroupYOrder = strtran(lcGroupYOrder, "PRECIOAR", "T")
		lcGroupYOrder = substr(lcGroupYOrder, 1, at("order by", lcGroupYOrder, 1)-1) + ", T.PDIRECTO, T.LISTAPRE, T.PACTUAL" + substr(lcGroupYOrder, at("order by", lcGroupYOrder, 1)-1, len(lcGroupYOrder))
		lcConsulta = lcConsulta + lcGroupYOrder

		lcCursor = this.ObtenerCursorRetorno( lcConsulta, lcTablas, lcListaDePrecios )
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSelectKitsYPacks( tcSelect as String, tcFuncionPrecio as String, tcAtributosCombinacion as String, tcListaDePrecios as String ) as String
		local lcSelect as String, lcSelectKits as String, lcFuncionPrecioRealParticipantes as String, lcAtributosConcatenados as String, ;
			lcReemplazar as String, llNoEncontrado as Boolean

		llNoEncontrado = .f.
		lcSelect = strtran( tcSelect, ", " + tcFuncionPrecio, " " )
		lcFuncionPrecioRealParticipantes = goServicios.Estructura.ObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia( this.ObtenerFechaBaseParaVigencia(), tcListaDePrecios, .t., this.lcListadePrecioDelItem )
		if !This.UsaCombinacion
			lcFuncionPrecioRealParticipantes = this.ModificaFuncionPrecioParaStockSinCombinacion( lcFuncionPrecioRealParticipantes )
		endif
		if occurs( tcAtributosCombinacion, lcFuncionPrecioRealParticipantes ) = 0
			llNoEncontrado = .t.
			lcReemplazar = substr( lcFuncionPrecioRealParticipantes, atc( "(", lcFuncionPrecioRealParticipantes, 3 ), atc( "timestampa", lcFuncionPrecioRealParticipantes ) - atc( "(", lcFuncionPrecioRealParticipantes, 3 ) +12 )
			lcFuncionPrecioRealParticipantes = strtran( lcFuncionPrecioRealParticipantes, lcReemplazar, "" )
			lcAtributosConcatenados = goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
			lcFuncionPrecioRealParticipantes = strtran( lcFuncionPrecioRealParticipantes, lcAtributosConcatenados, tcAtributosCombinacion )
		endif
		lcSelectKits = "select " + tcAtributosCombinacion + ", sum(PDIRECTO) as PDIRECTO, "
		lcSelectKits = lcSelectKits + iif( llNoEncontrado, "", "TIMESTAMPA, " )
		lcSelectKits = lcSelectKits + "ListaPre, PACTUAL "
		lcSelectKits = lcSelectKits + "from ( select " + tcAtributosCombinacion + ", " 
		lcSelectKits = lcSelectKits + lcFuncionPrecioRealParticipantes
		lcSelectKits = lcSelectKits + "from ( "
		lcSelect = lcSelectKits + lcSelect

		return lcSelect
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSelectPieKitsYPacks( tcConsulta as String, tcCampo as String, tcAtributosCombinacion as String ) as String
		local lcConsulta as String
		
			lcConsulta = tcConsulta + ") as CCombinaciones "
			lcConsulta = lcConsulta + "inner join " + goServicios.Estructura.ObtenerTablasParticipantes() + " on CCombinaciones." + tcCampo + " = " + goServicios.Estructura.ObtenerCampoClavePrimariaParticipantes()
			lcConsulta = lcConsulta + ") as PKITPACK GROUP BY " + tcAtributosCombinacion
			lcConsulta = lcConsulta + iif( atc( "timestampa", lcConsulta ) = 0, "", ", TimestampA" )
			lcConsulta = lcConsulta + ", ListaPre, PACTUAL"
			
		return lcConsulta 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSelectKitsYPacksParaFormula( tcListaDePrecios as String ) as String
		local lcSelectKitsYPacks as String, lcFuncionPrecioDeKitsYPacks as String, lcReemplazar as String
		
		lcSelectKitsYPacks = "select "
		lcSelectKitsYPacks = lcSelectKitsYPacks + goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
		lcSelectKitsYPacks = lcSelectKitsYPacks + ", sum(PDIRECTO) as PDIRECTO, ListaPre, PACTUAL "
		lcSelectKitsYPacks = lcSelectKitsYPacks + "from ( select "
		lcSelectKitsYPacks = lcSelectKitsYPacks + goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
		lcSelectKitsYPacks = lcSelectKitsYPacks + ", " 

		lcFuncionPrecioDeKitsYPacks = goServicios.Estructura.ObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia( this.ObtenerFechaBaseParaVigencia(), tcListaDePrecios, .t., this.lcListadePrecioDelItem )
		lcReemplazar = substr( lcFuncionPrecioDeKitsYPacks, atc( "(", lcFuncionPrecioDeKitsYPacks, 3 ), atc( "timestampa", lcFuncionPrecioDeKitsYPacks ) - atc( "(", lcFuncionPrecioDeKitsYPacks, 3 ) +12 )
		lcFuncionPrecioDeKitsYPacks = strtran( lcFuncionPrecioDeKitsYPacks, lcReemplazar, "" )
		
		lcSelectKitsYPacks = lcSelectKitsYPacks + lcFuncionPrecioDeKitsYPacks 
		lcSelectKitsYPacks = lcSelectKitsYPacks + "from ( "

		return lcSelectKitsYPacks
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSelectPrecio( tcListaDePrecios as String, tcListas as String ) as String
		local lcSelectPrecio as String

		lcSelectPrecio = "Select Distinct " 
		lcSelectPrecio = lcSelectPrecio + goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
		lcSelectPrecio = lcSelectPrecio + " from( "
		lcSelectPrecio = lcSelectPrecio + goServicios.Estructura.ObtenerSelectPreciosVigentes( this.ObtenerFechaBaseParaVigencia(), tcListaDePrecios )
		lcSelectPrecio = strtran( lcSelectPrecio, "SB.LISTAPRE, ", "" )
		lcSelectPrecio = strtran( lcSelectPrecio, "SB.FECHAVIG, ", "" )
		lcSelectPrecio = strtran( lcSelectPrecio, ", SB.PDIRECTO", "" )
		if !empty( tcListas ) 
			lcSelectPrecio = strtran( lcSelectPrecio, ' = [' + tcListaDePrecios + ']', ' IN (' + tcListas + ')' )
		endif 

		return lcSelectPrecio
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSelectCombParaUnirConPrecioAR() as String
		local lcSelectComb as String, lcReemplazo1 as String, lcReemplazo2 as String, lcReemplazo3 as String

		lcSelectComb = goServicios.Estructura.ObtenerCamposAtributosCombinacionDeStock()
		lcReemplazo1 = substr( lcSelectComb, 1, atc( ", ", upper( lcSelectComb ), 1 ) -1 )
		lcReemplazo2 = substr( lcSelectComb, atc( ", ", upper( lcSelectComb ), 1 ) +2, (atc(", ",upper( lcSelectComb ),2)) - (atc(", ",upper( lcSelectComb ),1)) -2 )
		lcReemplazo3 = substr( lcSelectComb, atc( ", ", upper( lcSelectComb ), 2 ) +2 )

		lcSelectComb = "Select distinct " + goServicios.Estructura.ObtenerTablasStockCombinacion() + "." + lcReemplazo1 + " as ARTICULO"
		lcSelectComb = lcSelectComb + ", " + goServicios.Estructura.ObtenerTablasStockCombinacion() + "." + lcReemplazo2 + " as CCOLOR"
		lcSelectComb = lcSelectComb + ", " + goServicios.Estructura.ObtenerTablasStockCombinacion() + "." + lcReemplazo3 + " as TALLE"
		lcSelectComb = lcSelectComb + ", 0 as TIMESTAMPA"
		lcSelectComb = lcSelectComb + " From " + goServicios.Estructura.ObtenerTablasStockCombinacion()
		lcSelectComb = lcSelectComb + goServicios.Estructura.ObtenerLeftJoinsCombinacionPrecios()
		lcSelectComb = lcSelectComb + " Where PRECIOAR.ARTICULO is null " 

		return lcSelectComb 
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
		local lcCursor as String, lcSelect as String, lcWhere As String, lcTablas as String, lcConsulta as String, lcCampo as String, ;
			lcPreSelect as String, lcClaveArticulo as String, lcFuncionPrecioParticipantes as String, lcLeftJoinPrecios as String

		lcCursor = sys( 2015 )

		lcClaveArticulo = goServicios.Estructura.ObtenerCampoClaveArticulo()
		lcSelect = goServicios.Estructura.ObtenerSelectStockArticulo()
		lcSelect = strtran( lcSelect, "Select", "Select distinct" )
		lcSelect = strtran( lcSelect, "*", lcClaveArticulo + " as ARTICULO, 0 as PDIRECTO" )

		if this.PrecioKitPackxParticipante
			lcFuncionPrecioParticipantes = goServicios.Estructura.ObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia( this.ObtenerFechaBaseParaVigencia(), this.lcListadePrecio, .t., this.lcListadePrecioDelItem )
			lcFuncionPrecioParticipantes = substr( lcFuncionPrecioParticipantes, 1, atc( "as", lcFuncionPrecioParticipantes )-2 )
			lcFuncionPrecioParticipantes = strtran( lcFuncionPrecioParticipantes, "ObtenerPrecioRealDeLaCombinacionConVigencia", "ObtenerPrecioDeLaCombinacionConVigencia" )
			lcFuncionPrecioParticipantes = this.ModificaFuncionPrecioParaStockSinCombinacion( lcFuncionPrecioParticipantes )
			lcPreSelect = "Select ARTICULO, sum(PDIRECTO) as PDIRECTO from ( Select ARTICULO, "
			lcPreSelect = lcPreSelect + lcFuncionPrecioParticipantes + " as PDIRECTO from ("
			lcSelect = lcPreSelect + lcSelect 
		endif

		lcSelect = lcSelect + goServicios.Estructura.ObtenerLeftJoinsCombinacion()
		lcSelect = strtran( lcSelect, "left", "inner" )
		lcLeftJoinPrecios = goServicios.Estructura.ObtenerLeftJoinsCombinacion()
		lcLeftJoinPrecios = strtran( lcLeftJoinPrecios, "COMB", "PRECIOAR" )
		lcLeftJoinPrecios = strtran( lcLeftJoinPrecios, "COART", "ARTICULO" )
		lcSelect = lcSelect + lcLeftJoinPrecios 
		
		lcWhere = "'" + goServicios.Estructura.ObtenerWhereStockArticulo()
		lcWhere = lcWhere + " and PRECIOAR.ARTICULO is null and 1=" + iif( This.f_PRECIODIRECTO_Desde > 0, transform(0), transform(1) ) + " "
		lcWhere = lcWhere + "'"

		lcTablas = goServicios.Estructura.ObtenerTablasStockArticulo()
		lcTablas = lcTablas + ", " + goServicios.Estructura.ObtenerTablasStockCombinacion() + ", PRECIOAR"

		lcConsulta = strtran( lcSelect + " Where " + &lcWhere, "[", "'" )
		lcConsulta = strtran( lcConsulta, "]", "'" )

		if this.PrecioKitPackxParticipante
			lcConsulta = lcConsulta + ") as CCombinaciones "
			lcConsulta = lcConsulta + "inner join " + goServicios.Estructura.ObtenerTablasParticipantes() + " on CCombinaciones.ARTICULO = " + goServicios.Estructura.ObtenerCampoClavePrimariaParticipantes()
			lcConsulta = lcConsulta + ") as PKITPACK GROUP BY ARTICULO ORDER BY ARTICULO"
			lcTablas = lcTablas + ", " + goServicios.Estructura.ObtenerTablasParticipantes()
		endif

		goServicios.Datos.EjecutarSentencias( lcConsulta, lcTablas, "", lcCursor, This.DataSessionId )
		lcCampo = goServicios.Estructura.ObtenerSentenciaInsertAtributosArticulos( lcCursor )
		lcCampo = strtran( lcCampo, lcClaveArticulo, "ARTICULO" )
		lcCampo = substr( lcCampo, 1, atc( "values", lcCampo )-4 ) + ", PDIRECTO ) " + substr( lcCampo, atc( "values", lcCampo ) ) 
		lcCampo = substr( lcCampo, 1, len(lcCampo)-2 ) + ", " + lcCursor + ".PDIRECTO )"
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
		local lcCursor as String, lcSelect as String, lcWhere As String, lcWhereActual as String, lcTablas as String, lcConsulta as String, lcCampo as String

		lcCursor = sys( 2015 )

		lcSelect = goServicios.Estructura.ObtenerSelectStockArticuloCombinacionConPrecios( this.ObtenerFechaBaseParaVigencia(), this.lcListadePrecio, .t., this.lcListadePrecioDelItem )
		lcSelect = lcSelect + goServicios.Estructura.ObtenerLeftJoinsCombinacionPrecios()
		lcSelect = strtran( lcSelect, "Select", "Select distinct" )
		lcSelect = "Select * from ( " + lcSelect 

		if this.PrecioKitPackxParticipante
			lcFuncionPrecio = goServicios.Estructura.ObtenerFuncionPrecioRealDelStockConVigencia( this.ObtenerFechaBaseParaVigencia(), this.lcListadePrecio, .t., this.lcListadePrecioDelItem )
			lcSelect = this.ObtenerSelectKitsYPacks( lcSelect, lcFuncionPrecio, goServicios.Estructura.ObtenerCamposAtributosCombinacionDeStock(), this.lcListadePrecio )
		endif

		lcSelect = strtran(lcSelect, "ObtenerPrecioRealDeLaCombinacionConVigencia", "ObtenerPrecioDeLaCombinacionConVigencia")
		lcWhere = "'" + goServicios.Estructura.ObtenerWhereStockArticuloCombinacion()
		lcWhere = lcWhere + " and PRECIOAR.ARTICULO is null '"
		
		lcTablas = goServicios.Estructura.ObtenerTablasStockArticuloCombinacion() + ", PRECIOAR"

		lcConsulta = strtran( lcSelect + " Where " + &lcWhere, "[", "'" )
		lcConsulta = strtran( lcConsulta, "]", "'" )
		lcConsulta = lcConsulta + ") SOLOCOMB "
		lcWhereActual = "where PACTUAL >= " + transform( This.f_PRECIODIRECTO_Desde ) + " and PACTUAL <= " + transform( This.f_PRECIODIRECTO_Hasta )

		if this.PrecioKitPackxParticipante
			lcConsulta = this.ObtenerSelectPieKitsYPacks( lcConsulta, "COART", goServicios.Estructura.ObtenerCamposAtributosCombinacionDeStock() )
			lcConsulta = strtran( lcConsulta, "GROUP BY", lcWhereActual + " GROUP BY" )
			lcTablas = lcTablas + ", " + goServicios.Estructura.ObtenerTablasParticipantes()
		else
			lcConsulta = lcConsulta + lcWhereActual
		endif

		goServicios.Datos.EjecutarSentencias( lcConsulta, lcTablas, "", lcCursor, This.DataSessionId )
		lcCampo = goServicios.Estructura.ObtenerSentenciaInsertAtributosCombinacion( lcCursor )
		lcSql= "insert into &tcCursorPrecioArticuloVacio " + lcCampo 
		lcSql= alltrim( strtran( lcSql, " ) values", ", PDirecto, ListaPre, PACTUAL ) values" ) )
		lcSql= left( lcSql, len( lcSql) - 2 )
		lcSql= lcSql + ", " + lcCursor + ".PDirecto, " + lcCursor + ".ListaPre, " + lcCursor + ".PActual )"

		select ( lcCursor )		
		scan
			&lcSql	
		endscan

		use in select( lcCursor )
		return tcCursorPrecioArticuloVacio
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ModificaFuncionPrecioParaStockSinCombinacion( tcFuncionPrecio as String ) as String
		local lcFuncionPrecio as String, lcReemplazar1 as String, lcReemplazar2 as String
		lcFuncionPrecio = tcFuncionPrecio
		lcReemplazar1 = substr( lcFuncionPrecio, atc( ",", lcFuncionPrecio, 1 )+2, atc( ",", lcFuncionPrecio, 2 ) - atc( ",", lcFuncionPrecio, 1)-2 )
		lcReemplazar2 = substr( lcFuncionPrecio, atc( ",", lcFuncionPrecio, 2 )+2, atc( ",", lcFuncionPrecio, 3 ) - atc( ",", lcFuncionPrecio, 2)-2 )
		lcFuncionPrecio = strtran( lcFuncionPrecio, lcReemplazar1, "''" )
		lcFuncionPrecio = strtran( lcFuncionPrecio, lcReemplazar2, "''" )
		return lcFuncionPrecio
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
	function ObtenerTimesTampA() as Integer
		return goServicios.Datos.ObtenerTimestamp()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AplicarActualizaciones( tcCursor as String, tnItem as Integer ) as Void
		local lcListaPrecio As String, lnValor as Float, lcListaPrecio_A as String, lcFormula as String, lnLen as Integer, loError as zooexception OF zooexception.prg, ;
			lnPrecioAnterior as Double, lcMensajeALoguear as String, lnTimestampA as Integer, ldFechaVigencia as Date, lcCamposCombinacion as String 

		lnLen = len( &tcCursor..ListaPre )
		with This.ModPrecios
			.CargarItem( tnItem )
			lcListaPrecio	= padr( .oItem.LPrecio_Pk, lnLen )
			lcListaPrecio_A = padr( .oItem.LPrecioA_Pk, lnLen )
			lnValor = .oItem.Valor

			lnTimestampA = this.ObtenerTimesTampA()
			ldFechaVigencia = this.FechaVigencia

			lcCamposCombinacion = goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados()
			lcCamposCombinacion = strtran( lcCamposCombinacion, ",", " +")
			lcFormula = This.ObtenerFormula( .oItem )

			do case
				case .oItem.EsAccionFormula()
					if this.lUsarPreciosConVigencia
						update &tcCursor set Codigo = padr( alltrim( str( lnTimestampA , 14 ) ), 14) + lcListaPrecio + &lcCamposCombinacion , FechaVig = ldFechaVigencia, TimestampA = lnTimestampA Where ListaPre = lcListaPrecio
					else
						update &tcCursor set Codigo = padr( alltrim( str( TimestampA, 14 ) ), 14) + lcListaPrecio + &lcCamposCombinacion Where ListaPre = lcListaPrecio
					endif
					with .oItem.Formula
						.CambiarSesionDeDatos( this.DataSessionId )
						select ( tcCursor )
						scan for ListaPre = lcListaPrecio
							try
								lnPrecioAnterior = PDirecto
								replace PDirecto with &lcFormula in ( tcCursor )
								if PDirecto < 0
									replace PDirecto with 0 in ( tcCursor )
								endif
							catch to loError
								replace PDirecto with lnPrecioAnterior in ( tcCursor )
								this.llHuboErroresAlActualizarPrecios = .t.
								lcMensajeALoguear = this.ObtenerMensajeALoguearPorErrorAlAplicarLaFormula( tcCursor, loError, lcListaPrecio )
								this.Loguear( lcMensajeALoguear )
							endtry
						endscan
						.RestaurarSesionDeDatos()
					endwith
				case !empty( lcListaPrecio ) and empty( lcListaPrecio_A )
					if this.lUsarPreciosConVigencia
						update &tcCursor set PDirecto = &lcFormula, Codigo = padr( alltrim( str( lnTimestampA , 14 ) ), 14) + lcListaPrecio + &lcCamposCombinacion , FechaVig = ldFechaVigencia, TimestampA = lnTimestampA &&Where ListaPre = lcListaPrecio
					else
						update &tcCursor set PDirecto = &lcFormula, Codigo = padr( alltrim( str( TimestampA, 14 ) ), 14) + lcListaPrecio + &lcCamposCombinacion &&, FechaVig = ldFechaVigencia
					endif
				case !empty( lcListaPrecio ) and !empty( lcListaPrecio_A )
					if this.lUsarPreciosConVigencia
						update &tcCursor set PDirecto = &lcFormula, ListaPre = lcListaPrecio, Codigo = padr( alltrim( str( lnTimestampA , 14 ) ), 14) + lcListaPrecio + &lcCamposCombinacion , FechaVig = ldFechaVigencia, TimestampA = lnTimestampA &&Where ListaPre = lcListaPrecio_A
					else
						update &tcCursor set PDirecto = &lcFormula, ListaPre = lcListaPrecio, Codigo = padr( alltrim( str( TimestampA, 14 ) ), 14) + lcListaPrecio + &lcCamposCombinacion &&, FechaVig = ldFechaVigencia
					endif
					
			endcase
			if used( tcCursor )
				update &tcCursor set PDirecto = 0 where PDirecto < 0 
				if this.lUsarPreciosConVigencia
					update &tcCursor set  TIMESTAMP = this.timestamp &&BDALTAFW = this.basededatosaltafw, BDMODIFW = this.basededatosmodificacionfw, SALTAFW = this.seriealtafw, SMODIFW = this.seriemodificacionfw, VALTAFW = this.versionaltafw, VMODIFW = this.versionmodificacionfw,
				endif
			endif
			if !empty( .oItem.Redondeo_Pk )
				if .oItem.EsAccionFormula()
					.oItem.Formula.CambiarSesionDeDatos( this.DataSessionId )
					this.AplicarRedondeo( tcCursor, lcListaPrecio )
					.oItem.Formula.RestaurarSesionDeDatos()
				else
					this.AplicarRedondeo( tcCursor, lcListaPrecio )
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AplicarRedondeo( tcCursor as String, tcListaPrecio as String ) as Void
		local lcListaPrecio as String
		lcListaPrecio = tcListaPrecio
		update &tcCursor set PDirecto = .oItem.Redondeo.Redondear( PDirecto ) where ListaPre = lcListaPrecio
		update &tcCursor set PDirecto = 0 where PDirecto < 0 and ListaPre = lcListaPrecio
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFormula( toItem as Object ) as String
		local lcRetorno as String, lcAccion as String
		lcRetorno = "PDirecto"
		lcAccion = alltrim( toItem.Accion )
		do Case
			case lcAccion == "1" 
				lcRetorno = lcRetorno + " +  ( pDirecto * ( lnValor / 100 ) )"
			case lcAccion == "2" 
				lcRetorno = "lnValor"
			case lcAccion == "3" 
				lcRetorno = lcRetorno + " + lnValor"
			case lcAccion == "4"
				lcRetorno = this.ObtenerFormulaDefinidaPorElUsuario( toItem )
		EndCase
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarPorcentajes() as Boolean
		local lni as Integer, llRetorno as Boolean
		llRetorno = .T.
		for lni = 1 to This.ModPrecios.Count
			if alltrim( This.ModPrecios.Item[lnI].Accion )  == "1" and This.ModPrecios.Item[lnI].Valor < -100
				This.AgregarInformacion( "No está permitido utilizar valores menores a -100 en 'Porcentajes de cálculo'" )
				llRetorno = .F.
				exit
			Endif
		EndFor
		return llRetorno	
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarPrecioDirecto() as Boolean
		local lni as Integer, llRetorno as Boolean
		llRetorno = .T.
		for lni = 1 to This.ModPrecios.Count
			if alltrim( This.ModPrecios.Item[lnI].Accion )  == "2" and This.ModPrecios.Item[lnI].Valor < 0
				This.AgregarInformacion( "No está permitido utilizar valores negativos en 'Precios directos'" )
				llRetorno = .F.
				exit
			Endif
		EndFor
		return llRetorno	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarItemsDeTipoDeAccionFormula() as Boolean
		local i as Integer, llRetorno as Boolean
		llRetorno = .T.
		for i = 1 to This.ModPrecios.Count
			if alltrim( This.ModPrecios.Item[ i ].Accion )  == "4" and empty( This.ModPrecios.Item[ i ].Formula_PK )
				This.AgregarInformacion( "Existen items del tipo de acción 'Fórmula' para los que no se especificó que fórmula se debe aplicar." )
				llRetorno = .F.
				exit
			Endif
		EndFor
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeListasDePrecios() as Boolean
		local i as Integer, llRetorno as Boolean
		llRetorno = .t.
		for i = 1 to This.ModPrecios.Count
			if !empty( This.ModPrecios.Item[ i ].LPrecio_PK )
				llRetorno = goServicios.Datos.ValidarExistenciaEnEntidad( this.oListaDePrecios, This.ModPrecios.Item[ i ].LPrecio_PK, this ) and llRetorno
			endif
			if !empty( This.ModPrecios.Item[ i ].LPrecioA_PK )
				llRetorno =  goServicios.Datos.ValidarExistenciaEnEntidad( this.oListaDePrecios, This.ModPrecios.Item[ i ].LPrecioA_PK, this ) and llRetorno
			endif
			if !empty( This.ModPrecios.Item[ i ].Formula_PK )
				This.ModPrecios.CargarItem( i )
				llRetorno = This.ModPrecios.oItem.Formula.ValidarExistenciaDeListasDePrecios( this ) and llRetorno
			endif
		endfor
		if !llRetorno
			This.AgregarInformacion( "Se encontraron errores al validar las Listas de Precios especificadas en el detalle de Listas de Precios y/o Fórmulas a aplicar." )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeRedondeos() as Boolean
		local i as Integer, llRetorno as Boolean
		llRetorno = .t.
		for i = 1 to This.ModPrecios.Count
			if !empty( This.ModPrecios.Item[ i ].Redondeo_PK )
				llRetorno = goServicios.Datos.ValidarExistenciaEnEntidad( this.oRedondeo, This.ModPrecios.Item[ i ].Redondeo_PK, this) and llRetorno
			endif
			if !empty( This.ModPrecios.Item[ i ].Formula_PK )
				This.ModPrecios.CargarItem( i )
				llRetorno = This.ModPrecios.oItem.Formula.ValidarExistenciaDeRedondeos( this ) and llRetorno
			endif
		endfor
		if !llRetorno
			This.AgregarInformacion( "Se encontraron errores al validar los códigos de Redondeos especificados en el detalle de Listas de Precios y/o Fórmulas a aplicar." )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeCotizaciones() as Boolean
		local i as Integer, llRetorno as Boolean
		llRetorno = .t.
		for i = 1 to This.ModPrecios.Count
			if !empty( This.ModPrecios.Item[ i ].Formula_PK )
				This.ModPrecios.CargarItem( i )
				llRetorno = This.ModPrecios.oItem.Formula.ValidarExistenciaDeCotizaciones( this ) and llRetorno
			endif
		endfor
		if !llRetorno
			This.AgregarInformacion( "Se encontraron errores al validar las cotizaciones especificadas en las Fórmulas a aplicar." )
		endif
		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		Local llRetorno as boolean, llVotacion as boolean
		llRetorno = .T.
		llRetorno = dodefault()
		With This
			llRetorno = .ValidarPorcentajes() and llRetorno
			llRetorno = .ValidarPrecioDirecto() and llRetorno
			llRetorno = .ValidarItemsDeTipoDeAccionFormula() and llRetorno
			llRetorno = .ValidarExistenciaDeListasDePrecios() and llRetorno
			llRetorno = .ValidarExistenciaDeRedondeos() and llRetorno
			llRetorno = .ValidarExistenciaDeCotizaciones() and llRetorno
		endwith
		return llRetorno
	EndFunc	

	*--------------------------------------------------------------------------------------------------------
	function Setear_UsaCombinacion( txVal as variant ) as void
		dodefault( txVal )
		if this.EsNuevo() or This.EsEdicion()
			This.HabilitarControlesFiltrosCombinacion( .t. )
			This.SetearValoresFiltrosCombinacion()
			This.HabilitarControlesFiltrosCombinacion( this.UsaCombinacion )	
		endif	
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarControlesFiltrosCombinacion( tlHabilitar as Boolean ) as Void
		tlHabilitar = iif( this.f_Articulo_Comportamiento_Desde = 4, .f., tlHabilitar )
		This.lHabilitarf_Color_Desde_PK = tlHabilitar
		This.lHabilitarf_Color_Hasta_PK = tlHabilitar
		if pemstatus( this, "f_Talle_Desde_PK", 5 ) and pemstatus( this, "f_Talle_Hasta_PK", 5 )
			This.lHabilitarf_Talle_Desde_PK = tlHabilitar
			This.lHabilitarf_Talle_Hasta_PK = tlHabilitar
		else
			This.lHabilitarf_Talle_Desde = tlHabilitar
			This.lHabilitarf_Talle_Hasta = tlHabilitar
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValoresFiltrosCombinacion() as Void
		local lnLargoColor as Integer, lnLargoTalle AS Integer, lcXML as String, lcCursor as String	
		
		lcCursor = sys( 2015 )	
		lcXML = This.obtenerdatosentidad( "f_Color_Desde,f_Talle_Desde", "" )
		This.XMLaCursor( lcXML, lcCursor )
		lnLargoColor = len( &lcCursor..f_Color_Desde )
		lnLargoTalle = len( &lcCursor..f_Talle_Desde )
		use in Select( lcCursor )

		if this.UsaCombinacion and this.f_Articulo_Comportamiento_Desde != 4
			this.f_Color_Desde_Pk = space( lnLargoColor )
			this.f_Color_Hasta_Pk = replicate( "Z", lnLargoColor )
			if pemstatus( this, "f_Talle_Desde_PK", 5 ) and pemstatus( this, "f_Talle_Hasta_PK", 5 )
				this.f_Talle_Desde_PK = space( lnLargoTalle )
				this.f_Talle_Hasta_PK = replicate( "Z", lnLargoTalle )
			else
				this.f_Talle_Desde = space( lnLargoTalle )
				this.f_Talle_Hasta = replicate( "Z", lnLargoTalle )
			endif
		else
			this.f_Color_Desde_Pk = space( lnLargoColor )
			this.f_Color_Hasta_pk = space( lnLargoColor )
			if pemstatus( this, "f_Talle_Desde_PK", 5 ) and pemstatus( this, "f_Talle_Hasta_PK", 5 )
				this.f_Talle_Desde_PK = space( lnLargoTalle )
				this.f_Talle_Hasta_PK = space( lnLargoTalle )
			else 
				this.f_Talle_Desde = space( lnLargoTalle )
				this.f_Talle_Hasta = space( lnLargoTalle )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearFiltrosComportamiento( ) as Void
		local lcVal as String, lnVal as Integer
		lcVal = This.Articulo_comportamiento
		lnVal = round( val( lcVal ), 0 )
		if empty( lcVal )
			this.f_Articulo_Comportamiento_Desde = 0
			this.f_Articulo_Comportamiento_Hasta = 9
		else
			this.f_Articulo_Comportamiento_Desde = lnVal
			this.f_Articulo_Comportamiento_Hasta = lnVal
		endif
		if inlist( lnVal, 4, 5 )
			this.lHabilitarPrecioKitPackxParticipante = .t.
		else
			this.PrecioKitPackxParticipante = .f.
			this.lHabilitarPrecioKitPackxParticipante = .f.
		endif
		if this.EsNuevo() or This.EsEdicion()
			This.SetearValoresFiltrosCombinacion()
			This.HabilitarControlesFiltrosCombinacion( this.UsaCombinacion )	
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarIngresoFiltrosCombinacion() as Boolean
		local llRetorno as Boolean, lnLargoColor as Integer, lnLargoTalle AS Integer
		
		lnLargoColor = len( this.f_Color_Desde_Pk )
		lnLargoTalle = iif( pemstatus( this, "f_Talle_Desde_PK", 5 ), len( this.f_Talle_Desde_PK ), len( this.f_Talle_Desde ) )
		
		llRetorno = .f.
		if this.UsaCombinacion 
			if this.f_Color_Desde_Pk != space( lnLargoColor ) or this.f_Color_Hasta_Pk != replicate( "Z", lnLargoColor )
				llRetorno = .t.
			else
				if pemstatus( this, "f_Talle_Desde_PK", 5 ) and pemstatus( this, "f_Talle_Hasta_PK", 5 )
					if this.f_Talle_Desde_PK != space( lnLargoTalle ) or this.f_Talle_Hasta_PK != replicate( "Z", lnLargoTalle )
						llRetorno = .t.
					endif
				else
					if this.f_Talle_Desde != space( lnLargoTalle ) or this.f_Talle_Hasta != replicate( "Z", lnLargoTalle )
						llRetorno = .t.
					endif
				endif
			endif
		else
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function BindearEventoHaCambiado() as Void
		This.BindearEvento( This.ModPrecios.oItem, "HaCambiado", This, "ProcesarItemDeModificacionDePrecios" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarItemDeModificacionDePrecios( tcAtributo as string, toItem as object ) as Void
		if inlist( upper( alltrim( tcAtributo ) ), "ACCION" )
			with this.ModPrecios.oItem
				do case
					case .EsAccionFormula()
						.LPrecioA_PK = ""
						.Valor = 0
					case .EsAccionPrecioDirecto()
						.LPrecioA_PK = ""
						.Formula_PK = ""
					otherwise
						.Formula_PK = ""
				endcase
			endwith
		endif
	endproc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFormulaDefinidaPorElUsuario( toItem as Object ) as String
		local lcRetorno as String
		lcRetorno = alltrim( toItem.Formula.ObtenerExpresionAEvaluar() )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarPreciosDeListasIncluidasEnLaFormula( tcCursorPrecioArticulo as String, toItem as Object ) as void
		local loMapeosDeListasDePrecios as zoocoleccion OF zoocoleccion.prg, loFormula as Object, loMapeo as String, lcNuevoCampo as String
		loFormula = toItem.Formula
		loMapeosDeListasDePrecios = loFormula.ObtenerMapeosDeListasDePrecios()
		for each loMapeo in loMapeosDeListasDePrecios foxobject
			lcNuevoCampo = sys( 2015 )
			with this
				.AgregarNuevoCampoParaPrecio( tcCursorPrecioArticulo, lcNuevoCampo )
				.AgregarMapeoDeFuncionPrecioDeLista( loMapeo, tcCursorPrecioArticulo + "." + lcNuevoCampo, toItem.Formula )
				.CompletarCampoParaPrecio( tcCursorPrecioArticulo, lcNuevoCampo, loMapeo.ElementoDeLaFormula, toItem )
				.oColCamposABorrar.Agregar( lcNuevoCampo )
			endwith
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarMapeoDeFuncionPrecioDeLista( toMapeo as Object, tcElementoAEvaluar as String, toFormula as Object  ) as Void
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
	protected function CompletarCampoParaPrecio( tcCursorPrecioArticulo as String, tcNuevoCampo as String, tcListaDePrecios as String, toItem as Object ) as void
		local lcCursor as String, lcCampo as String, lcCamposDeCombinacionConcatenados as String, lcCombinacionABuscar as String, ;
			lnCantCamposDeCombinacion as Integer, lcCamposDeCombinacionPrioridadUno as String, lcCamposDeCombinacionPrioridadDos as String, ;
			lcCamposDeCombinacionPrioridadTres as String

		if reccount( tcCursorPrecioArticulo ) > 0
			if this.PrecioKitPackxParticipante
				lcCursor = this.ObtenerCursorPreciosDeArticuloSegunParticipantes( toItem.NroItem, tcListaDePrecios )
			else
				lcCursor = this.ObtenerCursorPreciosDeArticulo( toItem.NroItem, tcListaDePrecios )
			endif

			select ( lcCursor ) 
			lcIndexar = 'index on ' + strtran( goServicios.Estructura.ObtenerCamposAtributosCombinacionConcatenados(), ", ", " + " ) + ' tag "Codigo"'
			&lcIndexar 
			lcCamposDeCombinacionConcatenados = this.cCamposDeCombinacionConcatenados
			lnCantCamposDeCombinacion = alines( lcCamposDeCombinacion, lcCamposDeCombinacionConcatenados, "+" )
			lcCamposDeCombinacionPrioridadUno = lcCamposDeCombinacion(1) + "+" + lcCamposDeCombinacion(2) + "+" + "space(len(" + lcCamposDeCombinacion(3) + "))"
			lcCamposDeCombinacionPrioridadDos = lcCamposDeCombinacion(1) + "+" + "space(len(" + lcCamposDeCombinacion(2) + "))" + "+" + lcCamposDeCombinacion(3)
			lcCamposDeCombinacionPrioridadTres = lcCamposDeCombinacion(1) + "+" + "space(len(" + lcCamposDeCombinacion(2) + "))" + "+" + "space(len(" + lcCamposDeCombinacion(3) + "))"
			
			select ( tcCursorPrecioArticulo )
			scan all
				lcCombinacionABuscar = &lcCamposDeCombinacionConcatenados
				select ( lcCursor )
				if seek( lcCombinacionABuscar, lcCursor )
					replace &tcNuevoCampo with nvl(&lcCursor..PDirecto,0) in ( tcCursorPrecioArticulo )
				else 
					select ( tcCursorPrecioArticulo )
					lcCombinacionABuscar = &lcCamposDeCombinacionPrioridadUno 
					if seek( lcCombinacionABuscar, lcCursor )
						replace &tcNuevoCampo with nvl(&lcCursor..PDirecto,0) in ( tcCursorPrecioArticulo )
					else
						select ( tcCursorPrecioArticulo )
						lcCombinacionABuscar = &lcCamposDeCombinacionPrioridadDos 
						if seek( lcCombinacionABuscar, lcCursor )
							replace &tcNuevoCampo with nvl(&lcCursor..PDirecto,0) in ( tcCursorPrecioArticulo )
						else
							select ( tcCursorPrecioArticulo )
							lcCombinacionABuscar = &lcCamposDeCombinacionPrioridadTres 
							if seek( lcCombinacionABuscar, lcCursor )
								replace &tcNuevoCampo with nvl(&lcCursor..PDirecto,0) in ( tcCursorPrecioArticulo )
							endif
						endif
					endif
				endif
				select ( tcCursorPrecioArticulo )
			endscan
			use in select( lcCursor )
			
		endif
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
	protected function ObtenerMensajeALoguearPorErrorAlAplicarLaFormula( tcCursor as String, toError as zooexception OF zooexception.prg, tcListaDePrecios as String ) as String
		local lcRetorno as String, lcCampo as String, lcCombinacion as String, i as Integer, llEsCombinacion as Boolean
		lcCombinacion = ""
		llEsCombinacion = .f.
		for i = 1 to getwordcount( this.cCamposDeCombinacionConcatenados, "+" )
			lcCampo = getwordnum( this.cCamposDeCombinacionConcatenados, i, "+" )
			if !empty( &tcCursor..&lcCampo. )
				if i > 1
					lcCombinacion = lcCombinacion + "+ ' - ' +"
					llEsCombinacion = .t.
				endif
				lcCombinacion = lcCombinacion + "alltrim( " + tcCursor + "." + lcCampo + " )"
			endif
		endfor

		lcRetorno = "No fue posible actualizar el precio " + iif( llEsCombinacion, "de la combinación ", "del artículo " ) + &lcCombinacion + " para la lista de precios " + alltrim( tcListaDePrecios ) + ;
			" Error: " + toError.Message + iif( isnull( toError.Details ), "", " " + toError.Details )
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Grabar() as Void
		local lnCodigo as numeric, llEsNuevo as Boolean, llEsEdicion as Boolean
		
		lnCodigo = this.Codigo
		llEsNuevo = this.EsNuevo()
		llEsEdicion = this.EsEdicion()
		
		if this.lUsarPreciosConVigencia
		else
			this.FechaVigencia = date()
			this.FechaBase = date()
		endif
		
		dodefault()
		this.EventoMensajeProcesando( "Calculando precios..." )	
		try
			this.ActualizarPrecios()
		catch to loError
			if lnCodigo != this.Codigo
				lnCodigo = this.Codigo
			endif
			loSentencias = this.obtenersentenciasdelete()
			loTalonario = _screen.zoo.instanciarentidad( "Talonario" )
			loTalonario.Codigo = this.oNumeraciones.obtenerTalonario( "CODIGO" )
			loTalonario.modificar()
			loTalonario.Numero = loTalonario.Numero - 1
			loTalonario.grabar()
			loTalonario.release()

			for each lcSentenciaEliminar in loSentencias foxobject
				goServicios.Datos.EjecutarSentencias( lcSentenciaEliminar , "calcpre", "", "", this.DataSessionId )
			endfor
			loEx = _screen.zoo.crearobjeto ( "ZooException" )			
			this.lNuevo = llEsNuevo
			this.lEdicion = llEsEdicion
			With loEx				
				.Grabar( loError )
				.AgregarInformacion( "Se produjo un error al actualizar precios" )
				goServicios.Errores.LevantarExcepcion( loEx )
			EndWith
		endtry
		
		this.EventoFinMensajeProcesando()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AntesDeAnular() as Void
		dodefault()
		this.BindearEvento( this.oAD, "AntesEndTransaction", this, "EjecutarSentenciasDeEliminacionPorEntidad" )
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function EjecutarSentenciasDeEliminacionPorEntidad() As Void
		local loComponente as ComponentePrecios of ComponentePrecios.prg, loCol as zoocoleccion OF zoocoleccion.prg 

		dodefault()
		if this.EstaAnulado()
			loComponente = _screen.zoo.instanciarcomponente( "ComponentePrecios" )
			loComponente.oEntidadPadre = this
			
			loCol = _screen.zoo.crearobjeto( "ZooColeccion" )
			loComponente.AgregarSentenciasDeEliminacionPorEntidad( @loCol )

			for each lcSentencia in loCol foxObject
				goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "", this.DataSessionId )
			endfor 
			loComponente.release()
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeAnular() as Void
		this.DesBindearEvento( this.oAD, "AntesEndTransaction", this, "EjecutarSentenciasDeEliminacionPorEntidad" )
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ModificaWhereParaFiltroDePrecio(tcSelect as String, tcWhere as String) as String
		local lcWhere as String, lcReemplazar as String
		lcWhere = strtran(tcWhere, "ObtenerPrecioRealDeLaCombinacionConVigencia", "ObtenerPrecioDeLaCombinacionConVigencia")
		lcReemplazar = ''
		lcWhere = strtran( lcWhere, "PRECIOAR.PDIRECTO >= "+transform( This.f_PRECIODIRECTO_Desde )+" and PRECIOAR.PDIRECTO <= "+transform( This.f_PRECIODIRECTO_Hasta )+" and", lcReemplazar )
		return lcWhere
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerString( tcSelect as String ) as String
		local lcCadena as String,lcPrimerCampo as String, lcSegundoCampo as String,lcTercercampo as String
		lcPrimerCampo =substr(tcSelect,atc(".", tcSelect, 1)+1,atc(",",tcSelect,1)-atc(".", tcSelect, 1)-1)
		lcSegundoCampo =substr(tcSelect,atc(".", tcSelect, 2)+1,atc(",",tcSelect,2)-atc(".", tcSelect, 2)-1)
		lcTercercampo =substr(tcSelect,atc(".", tcSelect, 3)+1,atc(",",tcSelect,3)-atc(".", tcSelect, 3)-1)
		
		lcCadena = "PRECIOAR." + lcPrimerCampo + " , PRECIOAR." + lcSegundoCampo + ", PRECIOAR." + lcTercercampo + ", '"
		return lcCadena
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTodasLasListasDePrecios() as Object
		local loRetorno as Object, lcFiltro as String, llNivel1 as Boolean, llNivel2 as Boolean, llNivel3 as Boolean
		
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		
		llNivel1 = goServicios.Seguridad.PedirAccesoMenu( "CALCULODEPRECIOS" + "_VERLP_N" + transform(1), .T. )
		llNivel2 = goServicios.Seguridad.PedirAccesoMenu( "CALCULODEPRECIOS" + "_VERLP_N" + transform(2), .T. )
		llNivel3 = goServicios.Seguridad.PedirAccesoMenu( "CALCULODEPRECIOS" + "_VERLP_N" + transform(3), .T. )
		
		if llNivel1 and llNivel2 and llNivel3
			lcXMLCursor = this.oListaDePrecios.oAd.ObtenerDatosEntidad( "Codigo" )
		else
			lcFiltro = iif( llNivel1, " NivelVisibilidad = " + transform(0),"")
			lcFiltro = lcFiltro + iif( llNivel2, iif(!empty(lcFiltro)," or ","") + " NivelVisibilidad = " + transform(1),"")
			lcFiltro = lcFiltro + iif( llNivel3, iif(!empty(lcFiltro)," or ","") + " NivelVisibilidad = " + transform(2),"")
			lcXMLCursor = this.oListaDePrecios.oAd.ObtenerDatosEntidad( "Codigo", lcFiltro )
		endif
		
		if !empty(lcXMLCursor)
			this.XmlACursor( lcXMLCursor, "C_Listas" )
			if reccount("C_Listas")> 0
				scan
					loRetorno.add( C_Listas.Codigo )
				endscan
			endif
		endif
		use in select ("C_Listas")

		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerXMLListasDePrecios( tcCursorPrecios as String ) as Object
		local lcXMLPrecios as String, lcFiltro as String, llNivel1 as Boolean, llNivel2 as Boolean, llNivel3 as Boolean
		
		select distinct listapre from &tcCursorPrecios into cursor "cListasAfectadas"
		
		llNivel1 = goServicios.Seguridad.PedirAccesoMenu( "CALCULODEPRECIOS" + "_VERLP_N" + transform(1), .T. )
		llNivel2 = goServicios.Seguridad.PedirAccesoMenu( "CALCULODEPRECIOS" + "_VERLP_N" + transform(2), .T. )
		llNivel3 = goServicios.Seguridad.PedirAccesoMenu( "CALCULODEPRECIOS" + "_VERLP_N" + transform(3), .T. )
		
		if llNivel1 and llNivel2 and llNivel3
			lcXMLPrecios = this.oListaDePrecios.oAd.ObtenerDatosEntidad( "Codigo, Nombre, OrdenConsulta" )		
		else 
			lcFiltro = ""
			lcFiltro = lcFiltro + iif( llNivel1, " NivelVisibilidad = 0","")
			lcFiltro = lcFiltro + iif( llNivel2, iif(empty(lcFiltro),""," or ") + " NivelVisibilidad = 1","")
			lcFiltro = lcFiltro + iif( llNivel3, iif(empty(lcFiltro),""," or ") + " NivelVisibilidad = 2","")
			if !empty(lcFiltro)
				lcFiltro = " (" + lcFiltro + ")"
				lcXMLPrecios = this.oListaDePrecios.oAd.ObtenerDatosEntidad( "Codigo, Nombre, OrdenConsulta", lcFiltro )
			endif
		endif
		
		this.xmlaCursor( lcXMLPrecios, "CListasDePrecios")
		update CListasDePrecios set OrdenConsulta = 4 where OrdenConsulta = 0
		delete from CListasDePrecios where codigo not in ( select listapre from cListasAfectadas)
		select * from CListasDePrecios order by ordenConsulta asc into cursor "cursorDevuelve"
		lcXmlRetorno = this.CursoraXML( "cursorDevuelve" )
		
		use in select ("CListasDePrecios")
		use in select ("cListasAfectadas")
		use in select ("cursorDevuelve")
		
		return lcXmlRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsAccionFormula( toItem as Object ) as Void
		return ( alltrim( toItem.Accion ) == "4" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidad( lcAtributo ) as String
		loAtributo = _screen.Zoo.InstanciarEntidad( lcAtributo )
		lcXMLAtributo = loAtributo.oAd.ObtenerDatosEntidad( "Codigo, Descripcion" )
		loAtributo.release()
		return lcXMLAtributo
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosCombinacion() as Object
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		loAtributos = AtributosCombinacionFactory()
		for each lcAtri as String in loAtributos foxobject
			if atc("_pk",lcAtri) != 0
				lcAtributo = substr( lcAtri, 1, len( lcAtri ) - 3 )
				loRetorno.add( lcAtributo )
			endif
		endfor
	
		return loRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function ProcesarRespuesta( loRespuesta as Object ) as void
		local lnInd as Integer
		for lnInd  = 0 to loRespuesta.Precios.count -1
			consulta = "update " + this.cCursorDefinitivo + loRespuesta.precios.Item[lnInd]
			&consulta
		endfor	

		if ctod( loRespuesta.FechaVigencia ) !=	this.FechaVigencia
			consultaFecha = "update " + this.cCursorDefinitivo + " set fechavig	= {" + loRespuesta.FechaVigencia + "}"
			&consultaFecha
			this.FechaVigencia = ctod( loRespuesta.FechaVigencia )
			lcSentencia = "update Zoologic.calcprec set fechavig = '" +alltrim( loRespuesta.FechaVigencia ) + "' where codigo = " + alltrim( str( this.Codigo ) )
			goServicios.Datos.EjecutarSentencias( lcSentencia , "calcpre", "", "", this.DataSessionId )
		endif
		
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDatosDeEntidadesParaNet() as Object
		local loEntidades as Object, loAtributos as Object, locampos as Object
		loEntidades = this.oFactoriaPrePantalla.ObtenerEntidades()		
		loAtributos = this.ObtenerAtributosCombinacion()
		loCampos = alines(loArrayCampos, lcCamposCombinacion,",")
		for i=1 to loAtributos.count
			loEntidades.add( this.oFactoriaPrePantalla.ObtenerEntidad( alltrim( loAtributos.Item[i] ), alltrim( lower( loArrayCampos( i ) ) ), this.ObtenerEntidad( loAtributos.Item[i] ) ) )
		endfor	
		
		return loEntidades
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemDeLista( tcLista as String ) as Object
		local loItem as Object

		loItem = this.ModPrecios.CrearItemAuxiliar()
		with loItem
	 		.LPrecio_Pk = tcLista
	 		.LprecioA_Pk = tcLista
			.Accion = "1"
			.Valor = 0
		endwith
		
		return loItem
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerListasCalculadas() as Object
		local loItem as Object, lcListaAcutal as String, lnUltimo as String, llEsUltimo as Boolean
		
		this.LimpiarInformacion()
		loCalculadas = _screen.zoo.instanciarentidad( "LISTADEPRECIOSCALCULADA" )
		loRetorno = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		llEsUltimo = .f.
		with loCalculadas
			.Ultimo()
			lnUltimo = .numero 
			.Primero()
			lcListaActual = ""

			do while !llEsUltimo and .numero <= lnUltimo
				llEsUltimo = iif(.numero == lnUltimo,.t.,.f.)
				try
					lcListaActual = .ListaDePrecios.Codigo
					if loRetorno.Buscar( lcListaActual )
					else
						if lcListaActual > ''
							loRetorno.add( lcListaActual, lcListaActual )
						endif
					endif
				catch
					this.AgregarInformacion( 'La lista de precios ' + alltrim( transform( .ListaDePrecios_PK ) );
						+ ' no existe y está siendo utilizada por la asignación de fórmula a lista de precios número ';
						+ rtrim( transform( .Numero ) ) + '.', 9001 )
					lcListaActual = .ListaDePrecios_PK
				finally
					.Siguiente()
				endtry
			enddo			
		endwith		
		loCalculadas.release()
		
		if this.HayInformacion()
			goServicios.Errores.LevantarExcepcion()
		endif
		
		return loRetorno 
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	protected function CompletarListas() as Void
		local lnJ as Integer
		if this.ModPrecios.Count = 0
			loListas = this.ObtenerTodasLasListasDePrecios()
			for lnJ = 1 to loListas.Count
					this.ModPrecios.Add( this.ObtenerItemDeLista( loListas.Item[lnJ] ) )
			endfor	 
			loListas.release()			
		endif
		endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function PasarListasAString( toListas ) as String
		local loItem as Object
		
		lcRetorno = ""
		lnCantidadListas = 1
		for each Lista in toListas foxobject
			lcRetorno = lcRetorno + alltrim( Lista )
			if lnCantidadListas < toListas.count
				lcRetorno = lcRetorno + ","
			endif
		endfor
		return lcRetorno
	endfunc	

	*-----------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		if this.modPrecios.count = 0
			this.eventoConfirmarSinListas()
		endif
		if this.lConfirmacion
			llRetorno = dodefault()
		else
			llRetorno = .f.
		endif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function VerConfirmacion() as boolean
		return this.lVisualizacion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function QuitarListasRepetidas( lcCursor as String ) as boolean
		select listapre, timestampa from ( lcCursor ) group by listapre, timestampa into cursor "cur_listaTimestamp"
		select listapre from ( lcCursor ) group by listapre into cursor "cur_lista"
		loListas = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		if reccount( "cur_listaTimestamp" ) != reccount( "cur_lista" )
			select "cur_listaTimestamp"
			go top
			lcLista= ""
			scan
				if lcLista = listapre
					llEsta = .f.
					if loListas.count > 0
						for each lista in loListas foxobject
							if listapre = lista
								llEsta = .t.
								exit
							endif
						endfor
					endif 
					if !llEsta
						loListas.add( listapre )
					endif
				endif			
				lcLista = listapre
			endscan
		endif
		use in select( "cur_lista" )
		if loListas.count > 0
			for each lista in loListas foxobject
				delete from ( lcCursor ) where listapre = alltrim( lista ) and timestampa != ( select top 1 timestampa from "cur_listaTimestamp" where listapre = lista order by timestampa desc )
			endfor
		endif
		use in select( "cur_listaTimestamp" )
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
	function ObtenerFechaBaseParaVigencia() as Date
		return this.FechaBase 
	endfunc
 	*-----------------------------------------------------------------------------------------
	function eventoGuardarMemoria() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function eventoCancelar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoCapturarMemoria() as Void
	endfunc 
	*-----------------------------------------------------------------------------------------
	function eventoConfirmarSinListas() as Void
	endfunc 
			
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
