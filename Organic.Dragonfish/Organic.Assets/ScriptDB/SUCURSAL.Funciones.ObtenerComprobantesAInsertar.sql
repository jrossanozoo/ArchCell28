IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerComprobantesAInsertar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerComprobantesAInsertar];
GO;

create function [Funciones].[ObtenerComprobantesAInsertar]
(
	@Comprobante as varchar(40),
	@ClienteDesde as varchar(10),
	@ClienteHasta as varchar(10),
	@NumeroComprobanteDesde as Numeric(8),
	@NumeroComprobanteHasta as Numeric(8),
	@FechaComprobanteDesde as date,
	@FechaComprobanteHasta as date,
	@VendedorDesde as varchar(10),
	@VendedorHasta as varchar(10),
	@MotivoDesde as varchar(3),
	@MotivoHasta as varchar(3),
	@TransportistaDesde as varchar(15),
	@TransportistaHasta as varchar(15)
)
returns table
as
return
(
	select cast(Remitos.FLetra + Funciones.padl(cast(Remitos.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Remitos.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante, 
		Remitos.Codigo as Codigo, Remitos.FFch as Fecha, Remitos.FPerson as Cliente, Remitos.FVen as Vendedor
	from [ZooLogic].[ComprobanteV] as Remitos
	where Funciones.alltrim(@Comprobante) = 'REMITO'
		and Remitos.FactTipo = 11
		and Remitos.Anulado = 0
		and Funciones.alltrim(Remitos.FPerson) between @ClienteDesde and @ClienteHasta
		and Remitos.FNumComp between @NumeroComprobanteDesde and @NumeroComprobanteHasta
		and Remitos.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Remitos.FVen between @VendedorDesde and @VendedorHasta
		and Funciones.alltrim(Remitos.Motivo) between @MotivoDesde and @MotivoHasta
		and Funciones.alltrim(Remitos.FTransp) between @TransportistaDesde and @TransportistaHasta
		and Remitos.Codigo not in ( Select distinct Comprob from ZooLogic.EntMerDet )
)