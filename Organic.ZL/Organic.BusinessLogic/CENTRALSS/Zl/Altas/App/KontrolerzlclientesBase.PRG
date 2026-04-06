define class KontrolerZlClientesBase as KontrolerConDetalle of KontrolerConDetalle.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar()
		dodefault()
		bindevent( this.oEntidad, "EventoInformarNombreRepetido", this, "InformarNombreRepetido", 1 )
		bindevent( this.oEntidad, "LimpiarDetalleFranquicias", this, "RefrescarDetalleFranquicias", 1 )
		bindevent( this.oEntidad, "EventoRefrescarDetalles", this, "RefrescarDetalles", 1 )
		This.ReacomodarDetallesYRedimensionarFormulario()
	endfunc

	*-----------------------------------------------------------------------------------------
	function InformarNombreRepetido() as Void
		goServicios.Mensajes.Enviar( "El nombre del Cliente ingresado ya existe.",0, 2 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalleFranquicias() as Void
		local loControl as Object
		loControl = this.obtenerControl( "DetalleFranquicias" )
		loControl.RefrescarGrilla()
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalles() as Void
		local loControl as Object
		loControl = this.obtenerControl( "DetalleTenant" )
		loControl.RefrescarGrilla()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ReacomodarDetallesYRedimensionarFormulario() as Void
		local loControlContactos as Object, loErr as zooexception OF zooexception.prg 
		
		try
			loControlContactos = This.Obtenercontrol( "DetalleContactos" )
			with loControlContactos.Parent
				.Top = .Top + 4 
			endwith 
			
			loControlContactos = This.Obtenercontrol( "DetalleTenant" )
			with loControlContactos.Parent
				.Top = .Top + 4 
			endwith 	
			
			loControlContactos = This.Obtenercontrol( "MensajeMDA" )
			with loControlContactos.Parent
				.Top = .Top + 2 
			endwith 			
		catch to loErr
		endtry 
	
	endfunc 

enddefine
