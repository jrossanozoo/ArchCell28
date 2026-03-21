**********************************************************************
define class zTestDesactivador as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestDesactivador of zTestDesactivador.prg
	#endif
	oLibreriasMock = null
	oEntidad = null

	*---------------------------------
	function setup
	endfunc

	*---------------------------------
	function TearDown
		if vartype( this.oEntidad ) = "O"
			this.oEntidad.release()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_Desactivar
		local lcCodigo as String
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		this.oEntidad.Nuevo()
		this.oEntidad.Codigo = lcCodigo
		this.oEntidad.Grabar()

		*Act (Actuar)
		this.oEntidad.oDesactivador.Desactivar()

		*Assert (Afirmar)
		this.AssertTrue( "Debería estar Inactivo", this.oEntidad.InactivoFW )
		this.oEntidad.Eliminar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DesactivarConReglaDeNegocio
		local lcCodigo as String, loError as Exception
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Bolivia" )
		this.oEntidad.Nuevo()
		this.oEntidad.Codigo = lcCodigo
		this.oEntidad.Grabar()

		*Act (Actuar)
		try
			this.oEntidad.oDesactivador.Desactivar()
			this.asserttrue( "Debería haber dado error", .f. )
		catch to loError
		*Assert (Afirmar)
			this.assertequals( "El error es incorrecto", "Excepción lanzada desde la regla de negocio de desactivación.", loError.UserValue.Message )
		finally 
			this.oEntidad.Modificar()
			this.oEntidad.InactivoFW = .t.
			this.oEntidad.Grabar()
			this.oEntidad.Eliminar()
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_Activar
		local lcCodigo as String
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		with this.oEntidad
			.Nuevo()
			.Codigo = lcCodigo
			.InactivoFW = .t.
			.Grabar()
		endwith
		*Act (Actuar)
		this.oEntidad.oDesactivador.Activar()

		*Assert (Afirmar)
		this.AssertTrue( "Debería estar Inactivo", !this.oEntidad.InactivoFW )
		this.oEntidad.oDesactivador.Desactivar()
		this.oEntidad.Eliminar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ActivarConReglaDeNegocio
		local lcCodigo as String, loError as Exception
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Bolivia" )
		with this.oEntidad
			.Nuevo()
			.Codigo = lcCodigo
			.InactivoFW = .t.
			.Grabar()
		endwith

		*Act (Actuar)
		try
			this.oEntidad.oDesactivador.Activar()
			this.asserttrue( "Debería haber dado error", .f. )
		catch to loError
		*Assert (Afirmar)
			this.assertequals( "El error es incorrecto", "Excepción lanzada desde la regla de negocio de activación.", loError.UserValue.Message )
		finally 
			this.oEntidad.Eliminar()
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ActivarRegistroAunActivo
		local lcCodigo as String
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		with this.oEntidad
			.Nuevo()
			.Codigo = lcCodigo
			.InactivoFW = .f.
			.Grabar()
		endwith
		*Act (Actuar)
		try
			this.oEntidad.oDesactivador.Activar()
			this.asserttrue( "Debería pasar por aca", .t. )
		catch to loError
		*Assert (Afirmar)
			this.asserttrue( "No Debería haber dado error", .f. )
		finally 
			this.oEntidad.oDesactivador.Desactivar()
			this.oEntidad.Eliminar()
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DesactivarRegistroYaDesactivado
		local lcCodigo as String
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		with this.oEntidad
			.Nuevo()
			.Codigo = lcCodigo
			.InactivoFW = .t.
			.Grabar()
		endwith
		*Act (Actuar)
		try
			this.oEntidad.oDesactivador.Desactivar()
			this.asserttrue( "Debería haber dado error", .t. )
		catch to loError
		*Assert (Afirmar)
			this.asserttrue( "No ebería haber dado error", .f. )
		finally 
			this.oEntidad.Eliminar()
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ActivarSinUnRegistroCargado
		local lcCodigo as String
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		*Act (Actuar)
		try
			this.oEntidad.oDesactivador.Activar()
			this.asserttrue( "Debería haber dado error", .f. )
		catch to loError
		*Assert (Afirmar)
			this.assertequals( "El error es incorrecto", "Seleccione un registro.", ;
				loError.uservalue.oinformacion.Item[ 1 ].cMensaje )
		finally 
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_DesactivarSinUnRegistroCargado
		local lcCodigo as String
		
		*Arrange (Preparar)
		lcCodigo = substr( sys( 2015 ), 2 )
		this.oEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		*Act (Actuar)
		try
			this.oEntidad.oDesactivador.Desactivar()
			this.asserttrue( "Debería haber dado error", .f. )
		catch to loError
		*Assert (Afirmar)
			this.assertequals( "El error es incorrecto", "Seleccione un registro.", ;
				loError.uservalue.oinformacion.Item[ 1 ].cMensaje )
		finally 
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ztestU_ExcepcionAlNoEstarActivo
		local loBolivia as din_entidadBolivia of Din_entidadBolivia.prg, loDesactivador as DesactivadorBase of DesactivadorBase.prg
		
		This.agregarmocks( "Bolivia" )
		loBolivia = _screen.zoo.InstanciarEntidad( "Bolivia" )
		loDesactivador = _screen.zoo.CrearObjeto( "DesactivadorBase" )
 		loDesactivador.oEntidad = loBolivia
 		loDesactivador.OSERVICIOERRORES = goServicios.Errores

		with loDesactivador as DesactivadorBase of DesactivadorBase.prg
			loBolivia.InactivoFW = .t.	
			try 
				loDesactivador.EstaActivo( "CODIGO" )
			catch to loError
						this.assertequals( "El error es incorrecto", "El código CODIGO en Bolivia se encuentra inactivo.", ;
				loError.uservalue.oinformacion.Item[ 1 ].cMensaje )
			finally 
			endtry
			
			.Release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestU_NoExcepcionAlEstarActivo
		local loBolivia as din_entidadBolivia of Din_entidadBolivia.prg, loDesactivador as DesactivadorBase of DesactivadorBase.prg
		
		This.agregarmocks( "Bolivia" )
		loBolivia = _screen.zoo.InstanciarEntidad( "Bolivia" )
		loDesactivador = _screen.zoo.CrearObjeto( "DesactivadorBase" )
 		loDesactivador.oEntidad = loBolivia

		with loDesactivador as DesactivadorBase of DesactivadorBase.prg
			loBolivia.InactivoFW = .f.	
			This.asserttrue( "El registro esta activo.", loDesactivador.Estaactivo( "CODIGO" ) )
			.Release()
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarEstadoActivacion 
		pp = _screen.zoo.crearobjeto("desactivadorbase")

		try
			pp.ValidarEstadoActivacion( "1", "1" , .f., .t.)
			this.asserttrue('1.No hace falta validar el estado inactivo', .t.)
		catch to loError
			this.asserttrue('1.Validar el estado inactivo', .f.)
		endtry
		
		try
			pp.ValidarEstadoActivacion( "1", "1" , .t., .f.)
			this.asserttrue('2.Deberia validar el estado inactivo', .f.)
		catch to loError
			this.asserttrue('2.No valida el estado inactivo', .t.)
		endtry
		
		try
			pp.ValidarEstadoActivacion( "1", "2" , .t., .f.)
			this.asserttrue('3.Deberia validar el estado inactivo', .f.)
		catch to loError
			this.asserttrue('3.No valida el estado inactivo', .t.)
		endtry
		
		try
			pp.ValidarEstadoActivacion( "1", "2" , .f., .t.)
			this.asserttrue('4.Deberia validar el estado inactivo', .f.)
		catch to loError
			this.asserttrue('4.No valida el estado inactivo', .t.)
		endtry
		***
		try
			pp.ValidarEstadoActivacion( "1", "2" , .f., .f.)
			this.asserttrue('5.No debe validar el estado', .t.)
		catch to loError
			this.asserttrue('5.Valida el estado, no tiene que hacerlo', .f.)
		endtry
		try
			pp.ValidarEstadoActivacion( "1", "2" , .t., .t.)
			this.asserttrue('6.Debe validar el estado', .f.)
		catch to loError
			this.asserttrue('6.No valida el estado, tiene que hacerlo', .t.)
		endtry
		 
			
		
	*Arrange (Preparar)

	*Act (Actuar)

	*Assert (Afirmar)


	endfunc 
	
	
enddefine
