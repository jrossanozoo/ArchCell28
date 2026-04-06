# Visual FoxPro Debugging

This project includes a configuration for debugging VFP files from VS Code.

## Run Configuration

The launch.json includes a "Run Visual FoxPro" configuration that:
1. First exports your VS Code breakpoints to VFP format 
2. Then executes the current file with dovfp.exe using the command:
```
dovfp run -template 1 yourfile.prg
```

## About dovfp

dovfp is a .NET global tool that needs to be installed with:
```
dotnet tool install --global dovfp --add-source ./nupkg
```

The executable is typically located at:
```
C:\Users\mrusso\.dotnet\tools\dovfp.exe
```

If the extension can't find it, you can set the path in settings:
1. Open VS Code settings
2. Search for "zoo-tool-kit.dovfpPath"
3. Enter the full path to dovfp.exe

## Breakpoints

Breakpoints set in VS Code are automatically exported before debugging starts.
- The breakpoints are saved to: C:\Users\mrusso\AppData\Roaming\Microsoft\Visual FoxPro 9\vsc_breakpoints.json
- This location is next to your FOXUSER.DBF file at: C:\Users\mrusso\AppData\Roaming\Microsoft\Visual FoxPro 9\FOXUSER.DBF
- This happens automatically when you start debugging (F5)

## Running PRG Files

When debugging a .prg file:
1. Make sure the file is open and active in the editor
2. Click the debugging icon or press F5 to start debugging
3. Your breakpoints will be exported and the file will run in VFP with the breakpoints active
