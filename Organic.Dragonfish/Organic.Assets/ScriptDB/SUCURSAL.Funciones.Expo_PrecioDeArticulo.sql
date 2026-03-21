IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Expo_PrecioDeArticulo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[Expo_PrecioDeArticulo];
GO;

CREATE FUNCTION [Funciones].[Expo_PrecioDeArticulo]
( 
	@PrecioVigenteAl datetime,
	@ArticuloDesde char(15),
	@ArticuloHasta char(15),
	@ColorDesde char(6),
	@ColorHasta char(6),
	@TalleDesde char(5),
	@TalleHasta char(5), 
	@ListaPrecioDesde char(6),
	@ListaPrecioHasta char(6),
	@Delimitador char(3)
)
RETURNS TABLE
AS
RETURN
(
select cast( DatosExpo.Articulo + @Delimitador as varchar(18) ) as Articulo,
		cast( DatosExpo.ArticuloDesc + @Delimitador as varchar(103) ) as ArticuloDesc,
		cast( DatosExpo.Color + @Delimitador as varchar(9) ) as Color,
		cast( DatosExpo.ColorDesc + @Delimitador as varchar(53) ) as ColorDesc, 
		cast( DatosExpo.Talle + @Delimitador as varchar(8) ) as Talle,
		cast( DatosExpo.TalleDesc + @Delimitador as varchar(53) ) as TalleDesc, 
		cast( DatosExpo.ListaDePrecio + @Delimitador as varchar(9) ) as ListaDePrecio, 
		cast( DatosExpo.ListaDePrecioDesc + @Delimitador as varchar(33) ) as ListaDePrecioDesc, 
		DatosExpo.Precio as Precio,
		cast( @Delimitador + cast( DatosExpo.AnioFecha + DatosExpo.MesFecha + DatosExpo.DiaFecha as varchar(8)) + @Delimitador as varchar(14) ) as FechaDeVigencia,
		cast( DatosExpo.Observaciones as varchar(100) ) as Observaciones
from
	(

	select Funciones.alltrim( c_PRECIODEARTICULO.ARTICULO ) as Articulo,
			case when c_ARTICULO.ARTDES is null then '' else Funciones.alltrim( c_ARTICULO.ARTDES ) end as ArticuloDesc,
			Funciones.alltrim( c_PRECIODEARTICULO.CCOLOR ) as Color,
			case when c_COLOR.COLDES is null then '' else Funciones.alltrim( c_COLOR.COLDES ) end as ColorDesc, 
			Funciones.alltrim( c_PRECIODEARTICULO.TALLE ) as Talle,
			case when c_TALLE.DESCRIP is null then '' else Funciones.alltrim( c_TALLE.DESCRIP ) end as TalleDesc, 
			Funciones.alltrim( c_PRECIODEARTICULO.LISTAPRE ) as ListaDePrecio, 
			case when c_LPRECIO.LPR_NOMBRE is null then '' else Funciones.alltrim( c_LPRECIO.LPR_NOMBRE ) end as ListaDePrecioDesc, 
			c_PRECIODEARTICULO.PDIRECTO as Precio,
			Funciones.padl( cast( day( convert( date, c_PRECIODEARTICULO.FECHAVIG ) ) as varchar(2) ), 2, '0' ) as DiaFecha,
			Funciones.padl( cast( month( convert( date, c_PRECIODEARTICULO.FECHAVIG ) ) as varchar(2) ), 2, '0' ) as MesFecha,
			Funciones.padl( cast( year( convert( date, c_PRECIODEARTICULO.FECHAVIG ) ) as varchar(4) ), 4, '0' ) as AnioFecha,	
			Funciones.alltrim( c_PRECIODEARTICULO.OBS ) as Observaciones
		from ZooLogic.PRECIOAR as c_PRECIODEARTICULO
			left join [ZooLogic].[Art] as c_ARTICULO on c_PRECIODEARTICULO.ARTICULO = c_ARTICULO.ArtCod
			left join [ZooLogic].[Col] as c_COLOR on c_PRECIODEARTICULO.CCOLOR = c_COLOR.ColCod
			left join [ZooLogic].[Talle] as c_TALLE on c_PRECIODEARTICULO.TALLE = c_TALLE.Codigo
			left join [ZooLogic].[LPrecio] as c_LPRECIO on c_PRECIODEARTICULO.LISTAPRE = c_LPRECIO.LPR_NUMERO
		where ( not 1 = funciones.empty( c_PRECIODEARTICULO.CODIGO ) ) 
			and c_PRECIODEARTICULO.ARTICULO between @ArticuloDesde and @ArticuloHasta 
			and c_PRECIODEARTICULO.CCOLOR between @ColorDesde and @ColorHasta
			and c_PRECIODEARTICULO.TALLE between @TalleDesde and @TalleHasta
			and c_PRECIODEARTICULO.LISTAPRE between @ListaPrecioDesde and @ListaPrecioHasta
			and funciones.eselpreciovigentealafecha(c_PRECIODEARTICULO.CODIGO, c_PRECIODEARTICULO.LISTAPRE, c_PRECIODEARTICULO.ARTICULO, c_PRECIODEARTICULO.CCOLOR, c_PRECIODEARTICULO.TALLE, @PrecioVigenteAl ) = 1
	
	UNION

	select Funciones.alltrim( c_PRECIODEARTICULO.ARTICULO ) as Articulo,
	case when c_ARTICULO.ARTDES is null then '' else Funciones.alltrim( c_ARTICULO.ARTDES ) end as ArticuloDesc,
	Funciones.alltrim( c_PRECIODEARTICULO.CCOLOR ) as Color,
	case when c_COLOR.COLDES is null then '' else Funciones.alltrim( c_COLOR.COLDES ) end as ColorDesc, 
	Funciones.alltrim( c_PRECIODEARTICULO.TALLE ) as Talle,
	case when c_TALLE.DESCRIP is null then '' else Funciones.alltrim( c_TALLE.DESCRIP ) end as TalleDesc, 
	Funciones.alltrim( c_LPRECIO.LPR_NUMERO ) as ListaDePrecio, 
	case when c_LPRECIO.LPR_NOMBRE is null then '' else Funciones.alltrim( c_LPRECIO.LPR_NOMBRE ) end as ListaDePrecioDesc, 
	Funciones.ObtenerPrecioDeLaCombinacionConVigenciaAlMomento(c_PRECIODEARTICULO.PDIRECTO, @PrecioVigenteAl, c_LPRECIO.Operador, c_LPRECIO.Coeficient, c_LPRECIO.MonedaCoti, c_LPRECIO.TRedondeo, c_LPRECIO.Cantidad) as Precio,
	Funciones.padl( cast( day( convert( date, c_PRECIODEARTICULO.FECHAVIG ) ) as varchar(2) ), 2, '0' ) as DiaFecha,
	Funciones.padl( cast( month( convert( date, c_PRECIODEARTICULO.FECHAVIG ) ) as varchar(2) ), 2, '0' ) as MesFecha,
	Funciones.padl( cast( year( convert( date, c_PRECIODEARTICULO.FECHAVIG ) ) as varchar(4) ), 4, '0' ) as AnioFecha,	
	Funciones.alltrim( c_PRECIODEARTICULO.OBS ) as Observaciones
from Zoologic.LPRECIO as c_LPRECIO
	left join [Zoologic].[PRECIOAR] as c_PRECIODEARTICULO On c_PRECIODEARTICULO.LISTAPRE = c_LPRECIO.LISTABASE 
		and c_PRECIODEARTICULO.Articulo between @ArticuloDesde and @ArticuloHasta 
		and c_PRECIODEARTICULO.CCOLOR between @ColorDesde and @ColorHasta
		and c_PRECIODEARTICULO.TALLE between @TalleDesde and @TalleHasta
	left join [ZooLogic].[Art] as c_ARTICULO on c_PRECIODEARTICULO.ARTICULO = c_ARTICULO.ArtCod
	left join [ZooLogic].[Col] as c_COLOR on c_PRECIODEARTICULO.CCOLOR = c_COLOR.ColCod
	left join [ZooLogic].[Talle] as c_TALLE on c_PRECIODEARTICULO.TALLE = c_TALLE.Codigo
where c_LPRECIO.PCALCULADO = 1 
	and c_LPRECIO.LPR_NUMERO  between @ListaPrecioDesde and @ListaPrecioHasta
	and funciones.eselpreciovigentealafecha(c_PRECIODEARTICULO.CODIGO, c_PRECIODEARTICULO.LISTAPRE, c_PRECIODEARTICULO.ARTICULO, c_PRECIODEARTICULO.CCOLOR, c_PRECIODEARTICULO.TALLE, @PrecioVigenteAl ) = 1	
	) as DatosExpo

)