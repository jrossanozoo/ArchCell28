IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[SeDebeMostrarElRegistroDeCtaCteCompra]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[SeDebeMostrarElRegistroDeCtaCteCompra];
GO;

CREATE FUNCTION [Funciones].[SeDebeMostrarElRegistroDeCtaCteCompra]
	(
	@CodigoDeComprobante varchar(38), 
	@TipoDeComprobante numeric(2,0),
	@CodigoDeValor char(5)
	)     
returns bit       
as     
begin
	declare @retorno bit;
	declare @comprometido bit;
	declare @saldo bit;
	declare @total bit;

	if @TipoDeComprobante = 31
		begin
			select @comprometido = sign( abs( sum( op.COMPCC ) ) )
				, @saldo = sign( abs( sum( op.SALDOCC ) ) ) 
				, @total = sign( abs( sum( op.TOTALCC ) ) ) 
			from ZooLogic.CCCOMPRA op where op.TIPOCOMP= 31 and op.CODCOMP = @CodigoDeComprobante;

			if ( @saldo = 1 ) or ( @total = 1 )
				set @retorno = 1 
			else
				if ( @comprometido = 1 ) and ( len( rtrim( @CodigoDeValor ) ) > 0 )
					set @retorno = 1
				else
					begin
						select @saldo = sign( abs( sum( opd.SALDOAUX ) ) )
						from ZooLogic.ORDPAGODET opd where opd.CODIGO = @CodigoDeComprobante;
						
						if ( @comprometido = 1 ) and ( @saldo = 1 )
							set @retorno = 1
						else 
							set @retorno = 0 
					end
		end
	else
		set @retorno = 1
				     
	return @retorno;  
end
