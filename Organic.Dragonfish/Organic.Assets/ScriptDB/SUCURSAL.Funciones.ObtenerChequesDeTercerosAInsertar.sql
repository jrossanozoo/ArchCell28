IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerChequesDeTercerosAInsertar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerChequesDeTercerosAInsertar];
GO;

create function [Funciones].[ObtenerChequesDeTercerosAInsertar]
(

	@FechaPagoDesde as date,
	@FechaPagoHasta as date,
	@MontoDesde as Numeric(15,2),
	@MontoHasta as Numeric(15,2),
	@MonedaDesde as varchar(10),
	@MonedaHasta as varchar(10),
	@ClienteDesde as varchar(10),
	@ClienteHasta as varchar(10),
	@NumeroDesde as Numeric(8),
	@NumeroHasta as Numeric(8),
	@EntidadFinancieraDesde as varchar(5),
	@EntidadFinancieraHasta as varchar(5),
	@CodigoValorDesde as varchar(5),
	@CodigoValorHasta as varchar(5),
	@FechaEmisionDesde as date,
	@FechaEmisionHasta as date,
	@NumeroInternoDesde as Numeric(8),
	@NumeroInternoHasta as Numeric(8),
	@CuitDesde as varchar(15),
	@CuitHasta as varchar(15)
	
)
returns table
as
return
(
	select Cheques.CCOD, Cheques.CFECHA, Cheques.CMONTO, Cheques.CMONEDA, Cheques.CLIENTE, Cheques.CNUMERO, Cheques.CENTFIN, Cheques.CVALOR, Cheques.CFECHAEMI,
	Cheques.NUMEROC, Cheques.CCOTRIBGIR, 0 as seleccionado
	from [ZooLogic].[Cheque] as Cheques
	where Cheques.ESTADO = 'CARTE'
		and Cheques.CFECHA between @FechaPagoDesde and @FechaPagoHasta
		and Cheques.CMONTO between @MontoDesde and @MontoHasta
		and Funciones.alltrim(Cheques.CMONEDA) between @MonedaDesde and @MonedaHasta
		and Funciones.alltrim(Cheques.CLIENTE) between @ClienteDesde and @ClienteHasta
		and Cheques.CNUMERO between @NumeroDesde and @NumeroHasta
		and Funciones.alltrim(Cheques.CENTFIN) between @EntidadFinancieraDesde and @EntidadFinancieraHasta
		and Funciones.alltrim(Cheques.CVALOR) between @CodigoValorDesde and @CodigoValorHasta
		and Cheques.CFECHAEMI between @FechaEmisionDesde and @FechaEmisionHasta
		and Cheques.NUMEROC between @NumeroInternoDesde and @NumeroInternoHasta
		and Funciones.alltrim(Cheques.CCOTRIBGIR) between @CuitDesde and @CuitHasta
)

