#!/usr/bin/env python3

import os
import sys
import random
from io import StringIO
from optparse import OptionParser,OptionGroup

import numpy as np
from scipy import spatial

import damask


scriptName = os.path.splitext(os.path.basename(__file__))[0]
scriptID   = ' '.join([scriptName,damask.version])


def kdtree_search(cloud, queryPoints):
  """Find distances to nearest neighbor among cloud (N,d) for each of the queryPoints (n,d)."""
  n = queryPoints.shape[0]
  distances = np.zeros(n,dtype=float)
  tree = spatial.cKDTree(cloud)

  for i in range(n):
    distances[i], index = tree.query(queryPoints[i])

  return distances


# --------------------------------------------------------------------
#                                MAIN
# --------------------------------------------------------------------

parser = OptionParser(option_class=damask.extendableOption, usage='%prog options', description = """
Distribute given number of points randomly within (a fraction of) the three-dimensional cube [0.0,0.0,0.0]--[1.0,1.0,1.0].
Reports positions with random crystal orientations in seeds file format to STDOUT.

""", version = scriptID)

parser.add_option('-N',
                  dest = 'N',
                  type = 'int', metavar = 'int',
                  help = 'number of seed points [%default]')
parser.add_option('-f',
                  '--fraction',
                  dest = 'fraction',
                  type = 'float', nargs = 3, metavar = 'float float float',
                  help='fractions along x,y,z of unit cube to fill %default')
parser.add_option('-g',
                  '--grid',
                  dest = 'grid',
                  type = 'int', nargs = 3, metavar = 'int int int',
                  help='min a,b,c grid of hexahedral box %default')
parser.add_option('-m',
                  '--microstructure',
                  dest = 'microstructure',
                  type = 'int', metavar = 'int',
                  help = 'first microstructure index [%default]')
parser.add_option('-r',
                  '--rnd',
                  dest = 'randomSeed', type = 'int', metavar = 'int',
                  help = 'seed of random number generator [%default]')

group = OptionGroup(parser, "Laguerre Tessellation",
                   "Parameters determining shape of weight distribution of seed points"
                   )
group.add_option( '-w',
                  '--weights',
                  action = 'store_true',
                  dest   = 'weights',
                  help   = 'assign random weights to seed points for Laguerre tessellation [%default]')
group.add_option( '--max',
                  dest = 'max',
                  type = 'float', metavar = 'float',
                  help = 'max of uniform distribution for weights [%default]')
group.add_option( '--mean',
                  dest = 'mean',
                  type = 'float', metavar = 'float',
                  help = 'mean of normal distribution for weights [%default]')
group.add_option( '--sigma',
                  dest = 'sigma',
                  type = 'float', metavar = 'float',
                  help='standard deviation of normal distribution for weights [%default]')
parser.add_option_group(group)

group = OptionGroup(parser, "Selective Seeding",
                    "More uniform distribution of seed points using Mitchell's Best Candidate Algorithm"
                   )
group.add_option( '-s',
                  '--selective',
                  action = 'store_true',
                  dest   = 'selective',
                  help   = 'selective picking of seed points from random seed points')
group.add_option( '--distance',
                  dest = 'distance',
                  type = 'float', metavar = 'float',
                  help = 'minimum distance to next neighbor [%default]')
group.add_option( '--numCandidates',
                  dest = 'numCandidates',
                  type = 'int', metavar = 'int',
                  help = 'size of point group to select best distance from [%default]')
parser.add_option_group(group)

parser.set_defaults(randomSeed = None,
                    grid = (16,16,16),
                    fraction = (1.0,1.0,1.0),
                    N = 20,
                    weights = False,
                    max = 0.0,
                    mean = 0.2,
                    sigma = 0.05,
                    microstructure = 1,
                    selective = False,
                    distance = 0.2,
                    numCandidates = 10,
                   )

(options,filenames) = parser.parse_args()
if filenames == []: filenames = [None]

fraction = np.array(options.fraction)
grid     = np.array(options.grid)

if options.randomSeed is None: options.randomSeed = int(os.urandom(4).hex(), 16)
np.random.seed(options.randomSeed)                                                                  # init random generators
random.seed(options.randomSeed)

for name in filenames:
  damask.util.report(scriptName,name)

# --- sanity checks -------------------------------------------------------------------------
  remarks = []
  errors  = []
  if any(grid==0):
    errors.append('zero grid dimension for {}.'.format(', '.join([['a','b','c'][x] for x in np.where(grid == 0)[0]])))
  if options.N > grid.prod()/10.:
    remarks.append('seed count exceeds 0.1 of grid points.')
  if options.selective and 4./3.*np.pi*(options.distance/2.)**3*options.N > 0.5:
    remarks.append('maximum recommended seed point count for given distance is {}'.
                   format(int(3./8./np.pi/(options.distance/2.)**3)))

  if remarks != []: damask.util.croak(remarks)
  if errors  != []:
    damask.util.croak(errors)
    sys.exit()

# --- do work ------------------------------------------------------------------------------------
  grainEuler = np.random.rand(3,options.N)                                                          # create random Euler triplets
  grainEuler[0,:] *= 360.0                                                                          # phi_1    is uniformly distributed
  grainEuler[1,:] = np.degrees(np.arccos(2*grainEuler[1,:]-1))                                      # cos(Phi) is uniformly distributed
  grainEuler[2,:] *= 360.0                                                                          # phi_2    is uniformly distributed

  if not options.selective:
    n = np.maximum(np.ones(3),np.array(grid*fraction),
                   dtype=int,casting='unsafe')                                                      # find max grid indices within fraction
    meshgrid = np.meshgrid(*map(np.arange,n),indexing='ij')                                         # create a meshgrid within fraction
    coords = np.vstack((meshgrid[0],meshgrid[1],meshgrid[2])).reshape(3,n.prod()).T                 # assemble list of 3D coordinates
    seeds = ((random.sample(list(coords),options.N)+np.random.random(options.N*3).reshape(options.N,3))\
              / \
             (n/fraction)).T                                                                        # pick options.N of those, rattle position,
                                                                                                    # and rescale to fall within fraction
  else:
    seeds = np.zeros((options.N,3),dtype=float)                                                     # seed positions array
    seeds[0] = np.random.random(3)*grid/max(grid)
    i = 1                                                                                           # start out with one given point
    if i%(options.N/100.) < 1: damask.util.croak('.',False)

    while i < options.N:
      candidates = np.random.random(options.numCandidates*3).reshape(options.numCandidates,3)
      distances  = kdtree_search(seeds[:i],candidates)
      best = distances.argmax()
      if distances[best] > options.distance:                                                        # require minimum separation
        seeds[i] = candidates[best]                                                                 # maximum separation to existing point cloud
        i += 1
        if i%(options.N/100.) < 1: damask.util.croak('.',False)

    damask.util.croak('')
    seeds = seeds.T                                                                                 # prepare shape for stacking

  if options.weights:
    weights = [np.random.uniform(low = 0, high = options.max, size = options.N)] if options.max > 0.0 \
         else [np.random.normal(loc = options.mean, scale = options.sigma, size = options.N)]


  data = np.transpose(np.vstack(tuple([seeds,
                                       grainEuler,
                                       np.arange(options.microstructure,options.microstructure + options.N),
                                      ] + (weights if options.weights else [])
                                 )))

  comments = [scriptID + ' ' + ' '.join(sys.argv[1:]),
              'grid\ta {}\tb {}\tc {}'.format(*grid),
              'randomSeed\t{}'.format(options.randomSeed),
             ]

  shapes = {'pos':(3,),'euler':(3,),'microstructure':(1,)}
  if options.weights: shapes['weight'] = (1,)

  table = damask.Table(data,shapes,comments)
  table.to_ASCII(sys.stdout if name is None else name)
