define class Ent_Seguridadperfil as din_EntidadSeguridadperfil of din_EntidadSeguridadperfil.prg

	#if .f.
		local this as Ent_Seguridadperfil of Ent_Seguridadperfil.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		this.LlenarOperaciones()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LlenarOperaciones()
		local lcCursor as String, lcXml as string, loOperaciones as entidad OF entidad.prg, lcXml as string, lcCursorAct as string, lcXmlAct as string, ;
			lcAux as string, lcOpe as string, lnInd as integer, loItem as object, lni as integer
				
		lcCursor = sys( 2015 )
		lcCursorAct = sys( 2015 )
		lcAux = sys( 2015 )
		
		lcXmlAct = this.oAd.ObtenerDatosDetalleOperaciones( "Operacion", "cCod = '" + this.Codigo + "'")
		xmltocursor( lcXmlAct, lcCursorAct )		

		loOperaciones = _screen.zoo.instanciarentidad( "seguridadoperacion" )
		try
			lcXml = loOperaciones.oAd.ObtenerDatosEntidad()
			xmltocursor( lcXml, lcCursor )

			lni = 0
			
			**** Eliminamos los viejos
			select Perf.Operacion as Codigo, .f. as Existe from ( lcCursorAct ) Perf;
				where Perf.Operacion not in ( select Ope.Codigo from ( lcCursor ) Ope ) ;
				into cursor ( lcAux )
			
			select ( lcAux )
			scan
				lcOpe =  alltrim( &lcAux..Codigo )
				if !empty(lcOpe )
					for lnInd = 1 to this.Operaciones.count
						loItem = this.Operaciones.Item[ lnInd ]
						if ( alltrim( loItem.Operacion_Pk ) == lcOpe )

							loItem = this.Operaciones.Item[ lnInd ]
							loItem.Operacion_PK = ""
							loItem.Estado_PK = 0
						endif
					endfor
				endif
			endscan

			**** Agregamos los nuevos
			select Ope.Codigo, .t. as Existe from ( lcCursor ) Ope;
				where Ope.Codigo not in ( select Perf.Operacion from ( lcCursorAct ) Perf ) ;
				into cursor ( lcAux )
			
			lni = this.Operaciones.Count + 1
			select ( lcAux )
			scan
				lcOpe = &lcAux..Codigo 
				if !empty(lcOpe )
					loItem = this.Operaciones.CrearItemAuxiliar()
					loItem.Codigo = this.Codigo
					loItem.Operacion_PK = alltrim( lcOpe )
					loItem.Estado_PK = 2
					loItem.NroItem = lni 
					this.Operaciones.Add( loITem )
					lni = lni + 1
			
				endif
			endscan

		catch to loError
			goServicios.Errores.LevantarExcepcion(loError)
		finally
			use in select( lcCursor )
			use in select( lcCursorAct )
			loOperaciones.release()
		endtry			
		
		this.Operaciones.LimpiarItem()
	
		use in select( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault()
		
		if llRetorno
			llRetorno = this.LlenarOperaciones()
		endif
		return llRetorno
	endfunc 

enddefine
