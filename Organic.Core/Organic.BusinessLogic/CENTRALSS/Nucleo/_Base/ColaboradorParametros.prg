define class ColaboradorParametros as Session

	#IF .f.
		Local this as ColaboradorParametros of ColaboradorParametros.prg
	#ENDIF

	oParametros = null
	oLibrerias = null
	oAplicacion = null

	*--------------------------------------------------------------------------------------------------------
	function oParametros_Access() as variant

		if !vartype( this.oParametros ) = 'O' or isnull( this.oParametros )
			this.oParametros = goServicios.Parametros
		endif
		return this.oParametros
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oLibrerias_Access() as variant
		if !vartype( this.oLibrerias ) = 'O' or isnull( this.oLibrerias )
			this.oLibrerias = goServicios.Librerias
		endif
		return this.oLibrerias
	endfunc

	*-----------------------------------------------------------------------------------------
	function oAplicacion_Access() as variant
		if !vartype( this.oAplicacion ) = 'O' or isnull( this.oAplicacion )
			this.oAplicacion = _screen.zoo.app
		endif
		return this.oAplicacion

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerParametroDeBaseDeDatos( tcParametro as String , tcSucursalOrigen as String ) as Variant
		local lcSucursalActiva as String, lxValorParametro as Variant
		
		lxValorParametro = this.ObtenerValorParametro( tcParametro, tcSucursalOrigen )   
		return lxValorParametro
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaDB( tcSucursal as String ) as String
		local lcRetorno as String

		if goServicios.Datos.esNativa()
			lcRetorno = addbs(_screen.zoo.app.ObtenerRutaSucursal( tcSucursal ))+'DBF'
		else
			lcRetorno = ""
		endif

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablaParametros( tcSucursal as String ) as String
		local lcRetorno as String

		if goServicios.Datos.esNativa()
			lcRetorno = 'PARAMETROSSUCURSAL'
		else
			lcRetorno = "[" + _Screen.Zoo.App.NombreProducto + "_" + alltrim( tcSucursal ) + "].Parametros.Sucursal"
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablaCabeceraParametros( tcSucursal as String ) as String
		local lcRetorno as String

		lcRetorno = "[" + _Screen.Zoo.App.NombreProducto + "_ZOOLOGICMASTER].PARAMETROS.CABECERA"

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValorParametro( tcParametro as String, tcBaseDeDatos as String) as String
		local lcRetorno as String, lcCursor as String, lcRutaDB as String, lcTabla as String, lcTablaCabecera as String,;
			lcAlias as String
		
		*lcAlias = alias()		
		lcRetorno = ""
		lcCursor = sys( 2015 )
		lcRutaDB = this.ObtenerRutaDB( tcBaseDeDatos )
		lcTabla = this.ObtenerTablaParametros( tcBaseDeDatos )
		lcTablaCabecera = this.ObtenerTablaCabeceraParametros()

		if goServicios.Datos.esNativa()
			goServicios.Datos.EjecutarSentencias( "select valor from " + lcTabla + " where ltrim(rtrim(parametro))='"+upper(alltrim( tcParametro ))+"'", ;
												lcTabla, lcRutaDB, lcCursor, this.DataSessionId )
		else
			goServicios.Datos.EjecutarSentencias( "select d.valor, c.idUnico from " + lcTabla + " d inner join " + lcTablaCabecera + ;
						" c on d.idunico = c.idunico where ltrim( rtrim( upper( c.Nombre ) ) ) = '"+upper(alltrim( tcParametro ))+"'",;
						lcTabla+","+lcTablaCabecera, lcRutaDB, lcCursor, this.DataSessionId )

			if reccount( lcCursor ) = 0 or empty( &lcCursor..IdUnico )
				this.EjecutarConsultaConIdCabecera( lcTabla, lcRutaDB, lcTablaCabecera, tcParametro, lcCursor )
			endif
		endif
		
		select &lcCursor
		
		if !empty( &lcCursor..valor )
			lcRetorno= alltrim( &lcCursor..valor )
		endif
		use in (lcCursor)

		*select (lcAlias)
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarConsultaConIdCabecera( tcTabla as String, tcRutaDB as String, tcTablaCabecera as String, ;
																tcParametro as String, tcCursor as String) as Void

		goServicios.Datos.EjecutarSentencias( "select d.valor, d.idCabecera, c.IdUnico from " + tcTabla + " d inner join " + tcTablaCabecera + ;
			" c on d.idCabecera = c.id where ltrim( rtrim( upper( c.Nombre ) ) ) = '"+upper(alltrim( tcParametro ))+"'",;
			tcTabla+","+tcTablaCabecera, tcRutaDB, tcCursor, this.DataSessionId )					
		
		lcIdUnico = this.ObtenerIdUnico( tcParametro )
		if reccount( tcCursor ) > 0
			if empty( &tcCursor..IdUnico )
				goServicios.Datos.EjecutarSentencias( "Update " + tcTabla + ;
													" set IdUnico = '" + lcIdUnico + "' " + ;
													" where idCabecera = " + transform( &tcCursor..idCabecera ), ;
													 tcTabla+","+tcTablaCabecera )
													 
				goServicios.Datos.EjecutarSentencias( "Update " + tcTablaCabecera + ;
													" set IdUnico = '" + lcIdUnico + "' " + ;
													" where id = " + transform( &tcCursor..idCabecera ), ;
													 tcTabla+","+tcTablaCabecera )
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdUnico( tcParametro as String ) as String
		local lcRetorno as string
		
		lcRetorno = ""
		
		if alltrim( upper( tcParametro ) ) == "SUCURSAL"
			lcRetorno = "1C2D17A2C1F31514C5C1A25410222710684731"
		endif

		return lcRetorno
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function SetearParametrosAOtraBaseDeDatos( tcParametro as String , tcBaseDeDatosDestino as String, lxValor as Variant ) as Void
		local lcComando as String , lcSucursalActiva as String 
		
		lcSucursalActiva = This.oAplicacion.cSucursalActiva
		try
			This.oParametros.oDatos.ResetearBuffers()
			This.oAplicacion.cSucursalActiva = tcBaseDeDatosDestino
			lcComando = tcParametro + " = " + This.oLibrerias.ValoraString( lxValor )
			&lcComando
			This.oDatos.Sucursal.ResetearBuffers()
		catch to loError	
		finally
			This.oAplicacion.cSucursalActiva = lcSucursalActiva
		endtry
		
	endfunc 

enddefine

