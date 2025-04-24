import unittest
from unittest.mock import MagicMock, patch
from selenium.webdriver.common.by import By

class TestPyShop(unittest.TestCase):

    @patch('undetected_chromedriver.v2.Chrome')
    def test_click_element(self, mock_chrome):
        # Mock the driver and its methods
        mock_driver = MagicMock()
        mock_chrome.return_value = mock_driver

        # Mock the element to be clicked
        mock_element = MagicMock()
        mock_driver.find_element.return_value = mock_element

        # Define the xpath expression
        xpath_expr = "//area[@href='#link3']"

        # Simulate the click
        mock_driver.find_element("xpath", xpath_expr).click()

        # Assertions
        mock_driver.find_element.assert_called_once_with("xpath", xpath_expr)
        mock_element.click.assert_called_once()

if __name__ == "__main__":
    unittest.main()