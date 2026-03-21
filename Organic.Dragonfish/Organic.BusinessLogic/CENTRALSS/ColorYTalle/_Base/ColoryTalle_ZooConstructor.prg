*-----------------------------------------------------------------------------------------
define class ColorYTalle_ZooConstructor as custom

	#IF .f.
		Local this as ColorYTalle_ZooConstructor of ColorYTalle_ZooConstructor.prg
	#ENDIF

	protected oClasesProxy as Collection, nDataSessionId as Integer
	oClasesProxy = null
	nDataSessionId = 0
	
	*-----------------------------------------------------------------------------------------
	function Init() as Boolean
		dodefault()
		this.nDataSessionId = set( "Datasession" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oClasesProxy_Access() as ZooColeccion of ZooColeccion.prg
		if isnull( this.oClasesProxy )
			this.oClasesProxy = this.ObtenerClasesProxy()
		endif
		return this.oClasesProxy
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearObjeto( tcClase as String, tnDataSession as Integer ) as Object
		local loRetorno as Object, loError as Object

		try
			set datasession to ( tnDataSession )
			loRetorno = newobject( tcClase )
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			set datasession to ( this.nDataSessionId )
		endtry

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreClaseProxy( tcClase as String, tcLibreria as String ) as String
		local lcRetorno as String, loError as Exception
		lcRetorno = ""
		if upper( alltrim( tcClase ) ) == upper( alltrim( juststem( tcLibreria ) ) )
			try
				lcRetorno = this.oClasesProxy.Item[ upper( alltrim( tcClase ) ) ]
			catch to loError
			endtry
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClasesProxy() as Collection
		local loClasesProxy as Collection
		loClasesProxy = createobject( "collection" )
		
		loClasesProxy.Add( [POOLDEAPLICACIONPROXY], [POOLDEAPLICACION] )
		loClasesProxy.Add( [ZOOCOLECCIONPROXY], [ZOOCOLECCION] )
		loClasesProxy.Add( [SENTENCIASPARAATRIBUTOFRAMEWORKPROXY], [SENTENCIASPARAATRIBUTOFRAMEWORK] )
		loClasesProxy.Add( [DIN_ABMFACTURAAVANZADOESTILO2PROXY], [DIN_ABMFACTURAAVANZADOESTILO2] )
		loClasesProxy.Add( [ENT_FACTURAPROXY], [ENT_FACTURA] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAFACTURADETALLEPROXY], [DIN_DETALLEFACTURAFACTURADETALLE] )
		loClasesProxy.Add( [DIN_ITEMFACTURAFACTURADETALLEPROXY], [DIN_ITEMFACTURAFACTURADETALLE] )
		loClasesProxy.Add( [COMPONENTEPRECIOSPROXY], [COMPONENTEPRECIOS] )
		loClasesProxy.Add( [COLORYTALLE_COMPONENTESTOCKPROXY], [COLORYTALLE_COMPONENTESTOCK] )
		loClasesProxy.Add( [DIN_ENTIDADCOLORPROXY], [DIN_ENTIDADCOLOR] )
		loClasesProxy.Add( [DIN_ENTIDADTALLEPROXY], [DIN_ENTIDADTALLE] )
		loClasesProxy.Add( [COMPONENTEENBASEAPROXY], [COMPONENTEENBASEA] )
		loClasesProxy.Add( [ENT_LISTADEPRECIOSPROXY], [ENT_LISTADEPRECIOS] )
		loClasesProxy.Add( [COMPONENTEDESCUENTOSPROXY], [COMPONENTEDESCUENTOS] )
		loClasesProxy.Add( [ENT_DESCUENTOPROXY], [ENT_DESCUENTO] )
		loClasesProxy.Add( [DIN_ENTIDADDESCUENTOAD_SQLSERVERPROXY], [DIN_ENTIDADDESCUENTOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAIMPUESTOSDETALLEPROXY], [DIN_DETALLEFACTURAIMPUESTOSDETALLE] )
		loClasesProxy.Add( [COMPONENTELIMITESDECONSUMOPROXY], [COMPONENTELIMITESDECONSUMO] )
		loClasesProxy.Add( [ENTCOLORYTALLE_CLIENTEPROXY], [ENTCOLORYTALLE_CLIENTE] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAVALORESDETALLEPROXY], [DIN_DETALLEFACTURAVALORESDETALLE] )
		loClasesProxy.Add( [DIN_ITEMFACTURAVALORESDETALLEPROXY], [DIN_ITEMFACTURAVALORESDETALLE] )
		loClasesProxy.Add( [COMPONENTECAJEROPROXY], [COMPONENTECAJERO] )
		loClasesProxy.Add( [COMPONENTESENIASPROXY], [COMPONENTESENIAS] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAARTICULOSSENIADOSDETALLEPROXY], [DIN_DETALLEFACTURAARTICULOSSENIADOSDETALLE] )
		loClasesProxy.Add( [DIN_ITEMFACTURAARTICULOSSENIADOSDETALLEPROXY], [DIN_ITEMFACTURAARTICULOSSENIADOSDETALLE] )
		loClasesProxy.Add( [COLORYTALLE_BUSQUEDAPROXY], [COLORYTALLE_BUSQUEDA] )
		loClasesProxy.Add( [ENT_ARTICULOPROXY], [ENT_ARTICULO] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAPROMOCIONESDETALLEPROXY], [DIN_DETALLEFACTURAPROMOCIONESDETALLE] )
		loClasesProxy.Add( [DIN_ITEMFACTURAPROMOCIONESDETALLEPROXY], [DIN_ITEMFACTURAPROMOCIONESDETALLE] )
		loClasesProxy.Add( [CODIGODEBARRASPROXY], [CODIGODEBARRAS] )
		loClasesProxy.Add( [ENTCOLORYTALLE_EQUIVALENCIAPROXY], [ENTCOLORYTALLE_EQUIVALENCIA] )
		loClasesProxy.Add( [COMPONENTEIMPUESTOSPROXY], [COMPONENTEIMPUESTOS] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAIMPUESTOSCOMPROBANTEPROXY], [DIN_DETALLEFACTURAIMPUESTOSCOMPROBANTE] )
		loClasesProxy.Add( [DIN_COMPONENTECOMPROBANTEPROXY], [DIN_COMPONENTECOMPROBANTE] )
		loClasesProxy.Add( [DIN_ENTIDADVENDEDORPROXY], [DIN_ENTIDADVENDEDOR] )
		loClasesProxy.Add( [ITEMADNDIBUJANTEPROXY], [ITEMADNDIBUJANTE] )
		loClasesProxy.Add( [ENT_PROMOCIONPROXY], [ENT_PROMOCION] )
		loClasesProxy.Add( [ENT_VALORPROXY], [ENT_VALOR] )
		loClasesProxy.Add( [INTERPRETERUTAIMAGENDINAMICAPROXY], [INTERPRETERUTAIMAGENDINAMICA] )
		loClasesProxy.Add( [SERVICIOSALTOSDECAMPOYVALORESSUGERIDOSPROXY], [SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS] )
		loClasesProxy.Add( [COMPONENTEVALESDECAMBIOPROXY], [COMPONENTEVALESDECAMBIO] )
		loClasesProxy.Add( [COMPONENTECHEQUESPROXY], [COMPONENTECHEQUES] )
		loClasesProxy.Add( [ENT_CHEQUEPROXY], [ENT_CHEQUE] )
		loClasesProxy.Add( [COMPONENTECHEQUESPROPIOSPROXY], [COMPONENTECHEQUESPROPIOS] )
		loClasesProxy.Add( [ENT_CHEQUEPROPIOPROXY], [ENT_CHEQUEPROPIO] )
		loClasesProxy.Add( [CONTROLDEACCIONESSENIASPROXY], [CONTROLDEACCIONESSENIAS] )
		loClasesProxy.Add( [DIN_DETALLEFACTURAPROMOARTICULOSDETALLEPROXY], [DIN_DETALLEFACTURAPROMOARTICULOSDETALLE] )
		loClasesProxy.Add( [DIN_ITEMFACTURAIMPUESTOSDETALLEPROXY], [DIN_ITEMFACTURAIMPUESTOSDETALLE] )
		loClasesProxy.Add( [DIN_DETALLEFACTURACOMPAFECPROXY], [DIN_DETALLEFACTURACOMPAFEC] )
		loClasesProxy.Add( [DIN_ITEMFACTURACOMPAFECPROXY], [DIN_ITEMFACTURACOMPAFEC] )
		loClasesProxy.Add( [DIN_ITEMFACTURAIMPUESTOSCOMPROBANTEPROXY], [DIN_ITEMFACTURAIMPUESTOSCOMPROBANTE] )
		loClasesProxy.Add( [DIN_ITEMFACTURAPROMOARTICULOSDETALLEPROXY], [DIN_ITEMFACTURAPROMOARTICULOSDETALLE] )
		loClasesProxy.Add( [DIN_MENUABMFACTURAPROXY], [DIN_MENUABMFACTURA] )
		loClasesProxy.Add( [DIN_ENTIDADFACTURAAD_SQLSERVERPROXY], [DIN_ENTIDADFACTURAAD_SQLSERVER] )
		loClasesProxy.Add( [ACOMODADOREDICIONPROXY], [ACOMODADOREDICION] )
		loClasesProxy.Add( [NUMERACIONESPROXY], [NUMERACIONES] )
		loClasesProxy.Add( [DIN_TIPODEVALORESPROXY], [DIN_TIPODEVALORES] )
		loClasesProxy.Add( [ENT_MONEDAPROXY], [ENT_MONEDA] )
		loClasesProxy.Add( [DIN_ENTIDADMONEDAAD_SQLSERVERPROXY], [DIN_ENTIDADMONEDAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_DETALLEMONEDACOTIZACIONESPROXY], [DIN_DETALLEMONEDACOTIZACIONES] )
		loClasesProxy.Add( [ITEMMONEDACOTIZACIONESPROXY], [ITEMMONEDACOTIZACIONES] )
		loClasesProxy.Add( [DIN_ENTIDADSUCURSALPROXY], [DIN_ENTIDADSUCURSAL] )
		loClasesProxy.Add( [DIN_ENTIDADSUCURSALAD_SQLSERVERPROXY], [DIN_ENTIDADSUCURSALAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADVALORAD_SQLSERVERPROXY], [DIN_ENTIDADVALORAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_DETALLEVALORDETALLEPLANESPROXY], [DIN_DETALLEVALORDETALLEPLANES] )
		loClasesProxy.Add( [ITEMVALORDETALLEPLANESPROXY], [ITEMVALORDETALLEPLANES] )
		loClasesProxy.Add( [DIN_DETALLEVALORDETALLEACREDITACIONPLANESPROXY], [DIN_DETALLEVALORDETALLEACREDITACIONPLANES] )
		loClasesProxy.Add( [DIN_ITEMVALORDETALLEACREDITACIONPLANESPROXY], [DIN_ITEMVALORDETALLEACREDITACIONPLANES] )
		loClasesProxy.Add( [ENTCOLORYTALLE_CAJAESTADOPROXY], [ENTCOLORYTALLE_CAJAESTADO] )
		loClasesProxy.Add( [DIN_ENTIDADCAJAESTADOAD_SQLSERVERPROXY], [DIN_ENTIDADCAJAESTADOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADLISTADEPRECIOSAD_SQLSERVERPROXY], [DIN_ENTIDADLISTADEPRECIOSAD_SQLSERVER] )
		loClasesProxy.Add( [COMPONENTEVALORESPROXY], [COMPONENTEVALORES] )
		loClasesProxy.Add( [COMPONENTETARJETADECREDITOPROXY], [COMPONENTETARJETADECREDITO] )
		loClasesProxy.Add( [COMPONENTECUENTACORRIENTEVALORESPROXY], [COMPONENTECUENTACORRIENTEVALORES] )
		loClasesProxy.Add( [COMPONENTECUENTACORRIENTEVALORESVENTASPROXY], [COMPONENTECUENTACORRIENTEVALORESVENTAS] )
		loClasesProxy.Add( [COMPONENTEAJUSTEDECUPONESPROXY], [COMPONENTEAJUSTEDECUPONES] )
		loClasesProxy.Add( [ENT_TALONARIOPROXY], [ENT_TALONARIO] )
		loClasesProxy.Add( [DIN_ENTIDADTALONARIOAD_SQLSERVERPROXY], [DIN_ENTIDADTALONARIOAD_SQLSERVER] )
		loClasesProxy.Add( [DECORADORDECODIGOSDEENTIDADESPROXY], [DECORADORDECODIGOSDEENTIDADES] )
		loClasesProxy.Add( [DIN_ENTIDADCLIENTEAD_SQLSERVERPROXY], [DIN_ENTIDADCLIENTEAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_DETALLECLIENTEPERCEPCIONESPROXY], [DIN_DETALLECLIENTEPERCEPCIONES] )
		loClasesProxy.Add( [ITEMCLIENTEPERCEPCIONESPROXY], [ITEMCLIENTEPERCEPCIONES] )
		loClasesProxy.Add( [ENT_SENIAPROXY], [ENT_SENIA] )
		loClasesProxy.Add( [DIN_ENTIDADSENIAAD_SQLSERVERPROXY], [DIN_ENTIDADSENIAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADSITUACIONFISCALPROXY], [DIN_ENTIDADSITUACIONFISCAL] )
		loClasesProxy.Add( [DIN_ENTIDADSITUACIONFISCALAD_SQLSERVERPROXY], [DIN_ENTIDADSITUACIONFISCALAD_SQLSERVER] )
		loClasesProxy.Add( [MANAGERPROMOCIONESPROXY], [MANAGERPROMOCIONES] )
		loClasesProxy.Add( [DIN_ENTIDADPROMOCIONAD_SQLSERVERPROXY], [DIN_ENTIDADPROMOCIONAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADVENDEDORAD_SQLSERVERPROXY], [DIN_ENTIDADVENDEDORAD_SQLSERVER] )
		loClasesProxy.Add( [DESACTIVADORBASEPROXY], [DESACTIVADORBASE] )
		loClasesProxy.Add( [MANAGERIMPRESIONPROXY], [MANAGERIMPRESION] )
		loClasesProxy.Add( [ENT_DISENOIMPRESIONPROXY], [ENT_DISENOIMPRESION] )
		loClasesProxy.Add( [DETALLEDISENOIMPRESIONAREASPROXY], [DETALLEDISENOIMPRESIONAREAS] )
		loClasesProxy.Add( [ITEMDISENOIMPRESIONAREASPROXY], [ITEMDISENOIMPRESIONAREAS] )
		loClasesProxy.Add( [DIN_ENTIDADDISENOIMPRESIONAD_SQLSERVERPROXY], [DIN_ENTIDADDISENOIMPRESIONAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADARTICULOAD_SQLSERVERPROXY], [DIN_ENTIDADARTICULOAD_SQLSERVER] )
		loClasesProxy.Add( [FACTORYVALIDADORESDECOMPROBANTESPROXY], [FACTORYVALIDADORESDECOMPROBANTES] )
		loClasesProxy.Add( [VALIDADORESDECOMPROBANTESPROXY], [VALIDADORESDECOMPROBANTES] )
		loClasesProxy.Add( [VALIDADORCOMPROBANTECONVALORESPROXY], [VALIDADORCOMPROBANTECONVALORES] )
		loClasesProxy.Add( [VALIDADORCOMPROBANTEDEVENTASPROXY], [VALIDADORCOMPROBANTEDEVENTAS] )
		loClasesProxy.Add( [VALIDADORCOMPROBANTECONVALORES_GRUPOPROXY], [VALIDADORCOMPROBANTECONVALORES_GRUPO] )
		loClasesProxy.Add( [ENTCOLORYTALLE_PRECIODEARTICULOPROXY], [ENTCOLORYTALLE_PRECIODEARTICULO] )
		loClasesProxy.Add( [DIN_ENTIDADPRECIODEARTICULOAD_SQLSERVERPROXY], [DIN_ENTIDADPRECIODEARTICULOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADUNIDADDEMEDIDAPROXY], [DIN_ENTIDADUNIDADDEMEDIDA] )
		loClasesProxy.Add( [DIN_ENTIDADUNIDADDEMEDIDAAD_SQLSERVERPROXY], [DIN_ENTIDADUNIDADDEMEDIDAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADCOLORAD_SQLSERVERPROXY], [DIN_ENTIDADCOLORAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADTALLEAD_SQLSERVERPROXY], [DIN_ENTIDADTALLEAD_SQLSERVER] )
		loClasesProxy.Add( [COLABORADORCONSULTASDESTOCKPROXY], [COLABORADORCONSULTASDESTOCK] )
		loClasesProxy.Add( [ENTCOLORYTALLE_STOCKCOMBINACIONPROXY], [ENTCOLORYTALLE_STOCKCOMBINACION] )
		loClasesProxy.Add( [DIN_ENTIDADSTOCKCOMBINACIONAD_SQLSERVERPROXY], [DIN_ENTIDADSTOCKCOMBINACIONAD_SQLSERVER] )
		loClasesProxy.Add( [COLABORADORCOLORYTALLEPROXY], [COLABORADORCOLORYTALLE] )
		loClasesProxy.Add( [DIN_ENTIDADGRUPOPROXY], [DIN_ENTIDADGRUPO] )
		loClasesProxy.Add( [DIN_ENTIDADSTOCKARTICULOSPROXY], [DIN_ENTIDADSTOCKARTICULOS] )
		loClasesProxy.Add( [DIN_ENTIDADSTOCKARTICULOSAD_SQLSERVERPROXY], [DIN_ENTIDADSTOCKARTICULOSAD_SQLSERVER] )
		loClasesProxy.Add( [ENT_CUPONPROXY], [ENT_CUPON] )
		loClasesProxy.Add( [DIN_ENTIDADCUPONAD_SQLSERVERPROXY], [DIN_ENTIDADCUPONAD_SQLSERVER] )
		loClasesProxy.Add( [ENT_POSPROXY], [ENT_POS] )
		loClasesProxy.Add( [DIN_DETALLEPOSTARJETASDETALLEPROXY], [DIN_DETALLEPOSTARJETASDETALLE] )
		loClasesProxy.Add( [DIN_ITEMPOSTARJETASDETALLEPROXY], [DIN_ITEMPOSTARJETASDETALLE] )
		loClasesProxy.Add( [DIN_DETALLEPOSMONEDASDETALLEPROXY], [DIN_DETALLEPOSMONEDASDETALLE] )
		loClasesProxy.Add( [DIN_ITEMPOSMONEDASDETALLEPROXY], [DIN_ITEMPOSMONEDASDETALLE] )
		loClasesProxy.Add( [DIN_ENTIDADPOSAD_SQLSERVERPROXY], [DIN_ENTIDADPOSAD_SQLSERVER] )
		loClasesProxy.Add( [FRMABM_DATOSTARJETAAVANZADOESTILO2PROXY], [FRMABM_DATOSTARJETAAVANZADOESTILO2] )
		loClasesProxy.Add( [ENT_DATOSTARJETAPROXY], [ENT_DATOSTARJETA] )
		loClasesProxy.Add( [COLABORADORPOSPROXY], [COLABORADORPOS] )
		loClasesProxy.Add( [ENT_ENTIDADFINANCIERAPROXY], [ENT_ENTIDADFINANCIERA] )
		loClasesProxy.Add( [DIN_ENTIDADCLASEDETARJETAPROXY], [DIN_ENTIDADCLASEDETARJETA] )
		loClasesProxy.Add( [DIN_ENTIDADCLASEDETARJETAAD_SQLSERVERPROXY], [DIN_ENTIDADCLASEDETARJETAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_DETALLEDATOSTARJETADETALLEPLANESPROXY], [DIN_DETALLEDATOSTARJETADETALLEPLANES] )
		loClasesProxy.Add( [DIN_ITEMDATOSTARJETADETALLEPLANESPROXY], [DIN_ITEMDATOSTARJETADETALLEPLANES] )
		loClasesProxy.Add( [ENT_OPERADORADETARJETAPROXY], [ENT_OPERADORADETARJETA] )
		loClasesProxy.Add( [DIN_DETALLEOPERADORADETARJETACLASESDETARJETADETALLEPROXY], [DIN_DETALLEOPERADORADETARJETACLASESDETARJETADETALLE] )
		loClasesProxy.Add( [DIN_ITEMOPERADORADETARJETACLASESDETARJETADETALLEPROXY], [DIN_ITEMOPERADORADETARJETACLASESDETARJETADETALLE] )
		loClasesProxy.Add( [DIN_ENTIDADOPERADORADETARJETAAD_SQLSERVERPROXY], [DIN_ENTIDADOPERADORADETARJETAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADENTIDADFINANCIERAAD_SQLSERVERPROXY], [DIN_ENTIDADENTIDADFINANCIERAAD_SQLSERVER] )
		loClasesProxy.Add( [ENT_LIMITECONSUMOPROXY], [ENT_LIMITECONSUMO] )
		loClasesProxy.Add( [DIN_ENTIDADLIMITECONSUMOAD_SQLSERVERPROXY], [DIN_ENTIDADLIMITECONSUMOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADCLASIFICACIONCLIENTEPROXY], [DIN_ENTIDADCLASIFICACIONCLIENTE] )
		loClasesProxy.Add( [DIN_DETALLESENIAARTICULOSDETALLEPROXY], [DIN_DETALLESENIAARTICULOSDETALLE] )
		loClasesProxy.Add( [DIN_ITEMSENIAARTICULOSDETALLEPROXY], [DIN_ITEMSENIAARTICULOSDETALLE] )
		loClasesProxy.Add( [COPIADORDEITEMSSTOCKACOLECCIONPROXY], [COPIADORDEITEMSSTOCKACOLECCION] )
		loClasesProxy.Add( [AGRUPADORPORARTICULOPROXY], [AGRUPADORPORARTICULO] )
		loClasesProxy.Add( [DIN_COMPROBANTESYGRUPOSCAJAPROXY], [DIN_COMPROBANTESYGRUPOSCAJA] )
		loClasesProxy.Add( [ENT_CTACTEPROXY], [ENT_CTACTE] )
		loClasesProxy.Add( [VALIDACIONESCUENTACORRIENTEPROXY], [VALIDACIONESCUENTACORRIENTE] )
		loClasesProxy.Add( [ENT_CAJASALDOSPROXY], [ENT_CAJASALDOS] )
		loClasesProxy.Add( [DIN_ENTIDADCAJASALDOSAD_SQLSERVERPROXY], [DIN_ENTIDADCAJASALDOSAD_SQLSERVER] )
		loClasesProxy.Add( [ENT_MOVIMIENTODECAJAPROXY], [ENT_MOVIMIENTODECAJA] )
		loClasesProxy.Add( [DIN_ENTIDADMOVIMIENTODECAJAAD_SQLSERVERPROXY], [DIN_ENTIDADMOVIMIENTODECAJAAD_SQLSERVER] )
		loClasesProxy.Add( [ENT_CAJAAUDITORIAPROXY], [ENT_CAJAAUDITORIA] )
		loClasesProxy.Add( [DIN_ENTIDADCAJAAUDITORIAAD_SQLSERVERPROXY], [DIN_ENTIDADCAJAAUDITORIAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_DETALLECAJAAUDITORIADETALLEVALORESAUDITORIAPROXY], [DIN_DETALLECAJAAUDITORIADETALLEVALORESAUDITORIA] )
		loClasesProxy.Add( [DIN_ITEMCAJAAUDITORIADETALLEVALORESAUDITORIAPROXY], [DIN_ITEMCAJAAUDITORIADETALLEVALORESAUDITORIA] )
		loClasesProxy.Add( [DIN_ENTIDADCHEQUEAD_SQLSERVERPROXY], [DIN_ENTIDADCHEQUEAD_SQLSERVER] )
		loClasesProxy.Add( [ENT_VALEDECAMBIOPROXY], [ENT_VALEDECAMBIO] )
		loClasesProxy.Add( [DIN_ENTIDADVALEDECAMBIOAD_SQLSERVERPROXY], [DIN_ENTIDADVALEDECAMBIOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADCHEQUEPROPIOAD_SQLSERVERPROXY], [DIN_ENTIDADCHEQUEPROPIOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_COMPROBANTEPROXY], [DIN_COMPROBANTE] )
		loClasesProxy.Add( [FRMABM_SENIAPENDIENTEAVANZADOESTILO2PROXY], [FRMABM_SENIAPENDIENTEAVANZADOESTILO2] )
		loClasesProxy.Add( [ENT_SENIAPENDIENTEPROXY], [ENT_SENIAPENDIENTE] )
		loClasesProxy.Add( [DETALLESENIAPENDIENTEDETALLESENIASPENDIENTESPROXY], [DETALLESENIAPENDIENTEDETALLESENIASPENDIENTES] )
		loClasesProxy.Add( [DIN_ITEMSENIAPENDIENTEDETALLESENIASPENDIENTESPROXY], [DIN_ITEMSENIAPENDIENTEDETALLESENIASPENDIENTES] )
		loClasesProxy.Add( [DIN_ENTIDADSENIAPENDIENTEAD_SQLSERVERPROXY], [DIN_ENTIDADSENIAPENDIENTEAD_SQLSERVER] )
		loClasesProxy.Add( [CLONADORCHEQUESARGENTINAPROXY], [CLONADORCHEQUESARGENTINA] )
		loClasesProxy.Add( [ESTILOSPROXY], [ESTILOS] )
		loClasesProxy.Add( [DIN_ESTILO2PROXY], [DIN_ESTILO2] )
		loClasesProxy.Add( [EXCEPCIONCOMBINACIONSINSTOCKPROXY], [EXCEPCIONCOMBINACIONSINSTOCK] )
		loClasesProxy.Add( [LANZADORMENSAJESSONOROSPROXY], [LANZADORMENSAJESSONOROS] )
		loClasesProxy.Add( [MENSAJESINESPERAPROXY], [MENSAJESINESPERA] )
		loClasesProxy.Add( [LANZADORMENSAJESPROXY], [LANZADORMENSAJES] )
		loClasesProxy.Add( [MULTIMEDIAPROXY], [MULTIMEDIA] )
		loClasesProxy.Add( [SERIALIZADORDEENTIDADESPROXY], [SERIALIZADORDEENTIDADES] )
		loClasesProxy.Add( [DIN_OBJETOPROMOCIONESPROXY], [DIN_OBJETOPROMOCIONES] )
		loClasesProxy.Add( [DIN_ENTIDADPAISESPROXY], [DIN_ENTIDADPAISES] )
		loClasesProxy.Add( [DIN_ENTIDADPROVINCIAPROXY], [DIN_ENTIDADPROVINCIA] )
		loClasesProxy.Add( [DIN_ENTIDADPROVEEDORPROXY], [DIN_ENTIDADPROVEEDOR] )
		loClasesProxy.Add( [DIN_ENTIDADTEMPORADAPROXY], [DIN_ENTIDADTEMPORADA] )
		loClasesProxy.Add( [DIN_ENTIDADFAMILIAPROXY], [DIN_ENTIDADFAMILIA] )
		loClasesProxy.Add( [DIN_ENTIDADMATERIALPROXY], [DIN_ENTIDADMATERIAL] )
		loClasesProxy.Add( [DIN_ENTIDADLINEAPROXY], [DIN_ENTIDADLINEA] )
		loClasesProxy.Add( [DIN_ENTIDADCATEGORIADEARTICULOPROXY], [DIN_ENTIDADCATEGORIADEARTICULO] )
		loClasesProxy.Add( [DIN_ENTIDADCLASIFICACIONARTICULOPROXY], [DIN_ENTIDADCLASIFICACIONARTICULO] )
		loClasesProxy.Add( [DIN_ENTIDADTIPODEARTICULOPROXY], [DIN_ENTIDADTIPODEARTICULO] )
		loClasesProxy.Add( [ENT_PALETADECOLORESPROXY], [ENT_PALETADECOLORES] )
		loClasesProxy.Add( [ENT_CURVADETALLESPROXY], [ENT_CURVADETALLES] )
		loClasesProxy.Add( [DIN_ENTIDADTIPOSUCURSALPROXY], [DIN_ENTIDADTIPOSUCURSAL] )
		loClasesProxy.Add( [DIN_ENTIDADLINEASUCURSALPROXY], [DIN_ENTIDADLINEASUCURSAL] )
		loClasesProxy.Add( [DIN_ENTIDADSEGMENTACIONPROXY], [DIN_ENTIDADSEGMENTACION] )
		loClasesProxy.Add( [COLORYTALLE_COMPONENTEPREPANTALLAPROXY], [COLORYTALLE_COMPONENTEPREPANTALLA] )
		loClasesProxy.Add( [INFORMACIONAPLICACIONPROXY], [INFORMACIONAPLICACION] )
		loClasesProxy.Add( [LANZADORNUEVOENBASEAPROXY], [LANZADORNUEVOENBASEA] )
		loClasesProxy.Add( [FRMABM_NUEVOENBASEAAVANZADOESTILO2PROXY], [FRMABM_NUEVOENBASEAAVANZADOESTILO2] )
		loClasesProxy.Add( [ENT_NUEVOENBASEAPROXY], [ENT_NUEVOENBASEA] )
		loClasesProxy.Add( [DIN_DETALLENUEVOENBASEADETALLECOMPROBANTESPROXY], [DIN_DETALLENUEVOENBASEADETALLECOMPROBANTES] )
		loClasesProxy.Add( [DIN_ITEMNUEVOENBASEADETALLECOMPROBANTESPROXY], [DIN_ITEMNUEVOENBASEADETALLECOMPROBANTES] )
		loClasesProxy.Add( [DIN_ENTIDADNUEVOENBASEAAD_SQLSERVERPROXY], [DIN_ENTIDADNUEVOENBASEAAD_SQLSERVER] )
		loClasesProxy.Add( [ENTCOLORYTALLE_REMITOPROXY], [ENTCOLORYTALLE_REMITO] )
		loClasesProxy.Add( [DIN_DETALLEREMITOFACTURADETALLEPROXY], [DIN_DETALLEREMITOFACTURADETALLE] )
		loClasesProxy.Add( [DIN_ITEMREMITOFACTURADETALLEPROXY], [DIN_ITEMREMITOFACTURADETALLE] )
		loClasesProxy.Add( [DIN_DETALLEREMITOIMPUESTOSDETALLEPROXY], [DIN_DETALLEREMITOIMPUESTOSDETALLE] )
		loClasesProxy.Add( [DIN_DETALLEREMITOIMPUESTOSCOMPROBANTEPROXY], [DIN_DETALLEREMITOIMPUESTOSCOMPROBANTE] )
		loClasesProxy.Add( [DIN_DETALLEREMITOCOMPAFECPROXY], [DIN_DETALLEREMITOCOMPAFEC] )
		loClasesProxy.Add( [DIN_ITEMREMITOCOMPAFECPROXY], [DIN_ITEMREMITOCOMPAFEC] )
		loClasesProxy.Add( [DIN_ITEMREMITOIMPUESTOSCOMPROBANTEPROXY], [DIN_ITEMREMITOIMPUESTOSCOMPROBANTE] )
		loClasesProxy.Add( [DIN_ITEMREMITOIMPUESTOSDETALLEPROXY], [DIN_ITEMREMITOIMPUESTOSDETALLE] )
		loClasesProxy.Add( [DIN_ENTIDADREMITOAD_SQLSERVERPROXY], [DIN_ENTIDADREMITOAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADTRANSPORTISTAPROXY], [DIN_ENTIDADTRANSPORTISTA] )
		loClasesProxy.Add( [DIN_ENTIDADTRANSPORTISTAAD_SQLSERVERPROXY], [DIN_ENTIDADTRANSPORTISTAAD_SQLSERVER] )
		loClasesProxy.Add( [ITEMSELECCIONENBASEAPROXY], [ITEMSELECCIONENBASEA] )
		loClasesProxy.Add( [GARBAGECOLLECTORPROXY], [GARBAGECOLLECTOR] )
		*-----------------------------------------------------------------------------------------
		* Performance septiembre 2015
		*-----------------------------------------------------------------------------------------
		loClasesProxy.Add( [MANEJADORERRORESKONTROLERPROXY], [MANEJADORERRORESKONTROLER] )
		loClasesProxy.Add( [ENT_REGIMENIMPOSITIVOPROXY], [ENT_REGIMENIMPOSITIVO] )
		loClasesProxy.Add( [ENT_IMPUESTOPROXY], [ENT_IMPUESTO] )
		loClasesProxy.Add( [ADAPTERVALIDADORACEPTACIONDEVALORESPROXY], [ADAPTERVALIDADORACEPTACIONDEVALORES] )
		loClasesProxy.Add( [DETALLECLIENTEPERCEPCIONESPROXY], [DETALLECLIENTEPERCEPCIONES] )
		loClasesProxy.Add( [DIN_DETALLECLIENTECONTACTOPROXY], [DIN_DETALLECLIENTECONTACTO] )
		loClasesProxy.Add( [DIN_DETALLECLIENTEOTRASDIRECCIONESPROXY], [DIN_DETALLECLIENTEOTRASDIRECCIONES] )
		loClasesProxy.Add( [DIN_ITEMCLIENTECONTACTOPROXY], [DIN_ITEMCLIENTECONTACTO] )
		loClasesProxy.Add( [DIN_ITEMCLIENTEOTRASDIRECCIONESPROXY], [DIN_ITEMCLIENTEOTRASDIRECCIONES] )
		loClasesProxy.Add( [DIN_DETALLEVALORAGRUPUBLIDETALLEPROXY], [DIN_DETALLEVALORAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ENTIDADDATOSADICIONALESCOMPROBANTESAAD_SQLSERVERPROXY], [DIN_ENTIDADDATOSADICIONALESCOMPROBANTESAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAPROXY], [DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESA] )
		loClasesProxy.Add( [DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAAD_SQLSERVERPROXY], [DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAAD_SQLSERVER] )
		loClasesProxy.Add( [DIN_ITEMVALORAGRUPUBLIDETALLEPROXY], [DIN_ITEMVALORAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [ENT_DATOSADICIONALESCOMPROBANTESAPROXY], [ENT_DATOSADICIONALESCOMPROBANTESA] )
		loClasesProxy.Add( [FRMABM_DATOSADICIONALESCOMPROBANTESAAVANZADOESTILO2PROXY], [FRMABM_DATOSADICIONALESCOMPROBANTESAAVANZADOESTILO2] )
		loClasesProxy.Add( [VALIDADORACEPTACIONDEVALORESDETALLEPROXY], [VALIDADORACEPTACIONDEVALORESDETALLE] )
		loClasesProxy.Add( [ZOOXMLPROXY], [ZOOXML] )
		loClasesProxy.Add( [COLABORADORIMPUESTOSINTERNOSPROXY], [COLABORADORIMPUESTOSINTERNOS] )
		loClasesProxy.Add( [DIN_DETALLELISTADEPRECIOSAGRUPUBLIDETALLEPROXY], [DIN_DETALLELISTADEPRECIOSAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMLISTADEPRECIOSAGRUPUBLIDETALLEPROXY], [DIN_ITEMLISTADEPRECIOSAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_PROCEDIMIENTOSALMACENADOSPROXY], [DIN_PROCEDIMIENTOSALMACENADOS] )
		loClasesProxy.Add( [ENT_COMISIONPROXY], [ENT_COMISION] )
		loClasesProxy.Add( [COMPONENTEIMPUESTOSVENTASPROXY], [COMPONENTEIMPUESTOSVENTAS] )
		loClasesProxy.Add( [DIN_DETALLEARTICULOAGRUPUBLIDETALLEPROXY], [DIN_DETALLEARTICULOAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMARTICULOAGRUPUBLIDETALLEPROXY], [DIN_ITEMARTICULOAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [ENT_STOCKARTICULOSPROXY], [ENT_STOCKARTICULOS] )
		loClasesProxy.Add( [COMPONENTEDATOSADICIONALESCOMPROBANTESAPROXY], [COMPONENTEDATOSADICIONALESCOMPROBANTESA] )
		loClasesProxy.Add( [COLABORADORPERCEPCIONESPROXY], [COLABORADORPERCEPCIONES] )
		loClasesProxy.Add( [COLABORADORVALIDACIONCONTROLDESTOCKDIPONIBLEPROXY], [COLABORADORVALIDACIONCONTROLDESTOCKDIPONIBLE] )
		loClasesProxy.Add( [COMPONENTESTOCKPROXY], [COMPONENTESTOCK] )
		loClasesProxy.Add( [DETALLEVENDEDORCOMISIONESDETALLEPROXY], [DETALLEVENDEDORCOMISIONESDETALLE] )
		loClasesProxy.Add( [DIN_DETALLECOLORAGRUPUBLIDETALLEPROXY], [DIN_DETALLECOLORAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_DETALLECONDICIONDEPAGOPAGOSPERSONALIZADOSPROXY], [DIN_DETALLECONDICIONDEPAGOPAGOSPERSONALIZADOS] )
		loClasesProxy.Add( [DIN_DETALLETALLEAGRUPUBLIDETALLEPROXY], [DIN_DETALLETALLEAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_DETALLEUNIDADDEMEDIDAAGRUPUBLIDETALLEPROXY], [DIN_DETALLEUNIDADDEMEDIDAAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_DETALLEVENDEDORAGRUPUBLIDETALLEPROXY], [DIN_DETALLEVENDEDORAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMCOLORAGRUPUBLIDETALLEPROXY], [DIN_ITEMCOLORAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMCONDICIONDEPAGOPAGOSPERSONALIZADOSPROXY], [DIN_ITEMCONDICIONDEPAGOPAGOSPERSONALIZADOS] )
		loClasesProxy.Add( [DIN_ITEMTALLEAGRUPUBLIDETALLEPROXY], [DIN_ITEMTALLEAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMUNIDADDEMEDIDAAGRUPUBLIDETALLEPROXY], [DIN_ITEMUNIDADDEMEDIDAAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMVENDEDORAGRUPUBLIDETALLEPROXY], [DIN_ITEMVENDEDORAGRUPUBLIDETALLE] )
		loClasesProxy.Add( [DIN_ITEMVENDEDORCOMISIONESDETALLEPROXY], [DIN_ITEMVENDEDORCOMISIONESDETALLE] )
		loClasesProxy.Add( [ENT_CONDICIONDEPAGOPROXY], [ENT_CONDICIONDEPAGO] )
		loClasesProxy.Add( [ENT_SITUACIONFISCALPROXY], [ENT_SITUACIONFISCAL] )
		loClasesProxy.Add( [ENT_VENDEDORPROXY], [ENT_VENDEDOR] )
		loClasesProxy.Add( [VALIDADORACEPTACIONDEVALORESPROXY], [VALIDADORACEPTACIONDEVALORES] )
		loClasesProxy.Add( [VALIDADORACEPTACIONDEVALORESTARJETADECREDITOPROXY], [VALIDADORACEPTACIONDEVALORESTARJETADECREDITO] )
		loClasesProxy.Add( [DIN_MENUABMDATOSTARJETAPROXY], [DIN_MENUABMDATOSTARJETA] )
		loClasesProxy.Add( [DIN_ENTIDADMEMORIAPROXY], [DIN_ENTIDADMEMORIA] )
		loClasesProxy.Add( [DIN_ENTIDADACCIONESAUTOMATICASPROXY], [DIN_ENTIDADACCIONESAUTOMATICAS] )
		loClasesProxy.Add( [DIN_OBJETOCURSORATRIBUTOSCONSALTODECAMPOPROXY], [DIN_OBJETOCURSORATRIBUTOSCONSALTODECAMPO] )
		loClasesProxy.Add( [DIN_COMPONENTELIMITESDECONSUMOPROXY], [DIN_COMPONENTELIMITESDECONSUMO] )
		loClasesProxy.Add( [DIN_COMPONENTEECOMMERCEPROXY], [DIN_COMPONENTEECOMMERCE] )
		loClasesProxy.Add( [DIN_COMPONENTEDESCUENTOSPROXY], [DIN_COMPONENTEDESCUENTOS] )
		loClasesProxy.Add( [DIN_COMPONENTESENIASPROXY], [DIN_COMPONENTESENIAS] )

		return loClasesProxy
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
* PROXIES
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class POOLDEAPLICACIONPROXY as POOLDEAPLICACION of POOLDEAPLICACION.PRG
	function Class_Access() as String
		return 'pooldeaplicacion'
	endfunc
	function ClassLibrary_Access() as String
		return 'pooldeaplicacion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ZOOCOLECCIONPROXY as ZOOCOLECCION of ZOOCOLECCION.PRG
	function Class_Access() as String
		return 'zoocoleccion'
	endfunc
	function ClassLibrary_Access() as String
		return 'zoocoleccion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class SENTENCIASPARAATRIBUTOFRAMEWORKPROXY as SENTENCIASPARAATRIBUTOFRAMEWORK of SENTENCIASPARAATRIBUTOFRAMEWORK.PRG
	function Class_Access() as String
		return 'sentenciasparaatributoframework'
	endfunc
	function ClassLibrary_Access() as String
		return 'sentenciasparaatributoframework.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ABMFACTURAAVANZADOESTILO2PROXY as DIN_ABMFACTURAAVANZADOESTILO2 of DIN_ABMFACTURAAVANZADOESTILO2.PRG
	function Class_Access() as String
		return 'din_abmfacturaavanzadoestilo2'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_abmfacturaavanzadoestilo2.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_FACTURAPROXY as ENT_FACTURA of ENT_FACTURA.PRG
	function Class_Access() as String
		return 'ent_factura'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_factura.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAFACTURADETALLEPROXY as DIN_DETALLEFACTURAFACTURADETALLE of DIN_DETALLEFACTURAFACTURADETALLE.PRG
	function Class_Access() as String
		return 'din_detallefacturafacturadetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturafacturadetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAFACTURADETALLEPROXY as DIN_ITEMFACTURAFACTURADETALLE of DIN_ITEMFACTURAFACTURADETALLE.PRG
	function Class_Access() as String
		return 'din_itemfacturafacturadetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturafacturadetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEPRECIOSPROXY as COMPONENTEPRECIOS of COMPONENTEPRECIOS.PRG
	function Class_Access() as String
		return 'componenteprecios'
	endfunc
	function ClassLibrary_Access() as String
		return 'componenteprecios.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLORYTALLE_COMPONENTESTOCKPROXY as COLORYTALLE_COMPONENTESTOCK of COLORYTALLE_COMPONENTESTOCK.PRG
	function Class_Access() as String
		return 'colorytalle_componentestock'
	endfunc
	function ClassLibrary_Access() as String
		return 'colorytalle_componentestock.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCOLORPROXY as DIN_ENTIDADCOLOR of DIN_ENTIDADCOLOR.PRG
	function Class_Access() as String
		return 'din_entidadcolor'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcolor.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTALLEPROXY as DIN_ENTIDADTALLE of DIN_ENTIDADTALLE.PRG
	function Class_Access() as String
		return 'din_entidadtalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEENBASEAPROXY as COMPONENTEENBASEA of COMPONENTEENBASEA.PRG
	function Class_Access() as String
		return 'componenteenbasea'
	endfunc
	function ClassLibrary_Access() as String
		return 'componenteenbasea.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_LISTADEPRECIOSPROXY as ENT_LISTADEPRECIOS of ENT_LISTADEPRECIOS.PRG
	function Class_Access() as String
		return 'ent_listadeprecios'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_listadeprecios.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEDESCUENTOSPROXY as COMPONENTEDESCUENTOS of COMPONENTEDESCUENTOS.PRG
	function Class_Access() as String
		return 'componentedescuentos'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentedescuentos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_DESCUENTOPROXY as ENT_DESCUENTO of ENT_DESCUENTO.PRG
	function Class_Access() as String
		return 'ent_descuento'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_descuento.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADDESCUENTOAD_SQLSERVERPROXY as DIN_ENTIDADDESCUENTOAD_SQLSERVER of DIN_ENTIDADDESCUENTOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidaddescuentoad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidaddescuentoad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAIMPUESTOSDETALLEPROXY as DIN_DETALLEFACTURAIMPUESTOSDETALLE of DIN_DETALLEFACTURAIMPUESTOSDETALLE.PRG
	function Class_Access() as String
		return 'din_detallefacturaimpuestosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturaimpuestosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTELIMITESDECONSUMOPROXY as COMPONENTELIMITESDECONSUMO of COMPONENTELIMITESDECONSUMO.PRG
	function Class_Access() as String
		return 'componentelimitesdeconsumo'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentelimitesdeconsumo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENTCOLORYTALLE_CLIENTEPROXY as ENTCOLORYTALLE_CLIENTE of ENTCOLORYTALLE_CLIENTE.PRG
	function Class_Access() as String
		return 'entcolorytalle_cliente'
	endfunc
	function ClassLibrary_Access() as String
		return 'entcolorytalle_cliente.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAVALORESDETALLEPROXY as DIN_DETALLEFACTURAVALORESDETALLE of DIN_DETALLEFACTURAVALORESDETALLE.PRG
	function Class_Access() as String
		return 'din_detallefacturavaloresdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturavaloresdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAVALORESDETALLEPROXY as DIN_ITEMFACTURAVALORESDETALLE of DIN_ITEMFACTURAVALORESDETALLE.PRG
	function Class_Access() as String
		return 'din_itemfacturavaloresdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturavaloresdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTECAJEROPROXY as COMPONENTECAJERO of COMPONENTECAJERO.PRG
	function Class_Access() as String
		return 'componentecajero'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentecajero.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTESENIASPROXY as COMPONENTESENIAS of COMPONENTESENIAS.PRG
	function Class_Access() as String
		return 'componentesenias'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentesenias.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAARTICULOSSENIADOSDETALLEPROXY as DIN_DETALLEFACTURAARTICULOSSENIADOSDETALLE of DIN_DETALLEFACTURAARTICULOSSENIADOSDETALLE.PRG
	function Class_Access() as String
		return 'din_detallefacturaarticulosseniadosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturaarticulosseniadosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAARTICULOSSENIADOSDETALLEPROXY as DIN_ITEMFACTURAARTICULOSSENIADOSDETALLE of DIN_ITEMFACTURAARTICULOSSENIADOSDETALLE.PRG
	function Class_Access() as String
		return 'din_itemfacturaarticulosseniadosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturaarticulosseniadosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLORYTALLE_BUSQUEDAPROXY as COLORYTALLE_BUSQUEDA of COLORYTALLE_BUSQUEDA.PRG
	function Class_Access() as String
		return 'colorytalle_busqueda'
	endfunc
	function ClassLibrary_Access() as String
		return 'colorytalle_busqueda.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_ARTICULOPROXY as ENT_ARTICULO of ENT_ARTICULO.PRG
	function Class_Access() as String
		return 'ent_articulo'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_articulo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAPROMOCIONESDETALLEPROXY as DIN_DETALLEFACTURAPROMOCIONESDETALLE of DIN_DETALLEFACTURAPROMOCIONESDETALLE.PRG
	function Class_Access() as String
		return 'din_detallefacturapromocionesdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturapromocionesdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAPROMOCIONESDETALLEPROXY as DIN_ITEMFACTURAPROMOCIONESDETALLE of DIN_ITEMFACTURAPROMOCIONESDETALLE.PRG
	function Class_Access() as String
		return 'din_itemfacturapromocionesdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturapromocionesdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class CODIGODEBARRASPROXY as CODIGODEBARRAS of CODIGODEBARRAS.PRG
	function Class_Access() as String
		return 'codigodebarras'
	endfunc
	function ClassLibrary_Access() as String
		return 'codigodebarras.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENTCOLORYTALLE_EQUIVALENCIAPROXY as ENTCOLORYTALLE_EQUIVALENCIA of ENTCOLORYTALLE_EQUIVALENCIA.PRG
	function Class_Access() as String
		return 'entcolorytalle_equivalencia'
	endfunc
	function ClassLibrary_Access() as String
		return 'entcolorytalle_equivalencia.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEIMPUESTOSPROXY as COMPONENTEIMPUESTOS of COMPONENTEIMPUESTOS.PRG
	function Class_Access() as String
		return 'componenteimpuestos'
	endfunc
	function ClassLibrary_Access() as String
		return 'componenteimpuestos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAIMPUESTOSCOMPROBANTEPROXY as DIN_DETALLEFACTURAIMPUESTOSCOMPROBANTE of DIN_DETALLEFACTURAIMPUESTOSCOMPROBANTE.PRG
	function Class_Access() as String
		return 'din_detallefacturaimpuestoscomprobante'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturaimpuestoscomprobante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPONENTECOMPROBANTEPROXY as DIN_COMPONENTECOMPROBANTE of DIN_COMPONENTECOMPROBANTE.PRG
	function Class_Access() as String
		return 'din_componentecomprobante'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_componentecomprobante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADVENDEDORPROXY as DIN_ENTIDADVENDEDOR of DIN_ENTIDADVENDEDOR.PRG
	function Class_Access() as String
		return 'din_entidadvendedor'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadvendedor.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ITEMADNDIBUJANTEPROXY as ITEMADNDIBUJANTE of ITEMADNDIBUJANTE.PRG
	function Class_Access() as String
		return 'itemadndibujante'
	endfunc
	function ClassLibrary_Access() as String
		return 'itemadndibujante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_PROMOCIONPROXY as ENT_PROMOCION of ENT_PROMOCION.PRG
	function Class_Access() as String
		return 'ent_promocion'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_promocion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_VALORPROXY as ENT_VALOR of ENT_VALOR.PRG
	function Class_Access() as String
		return 'ent_valor'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_valor.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class INTERPRETERUTAIMAGENDINAMICAPROXY as INTERPRETERUTAIMAGENDINAMICA of INTERPRETERUTAIMAGENDINAMICA.PRG
	function Class_Access() as String
		return 'interpreterutaimagendinamica'
	endfunc
	function ClassLibrary_Access() as String
		return 'interpreterutaimagendinamica.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class SERVICIOSALTOSDECAMPOYVALORESSUGERIDOSPROXY as SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS of SERVICIOSALTOSDECAMPOYVALORESSUGERIDOS.PRG
	function Class_Access() as String
		return 'serviciosaltosdecampoyvaloressugeridos'
	endfunc
	function ClassLibrary_Access() as String
		return 'serviciosaltosdecampoyvaloressugeridos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ZOOINFORMACIONPROXY as ZOOINFORMACION of ZOOINFORMACION.PRG
	function Class_Access() as String
		return 'zooinformacion'
	endfunc
	function ClassLibrary_Access() as String
		return 'zooinformacion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEVALESDECAMBIOPROXY as COMPONENTEVALESDECAMBIO of COMPONENTEVALESDECAMBIO.PRG
	function Class_Access() as String
		return 'componentevalesdecambio'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentevalesdecambio.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTECHEQUESPROXY as COMPONENTECHEQUES of COMPONENTECHEQUES.PRG
	function Class_Access() as String
		return 'componentecheques'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentecheques.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CHEQUEPROXY as ENT_CHEQUE of ENT_CHEQUE.PRG
	function Class_Access() as String
		return 'ent_cheque'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_cheque.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTECHEQUESPROPIOSPROXY as COMPONENTECHEQUESPROPIOS of COMPONENTECHEQUESPROPIOS.PRG
	function Class_Access() as String
		return 'componentechequespropios'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentechequespropios.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CHEQUEPROPIOPROXY as ENT_CHEQUEPROPIO of ENT_CHEQUEPROPIO.PRG
	function Class_Access() as String
		return 'ent_chequepropio'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_chequepropio.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class CONTROLDEACCIONESSENIASPROXY as CONTROLDEACCIONESSENIAS of CONTROLDEACCIONESSENIAS.PRG
	function Class_Access() as String
		return 'controldeaccionessenias'
	endfunc
	function ClassLibrary_Access() as String
		return 'controldeaccionessenias.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURAPROMOARTICULOSDETALLEPROXY as DIN_DETALLEFACTURAPROMOARTICULOSDETALLE of DIN_DETALLEFACTURAPROMOARTICULOSDETALLE.PRG
	function Class_Access() as String
		return 'din_detallefacturapromoarticulosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturapromoarticulosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAIMPUESTOSDETALLEPROXY as DIN_ITEMFACTURAIMPUESTOSDETALLE of DIN_ITEMFACTURAIMPUESTOSDETALLE.PRG
	function Class_Access() as String
		return 'din_itemfacturaimpuestosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturaimpuestosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEFACTURACOMPAFECPROXY as DIN_DETALLEFACTURACOMPAFEC of DIN_DETALLEFACTURACOMPAFEC.PRG
	function Class_Access() as String
		return 'din_detallefacturacompafec'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallefacturacompafec.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURACOMPAFECPROXY as DIN_ITEMFACTURACOMPAFEC of DIN_ITEMFACTURACOMPAFEC.PRG
	function Class_Access() as String
		return 'din_itemfacturacompafec'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturacompafec.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAIMPUESTOSCOMPROBANTEPROXY as DIN_ITEMFACTURAIMPUESTOSCOMPROBANTE of DIN_ITEMFACTURAIMPUESTOSCOMPROBANTE.PRG
	function Class_Access() as String
		return 'din_itemfacturaimpuestoscomprobante'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturaimpuestoscomprobante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMFACTURAPROMOARTICULOSDETALLEPROXY as DIN_ITEMFACTURAPROMOARTICULOSDETALLE of DIN_ITEMFACTURAPROMOARTICULOSDETALLE.PRG
	function Class_Access() as String
		return 'din_itemfacturapromoarticulosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemfacturapromoarticulosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_MENUABMFACTURAPROXY as DIN_MENUABMFACTURA of DIN_MENUABMFACTURA.PRG
	function Class_Access() as String
		return 'din_menuabmfactura'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_menuabmfactura.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADFACTURAAD_SQLSERVERPROXY as DIN_ENTIDADFACTURAAD_SQLSERVER of DIN_ENTIDADFACTURAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadfacturaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadfacturaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ACOMODADOREDICIONPROXY as ACOMODADOREDICION of ACOMODADOREDICION.PRG
	function Class_Access() as String
		return 'acomodadoredicion'
	endfunc
	function ClassLibrary_Access() as String
		return 'acomodadoredicion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class OBJETOLOGUEOPROXY as OBJETOLOGUEO of OBJETOLOGUEO.PRG
	function Class_Access() as String
		return 'objetologueo'
	endfunc
	function ClassLibrary_Access() as String
		return 'objetologueo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class NUMERACIONESPROXY as NUMERACIONES of NUMERACIONES.PRG
	function Class_Access() as String
		return 'numeraciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'numeraciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_TIPODEVALORESPROXY as DIN_TIPODEVALORES of DIN_TIPODEVALORES.PRG
	function Class_Access() as String
		return 'din_tipodevalores'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_tipodevalores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_MONEDAPROXY as ENT_MONEDA of ENT_MONEDA.PRG
	function Class_Access() as String
		return 'ent_moneda'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_moneda.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADMONEDAAD_SQLSERVERPROXY as DIN_ENTIDADMONEDAAD_SQLSERVER of DIN_ENTIDADMONEDAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadmonedaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadmonedaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEMONEDACOTIZACIONESPROXY as DIN_DETALLEMONEDACOTIZACIONES of DIN_DETALLEMONEDACOTIZACIONES.PRG
	function Class_Access() as String
		return 'din_detallemonedacotizaciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallemonedacotizaciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ITEMMONEDACOTIZACIONESPROXY as ITEMMONEDACOTIZACIONES of ITEMMONEDACOTIZACIONES.PRG
	function Class_Access() as String
		return 'itemmonedacotizaciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'itemmonedacotizaciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSUCURSALPROXY as DIN_ENTIDADSUCURSAL of DIN_ENTIDADSUCURSAL.PRG
	function Class_Access() as String
		return 'din_entidadsucursal'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadsucursal.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSUCURSALAD_SQLSERVERPROXY as DIN_ENTIDADSUCURSALAD_SQLSERVER of DIN_ENTIDADSUCURSALAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadsucursalad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadsucursalad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADVALORAD_SQLSERVERPROXY as DIN_ENTIDADVALORAD_SQLSERVER of DIN_ENTIDADVALORAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadvalorad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadvalorad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEVALORDETALLEPLANESPROXY as DIN_DETALLEVALORDETALLEPLANES of DIN_DETALLEVALORDETALLEPLANES.PRG
	function Class_Access() as String
		return 'din_detallevalordetalleplanes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallevalordetalleplanes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ITEMVALORDETALLEPLANESPROXY as ITEMVALORDETALLEPLANES of ITEMVALORDETALLEPLANES.PRG
	function Class_Access() as String
		return 'itemvalordetalleplanes'
	endfunc
	function ClassLibrary_Access() as String
		return 'itemvalordetalleplanes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEVALORDETALLEACREDITACIONPLANESPROXY as DIN_DETALLEVALORDETALLEACREDITACIONPLANES of DIN_DETALLEVALORDETALLEACREDITACIONPLANES.PRG
	function Class_Access() as String
		return 'din_detallevalordetalleacreditacionplanes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallevalordetalleacreditacionplanes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMVALORDETALLEACREDITACIONPLANESPROXY as DIN_ITEMVALORDETALLEACREDITACIONPLANES of DIN_ITEMVALORDETALLEACREDITACIONPLANES.PRG
	function Class_Access() as String
		return 'din_itemvalordetalleacreditacionplanes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemvalordetalleacreditacionplanes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENTCOLORYTALLE_CAJAESTADOPROXY as ENTCOLORYTALLE_CAJAESTADO of ENTCOLORYTALLE_CAJAESTADO.PRG
	function Class_Access() as String
		return 'entcolorytalle_cajaestado'
	endfunc
	function ClassLibrary_Access() as String
		return 'entcolorytalle_cajaestado.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCAJAESTADOAD_SQLSERVERPROXY as DIN_ENTIDADCAJAESTADOAD_SQLSERVER of DIN_ENTIDADCAJAESTADOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadcajaestadoad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcajaestadoad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADLISTADEPRECIOSAD_SQLSERVERPROXY as DIN_ENTIDADLISTADEPRECIOSAD_SQLSERVER of DIN_ENTIDADLISTADEPRECIOSAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadlistadepreciosad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadlistadepreciosad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEVALORESPROXY as COMPONENTEVALORES of COMPONENTEVALORES.PRG
	function Class_Access() as String
		return 'componentevalores'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentevalores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTETARJETADECREDITOPROXY as COMPONENTETARJETADECREDITO of COMPONENTETARJETADECREDITO.PRG
	function Class_Access() as String
		return 'componentetarjetadecredito'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentetarjetadecredito.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTECUENTACORRIENTEVALORESPROXY as COMPONENTECUENTACORRIENTEVALORES of COMPONENTECUENTACORRIENTEVALORES.PRG
	function Class_Access() as String
		return 'componentecuentacorrientevalores'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentecuentacorrientevalores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTECUENTACORRIENTEVALORESVENTASPROXY as COMPONENTECUENTACORRIENTEVALORESVENTAS of COMPONENTECUENTACORRIENTEVALORESVENTAS.PRG
	function Class_Access() as String
		return 'componentecuentacorrientevaloresventas'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentecuentacorrientevaloresventas.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEAJUSTEDECUPONESPROXY as COMPONENTEAJUSTEDECUPONES of COMPONENTEAJUSTEDECUPONES.PRG
	function Class_Access() as String
		return 'componenteajustedecupones'
	endfunc
	function ClassLibrary_Access() as String
		return 'componenteajustedecupones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_TALONARIOPROXY as ENT_TALONARIO of ENT_TALONARIO.PRG
	function Class_Access() as String
		return 'ent_talonario'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_talonario.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTALONARIOAD_SQLSERVERPROXY as DIN_ENTIDADTALONARIOAD_SQLSERVER of DIN_ENTIDADTALONARIOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadtalonarioad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtalonarioad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DECORADORDECODIGOSDEENTIDADESPROXY as DECORADORDECODIGOSDEENTIDADES of DECORADORDECODIGOSDEENTIDADES.PRG
	function Class_Access() as String
		return 'decoradordecodigosdeentidades'
	endfunc
	function ClassLibrary_Access() as String
		return 'decoradordecodigosdeentidades.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCLIENTEAD_SQLSERVERPROXY as DIN_ENTIDADCLIENTEAD_SQLSERVER of DIN_ENTIDADCLIENTEAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadclientead_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadclientead_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLECLIENTEPERCEPCIONESPROXY as DIN_DETALLECLIENTEPERCEPCIONES of DIN_DETALLECLIENTEPERCEPCIONES.PRG
	function Class_Access() as String
		return 'din_detalleclientepercepciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleclientepercepciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ITEMCLIENTEPERCEPCIONESPROXY as ITEMCLIENTEPERCEPCIONES of ITEMCLIENTEPERCEPCIONES.PRG
	function Class_Access() as String
		return 'itemclientepercepciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'itemclientepercepciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_SENIAPROXY as ENT_SENIA of ENT_SENIA.PRG
	function Class_Access() as String
		return 'ent_senia'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_senia.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSENIAAD_SQLSERVERPROXY as DIN_ENTIDADSENIAAD_SQLSERVER of DIN_ENTIDADSENIAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadseniaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadseniaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSITUACIONFISCALPROXY as DIN_ENTIDADSITUACIONFISCAL of DIN_ENTIDADSITUACIONFISCAL.PRG
	function Class_Access() as String
		return 'din_entidadsituacionfiscal'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadsituacionfiscal.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSITUACIONFISCALAD_SQLSERVERPROXY as DIN_ENTIDADSITUACIONFISCALAD_SQLSERVER of DIN_ENTIDADSITUACIONFISCALAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadsituacionfiscalad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadsituacionfiscalad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class MANAGERPROMOCIONESPROXY as MANAGERPROMOCIONES of MANAGERPROMOCIONES.PRG
	function Class_Access() as String
		return 'managerpromociones'
	endfunc
	function ClassLibrary_Access() as String
		return 'managerpromociones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADPROMOCIONAD_SQLSERVERPROXY as DIN_ENTIDADPROMOCIONAD_SQLSERVER of DIN_ENTIDADPROMOCIONAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadpromocionad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadpromocionad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADVENDEDORAD_SQLSERVERPROXY as DIN_ENTIDADVENDEDORAD_SQLSERVER of DIN_ENTIDADVENDEDORAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadvendedorad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadvendedorad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DESACTIVADORBASEPROXY as DESACTIVADORBASE of DESACTIVADORBASE.PRG
	function Class_Access() as String
		return 'desactivadorbase'
	endfunc
	function ClassLibrary_Access() as String
		return 'desactivadorbase.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class MANAGERIMPRESIONPROXY as MANAGERIMPRESION of MANAGERIMPRESION.PRG
	function Class_Access() as String
		return 'managerimpresion'
	endfunc
	function ClassLibrary_Access() as String
		return 'managerimpresion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_DISENOIMPRESIONPROXY as ENT_DISENOIMPRESION of ENT_DISENOIMPRESION.PRG
	function Class_Access() as String
		return 'ent_disenoimpresion'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_disenoimpresion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DETALLEDISENOIMPRESIONAREASPROXY as DETALLEDISENOIMPRESIONAREAS of DETALLEDISENOIMPRESIONAREAS.PRG
	function Class_Access() as String
		return 'detalledisenoimpresionareas'
	endfunc
	function ClassLibrary_Access() as String
		return 'detalledisenoimpresionareas.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ITEMDISENOIMPRESIONAREASPROXY as ITEMDISENOIMPRESIONAREAS of ITEMDISENOIMPRESIONAREAS.PRG
	function Class_Access() as String
		return 'itemdisenoimpresionareas'
	endfunc
	function ClassLibrary_Access() as String
		return 'itemdisenoimpresionareas.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADDISENOIMPRESIONAD_SQLSERVERPROXY as DIN_ENTIDADDISENOIMPRESIONAD_SQLSERVER of DIN_ENTIDADDISENOIMPRESIONAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidaddisenoimpresionad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidaddisenoimpresionad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADARTICULOAD_SQLSERVERPROXY as DIN_ENTIDADARTICULOAD_SQLSERVER of DIN_ENTIDADARTICULOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadarticuload_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadarticuload_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class FACTORYVALIDADORESDECOMPROBANTESPROXY as FACTORYVALIDADORESDECOMPROBANTES of FACTORYVALIDADORESDECOMPROBANTES.PRG
	function Class_Access() as String
		return 'factoryvalidadoresdecomprobantes'
	endfunc
	function ClassLibrary_Access() as String
		return 'factoryvalidadoresdecomprobantes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORESDECOMPROBANTESPROXY as VALIDADORESDECOMPROBANTES of VALIDADORESDECOMPROBANTES.PRG
	function Class_Access() as String
		return 'validadoresdecomprobantes'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadoresdecomprobantes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORCOMPROBANTECONVALORESPROXY as VALIDADORCOMPROBANTECONVALORES of VALIDADORCOMPROBANTECONVALORES.PRG
	function Class_Access() as String
		return 'validadorcomprobanteconvalores'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadorcomprobanteconvalores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORCOMPROBANTEDEVENTASPROXY as VALIDADORCOMPROBANTEDEVENTAS of VALIDADORCOMPROBANTEDEVENTAS.PRG
	function Class_Access() as String
		return 'validadorcomprobantedeventas'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadorcomprobantedeventas.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORCOMPROBANTECONVALORES_GRUPOPROXY as VALIDADORCOMPROBANTECONVALORES_GRUPO of VALIDADORCOMPROBANTECONVALORES_GRUPO.PRG
	function Class_Access() as String
		return 'validadorcomprobanteconvalores_grupo'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadorcomprobanteconvalores_grupo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENTCOLORYTALLE_PRECIODEARTICULOPROXY as ENTCOLORYTALLE_PRECIODEARTICULO of ENTCOLORYTALLE_PRECIODEARTICULO.PRG
	function Class_Access() as String
		return 'entcolorytalle_preciodearticulo'
	endfunc
	function ClassLibrary_Access() as String
		return 'entcolorytalle_preciodearticulo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADPRECIODEARTICULOAD_SQLSERVERPROXY as DIN_ENTIDADPRECIODEARTICULOAD_SQLSERVER of DIN_ENTIDADPRECIODEARTICULOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadpreciodearticuload_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadpreciodearticuload_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADUNIDADDEMEDIDAPROXY as DIN_ENTIDADUNIDADDEMEDIDA of DIN_ENTIDADUNIDADDEMEDIDA.PRG
	function Class_Access() as String
		return 'din_entidadunidaddemedida'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadunidaddemedida.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADUNIDADDEMEDIDAAD_SQLSERVERPROXY as DIN_ENTIDADUNIDADDEMEDIDAAD_SQLSERVER of DIN_ENTIDADUNIDADDEMEDIDAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadunidaddemedidaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadunidaddemedidaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCOLORAD_SQLSERVERPROXY as DIN_ENTIDADCOLORAD_SQLSERVER of DIN_ENTIDADCOLORAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadcolorad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcolorad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTALLEAD_SQLSERVERPROXY as DIN_ENTIDADTALLEAD_SQLSERVER of DIN_ENTIDADTALLEAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadtallead_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtallead_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLABORADORCONSULTASDESTOCKPROXY as COLABORADORCONSULTASDESTOCK of COLABORADORCONSULTASDESTOCK.PRG
	function Class_Access() as String
		return 'colaboradorconsultasdestock'
	endfunc
	function ClassLibrary_Access() as String
		return 'colaboradorconsultasdestock.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENTCOLORYTALLE_STOCKCOMBINACIONPROXY as ENTCOLORYTALLE_STOCKCOMBINACION of ENTCOLORYTALLE_STOCKCOMBINACION.PRG
	function Class_Access() as String
		return 'entcolorytalle_stockcombinacion'
	endfunc
	function ClassLibrary_Access() as String
		return 'entcolorytalle_stockcombinacion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSTOCKCOMBINACIONAD_SQLSERVERPROXY as DIN_ENTIDADSTOCKCOMBINACIONAD_SQLSERVER of DIN_ENTIDADSTOCKCOMBINACIONAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadstockcombinacionad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadstockcombinacionad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLABORADORCOLORYTALLEPROXY as COLABORADORCOLORYTALLE of COLABORADORCOLORYTALLE.PRG
	function Class_Access() as String
		return 'colaboradorcolorytalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'colaboradorcolorytalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADGRUPOPROXY as DIN_ENTIDADGRUPO of DIN_ENTIDADGRUPO.PRG
	function Class_Access() as String
		return 'din_entidadgrupo'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadgrupo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSTOCKARTICULOSPROXY as DIN_ENTIDADSTOCKARTICULOS of DIN_ENTIDADSTOCKARTICULOS.PRG
	function Class_Access() as String
		return 'din_entidadstockarticulos'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadstockarticulos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSTOCKARTICULOSAD_SQLSERVERPROXY as DIN_ENTIDADSTOCKARTICULOSAD_SQLSERVER of DIN_ENTIDADSTOCKARTICULOSAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadstockarticulosad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadstockarticulosad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CUPONPROXY as ENT_CUPON of ENT_CUPON.PRG
	function Class_Access() as String
		return 'ent_cupon'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_cupon.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCUPONAD_SQLSERVERPROXY as DIN_ENTIDADCUPONAD_SQLSERVER of DIN_ENTIDADCUPONAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadcuponad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcuponad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_POSPROXY as ENT_POS of ENT_POS.PRG
	function Class_Access() as String
		return 'ent_pos'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_pos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEPOSTARJETASDETALLEPROXY as DIN_DETALLEPOSTARJETASDETALLE of DIN_DETALLEPOSTARJETASDETALLE.PRG
	function Class_Access() as String
		return 'din_detallepostarjetasdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallepostarjetasdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMPOSTARJETASDETALLEPROXY as DIN_ITEMPOSTARJETASDETALLE of DIN_ITEMPOSTARJETASDETALLE.PRG
	function Class_Access() as String
		return 'din_itempostarjetasdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itempostarjetasdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEPOSMONEDASDETALLEPROXY as DIN_DETALLEPOSMONEDASDETALLE of DIN_DETALLEPOSMONEDASDETALLE.PRG
	function Class_Access() as String
		return 'din_detalleposmonedasdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleposmonedasdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMPOSMONEDASDETALLEPROXY as DIN_ITEMPOSMONEDASDETALLE of DIN_ITEMPOSMONEDASDETALLE.PRG
	function Class_Access() as String
		return 'din_itemposmonedasdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemposmonedasdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADPOSAD_SQLSERVERPROXY as DIN_ENTIDADPOSAD_SQLSERVER of DIN_ENTIDADPOSAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadposad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadposad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class FRMABM_DATOSTARJETAAVANZADOESTILO2PROXY as FRMABM_DATOSTARJETAAVANZADOESTILO2 of FRMABM_DATOSTARJETAAVANZADOESTILO2.PRG
	function Class_Access() as String
		return 'frmabm_datostarjetaavanzadoestilo2'
	endfunc
	function ClassLibrary_Access() as String
		return 'frmabm_datostarjetaavanzadoestilo2.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_DATOSTARJETAPROXY as ENT_DATOSTARJETA of ENT_DATOSTARJETA.PRG
	function Class_Access() as String
		return 'ent_datostarjeta'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_datostarjeta.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLABORADORPOSPROXY as COLABORADORPOS of COLABORADORPOS.PRG
	function Class_Access() as String
		return 'colaboradorpos'
	endfunc
	function ClassLibrary_Access() as String
		return 'colaboradorpos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_ENTIDADFINANCIERAPROXY as ENT_ENTIDADFINANCIERA of ENT_ENTIDADFINANCIERA.PRG
	function Class_Access() as String
		return 'ent_entidadfinanciera'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_entidadfinanciera.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCLASEDETARJETAPROXY as DIN_ENTIDADCLASEDETARJETA of DIN_ENTIDADCLASEDETARJETA.PRG
	function Class_Access() as String
		return 'din_entidadclasedetarjeta'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadclasedetarjeta.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCLASEDETARJETAAD_SQLSERVERPROXY as DIN_ENTIDADCLASEDETARJETAAD_SQLSERVER of DIN_ENTIDADCLASEDETARJETAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadclasedetarjetaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadclasedetarjetaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEDATOSTARJETADETALLEPLANESPROXY as DIN_DETALLEDATOSTARJETADETALLEPLANES of DIN_DETALLEDATOSTARJETADETALLEPLANES.PRG
	function Class_Access() as String
		return 'din_detalledatostarjetadetalleplanes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalledatostarjetadetalleplanes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMDATOSTARJETADETALLEPLANESPROXY as DIN_ITEMDATOSTARJETADETALLEPLANES of DIN_ITEMDATOSTARJETADETALLEPLANES.PRG
	function Class_Access() as String
		return 'din_itemdatostarjetadetalleplanes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemdatostarjetadetalleplanes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_OPERADORADETARJETAPROXY as ENT_OPERADORADETARJETA of ENT_OPERADORADETARJETA.PRG
	function Class_Access() as String
		return 'ent_operadoradetarjeta'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_operadoradetarjeta.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEOPERADORADETARJETACLASESDETARJETADETALLEPROXY as DIN_DETALLEOPERADORADETARJETACLASESDETARJETADETALLE of DIN_DETALLEOPERADORADETARJETACLASESDETARJETADETALLE.PRG
	function Class_Access() as String
		return 'din_detalleoperadoradetarjetaclasesdetarjetadetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleoperadoradetarjetaclasesdetarjetadetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMOPERADORADETARJETACLASESDETARJETADETALLEPROXY as DIN_ITEMOPERADORADETARJETACLASESDETARJETADETALLE of DIN_ITEMOPERADORADETARJETACLASESDETARJETADETALLE.PRG
	function Class_Access() as String
		return 'din_itemoperadoradetarjetaclasesdetarjetadetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemoperadoradetarjetaclasesdetarjetadetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADOPERADORADETARJETAAD_SQLSERVERPROXY as DIN_ENTIDADOPERADORADETARJETAAD_SQLSERVER of DIN_ENTIDADOPERADORADETARJETAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadoperadoradetarjetaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadoperadoradetarjetaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADENTIDADFINANCIERAAD_SQLSERVERPROXY as DIN_ENTIDADENTIDADFINANCIERAAD_SQLSERVER of DIN_ENTIDADENTIDADFINANCIERAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadentidadfinancieraad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadentidadfinancieraad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_LIMITECONSUMOPROXY as ENT_LIMITECONSUMO of ENT_LIMITECONSUMO.PRG
	function Class_Access() as String
		return 'ent_limiteconsumo'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_limiteconsumo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADLIMITECONSUMOAD_SQLSERVERPROXY as DIN_ENTIDADLIMITECONSUMOAD_SQLSERVER of DIN_ENTIDADLIMITECONSUMOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadlimiteconsumoad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadlimiteconsumoad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCLASIFICACIONCLIENTEPROXY as DIN_ENTIDADCLASIFICACIONCLIENTE of DIN_ENTIDADCLASIFICACIONCLIENTE.PRG
	function Class_Access() as String
		return 'din_entidadclasificacioncliente'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadclasificacioncliente.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLESENIAARTICULOSDETALLEPROXY as DIN_DETALLESENIAARTICULOSDETALLE of DIN_DETALLESENIAARTICULOSDETALLE.PRG
	function Class_Access() as String
		return 'din_detalleseniaarticulosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleseniaarticulosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMSENIAARTICULOSDETALLEPROXY as DIN_ITEMSENIAARTICULOSDETALLE of DIN_ITEMSENIAARTICULOSDETALLE.PRG
	function Class_Access() as String
		return 'din_itemseniaarticulosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemseniaarticulosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COPIADORDEITEMSSTOCKACOLECCIONPROXY as COPIADORDEITEMSSTOCKACOLECCION of COPIADORDEITEMSSTOCKACOLECCION.PRG
	function Class_Access() as String
		return 'copiadordeitemsstockacoleccion'
	endfunc
	function ClassLibrary_Access() as String
		return 'copiadordeitemsstockacoleccion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class AGRUPADORPORARTICULOPROXY as AGRUPADORPORARTICULO of AGRUPADORPORARTICULO.PRG
	function Class_Access() as String
		return 'agrupadorporarticulo'
	endfunc
	function ClassLibrary_Access() as String
		return 'agrupadorporarticulo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPROBANTESYGRUPOSCAJAPROXY as DIN_COMPROBANTESYGRUPOSCAJA of DIN_COMPROBANTESYGRUPOSCAJA.PRG
	function Class_Access() as String
		return 'din_comprobantesygruposcaja'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_comprobantesygruposcaja.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CTACTEPROXY as ENT_CTACTE of ENT_CTACTE.PRG
	function Class_Access() as String
		return 'ent_ctacte'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_ctacte.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDACIONESCUENTACORRIENTEPROXY as VALIDACIONESCUENTACORRIENTE of VALIDACIONESCUENTACORRIENTE.PRG
	function Class_Access() as String
		return 'validacionescuentacorriente'
	endfunc
	function ClassLibrary_Access() as String
		return 'validacionescuentacorriente.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CAJASALDOSPROXY as ENT_CAJASALDOS of ENT_CAJASALDOS.PRG
	function Class_Access() as String
		return 'ent_cajasaldos'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_cajasaldos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCAJASALDOSAD_SQLSERVERPROXY as DIN_ENTIDADCAJASALDOSAD_SQLSERVER of DIN_ENTIDADCAJASALDOSAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadcajasaldosad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcajasaldosad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_MOVIMIENTODECAJAPROXY as ENT_MOVIMIENTODECAJA of ENT_MOVIMIENTODECAJA.PRG
	function Class_Access() as String
		return 'ent_movimientodecaja'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_movimientodecaja.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADMOVIMIENTODECAJAAD_SQLSERVERPROXY as DIN_ENTIDADMOVIMIENTODECAJAAD_SQLSERVER of DIN_ENTIDADMOVIMIENTODECAJAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadmovimientodecajaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadmovimientodecajaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CAJAAUDITORIAPROXY as ENT_CAJAAUDITORIA of ENT_CAJAAUDITORIA.PRG
	function Class_Access() as String
		return 'ent_cajaauditoria'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_cajaauditoria.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCAJAAUDITORIAAD_SQLSERVERPROXY as DIN_ENTIDADCAJAAUDITORIAAD_SQLSERVER of DIN_ENTIDADCAJAAUDITORIAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadcajaauditoriaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcajaauditoriaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLECAJAAUDITORIADETALLEVALORESAUDITORIAPROXY as DIN_DETALLECAJAAUDITORIADETALLEVALORESAUDITORIA of DIN_DETALLECAJAAUDITORIADETALLEVALORESAUDITORIA.PRG
	function Class_Access() as String
		return 'din_detallecajaauditoriadetallevaloresauditoria'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallecajaauditoriadetallevaloresauditoria.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMCAJAAUDITORIADETALLEVALORESAUDITORIAPROXY as DIN_ITEMCAJAAUDITORIADETALLEVALORESAUDITORIA of DIN_ITEMCAJAAUDITORIADETALLEVALORESAUDITORIA.PRG
	function Class_Access() as String
		return 'din_itemcajaauditoriadetallevaloresauditoria'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemcajaauditoriadetallevaloresauditoria.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCHEQUEAD_SQLSERVERPROXY as DIN_ENTIDADCHEQUEAD_SQLSERVER of DIN_ENTIDADCHEQUEAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadchequead_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadchequead_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_VALEDECAMBIOPROXY as ENT_VALEDECAMBIO of ENT_VALEDECAMBIO.PRG
	function Class_Access() as String
		return 'ent_valedecambio'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_valedecambio.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADVALEDECAMBIOAD_SQLSERVERPROXY as DIN_ENTIDADVALEDECAMBIOAD_SQLSERVER of DIN_ENTIDADVALEDECAMBIOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadvaledecambioad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadvaledecambioad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCHEQUEPROPIOAD_SQLSERVERPROXY as DIN_ENTIDADCHEQUEPROPIOAD_SQLSERVER of DIN_ENTIDADCHEQUEPROPIOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadchequepropioad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadchequepropioad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPROBANTEPROXY as DIN_COMPROBANTE of DIN_COMPROBANTE.PRG
	function Class_Access() as String
		return 'din_comprobante'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_comprobante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class FRMABM_SENIAPENDIENTEAVANZADOESTILO2PROXY as FRMABM_SENIAPENDIENTEAVANZADOESTILO2 of FRMABM_SENIAPENDIENTEAVANZADOESTILO2.PRG
	function Class_Access() as String
		return 'frmabm_seniapendienteavanzadoestilo2'
	endfunc
	function ClassLibrary_Access() as String
		return 'frmabm_seniapendienteavanzadoestilo2.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_SENIAPENDIENTEPROXY as ENT_SENIAPENDIENTE of ENT_SENIAPENDIENTE.PRG
	function Class_Access() as String
		return 'ent_seniapendiente'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_seniapendiente.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DETALLESENIAPENDIENTEDETALLESENIASPENDIENTESPROXY as DETALLESENIAPENDIENTEDETALLESENIASPENDIENTES of DETALLESENIAPENDIENTEDETALLESENIASPENDIENTES.PRG
	function Class_Access() as String
		return 'detalleseniapendientedetalleseniaspendientes'
	endfunc
	function ClassLibrary_Access() as String
		return 'detalleseniapendientedetalleseniaspendientes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMSENIAPENDIENTEDETALLESENIASPENDIENTESPROXY as DIN_ITEMSENIAPENDIENTEDETALLESENIASPENDIENTES of DIN_ITEMSENIAPENDIENTEDETALLESENIASPENDIENTES.PRG
	function Class_Access() as String
		return 'din_itemseniapendientedetalleseniaspendientes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemseniapendientedetalleseniaspendientes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSENIAPENDIENTEAD_SQLSERVERPROXY as DIN_ENTIDADSENIAPENDIENTEAD_SQLSERVER of DIN_ENTIDADSENIAPENDIENTEAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadseniapendientead_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadseniapendientead_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class CLONADORCHEQUESARGENTINAPROXY as CLONADORCHEQUESARGENTINA of CLONADORCHEQUESARGENTINA.PRG
	function Class_Access() as String
		return 'clonadorchequesargentina'
	endfunc
	function ClassLibrary_Access() as String
		return 'clonadorchequesargentina.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ESTILOSPROXY as ESTILOS of ESTILOS.PRG
	function Class_Access() as String
		return 'estilos'
	endfunc
	function ClassLibrary_Access() as String
		return 'estilos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ESTILO2PROXY as DIN_ESTILO2 of DIN_ESTILO2.PRG
	function Class_Access() as String
		return 'din_estilo2'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_estilo2.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class EXCEPCIONCOMBINACIONSINSTOCKPROXY as EXCEPCIONCOMBINACIONSINSTOCK of EXCEPCIONCOMBINACIONSINSTOCK.PRG
	function Class_Access() as String
		return 'excepcioncombinacionsinstock'
	endfunc
	function ClassLibrary_Access() as String
		return 'excepcioncombinacionsinstock.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class LANZADORMENSAJESSONOROSPROXY as LANZADORMENSAJESSONOROS of LANZADORMENSAJESSONOROS.PRG
	function Class_Access() as String
		return 'lanzadormensajessonoros'
	endfunc
	function ClassLibrary_Access() as String
		return 'lanzadormensajessonoros.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class MENSAJESINESPERAPROXY as MENSAJESINESPERA of MENSAJESINESPERA.PRG
	function Class_Access() as String
		return 'mensajesinespera'
	endfunc
	function ClassLibrary_Access() as String
		return 'mensajesinespera.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class LANZADORMENSAJESPROXY as LANZADORMENSAJES of LANZADORMENSAJES.PRG
	function Class_Access() as String
		return 'lanzadormensajes'
	endfunc
	function ClassLibrary_Access() as String
		return 'lanzadormensajes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class MULTIMEDIAPROXY as MULTIMEDIA of MULTIMEDIA.PRG
	function Class_Access() as String
		return 'multimedia'
	endfunc
	function ClassLibrary_Access() as String
		return 'multimedia.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class SERIALIZADORDEENTIDADESPROXY as SERIALIZADORDEENTIDADES of SERIALIZADORDEENTIDADES.PRG
	function Class_Access() as String
		return 'serializadordeentidades'
	endfunc
	function ClassLibrary_Access() as String
		return 'serializadordeentidades.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_OBJETOPROMOCIONESPROXY as DIN_OBJETOPROMOCIONES of DIN_OBJETOPROMOCIONES.PRG
	function Class_Access() as String
		return 'din_objetopromociones'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_objetopromociones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADPAISESPROXY as DIN_ENTIDADPAISES of DIN_ENTIDADPAISES.PRG
	function Class_Access() as String
		return 'din_entidadpaises'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadpaises.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADPROVINCIAPROXY as DIN_ENTIDADPROVINCIA of DIN_ENTIDADPROVINCIA.PRG
	function Class_Access() as String
		return 'din_entidadprovincia'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadprovincia.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADPROVEEDORPROXY as DIN_ENTIDADPROVEEDOR of DIN_ENTIDADPROVEEDOR.PRG
	function Class_Access() as String
		return 'din_entidadproveedor'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadproveedor.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTEMPORADAPROXY as DIN_ENTIDADTEMPORADA of DIN_ENTIDADTEMPORADA.PRG
	function Class_Access() as String
		return 'din_entidadtemporada'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtemporada.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADFAMILIAPROXY as DIN_ENTIDADFAMILIA of DIN_ENTIDADFAMILIA.PRG
	function Class_Access() as String
		return 'din_entidadfamilia'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadfamilia.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADMATERIALPROXY as DIN_ENTIDADMATERIAL of DIN_ENTIDADMATERIAL.PRG
	function Class_Access() as String
		return 'din_entidadmaterial'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadmaterial.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADLINEAPROXY as DIN_ENTIDADLINEA of DIN_ENTIDADLINEA.PRG
	function Class_Access() as String
		return 'din_entidadlinea'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadlinea.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCATEGORIADEARTICULOPROXY as DIN_ENTIDADCATEGORIADEARTICULO of DIN_ENTIDADCATEGORIADEARTICULO.PRG
	function Class_Access() as String
		return 'din_entidadcategoriadearticulo'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadcategoriadearticulo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADCLASIFICACIONARTICULOPROXY as DIN_ENTIDADCLASIFICACIONARTICULO of DIN_ENTIDADCLASIFICACIONARTICULO.PRG
	function Class_Access() as String
		return 'din_entidadclasificacionarticulo'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadclasificacionarticulo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTIPODEARTICULOPROXY as DIN_ENTIDADTIPODEARTICULO of DIN_ENTIDADTIPODEARTICULO.PRG
	function Class_Access() as String
		return 'din_entidadtipodearticulo'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtipodearticulo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_PALETADECOLORESPROXY as ENT_PALETADECOLORES of ENT_PALETADECOLORES.PRG
	function Class_Access() as String
		return 'ent_paletadecolores'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_paletadecolores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CURVADETALLESPROXY as ENT_CURVADETALLES of ENT_CURVADETALLES.PRG
	function Class_Access() as String
		return 'ent_curvadetalles'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_curvadetalles.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTIPOSUCURSALPROXY as DIN_ENTIDADTIPOSUCURSAL of DIN_ENTIDADTIPOSUCURSAL.PRG
	function Class_Access() as String
		return 'din_entidadtiposucursal'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtiposucursal.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADLINEASUCURSALPROXY as DIN_ENTIDADLINEASUCURSAL of DIN_ENTIDADLINEASUCURSAL.PRG
	function Class_Access() as String
		return 'din_entidadlineasucursal'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadlineasucursal.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADSEGMENTACIONPROXY as DIN_ENTIDADSEGMENTACION of DIN_ENTIDADSEGMENTACION.PRG
	function Class_Access() as String
		return 'din_entidadsegmentacion'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadsegmentacion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLORYTALLE_COMPONENTEPREPANTALLAPROXY as COLORYTALLE_COMPONENTEPREPANTALLA of COLORYTALLE_COMPONENTEPREPANTALLA.PRG
	function Class_Access() as String
		return 'colorytalle_componenteprepantalla'
	endfunc
	function ClassLibrary_Access() as String
		return 'colorytalle_componenteprepantalla.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class INFORMACIONAPLICACIONPROXY as INFORMACIONAPLICACION of INFORMACIONAPLICACION.PRG
	function Class_Access() as String
		return 'informacionaplicacion'
	endfunc
	function ClassLibrary_Access() as String
		return 'informacionaplicacion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class LANZADORNUEVOENBASEAPROXY as LANZADORNUEVOENBASEA of LANZADORNUEVOENBASEA.PRG
	function Class_Access() as String
		return 'lanzadornuevoenbasea'
	endfunc
	function ClassLibrary_Access() as String
		return 'lanzadornuevoenbasea.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class FRMABM_NUEVOENBASEAAVANZADOESTILO2PROXY as FRMABM_NUEVOENBASEAAVANZADOESTILO2 of FRMABM_NUEVOENBASEAAVANZADOESTILO2.PRG
	function Class_Access() as String
		return 'frmabm_nuevoenbaseaavanzadoestilo2'
	endfunc
	function ClassLibrary_Access() as String
		return 'frmabm_nuevoenbaseaavanzadoestilo2.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_NUEVOENBASEAPROXY as ENT_NUEVOENBASEA of ENT_NUEVOENBASEA.PRG
	function Class_Access() as String
		return 'ent_nuevoenbasea'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_nuevoenbasea.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLENUEVOENBASEADETALLECOMPROBANTESPROXY as DIN_DETALLENUEVOENBASEADETALLECOMPROBANTES of DIN_DETALLENUEVOENBASEADETALLECOMPROBANTES.PRG
	function Class_Access() as String
		return 'din_detallenuevoenbaseadetallecomprobantes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallenuevoenbaseadetallecomprobantes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMNUEVOENBASEADETALLECOMPROBANTESPROXY as DIN_ITEMNUEVOENBASEADETALLECOMPROBANTES of DIN_ITEMNUEVOENBASEADETALLECOMPROBANTES.PRG
	function Class_Access() as String
		return 'din_itemnuevoenbaseadetallecomprobantes'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemnuevoenbaseadetallecomprobantes.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADNUEVOENBASEAAD_SQLSERVERPROXY as DIN_ENTIDADNUEVOENBASEAAD_SQLSERVER of DIN_ENTIDADNUEVOENBASEAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadnuevoenbaseaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadnuevoenbaseaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENTCOLORYTALLE_REMITOPROXY as ENTCOLORYTALLE_REMITO of ENTCOLORYTALLE_REMITO.PRG
	function Class_Access() as String
		return 'entcolorytalle_remito'
	endfunc
	function ClassLibrary_Access() as String
		return 'entcolorytalle_remito.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEREMITOFACTURADETALLEPROXY as DIN_DETALLEREMITOFACTURADETALLE of DIN_DETALLEREMITOFACTURADETALLE.PRG
	function Class_Access() as String
		return 'din_detalleremitofacturadetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleremitofacturadetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMREMITOFACTURADETALLEPROXY as DIN_ITEMREMITOFACTURADETALLE of DIN_ITEMREMITOFACTURADETALLE.PRG
	function Class_Access() as String
		return 'din_itemremitofacturadetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemremitofacturadetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEREMITOIMPUESTOSDETALLEPROXY as DIN_DETALLEREMITOIMPUESTOSDETALLE of DIN_DETALLEREMITOIMPUESTOSDETALLE.PRG
	function Class_Access() as String
		return 'din_detalleremitoimpuestosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleremitoimpuestosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEREMITOIMPUESTOSCOMPROBANTEPROXY as DIN_DETALLEREMITOIMPUESTOSCOMPROBANTE of DIN_DETALLEREMITOIMPUESTOSCOMPROBANTE.PRG
	function Class_Access() as String
		return 'din_detalleremitoimpuestoscomprobante'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleremitoimpuestoscomprobante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEREMITOCOMPAFECPROXY as DIN_DETALLEREMITOCOMPAFEC of DIN_DETALLEREMITOCOMPAFEC.PRG
	function Class_Access() as String
		return 'din_detalleremitocompafec'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleremitocompafec.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMREMITOCOMPAFECPROXY as DIN_ITEMREMITOCOMPAFEC of DIN_ITEMREMITOCOMPAFEC.PRG
	function Class_Access() as String
		return 'din_itemremitocompafec'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemremitocompafec.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMREMITOIMPUESTOSCOMPROBANTEPROXY as DIN_ITEMREMITOIMPUESTOSCOMPROBANTE of DIN_ITEMREMITOIMPUESTOSCOMPROBANTE.PRG
	function Class_Access() as String
		return 'din_itemremitoimpuestoscomprobante'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemremitoimpuestoscomprobante.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMREMITOIMPUESTOSDETALLEPROXY as DIN_ITEMREMITOIMPUESTOSDETALLE of DIN_ITEMREMITOIMPUESTOSDETALLE.PRG
	function Class_Access() as String
		return 'din_itemremitoimpuestosdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemremitoimpuestosdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADREMITOAD_SQLSERVERPROXY as DIN_ENTIDADREMITOAD_SQLSERVER of DIN_ENTIDADREMITOAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadremitoad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadremitoad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTRANSPORTISTAPROXY as DIN_ENTIDADTRANSPORTISTA of DIN_ENTIDADTRANSPORTISTA.PRG
	function Class_Access() as String
		return 'din_entidadtransportista'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtransportista.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADTRANSPORTISTAAD_SQLSERVERPROXY as DIN_ENTIDADTRANSPORTISTAAD_SQLSERVER of DIN_ENTIDADTRANSPORTISTAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadtransportistaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadtransportistaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ITEMSELECCIONENBASEAPROXY as ITEMSELECCIONENBASEA of ITEMSELECCIONENBASEA.PRG
	function Class_Access() as String
		return 'itemseleccionenbasea'
	endfunc
	function ClassLibrary_Access() as String
		return 'itemseleccionenbasea.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class GARBAGECOLLECTORPROXY as GARBAGECOLLECTOR of GARBAGECOLLECTOR.PRG
	function Class_Access() as String
		return 'garbagecollector'
	endfunc
	function ClassLibrary_Access() as String
		return 'garbagecollector.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
* Performance septiembre 2015
*-----------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------
define class MANEJADORERRORESKONTROLERPROXY as MANEJADORERRORESKONTROLER of MANEJADORERRORESKONTROLER.PRG
	function Class_Access() as String
		return 'manejadorerroreskontroler'
	endfunc
	function ClassLibrary_Access() as String
		return 'manejadorerroreskontroler.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine
define class ENT_REGIMENIMPOSITIVOPROXY as ENT_REGIMENIMPOSITIVO of ENT_REGIMENIMPOSITIVO.PRG
	function Class_Access() as String
		return 'ent_regimenimpositivo'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_regimenimpositivo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_IMPUESTOPROXY as ENT_IMPUESTO of ENT_IMPUESTO.PRG
	function Class_Access() as String
		return 'ent_impuesto'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_impuesto.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ADAPTERVALIDADORACEPTACIONDEVALORESPROXY as ADAPTERVALIDADORACEPTACIONDEVALORES of ADAPTERVALIDADORACEPTACIONDEVALORES.PRG
	function Class_Access() as String
		return 'adaptervalidadoraceptaciondevalores'
	endfunc
	function ClassLibrary_Access() as String
		return 'adaptervalidadoraceptaciondevalores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DETALLECLIENTEPERCEPCIONESPROXY as DETALLECLIENTEPERCEPCIONES of DETALLECLIENTEPERCEPCIONES.PRG
	function Class_Access() as String
		return 'detalleclientepercepciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'detalleclientepercepciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLECLIENTECONTACTOPROXY as DIN_DETALLECLIENTECONTACTO of DIN_DETALLECLIENTECONTACTO.PRG
	function Class_Access() as String
		return 'din_detalleclientecontacto'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleclientecontacto.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLECLIENTEOTRASDIRECCIONESPROXY as DIN_DETALLECLIENTEOTRASDIRECCIONES of DIN_DETALLECLIENTEOTRASDIRECCIONES.PRG
	function Class_Access() as String
		return 'din_detalleclienteotrasdirecciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleclienteotrasdirecciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMCLIENTECONTACTOPROXY as DIN_ITEMCLIENTECONTACTO of DIN_ITEMCLIENTECONTACTO.PRG
	function Class_Access() as String
		return 'din_itemclientecontacto'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemclientecontacto.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMCLIENTEOTRASDIRECCIONESPROXY as DIN_ITEMCLIENTEOTRASDIRECCIONES of DIN_ITEMCLIENTEOTRASDIRECCIONES.PRG
	function Class_Access() as String
		return 'din_itemclienteotrasdirecciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemclienteotrasdirecciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEVALORAGRUPUBLIDETALLEPROXY as DIN_DETALLEVALORAGRUPUBLIDETALLE of DIN_DETALLEVALORAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detallevaloragrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallevaloragrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADDATOSADICIONALESCOMPROBANTESAAD_SQLSERVERPROXY as DIN_ENTIDADDATOSADICIONALESCOMPROBANTESAAD_SQLSERVER of DIN_ENTIDADDATOSADICIONALESCOMPROBANTESAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidaddatosadicionalescomprobantesaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidaddatosadicionalescomprobantesaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAPROXY as DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESA of DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESA.PRG
	function Class_Access() as String
		return 'din_entidadmotivodatosadicionalescomprobantesa'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadmotivodatosadicionalescomprobantesa.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAAD_SQLSERVERPROXY as DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAAD_SQLSERVER of DIN_ENTIDADMOTIVODATOSADICIONALESCOMPROBANTESAAD_SQLSERVER.PRG
	function Class_Access() as String
		return 'din_entidadmotivodatosadicionalescomprobantesaad_sqlserver'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadmotivodatosadicionalescomprobantesaad_sqlserver.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMVALORAGRUPUBLIDETALLEPROXY as DIN_ITEMVALORAGRUPUBLIDETALLE of DIN_ITEMVALORAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemvaloragrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemvaloragrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_DATOSADICIONALESCOMPROBANTESAPROXY as ENT_DATOSADICIONALESCOMPROBANTESA of ENT_DATOSADICIONALESCOMPROBANTESA.PRG
	function Class_Access() as String
		return 'ent_datosadicionalescomprobantesa'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_datosadicionalescomprobantesa.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class FRMABM_DATOSADICIONALESCOMPROBANTESAAVANZADOESTILO2PROXY as FRMABM_DATOSADICIONALESCOMPROBANTESAAVANZADOESTILO2 of FRMABM_DATOSADICIONALESCOMPROBANTESAAVANZADOESTILO2.PRG
	function Class_Access() as String
		return 'frmabm_datosadicionalescomprobantesaavanzadoestilo2'
	endfunc
	function ClassLibrary_Access() as String
		return 'frmabm_datosadicionalescomprobantesaavanzadoestilo2.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORACEPTACIONDEVALORESDETALLEPROXY as VALIDADORACEPTACIONDEVALORESDETALLE of VALIDADORACEPTACIONDEVALORESDETALLE.PRG
	function Class_Access() as String
		return 'validadoraceptaciondevaloresdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadoraceptaciondevaloresdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ZOOXMLPROXY as ZOOXML of ZOOXML.PRG
	function Class_Access() as String
		return 'zooxml'
	endfunc
	function ClassLibrary_Access() as String
		return 'zooxml.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLABORADORIMPUESTOSINTERNOSPROXY as COLABORADORIMPUESTOSINTERNOS of COLABORADORIMPUESTOSINTERNOS.PRG
	function Class_Access() as String
		return 'colaboradorimpuestosinternos'
	endfunc
	function ClassLibrary_Access() as String
		return 'colaboradorimpuestosinternos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLELISTADEPRECIOSAGRUPUBLIDETALLEPROXY as DIN_DETALLELISTADEPRECIOSAGRUPUBLIDETALLE of DIN_DETALLELISTADEPRECIOSAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detallelistadepreciosagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallelistadepreciosagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMLISTADEPRECIOSAGRUPUBLIDETALLEPROXY as DIN_ITEMLISTADEPRECIOSAGRUPUBLIDETALLE of DIN_ITEMLISTADEPRECIOSAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemlistadepreciosagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemlistadepreciosagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_PROCEDIMIENTOSALMACENADOSPROXY as DIN_PROCEDIMIENTOSALMACENADOS of DIN_PROCEDIMIENTOSALMACENADOS.PRG
	function Class_Access() as String
		return 'din_procedimientosalmacenados'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_procedimientosalmacenados.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_COMISIONPROXY as ENT_COMISION of ENT_COMISION.PRG
	function Class_Access() as String
		return 'ent_comision'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_comision.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEIMPUESTOSVENTASPROXY as COMPONENTEIMPUESTOSVENTAS of COMPONENTEIMPUESTOSVENTAS.PRG
	function Class_Access() as String
		return 'componenteimpuestosventas'
	endfunc
	function ClassLibrary_Access() as String
		return 'componenteimpuestosventas.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEARTICULOAGRUPUBLIDETALLEPROXY as DIN_DETALLEARTICULOAGRUPUBLIDETALLE of DIN_DETALLEARTICULOAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detallearticuloagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallearticuloagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMARTICULOAGRUPUBLIDETALLEPROXY as DIN_ITEMARTICULOAGRUPUBLIDETALLE of DIN_ITEMARTICULOAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemarticuloagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemarticuloagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_STOCKARTICULOSPROXY as ENT_STOCKARTICULOS of ENT_STOCKARTICULOS.PRG
	function Class_Access() as String
		return 'ent_stockarticulos'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_stockarticulos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTEDATOSADICIONALESCOMPROBANTESAPROXY as COMPONENTEDATOSADICIONALESCOMPROBANTESA of COMPONENTEDATOSADICIONALESCOMPROBANTESA.PRG
	function Class_Access() as String
		return 'componentedatosadicionalescomprobantesa'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentedatosadicionalescomprobantesa.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLABORADORPERCEPCIONESPROXY as COLABORADORPERCEPCIONES of COLABORADORPERCEPCIONES.PRG
	function Class_Access() as String
		return 'colaboradorpercepciones'
	endfunc
	function ClassLibrary_Access() as String
		return 'colaboradorpercepciones.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COLABORADORVALIDACIONCONTROLDESTOCKDIPONIBLEPROXY as COLABORADORVALIDACIONCONTROLDESTOCKDIPONIBLE of COLABORADORVALIDACIONCONTROLDESTOCKDIPONIBLE.PRG
	function Class_Access() as String
		return 'colaboradorvalidacioncontroldestockdiponible'
	endfunc
	function ClassLibrary_Access() as String
		return 'colaboradorvalidacioncontroldestockdiponible.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class COMPONENTESTOCKPROXY as COMPONENTESTOCK of COMPONENTESTOCK.PRG
	function Class_Access() as String
		return 'componentestock'
	endfunc
	function ClassLibrary_Access() as String
		return 'componentestock.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DETALLEVENDEDORCOMISIONESDETALLEPROXY as DETALLEVENDEDORCOMISIONESDETALLE of DETALLEVENDEDORCOMISIONESDETALLE.PRG
	function Class_Access() as String
		return 'detallevendedorcomisionesdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'detallevendedorcomisionesdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLECOLORAGRUPUBLIDETALLEPROXY as DIN_DETALLECOLORAGRUPUBLIDETALLE of DIN_DETALLECOLORAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detallecoloragrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallecoloragrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLECONDICIONDEPAGOPAGOSPERSONALIZADOSPROXY as DIN_DETALLECONDICIONDEPAGOPAGOSPERSONALIZADOS of DIN_DETALLECONDICIONDEPAGOPAGOSPERSONALIZADOS.PRG
	function Class_Access() as String
		return 'din_detallecondiciondepagopagospersonalizados'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallecondiciondepagopagospersonalizados.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLETALLEAGRUPUBLIDETALLEPROXY as DIN_DETALLETALLEAGRUPUBLIDETALLE of DIN_DETALLETALLEAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detalletalleagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalletalleagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEUNIDADDEMEDIDAAGRUPUBLIDETALLEPROXY as DIN_DETALLEUNIDADDEMEDIDAAGRUPUBLIDETALLE of DIN_DETALLEUNIDADDEMEDIDAAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detalleunidaddemedidaagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detalleunidaddemedidaagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_DETALLEVENDEDORAGRUPUBLIDETALLEPROXY as DIN_DETALLEVENDEDORAGRUPUBLIDETALLE of DIN_DETALLEVENDEDORAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_detallevendedoragrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_detallevendedoragrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMCOLORAGRUPUBLIDETALLEPROXY as DIN_ITEMCOLORAGRUPUBLIDETALLE of DIN_ITEMCOLORAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemcoloragrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemcoloragrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMCONDICIONDEPAGOPAGOSPERSONALIZADOSPROXY as DIN_ITEMCONDICIONDEPAGOPAGOSPERSONALIZADOS of DIN_ITEMCONDICIONDEPAGOPAGOSPERSONALIZADOS.PRG
	function Class_Access() as String
		return 'din_itemcondiciondepagopagospersonalizados'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemcondiciondepagopagospersonalizados.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMTALLEAGRUPUBLIDETALLEPROXY as DIN_ITEMTALLEAGRUPUBLIDETALLE of DIN_ITEMTALLEAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemtalleagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemtalleagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMUNIDADDEMEDIDAAGRUPUBLIDETALLEPROXY as DIN_ITEMUNIDADDEMEDIDAAGRUPUBLIDETALLE of DIN_ITEMUNIDADDEMEDIDAAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemunidaddemedidaagrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemunidaddemedidaagrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMVENDEDORAGRUPUBLIDETALLEPROXY as DIN_ITEMVENDEDORAGRUPUBLIDETALLE of DIN_ITEMVENDEDORAGRUPUBLIDETALLE.PRG
	function Class_Access() as String
		return 'din_itemvendedoragrupublidetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemvendedoragrupublidetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ITEMVENDEDORCOMISIONESDETALLEPROXY as DIN_ITEMVENDEDORCOMISIONESDETALLE of DIN_ITEMVENDEDORCOMISIONESDETALLE.PRG
	function Class_Access() as String
		return 'din_itemvendedorcomisionesdetalle'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_itemvendedorcomisionesdetalle.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_CONDICIONDEPAGOPROXY as ENT_CONDICIONDEPAGO of ENT_CONDICIONDEPAGO.PRG
	function Class_Access() as String
		return 'ent_condiciondepago'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_condiciondepago.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_SITUACIONFISCALPROXY as ENT_SITUACIONFISCAL of ENT_SITUACIONFISCAL.PRG
	function Class_Access() as String
		return 'ent_situacionfiscal'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_situacionfiscal.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class ENT_VENDEDORPROXY as ENT_VENDEDOR of ENT_VENDEDOR.PRG
	function Class_Access() as String
		return 'ent_vendedor'
	endfunc
	function ClassLibrary_Access() as String
		return 'ent_vendedor.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORACEPTACIONDEVALORESPROXY as VALIDADORACEPTACIONDEVALORES of VALIDADORACEPTACIONDEVALORES.PRG
	function Class_Access() as String
		return 'validadoraceptaciondevalores'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadoraceptaciondevalores.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class VALIDADORACEPTACIONDEVALORESTARJETADECREDITOPROXY as VALIDADORACEPTACIONDEVALORESTARJETADECREDITO of VALIDADORACEPTACIONDEVALORESTARJETADECREDITO.PRG
	function Class_Access() as String
		return 'validadoraceptaciondevalorestarjetadecredito'
	endfunc
	function ClassLibrary_Access() as String
		return 'validadoraceptaciondevalorestarjetadecredito.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_MENUABMDATOSTARJETAPROXY as DIN_MENUABMDATOSTARJETA of DIN_MENUABMDATOSTARJETA.PRG
	function Class_Access() as String
		return 'din_menuabmdatostarjeta'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_menuabmdatostarjeta.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADMEMORIAPROXY as DIN_ENTIDADMEMORIA of DIN_ENTIDADMEMORIA.PRG
	function Class_Access() as String
		return 'din_entidadmemoria'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadmemoria.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_ENTIDADACCIONESAUTOMATICASPROXY as DIN_ENTIDADACCIONESAUTOMATICAS of DIN_ENTIDADACCIONESAUTOMATICAS.PRG
	function Class_Access() as String
		return 'din_entidadaccionesautomaticas'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_entidadaccionesautomaticas.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_OBJETOCURSORATRIBUTOSCONSALTODECAMPOPROXY as DIN_OBJETOCURSORATRIBUTOSCONSALTODECAMPO of DIN_OBJETOCURSORATRIBUTOSCONSALTODECAMPO.PRG
	function Class_Access() as String
		return 'din_objetocursoratributosconsaltodecampo'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_objetocursoratributosconsaltodecampo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPONENTELIMITESDECONSUMOPROXY as DIN_COMPONENTELIMITESDECONSUMO of DIN_COMPONENTELIMITESDECONSUMO.PRG
	function Class_Access() as String
		return 'din_componentelimitesdeconsumo'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_componentelimitesdeconsumo.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPONENTEECOMMERCEPROXY as DIN_COMPONENTEECOMMERCE of DIN_COMPONENTEECOMMERCE.PRG
	function Class_Access() as String
		return 'din_componenteecommerce'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_componenteecommerce.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPONENTEDESCUENTOSPROXY as DIN_COMPONENTEDESCUENTOS of DIN_COMPONENTEDESCUENTOS.PRG
	function Class_Access() as String
		return 'din_componentedescuentos'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_componentedescuentos.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class DIN_COMPONENTESENIASPROXY as DIN_COMPONENTESENIAS of DIN_COMPONENTESENIAS.PRG
	function Class_Access() as String
		return 'din_componentesenias'
	endfunc
	function ClassLibrary_Access() as String
		return 'din_componentesenias.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine
