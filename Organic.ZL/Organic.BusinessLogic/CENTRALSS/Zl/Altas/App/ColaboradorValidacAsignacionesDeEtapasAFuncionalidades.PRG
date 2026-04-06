define class ColaboradorValidacAsignacionesDeEtapasAFuncionalidades as ZooSession of ZooSession.prg

	*-----------------------------------------------------------------------------------------
	function ValidarIyDPresupuesto_Aceptado( tFun as number, tEtapa as Number ) as Boolean
		local lcCursor as String, lcSQL as String, llRetorno as Boolean, lcUsuarioLogueado as String
 
		llRetorno = .t.
		lcCursor = 'C' + sys( 2015 )
		if tFun <> 0 and tEtapa = 6
			text to lcSQL textmerge noshow
				select 
					fes.Funcionalidad as Funcionaliad, 
					isnull(F.Numr,0) as PresupuestoDeIYD, 
					isnull(E.Nume,0) as PresupuestoDeIYDNumeroAprobacion,
					isnull(E.Estado,0) as PresupuestoDeIYDEstadoAprobacion,
					fes.CodigoEstado as FuncEstado
				from  [ZL].[funcIyDFuncionalidadesEstadoActual]() fes
				left join zl.DETIyDPRES F on fes.funcionalidad = F.Codigofunc
				left join zl.IydPrAgEst E on E.presup = F.Numr 
				where fes.funcionalidad = <<transform( tFun )>>
				order by F.Numr desc	
			endtext
			goDatos.EjecutarSQL( lcSql, lcCursor, this.DataSessionId )

			if ( used( lcCursor ) and reccount( lcCursor ) > 0 ) 
				if &lcCursor..FuncEstado = 4
					select( lcCursor )
					locate for PresupuestoDeIYD <> 0
					if found()
						locate for PresupuestoDeIYDEstadoAprobacion = 2
						if !found()
							llRetorno = .f.
							goServicios.Errores.LevantarExcepcionTexto( 'No puede asignar la etapa "Desarrollo" a la funcionalidad ' + transform( tFun ) + ', tiene un presupuesto de I+D relacionado sin aceptar.')
						endif						
					else
						llRetorno = .f.
						goServicios.Errores.LevantarExcepcionTexto( 'No puede asignar la etapa "Desarrollo" a la funcionalidad ' + transform( tFun ) + ', por tener estado 4 (Presupuesto) y no tener un presupuesto de I+D relacionado.')
					endif	
				endif	
			endif		
		endif
		use in select( lcCursor )
 		return llRetorno
	endfunc
	
enddefine
