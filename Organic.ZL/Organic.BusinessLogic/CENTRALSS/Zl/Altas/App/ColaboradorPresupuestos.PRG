define class ColaboradorPresupuestos As zoosession Of zoosession.prg

	cUsuarioLogueado = ''
	TipoDePresupuesto = ''
	Cliente = ''
	RazonSocial = ''
	oDetalle = null
	
	*-----------------------------------------------------------------------------------------
	function ValidarArticulo( toItem as Object ) as Void
		if !empty( alltrim( toItem.Articulo_Pk ) )
			This.ValidarEspecificacionTipoDePresupuesto( toItem )
			This.Validar_ArticulosNoEsteDesactivado( toItem.Articulo_Pk )
			This.Validar_ArticulosParaPresupuestosPorEjecutivo( toItem.Articulo_Pk )
			This.ValidarTipoDePresupuesto_Articulo( toItem.Articulo_Pk )
		endif 	
	endfunc 
 	
 	*-----------------------------------------------------------------------------------------
	protected function ValidarEspecificacionTipoDePresupuesto( toItem as Object ) as Void
		if  empty( alltrim( this.TipoDePresupuesto ) )
			goServicios.Errores.LevantarExcepcionTexto( 'Debe especificar el tipo de presupuesto.', 9001 )
		endif 	
	endfunc 
 	
 	*-----------------------------------------------------------------------------------------
	protected function Validar_ArticulosNoEsteDesactivado( tcVal as String ) as Void
		local lcCursor as String, lcSQL as String
		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			select desacti
				from ZL.ISARTICU 
			 	where ccod = '<<alltrim( tcVal )>>'
		endtext 
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, this.DataSessionId )
		if used( lcCursor ) and reccount( lcCursor ) > 0 and !&lcCursor..desacti 
		else 
			goServicios.Errores.LevantarExcepcionTexto( 'El código de Artículo ' + alltrim( transform( tcVal ) ) + ' no puede ser utilizado por estar desactivado.', 9001 )
		endif
		use in select( lcCursor )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function Validar_ArticulosParaPresupuestosPorEjecutivo( txVal ) as void
		local lcCursor as String, lcSQL as String
		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			select Articulo 
			from ZL.func_COM_ArticulosParaPresupuestosPorEjecutivo('<<this.cUsuarioLogueado>>')
		 	where Articulo = '<<alltrim( txVal )>>'
		endtext 
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, this.DataSessionId )
		if used( lcCursor ) and reccount( lcCursor ) > 0
		else
			goServicios.Errores.LevantarExcepcionTexto( 'El código de Artículo ' + alltrim( transform( txVal ) ) + ' no puede ser utilizado para este item.', 9001 )	
		endif
		use in select( lcCursor )

	endfunc 

 	*-----------------------------------------------------------------------------------------
	protected function ValidarTipoDePresupuesto_Articulo( tcVal ) as Boolean
		local loItem as Object, lRetorno as Boolean, lcSQL as String, lcCursor as String, lcMonedaPresup as String 
		lRetorno = .T.
		lcCursor = 'C' + sys( 2015 )
		lcMonedaPresup = ''
		text to lcSQL textmerge noshow
			select
				TIPARIS.TPRESU as Tipo ,
				case enDolar when 1 then 'DOLARES' else 'PESOS' end as Moneda
			from zl.ISARTICU
			join zl.TIPARIS on TIPARIS.Ccod = ISARTICU.Tipart 
			where ISARTICU.Ccod = '<<alltrim(tcVal)>>' 
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )
		if used( lcCursor ) and reccount( lcCursor ) > 0
			if alltrim( this.TipoDePresupuesto ) = alltrim( &lcCursor..Tipo )
				if alltrim( this.TipoDePresupuesto ) = 'HARD'
					for each loItem in this.oDetalle
						if !empty( loItem.Articulo_Pk ) 
							lcMonedaPresup = this.ObtenerMonedaSiEsDeHARD( loItem.Articulo_Pk )
							exit	
						endif 
					endfor	
					if !empty( lcMonedaPresup) and  alltrim( lcMonedaPresup ) <> alltrim( &lcCursor..Moneda )
						lRetorno = .F. 
						goServicios.Errores.LevantarExcepcionTexto( 'El Artículo ' + alltrim( transform( tcVal ) ) + ' es de un tipo de moneda diferente al presupuesto.', 9001 )	
					endif
				endif 			
			else
				lRetorno = .F. 
				goServicios.Errores.LevantarExcepcionTexto( 'El Artículo ' + alltrim( transform( tcVal ) ) + ' es para un tipo de presupuesto diferente.', 9001 )	
			endif 
		endif
		use in select( lcCursor )			
		return lRetorno 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDescuento( toItem as Object ) as Void
		local lcCursor as String, lcSQL as String

		if ! empty( toItem.CodDesc_Pk )
			lcCursor = "C" + sys( 2015 )
			text to lcSQL textmerge noshow
				select 
					case when ( ARTDES <= '<<alltrim( toItem.Articulo_pk )>>' and case when ARTHAS = '' then 'ZZZZZZZZZZZZZ' else ARTHAS end >= '<<alltrim( toItem.Articulo_pk )>>' ) 
						then 'OK' 
						else 'El artículo ' + '<<alltrim( toItem.Articulo_pk )>>' + ' no está autorizado a usar el código de descuento ' + '<<alltrim( toItem.CodDesc_Pk )>>'
					end as RangoArt ,
					case when ( FECDES <= dateadd(d, datediff(d, 0, getdate()), 0) and case when FECHAS = '' then '99991231' else FECHAS end >= dateadd(d, datediff(d, 0, getdate()), 0) ) 
						then 'OK' 
						else 'El código de descuento '  + '<<alltrim( toItem.CodDesc_Pk )>>' + ' no está vigente a la fecha' 
					end as RangoFecha,
					isnull(D.PORCDES, 0) as Porcentaje 
				from ZL.DESCPRESUP D
				where  CODIGO = '<<alltrim( toItem.CodDesc_Pk )>>' 
			endtext
			
			goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, this.DataSessionId )

			if used( lcCursor ) and reccount( lcCursor ) > 0
				if &lcCursor..RangoArt <> 'OK'
					goServicios.Errores.LevantarExcepcionTexto( alltrim( &lcCursor..RangoArt ), 9001 )
				endif 
				if &lcCursor..RangoFecha <> 'OK'
					goServicios.Errores.LevantarExcepcionTexto( alltrim( &lcCursor..RangoFecha ), 9001 )
				endif 				
				if round( (toItem.Descuento / ( toItem.Cantidad * toItem.PrecioDeLista ) * 100 ), 2 ) > &lcCursor..Porcentaje 
					goServicios.Errores.LevantarExcepcionTexto( 'No puede superar el porcentaje de descuento autorizado para el artículo ' + ;
						alltrim( toItem.Articulo_pk ) + ' con el código de descuento '  + alltrim( toItem.CodDesc_Pk ) +'.', 9001 )
				endif 
			else
				goServicios.Errores.LevantarExcepcionTexto( 'El código de descuento ' + alltrim( toItem.CodDesc_Pk ) + ' no existe.', 9001 )				
			endif
			use in select( lcCursor )
		endif 	
	endfunc	

 	*-----------------------------------------------------------------------------------------
	function ObtenerMonedaSiEsDeHARD( tcArticulo as String ) as string 
		local lcSQL as String, lcCursor as String, lRetorno as string
		lRetorno = ''
		if !empty( tcArticulo )
			lcCursor = 'C' + sys( 2015 )
			text to lcSQL textmerge noshow
				select
					case enDolar when 1 then 'DOLARES' else 'PESOS' end as Descripcion 
				from zl.ISARTICU
				where Ccod = '<<alltrim(tcArticulo)>>'		
			endtext
			goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )
			if used( lcCursor ) and reccount( lcCursor ) > 0
				lRetorno = &lcCursor..Descripcion
			endif
			use in select( lcCursor )
		endif 	
		return lRetorno	
	endfunc 
	
enddefine
