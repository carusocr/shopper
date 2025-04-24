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

    TODO: anon FM window raises popup, but only sometimes? Check for and close if so.
    # use elementS instead of element to return list, if list isn't empty click [0].
    driver.find_elements("xpath","//button[text()='Dismiss']")[0].click()


"""
import undetected_chromedriver as uc
from bs4 import BeautifulSoup as bs
import random,time,os,sys
import regex as re
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

chrome_options = uc.ChromeOptions()
chrome_options.add_argument("--disable-extensions")
chrome_options.add_argument("--disable-popup-blocking")
chrome_options.add_argument("--ignore-certificate-errors")


driver = uc.Chrome(options=chrome_options)

#driver.get('https://www.fredmeyer.com/weeklyad')
driver.get('https://www.safeway.com/set-store.html?storeId=1594&target=weeklyad')
# <iframe id="0086b732-bb38-4e96-9906-38f8e46e1d0e" class="flippiframe mainframe" title="Main Panel" allowfullscreen="" scrolling="yes" frameborder="0" height="100%" width="100%" allowtransparency="true" webkitallowfullscreen="true" mozallowfullscreen="true" style="box-sizing: content-box;"></iframe>
#driver.switch_to.frame("0086b732-bb38-4e96-9906-38f8e46e1d0e")
# THEN get html_source, and it works. 
time.sleep(10)
elem = driver.find_element("xpath","//iframe[@class='flippiframe mainframe']")
driver.switch_to.frame(elem)
time.sleep(3) # see if this is necessary
html_source_code = driver.execute_script("return document.body.innerHTML;")
html_soup: bs = bs(html_source_code, 'html.parser')
html = html_soup.prettify("utf-8")
with open("souptest.html", "wb") as file:
    file.write(html)

# could also just parse instead of writing and then reading, but want to 
# review html manually too
with open('souptest.html') as fp:
    soup = bs(fp, features="lxml")

proteins = soup.find_all("button", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu", re.IGNORECASE)})
for protein in proteins:
    found_meat = (protein['aria-label'])
    res = re.search('(?<desc>.+), ,(?<price>.+\d(\.\d+)?.+(digital_coupon)?).+?\.', found_meat)
    if res:
        print(res.group('desc'))
        print(res.group('price'))
    res = re.search('(?<desc>.+), ,(?<price>.+\d(\.\d+)?.+(digital_coupon)?).+?\.', found_meat)
    if res:
        print(res.group('desc'))
        print(res.group('price'))
    else:
        print(f"No match found for: {found_meat}")
    res = re.search(r'(?P<desc>.+), ,(?P<price>\$\d+(\.\d+)?(?:\s+digital_coupon)?)', found_meat)
    print(res.group('desc'))
    print(res.group('price'))
