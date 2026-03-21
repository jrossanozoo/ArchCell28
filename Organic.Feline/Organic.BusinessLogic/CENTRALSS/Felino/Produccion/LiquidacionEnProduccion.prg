define class LiquidacionEnProduccion As Entidad Of Entidad.prg

	#If .F.
		Local This As LiquidacionEnProduccion As LiquidacionEnProduccion.prg
	#Endif

	oColaboradorProduccion = null

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorProduccion_Access() as variant
		if this.ldestroy
		else
			if ( !vartype( this.oColaboradorProduccion ) = 'O' or isnull( this.oColaboradorProduccion ) )
				this.oColaboradorProduccion = _Screen.zoo.CrearObjetoPorProducto( 'ColaboradorProduccion' )
			endif
		endif
		return this.oColaboradorProduccion
	endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		function Nuevo() as Void
*!*			if this.esEntidadValidaParaEdicion()
*!*				dodefault() 
*!*				this.ValidarPedirCotizacionObligatoria( this.Fecha )
*!*			endif
*!*		endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		function Modificar() as Void
*!*			if this.esEntidadValidaParaEdicion()
*!*				dodefault()
*!*			endif
*!*		endfunc

	*-----------------------------------------------------------------------------------------
	function EsModoEdicion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.CargaManual() and (this.EsNuevo() or this.EsEdicion())
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoEnviarMensajeSinEspera( tcMensaje as String) as Void
*!*			Evento para el kontroler
	endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		Protected function esEntidadValidaParaEdicion() as Boolean
*!*			local llRetorno as Boolean
*!*			llRetorno = _Screen.Zoo.nVersionSQLNo > 2008 or _Screen.Zoo.nVersionSQLNo = 0
*!*			if !llRetorno
*!*				lcMensaje = "Para usar el módulo de liquidación de costos en producción debe tener el motor de SqlServer 2022 o superior."
*!*				goServicios.Errores.LevantarExcepcion( lcMensaje )
*!*			endif
*!*			return llRetorno
*!*		EndFunc 


enddefine
