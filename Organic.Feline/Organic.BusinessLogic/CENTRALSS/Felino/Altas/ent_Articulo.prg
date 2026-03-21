define class Ent_Articulo as Din_Entidadarticulo of Din_Entidadarticulo.prg

	#if .f.
		local this as Ent_Articulo of Ent_Articulo.prg
	#endif

	lPreguntarSiDebeEliminar = .f.
	NoPermiteDevoluciones  = .f.
	lHabilitaTotalizadores = .f.
	oArticuloParticipante = null
	
	#if .f.
		local this as Ent_Articulo of Ent_Articulo.prg
	#endif
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.lHabilitaTotalizadores = goServicios.Registry.Nucleo.HabilitarArticuloTotalizador
		this.lHabilitarParticipantesDetalle = .F.
		this.BindearEvento( this.ParticipantesDetalle.oItem, "EventoValidarRecursividad", this, "ValidarRecursividadDeKits" )
		this.BindearEvento( this.ParticipantesDetalle.oItem, "EventoValidarRecursividad", this, "ValidarNivelesDeKits" )
		this.BindearEvento( this.ParticipantesDetalle.oItem, "EventoValidarIngresoPack", this, "ValidarIngresoPack" )
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llRetorno as boolean
		
		llRetorno = dodefault()

		with this		
			if .ValidarPorcentajesIva()
			else
				llRetorno = .F.
				this.agregarInformacion("Error al validar el porcentaje de IVA", 0 )
			endif
		Endwith
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarPorcentajesIva() as boolean
		local llRetorno as boolean
		llRetorno = .T.
		with this
			if .CondicionIvaCompras = 3 and .PorcentajeIvaCompras <= 0.00
				this.agregarInformacion( "El porcentaje de IVA Compras debe ser mayor a cero." )
				llRetorno = .F.
			endif

			if .CondicionIvaVentas = 3 and .PorcentajeIvaVentas <= 0.00
				this.agregarInformacion( "El porcentaje de IVA Ventas debe ser mayor a cero." )
				llRetorno = .F.
			endif
		endwith

		return llRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_CondicionIvaCompras(  txValor as Integer ) as boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txValor )
		if llRetorno
			if !between( txValor, 0, 4 )
				local loEx as Exception
				loEx = Newobject(  "ZooException", "ZooException.prg" )
				With loEx
					.Message = "La condición de IVA Compras esta fuera de rango."
					.Details = .Message
					.Grabar()
					.Throw()
				endwith 
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_CondicionIvaVentas( txValor as Variant ) as boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txValor )
		if llRetorno
			if !between( txValor, 0, 4 )
				local loEx as Exception
				loEx = Newobject(  "ZooException", "ZooException.prg" )
				With loEx
					.Message = "La condición de IVA Ventas esta fuera de rango."
					.Details = .Message
					.Grabar()
					.Throw()
				endwith 
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarIngresoPack(tcArt) as Void
		local loart as Object, loex as Exception
		loart = _screen.zoo.instanciarentidad("articulo" )
		try
			loart.codigo = tcart
			if loart.comportamiento = 5
				this.agregarinformacion( "Un Pack no puede ser participante de otro Pack." )
			endif 
		catch
		finally
		loart.release()
		endtry 
		if this.hayinformacion()
			goservicios.errores.levantarexcepcion( this.oiNFORMACION)
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_Comportamiento( txValor as Variant ) as boolean
		local llRetorno as Boolean

		llRetorno = dodefault( txValor )
		if llRetorno
			if !between( txValor, 0, 5 )
				local loEx as Exception
				loEx = Newobject(  "ZooException", "ZooException.prg" )
				With loEx
					.Message = "La característica está fuera de rango."
					.Details = .Message
					.Grabar()
					.Throw()
				endwith 
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_CondicionIvaVentas( txValor as variant ) as void
		dodefault( txValor )
		this.HabilitarPorcentajeIvaVentasSegunCondicion( txValor )		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitarPorcentajeIvaVentasSegunCondicion( txValor as Variant ) as Void
		with this
			if txValor = 3
				.lHabilitarPorcentajeIvaVentas = .T.
			else 
				.PorcentajeIvaVentas = 0
				.lHabilitarPorcentajeIvaVentas = .F.
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_CondicionIvaCompras( txValor as variant ) as void
		dodefault( txValor )
		this.HabilitarPorcentajeIvaComprasSegunCondicion( txValor )			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitarPorcentajeIvaComprasSegunCondicion( txValor as variant ) as Void
		with this	
			if txValor = 3
				.lHabilitarPorcentajeIvaCompras = .T.
			else 
				.PorcentajeIvaCompras = 0
				.lHabilitarPorcentajeIvaCompras = .F.
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function actualizarEstado() as Void

		dodefault()
		this.lHabilitarComportamiento = this.lNuevo
		this.lHabilitarImprimedespacho = This.TieneModuloHabilitado()
		this.HabilitarCentroDeCostoSegunCondicion()

	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Eliminar() As void
	local llExisteStock as Boolean, llExistePrecio as Boolean, llEliminar as Boolean, loKits as Object, lcKit as String, lcKitsSeparadosPorComa as string
	
		lnMensaje = 0 
		llEliminar = .T.
		
		llExisteStock = this.ExisteCombinacionConStock()
		llExistePrecio = this.ExisteCombinacionConPrecio()
		
		if llExisteStock
			lnMensaje = 1
		endif 
		if llExistePrecio 
			lnMensaje = 2
		endif 
		
		if llExisteStock and llExistePrecio 
			lnMensaje = 3
		endif 

		if lnMensaje > 0 					
			this.lPreguntarSiDebeEliminar =  .f.
			this.EventoPreguntarSiEliminaPorStockOPrecioMayorACero( lnMensaje )
			if this.lPreguntarSiDebeEliminar
					llEliminar = .F.
			endif	
		endif
		
		if llEliminar
			loKits = this.ObtenerKitEnQueParticipa( this.Codigo )
			if loKits.Count > 0
				llEliminar = .T.
				lcKitsSeparadosPorComa = ""
				for each lcKit in loKits
					lcKitsSeparadosPorComa = lcKitsSeparadosPorComa + "'" + lcKit + "', " 
				endfor
				lcKitsSeparadosPorComa = Substr( lcKitsSeparadosPorComa, 1, Len( lcKitsSeparadosPorComa ) - 2 )
				goservicios.Errores.LevantarExcepcion( "No se puede eliminar. Este articulo es participante en el/los kit/s " + lcKitsSeparadosPorComa )
			endif
		endif
						
		if llEliminar
			dodefault()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteCombinacionConStock() as Boolean
		local loComponenteStock as Object, lcCursorStock as String, llRetorno as Boolean
		
		llRetorno = .f.
		
		loComponenteStock = _screen.zoo.instanciarcomponente( "ComponenteStock" )
		
		lcCursorStock = loComponenteStock.ConsultarStockDeArticulo( this.codigo )
		if vartype( lcCursorStock ) == "C" and !empty( lcCursorStock ) 
		
			this.xmlacursor( lcCursorStock, "c_StockDisp" )
			select c_StockDisp
			
			if reccount( "c_StockDisp" ) > 0 
				select * from c_StockDisp where sum_cantidad != 0 into cursor c_HayArtConStock		
				if _Tally > 0	
					llRetorno = .t.
				endif
			endif 
			
			use in select( "c_HayArtConStock" ) 
			use in select( "c_StockDisp" ) 		
			
		endif 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteCombinacionConPrecio() as Boolean
		local loComponentePrecio as Object, llRetorno as Boolean
		
		loComponentePrecio = _screen.zoo.instanciarcomponente( "componenteprecios" )
		llRetorno = loComponentePrecio.ExistePrecioDeArticuloEnCombinaciones( this.codigo ) 
		
		return llRetorno 
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiEliminaPorStockOPrecioMayorACero( tnMensaje as Integer ) as Void
		&& Evento para pedir confirmacion del usuario
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArticuloNoPermiteDevoluciones() as Boolean
		local llRetorno as Boolean
		llRetorno =	this.NoPermiteDevoluciones
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneModuloHabilitado() as Boolean
		local llRetorno as Boolean, loError as Object
		
		try
			llRetorno = goModulos.ModuloHabilitado( "N" )
		catch to loError
			llRetorno = .F.
		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneModuloContabilidad() as Boolean
		return goServicios.Modulos.TieneModuloHabilitadoSegunAlias("CONTABILIDAD")
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarCentroDeCostoSegunCondicion() as Void
		this.lHabilitarRequiereCCosto = this.TieneModuloContabilidad() or This.VerificarContexto( "CB" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerComportamiento( tcCodigo as String ) as Number
		local lnComp as Number
		llLimpiandoAux = this.lLimpiando
		this.lLimpiando = .T.
		this.codigo = tcCodigo
		this.lLimpiando = llLimpiandoAux
		if this.oad.ConsultarPorClavePrimaria()
			lnComp = nvl( c_ARTICULO.Comportamiento, 0 )
		endif
		return lnComp
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		local llRetorno as Boolean
		
		if this.comportamiento = 5
			this.SetearPorcentajeDeIvaAlPack()
		endif
		llRetorno = this.ValidarNoTipoKitNiConjuntoYParticipantes()
		llRetorno = llRetorno and this.ValidarKitSinParticipantes()
		llRetorno = llRetorno and this.ValidarConjuntoSinParticipantes()
		llRetorno = llRetorno and this.ValidarRestriccionDeDescuentosYParticipante()
		*llRetorno = llRetorno and this.ValidarRecursividadDeKits()
		if llRetorno
			llRetorno = llRetorno and dodefault()
		endif
		return llRetorno
	endfunc
	
	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		local llEsConjuntoOKit as Boolean
		dodefault()	
		llEsConjuntoOKit = ( this.EsArticuloTipoConjunto() or this.EsArticuloTipoKit() )
		this.HabilitarDeshabilitarAtributosSegunKit( llEsConjuntoOKit )			
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsArticuloTipoKit() as Boolean
		return this.Comportamiento = 4
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsArticuloTipoConjunto() as Boolean
		return this.Comportamiento = 5
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_Comportamiento( txValor as variant ) as void
		local llEsKit as Boolean, lnResultado as Integer, llSetear as Boolean
		llEsKit = ( txValor = 4 ) or (txValor = 5 )
		if !llEsKit and this.TieneItemsParticipantes() and !this.lCargando and !this.lLimpiando
			goServicios.Errores.LevantarExcepcion( "Para cambiar el tipo de comportamiento debe eliminar los participantes agregados." )
		endif
		dodefault( txValor )	
		this.HabilitarDeshabilitarAtributosSegunKit( llEsKit )
		this.eventoSetearCaptionSolapaKits( txValor = 5 )
		this.partICIPANTESDETALLE.oitem.tipocomportamiento = txvalor
				
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarDeshabilitarAtributosSegunKit( tlEsKit as Boolean ) as Void
		if tlEsKit
			if pemstatus( this, "CurvaDeTalles_pk", 5 )
				this.lHabilitarCurvaDeTalles_PK = .T.		
				this.CurvaDeTalles_pk = ""	
			endif
			if pemstatus( this, "PaletaDeColores_pk", 5 )
				this.lHabilitarPaletaDeColores_pk = .T.		
				this.PaletaDeColores_pk = ""
			endif
			this.lHabilitarImprimeDespacho = .T.
			this.ImprimeDespacho = .F.
			this.lHabilitarImportado = .T.
			this.Importado = .F.
			this.lHabilitarRequiereCCosto = .T.
			this.RequiereCCosto = 0
			this.lHabilitarSoloPromoYKit = .T.
			this.SoloPromoYKit = .F.
		else	
			this.HabilitarCentroDeCostoSegunCondicion()
			this.lHabilitarImprimeDespacho = This.TieneModuloHabilitado()
		endif	
		
		this.lHabilitarParticipantesDetalle = tlEsKit
		this.lHabilitarImportado = !tlEsKit		
		if pemstatus( this, "PaletaDeColores_pk", 5 )
			this.lHabilitarPaletaDeColores_pk = !tlEsKit
		endif
		if pemstatus( this, "CurvaDeTalles_pk", 5 )
			this.lHabilitarCurvaDeTalles_PK = !tlEsKit
		endif
		this.lHabilitarSoloPromoYKit = !tlEsKit				
		
		&& Datos fiscales
		this.lHabilitarCondicionIvaVentas = .t.
		this.lHabilitarPorcentajeIvaVentas = .t.
		this.lHabilitarCondicionIvaCompras = .t.
		this.lHabilitarPorcentajeImpuestoInterno = .t.
		
		if tlEsKit
			this.CondicionIvaVentas = 0
			this.lHabilitarCondicionIvaVentas = .f.
			this.PorcentajeIvaVentas = 0
			this.lHabilitarPorcentajeIvaVentas = .f.			
			this.CondicionIvaCompras = 0
			this.lHabilitarCondicionIvaCompras = .f.
			this.PorcentajeIvaCompras = 0						
			this.lHabilitarPorcentajeIvaCompras = .f.
			this.PorcentajeImpuestoInterno = 0
			this.lHabilitarPorcentajeImpuestoInterno = .f.
		else
			this.HabilitarPorcentajeIvaVentasSegunCondicion( this.CondicionIvaVentas )
			this.HabilitarPorcentajeIvaComprasSegunCondicion( this.CondicionIvaCompras )
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarParticipantes() as Void	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneItemsParticipantes() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .F.
		if this.ParticipantesDetalle.nCantidadDeItemsCargados > 0
			for each loItem in this.ParticipantesDetalle
				if loItem.Cantidad > 0
					llRetorno = .T.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarNoTipoKitNiConjuntoYParticipantes() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if !this.EsArticuloTipoKit() and !this.EsArticuloTipoConjunto() and this.TieneItemsParticipantes()
			llRetorno = .F.
			goServicios.Errores.LevantarExcepcion( "Debe eliminar los articulos participantes para poder grabar." )		
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarKitSinParticipantes() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.EsArticuloTipoKit() and !this.TieneItemsParticipantes()
			llRetorno = .F.
			goServicios.Errores.LevantarExcepcion( "El artículo tipo kit debe tener al menos un participante con cantidad mayor a cero." )		
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarConjuntoSinParticipantes() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.EsArticuloTipoConjunto() and !this.TieneItemsParticipantes()
			llRetorno = .F.
			goServicios.Errores.LevantarExcepcion( "El artículo tipo Pack debe tener al menos un participante con cantidad mayor a cero." )		
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarRestriccionDeDescuentosYParticipante() as Boolean
		local llRetorno as Boolean, loKits as Object, lcKitsSeparadosPorComa as String 
		llRetorno = .T.
		if this.RestringirDescuentos
			loKits = this.ObtenerKitEnQueParticipa( this.Codigo )
			if loKits.Count > 0
				lcKitsSeparadosPorComa = ""
				for each lcKit in loKits
					lcKitsSeparadosPorComa = lcKitsSeparadosPorComa + "'" + lcKit + "', " 
				endfor
				lcKitsSeparadosPorComa = Substr( lcKitsSeparadosPorComa, 1, Len( lcKitsSeparadosPorComa ) - 2 )
				goservicios.Errores.LevantarExcepcion( "El artículo no puede tener restricción de descuentos ya que es participante en el/los kit/s " + lcKitsSeparadosPorComa )
			endif
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarRecursividadDeKits() as Void
		local llRetorno as Boolean, loDetalleParticipantes as Object
		llRetorno = .T.
		if upper( rtrim( this.ParticipantesDetalle.oItem.Articulo_pk ) ) = upper( rtrim( this.Codigo ) )
			llRetorno = .F.
			goServicios.Errores.LevantarExcepcion( "Un articulo no puede ser su propio participante." )		
		endif
		loDetalleParticipantes = this.ObtenerParticipantes( this.ParticipantesDetalle.oItem.Articulo_pk )
		llRetorno = this.ValidarRecursividad( 1, loDetalleParticipantes )	
		if !llRetorno
			goServicios.Errores.LevantarExcepcion( "El código de artículo no puede ser ingresado com participante porque provoca recursividad entre kits." )		
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarRecursividad( tnPasadas as Integer, toParticipantes as Object ) as Boolean
		local loDetalleParticipantes as Object, llRetorno as Boolean
		llRetorno = .T.
		if toParticipantes.Count > 0
			if tnPasadas <= 3
				if this.BuscarKitEnDetalle( toParticipantes, this.Codigo )
					llRetorno = .f.
				else
					for each loItem in toParticipantes
						loParticipantes = this.ObtenerParticipantes( loItem.Articulo_pk )
						llRetorno = this.ValidarRecursividad( tnPasadas + 1, loParticipantes )
						if !llRetorno
							exit
						endif
					endfor
				endif
			endif
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function BuscarKitEnDetalle( toParticipantes as Object, tcCodigo as String ) as Boolean
		local loItem as Object, llRetorno as Boolean
		llRetorno = .F.
		for each loItem in toParticipantes 
			if upper( rtrim( loItem.Articulo_pk ) ) = upper( rtrim( this.Codigo ) )
				llRetorno = .T.
				exit
			endif
		endfor
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerParticipantes( tcArticulo as String ) as Object
		this.oArticuloParticipante.Codigo = tcArticulo
		return this.oArticuloParticipante.ParticipantesDetalle
	endfunc

	*-----------------------------------------------------------------------------------------
	function oArticuloParticipante_Access() as Void		
		if !this.lDestroy and !vartype( this.oArticuloParticipante ) == "O"
			this.oArticuloParticipante = _Screen.Zoo.InstanciarEntidad( "ARTICULO" )
		endif		
		return this.oArticuloParticipante
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		dodefault()
		this.oArticuloParticipante = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerKitEnQueParticipa( tcKit as String ) as Object
		local lcWhere as String, lcXml as String, lcCursor as String, loRetorno as Object
		lcWhere = "ARTICULO in ('" + tcKit + "')"
		lcCursor = sys( 2015 )
		loRetorno = _screen.zoo.crearObjeto( "ZooColeccion" )
		lcXml = this.oAD.obtenerDatosDetalleParticipantesDetalle( "CODIGO", lcWhere, "", "", "" )
		this.XmlACursor( lcXML , lcCursor )
		select distinct * from &lcCursor order by Codigo into cursor &lcCursor		
		select &lcCursor
		scan
			loRetorno.Agregar( upper( rtrim( Codigo ) ) )
		endscan	
		use in select ( lcCursor )	
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarNivelesDeKits() as Void
		local llRetorno as Boolean, loParticipantes as Object, lcParticipante as String, loParticipantesN2 as Object, lcParticipanteN2 as String, ;
			  loParticipantesN3 as Object, lcParticipanteN3 as String, lnNiveles as Integer, loKits as Object
			  
		llRetorno = .t.
		lnNiveles = 0
		loParticipantes = this.ObtenerKitsParticipantes( this.ParticipantesDetalle.oItem.Articulo_pk )
		if loParticipantes.Count > 0
			for each lcParticipante in loParticipantes
				&& si entra aca ya hay dos niveles de kits, si algunos de esta coleccion tambien tiene kits
				lnNiveles = 2
				loParticipantesN2 = this.ObtenerKitsParticipantes( lcParticipante )
				for each lcParticipanteN2 in loParticipantesN2
					&& aca tengo 3 niveles de kits (máximo)
					lnNiveles = 3
					loParticipantesN3 = this.ObtenerKitsParticipantes( lcParticipante )
					if loParticipantesN3.Count > 0
						&&un nivel mas no esta permitido
						llRetorno = .f.
					endif
				endfor
			endfor
		else
			if this.ObtenerComportamientoDeArticulo( this.ParticipantesDetalle.oItem.Articulo_pk ) = 4
				lnNiveles = 1
			endif
		endif
						
		if !llRetorno
			goServicios.Errores.LevantarExcepcion( "No se puede agregar el participante. Un kit soporta hasta un máximo de 3 niveles de kits." )
		else
			&& ahora debo fijarme que este kit no se participante de otro kit, y ese kit se pase de los 3 niveles permitidos
			&& teniendo en cuenta cuantos niveles tengo en ese kit
			this.ValidarNivelesDeKitsHaciaArriba( this.Codigo, lnNiveles ) 			
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarNivelesDeKitsHaciaArriba( tcKits as String, tnNiveles as Integer ) as Void
		local lnRetorno as Integer, loKits as, llValida as Boolean, lcKitsN2 as String
		llValida = .f.
		
		loKits = this.ObtenerKitEnQueParticipa( tcKits )
		
		if tnNiveles >= 3
			goServicios.Errores.LevantarExcepcion( "No se puede agregar el participante. Un kit soporta hasta un máximo de 3 niveles de kits." )
		else
			if loKits.Count > 0						
				lcKitsN2 = ""
				for each lcKit in loKits			
					this.ValidarNivelesDeKitsHaciaArriba( lcKit, tnNiveles + 1 )
					*lcKitsN2 = "'" + lcKit + "', "
				endfor		
				*lcKitsN2 = Substr( lcKitsN2, 1, Len( lcKitsN2 ) - 2 )	
				*this.ValidarNivelesDeKitsHaciaArriba( lcKitsN2, tnNiveles + 1 )	
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerKitsParticipantes( tcKit as String ) as Object
		local llRetorno as Boolean, lcCursor as String, lcXml as String, loRetorno as Object
		loRetorno = _screen.zoo.crearObjeto( "ZooColeccion" )
		lcCursor = sys( 2015 )
		lcXml = this.oAD.ObtenerDatosDetalleParticipantesDetalle( "Articulo", "Codigo = '" + tcKit + "' and Comportamiento = 4" )
		this.XmlACursor( lcXML , lcCursor )
		select &lcCursor
		scan
			loRetorno.Agregar( upper( rtrim( Articulo ) ) )
		endscan
		use in select ( lcCursor )
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerComportamientoDeArticulo( tcArticulo ) as Integer
		local lnRetorno as Integer
		lnRetorno = 0
		try
			this.oArticuloParticipante.Codigo = tcArticulo
			lnRetorno = this.oArticuloParticipante.Comportamiento
		catch					
		endtry
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsValidoAtributoObligatorio( tcAtributo, tcDescAtributo, tcDetalle ) as Void
		local llRetorno as Boolean
	
		llRetorno = .t.
		
		if this.DebeValidarAtributo( tcAtributo )
			llRetorno = dodefault( tcAtributo, tcDescAtributo, tcDetalle )
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeValidarAtributo( tcAtributo as String ) as Boolean
		local llRetorno
		if this.EsArticuloTipoKit()
			llRetorno = !inlist( upper( alltrim( tcAtributo ) ), "PALETADECOLORES", "CURVADETALLES" )
		else
			llRetorno = .t.
		endif		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetearCaptionSolapaKits( tlEsConjunto ) as Void

	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oAD_Access() as variant

		if !this.ldestroy and ( !vartype( this.oAD ) = 'O' or isnull( this.oAD ) )
			this.oAD = this.crearobjeto( "ent_ARTICULOAD_SQLSERVER" )
			this.oAD.InyectarEntidad( this )
			this.oAD.Inicializar()
		endif
		return this.oAD
	endfunc

   	*-----------------------------------------------------------------------------------------
	function PreprocesarCursorParaImportacionEnBloque( tcCursor as String ) as Void
	
		select( tcCursor )

		replace all	ARTCOD with upper(ARTCOD)
		replace all TipAgruPub with 0 for TipAgruPub > 3 && regla de negocio en ProcesoImportacion.PRG cuando no se importaba por bulk
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearPorcentajeDeIvaAlPack() as Void
		local lnPorcentajeMasAlto as Double, llHabilitarIVAAnterior as Boolean, llHabilitarCondicionAnterior as Boolean, lnPorcentajeIVAParticipante as Double,;
			  lnCondicionIVAParticipante as Integer
		
		if this.participantesdetalle.count > 0
			lHabilitarIVAAnterior = this.lHabilitarPorcentajeIvaVentas
			llHabilitarCondicionAnterior = this.lHabilitarCondicionIvaVentas
		
			for i = 1 to this.participantesdetalle.count
				this.participantesdetalle.cargaritem(i)
				lnPorcentajeIVAParticipante = this.participantesdetalle.oitem.articulo.porcentajeivaventas
				lnCondicionIVAParticipante = this.participantesdetalle.oitem.articulo.Condicionivaventas
				if i = 1
					lnPorcentajeMasAlto = lnPorcentajeIVAParticipante 
					lnCondicionIvaVentas = lnCondicionIVAParticipante 
				endif
				
				if lnPorcentajeIVAParticipante > lnPorcentajeMasAlto
					lnPorcentajeMasAlto = lnPorcentajeIVAParticipante 
					lnCondicionIvaVentas = lnCondicionIVAParticipante
				endif
				
				if lnCondicionIVAParticipante = 1 and goparametros.felino.datosimpositivos.ivainscriptos > lnPorcentajeMasAlto 
					lnPorcentajeMasAlto = goparametros.felino.datosimpositivos.ivainscriptos
					lnCondicionIvaVentas = lnCondicionIVAParticipante
				endif
			endfor
			
			this.lHabilitarPorcentajeIvaVentas = .T.
			this.lHabilitarCondicionIvaVentas = .T.
			
			this.Setear_Porcentajeivaventas( lnPorcentajeMasAlto )
			this.Setear_Condicionivaventas( lnCondicionIvaVentas )
			
			this.lHabilitarPorcentajeIvaVentas = lHabilitarIVAAnterior 
			this.lHabilitarCondicionIvaVentas = llHabilitarCondicionAnterior 
		endif
	endfunc 

enddefine
