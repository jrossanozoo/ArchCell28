define class Ent_ListaDePrecios as Din_EntidadListaDePrecios of Din_EntidadListaDePrecios.prg

	#if .f.
		local this as Ent_ListaDePrecios of Ent_ListaDePrecios.prg
	#endif

	lRespondioActualizarListasDePreciosConOrdenamientoEnCero = 0
	cXmlListasDePreciosConOrdenIgual = ""
	oColaboradorFormulasYListasDePrecios = NULL
	oMoneda = null

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.BindearEvento( this, "Nuevo", this, "EventoHabilitarControlPreciosCalculadosAlUsarlos" )
		this.BindearEvento( this, "Modificar", this, "EventoDesHabilitarControlPreciosCalculadosAlUsarlos" )
		if pemstatus(this, "Precioscalculadosalusarlos_Assign", 5)
			this.BindearEvento( this, "Precioscalculadosalusarlos_Assign", this, "EventoHabilitarDeshabilitarParametrosPrecios" )
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorFormulasYListasDePrecios_Access() as variant
		with this
			if !this.ldestroy and ( !vartype( .oColaboradorFormulasYListasDePrecios ) = 'O' or isnull( .oColaboradorFormulasYListasDePrecios ) )
				.oColaboradorFormulasYListasDePrecios = _Screen.Zoo.CrearObjeto( "ColaboradorFormulasYListasDePrecios" )
			endif
		endwith
		return this.oColaboradorFormulasYListasDePrecios
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oMoneda_Access() as variant
		with this
			if !this.ldestroy and ( !vartype( .oMoneda ) = 'O' or isnull( .oMoneda ) )
				.oMoneda = _Screen.Zoo.Instanciarentidad( "Moneda" )
			endif
		endwith
		return this.oMoneda
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPrimeraPosicionDeOrdenamientoLibre() as Void
		local lcXml as string, lcCursor as String, lnInd as Integer, lnRetorno as Integer
		
		lcCursor = sys( 2015 )
		lcXml = this.oAd.obtenerdatosentidad( "OrdenConsulta" )
		lnCont = 0 
		lnRetorno = 0
		
		this.XmlACursor( lcXml, lcCursor ) 
		select distinct OrdenConsulta from &lcCursor where OrdenConsulta > 0 order by OrdenConsulta into cursor &lcCursor
				
		go top in &lcCursor

		for lnInd = 1 to 3
			if &lcCursor..OrdenConsulta != lnInd or eof()
				lnRetorno = lnInd
				exit
			else
				skip
			endif			
		endfor

		use in select( lcCursor )			

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerListasDePrecios() as zoocoleccion OF zoocoleccion.prg
		local lcXml as String, loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object
		
		loRetorno = _screen.zoo.CrearObjeto( "zooColeccion" )		

		lcXml = this.oAd.obtenerdatosentidad( "codigo,condicioniva", "", "codigo" )
		this.XmlACursor( lcXml, "C_Codigos" ) 
		select c_Codigos
		scan 
			loItem = this.ObtenerItemAuxParaColeccionDeListasDePrecios()
			loItem.Codigo = alltrim( c_Codigos.Codigo )
			loItem.CondicionIva = c_Codigos.CondicionIva
			loRetorno.Add( loItem )
		endscan 
					
		use in select( "c_Codigos" )			
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerListasDePreciosConVisibilidad( tcEntidad as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		
		loRetorno = _screen.zoo.CrearObjeto( "zooColeccion" )

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerListasDePreciosCalculadasAlMomento() as zoocoleccion OF zoocoleccion.prg
		local lcXml as String, loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object
		
		loRetorno = _screen.zoo.CrearObjeto( "zooColeccion" )		
		
		lcXml = this.oAd.obtenerdatosentidad( "codigo", "PreciosCalculadosAlUsarlos = .t.", "codigo" )
		this.XmlACursor( lcXml, "C_Codigos" ) 
		select c_Codigos
		scan 
			loRetorno.Add( alltrim( c_Codigos.Codigo ), alltrim( c_Codigos.Codigo ) )
		endscan 
					
		use in select( "c_Codigos" )
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemAuxParaColeccionDeListasDePrecios as Object
		local loItem as Object
		loItem = newobject( "Custom" )
		loItem.AddProperty( "Codigo", "" )
		loItem.AddProperty( "CondicionIva", 0 )
		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarOrdenDeConsultaRepetido() as Boolean
		local llRetorno as Boolean, lcCursor as String, lcXml as String, lcListasDePrecios as String
		llRetorno = .t.
		with this
			if !empty( this.OrdenConsulta )
				lcCursor = sys( 2015 )
				This.cXmlListasDePreciosConOrdenIgual = .oAD.ObtenerDatosEntidad( "Codigo, OrdenConsulta", "OrdenConsulta == " + transform( this.OrdenConsulta ) + " and !( alltrim( Codigo ) == '" + alltrim( This.Codigo ) + "')", "" , "" )
				.XmlACursor( This.cXmlListasDePreciosConOrdenIgual, lcCursor )
				if reccount( lcCursor ) >= 1
					lcListasDePrecios = ""
					scan
						lcListasDePrecios = lcListasDePrecios + Codigo + ", "
					endscan
					lcListasDePrecios = strtran( lcListasDePrecios, ",", ".", occurs( ",", lcListasDePrecios ), 1 )

					llRetorno = .F.
					this.AgregarInformacion( "El Orden en Consulta " + transform( this.OrdenConsulta ) + " ya se encuentra asignado a las siguientes Listas de Precios: " + lcListasDePrecios )
				endif
				use in select( lcCursor )
			endif
		endwith
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarOrdenDeConsultaNoRepetido() as boolean
		local lnRespuesta as Integer, lcCursor as String, loEntidadListaDePrecio as din_entidadListaDePrecios of din_entidadListaDePrecios.prg,;
		loInfo as zooinformacion of zooInformacion.prg, llRetorno as Boolean

		This.lRespondioActualizarListasDePreciosConOrdenamientoEnCero = 0
		
		llRetorno = .t.
		if This.ValidarOrdenDeConsultaRepetido()
		else
			This.EventoPreguntarActualizarListasDePreciosConOrdenamientoEnCero()
			if 6 = This.lRespondioActualizarListasDePreciosConOrdenamientoEnCero
				lcCursor = sys( 2015 )
				this.XmlACursor( This.cXmlListasDePreciosConOrdenIgual, lcCursor )

				loEntidadListaDePrecio = _screen.zoo.instanciarentidad( "ListaDePrecios" )
				select &lcCursor
				scan
					with loEntidadListaDePrecio as din_entidadListaDePrecios of din_entidadListaDePrecios.prg
						try
							.Codigo = &lcCursor..Codigo
							.Modificar()
							.OrdenConsulta = 0
							.Grabar()
						catch to loError
							goServicios.Errores.LevantarExcepcion( loError )
						endtry
					endwith
				endscan			
				use in select( lcCursor )

				loEntidadListaDePrecio.Release()
			else
				This.AgregarInformacion( "Debe establecer un orden de consulta no repetido." )
				llRetorno = .f.
			endif
		endif

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarActualizarListasDePreciosConOrdenamientoEnCero() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ListaUtilizadaEnFormula() as Boolean
		local llRetorno as Boolean, loColaboradorFormulasYListasDePrecios as Object
		llRetorno = .F.
		llRetorno = this.oColaboradorFormulasYListasDePrecios.ListaUtilizadaEnFormula( this.Codigo )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAnulacion() as Boolean
		local llRetorno as Boolean 
		llRetorno = .T.
		If this.ListaUtilizadaEnFormula()
			this.AgregarInformacion( "La lista de precios se encuentra utilizada en una fórmula.", 0 )
			llRetorno = .F.
		endif
		if llRetorno
			llRetorno = dodefault()
		endif
		return llRetorno
	endfunc 
	
	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = .F. 
		if dodefault() and this.ValidarDescuento()
			llRetorno = .T.
		else 
			this.AgregarInformacion( "El Descuento seleccionado tiene un modo de funcionamiento no permitido para la operación." )
		endif
		return llRetorno
	Endfunc
	
	*-------------------------------------------------------------------------------------------------
	Function ValidarDescuento() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			if vartype( this.DescuentoPreferente ) == "O" and ltrim( this.DescuentoPreferente_PK ) != "" and this.DescuentoPreferente.ModoFuncionamiento != 4 and this.DescuentoPreferente.ModoFuncionamiento != 6
					llRetorno = .F.
			endif
		endif
		
		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoHabilitarControlPreciosCalculadosAlUsarlos() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoDesHabilitarControlPreciosCalculadosAlUsarlos() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_Precioscalculadosalusarlos( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal )
		if this.lEdicion
			this.AgregarInformacion( "No puede modificar el atributo." )
			llRetorno = .f.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoHabilitarDeshabilitarParametrosPrecios( txVal as variant ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_Listapbase( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean, lcXml as String, lcCursor as String
		llRetorno =	dodefault( txVal, txValOld )
		if llRetorno
			lcCursor = sys( 2015 )
			lcXml = this.ObtenerDatosEntidad( "Precioscalculadosalusarlos", "Codigo = '" + txVal + "'" )
			xmltocursor( lcXml, lcCursor )
			select &lcCursor
			if !eof() and ( &lcCursor..Precioscalculadosalusarlos )				
				llRetorno = .f.
				goServicios.Errores.LevantarExcepcion("Debe ingresar una lista de precios base que no sea del tipo Calculada al momento.")
			endif
			use in select( lcCursor )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarMonedaComoCoeficiente( tcCodigoMoneda as String ) as Void
		local llRetorno as Boolean 
		llRetorno = this.oMoneda.oAD.verificarexistenciaclaveprimaria( tcCodigoMoneda )			
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoHabilitarDeshabilitarMonedaParaCotizacion() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoHabilitarDeshabilitarCoeficiente() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarListaPBase() as boolean
		local llRetorno as boolean
		if this.PreciosCalculadosAlUsarlos and empty( this.ListaPBase_PK )
			this.AgregarInformacion( 'Debe cargar el campo Lista de precios base', 9005, 'CondicionIva' )
			llRetorno = .f.
		else
			llRetorno = dodefault()
		endif		
		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as Void
		local llRetorno as Boolean, llEsCalculadaAlMomento as Boolean
		llEsCalculadaAlMomento = this.PreciosCalculadosAlUsarlos
		llRetorno = dodefault()
		
		if llEsCalculadaAlMomento
			If Empty( this.Operador )
				llRetorno = .F.
				This.AgregarInformacion( 'Debe cargar el campo Operador', 0 )
			endif
			If empty( this.Coeficiente) and empty( this.MonedaParaCotiz_Pk )
				llRetorno = .F.
				This.AgregarInformacion( 'Debe cargar los campos Coeficiente o Cotización.', 0 )
			endif
			If !empty( this.TipoRedondeo ) and empty( this.Cantidad )
				llRetorno = .F.
				This.AgregarInformacion( 'Debe completar el campo Dígito.', 0 )
			endif
			If !empty( this.Cantidad ) and empty( this.TipoRedondeo )
				llRetorno = .F.
				This.AgregarInformacion( 'Debe completar el campo Redondeo.', 0 )
			endif
		endif
		
		return llRetorno
	endfunc 
	
enddefine
