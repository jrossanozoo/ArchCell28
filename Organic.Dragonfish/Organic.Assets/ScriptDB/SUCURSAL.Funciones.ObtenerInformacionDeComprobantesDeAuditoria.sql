IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerInformacionDeComprobantesDeAuditoria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerInformacionDeComprobantesDeAuditoria];
GO;

CREATE FUNCTION [Funciones].[ObtenerInformacionDeComprobantesDeAuditoria]
	( 
	@ComprobanteAuditoria varchar(254) ,
	@InformacionRequerida varchar(20)	-- Los valores posibles son: MOTIVO, DESCRIPCION, CLIENTE, NOMBRE 
	)
	returns varchar(40)
AS
	begin
		
		declare @Informacion varchar(40) = '' ;

		declare @NombreDeComprobanteAuditoria varchar (40) = '' ;
		set @NombreDeComprobanteAuditoria = funciones.ObtenerNombreDeComprobanteAuditoria( @ComprobanteAuditoria ) ;
		
		declare @IdentificaEntidad varchar(6) ;
		set @IdentificaEntidad = Funciones.ObtenerIdentificadorDeEntidad( @NombreDeComprobanteAuditoria ) ;
	
		declare @TipoDeComprobante numeric(2,0) ;
		set @TipoDeComprobante = Funciones.ObtenerTipoDeComprobanteAsociadoALaEntidad( @NombreDeComprobanteAuditoria ) ;

		declare @LetraDeComprobante char(1);
		set @LetraDeComprobante = case when Funciones.EsUnaReferenciaAComprobanteValida( @ComprobanteAuditoria , 1 )  = 1 
								  then upper( substring( @ComprobanteAuditoria , Funciones.BuscarPosicionDeReferenciaAComprobanteValida( @ComprobanteAuditoria ) + 1, 1 )) 
								  else null 
								  end;

		declare @PuntoDeVenta numeric(4,0);
		set @PuntoDeVenta = case when Funciones.EsUnaReferenciaAComprobanteValida(  @ComprobanteAuditoria  , 1 )  = 1 
							then 
								case when substring(  @ComprobanteAuditoria  ,Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria )+1 , 1 ) like '[A-z]'
								then substring(  @ComprobanteAuditoria  ,Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria  ) + 3, 4 ) 
								else substring(  @ComprobanteAuditoria  ,Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria  ) + 1, 4 ) 
								-- ticke sin letra
								end
							else null 
							end;

		declare @NumeroDeComprobante numeric(8,0);
		set @NumeroDeComprobante = case when @NombreDeComprobanteAuditoria = 'MOVIMIENTODESTOCK' 
								then substring( @ComprobanteAuditoria, Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria  ), 100 ) when substring( @ComprobanteAuditoria, Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria  ) + 1 , 1 ) like '[A-z]' 
								then substring( @ComprobanteAuditoria, Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria  ) + 8, 8 ) else substring( @ComprobanteAuditoria, Funciones.BuscarPosicionDeReferenciaAComprobanteValida(  @ComprobanteAuditoria  ) + 6, 8 ) end;


		declare @CodigoMotivo varchar(3) = '';
		declare @DescribeMotivo varchar(30) = '';
		declare @CodigoCliente varchar(10) = '';
		declare @NombreCliente varchar(40) = '';

		if upper(@InformacionRequerida) in ('MOTIVO', 'DESCRIPCION')
			if @IdentificaEntidad in ('MDS', 'ADS') and @TipoDeComprobante = 0
				select 
					  @CodigoMotivo = ms.MOTIVO
					, @DescribeMotivo = mt.MOTDES 
				from ZooLogic.MSTOCK as ms inner join ZooLogic.MOTIVO mt 
					on mt.MOTCOD = ms.MOTIVO 
				where numero = @NumeroDeComprobante
			else
				select 
					  @CodigoMotivo = cv.MOTIVO
					, @DescribeMotivo = mt.MOTDES 
				from ZooLogic.COMPROBANTEV as cv inner join ZooLogic.MOTIVO mt 
					on mt.MOTCOD = cv.MOTIVO 
				where cv.FACTTIPO = @TipoDeComprobante
					and cv.FLETRA =  @LetraDeComprobante
					and cv.FPTOVEN = @PuntoDeVenta
					and cv.FNUMCOMP = @NumeroDeComprobante;

		if @TipoDeComprobante > 0 and upper(@InformacionRequerida) in ('CLIENTE', 'NOMBRE')
			select 
				  @CodigoCliente = cv.FPERSON
				, @NombreCliente = cv.FCLIENTE 
			from ZooLogic.COMPROBANTEV as cv
			where cv.FACTTIPO = @TipoDeComprobante
				and cv.FLETRA =  @LetraDeComprobante
				and cv.FPTOVEN = @PuntoDeVenta
				and cv.FNUMCOMP = @NumeroDeComprobante;
			
		set @Informacion =	case upper(@InformacionRequerida) 
								when 'MOTIVO'		then @CodigoMotivo
								when 'DESCRIPCION'	then @DescribeMotivo
								when 'CLIENTE'		then @CodigoCliente
								when 'NOMBRE'		then @NombreCliente
							end;

		return @Informacion
	end
