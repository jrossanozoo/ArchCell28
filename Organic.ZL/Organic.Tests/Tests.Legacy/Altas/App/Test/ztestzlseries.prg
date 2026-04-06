**********************************************************************
Define Class zTestZlSeries As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As zTestZlSeries Of zTestZlSeries.PRG
	#Endif

	cArchivoMock1 = ""

	*-----------------------------------------------------------------------------------------
	Function Setup
		CrearFuncion_func_NormalizarNombre()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestZlSeries
            local loZlseries as Object, loError  as Exception

            this.agregarmocks( "Direcciones, PRODUCTOZL, ZLAMBITOSSERIE" )

			=Crearent_zlseries_Test( this )	
			*!*	 DRAGON 2028
			set PROCEDURE to (this.cArchivoMock1) additive
			_screen.Mocks.AgregarMock( 'ZlSeries', forceext( this.cArchivoMock1, '' ) )

			private gomensajes as Object
			_screen.mocks.agregarmock( "Mensajes" )
			_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
			goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
            
            loZlseries = _Screen.zoo.instanciarentidad( "ZLSERIES" )

			with loZlseries
				try
					.nroserie = '407000'
					.Eliminar()
				catch
				finally
					.nuevo()
					.nombre = "Test"
					
					.PRODUCTOZOOLOGIC_pk = "Prod"
					.Ambito_pk = "Ambi"
					.direcc_pk = "Dire"
				endtry
	
				try
					.Grabar()
				catch
		            this.asserttrue( "No se pudo dar de alta" , .F. )        
	            endtry

				*-Intento de grabar el mismo serie -------------------------------------------

				try
					.nuevo()
					.nombre = "Test"
					
					.PRODUCTOZOOLOGIC_pk = "Prod"
					.Ambito_pk = "Ambi"
	
					.Grabar()
		            this.asserttrue( "No deberia grabar 2 veces el mismo serie" , .F. )        
				catch
				finally
					.Cancelar()
	            endtry

				*-Prueba de Producto Obligatorio ---------------------------------------------
				try
					.nroserie = '407000'
					.Eliminar()
				catch
				finally
					.nuevo()
					.nombre = "Test"
					
					.Ambito_pk = "Ambi"
					.direcc_pk = "Dire"
				endtry
	
				try
					.Grabar()
		            this.asserttrue( "No se deberia grabar sin el campo obligatorio PRODUCTO " , .F. )        
				catch
	            endtry
			endwith

            loZlseries.ultimo()
            loZlseries.Release()
			goMensajes = _Screen.zoo.app.oMensajes
      endfunc

Enddefine



*-----------------------------------------------------------------------------------------
function CargaDatosOK()

endfunc

*-----------------------------------------------------------------------------------------
function Crearent_zlseries_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMock1 = ObtenerNombreDeArchivoEnt_ZlSeries_Test()

	text to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMock1, '' ) )>> as Ent_ZlSeries of Ent_ZlSeries.prg
			function ObtenerNumeroString() as String
				return '407000'
			endfunc
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMock1, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarEnt_ZlSeries_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMock1
	delete file ( lcArchivo )
endfunc

*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoEnt_ZlSeries_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_Ent_ZlSeries_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSentencias( lcSQL , '' )
	
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
		
		goServicios.Datos.EjecutarSentencias( lcSQL , '' )

endfunc

