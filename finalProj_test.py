import unittest

import finalProj


class FlaskrTestCase(unittest.TestCase):

    def setUp(self):
        self.app = finalProj.app.test_client()

    def tearDown(self):
        pass

        #def test_home_page(self):
        # Render the / path of the website
        #rv = self.app.get('/')
        # Chech that the page contians the desired phrase
        #assert b'Welcome to the final project homepage' in rv.data

    def test_link_to_my_page(self):
        rv = self.app.get('/coffee')  
        # Search the page contents for the link to your topic page 
        # Replace xxxxxxxxxxxx with text you'd expect to see on your main page that links to your subpage
        assert b'Coffee' in rv.data

    def test_my_topic(self):
        # Replace '/' with the page path you want to make
        rv = self.app.get('/coffeesubpage')  
        # Replace UNH698 Website with the text you expect to see on you topic page
        assert b'Welcome to my coffee subpage' in rv.data

if __name__ == '__main__':
    unittest.main()
