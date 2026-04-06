**********************************************************************
Define Class zTestItemCambioDeRazonSocialSubitems as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestItemCambioDeRazonSocialSubitems of zTestItemCambioDeRazonSocialSubitems.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		CrearFuncion_funcObtenerArticulosNoVisiblesDeRazonSocial()
	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestU_CambioDeSerieTI_ArtActualConTI_ArtNuevoSinTI
		local loItem as Object, loCol as Collection
		
		this.agregarMocks( "zlitemsservicios,ZLSERIES,zlisarticulos,BUSQARTICLASIF,ZLSERIESTI,zlaltagrupocom,RELACIONTIIS" )
		
		loCol = newobject( "Collection" )
		loCol.Add( "Clasificacion1" )
		
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Obtenerclasificaciones', loCol )
		** Pasa una vez por el articulo actual
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .T. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .T. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		** Pasa una vez mas por el articulo nuevo
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .T. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .T. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )

		_screen.mocks.AgregarSeteoMetodo( 'relaciontiis', 'Obtenerserieti', "123456", "'*COMODIN'" )
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Esarticuloactivo', .T. )

		loItem = _screen.zoo.crearobjeto( "ItemCambioDeRazonSocialSubitems" )

		with loItem as ItemCambioDeRazonSocialSubitems of ItemCambioDeRazonSocialSubitems.prg
			.oClasificacionesDelNuevoCliente = newobject( "Collection" )
			.oClasificacionesDelNuevoCliente.add( "Clasificacion1" )
			.articuloAnterior_PK = "1"
			.articulo_PK = "2"
			
			** La llamada al método se produce al asignar el articulo_pk. Por eso no hay una llamada explicita.
			
			this.assertequals( "El Campo serie TI es invalido", "", alltrim( .SerieTI_PK ) )
			this.asserttrue( "La habilitacion del serie TI no es correcta", !.lHabilitarSerieTI_PK )
			.Release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_CambioDeSerieTI_ArtActualSinTI_ArtNuevoConTI
		local loItem as Object, loCol as Collection
		
		this.agregarMocks( "zlitemsservicios,ZLSERIES,zlisarticulos,BUSQARTICLASIF,ZLSERIESTI,zlaltagrupocom,RELACIONTIIS" )
		
		loCol = newobject( "Collection" )
		loCol.Add( "Clasificacion1" )
		
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Obtenerclasificaciones', loCol )
		** Pasa una vez por el articulo actual
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .T. )
		** Pasa una vez mas por el articulo nuevo
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodoEnCola( 'zlisarticulos', 'Tienemoduloti', .T. )

		_screen.mocks.AgregarSeteoMetodo( 'relaciontiis', 'Obtenerserieti', "123456", "'*COMODIN'" )
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Esarticuloactivo', .T. )


		loItem = _screen.zoo.crearobjeto( "ItemCambioDeRazonSocialSubitems" )

		with loItem as ItemCambioDeRazonSocialSubitems of ItemCambioDeRazonSocialSubitems.prg
			.oClasificacionesDelNuevoCliente = newobject( "Collection" )
			.oClasificacionesDelNuevoCliente.add( "Clasificacion1" )
			.articuloAnterior_PK = "1"
			.articulo_PK = "2"

			** La llamada al método se produce al asignar el articulo_pk. Por eso no hay una llamada explicita.
			
			this.assertequals( "El Campo serie TI es invalido", "", alltrim( .SerieTI_PK ) )
			this.asserttrue( "La habilitacion del serie TI no es correcta", .lHabilitarSerieTI_PK )
			.Release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_CambioDeSerieTI_ArtActualConTI_ArtNuevoConTI
		local loItem as Object, loCol as Collection
		
		this.agregarMocks( "zlitemsservicios,ZLSERIES,zlisarticulos,BUSQARTICLASIF,ZLSERIESTI,zlaltagrupocom,RELACIONTIIS" )
		
		loCol = newobject( "Collection" )
		loCol.Add( "Clasificacion1" )
		
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Obtenerclasificaciones', loCol )
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Tienemoduloti', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'relaciontiis', 'Obtenerserieti', "123456", "'*COMODIN'" )
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Esarticuloactivo', .T. )


		loItem = _screen.zoo.crearobjeto( "ItemCambioDeRazonSocialSubitems" )

		with loItem as ItemCambioDeRazonSocialSubitems of ItemCambioDeRazonSocialSubitems.prg
			.oClasificacionesDelNuevoCliente = newobject( "Collection" )
			.oClasificacionesDelNuevoCliente.add( "Clasificacion1" )
			.articuloAnterior_PK = "1"
			.articulo_PK = "2"

			** La llamada al método se produce al asignar el articulo_pk. Por eso no hay una llamada explicita.
			
			this.assertequals( "El Campo serie TI es invalido", "123456", alltrim( .SerieTI_PK ) )
			this.asserttrue( "La habilitacion del serie TI no es correcta", !.lHabilitarSerieTI_PK )
			.Release()
		endwith
	endfunc 


*!*		*-----------------------------------------------------------------------------------------
*!*		function zTestU_SerieTIHabilitado
*!*			local loItem as Object, loCol as Collection
*!*			
*!*			this.agregarMocks( "zlitemsservicios,ZLSERIES,zlisarticulos,BUSQARTICLASIF,ZLSERIESTI,zlaltagrupocom,RELACIONTIIS" )
*!*			
*!*			loCol = newobject( "Collection" )
*!*			loCol.Add( "Clasificacion1" )
*!*			
*!*			_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Obtenerclasificaciones', loCol )
*!*			_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Tienemoduloti', .T. )
*!*			_screen.mocks.AgregarSeteoMetodo( 'relaciontiis', 'Obtenerserieti', "123456", "'*COMODIN'" )
*!*			_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Esarticuloactivo', .T. )


*!*			loItem = _screen.zoo.crearobjeto( "ItemCambioDeRazonSocialSubitems" )

*!*			with loItem as ItemCambioDeRazonSocialSubitems of ItemCambioDeRazonSocialSubitems.prg
*!*				.oClasificacionesDelNuevoCliente = newobject( "Collection" )
*!*				.oClasificacionesDelNuevoCliente.add( "Clasificacion1" )
*!*				.articuloAnterior_PK = "1"
*!*				.articulo_PK = "2"

*!*				** La llamada al método se produce al asignar el articulo_pk. Por eso no hay una llamada explicita.
*!*				
*!*				this.assertequals( "El Campo serie TI es invalido", "123456", .SerieTI_PK )
*!*				this.asserttrue( "La habilitacion del serie TI no es correcta", !.lHabilitarSerieTI_PK )
*!*				.Release()
*!*			endwith
*!*		endfunc 
enddefine

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcObtenerArticulosNoVisiblesDeRazonSocial
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerArticulosNoVisiblesDeRazonSocial]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeRazonSocial]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeRazonSocial]
		(@RZ varchar(5), @Art varchar(13))
		RETURNS TABLE
		AS
		RETURN
		(
			select distinct cli.Cliente, art.Ccod as Articulo, dana.Cmpclasif as Clasificacion
			from ZL.Isarticu art
				inner join ZL.DCLAARTNO dana on dana.Codcla = art.Ccod
				inner join ZL.DETCLASCLIE dc on dc.Fkclasifi = dana.Cmpclasif
				inner join ZL.Razonsocial cli on cli.Cliente = dc.Fkcliente
			where cli.Cmpcod = @RZ and art.Ccod = @Art
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc
