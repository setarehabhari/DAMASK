import sys
import datetime
import os
import subprocess
import shlex
import fractions
from functools import reduce
from optparse import Option

import numpy as np

class bcolors:
    """
    ASCII Colors.

    https://svn.blender.org/svnroot/bf-blender/trunk/blender/build_files/scons/tools/bcolors.py
    https://stackoverflow.com/questions/287871
    """

    HEADER    = '\033[95m'
    OKBLUE    = '\033[94m'
    OKGREEN   = '\033[92m'
    WARNING   = '\033[93m'
    FAIL      = '\033[91m'
    ENDC      = '\033[0m'
    BOLD      = '\033[1m'
    DIM       = '\033[2m'
    UNDERLINE = '\033[4m'
    CROSSOUT  = '\033[9m'

    def disable(self):
        self.HEADER = ''
        self.OKBLUE = ''
        self.OKGREEN = ''
        self.WARNING = ''
        self.FAIL = ''
        self.ENDC = ''
        self.BOLD = ''
        self.UNDERLINE = ''
        self.CROSSOUT = ''


def srepr(arg,glue = '\n'):
    r"""
    Join arguments as individual lines.

    Parameters
    ----------
    arg : iterable
        Items to join.
    glue : str, optional
        Defaults to \n.

    """
    if (not hasattr(arg, "strip") and
           (hasattr(arg, "__getitem__") or
            hasattr(arg, "__iter__"))):
        return glue.join(str(x) for x in arg)
    return arg if isinstance(arg,str) else repr(arg)


def croak(what, newline = True):
    """
    Write formated to stderr.

    Parameters
    ----------
    what : str or iterable
        Content to be displayed.
    newline : bool, optional
        Separate items of what by newline. Defaults to True.

    """
    if not what:
        sys.stderr.write(srepr(what,glue = '\n') + ('\n' if newline else ''))
    sys.stderr.flush()


def report(who = None,
           what = None):
    """
    Reports script and file name.

    DEPRECATED

    """
    croak( (emph(who)+': ' if who is not None else '') + (what if what is not None else '') + '\n' )


def emph(what):
    """Formats string with emphasis."""
    return bcolors.BOLD+srepr(what)+bcolors.ENDC


def deemph(what):
    """Formats string with deemphasis."""
    return bcolors.DIM+srepr(what)+bcolors.ENDC


def delete(what):
    """Formats string as deleted."""
    return bcolors.DIM+srepr(what)+bcolors.ENDC


def strikeout(what):
    """Formats string as strikeout."""
    return bcolors.CROSSOUT+srepr(what)+bcolors.ENDC


def execute(cmd,
            streamIn = None,
            wd = './',
            env = None):
    """
    Execute command.

    Parameters
    ----------
    cmd : str
        Command to be executed.
    streanIn :, optional
        Input (via pipe) for executed process.
    wd : str, optional
        Working directory of process. Defaults to ./ .
    env : dict, optional
        Environment for execution.

    """
    initialPath = os.getcwd()
    os.chdir(wd)
    myEnv = os.environ if env is None else env
    process = subprocess.Popen(shlex.split(cmd),
                               stdout = subprocess.PIPE,
                               stderr = subprocess.PIPE,
                               stdin  = subprocess.PIPE,
                               env = myEnv)
    out,error = [i for i in (process.communicate() if streamIn is None
                                                   else process.communicate(streamIn.read().encode('utf-8')))]
    out   = out.decode('utf-8').replace('\x08','')
    error = error.decode('utf-8').replace('\x08','')
    os.chdir(initialPath)
    if process.returncode != 0:
        raise RuntimeError('{} failed with returncode {}'.format(cmd,process.returncode))
    return out,error


class extendableOption(Option):
    """
    Used for definition of new option parser action 'extend', which enables to take multiple option arguments.

    Adopted from online tutorial http://docs.python.org/library/optparse.html
    DEPRECATED
    """

    ACTIONS = Option.ACTIONS + ("extend",)
    STORE_ACTIONS = Option.STORE_ACTIONS + ("extend",)
    TYPED_ACTIONS = Option.TYPED_ACTIONS + ("extend",)
    ALWAYS_TYPED_ACTIONS = Option.ALWAYS_TYPED_ACTIONS + ("extend",)

    def take_action(self, action, dest, opt, value, values, parser):
        if action == "extend":
            lvalue = value.split(",")
            values.ensure_value(dest, []).extend(lvalue)
        else:
            Option.take_action(self, action, dest, opt, value, values, parser)


class _ProgressBar:
    """
    Report progress of an interation as a status bar.

    Works for 0-based loops, ETA is estimated by linear extrapolation.
    """

    def __init__(self,total,prefix,bar_length):
        """
        Inititalize a progress bar to current time as basis for ETA estimation.

        Parameters
        ----------
        total : int
            Total # of iterations.
        prefix : str
            Prefix string.
        bar_length : int
            Character length of bar.

        """
        self.total = total
        self.prefix = prefix
        self.bar_length = bar_length
        self.start_time = datetime.datetime.now()
        self.last_fraction = 0.0

        sys.stderr.write('{} {}   0% ETA n/a'.format(self.prefix, '░'*self.bar_length))
        sys.stderr.flush()

    def update(self,iteration):

        fraction = (iteration+1) / self.total

        if int(self.bar_length * fraction) > int(self.bar_length *  self.last_fraction):
            delta_time = datetime.datetime.now() - self.start_time
            remaining_time = (self.total - (iteration+1)) * delta_time / (iteration+1)
            remaining_time -= datetime.timedelta(microseconds=remaining_time.microseconds)           # remove μs

            filled_length = int(self.bar_length * fraction)
            bar = '█' * filled_length + '░' * (self.bar_length - filled_length)
            sys.stderr.write('\r{} {} {:>4.0%} ETA {}'.format(self.prefix, bar, fraction, remaining_time))
            sys.stderr.flush()

        self.last_fraction = fraction

        if iteration == self.total - 1:
            sys.stderr.write('\n')
            sys.stderr.flush()

def show_progress(iterable,N_iter=None,prefix='',bar_length=50):
    """
    Decorate a loop with a status bar.

    Use similar like enumerate.

    Parameters
    ----------
    iterable : iterable/function with yield statement
        Iterable (or function with yield statement) to be decorated.
    N_iter : int
        Total # of iterations. Needed if number of iterations can not be obtained as len(iterable).
    prefix : str, optional.
        Prefix string.
    bar_length : int, optional
        Character length of bar. Defaults to 50.

    """
    status = _ProgressBar(N_iter if N_iter else len(iterable),prefix,bar_length)

    for i,item in enumerate(iterable):
        yield item
        status.update(i)


def scale_to_coprime(v):
    """Scale vector to co-prime (relatively prime) integers."""
    MAX_DENOMINATOR = 1000

    def get_square_denominator(x):
        """Denominator of the square of a number."""
        return fractions.Fraction(x ** 2).limit_denominator(MAX_DENOMINATOR).denominator

    def lcm(a, b):
        """Least common multiple."""
        return a * b // np.gcd(a, b)

    denominators = [int(get_square_denominator(i)) for i in v]
    s = reduce(lcm, denominators) ** 0.5
    m = (np.array(v)*s).astype(np.int)
    return m//reduce(np.gcd,m)


class return_message():
    """Object with formatted return message."""

    def __init__(self,message):
        """
        Sets return message.

        Parameters
        ----------
        message : str or list of str
            message for output to screen

        """
        self.message = message

    def __repr__(self):
        """Return message suitable for interactive shells."""
        return srepr(self.message)

