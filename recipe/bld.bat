@echo off
setlocal enabledelayedexpansion

for /f "tokens=1 delims=." %%i in ("%cuda_compiler_version%") do (
    set "major_version=%%i"
)

:: Exit on error
if errorlevel 1 exit /b 1

:: Install the Python wheel
%PYTHON% -m pip install .\nvidia_nvcomp_cu%major_version%-%PKG_VERSION%-py3-none-win_amd64.whl --no-deps

:: Exit on error
if errorlevel 1 exit /b 1

:: Remove unnecessary directories and files
rmdir /s /q %SP_DIR%\nvidia\nvcomp\include
del /q %SP_DIR%\nvidia\nvcomp\nvcomp.dll

:: Exit on error
if errorlevel 1 exit /b 1

:: Loop through files and delete those whose Python version does not match %PY_VER%
for %%f in (%SP_DIR%\nvidia\nvcomp\nvcomp_impl.cp*-win_amd64.pyd) do (
    for /f "tokens=1 delims=-" %%i in ("%%~nf") do (
        set "temp=%%i"
        set "file_py_ver=!temp:*.cp=!"
        if not "!file_py_ver!" == "%PY_VER:.=%" (
            echo Deleting %%f as its Python version ^(!file_py_ver!^) does not match %PY_VER%
            del "%%f"
        )
    )
)

:: Exit on error
if errorlevel 1 exit /b 1

:: Copy the license file
copy %SP_DIR%\nvidia_nvcomp_cu%major_version%-%PKG_VERSION%.dist-info\LICENSE %SRC_DIR%

:: Exit on error
if errorlevel 1 exit /b 1
