define class ControlBasesDeDatos as ZooSession of ZooSession.prg

	#IF .f.
		Local this as ControlBasesDeDatos of ControlBasesDeDatos.prg
	#ENDIF

	oGestorNet = null
	oVersionAplicacion = null
		
	*-----------------------------------------------------------------------------------------
	function oGestorNet_Access() as Void
		if !this.ldestroy and ( !vartype( this.oGestorNet ) = 'O' or isnull( this.oGestorNet ) )
			
			local loFactoryNet as Object, loAdnImplant as Object, loParametrosNet as Object
			
			loFactoryNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )  

			loAdnImplant = _screen.zoo.crearobjeto( "AdnImplant" )
			loParametrosNet = loAdnImplant.ObtenerObjetoParametros()
			loParametrosNet.AgregarBDAProcesar( _screen.zoo.app.cSucursalActiva, .t. )
			loParametrosNet.EjecutarSilencioso = .t.

			this.oGestorNet = loFactoryNet.ObtenerGestorBD( loParametrosNet )
		endif
		return this.oGestorNet
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oVersionAplicacion_Access() as Void
		if !this.ldestroy and ( !vartype( this.oVersionAplicacion ) = 'O' or isnull( this.oVersionAplicacion ) )
			this.oVersionAplicacion = this.ObtenerVersionAplicacion()
		endif
		return this.oVersionAplicacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		this.lDestroy = .t.
		
		this.oGestorNet = null
		this.oVersionAplicacion = null
		
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ControlarBasesDeDatos( tcBaseDeDatosoAgrupamiento as String ) as ResultadoVerificacion of ControlBasesDeDatos.prg
		local lcNombreBases as String, loRetorno as Object, lnRespuestaDialogo as Integer, loAdnImplant as Object, llRespuestaADNImplant as Boolean
		
		loRetorno = _screen.zoo.crearobjeto( "ResultadoVerificacion", "ControlBasesDeDatos.prg" )
		
		*!* apagado hasta que se decida incorporar
		if .t.
			loRetorno.lHabilitadoContinuar = .t.
		else
			lcNombreBases = this.ObtenerBasesDeDatosQueRequierenAdecuar( tcBaseDeDatosoAgrupamiento )
			
			if !empty( lcNombreBases )
				
				lnRespuestaDialogo = this.PreguntarComportamiento( lcNombreBases  )
							
				do case
					case lnRespuestaDialogo = 6 && SI
						loAdnImplant = _screen.zoo.crearobjeto( "AdnImplant" )
						llRespuestaADNImplant = loAdnImplant.EjecutarAdnImplantV2( 0, lcNombreBases , .t. ) && Ejecuta adnimplant 

						loRetorno.lHabilitadoContinuar = llRespuestaADNImplant 

						if !llRespuestaADNImplant 
							loRetorno.cMotivo = "Se produjo un error al ejecutar ADN Implant. Verifique los logs del sistema."
						endif
						
					case lnRespuestaDialogo = 7 && NO
						loRetorno.lHabilitadoContinuar = .t.
					case lnRespuestaDialogo = 2 && CANCELAR
						loRetorno.lHabilitadoContinuar = .f.
						loRetorno.cMotivo = "Cancelado por el usuario."
				endcase
			else
				loRetorno.lHabilitadoContinuar = .t.
			endif	
		endif	
		
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerBasesDeDatosQueRequierenAdecuar( tcBaseDeDatosoAgrupamiento as String ) as String
		local loDataConfigIni as Object, lcCadena as String, loAdministradorBD as Object, loInfo as Object,;
				lcNombreBases as String, lcListaDeBasesAdecuar as String, loVersionApliacion as Object, lnI as Integer, loItem as Object
		
		loDataConfigIni = _screen.zoo.crearobjeto( "ZooLogicSA.Core.DatosAplicacion.DataConfigIni",, addbs(_screen.zoo.app.cRutaDataConfig ) )
		lcCadena = loDataConfigIni.GenerarCadenaConexion( goServicios.librerias.ObtenerNombreSucursal( _screen.zoo.app.cSucursalActiva ) )
		loAdministradorBD = _screen.zoo.crearobjeto( "ZooLogicSA.Core.BasesDeDatos.AdministradorBD",, lcCadena )

		loInfo = this.oGestorNet.ObtenerInformacionBasesDeDatos( loAdministradorBD, goLibrerias.ObtenerBasesDeDatos( tcBaseDeDatosoAgrupamiento ), _screen.zoo.app.ObtenerPrefijoDB() )

		lcNombreBases = ""
		lcListaDeBasesAdecuar = ""
		
		for lnI = 0 to loInfo.Count - 1
			loItem = loInfo.Item[lnI]
			if loItem .Existe and !this.oVersionAplicacion.Equals( loItem.Version )
				lcNombreBases =  lcNombreBases + chr(13)+chr(10) + loItem .Nombre
				lcListaDeBasesAdecuar = lcListaDeBasesAdecuar + iif( !empty(lcListaDeBasesAdecuar ), "," , "" ) + loItem.Nombre
			endif
		endfor
		
		return lcListaDeBasesAdecuar 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVersionAplicacion() as Object
		local loRetorno as Object, loXml as Object, lcVersion as String
		
		if _screen.zoo.app.lDesarrollo
			loXml = _screen.zoo.crearobjeto( "System.Xml.XmlDocument" )
			loXml.load( addbs( _screen.Zoo.cRutaInicial ) + "Generados\din_estructuraadn.xml" )
			lcVersion = loXml.SelectSingleNode("EstructuraAdn/Version/Version").innerXML
			loRetorno = _Screen.zoo.CrearObjeto( "ZooLogicSA.Core.Aplicacion.VersionOrganic", , lcVersion  )
		else
			loRetorno = _screen.zoo.app.oVersion
			*loRetorno = _Screen.zoo.CrearObjeto( "ZooLogicSA.Core.Aplicacion.VersionOrganic", , _screen.zoo.app.oVersion )
		endif
		
		return loRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarComportamiento( tcNombreBases as String ) as Integer
		local lcMensaje as String, lnRespuestaDialogo as Integer 

		if !_Screen.Zoo.UsaCapaDePresentacion()
			lnRetorno = 6
		else
			text to lcMensaje textmerge noshow
Las siguientes bases de datos tienen una version de estructura diferente a la de la aplicacion.

<<tcNombreBases>>

SI: Ejecutar ADN Implant para intentar adecuarlas y continuar.
NO: Continuar sin adecuar.
CANCELAR: No continuar con el proceso.
			endtext

			lnRetorno = goServicios.Mensajes.Enviar( lcMensaje, 3 )
		endif
		
		return lnRetorno
	endfunc 
	
enddefine

define class ResultadoVerificacion as custom
	lHabilitadoContinuar = .f.
	cMotivo = ""
enddefine
