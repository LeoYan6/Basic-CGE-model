# -*- coding: utf-8 -*-
"""
This file is used to convert SAM table from .csv to .gdx format. 

Created on Mon Dec 29 21:53:16 2025
@author: Leo Yan
"""

import numpy as np
import pandas as pd
from gams import transfer as gt

#%% Global settings
data_ver = '2.0'
m = gt.Container()

#%% read data from .csv files
df_sam = pd.read_csv('sam_'+data_ver+'.csv',index_col=0)

#%% SAM table accounts
acc = m.addSet('is',records=df_sam.index.values,description='SAM accounts')

#%% SAM table values
# wide to long form
df_sam.index.name = 'is'
df_sam = df_sam.reset_index()
df_sam = pd.melt(df_sam,id_vars='is',
                 var_name='js',value_name='value')
df_sam = df_sam.fillna(0)
sam = m.addParameter('sam',domain=['is','js'],records=df_sam,description='Social accounting matrix')

#%% Output
m.write('sam_'+data_ver+'.gdx')
