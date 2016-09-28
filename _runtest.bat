REM Please use first argument for ITERATIONS, second to specify which test it is -> new / old and last one to specify the input test file, e.g. _runtest.bat 10 new _runtest_input.txt
@echo off

REM Path where the .XML output files are found
set TEST_PATH=.\bin\Testing

REM The name of the XML files. This must be changed manually because i'm lazy
set DEFAULT_TEST_NAME=TEST-AlgorithmsTest

REM Default extension (it's XML who would've expected)
set XML_EXT=xml

REM Storage directory for the output tests
set STORAGE_DIR=C:\Users\QBR77747\Documents\mantid_issues\Issue-17273_MantidPerfTests

REM How many iterations of tests to run
set ITERATION_COUNT=%1
IF [%ITERATION_COUNT%] == [] set ITERATION_COUNT=5

REM Input file containing the test file names
REM Test file mode, this should be NEW or OLD, but in theory anything should work
set TEST_MODE=%2
IF [%TEST_MODE%] == [] set TEST_MODE=new

set INPUT_FILE_DIR=%3
IF [%INPUT_FILE_DIR%] == [] set INPUT_FILE_DIR=.\_runtest_input.txt

for /F "tokens=*" %%A in (%INPUT_FILE_DIR%) do (

	echo Running test for %%A
	echo %ITERATION_COUNT%

	mkdir %STORAGE_DIR%\%%A\%TEST_MODE%

	for /l %%x IN (1, 1, %ITERATION_COUNT%) DO (
		echo Running tests for %%A
	    start /w ctest -C Release -j8 -R %%A

	    if exist %STORAGE_DIR%\%%A\%TEST_MODE%\%DEFAULT_TEST_NAME%.%%A.%XML_EXT% (
	      REM File exists, renaming..
	      move %TEST_PATH%\%DEFAULT_TEST_NAME%.%%A.%XML_EXT% %STORAGE_DIR%\%%A\%TEST_MODE%\%DEFAULT_TEST_NAME%.%%A-%%x-.%XML_EXT%
	    ) else (
	      move %TEST_PATH%\%DEFAULT_TEST_NAME%.%%A.%XML_EXT% %STORAGE_DIR%\%%A\%TEST_MODE%\%DEFAULT_TEST_NAME%.%%A.%XML_EXT%
	    )
	)
	echo Running python algorithm at %STORAGE_DIR%
	start /w %STORAGE_DIR%\process.bat %STORAGE_DIR% .\%%A\%TEST_MODE%
)
