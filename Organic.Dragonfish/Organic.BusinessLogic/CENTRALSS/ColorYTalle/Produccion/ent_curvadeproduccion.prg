define class ent_CurvaDeProduccion as din_EntidadCurvaDeProduccion of din_EntidadCurvaDeProduccion.prg

	#If .F.
		Local This As ent_CurvaDeProduccion As ent_CurvaDeProduccion.prg
	#Endif

	oColaborador = null
	cPaletaAplicada = ''
	cCurvaAplicada = ''
	lCargandoDetalle = .f.
	lActualizarDetalle = .f.
	lDetalleConVariantePrincipal = .f.
	lDetalleConVarianteSecundaria = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		with this
			.Detalle.InyectarEntidad( This )
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

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean, lnIndex as Integer, loItem as Object
		llRetorno = dodefault()
		if llRetorno
			for lnIndex = this.Detalle.count to 1 step -1
				loItem = this.detalle.Item[lnIndex]
				if empty(loItem.Color_PK) and empty(loItem.Talle_PK)
					this.detalle.remove(lnIndex)
				endif
			endfor
		endif
		Return llRetorno
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Paletadecolores( txVal as variant ) as void
		local lcAnterior as String, lcNuevo as String, loItem as Object, loPaleta as Object, loCurva as Object
		dodefault( txVal )
		if this.lActualizarDetalle
			this.ActualizarDetalleConCombinaciones()
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Curvadetalles( txVal as variant ) as void
		local lcAnterior as String, lcNuevo as String, loItem as Object, loPaleta as Object, loCurva as Object
		dodefault( txVal )
		if this.lActualizarDetalle
			this.ActualizarDetalleConCombinaciones()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarDetalleConCombinaciones() as Void
		local loItemC as Object, loItemT as Object, loPaleta as Object, loCurva as Object, loError as Object
		if (!empty(this.PaletaDeColores_PK) and !empty(this.CurvaDeTalles_PK)) and ((upper(alltrim(this.cPaletaAplicada)) != upper(alltrim(this.PaletaDeColores_PK))) or ;
					(upper(alltrim(this.cCurvaAplicada)) != upper(alltrim(this.CurvaDeTalles_PK))))
			if this.Detalle.count > 0
				this.Detalle.Limpiar()
			endif
			loPaleta = _Screen.Zoo.InstanciarEntidad( "PaletaDeColores" )
			loCurva = _Screen.Zoo.InstanciarEntidad( "CurvaDeTalles" )
			this.eventoEnviarMensajeSinEspera( 'Generando la curva de producción.' )
			try
				loPaleta.Codigo = this.PaletaDeColores_PK
				loCurva.Codigo = this.CurvaDeTalles_PK
				for each loItemC in loPaleta.Colores FOXOBJECT
					for each loItemT in loCurva.Talles FOXOBJECT
						this.Detalle.LimpiarItem()
						this.Detalle.oItem.Color_PK = loItemC.Color_PK
						this.Detalle.oItem.Talle_PK = loItemT.Talle_PK
						this.Detalle.oItem.Cantidad = 1
						this.Detalle.Actualizar()
					next
				next
			catch to loError 
				loErr = loError
			endtry
			this.eventoEnviarMensajeSinEspera()

			loPaleta.Release()
			loCurva.Release()
			this.cPaletaAplicada = upper(alltrim(this.PaletaDeColores_PK))
			this.cCurvaAplicada = upper(alltrim(this.CurvaDeTalles_PK))
			this.eventoRefrescarDetalle( 'Detalle' )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoRefrescarDetalle( tcDetalle as String ) as Void
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Nuevo() As Boolean
		dodefault()
		this.cPaletaAplicada = ''
		this.cCurvaAplicada = ''
	Endfunc

	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		dodefault()
		this.cPaletaAplicada = upper(alltrim(this.PaletaDeColores_PK))
		this.cCurvaAplicada = upper(alltrim(this.CurvaDeTalles_PK))
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Paletadecolores( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		if this.EsModoEdicion()
			try
				this.lActualizarDetalle = .t.
				if !empty(txVal) and txVal != txValOld and !empty(this.CurvaDeTalles_PK) and this.Detalle.count > 0
					this.eventoMensajeConfirmar('Esta cambiando la curva de talles con definiciones cargadas. Se eliminaran las combinaciones y se cargaran las nuevas.', 'Ha cancelar el cambio' )
					this.lActualizarDetalle = .f.
				endif
				llRetorno = dodefault( txVal, txValOld )

			catch
				this.PaletaDeColores_PK = txValOld
			endtry
		else
			llRetorno = dodefault( txVal, txValOld )
		endif
		Return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Curvadetalles( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		if this.EsModoEdicion()
			try
				this.lActualizarDetalle = .t.
				if !empty(txVal) and txVal != txValOld and !empty(this.PaletaDeColores_PK) and this.Detalle.count > 0
					this.eventoMensajeConfirmar('Esta cambiando la curva de talles con definiciones cargadas. Se eliminaran las combinaciones y se cargaran las nuevas.', 'Ha cancelar el cambio' )
				endif
				llRetorno = dodefault( txVal, txValOld )
			catch
				this.CurvaDeTalles_PK = txValOld
			endtry
		else
			llRetorno = dodefault( txVal, txValOld )
		endif
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function eventoMensajeConfirmar( tcMensaje as String, tcMensajeCancelacion as String, tcAtributo as String, txValOld as variant ) as Void
&& Evento para que el kontroler muestre un mensaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ExisteCombinacion( tcColor as String, tcTalle as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if !empty(this.codigo)
			for each loComb in this.Detalle FOXOBJECT
				if loComb.Color_PK == tcColor and loComb.Talle_PK == tcTalle
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function EsModoEdicion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.CargaManual() and !this.EstaEnProceso() and (this.EsNuevo() or this.EsEdicion())
		return llRetorno
	endfunc 

enddefine
