IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPuntoVentaDeUnComprobanteEnLaAuditoriaComb]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerPuntoVentaDeUnComprobanteEnLaAuditoriaComb];
GO;

CREATE FUNCTION [Funciones].[ObtenerPuntoVentaDeUnComprobanteEnLaAuditoriaComb]
	( 
	@ComprobanteAuditoria varchar(254)
	)
	returns varchar(40)
AS
	begin
	
		declare @Informacion varchar(40) = '' ;
		declare @PosicionReferencia int = funciones.BuscarPosicionDeReferenciaAComprobanteValida( @ComprobanteAuditoria  ) ;

		
		set @Informacion =	case when funciones.esunareferenciaacomprobantevalida( @ComprobanteAuditoria  , 1) = 1  
								then  
									case when substring( @ComprobanteAuditoria , @PosicionReferencia+1 , 1 ) like '[A-z]' 
										then upper(substring( @ComprobanteAuditoria  , @PosicionReferencia+3 , 4 ))  
										else upper(substring( @ComprobanteAuditoria  , @PosicionReferencia+1 , 4 )) 
									end  
								else  null  
							end

		return @Informacion
	end
