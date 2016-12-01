# Eric Eckert
# CSE 413 Perkins AU16
# Part A
#
require_relative 'game.rb'

# MONSTER: FriendlyMonster
# FriendlyMonster extends Monster. It is a monster that does not attack.
class FriendlyMonster < Monster
    def initialize(name, world_text, dialogue, hurt_text, attr)
        super(name, world_text, attr)
        @dialogue = dialogue
        @hurt_text = hurt_text
    end

    def attack(other)
        puts @hurt_text
    end

    # prints FriendlyMonster's dialogue
    def talk()
        puts pretty_print(@dialogue, true)
    end

    # give items in FriendlyMonster's inventory to the player
    def give()
        if @inventory.any?
            print @name, " gave you "
            @inventory.each_with_index do |item, index|
                if (index != @inventory.length - 1)
                    print item.describe(:brief), ", "
                elsif (@inventory.length > 1)
                    print "and ", item.describe(:brief)
                else
                    print item.describe(:brief)
                end
            end
            Game.player.add_item(@inventory)
            @inventory.clear
            print ".", $/
        end
    end

    def describe(context)
        case context
        when :brief then @name
        when :world then @world_text
        when :detail then pretty_print(@detail_text)
        when :combat then @hurt_text
        else @name
        end
    end
end

# ITEM: Lantern
# Lantern is an item the player holds that may be turned on or off, and will aid
# the player in his adventure.
class Lantern < Item
    attr_reader :is_on
    def initialize(name, brief_text, detail_text, world_text)
        super(name, brief_text, detail_text, world_text)
        @is_on = false
    end

    # Turn lantern on or off when used
    def use(args = [])
        if @is_on
            @is_on = false
            @detail_text = "The lantern is off."
        else
            @is_on = true
            @detail_text = "The lantern is on."
        end

        Game.pretty_print(@detail_text)

        if Game.location.is_a? DarkLocation
            Game.location.pretty_print
        end
    end
end

# LOCATION: DarkLocation
# A Location in which you cannot see anything unless you have a lantern that is
# on
class DarkLocation < Location
    def initialize(name, desc)
        super(name, desc)
    end

    def pretty_print
        dark_paragraph = "It's too dark to see anything..."
        Game.player.inventory.each do |item|
            if item.name == "lantern" && item.is_on
                super
                return self
            end
        end
        Game.pretty_print(dark_paragraph, @name)
        return self
    end
end

