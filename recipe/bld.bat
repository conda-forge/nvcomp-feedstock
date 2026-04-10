@echo off
setlocal enabledelayedexpansion

for /f "tokens=1 delims=." %%i in ("%cuda_compiler_version%") do (
    set "major_version=%%i"
)

:: Exit on error
if errorlevel 1 exit /b 1

:: Install the Python wheel
%PYTHON% -m pip install .\nvidia_nvcomp_cu%major_version%-%PKG_VERSION%-py3-none-win_amd64.whl --no-deps

:: Query whether the current Python was configured with GIL disabled
for /f "delims=" %%i in ('%PYTHON% -c "import sysconfig; print(int(bool(sysconfig.get_config_var(\"Py_GIL_DISABLED\"))))"') do set "py_free_threaded=%%i"
set "PY_VER_t=%PY_VER:.=%"
if "!py_free_threaded!" == "1" (
    set "PY_VER_t=!PY_VER_t!t"
)

:: Exit on error
if errorlevel 1 exit /b 1

:: Remove unnecessary directories and files
rmdir /s /q %SP_DIR%\nvidia\nvcomp\include
del /q %SP_DIR%\nvidia\nvcomp\nvcomp*.dll

:: Exit on error
if errorlevel 1 exit /b 1

:: Loop through files and delete those whose Python version does not match %PY_VER%
for %%f in (%SP_DIR%\nvidia\nvcomp\nvcomp_impl.cp*-win_amd64.pyd) do (
    for /f "tokens=1 delims=-" %%i in ("%%~nf") do (
        set "temp=%%i"

        :: Python version with optional suffix t (indicating free-threadedness), e.g., 314t, or 314
        set "file_py_ver=!temp:*.cp=!"

        :: Delete the file if the Python version or the free-threadedness does not match
        if not "!file_py_ver!" == "!PY_VER_t!" (
            echo Deleting %%f as its Python version ^(!file_py_ver!^) does not match !PY_VER_t!
            del "%%f"
        )
    )
)

:: Exit on error
if errorlevel 1 exit /b 1

:: Copy the license file
copy %SP_DIR%\nvidia_nvcomp_cu%major_version%-%PKG_VERSION%.dist-info\licenses\LICENSE %SRC_DIR%

:: Exit on error
if errorlevel 1 exit /b 1
