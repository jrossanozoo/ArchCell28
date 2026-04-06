USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcObtenerNombreUsuario]    Script Date: 04/08/2010 11:04:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerNombreUsuario]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcObtenerNombreUsuario]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcObtenerNombreUsuario]    Script Date: 04/08/2010 11:04:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		gavalos

-- Description:	Obtiene los items facturables a una fecha
-- =============================================
CREATE FUNCTION [ZL].[funcObtenerNombreUsuario]
(
	@codigo varchar(8) 
)
RETURNS TABLE 
AS
RETURN 
(
	select usu_nom from zl.Usuivrweb where usu_cod = @codigo 
)


GO


