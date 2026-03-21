IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaObtenerDescripcionComisionesAAplicar]') AND type = N'V')
DROP VIEW [Listados].[VistaObtenerDescripcionComisionesAAplicar];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionComisionesAAplicar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionComisionesAAplicar];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaResumenComisionesPorVenta]') AND type = N'V')
DROP VIEW [Listados].[VistaResumenComisionesPorVenta];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerResumenComisionesPorVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerResumenComisionesPorVentas];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ComisionesPorVentaPorFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ComisionesPorVentaPorFecha];
GO;
	
IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_Comisiones' AND is_table_type = 1 AND SCHEMA_ID('Listados') = schema_id)
	DROP TYPE Listados.udt_TableType_Comisiones;
GO;

CREATE TYPE Listados.udt_TableType_Comisiones AS TABLE
(
	[ORIGEN] [varchar](12) NULL,
	[CODIGO] [varchar](38) NULL,
	[IDITEM] [varchar](38) NULL,
	[fven] [char](10) NULL,
	[mas_antigua] [smallint] NULL,
	[mas_reciente] [smallint] NULL,
	[descripMAS_RECIENTE] [varchar](10) NULL,
	[MAYOR_MONTOF] [bit] NULL,
	[MAYOR_PORCENT] [bit] NULL,
	[MENOR_MONTOF] [bit] NULL,
	[MENOR_PORCENT] [bit] NULL,
	[comision] [char](20) NULL,
	[montof] [numeric](15, 2) NULL,
	[porcent] [numeric](7, 2) NULL
)
GO;

create function [Funciones].[ComisionesPorVentaPorFecha]
(
		@CodigoComprobante as varchar(38),
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime
	)
RETURNS TABLE
AS
RETURN
(
SELECT
	cast( 'Con comisión' as varchar(22)) ORIGEN
	, c_Comp.CODIGO
	, c_CDet.IDITEM
	, c_Comp.FVEN
	--, cast( case when c_Art.ARTCOD is null then 'BORRADO' else 'ACTIVO' end as varchar(8)) Estado_Articulo
	, cast( case when min(cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime)) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime) then 1 else 0 end as smallint ) MAS_ANTIGUA
	, cast( case when max(cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime)) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime) then 1 else 0 end as smallint ) MAS_RECIENTE
	, cast( case when max(cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime)) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime) then c_CV.CODIGO else null end as varchar( 10 ) ) descripMAS_RECIENTE
	, cast( case when c_CV.MONTOF != 0 and max( c_CV.MONTOF ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.MONTOF then 1 else null end as bit ) MAYOR_MONTOF
	, cast( case when c_CV.PORCENT != 0 and max( c_CV.PORCENT ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.PORCENT then 1 else null end as bit ) MAYOR_PORCENT
	, cast( case when c_CV.MONTOF != 0 and min( case when c_CV.MONTOF = 0 then null else c_CV.MONTOF end ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.MONTOF then 1 else null end as bit ) MENOR_MONTOF
	, cast( case when c_CV.PORCENT != 0 and min( case when c_CV.PORCENT = 0 then null else c_CV.PORCENT end ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.PORCENT then 1 else null end as bit ) MENOR_PORCENT
	, c_CV.CODIGO COMISION
	, c_CV.MONTOF
	, c_CV.PORCENT
  FROM ( select dtv.*, nullif(Funciones.ObtenerCodigoDeSucursalDeUnaBase( dtv.BDALTAFW ), '' ) VtaSuc from [ZooLogic].COMPROBANTEV dtv ) c_Comp 
  	left join ORGANIZACION.SUC c_Suc on c_Suc.CODIGO = Funciones.ObtenerCodigoDeSucursalDeUnaBase( c_comp.BDALTAFW )
	INNER join ZooLogic.COMPROBANTEVDET c_CDet on c_CDet.CODIGO = c_Comp.CODIGO
	left join ZooLogic.ART c_Art on c_Art.ARTCOD = c_CDet.FART
	inner join ZooLogic.DETCOMVEN c_RVC on c_RVC.CODIGO = c_Comp.FVEN
	left join ZooLogic.COMISION c_CV on c_CV.CODIGO = c_RVC.COMISION
		and c_Comp.FFCH between c_CV.FECHAFD and c_CV.FECHAH 
		and c_Comp.CODLISTA between c_CV.LISDESDE and c_CV.LISHASTA
		and ( c_Suc.CODIGO is null OR c_Suc.CODIGO between c_CV.SUCDESDE and c_CV.SUCHASTA )
		and ( c_Suc.CODIGO is null OR c_Suc.SEG between c_CV.SEGSDESDE and c_CV.SEGSHASTA )
		and ( c_Suc.CODIGO is null OR c_Suc.LINEA between c_CV.LINSDESDE and c_CV.LINSHASTA )
		and ( c_Suc.CODIGO is null OR c_Suc.TIPO between c_CV.TIPSDESDE and c_CV.TIPSHASTA )
		and c_CDet.FART between c_CV.ARTDESDE and c_CV.ARTHASTA
		and c_CDet.CCOLOR between c_CV.COLDESDE and c_CV.COLHASTA
		and c_CDet.TALLE between c_CV.TALDESDE and c_CV.TALHASTA
		and ( c_Art.ANO is null OR c_Art.ANO between c_CV.ANODESDE and c_CV.ANOHASTA )
		and ( c_Art.CATEARTI is null OR c_Art.CATEARTI between c_CV.CATDESDE and c_CV.CATHASTA )
		and ( c_Art.CLASIFART is null OR c_Art.CLASIFART between c_CV.CLADESDE and c_CV.CLAHASTA )
		and ( c_Art.FAMILIA is null OR c_Art.FAMILIA between c_CV.FAMDESDE and c_CV.FAMHASTA )
		and ( c_Art.GRUPO is null OR c_Art.GRUPO between c_CV.GRUDESDE and c_CV.GRUHASTA )
		and ( c_Art.LINEA is null OR c_Art.LINEA between c_CV.LINDESDE and c_CV.LINHASTA )
		and ( c_Art.MAT is null OR c_Art.MAT between c_CV.MATDESDE and c_CV.MATHASTA )
		and ( c_Art.ARTFAB is null OR c_Art.ARTFAB between c_CV.PROVDESDE and c_CV.PROVHASTA )
		and ( c_Art.ATEMPORADA is null OR c_Art.ATEMPORADA between c_CV.TEMDESDE and c_CV.TEMHASTA )
		and ( c_Art.TIPOARTI is null OR c_Art.TIPOARTI between c_CV.TIPDESDE and c_CV.TIPHASTA )
		and ( c_Art.UNIMED is null OR c_Art.UNIMED between c_CV.UNIDESDE and c_CV.UNIHASTA )
		where ( @CodigoComprobante is null or c_Comp.CODIGO = @CodigoComprobante ) and
				( ( @FechaDesde is null ) OR ( c_comp.FFCH >= @FechaDesde ) ) and 
				( ( @FechaHasta is null ) OR ( c_comp.FFCH <= @FechaHasta ) )
union all

SELECT 
	cast( case when c_Comp.FVEN = '' then 'Sin vendedor' else 'Sin comisión' end as varchar(22)) ORIGEN
	, c_Comp.CODIGO
	, c_CDet.IDITEM
	, c_Comp.FVEN
	--, cast( case when c_Art.ARTCOD is null then 'BORRADO' else 'ACTIVO' end as varchar(8)) Estado_Articulo
	, cast( case when min(cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime)) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime) then 1 else 0 end as bit ) MAS_ANTIGUA
	, cast( case when max(cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime)) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime) then 1 else 0 end as bit ) MAS_RECIENTE
	, cast( case when max(cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime)) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = cast(c_CV.FMODIFW + c_CV.HMODIFW as datetime) then c_CV.CODIGO else null end as varchar( 10 ) ) descripMAS_RECIENTE
	, cast( case when c_CV.MONTOF != 0 and max( c_CV.MONTOF ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.MONTOF then 1 else null end as bit ) MAYOR_MONTOF
	, cast( case when c_CV.PORCENT != 0 and max( c_CV.PORCENT ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.PORCENT then 1 else null end as bit ) MAYOR_PORCENT
	, cast( case when c_CV.MONTOF != 0 and min( case when c_CV.MONTOF = 0 then null else c_CV.MONTOF end ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.MONTOF then 1 else null end as bit ) MENOR_MONTOF
	, cast( case when c_CV.PORCENT != 0 and min( case when c_CV.PORCENT = 0 then null else c_CV.PORCENT end ) over ( partition by c_Comp.CODIGO, c_CDet.NROITEM ) = c_CV.PORCENT then 1 else null end as bit ) MENOR_PORCENT
	, c_CV.CODIGO COMISION
	, c_CV.MONTOF
	, c_CV.PORCENT
  FROM ( select dtv.*, nullif(Funciones.ObtenerCodigoDeSucursalDeUnaBase( dtv.BDALTAFW ), '' ) VtaSuc from [ZooLogic].COMPROBANTEV dtv ) c_Comp 
	left join ORGANIZACION.SUC c_Suc on c_Suc.CODIGO = Funciones.ObtenerCodigoDeSucursalDeUnaBase( c_comp.BDALTAFW )
	INNER join ZooLogic.COMPROBANTEVDET c_CDet on c_CDet.CODIGO = c_Comp.CODIGO
	LEFT join ZooLogic.ART c_Art on c_Art.ARTCOD = c_CDet.FART
	left join ZooLogic.DETCOMVEN c_RVC on c_RVC.CODIGO = c_Comp.FVEN
	inner join ZooLogic.COMISION c_CV on c_RVC.COMISION is null
		and c_Comp.FFCH between c_CV.FECHAFD and c_CV.FECHAH 
		and c_Comp.CODLISTA between c_CV.LISDESDE and c_CV.LISHASTA
		and ( c_Suc.CODIGO is null OR c_Suc.CODIGO between c_CV.SUCDESDE and c_CV.SUCHASTA )
		and ( c_Suc.CODIGO is null OR c_Suc.SEG between c_CV.SEGSDESDE and c_CV.SEGSHASTA )
		and ( c_Suc.CODIGO is null OR c_Suc.LINEA between c_CV.LINSDESDE and c_CV.LINSHASTA )
		and ( c_Suc.CODIGO is null OR c_Suc.TIPO between c_CV.TIPSDESDE and c_CV.TIPSHASTA )
		and c_CDet.FART between c_CV.ARTDESDE and c_CV.ARTHASTA
		and c_CDet.CCOLOR between c_CV.COLDESDE and c_CV.COLHASTA
		and c_CDet.TALLE between c_CV.TALDESDE and c_CV.TALHASTA
		and ( c_Art.ANO is null OR c_Art.ANO between c_CV.ANODESDE and c_CV.ANOHASTA )
		and ( c_Art.CATEARTI is null OR c_Art.CATEARTI between c_CV.CATDESDE and c_CV.CATHASTA )
		and ( c_Art.CLASIFART is null OR c_Art.CLASIFART between c_CV.CLADESDE and c_CV.CLAHASTA )
		and ( c_Art.FAMILIA is null OR c_Art.FAMILIA between c_CV.FAMDESDE and c_CV.FAMHASTA )
		and ( c_Art.GRUPO is null OR c_Art.GRUPO between c_CV.GRUDESDE and c_CV.GRUHASTA )
		and ( c_Art.LINEA is null OR c_Art.LINEA between c_CV.LINDESDE and c_CV.LINHASTA )
		and ( c_Art.MAT is null OR c_Art.MAT between c_CV.MATDESDE and c_CV.MATHASTA )
		and ( c_Art.ARTFAB is null OR c_Art.ARTFAB between c_CV.PROVDESDE and c_CV.PROVHASTA )
		and ( c_Art.ATEMPORADA is null OR c_Art.ATEMPORADA between c_CV.TEMDESDE and c_CV.TEMHASTA )
		and ( c_Art.TIPOARTI is null OR c_Art.TIPOARTI between c_CV.TIPDESDE and c_CV.TIPHASTA )
		and ( c_Art.UNIMED is null OR c_Art.UNIMED between c_CV.UNIDESDE and c_CV.UNIHASTA ) 
		where ( @CodigoComprobante is null or c_Comp.CODIGO = @CodigoComprobante ) and
				( ( @FechaDesde is null ) OR ( c_comp.FFCH >= @FechaDesde ) ) and 
				( ( @FechaHasta is null ) OR ( c_comp.FFCH <= @FechaHasta ) )

)
GO;
			
CREATE function [Funciones].[ObtenerDescripcionComisionesAAplicar]
(
		@tblComisiones as Listados.udt_TableType_Comisiones ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
select	( 
					SELECT coalesce(stuff(
					(
					SELECT '; ' + rtrim( c_CV.COMISION ) 
						+ case when c_CV.MONTOF != 0  then ' $' + cast(c_CV.MONTOF as varchar ) else '' end 
						+ case when c_CV.PORCENT != 0 then ' ' + cast(c_CV.PORCENT as varchar ) + '%' else '' end
					from @tblComisiones as c_CV
					where ( c_CV.CODIGO = c_X.CODIGO ) and ( c_CV.IDITEM = c_X.IDITEM )
					FOR XML PATH('') 
					), 1, 2, ''), '')
				) as desccom,c_X.CODIGO,c_X.IDITEM from @tblComisiones as c_X
)
GO;


CREATE FUNCTION [Funciones].[ObtenerResumenComisionesPorVentas]
( @FechaDesde as DateTime, @FechaHasta as DateTime  )
RETURNS @retorno TABLE (
ORIGEN	varchar(12), 
CODIGO	varchar(38), 
IDITEM varchar(38), 
montof numeric(15,2), 
MONTOF_SOLOUNA numeric(15,2),
porcent numeric(7,2),
PORCENT_SOLOUNA numeric(7,2),
MAYOR_MONTOF numeric(15,2),
menor_montof numeric(15,2),
MAYOR_PORCENT numeric(7,2),
MONTO_LIMITE_DEL_MAYOR numeric(15,2),
MENOR_PORCENT numeric(7,2),
MONTO_LIMITE_DEL_MENOR numeric(15,2),
infocom varchar(254),
infocom_solouna varchar(254)
)
begin
declare @lala Listados.udt_TableType_Comisiones
--declare @fechadesde datetime = Convert( datetime, '20210401')
--declare @fechahasta datetime = Convert( datetime, '20210401')
--declare @retorno TABLE (ORIGEN	varchar(12), CODIGO	varchar(38), IDITEM varchar(38), montof numeric(15,2), MONTOF_SOLOUNA numeric(15,2),porcent numeric(7,2),PORCENT_SOLOUNA numeric(7,2),MAYOR_MONTOF numeric(15,2),MAYOR_PORCENT numeric(7,2),MONTO_LIMITE_DEL_MAYOR numeric(15,2),MENOR_PORCENT numeric(7,2),MONTO_LIMITE_DEL_MENOR numeric(15,2),infocom varchar(20),infocom_solouna varchar(20))
insert into @lala (origen, codigo, iditem, fven, mas_antigua, mas_reciente, descripMAS_RECIENTE,MAYOR_MONTOF, MAYOR_PORCENT, MENOR_MONTOF, MENOR_PORCENT, comision, montof, porcent)  select distinct origen, codigo, iditem, fven, mas_antigua, mas_reciente, descripMAS_RECIENTE,MAYOR_MONTOF, MAYOR_PORCENT, MENOR_MONTOF, MENOR_PORCENT, comision, montof, porcent from Funciones.ComisionesPorVentaPorFecha(null, @FechaDesde, @FechaHasta)
declare @descripciones table (desccom	varchar(254), CODIGO	varchar(38), IDITEM varchar(38))
insert into @descripciones (desccom, codigo, iditem)  select distinct desccom, codigo, iditem from Funciones.ObtenerDescripcionComisionesAAplicar(@lala)
--insert into @descripciones (desccom, codigo, iditem)  select desccom, codigo, iditem from Funciones.ObtenerDescripcionComisionesAAplicar(@lala)
insert into @retorno (ORIGEN, CODIGO, IDITEM, montof, MONTOF_SOLOUNA, porcent, PORCENT_SOLOUNA, MAYOR_MONTOF, MAYOR_PORCENT, MONTO_LIMITE_DEL_MAYOR, menor_montof, MENOR_PORCENT, MONTO_LIMITE_DEL_MENOR, infocom, infocom_solouna) 
SELECT c_CV.ORIGEN	
	, c_CV.CODIGO
	, c_CV.IDITEM
	, sum( c_CV.MONTOF ) MONTOF
	, sum( c_CV.MONTOF * c_CV.MAS_RECIENTE ) MONTOF_SOLOUNA
	, sum( c_CV.PORCENT ) PORCENT
	, sum( c_CV.PORCENT * c_CV.MAS_RECIENTE ) PORCENT_SOLOUNA
	, sum( c_CV.MONTOF * c_CV.MAYOR_MONTOF) MAYOR_MONTOF
	, sum( c_CV.PORCENT * c_CV.MAYOR_PORCENT ) MAYOR_PORCENT
	, cast( coalesce( sum( c_CV.MONTOF * c_CV.MAYOR_MONTOF), 0 ) / ( ( coalesce( sum( c_CV.PORCENT * c_CV.MAYOR_PORCENT ), 100 ) / 100 ) ) as numeric( 15, 2) ) MONTO_LIMITE_DEL_MAYOR
	, sum( c_CV.MONTOF * c_CV.MENOR_MONTOF) MENOR_MONTOF
	, sum( c_CV.PORCENT * c_CV.MENOR_PORCENT ) MENOR_PORCENT
	, cast( coalesce( sum( c_CV.MONTOF * c_CV.MENOR_MONTOF), 0 ) / ( ( coalesce( sum( c_CV.PORCENT * c_CV.MENOR_PORCENT ), 100 ) / 100 ) ) as numeric( 15, 2) ) MONTO_LIMITE_DEL_MENOR
	,cast(coalesce(c_CV99.desccom,'') as varchar(250)) as INFOCOM
	,cast(coalesce(c_CV99.desccom,'') as varchar(250)) as INFOCOM_solouna
--	,cast(coalesce(c_CV991.desccom,'') as varchar(250)) as INFOCOM_SOLOUNA
	--	,'' as infocom
	--	,'' as infocom_solouna
from @lala as c_CV
left join @descripciones as c_CV99 on c_CV.CODIGO = c_CV99.CODIGO AND c_CV.IDITEM = c_CV99.IDITEM
--left join @descripciones as c_CV991 on c_CV.CODIGO = c_CV991.CODIGO AND c_CV.IDITEM = c_CV991.IDITEM 
--AND c_CV.COMISION = C_CV.descripMAS_RECIENTE
group by c_CV.ORIGEN, c_CV.CODIGO, c_CV.IDITEM
,c_CV99.desccom
--, c_CV991.desccom
return
end

