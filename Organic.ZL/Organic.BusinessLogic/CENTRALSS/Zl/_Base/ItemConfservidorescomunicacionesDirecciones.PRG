define class ItemConfservidorescomunicacionesDirecciones as Din_ItemConfservidorescomunicacionesDirecciones of Din_ItemConfservidorescomunicacionesDirecciones.prg
	#if .f.
		local this as ItemConfservidorescomunicacionesDirecciones of ItemConfservidorescomunicacionesDirecciones.prg
	#endif


	*-----------------------------------------------------------------------------------------
	protected function AsignarTipoVisual() as Void
		if !empty( this.EntDireccion_PK )
			do case
				case this.Tipo = 1
					this.TipoV = "Llaves"
				case this.Tipo = 2
					this.TipoV = "Retorno"
				case this.Tipo = 3
					this.TipoV = "Estadísticas"
				case this.Tipo = 4
					this.TipoV = "Versión"
				case this.Tipo = 5
					this.TipoV = "Llaves/Credenciales"
				otherwise
					this.TipoV = "Desconocido"
			endcase
		endif
	endfunc

enddefine
