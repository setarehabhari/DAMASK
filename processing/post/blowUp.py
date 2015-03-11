#!/usr/bin/env python
# -*- coding: UTF-8 no BOM -*-

import os,sys,string
import numpy as np
from optparse import OptionParser
import damask

scriptID   = string.replace('$Id$','\n','\\n')
scriptName = os.path.splitext(scriptID.split()[1])[0]

# --------------------------------------------------------------------
#                                MAIN
# --------------------------------------------------------------------

parser = OptionParser(option_class=damask.extendableOption, usage='%prog options [file[s]]', description = """
Blows up each value to a surrounding data block of size 'packing' thus increasing the former resolution
to resolution*packing.

""", version = scriptID)

parser.add_option('-c','--coordinates', dest='coords', metavar='string',
                                        help='column heading for coordinates [%default]')
parser.add_option('-p','--packing',     dest='packing', type='int', nargs=3, metavar='int int int',
                                        help='dimension of packed group %default')
parser.add_option('-g','--grid',        dest='resolution', type='int', nargs=3, metavar='int int int',
                                        help='resolution in x,y,z [autodetect]')
parser.add_option('-s','--size',        dest='dimension', type='float', nargs=3, metavar='int int int',
                                        help='dimension in x,y,z [autodetect]')
parser.set_defaults(coords  = 'ipinitialcoord')
parser.set_defaults(packing = [2,2,2])
parser.set_defaults(grid    = [0,0,0])
parser.set_defaults(size    = [0.0,0.0,0.0])

(options,filenames) = parser.parse_args()


options.packing = np.array(options.packing)
prefix = 'blowUp%ix%ix%i_'%(options.packing[0],options.packing[1],options.packing[2])

# ------------------------------------------ setup file handles ------------------------------------
files = []
for name in filenames:
  if os.path.exists(name):
    files.append({'name':name, 'input':open(name), 'output':open(name+'_tmp','w'), 'croak':sys.stderr})

#--- loop over input files -------------------------------------------------------------------------
for file in files:
  file['croak'].write('\033[1m'+scriptName+'\033[0m: '+file['name']+'\n')

  table = damask.ASCIItable(file['input'],file['output'],False)                                     # make unbuffered ASCII_table
  table.head_read()                                                                                 # read ASCII header info
  table.info_append(scriptID + '\t' + ' '.join(sys.argv[1:]))

# --------------- figure out size and grid ---------------------------------------------------------
  try:
    elemCol = table.labels.index('elem')
    locationCol = table.labels.index('1_%s'%options.coords)                                         # columns containing location data
  except ValueError:
    try:
      locationCol = table.labels.index('%s.x'%options.coords)                                       # columns containing location data (legacy naming scheme)
    except ValueError:
      file['croak'].write('no coordinate (1_%s/%s.x) and/or elem data found...\n'%(options.coords,options.coords))
      continue

  if (any(options.grid)==0 or any(options.size)==0.0):
    coords = [{},{},{}]
    while table.data_read():                                                                        # read next data line of ASCII table
      for j in xrange(3):
        coords[j][str(table.data[locationCol+j])] = True                                            # remember coordinate along x,y,z
    grid = np.array([len(coords[0]),\
                     len(coords[1]),\
                     len(coords[2]),],'i')                                                          # resolution is number of distinct coordinates found
    size = grid/np.maximum(np.ones(3,'d'),grid-1.0)* \
              np.array([max(map(float,coords[0].keys()))-min(map(float,coords[0].keys())),\
                        max(map(float,coords[1].keys()))-min(map(float,coords[1].keys())),\
                        max(map(float,coords[2].keys()))-min(map(float,coords[2].keys())),\
                        ],'d')                                                                      # size from bounding box, corrected for cell-centeredness
    origin = np.array([min(map(float,coords[0].keys())),\
                       min(map(float,coords[1].keys())),\
                       min(map(float,coords[2].keys())),\
                      ],'d') - 0.5 * size / grid
  else:
    grid = np.array(options.grid,'i')
    size  = np.array(options.size,'d')
    origin     = np.zeros(3,'d')

  for i, res in enumerate(grid):
    if res == 1:
      options.packing[i] = 1
      options.shift[i]   = 0
      mask = np.ones(3,dtype=bool)
      mask[i]=0
      size[i] = min(size[mask]/grid[mask])                                                          # third spacing equal to smaller of other spacing
  
  packing = np.array(options.packing,'i')
  outSize = grid*packing
  
# ------------------------------------------ assemble header ---------------------------------------
  table.head_write()

# ------------------------------------------ process data -------------------------------------------
  table.data_rewind()
  data = np.zeros(outSize.tolist()+[len(table.labels)])
  p = np.zeros(3,'i')
  
  for p[2] in xrange(grid[2]):
    for p[1] in xrange(grid[1]):
      for p[0] in xrange(grid[0]):
        d = p*packing
        table.data_read()
        data[d[0]:d[0]+packing[0],
             d[1]:d[1]+packing[1],
              d[2]:d[2]+packing[2],
             : ] = np.tile(np.array(table.data_asFloat(),'d'),packing.tolist()+[1])                 # tile to match blowUp voxel size

  elementSize = size/grid/packing
  elem = 1
  for c in xrange(outSize[2]):
    for b in xrange(outSize[1]):
      for a in xrange(outSize[0]):
        data[a,b,c,locationCol:locationCol+3] = [a+0.5,b+0.5,c+0.5]*elementSize
        data[a,b,c,elemCol] = elem
        table.data = data[a,b,c,:].tolist()
        outputAlive = table.data_write()                                                            # output processed line
        elem += 1

# ------------------------------------------ output result -----------------------------------------  
  outputAlive and table.output_flush()                                                              # just in case of buffered ASCII table

  table.input_close()                                                                               # close input ASCII table
  table.output_close()                                                                              # close output ASCII table
  os.rename(file['name']+'_tmp',\
            os.path.join(os.path.dirname(file['name']),prefix+os.path.basename(file['name'])))
