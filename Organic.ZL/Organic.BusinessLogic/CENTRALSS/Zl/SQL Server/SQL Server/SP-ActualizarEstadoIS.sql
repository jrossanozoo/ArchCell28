USE [ZL]
GO

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-ActualizarEstadoIS]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[sp-ActualizarEstadoIS] as ')
  end   

/****** Object:  StoredProcedure [ZL].[sp-ActualizarEstadoIS]    Script Date: 09/02/2009 10:18:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[sp-ActualizarEstadoIS]
	( @Fecha datetime,
      @Hora varchar(8),
      @NroSerie varchar(7),
      @CodigoDesactivacion varchar(40),
      @Usuario varchar(20),
      @Terminal varchar(30)
 )
AS

      BEGIN
            BEGIN TRANSACTION
				 BEGIN TRY
					exec [ZL].[sp-DesactivarISxSerie] @NroSerie, @Fecha
					exec [ZL].[sp-ActivarISxSerie] @NroSerie, @Fecha
					exec [ZL].[sp-RegistrarCodigoDesactivacion] @Fecha, @Hora, @NroSerie, @CodigoDesactivacion, @Usuario, @Terminal
				 END TRY
				 
				 BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000);
					DECLARE @ErrorSeverity INT;
					DECLARE @ErrorState INT;

					SELECT 
						  @ErrorMessage = char(13) + 'ATENCION!!! Error al intentar actualizar el estado del Item de Servicios. No se ha completado la operación. ' + char(13) + 'Motivo: ' + ERROR_MESSAGE(),
						  @ErrorSeverity = ERROR_SEVERITY(),
						  @ErrorState = ERROR_STATE();

					If ERROR_NUMBER() <> 0
						  BEGIN 
								RAISERROR (@ErrorMessage, -- Message text.
										@ErrorSeverity, -- Severity.
										@ErrorState -- State.
										);
						  END            
					END CATCH;
		

				IF ERROR_NUMBER() <> 0
					  BEGIN
						ROLLBACK TRANSACTION
						RETURN
					  END
	            
				COMMIT TRANSACTION
      END


GO


