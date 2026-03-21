**********************************************************************
DEFINE CLASS zTestColaboradorPropiedadesRep as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestColaboradorPropiedadesRep OF zTestColaboradorPropiedadesRep.PRG
	#ENDIF
		
	*-----------------------------------------------------------------	
	FUNCTION Setup
	endfunc

	*-----------------------------------------------------------------	
	FUNCTION TearDown
	endfunc

	*-----------------------------------------------------------------	
	function zTestInsertarInformacionDeEstadoConectadoBD_NoExisten
		Local loMockAD as Object, loColaborador as Object, lcTabla as String, loPruebaColaborador as Object, lnDS as Integer
		
		&& Tengo que probar que si no existian, las agrega
		loMockAD = this.oServicioMocks.GenerarMock( "ServicioDatos" )
		loColaborador = newobject( "ColaboradorPropiedadesRep", "ColaboradorPropiedadesRep.prg" )
		loPruebaColaborador = newobject( "PruebaColaborador" )
		bindevent( loColaborador, "InsertDatos", loPruebaColaborador, "PruebaInsertDatos", 1 )
		bindevent( loColaborador, "UpdateDatos", loPruebaColaborador, "PruebaUpdateDatos", 1 )
		
		lcTabla = "TablaTest"
		lnDS = set("Datasession")
		set datasession to loColaborador.DatasessionId
		create cursor _4CD0N5GFA ( Atributo C( 100 ), Valor C(200) )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "AtributoCualquiera", "Lo que sea" )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "OtrAtributoCualquiera", "Bla" )
		set datasession to lnDS
		loColaborador.InsertarInformacionDeEstadoConectadoBD( loMockAD, "",lcTabla , .T., "10/05/15", "ADMIN" )

		this.AssertEquals( "No agrego los registros esperados", 3, loPruebaColaborador.oColInsert.Count )
		this.AssertEquals( "No inserto el atributo correcto (1).", "ConectadaZNube", loPruebaColaborador.oColInsert(1).cAtributo )
		this.AssertEquals( "No inserto el atributo correcto (2).", "FechaCambioConexion", loPruebaColaborador.oColInsert(2).cAtributo )
		this.AssertEquals( "No inserto el atributo correcto (3).", "UsuarioCambioConexion", loPruebaColaborador.oColInsert(3).cAtributo )
		
		this.AssertEquals( "No inserto el valor correcto (1).", "True", loPruebaColaborador.oColInsert(1).cValor )
		this.AssertEquals( "No inserto el valor correcto (2).", "10/05/15", loPruebaColaborador.oColInsert(2).cValor )
		this.AssertEquals( "No inserto el valor correcto (3).", "ADMIN", loPruebaColaborador.oColInsert(3).cValor )

		this.AssertEquals( "No deberia haber hecho update de ningun registro", 0, loPruebaColaborador.oColUpdate.Count )

		loMockAD.ValidarLlamadas()
		
		loColaborador = null
		loMockAD = null
		loPruebaColaborador = null
	endfunc

	*-----------------------------------------------------------------	
	function zTestInsertarInformacionDeEstadoConectadoBD_SiExisten
		Local loMockAD as Object, loColaborador as Object, lcTabla as String, loPruebaColaborador as Object, lnDS as Integer
		
		&& Tengo que probar que si existian, y les cambia el valor
		loMockAD = this.oServicioMocks.GenerarMock( "ServicioDatos" )
		loColaborador = newobject( "ColaboradorPropiedadesRep", "ColaboradorPropiedadesRep.prg" )
		loPruebaColaborador = newobject( "PruebaColaborador" )
		bindevent( loColaborador, "InsertDatos", loPruebaColaborador, "PruebaInsertDatos", 1 )
		bindevent( loColaborador, "UpdateDatos", loPruebaColaborador, "PruebaUpdateDatos", 1 )
		
		lcTabla = "TablaTest"
		lnDS = set("Datasession")
		set datasession to loColaborador.DatasessionId
		create cursor _4CD0N5GFA ( Atributo C( 100 ), Valor C(200) )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "ConectadaZNube", "True" )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "FechaCambioConexion", "10/05/15" )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "UsuarioCambioConexion", "ADMIN" )
		set datasession to lnDS

		loColaborador.InsertarInformacionDeEstadoConectadoBD( loMockAD, "", lcTabla , .F., "12/05/15", "STONE" )

		this.AssertEquals( "No cambio los registros esperados", 3, loPruebaColaborador.oColUpdate.Count )
		this.AssertEquals( "No cambio el atributo correcto (1).", "ConectadaZNube", loPruebaColaborador.oColUpdate(1).cAtributo )
		this.AssertEquals( "No cambio el atributo correcto (2).", "FechaCambioConexion", loPruebaColaborador.oColUpdate(2).cAtributo )
		this.AssertEquals( "No cambio el atributo correcto (3).", "UsuarioCambioConexion", loPruebaColaborador.oColUpdate(3).cAtributo )
		
		this.AssertEquals( "No cambio el valor correcto (1).", "False", loPruebaColaborador.oColUpdate(1).cValor )
		this.AssertEquals( "No cambio el valor correcto (2).", "12/05/15", loPruebaColaborador.oColUpdate(2).cValor )
		this.AssertEquals( "No cambio el valor correcto (3).", "STONE", loPruebaColaborador.oColUpdate(3).cValor )

		this.AssertEquals( "No deberia haber hecho insert de ningun registro", 0, loPruebaColaborador.oColInsert.Count )

		loMockAD.ValidarLlamadas()
		
		loColaborador = null
		loMockAD = null
		loPruebaColaborador = null
	endfunc

	*-----------------------------------------------------------------	
	function zTestInsertarInformacionDeEstadoConectadoBD_SiExistenPeroNoCambioValorNoSeActualiza
		Local loMockAD as Object, loColaborador as Object, lcTabla as String, loPruebaColaborador as Object, lnDS as Integer
		
		&& Tengo que probar que si existian, y como no cambio el valor, no se actualizan
		loMockAD = this.oServicioMocks.GenerarMock( "ServicioDatos" )
		loColaborador = newobject( "ColaboradorPropiedadesRep", "ColaboradorPropiedadesRep.prg" )
		loPruebaColaborador = newobject( "PruebaColaborador" )
		bindevent( loColaborador, "InsertDatos", loPruebaColaborador, "PruebaInsertDatos", 1 )
		bindevent( loColaborador, "UpdateDatos", loPruebaColaborador, "PruebaUpdateDatos", 1 )
		
		lcTabla = "TablaTest"
		lnDS = set("Datasession")
		set datasession to loColaborador.DatasessionId
		create cursor _4CD0N5GFA ( Atributo C( 100 ), Valor C(200) )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "ConectadaZNube", "True" )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "FechaCambioConexion", "10/05/15" )
		insert into _4CD0N5GFA ( Atributo, Valor ) values ( "UsuarioCambioConexion", "ADMIN" )
		set datasession to lnDS

		loColaborador.InsertarInformacionDeEstadoConectadoBD( loMockAD, "", lcTabla , .T., ctod("12/05/15"), "STONE" )

		this.AssertEquals( "No deberia haber cambiado los registros", 0, loPruebaColaborador.oColUpdate.Count )
		this.AssertEquals( "No deberia haber hecho insert de ningun registro", 0, loPruebaColaborador.oColInsert.Count )

		loMockAD.ValidarLlamadas()
		
		loColaborador = null
		loMockAD = null
		loPruebaColaborador = null
	endfunc
	
	*-----------------------------------------------------------------	
	function zTestObtenerInformacionDeEstadoConectadoBD_NoExiste
		Local loMockAD as Object, loColaborador as Object, lcTabla as String, loPruebaColaborador as Object, llRetorno as Boolean, lnDS as Integer
		
		&& Tengo que probar que si no existia, me devuelve true
		loMockAD = this.oServicioMocks.GenerarMock( "ServicioDatos" )
		loColaborador = newobject( "ColaboradorPropiedadesRep", "ColaboradorPropiedadesRep.prg" )
		loPruebaColaborador = newobject( "PruebaColaborador" )
		bindevent( loColaborador, "InsertDatos", loPruebaColaborador, "PruebaInsertDatos", 1 )
		bindevent( loColaborador, "UpdateDatos", loPruebaColaborador, "PruebaUpdateDatos", 1 )
		
		lcTabla = "TablaTest"
		lnDS = set("Datasession")
		set datasession to loColaborador.DatasessionId
		create cursor _4CD10NC9E ( Atributo C( 100 ), Valor C(200) )
		insert into _4CD10NC9E ( Atributo, Valor ) values ( "ConectadaZNube", "False" )
		insert into _4CD10NC9E ( Atributo, Valor ) values ( "AtributoCualquiera", "Lo que sea" )
		insert into _4CD10NC9E ( Atributo, Valor ) values ( "OtrAtributoCualquiera", "Bla" )
		set datasession to lnDS

		llRetorno = loColaborador.ObtenerInformacionDeEstadoConectadoBD( loMockAD, "", lcTabla )

		this.AssertTrue( "Me deberia haber dado false", !llRetorno )

		loMockAD.ValidarLlamadas()
		
		loColaborador = null
		loMockAD = null
		loPruebaColaborador = null
	endfunc

	*-----------------------------------------------------------------	
	function zTestObtenerInformacionDeEstadoConectadoBD_SiExiste
		Local loMockAD as Object, loColaborador as Object, lcTabla as String, loPruebaColaborador as Object, llRetorno as Boolean, lnDS as Integer
		
		&& Tengo que probar que si no existia, me devuelve true
		loMockAD = this.oServicioMocks.GenerarMock( "ServicioDatos" )
		loColaborador = newobject( "ColaboradorPropiedadesRep", "ColaboradorPropiedadesRep.prg" )
		loPruebaColaborador = newobject( "PruebaColaborador" )
		bindevent( loColaborador, "InsertDatos", loPruebaColaborador, "PruebaInsertDatos", 1 )
		bindevent( loColaborador, "UpdateDatos", loPruebaColaborador, "PruebaUpdateDatos", 1 )
		
		lcTabla = "TablaTest"
		lnDS = set("Datasession")
		set datasession to loColaborador.DatasessionId
		create cursor _4CD10NC9E ( Atributo C( 100 ), Valor C(200) )
		insert into _4CD10NC9E ( Atributo, Valor ) values ( "AtributoCualquiera", "Lo que sea" )
		insert into _4CD10NC9E ( Atributo, Valor ) values ( "OtrAtributoCualquiera", "Bla" )
		set datasession to lnDS

		llRetorno = loColaborador.ObtenerInformacionDeEstadoConectadoBD( loMockAD, "", lcTabla )

		this.AssertTrue( "Me deberia haber dado true, porque no existia previamente", llRetorno )

		loMockAD.ValidarLlamadas()
		
		loColaborador = null
		loMockAD = null
		loPruebaColaborador = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerNombreTablaPropiedadesRep
		local loColaborador as Object, lcNombreTabla as String
		
		loColaborador = _screen.zoo.CrearObjeto( "ColaboradorPropiedadesRep" )
		lcNombreTabla = loColaborador.ObtenerNombreTablaPropiedadesRep()
		
		this.AssertEquals( "No está bien el nombre de la tabla.", "[ZOOLOGIC].[PROPIEDADESREP]", lcNombreTabla )
		
		loColaborador = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerAtributosTablaPropiedadesRep
		local loColaborador as Object
		
		loColaborador = _screen.zoo.CrearObjeto( "ColaboradorPropiedadesRep" )
		
		this.AssertEquals( "No está bien el nombre del atributo conectada.", "ConectadaZNube", loColaborador.ObtenerAtributoConectado() )
		this.AssertEquals( "No está bien el nombre del atributo fecha de cambio.", "FechaCambioConexion", loColaborador.ObtenerAtributoFechaCambio() )
		this.AssertEquals( "No está bien el nombre del atributo usuario que cambio.", "UsuarioCambioConexion", loColaborador.ObtenerAtributoUsuarioCambio() )
		
		loColaborador = null
		
	endfunc 


ENDDEFINE

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class PruebaColaborador as Custom
	oColInsert = null
	oColUpdate = null

	function init
		this.oColInsert = _Screen.zoo.crearobjeto( "ZooColeccion" )
		this.oColUpdate = _Screen.zoo.crearobjeto( "ZooColeccion" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function PruebaInsertDatos( toAd as Object, tcTabla as String ,tcAtributo as String, tcValor ) as Void
		local loItem as Object
		
		loItem = newobject( "ItemCol" )
		loItem.cAtributo = tcAtributo
		loItem.cValor = tcValor
		this.oColInsert.Agregar( loItem, tcAtributo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PruebaUpdateDatos( toAd as Object, tcTabla as String ,tcAtributo as String, tcValor ) as Void
		local loItem as Object
		
		loItem = newobject( "ItemCol" )
		loItem.cAtributo = tcAtributo
		loItem.cValor = tcValor
		this.oColUpdate.Agregar( loItem, tcAtributo )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemCol as Custom
	cAtributo = ""
	cValor = ""
enddefine

