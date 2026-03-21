define class ManagerMonitor As Servicio of Servicio.prg

	#IF .f.
		Local this as ManagerMonitor of ManagerMonitor.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Enviar( toListado As Object ) as Void
		local loMockMonitor As MockMonitor As MockMonitor.prg, loError as Exception
		with this
			try
				loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
				loMockMonitor.Recibir( toListado )
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				loMockMonitor.Release()
			EndTry
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarTransferencia( toTransferencia As Object ) as Void
		local loMockMonitor As MockMonitor As MockMonitor.prg, loError as Exception
		try
			loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
			loMockMonitor.RecibirTransferencia( toTransferencia )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loMockMonitor.Release()
		EndTry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CrearCarpetaTemporal() as String
		local lcNombreRutaTemp as String, lcRetorno as String, loError as Exception
		try		
			lcNombreRutaTemp = addbs( _screen.zoo.obtenerrutatemporal() ) + "Paquete"
			if directory( lcNombreRutaTemp )
				lcRetorno = lcNombreRutaTemp
			else
				try
					md ( lcNombreRutaTemp )
					lcRetorno = lcNombreRutaTemp
				catch
					lcRetorno = ""
				endtry
			endif
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		EndTry
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ArmarZipTransferenciaAgrupada( toTransferenciaHijo as object, toTransferencia as object, tcRutaTemporalZip as String )
		local loMockMonitor As MockMonitor As MockMonitor.prg, loError as Exception
		try
			loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
			loMockMonitor.RecibirTransferenciaAgrupada( toTransferenciaHijo, toTransferencia, tcRutaTemporalZip )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loMockMonitor.Release()
		EndTry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EnviarExportacion( toExportacion as Object )  as Void
		local loMockMonitor As MockMonitor As MockMonitor.prg, loError as Exception
		try
			loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
			loMockMonitor.RecibirExportacion( toExportacion )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loMockMonitor.Release()
		EndTry
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EnviarImportacion( toImportacion as Object )  as Void
		local loMockMonitor As MockMonitor As MockMonitor.prg, loError as Exception
		try
			loMockMonitor = _Screen.Zoo.Crearobjeto( "MockMonitor" )
			loMockMonitor.RecibirImportacion( toImportacion )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loMockMonitor.Release()
		EndTry
	endfunc
	
EndDefine