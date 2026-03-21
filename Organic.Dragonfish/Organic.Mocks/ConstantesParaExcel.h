	&& Definicion de constantes de uso frecuente 
	
	&& Genericas
	#define Cr                               	chr(13)
	#define Lf                               	chr(10)
	#define CrLf                             	Cr + Lf
	#define Tab                              	chr(9)
	#define False                            	.f.
	#define True                             	.t.
	
	&& Para Excel
	#define xlLeft   							-4131
	#define xlCenter   							-4108
	#define xlRight   							-4152
	
	#define xlToLeft							-4159
	#define xlToRight							-4161
	#define xlUp								-4162
	#define xlDown								-4121
	
	#define xlWait								2		&& Puntero mouse HourGlass
	#define xlDefault							-4143	&& Puntero mouse Reset	
	
	#define xlPasteValues						-4163
	#define xlNone								-4142
	#define xlFormatFromLeftOrAbove				0
	#define xlLastCell 							11
	#define xlRangeAutoformatClassic2 			2
	#define xlPortrait 							1
	
	#define xlDataAndLabel						0
	#define xlLabelOnly							1
	#define xlDataOnly							2
	#define xlSolid								1
	#define xlAutomatic							-4105
	
	#define xlMaximized 						-4137
	#define xlDialogSaveAs						5	&& Dialogo Guardar como ...
	#define xlExcel12							50	&& Archivo Excel 2007-2010 binario
	#define xlOpenXMLWorkbook					51	&& Archivo Excel 2007-2010 sin macros
	#define xlExcel8							56  && Formato 97-2003 en Excel 2007-2010
	#define xlExclusive							3
	#define xlLocalSessionChanges				2

	#define xlDatabase							1
	#define xlPivotTableVersion2000				0	&& Excel 2000
	#define xlPivotTableVersion10 				1	&& Excel 2002
	#define xlPivotTableVersion11 				2	&& Excel 2003
	#define xlPivotTableVersion12				3	&& Excel 2007
	#define xlPivotTableVersion14				4	&& Excel 2010
	#define xlPivotTableVersionCurrent			-1	&& Version de Compatibilidad
	#define xlRowField							1
	#define xlColumnField						2 
	#define xlCount								-4112 
	#define xlSum								-4157 

	#define xlPasteAll							-4104
	#define xlPasteAllExceptBorders				7
	#define xlPasteAllMergingConditionalFormats	14
	#define xlPasteAllUsingSourceTheme			13
	#define xlPasteColumnWidths					8
	#define xlPasteComments						-4144
	#define xlPasteFormats						-4122
	#define xlPasteFormulas						-4123
	#define xlPasteFormulasAndNumberFormats		11
	#define xlPasteValidation					6
	#define xlPasteValues						-4163
	#define xlPasteValuesAndNumberFormats		12
	
	&& Tipo de coneciones
	#define xlConnectionTypeNOSOURCE			0	&& No source
	#define xlConnectionTypeOLEDB				1	&& OLEDB
	#define xlConnectionTypeODBC				2	&& ODBC
	#define xlConnectionTypeXMLMAP				3	&& XML MAP
	#define xlConnectionTypeTEXT				4	&& Text
	#define xlConnectionTypeWEB					5	&& Web
	#define xlConnectionTypeDATAFEED			6	&& Data Feed
	#define xlConnectionTypeMODEL				7	&& PowerPivot Model
	#define xlConnectionTypeWORKSHEET			8	&& Worksheet
