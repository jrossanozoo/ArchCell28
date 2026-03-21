**********************************************************************
Define Class ZtestValidarAdnConSeguridadComercial as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ZtestValidarAdnConSeguridadComercial of ZtestValidarAdnConSeguridadComercial.prg
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

	*-----------------------------------------------------------------------------------------
	function zTestValidarModulosEnEntidades
		local lcProyectoActivo as String 
		
		with This.oValidarADN
			
			lcProyectoActivo = .cProyectoActivo
		
		
			.cProyectoActivo = 'ZL'
			
			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI1", "E"  , .t., "B" )
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "DETENT1", "I" , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "No debio validar mal "+.cProyectoActivo, 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI2", "E"  , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 1", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI3", "E"  , .f., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 2", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI4", "E"  , .T., "@" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()			
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 3", 2, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			zap in ENTIDAD
			zap in DICCIONARIO			
			

			.cProyectoActivo = 'COLORYTALLE'
			
			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI1", "E"  , .t., "W" )
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "DETENT1", "I" , .t., "" )

			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "1.No debio validar mal "+.cProyectoActivo, 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI2", "E"  , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "2.Debio validar mal "+.cProyectoActivo+" 1", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI3", "E"  , .f., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "3.Debio validar mal "+.cProyectoActivo+" 2", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI4", "E"  , .T., "Y" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()			
			this.assertequals( "4.Debio validar mal "+.cProyectoActivo+" 3", 2, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			zap in ENTIDAD
			zap in DICCIONARIO



			.cProyectoActivo = 'NUCLEO'
			
			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI1", "E"  , .t., "A" )
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "DETENT1", "I" , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "No debio validar mal "+.cProyectoActivo, 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI2", "E"  , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 1", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI3", "E"  , .f., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 2", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI4", "E"  , .T., "@" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()			
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 3", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			zap in ENTIDAD
			zap in DICCIONARIO

	
			.cProyectoActivo = 'GENERADORES'
			
			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI1", "E"  , .t., "A" )
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "DETENT1", "I" , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "No debio validar mal "+.cProyectoActivo, 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI2", "E"  , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 1", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI3", "E"  , .f., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 2", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI4", "E"  , .T., "@" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()			
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 3", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			zap in ENTIDAD
			zap in DICCIONARIO


			.cProyectoActivo = 'FELINO'
			
			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI1", "E"  , .t., "B" )
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "DETENT1", "I" , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "No debio validar mal "+.cProyectoActivo, 0, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI2", "E"  , .t., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 1", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI3", "E"  , .f., "" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 2", 1, .oMockInformacionIndividual.Count )

			.oMockInformacionIndividual.Limpiar()
			insert into Entidad ( Entidad, tipo , Formulario, Modulos ) values ( "ENTI4", "E"  , .T., "@" )
			.oValidarAdnConSeguridadComercial.ValidarModulosEnEntidades()			
			this.assertequals( "Debio validar mal "+.cProyectoActivo+" 3", 2, .oMockInformacionIndividual.Count )

			
			.cProyectoActivo = lcProyectoActivo			
			.oMockInformacionIndividual.Limpiar()
			zap in ENTIDAD
			zap in DICCIONARIO

		endwith
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarModulosEnListadosCasosVarios
		local oldProyectoActivo As String

		insert into Listados ( id, titulo, modulos, idnodo ) Values( "1", "Listado1", "SUIOPTQDGHJKLM", 1 )
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "2", "Listado2", "AÑT", 1 )
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "3", "Listado2", "Ñ", 1 )
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "4", "Listado3", "", 1 )

		oldProyectoActivo = this.oValidarADN.cProyectoActivo

		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()

				.cProyectoActivo = "COLORYTALLE"
				.oValidarAdnConSeguridadComercial.cCursorListados = "Listados"
				.oValidarAdnConSeguridadComercial.ValidarModulosEnListados()

				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarModulosEnListados", 3, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto(1)", "El listado Listado2 (ID -> 2) contiene letra/s de módulos invalida/s (AÑ).", .oMockInformacionIndividual.Item[1].cMensaje )
				this.AssertEquals( "Mensaje incorrecto(2)", "El listado Listado2 (ID -> 3) contiene letra/s de módulos invalida/s (Ñ).", .oMockInformacionIndividual.Item[2].cMensaje )
				this.AssertEquals( "Mensaje incorrecto(3)", "El listado Listado3 (ID -> 4) no posee ningún módulo asignado.", .oMockInformacionIndividual.Item[3].cMensaje )
			endwith		
		catch to loError
			This.asserttrue( "Se produjo un error en la validacion." + loError.message, .f. )
		finally
			use in select( "listados" )
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc
	
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarModulosEnListadosConNodosPadres
		local oldProyectoActivo As String
	
		delete from listados
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "4", "Listado3", "", 0)
		
		oldProyectoActivo = this.oValidarADN.cProyectoActivo
	
		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.cProyectoActivo = "COLORYTALLE"
				.oValidarAdnConSeguridadComercial.cCursorListados = "Listados"
				.oValidarAdnConSeguridadComercial.ValidarModulosEnListados()
				
				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarModulosEnListados", 0, .oMockInformacionIndividual.Count )
			endwith		
		catch to loError
			This.asserttrue( "Se produjo un error en la validacion.", .f. )
		finally
			use in select( "listados" )
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarModulosEnListadosSinModulos
		local oldProyectoActivo As String
	
		delete from listados
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "1", "Listado3", "", 1)
		
		oldProyectoActivo = this.oValidarADN.cProyectoActivo
	
		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.cProyectoActivo = "COLORYTALLE"
				.oValidarAdnConSeguridadComercial.cCursorListados = "Listados"
				.oValidarAdnConSeguridadComercial.ValidarModulosEnListados()
				
				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarModulosEnListados", 1, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto(3)", "El listado Listado3 (ID -> 1) no posee ningún módulo asignado.", .oMockInformacionIndividual.Item[1].cMensaje )
			endwith		
		catch to loError
			This.asserttrue( "Se produjo un error en la validacion.", .f. )
		finally
			use in select( "listados" )
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarModulosEnListadosConModulosInvalidos
		local oldProyectoActivo As String
	
		delete from listados
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "1", "Listado3", "Ñ", 1)
		
		oldProyectoActivo = this.oValidarADN.cProyectoActivo
	
		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.cProyectoActivo = "COLORYTALLE"
				.oValidarAdnConSeguridadComercial.cCursorListados = "Listados"
				.oValidarAdnConSeguridadComercial.ValidarModulosEnListados()
				
				this.AssertEquals( "Debiera haberse ejecutado la validación ValidarModulosEnListados", 1, .oMockInformacionIndividual.Count )
				this.AssertEquals( "Mensaje incorrecto(2)", "El listado Listado3 (ID -> 1) contiene letra/s de módulos invalida/s (Ñ).", .oMockInformacionIndividual.Item[1].cMensaje )
			endwith		
		catch to loError
			This.asserttrue( "Se produjo un error en la validacion.", .f. )
		finally
			use in select( "listados" )
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestU_ValidarModulosEnListadosConModulosCorrectos
		local oldProyectoActivo As String
	
		delete from listados
		insert into Listados ( id, titulo, modulos, idnodo ) Values( "4", "Listado3", "QD", 5)
		
		oldProyectoActivo = this.oValidarADN.cProyectoActivo
	
		try
			with this.oValidarADN
				.oMockInformacionIndividual.Limpiar()
				.cProyectoActivo = "COLORYTALLE"
				.oValidarAdnConSeguridadComercial.cCursorListados = "Listados"
				.oValidarAdnConSeguridadComercial.ValidarModulosEnListados()
				 this.AssertEquals( "no Debiera ejecutarse la validación ValidarModulosEnListados", 0, .oMockInformacionIndividual.Count )
			endwith		
		catch to loError
			This.asserttrue( "Se produjo un error en la validacion.", .f. )
		finally
			use in select( "listados" )
			this.oValidarADN.cProyectoActivo = oldProyectoActivo
		endtry
	endfunc 	
	
EndDefine



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
enddefine
