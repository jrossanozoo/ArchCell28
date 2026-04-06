USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_DiasLaboralesXLegajo]    Script Date: 07/24/2013 15:41:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_DiasLaboralesXLegajo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_DiasLaboralesXLegajo]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_DiasLaboralesXLegajo]    Script Date: 07/24/2013 15:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Objetivos].[func_RRHH_DiasLaboralesXLegajo] 
(
      @ListaDeLegajos Varchar(max)
      , @FecIni DATETIME
      , @FecFin DATETIME

)
RETURNS 
      @DiasLaborales TABLE 
      (
            Fecha Datetime 
            , Legajo Varchar( 4 ) 
            , DiaSemanaZL Integer 
            , EsFeriado Bit
      )
AS
BEGIN
      declare @Legajo Varchar( 4 )
      declare TablaLegajos cursor for select convert( varchar( 4 ),ValorRetorno) as Legajo from [dbo].[ListaATabla]( @ListaDeLegajos ) 
      open TablaLegajos 
      
      FETCH NEXT FROM TablaLegajos INTO  @Legajo;
      WHILE @@FETCH_STATUS = 0
      BEGIN
            
            with Calendario
            as
            (
            select @FecIni as Fecha
            union all
            select DATEADD(dd, 1, Fecha) from Calendario where Fecha < @FecFin
            )
            
            INSERT INTO @DiasLaborales
                             select 
                                   c.Fecha 
                                   , @Legajo
                                   , zl.func_ZL_DiaSemana( c.Fecha ) as DiaSemanaZL
                                   , case      when ISNULL( zf.FECHA, '19000101' ) = '19000101' then 0 else  1 end as EsFeriado
                             from Calendario C 
                              left join ZL.ZLFERIADO zf on zf.fecha = C.Fecha
                             inner join ( select Dia, Feriados from ZL.DtSalRgDH 
                                                           where Codint = (select ESQLAB  
                                                                                  from Objetivos.func_RRHH_EsquemaVigentexLegajo( @Legajo ) ) 
                                               ) Esquema on Esquema.Dia = zl.func_ZL_DiaSemana( c.Fecha )
                                                             and ( ISNULL( zf.FECHA, '19000101' ) = '19000101' 
                                                                       or ( ISNULL( zf.FECHA, '19000101' ) <> '19000101' and Esquema.Feriados = 1 )
                                                                    )
                                     
                             option (maxrecursion 0)      
      
      FETCH NEXT FROM TablaLegajos INTO @Legajo;
      END
      
      close TablaLegajos
      deallocate TablaLegajos
            
      RETURN 
END



GO


