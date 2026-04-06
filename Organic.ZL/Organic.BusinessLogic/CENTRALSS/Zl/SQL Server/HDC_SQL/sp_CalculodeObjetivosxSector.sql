USE [ZL]
GO

/****** Object:  StoredProcedure [Objetivos].[sp_CalculodeObjetivosxSector]    Script Date: 05/09/2013 14:05:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[sp_CalculodeObjetivosxSector]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Objetivos].[sp_CalculodeObjetivosxSector]
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [Objetivos].[sp_CalculodeObjetivosxSector]    Script Date: 05/09/2013 14:05:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- Author:		Hector Daniel Correa
-- Create date: 07/05/2013
-- Description:	Levanta las AREAS segun el sector parametrizada
-- ============================================================
CREATE PROCEDURE [Objetivos].[sp_CalculodeObjetivosxSector] 
	@FECHA DATETIME = GETDATE, 
	@SECTOR VARCHAR(3) = ''
AS
BEGIN
	SET NOCOUNT ON;
	IF @SECTOR <> ''
	BEGIN
		DECLARE @AREA VARCHAR(3);
		DECLARE SECTORES CURSOR FOR
		SELECT 
			ZL.AREA.CODIGO AS AREAS
		FROM 
			ZL.SECTORES
			INNER JOIN ZL.AREA ON ZL.AREA.SECTOR = ZL.SECTORES.CODIGO
		WHERE
			ZL.SECTORES.CODIGO = @SECTOR;
		OPEN SECTORES;
		FETCH NEXT FROM SECTORES INTO @AREA;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @AREA IS NOT NULL AND @AREA <> ''
			BEGIN
				EXEC [Objetivos].[sp_CalculodeObjetivosxArea] @FECHA, @AREA;
			END
			FETCH NEXT FROM SECTORES INTO @AREA;
		END
		CLOSE SECTORES;
		DEALLOCATE SECTORES;
	END
END


GO

--DECLARE	@FECHA DATETIME, @SECTOR VARCHAR(4);
--SET @FECHA = GETDATE(); SET @SECTOR = 'SAL ';
--EXEC ZL.[Objetivos].[sp_CalculodeObjetivosxSector] @FECHA, @SECTOR;