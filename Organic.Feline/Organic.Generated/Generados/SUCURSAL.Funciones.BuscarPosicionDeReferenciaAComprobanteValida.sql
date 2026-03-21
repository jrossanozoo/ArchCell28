IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[BuscarPosicionDeReferenciaAComprobanteValida]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[BuscarPosicionDeReferenciaAComprobanteValida];
GO;

CREATE FUNCTION [Funciones].[BuscarPosicionDeReferenciaAComprobanteValida]
( @TextoConPosibleReferenciaAComprobante varchar(254) )
RETURNS int
AS
BEGIN
    declare @ConLetra bit = 0;
    declare @ReferenciaValida bit = 0;
    declare @RespetaEsquema int = len( @TextoConPosibleReferenciaAComprobante ) - len( replace( replace( @TextoConPosibleReferenciaAComprobante, ' ', ''), '-', '') );
    
    declare @CaracteresAAjustarSiHaySecuencia int = 0;
    if @TextoConPosibleReferenciaAComprobante like '%Sec:%'
    set @CaracteresAAjustarSiHaySecuencia = 7;
    
    declare @EsTipoLegal bit = 1;
    declare @DiferenciaEsperada int = 15 + @CaracteresAAjustarSiHaySecuencia;
    declare @PosicionEsquema int = patindex( '% [A-z] [0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @TextoConPosibleReferenciaAComprobante );
    if @TextoConPosibleReferenciaAComprobante like '%COMPRA%' and NOT(@TextoConPosibleReferenciaAComprobante like '%CANCELACION%')
		begin
			set @DiferenciaEsperada = 16 + @CaracteresAAjustarSiHaySecuencia;
			SET @PosicionEsquema = patindex( '% [A-z] [0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @TextoConPosibleReferenciaAComprobante );
		end
    if @PosicionEsquema = 0
    	begin /* podría ser ticke sin letra */
  		  	set @EsTipoLegal = 1;
  		  	set @DiferenciaEsperada = 12 + @CaracteresAAjustarSiHaySecuencia;
   	 	set @PosicionEsquema  = patindex( '%[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @TextoConPosibleReferenciaAComprobante );
    	end
    else
    	begin
    		set @ConLetra = 1;
    	end
    if @PosicionEsquema = 0
   	 begin /*Entonces no es una referencia del tipo (L) 0000-99999999 donde L es letra, 0000 es el punto de vta y 999999999 el numero de comprobante*/
	 	   if @TextoConPosibleReferenciaAComprobante like '%AJUSTEDESTOCK%'
	 	   		begin
	 	   			set @DiferenciaEsperada = 10;
	 	   		end
	 	   else
	 	   		begin
	 	   			set @DiferenciaEsperada = 8;
	 	   		end
    
    	   set @EsTipoLegal = 0;
	 	   set @PosicionEsquema = patindex( '% [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @TextoConPosibleReferenciaAComprobante );
   	 end; /*Los movimientos de inventario tienen este segundo esquema*/
    
    if len( rtrim( @TextoConPosibleReferenciaAComprobante ) ) - @PosicionEsquema = @DiferenciaEsperada 
  	 begin
        set @ReferenciaValida = convert( bit, sign( abs( @RespetaEsquema * @PosicionEsquema ) ) );
    
        if ( @EsTipoLegal = 1 ) and ( @RespetaEsquema = 3 ) and @ConLetra=1
        begin
            set @ReferenciaValida = @ReferenciaValida * isnumeric( substring( @TextoConPosibleReferenciaAComprobante, @PosicionEsquema + 3, 4 ) );
            set @ReferenciaValida = @ReferenciaValida * isnumeric( substring( @TextoConPosibleReferenciaAComprobante, @PosicionEsquema + 8, 8 ) );
        end
        else
        	if ( @EsTipoLegal = 1 ) and ( @RespetaEsquema = 3 )
        		begin
        		set @ReferenciaValida = @ReferenciaValida * isnumeric( substring( @TextoConPosibleReferenciaAComprobante, @PosicionEsquema , 4 ) );
        		set @ReferenciaValida = @ReferenciaValida * isnumeric( substring( @TextoConPosibleReferenciaAComprobante, @PosicionEsquema + 5, 8 ) );
        		set @PosicionEsquema = @PosicionEsquema - 1;
        		end
        	else
           	if ( @RespetaEsquema = 1 ) set @ReferenciaValida = @ReferenciaValida * isnumeric( substring( @TextoConPosibleReferenciaAComprobante, @PosicionEsquema + 1, 8 ) );
    end
    
    if @ReferenciaValida = 0 set @PosicionEsquema = null
    
    return @PosicionEsquema

END