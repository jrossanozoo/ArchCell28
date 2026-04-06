define class ComponenteAsignacionGrupoComunicacionesASeries as Din_ComponenteAsignacionGrupoComunicacionesASeries of Din_ComponenteAsignacionGrupoComunicacionesASeries.prg

	cAccionesRealizadas = ""
	oEntidadPadre = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidadPadre = toEntidad 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg
		local loColeccion as ZooColeccion of ZooColeccion.Prg, loSentencias as Object, lcSentencia as String

		loColeccion = _screen.zoo.crearobjeto( "ZooColeccion" )
		this.cAccionesRealizadas = ""

		this.oEntidadPadre.EventoAltaZLALTAGRUPOCOM()
		loSentencias = this.ObtenerSentenciasDeZLALTAGRUPOCOM()
		for each loItem in loSentencias
			loColeccion.Agregar( loItem )
		endfor

		lcSentencia = "Update ZL.AsGrComSS set ZADSFW = '" + this.cAccionesRealizadas + "' where Numero = " + transform( this.oEntidadPadre.Numero )
		loColeccion.Agregar( lcSentencia )
		this.oEntidadPadre.EventoFinEventoAltaZLALTAGRUPOCOM()

		return loColeccion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciasDeZLALTAGRUPOCOM() as Object
		local loSentencia as Object, loError as ZooException of ZooException.prg, lnNumero as Integer, lnI as integer, loColeccion as object, loitemCol  as Object

		with this.oZLALTAGRUPOCOM
			loError = null
			loColeccion = _screen.zoo.crearobjeto( "ZooColeccion" )
			for lnI = 1 to this.oEntidadPadre.DetalleSeries.count 
				
				if  vartype(loError) ='O'
					exit
				endif  
				this.oEntidadPadre.DetalleSeries.CargarItem( lnI )
				if !empty( this.oEntidadPadre.DetalleSeries.oItem.Serie_pk )
					try
						.Nuevo()
						lnNumero = .Numero
						.oAD.GrabarNumeraciones()					
						.NroSerie_pk = this.oEntidadPadre.DetalleSeries.oItem.Serie_pk
						.Contacto_PK = this.oEntidadPadre.Contacto_PK
						.detallegrupocomunica.LimpiarItem()
						.detallegrupocomunica.oitem.Grupo_Pk = this.oEntidadPadre.Grupo_pk
						.detallegrupocomunica.oitem.Numero_Pk = this.oEntidadPadre.DetalleSeries.oItem.Serie_pk
						.detallegrupocomunica.oitem.FechaAlta = this.oEntidadPadre.FechaAlta
						.detallegrupocomunica.Actualizar()
						.ZADSFW = 'Generado autómaticamente desde Asignación de grupo de comunicaciones a series Nº ' + transform( this.oEntidadPadre.Numero )
						this.cAccionesRealizadas = this.cAccionesRealizadas + "Se realizó el Documento de registro de alta de grupo de comunicación Nº " + transform( lnNumero ) + chr( 13 )
						loSentencia = .ObtenerSentenciasInsert()
						for each loitemCol in loSentencia 
							loColeccion.Agregar( loitemCol )
						endfor		
					catch to loError
						local loEx as ZooException OF ZooException.prg
						loEx = newobject( "ZooException", "ZooException.prg" )
						with loEx
							loError.Message = "Problemas al intentar grabar la Entidad ZLALTAGRUPOCOM "
							.Grabar( loError )
							.Throw()
						endwith
					finally
						.Cancelar()
					endtry							
				endif
			endfor

		endwith

		return loColeccion
	endfunc

enddefine
