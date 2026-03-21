#ifndef __ARGCOMMANDBARS_H_INCLUDED__
#define __ARGCOMMANDBARS_H_INCLUDED__

****************************************************************
* Library classes
****************************************************************

#define _CommandBar_CLASS				"CommandBar"
#define _MenuBar_CLASS					"MenuBar"
#define _Popup_CLASS					"Popup"
#define _DialogBar_CLASS				"DialogBar"
#define _Ribbon_CLASS					"Ribbon"

#define _CommandBarButton_CLASS			"CommandBarButton"
#define _CommandBarComboBox_CLASS		"CommandBarComboBox"
#define _CommandBarTextBox_CLASS		"CommandBarTextBox"
#define _CommandBarCheckBox_CLASS		"CommandBarCheckBox"
#define _CommandBarOptionButton_CLASS	"CommandBarOptionButton"
#define _CommandBarLabel_CLASS			"CommandBarLabel"
#define _CommandBarMenuPad_CLASS		"CommandBarMenuPad"
#define _CommandBarMenuItem_CLASS		"CommandBarMenuItem"
#define _CommandBarCustomControl_CLASS	"CommandBarCustomControl"

#define _RibbonTab_CLASS				"RibbonTab"
#define _RibbonGroup_CLASS				"RibbonGroup"


****************************************************************
* Visual Theme identifiers
****************************************************************

#define _VISUAL_THEME_FIRST				0

#define _VISUAL_THEME_OFFICEXP			0
#define _VISUAL_THEME_OFFICE2000		1
#define _VISUAL_THEME_OFFICE2003		2
#define _VISUAL_THEME_WINXP				3
#define _VISUAL_THEME_OFFICE2003_WINXP	4
#define _VISUAL_THEME_VSTUDIO2005		5
#define _VISUAL_THEME_OFFICE2007		6
#define _VISUAL_THEME_RIBBON			7
#define _VISUAL_THEME_VSTUDIO2008		8


#define _VISUAL_THEME_LAST				8

****************************************************************
* Color Scheme identifiers
****************************************************************

#define _COLOR_SCHEME_FIRST				0

#define _COLOR_SCHEME_OFFICE2007_BLUE		0
#define _COLOR_SCHEME_OFFICE2007_BLACK		1
#define _COLOR_SCHEME_OFFICE2007_AQUA		2
#define _COLOR_SCHEME_OFFICE2007_SILVER		3
#define _COLOR_SCHEME_OFFICE2010_BLUE		4
#define _COLOR_SCHEME_OFFICE2010_SILVER		5
#define _COLOR_SCHEME_OFFICE2010_BLACK		6
#define _COLOR_SCHEME_WINDOWS7_BLUE			7

* Obsolete constant. Use _COLOR_SCHEME_WINDOWS7_BLUE
#define _COLOR_SCHEME_WINDOWS7_SCENIC		_COLOR_SCHEME_WINDOWS7_BLUE

#define _COLOR_SCHEME_LAST				7

******************************************************************
* Command Bar Docking Flags
******************************************************************

#define _ACB_CBDF_ALIGNTOP		0x00000001
#define _ACB_CBDF_ALIGNBOTTOM	0x00000002
#define _ACB_CBDF_ALIGNLEFT		0x00000004
#define _ACB_CBDF_ALIGNRIGHT	0x00000008
#define _ACB_CBDF_ALIGNANY		(_ACB_CBDF_ALIGNTOP + _ACB_CBDF_ALIGNBOTTOM + _ACB_CBDF_ALIGNLEFT + _ACB_CBDF_ALIGNRIGHT)

******************************************************************
* Command Bar Types
******************************************************************

#define _ACB_BARTYPE_NORMAL					0
#define _ACB_BARTYPE_TOOLBAR				_ACB_BARTYPE_NORMAL
#define _ACB_BARTYPE_MENUBAR				1
#define _ACB_BARTYPE_POPUP					2
#define _ACB_BARTYPE_DIALOG					3
#define _ACB_BARTYPE_RIBBON					4

******************************************************************
* Control Types
******************************************************************

#define _ACB_CONTROLTYPE_BUTTON				0
#define _ACB_CONTROLTYPE_COMBOBOX			1
#define _ACB_CONTROLTYPE_TEXTBOX			2
#define _ACB_CONTROLTYPE_CUSTOM				3
#define _ACB_CONTROLTYPE_LABEL				4
#define _ACB_CONTROLTYPE_CHECKBOX			5
#define _ACB_CONTROLTYPE_OPTIONBUTTON		6
#define _ACB_CONTROLTYPE_MENUITEM			7

******************************************************************
* Button Types
******************************************************************

#define _ACB_BUTTONTYPE_BUTTON				0
#define _ACB_BUTTONTYPE_POPUP				1
#define _ACB_BUTTONTYPE_BUTTONPOPUP			2
#define _ACB_BUTTONTYPE_SPLITBUTTONPOPUP	3

******************************************************************
* Control Sizes
******************************************************************

#define _ACB_CONTROLSIZE_AUTO					0
#define _ACB_CONTROLSIZE_NORMAL					1
#define _ACB_CONTROLSIZE_LARGE					2

******************************************************************
* Dock Position
******************************************************************

#define _ACB_DOCKPOSITION_FLOATING			-1
#define _ACB_DOCKPOSITION_TOP				0
#define _ACB_DOCKPOSITION_LEFT				1
#define _ACB_DOCKPOSITION_RIGHT				2
#define _ACB_DOCKPOSITION_BOTTOM			3

******************************************************************
* Custom Item Options (Flags)
******************************************************************

#define _ACB_CIO_NONE						0
#define _ACB_CIO_CHECKED					0x00000001
#define _ACB_CIO_DISABLED					0x00000002
#define _ACB_CIO_BEGINGROUP					0x00000004
#define _ACB_CIO_HIDDEN						0x00000008
#define _ACB_CIO_MRU						0x00000010

#define _ACB_CIO_RESERVED3					0x00000020
#define _ACB_CIO_RESERVED4					0x00000040
#define _ACB_CIO_RESERVED5					0x00000080
#define _ACB_CIO_RESERVED6					0x00000100
#define _ACB_CIO_RESERVED7					0x00000200
#define _ACB_CIO_RESERVED8					0x00000400
#define _ACB_CIO_RESERVED9					0x00000800
#define _ACB_CIO_RESERVED10					0x00001000
#define _ACB_CIO_RESERVED11					0x00002000
#define _ACB_CIO_RESERVED12					0x00004000
#define _ACB_CIO_RESERVED13					0x00008000

******************************************************************
* Control Hide Flags
******************************************************************

#define _ACB_CHF_HIDEGENERIC				1		&& control is hidden by generic reason
#define _ACB_CHF_HIDECUSTOMIZE				16		&& control is hidden by customize settings


****************************************************************
* Font identifiers (see GetFont method of the CommandBarsManager)
****************************************************************

#define _ACB_FONT_Regular					0
#define _ACB_FONT_Icon						1
#define _ACB_FONT_Status					2
#define _ACB_FONT_SmCaption					3

#define _ACB_FONT_Last						3

******************************************************************
* ToolTip Styles
******************************************************************

#define _TTS_First						0

#define _TTS_Standard						0
#define _TTS_Balloon						1
#define _TTS_Office						2
#define _TTS_Luna						3
#define _TTS_Office2007						4

#define _TTS_Last						4


****************************************************************
* Size identifiers Width or Height (see GetPopupSize method of
* the CommandBarsManager)
****************************************************************

#define _ACB_POPUPSIZE_WIDTH			0
#define _ACB_POPUPSIZE_HEIGHT			1

****************************************************************
* Office Button Styles
****************************************************************

#define OfficeButtonStyle_Auto			0
#define OfficeButtonStyle_2007			1
#define OfficeButtonStyle_2010			2

******************************************************************
* GetXml method Flags
******************************************************************

#define _GETXML_FLAGS_IncludeXmlDeclaration		1
#define _GETXML_FLAGS_IncludeBlankValues		2
#define _GETXML_FLAGS_IncludeDefaultValues		4

******************************************************************
* Localizable Strings
******************************************************************

#define _ACB_LSID_ToolbarOptions			1	&& Tooltip: "Toolbar Options"
#define _ACB_LSID_ToolbarClose				2	&& Tooltip: "Close"
#define _ACB_LSID_AddOrRemoveButtons		3	&& Toolbar Options popup: "&Add or Remove Buttons"
#define _ACB_LSID_ResetToolbar				4	&& Toolbar Options popup: "&Reset Toolbar"
#define _ACB_LSID_EditCut					5	&& Edit popup: "Cuts the selection and moves it to the Clipboard\nCu&t"
#define _ACB_LSID_EditCopy					6	&& Edit popup: "Copies the selection to the Clipboard\n&Copy"
#define _ACB_LSID_EditPaste					7	&& Edit popup: "Inserts the Clipboard contents at the insertion point\n&Paste"
#define _ACB_LSID_EditUndo					8	&& Edit popup: "Undoes the last action\n&Undo"
#define _ACB_LSID_EditRedo					9	&& Edit popup: "Redoes the previously undone action\n&Redo"
#define _ACB_LSID_MdiMinimize				10	&& MDI menu button: "Minimize Window"
#define _ACB_LSID_MdiRestore				11	&& MDI menu button: "Restore Window"
#define _ACB_LSID_MdiClose					12	&& MDI menu button: "Close Window"
#define _ACB_LSID_ShortcutSecondKey			13	&& (%s) was pressed. Waiting for second key of chord...
#define _ACB_LSID_ShortcutNotCommand		14	&& The key combination (%s, %s) is not a command

#define _ACB_LSID_RibbonCustomize				15	&& "&Customize Quick Access Toolbar..."
#define _ACB_LSID_RibbonCustomize_Remove		16	&& "&Remove from Quick Access Toolbar"
#define _ACB_LSID_RibbonCustomize_Add			17	&& "&Add to Quick Access Toolbar"
#define _ACB_LSID_RibbonCustomize_Label			18	&& "Customize Quick Access Toolbar"
#define _ACB_LSID_RibbonCustomize_Minimize		19	&& "Mi&nimize the Ribbon"
#define _ACB_LSID_RibbonCustomize_MoreCommands	20	&& "&More Commands..."
#define _ACB_LSID_RibbonCustomize_QA_Below		21	&& "&Show Quick Access Toolbar Below the Ribbon"
#define _ACB_LSID_RibbonCustomize_QA_Above		22	&& "&Show Quick Access Toolbar Above the Ribbon"
#define _ACB_LSID_RibbonCustomize_QA_Below_2	23	&& "&Show Below the Ribbon"
#define _ACB_LSID_RibbonCustomize_QA_Above_2	24	&& "&Show Above the Ribbon"


******************************************************************
* Office image identifiers (see OfficeImageId property)
******************************************************************

#define _imgMso_ApplicationOptionsDialog	"ApplicationOptionsDialog"
#define _imgMso_Bold						"Bold"
#define _imgMso_ChangeCase					"ChangeCase"
#define _imgMso_Clear						"Clear"
#define _imgMso_Copy						"Copy"
#define _imgMso_Cut							"Cut"
#define _imgMso_Delete						"Delete"
#define _imgMso_FileClose					"FileClose"
#define _imgMso_FileExit					"FileExit"
#define _imgMso_FileInternetFax				"FileInternetFax"
#define _imgMso_FileNew						"FileNew"
#define _imgMso_FileOpen					"FileOpen"
#define _imgMso_FilePrepareMenu				"FilePrepareMenu"
#define _imgMso_FilePrint					"FilePrint"
#define _imgMso_FilePrintPreview			"FilePrintPreview"
#define _imgMso_FilePrintQuick				"FilePrintQuick"
#define _imgMso_FileSave					"FileSave"
#define _imgMso_FileSaveAs					"FileSaveAs"
#define _imgMso_FileSendAsAttachment		"FileSendAsAttachment"
#define _imgMso_FileSendMenu				"FileSendMenu"
#define _imgMso_FilterAdvancedByForm		"FilterAdvancedByForm"
#define _imgMso_FindDialog					"FindDialog"
#define _imgMso_FindNext					"FindNext"
#define _imgMso_FontDialog					"FontDialog"
#define _imgMso_FontSizeDecrease			"FontSizeDecrease"
#define _imgMso_FontSizeIncrease			"FontSizeIncrease"
#define _imgMso_FormatPainter				"FormatPainter"
#define _imgMso_GoTo						"GoTo"
#define _imgMso_GoToFirstRecord				"GoToFirstRecord"
#define _imgMso_GoToLastRecord				"GoToLastRecord"
#define _imgMso_GoToNextRecord				"GoToNextRecord"
#define _imgMso_GoToPreviousRecord			"GoToPreviousRecord"
#define _imgMso_HappyFace					"HappyFace"
#define _imgMso_Help						"Help"
#define _imgMso_Italic						"Italic"
#define _imgMso_ItemProperties				"ItemProperties"
#define _imgMso_Paste						"Paste"
#define _imgMso_PasteSpecialDialog			"PasteSpecialDialog"
#define _imgMso_PrintOptionsMenu			"PrintOptionsMenu"
#define _imgMso_PrintPreviewClose			"PrintPreviewClose"
#define _imgMso_PrintPreviewMultiplePagesMenu	"PrintPreviewMultiplePagesMenu"
#define _imgMso_Redo						"Redo"
#define _imgMso_ReplaceDialog				"ReplaceDialog"
#define _imgMso_SaveAll						"SaveAll"
#define _imgMso_SelectAll					"SelectAll"
#define _imgMso_SelectMenu					"SelectMenu"
#define _imgMso_SortAscending				"SortAscending"
#define _imgMso_SortDescending				"SortDescending"
#define _imgMso_Strikethrough				"Strikethrough"
#define _imgMso_Subscript					"Subscript"
#define _imgMso_Superscript					"Superscript"
#define _imgMso_Underline					"Underline"
#define _imgMso_Undo						"Undo"
#define _imgMso_WindowHide					"WindowHide"
#define _imgMso_WindowNew					"WindowNew"
#define _imgMso_WindowsArrangeAll			"WindowsArrangeAll"
#define _imgMso_WindowsCascade				"WindowsCascade"
#define _imgMso_WindowsSwitch				"WindowsSwitch"
#define _imgMso_Zoom100						"Zoom100"
#define _imgMso_ZoomCurrent100				"ZoomCurrent100"
#define _imgMso_ZoomDialog					"ZoomDialog"
#define _imgMso_ZoomFitToWindow				"ZoomFitToWindow"
#define _imgMso_ZoomIn						"ZoomIn"
#define _imgMso_ZoomOnePage					"ZoomOnePage"
#define _imgMso_ZoomOut						"ZoomOut"
#define _imgMso_ZoomPageWidth				"ZoomPageWidth"
#define _imgMso_ZoomTwoPages				"ZoomTwoPages"

#define _imgMso_RibbonMinimize				"RibbonMinimize"

******************************************************************
* Color Indexes for GetColor and SetColor methods of the CommandBarsManager class
******************************************************************

#define _ACB_COLOR_DockBar_Light			1
#define _ACB_COLOR_DockBar_Dark				2
#define _ACB_COLOR_CommandBar_Light			3
#define _ACB_COLOR_CommandBar_Dark			4
#define _ACB_COLOR_Button_Highlight_Light	5
#define _ACB_COLOR_Button_Highlight_Dark	6
#define _ACB_COLOR_Button_Checked_Light		7
#define _ACB_COLOR_Button_Checked_Dark		8
#define _ACB_COLOR_Button_Pushed_Light		9
#define _ACB_COLOR_Button_Pushed_Dark		10
#define _ACB_COLOR_Button_Highlight_Border	11
#define _ACB_COLOR_Button_Checked_Border	12
#define _ACB_COLOR_Button_Pushed_Border		13

#define _ACB_COLOR_Text_Default				14
#define _ACB_COLOR_Text_Highlight			15
#define _ACB_COLOR_Text_Checked				16
#define _ACB_COLOR_Text_Pushed				17
#define _ACB_COLOR_Text_Disabled			18
#define _ACB_COLOR_CommandBar_Shadow		19

#define _ACB_COLOR_Toolbar_Face				30

#define _ACB_COLOR_Highlight				31
#define _ACB_COLOR_Highlight_Border			32

#define _ACB_COLOR_Pushed					33
#define _ACB_COLOR_Pushed_Border			34

#define _ACB_COLOR_Checked					35
#define _ACB_COLOR_Checked_Border			36

#define _ACB_COLOR_Menubar_Text				44
#define _ACB_COLOR_Menubar_Text_Disabled	37

#define _ACB_COLOR_Toolbar_Text				46
#define _ACB_COLOR_Toolbar_Text_Disabled	72

#define _ACB_COLOR_Highlight_Text			45
#define _ACB_COLOR_Pushed_Text				47
#define _ACB_COLOR_Checked_Text				_ACB_COLOR_Highlight_Text

#define _ACB_COLOR_TextBox_Border			53

#define _ACB_COLOR_Control_Face				61

#define _ACB_COLOR_TextBox_ForeColor		62
#define _ACB_COLOR_TextBox_BackColor		63

#define _ACB_COLOR_TextBox_Selected_ForeColor		64
#define _ACB_COLOR_TextBox_Selected_BackColor		65

#define _ACB_COLOR_TextBox_Disabled_ForeColor		66
#define _ACB_COLOR_TextBox_Disabled_BackColor		67

#define _ACB_COLOR_TextBox_ReadOnly_ForeColor		68
#define _ACB_COLOR_TextBox_ReadOnly_BackColor		69

#define _ACB_COLOR_WorkspaceClientTop			95
#define _ACB_COLOR_WorkspaceClientMiddle		96
#define _ACB_COLOR_WorkspaceClientBottom		97


* Navigation Pane Colors

#define _ACB_COLOR_NP_Frame					100
#define _ACB_COLOR_NP_Splitter_Light		101
#define _ACB_COLOR_NP_Splitter_Dark			102
#define _ACB_COLOR_NP_Button_Light			103
#define _ACB_COLOR_NP_Button_Dark			104
#define _ACB_COLOR_NP_ButtonHot_Light		105
#define _ACB_COLOR_NP_ButtonHot_Dark		106
#define _ACB_COLOR_NP_ButtonSelected_Light	107
#define _ACB_COLOR_NP_ButtonSelected_Dark	108
#define _ACB_COLOR_NP_ButtonPushed_Light	109
#define _ACB_COLOR_NP_ButtonPushed_Dark		110

#define _ACB_COLOR_NP_Header_Light			111
#define _ACB_COLOR_NP_Header_Dark			112
#define _ACB_COLOR_NP_Header_Text			113

#define _ACB_COLOR_AppWorkSpace				114

#define _ACB_COLOR_NP_Button_Mid1			115
#define _ACB_COLOR_NP_Button_Mid2			116
#define _ACB_COLOR_NP_ButtonHot_Mid1		117
#define _ACB_COLOR_NP_ButtonHot_Mid2		118
#define _ACB_COLOR_NP_ButtonSelected_Mid1	119
#define _ACB_COLOR_NP_ButtonSelected_Mid2	120
#define _ACB_COLOR_NP_ButtonPushed_Mid1		121
#define _ACB_COLOR_NP_ButtonPushed_Mid2		122

#define _ACB_COLOR_NP_Button_Text			130
#define _ACB_COLOR_NP_ButtonHot_Text		131
#define _ACB_COLOR_NP_ButtonSelected_Text	132
#define _ACB_COLOR_NP_ButtonPushed_Text		133

#define _ACB_COLOR_NP_SmallHeader_Light		134
#define _ACB_COLOR_NP_SmallHeader_Dark		135
#define _ACB_COLOR_NP_SmallHeader_Text		136
#define _ACB_COLOR_NP_SmallHeader_Top		137
#define _ACB_COLOR_NP_SmallHeader_Shadow	138

#define _ACB_COLOR_CalendarBase				140

#define _ACB_COLOR_ToolbarExpand_Light		200
#define _ACB_COLOR_ToolbarExpand_Dark		201
#define _ACB_COLOR_HighlighPopuped_Light	202
#define _ACB_COLOR_HighlighPopuped_Dark		203
#define _ACB_COLOR_PopupExpandGripper_Light	204
#define _ACB_COLOR_PopupExpandGripper_Dark	205
#define _ACB_COLOR_PopupExpandCircle_Light	206
#define _ACB_COLOR_PopupExpandCircle_Dark	207
#define _ACB_COLOR_FloatingBarGripper		208
#define _ACB_COLOR_FloatingBarGripperText	209
#define _ACB_COLOR_FloatingBarBorder		210
#define _ACB_COLOR_MenuBarText				211

** Status bar colors (Office 2007 Theme)

#define _ACB_COLOR_StatusBarText			212
#define _ACB_Color_StatusBarTop_Light		213
#define _ACB_Color_StatusBarTop_Dark		214
#define _ACB_Color_StatusBarBottom_Light	215
#define _ACB_Color_StatusBarBottom_Dark		216
#define _ACB_Color_StatusBarShadow			217

** Tool Tip colors (Office 2007 and Ribbon Themes)

#define _ACB_Color_ToolTip_Light		218
#define _ACB_Color_ToolTip_Dark			219
#define _ACB_Color_ToolTip_Border		220

#define _ACB_COLOR_LAST						220

#endif	&& __ARGCOMMANDBARS_H_INCLUDED__