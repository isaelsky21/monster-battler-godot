##### **scripts/ui/option\_panel.gd:**



Exported variables:



* mode: holds INTERACTION\_MODE Enum integer that lives in GameRunner autoload
* options\_parent: child VBoxContainer list to hold actual data (list of attacks, items, or monsters) as child nodes. Typed as a Control node, so the actual node can be anything that extends Control



func populate:



\# Populates options\_parent node with actual options, such as attacks, monsters, or items



Takes one argument:



1. **labels:** Array of StringEnabled that contains the options to be added as children of options\_parent



Body:



Calls clear function, which deletes any existing children.



Then:



1. It loops over the passed-in labels variable
2. Creates a variable to hold string with button text
3. Creates a button for each option on the list
4. The button gets added as a child of the options\_parent
5. The button text is assigned the string variable
6. The button is enabled/disabled based on label enabled property
7. Button's alignment is always set to the left
8. Lastly, the button pressed signal gets connected to a lambda function that emits a signal that will be connected to a function in GameRunner to handle what happens when a button is pressed (Keeps data and UI separate)

