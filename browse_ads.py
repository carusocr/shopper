"""

Automated shopper to find cheapest prices of expensive staples.

    TODO: close browser windows before reinitializing a new one

"""
import undetected_chromedriver as uc
from bs4 import BeautifulSoup as bs
import random,time,os,sys
import regex as re
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains

def init_chrome():
    chrome_options = uc.ChromeOptions()
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--disable-popup-blocking")
    chrome_options.add_argument("--ignore-certificate-errors")
    driver = uc.Chrome(options=chrome_options)
    return driver

MEAT = ['Beef','Chicken','Pork','Tofu','Shrimp']
hits = {'SAFEWAY': [], 'FRED MEYER': []}


def crawl_fm(driver, hits):
    driver.get('https://www.fredmeyer.com/weeklyad')
    time.sleep(3)
    dismiss_modal = driver.find_elements("xpath","//button[text()='Dismiss']")
    if dismiss_modal:
        dismiss_modal[0].click()
    for meat in MEAT:
        searchbox = driver.find_element("xpath","//input[(@id='textInput' or @id='search-textInput') and not(@aria-label)]")
        searchbox.clear()
        searchbox.send_keys(meat)
        searchbox.send_keys(Keys.ENTER)
        time.sleep(1)
        prots = driver.find_elements("xpath","//div[@class='offer_card']/div[@class='footer_btn']")
        for p in prots:
            p.click()
            time.sleep(1)
            desc = driver.find_element("xpath", "//div[@class='modal__heading']").text
            desc = ' '.join(desc.splitlines())
            price = driver.find_element("xpath", "//div[@class='offer_price']").text
            price = ' '.join(price.splitlines())
            hits['FRED MEYER'].append(desc + ":  " + price)
            driver.find_elements("xpath","//a[@aria-label='Close modal']")[0].click()
        #instead of searching from results page, go back and click mainpage search again
        driver.find_element("xpath","//div[@id='back-to-weeklyad']").click()
        time.sleep(1)
    return hits

def crawl_safeway(driver, hits):

    driver.get('https://www.safeway.com/set-store.html?storeId=1594&target=weeklyad')
    # change this by making it a wait_for
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
        hits['SAFEWAY'].append(res.group('desc') + ":  " + res.group('price'))
        #print(res.group('desc'))
        #print(res.group('price'))
    return hits

driver = init_chrome()
#hits = crawl_safeway(driver, hits)
hits = crawl_fm(driver, hits)
for k, v in hits.items():
    for meat in v:
        print(k, meat)
