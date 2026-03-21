**********************************************************************
Define Class zTestVerificadorDll as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestVerificadorDll of zTestVerificadorDll.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
	EndFunc
	
	*---------------------------------
	Function TearDown
	EndFunc

	*---------------------------------------------------------------------------------------------	
	Function zTestValidarExistenciaDLLs
		Local loVerificadorDll As VerificadorDll of VerificadorDll.prg , lcRutaSeguridad as String, llBorrar as Boolean, loArchivos as Object, ;
			lcRutaGdsDll as String

		lcDirWinSysConArchivo = GETENV( "WINDIR" ) + "\SYSTEM32\" 

		loVerificadorDll = _screen.zoo.crearobjeto( "VerificadorDll" )

		llRetorno = loVerificadorDll.Verificar()
		This.asserttrue( "No existen todos los archivos DLLs", llRetorno )

		loArchivos = _screen.zoo.CrearObjeto( "manejoArchivos" )
		lcRutaGdsDll = addbs( justpath( justpath( addbs( _screen.zoo.cRutaInicial ) ) ) ) + "Dlls"
		loArchivos.setearatributos( "N", addbs( lcRutaGdsDll ) + "gds.dll" )
		rename ( addbs( lcRutaGdsDll ) + "gds.dll" ) To ( addbs( lcRutaGdsDll ) + "gds.dl1" )
		llRetorno = loVerificadorDll.Verificar()
		This.asserttrue( "Se encontro el archivo GDS.DLL, cuando no deberia encontrarlo", !llRetorno )
		rename ( addbs( lcRutaGdsDll ) + "gds.dl1" ) To ( addbs( lcRutaGdsDll ) + "gds.dll" )
		loArchivos.setearatributos( "R", addbs( lcRutaGdsDll ) + "gds.dll" )
		loArchivos = null

		loVerificadorDll.Release()

	endfunc


	*-----------------------------------------------------------------------------------------
	function zTestRegistrarDllDesdeInstalacion
		local loVerificadorDll as VerificadorDll of Verificadordll.prg

		loVerificadorDll = _screen.zoo.crearobjeto( "VerificadorDll" )
		

		loItem = _screen.zoo.crearobjeto( "ArchivoDll", "VerificadorDll.prg" )
		
		with loItem
			.NombreRegistrado = "Clase1"
			.NombreArchivo = "zTestVerificadorDll.fxp"
			.EsRegistrable = .t.
			.VerificarRegistro = .t.
			.RutaEnInstalacion = ""
		endwith

		loVerificadorDll.oFuncionesRegistry = newobject( "MockFuncionesRegistry" )
		loVerificadorDll.oFuncionesRegistry.cRetornoFuncion = "NoExiste.prg"
		loVerificadorDll.oZoo = newobject( "zooMock" )
		loVerificadorDll.cRutaComponentes = _screen.zoo.cRutaInicial + "_base\test\"

		loVerificadorDll.VerificarRegistroExistente( loItem ) 

		This.assertequals( "El comando no es el correcto.", ;
							'REGSVR32.EXE -S "' + upper( _screen.zoo.cRutaInicial ) + '_BASE\TEST\ZTESTVERIFICADORDLL.FXP"' , ;
							upper( alltrim( loVerificadorDll.oZoo.ComandoEjecutado ) ) )
		
		loVerificadorDll.Release()	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestNoRegistrarDllDesdeInstalacionSiExisteRegistro
		local loVerificadorDll as VerificadorDll of Verificadordll.prg

		loVerificadorDll = _screen.zoo.crearobjeto( "VerificadorDll" )
		loItem = _screen.zoo.crearobjeto( "ArchivoDll", "VerificadorDll.prg" )
		
		with loItem
			.NombreRegistrado = "Clase1"
			.NombreArchivo = "Archivo.dll"
			.EsRegistrable = .t.
			.VerificarRegistro = .t.
			.RutaEnInstalacion = "Carpeta1"
		endwith

		loVerificadorDll.oFuncionesRegistry = newobject( "MockFuncionesRegistry" )
				loVerificadorDll.oFuncionesRegistry.cRetornoFuncion = _screen.zoo.cRutaInicial + "pkware.sys"
		loVerificadorDll.oZoo = newobject( "zooMock" )

		loVerificadorDll.VerificarRegistroExistente( loItem ) 

		This.assertequals( "El comando no es el correcto.", "", alltrim( loVerificadorDll.oZoo.ComandoEjecutado ) )
		
		loVerificadorDll.Release()
	endfunc 
	
EndDefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class MockFuncionesRegistry as Custom
	
	cRetornoFuncion = ""
	*-----------------------------------------------------------------------------------------
	function ObtenerArchivoAsociado( tcClave as String ) as String
		return This.cRetornoFuncion && "Archivo.dll"
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class zooMock as Custom
	
	ComandoEjecutado = ""
	*-----------------------------------------------------------------------------------------
	function Ejecutados( tcComando as String ) as Void
		This.ComandoEjecutado = tcComando
	endfunc 

enddefine


