USE [ZL]
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-UsuarioDeClienteValidarAcceso]') AND type in (N'P', N'PC'))
	BEGIN
	
	EXEC ('CREATE PROCEDURE [ZL].[sp-UsuarioDeClienteValidarAcceso] @IVR_CLI_USER varchar(60), @IVR_CLI_PASS varchar(60) AS BEGIN  DECLARE @Resultado bit SET @Resultado = 0 	RETURN @Resultado END')
	END
	
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[sp-UsuarioDeClienteValidarAcceso]    Script Date: 01/18/2010 15:48:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		MatiasB
-- Create date: 18/01/2010
-- Description:	Valida Usr y Passwd. 
--				Mantiene la cantidad de intentos del usuario, bloquea en caso de llegar a 3
--				Valida el estado del cliente a través de los estados/permisos  de la razón social

/* Ejemplo 

DECLARE @RC BIT					SET @RC = 0
DECLARE @MENSAJE VARCHAR(500)	SET @MENSAJE =''

BEGIN TRY
	EXEC @RC = [ZL].[sp-UsuarioDeClienteValidarAcceso]  '0000119', '5358'
END TRY

BEGIN CATCH
    SET  @MENSAJE = (SELECT ERROR_MESSAGE() )
END CATCH

SELECT @RC, @MENSAJE
*/

-- =============================================
ALTER PROCEDURE [ZL].[sp-UsuarioDeClienteValidarAcceso] 
	-- Add the parameters for the stored procedure here
	@IVR_CLI_USER varchar(60),
	@IVR_CLI_PASS varchar(60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Resultado bit
	DECLARE @PassUsu varchar(60)
	DECLARE @Cliente varchar(5)
	DECLARE @Bloqueado bit
	DECLARE @Intentos NUMERIC(1,0)
	
	
	SET @IVR_CLI_USER = LTRIM(RTRIM(@IVR_CLI_USER))
	SET @IVR_CLI_PASS = LTRIM(RTRIM(@IVR_CLI_PASS))
	SET @Resultado = 0
	

	DECLARE @CadenaOKuser bit
	DECLARE @CadenaOKpass bit

	--Valida que la cadena de texto este compuesta unicamente por números o letras ASCII, 
	--sin espacios ni símbolos ni tildes
	SET @CadenaOKuser  = ZL.funcValidarCadenaUsuario (@IVR_CLI_USER)
	SET @CadenaOKpass  = ZL.funcValidarCadenaUsuario (@IVR_CLI_PASS)

		
	IF  (@CadenaOKuser=1 and @CadenaOKpass=1)

				BEGIN --CADENA OK
					
					IF NOT EXISTS (SELECT USU_COD FROM ZL.Usuivrweb  WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER )
								BEGIN --usuario no encontrado
										SET @Resultado = 0
										RAISERROR (50002, 16,1)
										RETURN
								END								
					ELSE
						BEGIN --usuario encontrado
							SELECT  
							@PassUsu = LTRIM(RTRIM(usu_pw)) ,
							@Cliente = usu_cli,
							@Bloqueado = usu_bloq,
							@Intentos = usu_inte
							
							FROM ZL.Usuivrweb   
									WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER
	
						IF @PassUsu <> @IVR_CLI_PASS
								IF @Bloqueado = 1
									BEGIN --usuario bloqueado
										SET @Resultado = 0
										RAISERROR (60004, 16,1)
										RETURN
									END
									ELSE BEGIN --no está bloqueado pero la paws esta mal
											IF @Intentos >= 2 
													BEGIN 
													SET @Resultado = 0
													UPDATE ZL.Usuivrweb   
														SET Usu_Inte = 0,
															Usu_Bloq = 1												
														WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER
													RAISERROR (60005, 16,1)
													RETURN
													END
												ELSE
													BEGIN
													SET @Resultado = 0
													UPDATE ZL.Usuivrweb   
														SET Usu_Inte = Usu_Inte + 1												
														WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER
													RAISERROR (50002, 16,1)
													RETURN
													END
											END
								ELSE 	
									 --USU Y PASSW OK
									IF EXISTS (	SELECT		ultestado.NRZ FROM
															Zl.admestadoRS() as ultestado join zl.razonsocial 
															on ultestado.nrz = razonsocial.cmpcod
															where razonsocial.cliente = @Cliente
																	and [Dar Código] = 1
												UNION ALL
												
												SELECT permiso.razonsoc
													FROM zl.aatmda as permiso
													join zl.razonsocial on permiso.razonsoc = razonsocial.cmpcod
													join zl.estado as esta on esta.codigo = permiso.cestado
												WHERE permiso.cmpfecfin  >= DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) 
														and razonsocial.cliente = @Cliente
														and esta.dacodigo = 1
												)
										BEGIN											
											UPDATE ZL.Usuivrweb   
												SET Usu_Inte = 0
											WHERE LTRIM(RTRIM(cast(usu_cod as varchar(60)))) = @IVR_CLI_USER	
											
											SET @Resultado = 1									
										END
										ELSE BEGIN
											 SET @Resultado = 0
											 RAISERROR (60003,16,1)
											 RETURN
											 END
									
																				
							END --usuario encontrado					
					END --CADENA OK													
	
	ELSE
			BEGIN
				SET @Resultado = 0
				RAISERROR (50001, 16,1)
				RETURN
			END
	
	RETURN @Resultado

END



GO

