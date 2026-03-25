# -*- coding: utf-8 -*-
"""
This file is used to conduct SAM table aggregations, extensions or other 
adjustments.

Created on Tue Jun 18 09:28:25 2024
@author: Leo Yan
"""

import pandas as pd
import numpy as np
from sam_funcs import (combine, newacc, reroute, reinit, reterm, diag_zero, resum)

#%% sam_1.0
# Read-in raw SAM data
sam = pd.read_csv('../io_to_sam/2020sam_china_macro.csv', index_col=0)
sam = sam.replace(np.NaN,0)
# Combine the unused accounts into a major account
sam = combine(sam, new_acc='act', old_accs=['com','act'])
sam = combine(sam, new_acc='hhd', old_accs=['hhd','ptx','mtx','gov','inv','row'])
# Adjust some payments routes
sam = reroute(sam, payer_acc='act', payee_acc='hhd', inter_acc='lab')
# Remove intra-account values and 0 values
sam = diag_zero(sam)
# Re-calculate row- and column-sums to balance the sheet
sam = resum(sam)
# Export processed SAM table
sam = sam.replace(0,np.NaN)
sam.to_csv('sam_1.0.csv')

#%% sam_1.1
# Read-in raw SAM data
sam = pd.read_csv('../io_to_sam/2020sam_china_macro.csv', index_col=0)
sam = sam.replace(np.NaN,0)
# Combine the unused accounts into a major account
sam = combine(sam, new_acc='act', old_accs=['com','act'])
sam = combine(sam, new_acc='hhd', old_accs=['hhd','ptx','mtx','gov','row'])
# Adjust some payments routes
sam = reroute(sam, payer_acc='act', payee_acc='hhd', inter_acc='lab')
# Remove intra-account values and 0 values
sam = diag_zero(sam)
# Re-calculate row- and column-sums to balance the sheet
sam = resum(sam)
# Export processed SAM table
sam = sam.replace(0,np.NaN)
sam.to_csv('sam_1.1.csv')

#%% sam_1.2
# Read-in raw SAM data
sam = pd.read_csv('../io_to_sam/2020sam_china_macro.csv', index_col=0)
sam = sam.replace(np.NaN,0)
# Combine the unused accounts into a major account
sam = combine(sam, new_acc='act', old_accs=['com','act'])
sam = combine(sam, new_acc='hhd', old_accs=['hhd','mtx','row'])
# Adjust some payments routes
sam = reroute(sam, payer_acc='act', payee_acc='hhd', inter_acc='lab')
#sam = reinit(sam, old_payer_acc='gov', new_payer_acc='hhd', payee_acc='inv')
# Remove intra-account values and 0 values
sam = diag_zero(sam)
# Re-calculate row- and column-sums to balance the sheet
sam = resum(sam)
# Export processed SAM table
sam = sam.replace(0,np.NaN)
sam.to_csv('sam_1.2.csv')

#%% sam_2.0
# Read-in raw SAM data
sam = pd.read_csv('../io_to_sam/2020sam_china_macro.csv', index_col=0)
sam = sam.replace(np.NaN,0)
# Adjust some payments routes
sam = reterm(sam, payer_acc='act', old_payee_acc='com', new_payee_acc='act')
#sam = reinit(sam, old_payer_acc='gov', new_payer_acc='hhd', payee_acc='inv')
# Remove intra-account values and 0 values
sam = diag_zero(sam)
# Re-calculate row- and column-sums to balance the sheet
sam = resum(sam)
# Export processed SAM table
sam = sam.replace(0,np.NaN)
sam.to_csv('sam_2.0.csv')

#%% sam_2.0a
# Read-in sam_2.0 data
sam = pd.read_csv('sam_2.0.csv', index_col=0)
sam = sam.replace(np.NaN,0)
# Add a new account named 'ENT'
sam = newacc(sam, new_acc='ent', ins_acc='hhd')
# Adjust some payments routes
sam = reterm(sam, payer_acc='act', old_payee_acc='cap', new_payee_acc='hhd', trans_value=486)
sam = reroute(sam, payer_acc='act', payee_acc='hhd', inter_acc='ent')
# Remove intra-account values and 0 values
sam = diag_zero(sam)
# Re-calculate row- and column-sums to balance the sheet
sam = resum(sam)
# Export processed SAM table
sam = sam.replace(0,np.NaN)
sam.to_csv('sam_2.0a.csv')





