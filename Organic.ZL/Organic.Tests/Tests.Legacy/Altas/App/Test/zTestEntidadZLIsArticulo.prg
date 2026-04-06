**********************************************************************
DEFINE CLASS zTestEntidadZLIsArticulo as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestEntidadZLIsArticulo OF zTestEntidadZLIsArticulo.PRG
	#ENDIF
	

	*-----------------------------------------------------------------------------------------
	function zTestTieneModuloComunicador
		local loEntidad as entidad OF entidad.prg, llRetorno as Boolean, lcCodigo1 as String, ;
			lcCodigo2 as String, lcCodigo3 as String, lnCantidad as Integer
		
		This.agregarmocks( "TIPOARTICULOITEMSERVICIO" )
		_screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', .T. )
		
		loEntidad = _screen.zoo.instanciarentidad( "Zlismodulo" )
		with loEntidad
			lnCantidad = loEntidad.ObtenerCantidadDeRegistrosConFiltro( "TipoModulo = '1' or TipoModulo = '2'" )
			
			.Nuevo()
			lcCodigo1 = .ccod
			.Descrip = "Modulo 1"
			.TipoModulo_Pk = "1"
			.Grabar()
			
			.Nuevo()
			lcCodigo2 = .ccod
			.Descrip = "Modulo 2"
			.TipoModulo_Pk = "2"
			.Grabar()
			
			.Nuevo()
			lcCodigo3 = .ccod
			.Descrip = "Modulo 3"
			.TipoModulo_Pk = "3"
			.Grabar()
			
			.Release()
		endwith

		loEntidad = _Screen.zoo.instanciarentidad( "ZLIsArticulos" )
		with loEntidad
			try
				.Codigo =  "0101"
				.Eliminar()
			catch to loError
			endtry
			
			.Nuevo()
			.Codigo =  "0101"
			.Descrip = "Descripcion 01"
			.TipoArticulo_Pk = "AB"
			with .DetalleModulos
				.Limpiar()
				.oItem.CodigoModulo_Pk = lcCodigo1
				.Actualizar()
			Endwith			
			
			This.assertequals( "Deberia Tener cargada la coleccion de Modulos con TRES items.", lnCantidad + 2, loEntidad.oModulos.Count  )
			
			llRetorno = .TieneModuloTI()
			This.asserttrue( "Deberia Tener un Modulo Toma de Inventario.", llRetorno )
					
			llRetorno = .EsTI( lcCodigo1 )
			This.asserttrue( "DEBERIA SER MODULO TI 1", llRetorno )
			llRetorno = .EsTI( lcCodigo2 )
			This.asserttrue( "NO DEBERIA SER MODULO TI 2", !llRetorno )
			llRetorno = .EsTI( lcCodigo3 )
			This.asserttrue( "NO DEBERIA SER MODULO TI 3", !llRetorno )
					
			llRetorno = .TieneModuloComunicador()
			This.asserttrue( "No deberia Tener un Modulo Comunicador.", !llRetorno )


			llRetorno = .EsComunicador( lcCodigo1 )
			This.asserttrue( "NO DEBERIA SER Comunicador 1", !llRetorno )
			llRetorno = .EsComunicador( lcCodigo2 )
			This.asserttrue( "DEBERIA SER Comunicador 2", llRetorno )
			llRetorno = .EsComunicador( lcCodigo3 )
			This.asserttrue( "NO DEBERIA SER Comunicador 3", !llRetorno )
			
									
			with .DetalleModulos
				.Limpiar()
				.oItem.CodigoModulo_Pk = lcCodigo2
				.Actualizar()
			Endwith			

			llRetorno = .TieneModuloTI()
			This.asserttrue( "No deberia Tener un Modulo Toma de Inventario.", !llRetorno )
			
			llRetorno = .TieneModuloComunicador()
			This.asserttrue( "Deberia Tener un Modulo Comunicador.", llRetorno )
			
			.Release()
		endwith		
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestObtenerClasificacionesDelArticulo
		local loArticulo as Object, loColClasificaciones as Collection, loDetalle as Object   

		loArticulo = _screen.zoo.instanciarentidad( "zlisarticulos" )
		this.asserttrue( "El articulo no tiene el método ObtenerClasificaciones() ", pemstatus( loArticulo, "ObtenerClasificaciones", 5 ))
		loColClasificaciones = loArticulo.ObtenerClasificaciones()
		this.assertequals( "Debería devolver una coleccion", "COLLECTION", upper( alltrim( loColClasificaciones.BaseClass )))
		loColClasificaciones.release()
		loTipoArt = _screen.zoo.instanciarentidad( "TIPOARTICULOITEMSERVICIO " )
		with loTipoArt
			try
				.cCod = "UU"
				.eliminar()
			catch	
			endtry 
			.Nuevo()
			.cCod = "UU"
			.descrip = "uu test"
			.grabar()
			.release()
		endwith
		with loArticulo
			try
				.codigo = "99-TEST"
				.eliminar()
			catch	
			endtry 
		endwith
		loClasificacion = _screen.zoo.instanciarentidad( "ClasificacionV2" )
		with loClasificacion 
			try
				.codigo = "01"
				.eliminar()
			catch	
			endtry 
			try
				.codigo = "02"
				.eliminar()
			catch	
			endtry 
			.nuevo()
			.codigo = "01"
			.nombre = "clasificacio c1"
			.grabar()
			.nuevo()
			.codigo = "02"
			.nombre = "clasificacio c2"
			.grabar()
			.release()
		endwith
		 			
		with loArticulo
			.nuevo()
			.Codigo = "99-TEST"
			.Descrip = "descripcion"
			.tipoarticulo_pk = "UU"
			loDetalle = loArticulo.DetalleClasificaciones
			with loDetalle  	
				.oItem.clasificacion_pk = "01"
				.actualizar()

				.LimpiarItem()				
				.oItem.clasificacion_pk = "02"
				.actualizar()
			endwith 
			.grabar() 	
			.codigo = "99-TEST"
			loColClasificaciones = .ObtenerClasificaciones()
			this.assertequals( "Debería tener dos items la coleccion de clasificaciones", 2, loColClasificaciones.Count )
			this.assertequals( "Debería tener la clasificación 01", "01", loColClasificaciones.item(1) )
			this.assertequals( "Debería tener la clasificación 02", "02", loColClasificaciones.item(2) )
			loColClasificaciones.release()
			.release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAntesDeGrabar
		local loEntidad as Object

		This.agregarmocks( "TIPOARTICULOITEMSERVICIO, CLASIFICACIONV2" )
		_screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', .T. )
											
			
		loEntidad = _Screen.zoo.instanciarentidad( "ZLIsArticulos" )
		
		with loEntidad
			try
				.Codigo =  "00-AB"
				.Eliminar()
			catch to loError
			endtry
			
			.Nuevo()
			.Codigo =  "00-AB"
			.Descrip = "Descripcion 01"
			.TipoArticulo_Pk = "AB"

			with .detaLLECLASIFICACIONES
				 .Limpiar()
				 .oiTEM.cLASIFICACION_PK = "02"
				 .oiTEM.DETALLECLASIFICACION  = "detalle 02"
				 .Actualizar()

				 .LimpiarItem()				
				 .oiTEM.cLASIFICACION_PK = "03"
				 .oiTEM.DETALLECLASIFICACION  = "detalle 03"
				 .Actualizar()

			endwith

			.grabar()
			
			this.assertequals("La descripcion del articulo no es la correcta 1", "Descripcion 01", alltrim( loentidad.detalleclasificaciones.item(1).descripcion ) )
			this.assertequals("La descripcion del articulo no es la correcta 2", "Descripcion 01", alltrim( loentidad.detalleclasificaciones.item(2).descripcion ) )

			.Codigo =  "00-AB"
			.Modificar()
			.Descrip = "Descripcion 02"
			
			.grabar()
			this.assertequals("La descripcion del articulo no es la correcta 3", "Descripcion 02", alltrim( loentidad.detalleclasificaciones.item(1).descripcion ) )
			this.assertequals("La descripcion del articulo no es la correcta 4", "Descripcion 02", alltrim( loentidad.detalleclasificaciones.item(2).descripcion ) )

	endwith 
	
	loEntidad.release()
		
	endfunc 

	
ENDDEFINE
