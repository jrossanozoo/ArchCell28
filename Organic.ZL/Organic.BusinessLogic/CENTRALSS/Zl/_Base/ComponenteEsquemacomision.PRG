define class ComponenteESQUEMACOMISION as Din_ComponenteESQUEMACOMISION of Din_ComponenteESQUEMACOMISION.prg

	cRazonSocial = ''
	nRegimencomision = 0
	nNroVincIS = 0
	cEntidad = ''
	cItemPadre = ''
	cItemHijo = ''
	oDetalle = null

	*-----------------------------------------------------------------------------------------
	function Grabar() as zoocoleccion OF zoocoleccion.prg 
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loSentencia as zoocoleccion OF zoocoleccion.prg, lnI as Integer

		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )

		if this.lNuevo
			if this.centidad = "ZLVINCULACIONITEMS"
				this.ReemplazarEsquemaDeComision()
			else
				this.xmlacursor( this.ObtenerItemsSinEsquemas( ), "c_items" )
				select c_items
				scan
					loSentencia = this.obtenerSentencias( c_items.codigo )
					for lnI = 1 to loSentencia.count
						loRetorno.Agregar( loSentencia.item( lnI ) )
					endfor
				endscan
				use in select( "c_items" )
			endif
		endif
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarEsquemaDeComision() as Void
		local loEntidadComasigitemseresqcom as entidad OF entidad.prg, loItem as Object, lcXML as String, lnCodigoDeEsquemaPadre as Integer, ;
			lnCodigoDeEsquemaHijo as Integer, lnUltimoComprobante as Integer,;
			loEntZlasigesquecomisio as Ent_Zlasigesquecomisio of Ent_Zlasigesquecomisio.prg
			

		for each loItem in this.oDetalle
			if !empty( loItem.NroItemServ_pk )
 
				if vartype( loEntidadComasigitemseresqcom ) <> 'O'
					loEntidadComasigitemseresqcom = _screen.Zoo.InstanciarEntidad( "Comasigitemseresqcom" )
				endif					
				
				if vartype( loEntZlasigesquecomisio ) <> 'O' 
					loEntZlasigesquecomisio = _screen.Zoo.InstanciarEntidad( "Zlasigesquecomisio" )
				endif 	
				
				if empty( loItem.NroItemServVinculado_pk ) 

					lcSQL = "Select Esquema, [Razón Social] from ZL.funcEsquemasAsignadosaRZ() where [Razón Social] = '" + loItem.RazonSocial_PK + "'"
					godatos.ejecutarSentencias( lcSQL, "", "", "c_REGIMENCOMISION", this.DataSessionId )
					select( "c_REGIMENCOMISION" )
					with loEntidadComasigitemseresqcom
						try 
							.nuevo()
							.ItemServicio_pk = loItem.NroItemServ_pk
							.RegimenComision_pk = c_REGIMENCOMISION.Esquema  &&lnCodigoDeEsquemaPadre 
							.Obs = "Comprobante generado desde la Vinculación de Items de Servicios número " + transform( this.nNroVincIS )
							.Grabar()
						catch
							.Cancelar()
						endtry 
					endwith
					use in select( "c_REGIMENCOMISION" )
				else
	
					lcSQL = "Select NumComprobante, CodEsquema, AprobacionNumero, EsEsquemaAdicional from ZL.ItemsEsquemasAsignados( '" + dtos(goServicios.Librerias.ObtenerFecha()) + "') where " +;
					 		"Item=" + transform( loItem.NroItemServVinculado_pk ) + " order by EsEsquemaAdicional"
					
					godatos.ejecutarSentencias( lcSQL, "", "", "c_EsquemaPadre", this.DataSessionId )		
		
					lcSQL = "Select NumComprobante, CodEsquema, AprobacionNumero, EsEsquemaAdicional from ZL.ItemsEsquemasAsignados( '" + dtos(goServicios.Librerias.ObtenerFecha()) + "') where " +;
					 		"Item=" + transform( loItem.NroItemServ_pk ) + " order by EsEsquemaAdicional"
		
					
					godatos.ejecutarSentencias( lcSQL, "", "", "c_EsquemaHIJO", this.DataSessionId )							
					
					go top in c_EsquemaPadre
					select c_EsquemaPadre
				
					scan 
						
						select c_EsquemaHIJO
						locate for c_EsquemaHIJO.CodEsquema = c_EsquemaPadre.CodEsquema
						select c_EsquemaPadre
						
						 
						if found()
						else
							with loEntidadComasigitemseresqcom
								try 
									.nuevo()
									.ItemServicio_pk = loItem.NroItemServ_pk
									.RegimenComision_pk = c_EsquemaPadre.CodEsquema
									.numaprobacion_Pk = nvl(c_EsquemaPadre.AprobacionNumero, 0)
									.EsquemaAdicional = !empty( c_EsquemaPadre.EsEsquemaAdicional )
									.Obs = "Comprobante generado desde la Vinculación de Items de Servicios número " + transform( this.nNroVincIS )
									.Grabar()
								catch
									.Cancelar()
								endtry 
							endwith
						endif

						
					endscan	
					
					use in select( 'c_EsquemaPadre' )
					use in select( 'c_EsquemaHIJO'  )

				endif 	

			endif
		endfor

		if vartype( loEntidadComasigitemseresqcom ) = 'O'
			loEntidadComasigitemseresqcom.release()
		endif 
			
		if vartype( loEntZlasigesquecomisio ) = 'O'
			loEntZlasigesquecomisio.release()
		endif	
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerItemsSinEsquemas() as String
		local loEntidad as entidad OF entidad.prg, lcXML as XMLTable

		loEntidad = _screen.Zoo.InstanciarEntidad( "ZLItemsServicios" )
		lcXML = loEntidad.OAD.ObtenerDatosEntidad( "CODIGO", "cRaSS='" + this.cRazonSocial + "'" )
		this.xmlacursor( lcXML, "c_ItemsServicios" )

		lcXML = this.oCOMASIGITEMSERESQCOM.OAD.ObtenerDatosEntidad( "ITEMSERVICIO" )
		this.xmlacursor( lcXML, "c_ItemEsquema" )

		select CODIGO ;
		from c_ItemsServicios ;
		where CODIGO not in ( select ITEMSERVICIO from c_ItemEsquema ) ;
		into cursor tmp

		lcXML = this.cursoraxml( "tmp" )

		use in select( "c_ItemsServicios" )
		use in select( "c_ItemEsquema" )
		use in select( "tmp" )

		loEntidad.release()
		return lcXML
	endfunc

	*-----------------------------------------------------------------------------------------
	function Obtenersentencias( tnNroItem as Integer ) as Object 
		local loRetorno as Object, loError as Exception

		with this.oCOMASIGITEMSERESQCOM
			Try
				.Nuevo()
				.ItemServicio_Pk = tnNroItem	
				.RegimenComision_Pk = this.nRegimenComision
				loRetorno = .obtenerSentenciasInsert()
			Catch To loError
			finally
				.Cancelar()
			endtry  
		endwith 
		return loRetorno
	endfunc 

enddefine 

