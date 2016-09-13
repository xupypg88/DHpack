#!/usr/bin/python
debug='on'

def MainMenu ():
    print "Menu\n"
    print "There you must choose: \n 1. Unpack \n 2. Pack\n"

    choice=raw_input()

    if debug == 'on':
        print "\nYour choice was: " + choice
		
    if choice == 1 :
        print "Unpacking...\n"
    elif choice == 0 :
        print "Packing...\n"
    else:
        print "Wrong choice!"
        MainMenu()

MainMenu()
