import requests

UNI_URL = 'http://search.mtvnservices.com/typeahead/suggest/'

PROF_PAGE_URL = 'http://www.ratemyprofessors.com/ShowRatings.jsp?'
PROF_RATING_URL = 'http://www.ratemyprofessors.com/paginate/professors/ratings'

rows = 10000

uni_params = {
    'solrformat': 'true',
    'rows': rows,
    'callback': '',
    'q': '*:* AND schoolid_s:1530',
    'defType': 'edismax',
    'qf': 'teacherfirstname_t^2000 teacherlastname_t^2000 '
          'teacherfullname_t^2000 autosuggest',
    'bf': 'pow(total_number_of_ratings_i,2.1)',
    'sort': 'total_number_of_ratings_i desc',
    'siteName': 'rmp',
    'start': 0,
    'fl': 'pk_id teacherfirstname_t teacherlastname_t '
          'total_number_of_ratings_i averageratingscore_rf schoolid_s',
    'fq': '',
    'prefix': 'schoolname_t:"University of Washington"',
}

r = requests.get(UNI_URL, params=uni_params)
# print(r.text)

tids = []
# Get first, last, score and tid.
docs = r.json()['response']['docs']
for professor in docs:
    if not ('averageratingscore_rf' in professor and not (
                professor['averageratingscore_rf'] == 0)):
        continue

    first = professor['teacherfirstname_t']
    last = professor['teacherlastname_t']
    score = professor['averageratingscore_rf']
    pk_id = professor['pk_id']

    tids.append(pk_id)
    print(first, last, score)

# Get reviews for each of the professors
for tid in tids:
    page_num = 1
    while True:
        r = requests.get(PROF_RATING_URL, params={'tid': tid, 'page': page_num})
        json = r.json()
        ratings = json['ratings']
        remaining = json['remaining']

        for rating in ratings:
            course = rating['rClass']
            overall = rating['rOverall']
            difficulty = rating['rEasy']

            print(course, overall, difficulty)

        if remaining == 0:
            break
        page_num += 1
