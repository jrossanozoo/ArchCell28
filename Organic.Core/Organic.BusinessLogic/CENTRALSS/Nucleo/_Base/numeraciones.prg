define class Numeraciones as Din_Numeraciones of Din_Numeraciones.prg

	#IF .f.
		Local this as Numeraciones of Numeraciones.prg
	#ENDIF

	protected oColEntidades, oEntidad, lTieneAutoImpresor, oCAI
	oColEntidades = null
	oEntidad = null
	oCAI = Null
	oTalonario = null
	lTieneAutoImpresor = .F.
	lForzarObtencionNumeroDesdeBuffer = .f.
	nCantidadASumar = 1	
	
	*-----------------------------------------------------------------------------------------
	function VaciarColecciones() as Void
		this.oColentidades.remove(-1)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void	
		dodefault()
		This.lTieneAutoImpresor = goParametros.Nucleo.HabilitarAutoImpresor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaEntidadAtributo( tcEntidadAtributo ) as Void
		local llRetorno as Boolean
		llRetorno = this.oColEntidades.buscar( tcEntidadAtributo )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function oTalonario_Access()
		if !this.ldestroy and !vartype( this.oTalonario ) = 'O'
			this.oTalonario = _screen.zoo.InstanciarEntidad( 'Talonario' )			
			this.oTalonario.lEsSubentidad = .T.
			this.oTalonario.oNumeraciones = this		
			bindevent(this,"SetearEntidad",this.oTalonario,"LimpiarEntidad",1)
		endif
		Return this.oTalonario
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function oCAI_Access()
		if !this.ldestroy and !vartype( this.oCAI ) = 'O'
			this.oCAI = _screen.zoo.InstanciarEntidad( 'CAI' )
		endif
		Return this.oCAI
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		********************* ESTO DEBE ESTAR GENERADO!!!!

		with this
			.lDestroy = .t.
			.oColEntidades = null
			.oEntidad = null
			.oColTalonarios = null
			
			if type( ".oCAI" ) = "O" and !isnull( .oCAI )
				.oCAI.release()
			endif
			if type( ".oTalonario" ) = "O" and !isnull( .oTalonario )
				.oTalonario.oNumeraciones = null
				.oTalonario.release()
			endif
		endwith
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LiberarEntidad() as Void
		this.oEntidad = null
		this.oColEntidades.remove(-1)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDisponibilidadServicio( tcServicio as String ) as Boolean
		local llReturn as Boolean
		llReturn = .f.

		do case
			case tcServicio = 'CF'
				if pemstatus( This.oEntidad, "cComprobante" , 5 )
					if inlist( This.oEntidad.cComprobante, "TICKETFACTURA","TICKETNOTADECREDITO", "TICKETNOTADEDEBITO" )
						if vartype( goControladorFiscal ) = "O"
							if goParametros.Felino.ControladoresFiscales.Codigo > 0
								llreturn = .t.
							endif						
						endif
					endif
				endif			
			case tcServicio = 'FUNCION'
				if pemstatus( this.oEntidad, "ObtenerNumeroString" , 5 )
					llreturn = .t.
				endif
		endcase
			
		return llReturn
	endfunc 

	*-----------------------------------------------------------------------------------------
	function UltimoNumero( tcAtributo as String ) as integer
		local lnRetorno as Integer, lcTalonario as String, loex as zooexception OF zooexception.prg

		lnRetorno = 0
		lcError = ""
	
		with this
			try
				lcTalonario = .obtenerTalonario( tcAtributo )
			catch to loError
				if vartype( loError.UserValue ) = "O" and ( loError.UserValue.nZooErrorNo = 9001 ) and this.oEntidad.cContexto = ""
					lcTalonario = ""
				else
					loex = _screen.zoo.crearobjeto( "ZooException" )
					loEx.Grabar( loError )
					throw loEx
				endif
			endtry
			
			if empty( lcTalonario )
				lnRetorno = 0
			else
				lnRetorno = .ObtenerUltimoNumeroTalonario( lcTalonario )
			endif
		endwith

		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTalonario( tcAtributo as String ) as String
		local lcTalonario as String, loError as Exception, loEx as Exception, lcServicio as String 
		with this

			lcTalonario = .obtenerTalonarioEntidad( tcAtributo )
			lcTalonario = .oTalonario.ArmarTalonario( lcTalonario, this.oEntidad )
			lcServicio = This.ObtenerServicio( tcAtributo )
			if !empty( lcTalonario ) and (empty( lcServicio ) or lcServicio = "REG" )
				try
					lcTalonario = .oTalonario.ObtenerTalonario( lcTalonario )
					.oTalonario.entidad = this.oentidad.cnombre
				catch to loError
					loEx = Newobject( "ZooException", "ZooException.prg" )
					with loEx
						.Grabar( loError )
						if .nZooErrorNo = 9001
							.AgregarInformacion( "El talonario " + lcTalonario + " de la entidad " + this.oEntidad.ObtenerDescripcion() + " no existe" )
						endif
						.Throw()
					endwith
				endtry
			endif
		endwith

		return lcTalonario
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumero( tcAtributo as String, tlEliminando as boolean, tlNumeroReal as Boolean ) as integer
		local lnNumero as Integer, lcTalonario as String, lcServicio as String, llDebeObetenerNumero as Boolean, ;
		lnNumeroFaltante as Integer, lnNumeracionExistente as Integer
		*** En la tabla numeraciones se esta guardando el ultimo usado. A la hora de obtener un numero hay que sumarle 1.
		llDebeObtenerNumero = .t.
		lnNumeroFaltante  = 0
		lnNumeracionExistente = 0
 		
		if pemstatus( this.oEntidad, "lObteniendoLetra", 5 )
			llDebeObtenerNumero = !this.oEntidad.lObteniendoLetra or inlist( goparametros.nucleo.datosGENERALES.pais, 2, 3 )
		endif

			with this
				lcServicio = .ObtenerServicio( tcAtributo )
				lnNumero = 0
				if empty( lcServicio ) or lcServicio = "REG"
					if llDebeobtenerNumero 
						.AgregarTalonario( tcAtributo )
						lcTalonario = .obtenerTalonario( tcAtributo )
						if .oTalonario.Asignacion = 2 and this.oEntidad.cContexto = "I"
							lnNumero = .oEntidad.numero
						else
							if empty( lcTalonario )
								lnNumero = 0
							else
								lnNumero = .ObtenerUltimoNumeroTalonario( lcTalonario )
								if lnNumero = 0
									lnNumeracionExistente = this.BuscarNumeracionesExistentes( tcAtributo ) 
									lnNumero = iif ( vartype ( lnNumeracionExistente ) = "C", int (val ( lnNumeracionExistente )), lnNumeracionExistente )
								endif	
								lnNumero = lnNumero + iif( tlEliminando, -this.nCantidadASumar, this.nCantidadASumar )
								
								if .oTalonario.MaximoNumero>0 and lnNumero > .oTalonario.MaximoNumero
									goServicios.Errores.LevantarExcepcion( "Se ha llegado al máximo disponible (" + transform(.oTalonario.MaximoNumero) + ") para el talonario de " + .oEntidad.ObtenerDescripcion() + " (" + alltrim( lcTalonario ) + ")." )
								endif
							endif
						endif

					if !tlEliminando and pemstatus( This.oEntidad, "lVieneDeEcommerce" , 5 ) and This.oEntidad.lVieneDeEcommerce
						lnNumeroFaltante = this.BuscarFaltanteNumeraciones( tcAtributo )
						if lnNumeroFaltante > 0 and lnNumeroFaltante < lnNumero
							lnNumero = lnNumeroFaltante 
						endif 
					endif
				
				else
					lnNumero = this.oEntidad.numero
				endif
			else
				if .ValidarDisponibilidadServicio( lcServicio )
					lnNumero = .ObtenerNumeroDesdeServicio( lcServicio, tlNumeroReal )
				else
					goServicios.Errores.LevantarExcepcion( "No se encontró servicio para la entidad " + .oEntidad.ObtenerDescripcion() )
				endif
			endif
		endwith


			if 	empty( lcServicio ) and llDebeObtenerNumero and this.ValidarReservaDeNumeros( tcAtributo )
				this.ActualizarTalonario( .F., lcTalonario, tcAtributo, lnNumero, tlEliminando )
			endif

		if vartype( lnNumero ) = "C"
			return iif( lnNumero = "", "0", lnNumero )
		else
			return iif( lnNumero < 0, 0, lnNumero )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroDesdeServicio( tcServicio as string, tlNumeroReal as Boolean ) as integer
		local lnNumero as Integer
		lnNumero = 0
		do case
			case tcServicio = 'CF' and ( tlNumeroReal and !this.lForzarObtencionNumeroDesdeBuffer )
				This.oEntidad.eventoMensajeControlador( "Comunicándose con el controlador fiscal." )
				
				do case
					case upper( this.oEntidad.cComprobante ) = 'TICKETNOTADECREDITO'			
						lnNumero = goControladorFiscal.ObtenerUltimoNumNotaCredito( This.oEntidad.Letra ) + 1

					case upper( this.oEntidad.cComprobante ) = 'TICKETFACTURA' 
						lnNumero = goControladorFiscal.ObtenerUltimoNumFactura( This.oEntidad.Letra ) + 1

					case upper( this.oEntidad.cComprobante ) = 'TICKETNOTADEDEBITO'			
						lnNumero = goControladorFiscal.ObtenerUltimoNumNotaDebito( This.oEntidad.Letra ) + 1

					otherwise
						This.oEntidad.eventoMensajeControlador()
						goServicios.Errores.LevantarExcepcion( "El comprobante no acepta este servicio. " + this.oEntidad.ObtenerDescripcion() )
				endcase
				
				This.oEntidad.eventoMensajeControlador()
				
				if lnNumero = 0 and pemstatus( This.oEntidad, "EventoErrorAlObtenerNumeracionDeServicio", 5 )
					This.oEntidad.EventoErrorAlObtenerNumeracionDeServicio( "Controlador Fiscal" )
				endif

			case tcServicio = 'CF' and ( !tlNumeroReal or this.lForzarObtencionNumeroDesdeBuffer )
				do case
					case upper( this.oEntidad.cComprobante ) = 'TICKETNOTADECREDITO'			
						lnNumero = goControladorFiscal.ObtenerUltimoNumNotaCreditoBuffer( This.oEntidad.Letra )

					case upper( this.oEntidad.cComprobante ) = 'TICKETFACTURA' 
						lnNumero = goControladorFiscal.ObtenerUltimoNumFacturaBuffer( This.oEntidad.Letra )

					case upper( this.oEntidad.cComprobante ) = 'TICKETNOTADEDEBITO'			
						lnNumero = goControladorFiscal.ObtenerUltimoNumNotaDebitoBuffer( This.oEntidad.Letra )

					otherwise
						This.oEntidad.eventoMensajeControlador()
						goServicios.Errores.LevantarExcepcion( "El comprobante no acepta este servicio. " + this.oEntidad.ObtenerDescripcion() )
				endcase
				if !this.lForzarObtencionNumeroDesdeBuffer
					lnNumero = lnNumero + 1 
				endif
			case tcServicio = 'FUNCION'
				lnNumero = this.oEntidad.ObtenerNumeroString()
			otherwise
				goServicios.Errores.LevantarExcepcion( "No se encontró el servicio para la entidad " + this.oEntidad.ObtenerDescripcion() )
		endcase
		
		return lnNumero 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function grabar( tcAtributo as String ) as integer
		local lnNumero as integer, lcServicio as String

		lcServicio = this.ObtenerServicio( tcAtributo )

		if (empty(lcServicio) or lcServicio = "REG")  and this.ValidarReservaDeNumeros( tcAtributo )
			lnNumero = evaluate('this.oentidad.' + allt( tcAtributo ) )
		else
			lnNumero = this.GrabarTalonario( tcAtributo )
		endif
		
		return lnNumero
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Actualizar( tcAtributo as String ) as int

		local lnNumero as integer, lcServicio as String

		lcServicio = this.ObtenerServicio( tcAtributo )

		if  empty(lcServicio) and this.ValidarReservaDeNumeros( tcAtributo )
			lnNumero = evaluate('this.oentidad.' + allt( tcAtributo ) )
		else
			lnNumero = this.GrabarTalonario( tcAtributo, .t. )
		endif
		
		return lnNumero
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarRenumerar( tcAtributo as String ) as boolean
		local llRetorno as boolean
		
		with this
			llRetorno = .oEntidad.VerificarContexto( '' ) or ( .oEntidad.VerificarContexto( 'B' ) and .EsNumeracionPrincipal( tcAtributo ) )
		endwith
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GrabarTalonario( tcAtributo as string, tlEliminando as boolean ) as integer
		local lnNumero as integer, lcTalonario as String, lcServicio as string, lnRetorno as integer, loError as Exception,;
				loEx as zooexception OF zooexception.prg

		with this
			lnRetorno = 0
			lnNumero = 0
			lcTalonario = ""
			try
				lcTalonario = .obtenerTalonario( tcAtributo )
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					if .nZooErrorNo = 9001 and this.oEntidad.VerificarContexto( 'CB' )
						lcTalonario = this.obtenerTalonarioEntidad( tcAtributo )
						lcTalonario = this.oTalonario.ArmarTalonario( lcTalonario, this.oEntidad )
					else
						.throw()
					endif
				endwith
			endtry	

			if empty( lcTalonario )
			else
				lcServicio = .ObtenerServicio( tcAtributo )
				if empty( lcServicio ) or lcServicio = "REG"
					lnNumero = .GrabarEntidadTalonario( lcTalonario , tcAtributo, tlEliminando )
				else
					if .oEntidad.VerificarContexto( 'CB' )
					else
						lnNumero = .ObtenerNumero( tcAtributo, tlEliminando, .t. )
						if lnNumero <= iif( vartype( lnNumero ) = "C", "", 0 )
							goServicios.Errores.LevantarExcepcion( "No se pudo obtener el último número de comprobante" )
						endif
					endif	
				endif
			endif

			if .VerificarRenumerar( tcAtributo ) or ( .oEntidad.lDebeRenumerarAlEnviarABaseDeDatos and .oEntidad.VerificarContexto( 'B' ) ) or this.DebeRenumerarPorVenirDeHerEcom()
				lnRetorno = lnNumero
			else
				lnRetorno = .oEntidad.&tcAtributo
			endif		
		endwith
		
		return lnRetorno 		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GrabarEntidadTalonario( tcTalonario as string, tcAtributo as string, tlEliminando as boolean ) as VOID
		local loError as Exception, llNuevo as Boolean, lnNumero as integer, loEx as zooexception OF zooexception.prg, lnI as Integer, loExcepcionNumeroYaUsado as Object, ;
			lnCantidadDeReintentos as Integer, llHayFaltanteEnNumeracion as Boolean
			
			llHayFaltanteEnNumeracion = .f.

		with this
			if Empty( tcTalonario )
			else
				if .ElAtributoConTalonarioEsClavePrimaria( tcAtributo )
					lnCantidadDeReintentos = 3
				else
					lnCantidadDeReintentos = 1
				endif
				for lnI = 1 to lnCantidadDeReintentos
					lnNumero = 0
					llNuevo = .f.
					try
						lnNumero = .ObtenerNumero( tcAtributo, tlEliminando, .t. )

					catch to loError
						loEx = Newobject( "ZooException", "ZooException.prg" )
						
						With loEx
							.Grabar( loError )
							if .nZooErrorNo = 9001 and this.oEntidad.VerificarContexto( 'CB' )
								llNuevo = .t.
							else
								.throw()
							endif
						endwith
					endtry

					try
						.ActualizarTalonario( llNuevo, tcTalonario, tcAtributo, lnNumero, tlEliminando  )
						lnI = lnCantidadDeReintentos

						if pemstatus( This.oEntidad, "lVieneDeEcommerce" , 5 ) and This.oEntidad.lVieneDeEcommerce and .oTalonario.Numero > lnNumero						
							llHayFaltanteEnNumeracion = .t.
						endif
					catch to loError
						loExcepcionNumeroYaUsado = newobject( "ExcepcionNumeroYaUsado", "numeraciones.prg" )
						if vartype( loError.UserValue ) = "O" and loError.uservalue.ErrorNo = loExcepcionNumeroYaUsado.ErrorNo and lnI < lnCantidadDeReintentos
							** reintenta
						else
							goServicios.Errores.LevantarExcepcion( loError )
						endif
					endtry
				endfor

			endif
			
			return iif ( llHayFaltanteEnNumeracion, lnNumero, .oTalonario.Numero )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarTalonario( tlNuevo as Boolean, tcTalonario as String, tcAtributo as String, tnNumero as Integer, tlEliminando as Boolean 	) as Void
		local llRenumerar as Boolean, lcNombreEntidad as String, loError as Exception, lxAtributoEntidad as Variant, ;
			lnNumeroAGrabar as Number, lnIntentoObtenerNuevoNumero as Number, lnUltimoNumeroAntesDeGrabar as Integer, ;
			llCancelaParaNoRetrasarNumeracionEnMasDeUno as Boolean, llNoPersistir as Boolean

		llCancelaParaNoRetrasarNumeracionEnMasDeUno = .f.
		llRenumerar = This.VerificarRenumerar( tcAtributo )
		with this.oTalonario
			try
				lxAtributoEntidad = iif( vartype( This.oEntidad.&tcAtributo ) = 'C', int( val( This.oEntidad.&tcAtributo ) ), This.oEntidad.&tcAtributo )
				if tlNuevo &&por aca solo entra si es Transferencia cualquiera (C o B)
					lcNombreEntidad = This.oEntidad.obtenerNombre()
					.Nuevo()
					.Codigo = tcTalonario
					.Entidad = lcNombreEntidad
					.Atributo = tcAtributo
					.Numero = 1
					This.SetearAtributosRelacionados( tcAtributo )
					if llRenumerar
					else
						.Numero = max( lxAtributoEntidad, .Numero )
					endif
				else
					if upper( alltrim( this.oEntidad.cNombre ) ) <> upper( alltrim( this.oTalonario.cNombre ) ) and !tlEliminando and !this.oEntidad.VerificarContexto("CI")
						.lIgnorarFiltroNumero = .f.
					else
						.lIgnorarFiltroNumero = .t.
					endif

					this.EventoAntesDeGrabarNuevoNumeroDeTalonario()
					*.oNumeraciones = this
					.Modificar()
					lnUltimoNumeroAntesDeGrabar = .Numero
					if llRenumerar or ( this.oEntidad.lDebeRenumerarAlEnviarABaseDeDatos and this.oEntidad.VerificarContexto( 'B' ) )
						lnNumeroAGrabar = tnNumero
					else
						lnNumeroAGrabar = max( lxAtributoEntidad, .Numero )
					endif
					if  this.oEntidad.cContexto = "C" or ( this.oEntidad.cContexto = "R" and this.oTalonario.Asignacion = 2 )
						if .Numero == lnNumeroAGrabar 
							llNoPersistir = .t.
						endif
						.Numero = lnNumeroAGrabar 
					else
						.Numero = this.ObtenerProximoNumeroAGrabar( lnNumeroAGrabar, tcTalonario, tcAtributo, tlEliminando ) 
					endif

					if tlEliminando and ( lnUltimoNumeroAntesDeGrabar - .Numero ) > 1
						llCancelaParaNoRetrasarNumeracionEnMasDeUno = .t.
					endif
				endif
	
				if pemstatus( This.oEntidad, "lVieneDeEcommerce" , 5 ) and This.oEntidad.lVieneDeEcommerce and .Numero > lnNumeroAGrabar 
					llNoPersistir = .t.
				endif
				
				if llCancelaParaNoRetrasarNumeracionEnMasDeUno or llNoPersistir 
					.Cancelar()
				else
					.Grabar()
				endif
			catch to loError
				.Cancelar()
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		endwith
			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerProximoNumeroAGrabar( tlNumeroaGrabar as integer, tcTalonario as string, tcAtributo as string, tlEliminando as Boolean ) as Number
		local lnNumero as Number, lnIntentoObtenerNuevoNumero as NumberlnNumeroAGrabar ,lnNumeroAGrabar as Number, i as Integer
		lnNumero = 0
		with this.oTalonario
		
			if !tlEliminando and .Numero => tlNumeroaGrabar
				lnIntentoObtenerNuevoNumero = 1
				for i = lnIntentoObtenerNuevoNumero to goRegistry.Nucleo.ReintentosDeObtencionDeNumeroConTalonarioUsado
					lnNumeroAGrabar = This.ObtenerUltimoNumeroTalonario( tcTalonario )
					if lnNumeroAGrabar = 0
						lnNumeroAGrabar = this.BuscarNumeracionesExistentes( tcAtributo )
					endif	
					if .Numero => lnNumeroAGrabar
						lnNumero  = lnNumeroAGrabar + 1
						exit
					endif
				endfor
			else
				lnNumero = tlNumeroaGrabar 
			endif		
		endwith	
		
		return lnNumero
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeGrabarNuevoNumeroDeTalonario() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosRelacionados( tcAtributo as String) as Void

		local lcTalonario as string, lxValor as Variant, lcAtributo as String

		*-- Asigna los atributos genericos
		lcTalonario = this.obtenerTalonarioEntidad( tcAtributo )
		if at( "#", lcTalonario ) > 0
			do while at( "#", lcTalonario ) > 0
				lcAtributo = substr( lcTalonario, at( "#", lcTalonario ) + 1, at( "@", lcTalonario ) - at( "#", lcTalonario ) - 1 )
				
				lxValor = This.oEntidad.&lcAtributo

				This.oTalonario.&lcAtributo = lxValor
				lcTalonario = substr( lcTalonario, at( "@", lcTalonario ) + 1 )
				
			enddo
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerServicio( tcAtributo as String ) as String
		return this.ObtenerServicioSegunEntidad( this.oEntidad.ObtenerNombre(), tcAtributo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSiPuedeReservar( tcEntidad as string, tcAtributo as String ) as Boolean
		local llPuedeReservar as Boolean, lcClave as String, loColTalonarios as Object, i as integer, ;
			lcDescripcionEntidad as String, loEntidadFake as Object, lSetearEntidad as Boolean 
		lSetearEntidad = .t.	
		llPuedeReservar = .f.
		with this
			if empty( tcAtributo )
				tcAtributo = this.ObtenerAtributo( tcEntidad )
			endif
			lcClave = upper( alltrim( tcEntidad ) ) + "." + upper( alltrim( tcAtributo ) )
			if .oColEntidades.count = 0 or upper(alltrim(this.oEntidad.cnombre)) != upper(alltrim(tcEntidad))&&lSetearEntidad 
				loEntidadFake = newobject("EntidadAuxiliar")
				loEntidadFake.cNombre = tcEntidad
				.setearentidad( loEntidadFake )
			endif
			
			if .oColEntidades.buscar( lcClave )
				loColTalonarios = .oColEntidades( lcClave ).oColTalonarios

				for i = 1 to loColTalonarios.count 
					llPuedeReservar = loColTalonarios( i ).lPuedeReservar 
				endfor 
			else
				lcDescripcionEntidad = this.ObtenerDescripcionDeEntidadParaError( tcEntidad )
				goServicios.Errores.LevantarExcepcion( "La entidad " + alltrim( lcDescripcionEntidad ) + " no tiene numeración asociada para el atributo " + tcAtributo )
			endif 
		endwith 
		
		return llPuedeReservar 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerServicioSegunEntidad( tcEntidad as string, tcAtributo as String ) as String
		local lcServicio as String, lcClave as String, loColTalonarios as Object, i as integer, ;
			lcDescripcionEntidad as String, lcAux as String

		lcServicio = ""
		lcAux = ""
		this.VerificarColeccionDeEntidadesParaComprobantesElectronicosDeCredito( tcEntidad )
		with this
			if empty( tcAtributo )
				tcAtributo = this.ObtenerAtributoNumerador( tcEntidad )
			endif
			lcClave = upper( alltrim( tcEntidad ) ) + "." + upper( alltrim( tcAtributo ) )
			if .oColEntidades.buscar( lcClave )
				loColTalonarios = .oColEntidades( lcClave ).oColTalonarios

				for i = 1 to loColTalonarios.count 
					lcAux = loColTalonarios( i ).cServicio
					if !empty( lcAux ) 
						if upper(alltrim(lcAux)) != "REG" 
							lcServicio = lcAux
						else
							if goParametros.Felino.ControladoresFiscales.Codigo = 35
								lcServicio = lcAux      
							endif	
						endif
					endif	
				endfor 
*!*					if !empty(lcServicio)
*!*							if vartype( goControladorFiscal ) = "O"
*!*								if goParametros.Felino.ControladoresFiscales.Codigo = 35
*!*									lcServicio = "REG"
*!*								else
*!*									lcServicio = "CF"
*!*								endif						
*!*							endif					
*!*					endif 				
			else
			 
				lcDescripcionEntidad = this.ObtenerDescripcionDeEntidadParaError( tcEntidad )
				goServicios.Errores.LevantarExcepcion( "La entidad " + alltrim( lcDescripcionEntidad ) + " no tiene numeración asociada para el atributo " + tcAtributo )
			endif 
		endwith
			
		return lcServicio
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoNumerador( tcEntidad as String ) as Void
		local lcAtributo as String, i as Integer
		
		lcAtributo = "" 
		for i = 1 to this.oColEntidades.Count
			if upper( alltrim( this.oColEntidades[i].cEntidad ) ) == upper( alltrim( tcEntidad ) )
				lcAtributo = this.oColEntidades[i].cAtributo
				exit
			endif
		endfor
		
		return lcAtributo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionDeEntidadParaError( tcEntidad as String ) as String
		local lcDescripcionEntidad as String
		
		if vartype( this.oEntidad ) = "O" and !isnull( this.oEntidad )
			lcDescripcionEntidad = .oEntidad.ObtenerDescripcion()
		else
			lcDescripcionEntidad = proper( tcEntidad )
		endif
		
		return lcDescripcionEntidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTalonarioEntidad( tcAtributo as String ) as string 
		local lcClave as String, i as Integer, lcTalonario as String, lcCondicion as String, loColTalonarios as Object
		
		lcTalonario = ""
	
		with this
			lcClave = upper( alltrim( .oEntidad.ObtenerNombre() ) ) + "." + upper( alltrim( tcAtributo ) )

			if .oColEntidades.buscar( lcClave )
				***tengo que buscar en la coleccion que esta adentro de oColEntidades el oColTalonarios valido para la entidad
				loColTalonarios = .oColEntidades( lcClave ).oColTalonarios
				for i = 1 to loColTalonarios.count 

					lcCondicion = loColTalonarios.Item( i ).cCondicion
					if empty( lcCondicion )
						lcTalonario = loColTalonarios.Item( i ).cTalonario
					else
						if .evaluarCondicion( lcCondicion )
							lcTalonario = loColTalonarios.Item( i ).cTalonario
							exit
						endif 
					endif 
				endfor 
			else
				
				goServicios.Errores.LevantarExcepcion( "La entidad " + alltrim( .oEntidad.ObtenerDescripcion() ) + " no tiene numeración asociada para el atributo " + tcAtributo )
			endif 

			if empty( lcTalonario )
				goServicios.Errores.LevantarExcepcion( "No se encontró la numeración para la entidad " + .oEntidad.ObtenerDescripcion() )
			endif
		endwith 
		
		return lcTalonario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EvaluarCondicion( tcCondicion as String ) as boolean
		local llReturn as Boolean 

		llReturn = evaluate("this.oEntidad." + tcCondicion)

		return llReturn 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerUltimoNumeroTalonario( tcTalonario as string ) as integer
		local loError as Exception , loEx as exception, lnRetorno as integer

		lnRetorno = 0
		with this
			try
				.oTalonario.Codigo = tcTalonario
				.oTalonario.entidad = this.oentidad.cnombre
				lnRetorno = .oTalonario.Numero
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					if .nZooErrorNo = 9001
						.AgregarInformacion( "El talonario " + tcTalonario + " de la entidad " + this.oEntidad.ObtenerDescripcion() + " no existe" )
					endif
					.Throw()
				EndWith
			endtry
		endwith
		
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreEntidad( tcEntidad as string )
		this.oEntidad.cNombre = tcEntidad
		this.oEntidad.cComprobante = tcEntidad
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearEntidad( toEntidad as object )
		this.oEntidad = toEntidad
		dodefault( toEntidad )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsNumeracionPrincipal( tcAtributo as string ) as Void
		local llRetorno as boolean, lcClave as String
		
		with this
			lcClave = upper( alltrim( .oEntidad.ObtenerNombre() ) ) + "." + upper( alltrim( tcAtributo ) )
			
			llRetorno = .f.
			if .oColEntidades.Buscar( lcClave )
				llRetorno = .oColEntidades( lcClave ).lNumeracionPrincipal
			else
				 
				goServicios.Errores.LevantarExcepcion( "La entidad " + alltrim( .oEntidad.ObtenerDescripcion() ) + " no tiene numeración asociada para el atributo " + tcAtributo )
			endif 
		endwith 
		
		return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function AsignarAtributosCAI( tcAtributoNumero as String, tcAtributoFechaCAI as string ) as Void
		local loObjetoCAI as Object, lcAtributoFecha as String, lcTalonario as String
		
		with This
			if .lTieneAutoImpresor
				
				lcTalonario = .ObtenerTalonario( tcAtributoNumero )
				lcAtributoFecha = alltrim( tcAtributoFechaCAI )

				loObjetoCAI = .oCAI.ObtenerDatosCAI( lcTalonario, .oEntidad.&lcAtributoFecha, .oEntidad.&tcAtributoNumero )

				.oEntidad.CAI = loObjetoCAI.nNumero
				.oEntidad.FechaVtoCAI = loObjetoCAI.dFechaVto
				.oEntidad.CodigoBarraAutoImpresor = loObjetoCAI.cCodigoDeBarras
			EndIf
		EndWith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarReservaDeNumeros( tcAtributo as String ) as Void

		local lcTalonario as string, loEx as zooexception OF zooexception.prg, llRetorno as Boolean
		with this
			lcTalonario = ""
			try
				lcTalonario = .obtenerTalonario( tcAtributo )
				
				.otalonario.codigo = lcTalonario
				.oTalonario.entidad = this.oentidad.cnombre
				llRetorno = .otalonario.ObtenerSiReservaNumeros()
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					if .nZooErrorNo = 9001 and this.oEntidad.VerificarContexto( 'CB' )
						lcTalonario = this.obtenerTalonarioEntidad( tcAtributo )
						lcTalonario = this.oTalonario.ArmarTalonario( lcTalonario, this.oEntidad )
					else
						.throw()
					endif
				endwith
			endtry
		endwith

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarTalonario( tcAtributo as String, tcTalonario as String ) as Void

		local lcAtributo as String, loError as Exception
		store "" to lcAtributo
		
		with this.oTalonario
			Try
				.Nuevo()
				.entidad = This.oEntidad.obtenerNombre()
				.codigo = tcTalonario

				lcTalonario = this.obtenerTalonarioEntidad( tcAtributo )
				
				if at( "#", lcTalonario  ) > 0
					do while at( "#", lcTalonario ) > 0
						lcAtributo = substr( lcTalonario , at( "#", lcTalonario ) + 1, at( "@", lcTalonario ) - at( "#", lcTalonario ) - 1 )
						.&lcAtributo = this.oentiDAD.&lcAtributo
						lcTalonario  = substr( lcTalonario , at( "@", lcTalonario ) + 1 )
					enddo 
				endif 
				.Grabar()
			catch to loError
				.Cancelar()
				goServicios.Errores.LevantarExcepcion( loError )
			Endtry
		endwith
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarTalonario( tcAtributo as String ) 
		local llRetorno as Boolean, lcTalonario as String, loEx as zooexception OF zooexception.prg, lnI as Integer, lnCantidadDeReintentos as Integer, ;
			loExcepcionCodigoYaExiste as Object

		lnCantidadDeReintentos = 3
		for lnI = 1 to lnCantidadDeReintentos
			llRetorno = .T.
			with this
				lcTalonario = .obtenerTalonarioEntidad( tcAtributo )
				lcTalonario = .oTalonario.ArmarTalonario( lcTalonario, this.oEntidad )
				try
					this.oTalonario.Codigo = lcTalonario
					this.oTalonario.entidad = this.oentidad.cnombre
					lnI = lnCantidadDeReintentos
				catch
					llRetorno = .F.
				endtry

				if llRetorno 
				else
					try
						this.CargarTalonario( tcAtributo, lcTalonario )
						lnI = lnCantidadDeReintentos
					catch to loError
						loExcepcionCodigoYaExiste = newobject( "ExcepcionCodigoYaExiste", "numeraciones.prg" )
						if vartype( loError.UserValue ) = "O" and loError.ErrorNo = loExcepcionCodigoYaExiste.ErrorNo and lnI < lnCantidadDeReintentos
							** reintenta
						else
							loEx = Newobject( "ZooException", "ZooException.prg" )
							with loEx
								.Grabar( loError )
								.AgregarInformacion( "Se produjo un error al cargar el talonario de " + this.oEntidad.ObtenerDescripcion() )
								.Throw()
							endwith
						endif
					endtry
				endif
			endwith
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TalonarioConNumeracionDisponible() as Boolean

		local loError as Exception , loEx as exception, llRetorno as Boolean, lcAtributo as String, lnUltimoNumero as Integer, lnMaximoNumero as Integer
		
		llRetorno = .t.

		with this
			try

				lnUltimoNumero = .oTalonario.Numero &&.UltimoNumero( lcAtributo )
				lnMaximoNumero = .oTalonario.MaximoNumero
				if lnMaximoNumero > 0 and lnUltimoNumero >= lnMaximoNumero
					llRetorno = .f.
				endif

			catch to loError
				.AgregarInformacion( "Error al consultar la disponibilidad del talonario" )
			endtry
		endwith
		
		return llRetorno 

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function BuscarUltimoNumeroExistenteEnEntidad( tcEntidad as String, tcPuntoDeVenta as String ) as Integer
		local lnRetorno as Integer, lcCondicion as string, lcXml as String, lcCursor as String 
		lnRetorno = 0
		if this.oEntidad.cNombre = tcEntidad and pemstatus( this.oEntidad, "oAd", 5 ) and type( "this.oEntidad.oAd" ) = "O"
			lcCursor = sys( 2015 )
			lcCondicion = this.oEntidad.oAd.ObtenerCampoEntidad( "PUNTODEVENTA" ) + " = " + tcPuntoDeVenta 
			lcXml = this.oEntidad.ObtenerDatosEntidad( "NUMEROC", lcCondicion ,, "MAX" )
			xmltocursor( lcXml, lcCursor )
			select ( lcCursor )
			lnRetorno = nvl( evaluate( lcCursor + ".MAX_NUMEROC" ), 0 )
			use in select( lcCursor )
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarNumeracionesExistentes( tcAtributo as String) as Integer  
		local lnRetorno as Integer, lcTalonario as String, loBuscador as Object  
		lcTalonario = this.ObtenerTalonarioEntidad( tcAtributo )
		loBuscador = newobject( "BuscadorAdicionalNumeraciones", "BuscadorAdicionalNumeraciones.prg" )
		lnRetorno = loBuscador.Buscar( this.oEntidad, lcTalonario, tcAtributo )
		
		return lnRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function BuscarFaltanteNumeraciones( tcAtributo as String) as Integer  
		local lnRetorno as Integer, lcTalonario as String, loBuscador as Object  
		lcTalonario = this.ObtenerTalonarioEntidad( tcAtributo )
		loBuscador = newobject( "BuscadorAdicionalNumeraciones", "BuscadorAdicionalNumeraciones.prg" )
		lnRetorno = loBuscador.BuscarFaltante( this.oEntidad, lcTalonario, tcAtributo, 10 )
		
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPuntoDeVentaUnicoPorEntidadDesdeTalonario() as Integer
		local lcXml as String, lcCursor as String, lcCursorAgrup as String, lnPuntoDeVenta as Integer, lcCondicion as String, lnRegistrosConsulta as Integer
		lnPuntoDeVenta = 0
		lcCursor = sys(2015)
		lcCursorAgrup = sys(2015)

		lcCondicion = "Entidad = '" + alltrim( this.oEntidad.ObtenerNombre() ) + "'"
		lcXml = this.oTalonario.ObtenerDatosEntidad( 'PuntoDeVenta', lcCondicion )
		lnRegistrosConsulta = xmltocursor( lcXml, lcCursor )
		if lnRegistrosConsulta > 0
			select PuntoDeVenta from &lcCursor group by PuntoDeVenta into cursor &lcCursorAgrup
			if _Tally = 1
				lnPuntoDeVenta = &lcCursorAgrup..PuntoDeVenta
			endif
			use in select( lcCursorAgrup)
		endif
		use in select( lcCursor)

		return lnPuntoDeVenta
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ElAtributoConTalonarioEsClavePrimaria( tcAtributo as String ) as Boolean
		local llEsClavePrimaria as Boolean
		llEsClavePrimaria = ( alltrim( upper( tcAtributo ) ) == alltrim( upper( this.oEntidad.ObtenerAtributoClavePrimaria() ) ) )
		return llEsClavePrimaria
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarEntidadCargada( tcEntidad ) as Boolean
		local llRetorno as Boolean
		llRetorno = this.oColEntidades.Buscar( tcEntidad )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarColeccionDeEntidadesParaComprobantesElectronicosDeCredito( tcEntidad as String) as Void
		local llEntidadEncontrada
		
		llEntidadEncontrada = .f.
		tcEntidad = upper(alltrim( tcEntidad ))
	 
		if inlist( tcEntidad, "FACTURAELECTRONICADECREDITO", "NOTADECREDITOELECTRONICADECREDITO", "NOTADEDEBITOELECTRONICADECREDITO" )
			for i = 1 to this.oColEntidades.count
				if alltrim(upper( this.oColEntidades(i).centidad )) = tcEntidad
					llEntidadEncontrada = .t.
					exit
				endif
			endfor
		
			if !llEntidadEncontrada
				this.oentidad.transformaracomprobantedecredito()
			endif
		endif
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function DebeRenumerarPorVenirDeHerEcom() as Void
		local lcEntidad as String, llRetorno as Boolean

		lcEntidad = this.oEntidad.ObtenerNombre()
		if this.oEntidad.cConTexto = "R" and inlist( lcEntidad, "COMPROBANTESECOMMERCE","FACTURA","TICKETFACTURA","FACTURAELECTRONICA","NOTADECREDITO","TICKETNOTADECREDITO",;
				 "NOTADECREDITOELECTRONICA","DEVOLUCION","PEDIDO","REMITO" ) and pemstatus( This.oEntidad, "lVieneDeEcommerce" , 5 ) and This.oEntidad.lVieneDeEcommerce
			llRetorno = .T.
		endif
		
		return llRetorno
		
	endfunc 

enddefine 


define class ExcepcionNumeroYaUsado as zooexception OF zooexception.prg
	ErrorNo = 16546
	Message = "Número de talonario ya usado"
enddefine

define class ExcepcionCodigoYaExiste as zooexception OF zooexception.prg
	ErrorNo = 2071
	Message = "El código a grabar ya existe"
enddefine


define class EntidadAuxiliar as custom 
	cContexto = ""
	cNombre = ""
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcion() as String 
		return this.cNombre
	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerNombre() as String 
		return this.cNombre
	endfunc
	*-----------------------------------------------------------------------------------------
	function VerificarContexto( tcTipos as String ) as boolean
		local llRetorno as boolean, i as Integer, lcLetra as string
		
		if empty( tcTipos )
			llRetorno = empty( this.cContexto )
		else
			tcTipos = upper( alltrim( tcTipos ) )
			llRetorno = .f.
			for i = 1 to len( tcTipos )
				lcLetra = substr( tcTipos, i, 1 )
				llRetorno = ( lcLetra $ this.cContexto ) or llRetorno
				if llRetorno
					exit
				endif
			endfor 
		endif
		
		return llRetorno
	endfunc 


enddefine
