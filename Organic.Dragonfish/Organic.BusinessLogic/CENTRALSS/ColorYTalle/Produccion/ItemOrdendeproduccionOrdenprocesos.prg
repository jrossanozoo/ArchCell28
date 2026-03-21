define class ItemOrdendeproduccionOrdenprocesos as Din_ItemOrdendeproduccionOrdenprocesos of Din_ItemOrdendeproduccionOrdenprocesos.PRG

	#if .f.
		local this as ItemOrdendeproduccionOrdenprocesos of ItemOrdendeproduccionOrdenprocesos.prg
	#endif

	oDetalle = null

	*-----------------------------------------------------------------------------------------
	function InyectarDetalle( toDetalle as detalle OF detalle.prg) as Void
		this.oDetalle = toDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_Proceso( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = this.EsModoEdicion() and dodefault( txVal, txValOld ) and this.ValidarProcesoEnModelo( txVal )
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarProcesoEnModelo( txVal as variant ) as Boolean
		local llRetorno as Boolean. loModelo as Object, loItem as Object
		if !empty(txVal) and this.oDetalle.oEntidad.EsModoEdicion()
			llRetorno = .f.
			loModelo = _Screen.Zoo.InstanciarEntidad( "ModeloDeProduccion" )
			try
				loModelo.Codigo = this.oDetalle.oEntidad.Modelo_PK
				for each loItem in loModelo.ModeloProcesos FOXOBJECT
					if loItem.Proceso_PK = txVal
						llRetorno = .t.
						exit
					endif
				endfor
			catch
			endtry
			loModelo.Release()
			if !llRetorno
				goServicios.Errores.LevantarExcepcion( "El proceso debe formar parte del modelo" )
			endif
		else
			llRetorno = .t.
		endif
		Return llRetorno
	endfunc 

enddefine
