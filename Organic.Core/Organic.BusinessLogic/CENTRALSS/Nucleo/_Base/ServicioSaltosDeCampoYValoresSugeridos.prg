define class ServicioSaltosDeCampoYValoresSugeridos as Servicio Of Servicio.prg

	protected oSaltosDeCampoYValoresSugeridosDeEntidades as zoocoleccion OF zoocoleccion.prg
	
	oSaltosDeCampoYValoresSugeridosDeEntidades = null
	
	#IF .f.
		local this as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function oSaltosDeCampoYValoresSugeridosDeEntidades_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oSaltosDeCampoYValoresSugeridosDeEntidades ) # "O"
			this.oSaltosDeCampoYValoresSugeridosDeEntidades = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oSaltosDeCampoYValoresSugeridosDeEntidades
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeSaltarElCampo( tcEntidad as String, tcDetalle as String, tcAtributo as String ) as Boolean
		local llDebeSaltarElCampo as Boolean, loSaltoDeCampoYValorSugerido as Object
		loSaltoDeCampoYValorSugerido = this.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( tcEntidad, tcDetalle, tcAtributo )
		if !isnull( loSaltoDeCampoYValorSugerido )
			llDebeSaltarElCampo = loSaltoDeCampoYValorSugerido.Salta or loSaltoDeCampoYValorSugerido.Ocultar
		endif
		return llDebeSaltarElCampo
	endfunc

	*-----------------------------------------------------------------------------------------
&&	function DebeObligarCargarElCampo( tcEntidad as String, tcDetalle as String, tcAtributo as String ) as Boolean
&&		local llRetorno as Boolean, loSaltoDeCampoYValorSugerido as Object
&&		
&&		loSaltoDeCampoYValorSugerido = this.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( tcEntidad, tcDetalle, tcAtributo )
&&		llRetorno = .f.
&&		if !isnull( loSaltoDeCampoYValorSugerido )
&&			llRetorno = loSaltoDeCampoYValorSugerido.Obliga
&&		endif
&&		
&&		return llRetorno
&&	endfunc 
	
	*-----------------------------------------------------------------------------------------
&&	function DebeEstarVisibleElCampo( tcEntidad as String, tcDetalle as String, tcAtributo as String ) as Boolean
&&		local llRetorno as Boolean, loSaltoDeCampoYValorSugerido as Object
&&		
&&		loSaltoDeCampoYValorSugerido = this.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( tcEntidad, tcDetalle, tcAtributo )
&&		llRetorno = .f.
&&		if !isnull( loSaltoDeCampoYValorSugerido )
&&			llRetorno = loSaltoDeCampoYValorSugerido.Visible
&&		endif
&&		
&&		return llRetorno
&&	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionAtributosObligatorios( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local llRetorno as Boolean, loCol as zoocoleccion OF zoocoleccion.prg, loSaltosDeCampoYValoresSugeridosDeEntidad as Object, ;
			loItem as ItemAtributo of ServicioSaltosDeCampoYValoresSugeridos.prg
		
		loCol = _screen.zoo.CrearObjeto( "ZooColeccion" )
		
		try
			loSaltosDeCampoYValoresSugeridosDeEntidad = this.ObtenerSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad )
		catch
			loSaltosDeCampoYValoresSugeridosDeEntidad = null
		endtry
		
		if !isnull( loSaltosDeCampoYValoresSugeridosDeEntidad )
			for each obj as Object in loSaltosDeCampoYValoresSugeridosDeEntidad FoxObject
				if obj.Obliga 
				    loItem = _screen.zoo.CrearObjeto( "ItemAtributo", this.class + ".prg" )
					loItem.cAtributo = obj.Atributo
					loItem.cEtiqueta = obj.AtrDesc
					loItem.cDetalle = obj.Detalle
					loItem.lOmiteObligatorioEnPack = obj.NoobligaAP
					loCol.Agregar( loItem )
				endif
			next
		endif
				
		return loCol
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionAtributosNoVisibles( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local llRetorno as Boolean, loCol as zoocoleccion OF zoocoleccion.prg, loSaltosDeCampoYValoresSugeridosDeEntidad as Object, ;
			loItem as ItemAtributo of ServicioSaltosDeCampoYValoresSugeridos.prg, lcClave as string

		loCol = goServicios.PersonalizacionDeEntidades.ObtenerColeccionAtributosInvisibles( tcEntidad )

		try
			loSaltosDeCampoYValoresSugeridosDeEntidad = this.ObtenerSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad )
		catch
			loSaltosDeCampoYValoresSugeridosDeEntidad = null
		endtry
		
		if !isnull( loSaltosDeCampoYValoresSugeridosDeEntidad )
			for each obj as Object in loSaltosDeCampoYValoresSugeridosDeEntidad FoxObject
				if obj.Ocultar
					loItem = _screen.zoo.CrearObjeto( "ItemAtributo", this.class + ".prg" )
					loItem.cAtributo = obj.Atributo
					loItem.cEtiqueta = obj.AtrDesc
					loItem.cDetalle = obj.Detalle
					lcClave = this.ObtenerStringParaClave( obj.Detalle ) + this.ObtenerStringParaClave( obj.Atributo )
					if loCol.Buscar( lcClave )
						loCol.Quitar( lcClave )
					endif
					loCol.Agregar( loItem, lcClave )			
				endif
			next
		endif
				
		return loCol
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorSugerido( tcEntidad as String, tcDetalle as String, tcAtributo as String ) as String
		local lcValorSugerido as String
		lcValorSugerido = null
		loSaltoDeCampoYValorSugerido = this.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( tcEntidad, tcDetalle, tcAtributo )
		if !isnull( loSaltoDeCampoYValorSugerido ) and !loSaltoDeCampoYValorSugerido.UsaValorSugeridoDeFramework
			lcValorSugerido = alltrim( loSaltoDeCampoYValorSugerido.ValorSugerido )
		endif
		return lcValorSugerido
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorSugeridoDeUnaEntidadDetalle( tcEntidad as String, tcDetalle as String ) as Object
		local loSaltoDeCampoYValorSugerido as Object, loSaltosDeCampoYValoresSugeridosDeEntidad as zoocoleccion OF zoocoleccion.prg, lcDetalle as String, lcAtributo as String, ;
			loError as zooexception of zooexception.prg
		loSaltosDeCampoYValoresSugeridosDeEntidadYDetalle = _screen.zoo.crearobjeto( "ZooColeccion")
		if !empty(alltrim(_screen.zoo.app.csucursalactiva))	
			lcDetalle = this.ObtenerStringParaClave( tcDetalle )
			loSaltosDeCampoYValoresSugeridosDeEntidad = this.ObtenerSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad )
			
			for each loItemValSug in loSaltosDeCampoYValoresSugeridosDeEntidad 
				if upper( alltrim( loItemValSug.Detalle ) ) = upper( alltrim ( lcDetalle ) ) and ( alltrim( loItemValSug.ValorSugerido ) != "" or loItemValSug.UsaValorElementoAnterior )
					loSaltosDeCampoYValoresSugeridosDeEntidadYDetalle.agregar( loItemValSug , alltrim( loItemValSug.Atributo ) )
				endif
			endfor
		endif	
		return loSaltosDeCampoYValoresSugeridosDeEntidadYDetalle
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( tcEntidad as String, tcDetalle as String, tcAtributo as String ) as Object
		local loSaltoDeCampoYValorSugerido as Object, loSaltosDeCampoYValoresSugeridosDeEntidad as zoocoleccion OF zoocoleccion.prg, lcDetalle as String, lcAtributo as String, ;
			loError as zooexception of zooexception.prg
		lcDetalle = this.ObtenerStringParaClave( tcDetalle )
		lcAtributo = this.ObtenerStringParaClave( tcAtributo )
		loSaltosDeCampoYValoresSugeridosDeEntidad = this.ObtenerSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad )
		try
			loSaltoDeCampoYValorSugerido = loSaltosDeCampoYValoresSugeridosDeEntidad.Item[ lcDetalle + lcAtributo ]
					
			if !empty( lcDetalle ) and loSaltoDeCampoYValorSugerido.UsaValorElementoAnterior
				loSaltoDeCampoYValorSugerido.ValorSugerido = "This.ElementoAnterior( '" + tcAtributo + "' )"
			endif
		catch to loError
			loSaltoDeCampoYValorSugerido = null
		endtry
		return loSaltoDeCampoYValorSugerido
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReiniciarSaltosDeCampoYValoresSugeridosDeTodasLasEntidades() as void
		this.oSaltosDeCampoYValoresSugeridosDeEntidades.Quitar( -1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ReiniciarSaltosDeCampoYValoresSugeridosDeEntidad( tcEntidad as String ) as void
		local lcEntidad as String, loError as zooexception of zooexception.prg
		lcEntidad = this.ObtenerStringParaClave( tcEntidad )
		try
			this.oSaltosDeCampoYValoresSugeridosDeEntidades.Quitar( lcEntidad )
		catch to loError
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local loSaltosDeCampoYValoresSugeridosDeEntidad as zoocoleccion OF zoocoleccion.prg, loError as zooexception of zooexception.prg, lcEntidad as String, ;
		      loCol as Object, lcClave as String, loItem as Object
		      
		lcEntidad = this.ObtenerStringParaClave( tcEntidad )
		try
			loSaltosDeCampoYValoresSugeridosDeEntidad = this.oSaltosDeCampoYValoresSugeridosDeEntidades.Item[ lcEntidad ]
		catch to loError
			loSaltosDeCampoYValoresSugeridosDeEntidad = this.CargarSaltosDeCampoYValoresSugeridosDeUnaEntidad( lcEntidad )
		endtry
		
		loCol = goServicios.PersonalizacionDeEntidades.ObtenerColeccionAtributosInvisibles( tcEntidad )
		for each loItem in loCol
			loSaltoDeCampoYValorSugerido = _screen.zoo.CrearObjeto( "ItemComportamiento", this.class + ".prg" )
			
			with loSaltoDeCampoYValorSugerido					
				.Entidad = tcEntidad
				.Detalle = loItem.cDetalle
				.Atributo = loItem.cAtributo
				.Salta = .T.
				.ValorSugerido = ""
				.UsaValorSugeridoDeFramework = .f.
				.Mostrar = .F.
				.Ocultar = .T.
				.Obliga = .F.
				.AtrDesc = ""
				.UsaValorElementoAnterior = .F.
				.UsaEtiquetaDeFramework = .F.
				.PersonalizacionEtiqueta = ""
				.NoObligaAP = .f.
			endwith
			
			lcClave = this.ObtenerStringParaClave( loItem.cDetalle ) + this.ObtenerStringParaClave( loItem.cAtributo )			
			if loSaltosDeCampoYValoresSugeridosDeEntidad.Buscar( lcClave )						
				loSaltosDeCampoYValoresSugeridosDeEntidad.Quitar( lcClave )
			endif							
			loSaltosDeCampoYValoresSugeridosDeEntidad.Agregar( loSaltoDeCampoYValorSugerido, lcClave )
		endfor

		return loSaltosDeCampoYValoresSugeridosDeEntidad
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CargarSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local loSaltosDeCampoYValoresSugeridosDeEntidad as zoocoleccion OF zoocoleccion.prg, loError as Object ,;
		 lcCursorSaltosDeCampoYValoresSugeridos as String, loSaltoDeCampoYValorSugerido as Object

		loSaltosDeCampoYValoresSugeridosDeEntidad = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		try
			
			lcCursorSaltosDeCampoYValoresSugeridos = this.ObtenerCursorDeSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad )
			select ( lcCursorSaltosDeCampoYValoresSugeridos )
			scan all
				scatter name loSaltoDeCampoYValorSugerido
				
				lcClave = this.ObtenerStringParaClave( loSaltoDeCampoYValorSugerido.Detalle ) + this.ObtenerStringParaClave( loSaltoDeCampoYValorSugerido.Atributo )
				
				if !loSaltosDeCampoYValoresSugeridosDeEntidad.Buscar( lcClave )	
					loSaltosDeCampoYValoresSugeridosDeEntidad.Agregar( loSaltoDeCampoYValorSugerido, lcClave )
				endif
			endscan
			
			if loSaltosDeCampoYValoresSugeridosDeEntidad.Count > 0
				this.oSaltosDeCampoYValoresSugeridosDeEntidades.Agregar( loSaltosDeCampoYValoresSugeridosDeEntidad, this.ObtenerStringParaClave( tcEntidad ) )
			endif
			use in select( lcCursorSaltosDeCampoYValoresSugeridos )
		catch to loError
		endtry
		return loSaltosDeCampoYValoresSugeridosDeEntidad
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad as String ) as String
		local lcConsulta as String, lcTabla as String, lcCursor as String, lcEntidad as String
		lcTabla = "SaltoDeCampo"
		lcEntidad = this.ObtenerStringParaClave( tcEntidad )
		lcConsulta = "select Entidad, Detalle, Atributo, Salta, VSugerido as ValorSugerido, UsaValSis as UsaValorSugeridoDeFramework, " + ;
							"Mostrar, Ocultar, Obliga,NoObligaAP, AtrDesc, UsaVSAnt as UsaValorElementoAnterior, " + ;
							"usaetiq as UsaEtiquetaDeFramework, persetiq as PersonalizacionEtiqueta " + ;
					"from " + lcTabla + " where upper( alltrim( Entidad ) ) == '" + lcEntidad + "' and atributo != ''"
		lcCursor = sys( 2015 )
		goServicios.Datos.EjecutarSentencias( lcConsulta, lcTabla, "", lcCursor, this.DataSessionId )
		return lcCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringParaClave( tcClave as String ) as String
		return upper( alltrim( tcClave ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPersonalizacionDeEtiquetas( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local llRetorno as Boolean, loCol as zoocoleccion OF zoocoleccion.prg, ;
			loSaltosDeCampoYValoresSugeridosDeEntidad as Object, ;
			loItem as ItemAtributo of ServicioSaltosDeCampoYValoresSugeridos.prg, lcClave as String

		loCol = goServicios.PersonalizacionDeEntidades.ObtenerColeccionComportamientoDeEtiquetasPersonalizadas( tcEntidad )
		
		try
			loSaltosDeCampoYValoresSugeridosDeEntidad = this.ObtenerSaltosDeCampoYValoresSugeridosDeUnaEntidad( tcEntidad )
		catch
			loSaltosDeCampoYValoresSugeridosDeEntidad = null
		endtry

		if !isnull( loSaltosDeCampoYValoresSugeridosDeEntidad )
			for each obj as Object in loSaltosDeCampoYValoresSugeridosDeEntidad FoxObject
				if !obj.UsaEtiquetaDeFramework or obj.Ocultar 					
					loItem = _screen.zoo.CrearObjeto( "ItemAtributo", this.class + ".prg" )
					loItem.cAtributo	= obj.Atributo
					loItem.cEtiqueta	= alltrim(obj.PersonalizacionEtiqueta)
					loItem.cDetalle		= obj.Detalle
					loItem.lOcultar = obj.Ocultar
					lcClave = upper( alltrim( tcEntidad ) + alltrim( loItem.cDetalle ) + alltrim( obj.Atributo ) )
					if loCol.Buscar( lcClave )
						loCol.Quitar( lcClave )
					endif
					loCol.Agregar( loItem, lcClave )					
				endif
			next
		endif
		return loCol
	endfunc

enddefine

define class ItemAtributo as Custom
	cAtributo=""
	cEtiqueta=""
	cDetalle = ""
	lOcultar = .F.
	lOmiteObligatorioEnPack = .F.
enddefine

define class ItemComportamiento as Custom
	Entidad = ""
	Detalle = ""
	Atributo = ""
	Salta = .f.
	ValorSugerido = ""
	UsaValorSugeridoDeFramework = .f.
	Mostrar = .f.
	Ocultar = .f.
	Obliga = .f.
	NoObligaAP = .f.
	AtrDesc = ""
	UsaValorElementoAnterior = .f.
	UsaEtiquetaDeFramework = .f.
	PersonalizacionEtiqueta = ""
enddefine