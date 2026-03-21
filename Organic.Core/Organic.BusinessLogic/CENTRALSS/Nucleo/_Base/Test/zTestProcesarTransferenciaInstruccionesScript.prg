**********************************************************************
Define Class zTestProcesarTransferenciaInstruccionesScript As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestProcesarTransferenciaInstruccionesScript Of zTestProcesarTransferenciaInstruccionesScript.PRG
	#Endif

	*---------------------------------
	Function zTestU_Init
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg

		_screen.mocks.Agregarmock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "", "[ProcesarTransferencia],[TimeOut]" )
		
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )
		
		this.assertequals( "Error en la Base De Datos", "", loInstrucciones.cBaseDeDatos )
		this.assertequals( "Error en el time out", 7200000,loInstrucciones.nTimeOut )
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )
		this.assertequals( "Error en la descripcion", "ProcesarTransferencia", loInstrucciones.cTipo )
		this.assertequals( "Error en la descripcion", "empaquetando datos", loInstrucciones.cDescripcion )

		loInstrucciones.release()

		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "999999999999", "[ProcesarTransferencia],[TimeOut]" )

		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )
		this.assertequals( "Error en el time out", 999999999999,loInstrucciones.nTimeOut )

		loInstrucciones.release()

		_screen.mocks.verificarejecuciondemocks()
	endfunc
	
	*---------------------------------
	Function zTestU_Release
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg
		
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )
		loInstrucciones.release()
		this.assertequals( "Error en la Base De Datos", null, loInstrucciones )
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )

		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test1", "TransferenciaSeleccionada" )
		loParametros.Agregar( .f., "EsCentralizada" )
		loParametros.Agregar( .f., "EsAgrupada" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( "test1 nombre", "NombreDeTransferencia" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Filtros" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Destinos" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "DestinosLince" )
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )
		loInstrucciones.Actualizar( loParametros )
		
		this.assertequals( "Error en la cantidad de instrucciones", 6, loInstrucciones.Count )
		this.assertequals( "No se actualizo la descripcion", "empaquetando datos 'test1 nombre'", loInstrucciones.cDescripcion )

		loInstrucciones.release()
	Endfunc

	*---------------------------------
	Function zTestU_VerificarInstrucciones
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )

		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test1", "TransferenciaSeleccionada" )
		loParametros.Agregar( .f., "EsCentralizada" )
		loParametros.Agregar( .f., "EsAgrupada" )
		loParametros.Agregar( "test1 nombre", "NombreDeTransferencia" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Filtros" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Destinos" )	
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "DestinosLince" )
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )	
		loInstrucciones.Actualizar( loParametros )

		lcIns = "loTransferencia = goServicios.transferencias.Procesar( 'test1', .F., null )"
		this.assertequals( "Instrucciones incorrecta 1", lcIns, loInstrucciones.Item[1] )
		
		lcIns = "loTransferencia.lRequiereValidacionAdicional = .F."
		this.assertequals( "Instrucciones incorrecta 2", lcIns, loInstrucciones.Item[2] )
		
		lcIns = "loTransferencia.cArchivo = 'CNOMBRE DE ARCHIVOOO'"
		this.assertequals( "Instrucciones incorrecta 3", lcIns, loInstrucciones.Item[3] )
	
		lcIns = "goMonitor.EnviarTransferencia( loTransferencia )"
		this.assertequals( "Instrucciones incorrecta 4", lcIns, loInstrucciones.Item[4] )		

		loInstrucciones.release()
	endfunc


	*---------------------------------
	Function zTestU_SetearDescripcion
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )
		***** test 1 *****
		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test1", "TransferenciaSeleccionada" )
		loParametros.Agregar( .f., "EsCentralizada" )
		loParametros.Agregar( .f., "EsAgrupada" )
		loParametros.Agregar( "test1 nombre", "NombreDeTransferencia" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Filtros" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Destinos" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "DestinosLince" )
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )		
		loInstrucciones.Actualizar( loParametros )
		
		this.assertequals( "La descripcion es incorrecta 1.", "empaquetando datos 'test1 nombre'", loInstrucciones.cDescripcion )		

		***** test 2 *****
		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test2", "TransferenciaSeleccionada" )
		loParametros.Agregar( .f., "EsCentralizada" )
		loParametros.Agregar( .t., "EsAgrupada" )
		loParametros.Agregar( "test2 nombress", "NombreDeTransferencia" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( "cNombreTransferenciaAgrupada", "cNombreTransferenciaAgrupada" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Filtros" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Destinos" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "DestinosLince" )	
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )	
		loInstrucciones.Actualizar( loParametros )
		
		this.assertequals( "La descripcion es incorrecta 2.", "empaquetando datos 'test2 nombress'", loInstrucciones.cDescripcion )	
		
		***** test 3 *****
		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test3", "TransferenciaSeleccionada" )
		loParametros.Agregar( .f., "EsCentralizada" )
		loParametros.Agregar( .t., "EsAgrupada" )
		loParametros.Agregar( "cNombreTransferenciaAgrupada", "cNombreTransferenciaAgrupada" )
		loParametros.Agregar( "Descripcion de la transferencia test3 nombre", "NombreDeTransferencia" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Filtros" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "Destinos" )
		loParametros.Agregar( _Screen.zoo.crearobjeto( "zooColeccion" ), "DestinosLince" )
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )		
		loInstrucciones.Actualizar( loParametros )
		
		this.assertequals( "La descripcion es incorrecta 3.", "empaquetando datos 'descripcion de la transferencia test3 nombre'", loInstrucciones.cDescripcion )		
		
		loInstrucciones.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ProcesarUnaAgrupadaDosFiltrosYDosDestinos
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg, loFiltro as zoocoleccion OF zoocoleccion.prg, loDestino as zoocoleccion OF zoocoleccion.prg, ;
			lnI as Integer
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )

		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test1", "TransferenciaSeleccionada" )
		loParametros.Agregar( .f., "EsCentralizada" )
		loParametros.Agregar( .t., "EsAgrupada" )
		loParametros.Agregar( "test1 nombre", "NombreDeTransferencia" )
		loParametros.Agregar( _screen.Zoo.CrearObjeto( "zooColeccion" ), "DestinosLince" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( "resumen del dia de ventas magicas" ,"cNombreTransferenciaAgrupada" )
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )
		
		*** filtro 1 ****
		loFiltro = _Screen.zoo.crearobjeto( "zooColeccion" )
		loFiltro.agregar( _Screen.zoo.crearobjeto( "iTemFiltro", "ObjetoTransferencia.prg" ) )
		loFiltro.item[1].Valor1 = "aaaaad"
		loFiltro.item[1].Valor2 = "aaaaag"
		loParametros.Agregar( loFiltro, "Filtros" )
		
		*** filtro 2 ****
		loFiltro.agregar( _Screen.zoo.crearobjeto( "iTemFiltro", "ObjetoTransferencia.prg" ) )
		loFiltro.item[2].Valor1 = "ccccc"
		loFiltro.item[2].Valor2 = "22222"
		
		*** destino 1 ****
		loDestino = _Screen.zoo.crearobjeto( "zooColeccion" )
		loDestino.Agregar( _Screen.zoo.crearobjeto( "iTemDestino", "ObjetoTransferencia.prg" ) )
		loParametros.Agregar( loDestino, "Destinos" )	
		loDestino.item[1].cDestino = "C:\TUTANCAMON1"
		loDestino.item[1].cDescripcion = "IRON MAN 1"
		loDestino.item[1].lABaseDeDatos = .t.
		loDestino.item[1].lEsBuzonLince = .f.
		
		*** destino 2 ****
		loDestino.Agregar( _Screen.zoo.crearobjeto( "iTemDestino", "ObjetoTransferencia.prg" ) )
		loDestino.item[2].cDestino = "C:\TUTANCAMON2"
		loDestino.item[2].cDescripcion = "IRON MAN 2"
		loDestino.item[2].lABaseDeDatos = .f.
		loDestino.item[2].lEsBuzonLince = .f.

		loInstrucciones.Actualizar( loParametros )

		***** Assert ****
		lnI = 1
		lcIns = "loTransferencia  = goServicios.transferencias.ProcesarTransferenciaAgrupada( test1 )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loTransferencia.cNombreTransferenciaAgrupada = 'resumen del dia de ventas magicas'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem = loTransferencia.oFiltros.iTem[1]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem.Valor1 = [aaaaad]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem.Valor2 = [aaaaag]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem = loTransferencia.oFiltros.iTem[2]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loItem.Valor1 = [ccccc]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loItem.Valor2 = [22222]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loTransferencia.cArchivo = 'CNOMBRE DE ARCHIVOOO'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loDestino = loTransferencia.CrearObjetoDestino()"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loTransferencia.oDestinos.Agregar( loDestino )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loDestino.cDescripcion = 'IRON MAN 1'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loDestino.cDestino = 'C:\TUTANCAMON1'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loDestino.lABaseDeDatos = .T."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )										

		lnI = lnI + 1
		lcIns = "loDestino.lEsBuzonLince = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )										

		lnI = lnI + 1
		lcIns = "loDestino = loTransferencia.CrearObjetoDestino()"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loTransferencia.oDestinos.Agregar( loDestino )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )			

		lnI = lnI + 1
		lcIns = "loDestino.cDescripcion = 'IRON MAN 2'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loDestino.cDestino = 'C:\TUTANCAMON2'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loDestino.lABaseDeDatos = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loDestino.lEsBuzonLince = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )										

		lnI = lnI + 1
		lcIns = "goServicios.Transferencias.FinalizarTransferenciaAgrupada( loTransferencia )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )									

		loInstrucciones.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ProcesarTransferenciaConDosFiltrosYDosDestinos
		local loInstrucciones as ProcesarTransferenciaInstruccionesScript of ProcesarTransferenciaInstruccionesScript.prg, lcScript as string, ;
			loParametros as zoocoleccion OF zoocoleccion.prg, loFiltro as zoocoleccion OF zoocoleccion.prg, loDestino as zoocoleccion OF zoocoleccion.prg, ;
			lnI as Integer
					
		loInstrucciones = _Screen.zoo.crearobjeto( "ProcesarTransferenciaInstruccionesScript" )

		loParametros = _Screen.zoo.crearobjeto( "zooColeccion" )
		loParametros.Agregar( "test1", "TransferenciaSeleccionada" )
		loParametros.Agregar( .t., "EsCentralizada" )
		loParametros.Agregar( .f., "EsAgrupada" )
		loParametros.Agregar( "test1 nombre", "NombreDeTransferencia" )
		loParametros.Agregar( _screen.Zoo.CrearObjeto( "zooColeccion" ), "DestinosLince" )
		loParametros.Agregar( "CNOMBRE DE ARCHIVOOO" ,"NombreDeArchivo" )
		loParametros.Agregar( "resumen del dia de ventas magicas" ,"cNombreTransferenciaAgrupada" )
		loParametros.Agregar( .f., "lRequiereValidacionAdicional" )
		
		*** filtro 1 ****
		loFiltro = _Screen.zoo.crearobjeto( "zooColeccion" )
		loFiltro.agregar( _Screen.zoo.crearobjeto( "iTemFiltro", "ObjetoTransferencia.prg" ) )
		loFiltro.item[1].Valor1 = "aaaaad"
		loFiltro.item[1].Valor2 = "aaaaag"
		loParametros.Agregar( loFiltro, "Filtros" )
		
		*** filtro 2 ****
		loFiltro.agregar( _Screen.zoo.crearobjeto( "iTemFiltro", "ObjetoTransferencia.prg" ) )
		loFiltro.item[2].Valor1 = "ccccc"
		loFiltro.item[2].Valor2 = "22222"
		
		*** destino 1 ****
		loDestino = _Screen.zoo.crearobjeto( "zooColeccion" )
		loDestino.Agregar( _Screen.zoo.crearobjeto( "iTemDestino", "ObjetoTransferencia.prg" ) )
		loParametros.Agregar( loDestino, "Destinos" )	
		loDestino.item[1].cDestino = "C:\TUTANCAMON1"
		loDestino.item[1].cDescripcion = "IRON MAN 1"
		loDestino.item[1].lABaseDeDatos = .t.
		loDestino.item[1].lEsBuzonLince = .f.
		
		*** destino 2 ****
		loDestino.Agregar( _Screen.zoo.crearobjeto( "iTemDestino", "ObjetoTransferencia.prg" ) )
		loDestino.item[2].cDestino = "C:\TUTANCAMON2"
		loDestino.item[2].cDescripcion = "IRON MAN 2"
		loDestino.item[2].lABaseDeDatos = .f.
		loDestino.item[2].lEsBuzonLince = .f.

		loInstrucciones.Actualizar( loParametros )

		***** Assert ****
		lnI = 1
		lcIns = "loTransferencia = goServicios.transferencias.Procesar( 'test1', .T., null )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loTransferencia.lRequiereValidacionAdicional = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
				
		lnI = lnI + 1
		lcIns = "loItem = loTransferencia.oFiltros.iTem[1]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem.Valor1 = [aaaaad]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem.Valor2 = [aaaaag]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loItem = loTransferencia.oFiltros.iTem[2]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loItem.Valor1 = [ccccc]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loItem.Valor2 = [22222]"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loTransferencia.cArchivo = 'CNOMBRE DE ARCHIVOOO'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )
		
		lnI = lnI + 1
		lcIns = "loDestino = loTransferencia.CrearObjetoDestino()"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loTransferencia.oDestinos.Agregar( loDestino )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loDestino.cDescripcion = 'IRON MAN 1'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loDestino.cDestino = 'C:\TUTANCAMON1'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )

		lnI = lnI + 1
		lcIns = "loDestino.lABaseDeDatos = .T."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )										

		lnI = lnI + 1
		lcIns = "loDestino.lEsBuzonLince = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )										

		lnI = lnI + 1
		lcIns = "loDestino = loTransferencia.CrearObjetoDestino()"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loTransferencia.oDestinos.Agregar( loDestino )"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )			

		lnI = lnI + 1
		lcIns = "loDestino.cDescripcion = 'IRON MAN 2'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loDestino.cDestino = 'C:\TUTANCAMON2'"
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loDestino.lABaseDeDatos = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )	

		lnI = lnI + 1
		lcIns = "loDestino.lEsBuzonLince = .F."
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )										

		lnI = lnI + 1
		lcIns = "goMonitor.EnviarTransferencia( loTransferencia )"
		
		this.assertequals( "Instrucciones incorrecta " + transform( lnI ), lcIns, loInstrucciones.Item[lnI] )									

		loInstrucciones.release()
	endfunc 	
Enddefine
