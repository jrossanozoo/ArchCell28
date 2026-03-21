Define Class kontrolerRedondeodeprecios As din_kontrolerredondeodeprecios of din_kontrolerredondeodeprecios.prg 

	#IF .f.
		Local this as kontrolerRedondeodeprecios of kontrolerRedondeodeprecios.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		DoDefault()
		This.SetearComboRedondeoNormal()
		This.Enlazar( "oEntidad.EventoActualizarPreview", "ActualizarPreview" )

		bindevent( this.oEntidad.DetRedondeoPorTabla, "EventoCambioEnDetalle", this, "ActualizarPreview", 1 )
		bindevent( this.oEntidad.DetRedondeoPorEntero, "EventoCambioEnDetalle", this, "ActualizarPreview", 1 )
		bindevent( this.oEntidad.DetRedondeoPorCentavo, "EventoCambioEnDetalle", this, "ActualizarPreview", 1 )

		bindevent( this.oEntidad.DetRedondeoPorTabla, "CambioSumarizado", this, "ActualizarPreview", 1 )
		bindevent( this.oEntidad.DetRedondeoPorEntero, "CambioSumarizado", this, "ActualizarPreview", 1 )
		bindevent( this.oEntidad.DetRedondeoPorCentavo, "CambioSumarizado", this, "ActualizarPreview", 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearComboRedondeoNormal() as Void
		Local loControl as Object
	
		loControl = this.ObtenerControl( "RedondeoNormal" )
		This.SetearCombo( loControl )
		
		loControl = this.ObtenerControl( "Redondeoportabla" )
		This.SetearCombo( loControl )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearCombo( loCombo as Object ) as Void

		With loCombo
			.AddItem( "Hacia arriba" )
			.AddItem( "Hacia abajo" )				
			.AddItem( "Normal" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarGrillaPreview() as Void
		local loGrilla as zooGrillaExtensible of zooGrillaExtensible.prg

		loGrilla = This.ObtenerControl( "DetPrueba" )
		loGrilla.RefrescarGrilla()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function ActualizarPreview( tcAtributo As String, toItem as object ) as Void
		local loItem as Object, loControl as zooGrillaExtensible as zooGrillaExtensible.prg
				
		if this.oEntidad.CargaManual()
			for each loItem in This.oEntidad.DetPrueba foxObject
				loItem.Resultado = This.oEntidad.Redondear( loItem.Precio )
			endfor

			This.ActualizarGrillaPreview()
		endif
	endfunc 

Enddefine
