define class ItemPRESUPUESTOSRLSFacturadetalle as din_ItemPRESUPUESTOSRLSFacturadetalle of din_ItemPRESUPUESTOSRLSFacturadetalle.prg

	oColaboradorPresupuestos = null
	oListaDePrecios = null
	oDetalle		= null
	oEntidad		= null
	lConfirmaSerieSinItemsVigentes = .f.
	oColaboradorNormalizadorNombres = null
	oClasificacionesDelCliente = null

	*-----------------------------------------------------------------------------------------
	function SetearClasificacionesDelCliente( toClasificaciones as zoocoleccion OF zoocoleccion.prg ) as Void
		this.oClasificacionesDelCliente = toClasificaciones
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarClasificacionArticulo() as Boolean
		local llRetorno as Boolean, lcMensaje as String , loClasificacionesDelArticulo as Collection, I as Integer, J as Integer, lcClasifiArt as String, lcClasifiCli as String

		if upper( alltrim( this.Articulo_PK ) ) = ""
			llRetorno = .t.
		else
			loClasificacionesDelArticulo = this.ArticuloVirtual.ObtenerClasificaciones()
			
			llRetorno = iif( loClasificacionesDelArticulo.Count = 0 and this.oClasificacionesDelCliente.Count = 0, .t., .f. )
			lcClasifiArt = ""
			lcClasifiCli = ""

			for I = 1 to loClasificacionesDelArticulo.Count 
				if !empty( loClasificacionesDelArticulo.item[I] )
					for J = 1 to this.oClasificacionesDelCliente.Count
						if upper( alltrim( loClasificacionesDelArticulo.item[I] )) = upper( alltrim( this.oClasificacionesDelCliente.item[J] ) )
							J = this.oClasificacionesDelCliente.Count
							I = loClasificacionesDelArticulo.Count
							llRetorno = .t.	
						endif

						if !empty(lcClasifiCli)
							lcClasifiCli = lcClasifiCli + iif( at( upper( alltrim( this.oClasificacionesDelCliente.item[J] ) ), lcClasifiCli ) > 0, "", ', ' + upper( alltrim( this.oClasificacionesDelCliente.item[J] ) ) )
						else
							lcClasifiCli = upper( alltrim( this.oClasificacionesDelCliente.item[J] ) )
						endif
					endfor 
					if !empty(lcClasifiArt)
						lcClasifiArt = lcClasifiArt + ', ' + upper( alltrim( loClasificacionesDelArticulo.item[I] ) )
					else
						lcClasifiArt = upper( alltrim( loClasificacionesDelArticulo.item[I] ))
					endif
				endif
			endfor 
			
			if !llRetorno 
				lcMensaje = "Las clasificaciones " + "(" + lcClasifiArt + ")" + " del artículo " + upper( alltrim( this.articulo_pk ) ) + " no coinciden con las del cliente " + "(" + lcClasifiCli + ")."
				goServicios.Errores.LevantarExcepcion( lcMensaje )
			endif
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		local llRespuesta
		llrespuesta = dodefault()
		if llRespuesta
			this.BindearEvento( this.Coddesc, "AjustarObjetoBusqueda", this, "SetearFiltroBuscadorCoddesc" )
			this.BindearEvento( this.Articulo, "AjustarObjetoBusqueda", this, "SetearFiltroBuscadorArticulo" )
			this.BindearEvento( this.Serie, "AjustarObjetoBusqueda", this, "SetearFiltroBuscadorSerie" )
		endif
		this.Enlazar( "haCambiado", "EventoComponentePrecio" )
	endfunc

	*-----------------------------------------------------------------------------------------
    function Setear_Monto( txVal as Variant ) as Void
    	dodefault( txVal )
		with this
			.PrecioEnDolares = .Articulo.PrecioEnDolares
			if .PrecioEnDolares
				.MontoD = txVal
				.MontoP = 0
			else
				.MontoP = txVal
				.MontoD = 0
			endif
		endwith
    endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarTotalMoneda() as Void
		with this
			if .Articulo.PrecioEnDolares
				.MontoD = .Monto
				.MontoP = 0
			else
				.MontoP = .Monto
				.MontoD = 0
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorCoddesc( toObjeto ) as Void
		local loFiltro as String

		text to loFiltro textmerge noshow pretext 11
			CODIGO in
				(
					select CODIGO
					from ZL.DESCPRESUP
					where ( ARTDES <= '<<alltrim(this.Articulo_pk)>>' and case when ARTHAS = '' then 'ZZZZZZZZZZZZZ' else ARTHAS end >= '<<alltrim(this.Articulo_pk)>>' )
						and ( FECDES <= dateadd(d, datediff(d, 0, getdate()), 0) and case when FECHAS = '' then '99991231' else FECHAS end >= dateadd(d, datediff(d, 0, getdate()), 0) )
				)
		endtext
		toObjeto.Filtro = loFiltro
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorArticulo( toObjeto ) as Void
		local loFiltro as String, lcFiltro as String 
		lcFiltro = this.ObtenerFiltroTipoDePresupuesto()
		text to loFiltro textmerge noshow pretext 11
			IsArticu.desacti = 0 and 
			IsArticu.ccod in ( 
				select 
					Articulo 
					from ZL.func_COM_ArticulosParaPresupuestosPorEjecutivo('<<alltrim(goServicios.Seguridad.ObtenerUltimoUsuarioLogueado())>>')
						where <<lcFiltro>>
							 )
		endtext
		toObjeto.Filtro = loFiltro
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Articulo_PK_Assign( txVal as variant ) as void
		local lxValOld as Variant, lxVal as Variant, loSugerido as Object

		lxValOld = this.Articulo_PK
		lxVal = txVal
		lxVal = iif( len( lxVal ) < 13, padr( lxVal, 13 ), lxVal )
		this.Articulo_PK = lxVal

		if this.Validar_Articulo( lxVal, lxValOld )
			if this.Validacion_Articulo_PK()
				this.ArticuloVirtual_pk = this.Articulo.Codigo
				if this.VerificarClasificacionArticulo()
					if this.ValidarProductoDelArticulo( lxVal )
						if this.ValidarSiElSerieNoTieneItemActivoyEsProductoLinceQueTengaClasificacion39( lxVal )
							if this.ValidarSerieDragonContraArticuloDragonCloud( this.Serie_PK, lxVal )
								this.EventoAntesDeSetear( this, 'Articulo_Pk', lxValOld, lxVal )
								this.Setear_Articulo( lxVal )
								this.EventoDespuesDeSetear( this, 'Articulo_Pk', lxValOld, lxVal )
								if lxValOld != lxVal
									if this.PuedeEjecutarHaCambiado()
										this.HaCambiado( 'Articulo_Pk', this )
									endif
								endif
								if lxValOld != lxVal or empty( this.Articulodetalle )
									this.Articulodetalle = this.ARTICULO.DESCRIP
								endif
							else
								this.Articulo_PK = lxValOld
								goServicios.Errores.LevantarExcepcion( "El serie no admite artículos con módulos Cloud." )
							endif
						else
							this.Articulo_PK = lxValOld
							goServicios.Errores.LevantarExcepcion( "El primer artículo ingresado para un serie de Lince sin ítems vigentes debe contener la clasificación 39." )
						endif	
					else
						this.Articulo_PK = lxValOld
						goServicios.Errores.LevantarExcepcion( "El artículo debe tener un tipo de artículo del tipo de presupuesto abono." )
					endif
				else
					this.Articulo_PK = lxValOld
					this.ArticuloVirtual_pk = lxValOld
				endif
			else
				this.Articulo_PK = lxValOld
				goServicios.Errores.LevantarExcepcion( "No se puede cambiar este valor (Entidad: Presupuestos - Atributo: Articulo)" )
			endif
		endif

		dodefault( lxVal )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarSerieDragonContraArticuloDragonCloud( tcSerie as String, tcArticulo as String ) as Boolean
		local llRetorno as Boolean, lcCursor as String, lcSerie as String, lcSQL as String

		llRetorno = .f.
		lcSerie = alltrim( tcSerie )
		if this.EsArticuloDragonCloud( tcArticulo )
			lcCursor = 'C' + sys( 2015 )
			text to lcSQL textmerge noshow
				select result from [ZL].[funcValidarSerieDragonContraArticuloDragonCloud]( '<<lcSerie>>' )
			endtext
			goDatos.EjecutarSentencias( lcSql, "", "", lcCursor, this.DataSessionId )

			if ( used( lcCursor ) and reccount( lcCursor ) > 0 )
				llRetorno = &lcCursor..result
			endif
			use in select( lcCursor )
		else
			llRetorno = .t.
		endif

 		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsArticuloDragonCloud( tcArticulo as String ) as Boolean
		local llRetorno as Boolean, lcCursor as String, lcArt as String, lcSQL as String

		llRetorno = .f.
		lcCursor = 'C' + sys( 2015 )
		lcArt = upper( alltrim( tcArticulo ) )
		text to lcSQL textmerge noshow
			select a.Ccod
			from ZL.Isarticu a
				inner join ZL.Dmodart d on d.Codigo = a.Ccod
				inner join ZL.Ismodulo m on m.Ccod = d.Ccod and m.Ccod = '0079'
			where a.Ccod = '<<lcArt>>'
		endtext
		goDatos.EjecutarSentencias( lcSql, "", "", lcCursor, this.DataSessionId )

		if ( used( lcCursor ) and reccount( lcCursor ) > 0 )
			llRetorno = .t.
		endif
		use in select( lcCursor )

 		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarProductoDelArticulo( txVal as Variant) as Boolean
		local llRetorno as Boolean, lcCursor as String, lcArt as String, lcSQL as String

		if !empty( alltrim( txVal ) ) and alltrim( this.oColaboradorPresupuestos.TipoDePresupuesto ) = "ABON"
			this.HabilitarAtributoCantidad()

			llRetorno = .f.
			lcCursor = 'C' + sys( 2015 )
			lcArt = alltrim( txVal )
			text to lcSQL textmerge noshow
				select a.Ccod from ZL.Isarticu a inner join ZL.Tiparis t on a.Tipart = t.Ccod and t.TPRESU = 'ABON' where a.Ccod = '<<lcArt>>'
			endtext
			goDatos.EjecutarSentencias( lcSql, "", "", lcCursor, this.DataSessionId )

			if ( used( lcCursor ) and reccount( lcCursor ) > 0 )
				llRetorno = .t.
			endif
			use in select( lcCursor )
		else
			llRetorno = .t.
		endif

 		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HabilitarAtributoCantidad() as Void
		this.lHabilitarCantidad = !( alltrim( this.Articulo.ProductoZoologic_pk ) = "0001" or alltrim( this.Articulo.ProductoZoologic_pk ) = "0006" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorSerie( toObjeto ) as Void
		local loFiltro as String
		text to loFiltro textmerge noshow pretext 11
			NroSerie in ( select distinct i.Nroserie from ZL.Itemserv i where (i.Febavig = '19000101' or i.Febavig >= convert(char(10), getdate(), 112)) and i.Crass = '<<alltrim(this.oColaboradorPresupuestos.RazonSocial)>>' )
		endtext
		toObjeto.Filtro = loFiltro
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Serie_PK_Assign( txVal as variant ) as void
		local lxValOld as Variant, lxVal as Variant, loSugerido as Object

		with this
			lxValOld = .Serie_PK
			lxVal = txVal
			lxVal = iif( len( lxVal ) < 7, padr( lxVal, 7 ), lxVal )
			.Serie_PK = lxVal

			if .Validar_Serie( lxVal, lxValOld )
				if empty( txVal ) or .ValidarSerieDeLaRazonSocial( txVal )
					if .ValidarSerieConItemsVigentes( txVal )
						.EventoAntesDeSetear( this, 'Serie_Pk', lxValOld, lxVal )
						.Setear_Serie( lxVal )
						.EventoDespuesDeSetear( this, 'Serie_Pk', lxValOld, lxVal )
						if lxValOld != lxVal
							if .PuedeEjecutarHaCambiado()
								.HaCambiado( 'Serie_Pk', this )
							endif
						endif
						if lxValOld != lxVal or empty( .Seriedetalle )
							.Seriedetalle = .SERIE.NOMBRE
						endif
						if !empty( alltrim( lxVal ) )
							.Puesto = alltrim( .SERIE.NOMBRE )
						endif
					else
						.Serie_PK = lxValOld
						goServicios.Errores.levantarexcepcion('Debe ingresar un serie con ítems vigentes.')
					endif
				else
					.Serie_PK = lxValOld
					goServicios.Errores.LevantarExcepcionTexto( "El número de serie ingresado no pertenece a la razón social." )
				endif
			endif
		endwith

		dodefault( lxVal )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarSerieDeLaRazonSocial( txVal as Variant) as Boolean
		local lcCursor as String, lcCliente as String, lcSerie as String, lcSQL as String, llRetorno as Boolean

		llRetorno = .f.
		lcCursor = 'C' + sys( 2015 )
		lcSerie = alltrim( txVal )

		text to lcSQL textmerge noshow
			select distinct i.Nroserie
			from ZL.Itemserv i
			where i.Nroserie = '<<lcSerie>>' and i.Crass = '<<alltrim(this.oColaboradorPresupuestos.RazonSocial)>>'
		endtext

		goDatos.EjecutarSentencias( lcSql, "", "", lcCursor, this.DataSessionId )

		if ( used( lcCursor ) and reccount( lcCursor ) > 0 )
			llRetorno = .t.
		endif
		use in select( lcCursor )

 		return llRetorno
	endfunc
  
  	*-----------------------------------------------------------------------------------------
	protected function ValidarSerieConItemsVigentes( txVal as Variant) as Boolean
		local lcCursor as String, lcSerie as String, lcSQL as String, llRetorno as Boolean

		if empty( txVal ) 
			llRetorno = .t.
		else	

			llRetorno = .f.
			lcCursor = 'C' + sys( 2015 )
			lcSerie = alltrim( txVal )

			text to lcSQL textmerge noshow
				select distinct i.Ccod
				from ZL.Itemserv i
				where i.Ccod in( select ccod from  [ZL].[funcItemsVigentes]())  and i.Nroserie = '<<lcSerie>>' and i.Crass = '<<alltrim(this.oColaboradorPresupuestos.RazonSocial)>>'
			endtext

			goDatos.EjecutarSentencias( lcSql, "", "", lcCursor, this.DataSessionId )

			if ( used( lcCursor ) and reccount( lcCursor ) > 0 ) or THIS.SerieCargadoEnPRESUPUESTOSFacturadetalle( lcSerie )
				llRetorno = .t.
			else 
				this.EventoConfirmaSerieSinItemsVigentes() 
				llRetorno = this.lConfirmaSerieSinItemsVigentes
				this.lConfirmaSerieSinItemsVigentes = .f.
			endif
			use in select( lcCursor )
		endif 
	
		return llRetorno 

	endfunc
  

  	*-----------------------------------------------------------------------------------------
	protected function ValidarSiElSerieNoTieneItemActivoyEsProductoLinceQueTengaClasificacion39( tcArticulo as String ) as Boolean
		local lcCursor as String, lcSQL as String, llRetorno as Boolean

		llRetorno = .f.
		lcCursor = 'C' + sys( 2015 )

		text to lcSQL textmerge noshow
			select distinct a.Product, dc.Cmpclasif as Clasificacion, ItemServ.Ccod
			from ZL.ItemServ
				inner join [ZL].[funcItemsVigentes]() ItemVig on ItemVig.Ccod = ItemServ.Ccod
					and ItemServ.Nroserie = '<<alltrim(this.Serie_pk)>>'
					and ItemServ.Crass = '<<alltrim(this.oColaboradorPresupuestos.RazonSocial)>>'
				inner join ZL.Isarticu a on a.Ccod = ItemServ.CodArt and a.Product = '0001'
				inner join ZL.Dclaart dc on dc.CodCla = ItemServ.CodArt
		endtext

		goDatos.EjecutarSQL( lcSql, lcCursor, this.DataSessionId )

		if ( used( lcCursor )  )
			if  reccount( lcCursor ) = 0  && No es Lince
				llRetorno = .t.
			else
				select (lcCursor)
				locate for Clasificacion = '39'
				if found()
					llRetorno = .t.
				else
					llRetorno = THIS.VerificarPRESUPUESTOSFacturadetalleTengaUnSerieSiEsLinceConClasificacion39()
				endif	
			endif	
		endif
		
		use in select( lcCursor )

		return llRetorno 
	endfunc  
    
	*-----------------------------------------------------------------------------------------
	function VerificarPRESUPUESTOSFacturadetalleTengaUnSerieSiEsLinceConClasificacion39() as boolean
		local llRetorno as Boolean, loItem as Object 
		llRetorno = .f.
		for each loItem in this.oDetalle
			if ! empty( alltrim( loItem.Articulo_Pk ) ) and loItem.Serie_pk = this.Serie_pk
				llRetorno = .t.
				exit	
			endif 
		endfor			

		return llRetorno
	endfunc 

   	*-----------------------------------------------------------------------------------------
	function EventoConfirmaSerieSinItemsVigentes() as Void
		
	endfunc 

   	*-----------------------------------------------------------------------------------------
	function SerieCargadoEnPRESUPUESTOSFacturadetalle( tcSerie as String ) as boolean 
		local llRetorno as Boolean, loItem as Object 
		llRetorno = .f.
		for each loItem in this.oDetalle
			if alltrim( loItem.Serie_Pk ) = tcSerie 
				llRetorno = .t.
				exit	
			endif 
		endfor			
		
		return llRetorno
	endfunc 
  
   	*-----------------------------------------------------------------------------------------
	function ObtenerFiltroTipoDePresupuesto() as String
		local lcRetorno as string, lcTag as String, lcWhere  as String, loItem as Object  
		lcRetorno = '1=1'
		lcTag = alltrim(this.oColaboradorPresupuestos.TipoDePresupuesto)
		lcWhere = "T.TPresu='" + lcTag + "'"  
	
		if lcTag = "HARD"  
			for each loItem in this.oDetalle
				if !empty( loItem.Articulo_Pk ) 
					if this.ObtenerMonedaSiEsDeHARD( loItem.Articulo_Pk ) = 'DOLARES'
						lcWhere = lcWhere + " and A.enDolar=1"
					else
						lcWhere = lcWhere + " and A.enDolar=0"	
					endif
					exit	
				endif 
			endfor	
		endif 	
		lcRetorno = ;
			"Articulo in ( select A.Ccod from zl.ISARTICU A join zl.TIPARIS T on T.Ccod = A.tipart "+;
			" where " + lcWhere + ")"
						
		return lcRetorno
	endfunc 
 
  	*-----------------------------------------------------------------------------------------
	function ObtenerMonedaSiEsDeHARD( tcArticulo as String ) as string 
		return this.oColaboradorPresupuestos.ObtenerMonedaSiEsDeHARD( tcArticulo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarDetalle( toDetalle as Object ) as Void
		this.oDetalle = toDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoComponentePrecio( tcAtributo as String, toItem as object ) as Void
		local loError as Exception, loEx as Exception

		with this
			try
				if upper( tcAtributo ) == "PRECIO" or upper( tcAtributo ) == "PREXCANT"
					.PrecioDeLista = .Precio
				else
					.lCargando = .t.
					dodefault( tcAtributo, toItem )
					.oCompPrecios.ObtenerPrecio( toItem, .oListaDePrecios.Codigo, tcAtributo )
					.Precio = .PrecioDeLista
				endif
				.ActualizarMonto()
			catch to loError
				loEx = newobject( "ZooException", "ZooException.prg" )
				with loEx
					.Grabar( loError )
					.Throw()
				endwith
			finally
				.lCargando = .f.
			endTry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarMonto() as Void
		with this
			.Monto = ( .Cantidad * .PrecioDeLista ) - .Descuento &&- ( ( .Cantidad * .PrecioDeLista ) * ( .Porcentaje / 100 ) )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarListaDePrecios( toListaDePrecios as Object ) as Void
		dodefault( toListaDePrecios )
		this.oListaDePrecios = toListaDePrecios
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarColaboradorPresupuestos( toColaboradorPresupuestos as Object ) as Void
		this.oColaboradorPresupuestos = toColaboradorPresupuestos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPresupuesto() as Void
		this.oColaboradorPresupuestos.ValidarArticulo( this )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCodigoDescuento() as Void
		this.oColaboradorPresupuestos.ValidarDescuento( this )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Descuento_Assign( txVal as variant ) as void
	
		Local lxValOld As Variant
		lxValOld = this.Descuento
		local lxVal as Variant
		lxVal = txVal

		if This.CargaManual()
			if this.Validar_Descuento( lxVal )
				this.ValidarDominio_Numericononegativo( lxVal )
				this.EventoAntesDeSetear( This, 'Descuento', lxValOld, lxVal  )
				this.Setear_Descuento( lxVal )
				this.EventoDespuesDeSetear( This, 'Descuento', lxValOld, lxVal  )
			 	This.Descuento_DespuesDeAsignar()
				This.RecalcularPorcentajeSiTieneCodigoDeDescuento() 
				If This.PuedeEjecutarCambioSumarizado()
					this.CambioSumarizado()
				EndIf
				If lxValOld != lxVal
					If This.PuedeEjecutarHaCambiado()
						this.HaCambiado( 'Descuento', This )
					Endif
				EndIf
			EndIf
		Else
			This.Setear_Descuento( lxVal ) 
		EndIf
		dodefault( lxVal )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarPorcentajeDescuento() as Void
		if !empty( this.coddesc_Pk ) and  (this.Descuento / ( this.Cantidad * this.PrecioDeLista )  * 100 ) > this.coddesc.Porcentaje 
			goServicios.Errores.LevantarExcepcionTexto( 'No puede superar el porcentaje de descuento autorizado.', 9001 )
		endif 
		if this.Porcentaje > 100
			goServicios.Errores.LevantarExcepcionTexto( 'El descuento no puede superar al monto.', 9001 )
		endif 		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarMontoDescuento() as Void
		with this
			.Descuento = ( .Cantidad * .PrecioDeLista ) * .Porcentaje / 100
			.ActualizarMonto()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarPorcentajeDescuento() as Void
		with this
			if ( .Cantidad * .PrecioDeLista ) = 0
				.Porcentaje = 0
			else
				.Porcentaje = .Descuento / ( .Cantidad * .PrecioDeLista ) * 100
			endif
			.ActualizarMonto()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularPorcentajeSiTieneCodigoDeDescuento() as Void
		with this
			if !empty(alltrim(.coddesc_Pk)) &&and this.Descuento <> 0  
				if ( .Cantidad * .PrecioDeLista ) = 0
					.Porcentaje = 0
				else
					.Porcentaje = .Descuento / ( .Cantidad * .PrecioDeLista ) * 100
				endif
			endif
		endwith 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarCodigoDeDescuentoDescripcionesExtras() as Void
		with this
			.CodigoDeDescuentoDescripcionesExtras = this.CodDesc.ObtenerCodigoDeDescuentoDescripcionesExtras()
		endwith
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorNormalizadorNombres_Access() as variant
		if !this.ldestroy and ( vartype( this.oColaboradorNormalizadorNombres ) != 'O' or isnull( this.oColaboradorNormalizadorNombres ) )
			this.oColaboradorNormalizadorNombres = newobject( "ColaboradorNormalizadorNombres", "ColaboradorNormalizadorNombres.PRG" )
		endif
		return this.oColaboradorNormalizadorNombres
	endfunc

	*-----------------------------------------------------------------------------------------
	function Normalizar( tctexto as String ) as Void
		local lret as String 
		if ! THIS.LCARGANDO and this.EsNuevo() 
			lret = this.oColaboradorNormalizadorNombres.Procesar( tctexto )
		else
			lret = tctexto
		endif 
		return lret 
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Puesto( txVal as variant ) as void
		dodefault( txVal )
		this.Puesto = this.Normalizar( txVal )
	endfunc	
	
enddefine
