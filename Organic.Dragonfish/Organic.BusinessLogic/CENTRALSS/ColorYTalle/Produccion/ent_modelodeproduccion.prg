define class ent_ModeloDeProduccion as din_EntidadModeloDeProduccion of din_EntidadModeloDeProduccion.prg

	#If .F.
		Local This As ent_ModeloDeProduccion As ent_ModeloDeProduccion.prg
	#Endif

	oColaborador = null
	ProcesoActivo = ''

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		with this
			.ModeloProcesos.InyectarEntidad( This )
			.ModeloInsumos.InyectarEntidad( This )
			.ModeloSalidas.InyectarEntidad( This )
			.ModeloMaquinas.InyectarEntidad( This )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColaborador_access() as Object
		if this.lDestroy
		else
			if ( vartype( this.oColaborador ) != "O" or isnull( this.oColaborador ) )
				this.oColaborador = _Screen.zoo.CrearObjetoPorProducto( "ColaboradorProduccion" )
			endif
		endif
		return this.oColaborador
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		Local llRetorno as boolean
		llRetorno = .T.

		llRetorno = dodefault()
		With This
			llRetorno = .ValidarUltimoProcesoUnico() and llRetorno
		EndWith
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeCombinacionesFueraDeCurva( tcCurva as String, toDetalle as detalle OF detalle.prg, tcColor as String, tcTalle as String) as Collection
		local loRetorno as Collection
		loRetorno = _Screen.zoo.crearobjeto( "zooInformacion" )
		return loRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Curvadeproduccion( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean, loInformacion as zooInformacion of zooInformacion.prg
		
		llRetorno = .T.
		if this.EsModoEdicion()
			this.oInformacion.Limpiar()
			if !empty(txVal)
				loInformacion = _Screen.zoo.crearobjeto( "zooInformacion" )
				loInformacion = this.oColaborador.ObtenerInformacionDeCombinacionesFueraDeCurva( loInformacion, txVal, this.ModeloInsumos, 'Color_PK', 'Talle_PK')
				if loInformacion.Count > 0
					for each loMensaje in loInformacion FOXOBJECT
						this.oInformacion.AgregarInformacion( chr(9) + loMensaje.cMensaje )
					next
					this.oInformacion.AgregarInformacion('Información del detalle de insumos:')
				endif

				loInformacion = _Screen.zoo.crearobjeto( "zooInformacion" )
				loInformacion = this.oColaborador.ObtenerInformacionDeCombinacionesFueraDeCurva( loInformacion, txVal, this.ModeloSalidas, 'Color_PK', 'Talle_PK')
				if loInformacion.Count > 0
					for each loMensaje in loInformacion FOXOBJECT
						this.oInformacion.AgregarInformacion( chr(9) + loMensaje.cMensaje )
					next
					this.oInformacion.AgregarInformacion('Información del detalle de salidas:')
				endif
				if this.oInformacion.Count > 0
					this.oInformacion.AgregarInformacion('Se encontraror errores con los detalle respecto de la curva de producción '+alltrim(txVal))
					this.CurvaDeProduccion_PK = txValOld
					goServicios.Errores.LevantarExcepcion( this.obtenerinformacion() )
				endif
			endif
			llRetorno = dodefault( txVal, txValOld )
		endif
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarGrillasSegunProceso( tcProceso as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarProcesoEnModelo( tcProceso as String ) as Boolean
		local loDetalle as Collection, loItem as Object, llRetorno as Boolean
		llRetorno = .f.
		if type('tcProceso') == 'C' and !empty(tcProceso)
			for each loItem in this.ModeloProcesos FOXOBJECT
				if alltrim(upper(loItem.Proceso_PK)) == alltrim(upper(tcProceso))
					llRetorno = .t.
					exit
				endif
			next
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarProcesoEnItems( tcProceso as String ) as Boolean
		local loDetalle as Collection, loItem as Object, llRetorno as Boolean
		llRetorno = .t.
		if type('tcProceso') == 'C' and !empty(tcProceso)
			for each loItem in this.ModeloMaquinas FOXOBJECT
				if alltrim(upper(loItem.Proceso_PK)) == alltrim(upper(tcProceso))
					llRetorno = .f.
					exit
				endif
			next
			for each loItem in this.ModeloInsumos FOXOBJECT
				if alltrim(upper(loItem.Proceso_PK)) == alltrim(upper(tcProceso))
					llRetorno = .f.
					exit
				endif
			next
			for each loItem in this.ModeloSalidas FOXOBJECT
				if alltrim(upper(loItem.Proceso_PK)) == alltrim(upper(tcProceso))
					llRetorno = .f.
					exit
				endif
			next
		endif
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Cancelar() As void
		this.ProcesoActivo = ''
		dodefault()
	Endfunc

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		this.ReordenarDetalles()
		llRetorno = DoDefault()
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReordenarDetalles() as Void
		this.ReordenarDetalleProcesos()
		this.ReordenarDetalleMaquinarias()
		this.ReordenarDetalleInsumos()
		this.ReordenarDetalleSalidas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function ReordenarDetalleProcesos() as Void
		local loDetalle as Collection, loItem1 as Object, loItem2 as Object, llReordenado as Boolean, lnItem as Integer, loIntercambio as Object
		loDetalle = _screen.zoo.crearobjeto("ZooColeccion")
		for each loItem in this.ModeloProcesos FOXOBJECT
			if !empty(loItem.Proceso_PK)
				loDetalle.Add( loItem )
			endif
		next
		llReordenado = .t.
		do while llReordenado
			llReordenado = .f.
			for lnItem = 1 to loDetalle.Count -1
				do case
				case loDetalle.Item[lnItem].Orden < loDetalle.Item[lnItem+1].Orden
				case loDetalle.Item[lnItem].Orden == loDetalle.Item[lnItem+1].Orden and loDetalle.Item[lnItem].Proceso_PK < loDetalle.Item[lnItem+1].Proceso_PK
				otherwise
					loIntercambio = loDetalle.Item[lnItem]
					loIntercambio.nroItem = lnItem+1
					loDetalle.Remove(lnItem)
					loDetalle.Item[lnItem].nroItem = lnItem
					loDetalle.Add(loIntercambio,,,lnItem)
					llReordenado = .t.
				endcase
			next
		enddo
		lnItem = 0
		this.ModeloProcesos.Limpiar()
		for each loItem in loDetalle FOXOBJECT
			if !empty(loItem.Proceso_PK)
				lnItem = lnItem + 1
				loItem.nroItem = lnItem
				this.ModeloProcesos.Add( loItem )
			endif
		next
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected function ReordenarDetalleMaquinarias() as Void
		local loDetalle as Collection, loProcesos as Object, loItem as Object, loOrden as Object, lnItem as Integer
		loDetalle = _screen.zoo.crearobjeto("ZooColeccion")
		for each loItem in this.ModeloMaquinas FOXOBJECT
			if !empty(loItem.Proceso_PK)
				loDetalle.Add( loItem )
			endif
		next
		lnItem = 0
		this.ModeloMaquinas.Limpiar()
		for each loOrden in this.ModeloProcesos FOXOBJECT
			if !empty(loOrden.Proceso_PK) and loOrden.nroItem > 0
				for each loItem in loDetalle FOXOBJECT
					if alltrim(upper(loItem.Proceso_PK)) = alltrim(upper(loOrden.Proceso_PK))
						lnItem = lnItem + 1
						loItem.nroItem = lnItem
						this.ModeloMaquinas.Add( loItem )
					endif
				next
			endif
		next
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected function ReordenarDetalleInsumos() as Void
		local loDetalle as Collection, loProcesos as Object, loItem as Object, loOrden as Object, lnItem as Integer
		loDetalle = _screen.zoo.crearobjeto("ZooColeccion")
		for each loItem in this.ModeloInsumos FOXOBJECT
			if !empty(loItem.Proceso_PK)
				loDetalle.Add( loItem )
			endif
		next
		lnItem = 0
		this.ModeloInsumos.Limpiar()
		for each loOrden in this.ModeloProcesos FOXOBJECT
			if !empty(loOrden.Proceso_PK) and loOrden.nroItem > 0
				for each loItem in loDetalle FOXOBJECT
					if alltrim(upper(loItem.Proceso_PK)) = alltrim(upper(loOrden.Proceso_PK))
						lnItem = lnItem + 1
						loItem.nroItem = lnItem
						this.ModeloInsumos.Add( loItem )
					endif
				next
			endif
		next
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected function ReordenarDetalleSalidas() as Void
		local loDetalle as Collection, loProcesos as Object, loItem as Object, loOrden as Object, lnItem as Integer
		loDetalle = _screen.zoo.crearobjeto("ZooColeccion")
		for each loItem in this.ModeloSalidas FOXOBJECT
			if !empty(loItem.Proceso_PK)
				loDetalle.Add( loItem )
			endif
		next
		lnItem = 0
		this.ModeloSalidas.Limpiar()
		for each loOrden in this.ModeloProcesos FOXOBJECT
			if !empty(loOrden.Proceso_PK) and loOrden.nroItem > 0
				for each loItem in loDetalle FOXOBJECT
					if alltrim(upper(loItem.Proceso_PK)) = alltrim(upper(loOrden.Proceso_PK))
						lnItem = lnItem + 1
						loItem.nroItem = lnItem
						this.ModeloSalidas.Add( loItem )
					endif
				next
			endif
		next
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarUltimoProcesoUnico() as Boolean
		local llRetorno as Boolean, lnUltimo as Integer, lnCantidad as Cantidad, loProcesos as Object
		lnUltimo = 0
		lnCantidad = 0
		for each loProcesos in this.ModeloProcesos FOXOBJECT
			do case
			case !empty(loProcesos.Proceso_PK) and loProcesos.Orden = lnUltimo
				lnCantidad = lnCantidad +  1
			case !empty(loProcesos.Proceso_PK) and loProcesos.Orden > lnUltimo
				lnCantidad = 1
				lnUltimo = loProcesos.Orden
			endcase
		next
		if lnCantidad > 1
			this.AgregarInformacion( 'El modelo debe tener un último proceso único (orden ' + alltrim(str(lnUltimo)) + ')' )
			llRetorno = .f.
		else
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

enddefine
