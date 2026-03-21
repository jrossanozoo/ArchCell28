**********************************************************************
Define Class ztestZooException as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestZooException of ztestZooException.prg
	#ENDIF
	
	loExTest = Null

	*---------------------------------
	Function Setup
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function zTestErroresAnidados

		local loError as Exception, loEx as Exception, lxResultado as Variant, loClase as Object
		loClase = newobject( "prueba" )
		loEx = Newobject( "ZooException", "ZooException.prg" )
		try
			lxResultado = loclase.ObtenerResultado()						
		Catch To loError
		 
			With loEx
				.Grabar( loError )
			EndWith
		endtry
		
		this.asserttrue("El UserValue No tiene un objeto anidado", vartype( loError.UserValue ) = "O" ) 
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestInformacion

		local loError as Exception, loEx as Exception, lxResultado as Variant, loClase as Object, loInfo as Object 
		
		loInfo = _screen.zoo.crearobjeto( "zooInformacion" )
		loInfo.AgregarInformacion( "Alguna Info" )
		loClase = newobject( "prueba" )
		loEx = Newobject( "ZooException", "ZooException.prg" )
		try
			lxResultado = loclase.ObtenerResultadoInformacion( loInfo )						
		Catch To loError
			loEx.Grabar( loError )
		endtry
	
		this.asserttrue( "No llego el objeto informacion" , !isnull( loEx.oInformacion ) )
		this.assertequals( "El objeto validacion no es el mismo", loInfo, loEx.oInformacion )
		loInfo.Limpiar()

		try
			lxResultado = loclase.ObtenerResultadoInformacion( loInfo )
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			loEx.Grabar( loError )
		endtry
		this.asserttrue( "No tendria que haber llegado el objeto informacion" , Empty( loEx.oInformacion.Count ) )
		
	endfunc
	
	*---------------------------------
	function zTestExceptionToInformacion
	
		local loEx as ZooException OF ZooException.prg, loInformacion as ZooInformacion of ZooInformacion.prg
		loInformacion = _screen.zoo.crearobjeto( "ZooInformacion" )

		loEx = _screen.zoo.crearobjeto( "ZooException" )
		loEx.Message = "Prueba de excepcion lanzada adrede."
		loEx.ErrorNO = 99
		loEx.ExceptionToInformacion( loInformacion )
		
		This.assertequals( "El numero del error es incorrecto.", 99, loInformacion.Item[ 1 ].nNumero )
		This.assertequals( "El texto del error es incorrecto.", "Prueba de excepcion lanzada adrede.", loInformacion.Item[ 1 ].cMensaje )

		loInformacion.Release()
		loEx = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestExceptionGrabaLog
		local loEx as ZooException OF ZooException.prg
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "serviciosaplicacion" )
		goServicios.Logueos = newobject( "mockLog" )

		loEx = _screen.zoo.crearobjeto( "ZooException" )
		loEx.Grabar()
		This.asserttrue( "No paso por ObtenerObjetoLogueo.", goServicios.Logueos.lPasoPorObtenerLogueo )
		This.asserttrue( "No paso por escribir log.", goServicios.Logueos.lPasoPorEscribirLog )
		This.asserttrue( "No paso por Guardar Log.", goServicios.Logueos.lPasoPorGuardar )	

	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestExceptionNoGrabaLogPorRESTAPI
		local loEx as ZooException OF ZooException.prg
		private goServicios

		goServicios = _screen.zoo.crearobjeto( "serviciosaplicacion" )

		goservicios.lnologuearrestapi = .T.
		_screen.AddProperty("lUsaServicioRest", .T. )

		goServicios.Logueos = newobject( "mockLog" )

		loEx = _screen.zoo.crearobjeto( "ZooException" )
 
		loEx.Grabar()
		This.asserttrue( "No debería haber pasado por ObtenerObjetoLogueo.", !goServicios.Logueos.lPasoPorObtenerLogueo )
		This.asserttrue( "No debería haber pasado por escribir log.", !goServicios.Logueos.lPasoPorEscribirLog )
		This.asserttrue( "No debería haber pasado por Guardar Log.", !goServicios.Logueos.lPasoPorGuardar )	

		removeproperty( _screen, "lUsaServicioRest" )
		goServicios.release()
	
	Endfunc 	
	
enddefine
*-----------------------------------------------------------------------------------------	

Define class mockLog as Custom
lPasoPorObtenerLogueo = .f.
lPasoPorEscribirLog = .f.
lPasoPorGuardar = .f.
		*-----------------------------------------------------------------------------------------
	function ObtenerObjetoLogueo( toObject as Object ) as Void

		This.lPasoPorObtenerLogueo = .t.
		loMock = newobject( "ObjetoMock" )
		return loMock		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Guardar( toObject as Object ) as Void
		This.lPasoPorGuardar = .t.
	endfunc 

Enddefine

define class ObjetoMock as Custom

	*-----------------------------------------------------------------------------------------
	function Escribir( tcTexto as String ) as Void
		goServicios.Logueos.lPasoPorEscribirLog = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void

	endfunc 

enddefine




define class prueba as Custom 

	lGeneroStack = .f.

	*-----------------------------------------------------------------------------------------
	function ObtenerResultado()
		local loError as Exception, loEx as Exception,lcTexto as String, ;
		lnCantidad as Integer, lxResultado as Variant
		Try
			lcTexto = "pepe"
			lnCantidad = 1	
			lxResultado = lcTexto + this.ObtenerCantidad(lnCantidad)		
			
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )

			With loEx
				.Grabar( loError )
				.Throw()
			EndWith

		endtry 

		return lxResultado

	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerResultadoInformacion( toInfo as Object )
		local loError as Exception, loEx as Exception,lcTexto as String, ;
		lnCantidad as Integer, lxResultado as Variant
		Try
			lcTexto = "pepe"
			lnCantidad = 1	
			lxResultado = lcTexto + this.ObtenerCantidad( lnCantidad )		
			
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )

			With loEx
				.oInformacion = toInfo
				.Grabar( loError )
				.Throw()
			EndWith

		endtry 

		return lxResultado

	endfunc

	*-----------------------------------------------------------------------------------------
	function GrabarSinDetalle() as Void
		local loEx as Exception

		Try
			this.FrutaMal( 'Mas fruta' )			
		catch to loError
		loEx = Newobject(  "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			Endwith
		Finally
		EndTry

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidad( tnCantidad )

		return 1

	endfunc
	
	*-----------------------------------------------------------------------------------------

	Function GrabarConDetalle() as Void
		local loEx as Exception
			Try
				this.SinMetodo( 'Mas fruta' )
			catch to loError
				loEx = Newobject(  'ZooException', 'ZooException.prg' )
				With loEx
					loError.Details = 'No existe el método FrutaMal'
					.Grabar( loError )
					.Throw()
				Endwith
			Finally
			EndTry
	endfunc 

enddefine