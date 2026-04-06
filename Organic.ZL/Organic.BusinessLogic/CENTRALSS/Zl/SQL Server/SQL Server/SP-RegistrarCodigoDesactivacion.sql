Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-RegistrarCodigoDesactivacion]') AND type in (N'P', N'PC'))
  begin
    exec('create proc [ZL].[sp-RegistrarCodigoDesactivacion] as ')
  end

/****** Object:  StoredProcedure [ZL].[sp-InsertarRegCodDesact]    Script Date: 01/09/2009 17:21:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[sp-RegistrarCodigoDesactivacion]
      @Fecha datetime,
      @Hora varchar(8),
      @NroSerie varchar(7),
      @CodigoDesactivacion varchar(40),
      @Usuario varchar(20),
      @Terminal varchar(30)

AS
      BEGIN
            BEGIN TRANSACTION
                  Insert into ZL.Regcoddesact( Fecha, Hora, NroSerie, CodDesact, Usuario, Terminal )
                  Values( @Fecha, @Hora, @NroSerie, @CodigoDesactivacion, @Usuario, @Terminal )
            IF @@error <> 0
                  BEGIN
            ROLLBACK TRANSACTION
            RETURN
                  END
            COMMIT TRANSACTION
      END
GO