IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIP3685_ObtenerNumeroDocumentoCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerNumeroDocumentoCliente];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerNumeroDocumentoCliente]
( 
	@TipoComprobante numeric(2,0),
	@CodigoCliente varchar(10),
	@CUITComprobante varchar(15),
	@CUITCliente varchar(15),
	@CUITPais varchar(20),
	@NroDocumento varchar(10)
)
returns varchar(20)
begin
	declare @lcNroDocumento varchar(20)

	if Funciones.EsComprobanteExportacion( @TipoComprobante ) = 1
		if @CUITCliente is not null and @CUITPais <> ''
			set @lcNroDocumento = @CUITPais
		else
			if @CUITCliente is not null and @CUITPais = ''
				set @lcNroDocumento = @CUITCliente -- Para Tierra del Fuego se hace fc exportación, pero se tiene que informar cuit cliente y no cuit pais
			else
				set @lcNroDocumento = '0'
	else
		if @CodigoCliente = ''
			set @lcNroDocumento = '0'
		else
			if @CUITComprobante <> ''
				set @lcNroDocumento = @CUITComprobante
			else
				if @CUITCliente is null
					set @lcNroDocumento = '0'
				else
					if @CUITCliente <> ''
						set @lcNroDocumento = @CUITCliente
					else
						if @NroDocumento = ''
							set @lcNroDocumento = '0'
						else
							set @lcNroDocumento = @NroDocumento
	set @lcNroDocumento = Funciones.padl( Funciones.Alltrim( replace(@lcNroDocumento,'-','') ), 20, '0' )
	
	return @lcNroDocumento
end