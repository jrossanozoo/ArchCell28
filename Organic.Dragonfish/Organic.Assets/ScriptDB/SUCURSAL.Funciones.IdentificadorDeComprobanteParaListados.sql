IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[IdentificadorDeComprobanteParaListado]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[IdentificadorDeComprobanteParaListado];
GO;

CREATE FUNCTION [Funciones].[IdentificadorDeComprobanteParaListado]
	( 
	@TipoDeComprobante int,
	@LetraDeComprobante char(1),
	@PuntoDeVenta int,
	@NumeroDeComprobante int
	--, @Secuencia char(2)	-- para incorporar la secuencia descomentar esta linea y la última del bloque begin/end
	)
	returns varchar(26)
AS
	begin
		declare @Identificador varchar(26)

		If @NumeroDeComprobante <> 0
			begin
				set @Identificador = upper( Funciones.ObtenerIdentificadorDeComprobante( @TipoDeComprobante ) );
				if coalesce( @LetraDeComprobante, ' ' ) != ' ' set @Identificador = @Identificador + ' ' + upper( left( @LetraDeComprobante, 1 ) ) + ' '
					else set @Identificador = @Identificador + ' ' ;
				if coalesce( @PuntoDeVenta, 0 ) != 0 set @Identificador = @Identificador + Funciones.padl( @PuntoDeVenta, 4, '0' ) + '-';
				if substring(@Identificador, len(@Identificador), 1) not in ( ' ', '-' ) set @Identificador = @Identificador + '';
				set @Identificador = @Identificador + Funciones.padl( @NumeroDeComprobante, 8, '0' ) --;
				--if coalesce( @Secuencia, '  ' ) != '  ' set @Identificador = @Identificador + '-Sec:' + Funciones.padl( @Secuencia, 2, '0' )
			end
		else
			set @Identificador = SPACE( 26 );

		return @Identificador
	end
