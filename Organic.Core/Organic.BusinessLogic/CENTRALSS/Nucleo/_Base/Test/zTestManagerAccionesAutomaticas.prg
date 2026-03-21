**********************************************************************
Define Class zTestManagerAccionesAutomaticas As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestManagerAccionesAutomaticas Of zTestManagerAccionesAutomaticas.prg
	#Endif

	*---------------------------------
	Function zTestU_ManejoDeErrores
		local loMan as manageraccionesautomaticas of manageraccionesautomaticas.prg
		
		loMan = _Screen.zoo.CrearObjeto( "manageraccionesautomaticas" )
		
		try
			loMan.EjecutarAccionesAutomaticasSegunEntidadMetodo()
			this.asserttrue( "Debe dar error", .f. )
		catch to loError
			if ( type( "loError.uservalue" ) == "O" and !isnull( loError.uservalue ) )
				this.assertequals( "El numero de error es incorrecto", 7123, loError.uservalue.nZooErrorNo )
			else
				throw loError
			endif
		endtry
		
		loMan.release()
	Endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		function ObtenerValorDeCierre( tcEntidad as String) as String
*!*			local lcRetorno as String
*!*			if this.oEntidadesConAccionesAutomaticas.buscar( upper(alltrim(tcEntidad)) )
*!*				lcRetorno	= this.oEntidadesConAccionesAutomaticas.item(upper(tcEntidad)).ValorDeCierre
*!*			else
*!*				lcRetorno	= ""
*!*			endif
*!*			return lcRetorno
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerValorDeCierre
		 local loManager as Object, loEntidad as Object
	*Arrange (Preparar)
		this.agregarmocks("bolivia")
		_screen.mocks.AgregarSeteoPropiedad( 'bolivia', 'codigo', '0' )
		_screen.mocks.AgregarSeteoPropiedad( 'bolivia', 'descripcion', 'Solo para Test' )
		loEntidad=_screen.zoo.instanciarentidad("accionesautomaticas")
		with loEntidad
			try 
				.codigo 	= 'test1'
				.eliminar()
			catch
			endtry
			.nuevo()
			.codigo 	= 'test1'
			.Entidad	= 'recibo'
			.ValorDeCierre = '0'
			.grabar()
			.release
			endwith
	*Act (Actuar)
		loManager	= goservicios.entIDADES.ACCIONESAUTOMATICAS
		loManager.init()
	*Assert (Afirmar)
		if loManager.CantidadDeEntidadesQueTienenAccionesAutomaticas()>0
			try
*				loManager.oEntidadesConAccionesAutomaticas[1].ValorDeCierre
				this.assertequals( "Debe devolver un valor tipo caracter","C",vartype(loManager.ObtenerValorDeCierreDeEntidad("Recibo")))
			catch
				this.asserttrue("No existe Campo ValorDeCierre",.f.)
			endtry
		else
			this.asserttrue("No existen Entidades para realizar el Test",.f.)
		endif
*		loManager.release()
	endfunc 

Enddefine
