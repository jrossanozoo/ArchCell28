USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[sp_ObtenerBugsParaPublicar]    Script Date: 03/08/2013 14:31:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [ZL].[sp_ObtenerBugsParaPublicar]
@Proyecto numeric(10),
@Entidad varchar( 25 )
as

if @Entidad='DEMO'
	SELECT b.[Codin] bug, DetEvBugs.bugaso, DetEvBugs.func
		  FROM [ZL].[REGBUG] as b
				inner join ZL.hpivot hp on  hp.bug = b.Codin
						and isNull(LTRIM(RTRIM(hp.estado)),'Sin Estado') in ('Accepted')
				left join  ZL.DetEvBugs on b.codin = DetEvBugs.bug
				left join  zl.DetEvIss  on b.codin = DetEvIss.bug 
				left join  zl.DetBugPu as dbl on b.codin = dbl.bug
				left join ZL.IydBugUltimoEstado as bue on bue.bug = b.codin
				left join ZL.IydBugUltimoProyecto as bup on bup.bug = b.codin
	  where 
	  --o fue evaluado o es urgente
	  (DetEvIss.bug is not null or DetEvBugs.bug is not null or bue.funcest = 11) 
		  and  dbl.bug is null
		  and  IsNull(bup.Proy,0) in (@Proyecto)  
		  and isNull(LTRIM(RTRIM(bue.Estado)),'Sin Estado') in ('Presupuesto - Aceptado','Aprobada','Aprobada condicionada', 'Urgencia', 'Presupuesto') 
		  and b.codin not in ( select Bug from zl.DtIyDemB )
else
  SELECT 
    B.[CODIN] BUG
    , DETEVBUGS.BUGASO
    , DETEVBUGS.FUNC
    , BUE.FUNCEST
  FROM 
    [ZL].[REGBUG] AS B
    INNER JOIN ZL.HPIVOT HP ON HP.BUG = B.CODIN
      AND ISNULL(LTRIM(RTRIM(HP.ESTADO)), 'Sin Estado') = 'Accepted'
    LEFT JOIN  ZL.DetEvBugs ON B.CODIN = DetEvBugs.BUG
    LEFT JOIN  ZL.DetEvIss ON B.CODIN = DetEvIss.BUG 
    LEFT JOIN  ZL.DETBUGPU AS DBL ON B.CODIN = DBL.BUG
    LEFT JOIN ZL.IYDBUGULTIMOESTADO AS BUE ON BUE.BUG = B.CODIN
    LEFT JOIN ZL.IYDBUGULTIMOPROYECTO AS BUP ON BUP.BUG = B.CODIN
  WHERE 
    --O FUE EVALUADO O ES URGENTE
    ((zl.DetEvIss.BUG IS NOT NULL OR DETEVBUGS.BUG IS NOT NULL OR BUE.FUNCEST = 11) and DBL.BUG IS NULL)
    AND -- ISNULL(BUP.PROY,0) IN (@PROYECTO)  */
    ISNULL(BUP.PROY,0) IN ( CASE 
                              WHEN @Proyecto <> 0 THEN (@Proyecto) 
                              ELSE ISNULL(BUP.PROY, 0) 
                            END ) 
    AND ISNULL(LTRIM(RTRIM(BUE.ESTADO)), 'Sin Estado') IN ('Presupuesto - Aceptado', 'Aprobada', 'Aprobada condicionada', 'Urgencia', 'Presupuesto') 
    AND B.CODIN NOT IN ( SELECT BUG FROM ZL.DETBUGPU )

GO


