import requests
import re
from bs4 import BeautifulSoup


def tab_serparate(s):
    return re.sub(r'\W{2,}|-', '\t', s)


def crawl_subject(url):
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'html.parser')
    course_name_elems = soup.select('table[bgcolor=#ffcccc]')
    for elem in course_name_elems:
        # Subject name
        subject_name_line = elem.select('a[name]')[0].text
        print(tab_serparate(subject_name_line))

        for section_elem in elem.next_siblings:
            if section_elem.name == 'br' or section_elem.name == 'p':
                break

            if section_elem.name == 'table':
                # Section table
                section_table_line = section_elem.text
                # print(tab_serparate(section_table_line))


URL = 'https://www.washington.edu/students/timeschd/AUT2017/'


def crawl_all_subjects(url):
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'html.parser')
    a_tags = soup.find_all(href=re.compile("^[a-z0-9]+\.html$"))
    for a in a_tags:
        crawl_subject(URL + a['href'])


crawl_all_subjects(URL)
