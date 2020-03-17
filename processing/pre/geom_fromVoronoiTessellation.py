#!/usr/bin/env python3

import os
import sys
import multiprocessing
from optparse import OptionParser,OptionGroup

import numpy as np
from scipy import spatial

import damask


scriptName = os.path.splitext(os.path.basename(__file__))[0]
scriptID   = ' '.join([scriptName,damask.version])


def Laguerre_tessellation(grid, coords, weights, grains, periodic = True, cpus = 2):

  def findClosestSeed(fargs):
    point, seeds, myWeights = fargs
    tmp = np.repeat(point.reshape(3,1), len(seeds), axis=1).T
    dist = np.sum((tmp - seeds)**2,axis=1) -myWeights
    return np.argmin(dist)                                                                          # seed point closest to point

  copies = \
    np.array([
              [ -1,-1,-1 ],
              [  0,-1,-1 ],
              [  1,-1,-1 ],
              [ -1, 0,-1 ],
              [  0, 0,-1 ],
              [  1, 0,-1 ],
              [ -1, 1,-1 ],
              [  0, 1,-1 ],
              [  1, 1,-1 ],
              [ -1,-1, 0 ],
              [  0,-1, 0 ],
              [  1,-1, 0 ],
              [ -1, 0, 0 ],
              [  0, 0, 0 ],
              [  1, 0, 0 ],
              [ -1, 1, 0 ],
              [  0, 1, 0 ],
              [  1, 1, 0 ],
              [ -1,-1, 1 ],
              [  0,-1, 1 ],
              [  1,-1, 1 ],
              [ -1, 0, 1 ],
              [  0, 0, 1 ],
              [  1, 0, 1 ],
              [ -1, 1, 1 ],
              [  0, 1, 1 ],
              [  1, 1, 1 ],
             ]).astype(float)*info['size'] if periodic else \
    np.array([
              [  0, 0, 0 ],
             ]).astype(float)

  repeatweights = np.tile(weights,len(copies)).flatten(order='F')                                   # Laguerre weights (1,2,3,1,2,3,...,1,2,3)
  for i,vec in enumerate(copies):                                                                   # periodic copies of seed points ...
    try: seeds = np.append(seeds, coords+vec, axis=0)                                               # ... (1+a,2+a,3+a,...,1+z,2+z,3+z)
    except NameError: seeds = coords+vec

  damask.util.croak('...using {} cpu{}'.format(options.cpus, 's' if options.cpus > 1 else ''))
  arguments = [[arg,seeds,repeatweights] for arg in list(grid)]

  if cpus > 1:                                                                                      # use multithreading
    pool = multiprocessing.Pool(processes = cpus)                                                   # initialize workers
    result = pool.map_async(findClosestSeed, arguments)                                             # evaluate function in parallel
    pool.close()
    pool.join()
    closestSeeds = np.array(result.get()).flatten()
  else:
    closestSeeds = np.zeros(len(arguments),dtype='i')
    for i,arg in enumerate(arguments):
      closestSeeds[i] = findClosestSeed(arg)

# closestSeed is modulo number of original seed points (i.e. excluding periodic copies)
  return grains[closestSeeds%coords.shape[0]]


def Voronoi_tessellation(grid, coords, grains, size, periodic = True):

  KDTree = spatial.cKDTree(coords,boxsize=size) if periodic else spatial.cKDTree(coords)
  devNull,closestSeeds = KDTree.query(grid)
  return grains[closestSeeds]


# --------------------------------------------------------------------
#                                MAIN
# --------------------------------------------------------------------

parser = OptionParser(option_class=damask.extendableOption, usage='%prog option(s) [seedfile(s)]', description = """
Generate geometry description and material configuration by tessellation of given seeds file.

""", version = scriptID)


group = OptionGroup(parser, "Tessellation","")

group.add_option('-l',
                 '--laguerre',
                 dest = 'laguerre',
                 action = 'store_true',
                 help = 'use Laguerre (weighted Voronoi) tessellation')
group.add_option('--cpus',
                 dest = 'cpus',
                 type = 'int', metavar = 'int',
                 help = 'number of parallel processes to use for Laguerre tessellation [%default]')
group.add_option('--nonperiodic',
                 dest = 'periodic',
                 action = 'store_false',
                 help = 'nonperiodic tessellation')

parser.add_option_group(group)

group = OptionGroup(parser, "Geometry","")

group.add_option('-g',
                 '--grid',
                 dest = 'grid',
                 type = 'int', nargs = 3, metavar = ' '.join(['int']*3),
                 help = 'a,b,c grid of hexahedral box')
group.add_option('-s',
                 '--size',
                 dest = 'size',
                 type = 'float', nargs = 3, metavar=' '.join(['float']*3),
                 help = 'x,y,z size of hexahedral box')
group.add_option('-o',
                 '--origin',
                 dest = 'origin',
                 type = 'float', nargs = 3, metavar=' '.join(['float']*3),
                 help = 'origin of grid')
group.add_option('--nonnormalized',
                 dest = 'normalized',
                 action = 'store_false',
                 help = 'seed coordinates are not normalized to a unit cube')

parser.add_option_group(group)

group = OptionGroup(parser, "Seeds","")

group.add_option('-p',
                 '--pos', '--seedposition',
                  dest = 'pos',
                  type = 'string', metavar = 'string',
                  help = 'label of coordinates [%default]')
group.add_option('-w',
                 '--weight',
                 dest = 'weight',
                 type = 'string', metavar = 'string',
                 help = 'label of weights [%default]')
group.add_option('-m',
                 '--microstructure',
                 dest = 'microstructure',
                 type = 'string', metavar = 'string',
                 help = 'label of microstructures [%default]')
group.add_option('-e',
                 '--eulers',
                 dest = 'eulers',
                 type = 'string', metavar = 'string',
                 help = 'label of Euler angles [%default]')
group.add_option('--axes',
                 dest = 'axes',
                 type = 'string', nargs = 3, metavar = ' '.join(['string']*3),
                 help = 'orientation coordinate frame in terms of position coordinate frame')

parser.add_option_group(group)

group = OptionGroup(parser, "Configuration","")

group.add_option('--without-config',
                 dest = 'config',
                 action = 'store_false',
                 help = 'omit material configuration header')
group.add_option('--homogenization',
                 dest = 'homogenization',
                 type = 'int', metavar = 'int',
                 help = 'homogenization index to be used [%default]')
group.add_option('--phase',
                 dest = 'phase',
                 type = 'int', metavar = 'int',
                 help = 'phase index to be used [%default]')

parser.add_option_group(group)

parser.set_defaults(pos            = 'pos',
                    weight         = 'weight',
                    microstructure = 'microstructure',
                    eulers         = 'euler',
                    homogenization = 1,
                    phase          = 1,
                    cpus           = 2,
                    laguerre       = False,
                    periodic       = True,
                    normalized     = True,
                    config         = True,
                  )

(options,filenames) = parser.parse_args()
if filenames == []: filenames = [None]

for name in filenames:
  damask.util.report(scriptName,name)

  table = damask.ASCIItable(name = name, readonly = True)


# --- read header ----------------------------------------------------------------------------

  table.head_read()
  info,extra_header = table.head_getGeom()

  if options.grid   is not None: info['grid']   = options.grid
  if options.size   is not None: info['size']   = options.size
  if options.origin is not None: info['origin'] = options.origin

# ------------------------------------------ sanity checks ---------------------------------------

  remarks = []
  errors = []
  labels = []

  hasGrains  = table.label_dimension(options.microstructure) == 1
  hasEulers  = table.label_dimension(options.eulers) == 3
  if options.laguerre and table.label_dimension(options.weight) != 1:
    errors.append('missing seed weights...')

  for i in range(3):
    if info['size'][i] <= 0.0:                                                                      # any invalid size?
      info['size'][i] = float(info['grid'][i])/max(info['grid'])                                    # normalize to grid
      remarks.append('rescaling size {} to {}...'.format(['x','y','z'][i],info['size'][i]))

  if table.label_dimension(options.pos) != 3:
    errors.append('seed positions "{}" have dimension {}.'.format(options.pos,
                                                                  table.label_dimension(options.pos)))
  else:
    labels += [options.pos]

  if not options.normalized:               remarks.append('using real-space seed coordinates...')
  if not hasEulers:                        remarks.append('missing seed orientations...')
  else: labels += [options.eulers]
  if not hasGrains:                        remarks.append('missing seed microstructure indices...')
  else: labels += [options.microstructure]

  if remarks != []: damask.util.croak(remarks)
  if errors != []:
    damask.util.croak(errors)
    table.close(dismiss=True)
    continue

# ------------------------------------------ read seeds ---------------------------------------

  table.data_readArray(labels)
  coords    = table.data[:,table.label_indexrange(options.pos)] * info['size'] if options.normalized \
        else  table.data[:,table.label_indexrange(options.pos)] - info['origin']
  eulers    = table.data[:,table.label_indexrange(options.eulers)] if hasEulers \
              else np.zeros(3*len(coords))
  grains    = table.data[:,table.label_indexrange(options.microstructure)].astype(int) if hasGrains \
              else np.arange(len(coords))+1

  grainIDs  = np.unique(grains).astype('i')
  NgrainIDs = len(grainIDs)

# --- tessellate microstructure ------------------------------------------------------------
  grid = damask.grid_filters.cell_coord0(info['grid'],info['size']).reshape(-1,3)
  damask.util.croak('tessellating...')
  if options.laguerre:
    weights = table.data[:,table.label_indexrange(options.weight)]
    indices = Laguerre_tessellation(grid, coords, weights, grains, options.periodic, options.cpus)
  else:
    indices = Voronoi_tessellation(grid, coords, grains, info['size'], options.periodic)

  config_header = []
  if options.config:

    if hasEulers:
      config_header += ['<texture>']
      for ID in grainIDs:
        eulerID = np.nonzero(grains == ID)[0][0]                                                    # find first occurrence of this grain id
        config_header += ['[Grain{}]'.format(ID),
                          '(gauss)\tphi1 {:.2f}\tPhi {:.2f}\tphi2 {:.2f}'.format(*eulers[eulerID])
                         ]
        if options.axes is not None: config_header += ['axes\t{} {} {}'.format(*options.axes)]

    config_header += ['<microstructure>']
    for ID in grainIDs:
      config_header += ['[Grain{}]'.format(ID),
                        '(constituent)\tphase {}\ttexture {}\tfraction 1.0'.format(options.phase,ID)
                       ]

    config_header += ['<!skip>']

  header = [scriptID + ' ' + ' '.join(sys.argv[1:])]\
         + config_header
  geom = damask.Geom(indices.reshape(info['grid'],order='F'),info['size'],info['origin'],
                     homogenization=options.homogenization,comments=header)
  damask.util.croak(geom)

  geom.to_file(sys.stdout if name is None else os.path.splitext(name)[0]+'.geom',pack=False)
