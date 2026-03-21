**********************************************************************
Define Class ztestEntidadesProduccion As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestEntidadesProduccion Of ztestEntidadesProduccion.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function zTestU_HabilitarCaracteristiasEnMaquinariaSegunTipo
		local loFormulario as Object, loEntidad as entidad OF entidad.prg, loError as Object
*Arrange (Preparar)
		loFormulario = goFormularios.Procesar( "Maquinaria" )
		loEntidad = loFormulario.oEntidad
*Act (Actuar)
		loFormulario.oKontroler.Inicializar()
		With loEntidad
			try
				.Nuevo()
				this.AssertTrue( "Debe estar habilitado Marca (1)", .lHabilitarMarca)
				this.AssertTrue( "Debe estar habilitado Modelo (1)", .lHabilitarModelo)
				this.AssertTrue( "Debe estar habilitado Serie (1)", .lHabilitarSerie)
				.Marca = 'Golden Laser'
				.Modelo = 'JG-10060'
				.Serie = '09022020-19'
				.TipoMaquinaria = 2
				this.AssertTrue( "No debe estar habilitado Marca (2)",!loEntidad.lHabilitarMarca)
				this.AssertTrue( "No debe estar habilitado Modelo (2)",!loEntidad.lHabilitarModelo)
				this.AssertTrue( "No debe estar habilitado Serie (2)",!loEntidad.lHabilitarSerie)
				this.AssertEquals( "Debe blanquearse la marca al cambiar el tipo (3)", "", .Marca)
				this.AssertEquals( "Debe blanquearse el modelo al cambiar el tipo (3)", "", .Modelo)
				this.AssertEquals( "Debe blanquearse el número de serie al cambiar el tipo (3)", "", .Serie)
				.TipoMaquinaria = 1
				this.AssertTrue( "Debe estar habilitado Marca (4)", .lHabilitarMarca)
				this.AssertTrue( "Debe estar habilitado Modelo (4)", .lHabilitarModelo)
				this.AssertTrue( "Debe estar habilitado Serie (4)", .lHabilitarSerie)
			catch to loError
			finally
				.Cancelar()
			endtry
*Assert (Afirmar)
		endwith
		loFormulario.Release()
		loEntidad = null
	endfunc 

Enddefine
