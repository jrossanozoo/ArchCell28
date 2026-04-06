USE [ZL]
GO

/****** Object:  Trigger [UpdateFichajes]    Script Date: 07/18/2013 18:02:00 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[ZL].[UpdateFichajes]'))
DROP TRIGGER [ZL].[UpdateFichajes]
GO

USE [ZL]
GO

/****** Object:  Trigger [ZL].[UpdateFichajes]    Script Date: 07/18/2013 18:02:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================
-- Author:		Daniel Correa
-- Create date: 18/07/2013
-- Description:	Updatea los campos restantes durante la
--              migracion de los fichajes desde ZNube
-- ====================================================
CREATE TRIGGER [ZL].[UpdateFichajes] 
   ON  [ZL].[ZNFICHAJE] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	UPDATE [ZL].[ZNFICHAJES]
		SET CODPUESTO = (SELECT CODPUESTO FROM [ZL].[Objetivos].[func_RRHH_UpdateFichaje](INSERTED.LEGAJO, GETDATE()))
	WHERE
		[ZL].[ZNFICHAJES].[COD] = INSERTED.[COD]
		

END

GO


