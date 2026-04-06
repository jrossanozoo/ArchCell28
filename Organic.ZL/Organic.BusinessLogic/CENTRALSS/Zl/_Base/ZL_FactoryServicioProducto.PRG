define class ZL_FactoryServicioProducto as custom

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseServicio() as String
		return "ZooLogicSA.OrganicServiciosREST.Zl.Servicio.ZlServicio"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseEjecutor() as String
		return "EjecutorZlServicioREST"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreEndpoint() as Void
		return "api.Zl"
	endfunc 

enddefine
