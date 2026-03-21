define class ManagerErrores as Servicio of Servicio.Prg

	#IF .f.
		Local this as ManagerErrores of ManagerErrores.prg
	#ENDIF

	oParseadorErroresNet = null
	oColeccionErroresOle = null
	nCodigoErrorParaValidacionTimestamp = 9003
	nCodigoErrorParaValidacionTimestampPermiteVolverAGrabar = 9004

	*-----------------------------------------------------------------------------------------
	protected function oColeccionErroresOle_Access() as Object

		if !this.ldestroy and ( !vartype( this.oColeccionErroresOle ) = 'O' or isnull( this.oColeccionErroresOle ) )
			loFactory = _Screen.zoo.Crearobjeto( "FactoryMensajesErroresOleCustomizados" )
			this.oColeccionErroresOle = loFactory.ObtenerMensajesErroresOleCustomizados()
		endif

		return this.oColeccionErroresOle 
	endfunc

	*-----------------------------------------------------------------------------------------
	function LevantarExcepcion( txObjeto As Variant ) as Void

		do Case
			case vartype( txObjeto ) == "C"
				This.LevantarExcepcionTexto( txObjeto )

			case vartype( txObjeto ) == "O"
				do case
					case lower( txObjeto.Class ) = "zooinformacion"
						this.LevantarNotificacionWindows( txObjeto )
						This.LevantarExcepcionInformacion( txObjeto )
					case this.EsExcepcionOleNetExtender( txObjeto )
						This.LevantarExcepcionNetExtender( txObjeto )
					case ( lower( txObjeto.Class ) = "exception" or lower( txObjeto.Class ) = "zooexception" ) and this.EsExcepcionErrorOle( txObjeto )
						This.EnmascararExcepcionOle( txObjeto )
					case lower( txObjeto.Class ) = "exception" or lower( txObjeto.Class ) = "zooexception"
						This.LevantarExcepcionExcepcion( txObjeto )
					otherwise
						This.LevantarExcepcionDesconocida()
				EndCase	
			otherwise
				This.LevantarExcepcionDesconocida()
		EndCase	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsExcepcionErrorOle( toExcepcion as Exception ) as Boolean
		local llRetorno as Boolean

		llRetorno = toExcepcion.ErrorNo = 1426 ;
						and ( "OLE error code" $ toExcepcion.Message ;
						or "Código de error OLE" $ toExcepcion.Message )
		
		if !llRetorno
			llRetorno = this.ExceptionOleEnUserValue( toExcepcion )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EnmascararExcepcionOle( toExcepcion as Exception ) as Void
		local lcCodigoOle as String, lcMensajeErrorOle as String
		
		if this.ExceptionOleEnUserValue( toExcepcion )
			loException = toExcepcion.UserValue
		else
			loException = toExcepcion 
		endif
		
		lcCodigoOle = this.ExtraerCodigoOle( loException.Message )

		if this.oColeccionErroresOle.Buscar( upper( lcCodigoOle ) )
			lcMensajeErrorOle = this.oColeccionErroresOle.Item[ upper( lcCodigoOle ) ]
			this.LevantarExcepcionEnmascarada( lcMensajeErrorOle, loException )
		else
			this.LevantarExcepcionExcepcion( toExcepcion )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ExtraerCodigoOle( tcMensaje as String ) as String
		local lcCodigoOle as String, loRegex as Object, loMatch as Object
		
		loRegex = _Screen.Zoo.crearobjeto( "System.Text.RegularExpressions.Regex", "", "0x([0-9ABCDEF]{8}):", 1 + 32 + 8 + 512 )
		loMatch = loRegex.Match( tcMensaje  )
		lcCodigoOle = loMatch.Groups.Item[1].ToString()
		
		return lcCodigoOle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExceptionOleEnUserValue( toExcepcion as Exception ) as Void
		local llRetorno as Boolean
		
		if type( "toExcepcion.UserValue" ) = "O" and lower( toExcepcion.UserValue.BaseClass ) = "exception"
			with toExcepcion.UserValue
				llRetorno = .ErrorNo = 1426 and ( "OLE error code" $ .Message or "Código de error OLE" $ .Message )
			endwith
		endif

		return llRetorno 
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function EsExcepcionOleNetExtender( toExcepcion as Exception ) as Boolean
		return lower( toExcepcion.Class ) = "exception" and toExcepcion.ErrorNo=1429 and "OLE IDispatch"$toExcepcion.Message and ( "0 from ?: "$toExcepcion.Message or "0 de ?: "$toExcepcion.Message )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LevantarNotificacionWindows( toExcepcion as Exception ) as Void
		local lcMensaje as String
		lcMensaje = ""
		if goServicios.Ejecucion.TieneScriptCargado() and !this.TieneCapaGrafica()
			lcMensaje = this.ObtenerMensajeDeZooInformacion( toExcepcion, 202 )
		endif
		if !empty( lcMensaje )
			goServicios.NotificacionWindowsToast.EnviarPorTipo( 6, lcMensaje )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TieneCapaGrafica() as Boolean
		local lvuelta as Boolean
		lvuelta = ( pemstatus(_screen,"lUsaCapaDePresentacion",5) and _screen.lUsaCapaDePresentacion )
		return lvuelta
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeDeZooInformacion( toInformacion as zooInformacion of zooInformacion.prg, tnNumero as Integer ) as String
		local lcRespuesta as Boolean, lnCont as Integer
		lcRespuesta = ""
		with toInformacion
			for lnCont = 1 to toInformacion.Count
				if .item[ lnCont ].nNumero = tnNumero 
					lcRespuesta = .item[ lnCont ].cMensaje
					exit
				endif
			endfor
		endwith		
		return lcRespuesta
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LevantarExcepcionNetExtender( toExcepcion as Exception ) as Void
		local loEx as zooException of ZooException.prg, lcMensajeProcesado as String 
		loEx = newobject(  "zooexception", "zooexception.prg" )
		lcMensajeProcesado = this.oParseadorErroresNet.Parsear( toExcepcion.Message )
		with loEx
			.Grabar( toExcepcion )
			.Message = lcMensajeProcesado
			.AgregarInformacion( lcMensajeProcesado )
			.throw()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LevantarExcepcionInformacion( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local loEx as zooException of ZooException.prg
		loEx = newobject(  "zooexception", "zooexception.prg" )
		with loEx
			.CargarInformacion(  toInformacion )
			.throw()
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function LevantarExcepcionExcepcion( toExcepcion as Exception ) as Void
		local loEx as zooException of ZooException.prg
		loEx = newobject(  "zooexception", "zooexception.prg" )
		with loEx
			.Grabar( toExcepcion )
			.throw()
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function LevantarExcepcionTexto( tcMensaje as String, tnNumeroError as Integer ) as Void
		local loex as exception
		loEx = newobject(  "zooexception", "zooexception.prg" )
		with loEx
			.AgregarInformacion( tcMensaje )
			if empty( tnNumeroError )
			else
				.nZooErrorNo = tnNumeroError
			endif
			.Throw()
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function LevantarExcepcionDesconocida() as Void
		This.LevantarExcepcionTexto( "Error interno de sistema." )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oParseadorErroresNet_Access() as Object
		if !this.ldestroy and ( !vartype( this.oParseadorErroresNet ) = 'O' or isnull( this.oParseadorErroresNet ) )
			this.oParseadorErroresNet = _Screen.zoo.Crearobjeto( "ParseadorErroresNet" )
		endif
		return this.oParseadorErroresNet
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsExcepcionConInformacionEnumerada( toExcepcion as Object, tnNumero as Integer ) as Boolean
		local llRetorno as Boolean, loInformacion as Object
		llRetorno = .f.
		if ( type( "toExcepcion.UserValue.oInformacion" ) = "O" ;
			and !isnull( toExcepcion.UserValue.oInformacion ) ;
			and upper( toExcepcion.UserValue.oInformacion.Class ) = "ZOOINFORMACION" ;
			and toExcepcion.UserValue.oInformacion.Count > 0 )
			for each loInformacion in toExcepcion.UserValue.oInformacion foxobject
				if ( type( "loInformacion.nNumero" ) == "N" and loInformacion.nNumero = tnNumero )
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarExcepcionEnmascarada( tcMensaje as String, toException as Exception ) as Void
		local loEx as exception
		loEx = newobject(  "ZooException", "ZooException.prg" )
		with loEx
			.Message = tcMensaje 
			.AgregarInformacion( tcMensaje )
			.Grabar( toException )
			.Throw()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoErrorParaValidacionTimestamp() as Integer
		return this.nCodigoErrorParaValidacionTimestamp
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoErrorParaValidacionTimestampPermiteVolverAGrabar() as Integer
		return this.nCodigoErrorParaValidacionTimestampPermiteVolverAGrabar
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerExcepcionParaInformar( loError ) as Exception 
		local loEx as Exception
		loEx = _screen.zoo.crearobjeto( "zooexception" )
		if vartype(loError.uservalue) = "O" and pemstatus(loError.uservalue,"oinformacion",5)
			if loError.uservalue.oinformacion.HayInformacion()
				loEx.CargarInformacion( loError.uservalue.oinformacion )
			else
				loEx.AgregarInformacion( loError.uservalue.Message )
			endif
		else
			loEx.AgregarInformacion( loError.Message )
		endif
		
		return loEx 

	endfunc 

enddefine
