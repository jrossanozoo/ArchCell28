IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerCostoDelStockEnProcesoSegunCosteo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP function [Contabilidad].[CMV_ObtenerCostoDelStockEnProcesoSegunCosteo];
GO;

CREATE FUNCTION [Contabilidad].[CMV_ObtenerCostoDelStockEnProcesoSegunCosteo]
(
	@Articulo char(15),
	@Color char(6),
	@Talle char(5),
	@MetodoCMV varchar(4),
	@tblStock as Contabilidad.udt_TableType_CMVStockComp READONLY
) 
RETURNS @Retorno TABLE
(
	id int,
	Cantidad numeric(15,2),
	Costo numeric(15,2),
	RelaFactTipo numeric(2,0), 
	RelaLetra varchar(2), 
	RelaPtoVenta numeric(5,0), 
	RelaNumComp numeric(8,0), 
	RelaComprobante varchar(200),
	CostoUnitario numeric(15,2),
	CostoTotal numeric(15,2)
)
BEGIN
	/*Se busca dentro del stock obtenido en la tabla c_Stock recibida como @tblStock desde la función [CMV_ObtenerLosComprobantesDeStockEntreFechas] 
	el stock y los costos correspondiente a la combinacion y el metodo de costeo pasados por parametros. */	

	if @MetodoCMV = 'PEPS'
		BEGIN
			INSERT INTO @Retorno ( Id, Cantidad, Costo, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprobante, CostoUnitario, CostoTotal )
			SELECT TOP 1 Id, Cantidad, Costo, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprob, 0, 0 
			FROM @tblStock 
			WHERE Cantidad > 0 and Articulo = @Articulo and ( ( @Color is null ) OR ( Color = @Color ) ) and ( ( @Talle is null ) OR ( Talle = @Talle ) ) 
			ORDER BY Id
		END

	if @MetodoCMV = 'UEPS' 
		BEGIN 
			INSERT INTO @Retorno ( Id, Cantidad, Costo, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprobante, CostoUnitario, CostoTotal ) 
			SELECT TOP 1 Id, Cantidad, Costo, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprob, 0, 0 
			FROM @tblStock 
			WHERE Cantidad > 0 and Articulo = @Articulo and ( ( @Color is null ) OR ( Color = @Color ) ) and ( ( @Talle is null ) OR ( Talle = @Talle ) ) 
			ORDER BY Id DESC
		END

	if @MetodoCMV = 'PPP'
		BEGIN 
			INSERT INTO @Retorno ( Id, Cantidad, Costo, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprobante, CostoUnitario, CostoTotal ) 
			SELECT TOP 1 Id, Stock, Costo, RelaFactTipo, RelaLetra, RelaPtoVenta, RelaNumComp, RelaComprob, CostoUnitarioInventario, CostoTotalInventario 
			FROM @tblStock 
			WHERE Articulo = @Articulo and ( ( @Color is null ) OR ( Color = @Color ) ) and ( ( @Talle is null ) OR ( Talle = @Talle ) ) 
			ORDER BY Id DESC
		END

	RETURN
END

