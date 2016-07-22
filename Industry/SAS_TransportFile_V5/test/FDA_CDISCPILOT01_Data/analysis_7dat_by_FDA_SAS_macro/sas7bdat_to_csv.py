#!/usr/bin/env python
from __future__ import division, absolute_import, print_function,\
    unicode_literals
import os
import sys
import logging
import optparse

import six

from sas7bdat import SAS7BDAT

xrange = six.moves.range


def main(options, args):
    if options.debug:
        log_level = logging.DEBUG
    else:
        log_level = logging.INFO
    in_files = [args[0]]
    if len(args) == 1:
        out_files = ['%s.csv' % os.path.splitext(args[0])[0]]
    elif len(args) == 2 and (args[1] == '-' or
                             args[1].lower().endswith('.csv')):
        out_files = [args[1]]
    else:
        assert all(x.lower().endswith('.sas7bdat') for x in args)
        in_files = args
        out_files = ['%s.csv' % os.path.splitext(x)[0] for x in in_files]
    assert len(in_files) == len(out_files)
    opts = {}
    if options.no_align_correction:
        opts['align_correction'] = False
    successes = 0
    errors = []
    for i in xrange(len(in_files)):
        with SAS7BDAT(in_files[i], log_level=log_level, **opts) as f:
            if options.header:
                f.logger.info(str(f.header))
                continue
            try:
                success = f.convert_file(
                    out_files[i],
                    delimiter=options.delimiter,
                    step_size=options.progress_step
                )
                if success:
                    successes += 1
                else:
                    errors.append(in_files[i])
            except:
                errors.append(in_files[i])
    print()
    if successes:
        print('Successfully converted %s of %s file%s' %
              (successes, len(in_files),
               '' if len(in_files) == 1 else 's'))
    if errors:
        print('Failed to convert %s of %s file%s:' %
              (len(errors), len(in_files),
               '' if len(in_files) == 1 else 's'))
        for error in errors:
            print('\t%s' % error)


if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.set_usage("""%prog [options] <infile> [outfile]

  Convert sas7bdat files to csv. <infile> is the path to a sas7bdat file and
  [outfile] is the optional path to the output csv file. If omitted, [outfile]
  defaults to the name of the input file with a csv extension. <infile> can
  also be a glob expression in which case the [outfile] argument is ignored.

  Use --help for more details""")
    parser.add_option('-d', '--debug', action='store_true', default=False,
                      help="Turn on debug logging")
    parser.add_option('--header', action='store_true', default=False,
                      help="Print out header information and exit.")
    parser.add_option('--delimiter', action='store', default=',',
                      help="Set the delimiter in the output csv file. "
                           "Defaults to '%default'.")
    parser.add_option('--progress-step', action='store', default=100000,
                      metavar='N', type='int',
                      help="Set the progress step size. Progress will be "
                           "displayed every N steps. Defaults to %default.")
    parser.add_option('--no-align-correction', action='store_true',
                      default=False,
                      help="Certain files raise an exception when processing "
                           "data with alignment correction turned on. Use "
                           "this flag to disable alignment correction.")
    options, args = parser.parse_args()
    if len(args) < 1:
        parser.print_help()
        sys.exit(1)
    main(options, args)
