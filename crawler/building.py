import requests
import json
import re
from bs4 import BeautifulSoup

URL = "https://www.washington.edu/classroom/"

r = requests.get(URL)
soup = BeautifulSoup(r.text, "html.parser")

buildings = soup.select('div[id=buildings]')[0]
# building_names = buildings.select('li')
for name in buildings.select('li'):
    building_name = name.text

    # print(building_name)
    abbr = re.search('(?<=\().+?(?=\))', building_name).group(0)
    outer_json = "{" + abbr + ": "
    print(outer_json)
    temp_url = URL + abbr + "/"
    r = requests.get(temp_url)
    temp_soup = BeautifulSoup(r.text, "html.parser")
    # rooms_sum = temp_soup.select("ul[class=children]")[0]
    rooms_sum = temp_soup.select('tbody')[0]
    rooms = rooms_sum.select('td')
    count = 0

    while count < len(rooms):
        room_name = rooms[count].text
        type = rooms[count+1].text
        room = rooms[count].text.strip().replace(" ", "+")
        room_url = URL + room + "/"
        r = requests.get(room_url)
        room_soup = BeautifulSoup(r.text, "html.parser")
        count += 3
        # print all the basic info about the classroom
        equipment = []
        furnishings = []
        dimensions = []
        instructor_area = []
        student_seating = []
        for cell in room_soup.html.findAll('h3'):
            # print(cell.text)
            if 'Equipment' == cell.text:
                # print(cell.text)
                ul = cell.find_next_siblings('ul')[0]
                # links = ul.select('a')
                equipment = [link.text.strip() for link in ul.findAll('a')]
                # for a in links:
                #     print(a.text)
            elif ' Furnishings' == cell.text:
                # print('Furnishings')
                ul = cell.find_next_siblings('ul')[0]
                furnishings = [list.text.strip() for list in ul.findAll('li')]
                # lists = ul.select('li')
                # for li in lists:
                #     print(li.text)
            elif 'Dimensions' == cell.text:
                # print(cell.text)
                ul = cell.find_next_siblings('ul')[0]
                dimensions = [list.text.strip() for list in ul.findAll('li')]
                # lists = ul.select('li')
                # for li in lists:
                #     print(li.text)
            elif 'Instructor Area' == cell.text:
                # print(cell.text)
                ul = cell.find_next_siblings('ul')[0]
                instructor_area = [list.text.strip() for list in ul.findAll('li')]
                # lists = ul.select('li')
                # for li in lists:
                #     print(li.text)
            elif 'Student Seating' == cell.text:
                # print(cell.text)
                ul = cell.find_next_siblings('ul')[0]
                student_seating = [list.text.strip() for list in ul.findAll('li')]
                # lists = ul.select('li')
                # for li in lists:
                #     print(li.text)
        # print(equipment)
        # print(furnishings)
        # print(dimensions)
        # print(instructor_area)
        # print(student_seating)
        img = room_soup.find('img')['src']
        # print(room_soup.select("div[class='widget widget_text']"))
        room_name = room_name.strip()
        result = { room_name: {"Type": type,
                              "Equipment": equipment,
                              "Furnishings": furnishings,
                              "Dimensions": dimensions,
                              "Instructor Area": instructor_area,
                              "Student Seating": student_seating,
                              "Picture": img}}
        print(result)
        print("}")
        print()


