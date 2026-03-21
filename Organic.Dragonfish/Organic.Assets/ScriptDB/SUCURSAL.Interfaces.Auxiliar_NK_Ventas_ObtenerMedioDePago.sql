IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_NK_Ventas_ObtenerMedioDePago]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_NK_Ventas_ObtenerMedioDePago];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_NK_Ventas_ObtenerMedioDePago]
(
	@CantidadEfectivo int,
	@CantidadTarjeta int,
	@CantidadOtros int,
	@CantidadCuotasDistintas int
)
returns varchar(5)     
as     
begin
	return 
		case when @CantidadOtros > 0 or @CantidadCuotasDistintas > 1 then 'O'
			 when @CantidadEfectivo > 0 and @CantidadTarjeta > 0 then 'E/T'
			 when @CantidadEfectivo > 0 then 'E'
			 when @CantidadTarjeta > 0 then 'T'
		end
end