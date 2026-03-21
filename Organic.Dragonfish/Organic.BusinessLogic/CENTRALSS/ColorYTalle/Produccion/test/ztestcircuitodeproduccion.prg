**********************************************************************
Define Class zTestCircuitoDeProduccion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestCircuitoDeProduccion of zTestCircuitoDeProduccion.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		local lcFiltroWhere as String
		lcFiltroWhere = "codigo LIKE '%fxu%'"
		goDatos.EjecutarSentencias( "Delete from ModeloProd where " + lcFiltroWhere, "ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModProc where codigo not in (Select codigo from ModeloProd)", "ModProc, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModIns where CodModIns not in (Select codigo from ModeloProd)", "ModIns, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModSal where CodModSal not in (Select codigo from ModeloProd)", "ModSal, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModMaq where CodModMaq not in (Select codigo from ModeloProd)", "ModMaq, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from OrdenProd where descrip LIKE '%fxu%'", "OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPProc where CodOrden not in (Select codigo from OrdenProd)", "OrdPProc, OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPCurv where CodOrden not in (Select codigo from OrdenProd)", "OrdPCurv, OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPIns where CodOrden not in (Select codigo from OrdenProd)", "OrdPIns, OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPSal where CodOrden not in (Select codigo from OrdenProd)", "OrdPSal, OrdenProd" )
	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarCombinacionEnCurvadeProduccion 
		local loComponente as Object, llValido as Boolean, loEntidad as entidad OF entidad.prg, loError as Object
*Arrange (Preparar)
		this.AgregarMocks( "CurvaDeProduccion" )
		_screen.mocks.AgregarSeteoMetodo( 'CurvaDeProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		loComponente = _Screen.Zoo.CrearObjeto( 'ColaboradorProduccionFake', 'zTestCircuitoDeProduccion.prg' )
*Act (Actuar)
		llValido = loComponente.CurvaDeProduccionValida( 'CURVAT', 'NEGRO', '1')
*Assert (Afirmar)
		this.asserttrue('La combinacion NEGRO-1 debe ser valida', llValido)
*Act (Actuar)
		llValido = loComponente.CurvaDeProduccionValida( 'CURVAT', 'BLANCO', '1')
*Assert (Afirmar)
		this.asserttrue('La combinacion BLANCO-1 debe ser invalida', !llValido)
*Clean (Limpiar)
		loComponente.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarColorEnPaletaDeColores
		local loComponente as Object, llValido as Boolean
*Arrange (Preparar)
		this.AgregarMocks( "PaletaDeColor" )
		_screen.mocks.AgregarSeteoMetodo( 'PaletaDeColor', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		loComponente = _Screen.Zoo.CrearObjeto( 'ColaboradorProduccionFake', 'zTestCircuitoDeProduccion.prg' )
*Act (Actuar)
		llValido = loComponente.ColorValido( 'CURVAT', 'AZUL')
*Assert (Afirmar)
		this.asserttrue('El color AZUL debe ser valido', llValido)
*Act (Actuar)
		llValido = loComponente.ColorValido( 'CURVAT', 'NARANJA')
*Assert (Afirmar)
		this.asserttrue('El color  NARANJA debe ser invalido', !llValido)
*Clean (Limpiar)
		loComponente.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarTalleEnCurvaDeTalles
		local loComponente as Object, llValido as Boolean
*Arrange (Preparar)
		this.AgregarMocks( "CurvaDeTalles" )
		_screen.mocks.AgregarSeteoMetodo( 'CurvaDeTalles', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		loComponente = _Screen.Zoo.CrearObjeto( 'ColaboradorProduccionFake', 'zTestCircuitoDeProduccion.prg' )
*Act (Actuar)
		llValido = loComponente.TalleValido( 'CURVAT', 'XL')
*Assert (Afirmar)
		this.asserttrue('El talle XL debe ser valido', llValido)
*Act (Actuar)
		llValido = loComponente.TalleValido( 'CURVAT', 'XS')
*Assert (Afirmar)
		this.asserttrue('El talle XS debe ser invalido', !llValido)
*Clean (Limpiar)
		loComponente.Release()
	endfunc 

EndDefine


******************************************************************************************
*-----------------------------------------------------------------------------------------
define class ColaboradorProduccionFake as colorytalle_ColaboradorProduccion of colorytalle_ColaboradorProduccion.PRG

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCurvaDeProduccion( tcCurvaDeProduccion as String ) as Collection
		local loRetorno as Collection, loItem As Object
		loRetorno = _Screen.Zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetalleCurvaDeProduccionDetalle.prg')
		loItem.NroItem = 1
		loItem.Color_PK = 'NEGRO'
		loItem.Talle_PK = '1'
		loItem.Cantidad = 1
		loRetorno.Agregar(loItem)
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPaletaDeColores( tcPaleta as String ) as Collection
		local loRetorno as Collection, loPaleta as Object, loItem As Object
		loRetorno = _Screen.Zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetallePaletaDeColoresColores.prg')
		loItem.NroItem = 1
		loItem.Color_PK = 'AZUL'
		loRetorno.Agregar(loItem)
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetallePaletaDeColoresColores.prg')
		loItem.NroItem = 1
		loItem.Color_PK = 'BLANCO'
		loRetorno.Agregar(loItem)
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetallePaletaDeColoresColores.prg')
		loItem.NroItem = 1
		loItem.Color_PK = 'NEGRO'
		loRetorno.Agregar(loItem)
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCurvaDeTalles( tcCurva as String ) as Collection
		local loRetorno as Collection, loCurva as Object, loItem As Object
		loRetorno = _Screen.Zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetalleCurvaDeTallesTalles.prg')
		loItem.NroItem = 1
		loItem.Talle_PK = 'S'
		loRetorno.Agregar(loItem)
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetalleCurvaDeTallesTalles.prg')
		loItem.NroItem = 1
		loItem.Talle_PK = 'M'
		loRetorno.Agregar(loItem)
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetalleCurvaDeTallesTalles.prg')
		loItem.NroItem = 1
		loItem.Talle_PK = 'L'
		loRetorno.Agregar(loItem)
		loItem = _Screen.Zoo.CrearObjeto('ItemAuxiliar','Din_DetalleCurvaDeTallesTalles.prg')
		loItem.NroItem = 1
		loItem.Talle_PK = 'XL'
		loRetorno.Agregar(loItem)
		return loRetorno
	endfunc 

enddefine
