'''
This script scrapes the data from the DatSemShift using Selenium Google WebDriver. It downloads the data from the website using a Chrome driver
and stores it in a csv file which has the following columns: 'ID', 'Type', 'Language_1', 'Lexeme_1', 'Meaning_1', 'Direction', 'Language_2', 
'Lexeme_2', 'Meaning_2'. Since the DatSemShift itself is a huge Database, the code takes couple of hours to run. 
'''

#Importing necessary packages
import json
import csv
import time
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

filename = "DatSemShift.csv" #name of the file where the extracted data will be stroed

api_url = "http://datsemshift.ru/api/shifts?draw=1&start=0&length=20000" #url for the API of the website

base_url = "http://datsemshift.ru/" #url of the website

def setup_driver():
    options = Options() #Startup settings for the created browser
    options.add_argument("--disable-blink-features=AutomationControlled") #To avoid getting caught by the website as the bot
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    #Which browser selenium pretends to be to connect to website (to avoid any blocking from the website)
    options.add_argument('--ignore-certificate-errors') #To avoid any problems because of the certificate of the website
    options.add_argument('--allow-insecure-localhost') #To avoid any problems because of the certificate of the website
    options.set_capability('acceptInsecureCerts', True) #To avoid any problems because of the certificate of the website
    service = Service(ChromeDriverManager().install()) #Installing the chrome driver that can be used by the Selenium
    driver = webdriver.Chrome(service=service, options=options) #Starts the chrome driver to be used by Selenium
    return driver

def scrape_details(driver, shift_id, m1, m2):
    url = f"{base_url}shift{shift_id}" #accessing to the shift page
    
    realizations = [] #to store different realizations of the shift
    try:
        driver.get(url) #open the shift page
        
        soup = BeautifulSoup(driver.page_source, 'html.parser') #parses the shift page
        tables = soup.find_all('table')
        
        for table in tables: #loop over each realization table in the shift
            data = {'Type': 'NA', 'L1': 'NA', 'Lex1': 'NA', 'L2': 'NA', 'Lex2': 'NA', 'Dir': 'NA'} #extracted data structure
            
            rows = table.find_all('tr') #realizations include at least 3 rows
            if len(rows) < 3: continue 
            
            for tr in rows:
                tds = tr.find_all('td') #realizations include 2 columns
                if len(tds) < 2: continue
                
                label = tds[0].text.strip().lower() #extracting the label and value from the realization
                val = tds[1].text.strip()
                
                #assigning each value from the table into the correct label
                if 'type' in label: data['Type'] = val
                elif label in ['language', 'language 1']: data['L1'] = val
                elif label == 'language 2': data['L2'] = val
                elif label in ['lexeme', 'lexeme 1']: data['Lex1'] = val
                elif label == 'lexeme 2': data['Lex2'] = val
                elif 'direction' in label: data['Dir'] = val
            
            #if there the Language 2 and Lexeme 2 are the same in the shift
            if data['L2'] == 'NA': data['L2'] = data['L1']
            if data['Lex2'] == 'NA': data['Lex2'] = data['Lex1']
            
            #formatting ID with padding (e.g., shift0001) for the CSV
            formatted_id = f"shift{str(shift_id).zfill(4)}"
            
            realizations.append([
                formatted_id, data['Type'], data['L1'], data['Lex1'], 
                m1, data['Dir'], data['L2'], data['Lex2'], m2
            ])
            
    except Exception as e:
        print(f"Error on {url}: {e}")
        
    return realizations

def main():
    headers = ['ID', 'Type', 'Language_1', 'Lexeme_1', 'Meaning_1', 'Direction', 'Language_2', 'Lexeme_2', 'Meaning_2']
    #headers for the data file
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        #setting up the file to save the extracted data
        csv.writer(f).writerow(headers)

    driver = setup_driver() #Starting the chrome driver for the scraping
    
    try:
        print("Step 1: Fetching Master List via Browser (HTTP)...")
        driver.get(api_url) #load the url
        time.sleep(2) #wait for the page to load
        body_text = driver.find_element(By.TAG_NAME, "body").text #get the main text from the page
        try:
            if "pre" in driver.page_source:
                body_text = driver.find_element(By.TAG_NAME, "pre").text #to parse the JSON properly in the website
            
            data_json = json.loads(body_text) #converting JSON string into a dict
            shifts = data_json.get('data', []) #extracting the "data field" into a list
        except Exception as e: #if the parsing fails
            print("CRITICAL: Could not parse JSON.")
            print(f"Content preview: {body_text[:200]}")
            return

        print(f"Found {len(shifts)} shifts. Starting detailed scrape...")
        
        for index, s in enumerate(shifts): #go through the extracted shifts to collect their id number and meanings
            s_id = s[0]
            m1 = s[1]
            m2 = s[3]
            
            if index % 10 == 0:
                print(f"[{index+1}/{len(shifts)}] Scraping shift{s_id}...")
            
            results = scrape_details(driver, s_id, m1, m2) #scraping the realizations of each shift
            
            if results:
                #write the results
                with open(filename, 'a', newline='', encoding='utf-8') as f:
                    csv.writer(f).writerows(results)
            
            
    finally:
        driver.quit() #closing the selenium browser
        print(f"\nScraping Complete. File saved as {filename}")

if __name__ == "__main__":
    main()