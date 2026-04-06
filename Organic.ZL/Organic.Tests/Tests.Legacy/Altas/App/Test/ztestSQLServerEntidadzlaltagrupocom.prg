**********************************************************************
DEFINE CLASS zTestSQLServerEntidadzlAltaGrupocom as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestSQLServerEntidadzlAltaGrupocom OF zTestSQLServerEntidadzlAltaGrupocom.PRG
	#ENDIF
	
	CodDireccion = ""
	
	*---------------------------------
	Function Setup
		local loEntidad as entidad of entidad.prg
		CrearFuncion_func_NormalizarNombre()
		loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
		with loentidad
			try
				.Codigo = "ALTAGRUPOCOM"
			catch to loError
				.nuevo()
				.Codigo = "ALTAGRUPOCOM"
				.Numero = 1
				.Grabar()
			catch to loError
			finally
				.release()
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerAgregarClienteAlDetalle
		local loEntidad as entidad OF entidad.prg, lnCodGrupoNoAfectado as Integer, lnCodGrupoAfectado as Integer, lcCodigo1 as String,;
			lcCodigo2 as String, lcCodigo3 as String, lcCodigo4 as String
		
		this.CodDireccion = CrearDirecciones()
		
		This.agregarmocks( "usov2,ZLSERIES, ActualizarzOO" )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarclientes', .T., "[*COMODIN],[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )
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

		loEntidad = _screen.zoo.instanciarentidad( "ZLCLIENTES" )

		with loEntidad
			.Nuevo()
			lcCodigo1 = .codigo
			.Nombre = "Cliente " + lcCodigo1
			.direcc_pk = this.CodDireccion
			.Grabar()

			.Nuevo()
			lcCodigo2 = .codigo
			.Nombre = "Cliente " + lcCodigo2
			.direcc_pk = this.CodDireccion
			.Grabar()

			.Nuevo()
			lcCodigo3 = .codigo
			.Nombre = "Cliente " + lcCodigo3
			.direcc_pk = this.CodDireccion
			.Grabar()

			.Nuevo()
			lcCodigo4 = .codigo
			.Nombre = "Cliente " + lcCodigo4
			.direcc_pk = this.CodDireccion
			.Grabar()

			.Release()
		endwith
		
		loEntidad = _screen.zoo.instanciarentidad( "GRUPOCOMUNICACION" )
		with loEntidad
			.Nuevo()
			.Descrip = "Con Cliente 03"
			.Usos_Pk = "01"
			*-- Prueba Exepciones
			with .GrupoClientes
				.LimpiarItem()
				.oItem.codcli_PK = lcCodigo1
				.Actualizar()

				.LimpiarItem()
				.oItem.codcli_PK = lcCodigo2
				.Actualizar()

				.LimpiarItem()
				.oItem.codcli_PK = lcCodigo3
				.Actualizar()
			endwith
			.Grabar()			
			lnCodGrupoNoAfectado = .Codigo
			
			.Nuevo()
			.Descrip = "Sin Cliente 03"
			.Usos_Pk = "02"
			*-- Prueba Exepciones
			with .GrupoClientes
				.LimpiarItem()
				.oItem.codcli_PK = lcCodigo4
				.Actualizar()
			endwith
			.Grabar()			
			lnCodGrupoAfectado = .Codigo
			.Release()
		endwith

		goParametros.Zl.ValoresSugeridos.ClienteSugeridoIS = lcCodigo3
		goParametros.Zl.ValoresSugeridos.NroSerieSugeridoDefault = "010101"

		loEntidad = createobject( "ent_zlaltagrupocomTest" )
		loEntidad.DetalleGrupoComunica.oiTEM.oCompComunicacion.oDetalle = null
		loEntidad.DetalleGrupoComunica.oiTEM.oCompComunicacion = null
		loEntidad.DetalleGrupoComunica.oItem = Null
		loEntidad.DetalleGrupoComunica.oItem = newobject( "ItemTest" )
		loEntidad.DetalleGrupoComunica.oItem.inicializar()
		loEntidad.DetalleGrupoComunica.oItem.oCompcomunicacion.oDetalle = loEntidad.DetalleGrupoComunica
	
		with loEntidad
			.Nuevo()
			with .DetalleGrupoComunica
				.LimpiarItem()
				.oItem.Grupo_Pk = lnCodGrupoNoAfectado
				.Actualizar()

				.LimpiarItem()
				.oItem.Grupo_Pk = lnCodGrupoAfectado
				.Actualizar()
			endwith
			.Grabar()
			.Release()
		endwith
		
		loEntidad = _screen.zoo.instanciarentidad( "GRUPOCOMUNICACION" )		
		with loEntidad

			.Codigo = lnCodGrupoNOAfectado
			This.assertequals( "No es correcta la cantidad de items en 'GrupoClientes'(1).", 3, .GrupoClientes.Count )
			This.assertequals( "El Primer Item del detalle es incorrecto(1).", lcCodigo1, alltrim( .GrupoClientes.item[ 1 ].CodCli_Pk ) )
			This.assertequals( "El Segundo Item del detalle es incorrecto(1).", lcCodigo2, alltrim( .GrupoClientes.item[ 2 ].CodCli_Pk ) )
			This.assertequals( "El Tercer Item del detalle es incorrecto(1).", lcCodigo3, alltrim( .GrupoClientes.item[ 3 ].CodCli_Pk ) )

			.Codigo = lnCodGrupoAfectado
			This.assertequals( "No es correcta la cantidad de items en 'GrupoClientes'(2).", 2, .GrupoClientes.Count )
			This.assertequals( "El Primer Item del detalle es incorrecto(2).", lcCodigo4, alltrim( .GrupoClientes.item[ 1 ].CodCli_Pk ) )
			This.assertequals( "El Segundo Item del detalle es incorrecto(2).", lcCodigo3, alltrim( .GrupoClientes.item[ 2 ].CodCli_Pk ) )

			.Release()
		endwith
		
	endfunc 
	

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerValorSugerigoParaNroSerie
		local loEntidad as entidad OF entidad.prg
		This.agregarmocks( "zlseries" )
		loEntidad = _screen.zoo.instanciarentidad( "zlAltaGrupocom" )
		with loEntidad

			goParametros.Zl.ValoresSugeridos.NroSerieSugeridoDefault = "123456"
			goParametros.Zl.ValoresSugeridos.ClienteSugeridoIS = "CLI01"
			.Nuevo()
			This.Assertequals( "El valor seteado en el Nro de Serie es incorrecto.", "123456", alltrim( .NroSerie_Pk ) )
			This.Asserttrue( "No se limpio el valor del parametro.", empty( goParametros.Zl.ValoresSugeridos.NroSerieSugeridoDefault ) )
			This.assertequals( "El valor seteado en cCliente es incorrecto.", "CLI01", alltrim( .cCliente ) )
			This.assertequals( "No Asigno el valor al Detalle.", "123456", alltrim( .DetalleGrupocomunica.oItem.cSerie ) )
			.Cancelar()

			.Release()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLServerInyeccionDetalleAComponente
		local loEntidad as entidad OF entidad.prg
		
		This.agregarmocks( "GRUPOCOMUNICACION" )

		loEntidad = _screen.zoo.instanciarentidad( "zlAltaGrupocom" )
		loEntidad.DetalleGrupoComunica.AddProperty( "PropiedadPrueba", "Test" )
		with loEntidad.DetalleGrupoComunica
			with .oItem.oCompComunicacion
				This.assertequals( "La referencia inyectada no es del detalle correcto.", "Test", .oDetalle.PropiedadPrueba )
			endwith
		endwith
		
		loEntidad.Release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSQLServerCargarNumeroDeSerieYUnGrupoDespuesCambiarElNumeroDeSerie

		local loEntidad as entidad OF entidad.prg, loItem as Object
		This.agregarmocks( "ZLSERIES,GRUPOCOMUNICACION" )

		loEntidad = _screen.zoo.instanciarentidad( "zlAltaGrupocom" )

		loEntidad.DetalleGrupoComunica.oItem.Release()
		loEntidad.DetalleGrupoComunica.oItem = null
		loEntidad.DetalleGrupoComunica.oItem = createobject( "MockItemZlaltagrupocomDetallegrupocomunica" )
		loEntidad.DetalleGrupoComunica.oItem.inicializar()
		
		with loEntidad
			.Nuevo()
			.NroSerie_Pk = "001001"
			with .DetalleGrupoComunica
				.LimpiarItem()
				.oItem.Grupo_Pk = 8
				.Actualizar()

				.LimpiarItem()
				.oItem.Grupo_Pk = 9
				.Actualizar()

			endwith

			.NroSerie_Pk = "002002"
			This.assertequals( "El numero de serie es incorrecto.", "002002", alltrim( .DetalleGrupoComunica.Item[ 1 ].Numero_Pk ) )
			
			.Release()
		endwith
			
	endfunc

enddefine

*-----------------------------------------------------------------------------------------

define class ItemTest as ItemZlaltagrupocomDetallegrupocomunica of ItemZlaltagrupocomDetallegrupocomunica.PRG

	function Setear_Grupo( txVal as variant ) as Boolean
		return .T.
	endfunc

enddefine


*---------------------------------------------------------------------------------------------------------------
define class ent_zlaltagrupocomTest as ent_zlaltagrupocom of ent_zlaltagrupocom.PRG
	protected function ObtenerExistenciaSerieGrupo( tcSerie as String, tnGrupo as Integer ) as Boolean
		return .f.
	endfunc
enddefine


*---------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------
define class MockItemZlaltagrupocomDetallegrupocomunica as ItemZlaltagrupocomDetallegrupocomunica of ItemZlaltagrupocomDetallegrupocomunica.Prg

	*-----------------------------------------------------------------------------------------
	protected function EsSerieCentralizador( tcSerie as String ) as Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutaSPSeriesCentralizadoresxGrupo( tnGrupo as Integer ) as String
		local lcCursor as String
		lcCursor = "c_" + sys( 2015 )
		
		create cursor &lcCursor ( NroSerie c(6), Conexiones n)

		insert into &lcCursor values ( "001001", 1 )
		
		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeCentralizadores( tcNroSerie as String ) as Void
		return 1
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
