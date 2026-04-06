**********************************************************************
Define Class ZTestEntZl_CajaEstado as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ZTestEntZl_CajaEstado  of ZTestEntZl_CajaEstado.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestU_VerificarPropiedadesSeguridadCaja
		local loEntidad as Ent_CajaEstado of Ent_CajaEstado.prg
		loEntidad = _Screen.zoo.instanciarEntidad( "CajaEstado" )
*!*			ZL no tiene las opciones de Abrir, Estado y Cerrar Caja en el menu principal y por eso no tiene ID de seguridad.
		with loEntidad
			this.asserttrue( "La Propiedad 'SeguridadEntidadAbrirCaja' debería estar seteada con el valor ''", .SeguridadEntidadAbrirCaja == ""  )
			this.asserttrue( "La Propiedad 'SeguridadMetodoAbrirCaja ' debería estar seteada con el valor ''", .SeguridadMetodoAbrirCaja == ""  )
			this.asserttrue( "La Propiedad 'SeguridadEntidadEstadoCaja ' debería estar seteada con el valor ''", .SeguridadEntidadEstadoCaja == ""  )
			this.asserttrue( "La Propiedad 'SeguridadMetodoEstadoCaja ' debería estar seteada con el valor ''", .SeguridadMetodoEstadoCaja == ""  )
			this.asserttrue( "La Propiedad 'SeguridadEntidadCerrarCaja ' debería estar seteada con el valor ''", .SeguridadEntidadCerrarCaja == ""  )
			this.asserttrue( "La Propiedad 'SeguridadMetodoCerrarCaja ' debería estar seteada con el valor ''", .SeguridadMetodoCerrarCaja == ""  )
															
			.Release()
		EndWith
	endfunc

EndDefine
