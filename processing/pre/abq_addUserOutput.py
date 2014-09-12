#!/usr/bin/env python
# -*- coding: UTF-8 no BOM -*-

'''
Writes meaningful labels to the Abaqus input file (*.inp) 
based on the files 
<modelname_jobname>.output<Homogenization/Crystallite/Constitutive>
that are written during the first run of the model.
See Abaqus Keyword Reference Manual (AKRM) *DEPVAR for details.
Original script: marc_addUserOutput.py modified by Benjamin Bode
'''

import sys,os,re,string
from optparse import OptionParser
import damask 

scriptID = '$Id$'
scriptName = scriptID.split()[1][:-3]

# -----------------------------
def ParseOutputFormat(filename,what,me):
# -----------------------------
  format = {'outputs':{},'specials':{'brothers':[]}}

  outputmetafile = filename+'.output'+what
  try:
    file = open(outputmetafile)
  except:
    print('Could not open file %s'%outputmetafile)
    raise
  else: 
    content = file.readlines()
    file.close()

  tag = ''
  tagID = 0
  for line in content:
    if re.match("\s*$",line) or re.match("#",line):     # skip blank lines and comments
      continue
    m = re.match("\[(.+)\]",line)             # look for block indicator
    if m:                         # next section
      tag = m.group(1)
      tagID += 1
      format['specials']['brothers'].append(tag)
      if tag == me or (me.isdigit() and tagID == int(me)):
        format['specials']['_id'] = tagID
        format['outputs'] = []
        tag = me
    else:                         # data from section
      if tag == me:
        (output,length) = line.split()
        output.lower()
        if length.isdigit():
          length = int(length)
        if re.match("\((.+)\)",output):         # special data, (e.g. (Ngrains)
          format['specials'][output] = length
        elif length > 0:
          format['outputs'].append([output,length])
  return format


parser = OptionParser(option_class=damask.extendableOption, usage='%prog options [file[s]]', description = """
Transfer the output variables requested in the material.config to
properly labelled user defined variables within the Abaqus input file (*.inp).

Requires the files 
<modelname_jobname>.output<Homogenization/Crystallite/Constitutive>
that are written during the first run of the model.

Specify which user block format you want to apply by stating the homogenization, crystallite, and phase identifiers.
Or have an existing set of user variables copied over from another *.inp file.

""", version= scriptID)

parser.add_option('-n','--number', dest='number', type='int', \
          help='maximum requested User Defined Variable [%default]')
parser.add_option('--homogenization', dest='homog', \
          help='homogenization identifier (as string or integer [%default])')
parser.add_option('--crystallite', dest='cryst', \
          help='crystallite identifier (as string or integer [%default])')
parser.add_option('--phase', dest='phase', \
          help='phase identifier (as string or integer [%default])')
parser.add_option('--use', dest='useFile', \
          help='Optionally parse output descriptors from '+
               'different <model_job>.outputZZZ file. Saves the effort '+
               'to start a calculation for each job [%default])')
parser.add_option('--option', dest='damaskOption', \
          help='Add damask option to input file '+
               'for example: "periodic x z" [%default]')
parser.set_defaults(number = 0)
parser.set_defaults(homog = '1')
parser.set_defaults(cryst = '1')
parser.set_defaults(phase = '1')
parser.set_defaults(useFile = '')
parser.set_defaults(damaskOption = '')

(options, files) = parser.parse_args()

if not files:
  parser.print_help()
  parser.error('no file(s) specified...')

me = {  'Homogenization':   options.homog,
        'Crystallite':      options.cryst,
        'Constitutive':     options.phase,
     }


for file in files:
  print '\033[1m'+scriptName+'\033[0m: '+file+'\n'
  if options.useFile != '':
    formatFile = os.path.splitext(options.useFile)[0]
  else:
    formatFile = os.path.splitext(file)[0]
  file = os.path.splitext(file)[0]+'.inp'
  if not os.path.lexists(file):
    print file,'not found'
    continue
    
  print('Scanning format files of: %s'%formatFile)

  if options.number < 1:
    outputFormat = {}

    for what in me:
      outputFormat[what] = ParseOutputFormat(formatFile,what,me[what])
      if not '_id' in outputFormat[what]['specials']:
        print "'%s' not found in <%s>"%(me[what],what)
        print '\n'.join(map(lambda x:'  '+x,outputFormat[what]['specials']['brothers']))
        sys.exit(1)

    UserVars = ['HomogenizationCount']
    for var in outputFormat['Homogenization']['outputs']:
      if var[1] > 1:
        UserVars += ['%i_%s'%(i+1,var[0]) for i in range(var[1])]
      else:
        UserVars += ['%s'%(var[0]) for i in range(var[1])]

    UserVars += ['GrainCount']

    for grain in range(outputFormat['Homogenization']['specials']['(ngrains)']):
      UserVars += ['%i_CrystalliteCount'%(grain+1)]
      for var in outputFormat['Crystallite']['outputs']:
        if var[1] > 1:
          UserVars += ['%i_%i_%s'%(grain+1,i+1,var[0]) for i in range(var[1])]
        else:
          UserVars += ['%i_%s'%(grain+1,var[0]) for i in range(var[1])]

      UserVars += ['%i_ConstitutiveCount'%(grain+1)]
      for var in outputFormat['Constitutive']['outputs']:
        if var[1] > 1:
          UserVars += ['%i_%i_%s'%(grain+1,i+1,var[0]) for i in range(var[1])]
        else:
          UserVars += ['%i_%s'%(grain+1,var[0]) for i in range(var[1])]

# Now change *.inp file(s)        
  print('Adding labels to:         %s'%file)
  inFile = open(file)
  input = inFile.readlines()
  inFile.close()
  output = open(file,'w')
  thisSection = ''
  if options.damaskOption:
    output.write('$damask {0}\n'.format(options.damaskOption))
  for line in input:
    #Abaqus keyword line begins with: *keyword, argument1, ...
    m = re.match('([*]\w+)\s',line)
    if m:
      lastSection = thisSection
      thisSection = m.group(1)
      #Abaqus keyword can be upper or lower case
      if (lastSection.upper() == '*DEPVAR' and thisSection.upper() == '*USER'):
        #Abaqus SDVs are named SDV1...SDVn if no specific name is given
        #Abaqus needs total number of SDVs in the line after *Depvar keyword
        if options.number > 0:
          #number of SDVs
          output.write('%i\n'%options.number)
        else:
          #number of SDVs
          output.write('%i\n'%len(UserVars))
          #index,output variable key,output variable description
          for i in range(len(UserVars)): 
             output.write('%i,"%i%s","%i%s"\n'%(i+1,0,UserVars[i],0,UserVars[i]))
    if (thisSection.upper() != '*DEPVAR' or not re.match('\s*\d',line)):
      output.write(line)
  output.close()
