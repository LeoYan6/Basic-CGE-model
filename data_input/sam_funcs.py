# -*- coding: utf-8 -*-
# title: sam processing functions for BA-CGE series
"""
This file contains sam table processes functions

Created on Tue Jun 11 14:50:59 2024
@author: Leo Yan
"""

import pandas as pd
import numpy as np

#%% Function to add new accounts
def newacc(sam:pd.DataFrame, new_acc: str, ins_acc: str):
    sam = row_newacc(sam, new_acc, ins_acc)
    sam = col_newacc(sam, new_acc, ins_acc)
    
    return sam

# Function to add new accounts in row dimension
def row_newacc(sam:pd.DataFrame, new_payee_acc: str, ins_payee_acc: str):
    ins_loc = int(np.where(sam.index.values == ins_payee_acc)[0][0])
    sam = sam.T
    sam.insert(ins_loc,new_payee_acc,value=0)
    sam = sam.T
    
    return sam

# Function to add new accounts in column dimension
def col_newacc(sam:pd.DataFrame, new_payer_acc: str, ins_payer_acc: str):
    ins_loc = int(np.where(sam.columns.values == ins_payer_acc)[0][0])
    sam.insert(ins_loc,new_payer_acc,value=0)
    
    return sam

#%% Function to combine multiple accounts
def combine(sam:pd.DataFrame, new_acc:str, old_accs:list):
    # row combination
    sam = row_combine(sam, new_acc, old_accs)
    # column combination
    sam = col_combine(sam, new_acc, old_accs)
    
    return sam

# Function to combine multiple accounts in row dimension
def row_combine(sam:pd.DataFrame, new_payee_acc:str, old_payee_accs:list):
    if new_payee_acc in old_payee_accs: # if the name of new account already exists, add a suffix
        sam = row_newacc(sam, new_payee_acc+'_new', old_payee_accs[0])
        sam.loc[new_payee_acc+'_new'] = sam.loc[old_payee_accs].sum(axis=0)
        sam = sam.drop(labels=old_payee_accs, axis=0)
        sam = sam.rename(index={new_payee_acc+'_new':new_payee_acc}) # drop the suffix
    else:
        sam = row_newacc(sam, new_payee_acc, old_payee_accs[0])
        sam.loc[new_payee_acc] = sam.loc[old_payee_accs].sum(axis=0)
        sam = sam.drop(labels=old_payee_accs, axis=0)
    
    return sam

# Function to combine multiple accounts in column dimension
def col_combine(sam:pd.DataFrame, new_payer_acc:str, old_payer_accs:list):
    if new_payer_acc in old_payer_accs: # if the name of new account already exists, add a suffix
        sam = col_newacc(sam, new_payer_acc+'_new', old_payer_accs[0])
        sam[new_payer_acc+'_new'] = sam[old_payer_accs].sum(axis=1)
        sam = sam.drop(labels=old_payer_accs, axis=1)
        sam = sam.rename(columns={new_payer_acc+'_new':new_payer_acc}) # drop the suffix
    else:
        sam = col_newacc(sam, new_payer_acc, old_payer_accs[0])
        sam[new_payer_acc] = sam[old_payer_accs].sum(axis=1)
        sam = sam.drop(labels=old_payer_accs, axis=1)
    
    return sam

#%% Function to re-route payments relationships
def reroute(sam:pd.DataFrame, payer_acc:str, payee_acc:str, inter_acc:str, trans_value=None):
    if trans_value == None:
        sam.loc[inter_acc,payer_acc] += sam.loc[payee_acc,payer_acc]
        sam.loc[payee_acc,inter_acc] += sam.loc[payee_acc,payer_acc]
        sam.loc[payee_acc,payer_acc] -= sam.loc[payee_acc,payer_acc]
    else:
        sam.loc[inter_acc,payer_acc] += trans_value
        sam.loc[payee_acc,inter_acc] += trans_value
        sam.loc[payee_acc,payer_acc] -= trans_value
    
    return sam

#%% Function to reset the starting point of payments relationships
def reinit(sam:pd.DataFrame, old_payer_acc:str, new_payer_acc:str, payee_acc:str, trans_value=None):
    if trans_value == None:
        sam = reroute(sam, new_payer_acc, old_payer_acc, payee_acc, trans_value=sam.loc[payee_acc,old_payer_acc])
        sam.loc[old_payer_acc,payee_acc] -= sam.loc[payee_acc,old_payer_acc]
        sam.loc[payee_acc,old_payer_acc] -= sam.loc[payee_acc,old_payer_acc]
    else:
        sam = reroute(sam, new_payer_acc, old_payer_acc, payee_acc, trans_value=trans_value)
        sam.loc[old_payer_acc,payee_acc] -= trans_value
        sam.loc[payee_acc,old_payer_acc] -= trans_value
    
    return sam

#%% Function to reset the ending point of payments relationships
def reterm(sam:pd.DataFrame, payer_acc:str, old_payee_acc:str, new_payee_acc:str, trans_value=None):
    if trans_value == None:
        sam = reroute(sam, old_payee_acc, new_payee_acc, payer_acc, trans_value=sam.loc[old_payee_acc,payer_acc])
        sam.loc[payer_acc,old_payee_acc] -= sam.loc[old_payee_acc,payer_acc]
        sam.loc[old_payee_acc,payer_acc] -= sam.loc[old_payee_acc,payer_acc]
    else:
        sam = reroute(sam, old_payee_acc, new_payee_acc, payer_acc, trans_value=trans_value)
        sam.loc[payer_acc,old_payee_acc] -= trans_value
        sam.loc[old_payee_acc,payer_acc] -= trans_value
        
    return sam

#%% Function to split a single account into multiple accounts
def row_split(sam:pd.DataFrame, payer_acc:str, old_payee_acc:str, new_payee_accs:list, info=None):
    allo_value = {}
    if info.any() == True: # if split information is provided, split based on external information
        for acc in new_payee_accs:
            allo_value[acc] = info[acc]/info.sum()*sam.loc[old_payee_acc,payer_acc]
    else: # if no external information, split averagely by default
        for acc in new_payee_accs:
            allo_value[acc] = 1/len(new_payee_accs)*sam.loc[old_payee_acc,payer_acc]
    for acc in new_payee_accs:
        sam = reterm(sam, payer_acc, old_payee_acc, acc, trans_value=allo_value[acc])
        
    return sam

def col_split(sam:pd.DataFrame, old_payer_acc:str, new_payer_accs:list, payee_acc:str, info=None):
    allo_value = {}
    if info.any() == True: # if split information is provided, split based on external information
        for acc in new_payer_accs:
            allo_value[acc] = info[acc]/info.sum()*sam.loc[payee_acc,old_payer_acc]
    else: # if no external information, split averagely by default
        for acc in new_payer_accs:
            allo_value[acc] = 1/len(new_payer_accs)*sam.loc[payee_acc,old_payer_acc] 
    for acc in new_payer_accs:
        sam = reinit(sam, old_payer_acc, acc, payee_acc, trans_value=allo_value[acc])
    
    return sam

#%% Function to remove intra-account payments and 0 values
def diag_zero(sam:pd.DataFrame):
    for acc in sam.index.values[:-1]:
        sam.loc[acc,acc] = 0
        
    return sam

#%% Function to re-calculate row- and column-sums
def resum(sam:pd.DataFrame):
    sam.iloc[-1,:-1] = sam.iloc[:-1,:-1].sum(axis=0)
    sam.iloc[:-1,-1] = sam.iloc[:-1,:-1].sum(axis=1)
    
    return sam








