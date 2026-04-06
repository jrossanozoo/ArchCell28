define class ColaboradorComprobantesAPIDragon as zoosession of zoosession.prg
	
	oEntidad =  null 
	oDataRest = null
	oScript = null
	cScriptColor  = "COLOR" + strtran( sys(2015),"_","")
	cScriptArticulo = "ARTIC" + strtran( sys(2015),"_","")
	
	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidad = toEntidad
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oDataRest_Access() as Variant
		if !this.ldestroy and ( vartype( this.oDataRest	) != 'O' or isnull( this.oDataRest ) ) and ! empty( alltrim( this.oEntidad.BaseDeDatos ))
			this.oDataRest = this.ObtenerClaseDataRest()
			this.oDataRest.servicioRestClienteRest = alltrim( .BaseDeDatos )
		endif
		return this.oDataRest
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oScript_Access() as Variant
		if !this.ldestroy and ( vartype( this.oScript	) != 'O' or isnull( this.oScript ) )
			this.oScript = _Screen.zoo.InstanciarEntidad ( "Script" )
		endif
		return this.oScript
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClaseDataRest() as Object
		_Screen.Zoo.AgregarReferencia( "ZooLogicSA.ZLaDragon.dll" )
		return _Screen.Zoo.CrearObjeto( "ZooLogicSA.ZLaDragon.DataRest" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstablecerTotalDeProcesos() as number
		local lRet as  number
		lRet = 0
		
		with this.oEntidad
			if ! empty( alltrim( .RutaDragon )) 
				if ! empty( alltrim(.ArchivoImpoArticulos) )
					lRet = lRet + 1
				endif 
			
				if ! empty( alltrim(.ArchivoImpoColores ) )
					lRet = lRet + 1
				endif 
			endif 
		
			if ! empty( .Archivo )
				lRet = lRet + 1
			endif

		endwith 
					
		return lRet
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributoBaseDeDatosDestino() as Boolean
		local lRet as Boolean 
		lRet = .t.
		with this.oEntidad
			if empty( alltrim( .BaseDeDatos ) )
				.AgregarInformacion ( "La Base de Datos es un atributo requerido para el proceso." )
				lRet = .f.
			endif
		endwith 	
		return lRet
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAtributosNecesariosPorProceso() as Boolean
		local lRet as Boolean 
		lRet = this.ValidarAtributoBaseDeDatosDestino()
		with this.oEntidad
			if lRet and !empty( alltrim( .RutaDragon ) )
				.RutaDragon = addbs(alltrim(.RutaDragon ))
				if ! file( .RutaDragon + "Dragonfish_Core.exe" )
					.AgregarInformacion ( "No se encuentra el Dragonfish_Core.exe en la ruta especificada." )
					lRet = .f.
				endif	
			endif
			if lRet and ( ! empty( alltrim( .ArchivoImpoArticulos ) ) or ! empty( alltrim( .ArchivoImpoColores ) ) ) and empty( alltrim( .RutaDragon ) )
				.AgregarInformacion ( "La Ruta de Dragonfish es un atributo requerido para el proceso." )
				lRet = .f.
			endif 
		endwith 	
		return lRet
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarComprobantes() as Boolean 
		local lRet as Boolean, lcResult as String, lnTotalDePRocesos as Number, lnProceso as Number    
		  
		lRet = this.ValidarAtributosNecesariosPorProceso()
		
		if lRet
			lnTotalDePRocesos = this.EstablecerTotalDeProcesos()
			lnProceso = 0
			with this.oEntidad
				if lnTotalDePRocesos > 0
					application.AutoYield = .t.
					*- Importacion de Articulos y Colores
					if ! empty( alltrim( .RutaDragon ))
						
						if ! empty( alltrim(.ArchivoImpoArticulos) )
							lnProceso = lnProceso + 1
							goServicios.Mensajes.EnviarSinEsperaProcesando( "Procesando Importacion de Artículos... Paso " + transform(lnProceso )+ " de " + transform(lnTotalDePRocesos ))
							this.GenerarScriptArticulos() 
							lcResult = this.oDataRest.ImportarArticulos(.RutaDragon)
							if (lcResult != "OK" )
								lRet = .f.
								.AgregarInformacion( "Hubo problemas en la importación de artículos en Dragon: " + alltrim( lcResult)) 
							endif 	
							this.EliminarScriptArticulos()
							goServicios.Mensajes.EnviarSinEsperaProcesando()
						endif 
						
						if lRet and ! empty( alltrim(.ArchivoImpoColores ) )
							lnProceso = lnProceso + 1
							goServicios.Mensajes.EnviarSinEsperaProcesando( "Procesando Importacion de Colores... Paso " + transform(lnProceso )+ " de " + transform(lnTotalDePRocesos ))
							this.GenerarScriptColores()
							lcResult = this.oDataRest.ImportarColores(.RutaDragon)
							if (lcResult != "OK" )
								lRet = .f.
								.AgregarInformacion( "Hubo problemas en la importación de colores en Dragon: " + alltrim( lcResult)) 
							endif 	
							this.EliminarScriptColores()
							goServicios.Mensajes.EnviarSinEsperaProcesando()
						endif
					endif 

					*- Generacion de Facturas
					if lRet and ! empty( .Archivo )
						lnProceso = lnProceso + 1
						goServicios.Mensajes.EnviarSinEsperaProcesando( "Procesando Facturación... Paso " + transform(lnProceso )+ " de " + transform(lnTotalDePRocesos ))
						lRet = this.GenerarFacturasEnDragon()
						goServicios.Mensajes.EnviarSinEsperaProcesando()
					endif
				
					goServicios.Mensajes.EnviarSinEsperaProcesando()
					application.AutoYield = .F.

				endif 

			endwith 
		endif
		return lRet
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFacturasEnDragon() as Boolean
		local loResult as Object, lnI as Number, loError as Exception, lRet as Boolean,;
			lcCursor as String, lcArchivoErrores as String, lcAcciones as String 			

		lcArchivoErrores = ""
		lcAcciones = ""
		lcCursor = 'C'+ sys(2015)
		
		with this.oEntidad
			loResult = this.oDataRest.ProcesarFacturacion( alltrim(.Archivo), dtos(.FechaFacturacion) )
		
			Try
				Local array aResultadosAux[loResult.count]
				Local array aResultados[loResult.count]
				For lnI = 1 To loResult.Count
					aResultadosAux[ lnI ] = loResult.Item( lnI-1 )
					
				endfor
				Asort( aResultadosAux )
		
				create cursor &lcCursor. ( Cprb C(9), Le C(1), PVt C(4), Nu C(8) )  
				for lnI = 1 to alen( aResultadosAux )
					if "ERROR" $ upper(aResultadosAux[ lnI ] )
						lcArchivoErrores = substr( aResultadosAux[ lnI ] , 10, 240 )
					else
						insert into &lcCursor. ;
							( Cprb , Le , PVt , Nu )  ;
							values (;
							substr( aResultadosAux[ lnI ] , 1, 8 ) ,;
							substr( aResultadosAux[ lnI ] , 10, 1 ) ,;
							substr( aResultadosAux[ lnI ] , 12, 4 ) ,;
							substr( aResultadosAux[ lnI ] , 18, 8 ) )
					endif
				endfor

				select Cprb, Le , Pvt, min( Nu ) as NuDesde , max( Nu ) as NuHasta from &lcCursor. into cursor &lcCursor. ;
					where ! ( "ERROR" $ upper( Cprb )) ;
					group by  Cprb, Le, Pvt 
				
				if used( lcCursor ) and reccount( lcCursor ) > 0 
					lcAcciones = "Comprobantes generados: " + chr(13) 
					scan
						lcAcciones = lcAcciones + Cprb + Le + " " + Pvt + "-"  + NuDesde + iif( NuHasta = NuDesde, "", "/ "+NuHasta)+ chr(13)
					endscan
				endif
				if lcArchivoErrores != ""
					lcAcciones = lcAcciones + "Se creó un archivo con errores: " + lcArchivoErrores 
				endif	
				.Zadsfw = lcAcciones 
			Catch To loError
							
			Finally
				lRet = (loResult.Count>0)
				use in select( lcCursor )
			Endtry
		
		endwith 
		
		return lRet
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarScriptArticulos() as Void
		local loItem as object
		with this.oScript
			try
				.Codigo = this.cScriptArticulo
				.eliminar()
			catch
			finally
				.Nuevo()
				.Codigo = this.cScriptArticulo
				.Descripcion = "Script temporal " + this.cScriptArticulo
				.Usuario = goServicios.Seguridad.cUltimoUsuarioLogueado
				.BaseDeDatos = this.oEntidad.BaseDeDatos 
				.RutaDestino = addbs(this.oEntidad.RutaDragon) + "TMP"
				.NombreArchivo = "Importararticulosparafacturar.txt"
				
				with .Instrucciones
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 1
					loItem.Instruccion = 'loObjeto = goServicios.Importaciones.Procesar( "' + alltrim(this.oEntidad.ArchivoImpoArticulos) + '" )'
					.add( loItem )
					
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 2
					loItem.Instruccion = 'loObjeto.cArchivoEntrada = "' + addbs(this.oEntidad.RutaDragon) + 'TMP\ARTICULOS.TXT"'             
					.add( loItem )
					
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 3
					loItem.Instruccion = 'goServicios.Importaciones.Enviar( loObjeto )'
					.add( loItem )
					
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 4
					loItem.Instruccion = 'goServicios.Mensajes.EnviarSinEspera()'
					.add( loItem )

					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 5
					loItem.Instruccion = '_Screen.Zoo.App.Salir()'
					.add( loItem )

				endwith 
				.Grabar()
				.GenerarArchivo()	
			endtry
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarScriptColores() as Void
		local loItem as object
		with this.oScript
			try
				.Codigo = this.cScriptColor
				.eliminar()
			catch
			finally
				.Nuevo()
				.Codigo = this.cScriptColor
				.Descripcion = "Script temporal " + this.cScriptColor
				.Usuario = goServicios.Seguridad.cUltimoUsuarioLogueado
				.BaseDeDatos = this.oEntidad.BaseDeDatos 
				.RutaDestino = addbs(this.oEntidad.RutaDragon) + "TMP"
				.NombreArchivo = "Importarcoloresparafacturar.txt"
				
				with .Instrucciones
				
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 1
					loItem.Instruccion = 'loObjeto = goServicios.Importaciones.Procesar( "' + alltrim(this.oEntidad.ArchivoImpoColores) + '" )'
					.add( loItem )
					
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 2
					loItem.Instruccion = 'loObjeto.cArchivoEntrada = "' + addbs(this.oEntidad.RutaDragon) + 'TMP\COLORES.TXT"'    
					.add( loItem )
					
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 3
					loItem.Instruccion = 'goServicios.Importaciones.Enviar( loObjeto )'
					.add( loItem )
					
					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 4
					loItem.Instruccion = 'goServicios.Mensajes.EnviarSinEspera()'
					.add( loItem )

					loItem = .CrearItemAuxiliar()
					loItem.NroItem = 5
					loItem.Instruccion = '_Screen.Zoo.App.Salir()'
					.add( loItem )

				endwith 	
				.Grabar()
				.GenerarArchivo()
			endtry 	
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EliminarScriptArticulos() as Void
		local loItem as object
		with this.oScript
			try
				.Codigo = this.cScriptArticulo
				.eliminar()
			catch
			endtry
		endwith 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarScriptColores() as Void
		with this.oScript
			try
				.Codigo = this.cScriptColor
				.eliminar()
			catch
			endtry 	
		endwith 			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarRecibos() as Boolean
		local lcSQL as String, lcCursor as String, lcJsonComprobante as String, lEstadoServicioRest as Boolean,;
			  lcEntidad as String, result as object, lcCurUpdt as String, lNum as String, lRecibo as String,;
			  lFecha  as string, lRet as Boolean  
		 
		lRet = this.ValidarAtributoBaseDeDatosDestino()
		
		if lRet
			lcCursor = 'C' + sys( 2015 )
			lcCurUpdt = 'C'+sys(2015)

			text to lcSQL textmerge noshow
				select
					  NumeroDeRegistroBancario
					, JsonComprobante
				from [ZL].[funcObtenerRegistrosDeProcesosBancariosSinProcesar]()
				order by 1
			endtext		
			
			goServicios.Datos.ejecutarsql( lcSQL, lcCursor, Set("datasession") )				

			if used( lcCursor ) and reccount( lcCursor ) > 0
				
				application.AutoYield = .t.
				
				lcEntidad = 'Recibo'
	 			lcCurUpdt = 'C'+sys(2015)

				scan
					lNum = transform(&lcCursor..NumeroDeRegistroBancario)
					lFecha = dtos(goServicios.Librerias.ObtenerFecha())				
					goServicios.Mensajes.EnviarSinEsperaProcesando( "Registro bancario Nº " + lNum + " . Procesando " +;
																	 transform(recno()) + "/" + transform( reccount()) ;
																   )
					lcJsonComprobante = &lcCursor..JsonComprobante
					
					result = this.oDataRest.ProcesarEntidad( lcJsonComprobante, lcEntidad )
					if alltrim( result ) != "" && Actualizamos la entidad ZLREGDEVBANCO
						lRecibo = transform(result)
						text to lcSQL textmerge noshow
							update ZL.Devbco set 
								  NroRecibo = '<<alltrim(lRecibo)>>' 
								, ZLaDRGN   = '<<lFecha>>'
								where Numero = << lNum >>
						endtext
						goServicios.Datos.ejecutarsql( lcSQL, lcCurUpdt , Set("datasession") )
					endif 	
					
					goServicios.Mensajes.EnviarSinEsperaProcesando()
					
				endscan
				
				application.AutoYield = .F.
			else
				goServicios.Mensajes.Enviar( "No se encontraron registros para procesar.")  
				lRet = .f.	
			endif		
			use in select( lcCursor )	
			use in select( lcCurUpdt )	
		endif 
		return lRet
	endfunc 

enddefine
