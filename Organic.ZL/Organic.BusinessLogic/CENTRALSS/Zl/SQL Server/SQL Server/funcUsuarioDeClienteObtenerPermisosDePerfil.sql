USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcUsuarioDeClienteObtenerPermisosDePerfil]    Script Date: 12/28/2009 10:06:55 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcUsuarioDeClienteObtenerPermisosDePerfil]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
EXECUTE ('CREATE FUNCTION [ZL].[funcUsuarioDeClienteObtenerPermisosDePerfil] (@USUARIO varchar(60)) RETURNS  bit AS  BEGIN DECLARE @CambioHW bit  SET @CambioHW = 0 RETURN @CambioHW END ' )
END

GO



USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[funcUsuarioDeClienteObtenerPermisosDePerfil]    Script Date: 03/18/2010 10:14:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		MatiasB
-- Create date: 24/12/2009
-- Description:	Define si un usuario puede obtener código con xx letra y con cambio de hw
-- Ejemplo:		select ZL.funcUsuarioDeClienteObtenerPermisosDePerfil (2,2)
-- =============================================

ALTER FUNCTION [ZL].[funcUsuarioDeClienteObtenerPermisosDePerfil] 
(
	-- Add the parameters for the function here
	@USUARIO varchar(60)
		
)
RETURNS bit
AS
BEGIN
	
	DECLARE @PerfilCod varchar(4)
	DECLARE @CambioHW bit
	SET @CambioHW = 0
		
	SELECT @PerfilCod = USU_PERFIL 
				FROM ZL.Usuivrweb 
				WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @USUARIO 
		--
		IF @PerfilCod IN ('0001','0002')
			SET @CambioHW = 1
		
	RETURN @CambioHW
END
