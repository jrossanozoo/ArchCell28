IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[SeSuperponenLosSegmentosTemporales]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[SeSuperponenLosSegmentosTemporales];
GO;

/*
	Esta función determina si dos períodos de tiempo se superponen entre sí, los períodos están
	comprendidos por los parámetros [ @Periodo1Desde; @Periodo1Hasta ] para el primero y por
	[ @Periodo2Desde; @Periodo2Hasta ] para el segundo. Ambos segmentos temporales incluyen las 
	fechas de sus extremos.
	Si los períodos se superponen devuelve 1 ( uno ) de lo contrario devuelve 0 ( cero ).
*/

CREATE FUNCTION [Funciones].[SeSuperponenLosSegmentosTemporales]
	(
	@Periodo1Desde datetime,	-- Límite inferior del período 1
	@Periodo1Hasta datetime,	-- Límite superior del período 1
	@Periodo2Desde datetime,	-- Límite inferior del período 2
	@Periodo2Hasta datetime		-- Límite superior del período 2
	)
	returns int
AS
	begin
		declare @lRetorno int
		declare @lIndiceDeSuperposicion int

		begin
			set @lIndiceDeSuperposicion = sign( datediff( day, @Periodo1Desde, @Periodo2Desde ) )
										+ sign( datediff( day, @Periodo1Desde, @Periodo2Hasta ) )
										+ sign( datediff( day, @Periodo1Hasta, @Periodo2Desde ) )
										+ sign( datediff( day, @Periodo1Hasta, @Periodo2Hasta ) );
			
			if abs( @lIndiceDeSuperposicion ) = 4
				set @lRetorno = 0	-- No se superponen
			else
				set @lRetorno = 1	-- Se superponen
		end;

		return @lRetorno;
	end
	