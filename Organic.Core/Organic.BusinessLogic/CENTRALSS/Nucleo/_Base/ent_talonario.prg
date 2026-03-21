define class ent_Talonario as din_EntidadTalonario of din_EntidadTalonario.prg

	#IF .f.
		Local this as ent_Talonario of ent_Talonario.prg
	#ENDIF

	Letra = ""
	PuntoDeVenta = 0
	oColaboradorComprobantesElectronicos = null
	lIgnorarFiltroNumero = .t.	
	lTieneDiseñosParaEnviarMail = .f.
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void	
		this.lDestroy = .t.
		if vartype( this.oNumeraciones ) == "O" and !isnull( this.oNumeraciones )
			this.oNumeraciones.Release()
		endif		
		this.oNumeraciones = null
		dodefault()
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Formula( txVal as variant ) as void
		dodefault( txVal )
		
		if !empty( txVal ) and this.EsNuevo()
			this.HabilitarAtributosSegunTalonario( txVal )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		local lcEntidad as String
		lcEntidad = this.entidad
		dodefault()
		this.entidad = lcEntidad
		this.HabilitarAtributosTalonario( .f. )
		This.HabilitaDesHabilitaReservarNumero()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		*this.oNumeraciones.vaciarcolecciones()
		this.HabilitarAtributosTalonario( .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColaboradorComprobantesElectronicos_access() as Void
	local loFactory as FactoryColaboradorComprobantesElectronicos of FactoryColaboradorComprobantesElectronicos.prg

		if !this.ldestroy and ( !vartype( this.oColaboradorComprobantesElectronicos ) = 'O' or isnull( this.oColaboradorComprobantesElectronicos ) )
			loFactory = _Screen.zoo.Crearobjeto( "FactoryColaboradorComprobantesElectronicos" )
			this.oColaboradorComprobantesElectronicos = loFactory.ObtenerColaborador()
		endif
		return this.oColaboradorComprobantesElectronicos

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerParametroBocaDeExpendio() as Integer
		local lnRetorno as Integer
		lnRetorno = 0
		if pemstatus( goParametros, "felino", 5 )
			lnRetorno = int( goParametros.felino.Numeraciones.BocaDeExpendio )
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarAtributosTalonario( tlHabilitar as Boolean ) as void
		local lnProp as Integer, i as integer, lcProp as string
		local array laProp[ 1 ]
		
		lnProp = amembers( laProp, this )
		for i = 1 to lnProp
			lcProp = laProp[ i ]
			if left( lcProp, 10 ) == "LHABILITAR" and !inlist( lcProp, "LHABILITARNUMERO", "LHABILITARTALONARIORELA_PK", "LHABILITARRESERVARNUMERO" )
				this.&lcProp = tlHabilitar 
			endif
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HabilitarAtributosSegunTalonario( tcTalonario as String ) as void
		local lnProp as Integer, i as integer, lcProp as string, lcAtributo as string, loEntidad as object, loComponenteComprobantes as Object
		local array laProp[ 1 ]
		lnProp = amembers( laProp, this )
		for i = 1 to lnProp
			lcProp = upper( laProp[ i ] )
			lcAtributo = strtran( lcProp, "LHABILITAR", "" )
			
			if left( lcProp, 10 ) == "LHABILITAR" and lcAtributo != "ENTIDAD" and !inlist( lcProp, "LHABILITARNUMERO", "LHABILITARTALONARIORELA_PK", "LHABILITARRESERVARNUMERO" )
				this.&lcProp = this.PerteneceAlTalonario( lcAtributo, tcTalonario )
			endif
		endfor

		if this.esComprobanteDeVenta( this.Entidad )
			this.lHabilitarAsignacion = .t.
		else	
			this.lHabilitarAsignacion = .t.
			this.Asignacion = 0
			this.lHabilitarAsignacion = .f.
		endif

		This.HabilitaDesHabilitaReservarNumero()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitaDesHabilitaReservarNumero() as Void
		local lcAtributo as String 
		if empty( this.Atributo )
			lcAtributo = this.oNumeraciones.ObtenerAtributoNumerador( this.Entidad )
		else
			lcAtributo = this.Atributo
		endif 
		if this.oNumeraciones.ObtenerSiPuedeReservar( this.Entidad, lcAtributo  ) 
			this.lHabilitarReservarNumero = .t.
		else
			this.lHabilitarReservarNumero = .t.
			this.ReservarNumero = .f.
			this.lHabilitarReservarNumero = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarEntidad( toDelegado ) as Void
		this.entidad = toDelegado.cnombre
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oNumeraciones_Access() as variant
		if !this.ldestroy and ( !vartype( this.oNumeraciones ) = 'O' or isnull( this.oNumeraciones ) )
			this.oNumeraciones = this.CrearObjeto( 'Numeraciones' )
			this.oNumeraciones.Inicializar()
			this.oNumeraciones.SetearEntidad( this )
		endif
		return this.oNumeraciones
	endfunc

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean

		Local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			this.SetearCodigo()
		endif
		
		if this.EsNuevo() 
			this.ValidarYSetearNumeroInternoCheques()
			this.ValidarYSetearNumeroComprobanteElectronico()
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarYSetearNumeroInternoCheques() as Void
		local loEntidad as Object, lnNumero as Integer, lcEntidadSeleccionada as String, lcPuntoDeVenta as String
		if this.esEntidadDeCheques()
			lcEntidadSeleccionada = upper( alltrim( this.Entidad ) )
			lcPuntoDeVenta = transform( this.PuntoDeVenta )
			lnNumero = this.BuscarUltimoNumeroExistenteParaEntidadSeleccionada( lcEntidadSeleccionada, lcPuntoDeVenta )
			if !empty( lnNumero )
				this.Numero = lnNumero
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarYSetearNumeroComprobanteElectronico() as Void
		local lcXml as String
		lcXml = goServicios.Estructura.ObtenerFuncionalidades()
		
		this.XmlACursor( lcXml, "c_Tags" )
		select c_Tags
		locate for alltrim( upper( entidad )) == alltrim( upper( this.entidad ) )
		if found() and atc( "<CE>", c_Tags.funcionalidades ) > 0 
			this.oColaboradorComprobantesElectronicos.SetearNumeroComprobanteElectronico( this ) 
		endif			
		use in select( "c_Tags" )	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearCodigo() as Void
		local lcTalonario as String 	
		with this
			if !.EsEdicion() and .EsNuevo()
				if empty( .Formula )
				else
					lcTalonario = upper( alltrim( .ArmarTalonario( .Formula ) ) )
					.Codigo = lcTalonario
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarTalonario( tcTalonario as String, toEntidad as entidad of entidad.prg ) as String 
		*** parsea lo que llegue en tcTalonario reemplazandolo por los valores de los atributos de la entidad seteada
		*** cada atributo llega con un # adelante y un @ atras, por ej: "pp" + #presidente@ + #nombre@
		local lcReturn as String, lcAtributo as String , lxValor as string
		
		lcReturn = ""
		lcAtributo = ""
	
		if type( "toEntidad" ) != "O" or isnull( toEntidad )
			toEntidad = this
		endif
		
		if at( "#", tcTalonario ) > 0
			do while at( "#", tcTalonario ) > 0
				lcReturn = lcReturn + left( tcTalonario, at( "#", tcTalonario ) - 1 )
				lcAtributo = substr( tcTalonario, at( "#", tcTalonario ) + 1, at( "@", tcTalonario ) - at( "#", tcTalonario ) - 1 )
				
				lxValor = toEntidad.&lcAtributo
				if empty( lxValor ) and !inlist( upper( alltrim( toEntidad.cNombre)) ,"TICKETFACTURA", "TICKETNOTADECREDITO" )
					lcReturn = "''"
					exit
				else
					lcReturn = lcReturn + " + '" + alltrim( transform( lxValor ) ) + "'"
					tcTalonario = substr( tcTalonario, at( "@", tcTalonario ) + 1 )
				endif
			enddo 
		else
			lcReturn = tcTalonario
		endif 

		lcReturn = alltrim( lcReturn )
		if left( lcReturn, 1 ) = "+"
			lcReturn = substr( lcReturn, 2 )
		endif
		
		return upper( evaluate( lcReturn ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PerteneceAlTalonario( tcAtributo as string, tcTalonario as string ) as boolean
		local llRetorno as Boolean
		
		tcAtributo = upper( alltrim( tcAtributo ) )
		tcTalonario = upper( alltrim( tcTalonario ) )

		llRetorno = at( "#" + tcAtributo + "@", tcTalonario ) > 0
		
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function Validar() As boolean
		Local llRetorno As boolean

		With This
			llRetorno = dodefault()
			if llRetorno
				llRetorno = This.ValidarDelegacionNivel1()
			endif
			if llRetorno
				llRetorno = THis.ValidarDelegacionComprobantesElectronicos()
			endif
			if llRetorno
				llretorno = This.ValidarLetraYPuntoDeVentaEnDelegacion()
			EndIf
			if llRetorno 
				llRetorno = This.ValidarTalonarioRelacion() 
			endif
			if llRetorno 
				llRetorno = This.ValidarDuplicidadDeTalonarioEnCheques() 
			endif
			if llRetorno 
				llRetorno = This.ValidarNumeroMaximo() 
			endif
			
			if this.MaximoNumero>0
				this.InformarTamanioTalonario( this.MaximoNumero - this.Numero )
			endif

			if llRetorno
				if .Numero < 0
					this.AgregarInformacion( "La numeración debe ser mayor que 0" )
					llRetorno = .F.
				endif
			endif
			

		endwith
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarDuplicidadDeTalonarioEnCheques() as Boolean
		local llRetorno as Boolean, lcTalonario as String, lcEntidadSeleccionada as String, lcPuntoDeVenta as String, ;
			lcMensaje as String, lnPuntoDeVentaEnParametros as Integer
			
		llRetorno = .T.
		lcTalonario = ""
		lcEntidadSeleccionada = upper( alltrim( this.Entidad ) )
		lcPuntoDeVenta = transform( this.PuntoDeVenta )
		
		if this.esEntidadDeCheques()
			lnPuntoDeVentaEnParametros = this.ObtenerParametroBocaDeExpendio()
			lcTalonario = this.ObtenerTalonarioDeEntidadSeleccionada( lcEntidadSeleccionada, lcPuntoDeVenta )
			if this.PuntoDeVenta != lnPuntoDeVentaEnParametros and !empty( lcTalonario ) 
				llRetorno = .F.
				lcMensaje = iif( occurs( ",", lcTalonario ) > 0, "Ya existen los talonarios ", "Ya existe el talonario " )
				lcMensaje = lcMensaje + lcTalonario + " para la entidad " + lcEntidadSeleccionada + "."
				This.AgregarInformacion( lcMensaje )
			endif
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTalonarioDeEntidadSeleccionada( tcEntidadSeleccionada as String, tcPuntoDeVenta as String ) as String
		local lcRetorno as Boolean, lcCursor as String, lcTablaPrincipal as String, lcCampoEntidad as String, lcCampoPuntoDeVenta as String, ;
			lcCampoTalonario as String, lcTabla as String, lcSentencia as String, loError as Object, lcTalonarios as String, lcOccurs as Integer 
		
		lcRetorno = ""
		lcTalonarios = ""
		lcCursor = sys(2015)
		with this.oAd
			lcTablaPrincipal = .cTablaPrincipal 
			lcCampoEntidad = .ObtenerCampoEntidad( "ENTIDAD" )
			lcCampoTalonario = .ObtenerCampoEntidad( "CODIGO" )
			lcCampoPuntoDeVenta = .ObtenerCampoEntidad( "PUNTODEVENTA" )
		endwith
        lcTabla = "[" + _Screen.Zoo.App.ObtenerPrefijoDB() + _screen.zoo.app.cSucursalActiva ;
        		+ "].[" + alltrim( _screen.zoo.app.cSchemaDefault ) + "].[" + lcTablaPrincipal + "]"
		lcSentencia = "Select " + lcCampoTalonario + " as Talonario From " + lcTabla + " " ;
					+ "Where " + lcCampoEntidad + " = '" + tcEntidadSeleccionada + "' and " + lcCampoPuntoDeVenta + " <> " + tcPuntoDeVenta + " " ;
					+ "Order by " + lcCampoTalonario
		
		try
			goServicios.Datos.EjecutarSentencias( lcSentencia , lcTablaPrincipal, "", lcCursor, set( "Datasession" ) )
			select &lcCursor  
			scan
				lcTalonarios = lcTalonarios + rtrim( nvl( evaluate( lcCursor + ".Talonario" ), "" ) ) + ", "
			endscan
			
			lcTalonarios = left( lcTalonarios, len( lcTalonarios ) -2 )
			lcOccurs = occurs( ", ", lcTalonarios )
			lcRetorno = strtran( lcTalonarios, ", ", " y ", iif( lcOccurs > 1, lcOccurs, 1 ) )
			
		catch to loError
		finally
			use in select( lcCursor )
		endtry
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function BuscarUltimoNumeroExistenteParaEntidadSeleccionada( tcEntidadSeleccionada as String, tcPuntoDeVenta as String ) as Integer
		return this.oNumeraciones.BuscarUltimoNumeroExistenteEnEntidad( tcEntidadSeleccionada, tcPuntoDeVenta )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarNumeroMaximo() as as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.MaximoNumero > 0 and this.Numero > this.MaximoNumero 
			llRetorno = .F.
			This.AgregarInformacion( "No se puede cargar un talonario con el último número (" + transform(this.Numero)+ ") mayor al máximo (" + transform(this.MaximoNumero)+ ")." )
		Endif
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDelegacionNivel1() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.DelegarNumeracion and This.TalonarioRela.DelegarNumeracion
			llRetorno = .F.
			This.AgregarInformacion( "No se puede delegar a un talonario que está delegado." )
		Endif
		return llRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarLetraYPuntoDeVentaEnDelegacion() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.DelegarNumeracion
			if This.Letra == This.TalonarioRela.Letra and This.PuntoDeVenta = This.TalonarioRela.PuntoDeVenta
			else
				llRetorno = .F.
				This.AgregarInformacion( "Para delegar talonarios deben coincidir los punto de venta y letra." )
			Endif
		Endif
		return llRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarDelegacionComprobantesElectronicos() as boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.DelegarNumeracion
			local lcXml as String
			lcXml = goServicios.Estructura.ObtenerFuncionalidades()
			this.XmlACursor( lcXml, "c_Tags" )
			select c_Tags
			locate for alltrim( upper( entidad )) == alltrim( upper( this.entidad ) )
			if found() and atc( "<CE>", c_Tags.funcionalidades ) > 0
				This.AgregarInformacion( "No se pueden delegar numeraciones en comprobantes electrónicos." )
				llRetorno = .F.
			endif			
			use in select( "c_Tags" )		
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTalonarioDelegado() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		
		if !empty( This.TalonarioRela_PK ) and This.Codigo = This.TalonarioRela_PK
			This.AgregarInformacion( "El talonario cargado para enumerar no debe ser igual al codigo." )
			llRetorno = .F.
		endif

		if empty( this.TalonarioRela_PK )
			This.AgregarInformacion( "Debe cargar un talonario." , 9005, "TalonarioRela" )
			llRetorno = .F.
		endif	

		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarTalonarioRelacion() as Boolean
		local loEnt as ent_talonario of Ent_talonario.prg, llRetorno as Boolean, loColRelacionados as zoocoleccion OF zoocoleccion.prg ,;
				lnClave as Integer
		llRetorno = .T.		

		if this.DelegarNumeracion
			llRetorno = This.ValidarTalonarioDelegado()
			if llRetorno
				loColRelacionados = _screen.zoo.crearobjeto( "zooColeccion" )
					loColRelacionados.agregar( alltrim( upper( this.TalonarioRela_PK ) ), alltrim( upper( this.TalonarioRela_PK ) ) )
					loColRelacionados.agregar( alltrim( upper( this.Codigo ) ), alltrim( upper( this.Codigo ) ) )

				loEnt = _screen.zoo.instanciarentidad( "Talonario" )
				loEnt.codigo = This.talonarioRela_PK

				do while loEnt.DelegarNumeracion and llRetorno
					
					lnClave = loColRelacionados.GetKey( upper( alltrim( loEnt.talonarioRela_PK ) ) ) 
					if empty( lnClave )
							loColRelacionados.agregar( upper( alltrim( loEnt.talonarioRela_PK ) ) , upper( alltrim( loEnt.talonarioRela_PK ) ) )
						loEnt.codigo = loEnt.talonarioRela_PK
					else
						This.AgregarInformacion( "El talonario cargado para enumerar no es válido." )
						llRetorno = .F.
					endif
				enddo
				loEnt.Release()
			endif
		endif 
	
		return llRetorno
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_DelegarNumeracion( txVal as Variant ) as Void
		dodefault( txVal )
		with this
			.lHabilitarNumero = !.DelegarNumeracion
			.lHabilitarTalonariorela_PK = .DelegarNumeracion
			
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTalonario( tcTalonario as String ) as String
		local lcTalonario as String, loEntidad as entidad OF entidad.prg
			with this
				.Codigo = tcTalonario
				if .DelegarNumeracion
					loEntidad = _screen.zoo.instanciarentidad( "talonario" )
					loEntidad.codigo = .TalonarioRela_pk
					do while loEntidad.DelegarNumeracion
						loEntidad.Codigo = loEntidad.TalonarioRela_pk
					enddo
					lcTalonario = loEntidad.Codigo
					loEntidad.release()
				else
					lcTalonario = .Codigo
				endif
			endwith
		return lcTalonario
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSiReservaNumeros() as Boolean

		return this.ReservarNumero
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InformarTamanioTalonario( tnTamanio as Integer ) as Void
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ElectronicoNacional() as object
		return _Screen.zoo.crearobjeto( "ObjetoCae" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ElectronicoExportacion() as object
		return _Screen.zoo.crearobjeto( "FacturacionElectronicaExportacion" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function esEntidadDeCheques() as Boolean
		local llRetorno as Boolean, lcEntidad as String
		lcEntidad = upper( alltrim( this.Entidad ) )
		llRetorno = iif( !empty( lcEntidad ) and inlist( lcEntidad, "CHEQUE", "CHEQUEPROPIO" ), .T., .F. )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function esComprobanteDeVenta( tcEntidad ) as Void
		local llRetorno as Boolean, loComponenteComprobantes as Object, lnNumeroComprobante as Integer, lcComprobantes as string, loColeccion as object, lcComprobante as String, ;
			  lnPiso as integer  
				
		loComponenteComprobantes = _screen.zoo.crearobjeto( "Din_ComponenteComprobante" )
		lnNumeroComprobante = loComponenteComprobantes.ObtenerNumeroComprobante( tcEntidad )
		
		if lnNumeroComprobante > 0
			lcComprobantes = loComponenteComprobantes.oComprobantes["VENTAS"]
			
			lnpiso = 1
			loColeccion = _screen.zoo.crearobjeto( "zoocoleccion" )
			do while at( ",", lcComprobantes ) > 0
				lnsup = at( ",", lcComprobantes )
				lcComprobante = substr( lcComprobantes, 1, lnsup - 1 )
				if alltrim( lcComprobante ) = alltrim( str( lnNumeroComprobante ) )
					llRetorno = .t.
					exit
				endif
				lcComprobantes = substr( lcComprobantes, lnsup + 1 )
			enddo
		endif
			
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidacionTimestamp() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if !this.lEsSubentidad
			llRetorno = dodefault()
		endif 	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerWhereAdicionalParaSentenciaUpdate() as String
		local lcRetorno as String
		lcRetorno = ""
		if !this.lIgnorarFiltroNumero 
			lcRetorno =  ' and "Numero" != ' + transform( this.Numero  )
		endif 
		return lcRetorno
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		function Destroy() as Void
*!*			this.oNumeraciones.Release()
*!*			dodefault()
*!*		endfunc 

enddefine

