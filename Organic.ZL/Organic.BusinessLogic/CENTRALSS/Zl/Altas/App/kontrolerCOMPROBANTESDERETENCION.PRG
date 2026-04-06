define class KontrolerCOMPROBANTESDERETENCION as Din_KontrolerCOMPROBANTESDERETENCION of Din_KontrolerCOMPROBANTESDERETENCION.PRG

	cURL = ''
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		local loDetalleComprobantes as Object
		dodefault()
		this.cURL = lower( alltrim(goparametros.zl.RutaDescargaAdjuntosAG) )
		loDetalleComprobantes = this.ObtenerControl( 'DetalleComprobantes' )
		this.BindearLinksDeCamposEnDetalle( loDetalleComprobantes )	
	endfunc

	*-----------------------------------------------------------------------------------------
	function BindearLinksDeCamposEnDetalle( toDetalle as Object ) as Void
		local lnI as Integer, loCampoArchivo as Object, loCampoLinkArchivo  AS Object 
		for lnI = 1  to toDetalle.nCantidadItemsVisibles  
			loCampoArchivo  = toDetalle.ObtenerCampoPorAtributo( lnI , "Archivo" )	
			loCampoLinkArchivo = toDetalle.ObtenerCampoPorAtributo( lnI , "LinkArchivo" )	
			loCampoLinkArchivo.cURL = this.cURL + "?archivo=" 
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarBarra( tcEstado as String ) as Void
		dodefault( tcEstado )
		this.SetearEnabledMenu( "Acciones", "ProcesarRetencion", !this.oEntidad.EsNuevo() and !this.oEntidad.EsEdicion() and !empty( this.Codigo ) and empty( this.FechaProceso ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarRetencion() as Void
		if this.oMensaje.Preguntar( "¿Desea procesar la retención?", 4 ) = 6
			with this
				goServicios.Mensajes.EnviarSinEsperaProcesando( "Procesando..." )
				.SetearEstadoMenuYToolbar( .f. )
				.oEntidad.ProcesarRetencion()
				.ActualizarProgressBar( 100 )
				.ActualizarProgressBar( 0 )
				.SetearEstadoMenuYToolbar( .t. )
				goServicios.Mensajes.EnviarSinEsperaProcesando()
			endwith
		endif
	endfunc

enddefine
