**********************************************************************
Define Class ztestSQLServerKontrolerRazonSocialV2 as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestSQLServerKontrolerRazonSocialV2 of ztestSQLServerKontrolerRazonSocialV2.prg
	#ENDIF
	
	CodDireccion = ""

	function Setup
		this.CodDireccion = CrearDirecciones()
		CrearFuncion_func_NormalizarNombre()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerAsignarFiltroClienteADireccion
		local loRazonSocial as Object, loCliente As Object, loDireccion as Object, lcValorFiltro As String, loEntidad as Din_EntidadzlCLientes of Din_EntidadzlCLientes.prg,;
			lcCodigo1 as String, lcCodigo2 as String

		_screen.mocks.agregarmock( "ActualizarzOO" )	
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarclientes', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )		

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

		loEntidad = _Screen.zoo.instanciarEntidad( "zlCLientes" )
		with loEntidad
			.Nuevo()
			lcCodigo1 = .codigo
			.Nombre = lcCodigo1
			.direcc_pk = this.CodDireccion
			.Grabar()
			.Nuevo()
			lcCodigo2 = .codigo
			.Nombre = lcCodigo2
			.direcc_pk = this.CodDireccion
			.Grabar()
			.Release()		
		EndWith			

		loRazonSocial  = goformularios.procesar( 'RazonSocialV2' )
		loDireccion = loRazonSocial.oKontroler.obtenerControl( "Direcciones" )

		loDireccion.cFiltroBusqueda = ""
		loRazonSocial.oEntidad.Cliente_PK = lcCodigo1
		lcValorFiltro = loDireccion.cFiltroBusqueda
		This.AssertEquals( "No se asigno correctamente la propiedad cFiltro a Direccion", "CLIENTE = '" + lcCodigo1 + "'", lcValorFiltro )

		loRazonSocial.oEntidad.Cliente_PK = lcCodigo2

		lcValorFiltro = loDireccion.cFiltroBusqueda
		This.AssertEquals( "No se asigno correctamente la propiedad cFiltro a Direccion", "CLIENTE = '" + lcCodigo2 + "'", lcValorFiltro )

		loRazonSocial.oEntidad.Cliente_PK = ""

		lcValorFiltro = loDireccion.cFiltroBusqueda
		This.AssertEquals( "No se asigno correctamente la propiedad cFiltro a Direccion", "CLIENTE = '     '", lcValorFiltro )

		loRazonSocial.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
*!*		function ztestMensajeDireccionErronea
*!*			local loRazonSocial as Object, lcEntidad As String
*!*			lnCantMocks = _screen.mocks.Count + 1
*!*			private goMensajes
*!*			
*!*			_screen.mocks.agregarmock( "Mensajes" )
*!*			_screen.mocks.AgregarSeteoMetodoencola( 'MENSAJES', 'Enviar', .T., ".F." ) 		
*!*			goMensajes = _screen.zoo.crearobjeto( "Mensajes" )

*!*			loRazonSocial  = goformularios.procesar( 'RazonSocialV2' )
*!*			lnCantidad = _screen.mocks(lnCantMocks).oMetodos.count
*!*			loRazonSocial.oEntidad.EventoDireccionErronea()	
*!*			this.assertequals( "No se ejecuto el evento direccionErronea", lnCantidad -1 , _screen.mocks(lnCantMocks).oMetodos.count )

*!*			loRazonsocial.release()
*!*		endfunc 



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

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSql( lcSQL )
	
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
		
		goServicios.Datos.EjecutarSql( lcSQL  )

endfunc
