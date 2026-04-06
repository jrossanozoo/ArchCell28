define class KontrolerZLSERIES as Din_KontrolerZLSERIES of Din_KontrolerZLSERIES.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar()
		dodefault()
		bindevent( this.oEntidad, "EventoInformarSerieYClave", this, "InformarSerieYClave", 1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function InformarSerieYClave() as Void
		goServicios.Mensajes.Enviar( "Nº de Serie " + alltrim( this.NroSerie ) + chr( 13 ) + chr( 10 ) + "Clave " + alltrim( this.Clave ), 0, 3 )
	endfunc

enddefine
