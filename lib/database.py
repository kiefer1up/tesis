import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from matplotlib.ticker import PercentFormatter

def licen():
    plt.ioff()
    df = pd.read_csv('data/licencia_conducir_2020_2017.csv',index_col=0, parse_dates=True)
    dfB = df[(df['clase'] == "B")]
    plt.plot(dfB.index,dfB.iloc[:,2] , label = "nueva")
    plt.plot(dfB.index,dfB.iloc[:,3] , label = "renovada")
    plt.title('Licencias de Clase B')
    plt.legend()
    plt.xticks(rotation=90)
    plt.savefig('fig/licen.png')
def petroleo():
    plt.ioff()
    df = pd.read_csv('data/a/petroleo_WIT.csv',index_col=0, parse_dates=True)
    df.plot(ylabel="WIT Petroleo")
    plt.xticks(rotation=90)
    plt.savefig('fig/WIT.png')

def dolar():
    plt.ioff()
    df = pd.read_csv('data/dolar2010_2022.csv',index_col=0 , parse_dates=True)
    df.index = pd.to_datetime(df.index)
    df.plot(ylabel="Dolar observado")
    plt.xticks(rotation=90)
    plt.savefig('fig/dolar2010_2022.png')

def anac_df():
    plt.ioff()
    anac_df = pd.read_csv('data/df_anac.csv', index_col=0, parse_dates=True)
    anac_df_vnt = anac_df['nvnt']
    anac_df_vnt.plot(ylabel="ventas de vehiculos")
    plt.xticks(rotation=90)
    plt.savefig('fig/anac.png')

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
    plt.ioff()
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
    
def abc():
    prd_tp = pd.read_csv('data/prod_tp.csv')
    prd_tp_df= pd.DataFrame(prd_tp)

    vnt = pd.read_csv('data/vnt_tmp_.csv')
    vnt_df= pd.DataFrame(vnt)

    pareto_df=pd.merge(vnt_df,prd_tp_df,left_on='prd_tp',right_on='1')

    o= pareto_df[['Accesorios','q','total']]
    frec= o.groupby(['Accesorios']).sum()
    frec_df=pd.DataFrame(frec)
    frec_df=frec_df.sort_values(by='total', ascending=False)
    frec_df.index.name= None
    frec_df.index.name= 'prd_tp'
    frec_df.reset_index(inplace=True)

    frec_df["Frec_abs"]= frec_df['total']
    frec_df["Frec_rel_%"]=100*frec_df["Frec_abs"]/frec_df['total'].sum()
    Frec_rel_val= frec_df["Frec_rel_%"].values
    acum=[]
    valor_acum= 0
    for i in Frec_rel_val:
        valor_acum = valor_acum + i
        acum.append(valor_acum)

    frec_df["Frec_rel_%_acum"]= acum
#frec_df["Frec_rel_%_acum"]=frec_df["Frec_rel_%_acum"].round(3)

    condition= [(frec_df["Frec_rel_%_acum"]<=80),(frec_df["Frec_rel_%_acum"]>90)]
    choice= ['a','c']
    frec_df['choise']= np.select(condition, choice, default= "b")

    result = frec_df.groupby('choise').agg({'Frec_rel_%_acum': ['max']})
#result.iloc[0,0]

    plt.ioff()
    fig = plt.figure()
    ax= fig.add_subplot(1,1,1)
    ax.set_title('Analisis ABC')
    ax.bar(frec_df.index, frec_df["Frec_abs"], color="C0")

    ax2= ax.twinx()
    ax2.plot(frec_df.index,frec_df["Frec_rel_%_acum"],color="C1", marker= "D", ms=5)
    ax2.yaxis.set_major_formatter(PercentFormatter())

    ax.tick_params(axis="y", colors="C0")
    ax2.tick_params(axis="y", colors="C1")


    ax.set_xticklabels(frec_df['Frec_rel_%_acum'].round(0),rotation=90)
    ax.axvline(x = 1)
    ax.axvline(x=10)

    plt.show()
