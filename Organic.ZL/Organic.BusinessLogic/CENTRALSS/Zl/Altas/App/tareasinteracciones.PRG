define class TareasInteracciones as zoosession of zoosession.prg

	*-----------------------------------------------------------------------------------------
	function CargarDetalleTareasInteracciones( toEntidad as Object ) as Void
		local lNumeroTarea as Number, lcCursor as String

		lNumeroTarea = evaluate( "toEntidad." + toEntidad.ObtenerAtributoClavePrimaria() )
		lcCursor = this.ObtenerInteracciones( lNumeroTarea )
		lnI = 1

		with toEntidad.DetalleInteraccionesTareas
			.Limpiar()
			if used( lcCursor ) and reccount( lcCursor ) > 0
				select( lcCursor )
				scan
					loItem = .CrearItemAuxiliar()
					with loItem
						.NroItem 		= lnI
						.Numero_pk 		= &lcCursor..NUMERO
						.Fecha			= ttod( &lcCursor..FECHA )
						.Tipo_pk		= &lcCursor..TIPO
						.Contacto_pk	= &lcCursor..CONTACTO
						.IdTecnovoz		= &lcCursor..IDTECNOVOZ
						.Ualtafw		= &lcCursor..UALTAFW
						.Notas			= &lcCursor..NOTAS
					endwith
					.add( loItem )
					lnI = lnI + 1
				endscan
			endif
			.CambioSumarizado()
			.Sumarizar()
		endwith

		use in select( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerInteracciones( tnTarea as Number ) as String
		local lcCursor as String, lcSQL as String, loItem as object, lnI as integer

		lcCursor  = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			select NUMERO, FECHA, TIPO, CONTACTO, IDTECNOVOZ, UALTAFW, NOTAS
			from ZL.INTERACCLI
			where TAREA = <<transform(tnTarea)>>
			order by NUMERO desc
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "Datasession" ) )

		return lcCursor
	endfunc

enddefine
