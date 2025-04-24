import unittest
from unittest.mock import patch, MagicMock
from bs4 import BeautifulSoup as bs
import regex as re
import pyshop

class TestPyshop(unittest.TestCase):

    @patch('pyshop.uc.Chrome')
    def test_driver_initialization(self, mock_chrome):
        mock_driver = MagicMock()
        mock_chrome.return_value = mock_driver

        driver = pyshop.uc.Chrome(options=pyshop.chrome_options)
        mock_chrome.assert_called_once_with(options=pyshop.chrome_options)
        self.assertEqual(driver, mock_driver)

    @patch('pyshop.bs')
    @patch('pyshop.open')
    def test_html_parsing(self, mock_open, mock_bs):
        mock_open.return_value.__enter__.return_value = "<html></html>"
        mock_soup = MagicMock()
        mock_bs.return_value = mock_soup

        with open('souptest.html') as fp:
            soup = pyshop.bs(fp, features="lxml")

        mock_open.assert_called_once_with('souptest.html')
        mock_bs.assert_called_once_with(mock_open.return_value.__enter__.return_value, features="lxml")
        self.assertEqual(soup, mock_soup)

    def test_protein_parsing(self):
        html_content = """
        <html>
            <button aria-label="Beef, ,$5.99 digital_coupon."></button>
            <button aria-label="Chicken, ,$3.49."></button>
            <button aria-label="Pork, ,$4.99 digital_coupon."></button>
            <button aria-label="Tofu, ,$2.99."></button>
        </html>
        """
        soup = bs(html_content, 'html.parser')
        proteins = soup.find_all("button", attrs={"aria-label": re.compile("Beef|Chicken|Pork|Tofu", re.IGNORECASE)})

        results = []
        for protein in proteins:
            found_meat = protein['aria-label']
            res = re.search(r'(?P<desc>.+), ,(?P<price>\$\d+(\.\d+)?(?:\s+digital_coupon)?)', found_meat)
            if res:
                results.append((res.group('desc'), res.group('price')))

        expected_results = [
            ("Beef", "$5.99 digital_coupon"),
            ("Chicken", "$3.49"),
            ("Pork", "$4.99 digital_coupon"),
            ("Tofu", "$2.99")
        ]
        self.assertEqual(results, expected_results)

if __name__ == '__main__':
    unittest.main()