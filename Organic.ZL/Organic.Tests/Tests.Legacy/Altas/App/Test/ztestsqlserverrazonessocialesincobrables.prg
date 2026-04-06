**********************************************************************
Define Class zTestSqlServerRazonesSocialesIncobrables As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestSqlServerRazonesSocialesIncobrables Of zTestSqlServerRazonesSocialesIncobrables.prg
	#Endif

	cArchivoMock = ""
	cArchivoMock1= ""
	cArchivoMockZlServiciosLoteBaja = ""
	CodDireccion = ""

	*---------------------------------
	Function Setup

		Local loEntSino
		loEntSino = _Screen.zoo.instanciarentidad( 'Sinocombo' )

		Try
			loEntSino.cod = "0"
		Catch
			loEntSino.nuevo()
			loEntSino.cod = "0"
			loEntSino.Descr = "NO"
			loEntSino.grabar()
		Endtry

		Try
			loEntSino.cod = "1"
		Catch
			loEntSino.nuevo()
			loEntSino.cod = "1"
			loEntSino.Descr = "SI"
			loEntSino.grabar()
		Endtry

		goParametros.zl.ValoresSugeridos.ContactoPredeterminadoEnBajaDeItemsPorDeudoresIncobrables = "00001"
		goParametros.zl.ValoresSugeridos.MotivoDeBajaDeDeudoresIncobrables = "12"

		loEntSino.Release()

		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()
		CrearFuncionItemsVigentes()
		this.CodDireccion = CrearDirecciones()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial()
		CrearSP_SP_IyD_ActualizarBajaEnIS()
		CrearFuncion_func_NormalizarNombre()
		CrearFuncion_funcArticuloConModuloActivacionOnLine()
	Endfunc

	*---------------------------------
	Function TearDown
		Local loEntSino
		loEntSino = _Screen.zoo.instanciarentidad( 'Sinocombo' )
		loEntSino.cod = "0"
		loEntSino.Eliminar()
		loEntSino.cod = "1"
		loEntSino.Eliminar()
		loEntSino.Release()
	Endfunc


	*-----------------------------------------------------------------------------------------
	Function zTestSqlServerGenerarBajaDeItemsVigentes
		Local loRZ As enttidad, loRZNueva As enttidad, loEntCambioRZ As entidad, loCliente As entidad Of entidad.prg ,;
			loZlServiciosLote As entidad Of entidad.prg, loArticulo As entidad Of entidad.prg , loISAlta As entidad Of entidad.prg,;
			lnNroISALTA As Integer, loProducto As Object , ldFechaBaja As Date , loTalonario As Object, loModulos As Object, lcProductoZL As String,;
			lcModulo1 As String, lcModulo2 As String, loClasificacionCte As Object, loClasificacionv2 As Object, ;
			loError As Exception, loEsquemaComisional As Object , loEntidad As Custom, loEntRzInc As Object, lnUltimoNumero As Integer, lcSql as String,;
			loCol as Collection, loCol2 as Collection , loZLTIPOUSUARIOZL as Object, loLegajoops as Object, loPais as Object, loProvincia as Object
			

private gomensajes as Object
_screen.mocks.agregarmock( "Mensajes" )
_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Nuevo', .T. ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:38
_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Enlazar', .T., "[Detallegrupocomunica.EventoObtenerLogueo],[inyectarLogueo]" ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:38
_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Enlazar', .T., "[Detallegrupocomunica.EventoObtenerInformacion],[inyectarInformacion]" ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:38
_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Enlazar', .T., "[Detallegrupocomunica.EventoAdvertirLimitePorDiseno],[EventoAdvertirLimitePorDiseno]" ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:38
_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Enlazar', .T., "[Detallegrupocomunica.EventoCancelarCargaLimitePorDiseno],[EventoCancelarCargaLimitePorDiseno]" ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:38
_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Cancelar', .T. ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:38
_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.]" ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 13/11/25 15:19:39

goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )

		loError = Null

		=CrearZlServiciosLoteBaja_Test( This )

		loZLTIPOUSUARIOZL = _Screen.zoo.instanciarentidad( "ZLTIPOUSUARIOZL" )
		With loZLTIPOUSUARIOZL 
			Try
				.cCod = '1'
				.Eliminar()
			Catch
			Endtry
			Try
				.nuevo()
				.cCod = '1'
				.Descrip = 'desc' + Sys( 2015 )
				.grabar()
			catch				
			Endtry
			.Release()
		Endwith
		loZLTIPOUSUARIOZL = Null		
		
		loLegajoops = _Screen.zoo.instanciarentidad( "Legajoops" )
		With loLegajoops 
			Try
				.Codigo = '1'
				.Eliminar()
			Catch
			Endtry
			Try
				.nuevo()
				.Codigo = '1'
				.Cortesia = 'desc' + Sys( 2015 )
				.tipousuarioZL_pk = '1'
				.UsuarioActivo = .t.
				.grabar()
			catch			
			Endtry
			.Release()
		Endwith
		loLegajoops = Null			
		
		Try
			_Screen.Mocks.AgregarMock( 'ZlServiciosLoteBaja', Forceext( This.cArchivoMockZlServiciosLoteBaja, '' ) )

			This.agregarmocks( "ListadePrecios,Valor,Direcciones,Actualizarzoo,estadov2,ZLASIGESTADOSRZADM,contactos, TIPOARTICULOITEMSERVICIO, ZLAMBITOSSERIE,zlaltagrupocom, TIPOMODULOS, LEGAJOOPS, COMMOTIVOBAJA")

			_screen.mocks.AgregarSeteoMetodo( 'contactos', 'Codigo_despuesdeasignar', .T. ) && ztestsqlserverrazonessocialesincobrables.ztestsqlservergenerarbajadeitemsvigentes 04/10/12 11:04:09
			_Screen.Mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
			_Screen.Mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
			_Screen.Mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Nuevo', .T. )
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Grabar', .T. )
			_Screen.Mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', '01' )
			_Screen.Mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN]" )
			loCol = newobject("collection")
			_Screen.Mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'GenerarComprobantesRazonesSocialesIncobrables', loCol, "[*COMODIN]" )

			loCol2 = newobject("ZooInformacion", "ZooInformacion.prg" )			
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Obtenerinformacion', loCol2 ) &&, "[*COMODIN]" )
			
			_Screen.Mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Numero_despuesdeasignar', .T. )
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerLogueo],[inyectarLogueo]" ) && ztestcambioderazonsocial.ztestefecuarcambiorazonsocial 20/09/11 17:14:31
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerInformacion],[inyectarInformacion]" ) && ztestcambioderazonsocial.ztestefecuarcambiorazonsocial 20/09/11 17:14:32
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerLogueo],[inyectarLogueo]" ) && ztestcambioderazonsocial.ztestefecuarcambiorazonsocial 20/09/11 17:14:33
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerInformacion],[inyectarInformacion]" ) && ztestcambioderazonsocial.ztestefecuarcambiorazonsocial 20/09/11 17:14:33
			loEntidad = Newobject( "objEntidad" )
			_Screen.Mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'razonsocial_access', loEntidad )

			*!*	 DRAGON 2028
			lcSql = "delete from itemserv"
			goServicios.Datos.Ejecutarsentencias( lcSql, "itemserv", "", "", Set("datasession") )
			lcSql = "delete from relaciontiis"
			goServicios.Datos.Ejecutarsentencias( lcSql, "relaciontiis", "", "", Set("datasession") )

			=CrearItemzlvinculacionitemsdetalleitems_Test( This )
			_Screen.Mocks.AgregarMock( 'Itemzlvinculacionitemsdetalleitems', Forceext( This.cArchivoMock, '' ) )

			=CrearItemZlserviciosloteSubitems_Test( This )
			_Screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', Forceext( This.cArchivoMock1, '' ) )

			loTalonario = _Screen.zoo.instanciarentidad("talonario")
			Local loError As Exception, loEx As Exception
			Try
				loTalonario.codigo = "ALTASIS"
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ALTASIS"
				loTalonario.entidad = "ZLSERVICIOSLOTE"
				loTalonario.grabar()
			Endtry

			Try
				loTalonario.codigo = "BAJASIS"
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "BAJASIS"
				loTalonario.entidad = "ZLSERVICIOSLOTEBAJA"
				loTalonario.grabar()
			Endtry

			Try
				loTalonario.codigo = "ITEMSERCOD"
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ITEMSERCOD"
				loTalonario.entidad = "ZLITEMSSERVICIOS"
				loTalonario.grabar()
			Endtry

			Try
				loTalonario.codigo = "VINCULACIONITEMS"
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "VINCULACIONITEMS"
				loTalonario.grabar()
			Endtry

			Try
				loTalonario.codigo = "ZLCLASIFICACIONCLIENTES"
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ZLCLASIFICACIONCLIENTES"
				loTalonario.grabar()
			Endtry

			loTalonario.Release()
			
			loEsquemaComisional = _Screen.zoo.instanciarentidad( "Esquemacomisional" )
			With loEsquemaComisional
				Try
					.cCod = 32
					.Eliminar()
				Catch
				Endtry
				Try
					.nuevo()
					.cCod = 32
					.Descrip = 'Esquema de prueba ' + Sys( 2015 )
					.Owner_Pk = '1'
					.grabar()
				catch 				
				Endtry
			Endwith
			loEsquemaComisional.Release()
			loEsquemaComisional = Null

			loClasificacionv2 = _Screen.zoo.instanciarentidad("Clasificacionv2")

			With loClasificacionv2
				Try
					loClasificacionv2.codigo = '99'
				Catch To loError
					loClasificacionv2.nuevo()
					loClasificacionv2.codigo = '99'
					loClasificacionv2.nombre = 'Clasificacion 99'
					loClasificacionv2.grabar()
				Endtry
			Endwith
			loClasificacionv2.Release()

			loClasificacionv2 = _screen.zoo.instanciarentidad( "Clasificacionv2" )
			with loClasificacionv2
				try
					.Codigo = '37'
					.Eliminar()
				catch
				finally
					.Nuevo()
					.Codigo = '37'
					.Nombre = 'Clasificacion 37'
					.Grabar()
				endtry 
			endwith
			loClasificacionv2.release()

			loModulos = _Screen.zoo.instanciarentidad( "zlismodulo" )
			With loModulos
				.nuevo()
				lcModulo1 = .cCod
				.Descrip = "Toma de inventario"
				.TipoModulo_pk = "1"
				.grabar()

				.nuevo()
				lcModulo2 = .cCod
				.Descrip = "Comuica"
				.TipoModulo_pk = "2"
				.grabar()
			Endwith
			loModulos.Release()

			loProducto = _Screen.zoo.instanciarentidad( "productozl" )
			With loProducto
				.nuevo()
				lcProductoZL = .cCod
				.Descrip = 'prod test'
				.grabar()
			Endwith
			loProducto.Release()

			loSerie = Createobject( "serieTest" )
			With loSerie
				Try
					.nroserie = '508000'
					.Eliminar()
				Catch
				Finally
					.cNumeroSugeridoTest = '508000'
					.nuevo()
					.ambito_pk = "0001"
					.productozoologic_pk = lcProductoZL
					.nombre = "serie test"
					.direcc_pk = '00001'
					.grabar()
				Endtry

				Try
					.nroserie = '508001'
					.Eliminar()
				Catch
				Finally
					.cNumeroSugeridoTest = '508001'
					.nuevo()
					.ambito_pk = "0001"
					.productozoologic_pk = lcProductoZL
					.nombre = "serie TI test"
					.direcc_pk = '00001'
					.grabar()
				Endtry
			Endwith

			loArticulo = _Screen.zoo.instanciarentidad( "zlIsarticulos" )
			With loArticulo
				Try
					.codigo = '00-AA'
					.Eliminar()
				Catch
				Finally
					.nuevo()
					.codigo = '00-AA'
					.Descrip = 'art 00-AA'
					.tipoArticulo_pk = '01'
					.productozoologic_pk = lcProductoZL
					.desactivado = .F.
					.detalleclasificaciones.oitem.clasificacion_pk = '99'
					.detalleclasificaciones.oitem.detalleclasificacion = '99'
					.detalleclasificaciones.actualizar()
					.grabar()
				Endtry
				Try
					.codigo = '00-TI'
					.Eliminar()
				Catch
				Finally
					.nuevo()
					.codigo = '00-TI'
					.Descrip = 'art 00-TI'
					.tipoArticulo_pk = '01'
					.productozoologic_pk = lcProductoZL
					.desactivado = .F.
					.detalleclasificaciones.oitem.clasificacion_pk = '99'
					.detalleclasificaciones.oitem.detalleclasificacion = '99'
					.detalleclasificaciones.actualizar()

					.detalleModulos.oitem.CodigoModulo_pk = lcModulo1
					.detalleModulos.oitem.Descrip = "Toma inventario"
					.detalleModulos.actualizar()
					.grabar()
				Endtry
				Try
					.codigo = '00-HS'
					.Eliminar()
				Catch
				Finally
					.nuevo()
					.codigo = '00-HS'
					.Descrip = 'art 00-HS'
					.tipoArticulo_pk = '01'
					.productozoologic_pk = lcProductoZL
					.desactivado = .F.
					.detalleclasificaciones.oitem.clasificacion_pk = '99'
					.detalleclasificaciones.oitem.detalleclasificacion = '99'
					.detalleclasificaciones.actualizar()

					.detalleModulos.oitem.CodigoModulo_pk = lcModulo2
					.detalleModulos.oitem.Descrip = "Comunica"
					.detalleModulos.actualizar()
					.grabar()
				Endtry
			Endwith

			loCliente = _Screen.zoo.instanciarentidad( "ZLCLIENTES" )

			With loCliente
				.nuevo()
				.nombre = "cliente test RZ Inco"
				.direcc_pk = this.CodDireccion
				.grabar()
			Endwith

			loClasificacionCte = _Screen.zoo.instanciarentidad( "ZLCMPCLASCLIENTE" )

			With loClasificacionCte
				Try
					.codigo = loCliente.codigo
					.Eliminar()
				Catch
				Finally
					.nuevo()
					.FKClie_pk = loCliente.codigo
					.Registrado_pk = "ZTEST"
					.detalleclasificaciones.oitem.CodClasifi_pk = '99'
					.detalleclasificaciones.actualizar()
					.grabar()
				Endtry
			Endwith

			loPais = _screen.zoo.instanciarentidad( "NACIONALIDAD" )
			with loPais
				try
					.Ccod = "00"
					.Eliminar()
				catch
				finally
					.Nuevo()
					.Ccod = "00"
					.Descrip = "00"
					.Grabar()
				endtry
			endwith	

			loProvincia = _screen.zoo.instanciarentidad( "PROVINCIA" )
			with loProvincia
				try
					.Codigo = "00"
					.Eliminar()
				catch
				finally
					.Nuevo()
					.Codigo = "00"
					.Descripcion = "00"
					.Pais_pk = "00"
					.Grabar()
				endtry
			endwith	

			loRZ = Createobject( "RzTest" )
			With loRZ
				.cCodigoSugerido = '99999'
				Try
					.codigo = '99999'
					.Eliminar()
				catch
				Finally	
					.nuevo()
					.descripcion = 'Razon Social Prueba'
					.listadeprecios_pk = '99999'
					.cliente_pk = loCliente.codigo
					.SituacionFiscal_pk = 1
					.cuit = '11111111113'
					.FormaDePago_pk = 'EFE'
					.direcc_pk = this.CodDireccion
					.VersionSistema = 88.88
					.reGIMENCOMISION = 32
					.Direccion = "Direccion de prueba"
					.Provincia_pk = "00"
					.RegimenComisionVirtual_pk = 32
					.grabar()
				Endtry
			Endwith

*			loZlServiciosLote = _Screen.zoo.instanciarentidad( "zlServiciosLote" )
			loZlServiciosLote = _screen.zoo.Crearobjeto( "ZLSERVICIOSLOTE_AUX", "zTestSqlServerRazonesSocialesIncobrables.prg" )
			loZlServiciosLote.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )
			
			With loZlServiciosLote
				.nuevo()
				.RazonSocial_pk = loRZ.codigo
				.contacto_pk = '01'

				.subitems.oitem.Serie_Pk = '508000'
				.subitems.oitem.Articulo_pk = '00-AA'
				.subitems.actualizar()

				.subitems.LimpiarItem()
				.subitems.oitem.Serie_Pk = '508000'
				.subitems.oitem.Articulo_pk = '00-TI'
				.subitems.oitem.SerieTI_Pk = '508001'
				.subitems.actualizar()

				.subitems.LimpiarItem()
				.subitems.oitem.Serie_Pk = '508000'
				.subitems.oitem.Articulo_pk = '00-HS'
				.subitems.oitem.GrupoCom_Pk = 9999
				.subitems.actualizar()
				.grabar()
			Endwith

			*----------------------------------------------
			* Declara la RZ social Incobrable
			loEntRzInc = _Screen.zoo.instanciarentidad("ZLRZINCOBRABLE")
			With loEntRzInc
				.nuevo()
				.RazonSocial_pk = loRZ.codigo
				.grabar()
			Endwith

			*-- Obtengo el Ultimo numero de Baja de Items
			loEntItemsVig = _Screen.zoo.instanciarentidad( 'ZLSERVICIOSLOTEBAJA' )
			loEntItemsVig.ultimo()
			lnUltimoNumero = loEntItemsVig.Numero


			*----------------------------------------------
			*No Autoriza que se declare como incobrable
			*----------------------------------------------

			* Autorizaciones
			loAut = _Screen.zoo.instanciarentidad( 'Autorizaciones' )
			With loAut
				.nuevo()
				.estado_PK = "0"
				.grabar()
			Endwith

			*----------------------------------------------
			* Declara la RZ social Incobrable Aprueba
			loEntRzIncApr = _Screen.zoo.instanciarentidad("ZlRzIncobrableAprob")
			
			With loEntRzIncApr
				.nuevo()
				.NumRegInco_PK = loEntRzInc.NumeroInt
				.EstadoAprob_PK = "0"
				.numaprobacion_PK = loAut.Numero
				.grabar()
			Endwith

			* Valida que no genere comprobantes de baja por rechazar la solicitud de declaracion de incobrable
			loEntItemsVig.ultimo()
			This.assertequals( "No deberia generar ningun comprobante de baja de items",lnUltimoNumero, loEntItemsVig.Numero )


			*----------------------------------------------
			* Autoriza que se declare como incobrable
			*----------------------------------------------

			* Autorizaciones
			With loAut
				.nuevo()
				.estado_PK = "1"
				.grabar()
			Endwith

			*----------------------------------------------
			* Declara la RZ social Incobrable Aprueba
			With loEntRzIncApr
				.ultimo()
				.Eliminar()
				.nuevo()
				.NumRegInco_PK = loEntRzInc.NumeroInt
				.EstadoAprob_PK = "1"
				.numaprobacion_PK = loAut.Numero
				.grabar()
			Endwith

			* Valida que genere comprobantes de baja de items y esten los datos correctos
			With loEntItemsVig
				.ultimo()
				This.asserttrue( "Deberia generar un comprobante de baja de items", lnUltimoNumero < loEntItemsVig.Numero )
				This.assertequals( "Debería tener la RZ", Alltrim( loRZ.codigo ), Alltrim( .RazonSocial_pk ))
				This.assertequals( "Debería tener el contacto", "00001", Alltrim( .contacto_pk ))
				This.assertequals( "Debería tener el motivo de baja ", "12", Alltrim(.MotivoBaja_PK ))
				This.assertequals( "Debería la observacion tener el mensaje",;
					"Generado Automáticamente por el Comprobante de Aprobación de Razones Sociales Incobrables nº " + Transform(loEntRzIncApr.NumeroInt), .Observ )


				Local lcSerie_PK, lcSerieDetalle, lcArticulo_PK, lcArticuloDetalle, lcSerieTI_PK, lcRazonSocial, ldFechaBajaVigencia

				lcSerie_PK = Alltrim(loEntItemsVig.subitems.Item[1].Serie_Pk)
				lcSerieDetalle = lower(Alltrim(loEntItemsVig.subitems.Item[1].SerieDetalle))
				lcArticulo_PK = Alltrim(loEntItemsVig.subitems.Item[1].Articulo_pk)
				lcArticuloDetalle = Alltrim(loEntItemsVig.subitems.Item[1].ArticuloDetalle)
				lcSerieTI_PK = Alltrim(loEntItemsVig.subitems.Item[1].SerieTI_Pk)
				lcRazonSocial = Alltrim(loEntItemsVig.subitems.Item[1].RazonSocial)
				ldFechaBajaVigencia = loEntItemsVig.subitems.Item[1].FechaBajaVigencia

				This.assertequals( "Debería tener el Serie_PK [1]", "508000", alltrim( lcSerie_PK ) )
				This.assertequals( "Debería tener el SerieDetalle[1]","serie test",lcSerieDetalle)
				This.assertequals( "Debería tener el Articulo_PK [1]","00-AA", alltrim( lcArticulo_PK) )
				This.assertequals( "Debería tener el ArticuloDetalle [1]","art 00-AA",lcArticuloDetalle)
				This.assertequals( "Debería tener el SerieTI_PK [1]","",alltrim( lcSerieTI_PK) )
				This.assertequals( "Debería tener el RazonSocial [1]","",lcRazonSocial)
				This.assertequals( "Debería tener el FechaBajaVigencia [1]",goServicios.librerias.ObtenerFecha(),ldFechaBajaVigencia)

				lcSerie_PK = Alltrim(loEntItemsVig.subitems.Item[2].Serie_Pk)
				lcSerieDetalle = lower(Alltrim(loEntItemsVig.subitems.Item[2].SerieDetalle))
				lcArticulo_PK = Alltrim(loEntItemsVig.subitems.Item[2].Articulo_pk)
				lcArticuloDetalle = Alltrim(loEntItemsVig.subitems.Item[2].ArticuloDetalle)
				lcSerieTI_PK = Alltrim(loEntItemsVig.subitems.Item[2].SerieTI_Pk)
				lcRazonSocial = Alltrim(loEntItemsVig.subitems.Item[2].RazonSocial)
				ldFechaBajaVigencia = loEntItemsVig.subitems.Item[2].FechaBajaVigencia

				This.assertequals( "Debería tener el Serie_PK [2]", "508000", alltrim( lcSerie_PK ) )
				This.assertequals( "Debería tener el SerieDetalle[2]","serie test",lcSerieDetalle)
				This.assertequals( "Debería tener el Articulo_PK [2]","00-TI", alltrim( lcArticulo_PK) )
				This.assertequals( "Debería tener el ArticuloDetalle [2]","art 00-TI",lcArticuloDetalle)
				This.assertequals( "Debería tener el SerieTI_PK [2]","508001",alltrim( lcSerieTI_PK) )
				This.assertequals( "Debería tener el RazonSocial [2]","",lcRazonSocial)
				This.assertequals( "Debería tener el FechaBajaVigencia [2]",goServicios.librerias.ObtenerFecha(),ldFechaBajaVigencia)

				lcSerie_PK = Alltrim(loEntItemsVig.subitems.Item[3].Serie_Pk)
				lcSerieDetalle = lower(Alltrim(loEntItemsVig.subitems.Item[3].SerieDetalle))
				lcArticulo_PK = Alltrim(loEntItemsVig.subitems.Item[3].Articulo_pk)
				lcArticuloDetalle = Alltrim(loEntItemsVig.subitems.Item[3].ArticuloDetalle)
				lcSerieTI_PK = Alltrim(loEntItemsVig.subitems.Item[3].SerieTI_Pk)
				lcRazonSocial = Alltrim(loEntItemsVig.subitems.Item[3].RazonSocial)
				ldFechaBajaVigencia = loEntItemsVig.subitems.Item[3].FechaBajaVigencia

				This.assertequals( "Debería tener el Serie_PK [3]", "508000", alltrim( lcSerie_PK ) )
				This.assertequals( "Debería tener el SerieDetalle[3]","serie test",lcSerieDetalle)
				This.assertequals( "Debería tener el Articulo_PK [3]","00-HS", alltrim( lcArticulo_PK) )
				This.assertequals( "Debería tener el ArticuloDetalle [3]","art 00-HS",lcArticuloDetalle)
				This.assertequals( "Debería tener el SerieTI_PK [3]","", alltrim( lcSerieTI_PK) )
				This.assertequals( "Debería tener el RazonSocial [3]","",lcRazonSocial)
				This.assertequals( "Debería tener el FechaBajaVigencia [3]",goServicios.librerias.ObtenerFecha(),ldFechaBajaVigencia)
			Endwith

			loSerie.Release()
			loArticulo.Release()
			loCliente.Release()
			loClasificacionCte.Release()
			loRZ.Release()
			loZlServiciosLote.Release()
			loEntRzInc.Release()
			loAut.Release()
			loEntRzIncApr.Release()
			loEntItemsVig.Release()
			loPais.Release()
			loProvincia.Release()
		Catch To loError
			Throw loError
		Finally
goMensajes = _Screen.zoo.app.oMensajes
		Endtry

	Endfunc

Enddefine

****************************************************************************************

*-----------------------------------------------------------------------------------------
Function CrearSP_SP_IyD_ActualizarBajaEnIS
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SP_IyD_ActualizarBajaEnIS]') AND type in (N'P', N'IF', N'TF', N'FS', N'FT'))
		DROP PROCEDURE [ZL].[SP_IyD_ActualizarBajaEnIS]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE PROCEDURE [ZL].[SP_IyD_ActualizarBajaEnIS]
			@RZ as varchar(5)
		AS
		BEGIN

			update i
			set i.Relaloteb = l.Subitem
			from ZL.Itemserv i
				inner join
					(
						select d.Nroitemser, Subitem
						from ZL.Detitemservibaja d
							inner join
								(
									select l.Crz, max(l.Codin) as Codin
									from ZL.Loteservibaja l
									where l.Crz = @RZ
									group by l.Crz
								) l on l.Codin = d.Subitem
					) l on l.Nroitemser = i.Ccod
			where i.Ccod = l.Nroitemser

		END
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerArticulosNoVisiblesDeCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeCliente]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeCliente]
		(@Cliente varchar(5), @Art varchar(13))
		RETURNS TABLE
		AS
		RETURN
		(
			select cli.Cmpcodigo as Cliente, art.Ccod as Articulo, dana.Cmpclasif as Clasificacion
			from ZL.Isarticu art
				inner join ZL.DCLAARTNO dana on dana.Codcla = art.Ccod
				inner join ZL.DETCLASCLIE dc on dc.Fkclasifi = dana.Cmpclasif
				inner join ZL.Clientes cli on cli.Cmpcodigo = dc.Fkcliente
			where cli.Cmpcodigo = @Cliente and art.Ccod = @Art
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncionItemsVigentes
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcItemsVigentes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcItemsVigentes]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcItemsVigentes]
		(
		)
		RETURNS TABLE
		AS
		RETURN
		(
			SELECT i.ccod
			from zl.itemserv as i WITH (NOLOCK)
			where (fealvig between '19000102' and DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) )
				and (febavig >= DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) or febavig='19000101')
			union all
			SELECT i.ccod
			from zl.itemserv as i WITH (NOLOCK) join zl.relaciontiis as ti  WITH (NOLOCK) on ti.ccod =  i.ccod
			where fealvig = '19000101' and febavig='19000101' and ti.fechaact > '19000101' and i.cmpfecdes = '19000101'
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
function CrearDirecciones
	local loent as Object, loerror as Object, lcCodRetorno as String, loent1 as Object , loent2 as Object, loent3 as Object

	lcCodRetorno = ''
	
	loent = _Screen.zoo.instanciarentidad( 'PROVINCIA' )

	with loent
		try 
			.codigo = '01'
			.Eliminar()
		catch to loError	
		endtry 
			
		try 
			.NUEVO()
			.codigo = '01'
			.Descripcion = 'BA'
			.grabar()
		catch to loError	
		finally 
			.Release()
		endtry 	
	endwith 
	
	loent = null
	loent1 = _Screen.zoo.instanciarentidad( 'TIPODIRECCIONES' )	

	with loent1
	
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = '01'
			.Descrip = 'Tipo 1'
			.grabar()
		catch to loError
		finally 
			.Release()
		endtry 			
	endwith 	
	loent1 = null
	loent2 = _Screen.zoo.instanciarentidad( 'NACIONALIDAD' )

	with loent2
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = 'AR'
			.Descrip = 'Aryentain'
			.grabar()
		catch to loError
		finally 
			.Release()
		endtry 				
	endwith 	

	loent2 = null
	loent3 = _Screen.zoo.instanciarentidad( 'DIRECCIONESALTAS' )
	
	with loent3	
		try 
			.nuevo()
			.Calle = 'LA CALLE'
			.Provincia_PK ='01'
			.TIPO_PK = '01'
			.Pais_pk = 'AR'
			.Grabar()
		catch to loError
		finally
			.Ultimo()
			lcCodRetorno = .Codigo
			.Release()
		endtry 	
			
	endwith 

	loent3 = null

	return lcCodRetorno
	
endfunc 


*-----------------------------------------------------------------------------------------
Function CrearItemzlvinculacionitemsdetalleitems_Test(  toFxuTestCase As Object ) As Void
	Local lcContenido As String

	toFxuTestCase.cArchivoMock = ObtenerNombreDeArchivoItemzlvinculacionitemsdetalleitems_Test()

	TEXT to lcContenido textmerge noshow
	*--------------------------------------------------------------------------------------------------
	define class <<justfname( forceext( toFxuTestCase.cArchivoMock, '' ) )>> as itemZLVINCULACIONITEMSDetalleItems of itemZLVINCULACIONITEMSDetalleItems.prg

		function CargarFecFact
			this.FechaFacturacion = date()
			return .t.
		endfunc

	enddefine
	ENDTEXT

	Strtofile( lcContenido, toFxuTestCase.cArchivoMock, 0)

Endfunc

*-----------------------------------------------------------------------------------------
Function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase As Object ) As Void

	Local lcContenido As String

	toFxuTestCase.cArchivoMock1 = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	TEXT to lcContenido textmerge noshow
	*--------------------------------------------------------------------------------------------------
	define class <<justfname( forceext( toFxuTestCase.cArchivoMock1, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg


		function init() as Void
			dodefault()
			this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_aux' )
		endfunc 
		
		function ValidaArticuloCentralizador
			return .t.
		endfunc

	enddefine
	ENDTEXT

	Strtofile( lcContenido, toFxuTestCase.cArchivoMock1, 0)

Endfunc

*--------------------------------------------------------------------------------
Define Class RzTest As ent_ZLRAZONSOCIALES Of ent_ZLRAZONSOCIALES.prg
	cCodigoSugerido = ''
	Function SetearCodigoSugerido() As String
		This.codigo = This.cCodigoSugerido
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarPermisoAsignacionTipoRazonSocial()
		return .t.
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Validar_Regimencomision( txVal as variant ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarEsquemaActivo( txVal ) as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosAFIP() as Void
		this.Direccion = "Direccion de prueba"
		this.Localidad = ""
		this.Provincia_pk = "00"
		this.CodigoPostal = ""
	endfunc 
	
Enddefine

*--------------------------------------------------------------------------------
Define Class serieTest As ent_zlseries Of ent_zlseries.prg
	cNumeroSugeridoTest = ''
	Function ObtenerNumeroString() As String
		Return This.cNumeroSugeridoTest
	Endfunc
Enddefine

*-----------------------------------------------------------------------------------------
Function ObtenerNombreDeArchivoItemzlvinculacionitemsdetalleitems_Test As String
	Local lcArchivo As String
	lcArchivo = Addbs( _Screen.zoo.ObtenerRutaTemporal() ) + 'Mock_Itemzlvinculacionitemsdetalleitems_Test' + Sys( 2015 ) + '.prg'
	Return lcArchivo
Endfunc

*-----------------------------------------------------------------------------------------
Function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test() As String
	Local lcArchivo As String
	lcArchivo = Addbs( _Screen.zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + Sys( 2015 ) + '.prg'
	Return lcArchivo
Endfunc

*-----------------------------------------------------------------------------------------
Function BorrarItemzlvinculacionitemsdetalleitems_Test( toFxuTestCase As Object )
	Local lcArchivo As String
	lcArchivo = toFxuTestCase.cArchivoMock
	Delete File ( lcArchivo )
Endfunc

*-----------------------------------------------------------------------------------------
Function Borrarzlvinculacionitemsdetalleitems_Test( toFxuTestCase As Object )
	Local lcArchivo As String
	lcArchivo = toFxuTestCase.cArchivoMock1
	Delete File ( lcArchivo )
Endfunc


*--------------------------------------------------------------------------------------------------
Function CrearZlServiciosLoteBaja_Test( toFxuTestCase As Object )
	Local lcContenido As String, lcSQL as String 

	toFxuTestCase.cArchivoMockZlServiciosLoteBaja = ObtenerNombreDeArchivoZlServiciosLoteBaja_Test()

	TEXT to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlServiciosLoteBaja, '' ) )>> as Ent_ZlServiciosLoteBaja of Ent_ZlServiciosLoteBaja.prg
			function TieneModuloeHost( tcArticulo as String ) as Boolean
				return .t.
			endfunc
			protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD( ) as void
				nodefault 
			endfunc					
		enddefine
	ENDTEXT

	Strtofile( lcContenido, toFxuTestCase.cArchivoMockZlServiciosLoteBaja, 0)
	
	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerEsquemaDeComision]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerEsquemaDeComision]
	endtext
	
	goServicios.Datos.EjecutarSentencias( lcSQL , '' )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[funcObtenerEsquemaDeComision]
		(	
			@RazonSocial varchar(5)
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			Select 
					a.NUMERO AS NUMERO
					,a.CREGIMEN AS REGIMENCOMISION 
				from ZL.ASESCOMAC a
				inner join ZL.esqcom e  on a.cregimen = e.ccod
				inner join  ZL.Legops l on l.ccod = e.dueno
			 Where  a.NUMERO != 0 
				and a.nrz = @RazonSocial 
				and l.activo = 1  
		)
		endtext
		
		goServicios.Datos.EjecutarSentencias( lcSQL , '' )
	
	
	
Endfunc

*--------------------------------------------------------------------------------------------------
Function BorrarZlServiciosLoteBaja_Test( toFxuTestCase As Object )
	Local lcArchivo As String
	lcArchivo = toFxuTestCase.cArchivoMockZlServiciosLoteBaja
	Delete File ( lcArchivo )
Endfunc


*--------------------------------------------------------------------------------------------------
Function ObtenerNombreDeArchivoZlServiciosLoteBaja_Test As String
	Local lcArchivo As String
	lcArchivo = Addbs( _Screen.zoo.ObtenerRutaTemporal() ) + 'Mock_ZlServiciosLoteBaja_Test' + Sys( 2015 ) + '.prg'
	Return lcArchivo
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
		(	
			
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			select 
					E.Ccod as Esquema ,
					CLIENTE  as Cliente ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
					e.dueno as Duenio
				from ZL.esqcom E
				left join (select Cliente, CREGIMEN from zl.ASESCOMCLI 
								where NUMERO in ( select max(numero)
									from zl.ASESCOMCLI
									group by   CLIENTE
												)      
							) as ASESCOMCLI on e.ccod = ASESCOMCLI.CREGIMEN 
				join ZL.Legops l on l.ccod = e.dueno 
				
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

*-----------------------------------------------------------------------------------------
define class objEntidad as Entidad of Entidad.prg 
	*-----------------------------------------------------------------------------------------
	Function SoportaBusquedaExtendida() As Void
		Return .F.
	Endfunc

Enddefine

*----------------------------------------------------------------
define class ValidacionesEstadoRazonSocial_Aux as custom 

	*-----------------------------------------------------------------------------------------
	function Validar( txVal ) as Boolean
		return .t.
	endfunc 
enddefine 

*-----------------------------------
define class ValidacionDeArticulos_aux  as custom

	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPorSerie( trazonsocial, tserie, tarticulo) as Boolean
		return .t.
	endfunc	
	
enddefine

*----------------------------------------------------------------
define class ZLSERVICIOSLOTE_AUX as ent_ZLSERVICIOSLOTE of ent_ZLSERVICIOSLOTE.PRG

	*-----------------------------------------------------------------------------------------
	function CrearCuentaComunicaciones() as Void
		nodefault
	endfunc
	*-----------------------------------------------------------------------------------------
	function GeneraGrupoComunicaciones() as Void
		nodefault
	endfunc
	protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
		nodefault
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSql( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[func_NormalizarNombre]
				(@Texto varchar(max))
			RETURNS VARCHAR(MAX) AS
			BEGIN

				declare @Text varchar(max) = ltrim(rtrim((case when @Texto is null then '' else lower(replace(@Texto, '.', '')) end)))
				while charindex('  ', @Text) > 0
					begin
						set @Text = replace(@Text, '  ', ' ')
					end
				declare @LastTextIndex int = (select charindex(' ', reverse(@Text))), @LastText varchar(max) = ''
				declare @New varchar(max) = ''
				declare @Index int = 1, @Len int = len(@Text)

				while (@Index <= @Len)
					begin
						if (substring(@Text, @Index, 1) like '[^a-z]' and @Index + 1 <= @Len)
							begin
								select @New = @New + upper(substring(@Text, @Index, 2)), @Index = @Index + 2
							end
						else
							begin
								select @New = @New + substring(@Text, @Index, 1), @Index = @Index + 1
							end
					end

				set @New = (upper(left(@New, 1)) + right(@New, abs(@Len - 1)))
				set @LastText = right(lower(@New), abs(@Len - (@Len - @LastTextIndex + 1)))
				set @New =
					case
						when @LastText = 'sa' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.'
						when @LastText = 'srl' then left(@New, @Len - @LastTextIndex + 1) + 'S.R.L.'
						when @LastText = 'sas' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.S.'
						else @New
					end

				return ltrim(rtrim(@New))

			END
		endtext
		
		goServicios.Datos.EjecutarSql( lcSQL )

endfunc


*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]
		(	
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
		select 
				E.Ccod as Esquema ,
				E.Descr as Descripcion,
				Nrz    as RazonSocial ,
				case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
				case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
				e.dueno as Duenio,
				l.Ccortesia as DescripcionDuenio
				--,	ASESCOMAC.Asignacion as Asignacion
			from ZL.esqcom E
			left join (select Nrz, CREGIMEN, Numero as Asignacion  from zl.ASESCOMAC 
							where NUMERO in ( select max(numero)
								from zl.ASESCOMAC
								group by   Nrz
											)      
						) as ASESCOMAC on e.ccod = ASESCOMAC.CREGIMEN 
			join ZL.Legops l on l.ccod = e.dueno 
			)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
	
endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcArticuloConModuloActivacionOnLine
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcArticuloConModuloActivacionOnLine]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcArticuloConModuloActivacionOnLine]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcArticuloConModuloActivacionOnLine]
		(	
			@Articulo varchar(13)
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			select '' as Ccod where 1 = 0
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc
