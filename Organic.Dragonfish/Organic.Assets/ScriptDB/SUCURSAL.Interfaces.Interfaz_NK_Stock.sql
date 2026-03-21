IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_NK_Stock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_NK_Stock];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_NK_Stock]
( 
	@CodigoProveedor varchar(10),
	@ListaPrecioCompra varchar(6)
)
RETURNS TABLE
AS
RETURN
(
	select '"' + cast(DatosExpo.Sucursal as varchar(20)) + '"' as Sucursal,
		'"' + cast(DatosExpo.Articulo as varchar(20)) + '"' as Articulo,
		'"' + cast(DatosExpo.Talle as varchar(20)) + '"' as Talle,
		cast(DatosExpo.Cantidad as varchar(6)) as Cantidad,
		cast(DatosExpo.PrecioCompra as varchar(15)) as PrecioCompra
	from [Interfaces].[Datos_NK_Stock](@CodigoProveedor, @ListaPrecioCompra) as DatosExpo
)