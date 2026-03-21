**********************************************************************
Define Class zTestManagerEntidades as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestManagerEntidades of zTestManagerEntidades.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function zTestAccionesAutomaticas
		local loEntidad as entidad of entidad.prg, loError as Exception, lnTmp as Integer
		
		lnTmp = goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas()
		
		loEntidad = _screen.zoo.instanciarentidad( "AccionesAutomaticas" )

		with loEntidad
		
			&& CARGA 1
			try
				.Codigo = "546456"
				.Eliminar()
				lnTmp = lnTmp - 1
				this.Asserttrue( "No se actualizo la collecion de entidades que tienen AccionesAutomaticas al ELIMINAR un ITEM de la entida AccionesAutomaticas. 1", lnTmp == goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas() )				
			catch to loError
			endtry
			.Nuevo()
			.Codigo = "546456"
			.Entidad = 'Rusia'
			.Observacion = ''
			with .AccionesDetalle
				.LimpiarItem()			
				with .oItem
					.Codigo = "1"
					.Metodo = "DespuesDeGrabar"
					.Accion = "Exportar"
					.Orden = 1
					.Expresion = "PEPE1"
				endwith
				.Actualizar()
			endwith
			.Grabar()
			lnTmp = lnTmp + 1

			&& CARGA 2
			try
				.Codigo = "5464562"
				.Eliminar()
				lnTmp = lnTmp - 1
				this.Asserttrue( "No se actualizo la collecion de entidades que tienen AccionesAutomaticas al ELIMINAR un ITEM de la entida AccionesAutomaticas. 1", lnTmp == goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas() )				
			catch to loError
			endtry
			.Nuevo()
			.Codigo = "5464562"
			.Entidad = 'Italia'
			.Observacion = ''
			with .AccionesDetalle
				.LimpiarItem()			
				with .oItem
					.Codigo = "1"
					.Metodo = "DespuesDeGrabar"
					.Accion = "Exportar"
					.Orden = 1
					.Expresion = "PEPE2"
				endwith
				.Actualizar()
			endwith
			.Grabar()
			lnTmp = lnTmp + 1

			&& CARGA 3
			try
				.Codigo = "123123213"
				.Eliminar()
				
				lnTmp = lnTmp - 1
				this.Asserttrue( "No se actualizo la collecion de entidades que tienen AccionesAutomaticas al ELIMINAR un ITEM de la entida AccionesAutomaticas. 1", lnTmp == goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas() )				
			catch to loError
			endtry			
			.Nuevo()
			.Codigo = "123123213"
			.Entidad = 'Senegal'
			.Observacion = ''
			with .AccionesDetalle
				.LimpiarItem()			
				with .oItem
					.Metodo = "DespuesDeGrabar"
					.Accion = "Exportar"
					.Orden = 1
					.Expresion = "PEPE2"
				endwith
				.Actualizar()
			endwith
			.Grabar()
			lnTmp = lnTmp + 1
			
			this.Asserttrue( "No se actualizo la collecion de entidades que tienen AccionesAutomaticas. 2", lnTmp == goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas() )
			.Codigo = "123123213"
			.Eliminar()
			lnTmp = lnTmp - 1
			this.Asserttrue( "No se actualizo la collecion de entidades que tienen AccionesAutomaticas. 3", lnTmp == goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas() )
		endwith
		loEntidad.Release()
		this.Asserttrue( "No se actualizo la collecion de entidades que tienen AccionesAutomaticas. 5", lnTmp == goServicios.Entidades.AccionesAutomaticas.CantidadDeEntidadesQueTienenAccionesAutomaticas() )
		
		loEntidad = _screen.zoo.instanciarentidad( "Rusia" )			
		with loEntidad
			try
				.Codigo = "1"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "1"
			.Habitantes = 3
			.Fecha = date()
			loTmp = Newobject( "AccionesAutomaticas_TEST" )
			loTmp.Inicializar()
			
			goServicios.Entidades.AccionesAutomaticas.lDestroy = .t.
			goServicios.Entidades.AccionesAutomaticas.oEntidadAccionesAutomaticas.release()
			goServicios.Entidades.AccionesAutomaticas.oEntidadAccionesAutomaticas = loTmp
			goServicios.Entidades.AccionesAutomaticas.lDestroy = .f.		
			.Grabar()
		endwith
		
		this.assertequals( "NO LLAMO AL EXPORTAR, O BIEN EL PARAMETRO ENVIADO ES INCORRECTO. 1", "PEPE1", loTmp.cExprecionEnviadaPorParametro )
		this.assertequals( "NO LLAMO AL EXPORTAR, O BIEN EL PARAMETRO ENVIADO ES INCORRECTO. 2", "RUSIA", loTmp.cNombreDeEntidadEnviadaPorParametro )
		this.assertequals( "NO LLAMO AL EXPORTAR, O BIEN EL PARAMETRO ENVIADO ES INCORRECTO. 3", 1, loTmp.nCantidadDeLla )
		loEntidad.release()
		loTmp.Release()
		loEntidad = _screen.zoo.instanciarentidad( "AccionesAutomaticas" )
		try
			loEntidad.Codigo = "546456"
			loEntidad.Eliminar()		
		catch
			this.Asserttrue( "No deberia pinchar al borrar el primer registro de la entidad ACCIONESAUTOMATICAS", .f. )
		endtry
		try
			loEntidad.Codigo = "5464562"
			loEntidad.Eliminar()		
		catch
			this.Asserttrue( "No deberia pinchar al borrar el segundo registro de la entidad ACCIONESAUTOMATICAS", .f. )
		endtry		
		

		loEntidad.release()		
		
	endfunc 
	*-----------------------------------------------------------------------------------------
		
enddefine


define class AccionesAutomaticas_TEST as ent_AccionesAutomaticas of ent_AccionesAutomaticas.prg
	
	cNombreDeEntidadEnviadaPorParametro = ""
	cExprecionEnviadaPorParametro = ""
	nCantidadDeLla = 0
	
	*-----------------------------------------------------------------------------------------
	function Exportar( toEntidad as entidad OF entidad.prg, tcExprecion as String) as Void
		this.cNombreDeEntidadEnviadaPorParametro = toEntidad.Obtenernombre()
		this.cExprecionEnviadaPorParametro = tcExprecion
		this.nCantidadDeLla = this.nCantidadDeLla + 1
	endfunc 

enddefine
