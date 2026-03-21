define class entColorYTalle_Preciodearticulo as Ent_Preciodearticulo of Ent_Preciodearticulo.prg

	#if .f.
		local this as entColorYTalle_Preciodearticulo of entColorYTalle_Preciodearticulo.prg
	#endif

	cAtributosCombinacion = "TimestampAlta,ListaDePrecio,Articulo,Color,Talle"
	lMantienePreciosCombAlImportar = .f.

	*-----------------------------------------------------------------------------------------
	function ReasignarPk_Con_CC() as Void
		This.Codigo =  padr( alltrim( str( this.TimestampAlta, 14 ) ), 14) + padr( This.ListaDePrecio_Pk, 6 ) + padr( This.Articulo_Pk, 15 ) + padr( This.Color_Pk, 6 )+ padr( This.Talle_PK, 5 )
	endfunc
	
	*--------------------------------------------------------------------------------------------------------	
	* Esto es para Optimizar el Ingreso de Precios a la tabla reduciendo los precios que ya existen según	
	* vigencia y que son iguales a lso que se intenta ingresar a través del de la sobrecarga del método	
	* EjecutarReglaDeNegocioPersonalizadaEnTablaTrabajo( toConexion )
	
	function oAD_Access() as variant
		if !this.ldestroy and ( !vartype( this.oAD ) = 'O' or isnull( this.oAD ) )
			this.oAD = this.crearobjeto( "entcolorytalle_PRECIODEARTICULOAD_SQLSERVER" )
			this.oAD.InyectarEntidad( this )
			this.oAD.Inicializar()
		endif
		return this.oAD
	endfunc
	
enddefine