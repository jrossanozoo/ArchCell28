IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIP3685_ObtenerNumeroDocumentoProveedor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerNumeroDocumentoProveedor];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerNumeroDocumentoProveedor]
( 
	@CUITComprobante varchar(15),
	@CUITProveedor varchar(15),
	@NroDocumento varchar(10)
)
returns varchar(20)
begin
	declare @lcNroDocumento varchar(20)

	if @CUITComprobante <> ''
		set @lcNroDocumento = @CUITComprobante
	else
		if @CUITProveedor is null
			set @lcNroDocumento = '0'
		else
			if @CUITProveedor <> ''
				set @lcNroDocumento = @CUITProveedor
			else
				if @NroDocumento = ''
					set @lcNroDocumento = '0'
				else 
					set @lcNroDocumento = @NroDocumento
	set @lcNroDocumento = Funciones.padl( Funciones.Alltrim( replace(@lcNroDocumento,'-','') ), 20, '0' )

	return @lcNroDocumento
end