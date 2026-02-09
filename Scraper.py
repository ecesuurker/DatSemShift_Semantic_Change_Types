'''
This script is the original script for the data scraping from DatSemShift but since the website structure has been updated this code is outdated.
'''

#Importing the necessary modules
from bs4 import BeautifulSoup
import csv
import requests
import pandas as pd
from random import randint
from time import sleep
import os.path

#The link for the DatSemShift website
url = 'http://datsemshift.ru/browse'

#Obtaining the HTML code of the webpage
response = requests.get(url,verify=False).text

#Parsing the HTML code of the website
soup = BeautifulSoup(response, 'html.parser')


# Verifying tables and their classes
print('Classes of each table:')
for table in soup.find_all('table'):
    print(table.get('class'))

#Getting display table
table = soup.find('table', class_='display')

#Getting the headers from the display table
headers = [th.text for th in table.select("tr th")]

if not(os.path.isfile('out.csv')): 
    #Getting the main table from http://datsemshift.ru/browse and saving as intermediate CSV
    with open("out.csv", "w") as f:
        wr = csv.writer(f)
        wr.writerow(headers)
        wr.writerow([[td.text for td in row.find_all("td")] for row in table.select("tr")][1]) #quick fix for missing first <tr> below
        wr.writerows([[td.text for td in row.find_all("td")] for row in table.select("tr + tr")])

df = pd.read_csv('out.csv')
colnames = df.columns.values.tolist()[:10] #Selecting only the columns needed
df = df[colnames]
print(df)
links = [item['href'] for item in soup.select('a[href^="shift"]')] #Selecting links that start with "shift"

if not(os.path.isfile('datsemshift.csv')):
    column_names = ['ID', 'Type', 'Language_1', 'Lexeme_1', 'Meaning_1', 'Direction', 'Language_2', 'Lexeme_2', 'Meaning_2']
    data = pd.DataFrame(columns=column_names)
    for row_in in range(len(df)): #Going through all the shifts in the database
        print(row_in)
        print(len(df))
        vals = list(df.loc[row_in]) #Values from the main data frame, for normalization
        url = 'http://datsemshift.ru/' + links[row_in] #Going into the link of the shift
        shift_id = links[row_in] #Saving the shift id separately
        response = requests.get(url,verify=False).text
        soup = BeautifulSoup(response, 'html.parser')
        tables = soup.find_all('table')
        sub_tables = [[[td.text for td in row.find_all("td")] for row in table.select("tr + tr")] for table in tables]
        sub_tables = [sbtbl for sbtbl in sub_tables if len(sbtbl) > 0] #Getting all the realizations of the shift
        for sbtbl in sub_tables: #Getting into the each realization of the shift
          d = ['NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA']
          if len(sbtbl) > 3:
            for i in range(len(sbtbl)):
                d[0] = shift_id
                if sbtbl[i][0] == 'type': d[1] = sbtbl[i][1]
                elif sbtbl[i][0] == 'language': d[2], d[6] = sbtbl[i][1], sbtbl[i][1] #If the shift happened inside the same language
                elif sbtbl[i][0] == 'language 1': d[2] = sbtbl[i][1]
                elif sbtbl[i][0] == 'lexeme': d[3], d[7] = sbtbl[i][1], sbtbl[i][1] #If the lexeme did not change with the shift
                elif sbtbl[i][0] == 'lexeme 1': d[3] = sbtbl[i][1]
                elif sbtbl[i][0] == 'meaning 1': d[4] = sbtbl[i][1]
                elif sbtbl[i][0] == 'direction': d[5] = sbtbl[i][1]
                elif sbtbl[i][0] == 'language 2': d[6] = sbtbl[i][1]
                elif sbtbl[i][0] == 'lexeme 2': d[7] = sbtbl[i][1]
                elif sbtbl[i][0] == 'meaning 2': d[8] = sbtbl[i][1]
            d = pd.DataFrame([d], columns=column_names)
            data = pd.concat([data, d], ignore_index=True) #Add the realization to the dataframe

    data = data.drop_duplicates()
    data.to_csv('DatSemShift.csv')