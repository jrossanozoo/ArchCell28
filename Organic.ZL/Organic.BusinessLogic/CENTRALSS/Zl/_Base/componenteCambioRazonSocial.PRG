define class ComponenteCambioRazonSocial as Din_ComponenteCambioRazonSocial of Din_ComponenteCambioRazonSocial.prg

	cAccionesRealizadas = ""
	cNumeroAltaIS = ""
	nNroItemServ = 0

	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg
		local loColeccion as ZooColeccion of ZooColeccion.Prg, loSentencias as Object, lcSentencia as String

		loColeccion = _screen.zoo.crearobjeto( "ZooColeccion" )
		this.cAccionesRealizadas = ""

		this.oEntidadPadre.EventoBajaItemsRZ()
		loSentencias = this.ObtenerSentenciasDeZLSERVICIOSLOTEBAJA()
		for each loItem in loSentencias
			loColeccion.Agregar( loItem )
		endfor

		this.oEntidadPadre.EventoAltaItemsRZ()
		loSentencias = this.ObtenerSentenciasDeZLSERVICIOSLOTE()
		for each loItem in loSentencias
			loColeccion.Agregar( loItem )
		endfor

		this.oEntidadPadre.EventoAltaVinculacion()
		loSentencias = this.ObtenerSentenciasDeZLVINCULACIONITEMS()
		for each loItem in loSentencias
			loColeccion.Agregar( loItem )
		endfor

		lcSentencia = "Update ZL.CambioRZ set Acc = '" + this.cAccionesRealizadas + "' where cCod = " + transform( this.oEntidadPadre.Numero )
		loColeccion.Agregar( lcSentencia )
		this.oEntidadPadre.EventoFinCambioRZ()

		return loColeccion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeZLSERVICIOSLOTEBAJA() as Object
		local loSentencia as Object, loError as ZooException of ZooException.prg, llEsCambioDeArticulo as Boolean, llTieneGrupoCom as Boolean, ;
			lnNumero as Integer, loColSentenciasComponente as Object, loColItemServ as ZooColeccion of ZooColeccion.Prg

		loColItemServ = _screen.zoo.crearobjeto( "ZooColeccion" )
		llEsCambioDeArticulo = ( this.oEntidadPadre.RZViejo_PK = this.oEntidadPadre.RZNuevo_PK  )

		with this.oZLSERVICIOSLOTEBAJA
			try
				.Nuevo()
				lnNumero = .Numero
				.RazonSocial_PK = this.oEntidadPadre.RZViejo_PK
				.Contacto_PK = this.oEntidadPadre.Contacto_PK
				.Observ = this.ObtenerObservacionDeEntidad()
				.MotivoBaja_PK = this.oEntidadPadre.MotivoBaja_PK
				.oAD.GrabarNumeraciones()
				for lnI = 1 to this.oEntidadPadre.subitems.count
					this.oEntidadPadre.subitems.CargarItem( lnI )
					.subitems.LimpiarItem()
					.subitems.oitem.NroItemServ_PK = this.oEntidadPadre.subitems.oItem.NroItemServ_PK
					.subitems.oitem.FechaBajaVigencia = this.oEntidadPadre.subitems.oItem.FechaBajaVigencia 
					if llEsCambioDeArticulo and !llTieneGrupoCom and !this.oEntidadPadre.subitems.oItem.Articulo.TieneModuloComunicador() and this.oEntidadPadre.subitems.oItem.ArticuloAnterior.TieneModuloComunicador()
						llTieneGrupoCom = .t.
					endif
					.subitems.Actualizar()
					loColItemServ.Agregar( "update zl.Itemserv set Relaloteb = " + transform( lnNumero ) + " where Ccod = " + transform( this.oEntidadPadre.subitems.oItem.NroItemServ_PK ) )
				endfor
				.BajaComunicacion = iif( llTieneGrupoCom, 1, 2 )
				loSentencia = .ObtenerSentenciasInsert()

				loColSentenciasComponente = .subitems.oitem.oCompServicios.grabar()
				for each loItem in loColSentenciasComponente
					loSentencia.Agregar( loItem )
				endfor
				for each loItem in loColItemServ
					loSentencia.Agregar( loItem )
				endfor

				this.cAccionesRealizadas = this.cAccionesRealizadas + "Se realizó la Baja de Items Nº " + transform( lnNumero ) + chr( 13 )
			catch to loError
				local loEx as ZooException OF ZooException.prg
				loEx = newobject( "ZooException", "ZooException.prg" )
				with loEx
					loError.Message = "Problemas al intentar grabar la Entidad ZLSERVICIOSLOTEBAJA "
					.Grabar( loError )
					.Throw()
				endwith
			finally
				.Cancelar()
			endtry
		endwith

		return loSentencia
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeZLSERVICIOSLOTE() as Object
		local loSentencia as Object, loError as ZooException of ZooException.prg, lnNumero as Integer, loColSentenciasComponente as Object

		with this.oZLSERVICIOSLOTE
			try
				.Nuevo()
				lnNumero = .Numero
				.RazonSocial_PK = this.oEntidadPadre.RZNuevo_PK
				.Contacto_PK = this.oEntidadPadre.Contacto_PK
				.Observ = this.ObtenerObservacionDeEntidad()
				.oAD.GrabarNumeraciones()
				for lnI = 1 to this.oEntidadPadre.subitems.count
					this.oEntidadPadre.subitems.CargarItem( lnI )
					if !empty( this.oEntidadPadre.subitems.oItem.Articulo_pk )
						.subitems.LimpiarItem()
						.subitems.oitem.Serie_Pk = this.oEntidadPadre.subitems.oItem.Serie_pk 
						.subitems.oitem.Articulo_pk = this.oEntidadPadre.subitems.oItem.Articulo_pk
						.subitems.oitem.ProductoZooLogicDetalle = this.oEntidadPadre.subitems.oItem.Serie.ProductoZooLogic.descrip
						.subitems.oitem.SerieTI_Pk = this.oEntidadPadre.subitems.oItem.Serieti_pk
						.subitems.oitem.Grupocom_Pk = this.oEntidadPadre.subitems.oItem.GrupoCom_pk
						.subitems.oitem.FechaAltaVigencia = this.oEntidadPadre.subitems.oItem.FechaBajaVigencia
						.subitems.Actualizar()
					endif
				endfor
				loSentencia = .ObtenerSentenciasInsert()

				this.nNroItemServ = .oCompServicios.oEntidad.ObtenerSiguienteNumerico() - 1
				loColSentenciasComponente = .oCompServicios.grabar()
				for each loItem in loColSentenciasComponente
					loSentencia.Agregar( loItem )
				endfor

				this.cAccionesRealizadas = this.cAccionesRealizadas + "Se realizó el Alta de Items Nº " + transform( lnNumero ) + chr( 13 )
				this.cNumeroAltaIS = alltrim( str( lnNumero ) )
				.CrearCuentaComunicaciones()
			catch to loError
				local loEx as ZooException OF ZooException.prg
				loEx = newobject( "ZooException", "ZooException.prg" )
				with loEx
					loError.Message = "Problemas al intentar grabar la Entidad ZLSERVICIOSLOTE "
					.Grabar( loError )
					.Throw()
				endwith
			finally
				.Cancelar()
			endtry
		endwith

		return loSentencia
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeZLVINCULACIONITEMS() as Object
		local loSentencia as Object, loError as ZooException of ZooException.prg, lnNumero as Integer, loColItemServ as ZooColeccion of ZooColeccion.Prg

		loColItemServ = _screen.zoo.crearobjeto( "ZooColeccion" )

		with this.oZLVINCULACIONITEMS
			try
				.Nuevo()
				lnNumero = .Numero
				.Observ = this.ObtenerObservacionDeEntidad()
				.oAD.GrabarNumeraciones()
				for lnI = 1 to this.oEntidadPadre.subitems.count
					this.oEntidadPadre.subitems.CargarItem( lnI )
					if !empty( this.oEntidadPadre.subitems.oItem.NroItemServ_pk ) and !empty( this.oEntidadPadre.subitems.oItem.Articulo_pk )
						.Detalleitems.LimpiarItem()
						.Detalleitems.oitem.NroItemServVinculado_pk = this.oEntidadPadre.subitems.oItem.NroItemServ_pk
						.Detalleitems.oitem.lCargando = .t.
						this.nNroItemServ = this.nNroItemServ + 1
						.Detalleitems.oitem.NroItemServ_pk = this.nNroItemServ
						.Detalleitems.oitem.lCargando = .f.
						.Detalleitems.Actualizar()
						loColItemServ.Agregar( "update zl.Itemserv set Relalote = " + transform( this.cNumeroAltaIS ) + " where Ccod = " + transform( this.nNroItemServ ) )
					endif
				endfor
				loSentencia = .ObtenerSentenciasInsert()

				for each loItem in loColItemServ
					loSentencia.Agregar( loItem )
				endfor

				this.cAccionesRealizadas = this.cAccionesRealizadas + "Se realizó la Vinculación de Items Nº " + transform( lnNumero ) + chr( 13 )
			catch to loError
				local loEx as ZooException OF ZooException.prg
				loEx = newobject( "ZooException", "ZooException.prg" )
				with loEx
					loError.Message = "Problemas al intentar grabar la Entidad ZLVINCULACIONITEMS "
					.Grabar( loError )
					.Throw()
				endwith
			finally
				.Cancelar()
			endtry
		endwith

		return loSentencia
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObservacionDeEntidad() as String
		local lcTexto as String, lcRetorno as String

		with this.oEntidadPadre
			if alltrim( .RZViejo_pk ) = alltrim( .RZNuevo_pk )
				lcTexto = ''
			else
				lcTexto =  " a " + alltrim( .RZNuevo_pk )
			endif
			lcRetorno = "Generado por Movimientos de Items Nº: " + alltrim( str( .Numero ) ) + " de la Razón Social: " + alltrim( .RZViejo_PK ) + lcTexto
		endwith

		return lcRetorno
	endfunc

enddefine
