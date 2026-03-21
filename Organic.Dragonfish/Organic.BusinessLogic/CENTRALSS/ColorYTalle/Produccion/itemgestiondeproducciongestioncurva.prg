define class ItemGestiondeproduccionGestionCurva as din_ItemGestiondeproduccionGestionCurva of din_ItemGestiondeproduccionGestionCurva.prg

	#if .f.
		local this as ItemGestiondeproduccionGestionCurva of ItemGestiondeproduccionGestionCurva.prg
	#endif

	oEntidad = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad As Object ) as Void
		This.oEntidad = toEntidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_CantProducida( txVal ) as Void
		dodefault( txVal )
		if this.lLimpiando or this.lDestroy
		else
			if !this.lCargando
				this.EventoRecalcularInsumosSegunItemActivoSalida()
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoRecalcularInsumosSegunItemActivoSalida( ) as Void
	endfunc	

	*-----------------------------------------------------------------------------------------
	function Setear_CantDescarte( txVal ) as Void
		dodefault( txVal )
		if this.lLimpiando or this.lDestroy
		else
			if !this.lCargando
				this.EventoRecalcularDescartesSegunItemActivoSalida()
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoRecalcularDescartesSegunItemActivoSalida( ) as Void
	endfunc	

	*--------------------------------------------------------------------------------------------------------
	function Cantproducida_Assign( txVal as variant ) as void
		local llContinuar as Boolean, lxVal as Variant, lxValOld As Variant
		lxValOld = this.CantProducida
		lxVal = txVal
		llContinuar = .t.
		if lxValOld != lxVal and lxValOld <> 0
			llContinuar = this.VerificarContinuarSiHaySalidasMultiples()
		endif
		if llContinuar
			dodefault( lxVal )
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function CantDescarte_Assign( txVal as variant ) as void
		local llContinuar as Boolean, lxVal as Variant, lxValOld As Variant
		lxValOld = this.CantDescarte
		lxVal = txVal
		llContinuar = .t.
		if lxValOld != lxVal
			llContinuar = this.VerificarContinuarSiHaySalidasMultiples()
		endif
		if llContinuar
			dodefault( lxVal )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarContinuarSiHaySalidasMultiples() as Boolean
		local llContinuar as Boolean
		llContinuar = .t.
		if This.CargaManual() ;
		 and this.oEntidad.ExistenSalidasMultiplesEnElProceso( this.Articulo_PK, this.ColorM_PK, this.TalleM_PK ) ;
		 and !this.oEntidad.lYaHizoLaPreguntaDeSalidasMultiples
			this.EventoPedirConfirmacionSalidasMultiples()
			llContinuar = this.oEntidad.lContinuarActualizacionInsumosConSalidasMultiples
			if llContinuar
				this.oEntidad.lYaHizoLaPreguntaDeSalidasMultiples = .t.							
			endif
		endIf
		return llContinuar
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPedirConfirmacionSalidasMultiples() as Void
	endfunc 

enddefine
