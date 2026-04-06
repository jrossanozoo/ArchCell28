define class componentecomunicacion as din_componentecomunicacion of din_componentecomunicacion.prg

	oDetalle = Null
	cCliente = ''
	
	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg
		local loColeccion as zoocoleccion OF zoocoleccion.prg

		loColeccion = This.ObtenerSentenciasUpdateGrupo()
		goParametros.Zl.ValoresSugeridos.ClienteSugeridoIS = ""
				
		return loColeccion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasUpdateGrupo() as zoocoleccion OF zoocoleccion.prg

		local loCol as zoocoleccion OF zoocoleccion.prg
		loCol = _screen.zoo.crearobjeto( "zoocoleccion" )
		try
			for each loItem in This.oDetalle
				lnCodigoGrupo = loItem.Grupo_Pk
				if This.ClientePerteneceAlGrupo( lnCodigoGrupo )
				else
					with This.oGrupoComunicacion
						.Codigo = lnCodigoGrupo
						.Modificar()
						with .GrupoClientes
							.LimpiarItem()
							.oItem.CodCli_Pk = This.cCliente
							.Actualizar()
						endwith
					endwith
				endif
			endfor
			loCol = This.oGrupoComunicacion.oAd.ObtenerSentenciasUpdate()

		catch to loError
		finally
			if this.ogrUPOCOMUNICACION.esedicion() or this.ogrUPOCOMUNICACION.esnuevo()
				This.oGrupoComunicacion.Cancelar()
			endif
		EndTry
			
		return loCol
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ClientePerteneceAlGrupo( tnCodigoGrupo as Integer ) as Boolean
		local llRetorno as Boolean

		llRetorno = .F.
		this.oGrupoComunicacion.Codigo = tnCodigoGrupo
		
		if upper( alltrim( This.cCliente ) ) $ upper( alltrim( this.ogrupocomunicacion.CodCli ) )
			llRetorno = .T.
		endif
		return llRetorno
	endfunc 

enddefine
