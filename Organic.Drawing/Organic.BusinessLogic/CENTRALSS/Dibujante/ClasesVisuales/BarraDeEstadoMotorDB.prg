define class BarraDeEstadoMotorDB as ZooSession of ZooSession.prg

	#if .f.
		local this as BarraDeEstadoMotorDB of BarraDeEstadoMotorDB.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function ObtenerMotorDB() as String
		local lcMotor as String, lcNombrePc as String, lcInstancia as String, lcServer as String, lcVersion as String, ;
			lnPosicionCorte as Integer, lcNumVersion as String, loColaborador as Objects, lcNombrePcOriginal as String
			
		lcNombrePcOriginal = alltrim( upper( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ) )
			
		loColaborador = _screen.zoo.CrearObjeto( "ColaboradorBarraDeEstadoMotorDB", "ColaboradorBarraDeEstadoMotorDB.prg" )
		loColaborador.EjecutarSentenciaMotorDB( "c_DatosMotor", this.DataSessionId )
		
		lcMotor = ""
		if used( "c_DatosMotor" )
			select c_DatosMotor
			scan
				lnPosicionCorte = atc( "-", c_DatosMotor.version )
				lcVersion = alltrim( left( c_DatosMotor.version, lnPosicionCorte - 1 ) )
				lcNumVersion = alltrim( c_DatosMotor.numVersion )
				lcNombrePc = alltrim( c_DatosMotor.nombrePc )
				lcServer = alltrim( c_DatosMotor.server )
				lcInstancia = iif( !isnull( c_DatosMotor.instancia ), alltrim( c_DatosMotor.instancia ), lcNombrePc ) 
							 	
				if upper( alltrim( lcNombrePc ) ) != lcNombrePcOriginal 
					lcMotor = lcServer
				else
					lcMotor = lcInstancia
				endif
				
				this.RegistrarVersionSQL( lcNumVersion )
				
				lcMotor = lcMotor + " - " + lcVersion + " (" + lcNumVersion + ")"
			endscan
			use in( "c_DatosMotor" )
		endif
		
		return lcMotor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RegistrarVersionSQL( tcVersionSQL as String ) as Void
		local lcVersionSQL as String, lnVersionSQL as Integer
		do case
			case left(tcVersionSQL,3) = '17.'
				lnVersionSQL = 2025
				lcVersionSQL = '2025'
			case left(tcVersionSQL,3) = '16.'
				lnVersionSQL = 2022
				lcVersionSQL = '2022'
			case left(tcVersionSQL,3) = '15.'
				lnVersionSQL = 2019
				lcVersionSQL = '2019'
			case left(tcVersionSQL,3) = '14.'
				lnVersionSQL = 2017
				lcVersionSQL = '2017'
			case left(tcVersionSQL,3) = '13.'
				lnVersionSQL = 2016
				lcVersionSQL = '2016'
			case left(tcVersionSQL,3) = '12.'
				lnVersionSQL = 2014
				lcVersionSQL = '2014'
			case left(tcVersionSQL,3) = '11.'
				lnVersionSQL = 2012
				lcVersionSQL = '2012'
			case left(tcVersionSQL,3) = '10.5'
				lnVersionSQL = 2008
				lcVersionSQL = '2008 R2'
			case left(tcVersionSQL,3) = '10.'
				lnVersionSQL = 2008
				lcVersionSQL = '2008'
			case left(tcVersionSQL,2) = '9.'
				lnVersionSQL = 2005
				lcVersionSQL = '2005'
			otherwise
				lnVersionSQL = 0
				lcVersionSQL = ''
		endcase
		_Screen.Zoo.nVersionSQLNo = lnVersionSQL
		_Screen.Zoo.cVersionSQLNo = lcVersionSQL
	endfunc 

enddefine
