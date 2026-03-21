IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_ArcibaVentasYPagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_ArcibaVentasYPagos];
GO;

create FUNCTION [interfaces].[Errores_ArcibaVentasYPagos]
( 
@FechaDesde as char(8),
@FechaHasta as char(8)
)
RETURNS TABLE
AS
RETURN 
(
	select * from  [interfaces].[Errores_ArcibaVentas](@FechaDesde,@FechaHasta)
	union all
	select * from  [interfaces].[Errores_ArcibaPagos](@FechaDesde,@FechaHasta)
)


