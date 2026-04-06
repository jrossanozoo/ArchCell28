define class ComponenteRSIncobrableAprob as Din_ComponenteRSIncobrableAprob of Din_ComponenteRSIncobrableAprob.prg

	cMensaje = ""
	cAccRealiz = ""
	nMontoDeudaCupones = 0
	nMontoDeudaCtaCte = 0

	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg
		local loColeccion as ZooColeccion of ZooColeccion.Prg, loSentencias as Object, lcSentencia as String

		loColeccion = _screen.zoo.crearobjeto( "ZooColeccion" )

		if this.oEntidadPadre.EstadoAprob.Cod = "1"
			goServicios.Mensajes.EnviarSinEsperaProcesando( "Procesando Baja de Items Vigentes..." )
			loSentencias = this.ObtenerSentenciasDeZLSERVICIOSLOTEBAJA()
			for each loItem in loSentencias
				loColeccion.Agregar( loItem )
			endfor

*!*				goServicios.Mensajes.EnviarSinEsperaProcesando()

*!*				goServicios.Mensajes.EnviarSinEsperaProcesando( "Generando Notas de Crédito..." )
*!*				this.GenerarComprobantesNCRazonesSocialesIncobrables()

*!*				if this.nMontoDeudaCupones = 0 and this.nMontoDeudaCtaCte = 0
*!*					this.cAccRealiz = 'La razón social "' + alltrim( this.oEntidadPadre.RazonSocial_PK ) + '" no posee deuda al momento de la baja.' + ;
*!*									 iif( !empty( this.cMensaje ), + chr( 13 ) + chr( 10 ) + this.cMensaje, "" )
*!*				else
*!*					this.cAccRealiz = iif( !empty( this.cMensaje ), "Se han generado los siguientes comprobantes:" + chr( 13 ) + chr( 10 ) + this.cMensaje, "" )
*!*				endif
*!*				lcSentencia = "Update ZL.RzIncoap set Accreal = '" + this.cAccRealiz + "' where Numero = " + transform( this.oEntidadPadre.NumeroInt )
*!*				loColeccion.Agregar( lcSentencia )

			loSentencias = null
			goServicios.Mensajes.EnviarSinEsperaProcesando()
		endif

		goServicios.Mensajes.EnviarSinEsperaProcesando( "Actualizando datos de la entidad..." )
		lcSentencia = "Update ZL.RzInco set FechAuto = '" + ;
			transform( goServicios.Librerias.ObtenerFechaFormateada( goServicios.Librerias.ObtenerFecha() ) ) + ;
			"' where Numero = " + transform( this.oEntidadPadre.NumRegInco_PK )
		loColeccion.Agregar( lcSentencia )
		goServicios.Mensajes.EnviarSinEsperaProcesando()

		this.cMensaje = ""
		this.cAccRealiz = ""

		return loColeccion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeZLSERVICIOSLOTEBAJA() as Object
		local lcSql as String, loEntItems as Object, llAgregarItems as Boolean

		loSentencia = _screen.zoo.crearobjeto( "ZooColeccion" )
		lcSql = "select i.ccod as Item, i.codart as Articulo,art.Descr as ArticuloDescr, i.nroserie as Serie, s.Puesto,ti.nroserie as SerieTi,i.febavig, i.relaloteb" + ;
			" from zl.itemserv as i " + ;
			" inner join zl.funcitemsvigentes() as iv on i.ccod = iv.ccod " + ;
			" inner join zl.series as s on s.nroserie = i.nroserie " + ;
			" inner join zl.isarticu as art on art.ccod = i.codart " + ;
			" left join zl.relaciontiis as ti on ti.ccod = i.ccod " + ;
			" where i.relaloteb = 0 and i.crass = '" + this.oEntidadPadre.RazonSocial_PK + "'"

		goServicios.Datos.EjecutarSentencias( lcSql, "itemserv, series, isarticu, relaciontiis", "", "c_ItemsPendientes", set( "datasession" ) )
		llAgregarItems = reccount( "c_ItemsPendientes" ) > 0

		if llAgregarItems
			loEntItems = _Screen.Zoo.InstanciarEntidad( "ZLSERVICIOSLOTEBAJA" )
			with loEntItems
				.Nuevo()
				.RazonSocial_PK = this.oEntidadPadre.RazonSocial_PK
				.Contacto_pk = goParametros.Zl.ValoresSugeridos.ContactoPredeterminadoEnBajaDeItemsPorDeudoresIncobrables
				.MotivoBaja_PK = goParametros.Zl.ValoresSugeridos.MotivoDeBajaDeDeudoresIncobrables
				.Observ = "Generado Automáticamente por el Comprobante de Aprobación de Razones Sociales Incobrables nº " + transform( this.oEntidadPadre.NumeroInt )
				.oAD.GrabarNumeraciones()
				select c_ItemsPendientes
				scan
					.SubItems.LimpiarItem()
					.SubItems.oItem.NroItemServ_PK = c_ItemsPendientes.Item
					.SubItems.oItem.FechaBajaVigencia = goServicios.Librerias.ObtenerFecha()
					.SubItems.Actualizar()
				endscan

				loSentencia = .ObtenerSentenciasInsert()
				loColSentenciasComponente = .subitems.oitem.oCompServicios.grabar()
				for each loItem in loColSentenciasComponente
					loSentencia.Agregar( loItem )
				endfor
			endwith

			this.cMensaje = this.cMensaje + "Baja de items de servicio nº " + transform( loEntItems.Numero ) + chr( 13 ) + chr( 10 )
			loEntItems.release()
			loColSentenciasComponente = null
		endif
		use in select( "c_ItemsPendientes" )

		return loSentencia
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarComprobantesNCRazonesSocialesIncobrables() as void
		local loActZoo as Object, loColGenComp as Object

		try
			loActZoo = _Screen.Zoo.CrearObjeto( "ActualizarZoo", "ActualizarZoo.prg" )
			loColGenComp = loActZoo.GenerarComprobantesRazonesSocialesIncobrables( this.oEntidadPadre.RazonSocial_PK )
			if loColGenComp.count > 0
				for each loMensaje in loColGenComp
					this.cMensaje = this.cMensaje + transform( loMensaje ) + chr( 13 ) + chr( 10 )
				endfor
			endif
			if type( "loActZoo.oFacturacionLince.MontoDeudaCupones" ) = "N" and type( "loActZoo.oFacturacionLince.MontoDeudaCtaCte" ) = "N"
				this.nMontoDeudaCupones = loActZoo.oFacturacionLince.MontoDeudaCupones
				this.nMontoDeudaCtaCte = loActZoo.oFacturacionLince.MontoDeudaCtaCte
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loColGenComp = null
			loActZoo.release()
		endtry
	endfunc

enddefine
