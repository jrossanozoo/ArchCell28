define class kontrolerLiquidacionEnProduccion as KontrolerConDetalle of KontrolerConDetalle.prg

	#If .F.
		Local This As kontrolerLiquidacionEnProduccion As kontrolerLiquidacionEnProduccion.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		dodefault()
		if !this.ValidarVersionDeMotor()
			lcMensaje = "Para usar costos en el módulo de producción debe actualizar el motor de base de datos a SQL Server 2022"
			messagebox(lcMensaje,16,"Restricción de acceso",10000)
			this.Release()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarVersionDeMotor() as Boolean
		local llRetorno as Boolean, lcNumVersion as String, lcMensaje as String
		if _Screen.Zoo.nVersionSQLNo = 0
			loColaborador = _screen.zoo.CrearObjeto( "ColaboradorBarraDeEstadoMotorDB", "ColaboradorBarraDeEstadoMotorDB.prg" )
			loColaborador.EjecutarSentenciaMotorDB( "c_DatosMotor", this.DataSessionId )
			select c_DatosMotor
			go top

			lcNumVersion = alltrim( c_DatosMotor.numVersion )
			do case
				case left(lcNumVersion,3) = '17.'
					_Screen.Zoo.nVersionSQLNo = 2025
				case left(lcNumVersion,3) = '16.'
					_Screen.Zoo.nVersionSQLNo = 2022
				case left(lcNumVersion,3) = '15.'
					_Screen.Zoo.nVersionSQLNo = 2019
				case left(lcNumVersion,3) = '14.'
					_Screen.Zoo.nVersionSQLNo = 2017
				case left(lcNumVersion,3) = '13.'
					_Screen.Zoo.nVersionSQLNo = 2016
				case left(lcNumVersion,3) = '12.'
					_Screen.Zoo.nVersionSQLNo = 2014
				case left(lcNumVersion,3) = '11.'
					_Screen.Zoo.nVersionSQLNo = 2012
				case left(lcNumVersion,3) = '10.5'
					_Screen.Zoo.nVersionSQLNo = 2008
				case left(lcNumVersion,3) = '10.'
					_Screen.Zoo.nVersionSQLNo = 2008
				case left(lcNumVersion,2) = '9.'
					_Screen.Zoo.nVersionSQLNo = 2005
			endcase
			use in c_DatosMotor
			release loColaborador
		endif
*!*			llRetorno = _Screen.Zoo.nVersionSQLNo >= 2014
		llRetorno = _Screen.Zoo.nVersionSQLNo < 2014
*!*			if !llRetorno
*!*				lcMensaje = "Para usar costos en el módulo de producción debe actualizar el motor de base de datos a SQL Server 2022"
*!*				messagebox(lcMensaje,16,"Restricción de acceso",10000)
*!*	*!*				goServicios.Errores.LevantarExcepcion( lcMensaje )
*!*			endif
		return llRetorno
	endfunc 

enddefine
