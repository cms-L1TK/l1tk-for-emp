import conifer
import sys
import json
import pickle
#from sklearn.ensemble import GradientBoostingClassifier
import xgboost as xgb
from scipy.special import expit

print(xgb.__version__)


with open('../models/clf_GBDT_emulation_newKF.pkl', 'rb') as file:
    bdt_model = pickle.load(file).get_booster() 
print("Model File Loaded")


cfg = conifer.backends.vivadohls.auto_config()
cfg['Precision'] = 'ap_fixed<10,5>'   #This parameter controls the internal quantisation of the BDT
cfg['OutputDir'] = "dir/"
cfg["XilinxPart"] = "xcvu7p-flvb2104-2-e"
cfg["ClockPeriod"] = "2.7"

try:
   hdl_model = conifer.model(bdt_model, conifer.converters.xgboost, conifer.backends.vhdl, cfg) #Create Conifer model
except:
    try:
         hdl_model = conifer.model(bdt_model, conifer.converters.sklearn, conifer.backends.vhdl, cfg) 
    except:
        print("Invalid BDT savefile, either xgboost or sklearn is currently supported") 
  
hdl_model.compile()
print("Model Compiled")