define class KontrolerConfServidoresComunicaciones as DIN_KontrolerConfservidorescomunicaciones of DIN_KontrolerConfservidorescomunicaciones.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar( "oEntidad.EventoActualizarGrillaPublicaciones", "ActualizarGrillaPublicaciones" )
		this.enlazar( "oEntidad.Cargar", "CargarPublicaciones" )		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarPublicaciones() as Void
		this.oEntidad.CargarPublicaciones()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ActualizarGrillaPublicaciones() as Void
		local loControl as Object, loError as Object

		thisform.lockscreen = .t.
		try
			loControl = this.ObtenerControl( "PUBLICACIONES" )
			loControl.RefrescarGrilla()
		catch to loError
			throw loError 
		finally
			thisform.lockscreen = .f.
		endtry
	endfunc 
enddefine
