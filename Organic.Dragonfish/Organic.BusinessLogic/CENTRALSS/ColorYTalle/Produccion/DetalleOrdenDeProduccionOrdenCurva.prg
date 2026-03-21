define class DetalleOrdenDeProduccionOrdenCurva as din_DetalleOrdenDeProduccionOrdenCurva of din_DetalleOrdenDeProduccionOrdenCurva.prg

	#if .f.
		local this as DetalleOrdenDeProduccionOrdenCurva of DetalleOrdenDeProduccionOrdenCurva.prg
	#endif

	#define OKORCANCEL 1

	*--------------------------------------------------------------------------------------------------------
	Function Actualizar( tcClave as String ) as Void
		local loInformacion as Object, lcMensaje as String, lnNroItem as Integer
		if this.oEntidad.EsModoEdicion()
			if empty(this.oItem.Producto_PK)
				if this.oItem.estaEliminando
				endif
			else
				loInformacion = _Screen.zoo.crearobjeto( "zooInformacion" )
				if this.oItem.Color.EsComodinEnProduccion or this.oItem.Talle.EsComodinEnProduccion
					loInformacion.AgregarInformacion('No esta permitido usar comodines en las variantes de la curva de produccion.')
				endif
				if this.oItem.Cantidad < 1
					loInformacion.AgregarInformacion('Debe cargar un cantidad positiva para producir.')
				endif
				if loInformacion.Count > 1
					loInformacion.AgregarInformacion('Hay errores en el item de la curva a producir.')
				endif
				if loInformacion.Count > 0
					goServicios.Errores.LevantarExcepcion(loInformacion)
				endif
				if !this.ValidarCurvaUnica()
					goServicios.Errores.LevantarExcepcion("La curva ya existe en la lista.")
				endif
				if !this.oEntidad.lCargandoCurva

					if this.oItem.estaEliminando
						this.eventoQuitarCurvaDeOrden(alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Color_PK),alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Talle_PK))
					endif
					if this.oItem.esCurvaNueva
						this.eventoArmarOrdenEnBaseACurva(alltrim(this.oItem.Color_PK),alltrim(this.oItem.Talle_PK))
					else
						if this.oItem.NroItem > 0
							if this.esCambioDeCurvaDeProduccion()
								lnNroItem = this.oItem.NroItem
								this.eventoQuitarCurvaDeOrden(alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Color_PK),alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Talle_PK))
								this.eventoArmarOrdenEnBaseACurva(alltrim(this.oItem.Color_PK),alltrim(this.oItem.Talle_PK))
							endif
						else
							this.eventoArmarOrdenEnBaseACurva(alltrim(this.oItem.Color_PK),alltrim(this.oItem.Talle_PK))
						endif
					endif
				endif
			endif
		endif
		DoDefault( tcClave )
		this.oItem.esCurvaNueva = .f.
		this.oItem.estaEliminando = .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function esCambioDeCurvaDeProduccion() as Boolean
		local llRetorno as Boolean, lnNroItem as Integer
		llRetorno = .f.
		if this.oItem.NroItem # 0 
			lnNroItem = this.oItem.NroItem
			if !empty(this.oEntidad.OrdenCurva.Item[lnNroItem].Producto_PK) and alltrim(this.oItem.Producto_PK) != alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Producto_PK) or ;
					alltrim(this.oItem.Color_PK) != alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Color_PK) or ;
					alltrim(this.oItem.Talle_PK) != alltrim(this.oEntidad.OrdenCurva.Item[lnNroItem].Talle_PK)
				llRetorno = .t.
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCurvaUnica() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .t.
		for each loItem in this.oEntidad.OrdenCurva FOXOBJECT
			do case
			case this.oItem.NroItem = 0 and ;
					alltrim(this.oItem.Producto_PK) = alltrim(loItem.Producto_PK) and ;
					alltrim(this.oItem.Color_PK) = alltrim(loItem.Color_PK) and ;
					alltrim(this.oItem.Talle_PK) = alltrim(loItem.Talle_PK)
				llRetorno = .f.
				exit
			case this.oItem.NroItem != 0 and this.oItem.NroItem != loItem.NroItem and ;
					alltrim(this.oItem.Producto_PK) = alltrim(loItem.Producto_PK) and ;
					alltrim(this.oItem.Color_PK) = alltrim(loItem.Color_PK) and ;
					alltrim(this.oItem.Talle_PK) = alltrim(loItem.Talle_PK)
				llRetorno = .f.
				exit
			endcase
		endfor
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoArmarOrdenEnBaseACurva( tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Void
*!*			Evento de entidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoQuitarCurvaDeOrden( tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Void
*!*			Evento de entidad
	endfunc 

enddefine
