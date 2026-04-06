define class kontrolerFACTIBILIDAD as Din_kontrolerFACTIBILIDAD of Din_kontrolerFACTIBILIDAD.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.DuracionCambiarTabIndex()
		loControl = this.ObtenerControl( "DURACION" )
 		bindevent( loControl, "GotFocus", this, "EjecutarCalcularDuracion" )
 	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarCalcularDuracion() as Void
		this.oEntidad.CalcularDuracion()
	endfunc

	*-----------------------------------------------------------------------------------------
	function DuracionCambiarTabIndex() as Void
		local loControl as Object
		loControl = this.ObtenerControl( "DURACION" )
		loControl.TabStop = .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarBarra( tcEstado ) as Void
		dodefault( tcEstado )
		this.SetearEnabledMenu( "Acciones", "CargaAutomaticaHoras", !this.oEntidad.EsNuevo() and !this.oEntidad.EsEdicion() and !empty( this.Codigo ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargaAutomaticaHoras() as Void
		goServicios.Mensajes.EnviarSinEsperaProcesando( "Realizando la carga automática de horas..." )
		this.oEntidad.oColaboradorHoras.EjecutarCargaAutomaticaHoras( 6, this.Codigo )
		goServicios.Mensajes.EnviarSinEsperaProcesando()
	endfunc

enddefine
