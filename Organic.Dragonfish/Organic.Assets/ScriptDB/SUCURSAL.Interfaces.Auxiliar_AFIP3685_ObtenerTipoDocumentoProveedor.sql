IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIP3685_ObtenerTipoDocumentoProveedor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerTipoDocumentoProveedor];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerTipoDocumentoProveedor]
( 
	@CUITComprobante varchar(15),
	@CUITProveedor varchar(15),
	@NroDocumento varchar(10),
	@ValorConversion varchar(2)
)
returns varchar(2)
begin
	declare @lcTipoDocumento varchar(2)

	if @CUITComprobante <> ''
		set @lcTipoDocumento = '80'
	else
		if @CUITProveedor is null
			set @lcTipoDocumento = '99'
		else
			if @CUITProveedor <> ''
				set @lcTipoDocumento = '80' 
			else
				if @NroDocumento = ''
					set @lcTipoDocumento = '99'
				else 
					set @lcTipoDocumento = @ValorConversion

	return @lcTipoDocumento
end