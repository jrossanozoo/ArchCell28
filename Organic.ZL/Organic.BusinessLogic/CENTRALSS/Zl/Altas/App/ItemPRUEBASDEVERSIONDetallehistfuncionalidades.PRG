define class ItemPRUEBASDEVERSIONDetallehistfuncionalidades as Din_ItemPRUEBASDEVERSIONDetallehistfuncionalidades of Din_ItemPRUEBASDEVERSIONDetallehistfuncionalidades.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerPropietarioPivotal() as void
		local  lcSql  as String, lcCursor as String 
		
		lcCursor = 'C' + sys( 2015 )

		if alltrim(this.PropietarioPivotal) <> ''
			text to lcSql textmerge noshow
			 	select [Funciones].[ObtenerUsuarioZLdeUsuarioPivotal]( '<<alltrim(this.PropietarioPivotal)>>' ) AS PropietarioZL
			endtext
			goDatos.EjecutarSql( lcSql , lcCursor, this.DataSessionId )
			this.Propietario_Pk = &lcCursor..PropietarioZL			
		else 
			*/* Si esta Listo para publicar trae propietario, si no no.*/*
			text to lcSql textmerge noshow			
				select 
					F.HistoriaProp as PropietarioPivotal ,
					F.HistoriaProp AS PropietarioZL
				from ZL.funcIyDFuncionalidadesListasParaPublicar( '<<alltrim(this.tag)>>' )  as F
				where F.Codigo = <<transform( this.Func_pk )>>
			endtext 
			goDatos.EjecutarSql( lcSql , lcCursor, this.DataSessionId )
			if used( lcCursor ) and reccount( lcCursor ) > 0
				this.PropietarioPivotal = &lcCursor..PropietarioPivotal
				this.Propietario_Pk = &lcCursor..PropietarioZL
			endif 	
		endif 	
	
		use in select ( lcCursor )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEquipo() as Void
		local  lcSql  as String, lcCursor as String 
		
		if this.func_Pk <> 0 and empty( this.Proyecto_Pk )
			lcCursor = 'C' + sys( 2015 )

			text to lcSql textmerge noshow
			 	select 
					CodigoEquipo 
				from ZL.funcIyDFuncionalidadesEquipoActual() 
				where Funcionalidad = <<transform(this.func_Pk)>> 
			endtext
			
			
			goDatos.EjecutarSentencias( lcSql , "", "", lcCursor, this.DataSessionId )
			
			this.Proyecto_Pk = &lcCursor..CodigoEquipo 
			
			use in select ( lcCursor )
		endif
		
		this.ObtenerHistoria()
		this.ObtenerPropietarioPivotal()                                                                    
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerHistoria() as Void
		local  lcSql  as String, lcCursor as String 
		
		if this.func_Pk <> 0 and empty( this.Hist_Pk )
			lcCursor = 'C' + sys( 2015 )

			text to lcSql textmerge noshow
			 	select 
						Codigo 	
					from zl.hpivot 
					where FUNC  =  <<transform(this.func_Pk)>> 
			endtext
			
			
			goDatos.EjecutarSentencias( lcSql , "", "", lcCursor, this.DataSessionId )
			
			if used( lcCursor ) and reccount( lcCursor ) = 1
				this.Hist_Pk = &lcCursor..Codigo 
			endif 	
			
			use in select ( lcCursor )
		endif
		
	endfunc 

enddefine