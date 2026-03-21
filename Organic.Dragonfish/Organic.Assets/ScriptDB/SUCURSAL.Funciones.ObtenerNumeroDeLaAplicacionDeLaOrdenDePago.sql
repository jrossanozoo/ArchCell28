IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNumeroDeLaAplicacionDeLaOrdenDePago]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerNumeroDeLaAplicacionDeLaOrdenDePago];
GO;

CREATE FUNCTION [Funciones].[ObtenerNumeroDeLaAplicacionDeLaOrdenDePago]
( @OrdenDePago varchar(38), 
  @Anulada bit )
RETURNS varchar(20)
AS
	BEGIN

		declare @IdentificadorAnulado varchar(40)

		if @Anulada = 0
			begin

				If @OrdenDePago <> ''
					begin
						declare @Identificador varchar(40)
						declare @IdentificadorRefinanciado varchar(40)
						declare @Tipo varchar(4)
						declare @Letra varchar(1)
						declare @Punto varchar(4)
						declare @Comprobante varchar(8)
						declare @Valor varchar(8)
						declare @Refinancia varchar(40)

						set @Valor = ( SELECT TOP 1 v.jjt from [ZooLogic].[VALFACCOMP] as v where v.jjnum = @OrdenDePago AND v.jjt =6 ) ;

						set @IdentificadorRefinanciado = null
						If @Valor = '6' -- pagado con Cuenta Corriente
							begin
								set @Refinancia = ( SELECT TOP 1 d.CODIGO 
													FROM [ZooLogic].[ORDPAGODET] as d 
													where d.CODCOMP = @OrdenDePago ) ;
						
								if @Refinancia is null
									begin
										set @IdentificadorRefinanciado = 'REFINANCIADO'		
									end
								else
									begin
							
										SELECT  @Tipo = o.FACTTIPO, 
												@Letra = o.FLETRA, 
												@Punto = o.FPTOVEN, 
												@Comprobante = o.FNUMCOMP 
										FROM [ZooLogic].[ORDPAGO] as o 
										where o.CODIGO = @Refinancia

									end
				
							end
			
						else

							begin

								SELECT	@Tipo = p.FACTTIPO, 
										@Letra = p.FLETRA, 
										@Punto = p.FPTOVEN, 
										@Comprobante = p.FNUMCOMP 
								FROM [ZooLogic].[ORDPAGO] as o 
								inner join [ZooLogic].[PAGO] p on p.OPAGO = o.CODIGO 
								where O.codigo = @OrdenDePago 

							end

						set @Identificador = upper( Funciones.ObtenerIdentificadorDeComprobante( @Tipo ) );
						set @Identificador = @Identificador + ' ' + upper( left( @Letra, 1 ) ) + ' ' ;
						set @Identificador = @Identificador + Funciones.padl( @Punto, 4, '0' ) + '-' ;
						set @Identificador = @Identificador + Funciones.padl( @Comprobante, 8, '0' ) ;				

					end			

			end

		else
			set @IdentificadorAnulado = 'ANULADO'
			
		return COALESCE ( @IdentificadorAnulado, @IdentificadorRefinanciado, @Identificador, SPACE( 20 ) )

	END
