IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerInformacionDePromocion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerInformacionDePromocion];
GO;

CREATE FUNCTION [Funciones].[ObtenerInformacionDePromocion]
( 
	@CodigoDePromocion varchar(38),
	@ParametroAtributoABuscar varchar(max),
	@TipoDePromocion numeric(1, 0)
  )		
RETURNS varchar(max)
AS begin
		declare @Retorno varchar(max)

		declare @InformacionDePromocion varchar(max) = '', @AtributoABuscar varchar(200), @ClaveValor varchar( max), @Encontrado bit, @Clave varchar(max), @Valor varchar(max)
		Set @AtributoABuscar = @ParametroAtributoABuscar

		select @InformacionDePromocion = cast(cast( c_PROMOCION.config as ntext) as xml).value( '(/Promocion/InformacionControl)[1]', 'nvarchar(max)') 
		From zoologic.[PROMOS] c_promocion
		where upper( rtrim( c_promocion.CODIGO ) ) = upper( rtrim( @CodigoDePromocion ) )

		declare @Separador INT, @PosicionPipeline INT = 1, @PosicionPipelineSiguiente INT = 0, @CantidadDePipelines INT = 0, @Dias int = 1;

		set @CantidadDePipelines = LEN( @InformacionDePromocion ) - LEN( REPLACE( @InformacionDePromocion, '|', '' ) );

		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
		-- -- -- -- -- -- -- -- -- -- -- -- SUBSTRING ( expression ,start , length ) -- -- -- -- -- -- -- -- -- -- -- --
		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

		while @PosicionPipeline <= len( @InformacionDePromocion )
		begin  
			set @PosicionPipelineSiguiente = charindex( '|', @InformacionDePromocion, @PosicionPipeline) ;
			set @PosicionPipelineSiguiente = case when @PosicionPipelineSiguiente = 0 then len( @InformacionDePromocion )+1 else @PosicionPipelineSiguiente end;
	
			set @ClaveValor = substring( @InformacionDePromocion, @PosicionPipeline, @PosicionPipelineSiguiente - @PosicionPipeline);

			set @Separador =  charindex( ';', @ClaveValor, 1);
			set @Clave = substring( @ClaveValor, 1, @Separador - 1 );
			set @Encontrado = case when @Clave = @AtributoABuscar then 1 else 0 end
	
			if @Encontrado = 1
				BEGIN
					set @Valor= replace( @ClaveValor, @Clave + ';', '' )
					
					IF UPPER( @Clave ) = 'DIASSEMANA'
					
						BEGIN
					
							declare @ValorDia  varchar(6), @PosicionArroba int, @PosicionArrobaSiguiente int, @Aux varchar(50), @NombreDeDia varchar(20)
							set @dias = 1
							SET @PosicionArroba = 1
							set @Aux = '@' + upper( @Valor )
							set @Valor = ''
							WHILE @Dias <= 7
							begin
								set @PosicionArrobaSiguiente = charindex( '@', @Aux, @PosicionArroba + 1) ;
								set @PosicionArrobaSiguiente = case when @PosicionArrobaSiguiente = 0 then len( @Aux )+1 else @PosicionArrobaSiguiente end;
						
								set @ValorDia = substring( @Aux, @PosicionArroba, @PosicionArrobaSiguiente - @PosicionArroba);
								if @ValorDia = '@TRUE'
									begin
										set @NombreDeDia = case @dias
																when 1 then 'Lunes'
																when 2 then 'Martes'
																when 3 then 'Miercoles'
																when 4 then 'Jueves'
																when 5 then 'Viernes'
																when 6 then 'Sábado'
																when 7 then 'Domingo'
																else ''
															end ;
												
										SET @Valor = @Valor + @NombreDeDia + ', '
									end;					
							set @PosicionArroba = @PosicionArrobaSiguiente
							SET @Dias = @Dias + 1
						END
						if @Valor <> ''
							begin
								SET @Valor = substring( @Valor, 1, len(rtrim(@Valor))-1 )
								set @PosicionArroba = len(@Valor) - charindex( ',', reverse(@Valor), 1) + 1
								--print @Clave + ' <---> ' + @Valor + ', ' + cast(@PosicionArroba as varchar(6))
								if @PosicionArroba < len(@Valor)
									SET @Valor = substring( @Valor, 1, @PosicionArroba -1 ) + ' y' + substring( @Valor, @PosicionArroba + 1, len(@Valor) - @PosicionArroba + 1)
							end
					END -- FIN DE TRATAMIENTO ESPECIAL PARA LOS DÍAS DE SEMANA.

				ELSE -- > UPPER( @Clave ) <> 'DIASSEMANA'

					set  @Valor = CASE 

					---- Para componer campo CONDICION/ES
					when UPPER( @Clave ) = 'MASKCONDICION' and @TipoDePromocion = 1 and @valor <> ''
						THEN 'Llevando ' + Funciones.Alltrim( @Valor ) 

					when upper( @Clave ) = 'FILTROCONDICION' and @valor <> ''
						THEN case when @TipoDePromocion = 1 then 'Y si cumple la/s siguiente/s condición/es: ' +    @Valor    
								                            else 'Todos los que cumplan la/s siguiente/s condición/es: ' +    @Valor     end

					---- Para componer campo BENEFICIO/S
					when UPPER( @Clave ) = 'MASKBENEFICIO' and @Valor <> '' 
						THEN
							case 
								when @TipoDePromocion = 1 then 'Paga ' + Funciones.Alltrim( @Valor )
								when @TipoDePromocion in (2,3,5,6) then 'Tienen ' + Funciones.Alltrim( @Valor ) + '% de descuento '
								when @TipoDePromocion in (4,7) then 'Tiene un monto fijo de '  + Funciones.Alltrim( @Valor ) 
								else '' 
							end

					when upper( @Clave ) = 'TIPOPRECIO' and @TipoDePromocion in (3,4,5,7,8) and @Valor <> '' 
						THEN ''  

					when upper( @Clave ) = 'MASKTOPEDESCUENTO' and @TipoDePromocion in (2,3,5,6) and @Valor <> ''
						THEN 'Tope ' + Funciones.Alltrim( @Valor ) 
					
					when upper( @Clave ) = 'MASKTOPEDESCUENTO' and @TipoDePromocion not in (2,3,5,6) and @Valor <> ''
						THEN '' 

					when upper( @Clave ) = 'MASKCUOTASSINRECARGO' and @TipoDePromocion = 5 and @Valor <> ''
						THEN 'Hasta ' +   Funciones.Alltrim( @Valor ) + ' cuotas sin recargo '
					
					when upper( @Clave ) = 'MASKCUOTASSINRECARGO' and @TipoDePromocion <> 5  and @Valor <> ''
						THEN '' 
						
					when upper( @Clave ) = 'FILTROBENEFICIO' and @TipoDePromocion in (2,6) and @Valor <> ''
						THEN 'En los productos que cumplan con la/s siguiente/s condición/es: ' +  Funciones.Alltrim( @Valor )
						
					when upper( @Clave ) = 'FILTROBENEFICIO' and @TipoDePromocion = 7 and @Valor <> ''
						THEN 'Y cumple con la/s siguiente/s condición/es: ' +  Funciones.Alltrim( @Valor )

					when upper( @Clave ) = 'LISTADEPRECIOS' and @TipoDePromocion = 8 and @Valor <> ''
						THEN 'Usa la lista de precios: ' +  Funciones.Alltrim( @Valor ) 
					
					else @Valor

				END -- > UPPER( @Clave ) = 'DIASSEMANA'
				
				-- VALOR ENCONTRADO DESPUÉS DE HABER PASADO POR LAS INTERPRETACIONES SEGUN EL TIPO DE PROMOCIÓN ---
				set @Retorno = @Valor
				BREAK

			END;
				
			set @PosicionPipeline = @PosicionPipelineSiguiente +1;
		end

	return CASE when @Retorno is null or @Retorno = '' then '' else @Retorno + CHAR(13) + CHAR(10)  end
    end
