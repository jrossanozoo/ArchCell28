**********************************************************************
Define Class ztestcomponente as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestcomponente of ztestcomponente.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestSetearCombinacion
		local	loComponente as componente of componente.prg, loItem as Object

		This.AgregarMocks( "Numeraciones,Mexico" )
		
		loItem = newobject("custom" ) 
		loItem.AddProperty("nombre")
		loItem.AddProperty("presidente")		
		loItem.nombre = "mandionga"
		loItem.presidente = "Pepe Grillo"

		loComponente = _screen.zoo.crearobjeto( "din_componentemuralla" )
		loComponente.oEntidad = _screen.zoo.instanciarentidad( "mexico" )
		loComponente.inicializar()
		loComponente.SetearCombinacion( loItem )
	
		this.assertequals( "No se cargo el atributo nombre de la entidad adentro del componente muralla", "mandionga", loComponente.oEntidad.nombre )
		this.assertequals( "No se cargo el atributo presidente de la entidad adentro del componente muralla", "Pepe Grillo", loComponente.oEntidad.presidente )		
			
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestCargarEntidad
		local loComponente As Componente of Componente.prg

		_screen.mocks.agregarmock("mexico")
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Cargar', .T. )

		loComponente = _screen.zoo.crearobjeto( "din_componentemuralla" )
		loComponente.oEntidad = _screen.zoo.instanciarentidad( "mexico" )
		loComponente.inicializar()
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Buscar', .T. )
		This.AssertTrue( "Se debio cargar correctamente la combinacion", loComponente.CargarEntidad() )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Buscar', '*THROWUSUARIO' )		
		This.AssertTrue( "No se debio cargar correctamente la combinacion", !loComponente.CargarEntidad() )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Buscar', '*THROWNOUSUARIO' )				
		try
			loComponente.CargarEntidad()
			This.AssertTrue( "No tiro la excepcion", .F. )
		catch
		EndTry
		loComponente.Release()	

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestGrabar
		local	loComponente As Componente of Componente.prg,;
				loColeccionInsert as zoocoleccion OF zoocoleccion.prg, loColeccionUpdate as zoocoleccion OF zoocoleccion.prg ,;
				loColeccionDelete as zoocoleccion OF zoocoleccion.prg, loColeccionTest as zoocoleccion OF zoocoleccion.prg  
		 
		_screen.mocks.agregarmock( "mexico" )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'Cargar', .T. )
		
		loColeccionInsert = _screen.zoo.CrearObjeto( "zoocoleccion" )
		loColeccionInsert.agregar( "Insert" )
		loColeccionUpdate = _screen.zoo.CrearObjeto( "zoocoleccion" )
		loColeccionUpdate.agregar( "Update" )
		loColeccionDelete = _screen.zoo.CrearObjeto( "zoocoleccion" )
		loColeccionDelete.agregar( "Delete" )

		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'ObtenerSentenciasInsert', loColeccionInsert )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'ObtenerSentenciasUpdate', loColeccionUpdate )
		_screen.mocks.AgregarSeteoMetodo( 'mexico', 'ObtenerSentenciasDelete', loColeccionDelete )
						
		loComponente = _screen.zoo.crearobjeto("din_componentemuralla")
		loComponente.oEntidad = _screen.zoo.instanciarentidad("mexico")
		loComponente.inicializar()
 		
		loComponente.lNuevo = .T.
		loComponente.lEdicion = .F.
		loComponente.lEliminar = .F.
		loColeccionTest = loComponente.grabar()
		this.assertequals("La coleccion al estar en nuevo no es la correcta", "Insert", loColeccionTest.Item[1])
		
		loComponente.lNuevo = .F.
		loComponente.lEdicion = .T.
		loComponente.lEliminar = .F.
		loColeccionTest = loComponente.grabar()
		this.assertequals("La coleccion al estar en edicion no es la correcta", "Update", loColeccionTest.Item[1])
		
		loComponente.lNuevo = .F.
		loComponente.lEdicion = .F.
		loComponente.lEliminar = .T.
		loColeccionTest = loComponente.grabar()
		this.assertequals("La coleccion al estar en eliminar no es la correcta", "Delete", loColeccionTest.Item[1])
		
		loComponente.Release()	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEstaEnOCombinacion
		local loComponente as Object 
		
		loComponente = _screen.zoo.crearobjeto( "din_componentemuralla" )
		loComponente.Inicializar()

		this.asserttrue( "El atributo NOMBRE esta en la combinacion", loComponente.estaEnOCombinacion( "presidente" ) )
		this.asserttrue( "El atributo MATITO no esta en la combinacion", !loComponente.estaEnOCombinacion( "matito" ) )

		release loComponente

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestVerificarExistenciaVotacion
		local loComponente as Object 

		loComponente = _screen.zoo.crearobjeto( "din_componentemuralla" )

		This.asserttrue( "No se encontro el metodo votarCambioEstadoNUEVO." , pemstatus( loComponente ,"votarCambioEstadoNUEVO", 5 ) )
		This.asserttrue( "No se encontro el metodo votarCambioEstadoEliminar." , pemstatus( loComponente ,"votarCambioEstadoEliminar", 5 ) )		
		
		This.asserttrue( "No se encontro el metodo votarCambioEstadoModificar." , pemstatus( loComponente ,"votarCambioEstadoModificar", 5 ) )
		This.asserttrue( "No se encontro el metodo votarCambioEstadoCancelar." , pemstatus( loComponente ,"votarCambioEstadoCancelar", 5 ) )		
		This.asserttrue( "No se encontro el metodo votarCambioEstadoGrabar." , pemstatus( loComponente ,"votarCambioEstadoGrabar", 5 ) )		
		
		release loComponente

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestVerificarExistenciaValidarAtributo
		local loComponente as Object 

		loComponente = _screen.zoo.crearobjeto( "din_componentemuralla" )

		This.asserttrue( "No se encontro el metodo ValidarAtributo." , pemstatus( loComponente ,"validarAtributo", 5 ) )
		
		release loComponente

	endfunc 


EndDefine
