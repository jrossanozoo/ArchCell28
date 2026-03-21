IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadesAfectantesDeLosComprobantesDeVentasRelacionados]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCantidadesAfectantesDeLosComprobantesDeVentasRelacionados];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadesAfectantesDeLosComprobantesDeVentasRelacionados]
( @CodigoComprobanteAfectado varchar(38),
  @TipoDeComprobante int ,
  @NivelEnLaRelacion int ,
  @NroItem int )
  
RETURNS numeric(16,3)
AS
BEGIN
	declare @retorno numeric(16,3);

	with ComprobantesRelacionados( Cantidad, Tipo, Afectado, Nivel , Iditem )  as
	(
		select Detalle.fcant as cantidad,
			Detalle.AFETIPOCOM,
			Detalle.CODIGO,
			0 as nivel ,
			Detalle.IDITEM
		from [ZooLogic].[ComprobantevDet] as Detalle
		where Detalle.CODIGO = @CodigoComprobanteAfectado and Detalle.NROITEM = @NroItem

		union all

		select Detalle.fcant as cantidad,
			Afecta.AFETIPOCOM,
			Afecta.AFECTA,
			Anterior.nivel + 1,
			Anterior.iditem 
		from ComprobantesRelacionados as Anterior
			inner join [ZooLogic].[COMPAFE] Afecta on AFECTA.AFETIPO = 'Afectante' and Afecta.codigo = Anterior.Afectado
			inner join [ZooLogic].[ComprobantevDet] as Detalle on Detalle.Codigo = Afecta.AFECTA and Detalle.IDITEM = Anterior.Iditem
		where Anterior.nivel < 5
	)
	select @retorno=sum(cantidad) 
	from ComprobantesRelacionados 
	where nivel = @NivelEnLaRelacion 
		and ( ( @TipoDeComprobante = 0 and tipo = 25 )						-- Presupuesto
		   or ( @TipoDeComprobante = 1 and tipo = 23 )						-- Pedido
		   or ( @TipoDeComprobante = 2 and tipo = 12 )						-- Cancelación de ventas
		   or ( @TipoDeComprobante = 3 and tipo = 11 )						-- Remito
		   or ( @TipoDeComprobante = 4 and tipo in ( 1, 2, 27, 33, 47 ) ) )	-- Facturas
	;

	return isnull( @retorno, 0 )
END
