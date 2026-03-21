**********************************************************************
Define Class zTestEntidadesDeProduccion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestEntidadesDeProduccion of zTestEntidadesDeProduccion.prg
	#ENDIF
	
	oCaja = null
	oModulos = null
	oSeguridad = null

	*---------------------------------
	Function Setup
		this.oCaja = goCaja
		this.oModulos = goModulos
		this.oSeguridad = goServicios.Seguridad
	EndFunc
	
	*---------------------------------
	Function TearDown
		goCaja = this.oCaja
		goModulos = this.oModulos
		goServicios.Seguridad = this.oSeguridad
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarUltimoProcesoEnGestion
		local loEntidad as entidad OF entidad.prg, loError as Object

		private goCaja as object, goModulos as object
		goCaja = _screen.zoo.InstanciarComponente( "ComponenteCaja" )
*Arrange (Preparar)
		this.AgregarMocks("Seguridad,ModulosColorYTalle,ProcesoProduccion")
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ModulosColorYTalle', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Obtenerultimousuariologueado', '"TEST"' )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Cusuariologueado_access', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Obtenerestadodelsistema', 1 )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'ObtenerEstadoDeSeguridad', "ABIERTO" )
		goModulos = _Screen.Zoo.CrearObjeto( "ModulosColorYTalle" )
		goServicios.Seguridad = _Screen.zoo.InstanciarComponente( "Seguridad" )
		_screen.mocks.AgregarSeteoMetodo( 'ProcesoProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
*Act (Actuar)
		loEntidad = _Screen.Zoo.InstanciarEntidad( "ModeloDeProduccion" )
		With loEntidad
			try
				.Nuevo()
				.Codigo = 'ZTEST999'
				with .ModeloProcesos
					.Limpiar()
					.oItem.Proceso_PK = 'CORTEXXX'
					.oItem.Orden = 1
					.Actualizar()
					.LimpiarItem()
					.oItem.Proceso_PK = 'CONFECCIONXXX'
					.oItem.Orden = 2
					.Actualizar()
					.LimpiarItem()
					.oItem.Proceso_PK = 'EMBOLSADOXXX'
					.oItem.Orden = 2
					.Actualizar()
				endwith
				try
					grabar()
					this.AssertTrue(.f.,"Debio tirar una excepcion al intentar grabar con el orden del último proceso repetido")
				catch
				endtry
			catch to loError
				lcMensaje = 'El modelo debe tener un último proceso único (orden ' + alltrim(str(2)) + ')'
				this.assertequals( "El mensaje de error es incorrecto", lcMensaje , loError.uservalue.oInformacion.item[ 1 ].cMensaje )
			finally
				.Cancelar()
			endtry
*Assert (Afirmar)
		EndWith
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarCurvaDeProduccionSinGenericosEnOrden 
		local loEntidad as entidad OF entidad.prg, loError as Object, loColaborador as Object, lcMensaje as String

		private goCaja as object, goModulos as object
		goCaja = _screen.zoo.InstanciarComponente( "ComponenteCaja" )
*Arrange (Preparar)
		this.AgregarMocks( "Color, Talle, ProcesoProduccion, Articulo, Insumo, ModeloDeProduccion,Seguridad,ModulosColorYTalle" )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ModulosColorYTalle', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Obtenerultimousuariologueado', '"TEST"' )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Cusuariologueado_access', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Obtenerestadodelsistema', 1 )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'ObtenerEstadoDeSeguridad', "ABIERTO" )
		goModulos = _Screen.Zoo.CrearObjeto( "ModulosColorYTalle" )
		goServicios.Seguridad = _Screen.zoo.InstanciarComponente( "Seguridad" )
		_screen.mocks.AgregarSeteoMetodo( 'Color', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Talle', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ProcesoProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Articulo', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Insumo', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ModeloDeProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'colorytalle_ColaboradorProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoPropiedad( 'Color', 'EsComodinEnProduccion', .t. )
		_screen.mocks.AgregarSeteoPropiedad( 'Talle', 'EsComodinEnProduccion', .t. )
		loColaborador = _Screen.Zoo.CrearObjeto( "ColaboradorProduccion_Fake", "zTestEntidadesDeProduccion.prg" )
		loEntidad = _Screen.Zoo.InstanciarEntidad( "OrdenDeProduccion" )
		loEntidad.oColaboradorProduccion = loColaborador
		With loEntidad
			try
				.Nuevo()
				.Modelo_PK = "MODELO"
				.ProductoFinal_PK = "PRODUCTO"
				.OrdenCurva.LimpiarItem()
				.OrdenCurva.oItem.Producto_PK = "PRODUCTO"
				.OrdenCurva.oItem.Color_PK = "."
				.OrdenCurva.oItem.Talle_PK = "."
				.OrdenCurva.Actualizar()
				.Grabar()
				this.AssertTrue("Debio dar error al intentar grabar con color o talle genérico en la curva de producción.", .t. )
			catch to loError
				lcMensaje = loError.UserValue.oInformacion.Item[1].cMensaje
				this.AssertEquals('El mensaje de error no es el esperado', 'No esta permitido usar comodines en las variantes de la curva de produccion.', lcMensaje)
			finally
			endtry
*Assert (Afirmar)
		EndWith
		loColaborador.Release()
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarInsumosOrdenDeProduccionSiModeloYCurvaConColorSinTalle
		local loEntidad as entidad OF entidad.prg, loError as Object, loColaborador as Object, lcMensaje as String,;
		 lcVariantePrincipal as String, lcVarianteSecundaria as String

		private goCaja as object, goModulos as object
		goCaja = _screen.zoo.InstanciarComponente( "ComponenteCaja" )

		this.AgregarMocks( "Color, Talle, ProcesoProduccion, Articulo, Insumo, Seguridad,ModulosColorYTalle,CurvaDeProduccion" )
		_screen.mocks.AgregarSeteoMetodo( 'CurvaDeProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ModulosColorYTalle', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Obtenerultimousuariologueado', '"TEST"' )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Cusuariologueado_access', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'Obtenerestadodelsistema', 1 )
		_screen.mocks.AgregarSeteoMetodo( 'Seguridad', 'ObtenerEstadoDeSeguridad', "ABIERTO" )
		goModulos = _Screen.Zoo.CrearObjeto( "ModulosColorYTalle" )
		goServicios.Seguridad = _Screen.zoo.InstanciarComponente( "Seguridad" )
		_screen.mocks.AgregarSeteoMetodo( 'ProcesoProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'colorytalle_ColaboradorProduccion', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoPropiedad( 'Color', 'Color_pk', '' )
		_screen.mocks.AgregarSeteoPropiedad( 'Talle', 'Talle_pk', 'S' )
		_screen.mocks.AgregarSeteoPropiedad( 'CurvaDeProduccion', 'CurvaDeProduccion_pk', "[*COMODIN]" )		

		loColaborador = _Screen.Zoo.CrearObjeto( "ColaboradorProduccion_Fake", "zTestEntidadesDeProduccion.prg" )
		
		loModelo = _Screen.Zoo.InstanciarEntidad( "ModeloDeProduccion" )
		With loModelo 
			try
				.Codigo = "ZTEST998"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "ZTEST998"
			with .ModeloProcesos
				.Limpiar()
				.oItem.Proceso_PK = 'CORTEXXX'
				.oItem.Orden = 1
				.Actualizar()
			endwith
			with .ModeloInsumos
				.Limpiar()
				.oitem.color_pk = 'XGRIX'
				.oitem.talle_pk = ''
				.oitem.colorm_pk = 'XGRIX'
				.oitem.tallem_pk = ''
				.oitem.proceso_pk = 'CORTEXXX'
				.oitem.Insumo_pk = 'TELA'
				.oitem.Cantidad = 3
				.Actualizar()
				
				.LimpiarItem()
				.oitem.color_pk = 'XBLAX'
				.oitem.talle_pk = ''
				.oitem.colorm_pk = 'XBLAX'
				.oitem.tallem_pk = ''
				.oitem.proceso_pk = 'CORTEXXX'
				.oitem.Insumo_pk = 'TELA'
				.oitem.Cantidad = 2
				.Actualizar()
			endwith
			.curvadeproduccion_pk = '1'
		endwith && loModelo
		
		lcVariantePrincipal = "XGRIX" && color de la CurvaDeProduccion
		lcVarianteSecundaria = "" && talle de la CurvaDeProduccion
		loCol = loColaborador.ObtenerInsumosDeCurvaDeProduccion( loModelo , lcVariantePrincipal , lcVarianteSecundaria )

		this.AssertTrue('Debería haber traído a la solapa insumos de la Orden de Producción el color del insumo del modelo ', loCol.item[1].color_pk = loModelo.ModeloInsumos.item[1].color_pk)
		this.AssertTrue('Debería haber traído a la solapa insumos de la Orden de Producción el talle vacío como el insumo del modelo ', loCol.item[1].talle_pk = loModelo.ModeloInsumos.item[1].talle_pk)
		this.AssertTrue('Debería haber traído a la solapa insumos de la Orden de Producción el color de la curva del insumo del modelo ', loCol.item[1].colorm_pk = loModelo.ModeloInsumos.item[1].colorm_pk)
		this.AssertTrue('Debería haber traído a la solapa insumos de la Orden de Producción el talle de la curva del insumo del modelo ', loCol.item[1].tallem_pk = loModelo.ModeloInsumos.item[1].tallem_pk)						
		this.AssertTrue('Debería haber traído a la solapa insumos de la Orden de Producción la cantidad del insumo del modelo', loCol.item[1].cantidad = loModelo.ModeloInsumos.item[1].cantidad)								



		lcVariantePrincipal = "XGRIX" && color de la CurvaDeProduccion
		lcVarianteSecundaria = "1" && talle de la CurvaDeProduccion
		loCol = loColaborador.ObtenerInsumosDeCurvaDeProduccion( loModelo , lcVariantePrincipal , lcVarianteSecundaria )

		this.Asserttrue('No hay coincidencia. No tiene que traer datos en grilla insumos en loCol', loCol.count = 0)
			
		loColaborador.Release()
		loCol.Release() 
		loModelo.Release()

	endfunc 


EndDefine


*!* *-----------------------------------------------------------------------------------------
define class ColaboradorProduccion_Fake as colorytalle_ColaboradorProduccion of colorytalle_ColaboradorProduccion.prg

enddefine

