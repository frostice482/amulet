--scoring coroutine

local oldplay = G.FUNCS.evaluate_play
local co = {
	frametime = 0.03,
	framecalc = 250,
}
Talisman.coroutine = co

function co.func()
	local f
	f = oldplay

	if Talisman.config_file.debug_coroutine then
		local ff = f
		function f(...)
			return assert(xpcall(ff, function(err)
				local handler = love.errorhandler(err)
				function love.errorhandler() return handler end
				return err
			end))
		end
	end

	return f
end

function co.create_state()
	return {
		coroutine = coroutine.create(co.func()),
		yield = love.timer.getTime(),
		time = 0,
		calculations = 0,
		frames = 0
	}
end

function co.initialize_state()
	Talisman.scoring_coroutine = co.create_state()
	G.SCORING_COROUTINE = Talisman.scoring_coroutine
end

function co.resume(...)
	if not Talisman.scoring_coroutine then return end
	Talisman.scoring_coroutine.yield = love.timer.getTime()
	Talisman.scoring_coroutine.frames = Talisman.scoring_coroutine.frames + 1
	return assert(coroutine.resume(Talisman.scoring_coroutine.coroutine, ...))
end

function co.shouldyield()
	return Talisman.scoring_coroutine
		and Talisman.scoring_coroutine.calculations % co.framecalc == 0
		and Talisman.scoring_coroutine.yield
		and love.timer.getTime() - Talisman.scoring_coroutine.yield > co.frametime
		and coroutine.running()
end

function co.clear_state()
	Talisman.scoring_coroutine = nil
	G.SCORING_COROUTINE = nil

	Talisman.current_calc.score = nil
	Talisman.current_calc.joker = nil
	Talisman.current_calc.card = nil
	co.aborted = nil
end

function co.forcestop()
	if not Talisman.scoring_coroutine then return end

	G.FUNCS.exit_overlay_menu()
	if co.aborted and Talisman.scoring_coroutine.state == "main" then
		evaluate_play_final_scoring(unpack(Talisman.scoring_coroutine.astate, 1, 7))
	end
	G.GAME.LAST_CALCS = Talisman.scoring_coroutine.calculations
	G.GAME.LAST_CALC_TIME = Talisman.scoring_coroutine.time
	co.clear_state()
end

function co.create_text_ui(texts)
	local nodes = {}

	table.insert(nodes, {
		n = G.UIT.R,
		config = { padding = 0.2, align = "cm" },
		nodes = {
			{ n = G.UIT.T, config = { colour = G.C.WHITE, scale = 1, text = localize("tal_calculating") } },
		}
	})

	for i in ipairs(texts) do
		table.insert(nodes, {
			n = G.UIT.R,
			nodes = {
				{ n = G.UIT.T, config = { colour = G.C.WHITE, scale = 0.4, ref_table = texts, ref_value = i } },
			}
		})
	end

	table.insert(nodes, {
		n = G.UIT.R,
		config = { padding = 0.2, align = "cm" },
		nodes = {
			UIBox_button({
				colour = G.C.BLUE,
				button = "tal_abort",
				label = { localize("tal_abort") },
				minw = 4.5,
				focus_args = { snap_to = true },
			})
		}
	})

	return {
		n = G.UIT.C,
		nodes = nodes
	}
end

function co.create_overlay_ui(texts)
	return {
		n = G.UIT.ROOT,
		config = {
			align = "cm",
			padding = 9999,
			offset = { x = 0, y = -3 },
			r = 0.1,
			colour = { G.C.GREY[1], G.C.GREY[2], G.C.GREY[3], 0.7 }
		},
		nodes = { co.create_text_ui(texts) }
	}
end

function co.overlay()
	co.scoring_text = {
		"", -- currently calculating
		"", -- card progress
		--"", -- joker progress
		"", -- lua mem
	}
	if G.GAME.LAST_CALCS then
		local text = string.format("%s: %d (%.2fs)", localize("tal_last_elapsed"), G.GAME.LAST_CALCS, G.GAME.LAST_CALC_TIME)
		table.insert(co.scoring_text, text)
	end

	G.FUNCS.overlay_menu({
		definition = co.create_overlay_ui(co.scoring_text),
		config = { align = "cm", offset = { x = 0, y = 0 }, major = G.ROOM_ATTACH, bond = 'Weak' }
	})
end

function co.update_text()
	if not Talisman.scoring_coroutine or not co.scoring_text then return end

	co.scoring_text[1] = string.format("%s: %d (%.2fs)", localize("tal_elapsed"), Talisman.scoring_coroutine.calculations, Talisman.scoring_coroutine.time)

	if Talisman.scoring_coroutine.card then
		local card = Talisman.scoring_coroutine.card
		local desc = card.area == G.hand and 'hand' or 'play'
		co.scoring_text[2] = string.format("%s: %d/%d (%s)", localize("tal_card_prog"), card.rank, #card.area.cards, desc or '???')
	else
		co.scoring_text[2] = string.format("%s: -", localize("tal_card_prog"))
	end

	--[[
	if Talisman.scoring_coroutine.joker then
		local card = Talisman.scoring_coroutine.joker
		Talisman.scoring_text[3] = string.format("%s: %d/%d", localize("tal_joker_prog"), card.rank, #card.area.cards)
	else
		Talisman.scoring_text[3] = string.format("%s: -", localize("tal_joker_prog"))
	end
	]]

	co.scoring_text[3] = string.format("%s: %.2fMB", localize("tal_luamem"), collectgarbage('count') / 1024)
end

function co.update(dt)
	if not Talisman.scoring_coroutine then return end

	if collectgarbage("count") > 1024 * 1024 then
		collectgarbage("collect")
	end

	if coroutine.status(Talisman.scoring_coroutine.coroutine) == "dead" or co.aborted then
		co.forcestop()
		return
	end

	co.resume()

	if not G.OVERLAY_MENU then
		co.overlay()
	else
		Talisman.scoring_coroutine.time = Talisman.scoring_coroutine.time + dt
		co.update_text()
	end
end

function G.FUNCS.evaluate_play(...)
	co.initialize_state()
	return co.resume(...)
end

function G.FUNCS.tal_abort()
	co.aborted = true
end

local _update = love.update
function love.update(dt, ...)
	if Talisman.scoring_coroutine then co.update(dt) end
	return _update(dt, ...)
end

local _eval_card = eval_card
function eval_card(card, ctx)
	if not Talisman.scoring_coroutine then return _eval_card(card, ctx) end

	local iv = Talisman.current_calc.card
	Talisman.current_calc.card = (iv or 0) + 1
	if not iv then
		if card.area == G.hand or card.area == G.play then
			Talisman.scoring_coroutine.card = card
		--[[elseif card.area == G.jokers then
			Talisman.scoring_coroutine.joker = card
		]]
		end
	end

	local ret, a, b = _eval_card(card, ctx)

	Talisman.current_calc.card = iv
	return ret, a, b
end

local _calc_joker = Card.calculate_joker
function Card:calculate_joker(context)
	if not Talisman.scoring_coroutine then return _calc_joker(self, context) end
	Talisman.scoring_coroutine.calculations = Talisman.scoring_coroutine.calculations + 1
	if co.shouldyield() then coroutine.yield() end

	local iv = Talisman.current_calc.joker
	Talisman.current_calc.joker = (iv or 0) + 1
	--[[if not iv and self.area == G.jokers then
		Talisman.scoring_coroutine.joker = self
	end]]

	local ret, trig = _calc_joker(self, context)
	Talisman.current_calc.joker = iv
	return ret, trig
end

local _ca_align = CardArea.align_cards
function CardArea:align_cards(...)
	if not Talisman.scoring_coroutine then return _ca_align(self, ...) end
end

local _c_move = Card.move
function Card:move(...)
	if not Talisman.scoring_coroutine then return _c_move(self, ...) end
end

local _m_move = Moveable.move
function Moveable:move(...)
	if not Talisman.scoring_coroutine then return _m_move(self, ...) end
end

local _m_align_major = Moveable.align_to_major
function Moveable:align_to_major(...)
	if not Talisman.scoring_coroutine or Talisman.scoring_coroutine.frames < 3 then return _m_align_major(self, ...) end
end

local _uie_update = UIElement.update
function UIElement:update(...)
	if not Talisman.scoring_coroutine or Talisman.scoring_coroutine.frames % 10 == 0 then return _uie_update(self, ...) end
end
