USE [ZL]
GO

/****** Object:  StoredProcedure [dbo].[stp_MigracionFichajes_INFORMACION_COMPLEMENTARIA]    Script Date: 08/12/2013 12:19:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_MigracionFichajes_INFORMACION_COMPLEMENTARIA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[stp_MigracionFichajes_INFORMACION_COMPLEMENTARIA]
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [dbo].[stp_MigracionFichajes_INFORMACION_COMPLEMENTARIA]    Script Date: 08/12/2013 12:19:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[stp_MigracionFichajes_INFORMACION_COMPLEMENTARIA]
(     
@FECHAUTLIMAMIGRACION DATETIME
)
AS
BEGIN
      SET NOCOUNT ON;

      --AGREGAMOS INFORMACION COMPLEMENTARIA A LA FICHADA
      DECLARE @LEGAJO VARCHAR(4), @FCHREG DATETIME, @CODPUESTO VARCHAR(4), @COD VARCHAR(MAX);
      DECLARE TEMPORAL CURSOR FOR
            SELECT 
                  COD
                  , LEGAJO
                  , FCHREG 
            FROM 
                  [ZL].[ZNFICHAJE]
            WHERE
                  FCHREG >=  @FECHAUTLIMAMIGRACION 
      OPEN TEMPORAL;
      FETCH NEXT FROM TEMPORAL INTO @COD, @LEGAJO, @FCHREG;
      WHILE @@FETCH_STATUS = 0
      BEGIN
            /*
            AREA VARCHAR(4), SECTOR VARCHAR(3), ESQUEMA INT, ASIGESQ INT, INGRESOESQUEMA VARCHAR(8)
            , EGRESOESQUEMA VARCHAR(8), TOLERANCIA INT, MINUTOS INT    
            */
            UPDATE [ZL].[ZNFICHAJE] SET
                  CODPUESTO        = (SELECT CODPUESTO FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG))
                  , AREA           = (SELECT FUNCION.AREA FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , SECTOR         = (SELECT FUNCION.SECTOR FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , ESQUEMA        = (SELECT FUNCION.ESQLAB FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , ASIGESQ        = (SELECT FUNCION.ASIGESQ FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , INGRESOESQUEMA = (SELECT FUNCION.INGRESOESQUEMA FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , EGRESOESQUEMA  = (SELECT FUNCION.EGRESOESQUEMA FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , TOLERANCIA     = (SELECT FUNCION.TOLERANCIA FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , MINUTOS        = (SELECT FUNCION.MINUTOS FROM [Objetivos].[func_RRHH_UpdateFichaje](@LEGAJO, @FCHREG) AS FUNCION)
                  , FECHA          = CONVERT(DATETIME, CONVERT(VARCHAR(10), @FCHREG, 120), 102)
                  , ANIO           = YEAR(@FCHREG)
                  , MES            = MONTH(@FCHREG)
                  , DIA            = DAY(@FCHREG)
            WHERE
                  COD = @COD;
            FETCH NEXT FROM TEMPORAL INTO @COD, @LEGAJO, @FCHREG;
      END
      CLOSE TEMPORAL;
      DEALLOCATE TEMPORAL;
END


GO


--exec [dbo].[stp_MigracionFichajes_INFORMACION_COMPLEMENTARIA] '20130801';