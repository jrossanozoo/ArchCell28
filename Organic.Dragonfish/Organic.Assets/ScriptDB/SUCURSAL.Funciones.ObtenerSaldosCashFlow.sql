IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerSaldosCashFlow]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerSaldosCashFlow];
GO;

CREATE FUNCTION [Funciones].[ObtenerSaldosCashFlow]
(@Parametro1 varchar(max), 
 @FACTURA_FECHA_DESDE  date,
 @FACTURA_FECHA_HASTA date)
RETURNS TABLE
AS

RETURN
(
	select	convert( date,FACTURA_FFCH,103) as factura_ffch,
		sum(ingreso) as ingreso, 
		sum(egreso) as egreso
	from 
	(
		--------------------------------------------------------  SALDO INGRESOS  ----------------------------------------------------------------------------
	--	select c_regcta.FECHA AS FACTURA_FFCH,
	--		c_regcta.IMPORTE as ingreso,
	--		0 as egreso
	--	from zoologic.REGCTA c_regcta
	--		left join zoologic.detregcon c_detregcon on c_regcta.codigo = c_detregcon.reg
	--		left join zoologic.CTABAN as c_ctaban on c_ctaban.cbcod = c_regcta.ctabanc
	--	where ( 1=1) and c_detregcon.codigo is not null -- and c_regcta.pendiente = 0
	--		and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_regcta.FECHA >= @FACTURA_FECHA_DESDE ) ) 
	--		and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_regcta.FECHA <= @FACTURA_FECHA_HASTA ) )

	--union all

		select 
			case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_factura.FFCH) else Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			c_itemvalores.montosiste as ingreso, --pesificado
			0 as egreso
		from ZooLogic.VAL as c_itemvalores
			left join ZooLogic.COMPROBANTEV as c_factura on c_factura.CODIGO = c_itemvalores.JJNUM and 0 = Funciones.empty( c_itemvalores.JJNUM )
 			left join ZooLogic.XVAL as c_valor on c_valor.CLCOD = c_itemvalores.JJCO and 0 = Funciones.empty( c_itemvalores.JJCO )
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_factura.CODIGO is not null and c_factura.facttipo IN (1,2,27,33,47,54,4,6,29,36,49,56) -- FACTURA Y NOTA DE DEBITO DE VENTA
			and ( c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ) )
			and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_ITEMVALORES.jjfe >= @FACTURA_FECHA_DESDE ) )  
			and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_ITEMVALORES.jjfe <= @FACTURA_FECHA_HASTA ) )

	union all

		select 
		case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_factura.FFCH) else Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			c_itemvalores.montosiste as ingreso,
			0 as egreso
		from ZooLogic.VALNCCOMP as c_itemvalores
			left join ZooLogic.NCCOMPRA as c_factura on c_factura.CODIGO = c_itemvalores.JJNUM and 0 = Funciones.empty( c_itemvalores.JJNUM )
 			left join ZooLogic.XVAL as c_valor on c_valor.CLCOD = c_itemvalores.JJCO and 0 = Funciones.empty( c_itemvalores.JJCO )
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_factura.CODIGO is not null
			and (c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ) )
			and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_ITEMVALORES.jjfe >= @FACTURA_FECHA_DESDE ) )  
			and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_ITEMVALORES.jjfe <= @FACTURA_FECHA_HASTA ) )

	union all

		select 
		Funciones.ObtenerFechaDiaOMes(@Parametro1,factura_ffch) as factura_ffch,
			ingreso,
			egreso
		from (
			select 
				case when c_ITEMVALORES.jjfecha = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_comcaj.fecha) else  Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfecha) end as FACTURA_FFCH,
				abs(c_itemvalores.monto) * Funciones.ObtenerCotizacion( getdate(), c_valor.clsmonet ) as ingreso,
				0 as egreso
			from zoologic.COMPCAJADET as c_itemvalores
				left join Zoologic.COMCAJ as c_comcaj on c_comcaj.codigo = c_itemvalores.coddetval 
				LEFT JOIN Zoologic.CONCECAJA as c_concecaja on c_concecaja.CODIGO = c_comcaj.CONCEPTO and 0 = Funciones.empty( c_comcaj.CONCEPTO )
				inner join ZooLogic.XVAL as c_valor on c_valor.clcod = c_itemvalores.codval 
			where ( 1=1 ) and c_itemvalores.coddetval is not null and 
				( ( c_comcaj.TIPO = 1 and c_itemvalores.ctotal > 0 ) or (c_comcaj.tipo = 2 and c_itemvalores.ctotal < 0 )) -- INGRESOS => Tipo1:Entrada con monto positivo o Tipo2:Salida con monto negativo
			) INGCompCaja
			where ( ( @FACTURA_FECHA_DESDE is null ) or ( FACTURA_FFCH >= @FACTURA_FECHA_DESDE ) )  
				and ( ( @FACTURA_FECHA_HASTA is null ) or ( FACTURA_FFCH <= @FACTURA_FECHA_HASTA ) )

	union all

		select 	Funciones.ObtenerFechaDiaOMes(@Parametro1,FACTURA_FFCH) as FACTURA_FFCH,
		ingreso,
		egreso
	from (
		select case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00' then Funciones.ObtenerFechaDiaOMes(@Parametro1,@FACTURA_FECHA_DESDE) else Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			c_itemvalores.jjm * Funciones.ObtenerCotizacion( getdate(), c_valor.clsmonet ) as ingreso,
			0 as egreso
		from zoologic.CANJECUPONESDET as c_ITEMVALORES
			left join ZooLogic.XVAL as c_VALOR on c_VALOR.CLCOD = c_ITEMVALORES.JJCO and 0 = Funciones.empty( c_ITEMVALORES.JJCO ) 
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_ITEMVALORES.jjt is not null   -- Canje de valores entrantes
		and ( c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ))
		) IngresosCanje
		where  ( ( @FACTURA_FECHA_DESDE is null ) or ( FACTURA_FFCH >= @FACTURA_FECHA_DESDE ) )  
		and ( ( @FACTURA_FECHA_HASTA is null ) or ( FACTURA_FFCH <= @FACTURA_FECHA_HASTA ) )

	union all

		---------------------------------------------  SALDO EGRESOS  ----------------------------------------------------------------------------

		select 
		case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_factura.FFCH) else  Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			0 as ingreso,
			c_itemvalores.montosiste as egreso
		from ZooLogic.VAL as c_itemvalores 
			left join ZooLogic.COMPROBANTEV as c_factura on c_factura.CODIGO = c_itemvalores.JJNUM and 0 = Funciones.empty( c_itemvalores.JJNUM )
 			left join ZooLogic.XVAL as c_valor on c_valor.CLCOD = c_itemvalores.JJCO and 0 = Funciones.empty( c_itemvalores.JJCO )
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_factura.CODIGO is not null and c_factura.facttipo IN (3,5,28,35,48,55) -- NOTA DE CREDITO DE VENTA
			and (c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ) )
			and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_ITEMVALORES.jjfe >= @FACTURA_FECHA_DESDE ) )  
			and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_ITEMVALORES.jjfe <= @FACTURA_FECHA_HASTA ) )

	union all

		select 
			case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_factura.FFCH) else  Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			0 as ingreso,
			c_itemvalores.montosiste as egreso
		from ZooLogic.VALFACCOMP as c_itemvalores
			left join ZooLogic.FACCOMPRA as c_factura on c_factura.CODIGO = c_itemvalores.JJNUM and 0 = Funciones.empty( c_itemvalores.JJNUM )
 			left join ZooLogic.XVAL as c_valor on c_valor.CLCOD = c_itemvalores.JJCO and 0 = Funciones.empty( c_itemvalores.JJCO )
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_factura.CODIGO is not null
			and (c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ) )
			and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_ITEMVALORES.jjfe >= @FACTURA_FECHA_DESDE ) )  
			and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_ITEMVALORES.jjfe <= @FACTURA_FECHA_HASTA ) )

	union all

		select 
			case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_factura.FFCH) else  Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			0 as ingreso,
			c_itemvalores.montosiste as egreso
		from ZooLogic.VALNDCOMP as c_itemvalores
			left join ZooLogic.NDCOMPRA as c_factura on c_factura.CODIGO = c_itemvalores.JJNUM and 0 = Funciones.empty( c_itemvalores.JJNUM )
 			left join ZooLogic.XVAL as c_valor on c_valor.CLCOD = c_itemvalores.JJCO and 0 = Funciones.empty( c_itemvalores.JJCO )
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_factura.CODIGO is not null
			and (c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ) )
			and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_ITEMVALORES.jjfe >= @FACTURA_FECHA_DESDE ) )  
			and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_ITEMVALORES.jjfe <= @FACTURA_FECHA_HASTA ) )

	union all

		select 
			case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_comppago.FFCH) else  Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			0 as ingreso,
			c_itemvalores.jjtotfac as egreso
		from zoologic.VALCOMPPAGO as c_itemvalores
			left join Zoologic.COMPPAGO as c_comppago on c_comppago.codigo = c_itemvalores.jjnum 
			left join zoologic.COMPPAGODET as c_compPagoDet on c_comppago.codigo = c_compPagoDet.codigo
			inner join ZooLogic.XVAL as c_valor on c_valor.clcod = c_itemvalores.jjco 
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) 
			and (c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ) )
			and ( ( @FACTURA_FECHA_DESDE is null ) OR ( c_ITEMVALORES.jjfe >= @FACTURA_FECHA_DESDE ) )  
			and ( ( @FACTURA_FECHA_HASTA is null ) OR ( c_ITEMVALORES.jjfe <= @FACTURA_FECHA_HASTA ) )

	union all

		select 
		Funciones.ObtenerFechaDiaOMes(@Parametro1,factura_ffch) as factura_ffch,
			ingreso,
			egreso
		from (
			select 
				case when c_ITEMVALORES.jjfecha = '01/01/1900 00:00:00'  then Funciones.ObtenerFechaDiaOMes(@Parametro1,c_comcaj.fecha) else  Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfecha) end as FACTURA_FFCH,
				0 as ingreso,
				abs(c_itemvalores.monto) * Funciones.ObtenerCotizacion( getdate(), c_valor.clsmonet ) as egreso
			from zoologic.COMPCAJADET as c_itemvalores
				left join Zoologic.COMCAJ as c_comcaj on c_comcaj.codigo = c_itemvalores.coddetval 
				LEFT JOIN Zoologic.CONCECAJA as c_concecaja on c_concecaja.CODIGO = c_comcaj.CONCEPTO and 0 = Funciones.empty( c_comcaj.CONCEPTO )
				inner join ZooLogic.XVAL as c_valor on c_valor.clcod = c_itemvalores.codval 
			where ( 1=1 ) and c_itemvalores.coddetval is not null and 
				( ( c_comcaj.TIPO = 1 and c_itemvalores.ctotal < 0 ) or (c_comcaj.tipo = 2 and c_itemvalores.ctotal > 0 )) -- INGRESOS => Tipo1:Entrada con monto positivo o Tipo2:Salida con monto negativo
			) EGCompCaja
			where ( ( @FACTURA_FECHA_DESDE is null ) or ( FACTURA_FFCH >= @FACTURA_FECHA_DESDE ) )  
				and ( ( @FACTURA_FECHA_HASTA is null ) or ( FACTURA_FFCH <= @FACTURA_FECHA_HASTA ) )

	union all

		select 	FACTURA_FFCH,
		ingreso,
		egreso
	from (
		select case when c_ITEMVALORES.jjfe = '01/01/1900 00:00:00' then Funciones.ObtenerFechaDiaOMes(@Parametro1,@FACTURA_FECHA_DESDE) else Funciones.ObtenerFechaDiaOMes(@Parametro1,c_ITEMVALORES.jjfe) end as FACTURA_FFCH,
			0 as ingreso,
			c_itemvalores.jjm * Funciones.ObtenerCotizacion( getdate(), c_valor.clsmonet ) as egreso
		from zoologic.CANJECUPONESENT as c_ITEMVALORES
			left join ZooLogic.XVAL as c_VALOR on c_VALOR.CLCOD = c_ITEMVALORES.JJCO and 0 = Funciones.empty( c_ITEMVALORES.JJCO ) 
			left join Zoologic.cheque as c_cheque on c_cheque.CCOD = c_ITEMVALORES.nrocheque 
		where ( 1=1 ) and c_ITEMVALORES.jjt is not null   -- Canje de valores entregados
		and ( c_itemvalores.jjt not in (4, 12) or ( c_itemvalores.jjt in (12, 4 ) and c_cheque.estado = 'CARTE' ))
		) IngresosCanje
		where  ( ( @FACTURA_FECHA_DESDE is null ) or ( FACTURA_FFCH >= @FACTURA_FECHA_DESDE ) )  
		and ( ( @FACTURA_FECHA_HASTA is null ) or ( FACTURA_FFCH <= @FACTURA_FECHA_HASTA ) )

	) as Intermedio
	  group by FACTURA_FFCH
)