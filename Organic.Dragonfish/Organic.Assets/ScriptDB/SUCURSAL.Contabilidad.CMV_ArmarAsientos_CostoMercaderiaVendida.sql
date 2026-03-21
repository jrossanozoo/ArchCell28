IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ArmarAsientos_CostoMercaderiaVendida]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP function [Contabilidad].[CMV_ArmarAsientos_CostoMercaderiaVendida];
GO;

CREATE FUNCTION [Contabilidad].[CMV_ArmarAsientos_CostoMercaderiaVendida]
(
	@FechaDesde as DateTime, 
	@FechaHasta as DateTime,
	@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly,
	@tblResultadoCMV as Contabilidad.udt_TableType_CMVInfoResultado ReadOnly
)
RETURNS TABLE
AS
RETURN
(
	/* Arma un asiento base por cada comprobante afectado por el costo de la mercaderia vendida segun el asinto tipo */

	select 
		asietipo.codigo as CodigoAsientoTipo, 
		convert(date,cab.Fecha) as FechaAsiento, 
		'' as TipoComp,
		'' as LetraComp,
		convert(char(150), ltrim(rtrim( cab.CompDesc))) as Referencia,
		cab.Codigo, 
		case 
			when asietipo.CodConc = 'COSTOMERCVEND' and asietipo.CodConc is not null then asietipo.cuentade 
			when asietipo.CodConc = 'INVENTARIO' and asietipo.CodConc is not null then asietipo.cuentade 
			else '' end CuentaDebe,
		case 
			when asietipo.CodConc = 'COSTOMERCVEND' and asietipo.CodConc is not null then asietipo.cuentaha 
			when asietipo.CodConc = 'INVENTARIO' and asietipo.CodConc is not null then asietipo.cuentaha 
			else '' end CuentaHaber,
		'' as CentroDeCostos,
		case 
			when asietipo.CodConc = 'COSTOMERCVEND' then cab.Monto * (-1)
			when asietipo.CodConc = 'INVENTARIO' then cab.Monto * (-1)
			else 0 end  as Monto
	from (
			select CompCodigo as Codigo, Referencia, Fecha, CompTipo as Tipo, CompDesc, sum(Cantidad * CostoUnitario) as Monto 
			from @tblResultadoCMV
			group by CompCodigo, Referencia, Fecha, CompTipo, CompDesc
		) cab
	cross join ( 
		select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'CMV' 
		) asietipo
	where 1=1
		and cab.Fecha between @FechaDesde and @FechaHasta 
		and left( ltrim( Referencia) , 1 ) = '2'
		and cab.Tipo in (1, 2, 3, 4, 5, 27, 28, 29, 33, 35, 36, 47, 48, 49, 51, 52, 53, 54, 55, 56, 11) 
)

