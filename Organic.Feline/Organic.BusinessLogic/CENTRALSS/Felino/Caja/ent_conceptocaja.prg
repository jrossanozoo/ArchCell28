define class ent_ConceptoCaja as Din_EntidadConceptoCaja of Din_EntidadConceptoCaja.prg

	#if .f.
		Local this as ent_ConceptoCaja as ent_ConceptoCaja.prg
	#endif

	#define TIPOMOVIMIENTOENTRADA			1
	#define TIPOMOVIMIENTOSALIDA			2

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.BindearEvento( this , "Nuevo" , This, "HabilitarSugerirCajaDestino" )
		This.BindearEvento( this , "Modificar" , This, "HabilitarSugerirCajaDestino" )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function HabilitarSugerirCajaDestino() as Void
		if this.tipo = 2
			this.lHabilitarCajaDestino_pk = .t.
		else
			this.lHabilitarCajaDestino_pk = .f.
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		Local llRetorno as boolean
		llRetorno = .T.

		llRetorno = dodefault()

		if This.ValidarConsistenciaCheques()
		else
			llRetorno = .F.
			this.AgregarInformacion( 'El tipo sugerido es incorrecto para el estado del cheque', 0 )
		EndIf
		return llRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarConsistenciaCheques() as Boolean
		local llRetorno as Boolean, loColaboradorCheques as Boolean
		llRetorno = .t.
		if !empty(this.EstadoCheque)
			loColaboradorCheques = _screen.zoo.CrearObjeto( "colaboradorCheques", "colaboradorCheques.PRG" )
			if this.Tipo # loColaboradorCheques.ObtenerTipoMovimiento( this.EstadoCheque )
				llRetorno = .f.
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DespuesDeSetearEstadoDeCheque() as Void
		local loColaboradorCheques as Boolean, lnTipoMovimiento as Integer
		if !empty(this.EstadoCheque)
			loColaboradorCheques = _screen.zoo.CrearObjeto( "colaboradorCheques", "colaboradorCheques.PRG" )
			lnTipoMovimiento = loColaboradorCheques.ObtenerTipoMovimiento( this.EstadoCheque )
			if inlist(lnTipoMovimiento,TIPOMOVIMIENTOENTRADA,TIPOMOVIMIENTOSALIDA)
				this.lHabilitarTipo = .t.
				this.Tipo = lnTipoMovimiento
				this.lHabilitarTipo = .f.
			else
				this.lHabilitarTipo = .t.
			endif
		else
			this.lHabilitarTipo = .t.
		endif
	endfunc 

enddefine 
