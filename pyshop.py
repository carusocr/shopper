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

proteins = soup.find_all("button", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu")})
for protein in proteins:
    print(protein['aria-label'])
