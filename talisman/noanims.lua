G.FUNCS.evaluate_play = function(e)
  if Talisman.scoring_coroutine then Talisman.scoring_coroutine.state = "intro" end
  text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta = evaluate_play_intro()
  if not G.GAME.blind:debuff_hand(G.play.cards, poker_hands, text) then
    if Talisman.scoring_coroutine then Talisman.scoring_coroutine.state = "main" end
    text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta = evaluate_play_main(text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta)
  else
    if Talisman.scoring_coroutine then Talisman.scoring_coroutine.state = "debuff" end
    text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta = evaluate_play_debuff(text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta)
  end
  if Talisman.scoring_coroutine then Talisman.scoring_coroutine.state = "final_scoring" end
  text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta = evaluate_play_final_scoring(text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta)
  if Talisman.scoring_coroutine then Talisman.scoring_coroutine.state = "after" end
  evaluate_play_after(text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta)
  if Talisman.scoring_coroutine then Talisman.scoring_coroutine.state = nil end
end

function Talisman.no_anims_calculating()
  return Talisman.config_file.disable_anims and (Talisman.current_calc.joker or Talisman.current_calc.score or Talisman.current_calc.card)
end

local upd = Game.update
function Game:update(dt)
    if Talisman.dollar_update then
      G.HUD:get_UIE_by_ID('dollar_text_UI').config.object:update()
      G.HUD:recalculate()
      Talisman.dollar_update = false
    end
    return upd(self, dt)
end

local gfep = G.FUNCS.evaluate_play
G.FUNCS.evaluate_play = function(e)
	Talisman.current_calc.score = true
	local ret = gfep(e)
	Talisman.current_calc.score = false
	return ret
end

--Easing fixes
--Changed this to always work; it's less pretty but fine for held in hand things
local edo = ease_dollars
function ease_dollars(mod, instant)
  if not Talisman.config_file.disable_anims then return edo(mod, instant) end --and (Talisman.current_calc.joker or Talisman.current_calc.score or Talisman.current_calc.card) then

  mod = mod or 0
  if to_big(mod) > BigC.ZERO then inc_career_stat('c_dollars_earned', mod) end
  G.GAME.dollars = G.GAME.dollars + mod
  Talisman.dollar_update = true
end

local sm = Card.start_materialize
function Card:start_materialize(a,b,c)
    if Talisman.no_anims_calculating() then return end
    return sm(self,a,b,c)
end

local sd = Card.start_dissolve
function Card:start_dissolve(a,b,c,d)
    if Talisman.no_anims_calculating() then return self:remove() end
    return sd(self,a,b,c,d)
end

local ss = Card.set_seal
function Card:set_seal(a,b,immediate)
    return ss(self,a,b,immediate or Talisman.no_anims_calculating())
end

local cest = card_eval_status_text
function card_eval_status_text(a,b,c,d,e,f)
    if not Talisman.config_file.disable_anims then return cest(a,b,c,d,e,f) end
end

local jc = juice_card
function juice_card(x)
    if not Talisman.config_file.disable_anims then return jc(x) end
end

local cju = Card.juice_up
function Card:juice_up(...)
    if not Talisman.config_file.disable_anims then return cju(self, ...) end
end

local uht = update_hand_text
function update_hand_text(config, vals)
    if not Talisman.config_file.disable_anims then return uht(config, vals) end

end

local gfer = G.FUNCS.evaluate_round
function G.FUNCS.evaluate_round()
  if not Talisman.config_file.disable_anims then return gfer() end

  if to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips) then
      add_round_eval_row({dollars = G.GAME.blind.dollars, name='blind1', pitch = 0.95})
  else
      add_round_eval_row({dollars = 0, name='blind1', pitch = 0.95, saved = true})
  end
  local arer = add_round_eval_row
  add_round_eval_row = function() return end
  local dollars = gfer()
  add_round_eval_row = arer
  add_round_eval_row({name = 'bottom', dollars = Talisman.dollars})
end