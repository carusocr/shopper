"""

Automated shopper to find cheapest prices of expensive staples.

Notes

To list all attributes of a particular element:

    elem = driver.find_element("xpath","//area")

    driver.execute_script('var items = {}; for (index = 0; index < arguments[0].attributes.length; ++index) { items[arguments[0].attributes[index].name] = arguments[0].attributes[index].value }; return items;', elem)

Clicking on a single item in FM flyer (example has href value of '#link3', need to 
find each one:

    driver.find_element("xpath","//area[@href='#link3']").click()
    

So the tedious process for getting Fred Meyer items is going to be something like:

    1. Get list of elements with description matching target items.

    soup.find_all("area", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu")})

    2. For each element, click on the link to open modal.

    hr = p[0].xpath("./href")
    xpath_expr = f"//area[@href='{hr}']"
    driver.find_element("xpath",xpath_expr).click()

    3. Scrape modal desc + price, add to dictionary, close modal.

    desc = driver.find_element("xpath","//div[@class='modal__heading']")
    price = driver.find_element("xpath","//div[@class='offer_price']")
    # then close modal window
    driver.find_element("xpath","//a[@aria-label='Close modal']").click()

    4. Generate pretty list of items + prices.


    To build list of sale items, make dict, keys are stores, arrays are values, 
    append each desc + price to store specific value array.
    
    a = {'sw': [], 'fm': []}
    a['sw'].append(res.group('desc') + res.group('price'))
    (do something similar with fm)
    then iterate over list
    for store, meats in a.items():
        for meat in meats:
            print(store + ":" + meat)



"""
import undetected_chromedriver as uc
from bs4 import BeautifulSoup as bs
import random,time,os,sys
import regex as re
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

def init_chrome():

    chrome_options = uc.ChromeOptions()
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--disable-popup-blocking")
    chrome_options.add_argument("--ignore-certificate-errors")
    driver = uc.Chrome(options=chrome_options)
    return driver

meats = {'SAFEWAY': [], 'FRED MEYER': []}

def crawl_safeway(driver, meats):

    driver.get('https://www.safeway.com/set-store.html?storeId=1594&target=weeklyad')
    time.sleep(10)
    elem = driver.find_element("xpath","//iframe[@class='flippiframe mainframe']")
    driver.switch_to.frame(elem)
    time.sleep(2) # see if this is necessary
    html_source_code = driver.execute_script("return document.body.innerHTML;")
    soup: bs = bs(html_source_code, 'html.parser')
    proteins = soup.find_all("button", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu")})
    for protein in proteins:
        found_meat = (protein['aria-label'])
        res = re.search('(?<desc>.+), ,(?<price>.+\d(\.\d+)?.+(digital_coupon)?).+?\.', found_meat)
        meats['SAFEWAY'].append(res.group('desc') + ":  " + res.group('price'))
        #print(res.group('desc'))
        #print(res.group('price'))
    return meats

driver = init_chrome()
meats = crawl_safeway(driver, meats)
for k, v in meats.items():
    for meat in v:
        print(k, meat)
