import requests
from bs4 import BeautifulSoup
from transfermarkt import main_leagues, second_leagues
from datetime import date, datetime
from meczbot import subreddit
import logging

logging.basicConfig(filename='failed_extractions.log', encoding='utf-8', level=logging.WARN)

class FutureGame(Exception):
    "Raised when game will be played tomorrow or later"
    pass

class NoDate(Exception):
    "Raised when game date was not in a.tag and date from previous game wasn't provided"
    pass

def title_text(competition_name):
    return competition_name + ' ' + str(date.today())

def body_text(games: list[dict]):
    games = [str(match) for match in games]
    return '\n\n'.join(games)
    
def is_theDay(checked_date_string:date, theDay:date):
    return datetime.strptime(checked_date_string, '%d.%m.%Y').date() == theDay
    
def is_today(checked_date_string:date):
    result = is_theDay(checked_date_string, date.today())
    return result

def is_past(date_string):
    return datetime.strptime(date_string, '%d.%m.%Y').date() < date.today()
    
def is_future(date_string):
    return datetime.strptime(date_string, '%d.%m.%Y').date() > date.today()

class MotherCompetitions():

    def __init__(self) -> None:
        self.helper_date = None
        self.helper_time = None
    
    def theday_game(self, game, date):
        game_dict = {}
        if game[0].a:
            game_date = game[0].a.text
            game_dict['date'] = game_date
            self.helper_date = game_date
        else:
            if self.helper_date:
                game_dict['date'] = self.helper_date
            else:
                logging.warning('Failed, no date available:{}'.format(str(game)))
                return False
        if not is_theDay(game_dict['date'], date):
            return False
            
        game_time = game[1].text.strip()
        if game_time:
            game_dict['time'] = game_time
            self.helper_time = game_time
        else:
            if self.helper_time:
                game_dict['time'] = self.helper_time
            else:
                logging.warning('Failed, no time available:{}'.format(str(game)))
                return False
                
        game_dict['host'] = game[2].a.text.strip()
        game_dict['guest'] = game[6].a.text.strip()
        
        assert game_dict['date']
        assert game_dict['guest']
        assert game_dict['host']
        assert game_dict['time']
        
        return game_dict
        
    def todays_game(self, game):
        result = self.theday_game(game, date.today())
        return result

class DomesticLeague(MotherCompetitions):

    @staticmethod
    def oneSeason_gamedays(soup):
        gamedays = soup.body.div.main.find_all('div', {'class': 'content-box-headline'})
        return [gameday.parent for gameday in gamedays]
    
    @staticmethod        
    def oneDay_games(gameday):
        gameday = gameday.table.tbody.find_all('tr')
        return [game.find_all('td') for game in gameday if not game.has_attr('class')] #9 matches 
    



def main():

    # test_league = 'Fortuna Liga - Łączny terminarz Transfermarkt.html'
    # with open(test_league) as tp:
    #     soup = BeautifulSoup(tp, 'html.parser')
    #     a = Domestic_league()
    #     for gameday in a.oneSeason_gamedays(soup):
    #         for game in a.oneDay_games(gameday):
    #             today = a.todays_game(game)
    #             if today:
    #                 print(today)

    headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36',
    }

    for name, link in main_leagues.items():
        r = requests.get(link, headers=headers)
        soup = BeautifulSoup(r.text, 'html.parser')    
        a = DomesticLeague()
        matches = []
        for gameday in a.oneSeason_gamedays(soup):
            for game in a.oneDay_games(gameday):
                today = a.todays_game(game)
                if today:
                    matches.append(today)
                    
        if matches:
            print(matches)
            # subreddit.submit(title_text(name), selftext = body_text(matches), discussion_type='CHAT')


    matches = []
    for name, link in second_leagues.items():
        submatches = []
        r = requests.get(link, headers=headers)
        soup = BeautifulSoup(r.text, 'html.parser')    
        a = DomesticLeague()
        for gameday in a.oneSeason_gamedays(soup):
            for game in a.oneDay_games(gameday):
                today = a.todays_game(game)
                if today:
                    submatches.append(today)
        if submatches:
            matches.append(15*'*' + '   ' + name + '  ' + 15*'*')
            matches.extend(submatches)

    print(matches)
    #subreddit.submit(title_text('Inne ligi'), selftext = body_text(matches), discussion_type='CHAT')

if __name__ == '__main__':
    main()  