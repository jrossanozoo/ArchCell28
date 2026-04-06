Define Class zTestDetalleHojaDeServicioDetalleServicios As FxuTestCase Of FxuTestCase.prg
	
	#If .F.
		Local This As zTestDetalleHojaDeServicioDetalleServicios Of zTestDetalleHojaDeServicioDetalleServicios.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function zTestEventos
		local loDetalleServicio as object, lcExact as String 

		lcExact = set ("Exact")
		set exact on

		loDetalleServicio = newObject( "DetalleHojaDeServicioDetalleServicios_mock" )
	
		with loDetalleServicio
			.Inicializar()
			.LimpiarItem()

			.oItem.EventoServicioIngresado( "COD1" )
			This.AssertTrue( "No se ejecuto el evento ServicioCargado Ingresado", .lEventoServicioIngresado )
		
			.oItem.EventoServicioEliminado( "COD1" )
			This.AssertTrue( "No se ejecuto el evento ServicioCargado Eliminado", .lEventoServicioEliminado )
		endwith
		
		set exact &lcExact
		
	endfunc 

enddefine

define class DetalleHojaDeServicioDetalleServicios_mock as detallehojadeserviciodetalleservicios of detallehojadeserviciodetalleservicios.prg
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

enddefine