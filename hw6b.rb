# Eric Eckert

require_relative 'game.rb'
require_relative 'hw6a.rb'

# ACTION: Unlock
# An action to unlock a locked location. Will check if location is locked, then
class Unlock < Action
    def intialize()
        @desc = "Unlock a locked location with the corresponding item in your inventory."
    end

    def do(args = [])
        if args.length < 1
            puts "Unlock where?"
            return
        end
        if (args[0] == 'n') then args[0] = 'north' end
        if (args[0] == 's') then args[0] = 'south' end
        if (args[0] == 'e') then args[0] = 'east' end
        if (args[0] == 'w') then args[0] = 'west' end
        if Game.location.doors.has_key?(args[0])
            next_location = Game.location.doors[args[0]]
            if next_location.is_a? LockedLocation
                if next_location.try_unlock()
                    print args[0], " is now unlocked. You can go there!", $/
                else
                    print "You need a ", next_location.key, " to unlock ", args[0], $/
                end
            else
                print args[0], " is not locked. You can go there!", $/
            end
        else
            print "You can't unlock ", args[0], ".", $/
        end
    end
end

# ACTION: PickUp
# Pick up all or a single item at the current location and place it in your inventory.
class PickUp < Action
    def initialize()
        @desc = "Pick up all items at current location. Will only pick up a single item if you specify."
    end

    def do(args = [])
        picked_up = false
        acquired_items = []
        # If no item is specified, pick up everything
        if (args.length < 1)
            Game.location.things.each do |key, thing|
                if thing.is_a? Item
                    #Game.player.inventory.push(thing)
                    picked_up = true
                    Game.location.things.delete(key)
                    acquired_items.push(thing)
                end
            end
        # If item is specified, pick up that item
        elsif Game.location.things.has_key?(args[0])
            picked_up = true
            Game.location.things.delete(args[0])
            acquired_items.push(thing)
        end
        # print items that were picked up
        if picked_up
            Game.player.add_item(acquired_items)
            print "You picked up "
            acquired_items.each_with_index do |item, index|
                if (index != acquired_items.length - 1)
                    print item.describe(:brief), ", "
                elsif (acquired_items.length > 1)
                    print "and ", item.describe(:brief)
                else
                    print item.describe(:brief)
                end
            end
            print ".", $/
        else
            puts "There's nothing to pick up."
        end
    end
end

# ACTION: TalkTo
# Action that allows player to talk to certain Monster subclasses
class TalkTo < Action
    def initialize() @desc = "Speak to a friendly monster" end
    def do(args = [])
        if (args.length < 1)
            puts "Talk to what?"
        end
        talkable = false
        if Game.location.things.has_key?(args[0])
            if ((Game.location.things[args[0]].is_a? FriendlyMonster) || (Game.location.things[args[0]].is_a? Boss))
                talkable = true
                Game.location.things[args[0]].talk()
                if (Game.location.things[args[0]].is_a? FriendlyMonster)
                    Game.location.things[args[0]].give()
                end
            end
        end
        if (not talkable)
            print "You can't talk to ", args[0], $/
        end
    end
end

# ITEM: Weapon
# An item the player can equip (with the use action) to increase his attack points.
class Weapon < Item
    def initialize(name, brief_text, detail_text = nil, world_text = nil, power)
        super(name, brief_text, detail_text, world_text)
        @power = power
        @equipped = false
    end

    def use(args = [])
        if !@equipped
            Game.player.delta_attr({"ap" => @power})
            print "You've equipped ", @brief_text, "! Your attack power has increased to ", Game.player.get_attribute("ap"), ".", $/
            @equipped = true
        else
            print "You've already equipped ", @brief_text, "!", $/
        end
    end
end

# ITEM: Potion
# An item that increases the user's hp attribute. Can only be used once.
class Potion < Item
    def initialize(name, brief_text, detail_text = nil, world_text = nil, heal)
        super(name, brief_text, detail_text, world_text)
        @heal = heal
    end

    def use(args = [])
        Game.player.delta_attr({"hp" => @heal})
        Game.player.inventory.delete_at(Game.player.inventory.index(self))
        print "You've drunk ", @brief_text, "! Your hp has increased to ", Game.player.get_attribute("hp"), ".", $/
    end
end


# FRIENDLYMONSTER: Boss
# There is only one Boss in the game. Once defeated, the game is clear.
class FinalBoss < FriendlyMonster
    def intialize(name, world_text, dialogue, hurt_text, attr)
        super(name, world_text, dialogue, hurt_text, attr)
        @dialogue = dialogue
        @end = false
        @hurt_text = hurt_text
    end

    def talk()
        if !@end
            puts pretty_print(@dialogue, true)
        else
            puts pretty_print("The boss is dead.")
        end
    end

    def give()
    end

    def attack(other)
        if !@end
            if @attributes["hp"] <= 0
                end_game
                return
            end
            puts @hurt_text
            print "The ", @name, " attacks you.", $/
            atk = if @attributes.has_key? "ap" then -@attributes["ap"] else -1 end
            other.delta_attr({ "hp" => atk })
            other.describe(:combat)
        else
            puts "The boss is dead. Stop beating a dead horse. Err... boss."
        end
    end

    def end_game()
        puts "Congratulations! You've completed the game!"
        @end = true
    end
end

# location instances
home = Location.new('Home', 'You are at home.')
closet = DarkLocation.new('Closet', 'You are in the closet')
basement = LockedLocation.new('Basement', 'You are in the basement. There is a glimmer of light in the darkness straight ahead.', 'key')
crystal = Location.new('Crystal Cavern', 'You are in the Crystal Cavern, a large crystal cavern presumably underground. The chamber has a timeless and ancient feeling to it.')
field = Location.new('Large Field', 'You are in a large, grassy field that extends as far as the eye can see. Almost. In the distance to the north you can barely make out what seems like a castle.')
castle_front = Location.new("Castle Front", "You are standing in front of a giant, old castle. It has an eerie feel to it. The front door to the castle is at least 15 feet tall. The door handles are engraved brass lion heads. There is a large keyhole on the right half of the door.")
castle_hall = LockedLocation.new("Castle Hall", "You are now inside the castle hall. It's dimly lit from the light in the windows. A tattered carpet that used to be a rich red tone extends down the center of the hall to the stairway, which goes up and splits, one direction leading east, and one west. The room to the east seems ominous. Something tells you you should go west first.", "key")
castle_throne = DarkLocation.new("Castle Throne Room", "The throne room is even more massive. Paintings and tapestries line the walls. An ominous mural covers the ceiling. In the dimly lit throne sits a giant figure. It seems like it was waiting for you.")
castle_dining = DarkLocation.new("Castle Dining Room", "The dining room is massive. Paintings of what seem like royals are lined up along one side of the wall. A large fireplace is on the other side of the room.")

# Door hashes
home.doors['north'] = closet
closet.doors['south'] = home
home.doors['east'] = basement
basement.doors['west'] = home
basement.doors['east'] = crystal
crystal.doors['north'] = field
field.doors['south'] = crystal
field.doors['east'] = field
field.doors['west'] = field
field.doors['north'] = castle_front
castle_front.doors['south'] = field
castle_front.doors['north'] = castle_hall
castle_hall.doors['south'] = castle_front
castle_hall.doors['east'] = castle_throne
castle_hall.doors['west'] = castle_dining
castle_dining.doors['east'] = castle_hall
castle_throne.doors['west'] = castle_hall

# Thing instances
frank = FriendlyMonster.new('Frank', 'Frank is here. He is a friendly guy.', 'Hello my friend, my name is Frank. I wish you best of luck on your journey!', "Hey, don't hurt me! I'm your friend!", {'hp' => 100})
lantern = Lantern.new("lantern", "your trusty lantern", "The lantern is off", nil)
key = Item.new("key", "a mysterious key", "A mysterious key lays on the ground.", "A mysterious key. It probably unlocks something.")
sword = Weapon.new("sword", "a legendary sword", "A sword with a regal aura about it sits embedded in the altar in the center of the room. It seems to call out to you.", "A well crafted sword with a regal aura. Something tells me you should \"use\" the sword to equip it. Whatever tha means.", 25)
potion = Potion.new("potion", "a health potion", "A health potion.", "A health potion contained within a glass bottle. It looks revitalizing.", 20)
fairy = FriendlyMonster.new("Grass Fairy", "A grass fairy wanders aimlessly in the field. Maybe you should talk to her.", "Dear adventurer, your destiny awaits to the north. This is all I can do to aid you. Before you continue, be sure you have a weapon with you.", "Please do not cause me harm. I am only here to help you on your mission :(", {"mp" => 1000})
castle_key = Item.new("key", "a large brass key", "A large brass key", "A large brass key. It has a carving of a lion on it.")
eric = FriendlyMonster.new('Eric', "Eric is sitting in a chair waving at you.", "Hey, are you enjoying my game? I'll just sit here and wait for you to finish. Just go over to the throne room in the east.", "OW, what the hell?! This is the thanks I get for letting you play my game?", {"Intelligence" => 0})
ruby = Item.new("ruby", "a ruby gem", "A ruby gem.", "A deep crimson colored gem. It's polished to perfection. It's also pretty useless in context.")
minotaur = FinalBoss.new("Minotaur", "It's a huge, hulking minotaur. It holds a large axe by its side. It's breath is slow and ragged. It's staring at you.", "*snort* *pant* *ROAR*", "The minotaur roars in pain", {"hp" => 100, "ap" => 4})

# Thing hashes
fairy.add_item([potion, castle_key])
eric.add_item([ruby])

# location thing hashes
closet.things['key'] = key
home.things['Frank'] = frank
home.things['frank'] = frank
crystal.things['sword'] = sword
field.things['fairy'] = fairy
field.things['Fairy'] = fairy
castle_dining.things['eric'] = eric
castle_dining.things['Eric'] = eric
castle_throne.things['minotaur'] = minotaur

Game.new(home, actions: {"pickup" => PickUp.new, "unlock" => Unlock.new, "talk" => TalkTo.new}, inventory: [lantern])
