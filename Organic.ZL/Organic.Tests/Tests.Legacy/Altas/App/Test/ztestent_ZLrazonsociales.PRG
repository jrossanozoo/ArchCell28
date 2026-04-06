define class zTestEnt_ZLrazonsociales as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestEnt_ZLrazonsociales of zTestEnt_ZLrazonsociales.prg
	#endif

	CodDireccion = ""
	
	*-----------------------------------------------------------------------------------------
	function setup
		this.CodDireccion = CrearDirecciones()
		CrearFuncion_FuncObtenerTipoUsuarioZLAD()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSqlServerZLRazonSociales
		local loEntidad as Object, lcMensaje as String, loEsquemaComisional as Object, loPais as Object, loProvincia as Object

		toEntidad = newobject( "objEntidad" ) 

		this.Agregarmocks( "ZLClientes, ListaDePrecios, Direcciones, Valor, EstadoV2, ZLAsigEstadosRZAdm" )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Nuevo', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Grabar', .T. )

		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerInformacion],[inyectarInformacion]" )
		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'razonsocial_access', toEntidad )

		loEsquemaComisional = _Screen.zoo.instanciarentidad( "Esquemacomisional" )
		With loEsquemaComisional
			Try
				.cCod = 32
				.Eliminar()
			Catch
			Endtry
			Try
				.nuevo()
				.cCod = 32
				.Descrip = 'Esquema de prueba ' + Sys( 2015 )
				.grabar()
			catch				
			Endtry
		Endwith
		loEsquemaComisional.Release()
		loEsquemaComisional = Null

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

		loPais.Release()
		loProvincia.Release()

		loEntidad= _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "zTestEnt_ZLrazonsociales.prg" ) 
		
		goParametros.Zl.Altas.ValorInicialSugeridoParaEstadoDeLaRazonSocial = "01"

		with loEntidad
			try
				.Nuevo()
				.Descripcion = "Prueba"
				.cuit = '11111111113'
				.SituacionFiscal_pk = 3
				.Cliente_pk = "1"
				.ListaDePrecios_pk = "1"
				.Direcc_pk = "1"
				.FormaDePago_pk = "PESOS"
				.direcc_pk = this.CodDireccion
				.reGIMENCOMISION = 32
				.NroDocumento = 20222333				
				.Direccion = "Direccion de prueba"
				.Provincia_pk = "00"
				.Grabar()
			catch to loError
			assert .f. message "Mensaje" &&cpolimeni
				this.asserttrue( "Debería haber grabado", .f. )
			endtry

			try
				.Nuevo()
				.Descripcion = "Prueba"
				.SituacionFiscal_pk = 1
				.Cliente_pk = "1"
				.ListaDePrecios_pk = "1"
				.Direcc_pk = "1"
				.FormaDePago_pk = "PESOS"
				.direcc_pk = this.CodDireccion
				.reGIMENCOMISION = 32					
				.Direccion = "Direccion de prueba"
				.Provincia_pk = "00"
				.Grabar()
			catch to loError
				this.asserttrue( "No debería haber grabado", .t. )
				lcMensaje = loError.UserValue.oInformacion.Item[1].cMensaje
				this.assertequals( "Debería haber pinchado", "Debe cargar el campo CUIT", lcMensaje )
			finally
				.Release()
			endtry
		endwith
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class objEntidad as Entidad of Entidad.prg 
	*-----------------------------------------------------------------------------------------
	function SoportaBusquedaExtendida() as Void
		return .f.
	endfunc 

enddefine

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
Function CrearFuncion_FuncObtenerTipoUsuarioZLAD
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncObtenerTipoUsuarioZLAD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[FuncObtenerTipoUsuarioZLAD]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE function [ZL].[FuncObtenerTipoUsuarioZLAD]
		( 
			@UsuarioZL Varchar(100) 
		)
		returns Varchar(7)
		as
		begin
			declare @ret Varchar(4);
			
					select @ret = L.Tipousu 
						from  ZL.DUsrZLAD D
						JOIN ZL.Legops L on upper(D.codusu) = L.ccod
						where upper(D.USUAD) = upper( @UsuarioZL )
			
			return ISNULL(@ret, '' )
		end
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

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
