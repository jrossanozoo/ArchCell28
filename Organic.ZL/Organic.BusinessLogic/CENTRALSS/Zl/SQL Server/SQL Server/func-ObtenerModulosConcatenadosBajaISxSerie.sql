Use [ZL]
go 

IF  NOT EXISTS ( 
      SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerModulosConcatenadosBajaISxSerie]') AND type in (N'FN'))
  begin  
    exec('create function [ZL].[ObtenerModulosConcatenadosBajaISxSerie] ( @NroSerie varchar(7) ) returns varchar(1000) begin declare @vCadena varchar(1000) set @vCadena = 0 return @vCadena end')
  end   
GO

USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[ObtenerModulosConcatenadosBajaISxSerie]    Script Date: 11/02/2009 17:24:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        <Author,,Name>
-- Create date: <Create Date, ,>
-- Description:   <Description, ,>
-- =============================================
alter FUNCTION [ZL].[ObtenerModulosConcatenadosBajaISxSerie]
(
      --  parameters for the function here
@NroSerie varchar(7)
  
)
RETURNS varchar(1000)
AS
BEGIN
      DECLARE @vCadena varchar(1000)

      -- T-SQL statements to compute the return value here
      
SELECT      @vCadena = COALESCE(@vCadena, '') + listado.ccod + ' - '

 
FROM 
(
   select dm.ccod, dm.Descr, count( dm.ccod ) as cantidad
            from ZL.Dmodart dm 
            left join ZL.Itemserv it on it.codart = dm.codigo 
            where it.nroserie = @NroSerie and ( ZL.[func-EsItemActivoSINActDesact]( it.ccod , getdate()) = 1)
            group by dm.ccod, dm.descr

) as listado

return '(' + substring( @vCadena,1,len(@vCadena)-1) + ')'

END


GO


