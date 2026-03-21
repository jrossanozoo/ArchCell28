**********************************************************************
Define Class zTestValidarADNComponenteSenias as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestValidarADNComponenteSenias of zTestValidarADNComponenteSenias.prg
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
	
	*---------------------------------
	Function Setup
		with This
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
			.oValidarADN.oAccesoDatos.AbrirTabla( "Parametros",						.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "JerarquiaParametros",			.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "RelaNumeraciones",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "AtributosGenericos",				.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TransferenciasAgrupadas",		.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TransferenciasAgrupadasItems",	.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Transferencias",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "TransferenciasFiltros",			.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "ListCampos",						.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "RelaTriggers",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Buscador",						.t., .oValidarADN.cRutaADN )			
			.oValidarADN.oAccesoDatos.AbrirTabla( "BuscadorDetalle",				.t., .oValidarADN.cRutaADN )						
			.oValidarADN.oAccesoDatos.AbrirTabla( "RelaComponente",					.t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Componente",						.t., .oValidarADN.cRutaADN )
			
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
			select * from Parametros where .f. into cursor cParametros readwrite			
			select * from JerarquiaParametros where .f. into cursor cJerarquiaParametros readwrite			
			select * from RelaNumeraciones where .f. into cursor cRelaNumeraciones  readwrite
			select * from AtributosGenericos where .f. into cursor cAtributosGenericos  readwrite
			select * from TransferenciasAgrupadas where .f. into cursor cTransferenciasAgrupadas readwrite
			select * from TransferenciasAgrupadasItems where .f. into cursor cTransferenciasAgrupadasItems readwrite
			select * from Transferencias where .f. into cursor cTransferencias readwrite
			select * from TransferenciasFiltros where .f. into cursor cTransferenciasFiltros readwrite
			select * from ListCampos where .f. into cursor cListCampos readwrite
			select * from RelaTriggers where .f. into cursor cRelaTriggers readwrite
			select * from Buscador where .f. into cursor cBuscador readwrite
			select * from BuscadorDetalle where .f. into cursor cBuscadorDetalle readwrite			
			select * from RelaComponente where .f. into cursor cRelaComponente readwrite	
			select * from Componente where .f. into cursor cComponente readwrite	
			
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
			select * from cParametros where .f. into cursor Parametros readwrite			
			select * from cJerarquiaParametros where .f. into cursor JerarquiaParametros readwrite		
			select * from cRelaNumeraciones where .f. into cursor RelaNumeraciones  readwrite	
			select * from cAtributosGenericos where .f. into cursor AtributosGenericos readwrite
			select * from cTransferenciasAgrupadas where .f. into cursor TransferenciasAgrupadas readwrite
			select * from cTransferenciasAgrupadasItems where .f. into cursor TransferenciasAgrupadasItems readwrite
			select * from cTransferencias where .f. into cursor Transferencias readwrite
			select * from cTransferenciasFiltros where .f. into cursor TransferenciasFiltros readwrite
			select * from cListCampos where .f. into cursor ListCampos readwrite
			select * from cRelaTriggers where .f. into cursor RelaTriggers readwrite
			select * from cBuscador where .f. into cursor Buscador readwrite
			select * from cBuscadorDetalle where .f. into cursor BuscadorDetalle readwrite
			select * from cRelaComponente where .f. into cursor RelaComponente readwrite
			select * from cComponente where .f. into cursor Componente readwrite
						
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
			use in select( "cParametros" )
			use in select( "cJerarquiaParametros" )
			use in select( "cRelaNumeraciones" )
			use in select( "cAtributosGenericos")
			use in select( "cTransferenciasAgrupadas" )
			use in select( "cTransferenciasAgrupadasItems" )
			use in select( "cTransferencias" )
			use in select( "cTransferenciasFiltros" )
			use in select( "cListCampos" )
			use in select( "cRelaTriggers" )
			use in select( "cBuscador" )
			use in select( "cBuscadorDetalle" )
			use in select( "cRelaComponente" )
			use in select( "cComponente" )
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
		EndWith
	endfunc
	

	*-----------------------------------										
	function zTestValidarAtributosParaComponenteSenia
		local lcMsgErr as String
		lcMsgErr = ""
		
		with This.oValidarADN

			&& Entidad E1
			insert into Entidad ( Entidad ) values ( "E1" )
			insert into Diccionario( entidad, atributo, tipodato, dominio, longitud, alta, genHabilitar  ) Values( "E1","IDSENIA", "C", "CARACTER", 38, .f., .f. )
			insert into Diccionario( entidad, atributo, tipodato, dominio, longitud, alta, genHabilitar ) Values( "E1","FECHAVTOSENIA", "D", "FECHACALENDARIO", 8, .t., .t. )
			insert into Diccionario( entidad, atributo, tipodato, dominio, longitud, alta, genHabilitar ) Values( "E1","ARTICULOSSENIADOSDETALLE", "G", "DETALLEITEMARTICULOSSENIADOS", 38, .t., .t. )

			&& COMPONENTE
			insert into Componente ( Componente, GRABA, Entidad, combinacion ) values ( "SENIAS", .T., "SENIA", "SENIA" )

			&& RELACOMPONENTES						
			insert into RelaComponente ( Entidad, Componente ) values ( "E1", "SENIAS" )
			insert into RelaComponente ( Entidad, Componente ) values ( "ITEMARTICULOSSENIADOS", "PRECIOS" )
									
			&& ITEMARTICULOSVENTAS
			insert into Entidad ( Entidad ) values ( "ITEMARTICULOSVENTAS" )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMARTICULOSVENTAS","ARTICULO", "C", "CARACTER", 19, .t. )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar, Sumarizar, Tags ) Values( "ITEMARTICULOSVENTAS","CANTIDAD", "N", "10", 19, .t., "Cantidad", "<MULTIPLICA:#CAB.SignoDeMovimiento>;<CONDICIONSUMARIZAR:!iif(this.lEsNavegacion,{item}.Articulo=This.cArticuloSenia,{item}.Articulo_PK=This.cArticuloSenia)>" )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMARTICULOSVENTAS","IDSENIACANCELADA", "C", "CARACTER", 38, .f. )

			&& ITEMARTICULOSSENIADOS
			insert into Entidad ( Entidad, HERENCIA ) values ( "ITEMARTICULOSSENIADOS", "ARTICULOSSENIADOS" )			
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMARTICULOSSENIADOS","ARTICULO", "C", "CARACTER", 19, .t. )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar, Sumarizar, Tags ) Values( "ITEMARTICULOSSENIADOS","CANTIDAD", "N", "10", 19, .t., "Cantidad", "" )						
			
			&& SENIAS
			insert into Entidad ( Entidad, FUNCIONALIDADES ) values ( "SENIA", "<ANULABLE>" )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CLIENTE", "SENIA",  "CLIENTE", "C", .t., .F. )									
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "PRECIOCONIMPUESTOS", "SENIA",  "PRUNCONIMP", "N", .F., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "PRECIOSINIMPUESTOS", "SENIA",  "PRUNSINIMP", "N", .F., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "ARTICULOSDETALLE", "SENIADET",  "CODIGO", "G", .t., .T. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "LETRAORIGEN", "SENIA",  "FLETRA", "C", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "NUMEROORIGEN", "SENIA",  "FNUMCOMP", "N", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "PUNTODEVENTAORIGEN", "SENIA",  "FPTOVEN", "N", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "TIPOCOMPROBANTEORIGEN", "SENIA",  "FACTTIPO", "N", .F., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CLIENTE", "SENIA",  "CLIENTE", "C", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CVERSIONORIGEN", "SENIA",  "CVERSION", "C", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CBASEDEDATOSORIGEN", "SENIA",  "CBASEDEDAT", "C", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "PRECIO", "SENIA",  "FPRECIO", "N", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "COMPROBANTEAFECTANTE", "SENIA", "COMPA", "C", .F., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "LETRAAFECTANTE", "SENIA",  "FLETRAA", "C", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "NUMEROAFECTANTE", "SENIA",  "FNUMCOMPA", "N", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "TIPOCOMPROBANTEAFECTANTE", "SENIA",  "FACTTIPOA", "N", .F., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CSERIEAFECTANTE", "SENIA",  "CSERIEA", "C", .t., .F. )
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CLIENTE", "SENIA",  "CLIENTE", "C", .t., .F. )			
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CVERSIONAFECTANTE", "SENIA",  "CVERSIONA", "C", .t., .F. )			
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CBASEDEDATOSAFECTANTE", "SENIA",  "CBDEDATA", "C", .t., .F. )			
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "FECHAORIGEN", "SENIA",  "FECHA", "D", .t., .F. )			
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "FECHAAFECTANTE", "SENIA",  "FECHAA", "D", .t., .F. )			
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "DESCRIPCIONTIPOCOMPROBANTEORIGEN", "",  "", "C", .t., .F. )			
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "DESCRIPCIONTIPOCOMPROBANTEAFECTANTE", "",  "", "C", .t., .F. )						
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "CSERIEORIGEN", "SENIA",  "CSERIE", "C", .t., .F. )						
			
			&& ITEMSENIAS
			insert into Entidad ( Entidad ) values ( "ITEMSENIA" )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMARTICULOSSENIADOS","ARTICULO", "C", "CARACTER", 19, .t. )

			&& SENIAPENDIENTE
			insert into Entidad ( Entidad ) values ( "SENIAPENDIENTE" )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "SENIAPENDIENTE","CODIGO", "C", "CARACTER", 19, .t. )
			
			&& ITEMSENIAPENDIENTE
			insert into Entidad ( Entidad ) values ( "ITEMSENIAPENDIENTE" )
			insert into Diccionario( Entidad, Atributo, TipoDato, Dominio, LONGITUD, genHabilitar ) Values( "ITEMSENIAPENDIENTE","ARTICULO", "C", "CARACTER", 19, .t. )
									
			&&&&&&& CASO 0 - EL COMPONENTE SENIA TIENE TODO LO NECESARIO EN EL ADN Y NO HAY ERROR.
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia()
			This.AssertEquals( "Cantidad De Errores Incorrectos (A)", 0, .oMockInformacionIndividual.Count )
		
			&&&&&&& CASO 1 - ELIMINACION DE UN ATRIBUTO DE LA ENTIDAD SENIA
			delete from Diccionario where Entidad = "SENIA" and Atributo = "NUMEROAFECTANTE"			
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia()
			This.AssertEquals( "Cantidad De Errores Incorrectos (B)", 1, .oMockInformacionIndividual.Count )
			
			lcMsgErr = "Error en la entidad SENIA. Debería tener el atributo: NUMEROAFECTANTE."
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (B)", lcMsgErr, .oMockInformacionIndividual.Item[ 1 ].cMensaje )	
			insert into Diccionario( Entidad, Atributo, TABLA, CAMPO, TipoDato, ALTA, genHabilitar ) Values( "SENIA", "NUMEROAFECTANTE", "SENIA",  "FNUMCOMPA", "N", .t., .F. )

			&&&&&&& CASO 2 - MODIFIACION DE UN ATRIBUTO DE LA ENTIDAD SENIA
			select DICCIONARIO
			locate for upper( alltrim( Entidad ) ) == "SENIA" and upper( alltrim( Atributo ) ) == "NUMEROORIGEN"
			replace TipoDato with "C", genHabilitar with .t. in ( "Diccionario" )

			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia()			
			This.AssertEquals( "Cantidad De Errores Incorrectos (C)", 2, .oMockInformacionIndividual.Count )
			lcMsgErr = "Error en la entidad SENIA. El tipo de datos del atributo NUMEROORIGEN debe ser de tipo: N."
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (C)", lcMsgErr, .oMockInformacionIndividual.Item[ 1 ].cMensaje )	

			lcMsgErr = "Error en la entidad SENIA. El estado de GenHabilitar del atributo NUMEROORIGEN, es incorrecto. "
			This.AssertEquals( "El mensaje de error 2 es incorrecto. (C)", lcMsgErr, .oMockInformacionIndividual.Item[ 2 ].cMensaje )	

			select DICCIONARIO
			locate for upper( alltrim( Entidad ) ) == "SENIA" and upper( alltrim( Atributo ) ) == "NUMEROORIGEN"
			replace TipoDato with "N", genHabilitar with .F. in ( "Diccionario" )		
			
			&&&&&&& CASO 4 - MODIFIACION ELIMINACION DE LOS ATRIBUTOS DEL COMPROBANTE REQUERIDOS POR EL COMPONENTE SENIAS
			select DICCIONARIO
			locate for upper( alltrim( Entidad ) ) == "E1" and upper( alltrim( Atributo ) ) == "IDSENIA"
			replace Atributo with "", ENTIDAD with "" in ( "Diccionario" )
			
			locate for upper( alltrim( Entidad ) ) == "E1" and upper( alltrim( Atributo ) ) == "FECHAVTOSENIA"
			replace Atributo with "", ENTIDAD with "" in ( "Diccionario" )

			locate for upper( alltrim( Entidad ) ) == "E1" and upper( alltrim( Atributo ) ) == "ARTICULOSSENIADOSDETALLE"
			replace Atributo with "", ENTIDAD with "" in ( "Diccionario" )						
			
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia()			
			
			This.AssertEquals( "Cantidad De Errores Incorrectos (D)", 3, .oMockInformacionIndividual.Count )
			lcMsgErr = "Error en la entidad E1. La entidad tiene el componente Senias y no tiene el atributo IDSENIA."
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (D)", lcMsgErr, .oMockInformacionIndividual.Item[ 1 ].cMensaje )	

			lcMsgErr = "Error en la entidad E1. La entidad tiene el componente Senias y no tiene el atributo FECHAVTOSENIA."
			This.AssertEquals( "El mensaje de error 2 es incorrecto. (D)", lcMsgErr, .oMockInformacionIndividual.Item[ 2 ].cMensaje )				

			lcMsgErr = "Error en la entidad E1. La entidad tiene el componente Senias y no tiene el atributo ARTICULOSSENIADOSDETALLE."
			This.AssertEquals( "El mensaje de error 2 es incorrecto. (D)", lcMsgErr, .oMockInformacionIndividual.Item[ 3 ].cMensaje )
						
			insert into Diccionario( entidad, atributo, tipodato, dominio, longitud, alta, genHabilitar  ) Values( "E1","IDSENIA", "C", "CARACTER", 38, .f., .f. )
			insert into Diccionario( entidad, atributo, tipodato, dominio, longitud, alta, genHabilitar ) Values( "E1","FECHAVTOSENIA", "D", "FECHACALENDARIO", 8, .t., .t. )
			insert into Diccionario( entidad, atributo, tipodato, dominio, longitud, alta, genHabilitar ) Values( "E1","ARTICULOSSENIADOSDETALLE", "G", "DETALLEITEMARTICULOSSENIADOS", 38, .t., .t. )			
			
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia()
			This.AssertEquals( "La validación deberia ser existosa (Z)", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc




	
EndDefine


****************************
define class ObjetoBindeo as custom

	lEjecutoValidarDominioImagen = .f.
	
	function ValidarDominioImagen() as void
		this.lEjecutoValidarDominioImagen = .t.
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
			this.oAccesoDatos.AbrirTabla( "BuscadorDetalle",			.t., this.cRutaADN )	
			******************************************************************
			this.oAccesoDatos.AbrirTabla( "componente",			.t., this.cRutaADN )
			this.oAccesoDatos.AbrirTabla( "relacomponente",			.t., this.cRutaADN )

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
			******************************************************************
			select * from componente where .f. into cursor cComponente readwrite
			select * from relacomponente where .f. into cursor cRelacomponente readwrite			
			

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
			******************************************************************			
			select * from cComponente where .f. into cursor Componente readwrite			
			select * from cRelacomponente where .f. into cursor relacomponente readwrite	

			
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
			******************************************************************					
			use in select( "cComponente " )			
			use in select( "cRelacomponente " )			
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

	
enddefine

*-------------------------------------
*-------------------------------------
define class MockValidarADN as ValidarADN of ValidarADN.prg

	oMockInformacionIndividual = null
	*-----------------------------------------------------------------------------------------
	Function Init( tcRuta ) As VOID
		dodefault( tcRuta )
		This.oMockInformacionIndividual = This.oInformacionIndividual
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

enddefine
