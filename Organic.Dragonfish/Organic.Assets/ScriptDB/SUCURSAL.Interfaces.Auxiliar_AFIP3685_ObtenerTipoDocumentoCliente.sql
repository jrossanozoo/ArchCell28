IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIP3685_ObtenerTipoDocumentoCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerTipoDocumentoCliente];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerTipoDocumentoCliente]
( 
	@TipoComprobante numeric(2,0),
	@CodigoCliente varchar(10),
	@CUITComprobante varchar(15),
	@CUITCliente varchar(15),
	@CUITPais varchar(20),
	@NroDocumento varchar(10),
	@ValorConversion varchar(2)
)
returns varchar(2)
begin
	declare @lcTipoDocumento varchar(2)

	if Funciones.EsComprobanteExportacion( @TipoComprobante ) = 1
		if @CUITCliente is not null and @CUITPais <> ''
			set @lcTipoDocumento = '80'
		else
			if @CUITCliente is not null and @CUITPais = ''
				set @lcTipoDocumento = '80' -- Para Tierra del Fuego se hace fc exportación, pero se tiene que informar cuit cliente y no cuit pais
			else
				set @lcTipoDocumento = '99'
	else
		if @CodigoCliente = ''
			set @lcTipoDocumento = '99'
		else
			if @CUITComprobante <> ''
				set @lcTipoDocumento = '80'
			else
				if @CUITCliente is null
					set @lcTipoDocumento = '99'
				else
					if @CUITCliente <> ''
						set @lcTipoDocumento = '80' 
					else
						if @NroDocumento = ''
							set @lcTipoDocumento = '99'
						else 
							set @lcTipoDocumento = @ValorConversion

	return @lcTipoDocumento
end