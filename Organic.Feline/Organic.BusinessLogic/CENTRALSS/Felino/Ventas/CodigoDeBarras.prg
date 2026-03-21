define class CodigoDeBarras as zoosession of zoosession.prg

	#if .f.
		local this as CodigoDeBarras of CodigoDeBarras.prg
	#endif
		
	protected oEntidad as object, oColAtributosCombinacion as collection, lVerificaEquivalencias as Boolean, ;
		nCantidad as integer, cCodigoDeBarras as string, oItem as object, oTraductor as object, ;
		nPrecioAlternativo as Number, nMontoAlternativo as Number, lTienePrecioAlternativo As Boolean, ;
		lTieneMontoAlternativo as Boolean, lImporteAlternativoConImpuesto as Boolean

	lVerificaEquivalencias = .f.
	lAcumularCantidades = .f.
	oEntidad = null
	oColAtributosCombinacion = null
	nCantidad = 0
	cCodigoDeBarras = ""
	cCodigoDeBarrasSinConvertir = ""
	oItem = null
	oTraductor = null
	cCaracterSeparador = ""
	nCantidadPorDefecto = 0
	lMostrarPrimercoincidencia = .f.
	lPermiteCodigosEnMinusculas = .f.
	oConversorIdiomas = null
	nroItemActual = 0
	cCaracterSeparadorImpresion = ""
	oFactory_Convetidor_versiones_anteriores = null
	lEstoyAgregando = .F.
	llCompletarLectura  = .f.
	lcCaracteresDeRelleno = ""
	oInterprete = null	
	oAlternativo = null
	cValorAtributoPrePantallaDetectado = ""
	nPrecioAlternativo = 0
	nMontoAlternativo = 0
	lTienePrecioAlternativo = .f.
	lTieneMontoAlternativo = .f.
	lImporteAlternativoConImpuesto = .f.
	lNoCargoItem = .F.
	lSeguirPorCBRepetido = .f.
	lEstoySeteandoCodigoDeBarraAlternativo = .F.
	lAgregarCBYaLeidosaColConIDArticulo = .F.
	lAgregarCBYaLeidosaCol = .F.
	lEsPorTXT = .F.
	lTieneSecuencial = .F.
	lTieneSecuencialDF = .F.
	nOpcionPreguntaCodBarAltDF = 0
	lAcumulaCantidadesAlVolverDePrecarga = .f.
	lVieneDeCancelarFormularioDuro = .f.
	
	*-----------------------------------------------------------------------------------------
	function init()
		dodefault()
		this.lVerificaEquivalencias = goParametros.Felino.CodigosDeBarras.VerificarExistenciaDeEquivalenciaEnLectura
		this.lAcumularCantidades = goParametros.Felino.CodigosDeBarras.AcumularCantidades
		this.nCantidadPorDefecto = goRegistry.Felino.CantidadPorDefectoEnLecturaDeCodigodeBarras
		this.cCaracterSeparador = alltrim( goRegistry.Felino.CaracterSeparadorDeAtributosDeCombinacionParaLecturadeCodigodeBarras )
		this.lMostrarPrimercoincidencia = goparametros.Felino.CodigosDeBarras.MostrarPrimerCoincidenciaEnLaBusquedaDeCodigosDeBarra
		this.lPermiteCodigosEnMinusculas = goParametros.Nucleo.PermiteCodigosEnMinusculas
		This.cCaracterSeparadorImpresion = alltrim( goregistry.dibujante.caracterseparadordeatributosdecombinacionparaimpresiondecodigodebarras )
		this.llCompletarLectura  =  goParametros.Felino.CodigosDeBarras.CompletarLectura 	
		this.lcCaracteresDeRelleno 	=  alltrim( goParametros.Felino.CodigosDeBarras.CaracteresDeRelleno )
		this.lAcumulaCantidadesAlVolverDePrecarga = goParametros.Felino.CodigosDeBarras.AcumularCantidadesAlVolverDeLaPrecarga
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oInterprete_access() as object
		if !this.lDestroy and (type("this.oInterprete") <> "O" or isnull(this.oInterprete))
			this.oInterprete = _screen.zoo.CrearObjeto( "InterpreteCodigoDeBarras" )
		endif
		return this.oInterprete
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function oAlternativo_access() as object
		if !this.lDestroy and (type("this.oAlternativo") <> "O" or isnull(this.oAlternativo))
			this.oAlternativo = _screen.zoo.CrearObjeto( "CodigoDeBarrasAlternativo" )
		endif
		return this.oAlternativo
	endfunc

	*-----------------------------------------------------------------------------------------
	function oFactory_Convetidor_versiones_anteriores_access() as object
		if !this.lDestroy and (type("this.oFactory_Convetidor_versiones_anteriores") <> 'O' or isnull(this.oFactory_Convetidor_versiones_anteriores))
			this.oFactory_Convetidor_versiones_anteriores = _screen.zoo.CrearObjetoPorProducto( "Factory_convertidor_codigodebarras_versiones_anteriores" )
		endif
		return this.oFactory_Convetidor_versiones_anteriores
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oTraductor_access() as object
		if !this.lDestroy and (type("this.oTraductor") <> "O" or isnull(this.oTraductor))
			this.oTraductor = _screen.zoo.CrearObjeto( "TraductordeDatos" )
		endif
		return this.oTraductor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function oConversorIdiomas_access() as object
		if !this.lDestroy and (type("this.oConversorIdiomas") <> "O" or isnull(this.oConversorIdiomas))
			this.oConversorIdiomas = _screen.zoo.CrearObjeto( "ZooLogicSA.Core.Conversiones.ConversorIdiomas" )
		endif
		return this.oConversorIdiomas
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as object ) as Void
		this.oEntidad = toEntidad
		this.oColAtributosCombinacion = this.oEntidad.ObtenerAtributosCombinacion()
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarBlanqueo( tcAtributo as string, toItem as object ) as Void
		local lcAtributo as string, llEsAtributoCombinacion as Boolean, loError as zooexception OF zooexception.prg

		llEsAtributoCombinacion = .f.

		for each lcAtributo in this.oColAtributosCombinacion foxobject
			if alltrim( lower( tcAtributo ) ) == alltrim( lower( lcAtributo ) )
				toItem.lCargando = .t.
				try
					toItem.Equivalencia_pk = goLibrerias.ValorVacio ( toItem.Equivalencia_pk )
					toItem.CodigoDeBarras = goLibrerias.ValorVacio ( toItem.CodigoDeBarras )
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					toItem.lCargando = .f.
				endtry
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function BuscarEnEquivalencia( tcCodigoDeBarras as String, tlForzado as Boolean ) as String
		local lcRetorno as String, llEquivalenciaEncontrada as Boolean,lcCodigoABuscar1 as String,lcCodigoABuscar2 as String,;
			  lcCodigoABuscar3 as String, lcCodigoABuscar4 as String, lcNombreCodigoABuscar as String, lcSentencia as String

		lcRetorno = ""
		llEquivalenciaEncontrada = .f.
		this.oEntidad.lBusquedaForzada = tlForzado

		lcCodigoABuscar1  = this.oEntidad.TransformarAlAsignarEnCodigoDeBarra(  tcCodigoDeBarras )
        lcCodigoABuscar2 = goLibrerias.EscapeCaracteresSQLServer( This.TransformarCaracteresSegunRegion(  this.oEntidad.TransformarAlAsignarEnCodigoDeBarra( tcCodigoDeBarras ) ) )
        lcCodigoABuscar3 = this.InvertirCaracteresMayusculas( this.oEntidad.TransformarAlAsignarEnCodigoDeBarra( tcCodigoDeBarras ) )
        this.oEntidad.lBusquedaForzada = !tlforzado
		lcCodigoABuscar4 = this.oEntidad.TransformarAlAsignarEnCodigoDeBarra( lcCodigoABuscar3 ) 
        *lcCodigoABuscar4 = this.InvertirCaracteresMayusculas( this.oEntidad.TransformarAlAsignarEnCodigoDeBarra(lcCodigoABuscar3) )

        text to lcSentencia textmerge noshow
            select ccodigo from ZooLogic.EQUI where (   "Ccodigo" = <<"'" + lcCodigoABuscar1  + "'">> 
                                                     or "Ccodigo" = <<"'" + lcCodigoABuscar2 + "'">> 
                                                     or "Ccodigo" = <<"'" + lcCodigoABuscar3 + "'">> 
                                                     or "Ccodigo" = <<"'" + lcCodigoABuscar4+ "'">> 
                                                    ) and  EQUI.CCODIGO != ''
        endtext
        goServicios.Datos.EjecutarSql( lcSentencia, 'c_VerificarExistencia', set( 'Datasession' ) )

        select c_VerificarExistencia
        if reccount("c_VerificarExistencia") > 0
			llEquivalenciaEncontrada = .t.
			lcRetorno = ccodigo
			this.oEntidad.Codigo = lcRetorno 
		else
			this.oEntidad.Codigo = ""
		endif
        use in select( 'c_VerificarExistencia' )
        	
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Interpretar( toItem as object, tcTextoIngresado as string, toDetalle as object, tlNoProcesar as Boolean, tlControlaSecuencialEnCodBarAlt as Boolean, tlEsImportacionTI as Boolean ) as Void
		local llEquivalenciaEncontrada as Boolean, loError as exception, lcCodigo as string, loEx  as Exception, lcAtributo as String, ;
			  lcCodigoDeBarrasAlternativo as String, lcTextoAlternativo as String, llCombinacionEncontrada as Boolean, ;
			  llCombinacionEnDetalle as Boolean, llSeguir as Boolean

		lcCodigoDeBarrasAlternativo = ""
		llCombinacionEncontrada = .f.
		llEquivalenciaEncontrada = .f.
		
		This.nPrecioAlternativo = 0
		This.nMontoAlternativo = 0
		This.lTienePrecioAlternativo = .f.
		This.lTieneMontoAlternativo = .f.
		
		This.lNoCargoItem = .F.
		llSeguir = .T.
		this.lEstoySeteandoCodigoDeBarraAlternativo = .F.
		this.lAgregarCBYaLeidosaColConIDArticulo = .F.
		this.lAgregarCBYaLeidosaCol = .F.
		this.lTieneSecuencial = .F.
		this.lTieneSecuencialDF = .F.
		
		this.nOpcionPreguntaCodBarAltDF = 0
		if !empty( tcTextoIngresado )
			this.lEstoySeteandoCodigoDeBarraAlternativo = .T.
			this.nroItemActual = toItem.NroItem
			this.cCodigoDeBarrasSinConvertir = tcTextoIngresado
			this.SepararCantidadDeCodigoDeBarras( tcTextoIngresado, !tlNoProcesar )

			this.CargarCantidadDisplayVFD( toDetalle )
			
			if !empty( this.cCodigoDeBarras )
				
				lcCodigo = this.cCodigoDeBarras	
				
				if this.lVerificaEquivalencias and !this.ContieneSeparadorCodigDeBarras( this.ConvertirCodigoDeBarrasVersionAnterior( lcCodigo ) )
					this.cCodigoDeBarras = this.oTraductor.Traducir( lcCodigo )
				endif	
				
				if this.lVerificaEquivalencias
					this.cCodigoDeBarras = This.BuscarEnEquivalencia( this.cCodigoDeBarras, .f. )
					if empty( this.cCodigoDeBarras )
						this.cCodigoDeBarras = lcCodigo
					else						
						llEquivalenciaEncontrada = .t.
					endif

					if llEquivalenciaEncontrada
						this.InterpretarEquivalencia( toItem )
					else
						if !this.llCompletarLectura or ( this.llCompletarLectura and empty( this.lcCaracteresDeRelleno ) )
							this.cCodigoDeBarras = This.BuscarEnEquivalencia( this.cCodigoDeBarrasSinConvertir, .t. )
							if empty( this.cCodigoDeBarras )
								this.cCodigoDeBarras = lcCodigo
							else
								llEquivalenciaEncontrada = .t.
								this.InterpretarEquivalencia( toItem )
							endif
						endif						
					endif
				endif	

				if !llEquivalenciaEncontrada
					lcCodigoDeBarrasAlternativo = this.oAlternativo.BuscarEstructurasAlternativas( tcTextoIngresado, This.cCaracterSeparadorImpresion )
					if lcCodigoDeBarrasAlternativo != ""
						if tlControlaSecuencialEnCodBarAlt and this.TieneSecuencialCodBarAlt( lcCodigoDeBarrasAlternativo ) 
							this.lTieneSecuencial = .T.

							if !tlEsImportacionTI
								if This.CodigoYaProcesado( lcCodigoDeBarrasAlternativo, tcTextoIngresado, toItem, toDetalle ) &&toItem.iditemarticulos, 
									llSeguir = .F.
									This.lNoCargoItem = .T.
								endif
							endif
						endif
						
						if llSeguir
							if pemstatus( toItem, "Precio", 5 )
								if this.TienePrecioAlternativo( lcCodigoDeBarrasAlternativo )
									this.nPrecioAlternativo = this.ExtraerPrecioAlternativoLeido( lcCodigoDeBarrasAlternativo )
								endif
								if this.TieneMontoAlternativo( lcCodigoDeBarrasAlternativo )
									this.nMontoAlternativo = this.ExtraerMontoAlternativoLeido( lcCodigoDeBarrasAlternativo )
								endif
								if this.lTienePrecioAlternativo and this.lTieneMontoAlternativo
									lcCodigoDeBarrasAlternativo = this.RecomponerTextoLeidoDesdePrecioMonto( lcCodigoDeBarrasAlternativo )
								endif
							endif
							lcTextoAlternativo = this.ExtraerCantidadArticuloColorTalle( lcCodigoDeBarrasAlternativo )
							this.SepararCantidadDeCodigoDeBarras( lcTextoAlternativo, !tlNoProcesar )
						endif
					else
						if tlControlaSecuencialEnCodBarAlt and this.ControlaSecuencialEnCodBarras( tcTextoIngresado )
							this.lTieneSecuencialDF = .T.
							if tlEsImportacionTI
								if this.lTieneSecuencialDF and "+" $ tcTextoIngresado
									toItem.Invalida = .T.
								endif
							else
								if This.CodigoYaProcesado( "", tcTextoIngresado, toItem, toDetalle )
									llseguir = .F.
									This.lNoCargoItem = .T.
								endif
							endif
						endif
					endif
				endif

				if llSeguir
					if tlNoProcesar or this.VerificaCodigoNoIngresadoYAcumula( toDetalle, toItem )
						this.cCodigoDeBarras = CHRTRAN( this.cCodigoDeBarras, "#&·^", "ÑñÑñ" ) && las demas opciones dependen del tipo de teclado que tenga configurado el cliente
						
						if left( tcTextoIngresado, 01 ) != "$" and !llEquivalenciaEncontrada
							this.cCodigoDeBarras = this.ComponerCodigo( this.cCodigoDeBarras )
						endif

						if this.VerificaCodigoNoIngresadoYAcumula( toDetalle, toItem )
							if This.oEntidad.Cantidad != 0 and llEquivalenciaEncontrada
								this.nCantidad = this.nCantidad * this.oEntidad.Cantidad	
							endif

							if !llEquivalenciaEncontrada
								if lcCodigoDeBarrasAlternativo != ""
									*!* Si encontre un codigo alternativo vuelvo hacia atras para buscar primero por combinacion *!*
									tcTextoIngresado = this.cCodigoDeBarrasSinConvertir
									this.SepararCantidadDeCodigoDeBarras( tcTextoIngresado, !tlNoProcesar )
								endif

								if this.oColAtributosCombinacion.count > 0							
									try
										if this.lEsPorTXT and this.lTieneSecuencial and !empty( lcCodigoDeBarrasAlternativo )
											this.SepararCantidadDeCodigoDeBarras( lcTextoAlternativo, !tlNoProcesar )
										endif

										this.InterpretarCodigoDeBarras( toItem )
										llCombinacionEncontrada = .t.
									catch to loex
										if this.lVerificaEquivalencias and upper( alltrim ( this.cCodigoDeBarras )) != upper( alltrim( goRegistry.Felino.CodigoDeArticuloSena ) )
											loEx.UserValue.agregarinformacion( "El dato buscado " + alltrim( tcTextoIngresado )+ " de la entidad EQUIVALENCIAS no existe." )
											loEx.UserValue.agregarinformacion( "El dato buscado " + alltrim( this.cCodigoDeBarras )+ " no existe." )
										endif
									endtry	
								endif 
								
								llCombinacionEnDetalle = type('toDetalle') = 'O' and toDetalle.count > 0 and !this.VerificaCodigoNoIngresadoYAcumula( toDetalle, toItem )

								if !llCombinacionEnDetalle and !llCombinacionEncontrada
									if lcCodigoDeBarrasAlternativo != ""
										this.SepararCantidadDeCodigoDeBarras( lcTextoAlternativo, !tlNoProcesar )
									
										if this.oColAtributosCombinacion.count > 0							
											for each lcAtributo in this.oColAtributosCombinacion foxobject
												if pemstatus( toItem, lcAtributo, 5 )
													This.AsignarEnAtributo( toItem, lcAtributo, '' )
												endif
											endfor
											try
												this.InterpretarCodigoDeBarras( toItem )
												if pemstatus( toItem, "Precio", 5 )
													this.CalcularPrecioSegunImpuesto( toItem, lcCodigoDeBarrasAlternativo )
												endif
											catch to loex
												loEx.UserValue.agregarinformacion( "El dato buscado " + alltrim( tcTextoIngresado )+ " no existe." )
												goServicios.Errores.LevantarExcepcion( loEx )						
											endtry	
										endif	
									else
										goServicios.Errores.LevantarExcepcion( loEx )
									endif
								endif
							endif
					
							if llSeguir
								this.AsignarCodigoDeBarras( toItem )

								if this.lAgregarCBYaLeidosaColConIDArticulo
									toDetalle.oColCBAltYaLeidosConIDArt.Agregar( this.cCodigoDeBarrasSinConvertir, toItem.iditemarticulos )
								endif
								
								if this.lAgregarCBYaLeidosaCol
									toDetalle.oColCBAltYaLeidos.Agregar( this.cCodigoDeBarrasSinConvertir, this.cCodigoDeBarrasSinConvertir )
								endif
								
								if !toItem.lProcesandoPrePantalla and toItem.lUtilizaCantidades
									if !tlNoProcesar and toitem.ValidarExistenciaCamposFijos() 
										if toItem.Cantidad == this.nCantidad and this.nCantidad != 0
											toItem.eventoComponenteStock( "CANTIDAD", toItem )
										else
											toItem.Cantidad = this.nCantidad
										endif
									else
										toItem.eventoComponenteStock( "CANTIDAD", toItem )
									endif
								endif
							endif
						endif
						
						if toItem.lProcesandoPrePantalla
							toItem.lProcesandoPrePantalla = .f.
							this.ProcesarPorPrepantalla( this.cValorAtributoPrePantallaDetectado )
							this.VerificaCargaPorPrepantallaYAcumula( toDetalle )
						endif
					else
						if (this.lTieneSecuencialDF or this.lTieneSecuencial) and this.lAgregarCBYaLeidosaColConIDArticulo
							toDetalle.oColCBAltYaLeidosConIDArt.Agregar( this.cCodigoDeBarrasSinConvertir, toItem.iditemarticulos )
						endif

						if this.lTieneSecuencialDF and this.lAgregarCBYaLeidosaCol
							toDetalle.oColCBAltYaLeidos.Agregar( this.cCodigoDeBarrasSinConvertir, this.cCodigoDeBarrasSinConvertir )
						endif
					endif
				endif
			endif
		endif

		this.lEstoySeteandoCodigoDeBarraAlternativo = .f.

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificaCargaPorPrepantallaYAcumula( toDetalle as object ) as Void
		local lnCargadosPorPrePantalla as Integer, lnTotalDetallePrePantalla as Integer, lnIndicePrepantalla as Integer, ;
			loItemPrepantalla as object, lnI as integer, loItemDetalle as object, lnUltimoIdModificado as Integer, ;
			loColItemsSumarizados as zoocoleccion OF zoocoleccion.prg
		if this.lAcumulaCantidadesAlVolverDePrecarga and vartype( toDetalle ) = "O"
			
			lnUltimoIdModificado = 0
			lnCargadosPorPrePantalla = 0
			lnTotalDetallePrePantalla = 0
			if pemstatus( toDetalle, "nCargadosPorPrePantalla", 5 ) and pemstatus( toDetalle, "nTotalDetallePrePantalla", 5 )
				lnCargadosPorPrePantalla = toDetalle.nCargadosPorPrePantalla
				lnTotalDetallePrePantalla = toDetalle.nTotalDetallePrePantalla
			endif
			
			if !empty( lnCargadosPorPrePantalla ) 
				loColItemsSumarizados = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
				for lnIndicePrepantalla = lnTotalDetallePrePantalla to lnTotalDetallePrePantalla - lnCargadosPorPrePantalla +1 step -1
					
					loItemPrepantalla = toDetalle.item[ lnIndicePrepantalla ]
					for lnI = 1 to lnTotalDetallePrePantalla - lnCargadosPorPrePantalla
						if loColItemsSumarizados.GetKey( transform( lnI ) ) > 0
							loop
						endif
						
						loItemDetalle = toDetalle.item[ lnI ]
						
						if !this.SonMismoSigno( loItemDetalle.Cantidad, loItemPrepantalla.Cantidad ) ; 
								or (pemstatus( loItemDetalle, "afe_codigo", 5 ) and !empty( alltrim( loItemDetalle.afe_codigo ) )) ;
								or (pemstatus( loItemDetalle, "IdKit", 5 ) and !empty( alltrim( loItemDetalle.IdKit ) )) ;
								or !this.VerificarItemNoAfectadoPorUnaPromocion( loItemDetalle ) ;
								or this.VerificarItemSecuencial( todetalle, loItemDetalle )
							loop
						endif
						if this.VerificarCombinacionExistenteEnPrePantalla( loItemDetalle, loItemPrepantalla ) and this.TieneSaldoParaAfectar( loItemDetalle, loItemPrepantalla.Cantidad )
							if pemstatus( loItemPrepantalla, "Precio", 5 ) and this.VerificarCambioDePrecioPrePantalla( loItemDetalle, loItemPrepantalla )
								loop
							endif
							lnUltimoIdModificado = lnIndicePrepantalla
							with toDetalle
								.LimpiarItem()
								.CargarItem( lnI )
								.oItem.Cantidad = .oItem.Cantidad + loItemPrepantalla.Cantidad 
								.Actualizar()
							endwith
							this.EventoCantidadHaCambiado( lnI )
							loColItemsSumarizados.Add( lnI, transform( lnI ) )
							this.EliminarItemPrePantalla( toDetalle, lnIndicePrepantalla )
							exit
						endif
					endfor
					
				endfor
				
				if !empty( lnUltimoIdModificado )
					loColItemsSumarizados.Remove( -1 )
					with toDetalle
						.LimpiarItem()
						if !empty( .item( lnTotalDetallePrePantalla ).Articulo_Pk )
							.CargarItem( lnTotalDetallePrePantalla )
						endif
					endwith
					this.ReposicionarAlVolverDePrePantalla() 
				endif
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarItemPrePantalla( toDetalle as Object, tnIndice as Integer ) as Void
		local lnNroItem as Integer
		with toDetalle
			.CargarItem( tnIndice )
			lnNroItem = .oItem.NroItem
			.LimpiarItem()
			.oItem.NroItem = lnNroItem
			.Actualizar()
			this.EventoCantidadHaCambiado( tnIndice )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarItemSecuencial( toDetalle as Object, toItem as Object ) as Void
		local llRetorno
		llRetorno = iif( pemstatus( toItem, "idItemArticulos", 5 ), .t., .f. )
		llRetorno = iif( llRetorno and toDetalle.oColCBAltYaLeidosConIDArt.getkey( toItem.idItemArticulos ) > 0, .t., .f. )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularPrecioSegunImpuesto( toItem as Object, tcCodigoDeBarrasAlternativo as String ) as Void
		local llMostrarImpuestos as Boolean, lnPorcentajeIVA as Number, lnAuxMontoAlternativo as Number

		lnPorcentajeIVA = ( toItem.PorcentajeIVA / 100 ) + 1
		llMostrarImpuestos = toItem.oComponenteFiscal.MostrarImpuestos()
		lnAuxMontoAlternativo = this.nMontoAlternativo
		if this.lTienePrecioAlternativo
			if this.lImporteAlternativoConImpuesto
				toItem.Precio = iif( llMostrarImpuestos, this.nPrecioAlternativo, this.nPrecioAlternativo / lnPorcentajeIVA )
			else
				toItem.Precio = iif( llMostrarImpuestos, this.nPrecioAlternativo * lnPorcentajeIVA, this.nPrecioAlternativo )
			endif
		else
			if this.lTieneMontoAlternativo
				if this.nCantidad > 1
					if this.lImporteAlternativoConImpuesto
						toItem.Precio = iif( llMostrarImpuestos, this.nMontoAlternativo / this.nCantidad, ( this.nMontoAlternativo  / lnPorcentajeIVA ) / this.nCantidad )
					else
						toItem.Precio = iif( llMostrarImpuestos, ( this.nMontoAlternativo * lnPorcentajeIVA ) / this.nCantidad, this.nMontoAlternativo / this.nCantidad )
					endif
				else
					if empty( toItem.PrecioDeLista )
						if this.lImporteAlternativoConImpuesto
							toItem.Precio = iif( llMostrarImpuestos, this.nMontoAlternativo, this.nMontoAlternativo / lnPorcentajeIVA )
						else
							toItem.Precio = iif( llMostrarImpuestos, this.nMontoAlternativo * lnPorcentajeIVA, this.nMontoAlternativo )
						endif
					else
						if this.lImporteAlternativoConImpuesto
							if toItem.olistadeprecios.condicioniva = 2
								lnAuxMontoAlternativo = this.nMontoAlternativo / lnPorcentajeIVA 
							endif
						else
							if toItem.olistadeprecios.condicioniva = 1
								lnAuxMontoAlternativo = this.nMontoAlternativo * lnPorcentajeIVA 
							endif
						endif
						if toItem.olistadeprecios.condicioniva = 1
							this.nCantidad = iif( llMostrarImpuestos, lnAuxMontoAlternativo / toItem.PrecioDeLista, ( lnAuxMontoAlternativo  / lnPorcentajeIVA ) / ( toItem.PrecioDeLista / lnPorcentajeIVA ) )
						else
							this.nCantidad = iif( llMostrarImpuestos, ( lnAuxMontoAlternativo * lnPorcentajeIVA ) / ( toItem.PrecioDeLista * lnPorcentajeIVA ), lnAuxMontoAlternativo / toItem.PrecioDeLista )
						endif
					endif
				endif
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecomponerTextoLeidoDesdePrecioMonto( tcCodigoDeBarrasAlternativo as String ) as String
		local lcNuevoTexto as String, lnCantidad as Number
		lnCantidad = this.nMontoAlternativo / this.nPrecioAlternativo
		lcNuevoTexto = transform( lnCantidad )
		lcNuevoTexto = lcNuevoTexto + "+" + this.ExtraerArticuloColorTalle( tcCodigoDeBarrasAlternativo )
		lcNuevoTexto = lcNuevoTexto + This.cCaracterSeparadorImpresion + transform( this.nPrecioAlternativo )
		lcNuevoTexto = lcNuevoTexto + This.cCaracterSeparadorImpresion + This.cCaracterSeparadorImpresion
		if this.lImporteAlternativoConImpuesto
			lcNuevoTexto = lcNuevoTexto + "IVA"
		endif
		return lcNuevoTexto
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RecomponerTextoLeidoDesdeCantidadMonto( tcCodigoDeBarrasAlternativo as String ) as String
		local lcNuevoTexto as String
		lcNuevoTexto = ""
		return lcNuevoTexto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ExtraerArticuloColorTalle( tcCodigoDeBarrasAlternativo as String ) as String
		local lcTextoLeido
		lcTextoLeido = left( tcCodigoDeBarrasAlternativo, at( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo, 3 ) - 1 )
		lcTextoLeido = substr( lcTextoLeido, at( "+", tcCodigoDeBarrasAlternativo ) + 1 )
		return lcTextoLeido
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExtraerCantidadArticuloColorTalle( tcCodigoDeBarrasAlternativo as String ) as String
		local lcTextoLeido
		lcTextoLeido = left( tcCodigoDeBarrasAlternativo, at( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo, 3 ) - 1 )
		return lcTextoLeido
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TienePrecioAlternativo( tcCodigoDeBarrasAlternativo as String ) as Boolean
		local llResultado as Boolean
		llResultado = .f.
		if occurs( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo ) > 3
			if at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 4 ) - at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 3 ) > 1
				llResultado = .t.
			endif
		endif
		this.lTienePrecioAlternativo = llResultado
		return llResultado 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ExtraerPrecioAlternativoLeido( tcCodigoDeBarrasAlternativo as String ) as Number
		local lcPrecioLeido as String
		lcPrecioLeido = ""
		if occurs( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo ) >= 3
			lcPrecioLeido = substr( alltrim( tcCodigoDeBarrasAlternativo ), at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 3 ) + 1 )
			if at( This.cCaracterSeparadorImpresion, alltrim( lcPrecioLeido ) ) > 0
				lcPrecioLeido = left( alltrim( lcPrecioLeido ), at( This.cCaracterSeparadorImpresion, alltrim( lcPrecioLeido ) ) - 1 )
			endif
			this.lImporteAlternativoConImpuesto = this.LosImportesLeidosTienenIvaIncluido( tcCodigoDeBarrasAlternativo )
		endif
		return val( lcPrecioLeido )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneMontoAlternativo( tcCodigoDeBarrasAlternativo as String ) as Boolean
		local llResultado as Boolean
		llResultado = .f.
		if occurs( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo ) > 4
			if at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 5 ) - at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 4 ) > 1
				llResultado = .t.
			endif
		endif
		this.lTieneMontoAlternativo = llResultado
		return llResultado 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExtraerMontoAlternativoLeido( tcCodigoDeBarrasAlternativo as String ) as Number
		local lcMontoLeido as String
		lcMontoLeido = ""
		if occurs( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo ) >= 4
			lcMontoLeido = substr( alltrim( tcCodigoDeBarrasAlternativo ), at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 4 ) + 1 )
			if at( This.cCaracterSeparadorImpresion, alltrim( lcMontoLeido ) ) > 0
				lcMontoLeido = left( alltrim( lcMontoLeido ), at( This.cCaracterSeparadorImpresion, alltrim( lcMontoLeido ) ) - 1 )
			endif
			this.lImporteAlternativoConImpuesto = this.LosImportesLeidosTienenIvaIncluido( tcCodigoDeBarrasAlternativo )
		endif
		return val( lcMontoLeido )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function LosImportesLeidosTienenIvaIncluido( tcCodigoDeBarrasAlternativo as String ) as Boolean
		local llResultado as Boolean, lcCondicionImpositiva as String
		llResultado = .f.
		lcCondicionImpositiva = ""
		if occurs( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo ) > 4
			lcCondicionImpositiva = substr( alltrim( tcCodigoDeBarrasAlternativo ), at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 5 ) + 1 )
			if "IVA" $ alltrim( upper( lcCondicionImpositiva ) )
				llResultado = .t.
			endif
		endif
		return llResultado 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarCantidadDisplayVFD( toDetalle as Object ) as Void
		if vartype( toDetalle ) = "O" and pemstatus( toDetalle, "lDisplayVFD", 5 ) and toDetalle.lDisplayVFD
			toDetalle.nCantidadItemVFD = this.nCantidad
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ConvertirCodigoDeBarrasVersionAnterior( tcCodigoDeBarras as String ) as String
		local loFactory as Object, loConvertidor as Object, lcCodigo as String

		lcCodigo = tcCodigoDeBarras 

		loConvertidor = this.oFactory_Convetidor_versiones_anteriores.ObtenerConvertidor( tcCodigoDeBarras )
		
		if !isnull( loConvertidor )
			lcCodigo = loConvertidor.Procesar( this.cCaracterSeparadorImpresion )
		endif
		
		return lcCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarCodigoDeBarras( toItem as object ) as Void
		local loError as exception

		toItem.lCargando = .t.
		try
			toItem.CodigoDeBarras = this.cCodigoDeBarras
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			toItem.lCargando = .f.
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificaCodigoNoIngresadoYAcumula( toDetalle as object, toItem as object ) as Boolean
		local i as integer, llResultado as Boolean, llPositivo as Boolean, llNegativo as Boolean, ;
			llNeutro as Boolean, loItem as object, i as integer
		llResultado = .t.
		
		if vartype( toDetalle ) = "O"
			if this.lAcumularCantidades and !toItem.lProcesandoPrePantalla and toItem.lUtilizaCantidades and toItem.cContexto != "I" and !this.UtilizaNuevaOperatoriaEnBaseA( todetalle.oItem ) ;
			  and !this.lTieneSecuencialDF and !this.lTieneSecuencial

				for i = 1 to toDetalle.count
					loItem = toDetalle.item[ i ]

					if !this.SonMismoSigno(loItem.Cantidad, This.nCantidad ) or !this.VerificarItemNoAfectadoPorUnaPromocion( loItem ) or this.VerificarItemParticipantes( todetalle, loItem )
						loop
					endif

					if this.VerificarCombinacionExistente( loItem, toDetalle.oitem ) and this.TieneSaldoParaAfectar( loItem, This.nCantidad )
						if pemstatus( toItem, "Precio", 5 ) and this.VerificarCambioDePrecio( loItem )
							loop
						endif
						this.lEstoyAgregando = .t.
						with toDetalle
							for each lcAtributo in this.oColAtributosCombinacion foxobject
								if pemstatus( .oItem, lcAtributo, 5 )
									.oItem.&lcAtributo = ""
								endif
							endfor
							.LimpiarItem()
							.CargarItem( i )

							if upper( alltrim( .oItem.CodigoDeBarras )) = 'SEÑA'
								.oItem.Cantidad = this.nCantidad + .oItem.Cantidad
							else
								try
									.oItem.Cantidad = IIF( this.oEntidad.Cantidad != 0, ( this.nCantidad * this.oEntidad.Cantidad ) + .oItem.Cantidad, this.nCantidad + .oItem.Cantidad )
								catch to loError
									.oItem.Cantidad = IIF( this.oEntidad.Cantidad != 0, ( this.nCantidad * this.oEntidad.Cantidad ) - .oItem.Cantidad, this.nCantidad - .oItem.Cantidad )
									goServicios.Errores.LevantarExcepcion( loError )
								endtry
							endif

							.Actualizar()
							this.EventoCantidadHaCambiado( i )

							.LimpiarItem()
							This.CargarItemActual( toDetalle ) 
						endwith
						llResultado = .f.
						exit
					endif
				endfor
			endif
		endif
		return llResultado
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarCambioDePrecio( toItem as Object ) as Boolean
		local llRetorno as Boolean, llMostrarImpuestos as Boolean, lnPorcentajeIVA as Number, ;
			  lnPrecioItem as Number, lnPrecioAuxiliar as Number, lnAuxMontoAlternativo as Number, ;
			  llListaConImpuestos as Boolean

		llRetorno = .f.
		lnPrecioAuxiliar = 0
		lnAuxMontoAlternativo = this.nMontoAlternativo
		lnPrecioItem = toItem.Precio
		lnPorcentajeIVA = ( toItem.PorcentajeIVA / 100 ) + 1
		llMostrarImpuestos = iif( round( toItem.Precio, 2 ) = round( toItem.PrecioConImpuestos, 2 ), .t., .f. )
		llListaConImpuestos = iif( round( toItem.PrecioDeLista, 2 ) = round( toItem.PrecioSinImpuestos, 2 ), .f., .t. )

		if this.lTienePrecioAlternativo
			if this.lImporteAlternativoConImpuesto
				lnPrecioAuxiliar = iif( llMostrarImpuestos, this.nPrecioAlternativo, this.nPrecioAlternativo / lnPorcentajeIVA )
			else
				lnPrecioAuxiliar = iif( llMostrarImpuestos, this.nPrecioAlternativo * lnPorcentajeIVA, this.nPrecioAlternativo )
			endif
			if lnPrecioItem != round( lnPrecioAuxiliar, 2 )
				llRetorno = .t.
			endif
		else
			if this.lTieneMontoAlternativo
				if this.nCantidad > 1
					if this.lImporteAlternativoConImpuesto
						lnPrecioAuxiliar = iif( llMostrarImpuestos, this.nMontoAlternativo / this.nCantidad, ( this.nMontoAlternativo  / lnPorcentajeIVA ) / this.nCantidad )
					else
						lnPrecioAuxiliar = iif( llMostrarImpuestos, ( this.nMontoAlternativo * lnPorcentajeIVA ) / this.nCantidad, this.nMontoAlternativo / this.nCantidad )
					endif
				else
					if empty( toItem.PrecioDeLista )
						if this.lImporteAlternativoConImpuesto
							lnPrecioAuxiliar = iif( llMostrarImpuestos, this.nMontoAlternativo, this.nMontoAlternativo / lnPorcentajeIVA )
						else
							lnPrecioAuxiliar = iif( llMostrarImpuestos, this.nMontoAlternativo * lnPorcentajeIVA, this.nMontoAlternativo )
						endif
					else
						if this.lImporteAlternativoConImpuesto
							if !llListaConImpuestos
								lnAuxMontoAlternativo = this.nMontoAlternativo / lnPorcentajeIVA 
							endif
						else
							if llListaConImpuestos
								lnAuxMontoAlternativo = this.nMontoAlternativo * lnPorcentajeIVA 
							endif
						endif
						if llListaConImpuestos
							lnPrecioAuxiliar = iif( llMostrarImpuestos, toItem.PrecioDeLista, toItem.PrecioDeLista / lnPorcentajeIVA )
							this.nCantidad = iif( llMostrarImpuestos, lnAuxMontoAlternativo / toItem.PrecioDeLista, ( lnAuxMontoAlternativo / lnPorcentajeIVA ) / ( toItem.PrecioDeLista / lnPorcentajeIVA ) )
						else
							lnPrecioAuxiliar = iif( llMostrarImpuestos, toItem.PrecioDeLista * lnPorcentajeIVA, toItem.PrecioDeLista )
							this.nCantidad = iif( llMostrarImpuestos, ( lnAuxMontoAlternativo * lnPorcentajeIVA ) / ( toItem.PrecioDeLista * lnPorcentajeIVA ), lnAuxMontoAlternativo / toItem.PrecioDeLista )
						endif
					endif
				endif
				if lnPrecioItem != round( lnPrecioAuxiliar, 2 )
					llRetorno = .t.
				endif
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarCambioDePrecioPrePantalla( toItem as object, toItemPrePantalla as object ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = .f.
		if !empty( toItemPrePantalla.Precio ) and toItemPrePantalla.Precio != toItem.Precio
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SonMismoSigno(tnValor1 as Integer , tnValor2 as Integer) as Boolean
		return sign(tnValor1*tnValor2) >= 0 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarItemNoAfectadoPorUnaPromocion( toItem as Object ) as Boolean
		local llRetorno as Boolean, lcIdItemArticulo as string
		
		llRetorno = .t.
		if ( pemstatus( toItem, "IdItemArticulos", 5 ) )
			if !pemstatus( toItem, "lAfectadoPorUnaPromocion", 5 )
				toItem.AddProperty( "lAfectadoPorUnaPromocion", .f. )
			endif
			toItem.lAfectadoPorUnaPromocion = .f.
			lcIdItemArticulo = toItem.IdItemArticulos
			this.EventoValidarArticuloAfectadoPorPromocion( toItem )
			llRetorno = !toItem.lAfectadoPorUnaPromocion
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarItemActual( toDetalle as detalle OF detalle.prg ) as Void
		if This.NroItemActual <> 0
			toDetalle.CargarItem( This.NroItemActual )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombredelaEntidad (tcAtributo as string) as Void
		local lcValor as string, lnposicion as Integer
		lcValor = ""
		lnposicion=atc('_PK',upper(tcAtributo))
		if lnposicion > 0
			lcValor = substr(tcAtributo,1,lnposicion -1)
		else
			lcValor = tcAtributo 
		endif
		return lcValor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarAplicaComportamientodeAtributodelaEntidad ( toItem as Object, tcCodigoBarra as String, tcAtributo as string, tcEntidad as String ) as Boolean
		local llRetorno as boolean, lcValor as string
		llRetorno = .f.
		
		if !empty( tcCodigoBarra) and !empty( tcAtributo ) and len( rtrim( tcCodigoBarra )) < len(rtrim( tcAtributo ))						
			if pemstatus( toItem.&tcEntidad, "Ocomportamientocodigosugerido", 5 )							
				if vartype(toItem.&tcEntidad..Ocomportamientocodigosugerido)="O"
					if  toItem.&tcEntidad..Ocomportamientocodigosugerido.lTienecomportamientoCargado
						llRetorno = .t.	
					endif
				endif		
			endif
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearComportamientodelAtributodelaEntidad ( tcValor as String, toDetalle as Object ) as String
		local lcValor as string
		
		lcValor = toDetalle.Ocomportamientocodigosugerido.FormatearCodigoSugerido(tcValor)
		return lcValor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarCombinacionExistente( toItem as object, toDetalleOitem as Object ) as Void
		local llRetorno as boolean, lcAtributo as string, lnCantAtributos as integer, i as integer, lcAux as string, lnCantAciertos as integer, lcCodigoDeBarras as String, lcCodigoDeBarras2 as String, ;
			  lcValor as String, lcAtributo as string, lcEntidad as String
		local array laCombinacion[1]
			llRetorno = .t.
			
			if inlist( occurs( This.cCaracterSeparadorImpresion, this.cCodigoDeBarras ), 1, 2 )
				lcCodigoDeBarras = rtrim( this.cCodigoDeBarras ) + This.cCaracterSeparadorImpresion + " "
			else
				lcCodigoDeBarras = this.cCodigoDeBarras
			endif			
			for j = 1 to this.oColAtributosCombinacion.count
				lcAtributo = this.oColAtributosCombinacion.item[ j ]
				if this.oEntidad.codigo = this.cCodigoDeBarras
					llRetorno = llRetorno and ( rtrim( this.oEntidad.&lcAtributo ) == rtrim( toItem.&lcAtributo ) )
				else
					lnCantAtributos = alines( laCombinacion, lcCodigoDeBarras, 0 , this.cCaracterSeparador, this.cCaracterSeparadorImpresion )
					if lnCantAtributos >= j
						if pemstatus( this.oEntidad, lcAtributo, 5 )
							if !this.lPermiteCodigosEnMinusculas
								lcValor = upper( laCombinacion[j] )
							else
								lcValor = laCombinacion[j]
							endif
							*----------------------------------------------------------
							lcEntidad = this.ObtenerNombredelaEntidad( lcAtributo) 
							if this.VerificarAplicaComportamientodeAtributodelaEntidad ( toDetalleOitem, lcValor, toItem.&lcAtributo, lcEntidad )
								lcValor = this.SetearComportamientodelAtributodelaEntidad ( lcValor, toDetalleOitem.&lcEntidad)
							endif
							*-----------------------------------------------------------
						endif
						llRetorno = llRetorno and ( rtrim( lcValor ) == rtrim( toItem.&lcAtributo ) ) 
					else
						llRetorno = .f.
					endif
				endif
				if !llRetorno
					exit
				endif
			endfor

		if !llRetorno and this.oEntidad.codigo != this.cCodigoDeBarras
			lnCantAtributos = alines( laCombinacion, lcCodigoDeBarras, 0 , this.cCaracterSeparador )
			if ( this.oColAtributosCombinacion.count >= lnCantAtributos )
				lnCantAciertos = 0
				for i = 1 to this.oColAtributosCombinacion.count  &&lnCantAtributos
			
				if lnCantAtributos >= i 
						lcAtributo = this.oColAtributosCombinacion[ i ]
						lcAux = laCombinacion[ i ]

						if pemstatus( toItem, lcAtributo, 5 )
							if !this.lPermiteCodigosEnMinusculas
								lcAux = upper( lcAux )
								
								*----------------------------------------------------------
								lcEntidad = this.ObtenerNombredelaEntidad( lcAtributo ) 
								if this.VerificarAplicaComportamientodeAtributodelaEntidad ( toDetalleOitem, lcAux, toItem.&lcAtributo, lcEntidad)
									lcAux = this.SetearComportamientodelAtributodelaEntidad ( lcAux , toDetalleOitem.&lcEntidad)
								endif
								*-----------------------------------------------------------
							endif

							if rtrim( toItem.&lcAtributo ) == rtrim( lcAux )
								lnCantAciertos = lnCantAciertos + 1
							endif
						endif
					endif
				endfor

				llRetorno = ( lnCantAciertos = this.oColAtributosCombinacion.count )

				if !llretorno and ( lnCantAtributos = lnCantAciertos )
					for i = lnCantAtributos + 1 to this.oColAtributosCombinacion.count  
						lcAtributo = this.oColAtributosCombinacion[ i ]
						if empty( toItem.&lcAtributo ) 
							llRetorno = .t.
						else
							llRetorno = .f.
							exit
						endif	
					endfor
				endif
			endif
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarCombinacionExistenteEnPrePantalla( toItem as object, toItemPrePantalla as object ) as Void
		local llRetorno as boolean, lcAtributo as string
		
		llRetorno = .t.
		for lnI = 1 to this.oColAtributosCombinacion.count
			lcAtributo = this.oColAtributosCombinacion.item[ lnI ]
			if pemstatus( toItem, lcAtributo, 5 ) and pemstatus( toItemPrePantalla, lcAtributo, 5 ) 
				llRetorno = llRetorno and ( rtrim( toItem.&lcAtributo ) == rtrim( toItemPrePantalla.&lcAtributo ) )
			else
				llRetorno = .f.
			endif
			if !llRetorno
				exit
			endif
		endfor

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoCantidadHaCambiado( tnFila as integer ) as Void
		*jbarrionuevo # 15/07/09 13:40:36 Evento para refresco de la fila en que cambió la cantidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoValidarArticuloAfectadoPorPromocion( tnIdItemArticulo as integer ) as Void
		*terminator # 15/11/12 13:40:36 Evento para preguntarle a la entidad si el id del articulo fue afectado por una promocion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SepararCantidadDeCodigoDeBarras( tcTextoIngresado as string, tlParsear as Boolean ) as Void
		local lnCantidad as Integer, lcAuxCantidad as String, lnOldCanDecimales as Integer, lnDecimalesDefault as Integer

		if tlParsear and "+" $ tcTextoIngresado

			lcAuxCantidad = left( tcTextoIngresado, atc( "+", tcTextoIngresado ) - 1 )
			
			lnOldCanDecimales = set( "DECIMALS" )
			lnDecimalesDefault = goServicios.PrecisionDecimalenCantidad.ObtenerDecimalesSegunAtributo( "Cantidad", "ITEMARTICULOSVENTAS" )
			lnDecimalesDefault = iif( empty( lnDecimalesDefault ), 2, lnDecimalesDefault )

			if lnOldCanDecimales != lnDecimalesDefault 
				lcAuxCantidad = substr( lcAuxCantidad, 1, at( ".", lcAuxCantidad ) + lnDecimalesDefault )
			endif
		
			set decimals to lnDecimalesDefault
			lnCantidad = val( lcAuxCantidad )
			set decimals to lnOldCanDecimales 
			
			this.nCantidad = lnCantidad

			if empty( lcAuxCantidad )
				This.nCantidad = this.nCantidadPorDefecto
			endif

			this.cCodigoDeBarras = substr( tcTextoIngresado, atc( "+", tcTextoIngresado ) + 1 )
		else
			this.nCantidad = this.nCantidadPorDefecto
			this.cCodigoDeBarras = tcTextoIngresado
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarPorPrepantalla( tcValor as String ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReposicionarAlVolverDePrePantalla() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InterpretarEquivalencia( toItem ) as Void
		local lcAtributo as string, loError as zooexception OF zooexception.prg

		if toItem.lProcesandoPrePantalla
			lcAtributo = this.oColAtributosCombinacion.Item[1]
			this.cValorAtributoPrePantallaDetectado = this.oEntidad.&lcAtributo
		else
			for each lcAtributo in this.oColAtributosCombinacion foxobject
				if pemstatus( toItem, lcAtributo, 5 ) and pemstatus( this.oEntidad, lcAtributo, 5 )
					This.AsignarEnAtributo( toItem, lcAtributo, this.oEntidad.&lcAtributo )
				endif
			endfor
			toItem.lCargando = .t. 
			try
				toItem.Equivalencia_pk = this.cCodigoDeBarras
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				toItem.lCargando = .f.
			endtry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function InterpretarCodigoDeBarras( toItem ) as Void
		local lcAtributo as string, lnCantAtributos as integer, i as integer, loEx as Exception 
		local array laCombinacion[1]
		lnCantAtributos = alines( laCombinacion, this.cCodigoDeBarras, 0 , this.cCaracterSeparador, this.cCaracterSeparadorImpresion )		
		if this.oColAtributosCombinacion.count >= lnCantAtributos
			if toItem.lProcesandoPrePantalla
				this.cValorAtributoPrePantallaDetectado = laCombinacion[1]
			else
		
				for i = 1 to this.oColAtributosCombinacion.count  &&lnCantAtributos
					if lnCantAtributos >= i
						lcAtributo = this.oColAtributosCombinacion[i]

						if pemstatus( toItem, lcAtributo, 5 )
							if !this.lPermiteCodigosEnMinusculas
								laCombinacion[i] = upper( laCombinacion[i] )
							endif
							This.AsignarEnAtributo( toItem, lcAtributo, iif( i <= 3, rtrim( laCombinacion[i] ), laCombinacion[i] ) )
						endif
					endif
					
				endfor
			
			endif

			if this.lVerificaEquivalencias
				this.AsignarEquivalencia( this.ObtenerEquivalenciaSegunAtributos( @laCombinacion ), toItem )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AsignarEnAtributo( toItem as Object, tcAtributo as String, tcValor as String ) as Void
		local loError as zooexception OF zooexception.prg, loMal as zooexception OF zooexception.prg

		try
			toItem.&tcAtributo = tcValor
			
		catch to loError
			this.EventoAntesDeProcesarCatchCodigoDeBarras( toItem )
			
			if this.lVieneDeCancelarFormularioDuro or left( tcValor , 01 ) == "$" 
				goServicios.Errores.LevantarExcepcion( loError )
			endif

			try
				toItem.&tcAtributo = this.TransformarCaracteresSegunRegion( tcValor )
			catch 
				try
					toItem.&tcAtributo = this.InvertirCaracteresMayusculas( tcValor )
				catch to loMal
					goServicios.Errores.LevantarExcepcion( loError )
				endtry
			endtry
		finally
			this.EventoDespuesDeProcesarCatchCodigoDeBarras( toItem )
		endtry

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoAntesDeProcesarCatchCodigoDeBarras( toItem as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeProcesarCatchCodigoDeBarras( toItem as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEquivalenciaSegunAtributos( taCombinacion ) as Void
		local lcXml as string, lcHaving as string, i as integer, lcCursor as string, ;
			lcRetorno as string, lcValor as string

		external array taCombinacion
		lcRetorno = ""
		lcHaving = ""
		for i = 1 to this.oColAtributosCombinacion.count
			if i > alen( taCombinacion )
				lcValor = " "
			else
				lcValor = taCombinacion[ i ]
			endif
			lcHaving = lcHaving + " and " + strtran( this.oColAtributosCombinacion[ i ], "_pk", "" ) + " == '" ;
				+ lcValor + "'"
		endfor
		lcHaving = substr( lcHaving, 6 )
		lcXml = this.oEntidad.oAD.ObtenerDatosEntidad( "", lcHaving )
		lcCursor = sys( 2015 )
		this.XmlACursor( lcXml, lcCursor )

		if this.lMostrarPrimercoincidencia
			if reccount( lcCursor ) > 0
				select &lcCursor
				go top
				lcRetorno = &lcCursor..Codigo
			endif
		else
			if reccount( lcCursor ) = 1
				lcRetorno = &lcCursor..Codigo
			endif
		endif
		use in select( lcCursor )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AsignarEquivalencia( tcEquivalencia as string, toItem as object ) as Void
		local loError as exception

		toItem.lCargando = .t.

		try
			toItem.Equivalencia_pk = tcEquivalencia
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			toItem.lCargando = .f.
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function release() as Void
		if !isnull( this.oEntidad )
			this.oEntidad.release()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ContieneSeparadorCodigDeBarras( tcTexto ) as boolean
		return at( upper( this.cCaracterSeparador ), upper( tcTexto ) ) > 0
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TransformarCaracteresSegunRegion( tcCadenaCaracteres as string ) as string
		local lcCadenaConvertida as String
	
		lcCadenaConvertida = This.oConversorIdiomas.ConvertirIdioma( tcCadenaCaracteres )

		return lcCadenaConvertida
	endfunc

	*-----------------------------------------------------------------------------------------
	function InvertirCaracteresMayusculas( tcCodigo as String) as string
		local lcCodigoInvertido as String
		lcCodigoInvertido = goservicios.librerias.invertirmayusculasminusculas( tcCodigo, .T. )
		return lcCodigoInvertido
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtieneCapsLock() as boolean
		
		return capslock()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ComponerCodigo( tcCodigo as String ) as Void
		return this.oInterprete.interpretar ( tcCodigo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarItemParticipantes( toDetalle as Object, toItem as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		if pemstatus( toDetalle, "EsItemParticipante", 5 )
			llRetorno = toDetalle.EsItemParticipante( toItem )
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function UtilizaNuevaOperatoriaEnBaseA( toItem as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if pemstatus( toItem, "oCompEnBaseA", 5) and toItem.oCompEnBaseA.nOperatoria > 1
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneSaldoParaAfectar( toItem as Object, tnCantidad as Integer ) as Boolean
		local llRetorno as Boolean, lnCantidad as Integer
		llRetorno = .t.
		lnCantidad = this.nCantidad
		if vartype( tnCantidad ) = "N"
			lnCantidad = tnCantidad
		endif
		if pemstatus(toItem, "Afe_Codigo", 5) and pemstatus(toItem, "Afe_SaldoOriginal", 5)
			llRetorno = (!empty( toItem.Afe_Codigo ) and ( toItem.Cantidad + lnCantidad ) <= toItem.Afe_SaldoOriginal ) or ( empty(toItem.Afe_Codigo ))
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneSecuencialCodBarAlt( tcCodigoDeBarrasAlternativo as String ) as boolean
		local llRetorno as Boolean
		llRetorno = .f.

		if occurs( This.cCaracterSeparadorImpresion, tcCodigoDeBarrasAlternativo ) >= 6
			 if at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 7) - at(This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 6) > 1
				llRetorno = .t.
			endif
		endif

		return llRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CodigoYaProcesado( tcCodigoDeBarrasAlternativo as String, tcTextIngresado as String, toItem as Object, toDetalle as Object ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = .F.

		* Por si acaso que me agreguen cantidad + codigo de barra, lo verifico y no lo dejo hacerlo, tipo (2+00503355!00!M!67178)
		if this.lTieneSecuencialDF and type("tcTextIngresado")="C" and "+" $ tcTextIngresado
			if this.lEsPorTXT
				toItem.Invalida = .T.
			else
				lcMensaje = "No esta permitido cargar cantidades en los códigos de barra con número secuencial."
				goServicios.Errores.LevantarExcepcion( lcMensaje )
			endif
		endif

		if !llRetorno
			if this.lEsPorTXT
				* Si estoy procesando un TXT y encuentra un cod. bar. alternativo que ya cargo, no debo informar, pero los tengo que marcar para procesarlos despues
				toItem.lTieneSecuencial = .T.
				toItem.nQuePregunto = iif(empty(this.nOpcionPreguntaCodBarAltDF),this.ObtenerValorPregunta( tcCodigoDeBarrasAlternativo ),this.nOpcionPreguntaCodBarAltDF )  
			else
				if type("toDetalle") = "O"
					if toDetalle.oColCBAltYaLeidos.count > 0 and toDetalle.oColCBAltYaLeidos.Buscar( this.cCodigoDeBarrasSinConvertir )
						* si lo encuentra en la coleccion se supone que es un codigo valido
						llRetorno = this.SacarMensajeCodigoYaProcesada( tcCodigoDeBarrasAlternativo, tcTextIngresado, toItem )
						
						if !llRetorno
							this.lAgregarCBYaLeidosaColConIDArticulo = .T.
						endif
					else
						
						if this.lTieneSecuencialDF
							this.lAgregarCBYaLeidosaCol = .T.
						else
							toDetalle.oColCBAltYaLeidos.Agregar( this.cCodigoDeBarrasSinConvertir, this.cCodigoDeBarrasSinConvertir )
						endif

						this.lAgregarCBYaLeidosaColConIDArticulo = .T.
					endif
				endif
			endif
		endif
				
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function SacarMensajeCodigoYaProcesada( tcCodigoDeBarrasAlternativo as String, tcTextIngresado as String, toItem as Object ) as Boolean
		local lnOpcionPregunta as Integer, llRetorno as Boolean, lcMensaje as String, lcArticulo as String, lcColor as String, lcTalle as String
	
		lcArticulo = this.ExtraerArtColTallAlternativoLeido(iif(empty(tcCodigoDeBarrasAlternativo),tcTextIngresado,tcCodigoDeBarrasAlternativo), "ART")
		lcColor    = this.ExtraerArtColTallAlternativoLeido(iif(empty(tcCodigoDeBarrasAlternativo),tcTextIngresado,tcCodigoDeBarrasAlternativo), "COL")
		lcTalle    = this.ExtraerArtColTallAlternativoLeido(iif(empty(tcCodigoDeBarrasAlternativo),tcTextIngresado,tcCodigoDeBarrasAlternativo), "TAL")

		if this.lTieneSecuencialDF
			lnOpcionPregunta = this.nOpcionPreguntaCodBarAltDF
		else
			if this.lTieneSecuencial
				lnOpcionPregunta = this.ObtenerValorPregunta( tcCodigoDeBarrasAlternativo )								
			endif
		endif

		if empty( lnOpcionPregunta )
			lnOpcionPregunta = 1
		endif
		
		lcMensaje = "La lectura del código " + alltrim( tcTextIngresado ) + " para el artículo " + lcArticulo + ;
					" color " + lcColor + " talle " + lcTalle + " ya fue realizada."

		this.EventoPreguntarQueHacerCBRepetido( lcMensaje, lnOpcionPregunta, toItem.odetalle.cnombre )

		llRetorno = this.lSeguirPorCBRepetido
		
		if !this.lAcumularCantidades and !llRetorno
			this.lAgregarCBYaLeidosaColConIDArticulo = .T.
		endif

		return llRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorPregunta( tcCodigoDeBarrasAlternativo as String) as Integer
		local lnRetorno as Integer
			
		lnRetorno =	int( val( substr( tcCodigoDeBarrasAlternativo, at( This.cCaracterSeparadorImpresion, alltrim( tcCodigoDeBarrasAlternativo ), 7 ) + 1, 1 ) ) )
				
		return lnRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExtraerArtColTallAlternativoLeido( tcCodigoDeBarrasAlternativo as String, tcQueExtraigo as String ) as Number
		local lcRetorno as String, lnDesde as Integer, lnHasta as Integer
		lcRetorno = ""
		
		do case
			case tcQueExtraigo = "ART"
				lnDesde = at("+",tcCodigoDeBarrasAlternativo)
				lnHasta = at(This.cCaracterSeparadorImpresion,tcCodigoDeBarrasAlternativo) - lnDesde
			case tcQueExtraigo = "COL"
				lnDesde = at(This.cCaracterSeparadorImpresion,tcCodigoDeBarrasAlternativo)
				lnHasta = at(This.cCaracterSeparadorImpresion,tcCodigoDeBarrasAlternativo,2) - lnDesde
			case tcQueExtraigo = "TAL"
				lnDesde = at(This.cCaracterSeparadorImpresion,tcCodigoDeBarrasAlternativo,2)
				lnHasta = at(This.cCaracterSeparadorImpresion,tcCodigoDeBarrasAlternativo,3) - lnDesde
		endcase
		
		lcRetorno = alltrim( substr(tcCodigoDeBarrasAlternativo,lnDesde+1,lnHasta-1) )

		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarQueHacerCBRepetido( tcMensaje as String, tnOpcionPregunta as integer, tcNombreDetalle as String ) as Boolean
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarItemsDeColecciones( tcIDItemArticulo as String, toDetalle as Object )
		local lnCant as Integer, lcItem as String, lcCodigoDeBarraABorrar as String, llAunQuedan as Boolean
		lnCant = 0

		if type("toDetalle") = "O" and pemstatus(toDetalle,"oColCBAltYaLeidosConIDArt",5)
			if toDetalle.oColCBAltYaLeidosConIDArt.Count > 0 and toDetalle.oColCBAltYaLeidosConIDArt.Buscar( tcIDItemArticulo )

				lcCodigoDeBarraABorrar = toDetalle.oColCBAltYaLeidosConIDArt.item(tcIDItemArticulo )
				toDetalle.oColCBAltYaLeidosConIDArt.Remove( tcIDItemArticulo )				

				for each lcItem in toDetalle.oColCBAltYaLeidosConIDArt
					if lcItem = lcCodigoDeBarraABorrar
						llAunQuedan = .T.
						exit
					endif
				endfor
				
				if !llAunQuedan
					toDetalle.oColCBAltYaLeidos.remove( lcCodigoDeBarraABorrar )
				endif
			endif
		endif			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ControlaSecuencialEnCodBarras( tcTextoIngresado ) as boolean
		local llRetorno as Boolean

		llRetorno = this.oColAtributosCombinacion.count > 0 and ;
				occurs( This.cCaracterSeparadorImpresion, tcTextoIngresado ) > (this.oColAtributosCombinacion.count - 1) and ;
				type(transform(substr(tcTextoIngresado ,at("!", tcTextoIngresado , this.oColAtributosCombinacion.count )+1))) = "N" and ;
				this.TieneUnCodBarAltConSecuencialDF()
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneUnCodBarAltConSecuencialDF() as boolean
		local lcSentencias as String, lcCursor as String, lcCursorAnt as String, llRetorno as String

		lcCursorAnt = alias()
		lcCursor = sys(2015)

		lcSentencias = "select codigo, CtrlUni from [" + _screen.zoo.app.nombreProducto + "_" + alltrim( _screen.zoo.app.cSucursalActiva ) + "].[ZooLogic].[CODBARALTER] " + ;	
					   "where Habilitado = 1 and CtrlUni <> 0 and UsaSecuen = 1"

		goServicios.Datos.EjecutarSentencias( lcSentencias, "CODBARALTER", "", lcCursor, this.DataSessionId )
		
		select ( lcCursor )
		
		if reccount( lcCursor ) > 0
			this.nOpcionPreguntaCodBarAltDF = &lcCursor..CtrlUni
			llRetorno = .T.
		endif
		
		use in ( lcCursor )
		
		if !empty( lcCursorAnt ) and used( lcCursorAnt )
			select ( lcCursorAnt )
		endif
		
		return llRetorno	

	endfunc 

enddefine
