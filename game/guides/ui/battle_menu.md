##### **scripts/ui/battle\_menu.gd:**



Exported variables:



* select\_ variables: These variables hold the button nodes that handle actions
* \_menu variables: main\_menu holds all button nodes, whereas the rest hold the OptionPanel nodes



func \_ready:



* Connects button pressed signals to functions in GameRunner to handle what happens when action buttons are pressed
* The signal request\_option\_selected ensures the player is brought back to main menu after selecting an option
* The functions in GameRunner that handle actions emit a signal that connects to a function that disables other menus and populates the buttons with the name and options
* Back and Run buttons are handled in this class
* Losing hides the battle menu, and starting a new game, shows it
* When first starting the game, hide everything, except the main menu

