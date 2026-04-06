USE [ZL]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_GestionIncumplimientosAusencias]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_GestionIncumplimientosAusencias]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_GestionIncumplimientosAusencias]    Script Date: 07/30/2013 11:27:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Objetivos].[func_RRHH_GestionIncumplimientosAusencias]
(
      @ListaDeLegajos Varchar(max)
      , @FecIni DATETIME
      , @FecFin DATETIME
)

RETURNS TABLE 
AS
RETURN 
(
            select 
                   D.LEGAJO
                  , rtrim( L.Capellido ) + ' ' + rtrim(  L.Cprinombre ) + ' ' + rtrim( L.Csegnombre ) as ApellidoYNombres
                  --, null
                  , CONVERT(VARCHAR(10), D.Fecha, 3) AS FECHA  
                  --, (case   when ISNULL( af.FECHA, '19000101' ) = '19000101' then 'No' else  'Sí' end)
                  --   as RegistraFichaje
                  --,  ISNULL( DV.Anno , '' ) as Vacaciones      
                  --,  (case when ISNULL( I.Justifica, 0 ) = 0 then 'No'    else  'Sí' end) as Justificada
                  --, Null,Null,Null,Null,Null 
                  , 'Ausencia' as TipoIncumplimpiento
                  from 
                        -- Calendario segun esquema
                        Objetivos.func_RRHH_DiasLaboralesxLegajo( @ListaDeLegajos,@FecIni,@FecFin ) as D
                  
                  Inner join 
                        -- Legajos
                        ZL.Legajo L on L.Ccod = D.LEGAJO
                  Left join   
                        -- Fichajes 
                        (     
                        select distinct
                             fecha
                             ,legajo
                        from ZL.ZNFICHAJE F
                        ) AF on Af.Fecha = D.Fecha and Af.legajo = D.Legajo 
                  
                  left join  
                        -- Vacaciones  
                        ZL.Dvaca DV on DV.Ccod = D.Legajo  
                                                           and ( D.Fecha <= DV.Ffin and D.Fecha >= DV.Finicio )
                                                           and ctipo = '0002'
                                                           
                  left join 
                        -- Incumplimientos 
                        zl.GesInc I on I.LEG = D.Legajo
                                                           and ( D.Fecha <= I.fechaf and D.Fecha >= I.fechai )
                                                           and I.Inchlab = 'AUS'
                                                           
                  where 
                        -- que no sea una fecha posterior a la fecha en curso
                        D.Fecha <= GETDATE()
                        and -- Que no este dentro del perido solicitado
                        ISNULL( af.FECHA, '19000101' ) = '19000101'
                        and  -- Que no este de vacaciones
                        ISNULL( DV.Anno , '' ) = ''
                        and  -- Que no este justificado el incumplimiento
                        ISNULL( I.Justifica, 0 ) = 0
      
                  --order by D.Legajo,  D.Fecha 

)


GO

