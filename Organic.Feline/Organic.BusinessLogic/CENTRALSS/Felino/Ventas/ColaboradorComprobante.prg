define class ColaboradorComprobante As ZooSession Of ZooSession.prg

	#If .F.
		Local This As ColaboradorComprobante As ColaboradorComprobante.prg
	#Endif
	
	*-----------------------------------------------------------------------------------------
	function ObtenerRemitosAfectados( tcCodigo as String ) as String
		local lcRetorno as String, lcSentencia as String, loRemito as Object

		lcCodigo = tcCodigo
		
		lcSentencia = "Select codigo, afetipocom, afecta  "
		lcSentencia = lcSentencia + "from <<ESQUEMA>>.COMPAFE "
		lcSentencia = lcSentencia + " where codigo = '" + lcCodigo + "' and afetipocomp = 11"

		goServicios.Datos.Ejecutarsentencias( lcSentencia, 'COMPAFE', '', 'cRemitos', this.DataSessionId )

		lcRetorno = this.cursoraxml( "cRemitos" )
		
		return lcRetorno
		
	endfunc 

enddefine
