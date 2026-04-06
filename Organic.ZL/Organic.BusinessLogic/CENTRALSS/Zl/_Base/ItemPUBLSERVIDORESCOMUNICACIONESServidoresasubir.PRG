define class ItemPublservidorescomunicacionesServidoresasubir as Din_ItemPublservidorescomunicacionesServidoresasubir of Din_ItemPublservidorescomunicacionesServidoresasubir.prg

	*-----------------------------------------------------------------------------------------
	function AsignarModoSubida() as Void
		this.ModoV = icase( this.Modo = 1, "FTP", this.Modo = 2, "Local", this.Modo = 3, "Bucket", "Desconocido" )	
	endfunc 


enddefine