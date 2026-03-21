IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[SituacionControlFlujoDeStock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[SituacionControlFlujoDeStock];
GO;
CREATE FUNCTION [Funciones].[SituacionControlFlujoDeStock]
( @EstadoTransOrigen varchar(30),
  @EstadoTransDestino varchar(30),
  @ComprobanteOrigen varchar(200),
  @ComprobanteDestino varchar(200),
  @BaseOrigen varchar(30),
  @BaseDestino varchar(30),
  @BaseDestinoAsignada varchar(30)
 )
RETURNS varchar (50)
AS
BEGIN
declare @retorno varchar (50)

set @retorno = case 
				when @EstadoTransOrigen = 'ENVIADO' and (@EstadoTransDestino = '' or @EstadoTransDestino is null) then 'No se encontró en destino'
				when @EstadoTransDestino = 'RECIBIDO' and (@EstadoTransOrigen = '' or @EstadoTransOrigen is null) then 'No se encontró en origen'
				when @EstadoTransOrigen = 'ENVIADO' and @EstadoTransDestino = 'RECIBIDO' then 'OK'
end;

if  @EstadoTransOrigen = 'ENVIADO' and @EstadoTransDestino = 'RECIBIDO' and @BaseDestinoAsignada != '' and @BaseDestinoAsignada != @BaseDestino
	set @retorno = 'Destino incorrecto';


return @retorno

END