**********************************************************************
Define Class zTestCircuitoLiquidacionDeTalleres as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestCircuitoLiquidacionDeTalleres of zTestCircuitoLiquidacionDeTalleres.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarArticuloEnGrillaProduccionDeCotizacion
		local loCotizacion as entidad OF entidad.prg, loError as Exception, lcMensaje as String

		private goCaja
		goCaja = _Screen.zoo.Instanciarcomponente( "ComponenteCaja" )

		CargarDatos( goCaja.DataSessionId )

		loCotizacion = _Screen.Zoo.InstanciarEntidad( "COTIZACIONPRODUCCION" )
		with loCotizacion
			.Nuevo()
			with .CotizacionOrdenProduccion
				.Limpiar()
				try
					.oItem.Articulo_PK = 'ARTICULO'
					this.AssertTrue( "Debio dar error por cargar un articulo de tipo distinto a concepto", .f. )
				catch to loError
					lcMensaje = loError.UserValue.oInformacion.Item[ 1 ].cMensaje
					this.AssertEquals( "El mensaje de error no es el esperado", "Solo puede ingresar un articulo tipo concepto.", lcMensaje )
				endtry
			endwith
			.Cancelar()
		endwith
		loCotizacion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarArticuloEnGrillaDescartesDeCotizacion
		local loCotizacion as entidad OF entidad.prg, loError as Exception, lcMensaje as String

		private goCaja
		goCaja = _Screen.zoo.Instanciarcomponente( "ComponenteCaja" )

		CargarDatos( goCaja.DataSessionId )

		loCotizacion = _Screen.Zoo.InstanciarEntidad( "COTIZACIONPRODUCCION" )
		with loCotizacion
			.Nuevo()
			with .CotizacionOrdenDescarte
				.Limpiar()
				try
					.oItem.Articulo_PK = 'ARTICULO'
					this.AssertTrue( "Debio dar error por cargar un articulo de tipo distinto a concepto", .f. )
				catch to loError
					lcMensaje = loError.UserValue.oInformacion.Item[ 1 ].cMensaje
					this.AssertEquals( "El mensaje de error no es el esperado", "Solo puede ingresar un articulo tipo concepto.", lcMensaje )
				endtry
			endwith
			.Cancelar()
		endwith
		loCotizacion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarArticuloEnGrillaInsumoaDeCotizacion
		local loCotizacion as entidad OF entidad.prg, loError as Exception, lcMensaje as String

		private goCaja
		goCaja = _Screen.zoo.Instanciarcomponente( "ComponenteCaja" )

		CargarDatos( goCaja.DataSessionId )

		loCotizacion = _Screen.Zoo.InstanciarEntidad( "COTIZACIONPRODUCCION" )
		with loCotizacion
			.Nuevo()
			with .CotizacionOrdenInsumos
				.Limpiar()
				try
					.oItem.Articulo_PK = 'ARTICULO'
					this.AssertTrue( "Debio dar error por cargar un articulo de tipo distinto a concepto", .f. )
				catch to loError
					lcMensaje = loError.UserValue.oInformacion.Item[ 1 ].cMensaje
					this.AssertEquals( "El mensaje de error no es el esperado", "Solo puede ingresar un articulo tipo concepto.", lcMensaje )
				endtry
			endwith
			.Cancelar()
		endwith
		loCotizacion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarArticuloEnGrillaAdicionalDeCotizacion
		local loCotizacion as entidad OF entidad.prg, loError as Exception, lcMensaje as String

		private goCaja
		goCaja = _Screen.zoo.Instanciarcomponente( "ComponenteCaja" )

		CargarDatos( goCaja.DataSessionId )

		loCotizacion = _Screen.Zoo.InstanciarEntidad( "COTIZACIONPRODUCCION" )
		with loCotizacion
			.Nuevo()
			with .CotizacionOrdenAdicionales
				.Limpiar()
				try
					.oItem.Articulo_PK = 'ARTICULO'
					this.AssertTrue( "Debio dar error por cargar un articulo de tipo distinto a concepto", .f. )
				catch to loError
					lcMensaje = loError.UserValue.oInformacion.Item[ 1 ].cMensaje
					this.AssertEquals( "El mensaje de error no es el esperado", "Solo puede ingresar un articulo tipo concepto.", lcMensaje )
				endtry
			endwith
			.Cancelar()
		endwith
		loCotizacion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_RecalcularMontos 
		local loCotizacion as entidad OF entidad.prg, loError as Exception, lcMensaje as String

		private goCaja
		goCaja = _Screen.zoo.Instanciarcomponente( "ComponenteCaja" )

		CargarDatos( goCaja.DataSessionId )

		loCotizacion = _Screen.Zoo.InstanciarEntidad( "COTIZACIONPRODUCCION" )
		with loCotizacion
			.Nuevo()
			.CotizacionOrdenAdicionales.Limpiar()
			with .CotizacionOrdenAdicionales
				try
					.oItem.Articulo_PK = 'CONCEPTO'
					
					.oItem.Cantidad = 10
					this.AssertEquals( "La suma de cantidades no es la esperada", 10, .Sum_Cantidad)
					.oItem.Costo = 100
					this.AssertEquals( "La suma de cantidades no es la esperada", 1000, .Sum_Monto)
				catch to loError
					lcMensaje = loError.UserValue.oInformacion.Item[ 1 ].cMensaje
					this.AssertTrue( "No debio dar el error : " + lcMensaje, .f. )
				endtry
			endwith
			.Cancelar()
		endwith
		loCotizacion.Release()
	endfunc 

EndDefine

*-----------------------------------------------------------------------------------------
function CargarDatos( tnSesionDB as Integer ) as Void
	local lcSentencia as String
	lcSentencia = "delete from zoologic.art where artcod = 'ARTICULO'"
	goServicios.Datos.EjecutarSentencias( lcSentencia, "art", "", "", tnSesionDB )
	lcSentencia = "delete from zoologic.art where artcod = 'CONCEPTO'"
	goServicios.Datos.EjecutarSentencias( lcSentencia, "art", "", "", tnSesionDB )
	lcSentencia = "insert into zoologic.art (artcod, astock) VALUES ('ARTICULO', 0)"
	goServicios.Datos.EjecutarSentencias( lcSentencia, "art", "", "", tnSesionDB )
	lcSentencia = "insert into zoologic.art (artcod, astock) VALUES ('CONCEPTO', 2)"
	goServicios.Datos.EjecutarSentencias( lcSentencia, "art", "", "", tnSesionDB )
endfunc 
