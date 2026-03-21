IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerConversionDeDatos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerConversionDeDatos];
GO;

CREATE FUNCTION [Funciones].[ObtenerConversionDeDatos]     
(  @CodigoConversion char(40), 
	@ValorOrigen char(100),
	@BaseDeDatos char(8)
)
	
RETURNS varchar(100)
AS
BEGIN
declare @retorno varchar(100)
set @retorno = ''

set @retorno = ( select ValDest from [Organizacion].[ConverVal] where conversion = @CodigoConversion and valorig = @ValorOrigen and BaseDatos = @BaseDeDatos )
if @retorno is null
	set @retorno = ( select ValDest from [Organizacion].[ConverVal] where conversion = @CodigoConversion and valorig = @ValorOrigen and BaseDatos = '        ' )
	if @retorno is null
		set @retorno = ( select
							case
								when accion = 'DEF' then ValorDef
								when accion = 'ORIGINAL' then @ValorOrigen
								when accion = 'CANCELAR' then ''
							end as ValorDestino
							from [Organizacion].[Conver] where codigo = @CodigoConversion );
return @retorno

end