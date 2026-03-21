define class DetalleProduccionColorYTalle as DetalleBaseProduccion of DetalleBaseProduccion.prg

	#If .F.
		Local This As DetalleProduccionColorYTalle As DetalleProduccionColorYTalle.prg
	#Endif
	
	lUsaClaveEnItem = .f.

	*-----------------------------------------------------------------------------------------
	function AgregarItemPlano( toItem as Object ) as Void
		local lcClave as String
		if this.lUsaClaveEnItem
			lcClave = toItem.ObtenerClaveParaItem()
			if empty( lcClave )
				dodefault( toItem )
			else
				with this
					if .ValidarCantidadItems() 
						.add( toItem, lcClave  )
					else
						goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
					endif
				endwith
			endif
		else
			dodefault( toItem )
		endif
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		protected function ObtenerClaveParaItem( toItem as Object ) as String
*!*			local lcRetorno as String
*!*			lcRetorno = ''
*!*			return lcRetorno
*!*		endfunc 

enddefine
