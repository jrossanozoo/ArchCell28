define class EntColorytalle_ListadePrecios as ent_LISTADEPRECIOS of ent_LISTADEPRECIOS.PRG 
	
	#if .f.
		local this as EntColorytalle_ListadePrecios of EntColorytalle_ListadePrecios.prg
	#endif

	tipoagrupamientopublicacionesAux = 0	
	oColaboradorEliminar = null
	
	*--------------------------------------------------------------------------------------------------------
	function oColaboradorEliminar_access() as object
		if !this.lDestroy and ( type( "this.oColaboradorEliminar" ) <> "O" or isnull( this.oColaboradorEliminar ) )
			this.oColaboradorEliminar = _screen.zoo.CrearObjeto( "ColaboradorListaDePreciosAEliminar " )
		endif
		return this.oColaboradorEliminar
	endfunc
	
	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		this.tipoagrupamientopublicacionesAux = this.tipoagrupamientopublicaciones
		dodefault()
	endfunc  

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		local llRetorno as Boolean, lcMensaje as String 
		
		llRetorno = dodefault()
	
		if llRetorno and !this.EsNuevo() and this.EsEdicion()  and (this.tipoagrupamientopublicacionesAux <> this.tipoagrupamientopublicaciones)
			lcMensaje = 'Importante: La modificación de la lista de precios afectará los precios asociados a la lista '+;
							alltrim(this.coDIGO) + ' de aquellas bases de datos que tengan suscripciones activas de precios.'+ chr(13)+;
							'¿Está seguro que desea guardar cambios en el registro? '

			llRetorno = ( gomensajes.Preguntar( lcMensaje , 4, 1 ) = 6 )
			this.AgregarInformacion("No se guardarán los cambios en el registro")
			
		endif 	
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAnulacion() as boolean
		local llRetorno as boolean
		
		llRetorno = .t.
		llRetorno = this.VerificarAsignacionesDeFormulas( this.Codigo ) and llRetorno
		llRetorno = this.VerificarFormulas( this.Codigo ) and llRetorno
		
		if llRetorno
			llRetorno = dodefault()
		else
			this.AgregarInformacion( "La lista de precios " + alltrim( this.Codigo ) + " no puede ser eliminada." )
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarAsignacionesDeFormulas( tcCodigoLista as string ) as boolean
		local lcNumerosAsignaciones as string, lcMensajeAsignaciones as string
		
		lcNumerosAsignaciones = this.oColaboradorEliminar.AsignacionesDeFormulasParaLaLista( tcCodigoLista )
		
		if !empty( lcNumerosAsignaciones )
			lcMensajeAsignaciones = "Para eliminar " + tcCodigoLista + " primero se debe eliminar o modificar la siguiente "
			lcMensajeAsignaciones = lcMensajeAsignaciones + "asignación de fórmula: " + lcNumerosAsignaciones + "."
			this.AgregarInformacion( lcMensajeAsignaciones )
		endif
		
		return empty( lcNumerosAsignaciones )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarFormulas( tcCodigoLista as string ) as boolean
		local lcCodigosFormulas as string, lcMensajeFormulas as string
		
		lcCodigosFormulas = this.oColaboradorEliminar.FormulasParaLaLista( tcCodigoLista )
		
		if !empty( lcCodigosFormulas )
			lcMensajeFormulas = "Para eliminar " + tcCodigoLista + " primero se deben eliminar o modificar las siguientes "
			lcMensajeFormulas = lcMensajeFormulas + "fórmulas: " + lcCodigosFormulas + "."
			this.AgregarInformacion( lcMensajeFormulas )
		endif
		
		return empty( lcCodigosFormulas )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarSinValidaciones() as void
		if this.lEliminar
			this.oColaboradorEliminar.EliminarPrecios( this.Codigo )
		endif
		dodefault()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerListasDePreciosConVisibilidad( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local lcXml as String, loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object, lcFiltro as String, llNivel1 as Boolean, llNivel2 as Boolean, llNivel3 as Boolean
		
		loRetorno = _screen.zoo.CrearObjeto( "zooColeccion" )

		llNivel1 = goServicios.Seguridad.PedirAccesoMenu( upper(alltrim(tcEntidad)) + "_VERLP_N" + transform(1), .T. )
		llNivel2 = goServicios.Seguridad.PedirAccesoMenu( upper(alltrim(tcEntidad)) + "_VERLP_N" + transform(2), .T. )
		llNivel3 = goServicios.Seguridad.PedirAccesoMenu( upper(alltrim(tcEntidad)) + "_VERLP_N" + transform(3), .T. )

		do case
		case llNivel1 and llNivel2 and llNivel3
			lcXml = this.oAd.obtenerdatosentidad( "codigo,condicioniva", "", "codigo" )
		case !llNivel1 and !llNivel2 and !llNivel3
			lcXml = this.oAd.obtenerdatosentidad( "codigo,condicioniva", "NivelVisibilidad < 0", "codigo" )
		other
			lcFiltro = iif( llNivel1, " NivelVisibilidad = " + transform(0),"")
			lcFiltro = lcFiltro + iif( llNivel2, iif(empty(lcFiltro),""," or")+" NivelVisibilidad = " + transform(1),"")
			lcFiltro = lcFiltro + iif( llNivel3, iif(empty(lcFiltro),""," or")+" NivelVisibilidad = " + transform(2),"")
			lcFiltro = "(" + lcFiltro + ")"
			lcXml = this.oAd.obtenerdatosentidad( "codigo,condicioniva", lcFiltro, "codigo" )
		endcase
		this.XmlACursor( lcXml, "C_Codigos" ) 
		select c_Codigos
		scan 
			loItem = this.ObtenerItemAuxParaColeccionDeListasDePrecios()
			loItem.Codigo = alltrim( c_Codigos.Codigo )
			loItem.CondicionIva = c_Codigos.CondicionIva
			loRetorno.Add( loItem )
		endscan 
					
		use in select( "c_Codigos" )			
		
		return loRetorno
	endfunc

enddefine
