define class EntidadDeProduccion As Entidad Of Entidad.prg

	#If .F.
		Local This As EntidadDeProduccion As EntidadDeProduccion.prg
	#Endif

	oColaboradorProduccion = null

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorProduccion_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oColaboradorProduccion ) = 'O' or isnull( this.oColaboradorProduccion ) )
				this.oColaboradorProduccion = _Screen.zoo.CrearObjetoPorProducto( 'ColaboradorProduccion' )
			endif
		endif
		return this.oColaboradorProduccion
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorColorEnCurva( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaOrden as String, lccondicionAnulado as String
		toBusqueda.Tabla = toBusqueda.Tabla + "," + this.oAd.cTablaPrincipal 
		lcTablaOrden = iif( !empty( this.oAd.cEsquema ), this.oAd.cEsquema + ".", "" ) + this.oAd.cTablaPrincipal
		toBusqueda.Filtro = toBusqueda.Filtro + " and modeloprod.codigo not in ( select modelo from " + lcTablaOrden + " )"
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorTalleEnCurva( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaOrden as String, lccondicionAnulado as String
		toBusqueda.Tabla = toBusqueda.Tabla + "," + this.oAd.cTablaPrincipal 
		lcTablaOrden = iif( !empty( this.oAd.cEsquema ), this.oAd.cEsquema + ".", "" ) + this.oAd.cTablaPrincipal
		toBusqueda.Filtro = toBusqueda.Filtro + " and modeloprod.codigo not in ( select modelo from " + lcTablaOrden + " )"
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsModoEdicion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.CargaManual() and (this.EsNuevo() or this.EsEdicion())
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDetalle( tcDetalle as String ) as String
		local lcRetorno as String
		lcRetorno = 'C_' + tcDetalle
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaAccionesDelSistema( tnCantidadGenerados as Integer, tcNumeros as String, tcDescripcionComprobante as String ) as String
		local lcMensaje as string, ldFecha as date, lcFecha as String lcHora as String, lcMensajeSistema as String, lcCodigo as String, lcSentencia AS String
		
		ldFecha = goServicios.Librerias.ObtenerFecha()
		lcFecha = dtoc( ldFecha, 1 )
		lcHora = goServicios.Librerias.ObtenerHora()
		
		**lcMensaje =  dtoc( ldFecha ) + " - " + lcHora + " - "
		lcMensaje =  ""
		if tnCantidadGenerados > 1
			lcMensaje = lcMensaje + "Se han generado los siguientes comprobantes de " + tcDescripcionComprobante + ": "
		else
			lcMensaje = lcMensaje + "Se ha generado el comprobante " + tcDescripcionComprobante + " Nº "
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
	function eventoEnviarMensajeSinEspera( tcMensaje as String) as Void
*!*			Evento para el kontroler
	endfunc 

enddefine
