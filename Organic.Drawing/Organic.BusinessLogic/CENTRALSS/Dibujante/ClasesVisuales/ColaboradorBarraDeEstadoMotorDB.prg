define class ColaboradorBarraDeEstadoMotorDB as custom

	#if .f.
		local this as ColaboradorBarraDeEstadoMotorDB of ColaboradorBarraDeEstadoMotorDB.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function EjecutarSentenciaMotorDB( tcDatosMotor as String, tnSession as Integer ) as void

		goDatos.EjecutarSentencias( "select cast(@@version as char(256)) as version, cast(serverproperty ('machinename') as char(256)) as nombrePc, " +;
		"cast(serverproperty ('instancename') as char(256)) as instancia, cast(serverproperty ('servername') as char(256)) as server, " +;
		"cast(serverproperty ('productversion') as char(256)) as numVersion",;
		"CONCEPTOS", "", tcDatosMotor, tnSession ) &&set( "DataSession" ) ) && Usamos una tabla cualquiera para poder hacer la consulta.
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteristicasMotodDB( tcDatosMotor as String, tnSession as Integer ) as Void
		local lcSentencia as String
		lcSentencia = "select cast(@@version as char(256)) as version, cast(serverproperty ('machinename') as char(256)) as nombrePc, "
		lcSentencia = lcSentencia + "cast(serverproperty ('instancename') as char(256)) as instancia, cast(serverproperty ('servername') as char(256)) as server, "
		lcSentencia = lcSentencia + "cast(serverproperty ('productversion') as char(256)) as numVersion "
		goDatos.Ejecutarsql(lcSentencia, tcDatosMotor, tnSession)
	endfunc 

enddefine
