IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerValorDeConversionSegunBaseDeDatos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerValorDeConversionSegunBaseDeDatos];
GO;

CREATE FUNCTION [Funciones].[ObtenerValorDeConversionSegunBaseDeDatos]
	(
	@Conversion varchar(max),
	@BaseDeDatos varchar(8),
	@Valor varchar(max)
	)
RETURNS varchar(max)
AS
BEGIN
	declare @Anterior varchar(23),
			@Grupo varchar(21),
			@ValorConversion varchar(max),
			@Existe bit
	declare @BasesDelAgrup table (Base varchar(max))

	/*PARA BUSCAR AGRUPAMIENTOS*/

	set @anterior = (select top 1 basedatos from organizacion.converval where conversion = @Conversion and BASEDATOS like '\[%' ESCAPE '\' and VALORIG = @Valor order by basedatos)

	while (@anterior <> '')
	begin
		set @grupo = right(left(@anterior,len(@anterior)-1), len(left(@anterior,len(@anterior)-1)) - 1)  
		delete from @BasesDelAgrup
		insert into @BasesDelAgrup SELECT DISTINCT RTRIM(BASEDEDATO) Base FROM [PUESTO].[AGRUPBD] WHERE Codigo = @Grupo and Incluye = 1
		set @existe = case when (select top 1 Base from @BasesDelAgrup where base = @BaseDeDatos) <> '' then 1 else 0 end

		if @existe = 1
		begin
			set @ValorConversion = (select codigo from ORGANIZACION.CONVERVAL where conversion = @Conversion and basedatos = @anterior and VALORIG = @Valor)
			return @ValorConversion
		end
		set @anterior = (select top 1 basedatos from organizacion.converval where conversion = @Conversion and BASEDATOS like '\[%' ESCAPE '\' and basedatos > @anterior and VALORIG = @Valor order by basedatos) 
	end

	/*PARA BUSCAR POR BASE*/

	set @ValorConversion = (select codigo from ORGANIZACION.CONVERVAL where conversion = @Conversion and basedatos = @BaseDeDatos and VALORIG = @Valor)

	if @ValorConversion <> ''
	begin
		return @ValorConversion
	end

	set @ValorConversion = (select codigo from ORGANIZACION.CONVERVAL where conversion = @Conversion and basedatos = '' and VALORIG = @Valor)

	return @ValorConversion

END