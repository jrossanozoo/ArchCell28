define class Ent_ComprobanteMovInsumos as Ent_Comprobante of Ent_Comprobante.prg

	#if .f.
		local this as Ent_ComprobanteMovInsumos of Ent_ComprobanteMovInsumos.prg
	#endif

	lInvertirSigno = .T.
	lDebeAdvertirFaltantedestock = .t.

	*-----------------------------------------------------------------------------------------
	function AntesDeAnular() as Void
		this.RestaurarStock()
		DoDefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		if this.cNombre <> "FINALDEPRODUCCION"
			this.RestaurarStock()
			This.EliminarStockInicial()
		endif
		DoDefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		local lcDetalle as String

		lcDetalle = "this." + This.cDetalleComprobante
		llTmp = &lcDetalle

		dodefault()
		if type( "this." + This.cDetalleComprobante ) = "O"
			lcDetalle = This.cDetalleComprobante
			with this.&lcDetalle..oitem
				.lInvertirSigno = This.lInvertirSigno
				if .lControlaStock
					.oCompStockProduccion.nSigno = iif( This.lInvertirSigno, -1, 1 )
					.oCompStockProduccion.lInvertirSigno = This.lInvertirSigno
					.oCompStockProduccion.InyectarEntidad( this )
				endif
			endwith
		endif
	endfunc	

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaAccionesDelSistema( tnCantidadGenerados as Integer, tcNumeros as String, tcDescripcionComprobante as String ) as String
		local lcMensaje as string, ldFecha as date, lcFecha as String lcHora as String, lcMensajeSistema as String, lcCodigo as String, lcSentencia AS String
		
		ldFecha = goServicios.Librerias.ObtenerFecha()
		lcFecha = dtoc( ldFecha, 1 )
		lcHora = goServicios.Librerias.ObtenerHora()
		
		**lcMensaje =  dtoc( ldFecha ) + " - " + lcHora + " - "
		lcMensaje = ""
		if tnCantidadGenerados > 1
			lcMensaje = lcMensaje + "Se han generado los siguientes comprobantes de " + tcDescripcionComprobante + ": "
		else
			lcMensaje = lcMensaje + "Se ha generado el " + tcDescripcionComprobante + " Nº "
		endif
		lcMensaje = lcMensaje + tcNumeros + "."
		if !empty( this.ZadsFW )
			lcMensajeSistema = this.ZadsFW + chr(13) + lcMensaje 
		else
			lcMensajeSistema = lcMensaje 
		endif
		
		lcCodigo = this.codigo

		lcTabla = "[" + _Screen.Zoo.App.Obtenerprefijodb() + _screen.zoo.app.csucursalactiva + "].[" + alltrim( _screen.zoo.app.cSchemaDefault ) + "].["
		lcTabla = lcTabla + this.OAD.cTablaPrincipal + "]"

		text to lcSentencia noshow textmerge
			update <<lcTabla>> set ZadsFW = '<<lcMensajeSistema>>' ,
								   FModiFW = '<<lcFecha>>' , 
								   HModiFW = '<<lcHora>>' , 
								   UmodiFW = '<<goServicios.Seguridad.cUsuarioLogueado>>' , 
								   SmodiFW = '<<_Screen.Zoo.App.cSerie>>' , 
								   VmodiFW = '<<_screen.zoo.app.cVersionSegunIni>>' , 
								   BDmodiFW = '<<_screen.zoo.app.cSucursalActiva>>'
			where CODIGO = '<<lcCodigo>>'
		endtext

		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerOrigenDestinoParaBaseActiva() as String
		local lcBaseActiva as String, lcSucursal as String, loColaboradorParametros as Object
		loColaboradorParametros = _screen.zoo.crearobjeto( "ColaboradorParametros" )
		lcBaseActiva = _Screen.Zoo.App.cSucursalActiva
		lcSucursal = loColaboradorParametros.ObtenerParametroDeBaseDeDatos( 'Codigo Origen De Sucursal', lcBaseActiva )
		loColaboradorParametros = null
		return lcSucursal
	endfunc 

enddefine

