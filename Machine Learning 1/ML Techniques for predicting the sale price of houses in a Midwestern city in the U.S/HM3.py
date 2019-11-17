# -*- coding: utf-8 -*-
"""
Created on Sun Nov 10 22:54:57 2019

@author: CX
"""
#%%
import numpy as np 
import pandas as pd 
import random as rn 
import tensorflow as tf 
np.random.seed(1234) 
rn.seed(1234) 
session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1) 
 
from keras import backend as K 
 
tf.set_random_seed(1234) 
 
sess = tf.Session(graph=tf.get_default_graph(),config=session_conf) 
K.set_session(sess)

#Import data
Val = pd.read_csv("GradedHW1-Validation-Data.csv",sep=',',header=0,quotechar='"')
Test = pd.read_csv("GradedHW1-Test-Data.csv",sep=',',header=0,quotechar='"')
Train = pd.read_csv("GradedHW1-Train-Data.csv",sep=',',header=0,quotechar='"')

Val['BuildAge'] = 2010 - Val['Year.Built']
Test['BuildAge'] = 2010 - Test['Year.Built']
Train['BuildAge'] = 2010 - Train['Year.Built']

Y = np.array(Train['SalePrice'])
X = np.array(Train.loc[:,['Gr.Liv.Area','BuildAge']])

Train['SalePrice'].isnull().sum()
Train['BuildAge'].isnull().sum()
Train['Gr.Liv.Area'].isnull().sum()

Xrsc = (X - X.min(axis=0))/X.ptp(axis=0)
Xrsc.shape
Xrsc.min(axis=0)
Xrsc.max(axis=0)

Yrsc = (Y-Y.min())/Y.ptp()

from keras.models import Sequential
from keras.layers import Dense, Activation

# 4. Using only the two x-variables indicated above, fit the least squares linear regression using Keras. 
#Make a 3D plots of the SalePrice against the two variables and add the regression plane. 
#This is the exactly the same process I showed in class using the Auto dataset. 
#Once you have fit the regression plane, find a good view that shows the data and the fit using the 3D plot. 
#Save the view to turn in as indicated below. Note: Selecting the window and then using Cntl-Alt-PrtScr copies the window into the clipboard on Windows as a picture. 
#You can then paste the picture into Word. Remember, you will need to label these plots, so keep track of what they are.

HouseNN = Sequential()
HouseNN.add(Dense(units=1,input_shape=(Xrsc.shape[1],),activation="linear",use_bias=True))
HouseNN.compile(loss='mean_squared_error', optimizer='rmsprop',metrics=['mean_squared_error'])


#Fit NN Model

from keras.callbacks import EarlyStopping

#FitHist = AutoNN.fit(Xrsc,Yrsc,epochs=100000,batch_size=len(Y),verbose=0, \
#                callbacks=[EarlyStopping(monitor='mean_squared_error',min_delta=0.00000000,patience=5)])

FitHist = HouseNN.fit(Xrsc,Yrsc,epochs=10000,batch_size=len(Y),verbose=0)
print("Number of Epochs = "+str(len(FitHist.history['mean_squared_error'])))
FitHist.history['mean_squared_error'][-1]
FitHist.history['mean_squared_error'][-10:-1]

# Make Predictions

YHat = HouseNN.predict(Xrsc,batch_size=Xrsc.shape[0])*(Y.max()-Y.min())+Y.min()
YHat

GridN = 20
x1g = np.arange(0,GridN)/(GridN-1)*(max(X[:,0])-min(X[:,0]))+min(X[:,0])
x1g = np.tile(x1g,GridN)

x2g = np.arange(0,GridN)/(GridN-1)*(max(X[:,1])-min(X[:,1]))+min(X[:,1])
x2g = np.repeat(x2g,GridN)

Xgrid = np.concatenate((np.reshape(x1g,(len(x1g),1)),np.reshape(x2g,(len(x2g),1))),axis=1)

Ygrid = HouseNN.predict((Xgrid-Xgrid.min(axis=0))/X.ptp(axis=0),batch_size=Xgrid.shape[0])*Y.ptp()+Y.min()


# Write out prediction

Train['YHat'] = YHat
list(Train)

Train.to_csv('TrainOut.csv',sep=',',na_rep="NA",header=True,index=False)

Out = pd.DataFrame(np.concatenate((Xgrid,Ygrid),axis=1),columns=["x1g","x2g","Ygrid"],copy=True)
Out.to_csv('TrainGridOut.csv',sep=',',na_rep="NA",header=True,index=False)


#%%
#Next, fit a neural net model with a layer of 4 ReLU nodes (units). 
#Recall that this will requires the first layer of 4 ReLU nodes to be followed by a layer with one node. 
#Please use a linear activation function for the final node. Make a 3D plot of the fitted surface for this model. 
#Once again, find a good view in the 3D plot that shows the data and the fitted surface and save the plot.

#
import numpy as np 
import pandas as pd 
import random as rn 
import tensorflow as tf 
np.random.seed(1234) 
rn.seed(1234) 
session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1) 
 
from keras import backend as K 
 
tf.set_random_seed(1234) 
 
sess = tf.Session(graph=tf.get_default_graph(),config=session_conf) 
K.set_session(sess)

#
HouseNN = Sequential()
HouseNN.add(Dense(units=4,input_shape=(Xrsc.shape[1],),activation="relu",use_bias=True))
HouseNN.add(Dense(units=1,activation="linear",use_bias=True))
HouseNN.compile(loss='mean_squared_error', optimizer='rmsprop',metrics=['mean_squared_error'])

# Fit NN Model

from keras.callbacks import EarlyStopping

#FitHist = AutoNN.fit(Xrsc,Yrsc,epochs=100000,batch_size=len(Y),verbose=0, \
#                callbacks=[EarlyStopping(monitor='mean_squared_error',min_delta=0.00000000,patience=5)])

FitHist = HouseNN.fit(Xrsc,Yrsc,epochs=10000,batch_size=len(Y),verbose=0)
print("Number of Epochs = "+str(len(FitHist.history['mean_squared_error'])))
FitHist.history['mean_squared_error'][-1]
FitHist.history['mean_squared_error'][-10:-1]

# Make Predictions

YHat = HouseNN.predict(Xrsc,batch_size=Xrsc.shape[0])*(Y.max()-Y.min())+Y.min()
YHat

GridN = 20
x1g = np.arange(0,GridN)/(GridN-1)*(max(X[:,0])-min(X[:,0]))+min(X[:,0])
x1g = np.tile(x1g,GridN)

x2g = np.arange(0,GridN)/(GridN-1)*(max(X[:,1])-min(X[:,1]))+min(X[:,1])
x2g = np.repeat(x2g,GridN)

Xgrid = np.concatenate((np.reshape(x1g,(len(x1g),1)),np.reshape(x2g,(len(x2g),1))),axis=1)

Ygrid = HouseNN.predict((Xgrid-Xgrid.min(axis=0))/X.ptp(axis=0),batch_size=Xgrid.shape[0])*Y.ptp()+Y.min()


# Write out prediction

Train['YHat'] = YHat
list(Train)

Train.to_csv('TrainOut2.csv',sep=',',na_rep="NA",header=True,index=False)

Out = pd.DataFrame(np.concatenate((Xgrid,Ygrid),axis=1),columns=["x1g","x2g","Ygrid"],copy=True)
Out.to_csv('TrainGridOut2.csv',sep=',',na_rep="NA",header=True,index=False)

#%%
import numpy as np 
import pandas as pd 
import random as rn 
import tensorflow as tf 
np.random.seed(1234) 
rn.seed(1234) 
session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1) 
 
from keras import backend as K 
 
tf.set_random_seed(1234) 
 
sess = tf.Session(graph=tf.get_default_graph(),config=session_conf) 
K.set_session(sess)

#
#Repeat the previous question (Q4) using a layer of 10 ReLU units to see if making the model “wider” changes the fit significantly
HouseNN = Sequential()
HouseNN.add(Dense(units=10,input_shape=(Xrsc.shape[1],),activation="relu",use_bias=True))
HouseNN.add(Dense(units=1,activation="linear",use_bias=True))
HouseNN.compile(loss='mean_squared_error', optimizer='rmsprop',metrics=['mean_squared_error'])

#Fit NN Model

from keras.callbacks import EarlyStopping


FitHist = HouseNN.fit(Xrsc,Yrsc,epochs=10000,batch_size=len(Y),verbose=0)
print("Number of Epochs = "+str(len(FitHist.history['mean_squared_error'])))
FitHist.history['mean_squared_error'][-1]
FitHist.history['mean_squared_error'][-10:-1]

# Make Predictions

YHat = HouseNN.predict(Xrsc,batch_size=Xrsc.shape[0])*(Y.max()-Y.min())+Y.min()
YHat

GridN = 20
x1g = np.arange(0,GridN)/(GridN-1)*(max(X[:,0])-min(X[:,0]))+min(X[:,0])
x1g = np.tile(x1g,GridN)

x2g = np.arange(0,GridN)/(GridN-1)*(max(X[:,1])-min(X[:,1]))+min(X[:,1])
x2g = np.repeat(x2g,GridN)

Xgrid = np.concatenate((np.reshape(x1g,(len(x1g),1)),np.reshape(x2g,(len(x2g),1))),axis=1)

Ygrid = HouseNN.predict((Xgrid-Xgrid.min(axis=0))/X.ptp(axis=0),batch_size=Xgrid.shape[0])*Y.ptp()+Y.min()


# Write out prediction

Train['YHat'] = YHat
list(Train)

Train.to_csv('TrainOut3.csv',sep=',',na_rep="NA",header=True,index=False)

Out = pd.DataFrame(np.concatenate((Xgrid,Ygrid),axis=1),columns=["x1g","x2g","Ygrid"],copy=True)
Out.to_csv('TrainGridOut3.csv',sep=',',na_rep="NA",header=True,index=False)


#%%
import numpy as np 
import pandas as pd 
import random as rn 
import tensorflow as tf 
np.random.seed(1234) 
rn.seed(1234) 
session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1) 
 
from keras import backend as K 
 
tf.set_random_seed(1234) 
 
sess = tf.Session(graph=tf.get_default_graph(),config=session_conf) 
K.set_session(sess)

#
#Next let’s try a neural net model that is “deeper.” Try 3 layers of 4 ReLU units.
HouseNN = Sequential()
HouseNN.add(Dense(units=4,input_shape=(Xrsc.shape[1],),activation="relu",use_bias=True))
HouseNN.add(Dense(units=4,activation="relu",use_bias=True))
HouseNN.add(Dense(units=4,activation="relu",use_bias=True))
HouseNN.add(Dense(units=1,activation="linear",use_bias=True))
HouseNN.compile(loss='mean_squared_error', optimizer='rmsprop',metrics=['mean_squared_error'])

#Fit NN Model

from keras.callbacks import EarlyStopping


FitHist = HouseNN.fit(Xrsc,Yrsc,epochs=10000,batch_size=len(Y),verbose=0)
print("Number of Epochs = "+str(len(FitHist.history['mean_squared_error'])))
FitHist.history['mean_squared_error'][-1]
FitHist.history['mean_squared_error'][-10:-1]

# Make Predictions

YHat = HouseNN.predict(Xrsc,batch_size=Xrsc.shape[0])*(Y.max()-Y.min())+Y.min()
YHat

GridN = 20
x1g = np.arange(0,GridN)/(GridN-1)*(max(X[:,0])-min(X[:,0]))+min(X[:,0])
x1g = np.tile(x1g,GridN)

x2g = np.arange(0,GridN)/(GridN-1)*(max(X[:,1])-min(X[:,1]))+min(X[:,1])
x2g = np.repeat(x2g,GridN)

Xgrid = np.concatenate((np.reshape(x1g,(len(x1g),1)),np.reshape(x2g,(len(x2g),1))),axis=1)

Ygrid = HouseNN.predict((Xgrid-Xgrid.min(axis=0))/X.ptp(axis=0),batch_size=Xgrid.shape[0])*Y.ptp()+Y.min()


# Write out prediction

Train['YHat'] = YHat
list(Train)

Train.to_csv('TrainOut4.csv',sep=',',na_rep="NA",header=True,index=False)

Out = pd.DataFrame(np.concatenate((Xgrid,Ygrid),axis=1),columns=["x1g","x2g","Ygrid"],copy=True)
Out.to_csv('TrainGridOut4.csv',sep=',',na_rep="NA",header=True,index=False)

#%%
import numpy as np 
import pandas as pd 
import random as rn 
import tensorflow as tf 
np.random.seed(1234) 
rn.seed(1234) 
session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1) 
 
from keras import backend as K 
 
tf.set_random_seed(1234) 
 
sess = tf.Session(graph=tf.get_default_graph(),config=session_conf) 
K.set_session(sess)

#
#Next let’s try a neural net model that is “deeper.” Try 3 layers of 4 ReLU units.
HouseNN = Sequential()
HouseNN.add(Dense(units=10,input_shape=(Xrsc.shape[1],),activation="relu",use_bias=True))
HouseNN.add(Dense(units=10,activation="relu",use_bias=True))
HouseNN.add(Dense(units=10,activation="relu",use_bias=True))
HouseNN.add(Dense(units=10,activation="relu",use_bias=True))
HouseNN.add(Dense(units=1,activation="linear",use_bias=True))
HouseNN.compile(loss='mean_squared_error', optimizer='rmsprop',metrics=['mean_squared_error'])

#Fit NN Model

from keras.callbacks import EarlyStopping


FitHist = HouseNN.fit(Xrsc,Yrsc,epochs=10000,batch_size=len(Y),verbose=0)
print("Number of Epochs = "+str(len(FitHist.history['mean_squared_error'])))
FitHist.history['mean_squared_error'][-1]
FitHist.history['mean_squared_error'][-10:-1]

# Make Predictions

YHat = HouseNN.predict(Xrsc,batch_size=Xrsc.shape[0])*(Y.max()-Y.min())+Y.min()
YHat

GridN = 20
x1g = np.arange(0,GridN)/(GridN-1)*(max(X[:,0])-min(X[:,0]))+min(X[:,0])
x1g = np.tile(x1g,GridN)

x2g = np.arange(0,GridN)/(GridN-1)*(max(X[:,1])-min(X[:,1]))+min(X[:,1])
x2g = np.repeat(x2g,GridN)

Xgrid = np.concatenate((np.reshape(x1g,(len(x1g),1)),np.reshape(x2g,(len(x2g),1))),axis=1)

Ygrid = HouseNN.predict((Xgrid-Xgrid.min(axis=0))/X.ptp(axis=0),batch_size=Xgrid.shape[0])*Y.ptp()+Y.min()


# Write out prediction

Train['YHat'] = YHat
list(Train)

Train.to_csv('TrainOut5.csv',sep=',',na_rep="NA",header=True,index=False)

Out = pd.DataFrame(np.concatenate((Xgrid,Ygrid),axis=1),columns=["x1g","x2g","Ygrid"],copy=True)
Out.to_csv('TrainGridOut5.csv',sep=',',na_rep="NA",header=True,index=False)
