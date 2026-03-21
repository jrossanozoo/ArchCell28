IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerSiHabilitaStockSeniado]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerSiHabilitaStockSeniado];
GO;

CREATE FUNCTION [Funciones].[ObtenerSiHabilitaStockSeniado]
	( )
RETURNS bit
AS
BEGIN

	declare @retorno bit

	set @retorno =
		case when (select s.valor from Parametros.Sucursal s where s.IDUNICO = '131596DD31D99514CF2194DB15285238793381') = '.T.' and 
				  (select s.valor from Parametros.Sucursal s where s.IDUNICO = '10558859E1A19C14F3F198F611552679120111') = '.T.' 
			 then 1  else 0 end 

	return @retorno
END

