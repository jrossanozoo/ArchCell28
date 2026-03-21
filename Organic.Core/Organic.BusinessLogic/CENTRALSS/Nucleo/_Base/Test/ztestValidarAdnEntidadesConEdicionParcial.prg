**********************************************************************
Define Class zTestValidarADNEntidadesConEdicionParcial as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestValidarADNEntidadesConEdicionParcial of zTestValidarADNEntidadesConEdicionParcial.prg
	#ENDIF

	oValidarADN		= null	
	oManejoArchivos	= null
	cTagEdicParc	= '<EDICIONPARCIAL>'
	cTagBloqReg 	= '<BLOQUEARREGISTRO>'
	loValidarAux    = null
	cDeleted        = ""
	
	*---------------------------------
	Function Setup
		with This
			.cDeleted = set( "deleted" )
			set deleted on
			.oValidarADN = newobject( "MockValidarADN", "zTestValidarADN.prg", "", _screen.zoo.cRutaInicial )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Entidad", .t., .oValidarADN.cRutaADN )
			.oValidarADN.oAccesoDatos.AbrirTabla( "Diccionario", .t., .oValidarADN.cRutaADN )
			select * from Entidad     where .f. into cursor cEntidad     readwrite
			select * from Diccionario where .f. into cursor cDiccionario readwrite		
			.oValidarADN.CerrarTablas()	
			select * from cEntidad     into cursor Entidad     readwrite
			select * from cDiccionario into cursor Diccionario readwrite					
			use in select( "cEntidad" )
			use in select( "cDiccionario" )
			
			.loValidarAux = newobject( "ValidarAdnEntidadesConEdicionParcial_AUX", "zTestValidarAdnEntidadesConEdicionParcial.prg", "", .oValidarAdn )
			insert into entidad (entidad, tipo, formulario, funcionalidades ) values ( 'EDICPARC01', 'E', .t., .cTagEdicParc )
			insert into entidad (entidad, tipo, formulario, funcionalidades ) values ( 'ITEMEDICPARC01', 'I', .t., .cTagEdicParc + .cTagBloqReg )
			insert into entidad (entidad, tipo, formulario, funcionalidades ) values ( 'NOFORMEDICPARC01', 'E', .f., .cTagEdicParc + .cTagBloqReg )
			insert into diccionario (entidad, tags ) values ( 'EDICPARC02', .cTagEdicParc )
			with .oValidarAdn
				.oValidarAdnEntidadesConEdicionParcial = this.loValidarAux
				.oMockInformacionIndividual.Limpiar()
			endwith
		endwith
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	Function TearDown

		local lcDeleted as String
		with This
			.oValidarADN.CerrarTablas( )
			.oValidarADN.release()
			.oValidarADN = null
			.loValidarAux = null
			if dbused( "Metadata" )
				set database to Metadata
				close databases
			endif
			lcDeleted = .cDeleted
			set deleted &lcDeleted
		EndWith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarCorrespondenciaDeTagsEntreDiccionarioYEntidad
		local lcMensError as string
		with this.oValidarAdn
			.oValidarAdnEntidadesConEdicionParcial.CrearCursores_AUX()
			.oValidarAdnEntidadesConEdicionParcial.ValidarCorrespondenciaDeTagsEntreDiccionarioYEntidad_AUX( 'c_dicc_edic', 'c_ent_edic' )
			.oValidarAdnEntidadesConEdicionParcial.CerrarCursores_AUX()
			This.AssertEquals( "Cantidad De Errores Incorrectos (C)", 1, .oMockInformacionIndividual.Count )
			lcMensError = "Si se usó el tag " + this.cTagEdicParc + " para una entidad, se lo debería agregar tanto en entidad.dbf " ;
				+ "como en al menos un atributo de dicha entidad en diccionario.dbf. [ EDICPARC02 ]"
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (C)", lcMensError, .oMockInformacionIndividual.Item[ 1 ].cMensaje )	

			.oMockInformacionIndividual.Limpiar()
			.oValidarAdnEntidadesConEdicionParcial.CrearCursores_AUX()
			.oValidarAdnEntidadesConEdicionParcial.ValidarCorrespondenciaDeTagsEntreDiccionarioYEntidad_AUX( 'c_ent_edic', 'c_dicc_edic' )
			.oValidarAdnEntidadesConEdicionParcial.CerrarCursores_AUX()
			This.AssertEquals( "Cantidad De Errores Incorrectos (C)", 1, .oMockInformacionIndividual.Count )
			lcMensError = "Si se usó el tag " + this.cTagEdicParc + " para una entidad, se lo debería agregar tanto en entidad.dbf " ;
				+ "como en al menos un atributo de dicha entidad en diccionario.dbf. [ EDICPARC01, ITEMEDICPARC01, NOFORMEDICPARC01 ]"
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (C)", lcMensError, .oMockInformacionIndividual.Item[ 1 ].cMensaje )	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarQueEntidadConEdicionParcialSeaDeTipoEntidad
		local lcMensError as string
		with this.oValidarAdn
			.oValidarAdnEntidadesConEdicionParcial.ValidarQueEntidadConEdicionParcialSeaDeTipoEntidad_AUX()
			This.AssertEquals( "Cantidad De Errores Incorrectos (C)", 1, .oMockInformacionIndividual.Count )
			lcMensError = "No deberían existir registros en entidad.dbf con el tag " + this.cTagEdicParc ;
				+ " que no cumplan con la siguiente condición: tipo <> 'E'. Dichas entidades son: ITEMEDICPARC01"
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (C)", lcMensError, .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarQueEntidadConEdicionParcialTengaFormulario
		local lcMensError as string
		with this.oValidarAdn
			.oValidarAdnEntidadesConEdicionParcial.ValidarQueEntidadConEdicionParcialTengaFormulario_AUX()
			This.AssertEquals( "Cantidad De Errores Incorrectos (C)", 1, .oMockInformacionIndividual.Count )
			lcMensError = "No deberían existir registros en entidad.dbf con el tag " + this.cTagEdicParc ;
				+ " que no cumplan con la siguiente condición: !formulario. Dichas entidades son: NOFORMEDICPARC01"
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (C)", lcMensError, .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarQueEntidadConEdicionParcialTengaTagBloquearRegistro
		local lcMensError as string
		with this.oValidarAdn
			.oValidarAdnEntidadesConEdicionParcial.ValidarQueEntidadConEdicionParcialTengaTagBloquearRegistro_AUX()
			This.AssertEquals( "Cantidad De Errores Incorrectos (C)", 1, .oMockInformacionIndividual.Count )		
			lcMensError = "No deberían existir registros en entidad.dbf con el tag " + this.cTagEdicParc ;
				+ " que no cumplan con la siguiente condición: !('<BLOQUEARREGISTRO>' $ funcionalidades). Dichas entidades son: EDICPARC01"
			This.AssertEquals( "El mensaje de error 1 es incorrecto. (C)", lcMensError, .oMockInformacionIndividual.Item[ 1 ].cMensaje )
		endwith
	endfunc
enddefine

define class ValidarAdnEntidadesConEdicionParcial_AUX as ValidarAdnEntidadesConEdicionParcial of ValidarAdnEntidadesConEdicionParcial.prg
    *-----------------------------------------------------------------------------------------
    function ValidarCorrespondenciaDeTagsEntreDiccionarioYEntidad_AUX( tcNombreCursor1 as String, tcNombreCursor2 as String ) as Void
    	this.ValidarCorrespondenciaDeTagsEntreDiccionarioYEntidad( tcNombreCursor1, tcNombreCursor2 )
    endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarQueEntidadConEdicionParcialSeaDeTipoEntidad_AUX() as Void
		this.ValidarQueEntidadConEdicionParcialSeaDeTipoEntidad()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarQueEntidadConEdicionParcialTengaFormulario_AUX() as Void
		this.ValidarQueEntidadConEdicionParcialTengaFormulario()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarQueEntidadConEdicionParcialTengaTagBloquearRegistro_AUX() as Void
		this.ValidarQueEntidadConEdicionParcialTengaTagBloquearRegistro()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearCursores_AUX() as Void
		this.CrearCursores()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CerrarCursores_AUX() as Void
		this.CerrarCursores()
	endfunc 
enddefine