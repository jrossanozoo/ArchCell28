IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerInformacionDeLaReferenciaAComprobantes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerInformacionDeLaReferenciaAComprobantes];
GO;

CREATE FUNCTION [Funciones].[ObtenerInformacionDeLaReferenciaAComprobantes]
	( 
	@ReferenciaAComprobante varchar(254),
	@InformacionRequerida varchar(20)	-- Los valores posibles son: DESCRIPTOR, LETRA, PTOVTA, NUMERO 
	)
	returns varchar(254)
AS
	begin
		declare @Informacion varchar(254) = '';
		declare @Descriptor varchar(254) = '';
		declare @Letra char(1) = '';
		declare @PtoVta varchar(4) = '0';
		declare @Numero varchar(8) = '0';
		declare @PosicionHito int = charindex( ' ',  @ReferenciaAComprobante  );

		if @PosicionHito > 0
			begin
				set @Descriptor = left( @ReferenciaAComprobante, @PosicionHito - 1);

				if len( @ReferenciaAComprobante ) - len( replace( replace( @ReferenciaAComprobante, ' ', '' ), '-', '' ) ) = 3	-- si solo existen 2 espacios y un guion
					and patindex( '% _ ____-________%', @ReferenciaAComprobante ) + 15 = len( @ReferenciaAComprobante )			-- y los ultimos 16 caracteres corresponden con la plantilla 
					and isnumeric( substring( @ReferenciaAComprobante, patindex( '% _ ____-%', @ReferenciaAComprobante ) + 3, 4 ) ) = 1
					and isnumeric( substring( @ReferenciaAComprobante, patindex( '% _ ____-________%', @ReferenciaAComprobante ) + 8, 8 ) ) = 1
					begin
						set @Letra = substring( @ReferenciaAComprobante, @PosicionHito + 1, 1 );
						set @PtoVta = substring( @ReferenciaAComprobante, patindex( '% _ ____-%', @ReferenciaAComprobante ) + 3, 4 );
						set @Numero = substring( @ReferenciaAComprobante, patindex( '% _ ____-________%', @ReferenciaAComprobante ) + 8, 8 );
					end
				else
					if len( @ReferenciaAComprobante ) - len( replace( @ReferenciaAComprobante, ' ', '' ) ) = 1
						and patindex( '% ________%', @ReferenciaAComprobante ) + 8 = len( @ReferenciaAComprobante )
						and isnumeric( substring( @ReferenciaAComprobante, patindex( '% ________%', @ReferenciaAComprobante ) + 1, 8 ) ) = 1
							set @Numero = substring( @ReferenciaAComprobante, patindex( '% ________%', @ReferenciaAComprobante ) + 1, 8 );
			end;

		set @Informacion =	case upper(@InformacionRequerida) 
								when 'DESCRIPTOR'	then @Descriptor
								when 'LETRA'		then @Letra
								when 'PTOVTA'		then @PtoVta
								when 'NUMERO'		then @Numero
							end;

		return @Informacion
	end
