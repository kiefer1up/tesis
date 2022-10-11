import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import PercentFormatter

def hola():
    print("hola mundo")

def anac_df():
    anac_df = pd.read_csv('data/df_anac.csv', index_col=0, parse_dates=True)
    anac_df_vnt = anac_df['nvnt']
    anac_df_vnt.plot(title="Ventas mensuales a publico del mercado de livianos y medianos",ylabel="ventas de vehiculos")
    plt.xticks(rotation=90)
    
def pareto():
    prd_tp = pd.read_csv('data/prod_tp.csv', index_col=0)
    prd_tp_df= pd.DataFrame(prd_tp)

    vnt = pd.read_csv('data/vnt_tmp_.csv', index_col=0)
    vnt_df= pd.DataFrame(vnt)

    pareto_df=pd.merge(vnt_df,prd_tp_df,left_on='prd_tp',right_on='1')

    frec= pd.value_counts(pareto_df['Accesorios'])
#frec=frec.filter(like=-'hm', axis=0)
    frec_df= pd.DataFrame(frec)

    frec_df.columns = ["Frec_abs"]
    frec_df["Frec_rel_%"]=100*frec_df["Frec_abs"]/len(pareto_df)

    Frec_rel_val= frec_df["Frec_rel_%"].values
    acum=[]
    valor_acum= 0
    for i in Frec_rel_val:
        valor_acum = valor_acum + i
        acum.append(valor_acum)
    
    frec_df["Frec_rel_%_acum"]= acum
# plot
    fig = plt.figure()
    ax= fig.add_subplot(1,1,1)
    ax.set_title('Diagrama de Pareto')
    ax.bar(frec_df.index, frec_df["Frec_abs"], color="C0")

    ax2= ax.twinx()
    ax2.plot(frec_df.index,frec_df["Frec_rel_%_acum"],color="C1", marker= "D", ms=5)
    ax2.yaxis.set_major_formatter(PercentFormatter())

    ax.tick_params(axis="y", colors="C0")
    ax2.tick_params(axis="y", colors="C1")

    ax.set_xticklabels(frec_df.index,rotation=90)

    plt.show()