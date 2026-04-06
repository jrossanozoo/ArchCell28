**********************************************************************
Define Class zTestEntidadLiberacionDeVersiones as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestEntidadLiberacionDeVersiones of zTestEntidadLiberacionDeVersiones.prg
	#ENDIF


	*-----------------------------------------------------------------------------------------
	function zTestSqlServerVerificarUrlDeDescargaAlGrabarConUrlValida
		local loEntidad as Entidad of Entidad.prg, llRetorno as Boolean
		
		* Arrange
		this.agregarmocks( "PRODUCTOZL,VERSIONPRODUCTOSZL" )
		*!*	 DRAGON 2028
		goServicios.Datos.EjecutarSentencias( "Delete from Liberaver", "Liberaver" )
		loEntidad = newobject( "liberaciondeversionesMock" )
		
		with loEntidad 
			.Nuevo()
			.Version_Pk = "00.0000.0003"
			.Producto_PK = "0001"

			.FechaDeCompilacion = date()
			.Grabar()
		endwith	
		
		* Act
		with loEntidad 
			.lPublicandoVersion = .T.
			.oValidadorWeb.cUrlEsperada = "http://EstoEsOtraUtrl/bla.zip"
			
			.Modificar()
			.URLDesc = "http://EstoEsOtraUtrl/bla.zip"
						
			llRetorno = .Validar()
			.Cancelar()
			.Release()
		endwith
		
		* Assert
		This.asserttrue( "Deberia pasar la validacion de la URL, es la misma URL", llRetorno )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerVerificarUrlDeDescargaAlGrabarConUrlInvalida

		local loEntidad as Entidad of Entidad.prg, llRetorno as Boolean
		
		* Arrange
		this.agregarmocks( "PRODUCTOZL,VERSIONPRODUCTOSZL" )
		*!*	 DRAGON 2028
		goServicios.Datos.EjecutarSentencias( "Delete from Liberaver", "Liberaver" )
		loEntidad = newobject( "liberaciondeversionesMock" )
		
		with loEntidad 
			.Nuevo()
			.Version_Pk = "00.0000.0003"
			.Producto_PK = "0001"

			.FechaDeCompilacion = date()
			.Grabar()
		endwith	
		
		* Act
		with loEntidad 
			.lPublicandoVersion = .T.
			.oValidadorWeb.cUrlEsperada = "http://EsToEsUnaURL/bla.zip"
			
			.Modificar()
			.URLDesc = "http://EstoEsOtraUtrl/bla.zip"
						
			llRetorno = .Validar()
			.Cancelar()
			.Release()
		endwith
		
		* Assert
		This.asserttrue( "No deberia pasar la validacion de la URL, la misma no coincide", !llRetorno )
		
	endfunc 
	

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerVerificarUrlDeDescargaAlGrabarConUrlVacia

		local loEntidad as Entidad of Entidad.prg, llRetorno as Boolean
		
		* Arrange
		this.agregarmocks( "PRODUCTOZL,VERSIONPRODUCTOSZL" )
		*!*	 DRAGON 2028
		goServicios.Datos.EjecutarSentencias( "Delete from Liberaver", "Liberaver" )
		loEntidad = newobject( "liberaciondeversionesMock" )
		
		with loEntidad 
			.Nuevo()
			.Version_Pk = "00.0000.0003"
			.Producto_PK = "0001"

			.FechaDeCompilacion = date()
			.Grabar()
		endwith	
		
		* Act
		with loEntidad 
			.lPublicandoVersion = .T.
			.oValidadorWeb.cUrlEsperada = "http://EsToEsUnaURL/bla.zip"
			
			.Modificar()
			.URLDesc = ""
						
			llRetorno = .Validar()
			.Cancelar()
			.Release()
		endwith
		
		* Assert
		This.asserttrue( "No deberia validar, la Url esta vacía.", !llRetorno )
		
	endfunc 


EndDefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class liberaciondeversionesMock as ent_liberaciondeversiones of ent_liberaciondeversiones.prg
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponenteWeb() as Object
		return CreateObject( "MockComponenteWeb" )
	endfunc 

enddefine


define class MockComponenteWeb as custom
	cUrlEsperada = ""
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTamañoArchivo( tcUbicacion as String )
		local lnRetorno as Integer
		lnRetorno = 0
		
		if ( alltrim( tcUbicacion ) == alltrim( This.cUrlEsperada ) )
			lnRetorno = 100
		endif
		
		return lnRetorno
	endfunc 

enddefine
