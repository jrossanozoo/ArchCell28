define class componenteEcommerce as Din_componenteEcommerce of Din_componenteEcommerce.prg

	#if .f.
		local this as ColaboradorRetenciones as ColaboradorRetenciones.prg
	#endif

	oColSentencias = null
	oEntidadAfectante = null
	oEntidadAfectada = null
	oColSentenciasOpeEcom = null
	oColDatosOperacion = null
	
	*-----------------------------------------------------------------------------------------
	function oColDatosOperacion_Access() as Void
		if !this.lDestroy and vartype( this.oColDatosOperacion) != "O"
			this.oColDatosOperacion = _screen.zoo.CrearObjeto( "zooColeccion" )
		endif
		return this.oColDatosOperacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function inyectarEntidadAfectante( toEntidad ) as Void
		this.oEntidadAfectante = toEntidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function instanciarEntidadAfectada( toEntidad ) as Void
		this.oEntidadAfectada = toEntidad
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarDetalleInformacionAdicionalOp( toOperacion, toEntidad, tcBase ) as Void
		if pemstatus( toEntidad, "Compafec", 5 )
			with toEntidad.Compafec
				with .oItem
					.tipoComprobante = 99
					.Letra = "X"
					.PuntoDeVenta = 1
					.Numero = 999999
					.Afecta = toOperacion.Codigo
					.tipocompcaracter = alltrim( toOperacion.cDescripcion ) + " Nº " + alltrim(transform( toOperacion.Numero )) 
					.fecha = toOperacion.fecha
					.tipo = "Afectado"
					.origen = tcBase
					.nombreentidad = toOperacion.cnombre
				endwith 
				.actualizar()	
			endwith	
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarDetalleInformacionAdicionalEnt( toEntidad, tnNumero, tcBase, tlEsCancelacion, toColItemsAgregadosAlDetalle ) as Object
		local lcMensaje as String, lcFechayHora as string, lcDescripcionComprobante as String, lnItem as Integer,;
			  lcSentencia as string, loColSentenciasOpeEcom as collection, lcLetra as String, lnPuntoDeVenta as Integer,;
			  lnTipoComprobante as Integer, lcTipoCompCaracter as String, lnNumero as Integer, lcAfecta as String,;
			  ldFecha as String, lcTipo as String, lcOrigen as String, lcNombreEntidad as String, lnNroItem as Integer,;
			  lcValorAntCampoZADSFW as String
		
		store "" to lcDescripcionComprobante, lcLetra, lcTipoCompCaracter, lcAfecta, ldFecha, lcTipo, lcOrigen, lcNombreEntidad, lcValorAntCampoZADSFW
		store 0 to lnPuntoDeVenta, lntipoComprobante, lnNumero,	lnNroItem
		loColSentenciasOpeEcom = _screen.zoo.crearObjeto( "zooColeccion" )
		
		if pemstatus( this.oEntidadAfectante, "Compafec", 5 )
			* Agrego las sentencias para Compafec
			
			lcCodigo = this.oEntidadAfectante.Codigo && Es el codigo guid de la operacion
			lcTabla = this.oEntidadAfectante.OAD.cEsquema + "." + "COMPAFE"
			
			if upper( alltrim( toEntidad.cNombre) ) = "MOVIMIENTODESTOCK"
				lcLetra = "X"
				lnPuntoDeVenta = 9999
				lntipoComprobante = 99
				lctipocompcaracter = alltrim( toEntidad.cDescripcion ) + " Nº " + padl( int( toEntidad.Numero ), 8, "0" )
			else
				lcLetra = toEntidad.Letra
				lnPuntoDeVenta = toEntidad.PuntoDeVenta
				lntipoComprobante = toEntidad.TipoComprobante
				lctipocompcaracter = alltrim( toEntidad.cDescripcion ) + " Nº " + toEntidad.Letra + " " + padl( int( toEntidad.PuntoDeVenta ), 4, "0" ) + "-" + padl( int( toEntidad.Numero ), 8, "0" )
			endif
			lcDescripcionComprobante = lctipocompcaracter
			lnNumero = toEntidad.Numero
			lcAfecta = toEntidad.codigo
			ldFecha = dtoc( toEntidad.fecha, 1 )
			lcTipo = "Afectante"
			lcorigen = tcBase
			lcNombreEntidad = toEntidad.cNombre
			lnNroItem = this.ObtenerProximoNroDeItem( lcCodigo )
			
			text to lcSentencia noshow textmerge
				insert into <<lcTabla>> ( AFECOMPROB, AFECTA, AFEFECHA, AFELETRA, AFENUMCOM, AFEPTOVEN, AFETIPO, AFETIPOCOM, CODIGO, NROITEM, ORIGEN, NOMINTER ) 
				values ( '<<lctipocompcaracter>>', '<<lcAfecta>>', '<<ldFecha >>', '<<lcLetra>>' , '<<lnNumero>>', '<<lnPuntoDeVenta >>', '<<lcTipo>>',
						 '<<lnTipoComprobante>>', '<<lcCodigo>>', '<<lnNroItem>>', '<<tcBase>>', '<<lcNombreEntidad>>' )
			endtext	
 
			loColSentenciasOpeEcom.add( lcSentencia )
			
			* Para cuando se utiliza las opciones de Pedido y factura en la accion de la herramienta
			lcFactura = ""
			for each Compafe in toEntidad.Compafec
				if "FACTURA" $ alltrim( upper( Compafe.TipoCompCaracter ) )
					lcFactura = " y " + Compafe.TipoCompCaracter
				endif
			endfor
			
			* Ahora modifico la cabezera de la operacion
			lcFechayHora = dtoc( goServicios.Librerias.ObtenerFecha() ) + " - " + goServicios.Librerias.ObtenerHora() 
			lcMensaje = lcFechayHora + " - " + lcDescripcionComprobante + lcFactura + " ( " + alltrim( tcBase )  + " ). Generado por la Herramienta de generación de comprobantes N° " + ;
						alltrim( str( tnNumero ) )
			
			lcValorAntCampoZADSFW = this.ObtenerDatoZADSFW( lcCodigo )
			if !empty( lcValorAntCampoZADSFW )
				lcMensaje = lcMensaje + chr(13) + lcValorAntCampoZADSFW
			endif
			
			lcTabla = this.oEntidadAfectante.OAD.cEsquema + "." + "OPECOM"

			lcSentencia = "update " + lcTabla + " set ZADSFW = '" + lcMensaje + "'" + iif( tlEsCancelacion, ", penproc = 0, ",", " ) + ;
						   					    "FModiFW = '" + dtoc( goServicios.Librerias.obtenerfecha(), 1 ) + "', HModiFW = '" + golibrerias.obtenerhora() + "'," + ;
							   					"UmodiFW = '" + goServicios.Seguridad.cUsuarioLogueado + "', SmodiFW = '" + _Screen.Zoo.App.cSerie + "'," + ;
							   					"VmodiFW = '" + _screen.zoo.app.cVersionSegunIni + "', BDmodiFW = '" + _screen.zoo.app.cSucursalActiva + "' " + ;
						  "where codigo = '" + lcCodigo + "'"

			loColSentenciasOpeEcom.add( lcSentencia )
			
			* Si es una cancelacion modifico tambien el detalle
			if tlEsCancelacion
				lcTabla = this.oEntidadAfectante.OAD.cEsquema + "." + "OPECOMDet"
				for lnItem = 1 to toColItemsAgregadosAlDetalle.count
					lcSentencia = "update " + lcTabla + " set codherrcan = " + alltrim(str(tnNumero)) + " where codigo = '" + lcCodigo + "' and nroitem = " + alltrim(str(toColItemsAgregadosAlDetalle.item(lnItem)))
					loColSentenciasOpeEcom.add( lcSentencia )
				endfor
			endif
		endif 
		
		return loColSentenciasOpeEcom
	endfunc	

	*-----------------------------------------------------------------------------------------
	function Grabar() as zoocoleccion of zoocoleccion.prg
		
		if !this.lNuevo and !this.lEdicion and vartype( this.oEntidadAfectada ) = "O"
			this.ObtenerSentenciasEliminar()
		endif

		if this.lNuevo
			this.AgregarSentenciaActualizarComprobanteEnHerramienta()
		endif
		 
		return this.oColSentencias
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarSentenciaActualizarComprobanteEnHerramienta() as Void
		local lcSentencia as String, lcComp as String, lnOpeNumero as Number, lcHerrNum as Number ,;
			lnPos as Number, lcProducto as String, lcBaseDeDato as String
		
		store "" to lcBaseDeDato, lcProducto, lcSentencia, lcComp, lcHerrNum
		store 0 to lnOpeNumero, lcHerrNum, lnPosH, lnPosO

		lnPosH = this.oColDatosOperacion.getkey("NUMEROHERRAMIENTA")
		lnPosO = this.oColDatosOperacion.getkey("NUMEROOPERACION")
		
		if lnPosH > 0 and lnPosO > 0
			lcHerrNum = this.oColDatosOperacion.item[lnPosH]
			lnOpeNumero = this.oColDatosOperacion.item[lnPosO]
			with this.oEntidadAfectada
				lcComp = upper(.oComponente.ObtenerIdentificadorDeComprobante( .TipoComprobante ) ) + " " + ;
				transform( .Letra ) + " " + transform( .PuntoDeVenta,"@LZ 9999" ) + "-" + transform( .Numero, "@LZ 99999999" )
			endwith
			lcProducto = _screen.zoo.app.nombreProducto
			lcBaseDeDato = _screen.zoo.app.csucursalactiva
			lcSentencia = [ update ]+ "[" + lcProducto +  "_" + lcBaseDeDato + "]" + ".[ZooLogic].[ECCOMPDET]" + [ set nrocomp = '] + alltrim( lcComp  ) + [' where openum = '] + alltrim( TRANSFORM( lnOpeNumero  ) ) + [' and numero = ] + alltrim( TRANSFORM( LcHerrNum ) )
			this.oColSentencias.Agregar( lcSentencia )
		endif
		
		this.oColDatosOperacion = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciasEliminar() as Void
		local lcProducto as String, lcBaseDeDato as String, lcTabla as String, lcCampoAfecta as String, lcCodigo as String, lcSentencia as string	
		lcProducto = _screen.zoo.app.nombreProducto
		lcBaseDeDato = _screen.zoo.app.csucursalactiva
		lcTabla = "COMPAFE"
		lcCampoAfecta = "AFECTA"
		lcCodigo = this.oEntidadAfectada.codigo		
		lcSentencia = "DELETE From [" + lcProducto  + "_" + lcBaseDeDato  + "].[ZooLogic].["+ lcTabla + "] where " + lcCampoAfecta + " = '" + lcCodigo + "'"  
		this.oColSentencias.Agregar( lcSentencia )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerProximoNroDeItem( lcCodigoOperacionEcom as String ) as Integer
		local lnRetorno as Integer, lcSentencia as String, lcCursor as String, lcCursorAnt as String
		lcCursorAnt = alias()
		lnRetorno = 1
		lcCursor = sys(2015)
		
		lcSentencia = "select top 1 nroitem from [" +; 
					 _screen.zoo.app.nombreProducto + "_" + _screen.zoo.app.csucursalactiva + "].[ZooLogic].[COMPAFE] " + ;
				      "where codigo = '" + lcCodigoOperacionEcom + "' order by nroitem desc"

		goServicios.Datos.EjecutarSentencias( lcSentencia, "COMPAFE", "", lcCursor, this.DataSessionId )
		
		select ( lcCursor )
		
		if reccount( lcCursor ) > 0
			lnRetorno = &lcCursor..nroitem + 1
		endif
		
		use in ( lcCursor )
		
		if !empty( lcCursorAnt ) and used( lcCursorAnt )
			select ( lcCursorAnt )
		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatoZADSFW( tcCodigo as String ) as String
		local lcRetorno as String, lcXMLResultado as String, lcCursor as String, lcWhere as string, lcCampo as String,;
			  lcAtributo as String, lcWhere as string, lcCursorAnt as String
		
		lcCursorAnt = alias()
		lcAtributo = "ZADSFW"
		lcCampo = this.oEntidadAfectante.OAD.ObtenerCampoEntidad( "CODIGO" )  
		lcCursor = "c_" + sys(2015)
		lcWhere = lcCampo + " = '" + tcCodigo + "'"
		
		lcXMLResultado = this.oEntidadAfectante.OAD.obtenerdatosentidad( lcAtributo, lcWhere, "", "", 1 )
		
		xmlToCursor( lcXMLResultado , lcCursor, 4 )
		
		select ( lcCursor )
		
		if reccount() = 1
			lcRetorno = alltrim( &lcCursor..ZADSFW )
		else
			lcRetorno = ""
		endif
		
		use in select ( lcCursor )	

		if !empty( lcCursorAnt ) and used( lcCursorAnt )
			select ( lcCursorAnt )
		endif
		
		return lcRetorno

	endfunc
	
enddefine 
