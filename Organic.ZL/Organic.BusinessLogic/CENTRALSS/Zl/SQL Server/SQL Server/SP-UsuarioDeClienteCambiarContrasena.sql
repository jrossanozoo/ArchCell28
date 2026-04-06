USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[SP-UsuarioDeClienteCambiarContrasena]    Script Date: 12/21/2009 12:37:26 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SP-UsuarioDeClienteCambiarContrasena]') AND type in (N'P', N'PC'))
	BEGIN
	exec('CREATE PROCEDURE [ZL].[SP-UsuarioDeClienteCambiarContrasena] @IVR_CLI_USER varchar(60), @IVR_CLI_NEW_PASS varchar(60) AS BEGIN DECLARE @Resultado bit SET @Resultado = 0 SELECT @Resultado AS Resultado END')
	END
GO


USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[SP-UsuarioDeClienteCambiarContrasena]    Script Date: 12/21/2009 12:37:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		MatiasB
-- Create date: 21/12/2009
-- Description:	Valida existencia de usuario de IVR pasado por parámetro
--				Devuelve 1 si se pudo establecer nueva contraseña, 0 caso contrario.
/* Ejemplo 
DECLARE @RC BIT					SET @RC = 0
DECLARE @MENSAJE VARCHAR(500)	SET @MENSAJE =''

BEGIN TRY
	EXEC @RC = [ZL].[SP-UsuarioDeClienteCambiarContrasena] '0000119','5358'
END TRY

BEGIN CATCH
    SET  @MENSAJE = (SELECT ERROR_MESSAGE() )
END CATCH

SELECT @RC, @MENSAJE
*/


-- =============================================
ALTER PROCEDURE [ZL].[SP-UsuarioDeClienteCambiarContrasena]
	
	@IVR_CLI_USER varchar(60),
	@IVR_CLI_NEW_PASS varchar(60)

WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
		DECLARE @Resultado bit

		DECLARE @CadenaOKuser bit
		DECLARE @CadenaOKpass bit

		--Valida que la cadena de texto este compuesta unicamente por números o letras ASCII
		SET @CadenaOKuser  = ZL.funcValidarCadenaUsuario (@IVR_CLI_USER)
		SET @CadenaOKpass  = ZL.funcValidarCadenaUsuario (@IVR_CLI_NEW_PASS)

		IF  (@CadenaOKuser=1 and @CadenaOKpass=1)
			
				
				IF exists (	SELECT  
								LTRIM(RTRIM(cast(usu_cod as varchar(60)))) as Usuario
								,LTRIM(RTRIM(usu_pw))  as Pass
							FROM ZL.Usuivrweb   
							WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER
							)
					--usuario ivr existe
							
							BEGIN 
									  UPDATE ZL.Usuivrweb
									  SET usu_pw = @IVR_CLI_NEW_PASS
									  WHERE  LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER
									  SET @Resultado = 1																		  
							END
					ELSE 								
								BEGIN
								SET @Resultado = 0
								RAISERROR (50002, 16,1)
								RETURN	
								END				
						
			
			ELSE --NO SON DATOS VALIDOS		 
					BEGIN
					SET @Resultado = 0
					RAISERROR(50001, 16,1)
					RETURN
					END					

	RETURN @Resultado

END

GO


