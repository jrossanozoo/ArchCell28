IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDocumentoParaSubDiarioIvaVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerDocumentoParaSubDiarioIvaVentas];
GO;

create FUNCTION [Funciones].[ObtenerDocumentoParaSubDiarioIvaVentas]( @fCuit varchar(20), @Documento varchar(20) )
returns varchar(20)
begin
	declare @retorno varchar(20)
	declare @Cuit varchar(20)
	
	set @Cuit =  rtrim(ltrim( @fCuit ))
	if ( len( @Cuit )<> 11 or [Funciones].[Empty]( @Cuit ) = 1) 
		begin
				if ( [Funciones].[Empty]( @Documento ) = 1 )
					begin
						set @retorno = SPACE(15) 
					end
				else 
					begin
					
						if  (SELECT CASE WHEN @DOCUMENTO LIKE '%[^0-9]%' THEN 0 ELSE 1 END ) = 1
							BEGIN
								SET @retorno = REPLACE( REPLACE( CONVERT( VARCHAR, CONVERT(MONEY, @Documento ), 1 ), '.00',''), ',', '.' )
							END
						ELSE
							BEGIN
								set @retorno = @Documento 
							END
						
					end
		end
	else
		begin
			set @retorno = left( @Cuit, 2 ) + '-' + substring( @Cuit, 3, 8 ) + '-' + right( @Cuit, 1 ) 
		end
	
	
	return @retorno
end
