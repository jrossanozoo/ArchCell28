**********************************************************************
Define Class zTestSetearEstadoInicialEnRZ as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestSetearEstadoInicialEnRZ of zTestSetearEstadoInicialEnRZ.prg
	#ENDIF
	
	CodDireccion = ""
	
	*---------------------------------
	Function Setup
		this.CodDireccion = CrearDirecciones()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestSqlServerSetearEstadoInicialEnRZ
		Local loEntidad as Object, loError as zooexception OF zooexception.prg, llExisteParam as Boolean,;  
				lcRazonSocial as String, lcEstado as String, loEsquemaComisional as Object ,;
				loZLTIPOUSUARIOZL as Object, loLegajoops as Object, loPais as Object, loProvincia as Object
		
		
		This.agregarmocks( "ZLclienteS,ListaDePrecios,Direcciones,valor,ZLSeries,PRODUCTOZL,Actualizarzoo,EstadoV2" )
		
		llExisteParam = pemstatus( goParametros.Zl.Altas, "vALORINICIALSUGERIDOPARAESTADODELARAZONSOCIAL", 5 )
		
		This.Asserttrue( "No existe el parametro 'VALOR INICIAL SUGERIDO PARA ESTADO DE LA RAZON SOCIAL'", llExisteParam)
		
		lcParamOld = goParametros.Zl.Altas.valorinicialsugeridoparaestadodelarazonsocial

		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN],[*COMODIN],[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. ) && ztestsetearestadoinicialenrz.ztestsetearestadoinicialenrz 20/05/10 09:39:58
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .t., "[*COMODIN]" ) && ztestsetearestadoinicialenrz.ztestsetearestadoinicialenrz 20/05/10 09:44:24


		loZLTIPOUSUARIOZL = _Screen.zoo.instanciarentidad( "ZLTIPOUSUARIOZL" )
		With loZLTIPOUSUARIOZL 
			Try
				.cCod = '1'
				.Eliminar()
			Catch
			Endtry
			Try
				.nuevo()
				.cCod = '1'
				.Descrip = 'desc' + Sys( 2015 )
				.grabar()
			catch				
			Endtry
			.Release()
		Endwith
		loZLTIPOUSUARIOZL = Null		
		
		loLegajoops = _Screen.zoo.instanciarentidad( "Legajoops" )
		With loLegajoops 
			Try
				.Codigo = '1'
				.Eliminar()
			Catch
			Endtry
			Try
				.nuevo()
				.Codigo = '1'
				.Cortesia = 'desc' + Sys( 2015 )
				.tipousuarioZL_pk = '1'
				.UsuarioActivo = .t.
				.grabar()
			catch			
			Endtry
			.Release()
		Endwith
		loLegajoops = Null			
		
		loPais = _screen.zoo.instanciarentidad( "NACIONALIDAD" )
		with loPais
			try
				.Ccod = "00"
				.Eliminar()
			catch
			finally
				.Nuevo()
				.Ccod = "00"
				.Descrip = "00"
				.Grabar()
			endtry
		endwith	

		loProvincia = _screen.zoo.instanciarentidad( "PROVINCIA" )
		with loProvincia
			try
				.Codigo = "00"
				.Eliminar()
			catch
			finally
				.Nuevo()
				.Codigo = "00"
				.Descripcion = "00"
				.Pais_pk = "00"
				.Grabar()
			endtry
		endwith	
		
	
		lcEstRZ = right( sys(2015), 2 )
		goParametros.Zl.Altas.valorinicialsugeridoparaestadodelarazonsocial = lcEstRZ
		loEntidad =  _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "zTestSetearEstadoInicialEnRZ.prg" ) &&	_Screen.Zoo.InstanciarEntidad( "ZLRazonSociales" )
				
		loEsquemaComisional = _screen.zoo.instanciarentidad( "Esquemacomisional" )
		with loEsquemaComisional
			try
				.cCod = 32
				.Eliminar()
			catch
			endtry
			try
				.Nuevo()
				.cCod = 32
				.Descrip = 'Esquema de prueba ' + sys( 2015 )
				.Owner_Pk = '1'
				.Grabar()
			catch
			endtry
		endwith
		loEsquemacomisional.Release()
		loEsquemacomisional = null		

		with loEntidad
			.Nuevo()
			lcCodRZ = .codigo
			.Descripcion = "RazonSocial " + lcCodRZ
			.Cliente_Pk = "99999"
			.SituacionFiscal_pk = 1
			.Cuit = "30-12345678-1"
			.ListaDePrecios_Pk = "999999"
			.Direcc_Pk = "99999"
			.FormaDePago_Pk = "9999"
			.VersionSistema = 3.25
			.direcc_pk = this.CodDireccion
			.reGIMENCOMISION = 32			
			.Direccion = "Direccion de prueba"
			.Provincia_pk = "00"
			.Grabar()
			.Release()
		endwith
		
	
		loEntidad = _Screen.Zoo.InstanciarEntidad( "ZLASIGESTADOSRZADM" )
		loEntidad.Ultimo()
		lcRazonSocial = loEntidad.RazonSocial_PK
		lcEstado = loEntidad.EstadoRZ_PK

		This.Assertequals( "No se grabo correctamente la RZ en la entidad de Cambio de estados", lcCodRZ, lcRazonSocial  )
		This.Assertequals( "No se grabo correctamente el estado inicial de la RZ en la entidad de Cambio de estados", lcEstRZ, lcEstado )				
	
		loEntidad.Release()
		loPais.Release()
		loProvincia.Release()

		loEntidad =  _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "zTestSetearEstadoInicialEnRZ.prg" )  &&_Screen.Zoo.InstanciarEntidad( "ZLRazonSociales" )

		goParametros.Zl.Altas.valorinicialsugeridoparaestadodelarazonsocial = lcParamOld
			
	Endfunc

	
	*---------------------------------
	Function TearDown

	EndFunc

EndDefine



*-----------------------------------------------------------------------------------------
function CrearDirecciones
	local loent as Object, loerror as Object, lcCodRetorno as String, loent1 as Object , loent2 as Object, loent3 as Object

	lcCodRetorno = ''
	
	loent = _Screen.zoo.instanciarentidad( 'PROVINCIA' )

	with loent
		try 
			.codigo = '01'
			.Eliminar()
		catch to loError	
		endtry 
			
		try 
			.NUEVO()
			.codigo = '01'
			.Descripcion = 'BA'
			.grabar()
		catch to loError	
		finally 
			.Release()
		endtry 	
	endwith 
	
	loent = null
	loent1 = _Screen.zoo.instanciarentidad( 'TIPODIRECCIONES' )	

	with loent1
	
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = '01'
			.Descrip = 'Tipo 1'
			.grabar()
		catch to loError
		finally 
			.Release()
		endtry 			
	endwith 	
	loent1 = null
	loent2 = _Screen.zoo.instanciarentidad( 'NACIONALIDAD' )

	with loent2
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = 'AR'
			.Descrip = 'Aryentain'
			.grabar()
		catch to loError
		finally 
			.Release()
		endtry 				
	endwith 	

	loent2 = null
	loent3 = _Screen.zoo.instanciarentidad( 'DIRECCIONESALTAS' )
	
	with loent3	
		try 
			.nuevo()
			.Calle = 'LA CALLE'
			.Provincia_PK ='01'
			.TIPO_PK = '01'
			.Pais_pk = 'AR'
			.Grabar()
		catch to loError
		finally
			.Ultimo()
			lcCodRetorno = .Codigo
			.Release()
		endtry 	
			
	endwith 

	loent3 = null

	return lcCodRetorno
	
endfunc 

*------------------------------------------------------------------------------
define class ZLRazonSociales_Aux as Ent_ZLRazonSociales of Ent_ZLRazonSociales.prg

	*-----------------------------------------------------------------------------------------
	function ValidarPermisoAsignacionTipoRazonSocial()
		return .t.
	endfunc 
	*--------------------------------------------------------------------------------------------------------
	function Validar_Regimencomision( txVal as variant ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarEsquemaActivo( txVal ) as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosAFIP() as Void
		this.Direccion = "Direccion de prueba"
		this.Localidad = ""
		this.Provincia_pk = "00"
		this.CodigoPostal = ""
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------

Function CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
		(	
			
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			select 
					E.Ccod as Esquema ,
					CLIENTE  as Cliente ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
					e.dueno as Duenio
				from ZL.esqcom E
				left join (select Cliente, CREGIMEN from zl.ASESCOMCLI 
								where NUMERO in ( select max(numero)
									from zl.ASESCOMCLI
									group by   CLIENTE
												)      
							) as ASESCOMCLI on e.ccod = ASESCOMCLI.CREGIMEN 
				join ZL.Legops l on l.ccod = e.dueno 
				
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

