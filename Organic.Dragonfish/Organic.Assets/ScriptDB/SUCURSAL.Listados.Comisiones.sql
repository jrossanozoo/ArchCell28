IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ComisionesPorVentaYCobranza]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ComisionesPorVentaYCobranza];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionComisionesPorVentaYCobranzaAAplicar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionComisionesPorVentaYCobranzaAAplicar];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ResumenComisionesPorVentaYCobranza]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ResumenComisionesPorVentaYCobranza];
GO;

CREATE FUNCTION [Funciones].[ComisionesPorVentaYCobranza]
(
	@COMISION varchar(10),
	@FechaDesde as DateTime, 
	@FechaHasta as DateTime
)
RETURNS TABLE
AS
RETURN
(

with Refinanciados as
(
	select    Recibo.CODIGO as Codigo
			, Recibo.DESCFW as Descripcion
			, ReDet.CODCOMP as AfeCodigo
			, ReDet.DESCRIP as AfeDescripcion
			, ReDet.RMONTO as AfeMonto
			, ReDet.TIPO as AfeTipo
			, 0 as Nivel
	from Zoologic.RECIBO as Recibo
	inner join ZooLogic.RECIBODET as ReDet on Recibo.CODIGO = ReDet.CODIGO
	inner join Zoologic.VAL as Valor on Recibo.CODIGO = Valor.JJNUM and Valor.JJCO <> 'C'
	where ReDet.TIPO = 13 and ReDet.DESCRIP <> 'Pago a cuenta'

	union all

	select    Anterior.CODIGO as Codigo
			, Anterior.DESCRIPCION as Descripcion
			, ReDet.CODCOMP as AfeCodigo
			, ReDet.DESCRIP as AfeDescripcion
			, ReDet.RMONTO as AfeMonto
			, ReDet.TIPO as AfeTipo
			, Anterior.NIVEL + 1 as Nivel
	from Refinanciados as Anterior
	inner join ZooLogic.RECIBODET as ReDet on Anterior.afecodigo = ReDet.CODIGO
	where Anterior.Nivel < 3
)

	SELECT distinct 
		cast( 'Con comisión' as varchar(22)) ORIGEN
		, coalesce( c_FacxRec.Recibo, c_Ref.Descripcion ) as Recibo
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
		--, c_Comp.FTOTAL
		--, c_CDet.FMONTO
		--, ( ( c_CDet.FMONTO / c_Comp.FTOTAL ) * 100 ) as PProrrateo
		, coalesce( c_FacxRec.RMONTO, c_Ref.AfeMonto ) as RMONTO
		, c_CV.CLCLASD as CLCLAS_DESDE
		, c_CV.CLCLASH as CLCLAS_HASTA
		, c_FacxRec.FechaRecibo
		--, cast( round( ( c_FacxRec.RMONTO * ( coalesce(c_CV.Porcent, 0) / 100) ) * ( c_CDet.FMONTO / c_Comp.FTOTAL ), 2 ) as numeric(12,2) ) as MonProrPorcen
		--, cast( round( ( c_FacxRec.RMONTO * ( coalesce(c_CV.MONTOF, 0) / c_Comp.FTOTAL ) ) * ( c_CDet.FMONTO / c_Comp.FTOTAL ), 2 ) as numeric(12,2) ) as MonProrMontoF
	FROM ( select dtv.*, nullif(Funciones.ObtenerCodigoDeSucursalDeUnaBase( dtv.BDALTAFW ), '' ) VtaSuc from [ZooLogic].COMPROBANTEV dtv ) c_Comp 
  		left join ORGANIZACION.SUC c_Suc on c_Suc.CODIGO = Funciones.ObtenerCodigoDeSucursalDeUnaBase( c_comp.BDALTAFW )
		left join ( select r.descfw as Recibo, rd.CODCOMP, DESCRIP, RMONTO , ffch as FechaRecibo
					from zoologic.RECIBODET as rd
					inner join ZooLogic.RECIBO as r on r.CODIGO = rd.CODIGO
					left join ZooLogic.val as v on rd.codigo = v.jjnum 
					where ( v.jjco <> 'C' or v.jjco is null)
					group by r.descfw, codcomp, descrip, rmonto , ffch
		) as c_FacxRec on c_FacxRec.CODCOMP = c_Comp.CODIGO
		left join ZooLogic.CLI as C_CLIENTE on C_CLIENTE.CLCOD = c_Comp.FPERSON and 0 = Funciones.empty( c_Comp.FPERSON )
		left join Refinanciados as c_Ref on c_Ref.AfeCodigo = c_Comp.CODIGO and c_Ref.AfeTipo <> 13
		INNER join ZooLogic.COMPROBANTEVDET c_CDet on c_CDet.CODIGO = c_Comp.CODIGO
		left join ZooLogic.ART c_Art on c_Art.ARTCOD = c_CDet.FART
		inner join ZooLogic.DETCOMVEN c_RVC on c_RVC.CODIGO = c_Comp.FVEN and ( c_RVC.COMISION = @COMISION or @COMISION = 'TODOS' )
		left join ZooLogic.COMISION c_CV on c_CV.CODIGO = c_RVC.COMISION
			and c_Comp.FFCH between c_CV.FECHAFD and c_CV.FECHAH 
			and c_Comp.CODLISTA between c_CV.LISDESDE and c_CV.LISHASTA
			and ( c_Suc.CODIGO is null OR c_Suc.CODIGO between c_CV.SUCDESDE and c_CV.SUCHASTA )
			and ( c_Suc.CODIGO is null OR c_Suc.SEG between c_CV.SEGSDESDE and c_CV.SEGSHASTA )
			and ( c_Suc.CODIGO is null OR c_Suc.LINEA between c_CV.LINSDESDE and c_CV.LINSHASTA )
			and ( c_Suc.CODIGO is null OR c_Suc.TIPO between c_CV.TIPSDESDE and c_CV.TIPSHASTA )
			and (C_CLIENTE.CLCOD is null or C_CLIENTE.CLCLAS between c_CV.CLCLASD and c_cv.CLCLASH)
			and (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLCOD BETWEEN C_CV.FPERSOND AND C_CV.FPERSONH)
			AND (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLCODFANT BETWEEN C_CV.CLCODFANTD AND C_CV.CLCODFANTH)
			AND (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLTIPOCLI BETWEEN C_CV.CLTIPOCLID AND C_CV.CLTIPOCLIH)
			AND (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLCATEGCLI BETWEEN C_CV.CLCATECLID AND C_CV.CLCATECLIH)
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
			and ( ( @FechaDesde is null ) OR ( c_comp.FFCH >= @FechaDesde ) ) 
			and ( ( @FechaHasta is null ) OR ( c_comp.FFCH <= @FechaHasta ) )
				where c_CV.MONTOF is not null or c_CV.PORCENT is not null
	
	union all

	SELECT
		cast( case when c_Comp.FVEN = '' then 'Sin vendedor' else 'Sin comisión' end as varchar(22)) ORIGEN
		, coalesce( c_FacxRec.Recibo, c_Ref.Descripcion ) as Recibo
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
		--, c_Comp.FTOTAL
		--, c_CDet.FMONTO
		--, ( ( c_CDet.FMONTO / c_Comp.FTOTAL ) * 100 ) as PProrrateo
		, coalesce( c_FacxRec.RMONTO, c_Ref.AfeMonto ) as RMONTO
		, c_CV.CLCLASD as CLCLAS_DESDE
		, c_CV.CLCLASH as CLCLAS_HASTA
		, c_FacxRec.FechaRecibo		
		--, cast( round( ( c_FacxRec.RMONTO * ( coalesce(c_CV.Porcent, 0) / 100) ) * ( c_CDet.FMONTO / c_Comp.FTOTAL ), 2 ) as numeric(12,2) ) as MonProrPorcen
		--, cast( round( ( c_FacxRec.RMONTO * ( coalesce(c_CV.MONTOF, 0) / c_Comp.FTOTAL ) ) * ( c_CDet.FMONTO / c_Comp.FTOTAL ), 2 ) as numeric(12,2) ) as MonProrMontoF
	FROM ( select dtv.*, nullif(Funciones.ObtenerCodigoDeSucursalDeUnaBase( dtv.BDALTAFW ), '' ) VtaSuc from [ZooLogic].COMPROBANTEV dtv ) c_Comp 
		left join ORGANIZACION.SUC c_Suc on c_Suc.CODIGO = Funciones.ObtenerCodigoDeSucursalDeUnaBase( c_comp.BDALTAFW )
		left join ( select r.descfw as Recibo, rd.CODCOMP, DESCRIP, RMONTO , ffch as FechaRecibo
					from zoologic.RECIBODET as rd
					inner join ZooLogic.RECIBO as r on r.CODIGO = rd.CODIGO
					left join ZooLogic.val as v on rd.codigo = v.jjnum 
					where ( v.jjco <> 'C' or v.jjco is null)
					group by r.descfw, codcomp, descrip, rmonto , ffch
		) as c_FacxRec on c_FacxRec.CODCOMP = c_Comp.CODIGO
		left join ZooLogic.CLI as C_CLIENTE on C_CLIENTE.CLCOD = c_Comp.FPERSON and 0 = Funciones.empty( c_Comp.FPERSON )
		left join Refinanciados as c_Ref on c_Ref.AfeCodigo = c_Comp.CODIGO and c_Ref.AfeTipo <> 13
		INNER join ZooLogic.COMPROBANTEVDET c_CDet on c_CDet.CODIGO = c_Comp.CODIGO
		LEFT join ZooLogic.ART c_Art on c_Art.ARTCOD = c_CDet.FART
		inner join ZooLogic.DETCOMVEN c_RVC on c_RVC.CODIGO = c_Comp.FVEN and ( c_RVC.COMISION = @COMISION or @COMISION = 'TODOS' )
		inner join ZooLogic.COMISION c_CV on c_RVC.COMISION is null
			and c_Comp.FFCH between c_CV.FECHAFD and c_CV.FECHAH 
			and c_Comp.CODLISTA between c_CV.LISDESDE and c_CV.LISHASTA
			and ( c_Suc.CODIGO is null OR c_Suc.CODIGO between c_CV.SUCDESDE and c_CV.SUCHASTA )
			and ( c_Suc.CODIGO is null OR c_Suc.SEG between c_CV.SEGSDESDE and c_CV.SEGSHASTA )
			and ( c_Suc.CODIGO is null OR c_Suc.LINEA between c_CV.LINSDESDE and c_CV.LINSHASTA )
			and ( c_Suc.CODIGO is null OR c_Suc.TIPO between c_CV.TIPSDESDE and c_CV.TIPSHASTA )
			and (C_CLIENTE.CLCOD is null or C_CLIENTE.CLCLAS between c_CV.CLCLASD and c_cv.CLCLASH)
			and (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLCOD BETWEEN C_CV.FPERSOND AND C_CV.FPERSONH)
			AND (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLCODFANT BETWEEN C_CV.CLCODFANTD AND C_CV.CLCODFANTH)
			AND (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLTIPOCLI BETWEEN C_CV.CLTIPOCLID AND C_CV.CLTIPOCLIH)
			AND (C_CLIENTE.CLCOD IS NULL OR C_CLIENTE.CLCATEGCLI BETWEEN C_CV.CLCATECLID AND C_CV.CLCATECLIH)
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
			and ( ( @FechaDesde is null ) OR ( c_comp.FFCH >= @FechaDesde ) ) 
			and ( ( @FechaHasta is null ) OR ( c_comp.FFCH <= @FechaHasta ) )
				where c_CV.MONTOF is not null or c_CV.PORCENT is not null
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ComisionesCobranzas' AND is_table_type = 1 AND SCHEMA_ID('Listados') = schema_id)
	DROP TYPE Listados.udt_TableType_ComisionesCobranzas;
GO;

CREATE TYPE Listados.udt_TableType_ComisionesCobranzas AS TABLE
(
	[ORIGEN] [varchar](12) NULL,
	[RECIBO] [varchar](200) NULL,
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
	[porcent] [numeric](7, 2) NULL,
	[rmonto] [numeric](15, 2) NULL,
	[CLCLAS_DESDE] [varchar] (10) NULL,
	[CLCLAS_HASTA] [varchar] (10) NULL,
	[FechaRecibo] [datetime] NULL
)
GO;
			
CREATE FUNCTION [Funciones].[ObtenerDescripcionComisionesPorVentaYCobranzaAAplicar]
(
	@tblComisiones as Listados.udt_TableType_ComisionesCobranzas ReadOnly
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

CREATE FUNCTION [Funciones].[ResumenComisionesPorVentaYCobranza]
(
	@COMISION varchar(10),
	@FechaDesde as DateTime, 
	@FechaHasta as DateTime
)
RETURNS @retorno TABLE (
ORIGEN	varchar(12), 
RECIBO varchar(200),
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
MONTO_RECIBO numeric(15,2),
MONTO_LIMITE_DEL_MENOR numeric(15,2),
FechaRecibo  datetime,
infocom varchar(254)
)
begin

declare @lala Listados.udt_TableType_ComisionesCobranzas
--declare @fechadesde datetime = Convert( datetime, '20210401')
--declare @fechahasta datetime = Convert( datetime, '20210401')
--declare @retorno TABLE (ORIGEN	varchar(12), CODIGO	varchar(38), IDITEM varchar(38), montof numeric(15,2), MONTOF_SOLOUNA numeric(15,2),porcent numeric(7,2),PORCENT_SOLOUNA numeric(7,2),MAYOR_MONTOF numeric(15,2),MAYOR_PORCENT numeric(7,2),MONTO_LIMITE_DEL_MAYOR numeric(15,2),MENOR_PORCENT numeric(7,2),MONTO_LIMITE_DEL_MENOR numeric(15,2),infocom varchar(20),infocom_solouna varchar(20))
insert into @lala (origen, recibo, codigo, iditem, fven, mas_antigua, mas_reciente, descripMAS_RECIENTE,MAYOR_MONTOF, MAYOR_PORCENT, MENOR_MONTOF, MENOR_PORCENT, comision, montof, porcent, rmonto, FechaRecibo)  select distinct origen, recibo, codigo, iditem, fven, mas_antigua, mas_reciente, descripMAS_RECIENTE,MAYOR_MONTOF, MAYOR_PORCENT, MENOR_MONTOF, MENOR_PORCENT, comision, montof, porcent, rmonto, FechaRecibo from Funciones.ComisionesPorVentaYCobranza(@COMISION, @FechaDesde, @FechaHasta)
insert into @retorno (ORIGEN, recibo, CODIGO, IDITEM, montof, MONTOF_SOLOUNA, porcent, PORCENT_SOLOUNA, MAYOR_MONTOF, MAYOR_PORCENT, MONTO_LIMITE_DEL_MAYOR, menor_montof, MENOR_PORCENT, MONTO_RECIBO, MONTO_LIMITE_DEL_MENOR, FechaRecibo, infocom) 
SELECT distinct
	  c_CV.ORIGEN
	, coalesce(c_CV.Recibo, '') as Recibo
	, c_CV.CODIGO
	, c_CV.IDITEM
	, sum( c_CV.MONTOF ) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS MONTOF
	, sum( c_CV.MONTOF * c_CV.MAS_RECIENTE ) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS MONTOF_SOLOUNA
	, sum( c_CV.PORCENT ) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS PORCENT
	, sum( c_CV.PORCENT * c_CV.MAS_RECIENTE ) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS PORCENT_SOLOUNA
	, sum( c_CV.MONTOF * c_CV.MAYOR_MONTOF) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS MAYOR_MONTOF
	, sum( c_CV.PORCENT * c_CV.MAYOR_PORCENT ) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS MAYOR_PORCENT
	, cast( coalesce( sum( c_CV.MONTOF * c_CV.MAYOR_MONTOF) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM), 0 ) / ( ( coalesce( sum( c_CV.PORCENT * c_CV.MAYOR_PORCENT ) over (partition by c_CV.ORIGEN, c_CV.CODIGO, c_CV.IDITEM), 100 ) / 100 ) ) as numeric( 15, 2) ) MONTO_LIMITE_DEL_MAYOR
	, sum( c_CV.MONTOF * c_CV.MENOR_MONTOF) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS MENOR_MONTOF
	, sum( c_CV.PORCENT * c_CV.MENOR_PORCENT ) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM) AS MENOR_PORCENT
	, c_CV.RMONTO as MONTO_RECIBO
	, cast( coalesce( sum( c_CV.MONTOF * c_CV.MENOR_MONTOF) over (partition by c_CV.ORIGEN, c_CV.Recibo, c_CV.CODIGO, c_CV.IDITEM), 0 ) / ( ( coalesce( sum( c_CV.PORCENT * c_CV.MENOR_PORCENT ) over (partition by c_CV.ORIGEN, c_CV.CODIGO, c_CV.IDITEM), 100 ) / 100 ) ) as numeric( 15, 2) ) MONTO_LIMITE_DEL_MENOR
	, c_CV.FechaRecibo
	, cast(coalesce(c_CV99.desccom,'') as varchar(250)) as INFOCOM
--	, cast(coalesce(c_CV991.desccom,'') as varchar(250)) as INFOCOM_SOLOUNA
from @lala as c_CV
left join [Funciones].[ObtenerDescripcionComisionesPorVentaYCobranzaAAplicar](@lala) as c_CV99 on c_CV.CODIGO = c_CV99.CODIGO AND c_CV.IDITEM = c_CV99.IDITEM
--left join [Listados].[VistaObtenerDescripcionComisionesPorCobranzaAAplicar] as c_CV991 on c_CV.CODIGO = c_CV991.CODIGO AND c_CV.IDITEM = c_CV991.IDITEM AND c_CV.COMISION = C_CV.descripMAS_RECIENTE
group by c_CV.ORIGEN
		 , c_cv.Recibo
		 , c_CV.CODIGO
		 , c_CV.IDITEM
		 , c_cv.RMONTO
		 , c_CV.PORCENT
		 , c_CV.MONTOF
		 , c_CV.MENOR_MONTOF
		 , c_CV.MAYOR_MONTOF
		 , c_CV.MENOR_PORCENT
		 , c_CV.MAYOR_PORCENT
		 , c_CV.MAS_RECIENTE
		 , c_CV99.desccom
		 , C_CV.FechaRecibo 
--		 , c_CV991.desccom
return
end