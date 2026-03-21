  
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIPRG4597_ComprasCUIT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [Interfaces].[Auxiliar_AFIPRG4597_ComprasCUIT];
GO;


CREATE FUNCTION [Interfaces].[Auxiliar_AFIPRG4597_ComprasCUIT]
( 
     @FechaDesde varchar(10),
    @FechaHasta varchar(10),
	@FechaEmisionDesde varchar(10),
	@FechaEmisionHasta varchar(10),
    @PtVtaDesde int,
    @PtVtaHasta int,
    @CompFiscal bit,
    @CompManual bit,
    @CompElectr bit,
    @CompDespacho bit,
    @CompLiqA bit,
    @CompLiqB bit,
    @CompServPubA bit,
    @CompServPubB bit,
	@CompReciboA bit,
	@CompReciboC bit,
    @ProrratearCreditoFiscalComputable varchar(1)
)
RETURNS TABLE
AS
RETURN
(
    select distinct
        cast( DatosExpo.TipoDocumento as char(2) ) as ProTipoDoc,
        cast( DatosExpo.NumeroDocumento as char(20) ) as ProNroDoc,
        cast( DatosExpo.CodigoProveedor as char(30) ) as Procodigo
    from ( 
                --> comprobantes de compra
        select 
            case when Comprobante.TcRG1361 in ( 4, 6, 7, 9, 10 ) then '80' else Interfaces.Auxiliar_AFIP3685_ObtenerTipoDocumentoProveedor( Comprobante.FCUIT, Proveedor.ClCUIT, Proveedor.ClNroDoc, case when ConvVDocu.ValDest is null then ConvCDocu.ValorDef else ConvVDocu.ValDest end ) end as TipoDocumento,
            case when Proveedor.ClCUIT is not null and Proveedor.ClCUIT <> '' then Proveedor.ClCUIT else case when Comprobante.FCUIT is not null and Comprobante.FCUIT <> '' then Comprobante.FCUIT else case when Proveedor.ClNroDoc is not null and Proveedor.ClNroDoc <> '' then Proveedor.ClNroDoc else '' end end end as NumeroDocumento,
            case when Proveedor.ClCod  is null then '' else Proveedor.ClCod end as CodigoProveedor
        from (
                select Codigo, FFch, FFchfac, FPtoVen, FactTipo, FLetra, FNumComp, FTotal, Cotiz, FPerson, FCUIT, Anulado, Moneda, TCRG1361, FPtoVenExt
                from [ZooLogic].[FacCompra]
                union all
                select Codigo, FFch, FFchfac, FPtoVen, FactTipo, FLetra, FNumComp, FTotal, Cotiz, FPerson, FCUIT, Anulado, Moneda, TCRG1361, FPtoVenExt
                from [ZooLogic].[NCCompra]
                union all
                select Codigo, FFch, FFchfac, FPtoVen, FactTipo, FLetra, FNumComp, FTotal, Cotiz, FPerson, FCUIT, Anulado, Moneda, TCRG1361, FPtoVenExt
                from [ZooLogic].[NDCompra]
            ) as Comprobante
            left join [ZooLogic].[Prov] as Proveedor on Comprobante.FPerson = Proveedor.ClCod
            left join [Organizacion].[Conver] as ConvCDocu on ConvCDocu.Codigo = 'CODIGODOCUMENTO'
            left join [Organizacion].[ConverVal] as ConvVDocu on ConvCDocu.Codigo = ConvVDocu.Conversion and ConvVDocu.ValOrig = Proveedor.ClTipoDoc
        where Comprobante.FactTipo in ( 8, 9, 10 ) and
             case 
                when @CompFiscal = 1 and Comprobante.TCRG1361 = 3 then 1 
                when @CompManual = 1 and Comprobante.TCRG1361 = 1 then 1
                when @CompElectr = 1 and Comprobante.TCRG1361 = 2 then 1
                when @CompDespacho = 1 and Comprobante.TCRG1361 = 4 then 1
                when @CompLiqA = 1 and Comprobante.TCRG1361 = 5 then 1
                when @CompLiqB = 1 and Comprobante.TCRG1361 = 6 then 1
                when @CompServPubA = 1 and Comprobante.TCRG1361 = 7 then 1
                when @CompServPubB = 1 and Comprobante.TCRG1361 = 8 then 1
				when @CompReciboA = 1 and Comprobante.TCRG1361 = 9 then 1
				when @CompReciboC = 1 and Comprobante.TCRG1361 = 10 then 1
                else 0
              end = 1
              and Comprobante.Anulado = 0
              and ( ( @FechaDesde is null ) or ( Comprobante.FFch >= @FechaDesde ) ) 
              and ( ( @FechaHasta is null ) or ( Comprobante.FFch <= @FechaHasta ) )
			  and ( ( @FechaEmisionDesde is null ) or ( Comprobante.FFCHFAC >= @FechaEmisionDesde ) ) 
              and ( ( @FechaEmisionHasta is null ) or ( Comprobante.FFCHFAC <= @FechaEmisionHasta ) )
              and ( ( @PtVtaDesde is null ) or ( Comprobante.FPTOVEN >= @PtVtaDesde ) ) 
              and ( ( @PtVtaHasta is null ) or ( Comprobante.FPTOVEN <= @PtVtaHasta ) )
        ) as DatosExpo
)



