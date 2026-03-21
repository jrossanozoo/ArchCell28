IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_ModificarCombinacionesConPrecioNuevoSegunExpresion]') AND type in (N'P'))
DROP PROC [Funciones].[sp_ModificarCombinacionesConPrecioNuevoSegunExpresion]
GO;

IF  EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'dtTablaFiltro' AND ss.name = N'dbo')
DROP TYPE [dbo].[dtTablaFiltro]
GO;

CREATE TYPE dtTablaFiltro AS TABLE (ARTICULO Varchar ( 13 ), COLORES Varchar ( 2 ), TALLE Varchar ( 3 ), FALTAFW Datetime, HALTAFW Varchar( 8 ), FMODIFW Datetime, HMODIFW Varchar( 8 ), UALTAFW Varchar( 100 ), UMODIFW Varchar( 100 ), SALTAFW Varchar( 7 ), SMODIFW Varchar( 7 ), BDALTAFW Varchar( 8 ), BDMODIFW Varchar( 8 ), VALTAFW Varchar( 13 ), VMODIFW Varchar( 13 ),CODORI Varchar ( 20 ), ENTORI Varchar ( 40 ), FECHAVIG DateTime, TIMESTAMPA Numeric ( 14,0 ), DESCFW Varchar( 200 ) )

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCotizacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCotizacion]
GO;

CREATE FUNCTION [Funciones].[ObtenerCotizacion]
( @Fecha Datetime, @Moneda varchar(10) )
RETURNS numeric( 15, 5 )
AS
BEGIN
declare
	 @Cotizacion numeric( 15, 5 )
	,@FechaSinhora datetime
	,@Hora smallint

Select
	 @FechaSinhora = convert( date, @Fecha )
	,@Hora = convert( smallint, replace( left( convert( varchar, @Fecha, 108), 5 ), ':', '' ) )

Select top 1 @Cotizacion = COTIZ
from ZOOLOGIC.COTIZA
Where CODIGO = @Moneda
and FECHA <= @FechaSinhora
And ( ( convert( smallint, replace( left( convert( varchar, HORA, 108), 5 ), ':', '' ) ) <= @Hora and FECHA = @FechaSinhora ) )
Order by FECHA Desc, convert( smallint, replace( left( convert( varchar, HORA, 108), 5 ), ':', '' ) ) Desc

Select top 1 @Cotizacion = COTIZ
from ZOOLOGIC.COTIZA
Where CODIGO = @Moneda
and FECHA < @FechaSinhora
and @Cotizacion is null
Order by FECHA Desc, convert( smallint, replace( left( convert( varchar, HORA, 108), 5 ), ':', '' ) ) Desc

select @Cotizacion = isnull( @Cotizacion, 1 )

return @Cotizacion
END

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[FactorIvaArticulo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[FactorIvaArticulo]
GO;

CREATE FUNCTION [Funciones].[FactorIvaArticulo]
( @TipoIva varchar(6), @Articulo varchar(15) )
RETURNS numeric( 15, 5 )
AS
BEGIN
	declare
		@CondicionIva int = 0
		,@Porcentaje numeric( 15, 5 ) = 0
		,@Factor numeric( 15, 5 ) = 0
		,@gravado numeric( 15, 5 ) = 0
		,@gravadoreducido numeric( 15, 5 ) = 0

		if (UPPER( rtrim( @TipoIva) ) = 'COMPRA')
		begin
			Select top 1 @CondicionIva = ARTIVA, @Porcentaje = ANX2
			from ZOOLOGIC.ART
			Where ARTCOD = rtrim( @Articulo )
		end
		else
		begin
			Select top 1 @CondicionIva = ARTCONIVA, @Porcentaje = ARTPORIVA
			from ZOOLOGIC.ART
			Where ARTCOD = rtrim( @Articulo )
		end
	-- Iva Gravado
	select top 1 @gravado = convert( numeric(15,5), VALOR)  from [PARAMETROS].[SUCURSAL] where IDUNICO = '1B58BD40911092149E118F2816855050858001'
	-- Iva gravado reducido
	select top 1 @gravadoreducido = convert( numeric(15,5), VALOR)  from [PARAMETROS].[SUCURSAL] where IDUNICO = '1BDD91621121BA14C5D1A1DF11938527732491'

	if ( @CondicionIva != 0)
	begin
		if (@CondicionIva = 1)
		begin
			set @Porcentaje = @gravado
		end
		if (@CondicionIva = 4)
		begin
			set @Porcentaje = @gravadoreducido
		end
		--if (@CondicionIva = 3) // porcentaje personalizado
		if (@CondicionIva = 2) -- no gravado
		begin
			set @Porcentaje = 0
		end
		set @Factor = 1 + ( @Porcentaje/100)
	end
	else
	begin
		set @Factor = 0
	end

	return @Factor
END

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[DividirLaCadenaPorElCaracterDelimitador]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[DividirLaCadenaPorElCaracterDelimitador]
GO;

CREATE FUNCTION [Funciones].[DividirLaCadenaPorElCaracterDelimitador]
(
@CadenaOriginal varchar(max),
@Delimitador char(1)
)
returns @Items TABLE (Item varchar(max), Orden int)
as
begin
declare
	@Posicion int
	,@PosicionParentesisApertura int
	,@PosicionParentesisCierre int
	,@Fragmento varchar(max)
	,@Orden int

	set @CadenaOriginal = rtrim( ltrim( @CadenaOriginal ) )
	set @Posicion = 1
	set @Orden = 1

	if @CadenaOriginal is null or len( @CadenaOriginal ) = 0 or charindex( @Delimitador, @CadenaOriginal ) = 0
		insert into @Items( Item ) values ( @CadenaOriginal )
	else
		while ( @Posicion != 0 ) and ( len( @CadenaOriginal ) > 0 )
		begin
			if @Delimitador = ','	-- Puede aparecer como separador de parámetros entonces verifica que no se encuentre entre paréntesis
				begin
					set @Posicion = 1;
					set @PosicionParentesisApertura = 0;
					set @PosicionParentesisCierre = 2;

					while ( @Posicion > 0 ) and ( @Posicion between @PosicionParentesisApertura and @PosicionParentesisCierre )
					begin
						set @PosicionParentesisApertura = charindex( '(', @CadenaOriginal, @Posicion + 1);
						set @PosicionParentesisCierre = charindex( ')', @CadenaOriginal, @Posicion + 1 );
						set @Posicion = charindex( @Delimitador, @CadenaOriginal, @Posicion + 1 )
					end
				end
			else
				set @Posicion = charindex( @Delimitador, @CadenaOriginal );

			if @Posicion!=0
				set @Fragmento = rtrim( ltrim( left( @CadenaOriginal, @Posicion - 1 ) ) )
			else
				set @Fragmento = @CadenaOriginal

			if( len( @Fragmento ) > 0 )
				insert into @Items( Item, Orden ) values ( @Fragmento, @Orden )

			set @CadenaOriginal = ltrim( right( @CadenaOriginal, len( @CadenaOriginal ) - @Posicion ) )
			set @Orden = @Orden + 1
		end;

	return
end
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerElementosFuncionPrecioDeLista]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerElementosFuncionPrecioDeLista]
GO;

CREATE FUNCTION [Funciones].[ObtenerElementosFuncionPrecioDeLista]
( @Expresion nvarchar( 4000 ) )
RETURNS @Listas table(	ListaDePrecios varchar(6) )
AS
BEGIN
	declare
	 	@aux varchar( 8000 )
		,@InicioElemento smallint
		,@FinElemento smallint
		,@LongitudExpresion smallint
		,@Elemento varchar( 6 )
		,@LongitudFuncion tinyint
		,@Funcion varchar( 15 )
		,@Argumentos varchar( 4000 )
		,@ExpresionLimpia nvarchar( 4000 ) = ''

	Select @Funcion = 'PRECIODELISTA'
		,@LongitudFuncion = LEN( @Funcion )

	Declare cArgumentos Cursor for
		select item from [Funciones].[DividirLaCadenaPorElCaracterDelimitador]( @Expresion, '"' )  order by Orden asc

	Open cArgumentos
	Fetch Next From cArgumentos Into @Argumentos
	set @aux = 1;
	while @@FETCH_STATUS = 0
	begin
		if @aux % 2 = 1
			Select @ExpresionLimpia = @ExpresionLimpia + UPPER( REPLACE( @Argumentos, ' ', '' ) )
		else
			Select @ExpresionLimpia = @ExpresionLimpia + '"' + @Argumentos + '"'

		set @aux += 1;
		Fetch Next From cArgumentos Into @Argumentos
	end
	close cArgumentos
	Deallocate cArgumentos

	Select @Expresion = @ExpresionLimpia
	Select @Expresion = UPPER( REPLACE( @Expresion, '''', '"' ) )

	Select @InicioElemento = CHARINDEX( @Funcion, @Expresion, 1 )

	while @InicioElemento > 0 and LEN( @Expresion ) > 0
	begin 
		Select @InicioElemento = @InicioElemento + @LongitudFuncion + 2
		Select @LongitudExpresion = LEN( @Expresion )
		Select @FinElemento = CHARINDEX( '"', @Expresion, @InicioElemento ) 
		if ( @FinElemento > @InicioElemento )

		begin

			Select @Elemento = SUBSTRING( @Expresion, @InicioElemento, @FinElemento - @InicioElemento )

			if not exists (select * from @Listas where ListaDePrecios = @Elemento )

				Insert Into @Listas values( @Elemento )

			select @Expresion = SUBSTRING( @Expresion, @FinElemento + 2, @LongitudExpresion )

			Select @InicioElemento = CHARINDEX( @Funcion, @Expresion, 1 )

		end

		else

		begin

			Select @InicioElemento = 0

			Select @LongitudExpresion = 0

		end

	end

	return
end

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerListasDependientes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerListasDependientes]
GO;

CREATE FUNCTION [Funciones].[ObtenerListasDependientes]
(  )
RETURNS @FormulaYListas table(	Formula varchar(15), ListaDePrecios varchar(6) )
AS
BEGIN
	declare @Expresion varchar( 8000 )
	Declare @Formula varchar( 15 )

	Declare cFormula Cursor for Select CODIGO, ExprSql from ZOOLOGIC.FORMULA
	Open cFormula
	Fetch Next From cFormula Into @Formula, @Expresion
	while @@FETCH_STATUS = 0
	begin
		Insert into @FormulaYListas ( Formula, ListaDePrecios )
		Select @Formula as Formula, ListaDePrecios from  [Funciones].[ObtenerElementosFuncionPrecioDeLista]( @Expresion )

		Fetch Next From cFormula Into @Formula, @Expresion
	end
	close cFormula
	Deallocate cFormula
	return
END

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EvaluarExpresionFormula]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EvaluarExpresionFormula]
GO;

CREATE FUNCTION [Funciones].[EvaluarExpresionFormula]
( @ARTICULO Varchar( 23 ), @COLORES Varchar( 12 ), @TALLE Varchar( 13 ), @VigenciaParaFecha nVarchar( 15 ), @Expresion nVarchar( 4000 ) ) 
RETURNS nVarchar ( 4000 )
AS
BEGIN
	Declare
		@aux Varchar( 4000 )
		,@FuncionRetorno nVarchar( 4000 )
		,@ListaDePrecios Varchar( 6 )
		,@FuncionPrecioSQL Varchar( 150 )
		,@Argumentos varchar( 4000 )
		,@ExpresionLimpia nvarchar( 4000 ) = ''

	Declare @a Numeric(15,5)

	Declare cArgumentos Cursor for
		select item from [Funciones].[DividirLaCadenaPorElCaracterDelimitador]( @Expresion, '"' )  order by Orden asc

	Open cArgumentos
	Fetch Next From cArgumentos Into @Argumentos
	set @aux = 1;
	while @@FETCH_STATUS = 0
	begin
		if @aux % 2 = 1
			Select @ExpresionLimpia = @ExpresionLimpia + UPPER( REPLACE( @Argumentos, ' ', '' ) )
		else
			Select @ExpresionLimpia = @ExpresionLimpia + '"' + @Argumentos + '"'

		set @aux += 1;
		Fetch Next From cArgumentos Into @Argumentos
	end
	close cArgumentos
	Deallocate cArgumentos

	Select @FuncionRetorno = @ExpresionLimpia
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, '''' , '"' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'DATE()' , 'GETDATE()' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'DATETIME()' , 'GETDATE()' ) )

	Declare cElementosPrecioDeLista Cursor for Select * from [Funciones].[ObtenerElementosFuncionPrecioDeLista]( @Expresion )

	Open cElementosPrecioDeLista
	Fetch Next From cElementosPrecioDeLista Into @ListaDePrecios

	while @@FETCH_STATUS = 0
	Begin
		Select @FuncionPrecioSQL = 
			'[Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]( ' + rtrim(ltrim(@ARTICULO)) + ', ' + rtrim(ltrim(@COLORES)) + ', ' + rtrim(ltrim(@TALLE)) + ',  ''' + rtrim(ltrim(@ListaDePrecios)) + ''', ' + rtrim(ltrim(@VigenciaParaFecha)) + ', default)'

		Select @FuncionRetorno = replace( @FuncionRetorno, 'PRECIODELISTA("'+ rtrim( ltrim( @ListaDePrecios ) ) + '")', @FuncionPrecioSQL )
		Fetch Next From cElementosPrecioDeLista Into @ListaDePrecios
	End

	Close cElementosPrecioDeLista
	Deallocate cElementosPrecioDeLista

	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'COTIZACION' , '[Funciones].[ObtenerCotizacion]' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'REDONDEO' , '[Funciones].[ObtenerRedondeo]' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, '"' , '''' ) )

	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'CASE' , ' CASE ' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'WHEN' , ' WHEN ' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'THEN' , ' THEN ' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'ELSE' , ' ELSE ' ) )
	Select @FuncionRetorno = upper( replace( @FuncionRetorno, 'END' , ' END ' ) )
	return @FuncionRetorno
END

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTimestamp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerTimestamp]
GO;

CREATE FUNCTION [Funciones].[ObtenerTimestamp]
()
RETURNS numeric( 14, 0 )
AS
BEGIN

	declare @retorno numeric(14,0)
	set @retorno = ( select floor(cast((DATEDIFF(ss, '19950101', GETDATE())) as numeric(14,0)) * 1000 +  cast( DATEDIFF(ms, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())), GETDATE()) as numeric(14,0)) / 100))

	return @retorno
END

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_ModificarCombinacionesConPrecioNuevoSegunExpresion]') AND type in (N'P'))
DROP PROC [Funciones].[sp_ModificarCombinacionesConPrecioNuevoSegunExpresion]
GO;

CREATE PROC [Funciones].[sp_ModificarCombinacionesConPrecioNuevoSegunExpresion]
( @Expresion varchar( 1000 ),
@ListaDePrecios varchar( 6 ),
@VigenciaParaFecha date,
@Tabla dtTablaFiltro READONLY,
@CodigoFormula varchar( 200 )
)
AS
BEGIN

	SET NOCOUNT ON;

	Declare @StrPrec Varchar( 8000 )
	Declare @SqlIns nVarchar( 4000 )
	Declare @SqlUpd nVarchar( 4000 )
	Declare @SqlSel nVarchar( 4000 )
	Declare @SqlDrop nVarchar( 4000 )
	Declare @SqlQuery nVarchar( 4000 )
	Declare @ParmDefinition nVarchar(100)
	Declare @ERR_MSG AS NVARCHAR(4000)
	Declare @ERR_SEV AS SMALLINT
	Declare @ERR_STA AS SMALLINT
	Declare @xstate int
	Declare @StrTimestamp nVarchar(100)



 -- Nuevo 

	Declare @precioConVigencia as integer;

	select top 1 @precioConVigencia = iif( VALOR = '.F.', 0, 1 ) from [PARAMETROS].[SUCURSAL] where IDUNICO = '121A11B731369214C131982F14777281646901'



	Select @StrPrec = [Funciones].[EvaluarExpresionFormula]( 'P.ARTICULO', 'P.COLORES', 'P.TALLE', 'P.FECHAVIG', @Expresion )
	Select @SqlSel =
	' Select *, ''' + @ListaDePrecios + ''' as ListaPre into #tt from @TablaQuery'

	Select @SqlIns = 
	'Insert Into ZOOLOGIC.PrecioAr(FALTAFW, HALTAFW, FMODIFW, HMODIFW, UALTAFW, UMODIFW, SALTAFW, SMODIFW, BDALTAFW, BDMODIFW, VALTAFW, VMODIFW, DESCFW, CODORI, ENTORI, FECHAVIG,
           TimestampA, Codigo, ARTICULO, COLORES, TALLE,  ListaPre, PDirecto)' + 
	' Select T.FMODIFW as FALTAFW, T.HMODIFW as HALTAFW, T.FMODIFW as FMODIFW, T.HMODIFW as HMODIFW, T.UMODIFW as UALTAFW, T.UMODIFW as UMODIFW, T.SMODIFW as SALTAFW, T.SMODIFW as SMODIFW, T.BDMODIFW as BDALTAFW, T.BDMODIFW as BDMODIFW, T.VMODIFW as VALTAFW, T.VMODIFW as VMODIFW, T.DESCFW as DESCFW, T.CODORI, T.ENTORI, T.FECHAVIG,
           T.TIMESTAMPA, Funciones.Padr( CONVERT(varchar(14), T.TIMESTAMPA ), 14, '' '') + ''' + @ListaDePrecios + '''  + T.ARTICULO + T.COLORES + T.TALLE as Codigo, T.ARTICULO, T.COLORES, T.TALLE,  '''  + @ListaDePrecios + ''' as ListaPre, ' + REPLACE( @StrPrec, 'P.', 'T.' ) + ' as PDirecto' + 
	' From #tt T'
   if ( @precioConVigencia = 0)
	begin
   	Select @SqlIns = @SqlIns + ' Left join ZooLogic.PrecioAr P ' + 
   	' on  T.ARTICULO= P.ARTICULO' +
' and T.COLORES = P.COLORES'+
' and T.TALLE = P.TALLE'+
   	' And T.ListaPre = P.ListaPre ' + 
   	' Where P.ListaPre is null'
   end


   if ( @precioConVigencia = 0)
   begin
	Select @SqlUpd = 
	'Update P' + 
	' set P.FMODIFW = T.FMODIFW, P.HMODIFW = T.HMODIFW, P.UMODIFW = T.UMODIFW, P.SMODIFW = T.SMODIFW, P.BDMODIFW = T.BDMODIFW, P.VMODIFW = T.VMODIFW, P.DESCFW = T.DESCFW, P.PDirecto = ' + REPLACE( @StrPrec, 'P.', 'T.' ) +
	' From ZooLogic.PrecioAr P'+ 
	' inner join #tt T ' +
	' on T.ARTICULO= P.ARTICULO' +
' and T.COLORES = P.COLORES'+
' and T.TALLE = P.TALLE'+
	' And T.ListaPre = P.ListaPre '+
	' And P.timestampa = [Funciones].[ObtenerTimestampVigenteDeLaCombinacion]( T.ARTICULO, T.COLORES, T.TALLE, T.LISTAPRE, GETDATE() )'

   end
   else
   begin
   	Select @SqlUpd = ''
   end


	select @SqlDrop =
	'Drop Table #tt'

	Select @SqlQuery =	ltrim( rtrim( @SqlSel ) ) + CHAR( 13 ) + CHAR( 10 ) +
						ltrim( rtrim( @SqlIns ) ) + CHAR( 13 ) + CHAR( 10 ) +
						ltrim( rtrim( @SqlUpd ) ) + CHAR( 13 ) + CHAR( 10 ) +
						ltrim( rtrim( @SqlDrop ) )

	SET @ParmDefinition = N'@TablaQuery dtTablaFiltro READONLY'

	BEGIN TRY
		EXECUTE sp_executesql @SqlQuery, @ParmDefinition, @TablaQuery = @Tabla
	END TRY
	BEGIN CATCH
		SELECT @ERR_MSG = ERROR_MESSAGE(),
		@ERR_SEV =ERROR_SEVERITY(),
		@ERR_STA = ERROR_STATE(),
		@xstate = XACT_STATE();

		SET @ERR_MSG= 'Se produjo un error al evaluar la fórmula [' + rtrim( @CodigoFormula ) +  '] para la lista de precios [' + @ListaDePrecios + ']: ' + @ERR_MSG + ' - Código de error interno: 112233'
		RAISERROR (@ERR_MSG, @ERR_SEV, @ERR_STA)
	END CATCH

END

GO;

IF OBJECT_ID(N'[Funciones].[ObtenerPrecioDeLaCombinacionConVigenciaAlMomento]') is not null DROP FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConVigenciaAlMomento]
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConVigenciaAlMomento]
(
    @PrecioParcial numeric(15,2),
    @VigenciaParaFecha datetime,
    @Operador char(1),
    @Coeficiente numeric(15,2),
    @MonedaCotiz char(10),
    @TipoRedondeo numeric(1),
    @CantRedondeo numeric(2)
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
DECLARE @CoeficienteFinal numeric(15,5)

	if (@MonedaCotiz IS NULL OR @MonedaCotiz = '')
		set @CoeficienteFinal = @Coeficiente
	else
		BEGIN
			DECLARE @fechaActual datetime, @hora varchar(max), @fecha varchar(max), @FechaHora datetime
			if(convert(varchar, @VigenciaParaFecha, 114)='00:00:00:000')
				BEGIN
					set @fechaActual = GETDATE()
					if cast(@VigenciaParaFecha AS date) < cast(@fechaActual AS date)
						set @hora = '23:59:00.000'
					else
						set @hora = convert(varchar, @fechaActual, 114)
					set @hora = CAST(LEFT(@hora, 8) as varchar(8)) + cast(REPLACE(RIGHT(@hora, 4), ':', '.') as varchar(4))
					set @fecha = CAST(YEAR(@VigenciaParaFecha) as varchar(4)) + CAST(RIGHT('00' + LTRIM(RTRIM(MONTH(@VigenciaParaFecha))),2) as varchar(2)) + CAST(RIGHT('00' + LTRIM(RTRIM(DAY(@VigenciaParaFecha))),2) as varchar(2)) + ' ' + CAST(@hora as varchar(12))
					set @FechaHora = CONVERT(datetime, @fecha)
				END
			else
				set @FechaHora = @VigenciaParaFecha

			set @CoeficienteFinal = coalesce( Funciones.ObtenerCotizacion(@FechaHora, @MonedaCotiz), 0)
		END

	set @retorno = coalesce(CASE @Operador WHEN '*' THEN @PrecioParcial * @CoeficienteFinal
									WHEN '/' THEN @PrecioParcial / @CoeficienteFinal 
									WHEN '+' THEN @PrecioParcial + @CoeficienteFinal
									WHEN '-' THEN @PrecioParcial - @CoeficienteFinal END, 0)

	if @TipoRedondeo = 1
		set @CantRedondeo = @CantRedondeo * -1
	else
		if @TipoRedondeo = 2
			BEGIN
				set @CantRedondeo = @CantRedondeo * 1
				if @CantRedondeo = 2
					set @CantRedondeo = 0
			END
		else
			set @CantRedondeo = 2

	set @retorno = ROUND(@retorno, @CantRedondeo)
	return @retorno
end

GO;

IF OBJECT_ID(N'[Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia]') is not null DROP FUNCTION [Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia]
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia]
(
    @P_ARTICULO Varchar( 23 ), 
    @P_COLORES Varchar( 12 ), 
    @P_TALLE Varchar( 13 ), 
    @CodigoLPrecio Varchar(6), 
    @VigenciaParaFecha datetime,
    @NoValidarSiEsListaCalculada bit = 0
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
if @VigenciaParaFecha = ''
	set @VigenciaParaFecha = GETDATE()


set @retorno = (select top 1 CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end 
	from ( select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = @P_COLORES ) and ( p.TALLE = @P_TALLE ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by FECHAVIG desc, TIMESTAMPA DESC 
UNION ALL 
select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end  as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = @P_COLORES  ) and ( p.TALLE = '' ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by FECHAVIG desc, TIMESTAMPA DESC 
UNION ALL 
select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end  as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = '' ) and ( p.TALLE = @P_TALLE ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by FECHAVIG desc, TIMESTAMPA DESC 
UNION ALL 
select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end  as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = '' ) and ( p.TALLE = '' ) and  p.FECHAVIG <= @VigenciaParaFecha 
	order by FECHAVIG desc, TIMESTAMPA DESC ) 
 p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = '' or p.COLORES = @P_COLORES ) and ( p.TALLE = '' or p.TALLE = @P_TALLE ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by ( case p.PDirecto when 0 then 0 else 1 end ) desc, p.FECHAVIG desc, p.TIMESTAMPA desc )

	return @retorno
end

GO;

IF OBJECT_ID(N'[Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]') is not null DROP FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]
(
    @P_ARTICULO Varchar( 23 ), 
    @P_COLORES Varchar( 12 ), 
    @P_TALLE Varchar( 13 ), 
    @CodigoLPrecio Varchar(6), 
    @VigenciaParaFecha datetime,
    @NoValidarSiEsListaCalculada bit = 0
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
if @VigenciaParaFecha = ''
	set @VigenciaParaFecha = GETDATE()


if @NoValidarSiEsListaCalculada = 0
	BEGIN
		DECLARE @ListaDePrecios TABLE (ListaBase char(6), PCalculado bit, Operador char(1), Coeficiente numeric(15,2), MonedaCotiz char(10), Redondeo numeric(1), Cantidad numeric(2))
		DECLARE @Calculada bit
		insert into @ListaDePrecios select LISTABASE, PCALCULADO, OPERADOR, COEFICIENT, MONEDACOTI, TREDONDEO, CANTIDAD from ZOOLOGIC.LPRECIO where LPR_NUMERO = @CodigoLPrecio;
		select @Calculada = pCalculado from @ListaDePrecios
		if @Calculada = 1
  			select @CodigoLPrecio = ListaBase from @ListaDePrecios
	END

set @retorno = (select isnull((select top 1 CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end 
	from ( select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = @P_COLORES ) and ( p.TALLE = @P_TALLE ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by FECHAVIG desc, TIMESTAMPA DESC 
UNION ALL 
select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end  as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = @P_COLORES  ) and ( p.TALLE = '' ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by FECHAVIG desc, TIMESTAMPA DESC 
UNION ALL 
select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end  as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = '' ) and ( p.TALLE = @P_TALLE ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by FECHAVIG desc, TIMESTAMPA DESC 
UNION ALL 
select top 1 ARTICULO, COLORES, TALLE, FECHAVIG, CODIGO, LISTAPRE, TIMESTAMPA, CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end  as PDIRECTO
	from ZOOLOGIC.PRECIOAR p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = '' ) and ( p.TALLE = '' ) and  p.FECHAVIG <= @VigenciaParaFecha 
	order by FECHAVIG desc, TIMESTAMPA DESC ) 
 p inner join ZOOLOGIC.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and ( p.COLORES = '' or p.COLORES = @P_COLORES ) and ( p.TALLE = '' or p.TALLE = @P_TALLE ) and  p.FECHAVIG <= @VigenciaParaFecha
	order by ( case p.PDirecto when 0 then 0 else 1 end ) desc, p.FECHAVIG desc, p.TIMESTAMPA desc ), 0))
    
    if @NoValidarSiEsListaCalculada = 0 and @Calculada = 1
    	BEGIN
    		declare @Operador char(1), @Coeficiente numeric(15,2), @MonedaCotiz char(10), @TipoRedondeo numeric(1), @CantRedondeo numeric(2)
    		select @Operador = Operador from @ListaDePrecios
    		select @Coeficiente = Coeficiente from @ListaDePrecios
    		select @MonedaCotiz = MonedaCotiz from @ListaDePrecios
    		select @TipoRedondeo = Redondeo from @ListaDePrecios
    		select @CantRedondeo = Cantidad from @ListaDePrecios
    		if coalesce(@VigenciaParaFecha, '') = ''
    			set @VigenciaParaFecha = getdate()
    		set @retorno = coalesce( Funciones.ObtenerPrecioDeLaCombinacionConVigenciaAlMomento( @retorno, @VigenciaParaFecha, @Operador, @Coeficiente, @MonedaCotiz, @TipoRedondeo, @CantRedondeo ), 0 )
    	END

	return @retorno
end

GO;

IF OBJECT_ID(N'[Funciones].[ObtenerTimestampVigenteDeLaCombinacion]') is not null DROP FUNCTION [Funciones].[ObtenerTimestampVigenteDeLaCombinacion]
GO;

CREATE FUNCTION [Funciones].[ObtenerTimestampVigenteDeLaCombinacion]
(
    @P_ARTICULO Varchar( 23 ), 
    @P_COLORES Varchar( 12 ), 
    @P_TALLE Varchar( 13 ), 
    @CodigoLPrecio Varchar(6), 
    @VigenciaParaFecha datetime
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
    
    set @retorno = 
        (
        select top 1
                prc.TIMESTAMPA
            from ZOOLOGIC.PRECIOAR prc
            where 1=1
                and prc.LISTAPRE = @CodigoLPrecio
                and prc.ARTICULO = @P_ARTICULO
                and prc.COLORES = @P_COLORES
                and prc.talle = @P_TALLE
                and prc.FECHAVIG <= case when coalesce(@VigenciaParaFecha, '') = '' then getdate() else @VigenciaParaFecha end
        	order by sign( prc.PDIRECTO ) desc, prc.FECHAVIG desc, prc.TIMESTAMPA desc
        )

	return @retorno
end

GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZOOLOGIC].[UPDATE_INSERT_PRECIOAR]') AND type in (N'TR'))
DROP TRIGGER [ZOOLOGIC].[UPDATE_INSERT_PRECIOAR]
GO;

CREATE TRIGGER [ZOOLOGIC].[UPDATE_INSERT_PRECIOAR] ON [ZOOLOGIC].[PRECIOAR]
	AFTER UPDATE, INSERT
As

Begin
	Declare
		 @ListaDependiente Varchar( 6 )
		,@ListaOrigen Varchar( 6 )
		,@Expresion nVarchar( 4000 )
		,@VigenciaParaFecha date
		,@Cant smallint
		,@i smallint
		,@Tabla dtTablaFiltro
		,@CodigoFormula varchar( 200 )
		,@id numeric( 10 )
		,@Proveedor varchar( 10 )

		Select ARTICULO, COLORES, TALLE, FALTAFW, HALTAFW, FMODIFW, HMODIFW, UALTAFW, UMODIFW, SALTAFW, SMODIFW, BDALTAFW, BDMODIFW, VALTAFW, VMODIFW, DESCFW, LISTAPRE,CODORI, ENTORI, FECHAVIG, TIMESTAMPA into #PreciosModificados from inserted
	if ( Select count( * ) from #PreciosModificados ) > 0
	begin
		select	LPCal.LPC_LISTA as ListaDependiente,
				LPDep.Formula,
				LPCal.LPC_PROV as Proveedor,
				F.ExprSql,
				LPDep.ListaDePrecios as ListaOrigen,
				row_number() over (order by LPCal.LPC_LISTA,LPCal.LPC_PROV) as id
		Into #ListasDependientes
		from [Funciones].[ObtenerListasDependientes]() LPDep
		Inner Join ZOOLOGIC.LCALCULADA LPCal
			ON	LPCal.LPC_FORM = LPDep.Formula
		Inner Join ZOOLOGIC.FORMULA F
			ON	F.CODIGO = LPCal.LPC_Form
		order by ListaDependiente,Proveedor

		Delete #ListasDependientes where #ListasDependientes.ListaOrigen not in ( Select distinct ListaPre from #PreciosModificados )
		Select @i = 1, @Cant = Count(*) from #ListasDependientes

		Select top 1 @VigenciaParaFecha = FechaVig from #PreciosModificados
		select proveedor , ListaDependiente into #ProveedoresExcluidos from #ListasDependientes where 0=1

		while @i <= @Cant
		begin
			Select top 1 @id = id + abs(CHECKSUM(left(Proveedor,1))), @ListaDependiente = ListaDependiente, @ListaOrigen = ListaOrigen, @Expresion = ExprSql, @CodigoFormula = Formula, @Proveedor = Proveedor from #ListasDependientes
			if (@Proveedor = '')
			begin
				insert into #ProveedoresExcluidos ( proveedor, ListaDependiente ) select proveedor,ListaDependiente from #ListasDependientes where ListaDependiente=@ListaDependiente and Proveedor != ''
			end

			insert into @Tabla
			Select PM.ARTICULO, PM.COLORES, PM.TALLE, PM.FALTAFW, PM.HALTAFW, PM.FMODIFW, PM.HMODIFW, PM.UALTAFW, PM.UMODIFW, PM.SALTAFW, PM.SMODIFW, PM.BDALTAFW, PM.BDMODIFW, PM.VALTAFW, PM.VMODIFW, PM.CODORI, PM.ENTORI, PM.FECHAVIG, PM.TIMESTAMPA+@id as TIMESTAMPA, PM.DESCFW
				From #PreciosModificados as PM
				left join ART on PM.ARTICULO = art.ARTCOD
				where LISTAPRE = @ListaOrigen and ( (art.ARTFAB = @Proveedor) or (RTRIM(LTRIM(@Proveedor))='') )
					and art.ARTFAB not in (select proveedor from #ProveedoresExcluidos )

			Exec [Funciones].[sp_ModificarCombinacionesConPrecioNuevoSegunExpresion] @Expresion, @ListaDependiente, @VigenciaParaFecha, @Tabla, @CodigoFormula

			Delete from @Tabla
			Delete from #ListasDependientes Where #ListasDependientes.ListaDependiente = @ListaDependiente and ListaOrigen = @ListaOrigen and Proveedor = @Proveedor
			Delete from #ProveedoresExcluidos
			set @i = @i + 1
		end

		drop table #ListasDependientes
		drop table #ProveedoresExcluidos 
		drop table #PreciosModificados

	end
END

GO;

if [Funciones].[EsBaseDeReplica]() = 1
DROP TRIGGER [ZOOLOGIC].[UPDATE_INSERT_PRECIOAR]
GO;

