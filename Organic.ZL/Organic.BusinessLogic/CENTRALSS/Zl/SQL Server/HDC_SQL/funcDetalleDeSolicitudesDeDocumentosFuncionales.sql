USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcDetalleDeSolicitudesDeDocumentosFuncionales]    Script Date: 08/28/2013 15:24:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcDetalleDeSolicitudesDeDocumentosFuncionales]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcDetalleDeSolicitudesDeDocumentosFuncionales]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcDetalleDeSolicitudesDeDocumentosFuncionales]    Script Date: 08/28/2013 15:24:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Héctor Daniel Correa
-- Create date: 29/08/2013
-- Description:	Retorna
-- =============================================
CREATE FUNCTION [ZL].[funcDetalleDeSolicitudesDeDocumentosFuncionales]
(
	@docfun as integer
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT
			SOLICNUM AS COMPSOLAPRO
			, CODIN AS COMPSOLNUM
			, FALTAFW AS COMPSOLALTA
			, NAPROV AS COMPSOLNUMAPROB
			, APROB AS COMPSOLCONFECC
			, FAPROB AS COMPSOLFAPROB
			, CASE ESTADO
				WHEN 1 THEN 'Si'
				ELSE 'No'
			END AS COMPSOLAUT
			, DOCFUN 
		FROM
			ZL.AproDocFun
		WHERE
			ZL.AproDocFun.DOCFUN = @docfun
)

GO
