IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaObtenerDescripcionComisionesAAplicar]') AND type = N'V')
DROP VIEW [Listados].[VistaObtenerDescripcionComisionesAAplicar];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaResumenComisionesPorVenta]') AND type = N'V')
DROP VIEW [Listados].[VistaResumenComisionesPorVenta];
GO;
				
CREATE view [Listados].[VistaObtenerDescripcionComisionesAAplicar] as
(
	select	( 
					SELECT coalesce(stuff(
					(
					SELECT '; ' + rtrim( c_CV.COMISION ) 
						+ case when c_CV.MONTOF != 0  then ' $' + cast(c_CV.MONTOF as varchar ) else '' end 
						+ case when c_CV.PORCENT != 0 then ' ' + cast(c_CV.PORCENT as varchar ) + '%' else '' end
					from Listados.VistaComisionesPorVenta as c_CV
					where ( c_CV.CODIGO = c_X.CODIGO ) and ( c_CV.IDITEM = c_X.IDITEM )
					FOR XML PATH('') 
					), 1, 2, ''), '')
				) as desccom,c_X.CODIGO,c_X.IDITEM from Listados.VistaComisionesPorVenta as c_X
)
GO;


CREATE view [Listados].[VistaResumenComisionesPorVenta] as
(
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
	,cast(coalesce(c_CV991.desccom,'') as varchar(250)) as INFOCOM_SOLOUNA
from [Listados].[VistaComisionesPorVenta] as c_CV
left join [Listados].[VistaObtenerDescripcionComisionesAAplicar] as c_CV99 on c_CV.CODIGO = c_CV99.CODIGO AND c_CV.IDITEM = c_CV99.IDITEM
left join [Listados].[VistaObtenerDescripcionComisionesAAplicar] as c_CV991 on c_CV.CODIGO = c_CV991.CODIGO AND c_CV.IDITEM = c_CV991.IDITEM AND c_CV.COMISION = C_CV.descripMAS_RECIENTE
group by c_CV.ORIGEN, c_CV.CODIGO, c_CV.IDITEM,c_CV99.desccom, c_CV991.desccom
)