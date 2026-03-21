define class ManagerAccionesAutomaticas as ZooSession of ZooSession.prg
	
	#IF .f.
		Local this as ManagerAccionesAutomaticas of ManagerAccionesAutomaticas.prg
	#ENDIF	

	protected oEntidadesConAccionesAutomaticas, oEntidadesConAccionesAutomaticas_Detalle
	
	oEntidadAccionesAutomaticas = null
	oEntidadesConAccionesAutomaticas = null
	oEntidadesConAccionesAutomaticas_Detalle = null
	cNombreDeEntidad = "ACCIONESAUTOMATICAS"
	
	*-----------------------------------------------------------------------------------------
	function init
		dodefault()
		this.oEntidadesConAccionesAutomaticas_Detalle = _Screen.zoo.CrearObjeto( "ZooColeccion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oEntidadesConAccionesAutomaticas_Access() as Variant
		if !this.lDestroy and ( !vartype( this.oEntidadesConAccionesAutomaticas ) = 'O' or isnull( this.oEntidadesConAccionesAutomaticas ) )
			this.oEntidadesConAccionesAutomaticas = _Screen.zoo.CrearObjeto( "ZooColeccion" )
			this.CargarColeccionDeEntidadesConAccionesAutomaticas()
		endif
		return this.oEntidadesConAccionesAutomaticas
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oEntidadAccionesAutomaticas_Access() as Variant
		if !this.lDestroy and ( !vartype( this.oEntidadAccionesAutomaticas ) = 'O' or isnull( this.oEntidadAccionesAutomaticas ) ) 
			if this.PuedeInstanciarLaEntidadAccionesAutomaticas()
				this.oEntidadAccionesAutomaticas = _Screen.zoo.InstanciarEntidad( this.cNombreDeEntidad )
				this.oEntidadAccionesAutomaticas.Inicializar()
			endif
		endif
		return this.oEntidadAccionesAutomaticas
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarColecciones() as Void
		if vartype( this.oEntidadesConAccionesAutomaticas ) == "O"
			this.oEntidadesConAccionesAutomaticas.Remove(-1)
		else
			this.oEntidadesConAccionesAutomaticas = _Screen.zoo.CrearObjeto( "ZooColeccion" ) 
		endif

		if vartype( this.oEntidadesConAccionesAutomaticas_Detalle ) == "O"
			this.oEntidadesConAccionesAutomaticas_Detalle = _Screen.zoo.CrearObjeto( "ZooColeccion" )		
		else
			this.oEntidadesConAccionesAutomaticas_Detalle.Remove(-1)
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarColeccionDeEntidadesConAccionesAutomaticas() as Void
		this.LimpiarColecciones()
		this.CargarColeccionDeEntidadesConAccionesAutomaticas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarColeccionDeEntidadesConAccionesAutomaticas() as Void	
		local lcXml as String, lcCursor as String, loItem as Custom
		if this.PuedeInstanciarLaEntidadAccionesAutomaticas()
			lcXml = this.oEntidadAccionesAutomaticas.oAd.ObtenerDatosEntidad( "Codigo, Entidad, NuevoDespuesDeGrabar, ValorDeCierre, RestringirPicking" )
			lcCursor = sys( 2015 )
			this.XmlaCursor( lcXml, lcCursor )	
			select ( lcCursor )
			scan for !empty( codigo  )  and !empty( entidad )
				loItem = newobject( "Custom" )
				loItem.AddProperty( "Entidad", upper( alltrim( Entidad ) ) )
				loItem.AddProperty( "PK", alltrim( Codigo ) )
				loItem.AddProperty( "Nuevodespuesdegrabar", NuevoDespuesDeGrabar )
				loItem.AddProperty( "ValorDeCierre", ValorDeCierre )
				loItem.AddProperty( "RestringirPicking", RestringirPicking )
				this.oEntidadesConAccionesAutomaticas.Agregar( loItem, upper( alltrim( Entidad ) ) )
			endscan
			use in select( lcCursor )

			if this.oEntidadesConAccionesAutomaticas.Count > 0
				lcXml = this.oEntidadAccionesAutomaticas.oAd.ObtenerDatosDetalleAccionesDetalle( "", "orden>0", "codigo,orden" )
				lcCursor = sys( 2015 )
				this.XmlaCursor( lcXml, lcCursor )	
				select ( lcCursor )
				scan for !empty( Codigo )
					loItem = newobject( "Custom" )
					loItem.AddProperty( "Codigo", alltrim( Codigo ) )
					loItem.AddProperty( "Metodo", alltrim( Metodo ) )
					loItem.AddProperty( "Expresion", alltrim( Expresion ) )
					loItem.AddProperty( "Orden", Orden )
					loItem.AddProperty( "Accion", alltrim( Accion ) )
					loItem.AddProperty( "Condicion", "" )
					loItem.AddProperty( "EjecutarEnOtroHilo", iif(_vfp.StartMode= 4, .T., .F. ))
					if "ANTESDEGRABAR" == upper( alltrim( Metodo ) ) or "ANTESDEANULAR" == upper( alltrim( Metodo ) )
						loItem.Condicion = "!.EsNuevo()"
						loItem.EjecutarEnOtroHilo = .F.
					endif
					this.oEntidadesConAccionesAutomaticas_Detalle.Agregar( loItem )
				endscan
				use in select( lcCursor )
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LaEntidadTieneAccionesAutomaticas( tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if vartype( this.oEntidadesConAccionesAutomaticas ) == "O"
			llRetorno = this.oEntidadesConAccionesAutomaticas.Buscar( upper( alltrim( tcEntidad ) ) )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarAccionesAutomaticasSegunEntidadMetodo( toEntidad as entidad OF entidad.prg, tcMetodo as String ) as Void
		local i as Integer, lcMetodo as String, lcEntidad as String, lcCodigo as String, lcAccion as String, loEx as ZooException of ZooException.prg

		try
			lcAccion = ""
			lcMetodo = upper( alltrim( tcMetodo ) )
			lcEntidad = upper( alltrim( toEntidad.ObtenerNombre() ) ) 
			try
				lcCodigo = this.oEntidadesConAccionesAutomaticas.item(lcEntidad).PK
			catch 
				lcCodigo = ""
			endtry
			if !empty(lcCodigo)
				for i = 1 to this.oEntidadesConAccionesAutomaticas_Detalle.Count && Colleccion Ordenada por Codigo y Orden.
					with this.oEntidadesConAccionesAutomaticas_Detalle[i]
						if lcCodigo == .Codigo
							if upper( alltrim( .Metodo ) ) = LcMetodo
								if left( upper( alltrim ( tcMetodo ) ), 5 ) == "ANTES"
									if pemstatus( toEntidad, "LACCIONAUTOMATICATIPOANTES", 5)
										toEntidad.LACCIONAUTOMATICATIPOANTES = .T.
									endif
								else
									if pemstatus( toEntidad, "LACCIONAUTOMATICATIPOANTES", 5)
										toEntidad.LACCIONAUTOMATICATIPOANTES = .F.
									endif
								endif
								lcAccion = this.BuscarEquivalenciaAccionMetodo( .Accion )
								if This.EvaluarCondicionEjecucionAccionAutomatica( toEntidad, .Condicion )
									This.oEntidadAccionesAutomaticas.lEjecutarEnOtroHilo = .EjecutarEnOtroHilo
									this.oEntidadAccionesAutomaticas.&lcAccion( toEntidad, .Expresion )
								Endif	
							endif
						endif
					endwith
				endfor
			endif
		catch to loError
			loEx = newobject( "ZooException", "ZooException.prg" )
			with loEx
				.Grabar( loError )
				.nZooErrorNo = 7123
				.AgregarInformacion( "Error al procesar la Acción Automática " + lcAccion  )
				.Message = "Error al procesar la Acción Automática " + lcAccion 
				.Details = "Error al procesar la Acción Automática " + lcAccion 
				.throw()
			endwith
		endtry
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function EvaluarCondicionEjecucionAccionAutomatica( toEntidad as Entidad of Entidad.prg, tcCondicion as String ) as boolean
		local llRetorno as Boolean, lcCondicion as String
		llRetorno = empty( tcCondicion )
		if llRetorno
		else
			with toEntidad
				lcCondicion = alltrim( tcCondicion )
				llRetorno = &lcCondicion
			endwith
		endIf
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CantidadDeEntidadesQueTienenAccionesAutomaticas() as Integer
		return this.oEntidadesConAccionesAutomaticas.Count
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarEquivalenciaAccionMetodo( tcAccion as String ) as String
		local lcMetodo as String, lcAccion as String
		lcAccion = alltrim( upper( tcAccion ) )
		do case
			case lcAccion = "IMPRIMIR"
				lcMetodo = "RealizarImpresion"
			case lcAccion = "ENVIAR EMAIL"
				lcMetodo = "EnviarMail"	
			otherwise
				lcMetodo = lcAccion
		endcase
		
		return lcMetodo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function PuedeInstanciarLaEntidadAccionesAutomaticas() as Boolean
		return !empty( _Screen.zoo.app.cSucursalActiva )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LaEntidadTieneIniciarDespuesDeGuardar( tcEntidad as String ) as Boolean
		local llRetorno as Boolean, loItem as Object

		llRetorno = .f.
		if vartype( this.oEntidadesConAccionesAutomaticas ) == "O"  
			try
				loItem = this.oEntidadesConAccionesAutomaticas.item(tcEntidad)
				llRetorno = loItem.nuevodespuesdegrabar
			catch
			endtry
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerExpresion( tcEntidad as string , tcMetodo as String, tcAccion as String ) as Void
		local loDetalle as zoocoleccion OF zoocoleccion.prg, loItem as Object


		for each loEntidad in this.oEntidadesConAccionesAutomaticas
			if upper( alltrim ( loEntidad.Entidad ) ) = upper( alltrim( tcEntidad ) )
				for each loAcciones in this.oEntidadesConAccionesAutomaticas_Detalle
					if upper( alltrim( loAcciones.Metodo ) ) = tcMetodo  and ;
						upper( alltrim( loAcciones.Accion ) ) = tcAccion 
						lcCodigoExpresion = alltrim( loAcciones.Expresion )
						exit
					endif
				endfor
			endif
		endfor
		
		return lcCodigoExpresion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValorDeCierreDeEntidad( tcEntidad as String) as String
		local lcRetorno as String
		lcRetorno	= ""
		if vartype( this.oEntidadesConAccionesAutomaticas ) == "O"  
			if this.LaEntidadTieneAccionesAutomaticas(upper(alltrim(tcEntidad)))
				lcRetorno	= this.oEntidadesConAccionesAutomaticas.item(upper(tcEntidad)).ValorDeCierre
			endif
		endif 
		return lcRetorno
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------
	function LaEntidadTieneRestringirPicking( tcEntidad as String ) as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		if vartype( this.oEntidadesConAccionesAutomaticas ) == "O"  
			try
				loItem = this.oEntidadesConAccionesAutomaticas.item(tcEntidad)
				llRetorno = loItem.RestringirPicking
			catch
			endtry
		endif
		return llRetorno
	endfunc 

enddefine
