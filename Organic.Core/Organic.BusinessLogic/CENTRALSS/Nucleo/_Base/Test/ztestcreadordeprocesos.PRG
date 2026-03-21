**********************************************************************
Define Class ztestcreadordeprocesos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestcreadordeprocesos of ztestcreadordeprocesos.prg
	#ENDIF
	
	nHandleNotepad = 0
	*---------------------------------
	Function Setup
		
	EndFunc
	
	*---------------------------------
	Function TearDown
		local loCreador as Object
		if !empty(this.nHandleNotepad)
			loCreador = newobject( "CreadorDeProcesos", "CreadorDeProcesos.prg" )
			loCreador.MatarProceso(this.nHandleNotepad)	
		endif
	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestU_CrearProceso32BitConReferencia
	
		local loCreador as creadordeprocesos of creadordeprocesos.prg, lcExe as String, lcParametros as String, lcProcessInfo as String,;
			lnPID as Integer, loProceso as Object, loObjProcesos as Object, loColProc as Object, lnHandle as Integer

		lcExe = addbs(getenv("SystemRoot")) + "system32\notepad.exe"
		lcParametros = addbs(_Screen.zoo.app.crutadataconfig) + "dataconfig.ini"
		lcProcessInfo = replicate( chr( 0 ), 128 )
		
		loCreador = newobject( "CreadorDeProcesos", "CreadorDeProcesos.prg" )
		
		loCreador.crearproceso32bitconreferencia( lcExe, lcParametros,1, @lcProcessInfo )
		
		lnPID = loCreador.ObtenerPID( lcProcessInfo )
		this.nHandleNotepad = loCreador.ObtenerHandle( lcProcessInfo )

		this.asserttrue("A donde fue a parar el notepad.exe?", file( lcExe ))
		this.asserttrue("A donde fue a parar el dataconfig.ini?", file( lcParametros ))
		
		this.asserttrue( "No se encontro al notepad", goservicios.librerias.VerificarExistenciaDeProceso( "Notepad.exe", lnPID ))

		loObjProcesos = Getobject( "winmgmts:" )
		loColProc = loObjProcesos.ExecQuery( "select * from win32_process where Name = 'Notepad.exe' and ProcessId = '" + transform( lnPID ) + "'")

		for each loProceso in loColProc
			this.assertequals( "Error en la llamada al notepad", ["] + lcExe + [" ] + lcParametros, loProceso.CommandLine )
		endfor
	endfunc 

EndDefine
