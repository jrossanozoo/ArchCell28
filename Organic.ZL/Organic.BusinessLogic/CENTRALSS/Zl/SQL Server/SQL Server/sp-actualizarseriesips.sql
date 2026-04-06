USE [ZL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-actualizarseriesips]') AND type in (N'P', N'PC'))
            DROP PROCEDURE [ZL].[sp-actualizarseriesips]
GO

Create PROCEDURE [ZL].[sp-actualizarseriesips] 
      ( @serie varchar(7),
      @ip varchar(45)
)     
as  

BEGIN 
declare  @retorno as int 
declare @fecha as datetime


set @fecha = GETDATE()
set @retorno = 1

BEGIN TRY
      insert into ZL.SeriesIps
                  ( serie, ip, fecha ) 
        values ( @serie, @ip , @fecha  )
END TRY 


BEGIN CATCH
    SET  @retorno = 0
END CATCH

SELECT      'RetVal' = @retorno
END
