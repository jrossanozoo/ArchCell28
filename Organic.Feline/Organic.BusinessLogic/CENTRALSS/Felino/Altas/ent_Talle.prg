define class ent_talle as din_entidadTalle of din_entidadTalle.prg

	#If .F.
		Local This as ent_talle of ent_talle.prg
	#Endif

	*-------------------------------------------------------------------------------------------------
	Function Eliminar() As void
		local llEliminar as Boolean
	
		loKits = this.ObtenerKitEnQueParticipa( this.Codigo )
		if loKits.Count > 0
			lcKitsSeparadosPorComa = ""
			for each lcKit in loKits
				lcKitsSeparadosPorComa = lcKitsSeparadosPorComa + "'" + lcKit + "', " 
			endfor
			lcKitsSeparadosPorComa = Substr( lcKitsSeparadosPorComa, 1, Len( lcKitsSeparadosPorComa ) - 2 )
			goservicios.Errores.LevantarExcepcion( "No se puede eliminar. Este " + lower( this.cDescripcionSingular ) + " es participante en el/los kit/s " + lcKitsSeparadosPorComa )
		else
			dodefault()			
		endif
						
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerKitEnQueParticipa( tcKit as String ) as Object
		local lcCursor as String, loRetorno as Object
		
		lcCursor = sys( 2015 )
		loRetorno = _screen.zoo.crearObjeto( "ZooColeccion" )
		lcSentencia = "select distinct CODIGO from [" + this.ObtenerNombreBase() + "].Zoologic.KitPartDet as k where k.CODIGO != '' and IPTALLE in ('" + this.Codigo + "')"
		goServicios.Datos.EjecutarSentencias( lcSentencia, "KitPartDet", "", lcCursor, this.DataSessionId )
		
		select * from &lcCursor order by Codigo into cursor &lcCursor		
		select &lcCursor
		scan
			loRetorno.Agregar( upper( rtrim( Codigo ) ) )
		endscan	
		use in select ( lcCursor )	
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreBase() as String
		local lcProducto as String, lcBaseDeDatos as String		
		lcProducto = _screen.zoo.app.nombreProducto
		lcBaseDeDatos = _screen.zoo.app.cSucursalActiva	
		return lcProducto + "_" + lcBaseDeDatos
	endfunc
	
enddefine