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
    driver.get("https://www.fredmeyer.com/weeklyad")

    1. Get list of elements with description matching target items.

    soup.find_all("area", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu")})

    anon FM window raises popup, but only sometimes? Check for and close if so.
    # use elementS instead of element to return list, if list isn't empty click [0].
    driver.find_elements("xpath","//button[text()='Dismiss']")[0].click()

    2. For each element, click on the link to open modal.

    hr = p[0]['href']
    xpath_expr = f"//area[@href='{hr}']"
    driver.find_element("xpath",xpath_expr).click()

    * gotchas: need to move to a specific element before clicking:

    elem = driver.find_element("xpath","//area[@href='#link10']")

    # vvv didn't work vvv
    driver.execute_script("arguments[0].scrollIntoView();", elem)

    # this seems to work
    from selenium.webdriver.common.action_chains import ActionChains
    a = ActionChains(driver)
    a.move_to_element(elem).perform()


    THEN click. Or just switch to using search.

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
    for store, hits in a.items():
        for meat in hits:
            print(store + ":" + meat)


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


def crawl_fm_rmx(driver, hits):
    '''using search instead of parsing full page:
    s = driver.find_element("xpath","//input[@id='textInput']")
    s.send_keys('Beef')
    s.send_keys(Keys.ENTER)
    p = driver.find_element("xpath","//div[@class='offer_card']/div[@class='footer_btn']")
    - then get desc + price, close modal, continue

    p = driver.find_elements("xpath","//div[@class='offer_card']/div[@class='footer_btn']")

    '''

    driver.get('https://www.fredmeyer.com/weeklyad')
    time.sleep(3)
    #driver.find_elements("xpath","//button[text()='Dismiss']")[0].click()
    for meat in MEAT:
        # we want the second text box on the page, gotta be a neater way of doing this
        # also, initial search needs first text box. Ugh.
        searchbox = driver.find_elements("xpath","//input[@id='textInput' or @id='search-textInput']")[1]
        searchbox.clear()
        searchbox.send_keys(meat)
        searchbox.send_keys(Keys.ENTER)
        # need another loop here to iterate over elements
        prots = driver.find_elements("xpath","//div[@class='offer_card']/div[@class='footer_btn']")
        for p in prots:
            p.click()
            time.sleep(1)
            desc = driver.find_element("xpath", "//div[@class='modal__heading']").text
            price = driver.find_element("xpath", "//div[@class='offer_price']").text
            hits['FRED MEYER'].append(desc + ":  " + price)
            driver.find_elements("xpath","//a[@aria-label='Close modal']")[0].click()



def crawl_fm(driver, hits):
    driver.get('https://www.fredmeyer.com/weeklyad')
    time.sleep(3)
    a = ActionChains(driver)
    #driver.find_elements("xpath","//button[text()='Dismiss']")[0].click()
    time.sleep(3)
    html_source_code = driver.execute_script("return document.body.innerHTML;")
    soup: bs = bs(html_source_code, 'html.parser')
    proteins = soup.find_all("area", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu")})
    for p in proteins:
        coords = p['coords']
        xpath_expr = f"//area[@coords='{coords}']"
        elem = driver.find_element("xpath", xpath_expr)
        a.move_to_element(elem).perform()
        elem.click
        time.sleep(1)
        desc = driver.find_element("xpath", "//div[@class='modal__heading']").text
        price = driver.find_element("xpath", "//div[@class='offer_price']").text
        hits['FRED MEYER'].append(desc + ":  " + price)
        time.sleep(1)
        #driver.find_elements("xpath","//button[text()='Dismiss']")[0].click()
        driver.find_elements("xpath","//a[@aria-label='Close modal']")[0].click()
        time.sleep(2)
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
hits = crawl_safeway(driver, hits)
for k, v in hits.items():
    for meat in v:
        print(k, meat)
