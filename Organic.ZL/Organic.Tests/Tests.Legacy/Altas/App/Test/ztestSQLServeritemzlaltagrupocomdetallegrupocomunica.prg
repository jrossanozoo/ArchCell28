Define Class zTestSQLServerItemZlaltagrupocomDetallegrupocomunica as FxuTestCase of FxuTestCase.prg

	#If .f.
		Local this as zTestSQLServerItemZlaltagrupocomDetallegrupocomunica of zTestItemZlaltagrupocomDetallegrupocomunica.PRG
	#Endif

	cSerie = ""

	*---------------------------------
	Function Setup
		CrearFuncion_func_NormalizarNombre()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerSetear_grupo
		local loClase as Object, llRetorno as Boolean, lnGrupo as Integer, loError as zooexception of zooexception.prg

		loClase = newobject( "Aux_ItemZlaltagrupocomDetallegrupocomunica" )

		llRetorno = loClase.Setear_Grupo( 0 )
		this.asserttrue( "No debió pasar por SeriesCentralizadoresxGrupo (1)", !loClase.lPasoPorSeriesCentralizadoresxGrupo )
		this.asserttrue( "Debió devolver False (1)", !loClase.lValorRetornoSeriesCentralizadoresxGrupo )

		llRetorno = loClase.Setear_Grupo( 1 )
		this.asserttrue( "Debió pasar por SeriesCentralizadoresxGrupo (2)", loClase.lPasoPorSeriesCentralizadoresxGrupo )
		this.asserttrue( "Debió devolver False (2)", !loClase.lValorRetornoSeriesCentralizadoresxGrupo )

		llRetorno = loClase.Setear_Grupo( 2 )
		this.asserttrue( "Debió pasar por SeriesCentralizadoresxGrupo (3)", loClase.lPasoPorSeriesCentralizadoresxGrupo )
		this.asserttrue( "Debió devolver True (3)", loClase.lValorRetornoSeriesCentralizadoresxGrupo )

		llRetorno = loClase.Setear_Grupo( 3 )
		this.asserttrue( "Debió pasar por SeriesCentralizadoresxGrupo (4)", loClase.lPasoPorSeriesCentralizadoresxGrupo )
		this.asserttrue( "Debió devolver True (4)", loClase.lValorRetornoSeriesCentralizadoresxGrupo )

		loClase.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerSeriesCentralizadoresxGrupo
		local loClase as Object, llRetorno as Boolean, loError as zooexception of zooexception.prg, lcMensaje as String
		
		loClase = newobject( "Mock_ItemZlaltagrupocomDetallegrupocomunica" )
		this.cSerie = "123"

		try
			llRetorno = loClase.SeriesCentralizadoresxGrupo( 1 )
		catch to loError
			lcMensaje = "Se superó el límite de conexiones para los siguientes Items de Servicio:" + chr(10) + chr(13) + chr(10) + chr(13) + ;
						"Item Servicio 123 - Artículo Articulo 1 ( cantidad máxima 2)" + chr(10) + chr(13) + ;
						"Item Servicio 456 - Artículo Articulo 2 ( cantidad máxima 5)" + chr(10) + chr(13) + ;
						"Item Servicio 789 - Artículo Articulo 3 ( cantidad máxima 7)" + chr(10) + chr(13)
			This.assertequals( "El mensaje es incorrecto.", lcMensaje, loerror.uservalue.oinformacion.item(1).cmensaje )
		endtry

		try
			llRetorno = loClase.SeriesCentralizadoresxGrupo( 2 )
			This.asserttrue( "No debería pinchar", llRetorno )
		catch to loError
		endtry
		
		loClase.release()
	endfunc

enddefine



Define Class Mock_ItemZlaltagrupocomDetallegrupocomunica as ItemZlaltagrupocomDetallegrupocomunica of ItemZlaltagrupocomDetallegrupocomunica.prg

	*-----------------------------------------------------------------------------------------
	function EjecutaSPSeriesCentralizadoresxGrupo( txval ) as String
		local lcNombreCursor as String, lcXML as String

		lcNombreCursor = 'c_' + sys( 2015 )
		create cursor &lcNombreCursor( itemserv c(10), nroserie c(7), codart c(13), conexiones n(4) )

		if txval = 1
			insert into &lcNombreCursor values( '123', '123', 'Articulo 1', 2 )
			insert into &lcNombreCursor values( '456', '456', 'Articulo 2', 5 )
			insert into &lcNombreCursor values( '789', '789', 'Articulo 3', 7 )
		endif

		return lcNombreCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutaSPConexiones_Asp( txval ) as String
		local lcNombreCursor as String, lcXML as String

		lcNombreCursor = 'c_' + sys( 2015 )
		create cursor &lcNombreCursor( serie c(7) )

		do case
			case txval = '123'
				insert into &lcNombreCursor values( '1' )
				insert into &lcNombreCursor values( '2' )
			case txval = '456'
				insert into &lcNombreCursor values( '1' )
				insert into &lcNombreCursor values( '2' )
				insert into &lcNombreCursor values( '3' )
				insert into &lcNombreCursor values( '4' )
				insert into &lcNombreCursor values( '5' )
			case txval = '789'
				insert into &lcNombreCursor values( '1' )
				insert into &lcNombreCursor values( '2' )
				insert into &lcNombreCursor values( '3' )
				insert into &lcNombreCursor values( '4' )
				insert into &lcNombreCursor values( '5' )
				insert into &lcNombreCursor values( '6' )
				insert into &lcNombreCursor values( '7' )
		endcase

		return lcNombreCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutaSPSerieCentralizador( tcSerie ) as String
		local lcNombreCursor as String, lcXML as String

		lcNombreCursor = 'c_' + sys( 2015 )
		create cursor &lcNombreCursor( relalote c(10), nroserie c(7), codart c(13), conexiones n(4) )

		insert into &lcNombreCursor values( '123', '123', 'Articulo 1', 2 )
		insert into &lcNombreCursor values( '789', '789', 'Articulo 3', 7 )

		return lcNombreCursor
	endfunc 

enddefine




define class Aux_ItemZlaltagrupocomDetallegrupocomunica as ItemZlaltagrupocomDetallegrupocomunica of ItemZlaltagrupocomDetallegrupocomunica.prg
	lPasoPorSeriesCentralizadoresxGrupo = .f.
	lPasoPorControlarGrupos = .f.
	lValorRetornoSeriesCentralizadoresxGrupo = .f.
	lValorRetornoControlarGrupos = .f.
	cSerie = '407000'
	*-----------------------------------------------------------------------------------------
	function SeriesCentralizadoresxGrupo( txVal as Variant ) as Boolean
		this.lPasoPorSeriesCentralizadoresxGrupo = .t.
		do case
			case txval = 1
				this.lValorRetornoSeriesCentralizadoresxGrupo = .f.
			case txval = 2
				this.lValorRetornoSeriesCentralizadoresxGrupo = .t.
		endcase
		return this.lValorRetornoSeriesCentralizadoresxGrupo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsSerieCentralizador( tcSerie as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		return llRetorno
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSql( lcSQL  )
	
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
