define class AccesoDatosSeguridad as ZooSession of ZooSession.prg

	#if .f.
		local this as AccesoDatosSeguridad of AccesoDatosSeguridad.prg
	#endif

	datasession = 1

	cSchemaSeguridad = ""
	cSchemaFunciones = ""
	cAlltrim = ""
	cVal = ""

	*-----------------------------------------------------------------------------------------
	function Iniciar() as Void
		this.CargarFuncionesDatos()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsSqlServer() as Boolean
		return ( _screen.zoo.app.TipoDeBase == "SQLSERVER" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarFuncionesDatos() as Void
		with this
			.cSchemaSeguridad = goDatos.ObtenerSchemaSeguridad()
			.cSchemaFunciones = goDatos.ObtenerSchemaFunciones()
			.cAlltrim = goDatos.ObtenerFuncion( "Alltrim" )
			.cVal = goDatos.ObtenerFuncion( "Val" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPerfiles( tcCursor as String ) as Void
		local lcSql as String, lcXML as String
		
		lcSql = "Select " + this.ObtenerCamposPerfiles() + " From " + this.cSchemaSeguridad + "Perfiles Order By Nombre"
		lcXML = this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "Perfiles.DBF" )

		this.Xmlacursor( lcXML, tcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerUsuarios( tcCursor as String ) as Void
		local lcSql as String, lcXML as String

		lcSql = "Select " + this.ObtenerCamposUsuarios() + " From " + this.cSchemaSeguridad + "Usuarios Order By Usuario"
		lcXML = this.EjecutarSentencia( lcSQL , _screen.Zoo.App.cRutaTablasSeguridad + "Usuarios.DBF" )
		
		this.Xmlacursor( lcXML, tcCursor )			
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDeOperacionesPerfiles( tcIdPral as String, tcIdOpe as String ) as Void
		local lcXML as String, lcSql as String

		text to lcSql textmerge noshow pretext 1+2+4+8
			select idOpe, << this.cSchemaFunciones >>.DesencriptarModo( idPer, idOpe, Modo ) as Modo, 
					idPer as IdClave 
			from << this.cSchemaSeguridad >>PerfilesOperaciones 
			where << this.cAlltrim >>( idPer )= '<< tcIdPral >>' and << this.cAlltrim >>( idOpe ) = '<< tcIdOpe >>'
		endtext
		
		lcXML = this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "PerfilesOperaciones" )
		
		this.Xmlacursor( lcXML, "Temp_operacion" )

		select Temp_operacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDeOperacionesUsuarios( tcIdPral as String, tcIdOpe as String ) as Void
		local lcXML as String, lcSql as String

		text to lcSql textmerge noshow pretext 1+2+4+8
			select idOpe, << this.cSchemaFunciones >>.DesencriptarModo( idUsu, idOpe, Modo ) as Modo, 
					idUsu as IdClave 
			from << this.cSchemaSeguridad >>UsuariosOperaciones 
			where << this.cAlltrim >>( idUsu )= '<< tcIdPral >>' and << this.cAlltrim >>( idOpe )= '<< tcIdOpe >>'
		endtext
		
		lcXML = this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "UsuariosOperaciones" )
		
		this.Xmlacursor( lcXML, "Temp_operacion" )

		select Temp_operacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRelacionUsuarios( tcId as String, tcCursor as string ) as Void
		local lcXML as String, lcSql as String

		lcSql = "select " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( " + this.cAlltrim + "( pu.IdPer ), " + ;
					this.cAlltrim + "( pu.idUsu ), 0 ) as idPer, " + this.ObtenerCamposUsuarios( .t. ) + ;
			" from " + this.cSchemaSeguridad + "Perfiles a left join " + this.cSchemaSeguridad + "Perfilesusuarios pu on " + this.cSchemaFunciones +;
			".DesencriptarPerfilUsuario( " + this.cAlltrim + "( pu.IdPer ), " + this.cAlltrim + "( pu.idUsu ), 0 )" + ;
			" = a.Id and " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( " + this.cAlltrim + "( pu.IdPer ), " + this.cAlltrim + "( pu.idUsu ), 1 ) = '" + tcId + "'"
			
		lcXML = this.EjecutarSentencia( lcSQl, _screen.Zoo.App.cRutaTablasSeguridad + "PerfilesUsuarios," + _screen.Zoo.App.cRutaTablasSeguridad + "Perfiles" )

		this.Xmlacursor( lcXML, tcCursor  )			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRelacionPerfiles( tcId as String, tcCursor as string ) as Void
		local lcXML as String, lcSql as String

		lcSql = "select " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( " + this.cAlltrim + "( pu.IdPer ), " + ;
					this.cAlltrim + "( pu.idUsu ), 0 ) as idPer," + this.ObtenerCamposPerfiles( .t. ) + ;
				" from " + this.cSchemaSeguridad + "Usuarios a left join " + this.cSchemaSeguridad + "Perfilesusuarios pu on " + ;
					this.cSchemaFunciones + ".DesencriptarPerfilUsuario( " + this.cAlltrim + "( pu.IdPer ), " + this.cAlltrim + "( pu.idUsu ), 1 )" +  ;
					" = a.Id and " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( " + this.cAlltrim + "( pu.IdPer ), " + ;
					this.cAlltrim + "( pu.idUsu ), 0 ) = '" + tcId + "'"
		
		lcXML = this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "PerfilesUsuarios," + _screen.Zoo.App.cRutaTablasSeguridad + "Usuarios" )

		this.Xmlacursor( lcXML, tcCursor )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function EliminarPerfiles( tcId as String ) as Void
		local lcSql as String

		lcSql = "Delete from " + this.cSchemaSeguridad + "perfiles where upper( Id ) = '" + tcId + "'"
		this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "Perfiles.DBF", .t. )
		
		lcSql = "Delete from " + this.cSchemaSeguridad + "PerfilesOperaciones where idPer = '" + tcId + "'"
		this.EjecutarSentencia( lcSQL , _screen.Zoo.App.cRutaTablasSeguridad + "Perfilesoperaciones.DBF", .t. )
		
		lcSql = "Delete from " + this.cSchemaSeguridad + "PerfilesUsuarios where " + this.cSchemaFunciones + ".ExtraerPerfilUsuario( " + this.cAlltrim + "( idPer ), 0 ) = '" + tcId + "'"
		this.EjecutarSentencia( lcSQL , _screen.Zoo.App.cRutaTablasSeguridad + "PerfilesUsuarios.DBF", .t. )
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function EliminarUsuarios( tcId as String ) as Void
		local lcSql as String

		lcSql = "Delete from " + this.cSchemaSeguridad + "usuarios where Id = '" + tcId + "'"
		this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "Usuarios", .t. )	
		
		lcSql = "Delete from " + this.cSchemaSeguridad + "UsuariosOperaciones where idUsu = '" + tcId + "'"
		this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "UsuariosOperaciones", .t. )		
		
		lcSql = "Delete from " + this.cSchemaSeguridad + "PerfilesUsuarios where " + this.cSchemaFunciones + ".ExtraerPerfilUsuario( " + this.cAlltrim + "( idPer ), 1 ) = '" + tcId + "'"
		this.EjecutarSentencia( lcSql, _screen.Zoo.App.cRutaTablasSeguridad + "PerfilesUsuarios", .t. )		
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function EjecutarSentencia( tcSql as String, tcTablas as String, tlActualizar as Boolean ) as String
		local lcXml as String

		lcXml = ""
		
		if this.EsSqlServer()
			lcXml = goDatos.EjecutarSql( tcSql )
		else
			if tlActualizar 
				goDatos.Actualizar( tcSql, tcTablas )
			else
				lcXml = goDatos.Consultar( tcSql, tcTablas )							
			endif
		endif
		
		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposPerfiles( tlInvertir as Boolean ) as Void
		local lcRetorno as String

		if 	tlInvertir
			lcRetorno = golibrerias.ObtenerCamposSeguridadUsuarios( "*clavedesencriptada" )
		else
			lcRetorno = golibrerias.ObtenerCamposSeguridadPerfiles( "*" )						
		endif
		
		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposUsuarios( tlInvertir as Boolean ) as Void
		local lcRetorno as String

		if 	tlInvertir
			lcRetorno = golibrerias.ObtenerCamposSeguridadPerfiles( "*" )						
		else
			lcRetorno = golibrerias.ObtenerCamposSeguridadUsuarios( "*clavedesencriptada" )
		endif
		
		return lcRetorno
	endfunc 	

enddefine
