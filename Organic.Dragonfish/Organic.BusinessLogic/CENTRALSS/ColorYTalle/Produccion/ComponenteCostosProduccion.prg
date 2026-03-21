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
	oColaborador = null
	lProcesarCostos = .F.

	*-----------------------------------------------------------------------------------------
	function oColaborador_access() as Void
		if this.ldestroy
		else
			if ( !vartype( this.oColaborador ) = 'O' or isnull( this.oColaborador ) )
				this.oColaborador = _Screen.Zoo.CrearObjeto('ColaboradorDeCostosDeProduccion','componenteCostosProduccion.prg')
			endif
		endif
		return this.oColaborador
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function InyectarDetalle( toDetalle As detalle Of detalle.prg ) As void
		This.oColCostos = toDetalle 
		This.oItem = toDetalle.oItem
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Grabar() As ZooColeccion Of ZooColeccion.prg
		Local loColSentencias As ZooColeccion Of ZooColeccion.prg, loItem As Object, loColAux As ZooColeccion Of ZooColeccion.prg, ;
			lcItemAux As String, loEntidadCostos as entidad OF entidad.prg, lcCodigo as String, loColCodigo As ZooColeccion Of ZooColeccion.prg
		loColSentencias	= _Screen.zoo.crearobjeto( "zoocoleccion" )
		loColCodigo	= _Screen.zoo.crearobjeto( "zoocoleccion" )
		With This
			If .lProcesarCostos
				if this.lNuevo
					loEntidadCostos = _Screen.Zoo.InstanciarEntidad( "CostoDeInsumo" )
					For Each loItem In This.oColCostos FoxObject
						loColAux = _Screen.zoo.crearobjeto( "zoocoleccion" )
						lcCodigo =  padr( loItem.ListaDeCosto_Pk, 6 ) + padr( loItem.SemiElaborado_PK, 25 ) + ;
									padr( loItem.Color_Pk, 6 ) + padr( loItem.Talle_Pk, 5 ) + ;
									padr( loItem.Taller_Pk, 15 ) + padr( loItem.Proceso_Pk, 15 ) + ;
									str(loItem.DesdeCantidad, 7 )
						try
							loEntidadCostos.Codigo = lcCodigo
							loEntidadCostos.Modificar()
						catch to loError
							loEntidadCostos.Nuevo()
							loEntidadCostos.Codigo = lcCodigo
						endtry
						try
							if loEntidadCostos.esNuevo()
								loEntidadCostos.ListaDeCosto_PK = loItem.ListaDeCosto_PK
								loEntidadCostos.Insumo_PK = loItem.Semielaborado_PK
								loEntidadCostos.color_PK = loItem.color_PK
								loEntidadCostos.talle_PK = loItem.talle_PK
								loEntidadCostos.taller_PK = loItem.taller_PK
								loEntidadCostos.proceso_PK = loItem.proceso_PK
								loEntidadCostos.DesdeCantidad = loItem.DesdeCantidad
								loEntidadCostos.CostoDirecto = loItem.CostoActualizado
							else
								loEntidadCostos.CostoOriginal = loItem.CostoDeLista
								loEntidadCostos.CostoDirecto = loItem.CostoActualizado
							endif
							If loEntidadCostos.Validar()
								loEntidadCostos.ReasignarPk_Con_CC()
								if loEntidadCostos.esNuevo()
									loColAux = loEntidadCostos.ObtenerSentenciasInsert()
								else
									loColAux = loEntidadCostos.ObtenerSentenciasUpdate()
								endif
								if !loColCodigo.Buscar(lcCodigo)
									loColCodigo.Agregar(lcCodigo, lcCodigo)
									For Each lcItemAux In loColAux FoxObject
										loColSentencias.agregar( lcItemAux )
									endfor
								endif
							endif
							loEntidadCostos.Cancelar()
						catch to loError
							loEntidadCostos.Cancelar()
							goServicios.Errores.LevantarExcepcion( loError )
						endtry
					endfor
					loEntidadCostos.Release()
				else 
					if this.lAnular
					endif 						
					if this.lEliminar 
					endif 						
				endif 
			endif
		endwith
		Return loColSentencias
	endfunc

	*-----------------------------------------------------------------------------------------
	Function SetearCostoActual( toItem As Object, tcListaDeCosto As String, tcAtributo As String, tcBaseDeDatos As String ) As void
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
	function ObtenerCostoDeInsumoParaLiquidacionDeTaller( tcLista as String, tcInsumo as String, tcTaller as String, tcProceso as String, ;
														tcColor as String, tcTalle as String, tnCantidad as Number ) as Void

		local lnRetorno as Currency, lcSentencia as String, lcLista as String, lcInsumo as String, lcTaller as String, lcProceso as String, lcColor as String, lcTalle as String
		lcLista = alltrim(tcLista)
		lcInsumo = alltrim(tcInsumo)
		lcTaller = alltrim(tcTaller)
		lcProceso = alltrim(tcProceso)
		lcColor = alltrim(tcColor)
		lcTalle = alltrim(tcTalle)
		lcSentencia = "Select codigo, cdirecto from " +_screen.zoo.app.cschemadefault + ".costoins where Insumo = '" + lcInsumo + "'"
		lcSentencia = lcSentencia + " and listacost = '" + lcLista + "'"
		lcSentencia = lcSentencia + " and cantidad <= " + alltrim(str(tnCantidad)) + " and "
		lcSentencia = lcSentencia + " (("
		lcSentencia = lcSentencia + "taller = '" + lcTaller + "' and proceso = '" + lcProceso + "'"
		lcSentencia = lcSentencia + " and ccolor = '" + lcColor + "' and talle = '" + lcTalle + "'"
		lcSentencia = lcSentencia + ") or "
		lcSentencia = lcSentencia + " (taller = '" + lcTaller + "' and proceso = '" + lcProceso + "') or "
		lcSentencia = lcSentencia + " ((taller = '' and proceso = '' and ccolor = '" + lcColor + "' and talle = '" + lcTalle + "')) or "
		lcSentencia = lcSentencia + " (taller = '' and proceso = '' and ccolor = '" + lcColor + "' and talle = '') or "
		lcSentencia = lcSentencia + " (taller = '' and proceso = '' and ccolor = '' and talle = '" + lcTalle + "'))"
		lcSentencia = lcSentencia + " order by iif(taller != '',8,0) + iif(proceso != '',4,0) + iif(ccolor != '',2,0) + iif(talle != '',1,0) desc "

		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curCosto", this.DataSessionId )
		if used('curCosto') and reccount('curCosto') > 0
			go top in curCosto
			lnRetorno = curCosto.cDirecto
		else
			lnRetorno = 0
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCostoAplicadoParaTaller( toItem As Object, tcListaDeCosto As String, tcTaller As String, tnCantidad as Integer ) as Currency
		local lnRetorno as Currency, lcSentencia as String
		lcSentencia = "Select codigo, cdirecto from " +_screen.zoo.app.cschemadefault + ".costoins where Insumo = '" + toItem.SemiElaborado_PK + "'"
		lcSentencia = lcSentencia + " and listacost = '" + tcListaDeCosto + "'"
		lcSentencia = lcSentencia + " and cantidad <= " + alltrim(str(tnCantidad))
		lcSentencia = lcSentencia + " order by iif(taller != '',8,0) + iif(proceso != '',4,0) + iif(ccolor != '',2,0) + iif(talle != '',1,0) desc) "
		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curCosto", this.DataSessionId )
		if used('curCosto') and reccount('curCosto') > 0
			go top in curCosto
			lnRetorno = curCosto.cDirecto
		else
			lnRetorno = 0
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerValorCostoCombinacion( toItem As Object, tcListaDeCosto As String ) As Number
		Local lnValor As Number, lcConsulta as String, lcCodigo as String
		lnValor =  0
		if !empty(toItem.SemiElaborado_PK) and !empty(toItem.ListaDeCosto_PK)
			lcCodigo =  padr( toItem.ListaDeCosto_Pk, 6 ) + padr( toItem.SemiElaborado_Pk, 25 ) + ;
						padr( toItem.Color_Pk, 6 ) + padr( toItem.Talle_Pk, 5 ) + ;
						padr( toItem.Taller_Pk, 15 ) + padr( toItem.Proceso_Pk, 15 ) + ;
						str(toItem.DesdeCantidad, 7 )
			lcConsulta = "Select cDirecto from "+_screen.zoo.app.cschemadefault+".costoins where Codigo = '" + lcCodigo + "' order by cantidad desc"
			goServicios.Datos.EjecutarSentencias( lcConsulta , "", "", "c_Costo", this.DataSessionId )
			if used("c_Costo") and reccount("c_Costo") > 0
				go top in c_Costo
				lnValor = c_Costo.cDirecto
			endif
		endif
		Return lnValor
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerCotizacionCostoCombinacion( toItem As Object, tcListaDeCosto As String ) As Number
		Local lnValor As Number, lcConsulta as String
		lnValor =  0
		if !empty(toItem.SemiElaborado_PK) and !empty(toItem.ListaDeCosto_PK)
			lcConsulta = "Select Cantidad, cDirecto from "+_screen.zoo.app.cschemadefault+".costoins where Insumo = '" + alltrim(toItem.SemiElaborado_PK) + "'"
			lcConsulta = lcConsulta + " and ListaCost = '" + alltrim(toItem.ListaDeCosto_PK) + "'"
			lcConsulta = lcConsulta + " and cColor = '" + alltrim(toItem.Color_PK) + "'"
			lcConsulta = lcConsulta + " and Talle = '" + alltrim(toItem.Talle_PK) + "'"
			lcConsulta = lcConsulta + " and Taller = '" + alltrim(toItem.Taller_PK) + "'"
			lcConsulta = lcConsulta + " and Proceso = '" + alltrim(toItem.Proceso_PK) + "'"
			lcConsulta = lcConsulta + " and cantidad <= " + alltrim(str(toItem.desdeCantidad)) + " order by cantidad desc"
			goServicios.Datos.EjecutarSentencias( lcConsulta , "", "", "c_Costo", this.DataSessionId )
			if used("c_Costo") and reccount("c_Costo") > 0
				go top in c_Costo
				lnValor = c_Costo.cDirecto
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

	*-----------------------------------------------------------------------------------------
	Function ObtenerCostoPonderado( tcLista as String, tcInsumo as String, tcTaller as String, tcProceso as String, ;
														tcColor as String, tcTalle as String, tnCantidad as Number ) as Number
		local lnRetorno as Currency, lcSentencia as String
		lcSentencia = this.oColaborador.ObtenerSentenciaCostoPonderado( tcLista, tcInsumo, tcTaller, tcProceso, tcColor, tcTalle, tnCantidad )
		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curCosto", this.DataSessionId )
		if used('curCosto') and reccount('curCosto') > 0
			go top in curCosto
			lnRetorno = curCosto.cDirecto
		else
			lnRetorno = 0
		endif
		return lnRetorno
	EndFunc 

enddefine

*-----------------------------------------------------------------------------------------
define class ColaboradorDeCostosDeProduccion as Session

	nPonderadoTaller = 2
	nPonderadoProceso = 1
	nPonderadoColor = 3
	nPonderadoTalle = 4

	*-----------------------------------------------------------------------------------------
	function ObtenerCostoPonderado( tcLista as String, tcInsumo as String, tcTaller as String, tcProceso as String, ;
														tcColor as String, tcTalle as String, tnCantidad as Number ) as Void

		local lnRetorno as Currency, lcSentencia as String, lcLista as String, lcInsumo as String, lcTaller as String, lcProceso as String, lcColor as String, lcTalle as String
		lcLista = alltrim(tcLista)
		lcInsumo = alltrim(tcInsumo)
		lcTaller = alltrim(tcTaller)
		lcProceso = alltrim(tcProceso)
		lcColor = alltrim(tcColor)
		lcTalle = alltrim(tcTalle)
		lcSentencia = "Select codigo, cdirecto from " +_screen.zoo.app.cschemadefault + ".costoins where Insumo = '" + lcInsumo + "'"
		lcSentencia = lcSentencia + " and listacost = '" + lcLista + "' and cdirecto > 0 "
		lcSentencia = lcSentencia + " and cantidad <= " + alltrim(str(tnCantidad)) + " and "
		lcSentencia = lcSentencia + " ("
		lcSentencia = lcSentencia + "(taller = '" + lcTaller + "' or taller = '') and "
		lcSentencia = lcSentencia + "(proceso = '" + lcProceso + "' or proceso = '') and "
		lcSentencia = lcSentencia + "(ccolor = '" + lcColor + "' or ccolor = '') and "
		lcSentencia = lcSentencia + "(talle = '" + lcTalle + "' or talle = '')"
		lcSentencia = lcSentencia + ")"
		lcSentencia = lcSentencia + " order by iif(taller != ''," + alltrim(str(2 ^ (4-this.nPonderadoTaller))) + ",0) + "
		lcSentencia = lcSentencia + "iif(proceso != ''," + alltrim(str(2 ^ (4-this.nPonderadoProceso))) + ",0) + "
		lcSentencia = lcSentencia + "iif(ccolor != ''," + alltrim(str(2 ^ (4-this.nPonderadoColor))) + ",0) + "
		lcSentencia = lcSentencia + "iif(talle != ''," + alltrim(str(2 ^ (4-this.nPonderadoTalle))) + ",0) "
		lcSentencia = lcSentencia + "+ cantidad / 10000000 desc "

		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curCosto", this.DataSessionId )
		if used('curCosto') and reccount('curCosto') > 0
			go top in curCosto
			lnRetorno = curCosto.cDirecto
		else
			lnRetorno = 0
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaCostoPonderado( tcLista as String, tcInsumo as String, tcTaller as String, tcProceso as String, ;
														tcColor as String, tcTalle as String, tnCantidad as Number ) as String

		local lcRetorno as String, lcSentencia as String, lcLista as String, lcInsumo as String, lcTaller as String, lcProceso as String, lcColor as String, lcTalle as String

		lcLista = alltrim(tcLista)
		lcInsumo = alltrim(tcInsumo)
		lcTaller = alltrim(tcTaller)
		lcProceso = alltrim(tcProceso)
		lcColor = alltrim(tcColor)
		lcTalle = alltrim(tcTalle)
		lcCantidad = alltrim(str(tnCantidad))
		lcRetorno = "Select Funciones.ObtenerCostoDeInsumoPonderado('"
		lcRetorno = lcRetorno + lcLista + "','"
		lcRetorno = lcRetorno + lcInsumo + "','"
		lcRetorno = lcRetorno + tcProceso + "','"
		lcRetorno = lcRetorno + lcTaller + "','"
		lcRetorno = lcRetorno + lcColor + "','"
		lcRetorno = lcRetorno + lcTalle + "',"
		lcRetorno = lcRetorno + lcCantidad + ") as cdirecto"

		return lcRetorno
	endfunc 

enddefine
