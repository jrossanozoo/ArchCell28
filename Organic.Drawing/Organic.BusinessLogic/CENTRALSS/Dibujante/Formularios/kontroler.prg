define class Kontroler as ZooSession of ZooSession.prg

	#if .f.
		local this as Kontroler of Kontroler.prg
	#endif

	oInformacionUltimoProceso = Null

	*-----------------------------------------------------------------------------------------
	Function ObtenerControl( tcAtributo As String ) As Object
		Local loControl As Object, lcRutaControl As String, lcAtributo As String, loError as Exception, loEx as Exception
		Store "" To lcAtributo, lcRutaControl

		lcAtributo = Upper( tcAtributo )

		Try
			lcRutaControl = Thisform.ColControles( lcAtributo )
			loControl = &lcRutaControl
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Details = .Details + " (Control: " + lcAtributo + ")"
				goMensajes.Enviar( loEx )
				.Throw()
			EndWith
		Endtry

		Return loControl

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerRutaControl( tcAtributo As String ) As Object
		Local loControl As Object, lcRutaControl As String, lcAtributo As String, loError as Exception, loEx as Exception
		Store "" To lcAtributo, lcRutaControl

		lcAtributo = Upper( tcAtributo )

		Try
			lcRutaControl = Thisform.ColControles( lcAtributo )
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Details = .Details + " (Control: " + lcAtributo + ")"
				.Throw()
			EndWith
		Endtry

		Return lcRutaControl 

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ExisteControl( tcAtributo As String ) As Boolean
		Local lcAtributo As String, llExiste as Boolean

		llExiste = .f.
		lcAtributo = Upper( tcAtributo )
		Try
			=Thisform.ColControles( lcAtributo )
			llExiste = .t.
		catch
		Endtry

		Return llExiste

	Endfunc

	*-----------------------------------------------------------------------------------------
	function ManejarErrorProceso( toError as Object, tcMostrar as String, tcMensaje as String ) as Void
		local loEx as Object 
		
		loEx = Newobject( "ZooException", "ZooException.prg" )
		With loEx
			if empty( tcMensaje )
			else
				.message = tcMensaje
			endif 
			.Grabar( toError )
			this.LlenarInformacionUP()
			
			if .TengoInformacion()

				this.oInformacionUltimoProceso = _screen.zoo.crearobjeto( "zooInformacion" )
				this.LlenarInformacionUP( .oInformacion )

				goMensajes.&tcMostrar.( .oInformacion )	

			else
				this.oInformacionUltimoProceso.agregarInformacion( .message )				
				goMensajes.&tcMostrar.( loEx )	
			endif

		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		local lcCentury as String 
		this.oInformacionUltimoProceso = _screen.zoo.crearobjeto( "zooInformacion" )	
		lcCentury = [Set century ] + iif( goParametros.Dibujante.FormatoParaFecha = 1, "OFF", "ON" )
		&lcCentury
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LlenarInformacionUP( toInformacion as zooinformacion of zooInformacion.prg ) as Void
		local loItem as Object

		if ( pcount() = 0 )
			toInformacion = this.oInformacion
		endif
		
		for each loItem in toInformacion foxobject
			this.oInformacionUltimoProceso.agregarInformacion( loItem.cMensaje, loItem.nNumero, loItem.xInfoExtra )
		endfor
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	function PerderFoco( toControl as Object ) as Void
		** Aca se escribe logica al perder el foco un control especifico	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DesactivarAdvertenciaEnControlAsociado( tcAtributo as String ) as Void
		local loControl as Object
		if this.ExisteControl( tcAtributo )
			loControl = this.ObtenerControl( tcAtributo )
			if pemstatus( loControl, "DesactivarColorAdvertencia", 5 )
				loControl.DesactivarColorAdvertencia()
			endif
		endif
	endfunc

enddefine
