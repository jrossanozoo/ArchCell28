Define class ComponenteServicios as Din_ComponenteServicios of Din_ComponenteServicios.prg
	oDetalleAnterior = Null
	oDetalle = null
	EsquemaDeComisionDelPresupuesto = 0
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void

		this.lDestroy = .t.
		if type( 'This.oEntidadPadre' ) = 'O' and !isnull( This.oEntidadPadre )
			this.oEntidadPadre.Release()
		endif

		dodefault()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg

		Local loColeccion as ZooColeccion of ZooColeccion.Prg, loItem as Object, ;
		loCol as zoocoleccion OF zoocoleccion.prg, lcCodigo as String ,loSentencias as Object ,lnNroCodigo as Integer 
		
		loColeccion = _screen.zoo.crearobjeto( "ZooColeccion" )

		if this.odetalle.lEsBaja

			for each loItem in this.oDetalle
				if !empty( loItem.NroItemServ_pk )

					loCol = this.obtenerBaja( loItem )
					
					for each loitemCol in loCol
						loColeccion.Agregar( loitemCol )
					endfor
				endif
			endfor
		else
			lcCodigo = this.obtenerId()

			lnNroCodigo  = this.oEntidad.ObtenerSiguienteNumerico()

			for each loItem in this.oDetalle

				if empty( loitem.Serie_pk )
				else
					with this.oentidad
						try
							.nuevo()
							.lCargando = .t.
							.Codigo = lnNroCodigo  
							.lCargando = .f.
							.NumeroSerie_pk = loitem.Serie_pk
							.RazonSocial_pk = this.oDetalle.cRazonSocial
							.Articulo_pk = loitem.Articulo_pk
							if this.ArticuloConModuloActivacionOnLine( loitem.Articulo_pk  )
								.FechaAlta = iif( this.SerieConItemsActivosLosUltimos7Dias( loitem.Serie_pk ), date(), ctod( "" ) )
							endif
							.fechaaltaRegistro = date()			
							.AltaRegPor_pk  = this.oDetalle.cRegpor 
							.FechaAltaVigencia = loitem.FechaAltaVigencia
							.RELALOTE = lcCodigo 
					
							this.oEntidad.RELALOTE = lcCodigo 
							loCol = dodefault()
							
							for each loItemCol in loCol
								loColeccion.Agregar( loItemCol )
							endfor				
							
							if !empty( loItem.SerieTI_PK )
								loSentencias = 	this.ObtenerSentenciasRelatiis( loItem )
								
								for each loItemTI in loSentencias
									loColeccion.Agregar( loItemTI )
								endfor
							endif
					
							if this.EsquemaDeComisionDelPresupuesto = 0
								lnNroComision = this.obtenerEsquemaDeComision( this.oDetalle.cRazonSocial )
							else
								lnNroComision = this.EsquemaDeComisionDelPresupuesto
							endif 
								
							if lnNroComision > 0
								loSentencias = 	this.ObtenerSentenciasEsquemaComision( loItem, lnNroComision  )
								for each loItemCom in loSentencias
									loColeccion.Agregar( loItemCom )
								endfor
							endif 
							lnNroCodigo  = lnNroCodigo + 1			
						catch to loError
							throw loError
						finally
							.Cancelar()
						endtry
					endwith
				ENDIF
			endfor
		endif
		
		return loColeccion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ArticuloConModuloActivacionOnLine( tcArticulo as String ) as Boolean
		local lcSQL as String, llRetorno as Boolean, lcCursor as String, lcSentencia as String, lnSelect as Integer

		lnSelect = select()
		llRetorno = .f.
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			select Ccod from [ZL].[funcArticuloConModuloActivacionOnLine]('<<alltrim(tcArticulo)>>')
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "datasession" ) )

		if used( lcCursor ) and reccount( lcCursor ) > 0
			llRetorno = .t.
		endif
		use in select( lcCursor )
		select( lnSelect )

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SerieConItemsActivosLosUltimos7Dias( tcSerie as String ) as Boolean
		local lcSQL as String, llRetorno as Boolean, lcCursor as String, lcSentencia as String, lnSelect as Integer

		lnSelect = select()
		llRetorno = .f.
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			select Ccod from [ZL].[funcSerieConItemsActivosLosUltimos7Dias]('<<alltrim(tcSerie)>>')
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "datasession" ) )

		if used( lcCursor ) and reccount( lcCursor ) > 0
			llRetorno = .t.
		endif
		use in select( lcCursor )
		select( lnSelect )

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerId() as String  
		local lcId as String , lcXml as String 
		lcId = ""

		lcXml = this.oEntidadPadre.oAD.ObtenerDatosEntidad( "NUMERO", , , "Max" )
		this.xmlACursor( lcXml, "c_Valores" )
		lcId = alltrim( str( nvl( c_Valores.max_NUMERO, 0 ) ))
		use in select( "c_Valores" )

		return lcId 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerIdBaja() as String  
		local lnId as String , lcXml as String 
		lcId = ""

		lcXml = this.ozlSERVICIOSLOTEBAJA.oAD.ObtenerDatosEntidad( "NUMERO", , , "Max" )
		this.xmlACursor( lcXml, "c_Valores" )
		lcId = alltrim( str( nvl( c_Valores.max_NUMERO, 0 ) ))
		use in select( "c_Valores" )

		return lcId 

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerSerieTI( tnCodItem as integer ) as String  
		local lcserieti as String , lcXml as String 
		lcserieti = ""

		lcXml = this.oEntidadPadre.oAD.ObtenerDatosEntidad( "NumeroSerie", "Ccod =" + transform( tnCodItem ) )
		
		this.xmlACursor( lcXml, "c_Valores" )
		lcserieti = alltrim( nvl( c_Valores.NumeroSerie, "" ) )
		use in select( "c_Valores" )

		return lcserieti 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasRelatiis( toItem as Object ) as Object    
		local loSentencia as Object, loError as zooexception OF zooexception.prg  

		with This.oRELACIONTIIS
			try
				.nuevo()
				.codigoitem = this.oentidad.Codigo
				.descrip = "Generación automática"
				.NumeroSerie = toItem.SerieTI_PK
				loSentencia = .obtenersentenciasInsert()
			catch to loError
				local loEx as zooexception OF zooexception.prg 
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				With loEx
					loError.Message = 'Problemas al intentar grabar en Asociación entre Item de servicio y serie del TI  '
					.Grabar( loError  )
					.Throw()
				Endwith
			finally
				.Cancelar() 
			endtry
		endwith 
		return loSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidadAUxiliar() as Void
		this.oEntidadPadre = _screen.zoo.instanciarentidad( "relaciontiis" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerBaja( toitem ) as Void
		local loSentencia as Object, loError as zooexception OF zooexception.prg, lcCodigo as String

		lcCodigo = this.obtenerIdBaja()

		with This.oEntidad
			try
				.codigo = toItem.nroitemserv_pk
				.modificar()
				.bajaregpor_PK = this.oDetalle.cRegpor
				.FechaBajaRegistro = goServicios.Librerias.ObtenerFecha()
				.FechaBajaVigencia = toItem.fechabajavigencia
				.RelaLoteBaja = lcCodigo

				loSentencia = .obtenersentenciasUpdate()

			catch to loError
				local loEx as zooexception OF zooexception.prg 
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				With loEx
					loError.Message = 'Problemas al intentar ACTUALIZAR ( BAJA ) Item de servicio   '
					.Grabar( loError  )
					.Throw()
				Endwith
			finally
				.Cancelar() 
			endtry
		endwith 
		return loSentencia

	endfunc 
	*-----------------------------------------------------------------------------------------
	function VerificarSerieRZ( txval ) as Boolean 
		local llretorno as Boolean 
		llretorno = this.oEntidad.VerificarSerieBaja( txval, this.oDetalle.cRazonSocial)

		return llretorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasEsquemaComision( toItem as Object, tnEsquemaComision as Integer  ) as zoocoleccion OF zoocoleccion.prg 
		local loSentencia as Object, loError as zooexception OF zooexception.prg

		with This.oCOMASIGITEMSERESQCOM
			loSentencia = _screen.zoo.crearobjeto( "zoocoleccion" )
			try
				.RegimenComision.oDesactivador.ValidarActivo = .F.
				.nuevo()
				.codigoISauxiliar = this.oentidad.Codigo
				.RegimenComision_pk = tnEsquemaComision
				loSentencia = this.ReasignarCodigoIS( .obtenersentenciasInsert() )
			catch to loError
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				With loEx
					loError.Message = 'Problemas al intentar grabar en Asociación entre Item de servicio y Esquema de comisión.'
					.Grabar( loError  )
					.Throw()
				Endwith
			finally
				.Cancelar()
			endtry
		endwith 

		return loSentencia
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ReasignarCodigoIS( toColSentencias as zoocoleccion OF zoocoleccion.prg ) as zoocoleccion OF zoocoleccion.prg
		local loCol as zoocoleccion OF zoocoleccion.prg, lcSentencia  as String, lcCampo as String, lcCampoAux as String,;
		 lcVirtual as String, lcSentenciaSQL as String    
		loCol = _screen.zoo.crearobjeto( "zoocoleccion" )
		lcCampo = lower( This.oCOMASIGITEMSERESQCOM.oAD.ObtenerCampoEntidad( 'ItemServicio' ) )
		lcCampoAux = lower( This.oCOMASIGITEMSERESQCOM.oAD.ObtenerCampoEntidad( 'codigoISauxiliar' ) )
		lcVirtual = lcCampoAux + "_" 
		
		lcSentenciaSQL = " update " +_screen.zoo.app.cSucursalActiva + ".COMASISESC set  Codis = Aux where codis = 0"
		
		for each lcSentencia in toColSentencias
			lcSentencia = strtran( lower( lcSentencia ), lcCampoAux, lcVirtual )
			lcSentencia = strtran( lower( lcSentencia ), lcCampo , lcCampoAux)
			lcSentencia = strtran( lower( lcSentencia ), lcVirtual, lcCampo )
			loCol.agregar( lcSentencia )	
		endfor
		
		if godatos.essqlserver() 
			locol.agregar( lcSentenciaSQL )
		endif
	
		return loCol
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerEsquemaDeComision( tcRazonSocial as String ) as Integer 
		local loEntidad as Object, lnRetorno as Integer 
		loEntidad = _screen.zoo.instanciarentidad( "zlasigesquecomisio" )
		
		lnRetorno = loEntidad.obtenerEsquemaDeComision( tcRazonSocial )
		loEntidad.release()
		return lnRetorno
	endfunc 


enddefine
