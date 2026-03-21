IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[AgregarAUnTextoRepeticionesDeOtroTexto]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[AgregarAUnTextoRepeticionesDeOtroTexto];
GO;

CREATE FUNCTION [Funciones].[AgregarAUnTextoRepeticionesDeOtroTexto]
	( 
	@TextoBase varchar(max),
	@TextoAAgregar varchar(20),
	@Repeticiones int,
	@EsSufijo bit	-- cuando es 0 se agrega como prefijo, cuando es 1 como sufijo
	)
RETURNS varchar(max)
AS
BEGIN
	declare @retorno varchar(max) = replicate(@TextoAAgregar, @Repeticiones * (1 - @EsSufijo)) + @TextoBase + replicate(@TextoAAgregar, @Repeticiones * @EsSufijo)

	return @retorno
END