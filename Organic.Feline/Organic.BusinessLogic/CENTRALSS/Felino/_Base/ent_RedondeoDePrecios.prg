define class Ent_RedondeoDePrecios as Din_EntidadRedondeoDePrecios of Din_EntidadRedondeoDePrecios.prg 

	#IF .f.
		Local this as Ent_RedondeoDePrecios of Ent_RedondeoDePrecios.prg
	#ENDIF

	nRedondeo = 1 && Cambiar x un registro
	oRedondeo = Null
	dimension aTipoRedondeo[4]

	*-------------------------------------------------------------------------------------------------
	Function Nuevo() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()	
		this.RedondeoNormal = 3
		this.RedondeoPorTabla = 3
		This.CargarPreciosPreview()
		
		return llRetorno
	EndFunc	
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.oRedondeo = _screen.zoo.crearObjeto( "ZoologicSa.Redondeos.EntidadRedondeo" )
	endfunc 

    *-----------------------------------------------------------------------------------------
    Function Redondear( tnValor As float ) As float
		local lcXml as String, lnRetorno as float, lcXml as String
		lnRetorno = tnValor

		if this.CargaManual() 
			if tnValor != 0
				lnRetorno = this.oRedondeo.Redondear( tnValor )
			endif
		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarDetalleCentavos() as Void
		This.lhABILITARDETREDONDEOPORCENTAVO = This.habILITAREDONDEARTERMCENTAVOS
		This.EventoActualizarPreview()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarDetalleEnteros() as Void
		This.lhABILITARDETREDONDEOPORENTERO = THis.hABILITAREDONDEARTERMENTEROS
		This.EventoActualizarPreview()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function HabilitarDetallePrecios() as Void 
		this.lHabilitarDetRedondeoPorTabla = This.habILITAREDONEARPRECIOS
		This.lhabILITARREDONDEOPORTABLA = This.habILITAREDONEARPRECIOS
		This.EventoActualizarPreview()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected function HabilitarRedondeoNormal() as Void
		This.lhABILITARREDONDEONORMAL = This.habILITAREDONDEARNORMAL
		
		This.EventoActualizarPreview()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DetPrueba_access() as Void
		local loObject as Object 

		loObject = dodefault()
		if vartype( this.detPrueba ) = "O"
			this.DetPrueba.InyectarEntidad( this ) 
		endif
		
		Return loObject
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DetRedondeoPorTabla_Access() as Void
		local loObject as Object 

		loObject = dodefault()
		if vartype( this.DetRedondeoPorTabla ) = "O"
			this.DetRedondeoPorTabla.InyectarEntidadNet( this.oRedondeo ) 
		endif
		
		Return loObject
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DetRedondeoPorCentavo_Access() as Void
		local loObject as Object 

		loObject = dodefault()
		if vartype( this.DetRedondeoPorCentavo ) = "O"
			this.DetRedondeoPorCentavo.InyectarEntidadNet( this.oRedondeo ) 
		endif
		
		Return loObject
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DetRedondeoPorEntero_Access() as Void
		local loObject as Object 

		loObject = dodefault()
		if vartype( this.DetRedondeoPorEntero ) = "O"
			this.DetRedondeoPorEntero.InyectarEntidadNet( this.oRedondeo ) 
		endif

		Return loObject
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoActualizarPreview( tcAtributo As String, toItem as object ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreviewActualizado() as Void

	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Habilitaredondeartermenteros( txVal as variant ) as void

		dodefault( txVal )
		This.oRedondeo.Habilitaredondeartermenteros = txVal 
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Habilitaredonearprecios( txVal as variant ) as void

		dodefault( txVal )
		This.oRedondeo.Habilitaredonearprecios = txVal

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Habilitaredondearnormal( txVal as variant ) as void

		dodefault( txVal )
		this.oRedondeo.Habilitaredondearnormal = txVal

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Habilitaredondeartermcentavos( txVal as variant ) as void

		dodefault( txVal )
		this.oRedondeo.Habilitaredondeartermcentavos = txVal
		
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Redondeonormal( txVal as variant ) as void

		dodefault( txVal )
		this.oRedondeo.Redondeonormal = cast( txVal as I )

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Redondeoportabla( txVal as variant ) as void

		dodefault( txVal )
		this.oRedondeo.Redondeoportabla = cast( txVal as I )

	endfunc

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		dodefault()
		with This.oRedondeo
			.DetRedondeoPorTabla.Clear()
			.DetRedondeoPorCentavo.Clear()
			.DetRedondeoPorEntero.Clear()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CargarPreciosPreview() as Void
		local loColPrecios as zoocoleccion OF zoocoleccion.prg, lnPrecio As Object
		
		loColPrecios = This.ObtenerListaDePreciosPreview()
		
		for each lnPrecio in loColPrecios foxObject
			With This.DetPrueba
				.LimpiarItem()
				.oItem.Precio = lnPrecio
				.Actualizar()
			EndWith
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function ObtenerListaDePreciosPreview() as zoocoleccion OF zoocoleccion.prg
		local loColPreciosPreview as zoocoleccion OF zoocoleccion.prg, lcPrecios as String ,;
			lnCantidadPrecios as Integer
		
		lcPrecios = alltrim( goRegistry.Felino.PreciosParaPreviewRedondeoDePrecios )
		lnCantidadPrecios = alines( laPrecios, lcPrecios, "," )
		
		loColPreciosPreview = _screen.zoo.crearobjeto( "zooColeccion" )
		
		for i = 1 to lnCantidadPrecios
			loColPreciosPreview.Add( val( laPrecios[ i ] ) / 100 )
		endfor

		return loColPreciosPreview
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerListaDeRedondeos() as Object
		local loRetorno as Object, lcCursor as String, loFactoriaPromociones as Object, loPromocion as Object, loSerializador as Object
		loFactoriaPromociones = _screen.Zoo.CrearObjeto( "ZooLogicSA.Promociones.FactoriaPromociones" )
		loSerializador = _screen.Zoo.CrearObjeto( "ZooLogicSA.Promociones.Serializador" )
		lcXmlEntidad = this.ObtenerDatosEntidad( "", "", "", "" )
		lcXmlDetTabla = this.oAD.ObtenerDatosDetalleDetRedondeoPorTabla( "", "", "", "" )
		lcXmlDetCent = this.oAD.ObtenerDatosDetalleDetRedondeoPorCentavo( "", "", "", "" )
		lcXmlDetEnt = this.oAD.ObtenerDatosDetalleDetRedondeoPorEntero( "", "", "", "" )
		loRedondeos = loFactoriaPromociones.ObtenerRedondeos( lcXmlEntidad, lcXmlDetTabla, lcXmlDetCent, lcXmlDetEnt )
		return loRedondeos
	endfunc
	
enddefine
