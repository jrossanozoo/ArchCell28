IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[LaOrdenDePagoAfectaSaldo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[LaOrdenDePagoAfectaSaldo];
GO;

CREATE FUNCTION [Funciones].[LaOrdenDePagoAfectaSaldo]
	(
	@CodigoDeComprobante varchar(38), 
	@TipoDeComprobante numeric(2,0),
	@MontoComprometido numeric(15,2)
	)     
returns bit       
as     
begin
	declare @retorno bit;
	declare @comprometido bit;
	declare @saldo bit;
	declare @PagoACuenta numeric(15, 2);

	if @TipoDeComprobante = 31
		begin
			set @comprometido = sign( abs( @MontoComprometido ) );

			if  ( @comprometido = 1 )
				begin
					select @saldo = sign( abs( sum( opd.SALDOAUX ) ) ), @PagoACuenta = sum( opd.RMONTO * power( 0, abs( 31 - opd.TIPO ) ) )
					from ZooLogic.ORDPAGODET opd where opd.CODIGO = @CodigoDeComprobante;
						
					if( @saldo = 1 ) and ( @MontoComprometido != @PagoACuenta )
						set @retorno = 1
					else 
						set @retorno = 0 
				end
			else
				set @retorno = 0
		end
	else
		set @retorno = 0
				     
	return @retorno;  
end
