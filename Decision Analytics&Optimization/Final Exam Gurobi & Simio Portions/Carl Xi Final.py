# -*- coding: utf-8 -*-
"""
@author: carlxi
"""

#%%
# Model

from gurobipy import *
from math import sqrt
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

m = Model("Final")

x = m.addVars(2, name="x")

product = range(2)

#Objective Function
ObjFunc = 3*x[0]+2.5*x[1]
# Set objective
m.setObjective(ObjFunc, GRB.MAXIMIZE)	

#Constraints
m.addConstr(0.1*x[0] + 0.2*x[1] <= 5420, "C1")
m.addConstr(0.4*x[0] + 0.3*x[1] <= 14790, "C2")
m.addConstr(0.5*x[0] + 0.5*x[1] <= 19990, "C3")
m.addConstr(-0.3*x[0] + 0.7*x[1] >= 0, "C4")
m.addConstr(x[0] >= 0, "C5")
m.addConstr(x[1] >= 0, "C6")


# Optimize
m.optimize()

for v in m.getVars():
		print('%s %g' % (v.varName, v.x))
	
print('Obj: %g' % m.objVal)

print('Optimal obj func value: %g' % m.objVal)
	
print('X1(exterior) is denoted by x[0], and X2(interior) is denoted by x[1].')
  
for g in product:
    print('Product X%s, Quantity: %g, Reduce Cost: %g, Lower: %g, Upper: %g'
	         % (g+1,x[g].x, x[g].RC, x[g].SAObjLow, x[g].SAObjUp))
		
for c in m.getConstrs():
    if c.Pi != 0:
        print('Constraint %s, Shadow Price: %g, Lower: %g, Upper: %g' % 
				(c.constrName, c.Pi, c.SARHSLow, c.SARHSUp))
	
m.write("saveit.mps")


