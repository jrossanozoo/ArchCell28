define class ItemPRIORIZACIONDEPROYECTOSDetalleorden as Din_ItemPRIORIZACIONDEPROYECTOSDetalleorden of Din_ItemPRIORIZACIONDEPROYECTOSDetalleorden.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerSeguimYAvance() as Void
		with this
			if empty( .NumAvance_pk )
				.NumAvance_pk = .Proyecto.ObtenerNumAvance()
			endif
		endwith
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Proyecto_PK_Assign( txVal as variant ) as void
		dodefault( txVal )
		goParametros.Zl.ValoresSugeridos.ProyectoSugeridoDesdePriorizacionDeProyectosASeguimiento = txVal
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarSeguimProyecto() as Boolean
		local llRetorno as Boolean, lcSQL as String , lcCursor as String

		goParametros.Zl.ValoresSugeridos.ProyectoSugeridoDesdePriorizacionDeProyectosASeguimiento = this.Proyecto_pk

		llRetorno = .t.
		if this.Seguim_pk <> 0
			lcCursor = 'C' + sys( 2015 )
			text to lcSQL textmerge noshow
				select Proyecto from ZL.SEGUIMPROY where Proyecto = '<<this.Proyecto_pk>>' and Numero = '<<this.Seguim_pk>>'
			endtext

			goServicios.Datos.EjecutarSentencias( lcSQL, "", "", lcCursor, set( "datasession" ) )
			if ( used( lcCursor ) and reccount( lcCursor ) > 0 )
				llRetorno = .t.
			else
				goServicios.Errores.LevantarExcepcion( "El seguimiento " + alltrim( str( this.Seguim_pk ) ) + " no corresponde al proyecto " + alltrim( str( this.Proyecto_pk ) ) + "." )
				llRetorno = .f.
			endif
			use in select( lcCursor )
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAvanceProyecto() as Void
		local llRetorno as Boolean, lcSQL as String , lcCursor as String

		goParametros.Zl.ValoresSugeridos.ProyectoSugeridoDesdePriorizacionDeProyectosAGradoDeAvance = this.Proyecto_pk

		llRetorno = .t.
		if this.NumAvance_pk <> 0
			lcCursor = 'C' + sys( 2015 )
			text to lcSQL textmerge noshow
				select Proyecto from ZL.GRADOAVANCE where Proyecto = '<<this.Proyecto_pk>>' and Numero = '<<this.NumAvance_pk>>'
			endtext

			goServicios.Datos.EjecutarSentencias( lcSQL, "", "", lcCursor, set( "datasession" ) )
			if ( used( lcCursor ) and reccount( lcCursor ) > 0 )
				llRetorno = .t.
			else
				goServicios.Errores.LevantarExcepcion( "El grado de avance " + alltrim( str( this.NumAvance_pk ) ) + " no corresponde al proyecto " + alltrim( str( this.Proyecto_pk ) ) + "." )
				llRetorno = .f.
			endif
			use in select( lcCursor )
		endif

		return llRetorno
	endfunc

enddefine
