**********************************************************************
Define Class zTestValidarADN as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestValidarADN of zTestValidarADN.prg
	#ENDIF

	oValidarADN		= NULL	
	oManejoArchivos	= Null
	cAtributoEntidad		= ""
	cAtributoDiccionario	= ""
	cAtributoDominio		= ""
	cAtributoControles		= ""
	cAtributoEstilos		= ""
	cAtributoPropiedades	= ""
	cDeleted                = ""
	nDataSession			= 0
	
	*---------------------------------
	Function Setup
		with This
			.nDataSession = set( "datasession" )
			.cDeleted = set( "deleted" )
			set deleted on
			.oValidarADN = newobject( "MockValidarADN", "zTestValidarADN.prg", "", _screen.zoo.cRutaInicial )

			.oValidarADN.oAccesoDatos.AbrirTabla( "Entidad",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Diccionario",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Dominio",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Estilos",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Controles",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Propiedades",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "EstructuraTablas",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "SeguridadEntidades",				.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "SeguridadEntidadesDefault",		.t., .oValidarADN.cRutaADN )						
			.oValidarADN.oAccesoDatos.AbrirTabla( "MenuPrincipal",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "MenuPrincipalItems",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "MenuAltasItems",					.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "MenuAltasDefault",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Parametros",						.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "JerarquiaParametros",			.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "RelaNumeraciones",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "AtributosGenericos",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TransferenciasAgrupadas",		.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TransferenciasAgrupadasItems",	.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Transferencias",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TransferenciasFiltros",			.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "ListCampos",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Listados",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "RelaTriggers",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Buscador",						.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "BuscadorDetalle",				.t., .oValidarADN.cRutaADN )						
			.oValidarADN.oAccesoDatos.AbrirTabla( "RelaComponente",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Componente",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TipoDeValores",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "ParametrosYRegistrosEspecificos",.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "NodosParametrosCliente",			.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Indice_SqlServer",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Comprobantes",			.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Proyectos",    .F., _screen.zoo.cRutaInicial + "..\taspein\data\", "Proyectos",	.T. )		

			select * from Propiedades into cursor cPropiedades readwrite
			select * from Dominio     where .f. into cursor cDominio     readwrite
			select * from Estilos     where .f. into cursor cEstilos     readwrite
			select * from Controles   where .f. into cursor cControles   readwrite
			select * from Entidad     where .f. into cursor cEntidad     readwrite
			select * from Diccionario where .f. into cursor cDiccionario readwrite
			select * from EstructuraTablas where .f. into cursor cEstructuraTablas readwrite
			select * from SeguridadEntidades where .f. into cursor cSeguridadEntidades readwrite
			select * from SeguridadEntidadesDefault where .f. into cursor cSeguridadEntidadesDefault readwrite			
			select * from MenuPrincipal where .f. into cursor cMenuPrincipal readwrite			
			select * from MenuPrincipalItems where .f. into cursor cMenuPrincipalItems readwrite			
			select * from MenuAltasItems where .f. into cursor cMenuAltasItems readwrite			
			select * from MenuAltasDefault where .f. into cursor cMenuAltasDefault readwrite
			select * from Parametros where .f. into cursor cParametros readwrite			
			select * from JerarquiaParametros where .f. into cursor cJerarquiaParametros readwrite			
			select * from RelaNumeraciones where .f. into cursor cRelaNumeraciones  readwrite
			select * from AtributosGenericos where .f. into cursor cAtributosGenericos  readwrite
			select * from TransferenciasAgrupadas where .f. into cursor cTransferenciasAgrupadas readwrite
			select * from TransferenciasAgrupadasItems where .f. into cursor cTransferenciasAgrupadasItems readwrite
			select * from Transferencias where .f. into cursor cTransferencias readwrite
			select * from TransferenciasFiltros where .f. into cursor cTransferenciasFiltros readwrite
			select * from ListCampos where .f. into cursor cListCampos readwrite
			select * from Listados where .f. into cursor cListados readwrite
			select * from RelaTriggers where .f. into cursor cRelaTriggers readwrite
			select * from Buscador where .f. into cursor cBuscador readwrite
			select * from BuscadorDetalle where .f. into cursor cBuscadorDetalle readwrite			
			select * from RelaComponente where .f. into cursor cRelaComponente readwrite	
			select * from Componente where .f. into cursor cComponente readwrite	
			select * from TipoDeValores where .f. into cursor cTipoDeValores readwrite				
			select * from ParametrosYRegistrosEspecificos where .f. into cursor cParametrosYRegistrosEspecificos readwrite
			select * from Proyectos into cursor cProyectos readwrite
			select * from NodosParametrosCliente into cursor cNodosParametrosCliente readwrite
			select * from Comprobantes into cursor cComprobantes readwrite
			select * from Indice_SqlServer into cursor cIndice_SqlServer readwrite

			.oValidarADN.CerrarTablas()
		
			select * from cEntidad     into cursor Entidad     readwrite
			select * from cDiccionario into cursor Diccionario readwrite
			select * from cDominio     into cursor Dominio     readwrite
			select * from cEstilos     into cursor Estilos     readwrite
			select * from cControles   into cursor Controles   readwrite
			select * from cPropiedades into cursor Propiedades readwrite
			select * from cEstructuraTablas into cursor EstructuraTablas readwrite
			select * from cSeguridadEntidades into cursor SeguridadEntidades readwrite
			select * from cSeguridadEntidadesDefault into cursor SeguridadEntidadesDefault readwrite			
			select * from cMenuPrincipal where .f. into cursor MenuPrincipal readwrite			
			select * from cMenuPrincipalItems where .f. into cursor MenuPrincipalItems readwrite			
			select * from cMenuAltasItems where .f. into cursor MenuAltasItems readwrite			
			select * from cMenuAltasDefault where .f. into cursor MenuAltasDefault readwrite
			select * from cParametros where .f. into cursor Parametros readwrite			
			select * from cJerarquiaParametros where .f. into cursor JerarquiaParametros readwrite		
			select * from cRelaNumeraciones where .f. into cursor RelaNumeraciones  readwrite	
			select * from cAtributosGenericos where .f. into cursor AtributosGenericos readwrite
			select * from cTransferenciasAgrupadas where .f. into cursor TransferenciasAgrupadas readwrite
			select * from cTransferenciasAgrupadasItems where .f. into cursor TransferenciasAgrupadasItems readwrite
			select * from cTransferencias where .f. into cursor Transferencias readwrite
			select * from cTransferenciasFiltros where .f. into cursor TransferenciasFiltros readwrite
			select * from cListCampos where .f. into cursor ListCampos readwrite
			select * from cListados where .f. into cursor Listados readwrite
			select * from cRelaTriggers where .f. into cursor RelaTriggers readwrite
			select * from cBuscador where .f. into cursor Buscador readwrite
			select * from cBuscadorDetalle where .f. into cursor BuscadorDetalle readwrite
			select * from cRelaComponente where .f. into cursor RelaComponente readwrite
			select * from cComponente where .f. into cursor Componente readwrite
			select * from cTipoDeValores where .f. into cursor TipoDeValores readwrite
			select * from cProyectos into cursor Proyectos readwrite
			select * from cNodosParametrosCliente into cursor NodosParametrosCliente readwrite
			select * from cComprobantes into cursor Comprobantes readwrite
			select * from cIndice_SqlServer into cursor Indice_SqlServer readwrite
						
			use in select( "cEntidad" )
			use in select( "cDiccionario" )
			use in select( "cDominio" )
			use in select( "cEstilos" )
			use in select( "cControles" )
			use in select( "cPropiedades" )
			use in select( "cEstructuraTablas" )
			use in select( "cSeguridadEntidades" )
			use in select( "cSeguridadEntidadesDefault" )			
			use in select( "cMenuPrincipal" )			
			use in select( "cMenuPrincipalItems" )			
			use in select( "cMenuAltasItems" )			
			use in select( "cMenuAltasDefault" )
			use in select( "cParametros" )
			use in select( "cJerarquiaParametros" )
			use in select( "cRelaNumeraciones" )
			use in select( "cAtributosGenericos")
			use in select( "cTransferenciasAgrupadas" )
			use in select( "cTransferenciasAgrupadasItems" )
			use in select( "cTransferencias" )
			use in select( "cTransferenciasFiltros" )
			use in select( "cListCampos" )
			use in select( "cListados" )
			use in select( "cRelaTriggers" )
			use in select( "cBuscador" )
			use in select( "cBuscadorDetalle" )
			use in select( "cRelaComponente" )
			use in select( "cComponente" )
			use in select( "cTipoDeValores" )
			use in select( "cParametrosYRegistrosEspecificos" )
			use in select( "cNodosParametrosCliente" )
			use in select( "cProyectos" )
			use in select( "cComprobantes" )
			use in select( "cIndice_SqlServer" )
		endwith
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	Function TearDown
		local lcDeleted as String
		with This
			.oValidarADN.CerrarTablas( )
			.oValidarADN.release()
			.oValidarADN = null
			if dbused( "Metadata" )
				set database to Metadata
				close databases
			endif
			lcDeleted = .cDeleted
			set deleted &lcDeleted
			set datasession to	.nDataSession
		EndWith
	endfunc
	
	*-----------------------------------	
	function zTestValidarAtributosGenericos
	
		local lcEntidad as String
		
		with This.oValidarADN
			insert into Entidad ( Entidad, Tipo ) ;
				values ( "RRR", "E" )

			insert into Entidad ( Entidad, Tipo ) ;
				values ( "EEE", "E" )

			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR", "atribgen", "C", 0, 0,  "CMPPRUEBA" )

			insert into AtributosGenericos( Atributo, tipodato, longitud, decimales, campo, tipo ) ;
				values ( "atribgen", "C", 0, 0, "CMPPRUEBA", "E" )
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosGenericos()
			This.AssertEquals( "No deberia haber saltado la validacion los Atributos Genericos", 0, .oMockInformacionIndividual.Count )
						
			update diccionario set longitud = 30 where entidad = "RRR"

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosGenericos()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
							"Deberia saltar la validacion" ), 1, .oMockInformacionIndividual.Count )

			update diccionario set longitud = 0 where entidad = "RRR"

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosGenericos()
			This.AssertEquals( "No deberia haber saltado la validacion los Atributos Genericos", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR", "atribgen", "C", 0, 0,  "CMPPRUEBAD" )

			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "EEE", "atribgen", "F", 0, 0,  "CMPPRUEBA" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosGenericos()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
							"Deberia saltar la validacion" ), 2, .oMockInformacionIndividual.Count )

		EndWith		

	endfunc

	*-----------------------------------	
	function zTestValidarAtributosReservados
		
		with This.oValidarADN
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR", "GUID", "C", 0, 0,  "CMPPRUEBA" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosReservados()
			This.AssertEquals( "Deberia haber saltado la validacion los Atributos reservados", 1, .oMockInformacionIndividual.Count )

			delete from Diccionario where Entidad = "RRR" and Atributo = "GUID"

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosReservados()
			This.AssertEquals( "No deberia haber saltado la validacion los Atributos reservados", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR", "OAD", "C", 0, 0,  "CMPPRUEBA" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosReservados()
			This.AssertEquals( "Deberia haber saltado la validacion los Atributos reservados", 1, .oMockInformacionIndividual.Count )

			delete from Diccionario where Entidad = "RRR" and Atributo = "OAD"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosReservados()
			This.AssertEquals( "No Deberia haber saltado la validacion los Atributos reservados", 0, .oMockInformacionIndividual.Count )

		EndWith		

	endfunc
	
	*-----------------------------------	
	function zTestValidarCamposReservados
	
		with This.oValidarADN
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR", "GUIDA", "C", 0, 0,  "GUID" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposReservados()
			This.AssertEquals( "Deberia haber saltado la validacion los Atributos reservados", 1, .oMockInformacionIndividual.Count )

			delete from Diccionario where Entidad = "RRR" and campo = "GUID"

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposReservados()
			This.AssertEquals( "No deberia haber saltado la validacion los Atributos reservados", 0, .oMockInformacionIndividual.Count )

		EndWith		

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarClaveForaneaInvalidos

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarClaveForaneaInvalidos()
			This.AssertEquals( "No deberia haber saltado la validacion de las claves foraneas", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( tabla, campo, dominio, claveprimaria, claveforanea );
							 values ( "TTT", "TTTCC", "CODIGOSOLONUMEROS", .t., "PEPE" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarClaveForaneaInvalidos()
			This.AssertEquals( "Deberia haber saltado la validacion de las claves foraneas", 1, .oMockInformacionIndividual.Count )

			delete from Diccionario where tabla =  "TTT" and  campo = "TTTCC"
			
		EndWith

	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function ztestValidarCamposClaveForanea

		local lcEntidad as String
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposClaveForanea()
			This.AssertEquals( "No se ha validado la clave foranea de campos con dominio codigo (1)", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( tabla, campo, dominio, claveprimaria, claveforanea );
							 values ( "TTT", "TTTCC", "CODIGOSOLONUMEROS", .t., "" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposClaveForanea()
			This.AssertEquals( "No se ha validado la clave foranea de campos con dominio codigo (2)", 0, .oMockInformacionIndividual.Count )

			delete from Diccionario where tabla =  "TTT" and  campo = "TTTCC"
			
			insert into Diccionario ( tabla, campo, dominio, claveprimaria, claveforanea );
							 values ( "TTT", "TTTCC", "CODIGOSOLONUMEROS", .F., "" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposClaveForanea()
			This.AssertEquals( "Deberia haber validado la clave foranea de campos con dominio codigo", 1, .oMockInformacionIndividual.Count )

			delete from Diccionario where tabla =  "TTT" and  campo = "TTTCC"

			insert into Diccionario ( tabla, campo, dominio, claveprimaria, claveforanea );
							 values ( "TTT", "TTTCC", "CODIGOSOLONUMEROS", .F., "ENTPEPE" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposClaveForanea()
			This.AssertEquals( "NO Deberia haber validado la clave foranea de campos con dominio codigo", 0, .oMockInformacionIndividual.Count )

		EndWith

	endfunc 

	*-----------------------------------	
	function zTestValidarUnicidadDeEntidades
	
		local lcEntidad as String
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeEntidades()
			This.AssertEquals( "No se ha validado la Unicidad de Entidades 1", 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad ) values ( "PORSCHE_TEST" )
			insert into Entidad ( Entidad ) values ( "PORSCHE_TEST" )
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeEntidades()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
							"No se ha podido validar la unicidad de Entidades" ), 1, .oMockInformacionIndividual.Count )

		EndWith		

	endfunc
	
	*-----------------------------------	
	function zTestValidarClavePrimariaEnEntidad

		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaEnEntidad()
			This.AssertEquals( "No se ha validado la Clave Primaria en Entidad", 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, ClavePrimaria ) Values( "BMW", .f. )
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaEnEntidad()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"No se ha podido validar la Clave Primaria"), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	
	*-----------------------------------	
	function zTestValidarEtiquetaCorta

		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarEtiquetaCorta()
			This.AssertEquals( "No se ha validado la etiqueta corta 1", 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, ClavePrimaria, alta ) Values( "BMW", .f., .t. )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarEtiquetaCorta()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"No se ha podido validar la etiqueta corta 2"), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc

	*-----------------------------------		
	function zTestValidarAtributosNoRepetidos
	
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosNoRepetidos()				
			This.AssertEquals( "Falló la validacion de Atributos No Repetidos", 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo ) values ( "BMW", "Codigo" )
			insert into Diccionario ( Entidad, Atributo ) values ( "BMW", "Codigo" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosNoRepetidos()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"No se han validado atributos No Repetidos") , 1, .oMockInformacionIndividual.Count )
		EndWith
	endfunc	
	*-----------------------------------			
	function zTestValidarTipodatoLongitudDecimalesEtiqueta
	
		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()				
			This.AssertEquals( "Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta", 0, .oMockInformacionIndividual.Count )	
			
			insert into Dominio ( Dominio ) values ( "CARACTER" )
			insert into Dominio ( Dominio ) values ( "OBSERVACION" )
			
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, etiqueta, dominio ) ;
				values ( "BMW", "Descripcion", "C", 0, 0, "", "CARACTER" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
					"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 1" ), 1, .oMockInformacionIndividual.Count )	
			
			update diccionario set longitud = 30 where entidad = "BMW"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 2" ), 0, .oMockInformacionIndividual.Count )	
			
			update diccionario set decimales = 2 where entidad = "BMW"		
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 3" ), 1, .oMockInformacionIndividual.Count )
			
			update diccionario set etiqueta = "etiqueta" where entidad = "BMW"		

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 4" ), 1, .oMockInformacionIndividual.Count )
			
			update diccionario set decimales = 0 where entidad = "BMW"	
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 5" ), 0, .oMockInformacionIndividual.Count )
			
			select Diccionario
			delete for entidad = "BMW"
			
			
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, etiqueta, dominio ) ;
				Values( "BMW", "Puerta", "", 0, 0, "Etiqueta", "CARACTER" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 6" ), 1, .oMockInformacionIndividual.Count )	

			update diccionario set Tipodato = "N" where entidad = "BMW"		

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 7" ), 1, .oMockInformacionIndividual.Count )	
			
			update diccionario set Longitud = 20 where entidad = "BMW"				

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 8"), 0, .oMockInformacionIndividual.Count )	

			update diccionario set Longitud = 0, Decimales = 0, TipoDato = "M", Dominio = "OBSERVACION" where entidad = "BMW"				

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 9"), 0, .oMockInformacionIndividual.Count )	
				
			update diccionario set Longitud = 1, Decimales = 0, TipoDato = "M", Dominio = "OBSERVACION" where entidad = "BMW"				
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipodatoLongitudDecimalesEtiqueta()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló la validacion de Tipo de Dato, Longitud, Decimales o Etiqueta 10"), 0, .oMockInformacionIndividual.Count )	

		endwith
	endfunc
	*-----------------------------------				
	function zTestValidarDominioEnDiccionario
	
		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioEnDiccionario()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Dominios en Diccionario" ), 0, .oMockInformacionIndividual.Count )


			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, dominio ) ;
				values ( "BMW", "Descripcion", "" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioEnDiccionario()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Dominios en Diccionario" ), 1, .oMockInformacionIndividual.Count )	
		endwith
	endfunc
	*-----------------------------------					
	function zTestValidarValorSubgrupo
	
		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarValorSubgrupo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Valor de Subgrupos en Diccionario" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Entidad (Entidad) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, tiposubgrupo, Alta ) ;
				values ( "BMW", "Descripcion", 0 , .T. )

			.oMockInformacionIndividual.Limpiar()
			.ValidarValorSubgrupo()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
					"Falló Validación de Valor de Subgrupos en Diccionario 1" ), 1, .oMockInformacionIndividual.Count )

			update diccionario set Alta = .F. where entidad = "BMW"		

			.oMockInformacionIndividual.Limpiar()
			.ValidarValorSubgrupo()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
					"Falló Validación de Valor de Subgrupos en Diccionario 2" ), 0, .oMockInformacionIndividual.Count )

		EndWith	
	endfunc
	*-----------------------------------						
	function zTestValidarTiposSubgrupo	
	
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTiposSubgrupo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Tipo de Subgrupos en  Diccionario" ), 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, grupo, subgrupo, tiposubgrupo, Alta) ;
				values ( "BMW", "Descripcion", 0, 2, 1, .T. )			
			insert into Diccionario ( Entidad, Atributo, grupo, subgrupo, tiposubgrupo, Alta ) ;
				Values( "BMW", "Descripcion", 0, 2, 2, .T. )			

			.oMockInformacionIndividual.Limpiar()
			.ValidarTiposSubgrupo()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Tipo de Subgrupos en  Diccionario 1" ), 1, .oMockInformacionIndividual.Count )	

			update diccionario set Alta = .F. where entidad = "BMW"		
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarTiposSubgrupo()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Tipo de Subgrupos en  Diccionario 1" ), 0, .oMockInformacionIndividual.Count )	

		EndWith
	endfunc
	*-----------------------------------	
	function zTestValidarAtributosVacios
	
		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosVacios()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos Vacíos en  Diccionario" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo ) ;
				values ( "BMW", "" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosVacios()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos Vacíos en  Diccionario" ), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------						
	function zTestValidarAtributosSinDominio
	
		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosSinDominio()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos sin dominio en Diccionario" ), 0, .oMockInformacionIndividual.Count )	

			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, dominio ) ;
				Values( "BMW", "Prueba", "" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosSinDominio()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos sin dominio en Diccionario 1" ), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------							
	function zTestValidarAyudaEnFormularios
	
		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAyudaEnFormularios()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Ayuda en Formularios"), 0, .oMockInformacionIndividual.Count )
				
			insert into Dominio ( Dominio ) values ( "DESCRIPCION" )
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, Dominio, alta, ayuda ) ;
				values ( "BMW", "Prueba", "DESCRIPCION", .t., "" )			

			.oMockInformacionIndividual.Limpiar()
			.ValidarAyudaEnFormularios()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Ayuda en Formularios 1" ), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------								
	function zTestValidarDominioCodigo
	
		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioCodigo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Dominio Código" ), 0, .oMockInformacionIndividual.Count )	
				
			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, dominio, claveprimaria, claveforanea ) ;
				values ( "BMW", "Prueba", "CODIGO", .f., "" )			

			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioCodigo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Dominio Código" ), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------									
	function zTestValidarComposicionDeBloques
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarComposicionDeBloques()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar bloques). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar bloques). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + oInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				insert into dominio ( Dominio, esBloque ) values ( "DOMINIO_PORSCHE_TEST", .t. )
				insert into diccionario ( Entidad, Atributo, Dominio, grupo, subgrupo, alta ) values ( "PORSCHE_TEST", "Motor", "DOMINIO_PORSCHE_TEST", 0, 0, .t. )
				insert into diccionario ( Entidad, Atributo, Dominio, grupo, subgrupo, alta ) values ( "PORSCHE_TEST", "Torque", "DOMINIO_PORSCHE_TEST", 0, 1, .t. )
				insert into diccionario ( Entidad, Atributo, Dominio, grupo, subgrupo, alta ) values ( "PORSCHE_TEST", "Valvula", "DOMINIO_PORSCHE_TEST", 0, 1, .t. )

				.oMockInformacionIndividual.Limpiar()
				.ValidarComposicionDeBloques()
				This.AssertEquals( "PORSCHE_TEST tiene dos bloques con cant de atributos distintos y no Pinchó", 1, .oMockInformacionIndividual.Count )

				insert into diccionario ( Entidad, Atributo, Dominio, grupo, subgrupo, alta ) values ( "PORSCHE_TEST", "Bateria", "DOMINIO_PORSCHE_TEST", 0, 0, .t. )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarComposicionDeBloques()
				This.AssertEquals( "PORSCHE_TEST tiene dos bloques con cant de atributos iguales y Pinchó", 0, .oMockInformacionIndividual.Count )

			endif
			delete from diccionario where upper( alltrim( Entidad ) ) == "PORSCHE_TEST"			
			delete from dominio where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"			
		endwith
	endfunc
	*-----------------------------------										
	function zTestValidarControlesEstilos
		local lnIdControl As Integer

		with This.oValidarADN
			.ValidarControlesEstilos()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Controles Estilos" ), 0, .oMockInformacionIndividual.Count )

			insert into Estilos ( id, Descripcion ) values ( 1, "Lince" )
			insert into Controles ( id, Descripcion ) values ( 999, "ControlDePrueba" )
			lnIdControl = Controles.Id

			.ValidarControlesEstilos()			
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Se agregó ControlDePrueba y no pinchó" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------
	function zTestValidar
		local llValidacion as Boolean
		with This.oValidarADN
			.InsertarStockCombinacionyEquivalencias()

			llValidacion = .Validar()
			This.AssertTrue( "Fallaron validaciones en el ADN(1)", llValidacion )

			insert into Entidad ( Entidad ) values ( "BMW" )
			insert into Diccionario ( Entidad, Atributo, dominio, claveprimaria, claveforanea ) ;
				Values( "BMW", "Prueba", "CODIGO", .f., "" )			

			llValidacion = .Validar()
			This.AssertTrue( "Fallaron validaciones en el ADN(2)", !llValidacion )
			
			.EliminarStockCombinacionyEquivalencias()
		EndWith
	endfunc

	*-----------------------------------
	function zTestValidarDescripcionesGrupo
		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionesGrupo()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Grupo" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo, grupo, Descripciongrupo, Alta ) ;
				values ( "BMW", "Prueba", 0, "Des1", .T. )			
			insert into Diccionario ( Entidad, Atributo, grupo, Descripciongrupo, Alta ) ;
				values ( "BMW", "Prueba2", 0, "Des2", .T. )
			insert into Diccionario ( Entidad, Atributo, grupo, Descripciongrupo, Alta ) ;
				values ( "BMW", "Prueba3", 0, "Des2", .T. )

			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionesGrupo()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Grupo 1" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc
	
	*-----------------------------------		
	function zTestValidarSeguridadEntidadesDefault
	
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarSeguridadEntidadesDefault()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Tabla SeguridadEntidadesDefault" ), 0, .oMockInformacionIndividual.Count )
				
			insert into SeguridadEntidadesDefault (Operacion) values ("New")
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarSeguridadEntidadesDefault()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Tabla SeguridadEntidadesDefault" ), 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function zTestValidarDescripcionesSubgrupo
	
		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionesSubgrupo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Descripción de Subgrupos en  Diccionario" ), 0, .oMockInformacionIndividual.Count )	
				
			insert into Diccionario ( Entidad, Atributo, grupo, subgrupo, descripcionsubgrupo, Alta ) ;
					values ( "BMW", "Descripcion", 0, 2, "Pepe", .T. )
			insert into Diccionario ( Entidad, Atributo, grupo, subgrupo, descripcionsubgrupo, Alta ) ;
					values ( "BMW", "Descripcio2", 0, 2, "Carlos", .T. )


			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionesSubgrupo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Descripción de Subgrupos en  Diccionario 1" ), 1, .oMockInformacionIndividual.Count )	
		endwith
	endfunc	

	*-----------------------------------										
	Function zTestValidarDescripcionGrupo

		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionGrupo( "BMW", "Des1", 0 )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Grupo" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, grupo, Descripciongrupo, Alta ) ;
				values ( "BMW", 0, "Des1", .T. )
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionGrupo( "BMW", "Des2", 0 )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Grupo 1" ), 1, .oMockInformacionIndividual.Count )
		EndWith
	Endfunc

	*-----------------------------------										
	Function zTestValidarDescripcionSubGrupo

		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionSubGrupo( "BMW", "Des1", 0 , 0 )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion SubGrupo" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, grupo, Subgrupo, DescripcionSubGrupo , Alta ) ;
				values ( "BMW", 0, 0, "Des1", .T. )
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionSubGrupo( "BMW", "Des2", 0, 0 )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion SubGrupo 1" ), 1, .oMockInformacionIndividual.Count )
		EndWith
	Endfunc
	
	*-----------------------------------										
	Function zTestValidarLargoTablaMemo

		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarLargoTablaMemo( "Tabla", "Atributo", "Entidad" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Largo Tabla Memo" ), 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLargoTablaMemo( "TablaConNombreMuyyyyyyyyLargooooooooooo", "AtributoConNombreMuyyyyyyyLargooooooo", "Entidad" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Largo Tabla Memo 1" ), 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLargoTablaMemo( "", "AtributoConNombreMuyyyyyyyLargooooooo", "Entidad" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Largo Tabla Memo 2" ), 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLargoTablaMemo( "TablaConNombreMuyyyyyyyyLargooooooooooo", "", "Entidad" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Largo Tabla Memo 3" ), 0, .oMockInformacionIndividual.Count )

		EndWith
	Endfunc

	*-----------------------------------										
	Function zTestValidarLargoTablaMemoGenerico

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarLargoTablaMemoGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Largo Tabla Memo Generico" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo, Tabla, TipoDato ) ;
				values ( "BMW", "ATRIBUTOLARGOPEROMUYLARGO" , "TABLAALRGAPEROMUYLARGA", "M" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLargoTablaMemoGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Largo Tabla Memo Generico 1" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc
	
	*-----------------------------------										
	Function zTestValidarSumarizarGenerico

		with This.oValidarADN


			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico" ), 0, .oMockInformacionIndividual.Count )

			** suma el atributo 1 en el atributo 2
			insert into Diccionario ( Entidad, Atributo, TipoDato, Sumarizar ) ;
				values ( "BMW", "ATRIBUTO1" , "C", "" )
			
			insert into Diccionario ( Entidad, Atributo, TipoDato, Sumarizar ) ;
				values ( "BMW", "ATRIBUTO2" , "C", "ATRIBUTO1" )


			** ambos atributos caracter
			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico 1" ), 2, .oMockInformacionIndividual.Count )
				
			** atributo 1 numérico, atributo 2 caracter
			update Diccionario set TipoDato = "N" where Entidad = "BMW" and Atributo = "ATRIBUTO1"

			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico 2" ), 0, .oMockInformacionIndividual.Count )

			** atributo 1 caracter, atributo 2 numérico
			update Diccionario set TipoDato = "C" where Entidad = "BMW" and Atributo = "ATRIBUTO1"
			update Diccionario set TipoDato = "N" where Entidad = "BMW" and Atributo = "ATRIBUTO2"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico 3" ), 2, .oMockInformacionIndividual.Count )

			** atributo 1 numérico, atributo 2 numérico
			update Diccionario set TipoDato = "N" where Entidad = "BMW" and Atributo = "ATRIBUTO1"

			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico 4" ), 0, .oMockInformacionIndividual.Count )
			
			
			** totaliza el atributo 2 en el atributo 2
			update Diccionario set Sumarizar = "ATRIBUTO2" where Entidad = "BMW" and Atributo = "ATRIBUTO2"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico 5" ), 0, .oMockInformacionIndividual.Count )

			** borrando el que sumarizo
			update Diccionario set Sumarizar = "ATRIBUTO1" where Entidad = "BMW" and Atributo = "ATRIBUTO2"
			delete from Diccionario where Entidad = "BMW" and Atributo = "ATRIBUTO1"

			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizarGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar Generico 6" ), 3, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarSumarizar

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizar( "N" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar" ), 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarSumarizar( "C" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Sumarizar 1" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarDescripcionEntidad

		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionEntidad( "BMW" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Entidad" ), 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionEntidad( "" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Entidad 1" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarEntidad

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidad( "BMW" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Nombre Entidad" ), 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidad( "" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Nombre Entidad 1" ), 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidad( "!!!!!" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Nombre Entidad 2" ), 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidad( "BVB DFDF" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Nombre Entidad 3" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarDescripcionEntidadGenerico

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionEntidadGenerico( )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Entidad Generico" ), 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad ) values ( "BMW" )
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarDescripcionEntidadGenerico( )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Descripcion Entidad Generico 1" ), 2, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarCampoBusquedaGenerico

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoBusquedaGenerico()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Campo Busqueda Generico" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo, BusquedaOrdenamiento ) values ( "BMW", "AtributoPrueba", .T. )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoBusquedaGenerico( )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Campo Busqueda Generico 1" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarAutoCompletar

		with This.oValidarADN
			insert into Dominio ( Dominio, AutoCompletar ) values ( "DOMINIOBMW", .T. )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletar( "DOMINIOBMW" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar" ), 0, .oMockInformacionIndividual.Count )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletar( "DominioBMW" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar 1" ), 0, .oMockInformacionIndividual.Count )

			update Dominio set AutoCompletar = .F. where Dominio = "DOMINIOBMW"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletar( "DOMINIOBMW" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar 2" ), 1, .oMockInformacionIndividual.Count )

			delete from Dominio where Dominio = "DOMINIOBMW"
			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletar( "DOMINIOBMW" )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar 3" ), 1, .oMockInformacionIndividual.Count )
			
		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarAutoCompletarGenerico

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()		
			.ValidarAutoCompletarGenerico(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar Generico " ), 0, .oMockInformacionIndividual.Count )
			
			insert into Dominio ( Dominio, AutoCompletar ) values ( "DOMINIOBMW", .T. )
			insert into Diccionario ( Entidad, Atributo, Dominio, AutoCompletar ) values ;
						( "BMW", "AtriibutoPrueba", "DominioBMW", .T. )			
						
			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletarGenerico(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar Generico 1" ), 0, .oMockInformacionIndividual.Count )

			update Dominio set AutoCompletar = .F. where Dominio = "DOMINIOBMW"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletarGenerico(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar Generico 2" ), 2, .oMockInformacionIndividual.Count )

			delete from Dominio where Dominio = "DOMINIOBMW"				
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAutoCompletarGenerico(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación AutoCompletar Generico 3" ), 2, .oMockInformacionIndividual.Count )
			
		EndWith
	endfunc

	*-----------------------------------										
	Function zTestValidarDominioExistenteEnDiccionario

		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioExistenteEnDiccionario(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Dominio existente en diccionario" ), 0, .oMockInformacionIndividual.Count )
			insert into Dominio ( Dominio ) values ( "DOMINIOBMW" )
			insert into Diccionario ( Entidad, Atributo, Dominio ) values ;
						( "BMW", "AtriibutoPrueba", "DominioBMW" )			
						
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioExistenteEnDiccionario(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Dominio existente en diccionario 1" ), 0, .oMockInformacionIndividual.Count )

			delete from Dominio where Dominio = "DOMINIOBMW"			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioExistenteEnDiccionario(  )
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación Dominio existente en diccionario 2" ), 1, .oMockInformacionIndividual.Count )

		EndWith
	endfunc
	
	*-----------------------------------	
	function zTestValidarCampoBusquedaOrden

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoBusquedaOrden()
			This.AssertEquals( "Falló Validación Campo Búsqueda Orden" , 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad, Tipo ) values ( "BMW", "E" )
			insert into Diccionario ( entidad, atributo , clavePrimaria, busquedaOrdenamiento ) ;
				values ( "BMW", "Nuevo", .t., .f. )	
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoBusquedaOrden()
			This.AssertEquals( "Falló Validación Campo Búsqueda Orden 1" , 1, .oMockInformacionIndividual.Count )

			update Entidad set Tipo = "I" where Entidad = "BMW"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoBusquedaOrden()
			This.AssertEquals( "Falló Validación Campo Búsqueda Orden 2" , 0, .oMockInformacionIndividual.Count )
				
		endwith
	
	endfunc 
	
	*-----------------------------------		
	function zTestvalidarCampoAdmiteBusqueda
		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoAdmiteBusqueda()
			This.AssertEquals( "Falló Validación Campo AdmiteBusqueda" , 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad ( Entidad, Tipo, formulario ) values ( "BMW", "E", .t. )
			insert into Diccionario ( entidad, atributo , clavePrimaria, admitebusqueda ) ;
				values ( "BMW", "Nuevo", .T., 0 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoAdmiteBusqueda()
			This.AssertEquals( "Falló Validación Campo AdmiteBusqueda 1" , 1, .oMockInformacionIndividual.Count )

			update Entidad set Tipo = "I" where Entidad = "BMW"				
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoAdmiteBusqueda()
			This.AssertEquals( "Falló Validación Campo AdmiteBusqueda 2" , 0, .oMockInformacionIndividual.Count )
			
			update Entidad set Tipo = "E" where Entidad = "BMW"				
			update diccionario set admitebusqueda = 2 where Entidad = "BMW"	and atributo = "Nuevo"

			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoAdmiteBusqueda()
			This.AssertEquals( "Falló Validación Campo AdmiteBusqueda 3" , 0, .oMockInformacionIndividual.Count )
			
		endwith
	
	endfunc 
										
	*-----------------------------------		
	function zTestValidarAdmiteBusquedaEnAtributoSinAsociacionDeCampo
		local lcDominio As String
		lcDominio = upper( sys(2015) )

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdmiteBusquedaEnAtributoSinAsociacionDeCampo()
			This.AssertEquals( "Falló Validación AdmiteBusqueda en Atributo sin Asociación de Campo (1)" , 0, .oMockInformacionIndividual.Count )
			
			insert into Dominio( Dominio, Detalle ) values ( lcDominio, .T. )
			insert into Entidad( Entidad, Formulario, Tipo ) values ( lcDominio, .T., "E" )
			insert into Diccionario ( Entidad, Atributo,Dominio, AdmiteBusqueda ) values ;
				( lcDominio, "ATRIBUTO1", lcDominio, 1 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdmiteBusquedaEnAtributoSinAsociacionDeCampo()
			This.AssertEquals( "Falló Validación AdmiteBusqueda en Atributo sin Asociación de Campo (2)" , 1, .oMockInformacionIndividual.Count )
			
			delete from Diccionario where upper( alltrim( Entidad ) ) = lcDominio
			delete from Entidad where upper( alltrim( Entidad ) ) = lcDominio
			delete from Dominio where upper( alltrim( dominio ) ) = lcDominio
		endwith
	
	endfunc 

	*-----------------------------------		
	function zTestValidarEntidadConFuncionalidadGuardarComoEnToolbar
		local lcEntidad As String
		lcEntidad = upper( sys(2015) )

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadConFuncionalidadGuardarComoEnToolbar()
			This.AssertEquals( "Falló Validar la Entidad con Funcionalidad Guardar Como en la Toolbar (1)" , 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad( Entidad, Funcionalidades ) values ( lcEntidad, "<GUARDARCOMO>" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadConFuncionalidadGuardarComoEnToolbar()
			This.AssertEquals( "Falló Validar la Entidad con Funcionalidad Guardar Como en la Toolbar (2). No hay registros en Menualtasitems." , 1, .oMockInformacionIndividual.Count )

			insert into Menualtasitems ( Entidad, Codigo, toolbar ) values ;
				( lcEntidad, "GuardarComo", .F. )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadConFuncionalidadGuardarComoEnToolbar()
			This.AssertEquals( "Falló Validar la Entidad con Funcionalidad Guardar Como en la Toolbar (3). El campo toolbar esta en False." , 1, .oMockInformacionIndividual.Count )
			
			delete from Entidad where upper( alltrim( Entidad ) ) = lcEntidad
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadConFuncionalidadGuardarComoEnToolbar()
			This.AssertEquals( "Falló Validar la Entidad con Funcionalidad Guardar Como en la Toolbar (4). No está el tag GUARDARCOMO en Entidad." , 1, .oMockInformacionIndividual.Count )

			delete from Menualtasitems where upper( alltrim( Entidad ) ) = lcEntidad
		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestMuestraRelacion
		local i as Integer

		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarMuestraRelacion()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Muestra relación). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0

				.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Muestra relación). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor

			else			

				**** Validamos los atributos PORSCHE_TEST que tiene dos muestra relacion ***************************
				
				insert into entidad ( entidad, tipo, formulario ) values ( "ALFAROMEO_TEST", "E", .F. )
				insert into diccionario ( entidad, atributo, muestrarelacion ) values ( "ALFAROMEO_TEST", "Modelo", .t. )
				insert into diccionario ( entidad, atributo, muestrarelacion ) values ( "ALFAROMEO_TEST", "Motor", .t. )				
					
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "ALFAROMEO_TEST tiene dos muestra relacion y formulario en False y no valido como correcto", 0, .oMockInformacionIndividual.Count )
					
					
				insert into entidad ( entidad, tipo, formulario ) values ( "PORSCHE_TEST", "E", .t. )
				insert into diccionario ( entidad, atributo, muestrarelacion ) values ( "PORSCHE_TEST", "Modelo", .t. )
				insert into diccionario ( entidad, atributo, muestrarelacion ) values ( "PORSCHE_TEST", "Motor", .t. )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "PORCHE_TEST tiene dos muestra relacion y valido como correcto", 1, .oMockInformacionIndividual.Count )
			
				insert into diccionario ( entidad, atributo, muestrarelacion ) values ( "PORSCHE_TEST", "DescripcionTecnica", .f. )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "PORCHE_TEST tiene dos muestra relacion y valido como correcto", 1, .oMockInformacionIndividual.Count )
				
				**** Modificamos los atributos de PORSCHE_TEST para que tenga un solo muestra relacion ************
				
				update diccionario set muestrarelacion = .f. where upper(alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "PORCHE_TEST tiene un solo muestra relacion y valido como incorrecto", 0, .oMockInformacionIndividual.Count )
				
				if .oMockInformacionIndividual.Count > 0
					.messageout( "PORCHE_TEST tiene un solo muestra relacion y valido como incorrecto" )
					for i = 1 to .oMockInformacionIndividual.count
						.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
					endfor
				endif

				**** Validamos los atributos PORSCHE_TEST no tiene ningun muestra relacion *************************
				
				update diccionario set muestrarelacion = .f. where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"
				update diccionario set muestrarelacion = .f. where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MOTOR"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "PORCHE_TEST no tiene muestra relacion y valido como correcto", 1, .oMockInformacionIndividual.Count )

				
				**** Validamos los atributos PORSCHE_TEST Tiene muestraRelacion y es un detalle *************************
				
				update diccionario set muestrarelacion = .t., Dominio = "DETALLEPORSCHE_TEST" where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"
				insert into dominio ( Dominio, EsBloque, Detalle ) values ( "DETALLEPORSCHE_TEST", .t., .t. )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "Se declaró a PORSCHE_TEST como Detalle y no pinchó", 2, .oMockInformacionIndividual.Count )


				**** Validamos los atributos PORSCHE_TEST Tiene muestraRelacion y sin que sea un detalle *************************
				
				delete from dominio where upper( alltrim( dominio ) ) == "DETALLEPORSCHE_TEST"
				update diccionario set muestrarelacion = .t., Dominio = "CARACTER" where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "Se actualizó a PORSCHE_TEST como que NO es Detalle y pinchó", 0, .oMockInformacionIndividual.Count )
				
				**** Validamos los atributos PORSCHE_TEST Tiene muestraRelacion y clave foránea *************************
				
				update diccionario set Dominio = "CARACTER", CLAVEFORANEA = "MODELO" where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "Se le puso a PORSCHE_TEST clave foránea y no pinchó", 1, .oMockInformacionIndividual.Count )

				**** Validamos los atributos PORSCHE_TEST Tiene muestraRelacion y NO clave foránea *************************
				
				update diccionario set Dominio = "CARACTER", CLAVEFORANEA = "" where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarMuestraRelacion()
				This.AssertEquals( "Se le puso a PORSCHE_TEST clave foránea y pinchó", 0, .oMockInformacionIndividual.Count )
			endif
			
			**** Borramos las entidades generadas *************************************************************
			delete from dominio where upper( alltrim( dominio ) ) == "DETALLEPORSCHE_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "ALFAROMEO_TEST"			
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
			delete from diccionario where upper( alltrim( entidad ) ) == "ALFAROMEO_TEST"			
		EndWith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestClaveCompuestaSinMemo
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaSinMemo()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (ClavePrimariaSinMemo). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0

				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (ClavePrimariaSinMemo). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor

			else
				**** Validamos los atributos PORSCHE_TEST que tiene clave primaria compuesta ***************************
				
				insert into entidad ( entidad, tipo ) values ( "PORSCHE_TEST", "E" )
				insert into diccionario ( entidad, atributo, ClavePrimaria ) values ( "PORSCHE_TEST", "Modelo", .t. )
				insert into diccionario ( entidad, atributo, ClavePrimaria ) values ( "PORSCHE_TEST", "Motor", .t. )
				insert into diccionario ( entidad, atributo, TipoDato ) values ( "PORSCHE_TEST", "Observaciones", "M" )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarClavePrimariaSinMemo()
				This.AssertEquals( "PORCHE_TEST tiene clave compuesta con un campo memo y no pinchó", 1, .oMockInformacionIndividual.Count )

				**** Validamos los atributos PORSCHE_TEST que no tiene clave primaria compuesta ***************************
				delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and alltrim( atributo ) == "Motor"

				.oMockInformacionIndividual.Limpiar()
				.ValidarClavePrimariaSinMemo()
				This.AssertEquals( "PORCHE_TEST tiene clave compuesta con un campo memo y no pinchó", 0, .oMockInformacionIndividual.Count )
			endif
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestComboTabla
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarCombosTabla()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (ComboTabla). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (ComboTabla). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else

				insert into diccionario ( entidad, atributo, dominio, ClaveForanea ) values ( "PORSCHE_TEST", "Modelo", "COMBOTABLA", "" )
				**** Validamos los atributos PORSCHE_TEST que es comboTabla y tiene Clave Foranea ***************************

				.oMockInformacionIndividual.Limpiar()
				.ValidarCombosTabla()
				This.AssertEquals( "PORCHE_TEST es comboTabla sin Clave Foranea y no pinchó", 1, .oMockInformacionIndividual.Count )
				
				**** Validamos los atributos PORSCHE_TEST que es comboTabla y no es Clave Foranea ***************************
				update diccionario set CLAVEFORANEA = "Modelos" where upper( alltrim( entidad ) ) == "PORSCHE_TEST" and upper( alltrim( Atributo ) ) == "MODELO"

				.oMockInformacionIndividual.Limpiar()
				.ValidarCombosTabla()
				This.AssertEquals( "PORCHE_TEST es comboTabla con Clave Foranea y pinchó", 0, .oMockInformacionIndividual.Count )

			endif
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestClavesForaneasComoEntidad
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavesForaneasComoEntidad()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Claves Foraneas Como Entidad). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Claves Foraneas Como Entidad). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				**** Validamos los atributos PORSCHE_TEST que tiene una clave foranea inexistente ***************************
				insert into entidad ( entidad ) values ( "PORSCHE_TEST" )
				insert into diccionario ( entidad, atributo, ClaveForanea ) values ( "PORSCHE_TEST", "Modelo", "MODELO_TEST" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarClavesForaneasComoEntidad()
				This.AssertEquals( "PORCHE_TEST tiene una clave foranea inexistente y no pinchó.", 1, .oMockInformacionIndividual.Count )
				
				**** Validamos los atributos PORSCHE_TEST que tiene una clave foranea existente ***************************
				insert into entidad ( entidad ) values ( "MODELO_TEST" )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarClavesForaneasComoEntidad()
				This.AssertEquals( "PORCHE_TEST tiene una clave foranea existente y pinchó.", 0, .oMockInformacionIndividual.Count )

				**** Validamos todo luego de recomponer al estado original ***************************
				delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				delete from entidad where upper( alltrim( entidad ) ) == "MODELO_TEST"

				.oMockInformacionIndividual.Limpiar()
				.ValidarClavesForaneasComoEntidad()
				This.AssertEquals( "Se borro PORCHE_TEST y pinchó.", 0, .oMockInformacionIndividual.Count )
				
			
				**** Validamos los atributos VALORES_TEST que tiene una clave foranea parecida a una existente ****************
				insert into entidad ( entidad ) values ( "VALORES_TEST" )
				insert into diccionario ( entidad, atributo, ClaveForanea ) values ( "VALORES_TEST", "Pesos", "VALORES" )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarClavesForaneasComoEntidad()
				This.AssertEquals( "VALORES_TEST tiene una clave foranea inexistente y no pincho.", 1, .oMockInformacionIndividual.Count )
				
			endif
			
			delete from diccionario where upper( alltrim( entidad ) ) == "VALORES_TEST"
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "MODELO_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "VALORES_TEST"			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestMemosEnItems
		local	loRetorno as Object, i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarMemosEnItems()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Claves Foraneas Como Entidad). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Claves Foraneas Como Entidad). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				**** Validamos los atributos PORSCHE_TEST que tiene detalle con tipo de dato Memo ***************************
				insert into entidad ( entidad, tipo ) values ( "ItemModelo_Test", "I" )
				insert into diccionario ( entidad, atributo, TipoDato, Tabla, Campo ) values ( "ItemModelo_Test", "Color", "M", "pp", "pp" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarMemosEnItems()
				This.AssertEquals( "ItemModelo_Test es un Item con un atributo tipo Memo y no pinchó", 1, .oMockInformacionIndividual.Count )

				**** Validamos los atributos PORSCHE_TEST que tiene detalle con tipo de dato Character ***************************
				update diccionario set TipoDato = "C" where upper( alltrim( entidad ) ) == upper( "ItemModelo_Test" ) and upper( alltrim( Atributo ) ) == upper( "Color" )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarCombosTabla()
				This.AssertEquals( "ItemModelo_Test es un Item con un atributo tipo Character y pinchó", 0, .oMockInformacionIndividual.Count )

				**** Validamos todo luego de recomponer al estado original ***************************
				delete from diccionario where upper( alltrim( entidad ) ) == upper( "ItemModelo_Test" )
				delete from entidad where upper( alltrim( entidad ) ) == upper( "ItemModelo_Test" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarClavesForaneasComoEntidad()
				This.AssertEquals( "Se borro ItemModelo_Test y pinchó", 0, .oMockInformacionIndividual.Count )
			endif
			delete from diccionario where upper( alltrim( entidad ) ) == upper( "ItemModelo_Test" )
			delete from entidad where upper( alltrim( entidad ) ) == upper( "ItemModelo_Test" )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestPalabrasReservadas
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarPalabrasReservadas()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Claves Foraneas Como Entidad). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 1
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Claves Foraneas Como Entidad). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				**** Validamos los atributos PORSCHE_TEST que tiene como nombre de campo una palabra reservada ***************************
				insert into diccionario ( entidad, atributo, Campo ) values ( "PORSCHE_TEST", "Modelo", "_tally" )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarPalabrasReservadas()
				This.AssertEquals( "PORCHE_TEST tiene como nombre de campo la palabra reservada '_tally' y no pinchó", 1, .oMockInformacionIndividual.Count )

				**** Validamos los atributos PORSCHE_TEST que NO tiene como nombre de campo una palabra reservada ***************************
				update diccionario set Campo  = "Campo" where upper( alltrim( entidad ) ) == "PORSCHE_TEST"

				.oMockInformacionIndividual.Limpiar()
				.ValidarPalabrasReservadas()
				This.AssertEquals( "PORCHE_TEST NO tiene como nombre de campo la palabra reservada 'campo' y pinchó", 0, .oMockInformacionIndividual.Count )

				**** Validamos todo luego de recomponer al estado original ***************************
				delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"

				.oMockInformacionIndividual.Limpiar()
				.ValidarClavesForaneasComoEntidad()
				This.AssertEquals( "Se borro PORCHE_TEST y pinchó", 0, .oMockInformacionIndividual.Count )
			endif
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
		endwith
	
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestTablaCampo
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarTablaCampo()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 1
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla campo). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				**** Validamos los atributos PORSCHE_TEST que tiene dos atributos apuntando a la misma tabla+campo con diferentes tipo de datos ***************************
				insert into diccionario ( entidad, atributo, tabla, Campo, tipoDato ) values ( "PORSCHE_TEST", "Modelo", "Modelos", "ModCod", "C" )
				insert into diccionario ( entidad, atributo, tabla, Campo, tipoDato ) values ( "PORSCHE_TEST", "Modelo2", "Modelos", "ModCod", "L" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampo()
				This.AssertEquals( "PORCHE_TEST tiene dos atributos apuntando a la misma tabla+campo con diferentes tipo de datos y no pinchó", 3, .oMockInformacionIndividual.Count )

				**** Validamos los atributos PORSCHE_TEST que tiene dos atributos apuntando a la misma tabla+campo con diferentes tipo de datos ***************************
				update diccionario set TipoDato = "C"	where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampo()
				This.AssertEquals( "PORCHE_TEST tiene las cosas bien ahora y pincho", 0, .oMockInformacionIndividual.Count )

			endif
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestTablaCampoVsClaveForanea
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarTablaCampovsClaveForanea()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo versus Clave Foranea). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo versus Clave Foranea). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				**** Validamos PORSCHE_TEST que tiene un atributo clave primaria y ;
					y PORSCHE_TEST_SUBENTIDAD que tiene clave foranea a PORSCHE_TEST ;
					La idea es que tienen que coincidir el tipo de dato, longitud y decimales de ambos
				insert into diccionario ( entidad, atributo, tipoDato, ClavePrimaria ) values ;
							( "PORSCHE_TEST", "Modelo", "C", .T. )
				insert into diccionario ( entidad, atributo, tipoDato, ClaveForanea ) values ;
							( "PORSCHE_TEST_SUBENTIDAD", "Modelo", "L", "PORSCHE_TEST" )
							
				.oMockInformacionIndividual.Limpiar()							
				.ValidarTablaCampovsClaveForanea()
				This.AssertEquals( "PORCHE_TEST y PORSCHE_TEST_SUBENTIDAD tienen Diferentes tipos de datos para su Join de ClavePrimaria y ClaveForanea y no pinchó", 1, .oMockInformacionIndividual.Count )

				update diccionario set TipoDato = "C", Longitud = 10	where upper( alltrim( entidad ) ) == "PORSCHE_TEST_SUBENTIDAD"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampovsClaveForanea()
				This.AssertEquals( "PORCHE_TEST y PORSCHE_TEST_SUBENTIDAD tienen Diferentes Longitudes para su Join de ClavePrimaria y ClaveForanea y no pinchó", 1, .oMockInformacionIndividual.Count )

				update diccionario set TipoDato = "C", Longitud = 0, Decimales = 10	where upper( alltrim( entidad ) ) == "PORSCHE_TEST_SUBENTIDAD"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampovsClaveForanea()
				This.AssertEquals( "PORCHE_TEST y PORSCHE_TEST_SUBENTIDAD tienen Diferentes Decimales para su Join de ClavePrimaria y ClaveForanea y no pinchó", 1, .oMockInformacionIndividual.Count )

				update diccionario set TipoDato = "C", Longitud = 0, Decimales = 0	where upper( alltrim( entidad ) ) == "PORSCHE_TEST_SUBENTIDAD"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampovsClaveForanea()
				This.AssertEquals( "PORCHE_TEST y PORSCHE_TEST_SUBENTIDAD estan bien para su Join de ClavePrimaria y ClaveForanea y Pinchó", 0, .oMockInformacionIndividual.Count )
				
				update Diccionario set TipoDato = "A", Longitud = 4 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampovsClaveForanea()
				This.AssertEquals( "PORCHE_TEST y PORSCHE_TEST_SUBENTIDAD estan Mal y no Pinchó", 1, .oMockInformacionIndividual.Count )
				update diccionario set TipoDato = "N", Longitud = 4	where upper( alltrim( entidad ) ) == "PORSCHE_TEST_SUBENTIDAD"
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTablaCampovsClaveForanea()
				This.AssertEquals( "PORCHE_TEST y PORSCHE_TEST_SUBENTIDAD estan bien para su Join de ClavePrimaria y ClaveForanea y Pinchó 2", 0, .oMockInformacionIndividual.Count )

			endif
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
			delete from diccionario where upper( alltrim( entidad ) ) == "PORSCHE_TEST_SUBENTIDAD"			
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestValidarTipoDatoDominio
		local	loRetorno as Object, i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipoDatoDominio()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar Tipo Dato Dominio). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar Tipo Dato Dominio). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				* Tipo de datos inválido
				insert into dominio ( Dominio, tipoDato ) values ( "DOMINIO_PORSCHE_TEST", "H" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST tiene un tipo de datos inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update dominio set TipoDato = "C", Longitud = -1 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'C' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update dominio set TipoDato = "C", Longitud = 260 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'C' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update dominio set TipoDato = "C", Longitud = 60, decimales = 2 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'C', tamaño válido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update dominio set TipoDato = "C", Longitud = 60, decimales = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST esta correcto y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update dominio set TipoDato = "N", Longitud = -1 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'N' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update dominio set TipoDato = "N", Longitud = 260 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'N' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update dominio set TipoDato = "N", Longitud = 15, decimales = -1 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales inválidos y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update dominio set TipoDato = "N", Longitud = 15, decimales = 15 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales inválidos y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update dominio set TipoDato = "N", Longitud = 15, decimales = 5 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales válidos y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update dominio set TipoDato = "N", Longitud = 15, decimales = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales válidos y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update dominio set TipoDato = "D", Longitud = 15 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'D', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update dominio set TipoDato = "D", Longitud = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'D', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update dominio set TipoDato = "D", Longitud = 8, decimales = 1 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'D', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update dominio set TipoDato = "D", Longitud = 8, decimales = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'D', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update dominio set TipoDato = "L", Longitud = 15 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'L', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update dominio set TipoDato = "L", Longitud = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'L', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update dominio set TipoDato = "L", Longitud = 1, decimales = 1 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'L', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update dominio set TipoDato = "L", Longitud = 1, decimales = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'L', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (M) pero tamaño inválido
				update dominio set TipoDato = "M", Longitud = 15 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'M', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (M) pero tamaño inválido
				update dominio set TipoDato = "M", Longitud = 0, decimales = 1 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'M', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update dominio set TipoDato = "M", Longitud = 0, decimales = 0 where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDominio()
				This.AssertEquals( "DOMINIO_PORCHE_TEST Tipo de datos correcto 'M', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )
			endif
			delete from dominio where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarTipoDatoDiccionario
		local i as Integer
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipoDatoDiccionario()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar Tipo Dato Diccionario). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar Tipo Dato Diccionario). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				* Tipo de datos inválido
				insert into dominio ( Dominio, tipoDato ) values ( "DOMINIO_PORSCHE_TEST", "H" )
				insert into diccionario ( Entidad, Atributo, tipoDato, Dominio ) values ( "PORSCHE_TEST", "Motor", "H", "DOMINIO_PORSCHE_TEST" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST tiene un tipo de datos inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )
				
				* Tipo de datos correcto (C) pero tamaño inválido
				update diccionario set TipoDato = "C", Longitud = -1 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'C' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update diccionario set TipoDato = "C", Longitud = 260 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'C' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update diccionario set TipoDato = "C", Longitud = 60, decimales = 2 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'C', tamaño válido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (C) pero tamaño inválido
				update diccionario set TipoDato = "C", Longitud = 60, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST esta correcto y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update diccionario set TipoDato = "N", Longitud = -1 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'N' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update diccionario set TipoDato = "N", Longitud = 260 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'N' pero tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update diccionario set TipoDato = "N", Longitud = 15, decimales = -1 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales inválidos y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update diccionario set TipoDato = "N", Longitud = 15, decimales = 15 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales inválidos y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update diccionario set TipoDato = "N", Longitud = 15, decimales = 5 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales válidos y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (N) pero tamaño inválido
				update diccionario set TipoDato = "N", Longitud = 15, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'N', tamaño válido pero con decimales válidos y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update diccionario set TipoDato = "D", Longitud = 15 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'D', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update diccionario set TipoDato = "D", Longitud = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'D', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update diccionario set TipoDato = "D", Longitud = 8, decimales = 1 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'D', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update diccionario set TipoDato = "D", Longitud = 8, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'D', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update diccionario set TipoDato = "L", Longitud = 15 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'L', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update diccionario set TipoDato = "L", Longitud = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'L', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update diccionario set TipoDato = "L", Longitud = 1, decimales = 1 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'L', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (L) pero tamaño inválido
				update diccionario set TipoDato = "L", Longitud = 1, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'L', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (M) pero tamaño inválido
				update diccionario set TipoDato = "M", Longitud = 15 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'M', tamaño inválido y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (M) pero tamaño inválido
				update diccionario set TipoDato = "M", Longitud = 0, decimales = 1 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'M', tamaño inválido pero con decimales y no Pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (D) pero tamaño inválido
				update diccionario set TipoDato = "M", Longitud = 0, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST"
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'M', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (G) Tamañano ok
				update diccionario set tipoDato = 'G' , Longitud = 38, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST" 
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'G', tamaño inválido sin decimales y Pinchó", 0, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (G) Tamañano mal
				update diccionario set Longitud = 0, decimales = 0 where upper( alltrim( entidad ) ) == "PORSCHE_TEST" 
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'G', tamaño inválido sin decimales y no pinchó", 1, .oMockInformacionIndividual.Count )

				* Tipo de datos correcto (G) Tamañano mal Decimales
				update diccionario set Longitud = 38, decimales = 4 where upper( alltrim( entidad ) ) == "PORSCHE_TEST" 
				.oMockInformacionIndividual.Limpiar()
				.ValidarTipoDatoDiccionario()
				This.AssertEquals( "PORSCHE_TEST Tipo de datos correcto 'G', tamaño inválido con decimales y no pinchó", 1, .oMockInformacionIndividual.Count )



			endif
			delete from diccionario where upper( alltrim( Entidad ) ) == "PORSCHE_TEST"			
			delete from dominio where upper( alltrim( dominio ) ) == "DOMINIO_PORSCHE_TEST"			
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarMascara
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras en el Diccionario 1 " ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato, dominio, mascara ) ;
				values ( "BMW", "pepe","N", "SINDOMINIO", "0.9" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras en el Diccionario 2" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"

			insert into Diccionario ( Entidad, Atributo,tipodato,mascara ) ;
				values ( "BMW", "Nada","N", "9" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras en el Diccionario 3" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "NADA"			

			insert into Diccionario ( Entidad, Atributo, dominio, mascara ) ;
				values ( "BMW", "Nada","CODIGOSOLONUMEROS","" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras Dominio CODIGOSOLONUMEROS en el Diccionario" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "NADA"			

			insert into Diccionario ( Entidad, Atributo, dominio, mascara ) ;
				values ( "BMW", "Nada","CODIGOSOLONUMEROS","9" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras Dominio CODIGOSOLONUMEROS en el Diccionario" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "NADA"			

			insert into Diccionario ( Entidad, Atributo,tipodato, longitud, decimales,mascara ) ;
				values ( "BMW", "pepe","N",7,2, "9,999.99" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de longitud de Máscaras en el Diccionario 1" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"
			
			insert into Diccionario ( Entidad, Atributo,tipodato, longitud, decimales,mascara ) ;
				values ( "BMW", "pepe","N",7,2, "" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de longitud de Máscaras en el Diccionario 2" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"
			
			insert into Diccionario ( Entidad, Atributo,tipodato, longitud, decimales, dominio, mascara ) ;
				values ( "BMW", "pepe","N",7,0, "NUMEROCOMPROBANTE", "X 9999-99999" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( "la validación debe dar OK por NUMEROCOMPROBANTE", 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"

			insert into Diccionario ( Entidad, Atributo,tipodato, longitud, decimales, dominio, mascara ) ;
				values ( "BMW", "pepe","N",7,0, "NUMEROINTERNO", "X999-99999" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( "la validación debe dar OK NUMEROINTERNO", 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"
			

			insert into Diccionario ( Entidad, Atributo,tipodato, dominio, mascara ) ;
				values ( "BMW", "fulano","N", "SINDOMINIO", "999%" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras con el signo '%'" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "FULANO"

			insert into Diccionario ( Entidad, Atributo,tipodato, dominio, mascara ) ;
				values ( "BMW", "fulano","N", "SINDOMINIO", "9%99%" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras con el signo '%' 2 " ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "FULANO"
			

			insert into Diccionario ( Entidad, Atributo,tipodato, dominio, mascara ) ;
				values ( "BMW", "fulano","N", "SINDOMINIO", "9.  99" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Máscaras con espacios intermedios" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "FULANO"

			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Mascara, Dominio ) ;
				values ( "BMW", "pepe", "N", 7, 2, "9,999.99", "NUMERICO" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarMascara()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de longitud de Máscaras en el Diccionario 3" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"

		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function zTestValidarAtributoAjustableEnDetalle
	
		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributoAjustableEnDetalle()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributo Ajustable en Detalle" ), 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad( Entidad, Descripcion, Formulario, Tipo ) values ( "ItemNueva", "Entidad Nueva", .t., "I" )	
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio, Ajustable, alta ) ;
				values ( "ItemNueva", "pepe","N",6,"CODIGO", .f. , .t.)

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributoAjustableEnDetalle()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributo Ajustable en Detalle 2 " ), 1, .oMockInformacionIndividual.Count )

			update diccionario set Alta = .f. where Entidad = "ItemNueva"

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributoAjustableEnDetalle()					

			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributo Ajustable en Detalle 1 bis " ), 0, .oMockInformacionIndividual.Count )


			update diccionario set ajustable = .t. where Entidad = "ItemNueva"

			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributoAjustableEnDetalle()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributo Ajustable en Detalle 3 " ), 0, .oMockInformacionIndividual.Count )

			delete from entidad where upper( alltrim( entidad ) ) = "ITEMNUEVA" 
			delete from diccionario where upper( alltrim( entidad ) ) = "ITEMNUEVA"
		endwith
	

	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function zTestValidarClavePrimariaCompuestaConCamposMemos
	
		local lcEntidad as String
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaCompuestaConCamposMemos()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Clave Primaria Compuesta para Campos Memos" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,claveprimaria) ;
				values ( "BMW", "pepe","M",.t. )
			insert into Diccionario ( Entidad, Atributo,tipodato,claveprimaria) ;
				values ( "BMW", "pepe","N",.t. )				

			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaCompuestaConCamposMemos()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Clave Primaria Compuesta para Campos Memos" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "BMW" and upper( alltrim( atributo ) ) = "PEPE"

			lcEntidad = sys (2015 )	
			insert into Diccionario ( Entidad, Atributo,tipodato,claveprimaria) ;
				values ( lcEntidad , "pepe","M",.t. )
			insert into Diccionario ( Entidad, Atributo,tipodato,claveprimaria) ;
				values ( lcEntidad , "pepe","N",.f. )	
			insert into Diccionario ( Entidad, Atributo,tipodato,claveprimaria) ;
				values ( lcEntidad , "pepe","M",.f. )					

			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaCompuestaConCamposMemos()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Clave Primaria Compuesta para Campos Memos" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = lcEntidad 

		endwith
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function zTestValidarCamposNoMemoEnDetalle
	
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposNoMemoEnDetalle()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos No Memo en Detalle" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Entidad( Entidad, Descripcion, Formulario, Tipo ) values ( "ItemNueva", "Entidad Nueva", .t., "I" )	
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio,Tabla,Campo ) ;
				values ( "ItemNueva", "pepe","M",6,"CODIGO","pp","pp" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposNoMemoEnDetalle()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos No Memo en Detalle" ), 1, .oMockInformacionIndividual.Count )

			update Diccionario set TipoDato = "N" where alltrim( upper( entidad ) ) = "ITEMNUEVA"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposNoMemoEnDetalle()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos No Memo en Detalle" ), 0, .oMockInformacionIndividual.Count )

			delete from entidad where upper( alltrim( entidad ) ) = "ITEMNUEVA" 
			delete from diccionario where upper( alltrim( entidad ) ) = "ITEMNUEVA"

		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function zTestValidarClavesPrimariasNoMemo
	
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavesPrimariasNoMemo()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Claves Primaria No Memo" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,claveprimaria ) ;
				values ( "EntNueva", "pepe","M",.t. )

			.oMockInformacionIndividual.Limpiar()
			.ValidarClavesPrimariasNoMemo()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Claves Primaria No Memo" ), 1, .oMockInformacionIndividual.Count )

			update Diccionario set TipoDato = "N" where alltrim( upper( entidad ) ) = "ENTNUEVA"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavesPrimariasNoMemo()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Claves Primaria No Memo" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "ENTNUEVA"

		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	Function ztestValidarRepeticiondeDetallesEnEntidad	

		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarDetallesRepetidosEnEntidad()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de repeticion de detalles en misma entidad 1" ), 0, .oMockInformacionIndividual.Count )
				 

			insert into Diccionario ( Entidad, Atributo, dominio ) ;
				values ( "EntNueva", "pepe", "DETALLEITEMEERROR")
				
			insert into Diccionario ( Entidad, Atributo, dominio ) ;
				values ( "EntNueva", "pepe2", "DETALLEITEMEERROR")				

			.oMockInformacionIndividual.Limpiar()
			.ValidarDetallesRepetidosEnEntidad()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de repeticion de detalles en misma entidad 2" ), 1, .oMockInformacionIndividual.Count )

			update diccionario set dominio = "DETALLEITEMPEPE" where alltrim( upper( atributo ) ) == "PEPE2" 

				
			.oMockInformacionIndividual.Limpiar()
			.ValidarDetallesRepetidosEnEntidad()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de repeticion de detalles en misma entidad 3" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "ENTNUEVA"

		endwith
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarNomenclaturaDeItems
			
		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarNomenclaturaDeItems()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Nomenclatura de Items" ), 0, .oMockInformacionIndividual.Count )

			insert into Entidad( Entidad, Descripcion, Formulario, Tipo ) values ( "ItemNueva", "Entidad Nueva", .t., "I" )	
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "ValorDetalle","C",30,"CODIGO" )			

			.oMockInformacionIndividual.Limpiar()
			.ValidarNomenclaturaDeItems()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Nomenclatura de Items 2" ), 1, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,"CODIGO" )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarNomenclaturaDeItems()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Nomenclatura de Items 3" ), 0, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( entidad ) ) = "ITEMNUEVA"
			delete from entidad where upper( alltrim( entidad ) ) = "ITEMNUEVA" 

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function zTestValidarCantidadDeAtributosPorBloque
		local lcDominio as String
		
		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad De Atributos por Bloque" ), 0, .oMockInformacionIndividual.Count )
			
			*Test para el dominio CLAVECANDIDATA
			lcDominio = "CLAVECANDIDATA"
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )	
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "ValorDetalle","C",30,lcDominio )			

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad De Atributos por Bloque 2" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "ValorDetalle2","C",30,lcDominio )		
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad De Atributos por Bloque 3" ), 0, .oMockInformacionIndividual.Count )
				
			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio				
			
			*Test para el dominio CODIGOCLIENTECOMPROBANTE	
			lcDominio = "CODIGOCLIENTECOMPROBANTE"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 4" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 5" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor3","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 6" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio
			

			*Test para el dominio DESCUENTO	
			lcDominio = "DESCUENTO"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 7" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 8" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor3","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 9" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio			
			
			*Test para el dominio TIPOIVA	
			lcDominio = "TIPOIVA"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 10" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 11" ), 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor3","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 12" ), 1, .oMockInformacionIndividual.Count )

			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio			
			
			*Test para el dominio NUMEROCOMPROBANTE	
			lcDominio = "NUMEROCOMPROBANTE"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 13" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 14" ), 1, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor3","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 15" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor4","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 16" ), 1, .oMockInformacionIndividual.Count )				

			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio	
			
			*Test para el dominio NUMEROINTERNO
			lcDominio = "NUMEROINTERNO"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque NUMEROINTERNO 1" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque NUMEROINTERNO 2" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor4","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque NUMEROINTERNO 3" ), 1, .oMockInformacionIndividual.Count )				

			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio	
			
			*Test para el dominio NUMEROCOMPROBANTESINSUGERIR	
			lcDominio = "NUMEROCOMPROBANTESINSUGERIR"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 17" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 18" ), 1, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor3","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 19" ), 0, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor4","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 20" ), 1, .oMockInformacionIndividual.Count )				

			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio		
			
			*Test para el dominio DIRECCION	
			lcDominio = "DIRECCION"	
			
			insert into Dominio( Dominio, EsBloque ) values ( lcDominio, .t. )				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor","C",30,lcDominio )			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 21" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor2","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 22" ), 1, .oMockInformacionIndividual.Count )

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor3","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 23" ), 1, .oMockInformacionIndividual.Count )
				
			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor4","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 24" ), 0, .oMockInformacionIndividual.Count )				

			insert into Diccionario ( Entidad, Atributo,tipodato,longitud,Dominio ) ;
				values ( "ItemNueva", "Valor5","C",30,lcDominio )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAtributosPorBloque()					
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Cantidad de Atributos por Bloque 25" ), 1, .oMockInformacionIndividual.Count )	
				
			delete from diccionario where upper( alltrim( dominio ) ) = lcDominio
			delete from dominio where upper( alltrim( dominio ) ) = lcDominio
						
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarSubEntidadConUnaSolaClavePrimaria

		local lcCursor as String
		lcCursor = sys(2015)
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarSubEntidadConUnaSolaClavePrimaria()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de subEntidades con una sola clave primaria" ), 0, .oMockInformacionIndividual.Count )
			
			select distinct entidad from diccionario where claveprimaria and atc("ITEM", entidad) = 0;
			 and entidad in (select distinct(claveForanea) from diccionario where !empty(claveforanea)) into cursor (lcCursor)
			if _tally > 0
				insert into Diccionario ( Entidad, Atributo,claveprimaria ) ;
					values ( &lcCursor..entidad, "ATBNuevo" , .T.)			

				.oMockInformacionIndividual.Limpiar()
				.ValidarSubEntidadConUnaSolaClavePrimaria()					
				This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
					"Falló Validación de subEntidades con una sola clave primaria 2" ), 1, .oMockInformacionIndividual.Count )

				delete from diccionario where entidad = &lcCursor..entidad and atributo = "ATBNuevo"		
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarCantidadMinimaDeAtributosPorBloque()					
				This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
					"Falló Validación de subEntidades con una sola clave primaria 3" ), 0, .oMockInformacionIndividual.Count )
			endif 
		endwith

		use in select( lcCursor )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestValidarAdmiteBusquedaEnAtributoDetalle
	
		local lcDominio As String
		lcDominio = upper( sys(2015) )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdmiteBusquedaEnAtributoDetalle()				
			This.AssertEquals( "No se ha validado el admite busqueda en atributos detalle", 0, .oMockInformacionIndividual.Count )


			insert into Dominio( Dominio, Detalle ) values ( lcDominio, .T. )
			insert into Entidad( Entidad, Formulario, Tipo ) values ( lcDominio, .T., "E" )
			insert into Diccionario ( Entidad, Atributo,Dominio, AdmiteBusqueda ) values ;
				( lcDominio, "ATRIBUTO1", lcDominio, 1 )
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdmiteBusquedaEnAtributoDetalle()				
			This.AssertEquals( "No se ha validado el admite busqueda en atributos detalle 2 ", 1, .oMockInformacionIndividual.Count )
			
			delete from Diccionario where upper( alltrim( Entidad ) ) = lcDominio
			delete from Entidad where upper( alltrim( Entidad ) ) = lcDominio
			delete from Dominio where upper( alltrim( dominio ) ) = lcDominio
			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarSeguridadEnEntidades
		local i as integer
		
		for i = 1 to 4
			insert into seguridadentidades ;
				( entidad, operacion, descripcionoperacion ) ; 
				values ;
				( 'ZTESTLOACA', 'Operacion loaca'+ transform( i, '@lz 99' ), 'Operacion loaca'+ transform( i, '@lz 99' ))
				
		endfor 
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarSeguridadEnEntidades()
			This.AssertEquals( 'No se debe permitir cargar nombrs de metodos con espacios', 1, .oMockInformacionIndividual.Count )

			select seguridadentidades
			replace all operacion with strtran( " ", operacion, "" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarSeguridadEnEntidades()
			This.AssertEquals( 'Los nombres de metodos no deben tener espacios', 0, .oMockInformacionIndividual.Count )
			
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoEntidadVacioEnMenuAltasItems

		select menualtasitems
		append blank
		replace all entidad with "Prueba"
		
		with This.oValidarAdn
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoEntidadVacioEnMenuAltasItems()
			This.AssertEquals( "La validación debe estar ok.", 0, .oMockInformacionIndividual.Count )
		
			select menualtasitems
			go top
			replace entidad with ""
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoEntidadVacioEnMenuAltasItems()
			This.AssertEquals( "La validación debe ser falsa.", 1, .oMockInformacionIndividual.Count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarEntidadesConMismaVersionEntidadVsEntidad

		with This.oValidarADN

			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "No se ha validado la Unicidad Version de Entidades.", 0, .oMockInformacionIndividual.Count )


			insert into Entidad ( Entidad, tipo , VERSION ) values ( "DACIA", "E"  ,1 )
			insert into Entidad ( Entidad, tipo , VERSION ) values ( "MINI", "E" ,1 )
			insert into Entidad ( Entidad, tipo , VERSION ) values ( "MINIV2", "E" ,2 )

			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "DACIA", "Codigo", "" )
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "DACIA", "Descripcion", "" )			
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "DACIA", "Partes", "MINI" )						


			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "Se ha validado incorrectamente la Unicidad de Versión entre entidades cuando no debería.", 0, .oMockInformacionIndividual.Count )

			zap in ENTIDAD
			zap in DICCIONARIO

			insert into Entidad ( Entidad, tipo, VERSION ) values ( "DACIA", "E" , 1 )
			insert into Entidad ( Entidad, tipo, VERSION ) values ( "MINI", "E" , 2 )
			insert into Entidad ( Entidad, tipo, VERSION ) values ( "MINIV2", "E" , 1 )

			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "DACIA", "Codigo", "" )
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "DACIA", "Descripcion", "" )			
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "DACIA", "Partes", "MINI" )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "Se ha validado correctamente la Unicidad de Versión entre entidades cuando no debería.", 1, .oMockInformacionIndividual.Count )

		endwith
		
		
	*-----------------------------------------------------------------------------------------
	function zTestValidarEntidadesConMismaVersionEntidadVsDetalle

		with This.oValidarADN

			insert into Entidad ( Entidad, tipo , VERSION ) values ( "DACIA", "E" , 1 )
			insert into Entidad ( Entidad, tipo , VERSION ) values ( "DACIAV2", "E" , 2 )			
			insert into Entidad ( Entidad, tipo ,  VERSION ) values ( "ITEMDACIA", "I" , 1 )

			insert into diccionario ( Entidad, Atributo, Dominio ) values ( "DACIA", "Codigo", "" )
			insert into diccionario ( Entidad, Atributo, Dominio ) values ( "DACIA", "Descripcion", "" )			
			insert into diccionario ( Entidad, Atributo, Dominio ) values ( "DACIA", "DACIADETALLE", "DETALLEITEMDACIA" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "Se ha validado incorrectamente la Unicidad  de version entre Entidades y Detalles cuando no debería.", 0, .oMockInformacionIndividual.Count )


			zap in ENTIDAD
			zap in DICCIONARIO

			insert into Entidad ( Entidad, tipo , VERSION ) values ( "DACIA", "E" , 1 )
			insert into Entidad ( Entidad, tipo , VERSION ) values ( "DACIAV2", "E" , 2 )			
			insert into Entidad ( Entidad, tipo , VERSION ) values ( "ITEMDACIA", "I" , 2 )

			insert into diccionario ( Entidad, Atributo, Dominio ) values ( "DACIA", "Codigo", "" )
			insert into diccionario ( Entidad, Atributo, Dominio ) values ( "DACIA", "Descripcion", "" )			
			insert into diccionario ( Entidad, Atributo, Dominio ) values ( "DACIA", "DACIADETALLE", "DETALLEITEMDACIA" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "Se ha validado correctamente la Unicidad  de version entre Entidades y Detalles cuando no debería.", 1, .oMockInformacionIndividual.Count )

		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarEntidadesConMismaVersionDetalleConSub_Entidad

		with This.oValidarADN

			insert into Entidad ( Entidad, tipo , VERSION ) values ( "ITEMDACIA", "I" ,2 )
			insert into Entidad ( Entidad, tipo , VERSION ) values ( "DACIA", "E" ,2 )

			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "ITEMDACIA", "Codigo", "" )
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "ITEMDACIA", "Descripcion", "" )			
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "ITEMDACIA", "Dacia", "Dacia" )						

			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "Se ha validado incorrectamente la Unicidad  de version entre Entidades y Detalles cuando debería.", 0, .oMockInformacionIndividual.Count )
	
			zap in ENTIDAD
			zap in DICCIONARIO

			insert into Entidad ( Entidad, tipo , VERSION ) values ( "ITEMDACIA", "I" ,2 )
			insert into Entidad ( Entidad, tipo ,VERSION ) values ( "DACIAV2", "E" ,2 )
			insert into Entidad ( Entidad, tipo ,VERSION ) values ( "DACIA", "E" ,1 )

			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "ITEMDACIA", "Codigo", "" )
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "ITEMDACIA", "Descripcion", "" )			
			insert into diccionario ( Entidad, Atributo, ClaveForanea ) values ( "ITEMDACIA", "Dacia", "Dacia" )						

			.oMockInformacionIndividual.Limpiar()			
			.ValidarUnicidadDeVersionDeEntidades()
			This.AssertEquals( "Se ha validado correctamente la Unicidad  de version entre Entidades y Detalles cuando no debería.", 1, .oMockInformacionIndividual.Count )

		endwith

	endfunc

	*-----------------------------------	
	function zTestValidarDominioImagenConRutaDinamica
		local lcMensaje as string, loObjeto as object

	
		*Validamos que se ejecute el metodo ValidarDominioImagen al ejecutar la validacion
		loObjeto = newobject( "ObjetoBindeo" )
		bindevent( This.oValidarADN, "ValidarDominioImagen", loObjeto, "ValidarDominioImagen", 1 )
		
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.Validar()
			This.AssertTrue( "No se ejecutó ValidarDominioImagen", loObjeto.lEjecutoValidarDominioImagen )

			loObjeto.destroy()

			*Verificamos buen funcionamiento de ValidarDominioImagen
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioImagen()
			This.AssertEquals( "No se ha validado la el dominio IMAGEN (1). ValidarDominioImagen", 0, .oMockInformacionIndividual.Count )

			insert into diccionario ( Entidad, Atributo, Dominio, AdmiteBusqueda ) ;
				values ( "ENTPRUEBA", "AIMAGEN", "IMAGENCONRUTADINAMICA", 1 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioImagen()
			This.AssertEquals( "No se ha validado la el dominio IMAGEN (2). ValidarDominioImagen", 0, .oMockInformacionIndividual.Count )
			
			update diccionario set AdmiteBusqueda = 0 ;
				where	alltrim( upper( entidad ) ) == "ENTPRUEBA" and ;
						alltrim( upper( atributo ) ) == "AIMAGEN"

			lcMensaje = "El atributo AIMAGEN de la entidad ENTPRUEBA tiene dominio IMAGENCONRUTADINAMICA " + ;
					"y no tiene cargado el campo Admite Busqueda"

			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioImagen()
			This.AssertEquals( "No se ha validado la el dominio IMAGENCONRUTADINAMICA (3). ValidarDominioImagen", 1, .oMockInformacionIndividual.Count )
			This.assertEquals( "Error en el mensaje. ValidarDominioImagen", lcMensaje, .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		EndWith		
	endfunc
	*-----------------------------------	
	function zTestValidarDominioImagen
		local lcMensaje as string
		with This.oValidarADN			
			insert into diccionario ( Entidad, Atributo, Dominio, AdmiteBusqueda ) ;
				values ( "ENTPRUEBA", "AIMAGEN", "IMAGEN", 1 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioImagen()
			This.AssertEquals( "No se ha validado la el dominio IMAGEN (2). ValidarDominioImagen", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "El atributo AIMAGEN de la entidad ENTPRUEBA tiene dominio IMAGEN" + ;
					" y este fue reemplazado por IMAGENCONRUTADINAMICA."

			This.assertEquals( "Error en el mensaje. ValidarDominioImagen", lcMensaje, .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		EndWith		
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarDetallesNormalizadosV2
		local loValidarADN as validarADN of validarADN.prg

		loValidarADN = newobject( "ValidarADNAux", "zTestValidarADN.prg", "", _Screen.zoo.cRutaInicial )	
		with loValidarADN

			insert into Diccionario ( Entidad, Atributo, dominio, tabla ) ;
				values ( "EntNueva", "pepe", "DETALLEITEMEERROR", "miTabla")
				
			insert into Diccionario ( Entidad, Atributo, ClavePrimaria, tabla ) ;
				values ( "EntNueva", "ClavePrimaria", .t., "miTabla")				

			insert into Entidad ( Entidad ) ;
				values ( "EntNueva" )				

			insert into Dominio ( Dominio, Detalle ) ;
				values ( "DETALLEITEMEERROR", .t. )				

			.oMockInformacionIndividual.Limpiar()
			.ValidarDetallesNormalizadosV2Aux()
			This.AssertEquals( "Fallo la validacion de detalles normalizados para ent V1", 0, .oMockInformacionIndividual.Count )

			update Entidad set version = 2 where Entidad == "EntNueva"

			.oMockInformacionIndividual.Limpiar()
			.ValidarDetallesNormalizadosV2Aux()
			This.AssertEquals( "No fallo la validacion de detalles normalizados para ent V2", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "No fallo la validacion de detalles normalizados para ent V2", ;
				"la entidad: entnueva, no tiene normalizado el atributo detalle: pepe.", ;
				lower( .oMockInformacionIndividual.Item[1].cMensaje ) )

			update Diccionario set tabla = "miTabl" where atributo = "pepe"

			.oMockInformacionIndividual.Limpiar()
			.ValidarDetallesNormalizadosV2Aux()
			This.AssertEquals( "Fallo la validacion de detalles normalizados para ent V2", 0, .oMockInformacionIndividual.Count )
		endwith
		loValidarADN.release()
		loValidarADN = null
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarIntegridadNodosDeParametros
		with This.oValidarADN		
			insert into parametros ( idNodo, parametro ) ;
				values( 1, "parametro 1 de 1" )

			insert into JerarquiaParametros ( Nodo, nombre ) ;
				values( 1, "Nodo 1" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarIntegridadNodosDeParametros()
			
			This.AssertEquals( "La validación debe ser OK", 0, .oMockInformacionIndividual.Count )
			
			insert into parametros ( idNodo, parametro ) ;
				values( 10, "parametro 1 de 10" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarIntegridadNodosDeParametros()
			
			This.AssertEquals( "La validación debe ser erronea", 1, .oMockInformacionIndividual.Count )
			this.assertequals( "La cantidad de errores es incorrecta", 1, .oMockInformacionIndividual.Count )
			this.assertequals( "El mensaje de error es incorrecto", ;
					'EL PARÁMETRO "PARAMETRO 1 DE 10" ESTA ASOCIADO AL NODO "10" INEXISTENTE.', ;
					alltrim( upper( .oMockInformacionIndividual.item[ 1 ].cMensaje )))
			
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposTablaDeParametros

		insert into parametros ( idNodo, parametro ) values( 1, "parametro 1 de 1" )
		with This.oValidarAdn
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposTablaDeParametros()
			This.AssertEquals( "Deberia haber dado error", 1, .oMockInformacionIndividual.Count )
			
			update parametros set paramint = "Parametro1de1", paramusu = "Parametro1de1" where ;
				idNodo = 1 and alltrim( upper( parametro ) ) = "PARAMETRO 1 DE 1"
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposTablaDeParametros()
			This.AssertEquals( "No deberia haber dado error", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 


	*-----------------------------------	
	function zTestValidarEspacios
	
		local loRetorno as Object
		
		with This.oValidarADN
		
			* --- Verificar que el diccionario tiene datos
			.oMockInformacionIndividual.Limpiar()
			.ValidarEspacios()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos Vacíos en Diccionario" ), 0, .oMockInformacionIndividual.Count )
				
			* --- Entidad
			insert into Entidad ( Entidad ) values ( "EL SALVADOR " )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEspacios()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Espacios en Blanco en Nombre de la Entidad en la tabla entidad" ), 1, .oMockInformacionIndividual.Count )

    		insert into Diccionario ( Entidad, Atributo ) values ( "EL SALVADOR ", "Atributo" )
    		.oMockInformacionIndividual.Limpiar()
			.ValidarEspacios()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Espacios en Blanco en Nombre de la Entidad en la tabla diccionario" ), 2, .oMockInformacionIndividual.Count )
			
			delete from diccionario where alltrim( upper( Entidad ) ) = "EL SALVADOR "
			delete from Entidad where alltrim( upper( Entidad ) ) = "EL SALVADOR "

			* ----	atributo 
			insert into Entidad ( Entidad ) values ( "ELSALVADOR" )
			insert into Diccionario ( Entidad, Atributo ) values ( "ELSALVADOR", "Mi Atributo" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarEspacios()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Espacios en Blanco en Nombre del atributo" ), 1, .oMockInformacionIndividual.Count )
			
			delete from diccionario where alltrim( upper( Entidad ) ) = "ELSALVADOR"
			
			* ----	campo			
			insert into Diccionario ( Entidad, Campo ) values ( "ELSALVADOR", "Mi Campo" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEspacios()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Espacios en Blanco en Nombre del campo" ), 1, .oMockInformacionIndividual.Count )
			
			delete from diccionario where alltrim( upper( Entidad ) ) = "ELSALVADOR"
			
			* ----	tabla
			insert into Diccionario ( Entidad, Tabla ) values ( "ELSALVADOR", "Mi Tabla" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEspacios()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Espacios en Blanco en Nombre de la Tabla" ), 1, .oMockInformacionIndividual.Count )
	
		endwith
	endfunc


	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposObligatoriosEnDetalle

		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposObligatoriosEnDetalle()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Detalles en Diccionario" ), 0, .oMockInformacionIndividual.Count )
		
    		insert into Diccionario ( Entidad, Obligatorio ) values ( "ITEMPERU", .f. )
    		
    		.oMockInformacionIndividual.Limpiar()
    		.ValidarCamposObligatoriosEnDetalle()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Detalles en Diccionario" ), 1, .oMockInformacionIndividual.Count )
				
			update diccionario set obligatorio = .T.
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposObligatoriosEnDetalle()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Detalles en Diccionario" ), 0, .oMockInformacionIndividual.Count )
    		
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoMemoEnBusqueda
		
		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoMemoEnBusqueda()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos Memo en Diccionario 1" ), 0, .oMockInformacionIndividual.Count )
		
			insert into Diccionario ( Entidad, atributo, tipodato,admitebusqueda ) values ( "cuba", 'observacion','M', 1 )

    		.oMockInformacionIndividual.Limpiar()
    		.ValidarCampoMemoEnBusqueda()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos Memo en Diccionario 2" ), 1, .oMockInformacionIndividual.Count )
				
			update diccionario set AdmiteBusqueda = 0 where alltrim( upper( entidad ) ) = 'CUBA' and alltrim( upper( atributo ) ) = 'OBSERVACION'
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoMemoEnBusqueda()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos Memo en Diccionario 3" ), 0, .oMockInformacionIndividual.Count )
			
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposDuplicadosEnMismaTabla

		local lcEntidad as String
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosEnMismaTabla()
			This.AssertEquals( "No se ha validado la Unicidad de campos para la misma tabla 1", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( tabla, campo, tipodato, longitud ) values ( "CUBA", "HABITANTES", "C", 3 )
			insert into Diccionario ( tabla, campo, tipodato, longitud ) values ( "CUBA", "HABITANTES", "C", 6 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosEnMismaTabla()
			
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
							"Falló Validación de campos duplicados." ), 1, .oMockInformacionIndividual.Count )
							
			***** CASO 1 *****
			insert into Diccionario ( tabla, campo, tipodato, longitud ) values ( "CuBA", "HABITANTES", "C", 3 )
			insert into Diccionario ( tabla, campo, tipodato, longitud ) values ( "CUBA", "HAbITANTES", "c", 6 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosEnMismaTabla()
			
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
							"Falló Validación de campos duplicados." ), 1, .oMockInformacionIndividual.Count )										

		EndWith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarOrdenReglaDeNegocio

		local lcEntidad as String
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenReglaDeNegocio()
			This.AssertEquals( "No se ha validado el orden regla de negocio para la misma tabla 1", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario ( tabla, campo, OrdenReglaNegocio ) values ( "CUBA", "HABITANTES", -1 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenReglaDeNegocio()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
							"Falló Validación de rden regla de negocio." ), 1, .oMockInformacionIndividual.Count )

		EndWith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarClavePrimariayForaneaEnAtributosDeDetalles

		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariayForaneaEnAtributosDeDetalles()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos Vacíos en Diccionario." ), 0, .oMockInformacionIndividual.Count )
		
			insert into Entidad ( Entidad, tipo ) values ( "ELSALVADOR", "I" )

    		insert into Diccionario ( Entidad, Atributo, ClavePrimaria, ClaveForanea ) values ( "ELSALVADOR", "Atributo1", .T. , "Entidad1" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariayForaneaEnAtributosDeDetalles()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Claves Primaria y Foránea en Atributos de Detalles, en la tabla Diccionario." ), 1, .oMockInformacionIndividual.Count )

			go 1 in Entidad
			replace tipo with "E" in Entidad 
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariayForaneaEnAtributosDeDetalles()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"La validación debería ser correcta porque la entidad no es un detalle." ), 0, .oMockInformacionIndividual.Count )
			
			go 1 in Diccionario 
			replace tipo with "I" in Entidad 
			
			replace ClavePrimaria with .f. in Diccionario 

			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariayForaneaEnAtributosDeDetalles()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"La validación debería ser correcta porque el atributo no tiene clave primaria." ), 0, .oMockInformacionIndividual.Count )
				
			go 1 in Diccionario 
			replace ClavePrimaria	with .t. , ClaveForanea	with "" in Diccionario 

			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariayForaneaEnAtributosDeDetalles()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"La validación debería ser correcta porque el atributo no tiene clave foránea." ), 0, .oMockInformacionIndividual.Count )

		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoObligatorioEnAtributoDetalle
	
	with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoObligatorioEnAtributoDetalle()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Atributos Vacíos en Diccionario." ), 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad ( Entidad, tipo ) values ( "ELSALVADOR" , "E")
			insert into Dominio ( dominio, detalle ) values ( "DetalleDePrueba" , .t.)
			insert into Diccionario ( Entidad, Atributo, Obligatorio, dominio ) values ( "ELSALVADOR", "ItemAtributo1", .f., "DETALLEDEPRUEBA" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoObligatorioEnAtributoDetalle()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de Campos obligatorios en Atributos Detalle." ), 0, .oMockInformacionIndividual.Count )

			replace all obligatorio with .t. in Diccionario
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoObligatorioEnAtributoDetalle()
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"NO falló Validación de Campos obligatorios en Atributos Detalle." ), 1, .oMockInformacionIndividual.Count )			
	endwith
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios
		local i as Integer, lcEntidad as String, lnId as Integer
		lcEntidad = ''
		
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo versus Clave Foranea). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo versus Clave Foranea). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				**** Creamos PAIS_PRI_TEST como entidad Primaria, ;
							 PAIS_SEC_TEST como entidad con atributos foraneos de PAIS_PRI_TEST e ;
							 ITEMPAIS_PRI_TEST como Item de PAIS_PRI_TEST. ;
						La idea es que tienen que coincidir el tipo de dato, longitud y decimales entre la entidad primariade ambos.
				insert into entidad ( entidad ) values ( "PAIS_PRI_TEST" )
				insert into entidad ( entidad ) values ( "PAIS_SEC_TEST" )
				insert into entidad ( entidad ) values ( "ITEMPAIS_PRI_TEST" )
				insert into diccionario ( entidad, atributo, tipoDato, longitud, decimales ) values ( "PAIS_PRI_TEST", "Descripcion", "C", 20, 0 )

				for lnId = 1 to 3
					do case
						case lnId = 1
							*** Testeamos el ATRIBUTOFORANEO con un atributo de la misma entidad que tiene como ClaveForanea a otra entidad.
							insert into diccionario ( entidad, atributo, tipoDato, longitud, decimales, ClaveForanea ) values ;
										( "PAIS_SEC_TEST", "PaisPRI", "C", 20, 0, "PAIS_PRI_TEST" )
							insert into diccionario ( entidad, atributo, tipoDato, longitud, decimales, AtributoForaneo ) values ;
										( "PAIS_SEC_TEST", "DescModelo", "C", 20, 0, "PaisPRI.Descripcion" )
							lcEntidad = "PAIS_SEC_TEST"
							lcAtributo = "DESCMODELO"
							
						case lnId = 2
							*** Testeamos el ATRIBUTOFORANEO con otra entidad
							delete from diccionario where upper( alltrim( entidad ) ) == "PAIS_SEC_TEST" and upper( alltrim( atributo ) ) == "PAISPRI"
							update diccionario set AtributoForaneo = "PAIS_PRI_TEST.Descripcion", TipoDato = "C", Longitud = 20, Decimales = 0 ;
								where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo

							** Este caso no esta (ni estaba) soportado
							loop
						case lnId = 3
							*** Testeamos con la nomenclatura del Atributo perteneciente a un ITEM
							delete from diccionario where upper( alltrim( entidad ) ) == "PAIS_SEC_TEST"
							insert into diccionario ( entidad, atributo, tipoDato, longitud, decimales, AtributoForaneo, claveforanea ) values ;
										( "ITEMPAIS_PRI_TEST", "PAIS_PRI_TEST", "C", 20, 0, "", "PAIS_PRI_TEST" )
							insert into diccionario ( entidad, atributo, tipoDato, longitud, decimales, AtributoForaneo ) values ;
										( "ITEMPAIS_PRI_TEST", "PAIS_PRI_TESTDETALLE", "C", 20, 0, "PAIS_PRI_TEST.Descripcion" )
							lcEntidad = "ITEMPAIS_PRI_TEST"
							lcAtributo = "PAIS_PRI_TESTDETALLE"
					endcase

					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen los mismos tipos de datos, longitudes y decimales, y no lo validó OK", 0, .oMockInformacionIndividual.Count )
		
					update diccionario set TipoDato = "N" where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen diferentes tipos de datos, y lo validó ok", 1, .oMockInformacionIndividual.Count )

					update diccionario set TipoDato = "C", Longitud = 10 where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen diferentes longitudes, y lo validó ok", 1, .oMockInformacionIndividual.Count )

					update diccionario set Longitud = 20, Decimales = 1 where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen diferentes decimales, y lo validó ok", 1, .oMockInformacionIndividual.Count )

					update diccionario set TipoDato = "N", Longitud = 20 where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen diferentes tipos de datos y decimales, y lo validó ok", 1, .oMockInformacionIndividual.Count )

					update diccionario set TipoDato = "N", Longitud = 10, Decimales = 0 where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen diferentes tipos de datos y longitudes, y lo validó ok", 1, .oMockInformacionIndividual.Count )

					update diccionario set TipoDato = "C", Decimales = 1 where upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
					.oMockInformacionIndividual.Limpiar()
					.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
					This.AssertEquals( "PAIS_PRI_TEST y " + lcEntidad + " " + alltrim( str( lnId ) ) + " tienen diferentes longitudes y decimales, y lo validó ok", 1, .oMockInformacionIndividual.Count )
				endfor

			endif
			delete from diccionario where upper( alltrim( entidad ) ) == "PAIS_PRI_TEST"
			delete from diccionario where upper( alltrim( entidad ) ) == "PAIS_SEC_TEST"
			delete from diccionario where upper( alltrim( entidad ) ) == "ITEMPAIS_PRI_TEST"			
			delete from entidad where upper( alltrim( entidad ) ) == "PAIS_PRI_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "PAIS_SEC_TEST"
			delete from entidad where upper( alltrim( entidad ) ) == "ITEMPAIS_PRI_TEST"			

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarUnicidadEnRelaNumeraciones
		local i as Integer, lcEntidad as String, lnId as Integer, loInformacion as Object, llValidacion as Boolean
		lcEntidad = ''

		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarUnicidadEnRelaNumeraciones()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Unicidad de RelaNumeraciones). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo versus Clave Foranea). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				insert into Dominio ( dominio ) values ( "NUMERICO" )

				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud ) values ( "PAIS_TEST", "Numero", "NUMERICO", "1", "N", 1 )
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud ) values ( "PAIS_TEST", "Otro", "NUMERICO", "2", "N", 2 )
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud ) values ( "PROVINCIA_TEST", "Numero", "NUMERICO", "3", "N", 3 )
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud ) values ( "PROVINCIA_TEST", "Otro", "NUMERICO", "4", "N", 4 )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PAIS_TEST", "Numero" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarUnicidadEnRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser correcta. (1)", 0, .oMockInformacionIndividual.Count )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PAIS_TEST", "Otro" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarUnicidadEnRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser correcta. (2)", 0, .oMockInformacionIndividual.Count )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PROVINCIA_TEST", "Numero" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarUnicidadEnRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser correcta. (3)", 0, .oMockInformacionIndividual.Count )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PROVINCIA_TEST", "Otro" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarUnicidadEnRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser correcta. (4)", 0, .oMockInformacionIndividual.Count )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PAIS_TEST", "Otro" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarUnicidadEnRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser incorrecta. (5)", 1, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (5)", 1, .oMockInformacionIndividual.count )
				This.assertEquals( "El mensaje de error es incorrecto. (5)", 'Entidad "PAIS_TEST" - Atributo "OTRO" ya fueron cargados en RelaNumeraciones', .oMockInformacionIndividual.Item[ 1 ].cMensaje )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PROVINCIA_TEST", "Numero" )
				.oMockInformacionIndividual.Limpiar()
				.ValidarUnicidadEnRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser incorrecta. (6)", 2, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (6)", 2, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje 1 de error es incorrecto. (6)", 'Entidad "PAIS_TEST" - Atributo "OTRO" ya fueron cargados en RelaNumeraciones', .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (6)", 'Entidad "PROVINCIA_TEST" - Atributo "NUMERO" ya fueron cargados en RelaNumeraciones', .oMockInformacionIndividual.Item[ 2 ].cMensaje )

				llValidacion = .Validar()
				loInformacion = .ObtenerInformacion()

				This.AssertTrue( "La validacion debe ser incorrecta. (7)", !llValidacion )
				This.assertEquals( "La cantidad de mensajes principales es incorrecta. (7)", 6, loInformacion.count )
				This.assertEquals( "El mensaje de error principal es incorrecto. (7)", ;
					'Falló Validación de Unicidad de Numeraciones', loInformacion.Item[ 3 ].cMensaje )
				This.assertEquals( "El mensaje 1 de error es incorrecto. (7)", 'Entidad "PAIS_TEST" - Atributo "OTRO" ya fueron cargados en RelaNumeraciones', ;
					alltrim( loInformacion.Item[ 1 ].cMensaje ) )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (7)", 'Entidad "PROVINCIA_TEST" - Atributo "NUMERO" ya fueron cargados en RelaNumeraciones', ;
					alltrim( loInformacion.Item[ 2 ].cMensaje ) )
			endif

			delete from relanumeraciones where upper( alltrim( entidad ) ) == "PAIS_TEST"
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarRelaNumeraciones
		local llRetorno as Boolean, i as Integer, lcEntidad as String, lnId as Integer, loInformacion as Object

		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarRelaNumeraciones()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de RelaNumeraciones 1" ), 0, .oMockInformacionIndividual.Count )
		
			insert into RelaNumeraciones ( Entidad, atributo ) values ( "cuba", 'observacion' )
			insert into Diccionario ( Entidad, atributo, tipodato ) values ( "cuba", 'observacion','C' )

    		.oMockInformacionIndividual.Limpiar()
    		.ValidarRelaNumeraciones()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de RelaNumeraciones 2" ), 1, .oMockInformacionIndividual.Count )
			
			update diccionario set TipoDato = "N" where alltrim( upper( entidad ) ) = 'CUBA' and alltrim( upper( atributo ) ) = 'OBSERVACION'
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarRelaNumeraciones()				
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló Validación de RelaNumeraciones 3" ), 0, .oMockInformacionIndividual.Count )
			
		endwith

		lcEntidad = ''
		
		delete from RelaNumeraciones 
		delete from diccionario 
		
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarRelaNumeraciones()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Unicidad de RelaNumeraciones). Verifique ADN", 0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Tabla Campo versus Clave Foranea). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				insert into Dominio ( dominio ) values ( "NUMERICO" )
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud ) values ( "PAIS_TEST", "Numero", "NUMERICO", "1", "N", 1 )
				insert into RelaNumeraciones ( entidad, atributo ) values ( "PAIS_TEST", "Numero" )
				
				.ValidarRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser correcta. (1)", 0, .oMockInformacionIndividual.Count )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PAIS_TEST", "Otro" )
				
				.ValidarRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser incorrecta. (2)", 1, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (2)", 1, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje de error es incorrecto. (2)", 'Entidad "PAIS_TEST" - Atributo "OTRO"  de ' + ;
									'RelaNumeraciones no existen en el Diccionario', .oMockInformacionIndividual.Item[ 1 ].cMensaje )

				insert into RelaNumeraciones ( entidad, atributo ) values ( "PROVINCIA_TEST", "Numero" )
				
				.ValidarRelaNumeraciones()
				This.AssertEquals( "La validacion debe ser incorrecta. (3)", 3, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (3)", 3, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje 1 de error es incorrecto. (3)", 'Entidad "PAIS_TEST" - Atributo "OTRO"  de ' + ;
									'RelaNumeraciones no existen en el Diccionario', .oMockInformacionIndividual.Item[ 1 ].cMensaje )

				This.assertEquals( "El mensaje 2 de error es incorrecto. (3)", 'Entidad "PROVINCIA_TEST" - Atributo "NUMERO"  ' + ;
									'de RelaNumeraciones no existen en el Diccionario', .oMockInformacionIndividual.Item[ 3 ].cMensaje )

				llRetorno = This.oValidarADN.Validar()
				loInformacion = .ObtenerInformacion()
				
				This.asserttrue( "La validacion debe ser incorrecta. (4)", !llRetorno )
				This.assertEquals( "La cantidad de mensajes principales es incorrecta. (4)", 5, loInformacion.count )
				This.assertEquals( "El mensaje de error principal es incorrecto. (4)", ;
					'Falló Validar existencia y consistencia de tipo de dato numérico en el Diccionario, para entidades con numeraciones.', alltrim( loInformacion.Item[ 3 ].cMensaje ) )
					
				This.assertEquals( "El mensaje 1 de error es incorrecto. (4)", 'Entidad "PAIS_TEST" - Atributo "OTRO"  de RelaNumeraciones no existen en el Diccionario', ;
					alltrim( loInformacion.Item[ 1 ].cMensaje ) )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (4)", 'Entidad "PROVINCIA_TEST" - Atributo "NUMERO"  de RelaNumeraciones no existen en el Diccionario', ;
					alltrim( loInformacion.Item[ 2 ].cMensaje ) )
			endif

			delete from relanumeraciones where upper( alltrim( entidad ) ) == "PAIS_TEST"
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarEntidadCAINoPuedeTenerNumeracionesLaClaveCandidataYLaClavePrimaria
		local loInformacion as Object
		
		with This.oValidarADN
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCAINoPuedeTenerNumeracionesLaClaveCandidataYLaClavePrimaria()				

			insert into Entidad ( Entidad, Funcionalidades ) values ( "francia", '<CAI>' )
			insert into Entidad ( Entidad, Funcionalidades ) values ( "argentina", '<CAI>' )
			insert into Diccionario ( Entidad, atributo, tipodato, claveprimaria, clavecandidata ) values ( "francia", 'codigo','N', .t., 0 )
			insert into Diccionario ( Entidad, atributo, tipodato, claveprimaria, clavecandidata ) values ( "francia", 'numero','N', .f., 1 )
			insert into Diccionario ( Entidad, atributo, tipodato, claveprimaria, clavecandidata ) values ( "argentina", 'codigo','N', .t., 0 )
			insert into Diccionario ( Entidad, atributo, tipodato, claveprimaria, clavecandidata ) values ( "argentina", 'numero','N', .f., 1 )

			This.AssertEquals( "No debe dar error al no tener cargadas numeraciones", 0, .oMockInformacionIndividual.Count )
		
			insert into RelaNumeraciones ( Entidad, atributo ) values ( "argentina", 'codigo' )
			insert into RelaNumeraciones ( Entidad, atributo ) values ( "francia", 'codigo' )

    		.oMockInformacionIndividual.Limpiar()
    		.ValidarEntidadCAINoPuedeTenerNumeracionesLaClaveCandidataYLaClavePrimaria()

			This.AssertEquals( "No debe dar error al tener cargadas numeraciones pero correctamente", 0, .oMockInformacionIndividual.Count )
			
			insert into RelaNumeraciones ( Entidad, atributo ) values ( "francia", 'numero' )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCAINoPuedeTenerNumeracionesLaClaveCandidataYLaClavePrimaria()				

			This.AssertEquals( "Debe dar error. La entidad FRANCIA es CAI y tiene asignado talonario en clave primaria y candidata", ;
				1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "La entidad FRANCIA es CAI y tiene asignado talonario en clave primaria y candidata", ;
				"Le entidad FRANCIA tiene asociado un talonario a la clave primaria y a la clave candidata", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
			
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoIdentificadorDeLaTablaEntidad
		local llValidacion as Boolean, i as Integer, lcEntidad as String, lnId as Integer, loInformacion as Object
		lcEntidad = ''
		
		with This.oValidarADN

			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoIdentificadorDeLaTablaEntidad()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Unicidad y existencia de Identificador). Verifique ADN", ;
								0, .oMockInformacionIndividual.Count )
			
			if .oMockInformacionIndividual.Count > 0
				This.messageout( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Unicidad y existencia de Identificador). Verifique ADN" )
				for i = 1 to .oMockInformacionIndividual.Count
					This.messageout( "- " + .oMockInformacionIndividual.Item[ i ].cMensaje )
				endfor
			else
				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD001", "001", "E", "DESC", "B" )
				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD002", "002", "E", "DESC", "B" )
				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD003", "003", "E", "DESC", "B" )
				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ITEM003", "", "I", "DESC", "B" )
				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD004", "004", "E", "DESC", "B" )

				.ValidarCampoIdentificadorDeLaTablaEntidad()
				This.AssertEquals( "La validacion debe ser correcta.", 0, .oMockInformacionIndividual.Count )

				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD005", "002", "E", "DESC", "B" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarCampoIdentificadorDeLaTablaEntidad()
				This.AssertEquals( "La validacion debe ser incorrecta. (1)", 1, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (1)", 1, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje de error es incorrecto. (1)", ;
					'El Identificador "002" está cargado en las entidades "ENTIDAD002,ENTIDAD005" y debe ser único', .oMockInformacionIndividual.Item[ 1 ].cMensaje )

				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD006", "004", "E", "DESC", "B" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarCampoIdentificadorDeLaTablaEntidad()
				This.AssertEquals( "La validacion debe ser incorrecta. (2)", 2, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (2)", 2, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje 1 de error es incorrecto. (2)", ;
					'El Identificador "002" está cargado en las entidades "ENTIDAD002,ENTIDAD005" y debe ser único', .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (2)", ;
					'El Identificador "004" está cargado en las entidades "ENTIDAD004,ENTIDAD006" y debe ser único', .oMockInformacionIndividual.Item[ 2 ].cMensaje )

				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos  ) values ( "ENTIDAD007", "", "E", "DESC", "B" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarCampoIdentificadorDeLaTablaEntidad()
				This.AssertEquals( "La validacion debe ser incorrecta. (3)", 3, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (2)", 3, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje 1 de error es incorrecto. (3)", ;
					'La Entidad "ENTIDAD007" no tiene cargado el campo "Identificador"', .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (3)", ;
					'El Identificador "002" está cargado en las entidades "ENTIDAD002,ENTIDAD005" y debe ser único', .oMockInformacionIndividual.Item[ 2 ].cMensaje )
				This.assertEquals( "El mensaje 3 de error es incorrecto. (3)", ;
					'El Identificador "004" está cargado en las entidades "ENTIDAD004,ENTIDAD006" y debe ser único', .oMockInformacionIndividual.Item[ 3 ].cMensaje )

				insert into Entidad ( entidad, identificador, Tipo, Descripcion, modulos ) values ( "ENTIDAD008", "", "E", "DESC", "B" )

				.oMockInformacionIndividual.Limpiar()
				.ValidarCampoIdentificadorDeLaTablaEntidad()
				This.AssertEquals( "La validacion debe ser incorrecta. (4)", 4, .oMockInformacionIndividual.Count )
				This.assertEquals( "La cantidad de mensajes de error es incorrecta. (4)", 4, .oMockInformacionIndividual.Count )
				This.assertEquals( "El mensaje 1 de error es incorrecto. (4)", ;
					'La Entidad "ENTIDAD007" no tiene cargado el campo "Identificador"', .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (4)", ;
					'La Entidad "ENTIDAD008" no tiene cargado el campo "Identificador"', .oMockInformacionIndividual.Item[ 2 ].cMensaje )
				This.assertEquals( "El mensaje 3 de error es incorrecto. (4)", ;
					'El Identificador "002" está cargado en las entidades "ENTIDAD002,ENTIDAD005" y debe ser único', .oMockInformacionIndividual.Item[ 3 ].cMensaje )
				This.assertEquals( "El mensaje 4 de error es incorrecto. (4)", ;
					'El Identificador "004" está cargado en las entidades "ENTIDAD004,ENTIDAD006" y debe ser único', .oMockInformacionIndividual.Item[ 4 ].cMensaje )

			********
				insert into Dominio ( Dominio ) values ( "CODIGONUMERICO" )

				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD001", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD002", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD003", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD004", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD005", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD006", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD007", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, admitebusqueda, BusquedaOrdenamiento ) ;
					values ( "ENTIDAD008", ;
						"Numero", "CODIGONUMERICO", "1", "N", 1, .T., 0, .t. )
						
				insert into Diccionario ( entidad, atributo, dominio, Etiqueta, TipoDato, Longitud, claveprimaria, ajustable ) ;
					values ( "ITEM003", "Numero", "CODIGONUMERICO", "1", "N", 1, .T., .t. )

				llValidacion = .Validar()
				loInformacion = .ObtenerInformacion()

				This.AssertTrue( "La validacion debe ser incorrecta. (5)", !llValidacion )

				This.AssertEquals( "La cantidad de mensajes principales es incorrecta. (5)", 5, loInformacion.Count )
				
				This.assertEquals( "El mensaje de error principal es incorrecto. (5)", ;
					'Falló Validación de Existencia y Unicidad de Identificador de Entidades.', alltrim( loInformacion.Item[ 5 ].cMensaje ) )
					
				This.assertEquals( "El mensaje 1 de error es incorrecto. (5)", 'La Entidad "ENTIDAD007" no tiene cargado el campo "Identificador"', ;
					alltrim( loInformacion.Item[ 1 ].cMensaje ) )
				This.assertEquals( "El mensaje 2 de error es incorrecto. (5)", 'La Entidad "ENTIDAD008" no tiene cargado el campo "Identificador"', ;
					alltrim( loInformacion.Item[ 2 ].cMensaje ) )
				This.assertEquals( "El mensaje 3 de error es incorrecto. (5)", 'El Identificador "002" está cargado en las entidades "ENTIDAD002,ENTIDAD005" y debe ser único', ;
					alltrim( loInformacion.Item[ 3 ].cMensaje ) )
				This.assertEquals( "El mensaje 4 de error es incorrecto. (5)", 'El Identificador "004" está cargado en las entidades "ENTIDAD004,ENTIDAD006" y debe ser único', ;
					alltrim( loInformacion.Item[ 4 ].cMensaje ) )
			endif
			
			delete from entidad where inlist( upper( alltrim( entidad ) ), "ENTIDAD001", "ENTIDAD002", "ENTIDAD003", "ENTIDAD004", "ENTIDAD005", "ENTIDAD006", "ENTIDAD001" )
			delete from diccionario where inlist( upper( alltrim( entidad ) ), "ENTIDAD001", "ENTIDAD002", "ENTIDAD003", "ENTIDAD004", "ENTIDAD005", "ENTIDAD006", "ENTIDAD001" )
			delete from dominio where inlist( upper( alltrim( dominio ) ), "CODIGONUMERICO" )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarUnicidadDeCamposEnListados
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
			
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen2", .t. )
			
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "2", "RRR", "atribgen", .t. )
		
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
		loValidadorListado.ValidarUnicidadDeCamposEnListados()
		This.AssertEquals( "No valido la unicidad de Campos en listados", 1, this.oValidarADN.oMockInformacionIndividual.Count )
		
		
		delete from listcampos where alltrim( idFormato ) = "1"
		delete from listcampos where alltrim( idFormato ) = "2"
		
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen2", .t. )
			
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "2", "RRR", "atribgen", .t. )
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarUnicidadDeCamposEnListados()
			This.AssertEquals( "No hay duplicados. La validacion debe dar OK", 0, .oMockInformacionIndividual.Count )
		endwith

		delete from listcampos where alltrim( idFormato ) = "1"
		delete from listcampos where alltrim( idFormato ) = "2"

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarFiltrosListados
		local loError, lcArchivo
		
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "100000000", "RRR", "atribgen", 0 )
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "100000000", "RRR", "atribgen1", 1 )
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "100000000", "RRR", "atribgen2", 0 )
			
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "200000000", "RRR", "atribgen", 0 )
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "200000000", "RRR", "atribgen1", 0 )
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "200000000", "RRR", "atribgen2", 0 )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
		
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarFiltrosListados()
			This.AssertEquals( "No validaron los Filtros", 1, .oMockInformacionIndividual.Count )
		endwith
		
		****************************
		insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
			values ( "200000000", "RRR", "atribgen2", 1 )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarFiltrosListados()
			This.AssertEquals( "Todos los listados tienen filtros. La validacion debe dar OK", 0, .oMockInformacionIndividual.Count )
		endwith

		****************************
		lcArchivo = addbs( strtran( lower( _Screen.zoo.cRutaInicial ), "\_base", "" ) ) + "clasesdeprueba\lis_listado300000000objeto.prg"

		if file( lcArchivo )
			lcArchivo = ""
		else
			strtofile( "", lcArchivo )
		endif

		try		
			insert into listcampos ( idFormato, Entidad, Atributo, ordenFiltro ) ;
				values ( "300000000", "RRR", "atribgen2", 1 )
				
			with This.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				loValidadorListado.ValidarFiltrosListados()
				This.AssertEquals( "El listado no tiene filtros pero existe el objeto especifico 999991. La validacion debe dar OK", 0, .oMockInformacionIndividual.Count )
			endwith
		catch to loError
			throw loError
		finally
			if !empty( lcArchivo ) and file( lcArchivo)
				delete file ( lcArchivo)
			endif
		endtry
			
		delete from listcampos where alltrim( idFormato ) = "100000000"
		delete from listcampos where alltrim( idFormato ) = "200000000"
		delete from listcampos where alltrim( idFormato ) = "300000000"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarEtiquetaTipoDatoExpresionParaAtributosVirtualesListados
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
		
		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
		
		with This.oValidarADN
			.CrearAdnAdicional()
			
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarEtiquetaTipoDatoExpresionParaAtributosVirtualesListados()
			This.AssertEquals( "No valido la Etiqueta, tipo de dato o expresion para atributos virtuales en listados", 3, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()			
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
		
		insert into listcampos ( idFormato, Entidad, Atributo, etiqueta, tipodato, expresion, visible ) ;
			values ( "2", "RRR", "atribgen", "ETIQUETA", "C", "expresion", .t. )
		
		with This.oValidarADN
			.CrearAdnAdicional()
			
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarEtiquetaTipoDatoExpresionParaAtributosVirtualesListados()
			This.AssertEquals( "No debe dar error. No valido la Etiqueta, tipo de dato o expresion para atributos virtuales en listados", 0, .oMockInformacionIndividual.Count )

			.CerrarAdnAdicional()			
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "2"

		insert into listados ( id ) values ( "1" )

		insert into entidad ( Entidad, Funcionalidades, Tipo ) ;
			values ( "MEXICO", "<AUDITORIA>", "E" )

		insert into diccionario ( Entidad, Atributo, Auditoria ) ;
			values ( "MEXICO", "Codigo", .t. )

		insert into listcampos ( idFormato, Entidad, Atributo, etiqueta, tipodato, expresion, visible ) ;
			values ( "3", "ADT_MEXICO", "ADT_COD", "", "", "", .t. )
		
		with This.oValidarADN
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()

			loValidadorListado.ValidarEtiquetaTipoDatoExpresionParaAtributosVirtualesListados()
			This.AssertEquals( "No debe dar error, es un listado de una auditoria", 0, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()		
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "3"
		delete from diccionario where upper( alltrim( entidad ) ) = "MEXICO" and upper( alltrim( atributo ) ) = "CODIGO"
		delete from entidad where upper( alltrim( entidad ) ) = "MEXICO"
	endfunc 

	*-----------------------------------------------------------------------------------------
 	function zTestValidarEtiquetasDeCamposNoVirtualesParaListados


				
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
			
		insert into diccionario ( Entidad, Atributo ) ;
			values ( "RRR", "atribgen" )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.CrearAdnAdicional()
		
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarEtiquetasDeCamposNoVirtualesParaListados()
			This.AssertEquals( "No valido que tenga Etiqueta en diccionario o en listcampos para atributos en listados", 1, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()			
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
		delete from diccionario where upper( alltrim( entidad ) ) = "RRR" and upper( alltrim( atributo ) ) = "ATRIBGEN"


		insert into listados ( id ) values ( "1" )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
			
		insert into diccionario ( Entidad, Atributo, etiquetacorta ) ;
			values ( "RRR", "atribgen", "Etiq." )
			
		with This.oValidarADN
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarEtiquetasDeCamposNoVirtualesParaListados()
			This.AssertEquals( "La validacion debe dar OK, porque tiene seteada la etiqueta.", 0, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()				
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
		delete from diccionario where upper( alltrim( entidad ) ) = "RRR" and upper( alltrim( atributo ) ) = "ATRIBGEN"

		insert into entidad ( Entidad, Funcionalidades, Tipo ) ;
			values ( "MEXICO", "<AUDITORIA>", "E" )

		insert into diccionario ( Entidad, Atributo, Auditoria, Etiqueta ) ;
			values ( "MEXICO", "Codigo", .t., "Etiqueta" )

		insert into listcampos ( idFormato, Entidad, Atributo, etiqueta, tipodato, expresion, visible ) ;
			values ( "3", "ADT_MEXICO", "ADT_COD", "", "", "", .t. )
		
		with This.oValidarADN
			.CrearAdnAdicional()
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarEtiquetasDeCamposNoVirtualesParaListados()
			This.AssertEquals( "La validacion debe dar OK, porque es un listado de auditoria.", 0, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()
		endwith

		delete from listcampos where alltrim( idFormato ) = "3"
		delete from diccionario where upper( alltrim( entidad ) ) = "MEXICO" and upper( alltrim( atributo ) ) = "CODIGO"
		delete from entidad where upper( alltrim( entidad ) ) = "MEXICO"

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarAtributoListadosLleno
		
		insert into listcampos ( idFormato, Entidad, visible ) ;
			values ( "1", "RRR", .t. )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarAtributoListadosLleno()
			This.AssertEquals( "No valido que tenga cargado Atributo en listcampos.", 1, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where upper( alltrim( idFormato ) ) = "1"

		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
			
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarAtributoListadosLleno()
			This.AssertEquals( "La validacion debe dar OK, porque tiene atributo.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where upper( alltrim( idFormato ) ) = "1"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarAtributo_BDParaListados
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "_BD", .t. )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "BBB", "_BD", .t. )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarAtributo_BDParaListados()
			This.AssertEquals( "No valido que tenga un solo Atributo llamado _BD en listcampos.", 1, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "atribgen", .t. )
		insert into listcampos ( idFormato, Entidad, Atributo, visible ) ;
			values ( "1", "RRR", "_BD", .t. )
			
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarAtributo_BDParaListados()
			This.AssertEquals( "La validacion debe dar OK, porque tiene un solo Atributo llamado _BD en listcampos.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestValidarSubtotalizadoresEnListados
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible, calculo, subtotaliza ) ;
			values ( "1", "RRR", "AT1", .t., "", 1 )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible, calculo, subtotaliza ) ;
			values ( "1", "BBB", "AT2", .t., "", 0 )
			
		insert into listcampos ( idFormato, Entidad, Atributo, visible, calculo, subtotaliza ) ;
			values ( "1", "CCC", "AT3", .t., "sum", 0 )
		
		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarSubtotalizadoresEnListados()
			This.AssertEquals( "No valido que esten todas las columnas SUBTOTALIZA completas.", 1, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		insert into listcampos ( idFormato, Entidad, Atributo, visible, calculo, subtotaliza ) ;
			values ( "1", "RRR", "AT1", .t., "", 1 )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible, calculo, subtotaliza ) ;
			values ( "1", "BBB", "AT2", .t., "", 2 )
		
		insert into listcampos ( idFormato, Entidad, Atributo, visible, calculo, subtotaliza ) ;
			values ( "1", "CCC", "AT3", .t., "sum", 0 )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarSubtotalizadoresEnListados()
			This.AssertEquals( "La validacion debe dar OK, por que tiene todos los subtotales cargados exepto el registro con CALCULO = 'SUM'.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoGuiaApuntaADistintaEntidadListados
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 1, "1", "RRR", "AT1", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 2, "1", "BBB", "AT2", 0 )
			
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 3, "1", "CCC", "AT3", 0 )
		
		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCampoGuiaApuntaADistintaEntidadListados()
			This.AssertEquals( "No hay atributos con campo guia. Debe dar bien.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 1, "1", "RRR", "AT1", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 2, "1", "BBB", "AT2", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 3, "1", "CCC", "AT3", 1 )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCampoGuiaApuntaADistintaEntidadListados()
			This.AssertEquals( "El campo guia esta apuntando a un atributo de una entidad distinta. Debe dar bien.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 1, "1", "CCC", "AT1", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 2, "1", "BBB", "AT2", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 3, "1", "CCC", "AT3", 1 )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCampoGuiaApuntaADistintaEntidadListados()
			This.AssertEquals( "El campo guia esta apuntando a un atributo de la misma entidad. Debe dar mal.", 1, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoGuiaApuntaExisteEnElMismoListado
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 1, "1", "RRR", "AT1", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 2, "2", "BBB", "AT2", 0 )
			
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 3, "1", "CCC", "AT3", 0 )
		
		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCampoGuiaApuntaExisteEnElMismoListado()
			This.AssertEquals( "No hay atributos con campo guia. Debe dar bien.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 1, "1", "RRR", "AT1", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 2, "2", "BBB", "AT2", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 3, "1", "CCC", "AT3", 1 )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCampoGuiaApuntaExisteEnElMismoListado()
			This.AssertEquals( "El campo guia esta apuntando a un atributo del mismo listado. Debe dar bien.", 0, .oMockInformacionIndividual.Count )
		endwith
		
		
		delete from listcampos where alltrim( idFormato ) = "1"

		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 1, "2", "CCC", "AT1", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 2, "2", "BBB", "AT2", 0 )
		
		insert into listcampos ( id, idFormato, Entidad, Atributo, CampoGuia ) ;
			values ( 3, "1", "AAA", "AT3", 8 )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCampoGuiaApuntaExisteEnElMismoListado()
			This.AssertEquals( "El campo guia esta apuntando a un atributo inexistente. Debe dar mal", 1, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposClavesPrimariaListados
		
		insert into diccionario ( Entidad, Atributo, ClavePrimaria ) ;
			values ( "AAA", "A1", .f. )
		insert into diccionario ( Entidad, Atributo, ClavePrimaria ) ;
			values ( "AAA", "Cp", .t. )
		insert into diccionario ( Entidad, Atributo, ClavePrimaria ) ;
			values ( "AAA", "A2", .f. )
		insert into diccionario ( Entidad, Atributo, ClavePrimaria ) ;
			values ( "BBB", "A1", .f. )
		insert into diccionario ( Entidad, Atributo, ClavePrimaria ) ;
			values ( "BBB", "Cp", .t. )
		insert into diccionario ( Entidad, Atributo, ClavePrimaria ) ;
			values ( "BBB", "A2", .f. )

		insert into listados (id) values ("1")
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "A1", 10, 2, "D" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "Cp", 0, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "A2", 10, 2, "D" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "Cp", 0, 0, "" )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
		
		with This.oValidarADN
			.CrearAdnAdicional()
		
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCamposClavesPrimariaListados()
			This.AssertEquals( "Los atributos modificados noi son CP. Debe dar bien.", 0, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()						
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		***		
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "A1", 0, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "Cp", 1, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "A2", 10, 2, "D" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "Cp", 0, 0, "" )
			
		with This.oValidarADN
			.CrearAdnAdicional()
		
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCamposClavesPrimariaListados()
			This.AssertEquals( "Se modifico la longitud del atributo CP de la entidad AAA. Debe dar mal.", 1, .oMockInformacionIndividual.Count )
			
			This.assertEquals( "mensaje de error incorrecto. Se modifico la longitud del atributo CP de la entidad AAA. Debe dar mal.", ;
								"No se puede modificar la Longitud, Decimales o Tipo de Dato del atributo Cp para la entidad AAA del listado " + ;
								"1 ya que es Clave Primaria.", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
								
			.CerrarAdnAdicional()											
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		***		
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "A1", 10, 2, "D" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "Cp", 0, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "A2", 0, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "Cp", 0, 2, "" )
			
		with This.oValidarADN
			.CrearAdnAdicional()
		
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCamposClavesPrimariaListados()
			This.AssertEquals( "Se modifico los decimales del atributo CP de la entidad BBB. Debe dar mal.", 1, .oMockInformacionIndividual.Count )
			
			This.assertEquals( "mensaje de error incorrecto. Se modifico los decimales del atributo CP de la entidad BBB. Debe dar mal.Debe dar mal.", ;
								"No se puede modificar la Longitud, Decimales o Tipo de Dato del atributo Cp para la entidad BBB del listado " + ;
								"1 ya que es Clave Primaria.", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
								
			.CerrarAdnAdicional()											
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		***		
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "A1", 0, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "A2", 2, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "AAA", "Cp", 0, 0, "C" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "A2", 0, 0, "" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "Cp", 0, 0, "D" )
		insert into listcampos ( id, idFormato, Entidad, Atributo, Longitud, Decimales, TipoDato ) ;
			values ( 1, "1", "BBB", "A2", 0, 2, "" )
			
		with This.oValidarADN
			.CrearAdnAdicional()
		
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarCamposClavesPrimariaListados()
			This.AssertEquals( "Se modifico el tipo de dato del atributo CP de la entidad BBB y AAA. Debe dar mal.", 2, .oMockInformacionIndividual.Count )
			This.assertEquals( "mensaje de error incorrecto. Se modifico el tipo de dato del atributo CP de la entidad BBB y AAA. Debe dar mal.Debe dar mal. (1)", ;
								"No se puede modificar la Longitud, Decimales o Tipo de Dato del atributo Cp para la entidad AAA del " + ;
								"listado 1 ya que es Clave Primaria.", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
								
			This.assertEquals( "mensaje de error incorrecto. Se modifico la longitud del atributo CP de la entidad AAA. Debe dar mal. (2)", ;
								"No se puede modificar la Longitud, Decimales o Tipo de Dato del atributo Cp para la entidad BBB del listado " + ;
								"1 ya que es Clave Primaria.", .oMockInformacionIndividual.Item[ 2 ].cMensaje )
								
			.CerrarAdnAdicional()											
		endwith
		
		delete from listcampos where alltrim( idFormato ) = "1"

		***
		delete from listcampos where alltrim( idFormato )  = "1"
		delete from diccionario where Entidad = "AAA" or Entidad = "BBB"


		***
		insert into entidad ( Entidad, Funcionalidades, Tipo ) ;
			values ( "MEXICO", "<AUDITORIA>", "E" )

		insert into diccionario ( Entidad, Atributo, Auditoria, Etiqueta, ClavePrimaria ) ;
			values ( "MEXICO", "Codigo", .t., "Etiqueta", .t. )

		insert into listcampos ( idFormato, Entidad, Atributo, etiqueta, tipodato, expresion, visible ) ;
			values ( "3", "ADT_MEXICO", "ADT_COD", "", "", "", .t. )

		with This.oValidarADN
			.CrearAdnAdicional()
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarEtiquetasDeCamposNoVirtualesParaListados()
			This.AssertEquals( "La validacion debe dar OK, porque es un listado de auditoria.", 0, .oMockInformacionIndividual.Count )
			
			.CerrarAdnAdicional()						
		endwith

		delete from listcampos where alltrim( idFormato ) = "1"
		delete from diccionario where upper( alltrim( entidad ) ) = "MEXICO" and upper( alltrim( atributo ) ) = "CODIGO"
		delete from entidad where upper( alltrim( entidad ) ) = "MEXICO"
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposVotacion

		local lcCursor as String 
		lcCursor = sys( 2015 )

		insert into diccionario ( Entidad, Atributo, validacomp ) ;
			values ( "AAA", "A1", .f. )
		insert into diccionario ( Entidad, Atributo, validacomp ) ;
			values ( "AAA", "Cp", .t. )
		insert into diccionario ( Entidad, Atributo, validacomp ) ;
			values ( "AAA", "A2", .f. )
			
		insert into diccionario ( Entidad, Atributo, validacomp ) ;
			values ( "BBB", "A1", .T. )
		insert into diccionario ( Entidad, Atributo, validacomp ) ;
			values ( "BBB", "A2", .f. )	
		insert into entidad ( entidad, tipo ) values ( "BBB" , "E" )

		with This.oValidarAdn
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposVotacion()

			This.AssertEquals( "Fallo la validacion de camposVotacion", 2, .oMockInformacionIndividual.Count )
			this.AssertEquals( "La cantidad de errores no es correcta", 2, .oMockInformacionIndividual.Count )

			this.assertequals( "El mensaje de error 1 no es el correcto", ;
			"Error en la entidad 'AAA' atributo 'Cp'.Tiene diccionario.validaComp y no tiene componente relacionado.", ;
			 						.oMockInformacionIndividual.item[1].cMensaje )

			this.assertequals( "El mensaje de error 2 no es el correcto", ;
			"Error en la entidad 'BBB' atributo 'A1'.Tiene diccionario.validaComp y no tiene componente relacionado.", ;
			 						.oMockInformacionIndividual.item[2].cMensaje )

		endwith
		delete from diccionario where entidad = "AAA"	
		delete from entidad where entidad = "BBB"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarListCampos

		insert into listcampos ( idFormato, atributo ) values ( "15", "atri1" )
		insert into listcampos ( idFormato, atributo ) values ( "16", "atri1" )		
		insert into listcampos ( idFormato, atributo ) values ( "16", "_grupo" )		

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
				
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarListCampos()
		
			This.AssertEquals( "Fallo la validacion de listcampos", 1, .oMockInformacionIndividual.Count )
			This.assertequals( "La cantidad de errores no es la correcta", 1, .oMockInformacionIndividual.Count )
			This.assertequals( "El mensaje del error 1 no es el correcto", ;
				"El listado 16 tiene un atributo _GRUPO el cual está reservado para el framework.", ;
				.oMockInformacionIndividual.item[1].cMensaje )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarAtributosEnListCampos

		insert into Diccionario ( Entidad, Atributo, dominio ) ;
				values ( "EntidadTest", "AtributoTest", "DETALLEITEMTEST")

		insert into listcampos ( id, idFormato, Entidad, Atributo ) ;
			values ( 9999, "999", "EntidadTest", "AtributoTest" )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
					
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarAtributosEnListCampos()
			This.AssertEquals( "No se valido correctamente la existencia de atributos 'DETALLE' en ListCampos", 1, .oMockInformacionIndividual.Count )
		endwith
		
		delete from listcampos where upper( alltrim( idFormato ) ) = "999"
		delete from diccionario where upper( alltrim( entidad ) ) = "ENTIDADTEST" and upper( alltrim( atributo ) ) = "ATRIBUTOTEST"

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			loValidadorListado.ValidarAtributosEnListCampos()
			This.AssertEquals( "La validacion debe dar OK, porque no existen atributos 'DETALLE' en ListCampos", 0, .oMockInformacionIndividual.Count )
		endwith

		release loRetono

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarValidarAtributosUnicosEnEstetica
	
		insert into Diccionario ( Entidad, Atributo, dominio, estetica ) ;
				values ( "EntidadTest", "AtributoTest", "DETALLEITEMTEST", "G1" )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosUnicosEnEstetica()
			This.AssertEquals( "No se valido correctamente los atributos unicos en grupos de estetica.", 1, .oMockInformacionIndividual.Count )
		endwith

		insert into Diccionario ( Entidad, Atributo, dominio, estetica ) ;
				values ( "EntidadTest", "AtributoTest2", "DETALLEITEMTEST", "G1" )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosUnicosEnEstetica()
			This.AssertEquals( "La validacion debe dar OK, porque existen dos atributos en el mismo grupo estetica.", 0, .oMockInformacionIndividual.Count )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposDuplicadosIdEnMenuPrincipal

		insert into MenuPrincipal ( id, idpadre, etiqueta ) values ( 99, 99, "prueba adn" )
		insert into MenuPrincipal ( id, idpadre, etiqueta ) values ( 78, 78, "prueba adn" )
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosIdEnMenuPrincipal()
			This.AssertEquals( "No se validaron correctamente los campos duplicados en la tabla MenuPrincipal.", 0, .oMockInformacionIndividual.Count )
		endwith

		insert into MenuPrincipal ( id, idpadre, etiqueta ) values ( 99, 99, "prueba adn" )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosIdEnMenuPrincipal()
			This.AssertEquals( "Se validaron correctamente los campos duplicados en la tabla MenuPrincipal.", 1, .oMockInformacionIndividual.Count )
		endwith

		delete from MenuPrincipal where id = 99 and idpadre = 99 and alltrim(upper( etiqueta )) = "PRUEBA ADN"
		delete from MenuPrincipal where id = 78 and idpadre = 78 and alltrim(upper( etiqueta )) = "PRUEBA ADN"

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCamposDuplicadosIdEnMenuPrincipalItems

		insert into MenuPrincipalItems ( id, idpadre, etiqueta ) values ( 99, 99, "prueba adn" )
		insert into MenuPrincipalItems ( id, idpadre, etiqueta ) values ( 78, 78, "prueba adn" )
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosIdEnMenuPrincipalItems()
			This.AssertEquals( "No se validaron correctamente los campos duplicados en la tabla MenuPrincipalItems.", 0, .oMockInformacionIndividual.Count )
		endwith

		insert into MenuPrincipalItems ( id, idpadre, etiqueta ) values ( 99, 99, "prueba adn" )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarCamposDuplicadosIdEnMenuPrincipalItems()
			This.AssertEquals( "Se validaron correctamente los campos duplicados en la tabla MenuPrincipalItems.", 1, .oMockInformacionIndividual.Count )
		endwith

		delete from MenuPrincipalItems where id = 99 and idpadre = 99 and alltrim(upper( etiqueta )) = "PRUEBA ADN"
		delete from MenuPrincipalItems where id = 78 and idpadre = 78 and alltrim(upper( etiqueta )) = "PRUEBA ADN"

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarTieneSeguridadMenu
		***Caso 1
		insert into MenuPrincipalItems ( id, idpadre, etiqueta, lTieneSeguridad ) values ( 98, 56, "primer opcion", .t. )
		insert into MenuPrincipalItems ( id, idpadre, etiqueta, lTieneSeguridad ) values ( 99, 78, "prueba adn", .t. )
		insert into MenuPrincipal( id, etiqueta, lTieneSeguridad ) values ( 56, "Sistema", .f. )
		insert into MenuPrincipal( id, etiqueta, lTieneSeguridad ) values ( 78, "prueba adn", .f. )
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTieneSeguridadMenu()
			This.AssertEquals( "La seguridad del menu item padre tapa a la seguridad del menu item hijo (1)", 1, .oMockInformacionIndividual.Count )
		endwith
		delete from MenuPrincipalItems where id = 99 
		delete from MenuPrincipal where id = 78 
	
		***Caso 2	
		insert into MenuPrincipalItems ( id, idpadre, etiqueta, lTieneSeguridad ) values ( 99, 78, "prueba adn", .f. )
		insert into MenuPrincipal( id, etiqueta, lTieneSeguridad ) values ( 78, "prueba adn", .t. )
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTieneSeguridadMenu()
			This.AssertEquals( "La seguridad del menu item padre tapa a la seguridad del menu item hijo (2)", 1, .oMockInformacionIndividual.Count )
		endwith
		delete from MenuPrincipalItems where id = 99 
		delete from MenuPrincipal where id = 78 	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestAgregarInformacionGeneral
		local loInformacion as Object, loValidarAdn as Object, loInformacionIndividual as Object

		loValidarAdn = newobject( "ValidarADNAux" )		
		loInformacionIndividual = _screen.zoo.crearobjeto( "ZooInformacion" )
		
		
		loValidarAdn.MockAgregarInformacionGeneral( "No deberia agregar esto" )
		loInformacion = loValidarAdn.ObtenerInformacion()
		This.assertequals( "No deberia agregar el mensaje ya que la coleccion esta vacia.", 0, loInformacion.Count )
				
		with loInformacionIndividual
			.AgregarInformacion( "Mensaje de Prueba Nro 1" )
			.AgregarInformacion( "Mensaje de Prueba Nro 2" )
			.AgregarInformacion( "Mensaje de Prueba Nro 3" )
		endwith
		loValidarAdn.ReemplazarInformacionIndividual( loInformacionIndividual )
		loValidarAdn.MockAgregarInformacionGeneral( "Deberia agregar este mensaje" )
		loInformacion = loValidarAdn.ObtenerInformacion()
		with This
			.assertequals( "No deberia agregar el mensaje", 4, loInformacion.Count )
			.assertequals( "Mensaje 1 invalido.", "Mensaje de Prueba Nro 1", alltrim( loInformacion.Item[ 1 ].cMensaje ) )
			.assertequals( "Mensaje 2 invalido.", "Mensaje de Prueba Nro 2", alltrim( loInformacion.Item[ 2 ].cMensaje ) )
			.assertequals( "Mensaje 3 invalido.", "Mensaje de Prueba Nro 3", alltrim( loInformacion.Item[ 3 ].cMensaje ) )
			.assertequals( "Mensaje 4 invalido.", "Deberia agregar este mensaje", alltrim( loInformacion.Item[ 4 ].cMensaje ) )
		endwith							

		loInformacionIndividual.release()
		loInformacion.Release()
		loValidarAdn.Release()
		loValidarADN = null

	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarUsoEntidadVersionV1

		with This.oValidarADN
		
			*--
			insert into Entidad ( Entidad, Descripcion, Titulo, Version ) ;
					values ( "ENTIDADTEST", "ENTIDAD DE PRUEBA", "ENTIDAD DE PRUEBA", 2 )
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarUsoEntidadVersionV1()
			This.AssertEquals( "Se debe permitir la carga entidades con valor 2.", 0, .oMockInformacionIndividual.Count )
	
			*--
			insert into Entidad ( Entidad, Descripcion, Titulo, Version ) ;
					values ( "ENTIDADTEST2", "ENTIDAD DE PRUEBA 2", "ENTIDAD DE PRUEBA 2", 1 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarUsoEntidadVersionV1()
			This.AssertEquals( "No se debe permitir la carga entidades con valor 1.", 1, .oMockInformacionIndividual.Count )


			*--
			update entidad set Version = 0 where alltrim( Entidad ) == "ENTIDADTEST2"
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarUsoEntidadVersionV1()
			This.AssertEquals( "Se debe permitir la carga entidades con valor 0(por defecto es V2)", 0, .oMockInformacionIndividual.Count )

			*--
			update entidad set Version = 99 where alltrim( Entidad ) == "ENTIDADTEST2"
				
			.oMockInformacionIndividual.Limpiar()
			.ValidarUsoEntidadVersionV1()
			This.AssertEquals( "Se debe permitir la carga entidades con valor X(por defecto es V2)", 0, .oMockInformacionIndividual.Count )


		endwith

	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestAdnAuditoria
		local i as Integer
		
		with This.oValidarADN
			.cDiccionarioAdicional = sys( 2015 )
			.cEntidadAdicional = sys( 2015 )
			*--
			insert into Entidad ( Entidad, Descripcion, Titulo, Funcionalidades ) ;
					values ( "ENTIDADTEST", "ENTIDAD DE PRUEBA", "ENTIDAD DE PRUEBA", "<AUDITORIA>" )
	
			insert into diccionario ( Entidad, tabla, campo, claveprimaria ) ;
					values ( "ENTIDADTEST", "tabla", "campo", .F. )	
			select * from entidad into cursor ( .cEntidadAdicional )
			select * from diccionario into cursor ( .cDiccionarioAdicional )

			insert into transferenciasagrupadas ( id, descripcion ) values ( 99, "Auditorias" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir la carga de auditoria a una entidad sin nada que auditar", 1, .oMockInformacionIndividual.Count )
			*--

			delete from transferenciasagrupadas where id = 99
			update diccionario set auditoria = .T. where alltrim( entidad ) = "ENTIDADTEST"
			select * from diccionario into cursor ( .cDiccionarioAdicional )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "Debe validar que falta el nodo de transferencias agrupadas de auditoria", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "Debe validar que falta el nodo de transferencias agrupadas de auditoria", "Falta el nodo de auditorias en TransferenciasAgrupadas", .oMockInformacionIndividual.item[1].cmensaje )
			
			insert into transferenciasagrupadas ( id, descripcion ) values ( 99, "Auditorias" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "Debe permitir auditar la entidad, porque tiene atributos que auditar", 0, .oMockInformacionIndividual.Count )


			update diccionario set claveprimaria = .T. where alltrim( entidad ) = "ENTIDADTEST"
			select * from diccionario into cursor ( .cDiccionarioAdicional )
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir auditar la clave primaria", "Entidad: ENTIDADTEST - no se puede auditar la clave primaria", ;
				.oMockInformacionIndividual.item[ 1 ].cMensaje )
			
			update diccionario set claveprimaria = .F., clavecandidata = 1 where alltrim( entidad ) = "ENTIDADTEST"
			select * from diccionario into cursor ( .cDiccionarioAdicional )
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir auditar la clave candidata", "Entidad: ENTIDADTEST - no se puede auditar la clave candidata", ;
				.oMockInformacionIndividual.item[ 1 ].cMensaje )

			update diccionario set clavecandidata = 0, tabla = "" where alltrim( entidad ) = "ENTIDADTEST"
			select * from diccionario into cursor ( .cDiccionarioAdicional )
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir auditar atributos virtuales", "Entidad: ENTIDADTEST - no se puede auditar atributos  virtuales", ;
				.oMockInformacionIndividual.item[ 1 ].cMensaje )
			
			update diccionario set auditoria = .F., claveprimaria = .T., tabla = "tabla" where alltrim( entidad ) = "ENTIDADTEST"
			select * from diccionario into cursor ( .cDiccionarioAdicional )
			
			insert into diccionario ( Entidad, atributo, Auditoria, tabla, campo, atributoforaneo ) ;
					values ( "ENTIDADTEST", "atributotest", .T., "tabla2", "campo", "algun.atributo" )

			select * from diccionario into cursor ( .cDiccionarioAdicional )
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir auditar atributos foraneos", ;
				"Entidad: ENTIDADTEST - no se pueden auditar campos foraneos que graban en otras tablas" , ;
				.oMockInformacionIndividual.item[ 1 ].cMensaje )
				
			update diccionario set tipodato = "M", tabla = "tabla" where alltrim( atributo ) = "atributotest"
			select * from diccionario into cursor ( .cDiccionarioAdicional )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir auditar atributos tipo memo", ;
				"Entidad: ENTIDADTEST - no se puede auditar atributos del tipo Memo" , ;
				.oMockInformacionIndividual.item[ 1 ].cMensaje )
				
			update diccionario set tipodato = "C" where alltrim( atributo ) = "atributotest"			
			for i = 1 to 210
				insert into diccionario ( entidad, atributo, campo, tabla, auditoria ) ;
					values ( "ENTIDADTEST", "ATRI" + transform( i ), "CAMPO" + transform( i ), "tabla", .T. )
			endfor
			select * from diccionario into cursor ( .cDiccionarioAdicional )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "No debe permitir auditar mas de 200 campos de una misma tabla", ;
				"Tabla: tabla - no se puede auditar mas de 200 atributos" , ;
				.oMockInformacionIndividual.item[ 1 ].cMensaje )
			
			for i = 1 to 210
				update diccionario set auditoria = .F. where atributo = "ATRI" + transform( i )
			endfor
			select * from diccionario into cursor ( .cDiccionarioAdicional )
			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "Tendria que haber validado todo ok", 0 , .oMockInformacionIndividual.count )

		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestTablasAuditoria
 
		with This.oValidarADN
			.cDiccionarioAdicional = sys( 2015 )
			*Como en el validaradn todavia no se puede consumir los parametros y reg. se dejo duro el prefijo, es el unico lugar donde esta asi. 
			*Por favor consumir el registro en los demas lugares donde haga falta
			this.assertequals( "El prefijo que esta duro en el validaradn es diferente al registro que se consume en el resto del sistema, por favor cambielo", ; 
				.cPrefijoAuditoria, alltrim( upper( goregistry.nucleo.prefijotablasauditoria ) ) )
			*--
			insert into Diccionario ( Entidad, tabla ) ;
					values ( "ENTIDADTEST", .cPrefijoAuditoria + "PRUEBA" )
			select * from diccionario into cursor ( .cDiccionarioAdicional )
		
			.oMockInformacionIndividual.Limpiar()
			.ValidarTablasAuditoria()
			This.AssertEquals( "No debe permitir una tabla con el prefijo de auditoria", 1, .oMockInformacionIndividual.Count )
			*--
			update Diccionario set tabla = "unaTabla" where alltrim( entidad ) = "ENTIDADTEST"
			select * from diccionario into cursor ( .cDiccionarioAdicional )

			.oMockInformacionIndividual.Limpiar()
			.ValidarAdnAuditoria()
			This.AssertEquals( "Debe permitir auditar la entidad", 0, .oMockInformacionIndividual.Count )

		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoComportamiento

		with This.oValidarADN

			insert into Entidad ( Entidad, Comportamiento ) values ( "ENTIDADTEST1", "" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoComportamiento()
			This.AssertEquals( "No deberia validar Entidades sin comportamiento", 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad, Comportamiento ) values ( "ENTIDADTEST2", "Z" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoComportamiento()
			This.AssertEquals( "Deberia haber pinchado la validacion de campo Comportamiento(1).", 1, .oMockInformacionIndividual.Count )

			update Entidad set Comportamiento = "T" where alltrim( entidad ) = "ENTIDADTEST2"
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoComportamiento()						
			This.AssertEquals( "No deberia Pinchar por campo comportamiento", 0, .oMockInformacionIndividual.Count )

			update Entidad set Comportamiento = "BZ" where alltrim( entidad ) = "ENTIDADTEST2"
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoComportamiento()						
			This.AssertEquals( "Deberia haber pinchado la validacion de campo Comportamiento(2).", 1, .oMockInformacionIndividual.Count )
		
			update Entidad set Comportamiento = "BT" where alltrim( entidad ) = "ENTIDADTEST2"
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoComportamiento()						
			This.AssertEquals( "No deberia Pinchar por campo comportamiento", 0, .oMockInformacionIndividual.Count )

		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarAuditoriaEnItems
			
		with This.oValidarADN
		
			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "EntidadConDetalle", "<AUDITORIA>", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarItemsConAuditoria()
			This.AssertEquals( "No deberia Pinchar por Items con Auditoria(1)", 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad, Tipo ) values ( "ItemEntidadConDetalle", "I" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarItemsConAuditoria()
			This.AssertEquals( "No deberia Pinchar por Items con Auditoria(2)", 0, .oMockInformacionIndividual.Count )
		
			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "ItemEntidadConDetalle", "<AUDITORIA>", "I" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarItemsConAuditoria()
			This.AssertEquals( "Deberia Pinchar por Items con auditoria.", 1, .oMockInformacionIndividual.Count )
		
		endwith

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestValidarCampoFuncionalidades
	
		with This.oValidarADN
			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "EntidadConDetalle", "<AUDITORIA>", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "No deberia Pinchar, el campo FUNCIONALIDADES tiene valores correctos.", 0, .oMockInformacionIndividual.Count )
			
			delete from Entidad where alltrim( Entidad ) == "EntidadConDetalle"
			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "EntidadConDetalle", "<AUDITORIA><LINCE><ANULABLE><NOEXPO><NOIMPO><HABILITARIMPOINSEGURA><TRANSMODOSEGUROCEN><TRANSMODOSEGURODB><PAIS:1><PAIS:2><PAIS:3><NOLOGUEAR><MODULOSLISTADO:SFGC><CODIGOSUGERIDO><CE><FRMMODAL>,<IMPOSEGURACONCORTE>", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "No deberia Pinchar, el campo FUNCIONALIDADES tiene valores correctos 2.", 0, .oMockInformacionIndividual.Count )			

			delete from Entidad where alltrim( Entidad ) == "EntidadConDetalle"
			insert into Entidad ( Entidad, Tipo ) values ( "EntidadConDetalle", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "No deberia Pinchar, el campo FUNCIONALIDADES esta vacio.", 0, .oMockInformacionIndividual.Count )

			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "EntidadConDetalle", "<SoyUnTagQueNoDeboValidar>", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "Deberia Pinchar, el campo FUNCIONALIDADES no tiene valores incorrectos.", 1, .oMockInformacionIndividual.Count )
		
			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "EntidadConDetalle", "<AUDITORIA >", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "Deberia Pinchar, el campo FUNCIONALIDADES tiene un tag con espacios.", 2, .oMockInformacionIndividual.Count )

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarTransferencias
		with this.oVALIDARADN

			insert into transferencias ( entidad ) values ( "ent1" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarTransferencias()
			this.AssertEquals( "Deberia Pinchar por varios motivos...", "La entidad ent1 está en transferencias y no existe como entidad", .oMockInformacionIndividual.item[ 1 ].cMensaje )
			this.AssertEquals( "Deberia Pinchar por varios motivos...", "Faltan campos obligatorios en la tabla transferencias", .oMockInformacionIndividual.item[ 2 ].cMensaje )
			this.AssertEquals( "Error en la cantidad de errores", 2, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			delete from entidad
			delete from transferencias

			insert into entidad (entidad, tipo ) values ( "ent1", "E" )
			insert into entidad (entidad, tipo ) values ( "ent2", "E" )
			insert into transferencias ( entidad, codigo, descrip, orden ) values ( "ent1", "ent2", "transferencia 1", 0 )
			.ValidarTransferencias()
			this.AssertEquals( "Deberia Pinchar por codigo repetido", "El código de transferencia ent2 es inválido ya que existe como entidad", .oMockInformacionIndividual.item[ 1 ].cMensaje )
			this.AssertEquals( "Error en la cantidad de errores 2", 1, .oMockInformacionIndividual.Count )
			
			.oMockInformacionIndividual.Limpiar()
			delete from entidad
			delete from transferencias

			insert into transferencias ( entidad, codigo, descrip, orden ) values ( "ent1", "tra2", "transferencia 1", 0 )
			.ValidarTransferencias()
			this.AssertEquals( "Deberia Pinchar por faltar la entidad asociada a la transferencia tra1", "La entidad ent1 está en transferencias y no existe como entidad", .oMockInformacionIndividual.item[ 1 ].cMensaje )
			this.AssertEquals( "Error en la cantidad de errores 4", 1, .oMockInformacionIndividual.Count )
			
			insert into entidad (entidad, tipo ) values ( "ent1", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarTransferencias()
			this.AssertEquals( "No debe haber errores", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarFiltrosTransferencias
		with this.oVALIDARADN
			insert into transferencias ( entidad ) values ( "ent1" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarFiltrosTransferencias_TEST()
			this.AssertEquals( "Deberia Pinchar por no tener filtros", "La entidad ent1 está en transferencias pero no tiene cargado filtros", .oMockInformacionIndividual.item[ 1 ].cMensaje )
			
			insert into transferenciasFiltros ( entidad, atributo ) values ( "ent1", "atr1" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarFiltrosTransferencias_TEST()
			this.AssertEquals( "No debe haber errores", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestValidarCampoGUIDClave

		with This.oValidarADN
			insert into Entidad ( Entidad, Funcionalidades, Tipo ) values ( "EntidadConDetalle", "<AUDITORIA>", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "No deberia Pinchar, el campo FUNCIONALIDADES tiene valores correctos.", 0, .oMockInformacionIndividual.Count )
			
			insert into Entidad ( Entidad, Tipo ) values ( "EntidadConDetalle", "E" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCampoFuncionalidades()
			This.AssertEquals( "No deberia Pinchar, el campo FUNCIONALIDADES esta vacio.", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarCantidadDeAutoincrementales
		
		with This.oValidarADN
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAutoincrementales()
			
			This.AssertEquals( "No deberia Pinchar", 0, .oMockInformacionIndividual.Count )
			
			insert into diccionario ( tipoDato ) values ( "A" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCantidadDeAutoincrementales()
			This.AssertEquals( "Deberia Pinchar, la cantidad de autoincrementales no es la que tendria que haber", 1, .oMockInformacionIndividual.Count )
			
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarLongitudCamposIncrementales

		with This.oValidarADN

			delete from Dominio
			delete from Entidad
			delete from Diccionario
			
			insert into Dominio ( Dominio, Detalle ) ;
				values ( "DetalleItemPepe", .T. )
			insert into Entidad ( Entidad, Tipo ) ;
				values ( "Entidad1", "E" )
			insert into Entidad ( Entidad, Tipo ) ;
				values ( "Entidad2", "E" )

			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla ) ;
				values ( "Entidad1", "Atributo1", "A", 0, 0, "Tabla1" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "Debería haber saltado la validación la longitud de los campos Autoincrementales (1)", 2, .oMockInformacionIndividual.Count )

			delete from Diccionario
			
			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla ) ;
				values ( "Entidad1", "Atributo1", "A", 9, 0, "Tabla1" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "No Debería haber saltado la validación la longitud de los campos Autoincrementales (2)", 0, .oMockInformacionIndividual.Count )
			
			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla ) ;
				values ( "Entidad1", "Atributo2", "A", 9, 1, "Tabla1" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "Debería haber saltado la validación la longitud de los campos Autoincrementales (3)", 2, .oMockInformacionIndividual.Count )
			
			delete from Diccionario

			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla ) ;
				values ( "Entidad1", "Atributo1", "A", 9, 0, "Tabla1" )
			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, ClaveForanea  ) ;
				values ( "Entidad2", "Atributo1", "N", 9, 0, "Tabla1", "Entidad1" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "No Debería haber saltado la validación la longitud de los campos Autoincrementales (4)", 0, .oMockInformacionIndividual.Count )
			
			delete from Diccionario

			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, ClavePrimaria ) ;
				values ( "Entidad1", "Atributo1", "A", 9, 0, "Tabla1", .T. )
			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, ClaveForanea ) ;
				values ( "Entidad2", "Atributo1", "N", 8, 0, "Tabla1", "Entidad1" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "Debería haber saltado la validación la longitud de los campos Autoincrementales (5)", 2, .oMockInformacionIndividual.Count )
			
			delete from Diccionario

			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, ClavePrimaria ) ;
				values ( "Entidad1", "Atributo1", "A", 9, 0, "Tabla1", .T. )
			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, Dominio ) ;
				values ( "Entidad1", "Atributo2", "N", 9, 0, "Tabla1", "DetalleItemPepe" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "No Debería haber saltado la validación la longitud de los campos Autoincrementales (6)", 0, .oMockInformacionIndividual.Count )
			
			delete from Diccionario

			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, ClavePrimaria ) ;
				values ( "Entidad1", "Atributo1", "A", 9, 0, "Tabla1", .T. )
			insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Decimales, Tabla, Dominio ) ;
				values ( "Entidad1", "Atributo2", "N", 10, 0, "Tabla1", "DetalleItemPepe" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudCamposAutoIncrementales()
			This.AssertEquals( "Debería haber saltado la validación la longitud de los campos Autoincrementales (7)", 2, .oMockInformacionIndividual.Count )

		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestValidarAnulables

		with This.oValidarADN
			insert into entidad ( entidad, funcionalidades ) values ( "mexico", "" )
			insert into diccionario ( entidad, atributo, tipodato ) values ( "mexico", "anulado", "L" )
			
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarFuncionalidadAnulable()
			This.AssertEquals( "No deberia tener problemas ya que no tiene nada anulable", 0, .oMockInformacionIndividual.Count )
			
			update entidad set funcionalidades = "<ANULABLE>" where entidad = "mexico"
			.oMockInformacionIndividual.Limpiar()
			.ValidarFuncionalidadAnulable()
			This.AssertEquals( "No deberia tener problemas ya que tiene el atributo anulado", 0, .oMockInformacionIndividual.Count )

			update diccionario set atributo = "pepito" where atributo = "anulado"
			.oMockInformacionIndividual.Limpiar()
			.ValidarFuncionalidadAnulable()
			This.AssertEquals( "Deberia tener problemas ya que no tiene el atributo anulado", 1, .oMockInformacionIndividual.Count )
			
			update diccionario set atributo = "anulado" where atributo = "pepito"
			.oMockInformacionIndividual.Limpiar()
			.ValidarFuncionalidadAnulable()
			This.AssertEquals( "No deberia tener problemas ya que tiene el atributo anulado de vuelta", 0, .oMockInformacionIndividual.Count )

			update diccionario set tipodato = "C" where atributo = "anulado"
			.oMockInformacionIndividual.Limpiar()
			.ValidarFuncionalidadAnulable()
			This.AssertEquals( "Deberia tener problemas ya que el tipo de dato no es el correcto", 1, .oMockInformacionIndividual.Count )

			delete from entidad
			delete from diccionario
		endwith

	endfunc 
 
	*-----------------------------------------------------------------------------------------
	function zTestValidarOrdenNavegacion
		with this.oValidarAdn
			
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "codigo", "N", "CODIGONUMERICO", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "detallecanada", "N", "DETALLEITEMCANADA", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "numero", "N", "NUMEROCOMPROBANTE", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "puntodeventa", "N", "NUMEROCOMPROBANTE", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "letra", "C", "NUMEROCOMPROBANTE", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "descripcion", "C", "DESCRIPCION", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "listadeprecio", "N", "LISTADEPRECIOSPREFERENTE", 0 )
			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "CANADA", "descripcion", "C", "DESCRIPCION", 0 )

			insert into diccionario ( entidad, atributo, tipodato, dominio, ordennavegacion ) values ( "ITEMCANADA", "gobernador", "C", "CARACTER", 0 )
			
			insert into entidad ( entidad, tipo ) values ( "CANADA", "E" )
			insert into entidad ( entidad, tipo ) values ( "ITEMCANADA", "I" )
			
			insert into dominio ( dominio, detalle ) values ( "DETALLEITEMCANADA", .T. )

			update diccionario set ordenNavegacion = 1 where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "CODIGO"
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "No deberia tener problemas", 0, .oMockInformacionIndividual.Count )
			
			update diccionario set ordenNavegacion = 1 where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "NUMERO"
			.oMockInformacionIndividual.Limpiar()
	
			.ValidarOrdenNavegacion()
			This.AssertEquals( "Tiene que dar error por tener orden navegacion repetido", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error es incorrecto 1", "La entidad CANADA tiene repetido el orden de navegación", .oMockInformacionIndividual.Item[1].cMensaje )
			
			update diccionario set ordenNavegacion = 2 where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "NUMERO"
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "No deberia tener problemas 2", 0, .oMockInformacionIndividual.Count )

			update diccionario set ordenNavegacion = 3 where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "DETALLECANADA"
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "Tiene que dar error por tener orden navegacion en un detalle", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error es incorrecto 2", "El atributo DETALLECANADA de la entidad CANADA tiene orden de navegación y es un detalle", .oMockInformacionIndividual.Item[1].cMensaje )
			
			update diccionario set ordenNavegacion = 0 where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "DETALLECANADA"
			update diccionario set ordenNavegacion = 3, tipoDato = "M" where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "PUNTODEVENTA"
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "Tiene que dar error por tener orden navegacion en un tipodato memo", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error es incorrecto 3", "El atributo PUNTODEVENTA de la entidad CANADA tiene orden de navegación en un campo memo", .oMockInformacionIndividual.Item[1].cMensaje )
			update diccionario set ordenNavegacion = 3, tipoDato = "N" where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "PUNTODEVENTA"
	
			update diccionario set ordenNavegacion = 1 where upper( alltrim( ENTIDAD ) ) == "ITEMCANADA" and upper( alltrim( atributo ) ) == "GOBERNADOR"
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "Tiene que dar error por tener orden navegacion en un item", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error es incorrecto 4", "El atributo GOBERNADOR del item ITEMCANADA tiene orden de navegación", .oMockInformacionIndividual.Item[1].cMensaje )

			update diccionario set ordenNavegacion = 0 where upper( alltrim( ENTIDAD ) ) == "ITEMCANADA" and upper( alltrim( atributo ) ) == "GOBERNADOR"
			update diccionario set ClavePrimaria = .t. where upper( alltrim( ENTIDAD ) ) == "CANADA" and upper( alltrim( atributo ) ) == "CODIGO"
			update diccionario set tipoDato = "G" where upper( alltrim( ENTIDAD ) ) == "CANADA" and claveprimaria
			update diccionario set ordenNavegacion = 0 where upper( alltrim( ENTIDAD ) ) == "CANADA"
			update entidad set formulario = .t. where upper( alltrim( ENTIDAD ) ) == "CANADA"

			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "Tiene que dar error por tener GUID y no tener orden de navegacion", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error es incorrecto 5", "La entidad CANADA tiene GUID y no tiene cargado un orden de navegación.", .oMockInformacionIndividual.Item[1].cMensaje )

			update diccionario set ordenNavegacion = 1 where upper( alltrim( ENTIDAD ) ) == "CANADA" and TipoDato = "G"
			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenNavegacion()
			This.AssertEquals( "Tiene que dar error por tener GUID y tener orden de navegacion en ese atributo", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error es incorrecto 5", "La entidad CANADA tiene asignado orden de navegación en el atributo de tipo GUID.", .oMockInformacionIndividual.Item[1].cMensaje )
					
			delete from diccionario
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarEsquema

		with this.oValidarAdn
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "Id", "RRHH", "PAISES", "Id" )
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "COLOMBIA", "Id", "VENTAS", "PAISES", "Id" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Una tabla no puede tener asignado más de un Esquema ( 1 )", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto ( 1 )", "La tabla [PAISES] en el diccionario tiene asignado más de un Esquema.", .oMockInformacionIndividual[ 1 ].cMensaje )
			
			update diccionario set Esquema = "RRHH" where upper( alltrim( entidad ) ) == "COLOMBIA"
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 1 )", 0, .oMockInformacionIndividual.count )
			
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "IdColonia", "RRHH", "COUNTRIES", "IdColonia" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 2 )", 0, .oMockInformacionIndividual.count )
			
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "IdContinente", "", "", "IdContinente" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 3 )", 0, .oMockInformacionIndividual.count )
			
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "COLOMBIA", "Nombre", "", "PAISES", "Nombre" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Una tabla no puede tener asignado más de un Esquema ( 2 )", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto ( 2 )", "La tabla [PAISES] en el diccionario tiene asignado más de un Esquema.", .oMockInformacionIndividual[ 1 ].cMensaje )

**** Para la Tabla Tablasinternas
			select tabla from TablasInternas where tabla = "PAISES" into cursor c_Cursor
			if _tally < 0 
				insert into Tablasinternas( Esquema, tabla, campo ) values ( "VENTAS", "PAISES", "Codigo" )
				insert into Tablasinternas( Esquema, tabla, campo ) values ( "RRHH", "PAISES", "Id" )
			endif 
			use in select( "c_Cursor" ) 
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Una tabla no puede tener asignado más de un Esquema ( 1 )", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto ( 1 )", "La tabla [PAISES] en el diccionario tiene asignado más de un Esquema.", .oMockInformacionIndividual[ 1 ].cMensaje )
			
			update diccionario set Esquema = "RRHH" where upper( alltrim( entidad ) ) == "COLOMBIA"
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 1 )", 0, .oMockInformacionIndividual.count )
			
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "IdColonia", "RRHH", "COUNTRIES", "IdColonia" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 2 )", 0, .oMockInformacionIndividual.count )
			
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "IdContinente", "", "", "IdContinente" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 3 )", 0, .oMockInformacionIndividual.count )
			
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "COLOMBIA", "Nombre", "", "PAISES", "Nombre" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Una tabla no puede tener asignado más de un Esquema ( 2 )", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto ( 2 )", "La tabla [PAISES] en el diccionario tiene asignado más de un Esquema.", .oMockInformacionIndividual[ 1 ].cMensaje )


		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarTablasInternasContraDiccionario

		with this.oValidarAdn
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "Id", "RRHH", "PAISES", "Id" )
			select tabla from TablasInternas where tabla = "PAISES" into cursor c_Cursor
			if _tally = 0 
				insert into Tablasinternas( Esquema, tabla, campo ) values ( "VENTAS", "PAISES", "ID" )
			endif 
			use in select( "c_Cursor" )  
						
			.oMockInformacionIndividual.Limpiar()
			.ValidarTablasInternasContraDiccionario()
			this.AssertEquals( "no puede haber tablas en comun entre el diccionario y tablasinternas", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto.", "La tabla [PAISES] en diccionario existe en tablasinternas.", .oMockInformacionIndividual[ 1 ].cMensaje )
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarNombreTablasConCampo

		with this.oValidarAdn
			insert into diccionario ( entidad, atributo, Esquema, tabla, campo ) values ( "JAMAICA", "PP", "RRHH", "PAISES", "PAISES" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarNombreTablasConCampo()
			this.AssertEquals( "El nombre del campo es igual a la tabla ( Entidad: JAMAICA Atributo: PP)", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto ( 1 )", "El nombre del campo es igual a la tabla ( Entidad: JAMAICA Atributo: PP)", .oMockInformacionIndividual[ 1 ].cMensaje )
			update diccionario set campo = "PP" where upper(Entidad )= "JAMAICA" and upper(tabla) = "PAISES"
			.oMockInformacionIndividual.Limpiar()
			.ValidarEsquemasTablas()
			this.AssertEquals( "Los datos del campo Esquema del diccionario son correctos ( 3 )", 0, .oMockInformacionIndividual.count )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarNombresDeCamposClavePrimaria
		with this.oValidarAdn
			.oMockInformacionIndividual.Limpiar()
			insert into entidad ( entidad, tipo, descripcion ) values ( "Luxemburgo", "E", "Descripcion de Luxemburgo" )

			insert into diccionario ( entidad, atributo, tipodato, dominio, campo, clavePrimaria ) values ( "Luxemburgo", "codigo", "N", "CODIGONUMERICO", "orden", .t. )
			insert into diccionario ( entidad, atributo, tipodato, dominio, campo ) values ( "Luxemburgo", "obs", "M", "OBSERVACION", "obs" )
			
			.ValidarNombresDeCamposClavePrimaria()
			this.AssertEquals( "La clave primaria no puede llamarse orden, si posee un atributo de tipo memo", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto (1)", ;
				"El atributo 'Codigo' de la entidad 'Descripcion De Luxemburgo' no puede tener como nombre de campo 'Orden' y ser clave primaria.", ;
				.oMockInformacionIndividual[1].cMensaje )

			.oMockInformacionIndividual.Limpiar()
			update diccionario set campo = "texto" where clavePrimaria
			.ValidarNombresDeCamposClavePrimaria()
			this.AssertEquals( "La clave primaria no puede llamarse texto, si posee un atributo de tipo memo", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto (2)", ;
				"El atributo 'Codigo' de la entidad 'Descripcion De Luxemburgo' no puede tener como nombre de campo 'Texto' y ser clave primaria.", ;
				.oMockInformacionIndividual[1].cMensaje )

			.oMockInformacionIndividual.Limpiar()
			update diccionario set campo = "id_memo" where clavePrimaria
			.ValidarNombresDeCamposClavePrimaria()
			this.AssertEquals( "La clave primaria no puede llamarse id_memo, si posee un atributo de tipo memo", 1, .oMockInformacionIndividual.count )
			this.AssertEquals( "El problema no es el correcto (3)", ;
				"El atributo 'Codigo' de la entidad 'Descripcion De Luxemburgo' no puede tener como nombre de campo 'Id_memo' y ser clave primaria.", ;
				.oMockInformacionIndividual[1].cMensaje )

			insert into entidad ( entidad, tipo, descripcion ) values ( "Luxemburgo2", "E", "Descripcion de Luxemburgo 2" )
			insert into entidad ( entidad, tipo, descripcion ) values ( "Luxemburg", "E", "Descripcion de Luxemburg" )
			insert into diccionario ( entidad, atributo, tipodato, dominio, campo, clavePrimaria ) values ( "Luxemburg", "codigo", "N", "CODIGONUMERICO", "orden", .t. )
			update diccionario set campo = "ordenPK" where clavePrimaria

			.oMockInformacionIndividual.Limpiar()
			.ValidarNombresDeCamposClavePrimaria()
			this.AssertEquals( "No debería haber problemas", 0, .oMockInformacionIndividual.count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarCaracteresEspeciales
		with this.oValidarADN
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR", "atribgen", "C", 0, 0,  "CMPPRUEBA" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCaracteresEspeciales()
			this.AssertEquals( "No debería haber problemas", 0, .oMockInformacionIndividual.count )

			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, campo ) ;
				values ( "RRR[", "atribgen", "C", 0, 0,  "CMPPRUEBA" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarCaracteresEspeciales()
			this.AssertEquals( "Es incorrecta la cantidad de errores.", 1, .oMockInformacionIndividual.count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarUnicidadIdPorListado
		local lcError as String
		
		insert into listcampos ( id, idFormato, Entidad, Atributo ) values ( 1, "1", "RRR", "atribgen1" )
		insert into listcampos ( id, idFormato, Entidad, Atributo ) values ( 2, "1", "RRR", "atribgen2" )
		insert into listcampos ( id, idFormato, Entidad, Atributo ) values ( 3, "1", "RRR", "atribgen3" )
		insert into listcampos ( id, idFormato, Entidad, Atributo ) values ( 1, "2", "RRR", "atribgen4" )

		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
		
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		loValidadorListado.ValidarUnicidadIdPorListado()
		This.assertequals( "No debe encontrar errores." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
	
		insert into listcampos ( id, idFormato, Entidad, Atributo ) values ( 1, "2", "RRR", "atribgen5" )
	
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		loValidadorListado.ValidarUnicidadIdPorListado()
		This.assertequals( "La cantidad de errores es incorrecta." , 1, This.oValidarADN.oMockInformacionIndividual.Count )

		lcError = "El identificador(ID) 1 se encuentra repetido en el listado 2."
		This.assertequals( "El mensaje de la valicadion es incorrecto.", lcError, This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarRelaTriggers
		local lcMensaje as String
	
		insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud ) values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud ) values ( "ENTIDADDESTINO", "ATRIBUTODESTINO", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud ) values ( "ENTIDADPRUEBA", "ATRIBUTOPRUEBA", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud ) values ( "ENTIDADDESTINO", "ATRIBUTODESTINOMAL", "N", 6 )
		insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud ) values ( "ENTIDADERRONEA", "ATRIBUTODESTINO", "C", 10 )

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion, Expresion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "INSERTAR", "#ENTIDADDESTINO.ATRIBUTODESTINO + 5" )
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "ACTUALIZAR" )
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion, Expresion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "ELIMINAR", "#ENTIDADDESTINO.ATRIBUTODESTINO + 9" )
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Relacion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", 1 )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "No debería encontrar errores (1)." , 0, This.oValidarADN.oMockInformacionIndividual.Count )


		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "ACCIONNODEFINIDA" )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (2)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (2)." , "El valor 'ACCIONNODEFINIDA' en el campo accion es incorrecto.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )
		delete from RelaTriggers where accion = "ACCIONNODEFINIDA"

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Relacion ) ;
			values ( "ENTIDADNOEXISTENTE", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", 1 )
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADNOEXISTENTE", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "INSERTAR" )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (3)." , 2, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (3)." , "La entidad/atributo origen de la tabla RelaTriggers (ENTIDADNOEXISTENTE.ATRIBUTOORIGEN) no existe en Diccionario.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )
		delete from RelaTriggers where entidad_origen = "ENTIDADNOEXISTENTE"

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTONOEXISTENTE", "ENTIDADDESTINO", "ATRIBUTODESTINO", "INSERTAR" )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (4)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (4)." , "La entidad/atributo origen de la tabla RelaTriggers (ENTIDADORIGEN.ATRIBUTONOEXISTENTE) no existe en Diccionario.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )
		delete from RelaTriggers where atributo_origen = "ATRIBUTONOEXISTENTE"

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADNOEXISTENTE", "ATRIBUTODESTINO", "INSERTAR" )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (5)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (5)." , "La entidad/atributo destino de la tabla RelaTriggers (ENTIDADNOEXISTENTE.ATRIBUTODESTINO) no existe en Diccionario.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )
		delete from RelaTriggers where entidad_destino = "ENTIDADNOEXISTENTE"

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTONOEXISTENTE", "INSERTAR" )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (6)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (6)." , "La entidad/atributo destino de la tabla RelaTriggers (ENTIDADDESTINO.ATRIBUTONOEXISTENTE) no existe en Diccionario.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )
		delete from RelaTriggers where atributo_destino = "ATRIBUTONOEXISTENTE"

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Relacion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", 1 )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (7)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (7)." , "El orden de búsqueda para la Entidad Origen (ENTIDADORIGEN) Entidad Destino (ENTIDADDESTINO) se encuentra repetido.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

		delete from RelaTriggers where recno()  = reccount()

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Relacion ) ;
			values ( "ENTIDADPRUEBA", "ATRIBUTOPRUEBA", "ENTIDADDESTINO", "ATRIBUTODESTINO", 1 )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()
		This.assertequals( "Debería encontrar errores (8)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (8)." , "No especifico acciones a efectuar en la entidad origen 'ENTIDADPRUEBA'.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

		delete from RelaTriggers where recno()  = reccount()

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion ) ;
			values ( "ENTIDADPRUEBA", "ATRIBUTOPRUEBA", "ENTIDADDESTINO", "ATRIBUTODESTINO", "INSERTAR" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()

		This.assertequals( "Debería encontrar errores (9)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.assertequals( "Mensaje de error incorrecto (9)." , "No especifico relaciones en la entidad origen 'ENTIDADPRUEBA'.", ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

		delete from RelaTriggers where recno()  = reccount()

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Relacion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINOMAL", 2 )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()

		This.assertequals( "Debería encontrar errores (10)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		lcMensaje = "El tipo de datos/longitud de origen 'ENTIDADORIGEN.ATRIBUTOORIGEN' difiere en diccionario " + ;
					"del destino 'ENTIDADDESTINO.ATRIBUTODESTINOMAL'."
					
		This.assertequals( "Mensaje de error incorrecto (10)." , lcMensaje, ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

		delete from RelaTriggers where recno()  = reccount()
		
		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion, Expresion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "INSERTAR", "#ENTIDADERRONEA.ATRIBUTODESTINO + 1" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()

		This.assertequals( "Debería encontrar errores (11)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		lcMensaje = "La Entidad 'ENTIDADERRONEA' de la Expresion no tiene una relación en RelaTriggers."

		This.assertequals( "Mensaje de error incorrecto (11)." , lcMensaje, ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

		delete from RelaTriggers where recno()  = reccount()

		*--
		insert into RelaTriggers ( Entidad_Origen, Atributo_Origen, Entidad_Destino, Atributo_Destino, Accion, Expresion ) ;
			values ( "ENTIDADORIGEN", "ATRIBUTOORIGEN", "ENTIDADDESTINO", "ATRIBUTODESTINO", "INSERTAR", "#ENTIDADDESTINO.ATRIBUTOERRONEO + 1" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarRelaTriggers()

		This.assertequals( "Debería encontrar errores (12)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		lcMensaje = "El Atributo 'ATRIBUTOERRONEO' de la Expresion no existe en Diccionario para la Entidad ENTIDADDESTINO."

		This.assertequals( "Mensaje de error incorrecto (12)." , lcMensaje, ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

		delete from RelaTriggers where recno()  = reccount()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarClavePrimariaVisibles

		*-- Caso 1 anda todo bien
		insert into Diccionario ( Entidad, Atributo, ClavePrimaria, Alta ) values ( "ENTIDAD", "Clave_Primaria", .T., .T. )
		insert into Diccionario ( Entidad, Atributo, ClavePrimaria, Alta ) values ( "ENTIDAD", "Descripcion", .F., .T. )

		insert into Diccionario ( Entidad, Atributo, ClavePrimaria, Alta ) values ( "ITEMENTIDAD", "Clave_Primaria", .T., .T. )
		insert into Diccionario ( Entidad, Atributo, ClavePrimaria, Alta ) values ( "ITEMENTIDAD", "Descripcion", .F., .T. )
		insert into Diccionario ( Entidad, Atributo, ClavePrimaria, Alta, ClaveForanea ) values ( "ITEMENTIDAD", "Clave_foranea", .F., .T., "ENTIDAD" )
		
		insert into Diccionario ( Entidad, Atributo, Dominio, Alta ) values ( "ENTIDADX", "Clave_Primaria", "", .T. )
		insert into Diccionario ( Entidad, Atributo, Dominio, Alta ) values ( "ENTIDADX", "AtributoDetalle", "DETALLEITEMENTIDAD", .T. )
		
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarClavePrimariaVisibles()
		This.assertequals( "No debería encontrar Errores(1)." , 0, This.oValidarADN.oMockInformacionIndividual.Count )

		*-- Caso 2 Pincha
 		update Diccionario set Alta = .F. where upper( alltrim( Entidad ) ) == "ENTIDAD" and upper( alltrim( Atributo ) ) == "CLAVE_PRIMARIA"
	
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarClavePrimariaVisibles()
		This.assertequals( "Debería encontrar errores(2)." , 1, This.oValidarADN.oMockInformacionIndividual.Count )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarClavePrimariaVisibles()
		lcMensaje = "El atributo 'CLAVE_PRIMARIA' de la entidad 'ENTIDAD' debe ser visible ya que es clave foranea visible en la entidad 'ITEMENTIDAD'."
		This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestValidarDominioCodigoConBusqueda
	
		*--
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Alta, Dominio, ClavePrimaria, Alta, BusquedaOrdenamiento ) ;
						values ( "Entidad1", "Atributo1", "C", .T., "Codigo", .T., .T. , .T. )
				
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarDominioCodigo()
		This.assertequals( "No debería encontrar errores." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
		
		*-- 
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Alta, Dominio, ClavePrimaria, Alta, BusquedaOrdenamiento ) ;
						values ( "Entidad1", "Atributo1", "N", .T., "Codigo", .T., .T. , .T. )
				
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarDominioCodigo()
		This.assertequals( "Debería encontrar errores." , 1, This.oValidarADN.oMockInformacionIndividual.Count )

		lcMensaje = "Para que el atributo ATRIBUTO1 de la entidad ENTIDAD1 tenga comportamiento CODIGO y busqueda, el tipo de dato del mismo no debe ser numerico."
		This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
							This.oValidarADN.oMockInformacionIndividual.item[ 1 ].cMensaje )

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestValidarBuscadorId

		Insert into BuscadorDetalle ( id_Buscador, Entidad ) values ( 1 , "Entidad 1" )
		This.oValidarADN.ValidarIdBuscadorDetalleEnBuscador()

		This.assertequals( "El Bucador 1 no deberia tener Definido el ID en Buscador." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		Insert into Buscador ( id, descripcion ) values ( 1 , "Descrip 1" )

		This.oValidarADN.ValidarIdBuscadorDetalleEnBuscador()

		This.assertequals( "El Bucador 1 deberia tener Atributos en BuscadorDetalle." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		Insert into Buscador ( id, descripcion ) values ( 2 , "Descrip 1" )
		This.oValidarADN.ValidarIdBuscadorDetalleEnBuscador()

		This.assertequals( "El Bucador 2 no deberia tener Atributos en BuscadorDetalle." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		Insert into BuscadorDetalle ( id_Buscador, Atributo ) values ( 2 , "Atributo 2" )
		This.oValidarADN.ValidarIdBuscadorDetalleEnBuscador()

		This.assertequals( "El Bucador 2 deberia tener Atributos en BuscadorDetalle." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestValidarBuscadorEntidad

		Insert into Buscador ( id, descripcion ) values ( 1 , "Descrip 1" )
		Insert into BuscadorDetalle ( id_Buscador, Entidad ) values ( 1 , "Entidad" )

		This.oValidarADN.ValidarEntidadEnBuscador()

		This.assertequals( "El Bucador 1 Deberia tener cargado una entidad no válida." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		Insert into Entidad ( Entidad ) values ( "Entidad" )

		This.oValidarADN.ValidarEntidadEnBuscador()

		This.assertequals( "El Bucador 1 Deberia tener cargado una entidad válida." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()


	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestValidarBuscadorAtributo
		Insert into Buscador ( id, descripcion ) values ( 1 , "Descrip 1" )
		Insert into BuscadorDetalle ( id_Buscador, Entidad, Atributo ) values ( 1 , "Entidad", "Atributo NNN" )
		
		This.oValidarADN.ValidarAtributoEnBuscador()
		This.assertequals( "El Bucador 1 Deberia tener cargado un atributo existente." , 1, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		insert into AtributosGenericos ( Atributo ) values ( "Atributo NNN" )

		This.oValidarADN.ValidarAtributoEnBuscador()
		This.assertequals( "El Bucador 1 Deberia tener cargado un atributo válido en Genericos." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()

		Insert into BuscadorDetalle ( id_Buscador, Entidad, Atributo ) values ( 1 , "Entidad", "Atributo DDD" )
		insert into Diccionario ( Entidad, Atributo ) values ( "Entidad", "Atributo DDD" )

		This.oValidarADN.ValidarAtributoEnBuscador()
		This.assertequals( "El Bucador 1 Deberia tener cargado un atributo válido en Diccionario." , 0, This.oValidarADN.oMockInformacionIndividual.Count )
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarAtribHerRecPrecios_ValCombinacion
		local i as Integer
		*--Articulo
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClavePrimaria ) ;
						values ( "articulo", "Codigo", "C", 13, .T., "Codigo", .T. )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "articulo", "Honduras", "C", 13, .T., "Codigo", "HONDURAS" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "articulo", "CUBA", "C", 10, .T., "Codigo", "CUBA" )

		*--PrecioDeArticulo
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveCandidata ) ;
						values ( "PrecioDeArticulo", "Articulo", "C", 13, .F., "Codigo", 2 )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveCandidata ) ;
						values ( "PrecioDeArticulo", "Color", "C", 2, .F., "Codigo", 3 )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveCandidata ) ;
						values ( "PrecioDeArticulo", "Talle", "C", 3, .F., "Caracter", 4 )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveCandidata ) ;
						values ( "PrecioDeArticulo", "ListaDePrecio", "C", 6, .F., "Codigo", 1 )
				
		*-- CalculoDePrecios (ex HerCalcListasDePrecios)
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClavePrimaria ) ;
						values ( "CalculoDePrecios", "Codigo", "N", 16, .T., "CodigoNumerico", .T. )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarAtributosObligatoriosDeCalculoDePrecios()
		This.assertequals( "Debería encontrar errores. Faltan atributos." , 10, This.oValidarADN.oMockInformacionIndividual.Count )

		i = 0
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_articulo_cuba_desde'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_articulo_cuba_hasta'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_articulo_honduras_desde'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_articulo_honduras_hasta'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_articulo_desde'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_articulo_hasta'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_color_desde'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_color_hasta'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_talle_desde'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_talle_hasta'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif

		*--CalculoDePrecios CORRECTOS
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Honduras_Desde", "C", 13, .t., "EtiquetaCaracterDesdeHastaBusc", "Honduras" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorsugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Honduras_Hasta", "C", 13, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 13 ), "Honduras" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Cuba_Desde", "C", 10, .t., "EtiquetaCaracterDesdeHastaBusc", "Cuba" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorsugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Cuba_Hasta", "C", 10, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 10 ),"Cuba" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorsugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Talle_Hasta", "C", 3, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 3 ) , "Cuba")

		*--CalculoDePrecios CON PROBLEMAS
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Articulo_Desde", "C", 10, .t., "EtiquetaCaracterDesdeHastaBusc", "Articulo" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorsugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Color_Desde", "C", 2, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 2 ), "Color" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorsugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Articulo_Hasta", "C", 13, .f., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 3 ), "Articulo" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Color_Desde", "D", 2, .t., "EtiquetaCaracterDesdeHastaBusc", "Color" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Talle_Desde", "C", 3, .t., "Caracter", "Talle" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarAtributosObligatoriosDeCalculoDePrecios() 
		This.assertequals( "Debería encontrar errores. Hay problemas con las características de los atributos" , 5, This.oValidarADN.oMockInformacionIndividual.Count )

		i = 0
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la longitud del atributo 'f_articulo_desde' de la entidad 'cálculo de precios' debe ser de 13."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el atributo 'f_articulo_hasta' de la entidad 'cálculo de precios' debe ser visible."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el valor sugerido del atributo 'f_articulo_hasta' de la entidad 'cálculo de precios' debe ser 'zzzzzzzzzzzzz'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la entidad 'cálculo de precios' debe poseer el atributo 'f_color_hasta'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1 
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el dominio del atributo 'f_talle_desde' de la entidad 'cálculo de precios' debe ser 'etiquetacaracterdesdehastabusc'."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif

		delete from diccionario where entidad == "CalculoDePrecios"
		*--CalculoDePrecios CORRECTA
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClavePrimaria ) ;
						values ( "CalculoDePrecios", "Codigo", "N", 16, .T., "CodigoNumerico", .T. )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Articulo_Desde", "C", 13, .t., "EtiquetaCaracterDesdeHastaBusc", "Articulo" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorSugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Articulo_Hasta", "C", 13, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 13 ), "Articulo" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Color_Desde", "C", 2, .t., "EtiquetaCaracterDesdeHastaBusc", "Color" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorSugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Color_Hasta", "C", 2, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 2 ), "Color" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Talle_Desde", "C", 3, .t., "EtiquetaCaracterDesdeHastaBusc", "Talle" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorSugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_Talle_Hasta", "C", 3, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 3 ), "Talle" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Honduras_Desde", "C", 13, .t., "EtiquetaCaracterDesdeHastaBusc", "Honduras" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorSugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Honduras_Hasta", "C", 13, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 13 ), "Honduras" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Cuba_Desde", "C", 10, .t., "EtiquetaCaracterDesdeHastaBusc", "Cuba" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, valorSugerido, ClaveForanea ) ;
						values ( "CalculoDePrecios", "f_articulo_Cuba_Hasta", "C", 10, .t., "EtiquetaCaracterDesdeHastaBusc", replicate( "Z", 10 ), "Cuba" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarAtributosObligatoriosDeCalculoDePrecios()		
		This.assertequals( "NO Debería encontrar errores." , 0, This.oValidarADN.oMockInformacionIndividual.Count )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarFuncionalidadImportacion
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent1_sin_detalle" , "E", "" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent2_sin_detalle" , "E", "<NOIMPO>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent3_sin_detalle" , "E", "<HABILITARIMPOINSEGURA>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent4_sin_detalle" , "E", "<NOIMPO><HABILITARIMPOINSEGURA>" )
						
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent1_con_detalle" , "E", "<NOIMPO>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent2_con_detalle" , "E", "" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent3_con_detalle" , "E", "<NOIMPO><HABILITARIMPOINSEGURA><IMPOSEGURACONCORTE>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent4_con_detalle" , "E", "<HABILITARIMPOINSEGURA>" )
						
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent1_sin_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent2_sin_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent3_sin_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent4_sin_detalle" , "codigo", "caracter" )

		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent1_con_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent1_con_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent2_con_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent2_con_detalle" , "codigo", "caracter" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent3_con_detalle" , "detalle", "detalle" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent3_con_detalle" , "detalle", "detalle" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent4_con_detalle" , "detalle", "detalle" )
		Insert into diccionario ( entidad, atributo, dominio ) values ( "ent4_con_detalle" , "detalle", "detalle" )
						
		Insert into dominio ( dominio, detalle ) values ( "caracter" , .f. )
		Insert into dominio ( dominio, detalle ) values ( "detalle" , .t. )
		
		This.oValidarADN.ValidarFuncionalidadImportacion()

		This.assertequals( "La cantidad de mensajes de error es incorrecta. " + ;
			"Debería dar error la validacion ya que la entidad ent4_con_detalle tiene funcionalidad importacion sin validaciones",;
			 4, This.oValidarADN.oMockInformacionIndividual.Count )

		This.assertequals( "El mensaje de error es incorrexcto. " + ;
			"Debería dar error la validacion ya que la entidad ent3_con_detalle tiene funcionalidad importacion sin validaciones" ,;
			"La entidad ent3_con_detalle no se puede importar sin validaciones debido a que tiene atributos de tipo detalle.", This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cmensaje )

		This.assertequals( "El mensaje de error es incorrexcto. " + ;
			"Debería dar error la validacion ya que la entidad ent4_con_detalle tiene funcionalidad importacion sin validaciones" ,;
			 "La entidad ent4_con_detalle no se puede importar sin validaciones debido a que tiene atributos de tipo detalle.", This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cmensaje )
		This.assertequals( "El mensaje de error es incorrexcto. " + ;
			"Debería dar error la validacion ya que la entidad ent4_Sin_detalle tiene funcionalidad importacion sin validaciones" ,;
			"La entidad ent4_sin_detalle no debe tener la funcionalidad <NOIMPO> para poder tener la funcionalidad de IMPORTACIONES SIN VALIDACIONES.", This.oValidarADN.oMockInformacionIndividual.Item[ 3 ].cmensaje )

		This.assertequals( "El mensaje de error es incorrexcto. " + ;
			"Debería dar error la validacion ya que la entidad ent3_Con_detalle tiene funcionalidad importacion sin validaciones" ,;
			 "La entidad ent3_con_detalle no debe tener la funcionalidad <NOIMPO> para poder tener la funcionalidad de IMPORTACIONES SIN VALIDACIONES.", This.oValidarADN.oMockInformacionIndividual.Item[ 4 ].cmensaje )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarFuncionalidadEntidadNoEditableYBloquearRegistro
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent1_sin_nada" , "E", "" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent2_bien" , "E", "<NOIMPO><BLOQUEARREGISTRO>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent3_bien" , "E", "<NOIMPO><ENTIDADNOEDITABLE>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent4_bien" , "E", "<HABILITARIMPOINSEGURA><BLOQUEARREGISTRO>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent1_mal" , "E", "<BLOQUEARREGISTRO>" )
		Insert into entidad ( entidad, tipo, funcionalidades) values ( "ent2_mal" , "E", "<ENTIDADNOEDITABLE><ANULABLE>" )
	
		This.oValidarADN.ValidarFuncionalidadEntidadNoEditableYBloquearRegistro()

		This.assertequals( "La cantidad de mensajes de error es incorrecta. ",;
			 2, This.oValidarADN.oMockInformacionIndividual.Count )

		This.assertequals( "El mensaje de error es incorrecto.(1) ",;
			"La entidad ent1_mal no puede tener la funcionalidades <ENTIDADNOEDITABLE> y/o <BLOQUEARREGISTRO> si, además, no contiene la funcionalidad <NOIMPO> y/o contiene las funcionalidades <ANULABLE>.", This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cmensaje )

		This.assertequals( "El mensaje de error es incorrecto.(2) " ,;
			 "La entidad ent2_mal no puede tener la funcionalidades <ENTIDADNOEDITABLE> y/o <BLOQUEARREGISTRO> si, además, no contiene la funcionalidad <NOIMPO> y/o contiene las funcionalidades <ANULABLE>.", This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cmensaje )
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function zTestValidarTags
		local i as Integer
		select * from Diccionario into cursor diccionario readwrite
		*--Equivalencia
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, Tags ) ;
						values ( "Equivalencia", "Codigo", "C", 6, .t., "Codigo", "" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, Tags ) ;
						values ( "Equivalencia", "Articulo", "C", 13, .t., "Codigo", "combinacion" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, Tags ) ;
						values ( "Equivalencia", "Color", "C", 2, .t., "Codigo", "<combinacion2" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, Tags ) ;
						values ( "Equivalencia", "Talle", "C", 3, .t., "Caracter", "<Combinacion03" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, Tags ) ;
						values ( "Equivalencia", "Grupo", "C", 3, .t., "Caracter", "<Combinacino04>" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Alta, Dominio, Tags ) ;
						values ( "Equivalencia", "Rubro", "C", 3, .t., "Caracter", "<Combinacion05>" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarTags()
		This.assertequals( "Debería encontrar errores." , 7, This.oValidarADN.oMockInformacionIndividual.Count )
		i = 0
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'grupo' de la entidad 'equivalencia' esta mal ingresado; '<combinacino04>' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'talle' de la entidad 'equivalencia' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'color' de la entidad 'equivalencia' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'articulo' de la entidad 'equivalencia' esta mal ingresado; combinacion99 debe ser el primer tag."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'articulo' de la entidad 'equivalencia' esta mal ingresado; el tag combinacion debe estar seguido de dos dígitos que indican el orden (01->99)."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'articulo' de la entidad 'equivalencia' esta mal ingresado; debe comenzar con el signo <."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'articulo' de la entidad 'equivalencia' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'grupo' de la entidad 'equivalencia' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'grupo' de la entidad 'equivalencia' esta mal ingresado; 'combinacino' no es un tag válido"
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
	endfunc


	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarFuncionalidadesListCampos
	
		local i as Integer
		
		
		select * from ListCampos into cursor ListCampos readwrite
		select * from ListCampos into cursor cListCampos readwrite
		select * from diccionario into cursor diccionario readwrite
		
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<noexiste>", "43" )		
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades , idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "desdesugerido", "43" )
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<desdesugerido", "43" )
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "desdesugerido>" , "43" )	
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<>" , "43" )
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades , idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<:213123>", "43" )
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<desdesugerido><hastasugerido>" , "43" )	
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<desdesugerido>; ", "43" )
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<desdesugerido> , <hastasugerido>" , "43" )	
		Insert into Diccionario ( Entidad, Atributo, TipoDato, longitud, Decimales ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 9, 2 )										
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "C", 10, 0, "<desdesugerido:-999999.99>" , "43" )		
						
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "", 5, 2, "<desdesugerido:-999999.99>" , "43" )


		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "", 0, 0, "<desdesugerido:-99999.99>", "43" )											

		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "", 15, 3, "<desdesugerido:-999999.99>" , "43" )
	
		local loValidadorListado as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		loValidadorListado = This.oValidarADN.TEST_ObtenerOValidarAdnListadosOrganic()
			
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		loValidadorListado.ValidarFuncionalidadesListCampos()
		
		This.assertequals( "Debería encontrar errores." ,14 , This.oValidarADN.oMockInformacionIndividual.Count )
		i = 0
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; '<noexiste>' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; debe comenzar con el signo <."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1].cMensaje ) )
		endif
		
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1].cMensaje ) )
		endif		
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; debe comenzar con el signo <."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1].cMensaje ) )
		endif		
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; '<>' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; '<:213123>' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; '<desdesugerido><hastasugerido>' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; debe comenzar con el signo <."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; debe finalizar con el signo >."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; '' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tag del atributo 'cantidad' de la entidad 'stockcombinacion' esta mal ingresado; '<desdesugerido> , <hastasugerido>' no es un tag válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el tipo de dato del atributo cantidad del listado 43 del adn listcampos para la funcionalidad desdesugerido debe ser igual al del adn diccionario."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif		
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "el valor para la funcionalidad desdesugerido del atributo cantidad del listado 43 del adn listcampos no puede ser mayor a la longitud y decimales del atributo del adn diccionario ni del adn listcampos."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif	
		i = i + 1	
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "ADN válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		 i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "ADN válido."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif

		use in select("Listcampos")
	  	select * from clistcampos into cursor listcampos readwrite
		
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades, idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<desdesugerido:>" , "43" )	
		Insert into ListCampos ( Entidad, Atributo, TipoDato, longitud, Decimales, Funcionalidades , idformato ) ;
						values ( "Stockcombinacion", "Cantidad", "N", 10, 2, "<novacios:89875>", "43" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		loValidadorListado.ValidarValorEnFuncionalidadesListCampos()
		This.assertequals( "Debería encontrar errores." ,2 , This.oValidarADN.oMockInformacionIndividual.Count )
		i = 0						
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la funcionalidad desdesugerido del atributo cantidad del listado 43 del adn listcampos debe tener un valor cargado."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif
		i = i + 1
		if This.oValidarADN.oMockInformacionIndividual.Count > i
			lcMensaje = "la funcionalidad novacios del atributo cantidad del listado 43 del adn listcampos no debe tener un valor cargado."
			This.assertequals( "Mensaje de error incorrecto." , lcMensaje, ;
								lower( This.oValidarADN.oMockInformacionIndividual.item[ i + 1 ].cMensaje ) )
		endif		
		use in select("clistcampos")
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarTagCondicionSummarizado
		local lcMensaje as String
		*!* Atributos válidos.
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "A", "X", "N", 1, "Numerico", "", "" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "B", "X", "N", 1, "Numerico", "X", "" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "E", "X", "N", 1, "Numerico", "X", "<CONDICIONSUMARIZAR:W>" )

		*!* Atributos no válidos.
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "B", "V", "N", 1, "Numerico", "V", "<CONDICIONSUMARIZAR:W><CONDICIONSUMARIZAR:U>" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "C", "W", "N", 1, "Numerico", "", "<CONDICIONSUMARIZAR:W>" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "D", "X", "N", 1, "Numerico", "X", "<CONDICIONSUMARIZAR>" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "E", "Y", "N", 1, "Numerico", "Y", "<CONDICIONSUMARIZAR:>" )
		Insert into Diccionario ( Entidad, Atributo, TipoDato, Longitud, Dominio, Sumarizar, Tags ) ;
						values ( "F", "Z", "N", 1, "Numerico", "Z", "<CONDICIONSUMARIZAR:W:>" )

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarTags()

		This.AssertEquals( "Debería encontrar errores.", 5, This.oValidarADN.oMockInformacionIndividual.Count )

		lcMensaje = "Entidad: [B] Atributo: [V] - Tiene especificado más de un tag <CONDICIONSUMARIZAR>."
		This.AssertEquals( "Mensaje de error incorrecto (1).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )

		lcMensaje = "Entidad: [C] Atributo: [W] - Tiene especificado el tag <CONDICIONSUMARIZAR> para un atributo que no se sumariza."
		This.AssertEquals( "Mensaje de error incorrecto (2).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cMensaje )
		
		lcMensaje = "Entidad: [D] Atributo: [X] - No se especificó la condición a evaluar para el tag <CONDICIONSUMARIZAR>."
		This.AssertEquals( "Mensaje de error incorrecto (3).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 3 ].cMensaje )
		
		lcMensaje = "Entidad: [E] Atributo: [Y] - No se especificó la condición a evaluar para el tag <CONDICIONSUMARIZAR>."
		This.AssertEquals( "Mensaje de error incorrecto (4).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 4 ].cMensaje )

		lcMensaje = "Entidad: [F] Atributo: [Z] - El tag <CONDICIONSUMARIZAR> no puede poseer más de un carácter [:]."
		This.AssertEquals( "Mensaje de error incorrecto (5).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 5 ].cMensaje )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarCopiaTablasEntreSucursales
		Insert into entidad ( entidad, comportamiento, ubicaciondb ) values ( "ent_nocopia" , "ABC", "" )	
		Insert into entidad ( entidad, comportamiento, ubicaciondb ) values ( "ent_bien" , "ABCW", "" )
		Insert into entidad ( entidad, comportamiento, ubicaciondb ) values ( "ent_sin_tags" , "ABCW", "" )
		Insert into entidad ( entidad, comportamiento, ubicaciondb ) values ( "ent_nocopia_contags" , "ABC", "" )
		Insert into entidad ( entidad, comportamiento, ubicaciondb ) values ( "ent_copia_nosuc" , "ABCW", "PUESTO" )
						
		Insert into diccionario ( entidad, atributo, tags ) values ( "ent_nocopia" , "codigo", "" )
		Insert into diccionario ( entidad, atributo, tags ) values ( "ent_bien" , "codigo", "<pepe>;<NOCOPIAR>" )		
		Insert into diccionario ( entidad, atributo, tags ) values ( "ent_sin_tags" , "codigo", "<pepe>" )				
		Insert into diccionario ( entidad, atributo, tags ) values ( "ent_nocopia_contags" , "codigo", "<pepe>;<NOCOPIAR>" )				
		Insert into diccionario ( entidad, atributo, tags ) values ( "ent_copia_nosuc" , "codigo", "<pepe>;<NOCOPIAR>" )
		
		This.oValidarADN.ValidarCopiaTablasEntreSucursales()	

		This.assertequals( "La cantidad de mensajes de error es incorrecta. ",;
			 2, This.oValidarADN.oMockInformacionIndividual.Count )	
			 
		This.assertequals( "El mensaje de error es incorrecto. " + ;
			"Debería dar error la validacion en la ya que la entidad ent_nocopia_contags no tiene comportamineto 'W' pero si el tag 'NOCOPIAR'" ,;
			"El atributo: codigo de la entidad: ent_nocopia_contags tiene el tag NOCOPIAR pero no tiene comportamiento 'W'", This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cmensaje )

		This.assertequals( "El mensaje de error es incorrecto. " + ;
			"Debería dar error la validacion en la ya que la entidad ent_copia_nosuc tiene comportamineto 'W' pero no es entidad de sucursal" ,;
			"La entidad: ent_copia_nosuc tiene comportamiento 'W' y no es de sucursal.", This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cmensaje )
	endfunc 

	*-----------------------------------				
	function zTestValidarOrdenEnDominioDireccion

		with This.oValidarADN

			insert into Entidad ( Entidad ) values ( "Clientillo" )
			
			insert into Diccionario ( Entidad, Atributo, dominio, Orden ) ;
				values ( "Clientillo", "Calle", "DIRECCION", 4 )
			insert into Diccionario ( Entidad, Atributo, dominio, Orden ) ;
				values ( "Clientillo", "Numero", "DIRECCION", 5 )
			insert into Diccionario ( Entidad, Atributo, dominio, Orden ) ;
				values ( "Clientillo", "Piso", "DIRECCION", 6 )
			insert into Diccionario ( Entidad, Atributo, dominio, Orden ) ;
				values ( "Clientillo", "Departamento", "DIRECCION", 7 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarOrdenEnDominioDireccion()	
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"Falló al Validar el Orden de los Atributos para el Dominio Direccion" ), 0, .oMockInformacionIndividual.Count )	
		endwith
	endfunc	

	*-----------------------------------------------------------------------------------------
	function zTestValidarDominioParaCampoGUID

		with This.oValidarADN
		
			insert into diccionario( Entidad, Atributo, TipoDato, Dominio )	Values( "Entidad", "Atributo1", "G", "CODIGO" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioParaCampoGUID()
			This.AssertEquals( "No deberia pinchar, es un dominio valido.", 0, .oMockInformacionIndividual.Count )	

			insert into diccionario( Entidad, Atributo, TipoDato, Dominio )	Values( "Entidad", "Atributo2", "C", "CODIGO" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioParaCampoGUID()
			This.AssertEquals( "No deberia pinchar, es un TipoDato GUID.", 0, .oMockInformacionIndividual.Count )	
			
			insert into diccionario( Entidad, Atributo, TipoDato, Dominio )	Values( "Entidad", "Atributo2", "G", "CODIGONUMERICO" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarDominioParaCampoGUID()
			This.assertequals( "El mensaje de error es incorrecto. ", "El Atributo 'ATRIBUTO2' de la entidad 'ENTIDAD' es tipo GUID y no puede tener el dominio 'CODIGONUMERICO'." ;
									,.oMockInformacionIndividual.Item[ 1 ].cmensaje )

						
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarCoherencia_De_SubEntidades

		with This.oValidarADN
		
			insert into Entidad( Entidad,Tipo, UbicacionDB ) values ( "E1S", "E", "SUCURSAL" )
			insert into Entidad( Entidad,Tipo, UbicacionDB ) values ( "E2S", "E", "SUCURSAL" )
			insert into Entidad( Entidad,Tipo, UbicacionDB ) values ( "E1P", "E", "PUESTO" )
			insert into Entidad( Entidad,Tipo, UbicacionDB ) values ( "E2P", "E", "PUESTO" )			
			insert into Entidad( Entidad,Tipo, UbicacionDB ) values ( "E1O", "E", "ORGANIZACION" )
			insert into Entidad( Entidad,Tipo, UbicacionDB ) values ( "E2O", "E", "ORGANIZACION" )
			
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1S","A1", "E2S" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1S","A2", "E1O" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1S","A3", "E1P" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1P","A4", "E2P" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1P","A5", "E1O" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1P","A6", "E1S" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1O","A7", "E2O" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1O","A8", "E1P" )
			insert into diccionario( Entidad, Atributo, ClaveForanea ) Values( "E1O","A9", "E1S" )
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCoherencia_De_SubEntidades()
			This.AssertEquals( "Cantidad De Errores Incorrectos", 5, .oMockInformacionIndividual.Count )	
			This.assertequals( "El mensaje de error 1 es incorrecto. ", "El Atributo A3 de la entidad E1s tiene como clave foranea una entidad cuya Ubicación no es Sucursal o de Organización" ,.oMockInformacionIndividual.Item[ 1 ].cmensaje )
			This.assertequals( "El mensaje de error 2 es incorrecto. ", "El Atributo A6 de la entidad E1p tiene como clave foranea una entidad cuya Ubicación no es Puesto o de Organización" ,.oMockInformacionIndividual.Item[ 2 ].cmensaje )
			This.assertequals( "El mensaje de error 3 es incorrecto. ", "El Atributo A8 de la entidad E1o tiene como clave foranea una entidad cuya Ubicación no es Organizacion" ,.oMockInformacionIndividual.Item[ 3 ].cmensaje )
			This.assertequals( "El mensaje de error 4 es incorrecto. ", "El Atributo A9 de la entidad E1o tiene como clave foranea una entidad cuya Ubicación no es Organizacion" ,.oMockInformacionIndividual.Item[ 4 ].cmensaje )
			This.assertequals( "El mensaje de error 5 es incorrecto. ", "Falló validar coherencia de ubicacion de base de datos de subentidades" ,.oMockInformacionIndividual.Item[ 5 ].cmensaje )

			delete from Diccionario where .T.
			insert into diccionario( Entidad, ClaveForanea ) Values( "E1S", "E2S" )
			insert into diccionario( Entidad, ClaveForanea ) Values( "E1S", "E1O" )
			insert into diccionario( Entidad, ClaveForanea ) Values( "E1P", "E2P" )
			insert into diccionario( Entidad, ClaveForanea ) Values( "E1P", "E1O" )
			insert into diccionario( Entidad, ClaveForanea ) Values( "E1O", "E2O" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCoherencia_De_SubEntidades()
						
			This.AssertEquals( "Deberia validar bien", 0, .oMockInformacionIndividual.Count )	

		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarEntidadAtributosTransferenciaAgrupada 
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		
			insert into transferenciasagrupadas ( id, Descripcion) values ( 1, "Agrup1" )
			insert into transferenciasagrupadasItems ( id, entidad) values ( 1, "ENTIDAD" )

			.ValidarEntidadAtributosTransferenciaAgrupada()
			
			This.AssertEquals( "Cantidad De Errores Incorrectos. Debe dar error ya que la entidad no existe", 1, .oMockInformacionIndividual.Count )	
			This.assertequals( "El mensaje de error 1 es incorrecto. Debe dar error ya que la entidad no existe", ;
				 "No Existe la Entidad/Transferencia adicional ENTIDAD Indicada en la Transferencia Agrupada AGRUP1" ,.oMockInformacionIndividual.Item[ 1 ].cmensaje )

			*******************
			.oMockInformacionIndividual.Limpiar()

			insert into Entidad( Entidad,Tipo ) values ( "ENTIDAD", "E" )
			
			.ValidarFiltrosParaTransferenciasAgrupadas()
			
			This.AssertEquals( "No debe dar error ya que la entidad fue carada", 0, .oMockInformacionIndividual.Count )	

			*******************
			.oMockInformacionIndividual.Limpiar()

			insert into transferenciasagrupadasItems ( id, entidad) values ( 1, "ADICIONAL" )
			
			.ValidarEntidadAtributosTransferenciaAgrupada()
			
			This.AssertEquals( "Cantidad De Errores Incorrectos. Debe dar error ya que la transferencia adicional no existe", 1, .oMockInformacionIndividual.Count )	
			This.assertequals( "El mensaje de error 1 es incorrecto. Debe dar error ya que la transferencia adicional no existe", ;
				 "No Existe la Entidad/Transferencia adicional ADICIONAL Indicada en la Transferencia Agrupada AGRUP1" ,.oMockInformacionIndividual.Item[ 1 ].cmensaje )

			*******************
			.oMockInformacionIndividual.Limpiar()
			
			insert into Transferencias( Entidad, Codigo ) values ( "OTRAENTIDAD", "ADICIONAL" )
			
			.ValidarEntidadAtributosTransferenciaAgrupada()
			
			This.AssertEquals( "No debe dar error ya que la transferencia adicional fue carada", 0, .oMockInformacionIndividual.Count )	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarDetallesObligatorios
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			insert into diccionario( Entidad, Atributo, Dominio ) Values( "Entidad1","Atributo1", "TEXTO" )

			.ValidarDetallesObligatorios()
			This.AssertEquals( "Cantidad De Errores Incorrectos(1).", 0, .oMockInformacionIndividual.Count )
			
			insert into diccionario( Entidad, Atributo, Dominio ) Values( "Entidad1","Atributo2", "DETALLEPETER" )

			.ValidarDetallesObligatorios()
			This.AssertEquals( "Cantidad De Errores Incorrectos(2).", 0, .oMockInformacionIndividual.Count )

			insert into diccionario( Entidad, Atributo, Dominio, Tags ) Values( "Entidad1","Atributo3", "DETALLEPETER", "<OBLIGATORIO>" )

			.ValidarDetallesObligatorios()
			This.AssertEquals( "Cantidad De Errores Incorrectos(2).", 1, .oMockInformacionIndividual.Count )

			This.assertequals( "El mensaje de error 1 es incorrecto. Debe dar error ya no tiene cargada la etiqueta", ;
				 "El detalle 'ATRIBUTO3' de la entidad 'ENTIDAD1' debe tener cargada la etiqueta cuando se espeficica que es obligatorio." ,;
				 .oMockInformacionIndividual.Item[ 1 ].cmensaje )
			
		endwith		

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarEntidadesAnulables
		
		***Por la forma en que acumulan los campos en la recepcion de las transferencias, todas las entidades que tengan componente stock deben tener funcionalidad anulable, 
		***para que la recep. de las transferencia solo modifiquen un comprobante si fue previamente anulado.
		with This.oValidarADN
			
			insert into entidad( entidad, tipo, funcionalidades) values ( "ENT1","E", "" )&&No tiene componente asociado, no tiene problema
			insert into entidad( entidad, tipo, funcionalidades) values ( "ENT2","E", "" )&&Si tiene componente asociado, TIENE problema
			insert into entidad( entidad, tipo, funcionalidades) values ( "ENT3","E", "<ANULABLE>" )&&Si tiene componente asociado pero es anulable, no tiene problema

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(1).", 0, .oMockInformacionIndividual.Count )

			insert into relaComponente (entidad, componente) values ( "ENT2", "DESCUENTOS" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(2).", 0, .oMockInformacionIndividual.Count )

			insert into relaComponente (entidad, componente) values ( "ENT2", "STOCK" )
			.oMockInformacionIndividual.Limpiar()

			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(3).", 1, .oMockInformacionIndividual.Count )

			insert into relaComponente (entidad, componente) values ( "ENT3", "DESCUENTOS" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(4).", 1, .oMockInformacionIndividual.Count )

			insert into relaComponente (entidad, componente) values ( "ENT3", "STOCK" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(5).", 1, .oMockInformacionIndividual.Count )
			
			This.assertequals( "El mensaje de error es incorrecto.", ;
				 "La entidad ENT2 tiene componente STOCK y deberia ser ANULABLE" ,;
				 .oMockInformacionIndividual.Item[ 1 ].cmensaje )
						
			update relacomponente set componente = "" where alltrim( upper( entidad ) ) == alltrim( upper( "ENT2" ))
			
			
			insert into entidad( entidad, tipo, funcionalidades) values ( "ENT4","E", "" )&&No tiene componente asociado, no tiene problema
			insert into entidad( entidad, tipo, funcionalidades) values ( "ITEMENT4","I", "" )&&Si tiene componente asociado, TIENE problema
			
			insert into diccionario ( entidad, dominio ) values ( "ENT4", "DETALLEITEMENT4" )
			
			insert into relaComponente (entidad, componente) values ( "ITEMENT4", "STOCK" )			
	
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(6).", 1, .oMockInformacionIndividual.Count )
			This.assertequals( "El mensaje de error es incorrecto.", ;
				 "La entidad ENT4 tiene componente STOCK y deberia ser ANULABLE" ,;
				.oMockInformacionIndividual.Item[ 1 ].cmensaje )
				
			update entidad set funcionalidades = "<ANULABLE>" where alltrim( upper( entidad ) ) == alltrim( upper( "ENT4" ))
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadesAnulables()
			This.AssertEquals( "Cantidad De Errores Incorrectos(7).", 0, .oMockInformacionIndividual.Count )
			
		endwith		

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarCodigoDeBarras
		with This.oValidarADN
			
			insert into entidad( entidad, tipo ) values ( "STOCKCOMBINACION","E" )
			insert into entidad( entidad, tipo ) values ( "ITEM1","I" )
			insert into entidad( entidad, tipo ) values ( "ITEMSINCODBAR","I" )
			insert into entidad( entidad, tipo ) values ( "ITEMSINCOMB","I" )
			insert into entidad( entidad, tipo ) values ( "ITEM3", "I" )

			insert into diccionario( entidad, atributo, longitud,clavecandidata ) values ( "STOCKCOMBINACION","CLAVE1", 5, 1 )
			insert into diccionario( entidad, atributo, longitud,clavecandidata ) values ( "STOCKCOMBINACION","OTRO", 5, 0 )
			insert into diccionario( entidad, atributo, longitud,clavecandidata ) values ( "STOCKCOMBINACION","CLAVE2", 5, 2 )

			insert into diccionario( entidad, atributo, longitud ) values ( "ITEM1","Clave1", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "Item1","CodigoDeBarras", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "ITEM1","OTRO", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "Item1","CLAVE2", 10 )

			insert into diccionario( entidad, atributo, longitud ) values ( "Item2","CLAVE1", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "ITEM2","OTRO", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "Item2","CodigoDeBarras", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "Item2","Clave2", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "Item2","Cantidad", 10 )

			insert into diccionario( entidad, atributo, longitud ) values ( "itemsincodbar","CLAVE1", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "itemsincodbar","OTRO", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "itemsincodbar","Clave2", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "itemsincodbar","Cantidad", 10 )

			insert into diccionario( entidad, atributo, longitud ) values ( "ITEMSINCOMB","CodigoDeBarras", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "ITEMSINCOMB","OTRO", 10 )
			insert into diccionario( entidad, atributo, longitud ) values ( "ITEMSINCOMB","Cantidad", 10 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCodigoDeBarras()
			This.AssertEquals( "Cantidad De Errores Incorrectos(1).", 3, .oMockInformacionIndividual.Count )

			This.assertequals( "El mensaje de error 1 es incorrecto.", ;
				 "La longitud del atributo CODIGODEBARRAS de la entidad ITEM1 es 10 y debería ser mayor o igual a 22." , .oMockInformacionIndividual.Item[ 1 ].cmensaje )
			This.assertequals( "El mensaje de error 2 es incorrecto.", ;
				 "La longitud del atributo CODIGODEBARRAS de la entidad ITEM2 es 10 y debería ser mayor o igual a 33." , .oMockInformacionIndividual.Item[ 2 ].cmensaje )
			This.assertequals( "El mensaje de error 3 es incorrecto.", ;
				 "La longitud del atributo CODIGODEBARRAS de la entidad ITEMSINCOMB es 10 y debería ser mayor o igual a 11." , .oMockInformacionIndividual.Item[ 3 ].cmensaje )
						
			update diccionario set longitud = 11 where alltrim( upper( atributo) ) == alltrim( upper( "CodigoDeBarras" ))
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCodigoDeBarras()
			This.AssertEquals( "Cantidad De Errores Incorrectos(2).", 2, .oMockInformacionIndividual.Count )

			This.assertequals( "El mensaje de error 1 es incorrecto.", ;
				 "La longitud del atributo CODIGODEBARRAS de la entidad ITEM1 es 11 y debería ser mayor o igual a 22." , .oMockInformacionIndividual.Item[ 1 ].cmensaje )
			This.assertequals( "El mensaje de error 2 es incorrecto.", ;
				 "La longitud del atributo CODIGODEBARRAS de la entidad ITEM2 es 11 y debería ser mayor o igual a 33." , .oMockInformacionIndividual.Item[ 2 ].cmensaje )

			update diccionario set longitud = 33 where alltrim( upper( atributo) ) == alltrim( upper( "CodigoDeBarras" ))
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarCodigoDeBarras()
			This.AssertEquals( "No debe haber errores.", 0, .oMockInformacionIndividual.Count )
			
			insert into entidad( entidad, tipo ) values ( "ITEMATRIBUTOVIRTUAL", "I" )			
			
			insert into diccionario( entidad, atributo, tabla, campo, longitud ) values ( "ITEMATRIBUTOVIRTUAL", "Clave1", "AtrVirtual", "Codigo", 10 )
			insert into diccionario( entidad, atributo, tabla, campo, longitud ) values ( "ITEMATRIBUTOVIRTUAL", "CodigoDeBarras", "AtrVirtual", "Codbar", 11 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarCodigoDeBarras()
			This.AssertEquals( "Cantidad De Errores Incorrectos(3).", 1, .oMockInformacionIndividual.Count )
			This.assertequals( "El mensaje de error 1 es incorrecto.", ;
				 "El atributo CODIGODEBARRAS de la entidad ITEMATRIBUTOVIRTUAL debe ser un Atributo virtual y por eso no se permite configurarle la Tabla ni el Campo." , .oMockInformacionIndividual.Item[ 1 ].cmensaje )
						
		endwith		

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarFiltroTransferenciaDisenoImpresion
		with This.oValidarADN
			**** Validamos los atributos del ADN real *************************************************************
			.oMockInformacionIndividual.Limpiar()
			insert into ENTIDAD ( Entidad ) values ( "DISENOIMPRESION" )
			.ValidarFiltroTransferenciaDisenoImpresion()
			This.AssertEquals( "DISENOIMPRESION tiene un tipo de datos inválido y no pinchó", 1, .oMockInformacionIndividual.Count )

			* Tipo de datos inválido
			insert into transferenciasfiltros ( entidad, atributo ) values ( "DISENOIMPRESION", "CODIGO" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarFiltroTransferenciaDisenoImpresion()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar Filtro Transferencia Diseño Impresion). Verifique ADN", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarMenuTransferenciaDisenoImpresion
		with This.oValidarADN
			**** Validamos los atributos del ADN real *************************************************************
			insert into ENTIDAD ( Entidad ) values ( "DISENOIMPRESION" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarMenuTransferenciaDisenoImpresion()
			This.AssertEquals( "DISENOIMPRESION tiene un tipo de datos inválido y no pinchó", 1, .oMockInformacionIndividual.Count )

			* Tipo de datos inválido
			insert into menualtasitems ( entidad, etiqueta ) values ( "DISENOIMPRESION", "EMPAQUETAR DATOS" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarMenuTransferenciaDisenoImpresion()
			This.AssertEquals( "Existen problemas en el ADN ANTES DE CORRER LOS TEST (Validar Menú Empaquetar Datos Diseño Impresion). Verifique ADN", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarFormatoDescripcionEnComprobantes
		insert into entidad ( Entidad, FormatoDescripcion, Tipo ) values ( "Entidad 1", "'COCONA'", "E" )
		insert into entidad ( Entidad, FormatoDescripcion, Tipo ) values ( "Entidad 2", "", "E" )
		insert into entidad ( Entidad, FormatoDescripcion, Tipo ) values ( "Entidad 3", "", "E" ) && esta deberia tener el campo lleno
		insert into entidad ( Entidad, FormatoDescripcion, Tipo ) values ( "Entidad 4", "", "E" ) 
		insert into entidad ( Entidad, FormatoDescripcion, Tipo ) values ( "Entidad 5", "", "E" ) && esta deberia tener el campo lleno porque su detalle tiene componente
		insert into entidad ( Entidad, Tipo ) values ( "Item 1", "I" ) 
		insert into entidad ( Entidad, Tipo ) values ( "Item 2", "I" ) 

		insert into diccionario ( entidad, dominio ) values ( "Entidad 5", "DETALLEITEM 1" )
		
		insert into entidad ( Entidad, Funcionalidades, Tipo ) values ( "Entidad Auditada 1", "<AUDITORIA>", "E" )
		insert into entidad ( Entidad, Funcionalidades, Tipo ) values ( "Entidad Auditada 2", "<AUDITORIA>", "E" )
		insert into entidad ( Entidad, Funcionalidades, Tipo ) values ( "Entidad sin Auditar", "", "E" )
		
		insert into componente ( Componente, entidad ) values ( "componente 1", "Entidad Auditada 1, Entidad Auditada 2" )
		insert into componente ( Componente, entidad ) values ( "componente 2", "Entidad sin Auditar" )
		insert into relacomponente ( entidad, Componente ) values ( "Entidad 3", "componente 1" )
		insert into relacomponente ( entidad, Componente ) values ( "Entidad 4", "componente 2" )
		insert into relacomponente ( entidad, Componente ) values ( "Item 1", "componente 1" )
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarFormatoDescripcionEnComprobantesAux()
			This.AssertEquals( "La validación no tiene la cantidad de items correcta 1", 2, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El mensaje es incorrecto 1", ;
				"La entidad 'ENTIDAD 3' no tiene cargado el campo FORMATODESCRIPCION de la tabla ENTIDAD.", ;
				.oMockInformacionIndividual.Item[1].cMensaje )
			This.AssertEquals( "El mensaje es incorrecto 2", ;
				"La entidad 'ENTIDAD 5' no tiene cargado el campo FORMATODESCRIPCION de la tabla ENTIDAD.", ;
				.oMockInformacionIndividual.Item[2].cMensaje )
			
			update entidad set FormatoDescripcion = "'TORONJA'" where entidad = "Entidad 3"

			.oMockInformacionIndividual.Limpiar()
			.ValidarFormatoDescripcionEnComprobantesAux()
			This.AssertEquals( "La validación no tiene la cantidad de items correcta 2", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El mensaje es incorrecto 3", ;
				"La entidad 'ENTIDAD 5' no tiene cargado el campo FORMATODESCRIPCION de la tabla ENTIDAD.", ;
				.oMockInformacionIndividual.Item[1].cMensaje )

			update entidad set FormatoDescripcion = "'TORONJA 2'" where entidad = "Entidad 5"

			.oMockInformacionIndividual.Limpiar()
			.ValidarFormatoDescripcionEnComprobantesAux()
			This.AssertEquals( "La validación no tiene la cantidad de items correcta 3", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 

	*-----------------------------------	
	function zTestValidarTipoDeValorCheque
		local lcMensaje as string, loObjeto as object

		*Validamos que se ejecute el metodo ValidarDominioImagen al ejecutar la validacion
		loObjeto = newobject( "ObjetoBindeo" )
		bindevent( This.oValidarADN, "ValidarTipoDeValorCheque", loObjeto, "ValidarTipoDeValorCheque", 1 )
		
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.Validar()
			This.AssertTrue( "No se ejecutó ValidarTipoDeValorCheque", loObjeto.lEjecutoValidarTipoDeValorCheque )

			loObjeto.destroy()
			
			delete from tipoDeValores 
			
			*Verificamos buen funcionamiento de ValidarTipoDeValorCheque
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipoDeValorCheque()
			This.AssertEquals( "No se ha validado (1). ValidarTipoDeValorCheque", 0, .oMockInformacionIndividual.Count )

			insert into tipoDeValores ( Codigo, Descripcion, FechaEntrega, FechaRecibe) values ( 4, "Cheque", .f., .f. )

			.oMockInformacionIndividual.Limpiar()
			.ValidarTipoDeValorCheque()
			This.AssertEquals( "No se ha validado (2). ValidarTipoDeValorCheque", 0, .oMockInformacionIndividual.Count )
			
			update tipoDeValores set FechaEntrega = .t. where codigo == 4 

			lcMensaje = "El tipo de valor CHEQUE debe tener habilitado (.F.) el salto de campo en FechaEntrega y FechaRecibe"
			.oMockInformacionIndividual.Limpiar()
			.ValidarTipoDeValorCheque()
			This.AssertEquals( "No se ha validado (3). ValidarTipoDeValorCheque", 1, .oMockInformacionIndividual.Count )
			This.assertEquals( "Error en el mensaje. ValidarTipoDeValorCheque", lcMensaje, .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		EndWith		
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas
		
		insert into comprobantes ( descripcion ) values ( "Comprobante" )

		insert into menualtasitems ( Id, entidad, AccesoRapido, etiqueta, codigo ) values ( 1, "Comprobante", "A", "E1", "C1" )
		insert into menualtasitems ( Id, entidad, AccesoRapido, etiqueta, codigo ) values ( 2, "Alta", "C", "E2", "C2" )
		insert into menualtasitems ( Id, entidad, AccesoRapido, etiqueta, codigo ) values ( 20, "Alta", "D", "E5", "C5" )
		
		insert into menualtasdefault ( Id, AccesoRapido, etiqueta, codigo ) values ( 3, "B", "E3", "C3" )
		insert into menualtasdefault ( Id, AccesoRapido, etiqueta, codigo ) values ( 30, "D", "E5", "C5" )
		
		with This.oValidarAdn
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()
			.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
			This.AssertEquals( "La validación debe estar ok.", 0, .oMockInformacionIndividual.Count )

			.CerrarAdnAdicional()
		
			****************
			insert into menualtasdefault ( Id, AccesoRapido, etiqueta, codigo ) values ( 4, "C", "E4", "C4" )
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()

			.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C está repetido", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C está repetido. Mensaje 1", ;
				"La entidad ALTA tiene repetido el acceso rapido C en el menú default.", .oMockInformacionIndividual(1).cMensaje )

			.CerrarAdnAdicional()

			****************
			insert into menualtasdefault ( Id, AccesoRapido, etiqueta, codigo ) values ( 5, "A", "E5", "C5" )
			.CrearAdnAdicional()
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos", 2, .oMockInformacionIndividual.Count )
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos. Mensaje 1", ;
				"La entidad COMPROBANTE tiene repetido el acceso rapido A en el menú default.", .oMockInformacionIndividual(1).cMensaje )
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos. Mensaje 2", ;
				"La entidad ALTA tiene repetido el acceso rapido C en el menú default.", .oMockInformacionIndividual(2).cMensaje )

			.CerrarAdnAdicional()

			****************
			insert into menualtasitems ( Id, entidad, AccesoRapido, etiqueta, codigo ) values ( 6, "Alta", "CTRL+O", "E6", "C6" )
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()
			.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O es correcto en altas", ;
																											2, .oMockInformacionIndividual.Count )
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O es correcto en altas. Mensaje 1", ;
				"La entidad COMPROBANTE tiene repetido el acceso rapido A en el menú default.", .oMockInformacionIndividual(1).cMensaje )
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O es correcto en altas. Mensaje 2", ;
				"La entidad ALTA tiene repetido el acceso rapido C en el menú default.", .oMockInformacionIndividual(2).cMensaje )

			.CerrarAdnAdicional()

			****************
			insert into menualtasitems ( Id, entidad, AccesoRapido, etiqueta, codigo ) values ( 7, "Comprobante", "CTRL +  O", "E7", "C7" )
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()
			.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O es pisado por el de NUEVO EN BASE A", ;
																											2, .oMockInformacionIndividual.Count )

			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O es pisado por el de NUEVO EN BASE A. Mensaje 1", ;
				"La entidad COMPROBANTE tiene repetido el acceso rapido A en el menú default.", .oMockInformacionIndividual(1).cMensaje )
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O es pisado por el de NUEVO EN BASE A. Mensaje 2", ;
				"La entidad ALTA tiene repetido el acceso rapido C en el menú default.", .oMockInformacionIndividual(2).cMensaje )

			.CerrarAdnAdicional()

			****************
			insert into menualtasdefault ( Id, AccesoRapido, etiqueta, codigo ) values ( 8, "C", "E8", "C8" )
			.CrearAdnAdicional()

			.oMockInformacionIndividual.Limpiar()

			.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O NO es correcto en comprobantes " + ;
								"(ya que pertecene al nuevo en base A) y esta repetido un acceso en menudefault", ;
																											3, .oMockInformacionIndividual.Count )

			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O NO es correcto en comprobantes " + ;
								"(ya que pertecene al nuevo en base A) y esta repetido un acceso en menudefault. Mensaje 1", ;
				"Las opciones por default del menu de altas tiene repetido el acceso rapido C en el menú.", .oMockInformacionIndividual(1).cMensaje )

			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O NO es correcto en comprobantes " + ;
								"(ya que pertecene al nuevo en base A) y esta repetido un acceso en menudefault. Mensaje 2", ;
				"La entidad COMPROBANTE tiene repetido el acceso rapido A en el menú default.", .oMockInformacionIndividual(2).cMensaje )

			This.AssertEquals( "La validación debe ser falsa. El acceso rapido C y A están repetidos pero el CTRL+O NO es correcto en comprobantes " + ;
								"(ya que pertecene al nuevo en base A) y esta repetido un acceso en menudefault. Mensaje 3", ;
				"La entidad ALTA tiene repetido el acceso rapido C en el menú default.", .oMockInformacionIndividual(3).cMensaje )
			
			.CerrarAdnAdicional()


		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarConsistenciaDeEntidadesAnulablesYMenu
		
		***Por la forma en que acumulan los campos en la recepcion de las transferencias, todas las entidades que tengan componente stock deben tener funcionalidad anulable, 
		***para que la recep. de las transferencia solo modifiquen un comprobante si fue previamente anulado.
		with This.oValidarADN
			
			insert into entidad( entidad, tipo, funcionalidades, formulario ) values ( "ENT1","E", "", .f. )&&No tiene componente asociado, no tiene problema
			insert into entidad( entidad, tipo, funcionalidades, formulario ) values ( "ENT2","E", "", .f. )&&Si tiene componente asociado, TIENE problema

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()
			This.AssertEquals( "No debe haber errores.", 0, .oMockInformacionIndividual.Count )

			insert into entidad( entidad, tipo, funcionalidades) values ( "ENTSINFORM","E", "<ANULABLE>" )&&Si tiene componente asociado pero es anulable, no tiene problema

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()
			This.AssertEquals( "No debe haber errores debido a que la entidad no tiene formulario asociado.", 0, .oMockInformacionIndividual.Count )

			insert into entidad( entidad, tipo, funcionalidades, formulario ) values ( "ENT3", "E", "<ANULABLE>", .t. )&&Si tiene componente asociado pero es anulable, no tiene problema

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()
			This.AssertEquals( "La entidad 3 es anulable y no tiene cargado el menú.", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "La entidad 3 es anulable y no tiene cargado el menú. Detalle del error", ;
				"La entidad ENT3 tiene funcionalidad <ANULABLE> y no tiene cargado (o está cargado de forma incorrecta) de forma el menú ANULAR.", .oMockInformacionIndividual.Item[ 1 ].cMensaje )

			insert into menualtasitems ( etiqueta, comando, skipfor, idImagen, toolbar, Codigo, Entidad ) values ;
				( "Anular","thisform.oKontroler.ejecutar('Anular')", "thisform.lDeshabilitarAnular", 37, .t., "ANULAR", "ENT3" )&&Si tiene componente asociado, TIENE problema

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()
			This.AssertEquals( "No debe haber errores. La entidad ENT3 tiene funcionaliudad y tiene menu cargado.", 0, .oMockInformacionIndividual.Count )
		
			insert into menualtasitems ( etiqueta, comando, skipfor, idImagen, toolbar, Codigo, Entidad ) values ;
				( "Anular","thisform.oKontroler.ejecutar('Anular')", "thisform.lDeshabilitarAnular", 37, .t., "ANULAR", "ENT2" )&&Si tiene componente asociado, TIENE problema

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()
			This.AssertEquals( "No debe haber errores. La entidad ENT2 No tiene funcionaliudad y tiene menu cargado peor no es visible.", 0, .oMockInformacionIndividual.Count )
		
			update Entidad set formulario = .t. where alltrim( upper( entidad ) ) == "ENT2"

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()

			This.AssertEquals( "La entidad 2 tiene cargado el menú y no es anulable.", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "La entidad 2 tiene cargado el menú y no es anulable. Detalle del error", ;
				"La entidad ENT2 tiene cargado el menú ANULAR y no tiene funcionalidad <ANULABLE>.", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				
			update Entidad set funcionalidades = "<ANULABLE>" where alltrim( upper( entidad ) ) == "ENT2"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaDeEntidadesAnulablesYMenu()
			This.AssertEquals( "No debe haber errores. La entidad ENT2 tiene menu cargado y tiene funcionaliudad y .", 0, .oMockInformacionIndividual.Count )
		endwith		

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarLlamadasAValidacionesDeAdn

		local lcCursor as String, lnCantDeLlamadasAMetodosValidar as Integer, loLlamadasAMetodosValidar as collection,;
			  loObjetoBindeoMetodos as Object, lcMetodo as String
			  
		This.oValidarADN.CerrarTablas()
		store 0 to lnCantDeMetodosValidar, lnCantDeLlamadasAMetodosValidar


		loLlamadasAMetodosValidar = Newobject( 'Collection' )

		lcCursor = Sys( 2015 )
		Create Cursor ( lcCursor ) ( txt C(250) )
		Append From ( "validaradn.prg" ) Type Sdf	

		scan	
			lcNombreFuncion =alltrim(lower( strtran( TXT, chr(9), "" ) ) )
			if "function"  $ lower( lcNombreFuncion ) and !( '"function"' $ lcNombreFuncion ) and !(substr( lcNombreFuncion,1,1 ) = "*" )
				
				lcNombreFuncion = strtran( lcNombreFuncion, "protected", "" )
				lcNombreFuncion = strtran( lcNombreFuncion, "function", "" )
				lcNombreFuncion = alltrim( getwordnum(lcNombreFuncion, 1, "(") )
				
				if inlist(lower(lcNombreFuncion), "init", "crearadnadicional", "agregarinformacionindividual", "release",;
							"obtenerproyectoactivo", "validar", "devolverinformacion", "abrirtablas", "crearcursor" ,"cerrartablas" ,"destroy",;
							"obtenerentidadesconproblemas", "cerraradnadicional", "armarmensajeparaentidadatributo" ) or ;
					inlist( lower(lcNombreFuncion), "validaratributossindominio", "validarlargodecampoversusmascara",;
						"validarcamposobligatoriosendetalle", "validarordenregladenegocio", "validarlongitudcamposautoincrementales", "validarunicidadenids", ;
						"validarrelatriggers", "validarexistenciadetallebuscador", "validarcoherencia_de_subentidades" ) or ;
					inlist( lower(lcNombreFuncion), "validardescripciongrupo", "validardescripcionsubgrupo", "validartiposubgrupo", "validartitulomenunorepetido", ;
						"validartitulosmenunorepetidos_hijos", "validartitulosmenunorepetidos_cabecera", "validaraccesodirectos", "validaraccesosdirectos", ;
						"validarentidad", "validarfuncionalidadcontrolarfechahoraenrecepcion" ) or ;
					inlist( lower(lcNombreFuncion), "obtenercaracteresvalidosnombreentidad", "validarlongitudcamposautoincrementalesenclaveforanea", ;
						"validarlongitudcamposautoincrementalesenitems", "valoraccioncorrecto", "contieneidsrepetidos" ) or ;
					inlist( lower(lcNombreFuncion), "verificardesdehasta", "verificaratributodepreciodearticulo", ;
						"verificaratributo_subentidad", "esatributofiltroencalculodeprecios", "tienesubentidad", "letrasinvalidasporproyecto" ) or ;
					inlist( lower(lcNombreFuncion), "validarfuncionalidaddesdehastalistcampos", "esfuncionalidadconvalor", "ozoo_access" ) or;
					inlist( lower(lcNombreFuncion), "compararcamposfaltantes", "compararcampos", "compararregistros", "validarcompras" ) or ;
					inlist( lower(lcNombreFuncion), "validarlongitudclienteorigenenvaledecambio", "validarlongitudclientedestinoenvaledecambio", "acumularlongitudescliente" ) or ;
					inlist( lower(lcNombreFuncion), "verificarsielcampodebesercomparadoentreitemventayitemkits", "esatributodetalle", "tienemasdeunatributoamismaclaveforanea", "completarcolecciontaglc" )
				else
					With loLlamadasAMetodosValidar
						.Add( lcNombreFuncion )
					endwith		
				endif
			endif
		endscan
		
		use in select ( "&lcCursor" )
		
		loValidarBindeo = newobject( "ValidarADNBindeo" )
		loValidarBindeo.cProyectoActivo = "FELINO" && para que corra algunas validaciones que en nucleo no se corren		
		loValidarBindeo.cRutaInicial = strtran( upper( loValidarBindeo.cRutaInicial ), "NUCLEO", "FELINO" ) && para que corra algunas validaciones que en nucleo no se corren		
		loValidarBindeo.AbrirTablas()
		loValidarBindeo.RealizarBindeos( loLlamadasAMetodosValidar )
		set datasession to loValidarBindeo.DataSessionId

		select * from Entidad into cursor c_Entidad noFilter
		use in select( "Entidad" )
		select * from c_Entidad into cursor Entidad ReadWrite
		
		select * from Diccionario into cursor c_Diccionario noFilter
		use in select( "Diccionario" )
		select * from c_Diccionario into cursor Diccionario ReadWrite

		insert into Entidad ( Entidad ) values ( "Entidad Test" )
		insert into Diccionario( Entidad, Atributo, claveCandidata ) values ( "PRECIODEARTICULO", "MANZANA", 1 )
		insert into Diccionario( Entidad, Atributo, claveCandidata ) values ( "CALCULODEPRECIOS", "MANZANA", 1 )		

		loValidarBindeo.validar()
		for each lcMetodo in loLlamadasAMetodosValidar 
			This.Asserttrue( "No se Ejecuto el metodo " + lcMetodo, seek( padl( upper( lcMetodo ), 200 ), "c_Validaciones", "Nombre" ) )
		endfor		
		set datasession to This.nDataSession
		loValidarBindeo.CerrarTablas()

		use in select ( "lcCursor" )
		loValidarBindeo.lDestroy = .t.
		loValidarBindeo.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestValidarCampoInicialConSaltoDeCampo

		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()

			insert into entidad ( entidad, formulario, tipo ) values ( "entidad1", .t., "E" )
			insert into diccionario ( entidad, atributo , campoinicial, saltoCampo , alta ) values ( "entidad1", "Atributo1", .t., .t., .t. )
			
			.ValidarCampoInicialConSaltoDeCampo()
			This.AssertEquals( "La entidad Entidad1 tiene cargado un atributo con salto de campo y campo inicial en .t.", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			update diccionario set campoinicial = .f. where alltrim( upper( entidad ) ) == "ENTIDAD1"

			.ValidarCampoInicialConSaltoDeCampo()
			This.AssertEquals( "La entidad Entidad1 no cargado un atributo con salto de campo y campo inicial en .t.", 0, .oMockInformacionIndividual.Count )

			delete from entidad 
			delete from diccionario 
			.oMockInformacionIndividual.Limpiar()
			
			insert into entidad ( entidad, formulario, tipo ) values ( "entidad1", .f., "E" )
			insert into diccionario ( entidad, atributo , campoinicial, saltoCampo , alta ) values ( "entidad1", "Atributo1", .t., .t., .t. )

			.ValidarCampoInicialConSaltoDeCampo()
			This.AssertEquals( "La entidad Entidad1 tiene cargado un atributo con salto de campo y campo inicial en .t. y no es formulario.", 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			update entidad set tipo = "I" , formulario = .t. where alltrim( upper( entidad ) ) == "ENTIDAD1"

			.ValidarCampoInicialConSaltoDeCampo()
			This.AssertEquals( "La entidad Entidad1 tiene cargado un atributo con salto de campo y campo inicial en .t. y es un item.", 0, .oMockInformacionIndividual.Count )

			delete from entidad 
			delete from diccionario 
			.oMockInformacionIndividual.Limpiar()
			
			insert into entidad ( entidad, formulario, tipo ) values ( "entidad1", .t., "E" )
			insert into diccionario ( entidad, atributo , campoinicial, saltoCampo , alta ) values ( "entidad1", "Atributo1", .t., .t., .f. )

			.ValidarCampoInicialConSaltoDeCampo()
			This.AssertEquals( "La entidad Entidad1 tiene cargado un atributo no visible con salto de campo y campo inicial en .t. y es formulario.", 0, .oMockInformacionIndividual.Count )


		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	Function zTestU_FiltrosConTransferenciasNoBoleanos 

		with This.oValidarADN				
			*Arrange (Preparar)
			insert into TransferenciasFiltros( Entidad , Atributo ) values ( "ENTIDAD1", "ATRIBUTO" )
			insert into Diccionario( Entidad , Atributo, TipoDato ) values ( "ENTIDAD1", "ATRIBUTO" , "L" )		
			*Act (Actuar)
			.ValidarFiltrosTransferenciasSegunTipo()
			*Assert (Afirmar)

			This.AssertEquals( "No puede existir un filtro en Transferencias a puntando a un atributo lógico.", 1, .oMockInformacionIndividual.Count )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarTablaParametrosYRegistrosEspecificos
		delete from PARAMETROSYREGISTROSESPECIFICOS 
		insert into PARAMETROSYREGISTROSESPECIFICOS ( ;
			ID, ;
			IDPROYECTO, ;
			ESREGISTRO, ;
			DEFAULT, ;
			AYUDA, ;
			IDNODOCLIE, ;
			PARAMUSU ) values ( 3, 2, .f., "PEPE4", "AYUDA 1 - pisada", 2, "Parametros desde test 1. - pisada" )						
		
		insert into Parametros ( id, idNodo, Parametro, ParamInt ,Organizacion, Puesto, Sucursal, Default, TipoDato, Ayuda, idNodoCliente, paramusu ) values ;
		    ( 3, 3, "Test3", "ParametrosTest3", 0, 0, 1, "PEPE", "C", "AYUDA 3", 2, "Parametros desde test 3." )
		
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarTablaParametrosYRegistrosEspecificos()    
		This.AssertEquals( "No deberia dar error ya que la especificacion apunta a un parametro o registro existente.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		
		replace all idproyecto with -2 in PARAMETROSYREGISTROSESPECIFICOS

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarTablaParametrosYRegistrosEspecificos()    
		This.AssertEquals( "Deberia dar error ya que la especificacion del parametro o registro tiene un Id de proyecto incorrecto.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
		
		replace all idproyecto with 2 in PARAMETROSYREGISTROSESPECIFICOS
		replace all id with 0 in PARAMETROSYREGISTROSESPECIFICOS

		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarTablaParametrosYRegistrosEspecificos()    
		This.AssertEquals( "Deberia dar error ya que hay especificaciones que no tienen ID.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
		
		replace all id with 3 in PARAMETROSYREGISTROSESPECIFICOS
		replace all PARAMUSU with "" in PARAMETROSYREGISTROSESPECIFICOS
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarTablaParametrosYRegistrosEspecificos()    
		This.AssertEquals( "Deberia dar error ya hay especificaciones que no tienen paramusu.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
								
		delete from PARAMETROSYREGISTROSESPECIFICOS 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarIntegridadEntreTablasEntidadDiccionario
		with This.oValidarADN				

			insert into Diccionario( Entidad ) values ( "ENTIDAD" )
			insert into Entidad( Entidad ) values ( "ENTIDAD" )
			.ValidarIntegridadEntreTablasEntidadDiccionario()
			This.AssertEquals( "No tiene que haber encontrado problemas de integridad.", 0, .oMockInformacionIndividual.Count )

			insert into Diccionario( Entidad ) values ( "ENTIDAD2" )

			.ValidarIntegridadEntreTablasEntidadDiccionario()
			This.AssertEquals( "Tiene que haber encontrado problemas de integridad.", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "Mensaje incorrecto 1", "La entidad ENTIDAD2 se encuentra en la tabla diccionario pero no en entidad.", .oMockInformacionIndividual.item[1].cMensaje )
		
			insert into Entidad( Entidad ) values ( "ENTIDAD2" )
			insert into Entidad( Entidad ) values ( "ENTIDAD3" )
			
			.ValidarIntegridadEntreTablasEntidadDiccionario()
			This.AssertEquals( "Tiene que haber encontrado problemas de integridad.", 2, .oMockInformacionIndividual.Count )
			This.AssertEquals( "Mensaje incorrecto 2", "La entidad ENTIDAD3 se encuentra en la tabla entidad pero no en diccionario.", .oMockInformacionIndividual.item[2].cMensaje )

			insert into Diccionario( Entidad ) values ( "ENTIDAD3" ) 
			.oMockInformacionIndividual.Limpiar()
			.ValidarIntegridadEntreTablasEntidadDiccionario()
			This.AssertEquals( "Finalmente no tiene que haber encontrado problemas de integridad.", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosAtributoFiltroInexistenteEnPrecioDeArticulo
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo1_Desde" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado", 1, .oMockInformacionIndividual.Count )
			this.assertequals( "Mensaje incorrecto 1", "El atributo 'ARTICULO1' debe ser un atributo de la entidad 'PRECIODEARTICULO'", .oMockInformacionIndividual.item[1].cMensaje )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosAtributoFiltroExistenteEnPrecioDeArticulo
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Hasta" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosAtributoFiltroExistente_e_Inexistente_EnPrecioDeArticulo
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Hasta" )			
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo1_Desde" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado", 1, .oMockInformacionIndividual.Count )
			this.assertequals( "Mensaje incorrecto 1", "El atributo 'ARTICULO1' debe ser un atributo de la entidad 'PRECIODEARTICULO'", .oMockInformacionIndividual.item[1].cMensaje )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosAtributoNoFiltro
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()

			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_DesdeFAFA" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo1_DesdePAPA" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Manzana_Pirulo_Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f__Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f___Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Hasta" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f__Hasta" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f___Hasta" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "No debio validar mal", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosEntidad_AtributoInvalido
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Proveedor1_Desde" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado", 2, .oMockInformacionIndividual.Count )
			this.assertequals( "Mensaje incorrecto 1", "Debe existir el atributo 'F_ARTICULO_PROVEEDOR1_HASTA' en la entidad 'CALCULODEPRECIOS'", .oMockInformacionIndividual.item[1].cMensaje )
			this.assertequals( "Mensaje incorrecto 2", "El atributo 'PROVEEDOR1' no es un atributo de la entidad 'ARTICULO'", .oMockInformacionIndividual.item[2].cMensaje )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosEntidad_AtributoValido
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Proveedor_Desde" )
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Proveedor_hasta" )			
			insert into Diccionario ( entidad, atributo ) values ( "Articulo", "Proveedor" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarCalculoDePreciosAtributoDesdeExistaUnAtributoHasta
		with this.oValidarADN
			=InsertarDatosParaCalculodePrecios()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_Desde" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado 1", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Diccionario ( entidad, atributo ) values ( "CalculoDePrecios", "f_Articulo_hasta" )
			.ValidarEntidadCalculoDePrecios()
			this.assertequals( "Mal Validado 2", 0, .oMockInformacionIndividual.Count )

		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarHotKeysEnElMenuPrincipal

		insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "Manzana", 10 )
		insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "\<Manzana", 10 )
		insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "\<Mandarina", 10 )

		insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "Manzana", 11 )
		insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "\<Manzana", 11 )
		insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "M\<andarina", 11 )
		

		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipal()
			this.assertequals( "Mal Validado HotKey 1", 1, .oMockInformacionIndividual.Count )

			update MenuPrincipal set Etiqueta = "Man\<darina" where Etiqueta = "\<Mandarina" and idPadre = 10
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipal()
			this.assertequals( "Mal Validado HotKey 2", 0, .oMockInformacionIndividual.Count )

			insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "Mandarina \<Verde", 10 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipal()
			this.assertequals( "Mal Validado HotKey 3", 0, .oMockInformacionIndividual.Count )

			insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "Mandioca \<Verde", 11 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipal()
			this.assertequals( "Mal Validado HotKey 4", 0, .oMockInformacionIndividual.Count )
			
			insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "Mandioca \<Verde", 10 )
			insert into MenuPrincipal( Etiqueta, idPadre ) Values ( "Mandioca \<Verde", 11 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipal()
			this.assertequals( "Mal Validado HotKey 5", 2, .oMockInformacionIndividual.Count )

		EndWith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_VerificarHotKeysEnElMenuPrincipalItems
	
		insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "Manzana", 10 )
		insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "\<Manzana", 10 )
		insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "\<Mandarina", 10 )

		insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "Manzana", 11 )
		insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "\<Manzana", 11 )
		insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "M\<andarina", 11 )
		

		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipalItems()
			this.assertequals( "Mal Validado HotKey 1", 1, .oMockInformacionIndividual.Count )

			update MenuPrincipalItems set Etiqueta = "Man\<darina" where Etiqueta = "\<Mandarina" and idPadre = 10
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipalItems()
			this.assertequals( "Mal Validado HotKey 2", 0, .oMockInformacionIndividual.Count )

			insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "Mandarina \<Verde", 10 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipalItems()
			this.assertequals( "Mal Validado HotKey 3", 0, .oMockInformacionIndividual.Count )

			insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "Mandioca \<Verde", 11 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipalItems()
			this.assertequals( "Mal Validado HotKey 4", 0, .oMockInformacionIndividual.Count )
			
			insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "Mandioca \<Verde", 10 )
			insert into MenuPrincipalItems( Etiqueta, idPadre ) Values ( "Mandioca \<Verde", 11 )
			.oMockInformacionIndividual.Limpiar()
			.ValidarHotKeysEnElMenuPrincipalItems()
			this.assertequals( "Mal Validado HotKey 5", 2, .oMockInformacionIndividual.Count )

		EndWith		
	endfunc 

		
	*-----------------------------------------------------------------------------------------
	function zTestValidarComienzaGrupoEnMenuPrincipal

		insert into MenuPrincipal ( id, idpadre, etiqueta, comienzagrupo ) values ( 1, 0, "Menu1", .f. )
		
		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarComienzaGrupoEnMenuPrincipal()
			This.AssertEquals( "No se validó correctamente el valor del campo ComienzaGrupo en la tabla MenuPrincipal (1).", 0, .oMockInformacionIndividual.Count )
		endwith

		insert into MenuPrincipal ( id, idpadre, etiqueta, comienzagrupo ) values ( 2, 0, "Menu2", .t. )
		insert into MenuPrincipal ( id, idpadre, etiqueta, comienzagrupo ) values ( 2, 1, "SubMenu", .t. )

		with This.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarComienzaGrupoEnMenuPrincipal()
			This.AssertEquals( "No se validó correctamente el valor del campo ComienzaGrupo en la tabla MenuPrincipal (2).", 1, .oMockInformacionIndividual.Count )
			This.AssertEquals( "El error detectado no es correcto.", "La opción de menu con Id: 2 y Etiqueta: Menu2 tiene especificado que ComienzaGrupo pero no tiene IdPadre.", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarNodosParametrosCliente
		with this.oValidarADN
			insert into NodosParametrosCliente ( IdNodo, NombreNodo, IdNodoPadre ) ;
				values ( 9999, "PRUEBATEST", 8888 )

			.oMockInformacionIndividual.Limpiar()
			.ValidarNodosParametrosCliente()
			this.AssertEquals( "Debería haber saltado la validación ValidarNodosParametrosCliente", 1, .oMockInformacionIndividual.Count )

			delete from NodosParametrosCliente where IdNodo = 9999

			.oMockInformacionIndividual.Limpiar()
			.ValidarNodosParametrosCliente()
			this.AssertEquals( "No debería haber saltado la validación ValidarNodosParametrosCliente", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_NoExisteEnEntidad
		local loError as Exception
		
		with this.oValidarADN
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "NO Debería haber saltado la validación ValidarTagsComprobantes", 0, .oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_NoExisteEnComprobantes
		with this.oValidarADN
			insert into Entidad ( Entidad ) ;
				values ( "EntidadTest" )
			delete from Comprobantes where Descripcion == "EntidadTest"

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "No Debería haber saltado la validación ValidarTagsComprobantes", 0, .oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_NoTieneElTagVentasNiCompras
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion ) ;
				values ( "EntidadTest", "Entidad Test" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 1, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"El comprobante Entidad Test no posee el tag que indica si es de Ventas o Compras.", ;
					.oMockInformacionIndividual.Item[1].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagVentas
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<VENtAS>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "NO Debería haber saltado la validación ValidarTagsComprobantes", 0, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagCompras
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<CoMpRaS>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "NO Debería haber saltado la validación ValidarTagsComprobantes", 0, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagComprasMalEscrito
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<COMPRAS>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest2", "Entidad Test", "COMPRAS>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest2" )
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest3", "Entidad Test", "<COMPRAS" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest3" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 2, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Entidad where Entidad == "EntidadTest2"
				delete from Entidad where Entidad == "EntidadTest3"
				delete from Comprobantes where Descripcion == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest2"
				delete from Comprobantes where Descripcion == "EntidadTest3"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagVentasMalEscrito
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<VENTAS>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest2", "Entidad Test", "VENTAS>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest2" )
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest3", "Entidad Test", "<VENTAS" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest3" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 2, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Entidad where Entidad == "EntidadTest2"
				delete from Entidad where Entidad == "EntidadTest3"
				delete from Comprobantes where Descripcion == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest2"
				delete from Comprobantes where Descripcion == "EntidadTest3"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagVentasPeroNoEsUnComprobante
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<VENTAS>" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 1, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"La entidad Entidad Test posee el tag Ventas pero no está en la tabla Comprobantes.", ;
					.oMockInformacionIndividual.Item[1].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagComprasPeroNoEsUnComprobante
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<COMPRAS>" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 1, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"La entidad Entidad Test posee el tag Compras pero no está en la tabla Comprobantes.", ;
					.oMockInformacionIndividual.Item[1].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagFiscalNoTieneElTagVentasNiCompras
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<FISCAL>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 2, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"El comprobante Entidad Test posee el tag que indica que es un comprobante fiscal pero no tiene indicado si es de Ventas o Compras.", ;
					.oMockInformacionIndividual.Item[2].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagFiscalYTieneElTagVentas
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<VENTAS<FISCAL>>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 0, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagFiscalYTieneElTagCompras
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<COMPRAS<FISCAL>>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 0, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagFiscalPeroNoExisteEnComprobantes
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<FISCAL>" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 1, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"La entidad Entidad Test posee el tag Fiscal pero no está en la tabla Comprobantes.", ;
					.oMockInformacionIndividual.Item[1].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagSubdiarioPeroNoFiscal
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<CONVALORES>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 2, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"El comprobante Entidad Test posee el tag que indica que es un comprobante tiene valores, pero no tiene indicado que es Fiscal.", ;
					.oMockInformacionIndividual.Item[2].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagSubdiarioYFiscalNoVentasNiCompras
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<FISCAL<CONVALORES>>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 2, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"El comprobante Entidad Test posee el tag que indica que es un comprobante fiscal pero no tiene indicado si es de Ventas o Compras.", ;
					.oMockInformacionIndividual.Item[2].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagSubdiario_FiscalYVentas
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<VENTAS<FISCAL<CONVALORES>>>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 0, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagSubdiario_FiscalYCompras
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<COMPRAS<FISCAL<CONVALORES>>>" )
			insert into Comprobantes ( Descripcion ) ;
				values ( "EntidadTest" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 0, ;
					.oMockInformacionIndividual.Count )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
				delete from Comprobantes where Descripcion == "EntidadTest"
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestTagParaComprobantes_TieneElTagSubdiarioPeroNoExisteEnComprobantes
		with this.oValidarADN
			insert into Entidad ( Entidad, Descripcion, Funcionalidades ) ;
				values ( "EntidadTest", "Entidad Test", "<CONVALORES>" )

			try
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagsComprobantes_Test()
				this.AssertEquals( "Debería haber saltado la validación ValidarTagsComprobantes", 1, ;
					.oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", ;
					"La entidad Entidad Test posee el tag Convalores pero no está en la tabla Comprobantes.", ;
					.oMockInformacionIndividual.Item[1].cMensaje )
			catch to loError
				throw loError
			finally 
				delete from Entidad where Entidad == "EntidadTest"
			endtry
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarDigitosEnTipoDatosNumericosEnDiccionario
		local oldProyectoActivo As String, loError As Exception
		oldProyectoActivo = this.oValidarADN.cProyectoActivo

		insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales) ;
							values ( "RRR", "1", "C", 15, 0 )
		insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales) ;
							values ( "RRR", "2", "C", 18, 0 )
		insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales) ;
							values ( "RRR", "3", "N", 15, 0 )
		insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales) ;
							values ( "RRR", "4", "N", 17, 0 )
		insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales) ;
							values ( "RRR", "5", "N", 15, 2 )
		insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales) ;
							values ( "RRR", "6", "N", 16, 0 )

		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.cProyectoActivo = "COLORYTALLE"
				.ValidarDigitosEnTipoDatosNumericosEnDiccionario()

				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarDigitosEnTipoDatosNumericosEnDiccionario", 2, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", "La LONGITUD del atributo 4 de la entidad Rrr (Diccionario) no puede ser mayor a 15.", .oMockInformacionIndividual.Item[1].cMensaje )
				this.AssertEquals( "Mensaje incorrecto", "La LONGITUD del atributo 6 de la entidad Rrr (Diccionario) no puede ser mayor a 15.", .oMockInformacionIndividual.Item[2].cMensaje )
			endwith
		catch to loError
		finally
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarDigitosEnTipoDatosNumericosEnListados
		local oldProyectoActivo As String, loError As Exception
		oldProyectoActivo = this.oValidarADN.cProyectoActivo

		insert into listcampos ( idFormato, Entidad, Atributo, longitud, tipodato ) ;
			values ( "1", "RRR", "atribgen", 17, "N" )

		insert into listcampos ( idFormato, Entidad, Atributo, longitud, tipodato ) ;
			values ( "1", "RRR", "atribgen", 17, "C" )

		insert into listcampos ( idFormato, Entidad, Atributo, longitud, tipodato ) ;
			values ( "1", "RRR", "atribgen", 15, "N" )

		insert into listcampos ( idFormato, Entidad, Atributo, longitud, tipodato, decimales ) ;
			values ( "2", "RRR", "atribgen2", 18, "N", 2 )

		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.cProyectoActivo = "COLORYTALLE"
				.ValidarDigitosEnTipoDatosNumericosEnListados()

				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarDigitosEnTipoDatosNumericosEnListados", 2, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", "La LONGITUD del atributo atribgen de la entidad Rrr (Listcampos IDFORMATO:1) no puede ser mayor a 15.", .oMockInformacionIndividual.Item[1].cMensaje )
				this.AssertEquals( "Mensaje incorrecto", "La LONGITUD del atributo atribgen2 de la entidad Rrr (Listcampos IDFORMATO:2) no puede ser mayor a 15.", .oMockInformacionIndividual.Item[2].cMensaje )
			endwith
		catch to loError
		finally
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc 

	*---------------------------------------------------------------------------------------
	function zTestValidarCapitalizacionDeEtiquetas
		local lcProyectoActivo as String
		
		with This.oValidarADN
			try
				lcProyectoActivo = .cProyectoActivo
				.cProyectoActivo = "COLORYTALLE"
				.oMockInformacionIndividual.Limpiar()
				insert into Diccionario ( Entidad, Atributo, Etiqueta, EtiquetaCorta ) Values( "Uno", "A1", "Etiqueta Uno", "Etq. Uno" )
				insert into Diccionario ( Entidad, Atributo, Etiqueta, EtiquetaCorta ) Values( "Dos", "A2", "Etiqueta dos", "Etq. Dos" )
				.oValidarAdnCapitalizacionEtiquetas.Validar()
				This.AssertEquals( "No se debió haber encontrado etiquetas con problemas. No hay atributos visibles.", 0, .oMockInformacionIndividual.Count )
				
				update Diccionario set Alta = .t.
				.oValidarAdnCapitalizacionEtiquetas.Validar()
				This.AssertEquals( "La cantidad de etiquetas con problemas es incorrecta", 3, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", "La Etiqueta del atributo A1 en la entidad Uno no está bien capitalizada (Texto actual: Etiqueta Uno).", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				this.AssertEquals( "Mensaje incorrecto", "La Etiqueta Corta del atributo A1 en la entidad Uno no está bien capitalizada (Texto actual: Etq. Uno).", .oMockInformacionIndividual.Item[ 2 ].cMensaje )
				this.AssertEquals( "Mensaje incorrecto", "La Etiqueta Corta del atributo A2 en la entidad Dos no está bien capitalizada (Texto actual: Etq. Dos).", .oMockInformacionIndividual.Item[ 3 ].cMensaje )

				update Diccionario set Etiqueta = "Etiqueta uno", EtiquetaCorta = "Etq. uno" where alltrim( Entidad ) == "Uno"
				update Diccionario set EtiquetaCorta = "Etq. dos" where alltrim( Entidad ) == "Dos"

				.oMockInformacionIndividual.Limpiar()
				.oValidarAdnCapitalizacionEtiquetas.Validar()
				This.AssertEquals( "No se debió haber encontrado etiquetas con problemas.", 0, .oMockInformacionIndividual.Count )
			finally
				.cProyectoActivo = lcProyectoActivo
			endtry
		endwith
	endfunc
	
	*---------------------------------------------------------------------------------------
	function zTestValidarAdnOrtografiaEtiquetas
		local lcProyectoActivo as String
		
		with This.oValidarADN
			try
				lcProyectoActivo = .cProyectoActivo
				.cProyectoActivo = "COLORYTALLE"
				.oMockInformacionIndividual.Limpiar()
				insert into Diccionario ( Entidad, Atributo, Etiqueta, EtiquetaCorta, Ayuda ) Values( "Uno", "A1", "Descripción", "Desc.", "Descricion" )
				insert into Diccionario ( Entidad, Atributo, Etiqueta, EtiquetaCorta, Ayuda ) Values( "Dos", "A2", "Priemro", "Priem.", "Primero" )
				.ValidarOrtografiaEtiquetas()
				This.AssertEquals( "No se debió haber encontrado errores ortográficos. No hay atributos visibles.", 0, .oMockInformacionIndividual.Count )

				update Diccionario set Alta = .t.
				.ValidarOrtografiaEtiquetas()
				This.AssertEquals( "La cantidad de etiquetas/ayuda con problemas es incorrecta", 3, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", "La Ayuda del atributo A1 en la entidad Uno contiene posibles errores ortográficos (Texto actual: Descricion).", .oMockInformacionIndividual.Item[ 1 ].cMensaje )
				this.AssertEquals( "Mensaje incorrecto", "La Etiqueta del atributo A2 en la entidad Dos contiene posibles errores ortográficos (Texto actual: Priemro).", .oMockInformacionIndividual.Item[ 2 ].cMensaje )
				this.AssertEquals( "Mensaje incorrecto", "La Etiqueta Corta del atributo A2 en la entidad Dos contiene posibles errores ortográficos (Texto actual: Priem.).", .oMockInformacionIndividual.Item[ 3 ].cMensaje )

				update Diccionario set Ayuda = "Descripción" where alltrim( Entidad ) == "Uno"
				update Diccionario set Etiqueta = "Primero", etiquetacorta = "Prime." where alltrim( Entidad ) == "Dos"

				.oMockInformacionIndividual.Limpiar()
				.ValidarOrtografiaEtiquetas()
				This.AssertEquals( "No debiría haber encontrado errores ortográficos.", 0, .oMockInformacionIndividual.Count )
			finally
				.cProyectoActivo = lcProyectoActivo
			endtry
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_VerificarSeguridadEnTablaMenuPrincipal
	
		insert into MenuPrincipal ( id, idpadre, etiqueta, lTieneSeguridad ) values ( 1, 0, "prueba adn", .T. )
		insert into MenuPrincipal ( id, idpadre, etiqueta, lTieneSeguridad ) values ( 2, 1, "prueba adn", .F. )
		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.ValidarSeguridadEnMenuPrincipal()

				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarSeguridadEnMenuPrincipal", 1, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto", "La configuración de seguridad del menú id 2 no se corresponde con la de su padre( Id Padre: 1 ).", .oMockInformacionIndividual.Item[1].cMensaje )
			endwith
		catch to loError
			throw loError
		endtry

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarFuncionalidadCodigoSugerido
		local lcMensaje as String
		Insert into entidad ( entidad, tipo, funcionalidades ) values ( "Ent1" , "E", "" )
		Insert into entidad ( entidad, tipo, funcionalidades ) values ( "Ent2" , "E", "<CODIGOSUGERIDO>" )
		Insert into entidad ( entidad, tipo, funcionalidades ) values ( "Ent3" , "E", "<CODIGOSUGERIDO>" )
		Insert into entidad ( entidad, tipo, funcionalidades ) values ( "Item1" , "I", "" )
		Insert into entidad ( entidad, tipo, funcionalidades ) values ( "Item2" , "I", "<CODIGOSUGERIDO>" )

		Insert into diccionario ( entidad, atributo, tipodato, claveprimaria, valorsugerido ) values ( "Ent1" , "Codigo", "C", .t., "" )
		Insert into diccionario ( entidad, atributo, tipodato, claveprimaria, valorsugerido ) values ( "Ent2" , "id", "G", .t., "" )
		Insert into diccionario ( entidad, atributo, tipodato, claveprimaria, valorsugerido ) values ( "Ent3" , "Codigo", "N", .t., "='A'" )
		Insert into diccionario ( entidad, atributo, tipodato, claveprimaria, valorsugerido ) values ( "Item1" , "Codigo", "C", .t., "" )
		Insert into diccionario ( entidad, atributo, tipodato, claveprimaria, valorsugerido ) values ( "Item2" , "Codigo", "C", .t., "" )

		This.oValidarADN.ValidarFuncionalidadCodigoSugerido()
		This.assertequals( "La cantidad de mensajes de error es incorrecta.", 4, This.oValidarADN.oMockInformacionIndividual.Count )
		lcMensaje = "Entidad: ENT2. La funcionalidad <CODIGOSUGERIDO> solo esta disponible para entidades cuya clave primaria sea de tipo de dato [C]."
		This.assertequals( "El mensaje de error es incorrexcto (1).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		lcMensaje = "Entidad: ENT3. La funcionalidad <CODIGOSUGERIDO> solo esta disponible para entidades cuya clave primaria sea de tipo de dato [C]."
		This.assertequals( "El mensaje de error es incorrexcto (2).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cMensaje )
		lcMensaje = "Entidad: ENT3. La funcionalidad <CODIGOSUGERIDO> no esta disponible para entidades a las que se les especificó un valor en el campo [ValorSugerido] de la clave primaria."
		This.assertequals( "El mensaje de error es incorrexcto (3).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 3 ].cMensaje )
		lcMensaje = "Item: ITEM2. La funcionalidad <CODIGOSUGERIDO> solo esta disponible para Entidades."
		This.assertequals( "El mensaje de error es incorrexcto (4).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 4 ].cMensaje )
		
		update entidad set funcionalidades = "" where alltrim( entidad ) == "Item2"
		update diccionario set tipodato = "C" where alltrim( entidad ) == "Ent2" and alltrim( atributo ) == "id"
		update diccionario set tipodato = "C", valorsugerido = "" where alltrim( entidad ) == "Ent3" and alltrim( atributo ) == "Codigo"
		
		This.oValidarADN.oMockInformacionIndividual.Limpiar()
		This.oValidarADN.ValidarFuncionalidadCodigoSugerido()
		This.assertequals( "No debería haber detectado errores.", 0, This.oValidarADN.oMockInformacionIndividual.Count )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_TagParaOrdenEnBuscador
		local lcMensaje as String
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, AdmiteBusqueda, Tags ) values ( "EntidadTest", "CODIGO", "", "", 0, "<OrdenBuscador:A>" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTags()
			this.AssertEquals( "Debería haber detectado errores de validación (1).", 3, This.oValidarADN.oMockInformacionIndividual.Count )
			lcMensaje = "Entidad: EntidadTest - Atributo: CODIGO. No es posible especificar el tag <OrdenBuscador> en un atributo virtual."
			this.AssertEquals( "El mensaje de error es incorrexcto (1).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
			lcMensaje = "Entidad: EntidadTest - Atributo: CODIGO. No es posible especificar el tag <OrdenBuscador> en un atributo que no admite busqueda."
			this.AssertEquals( "El mensaje de error es incorrexcto (2).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cMensaje )
			lcMensaje = "Entidad: EntidadTest - Atributo: CODIGO. El parámetro del tag <OrdenBuscador> debe ser un número entero."
			this.AssertEquals( "El mensaje de error es incorrexcto (3).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 3 ].cMensaje )
			
			delete from Diccionario
			insert into Diccionario ( Entidad, Atributo, Tabla, Campo, AdmiteBusqueda, Tags ) values ( "EntidadTest", "CODIGO", "Tabla", "Codigo", 1, "<OrdenBuscador:1>" )
			insert into Diccionario ( Entidad, Atributo, Tabla, Campo, AdmiteBusqueda, Tags ) values ( "EntidadTest", "Direccion", "Tabla", "Direccion", 2, "<OrdenBuscador>" )
			.oMockInformacionIndividual.Limpiar()
			.ValidarTags()
			this.AssertEquals( "Debería haber detectado errores de validación (2).", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			lcMensaje = "Entidad: EntidadTest - Atributo: Direccion. Debe especificar un parámetro para el tag <OrdenBuscador>."
			this.AssertEquals( "El mensaje de error es incorrexcto (4).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )

			update Diccionario set Tags = "<OrdenBuscador:2>" where upper( alltrim( Atributo ) ) = "DIRECCION"
			.oMockInformacionIndividual.Limpiar()
			.ValidarTags()
			this.AssertEquals( "No debería haber detectado errores.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_SiEsAnulableNoDebeSerDesactivable

	*Arrange (Preparar)
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADANULABLE", "<ANULABLE>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADANULABLEDESACTIVABLE", "<ANULABLE><DESACTIVABLE>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADDESACTIVABLEANULABLE", "<DESACTIVABLE><ANULABLE>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADDESACTIVABLE", "<DESACTIVABLE>" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
	*Act (Actuar)
			.ValidarIndividualidadDeTagDesactivableYAnulable_AUX()
	*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 2, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El primer error no es el correcto.", ;
				"La entidad ENTIDADANULABLEDESACTIVABLE tiene las funcionalidades ANULABLE y DESACTIVABLE pero ambas no se pueden asignar a la misma entidad.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
			this.AssertEquals( "El segundo error no es el correcto.", ;
				"La entidad ENTIDADDESACTIVABLEANULABLE tiene las funcionalidades ANULABLE y DESACTIVABLE pero ambas no se pueden asignar a la misma entidad.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_SiEsDesactivableDebeSerAuditable

	*Arrange (Preparar)
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADAUDITORIA", "<AUDITORIA>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADAUDITORIADESACTIVABLE", "<AUDITORIA><DESACTIVABLE>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADDESACTIVABLEAUDITORIA", "<DESACTIVABLE><AUDITORIA>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADDESACTIVABLE", "<DESACTIVABLE>" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
	*Act (Actuar)
			.ValidarQueEntidadDesactivableSeaAuditable_AUX()
	*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"La entidad ENTIDADDESACTIVABLE debe tener AUDITORIA para poseer la funcionalidad DESACTIVABLE.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_SiEsAuditableDebePoseerModulosListado

	*Arrange (Preparar)
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADAUDITORIA", "<AUDITORIA>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADAUDITORIAMODULARIZADA", "<AUDITORIA><MODULOSLISTADO:B>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADMODULARIZADAAUDITORIA", "<MODULOSLISTADO:B><AUDITORIA>" )
		insert into Entidad ( Descripcion, funcionalidades ) values ( "ENTIDADMODULARIZADA", "<MODULOSLISTADO:B>" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
	*Act (Actuar)
			.ValidarQueEntidadConAuditoriaTengaModulosListado_AUX()
	*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"La entidad ENTIDADAUDITORIA debe tener indicados los módulos mediante la funcionalidad MODULOSLISTADO: para poseer la funcionalidad AUDITORIA.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoConfigurablesYSaltosFijos
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, saltocampo, tags ) values ( "ENTIDADTEST", "ATRIBUTO1", .f., "<SALTODECAMPO>" )
		insert into Diccionario ( entidad, atributo, saltocampo, tags ) values ( "ENTIDADTEST", "ATRIBUTO2", .t., "<SALTODECAMPO>" )
		insert into Diccionario ( entidad, atributo, saltocampo, tags ) values ( "ENTIDADTEST", "ATRIBUTO3", .t., "" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoFijosYConfigurables_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO2 de la entidad ENTIDADTEST tiene establecido salto de campo fijo y el tag para que el salto de " + ;
					"campo sea configurable. Por favor, cambie uno de ambos.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoYGenHabilitar
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, genhabilitar, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO1", .f., "<SALTODECAMPO>", "CARACTER" )
		insert into Diccionario ( entidad, atributo, genhabilitar, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO2", .t., "<SALTODECAMPO>", "CARACTER" )
		insert into Diccionario ( entidad, atributo, genhabilitar, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO3", .t., "", "CARACTER" )
		insert into Diccionario ( entidad, atributo, genhabilitar, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO4", .t., "<SALTODECAMPO>", "DETALLETEST" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYGenHabilitar_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO2 de la entidad ENTIDADTEST tiene establecida la habilitación dinámica y el tag que permite configurar el salto de " + ;
					"campo. Por favor, cambie uno de ambos.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoCabeceraDetalle
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ENTIDADCABECERA", "ATRIBUTO1", "<SALTODECAMPO>", "DETALLEITEM1" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ENTIDADCABECERA", "ATRIBUTO2", "<SALTODECAMPO>", "DETALLEITEM2" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ITEM1", "ATRIBUTO3", "", "CARACTER" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ITEM1", "ATRIBUTO4", "", "CARACTER" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ITEM2", "ATRIBUTO5", "<SALTODECAMPO>", "CARACTER" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ITEM2", "ATRIBUTO6", "<SALTODECAMPO>", "CARACTER" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ITEM2", "ATRIBUTO7", "", "CARACTER" )
		insert into Entidad ( entidad, tipo ) values ( "ENTIDADCABECERA", "E" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM1", "I" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM2", "I" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYCabeceraDetalle_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO1 de la entidad ENTIDADCABECERA es un detalle y tiene establecido el tag que permite configurar el salto de " + ;
					"campo, pero falta establecer el mismo tag para por lo menos un atributo de ese detalle.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoDetalleCabecera
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ENTIDADCABECERA", "ATRIBUTO1", "<SALTODECAMPO>", "DETALLEITEM1", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ENTIDADCABECERA", "ATRIBUTO2", "", "DETALLEITEM2", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM1", "ATRIBUTO3", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM1", "ATRIBUTO4", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM1", "ATRIBUTO5", "", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM2", "ATRIBUTO6", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM2", "ATRIBUTO7", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM2", "ATRIBUTO8", "", "CARACTER", .t. )
		insert into Entidad ( entidad, tipo ) values ( "ENTIDADCABECERA", "E" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM1", "I" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM2", "I" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYDetalleCabecera_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO2 de la entidad ENTIDADCABECERA es un detalle y tiene que tener el tag que permite configurar el salto de " + ;
					"campo ya que por lo menos un atributo de dicho detalle tiene el tag mencionado.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoDetalleCabeceraInvisible
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ENTIDADCABECERA", "ATRIBUTO1", "<SALTODECAMPO>", "DETALLEITEM1", .f. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ENTIDADCABECERA", "ATRIBUTO2", "", "DETALLEITEM2", .f. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM1", "ATRIBUTO3", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM1", "ATRIBUTO4", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM1", "ATRIBUTO5", "", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM2", "ATRIBUTO6", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM2", "ATRIBUTO7", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, alta ) values ( "ITEM2", "ATRIBUTO8", "", "CARACTER", .t. )
		insert into Entidad ( entidad, tipo ) values ( "ENTIDADCABECERA", "E" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM1", "I" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM2", "I" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYDetalleCabecera_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoDetalleAtributoObligatorio
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, dominio, obligatorio ) values ( "ENTIDADCABECERA", "ATRIBUTO1", "<SALTODECAMPO>", "DETALLEITEM1", .f. )
		insert into Diccionario ( entidad, atributo, tags, dominio, obligatorio ) values ( "ENTIDADCABECERA", "ATRIBUTO2", "", "DETALLEITEM2", .f. )
		insert into Diccionario ( entidad, atributo, tags, dominio, obligatorio ) values ( "ITEM1", "ATRIBUTO3", "<SALTODECAMPO>", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, obligatorio ) values ( "ITEM1", "ATRIBUTO4", "<SALTODECAMPO>", "CARACTER", .f. )
		insert into Diccionario ( entidad, atributo, tags, dominio, obligatorio ) values ( "ITEM2", "ATRIBUTO5", "", "CARACTER", .t. )
		insert into Diccionario ( entidad, atributo, tags, dominio, obligatorio ) values ( "ITEM2", "ATRIBUTO6", "<SALTODECAMPO>", "CARACTER", .f. )
		insert into Entidad ( entidad, tipo ) values ( "ENTIDADCABECERA", "E" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM1", "I" )
		insert into Entidad ( entidad, tipo ) values ( "ITEM2", "I" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYDetalleAtributoObligatorio_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO3 de la entidad ITEM1 tiene el tag que permite configurar el salto de " + ;
					"campo y es obligatorio. Por favor, cambie uno de ambos.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoSinEtiqueta
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, etiqueta ) values ( "ENTIDADTEST", "ATRIBUTO1", "<SALTODECAMPO>", "Atributo 1" )
		insert into Diccionario ( entidad, atributo, tags, etiqueta ) values ( "ENTIDADTEST", "ATRIBUTO2", "", "Atributo 2" )
		insert into Diccionario ( entidad, atributo, tags, etiqueta ) values ( "ENTIDADTEST", "ATRIBUTO3", "<SALTODECAMPO>", "" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYEtiquetas_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO3 de la entidad ENTIDADTEST tiene el tag que permite configurar el salto de " + ;
					"campo pero no tiene etiqueta.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoAtributosInvisibles
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, alta ) values ( "ENTIDADTEST", "ATRIBUTO1", "<SALTODECAMPO>", .t. )
		insert into Diccionario ( entidad, atributo, tags, alta ) values ( "ENTIDADTEST", "ATRIBUTO2", "<SALTODECAMPO>", .f. )
		insert into Diccionario ( entidad, atributo, tags, alta ) values ( "ENTIDADTEST", "ATRIBUTO3", "", .f. )
		insert into Diccionario ( entidad, atributo, tags, alta ) values ( "ENTIDADTEST", "ATRIBUTO4", "", .t. )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYAlta_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO2 de la entidad ENTIDADTEST tiene el tag que permite configurar el salto de " + ;
					"campo pero no es visible.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarSaltosDeCampoDominiosInvalidos
		*Arrange (Preparar)
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO1", "<SALTODECAMPO>", "CARACTER" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO2", "<SALTODECAMPO>", "NUMEROCOMPROBANTE" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO3", "", "NUMEROCOMPROBANTE" )
		insert into Diccionario ( entidad, atributo, tags, dominio ) values ( "ENTIDADTEST", "ATRIBUTO4", "", "CARACTER" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
		*Act (Actuar)
			.ValidarSaltosDeCampoConfigurablesYDominiosInvalidos_AUX()
		*Assert (Afirmar)
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", ;
				"El atributo ATRIBUTO2 de la entidad ENTIDADTEST tiene el tag que permite configurar el salto de " + ;
					"campo pero no se permite para atributos con el dominio NUMEROCOMPROBANTE.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_CampoValorSuregeridoNoTieneDateNoDebePinchar
		
		* Arrange
		insert into Diccionario ( entidad, atributo, valorsugerido ) values ( "ENTIDADTEST", "ATRIBUTO1", "" )
		
		* Act
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarFechasEnCampoValorSugerido_Aux()

		* Assert	
			this.AssertEquals( "Debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_CampoValorSuregeridoTieneDateDebePinchar
		
		* Arrange
		insert into Diccionario ( entidad, atributo, valorsugerido ) values ( "ENTIDADTEST", "ATRIBUTO1",  "=dAte()" )
		
		* Act
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarFechasEnCampoValorSugerido_Aux()

		* Assert	
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", "El atributo ATRIBUTO1 de la entidad ENTIDADTEST no esta obteniendo la fecha de manera correcta.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith	
	endfunc 
		

	*-----------------------------------------------------------------------------------------
	function zTestU_CampoValorSuregeridoNoTieneTimeNoDebePinchar
		
		* Arrange
		insert into Diccionario ( entidad, atributo, valorsugerido ) values ( "ENTIDADTEST", "ATRIBUTO1", "" )
		
		* Act
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarHorasEnCampoValorSugerido_AUX()

		* Assert	
			this.AssertEquals( "Debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_CampoValorSuregeridoTieneTimeDebePinchar
		
		* Arrange
		insert into Diccionario ( entidad, atributo, valorsugerido ) values ( "ENTIDADTEST", "ATRIBUTO1",  "=tImE()" )
		
		* Act
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarHorasEnCampoValorSugerido_AUX()

		* Assert	
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", "El atributo ATRIBUTO1 de la entidad ENTIDADTEST no esta obteniendo la hora de manera correcta.", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarTagPromocionesPrincipal

		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo1", "<PROMO_PRINCIPAL>" )
		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo2", "<PROMO_PRINCIPAL>" )
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTagPromocionesPrincipal()
				
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", "No puede haber mas de una entidad con tag <PROMO_PRINCIPAL> ( EntidadPromo1, EntidadPromo2 )", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
	
		delete From Entidad where alltrim( Entidad ) == "EntidadPromo2"
		.oMockInformacionIndividual.Limpiar()
		.ValidarTagPromocionesPrincipal()
		.ValidarCampoFuncionalidades()			
		this.AssertEquals( "No debería haber detectado errores de validación. 1", 0, This.oValidarADN.oMockInformacionIndividual.Count )

		delete From Entidad where alltrim( Entidad ) == "EntidadPromo1"
		.oMockInformacionIndividual.Limpiar()
		.ValidarTagPromocionesPrincipal()
		.ValidarCampoFuncionalidades()			
		this.AssertEquals( "No debería haber detectado errores de validación. 2", 0, This.oValidarADN.oMockInformacionIndividual.Count )
						
		.ValidarTags()
		.ValidarCampoFuncionalidades()		
		this.AssertEquals( "No debería haber detectado errores de validación. 3", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		EndWith			
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarTagPromociones

		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo1", "<PROMO>" )
		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo2", "<PROMO>" )		
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTagPromociones()
				
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", "No puede haber tag <PROMO> sin una entidad declarada como <PROMO_PRINCIPAL> ( EntidadPromo1, EntidadPromo2 )", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
	
		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo3", "<PROMO_PRINCIPAL>" )
		.oMockInformacionIndividual.Limpiar()
		.ValidarTagPromociones()
		this.AssertEquals( "No debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		.ValidarTags()
		.ValidarCampoFuncionalidades()
		this.AssertEquals( "No debería haber detectado errores de validación. 2", 0, This.oValidarADN.oMockInformacionIndividual.Count )
					
		EndWith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarConsistenciaAtributosPromociones

		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo1", "<PROMO_PRINCIPAL>" )
		insert into Entidad ( entidad, Funcionalidades ) values ( "EntidadPromo2", "<PROMO>" )
		
		insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadPromo1", "Atributo1", "<PP>" )
		insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadPromo1", "Atributo2", "<PP>" )
		insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadPromo1", "Atributo5", "" )		
		insert into Diccionario ( entidad, Atributo ) values ( "EntidadPromo2", "Atributo1" )
		insert into Diccionario ( entidad, Atributo ) values ( "EntidadPromo2", "Atributo3")
		insert into Diccionario ( entidad, Atributo ) values ( "EntidadPromo2", "Atributo4")		
		
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaAtributosPromociones()
				
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			this.AssertEquals( "El error no es el correcto.", "Los atributos con funcionalidad <PP> de las entidades declaradas como promociones deben coincidir en todas las entidades participantes ( EntidadPromo1, EntidadPromo2 )", ;
				This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
	
			insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadPromo1", "Atributo3", "<PP>" )
			insert into Diccionario ( entidad, Atributo ) values ( "EntidadPromo2", "Atributo2" )

			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaAtributosPromociones()
			this.AssertEquals( "No debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
			.ValidarTags()
			.ValidarCampoFuncionalidades()
			this.AssertEquals( "No debería haber detectado errores de validación. 2", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		
		EndWith
	endfunc 

	
      *-----------------------------------------------------------------------------------------
      function zTestU_ValidarTagPermitidos

            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo1" , "<combinacion>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo2" , "<noCopiar>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo3" , "<fechaCai>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo4" , "<obligatorio>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo5" , "<condicionSumarizar>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo6" , "<desdeSugerido>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo7" , "<hastaSugerido>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo8" , "<filtroConCeroNoVacio>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo9" , "<noVacios>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo10", "<atributoAnulacion>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo11", "<sugeridoAnulacion>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo12", "<ordenBuscador>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo13", "<ordenarAlCargar>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo14", "<saltoDeCampo>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo15", "<noListaGenerico>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo16", "<pp>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo17", "<copiaDetalle>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo18", "<noMantenerEnRecepcion>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo19", "<ignorar_pk>" )
            insert into Diccionario ( entidad, Atributo, Tags ) values ( "Entidad1", "Atributo20", "<admitebusquedasubentidad>" )

            with this.oValidarADN
                  select Diccionario
                  scan
                        .oMockInformacionIndividual.Limpiar()
                        .validarTagPermitidos_Aux( "Diccionario", Diccionario.Tags, "Diccionario" )
                  endscan

                  this.AssertEquals( "No debería haber detectado errores de validación 1.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
            EndWith
            
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo1" , "<desdesugerido>" )
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo2" , "<hastasugerido>" )
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo3" , "<filtroconceronovacio>" )
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo4" , "<novacios>" )
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo5" , "<atributosubtotal>" )
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo6" , "<noperzonalizacampo>" )
            insert into ListCampos( entidad, Atributo, Funcionalidades ) values ( "Entidad1", "Atributo7" , "<noperzonalizafiltro>" )
            
            with this.oValidarADN
                  select ListCampos
                  scan
                        .oMockInformacionIndividual.Limpiar()
                        .validarTagPermitidos_Aux( "ListCampos", ListCampos.Funcionalidades, "ListCampos" )
                  endscan

                  this.AssertEquals( "No debería haber detectado errores de validación 2.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
            EndWith

            use in select("Diccionario")
            use in select("ListCampos")        
      endfunc

		*-----------------------------------------------------------------------------------------
		function zTestU_ValidarTagSoportaPrePantalla
			local lcMensaje as String
			lcMensaje = "Entidad: ItemArticulos - Atributo: Articulo - Debe tener ALTA, la clave foránea debe ser ARTICULO, el dominio debe ser CONSOPORTEPREPANTALLA y pertenecer a un detalle que posea el tag CONSOPORTEPREPANTALLA"

			insert into Diccionario ( Entidad, Atributo, Dominio, Alta, ClaveForanea, Tags ) values ( "ItemArticulos", "Articulo", "CODIGO", .F., "COLOR", "<SOPORTAPREPANTALLA>" )

			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagSoportaPrePantalla()
				this.AssertEquals( "Debería haber detectado errores de validación (1).", 1, This.oValidarADN.oMockInformacionIndividual.Count )
				this.AssertEquals( "El error no es el esperado (1).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
				
				update Diccionario set Alta = .t. where upper( alltrim( Entidad ) ) == upper( alltrim( "ItemArticulos" ) ) and upper( alltrim( Atributo ) ) == upper( alltrim( "ARTICULO" ) )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagSoportaPrePantalla()
				this.AssertEquals( "Debería haber detectado errores de validación (2).", 1, This.oValidarADN.oMockInformacionIndividual.Count )
				this.AssertEquals( "El error no es el esperado (2).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
				
				update Diccionario set ClaveForanea = "ARTICULO" where upper( alltrim( Entidad ) ) == upper( alltrim( "ItemArticulos" ) ) and upper( alltrim( Atributo ) ) == upper( alltrim( "ARTICULO" ) )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagSoportaPrePantalla()
				this.AssertEquals( "Debería haber detectado errores de validación (3).", 1, This.oValidarADN.oMockInformacionIndividual.Count )
				this.AssertEquals( "El error no es el esperado (3).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
				
				update Diccionario set Dominio = "CONSOPORTEPREPANTALLA" where upper( alltrim( Entidad ) ) == upper( alltrim( "ItemArticulos" ) ) and upper( alltrim( Atributo ) ) == upper( alltrim( "ARTICULO" ) )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagSoportaPrePantalla()
				this.AssertEquals( "Debería haber detectado errores de validación (4).", 1, This.oValidarADN.oMockInformacionIndividual.Count )
				this.AssertEquals( "El error no es el esperado (4).", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )
				
				insert into Diccionario ( Entidad, Atributo, Dominio, Alta, ClaveForanea, Tags ) values ( "Factura", "FacturaDetalle", "DETALLEITEMARTICULOS", .t., "", "<SOPORTAPREPANTALLA>" )
				
				.oMockInformacionIndividual.Limpiar()
				.ValidarTagSoportaPrePantalla()
				this.AssertEquals( "No debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
				
			endwith

		endfunc
		
	*-----------------------------------------------------------------------------------------
	Function zTestU_LongitudMinimaClienteNombre
		local lcProyectoActivo as String 
		update diccionario set longitud=longitud+13 where upper( alltrim( entidad ) )=="CLIENTE" and inlist(Atributo, "PrimerNombre","SegundoNombre")
		with This.oValidarADN
			lcProyectoActivo = .cProyectoActivo
			.cProyectoActivo	= "COLORYTALLE"
			.oMockInformacionIndividual.Limpiar()
			.LongitudMinimaClienteNombre()
			this.AssertEquals( "Debería haber detectado errores de validación de la longitud atributo Nombre de la entidad Cliente", 1, .oMockInformacionIndividual.Count )
			.cProyectoActivo = lcProyectoActivo
		endwith
		update diccionario set longitud=longitud-13 where upper( alltrim( entidad ) )=="CLIENTE" and inlist(Atributo, "PrimerNombre","SegundoNombre")
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestValidarLongitudClienteOrigenEnValeDeCambio
	
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "VALEDECAMBIO", "ClienteOrigen", "VALCAMBIO", "cCliente", "C", 30 )
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTE", "Codigo", "CLI", "CLCOD", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTE", "Nombre", "CLI", "CLNOM", "C", 30 )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudClienteOrigenEnValeDeCambio()
			This.AssertEquals( "Debería haber detectado errores de validación del Cliente de Origen (1)", 1, .oMockInformacionIndividual.Count )
		endwith	
		
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTECHILE", "Codigo", "CLI", "CLCOD", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTECHILE", "Nombre", "CLI", "CLNOM", "C", 30 )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudClienteOrigenEnValeDeCambio()
			This.AssertEquals( "Debería haber detectado errores de validación del Cliente de Origen (2)", 2, .oMockInformacionIndividual.Count )
		endwith	
		
		update Diccionario set Longitud = 50 where upper( alltrim( Entidad ) ) == upper( alltrim( "VALEDECAMBIO" ) ) and upper( alltrim( Atributo ) ) == upper( alltrim( "ClienteOrigen" ) )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudClienteOrigenEnValeDeCambio()
			This.AssertEquals( "No debería haber detectado errores de validación del Cliente de Origen (3)", 0, .oMockInformacionIndividual.Count )
		endwith	
			
			
	endfunc		

	*-----------------------------------------------------------------------------------------
	Function ztestValidarLongitudClienteDestinoEnValeDeCambio
	
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "VALEDECAMBIO", "ClienteDestino", "VALCAMBIO", "cCliente", "C", 30 )
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTE", "Codigo", "CLI", "CLCOD", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTE", "Nombre", "CLI", "CLNOM", "C", 30 )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudClienteDestinoEnValeDeCambio()
			This.AssertEquals( "Debería haber detectado errores de validación del Cliente de Destino (1)", 1, .oMockInformacionIndividual.Count )
		endwith	
		
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTECHILE", "Codigo", "CLI", "CLCOD", "C", 10 )
		insert into Diccionario ( Entidad, Atributo, Tabla, Campo, TipoDato, Longitud ) values ( "CLIENTECHILE", "Nombre", "CLI", "CLNOM", "C", 30 )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudClienteDestinoEnValeDeCambio()
			This.AssertEquals( "Debería haber detectado errores de validación del Cliente de Destino (2)", 2, .oMockInformacionIndividual.Count )
		endwith	
		
		update Diccionario set Longitud = 50 where upper( alltrim( Entidad ) ) == upper( alltrim( "VALEDECAMBIO" ) ) and upper( alltrim( Atributo ) ) == upper( alltrim( "ClienteDestino" ) )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarLongitudClienteDestinoEnValeDeCambio()
			This.AssertEquals( "No debería haber detectado errores de validación del Cliente de Destino (3)", 0, .oMockInformacionIndividual.Count )
		endwith	
	
	endfunc		

	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarClavePrimariaEnITems
		local lcMensaje as String
		
		insert into Entidad ( Entidad, Tipo ) values ( "Manzana", "I" )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaEnITems()
			This.AssertEquals( "Debería haber detectado errores de validación ValidarClavePrimariaEnITems", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "El Item Manzana no tiene seteado un atributo claveprimaria"
			This.AssertEquals( "El mensaje no es el correcto", lcMensaje, .oMockInformacionIndividual.Item[1].cMensaje )
		endwith	
		insert into Diccionario( Entidad, ClavePrimaria ) values ( "Manzana", .T. )	
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarClavePrimariaEnITems()
			This.AssertEquals( "No Debería haber detectado errores de validación ValidarClavePrimariaEnITems", 0, .oMockInformacionIndividual.Count )
		endwith	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarNombredeItems
		local lcMensaje as String
		
		insert into Entidad ( Entidad, Tipo ) values ( "ItemDetalleManzana", "I" )
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarNombredeItems()
			This.AssertEquals( "Debería haber detectado errores de validación ValidarNombredeItems", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "Los items no pueden contener 'detalle' dentro de su nombre - ItemDetalleManzana"
			This.AssertEquals( "El mensaje no es el correcto", lcMensaje, .oMockInformacionIndividual.Item[1].cMensaje )
		endwith	
		Update entidad set Entidad = "ItemDetayeManzana" where Entidad = "ItemDetalleManzana"
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarNombredeItems()
			This.AssertEquals( "No Debería haber detectado errores de validación ValidarNombredeItems", 0, .oMockInformacionIndividual.Count )
		endwith	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarVisibilidadMuestraRelacion
		local lcMensaje as String
		
		insert into Entidad ( Entidad, Tipo ) values ( "ItemDetalleManzana", "I" )
		insert into Entidad ( Entidad, Tipo, Formulario ) values ( "ManzanaSinFormulario", "E", .F. )
		insert into Entidad ( Entidad, Tipo, Formulario ) values ( "Manzana", "E", .T. )
		insert into Diccionario ( Entidad, Atributo, Alta, MuestraRelacion ) values ( "ManzanaSinFormulario", "Verde", .F. , .T. )
		insert into Diccionario ( Entidad, ClaveForanea ) values ( "Tito", "Manzana" )
		insert into Diccionario ( Entidad, Atributo, Alta, MuestraRelacion ) values ( "Manzana", "Verde", .F. , .T. )
		insert into Diccionario ( Entidad, Atributo, Alta, MuestraRelacion ) values ( "ItemManzana", "ItemVerde", .F. , .T. )		
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarVisibilidadMuestraRelacion()
			This.AssertEquals( "Debería haber detectado errores de validación ValidarVisibilidadMuestraRelacion", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "Los Atributos MuestraRelacion deben tener alta en true Manzana - Verde"
			This.AssertEquals( "El mensaje no es el correcto", lcMensaje, .oMockInformacionIndividual.Item[1].cMensaje )
		endwith	
		Update Diccionario set Alta = .T. where Entidad = "Manzana"
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarVisibilidadMuestraRelacion()
			This.AssertEquals( "No Debería haber detectado errores de validación ValidarNombredeItems", 0, .oMockInformacionIndividual.Count )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarIndice_SqlServer_SoloUnCluster
		local lcMensaje as String
		insert into indice_sqlserver ( nombre, tabla, campos, ubicacion, escluster ) values ( "INDICE1", "CLI", "CODIGO", "SUCURSAL", .T. )
		insert into indice_sqlserver ( nombre, tabla, campos, ubicacion, escluster ) values ( "INDICE2", "CLI", "NOMBRE", "SUCURSAL", .F. )
		insert into indice_sqlserver ( nombre, tabla, campos, ubicacion, escluster ) values ( "INDICE3", "CLI", "CODIGO", "SUCURSAL", .T. )

		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarIndice_SqlServer_SoloUnCluster()
			This.AssertEquals( "Debería haber detectado errores de validación ValidarIndice_SqlServer_SoloUnCluster", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "Se ha especificado mas de un índice cluster para la tabla CLI en la tabla de ADN INDICE_SQLSERVER."
			This.AssertEquals( "El mensaje no es el correcto", lcMensaje, .oMockInformacionIndividual.Item[1].cMensaje )
		endwith	
		delete from indice_sqlserver where nombre = "INDICE3"
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarIndice_SqlServer_IndicesDuplicados()
			This.AssertEquals( "No Debería haber detectado errores de validación ValidarIndice_SqlServer_SoloUnCluster", 0, .oMockInformacionIndividual.Count )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarIndice_SqlServer_IndicesDuplicados
		local lcMensaje as String
		insert into indice_sqlserver ( nombre, tabla, campos, ubicacion, escluster ) values ( "INDICE1", "CLI", "CODIGO, Nombre, Apellido", "SUCURSAL", .F. )
		insert into indice_sqlserver ( nombre, tabla, campos, ubicacion, escluster ) values ( "INDICE2", "CLI", "NOMBRE", "SUCURSAL", .F. )
		insert into indice_sqlserver ( nombre, tabla, campos, ubicacion, escluster ) values ( "INDICE1", "CLI", "CODIGO", "SUCURSAL", .F. )

		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarIndice_SqlServer_IndicesDuplicados()
			This.AssertEquals( "Debería haber detectado errores de validación ValidarIndice_SqlServer_IndicesDuplicados", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "El índice INDICE1 para la tabla CLI se encuentra duplicado en la tabla de ADN INDICE_SQLSERVER."
			This.AssertEquals( "El mensaje no es el correcto", lcMensaje, .oMockInformacionIndividual.Item[1].cMensaje )
		endwith	
		delete from indice_sqlserver where nombre = "INDICE1" and campos = "CODIGO"
		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarIndice_SqlServer_IndicesDuplicados()
			This.AssertEquals( "No Debería haber detectado errores de validación ValidarIndice_SqlServer_IndicesDuplicados", 0, .oMockInformacionIndividual.Count )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarConsistenciaClavesCandidatas_ValidacionOk
		local lcMensaje as String
		insert into diccionario ( entidad, tabla, campo, clavecandidata, claveprimaria ) values ( "ENTIDAD1", "TABLA1", "CAMPO1", 1, .t. )
		insert into diccionario ( entidad, tabla, campo, clavecandidata ) values ( "ENTIDAD1", "TABLA1", "CAMPO2", 2 )
		insert into diccionario ( entidad, tabla, campo, clavecandidata, claveprimaria ) values ( "ENTIDAD2", "TABLA1", "CAMPO1", 1, .t. )
		insert into diccionario ( entidad, tabla, campo, clavecandidata ) values ( "ENTIDAD2", "TABLA1", "CAMPO2", 2 )

		insert into comprobantes ( descripcion ) values ( "ENTIDAD1" )
		insert into comprobantes ( descripcion ) values ( "ENTIDAD2" )

		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaClavesCandidatas()
			This.AssertEquals( "No Debería haber detectado errores de validación ValidarConsistenciaClavesCandidatas", 0, .oMockInformacionIndividual.Count )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarConsistenciaClavesCandidatas_ValidacionErronea
		local lcMensaje as String
		insert into diccionario ( entidad, tabla, campo, clavecandidata, claveprimaria ) values ( "ENTIDAD1", "TABLA1", "CAMPO1", 1, .t. )
		insert into diccionario ( entidad, tabla, campo, clavecandidata ) values ( "ENTIDAD1", "TABLA1", "CAMPO2", 2 )
		insert into diccionario ( entidad, tabla, campo, clavecandidata, claveprimaria ) values ( "ENTIDAD2", "TABLA1", "CAMPO1", 1, .t. )

		insert into comprobantes ( descripcion ) values ( "ENTIDAD1" )
		insert into comprobantes ( descripcion ) values ( "ENTIDAD2" )

		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()
			.ValidarConsistenciaClavesCandidatas()
			This.AssertEquals( "Debería haber detectado errores de validación ValidarConsistenciaClavesCandidatas", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "Las claves candidatas para la tabla TABLA1 son inconsistentes entre las distintas entidades."
			This.AssertEquals( "El mensaje no es el correcto", lcMensaje, .oMockInformacionIndividual.Item[1].cMensaje )
		endwith	
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarExistenciaEtiquetaEntidadesItem_ValidacionOk

		insert into Entidad ( Entidad , Tipo, FUNCIONALIDADES ) values ( "MERCEDES" , "I" , "<>" )
		insert into Diccionario ( Entidad, Atributo, Dominio, Etiqueta ) Values( "MERCEDESF1", "MOTOR","DETALLEMERCEDES", ""  )
	
		with This.oValidarADN
	
			.oMockInformacionIndividual.Limpiar()
			.cProyectoActivo = "COLORYTALLE"		
		
			.ValidarExistenciaEtiquetaEntidadesItem()
			
			
			This.AssertEquals( iif( .oMockInformacionIndividual.Count > 0, .oMockInformacionIndividual.Item[ .oMockInformacionIndividual.Count ].cMensaje, ;
				"No se ha podido validar la existencia de etiqueta en entidades Item"), 1, .oMockInformacionIndividual.Count )
								
		endwith	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarTagCopiaDesdeTxt
		local lcMensaje as String
		insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadTest1", "Atributo1", "CopiaDesdeTxt" )
		insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadTest2", "Atributo1", "CopiaDesdeTxt" )
		insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadTest3", "Atributo1", "CopiaDesdeTxt" )		
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarTagCopiaDesdeTxt()				
			this.AssertEquals( "No debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
			insert into Diccionario ( entidad, Atributo, Tags ) values ( "EntidadTest3", "Atributo2", "CopiaDesdeTxt" )	
			.oMockInformacionIndividual.Limpiar()
			.ValidarTagCopiaDesdeTxt()
			this.AssertEquals( "Debería haber detectado errores de validación.", 1, This.oValidarADN.oMockInformacionIndividual.Count )
			lcMensaje = "No puede haber más de una atributo con tag <COPIADSDETXT> en la misma entidad ( EntidadTest3 )"
			this.AssertEquals( "El error no es el correcto.", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )	
		EndWith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarAtributosKitsYParticipantes
		local lcMensaje as String
		insert into Diccionario ( entidad, Atributo, Dominio, ClaveForanea, Alta, Tags ) values ( "EntidadDePrueba", "Detalle", "DetalleItemDePrueba", "", .T., "<CONPARTICIPANTES>" )
		insert into Diccionario ( entidad, Atributo, Dominio, ClaveForanea, Alta ) values ( "ItemDePrueba", "Articulo", "Codigo", "Articulo", .T. )
		insert into Diccionario ( entidad, Atributo, Dominio, ClaveForanea, Alta ) values ( "ItemDePrueba", "Color", "Codigo", "Color", .T. )
		insert into Diccionario ( entidad, Atributo, Dominio, ClaveForanea, Alta ) values ( "ItemDePrueba", "Talle", "Codigo", "Talle", .T. )	
		with this.oValidarADN
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosKitsYParticipantes()							
			this.AssertEquals( "1. Debería haber detectado errores de validación.", 4, This.oValidarADN.oMockInformacionIndividual.Count )

			lcMensaje = "La entidad ItemDePrueba no tiene el atributo 'articulo' con despuesDeAsignacion = 'this.LimpiarColorYTalle()'"			
			this.AssertEquals( "2. El error no es el correcto.", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 4 ].cMensaje )	
			
			lcMensaje = "La entidad ItemDePrueba no tiene el atributo 'comportamiento' o no lo tiene de manera correcta (atributo foraneo debe ser 'Articulo.Comportamiento' y debe tener tabla y campo, tipo de dato N y longitud 1)"			
			this.AssertEquals( "3. El error no es el correcto.", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )						

			lcMensaje = "La entidad EntidadDePrueba no tiene el atributo 'KitsDetalle' o no lo tiene de manera correcta (debe tener tabla y campo, tipo de dato G, longitud 38 y dominio DETALLEITEMKITS)"
			this.AssertEquals( "4. El error no es el correcto.", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 3 ].cMensaje )									
			
			lcMensaje = "La entidad ItemDePrueba no tiene el atributo 'idkit' o no lo tiene de manera correcta (debe tener tabla y campo, tipo de dato G, longitud 38 y dominio CARACTER)"
			this.AssertEquals( "5. El error no es el correcto.", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 2 ].cMensaje )						
			
			insert into Diccionario ( entidad, Atributo, AtributoForaneo, Tabla, Campo, TipoDato, Longitud, Dominio ) values ( "ItemDePrueba", "Comportamiento", 'Articulo.Comportamiento', "Tabla", "Campo", "N", 1, "NUMERICO" )
			*insert into Diccionario ( entidad, Atributo, AtributoForaneo, Tabla, Campo, TipoDato, Longitud, Dominio ) values ( "ItemDePrueba", "EsKit", "", "Tabla", "Campo", "L", 1, "SINOBOOL" )
			insert into Diccionario ( entidad, Atributo, AtributoForaneo, Tabla, Campo, TipoDato, Longitud, Dominio ) values ( "EntidadDePrueba", "KitsDetalle", "", "Tabla", "Campo", "G", 38, "DETALLEITEMKITS" )
			insert into Diccionario ( entidad, Atributo, AtributoForaneo, Tabla, Campo, TipoDato, Longitud, Dominio ) values ( "ItemDePrueba", "Idkit", "", "Tabla", "Campo", "G", 38, "CARACTER" )
			update diccionario set despuesDeAsignacion = "this.LimpiarColorYTalle()" where entidad = "ItemDePrueba" and Atributo = "Articulo"
			
			.oMockInformacionIndividual.Limpiar()
			.ValidarAtributosKitsYParticipantes()		
			this.AssertEquals( "6.No Debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
		endwith	
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ztestU_ValidarItemKitsVsItemArticulosVentas
		local lcMensaje as String
		insert into Entidad ( Entidad ) values ( "ITEMARTICULOSVENTAS" )
		insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMARTICULOSVENTAS","ARTICULO", "C", "CARACTER", 19, .t. )						
		insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar, Sumarizar, Tags ) Values( "ITEMARTICULOSVENTAS","CANTIDAD", "N", "10", 19, .t., "Cantidad", "<CONDICIONSUMARIZAR:!iif(this.lEsNavegacion,this.EsItemSeniaAlNavegar(Articulo),this.EsItemSenia(lnItem))>" )
		insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMARTICULOSVENTAS","COMPORTAMIENTO", "N", "NUMERICO", 1, .f. )
		
		insert into Entidad ( Entidad ) values ( "ITEMKITS" )
		insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMKITS","ARTICULO", "C", "CARACTER", 19, .t. )						
		insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar, Sumarizar, Tags ) Values( "ITEMKITS","CANTIDAD", "N", "10", 19, .t., "Cantidad", "<CONDICIONSUMARIZAR:!iif(this.lEsNavegacion,this.EsItemSeniaAlNavegar(Articulo),this.EsItemSenia(lnItem))>" )		

		with this.oValidarADN
			.cProyectoActivo = "COLORYTALLE"
			.oMockInformacionIndividual.Limpiar()
			.ValidarItemKitsVsItemArticulosVentas()
			lcMensaje = "Error en la entidad ITEMKITS. El atributo COMPORTAMIENTO de ITEMARTICULOSVENTAS, debería estar en ITEMKITS."
			this.AssertEquals( "1. El error no es el correcto.", lcMensaje, This.oValidarADN.oMockInformacionIndividual.Item[ 1 ].cMensaje )	
			
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMKITS","COMPORTAMIENTO", "N", "NUMERICO", 1, .f. )			
			.oMockInformacionIndividual.Limpiar()
			.ValidarItemKitsVsItemArticulosVentas()
			this.AssertEquals( "2.No Debería haber detectado errores de validación.", 0, This.oValidarADN.oMockInformacionIndividual.Count )
			
		endwith		
	endfunc 

*-----------------------------------------------------------------------------------------
	Function ztest_ValidarTagAdmiteBusquedaSubEntidad

		with This.oValidarADN			
			.oMockInformacionIndividual.Limpiar()

			insert into diccionario ( entidad, atributo , admitebusqueda, tags ) values ( "entidad1", "Atributo1", 1, "<ADMITEBUSQUEDASUBENTIDAD>" )
			
			.ValidarTagAdmiteBusquedaSubEntidad_Aux("diccionario" ,diccionario.tags)
			This.AssertEquals( "La entidad Entidad1 tiene cargado el tag <ADMITEBUSQUEDASUBENTIDAD> y no tiene cargada la tabla ni el campo, ni la claveforanea, por lo que deberia haber dado error", 1, .oMockInformacionIndividual.Count )

			delete from diccionario 
			.oMockInformacionIndividual.Limpiar()

		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ztest_EsAtributoDetalle

		with This.oValidarADN			
			insert into entidad ( entidad, formulario, tipo ) values ( "entidad1", .t., "I" )
			
			This.Asserttrue( "Debería haber respondido error, ya la la entidad es un detalle", .EsAtributoDetalle( entidad.entidad ) )

			delete from entidad 
		endwith
	endfunc

	
	*-----------------------------------------------------------------------------------------
	function ztest_TieneMasDeUnAtributoAMismaClaveForanea
		local llResultado as Boolean
		
		with This.oValidarADN			
			insert into diccionario ( entidad, atributo, claveforanea, tags ) values ( "ENTIDAD_1", "Atributo_1", "CLIENTE", "<ADMITEBUSQUEDASUBENTIDAD>" )
			insert into diccionario ( entidad, atributo, claveforanea, tags ) values ( "ENTIDAD_1", "Atributo_2", "CLIENTE", "<ADMITEBUSQUEDASUBENTIDAD>" )

			llResultado = .TieneMasDeUnAtributoAMismaClaveForanea(upper(diccionario.entidad), alltrim(diccionario.claveforanea) )
			This.Asserttrue( "La entidad Entidad_1 posee mas de un atributo con la misma clave foranea (CLIENTE) y el tag <ADMITEBUSQUEDASUBENTIDAD>, por lo que deberia haber dado error", llResultado  )

			select diccionario
			replace diccionario.claveforanea with "PROVEEDOR"
			llResultado = .TieneMasDeUnAtributoAMismaClaveForanea(upper(diccionario.entidad), alltrim(diccionario.claveforanea) )
			This.Asserttrue( "No debería haber dado error ya que los atributos de la entidad Entidad_1 con el tag <ADMITEBUSQUEDASUBENTIDAD> tienen diferente clave foranea", !llResultado  )

			delete from diccionario 
		endwith
		
	endfunc 
	
EndDefine

	
*-----------------------------------------------------------------------------------------
function InsertarDatosParaCalculodePrecios() as Void
	insert into Entidad ( entidad ) values ( "PrecioDeArticulo" )
	insert into Diccionario ( entidad, atributo ) values ( "PrecioDeArticulo", "Articulo" )
	insert into Diccionario ( entidad, atributo ) values ( "PrecioDeArticulo", "Color" )
	insert into Diccionario ( entidad, atributo ) values ( "PrecioDeArticulo", "Talle" )
	insert into Entidad ( entidad ) values ( "CalculoDePrecios" )
endfunc


*-----------------------------------------------------------------------------------------
define class ValidarADNBindeo as ValidarAdn of ValidarAdn.Prg
	*-----------------------------------------------------------------------------------------
	function ControlEjecucionMetodos( txPar1, txpar2, txPar3 ) as void
		if !this.ldestroy
			local lcMetodo as String
			local array myArray[1]
			AEVENTS( myArray, 0 )
			lcMetodo = padl( upper( alltrim( myArray(2,1) ) ), 200 )
			if !seek( lcMetodo, "c_Validaciones", "Nombre" )
				insert into c_Validaciones ( Nombre ) values ( lcMetodo )
			EndIf	
		endif
	endfunc
	*-----------------------------------------------------------------------------------------
	function RealizarBindeos( toColeccion as Object ) as Void
		local lcMetodo as String
		for each lcMetodo in toColeccion
			bindevent( this, lcMetodo, This, "ControlEjecucionMetodos" )
		endfor

	endfunc
	*-----------------------------------------------------------------------------------------
	function Abrirtablas() as Void
		dodefault()
		select 0
		create cursor c_Validaciones ( Nombre c( 200 ) )
		index on Nombre tag Nombre
	endfunc 
	*-----------------------------------------------------------------------------------------
	function CerrarTablas() as Void
		dodefault()
		use in select( "c_Validaciones" )
	endfunc 
 
enddefine


****************************
define class ObjetoBindeo as custom

	lEjecutoValidarDominioImagen = .f.
	lEjecutoValidarTipoDeValorCheque = .f.	
	
	function ValidarDominioImagen() as void
		this.lEjecutoValidarDominioImagen = .t.
	endfunc
	
	function ValidarTipoDeValorCheque() as void
		this.lEjecutoValidarTipoDeValorCheque = .t.
	endfunc


enddefine

****************************
define class ValidarADNAux as MockValidarADN &&ValidarADN of ValidarADN.prg

	
	*-----------------------------------------------------------------------------------------
	function Init( tcRuta ) as Void
		dodefault( tcRuta )
		this.oAccesoDatos.AbrirTabla( "Entidad",			.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "Diccionario",		.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "Dominio",			.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "Estilos",			.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "Controles",			.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "Propiedades",		.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "EstructuraTablas",	.t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "SeguridadEntidades",	.t., this.cRutaADN )			
		this.oAccesoDatos.AbrirTabla( "SeguridadEntidadesDefault",	.t., this.cRutaADN )						
		this.oAccesoDatos.AbrirTabla( "MenuAltasItems",		.t., this.cRutaADN )			
		this.oAccesoDatos.AbrirTabla( "Buscador",			.t., this.cRutaADN )			
		this.oAccesoDatos.AbrirTabla( "BuscadorDetalle", .t., this.cRutaADN )
		this.oAccesoDatos.AbrirTabla( "TipoDeValores", .t., this.cRutaADN )									
		this.oAccesoDatos.AbrirTabla( "ParametrosYRegistrosEspecificos",.t., this.cRutaADN )

		select * from Propiedades into cursor cPropiedades readwrite
		select * from Dominio     where .f. into cursor cDominio     readwrite
		select * from Estilos     where .f. into cursor cEstilos     readwrite
		select * from Controles   where .f. into cursor cControles   readwrite
		select * from Entidad     where .f. into cursor cEntidad     readwrite
		select * from Diccionario where .f. into cursor cDiccionario readwrite
		select * from EstructuraTablas where .f. into cursor cEstructuraTablas readwrite
		select * from SeguridadEntidades where .f. into cursor cSeguridadEntidades readwrite
		select * from SeguridadEntidadesDefault where .f. into cursor cSeguridadEntidadesDefault readwrite			
		select * from MenuAltasItems where .f. into cursor cMenuAltasItems readwrite			
		select * from Parametros where .f. into cursor cParametros readwrite			
		select * from JerarquiaParametros where .f. into cursor cJerarquiaParametros readwrite			
		select * from Buscador where .f. into cursor cBuscador readwrite
		select * from BuscadorDetalle where .f. into cursor cBuscadorDetalle readwrite
		select * from TipoDeValores where .f. into cursor cTipoDeValores readwrite
		select * from ParametrosYRegistrosEspecificos where .f. into cursor cParametrosYRegistrosEspecificos readwrite

		this.CerrarTablas( )
		
		select * from cEntidad     into cursor Entidad     readwrite
		select * from cDiccionario into cursor Diccionario readwrite
		select * from cDominio     into cursor Dominio     readwrite
		select * from cEstilos     into cursor Estilos     readwrite
		select * from cControles   into cursor Controles   readwrite
		select * from cPropiedades into cursor Propiedades readwrite
		select * from cEstructuraTablas into cursor EstructuraTablas readwrite
		select * from cSeguridadEntidades into cursor SeguridadEntidades readwrite
		select * from cSeguridadEntidadesDefault into cursor SeguridadEntidadesDefault readwrite			
		select * from cMenuAltasItems where .f. into cursor MenuAltasItems readwrite			
		select * from cParametros where .f. into cursor Parametros readwrite			
		select * from cJerarquiaParametros where .f. into cursor JerarquiaParametros readwrite			
		select * from cBuscador where .f. into cursor Buscador readwrite			
		select * from cBuscadorDetalle where .f. into cursor BuscadorDetalle readwrite			
		select * from cTipoDeValores where .f. into cursor TipoDeValores readwrite			
		select * from cParametrosYRegistrosEspecificos where .f. into cursor ParametrosYRegistrosEspecificos readwrite
		
		use in select( "cEntidad" )
		use in select( "cDiccionario" )
		use in select( "cDominio" )
		use in select( "cEstilos" )
		use in select( "cControles" )
		use in select( "cPropiedades" )
		use in select( "cEstructuraTablas" )
		use in select( "cSeguridadEntidades" )
		use in select( "cSeguridadEntidadesDefault" )			
		use in select( "cMenuAltasItems" )			
		use in select( "cParametros" )
		use in select( "cJerarquiaParametros" )
		use in select( "cBuscador" )			
		use in select( "cBuscadorDetalle" )
		use in select( "cTipoDeValores" )
		use in select( "cParametrosYRegistrosEspecificos" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDetallesNormalizadosV2Aux() as VOID
		return this.ValidarDetallesNormalizadosV2()
	endfunc


	*-----------------------------------------------------------------------------------------
	function release() as Void
		dodefault()
		this.CerrarTablas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function MockAgregarInformacionGeneral( tcDescripcion As String ) As VOID
		This.AgregarInformacionGeneral( tcDescripcion )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TEST_ObtenerOValidarAdnListadosOrganic() as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		return this.oValidarAdnListadosOrganic
	endfunc 

enddefine

*-------------------------------------
*-------------------------------------
define class MockValidarADN as ValidarADN of ValidarADN.prg

	oMockInformacionIndividual = null
	oZoo = null


	*-----------------------------------------------------------------------------------------
	Function Init( tcRuta ) As VOID
		dodefault( tcRuta )
		This.oMockInformacionIndividual = This.oInformacionIndividual
		this.oZoo = newobject( "MockZoo", "zTestValidarAdn.prg" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarFiltrosTransferencias_TEST() as Void
		this.ValidarFiltrosTransferencias()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacionIndividual() as Object
		return This.oInformacionIndividual
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarInformacionIndividual() as VOID
		This.oMockInformacionIndividual.Limpiar()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ReemplazarInformacionIndividual( toInformacionIndividual as Object ) as Void
		This.oInformacionIndividual = toInformacionIndividual
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InsertarStockCombinacionyEquivalencias() as Void
			insert into Dominio ( Dominio ) values ( "CODIGONUMERICO" )		
			insert into Dominio ( Dominio ) values ( "NUMERICO" )				
			insert into Dominio ( Dominio ) values ( "DESCRIPCION" )					
		
			insert into Entidad ( Entidad, comportamiento, descripcion ) values ( "STOCKCOMBINACION", "T", "pepe" )
			insert into Entidad ( Entidad, comportamiento, descripcion ) values ( "EQUIVALENCIA", "T", "pepe2" )
		
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "STOCKCOMBINACION", "ID", "N", 4, 0, "CODIGONUMERICO", "IDSTOCK", 0, .T. )
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "STOCKCOMBINACION", "ARTICULO", "C", 8, 0, "DESCRIPCION", "ART", 1, .F. )
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "STOCKCOMBINACION", "COLOR", "C", 8, 0, "DESCRIPCION", "COLO", 2, .F. )
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "STOCKCOMBINACION", "TALLE", "C", 2, 0, "DESCRIPCION", "TALL", 3, .F. )												
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "STOCKCOMBINACION", "CANTIDAD", "N", 4, 0, "NUMERICO" , "CANT", 0, .F. )												
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "EQUIVALENCIA", "ARTICULO", "C", 8, 0,  "DESCRIPCION", "ART", 1, .T. )
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "EQUIVALENCIA", "COLOR", "C", 8, 0,  "DESCRIPCION", "COLO", 2, .F. )
			insert into Diccionario ( Entidad, Atributo, tipodato, longitud, decimales, dominio, campo, clavecandidata, claveprimaria ) ;
				values ( "EQUIVALENCIA", "TALLE", "C", 2, 0, "DESCRIPCION", "TALL", 3, .F. )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarStockCombinacionyEquivalencias() as Void
		delete from Dominio where inlist( upper( alltrim( Dominio ) ), "CODIGONUMERICO", "NUMERICO", "DESCRIPCION" )
		delete from Entidad where inlist( upper( alltrim( Entidad ) ), "STOCKCOMBINACION", "EQUIVALENCIA" )
		delete from Diccionario where inlist( upper( alltrim( Entidad ) ), "STOCKCOMBINACION", "EQUIVALENCIA" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarFormatoDescripcionEnComprobantesAux() as Void
		this.ValidarFormatoDescripcionEnComprobantes()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTagsComprobantes_Test() as Void
		this.ValidarTagsComprobantes()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIndividualidadDeTagDesactivableYAnulable_AUX() as Void
		this.ValidarIndividualidadDeTagDesactivableYAnulable()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarQueEntidadDesactivableSeaAuditable_AUX() as Void
		this.ValidarQueEntidadDesactivableSeaAuditable()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarQueEntidadConAuditoriaTengaModulosListado_AUX() as Void
		this.ValidarQueEntidadConAuditoriaTengaModulosListado()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoFijosYConfigurables_AUX() as Void
		this.ValidarSaltosDeCampoFijosYConfigurables()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYGenHabilitar_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYGenHabilitar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYCAbeceraDetalle_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYCAbeceraDetalle()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYDetalleCabecera_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYDetalleCabecera()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYDetalleAtributoObligatorio_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYDetalleAtributoObligatorio()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYEtiquetas_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYEtiquetas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYAlta_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYAlta()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSaltosDeCampoConfigurablesYDominiosInvalidos_AUX() as Void
		this.ValidarSaltosDeCampoConfigurablesYDominiosInvalidos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFechasEnCampoValorSugerido_AUX() as Void
		this.ValidarFechasEnCampoValorSugerido()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarHorasEnCampoValorSugerido_AUX() as Void
		this.ValidarHorasEnCampoValorSugerido()
	endfunc 

    *-----------------------------------------------------------------------------------------
    function ValidarTagPermitidos_AUX( tcCursor as String, tcTag as String, tcAdn as String ) as Void
         this.ValidarTagPermitidos( tcCursor, tcTag, tcAdn )
    endfunc

	*-----------------------------------------------------------------------------------------
	function TEST_ObtenerOValidarAdnListadosOrganic() as ValidarAdnListadosOrganic of ValidarAdnListadosOrganic.prg
		return this.oValidarAdnListadosOrganic
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosCombinacion() as Object
		local loAtributos as Object
		loAtributos = _screen.zoo.crearobjeto( "ZooColeccion" )
		loAtributos.Add("ARTICULO")
		loAtributos.Add("COLOR")
		loAtributos.Add("TALLE")
		return loAtributos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTagAdmiteBusquedaSubEntidad_Aux( tcCursor as String, tcTag as String ) as Void
		this.ValidarTagAdmiteBusquedaSubEntidad( tcCursor, tcTag )
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
define class MockZoo as Custom

	cRutaInicial = ""
	App = null
	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		dodefault()
		this.cRutaInicial = _screen.zoo.crutAINICIAL
		this.App = newobject( "custom" )
		this.App.addproperty( "cProyecto", _Screen.Zoo.App.cPrOYECTO )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerHerenciaDenombre( tcCadenaPrefijo as string, tcEntidad as string, tcSubfijo as string )
		return _Screen.zoo.obtenerHerenciaDeNombre( tcCadenaPrefijo, tcEntidad, tcSubfijo )
	endfunc 
enddefine

