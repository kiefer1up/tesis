import pandas as pd
import matplotlib.pyplot as plt

def hola():
    print("hola mundo")

def anac_df():
    anac_df = pd.read_csv('data/df_anac.csv', index_col=0, parse_dates=True)
    anac_df_vnt = anac_df['nvnt']
    anac_df_vnt.plot(title="Ventas mensuales a publico del mercado de livianos y medianos",ylabel="ventas de vehiculos")
    plt.xticks(rotation=90)
    
def pareto()
    