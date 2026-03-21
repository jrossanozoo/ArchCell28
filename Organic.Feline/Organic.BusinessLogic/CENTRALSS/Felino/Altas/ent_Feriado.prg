define class ent_Feriado as din_entidadferiado of din_entidadferiado.prg

	#IF .f.
		Local this as ent_Feriado of ent_Feriado.prg
	#ENDIF

	*--------------------------------------------------------------------------------------------------------
	function anio_Assign( txVal as variant ) as void
		local llConsulta as Boolean, llNuevo as boolean, llEdicion as boolean

		lxValOld = this.anio
		
		try	
			dodefault( txVal ) 
		catch to loError
			if this.EsExcepcionCodigoYaExiste( txVal, loError )
				goServicios.Errores.LevantarExcepcion( 'El año ' + alltrim( transform( txVal ) ) + ' ya fue cargado.' )
			else
				goServicios.Errores.LevantarExcepcion( loError )
			endif
		endtry
		
		if !empty( txVal ) and ( this.lEdicion or this.lNuevo )
			this.ActualizarFechasCargadas()
			if txVal != lxValOld
				this.EventoCambioAnio( txVal )
			endif
		endif
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarFechasCargadas() as Void
		local lnI as Integer, ldFecha as Date

		for lnI = 1 to This.DetalleFechas.Count
			ldFecha = This.DetalleFechas.Item[lnI].Fecha
			if !empty( ldFecha )
				try
					This.DetalleFechas.Item[lnI].Fecha = date( this.Anio, month( ldFecha ), day( ldFecha ) )
				catch to loError
					goServicios.Errores.LevantarExcepcion( "Problemas con fecha " + dtoc( ldFecha ) )
				endtry
			endif
		endfor
		
		this.EventoCambioDetalle()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsExcepcionCodigoYaExiste( txVal as variant, toError as Exception ) as Boolean
		local llRetorno as Boolean

		llRetorno = .f.
		
		try
			if toError.UserValue.oInformacion.Item[1].cMensaje = 'El código ' + alltrim( transform( txVal ) ) + ' ya existe.'
				llRetorno = .t.
			else
			endif
		catch
		endtry

		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Limpiar( tlForzar as boolean ) as void
		dodefault( tlForzar )

		with this
			.lEstaSeteandoValorSugerido = .T.
			if .EsNuevo()
				this.Anio = this.ObtenerNuevoAnio()
			endif
			.lEstaSeteandoValorSugerido = .F.
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNuevoAnio() as Integer
		local lnRetorno as Integer, lcCursor as String, lcXml as String, lcCursorHuecos as String

		lnRetorno = year( goLibrerias.ObtenerFecha() )

		lcCursor = sys(2015)
		lcXml = this.oAd.ObtenerDatosEntidad( "Anio", "Anio >= " + goLibrerias.ValorAStringSqlServer( year( goLibrerias.ObtenerFecha() ) ) )

		this.XmlACursor( lcXml, lcCursor ) 

		lcCursorHuecos = sys(2015)

		select anio1.anio + 1 as anio1_anio, anio2.anio as anio2_anio from &lcCursor as anio1 ;
			left join &lcCursor as anio2 on anio1.anio + 1 = anio2.anio ;
			where nvl( anio2.anio, 0 ) = 0 ;
			into cursor &lcCursorHuecos
			
		if reccount( lcCursorHuecos ) > 0
			select ( lcCursorHuecos )
			go top
			lnRetorno = &lcCursorHuecos..anio1_anio
		endif

		return lnRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteFeriado( tdFecha as Date ) as Boolean
		local lcCursor as String, lcFecha as String, lcXml as String

		lcCursor = sys(2015)
		
		lcFecha = golibrerias.ValorAStringSegunTipoBase( tdFecha )
		
		lcXml = this.oAd.ObtenerDatosDetalleDetalleFechas( "Fecha", "FECHA = " + lcFecha )
		
		this.XmlACursor( lcXml, lcCursor ) 
		
		return ( reccount( lcCursor ) > 0 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoCambioAnio( tnAnio as Integer ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCambioDetalle() as Void
	endfunc 
	
enddefine
