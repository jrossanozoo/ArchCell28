**********************************************************************
Define Class zTestValidarAdnConConfiguracionBasica as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestValidarAdnConConfiguracionBasica of zTestValidarAdnConConfiguracionBasica.prg
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

	*-----------------------------------------------------------------------------------------
	function zTestValidarRutaInicial
		local lcRutaConfigBasica as String
		
		with This.oValidarADN	
			lcRutaConfigBasica = addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) ) + "configuracionbasica\"
			This.AssertEquals( "La ruta de Configuracio basica no es correcta.",.oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica, lcRutaConfigBasica )
		endwith
	endfunc 
	

	*-----------------------------------										
	function zTestValidarAtributosParaComponenteSenia
		local lcMsgErr as String
		lcMsgErr = ""
		
		with This.oValidarADN
			&& Entidad E1
			insert into Entidad ( Entidad ) values ( "E1" )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","IDSENIA", "C", 38, 2 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","FECHAVTOSENIA", "D", 8, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","ARTICULOSSENIADOSDETALLE", "G", 38, 0 )

									
			&& La tabla no existe en Configuracion Basica.
			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnConLaConfiguracionBasica.Validar()
			This.AssertEquals( "Cantidad De Errores Incorrectos (1)", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc


	*-----------------------------------------------------------------------------------------
	function zTestValidarConCamposDiferentesEnADN
		local lcMsgErr as String, lcRutaTmp as String, lcTabla as String, lcRutaConfiguracionBasica as String
		lcMsgErr = ""
		
		with This.oValidarADN
			.oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica = _screen.zoo.obtenerRutaTemporal()
			&& Entidad E1
			insert into Entidad ( Entidad ) values ( "E1" )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","IDSENIA", "G", 38, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","FECHAVTO", "D", 8, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","ARTIALLE", "C", 38, 0 )
			lcRutaTmp = addbs( .oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica ) 
			lcRutaConfiguracionBasica = lcRutaTmp
			set DEFAULT to &lcRutaTmp
			if !directory( "ESPECIFICO" )
				mkdir "ESPECIFICO"
			endif
			lcRutaTmp = lcRutaTmp + "especifico\"
			set DEFAULT to &lcRutaTmp
			
			if !directory( "NUCLEO" )
				mkdir "NUCLEO"
			endif
			lcRutaTmp = lcRutaTmp + "NUCLEO\"
			set DEFAULT to &lcRutaTmp			
			
			lcTabla = lcRutaTmp + "E1.dbf"
			create table &lcTabla free ( IDSENIA C(38), FECHAVTO D, ARTIALLE C(37) ) 
			use in select( "E1" )
			
			.oMockInformacionIndividual.Limpiar()
	 		.oValidarAdnConLaConfiguracionBasica.Validar()
			This.AssertEquals( "Cantidad De Errores Incorrectos (1)", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "La tabla: E1 Campo: ARTIALLE En Diccionario:C(38,0), En Configuracion Básica:C(37,0) del directorio: " + lcRutaConfiguracionBasica + "especifico\NUCLEO"
			This.AssertEquals( "El mensaje de error (1) es incorrecto.", lcMensaje, .oMockInformacionIndividual.Item(1).cMensaje )
		endwith
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestValidarConCamposDiferentesFaltantesEnConfiguracionBasica
		local lcMsgErr as String, lcRutaTmp as String, lcTabla as String, lcRutaConfiguracionBasica as String
		lcMsgErr = ""
		
		with This.oValidarADN
			.oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica = _screen.zoo.obtenerRutaTemporal()
			&& Entidad E1
			insert into Entidad ( Entidad ) values ( "E1" )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","IDSENIA", "G", 38, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","FECHAVTO", "D", 8, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","ARTIALLE", "C", 37, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","CAMPONUEVO", "C", 15, 0 )
			lcRutaTmp = addbs( .oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica ) 
			lcRutaConfiguracionBasica = lcRutaTmp
			set DEFAULT to &lcRutaTmp
			if !directory( "ESPECIFICO" )
				mkdir "ESPECIFICO"
			endif
			lcRutaTmp = lcRutaTmp + "especifico\"
			set DEFAULT to &lcRutaTmp
			
			if !directory( "NUCLEO" )
				mkdir "NUCLEO"
			endif
			lcRutaTmp = lcRutaTmp + "NUCLEO\"
			set DEFAULT to &lcRutaTmp			
			
			lcTabla = lcRutaTmp + "E1.dbf"
			create table &lcTabla free ( IDSENIA C(38), FECHAVTO D, ARTIALLE C(37) ) 
			use in select( "E1" )
			
			.oMockInformacionIndividual.Limpiar()
	 		.oValidarAdnConLaConfiguracionBasica.Validar()
			This.AssertEquals( "Cantidad De Errores Incorrectos (1)", 1, .oMockInformacionIndividual.Count )
			lcMensaje = "La tabla: E1 tiene el campo: CAMPONUEVO C(15,0) y este no existe en la tabla de la configuración básica del directorio: " + lcRutaConfiguracionBasica + "especifico\NUCLEO"
			This.AssertEquals( "El mensaje de error (1) es incorrecto.", lcMensaje, .oMockInformacionIndividual.Item(1).cMensaje )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarConCamposAutoincrementalesEnADN
		local lcMsgErr as String, lcRutaTmp as String, lcTabla as String, lcRutaConfiguracionBasica as String
		lcMsgErr = ""
		
		with This.oValidarADN
			.oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica = _screen.zoo.obtenerRutaTemporal()
			&& Entidad E1
			insert into Entidad ( Entidad ) values ( "E1" )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","IDSENIA", "G", 38, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","FECHAVTO", "A", 8, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","ARTIALLE", "C", 37, 0 )
			lcRutaTmp = addbs( .oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica ) 
			lcRutaConfiguracionBasica = lcRutaTmp
			set DEFAULT to &lcRutaTmp
			if !directory( "ESPECIFICO" )
				mkdir "ESPECIFICO"
			endif
			lcRutaTmp = lcRutaTmp + "especifico\"
			set DEFAULT to &lcRutaTmp
			
			if !directory( "NUCLEO" )
				mkdir "NUCLEO"
			endif
			lcRutaTmp = lcRutaTmp + "NUCLEO\"
			set DEFAULT to &lcRutaTmp			
			
			lcTabla = lcRutaTmp + "E1.dbf"
			create table &lcTabla free ( IDSENIA C(38), ARTIALLE C(37) ) 
			use in select( "E1" )
			
			.oMockInformacionIndividual.Limpiar()
	 		.oValidarAdnConLaConfiguracionBasica.Validar()
			This.AssertEquals( "Cantidad De Errores Incorrectos (1)", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarConCamposMemoEnAdn
		local lcMsgErr as String, lcRutaTmp as String, lcTabla as String, lcRutaConfiguracionBasica as String
		lcMsgErr = ""
		
		with This.oValidarADN
			.oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica = _screen.zoo.obtenerRutaTemporal()
			&& Entidad E1
			insert into Entidad ( Entidad ) values ( "E1" )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","IDSENIA", "G", 38, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","FECHAVTO", "D", 8, 0 )
			insert into Diccionario( Tabla, Campo, tipodato, longitud, decimales ) values ( "E1","ARTIALLE", "M", 0, 0 )
			lcRutaTmp = addbs( .oValidarAdnConLaConfiguracionBasica.cDirectorioDeConfiguracionBasica ) 
			lcRutaConfiguracionBasica = lcRutaTmp
			set DEFAULT to &lcRutaTmp
			if !directory( "ESPECIFICO" )
				mkdir "ESPECIFICO"
			endif
			lcRutaTmp = lcRutaTmp + "especifico\"
			set DEFAULT to &lcRutaTmp
			
			if !directory( "NUCLEO" )
				mkdir "NUCLEO"
			endif
			lcRutaTmp = lcRutaTmp + "NUCLEO\"
			set DEFAULT to &lcRutaTmp			
			
			lcTabla = lcRutaTmp + "E1.dbf"
			create table &lcTabla free ( IDSENIA C(38), FECHAVTO D, ARTIALLE C(1) ) 
			use in select( "E1" )
			
			.oMockInformacionIndividual.Limpiar()
	 		.oValidarAdnConLaConfiguracionBasica.Validar()
			This.AssertEquals( "Cantidad De Errores Incorrectos (1)", 0, .oMockInformacionIndividual.Count )
		endwith
	endfunc 
		
EndDefine


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
