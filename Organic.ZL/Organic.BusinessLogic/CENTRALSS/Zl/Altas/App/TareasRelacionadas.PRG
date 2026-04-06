define class TareasRelacionadas as zoosession of zoosession.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerTareasRelacionadasAEntidades( tnTarea as Number ) as String
		local lcCursor as String, lcSQL as String, loItem as object, lnI as integer
		 
		lcCursor  = 'C' + sys( 2015 ) 
		text to lcSQL textmerge noshow
			select  
					Entidad as Entidad,
					Numero AS Numero, 
					fechaDeAlta as fechaDeAlta
				from ZL.TareasYSusEntidadesAsociadas( <<transform(tnTarea)>> )
				order by fechaDeAlta DESC
		endtext
		
		goServicios.Datos.EjecutarSql( lcSQL , lcCursor, set("Datasession") )
			
		return lcCursor

	endfunc 	

	*-----------------------------------------------------------------------------------------
	function CargarDetalleTareasRelacionadas( toEntidad as Object ) as Void
		local lNumeroTarea as Number, lcCursor as String 
	
		lNumeroTarea = evaluate( "toEntidad." + toEntidad.obteneratributoclaveprimaria() ) &&toEntidad.Numero  &&Cambiar para Obtener el atributo claveprimaria de la ent para que no este duranga.
		
		lcCursor = this.ObtenerTareasRelacionadasAEntidades( lNumeroTarea )

		lnI = 1

		with toEntidad.DetalleTareasAsociadas
			.Limpiar()

			if used( lcCursor ) and reccount( lcCursor ) > 0
				select( lcCursor )		
				scan
					loItem = .CrearItemAuxiliar()
					with loItem
						.NroItem 		= lnI 
						.Entidad 	= &lcCursor..Entidad
						.Numero		= &lcCursor..Numero 
						.fecha		= ttod(&lcCursor..fechaDeAlta)
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

enddefine 
