Define Class GetSpecialFolder as Custom

	*-----------------------------------------------------------------------------------------
	Procedure Init
		DoDefault()
	EndProc

	*-----------------------------------------------------------------------------------------
	Function DevuelveRuta( tnTipoCarpeta ) as Void
		Local lcRutaArchivosDePrograma As String
		
		lcRutaArchivosDePrograma = ""

		lcRutaArchivosDePrograma = This.ObtenerRutaApi1( tnTipoCarpeta )
		If Empty( lcRutaArchivosDePrograma )
			lcRutaArchivosDePrograma = This.ObtenerRutaApi2( tnTipoCarpeta )
		EndIf
		
		Return lcRutaArchivosDePrograma
	EndFunc

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerRutaApi1( tnRuta As Integer ) As String
		Local lcRetorno As String, lcFolderPath As String, loError As Exception

		lcFolderPath = Space( 255 )

		Try
			Declare Short SHGetFolderPath In SHFolder.dll ;
				Integer hwndOwner, ;
				Integer nFolder, ;
				Integer hToken, ;
				Integer dwFlags, ;
				String @pszPath

			SHGetFolderPath( 0, tnRuta, 0, 0, @lcFolderPath )
			lcRetorno = Alltrim( lcFolderPath )
			lcRetorno = SubStr( lcRetorno, 01, Len( lcRetorno ) - 01 )
		Catch To loError
			lcRetorno = ""
		Finally
			Clear Dlls "SHGetFolderPath"
		EndTry

		Return Addbs( lcRetorno )
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerRutaApi2( tnRuta As Integer ) As String
		Local lcRetorno As String, lcFolderPath As String, loError As Exception

		lcFolderPath = Space( 255 )

		Try
			Declare SHGetSpecialFolderPath In SHELL32.DLL ;
				Long hwndOwner, ;
				String @cSpecialFolderPath, ;
				Long nWhichFolder

			SHGetSpecialFolderPath( 0, @lcFolderPath, tnRuta )
			lcRetorno = Alltrim( lcFolderPath )
			lcRetorno = SubStr( lcRetorno, 01, Len( lcRetorno )-1 )
		Catch To loError
			lcRetorno = ""
		Finally
			Clear Dlls "SHGetSpecialFolderPath"
		EndTry

		Return Addbs( lcRetorno )
	EndFunc 

enddefine

function ValoresPosiblesDe_tnTipoCarpeta()
	*!*  Version 5.0. Combine this CSIDL with any of the following CSIDLs to force the creation of the associated folder.
	#DEFINE CSIDL_FLAG_CREATE 0x8000

	*!*  Version 5.0. The file system directory that is used to store administrative tools for an individual user. The Microsoft Management Console MMC will save customized consoles to this directory, and it will roam with the user.
	#DEFINE CSIDL_ADMINTOOLS 0x0030

	*!*   The file system directory that corresponds to the user's nonlocalized Startup program group.
	#DEFINE CSIDL_ALTSTARTUP 0x001d

	*!*   Version 4.71. The file system directory that serves as a common repository for application-specific data. A typical path is C:\Documents and Settings\username\Application Data. This CSIDL is supported by the redistributable Shfolder.dll for systems that do not have the Microsoft® Internet Explorer 4.0 integrated Shell installed.
	#DEFINE CSIDL_APPDATA 0x001a

	*!*   The virtual folder containing the objects in the user's Recycle Bin.
	#DEFINE CSIDL_BITBUCKET 0x000a

	*!*   Version 6.0. The file system directory acting as a staging area for files waiting to be written to CD. A typical path is C:\Documents and Settings\username\Local Settings\Application Data\Microsoft\CD Burning.
	#DEFINE CSIDL_CDBURN_AREA 0x003b

	*!*   Version 5.0. The file system directory containing administrative tools for all users of the computer.
	#DEFINE CSIDL_COMMON_ADMINTOOLS 0x002f

	*!*   The file system directory that corresponds to the nonlocalized Startup program group for all users. Valid only for Microsoft Windows NT® systems.
	#DEFINE CSIDL_COMMON_ALTSTARTUP 0x001e

	*!*   Version 5.0. The file system directory containing application data for all users. A typical path is C:\Documents and Settings\All Users\Application Data.
	#DEFINE CSIDL_COMMON_APPDATA 0x0023

	*!*   The file system directory that contains files and folders that appear on the desktop for all users. A typical path is C:\Documents and Settings\All Users\Desktop. Valid only for Windows NT systems.
	#DEFINE CSIDL_COMMON_DESKTOPDIRECTORY 0x0019

	*!*   The file system directory that contains documents that are common to all users. A typical paths is C:\Documents and Settings\All Users\Documents. Valid for Windows NT systems and Microsoft Windows® 95 and Windows 98 systems with Shfolder.dll installed.
	#DEFINE CSIDL_COMMON_DOCUMENTS 0x002e

	*!*   The file system directory that serves as a common repository for favorite items common to all users. Valid only for Windows NT systems.
	#DEFINE CSIDL_COMMON_FAVORITES 0x001f

	*!*   Version 6.0. The file system directory that serves as a repository for music files common to all users. A typical path is C:\Documents and Settings\All Users\Documents\My Music.
	#DEFINE CSIDL_COMMON_MUSIC 0x0035

	*!*   Version 6.0. The file system directory that serves as a repository for image files common to all users. A typical path is C:\Documents and Settings\All Users\Documents\My Pictures.
	#DEFINE CSIDL_COMMON_PICTURES 0x0036

	*!*   The file system directory that contains the directories for the common program groups that appear on the Start menu for all users. A typical path is C:\Documents and Settings\All Users\Start Menu\Programs. Valid only for Windows NT systems.
	#DEFINE CSIDL_COMMON_PROGRAMS 0x0017

	*!*   The file system directory that contains the programs and folders that appear on the Start menu for all users. A typical path is C:\Documents and Settings\All Users\Start Menu. Valid only for Windows NT systems.
	#DEFINE CSIDL_COMMON_STARTMENU 0x0016

	*!*   The file system directory that contains the programs that appear in the Startup folder for all users. A typical path is C:\Documents and Settings\All Users\Start Menu\Programs\Startup. Valid only for Windows NT systems.
	#DEFINE CSIDL_COMMON_STARTUP 0x0018

	*!*   The file system directory that contains the templates that are available to all users. A typical path is C:\Documents and Settings\All Users\Templates. Valid only for Windows NT systems.
	#DEFINE CSIDL_COMMON_TEMPLATES 0x002d

	*!*   Version 6.0. The file system directory that serves as a repository for video files common to all users. A typical path is C:\Documents and Settings\All Users\Documents\My Videos.
	#DEFINE CSIDL_COMMON_VIDEO 0x0037

	*!*   The virtual folder containing icons for the Control Panel applications.
	#DEFINE CSIDL_CONTROLS 0x0003

	*!*   The file system directory that serves as a common repository for Internet cookies. A typical path is C:\Documents and Settings\username\Cookies.
	#DEFINE CSIDL_COOKIES 0x0021

	*!*   The virtual folder representing the Windows desktop, the root of the namespace.
	#DEFINE CSIDL_DESKTOP 0x0000

	*!*   The file system directory used to physically store file objects on the desktop not to be confused with the desktop folder itself. A typical path is C:\Documents and Settings\username\Desktop.
	#DEFINE CSIDL_DESKTOPDIRECTORY 0x0010

	*!*   The virtual folder representing My Computer, containing everything on the local computer: storage devices, printers, and Control Panel. The folder may also contain mapped network drives.
	#DEFINE CSIDL_DRIVES 0x0011

	*!*   The file system directory that serves as a common repository for the user's favorite items. A typical path is C:\Documents and Settings\username\Favorites.
	#DEFINE CSIDL_FAVORITES 0x0006

	*!*   A virtual folder containing fonts. A typical path is C:\Windows\Fonts.
	#DEFINE CSIDL_FONTS 0x0014

	*!*   The file system directory that serves as a common repository for Internet history items.
	#DEFINE CSIDL_HISTORY 0x0022

	*!*   A virtual folder representing the Internet.
	#DEFINE CSIDL_INTERNET 0x0001

	*!*   Version 4.72. The file system directory that serves as a common repository for temporary Internet files. A typical path is C:\Documents and Settings\username\Local Settings\Temporary Internet Files.
	#DEFINE CSIDL_INTERNET_CACHE 0x0020

	*!*   Version 5.0. The file system directory that serves as a data repository for local nonroaming applications. A typical path is C:\Documents and Settings\username\Local Settings\Application Data.
	#DEFINE CSIDL_LOCAL_APPDATA 0x001c

	*!*   Version 6.0. The virtual folder representing the My Documents desktop item.
	#DEFINE CSIDL_MYDOCUMENTS 0x000c

	*!*   The file system directory that serves as a common repository for music files. A typical path is C:\Documents and Settings\User\My Documents\My Music.
	#DEFINE CSIDL_MYMUSIC 0x000d

	*!*   Version 5.0. The file system directory that serves as a common repository for image files. A typical path is C:\Documents and Settings\username\My Documents\My Pictures.
	#DEFINE CSIDL_MYPICTURES 0x0027

	*!*   Version 6.0. The file system directory that serves as a common repository for video files. A typical path is C:\Documents and Settings\username\My Documents\My Videos.
	#DEFINE CSIDL_MYVIDEO 0x000e

	*!*   A file system directory containing the link objects that may exist in the My Network Places virtual folder. It is not the same as CSIDL_NETWORK, which represents the network namespace root. A typical path is C:\Documents and Settings\username\NetHood.
	#DEFINE CSIDL_NETHOOD 0x0013

	*!*   A virtual folder representing Network Neighborhood, the root of the network namespace hierarchy.
	#DEFINE CSIDL_NETWORK 0x0012

	*!*   Version 6.0. The virtual folder representing the My Documents desktop item. This is equivalent to CSIDL_MYDOCUMENTS.
	*!*   Previous to Version 6.0. The file system directory used to physically store a user's common repository of documents. A typical path is C:\Documents and Settings\username\My Documents. This should be distinguished from the virtual My Documents folder in the namespace. To access that virtual folder, use SHGetFolderLocation, which returns the ITEMIDLIST for the virtual location, or refer to the technique described in Managing the File System.
	#DEFINE CSIDL_PERSONAL 0x0005

	*!*   The virtual folder containing installed printers.
	#DEFINE CSIDL_PRINTERS 0x0004

	*!*   The file system directory that contains the link objects that can exist in the Printers virtual folder. A typical path is C:\Documents and Settings\username\PrintHood.
	#DEFINE CSIDL_PRINTHOOD 0x001b

	*!*   Version 5.0. The user's profile folder. A typical path is C:\Documents and Settings\username. Applications should not create files or folders at this level; they should put their data under the locations referred to by CSIDL_APPDATA or CSIDL_LOCAL_APPDATA.
	#DEFINE CSIDL_PROFILE 0x0028

	*!*   Version 6.0. The file system directory containing user profile folders. A typical path is C:\Documents and Settings.
	#DEFINE CSIDL_PROFILES 0x003e

	*!*   Version 5.0. The Program Files folder. A typical path is C:\Program Files.
	#DEFINE CSIDL_PROGRAM_FILES 0x0026

	*!*   Version 5.0. A folder for components that are shared across applications. A typical path is C:\Program Files\Common. Valid only for Windows NT, Windows 2000, and Windows XP systems. Not valid for Windows Millennium Edition Windows Me.
	#DEFINE CSIDL_PROGRAM_FILES_COMMON 0x002b

	*!*   The file system directory that contains the user's program groups which are themselves file system directories. A typical path is C:\Documents and Settings\username\Start Menu\Programs.
	#DEFINE CSIDL_PROGRAMS 0x0002

	*!*   The file system directory that contains shortcuts to the user's most recently used documents. A typical path is C:\Documents and Settings\username\My Recent Documents. To create a shortcut in this folder, use SHAddToRecentDocs. In addition to creating the shortcut, this function updates the Shell's list of recent documents and adds the shortcut to the My Recent Documents submenu of the Start menu.
	#DEFINE CSIDL_RECENT 0x0008

	*!*   The file system directory that contains Send To menu items. A typical path is C:\Documents and Settings\username\SendTo.
	#DEFINE CSIDL_SENDTO 0x0009

	*!*   The file system directory containing Start menu items. A typical path is C:\Documents and Settings\username\Start Menu.
	#DEFINE CSIDL_STARTMENU 0x000b

	*!*   The file system directory that corresponds to the user's Startup program group. The system starts these programs whenever any user logs onto Windows NT or starts Windows 95. A typical path is C:\Documents and Settings\username\Start Menu\Programs\Startup.
	#DEFINE CSIDL_STARTUP 0x0007

	*!*   Version 5.0. The Windows System folder. A typical path is C:\Windows\System32.
	#DEFINE CSIDL_SYSTEM 0x0025

	*!*   The file system directory that serves as a common repository for document templates. A typical path is C:\Documents and Settings\username\Templates.
	#DEFINE CSIDL_TEMPLATES 0x0015

	*!*   Version 5.0. The Windows directory or SYSROOT. This corresponds to the %windir% or %SYSTEMROOT% environment variables. A typical path is C:\Windows.
	#DEFINE CSIDL_WINDOWS 0x0024
EndFunc
