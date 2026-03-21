IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerComprobantesAfectadosPorNC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP function [Contabilidad].[CMV_ObtenerComprobantesAfectadosPorNC];
GO;

CREATE FUNCTION [Contabilidad].[CMV_ObtenerComprobantesAfectadosPorNC]
(
	@Articulo char(15),
	@Color char(6),
	@Talle char(5),
	@CompAsoc varchar(200),
	@FechaMov datetime,
	@tblMovimientos as Contabilidad.udt_TableType_CMVMovimientos READONLY
) 
RETURNS @Retorno TABLE
	(
		id int,
		Cantidad numeric(15,2),
		Costo numeric(15,2),
		fecha datetime,
		CantidadAfectada numeric(15,2), 
		RelaFactTipo numeric(2,0), 
		RelaLetra varchar(2), 
		RelaPtoVenta numeric(5,0), 
		RelaNumComp numeric(8,0), 
		RelaComprobante varchar(200)
	)
BEGIN
	/*Se busca entre los movimientos ya procesados en la tabla c_final recibida como @tblMovimientos desde la función [CMV_ObtenerLosComprobantesDeStockEntreFechas] 
	las facturas que fueron afectadas por el comprobante asociado recibido como parámetro */	

	insert into @Retorno ( id, cantidad, costo, fecha, CantidadAfectada, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprobante )
	select id, Cantidad, Precio, Fecha, coalesce(NCStockAfectado, 0) as CantidadAfectada 
		, coalesce(RelaFactTipo, 0) as RelaFactTipo, coalesce(RelaLetra, '') as RelaLetra 
		, coalesce(RelaPtoVenta, 0) as RelaPtoVenta, coalesce(RelaNumComp, 0) as RelaNumComp, coalesce(RelaComprob, '') as RelaComprob
	from @tblMovimientos
		where Comprobante = @CompAsoc
			and ( ( @Articulo is null ) OR ( Articulo = @Articulo ) )
			and ( ( @Color is null ) OR ( Color = @Color ) )
			and ( ( @Talle is null ) OR ( talle = @Talle ) )
			and Fecha <= @FechaMov
	
	RETURN
END

