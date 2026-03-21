define class componenteCostosProduccion as Din_ComponenteCostosProduccion of Din_ComponenteCostosProduccion.prg

	#if .f.
		local this as componenteCostosProduccion of componenteCostosProduccion.prg
	#endif

	Protected nSesionDeDatosPropia As Integer

	oColCostos = Null
	oItem = Null
	oArbolCombinacionCostos = Null
	oColCombinacionCostos  = Null
	oColCombinacionesBuscadas  = Null

	*-----------------------------------------------------------------------------------------
	Function InyectarDetalle( toDetalle As detalle Of detalle.prg ) As void
		This.oColCostos = toDetalle 
		This.oItem = toDetalle.oItem
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerCosto( toItem As Object, tcListaDeCosto As String, tcAtributo As String, tcBaseDeDatos As String ) As void
		If Pcount() < 3 Or This.estaEnOCombinacion( tcAtributo ) Or !Empty( tcBaseDeDatos )
			this.ProcesarCosto( toItem, tcListaDeCosto, tcAtributo, tcBaseDeDatos, 0)
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstaEnOCombinacion( tcAtributo as String ) as Boolean
		
		local llRetorno as Boolean, loItem as Object  
		llRetorno = inlist(lower(tcAtributo),'semielaborado_pk','listadecosto_pk','color_pk','talle_pk','taller_pk','proceso_pk','desdecantidad')
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarCosto( toItem As Object, tcListaDeCosto As String, tcAtributo As String, tcBaseDeDatos As String, tnCosto as Number ) As void
		if this.ValidarAtributosDelItem( toItem )
			Try
				llCambioBaseDeDatos = .F.

				if tnCosto <> 0
					lnValor = tnCosto
				else
					lnValor = This.ObtenerValorCostoCombinacion( toItem, tcListaDeCosto )
				endif
				
				if lnValor = 0 
					This.LimpiarInformacion()
				endif

				If Pemstatus( toItem, "TipoListaDeCosto", 5 )
					This.oEntidad.listaDeCosto_pk = tcListaDeCosto					
					toItem.TipoListaDeCosto = This.oEntidad.ListaDeCosto.CondicionIva
				endif
				
				If Pemstatus( toItem, "Costo", 5 )
					if lnValor = 0 and Pemstatus( toItem, "cContexto", 5 ) and toItem.cContexto = "B"
						lnValor = toItem.Costo
					endif 
					toItem.Costo = lnValor
				endif
				
				toItem.CostoDeLista = lnValor

			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			Finally
				If llCambioBaseDeDatos
					_Screen.zoo.App.cSucursalActiva = This.cBaseDeDatosActiva
					This.cBaseDeDatosEntidad = This.cBaseDeDatosActiva
				Endif
			Endtry
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerValorCostoCombinacion( toItem As Object, tcListaDeCosto As String ) As Number
		Local lnValor As Number, lcConsulta as String
		lnValor =  0
		if !empty(toItem.SemiElaborado_PK) and !empty(toItem.ListaDeCosto_PK)
			lcConsulta = "Select Cantidad, pDirecto from "+_screen.zoo.app.cschemadefault+".costoins where Insumo = '" + alltrim(toItem.SemiElaborado_PK) + "'"
			lcConsulta = lcConsulta + " and ListaCost = '" + alltrim(toItem.ListaDeCosto_PK) + "'"
			lcConsulta = lcConsulta + " and cColor = '" + alltrim(toItem.Color_PK) + "'"
			lcConsulta = lcConsulta + " and Talle = '" + alltrim(toItem.Talle_PK) + "'"
			lcConsulta = lcConsulta + " and Taller = '" + alltrim(toItem.Taller_PK) + "'"
			lcConsulta = lcConsulta + " and Proceso = '" + alltrim(toItem.Proceso_PK) + "'"
			lcConsulta = lcConsulta + " and cantidad <= " + alltrim(str(toItem.desdeCantidad)) + " order by cantidad desc"
			goServicios.Datos.EjecutarSentencias( lcConsulta , "", "", "c_Costo", this.DataSessionId )
			if used("c_Costo") and reccount("c_Costo") > 0
				go top in c_Costo
				lnValor = c_Costo.pDirecto
			endif
		endif
		
		Return lnValor
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAtributosDelItem( toItem as Object ) as Boolean 
		local llRetorno
		llRetorno = !empty( toitem.semielaborado_pk )
		return llRetorno	
	endfunc 

enddefine
