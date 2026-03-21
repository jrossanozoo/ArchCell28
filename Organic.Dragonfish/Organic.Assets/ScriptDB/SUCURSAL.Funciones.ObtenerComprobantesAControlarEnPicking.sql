IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerComprobantesAControlarEnPicking]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerComprobantesAControlarEnPicking];
GO;

create function [Funciones].[ObtenerComprobantesAControlarEnPicking]
(
	@Comprobante as varchar(40),
	@ClienteDesde as varchar(10),
	@ClienteHasta as varchar(10),
	@ProveedorDesde as varchar(10),
	@ProveedorHasta as varchar(10),
	@OrigenDestinoDesde as varchar(8),
	@OrigenDestinoHasta as varchar(8),
	@FechaComprobanteDesde as date,
	@FechaComprobanteHasta as date,
	@FechaEntregaDesde as date,
	@FechaEntregaHasta as date,
	@VendedorDesde as varchar(10),
	@VendedorHasta as varchar(10),
	@MotivoDesde as varchar(3),
	@MotivoHasta as varchar(3),
	@TransportistaDesde as varchar(15),
	@TransportistaHasta as varchar(15),
	@EntregaPosterior as Numeric(1)
)
returns table
as
return
(
	select cast(Pedidos.FLetra + Funciones.padl(cast(Pedidos.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Pedidos.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Pedidos
	where Funciones.alltrim(@Comprobante) = 'PEDIDO'
		and Pedidos.FactTipo = 23
		and Funciones.alltrim(Pedidos.FPerson) between @ClienteDesde and @ClienteHasta
		and Pedidos.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Pedidos.FFchEnt between @FechaEntregaDesde and @FechaEntregaHasta
		and Funciones.alltrim(Pedidos.FVen) between @VendedorDesde and @VendedorHasta
		and Funciones.alltrim(Pedidos.Motivo) between @MotivoDesde and @MotivoHasta
		and Funciones.alltrim(Pedidos.FTransp) between @TransportistaDesde and @TransportistaHasta
		and Pedidos.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Pedidos.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)		

	union

	select cast(Preparaciones.FLetra + Funciones.padl(cast(Preparaciones.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Preparaciones.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Preparaciones
	where Funciones.alltrim(@Comprobante) = 'PREPARACIONDEMERCADERIA'
		and Preparaciones.FactTipo = 57
		and Funciones.alltrim(Preparaciones.FPerson) between @ClienteDesde and @ClienteHasta
		and Preparaciones.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Preparaciones.FFchEnt between @FechaEntregaDesde and @FechaEntregaHasta
		and Funciones.alltrim(Preparaciones.FVen) between @VendedorDesde and @VendedorHasta
		and Funciones.alltrim(Preparaciones.Motivo) between @MotivoDesde and @MotivoHasta
		and Funciones.alltrim(Preparaciones.FTransp) between @TransportistaDesde and @TransportistaHasta
		and Preparaciones.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Preparaciones.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

		union

	select cast(Remitos.FLetra + Funciones.padl(cast(Remitos.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Remitos.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Remitos
	where Funciones.alltrim(@Comprobante) = 'REMITO'
		and Remitos.FactTipo = 11
		and Funciones.alltrim(Remitos.FPerson) between @ClienteDesde and @ClienteHasta
		and Remitos.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Remitos.FVen between @VendedorDesde and @VendedorHasta
		and Funciones.alltrim(Remitos.Motivo) between @MotivoDesde and @MotivoHasta
		and Funciones.alltrim(Remitos.FTransp) between @TransportistaDesde and @TransportistaHasta
		and Remitos.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Remitos.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta =	b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

	union

	select cast(Facturas.FLetra + Funciones.padl(cast(Facturas.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Facturas.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Facturas
	where Funciones.alltrim(@Comprobante) = 'FACTURA'
		and Facturas.FactTipo = 1
		and Funciones.alltrim(Facturas.FPerson) between @ClienteDesde and @ClienteHasta
		and Facturas.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Facturas.FVen) between @VendedorDesde and @VendedorHasta
		and ((@EntregaPosterior = 1 and Facturas.EntregaPos = 1) or (@EntregaPosterior = 2 and Facturas.EntregaPos not in (1, 3)) or (@EntregaPosterior = 3 and Facturas.EntregaPos = 3))
		and Facturas.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Facturas.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

	union

	select cast(Facturas.FLetra + Funciones.padl(cast(Facturas.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Facturas.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Facturas
	where Funciones.alltrim(@Comprobante) = 'FACTURAELECTRONICA'
		and Facturas.FactTipo = 27
		and Funciones.alltrim(Facturas.FPerson) between @ClienteDesde and @ClienteHasta
		and Facturas.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Facturas.FVen) between @VendedorDesde and @VendedorHasta
		and ((@EntregaPosterior = 1 and Facturas.EntregaPos = 1) or (@EntregaPosterior = 2 and Facturas.EntregaPos not in (1, 3)) or (@EntregaPosterior = 3 and Facturas.EntregaPos = 3))
		and Facturas.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Facturas.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

	union

	select cast(Facturas.FLetra + Funciones.padl(cast(Facturas.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Facturas.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Facturas
	where Funciones.alltrim(@Comprobante) = 'FACTURADEEXPORTACION'
		and Facturas.FactTipo = 47
		and Funciones.alltrim(Facturas.FPerson) between @ClienteDesde and @ClienteHasta
		and Facturas.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Facturas.FVen) between @VendedorDesde and @VendedorHasta
		and Facturas.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Facturas.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

	union

	select cast(Facturas.FLetra + Funciones.padl(cast(Facturas.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Facturas.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Facturas
	where Funciones.alltrim(@Comprobante) = 'FACTURAELECTRONICAEXPORTACION'
		and Facturas.FactTipo = 33
		and Funciones.alltrim(Facturas.FPerson) between @ClienteDesde and @ClienteHasta
		and Facturas.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Facturas.FVen) between @VendedorDesde and @VendedorHasta
		and Facturas.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Facturas.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

	union

	select cast(Facturas.FLetra + Funciones.padl(cast(Facturas.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Facturas.FNumComp as varchar(8)), 8, '0') as varchar(13)) as Comprobante
	from [ZooLogic].[ComprobanteV] as Facturas
	where Funciones.alltrim(@Comprobante) = 'TICKETFACTURA'
		and Facturas.FactTipo = 2
		and Funciones.alltrim(Facturas.FPerson) between @ClienteDesde and @ClienteHasta
		and Facturas.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Facturas.FVen) between @VendedorDesde and @VendedorHasta
		and ((@EntregaPosterior = 1 and Facturas.EntregaPos = 1) or (@EntregaPosterior = 2 and Facturas.EntregaPos not in (1, 3)) or (@EntregaPosterior = 3 and Facturas.EntregaPos = 3))
		and Facturas.Codigo not in (
			Select distinct Codigo from ZooLogic.COMPROBANTEVDET group by Codigo having sum(AFESALDO) <= 0 ) AND					Facturas.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.COMPROBANTEVDET where Codigo =						b.CodigoOri group by Codigo) 
		)

	union

	select cast(Pedidos.NumInt as char(13)) as Comprobante
	from [ZooLogic].[PedCompra] as Pedidos
	where Funciones.alltrim(@Comprobante) = 'PEDIDODECOMPRA'
		and Funciones.alltrim(Pedidos.FPerson) between @ProveedorDesde and @ProveedorHasta
		and Pedidos.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Pedidos.FFchEntr between @FechaEntregaDesde and @FechaEntregaHasta
		and Funciones.alltrim(Pedidos.Motivo) between @MotivoDesde and @MotivoHasta
		and Funciones.alltrim(Pedidos.FTransp) between @TransportistaDesde and @TransportistaHasta
		and Pedidos.Codigo not in (
			Select distinct Codigo from ZooLogic.PedCompraDet group by Codigo having sum(AFESALDO) <= 0 ) AND						Pedidos.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.PedCompraDet  where Codigo = b.CodigoOri			group by Codigo) 
		)

	union

	select cast(Remitos.NumInt as char(13)) as Comprobante
	from [ZooLogic].[RemCompra] as Remitos
	where Funciones.alltrim(@Comprobante) = 'REMITODECOMPRA'
		and Funciones.alltrim(Remitos.FPerson) between @ProveedorDesde and @ProveedorHasta
		and Remitos.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Remitos.Motivo) between @MotivoDesde and @MotivoHasta
		and Funciones.alltrim(Remitos.FTransp) between @TransportistaDesde and @TransportistaHasta
		and Remitos.Codigo not in (
			Select distinct Codigo from ZooLogic.RemCompraDet group by Codigo having sum(AFESALDO) <= 0 ) AND						Remitos.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.RemCompraDet  where Codigo = b.CodigoOri			group by Codigo) 
		)
	union

	select cast(Facturas.NumInt as char(13)) as Comprobante
	from [ZooLogic].[FacCompra] as Facturas
	where Funciones.alltrim(@Comprobante) = 'FACTURADECOMPRA'
		and Funciones.alltrim(Facturas.FPerson) between @ProveedorDesde and @ProveedorHasta
		and Facturas.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Facturas.Codigo not in (
			Select distinct Codigo from ZooLogic.FacCompraDet group by Codigo having sum(AFESALDO) <= 0 ) AND						Facturas.Codigo not in( Select CodigoOri from Zoologic.DetPrepMPicking as b where b.Codigo not in (Select				distinct CodInter from Zoologic.CompAfe where AfeTipo = 'Afectado' and Afecta = b.CodigoOri) group by					CodigoOri having sum(CantAfe) >= (Select sum(AFESALDO) from ZooLogic.FacCompraDet  where Codigo = b.CodigoOri			group by Codigo) 
		)
	union

	select cast(Mercaderias.Numero as char(13)) as Comprobante
	from [ZooLogic].[MTrans] as Mercaderias
	where Funciones.alltrim(@Comprobante) = 'MERCADERIAENTRANSITO'
		and Mercaderias.DirMov = 1
        and Mercaderias.Compgen = ''
		and Funciones.alltrim(Mercaderias.OrigDest) between @OrigenDestinoDesde and @OrigenDestinoHasta
		and Mercaderias.Fecha between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Mercaderias.Vendedor) between @VendedorDesde and @VendedorHasta
		and Funciones.alltrim(Mercaderias.Motivo) between @MotivoDesde and @MotivoHasta

	union

	select cast(Movimientos.Numero as char(13)) as Comprobante
	from [ZooLogic].[MStock] as Movimientos
	where Funciones.alltrim(@Comprobante) = 'MOVIMIENTODESTOCK'
		and Funciones.alltrim(Movimientos.OrigDest) between @OrigenDestinoDesde and @OrigenDestinoHasta
		and Movimientos.Fecha between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Funciones.alltrim(Movimientos.Vendedor) between @VendedorDesde and @VendedorHasta
		and Funciones.alltrim(Movimientos.Motivo) between @MotivoDesde and @MotivoHasta
)