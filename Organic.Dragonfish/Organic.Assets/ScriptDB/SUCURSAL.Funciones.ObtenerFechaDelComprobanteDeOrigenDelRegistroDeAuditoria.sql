IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerFechaDelComprobanteDeOrigenDelRegistroDeAuditoria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerFechaDelComprobanteDeOrigenDelRegistroDeAuditoria];
GO;

CREATE FUNCTION [Funciones].[ObtenerFechaDelComprobanteDeOrigenDelRegistroDeAuditoria]
	( 
	@ComprobanteAuditoria varchar(254),
	@FechaDeAuditoria datetime
	)
	returns datetime
AS
	begin
		declare @FechaDeComprobante datetime;

		declare @EsValido bit = Funciones.EsUnaReferenciaAComprobanteValida( @ComprobanteAuditoria , 1 );
		declare @NombreDeComprobanteAuditoria varchar (40) = funciones.ObtenerNombreDeComprobanteAuditoria( @ComprobanteAuditoria ) ;
		declare @IDEntidad varchar(6) = Funciones.ObtenerIdentificadorDeEntidad( @NombreDeComprobanteAuditoria );
		declare @PosReferencia int = Funciones.BuscarPosicionDeReferenciaAComprobanteValida( @ComprobanteAuditoria );
		declare @TipoDeComprobante numeric(2,0) = Funciones.ObtenerTipoDeComprobanteAsociadoALaEntidad( @NombreDeComprobanteAuditoria ) ;
		declare @LetraDeComprobante char(1) = case when @EsValido = 1 then upper( substring( @ComprobanteAuditoria, @PosReferencia + 1, 1 ) ) else null end;

		declare @Long int = case when @ComprobanteAuditoria like '%COMPRA%' and NOT(@ComprobanteAuditoria like '%CANCELACION%') then 1 else 0 end ;
		declare @PuntoDeVenta numeric(5,0) = case when @EsValido = 1 then case when substring( @ComprobanteAuditoria, @PosReferencia + 1 , 1 ) like '[A-z]' then substring( @ComprobanteAuditoria, @PosReferencia + 3, 4 + @Long ) else substring( @ComprobanteAuditoria, @PosReferencia + 1, 4 ) end else null end;
		declare @NumeroDeComprobante numeric(8,0) = case when @NombreDeComprobanteAuditoria = 'MOVIMIENTODESTOCK' then substring( @ComprobanteAuditoria, @PosReferencia, 100 ) when substring( @ComprobanteAuditoria, @PosReferencia + 1 , 1 ) like '[A-z]' then substring( @ComprobanteAuditoria, @PosReferencia + 8 + @Long, 8 ) else substring( @ComprobanteAuditoria, @PosReferencia + 6, 8 ) end;
		
		if @IDEntidad in ('MDS', 'ADS')
			select top 1 @FechaDeComprobante = ms.FECHA
			from ZooLogic.MSTOCK as ms where numero = @NumeroDeComprobante;
		else
			if @IDEntidad in ('FCV', 'RMV', 'NCV', 'NDV', 'DEV', 'TFC', 'TNC', 'TND', 'FEN', 'CEN', 'DEN', 'FEE', 'CEE', 'DEE', 'FMX', 'NCX', 'NDX', 'PED', 'PR1')
				select top 1 @FechaDeComprobante = cv.FFCH 
				from ZooLogic.COMPROBANTEV as cv where cv.FACTTIPO = @TipoDeComprobante and cv.FLETRA = @LetraDeComprobante and cv.FPTOVEN = @PuntoDeVenta and cv.FNUMCOMP = @NumeroDeComprobante;
			else
				if @IDEntidad = 'FDC'
					select @FechaDeComprobante = max( cc.FFCH ) 
					from ZooLogic.FACCOMPRA as cc where cc.FACTTIPO = @TipoDeComprobante and cc.FLETRA = @LetraDeComprobante and cc.FPTOVEN = @PuntoDeVenta and cc.FNUMCOMP = @NumeroDeComprobante and cc.FFCH <= @FechaDeAuditoria;
				else
					if @IDEntidad = 'NCC'
						select @FechaDeComprobante = max( cc.FFCH ) 
						from ZooLogic.NCCOMPRA as cc where cc.FACTTIPO = @TipoDeComprobante and cc.FLETRA = @LetraDeComprobante and cc.FPTOVEN = @PuntoDeVenta and cc.FNUMCOMP = @NumeroDeComprobante and cc.FFCH <= @FechaDeAuditoria;
					else
						if @IDEntidad = 'NDC'
							select @FechaDeComprobante = max( cc.FFCH )
							from ZooLogic.NDCOMPRA as cc where cc.FACTTIPO = @TipoDeComprobante and cc.FLETRA = @LetraDeComprobante and cc.FPTOVEN = @PuntoDeVenta and cc.FNUMCOMP = @NumeroDeComprobante and cc.FFCH <= @FechaDeAuditoria;
						else
							if @IDEntidad = 'PCO'
								select @FechaDeComprobante = max( cc.FFCH )
								from ZooLogic.PEDCOMPRA as cc where cc.FACTTIPO = @TipoDeComprobante and cc.FLETRA = @LetraDeComprobante and cc.FPTOVEN = @PuntoDeVenta and cc.FNUMCOMP = @NumeroDeComprobante and cc.FFCH <= @FechaDeAuditoria;
							else
								if @IDEntidad = 'CAC'
									select @FechaDeComprobante = max( cc.FFCH )
									from ZooLogic.CANCOMPRA as cc where cc.FACTTIPO = @TipoDeComprobante and cc.FLETRA = @LetraDeComprobante and cc.FPTOVEN = @PuntoDeVenta and cc.FNUMCOMP = @NumeroDeComprobante and cc.FFCH <= @FechaDeAuditoria;
								else
									set @FechaDeComprobante = null;
		
		if isdate( @FechaDeComprobante ) = 0 set @FechaDeComprobante = @FechaDeAuditoria;
		
		return @FechaDeComprobante
	end
