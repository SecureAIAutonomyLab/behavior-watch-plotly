import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import plotly.graph_objects as go
import plotly.express as px
import boto3
import pandas as pd
import numpy as np
import calendar
pd.options.mode.chained_assignment = None  # default='warn'

# read in secret key
file = open("aws.key", "r")
file.readline() # header
access_key_id = file.readline().replace("\n", "")
secret_access_key = file.readline().replace("\n", "")


"""
boto3 connestc to aws with params ...
"""
#Connect to AWS S3
s3 = boto3.client(
    's3',
    aws_access_key_id = access_key_id,
    aws_secret_access_key = secret_access_key,
    region_name = 'us-east-2'
)

#Get the list of User objects from AWS S3
data_frames = []
users = []
for key in s3.list_objects(Bucket='cloudvitalsbucket154408-ailadev')['Contents']:
    object_key = key['Key']
    if "dashboard_data/" not in str(object_key):
        continue

    start = object_key.find("dashboard_data/") + len("dashboard_data/")
    username = object_key[start:]
    if len(username) == 0:
        continue

    users.append(username)
    print(object_key)
    print(username)

    filename = username+'.csv'
    file_df = pd.DataFrame(list())
    file_df.to_csv(filename)
    s3.download_file('cloudvitalsbucket154408-ailadev', object_key, filename)
    df = pd.read_csv(filename, names=["Timestamp", "Sensor_Info"])
    data_frames.append(df)    

print(len(data_frames))

# calendar dictionary
months = {month: index for index, month in enumerate(calendar.month_abbr) if month}

# Separate out different sensors
result_df = data_frames[0]
user = 0
print("Printing sensor info")
print(result_df)
heart_rate_df = result_df.loc[result_df['Sensor_Info'].str.contains("heart_rate"), :]
blood_oxygen_df = result_df.loc[result_df['Sensor_Info'].str.contains("blood_o2")]
noise_exp_df = result_df.loc[result_df['Sensor_Info'].str.contains("noise")]
temp_sleep_df = result_df.loc[result_df['Sensor_Info'].str.contains("sleep")]
acc_resultant_df = result_df.loc[result_df['Sensor_Info'].str.contains("resultant_acc")]
acc_xyz_df = result_df.loc[result_df['Sensor_Info'].str.contains("xyz_acc")]
acc_xyz_df[["X", "Y", "Z"]] = ""




health_data = [heart_rate_df, blood_oxygen_df, noise_exp_df, acc_resultant_df, acc_xyz_df, temp_sleep_df]
# reset data frame indexes
for data in health_data:
    data.reset_index(inplace=True, drop=True)


for df in health_data:
    for i in range(len(df.index)):
        time = df.at[i, 'Timestamp']
        if (time[:1] != " "):
            df.at[i, 'Timestamp'] = str(months[time[3:6]]) + time[time.index("/"):]
        else:
            df.at[i, 'Timestamp'] = str(months[time[4:7]]) + time[time.index("/"):]
        entry = df.iloc[i]['Sensor_Info']
        if 'xyz' in entry:
            values = (entry.split(":")[-1]).split()
            df.at[i, 'X'] = float(values[0])
            df.at[i, 'Y'] = float(values[1])
            df.at[i, 'Z'] = float(values[2]) 
        else:
            df.at[i,'Sensor_Info'] = float(entry.split(":")[-1])


# convert timestamp column to datetime object
for data in health_data:
    data['Timestamp'] = pd.to_datetime(data['Timestamp'], format="%m/%d/%Y %H:%M:%S:%f")

#heart_rate_df.loc[0:-1,["Sensor_Info"]] = heart_rate_df["Senfor_Info"].str.split(":")[-1]
print("------------------HR---------------------")
print(heart_rate_df.head())
# heart_rate_df['Timestamp'] = pd.to_datetime(heart_rate_df['Timestamp'], format="%m/%d/%Y %H:%M:%S:%f")

print("---------------O2------------------------")
print(blood_oxygen_df.head())

print("-----------------N----------------------")
print(noise_exp_df.head())

print("-------------------S--------------------")
sleep_df = temp_sleep_df[temp_sleep_df['Sensor_Info'] > 0]

# convert the hours of sleep to seconds
for i, row in sleep_df.iterrows():
    val = sleep_df.at[i, 'Sensor_Info']
    sleep_df.at[i, 'Sensor_Info'] = round(val/3600.0, 2)

print(sleep_df.head())

print("-------------------AR-------------------")
print(acc_resultant_df.head())

print("------------------XYZ-------------------")
acc_xyz_df.drop(labels="Sensor_Info", axis=1, inplace=True)
print(acc_xyz_df.head())






#Generate charts for the sensors
def plot_graphs(heart_rate_df, blood_oxygen_df, noise_exp_df, acc_resultant_df, acc_xyz_df, sleep_df):
    fig1 = px.scatter(heart_rate_df, x='Timestamp', y='Sensor_Info', labels={"Timestamp": "Time","Sensor_Info": "Heart Rate(BPM)"},title="Heart Rate")
    fig2 = px.scatter(blood_oxygen_df, x='Timestamp', y='Sensor_Info', labels={"Timestamp": "Time","Sensor_Info": "Blood Oxygen(%)"},title="Blood Oxygen Saturation")
    fig3 = px.scatter(noise_exp_df, x='Timestamp', y='Sensor_Info', labels={"Timestamp": "Time","Sensor_Info": "Audio Exposure(dB)"},title="Environmental Audio Exposure")
    fig4 = px.line(acc_resultant_df, x='Timestamp', y='Sensor_Info', labels={"Timestamp": "Time","Sensor_Info": "Acceleration(G's)"},title="Resultant Acceleration")
    fig5 = px.line(acc_xyz_df, x='Timestamp', y=['X', 'Y', 'Z'], title="XYZ Acceleration", labels={"Timestamp": "Time","value": "Acceleration(G's)"})
    fig6 = px.line(sleep_df, x='Timestamp', y='Sensor_Info', labels={"Timestamp": "Time","Sensor_Info": "Sleep duration(hrs)"},title="Sleep Analysis")
    return fig1,fig2,fig3,fig4,fig5,fig6

fig1, fig2, fig3, fig4, fig5, fig6 = plot_graphs(heart_rate_df, blood_oxygen_df, noise_exp_df, acc_resultant_df, acc_xyz_df, sleep_df)
figures = [fig1, fig2, fig3, fig4, fig5, fig6]

# adjust the xaxis ticks
# for index, fig in enumerate(figures):
#     length = len(health_data[index])
#     print(health_data[index].head())
#     fig.update_layout(
#     xaxis = dict(
#         tickmode = 'array',
#         tickvals = [x*(length//7) for x in range(length)],
#         )
#     )    




app = dash.Dash('SimpleExample')

app.layout = html.Div([
    html.H1("Apple Watch Sensory Data Visualization", style={'text-align': 'center'}),
    html.Br(),
    html.Div(["Select User: ",
              dcc.Dropdown(
                  id='dropdown',
                  value=0,
                  clearable=False,
                  options=[{'label': name, 'value': users.index(name)}
                          for name in users])
            ], style={'width': '20%', 'display': 'inline-block'}),

    html.Div([
        dcc.Graph(id="graph1",figure=fig1),
        dcc.Graph(id="graph2",figure=fig2),
        dcc.Graph(id="graph3",figure=fig3),
        dcc.Graph(id="graph4",figure=fig4),
        dcc.Checklist(
            id="xyz_checkbox",
            options=[
                {"label": "X", "value": 0},
                {"label": "Y", "value": 1},
                {"label": "Z", "value": 2}
            ],
            style={"margin-left": "800px"},
            labelStyle={"display": 'inline-block'},
            value=[0, 1, 2],
        ),
        dcc.Graph(id="graph5",figure=fig5),
        dcc.Graph(id="graph6",figure=fig6),

    ])
])

def update_xyz_chart(values):
    list = []
    if 0 in values:
        list.append("X")
    if 1 in values:
        list.append("Y")
    if 2 in values:
        list.append("Z")
    if len(list) == 0:
        return px.line(acc_xyz_df, x='Timestamp', y=[0 for x in range(len(acc_xyz_df))], title="XYZ Acceleration", labels={"Timestamp": "Time","value": "Acceleration(G's)"})
    fig5 = px.line(acc_xyz_df, x='Timestamp', y=list, title="XYZ Acceleration", labels={"Timestamp": "Time","value": "Acceleration(G's)"})

    length = len(acc_xyz_df)
    fig5.update_layout(
        xaxis = dict(
            tickmode = 'array',
            tickvals = [x*(length//7) for x in range(length)],
            )
        )
    return fig5


@app.callback(Output('graph1', 'figure'),
              Output('graph2', 'figure'),
              Output('graph3', 'figure'),
              Output('graph4', 'figure'),
              Output('graph5', 'figure'),
              Output('graph6', 'figure'),
              [Input('dropdown', 'value'), Input("xyz_checkbox", "value")])

def update_figure(user_option, checkbox_values):

    print("******************* This function is called **********************")
    global user
    if user == user_option:
        global fig1, fig2, fig3, fig4, fig5, fig6

        # did not change user so don't update all graphs
        fig5 = update_xyz_chart(checkbox_values)
        return fig1, fig2, fig3, fig4, fig5, fig6


    print(user_option)
    user = user_option
    result_df = data_frames[user_option]
    

    heart_rate_df = result_df.loc[result_df['Sensor_Info'].str.contains("heart_rate"), :]
    blood_oxygen_df = result_df.loc[result_df['Sensor_Info'].str.contains("blood_o2")]
    noise_exp_df = result_df.loc[result_df['Sensor_Info'].str.contains("noise")]
    sleep_df = result_df.loc[result_df['Sensor_Info'].str.contains("sleep")]
    acc_resultant_df = result_df.loc[result_df['Sensor_Info'].str.contains("resultant_acc")]
    global acc_xyz_df
    acc_xyz_df = result_df.loc[result_df['Sensor_Info'].str.contains("xyz_acc")]
    acc_xyz_df[["X", "Y", "Z"]] = ""

    health_data = [heart_rate_df, blood_oxygen_df, noise_exp_df, acc_resultant_df, acc_xyz_df, sleep_df]
    
     # reset data frame indexes
    for df in health_data:
        df.reset_index(inplace=True, drop=True)

    for df in health_data:
        for i in range(len(df.index)):
            time = df.at[i, 'Timestamp']
            if (time[:1] != " "):
                df.at[i, 'Timestamp'] = str(months[time[3:6]]) + time[time.index("/"):]
            else:
                df.at[i, 'Timestamp'] = str(months[time[4:7]]) + time[time.index("/"):]
            # df.at[i, 'Timestamp'] = time[4:]
            entry = df.iloc[i]['Sensor_Info']
            if 'xyz' in entry:
                values = (entry.split(":")[-1]).split()
                df.at[i, 'X'] = float(values[0])
                df.at[i, 'Y'] = float(values[1])
                df.at[i, 'Z'] = float(values[2]) 
            else:
                df.at[i,'Sensor_Info'] = float(entry.split(":")[-1])

        # handle the case where no values recorded for sensor type
        if len(df) == 0:
            # add zero entry to data frame 
            df.loc[0] = [0 for x in range(len(df.columns))]

    # # convert timestamp column to datetime object
    for data in health_data:
        data['Timestamp'] = pd.to_datetime(data['Timestamp'], format="%m/%d/%Y %H:%M:%S:%f")


    acc_xyz_df.drop(labels="Sensor_Info", axis=1, inplace=True)
    sleep_df = sleep_df[sleep_df['Sensor_Info'] > 0]

    # convert the hours of sleep to seconds
    for i, row in sleep_df.iterrows():
        val = sleep_df.at[i, 'Sensor_Info']
        sleep_df.at[i, 'Sensor_Info'] = round(val/3600.0, 2)
    
    
    fig1, fig2, fig3, fig4, fig5, fig6 = plot_graphs(heart_rate_df, blood_oxygen_df, noise_exp_df, acc_resultant_df, acc_xyz_df, sleep_df)
    figures = [fig1, fig2, fig3, fig4, fig5, fig6]

    # adjust the xaxis ticks
    # for index, fig in enumerate(figures):
    #     length = len(health_data[index])
    #     fig.update_layout(
    #     xaxis = dict(
    #         tickmode = 'array',
    #         tickvals = [x*(length//7) for x in range(length)],
    #         )
    #     )

    return fig1, fig2, fig3, fig4, fig5, fig6





# Run the web server locally
app.run_server(debug=True)