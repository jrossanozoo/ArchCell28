**********************************************************************
Define Class ztestentidadZLITEMSSERVICIOS As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestentidadZLITEMSSERVICIOS Of ztestentidadZLITEMSSERVICIOS.prg
	#Endif

	cArchivoMockZlServiciosLoteBaja = ""	

	*---------------------------------
	Function Setup
		local loEntidad as entidad OF entidad.prg
		
		loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
		with loentidad
			try
				.Codigo = "ITEMSERCOD"
			catch to loError
				.nuevo()
				.Codigo = "ITEMSERCOD"
				.Numero = 1
				.Grabar()
			catch to loError
			finally
				.release()
			endtry
		endwith
	Endfunc

	*---------------------------------
     Function zTestItemSeriviciosTI
        local loEntidad as Object, loError as Exception , lcMensaje as String 

		loError = null
		=CrearZlServiciosLoteBaja_Test( this )

		try
			_screen.Mocks.AgregarMock( 'ZlServiciosLoteBaja', forceext( this.cArchivoMockZlServiciosLoteBaja, '' ) )

			this.agregarmocks( "Zlrazonsociales,ZLSERIES,Zlisarticulos,contratov2, ActualizarzOO" ) 

			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Levantarexcepciontexto', .T., "[El dato buscado 98765 de la entidad ZLRAZONSOCIALES no existe.],9001" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Codigo_despuesdeasignar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Levantarexcepciontexto', .T., "[El dato buscado 123456 de la entidad ZLISARTICULOS no existe.],9001" )
			_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Tienemoduloti', .T. ) 

			loEntidad = _Screen.zoo.instanciarentidad( "ZLITEMSSERVICIOS" )
			loEntidad.nuevo()
			loEntidad.RazonSocial_pk = '98765'
			loEntidad.NumeroSerie_pk = '507544'
			loEntidad.articulo_pk = '123456'
			loEntidad.FechaAlta = date()
	
			try	
				loEntidad.grabar()
          		this.asserttrue( "No debería haber grabado", .f. ) 
            catch to loError
            	lcMensaje = loError.uservalue.oinformacion.item[1].cMensaje 
				this.assertequals( 'Deberia haber dado error de TI','El Artículo tiene un módulo TI' , lcMensaje )
            endtry   
			
			loEntidad.cancelar()

			_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Tienemoduloti', .F. ) 

			loEntidad.nuevo()
			loEntidad.RazonSocial_pk = '98765'
			loEntidad.NumeroSerie_pk = '507544'
			loEntidad.articulo_pk = '123456'
			loEntidad.FechaAlta = date()
            
 			try	
				loEntidad.grabar()
            catch to loError
				this.asserttrue( "Debería haber grabado", .F. ) 
            finally
                loEntidad.release()	
            endtry   
		catch to loError
			throw loError
		finally
			=BorrarZlServiciosLoteBaja_Test( this )
		endtry
            

      endfunc
     
      *-----------------------------------------------------------------------------------------
      function zTestBotonNuevo
            local oLote as Object 
      
            oLote = GOFORMULARIOS.procesar('ZLITEMSSERVICIOS')    
                 
            this.asserttrue( "No deberia existir el Botón Nuevo", !pemstatus( oLote.oTOOLBAR,  "Barra_Nuevo", 5 ) )
            this.asserttrue( "No deberia existir el Botón Nuevo", !pemstatus( oLote.oMenu.mENU_ARCHIVO ,  "Menu_Nuevo", 5 ) )
            
            oLote.release()
                             
      endfunc 
enddefine


*--------------------------------------------------------------------------------------------------
function CrearZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMockZlServiciosLoteBaja = ObtenerNombreDeArchivoZlServiciosLoteBaja_Test()

	text to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlServiciosLoteBaja, '' ) )>> as Ent_ZlServiciosLoteBaja of Ent_ZlServiciosLoteBaja.prg
			function TieneModuloeHost( tcArticulo as String ) as Boolean
				return .t.
			endfunc

			function EjecutaSPDesactivaGrupoComunicacionesxSerie( tcSerie as String, tcFechaBaja as String ) as Void
			endfunc
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMockZlServiciosLoteBaja, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMockZlServiciosLoteBaja
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoZlServiciosLoteBaja_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ZlServiciosLoteBaja_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc


