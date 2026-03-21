IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[interfaces].[Datos_Cliente13066_Resumen]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [interfaces].[Datos_Cliente13066_Resumen];
GO;

CREATE FUNCTION [interfaces].[Datos_Cliente13066_Resumen]
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
	DatosExpoAvanzados.Retail_Weekend_Date,
	DatosExpoAvanzados.Retail_Week_Year,
	DatosExpoAvanzados.Reporting_Unit,
	DatosExpoAvanzados.BCS_Store_Code,
	DatosExpoAvanzados.Currency,
	DatosExpoAvanzados.Traffic_Count,
	sum(DatosExpoAvanzados.Number_Of_Sales_Transaction) as Number_Of_Sales_Transaction,
	DatosExpoAvanzados.Correction_Of_Invoice
from (
	select 
		DatosExpoBasicos.Fecha as Retail_Weekend_Date,
		cast(DATEPART(wk, DatosExpoBasicos.Fecha) as varchar(2)) + cast(substring(DatosExpoBasicos.Fecha, 1, 4) as varchar(4)) as Retail_Week_Year,
		DatosExpoBasicos.ConversionAReportingUnit as Reporting_Unit,
		DatosExpoBasicos.ConversionAStoreCode as BCS_Store_Code,
		'ARS' as Currency,
		'0' as Traffic_Count,
		CantidadVendida as Number_Of_Sales_Transaction,
		'0' as Correction_Of_Invoice
	from(
		select distinct
			@FechaHasta as Fecha,
			case when REPORTINGUNIT_valconv.ValDest is null then SUBSTRING(DB_NAME(), 12, 8) else REPORTINGUNIT_valconv.ValDest end as ConversionAReportingUnit,
			case when STORECODE_valconv.ValDest is null then SUBSTRING(DB_NAME(), 12, 8) else STORECODE_valconv.ValDest end as ConversionAStoreCode,
			Articulo.ARTCOD,
			DetalleComprobante.CCOLOR,
			DetalleComprobante.AFECANT * Comprobante.SIGNOMOV as CantidadVendida
		from ZooLogic.ART as Articulo
		left join (select Codigo, Fart, ccolor, Afecant
					from ZooLogic.COMPROBANTEVDET) as DetalleComprobante on Articulo.ARTCOD = DetalleComprobante.FART
		left join ZooLogic.COMPROBANTEV as Comprobante on DetalleComprobante.CODIGO = Comprobante.CODIGO
		left join (select coart, sum(cocant) as COCANT, COCOL
					from ZooLogic.comb
					group by coart, COCOL) as Stock on Articulo.ARTCOD = Stock.COART and (DetalleComprobante.ccolor = Stock.cocol or DetalleComprobante.ccolor is null)
		left join [Organizacion].[ConverVal] as REPORTINGUNIT_valconv on REPORTINGUNIT_valconv.Conversion = '13066REPORTINGUNIT' and REPORTINGUNIT_valconv.ValOrig = SUBSTRING(DB_NAME(), 12, 8)
		left join [Organizacion].[ConverVal] as STORECODE_valconv on STORECODE_valconv.Conversion = '13066STORECODE' and STORECODE_valconv.ValOrig = SUBSTRING(DB_NAME(), 12, 8)
		where ( ( Comprobante.FACTTIPO in (1, 3, 4, 2, 5, 6, 27, 28, 29)
			and Comprobante.FFch between @FechaDesde and @FechaHasta
			and Comprobante.ANULADO = 0
			and Articulo.BLOQREG = 0 ) or Stock.Cocant <> 0)
			and Articulo.ARTFAB = @CodigoProveedor
	) as DatosExpoBasicos
) as DatosExpoAvanzados
group by
	DatosExpoAvanzados.Retail_Weekend_Date,
	DatosExpoAvanzados.Retail_Week_Year,
	DatosExpoAvanzados.Reporting_Unit,
	DatosExpoAvanzados.BCS_Store_Code,
	DatosExpoAvanzados.Currency,
	DatosExpoAvanzados.Traffic_Count,
	DatosExpoAvanzados.Correction_Of_Invoice

)