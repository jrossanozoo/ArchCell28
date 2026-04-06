define class ColaboradorZLaAPIPantera as zoosession of zoosession.prg
	
	oEntidad =  null 
	oDataRest = null
	EMailAdministradorParaAltaDeTenant = ""

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidad = toEntidad
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oDataRest_Access() as Variant
		if !this.ldestroy and ( vartype( this.oDataRest	) != 'O' or isnull( this.oDataRest ) )
			this.oDataRest = this.ObtenerClaseDataRest()
		endif
		return this.oDataRest
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClaseDataRest() as Object
		_Screen.Zoo.AgregarReferencia( "ZooLogicSA.ZLaPantera.dll" )
		return _Screen.Zoo.CrearObjeto( "ZooLogicSA.ZLaPantera.DataRest" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearTenant() as void 
		local  resultado as String, loTenant as Object, lctenancyName as String, lcadminEmailAddress as String, lcname as String  
		 
		application.AutoYield = .t.
		goServicios.Mensajes.EnviarSinEsperaProcesando( "Creando Tenant en Pantera Comercios..." )
		
		lcname = strtran(alltrim( this.oEntidad.Razonsocial.Descripcion ),' ', '_')
		lctenancyName = lcname + '_'+	alltrim(this.oEntidad.Razonsocial_pk) 
		lcadminEmailAddress = alltrim(this.EMailAdministradorParaAltaDeTenant )	
	
		with this.oDataRest
			with .ZLTenant 
				.name = lcname 
				.tenancyName = lctenancyName 
				.editionId = 1
				.editionDisplayName = "Free"
				.isActive =  .t.
				.shouldChangePasswordOnNextLogin = .t.
				.sendActivationEmail = .t.
				.isInTrialPeriod = .f.
				.adminEmailAddress =  lcadminEmailAddress 
			endwith 	
        	resultado = .CrearTenant()
		endwith 
		
		if resultado = "OK"
		   	this.VincularTenantAZLClientes( lctenancyName )		
    	endif
    	
		goServicios.Mensajes.EnviarSinEsperaProcesando()
		application.AutoYield = .F.

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarEstadoTenant( tcCliente as String ) as void 
		local idTenant as integer, lcSQL as String, lcCursor as String, loError as object  

		text to lcSql  textmerge noshow 
			select IDTenant from ZL.DeTenantCli  
			where ZLCliente = '<<alltrim(tcCliente)>>'
		endtext 
		goDatos.EjecutarSQL( lcSql , "", this.DataSessionId )
		if used( lcCursor ) and reccount( lcCursor ) > 0 
	
			application.AutoYield = .t.
			
			goServicios.Mensajes.EnviarSinEsperaProcesando( "Actualizando Tenants en Pantera Comercios..." )
			
			*this.oDataRest.ActualizarEstadoDeUnTenant(idTenant)
			goServicios.Mensajes.EnviarSinEsperaProcesando()
			application.AutoYield = .F.
		endif 
		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VincularTenantAZLClientes( TenancyName as String ) as Void
		local idTenant as integer, lcSQL as String, lcCursor as String, loError as object
		idTenant = this.oDataRest.ObtenerIDTenant(TenancyName)
		try
			text to lcSql  textmerge noshow 
				insert into ZL.TENANTSPANTERA(TnName, IDTenant) values ('<<TenancyName>>', <<transform(idTenant)>>)
				insert into ZL.DETENANTCLI (IDTenant, ZLCliente) values (<<transform(idTenant)>>, '<<alltrim(this.oEntidad.Cliente_pk)>>')
			endtext 
			goDatos.EjecutarSQL( lcSql , "", this.DataSessionId )
		catch to loError
			*goServicios.Errores.LevantarExcepcion( loError )
		endtry 
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CrearReferenceCode() as Void
		local  resultado as String, lcDescription as String, lcname as String  
		 
		application.AutoYield = .t.
		goServicios.Mensajes.EnviarSinEsperaProcesando( "Creando ReferenceCode en Pantera Comercios..." )
		
		lcname = alltrim( this.oEntidad.Codigo )
		lcDescription  = alltrim(this.oEntidad.Descripcion ) 
        *int ReferenceCodeStateType { get; set; } 
	
		with this.oDataRest
			with .ZLReferenceCode.Dto
				.Name = lcname 
				.Description = lcDescription  
			endwith 	
        	resultado = this.oDataRest.CrearReferenceCode()
			if resultado = "OK"
				this.oEntidad.IDPantera  = .ZLReferenceCode.Dto.Id 
	    	endif
    	endwith 
		goServicios.Mensajes.EnviarSinEsperaProcesando()
		application.AutoYield = .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActivarDesactivarReferenceCode( tcAccion as String ) as Void
		local  resultado as String, lnAccion AS Integer 
		application.AutoYield = .t.
		goServicios.Mensajes.EnviarSinEsperaProcesando( tcAccion + " ReferenceCode en Pantera Comercios..." )
		lnAccion = iif(upper( tcAccion )='ACTIVAR', 1, 2 )
		this.oDataRest.ZLReferenceCodeCambiarEstado.Id = alltrim( this.oEntidad.IDPantera )
		this.oDataRest.ZLReferenceCodeCambiarEstado.ReferenceCodeStateType = lnAccion 
    	resultado = this.oDataRest.CambiarEstadoReferenceCode()
		goServicios.Mensajes.EnviarSinEsperaProcesando()
		application.AutoYield = .F.
		if resultado = "OK"
	    endif
	endfunc 

enddefine
