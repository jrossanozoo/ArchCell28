IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[StockInicialOmnicanalidad]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[StockInicialOmnicanalidad];
GO;

CREATE FUNCTION [Funciones].[StockInicialOmnicanalidad]
( 
	
)
RETURNS TABLE
AS
RETURN
(
select funciones.alltrim(c_comb.BDALTAFW) as '_BD', 
case when funciones.alltrim(c_comb.COCOL) = '' or c_comb.COCOL is null then rtrim(c_comb.COART) + '!GRAL' else rtrim(c_comb.COART) + '!' + rtrim(c_comb.COCOL) end as 'Artículo', funciones.alltrim(c_art.ARTDES) as 'Descripción', 
funciones.alltrim(c_art.ARTDESADIC) as 'Descripción_adicional', funciones.alltrim(coalesce(c_color.COLDES,'')) as 'Color_descripción', case when funciones.alltrim(c_comb.talle) = '' or c_comb.talle is null then 'Talla Única' else rtrim(c_comb.talle) end as Talle,c_comb.COCANT as 'Cantidad',
funciones.alltrim(c_comb.COART) as 'coart',
funciones.alltrim(c_comb.COCOL) as 'cocol',
funciones.alltrim(c_comb.TALLE) as 'cotll',
c_art.ARTALTO as 'Alto',c_art.ARTANCHO as 'Ancho',c_art.ARTLARGO as 'Largo_cm',c_art.ARTPESO as 'Peso_kg', c_art.ANO as 'Año',
funciones.alltrim(c_art.CLASIFART) as 'Clasificación', funciones.alltrim(coalesce(c_clasifart.DESCRIP,'')) as 'Clasificación_descripción',
funciones.alltrim(c_art.FAMILIA) as 'Familia', funciones.alltrim(coalesce(c_familia.DESCRIP,'')) as 'Familia_descripción', funciones.alltrim(c_art.LINEA) as 'Línea', funciones.alltrim(coalesce(c_linea.DESCRIP,'')) as 'Línea_descripción',
funciones.alltrim(c_art.MAT) as 'Material', funciones.alltrim(coalesce(c_mat.MATDES,'')) as 'Material_descripción', funciones.alltrim(c_art.ARTFAB) as 'Proveedor', funciones.alltrim(coalesce(c_prov.CLNOM,'')) as 'Nombre',
funciones.alltrim(c_art.ATEMPORADA) as 'Temporada', funciones.alltrim(coalesce(c_tempo.TDES,'')) as 'Temporada_descripción', funciones.alltrim(c_art.TIPOARTI) as 'Tipo_de_artículo', funciones.alltrim(coalesce(c_tipoart.DESCRIP,'')) as 'Tipo_artículo_descripción',
funciones.alltrim(c_art.UNIMED) as 'Unidad_de_medida', funciones.alltrim(coalesce(c_unmed.DESCRIP,'')) as 'Unidad_de_medida_descripción',
funciones.alltrim(c_art.GRUPO) as 'Grupo', funciones.alltrim(coalesce(c_grupo.DESCRIP,'')) as 'Grupo_descripción', funciones.alltrim(c_art.ARIMAGEN) as 'Archivo'
from ZooLogic.comb as c_comb
inner join ZooLogic.ART as c_art on c_comb.COART = c_art.ARTCOD
left join ZooLogic.COL as c_color on c_comb.cocol = c_color.COLCOD
left join ZooLogic.CLASIFART as c_clasifart on c_art.CLASIFART = c_clasifart.CODIGO
left join ZooLogic.FAMILIA as c_familia on c_art.FAMILIA = c_familia.COD
left join ZooLogic.LINEA as c_linea on c_art.LINEA = c_linea.COD
left join ZooLogic.MAT as c_mat on c_art.MAT = c_mat.MATCOD
left join ZooLogic.PROV as c_prov on c_art.ARTFAB = c_prov.CLCOD
left join ZooLogic.TEMPORADA as c_tempo on c_art.ATEMPORADA = c_tempo.TCOD
left join ZooLogic.TIPOART as c_tipoart on c_art.TIPOARTI = c_tipoart.COD
left join ZooLogic.UNMED as c_unmed on c_art.UNIMED = c_unmed.COD
left join ZooLogic.grupo as c_grupo on c_art.GRUPO = c_grupo.COD
left join ZooLogic.PRECIOAR as c_precioar on c_comb.COART = c_precioar.ARTICULO and c_comb.COCOL = c_precioar.CCOLOR and c_comb.talle = c_precioar.TALLE
)


