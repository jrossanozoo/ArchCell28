define class Mensajes as Servicio of Servicio.prg

	#if .f.
		local this as Mensajes of Mensajes.prg
	#endif

	protected lMuestraMensajes
	
	oForm = null
	oColSuscriptoresSinEspera = null
	oLanzador = null
	oColLanzadores = null

	nSegundosInteraccion = 0
	lMuestraMensajes = .T.

	*-----------------------------------------------------------------------------------------
	function oColSuscriptoresSinEspera_Access() as Object
		if vartype( this.oColSuscriptoresSinEspera ) != 'O' or isnull( this.oColSuscriptoresSinEspera )
			this.oColSuscriptoresSinEspera = this.crearobjeto( "ZooColeccion" )
		endif		
		return this.oColSuscriptoresSinEspera
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClaseLanzador() as string
		local lcRetorno as String, llMuestraMensaje as Boolean

		try
			if type( "_screen.zoo" ) == "O" and !isnull( _screen.zoo )
				llMuestraMensaje = !_screen.zoo.EsModoSystemStartUp() and ( _screen.Zoo.UsaCapaDePresentacion() or _screen.Zoo.DebeInformarErrores() )
			else
				llMuestraMensaje = .f.
			endif
		catch
			llMuestraMensaje = .f.
		endtry

		if llMuestraMensaje and This.lMuestraMensajes
			lcRetorno = "LanzadorMensajesSonoros"
		else
			lcRetorno = "LanzadorMensajesSilenciosos"
		endif
		
		return lcRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColLanzadores_Access() as Object
		if !this.lDestroy and ( !vartype( this.oColLanzadores ) = "O" or isnull( this.oColLanzadores ) )
			this.oColLanzadores = this.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColLanzadores
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as VOID
		this.LiberarLanzadores( this.oColLanzadores )
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LiberarLanzadores( toColLanzadores as Collection ) as VOID
		local loLanzador as Object
		do while toColLanzadores.Count > 0
			loLanzador = toColLanzadores.Item[ 1 ]
			toColLanzadores.Quitar( 1 )
			if vartype( loLanzador ) = "O"
				loLanzador.Release()
			endif
		enddo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearLanzador() as Object
		local loLanzador as Object
		this.LiberarLanzadoresSinFormularios()
		loLanzador = this.CrearObjeto( this.ObtenerClaseLanzador() )
		bindevent( loLanzador, "CrearFormularioInformacion", this, "SeteaFormMensaje", 1 )
		this.oLanzador = loLanzador
		this.oColLanzadores.Agregar( loLanzador )
		return loLanzador
	endfunc

	*-----------------------------------------------------------------------------------------
	function SeteaFormMensaje( t1 as Variant, t2 as Variant, t3 as Variant, t4 as Variant, t5 as Variant ) as Void
		this.oForm = this.oLanzador.oForm
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LiberarLanzadoresSinFormularios() as Void
		local loLanzador as Object, loColLanzadoresALiberar as zoocoleccion OF zoocoleccion.prg
		loColLanzadoresALiberar = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		for each loLanzador in this.oColLanzadores
			if vartype( loLanzador ) = "O" and ( vartype( loLanzador.oForm ) != "O" or isnull( loLanzador.oForm ) )
				loColLanzadoresALiberar.Agregar( loLanzador )
			endif
		endfor
		this.LiberarLanzadores( loColLanzadoresALiberar )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local lnRetorno as integer, loLanzador as Object, lnSeconds as Double

		this.EnviarSinEspera()		&& Esto esta aca por un error de controlador fiscal que venia mandando mensajes sin espera
									&& y de pronto al tirar una excepcion el codigo no lo contemplaba y se necesitaba limpiar
									&& Cuando se refactorize acordarse de tocar eso( cualquier duda preguntarle a POLI )
									&& No se hace ahora por que FADETE esta apurado y la mensajeria tal cual esta no afecta esta funcionalidad
				
		loLanzador = this.CrearLanzador()

		lnSeconds = seconds()
		lnRetorno = loLanzador.Enviar( tvMensaje, tnBotones, tnIcono, tnBotonDefault, tcTitulo, tnTiempoEspera )
		lnSeconds = seconds() - lnSeconds 
		this.nSegundosInteraccion = this.nSegundosInteraccion + lnSeconds 

		return lnRetorno 
	endfunc

	*-------------------------------------------------------------------------------------
	function EnviarEstiloWindows(tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Void
		local lnEstilo as Integer, lnRetorno as Integer, lnParametros as Integer
		
		lnParametros = pcount()
		lnEstilo = goParametros.dibujante.estilo
		goParametros.dibujante.estilo = 2		
		do case
			case lnParametros = 1
				lnRetorno = this.enviar( tvMensaje )															
			case lnParametros = 2
				lnRetorno = this.enviar( tvMensaje, tnBotones )												
			case lnParametros = 3
				lnRetorno = this.enviar( tvMensaje, tnBotones, tnIcono )									
			case lnParametros = 4
				lnRetorno = this.enviar( tvMensaje, tnBotones, tnIcono, tnBotonDefault )						
			case lnParametros = 5												
				lnRetorno = this.enviar( tvMensaje, tnBotones, tnIcono, tnBotonDefault, tcTitulo )			
			case lnParametros = 6
				lnRetorno = this.enviar( tvMensaje, tnBotones, tnIcono, tnBotonDefault, tcTitulo, tnTiempoEspera )							
		endcase	
		
		
		goParametros.dibujante.estilo = lnEstilo
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Alertar( tvMensaje as Variant, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local lnRetorno as Integer

		lnRetorno = this.Enviar( tvMensaje, tnBotones, 0, tnBotonDefault, tcTitulo, tnTiempoEspera )
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Advertir( tvMensaje as Variant, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local lnRetorno as Integer

		lnRetorno =	this.Enviar( tvMensaje, tnBotones, 2, tnBotonDefault, tcTitulo, tnTiempoEspera )
		if vartype( this.oForm ) = 'O'
			this.oForm.Activate()
		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Preguntar( tvMensaje as Variant, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local lnRetorno as Integer

		lnRetorno =	this.Enviar( tvMensaje, tnBotones, 1, tnBotonDefault, tcTitulo, tnTiempoEspera )
		
		return lnRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Informar( tvMensaje as Variant, tnBotones as integer , tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local lnRetorno	as Integer

		lnRetorno =	this.Enviar( tvMensaje, tnBotones, 3, tnBotonDefault, tcTitulo, tnTiempoEspera )
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsperaConBotonCancelar( tvMensaje as Variant, tcTitulo as string, tnTiempoEspera as Integer, tlProcesando as boolean ) as Void
		local lnRetorno as Integer, lnIcono as Integer
		
		lnIcono = iif( tlProcesando, 4, 3 )
		lnRetorno =	this.Enviar( tvMensaje, 10, lnIcono, 0, tcTitulo, tnTiempoEspera )

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function EnviarSinEspera( tcMensaje as String, tcTitulo as string, tcTextoBoton as String ) as VOID 
		this.EnviarSinEsperaGenerico( tcMensaje, tcTitulo, tcTextoBoton, "Informacion.gif" )
	endfunc

	*-----------------------------------------------------------------------------------------	
	function EnviarSinEsperaProcesando( tcMensaje as String, tcTitulo as string, tcTextoBoton as String, tlNoHacePausa as Boolean ) as VOID 
		this.EnviarSinEsperaGenerico( tcMensaje, tcTitulo, tcTextoBoton, "Procesando.gif", tlNoHacePausa )
	endfunc

	*-----------------------------------------------------------------------------------------	
	function EnviarSinEsperaProcesandoEnEscritorio( tcMensaje as String, tcTitulo as string, tcTextoBoton as String ) as Form
		local llMuestraMensaje as Boolean, loMensajeSinEspera as Object, loForm as Object
		loForm = null
		llMuestraMensaje = .f.
		if type( "_screen.Zoo" ) == "O" and !isnull( _screen.Zoo )
			llMuestraMensaje = !_screen.zoo.EsModoSystemStartUp() and ( _screen.Zoo.UsaCapaDePresentacion() or _screen.Zoo.DebeInformarErrores() )
		endif
		if llMuestraMensaje
			loMensajeSinEspera = _screen.Zoo.CrearObjeto( "MensajeSinEspera", "MensajeSinEspera.prg" )
			loForm = loMensajeSinEspera.Enviar( tcMensaje, tcTitulo, tcTextoBoton, "Procesando.gif", .t. )
			loMensajeSinEspera.cNombreForm = ""
		endif
		return loForm
	endfunc

	*-----------------------------------------------------------------------------------------	
	function EnviarSinEsperaGenerico( tcMensaje as String, tcTitulo as string, tcTextoBoton as String, tcGif as string, tlNoHacePausa as Boolean ) as VOID 
		local i as Integer, loForm as Form, loLanzador as Object

		loLanzador = this.CrearLanzador()
		loForm = loLanzador.EnviarSinEspera( tcMensaje, tcTitulo, tcTextoBoton, tcGif, tlNoHacePausa )
		if type( "loForm" ) == "O" and !isnull( loForm )
			if ( loForm.Boton.Visible )
				bindevent( loForm.Boton, "Click", this, "EventoClickBotonSinEspera" )
			endif
		else
			with this.oColSuscriptoresSinEspera
				for i = 1 to .count
					unbindevents( this, "EventoClickBotonSinEspera", .Item[ i ], .getKey( i ) )
				endfor
				.Remove( -1 )
			endwith
			this.LiberarLanzadoresSinFormularios()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoClickBotonSinEspera() as Void
		** Evento que se dispara al hacer click en el boton del formulario sin espera
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SuscribirAEventoBotonEspera( toObjeto as Object, tcMetodo as String ) as Void
		bindevent( this, "EventoClickBotonSinEspera", toObjeto, tcMetodo )
		this.oColSuscriptoresSinEspera.agregar( toObjeto, tcMetodo )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function ObtenerTitulo() As String
		local loLanzador as LanzadorMensajes of LanzadorMensajes.prg, lcRetorno As String
		
		loLanzador = this.CrearObjeto( "LanzadorMensajes" )
		lcRetorno = loLanzador.ObtenerTitulo()
		loLanzador.Release()

		Return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Cerrar() as Void
		if vartype( this.oForm ) = "O"
			this.oForm.Cerrar()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarMensajeria( tlHabilitar as Boolean ) as Void
		this.lMuestraMensajes = tlHabilitar
	endfunc 
	
enddefine