from transfermarkt_parsing import MotherCompetitions, DomesticLeague, DomesticCup, EuroCup
from transfermarkt_parsing import is_theDay
from bs4 import BeautifulSoup
import datetime
import requests
import pytest
from transfermarkt import main_cups, second_cups

a = MotherCompetitions()
headers = {
'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36',
}

# r = requests.get('https://www.transfermarkt.pl/super-lig/gesamtspielplan/wettbewerb/TR1/saison_id/2022', headers=headers)
# soup = BeautifulSoup(r.text, 'html.parser')    
# matches = []
# a = DomesticLeague()
# for gameday in a.oneSeason_gamedays(soup):
#     for game in a.oneDay_games(gameday):
#         today = a.single_game(game)
#         if today:
#             print(today)

test_date = datetime.datetime.strptime('07.03.2023', '%d.%m.%Y').date()
            
r = requests.get('https://www.transfermarkt.pl/uefa-champions-league/gesamtspielplan/pokalwettbewerb/CL/saison_id/2022', headers=headers)
soup = BeautifulSoup(r.text, 'html.parser')    
b = EuroCup()
rounds = b.two_top_rounds(soup=soup)
print(len(rounds))
for round in rounds:
    round = b.games_from_round(round)
    for game in round:
        today = b.single_game(game)
        today['date'] = b.parse_date(today['date'])
        if is_theDay(today['date'], test_date):
            print(today)
            
# for name, link in main_cups.items():
#     r = requests.get(link, headers=headers)
#     soup = BeautifulSoup(r.text, 'html.parser')    
#     b = DomesticCup()
#     matches = []
#     rounds = b.two_top_rounds(soup=soup)
#     for round in rounds:
#         round = b.games_from_round(round)
#         for game in round:
#             today = b.single_game(game)
#             today['date'] = b.parse_date(today['date'])
#             if is_theDay(today['date'], test_date):
#                 matches.append(today)
#     if matches:
#         print(matches)
        
# matches = []
# for name, link in second_cups.items():
#     submatches = []
#     r = requests.get(link, headers=headers)
#     soup = BeautifulSoup(r.text, 'html.parser')    
#     b = DomesticCup()
#     rounds = b.two_top_rounds(soup=soup)
#     for round in rounds:
#         round = b.games_from_round(round)
#         for game in round:
#             today = b.single_game(game)
#             today['date'] = b.parse_date(today['date'])
#             if is_theDay(today['date'], test_date):
#                 submatches.append(today)
#     if submatches:
#         matches.append(15*'*' + '   ' + name + '  ' + 15*'*')
#         matches.extend(submatches)
# print(matches)