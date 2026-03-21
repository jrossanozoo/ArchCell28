Define Class EntColorYTalle_ComprobanteDeVentasConValores as Ent_ComprobanteDeVentasConValores of Ent_ComprobanteDeVentasConValores.prg

	#if .f.
		local this as EntColorYTalle_ComprobanteDeVentasConValores of EntColorYTalle_ComprobanteDeVentasConValores.prg
	#endif

	lItemControlaDisponibilidad = .T.
	lComprobanteDebeValidarDevolucionDeArticulo = .T.
	
	*-----------------------------------------------------------------------------------------
	Function Inicializar() as Void
		Dodefault()
		if Type("This.FacturaDetalle" ) = "O"
			This.BindearEvento( This.FacturaDetalle, "EventoVerificarValidezArticulo" , This, "EventoVerificarExistenciaGrupo" ) 
		endif
		this.lIncorporarControlDeStockEnFacturasConEntregaPosterior = goParametros.ColorYTalle.GestionDeVentas.IncorporarControlDeStockEnFacturasConEntregaPosterior
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerNombresValidadores() as zoocoleccion 
		Local loNombreDeValidadores as zoocoleccion OF zoocoleccion.prg
		
		loNombreDeValidadores = dodefault()
		loNombreDeValidadores.Add( "ValidadorComprobanteConValores_Grupo" )

		Return loNombreDeValidadores
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function EventoVerificarExistenciaGrupo( toArticulo as entidad OF entidad.prg ) as Boolean
		Return This.oValidadores.VALIDADORCOMPROBANTECONVALORES_GRUPO.EventoVerificarExistenciaGrupo( toArticulo )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ControlaStockDisponible() as Boolean
		Local llRetorno as Boolean
		llRetorno = goParametros.Felino.Generales.HabilitaControlStock and ( goParametros.ColorYTalle.GestionDeVentas.ControlStockDisponibleFacturacion == 2 )
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AdvierteStockDisponible() as Boolean
		Local llRetorno as Boolean
		llRetorno = goParametros.Felino.Generales.HabilitaControlStock and ( goParametros.ColorYTalle.GestionDeVentas.ControlStockDisponibleFacturacion == 3 )
		Return llRetorno
	Endfunc

Enddefine
