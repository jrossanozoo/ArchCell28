DEFINE CLASS zTestSQLServerEntidadgrupocomunicacion as FxuTestCase OF FxuTestCase.prg
	#If .F.
		Local This As zTestSQLServerentidadZLSERVICIOSLOTE Of zTestSQLServerentidadZLSERVICIOSLOTE.prg
	#Endif
	
	CodDireccion = ""
	
		*-----------------------------------------------------------------------------------------
	function Setup
		this.CodDireccion = CrearDirecciones()
		CrearFuncion_func_NormalizarNombre()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerArmarCodigo
		local loEntidad as entidad OF entidad.prg, loUsos as entidad OF entidad.prg, loCliente as entidad OF entidad.prg, lcCliente1 as String,;
			lcCliente1 as String, lcCliente2 as String
		
		This.agregarmocks( "Actualizarzoo,Direcciones" )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. ) && zTestSQLServerentidadgrupocomunicacion.zTestSQLServerarmarcodigo 21/10/09 11:28:06
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarclientes', .T., "[*COMODIN],[*COMODIN]" ) && zTestSQLServerentidadgrupocomunicacion.zTestSQLServerarmarcodigo 21/10/09 11:28:06
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )		
		
		loEntidad = _screen.zoo.instanciarentidad( "grupocomunicacion" )
		loUsos 	  = _screen.zoo.instanciarentidad( "usov2" )
		loCliente = _screen.zoo.instanciarentidad( "zlclientes" )

		with loUsos
			try 
				.Codigo = "U1" 
				.Eliminar()
			catch to loError
			endtry

			.Nuevo()
			.Codigo = "U1" 
			.Nombre = "DESCRIPCIÓNUSO" 
			.Grabar()
		endwith

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

		with loCliente
			.Nuevo()
			lcCliente1 = .codigo
			.Nombre = "DESCRIPCIONCTE1" 
			.direcc_pk = this.CodDireccion
			.Grabar()

			.Nuevo()
			lcCliente2 = .codigo
			.Nombre = "DESCRIPCIONCTE2" 
			.direcc_pk = this.CodDireccion
			.Grabar()
			
			.Nuevo()
			lcCliente3 = .codigo
			.Nombre = "DESCRIPCIONCTE3" 
			.direcc_pk = this.CodDireccion			
			.Grabar()
		endwith

		with loEntidad
			.nuevo()

			.usos_pk = "U1"

			.grupoCLIENTES.oiTEM.coDCLI_PK = lcCliente1
			This.assertequals( "No armo correctamente el codigo(1).", lcCliente1, .codcli )

			.grupoCLIENTES.oiTEM.coDCLI_PK = lcCliente2
			This.assertequals( "No armo correctamente el codigo(2).", lcCliente1 + '/' + lcCliente2, .codcli )

			This.assertequals( "La descripcion del cliente no es correcta.", "Descripcioncte2", alltrim( loentidad.grUPOCLIENTES.oitem.nombre ) )
			.Grabar()

			.Modificar()
			.grupoCLIENTES.LimpiarItem
			.grupoCLIENTES.oiTEM.coDCLI_PK = lcCliente3
			This.assertequals( "No armo correctamente el codigo al modificar.", lcCliente1 + '/' + lcCliente2 + '/' + lcCliente3, .codcli )

			.Release
		endwith
		
		loUsos.release()
		loCliente.release()
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
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSQL( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[func_NormalizarNombre]
				(@Texto varchar(max))
			RETURNS VARCHAR(MAX) AS
			BEGIN

				declare @Text varchar(max) = ltrim(rtrim((case when @Texto is null then '' else lower(replace(@Texto, '.', '')) end)))
				while charindex('  ', @Text) > 0
					begin
						set @Text = replace(@Text, '  ', ' ')
					end
				declare @LastTextIndex int = (select charindex(' ', reverse(@Text))), @LastText varchar(max) = ''
				declare @New varchar(max) = ''
				declare @Index int = 1, @Len int = len(@Text)

				while (@Index <= @Len)
					begin
						if (substring(@Text, @Index, 1) like '[^a-z]' and @Index + 1 <= @Len)
							begin
								select @New = @New + upper(substring(@Text, @Index, 2)), @Index = @Index + 2
							end
						else
							begin
								select @New = @New + substring(@Text, @Index, 1), @Index = @Index + 1
							end
					end

				set @New = (upper(left(@New, 1)) + right(@New, abs(@Len - 1)))
				set @LastText = right(lower(@New), abs(@Len - (@Len - @LastTextIndex + 1)))
				set @New =
					case
						when @LastText = 'sa' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.'
						when @LastText = 'srl' then left(@New, @Len - @LastTextIndex + 1) + 'S.R.L.'
						when @LastText = 'sas' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.S.'
						else @New
					end

				return ltrim(rtrim(@New))

			END
		endtext
		
		goServicios.Datos.EjecutarSQL( lcSQL )

endfunc
