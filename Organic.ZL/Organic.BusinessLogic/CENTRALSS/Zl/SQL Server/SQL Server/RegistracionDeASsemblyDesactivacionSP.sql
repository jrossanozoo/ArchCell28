use zl
GO

sp_configure 'clr enabled', 1
GO

RECONFIGURE
GO

ALTER DATABASE ZL SET TRUSTWORTHY ON;
GO

RECONFIGURE
GO

USE ZL

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObtenerRetorno]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[ObtenerRetorno]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CalcularValores]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[CalcularValores]
GO

IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'ZooLogicSA.DesactivacionSP')
      DROP ASSEMBLY [ZooLogicSA.DesactivacionSP]
GO

CREATE ASSEMBLY [ZooLogicSA.DesactivacionSP]
FROM 'c:\ZooLogicSA.DesactivacionSP.dll' --Agregar ruta--
WITH PERMISSION_SET = UNSAFE;
GO

CREATE PROCEDURE [dbo].[ObtenerRetorno]
      @usuario [nvarchar](4000),
      @letra [nvarchar](4000),
      @desactivacion [nvarchar](4000),
      @origen [nvarchar](4000),
      @ipWeb [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [ZooLogicSA.DesactivacionSP].[UserDefinedFunctions].[ObtenerRetorno]
GO

CREATE PROCEDURE [dbo].[CalcularValores]
      @build [nvarchar](5),
      @enviaPipe [bit]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [ZooLogicSA.DesactivacionSP].[GeneradorPosicionesIniciales].[CalcularValores]
GO
