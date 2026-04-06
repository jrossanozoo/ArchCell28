IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_ObtenerParametro]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
DROP PROCEDURE [Funciones].[sp_ObtenerParametro];
GO;

CREATE PROCEDURE [Funciones].[sp_ObtenerParametro]
	(
		@Parametro varchar(255),
		@Tipo varchar(20)
	)     
as     
begin
      
declare @IdNodo int = 0
declare @Nombre varchar(254) = ''	
declare @Proyecto varchar(254) = ''
declare @TipoDato varchar(254) = ''
declare @Default_N int;
declare @Default_D datetime;
declare @Default_C varchar(254) = '';
declare @Default_L bit;
declare @Campo varchar(254) = '';
 
if ( @Tipo = 'PARAMETROS' and @Parametro = 'Dibujante.FormatoParaFecha' )
begin 
       set @IdNodo = 1; set @Nombre = 'FormatoParaFecha'; set  @Proyecto = 'DIBUJANTE'; set  @Campo = 'p.Valor'; set  @TipoDato = 'N'; set  @Default_N = 1
end
else if ( @Tipo = 'REGISTROS' and @Parametro = 'Dibujante.CaracterSeparadorDeAtributosDeCombinacionParaImpresionDeCodigoDeBarras' )
begin 
       set @IdNodo = 1; set @Nombre = 'Caracter separador de atributos de combinación para impresión de código de barras'; set @Proyecto = 'DIBUJANTE'; set @Campo = 'p.Valor'; set @TipoDato = 'C'; set @Default_C = '!'
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.VerificarExistenciaDeEquivalenciaEnLectura' )
begin 
       set @IdNodo = 4; set @Nombre = 'Verificar existencia de equivalencia en lectura'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'L'; set @Default_L = 0
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.HabilitarLectura' )
begin 
       set @IdNodo = 4; set @Nombre = 'Habilitar lectura'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'L'; set @Default_L = 0
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.CompletarLectura' )
begin 
       set @IdNodo = 4; set @Nombre = 'Completar lectura'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'L'; set @Default_L = 0
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.AnchoRequerido' )
begin 
       set @IdNodo = 4; set @Nombre = 'Ancho requerido'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'N'; set @Default_N = 14
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.CompletarLecturaALa' )
begin 
       set @IdNodo = 4; set @Nombre = 'Completar lectura a la'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'N'; set @Default_N = 1
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.CaracteresDeRelleno' )
begin 
       set @IdNodo = 4; set @Nombre = 'Caracteres de relleno'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'C'; set @Default_C = ''
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Felino.CodigosDeBarras.MostrarPrimerCoincidenciaEnLaBusquedaDeCodigosDeBarra' )
begin 
       set @IdNodo = 4; set @Nombre = 'Mostrar primer coincidencia en la búsqueda de códigos de barra'; set @Proyecto = 'FELINO'; set @Campo = 'p.Valor'; set @TipoDato = 'L'; set @Default_L = 0
end
else if ( @Tipo = 'PARAMETROS' and @Parametro = 'Nucleo.AgrupamientoParaConsultaDeStock' )
begin 
       set @IdNodo = 1; set @Nombre = 'AgrupamientoParaConsultaDeStock'; set @Proyecto = 'NUCLEO'; set @Campo = 's.Valor'; set @TipoDato = 'C'; set @Default_C = ''
end

if ( @Nombre is null )
	select 'ERROR: ' + @Tipo + ' ' + @Parametro + ' inexistente';
else
begin
	declare @sentencia varchar(max) = ''

	if ( @TipoDato = 'N' )
	begin
		   set @Campo = 'cast( ' + @Campo + ' as int ) ';
	end
	else
	if ( @TipoDato = 'L' )
	begin
		   set @Campo = 'cast( case when ' + @Campo + ' = ''.f.'' then 0 else case when ' + @Campo + ' = ''.t.'' then 1 else ' + @Campo + ' end end as bit ) ';
	end
	else
	if ( @TipoDato = 'D' )
	begin
		   set @Campo = 'cast( ' + @Campo + ' as datetime ) ';
	end
	 
	set @sentencia = '
	SELECT ' + @Campo + ' as Valor
	FROM [' + @Tipo + '].[CABECERA] as c
	left join [' + @Tipo + '].[PUESTO] as p on p.IdUnico = c.IdUnico
	left join [' + @Tipo + '].[ORGANIZACION] as o on o.IdUnico = c.IdUnico
	left join [' + @Tipo + '].[SUCURSAL] as s on s.IdUnico = c.IdUnico'
	+ ' where c.IdNodo = ' + cast( @IdNodo as varchar(100) ) + ' and c.Nombre = ''' + @Nombre + ''' and c.Proyecto = ''' + @Proyecto + ''''
	 
	 
	-- print ( @sentencia )
	if ( @TipoDato = 'C' )
	begin
			declare @outC table ( out varchar(254))
			insert into @outC exec(@sentencia) 
			IF NOT EXISTS (SELECT 1 FROM @outC)
				SELECT @Default_C 
			ELSE
				SELECT * FROM @outC
	end
	else
	if ( @TipoDato = 'N' )
	begin
			declare @outN table ( out int )
			insert into @outN exec(@sentencia) 
			IF NOT EXISTS (SELECT 1 FROM @outN)
				SELECT @Default_N 
			ELSE
				SELECT * FROM @outN
	end
	else
	if ( @TipoDato = 'L' )
	begin
			declare @outL table ( out bit )
			insert into @outL exec(@sentencia)
			IF NOT EXISTS (SELECT 1 FROM @outL)
				SELECT @Default_L
			ELSE
				SELECT * FROM @outL
	end
	else
	if ( @TipoDato = 'D' )
	begin
			declare @outD table ( out datetime )
			insert into @outD exec(@sentencia) 
			IF NOT EXISTS (SELECT 1 FROM @outD)
				SELECT @Default_D
			ELSE
				SELECT * FROM @outD
	end
	else
		   select 'ERROR: ' + @Tipo + ' ' + @Parametro + 'Tipo de dato incorrecto'
	end
end