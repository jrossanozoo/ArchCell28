USE [ZL]
GO

/****** Object:  StoredProcedure [Objetivos].[sp_devolverOBSQL]    Script Date: 04/22/2013 15:02:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[sp_devolverOBSQL]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Objetivos].[sp_devolverOBSQL]
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [Objetivos].[sp_devolverOBSQL]    Script Date: 04/22/2013 15:02:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Objetivos].[sp_devolverOBSQL] 
	
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE @RETORNO NUMERIC(10, 5);
	--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[valor]') AND type in (N'U')) DROP TABLE [Objetivos].[valor];

	--CREATE TABLE valor(VALOR NUMERIC(10,5));
	--INSERT INTO valor EXEC sp_executesql @OBJESQL;
	--SET @RETORNO = (SELECT VALOR FROM valor);
	--DELETE FROM valor;

	SELECT * FROM ;
END

GO


