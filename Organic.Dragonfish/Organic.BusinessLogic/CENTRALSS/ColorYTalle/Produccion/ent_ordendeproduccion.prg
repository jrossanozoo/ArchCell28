define class ent_OrdenDeProduccion as din_EntidadOrdenDeProduccion of din_EntidadOrdenDeProduccion.prg

	#if .f.
		local this as ent_OrdenDeProduccion of ent_OrdenDeProduccion.prg
	#endif
	
	#define OKORCANCEL 1
	#define YESORNO 4
	#define FIRSTBUTTON 0
	#define SECONDBUTTON 256
	
	lCargandoModelo = .f.
	lCargandoCurva = .f.
	lCurvaEspecificaSegunModelo = .f.
	oModelo = null
	ProcesoActivo = ''
	lCalcularCantidadDeCurvas = .f.
	
	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.OrdenCurva.InyectarEntidad( this )
		this.OrdenProcesos.InyectarEntidad( this )
		this.enlazar( 'Ordencurva.eventoArmarOrdenEnBaseACurva', 'ArmarOrdenEnBaseAModeloYCurva' )
		this.enlazar( 'Ordencurva.eventoQuitarCurvaDeOrden', 'QuitarCurvaDeOrden' )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Destroy()

		dodefault()
		if this.lDestroy
			this.oModelo = null
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		Local llRetorno as boolean
		llRetorno = .T.

		llRetorno = dodefault()
		With This
			llRetorno = .ValidarUltimoProcesoUnico() and .ValidarCurvaSinGenericos() and llRetorno
		EndWith

		return llRetorno

	endfunc

	*-------------------------------------------------------------------------------------------------
	Function Cancelar() As void
		this.ProcesoActivo = ''
		dodefault()
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Modelo( txVal as variant, txValOld as variant ) as Boolean
		local llEsNuevoModelo as Boolean
		llEsNuevoModelo = !empty(txVal) and txVal != txValOld
		if This.CargaManual() and llEsNuevoModelo and (this.OrdenCurva.Count > 0 or this.OrdenProcesos.Count > 0)
			this.OrdenProcesos.Limpiar()
			this.OrdenCurva.Limpiar()
			this.OrdenInsumos.Limpiar()
			this.OrdenSalidas.Limpiar()
			this.EventoRefrescarGrilla('OrdenProcesos')
			this.EventoRefrescarGrilla('OrdenInsumos')
			this.EventoRefrescarGrilla('OrdenCurva')
			this.EventoRefrescarGrilla('OrdenSalidas')
		endif
		if llEsNuevoModelo
			this.lCargandoModelo = .t.
		endif
		Return dodefault( txVal, txValOld )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Modelo( txVal as variant ) as void
		local loVariante as Object, loItem as Object
		dodefault( txVal )
		this.oModelo = this.oColaboradorProduccion.ObtenerModeloDeProduccion( txVal )
		if this.lCargandoModelo
			this.LlenarProcesosDeProduccion(this.OrdenProcesos, this.oModelo )
			this.EventoRefrescarGrilla('OrdenProcesos')
		endif
		if This.CargaManual() and this.lCargandoModelo and empty(this.oModelo.ProductoFinal_PK)
			if this.oModelo.ModeloSalidas.Count > 0 and !empty(this.oModelo.ModeloSalidas.Item[this.oModelo.ModeloSalidas.count].Semielaborado_PK)
				try
					this.ProductoFinal_PK = this.oColaboradorProduccion.ObtenerCodigoDeArticuloDeInsumo( this.oModelo.ModeloSalidas.Item[this.oModelo.ModeloSalidas.count].Semielaborado_PK )
				catch
				endtry
			endif
		else
			this.ProductoFinal_PK = this.oModelo.ProductoFinal_PK
		endif

		this.CurvaDeProduccion_PK = this.oModelo.CurvaDeProduccion_PK

		this.lCurvaEspecificaSegunModelo = this.EsModeloConCurvaEspecifica()
		if this.lCargandoModelo and empty(this.CurvaDeProduccion_PK) and !empty(this.ProductoFinal_PK) and this.lCurvaEspecificaSegunModelo &&  and !empty(this.CurvaDeProduccion_PK)
			this.ArmarOrdenDeModeloEspecificoSinCurva()
			this.EventoRefrescarGrilla('OrdenCurva')
			this.EventoRefrescarGrilla('OrdenInsumos')
			this.EventoRefrescarGrilla('OrdenSalidas')
		endif
		this.lCargandoModelo = .f.

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Curvadeproduccion( txVal as variant ) as void
		dodefault( txVal )
		if !empty(txVal) and this.CurvaDeProduccion.Detalle.Count > 0 and this.lCargandoCurva
			for each loItem in this.CurvaDeProduccion.Detalle FOXOBJECT
				if !empty(loItem.Color_PK) or !empty(loItem.Talle_PK)
					if this.ArmarOrdenEnBaseAModeloYCurva(loItem.Color_PK, loItem.Talle_PK)
						this.OrdenCurva.LimpiarItem()
						this.OrdenCurva.oItem.Producto_PK = this.ProductoFinal_PK
						this.OrdenCurva.oItem.Color_PK = loItem.Color_PK
						this.OrdenCurva.oItem.Talle_PK = loItem.Talle_PK
						if loItem.Cantidad > 0
							this.OrdenCurva.oItem.Cantidad = loItem.Cantidad
						endif
						this.OrdenCurva.Actualizar()
					endif
				endif
			endfor
			this.eventoEnviarMensajeSinEspera( '' )
			this.EventoRefrescarGrilla('OrdenCurva')
		endif
		this.lCargandoCurva = .f.
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Curvadeproduccion( txVal as variant, txValOld as variant ) as Boolean
		local llEsNuevaCurva as Boolean
		llEsNuevaCurva = !empty(txVal) and txVal != txValOld
		if This.CargaManual() and llEsNuevaCurva and this.OrdenCurva.Count > 0
			this.OrdenCurva.Limpiar()
			this.OrdenInsumos.Limpiar()
			this.OrdenSalidas.Limpiar()
			this.EventoRefrescarGrilla('OrdenInsumos')
			this.EventoRefrescarGrilla('OrdenCurva')
		endif
		if llEsNuevaCurva and !empty(this.Modelo_PK)
			this.lCargandoCurva = .t.
		endif
		Return dodefault( txVal, txValOld )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Cantidad( txVal as variant ) as Boolean
		this.lCalcularCantidadDeCurvas = this.EsModoEdicion() and txVal # 0 and txVal # this.Cantidad
		Return dodefault( txVal ) 
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Cantidad( txVal as variant ) as void
		local loVariante as Object
		dodefault( txVal )
		if this.lCalcularCantidadDeCurvas
			this.OrdenCurva.sum_total = 0 
			try
				for each loVariante in this.OrdenCurva foxobject
					loVariante.Total = loVariante.Cantidad * this.cantidad
					this.OrdenCurva.sum_total = this.OrdenCurva.sum_total + loVariante.Total 
				endfor
				this.EventoRefrescarGrilla('OrdenCurva')
			catch
			endtry
		endif
		this.lCalcularCantidadDeCurvas = .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorModeloDeProduccion( toBusqueda as Object ) as Void
		local lcCondicionAnulado as String, lcTablaOrden as String
		toBusqueda.Tabla = toBusqueda.Tabla + "," + this.oAd.cTablaPrincipal 
		lcTablaOrden = iif( !empty( this.oAd.cEsquema ), this.oAd.cEsquema + ".", "" ) + this.oAd.cTablaPrincipal
		toBusqueda.Filtro = toBusqueda.Filtro + " and modeloprod.codigo not in ( select modelo from " + lcTablaOrden + " )"
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoRefrescarGrilla( tcDetalle as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarCurvaDeProduccion( toGrilla as Collection, toModelo as Object ) as Void
		local lcUltimoProceso as String, lnCantidad as Integer
		lcUltimoProceso = this.ObtenerUltimoProceso(toModelo)
		toGrilla.Limpiar()
		try
			with toModelo
				this.eventoEnviarMensajeSinEspera( 'Cargando curva de producción.' )
				for each loVariante in .ModeloSalidas foxobject
					if alltrim(loVariante.Proceso_PK) == alltrim(lcUltimoProceso)
						toGrilla.LimpiarItem()
						toGrilla.oItem.Producto_PK = this.ProductoFinal_PK
						toGrilla.oItem.Color_PK = loVariante.Color_PK
						toGrilla.oItem.Talle_PK = loVariante.Talle_PK
						lnCantidad = this.ObtenerCantidadPorCombinacionEnCurva( this.CurvaDeProduccion_PK, loVariante.Color_PK, loVariante.Talle_PK )
						toGrilla.oItem.Cantidad = lnCantidad 
						toGrilla.oItem.Total = lnCantidad * this.Cantidad
						toGrilla.Actualizar()
					endif
				endfor
			endwith
		catch
		finally
			this.eventoEnviarMensajeSinEspera( '' )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarInsumosDeProduccion( toGrilla as Collection, toModelo as Object ) as Void
		local loError as Object
		toGrilla.Limpiar()
		try
			with toModelo
				if this.lCurvaEspecificaSegunModelo
					this.eventoEnviarMensajeSinEspera( 'Cargando insumos de producción.' )
				endif
				for each loVariante in .ModeloInsumos foxobject
					try
						toGrilla.LimpiarItem()
						toGrilla.oItem.Proceso_pk = alltrim(loVariante.Proceso_PK)
						toGrilla.oItem.Insumo_PK = alltrim(loVariante.Insumo_PK)
						toGrilla.oItem.ColorM_PK = alltrim(loVariante.ColorM_PK)
						toGrilla.oItem.TalleM_PK = alltrim(loVariante.TalleM_PK)
						toGrilla.oItem.Color_PK = alltrim(loVariante.Color_PK)
						toGrilla.oItem.Talle_PK = alltrim(loVariante.Talle_PK)
						toGrilla.oItem.UnidadDeMedida_PK = alltrim(loVariante.UnidadDeMedida_PK)
						toGrilla.oItem.Cantidad = loVariante.Cantidad
					catch to loError
					endtry
					toGrilla.Actualizar()
				endfor
			endwith
		catch to loError
		finally
			if this.lCurvaEspecificaSegunModelo
				this.eventoEnviarMensajeSinEspera( '' )
			endif
		endtry
		this.EventoRefrescarGrilla(toGrilla.cNombre)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarProcesosDeProduccion( toGrilla as Collection, toModelo as Object ) as Void
		local loTaller as Object, loVariante as Object, loError as Object
		loTaller = _Screen.Zoo.InstanciarEntidad( "Taller" )
		toGrilla.Limpiar()
		try
			with toModelo
				for each loVariante in .ModeloProcesos foxobject
					toGrilla.LimpiarItem()
					toGrilla.oItem.Proceso_pk = loVariante.Proceso_PK
					toGrilla.oItem.Orden = loVariante.Orden
					try
						toGrilla.oItem.Taller_PK = alltrim(loVariante.Taller_PK)
						loTaller.Codigo = alltrim(loVariante.Taller_PK)
						for each loItem in loTaller.Procesos FOXOBJECT
							if upper(alltrim(loItem.Proceso_PK)) == upper(alltrim(loVariante.Proceso_PK))
								toGrilla.oItem.InventarioEntrada_PK = loItem.InventarioEntrada_PK
								toGrilla.oItem.InventarioSalida_PK = loItem.InventarioSalida_PK
								exit
							endif
						next
					catch to loError
					endtry
					toGrilla.Actualizar()
				endfor
			endwith
		catch to loError
		endtry
		loTaller.Release()
		this.EventoRefrescarGrilla(toGrilla.cNombre)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarSalidasDeProduccion( toGrilla as Collection, toModelo as Object ) as Void
		local lcUltimoProceso as String, lnCantidad as Integer, loVariante as Object
		lcUltimoProceso = this.ObtenerUltimoProceso(toModelo)
		toGrilla.Limpiar()
		try
			with toModelo
				for each loVariante in .ModeloSalidas foxobject
*!*						if alltrim(loVariante.Proceso_PK) == alltrim(lcUltimoProceso)
						toGrilla.LimpiarItem()
						toGrilla.oItem.Proceso_pk = alltrim(loVariante.Proceso_PK)
						toGrilla.oItem.Semielaborado_PK = loVariante.Semielaborado_PK
						toGrilla.oItem.SemielaboradoDetalle = loVariante.SemielaboradoDetalle
						toGrilla.oItem.ColorM_PK = alltrim(loVariante.ColorM_PK)
						toGrilla.oItem.TalleM_PK = alltrim(loVariante.TalleM_PK)
						toGrilla.oItem.Color_PK = alltrim(loVariante.Color_PK)
						toGrilla.oItem.Talle_PK = alltrim(loVariante.Talle_PK)
						toGrilla.oItem.Cantidad = loVariante.Cantidad
						toGrilla.Actualizar()
*!*						endif
				endfor
			endwith
		catch
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerUltimoProceso( toModelo as Object) as String
		local lcRetorno as String, lnOrdenUltimo as Integer, loVariante as Object
		lcRetorno = ''
		lnOrdenUltimo = 0
		for each loVariante in toModelo.ModeloProcesos foxobject
			if loVariante.Orden > lnOrdenUltimo
				lcRetorno = loVariante.Proceso_PK
				lnOrdenUltimo = loVariante.Orden
			endif
		next
		return lcRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Productofinal( txVal as variant ) as void
		local loItem as Object
		dodefault( txVal )
		if !empty(txVal)
			for each loItem in this.OrdenCurva FOXOBJECT
				if !empty(loItem.Producto_PK) or !empty(loItem.Color_PK) or !empty(loItem.Talle_PK)
					loItem.Producto_PK = txVal
				endif
			next
		endif
		this.EventoRefrescarGrilla('OrdenCurva')
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadPorCombinacionEnCurva( tcCurva as String, tcColor as String, tcTalle as String ) as Integer
		local lnRetorno as Integer, loCurva as entidad OF entidad.prg, loItem as Object
		lnRetorno = 1
		if type('tcCurva') = 'C' and !empty(tcCurva) and type('tcColor') = 'C' and !empty(tcColor) and type('tcTalle') = 'C' and !empty(tcTalle)
			loCurva = _Screen.Zoo.InstanciarEntidad( "CurvaDeProduccion" )
			try
				loCurva.Codigo = tcCurva
				for each loItem in loCurva.Detalle FOXOBJECT
					if alltrim(upper(loItem.Color_PK)) == alltrim(upper(tcColor)) and alltrim(upper(loItem.Talle_PK)) == alltrim(upper(tcTalle))
						lnRetorno = loItem.Cantidad
						exit
					endif
				next
			catch
			endtry
			loCurva.Release()
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarUltimoProcesoUnico() as Boolean
		local llRetorno as Boolean, lnUltimo as Integer, lnCantidad as Cantidad, loProcesos as Object
		lnUltimo = 0
		lnCantidad = 0
		for each loProcesos in this.OrdenProcesos FOXOBJECT
			do case
			case !empty(loProcesos.Proceso_PK) and loProcesos.Orden = lnUltimo
				lnCantidad = lnCantidad +  1
			case !empty(loProcesos.Proceso_PK) and loProcesos.Orden > lnUltimo
				lnCantidad = 1
				lnUltimo = loProcesos.Orden
			endcase
		next
		if lnCantidad > 1
			this.AgregarInformacion( 'La orden de produccion debe tener un último proceso único (orden ' + alltrim(str(lnUltimo)) + ')' )
			llRetorno = .f.
		else
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCurvaSinGenericos() as Boolean
		local llRetorno as Boolean, lnCantidad as Cantidad, loItem as Object
		llRetorno = .t.
		lnCantidad = 0
		if This.CargaManual()
			for each loItem in this.OrdenCurva FOXOBJECT
				if !empty(loItem.Color_PK)
					try
						if this.oColaboradorProduccion.EsComodinEnVariantePrincipal(loItem.Color_PK)
							llRetorno = .f.
						endif
					catch
					endtry 
				endif
				if !empty(loItem.Talle_PK)
					try
						if this.oColaboradorProduccion.EsComodinEnVarianteSecundaria(loItem.Talle_PK)
							llRetorno = .f.
						endif
					catch
					endtry 
				endif
			next
			if llRetorno = .f.
				this.AgregarInformacion( 'No puede usar colores o talles genéricos en la curva de producción.' )
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoConfirmarCambio( tcMensajeDeConfirmacion as String, tcTitulo as String ) as Void
*!*	 --> Evento para bindearse en el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarOrdenEnBaseAModeloYCurva( tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Boolean
		local loCurvaDeProduccion as Collection, loItem as Object, llTieneCurvaEspecifica as Boolean, lcProceso as String, loError as Object, ;
				lcColor as String, lcTalle as String, lcColorComodin as String, lcTalleComodin as String
		local llRetornoInsumo as Boolean, llRetornoSalida as Boolean		
		llRetornoInsumo = .f.
		llRetornoSalida = .f.

		try
			loCurvaDeProduccion = this.oColaboradorProduccion.ObtenerInsumosDeCurvaDeProduccion(this.oModelo,tcVariantePrincipal,tcVarianteSecundaria)
			llRetornoInsumo = loCurvaDeProduccion.Count > 0
			this.eventoEnviarMensajeSinEspera( 'Cargando curva de producción ' + alltrim(tcVariantePrincipal) + "-" + alltrim(tcVarianteSecundaria))
			for each loItem in loCurvaDeProduccion
				this.OrdenInsumos.LimpiarItem()
				this.OrdenInsumos.oItem.Proceso_PK = loItem.Proceso_PK
				this.OrdenInsumos.oItem.Insumo_PK = loItem.Insumo_PK
				this.OrdenInsumos.oItem.ColorM_PK = iif(this.oColaboradorProduccion.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.ColorM_PK)
				this.OrdenInsumos.oItem.TalleM_PK = iif(this.oColaboradorProduccion.EsComodinEnVarianteSecundaria(loItem.TalleM_PK),tcVariantePrincipal,loItem.TalleM_PK)
				this.OrdenInsumos.oItem.Color_PK = iif(this.oColaboradorProduccion.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
				this.OrdenInsumos.oItem.Talle_PK = iif(this.oColaboradorProduccion.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVariantePrincipal,loItem.Talle_PK)
				this.OrdenInsumos.oItem.UnidadDeMedida_PK = alltrim(loItem.UnidadDeMedida_PK)
				this.OrdenInsumos.oItem.Cantidad = loItem.Cantidad
				this.OrdenInsumos.Actualizar()
			endfor
		catch to loError
		finally
			if !this.lCargandoCurva
				this.eventoEnviarMensajeSinEspera( '' )
			endif
		endtry
		
		try
			loCurvaDeProduccion = this.oColaboradorProduccion.ObtenerSalidasDeCurvaDeProduccion(this.oModelo,tcVariantePrincipal,tcVarianteSecundaria)
			llRetornoSalida = loCurvaDeProduccion.Count > 0
			this.eventoEnviarMensajeSinEspera( 'Cargando curva de producción ' + alltrim(tcVariantePrincipal) + "-" + alltrim(tcVarianteSecundaria))
			for each loItem in loCurvaDeProduccion
				this.OrdenSalidas.LimpiarItem()
				this.OrdenSalidas.oItem.Proceso_PK = loItem.Proceso_PK
				this.OrdenSalidas.oItem.SemiElaborado_PK = loItem.SemiElaborado_PK
				this.OrdenSalidas.oItem.ColorM_PK = iif(this.oColaboradorProduccion.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.ColorM_PK)
				this.OrdenSalidas.oItem.TalleM_PK = iif(this.oColaboradorProduccion.EsComodinEnVarianteSecundaria(loItem.TalleM_PK),tcVariantePrincipal,loItem.TalleM_PK)
				this.OrdenSalidas.oItem.Color_PK = iif(this.oColaboradorProduccion.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
				this.OrdenSalidas.oItem.Talle_PK = iif(this.oColaboradorProduccion.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVariantePrincipal,loItem.Talle_PK)
				this.OrdenSalidas.oItem.Cantidad = loItem.Cantidad
				this.OrdenSalidas.Actualizar()
			endfor
		catch to loError
		finally
			if !this.lCargandoCurva
				this.eventoEnviarMensajeSinEspera( '' )
			endif
		endtry
		this.EventoRefrescarGrilla('OrdenInsumos')
		this.EventoRefrescarGrilla('OrdenSalidas')

		return llRetornoInsumo or llRetornoSalida 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function QuitarCurvaDeOrden( tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Void
		local loItem as Object, lnItem as Integer
		try
			with this.OrdenInsumos
				for lnItem = .Count to 1 step -1
					loItem = .Item[lnItem]
					if loItem.ColorM_PK = tcVariantePrincipal and loItem.TalleM_PK = tcVarianteSecundaria
						.Quitar(lnItem)
					endif
				next
			endwith
		catch
		endtry
		try
			with this.OrdenSalidas
				for lnItem = .Count to 1 step -1
					loItem = .Item[lnItem]
					if loItem.ColorM_PK = tcVariantePrincipal and loItem.TalleM_PK = tcVarianteSecundaria
						.Quitar(lnItem)
					endif
				next
			endwith
		catch
		endtry
		this.EventoRefrescarGrilla('OrdenCurva')
		this.EventoRefrescarGrilla('OrdenInsumos')
		this.EventoRefrescarGrilla('OrdenSalidas')
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarOrdenDeModeloEspecificoSinCurva() as Void
		this.lCargandoCurva = .t.
		this.LlenarCurvaDeProduccion(this.OrdenCurva, this.oModelo )
		this.LlenarInsumosDeProduccion(this.OrdenInsumos, this.oModelo )
		this.LlenarSalidasDeProduccion(this.OrdenSalidas, this.oModelo )
		this.lCargandoCurva = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsModeloConCurvaEspecifica() as Boolean
		local lcUltimoProceso as String, loModelo as Object, llRetorno as Boolean, loItem as Object
		llRetorno = .t. && .f. && .t.
		lcUltimoProceso = this.ObtenerUltimoProceso(this.oModelo)
		for each loItem in this.oModelo.ModeloSalidas
			do case
			case !empty(loItem.ColorM_PK) 
				try
					if this.oColaboradorProduccion.EsColorGenerico( loItem.ColorM_PK )
						llRetorno = .f. &&  .t.
						exit
					endif
				catch
				endtry
			case !empty(loItem.TalleM_PK)
				try
					if this.oColaboradorProduccion.EsTalleGenerico( loItem.TalleM_PK )
						llRetorno = .f. && .t.
						exit
					endif
				catch
				endtry
			endcase
		next
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoEnviarMensajeSinEspera( tcMensaje as String) as Void
*!*			Evento para el kontroler
	endfunc 

	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		dodefault()
		if this.lEdicion and !this.lNuevo and !this.lAnular
			if !empty(this.Modelo_PK)
				this.oModelo = this.oColaboradorProduccion.ObtenerModeloDeProduccion( this.Modelo_PK )
			endif
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function _EsRegistroAnulable() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		dodefault()
		if this.esOrdenConGestionIniciada()
			lcMotivo = "No se puede anular una orden que tiene gestión(es) de producción asociadas."
		endif
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "El registro de la entidad " + ;
				alltrim( this.cDescripcion ) + " no puede ser anulado,"  + chr(10) + lcMotivo )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function _EsRegistroEliminable() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		dodefault()
		if this.esOrdenConGestionIniciada()
			lcMotivo = "No se puede eliminar una orden que tiene gestión(es) de producción asociadas."
		endif
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "El registro de la entidad " + ;
				alltrim( this.cDescripcion ) + " no puede ser eliminado." + chr(10) + lcMotivo )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function esOrdenConGestionIniciada() as Boolean
		local llRetorno as Boolean, lcSentencia as String, lcCodigo as String, lnCantidad as Integer
		llRetorno = .f.
		lcCodigo = this.Codigo
		text to lcSentencia textmerge noshow
			select count(*) cantidad
			 from <<this.oAd.cEsquema>>.ORDENPROD op 
			   where op.codigo = '<<lcCodigo>>' and (
			   '<<lcCodigo>>' in (select gp.ORDENDEPRO from <<this.oAd.cEsquema>>.GESTIONPROD gp) or
			   '<<lcCodigo>>' in (select fp.ORDENPROD from <<this.oAd.cEsquema>>.FINALPROD fp))
		endtext
		
		lcCurVal  = "c_" + sys(2015)
		goServicios.Datos.EjecutarSentencias( lcSentencia , "ORDENPROD,GESTIONPROD,FINALPROD" , "", lcCurVal, this.DataSessionId )
		
		lnCantidad = &lcCurVal..Cantidad
		llRetorno = lnCantidad > 0
		use in &lcCurVal
		return llRetorno
	EndFunc 

enddefine
