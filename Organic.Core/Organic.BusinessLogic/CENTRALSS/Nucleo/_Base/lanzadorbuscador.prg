define class LanzadorBuscador as custom

	#IF .f.
		Local this as LanzadorBuscador of LanzadorBuscador.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Lanzar( toKontroler as object, toFormulario as form, tlClaveCandidata as Boolean ) as Void
		local lxVal as Variant, loControl as zooTextBox of zooTextBox.prg, loError as exception

		if toKontroler.ExisteControl( "Entidad" )
			loControl = toKontroler.ObtenerControl( "Entidad" )

			with loControl
				lxVal = .xValorAnterior
				try
					goControles.Buscar( toFormulario, loControl, "?", "", tlClaveCandidata )
					if tlClaveCandidata 
						if this.SeCompletoLaClaveCandidata( toFormulario.oEntidad )
							this.Buscar( toFormulario.oEntidad )
						endif
					else
						.Valid()
					endif
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.xValorAnterior = lxVal

					toKontroler.cEstado = "NULO"
					toKontroler.ActualizarFormulario()
					toKontroler.ActualizarBarra()
				endtry
			endwith
		else
			goServicios.Mensajes.Alertar( "Error al buscar" )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SeCompletoLaClaveCandidata( toEntidad as Object ) as Boolean
		local lcAtributo as String, llEstaVacia as Boolean
		
		llEstaVacia = .t.
		for each lcAtributo in toEntidad.oAtributosCC
			llEstaVacia = llEstaVacia and empty( toEntidad.&lcAtributo )
		endfor
		
		return !llEstaVacia
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function Buscar( toEntidad as Object ) as Void
		toEntidad.Buscar()
		toEntidad.Cargar()
	endfunc 
enddefine
