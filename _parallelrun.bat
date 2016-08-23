@echo off
REM Set variables here because each file is in a new folder
REM Name of the file test
set FILE_NAME=%1

REM The output directory of the .XML file
set OUTPUT_STORAGE_DIR=%STORAGE_DIR%\%FILE_NAME%\%TEST_MODE%

REM Reconstructing the name of the TEST-AlgorithmsTest.. etc
set TEST_NAME=%DEFAULT_TEST_NAME%.%FILE_NAME%.%XML_EXT%

REM The relative dir from the process.bat to the tests
set PYTHON_RELATIVE_DIR=.\%FILE_NAME%\%TEST_MODE%

echo Running test for %FILE_NAME%
echo %ITERATION_COUNT%

mkdir %OUTPUT_STORAGE_DIR%

for /l %%x IN (1, 1, %ITERATION_COUNT%) DO (
    start /w ctest -C Debug -j8 -V -R %FILE_NAME%

    if exist %OUTPUT_STORAGE_DIR%\%TEST_NAME% (
      REM File exists, renaming..
      move %TEST_PATH%\%TEST_NAME% %OUTPUT_STORAGE_DIR%\%DEFAULT_TEST_NAME%.%FILE_NAME%-%%x-.%XML_EXT%
    ) else (
      move %TEST_PATH%\%TEST_NAME% %OUTPUT_STORAGE_DIR%\%TEST_NAME%
    )
)
echo Running python algorithm at %STORAGE_DIR%
start /w %STORAGE_DIR%\process.bat %STORAGE_DIR% %PYTHON_RELATIVE_DIR%
exit
