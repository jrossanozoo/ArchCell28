**********************************************************************
Define Class zTestAdnImplant As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestAdnImplant Of zTestAdnImplant.prg
	#Endif

	cSucursal = ""
	cNombreBaseAnt = ""
	cEsquemaDefault = _Screen.Zoo.App.cSchemaDefault
	oAdnImplant = Null

	*---------------------------------
	Function Setup
		Local lcSql As String, lcRutaSuc As String, lcEsquema As String

		This.oAdnImplant = _Screen.Zoo.CrearObjeto( "AdnImplant" )
		This.oAdnImplant.Inicializar( .F., _Screen.Zoo.App.cBDMaster, _Screen.Zoo.App.ObtenerSucursalDefault() )

		This.cSucursal = goServicios.Librerias.ObtenerNombreSucursal( "PAISES" )
		This.cEsquemaDefault = _Screen.Zoo.App.cSchemaDefault
		This.cNombreBaseAnt = _Screen.Zoo.App.cNombreBaseDeDatosSql
		goServicios.Datos.DesconectarMotorSql()
		_Screen.Zoo.App.cNombreBaseDeDatosSql = This.cSucursal
	Endfunc

	*---------------------------------
	Function TearDown
		Local lcSql As String, lcRutaSuc As String, lcEsquema As String

		_Screen.Zoo.App.cNombreBaseDeDatosSql = This.cNombreBaseAnt
		goServicios.Datos.DesconectarMotorSql()
		This.oAdnImplant.Release()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestEjecutarAdnImplantV2_VerificarFocoDePantalla
		local loForm as Form, lcCaption as String, loFormEsperado as form
		
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		* 19/04/2011 * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		****
		**** SOLO CORRE EN NATIVA YA QUE TODAVIA NO SE HIZO EL NUEVO ADNIMPLANT PARA SQLSERVER
		****
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		* 19/04/2011 * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO

		If goServicios.Datos.EsNativa()
			loFormEsperado = null
			if type( "_screen.ActiveForm" ) = "O"
				loFormEsperado = _screen.ActiveForm 
			endif
			
			This.oAdnImplant.EjecutarAdnImplantV2( 1, "", .f. )

			loForm = null
			if type( "_screen.ActiveForm" ) = "O"
				loForm = _screen.ActiveForm 
			endif

			this.assertequals( "El formulario activo no es el esperado", loFormEsperado, loForm )
		Endif

		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		* 19/04/2011 * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
		************** MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO * MRUSSO
	Endfunc

Enddefine
