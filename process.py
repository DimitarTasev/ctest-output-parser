from os import walk
import os
import sys
import xml.etree.ElementTree as ET

NEW_DIR = "./new"
OLD_DIR = "./old"


def readFilenames(filedir):
    f = []
    for (dirpath, dirnames, filenames) in walk(filedir):
        f.extend(filenames)
        break
    return f


def validChild(child):
    # exclude all tests that have a system-err as their time is invalid
    for c in child:
        # check if it has a child with tag system-err
        if (c.tag == "system-err"):
            return False

    return True


def processRoot(results, root):
    childPos = 1
    for child in root:
        # if we have less elements in the array, then it hasnt been initialised
        if (validChild(child)):
            if (childPos > len(results)):
                results.append(
                    {
                        'name': child.attrib['name'],
                        'time': child.attrib['time'],
                        'runs': 1 # start from 1 to get accurate count
                    })
            else:
                # get the old time
                oldTime = results[childPos - 1]['time']
                # sum old time + new time
                newTime = float(child.attrib['time']) + float(oldTime)

                oldRuns = results[childPos - 1]['runs']
                newRuns = 1 + int(oldRuns)
                # change child at correct element, hence - 1
                results[childPos - 1] = {
                    'name': child.attrib['name'],
                    'time': newTime,
                    'runs': newRuns
                }
            childPos += 1
        else:
            print "excluding invalid test"
            # print results


def exportResults(filedir, exportDir, results, root):
    expStr = '<?xml version="1.0" encoding="UTF-8" ?><' + root.tag + " "

    # recreate test tag
    for k, v in root.attrib.iteritems():
        expStr += k + "=\"" + v + "\" "
    expStr += '>'

    # get classname for fancy style
    classname = root[0].attrib['classname']

    # recreate test cases
    for res in results:
        expStr += '<testcase classname=\"' + classname + "\" name=\"" +         \
        res['name'] + "\" totalTime=\""+ str(res['time']) +"\" averageTime=\"" +\
        str(float(res['time']) / float(res['runs'])) + "\" testsProcessed=\"" + \
        str(res['runs']) + "\" testType=\"" + filedir[-3:] + "\" ></testcase>"

    expStr += "</testsuite>"
    try:
        newFilepath = exportDir + '/TEST-' + classname + '-average-' + filedir[-3:] + '.xml'
        newF = open(newFilepath, 'w')
    except IOError:
        newFilepath = './TEST-' + classname + '-average-' + filedir[-3:] + '.xml'
        print "ERROR: Directory " + exportDir + " doesn't exist. Creating file at " + newFilepath
        newF = open(newFilepath, 'w')

    newF.write(expStr)


def validFile(f):
    return f[0:4] == "TEST" and f[-3:] == "xml"


def process(filedir, exportDir):
    # read ALL file names from directory, if any unexpected files
    # are present the program will FAIL horribly and unpredictably
    filenames = readFilenames(filedir)

    # save a pointer to the root for formatting
    sneakyRoot = None

    # holder for the dictionary of results
    results = []

    runs = 0
    # simple runs counter to properly average out the exit value
    if (len(filenames) < 1):
        exit("No files found! Please make sure the files are in ./new and ./old directory relative to the .py file!")

    for f in filenames:
        if (validFile(f)):
            filePath = os.path.join(filedir, f)
            print "Processing file: " + str(filePath)
            try:
                tree = ET.parse(filePath)
                root = tree.getroot()
                sneakyRoot = root
                processRoot(results, root)
                runs += 1
                print "Done."
            except ET.ParseError:
                print "Found invalid file in directory: " + f +" does not have valid XML structure."
        else:
            print "Skipping over file, invalid name: " + f

    if (sneakyRoot is not None):
        exportResults(filedir, exportDir, results, sneakyRoot)
        print "Successfully processed " + str(runs) + " "+ filedir + " tests!"
    else:
        print "Processing end. No valid files found."


argc = len(sys.argv)
if (argc < 2):
    exit("invalid argument, please specify new or old")

argv = sys.argv
if(argc < 3):
    exportDir = "./"
else:
    exportDir = argv[2]
    # Truncate trailing dash    
    if(exportDir[-1:] == '/' or exportDir[-1:] == '\\'):
        exportDir = exportDir[:-1]


print "Export dir is: " + exportDir

choice = None
userArg = argv[1]
if (userArg == 'old'):
    choice = OLD_DIR
elif (userArg == 'new'):
    choice = NEW_DIR
else:
    choice = userArg

process(choice, exportDir)
