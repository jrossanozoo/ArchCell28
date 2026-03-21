define class ManagerImpresion As Servicio of Servicio.prg

	#if .f.
		local this as ManagerImpresion of ManagerImpresion.prg
	#endif

	#define DEF_SALIDA_A_PDF "PDF"
	#define DEF_SALIDA_A_IMPRESORA "IMPRESORA"

	protected oLineasAEnviarAControladorFiscal as zoocoleccion OF zoocoleccion.prg, colVariablesDeReporte as zoocoleccion OF zoocoleccion.prg
	
	oDisenoImpresion = null
	lProcesando = .F.
	cRutaRepositorio = ""
	oEstilo = null
	oEntidadImprimir = null
	lServicioHabilitado = .t.
	cCursorDisenosAutomaticos = ""
	cCursorDisenos = ""
	protected cBaseDeDatos as String, lLockScreenFormularioActivo as Boolean, cDescripPregunta as String
	cDelimitadorInsertApertura	= ""
	cDelimitadorInsertCierre	= ""	
	lFiltroVacio = .F.
	cBaseDeDatos = ""
	Funcionalidades = null
	lLockScreenFormularioActivo = .f.
	oLineasAEnviarAControladorFiscal = null
	cDescripPregunta = ""
	lImprimeAPdf = .f.
	cDisenoSeleccionado = ""
	colDisenosAutomaticosEntidad = null
	colVariablesDeReporte = null
	lEsReporteMultihoja = .f.
	nPosicionDetalleMultihoja = 0
	cTipoAreaEtiquetaDeArticulo = "ETIQUETA DE ARTICULO"
	cDetalleEtiquetaDeArticulo = ".ETIQUETADETALLE"
	cFuncionCodigoDeBarra = "COMBINACIONPARACODBARRA"
	oComprobantes = null
	nCantidadPdfsPorCarpetaCompatibilidadHaciaAtras = 2000
	oColaboradorParametros = null
	oSeleccionDisenios = null
	nCondicionesFalsas = 0
	nItemsAImprimir = 0
	nNumeroErrorPorImprimirSinDetalle = 4010
	oColumnaNumerarPorCombinacion = null
	oColaboradorArticuloTotalizador = null
	lIncluyeArticuloTotalizador = .f.
	lEsValeDeCambio = .f.
	llHabilitaTotalizadores = .f.
	oGeneradorReportes = null	
	cImpresoraForzada = ""
	cImpresoraPredeterminada = ""
	nIndiceEtiqueta = 1
	dPrecioConVigenciaDesde = {  /  /    }
	lEsSalidaAPDF = .F.
	lDebeBorrarQR = .F.
	lEsUnTiquetDeCambio = .F.
	nUltimoNroSecuencial = 0
	nCantNrosSecuencial = 0
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		local loExcepcion as zooexception OF zooexception.prg
		*-- Si no se carga la entidad al inicializar pinchan los test por que tienen mas sesiones que las que tenian al iniciar
		dodefault()
		this.colDisenosAutomaticosEntidad = _screen.zoo.crearobjeto( "zooColeccion" )
		This.EstablecerDelimitadoresDeSentencia()
		this.cCursorDisenosAutomaticos = sys( 2015 )
		this.cCursorDisenos = sys( 2015 )
		try
			this.oDisenoImpresion = _screen.zoo.instanciarentidad( "disenoimpresion" )
		catch to loExcepcion
			this.lServicioHabilitado = .f.
			goServicios.Errores.LevantarExcepcion( loExcepcion )
		endtry

		this.cRutaRepositorio = this.ObtenerRutaRepositorio()
		this.llHabilitaTotalizadores =  goServicios.Registry.Nucleo.HabilitarArticuloTotalizador
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColaboradorParametros_Access() as Void
		if !this.ldestroy and ( !vartype( this.oColaboradorParametros ) = 'O' or isnull( this.oColaboradorParametros ) )
			this.oColaboradorParametros = _screen.zoo.crearobjeto( "ColaboradorParametros" )
		endif
		return this.oColaboradorParametros
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstablecerDelimitadoresDeSentencia() as Void
		this.cDelimitadorInsertApertura	= "["
		this.cDelimitadorInsertCierre	= "]"	
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Esta funcion se utiliza desde el formulario de desde donde se quiere imprimir
	*-----------------------------------------------------------------------------------------
	function Imprimir( toEntidad as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean, loInfo as Object 
		llRetorno = .T.
		with this
			if .lServicioHabilitado
				if .lProcesando
					llRetorno = .F.
					.AgregarInformacion( "Ya se está imprimiendo" )
				else
					.oEntidadImprimir = toEntidad
					llRetorno = .SeleccionarDisenoEImprimir()
				endif
			else
				.AgregarInformacion( "El servicio de impresión no está habilitado" )
				llRetorno = .F.
			endif
		endwith
		if llRetorno
		else
			loInfo = this.ObtenerInformacion()
			if loInfo.count > 0
				goservicios.errores.levantarexcepcion( loInfo )
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Esta funcion se utiliza desde el formulario de seleccion de diseño de impresion
	*-----------------------------------------------------------------------------------------
	function ImprimirDiseno( tnDiseno as integer, toEntidad as entidad OF entidad.prg ) as Boolean
		local lcReporte as String, llRetorno as Boolean, loEntidad as entidad OF entidad.prg, ;
				loError as zooexception OF zooexception.prg, loInfo as zooinformacion of zooInformacion.prg, ;
				lcDetalles as String, llEsUnReporteDeEtiqueta as Boolean, lcQRsHabilitados as String, ;
				lnCantDetalleTiquet as integer, lnCantArticuloTiquet as Integer, lnItemTiquet as Integer, ;
				loTiquet as Object, llForzarpredeterminada as Boolean

		

		llRetorno = .T.
		lcQRsHabilitados = ""
		store .f. to llForzarpredeterminada, llEsUnReporteDeEtiqueta
		if type( "toEntidad" ) = "O" and !isnull( toEntidad )
			loEntidad = toEntidad 
		else
			loEntidad = this.oEntidadImprimir
		    This.cDescripPregunta = this.obtenerDescripPregunta( loEntidad )
		endif

		if ( pemstatus( loEntidad,"cContexto", 5 ) and upper(alltrim( loEntidad.cContexto )) = "R" ) and !inlist( this.oDisenoImpresion.OpcionDeSalida, 2,4,5,6,7,8 )
			llForzarpredeterminada = .t.
		endif

		with this
			.lEsUnTiquetDeCambio = .F.
			if .lServicioHabilitado
				if .lProcesando
					llRetorno = .F.
					.AgregarInformacion( "Ya se está imprimiendo" )
				else
					try
						.oDisenoImpresion.Codigo = tnDiseno 

						if .oDisenoImpresion.EsUnReporteDeEtiqueta()
							llEsUnReporteDeEtiqueta = .T.
							if pemstatus( loEntidad, "lTieneImagenQRLink", 5 )
								lcQRsHabilitados = .ValidarExistenciaDeImagenQrEnDisenoImpresion()
								if !empty( lcQRsHabilitados )
									loEntidad.lTieneImagenQRLink = loEntidad.SetearAtributosVirtualesImagenQR('Imprimir_' + lcQRsHabilitados )
								endif
							endif
						endif
						
						if pemstatus( loEntidad, "lEsTiquetDeCambio", 5 ) and loEntidad.lEsTiquetDeCambio
							.lEsUnTiquetDeCambio = .T.
						endif

						.lIncluyeArticuloTotalizador = .llHabilitaTotalizadores and .oColaboradorArticuloTotalizador.HayArticuloTotalizador( loEntidad ) and !llEsUnReporteDeEtiqueta
						if .lIncluyeArticuloTotalizador
							.oColaboradorArticuloTotalizador.ModificarDetalleDelComprobante( loEntidad ) 
						endif

						lcDetalles = This.ObtenerDetallesQueSuperanCantidadItemsPorDiseno( loEntidad )
						if !empty( lcDetalles )
							llRetorno = .F.							
							.AgregarInformacion( "El reporte no se puede imprimir porque supera la cantidad de ítems indicada en el diseño de impresión ( " + alltrim(.oDisenoImpresion.Codigo) + " )" )
						else
							if .CumpleCondicionDeImpresion( loEntidad, .oDisenoImpresion.Condicion, .oDisenoImpresion.Codigo ) and .ConfirmarImpresion( DEF_SALIDA_A_IMPRESORA, loEntidad )

								llRetorno = .GenerarQREnComprobantesElectronicos( loEntidad )

								if llRetorno
									.lProcesando = .T.
									.VerificarGenerados()
									do case 
										case inList( upper( strtran( loEntidad.ObtenerNombre(), ' ', '' ) ), "IMPRESIONDEETIQUETA" ) and  inlist( this.oDisenoImpresion.OpcionDeSalida, 5 )
											for n = this.nIndiceEtiqueta to loentidad.etiquetadetalle.count
												lcReporte = .ActualizarDatos( loEntidad )
												.SalidaDiseno( lcReporte, loEntidad.ObtenerDescripcion(), .f., llForzarpredeterminada )
												this.nIndiceEtiqueta = this.nIndiceEtiqueta + 1 
											endfor
											this.nIndiceEtiqueta = 1
										
										case this.lEsUnTiquetDeCambio
											lnCantDetalleTiquet = loEntidad.ObtenerCantidadDeItemsEnDetalle()
											for lnItemTiquet = 1 to lnCantDetalleTiquet
												lnCantArticuloTiquet = loEntidad.ObtenerCantidadDeArticulosEnItem( lnItemTiquet )
												loTiquet = loEntidad.ObtenerTicketIndividual( lnItemTiquet )
												if loTiquet.lPermiteGenerarTiquetDeCambio
													lcReporte = .ActualizarDatos( loTiquet )
													for n = 1 to lnCantArticuloTiquet
														.SalidaDiseno( lcReporte, loTiquet.ObtenerDescripcion(), .f., llForzarpredeterminada )
													endfor
												endif
											endfor
										
										otherwise
											lcReporte = .ActualizarDatos( loEntidad )
											.SalidaDiseno( lcReporte, loEntidad.ObtenerDescripcion(), .f., llForzarpredeterminada )
											if this.lDebeBorrarQR
												loEntidad.BorrarArchivoQR()
												this.lDebeBorrarQR = .F.
											endif
									endcase
								endif
							endif
						endif
	
						if .lIncluyeArticuloTotalizador 
							.oColaboradorArticuloTotalizador.RestaurarDetalleDeComprobantes( loEntidad )
							.lIncluyeArticuloTotalizador = .f.
						endif

					Catch To loError
						if !this.HayErrorPorDetalleVacio( loError )
							goServicios.Errores.LevantarExcepcion( loError )
						endif
					finally
						loInfo = this.ObtenerInformacion()
						.lProcesando = .F.
						if loInfo.Count > 0
							goServicios.Errores.LevantarExcepcion( loInfo )
						endif
					endtry 
				endif
			else
				llRetorno = .F.
				.AgregarInformacion( "El servicio de impresión no está habilitado" )
			endif
			.lEsUnTiquetDeCambio = .F.
		endwith
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarQREnComprobantesElectronicos( toEntidad as Object ) as Boolean
		local llRetorno as Boolean

		llRetorno = .t.
		this.lDebeBorrarQR = .F.		
		
		if this.EsComprobanteElectronico( toEntidad ) and pemstatus( toEntidad, "ImagenRutaCodigoQR", 5) and empty( toEntidad.ImagenRutaCodigoQR )
			if !empty( toEntidad.CAE )
				llRetorno = toEntidad.SetearAtributosVirtualesImagenqr("imprimir")
			else
			    llRetorno = .f.
			endif
			
		    if llRetorno
		   		this.lDebeBorrarQR = .T.
		   	else
		    	this.AgregarInformacion( "El reporte no se puede imprimir porque no se pudo generar Código QR ( " + alltrim(this.oDisenoImpresion.Codigo) + " )" )
		    endif
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarExistenciaDeImagenQrEnDisenoImpresion() as String
		local lcQrHabilitados as String
		lcQrHabilitados = ""
		with this
			if pemstatus( .odisenoimpresion, "atributos", 5 ) and .odisenoimpresion.atributos.count > 0
				for each atributo in .oDisenoImpresion.Atributos foxobject
					lcAtributo = alltrim( upper( atributo.contenido ) )
					if "QRLINK" $ lcAtributo
						lcQrHabilitados = lcQrHabilitados + substr( lcAtributo, atc("QRLINK", lcAtributo) +6 , 1 )
					endif
				endfor
			endif
		endwith		
		return lcQrHabilitados
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oColaboradorArticuloTotalizador_Access() as Object
		if !this.lDestroy and vartype( this.oColaboradorArticuloTotalizador ) # "O"
			this.oColaboradorArticuloTotalizador = _Screen.zoo.crearobjeto( "ColaboradorArticuloTotalizador" )
		endif
		return this.oColaboradorArticuloTotalizador
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarGenerados() as Void
		local loArchivosNecesarios as zoocoleccion OF zoocoleccion.prg, lcRutaRepositorio as String, lcArchivo as string,;
		llHayQueGenerar as Boolean, llPasoCabecera as Boolean, loArea as Object, lcArchivoRpt as String,;
		ldFechaModificacion as Date, lcHoraModificacion as String, lcNombreReporte as String;
		llForzarCodigoQRContinuo as Boolean, llForzarCodigoQR as Boolean, llDebeGenerarDiseño as Boolean		
		local array laInformacionRpt(1,1)

		store .f. to llHayQueGenerar, llDebeGenerarDiseño, llPasoCabecera, llForzarCodigoQRContinuo, llForzarCodigoQR 
		lcRutaRepositorio = addbs( this.ObtenerRutaRepositorio() )
		loArchivosNecesarios = _Screen.zoo.crearobjeto( "zooColeccion" )
		lcNombreReporte = this.obtenerNombreReporte( this.oDisenoImpresion )
		lcArchivoRpt = lcRutaRepositorio + forceext( lcNombreReporte , "RPT" )
		loArchivosNecesarios.agregar( lcArchivoRpt  )

		if  vartype( goParametros.Felino ) = "O"
			llForzarCodigoQRContinuo = goparametros.felino.gestiondeventas.facturacionelectronica.ForzarLaImpresionDeCodigoQRenDisenosConCantidadDinamicaDeLineas
			llForzarCodigoQR = goparametros.felino.gestiondeventas.facturacionelectronica.ForzarLaImpresionDeCodigoQrEnDisenosConCantidadFijaDeLineas
		endif
			
		llDebeGenerarDiseño = this.ForzarCodigoQrParaComprobanteElectronicoConDiseno( llForzarCodigoQRContinuo, llForzarCodigoQR )
		
		for each loArea in this.oDisenoImpresion.Areas
			if !loArea.EsDet
				if llPasoCabecera
				else
					lArchivo = this.ObtenerTabla( loArea, this.oDisenoImpresion.Codigo )
					llPasoCabecera = .T.
				endif
			else
				lcArchivo = this.ObtenerTabla( loArea, this.oDisenoImpresion.Codigo )
			endif
			if !empty( lcArchivo )
				loArchivosNecesarios.agregar( lcRutaRepositorio + lcArchivo )
			endif
			lcArchivo = ""
		endfor

		for each lcArchivo in loArchivosNecesarios
			if file( lcArchivo )
			else
				llHayQueGenerar = .T.
				exit
			endif
		endfor

		if vartype( goRegistry.Felino ) = "O" and this.EsComprobanteElectronico( This.oEntidadImprimir )
			if goRegistry.Felino.EstadoParametroForzarQRcontinuo != llForzarCodigoQRContinuo
				goRegistry.Felino.EstadoParametroForzarQRcontinuo = llForzarCodigoQRContinuo
				llDebeGenerarDiseño =.t.
			endif

			if goRegistry.Felino.EstadoParametroForzarQRNoContinuo != llForzarCodigoQR
				goRegistry.Felino.EstadoParametroForzarQRNoContinuo = llForzarCodigoQR
				llDebeGenerarDiseño =.t.
			endif
		endif

		if llHayQueGenerar or llDebeGenerarDiseño
			this.setearimpresorapredeterminada( this.obtenerimpresorapredeterminada() )
			this.oDisenoImpresion.EsPrevisualizacion = .F.

			this.oDisenoImpresion.GenerarImpresion()
		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ForzarCodigoQrParaComprobanteElectronicoConDiseno( tlForzarCodigoQRContinuo as Boolean, tlForzarCodigoQR as Boolean ) as Boolean
		local lnPosVerticalAtributo as Number, llTieneCB as Boolean, lcNombreArea as String, lnPosicionArea as Integer, lnPosicionAreaY as Integer,;
		llRetorno as Boolean
		
		store 0 to lnPosicionArea, lnPosVerticalAtributo, lnPosicionAreaY
		store .F. to llEsContinuo, llTieneCB

		try
			if this.EsComprobanteElectronico( This.oEntidadImprimir ) and ( tlForzarCodigoQRContinuo or tlForzarCodigoQR ) and this.DebeAgregarQR()
				
				llRetorno = .t.
				
				llEsContinuo = this.odisenoimpresion.imprimecontinuo()

				lnPosVerticalAtributo = this.ObtenerPosicionVerticalAtributo( @lcNombreArea, @lnPosicionArea, llEsContinuo )

				if llEsContinuo and tlForzarCodigoQRContinuo 
					****************** Es diseño de impresión continua
					
					****** Area
					loItemAuxiliarArea = this.oDisenoImpresion.Areas.obtenerobjetoitemauxiliar()
					loItemAuxiliarArea.Area = "Qr" + sys(2015)
					loItemAuxiliarArea.Codigo = this.oDisenoImpresion.codigo
					loItemAuxiliarArea.nroitem = this.oDisenoImpresion.Areas.Count + 1
					loItemAuxiliarArea.Tipo_pk = "PIE DINAMICO"
					loItemAuxiliarArea.y = lnPosVerticalAtributo + 700
					loItemAuxiliarArea.x = 675
					this.oDisenoImpresion.Areas.add( loItemAuxiliarArea)

					****** Atributo
					loItemAuxiliarAtributo = this.oDisenoImpresion.atributos.obtenerobjetoitemauxiliar()
					loItemAuxiliarAtributo.ancho = 1600
					loItemAuxiliarAtributo.area = loItemAuxiliarArea.Area 
					loItemAuxiliarAtributo.codigo = this.oDisenoImpresion.codigo
					loItemAuxiliarAtributo.contenido = '.imagenRutaCodigoQR'
					loItemAuxiliarAtributo.nroitem = this.oDisenoImpresion.atrIBUTOS.Count + 1
					loItemAuxiliarAtributo.tipodetalle = 'IMAGEN'
					loItemAuxiliarAtributo.tipo_pk = "I"
					loItemAuxiliarAtributo.width = 100 
					this.oDisenoImpresion.atributos.add( loItemAuxiliarAtributo )
					*****

					****** Atributo
					loItemAuxiliarAtributo = this.oDisenoImpresion.atributos.obtenerobjetoitemauxiliar()
					loItemAuxiliarAtributo.ancho = 0
					loItemAuxiliarAtributo.area = loItemAuxiliarArea.Area 
					loItemAuxiliarAtributo.codigo = this.oDisenoImpresion.codigo				
					loItemAuxiliarAtributo.nroitem = this.oDisenoImpresion.atrIBUTOS.Count + 1
					loItemAuxiliarAtributo.tipo_pk = "E"
					loItemAuxiliarAtributo.tipodetalle = 'ETIQUETA'
					loItemAuxiliarAtributo.contenido = ".  "
					loItemAuxiliarAtributo.width = 100 
					loItemAuxiliarAtributo.y = 3000
					this.oDisenoImpresion.atributos.add( loItemAuxiliarAtributo )
					*****
				else
				    if tlForzarCodigoQR
						*!* Diseño NO continuo
						for each loAtributos in this.oDisenoImpresion.atributos
							if alltrim(lower(loAtributos.contenido)) = '.codigobarracae'
								llTieneCB = .T.
								
								*!* Si existe el CB lo reemplazo por el QR 
								lnPosicionAreaY = this.ObtenerPosicionYDelArea( loAtributos.Area ) 
								nPosicionDelQRAreaYAtributo = lnPosicionAreaY + loAtributos.y
							
								if nPosicionDelQRAreaYAtributo	> 15000
									loAtributos.Y = abs( 15000 - lnPosicionAreaY )
								endif
									
								loAtributos.contenido = ".imagenRutaCodigoQR"
								loAtributos.ancho  = 800
								loAtributos.Estilo_pk = ""
								loAtributos.Tipo_pk = "I"
											
								exit
							endif
						endfor

						*!* Si no tenia CB, agrego el QR despues del atributo que este mas abajo, si no hay lugar lo pongo en esa misma posicionY
						if !llTieneCB
							*!* Se calcula la posicion maxima para el atributo QR respecto al area y demas atributos
							lnPosicionAtributoMayorSinArea = lnPosVerticalAtributo - lnPosicionArea 
						
							if lnPosVerticalAtributo > 15000
								lnPosVerticalAtributo = abs( 15000 - lnPosicionArea )
							else
								if (lnPosVerticalAtributo + 56.7) > 15000
									lnPosVerticalAtributo = abs( 15000 - lnPosicionArea )
								else
									lnPosVerticalAtributo = lnPosicionAtributoMayorSinArea + 56.7
								endif
							endif

							*!* Agrego el atributo
							loItemAuxiliarAtributo = this.oDisenoImpresion.atributos.obtenerobjetoitemauxiliar()
							loItemAuxiliarAtributo.ancho = 800
							loItemAuxiliarAtributo.area = lcNombreArea
							loItemAuxiliarAtributo.codigo = this.oDisenoImpresion.codigo
							loItemAuxiliarAtributo.contenido = '.imagenRutaCodigoQR'
							loItemAuxiliarAtributo.nroitem = this.oDisenoImpresion.atrIBUTOS.Count + 1
							loItemAuxiliarAtributo.tipodetalle = 'IMAGEN'
							loItemAuxiliarAtributo.tipo_pk = "I"
							loItemAuxiliarAtributo.width = 100 
							loItemAuxiliarAtributo.y = lnPosVerticalAtributo 
							loItemAuxiliarAtributo.x = 963
							this.oDisenoImpresion.atributos.add( loItemAuxiliarAtributo )			
						endif
					endif
				endif
			endif				
			
		catch to loError
			lcMensajeError = "MANAGERIMPRESION - ForzarCodigoQrParaComprobanteElectronico " + iif(vartype( loError.uservalue ) = 'O', loError.uservalue.message,loError.message)
			loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( loError )
			loLogueador.Escribir( lcMensajeError )
			goServicios.Logueos.Guardar( loLogueador )
			loLogueador = null
		endtry

		return llRetorno

	endfunc	

	*-----------------------------------------------------------------------------------------
	function ObtenerPosicionYDelArea( tcArea as String ) as Integer
		local lnRetorno as Integer
		
		lnRetorno = 0

		for each loAreas in this.oDisenoImpresion.Areas
			if alltrim(lower(loAreas.area)) = lower( tcArea )
				lnRetorno = loAreas.Y
				exit
			endif
		endfor

		return lnRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeAgregarQR() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		for each loAtributos in this.oDisenoImpresion.atributos
			if alltrim(lower(loAtributos.contenido)) = '.imagenrutacodigoqr'
				llRetorno = .F.
				exit
			endif
		endfor
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPosicionVerticalAtributo( lcNombreArea, lnPosicionArea, tlEsContinuo ) as Number
		local lnPosVertical as Number, lnPosVerticalTotal as Number, lcCondicion as String
		store 0 to lnPosVertical, lnPosVerticalTotal
		
		if tlEsContinuo
			lcCondicion = '"PIE" $ alltrim(upper(loAreas.Tipo_PK))'
		else
			lcCondicion = 'alltrim(upper(loAreas.Tipo_PK)) = "PIE"'
		endif

		for each loAreas in this.oDisenoImpresion.Areas
			lnPosVertical = 0
			
			with this.oentidadimprimir
			if  &lcCondicion and iif(!empty(loAreas.condicion),evaluate(alltrim(loAreas.condicion)),.T.)

				for each loAtributos in this.oDisenoImpresion.atributos					
					if alltrim(lower(loAreas.area)) = alltrim(lower(loAtributos.Area)) and iif(!empty(loatributos.condicion), evaluate(alltrim(loatributos.condicion)), .T.)
						if loAtributos.Y > lnPosVertical
							lnPosVertical = loAtributos.Y
						endif
					endif
				endfor
				
				if ( loAreas.y + lnPosVertical ) > lnPosVerticalTotal
					lnPosVerticalTotal = loAreas.y + lnPosVertical
					lcNombreArea = loAreas.Area
					lnPosicionArea = loAreas.y
				endif
			endif
			endwith
			
		endfor
		
		return lnPosVerticalTotal
			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SeleccionarDiseno( toEntidad as entidad OF entidad.prg ) as string
		local lnCantidad as Integer, lcRetorno as String, loForm as form, lcForm as string, lnDiseno as Integer, llImpresionAutomatica as Boolean ,;
		loSeleccion as SeleccionDeDisenios of SeleccionDeDisenios.prg
		
		lcRetorno = ""
		llImpresionAutomatica = .f.
		lnCantidad = 1

		this.oEntidadImprimir = toEntidad

		llImpresionAutomatica = this.DebeImprimirDisenosAutomaticamente( this.oEntidadImprimir )

		if !llImpresionAutomatica
			lnCantidad = this.TieneDisenoParaImpresora( this.oEntidadImprimir )
		endif

		with this
			do case
				case lnCantidad > 1
					loSeleccion = _screen.zoo.crearobjeto( "SeleccionDeDisenios" )
					loSeleccion.setearDecoradorEspecifico( _screen.zoo.crearobjeto( "DecoradorSeleccionDisenioDeSalida" ) )
					loSeleccion.setearPobladorEspecifico( _screen.zoo.crearobjeto( "PobladorSeleccionDisenioDeImpresion" ) ) 
					loRespuesta = loSeleccion.ObtenerDisenio()
					lcRetorno = loRespuesta.cRespuesta
					this.dPrecioConVigenciaDesde = loRespuesta.dFechaVigencia
					loSeleccion.Release()
				case lnCantidad = 1
					lcRetorno = .PrimerDiseno( .f., DEF_SALIDA_A_IMPRESORA, .f. )
				otherwise
					lcRetorno = ""
					.AgregarInformacion( this.ObtenerMensajeDeFaltaDeDisenos( "impresora" ) )
			endcase
		endwith

		return lcRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SeleccionarDisenoEImprimir() as Boolean
		local lnCantidad as Integer, llRetorno as boolean, loForm as form, lcForm as string, lnDiseno as Integer, llImpresionAutomatica as Boolean
		
		llRetorno = .T.
		llImpresionAutomatica = .f.
		lnCantidad = 1
		llImpresionAutomatica = this.DebeImprimirDisenosAutomaticamente( this.oEntidadImprimir )
		
		if !llImpresionAutomatica
			lnCantidad = this.TieneDisenoParaImpresora( this.oEntidadImprimir )
		endif
		lcDisenio = this.SeleccionarDiseno( this.oEntidadImprimir )
		lnEtiquetasConPrecioVigenteAFecha = this.ObtenerDisenosEtiquetasConPrecioVigenteAFecha( lcDisenio )

		with this
			do case
				case llImpresionAutomatica
					this.dPrecioConVigenciaDesde = date()
					this.ImprimirDisenosAutomaticos( this.oEntidadImprimir )
				case lnCantidad > 1 or (lnCantidad = 1 and lnEtiquetasConPrecioVigenteAFecha > 0)
					if !empty( alltrim( lcDisenio ) )
						goServicios.Impresion.ImprimirDiseno( lcDisenio )
					endif
				case lnCantidad = 1 and lnEtiquetasConPrecioVigenteAFecha = 0
					lnDiseno = .PrimerDiseno( .f., DEF_SALIDA_A_IMPRESORA, .f. )
					llRetorno = .ImprimirDiseno( lnDiseno )
				otherwise
					llRetorno = .F.
					.AgregarInformacion( this.ObtenerMensajeDeFaltaDeDisenos( "impresora" ) )
			endcase
		endwith

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDisenosEtiquetasConPrecioVigenteAFecha( tcDiseno as string ) as Integer
		local lcCursor as String, lcBase as String, lcSql as String, lxValor as Integer, lcEsquema as string
		lxValor = 0

		lcCursor = "c_eti"
		lcBase = _screen.zoo.app.ObtenerPrefijoDB() + _screen.zoo.app.cSucursalActiva
		lcEsquema = _screen.zoo.app.cschemadefault
		 
		lcSQL = "select c1.ctipo, c1.icod from [" + lcBase + "].[" + lcEsquema + "].[DISAREAS] c1 "
		lcSQL = lcSQL + "inner join [" + lcBase + "].[" + lcEsquema + "].[DISATRIBUTOS] c2 on c1.ICOD = c2.ICOD "
		lcSQL = lcSQL + "where c1.CTIPO = 'ETIQUETA DE ARTICULO' and c2.CCONTENIDO = 'PRECIOCOMBINACIONVIGENTE' and c1.ICOD = '" + upper(alltrim(tcDiseno)) + "'"
				
		goServicios.Datos.EjecutarSentencias( lcSQL ,"","", lcCursor , This.DataSessionId )
		
		lxValor = reccount( "c_eti" ) 
		
		if used("c_eti")
			use in ( "c_eti" )
		endif
		return lxValor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HabilitarDibujoDeFormularioActivo() as Void
		if type( "_screen.ActiveForm" ) == "O" and !isnull( _screen.ActiveForm )
			this.lLockScreenFormularioActivo = _screen.ActiveForm.LockScreen
			_screen.ActiveForm.LockScreen = .f.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RestaurarDibujoDeFormularioActivo() as Void
		if type( "_screen.ActiveForm" ) == "O" and !isnull( _screen.ActiveForm )
			_screen.ActiveForm.LockScreen = this.lLockScreenFormularioActivo
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Aplicarfiltros( toEntidad as Object,  tcDisenos as String ) as Void
		local lnretorno as Integer, lcXml, lcCursor , lcRetorno 
		lnRetorno = 0
		lcXml = this.oDisenoImpresion.oAd.obtenerDatosEntidad( "codigo, Descripcion, entidad, condicion, Defaultimpresion", "codigo in (" + tcDisenos + ")", "Codigo" )
		lcRetorno = this.ObtenerDisenosSegunCondicion( toEntidad, lcxml )
		if ! empty( lcRetorno )
			lcCursor = sys(2015)
			this.XmlACursor( lcRetorno , lcCursor )
			lnRetorno = reccount( lcCursor ) 
			use in select( lcCursor )		
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneDiseno( toEntidad as entidad OF entidad.prg, tcTipoDeSalida as String ) as Integer
		local lcCursor as String, lcXml as String, lnRetorno as Integer

		lcCursor = sys( 2015 )
		lnRetorno = 0
	
		if pemstatus( this,"oEntidadImprimir",5 ) and isnull(this.oEntidadImprimir)
			this.oEntidadImprimir = toEntidad
		endif
		
		if this.lServicioHabilitado
			lcDisenos = this.ObtenerDisenosDeUnaEntidad( toEntidad.obtenernombre(), tcTipoDeSalida, .f. )
			if !empty( lcDisenos )
				lnRetorno = this.aplicarfiltros( toEntidad, lcdisenos )	
			endif 
		endif

		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneDisenoParaImpresora( toEntidad as entidad OF entidad.prg ) as Integer
		return this.TieneDiseno( toEntidad, DEF_SALIDA_A_IMPRESORA )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneDisenoParaPDF( toEntidad as entidad OF entidad.prg ) as Integer
		return this.TieneDiseno( toEntidad, DEF_SALIDA_A_PDF )
	endfunc

	*-----------------------------------------------------------------------------------------
	function PrimerDiseno( toEntidad as entidad OF entidad.prg, tcTipoSalidaImpresion as String, tlGeneracionAutomatica as Boolean ) as Integer
		local lcCursor as String, lcXml as String, lnRetorno as Integer

		if type( "toEntidad" ) = "O"
		else
			toEntidad = null
		endif

		lcCursor = sys( 2015 )
		lnRetorno = 0

		with this
			lcXml = .ObtenerDisenoDeEntidad( toEntidad, tcTipoSalidaImpresion, tlGeneracionAutomatica )
			.xmlACursor( lcXml, lcCursor )

			select ( lcCursor )
			go top

			lnRetorno = &lcCursor..Codigo
			use in select( lcCursor )
		endwith		

		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDisenoDeEntidad( toEntidad as entidad OF entidad.prg, tcTipoSalidaDeImpresion as String, tlGeneracionAutomatica as Boolean ) as string
		local lcRetorno as String, lcNombre as String, loEntidad as entidad OF entidad.prg, lcCodigos as String

		lcRetorno = ""

		if this.lServicioHabilitado
			lcNombre = ""
			loEntidad = null
			if type( "toEntidad" ) = "O" and !isnull( toEntidad )
				lcNombre = alltrim( upper( toEntidad.obtenerNombre() ) )
				loEntidad = toEntidad
			else
				if type( "this.oEntidadImprimir" ) = "O" and !isnull( this.oEntidadImprimir )
					lcNombre = alltrim( upper( this.oEntidadImprimir.obtenerNombre() ) )
					loEntidad = this.oEntidadImprimir
				endif
			endif

			if empty( lcNombre )
				lcRetorno = this.oDisenoImpresion.oAd.obtenerDatosEntidad( "codigo, Descripcion, entidad, Defaultimpresion", "", "Descripcion" )
			else
				lcCodigos = this.ObtenerDisenosDeUnaEntidad( lcNombre, tcTipoSalidaDeImpresion, tlGeneracionAutomatica )
				lcRetorno = this.oDisenoImpresion.oAd.obtenerDatosEntidad( "codigo, Descripcion, entidad, condicion, Defaultimpresion", "codigo in (" + lcCodigos + ")", "Descripcion" )
				if !empty( lcRetorno )
					lcRetorno = this.ObtenerDisenosSegunCondicion( loEntidad, lcRetorno )
				endif

			endif
			if this.TieneModuloEtiquetaHabilitado()	
			else
				lcRetorno = this.FiltrarEtiquetas( lcRetorno )
			endif 
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneModuloEtiquetaHabilitado() as Boolean 
		local llRetorno as Boolean, lTieneModuloEtiqueta as Boolean  
		llRetorno = .t.
		lTieneModuloEtiqueta = goServicios.Modulos.ExisteModuloSegunAlias( "ETIQUETA" )
		if lTieneModuloEtiqueta 
			llRetorno = goServicios.Modulos.TieneModuloHabilitadoSegunAlias( "ETIQUETA" )
		endif 
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnReporteDeEtiquetas( tcCodigo as String ) as Boolean 
		this.oDisenoImpresion.codigo = tcCodigo
		return this.oDisenoImpresion.EsUnReporteDeEtiqueta()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FiltrarEtiquetas( tcXmlReportes as string ) as String 
		local lcCursor as String, lcRetorno as String 
		lcCursor = sys( 2015 )

		this.XmlaCursor(tcXmlReportes, lcCursor )
		select * from (lcCursor) where .f. into cursor c_CursorFiltrado readwrite
		with this.oDisenoImpresion
			select (lcCursor)
			scan
				.codigo = &lcCursor..Codigo
				if !.EsUnReporteDeEtiqueta()
					scatter memvar 
					select c_CursorFiltrado
					append blank
					gather memvar 
				endif
				select (lcCursor)
			endscan 
		endwith		
		lcRetorno = this.cursoraxml( "c_CursorFiltrado" )
		use in select( lcCursor )
		use in select( "c_CursorFiltrado" )
		return lcRetorno 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDatos( toEntidad as entidad OF entidad.prg ) as string
		local lcRetorno as String, lcRutaTrabajo as String, loAreas as Object, llPasoCabecera as Boolean
		llPasoCabecera = .F.
		with this			
			lcRutaTrabajo = _screen.Zoo.ObtenerRutaTemporal()
			.CopiarTablasDesdeRepositorio( lcRutaTrabajo )

			*!* De todas las areas que no son detalle proceso la primera que encuentro, las demas las salteo
			*!* Porque hay una sola tabla para todo lo que no sea detalle
			for each loArea in .oDisenoImpresion.Areas
				if !loArea.EsDet 
					if llPasoCabecera
					else
						.ActualizarDatosArea( loArea, lcRutaTrabajo, toEntidad )
						llPasoCabecera = .T.
					endif
				else
					.ActualizarDatosArea( loArea, lcRutaTrabajo, toEntidad )
				endif
			endfor
			.ActualizarDatosTotalizadores( loArea, lcRutaTrabajo, toEntidad )
	
			lcRetorno = .ActualizarYCopiarReporte( lcRutaTrabajo, toEntidad )
			lcRetorno = lcRutaTrabajo + lcRetorno
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarDatosTotalizadores( toArea as Object, tcRutaTrabajo as String, toEntidad as entidad OF entidad.prg ) as Void
		local loDatos as Object, loColTotalizadores, lcTabla, loItem,loItemValor, lcValor, lcdetalle, lcCampo, lcCondicion, lcCadenaDeCampos as String 
 
		lcCadenaDeCampos = ""
		loColTotalizadores = this.oDisenoImpresion.obteneratributostotalizadores()
		if loColTotalizadores.count > 0
			loDatos = newobject( "datosArea" )
			lodatos.cTabla = strtran(alltrim(this.oDisenoImpresion.codigo)," ","_")+ "totaliza.dbf"
			lodatos.cRutaTabla = tcRutaTrabajo 	

			for each loItem in loColTotalizadores foxobject 
				lcDetalle =alltrim( getwordnum( loItem.Contenido,1,"," ))
				lcTabla = addbs( tcRutaTrabajo )+ strtran(alltrim(this.oDisenoImpresion.codigo)," ","_")+ "_" +lcDetalle+".dbf"
				lcCampo = "c_"+alltrim(transform(getwordnum( loItem.Contenido,2,"," )))
				lcCadenaDeCampos = lcCadenaDeCampos +"ct_"+alltrim(transform(loItem.Nro)) + ","
				lcCondicion = alltrim( loItem.Funcion )+"(val(strt( "+lcCampo+" ,',',''))) as total "
				select &lcCondicion from &lcTabla into cursor c_totaliza
				lcValor = transform(c_totaliza.total)
				loItemValor = _screen.Zoo.crearObjeto( "ItemValores", "managerImpresion.prg" )
				loItemValor.cValor = "'"+lcValor + "'" 
				loDatos.oValores.agregar( loItemValor )
				loDatos.oAtributos.agregar( this.oDisenoImpresion.Atributos.item[loItem.Nro] )
				use in select("c_totaliza")
				use in select( juststem( lcTabla ))
			endfor
			lodatos.cCampos = left(lcCadenaDeCampos , len(lcCadenaDeCampos )-1)
			lodatos.ejecutar()
		endif	

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearTablas( toReporte as Object, tcRutaTrabajo as String ) as Void
		local loItem as Object, i as Integer, lcArchivo as string, lcDataSource as String
		with this
			for i = 1 to toreporte.Database.Tables.Count
				loItem = toreporte.Database.Tables.Item[ i ]
				lcDataSource = justfname( loItem.ConnectionProperties.Item("Data Source").value )
				loItem.ConnectionProperties.Item("Data Source").value = addbs( tcRutaTrabajo ) + lcDataSource
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarDatosArea( toArea as Object, tcRutaTrabajo as String, toEntidad as entidad OF entidad.prg ) as Void
		local loDatos as Object, loError as Object, loExcepcion as zooexception OF zooexception.prg, lcSetCenturyAnterior as String, lcCentury as String

		loDatos = newobject( "datosArea" )
		loDatos.cDelimitadorInsertCierre = this.cDelimitadorInsertCierre
		loDatos.cTabla = this.ObtenerTabla( toArea, this.oDisenoImpresion.Codigo )
		loDatos.cRutaTabla = tcRutaTrabajo
		loDatos.cTipoArea = upper( alltrim( toArea.tipo_pk ))
		loDatos.cCondicion = upper( alltrim( toArea.Condicion ))
		this.SetearAtributosArea( toArea, loDatos )
		this.SetearCamposInsert( loDatos )
		if loDatos.cTipoArea = this.cTipoAreaEtiquetaDeArticulo
			if toEntidad.cNombre = "IMPRESIONDEETIQUETA"
				goServicios.Impresion.cDetalleEtiquetaDeArticulo = ".ETIQUETADETALLE"
			else
				if pemstatus( toEntidad,"cDetalleComprobante",5 )
					goServicios.Impresion.cDetalleEtiquetaDeArticulo = "." + alltrim( upper( toEntidad.cDetalleComprobante ) )
				else
					this.AgregarInformacion( chr( 9 ) + "La entidad " + alltrim( toEntidad.cDescripcion) + " no posee un detalle que pueda ser utilizado para imprimir etiquetas." )
				endif 
			endif
		endif

		lcSetCenturyAnterior = set( "Century" )
		lcCentury = "set century " + iif( goParametros.Dibujante.FormatoParaFecha = 2, "on", "off" )
		&lcCentury		
		try
			if toArea.EsDet
				try
					if inList( upper( strtran( toEntidad.ObtenerNombre(), ' ', '' ) ), "IMPRESIONDEETIQUETA" ) and  inlist( this.oDisenoImpresion.OpcionDeSalida, 5 )
					&& Estos metodos estan clonados para mejorar la perfonmance de tiempo de impresion de etiquetas
						this.SetearValoresInsertDetEtiquetas( loDatos, toEntidad )
					else
						this.SetearValoresInsertDet( loDatos, toEntidad )
					endif
				catch to loError
					this.AgregarInformacion( "Se detectó un error en el diseño de impresión." )
					goServicios.Errores.LevantarExcepcion( this.ObtenerInformacion() )			
				endtry
			else
				this.SetearValoresInsert( loDatos, toEntidad )			
			endif
		catch to loExcepcion
			goServicios.Errores.LevantarExcepcion( loExcepcion )
		finally
			set century &lcSetCenturyAnterior
		endtry

		loDatos.ejecutar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearValoresInsert( toDatos as Object, toEntidad as entidad OF entidad.prg ) as Void
		local lcValores as String, lcAtributo as String, llError as Boolean, lni as Integer, loItemValor as Object, lcmascara , lcaux 
		lcaux = ""
		lcValores = ""
		lcAtributo = ""
		llError = .F. 
		for lni = 1 to toDatos.oAtributos.Count
			lcAtributo = alltrim( toDatos.oAtributos( lni ).Contenido )
			 lcMascara = iif( toDatos.oAtributos( lni ).FuncionAgrupar = 2, "", alltrim( toDatos.oAtributos( lni ).Mascara ) ) 
			with toEntidad
				if  toDatos.oAtributos( lni ).tipo_pk = "F"
					lcAtributo = this.ObtenerAtributoConFuncionalidad( toDatos.oAtributos( lni ).contenido, toDatos.oAtributos( lni ), toEntidad, alltrim( toDatos.oAtributos( lni ).Mascara ) )
					lcAtributo = strtran( lcAtributo, "]", "] + chr( 93 ) + [" )
					lcAtributo = strtran( strtran( lcAtributo, "$#", "" ), "#$", "" )
					lcAtributo = strtran( strtran( lcAtributo, "%#", "" ), "#%", "" )			
					lcValores = lcValores + this.cDelimitadorInsertApertura + lcAtributo + this.cDelimitadorInsertCierre + "<!> "
				else
					try
						lxAtributo = &lcAtributo.
						if vartype( &lcAtributo. ) = "U"
							this.agregarInformacion( "El atributo " + iif( left( lcAtributo , 1 ) == ".", substr( lcAtributo, 2 ), lcAtributo ) + " no existe." )
							llError = .T.
						else
							lcAtributo = transform( &lcAtributo., alltrim( toDatos.oAtributos( lni ).Mascara ) )					
							lcAtributo = strtran( lcAtributo, "]", "] + chr( 93 ) + [" )
							loCodBarra = this.EsCodigoDeBarra( toDatos.oAtributos( lni ) )
							lcDelimitador = iif( loCodBarra.lUsaCB ,alltrim( loCodBarra.cDelimitador ), "" )
							
							if loCodBarra.lUsaCB
								 lcaux = strtran( this.ConfigurarCadena( alltrim( transform( lcAtributo, lcMascara ) )) , "]", "] + chr( 93 ) + [" ) 
							else
	                             lcaux =  lcAtributo 
	                        endif                                       
							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + ;
										lcaux + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
						endif
					catch
						if ".CompAfec" $ lcAtributo  		
							this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
						else
							this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
						endif
						
						llError = .T.
					endtry
				endif
			endwith
		endfor

		if llError
			this.AgregarInformacion( "Error en el diseño de impresión." )
			goServicios.Errores.levantarExcepcion( this.ObtenerInformacion() )
		endif

		lcValores = alltrim( lcValores )
		lcValores = substr( lcValores, 1, len( lcValores ) - 3 )
		loItemValor = _screen.Zoo.crearObjeto( "ItemValores", "managerImpresion.prg" )
		loItemValor.cValor = lcValores
		loItemValor.cDelimitadorInsertCierre = this.cDelimitadorInsertCierre
		toDatos.oValores.agregar( loItemValor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoConFuncionalidad( tcFuncionalidad as String, toItem as Object, toEntidad as Entidad of Entidad.prg, tcMascara as String ) as string
		local lcRetorno as String , lcCadena as String, loError as Exception  
		lcRetorno = ""

		try
			This.Funcionalidades.cMascara = tcMascara
			lcCadena = "This.Funcionalidades." + This.ObtenerNombreFuncion( alltrim( tcFuncionalidad ) ) + ;
				"( " + this.ObtenerParametro( tcFuncionalidad ) + " )"
			
			if occurs('PRECIOCOMBINACIONVIGENTE',lcCadena) > 0
				if pemstatus(this,"dPrecioConVigenciaDesde",5) and !isnull(this.dPrecioConVigenciaDesde )
					toItem.AddProperty("FechaVigencia",iif(this.dPrecioConVigenciaDesde != { / / },this.dPrecioConVigenciaDesde,date()))
				else
					toItem.AddProperty("FechaVigencia",date())
				endif
			endif
			with toEntidad
				lcRetorno = &lcCadena
			endwith
		catch to loError
			this.AgregarInformacion( "Error en el diseño de impresión." )
			goServicios.Errores.LevantarExcepcion( this.ObtenerInformacion() )
		endtry		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFuncionesPersonalizadas()as String
		return This.Funcionalidades.ObtenerFuncionesPersonalizadas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsFuncionConParametros( tcFuncion as String ) as Void
		local lnCantidad as Integer, llRetorno as Boolean, i as Integer

		llRetorno = .f.
		lnCantidad =alines( laLista, This.ObtenerFuncionesPersonalizadas(), ";" )
		for i = 1 to lnCantidad
			if upper( alltrim( tcFuncion ) ) = laLista[i]
				llRetorno = .t.
				exit
			endif
		endfor

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerParametro( tcFuncionalidad ) as string 
		local lcRetorno as String 
		lcRetorno = ""
		if This.EsFuncionConParametros( upper( alltrim( This.ObtenerNombreFuncion( tcFuncionalidad ) ) ) )
			lcRetorno = "toItem"
			if "(" $ tcFuncionalidad
				lcRetorno = lcRetorno + alltrim( This.AgregarParametrosPersonalizados( tcFuncionalidad ) )
			endif
		endif	
		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarParametrosPersonalizados( tcFuncionalidad ) as String
		local lcCadenaDeParametros as String 
			lcCadenaDeParametros = strtran( substr( tcFuncionalidad, at( "(", tcFuncionalidad ) + 1 ), ")" )
			if empty( lcCadenaDeParametros )
			else
				lcCadenaDeParametros = ", " + alltrim( lcCadenaDeParametros )
			endif

		return lcCadenaDeParametros
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreFuncion( tcFuncionalidad as String )	as string
		local lcFuncion as String 	

		lcFuncionalidad = tcFuncionalidad
		
		if "(" $ lcFuncionalidad
			lcFuncionalidad = left( lcFuncionalidad, at( "(" , lcFuncionalidad ) - 1 )
		endif
		return lcFuncionalidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsItemFuncionEtiquetaDeArticulo( tcContenido as String ) as Boolean
		return this.cDetalleEtiquetaDeArticulo $ upper( tcContenido ) and "(" $ upper( tcContenido ) and ")" $ upper( tcContenido )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AnalizarContenidoAtributos( lcContenidoAtributos as String ) as String	
		local loAnalizador as AnalizadorDeExpresiones as AnalizadorDeExpresiones.prg, loItemsAReemplazar as Collection, lcDetalleAtributos as String
		
		loAnalizador = newobject( "AnalizadorDeExpresiones", "AnalizadorDeExpresiones.prg" )
		loAnalizador.Texto = lcContenidoAtributos
		loItemsAReemplazar = loAnalizador.ObtenerConjuntoDeBloquesDeLosTipos( "A" )
		
		lcDetalleAtributos = iif(loItemsAReemplazar.count = 0, lcContenidoAtributos, loItemsAReemplazar( 1 ).texto )
		
		return lcDetalleAtributos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearValoresInsertDet( toDatos as Object, toEntidad as entidad OF entidad.prg ) as Void
		local lcDetalle as String, loDetalle as Object, llEsAreaEtiqueta as Boolean , ;
		 lcValores as String, lcAtributo as String, llError as Boolean, lni as Integer, lnj as Integer, llAtributoFuncional, ;
		  lnCantidad as Integer, lnP as Integer , llEsAtributoDelDetalle as Boolean, loCodBarra as Object, lcDelimitador as String ,;
		  lnA as Integer , lcAtrib as String , lcAux as String, lnCantidadAtributos as Integer, lcAuxUsaCB As String, loItemValor as Object, ;
		  llEsItemFuncEtiqueta as Boolean, lcContenido as String, lcValor as String, lcAtributoSinFunciones as String, ;
		  llExisteMensaje as Boolean, llEsCodBarAltSecuencial as Boolean, lcLongitudCampo as string, lnLongitudCampo as integer, ;
		  lcBusca as String, lcAuxConCheck as String, llUsaCodBarAlt as Boolean

		llError = .F.
		lcAuxUsaCB = ""
		llExisteMensaje = .f.
		lcDetalle = this.ObtenerDetalleDelArea( toDatos, toEntidad )
		llError = this.hayInformacion()
		store .F. to llEsCodBarAltSecuencial, llUsaCodBarAlt
		store "" to lcLongitudCampo, lcBusca, lcAuxConCheck
		lnLongitudCampo = 0
		if !llError and !empty( lcDetalle )
			with toEntidad
				loDetalle = &lcDetalle.
			endwith
			llEsAreaEtiqueta = ( todatos.cTipoArea = this.cTipoAreaEtiquetaDeArticulo )
			this.nItemsAImprimir = 0
			this.oColumnaNumerarPorCombinacion = _screen.zoo.crearobjeto("ZooColeccion")
			
			this.nCantNrosSecuencial = 0
			this.nUltimoNroSecuencial = 0
			
			for lnj = 1 to loDetalle.Count		
				if empty( toDatos.cCondicion ) or ( !empty( toDatos.cCondicion ) and this.CondicionVerdadera( toDatos.cCondicion , lnJ, loDetalle, .t. ) )				
					lcValores = ""
					lnCantidad = 1
					this.nCondicionesFalsas = 0
					this.oColumnaNumerarPorCombinacion.remove(-1)
					for lni = 1 to toDatos.oAtributos.Count
						lcValor = ""

						lcContenido = toDatos.oAtributos[ lni ].contenido 
						
						if "IIF" $ upper(lcContenido)
							with toEntidad
								lcContenido = &lcContenido
							endwith
						endif
                        lcAtributoSinFunciones = this.analizarcontenidoatributos( lcContenido )

						loCodBarra = this.EsCodigoDeBarra( toDatos.oAtributos( lni ) )
						llEsAtributoDelDetalle =  getwordcount( alltrim( lcAtributoSinFunciones ), '.' ) > 1  and ( upper(alltrim( strtran( lcdetalle,".",""))) = upper(getwordnum( alltrim( lcAtributoSinFunciones ),1,".")))
						lcAtributo = this.ObtenerAtributo( llEsAtributoDelDetalle , alltrim( lcAtributoSinFunciones) )
						llEsItemFuncEtiqueta = this.EsItemFuncionEtiquetaDeArticulo( lcContenido )
						llEsAtributoDelDetalle = llEsAtributoDelDetalle or llEsItemFuncEtiqueta
						lcDelimitador = iif( loCodBarra.lUsaCB ,alltrim( loCodBarra.cDelimitador ), "" )
						lcMascara = iif( toDatos.oAtributos( lni ).FuncionAgrupar = 2, "", alltrim( toDatos.oAtributos( lni ).Mascara ) )
						llAtributoFuncional = ( toDatos.oAtributos( lni ).tipo_pk = "F" )
						llIntermec	= ( this.oDisenoImpresion.OpcionDeSalida = 5 and this.oDisenoImpresion.EsUnReporteDeEtiqueta() )
						llNumerarPorCombinacion = (llAtributoFuncional or llIntermec) and "NUMERARCOMBINACION" $ upper(lcContenido)

						if "COMBINACIONPARACODBARRACONSECUENCIAL" $ upper( lcContenido )
							llEsCodBarAltSecuencial = .T.
						endif
						if llAtributoFuncional
							if !llNumerarPorCombinacion
								lcAtributo = this.ObtenerAtributoConFuncionalidad( lcContenido  , loDetalle.Item( lnj ), toEntidad, lcMascara )
								if this.oDisenoImpresion.EsUnReporteDeEtiqueta()
									lcAux = ""
									lnCantidadAtributos = getwordcount( lcAtributo, ";" )
									
									for lnA = 1 to lnCantidadAtributos 
										lcAtrib = alltrim( getwordnum( lcAtributo, lnA, ";" ))
										if occurs( "#$", lcAtrib ) > 0 && Es Codigo de barra formato Lince
											llExisteMensaje = .f.
											lcAux2 = alltrim( strtran( lcAtrib, "#$", "" ) )
											try
												lxAtrib = loDetalle( lnj ).&lcAux2.
												lxAtrib = alltrim(lxAtrib)
												if vartype( loDetalle( lnj ).&lcAux2. ) = "U"
													this.agregarInformacion( "El atributo " + lcAux2 + " no existe." )
													llError = .T.
												else
													do case
														case lower(lcAux2) = 'articulo_pk'
															if len( alltrim(lxAtrib) ) > 13 or empty(lxAtrib)
																llError = .T.
																llExisteMensaje = .T.
															else
																lcAux = lxAtrib
															endif
														case lower(lcAux2) = 'color_pk' and !empty(lxAtrib)
															if len( alltrim(lxAtrib) ) > 2
																llError = .T.
																llExisteMensaje = .T.
															else
																lcAux = lcAux + "%" + lxAtrib
															endif
														case lower(lcAux2) = 'talle_pk' and !empty(lxAtrib)
															if len( alltrim(lxAtrib) ) > 3
																llError = .T.
																llExisteMensaje = .T.
															else
																if occurs( "%", lcAux ) > 0
																	lcAux = lcAux + lxAtrib
																else
																	lcAux = lcAux + "$" + lxAtrib
																endif
															endif
														endcase
														if llExisteMensaje
														llExisteMensaje = .f.
														for each loMensaje in this.oInformacion
															if alltrim( loMensaje.cmensaje ) = "La longuitud del atributo " + lxAtrib + " no es válida."
																llExisteMensaje = .t.
															endif
														endfor
														if llExisteMensaje
														else
															this.agregarInformacion( "La longuitud del atributo " + lxAtrib + " no es válida." )
														endif
													endif
													
												endif
											catch
												if ".CompAfec" $ lcAtributo  		
													this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
												else
													this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAux2 )
												endif
												llError = .T.
											endtry
										else
											if occurs( "#%", lcAtrib ) > 0
												lcAux = lcAux + lcDelimitador + alltrim( strtran( lcAtrib, "#%", "" ) )
											else
												try
													* Si es el atributo secuencial, le debo sacar el tamaño y guardarmelo
													if llEsCodBarAltSecuencial and "SECUENCIAL" $ lcAtrib 
														lcLongitudCampo = substr( lcAtrib,atc("(",lcAtrib), len(lcAtrib))
														lcAtrib = strtran(  lcAtrib, lcLongitudCampo, "" )
														lcLongitudCampo = strtran( lcLongitudCampo, "((", "" )
														lnLongitudCampo = int( val( strtran( lcLongitudCampo, "))", "" ) ) )
													endif
													lxAtrib = loDetalle( lnj ).&lcAtrib.
													if vartype( loDetalle( lnj ).&lcAtrib. ) = "U"
														this.agregarInformacion( "El atributo " + lcAtrib + " no existe." )
														llError = .T.
													else
														lcAux = lcAux + iif( lnA = 1, lcDelimitador, alltrim( goregistry.dibujante.CaracterSeparadorDeAtributosDeCombinacionParaImpresionDeCodigoDeBarras ) ) + strtran( alltrim( transform( loDetalle( lnj ).&lcAtrib., alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
													endif
												catch
													if ".CompAfec" $ lcAtributo  		
														this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
													else
														this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtrib )
													endif	
													llError = .T.
												endtry
											endif
										endif
									endfor
									if occurs( "#$", lcAtrib ) > 0
										lcAuxUsaCB = "*" + lcAux + "*"
									else
										if llEsCodBarAltSecuencial 
											lcAux = lcAux + lcDelimitador 
											
											if loCodBarra.lUsaCB
												lcAuxUsaCB = "*" + lcAux + "*"
												llUsaCodBarAlt = .t.
											else
												*llUsaCodBarAlt = .f.
												lcAuxUsaCB = alltrim( lcAux )
											endif
										else
											lcAux = lcAux + lcDelimitador 
											lcAuxUsaCB = iif( loCodBarra.lUsaCB ,this.ConfigurarCadena( lcAux ), alltrim( lcAux ) )
										endif
									endif
									
									if inlist( asc( substr( lcAuxUsaCB, len( lcAuxUsaCB ) - 01, 01 ) ), 91, 93) and this.cDelimitadorInsertApertura == "["
										this.cDelimitadorInsertApertura = "'"
										this.cDelimitadorInsertCierre = "'"
									endif
								
									lcValor = lcAuxUsaCB
									lcValores = lcValores + this.cDelimitadorInsertApertura + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .t. ) + this.cDelimitadorInsertCierre + "<!> "
									This.EstablecerDelimitadoresDeSentencia()
									
								else
									lcAtributo = strtran(lcAtributo,"#%","") 
									lcValor = strtran( alltrim( transform( lcAtributo, alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
		 							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .t. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
								endif
							else
	 							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + lcContenido + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
								this.oColumnaNumerarPorCombinacion.Agregar(lni)
							endif 
						else 
							if llIntermec
								loDetalle.CargarItem( lnJ )
								toItem = loDetalle.oItem
								try
									lcAtributo = alltrim( lcContenido )
									if llNumerarPorCombinacion
										this.oColumnaNumerarPorCombinacion.Agregar(lni)
									else
										lcAtributo = this.ObtenerValorEnExpresionIntermec( lcAtributo, toEntidad , toItem )
									endif
									
									lcValor = strtran( alltrim( transform( lcAtributo, alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
									lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .f. ) + ;
									            lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
									
									if occurs( "#$", lcAtributo ) > 0 && Es Codigo de barra formato Lince, contiene error
										llError = .T.
										lcMensaje = substr( lcAtributo,at("#$",lcAtributo)+2, at("#$",lcAtributo,2) - at("#$",lcAtributo)-2)
										llExisteMensaje = .f.
										for each loMensaje in this.oInformacion
											if alltrim( loMensaje.cmensaje ) = "La longuitud del los siguientes atributos no es válida: " + lcMensaje
												llExisteMensaje = .t.
											endif
										endfor
										if llExisteMensaje
										else
											this.agregarInformacion( "La longuitud del los siguiente atributos no es válida: " + lcMensaje )
										endif
									endif
								catch
									if ".CompAfec" $ lcAtributo  		
										this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
									else
										this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
									endif
									llError = .T.
								endtry
							else
								if llEsAtributoDelDetalle
									if llEsItemFuncEtiqueta
										try
											*!* En esta instancia tengo algo del estilo Funcion( .ETIQUETADETALLE.ATRIBUTO, parametro, etc ) 
											loDetalle.CargarItem( lnJ )
											lcAtributo = strtran( lcContenido, this.cDetalleEtiquetaDeArticulo, "" )
											with loDetalle.oItem
												lcValor = strtran( alltrim( transform( &lcAtributo, lcMascara ) ) , "]", "] + chr( 93 ) + [" )
												lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .t. ) + ;
															lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
											endwith
										catch
											if ".CompAfec" $ lcAtributo  			
												this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
											else
												this.agregarInformacion( "El contenido de la expresión no es válido: " + lcContenido )
											endif
											llError = .T.
										endtry
									Else
										if occurs(".", lcAtributo) > 0
											try											
												lxAtrib = loDetalle.oItem.&lcAtributo.
												if vartype( loDetalle.oItem.&lcAtributo. ) = "U"
													this.agregarInformacion( "El atributo " + lcAtributo + " no existe." )
													llError = .T.
												else
													loDetalle.CargarItem( lnJ )
													lcAtributo = strtran( lcCOntenido, lcDetalle, "",-1,-1,1)
													
													with loDetalle.oItem
														lcValor = iif( loCodBarra.lUsaCB, strtran( this.ConfigurarCadena( alltrim( transform( &lcAtributo ) ) ), "]", "] + chr( 93 ) + [" ) , ;
																	strtran( alltrim( transform( &lcAtributo, lcMascara ) ) , "]", "] + chr( 93 ) + [" ) )
														lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + ;
																	this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .f. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
													endwith
												endif
											catch
												if ".CompAfec" $ lcAtributo  	 	
													this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
												else
													this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
												endif
												llError = .T.
											endtry
										else
											try
												loDetalle.CargarItem( lnJ )

												if vartype( loDetalle( lnj ).&lcAtributo. ) = "U"
													this.agregarInformacion( "El atributo " + lcAtributo + " no existe." )
													llError = .T.
												else

												lcAtributo = strtran( lcCOntenido, lcDetalle, "",-1,-1,1)

													with loDetalle.oItem

														if loCodBarra.lUsaCB
															lcValor = strtran( this.ConfigurarCadena( alltrim( transform( &lcAtributo ) ) ), "]", "] + chr( 93 ) + [" )
														else 
															lcValor = strtran( alltrim( transform( &lcAtributo, lcMascara ) ), "]", "] + chr( 93 ) + [" )
														endif	

														lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + ;
																	this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .t. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
													endwith
												endif
											catch
												if ".CompAfec" $ lcAtributo  		
													this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
												else
													this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
												endif												
												llError = .T.
											endtry
										endif
									Endif	
								else
									with toEntidad
										try
											lxAtrib = &lcAtributo.
											if vartype( &lcAtributo. ) = "U"
												this.agregarInformacion( "El atributo " + iif( left( lcAtributo , 1 ) == ".", substr( lcAtributo, 2 ), lcAtributo ) + " no existe." )
												llError = .T.
											else
												lcValor = strtran( alltrim( transform( &lcAtributo., alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
												lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, lnJ, lnI, .t. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
											endif
										catch
											if ".CompAfec" $ lcAtributo  	
												this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
											else
												this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
											endif
											llError = .T.
										endtry
									endwith
								endif
							endif 
						endif	
					endfor	
				else
					this.nCondicionesFalsas = toDatos.oAtributos.Count			
				endif

				if this.nCondicionesFalsas < toDatos.oAtributos.Count && muestra al menos un atributo del item
					this.nItemsAImprimir = this.nItemsAImprimir + 1
					lnCantidad = 1
					if llEsAreaEtiqueta and pemstatus( loDetalle.item( lnj ), "Cantidad", 5 )
						lnCantidad = loDetalle( lnj ).Cantidad
					endif
					
					if llIntermec
						if  llEsCodBarAltSecuencial
							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + "1" + lcDelimitador +;
									    this.cDelimitadorInsertCierre + "<!> "
						else
							if this.oColumnaNumerarPorCombinacion.Count = 0
								lnCantidad = 1 && Optimiza si es impresion directa a puerto con etiquetas con una sola columna de impresion
							else
								lnCantidad = ceiling( loDetalle(lnj).Cantidad/ max(1,this.oDisenoImpresion.Columnas) ) 
							endif
							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador ;
										+ alltrim( transform( ceiling( loDetalle(lnj).Cantidad/max(1,this.oDisenoImpresion.Columnas) ) ) );
										+ lcDelimitador + this.cDelimitadorInsertCierre;
										+ "<!> "
						endif
					endif
					lcValores = alltrim( lcValores )
					lcValores = substr( lcValores, 1, len( lcValores ) - 3 )

					for lnP = 1 to lnCantidad
						lcLinea = lcValores
						*!* Si hay que calcular NUMERARCOMBINACION
						for each lnIndiceX in this.oColumnaNumerarPorCombinacion
							lcDelimitador = "<!> "
							lnInferior = iif( lnIndiceX > 1, at( lcDelimitador, lcLinea, lnIndiceX-1 ) + len(lcDelimitador) - 1, 1 )
							lnSuperior = at( lcDelimitador, lcLinea, lnIndiceX )
							lnSuperior = iif( lnSuperior=0, len(lcLinea)+1, lnSuperior )
							lcFuncion = chrtran( substr( lcLinea, lnInferior, lnSuperior-lnInferior ), this.cDelimitadorInsertApertura+this.cDelimitadorInsertCierre, "" )
							if llIntermec 
								lcAtributo = this.ObtenerValorEnExpresionIntermec( lcFuncion , toEntidad , loDetalle.Item( lnj ) )
							else
								lcAtributo = this.ObtenerAtributoConFuncionalidad( lcFuncion , loDetalle.Item( lnj ), toEntidad, lcMascara )
							endif
							lcLinea = iif(lnInferior>1,substr(lcLinea,1,lnInferior),"") + this.cDelimitadorInsertApertura + lcAtributo + this.cDelimitadorInsertCierre + substr(lcLinea,lnSuperior)
						endfor
						loItemValor = _screen.Zoo.crearObjeto( "ItemValores", "managerImpresion.prg" )

						if llEsCodBarAltSecuencial
							* Si tiene secuencial debo agregarle a la linea que voy a agregar el secuencial
							lcLinea = this.AgregarNroSecuencial( lcLinea, loDetalle( lnj ).secuencial )
							
							if llUsaCodBarAlt
								lcLinea = this.AgregarCheckSumACodigoConSecuencial( lcLinea )
								
*!*									lcAux = substr(lcLinea, atc("*", lcLinea ,1)+1, atc("*", lcLinea ,2)-atc("*", lcLinea ,1)-1)
*!*									lcBusca = substr(lcLinea, atc("*", lcLinea ,1), atc("*", lcLinea ,2)-atc("*", lcLinea ,1)+1)
*!*									lcAuxConCheck = this.ConfigurarCadena( lcAux )
*!*									lcLinea =  strtran(lcLinea, lcBusca,lcAuxConCheck)
								
							endif
						endif
						loItemValor.cValor = lcLinea
						loItemValor.cDelimitadorInsertCierre = this.cDelimitadorInsertCierre
						toDatos.oValores.Agregar( loItemValor )
					endfor
				endif
			endfor
			this.Funcionalidades.oContadorPorCombinacion = null
			if this.nItemsAImprimir = 0
				if toDatos.cTipoArea = this.cTipoAreaEtiquetaDeArticulo
					this.AgregarInformacion( "Sin detalle", this.nNumeroErrorPorImprimirSinDetalle )
					llError = .t.
				endif	
			endif
			
			if llEsAreaEtiqueta && no agrupo ya que viene por impresion de etiquetas
			else
				This.VerificarFuncionalidadAgrupamiento( toDatos )
			EndIf	
		endif	
		if llError
			goServicios.Errores.levantarExcepcion( "Error en el diseño de impresión." )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearValoresInsertDetEtiquetas( toDatos as Object, toEntidad as entidad OF entidad.prg ) as Void
		local lcDetalle as String, loDetalle as Object, llEsAreaEtiqueta as Boolean , ;
		 lcValores as String, lcAtributo as String, llError as Boolean, lni as Integer, lnj as Integer, llAtributoFuncional, ;
		  lnCantidad as Integer, lnP as Integer , llEsAtributoDelDetalle as Boolean, loCodBarra as Object, lcDelimitador as String ,;
		  lnA as Integer , lcAtrib as String , lcAux as String, lnCantidadAtributos as Integer, lcAuxUsaCB As String, loItemValor as Object, ;
		  llEsItemFuncEtiqueta as Boolean, lcContenido as String, lcValor as String, lcAtributoSinFunciones as String, ;
		  llExisteMensaje as Boolean, llEsCodBarAltSecuencial as Boolean, lcLongitudCampo as string, lnLongitudCampo as integer, ;
		  lcBusca as String, lcAuxConCheck as String, llUsaCodBarAlt as Boolean
 
		llError = .F.
		lcAuxUsaCB = ""
		llExisteMensaje = .f.
		lcDetalle = this.ObtenerDetalleDelArea( toDatos, toEntidad )
		llError = this.hayInformacion()
		store .F. to llEsCodBarAltSecuencial, llUsaCodBarAlt
		store "" to lcLongitudCampo, lcBusca, lcAuxConCheck

		this.nCantNrosSecuencial = 0
		this.nUltimoNroSecuencial = 0
		
		lnLongitudCampo = 0
		if !llError and !empty( lcDetalle )
			with toEntidad
				loDetalle = &lcDetalle.
			endwith

			if type("loDetalle(this.nIndiceEtiqueta).Secuencial") = "C" and !empty( loDetalle(this.nIndiceEtiqueta).Secuencial )
				loDetalle(this.nIndiceEtiqueta).Secuencial = ""
			endif
			
			llEsAreaEtiqueta = ( todatos.cTipoArea = this.cTipoAreaEtiquetaDeArticulo )
			this.nItemsAImprimir = 0
			this.oColumnaNumerarPorCombinacion = _screen.zoo.crearobjeto("ZooColeccion")
				if empty( toDatos.cCondicion ) or ( !empty( toDatos.cCondicion ) and this.CondicionVerdadera( toDatos.cCondicion , this.nIndiceEtiqueta , loDetalle, .t. ) )				
					lcValores = ""
					lnCantidad = 1
					this.nCondicionesFalsas = 0
					this.oColumnaNumerarPorCombinacion.remove(-1)

					for lni = 1 to toDatos.oAtributos.Count
						lcValor = ""						
						lcContenido = toDatos.oAtributos[ lni ].contenido 

						lcAtributoSinFunciones = this.analizarcontenidoatributos( lcContenido )
						if "IIF" $ upper(lcContenido)
							with toEntidad
								lcContenido = &lcContenido
							endwith
						endif

						loCodBarra = this.EsCodigoDeBarra( toDatos.oAtributos( lni ) )
						llEsAtributoDelDetalle =  getwordcount( alltrim( lcAtributoSinFunciones ), '.' ) > 1  and ( upper(alltrim( strtran( lcdetalle,".",""))) = upper(getwordnum( alltrim( lcAtributoSinFunciones ),1,".")))
						lcAtributo = this.ObtenerAtributo( llEsAtributoDelDetalle , alltrim( lcAtributoSinFunciones) )
						llEsItemFuncEtiqueta = this.EsItemFuncionEtiquetaDeArticulo( lcContenido )
						llEsAtributoDelDetalle = llEsAtributoDelDetalle or llEsItemFuncEtiqueta
						lcDelimitador = iif( loCodBarra.lUsaCB ,alltrim( loCodBarra.cDelimitador ), "" )
						lcMascara = iif( toDatos.oAtributos( lni ).FuncionAgrupar = 2, "", alltrim( toDatos.oAtributos( lni ).Mascara ) )
						llAtributoFuncional = ( toDatos.oAtributos( lni ).tipo_pk = "F" )
						llIntermec	= ( this.oDisenoImpresion.OpcionDeSalida = 5 and this.oDisenoImpresion.EsUnReporteDeEtiqueta() )
						llNumerarPorCombinacion = (llAtributoFuncional or llIntermec) and "NUMERARCOMBINACION" $ upper(lcContenido)

						if "OBTENERCADENACODBARRADECOMBINACIONCONSECUENCIAL" $ upper( lcContenido ) or upper( lcContenido ) $ "COMBINACIONPARACODBARRACONSECUENCIAL"
							llEsCodBarAltSecuencial = .T.
						endif
						
						if llAtributoFuncional
							if !llNumerarPorCombinacion
								lcAtributo = this.ObtenerAtributoConFuncionalidad( lcContenido  , loDetalle.Item( this.nIndiceEtiqueta  ), toEntidad, lcMascara )
								if this.oDisenoImpresion.EsUnReporteDeEtiqueta()
									lcAux = ""
									lnCantidadAtributos = getwordcount( lcAtributo, ";" )
									for lnA = 1 to lnCantidadAtributos 
										lcAtrib = alltrim( getwordnum( lcAtributo, lnA, ";" ))
										if occurs( "#$", lcAtrib ) > 0 && Es Codigo de barra formato Lince
											llExisteMensaje = .f.
											lcAux2 = alltrim( strtran( lcAtrib, "#$", "" ) )
											try
												lxAtrib = loDetalle( this.nIndiceEtiqueta ).&lcAux2.
												lxAtrib = alltrim(lxAtrib)
												if vartype( loDetalle( this.nIndiceEtiqueta ).&lcAux2. ) = "U"
													this.agregarInformacion( "El atributo " + lcAux2 + " no existe." )
													llError = .T.
												else
													do case
														case lower(lcAux2) = 'articulo_pk'
															if len( alltrim(lxAtrib) ) > 13 or empty(lxAtrib)
																llError = .T.
																llExisteMensaje = .T.
															else
																lcAux = lxAtrib
															endif
														case lower(lcAux2) = 'color_pk' and !empty(lxAtrib)
															if len( alltrim(lxAtrib) ) > 2
																llError = .T.
																llExisteMensaje = .T.
															else
																lcAux = lcAux + "%" + lxAtrib
															endif
														case lower(lcAux2) = 'talle_pk' and !empty(lxAtrib)
															if len( alltrim(lxAtrib) ) > 3
																llError = .T.
																llExisteMensaje = .T.
															else
																if occurs( "%", lcAux ) > 0
																	lcAux = lcAux + lxAtrib
																else
																	lcAux = lcAux + "$" + lxAtrib
																endif
															endif
														endcase
														if llExisteMensaje
														llExisteMensaje = .f.
														for each loMensaje in this.oInformacion
															if alltrim( loMensaje.cmensaje ) = "La longuitud del atributo " + lxAtrib + " no es válida."
																llExisteMensaje = .t.
															endif
														endfor
														if llExisteMensaje
														else
															this.agregarInformacion( "La longuitud del atributo " + lxAtrib + " no es válida." )
														endif
													endif
													
												endif
											catch
												if ".CompAfec" $ lcAtributo  		
													this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
												else
													this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAux2 )
												endif
												llError = .T.
											endtry
										else
											if occurs( "#%", lcAtrib ) > 0
												lcAux = lcAux + lcDelimitador + alltrim( strtran( lcAtrib, "#%", "" ) )
											else
												try
													if llEsCodBarAltSecuencial and "SECUENCIAL" $ lcAtrib
														lcLongitudCampo = substr( lcAtrib,atc("(",lcAtrib), len(lcAtrib))
														lcAtrib = strtran(  lcAtrib, lcLongitudCampo, "" )
														lcLongitudCampo = strtran( lcLongitudCampo, "((", "" )
														lnLongitudCampo = int( val( strtran( lcLongitudCampo, "))", "" ) ) )
													endif
													lxAtrib = loDetalle( this.nIndiceEtiqueta  ).&lcAtrib.
													if vartype( loDetalle( this.nIndiceEtiqueta  ).&lcAtrib. ) = "U"
														this.agregarInformacion( "El atributo " + lcAtrib + " no existe." )
														llError = .T.
													else
														lcAux = lcAux + iif( lnA = 1, lcDelimitador, alltrim( goregistry.dibujante.CaracterSeparadorDeAtributosDeCombinacionParaImpresionDeCodigoDeBarras ) ) + strtran( alltrim( transform( loDetalle( this.nIndiceEtiqueta  ).&lcAtrib., alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
													endif
												catch
													if ".CompAfec" $ lcAtributo  		
														this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
													else
														this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtrib )
													endif
													llError = .T.
												endtry
											endif
										endif
									endfor
									if occurs( "#$", lcAtrib ) > 0
										lcAuxUsaCB = "*" + lcAux + "*"
									else
										if llEsCodBarAltSecuencial 
											lcAux = lcAux + lcDelimitador
											if loCodBarra.lUsaCB
												lcAuxUsaCB = "*" + lcAux + "*"
												llUsaCodBarAlt = .t.
											else
												*llUsaCodBarAlt = .f.
												lcAuxUsaCB = alltrim( lcAux )
											endif
										else
											lcAux = lcAux + lcDelimitador 
											lcAuxUsaCB = iif( loCodBarra.lUsaCB ,this.ConfigurarCadena( lcAux ), alltrim( lcAux ) )
										endif
									endif
									if inlist( asc( substr( lcAuxUsaCB, len( lcAuxUsaCB ) - 01, 01 ) ), 91, 93) and this.cDelimitadorInsertApertura == "["
										this.cDelimitadorInsertApertura = "'"
										this.cDelimitadorInsertCierre = "'"
									endif
									lcValor = lcAuxUsaCB
									lcValores = lcValores + this.cDelimitadorInsertApertura + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .t. ) + this.cDelimitadorInsertCierre + "<!> "
									This.EstablecerDelimitadoresDeSentencia()
								else
									lcAtributo = strtran(lcAtributo,"#%","") 
									lcValor = strtran( alltrim( transform( lcAtributo, alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
		 							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .t. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
								endif
							else
	 							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + lcContenido + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
								this.oColumnaNumerarPorCombinacion.Agregar(lni)
							endif 
						else 
							if llIntermec								
								loDetalle.CargarItem( this.nIndiceEtiqueta  )
								toItem = loDetalle.oItem
								try
									lcAtributo = alltrim( lcContenido )
									if llNumerarPorCombinacion
										this.oColumnaNumerarPorCombinacion.Agregar(lni)
									else
										lcAtributo = this.ObtenerValorEnExpresionIntermec( lcAtributo, toEntidad , toItem )
										if llEsCodBarAltSecuencial and "OBTENERCADENACODBARRADECOMBINACIONCONSECUENCIAL" $ upper( lcContenido ) and ;
											!EMPTY(toItem.secuencial) AND empty(loDetalle( this.nIndiceEtiqueta).SECUENCIAL)
												loDetalle(this.nIndiceEtiqueta).SECUENCIAL = toItem.secuencial
										endif
									endif
										 								
									lcValor = strtran( alltrim( transform( lcAtributo, alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
									lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .f. ) + ;
									            lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
									
									if occurs( "#$", lcAtributo ) > 0 && Es Codigo de barra formato Lince, contiene error
										llError = .T.
										lcMensaje = substr( lcAtributo,at("#$",lcAtributo)+2, at("#$",lcAtributo,2) - at("#$",lcAtributo)-2)
										llExisteMensaje = .f.
										for each loMensaje in this.oInformacion
											if alltrim( loMensaje.cmensaje ) = "La longuitud del los siguientes atributos no es válida: " + lcMensaje
												llExisteMensaje = .t.
											endif
										endfor
										if llExisteMensaje
										else
											this.agregarInformacion( "La longuitud del los siguiente atributos no es válida: " + lcMensaje )
										endif
									endif
								catch
									if ".CompAfec" $ lcAtributo  		
										this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
									else
										this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
									endif
									llError = .T.
								endtry
							else
								if llEsAtributoDelDetalle
									if llEsItemFuncEtiqueta
										try
											&& En esta instancia tengo algo del estilo Funcion( .ETIQUETADETALLE.ATRIBUTO, parametro, etc ) 
											loDetalle.CargarItem( this.nIndiceEtiqueta  )
											lcAtributo = strtran( lcContenido, this.cDetalleEtiquetaDeArticulo, "" )
											with loDetalle.oItem
												lcValor = strtran( alltrim( transform( &lcAtributo, lcMascara ) ) , "]", "] + chr( 93 ) + [" )
												lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .t. ) + ;
															lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
											endwith
										catch
											if ".CompAfec" $ lcAtributo  		
												this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
											else
												this.agregarInformacion( "El contenido de la expresión no es válido: " + lcContenido )
											endif
											llError = .T.
										endtry
									Else
										if occurs(".", lcAtributo) > 0
											try											
												lxAtrib = loDetalle.oItem.&lcAtributo.
												if vartype( loDetalle.oItem.&lcAtributo. ) = "U"
													this.agregarInformacion( "El atributo " + lcAtributo + " no existe." )
													llError = .T.
												else
													loDetalle.CargarItem( this.nIndiceEtiqueta  )
													lcAtributo = strtran( lcCOntenido, lcDetalle, "",-1,-1,1)
													
													with loDetalle.oItem
														lcValor = iif( loCodBarra.lUsaCB, strtran( this.ConfigurarCadena( alltrim( transform( &lcAtributo ) ) ), "]", "] + chr( 93 ) + [" ) , ;
																	strtran( alltrim( transform( &lcAtributo, lcMascara ) ) , "]", "] + chr( 93 ) + [" ) )
														lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + ;
																	this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .f. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
													endwith
												endif
											catch
												if ".CompAfec" $ lcAtributo  		
													this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
												else
													this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
												endif
												llError = .T.
											endtry
										else
											try
												loDetalle.CargarItem( this.nIndiceEtiqueta  )

												if vartype( loDetalle( this.nIndiceEtiqueta  ).&lcAtributo. ) = "U"
													this.agregarInformacion( "El atributo " + lcAtributo + " no existe." )
													llError = .T.
												else

												lcAtributo = strtran( lcCOntenido, lcDetalle, "",-1,-1,1)

													with loDetalle.oItem

														if loCodBarra.lUsaCB
															lcValor = strtran( this.ConfigurarCadena( alltrim( transform( &lcAtributo ) ) ), "]", "] + chr( 93 ) + [" )
														else 
															lcValor = strtran( alltrim( transform( &lcAtributo, lcMascara ) ), "]", "] + chr( 93 ) + [" )
														endif	

														lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + ;
																	this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .t. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
													endwith
												endif
											catch
												if ".CompAfec" $ lcAtributo  		
													this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
												else
													this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
												endif
												lError = .T.
											endtry
										endif
									Endif	
								else
									with toEntidad
										try
											lxAtrib = &lcAtributo.
											if vartype( &lcAtributo. ) = "U"
												this.agregarInformacion( "El atributo " + iif( left( lcAtributo , 1 ) == ".", substr( lcAtributo, 2 ), lcAtributo ) + " no existe." )
												llError = .T.
											else
												lcValor = strtran( alltrim( transform( &lcAtributo., alltrim( toDatos.oAtributos( lni ).Mascara ) ) ), "]", "] + chr( 93 ) + [" )
												lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + this.ValorConCondicion( lcValor, toDatos.oAtributos, loDetalle, this.nIndiceEtiqueta , lnI, .t. ) + lcDelimitador + this.cDelimitadorInsertCierre + "<!> "
											endif
										catch
											if ".CompAfec" $ lcAtributo  		
												this.agregarInformacion( "El diseño seleccionado no se puede imprimir desde la entidad simplificada. debe realizarlo desde el formulario donde se generó")
											else
												this.agregarInformacion( "El contenido de la expresión no es válido: " + lcAtributo )
											endif
											llError = .T.
										endtry
									endwith
								endif
							endif 
						endif	
					endfor	
				else
					this.nCondicionesFalsas = toDatos.oAtributos.Count			
				endif

				if this.nCondicionesFalsas < toDatos.oAtributos.Count && muestra al menos un atributo del item
					this.nItemsAImprimir = this.nItemsAImprimir + 1
					lnCantidad = 1
					if llEsAreaEtiqueta and pemstatus( loDetalle.item( this.nIndiceEtiqueta  ), "Cantidad", 5 )
						lnCantidad = loDetalle( this.nIndiceEtiqueta  ).Cantidad
					endif

					if llIntermec
						if llEsCodBarAltSecuencial
							lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador + "1" + lcDelimitador +;
									    this.cDelimitadorInsertCierre + "<!> "
					    else
					        if this.oColumnaNumerarPorCombinacion.Count = 0
						        lnCantidad = 1 && Optimiza si es impresion directa a puerto con etiquetas con una sola columna de impresion
					        else
						        lnCantidad = ceiling( loDetalle(this.nIndiceEtiqueta ).Cantidad/ max(1,this.oDisenoImpresion.Columnas) ) 
					        endif
					        lcValores = lcValores + this.cDelimitadorInsertApertura + lcDelimitador ;
								+ alltrim( transform( ceiling( loDetalle(this.nIndiceEtiqueta ).Cantidad/max(1,this.oDisenoImpresion.Columnas) ) ) );
								+ lcDelimitador + this.cDelimitadorInsertCierre;
								+ "<!> "
					    endif
					endif
                    lcValores = alltrim( lcValores )
					lcValores = substr( lcValores, 1, len( lcValores ) - 3 )
					
					for lnP = 1 to lnCantidad
						lcLinea = lcValores
						&& Si hay que calcular NUMERARCOMBINACION
						for each lnIndiceX in this.oColumnaNumerarPorCombinacion
							lcDelimitador = "<!> "
							lnInferior = iif( lnIndiceX > 1, at( lcDelimitador, lcLinea, lnIndiceX-1 ) + len(lcDelimitador) - 1, 1 )
							lnSuperior = at( lcDelimitador, lcLinea, lnIndiceX )
							lnSuperior = iif( lnSuperior=0, len(lcLinea)+1, lnSuperior )
							lcFuncion = chrtran( substr( lcLinea, lnInferior, lnSuperior-lnInferior ), this.cDelimitadorInsertApertura+this.cDelimitadorInsertCierre, "" )
							if llIntermec 
								lcAtributo = this.ObtenerValorEnExpresionIntermec( lcFuncion , toEntidad , loDetalle.Item( this.nIndiceEtiqueta  ) )
							else
								lcAtributo = this.ObtenerAtributoConFuncionalidad( lcFuncion , loDetalle.Item( this.nIndiceEtiqueta  ), toEntidad, lcMascara )
							endif
							lcLinea = iif(lnInferior>1,substr(lcLinea,1,lnInferior),"") + this.cDelimitadorInsertApertura + lcAtributo + this.cDelimitadorInsertCierre + substr(lcLinea,lnSuperior)
						endfor
						loItemValor = _screen.Zoo.crearObjeto( "ItemValores", "managerImpresion.prg" )

						if llEsCodBarAltSecuencial
							lcLinea = this.AgregarNroSecuencial( lcLinea, loDetalle( this.nIndiceEtiqueta ).Secuencial, loDetalle( this.nIndiceEtiqueta ).Cantidad )

							if llUsaCodBarAlt
								lcLinea = this.AgregarCheckSumACodigoConSecuencial( lcLinea )
*!*									lcAux = substr(lcLinea, atc("*", lcLinea ,1)+1, atc("*", lcLinea ,2)-atc("*", lcLinea ,1)-1)
*!*									lcBusca = substr(lcLinea, atc("*", lcLinea ,1), atc("*", lcLinea ,2)-atc("*", lcLinea ,1)+1)
*!*									lcAuxConCheck = this.ConfigurarCadena( lcAux )
*!*									lcLinea =  strtran( lcLinea, lcBusca,lcAuxConCheck )
							endif
						endif
						loItemValor.cValor = lcLinea
						loItemValor.cDelimitadorInsertCierre = this.cDelimitadorInsertCierre
						toDatos.oValores.Agregar( loItemValor )
					endfor
				endif
				
			this.Funcionalidades.oContadorPorCombinacion = null
			if this.nItemsAImprimir = 0
				if toDatos.cTipoArea = this.cTipoAreaEtiquetaDeArticulo
					this.AgregarInformacion( "Sin detalle", this.nNumeroErrorPorImprimirSinDetalle )
					llError = .t.
				endif	
			endif
			if llEsAreaEtiqueta && no agrupo ya que viene por impresion de etiquetas
			else
				This.VerificarFuncionalidadAgrupamiento( toDatos )
			EndIf	
		endif	
		if llError
			goServicios.Errores.levantarExcepcion( "Error en el diseño de impresión." )
		ENDIF
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorEnExpresionIntermec( tcAtributo as String, toEntidad as Object, toItem as Object ) as String
		local lcLeft as String, lcExpresion as String, lcRight as String, lcFuncion as String, lcRetorno as String
		if at('#%',tcAtributo,2) != 0 
			lcLeft = alltrim( getwordnum( tcAtributo, 1, "#%" ))
			lcExpresion = alltrim( getwordnum( tcAtributo, 2, "#%" ))
			lcRight = alltrim( getwordnum( tcAtributo, 3, "#%" ))
			lcFuncion = this.ObtenerNombreFuncion( lcExpresion )
			if pemstatus( this.funcionalidades,lcFuncion,5 )
				lcFuncionValor = this.ObtenerAtributoConFuncionalidad( lcExpresion , toItem , toEntidad, "" )
				lcFuncionValor = alltrim(strtran(lcFuncionValor,"#%",""))
			else
				lcExpresion = strtran( lcExpresion, this.cDetalleEtiquetaDeArticulo, "" )
				lcExpresion = this.CambiarCantidadParaImpresionAPuerto( lcExpresion )
				with toItem 
					lcFuncionValor = &lcExpresion.
				endwith
			endif
			lcRetorno = lcLeft + lcFuncionValor + lcRight 
		else
			lcRetorno = tcAtributo
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarFuncionalidadAgrupamiento( toDatos as Object ) as Void
		if This.TieneFuncionesAgrupamientos( toDatos.oAtributos )
			This.CrearCursorAgrupamiento( toDatos )
			This.CargarDatosEnCursorAgrupamiento( toDatos )
			This.EjecutarSelectAgrupamiento( toDatos )
			This.RegenerarValores( toDatos )
			This.CerrarCursoresAgrupamiento()
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RegenerarValores( toDatos as Object ) as Void
		local lnI as Integer, lcValores as String, loItemValor As Object, lcAtributo as String
		toDatos.oValores.remove( -1 )
		select c_Agrupados
		scan All
			lcValores = ""
			loItemValor = _screen.Zoo.crearObjeto( "ItemValores", "managerImpresion.prg" )
			loItemValor.cDelimitadorInsertCierre = this.cDelimitadorInsertCierre
			for lni = 1 to toDatos.oAtributos.Count
				lcCampo = "C" + transform( lnI )
				if toDatos.oAtributos( lni ).funcionAgrupar = 2
					lcAtributo = transform( c_Agrupados.&lcCampo, alltrim( toDatos.oAtributos( lni ).Mascara ) )					
					lcValores = lcValores + this.cDelimitadorInsertApertura + alltrim( lcAtributo ) + this.cDelimitadorInsertCierre + "<!> "
				else
					lcAtributo = alltrim( c_Agrupados.&lcCampo )
					lcValores = lcValores + lcAtributo + "<!> "
				Endif
			endfor
			lcValores = substr( lcValores, 1, len( lcValores ) - 4 )
			loItemValor.cValor = lcValores
			toDatos.oValores.Agregar( loItemValor )
			select c_Agrupados
		EndScan	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EjecutarSelectAgrupamiento( toDatos as Object ) as Void
		local lnI as Integer, lcSelect as String, lcGroupBy as String
		lcSelect = ""
		lcGroupBy = ""
		for lni = 1 to toDatos.oAtributos.Count
			if toDatos.oAtributos( lni ).funcionAgrupar = 2
				lcSelect = lcSelect + "sum( C" + transform( lnI ) + ") as C" + transform( lnI ) + ","
			else
				lcSelect = lcSelect + "C" + transform( lnI ) + ","
				lcGroupBy = lcGroupBy + "C" + transform( lnI ) + ","
			Endif
		Endfor
		lcSelect = substr( lcSelect, 1, len( lcSelect ) - 1)
		lcGroupBy = substr( lcGroupBy, 1, len( lcGroupBy ) - 1)
		lcSelect = "Select " + lcSelect + " from c_Agrupar into Cursor c_Agrupados Group by " + lcGroupBy
		&lcSelect
		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarDatosEnCursorAgrupamiento( toDatos as Object ) as Void
		local lnI as Integer, lnJ as Integer, lcItem as String, lcValor as String, lnCantidadAtributos as Integer
		
		lnCantidadAtributos = 0
		dimension laAtributos[ 1 ]
			
		for lnJ = 1 to toDatos.oValores.Count
			insert into c_Agrupar ( c_registro ) values ( lnJ )
			
			lcItem = toDatos.oValores[ lnJ ].cValor
			lnCantidadAtributos = alines( laAtributos, lcItem , 0, "<!>" )		
	
			for lni = 1 to lnCantidadAtributos 
				lcValor = laAtributos[ lni ]			

				if toDatos.oAtributos( lni ).funcionAgrupar = 2
					lcValor = strtran( lcValor, This.cDelimitadorInsertApertura , "" )
					lcValor = strtran( lcValor, This.cDelimitadorInsertCierre, "" )
					Replace ( "C" + transform(lni) ) with val( lcValor ) in c_Agrupar
				else
					Replace ( "C" + transform(lni) ) with lcValor in c_Agrupar
				Endif
			Endfor
		Endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearCursorAgrupamiento( toDatos as Object ) as Void
		local lnI as Integer
		create cursor c_Agrupar ( C_Registro N(10) )
		for lni = 1 to toDatos.oAtributos.Count
			if toDatos.oAtributos( lni ).funcionAgrupar = 2
				alter table c_Agrupar add column ( "C" + transform(lni) )  N( 15, 3)
			else
				alter table c_Agrupar add column ( "C" + transform(lni) )  C( 254)							
			Endif
		Endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarCursoresAgrupamiento() as Void
		use in select( "c_Agrupar" )
		use in select( "c_Agrupados" )
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function TieneFuncionesAgrupamientos( toAtributos as Object ) as boolean
		local llRetorno as Boolean, lni as Integer
		llRetorno = .F.
		for lni = 1 to toAtributos.Count
			llRetorno = llRetorno or ( toAtributos( lni ).funcionAgrupar = 2 )
		endfor
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributo( TlEsAtributoDelDetalle as Boolean, tcContenido as String  ) as String 
	local lcRetorno as String 
		if tlEsAtributoDelDetalle 
			lcRetorno = substr( alltrim( tcContenido ), atc( ".", alltrim( tcContenido ),2 ) + 1 )
		else
			lcRetorno =  alltrim( tcContenido )
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarCadena( tcAux ) as string
		local lcRetorno as String 
		lcRetorno = ""
		if !empty( tcAux )
			lcRetorno = this.GenerarChecksum( alltrim( tcAux ) )
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosArea( toArea as Object, toDatos as Object ) as Void
		local lnCont as Integer, lnCont2 as Integer, loItem as Object

		if toArea.esDet
			with this.oDisenoImpresion.Atributos
				for lnCont = 1 to .count
					if upper( alltrim( toArea.Area ) ) == upper( alltrim( .item[ lnCont ].Area) )
						if ( upper( alltrim( .item[ lnCont ].Tipo_Pk ) ) = "E" and !empty( .item[ lnCont ].Condicion ) )
							.item[ lnCont ].Tipo_Pk = "A"
							.item[ lnCont ].Contenido = "[" + alltrim( .item[ lnCont ].Contenido ) + "]"
						endif
						if ( inlist(upper( alltrim( .item[ lnCont ].Tipo_Pk )),"A","F","CDP","I") )

							toDatos.oAtributos.agregar( .item[ lnCont ] )
						endif	
					endif	
				endfor
			endwith
		else
			*Tengo que seleccionar todos los atributos que sean de areas NO DETALLE
			with this.oDisenoImpresion.Areas
				for lnCont = 1 to .count
					loItem = .item[ lnCont ]
					if loItem.EsDet 
					else
						with this.oDisenoImpresion.Atributos
							for lnCont2 = 1 to .count
								if upper( alltrim( loItem.Area ) ) == upper( alltrim( .item[ lnCont2 ].Area) ) and ;
										( upper( alltrim( .item[ lnCont2 ].Tipo_Pk ) ) == "A" or upper( alltrim( .item[ lnCont2 ].Tipo_Pk ) ) == "F" or upper( alltrim( .item[ lnCont2 ].Tipo_Pk ) ) == "I" )
									toDatos.oAtributos.agregar( .item[ lnCont2 ] )
								endif		
							endfor
						endwith
					endif
				endfor
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearCamposInsert( toDatos as Object ) as Void
		local lnCont as Integer, lcCampos as String, lnCol as Integer, lni as Integer , lEsEtiqueta as Boolean , lnContador as Integer;
			lEsIntermec as Boolean, lcCursorOrdenamiento as string, lcNombreCampo as string, llCampoConOrden as boolean

		lEsEtiqueta = this.oDisenoImpresion.EsUnReporteDeEtiqueta()
		lEsIntermec = this.oDisenoImpresion.OpcionDeSalida = 5

		lnCol = iif( ( lEsEtiqueta and !lEsIntermec ),max(1,this.oDisenoImpresion.Columnas), 1 )
		lnContador = 1
		lcCampos = ""
		
		lcCursorOrdenamiento = "c_Ordenamiento" + sys(2015)
		create cursor &lcCursorOrdenamiento. (Prioridad n(2), NumeroCampo n(3), NombreCampo c(5), TipoOrden c(5))
		
		with toDatos.oAtributos
			for lnCont = 1 to .count
				if inlist( upper( alltrim( .item[ lnCont ].Tipo_Pk ) ), "A", "F", "CDP", "I" )
					llCampoConOrden = !empty( .item[lnCont].PrioridadOrdenamiento )
					if llCampoConOrden
						append blank in (lcCursorOrdenamiento)
						replace Prioridad with .item[lnCont].PrioridadOrdenamiento, ;
								TipoOrden with this.ObtenerTipoOrdenamiento(.item[lnCont].TipoOrdenamiento) ;
								in (lcCursorOrdenamiento)
					endif
					
					if lEsEtiqueta
						for lnI = 1 to lnCol
							lcNombreCampo = This.ObtenerNombreCampo( .item[ lnCont ], lnContador )
							lcCampos = lcCampos + lcNombreCampo + " ,"
							
							if llCampoConOrden
								replace NumeroCampo with lnContador, ;
										NombreCampo with lcNombreCampo ;
										in (lcCursorOrdenamiento)
							endif
							
							lnContador = lnContador + 1
						endfor 
					else
						lcNombreCampo = This.ObtenerNombreCampo( .item[ lnCont ], lnCont )
						lcCampos = lcCampos + lcNombreCampo + " ,"
							
						if llCampoConOrden
							replace NumeroCampo with lnCont, ;
									NombreCampo with lcNombreCampo ;
									in (lcCursorOrdenamiento)
						endif
					endif	
				endif	
			endfor
		endwith
		if lEsIntermec 
			lcCampos = lcCampos + "zcantidad ,"
		endif
		
		toDatos.cCampos = iif( empty( lcCampos ), "c_1",substr( lcCampos, 1, len( lcCampos ) - 2 ))
		
		toDatos.cOrdenamiento = ""
		select &lcCursorOrdenamiento
		if !eof()
			index on str(Prioridad) + str(NumeroCampo) tag imporden
			scan
				toDatos.cOrdenamiento = toDatos.cOrdenamiento + alltrim(NombreCampo) + rtrim(TipoOrden) + ", "
			endscan
			toDatos.cOrdenamiento = left(toDatos.cOrdenamiento, len(toDatos.cOrdenamiento) - 2)
		endif
		use in (lcCursorOrdenamiento)
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoOrdenamiento( tnTipoOrdenamiento as integer ) as string
		do case
			case tnTipoOrdenamiento = 1
				return " asc"
			case tnTipoOrdenamiento = 2
				return " desc"
			otherwise
				return ""
		endcase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CopiarTablasDesdeRepositorio( tcRutaTrabajo as String )
		local i as Integer, loItem as Object, lcArchivo as String
		with this
			for i = 1 to .oDisenoImpresion.Areas.Count
				loItem = .oDisenoImpresion.Areas.Item[ i ]
				lcArchivo = .ObtenerTabla( loItem , .oDisenoImpresion.Codigo )
				if file( this.cRutaRepositorio + lcArchivo )
					copy file ( this.cRutaRepositorio + lcArchivo ) to ( tcRutaTrabajo + lcArchivo )
				endif
			endfor
			lcArchivo = strtran(alltrim(.oDisenoImpresion.Codigo)," ","_") + "totaliza.dbf"
			if file( this.cRutaRepositorio + lcArchivo )
				copy file ( this.cRutaRepositorio + lcArchivo ) to ( tcRutaTrabajo + lcArchivo )
			endif
			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAreaEtiqueta( tnI as Integer ) as Boolean 
		local llRetorno as Boolean, loitem as Object 
		
		loItem = this.oDisenoImpresion.Areas.item[ tnI ]
		if loItem.tipo_pk = this.cTipoAreaEtiquetaDeArticulo
			llretorno = .T.
		endif 

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsDetalleMultiHoja( tnI as Integer ) as Boolean 
		local llRetorno as Boolean, loitem as Object 
		
		loItem = this.oDisenoImpresion.Areas.item[ tnI ]
		if loItem.tipo_pk = "DETALLE MULTIHOJA"	
			llretorno = .T.
		endif 
	 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearPropiedadesDelReporte( toReporte as Object ) as Void
		local i as Integer, loItem as Object  
		this.lEsReporteMultihoja = .f.
		this.nPosicionDetalleMultihoja = 0

		for i = 1 to this.oDisenoImpresion.Areas.Count
			loItem = this.oDisenoImpresion.Areas.Item[ i ]
			if loItem.EsDet and this.EsDetalleMultiHoja[ i ]
				this.lEsReporteMultihoja = .t.
				this.nPosicionDetalleMultihoja = loItem.y
				exit
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarYCopiarReporte( tcRutaTrabajo as String, toEntidad as entidad OF entidad.prg ) as String 

		local lcReporte as String, i as Integer, loItem as Object, loApp as Object, loReporte as Object, loSubReporte as Object, lni
		
		with this
			lcReporte = forceext( this.obtenerNombreReporte( .oDisenoImpresion ), "RPT" )
			try
				loReporte = This.AbrirReporte( .cRutaRepositorio + lcReporte )
				this.SetearTablas( loReporte, tcRutaTrabajo )
				this.SetearPropiedadesDelReporte( loReporte )
				for i = 1 to .oDisenoImpresion.Areas.Count
					loItem = .oDisenoImpresion.Areas.Item[ i ]
					if loItem.EsDet and !this.EsAreaEtiqueta[ i ] and !this.EsDetalleMultiHoja[ i ]
						if .nPosicionDetalleMultihoja > 0 and loItem.Y > .nPosicionDetalleMultihoja
							lnI = loReporte.Areas.count - 1
							loSubReporte = loReporte.Areas.item[lni].sections.item[1].reportObjects.item[ 'DETALLE_' + upper( alltrim( loItem.Area ) )]
						else
							if upper( alltrim( loItem.tipo_PK ) ) = "PIE DETALLE"
								loSubReporte = loReporte.Areas.item[4].sections.item[1].reportObjects.item[ 'DETALLE_' + upper( alltrim( loItem.Area ) )]
							else
								loSubReporte = loReporte.Areas.item[2].sections.item[1].reportObjects.item[ 'DETALLE_' + upper( alltrim( loItem.Area ) )]
							endif
						endif 
						this.setearTablas( loSubReporte.openSubReport(), tcRutaTrabajo )
					endif
				endfor

				if this.verificaTamañoHoja() 
					loReporte.Areas("PF").Sections.Item[ 1 ].Suppress = .T.
				else
					if !.lEsSalidaAPDF and this.odisenoimpresion.imprimecontinuo()
						for i = 1 to loReporte.Areas("PF").Sections.Item[ 1 ].ReportObjects.Count
							if "TEXT" $ upper( alltrim( loReporte.Areas("PF").Sections.Item[ 1 ].ReportObjects.Item[ i ].name ) )
								loReporte.Areas("PF").Sections.Item[ 1 ].ReportObjects.Item[ i ].Suppress = .T.
							endif
						endfor
					endif
				endif
				
				loReporte.Database.verify()

				.AplicarCondiciones( toEntidad, loReporte )

				loReporte.saveAs( addbs( tcRutaTrabajo )+ lcReporte , 0 )
			Catch To loError
				goServicios.Errores.levantarExcepcion( loError )
			finally
				loApp = null
				loReporte = null
				loSubReporte = null
			EndTry
		endwith
		return lcReporte
	endfunc 

	*-----------------------------------------------------------------------------------------
	function verificaTamañoHoja() as Boolean
		local lRetorno as boolean
 
		lRetorno = .f.
		if prtinfo(3) != -1 and prtinfo(3) <1050
			lRetorno = .t.
		endif
		
		return lRetorno 
	endfunc
	*-----------------------------------------------------------------------------------------
	function AplicarCondiciones( toEntidad as entidad OF entidad.prg, loReporte as Object ) as Void
		local loItem as Object, llCondicion as Boolean, loObjetoCrystal as Object, lcNombreObjetoCrystal as String,;
		lnI as Integer, lnCol as Integer , llEsEtiqueta as Boolean, lnPP, llCondicionArea as Boolean, lcArea as String
		lnPP = 1
		lnI = 0
		llEsEtiqueta = this.oDisenoImpresion.EsUnReporteDeEtiqueta()
		lnCol = iif( llEsEtiqueta, max(1,this.oDisenoImpresion.Columnas), 1 )
		loColResultados = this.ObtenerResultadoCondiciones( toEntidad )
		with this

			for each loItem in .oDisenoImpresion.Atributos 
				if !this.EsItemDeDetalle( loItem.Area )
					lcArea = upper( alltrim( loItem.Area ) )
					llCondicionArea = loColResultados[ lcArea ].Resultado
					if !llCondicionArea 
						llCondicion = .f.
					else				
						if empty( loItem.Condicion ) 
							llCondicion = .t.
						else
							with toEntidad
								llCondicion = evaluate( alltrim( loItem.Condicion ) )				
							endwith
						endif
					endif
					
					if llCondicion 
					else
						for lni = 1 to lnCol
							lcNombreObjetoCrystal = alltrim( loItem.Tipo_PK )+ transform(loItem.nroItem) + "Col" + transform( lnCol )
							loObjetoCrystal = .ObtenerObjetoCrystal( loReporte, lcNombreObjetoCrystal )
							loObjetoCrystal.suppress = .T.
							lnPP = lnPP + 1
						endfor
						lnPP = lnPP - 1
					endif
				endif
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreObjetoCrystal( toAtributo as Object, tnColumna as Integer  ) as string

		return alltrim( toAtributo.tipo_Pk ) + transform( toAtributo.NroItem + tnColumna  )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoCrystal( toReporte as Object, tcNombreObjetoCrystal as String ) as object

		local loArea as Object, loSection as Object, loItem as Object, llEncontrado as Boolean, loRetorno as Object
		llEncontrado = .F.

		for each loArea in toReporte.Areas			
			for each loSection in loArea.Sections
				for each loItem in loSection.ReportObjects
					if loItem.kind = 5
						loRetorno = this.ObtenerObjetoCrystal( loItem.openSubReport(), tcNombreObjetoCrystal )
						if vartype( loRetorno ) = "O"
							llEncontrado = .T.
						endif
					else
						if upper( alltrim( loItem.name )) == upper( alltrim( tcNombreObjetoCrystal ))
							loRetorno = loItem
							llEncontrado = .T.
							exit
						endif
					endif
				endfor
				if llEncontrado 
					exit
				endif
			endfor
			if llEncontrado 
				exit
			endif
		endfor
	
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreCampo( toItem as Object, tnColumna as Integer ) as String
		return "c_" + transform( tnColumna )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTabla( toArea as Object, tnCodigo as Integer ) as string
		local lcRetorno as String, lcCodigo as String 
		lcCodigo =  alltrim( transform( tnCodigo ) )
		if toArea.EsDet
			lcRetorno = lcCodigo + "_" + alltrim( toArea.Area ) + ".dbf"
		else
			lcRetorno = lcCodigo + "Cabecera.dbf"
		endif
		
		return strtran( lcRetorno ," ", "_" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AbrirReporte( tcReporte as String ) as Object
		local loApp as Object, loReporte as Object
		loApp =  createobject( 'CrystalRuntime.Application.11' )
		loReporte = loApp.OpenReport( tcReporte )
		loApp = Null
		return loReporte
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SalidaDiseno( tcReporte as String, tcCaption as String, tlForzarVistaPrevia as Boolean, tlForzarpredeterminada as Boolean) as VOID
		local loApp as Object, loReporte as Object, lcArchivo as String	
	
		try
			loReporte = This.AbrirReporte( tcReporte )
			loReporte.Database.Verify()
	
			if ( (pemstatus( _screen,"lUsaServicioRest", 5 ) and _Screen.lUsaServicioRest) or tlForzarpredeterminada )
				this.SalidaPorImpresora( loReporte ) 
			else
				do case
					case inlist( this.oDisenoImpresion.OpcionDeSalida, 0, 1 ) or tlForzarVistaPrevia && Vista previa. (0) Para que siga funcionando como antes sin la necesidad de inicializar a 1 en los diseños ya existentes.
						if this.verificaTamañoHoja() 
							this.OcultarSeccionDeLeyendaEImagenesDelAreaPie( loReporte )
						endif
						this.MostrarVistaPrevia( loReporte, tcCaption )
					case this.oDisenoImpresion.SeImprimePorControladorFiscal() && Controlador fiscal
						lcArchivo = this.GenerarArchivoEnDisco( loReporte, 8, this.Class + "." + alltrim( this.oDisenoImpresion.Codigo ) + ".txt" )
						this.oLineasAEnviarAControladorFiscal = this.ObtenerLineasAEnviarAControladorFiscal( lcArchivo )
						this.PersistirLineasAEnviarAControladorFiscal( lcArchivo )
						this.EnviarImpresionAControladorFiscal()
					case inlist( this.oDisenoImpresion.OpcionDeSalida, 5 ) 

						if this.PuertoDisponible()
							this.SalidaPorPuerto( loReporte ) && Impresión directo a puerto
						else
							goServicios.Errores.LevantarExcepcion( "El puerto "+alltrim( this.oDisenoImpresion.Puerto )+" no se encuentra disponible." )	
						endif	
					otherwise
						&& Impresora Predeterminada == 2
						&& Selección de Impresora == 3
						this.SalidaPorImpresora( loReporte ) 
				endcase
			endif

		Catch To loError
			loError.message = This.TransformarMensajeError( loError.details )
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loReporte = null
		EndTry

	endfunc

	*-----------------------------------------------------------------------------------------
	function OcultarSeccionDeLeyendaEImagenesDelAreaPie( toReporte as Object ) as Void
		toReporte.Areas("PF").Sections.Item[ 1 ].Suppress = .T.
	endfunc 


	*-----------------------------------------------------------------------------------------
	function TransformarMensajeError( tcMensaje as String) as String
		local lcRetorno as String

		lcRetorno = ""
		if ( " sobrepasan el tamaño de esta página. ." ) $ tcMensaje			
			lcRetorno = "El tamaño del diseño de impresión seleccionado supera el tamaño de página de la impresora indicada."
		endif
		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PuertoDisponible() as Boolean
		local llRetorno as Boolean, lcPuerto as String, lnHandel as Integer 
		llRetorno = .f.
		if empty( this.oDisenoImpresion.Puerto )
			lcPuerto = upper( alltrim( goParametros.Felino.Impresiones.ImpresionDirectaAPuerto ))
		else
			lcPuerto = upper( alltrim( this.oDisenoImpresion.Puerto ))
		endif 
		
		lnHandel = this.AbrirPuerto( lcPuerto )
		if lnHandel > 0
			=fclose( lnHandel )
			llRetorno = .t.
		endif 
		
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambiarCantidadParaImpresionAPuerto( tcContenido ) as String
		local lcExpresion as String, lnHayCantidad as Integer, lcdivisor as String, lcCambio as String 
		lcExpresion = tcContenido
		lnHayCantidad = at( ".CANTIDAD",upper( lcExpresion ) )
		lcdivisor = alltrim( str( max( this.oDisenoImpresion.Columnas , 1) ) )
		if lnHayCantidad>0
			lcCambio = upper( substr( lcExpresion,lnHayCantidad ) )
			if this.oColumnaNumerarPorCombinacion.Count > 0
				lcCambio = strtran( lcCambio,".CANTIDAD","1" ) && Siempre se debera imprimir de 1 etiqueta.
			else
				lcCambio = strtran( lcCambio,".CANTIDAD","ceiling(.CANTIDAD/"+lcdivisor+")" )
			endif
			lcExpresion = substr( lcExpresion, 1, lnHayCantidad-1 ) + lcCambio
		endif
		return lcExpresion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirPuerto( tcPuerto ) as Integer
		local lHandle as Integer
		lHandle = -1
		if left( upper( tcPuerto ), 3 ) == "COM"
			lHandle = fopen( tcPuerto, 1 )
		else
			lHandle = fcreate( tcPuerto )
		endif 
		return lHandle
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarAPuerto( tcPuerto, tcTexto ) as Boolean
		local llRetorno as Boolean, lnHandle as Integer 
		tcPuerto = alltrim( tcPuerto )
		lnHandle = this.AbrirPuerto( tcPuerto )
		if lnHandle>0
			=fwrite( lnHandle,tcTexto )
			=fclose( lnHandle )
			llRetorno = .t.
		else
			goServicios.Errores.LevantarExcepcion( "El puerto predeterminado "+tcPuerto+" no se encuentra disponible." )
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Esperar( tnSegundos as Integer ) as Void
		local lnMilisegundos as Integer 
		
		DECLARE Sleep IN Win32API INTEGER nMilliseconds
		
		lnMilisegundos = tnSegundos * 1000
		=sleep( lnMilisegundos )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SalidaPorPuerto( toReporte as Object ) as Void
		local lcdbf as String, lcTexto as String, lcPuerto as String 
		local array laCampos(1,1)

		if empty( alltrim( this.oDisenoImpresion.Puerto )) or upper(alltrim( this.oDisenoImpresion.Puerto )) == "DEFAULT"
			lcPuerto = goParametros.Felino.Impresiones.ImpresionDirectaAPuerto
		else 
			lcPuerto = upper(alltrim( this.oDisenoImpresion.Puerto))
		endif 
		
		try
			lcdbf = toReporte.Database.Tables(1).ConnectionProperties.Item("Data Source").value
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
		use &lcdbf in 0 alias tempimpr again
		select tempimpr
		=afields(laCampos)

		lnTotal = alen(laCampos,1) - 1 && por campo cantidad
		scan
			lcTexto = ""
			for fct=1 to lnTotal
				lColumna = laCampos(fct,1)
				lcTexto = lcTexto + alltrim( &lColumna. ) +chr(13)+chr(10)
			endfor
			lcTexto = chr(13)+chr(10)+lcTexto+chr(13)+chr(10)
			*=strtofile( lcTexto, "outport.txt", iif( recno()=1, 0, 1 ) )
			this.EnviarAPuerto( lcPuerto, lcTexto )
			this.Esperar( this.oDisenoImpresion.Segundos*val(alltrim(zcantidad)) )
		endscan
		use 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConfirmarImpresion( tcTipoDeSalida as String, toEntidad as Object ) as Boolean
		local llRetorno as Boolean, lnImprimir as Boolean, lnRespuestaSugerida as Integer, lnSolicitarConfirmacion as Integer,;
			  lcMensaje as String
			  
		llRetorno = .t.
		lnImprimir = 1
		toEntidad.lConfirmarImpresion = 0
		lnSolicitarConfirmacion = this.ObtenerValorDeConfirmacionDeSalida( tcTipoDeSalida )
	
		if lnSolicitarConfirmacion > 0 
			lnRespuestaSugerida = max( lnSolicitarConfirmacion - 1, 0 )
			if empty( This.cDescripPregunta )
				lcMensaje = "¿Confirma la salida a " + lower( tcTipoDeSalida ) + " de " + alltrim( .oDisenoImpresion.Descripcion ) + "?"
			else	
				lcMensaje = "¿Confirma la salida a " + lower( tcTipoDeSalida ) + " de " +	alltrim( This.cDescripPregunta ) + space(1) + "( Diseño: " +alltrim( .oDisenoImpresion.Codigo ) + " )?"
			endif
			
			toEntidad.PreguntarConfirmacionImpresion( lcMensaje, 1, lnRespuestaSugerida )
			lnImprimir = toEntidad.lConfirmarImpresion
				
		endif
		
		llRetorno = ( lnImprimir = 1 )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorDeConfirmacionDeSalida( tcTipoDeSalida as String ) as Integer
		local lnRetorno as Integer
		if tcTipoDeSalida = DEF_SALIDA_A_PDF
			lnRetorno = this.oDisenoImpresion.ConfirmaPdf
		else
			lnRetorno = this.oDisenoImpresion.Sugiere
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function MostrarVistaPrevia( toReporte as Object, tcCaption as String ) as Void
		local loForm as Object
		
		this.SetearImpresoraAReporte( toReporte, this.ObtenerImpresoraPreferente() )
		loForm = _screen.zoo.crearobjeto( "FormVisualizacionReportes" )
		with loForm
			.caption = tcCaption
			with .Visor
				.ReportSource = toReporte
				.ViewReport()
			endwith
			.SetearVisor()
			.show( 1 )
		endwith
		loForm = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SalidaPorImpresora( toReporte as Object ) as Void
		local lnCantidadDeCopias as Integer, lnI as Integer, lcImpresoraPredeterminada as String
		lcImpresoraPredeterminada = SET("Printer",2)		
		try
			this.SetearImpresora( toReporte )
		
			lnCantidadDeCopias = max( this.oDisenoImpresion.CantidadCopias, 1 )
			for lnI = 1 to lnCantidadDeCopias
				toReporte.PrintOut( .f. )
			endfor
		finally
			this.SetearImpresoraPredeterminada( lcImpresoraPredeterminada ) 
		endtry	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearImpresora( toReporte as Object ) as Void
		local lcImpresora as String
		
		do case
			case this.oDisenoImpresion.OpcionDeSalida == 2 or ( pemstatus( _screen,"lUsaServicioRest", 5 ) and _Screen.lUsaServicioRest )
				*!* Impresora predeterminada.
				if !empty( this.cImpresoraForzada )
					lcImpresora = alltrim( this.cImpresoraForzada )
				else
					lcImpresora = this.ObtenerImpresoraPredeterminada()
				endif
			case this.oDisenoImpresion.OpcionDeSalida == 3
				*!* Cuadro de dialogo de impresoras. (OpcionDeSalida == 3)
				lcImpresora = this.ObtenerImpresoraDesdeCuadroDeDialogo()
			otherwise
				lcImpresora = this.ObtenerNombreImpresoraDePuesto()
				lcImpresora = this.ValidarImpresoraDePuesto( lcImpresora )
		endcase
		if empty( lcImpresora )
			goServicios.Errores.LevantarExcepcion( "No se seleccionó ninguna impresora." )
		endif

		this.SetearImpresoraAReporte( toReporte, lcImpresora )

		if this.oDisenoImpresion.OpcionDeSalida == 3 && Seleccion de Impresora.
			try
				this.SetearImpresoraPredeterminada( lcImpresora )	
				if prtinfo(2) == -1 		  && Custom paper size
					toReporte.PaperSize = 256 && Custom paper size
					toReporte.SetUserPaperSize( prtinfo(3), prtinfo(4) ) && length and width
				else
					toReporte.PaperSize = prtinfo( 2 ) 
				endif
			catch to loError
				toReporte.PaperSize = 256 				 && Custom paper size
				toReporte.SetUserPaperSize( 2100, 2800 ) && A4 => length and width
			endtry
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreImpresoraDePuesto() as String
		local lcRetorno as String
		
		lcRetorno = ""
		do case
			case this.oDisenoImpresion.OpcionDeSalida == 6
				lcRetorno = alltrim( goparametros.felino.impresiones.impresoradepuestonumero1 )
			case this.oDisenoImpresion.OpcionDeSalida == 7
				lcRetorno = alltrim( goparametros.felino.impresiones.impresoradepuestonumero2 )
			case this.oDisenoImpresion.OpcionDeSalida == 8
				lcRetorno = alltrim( goparametros.felino.impresiones.impresoradepuestonumero3 )
		endcase		
		if empty( lcRetorno )
			lcRetorno = this.ObtenerImpresoraPredeterminada()
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarImpresoraDePuesto( tcImpresora as Boolean ) as String
		local lcRetorno as String, lnPosicion as Integer, llOk as Boolean
		
		lcRetorno = tcImpresora 
		
		=aprinters( laListaDeImpresoras, 1 )
		lnPosicion = ascan( laListaDeImpresoras, tcImpresora, 1, alen( laListaDeImpresoras, 1 ), 1, 1 + 8 )
		llOk = lnPosicion>0
	
		if !llOk
			* Ahora antes de buscar la predeterminada, intento buscar la mas similar
			lcRetorno = this.ObtenerImpresoraMasSimilar( tcImpresora )
			
			if empty( lcRetorno  )		
				lcRetorno = this.ObtenerImpresoraPredeterminada()
			endif
		endif
		
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearImpresoraAReporte( toReporte as Object, tcImpresora as String ) as Void
		local array laListaDeImpresoras[ 1 ]
		local lnPosicion as Integer, lcPuerto as string, lcDriver as String, loError as Exception
		try 
			=aprinters( laListaDeImpresoras, 1 )
			lnPosicion = ascan( laListaDeImpresoras, tcImpresora, 1, alen( laListaDeImpresoras, 1 ), 1, 1 + 8 )
			if lnPosicion>0
				lcPuerto = laListaDeImpresoras[ lnPosicion, 2 ]
				lcDriver = laListaDeImpresoras[ lnPosicion, 3 ]
				toReporte.SelectPrinter( lcDriver, tcImpresora, lcPuerto )
			else
				goservicios.Errores.LevantarExcepciontexto( "La impresora a setear en el reporte no existe" )
			endif
		catch to loError
			goservicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearImpresoraPredeterminada( tcImpresora as string ) as Void
		local lcImpresoraDefault as String
		if !empty( tcImpresora )
			* seteo en Fox
			try
				set printer to name ( tcImpresora )				
				* seteo en Windows técnica UNO.
				this.SetearImpresoraPredeterminadaTecnicaUno( tcImpresora )
				lcImpresoraDefault = this.ObtenerImpresoraPredeterminada()
				catch to loError
					lcMsgError = "Error al intentar acceder a la impresora ó existen problemas con el servicio 'cola de impresión'." 
				&&  Como este metodo puede ser llamado 3 veces para las distintas etapas, reviso que el error ya no haya sido informado previamente
				if !this.InformacionDuplicada( this, lcMsgError )
					.AgregarInformacion( lcMsgError )
					*goMensajes.advertir( lcMsgError, 0 )
					lcMsgError = lcMsgError + chr(13) + chr(10) + "Mensaje: " + loError.Message
					loLog = goServicios.Logueos.ObtenerObjetoLogueo( This )
					loLog.Escribir( lcMsgError )
					goServicios.Logueos.guardar( loLog )
				endif
				*goServicios.Errores.LevantarExcepcion( loError )
			endtry
			
			if upper( alltrim( lcImpresoraDefault ) ) == upper( alltrim( tcImpresora ) )
				return
			else
				*!* seteo en Windows técnica DOS.
				local lobjWMI as Object, lobjImp as Object, lobjPrinter	as Object
				lobjWMI = GetObject("winmgmts:\\")
				lobjImp = lobjWMI.ExecQuery( "Select * from Win32_Printer" )

				for each lobjPrinter in lobjImp foxObject
			    	if upper( alltrim( lobjPrinter.Name ) ) == upper( alltrim( tcImpresora ) )
				    	lobjPrinter.SetDefaultPrinter
					EndIf
				endfor
				
				lcImpresoraDefault = this.ObtenerImpresoraPredeterminada()
				if upper( alltrim( lcImpresoraDefault ) ) == upper( alltrim( tcImpresora ) )
					return
				else
					*!* seteo en Windows técnica TRES.
					Declare long WriteProfileString in "kernel32" string lpszSection, string lpszKeyName, string lpszString
					= WriteProfileString( 'windows','device', tcImpresora )
					clear dlls "WriteProfileString"
				endif		
			endif
			
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Protected Function SetearImpresoraPredeterminadaTecnicaUno( tcPrinter As String ) As Void
		Local loWSHNetwork As "WScript.Network"
		loWSHNetwork = Null
		try	
			loWSHNetwork = Createobject( "WScript.Network" )
			loWSHNetwork.SetDefaultPrinter( tcPrinter )
			Set Printer To Name ( tcPrinter )
		catch
			&& no informa
		finally
			loWSHNetwork = Null
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerImpresoraPredeterminada() as String
		local lcImpresora as String, lnTamanioBuffer as Integer
		lcImpresora = ""
		if _Screen.Zoo.App.lEsEntornoCloud and !empty( this.cImpresoraPredeterminada )
			lcImpresora = this.cImpresoraPredeterminada
		else
			declare integer GetDefaultPrinter ;
	    		in winspool.drv ;
	    		string  @pszBuffer,;
	    		integer @pcchBuffer

			lnTamanioBuffer = 250
			lcImpresora = replicate( chr( 0 ), lnTamanioBuffer )
			=GetDefaultPrinter( @lcImpresora, @lnTamanioBuffer )
			lcImpresora = substr( lcImpresora, 1, at( Chr( 0 ), lcImpresora ) -1 )
			if _Screen.Zoo.App.lEsEntornoCloud
				this.cImpresoraPredeterminada = lcImpresora
			endif
		endif
		
		return lcImpresora
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerImpresoraDesdeCuadroDeDialogo() as String
		return getprinter()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as VOID
		if type( "this.oDisenoImpresion" ) = "O" and !isnull( this.oDisenoImpresion )
			this.oDisenoImpresion.release()
		endif
		this.oEntidadImprimir = null
		this.oComprobantes = null
		This.oColaboradorParametros = null
		if ( vartype( this.oEntidades ) = 'O' and !isnull( this.oEntidades ) ) 
			This.oEntidades.release()
		endif		
		
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaRepositorio() as String
		local lcRetorno as String

		lcRetorno = addbs( alltrim( goRegistry.Nucleo.RutaDeDisenos ) )
		if substr( lcRetorno, 2, 2 ) == ":\"
		else
			if left( lcRetorno, 1 ) == "\"
				lcRetorno = alltrim( substr( lcRetorno, 2 ) )
			endif
			lcRetorno = addbs( alltrim( _screen.zoo.cRutaInicial ) + lcRetorno )
		endif
		if directory( lcRetorno )
		else
			md ( lcRetorno )
		endif
		return lcRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreReporte( toDiseno as entidad OF entidad.prg ) as String 
		local lcNombre as String, lcFechaModif as String, lcHoraModif as String

		lcFechaModif = transform( year( toDiseno.FechaModificacionFw ) * 10000 + month( toDiseno.FechaModificacionFw ) * 100 + day( toDiseno.FechaModificacionFw ) )
		lcHoraModif = strtran( toDiseno.HoraModificacionFw, ":", "" )
		lcNombre = alltrim( transform( toDiseno.Codigo ) ) + "_" + lcFechaModif + "_" + lcHoraModif
		return lcNombre
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeImprimirDisenosAutomaticamente( toEntidad as entidad of entidad.prg ) as boolean
		return this.DebeEjecutarDisenosDeSalidaAutomaticamente( toEntidad, DEF_SALIDA_A_IMPRESORA )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeGenerarPDFsDeDisenosAutomaticamente( toEntidad as entidad of entidad.prg ) as boolean
		return this.DebeEjecutarDisenosDeSalidaAutomaticamente( toEntidad, DEF_SALIDA_A_PDF )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeEjecutarDisenosDeSalidaAutomaticamente( toEntidad as entidad of entidad.prg, tcTipoDeSalida as String ) as boolean
		local llRetorno as Boolean, lcCursor as String, lcXml as String, lcEntidad as String, lcDisenos
		lcCursor = sys( 2015 )		
		lcEntidad = upper( toEntidad.ObtenerNombre() ) 
		llRetorno = toEntidad.EsNuevo() or this.lEsValeDeCambio or this.lEsUnTiquetDeCambio 	&&or this.EsComprobanteElectronico( toEntidad )
		this.colDisenosAutomaticosEntidad.remove(-1)
		if llRetorno
			this.CargarDisenosAutomaticos( .f. )
			lcDisenos = this.ObtenerDisenosDeUnaEntidad( lcEntidad, tcTipoDeSalida, .t. )
			if empty( lcDisenos )
				llRetorno = .f.
			else
				select Codigo, Condicion ;
					from ( this.cCursorDisenosAutomaticos ) ;
					where codigo in ( &lcDisenos );
				into cursor &lcCursor

				lcXml = this.CursorAXML( lcCursor )
				if !empty( lcXml )
					lcXml = this.ObtenerDisenosSegunCondicion( toEntidad, lcXml )
					this.XmlACursor( lcXml, lcCursor )
				endif
				
				llRetorno = reccount( lcCursor ) > 0
				if llRetorno
					select (lcCursor)
					scan
						this.colDisenosAutomaticosEntidad.add( &lcCursor..Codigo )
					endscan
				endif 
				use in ( lcCursor )
			endif
		Endif

		return llRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarDisenosAutomaticos( tlForzarCarga as Boolean ) as Void
		local lcXml as String, lcCondicion as String
		if tlForzarCarga or !( this.cBaseDeDatos == _screen.zoo.app.cSucursalActiva )
			lcCondicion = " ( ImpresionAutomatica = .T. AND HabilitaSalidaAImpresora = .T. ) OR ( PdfAutomatico = .T. AND HabilitaSalidaAPdf = .T. )"
			lcXml = This.oDisenoImpresion.oAD.ObtenerDatosEntidad( "Codigo, Entidad, ImpresionAutomatica, Condicion, HabilitaSalidaAImpresora, HabilitaSalidaAPdf", lcCondicion )
			this.XMLACursor( lcXml, this.cCursorDisenosAutomaticos )	
			this.cBaseDeDatos = _screen.zoo.app.cSucursalActiva
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ImprimirDisenosAutomaticos( toEntidad as entidad OF entidad.prg ) as Void
		local llRetorno as Boolean, lcCursor as String, llImprimir as Boolean, lcMensaje as String, lcReporte as String   
		llRetorno = .t.
		llImprimir = .t.
		lcMensaje = ""
		lcReporte = ""

		for lnI = 1 to this.colDisenosAutomaticosEntidad.count
			lcReporte = this.colDisenosAutomaticosEntidad.item( lni )
			if this.EsUnReporteDeEtiquetas( lcReporte )
				if this.TieneModuloEtiquetaHabilitado()	
				else
					llImprimir = .f.
					lcMensaje = lcMensaje + "El reporte '" + alltrim( lcReporte ) + "' no se puede imprimir porque requiere el módulo de Impresión de Etiquetas." + chr(10) 
				endif
			endif	
			if llImprimir
				llRetorno = this.ImprimirDiseno( lcReporte )
			endif	
			llImprimir = .t.
		
		endfor 
		
		if !empty( lcMensaje )
			toEntidad.omensaje.Advertir(lcmensaje)
		endif 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsCodigoDeBarra( toArea as Object ) as Object 
		local loRetorno as Object, loError as Exception 
		loRetorno = createobject( "custom" )
		addproperty( loRetorno, "lUsaCB", .f. )
		addproperty( loRetorno, "cDelimitador", "" )
		if !empty( toArea.estilo_pk )
			if vartype( this.oEstilo ) != "O"
				this.oEstilo = _screen.zoo.instanciarentidad( "estiloimpresion" )
			endif
			try
				this.oEstilo.Codigo = toArea.estilo_pk
				loRetorno.lUsaCB = this.oEstilo.EsCodBarra
				loRetorno.cDelimitador = this.oEstilo.Delimitador
			catch
				
			endtry 
		endif 
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Funcionalidades_Access() as variant
		
		if !this.ldestroy and ( !vartype( this.Funcionalidades ) = 'O' or isnull( this.Funcionalidades ) )
			This.CargarFuncionalidades()
		endif
		return this.Funcionalidades

	endfunc 

	*-----------------------------------------------------------------------------------------
	function colVariablesDeReporte_Access() as variant
		
		if !this.ldestroy and ( !vartype( this.colVariablesDeReporte ) = 'O' or isnull( this.colVariablesDeReporte ) )
			this.colVariablesDeReporte = _Screen.Zoo.CrearObjeto( "zooColeccion" )
			this.AgregarVariableDeReporte( "TOTALDEPAGINAS", "9" )
			this.AgregarVariableDeReporte( "NUMERODEPAGINA", "7" )
			this.AgregarVariableDeReporte( "PAGINAXDEY", "17" )
		endif
		return this.colVariablesDeReporte 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function oComprobantes_Access() as Object
		if !this.ldestroy and ( !vartype( this.oComprobantes ) = 'O' or isnull( this.oComprobantes ) )
			this.oComprobantes = newobject( "din_comprobante", "din_comprobante.prg" )
		endif
		return this.oComprobantes
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarVariableDeReporte( tcNombreOrganic as String ) as Boolean
		return this.colVariablesDeReporte.Buscar( upper( alltrim( tcNombreOrganic ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoVariableDeReporte( tcNombreOrganic as String ) as Object
		return this.colVariablesDeReporte.Item[ upper( alltrim( tcNombreOrganic ) ) ]
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarVariableDeReporte( tcNombreOrganic as String, tcNombreCrystal as String ) as Void
		local loVariableDeReporte as Object

		loVariableDeReporte  = _Screen.Zoo.CrearObjeto( "ObjetoVariableDeReporte" ,"ManagerImpresion.prg" )
		loVariableDeReporte.NombreOrganic = tcNombreOrganic 
		loVariableDeReporte.NombreCrystal = tcNombreCrystal 
		this.colVariablesDeReporte.Agregar( loVariableDeReporte,  upper( alltrim( tcNombreOrganic ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarFuncionalidades() as VOID 
		local lcProyecto as String,  loError as zooexception OF zooexception.prg 
		lcProyecto = "FuncionesImpresion"

		if file( lcProyecto + alltrim( _screen.zoo.app.cProyecto ) +".prg") or file( lcProyecto + alltrim( _screen.zoo.app.cProyecto ) + ".fxp")
			lcProyecto = lcProyecto + alltrim( _screen.zoo.app.cProyecto )  
		else
			if upper( alltrim( _screen.zoo.app.ParentClass )) = "APLICACIONFELINO"
				lcProyecto = "FuncionesImpresionFelino"
			endif   	
		endif
		try
			this.Funcionalidades = this.crearObjeto( lcProyecto ) 
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		EndTry

	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarChecksum( tcString as String ) as String 

      local lcStart, lcStop, lcRet, lcCheck, lnLong, lnI, lnCheckSum, lnAsc

	  tcString = STRTRAN(tcString,"Ñ","#")
	  tcString = STRTRAN(tcString,"ñ","&")

      lcStart = chr(104 + 32)
      lcStop = chr(106 + 32)
      lnCheckSum = asc(lcStart) - 32
      lcRet = tcString
      lnLong = len(lcRet)

      for lnI = 1 to lnLong
            lnAsc = asc( subs( lcRet, lnI, 01 ) ) - 32

            if !between(lnAsc,0,99)
                  lcRet = STUFF(lcRet,lnI,1,CHR(32))
                  lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
            ENDIF

            lnCheckSum = lnCheckSum + (lnAsc * lnI)
            
      ENDFOR
	  	lcCheck = CHR(MOD(lnCheckSum,103) + 32)
      lcRet = lcStart + lcRet + lcCheck + lcStop

      *--- Esto es para cambiar los espacios y caracteres inválidos
      lcRet = STRTRAN(lcRet,CHR(32),CHR(232))
      lcRet = STRTRAN(lcRet,CHR(127),CHR(192))
      lcRet = STRTRAN(lcRet,CHR(128),CHR(193))
      lcRet = STRTRAN(lcRet,CHR(129),CHR(194))
      RETURN lcRet

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDetalleDelArea( toDatos as Object, toEntidad as entidad OF entidad.prg ) as String 
		local lcRetorno as String, lnI as Integer, lcContenido as String  
		lcRetorno = ""
        
		if  ( todatos.cTipoArea = this.cTipoAreaEtiquetaDeArticulo )
			for lnI = 1 to toDatos.oAtributos.Count
				lcContenido = alltrim( upper( toDatos.oAtributos[ lnI ].contenido ) )
				if this.cDetalleEtiquetaDeArticulo $ lcContenido && or this.cFuncionCodigoDeBarra $ lcContenido
					lcRetorno = this.cDetalleEtiquetaDeArticulo
					exit for
				Endif
			endfor
		endif

		if empty( lcRetorno )
			for lnI = 1 to toDatos.oAtributos.Count
				
               
                if "IIF" $ upper( toDatos.oAtributos[ lnI ].contenido )
                    with toEntidad
                        lcContenido = toDatos.oAtributos[ lnI ].contenido
                        lcContenido = &lcContenido
                    endwith
                else
                    lcContenido = this.analizarcontenidoatributos( toDatos.oAtributos[ lnI ].contenido )    
                endif
      
                if occurs( ".",  lcContenido ) > 1
					if occurs('#%',lcContenido  ) = 2
						lcContenido = getwordnum( lcContenido , 2, "." ) 
					else
						lcContenido = getwordnum( lcContenido , 1, "." ) 
					endif
					if vartype( toEntidad.&lcContenido ) = "U"
						this.agregarInformacion( "El atributo " + lcContenido  + " no existe." )
					else				
						if vartype( toEntidad.&lcContenido..oItem ) = "O"
							lcRetorno = "." + lcContenido
						endif
					endif
					exit
				endif

			endfor  
		Endif		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDisenosSegunCondicion( toEntidad as entidad OF entidad.prg,  tcXml as String ) as String
		local lcCursor as String, lcXml as String

		lcCursor = sys( 2015 )
		this.XMLaCursor( tcXml, lcCursor )
		select ( lcCursor )
		scan
			if !this.CumpleCondicionDeImpresion( toEntidad, &lcCursor..Condicion, &lcCursor..Codigo )
				delete in ( lcCursor )
			endif
		endscan
		
		lcXml = this.CursorAXml( lcCursor )
		use in select ( lcCursor )
		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CumpleCondicionDeImpresion( toEntidad as entidad OF entidad.prg, tcExpresion as String, tcCodigoDiseno as String  ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcMsgError as String, lcExpresion as string, loLog as Object, lcCursor as String

		llRetorno = .f.
		lcExpresion = alltrim( nvl( tcExpresion, "" ) ) 
		with toEntidad	
			try
				if empty( lcExpresion )
					llRetorno = .t.
				else
					llRetorno = &lcExpresion
				endif
			catch to loError				
				lcMsgError = "Error al evaluar el campo condición del diseño de impresión " +  alltrim( tcCodigoDiseno ) +"."
				&&  Como este metodo puede ser llamado 3 veces para las distintas etapas, reviso que el error ya no haya sido informado previamente
				if !this.InformacionDuplicada( toEntidad, lcMsgError )
					.AgregarInformacion( lcMsgError )
					*goMensajes.advertir( lcMsgError, 0 )
					lcMsgError = lcMsgError + chr(13) + chr(10) + "Mensaje: " + loError.Message
					loLog = goServicios.Logueos.ObtenerObjetoLogueo( This )
					loLog.Escribir( lcMsgError )
					goServicios.Logueos.guardar( loLog )
				endif
			endtry
		endwith		
		return llRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InformacionDuplicada( toEntidad as entidad OF entidad.prg, tcMensaje as String ) as Boolean
		local llRetorno as Boolean, loInformacion as Object, loMensaje as Object
		
		llRetorno = .F.
		loInformacion = toEntidad.obtenerinformacion()
		with loInformacion
			if .hayInformacion()
				for each loMensaje in loInformacion
					if loMensaje.cMensaje == tcMensaje
						llRetorno = .T.
					endif
				endfor
			endif			
		endwith
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivoEnDisco( toReporte as Object, tnFormato as Integer, tcNombre as String ) as String
		local lcRetorno as String

		lcRetorno = addbs( _Screen.Zoo.ObtenerRutaTemporal() ) + tcNombre
		toReporte.ExportOptions.FormatType = tnFormato
		toReporte.ExportOptions.DestinationType = 1  && crEDTDiskFile
		toReporte.ExportOptions.DiskFileName = lcRetorno
		
		if file( lcRetorno )
			delete file ( lcRetorno )
		endif

		toReporte.Export( .f. )
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerLineasAEnviarAControladorFiscal( tcArchivo as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loStreamReader as Object, lcLinea as String, loEncoding as Object
		loRetorno = this.CrearObjeto( "ZooColeccion" )
		loStreamReader = null
		
		try
			loEncoding = _screen.zoo.obtenervalorpropiedadestatica( "System.Text.Encoding", "Default" )
			loStreamReader = _Screen.Zoo.CrearObjeto( "System.IO.StreamReader", "", tcArchivo, loEncoding )
			lcLinea = loStreamReader.ReadLine()
			do while !isnull( lcLinea )

				if empty( lcLinea )
				else
					if "<LINEAENBLANCO>" == upper( alltrim( lcLinea ) )
						loRetorno.Agregar( "" )
					else
						loRetorno.Agregar( lcLinea )
					endif
				endif
				
				lcLinea = loStreamReader.ReadLine()
			enddo
		finally
			if !isnull( loStreamReader )
				loStreamReader.Close()
			endif
		endtry
		if loRetorno.Count > 0
			do while empty( loRetorno.Item( loRetorno.Count ) )
				loRetorno.Quitar( loRetorno.Count )
			enddo
		endif

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EnviarImpresionAControladorFiscal() as void
		local llRetorno as Boolean, loInformacion as zoocoleccion OF zoocoleccion.prg,  lnI as Integer, lnCantidadDeCopias as integer
		if vartype( goControladorFiscal ) = "O" and !isnull( goControladorFiscal )
		else
			goServicios.Errores.LevantarExcepcion( "El servicio del Controlador Fiscal no se inicializó correctamente, verifique la configuración del mismo en Parámetros del sistema > Controladores Fiscales." )
		endif
		lnCantidadDeCopias = max( this.oDisenoImpresion.CantidadCopias, 1 )
			for lnI = 1 to lnCantidadDeCopias
				llRetorno = goControladorFiscal.ImprimirComprobanteNoFiscal( this.oLineasAEnviarAControladorFiscal )
			endfor
		
		loInformacion = goControladorFiscal.ObtenerInformacion()
		if loInformacion.Count > 0
			goServicios.Errores.LevantarExcepcion( loInformacion )
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTxtParaVistaPreviaDeSalidaPorControladorFiscal( tcCodigoDiseno as String ) as String
		local lcReporte as String, loReporte as Object, lcArchivo as String

		lcReporte = ""
		this.oDisenoImpresion.Codigo = tcCodigoDiseno
		lcReporte = this.oDisenoImpresion.GenerarImpresion()
		loReporte = This.AbrirReporte( lcReporte )
		loReporte.Database.Verify()

		lcArchivo = this.GenerarArchivoEnDisco( loReporte, 8, this.Class + "." + alltrim( this.oDisenoImpresion.Codigo ) + ".txt" )
		this.oLineasAEnviarAControladorFiscal = this.ObtenerLineasAEnviarAControladorFiscal( lcArchivo )
		this.PersistirLineasAEnviarAControladorFiscal( lcArchivo )
		
		return lcArchivo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function PersistirLineasAEnviarAControladorFiscal( tcArchivo as String ) as Void
		local loEncoding as Object, loStreamWriter as Object, lcLinea as String
		loStreamWriter = null
		loEncoding = _screen.zoo.obtenervalorpropiedadestatica( "System.Text.Encoding", "Default" )
		try
			loStreamWriter = _Screen.Zoo.CrearObjeto( "System.IO.StreamWriter", "", tcArchivo, .f., loEncoding )
			for each lcLinea in this.oLineasAEnviarAControladorFiscal
				loStreamWriter.WriteLine( lcLinea )
			endfor
		finally
			if !isnull( loStreamWriter )
				loStreamWriter.Close()
			endif
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarPDFsAlGrabarEntidad( toEntidad as entidad OF entidad.prg ) as zoocoleccion OF zoocoleccion.prg
		return this.GenerarPDFs( toEntidad, .f., .t., .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPDFsAlEnviarMail( toEntidad as entidad OF entidad.prg ) as zoocoleccion OF zoocoleccion.prg
		return this.GenerarPDFs( toEntidad, .f., .f., .f. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPDFDesdeMenu( toEntidad as entidad OF entidad.prg ) as zoocoleccion OF zoocoleccion.prg
		return this.GenerarPDFs( toEntidad, .t., .f., .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarPdfSegundoPlano( toEntidad as entidad OF entidad.prg, tcCodigoDisenio as String ) as zoocoleccion OF zoocoleccion.prg
		local loFactory as FactoryAccionEnSegundoPlano of FactoryAccionEnSegundoPlano.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, ;
		loInstruccionesGeneracionPdf as ParametrosInstruccionesGeneracionPdf of ParametrosInstruccionesGeneracionPdf.prg
		
		loFactory = _screen.zoo.CrearObjetoPorProducto( "FactoryAccionEnSegundoPlano" )
		loAccion = loFactory.Obtener( "GeneracionPdf" )
		loInstruccionesGeneracionPdf = _screen.zoo.crearobjeto( "ParametrosInstruccionesGeneracionPdf" )
		loAccion.oParametros.AgregarRango( loInstruccionesGeneracionPdf.Obtener( toEntidad, tcCodigoDisenio ) )
		loAccion.Enviar()
		loFactory.Release()
		loAccion.Release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarPdfTiquetDeCambioSegundoPlano( toEntidad as entidad OF entidad.prg, tcCodigoDisenio as String ) as zoocoleccion OF zoocoleccion.prg
		local loFactory as FactoryAccionEnSegundoPlano of FactoryAccionEnSegundoPlano.prg, loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, ;
			loInstruccionesGeneracionPdf as ParametrosInstruccionesGeneracionPdf of ParametrosInstruccionesGeneracionPdf.prg, ;
			lnCantDetalleTiquet as integer, lnItemTiquet as Integer, lnCantArticuloTiquet as Integer, lnI as Integer, ;
			lcAtributoClavePrimaria as String, lxValorClavePrimaria as Variant

		loFactory = _screen.zoo.CrearObjetoPorProducto( "FactoryAccionEnSegundoPlano" )
		loAccion = loFactory.Obtener( "GeneracionPdfTiquetDeCambio" )
		loInstruccionesGeneracionPdf = _screen.zoo.crearobjeto( "parametrosinstruccionesgenerarpdftiquetdecambio" )

		lcAtributoClavePrimaria = toEntidad.ObtenerAtributoClavePrimaria()
		lxValorClavePrimaria = toEntidad.&lcAtributoClavePrimaria
		toEntidad.&lcAtributoClavePrimaria = lxValorClavePrimaria 
		
		lnCantDetalleTiquet = toEntidad.ObtenerCantidadDeItemsEnDetalle()
		for lnItemTiquet = 1 to lnCantDetalleTiquet
			lnCantArticuloTiquet = toEntidad.ObtenerCantidadDeArticulosEnItem( lnItemTiquet )
			for lnI = 1 to lnCantArticuloTiquet
				loAccion.oParametros.Remove(-1)
				loAccion.oParametros.AgregarRango( loInstruccionesGeneracionPdf.Obtener( toEntidad, tcCodigoDisenio, lnItemTiquet, lnI ) )
				loAccion.Enviar()
			endfor
		endfor
		
		loFactory.Release()
		loAccion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPDFParaComprobanteElectronico( toEntidad as entidad OF entidad.prg ) as zoocoleccion OF zoocoleccion.prg
		return this.GenerarPDFs( toEntidad, .f., .t., .f. )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarPDFparaValeDeCambio( toEntidad as entidad OF entidad.prg ) as zoocoleccion OF zoocoleccion.prg
		this.lEsValeDeCambio = .t.
		this.GenerarPDFs( toEntidad, .f., .t., .t. )
		this.lEsValeDeCambio = .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarPDFparaTiquetDeCambio( toEntidad as entidad OF entidad.prg ) as zoocoleccion OF zoocoleccion.prg
		this.lEsUnTiquetDeCambio = .t.
		this.GenerarPDFs( toEntidad, .f., .t., .t. )
		this.lEsUnTiquetDeCambio = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPDFs( toEntidad as entidad OF entidad.prg, tlMostrarVentanaDeSeleccion as Boolean, tlGeneracionAutomatica as Boolean, tlPedirConfirmaciones as Boolean ) as zoocoleccion OF zoocoleccion.prg
		local lcNombreDiseno as String, lcRutaDiseno as String, lnI as Integer, loColDisenosPdf as zoocoleccion OF zoocoleccion.prg, llProcesar as Boolean, ;
			loInfo as Object, lcPdfGenerado as String, loColPdfsGenerados as zoocoleccion OF zoocoleccion.prg
		external array loColDisenosPdf
		llProcesar = .T.
 
		loColPdfsGenerados = _screen.zoo.crearobjeto( "zooColeccion" )
		this.oEntidadImprimir = toEntidad
		with this
			if .lServicioHabilitado
				if .lProcesando
					llProcesar = .F.
					.AgregarInformacion( "Ya se está generando PDF" )
				else
					if pemstatus( toEntidad, "cDisenoComprobanteAdjunto", 5 ) and toEntidad.cDisenoComprobanteAdjunto != ""
						loColDisenosPdf = _screen.zoo.crearobjeto( "zooColeccion" )
						loColDisenosPdf.Add( toEntidad.cDisenoComprobanteAdjunto ) 
					else
						loColDisenosPdf = This.ObtenerDisenosParaPdf( toEntidad, tlMostrarVentanaDeSeleccion, tlGeneracionAutomatica )
					endif
					
					if loColDisenosPdf.Count = 0
						llProcesar = .F.
					else

						this.cDescripPregunta = this.obtenerDescripPregunta( this.oEntidadImprimir )
						for lnI = 1 to loColDisenosPdf.Count
							lcPdfGenerado = ""
							.oDisenoImpresion.Codigo = loColDisenosPdf[ lnI ]
							if !tlPedirConfirmaciones or .ConfirmarImpresion( DEF_SALIDA_A_PDF, toEntidad  )

								if this.lEsUnTiquetDeCambio
									this.GenerarPdfTiquetDeCambioSegundoPlano( toEntidad, loColDisenosPdf[ lnI ] )
								else
									if ( tlMostrarVentanaDeSeleccion or tlGeneracionAutomatica or tlPedirConfirmaciones )
										this.GenerarPdfSegundoPlano( toEntidad, loColDisenosPdf[ lnI ] )
									else
										if toEntidad.ObtenerNombre() = "TIQUETDECAMBIO"
											this.GenerarPdfTiquetDeCambio( toEntidad, loColDisenosPdf[ lnI ], loColPdfsGenerados )
										else
											lcPdfGenerado = this.GenerarPdf( toEntidad, loColDisenosPdf[ lnI ] )
										endif
									endif
								endif
							endif
							if !empty( lcPdfGenerado )
								loColPdfsGenerados.Add( lcPdfGenerado )
								if pemstatus( toEntidad, "lTieneTiquetDeCambioPdf", 5 ) and toEntidad.lTieneTiquetDeCambioPdf
									this.AdjuntarPdfsGeneradosPorTiquetDeCambio( loColPdfsGenerados )
								endif
							endif
						endfor
					endif
				endif
			else
				.AgregarInformacion( "El servicio de impresión no está habilitado" )
				llProcesar = .F.
			endif
		endwith
		
		if !llProcesar
			loInfo = this.ObtenerInformacion()
			if loInfo.count > 0
				goservicios.errores.levantarexcepcion( loInfo )
			endif
		endif
		return loColPdfsGenerados
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AdjuntarPdfsGeneradosPorTiquetDeCambio( toColPdfsGenerados ) as zoocoleccion OF zoocoleccion.prg
		local loTiquetDeCambio as Object, loColDisenos as Object, loDisenoImpre as Object, lnI as Integer, lcRuta as String, ;
			lcRutaAnterior as String, loColArchivos as zoocoleccion OF zoocoleccion.prg
		external array loColDisenos 
		external array loColArchivos 
		
		lcRuta = ""
		lcRutaAnterior = ""
		loColArchivos = _screen.zoo.crearobjeto( "zooColeccion" )
		loColArchivos.Remove(-1)
		loDisenoImpre = This.oDisenoImpresion
		loTiquetDeCambio = _screen.Zoo.InstanciarEntidad( "TiquetDeCambio" )
		loColDisenos = This.ObtenerDisenosParaPdf( loTiquetDeCambio, .f., .f. )

		for lnI = 1 to loColDisenos.count
			loDisenoImpre.Codigo = loColDisenos[ lnI ]
			lcRuta = upper( this.ObtenerRutaPdfParaEntidadesSinDatos( loTiquetDeCambio, loDisenoImpre ) )
			if empty( lcRutaAnterior ) or lcRutaAnterior != lcRuta
				cNombreArchivoParaBuscar = this.ObtenerNombreDeArchivoParaTiquetDeCambio( loTiquetDeCambio, loColDisenos[ lnI ])
				loColArchivos = this.ObtenerListaDeArchivos( lcRuta, cNombreArchivoParaBuscar + "*.Pdf" )
			endif
			lcRutaAnterior = lcRuta
		endfor
		for lnI = 1 to loColArchivos.count
			toColPdfsGenerados.Add( loColArchivos[ lnI ] )
		endfor
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDeArchivos( tcCarpeta, tcEsquema ) as zoocoleccion OF zoocoleccion.prg
		local lnCantidadArchivos as Integer, lnI as Integer, lnJ as Integer, ;
			loColListaArchivos as zoocoleccion OF zoocoleccion.prg
		
		loColListaArchivos = _screen.zoo.crearobjeto( "zooColeccion" )
		loColListaArchivos.Remove(-1)
		try
			lnCantidadArchivos = ADIR(laArchivos, AddBS(tcCarpeta) + tcEsquema, "A", 0)
			for lnI = 1 to lnCantidadArchivos
				lnJ = (lnI - 1) * 5
				loColListaArchivos.Add(	tcCarpeta + laArchivos[lnJ + 1] )
			endfor
		catch to loError
			loColListaArchivos.Remove(-1)
		endtry
		return loColListaArchivos
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreDeArchivoParaTiquetDeCambio( toTiquetDeCambio as Object, lcDiseno as String ) as String
		local lcRetorno as String, lcNombreArchivoEntidadComprobante as String, lcDescipcionEntidadTiquetDeCambio as String, ;
			lcTipoComprobante as String, lcComprobante as String, lnComprobanteLen as Integer, lnComprobantePos as Integer, ;
			lcNombreArchivoEntidadTiquetDeCambio as String
		
		lcNombreArchivoEntidadComprobante = upper( this.ObtenerNombreDeArchivoPdfAGenerar( lcDiseno ) )
		lcDescipcionEntidadTiquetDeCambio = upper( toTiquetDeCambio.cDescripcion ) 
		lcTipoComprobante = upper( this.ObtenerIdentificadorDeComprobante( this.oEntidadImprimir ) )
		lcComprobante = " " + upper( lcTipoComprobante + "_" + this.oEntidadImprimir.Letra ) ;
							+ "_" + padl( transform( this.oEntidadImprimir.PuntoDeVenta ), 4, "0" ) ;
							+ "-" + padl( transform( this.oEntidadImprimir.Numero ), 8, "0" )
		lnComprobanteLen = len( lcComprobante )
		lnComprobantePos = at( lcComprobante, lcNombreArchivoEntidadComprobante )
		lcNombreArchivoEntidadTiquetDeCambio = lcDescipcionEntidadTiquetDeCambio + substr( lcNombreArchivoEntidadComprobante, lnComprobantePos )
		lcRetorno = substr( lcNombreArchivoEntidadTiquetDeCambio, 1, lnComprobantePos + lnComprobanteLen - 1 )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaPdfParaEntidadesSinDatos( toEntidadImpre as Object, toDisenoImpre as Object ) as String
		local lcRetorno as String
		lcRutaInicial = iif( empty( alltrim( toDisenoImpre.RutaPdf ) ), addbs( _screen.zoo.cRutaInicial ), addbs( alltrim( toDisenoImpre.RutaPdf ) ) )
		lcRetorno = lcRutaInicial ;
					+ addbs( alltrim( _Screen.zoo.app.cSucursalActiva ) ) ;
					+ addbs( toEntidadImpre.cDescripcion ) ;
					+ addbs( alltrim( str(year( date() )) ) + "-" + padl( alltrim( str(month( date() )) ), 2, "0" ) )	
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerDescripPregunta( loEntidad ) as Void
		local lcRetorno as string
		lcRetorno = space(0)
		if pemstatus( loEntidad , "DescripcionFw", 5 ) 
			lcRetorno = this.oEntidadImprimir.DescripcionFw
			if pemstatus( this.oEntidadImprimir, "PuntoDeVenta", 5 )
			else
				lcRetorno = strtran( lcRetorno, "()", space(0) )
	   			lcRetorno = strtran( lcRetorno, "( )", space(0) )
	   			lcRetorno = strtran( lcRetorno, "(-)", space(0) )
	   			lcRetorno = strtran( lcRetorno, " - ", space(1) )
			endif
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPdf( toEntidad as entidad OF entidad.prg, tcCodigoDisenio as String ) as Void
		local lcRutaDiseno as String, lcRetorno as String
			
		lcRetorno = ""
		
		with this
			.lEsSalidaAPDF = .T.
			.lIncluyeArticuloTotalizador = .llHabilitaTotalizadores and .oColaboradorArticuloTotalizador.HayArticuloTotalizador( toEntidad ) and !.oDisenoImpresion.EsUnReporteDeEtiqueta()
			if .lIncluyeArticuloTotalizador 
				.oColaboradorArticuloTotalizador.ModificarDetalleDelComprobante( toEntidad ) 
				.oEntidadImprimir = toEntidad
			endif
			
			if this.EsComprobanteElectronico( toEntidad ) and pemstatus( toEntidad, "ImagenRutaCodigoQR", 5) and empty( toEntidad.ImagenRutaCodigoQR )
				llCompQrGenerado = toEntidad.SetearAtributosVirtualesImagenQR('GenerarPdf')
			endif

			lcRutaDiseno = .ActualizarDatosEnDiseno( toEntidad, tcCodigoDisenio )
			lcRetorno = .GenerarImpresionAPDF( lcRutaDiseno, tcCodigoDisenio )

			if .lIncluyeArticuloTotalizador 
				.oColaboradorArticuloTotalizador.RestaurarDetalleDeComprobantes( toEntidad )
				.oEntidadImprimir = toEntidad
				.lIncluyeArticuloTotalizador = .f.
			endif
		endwith

		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPdfTiquetDeCambio( toEntidad as entidad OF entidad.prg, tcCodigoDisenio as String, toColPdfsGenerados as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcRutaDiseno as String, lnCantDetalleTiquet as Integer, lnCantArticuloTiquet as Integer, ;
			lnItemTiquet as Integer, lnI as Integer, loTiquet as Object, lcNombreArchivo as String, ;
			lcAtributoClavePrimaria as String, lxValorClavePrimaria as Variant, llSaveEsUnTiquetDeCambio as Boolean

		this.lEsSalidaAPDF = .T.
		llSaveEsUnTiquetDeCambio = this.lEsUnTiquetDeCambio
		this.lEsUnTiquetDeCambio = .t.
		lcAtributoClavePrimaria = toEntidad.ObtenerAtributoClavePrimaria()
		lxValorClavePrimaria = toEntidad.&lcAtributoClavePrimaria
		toEntidad.&lcAtributoClavePrimaria = lxValorClavePrimaria

		lnCantDetalleTiquet = toEntidad.ObtenerCantidadDeItemsEnDetalle()
		for lnItemTiquet = 1 to lnCantDetalleTiquet
			lnCantArticuloTiquet = toEntidad.ObtenerCantidadDeArticulosEnItem( lnItemTiquet )
			for lnI = 1 to lnCantArticuloTiquet
				lcNombreArchivo = ""
				loTiquet = toEntidad.ObtenerTicketIndividual( lnItemTiquet, lnI ) 
				if loTiquet.lPermiteGenerarTiquetDeCambio
					This.oEntidadImprimir = loTiquet
					lcRutaDiseno = this.ActualizarDatosEnDiseno( loTiquet , tcCodigoDisenio )
					lcNombreArchivo = this.GenerarImpresionAPDF( lcRutaDiseno, tcCodigoDisenio )
					if !empty( lcNombreArchivo )
						toColPdfsGenerados.Add ( lcNombreArchivo ) 
					endif
				endif
			endfor
		endfor
		this.lEsUnTiquetDeCambio = llSaveEsUnTiquetDeCambio
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteElectronico( toEntidad as Object ) as Boolean
		local llRetorno as Boolean
		if vartype (toEntidad) = "O"
		  llRetorno = ( "<CE>" $ toEntidad.ObtenerFuncionalidades() )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDisenosParaPdf( toEntidad as entidad OF entidad.prg, tlMostrarVentanaDeSeleccion as Boolean, tlGeneracionAutomatica as Boolean ) as Object
		local lnCantidad as Integer, loForm as form, lcForm as string, lnDiseno as Integer, llHayDisenosAutomaticosParaPdf as Boolean, lcDisenoPDF as String, ;
			  loColDisenosPdf as zoocoleccion OF zoocoleccion.prg, lnI as Integer, lcXmlDisenios as String, lcCursorDisenios as String

		lcDisenoPDF = ""
		llHayDisenosAutomaticosParaPdf = .f.
		lnCantidad = 1
		loColDisenosPdf = _screen.zoo.crearobjeto( "zooColeccion" )
		lcCursorDisenios = sys( 2015 )

		if tlGeneracionAutomatica
			llHayDisenosAutomaticosParaPdf = this.DebeGenerarPDFsDeDisenosAutomaticamente( this.oEntidadImprimir )
		else
			lnCantidad = this.TieneDisenoParaPdf( this.oEntidadImprimir )
		endif

		with this
			do case
				case tlGeneracionAutomatica
					if llHayDisenosAutomaticosParaPdf
						for lnI = 1 to this.colDisenosAutomaticosEntidad.Count
							loColDisenosPdf.Add( this.colDisenosAutomaticosEntidad[ lnI ] )
						endfor
					endif
				case lnCantidad > 1
					if tlMostrarVentanaDeSeleccion 
						This.oSeleccionDisenios.setearDecoradorEspecifico( _screen.zoo.crearobjeto( "DecoradorSeleccionDisenioDeSalida" ) )
						This.oSeleccionDisenios.setearPobladorEspecifico( _screen.zoo.crearobjeto( "PobladorSeleccionDisenioDePdf" ) ) 
						loRespuesta = This.oSeleccionDisenios.ObtenerDisenio()
						loColDisenosPdf.Add( loRespuesta.cRespuesta )
					else
						lcXmlDisenios = this.ObtenerDisenoDeEntidad( toEntidad,DEF_SALIDA_A_PDF, tlGeneracionAutomatica )
						xmltocursor( lcXmlDisenios, lcCursorDisenios )
						scan
							loColDisenosPdf.Add( &lcCursorDisenios..Codigo ) 
						endscan
						use in select( lcCursorDisenios )
					endif
				case lnCantidad = 1
					loColDisenosPdf.Add( This.PrimerDiseno( toEntidad, DEF_SALIDA_A_PDF, tlGeneracionAutomatica ) )

				otherwise
					if tlMostrarVentanaDeSeleccion 
						.AgregarInformacion( this.ObtenerMensajeDeFaltaDeDisenos( "PDF" ) )
					endif
			endcase
		endwith
		return loColDisenosPdf
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oSeleccionDisenios_Access() as Variant
		if !this.ldestroy and ( !vartype( this.oSeleccionDisenios ) = 'O' or isnull( this.oSeleccionDisenios ) )
			This.oSeleccionDisenios = _screen.zoo.crearobjeto( "SeleccionDeDisenios" )
		endif
		
		return This.oSeleccionDisenios
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDatosEnDiseno( toEntidad as entidad of entidad.prg, tcDiseno as String ) as Void
		This.oDisenoImpresion.Codigo = tcDiseno
		This.VerificarGenerados()
		return This.ActualizarDatos( toEntidad )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarImpresionAPDF( tcRutaDiseno as String, tcCodigoDiseno as String ) as Void
		local loGenerador as Object, lcNombreArchivoGenerado as String, lcDirectorio as String, lcArchivoPdfTemporal as String,;
			loListado as objetoListado of ObjetoListado.prg
		
		loListado = _screen.zoo.crearobjeto( "ObjetoListado")
		loListado.cArchivo = tcRutaDiseno
		
		loGenerador = _Screen.zoo.crearObjeto( "ExportadorReportesCrystal" )
		loGenerador.Tipo = DEF_SALIDA_A_PDF
		loGenerador.Exportar( loListado )
		loGenerador.release()

		lcNombreArchivoGenerado = ""
		lcArchivoPdfTemporal = tcRutaDiseno 
		if empty( lcArchivoPdfTemporal )
		else			
			lcArchivoPdfTemporal = forceext( lcArchivoPdfTemporal, ".pdf" )
			lcNombreArchivoGenerado = this.ObtenerRutaYNombreDeArchivoPdfAGenerar( tcCodigoDiseno )

			this.CopiarArchivoPdfANuevoDestino( lcArchivoPdfTemporal, lcNombreArchivoGenerado )
			this.EliminarTemporalesDeImpresionAPdf( lcArchivoPdfTemporal )
		endif
		return lcNombreArchivoGenerado
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CopiarArchivoPdfANuevoDestino( tcArchivoPdfTemporal as String, tcNombreArchivoGenerado as String ) as Void
		local llDebeCopiarElArchivo as Boolean
		llDebeCopiarElArchivo = .t.
		
		if this.EsComprobanteElectronico( This.oEntidadImprimir ) and file( tcNombreArchivoGenerado )
			llDebeCopiarElArchivo = .f.
		endif
		if llDebeCopiarElArchivo
			goLibrerias.CrearDirectorio( justpath( tcNombreArchivoGenerado ) )
			copy file ( tcArchivoPdfTemporal ) to ( tcNombreArchivoGenerado )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaYNombreDeArchivoPdfAGenerar( tcCodigoDiseno as String ) as String
		return this.ObtenerRutaDeArchivoPdfAGenerar() + this.ObtenerNombreDeArchivoPdfAGenerar( tcCodigoDiseno )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaDeArchivoPdfAGenerar() as String
		local lcRuta as String, lcTipoComprobante as String, lnCant as Integer, loError as Exception, ldFecha as Date
		lcRuta = ""
		with This.oEntidadImprimir
			if this.EsComprobanteElectronico( This.oEntidadImprimir ) and this.MantieneCompatibilidadHaciaAtrasEnNombresDePdfs()
				lcTipoComprobante = .ObtenerCodigoComprobanteParaPdf()
				lcRuta = addbs( alltrim( This.oDisenoImpresion.RutaPdf ) ) ;
						+ addbs( alltrim( upper( lcTipoComprobante + "_" + .Letra ) + "_" + padl( transform( .PuntoDeVenta ), 4, "0" ) ) )
				lnCant = this.nCantidadPdfsPorCarpetaCompatibilidadHaciaAtras
				if mod( .Numero, lnCant ) = 0
					lnDesde = ( int( .Numero / lnCant ) - 1 ) * lnCant
				else
					lnDesde = int( .Numero / lnCant ) * lnCant
				endif 	
				lnHasta = lnDesde + lnCant
				lcRuta = lcRuta + addbs( padl( alltrim( str( lnDesde + 1 ) ), 8, "0" ) + "-" + padl( alltrim( str( lnHasta ) ), 8, "0" ) )
			else
				if empty( alltrim( This.oDisenoImpresion.RutaPdf ) )
					lcRutaInicial = addbs( _screen.zoo.cRutaInicial )
				else
					lcRutaInicial = addbs( alltrim( This.oDisenoImpresion.RutaPdf ) )
				endif
				
				if pemstatus( this, "Fecha", 5)
					ldFecha = iif(!empty(.Fecha),.Fecha,date())
				else
					ldFecha = date()
				endif
			
				lcRuta = lcRutaInicial ;
						+ addbs( alltrim( _Screen.zoo.app.cSucursalActiva ) ) ;
						+ addbs( .cDescripcion ) ;
						+ addbs( alltrim( str(year( ldFecha )) ) + "-" + padl( alltrim( str(month( ldFecha )) ), 2, "0" ) )	
			endif
		endwith

		goservicios.Librerias.CrearDirectorio( lcRuta )
		return lcRuta
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDeArchivoPdfAGenerar( tcCodigoDiseno as String ) as String
		local lcNombre as String, lcTipoComprobante as String, lcNombreDiseno as String
		lcNombre = ""
		with This.oEntidadImprimir
			if this.EsComprobanteElectronico( This.oEntidadImprimir ) and this.MantieneCompatibilidadHaciaAtrasEnNombresDePdfs()
				lcTipoComprobante = .ObtenerCodigoComprobanteParaPdf()
				lcNombre = alltrim( upper( lcTipoComprobante + "_" + .Letra ) + "_" + padl( transform( .PuntoDeVenta ), 4, "0" ) ) ;
							+ "-" + padl( transform( .Numero ), 8, "0" )
			else
				lcNombre = upper( alltrim( this.oEntidadImprimir.cDescripcion ) ) + " " + this.ObtenerSufijoDeNombreDeArchivoPdfAGenerar( this.oEntidadImprimir )
			endif
		endwith
		lcNombreDiseno = ""
		if this.ExisteMasDeUnDisenoHabilitadoParaLaEntidad()
			lcNombreDiseno = " (" + alltrim( tcCodigoDiseno ) + ")"
		endif
		lcNombre = alltrim( lcNombre + lcNombreDiseno ) + ".pdf"
		return lcNombre
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function MantieneCompatibilidadHaciaAtrasEnNombresDePdfs() as Boolean
		return !this.HaCambiadoElValorDeParametroPreexistenteParaRutaPdf()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HaCambiadoElValorDeParametroPreexistenteParaRutaPdf() as Boolean
		local llRetorno as Boolean, lcValorParametroRutaDelPdf as String
		llRetorno = .t.
		
		if this.TuvoSeteadoElParametroAntiguoGeneraComprobanteEnPdf()
			lcValorParametroRutaDelPdf = This.ObtenerValorParametroAntiguoRutaDelPdf()
			lcValorParametroRutaDelPdf = this.QuitarTagSeteadoMedianteFixParaCompatibilidadHaciaAtras( lcValorParametroRutaDelPdf )
			if !empty( lcValorParametroRutaDelPdf ) and upper( alltrim( lcValorParametroRutaDelPdf ) ) == upper( alltrim( This.oDisenoImpresion.RutaPdf ) )
				llRetorno = .f.
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TuvoSeteadoElParametroAntiguoGeneraComprobanteEnPdf() as Boolean
		local llRetorno as Boolean, lcValorParametroGeneraComprobanteEnPdf as String
		llRetorno = .f.

		lcValorParametroGeneraComprobanteEnPdf = This.oColaboradorParametros.ObtenerValorParametro( "Genera comprobante en PDF", _Screen.zoo.app.cSucursalActiva )
		lcValorParametroGeneraComprobanteEnPdf = this.QuitarTagSeteadoMedianteFixParaCompatibilidadHaciaAtras( lcValorParametroGeneraComprobanteEnPdf )
		if type( "lcValorParametroGeneraComprobanteEnPdf" ) = "C" and alltrim( upper( lcValorParametroGeneraComprobanteEnPdf ) ) == ".T."
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorParametroAntiguoRutaDelPdf() as String
		return This.oColaboradorParametros.ObtenerValorParametro( "Ruta del Pdf", _Screen.zoo.app.cSucursalActiva )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function QuitarTagSeteadoMedianteFixParaCompatibilidadHaciaAtras( tcValor as String ) as String
		return strtran( tcValor, "??FIX??", "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteMasDeUnDisenoHabilitadoParaLaEntidad() as Boolean
		local llRetorno as Boolean, lcDisenos as String, lnCantidadDeDisenosHabilitadosDeLaEntidad as Integer
		llRetorno = .f.
		lcDisenos = this.ObtenerDisenosDeUnaEntidad( this.oEntidadImprimir.obtenernombre(), DEF_SALIDA_A_PDF, .f. )
		lnCantidadDeDisenosHabilitadosDeLaEntidad = getwordcount( lcDisenos, "," )
		if lnCantidadDeDisenosHabilitadosDeLaEntidad > 1
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarTemporalesDeImpresionAPdf( tcRutaDiseno as String ) as Void
		delete file addbs( justpath( tcRutaDiseno ) ) + "*.*"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDisenosConLimiteParaEntidad( toEntidad as Object ) as Void
		local lcCursor as String, lcCodigosDisenoDeImpresion as String 

		lcCursor = sys( 2015 )
		lcCodigosDisenoDeImpresion = this.ObtenerDisenosDeUnaEntidad( alltrim( toEntidad.ObtenerNombre() ), DEF_SALIDA_A_IMPRESORA, .f. )

		if EMPTY( lcCodigosDisenoDeImpresion )
			lcCodigosDisenoDeImpresion = "''"
		ENDIF

		This.XmlACursor( This.oDisenoImpresion.oAD.ObtenerDatosEntidad( "Codigo, Entidad, ImpresionAutomatica, Condicion, DefaultImpresion, ;
		BloquearRegistro, AplicaLimite, Advierte, Fechatransferencia", "Codigo in ( " + alltrim( lcCodigosDisenoDeImpresion ) + " ) and ( AplicaLimite = 1 or Advierte = 1 )" ), lcCursor )
		select * from &lcCursor where .f. into cursor ( this.cCursorDisenos ) readwrite
		select ( lcCursor )
		scan
			if this.CumpleCondicionDeImpresion( toEntidad, &lcCursor..Condicion, &lcCursor..Codigo )
				scatter name loDatos
				insert into ( this.cCursorDisenos )  from name loDatos
			endif
		endscan
		use in select( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoConLimitesDeImpresion( toEntidad as entidad OF entidad.prg, tcDetalle as String ) as Object

		local loObjetoLimite as Object
		loObjetoLimite = null
		this.lFiltroVacio = .f.
		this.CargarDisenosConLimiteParaEntidad( toEntidad )

		if reccount( this.cCursorDisenos ) > 0
			loObjetoLimite = this.ObtenerObjetoConLimitesParaEntidad( this.cCursorDisenos, tcDetalle )
		endif
		return loObjetoLimite
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoConLimitesParaEntidad( tcCursor as String, tcDetalle as String ) as object
		local loRetorno as object
		loRetorno = This.ObtenerObjetoConLimitesSegunOpcion( tcCursor, tcDetalle, "ImpresionAutomatica = .T. " )
		if Isnull( loRetorno ) and !this.lFiltroVacio
			loRetorno = This.ObtenerObjetoConLimitesSegunOpcion( tcCursor, tcDetalle, "DefaultImpresion = .T. " )
		Endif	
		if Isnull( loRetorno ) and !this.lFiltroVacio
			loRetorno = This.ObtenerObjetoConLimitesSegunOpcion( tcCursor, tcDetalle, "" )
		endif

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoConLimitesSegunOpcion( tcCursor as String, tcDetalle as String, tcExpresion as String ) as object
		local lcCursor as String, loRetorno as Object, lcWhere as String, llAplicoLimite as Boolean, lnMinimo as Integer
		loRetorno = Null
		lcCursor = sys( 2015 )
		
		lcWhere = " where " + iif( empty( tcExpresion ), " .t. ", tcExpresion  )
		select * from ( tcCursor ) &lcWhere into cursor ( lcCursor )

		if _Tally > 0
			loRetorno = This.ObtenerObjetoConLimitesSegunDetalle( lcCursor, tcDetalle, "AplicaLimite = 1" )
			if isnull( loRetorno )
				loRetorno = This.ObtenerObjetoConLimitesSegunDetalle( lcCursor, tcDetalle, "Advierte = 1" )
			endif
		EndIf
		use in select( lcCursor )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoConLimitesSegunDetalle( tcCursor as String, tcDetalle as String, tcExpresion as String ) as Object
		local lcCursor as String, loRetorno as String, lcWhere as String, lnLimite as Integer, lnCantidadItemsDetalle as Integer, lcDiseno as String, ;
			lnRestriccion as Integer, lcAtributosAgrupamiento as String, loObjetoDetalle as Object
		
		loRetorno = Null
		lnLimite = 0
		lnCantidadItemsDetalle = 0
		lcDiseno = ""
		lnRestriccion = 0
		lcAtributosAgrupamiento = ""
		lcCursor = sys( 2015 )		
		lcWhere = " where " + iif( empty( tcExpresion ), " .t. ", tcExpresion  )
		select * from ( tcCursor ) &lcWhere into cursor ( lcCursor )
		if _Tally > 0
			select &lcCursor
			scan all

				loObjetoDetalle = This.ObtenerObjetoConDatosDetalle( &lcCursor..Codigo, tcDetalle )
				if loObjetoDetalle.CantidadItemsDetalle > 0
					if empty( lnLimite ) or loObjetoDetalle.CantidadItemsDetalle < lnLimite
						lnLimite = loObjetoDetalle.CantidadItemsDetalle
						lcDiseno = &lcCursor..Codigo
						lnRestriccion = iif( &lcCursor..AplicaLimite = 1, 2, &lcCursor..Advierte )
						lcAtributosAgrupamiento = loObjetoDetalle.AtributosAgrupamiento
					EndIf
				Endif	
				select &lcCursor
			EndScan
		EndIf
		if lnLimite > 0
			loRetorno = _screen.zoo.crearobjeto( "ObjetoLimite", "ManagerImpresion.prg" )
			loRetorno.Limite = lnLimite
			loRetorno.Restriccion = lnRestriccion
			loRetorno.Diseno = lcDiseno
			loRetorno.AtributosAgrupamiento = lcAtributosAgrupamiento
		Endif
		use in select( lcCursor )
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoConDatosDetalle( tcDiseno as String, tcDetalle as String ) as Object
		local	lnCantidadItemsDetalle as Integer, lcCursorAreas as String, lcCursorAtributos as String, loRetorno as Object, lcAtributosAgrupamiento as String, ;
				llAgrupar As Boolean
					
		lnCantidadItemsDetalle = 0
		lcAtributosAgrupamiento = ""
		llAgrupar = .F.
		lcCursorAreas = sys( 2015 )
		lcCursorAtributos = sys( 2015 )
		this.lFiltroVacio = .F.

		this.XmlACursor( this.oDisenoImpresion.oAD.ObtenerDatosDetalleAreas( "", "Codigo = '" + tcDiseno + "' and EsDet = .t." ), lcCursorAreas )
		select ( lcCursorAreas )
		scan for lnCantidadItemsDetalle = 0
			this.XmlACursor( this.oDisenoImpresion.oAD.ObtenerDatosDetalleAtributos( "", "Codigo = '" + tcDiseno + "' and Area ='" + &lcCursorAreas..Area + "'" ), lcCursorAtributos )
			if This.ExisteDetalleEnElArea( tcDetalle, lcCursorAtributos )
				if  alltrim( upper( &lcCursorAreas..Tipo ) ) == "DETALLE MULTIHOJA"
					this.lFiltroVacio = .T.
				else
					lnCantidadItemsDetalle = &lcCursorAreas..Alto
				endif
			EndIf	

			if lnCantidadItemsDetalle = 0
			else
				lcAtributosAgrupamiento = This.ObtenerAtributosAgrupamiento( lcCursorAtributos )
			EndIf
		endscan

		use in select( lcCursorAreas )
		use in select( lcCursorAtributos )
		loRetorno = newobject( "Custom" )
		loRetorno.AddProperty( "CantidadItemsDetalle", lnCantidadItemsDetalle )
		loRetorno.AddProperty( "AtributosAgrupamiento", lcAtributosAgrupamiento )

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosAgrupamiento( tcCursor as String ) as String
		local lcAtributosAgrupamiento as String, llAgrupar as Boolean
		llAgrupar = .F.
		lcAtributosAgrupamiento = ""
		select ( tcCursor )
		scan all
			llAgrupar = llAgrupar or &tcCursor..FuncionAgrupar = 2
			lcAtributosAgrupamiento = lcAtributosAgrupamiento + iif( &tcCursor..FuncionAgrupar = 2, "", this.ObtenerAtributoAgrupamiento( &tcCursor..Contenido ) + "," )&&alltrim( getwordnum( &tcCursor..Contenido , 2, "." ) ) + "," )
			select ( tcCursor )
		endscan
		if llAgrupar
			lcAtributosAgrupamiento = substr( lcAtributosAgrupamiento, 1, len( lcAtributosAgrupamiento ) - 1 )
		else
			lcAtributosAgrupamiento = ""
		Endif
		return lcAtributosAgrupamiento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoAgrupamiento( tcAtributo as String ) as String
		local lcRetorno as String, lnCant as Integer, lnI as Integer
			
		lnCant = getwordcount( tcAtributo, "." )
		lcRetorno = ""
		
		for lnI = 2 to lnCant
			if lnI > 2
				lcRetorno = lcRetorno + "." + alltrim( getwordnum( tcAtributo, lnI, "."  ) )
			else
				lcRetorno = lcRetorno + alltrim( getwordnum( tcAtributo, lnI, "."  ) )
			endif
		endfor
			
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteDetalleEnElArea( tcDetalle as String, tcCursor as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		select ( tcCursor )
		scan all
			if upper( alltrim( tcDetalle ) ) $ upper( alltrim(  getwordnum( &tcCursor..Contenido , 1, "." ) ) )
				llRetorno = .T.
				exit
			endif
			select ( tcCursor )			
		endscan
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarLimites( toColeccion as zoocoleccion OF zoocoleccion.prg, tcDiseno as String ) as Void
		local loItem as Object, lnI as Integer,  lnJ as Integer, lcArea as String, lnLimite as Integer, lcAtributosAgrupamiento as String, llAgrupar as Boolean
		llAgrupar = .F.
		lcAtributosAgrupamiento =  ""
		with this.oDisenoImpresion
			.codigo =  rtrim( tcDiseno )
			for lnI = 1 to .Areas.count
				if .Areas.item( lnI ).esDet
					if upper( alltrim( .Areas.Item( lni ).tipo_pk )) != "DETALLE MULTIHOJA"
						if !.ImprimeContinuo()
							lcArea = upper(alltrim( .Areas.item( lnI ).Area ))
							lcDetalle = ""
							for lnJ = 1 to .Atributos.count
								if ( upper(alltrim( .Atributos.item( lnJ ).Area)) = lcArea ) and (inlist(upper(alltrim( .Atributos.item( lnJ ).tipo_pk)), "A", "I" ) )
									lcDetalle = getwordnum( .Atributos.item( lnJ ).contenido , 1, "." )						
									exit
								endif
							endfor
							llAgrupar = .F.
							for lnJ = 1 to .Atributos.count
								if ( upper(alltrim( .Atributos.item( lnJ ).Area)) = lcArea )
									llAgrupar = llAgrupar or ( .Atributos.item( lnJ ).FuncionAgrupar = 2 )
									lcAtributosAgrupamiento = lcAtributosAgrupamiento + iif( .Atributos.item( lnJ ).FuncionAgrupar = 2, "", alltrim( getwordnum( .Atributos.item( lnJ ).contenido , 2, "." ) ) + "," )
								endif
							endfor
							if llAgrupar
								lcAtributosAgrupamiento = substr( lcAtributosAgrupamiento, 1, len( lcAtributosAgrupamiento ) - 1 )
							else
								lcAtributosAgrupamiento = ""
							Endif		
							if !empty( lcDetalle )
								lnLimite = iif(.AplicaLimite > 0, 2,.Advierte )
								this.AgregarLimiteALaColeccion( toColeccion, lcDetalle, .Areas.item( lnI ).alto, lnLimite , .Codigo, lcAtributosAgrupamiento )
							endif
						endif
					endif	
				endif
			endfor	
		endwith	
		
	endfunc 

	*-------------------------------------------------------------------------------------------------------------
	function AgregarLimiteALaColeccion( toColeccion as zoocoleccion OF zoocoleccion.prg , tcDetalle as String , tnCantidadItems as Integer , tnRestriccion as Integer, tcDiseno as String, tcAtributosAgrupamiento  as String ) as Void
		local loItem as Object 

		try
			loItem = toColeccion.item( tcDetalle )
			do case
				case loItem.Limite > tnCantidadItems
					loItem.Limite = tnCantidadItems
					loItem.Restriccion = tnRestriccion
					loItem.Diseno = tcDiseno
					loItem.AtributosAgrupamiento = tcAtributosAgrupamiento
				case loItem.Limite = tnCantidadItems
					if loItem.Restriccion > tnRestriccion
						loItem.Restriccion = tnRestriccion
						loItem.Diseno = tcDiseno
						loItem.AtributosAgrupamiento = tcAtributosAgrupamiento
					endif
			endcase

		catch
			loItem = createobject("empty")
			addproperty( loItem, "Detalle", tcDetalle )
			addproperty( loItem, "Limite", tnCantidadItems )
			addproperty( loItem, "Restriccion", tnRestriccion )
			addproperty( loItem, "Diseno", tcDiseno )
			addproperty( loItem, "AtributosAgrupamiento", tcAtributosAgrupamiento )
			toColeccion.Agregar( loItem, tcDetalle )
		endtry

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDetallesQueSuperanCantidadItemsPorDiseno( toEntidad as Object ) as String
		local lcRetorno as String, loColDetallesEnDisenoImpresion as Collection, lcDetalle as String, loItemDelDiseno as Object,;
		lcNombreEntidad as String   
		lcRetorno = ""
		loColDetallesEnDisenoImpresion = _screen.zoo.crearobjeto( "zooColeccion" )
		this.AgregarLimites( loColDetallesEnDisenoImpresion , this.oDisenoImpresion.codigo )
		for each loItemDelDiseno in loColDetallesEnDisenoImpresion
			lcDetalle = loItemDelDiseno.Detalle
			try
				toEntidad.&lcDetalle..cAtributosAgrupamiento = loItemDelDiseno.AtributosAgrupamiento
				if  toEntidad.&lcDetalle..nCantidadDeItemsCargados > loItemDelDiseno.Limite
					lcRetorno = lcRetorno + iif( empty( lcRetorno ), "", ", " ) + proper( lcDetalle ) + "(" + transform( loItemDelDiseno.Limite ) + ")"
				endif
			catch
			endtry
		endfor
		
		return lcRetorno
	endfunc 

	*----------------------------------------------------------------------------------
	function ObtenerDisenosDeUnaEntidad( tcEntidad as String, tcTipoDeSalida as String, tlFiltrarSoloAutomaticos as Boolean ) as String 
		local lcDisenos as String, lcCursor as String, lcCursor2 as String, lcRetorno as String, lcHaving as String, lcCondicionCodigos as String, ;
			  lcCondicionTipoDeSalida as String, lcCondicionFiltrarAutomaticos as String
		lcCursor = sys(2015) 
		lcCursor2 = sys(2015) 
		lcDisenos = ""
		lcRetorno = ""

		this.xmlACursor( This.oDisenoImpresion.oAD.ObtenerDatosDetalleEntidades( "codigo, entidad ", " upper( entidad ) = '" + tcEntidad + "'" ), lcCursor )
		select ( lcCursor )
		scan
			lcDisenos = lcDisenos +"'"+ rtrim( &lcCursor..Codigo ) + "',"
		endscan 
		use in select( lcCursor )

		if !empty( lcDisenos )
			lcDisenos = left( lcDisenos, len( lcDisenos ) - 1 )
			lcCondicionCodigos = " codigo  in (" + lcDisenos + ")"
			do case
				case tcTipoDeSalida = DEF_SALIDA_A_IMPRESORA
					lcCondicionTipoDeSalida = " HabilitaSalidaAImpresora = .T. "
				case tcTipoDeSalida = DEF_SALIDA_A_PDF
					lcCondicionTipoDeSalida = " HabilitaSalidaAPdf = .T. "
				otherwise
					lcCondicionTipoDeSalida = ""
			endcase
			lcHaving = lcCondicionCodigos + iif( empty( lcCondicionTipoDeSalida ), "", " and " ) + lcCondicionTipoDeSalida
			if tlFiltrarSoloAutomaticos
				do case
					case tcTipoDeSalida = DEF_SALIDA_A_IMPRESORA
						lcCondicionFiltrarAutomaticos = " and ImpAuto = .T. "
					case tcTipoDeSalida = DEF_SALIDA_A_PDF
						lcCondicionFiltrarAutomaticos = " and PdfAutomatico = .T. "
					otherwise
						lcCondicionFiltrarAutomaticos = ""
				endcase
				lcHaving = lcHaving + lcCondicionFiltrarAutomaticos
			endif

			this.xmlACursor( this.oDisenoImpresion.oAd.obtenerDatosEntidad( "codigo, entidad, series", lcHaving, "Codigo" ), lcCursor2 )

			select ( lcCursor2 )
			scan
				if empty( alltrim( &lcCursor2..Series ) ) or ( atc(_screen.zoo.app.cSerie,alltrim( &lcCursor2..Series )) > 0)&&( inlist( alltrim( &lcCursor2..Series ),_screen.zoo.app.cSerie ))
					lcRetorno = lcRetorno +"'"+ rtrim( &lcCursor2..Codigo ) + "',"
				endif 	
			endscan 
			use in select( lcCursor2 )
			if !empty( lcRetorno )
				lcRetorno = left( lcRetorno, len( lcRetorno ) - 1 )
			endif
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeDeFaltaDeDisenos( tcTipoDeSalida as String ) as String
		return "La entidad " + this.oEntidadImprimir.ObtenerDescripcion() + " no tiene asociado o habilitado ningún diseño de salida a " + tcTipoDeSalida + "." ;
				+ chr(13) + "Puede modificar o cargar un nuevo diseño desde la opción de menú Configuración --> Entrada y salida a dispositivos --> Diseños de salida"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSufijoDeNombreDeArchivoPdfAGenerar( toEntidad as entidad OF entidad.prg ) as String
		local lcSufijo as String
		lcSufijo = this.ObtenerValorClaveCandidata( toEntidad )
		if empty( lcSufijo )
			lcSufijo = this.ObtenerValorClavePrimaria( toEntidad )
		endif
		return lcSufijo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorClaveCandidata( toEntidad as entidad OF entidad.prg ) as string
		local  lcAtributo as string, lcClave as string, lnI as integer, lcValor as String, ;
			lcIdentificadorDeComprobante as String, llEsEntidadComprobante as Boolean
		lcClave = ""
		lcIdentificadorDeComprobante = this.ObtenerIdentificadorDeComprobante( toEntidad )
		llEsEntidadComprobante = !empty( lcIdentificadorDeComprobante )
		if type( "toEntidad.oAtributosCC" ) = "O" and toEntidad.oAtributosCC.Count > 0
			for lnI = 1 to toEntidad.oAtributosCC.count
				lcAtributo = toEntidad.oAtributosCC( lnI )
				if empty( toEntidad.&lcAtributo )
					lcValor = ""
				else
					if lcAtributo = "TipoComprobante"
						lcValor = lcIdentificadorDeComprobante
					else
						lcValor = this.FormatearValorAtributo( lcAtributo, toEntidad.&lcAtributo, llEsEntidadComprobante )
					endif
				endif
				lcClave = lcClave + upper( lcValor ) + iif( lower( lcAtributo ) = "puntodeventa", "-", "_" )
			endfor
			lcClave = substr( lcClave, 1, len( lcClave ) - 1 )
		endif
		return lcClave
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorClavePrimaria( toEntidad as entidad OF entidad.prg ) as string
		local  lcAtributo as string, lcValor as String
		lcAtributo = toEntidad.ObtenerAtributoClavePrimaria()
		lcValor = this.FormatearValorAtributo( lcAtributo, toEntidad.&lcAtributo, .f. )
		return lcValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearValorAtributo( tcAtributo as String, txValor as Variant, tlEsEntidadComprobante as Boolean ) as String
		local lcRetorno as String
		lcRetorno = goservicios.librerias.ConvertirAString( txValor )
		lcRetorno = this.FormatearValorAtributoParaComprobante( tcAtributo, lcRetorno )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FormatearValorAtributoParaComprobante( tcAtributo as String, tcValor as Variant ) as String
		local lcRetorno as String
		do case
			case lower( tcAtributo ) = "puntodeventa"
				lcRetorno = padl( tcValor, 4, "0" )
			case lower( tcAtributo ) = "numero"
				lcRetorno = padl( tcValor, 8, "0" )
			case lower( tcAtributo ) = "numint"
				lcRetorno = padl( tcValor, 8, "0" )
			otherwise
				lcRetorno = tcValor
		endcase
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdentificadorDeComprobante( toEntidad as entidad OF entidad.prg ) as String
		local lcIdentificador as String, lnNumeroComprobante as Integer
		lcIdentificador = ""
		if this.lEsUnTiquetDeCambio
			lcIdentificador = this.oComprobantes.ObtenerIdentificadorDeComprobante( toEntidad.TipoComprobante )
		else
			lnNumeroComprobante = this.oComprobantes.ObtenerNumeroComprobante( toEntidad.cNombre )
			if lnNumeroComprobante <> 0
				lcIdentificador = this.oComprobantes.ObtenerIdentificadorDeComprobante( lnNumeroComprobante )
			endif
		endif
		return lcIdentificador
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeProcesarEnAgenteDeAccionesOrganic() as Integer
		local lnRetorno as Integer, loConectorAgenteDeAccionesOrganic as ConectorAgenteDeAccionesOrganic of ConectorAgenteDeAccionesOrganic.prg

		*lnRetorno = 1 &&  No esta disponible.
		*lnRetorno = 2 &&  No esta disponible con error.
		*lnRetorno = 3 &&  Esta disponible.
		loConectorAgenteDeAccionesOrganic = _screen.zoo.CrearobjetoPorProducto( "ConectorAgenteDeAccionesOrganic" )
		lnRetorno = loConectorAgenteDeAccionesOrganic.ObtenerDisponibilidadAAO()
		loConectorAgenteDeAccionesOrganic.Release()
		
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValorConCondicion( tcValor, toAtributos, toDetalle, tnNroItemDet, tnNroItemDis, tlCargarItem ) as Void
		local lcRetorno as String, lcCondicion as String
		lcCondicion = toAtributos.Item[ tnNroItemDis ].Condicion		
		if empty( lcCondicion ) or this.CondicionVerdadera( lcCondicion, tnNroItemDet, toDetalle, tlCargarItem )
			lcRetorno = tcValor
		else
			lcRetorno = ""
			this.nCondicionesFalsas = this.nCondicionesFalsas + 1 		
		endif	
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CondicionVerdadera( tcCondicion, tnNroItem, toDetalle, tlCargarItem ) as Boolean
		local llRetorno as Boolean, loItem as Object, lcNombreDetalle as String

		if upper( alltrim( toDetalle.cNombre ) ) $ upper( alltrim ( tcCondicion ) ) && condicion usa el detalle
			if tlCargarItem and todetalle.oItem.NroItem != tnNroItem 
				toDetalle.CargarItem( tnNroItem )
			endif			
			lcNombreDetalle = upper( alltrim( toDetalle.cNombre ) )
			tcCondicion = strtran( upper( tcCondicion ), lcNombreDetalle , lcNombreDetalle  + ".oItem" )			
		endif
		with this.oEntidadImprimir
			llRetorno = evaluate( alltrim( tcCondicion ) )	
		endwith
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsItemDeDetalle( tcArea ) as Void
		local llRetorno as Boolean, toArea as Object
			llRetorno = .f.
			for each toArea in this.oDisenoImpresion.Areas
				if upper( alltrim( tcArea ) ) = upper( alltrim( toArea.Area ) )
					llRetorno = iif( inlist( upper( alltrim( toArea.tipo_pk ) ), "DETALLE", "DETALLE MULTIHOJA", "ETIQUETA DE ARTICULO"), .t., .f.)
					exit
				endif
			endfor
		return llRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HayErrorPorDetalleVacio( toError ) as Void
		local loItemError as Object, llRetorno as Boolean
		if vartype( toError.UserValue.oInformacion ) = "O"
			for each loItemError in toError.UserValue.oInformacion
				if loItemError.nNumero = this.nNumeroErrorPorImprimirSinDetalle
					llRetorno = .t.
					exit
				endif
			endfor
		endif	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerResultadoCondiciones( toEntidad ) as Object
		local loCol as Object, loArea as Object, loItemResultado as Object
		loCol = _screen.zoo.CrearObjeto( "ZooColeccion" )
		for each loArea in this.oDisenoImpresion.Areas
			loItemResultado = createobject( "ResultadoCondicion" )
			loItemResultado.Area = upper( alltrim( loArea.Area ) )
			if !inlist( upper( alltrim( loArea.Tipo_pk ) ), "DETALLE", "DETALLE MULTIHOJA", "ETIQUETA DE ARTICULO" )		
				if empty( loArea.Condicion )
					loItemResultado.Resultado = .t.
				else
					with toEntidad
						loItemResultado.Resultado = evaluate( loArea.Condicion )
					endwith
				endif
				loCol.Agregar( loItemResultado, upper( alltrim( loArea.Area ) ) )		
			endif
		endfor
		return loCol
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerImpresoraPreferente() as String
		this.oGeneradorReportes = _screen.zoo.crearobjeto("GeneradorReportes")
		return 	this.oGeneradorReportes.cImpresoraPreferente
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarNroSecuencial( tcLinea as String, tcCantidad as Integer, tnReservarNros as String ) as String
		local lcRetorno as String, lcSecuencial as Integer, lnI as Integer

		* Si es directo a etiqueta debo usar tnReservarNros porque se imprime por item, y si no es por etiqueta, reservo
		* la cantidad total de etiquetas que tiene el comprobante

		if type("tnReservarNros") <> "N"
			tnReservarNros = 0
		endif

		if this.nUltimoNroSecuencial = 0
			this.nUltimoNroSecuencial = this.Funcionalidades.ObtenerUltimoSecuencial( iif (tnReservarNros>0,tnReservarNros, this.oEntidadImprimir.EtiquetaDetalle.Sum_Cantidad ) )
		endif

		this.nCantNrosSecuencial = len( tcCantidad )
		this.nUltimoNroSecuencial = this.nUltimoNroSecuencial + 1

		lcSecuencial = this.Funcionalidades.ObtenerSecuencial( this.nCantNrosSecuencial, this.nUltimoNroSecuencial )

		*lcRetorno = stuff( tcLinea,at(this.Funcionalidades.cCaracterDeRellonoSecuencial, tcLinea ), this.nCantNrosSecuencial, lcSecuencial )

		do while at( replicate(this.Funcionalidades.cCaracterDeRellonoSecuencial, this.nCantNrosSecuencial ), tclinea ) > 0
			tclinea = stuff( tcLinea,at(this.Funcionalidades.cCaracterDeRellonoSecuencial, tcLinea ), this.nCantNrosSecuencial, lcSecuencial )
		enddo

		lcRetorno = tcLinea
			
		return lcRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarCheckSumACodigoConSecuencial( tcLinea as String ) as String
		local lcAux as String, lcBusca as String, lcAuxConCheck as String, lcRetorno as String
								
		lcAux = substr(tcLinea, atc("*", tcLinea ,1)+1, atc("*", tcLinea ,2)-atc("*", tcLinea ,1)-1)
		lcBusca = substr(tcLinea, atc("*", tcLinea ,1), atc("*", tcLinea ,2)-atc("*", tcLinea ,1)+1)
		lcAuxConCheck = this.ConfigurarCadena( lcAux )
		lcRetorno =  strtran( tcLinea, lcBusca,lcAuxConCheck )
		
		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerImpresoraMasSimilar( tcImpresora as Boolean ) as String
		local lcRetorno as String, lnPosicion as Integer
		local array laListaDeImpresoras[ 1 ]

		=aprinters( laListaDeImpresoras, 1 )

		lnPosicion = 0
		lcRetorno = ""
		
		* si la encuentro tambien la tengo que validar
		do while len( tcImpresora ) > 0 and lnPosicion = 0
			
			for i = 1 to alen( laListaDeImpresoras, 1 )	
				
				if tcImpresora $ laListaDeImpresoras(i,1)
					tcImpresora = laListaDeImpresoras(i,1)
					lnPosicion = ascan( laListaDeImpresoras, tcImpresora, 1, alen( laListaDeImpresoras, 1 ), 1, 1 + 8 )		
					
					exit
				endif
			endfor
			
			 if right( tcImpresora, 1 ) = "("
			 	exit
			 endif
				 
			if lnPosicion = 0
				tcImpresora = alltrim( substr( tcImpresora, 1, len( tcImpresora ) -1 ) )
			endif		
			
		enddo
		
		if lnPosicion > 0		
			lcRetorno = tcImpresora
		endif
		
		return lcRetorno
		
	endfunc
			
enddefine

*----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------
*----------------------------------------------------------------------------------
define class datosArea as custom
	cTabla = ""
	cRutaTabla = ""
	cCampos = ""
	oValores = null
	oAtributos = null
	cTipoArea = ""
	lEsCodigoDeBarra = .f.
	cDelimitador = ""
	cDelimitadorInsertCierre = ""
	cCondicion = ""
	cOrdenamiento = ""
	
	*-----------------------------------------------------------------------------------------	
	function init
		this.oValores = _screen.Zoo.crearObjeto( "ZooColeccion" )
		this.oAtributos = _screen.Zoo.crearObjeto( "ZooColeccion" )		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Ejecutar() as Void

		if file( addbs( this.cRutaTabla ) + this.cTabla )
			local lcItem as String, loError as Exception, loColSentencias as zoocoleccion OF zoocoleccion.prg
			loColSentencias = this.ObtenerColeccionDeSentencias()
			use ( addbs( this.cRutaTabla ) + this.cTabla ) in 0 alias tablaReporte
			for each lcItem in loColSentencias foxObject
				try		
					&lcItem
				Catch To loError
					goservicios.Errores.AgregarInformacion( "Sentencia: " + lcItem )
					goservicios.Errores.AgregarInformacion( "Algunas etiquetas no se pudieron imprimir." )
				endtry
			endfor 
			use in select( "tablaReporte" )
		endif 	

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeSentencias() as Collection 
		local loColSentencias as zoocoleccion OF zoocoleccion.prg, lcSentencia as String, lcSql as String, lcValores as String,;
		lnColTabla as Integer, lnCantAtributos as Integer, lnIteraciones as Integer, lcCadenaVacia as String, lnFilas as Integer,;
		lnI as Integer, lcTabla as String, lcAlias as String, lcTabla2 as String 
		
		local array laArrayAux[1]  

		store 1  to lnCantAtributos, lnFilas, lni 
		lcValores = ""
		with this
			if .oValores.count > 0
				lnCantAtributos = alines( laArrayAux, .oValores.item(1).cValor, "<!> " )
			endif 
			loColSentencias = _screen.zoo.crearobjeto( "ZooColeccion" )
			lcSql = "INSERT INTO tablaReporte ( " + this.cCampos + " ) values ("
			lcCadenaVacia = .ObtenerCadenaVacia( lnCantAtributos )
			lcTabla = addbs( .cRutaTabla ) + .cTabla 
			if file( lcTabla )

				lcAlias = alias()
				lcTabla2 = sys(2015)
				use ( addbs( this.cRutaTabla ) + this.cTabla ) in 0 alias(lcTabla2)
				select ( lcTabla2 )
				lnColTabla = afields( aTabla )
				use in select ( lcTabla2 )
				if !empty( lcAlias )
					select ( lcAlias )
				endif	
				
				lnIteraciones = lnColTabla / lnCantAtributos
				do while lnFilas <= .oValores.count
					lnCantidadDeAtributosVacios = 0
					do while lnI <= lnIteraciones
						lcValores = lcValores + iif( lnFilas > .oValores.count , lcCadenaVacia ,.oValores.item( lnFilas).cValor ) +  iif(lnI <> lnIteraciones , "<!> ", "" )
						lnFilas = lnFilas + 1
						lnI = lnI + 1
					enddo

					if .EsSentenciaVacia(lcValores)
					else
						lcSentencia = lcSql + lcValores + ")"
						lcSentencia = strtran( lcSentencia, "<!> ", "," )
						lcSentencia = .FiltrarCaracteresEspeciales( lcSentencia )
						loColSentencias.agregar( lcSentencia )
					endif
					
					lcValores = ""
					lnI=1
				enddo
				
				this.AgregarSentenciaOrdenamientos(@loColSentencias)
			endif 
		endwith
		return loColSentencias 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCadenaVacia( tnAtributos as Integer ) as String  
		local lcRetorno as String, lnj as Integer 
		lcRetorno = ""	 
		for lnj = 1 to tnAtributos 
			lcRetorno = lcRetorno + "[]" + iif(lnj <> tnAtributos , "<!> ","")
		endfor
	
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentenciaOrdenamientos(toSentencias as object) as void
		if !empty(this.cOrdenamiento)
			toSentencias.Agregar("select * from tablaReporte order by " + this.cOrdenamiento + " into cursor c_tablaReporte__2")
			toSentencias.Agregar("select tablaReporte")
			toSentencias.Agregar("delete all")
			toSentencias.Agregar("append from dbf('c_tablaReporte__2')")
			toSentencias.Agregar("use in ('c_tablaReporte__2')")
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function FiltrarCaracteresEspeciales( tcCadena as String ) as String  
		local lcRetorno as String
		
		lcRetorno = STRTRAN( tcCadena, chr(13) + chr(10), "]+chr(13)+chr(10)+[" )
		lcRetorno = STRTRAN( lcRetorno , chr(10) + chr(13), "]+chr(13)+chr(10)+[" )
		lcRetorno = STRTRAN( lcRetorno, chr(10), "]+chr(13)+chr(10)+[" )
		lcRetorno = STRTRAN( lcRetorno, chr(13), "]+chr(13)+chr(10)+[" )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaVacia( tcCadena as String ) as Boolean
		local llRetorno as Boolean, lcValoresSinEspacios as String 
	
		llRetorno = .F.
		lcValoresSinEspacios = STRTRAN( tcCadena,"[","" )
		lcValoresSinEspacios = STRTRAN( lcValoresSinEspacios,"]","" )
		lcValoresSinEspacios = STRTRAN( lcValoresSinEspacios,"/","" )
		lcValoresSinEspacios = STRTRAN( lcValoresSinEspacios,"<!>","" )
		if len( alltrim( lcValoresSinEspacios ) ) = 0
			llRetorno = .T.
		endif
	
		return llRetorno
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class ItemValores as custom
	cValor = ""
	cDelimitadorInsertCierre = ""	
enddefine

*-----------------------------------------------------------------------------------------
define class ObjetoLimite as Custom
	Limite = 0
	Restriccion = 0
	Diseno = ""
	AtributosAgrupamiento = ""
enddefine

*-----------------------------------------------------------------------------------------
define class ObjetoVariableDeReporte as Custom

	NombreOrganic = ""
	NombreCrystal = ""

enddefine

*-----------------------------------------------------------------------------------------
define class ResultadoCondicion as Custom
	Area = ""
	Resultado = .t.
enddefine

