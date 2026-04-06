**********************************************************************
DEFINE CLASS ztestSQLServerEntidadzlcmpclascliente as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		LOCAL THIS AS ztestSQLServerEntidadzlcmpclascliente OF ztestSQLServerEntidadzlcmpclascliente.PRG
	#ENDIF
	
	CodDireccion = ""
	*---------------------------------
	Function Setup

		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerInstanciarEntidad
		local loError as Exception, loEntidad as Object
		
		try
			loEntidad = _Screen.zoo.instanciarentidad( "ZLCMPCLASCLIENTE" )
			loEntidad.Release()
		catch to loError
			this.asserttrue( 'No Deberia haber dado error al instanciar ZLCMPCLASCLIENTE.', .f. )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerGrabar
		local loError as Exception, loClasificaciones as Object, loCliente as Object, loCMPClas as Object, lcCodigoCli as string, loTalonario as Object

		this.CodDireccion = CrearDirecciones()
		this.agregarmocks("LEGAJOOPS")
		
		******************************** ALTA DE CLASIFICACION ************************
		loClasificaciones = _Screen.zoo.instanciarentidad( "CLASIFICACIONV2" )
		with loClasificaciones
			try
				.Codigo = "01"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "01"		
			.Nombre = "Grandes Clientes"
			.Grabar()

			try
				.Codigo = "02"
				.Eliminar()
			catch
			endtry
			.Nuevo()
			.Codigo = "02"		
			.Nombre = "Exportadores"
			.Grabar()

			.Release()
		endwith
		local lcBKPCLASIFICACION as string
		lcBKPCLASIFICACION = goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes
		goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes = "01"

		local loClasificacionv2 as Object
		loClasificacionv2 = _screen.zoo.instanciarentidad( "Clasificacionv2" )
		with loClasificacionv2
			try
				.Codigo = '37'
				.Eliminar()
			catch
			finally
				.Nuevo()
				.Codigo = '37'
				.Nombre = 'Clasificacion 37'
				.Grabar()
			endtry 
		endwith
		loClasificacionv2.release()
		
		******************************** ALTA DE CLIENTE ************************
		loCliente = _Screen.zoo.instanciarentidad( "ZLClientes" )
		with loCliente
			try
				.Nuevo()
				lcCodigoCli = .Codigo
				.direcc_pk = this.CodDireccion
				.Grabar()
				.Codigo = lcCodigoCli
				this.assertequals( 'No se creo la clasificacion DEFAULT.', 2 , .DetalleClasificaciones.Count )				
				.Release()
			catch to loError
				this.asserttrue( 'no Deberia haber dado error al dar de alta el cliente.', .f. )
			endtry
		endwith
		
		loCMPClas = _Screen.zoo.instanciarentidad( "ZLCMPCLASCLIENTE" )
		loCMPClas.Ultimo()
		local lnUltimaCMPClasificacion as Integer
		lnUltimaCMPClasificacion = loCMPClas.Codigo
		
		
		loTalonario = _screen.zoo.instanciarentidad( "Talonario" )
		with loTalonario
			try
				.Codigo = "ZLCLASIFICACIONCLIENTES"
			catch to loError
				.nuevo()
				.Codigo = "ZLCLASIFICACIONCLIENTES"
				.Numero = lnUltimaCMPClasificacion + 1
				.Grabar()
			finally
				.release()
			endtry
		endwith

		with loCMPClas
			try
				.Nuevo()
				.FKClie_PK = lcCodigoCli
				.Registrado_pk = 'ADMIN'
				with .DetalleClasificaciones

					this.assertequals( 'La Cant de Clasificaciones deberia ser 1 (Clasificacion DEFAULT).', 2 , .Count )

					.LimpiarItem()
					.oitem.CodClasifi_pk = '02'
					.Actualizar()
					this.assertequals( 'La Cant de Clasificaciones deberia ser 2 (Clasificacion Nueva + DEFAULT).', 3 , .Count )

				endwith
				.Grabar()

			catch to loError
				this.asserttrue( 'No Deberia haber dado error al setear las clasificaciones del cliente.', .f. )
			endtry		
			.Release()
		endwith

		
		loCliente = _Screen.zoo.instanciarentidad( "ZLClientes" )
		with loCliente
			.Codigo = lcCodigoCli
			this.assertequals( 'La Cant de Clasificaciones deberia ser 3', 3 , .DetalleClasificaciones.Count )
			.Release()
		endwith
		goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes = lcBKPCLASIFICACION
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
Endfunc