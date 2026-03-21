IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerUltimaFechaDeIngresoAStock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerUltimaFechaDeIngresoAStock];
GO;

CREATE FUNCTION [Funciones].[ObtenerUltimaFechaDeIngresoAStock]
	( 
	@Articulo varchar(100),
	@Color varchar(50),
	@Talle varchar(50)
	)
	returns datetime
AS
	begin
		declare @FechaDeAuditoria datetime;
		
		set @FechaDeAuditoria = 
			(
			select top 1 c_final.adt_fecha 
			from 
				(
				select c_adtcomb.adt_fecha, c_adtcomb.coart, c_adtcomb.cocol, c_adtcomb.talle
				from Zoologic.adt_comb as c_adtcomb
				left join 
					(
					select c_mstock.descfw
					from Zoologic.mstock as c_mstock
					where c_mstock.dirmov = 1
					) as c_mstock 
				on c_mstock.descfw = c_adtcomb.adt_comp
				left join 
					(
					select c_faccompra.descfw
					from Zoologic.faccompra as c_faccompra
					where c_faccompra.signomov = -1
					) as c_faccompra 
				on c_faccompra.descfw = c_adtcomb.adt_comp
				left join 
					(
					select c_remcompra.descfw
					from Zoologic.remcompra as c_remcompra
					where c_remcompra.signomov = -1
					) as c_remcompra 
				on c_remcompra.descfw = c_adtcomb.adt_comp
			where 1=1
				and ( c_adtcomb.adt_comp like 'REMITODECOMPRA%' or c_adtcomb.adt_comp like 'FACTURADECOMPRA%' or c_adtcomb.adt_comp like 'MOVIMIENTODESTOCK%' )
				and ( c_mstock.descfw is not null or c_faccompra.descfw is not null or c_remcompra.descfw is not null ) 
				and c_adtcomb.coart = @Articulo 
				and c_adtcomb.cocol = @Color 
				and c_adtcomb.talle = @Talle
			) as c_final 
			order by c_final.adt_fecha desc
		)
		
		if isdate( @FechaDeAuditoria ) = 0 set @FechaDeAuditoria = convert(datetime,'1900-01-01');
		
		return @FechaDeAuditoria
	end
