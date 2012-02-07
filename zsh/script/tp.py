#!/usr/bin/env python

import os
import re

a = os.popen('synclient -l').read()
b = re.compile('TouchpadOff.+\d')
c = b.findall(a)[-1][-1]
c = '0' if c == '1' else '1'
os.popen('synclient TouchpadOff=' + c)

