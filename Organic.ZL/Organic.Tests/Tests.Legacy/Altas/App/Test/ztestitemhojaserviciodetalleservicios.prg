Define Class zTestItemhojaServicioDetalleServicios As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestItemhojaServicioDetalleServicios Of zTestItemhojaServicioDetalleServicios.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function setup() as Void
		if vartype( glCorrerTestDeZL ) = "L"
		Else
			return
		endif
		
		local loEntidad as Object
		CrearFuncion_ServiciosFacturablesDesdePresupuestosPendientes()
		loEntidad = _Screen.zoo.InstanciarEntidad( "TIPOARTICULOITEMSERVICIO" )
            try
                  loEntidad.cCod = '99'
            catch
                  loEntidad.Nuevo()
                  loEntidad.Ccod = '99'
                  loEntidad.descrip = "test" 
                  loentidad.Grabar()
            endtry
            loEntidad.Release()


		loEntidad = _Screen.zoo.InstanciarEntidad( "Zlisarticulos" )
		try
			loEntidad.Codigo = '9999'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '9999'
			loEntidad.descrip = "test" 
			loEntidad.tipoArticulo_pk = "99" 
			loentidad.Grabar()
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "moneda" )
		try
			loEntidad.Codigo = 'P'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = 'P'
			loentidad.Grabar()
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "listadeprecios" )
		try
			loEntidad.Codigo = 'LISTAX'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = 'LISTAX'
			loEntidad.moneda_PK = 'P'
			loentidad.Grabar()
		endtry
		loEntidad.Release()


		loEntidad = _Screen.zoo.InstanciarEntidad( "ottarea" )
		try
			loEntidad.Codigo = '9999'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '9999'
			loEntidad.Articulo_pk = '9999'
			loentidad.Grabar()
		endtry
		
		try
			loEntidad.Codigo = '8888'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '8888'
			loEntidad.Articulo_pk= '9999'
			loentidad.Grabar()
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "SERVICIOOT" )
		try
			loEntidad.Codigo = '66'
		catch
			with loEntidad
				.Nuevo()
				.Codigo = '66'
				
				.DetTar.LimpiarItem()
				with .DetTar.Oitem
					.CodTar_pk = '9999'
				endwith
				.DetTar.Actualizar()

				with .DetTar.Oitem
					.CodTar_pk = '8888'
				endwith
				.DetTar.Actualizar()
				.Articulo_pk = '9999'
				.grabar()
			endwith
		endtry
		
		loentidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "Preciodearticulo" )
		try
			loEntidad.Codigo = '666666555555  LISTAX9999'
		catch
			loEntidad.Nuevo()
			loEntidad.Codigo = '9999'
			loEntidad.Articulo_pk = "9999"
			loEntidad.listadeprecio_pk = "LISTAX"
			loEntidad.FechaVigencia = date()
			loEntidad.PrecioDirecto = 3
			loEntidad.TimestampAlta = 666666555555
			loentidad.Grabar()
			
		endtry
		loEntidad.Release()


	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
		if vartype( glCorrerTestDeZL ) = "L"
		Else
			return
		endif	
		local loentidad as Object 

		loEntidad = _Screen.zoo.InstanciarEntidad( "TIPOARTICULOITEMSERVICIO" )
		try
			loEntidad.cCod = '99'
			loEntidad.Eliminar()
		catch
		endtry
		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "ottarea" )
		try
			loEntidad.Codigo = '9999'
			loEntidad.Eliminar()
		catch
		endtry
		
		try
			loEntidad.Codigo = '8888'
			loEntidad.Eliminar()
		catch
		endtry

		loEntidad.Release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "SERVICIOOT" )
		try
			loEntidad.Codigo = '66'
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "Zlisarticulos" )
		try
			loEntidad.Codigo = '9999'
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.release()

		loEntidad = _Screen.zoo.InstanciarEntidad( "moneda" )
		try
			loEntidad.Codigo = 'P'
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.release()
		loEntidad = _Screen.zoo.InstanciarEntidad( "listadeprecios" )
		try
			loEntidad.Codigo = 'LISTAX'
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.release()
		loEntidad = _Screen.zoo.InstanciarEntidad( "Preciodearticulo" )
		try
			loEntidad.Codigo = '666666555555  LISTAX9999'
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.release()


	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestSetearServicioConTarea
		if vartype( glCorrerTestDeZL ) = "L"
		Else
			return
		endif	
		local loItemServicio as object
		
		this.agregarmocks( "Servicioot" )
		_screen.mocks.AgregarSeteoMetodo( 'servicioot', 'Eliminar', .T. )
		loItemServicio = newObject( "ItemHOJADESERVICIODetalleservicios_mOCK" )
	
		this.asserttrue( "No tiene la referencia de la lista de precios", pemstatus( loItemServicio, "oListaDePrecios", 5 ))	
		loItemServicio.Setear_servicio( "66" )
		This.AssertTrue( "No se ejecuto el evento ServicioCargado", loItemServicio.lEventoServicioIngresado )
		loItemServicio.Validar_servicio( "", "66" )
		This.AssertTrue( "No se ejecuto el evento ServicioEliminado", loItemServicio.lEventoServicioEliminado )

		loItemServicio.Release()
		
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtencionPrecioServicio
		if vartype( glCorrerTestDeZL ) = "L"
		Else
			return
		endif	
		local loListaDePrecios as Object, loItem as ItemHOJADESERVICIODetalleservicios of ItemHOJADESERVICIODetalleservicios.prg,;
		loServicio as Object, loArticulo as Object  
		
		loListaDePrecios = _screen.zoo.instanciarentidad( "ListaDePrecios" )

		loItem = _screen.zoo.crearobjeto( "ItemHojaDeServicioDetalleServicios" )
		loItem.inicializar()
		loItem.InyectarListaDePrecios( loListaDePrecios )
		loItem.olISTADEPRECIOS.codigo = "LISTAX"
		
		loItem.Servicio_Pk = "66"
		this.assertequals( "No cargó bien el precio del servicio", 3, loItem.PrecioDeLista )		
		this.assertequals( "No cargó bien el precio del servicio", 3, loItem.PRECIODOMICILIO )		

		loListaDePrecios.release()
		loItem.release()
		
	endfunc 


enddefine


define class ItemHOJADESERVICIODetalleservicios_mOCK as ItemHOJADESERVICIODetalleservicios of ItemHOJADESERVICIODetalleservicios.prg
	lEventoServicioIngresado = .f.
	lEventoServicioEliminado = .f.	

	*-----------------------------------------------------------------------------------------
	function EventoServicioEliminado( txVal as Variant ) as Void
		This.lEventoServicioEliminado = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoServicioIngresado( txVal as Variant ) as Void
		This.lEventoServicioIngresado = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneServiciosFacturablesDesdePresupuestosPendientes( toItem ) as Boolean
		return .F.
	endfunc	

enddefine
****************************************************************************************


*-----------------------------------------------------------------------------------------
Function CrearFuncion_ServiciosFacturablesDesdePresupuestosPendientes
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncServiciosFacturablesDesdePresupuestosPendientesPorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[FuncServiciosFacturablesDesdePresupuestosPendientesPorCliente]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION ZL.FuncServiciosFacturablesDesdePresupuestosPendientesPorCliente
		( 
			@Cliente varchar(5)
		)
		RETURNS TABLE
		AS
		RETURN
		(select '' as Servicio, 1 as pendientes where 1=2)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc