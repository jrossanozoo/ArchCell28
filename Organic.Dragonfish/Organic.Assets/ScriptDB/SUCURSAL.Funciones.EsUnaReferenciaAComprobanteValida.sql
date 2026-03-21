IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsUnaReferenciaAComprobanteValida]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsUnaReferenciaAComprobanteValida];
GO;

CREATE FUNCTION [Funciones].[EsUnaReferenciaAComprobanteValida]( @ReferenciaAComprobante varchar(254), @SoloFortamoLegal bit )
returns bit
begin
	declare @PosicionDeLaReferenciaAlComprobante int = Funciones.BuscarPosicionDeReferenciaAComprobanteValida( @ReferenciaAComprobante );
	declare @Long int = case when @ReferenciaAComprobante like '%COMPRA%' and NOT(@ReferenciaAComprobante like '%CANCELACION%') then 16 else 15 end ;
	declare @NumeroDeComprobante varchar(16) = substring( @ReferenciaAComprobante, @PosicionDeLaReferenciaAlComprobante + 1, @Long );
	declare @ReferenciaValida bit = cast( case when @SoloFortamoLegal = 1  
											THEN 
										      case when @NumeroDeComprobante like '[A-Z]_[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
											  then 1
											  else
												  case when @NumeroDeComprobante like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
												  then 1
												  ELSE
													case when @NumeroDeComprobante like '[A-Z]_[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
													THEN 1
													else 0 
													END
												end
											  end
										  else coalesce( @PosicionDeLaReferenciaAlComprobante, 0 )
										  end 
									as bit);
	return @ReferenciaValida
end
