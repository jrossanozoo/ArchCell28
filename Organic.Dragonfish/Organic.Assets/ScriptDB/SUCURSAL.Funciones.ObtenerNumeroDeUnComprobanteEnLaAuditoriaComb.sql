IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNumeroDeUnComprobanteEnLaAuditoriaComb]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerNumeroDeUnComprobanteEnLaAuditoriaComb];
GO;

CREATE FUNCTION [Funciones].[ObtenerNumeroDeUnComprobanteEnLaAuditoriaComb]
	( 
	@ComprobanteAuditoria varchar(254)
	)
	returns varchar(40)
AS
	begin
	
		declare @Informacion varchar(40) = '' ;
		declare @PosicionReferencia int = funciones.BuscarPosicionDeReferenciaAComprobanteValida( @ComprobanteAuditoria  ) ;
		
		set @Informacion =	case when substring(  @ComprobanteAuditoria  , @PosicionReferencia+1 , 1 ) like '[A-z]' 
								then substring( @ComprobanteAuditoria , funciones.ObtenerPosicionDelNumeroDeComprobante( @ComprobanteAuditoria ), 8)  
								else upper(substring( @ComprobanteAuditoria , @PosicionReferencia+7 , 8 ))  
							end

		return @Informacion
	end
