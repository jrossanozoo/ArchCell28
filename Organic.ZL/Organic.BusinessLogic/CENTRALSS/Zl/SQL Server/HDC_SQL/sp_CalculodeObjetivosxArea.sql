USE [ZL]
GO

/****** Object:  StoredProcedure [Objetivos].[sp_CalculodeObjetivosxArea]    Script Date: 05/09/2013 14:01:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[sp_CalculodeObjetivosxArea]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Objetivos].[sp_CalculodeObjetivosxArea]
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [Objetivos].[sp_CalculodeObjetivosxArea]    Script Date: 05/09/2013 14:01:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- Author:		Hector Daniel Correa
-- Create date: 07/05/2013
-- Description:	Levanta los PUESTOS segun el area parametrizada
-- ============================================================
CREATE PROCEDURE [Objetivos].[sp_CalculodeObjetivosxArea] 
	@FECHA DATETIME = GETDATE, 
	@AREA VARCHAR(3) = ''
AS
BEGIN
	SET NOCOUNT ON;
	IF @AREA <> ''
	BEGIN
		DECLARE @PUESTO VARCHAR(4);
		DECLARE AREAS CURSOR FOR
			SELECT 
				ZL.PUESTOSRH.COD AS PUESTOS
			FROM 
				ZL.AREA
				INNER JOIN ZL.PUESTOSRH ON ZL.PUESTOSRH.AREA = ZL.AREA.CODIGO
			WHERE
				ZL.AREA.CODIGO = @AREA;
		OPEN AREAS;
		FETCH NEXT FROM AREAS INTO @PUESTO;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @PUESTO IS NOT NULL AND @PUESTO <> ''
			BEGIN
				EXEC [Objetivos].[sp_CalculodeObjetivosxPuesto] @FECHA, @PUESTO;
			END
			FETCH NEXT FROM AREAS INTO @PUESTO;
		END
		CLOSE AREAS;
		DEALLOCATE AREAS;

		--UPDATEAMOS ACCIONES DE LA HERRAMIENTA DE CALCULO SI EXISTIESE EL COMPROBANTE POR AREA
		UPDATE [ZL].[ZL].[CALCOBJ] SET
			ACC = CONVERT(VARCHAR(MAX), 'Último cálculo: '+CONVERT(VARCHAR(20), GETDATE(), 103))+' '+CONVERT(VARCHAR(8), GETDATE(), 108)
			+CHAR(13)+CONVERT(VARCHAR(MAX), ACC)
		WHERE 
			[AREA] = @AREA; 
		
	END
END


GO

--DECLARE @FECHA DATETIME, @AREA VARCHAR(4);
--SET @FECHA = GETDATE(); SET @AREA = 'MDA ';
--EXEC ZL.[Objetivos].sp_CalculodeObjetivosxArea @FECHA, @AREA;


