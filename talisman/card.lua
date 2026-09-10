local cuc = Card.use_consumable
function Card:use_consumable(x,y)
	Talisman.current_calc.score = true
	local ret = cuc(self, x,y)
	Talisman.current_calc.score = false
	return ret
end

if not SMODS then
  function Card:get_chip_x_bonus()
      if self.debuff then return 0 end
      if self.ability.set == 'Joker' then return 0 end
      if (self.ability.x_chips or 0) <= 1 then return 0 end
      return self.ability.x_chips
  end
end
