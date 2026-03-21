IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[zPromocionVigenteEnElPeriodo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[zPromocionVigenteEnElPeriodo];
GO;

/*
	Esta función determina si un promoción está vigente en un período determinado para poder filtrarlas.
	Hace uso de la función "SeSuperponenLosSegmentosTemporales( @P1Desde, @P1Hasta, @P2Desde, @P2Hasta )"
	Como el ADNImpant impacta las funciones en la base de datos en orden alfabético, para evitar que esta
	función se impacte antes de SeSuperponenLosSegmentosTemporales, se agrega "z" como prefijo al nombre.
*/

CREATE FUNCTION [Funciones].[zPromocionVigenteEnElPeriodo]
	(
	@FechaFiltroInicial varchar(10),	-- Fecha inicial del período de referencia.
	@FechaFiltroFinal 	varchar(10),	-- Fecha final del período de referencia.
	@VigenciaPromocionDesde datetime,	-- Inicio de la vigencia de la promoción
	@VigenciaPromocionHasta datetime	-- Fin de la vigencia de la promoción.
	)
	returns int
AS
	begin
		declare @Retorno int
	
		if ( ( len( @FechaFiltroInicial ) > 0 ) and ( isdate( @FechaFiltroInicial ) = 0 ) ) or ( ( len( @FechaFiltroFinal ) > 0 ) and ( isdate( @FechaFiltroFinal ) = 0 ) )
			set @Retorno = 1
		else
			begin
				declare @FechaInicial datetime
				declare @FechaFinal datetime
				
				set @FechaInicial = convert( date, @FechaFiltroInicial )
				set @FechaFinal = convert( date, @FechaFiltroFinal )
				
				set @Retorno = Funciones.SeSuperponenLosSegmentosTemporales( 
																			@FechaInicial, 
																			@FechaFinal, 
																			@VigenciaPromocionDesde, 
																			@VigenciaPromocionHasta 
																			)
			end
		
		return @Retorno
	end
