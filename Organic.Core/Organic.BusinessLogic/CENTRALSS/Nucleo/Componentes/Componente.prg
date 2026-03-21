Define Class Componente As zoosession Of zoosession.prg

	#IF .f.
		Local this as Componente of Componente.prg
	#ENDIF

	oCombinacion = null
	oEntidad = null
	lEdicion = .F.
	lNuevo = .F.
	lEliminar = .F.
	lAnular = .f.
	oEntidadPadre = Null
	oDetallePadre = Null
	oDetalleAnterior = Null
	oColSentencias = Null
	oAtributosGenericos = null

	*-----------------------------------------------------------------------------------------
	function oAtributosGenericos_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oAtributosGenericos ) # "O"
			this.oAtributosGenericos = this.ObtenerAtributosGenericos()
		endif
		return this.oAtributosGenericos
	endfunc

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Se ejecuta cuando hace nuevo, modificar, eliminar, etc.
	function Reinicializar( tlLimpiar as Boolean ) as Void
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function InyectarDetalle( toDetalle as Object ) as Void
		This.oDetallePadre = toDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		This.oEntidadPadre = toEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarDetalleAnterior( toDetalle as Object ) as Void
		This.oDetalleAnterior = toDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void

		this.lDestroy = .t.
		if vartype( this.oEntidad ) = "O"
			this.oEntidad.release()
		endif
		this.oEntidad = null
		this.oCombinacion = null
		This.oEntidadPadre = Null
		This.oDetallePadre = Null
		This.oDetalleAnterior = Null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearCombinacion( toItem ) as Void
		local loNodo as object, lcNombreEntidadACargar as String, llCargando as Boolean

		This.oEntidad.Limpiar()
		llCargando = this.oEntidad.lcargando 
		this.oEntidad.lcargando = .T.
		for each loNodo in this.oCombinacion
			
			if pemstatus( toItem, loNodo, 5 ) and pemstatus( this.oEntidad, loNodo, 5 )
				this.oEntidad.&loNodo = toItem.&loNodo
			endif 
				
		endfor 
		this.oEntidad.lcargando = llCargando

	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarEntidad() as Boolean
		local llRetorno as Boolean, loError as Exception, loEx as Exception
		This.LimpiarInformacion()
		llRetorno = .T.
		try 
			This.oEntidad.Buscar()
			This.oEntidad.Cargar()
		catch to loError
			if loError.ErrorNo = 2071 && Error generado por el Usuario
				This.CargarInformacion( loError.UserValue.ObtenerInformacion() )
				llRetorno = .F.
			else
				goServicios.Errores.LevantarExcepcion( loError )
			Endif
		Endtry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Grabar() as zoocoleccion OF zoocoleccion.prg 
		local loRetorno as zoocoleccion OF zoocoleccion.prg, llConEntidad as Boolean

		llConEntidad = vartype( this.oEntidad ) = "O"				 
		do case
			case this.lNuevo and llConEntidad
				loRetorno = this.oEntidad.ObtenerSentenciasInsert()
			case this.lEdicion and llConEntidad				
				loRetorno = this.oEntidad.ObtenerSentenciasUpdate()			
			case this.lEliminar and llConEntidad				
				loRetorno = this.oEntidad.ObtenerSentenciasDelete()
			otherwise
				loRetorno = _screen.zoo.CrearObjeto( "zooColeccion" )
		endcase
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaEnOCombinacion( tcAtributo as String ) as Boolean
		
		local llRetorno as Boolean, loItem as Object  
		llRetorno = .F.
		
		for each loItem in this.oCombinacion 
			if upper( alltrim( loItem ) ) == upper( alltrim( tcAtributo ) ) 
				llRetorno = .T.
				exit
			endif 
		endfor
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoNUEVO( tcEstado as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoELIMINAR( tcEstado as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoMODIFICAR( tcEstado as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoCANCELAR( tcEstado as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoGRABAR( tcEstado as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoANULAR( tcEstado as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function validarAtributo( txVal as Variant, tcAtributo as String ) as Boolean
		&& si devuelve falso deberia llenar un informacion
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarColeccionAColeccion( toColeccionReferencia as zoocoleccion OF zoocoleccion.prg, toColeccionAAgregar as zoocoleccion OF zoocoleccion.prg  ) as Void
		local loItem As Object
		for each loItem in toColeccionAAgregar
			toColeccionReferencia.Add( loItem )
		Endfor	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarItem( tcAtributo as String, toItem as Object ) as Void
		&&Firma para los componentes
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Recibir( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String, tcCursorCabecera as String ) as Void
		&&Firma para los componentes
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearColeccionSentenciasAnterior_NUEVO() as Void
		this.oColSentencias = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearColeccionSentenciasAnterior_MODIFICAR() as Void
		&&Firma para los componentes
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearColeccionSentenciasAnterior_ANULAR() as Void
		&&Firma para los componentes
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearColeccionSentenciasAnterior_ELIMINAR() as Void
		&&Firma para los componentes
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColSentencias_Access() as Void
		if !this.ldestroy and vartype( this.oColSentencias ) != 'O'
			this.oColSentencias = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColSentencias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabarEntidadPadre() as Boolean
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Imprimir( toItem as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function VerificarSiSeteaDatos( toItem as Object ) as boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function SetearYVerificarDatos( toItem as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function RemoverDatosSiCambioTipo( toItem as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function AsignarNumeroDeItemAlItemCero( toItem as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	**Este metodo es llamado por el itemvaloresventas al componente cajero, y este lo llama al subcomponente que le corresponda.
	function AntesDeSetearAtributo( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeForzarVotarCambioEstadoANULAR() as Boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerExpresionConCamposDeAtributosGenericosParaSelect( tcTabla as String, tnOpcion as Integer ) as string
		local lcRetorno as String, loAtributo as Object, lcTabla as String, lcExpresion as String
		lcRetorno = ""
		if empty( tcTabla )
			lcTabla = ""
		else
			lcTabla = tcTabla + "."
		endif
		
		for each loAtributo in this.oAtributosGenericos foxobject
			do case
				case tnOpcion = 1 && Seleccionar nombre de atributo sin renombrarlo.
					lcExpresion = lcTabla + loAtributo.Atributo + " as " + loAtributo.Atributo
				case tnOpcion = 2 && Seleccionar nombre de atributo renombrandolo a campo.
					lcExpresion = lcTabla + loAtributo.Atributo + " as " + loAtributo.Campo
				case tnOpcion = 3 && Seleccionar nombre de campo sin renombrarlo.
					lcExpresion = lcTabla + loAtributo.Campo + " as " + loAtributo.Campo
				case tnOpcion = 4 && Seleccionar nombre de campo renombrandolo a atributo.
					lcExpresion = lcTabla + loAtributo.Campo + " as " + loAtributo.Atributo
			endcase
			lcRetorno = lcRetorno + lcExpresion + ", "
		endfor
		lcRetorno = alltrim( substr( lcRetorno, 1, len( lcRetorno ) - 2 ) )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosGenericos() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		
		loRetorno.Agregar( this.CrearAtributoGenerico( "FechaAltaFW", "FAltaFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "HoraAltaFW", "HAltaFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "FechaModificacionFW", "FModiFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "HoraModificacionFW", "HModiFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "FechaTransferencia", "FecTrans" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "EstadoTransferencia", "EstTrans" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "FechaImpo", "FecImpo" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "HoraImpo", "HoraImpo" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "FechaExpo", "FecExpo" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "HoraExpo", "HoraExpo" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "UsuarioAltaFW", "UAltaFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "UsuarioModificacionFW", "UModiFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "SerieAltaFW", "SAltaFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "SerieModificacionFW", "SModiFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "BaseDeDatosAltaFW", "BDAltaFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "BaseDeDatosModificacionFW", "BDModiFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "VersionAltaFW", "VAltaFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "VersionModificacionFW", "VModiFW" ) )
		loRetorno.Agregar( this.CrearAtributoGenerico( "ZADSFW", "ZADSFW" ) )

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearAtributoGenerico( tcAtributo as String, tcCampo as String ) as Object
		local loRetorno as Object
		loRetorno = _screen.zoo.CrearObjeto( "AtributoGenerico", "Componente.prg" )
		loRetorno.Atributo = tcAtributo
		loRetorno.Campo = tcCampo
		return loRetorno
	endfunc 

enddefine

define class AtributoGenerico as custom
	Atributo = ""
	Campo = ""
enddefine
