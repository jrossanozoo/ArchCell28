IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerRedondeo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerRedondeo]
GO;

CREATE FUNCTION [Funciones].[ObtenerRedondeo]( @Valor numeric( 15, 2 ), @CodigoRedondeo Varchar( 19 ) )
	Returns Numeric( 15, 2 )
AS
Begin
	Declare 
		 @HabilitaRedondearNormal		Bit
		,@HabilitaRedondearPrecios		Bit
		,@HabilitaRedondearTermEnteros	Bit
		,@HabilitaRedondearTermCentavos	Bit
		,@RedondeoNormal Tinyint
		,@RedondeoPorTabla Tinyint
		,@Cant Tinyint
		,@i Tinyint
		,@DesdePrecio Numeric( 15, 2 )
		,@HastaPrecio Numeric( 15, 2 )
		,@RedondearEn Numeric( 15, 2 )
		,@DesdeCentavos Numeric( 2, 0 )
		,@HastaCentavos Numeric( 2, 0 )
		,@DesdeEnteros Numeric( 15, 0 )
		,@HastaEnteros Numeric( 15, 0 )
		,@Terminacion Numeric( 2, 0 )
		,@TerminacionEnt Numeric(15, 2 )
		,@TerminacionCaracter Varchar( 16 )
		,@Centavos Numeric( 15, 2 )
		,@Enteros Numeric( 15, 0 )
		,@Retorno Numeric( 15, 2 )


	Declare @TMP_RedoDetPorTabla Table (ROWNUMBER Tinyint, DESDEPRE Numeric(15, 2), HASTAPRE Numeric(15, 2), REDEN Numeric(15, 2), NROITEM Numeric(5, 0)) 
	Declare @TMP_RedoDetPorCent Table (ROWNUMBER Tinyint, DESDE Numeric(2, 0), DESDEPRE Numeric(15, 2), HASTA Numeric(2, 0), HASTAPRE Numeric(15, 2), NROITEM Numeric(5, 0), TERMI Numeric(2, 0)) 
	Declare @TMP_RedoDetPorEnt Table (ROWNUMBER Tinyint, DESDE Numeric(15, 0), DESDEPRE Numeric(15, 2), HASTA Numeric(15, 0), HASTAPRE Numeric(15, 2), NROITEM Numeric(5, 0), TERMI Numeric(15, 0), TERMIALFA varchar(16)) 
	
	Select
		 @HabilitaRedondearNormal = RedoEnt
		,@HabilitaRedondearPrecios = RedoPre
		,@HabilitaRedondearTermEnteros = RedoTEnt
		,@HabilitaRedondearTermCentavos = RedoTCent
		,@RedondeoNormal = RNormal
		,@RedondeoPorTabla = RTabla
	from ZooLogic.Redo
	Where Codigo = @CodigoRedondeo

	Set @Retorno = @Valor


	-- REDONDEO NORMAL A ENTERO
	if @HabilitaRedondearNormal = 1 AND floor( @Retorno ) <> 0 AND ( @Retorno%floor( @Retorno ) ) <> 0
	Begin
		select @Retorno =
			Case
				When @RedondeoNormal = 1 Then floor( @Retorno ) + 1 -- Hacia Arriba
				When @RedondeoNormal = 2 Then floor( @Retorno ) -- Hacia Abajo
				When @RedondeoNormal = 3 Then round( @Retorno, 0 ) -- Normal
			End
	End
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	

	-- REDONDEO SEGUN TABLA
	if @HabilitaRedondearPrecios = 1 and Exists( Select NULL from ZooLogic.RedoDetPorTabla Where Codigo = @CodigoRedondeo )
	Begin
		Insert Into @TMP_RedoDetPorTabla
		SELECT
			ROW_NUMBER() OVER(ORDER BY NROITEM) AS ROWNUMBER
				,DESDEPRE
				,HASTAPRE
				,REDEN
				,NROITEM
			from ZooLogic.RedoDetPorTabla
			Where CODIGO = @CodigoRedondeo
			group by DESDEPRE, HASTAPRE, REDEN, NROITEM

		Select @i = 1, @Cant = @@ROWCOUNT

		while @i <= @Cant
		begin
			Select	 @DesdePrecio = DesdePre
					,@HastaPrecio = HastaPre
					,@RedondearEn = RedEn
			From @TMP_RedoDetPorTabla
			Where RowNumber = @i

			if ( @HastaPrecio >= @DesdePrecio AND @HastaPrecio > 0 )
			Begin
				if (@Retorno >= @DesdePrecio AND @Retorno <= @HastaPrecio AND (@Retorno % @RedondearEn != 0))
				Begin
					Select @Retorno =
						Case 
							When @RedondeoPorTabla = 1 Then @Retorno + @RedondearEn - ( @Retorno % @RedondearEn )
							When @RedondeoPorTabla = 2 Then @Retorno - @RedondearEn + @RedondearEn - ( @Retorno % @RedondearEn )
							When @RedondeoPorTabla = 3 Then (Case When ( @Retorno % @RedondearEn >= @RedondearEn / 2 ) Then @Retorno + @RedondearEn - (@Retorno % @RedondearEn) Else @Retorno - @RedondearEn + @RedondearEn - ( @Retorno % @RedondearEn ) End )
						End
				End
			End

			Set @i = @i + 1
		end
	End
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------


	-- REDONDEAR TERMINACION CENTAVOS
	if @HabilitaRedondearTermCentavos = 1 and Exists( Select NULL from ZooLogic.RedoDetPorCent Where Codigo = @CodigoRedondeo )
	Begin
		Select @Centavos = @Retorno - floor( @Retorno )

		Insert Into @TMP_RedoDetPorCent
		SELECT
			ROW_NUMBER() OVER(ORDER BY NROITEM) AS ROWNUMBER
				,DESDE
				,DESDEPRE
				,HASTA
				,HASTAPRE
				,NROITEM
				,TERMI
			from ZooLogic.redoDetPorCent
			Where CODIGO = @CodigoRedondeo
			group by DESDE, DESDEPRE, HASTA, HASTAPRE, NROITEM, TERMI

		Select @i = 1, @Cant = @@ROWCOUNT

		while @i <= @Cant
		Begin
			Select	 @DesdePrecio = DesdePre
					,@HastaPrecio = HastaPre
					,@DesdeCentavos = Desde
					,@HastaCentavos = Hasta
					,@Terminacion = Termi
			From @TMP_RedoDetPorCent
			Where RowNumber = @i
			 
			if (@Retorno >= @DesdePrecio AND @Retorno <= @HastaPrecio AND @DesdePrecio <= @HastaPrecio AND @HastaPrecio > 0)
				if (@Centavos >= @DesdeCentavos * 0.01 AND @Centavos <= @HastaCentavos * 0.01)
					Select @Centavos = @Terminacion * 0.01

			Set @i = @i + 1
		End

		Select @Retorno = floor( @Retorno ) + @Centavos
	End
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------


	-- REDONDEAR TERMINACION ENTEROS
	if @HabilitaRedondearTermEnteros = 1 and Exists( Select NULL from ZooLogic.RedoDetPorEnt Where Codigo = @CodigoRedondeo )
	Begin
		Declare @cde Tinyint
		Declare @Operando1 Int
		Declare @Operando2 Numeric( 15, 2 )
		Declare @Operando3 Numeric( 15, 2 )
		Declare @EntCal Numeric( 15, 2 )
		Declare @DesdeEnterosCaracter Varchar( 16 )
		Declare @HastaEnterosCaracter Varchar( 16 )

		Select @Enteros = floor( @Retorno )
		Select @Centavos = @Retorno - @Enteros
		Select @cde = 1
		Select @TerminacionCaracter = ''
		Select @DesdeEnterosCaracter = ''
		Select @HastaEnterosCaracter = ''

		Insert Into @TMP_RedoDetPorEnt
		SELECT
			ROW_NUMBER() OVER(ORDER BY NROITEM) AS ROWNUMBER
				,DESDE
				,DESDEPRE
				,HASTA
				,HASTAPRE
				,NROITEM
				,TERMI
				,TERMIALFA
			from ZooLogic.redoDetPorEnt
			Where CODIGO = @CodigoRedondeo
			group by DESDE, DESDEPRE, HASTA, HASTAPRE, NROITEM, TERMI, TERMIALFA

		Select @i = 1, @Cant = @@ROWCOUNT
		-- select * from ZooLogic.redoDetPorEnt
		while @i <= @Cant
		Begin
			Select	 @DesdePrecio = DesdePre
					,@HastaPrecio = HastaPre
					,@DesdeEnteros = Desde
					,@HastaEnteros = Hasta
					,@TerminacionEnt = Termi
					,@TerminacionCaracter = Funciones.Alltrim( TermiAlfa )
			From @TMP_RedoDetPorEnt
			Where RowNumber = @i
			 
			if @Retorno >= @DesdePrecio AND @Retorno <= @HastaPrecio AND @HastaPrecio >= @DesdePrecio AND @HastaPrecio > 0
			Begin

				Set @DesdeEnterosCaracter = Funciones.Alltrim( cast( @DesdeEnteros as varchar(16) ) )
				Set @HastaEnterosCaracter = Funciones.Alltrim( cast( @HastaEnteros as varchar(16) ) )
				Set @cde = len( @TerminacionCaracter )			
				Set @Operando1 = @Enteros / Power( 10, @cde )
				Set @Operando2 = Power( 10, @cde )
				Set @EntCal = @Enteros - ( @Operando1 * @Operando2 )
				Set @Operando3 = @EntCal + @Operando2

				if ( ( @EntCal >= @DesdeEnteros AND @EntCal <= @HastaEnteros ) OR
					 ( ( len( @HastaEnterosCaracter ) > len( @DesdeEnterosCaracter ) ) AND ( @Operando3 >= @DesdeEnteros AND @Operando3 <= @HastaEnteros ) ) )
					Set @Enteros = @Enteros - @EntCal + @TerminacionEnt
			End
                    
			Set @i = @i + 1
		End

		Select @Retorno = @Enteros + @Centavos
	End
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Set @Retorno = round( @Retorno, 2 )

	return @Retorno
End