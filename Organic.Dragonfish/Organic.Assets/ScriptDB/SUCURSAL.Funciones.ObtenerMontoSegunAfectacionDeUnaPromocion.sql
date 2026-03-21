IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoSegunAfectacionDeUnaPromocion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMontoSegunAfectacionDeUnaPromocion];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoSegunAfectacionDeUnaPromocion]
	(
	@IDComprobante as char(38),
	@IDItemPromocion varchar(38),
	@TipoDeAfectacion int	-- 0 Monto Bruto
							-- 1 Monto del comprobante sin promociones aplicadas 
							-- 2 Monto del comprobante afectado por una promocion específica
							-- 3 Otros descuentos
							-- 4 Recargos
							-- 5 Notas de crédito por promos bancarias
							-- 6 Notas de crédito por promos bancarias pendientes
							-- 7 Monto total del comprobante
	)
RETURNS numeric(15, 2)
AS
begin
	declare @retorno numeric(15, 2)
	declare @signo 	numeric( 2,0)	-- Signo del comprobante
	declare  @monto0 numeric(15,2)	-- Monto Bruto
			,@monto1 numeric(15,2)	-- Monto afectado por la promocion
			,@monto2 numeric(15,2)	-- Monto fuera de las promociones
			,@monto3 numeric(15,2)	-- Descuentos en línea fuera de las promociones
			,@monto4 numeric(15,2)	-- Descuentos del comprobante
			,@monto5 numeric(15,2)	-- Recargos del comprobante
			,@monto6 numeric(15,2)	-- Notas de credito por promos bancarias
			,@monto7 numeric(15,2)	-- Notas de credito por promos bancarias pendientes
			,@monto8 numeric(15,2)	-- Monto Total

	if ( @TipoDeAfectacion >= 0 and @TipoDeAfectacion <= 7 )
		select @signo = signomov from ZooLogic.COMPROBANTEV where codigo = @IDComprobante
		
		if ( @TipoDeAfectacion < 5 ) or ( @TipoDeAfectacion > 6 )
			select   @monto0 = coalesce( sum( ia.PRUNCONIMP * ia.FCANT ), 0)
					,@monto1 = coalesce( sum( case when rap.IDPROMO = @IDItemPromocion then ia.PRUNCONIMP * ia.FCANT else 0 end ), 0)
					,@monto2 = coalesce( sum( case when len(rtrim(rap.IDPROMO)) > 0 then ia.PRUNCONIMP * ia.FCANT else 0 end  ), 0)
					,@monto3 = coalesce( sum( case when len(rtrim(rap.IDPROMO)) > 0 then 0 else ia.MNDESCI + ia.FCFITOT end  ), 0)
					,@monto4 = coalesce( sum( ia.MNTPDESCI ), 0)
					,@monto5 = coalesce( sum( ia.MNTPRECCI ), 0)
					,@monto8 = coalesce( sum( ia.MNTPTOT ), 0)
			from ZooLogic.COMPROBANTEVDET as ia 
				left join ZooLogic.PROARTDET as rap on rap.CODIGO = ia.CODIGO and rap.IDARTI = ia.IDITEM
			where ia.CODIGO = @IDComprobante
		else
			select 	 @monto6 = coalesce( nc.BENEFICIO, 0 )
					,@monto7 = case when coalesce( nc.REFERENCIA, '' ) = '' then dp.BENEFICIO else 0 end
			from ZooLogic.PROMDET as dp
				inner join ZooLogic.COMPROBANTEV as cp on cp.CODIGO = dp.CODIGO
				left join (
							select upper( rtrim(FTXT)) as REFERENCIA, sum(MNTPTOT) as BENEFICIO 
							from ZooLogic.COMPROBANTEVDET 
							group by FTXT 
							) as nc 
							on nc.REFERENCIA = upper( rtrim('Descuento Bancario Comp. ' + cp.FLETRA + '-' + Funciones.padl( cp.FPTOVEN, 4, '0' ) + '-' + Funciones.padl( cp.FNUMCOMP, 8, '0' ))) 
								and nc.BENEFICIO = dp.BENEFICIO
			where dp.TIPO = 5 and dp.CODIGO = @IDComprobante and dp.IDITEM = @IDItemPromocion;
	
	set @retorno = 	case 
						when @TipoDeAfectacion = 0 then
							@monto0 				-- 0 Monto Bruto
						when @TipoDeAfectacion = 1 then
							@monto0 - @monto2		-- 1 Monto del comprobante sin promociones aplicadas
						when @TipoDeAfectacion = 2 then
							@monto1 				-- 2 Monto del comprobante afectado por una promocion específica
						when @TipoDeAfectacion = 3 then
							-( @monto3 + @monto4 )	-- 3 Otros descuentos
						when @TipoDeAfectacion = 4 then
							@monto5					-- 4 Recargos
						when @TipoDeAfectacion = 5 then
							@monto6					-- 5 Notas de crédito por promos bancarias
						when @TipoDeAfectacion = 6 then
							@monto7					-- 6 Notas de crédito por promos bancarias pendientes
						when @TipoDeAfectacion = 7 then
							@monto8					-- 7 Monto total del comprobante
						else
							0
					end * @signo;
	
	return @retorno
end
