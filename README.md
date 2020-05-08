# Play Celebrity online
Hacked together for playing Celebrity online while social distancing. Shiny was not designed with multiplayer games in mind, but it more or less works as intended now.

## How to Set Up a Game

Feel free to clone this repo into your own Shiny server or use mine available [here](https://shiny.modallen.com/celebrity). The easiest way to set up a game is to use [**Google Forms**](http://forms.google.com/) to build the celebrity name list (see formatting rules below). After each player submits their celebrity names through Forms simply insert the URL to the Google Sheet containing everyone's responses into the text box under the "Configure Game" tab and click "Submit." See below for info on how to format and publish the Google Forms data.

### Format of the Google Form

Google Forms will automatically create a column for each question asked in the form. The only rule is that there must be one column with the word "player" somewhere in the column name (case-insensitive). The columns containing the celebrity names can be named anything, except they *cannot contain the word "player" in the column name.* The app will interpret all columns containing the word "player" as containing player names so those names will not be added to the game's celebrity name list (but they will be added to the list of players!).

### How to Publish Google Form data as CSV

From your Google Form page click into the "Responses" tab then the green Google Sheets icon in the top right. Once you are viewing the data in Google Sheets, go to File -> Publish to Web -> Linked. Make sure the correct sheet is selected then in the drop-down menu on the right select  "Comma-seperated values (.csv)." Copy the link that appears below.

