*-----------------------------------------------------------------------------------------
define class zTestServicioSaltosDeCampoYValoresSugeridos as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestServicioSaltosDeCampoYValoresSugeridos of zTestServicioSaltosDeCampoYValoresSugeridos.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Setup
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TearDown
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoDebeSaltarElCampoParaAtributoNoEspecificado
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, llValorEsperado as Boolean, llValorRetornado as Boolean
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		llValorEsperado = .f.
		llValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.DebeSaltarElCampo( sys( 2015 ), "", sys(2015 ) )
		this.assertequals( "Debió haber retornado que no debe saltar el campo.", llValorEsperado, llValorRetornado )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoDebeSaltarElCampoParaAtributoEspecificadoComoQueDebeSaltar
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, llValorEsperado as Boolean, llValorRetornado as Boolean
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', '', 'DESCRIPCION', .t., 'Mi articulo', .f. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		llValorEsperado = .t.
		llValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.DebeSaltarElCampo( "Articulo", "", "Descripcion" )
		this.assertequals( "Debió haber retornado que debe saltar el campo.", llValorEsperado, llValorRetornado )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoDebeSaltarElCampoParaAtributoDeDetalleEspecificadoComoQueDebeSaltar
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, llValorEsperado as Boolean, llValorRetornado as Boolean
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
 		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', 'CUALIDADES', 'DESCRIPCION', .t., 'Mi articulo', .f. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		llValorEsperado = .t.
		llValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.DebeSaltarElCampo( "Articulo", "Cualidades", "Descripcion" )
		this.assertequals( "Debió haber retornado que debe saltar el campo.", llValorEsperado, llValorRetornado )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoDebeSaltarElCampoParaAtributoEspecificadoComoQueNoDebeSaltar
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, llValorEsperado as Boolean, llValorRetornado as Boolean
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', '', 'DESCRIPCION', .f., 'Mi articulo', .f. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		llValorEsperado = .f.
		llValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.DebeSaltarElCampo( "Articulo", "", "Descripcion" )
		this.assertequals( "Debió haber retornado que no debe saltar el campo.", llValorEsperado, llValorRetornado )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoObtenerValorSugeridoParaAtributoNoEspecificado
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, lcValorRetornado as String
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		lcValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( sys( 2015 ), "", sys( 2015 ) )
		this.asserttrue( "Debió haber retornado nulo ya que no hay definido un valor sugerido.", isnull( lcValorRetornado ) )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoObtenerValorSugeridoParaAtributoEspecificado
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, lcValorEsperado as String, lcValorRetornado as String
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', '', 'DESCRIPCION', .t., 'Mi articulo', .f. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		lcValorEsperado = "Mi articulo"
		lcValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( "Articulo", "", "Descripcion" )
		this.assertequals( "El valor sugerido retornado no es correcto.", lcValorEsperado, lcValorRetornado )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_MetodoObtenerValorSugeridoParaAtributoEspecificadoComoQueDebeUsarElDeFramework
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, lcValorRetornado as String
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', '', 'DESCRIPCION', .t., 'Mi articulo', .t. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		lcValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( "Articulo", "", "Descripcion" )
		this.asserttrue( "Debió haber retornado nulo ya que se definió que use el valor sugerido de Framework.", isnull( lcValorRetornado ) )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerSaltoDeCampoYValorSugeridoParaAtributoNoEspecificado
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, loValorRetornado as Object
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( sys( 2015 ), "", sys( 2015 ) )
 		this.asserttrue( "Debió haber retornado nulo ya que no hay nada definido en la entidad SaltoDeCampo.", isnull( loValorRetornado ) )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerSaltoDeCampoYValorSugeridoParaAtributoEspecificado
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, loValorRetornado as Object
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', '', 'DESCRIPCION', .t., 'Mi articulo', .f. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( "Articulo", "", "Descripcion" )
		this.assertequals( "La propiedad Entidad no tiene el valor esperado.", "ARTICULO", alltrim( loValorRetornado.Entidad ) )
		this.assertequals( "La propiedad Detalle no tiene el valor esperado.", "", alltrim( loValorRetornado.Detalle ) )
		this.assertequals( "La propiedad Atributo no tiene el valor esperado.", "DESCRIPCION", alltrim( loValorRetornado.Atributo ) )
		this.assertequals( "La propiedad Salta no tiene el valor esperado.", .t., loValorRetornado.Salta )
		this.assertequals( "La propiedad ValorSugerido no tiene el valor esperado.", "Mi articulo", alltrim( loValorRetornado.ValorSugerido ) )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado.", .f., loValorRetornado.UsaValorSugeridoDeFramework )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerSaltoDeCampoYValorSugeridoParaAtributosConMismoNombrePeroDeDistintoDetalle
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, loValorRetornado as Object
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', '', 'DESCRIPCION', .t., 'Mi articulo', .f. )], "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '2', 'ARTICULO', 'CUALIDADES', 'DESCRIPCION', .f., 'Mi cualidad', .f. )], "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '3', 'ARTICULO', 'PROPIEDADES', 'DESCRIPCION', .t., 'Mi propiedad', .t. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( "Articulo", "PROPIEDADES", "Descripcion" )
		this.assertequals( "La propiedad Entidad no tiene el valor esperado.", "ARTICULO", alltrim( loValorRetornado.Entidad ) )
		this.assertequals( "La propiedad Detalle no tiene el valor esperado.", "PROPIEDADES", alltrim( loValorRetornado.Detalle ) )
		this.assertequals( "La propiedad Atributo no tiene el valor esperado.", "DESCRIPCION", alltrim( loValorRetornado.Atributo ) )
		this.assertequals( "La propiedad Salta no tiene el valor esperado.", .t., loValorRetornado.Salta )
		this.assertequals( "La propiedad ValorSugerido no tiene el valor esperado.", "Mi propiedad", alltrim( loValorRetornado.ValorSugerido ) )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado.", .t., loValorRetornado.UsaValorSugeridoDeFramework )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerSaltoDeCampoYValorSugeridoParaAtributosElementoAnterior
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, loValorRetornado as Object
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis, UsaVSAnt ) values ( '1', 'CANADA', 'DETALLECANADA', 'GOBERNADOR', .F., 'Mi articulo', .f., .t. )], "SaltoDeCampo" )
		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis, UsaVSAnt ) values ( '2', 'CANADA', 'DETALLECANADA', 'CODIGO', .f., 'Mi cualidad', .f., .T. )], "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( "CANADA", "DETALLECANADA", "GOBERNADOR" )
		this.assertequals( "La propiedad Entidad no tiene el valor esperado.", "CANADA", alltrim( loValorRetornado.Entidad ) )
		this.assertequals( "La propiedad Detalle no tiene el valor esperado.", "DETALLECANADA", alltrim( loValorRetornado.Detalle ) )
		this.assertequals( "La propiedad Atributo no tiene el valor esperado.", "GOBERNADOR", alltrim( loValorRetornado.Atributo ) )
		this.assertequals( "La propiedad Salta no tiene el valor esperado.", .F., loValorRetornado.Salta )
		this.assertequals( "La propiedad ValorSugerido no tiene el valor esperado.", "This.ElementoAnterior( 'GOBERNADOR' )", alltrim( loValorRetornado.ValorSugerido ) )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado.", .f., loValorRetornado.UsaValorSugeridoDeFramework )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado.", .t., loValorRetornado.UsaValorElementoAnterior )
		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ReiniciarSaltosDeCampoYValoresSugeridosDeEntidad
		local loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg, loValorRetornado as Object
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		goServicios.Datos.EjecutarSentencias( "Delete From SaltoDeCampo", "SaltoDeCampo" )

		goServicios.Datos.EjecutarSentencias( [insert into SaltoDeCampo ( Codigo, Entidad, Detalle, Atributo, Salta, VSugerido, UsaValSis ) values ( '1', 'ARTICULO', 'PROPIEDADES', 'DESCRIPCION', .t., 'Mi propiedad', .t. )], "SaltoDeCampo" )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( "Articulo", "PROPIEDADES", "Descripcion" )
		this.assertequals( "La propiedad Entidad no tiene el valor esperado 1.", "ARTICULO", alltrim( loValorRetornado.Entidad ) )
		this.assertequals( "La propiedad Detalle no tiene el valor esperado 1.", "PROPIEDADES", alltrim( loValorRetornado.Detalle ) )
		this.assertequals( "La propiedad Atributo no tiene el valor esperado 1.", "DESCRIPCION", alltrim( loValorRetornado.Atributo ) )
		this.assertequals( "La propiedad Salta no tiene el valor esperado 1.", .t., loValorRetornado.Salta )
		this.assertequals( "La propiedad ValorSugerido no tiene el valor esperado 1.", "Mi propiedad", alltrim( loValorRetornado.ValorSugerido ) )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado 1.", .t., loValorRetornado.UsaValorSugeridoDeFramework )

		goServicios.Datos.EjecutarSentencias( "Update SaltoDeCampo set UsaValSis = .f. ", "SaltoDeCampo" )
		loServicioSaltosDeCampoYValoresSugeridos.ReiniciarSaltosDeCampoYValoresSugeridosDeEntidad( sys( 2015 ) )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( "Articulo", "PROPIEDADES", "Descripcion" )
		this.assertequals( "La propiedad Entidad no tiene el valor esperado 2.", "ARTICULO", alltrim( loValorRetornado.Entidad ) )
		this.assertequals( "La propiedad Detalle no tiene el valor esperado 2.", "PROPIEDADES", alltrim( loValorRetornado.Detalle ) )
		this.assertequals( "La propiedad Atributo no tiene el valor esperado 2.", "DESCRIPCION", alltrim( loValorRetornado.Atributo ) )
		this.assertequals( "La propiedad Salta no tiene el valor esperado 2.", .t., loValorRetornado.Salta )
		this.assertequals( "La propiedad ValorSugerido no tiene el valor esperado 2.", "Mi propiedad", alltrim( loValorRetornado.ValorSugerido ) )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado 2.", .t., loValorRetornado.UsaValorSugeridoDeFramework )
		
		loServicioSaltosDeCampoYValoresSugeridos.ReiniciarSaltosDeCampoYValoresSugeridosDeEntidad( "Articulo" )
		loValorRetornado = loServicioSaltosDeCampoYValoresSugeridos.ObtenerSaltoDeCampoYValorSugeridoDeUnAtributo( "Articulo", "PROPIEDADES", "Descripcion" )
		this.assertequals( "La propiedad Entidad no tiene el valor esperado 3.", "ARTICULO", alltrim( loValorRetornado.Entidad ) )
		this.assertequals( "La propiedad Detalle no tiene el valor esperado 3.", "PROPIEDADES", alltrim( loValorRetornado.Detalle ) )
		this.assertequals( "La propiedad Atributo no tiene el valor esperado 3.", "DESCRIPCION", alltrim( loValorRetornado.Atributo ) )
		this.assertequals( "La propiedad Salta no tiene el valor esperado 3.", .t., loValorRetornado.Salta )
		this.assertequals( "La propiedad ValorSugerido no tiene el valor esperado 3.", "Mi propiedad", alltrim( loValorRetornado.ValorSugerido ) )
		this.assertequals( "La propiedad UsaValorSugeridoDeFramework no tiene el valor esperado 3.", .f., loValorRetornado.UsaValorSugeridoDeFramework )

		loServicioSaltosDeCampoYValoresSugeridos.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerPersonalizacionDeEtiqueta
		local lcEtiqueta as String, loSalto as Object, loColAtributos as zoocoleccion OF zoocoleccion.prg, itemAtributo as Object,;
		loServicioSaltosDeCampoYValoresSugeridos as ServicioSaltosDeCampoYValoresSugeridos of ServicioSaltosDeCampoYValoresSugeridos.prg
		loServicioSaltosDeCampoYValoresSugeridos = _screen.zoo.CrearObjeto( "ServicioSaltosDeCampoYValoresSugeridos" )
		lcEtiqueta = "dEsCrIpCiOn"
		loSalto = _screen.zoo.instanciarentidad("saltodecampo")
		try
			loSalto.nuevo()
			loSalto.entidad					= "RIO"
			loSalto.entidadDescripcion		= "Rio"
			loSalto.AtributoVirtual			= "Descripción (Carácter)"
			loSalto.Atributo				= "DESCRIPCION"
			loSalto.AtributoDescripcion		= loSalto.AtributoVirtual
			loSalto.UsaEtiquetaDeFramework	= .f.
			loSalto.PersonalizacionEtiqueta	= lcEtiqueta
			loSalto.grabar()
		catch to loError
		finally
			loSalto.release
		endtry
		loColAtributos = loServicioSaltosDeCampoYValoresSugeridos.ObtenerPersonalizacionDeEtiquetas( "RIO" )
		itemAtributo	= loColAtributos.Item(1)
		this.assertequals( "La cantidad de campos a personalizar es distinta de 1", 1, loColAtributos.Count )
		this.assertequals( "No devuelve la Etiqueta esperada", lcEtiqueta, itemAtributo.cEtiqueta )
		loServicioSaltosDeCampoYValoresSugeridos.release
		itemAtributo = null
		loColAtributos = null
	endfunc



enddefine