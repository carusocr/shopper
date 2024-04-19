import undetected_chromedriver as uc
import random,time,os,sys
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

chrome_options = uc.ChromeOptions()
chrome_options.add_argument("--disable-extensions")
chrome_options.add_argument("--disable-popup-blocking")
chrome_options.add_argument("--ignore-certificate-errors")

driver = uc.Chrome(options=chrome_options)

driver.get('https://www.safeway.com/set-store.html?storeId=1594&target=weeklyad')

time.sleep(10)
