define class ent_Numeraciones as din_EntidadNumeraciones of din_EntidadNumeraciones.prg

	oTalonario = null
	Talonarios = null
	TalonariosAux = null
	lLanzarExcepcion = .t.
	
	*-----------------------------------------------------------------------------------------
	Function oTalonario_Access()
		if !this.ldestroy and !vartype( this.oTalonario ) = 'O'
			this.oTalonario = _screen.zoo.InstanciarEntidad( 'Talonario' )
		endif
		Return this.oTalonario
	endfunc
		
	*-------------------------------------------------------------------------------------------------
	Function ValidacionBasica() As boolean
		return .T.
	Endfunc

	*-------------------------------------------------------------------------------------------------
	Function ValidarExistencia() As boolean
		Return .t.
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		if this.lLanzarExcepcion
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Nuevo." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		if this.lLanzarExcepcion	
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Eliminar." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Primero() as Void
		if this.lLanzarExcepcion
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Primero." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Ultimo() as Void
		if this.lLanzarExcepcion
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Ultimo." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Siguiente() as Void
		if this.lLanzarExcepcion
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Siguiente." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Anterior() as Void
		if this.lLanzarExcepcion
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Anterior." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Buscar() as Void
		if this.lLanzarExcepcion
			goServicios.Errores.LevantarExcepcion( "No se puede hacer Buscar." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		with this
			create cursor c_InicializacionTalonarios ( Codigo N(1) )
			.Cargar()
			.Talonarios.nCantidadItems = .Talonarios.Count
			.CargarTalonarioAux()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarTalonarioAux() as Void
		local i as Integer, lnNumeroAux  as integer 
		this.TalonariosAux = _screen.zoo.crearobjeto( 'zoocoleccion' )
		for i = 1 to this.Talonarios.Count
			lnNumeroAux  = this.Talonarios.Item[ i ].Numero
			this.TalonariosAux.agregar( lnNumeroAux )
		endfor 
	endfunc 

	*-------------------------------------------------------------------------------------------
	Function Modificar () As void
		with this
			.lEdicion = .T.
			.lNuevo = .F.
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Grabar() as Void
		local i as Integer, lcTalonario as string, loError as Exception, lnNumero as integer, lnNumeroAux as integer, ;
			lcEntidad as string

		with this
			for i = 1 to .Talonarios.Count
			
				lcTalonario = .Talonarios.Item[ i ].Talonario 
				lnNumero = .Talonarios.Item[ i ].Numero
				lnNumeroAux  = .TalonariosAux.Item[ i ]
				lcEntidad = alltrim( .Talonarios.Item[ i ].Entidad )
				if empty( lcEntidad )
				else
					lcEntidad = " (" + lcEntidad + ")"
				endif
				
				if empty( lcTalonario ) 
				else
					if lnNumero <> lnNumeroAux  
						Try
							.oTalonario.Codigo = lcTalonario 
							if .oTalonario.Numero != lnNumero
								.oTalonario.Modificar()
								.oTalonario.Numero = lnNumero
								.oTalonario.Grabar()
							endif
						Catch To loError
							.AgregarInformacion( .DesgloceError( loError ) )
							.AgregarInformacion( "Error al intentar grabar el talonario " + alltrim(lcTalonario) + " " + lcEntidad )
							goServicios.Errores.levantarExcepcion( .ObtenerInformacion() )
						finally
							if .oTalonario.EsEdicion()
								.oTalonario.Cancelar()
							endif
						EndTry
					endif
				endif
			endfor
			
			.Modificar()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DesgloceError( toError as zooexception OF zooexception.prg ) as String
		local lcMensajeError as String, loErrorAux as Object, lcAux as String, i as Integer

		loErrorAux = toError
		lcMensaje = ""
		lcAux = ""
		
		do while vartype( loErrorAux.UserValue ) == 'O'
			loErrorAux = loErrorAux.UserValue
		enddo

		if pemstatus( loErrorAux, 'oInformacion', 5 )
			if loErrorAux.oInformacion.Count > 0
				for i=1 to loErrorAux.oInformacion.Count
					lcMensaje = alltrim(lcMensaje) + loErrorAux.oInformacion.item[i].cMensaje + chr(13)
				endfor
			else
				lcMensaje = loErrorAux.LineContents
			endif
		else
			lcMensaje = loErrorAux.LineContents
		endif
		
		return lcMensaje
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local lcXml as String

		with this
			lcXml = .oTalonario.oAd.ObtenerDatosEntidad()
			.XmlACursor( lcXml, "c_Talonarios" )
			
			select space(150) as DescripEnt, Codigo as Talonario, * ;
				from c_Talonarios ;
				where !DelegarNumeracion ;
				into cursor c_Talonarios readwrite
			
			.ActualizarDescripcionesCursor()			
			.Talonarios.Limpiar()			 
			.Talonarios.Cargar()
			.ActualizarDescripcionesGrilla()
			use in select( "c_Talonarios" )
		endwith
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		dodefault()
		use in select( "c_InicializacionTalonarios" )
		this.oTalonario = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDescripcionesCursor() as Void
		local lcCursorDescrip as String
		
		lcCursorDescrip = this.ObtenerCursorConDescripciones()
		select c_Talonarios
		do while !eof()
			select &lcCursorDescrip
			seek alltrim( upper( c_Talonarios.Entidad ) )
			if found()
				select c_Talonarios
				replace DescripEnt with &lcCursorDescrip..Descripcion
			endif
			
			select c_Talonarios
			skip
		enddo
		index on alltrim( DescripEnt ) tag c_Talo1
		use in ( lcCursorDescrip )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarDescripcionesGrilla() as Void
		local loItemTalonario as Object
		
		for each loItemTalonario in this.Talonarios
			select c_Talonarios
			locate for Entidad = loItemTalonario.Entidad
			if found()
				loItemTalonario.DescripcionEntidad = c_Talonarios.DescripEnt
			endif
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCursorConDescripciones() as String
		local lcCursor as String, lcXMLEntidades as String
		
		lcCursor = sys( 2015 )
		lcXMLEntidades = goServicios.Estructura.ObtenerFuncionalidades()
		this.XmlACursor( lcXMLEntidades, lcCursor + "_Tags" )
		
		select Entidad, Descripcion ;
			from &lcCursor._Tags ;
			group by Entidad, Descripcion ;
			into cursor &lcCursor
		index on alltrim( upper( Entidad ) ) tag idxdesc1
		
		use in ( lcCursor + "_Tags" )
		return lcCursor
	endfunc

enddefine