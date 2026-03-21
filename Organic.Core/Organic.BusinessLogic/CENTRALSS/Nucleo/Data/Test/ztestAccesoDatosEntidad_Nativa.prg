**********************************************************************
Define Class ztestAccesoDatosEntidad_Nativa as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestAccesoDatosEntidad_Nativa of ztestAccesoDatosEntidad_Nativa.prg
	#ENDIF
	oAcceso = Null
	nDataSession = 0
	*---------------------------------
	Function Setup
		This.oAcceso = newobject( "AuxAcceso" )
		This.nDataSession = set("Datasession")
		set datasession to This.oAcceso.DataSessionId
		create cursor c_Orig ( Campo1 C( 10 ) Null, Campo2 N( 10, 2 ) null )
		create cursor c_Imp ( Campo1 C( 10 ) Null, Campo2 N( 10, 2 ) null )

	EndFunc
	
	*---------------------------------
	Function TearDown
		use in select( "c_Orig" )
		use in select( "c_Imp" )		
		set datasession to This.nDataSession
		This.oAcceso.release()
	EndFunc
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios1
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( null, 2.11 )
		This.Asserttrue( "Hubo Cambios", This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios2
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( null, 2.12 )
		This.Asserttrue( "No Hubo Cambios", !This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )
	endfunc
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios3
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( "2", null )
		This.Asserttrue( "Hubo Cambios", This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios4
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( "1", null )
		This.Asserttrue( "No Hubo Cambios", !This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios5
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( null, null )
		This.Asserttrue( "No Hubo Cambios", !This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )		
	endfunc
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios6
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( "2", 2.12 )
		This.Asserttrue( "Hubo Cambios", This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios7
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( "2", 2.11 )
		This.Asserttrue( "Hubo Cambios", This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios8
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( "1", 2.11 )
		This.Asserttrue( "Hubo Cambios", This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_HuboCambios9
		insert into c_Orig( Campo1, Campo2 ) values ( "1", 2.12 )
		insert into c_Imp( Campo1, Campo2 ) values ( "1", 2.12 )
		This.Asserttrue( "No Hubo Cambios", !This.oAcceso.HuboCambiosAux( "c_Imp", "c_Orig" ) )		
	endfunc	

	*-----------------------------------------------------------------------------------------
	function zTestNativaI_CargarCampoMemo
		local loEntidad as Entidad of Entidad.prg, loAD as Object, lcCodigo1 as String, lcCodigo2 as String, lcXml as String, lnDataSessionId as Integer, loEx as Exception
		lcCodigo1 = "1"
		lcCodigo2 = "2"

		goServicios.Datos.Ejecutarsentencias( "delete from Col where alltrim( COLCOD ) == '" + lcCodigo1 + "' ", "Col" )
		goServicios.Datos.Ejecutarsentencias( "delete from Col where alltrim( COLCOD ) == '" + lcCodigo2 + "' ", "Col" )
		goServicios.Datos.Ejecutarsentencias( "delete from col_cobs where alltrim( COLCOD ) == '" + lcCodigo1 + "' ", "col_cobs" )
		goServicios.Datos.Ejecutarsentencias( "delete from col_cobs where alltrim( COLCOD ) == '" + lcCodigo2 + "' ", "col_cobs" )

		loEntidad = _screen.Zoo.InstanciarEntidad( "Color" )
		loEntidad.Nuevo()
		loEntidad.Codigo = lcCodigo1
		loEntidad.Observacion = "Observacion 1"
		loEntidad.Grabar()

		loEntidad.Nuevo()
		loEntidad.Codigo = lcCodigo2
		loEntidad.Observacion = "Observacion 2"
		loEntidad.Grabar()
		
		loAD = loEntidad.oAD
		lcXml = loEntidad.ObtenerDatosEntidad( "Codigo, Observacion", "", "", "" )
		loEntidad.XmlACursor( lcXml, "cResultado" )
		loAD.CargarCampoMemo( "cResultado", "Codigo", "Observacion" )
		
		try
			lnDataSessionId = set( "Datasession" )
			set datasession to ( loAD.DataSessionId )
			select ( "cResultado" )
			locate for alltrim( Codigo ) == "1"
			this.assertequals( "La observación del primer registro no es la esperada.", "Observacion 1", alltrim( cResultado.Observacion ) )
			locate for alltrim( Codigo ) == "2"
			this.assertequals( "La observación del segundo registro no es la esperada.", "Observacion 2", alltrim( cResultado.Observacion ) )
		catch to loEx
			this.asserttrue( "No debería dar error.", .f. )
		finally
			set datasession to ( lnDataSessionId )
		endtry

		loEntidad.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestU_VerificarInsercionUnicidadAntesDelCommit
		local loError as Exception , lcAux as string, loEntidad as entidad OF entidad.prg 
		
		loEntidad = newobject("TestEntidad" )
		loEntidad.aPK = "1"
		this.oAcceso.InyectarEntidad( loEntidad )
		
		this.oAcceso.DataSessionId = set("Datasession")

		try
			create cursor c_tablaTest ( aPK C(10) )

			try
				this.oAcceso.VerificarInsercionUnicidadAntesDelCommit( "" )
				this.asserttrue( "Debe indicar error ya que no hay registos insertados en la tabla", .f. )
			catch to loError
				if type( "loError.uservalue.oinformacion.Item[1].cmensaje" ) = "C"
					lcAux = loError.uservalue.oinformacion.Item[1].cmensaje
					this.Assertequals( "Error en el mensaje de error esperado", "La clave primaria a grabar ya existe",lcAux   )
				else
					throw
				endif
			endtry
			
			insert into c_tablaTest ( aPK ) values ( "1" )
			
			this.asserttrue( "Debe indicar que no hay problema ya que hay un solo registos insertado en la tabla", this.oAcceso.VerificarInsercionUnicidadAntesDelCommit( "1" ) )

			insert into c_tablaTest ( aPK ) values ( "1" )
			
			try
				this.oAcceso.VerificarInsercionUnicidadAntesDelCommit( "1" )
				this.asserttrue( "Debe indicar error ya que hay 2 registos insertados en la tabla", .f. )
			catch to loError
				if type( "loError.uservalue.oinformacion.Item[1].cmensaje" ) = "C"
					lcAux = loError.uservalue.oinformacion.Item[1].cmensaje
					this.Assertequals( "Error en el mensaje de error esperado", "La clave primaria a grabar ya existe",lcAux   )
				else
					throw
				endif
			endtry
		finally
			use in select( "c_tablaTest" )
			
			if type( "loEntidad" ) = "O"
				loEntidad.release()
			endif
		endtry
		
	endfunc	

EndDefine

*-----------------------------------------------------------------------------------------
define class AuxAcceso as AccesoDatosEntidad_Nativa of AccesoDatosEntidad_Nativa.prg
	
	cTablaPrincipal = "c_tablaTest"

	*-----------------------------------------------------------------------------------------
	function HuboCambiosAux( tcCursor as String, tcTabla as String ) as Boolean
		return This.HuboCambios( tcCursor, tcTabla )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoEntidad( tcAtributo as String ) as Void
		return tcAtributo 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoBusqueda() as Void
		return newobject( "TestObjetoBusqueda" )
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
define class TestEntidad as entidad OF entidad.prg 

	aPK = ""
	
	cAtributoPK= "aPK"
	
enddefine

*-----------------------------------------------------------------------------------------
define class TestObjetoBusqueda as custom

	Filtro = "!empty( aPK )"
enddefine

