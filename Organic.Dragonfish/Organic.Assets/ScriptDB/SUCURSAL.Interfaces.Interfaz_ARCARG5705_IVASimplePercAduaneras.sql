IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_ARCARG5705_IVASimplePercAduaneras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_ARCARG5705_IVASimplePercAduaneras];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_ARCARG5705_IVASimplePercAduaneras]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@FechaEmisionDesde varchar(10),
	@FechaEmisionHasta varchar(10)
)
RETURNS TABLE
AS
RETURN

(
	select 
		c_imp.regimenimp AS Regimen
		,Funciones.padl( cast( year( convert( date, c_compras.FFchFac ) ) as varchar(4) ), 4, '0' ) + '-' + 
			Funciones.padl( cast( month( convert( date, c_compras.FFchFac ) ) as varchar(2) ), 2, '0' ) + '-' + 
			Funciones.padl( cast( day( convert( date, c_compras.FFchFac ) ) as varchar(2) ), 2, '0' ) as FechaPercep
		,case when c_tipocomp.despacho is null then '' else left(c_tipocomp.despacho, 2 ) + '-' + substring(c_tipocomp.despacho,3,3) + '-' + substring(c_tipocomp.despacho,6,4) + '-' + substring(c_tipocomp.despacho,10,6) + '-' + right(c_tipocomp.despacho, 1 ) end as NroDespacho  --  06 001 IC01 000001 A.
		,replace( cast( c_PercCompras.monto as varchar(15) ), '.', ',') as Importe
		,c_compras.DESCFW as NroComprob 
	from zoologic.impfacc as c_PercCompras
	left join zoologic.IMPUESTO c_imp ON c_imp.codigo = c_PercCompras.codimp
	left join zoologic.faccompra as c_compras on c_compras.codigo = c_PercCompras.ccod
	left join zoologic.tipocompcom c_tipocomp on c_tipocomp.codigoCor = c_compras.codigo
	where C_IMP.tipo ='IVA' 
		and C_IMP.aplicacion = 'PRC' 
		and c_Compras.TCRG1361 = 4 
		and c_Compras.Anulado = 0
		and ( ( @FechaEmisionDesde is null ) or ( c_compras.FFchFac >= @FechaEmisionDesde ) )  
		and ( ( @FechaEmisionHasta is null ) or ( c_compras.FFchFac <= @FechaEmisionHasta ) )
		and ( ( @FechaDesde is null ) or ( c_compras.Ffch >= @FechaDesde ) ) 
		and ( ( @FechaHasta is null ) or ( c_compras.Ffch <= @FechaHasta ) )
)
 