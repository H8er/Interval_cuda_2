from mpl_toolkits import mplot3d
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d


import matplotlib.pyplot as plt
import sys
import re

# z0 = 0
# z1 = 0.002
fig = plt.figure()
ax = fig.gca(projection='3d')

# pat = re.compile('\[(\-|\d|\.)*\:(\-|\d|\.)*\]')
pat = re.compile('\[(?:\d|-|\.)*\:(?:\d|-|\.)*\]')
k = 0
for line in sys.stdin:
        if re.match("^#.*", line):
            print(line)
            continue
        if re.match("^_+", line):
            if k == 0:
                k = 1
            else:
                k = 0
            continue
        arr =pat.findall(line)
        # ends = re.split('\[|\:|\]', I)
        # I.strip('[')
        I = arr[0]
        l = len(I)
        ends = re.split('\:', I[1:l-1])
        # print(ends)
        a1 = float(ends[0])
        b1 = float(ends[1])

        I = arr[1]
        l = len(I)
        ends = re.split('\:', I[1:l-1])
        # print(ends)
        a2 = float(ends[0])
        b2 = float(ends[1])

        I = arr[2]
        l = len(I)
        ends = re.split('\:', I[1:l-1])
        # print(ends)
        z0 = float(ends[0])
        z1 = float(ends[1])

        x = [a1,b1,b1,a1,a1,a1,b1,b1,a1,a1,a1,a1,b1,b1,b1,b1]
        y = [a2,a2,b2,b2,a2,a2,a2,b2,b2,a2,b2,b2,b2,b2,a2,a2]
        z = [z0,z0,z0,z0,z0,z1,z1,z1,z1,z1,z1,z0,z0,z1,z1,z0]
        ax.plot(x, y, z, color = 'green')
#circle = plt.Circle((0, 0), radius=3, fc='y', fill = False)
#plt.gca().add_patch(circle)
#
# x0 = 2.78400
# x1 = 2.78600
# y0 = -0.80200
# y1 = -0.80000
# z0 = 0
# z1 = 1
#
#
# x = [x0,x1,x1,x0,x0,x0,x1,x1,x0,x0,x0,x0,x1,x1,x1,x1]
# y = [y0,y0,y1,y1,y0,y0,y0,y1,y1,y0,y1,y1,y1,y1,y0,y0]
# z = [z0,z0,z0,z0,z0,z1,z1,z1,z1,z1,z1,z0,z0,z1,z1,z0]
# ax.plot(x, y, z, color = 'black')

plt.show()
