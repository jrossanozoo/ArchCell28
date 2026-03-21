**********************************************************************
Define Class zTestValidarADNCopiaDeDetalles as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestValidarADNCopiaDeDetalles of zTestValidarADNCopiaDeDetalles.prg
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
	Function zTestTagEnAtributoQueNoEsDetalle
		
		with This.oValidarADN

			insert into Diccionario( entidad, atributo, Dominio, tags ) Values( "E1","NOESDETALLE", "DOMINIO" , "<COPIADETALLE>" )

			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnCopiaDeDetalles.ValidarTagEnAtributoDetalle()

			this.AssertEquals( "Debiera haberse ejecutado la validación de detalles.", 1, .oMockInformacionIndividual.Count )
			this.AssertEquals( "Mensaje incorrecto(2)", "El atributo NOESDETALLE de la entidad E1 tiene un atributo marcado COPIADETALLE y no es un detalle o no esta con alta en Verdadero.", .oMockInformacionIndividual.Item[1].cMensaje )

			delete from Diccionario where 1 = 1 
			insert into Diccionario( entidad, atributo, Dominio, tags, alta ) Values( "E1","atributo1", "DETALLEITEM", "<COPIADETALLE>", .T. )

			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnCopiaDeDetalles.ValidarTagEnAtributoDetalle()

			this.AssertEquals( "Debiera haberse ejecutado la validación de detalles.", 0, .oMockInformacionIndividual.Count )

		endwith
	endfunc

	*-----------------------------------										
	Function zTestDetalleConAtributoObligatorio
		
		with This.oValidarADN

			insert into Diccionario( entidad, atributo, Dominio, tags, alta ) Values( "E1","ATRIBUTODETALLE", "DETALLEITEMATRIBUTO1" , "<COPIADETALLE>", .t. )
			
			insert into Diccionario( Entidad, Atributo, Obligatorio ) Values( "ITEMATRIBUTO1","ATRIBUTO1", .f. )
			insert into Diccionario( Entidad, Atributo, Obligatorio ) Values( "ITEMATRIBUTO1","ATRIBUTO2", .f. )
			
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnCopiaDeDetalles.ValidarDetalleConAtributoObligatorio()

			this.AssertEquals( "Debiera haberse ejecutado la validación de detalles.", 1, .oMockInformacionIndividual.Count )
			this.AssertEquals( "Mensaje incorrecto.", "El detalle ITEMATRIBUTO1 no tiene ningun atributo como obligatorio.", alltrim( .oMockInformacionIndividual.Item[1].cMensaje ) )

		endwith
	endfunc

	*-----------------------------------										
	Function zTestUnSoloDetallePorEntidadConTag
		
		with This.oValidarADN

			insert into Diccionario( entidad, tags ) Values( "E1", "<COPIADETALLE>" )
			insert into Diccionario( entidad, tags ) Values( "E1", "<COPIADETALLE>" )
			
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnCopiaDeDetalles.ValidarUnSoloTagPorEntidad()

			this.AssertEquals( "Debiera haberse ejecutado la validación de ValidarUnSoloTagxEntidad.", 1, .oMockInformacionIndividual.Count )
			this.AssertEquals( "Mensaje incorrecto.", "La entidad E1 tiene dos atributos marcados como <COPIADETALLE>. Solo se permite 1 x entidad.", alltrim( .oMockInformacionIndividual.Item[1].cMensaje ) )

		endwith
	endfunc



EndDefine

****************************
define class ValidarADNAux as MockValidarADN

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

enddefine
