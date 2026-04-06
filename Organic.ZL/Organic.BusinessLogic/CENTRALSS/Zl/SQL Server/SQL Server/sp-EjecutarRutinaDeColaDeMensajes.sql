Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-EjecutarRutinaDeColaDeMensajes]') AND type in (N'P', N'PC'))
  begin
    exec('create proc [ZL].[sp-EjecutarRutinaDeColaDeMensajes] as ')
  end

/****** Object:  StoredProcedure [ZL].[sp-EjecutarRutinaDeColaDeMensajes]    Script Date: 01/09/2009 17:21:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[sp-EjecutarRutinaDeColaDeMensajes]

as

Begin 

	DECLARE @Maquina varchar(254), @Buzon varchar(100), @text nvarchar(1024), @cBuzonMQ varchar(254), @Marca varchar(50), @LongitudMarca int

	DECLARE cBuzones CURSOR FOR
	SELECT Maquina, Buzon
	FROM [ZL].[BuzonesMessageQueue]

	OPEN cBuzones
	
	FETCH NEXT FROM cBuzones
	INTO @Maquina, @Buzon

	Set @Marca = '[ZL].[sp-ActualizarEstadoIS]'
	Set @LongitudMarca = len( @Marca )

	WHILE @@FETCH_STATUS = 0
	BEGIN

		Set @text = @Marca
		Set @cBuzonMQ = funciones.Alltrim( @Maquina ) + '\' + funciones.Alltrim( @Buzon )

		WHILE ( substring( @text, 1, @LongitudMarca ) = @Marca )
			BEGIN
				EXEC [ZL].[EjecutarSentenciaDeColaDeMensaje] @cBuzonMQ, @msg = @text OUTPUT
				IF substring( @text, 1, @LongitudMarca ) <> @Marca
					BREAK
				ELSE
					exec ( @text )
					CONTINUE
			END
	
		FETCH NEXT FROM cBuzones
		INTO @Maquina, @Buzon
	END

	CLOSE cBuzones
	DEALLOCATE cBuzones 			
end