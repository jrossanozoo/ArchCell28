**********************************************************************
define class ztestNocturnosNumeraciones as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as ztestNocturnosNumeraciones of ztestNocturnosNumeraciones.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function zTestVerificarNumeracionesPorSucursal
		local loEntidad as object, loNumeraciones as object, lnNumero as int, lnUltimoNro as integer, ;
			loError as exception

		_Screen.zoo.app.cSucursalActiva = "PAISES"

		goServicios.Datos.EjecutarSentencias( 'delete from numeraciones', 'numeraciones' )
		goServicios.Datos.EjecutarSentencias( 'delete from mexico', 'mexico' )

		_Screen.zoo.app.cSucursalActiva = "COUNTRYS"

		goServicios.Datos.EjecutarSentencias( 'delete from numeraciones', 'numeraciones' )
		goServicios.Datos.EjecutarSentencias( 'delete from mexico', 'mexico' )
		
		_Screen.zoo.app.cSucursalActiva = "PAISES"
		loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
		with loentidad
			try
				.nuevo()
				.Codigo = "11"
				.entidad = "MEXICO"
				.Numero = 0
				.Grabar()
			catch to loError
				throw loError
			finally
				.release()
			endtry
		endwith

		_Screen.zoo.app.cSucursalActiva = "COUNTRYS"
		loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
		with loentidad
			try
				.nuevo()
				.Codigo = "11"
				.entidad = "MEXICO"
				.Numero = 0
				.Grabar()
			catch to loError
				throw loError
			finally
				.release()
			endtry
		endwith

		*** Seteo una sucursal
		_Screen.zoo.app.cSucursalActiva = "PAISES"
		loEntidad = _screen.zoo.instanciarentidad( "Mexico" )
		with loentidad
			.Nuevo()
			try
				.Codigo = 1
				.Nombre = "1"
				.Presidente = "1"
				.Grabar()
				this.Assertequals( "Error en la numeracion (1)", 1, .Habitantes )
			catch to loError
				throw loError
			finally
				.release()
			endtry
		endwith

		*** Cambio la sucursal por otra distinta
		_Screen.zoo.app.cSucursalActiva = "COUNTRYS"
		loEntidad = _screen.zoo.instanciarentidad( "Mexico" )
		with loentidad
			.Nuevo()
			try
				.Codigo = 2
				.Nombre = "1"
				.Presidente = "1"
				.Grabar()
				this.Assertequals( "Error en la numeracion (2)", 1, .Habitantes )
			catch to loError
				throw loError
			finally
				.release()
			endtry
		endwith

		*** Vuelvo a la sucursal anterior
		_Screen.zoo.app.cSucursalActiva = "PAISES"
		loEntidad = _screen.zoo.instanciarentidad( "Mexico" )
		with loentidad
			.Nuevo()

			try
				.Codigo = 3
				.Nombre = "2"
				.Presidente = "1"
				.Grabar()
				this.Assertequals( "Error en la numeracion (3)", 2, .Habitantes )
			catch to loError
				throw loError
			finally
				.release()
			endtry
		endwith

		_Screen.zoo.app.cSucursalActiva = "COUNTRYS"

		goServicios.Datos.EjecutarSentencias( "Select * From Numeraciones", "Numeraciones", "", "Numeraciones_Countrys", set("Datasession")  )
		this.assertequals( "Error en la numeracion de la sucursal COUNTRYS", 1, Numero )
		use in select("Numeraciones_Countrys")

		_Screen.zoo.app.cSucursalActiva = "PAISES"
		goServicios.Datos.EjecutarSentencias( "Select * From Numeraciones", "Numeraciones", "", "Numeraciones_Paises", set("Datasession")  )
		this.assertequals( "Error en la numeracion de la sucursal PAISES", 2, Numero )
		use in select("Numeraciones_Paises")
	endfunc
enddefine

