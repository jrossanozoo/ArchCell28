define class ObjetoLogueo as zooSession of zooSession.prg

	#if .f.
		local this as ObjetoLogueo of ObjetoLogueo.prg
	#endif

	oInfoLog = null

	protected oUltimoLog, oBufferLogueo, nCantidadLineasBuffer
	oBufferLogueo = null
	oUltimoLog = null
	
	cIdLogueo = ""
	cLogger = ""
	Accion = ""
	NivelParaLogueoPorDefecto = 0

	nCantidadLineasBuffer = 1000
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLogueosDeNivel( tnNivel as Integer ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		
		try
			loRetorno = this.oBufferLogueo.Item[ transform( tnNivel ) ]
		catch
			loRetorno = null
		endtry
		
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLogueos() as zoocoleccion OF zoocoleccion.prg
		return this.oBufferLogueo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoLog() as object
		return this.oUltimoLog
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearCantidadDeLineasDelBuffer( tnCantidad as Integer ) as Void
		this.nCantidadLineasBuffer = tnCantidad 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cLogger_Assign( txVal as Variant ) as Void
		if goDatos.EsNativa()
			this.cLogger = alltrim( upper( txVal ))			
		else
			this.cLogger = "FULL_" + alltrim( upper( txVal ))
		endif
		
		this.oInfoLog.Logger = this.cLogger
	endfunc

	*-----------------------------------------------------------------------------------------
	function Accion_Assign( txVal as Variant ) as Void
		this.oInfoLog.Accion = txVal 
		this.Accion = txVal 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Init
		This.cIdLogueo = sys( 2015 )
		this.oInfoLog = _screen.DotNetBridge.CrearObjeto( "ZooLogicSA.Core.InfoLogueo" )

		this.cLogger = upper( goRegistry.Nucleo.RepositorioParaLogueoPorDefecto )
		this.NivelParaLogueoPorDefecto = goRegistry.Nucleo.NivelParaLogueoPorDefecto
		
		if !inlist( alltrim( transform( this.NivelParaLogueoPorDefecto) ), "1", "2", "3", "4", "5" )
			this.NivelParaLogueoPorDefecto = 4 && Logueo del tipo INFO. el mismo definido en goRegistry.Nucleo.NivelParaLogueoPorDefecto
		endif 
				
		this.Accion = "NO DISP."
*		This.InicializarColecciones()
		This.SetearDatosCabecera()
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oBufferLogueo_Access() As object
		if !this.ldestroy and ( vartype( this.oBufferLogueo ) != 'O' or isnull( this.oBufferLogueo ) )
			this.oBufferLogueo = _screen.zoo.crearobjeto( 'zooColeccion' )
		endif
		return this.oBufferLogueo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Escribir( tcTexto as String, tnNivelLog as Integer ) as VOID 
		local lnNivel as Integer, lcNivel as String, loItem as Object, loNivel as zoocoleccion OF zoocoleccion.prg
		
		if pcount() = 2 and vartype( tnNivelLog ) == "N"
			lnNivel = tnNivelLog
		else
			lnNivel = this.NivelParaLogueoPorDefecto 
		endif

		lcNivel = transform( lnNivel )
		

		try
			loNivel = This.oBufferLogueo.Item[ lcNivel ]
		catch
			loNivel = _screen.zoo.crearobjeto( 'zooColeccion' )
			This.oBufferLogueo.Agregar( loNivel, lcNivel )
		endtry

		loItem = This.CrearObjetoLogueo()
		with loItem
			.Descripcion = tcTexto
			.TipoDeLogueo = lnNivel
		endwith
		
		this.oUltimoLog = loItem
		
		loNivel.Agregar( loItem )
		
		if loNivel.Count > this.nCantidadLineasBuffer
			goServicios.Logueos.GuardarParcialmente( this )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EscribirAlUltimo( tcTexto as String ) as Void

		if isnull( this.oUltimoLog )
		else
			this.oUltimoLog.Descripcion = this.oUltimoLog.Descripcion + tcTexto
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosGenerales( toItem as Object ) as VOID

		if vartype( goLibrerias ) = 'O' and !isnull( golibrerias )
		else
			goLibrerias = goservicios.librerias	
		endif
		with toItem
			.Hora = goLibrerias.ObtenerHora()
			.Fecha = goLibrerias.ObtenerFecha()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosCabecera() as Void
		local lcNombrePC as String, lcUsuarioPC as String
		lcNombrePC = alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) )
		lcUsuarioPC = alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ) 

		with this.oInfoLog
			.BaseDatos = alltrim( _screen.zoo.app.obtenersucursalactiva() )
			.Serie = _screen.zoo.app.cSerie
			.Version = _screen.zoo.app.ObtenerVersion()
			.Aplicacion = _screen.zoo.app.nombre	
			.NombrePc = lcNombrePc
			.UsuarioPc = lcUsuarioPc
			if !empty(goServicios.Seguridad.cUsuarioOtorgaPermiso)	
				.Usuario = goServicios.Seguridad.cUsuarioLogueado + " (Autorizó: " +goServicios.Seguridad.cUsuarioOtorgaPermiso + ")"
				goServicios.Seguridad.cUsuarioOtorgaPermiso = ''
			else
				.Usuario = goServicios.Seguridad.cUsuarioLogueado
			endif
			.OrigenLogueo = this.ObtenerOrigenLogueo()
			.EstadoSistema = goServicios.Seguridad.ObtenerEstadoDelSistema()
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerOrigenLogueo() as String
		local lcOrigen as String, lEsStartUp as Boolean, lEsEscritorio as Boolean, lEsRest as Boolean
		
		lEsStartUp = pemstatus( _Screen,"lEsModoSystemStartUp", 5) and _Screen.lEsModoSystemStartUp
		lEsEscritorio = pemstatus(_Screen,"lUsaCapaDePresentacion", 5) and _Screen.lUsaCapaDePresentacion 
		lEsScript = goServicios.Ejecucion.TieneScriptCargado() 
		lEsRest = pemstatus(_screen,"lUsaServicioRest", 5) and _Screen.lUsaServicioRest
		
		do case
			case lEsRest 
				lcOrigen = "RestApi"
			case lEsScript 
				lcOrigen = "Script"
			case lEsStartUp 
				lcOrigen = "StartUp"
			case lEsEscritorio
				lcOrigen = "UI"
			otherwise
				lcOrigen = "UI"
		endcase

		return lcOrigen
	 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearObjetoLogueo() as Void
		
		local loObjetoItem as Object
		loObjetoItem = newobject( 'ItemLogueo' )
		This.SetearDatosGenerales( loObjetoItem )
		return loObjetoItem
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.EliminarLogueos()

		This.oInfoLog = Null
		
		dodefault()
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarLogueos() as Void
		local loItem as Object, loNivel as zoocoleccion OF zoocoleccion.prg

		if type( "this.oBufferLogueo" ) = "O" and !isnull( this.oBufferLogueo )
			for each loNivel in this.oBufferLogueo foxobject 
				for each loItem in loNivel foxobject 
					loItem.Destroy()
				endfor

				loNivel.Remove(-1)
				loNivel.Release()
			endfor

			this.oBufferLogueo.Remove(-1)
			this.oBufferLogueo.Release()
		endif

		this.oBufferLogueo = null
		this.oUltimoLog = null
	endfunc 


enddefine

*****************************************************************
define class ItemLogueo as custom

	Fecha = {''}
	Hora = ''
	TipoDeLogueo = 0
	Descripcion = ''

enddefine

