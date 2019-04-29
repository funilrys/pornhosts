# This script will add "0.0.0.0" at the beginning of each line

import fileinput
import sys

for line in fileinput.input(['./new-list'], inplace=True):
    sys.stdout.write('0.0.0.0 {l}'.format(l=line))
