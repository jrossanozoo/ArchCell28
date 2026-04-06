define class KontrolerPublServidoresComunicaciones as DIN_KontrolerPublServidoresComunicaciones of DIN_KontrolerPublServidoresComunicaciones.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar( "oEntidad.EventoConfirmaCrearZooLogicZoo", "ConfirmaCrearZooLogicZoo" )
		this.enlazar( "oEntidad.EventoArchivoCreado", "ArchivoCreado" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearZooLogicZOOManual() as Void
		local loError as Object, loEx as zooException of zooException.prg, llRetorno as Boolean

		llRetorno = .f.
		if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombre(), "CrearZooLogicZOO" )
			This.SetearUltimaAccion( "Crear ZooLogic.zoo" )
			try
				ThisForm.oEntidad.CrearZooLogicZOOManual()
				llRetorno = .t.
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					goMensajes.Enviar( loEx )
				EndWith
			finally
			endtry
		else
			goMensajes.enviar( goServicios.Seguridad.ObtenerInformacion() )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PublicarZooLogicZOO() as Void
		local loError as Object, loEx as zooException of zooException.prg, llRetorno as Boolean
		
		llRetorno = .f.
		if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombre(), "PublicarZooLogicZOO" )
			This.SetearUltimaAccion( "Publicar ZooLogic.zoo" )
			try
				ThisForm.oEntidad.PublicarZooLogicZOO()
				llRetorno = .t.
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					goMensajes.Enviar( loEx )
				EndWith
			finally
			endtry
		else
			goMensajes.enviar( goServicios.Seguridad.ObtenerInformacion() )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function ConfirmaPublicarZooLogicZoo() as Void
		if goMensajes.Preguntar( "¿Confirma la publicación del archivo ZooLogic.zoo?", 4, 1 ) = 6
			with this.oEntidad
				.lConfirmaPublicarZooLogicZoo = .t.
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function ArchivoPublicado() as Void
		if this.oEntidad.HayInformacion()
			goMensajes.Informar( this.oEntidad.ObtenerInformacion() )
		else
			goMensajes.Informar( "El archivo zoologic.zoo se ha publicado correctamente" )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function ConfirmaCrearZooLogicZoo() as Void
		if goMensajes.Preguntar( "¿Confirma la creación del archivo ZooLogic.zoo " + ;
			"para publicación manual en una carpeta específica?", 4, 1 ) = 6
			
			with this.oEntidad
				.lConfirmaCrearZooLogicZoo = .t.
				.cRutaArchivo = goLibrerias.ObtenerDirectorio()
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function ArchivoCreado( tcArchivo as String ) as Void
		goMensajes.Informar( "El archivo " + lower( alltrim( tcArchivo ) ) + ;
			" se ha creado correctamente" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarBarra( tcEstado ) as Void
		dodefault( tcEstado )
		This.SetearEnabledMenu( "Acciones", "CrearZoologicZOO", !empty( this.oEntidad.Codigo ) )
	endfunc 
enddefine
