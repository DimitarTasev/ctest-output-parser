REM Please use first argument for ITERATIONS, second to specify which test it is -> new / old and last one to specify the test itself, e.g. _runtest.bat 10 new _runtest_input.txt
@echo off

REM Path where the .XML output files are found
set TEST_PATH=C:\Users\QBR77747\Documents\mantid_build\bin\Testing

REM The name of the XML files. This must be changed manually because i'm lazy
set DEFAULT_TEST_NAME=TEST-AlgorithmsTest

REM Default extension (it's XML who would've expected)
set XML_EXT=xml

REM Storage directory for the output tests
set STORAGE_DIR=C:\Users\QBR77747\Documents\mantid_issues\Issue-17273_MantidPerfTests

REM Input file containing the test file names
set INPUT_FILE_DIR=%3
IF [%INPUT_FILE_DIR%] == [] set INPUT_FILE_DIR=.\_runtest_input.txt

REM Test file mode, this should be NEW or OLD, but in theory anything should work
set TEST_MODE=%2
IF [%TEST_MODE%] == [] set TEST_MODE=new

REM How many iterations of tests to run
set ITERATION_COUNT=%1
IF [%ITERATION_COUNT%] == [] set ITERATION_COUNT=5

@echo off
mkdir %OUTPUT_STORAGE_DIR%

for /F "tokens=*" %%A in (%INPUT_FILE_DIR%) do (
	REM Name of the file test
	set FILE_NAME=%%A
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
			echo Running tests for %DEFAULT_TEST_NAME%
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
)
