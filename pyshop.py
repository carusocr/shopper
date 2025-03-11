import undetected_chromedriver as uc
from bs4 import BeautifulSoup
import random,time,os,sys
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
html_source_code = driver.execute_script("return document.body.innerHTML;")
html_soup: BeautifulSoup = BeautifulSoup(html_source_code, 'html.parser')
html = html_soup.prettify("utf-8")
with open("souptest.html", "wb") as file:
    file.write(html)

time.sleep(10)
