**********************************************************************
Define Class zTestNocturnosCircuitoProduccion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestNocturnosCircuitoProduccion of zTestNocturnosCircuitoProduccion.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		local lcFiltroWhere as String
		lcFiltroWhere = "LIKE '%fxu%'"
		goDatos.EjecutarSentencias( "Delete from ModeloProd where codigo " + lcFiltroWhere, "ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModProc where codigo not in (Select codigo from ModeloProd)", "ModProc, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModIns where CodModIns not in (Select codigo from ModeloProd)", "ModIns, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModSal where CodModSal not in (Select codigo from ModeloProd)", "ModSal, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from ModMaq where CodModMaq not in (Select codigo from ModeloProd)", "ModMaq, ModeloProd" )
		goDatos.EjecutarSentencias( "Delete from OrdenProd where descrip " + lcFiltroWhere, "OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPProc where CodOrden not in (Select codigo from OrdenProd)", "OrdPProc, OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPCurv where CodOrden not in (Select codigo from OrdenProd)", "OrdPCurv, OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPIns where CodOrden not in (Select codigo from OrdenProd)", "OrdPIns, OrdenProd" )
		goDatos.EjecutarSentencias( "Delete from OrdPSal where CodOrden not in (Select codigo from OrdenProd)", "OrdPSal, OrdenProd" )
	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_CrearOrdenEnBaseAModeloConProductoFinal 
		local loEntidad as entidad OF entidad.prg, loError as Object
*Arrange (Preparar)
		this.AgregarMocks( "ModeloDeProduccion" )
		_screen.mocks.AgregarSeteoMetodo( 'ModeloDeProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
*Act (Actuar)
		loEntidad = _Screen.Zoo.InstanciarEntidad( "OrdenDeProduccion" )
		With loEntidad
			try
			catch to loError
			finally
			endtry
*Assert (Afirmar)
		EndWith
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_CrearOrdenEnBaseAModeloSinProductoFinal 
		local loEntidad as entidad OF entidad.prg, loError as Object, loComponente as Object
*Arrange (Preparar)
		this.AgregarMocks( "ModeloDeProduccion" )
		_screen.mocks.AgregarSeteoMetodo( 'ModeloDeProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
*Act (Actuar)
*!*			loComponente = _Screen.zoo.CrearObjetoPorProducto('ColaboradorProduccion', 'ColaboradorProduccion.prg')
		loComponente = _Screen.zoo.CrearObjeto('ColaboradorProduccion_Fake', 'zTestNocturnosCircuitoProduccion.prg')
		loEntidad = loComponente.ObtenerModeloDeProduccion( 'MODELO01') && _Screen.Zoo.InstanciarEntidad( "OrdenDeProduccion" )
		loComponente.Release()
		With loEntidad
			try
				wait window loComponente.Codigo nowait
			catch to loError
			finally
			endtry
*Assert (Afirmar)
		EndWith
		loEntidad.Release()
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
define class ColaboradorProduccion_Fake as colorytalle_colaboradorproduccion of colorytalle_colaboradorproduccion.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerModeloDeProduccion( tcModelo as String ) as Object
		local loRetorno as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "Mock_Modelodeproduccion", "Mock_Modelodeproduccion.prg" )
		if vartype( 'tcModelo' ) = 'C' and !empty( tcModelo )
			try
				loRetorno.Codigo = tcModelo
			catch
			endtry
		endif
		return loRetorno
	endfunc 

enddefine
