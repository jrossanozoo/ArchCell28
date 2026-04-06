define class ColaboradorHoras as ZooSession of ZooSession.prg

	oEntidad = null
	cUsuario = ''
	
	*-------------------------------------------------------------------
	Function SeteosPrivados() as VOID 
		dodefault()
		this.cUsuario = goServicios.Seguridad.cUltimoUsuarioLogueado
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidad = toEntidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularDuracion() as String
		local lcRetorno as Boolean, lnDiff as Integer, lcHours as String, lcSeconds as String

		lnDiff = ctot( time() ) - ctot( this.oEntidad.cTimeInicial )
		lcHours = padl( alltrim( str( int( lnDiff / 3600 ) ) ), 2, "0" )
		lcMinutes = padl( alltrim( str( round( ( ( lnDiff - ( val( lcHours ) * 3600 ) ) / 60 ), 0 ) ) ), 2, "0" )
		lcRetorno = lcHours + ":" + lcMinutes

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarCargaAutomaticaHoras( tnTipoDeReunion as Integer, tnNumero as Integer ) as Void
		local lcSentencia as String
		lcSentencia = "exec [ZL].[sp_CargaAutomaticaDeHoras] " + transform( tnTipoDeReunion ) + ", " + transform( tnNumero )
		goDatos.EjecutarSentencias( lcSentencia, "", "", "", this.DataSessionId )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerHorasDiariasCargadasPorUsuario( tFecha as string ) as number
		local lcCursor as String, lcSQL as String, lcFecha as String, lnHoras AS Number  
		lcFecha =  tFecha
		lcCursor = "C" + sys( 2015 )
		lnHoras  = 0	
		text to lcSQL textmerge noshow 
			select 
					isnull(TotalHoras, 0 ) as TotalHoras    
				from  ZL.funcObtenerHorasDiariasCargadasPorUsuario( '<<alltrim(this.cUsuario)>>' , '<<lcFecha>>' )
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, this.DataSessionId )	
		if used( lcCursor ) and reccount( lcCursor ) > 0
			lnHoras = &lcCursor..TotalHoras  
		endif 	
		use in select( lcCursor )
		return lnHoras 
	endfunc 

enddefine
