define class HelperPropiedadesExtendidasBD as zooSession of zooSession.prg

	#IF .f.
		Local this as HelperPropiedadesExtendidasBD of HelperPropiedadesExtendidasBD.prg
	#ENDIF

	oConexion = null

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.oConexion = _screen.zoo.app.oPoolConexiones.ObtenerConexion()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValorPropiedadExtendidaDB( tcNombreBD as String, tcNombrePropiedad as String  ) as Void
		local lcRetorno, lcCursor
		
		lcRetorno = null
		lcCursor = sys(2015)

		this.oConexion.ejecutarsql( "USE [" + _screen.zoo.app.ObtenerPrefijoDB() + tcNombreBD + "]" )
		this.oConexion.ejecutarsql( "Select value from sys.extended_properties where [class_desc]='DATABASE' and [name]='"+tcNombrePropiedad +"'", lcCursor, this.datasessionid )
		
		if (_tally==1)
			lcRetorno = &lcCursor..value
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregararPropiedadExtendida( tcNombreBD as String, tcNombrePropiedad as String, tcValor as String ) as Void

		this.oConexion.ejecutarsql( "USE [" + _screen.zoo.app.ObtenerPrefijoDB() + tcNombreBD + "]" )
		this.oConexion.ejecutarsql( "EXEC sp_addextendedproperty @name = [" + tcNombrePropiedad + "], @value = '" + tcValor + "'" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarPropiedadExtendida( tcNombreBD as String, tcNombrePropiedad as String ) as Void

		this.oConexion.ejecutarsql( "USE [" + _screen.zoo.app.ObtenerPrefijoDB() + tcNombreBD + "]" )
		this.oConexion.ejecutarsql( "EXEC sp_dropextendedproperty @name = [" + tcNombrePropiedad + "]" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarPropiedadExtendida( tcNombreBD as String, tcNombrePropiedad as String, tcValor as String ) as Void

		this.oConexion.ejecutarsql( "USE [" + _screen.zoo.app.ObtenerPrefijoDB() + tcNombreBD + "]" )
		this.oConexion.ejecutarsql( "EXEC sp_updateextendedproperty @name = [" + tcNombrePropiedad + "], @value = '" + tcValor + "'" )

	endfunc 

enddefine
