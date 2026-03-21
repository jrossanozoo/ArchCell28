IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_NK_Stock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_NK_Stock];
GO;

CREATE FUNCTION [Interfaces].[Datos_NK_Stock]
(
	@CodigoProveedor varchar(10),
	@ListaPrecioCompra varchar(6)
)
RETURNS TABLE
AS
RETURN
(
	select DatosExpoIntermedios.Sucursal,
		case when DatosExpoIntermedios.ConversionArticulo = '-' then DatosExpoIntermedios.Articulo else DatosExpoIntermedios.ConversionArticulo end as Articulo,
		DatosExpoIntermedios.Talle,
		DatosExpoIntermedios.Cantidad,
		DatosExpoIntermedios.PrecioCompra
	from (
		select left(DatosExpoBasicos.ConversionSucursal, 6) as Sucursal,
			left(DatosExpoBasicos.Articulo, 13) as Articulo,
			left(DatosExpoBasicos.ConversionArticulo, 6) + '-' + left(DatosExpoBasicos.ConversionColor, 3) as ConversionArticulo,
			DatosExpoBasicos.ConversionTalle as Talle,
			DatosExpoBasicos.Cantidad,
			DatosExpoBasicos.PrecioCompra
		from (
			select Funciones.alltrim(Combinaciones.CoArt) as Articulo,
				cast(Combinaciones.CoCant as numeric(5,0)) as Cantidad,
				[Funciones].[ObtenerPrecioDeLaCombinacionPorListaDePrecio]( Combinaciones.CoArt, Combinaciones.CoCol, Combinaciones.Talle, @ListaPrecioCompra ) as PrecioCompra,
				case when NKNOMBREBASE_valconv.ValDest is null then Combinaciones.BDAltaFW else NKNOMBREBASE_valconv.ValDest end as ConversionSucursal,
				case when NKCODIGOARTICULO_valconv.ValDest is null then '' else Funciones.alltrim(NKCODIGOARTICULO_valconv.ValDest) end as ConversionArticulo,
				case when NKCOLOR_valconv.ValDest is null then '' else Funciones.alltrim(NKCOLOR_valconv.ValDest) end as ConversionColor,
				case when NKTALLE_valconv.ValDest is null then Funciones.alltrim(Combinaciones.Talle) else Funciones.alltrim(NKTALLE_valconv.ValDest) end as ConversionTalle
			from [ZooLogic].[Comb] as Combinaciones
				join [ZooLogic].[Art] as Articulos on Combinaciones.CoArt = Articulos.ArtCod and Articulos.ArtFab = @CodigoProveedor
				left join [Organizacion].[ConverVal] as NKNOMBREBASE_valconv on NKNOMBREBASE_valconv.Conversion = 'NKNOMBREBASE' and NKNOMBREBASE_valconv.ValOrig = Combinaciones.BDAltaFW
				left join [Organizacion].[ConverVal] as NKCODIGOARTICULO_valconv on NKCODIGOARTICULO_valconv.Conversion = 'NKCODIGOARTICULO' and NKCODIGOARTICULO_valconv.ValOrig = Combinaciones.CoArt
				left join [Organizacion].[ConverVal] as NKCOLOR_valconv on NKCOLOR_valconv.Conversion = 'NKCOLOR' and NKCOLOR_valconv.ValOrig = Combinaciones.CoCol
				left join [Organizacion].[ConverVal] as NKTALLE_valconv on NKTALLE_valconv.Conversion = 'NKTALLE' and NKTALLE_valconv.ValOrig = Combinaciones.Talle
			where Combinaciones.CoCant <> 0
		) as DatosExpoBasicos
	) as DatosExpoIntermedios
)