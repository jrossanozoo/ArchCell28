define class ManagerWebHook as Servicio of Servicio.Prg
	
	#IF .f.
		Local this as ManagerWebHook of ManagerWebHook.prg
	#ENDIF

	protected oNetWebHook 
	hidden oNetPadronAFIPWS 
	oNetWebHook = null
		
	*--------------------------------------------------------------------------------------------------------
	function oNetWebHook_Access() as variant
		if !this.lDestroy and ( !vartype( this.oNetWebHook) = 'O' or isnull( this.oNetWebHook ) )
			this.oNetWebHook = this.ObtenerComponenteWH()
			this.CargarWebHooksDeBase(alltrim(upper(_screen.zoo.app.csucurSALACTIVA)))
		endif
		return this.oNetWebHook
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponenteWH() as Object
		loFactory = _Screen.Zoo.CrearObjeto( "ZooLogicSA.ManagerWebHook.FactoryWebHook" )
		return loFactory.ObtenerWH( addbs(_screen.zoo.crutainicial) + "Log\WebHook.log" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Enviar( toEntidad as Object, tcEvento as string) as void
		lcObtenerCodigo = "toEntidad." + toEntidad.ObtenerAtributoClavePrimaria()
		lcCodigo = &lcObtenerCodigo
		this.oNetWebHook.PostearWH( alltrim( toEntidad.cNombre ), rtrim( lcCodigo ), tcEvento )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarPorSentencias( tcEntidad as String, tcCodigo as String, tcEvento as String ) as Void
		this.oNetWebHook.PostearWH( alltrim( tcEntidad ), rtrim (tcCodigo ), tcEvento )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarPrueba( toEntidad as Object) as string
		local lcResultado as String
		
		lcResultado = this.oNetWebHook.PostearPrueba( toEntidad.url, toEntidad.codigo )		
		
		return lcResultado
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCursorWHDeUnaBase( tcBase as String ) as String
		local lcConsulta as String, lcTabla as String, lcCursor as String, lcEntidad as String, lcBase as String

		lcBase = alltrim( tcBase )
		lcConsulta = "SELECT whook.url, whookdet.ENTIDAD, whookdet.ingresar, whookdet.eliminar, whookdet.modificar FROM ORGANIZACION.WHOOKDET " + ;
					"INNER JOIN organizacion.WHOOK ON whook.codigo = whookdet.codigo  where Basedatos = '" + ;
					lcBase + "' "
		lcCursor = sys( 2015 )
		goServicios.Datos.EjecutarSentencias( lcConsulta, "WebHook", "", lcCursor, this.DataSessionId )
		return lcCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarWebHooksDeBase( tcBaseDeDatos as String ) as void
		local loSaltosDeCampoYValoresSugeridosDeEntidad as zoocoleccion OF zoocoleccion.prg, lcCursorSaltosDeCampoYValoresSugeridos as String, loSaltoDeCampoYValorSugerido as Object,;
				lcClave as String, lcCursor as String
		try
			lcConnString = goServicios.datos.oManagerConexionASql.ObtenerCadenaConexionNet()
			this.oNetWebHook.SetearAccesoDatos( lcConnString )
			loLista = this.oNetWebHook.ObtenerLista()
			lcCursor = this.ObtenerCursorWHDeUnaBase( tcBaseDeDatos )
			scan 
				scatter name loWH
				loLista.Agregar(alltrim(loWH.entidad),alltrim( loWH.url), loWH.ingresar, loWH.modificar, loWH.eliminar)
				if inlist(alltrim(loWH.Entidad),"FACTURA", "NOTADECREDITO", "NOTADEDEBITO")
					loLista.Agregar(alltrim("TICKET"+alltrim(loWH.entidad)),alltrim( loWH.url), loWH.ingresar, loWH.modificar, loWH.eliminar)
					loLista.Agregar(alltrim(alltrim(loWH.entidad)+"ELECTRONICA"),alltrim( loWH.url), loWH.ingresar, loWH.modificar, loWH.eliminar)
					loLista.Agregar(alltrim(alltrim(loWH.entidad)+"ELECTRONICAEXPORTACION"),alltrim( loWH.url), loWH.ingresar, loWH.modificar, loWH.eliminar)
					loLista.Agregar(alltrim(alltrim(loWH.entidad)+"ELECTRONICADECREDITO"),alltrim( loWH.url), loWH.ingresar, loWH.modificar, loWH.eliminar)
					loLista.Agregar(alltrim(alltrim(loWH.entidad)+"AGRUPADA"),alltrim( loWH.url), loWH.ingresar, loWH.modificar, loWH.eliminar)
				endif
			endscan

			this.oNetWebHook.ObtenerHooks( loLista, tcBaseDeDatos )
		catch to loError
		
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarMensajeALaCola( tcEvento as string, toRegistro as object, tcEntidad as string) as void
		this.oNetWebHook.AgregarMensajeALaCola( tcEvento, toRegistro, tcEntidad )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarColaDeMensajes( tcEntidad as String) as void
		this.oNetWebHook.EnviarColaDeMensajes( tcEntidad )
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function TieneQueMandar( tcEntidad as String, tcEvento as string ) as Boolean
		return this.oNetWebHook.TieneQueMandar( tcEntidad, tcEvento )
	endfunc

enddefine 	




