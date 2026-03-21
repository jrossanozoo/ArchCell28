define class kontrolerGestionDeProduccion as din_KontrolerGestionDeProduccion of din_KontrolerGestionDeProduccion.prg

	#if .f.
		local this as kontrolerGestionDeProduccion of kontrolerGestionDeProduccion.prg
	#endif
	
	lDeshabilitarGenerarCotizacion = .t.
	lHabilitarGenerarCotizacion = .t.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.BindearEvento( This.oEntidad, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorGestion" )
		This.BindearEvento( This.oEntidad.OrdenDeProduccion, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorOrden" )
		This.BindearEvento( This.oEntidad.Proceso, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorProceso" )
		this.BindearEvento( this.oEntidad.GestionCurva.oitem, "EventoPedirConfirmacionSalidasMultiples", this, "PedirConfirmacionSalidasMultiples" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ActualizarBarra( tcEstado ) As Void
		dodefault( tcEstado )

		with this.oEntidad
			this.lHabilitarGenerarCotizacion = !empty(.Codigo) and !.EsModoEdicion()
			This.SetearEnabledMenu( "Acciones", "CotizaOrdenDeProduccion", this.lHabilitarGenerarCotizacion )
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipCantidad(toControl as Object) as String
    	local lcRetorno as String, lnIndice as Integer, lcDescripcionTalle as string, loDetalle as object, lcNombreAtributo as string, lcNombreObjetoDetalle as String
        lcRetornoDetalle = ""  
        lcRetorno = ""  
		try   
			if pemstatus( toControl, "cDominio", 5 ) and upper( alltrim( toControl.cDominio ) ) == "NUMERICODECIMALPARAMETRIZADOPR"
				lcNombreObjetoDetalle = "this.oEntidad." + alltrim( toControl.Parent.cAtributo ) 
				loDetalle = &lcNombreObjetoDetalle
		    	if type( 'loDetalle' ) = 'O' and !isnull( loDetalle )
			        with loDetalle
				        if  .Count > 0
				            lnIndice = toControl.nFila
            				lcNombreAtributo = toControl.cAtributo
				            if .Count >= lnIndice and lnIndice > 0
					            if .oItem.nroItem = lnIndice 
						            lcRetornoDetalle = alltrim(str(.oItem.&lcNombreAtributo,15,6))
					            else
						            lcRetornoDetalle = alltrim(str(.Item[ lnIndice ].&lcNombreAtributo,15,6))
					            endif
		        	    		lcRetorno = lcRetornoDetalle
				            endif
				        endif
			        endwith
			        release loDetalle
			        loDetalle = null
			    endif
			endif 
		catch
		endtry	
        return lcRetorno 
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipDescripcionTalle(toControl as Object) as String
    	local lcRetorno as String
        lcRetorno = ""
		try
			lcRetorno = this.oEntidad.ObtenerTooltipTalle( toControl.Text )
		catch
		endtry	
        return lcRetorno 
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipValorActual(toControl as Object) as String
    	local lcRetorno as String
        lcRetorno = ""
		try   
			lcRetorno = alltrim( toControl.Text )
		catch
		endtry	
        return lcRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function PedirConfirmacionSalidasMultiples() as Void
		local lcTexto as String, llRespuestaAfirmativa as Boolean
		lcTexto = "Se está intentando modificar o eliminar información de una combinación con múltiples salidas. " ;
				+ chr(13) + chr(10) + "Si continúa, deberá revisar a partir de ahora las cantidades de insumos a consumir " ;
				+ chr(13) + chr(10) + "y, de ser necesario, ajustarlas manualmente." ;
				+ chr(13) + chr(10) + "¿Desea continuar?"
		llRespuestaAfirmativa = ( gomensajes.Preguntar( lcTexto, 4, 1 ) = 6 )
		if llRespuestaAfirmativa
			this.oEntidad.lDebeLoguearPreguntaDeSalidasMultiplesAfirmativa = .t.
			this.oEntidad.lContinuarActualizacionInsumosConSalidasMultiples = .t.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarDetalle( tcTipoDetalle as String, tnFilaActiva as integer ) as Boolean
		local llRetorno as Boolean, lnItem as Integer, lcArticuloOriginal as String, llContinuar as Boolean, llArticuloBorrado as Boolean
		llRetorno = .t.

		if upper( tcTipoDetalle ) == "GESTIONCURVA"

			llContinuar = .t.
			lnItem = this.GestionCurva_NroItem
			if lnItem > 0
				lcArticuloOriginal = this.oEntidad.GestionCurva.Item[ lnItem ].Articulo_PK
				llArticuloBorrado = !empty( lcArticuloOriginal ) and empty( this.GestionCurva_Articulo_pk )

				if this.oEntidad.&tcTipoDetalle..CargaManual() ;
				 and this.oEntidad.ExistenSalidasMultiplesEnElProceso( lcArticuloOriginal, this.GestionCurva_ColorM_pk, this.GestionCurva_TalleM_pk ) ;
				 and !this.oEntidad.lYaHizoLaPreguntaDeSalidasMultiples ;
				 and vartype( this.GestionCurva_Articulo_pk ) = 'C' and this.GestionCurva_Articulo_pk = ''
					this.PedirConfirmacionSalidasMultiples()
					llContinuar = this.oEntidad.lContinuarActualizacionInsumosConSalidasMultiples
					if llContinuar
						this.oEntidad.lYaHizoLaPreguntaDeSalidasMultiples = .t.							
					endif
				endIf
				if llContinuar

					if llArticuloBorrado
						this.oEntidad.EliminarInsumos( lcArticuloOriginal, this.GestionCurva_ColorM_pk, this.GestionCurva_TalleM_pk )
						if this.GestionCurva_CantDescarte > 0
							this.oEntidad.EliminarDescartes( lcArticuloOriginal, this.GestionCurva_ColorM_pk, this.GestionCurva_TalleM_pk )
							this.oEntidad.EliminarInsumosDescartes( lcArticuloOriginal, this.GestionCurva_ColorM_pk, this.GestionCurva_TalleM_pk )
						endif
					endif

				else
					this.GestionCurva_Articulo_pk = lcArticuloOriginal
					loControlDetalleCurva = this.ObtenerControl( tcTipoDetalle )
					loControlDetalleCurva.RefrescarGrilla()
					llRetorno = .f.
				endif

			endif
		endif

		llRetorno = llRetorno and dodefault( tcTipoDetalle , tnFilaActiva )

		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	Function CotizacionDeOrdenDeProduccion() as void
		local loFormulario as Form, loCampo as Object
		loFormulario = goServicios.Formularios.Procesar( "CotizacionProduccion" )
		loFormulario.WindowType= 1
		loFormulario.LockScreen = .t.
		loFormulario.Show(1)
		loFormulario.oKontroler.Ejecutar( "NUEVO" )
		loFormulario.oEntidad.GestionDeProduccion_PK = this.oEntidad.Codigo
		loFormulario.oEntidad.lHabilitarGestionDeProduccion_PK = .f.
		loFormulario.oEntidad.lHabilitarOrdenDeProduccion_PK = .f.
		loCampo = loFormulario.oKontroler.Obtenercontrol('Fecha')
		loCampo.SetFocus()
		loFormulario.LockScreen = .f.
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		Function CotizacionDeOrdenDeProduccion() as void
*!*			local loFormulario as Form, loCampo as Object
*!*			if empty( this.oEntidad.Taller.Proveedor_PK )
*!*				goMensajes.Advertir( "El taller debe tener un proveedor asignado para liquidar un proceso." )
*!*			else
*!*				loFormulario = goServicios.Formularios.Procesar( "CotizacionProduccion" )
*!*				loFormulario.WindowType= 1
*!*				loFormulario.LockScreen = .t.
*!*				loFormulario.Show(1)
*!*				loFormulario.oKontroler.Ejecutar( "NUEVO" )
*!*				loFormulario.oEntidad.GestionDeProduccion_PK = this.oEntidad.Codigo
*!*				loFormulario.oEntidad.lHabilitarGestionDeProduccion_PK = .f.
*!*				loFormulario.oEntidad.lHabilitarOrdenDeProduccion_PK = .f.
*!*	*!*				loFormulario.oEntidad.LlenarInsumosDesdeGestionDeOrden()
*!*				loCampo = loFormulario.oKontroler.Obtenercontrol('Fecha')
*!*				loCampo.SetFocus()
*!*				loFormulario.LockScreen = .f.
*!*	*!*				loFormulario.Show()
*!*			endif
*!*		endfunc 

enddefine
