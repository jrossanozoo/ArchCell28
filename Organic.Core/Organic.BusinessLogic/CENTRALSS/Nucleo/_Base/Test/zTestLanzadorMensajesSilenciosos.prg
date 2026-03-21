**********************************************************************
Define Class zTestLanzadorMensajesSilenciosos As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestLanzadorMensajesSilenciosos Of zTestLanzadorMensajesSilenciosos.prg
	#Endif

	*---------------------------------
	Function Setup

	Endfunc

	*---------------------------------
	Function TearDown

	Endfunc

	*-----------------------------------------------------------------------------------------
	function zTestEnviar
		local loLanzador as Object, lcLog as String, loInfo as zooinformacion of zooInformacion.prg
		
*!*			this.agregarmocks( "ManagerEjecucion" )
*!*			_screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Tienescriptcargado', .T. )
*!*			
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		goServicios.Logueos = newobject( "Mock_ManagerLogueosTest" )

		local loLanzador 
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorMensajesSilenciosos" )

		with goServicios.Logueos.oInfoLogueo
			lnRetorno = loLanzador.Enviar( "Logueo 1" )
			this.assertequals( "El retorno es incorrecto 1", 1, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 1", 1, .Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto 1", "NucleoLogueo 1", lcLog )

			lnRetorno = loLanzador.Enviar( "Logueo 1", 1 )
			this.assertequals( "El retorno es incorrecto 2", 1, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 2", 1, goServicios.Logueos.oInfoLogueo.Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto  2", "NucleoLogueo 1", lcLog )

			lnRetorno = loLanzador.Enviar( "Logueo 1", 2 )
			this.assertequals( "El retorno es incorrecto 3", 3, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 3", 1, goServicios.Logueos.oInfoLogueo.Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto 3", "NucleoLogueo 1", lcLog )

			lnRetorno = loLanzador.Enviar( "Logueo 1", 3 )
			this.assertequals( "El retorno es incorrecto 4", 6, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 4", 1, goServicios.Logueos.oInfoLogueo.Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto 4", "NucleoLogueo 1", lcLog )

			lnRetorno = loLanzador.Enviar( "Logueo 1", 4 )
			this.assertequals( "El retorno es incorrecto 5", 6, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 5", 1, goServicios.Logueos.oInfoLogueo.Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto 5", "NucleoLogueo 1", lcLog )

			lnRetorno = loLanzador.Enviar( "Logueo 1", 5 )
			this.assertequals( "El retorno es incorrecto 6", 4, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 6", 1, goServicios.Logueos.oInfoLogueo.Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto 6", "NucleoLogueo 1", lcLog )

			loInfo = _screen.zoo.crearobjeto( "ZooInformacion" )
			loInfo.AgregarInformacion( "Log 1" )
			loInfo.AgregarInformacion( "Log 2" )
			loInfo.AgregarInformacion( "Log 3" )
			loInfo.AgregarInformacion( "Log 4" )
	
			lnRetorno = loLanzador.Enviar( loInfo )
			this.assertequals( "El retorno es incorrecto 7", 1, lnRetorno )
			this.assertequals( "La cantidad de logueos es incorrecta 7", 1, goServicios.Logueos.oInfoLogueo.Count )
			lcLog = strtran( .Item[ 1 ], chr( 13 ) + chr( 10 ) )
			this.assertequals( "El mensaje de logueo es incorrecto 7", "NucleoLog 4" + chr( 9 ) + "Log 3" + chr( 9 ) + "Log 2" + chr( 9 ) + "Log 1", lcLog )		
		endwith
		
		loLanzador.Release()
		
		goServicios.Release()		

		_screen.mocks.verificarejecuciondemocks()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_EnviarSinEsperaNoLoguear
		local lcLog as String

*!*			this.agregarmocks( "ManagerEjecucion" )
*!*			_screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Tienescriptcargado', .T. )

		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		goServicios.Logueos = newobject( "Mock_ManagerLogueosTest" )

		local loLanzador 
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorMensajesSilenciosos" )

		with goServicios.Logueos.oInfoLogueo
			loLanzador.EnviarSinEspera( "Logueo 1" )
			this.assertequals( "La cantidad de logueos es incorrecta 1", 0, .Count )
		endwith

		loLanzador.Release()
		
		goServicios.Release()
		
		_screen.mocks.verificarejecuciondemocks()
	endfunc 
EndDefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_ManagerLogueosTest as ManagerLogueos of ManagerLogueos.prg

	oInfoLogueo = null

	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		dodefault()
		this.oInfoLogueo = newobject( "Collection" )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function Guardar( toObjetoLogueo as Object ) as Void
		local loItem as Object, loNivel as object, loColeccion as zoocoleccion OF zoocoleccion.prg
		
		loColeccion = toObjetoLogueo.ObtenerLogueos()
		
		this.oInfoLogueo.Remove( -1 )
		for each loNivel in loColeccion foxobject
			for each loItem in loNivel foxobject
				this.oInfoLogueo.add( loItem.Descripcion )
			endfor
		endfor
		
		dodefault( toObjetoLogueo )
	endfunc
enddefine
