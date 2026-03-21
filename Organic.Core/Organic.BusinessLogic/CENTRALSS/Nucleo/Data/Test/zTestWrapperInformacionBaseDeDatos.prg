**********************************************************************
Define Class zTestWrapperInformacionBaseDeDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestWrapperInformacionBaseDeDatos of zTestWrapperInformacionBaseDeDatos.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function zTestSqlServer_WrapperInformacionBaseDeDatos
		local loInfo as WrapperInformacionBaseDeDatos of Ent_RegistroDeMantenimiento.prg, lcId as string

		loInfo = _screen.zoo.CrearObjeto( "WrapperInformacionBaseDeDatos", "WrapperInformacionBaseDeDatos.prg", "PAISES" )

		lcId = loInfo.Obtener( "IDBaseDeDatos" )

		if goServicios.Datos.Esnativa()
			this.AssertTrue( "En Nativa. El id debe ser vacio", empty( lcId ) )
		else
			this.AssertTrue( "En SqlServer. El id obtenido es erroneo", !empty( lcId ) )
		endif
		
		_screen.mocks.verificarejecuciondemocks()
	endfunc 

EndDefine
