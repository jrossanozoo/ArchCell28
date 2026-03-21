**********************************************************************
Define Class zTestExportacionInstruccionesScript As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestExportacionInstruccionesScript Of zTestExportacionInstruccionesScript.prg
	#Endif

	*---------------------------------
	Function zTestU_Init
		local loInstrucciones as ExportacionInstruccionesScript of ExportacionInstruccionesScript.prg

		_screen.mocks.Agregarmock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "", "[Exportacion],[TimeOut]" )
		
		loInstrucciones = _Screen.zoo.crearobjeto( "ExportacionInstruccionesScript" )
		
		this.assertequals( "Error en la Base De Datos", "", loInstrucciones.cBaseDeDatos )
		this.assertequals( "Error en el time out", 360000,loInstrucciones.nTimeOut )
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )
		this.assertequals( "Error en la descripcion", "Exportacion", loInstrucciones.cTipo )
		this.assertequals( "Error en la descripcion", "exportando datos", loInstrucciones.cDescripcion )

		loInstrucciones.release()

		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "999999999999", "[Exportacion],[TimeOut]" )

		loInstrucciones = _Screen.zoo.crearobjeto( "ExportacionInstruccionesScript" )
		this.assertequals( "Error en el time out", 999999999999,loInstrucciones.nTimeOut )

		loInstrucciones.release()

		_screen.mocks.verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar
		local loInstrucciones as ExportacionInstruccionesScript of ExportacionInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ExportacionInstruccionesScript" )
		
		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "CodigoDeExportacion", "CodigoDeExportacion" )
		loParametros.Agregar( "AtributoFiltro", "AtributoFiltro" )
		loParametros.Agregar( "CodigoDesde", "CodigoDesde" )
		loParametros.Agregar( "CodigoHasta", "CodigoHasta" )
		loParametros.Agregar( "Estado", "Estado" )
		loParametros.Agregar( .t., "AccionTipoAntes" )
		loParametros.Agregar( "Entidad1", "Entidad" )
		loParametros.Agregar( "Evento1", "Evento" )

		loInstrucciones.Actualizar( loParametros )
		
		this.asserttrue( "No se debe obtuvener un script", empty( lcScript ) )
		this.assertequals( "Error en la cantidad de instrucciones", 2, loInstrucciones.Count )

		this.assertequals( "Instruccion 1 incorrecta", ;
			'this.oAtributoAuxiliar1 = _screen.zoo.crearobjeto( "LanzadorDeExportacionEnAccionAutomatica" )', ;
			loInstrucciones[1] )

		this.assertequals( "Instruccion 2 incorrecta", ;
			"this.oAtributoAuxiliar1.Procesar( 'CodigoDeExportacion', 'AtributoFiltro', 'CodigoDesde', 'CodigoHasta', 'Estado', .T. , 'Entidad1' , 'Evento1' )", ;
			loInstrucciones[2] )

		loInstrucciones.release()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar_ConParametrosErroneos
		local loInstrucciones as ExportacionInstruccionesScript of ExportacionInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ExportacionInstruccionesScript" )

		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "p1", "p1" )
		loParametros.Agregar( "p2", "p2" )
		loParametros.Agregar( "p3", "p3" )
		loParametros.Agregar( "p4", "p4" )
		loParametros.Agregar( "p5", "p5" )
		loParametros.Agregar( "p6", "p6" )
		
		loInstrucciones.Actualizar( loParametros )
		
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )

		loInstrucciones.release()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar_SinParametrosErroneos
		local loInstrucciones as ExportacionInstruccionesScript of ExportacionInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ExportacionInstruccionesScript" )
		loInstrucciones.Actualizar( null )
		
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )

		loInstrucciones.release()
	Endfunc


Enddefine
