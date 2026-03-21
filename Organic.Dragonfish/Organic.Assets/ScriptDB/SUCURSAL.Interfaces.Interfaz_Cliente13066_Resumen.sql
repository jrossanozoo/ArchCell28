IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[interfaces].[Interfaz_Cliente13066_Resumen]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [interfaces].[Interfaz_Cliente13066_Resumen];
GO;

CREATE FUNCTION [interfaces].[Interfaz_Cliente13066_Resumen]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@CodigoProveedor varchar(10)
)
RETURNS TABLE
AS
RETURN
(
select 
	DatosExpo.Retail_Weekend_Date,
	DatosExpo.Retail_Week_Year,
	DatosExpo.Reporting_Unit,
	DatosExpo.BCS_Store_Code,
	DatosExpo.Currency,
	DatosExpo.Traffic_Count,
	DatosExpo.Number_Of_Sales_Transaction,
	DatosExpo.Correction_Of_Invoice
from [Interfaces].[Datos_Cliente13066_Resumen](@FechaDesde, @FechaHasta, @CodigoProveedor) as DatosExpo
)