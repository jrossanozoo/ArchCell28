define class Ent_Buzon as Din_EntidadBuzon of Din_EntidadBuzon.prg
	
	#IF .f.
		Local this as Ent_Buzon of Ent_Buzon.prg
	#ENDIF

	oColaboradorRutas = null
	oBaseDeDatos = null
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as void
		dodefault()
		bindevent( this, "Modificar", this, "ReasignarUnidadYRuta", 1 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorRutas_Access() as object
		if !this.lDestroy and ( vartype( this.oColaboradorRutas ) <> 'O' or isnull( this.oColaboradorRutas ) )
			this.oColaboradorRutas = _screen.zoo.CrearObjeto( "ColaboradorRutasBuzon" )
		endif
		return this.oColaboradorRutas
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReasignarUnidadYRuta() as void
		local lcDirectorio as string
		lcDirectorio = this.oColaboradorRutas.ArmarRutaBuzon( addbs( alltrim( this.Directorio ) ) )
		this.HUnid = this.oColaboradorRutas.ExtraerUnidad( lcDirectorio )
		this.HPath = this.oColaboradorRutas.ExtraerRuta( lcDirectorio )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_HUnid( txVal as string ) as void
		dodefault( txVal )
		if !this.CargaManual()
			this.ReasignarDirectorio()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_HPath( txVal as string ) as void
		dodefault( txVal )
		if !this.CargaManual()
			this.ReasignarDirectorio()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReasignarDirectorio() as void
		this.Directorio = ""
		if !empty( this.HUnid )
			this.Directorio = alltrim( this.HUnid ) + ":"
		endif
		this.Directorio = this.Directorio + alltrim( this.HPath )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llValido as boolean
		llValido = dodefault()
		llValido = this.oColaboradorRutas.ValidarDirectorio( this ) and llValido
		return llValido
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDirectorioEnvia( tcUnidad as string, tcRuta as string, tcBuzon as string ) as string
		return this.oColaboradorRutas.ArmarRutaBuzonEnvia( tcUnidad, tcRuta, tcBuzon )
	endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		local llRetorno as Boolean
		this.LimpiarAtributosDeFranquicia()		
		llRetorno = dodefault()
		llRetorno = llRetorno and this.ValidarSerieOBaseDeDatos()		
		llRetorno = llRetorno and this.ValidarSerieSegunComportamientoFranquicia()		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarAtributosDeFranquicia() as Void
		local lvalor as Boolean
		with this
			do case
				case .comportamiento = 3
					lvalor = .lHabilitarClienteFranquicia_PK
					.lHabilitarClienteFranquicia_PK = .t.
					.ClienteFranquicia_pk = ""
					.lHabilitarClienteFranquicia_PK = lvalor
				case .comportamiento = 2
					lvalor = .lHabilitarProveedorFranquicia_PK
					.lHabilitarProveedorFranquicia_PK = .t.
					.ProveedorFranquicia_pk = ""
					.lHabilitarProveedorFranquicia_PK = lvalor
				case .comportamiento = 4
					lvalor = .lHabilitarClienteFranquicia_PK
					.lHabilitarClienteFranquicia_PK = .t.
					.ClienteFranquicia_pk = ""
					.lHabilitarClienteFranquicia_PK = lvalor
					lvalor = .lHabilitarProveedorFranquicia_PK
					.lHabilitarProveedorFranquicia_PK = .t.
					.ProveedorFranquicia_pk = ""
					.lHabilitarProveedorFranquicia_PK = lvalor
				otherwise
			endcase
		endwith 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsSerieFranquicia( tnSerie as integer) as boolean
		return this.EsSerieSegunComportamiento( tnSerie, 2 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsSerieFranquiciante( tnSerie as integer) as boolean
		return this.EsSerieSegunComportamiento( tnSerie, 3 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsSerieSegunComportamiento( tnSerie as integer, tnComportamiento as integer) as boolean
		local llEsFranquicia as boolean, lcCursor as string, lcXmlDatos as string
		lcCursor = "c_buzones_" + sys(2015)
		lcXmlDatos = this.ObtenerDatosEntidad( "Codigo", "HSERIE = " + alltrim(str(tnSerie)) + " and COMPORT = " + transform(tnComportamiento) )
		xmlToCursor( lcXmlDatos, lcCursor )
		if used( lcCursor )
			llEsFranquicia = reccount(lcCursor) > 0
			use in (lcCursor)
		endif            
		return llEsFranquicia
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosFranquiciaPorSerie( tnSerie as integer ) as Object
		local llEsFranquicia as boolean, lcCursor as string, lcXmlDatos as string
		local loRetorno as Object
		loRetorno = null
		lcCursor = "c_buzones_" + sys(2015)
		lcXmlDatos = this.ObtenerDatosEntidad( "Codigo,origenfranquicia,clientefranquicia,proveedorfranquicia", "HSERIE = " + alltrim(str(tnSerie)) + " and COMPORT > 1 " )
		xmlToCursor( lcXmlDatos, lcCursor )
		if used( lcCursor ) and reccount( lcCursor ) > 0
			scatter name loRetorno
			use in (lcCursor)
		endif            
		return loRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Comportamiento( txVal as variant ) as void
		dodefault( txVal )
		this.HabilitarAtributosFranquicia()
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarAtributosFranquicia() as Void
		local llOrigen as Boolean, llCliente as Boolean, llProveedor as Boolean
		with this
			do case
				case .Comportamiento = 2
					llOrigen = .t.
					llCliente = .t.
					llProveedor = .f.
				case .Comportamiento = 3
					llOrigen = .t.
					llCliente = .f.
					llProveedor = .t.
				case .Comportamiento = 4
					llOrigen = .t.
					llCliente = .f.
					llProveedor = .f.
				otherwise
			endcase
			.lHabilitarOrigenFranquicia_PK = llOrigen
			.lHabilitarClienteFranquicia_PK = llCliente
			.lHabilitarProveedorFranquicia_PK = llProveedor
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function CompletarItemTransferencia( tcFiltro as String, tcAtributo as String, tlSetearBuzonLince as Boolean, toItem as Object ) as Void
		This.XmlACursor( this.oAd.ObtenerDatosEntidad( "CODIGO,hunid,hpath,BaseDeDatos,EsBuzonLince," + tcFiltro , tcFiltro + " = '" + tcAtributo + "'" ), "c_Ver" )
		if reccount( "c_Ver" ) > 0
			go top in c_Ver
			if empty( c_ver.basededatos ) 
				toitem.cBuzonDestino = this.ObtenerDirectorioEnvia( c_ver.hunid, c_ver.hpath, c_ver.Codigo )
				toItem.cBuzon = alltrim(  c_ver.Codigo )
			else
				toItem.cBaseDeDatos = c_ver.basededatos
			endif
			if tlSetearBuzonLince 
				toItem.lEsBuzonLince =  c_ver.EsBuzonLince
			endif
		endif
		use in select( "c_Ver" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_BaseDeDatos( txVal as string ) as void
		dodefault( txVal )
		if empty( txVal )
			this.lHabilitarEsBuzonLince = .t.
			this.lHabilitarOrigenDeDatos_pk = .t.
		else
			this.EsBuzonLince = .f.
			this.lHabilitarEsBuzonLince = .f.
			this.lHabilitarOrigenDeDatos_pk = .t.
			this.OrigenDeDatos_pk = this.ObtenerOrigenDestinoBaseDeDatos( txVal )
			this.lHabilitarOrigenDeDatos_pk = .f.
		endif
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oBaseDeDatos_Access() as variant
		if !this.ldestroy and ( !vartype( this.oBaseDeDatos ) = 'O' or isnull( this.oBaseDeDatos ) )
			this.oBaseDeDatos = _Screen.zoo.instanciarEntidad( "BaseDeDatos" )
		endif
		return this.oBaseDeDatos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerOrigenDestinoBaseDeDatos( tcBaseDeDatos as String ) as String
		local lcRetorno as String
		lcRetorno = ""
		try
			this.oBaseDeDatos.Codigo = tcBaseDeDatos 
			lcRetorno = this.oBaseDeDatos.OrigenDestino_pk
		catch
		endtry
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarSerieSegunComportamientoFranquicia() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if this.Comportamiento > 1 and empty( this.Serie ) 		
			llRetorno = .f.
			this.AgregarInformacion("Debe cargar el campo Serie, necesario para el circuito de franquicias.")
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarSerieOBaseDeDatos() as Void
		local llRetorno as Boolean
		llRetorno = .t.
		if empty( this.Serie ) and empty( this.BaseDeDatos ) 	
			llRetorno = .f.
			this.AgregarInformacion("Debe cargar el campo Serie o elegir una base de datos.")
		endif
		return llRetorno
	endfunc 

enddefine
